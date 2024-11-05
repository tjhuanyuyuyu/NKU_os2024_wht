#ifndef __KERN_MM_MEMLAYOUT_H__
#define __KERN_MM_MEMLAYOUT_H__

/* All physical memory mapped at this address */
#define KERNBASE            0xFFFFFFFFC0200000 // = 0x80200000(物理内存里内核的起始位置, KERN_BEGIN_PADDR) + 0xFFFFFFFF40000000(偏移量, PHYSICAL_MEMORY_OFFSET)
//把原有内存映射到虚拟内存空间的最后一页
#define KMEMSIZE            0x7E00000          // the maximum amount of physical memory
// 0x7E00000 = 0x8000000 - 0x200000
// QEMU 缺省的RAM为 0x80000000到0x88000000, 128MiB, 0x80000000到0x80200000被OpenSBI占用
#define KERNTOP             (KERNBASE + KMEMSIZE) // 0x88000000对应的虚拟地址

#define PHYSICAL_MEMORY_END         0x88000000
#define PHYSICAL_MEMORY_OFFSET      0xFFFFFFFF40000000
#define KERNEL_BEGIN_PADDR          0x80200000
#define KERNEL_BEGIN_VADDR          0xFFFFFFFFC0200000


#define KSTACKPAGE          2                           // # of pages in kernel stack
#define KSTACKSIZE          (KSTACKPAGE * PGSIZE)       // sizeof kernel stack

#ifndef __ASSEMBLER__

#include <defs.h>
#include <atomic.h>
#include <list.h>

typedef uintptr_t pte_t;
typedef uintptr_t pde_t;

/* *
 * struct Page - Page descriptor structures. Each Page describes one
 * physical page. In kern/mm/pmm.h, you can find lots of useful functions
 * that convert Page to other data types, such as physical address.
 * */
struct Page {
    int ref;                        // 页框的引用计数
    uint64_t flags;                 // 描述页框状态的标志位数组
    unsigned int property;          // 空闲块的数量，用于首次适配的物理内存管理器
    list_entry_t page_link;         // 空闲链表链接
};

/* 描述页框状态的标志位 */
#define PG_reserved                 0       // 如果该位为1：该页被保留用于内核，不能用于 alloc/free_pages；否则，该位为0 
#define PG_property                 1       // 如果该位为1：该页是一个空闲内存块的头页（包含一些连续地址页），可以用于 alloc_pages；如果该位为0：如果该页是空闲内存块的头页，则该页和内存块已被分配；或者该页不是头页。

#define SetPageReserved(page)       set_bit(PG_reserved, &((page)->flags))  // 设置页为保留状态
#define ClearPageReserved(page)     clear_bit(PG_reserved, &((page)->flags)) // 清除页的保留状态
#define PageReserved(page)          test_bit(PG_reserved, &((page)->flags))  // 测试页是否被保留
#define SetPageProperty(page)       set_bit(PG_property, &((page)->flags))   // 设置页的属性
#define ClearPageProperty(page)     clear_bit(PG_property, &((page)->flags)) // 清除页的属性
#define PageProperty(page)          test_bit(PG_property, &((page)->flags))   // 测试页的属性

// 将链表项转换为页
#define le2page(le, member)                 \
    to_struct((le), struct Page, member)   // 将链表项转换为结构体 Page

/* free_area_t - 维护一个双向链表以记录空闲（未使用）页 */
typedef struct {
    list_entry_t free_list;         // 链表头
    unsigned int nr_free;           // 空闲页的数量
} free_area_t;                     // 空闲区域结构体

#endif /* !__ASSEMBLER__ */

#endif /* !__KERN_MM_MEMLAYOUT_H__ */
