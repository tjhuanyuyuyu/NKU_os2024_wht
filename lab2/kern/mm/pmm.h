#ifndef __KERN_MM_PMM_H__ // 防止头文件被多重包含
#define __KERN_MM_PMM_H__

#include <assert.h>       // 引入断言库
#include <atomic.h>      // 引入原子操作库
#include <defs.h>        // 引入定义文件
#include <memlayout.h>   // 引入内存布局文件
#include <mmu.h>         // 引入内存管理单元相关文件
#include <riscv.h>       // 引入 RISC-V 相关文件

// pmm_manager 是一个物理内存管理类。
// 一个特殊的 pmm 管理器 - XXX_pmm_manager
// 只需要实现 pmm_manager 类中的方法，
// 然后 XXX_pmm_manager 可以被 ucore 用于管理总的物理内存空间。
struct pmm_manager {
    const char *name;  // XXX_pmm_manager 的名称
    void (*init)(void);  // 初始化内部描述和管理数据结构
                          // （空闲块列表、空闲块数量等）的 XXX_pmm_manager
    void (*init_memmap)(struct Page *base, size_t n); // 根据初始的空闲物理内存空间
                                                      // 设置描述和管理数据结构
    struct Page *(*alloc_pages)(size_t n);  // 分配 >= n 页，取决于分配算法
    void (*free_pages)(struct Page *base, size_t n);  // 释放 >= n 页，以 "base" 为基地址的
                                                      // 页描述结构
    size_t (*nr_free_pages)(void);  // 返回空闲页的数量
    void (*check)(void);            // 检查 XXX_pmm_manager 的正确性
};

extern const struct pmm_manager *pmm_manager; // 外部定义的 pmm 管理器

void pmm_init(void); // 初始化物理内存管理

struct Page *alloc_pages(size_t n); // 分配 n 页
void free_pages(struct Page *base, size_t n); // 释放 n 页
size_t nr_free_pages(void); // 获取空闲页的数量

// 定义便捷宏，用于分配和释放单个页面
#define alloc_page() alloc_pages(1)
#define free_page(page) free_pages(page, 1)

/* *
 * PADDR - 将一个内核虚拟地址（指向 KERNBASE 以上的地址）转化为对应的物理地址。
 * 如果传入非内核虚拟地址，则触发 panic。
 * */
#define PADDR(kva)                                                 \
    ({                                                             \
        uintptr_t __m_kva = (uintptr_t)(kva);                      \
        if (__m_kva < KERNBASE) {                                  \
            panic("PADDR called with invalid kva %08lx", __m_kva); \
        }                                                          \
        __m_kva - va_pa_offset;                                    \
    })

/* *
 * KADDR - 将一个物理地址转化为对应的内核虚拟地址。
 * 如果传入无效的物理地址，则触发 panic。
 * */
/*
#define KADDR(pa)                                                \
    ({                                                           \
        uintptr_t __m_pa = (pa);                                 \
        size_t __m_ppn = PPN(__m_pa);                            \
        if (__m_ppn >= npage) {                                  \
            panic("KADDR called with invalid pa %08lx", __m_pa); \
        }                                                        \
        (void *)(__m_pa + va_pa_offset);                         \
    })
*/
extern struct Page *pages; // 外部定义的页面数组
extern size_t npage; // 页的数量
extern const size_t nbase; // 基地址的数量
extern uint64_t va_pa_offset; // 虚拟地址和物理地址之间的偏移

// 将 Page 结构转化为页号
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }

// 将 Page 结构转化为物理地址
static inline uintptr_t page2pa(struct Page *page) {
    return page2ppn(page) << PGSHIFT; // 页号左移以获取物理地址
}

// 获取页的引用计数
static inline int page_ref(struct Page *page) { return page->ref; }

// 设置页的引用计数
static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }

// 引用计数增加
static inline int page_ref_inc(struct Page *page) {
    page->ref += 1; // 引用计数加一
    return page->ref; // 返回当前引用计数
}

// 引用计数减少
static inline int page_ref_dec(struct Page *page) {
    page->ref -= 1; // 引用计数减一
    return page->ref; // 返回当前引用计数
}

// 将物理地址转化为 Page 结构
static inline struct Page *pa2page(uintptr_t pa) {
    if (PPN(pa) >= npage) { // 检查页号是否有效
        panic("pa2page called with invalid pa");
    }
    return &pages[PPN(pa) - nbase]; // 返回对应的 Page 结构
}

// 刷新 TLB（翻译后备缓冲区）
static inline void flush_tlb() { asm volatile("sfence.vm"); } // 执行刷新 TLB 的汇编指令

extern char bootstack[], bootstacktop[]; // 在 entry.S 中定义的引导栈顶和栈底

#endif /* !__KERN_MM_PMM_H__ */ // 结束条件
