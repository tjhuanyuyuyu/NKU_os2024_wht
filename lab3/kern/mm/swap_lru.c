#include <defs.h>
#include <riscv.h>
#include <stdio.h>
#include <string.h>
#include <swap.h>
#include <swap_lru.h>
#include <list.h>

//最近最少使用算法
/*LRU 算法追踪每个页面的访问顺序，每当访问一个页面时，它被标记为最近使用。
 *为了找到最久未使用的页面，LRU 会记录每个页面的使用历史。
 （未访问（PTE_A 位未设置），则visited++,访问则为0）
 （visited为距离上次访问的时间）
 *在页面替换时，选择最久没有被访问过的页面进行替换。（即visited最大）
*/
extern list_entry_t pra_list_head;


static int
_lru_init_mm(struct mm_struct *mm)
{     
     list_init(&pra_list_head);
     mm->sm_priv = &pra_list_head;//全局的链表头部，用于管理 lru 页面替换算法中的页面
     return 0;
}


/*计算同一个根目录下页面的访问次数*/
/*对物理页面进行遍历，查看物理页面在过去的一段时间内访问的次数，visited变量代表着该物理页面
 在过去的一段时间多久没有访问了，如果没有访问，则visited加1,表明没有再次访问（时间加长）
 如果访问则重置为0；
 */
static int
_lru_check(struct mm_struct *mm){
    list_entry_t *head=(list_entry_t*) mm->sm_priv;
    assert(head != NULL);
    list_entry_t *curr_ptr=head;//
    assert(curr_ptr != NULL);

    while((curr_ptr=list_prev(curr_ptr))!=head){
        struct Page* curr_page=le2page(curr_ptr,pra_page_link);
        pte_t* tep_pte=get_pte(mm->pgdir,curr_page->pra_vaddr,0);

        if(*tep_pte & PTE_A){
            //如果页面最近被访问过（PTE_A 被设置），则将其 visited 归零，表示它被“重置”为最近访问。
            curr_page->visited=0;
            *tep_pte = *tep_pte ^ PTE_A;
        } 
        else{
            //如果页面没有被访问（PTE_A 没有被设置），则增加 visited 值，表示它被冷却了更久
            curr_page->visited++;
        }
    }
    

}

/*加入page，头插法  把需要的新的页面加入*/
static int
_lru_map_swappable(struct mm_struct *mm, uintptr_t addr, struct Page *page, int swap_in)
{
    _lru_check(mm);
    list_entry_t *head=(list_entry_t*) mm->sm_priv;
    list_entry_t *entry=&(page->pra_page_link);
    assert(entry != NULL && head != NULL);
    list_add(head, entry);
    page->visited=0;

    return 0;
}

/*将最久没有访问的页面换出，删除页面
 寻找最久没有访问的页面：遍历链表，将节点转换为页，寻找最大值，替换*/
static int  _lru_swap_out_victim(struct mm_struct *mm, struct Page ** ptr_page, int in_tick)
{
    _lru_check(mm);
    list_entry_t *head=(list_entry_t*) mm->sm_priv;
    assert(head != NULL);
    assert(in_tick==0);
   
    list_entry_t *curr_ptr=list_prev(head);
    list_entry_t *lru_ptr=curr_ptr;
    uint_t largest_visited=le2page(curr_ptr,pra_page_link)->visited;//得到最久没有使用的页面

    while(1){

        if(curr_ptr == head){
            break;
        }
        if(le2page(curr_ptr,pra_page_link)->visited > largest_visited){
            largest_visited=le2page(curr_ptr,pra_page_link)->visited;
            lru_ptr=curr_ptr;
            
        }
        curr_ptr=list_prev(curr_ptr);
    }
    list_del(lru_ptr);
    *ptr_page = le2page(lru_ptr, pra_page_link);
    cprintf("curr_ptr %p\n", lru_ptr);

    return 0;
}

static int
_lru_check_swap(void) {
   #ifdef ucore_test
    int score = 0, totalscore = 5;
    cprintf("%d\n", &score);
    ++ score; cprintf("grading %d/%d points", score, totalscore);
    *(unsigned char *)0x3000 = 0x0c;
    assert(pgfault_num==4);
    *(unsigned char *)0x1000 = 0x0a;
    assert(pgfault_num==4);
    *(unsigned char *)0x4000 = 0x0d;
    assert(pgfault_num==4);
    *(unsigned char *)0x2000 = 0x0b;
    ++ score; cprintf("grading %d/%d points", score, totalscore);
    assert(pgfault_num==4);
    *(unsigned char *)0x5000 = 0x0e;
    assert(pgfault_num==5);
    *(unsigned char *)0x2000 = 0x0b;
    assert(pgfault_num==5);
    ++ score; cprintf("grading %d/%d points", score, totalscore);
    *(unsigned char *)0x1000 = 0x0a;
    assert(pgfault_num==5);
    *(unsigned char *)0x2000 = 0x0b;
    assert(pgfault_num==5);
    *(unsigned char *)0x3000 = 0x0c;
    assert(pgfault_num==5);
    ++ score; cprintf("grading %d/%d points", score, totalscore);
    *(unsigned char *)0x4000 = 0x0d;
    assert(pgfault_num==5);
    *(unsigned char *)0x5000 = 0x0e;
    assert(pgfault_num==5);
    assert(*(unsigned char *)0x1000 == 0x0a);
    *(unsigned char *)0x1000 = 0x0a;
    assert(pgfault_num==6);
    ++ score; cprintf("grading %d/%d points", score, totalscore);
#else 
    *(unsigned char *)0x3000 = 0x0c;
    assert(pgfault_num==4);
    *(unsigned char *)0x1000 = 0x0a;
    assert(pgfault_num==4);
    *(unsigned char *)0x4000 = 0x0d;
    assert(pgfault_num==4);
    *(unsigned char *)0x2000 = 0x0b;
    assert(pgfault_num==4);
    *(unsigned char *)0x5000 = 0x0e;
    assert(pgfault_num==5);
    *(unsigned char *)0x2000 = 0x0b;
    assert(pgfault_num==5);
    *(unsigned char *)0x1000 = 0x0a;
    assert(pgfault_num==5);
    *(unsigned char *)0x2000 = 0x0b;
    assert(pgfault_num==5);
    *(unsigned char *)0x3000 = 0x0c;
    assert(pgfault_num==5);
    *(unsigned char *)0x4000 = 0x0d;
    assert(pgfault_num==5);
    *(unsigned char *)0x5000 = 0x0e;
    assert(pgfault_num==5);
    assert(*(unsigned char *)0x1000 == 0x0a);
    *(unsigned char *)0x1000 = 0x0a;
    assert(pgfault_num==6);
#endif
return 0;
}


static int
_lru_init(void)
{
    return 0;
}

static int
_lru_set_unswappable(struct mm_struct *mm, uintptr_t addr)
{
    return 0;
}

static int
_lru_tick_event(struct mm_struct *mm)
{ return 0; }


struct swap_manager swap_manager_lru=
{
     .name            = "lru swap manager",
     .init            = &_lru_init,
     .init_mm         = &_lru_init_mm,
     .tick_event      = &_lru_tick_event,
     .map_swappable   = &_lru_map_swappable,
     .set_unswappable = &_lru_set_unswappable,
     .swap_out_victim = &_lru_swap_out_victim,
     .check_swap      = &_lru_check_swap,
};
