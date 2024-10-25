#include <default_pmm.h>
#include <best_fit_pmm.h>
#include <buddy_system_pmm.h>
#include <defs.h>
#include <error.h>
#include <memlayout.h>
#include <mmu.h>
#include <pmm.h>
#include <sbi.h>
#include <stdio.h>
#include <string.h>
#include <../sync/sync.h>
#include <riscv.h>

// 虚拟地址的物理页面数组
struct Page *pages;
// 物理内存的总量（以页面为单位）
size_t npage = 0;
// 内核映像映射在 VA=KERNBASE 和 PA=info.base
uint64_t va_pa_offset;
// 内存从 0x80000000 开始，RISC-V 中的 DRAM_BASE 定义为 0x80000000
const size_t nbase = DRAM_BASE / PGSIZE;

// 启动时页面目录的虚拟地址
uintptr_t *satp_virtual = NULL;
// 启动时页面目录的物理地址
uintptr_t satp_physical;

// 物理内存管理
const struct pmm_manager *pmm_manager;

// 检查分配页面的函数
static void check_alloc_page(void);

// init_pmm_manager - 初始化 pmm_manager 实例
static void init_pmm_manager(void) {
    pmm_manager = &best_fit_pmm_manager;  // 使用最佳适应算法的物理内存管理
    cprintf("memory management: %s\n", pmm_manager->name);  // 输出当前使用的内存管理算法名称
    pmm_manager->init();  // 调用初始化函数
}

// init_memmap - 调用 pmm->init_memmap 来构建自由内存的 Page 结构
static void init_memmap(struct Page *base, size_t n) {
    pmm_manager->init_memmap(base, n);  // 初始化内存映射
}

// alloc_pages - 调用 pmm->alloc_pages 分配连续的 n*PAGESIZE 内存
struct Page *alloc_pages(size_t n) {
    struct Page *page = NULL;
    bool intr_flag;
    local_intr_save(intr_flag);  // 保存当前中断状态
    {
        page = pmm_manager->alloc_pages(n);  // 调用物理内存管理器的分配函数
    }
    local_intr_restore(intr_flag);  // 恢复中断状态
    return page;  // 返回分配的页面
}

// free_pages - 调用 pmm->free_pages 释放连续的 n*PAGESIZE 内存
void free_pages(struct Page *base, size_t n) {
    bool intr_flag;
    local_intr_save(intr_flag);  // 保存当前中断状态
    {
        pmm_manager->free_pages(base, n);  // 调用物理内存管理器的释放函数
    }
    local_intr_restore(intr_flag);  // 恢复中断状态
}

// nr_free_pages - 调用 pmm->nr_free_pages 获取当前可用内存的大小（nr*PAGESIZE）
size_t nr_free_pages(void) {
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);  // 保存当前中断状态
    {
        ret = pmm_manager->nr_free_pages();  // 获取可用页面数量
    }
    local_intr_restore(intr_flag);  // 恢复中断状态
    return ret;  // 返回可用页面数量
}

// page_init - 初始化页面
static void page_init(void) {
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;  // 设置虚拟地址与物理地址的偏移

    uint64_t mem_begin = KERNEL_BEGIN_PADDR;  // 内存起始地址
    uint64_t mem_size = PHYSICAL_MEMORY_END - KERNEL_BEGIN_PADDR;  // 物理内存大小
    uint64_t mem_end = PHYSICAL_MEMORY_END;  // 物理内存结束地址

    cprintf("physcial memory map:\n");  // 输出物理内存映射信息
    cprintf("  memory: 0x%016lx, [0x%016lx, 0x%016lx].\n", mem_size, mem_begin,
            mem_end - 1);  // 输出内存大小及范围

    uint64_t maxpa = mem_end;  // 最大物理地址

    if (maxpa > KERNTOP) {  // 限制最大物理地址
        maxpa = KERNTOP;
    }

    extern char end[];  // 内核结束位置

    npage = maxpa / PGSIZE;  // 计算物理页面总数
    // 内核在 end[] 结束，pages 是剩余页面的起始地址
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);  // 对齐内存页

    // 将保留的页面标记为已保留
    for (size_t i = 0; i < npage - nbase; i++) {
        SetPageReserved(pages + i);
    }

    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));  // 计算空闲内存的起始地址

    mem_begin = ROUNDUP(freemem, PGSIZE);  // 对齐起始地址
    mem_end = ROUNDDOWN(mem_end, PGSIZE);  // 对齐结束地址
    if (freemem < mem_end) {
        // 初始化内存映射，将空闲页面加入管理
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
    }
}

/* pmm_init - 初始化物理内存管理 */
void pmm_init(void) {
    // 我们需要分配/释放物理内存（粒度为 4KB 或其他大小）。
    // 因此在 pmm.h 中定义了物理内存管理框架（struct pmm_manager）。
    // 首先我们应根据框架初始化一个物理内存管理器（pmm）。
    // 然后 pmm 可以分配/释放物理内存。
    // 现在可以使用 first_fit/best_fit/worst_fit/buddy_system 等 pmm。
    init_pmm_manager();  // 初始化物理内存管理器

    // 检测物理内存空间，保留已使用的内存，
    // 然后使用 pmm->init_memmap 创建自由页面列表
    page_init();

    // 使用 pmm->check 验证 pmm 中分配/释放函数的正确性
    check_alloc_page();

    extern char boot_page_table_sv39[];
    satp_virtual = (pte_t*)boot_page_table_sv39;  // 获取启动时的虚拟页表
    satp_physical = PADDR(satp_virtual);  // 获取物理地址
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);  // 输出虚拟和物理地址
}

// 检查页面分配
static void check_alloc_page(void) {
    pmm_manager->check();  // 调用检查函数
    cprintf("check_alloc_page() succeeded!\n");  // 输出检查成功信息
}
