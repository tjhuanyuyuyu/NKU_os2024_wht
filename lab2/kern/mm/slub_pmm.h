#ifndef __KERN_MM_SLUB_PMM_H__
#define __KERN_MM_SLUB_PMM_H__

#include <defs.h>

// 初始化 SLUB 内存分配器
void slub_init(void);

// 根据请求的大小分配内存
void *slub_alloc(size_t size);

// 释放指定的内存对象
void slub_free(void *objp);

// 检查 SLUB 内存分配器的状态和功能
void slub_check(void);

#endif /* !__KERN_MM_SLUB_PMM_H__ */

