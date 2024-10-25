#include <pmm.h>
#include <list.h>
#include <string.h>
#include <buddy_system_pmm.h>
#include <stdio.h>

extern free_area_t free_area;

#define free_list (free_area.free_list)
#define nr_free (free_area.nr_free)

//创建数据结构
typedef struct buddy2 {
    unsigned size;
    unsigned *longest;  // 用于管理树的数组
} buddy2_t;

struct buddy2 buddy;
struct Page* current_base;

// 初始化 buddy2 系统
static buddy2_t *buddy2_new(unsigned size) {   
    unsigned node_size;

    if (size < 1 || !IS_POWER_OF_2(size)) {
        return NULL;  // size 必须是 2 的幂
    }

    buddy.size = size;
    node_size = size * 2;

    for (unsigned i = 0; i < 2 * size - 1; i++) {
        if (IS_POWER_OF_2(i+1)) {
            node_size /= 2;
        }
        buddy.longest[i] = node_size;
    }

    return &buddy;
}

unsigned fixsize(size_t n){
    unsigned index=0;
    while ((1 << index) < n) {
        index++;
    }
    return (1<<index);
}

static void 
buddy_system_init(void) {
    list_init(&free_list);
    nr_free = 0;

    // 初始化 buddy system
    unsigned npage = 1048576; //2^20
    buddy2_new(npage);
}

static void 
buddy_system_init_memmap(struct Page *base, size_t n) {
    assert(n > 0);
    current_base=base;
    struct Page *p = base;
    for (; p != base + n; p++) {
        assert(PageReserved(p));
        p->flags = p->property = 0;
        set_page_ref(p, 0);
    }
    base->property = n;
    SetPageProperty(base);
    nr_free += n;

    // 按 buddy 分配算法管理 free_list 的链表结构
    if (list_empty(&free_list)) {
        list_add(&free_list, &(base->page_link));
    } else {
        list_entry_t *le = &free_list;
        while ((le = list_next(le)) != &free_list) {
            struct Page *page = le2page(le, page_link);
            if (base < page) {
                list_add_before(le, &(base->page_link));
                break;
            } else if (list_next(le) == &free_list) {
                list_add(le, &(base->page_link));
            }
        }
    }
}

static struct Page *
buddy_system_alloc_pages(size_t n) {
    assert(n > 0);
    unsigned offset = 0;

    if (n > nr_free) {
        return NULL;
    }

    unsigned current_size = IS_POWER_OF_2(n) ? n : fixsize(n);

    // 在 buddy system 中查找合适的块
    unsigned index = 0;
    unsigned node_size;
    for (node_size = buddy.size; node_size != current_size; node_size /= 2) {
        if (buddy.longest[2 * index + 1] >= current_size) {
            index = 2 * index + 1;
        } else {
            index = 2 * index + 2;
        }
    }
    if (buddy.longest[index] < n) {
        return NULL;
    }
    buddy.longest[index]=0;
    //从该节点往上修改相关的节点
    while(index>0){
        if(index%2==0){
            index = (index - 2) / 2;
        }
        else{
            index = (index - 1) / 2;
        }
        buddy.longest[index]=(buddy.longest[2 * index + 1] > buddy.longest[2 * index + 2]) ? buddy.longest[2 * index + 1] : buddy.longest[2 * index + 2];
    }


    // 找到合适的块，从链表中移除相应的页面
    offset = (index + 1) * node_size - buddy.size;
    struct Page *page = current_base+offset;
    page->property=0;

    unsigned page_size =fixsize(n);
    nr_free -= page_size;

    for(struct Page* i=page;i!=page+page_size;i++){
        ClearPageProperty(i);
    }

    return page;
}

static void 
buddy_system_free_pages(struct Page *base, size_t n) {
    assert(n > 0);

    // 重置页面的 flags
    unsigned size = IS_POWER_OF_2(n) ? n : fixsize(n);
    struct Page *p = base;
    for (; p != base + n; p++) {
        assert(!PageReserved(p) && !PageProperty(p));
        p->flags = 0;
        set_page_ref(p, 0);
    }
    base->property = n;

    // 确定起始节点的位置
    unsigned offset = base - current_base;
    unsigned index = offset + buddy.size - 1;
    buddy.longest[index] = size;
    nr_free += size;

    //将该节点上面的节点加上释放的内存
    while(index>0){
        // 找到父节点位置
        index = (index - 1) / 2;  

        // 获取左子节点和右子节点的大小
        unsigned left_size = buddy.longest[2 * index + 1];
        unsigned right_size = buddy.longest[2 * index + 2];

        // 如果左、右子节点都空闲且大小相等，则合并为更大的块
        int order =0;
        while(index >>= 1){
            order++;
        }

        //!!!!!确定是否为整个还有问题
        if (left_size == right_size && left_size == (1 << (buddy.size - index - 1))) {
            buddy.longest[index] = left_size * 2;
        } else {
            buddy.longest[index] = left_size>right_size?left_size:right_size;
        }
    }

     // 清除页面的属性
    for (struct Page *i = p; i != p + size; i++) {
        ClearPageProperty(i);
    }
}

// 查询剩余的空闲页面数量
static size_t buddy_system_nr_free_pages(void) {
    return nr_free;
}

static void
basic_check(void) {
    struct Page *p0, *p1, *p2;
    p0 = p1 = p2 = NULL;
    assert((p0 = alloc_page()) != NULL);
    assert((p1 = alloc_page()) != NULL);
    assert((p2 = alloc_page()) != NULL);

    assert(p0 != p1 && p0 != p2 && p1 != p2);
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);

    assert(page2pa(p0) < npage * PGSIZE);
    assert(page2pa(p1) < npage * PGSIZE);
    assert(page2pa(p2) < npage * PGSIZE);

    list_entry_t free_list_store = free_list;
    list_init(&free_list);
    assert(list_empty(&free_list));

    unsigned int nr_free_store = nr_free;
    nr_free = 0;

    assert(alloc_page() == NULL);

    free_page(p0);
    free_page(p1);
    free_page(p2);
    assert(nr_free == 3);

    assert((p0 = alloc_page()) != NULL);
    assert((p1 = alloc_page()) != NULL);
    assert((p2 = alloc_page()) != NULL);

    assert(alloc_page() == NULL);

    free_page(p0);
    assert(!list_empty(&free_list));

    struct Page *p;
    assert((p = alloc_page()) == p0);
    assert(alloc_page() == NULL);

    assert(nr_free == 0);
    free_list = free_list_store;
    nr_free = nr_free_store;

    free_page(p);
    free_page(p1);
    free_page(p2);
}

// LAB2: below code is used to check the best fit allocation algorithm 
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
buddy_system_check(void) {
    int score = 0 ,sumscore = 6;
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
        count ++, total += p->property;
    }
    assert(total == nr_free_pages());

    basic_check();

    #ifdef ucore_test
    score += 1;
    cprintf("grading: %d / %d points\n",score, sumscore);
    #endif
    struct Page *p0 = alloc_pages(5), *p1, *p2;
    assert(p0 != NULL);
    assert(!PageProperty(p0));

    #ifdef ucore_test
    score += 1;
    cprintf("grading: %d / %d points\n",score, sumscore);
    #endif
    list_entry_t free_list_store = free_list;
    list_init(&free_list);
    assert(list_empty(&free_list));
    assert(alloc_page() == NULL);

    #ifdef ucore_test
    score += 1;
    cprintf("grading: %d / %d points\n",score, sumscore);
    #endif
    unsigned int nr_free_store = nr_free;
    nr_free = 0;

    // * - - * -
    free_pages(p0 + 1, 2);
    free_pages(p0 + 4, 1);
    assert(alloc_pages(4) == NULL);
    assert(PageProperty(p0 + 1) && p0[1].property == 2);
    // * - - * *
    assert((p1 = alloc_pages(1)) != NULL);
    assert(alloc_pages(2) != NULL);      // best fit feature
    assert(p0 + 4 == p1);

    #ifdef ucore_test
    score += 1;
    cprintf("grading: %d / %d points\n",score, sumscore);
    #endif
    p2 = p0 + 1;
    free_pages(p0, 5);
    assert((p0 = alloc_pages(5)) != NULL);
    assert(alloc_page() == NULL);

    #ifdef ucore_test
    score += 1;
    cprintf("grading: %d / %d points\n",score, sumscore);
    #endif
    assert(nr_free == 0);
    nr_free = nr_free_store;

    free_list = free_list_store;
    free_pages(p0, 5);

    le = &free_list;
    while ((le = list_next(le)) != &free_list) {
        struct Page *p = le2page(le, page_link);
        count --, total -= p->property;
    }
    assert(count == 0);
    assert(total == 0);
    #ifdef ucore_test
    score += 1;
    cprintf("grading: %d / %d points\n",score, sumscore);
    #endif
}
//这个结构体在
const struct pmm_manager best_fit_pmm_manager = {
    .name = "buddy_system_pmm_manager",
    .init = buddy_system_init,
    .init_memmap = buddy_system_init_memmap,
    .alloc_pages = buddy_system_alloc_pages,
    .free_pages = buddy_system_free_pages,
    .nr_free_pages = buddy_system_nr_free_pages,
    .check = basic_check,
};

