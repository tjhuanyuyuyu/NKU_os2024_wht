#include <unistd.h>
#include <proc.h>
#include <syscall.h>
#include <trap.h>
#include <stdio.h>
#include <pmm.h>
#include <assert.h>

//用户态的系统调用请求转发给相应的内核处理函数。

static int
sys_exit(uint64_t arg[]) {
    int error_code = (int)arg[0];
    return do_exit(error_code);
}

//sys_fork 获取当前进程的 trapframe（包含寄存器状态），然后将当前栈地址和 trapframe 传递给 do_fork() 进行进程创建
static int
sys_fork(uint64_t arg[]) {
    struct trapframe *tf = current->tf;
    uintptr_t stack = tf->gpr.sp;
    return do_fork(0, stack, tf);
}

static int
sys_wait(uint64_t arg[]) {
    int pid = (int)arg[0];
    int *store = (int *)arg[1];
    return do_wait(pid, store);
}


//arg[] 中提取程序名、程序长度、二进制文件和大小等参数，然后调用 do_execve() 来执行新的程序。
static int
sys_exec(uint64_t arg[]) {
    const char *name = (const char *)arg[0];
    size_t len = (size_t)arg[1];
    unsigned char *binary = (unsigned char *)arg[2];
    size_t size = (size_t)arg[3];
    return do_execve(name, len, binary, size);
}

//触发进程调度，放弃当前 CPU 的控制权，让其他进程有机会运行。
static int
sys_yield(uint64_t arg[]) {
    return do_yield();
}

static int
sys_kill(uint64_t arg[]) {
    int pid = (int)arg[0];
    return do_kill(pid);
}

static int
sys_getpid(uint64_t arg[]) {
    return current->pid;
}

//处理打印字符到控制台的系统调用。
//arg[0] 存储需要打印的字符，cputchar() 是实际的字符输出函数。
static int
sys_putc(uint64_t arg[]) {
    int c = (int)arg[0];
    cputchar(c);
    return 0;
}

static int
sys_pgdir(uint64_t arg[]) {
    //print_pgdir();
    return 0;
}

//该数组将系统调用编号（SYS_exit、SYS_fork 等）映射到相应的处理函数
static int (*syscalls[])(uint64_t arg[]) = {
    [SYS_exit]              sys_exit,
    [SYS_fork]              sys_fork,
    [SYS_wait]              sys_wait,
    [SYS_exec]              sys_exec,
    [SYS_yield]             sys_yield,
    [SYS_kill]              sys_kill,
    [SYS_getpid]            sys_getpid,
    [SYS_putc]              sys_putc,
    [SYS_pgdir]             sys_pgdir,
};
//系统调用的数量，它计算了 syscalls 数组的大小
#define NUM_SYSCALLS        ((sizeof(syscalls)) / (sizeof(syscalls[0])))


//在系统调用发生时，ecall 指令会触发一个从用户态到内核态的上下文切换。
//为了解决用户态和内核态之间的状态保存与恢复问题，操作系统会保存当前进程的寄存器状态（包括参数、返回值等）到 trapframe 结构体中的 gpr 字段
void
syscall(void) {
    struct trapframe *tf = current->tf;
    uint64_t arg[5];
    int num = tf->gpr.a0;// a0寄存器保存了系统调用编号  当前进程的寄存器状态
    if (num >= 0 && num < NUM_SYSCALLS) {
        if (syscalls[num] != NULL) {
            arg[0] = tf->gpr.a1;
            arg[1] = tf->gpr.a2;
            arg[2] = tf->gpr.a3;
            arg[3] = tf->gpr.a4;
            arg[4] = tf->gpr.a5;
            tf->gpr.a0 = syscalls[num](arg); // 调用相应的系统调用处理函数
            return ;
        }
    }
     // 如果执行到这里，说明传入的系统调用编号还没有被实现
    print_trapframe(tf);
    panic("undefined syscall %d, pid = %d, name = %s.\n",
            num, current->pid, current->name);
}

