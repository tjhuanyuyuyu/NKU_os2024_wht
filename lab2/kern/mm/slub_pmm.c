#include <list.h>
#include <string.h>
#include <assert.h>
#include <stdio.h>
#include <stdlib.h> 
#include "best_fit_pmm.c" 
#include<pmm.h>
#include<slub_pmm.h>

#define PAGE_SIZE 4096
#define NUM_CACHES 5

// 定义支持的对象大小
static size_t kmalloc_size[NUM_CACHES] = {8, 32, 128, 512, 2048};

// 每个对象大小对应一个kmem_cache
struct kmem_cache kmalloc_caches[NUM_CACHES];

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

// 初始化slub分配器
void slub_init(void) {
    for (int i = 0; i < NUM_CACHES; i++) {
        kmem_cache_init(&kmalloc_caches[i], kmalloc_size[i]);
    }
}

// 根据对象大小选择合适的kmem_cache并分配内存
void *slub_alloc(size_t size) {
    for (int i = 0; i < NUM_CACHES; i++) {
        if (size <= kmalloc_size[i]) {
            return kmem_cache_alloc(&kmalloc_caches[i]);
        }
    }
    return NULL; // 如果请求的大小超过最大值，返回NULL
}

// 释放对象
void slub_free(void *objp, size_t size) {
    for (int i = 0; i < NUM_CACHES; i++) {
        if (size <= kmalloc_size[i]) {
            kmem_cache_free(&kmalloc_caches[i], objp);
            return;
        }
    }
}

// 打印slab信息，用于调试
void print_slab_info(struct kmem_cache *cache) {
    list_entry_t *le;
    printf("Slab cache for size %zu bytes:\n", cache->obj_size);

    // 遍历部分空闲的slab
    list_for_each(le, &cache->slab_partial) {
        struct slab *slab = le2struct(le, struct slab, slab_link);
        printf("  Partial slab: total_objs = %zu, free_objs = %zu\n",
               slab->total_objs, slab->free_objs);
    }

    // 遍历完全占用的slab
    list_for_each(le, &cache->slab_full) {
        struct slab *slab = le2struct(le, struct slab, slab_link);
        printf("  Full slab: total_objs = %zu, free_objs = %zu\n",
               slab->total_objs, slab->free_objs);
    }
}

// 测试分配和释放
void slub_check(void) {
    slub_init();

    // 分配多个对象
    printf("Allocating 3 objects of size 32 bytes...\n");
    void *objs[3];
    for (int i = 0; i < 3; i++) {
        objs[i] = slub_alloc(32);
        printf("Allocated object at address: %p\n", objs[i]);
    }

    // 打印slab信息
    print_slab_info(&kmalloc_caches[1]);

    // 释放对象
    printf("\nFreeing 3 objects of size 32 bytes...\n");
    for (int i = 0; i < 3; i++) {
        slub_free(objs[i], 32);
        printf("Freed object at address: %p\n", objs[i]);
    }

    // 再次打印slab信息
    print_slab_info(&kmalloc_caches[1]);
}
