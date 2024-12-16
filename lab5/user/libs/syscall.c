#include <defs.h>
#include <unistd.h>
#include <stdarg.h>
#include <syscall.h>

#define MAX_ARGS            5

//通过 ecall 指令触发一个系统调用
//使用了 变参函数 和 内联汇编 来传递参数并执行系统调用
static inline int
syscall(int64_t num, ...) {
    va_list ap;//ap: 参数列表(此时未初始化)  存储可变参数的处理状态
    va_start(ap, num);//初始化参数列表, 从num开始 从 num 参数开始读取后续的可变参数
    uint64_t a[MAX_ARGS];
    //存储传递给系统调用的参数。这些参数会依次被放入这个数组中，以便通过 ecall 指令传递给内核。
    int i, ret;// 存储返回值的变量ret
    for (i = 0; i < MAX_ARGS; i ++) {
        a[i] = va_arg(ap, uint64_t);
    }
    va_end(ap);

    asm volatile (//内联汇编
        "ld a0, %1\n"//系统调用号 num 加载到寄存器 a0
        "ld a1, %2\n"//第一个系统调用参数 a[0] 加载到寄存器 a1
        "ld a2, %3\n"
        "ld a3, %4\n"
        "ld a4, %5\n"
    	"ld a5, %6\n"
        "ecall\n"//触发系统调用（ecall 是 RISC-V 中用于触发从用户态到内核态的指令）
        "sd a0, %0"//将返回值（通常存储在 a0 寄存器中）存储到 ret 变量中
        : "=m" (ret)
        : "m"(num), "m"(a[0]), "m"(a[1]), "m"(a[2]), "m"(a[3]), "m"(a[4])
        :"memory");

        //num存到a0寄存器， a[0]存到a1寄存器
        //ecall的返回值存到ret
    return ret;

    //内核会将这些参数存入 current->tf->gpr，并根据这些参数调用相应的内核函数来处理系统调用。处理完成后，内核会将返回值存入 a0，并通过 ecall 返回用户程序。
}

int
sys_exit(int64_t error_code) {
    return syscall(SYS_exit, error_code);
}

int
sys_fork(void) {
    return syscall(SYS_fork);
}//调用 syscall(SYS_fork)，通过系统调用号 SYS_fork 创建一个子进程，返回新进程的 pid

int
sys_wait(int64_t pid, int *store) {
    return syscall(SYS_wait, pid, store);
}//等待指定进程（pid）结束，并将其退出状态保存在 store 中
//通过系统调用号 SYS_wait，传递进程 pid 和退出状态保存的地址 store，内核会阻塞当前进程直到指定进程退出

int
sys_yield(void) {
    return syscall(SYS_yield);
}//让出 CPU，允许其他进程执行

int
sys_kill(int64_t pid) {
    return syscall(SYS_kill, pid);
}//终止指定的进程（pid）

int
sys_getpid(void) {
    return syscall(SYS_getpid);
}//返回当前进程的进程 ID

int
sys_putc(int64_t c) {
    return syscall(SYS_putc, c);
}//输出字符 c 到控制台

int
sys_pgdir(void) {
    return syscall(SYS_pgdir);
}//获取当前进程的页表目录

