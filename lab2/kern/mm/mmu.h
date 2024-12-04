#ifndef __KERN_MM_MMU_H__
#define __KERN_MM_MMU_H__

#ifndef __ASSEMBLER__
#include <defs.h>
#endif

#define PGSIZE          4096                    // ÿ��ҳ��ӳ����ֽ���
#define PGSHIFT         12                      // ÿ��ҳ���λ�ƣ�log2(PGSIZE)

// ����/�����ַ��ҳ����
#define PPN(la) (((uintptr_t)(la)) >> PGSHIFT)

// Sv39 ���Ե�ַ�ṹ
// +-------9--------+-------9--------+--------9---------+----------12----------+
// |      VPN2      |      VPN1      |       VPN0       |  ҳ����ƫ��         |
// +----------------+----------------+------------------+----------------------+

// RISC-V64 �е� Sv39 ʹ�� 39 λ�����ַ���� 56 λ�����ַ��
// Sv39 ҳ�����:
// +-------10--------+--------26-------+--------9----------+--------9--------+---2----+-------8-------+
// |    ����         |      PPN[2]     |      PPN[1]       |      PPN[0]     | ����  | D | A | G | U | X | W | R | V |
// +-----------------+-----------------+-------------------+-----------------+--------+---------------+

/* ҳ��Ŀ¼��ҳ����� */
#define SV39_NENTRY          512                     // ÿ��ҳ��Ŀ¼�е�ҳ��Ŀ¼������

#define SV39_PGSIZE          4096                    // ÿ��ҳ��ӳ����ֽ���
#define SV39_PGSHIFT         12                      // ÿ��ҳ���λ�ƣ�log2(PGSIZE)
#define SV39_PTSIZE          (PGSIZE * SV39_NENTRY)  // ҳ��Ŀ¼��ӳ����ֽ���
#define SV39_PTSHIFT         21                      // ҳ��Ŀ¼���С��λ��

#define SV39_VPN0SHIFT       12                      // ���Ե�ַ�� VPN0 ��ƫ��
#define SV39_VPN1SHIFT       21                      // ���Ե�ַ�� VPN1 ��ƫ��
#define SV39_VPN2SHIFT       30                      // ���Ե�ַ�� VPN2 ��ƫ��
#define SV39_PTE_PPN_SHIFT   10                      // �����ַ�� PPN ��ƫ��

#define SV39_VPN0(la) ((((uintptr_t)(la)) >> SV39_VPN0SHIFT) & 0x1FF) // ��ȡ���Ե�ַ�е� VPN0
#define SV39_VPN1(la) ((((uintptr_t)(la)) >> SV39_VPN1SHIFT) & 0x1FF) // ��ȡ���Ե�ַ�е� VPN1
#define SV39_VPN2(la) ((((uintptr_t)(la)) >> SV39_VPN2SHIFT) & 0x1FF) // ��ȡ���Ե�ַ�е� VPN2
#define SV39_VPN(la, n) ((((uintptr_t)(la)) >> 12 >> (9 * n)) & 0x1FF) // ��ȡ���Ե�ַ�еĵ� n �� VPN

// ��������ƫ�ƹ������Ե�ַ
#define SV39_PGADDR(v2, v1, v0, o) ((uintptr_t)((v2) << SV39_VPN2SHIFT | (v1) << SV39_VPN1SHIFT | (v0) << SV39_VPN0SHIFT | (o)))

// ҳ����ҳ��Ŀ¼���еĵ�ַ
#define SV39_PTE_ADDR(pte)   (((uintptr_t)(pte) & ~0x1FF) << 3) // ��ȡҳ�����ĵ�ַ

// 3 ��ҳ��
#define SV39_PT0                 0 // ��һ��ҳ��
#define SV39_PT1                 1 // �ڶ���ҳ��
#define SV39_PT2                 2 // ������ҳ��

// ҳ����� (PTE) �ֶ�
#define PTE_V     0x001 // ��Чλ
#define PTE_R     0x002 // �ɶ�
#define PTE_W     0x004 // ��д
#define PTE_X     0x008 // ��ִ��
#define PTE_U     0x010 // �û���
#define PTE_G     0x020 // ȫ��
#define PTE_A     0x040 // �ѷ���
#define PTE_D     0x080 // ��λ
#define PTE_SOFT  0x300 // ���������ʹ��

#define PAGE_TABLE_DIR (PTE_V)              // ҳ���Ŀ¼�Ķ���
#define READ_ONLY (PTE_R | PTE_V)            // ֻ��
#define READ_WRITE (PTE_R | PTE_W | PTE_V)   // �ɶ���д
#define EXEC_ONLY (PTE_X | PTE_V)            // ����ִ��
#define READ_EXEC (PTE_R | PTE_X | PTE_V)    // �ɶ��Ϳ�ִ��
#define READ_WRITE_EXEC (PTE_R | PTE_W | PTE_X | PTE_V) // �ɶ�����д�Ϳ�ִ��

#define PTE_USER (PTE_R | PTE_W | PTE_X | PTE_U | PTE_V) // �û�Ȩ�޵�ҳ�����

#endif /* !__KERN_MM_MMU_H__ */
