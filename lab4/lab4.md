### 操作系统lab4实验报告

***

#### 成员：涂佳欢语 王婷睿 胡可玉

***

#### 练习0：填写已有实验

本实验依赖实验2/3。需要将实验2/3的代码填入本实验中代码中有“LAB2”,“LAB3”的注释相应部分。

#### 练习1：分配并初始化一个进程控制块（需要编码）

在`proc.h`中，我们定义结构体`proc_struct`，用来管理进程信息。代码如下：

```c++
struct proc_struct {
    //uCore中进程状态有四种：分别是PROC_UNINIT、PROC_SLEEPING、PROC_RUNNABLE、PROC_ZOMBIE
    enum proc_state state;                      // 进程所处的状态。
    int pid;                                    // Process ID
    int runs;                                   // the running times of Proces
    uintptr_t kstack;                           // 记录了分配给该进程/线程的内核栈的位置
    volatile bool need_resched;                 // bool value: need to be rescheduled to release CPU?
    struct proc_struct *parent;                 // 进程的父进程的指针 在内核中，只有内核创建的idle进程没有父进程
    struct mm_struct *mm;                       //保存了内存管理的信息，包括内存映射，虚存管理等内容
    struct context context;                     // 保存了进程执行的上下文（几个关键的寄存器的值）进程切换中还原之前进程的运行状态
    struct trapframe *tf;                       // 保存了进程的中断帧。当进程从用户空间跳进内核空间的时候，进程的执行状态被保存在了中断帧中
    uintptr_t cr3;                              // x86架构的特殊寄存器，用来保存页表所在的基址
    uint32_t flags;                             // Process flag
    char name[PROC_NAME_LEN + 1];               // Process name
    list_entry_t list_link;                     // 链表节点 链接入进程控制块的双向线性列表
    list_entry_t hash_link;                     // 链表节点 基于pid链接入进程控制块的哈希表
};

```

**1.1、内核控制块的分配和初始化**

在`alloc_proc`函数中，我们将分配并返回一个新的`struct proc_struct`结构，用于存储新建立的内核线程的管理信息。

因此，在`alloc_proc`函数中，我们首先通过`kmalloc`函数获得`proc_struct`结构的一块内存块，并且对其进行初步初始化。简单的初始化即把`proc_struct`中的各个成员变量清零，但由于有些成员变量拥有特殊的含义，需要设置特殊值。下面我将逐步介绍：

- *enum proc_state state:* 表示进程所处的状态，在初始化时，我们将其初始化为`PROC_UNINIT`，意味着`uninitialized`。
- *uintptr_t cr3:* 用来保存页表所在的基址。由于内核线程在内核中运行，因此`cr3`设置为uCore内核页表的起始地址`boot_cr3`。
- *int pid:* 表示进程的ID，因此我们初始化为-1，表明进程的ID还未正式生成。
  
对于其他成员变量我们将初始化为`0`或者`NULL`。在这里还需要注意`struct context context`和`char name[PROC_NAME_LEN + 1]`。

- *struct context context:* 进程上下文。其中保存了14个被调用者保存寄存器，即`ra`，`sp`，`s0~s11`共14个寄存器。因此在初始化时，我们将寄存器的值均初始化为0，即`memset(&(proc->context),0,sizeof(struct context));`。
- *char name[PROC_NAME_LEN + 1]:* 进程的名字。我们将前`PROC_NAME_LEN`个字符初始化为0，保留最后一位为`/0`。
  
因此进程控制块的分配和初始化代码如下：

```c++
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));//通过kmalloc函数获得proc_struct结构的一块内存块
    if (proc != NULL) {
        proc->state=PROC_UNINIT;    //设置进程为“初始”态
        proc->pid=-1;               //设置进程pid的未初始化值
        proc->runs=0;
        proc->kstack=0;
        proc->need_resched=0;
        proc->parent=NULL;
        proc->mm=NULL;
        
        memset(&(proc->context),0,sizeof(struct context));//context结构体全部置为0
        proc->tf=NULL;
        
        proc->cr3=boot_cr3;     //使用内核页目录表的基址由于该内核线程在内核中运行，
                                // 故采用为uCore内核已经建立的页表，即uCore内核页表的起始地址boot_cr3
        proc->flags=0;
        memset(proc->name,0,PROC_NAME_LEN); //最后一个char存放'\0'
    }
    return proc;

```

**1.2、问题回答**

**1.2.1、struct context context:**

在ucore中，进程上下文使用结构体`struct context`保存，其中包含了`ra`，`sp`，`s0~s11`共14个寄存器。操作系统保存当前执行的进程或线程的上下文，以便将来恢复。

在`copy_thread`中：

- `proc->context.ra：`设置子进程的入口点，也就是从 `forkret` 函数开始执行。通过设置返回地址，确保当进程切换回来时，它会从 `forkret` 开始执行。
- `proc->context.sp：`设置栈指针为指向 `trapframe`，确保进程恢复执行时，从 `trapframe` 保存的状态继续执行。
  
在`switch_to`函数中，存在`context`中需要保存的寄存器进行保存和调换。

**1.2.2、struct trapframe \* tf:**

在ucore中，`trapframe` 主要用来保存进程在发生中断、系统调用、或上下文切换时的 `CPU` 状态。

在`kernel_thread`函数中，trapframe被用来设置内核线程的初始状态。

- 初始化函数指针和参数，准备内核线程的执行。
  - trapframe 中的寄存器：`tf.gpr.s0`被设置为内核线程函数的函数指针`fn`，这个函数指针会在线程启动时被调用。
  - `tf.gpr.s1`被设置为函数参数`arg`，它是传递给内核线程的参数。

- 配置状态寄存器，确保线程以内核模式启动，并禁用中断。
  - 状态寄存器`tf.status`保存进程的状态信息。表示进程运行在`Supervisor`模式，在陷阱返回时启用中断并且禁用中断，避免在内核线程执行时被中断。

- 设置程序计数器`epc`为内核线程的入口函数`kernel_thread_entry`，确保线程从正确的地方开始执行。


在`copy_thread`中，`trapframe`使子进程能够从正确的状态开始执行，且能够正确地从forkret函数恢复执行。

- 初始化子进程状态。在`fork`系统调用中，父进程的状态被复制到子进程的`trapframe`中，确保子进程继承父进程的执行上下文。
- 保存当前进程的状态
- 栈的初始化。通过设置栈指针为`trapframe`或提供的`esp`，操作系统确保进程从正确的位置恢复执行，栈空间也正确地初始化。

`context`通常与`trapframe`一起使用，以帮助操作系统管理和恢复进程状态。

#### 练习2：为新创建的内核线程分配资源（需要编码）

#### 练习3：编写proc_run 函数（需要编码）

proc_run用于将指定的进程切换到CPU上运行，它的大致执行步骤包括：

1.检查要切换的进程是否与当前正在运行的进程相同，如果相同则不需要切换。

2.禁用中断。

3.切换当前进程为要运行的进程；切换页表，以便使用新进程的地址空间；切换上下文。

4.允许中断。

根据它的执行步骤，填写代码如下：

```c++
void
proc_run(struct proc_struct *proc) {
    if (proc != current) {  // 如果待运行的进程不是当前进程
        bool intr_flag; // 保存是否启用中断
        struct proc_struct *prev = current, *next = proc;
        local_intr_save(intr_flag); // 禁用中断，确保操作的原子性
        {
            current = proc;
            lcr3(proc->cr3); // 切换页表，以便使用新进程的地址空间
            switch_to(&(prev->context), &(next->context)); // 实现上下文切换
        }
        local_intr_restore(intr_flag); // 启用中断
       
    }
}
```

对实现代码进行说明：

- `if (proc != current)` 检查目标进程 `proc` 是否与当前正在运行的进程（`current`）相同。如果相同，意味着当前进程已经在运行，不需要进行切换，所以可以直接返回。只有在目标进程与当前进程不同的情况下，才会执行接下来的操作。 `current` 表示当前正在执行的进程。

- `bool intr_flag;` 声明一个 `bool` 类型的变量 `intr_flag`，用于保存当前中断的状态，在禁用中断之前先将当前的中断状态保存下来，以便稍后恢复，由于只有开、关两种情况，所以使用`bool` 类型。

-  `struct proc_struct *prev = current, *next = proc;` 声明两个进程指针 `prev` 和 `next`，分别指向当前进程和目标进程。

- 调用 `local_intr_save(intr_flag)` 宏来禁用中断并保存当前中断状态，保证进程切换操作的原子性。

-  `current = proc;` 将当前进程切换为要运行的进程。

- 调用 `lcr3(proc->cr3)` 来切换页表，cr3寄存器是x86架构的特殊寄存器，用来保存页表所在的基址， `proc->cr3` 是目标进程的页表基地址。

-  `switch_to(&(prev->context), &(next->context));` 调用 `switch_to()` 函数，执行上下文切换， `prev->context` 和 `next->context` 分别是当前进程和要运行的进程的上下文。

- 调用 `local_intr_restore(intr_flag)` 恢复中断状态。

回答问题：在本实验的执行过程中，创建且运行了几个内核线程？

在本实验中创建并运行了两个内核线程：第0个线程idleproc和第1个线程initproc。

与本实验相关的部分运行结果截图：

![部分运行结果](lab4.png)

#### 扩展练习 Challenge

- 说明语句local_intr_save(intr_flag);....local_intr_restore(intr_flag);是如何实现开关中断的？

