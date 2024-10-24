#include <pmm.h>
#include <list.h>
#include <string.h>
#include <buddy_system_pmm.h>
#include <stdio.h>


#define max_order 20  //最大块大小，2^20=1048576 pages

//存储每一级空闲链表
free_area_t free_area[max_order+1];

static void
buddy_system_init(void) {
    for(int i=0;i<=max_order;i++)
    {
        list_init(&(free_area[i].free_list));
        free_area[i].nr_free = 0;
    }
}

static int order_from_size(size_t size) {
    int order = 0;
    size_t block_size = 1;

    while (block_size < size) {
        block_size <<= 1;
        order++;
    }
    return order;
}

static void buddy_system_init_memmap(struct Page *base, size_t n) {
    assert(n > 0);
    struct Page *p = base;

    // 初始化每一页
    for (; p != base + n; p++) {
        assert(PageReserved(p)); // 确保页面已保留
        p->flags = p->property = 0;  // 清空标志和属性
        set_page_ref(p, 0);  // 设置引用计数为0
    }

    base->property = n;  // 设置基本页的属性为总页数
    SetPageProperty(base); // 更新属性

    int order = order_from_size(n); // 根据页面数量获取 order
    for(int i=order;i<=max_order;i++)
    {
        free_area[order].nr_free += n; // 更新空闲页面数量
    }
    

    // 管理空闲链表
    if (list_empty(&free_area[order].free_list)) {
        list_add(&free_area[order].free_list, &(base->page_link)); // 添加到空闲列表
    } else {
        list_entry_t* le = free_area[order].free_list.next; // 从空闲链表的第一个元素开始

        // 遍历空闲链表
        while (le != &free_area[order].free_list) {
            struct Page* page = le2page(le, page_link); // 获取当前页面

            // 找到第一个大于 base 的页面，将 base 插入到它前面
            if (base < page) {
                list_add_before(le, &(base->page_link)); // 插入到当前页面之前
                break;
            }

            // 检查是否到达链表末尾
            le = list_next(le);
        }

        // 如果到达链表末尾，插入到链表尾部
        if (le == &free_area[order].free_list) {
            list_add(le, &(base->page_link));
        }
    }
}
