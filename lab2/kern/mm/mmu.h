#ifndef __KERN_MM_MMU_H__
#define __KERN_MM_MMU_H__

#ifndef __ASSEMBLER__
#include <defs.h>
#endif

#define PGSIZE          4096                    // 每个页面映射的字节数
#define PGSHIFT         12                      // 每个页面的位移，log2(PGSIZE)

// 物理/虚拟地址的页面编号
#define PPN(la) (((uintptr_t)(la)) >> PGSHIFT)

// Sv39 线性地址结构
// +-------9--------+-------9--------+--------9---------+----------12----------+
// |      VPN2      |      VPN1      |       VPN0       |  页面内偏移         |
// +----------------+----------------+------------------+----------------------+

// RISC-V64 中的 Sv39 使用 39 位虚拟地址访问 56 位物理地址！
// Sv39 页面表项:
// +-------10--------+--------26-------+--------9----------+--------9--------+---2----+-------8-------+
// |    保留         |      PPN[2]     |      PPN[1]       |      PPN[0]     | 保留  | D | A | G | U | X | W | R | V |
// +-----------------+-----------------+-------------------+-----------------+--------+---------------+

/* 页面目录和页面表常量 */
#define SV39_NENTRY          512                     // 每个页面目录中的页面目录项数量

#define SV39_PGSIZE          4096                    // 每个页面映射的字节数
#define SV39_PGSHIFT         12                      // 每个页面的位移，log2(PGSIZE)
#define SV39_PTSIZE          (PGSIZE * SV39_NENTRY)  // 页面目录项映射的字节数
#define SV39_PTSHIFT         21                      // 页面目录项大小的位移

#define SV39_VPN0SHIFT       12                      // 线性地址中 VPN0 的偏移
#define SV39_VPN1SHIFT       21                      // 线性地址中 VPN1 的偏移
#define SV39_VPN2SHIFT       30                      // 线性地址中 VPN2 的偏移
#define SV39_PTE_PPN_SHIFT   10                      // 物理地址中 PPN 的偏移

#define SV39_VPN0(la) ((((uintptr_t)(la)) >> SV39_VPN0SHIFT) & 0x1FF) // 获取线性地址中的 VPN0
#define SV39_VPN1(la) ((((uintptr_t)(la)) >> SV39_VPN1SHIFT) & 0x1FF) // 获取线性地址中的 VPN1
#define SV39_VPN2(la) ((((uintptr_t)(la)) >> SV39_VPN2SHIFT) & 0x1FF) // 获取线性地址中的 VPN2
#define SV39_VPN(la, n) ((((uintptr_t)(la)) >> 12 >> (9 * n)) & 0x1FF) // 获取线性地址中的第 n 个 VPN

// 从索引和偏移构造线性地址
#define SV39_PGADDR(v2, v1, v0, o) ((uintptr_t)((v2) << SV39_VPN2SHIFT | (v1) << SV39_VPN1SHIFT | (v0) << SV39_VPN0SHIFT | (o)))

// 页面表或页面目录项中的地址
#define SV39_PTE_ADDR(pte)   (((uintptr_t)(pte) & ~0x1FF) << 3) // 获取页面表项的地址

// 3 级页表
#define SV39_PT0                 0 // 第一级页表
#define SV39_PT1                 1 // 第二级页表
#define SV39_PT2                 2 // 第三级页表

// 页面表项 (PTE) 字段
#define PTE_V     0x001 // 有效位
#define PTE_R     0x002 // 可读
#define PTE_W     0x004 // 可写
#define PTE_X     0x008 // 可执行
#define PTE_U     0x010 // 用户级
#define PTE_G     0x020 // 全局
#define PTE_A     0x040 // 已访问
#define PTE_D     0x080 // 脏位
#define PTE_SOFT  0x300 // 保留给软件使用

#define PAGE_TABLE_DIR (PTE_V)              // 页面表目录的定义
#define READ_ONLY (PTE_R | PTE_V)            // 只读
#define READ_WRITE (PTE_R | PTE_W | PTE_V)   // 可读可写
#define EXEC_ONLY (PTE_X | PTE_V)            // 仅可执行
#define READ_EXEC (PTE_R | PTE_X | PTE_V)    // 可读和可执行
#define READ_WRITE_EXEC (PTE_R | PTE_W | PTE_X | PTE_V) // 可读、可写和可执行

#define PTE_USER (PTE_R | PTE_W | PTE_X | PTE_U | PTE_V) // 用户权限的页面表项

#endif /* !__KERN_MM_MMU_H__ */
