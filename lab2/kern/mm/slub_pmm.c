#include <list.h>
#include <string.h>
#include <assert.h>
#include <stdio.h>
#include <stdlib.h>  // 用于模拟页面申请和释放
#include "best_fit_pmm.c" // 引入best_fit_pmm.c

#define PAGE_SIZE 4096

// slab结构表示包含多个小对象的slab
struct slab {
    size_t obj_size;     // slab中每个对象的大小
    size_t total_objs;   // 该slab中的对象总数
    size_t free_objs;    // 可用对象数量
    void *freelist;      // 指向下一个空闲对象
    struct list_entry slab_link; // slab链表中的链接
};

// kmem_cache结构表示内存缓存
struct kmem_cache {
    size_t obj_size;             // 此缓存管理的对象大小
    struct list_entry slab_full; // 完全占用的slab（没有空闲对象）
    struct list_entry slab_partial; // 部分占用的slab（有空闲对象）
};

// 初始化kmem_cache
static void
kmem_cache_init(struct kmem_cache *cache, size_t obj_size) {
    cache->obj_size = obj_size;
    list_init(&cache->slab_full);
    list_init(&cache->slab_partial);
}

// 创建一个slab并分配页面，初始化对象
static struct slab *
create_slab(size_t obj_size) {
    struct slab *slab = (struct slab *)malloc(sizeof(struct slab));
    slab->obj_size = obj_size;
    slab->total_objs = PAGE_SIZE / obj_size;
    slab->free_objs = slab->total_objs;
    slab->freelist = best_fit_alloc_pages(PAGE_SIZE); // 使用best_fit分配页面
    void *obj = slab->freelist;

    // 初始化freelist，链接所有的对象
    for (size_t i = 1; i < slab->total_objs; i++) {
        void *next_obj = (char *)obj + obj_size;
        *((void **)obj) = next_obj;
        obj = next_obj;
    }
    *((void **)obj) = NULL; // 最后一个对象指向NULL
    return slab;
}

// 分配一个对象
static void *
kmem_cache_alloc(struct kmem_cache *cache) {
    if (list_empty(&cache->slab_partial)) {
        struct slab *new_slab = create_slab(cache->obj_size);
        list_add(&cache->slab_partial, &(new_slab->slab_link));
    }

    list_entry_t *le = list_next(&cache->slab_partial);
    struct slab *slab = le2struct(le, struct slab, slab_link);

    void *obj = slab->freelist;  // 获取第一个空闲对象
    slab->freelist = *((void **)obj);  // 更新freelist
    slab->free_objs--;

    if (slab->free_objs == 0) {
        list_del(&(slab->slab_link));
        list_add(&cache->slab_full, &(slab->slab_link));  // 移动到full列表
    }

    return obj;
}

// 释放一个对象
static void
kmem_cache_free(struct kmem_cache *cache, void *obj) {
    list_entry_t *le = list_next(&cache->slab_full);
    struct slab *slab = NULL;

    // 遍历所有的slab，找到对应的slab
    while (le != &cache->slab_full) {
        slab = le2struct(le, struct slab, slab_link);
        if ((char *)obj >= (char *)slab->freelist &&
            (char *)obj < (char *)slab->freelist + PAGE_SIZE) {
            break;
        }
        le = list_next(le);
    }

    // 释放对象，重新插入freelist
    *((void **)obj) = slab->freelist;
    slab->freelist = obj;
    slab->free_objs++;

    if (slab->free_objs == slab->total_objs) {
        // slab完全空闲，释放该slab
        list_del(&(slab->slab_link));
        free(slab->freelist);
        free(slab);
    } else if (slab->free_objs == 1) {
        list_del(&(slab->slab_link));
        list_add(&cache->slab_partial, &(slab->slab_link));  // 移动回partial列表
    }
}

static void
slub_basic_check(void) {
    struct slab *slab0, *slab1, *slab2;
    slab0 = slab1 = slab2 = NULL;

    // 申请三个 slab
    assert((slab0 = create_slab(64)) != NULL); // 创建大小为64的slab
    assert((slab1 = create_slab(64)) != NULL);
    assert((slab2 = create_slab(64)) != NULL);

    assert(slab0 != slab1 && slab0 != slab2 && slab1 != slab2);
    assert(slab0->free_objs == slab0->total_objs);
    assert(slab1->free_objs == slab1->total_objs);
    assert(slab2->free_objs == slab2->total_objs);

    list_entry_t free_list_store = free_list;
    list_init(&free_list);
    assert(list_empty(&free_list));

    unsigned int nr_free_store = nr_free;
    nr_free = 0;

    assert(alloc_page() == NULL); // 检查没有可用页面

    // 释放三个 slab
    free_slab(slab0);
    free_slab(slab1);
    free_slab(slab2);
    assert(nr_free == 3);

    // 再次申请三个 slab
    assert((slab0 = create_slab(64)) != NULL);
    assert((slab1 = create_slab(64)) != NULL);
    assert((slab2 = create_slab(64)) != NULL);

    assert(alloc_page() == NULL); // 检查没有可用页面

    free_slab(slab0);
    assert(!list_empty(&free_list));

    struct slab *slab;
    assert((slab = alloc_slab()) == slab0); // 检查分配的 slab 是 slab0
    assert(alloc_page() == NULL); // 检查没有可用页面

    assert(nr_free == 0);
    free_list = free_list_store;
    nr_free = nr_free_store;

    free_slab(slab);
    free_slab(slab1);
    free_slab(slab2);
}

// LAB2: 用于检查 SLUB 内存分配算法的代码
static void
slub_default_check(void) {
    int count = 0, total = 0;
    list_entry_t *le = &free_list;

    // 检查 free_list 中的所有 slab
    while ((le = list_next(le)) != &free_list) {
        struct slab *s = le2slab(le, slab_link);
        assert(s->free_objs == s->total_objs);
        count++, total += s->total_objs;
    }
    assert(total == nr_free_slabs());

    slub_basic_check();

    struct slab *slab0 = create_slab(128), *slab1, *slab2;
    assert(slab0 != NULL);
    assert(slab0->free_objs == slab0->total_objs);

    list_entry_t free_list_store = free_list;
    list_init(&free_list);
    assert(list_empty(&free_list));
    assert(alloc_page() == NULL);

    unsigned int nr_free_store = nr_free;
    nr_free = 0;

    free_slabs(slab0 + 2, 3); // 释放 slab0 的部分
    assert(alloc_slabs(4) == NULL);
    assert(slab0 + 2->free_objs == 3);
    assert((slab1 = alloc_slabs(3)) != NULL);
    assert(alloc_page() == NULL);
    assert(slab0 + 2 == slab1);

    slab2 = slab0 + 1;
    free_slab(slab0);
    free_slabs(slab1, 3);
    assert(slab0->free_objs == 1);
    assert(slab1->free_objs == 3);

    assert((slab0 = alloc_slab()) == slab2 - 1);
    free_slab(slab0);
    assert((slab0 = alloc_slabs(2)) == slab2 + 1);

    free_slabs(slab0, 2);
    free_slab(slab2);

    assert((slab0 = alloc_slabs(5)) != NULL);
    assert(alloc_page() == NULL);

    assert(nr_free == 0);
    nr_free = nr_free_store;

    free_list = free_list_store;
    free_slabs(slab0, 5);

    le = &free_list;
    while ((le = list_next(le)) != &free_list) {
        struct slab *s = le2slab(le, slab_link);
        count--, total -= s->free_objs;
    }
    assert(count == 0);
    assert(total == 0);
}
