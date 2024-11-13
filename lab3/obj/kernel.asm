
bin/kernel:     file format elf64-littleriscv


Disassembly of section .text:

ffffffffc0200000 <kern_entry>:

    .section .text,"ax",%progbits
    .globl kern_entry
kern_entry:
    # t0 := 三级页表的虚拟地址
    lui     t0, %hi(boot_page_table_sv39)
ffffffffc0200000:	c02092b7          	lui	t0,0xc0209
    # t1 := 0xffffffff40000000 即虚实映射偏移量
    li      t1, 0xffffffffc0000000 - 0x80000000
ffffffffc0200004:	ffd0031b          	addiw	t1,zero,-3
ffffffffc0200008:	037a                	slli	t1,t1,0x1e
    # t0 减去虚实映射偏移量 0xffffffff40000000，变为三级页表的物理地址
    sub     t0, t0, t1
ffffffffc020000a:	406282b3          	sub	t0,t0,t1
    # t0 >>= 12，变为三级页表的物理页号
    srli    t0, t0, 12
ffffffffc020000e:	00c2d293          	srli	t0,t0,0xc

    # t1 := 8 << 60，设置 satp 的 MODE 字段为 Sv39
    li      t1, 8 << 60
ffffffffc0200012:	fff0031b          	addiw	t1,zero,-1
ffffffffc0200016:	137e                	slli	t1,t1,0x3f
    # 将刚才计算出的预设三级页表物理页号附加到 satp 中
    or      t0, t0, t1
ffffffffc0200018:	0062e2b3          	or	t0,t0,t1
    # 将算出的 t0(即新的MODE|页表基址物理页号) 覆盖到 satp 中
    csrw    satp, t0
ffffffffc020001c:	18029073          	csrw	satp,t0
    # 使用 sfence.vma 指令刷新 TLB
    sfence.vma
ffffffffc0200020:	12000073          	sfence.vma
    # 从此，我们给内核搭建出了一个完美的虚拟内存空间！
    #nop # 可能映射的位置有些bug。。插入一个nop
    
    # 我们在虚拟内存空间中：随意将 sp 设置为虚拟地址！
    lui sp, %hi(bootstacktop)
ffffffffc0200024:	c0209137          	lui	sp,0xc0209

    # 我们在虚拟内存空间中：随意跳转到虚拟地址！
    # 跳转到 kern_init
    lui t0, %hi(kern_init)
ffffffffc0200028:	c02002b7          	lui	t0,0xc0200
    addi t0, t0, %lo(kern_init)
ffffffffc020002c:	03228293          	addi	t0,t0,50 # ffffffffc0200032 <kern_init>
    jr t0
ffffffffc0200030:	8282                	jr	t0

ffffffffc0200032 <kern_init>:


int
kern_init(void) {
    extern char edata[], end[];
    memset(edata, 0, end - edata);
ffffffffc0200032:	0000a517          	auipc	a0,0xa
ffffffffc0200036:	00e50513          	addi	a0,a0,14 # ffffffffc020a040 <ide>
ffffffffc020003a:	00011617          	auipc	a2,0x11
ffffffffc020003e:	53a60613          	addi	a2,a2,1338 # ffffffffc0211574 <end>
kern_init(void) {
ffffffffc0200042:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
ffffffffc0200044:	8e09                	sub	a2,a2,a0
ffffffffc0200046:	4581                	li	a1,0
kern_init(void) {
ffffffffc0200048:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
ffffffffc020004a:	402040ef          	jal	ra,ffffffffc020444c <memset>

    const char *message = "(THU.CST) os is loading ...";
    cprintf("%s\n\n", message);
ffffffffc020004e:	00004597          	auipc	a1,0x4
ffffffffc0200052:	42a58593          	addi	a1,a1,1066 # ffffffffc0204478 <etext+0x2>
ffffffffc0200056:	00004517          	auipc	a0,0x4
ffffffffc020005a:	44250513          	addi	a0,a0,1090 # ffffffffc0204498 <etext+0x22>
ffffffffc020005e:	05c000ef          	jal	ra,ffffffffc02000ba <cprintf>

    print_kerninfo();
ffffffffc0200062:	0a0000ef          	jal	ra,ffffffffc0200102 <print_kerninfo>

    // grade_backtrace();

    pmm_init();                 // init physical memory management
ffffffffc0200066:	2b1010ef          	jal	ra,ffffffffc0201b16 <pmm_init>

    idt_init();                 // init interrupt descriptor table
ffffffffc020006a:	4fa000ef          	jal	ra,ffffffffc0200564 <idt_init>

    vmm_init();                 // init virtual memory management
ffffffffc020006e:	686030ef          	jal	ra,ffffffffc02036f4 <vmm_init>

    ide_init();                 // init ide devices
ffffffffc0200072:	420000ef          	jal	ra,ffffffffc0200492 <ide_init>
    swap_init();                // init swap
ffffffffc0200076:	105020ef          	jal	ra,ffffffffc020297a <swap_init>

    clock_init();               // init clock interrupt
ffffffffc020007a:	356000ef          	jal	ra,ffffffffc02003d0 <clock_init>
    // intr_enable();              // enable irq interrupt



    /* do nothing */
    while (1);
ffffffffc020007e:	a001                	j	ffffffffc020007e <kern_init+0x4c>

ffffffffc0200080 <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
ffffffffc0200080:	1141                	addi	sp,sp,-16
ffffffffc0200082:	e022                	sd	s0,0(sp)
ffffffffc0200084:	e406                	sd	ra,8(sp)
ffffffffc0200086:	842e                	mv	s0,a1
    cons_putc(c);
ffffffffc0200088:	39a000ef          	jal	ra,ffffffffc0200422 <cons_putc>
    (*cnt) ++;
ffffffffc020008c:	401c                	lw	a5,0(s0)
}
ffffffffc020008e:	60a2                	ld	ra,8(sp)
    (*cnt) ++;
ffffffffc0200090:	2785                	addiw	a5,a5,1
ffffffffc0200092:	c01c                	sw	a5,0(s0)
}
ffffffffc0200094:	6402                	ld	s0,0(sp)
ffffffffc0200096:	0141                	addi	sp,sp,16
ffffffffc0200098:	8082                	ret

ffffffffc020009a <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
ffffffffc020009a:	1101                	addi	sp,sp,-32
ffffffffc020009c:	862a                	mv	a2,a0
ffffffffc020009e:	86ae                	mv	a3,a1
    int cnt = 0;
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000a0:	00000517          	auipc	a0,0x0
ffffffffc02000a4:	fe050513          	addi	a0,a0,-32 # ffffffffc0200080 <cputch>
ffffffffc02000a8:	006c                	addi	a1,sp,12
vcprintf(const char *fmt, va_list ap) {
ffffffffc02000aa:	ec06                	sd	ra,24(sp)
    int cnt = 0;
ffffffffc02000ac:	c602                	sw	zero,12(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000ae:	6ed030ef          	jal	ra,ffffffffc0203f9a <vprintfmt>
    return cnt;
}
ffffffffc02000b2:	60e2                	ld	ra,24(sp)
ffffffffc02000b4:	4532                	lw	a0,12(sp)
ffffffffc02000b6:	6105                	addi	sp,sp,32
ffffffffc02000b8:	8082                	ret

ffffffffc02000ba <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
ffffffffc02000ba:	711d                	addi	sp,sp,-96
    va_list ap;
    int cnt;
    va_start(ap, fmt);
ffffffffc02000bc:	02810313          	addi	t1,sp,40 # ffffffffc0209028 <boot_page_table_sv39+0x28>
cprintf(const char *fmt, ...) {
ffffffffc02000c0:	8e2a                	mv	t3,a0
ffffffffc02000c2:	f42e                	sd	a1,40(sp)
ffffffffc02000c4:	f832                	sd	a2,48(sp)
ffffffffc02000c6:	fc36                	sd	a3,56(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000c8:	00000517          	auipc	a0,0x0
ffffffffc02000cc:	fb850513          	addi	a0,a0,-72 # ffffffffc0200080 <cputch>
ffffffffc02000d0:	004c                	addi	a1,sp,4
ffffffffc02000d2:	869a                	mv	a3,t1
ffffffffc02000d4:	8672                	mv	a2,t3
cprintf(const char *fmt, ...) {
ffffffffc02000d6:	ec06                	sd	ra,24(sp)
ffffffffc02000d8:	e0ba                	sd	a4,64(sp)
ffffffffc02000da:	e4be                	sd	a5,72(sp)
ffffffffc02000dc:	e8c2                	sd	a6,80(sp)
ffffffffc02000de:	ecc6                	sd	a7,88(sp)
    va_start(ap, fmt);
ffffffffc02000e0:	e41a                	sd	t1,8(sp)
    int cnt = 0;
ffffffffc02000e2:	c202                	sw	zero,4(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000e4:	6b7030ef          	jal	ra,ffffffffc0203f9a <vprintfmt>
    cnt = vcprintf(fmt, ap);
    va_end(ap);
    return cnt;
}
ffffffffc02000e8:	60e2                	ld	ra,24(sp)
ffffffffc02000ea:	4512                	lw	a0,4(sp)
ffffffffc02000ec:	6125                	addi	sp,sp,96
ffffffffc02000ee:	8082                	ret

ffffffffc02000f0 <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
    cons_putc(c);
ffffffffc02000f0:	ae0d                	j	ffffffffc0200422 <cons_putc>

ffffffffc02000f2 <getchar>:
    return cnt;
}

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
ffffffffc02000f2:	1141                	addi	sp,sp,-16
ffffffffc02000f4:	e406                	sd	ra,8(sp)
    int c;
    while ((c = cons_getc()) == 0)
ffffffffc02000f6:	360000ef          	jal	ra,ffffffffc0200456 <cons_getc>
ffffffffc02000fa:	dd75                	beqz	a0,ffffffffc02000f6 <getchar+0x4>
        /* do nothing */;
    return c;
}
ffffffffc02000fc:	60a2                	ld	ra,8(sp)
ffffffffc02000fe:	0141                	addi	sp,sp,16
ffffffffc0200100:	8082                	ret

ffffffffc0200102 <print_kerninfo>:
/* *
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void print_kerninfo(void) {
ffffffffc0200102:	1141                	addi	sp,sp,-16
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
ffffffffc0200104:	00004517          	auipc	a0,0x4
ffffffffc0200108:	39c50513          	addi	a0,a0,924 # ffffffffc02044a0 <etext+0x2a>
void print_kerninfo(void) {
ffffffffc020010c:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc020010e:	fadff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  entry  0x%08x (virtual)\n", kern_init);
ffffffffc0200112:	00000597          	auipc	a1,0x0
ffffffffc0200116:	f2058593          	addi	a1,a1,-224 # ffffffffc0200032 <kern_init>
ffffffffc020011a:	00004517          	auipc	a0,0x4
ffffffffc020011e:	3a650513          	addi	a0,a0,934 # ffffffffc02044c0 <etext+0x4a>
ffffffffc0200122:	f99ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  etext  0x%08x (virtual)\n", etext);
ffffffffc0200126:	00004597          	auipc	a1,0x4
ffffffffc020012a:	35058593          	addi	a1,a1,848 # ffffffffc0204476 <etext>
ffffffffc020012e:	00004517          	auipc	a0,0x4
ffffffffc0200132:	3b250513          	addi	a0,a0,946 # ffffffffc02044e0 <etext+0x6a>
ffffffffc0200136:	f85ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  edata  0x%08x (virtual)\n", edata);
ffffffffc020013a:	0000a597          	auipc	a1,0xa
ffffffffc020013e:	f0658593          	addi	a1,a1,-250 # ffffffffc020a040 <ide>
ffffffffc0200142:	00004517          	auipc	a0,0x4
ffffffffc0200146:	3be50513          	addi	a0,a0,958 # ffffffffc0204500 <etext+0x8a>
ffffffffc020014a:	f71ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  end    0x%08x (virtual)\n", end);
ffffffffc020014e:	00011597          	auipc	a1,0x11
ffffffffc0200152:	42658593          	addi	a1,a1,1062 # ffffffffc0211574 <end>
ffffffffc0200156:	00004517          	auipc	a0,0x4
ffffffffc020015a:	3ca50513          	addi	a0,a0,970 # ffffffffc0204520 <etext+0xaa>
ffffffffc020015e:	f5dff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
ffffffffc0200162:	00012597          	auipc	a1,0x12
ffffffffc0200166:	81158593          	addi	a1,a1,-2031 # ffffffffc0211973 <end+0x3ff>
ffffffffc020016a:	00000797          	auipc	a5,0x0
ffffffffc020016e:	ec878793          	addi	a5,a5,-312 # ffffffffc0200032 <kern_init>
ffffffffc0200172:	40f587b3          	sub	a5,a1,a5
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc0200176:	43f7d593          	srai	a1,a5,0x3f
}
ffffffffc020017a:	60a2                	ld	ra,8(sp)
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc020017c:	3ff5f593          	andi	a1,a1,1023
ffffffffc0200180:	95be                	add	a1,a1,a5
ffffffffc0200182:	85a9                	srai	a1,a1,0xa
ffffffffc0200184:	00004517          	auipc	a0,0x4
ffffffffc0200188:	3bc50513          	addi	a0,a0,956 # ffffffffc0204540 <etext+0xca>
}
ffffffffc020018c:	0141                	addi	sp,sp,16
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc020018e:	b735                	j	ffffffffc02000ba <cprintf>

ffffffffc0200190 <print_stackframe>:
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before
 * jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the
 * boundary.
 * */
void print_stackframe(void) {
ffffffffc0200190:	1141                	addi	sp,sp,-16

    panic("Not Implemented!");
ffffffffc0200192:	00004617          	auipc	a2,0x4
ffffffffc0200196:	3de60613          	addi	a2,a2,990 # ffffffffc0204570 <etext+0xfa>
ffffffffc020019a:	04e00593          	li	a1,78
ffffffffc020019e:	00004517          	auipc	a0,0x4
ffffffffc02001a2:	3ea50513          	addi	a0,a0,1002 # ffffffffc0204588 <etext+0x112>
void print_stackframe(void) {
ffffffffc02001a6:	e406                	sd	ra,8(sp)
    panic("Not Implemented!");
ffffffffc02001a8:	1cc000ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc02001ac <mon_help>:
    }
}

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc02001ac:	1141                	addi	sp,sp,-16
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc02001ae:	00004617          	auipc	a2,0x4
ffffffffc02001b2:	3f260613          	addi	a2,a2,1010 # ffffffffc02045a0 <etext+0x12a>
ffffffffc02001b6:	00004597          	auipc	a1,0x4
ffffffffc02001ba:	40a58593          	addi	a1,a1,1034 # ffffffffc02045c0 <etext+0x14a>
ffffffffc02001be:	00004517          	auipc	a0,0x4
ffffffffc02001c2:	40a50513          	addi	a0,a0,1034 # ffffffffc02045c8 <etext+0x152>
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc02001c6:	e406                	sd	ra,8(sp)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc02001c8:	ef3ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc02001cc:	00004617          	auipc	a2,0x4
ffffffffc02001d0:	40c60613          	addi	a2,a2,1036 # ffffffffc02045d8 <etext+0x162>
ffffffffc02001d4:	00004597          	auipc	a1,0x4
ffffffffc02001d8:	42c58593          	addi	a1,a1,1068 # ffffffffc0204600 <etext+0x18a>
ffffffffc02001dc:	00004517          	auipc	a0,0x4
ffffffffc02001e0:	3ec50513          	addi	a0,a0,1004 # ffffffffc02045c8 <etext+0x152>
ffffffffc02001e4:	ed7ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc02001e8:	00004617          	auipc	a2,0x4
ffffffffc02001ec:	42860613          	addi	a2,a2,1064 # ffffffffc0204610 <etext+0x19a>
ffffffffc02001f0:	00004597          	auipc	a1,0x4
ffffffffc02001f4:	44058593          	addi	a1,a1,1088 # ffffffffc0204630 <etext+0x1ba>
ffffffffc02001f8:	00004517          	auipc	a0,0x4
ffffffffc02001fc:	3d050513          	addi	a0,a0,976 # ffffffffc02045c8 <etext+0x152>
ffffffffc0200200:	ebbff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    }
    return 0;
}
ffffffffc0200204:	60a2                	ld	ra,8(sp)
ffffffffc0200206:	4501                	li	a0,0
ffffffffc0200208:	0141                	addi	sp,sp,16
ffffffffc020020a:	8082                	ret

ffffffffc020020c <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
ffffffffc020020c:	1141                	addi	sp,sp,-16
ffffffffc020020e:	e406                	sd	ra,8(sp)
    print_kerninfo();
ffffffffc0200210:	ef3ff0ef          	jal	ra,ffffffffc0200102 <print_kerninfo>
    return 0;
}
ffffffffc0200214:	60a2                	ld	ra,8(sp)
ffffffffc0200216:	4501                	li	a0,0
ffffffffc0200218:	0141                	addi	sp,sp,16
ffffffffc020021a:	8082                	ret

ffffffffc020021c <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
ffffffffc020021c:	1141                	addi	sp,sp,-16
ffffffffc020021e:	e406                	sd	ra,8(sp)
    print_stackframe();
ffffffffc0200220:	f71ff0ef          	jal	ra,ffffffffc0200190 <print_stackframe>
    return 0;
}
ffffffffc0200224:	60a2                	ld	ra,8(sp)
ffffffffc0200226:	4501                	li	a0,0
ffffffffc0200228:	0141                	addi	sp,sp,16
ffffffffc020022a:	8082                	ret

ffffffffc020022c <kmonitor>:
kmonitor(struct trapframe *tf) {
ffffffffc020022c:	7115                	addi	sp,sp,-224
ffffffffc020022e:	ed5e                	sd	s7,152(sp)
ffffffffc0200230:	8baa                	mv	s7,a0
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc0200232:	00004517          	auipc	a0,0x4
ffffffffc0200236:	40e50513          	addi	a0,a0,1038 # ffffffffc0204640 <etext+0x1ca>
kmonitor(struct trapframe *tf) {
ffffffffc020023a:	ed86                	sd	ra,216(sp)
ffffffffc020023c:	e9a2                	sd	s0,208(sp)
ffffffffc020023e:	e5a6                	sd	s1,200(sp)
ffffffffc0200240:	e1ca                	sd	s2,192(sp)
ffffffffc0200242:	fd4e                	sd	s3,184(sp)
ffffffffc0200244:	f952                	sd	s4,176(sp)
ffffffffc0200246:	f556                	sd	s5,168(sp)
ffffffffc0200248:	f15a                	sd	s6,160(sp)
ffffffffc020024a:	e962                	sd	s8,144(sp)
ffffffffc020024c:	e566                	sd	s9,136(sp)
ffffffffc020024e:	e16a                	sd	s10,128(sp)
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc0200250:	e6bff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
ffffffffc0200254:	00004517          	auipc	a0,0x4
ffffffffc0200258:	41450513          	addi	a0,a0,1044 # ffffffffc0204668 <etext+0x1f2>
ffffffffc020025c:	e5fff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    if (tf != NULL) {
ffffffffc0200260:	000b8563          	beqz	s7,ffffffffc020026a <kmonitor+0x3e>
        print_trapframe(tf);
ffffffffc0200264:	855e                	mv	a0,s7
ffffffffc0200266:	4e8000ef          	jal	ra,ffffffffc020074e <print_trapframe>
ffffffffc020026a:	00004c17          	auipc	s8,0x4
ffffffffc020026e:	466c0c13          	addi	s8,s8,1126 # ffffffffc02046d0 <commands>
        if ((buf = readline("")) != NULL) {
ffffffffc0200272:	00006917          	auipc	s2,0x6
ffffffffc0200276:	8be90913          	addi	s2,s2,-1858 # ffffffffc0205b30 <default_pmm_manager+0x928>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc020027a:	00004497          	auipc	s1,0x4
ffffffffc020027e:	41648493          	addi	s1,s1,1046 # ffffffffc0204690 <etext+0x21a>
        if (argc == MAXARGS - 1) {
ffffffffc0200282:	49bd                	li	s3,15
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc0200284:	00004b17          	auipc	s6,0x4
ffffffffc0200288:	414b0b13          	addi	s6,s6,1044 # ffffffffc0204698 <etext+0x222>
        argv[argc ++] = buf;
ffffffffc020028c:	00004a17          	auipc	s4,0x4
ffffffffc0200290:	334a0a13          	addi	s4,s4,820 # ffffffffc02045c0 <etext+0x14a>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200294:	4a8d                	li	s5,3
        if ((buf = readline("")) != NULL) {
ffffffffc0200296:	854a                	mv	a0,s2
ffffffffc0200298:	084040ef          	jal	ra,ffffffffc020431c <readline>
ffffffffc020029c:	842a                	mv	s0,a0
ffffffffc020029e:	dd65                	beqz	a0,ffffffffc0200296 <kmonitor+0x6a>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002a0:	00054583          	lbu	a1,0(a0)
    int argc = 0;
ffffffffc02002a4:	4c81                	li	s9,0
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002a6:	e1bd                	bnez	a1,ffffffffc020030c <kmonitor+0xe0>
    if (argc == 0) {
ffffffffc02002a8:	fe0c87e3          	beqz	s9,ffffffffc0200296 <kmonitor+0x6a>
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02002ac:	6582                	ld	a1,0(sp)
ffffffffc02002ae:	00004d17          	auipc	s10,0x4
ffffffffc02002b2:	422d0d13          	addi	s10,s10,1058 # ffffffffc02046d0 <commands>
        argv[argc ++] = buf;
ffffffffc02002b6:	8552                	mv	a0,s4
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02002b8:	4401                	li	s0,0
ffffffffc02002ba:	0d61                	addi	s10,s10,24
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02002bc:	15c040ef          	jal	ra,ffffffffc0204418 <strcmp>
ffffffffc02002c0:	c919                	beqz	a0,ffffffffc02002d6 <kmonitor+0xaa>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02002c2:	2405                	addiw	s0,s0,1
ffffffffc02002c4:	0b540063          	beq	s0,s5,ffffffffc0200364 <kmonitor+0x138>
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02002c8:	000d3503          	ld	a0,0(s10)
ffffffffc02002cc:	6582                	ld	a1,0(sp)
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02002ce:	0d61                	addi	s10,s10,24
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02002d0:	148040ef          	jal	ra,ffffffffc0204418 <strcmp>
ffffffffc02002d4:	f57d                	bnez	a0,ffffffffc02002c2 <kmonitor+0x96>
            return commands[i].func(argc - 1, argv + 1, tf);
ffffffffc02002d6:	00141793          	slli	a5,s0,0x1
ffffffffc02002da:	97a2                	add	a5,a5,s0
ffffffffc02002dc:	078e                	slli	a5,a5,0x3
ffffffffc02002de:	97e2                	add	a5,a5,s8
ffffffffc02002e0:	6b9c                	ld	a5,16(a5)
ffffffffc02002e2:	865e                	mv	a2,s7
ffffffffc02002e4:	002c                	addi	a1,sp,8
ffffffffc02002e6:	fffc851b          	addiw	a0,s9,-1
ffffffffc02002ea:	9782                	jalr	a5
            if (runcmd(buf, tf) < 0) {
ffffffffc02002ec:	fa0555e3          	bgez	a0,ffffffffc0200296 <kmonitor+0x6a>
}
ffffffffc02002f0:	60ee                	ld	ra,216(sp)
ffffffffc02002f2:	644e                	ld	s0,208(sp)
ffffffffc02002f4:	64ae                	ld	s1,200(sp)
ffffffffc02002f6:	690e                	ld	s2,192(sp)
ffffffffc02002f8:	79ea                	ld	s3,184(sp)
ffffffffc02002fa:	7a4a                	ld	s4,176(sp)
ffffffffc02002fc:	7aaa                	ld	s5,168(sp)
ffffffffc02002fe:	7b0a                	ld	s6,160(sp)
ffffffffc0200300:	6bea                	ld	s7,152(sp)
ffffffffc0200302:	6c4a                	ld	s8,144(sp)
ffffffffc0200304:	6caa                	ld	s9,136(sp)
ffffffffc0200306:	6d0a                	ld	s10,128(sp)
ffffffffc0200308:	612d                	addi	sp,sp,224
ffffffffc020030a:	8082                	ret
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc020030c:	8526                	mv	a0,s1
ffffffffc020030e:	128040ef          	jal	ra,ffffffffc0204436 <strchr>
ffffffffc0200312:	c901                	beqz	a0,ffffffffc0200322 <kmonitor+0xf6>
ffffffffc0200314:	00144583          	lbu	a1,1(s0)
            *buf ++ = '\0';
ffffffffc0200318:	00040023          	sb	zero,0(s0)
ffffffffc020031c:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc020031e:	d5c9                	beqz	a1,ffffffffc02002a8 <kmonitor+0x7c>
ffffffffc0200320:	b7f5                	j	ffffffffc020030c <kmonitor+0xe0>
        if (*buf == '\0') {
ffffffffc0200322:	00044783          	lbu	a5,0(s0)
ffffffffc0200326:	d3c9                	beqz	a5,ffffffffc02002a8 <kmonitor+0x7c>
        if (argc == MAXARGS - 1) {
ffffffffc0200328:	033c8963          	beq	s9,s3,ffffffffc020035a <kmonitor+0x12e>
        argv[argc ++] = buf;
ffffffffc020032c:	003c9793          	slli	a5,s9,0x3
ffffffffc0200330:	0118                	addi	a4,sp,128
ffffffffc0200332:	97ba                	add	a5,a5,a4
ffffffffc0200334:	f887b023          	sd	s0,-128(a5)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200338:	00044583          	lbu	a1,0(s0)
        argv[argc ++] = buf;
ffffffffc020033c:	2c85                	addiw	s9,s9,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc020033e:	e591                	bnez	a1,ffffffffc020034a <kmonitor+0x11e>
ffffffffc0200340:	b7b5                	j	ffffffffc02002ac <kmonitor+0x80>
ffffffffc0200342:	00144583          	lbu	a1,1(s0)
            buf ++;
ffffffffc0200346:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200348:	d1a5                	beqz	a1,ffffffffc02002a8 <kmonitor+0x7c>
ffffffffc020034a:	8526                	mv	a0,s1
ffffffffc020034c:	0ea040ef          	jal	ra,ffffffffc0204436 <strchr>
ffffffffc0200350:	d96d                	beqz	a0,ffffffffc0200342 <kmonitor+0x116>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200352:	00044583          	lbu	a1,0(s0)
ffffffffc0200356:	d9a9                	beqz	a1,ffffffffc02002a8 <kmonitor+0x7c>
ffffffffc0200358:	bf55                	j	ffffffffc020030c <kmonitor+0xe0>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc020035a:	45c1                	li	a1,16
ffffffffc020035c:	855a                	mv	a0,s6
ffffffffc020035e:	d5dff0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc0200362:	b7e9                	j	ffffffffc020032c <kmonitor+0x100>
    cprintf("Unknown command '%s'\n", argv[0]);
ffffffffc0200364:	6582                	ld	a1,0(sp)
ffffffffc0200366:	00004517          	auipc	a0,0x4
ffffffffc020036a:	35250513          	addi	a0,a0,850 # ffffffffc02046b8 <etext+0x242>
ffffffffc020036e:	d4dff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    return 0;
ffffffffc0200372:	b715                	j	ffffffffc0200296 <kmonitor+0x6a>

ffffffffc0200374 <__panic>:
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
    if (is_panic) {
ffffffffc0200374:	00011317          	auipc	t1,0x11
ffffffffc0200378:	18430313          	addi	t1,t1,388 # ffffffffc02114f8 <is_panic>
ffffffffc020037c:	00032e03          	lw	t3,0(t1)
__panic(const char *file, int line, const char *fmt, ...) {
ffffffffc0200380:	715d                	addi	sp,sp,-80
ffffffffc0200382:	ec06                	sd	ra,24(sp)
ffffffffc0200384:	e822                	sd	s0,16(sp)
ffffffffc0200386:	f436                	sd	a3,40(sp)
ffffffffc0200388:	f83a                	sd	a4,48(sp)
ffffffffc020038a:	fc3e                	sd	a5,56(sp)
ffffffffc020038c:	e0c2                	sd	a6,64(sp)
ffffffffc020038e:	e4c6                	sd	a7,72(sp)
    if (is_panic) {
ffffffffc0200390:	020e1a63          	bnez	t3,ffffffffc02003c4 <__panic+0x50>
        goto panic_dead;
    }
    is_panic = 1;
ffffffffc0200394:	4785                	li	a5,1
ffffffffc0200396:	00f32023          	sw	a5,0(t1)

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
ffffffffc020039a:	8432                	mv	s0,a2
ffffffffc020039c:	103c                	addi	a5,sp,40
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc020039e:	862e                	mv	a2,a1
ffffffffc02003a0:	85aa                	mv	a1,a0
ffffffffc02003a2:	00004517          	auipc	a0,0x4
ffffffffc02003a6:	37650513          	addi	a0,a0,886 # ffffffffc0204718 <commands+0x48>
    va_start(ap, fmt);
ffffffffc02003aa:	e43e                	sd	a5,8(sp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02003ac:	d0fff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    vcprintf(fmt, ap);
ffffffffc02003b0:	65a2                	ld	a1,8(sp)
ffffffffc02003b2:	8522                	mv	a0,s0
ffffffffc02003b4:	ce7ff0ef          	jal	ra,ffffffffc020009a <vcprintf>
    cprintf("\n");
ffffffffc02003b8:	00005517          	auipc	a0,0x5
ffffffffc02003bc:	2c850513          	addi	a0,a0,712 # ffffffffc0205680 <default_pmm_manager+0x478>
ffffffffc02003c0:	cfbff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    va_end(ap);

panic_dead:
    intr_disable();
ffffffffc02003c4:	12a000ef          	jal	ra,ffffffffc02004ee <intr_disable>
    while (1) {
        kmonitor(NULL);
ffffffffc02003c8:	4501                	li	a0,0
ffffffffc02003ca:	e63ff0ef          	jal	ra,ffffffffc020022c <kmonitor>
    while (1) {
ffffffffc02003ce:	bfed                	j	ffffffffc02003c8 <__panic+0x54>

ffffffffc02003d0 <clock_init>:
 * and then enable IRQ_TIMER.
 * */
void clock_init(void) {
    // divided by 500 when using Spike(2MHz)
    // divided by 100 when using QEMU(10MHz)
    timebase = 1e7 / 100;
ffffffffc02003d0:	67e1                	lui	a5,0x18
ffffffffc02003d2:	6a078793          	addi	a5,a5,1696 # 186a0 <kern_entry-0xffffffffc01e7960>
ffffffffc02003d6:	00011717          	auipc	a4,0x11
ffffffffc02003da:	12f73923          	sd	a5,306(a4) # ffffffffc0211508 <timebase>
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc02003de:	c0102573          	rdtime	a0
static inline void sbi_set_timer(uint64_t stime_value)
{
#if __riscv_xlen == 32
	SBI_CALL_2(SBI_SET_TIMER, stime_value, stime_value >> 32);
#else
	SBI_CALL_1(SBI_SET_TIMER, stime_value);
ffffffffc02003e2:	4581                	li	a1,0
    ticks = 0;

    cprintf("++ setup timer interrupts\n");
}

void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc02003e4:	953e                	add	a0,a0,a5
ffffffffc02003e6:	4601                	li	a2,0
ffffffffc02003e8:	4881                	li	a7,0
ffffffffc02003ea:	00000073          	ecall
    set_csr(sie, MIP_STIP);
ffffffffc02003ee:	02000793          	li	a5,32
ffffffffc02003f2:	1047a7f3          	csrrs	a5,sie,a5
    cprintf("++ setup timer interrupts\n");
ffffffffc02003f6:	00004517          	auipc	a0,0x4
ffffffffc02003fa:	34250513          	addi	a0,a0,834 # ffffffffc0204738 <commands+0x68>
    ticks = 0;
ffffffffc02003fe:	00011797          	auipc	a5,0x11
ffffffffc0200402:	1007b123          	sd	zero,258(a5) # ffffffffc0211500 <ticks>
    cprintf("++ setup timer interrupts\n");
ffffffffc0200406:	b955                	j	ffffffffc02000ba <cprintf>

ffffffffc0200408 <clock_set_next_event>:
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc0200408:	c0102573          	rdtime	a0
void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc020040c:	00011797          	auipc	a5,0x11
ffffffffc0200410:	0fc7b783          	ld	a5,252(a5) # ffffffffc0211508 <timebase>
ffffffffc0200414:	953e                	add	a0,a0,a5
ffffffffc0200416:	4581                	li	a1,0
ffffffffc0200418:	4601                	li	a2,0
ffffffffc020041a:	4881                	li	a7,0
ffffffffc020041c:	00000073          	ecall
ffffffffc0200420:	8082                	ret

ffffffffc0200422 <cons_putc>:
#include <intr.h>
#include <mmu.h>
#include <riscv.h>

static inline bool __intr_save(void) {
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0200422:	100027f3          	csrr	a5,sstatus
ffffffffc0200426:	8b89                	andi	a5,a5,2
	SBI_CALL_1(SBI_CONSOLE_PUTCHAR, ch);
ffffffffc0200428:	0ff57513          	zext.b	a0,a0
ffffffffc020042c:	e799                	bnez	a5,ffffffffc020043a <cons_putc+0x18>
ffffffffc020042e:	4581                	li	a1,0
ffffffffc0200430:	4601                	li	a2,0
ffffffffc0200432:	4885                	li	a7,1
ffffffffc0200434:	00000073          	ecall
    }
    return 0;
}

static inline void __intr_restore(bool flag) {
    if (flag) {
ffffffffc0200438:	8082                	ret

/* cons_init - initializes the console devices */
void cons_init(void) {}

/* cons_putc - print a single character @c to console devices */
void cons_putc(int c) {
ffffffffc020043a:	1101                	addi	sp,sp,-32
ffffffffc020043c:	ec06                	sd	ra,24(sp)
ffffffffc020043e:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0200440:	0ae000ef          	jal	ra,ffffffffc02004ee <intr_disable>
ffffffffc0200444:	6522                	ld	a0,8(sp)
ffffffffc0200446:	4581                	li	a1,0
ffffffffc0200448:	4601                	li	a2,0
ffffffffc020044a:	4885                	li	a7,1
ffffffffc020044c:	00000073          	ecall
    local_intr_save(intr_flag);
    {
        sbi_console_putchar((unsigned char)c);
    }
    local_intr_restore(intr_flag);
}
ffffffffc0200450:	60e2                	ld	ra,24(sp)
ffffffffc0200452:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0200454:	a851                	j	ffffffffc02004e8 <intr_enable>

ffffffffc0200456 <cons_getc>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0200456:	100027f3          	csrr	a5,sstatus
ffffffffc020045a:	8b89                	andi	a5,a5,2
ffffffffc020045c:	eb89                	bnez	a5,ffffffffc020046e <cons_getc+0x18>
	return SBI_CALL_0(SBI_CONSOLE_GETCHAR);
ffffffffc020045e:	4501                	li	a0,0
ffffffffc0200460:	4581                	li	a1,0
ffffffffc0200462:	4601                	li	a2,0
ffffffffc0200464:	4889                	li	a7,2
ffffffffc0200466:	00000073          	ecall
ffffffffc020046a:	2501                	sext.w	a0,a0
    {
        c = sbi_console_getchar();
    }
    local_intr_restore(intr_flag);
    return c;
}
ffffffffc020046c:	8082                	ret
int cons_getc(void) {
ffffffffc020046e:	1101                	addi	sp,sp,-32
ffffffffc0200470:	ec06                	sd	ra,24(sp)
        intr_disable();
ffffffffc0200472:	07c000ef          	jal	ra,ffffffffc02004ee <intr_disable>
ffffffffc0200476:	4501                	li	a0,0
ffffffffc0200478:	4581                	li	a1,0
ffffffffc020047a:	4601                	li	a2,0
ffffffffc020047c:	4889                	li	a7,2
ffffffffc020047e:	00000073          	ecall
ffffffffc0200482:	2501                	sext.w	a0,a0
ffffffffc0200484:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc0200486:	062000ef          	jal	ra,ffffffffc02004e8 <intr_enable>
}
ffffffffc020048a:	60e2                	ld	ra,24(sp)
ffffffffc020048c:	6522                	ld	a0,8(sp)
ffffffffc020048e:	6105                	addi	sp,sp,32
ffffffffc0200490:	8082                	ret

ffffffffc0200492 <ide_init>:
#include <stdio.h>
#include <string.h>
#include <trap.h>
#include <riscv.h>

void ide_init(void) {}
ffffffffc0200492:	8082                	ret

ffffffffc0200494 <ide_device_valid>:

#define MAX_IDE 2
#define MAX_DISK_NSECS 56
static char ide[MAX_DISK_NSECS * SECTSIZE];

bool ide_device_valid(unsigned short ideno) { return ideno < MAX_IDE; }
ffffffffc0200494:	00253513          	sltiu	a0,a0,2
ffffffffc0200498:	8082                	ret

ffffffffc020049a <ide_device_size>:

size_t ide_device_size(unsigned short ideno) { return MAX_DISK_NSECS; }
ffffffffc020049a:	03800513          	li	a0,56
ffffffffc020049e:	8082                	ret

ffffffffc02004a0 <ide_read_secs>:

int ide_read_secs(unsigned short ideno, uint32_t secno, void *dst,
                  size_t nsecs) {
    int iobase = secno * SECTSIZE;
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc02004a0:	0000a797          	auipc	a5,0xa
ffffffffc02004a4:	ba078793          	addi	a5,a5,-1120 # ffffffffc020a040 <ide>
    int iobase = secno * SECTSIZE;
ffffffffc02004a8:	0095959b          	slliw	a1,a1,0x9
                  size_t nsecs) {
ffffffffc02004ac:	1141                	addi	sp,sp,-16
ffffffffc02004ae:	8532                	mv	a0,a2
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc02004b0:	95be                	add	a1,a1,a5
ffffffffc02004b2:	00969613          	slli	a2,a3,0x9
                  size_t nsecs) {
ffffffffc02004b6:	e406                	sd	ra,8(sp)
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc02004b8:	7a7030ef          	jal	ra,ffffffffc020445e <memcpy>
    return 0;
}
ffffffffc02004bc:	60a2                	ld	ra,8(sp)
ffffffffc02004be:	4501                	li	a0,0
ffffffffc02004c0:	0141                	addi	sp,sp,16
ffffffffc02004c2:	8082                	ret

ffffffffc02004c4 <ide_write_secs>:

int ide_write_secs(unsigned short ideno, uint32_t secno, const void *src,
                   size_t nsecs) {
    int iobase = secno * SECTSIZE;
ffffffffc02004c4:	0095979b          	slliw	a5,a1,0x9
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc02004c8:	0000a517          	auipc	a0,0xa
ffffffffc02004cc:	b7850513          	addi	a0,a0,-1160 # ffffffffc020a040 <ide>
                   size_t nsecs) {
ffffffffc02004d0:	1141                	addi	sp,sp,-16
ffffffffc02004d2:	85b2                	mv	a1,a2
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc02004d4:	953e                	add	a0,a0,a5
ffffffffc02004d6:	00969613          	slli	a2,a3,0x9
                   size_t nsecs) {
ffffffffc02004da:	e406                	sd	ra,8(sp)
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc02004dc:	783030ef          	jal	ra,ffffffffc020445e <memcpy>
    return 0;
}
ffffffffc02004e0:	60a2                	ld	ra,8(sp)
ffffffffc02004e2:	4501                	li	a0,0
ffffffffc02004e4:	0141                	addi	sp,sp,16
ffffffffc02004e6:	8082                	ret

ffffffffc02004e8 <intr_enable>:
#include <intr.h>
#include <riscv.h>

/* intr_enable - enable irq interrupt */
void intr_enable(void) { set_csr(sstatus, SSTATUS_SIE); }
ffffffffc02004e8:	100167f3          	csrrsi	a5,sstatus,2
ffffffffc02004ec:	8082                	ret

ffffffffc02004ee <intr_disable>:

/* intr_disable - disable irq interrupt */
void intr_disable(void) { clear_csr(sstatus, SSTATUS_SIE); }
ffffffffc02004ee:	100177f3          	csrrci	a5,sstatus,2
ffffffffc02004f2:	8082                	ret

ffffffffc02004f4 <pgfault_handler>:
    set_csr(sstatus, SSTATUS_SUM);
}

/* trap_in_kernel - test if trap happened in kernel */
bool trap_in_kernel(struct trapframe *tf) {
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc02004f4:	10053783          	ld	a5,256(a0)
    cprintf("page fault at 0x%08x: %c/%c\n", tf->badvaddr,
            trap_in_kernel(tf) ? 'K' : 'U',
            tf->cause == CAUSE_STORE_PAGE_FAULT ? 'W' : 'R');
}

static int pgfault_handler(struct trapframe *tf) {
ffffffffc02004f8:	1141                	addi	sp,sp,-16
ffffffffc02004fa:	e022                	sd	s0,0(sp)
ffffffffc02004fc:	e406                	sd	ra,8(sp)
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc02004fe:	1007f793          	andi	a5,a5,256
    cprintf("page fault at 0x%08x: %c/%c\n", tf->badvaddr,
ffffffffc0200502:	11053583          	ld	a1,272(a0)
static int pgfault_handler(struct trapframe *tf) {
ffffffffc0200506:	842a                	mv	s0,a0
    cprintf("page fault at 0x%08x: %c/%c\n", tf->badvaddr,
ffffffffc0200508:	05500613          	li	a2,85
ffffffffc020050c:	c399                	beqz	a5,ffffffffc0200512 <pgfault_handler+0x1e>
ffffffffc020050e:	04b00613          	li	a2,75
ffffffffc0200512:	11843703          	ld	a4,280(s0)
ffffffffc0200516:	47bd                	li	a5,15
ffffffffc0200518:	05700693          	li	a3,87
ffffffffc020051c:	00f70463          	beq	a4,a5,ffffffffc0200524 <pgfault_handler+0x30>
ffffffffc0200520:	05200693          	li	a3,82
ffffffffc0200524:	00004517          	auipc	a0,0x4
ffffffffc0200528:	23450513          	addi	a0,a0,564 # ffffffffc0204758 <commands+0x88>
ffffffffc020052c:	b8fff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    extern struct mm_struct *check_mm_struct;
    print_pgfault(tf);
    if (check_mm_struct != NULL) {
ffffffffc0200530:	00011517          	auipc	a0,0x11
ffffffffc0200534:	03853503          	ld	a0,56(a0) # ffffffffc0211568 <check_mm_struct>
ffffffffc0200538:	c911                	beqz	a0,ffffffffc020054c <pgfault_handler+0x58>
        return do_pgfault(check_mm_struct, tf->cause, tf->badvaddr);
ffffffffc020053a:	11043603          	ld	a2,272(s0)
ffffffffc020053e:	11843583          	ld	a1,280(s0)
    }
    panic("unhandled page fault.\n");
}
ffffffffc0200542:	6402                	ld	s0,0(sp)
ffffffffc0200544:	60a2                	ld	ra,8(sp)
ffffffffc0200546:	0141                	addi	sp,sp,16
        return do_pgfault(check_mm_struct, tf->cause, tf->badvaddr);
ffffffffc0200548:	7840306f          	j	ffffffffc0203ccc <do_pgfault>
    panic("unhandled page fault.\n");
ffffffffc020054c:	00004617          	auipc	a2,0x4
ffffffffc0200550:	22c60613          	addi	a2,a2,556 # ffffffffc0204778 <commands+0xa8>
ffffffffc0200554:	07900593          	li	a1,121
ffffffffc0200558:	00004517          	auipc	a0,0x4
ffffffffc020055c:	23850513          	addi	a0,a0,568 # ffffffffc0204790 <commands+0xc0>
ffffffffc0200560:	e15ff0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc0200564 <idt_init>:
    write_csr(sscratch, 0);
ffffffffc0200564:	14005073          	csrwi	sscratch,0
    write_csr(stvec, &__alltraps);
ffffffffc0200568:	00000797          	auipc	a5,0x0
ffffffffc020056c:	4e878793          	addi	a5,a5,1256 # ffffffffc0200a50 <__alltraps>
ffffffffc0200570:	10579073          	csrw	stvec,a5
    set_csr(sstatus, SSTATUS_SIE);
ffffffffc0200574:	100167f3          	csrrsi	a5,sstatus,2
    set_csr(sstatus, SSTATUS_SUM);
ffffffffc0200578:	000407b7          	lui	a5,0x40
ffffffffc020057c:	1007a7f3          	csrrs	a5,sstatus,a5
}
ffffffffc0200580:	8082                	ret

ffffffffc0200582 <print_regs>:
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200582:	610c                	ld	a1,0(a0)
void print_regs(struct pushregs *gpr) {
ffffffffc0200584:	1141                	addi	sp,sp,-16
ffffffffc0200586:	e022                	sd	s0,0(sp)
ffffffffc0200588:	842a                	mv	s0,a0
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc020058a:	00004517          	auipc	a0,0x4
ffffffffc020058e:	21e50513          	addi	a0,a0,542 # ffffffffc02047a8 <commands+0xd8>
void print_regs(struct pushregs *gpr) {
ffffffffc0200592:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200594:	b27ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc0200598:	640c                	ld	a1,8(s0)
ffffffffc020059a:	00004517          	auipc	a0,0x4
ffffffffc020059e:	22650513          	addi	a0,a0,550 # ffffffffc02047c0 <commands+0xf0>
ffffffffc02005a2:	b19ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc02005a6:	680c                	ld	a1,16(s0)
ffffffffc02005a8:	00004517          	auipc	a0,0x4
ffffffffc02005ac:	23050513          	addi	a0,a0,560 # ffffffffc02047d8 <commands+0x108>
ffffffffc02005b0:	b0bff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc02005b4:	6c0c                	ld	a1,24(s0)
ffffffffc02005b6:	00004517          	auipc	a0,0x4
ffffffffc02005ba:	23a50513          	addi	a0,a0,570 # ffffffffc02047f0 <commands+0x120>
ffffffffc02005be:	afdff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc02005c2:	700c                	ld	a1,32(s0)
ffffffffc02005c4:	00004517          	auipc	a0,0x4
ffffffffc02005c8:	24450513          	addi	a0,a0,580 # ffffffffc0204808 <commands+0x138>
ffffffffc02005cc:	aefff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc02005d0:	740c                	ld	a1,40(s0)
ffffffffc02005d2:	00004517          	auipc	a0,0x4
ffffffffc02005d6:	24e50513          	addi	a0,a0,590 # ffffffffc0204820 <commands+0x150>
ffffffffc02005da:	ae1ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc02005de:	780c                	ld	a1,48(s0)
ffffffffc02005e0:	00004517          	auipc	a0,0x4
ffffffffc02005e4:	25850513          	addi	a0,a0,600 # ffffffffc0204838 <commands+0x168>
ffffffffc02005e8:	ad3ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc02005ec:	7c0c                	ld	a1,56(s0)
ffffffffc02005ee:	00004517          	auipc	a0,0x4
ffffffffc02005f2:	26250513          	addi	a0,a0,610 # ffffffffc0204850 <commands+0x180>
ffffffffc02005f6:	ac5ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc02005fa:	602c                	ld	a1,64(s0)
ffffffffc02005fc:	00004517          	auipc	a0,0x4
ffffffffc0200600:	26c50513          	addi	a0,a0,620 # ffffffffc0204868 <commands+0x198>
ffffffffc0200604:	ab7ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc0200608:	642c                	ld	a1,72(s0)
ffffffffc020060a:	00004517          	auipc	a0,0x4
ffffffffc020060e:	27650513          	addi	a0,a0,630 # ffffffffc0204880 <commands+0x1b0>
ffffffffc0200612:	aa9ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc0200616:	682c                	ld	a1,80(s0)
ffffffffc0200618:	00004517          	auipc	a0,0x4
ffffffffc020061c:	28050513          	addi	a0,a0,640 # ffffffffc0204898 <commands+0x1c8>
ffffffffc0200620:	a9bff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc0200624:	6c2c                	ld	a1,88(s0)
ffffffffc0200626:	00004517          	auipc	a0,0x4
ffffffffc020062a:	28a50513          	addi	a0,a0,650 # ffffffffc02048b0 <commands+0x1e0>
ffffffffc020062e:	a8dff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc0200632:	702c                	ld	a1,96(s0)
ffffffffc0200634:	00004517          	auipc	a0,0x4
ffffffffc0200638:	29450513          	addi	a0,a0,660 # ffffffffc02048c8 <commands+0x1f8>
ffffffffc020063c:	a7fff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc0200640:	742c                	ld	a1,104(s0)
ffffffffc0200642:	00004517          	auipc	a0,0x4
ffffffffc0200646:	29e50513          	addi	a0,a0,670 # ffffffffc02048e0 <commands+0x210>
ffffffffc020064a:	a71ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc020064e:	782c                	ld	a1,112(s0)
ffffffffc0200650:	00004517          	auipc	a0,0x4
ffffffffc0200654:	2a850513          	addi	a0,a0,680 # ffffffffc02048f8 <commands+0x228>
ffffffffc0200658:	a63ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc020065c:	7c2c                	ld	a1,120(s0)
ffffffffc020065e:	00004517          	auipc	a0,0x4
ffffffffc0200662:	2b250513          	addi	a0,a0,690 # ffffffffc0204910 <commands+0x240>
ffffffffc0200666:	a55ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc020066a:	604c                	ld	a1,128(s0)
ffffffffc020066c:	00004517          	auipc	a0,0x4
ffffffffc0200670:	2bc50513          	addi	a0,a0,700 # ffffffffc0204928 <commands+0x258>
ffffffffc0200674:	a47ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc0200678:	644c                	ld	a1,136(s0)
ffffffffc020067a:	00004517          	auipc	a0,0x4
ffffffffc020067e:	2c650513          	addi	a0,a0,710 # ffffffffc0204940 <commands+0x270>
ffffffffc0200682:	a39ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc0200686:	684c                	ld	a1,144(s0)
ffffffffc0200688:	00004517          	auipc	a0,0x4
ffffffffc020068c:	2d050513          	addi	a0,a0,720 # ffffffffc0204958 <commands+0x288>
ffffffffc0200690:	a2bff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc0200694:	6c4c                	ld	a1,152(s0)
ffffffffc0200696:	00004517          	auipc	a0,0x4
ffffffffc020069a:	2da50513          	addi	a0,a0,730 # ffffffffc0204970 <commands+0x2a0>
ffffffffc020069e:	a1dff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc02006a2:	704c                	ld	a1,160(s0)
ffffffffc02006a4:	00004517          	auipc	a0,0x4
ffffffffc02006a8:	2e450513          	addi	a0,a0,740 # ffffffffc0204988 <commands+0x2b8>
ffffffffc02006ac:	a0fff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc02006b0:	744c                	ld	a1,168(s0)
ffffffffc02006b2:	00004517          	auipc	a0,0x4
ffffffffc02006b6:	2ee50513          	addi	a0,a0,750 # ffffffffc02049a0 <commands+0x2d0>
ffffffffc02006ba:	a01ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc02006be:	784c                	ld	a1,176(s0)
ffffffffc02006c0:	00004517          	auipc	a0,0x4
ffffffffc02006c4:	2f850513          	addi	a0,a0,760 # ffffffffc02049b8 <commands+0x2e8>
ffffffffc02006c8:	9f3ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc02006cc:	7c4c                	ld	a1,184(s0)
ffffffffc02006ce:	00004517          	auipc	a0,0x4
ffffffffc02006d2:	30250513          	addi	a0,a0,770 # ffffffffc02049d0 <commands+0x300>
ffffffffc02006d6:	9e5ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc02006da:	606c                	ld	a1,192(s0)
ffffffffc02006dc:	00004517          	auipc	a0,0x4
ffffffffc02006e0:	30c50513          	addi	a0,a0,780 # ffffffffc02049e8 <commands+0x318>
ffffffffc02006e4:	9d7ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc02006e8:	646c                	ld	a1,200(s0)
ffffffffc02006ea:	00004517          	auipc	a0,0x4
ffffffffc02006ee:	31650513          	addi	a0,a0,790 # ffffffffc0204a00 <commands+0x330>
ffffffffc02006f2:	9c9ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc02006f6:	686c                	ld	a1,208(s0)
ffffffffc02006f8:	00004517          	auipc	a0,0x4
ffffffffc02006fc:	32050513          	addi	a0,a0,800 # ffffffffc0204a18 <commands+0x348>
ffffffffc0200700:	9bbff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc0200704:	6c6c                	ld	a1,216(s0)
ffffffffc0200706:	00004517          	auipc	a0,0x4
ffffffffc020070a:	32a50513          	addi	a0,a0,810 # ffffffffc0204a30 <commands+0x360>
ffffffffc020070e:	9adff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc0200712:	706c                	ld	a1,224(s0)
ffffffffc0200714:	00004517          	auipc	a0,0x4
ffffffffc0200718:	33450513          	addi	a0,a0,820 # ffffffffc0204a48 <commands+0x378>
ffffffffc020071c:	99fff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc0200720:	746c                	ld	a1,232(s0)
ffffffffc0200722:	00004517          	auipc	a0,0x4
ffffffffc0200726:	33e50513          	addi	a0,a0,830 # ffffffffc0204a60 <commands+0x390>
ffffffffc020072a:	991ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc020072e:	786c                	ld	a1,240(s0)
ffffffffc0200730:	00004517          	auipc	a0,0x4
ffffffffc0200734:	34850513          	addi	a0,a0,840 # ffffffffc0204a78 <commands+0x3a8>
ffffffffc0200738:	983ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc020073c:	7c6c                	ld	a1,248(s0)
}
ffffffffc020073e:	6402                	ld	s0,0(sp)
ffffffffc0200740:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200742:	00004517          	auipc	a0,0x4
ffffffffc0200746:	34e50513          	addi	a0,a0,846 # ffffffffc0204a90 <commands+0x3c0>
}
ffffffffc020074a:	0141                	addi	sp,sp,16
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc020074c:	b2bd                	j	ffffffffc02000ba <cprintf>

ffffffffc020074e <print_trapframe>:
void print_trapframe(struct trapframe *tf) {
ffffffffc020074e:	1141                	addi	sp,sp,-16
ffffffffc0200750:	e022                	sd	s0,0(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200752:	85aa                	mv	a1,a0
void print_trapframe(struct trapframe *tf) {
ffffffffc0200754:	842a                	mv	s0,a0
    cprintf("trapframe at %p\n", tf);
ffffffffc0200756:	00004517          	auipc	a0,0x4
ffffffffc020075a:	35250513          	addi	a0,a0,850 # ffffffffc0204aa8 <commands+0x3d8>
void print_trapframe(struct trapframe *tf) {
ffffffffc020075e:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200760:	95bff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    print_regs(&tf->gpr);
ffffffffc0200764:	8522                	mv	a0,s0
ffffffffc0200766:	e1dff0ef          	jal	ra,ffffffffc0200582 <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
ffffffffc020076a:	10043583          	ld	a1,256(s0)
ffffffffc020076e:	00004517          	auipc	a0,0x4
ffffffffc0200772:	35250513          	addi	a0,a0,850 # ffffffffc0204ac0 <commands+0x3f0>
ffffffffc0200776:	945ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc020077a:	10843583          	ld	a1,264(s0)
ffffffffc020077e:	00004517          	auipc	a0,0x4
ffffffffc0200782:	35a50513          	addi	a0,a0,858 # ffffffffc0204ad8 <commands+0x408>
ffffffffc0200786:	935ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
ffffffffc020078a:	11043583          	ld	a1,272(s0)
ffffffffc020078e:	00004517          	auipc	a0,0x4
ffffffffc0200792:	36250513          	addi	a0,a0,866 # ffffffffc0204af0 <commands+0x420>
ffffffffc0200796:	925ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc020079a:	11843583          	ld	a1,280(s0)
}
ffffffffc020079e:	6402                	ld	s0,0(sp)
ffffffffc02007a0:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc02007a2:	00004517          	auipc	a0,0x4
ffffffffc02007a6:	36650513          	addi	a0,a0,870 # ffffffffc0204b08 <commands+0x438>
}
ffffffffc02007aa:	0141                	addi	sp,sp,16
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc02007ac:	90fff06f          	j	ffffffffc02000ba <cprintf>

ffffffffc02007b0 <interrupt_handler>:

static volatile int in_swap_tick_event = 0;
extern struct mm_struct *check_mm_struct;

void interrupt_handler(struct trapframe *tf) {
    intptr_t cause = (tf->cause << 1) >> 1;
ffffffffc02007b0:	11853783          	ld	a5,280(a0)
ffffffffc02007b4:	472d                	li	a4,11
ffffffffc02007b6:	0786                	slli	a5,a5,0x1
ffffffffc02007b8:	8385                	srli	a5,a5,0x1
ffffffffc02007ba:	08f76c63          	bltu	a4,a5,ffffffffc0200852 <interrupt_handler+0xa2>
ffffffffc02007be:	00004717          	auipc	a4,0x4
ffffffffc02007c2:	41270713          	addi	a4,a4,1042 # ffffffffc0204bd0 <commands+0x500>
ffffffffc02007c6:	078a                	slli	a5,a5,0x2
ffffffffc02007c8:	97ba                	add	a5,a5,a4
ffffffffc02007ca:	439c                	lw	a5,0(a5)
ffffffffc02007cc:	97ba                	add	a5,a5,a4
ffffffffc02007ce:	8782                	jr	a5
            break;
        case IRQ_H_SOFT:
            cprintf("Hypervisor software interrupt\n");
            break;
        case IRQ_M_SOFT:
            cprintf("Machine software interrupt\n");
ffffffffc02007d0:	00004517          	auipc	a0,0x4
ffffffffc02007d4:	3b050513          	addi	a0,a0,944 # ffffffffc0204b80 <commands+0x4b0>
ffffffffc02007d8:	8e3ff06f          	j	ffffffffc02000ba <cprintf>
            cprintf("Hypervisor software interrupt\n");
ffffffffc02007dc:	00004517          	auipc	a0,0x4
ffffffffc02007e0:	38450513          	addi	a0,a0,900 # ffffffffc0204b60 <commands+0x490>
ffffffffc02007e4:	8d7ff06f          	j	ffffffffc02000ba <cprintf>
            cprintf("User software interrupt\n");
ffffffffc02007e8:	00004517          	auipc	a0,0x4
ffffffffc02007ec:	33850513          	addi	a0,a0,824 # ffffffffc0204b20 <commands+0x450>
ffffffffc02007f0:	8cbff06f          	j	ffffffffc02000ba <cprintf>
            cprintf("Supervisor software interrupt\n");
ffffffffc02007f4:	00004517          	auipc	a0,0x4
ffffffffc02007f8:	34c50513          	addi	a0,a0,844 # ffffffffc0204b40 <commands+0x470>
ffffffffc02007fc:	8bfff06f          	j	ffffffffc02000ba <cprintf>
void interrupt_handler(struct trapframe *tf) {
ffffffffc0200800:	1141                	addi	sp,sp,-16
ffffffffc0200802:	e022                	sd	s0,0(sp)
ffffffffc0200804:	e406                	sd	ra,8(sp)
            // "All bits besides SSIP and USIP in the sip register are
            // read-only." -- privileged spec1.9.1, 4.1.4, p59
            // In fact, Call sbi_set_timer will clear STIP, or you can clear it
            // directly.
            // clear_csr(sip, SIP_STIP);
            clock_set_next_event();//(1)
ffffffffc0200806:	c03ff0ef          	jal	ra,ffffffffc0200408 <clock_set_next_event>
            if (++ticks % TICK_NUM == 0) {//(2+3)
ffffffffc020080a:	00011697          	auipc	a3,0x11
ffffffffc020080e:	cf668693          	addi	a3,a3,-778 # ffffffffc0211500 <ticks>
ffffffffc0200812:	629c                	ld	a5,0(a3)
ffffffffc0200814:	06400713          	li	a4,100
ffffffffc0200818:	00011417          	auipc	s0,0x11
ffffffffc020081c:	cf840413          	addi	s0,s0,-776 # ffffffffc0211510 <num>
ffffffffc0200820:	0785                	addi	a5,a5,1
ffffffffc0200822:	02e7f733          	remu	a4,a5,a4
ffffffffc0200826:	e29c                	sd	a5,0(a3)
ffffffffc0200828:	c715                	beqz	a4,ffffffffc0200854 <interrupt_handler+0xa4>
                print_ticks();
                num=num+1;//(3)
            }
           
            if(num==10)
ffffffffc020082a:	6018                	ld	a4,0(s0)
ffffffffc020082c:	47a9                	li	a5,10
ffffffffc020082e:	00f71863          	bne	a4,a5,ffffffffc020083e <interrupt_handler+0x8e>
#endif
}

static inline void sbi_shutdown(void)
{
	SBI_CALL_0(SBI_SHUTDOWN);
ffffffffc0200832:	4501                	li	a0,0
ffffffffc0200834:	4581                	li	a1,0
ffffffffc0200836:	4601                	li	a2,0
ffffffffc0200838:	48a1                	li	a7,8
ffffffffc020083a:	00000073          	ecall
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc020083e:	60a2                	ld	ra,8(sp)
ffffffffc0200840:	6402                	ld	s0,0(sp)
ffffffffc0200842:	0141                	addi	sp,sp,16
ffffffffc0200844:	8082                	ret
            cprintf("Supervisor external interrupt\n");
ffffffffc0200846:	00004517          	auipc	a0,0x4
ffffffffc020084a:	36a50513          	addi	a0,a0,874 # ffffffffc0204bb0 <commands+0x4e0>
ffffffffc020084e:	86dff06f          	j	ffffffffc02000ba <cprintf>
            print_trapframe(tf);
ffffffffc0200852:	bdf5                	j	ffffffffc020074e <print_trapframe>
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc0200854:	06400593          	li	a1,100
ffffffffc0200858:	00004517          	auipc	a0,0x4
ffffffffc020085c:	34850513          	addi	a0,a0,840 # ffffffffc0204ba0 <commands+0x4d0>
ffffffffc0200860:	85bff0ef          	jal	ra,ffffffffc02000ba <cprintf>
                num=num+1;//(3)
ffffffffc0200864:	601c                	ld	a5,0(s0)
ffffffffc0200866:	0785                	addi	a5,a5,1
ffffffffc0200868:	e01c                	sd	a5,0(s0)
ffffffffc020086a:	b7c1                	j	ffffffffc020082a <interrupt_handler+0x7a>

ffffffffc020086c <exception_handler>:


void exception_handler(struct trapframe *tf) {
    int ret;
    switch (tf->cause) {
ffffffffc020086c:	11853783          	ld	a5,280(a0)
void exception_handler(struct trapframe *tf) {
ffffffffc0200870:	1101                	addi	sp,sp,-32
ffffffffc0200872:	e822                	sd	s0,16(sp)
ffffffffc0200874:	ec06                	sd	ra,24(sp)
ffffffffc0200876:	e426                	sd	s1,8(sp)
ffffffffc0200878:	473d                	li	a4,15
ffffffffc020087a:	842a                	mv	s0,a0
ffffffffc020087c:	18f76963          	bltu	a4,a5,ffffffffc0200a0e <exception_handler+0x1a2>
ffffffffc0200880:	00004717          	auipc	a4,0x4
ffffffffc0200884:	58870713          	addi	a4,a4,1416 # ffffffffc0204e08 <commands+0x738>
ffffffffc0200888:	078a                	slli	a5,a5,0x2
ffffffffc020088a:	97ba                	add	a5,a5,a4
ffffffffc020088c:	439c                	lw	a5,0(a5)
ffffffffc020088e:	97ba                	add	a5,a5,a4
ffffffffc0200890:	8782                	jr	a5
                print_trapframe(tf);
                panic("handle pgfault failed. %e\n", ret);
            }
            break;
        case CAUSE_STORE_PAGE_FAULT:
            cprintf("Store/AMO page fault\n");
ffffffffc0200892:	00004517          	auipc	a0,0x4
ffffffffc0200896:	55e50513          	addi	a0,a0,1374 # ffffffffc0204df0 <commands+0x720>
ffffffffc020089a:	821ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc020089e:	8522                	mv	a0,s0
ffffffffc02008a0:	c55ff0ef          	jal	ra,ffffffffc02004f4 <pgfault_handler>
ffffffffc02008a4:	84aa                	mv	s1,a0
ffffffffc02008a6:	16051a63          	bnez	a0,ffffffffc0200a1a <exception_handler+0x1ae>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc02008aa:	60e2                	ld	ra,24(sp)
ffffffffc02008ac:	6442                	ld	s0,16(sp)
ffffffffc02008ae:	64a2                	ld	s1,8(sp)
ffffffffc02008b0:	6105                	addi	sp,sp,32
ffffffffc02008b2:	8082                	ret
            cprintf("Instruction address misaligned\n");
ffffffffc02008b4:	00004517          	auipc	a0,0x4
ffffffffc02008b8:	34c50513          	addi	a0,a0,844 # ffffffffc0204c00 <commands+0x530>
}
ffffffffc02008bc:	6442                	ld	s0,16(sp)
ffffffffc02008be:	60e2                	ld	ra,24(sp)
ffffffffc02008c0:	64a2                	ld	s1,8(sp)
ffffffffc02008c2:	6105                	addi	sp,sp,32
            cprintf("Instruction access fault\n");
ffffffffc02008c4:	ff6ff06f          	j	ffffffffc02000ba <cprintf>
ffffffffc02008c8:	00004517          	auipc	a0,0x4
ffffffffc02008cc:	35850513          	addi	a0,a0,856 # ffffffffc0204c20 <commands+0x550>
ffffffffc02008d0:	b7f5                	j	ffffffffc02008bc <exception_handler+0x50>
            cprintf("Exception type is Illegal instruction\n");
ffffffffc02008d2:	00004517          	auipc	a0,0x4
ffffffffc02008d6:	36e50513          	addi	a0,a0,878 # ffffffffc0204c40 <commands+0x570>
ffffffffc02008da:	fe0ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
            cprintf("its address is: 0x%lx\n", tf->epc);
ffffffffc02008de:	10843583          	ld	a1,264(s0)
ffffffffc02008e2:	00004517          	auipc	a0,0x4
ffffffffc02008e6:	38650513          	addi	a0,a0,902 # ffffffffc0204c68 <commands+0x598>
ffffffffc02008ea:	fd0ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
            tf->epc=tf->epc+4;
ffffffffc02008ee:	10843783          	ld	a5,264(s0)
ffffffffc02008f2:	0791                	addi	a5,a5,4
ffffffffc02008f4:	10f43423          	sd	a5,264(s0)
            break;
ffffffffc02008f8:	bf4d                	j	ffffffffc02008aa <exception_handler+0x3e>
            cprintf("Exception type is breakpoint\n");
ffffffffc02008fa:	00004517          	auipc	a0,0x4
ffffffffc02008fe:	38650513          	addi	a0,a0,902 # ffffffffc0204c80 <commands+0x5b0>
ffffffffc0200902:	fb8ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
            cprintf("its address is:0x%lx\n",tf->epc);
ffffffffc0200906:	10843583          	ld	a1,264(s0)
ffffffffc020090a:	00004517          	auipc	a0,0x4
ffffffffc020090e:	39650513          	addi	a0,a0,918 # ffffffffc0204ca0 <commands+0x5d0>
ffffffffc0200912:	fa8ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
            tf->epc=tf->epc+2;// EBREAK 指令在 RISC-V 中是一个 压缩指令（2 字节）
ffffffffc0200916:	10843783          	ld	a5,264(s0)
ffffffffc020091a:	0789                	addi	a5,a5,2
ffffffffc020091c:	10f43423          	sd	a5,264(s0)
            break;
ffffffffc0200920:	b769                	j	ffffffffc02008aa <exception_handler+0x3e>
            cprintf("Load address misaligned\n");
ffffffffc0200922:	00004517          	auipc	a0,0x4
ffffffffc0200926:	39650513          	addi	a0,a0,918 # ffffffffc0204cb8 <commands+0x5e8>
ffffffffc020092a:	bf49                	j	ffffffffc02008bc <exception_handler+0x50>
            cprintf("Load access fault\n");
ffffffffc020092c:	00004517          	auipc	a0,0x4
ffffffffc0200930:	3ac50513          	addi	a0,a0,940 # ffffffffc0204cd8 <commands+0x608>
ffffffffc0200934:	f86ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200938:	8522                	mv	a0,s0
ffffffffc020093a:	bbbff0ef          	jal	ra,ffffffffc02004f4 <pgfault_handler>
ffffffffc020093e:	84aa                	mv	s1,a0
ffffffffc0200940:	d52d                	beqz	a0,ffffffffc02008aa <exception_handler+0x3e>
                print_trapframe(tf);
ffffffffc0200942:	8522                	mv	a0,s0
ffffffffc0200944:	e0bff0ef          	jal	ra,ffffffffc020074e <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200948:	86a6                	mv	a3,s1
ffffffffc020094a:	00004617          	auipc	a2,0x4
ffffffffc020094e:	3a660613          	addi	a2,a2,934 # ffffffffc0204cf0 <commands+0x620>
ffffffffc0200952:	0ee00593          	li	a1,238
ffffffffc0200956:	00004517          	auipc	a0,0x4
ffffffffc020095a:	e3a50513          	addi	a0,a0,-454 # ffffffffc0204790 <commands+0xc0>
ffffffffc020095e:	a17ff0ef          	jal	ra,ffffffffc0200374 <__panic>
            cprintf("AMO address misaligned\n");
ffffffffc0200962:	00004517          	auipc	a0,0x4
ffffffffc0200966:	3ae50513          	addi	a0,a0,942 # ffffffffc0204d10 <commands+0x640>
ffffffffc020096a:	bf89                	j	ffffffffc02008bc <exception_handler+0x50>
            cprintf("Store/AMO access fault\n");
ffffffffc020096c:	00004517          	auipc	a0,0x4
ffffffffc0200970:	3bc50513          	addi	a0,a0,956 # ffffffffc0204d28 <commands+0x658>
ffffffffc0200974:	f46ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200978:	8522                	mv	a0,s0
ffffffffc020097a:	b7bff0ef          	jal	ra,ffffffffc02004f4 <pgfault_handler>
ffffffffc020097e:	84aa                	mv	s1,a0
ffffffffc0200980:	f20505e3          	beqz	a0,ffffffffc02008aa <exception_handler+0x3e>
                print_trapframe(tf);
ffffffffc0200984:	8522                	mv	a0,s0
ffffffffc0200986:	dc9ff0ef          	jal	ra,ffffffffc020074e <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc020098a:	86a6                	mv	a3,s1
ffffffffc020098c:	00004617          	auipc	a2,0x4
ffffffffc0200990:	36460613          	addi	a2,a2,868 # ffffffffc0204cf0 <commands+0x620>
ffffffffc0200994:	0f800593          	li	a1,248
ffffffffc0200998:	00004517          	auipc	a0,0x4
ffffffffc020099c:	df850513          	addi	a0,a0,-520 # ffffffffc0204790 <commands+0xc0>
ffffffffc02009a0:	9d5ff0ef          	jal	ra,ffffffffc0200374 <__panic>
            cprintf("Environment call from U-mode\n");
ffffffffc02009a4:	00004517          	auipc	a0,0x4
ffffffffc02009a8:	39c50513          	addi	a0,a0,924 # ffffffffc0204d40 <commands+0x670>
ffffffffc02009ac:	bf01                	j	ffffffffc02008bc <exception_handler+0x50>
            cprintf("Environment call from S-mode\n");
ffffffffc02009ae:	00004517          	auipc	a0,0x4
ffffffffc02009b2:	3b250513          	addi	a0,a0,946 # ffffffffc0204d60 <commands+0x690>
ffffffffc02009b6:	b719                	j	ffffffffc02008bc <exception_handler+0x50>
            cprintf("Environment call from H-mode\n");
ffffffffc02009b8:	00004517          	auipc	a0,0x4
ffffffffc02009bc:	3c850513          	addi	a0,a0,968 # ffffffffc0204d80 <commands+0x6b0>
ffffffffc02009c0:	bdf5                	j	ffffffffc02008bc <exception_handler+0x50>
            cprintf("Environment call from M-mode\n");
ffffffffc02009c2:	00004517          	auipc	a0,0x4
ffffffffc02009c6:	3de50513          	addi	a0,a0,990 # ffffffffc0204da0 <commands+0x6d0>
ffffffffc02009ca:	bdcd                	j	ffffffffc02008bc <exception_handler+0x50>
            cprintf("Instruction page fault\n");
ffffffffc02009cc:	00004517          	auipc	a0,0x4
ffffffffc02009d0:	3f450513          	addi	a0,a0,1012 # ffffffffc0204dc0 <commands+0x6f0>
ffffffffc02009d4:	b5e5                	j	ffffffffc02008bc <exception_handler+0x50>
            cprintf("Load page fault\n");
ffffffffc02009d6:	00004517          	auipc	a0,0x4
ffffffffc02009da:	40250513          	addi	a0,a0,1026 # ffffffffc0204dd8 <commands+0x708>
ffffffffc02009de:	edcff0ef          	jal	ra,ffffffffc02000ba <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc02009e2:	8522                	mv	a0,s0
ffffffffc02009e4:	b11ff0ef          	jal	ra,ffffffffc02004f4 <pgfault_handler>
ffffffffc02009e8:	84aa                	mv	s1,a0
ffffffffc02009ea:	ec0500e3          	beqz	a0,ffffffffc02008aa <exception_handler+0x3e>
                print_trapframe(tf);
ffffffffc02009ee:	8522                	mv	a0,s0
ffffffffc02009f0:	d5fff0ef          	jal	ra,ffffffffc020074e <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc02009f4:	86a6                	mv	a3,s1
ffffffffc02009f6:	00004617          	auipc	a2,0x4
ffffffffc02009fa:	2fa60613          	addi	a2,a2,762 # ffffffffc0204cf0 <commands+0x620>
ffffffffc02009fe:	10e00593          	li	a1,270
ffffffffc0200a02:	00004517          	auipc	a0,0x4
ffffffffc0200a06:	d8e50513          	addi	a0,a0,-626 # ffffffffc0204790 <commands+0xc0>
ffffffffc0200a0a:	96bff0ef          	jal	ra,ffffffffc0200374 <__panic>
            print_trapframe(tf);
ffffffffc0200a0e:	8522                	mv	a0,s0
}
ffffffffc0200a10:	6442                	ld	s0,16(sp)
ffffffffc0200a12:	60e2                	ld	ra,24(sp)
ffffffffc0200a14:	64a2                	ld	s1,8(sp)
ffffffffc0200a16:	6105                	addi	sp,sp,32
            print_trapframe(tf);
ffffffffc0200a18:	bb1d                	j	ffffffffc020074e <print_trapframe>
                print_trapframe(tf);
ffffffffc0200a1a:	8522                	mv	a0,s0
ffffffffc0200a1c:	d33ff0ef          	jal	ra,ffffffffc020074e <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200a20:	86a6                	mv	a3,s1
ffffffffc0200a22:	00004617          	auipc	a2,0x4
ffffffffc0200a26:	2ce60613          	addi	a2,a2,718 # ffffffffc0204cf0 <commands+0x620>
ffffffffc0200a2a:	11500593          	li	a1,277
ffffffffc0200a2e:	00004517          	auipc	a0,0x4
ffffffffc0200a32:	d6250513          	addi	a0,a0,-670 # ffffffffc0204790 <commands+0xc0>
ffffffffc0200a36:	93fff0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc0200a3a <trap>:
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void trap(struct trapframe *tf) {
    // dispatch based on what type of trap occurred
    if ((intptr_t)tf->cause < 0) {
ffffffffc0200a3a:	11853783          	ld	a5,280(a0)
ffffffffc0200a3e:	0007c363          	bltz	a5,ffffffffc0200a44 <trap+0xa>
        // interrupts
        interrupt_handler(tf);
    } else {
        // exceptions
        exception_handler(tf);
ffffffffc0200a42:	b52d                	j	ffffffffc020086c <exception_handler>
        interrupt_handler(tf);
ffffffffc0200a44:	b3b5                	j	ffffffffc02007b0 <interrupt_handler>
	...

ffffffffc0200a50 <__alltraps>:
    .endm

    .align 4
    .globl __alltraps
__alltraps:
    SAVE_ALL
ffffffffc0200a50:	14011073          	csrw	sscratch,sp
ffffffffc0200a54:	712d                	addi	sp,sp,-288
ffffffffc0200a56:	e406                	sd	ra,8(sp)
ffffffffc0200a58:	ec0e                	sd	gp,24(sp)
ffffffffc0200a5a:	f012                	sd	tp,32(sp)
ffffffffc0200a5c:	f416                	sd	t0,40(sp)
ffffffffc0200a5e:	f81a                	sd	t1,48(sp)
ffffffffc0200a60:	fc1e                	sd	t2,56(sp)
ffffffffc0200a62:	e0a2                	sd	s0,64(sp)
ffffffffc0200a64:	e4a6                	sd	s1,72(sp)
ffffffffc0200a66:	e8aa                	sd	a0,80(sp)
ffffffffc0200a68:	ecae                	sd	a1,88(sp)
ffffffffc0200a6a:	f0b2                	sd	a2,96(sp)
ffffffffc0200a6c:	f4b6                	sd	a3,104(sp)
ffffffffc0200a6e:	f8ba                	sd	a4,112(sp)
ffffffffc0200a70:	fcbe                	sd	a5,120(sp)
ffffffffc0200a72:	e142                	sd	a6,128(sp)
ffffffffc0200a74:	e546                	sd	a7,136(sp)
ffffffffc0200a76:	e94a                	sd	s2,144(sp)
ffffffffc0200a78:	ed4e                	sd	s3,152(sp)
ffffffffc0200a7a:	f152                	sd	s4,160(sp)
ffffffffc0200a7c:	f556                	sd	s5,168(sp)
ffffffffc0200a7e:	f95a                	sd	s6,176(sp)
ffffffffc0200a80:	fd5e                	sd	s7,184(sp)
ffffffffc0200a82:	e1e2                	sd	s8,192(sp)
ffffffffc0200a84:	e5e6                	sd	s9,200(sp)
ffffffffc0200a86:	e9ea                	sd	s10,208(sp)
ffffffffc0200a88:	edee                	sd	s11,216(sp)
ffffffffc0200a8a:	f1f2                	sd	t3,224(sp)
ffffffffc0200a8c:	f5f6                	sd	t4,232(sp)
ffffffffc0200a8e:	f9fa                	sd	t5,240(sp)
ffffffffc0200a90:	fdfe                	sd	t6,248(sp)
ffffffffc0200a92:	14002473          	csrr	s0,sscratch
ffffffffc0200a96:	100024f3          	csrr	s1,sstatus
ffffffffc0200a9a:	14102973          	csrr	s2,sepc
ffffffffc0200a9e:	143029f3          	csrr	s3,stval
ffffffffc0200aa2:	14202a73          	csrr	s4,scause
ffffffffc0200aa6:	e822                	sd	s0,16(sp)
ffffffffc0200aa8:	e226                	sd	s1,256(sp)
ffffffffc0200aaa:	e64a                	sd	s2,264(sp)
ffffffffc0200aac:	ea4e                	sd	s3,272(sp)
ffffffffc0200aae:	ee52                	sd	s4,280(sp)

    move  a0, sp
ffffffffc0200ab0:	850a                	mv	a0,sp
    jal trap
ffffffffc0200ab2:	f89ff0ef          	jal	ra,ffffffffc0200a3a <trap>

ffffffffc0200ab6 <__trapret>:
    // sp should be the same as before "jal trap"
    .globl __trapret
__trapret:
    RESTORE_ALL
ffffffffc0200ab6:	6492                	ld	s1,256(sp)
ffffffffc0200ab8:	6932                	ld	s2,264(sp)
ffffffffc0200aba:	10049073          	csrw	sstatus,s1
ffffffffc0200abe:	14191073          	csrw	sepc,s2
ffffffffc0200ac2:	60a2                	ld	ra,8(sp)
ffffffffc0200ac4:	61e2                	ld	gp,24(sp)
ffffffffc0200ac6:	7202                	ld	tp,32(sp)
ffffffffc0200ac8:	72a2                	ld	t0,40(sp)
ffffffffc0200aca:	7342                	ld	t1,48(sp)
ffffffffc0200acc:	73e2                	ld	t2,56(sp)
ffffffffc0200ace:	6406                	ld	s0,64(sp)
ffffffffc0200ad0:	64a6                	ld	s1,72(sp)
ffffffffc0200ad2:	6546                	ld	a0,80(sp)
ffffffffc0200ad4:	65e6                	ld	a1,88(sp)
ffffffffc0200ad6:	7606                	ld	a2,96(sp)
ffffffffc0200ad8:	76a6                	ld	a3,104(sp)
ffffffffc0200ada:	7746                	ld	a4,112(sp)
ffffffffc0200adc:	77e6                	ld	a5,120(sp)
ffffffffc0200ade:	680a                	ld	a6,128(sp)
ffffffffc0200ae0:	68aa                	ld	a7,136(sp)
ffffffffc0200ae2:	694a                	ld	s2,144(sp)
ffffffffc0200ae4:	69ea                	ld	s3,152(sp)
ffffffffc0200ae6:	7a0a                	ld	s4,160(sp)
ffffffffc0200ae8:	7aaa                	ld	s5,168(sp)
ffffffffc0200aea:	7b4a                	ld	s6,176(sp)
ffffffffc0200aec:	7bea                	ld	s7,184(sp)
ffffffffc0200aee:	6c0e                	ld	s8,192(sp)
ffffffffc0200af0:	6cae                	ld	s9,200(sp)
ffffffffc0200af2:	6d4e                	ld	s10,208(sp)
ffffffffc0200af4:	6dee                	ld	s11,216(sp)
ffffffffc0200af6:	7e0e                	ld	t3,224(sp)
ffffffffc0200af8:	7eae                	ld	t4,232(sp)
ffffffffc0200afa:	7f4e                	ld	t5,240(sp)
ffffffffc0200afc:	7fee                	ld	t6,248(sp)
ffffffffc0200afe:	6142                	ld	sp,16(sp)
    // go back from supervisor call
    sret
ffffffffc0200b00:	10200073          	sret
	...

ffffffffc0200b10 <default_init>:
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
ffffffffc0200b10:	00010797          	auipc	a5,0x10
ffffffffc0200b14:	53078793          	addi	a5,a5,1328 # ffffffffc0211040 <free_area>
ffffffffc0200b18:	e79c                	sd	a5,8(a5)
ffffffffc0200b1a:	e39c                	sd	a5,0(a5)
#define nr_free (free_area.nr_free)

static void
default_init(void) {
    list_init(&free_list);
    nr_free = 0;
ffffffffc0200b1c:	0007a823          	sw	zero,16(a5)
}
ffffffffc0200b20:	8082                	ret

ffffffffc0200b22 <default_nr_free_pages>:
}

static size_t
default_nr_free_pages(void) {
    return nr_free;
}
ffffffffc0200b22:	00010517          	auipc	a0,0x10
ffffffffc0200b26:	52e56503          	lwu	a0,1326(a0) # ffffffffc0211050 <free_area+0x10>
ffffffffc0200b2a:	8082                	ret

ffffffffc0200b2c <default_check>:
}

// LAB2: below code is used to check the first fit allocation algorithm
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
ffffffffc0200b2c:	715d                	addi	sp,sp,-80
ffffffffc0200b2e:	e0a2                	sd	s0,64(sp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
ffffffffc0200b30:	00010417          	auipc	s0,0x10
ffffffffc0200b34:	51040413          	addi	s0,s0,1296 # ffffffffc0211040 <free_area>
ffffffffc0200b38:	641c                	ld	a5,8(s0)
ffffffffc0200b3a:	e486                	sd	ra,72(sp)
ffffffffc0200b3c:	fc26                	sd	s1,56(sp)
ffffffffc0200b3e:	f84a                	sd	s2,48(sp)
ffffffffc0200b40:	f44e                	sd	s3,40(sp)
ffffffffc0200b42:	f052                	sd	s4,32(sp)
ffffffffc0200b44:	ec56                	sd	s5,24(sp)
ffffffffc0200b46:	e85a                	sd	s6,16(sp)
ffffffffc0200b48:	e45e                	sd	s7,8(sp)
ffffffffc0200b4a:	e062                	sd	s8,0(sp)
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200b4c:	2c878763          	beq	a5,s0,ffffffffc0200e1a <default_check+0x2ee>
    int count = 0, total = 0;
ffffffffc0200b50:	4481                	li	s1,0
ffffffffc0200b52:	4901                	li	s2,0
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0200b54:	fe87b703          	ld	a4,-24(a5)
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc0200b58:	8b09                	andi	a4,a4,2
ffffffffc0200b5a:	2c070463          	beqz	a4,ffffffffc0200e22 <default_check+0x2f6>
        count ++, total += p->property;
ffffffffc0200b5e:	ff87a703          	lw	a4,-8(a5)
ffffffffc0200b62:	679c                	ld	a5,8(a5)
ffffffffc0200b64:	2905                	addiw	s2,s2,1
ffffffffc0200b66:	9cb9                	addw	s1,s1,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200b68:	fe8796e3          	bne	a5,s0,ffffffffc0200b54 <default_check+0x28>
    }
    assert(total == nr_free_pages());
ffffffffc0200b6c:	89a6                	mv	s3,s1
ffffffffc0200b6e:	385000ef          	jal	ra,ffffffffc02016f2 <nr_free_pages>
ffffffffc0200b72:	71351863          	bne	a0,s3,ffffffffc0201282 <default_check+0x756>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200b76:	4505                	li	a0,1
ffffffffc0200b78:	2a9000ef          	jal	ra,ffffffffc0201620 <alloc_pages>
ffffffffc0200b7c:	8a2a                	mv	s4,a0
ffffffffc0200b7e:	44050263          	beqz	a0,ffffffffc0200fc2 <default_check+0x496>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200b82:	4505                	li	a0,1
ffffffffc0200b84:	29d000ef          	jal	ra,ffffffffc0201620 <alloc_pages>
ffffffffc0200b88:	89aa                	mv	s3,a0
ffffffffc0200b8a:	70050c63          	beqz	a0,ffffffffc02012a2 <default_check+0x776>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200b8e:	4505                	li	a0,1
ffffffffc0200b90:	291000ef          	jal	ra,ffffffffc0201620 <alloc_pages>
ffffffffc0200b94:	8aaa                	mv	s5,a0
ffffffffc0200b96:	4a050663          	beqz	a0,ffffffffc0201042 <default_check+0x516>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0200b9a:	2b3a0463          	beq	s4,s3,ffffffffc0200e42 <default_check+0x316>
ffffffffc0200b9e:	2aaa0263          	beq	s4,a0,ffffffffc0200e42 <default_check+0x316>
ffffffffc0200ba2:	2aa98063          	beq	s3,a0,ffffffffc0200e42 <default_check+0x316>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0200ba6:	000a2783          	lw	a5,0(s4)
ffffffffc0200baa:	2a079c63          	bnez	a5,ffffffffc0200e62 <default_check+0x336>
ffffffffc0200bae:	0009a783          	lw	a5,0(s3)
ffffffffc0200bb2:	2a079863          	bnez	a5,ffffffffc0200e62 <default_check+0x336>
ffffffffc0200bb6:	411c                	lw	a5,0(a0)
ffffffffc0200bb8:	2a079563          	bnez	a5,ffffffffc0200e62 <default_check+0x336>
extern struct Page *pages;
extern size_t npage;
extern const size_t nbase;
extern uint_t va_pa_offset;

static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200bbc:	00011797          	auipc	a5,0x11
ffffffffc0200bc0:	9747b783          	ld	a5,-1676(a5) # ffffffffc0211530 <pages>
ffffffffc0200bc4:	40fa0733          	sub	a4,s4,a5
ffffffffc0200bc8:	870d                	srai	a4,a4,0x3
ffffffffc0200bca:	00005597          	auipc	a1,0x5
ffffffffc0200bce:	7265b583          	ld	a1,1830(a1) # ffffffffc02062f0 <error_string+0x38>
ffffffffc0200bd2:	02b70733          	mul	a4,a4,a1
ffffffffc0200bd6:	00005617          	auipc	a2,0x5
ffffffffc0200bda:	72263603          	ld	a2,1826(a2) # ffffffffc02062f8 <nbase>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0200bde:	00011697          	auipc	a3,0x11
ffffffffc0200be2:	94a6b683          	ld	a3,-1718(a3) # ffffffffc0211528 <npage>
ffffffffc0200be6:	06b2                	slli	a3,a3,0xc
ffffffffc0200be8:	9732                	add	a4,a4,a2

static inline uintptr_t page2pa(struct Page *page) {
    return page2ppn(page) << PGSHIFT;
ffffffffc0200bea:	0732                	slli	a4,a4,0xc
ffffffffc0200bec:	28d77b63          	bgeu	a4,a3,ffffffffc0200e82 <default_check+0x356>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200bf0:	40f98733          	sub	a4,s3,a5
ffffffffc0200bf4:	870d                	srai	a4,a4,0x3
ffffffffc0200bf6:	02b70733          	mul	a4,a4,a1
ffffffffc0200bfa:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0200bfc:	0732                	slli	a4,a4,0xc
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0200bfe:	4cd77263          	bgeu	a4,a3,ffffffffc02010c2 <default_check+0x596>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200c02:	40f507b3          	sub	a5,a0,a5
ffffffffc0200c06:	878d                	srai	a5,a5,0x3
ffffffffc0200c08:	02b787b3          	mul	a5,a5,a1
ffffffffc0200c0c:	97b2                	add	a5,a5,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0200c0e:	07b2                	slli	a5,a5,0xc
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0200c10:	30d7f963          	bgeu	a5,a3,ffffffffc0200f22 <default_check+0x3f6>
    assert(alloc_page() == NULL);
ffffffffc0200c14:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0200c16:	00043c03          	ld	s8,0(s0)
ffffffffc0200c1a:	00843b83          	ld	s7,8(s0)
    unsigned int nr_free_store = nr_free;
ffffffffc0200c1e:	01042b03          	lw	s6,16(s0)
    elm->prev = elm->next = elm;
ffffffffc0200c22:	e400                	sd	s0,8(s0)
ffffffffc0200c24:	e000                	sd	s0,0(s0)
    nr_free = 0;
ffffffffc0200c26:	00010797          	auipc	a5,0x10
ffffffffc0200c2a:	4207a523          	sw	zero,1066(a5) # ffffffffc0211050 <free_area+0x10>
    assert(alloc_page() == NULL);
ffffffffc0200c2e:	1f3000ef          	jal	ra,ffffffffc0201620 <alloc_pages>
ffffffffc0200c32:	2c051863          	bnez	a0,ffffffffc0200f02 <default_check+0x3d6>
    free_page(p0);
ffffffffc0200c36:	4585                	li	a1,1
ffffffffc0200c38:	8552                	mv	a0,s4
ffffffffc0200c3a:	279000ef          	jal	ra,ffffffffc02016b2 <free_pages>
    free_page(p1);
ffffffffc0200c3e:	4585                	li	a1,1
ffffffffc0200c40:	854e                	mv	a0,s3
ffffffffc0200c42:	271000ef          	jal	ra,ffffffffc02016b2 <free_pages>
    free_page(p2);
ffffffffc0200c46:	4585                	li	a1,1
ffffffffc0200c48:	8556                	mv	a0,s5
ffffffffc0200c4a:	269000ef          	jal	ra,ffffffffc02016b2 <free_pages>
    assert(nr_free == 3);
ffffffffc0200c4e:	4818                	lw	a4,16(s0)
ffffffffc0200c50:	478d                	li	a5,3
ffffffffc0200c52:	28f71863          	bne	a4,a5,ffffffffc0200ee2 <default_check+0x3b6>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200c56:	4505                	li	a0,1
ffffffffc0200c58:	1c9000ef          	jal	ra,ffffffffc0201620 <alloc_pages>
ffffffffc0200c5c:	89aa                	mv	s3,a0
ffffffffc0200c5e:	26050263          	beqz	a0,ffffffffc0200ec2 <default_check+0x396>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200c62:	4505                	li	a0,1
ffffffffc0200c64:	1bd000ef          	jal	ra,ffffffffc0201620 <alloc_pages>
ffffffffc0200c68:	8aaa                	mv	s5,a0
ffffffffc0200c6a:	3a050c63          	beqz	a0,ffffffffc0201022 <default_check+0x4f6>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200c6e:	4505                	li	a0,1
ffffffffc0200c70:	1b1000ef          	jal	ra,ffffffffc0201620 <alloc_pages>
ffffffffc0200c74:	8a2a                	mv	s4,a0
ffffffffc0200c76:	38050663          	beqz	a0,ffffffffc0201002 <default_check+0x4d6>
    assert(alloc_page() == NULL);
ffffffffc0200c7a:	4505                	li	a0,1
ffffffffc0200c7c:	1a5000ef          	jal	ra,ffffffffc0201620 <alloc_pages>
ffffffffc0200c80:	36051163          	bnez	a0,ffffffffc0200fe2 <default_check+0x4b6>
    free_page(p0);
ffffffffc0200c84:	4585                	li	a1,1
ffffffffc0200c86:	854e                	mv	a0,s3
ffffffffc0200c88:	22b000ef          	jal	ra,ffffffffc02016b2 <free_pages>
    assert(!list_empty(&free_list));
ffffffffc0200c8c:	641c                	ld	a5,8(s0)
ffffffffc0200c8e:	20878a63          	beq	a5,s0,ffffffffc0200ea2 <default_check+0x376>
    assert((p = alloc_page()) == p0);
ffffffffc0200c92:	4505                	li	a0,1
ffffffffc0200c94:	18d000ef          	jal	ra,ffffffffc0201620 <alloc_pages>
ffffffffc0200c98:	30a99563          	bne	s3,a0,ffffffffc0200fa2 <default_check+0x476>
    assert(alloc_page() == NULL);
ffffffffc0200c9c:	4505                	li	a0,1
ffffffffc0200c9e:	183000ef          	jal	ra,ffffffffc0201620 <alloc_pages>
ffffffffc0200ca2:	2e051063          	bnez	a0,ffffffffc0200f82 <default_check+0x456>
    assert(nr_free == 0);
ffffffffc0200ca6:	481c                	lw	a5,16(s0)
ffffffffc0200ca8:	2a079d63          	bnez	a5,ffffffffc0200f62 <default_check+0x436>
    free_page(p);
ffffffffc0200cac:	854e                	mv	a0,s3
ffffffffc0200cae:	4585                	li	a1,1
    free_list = free_list_store;
ffffffffc0200cb0:	01843023          	sd	s8,0(s0)
ffffffffc0200cb4:	01743423          	sd	s7,8(s0)
    nr_free = nr_free_store;
ffffffffc0200cb8:	01642823          	sw	s6,16(s0)
    free_page(p);
ffffffffc0200cbc:	1f7000ef          	jal	ra,ffffffffc02016b2 <free_pages>
    free_page(p1);
ffffffffc0200cc0:	4585                	li	a1,1
ffffffffc0200cc2:	8556                	mv	a0,s5
ffffffffc0200cc4:	1ef000ef          	jal	ra,ffffffffc02016b2 <free_pages>
    free_page(p2);
ffffffffc0200cc8:	4585                	li	a1,1
ffffffffc0200cca:	8552                	mv	a0,s4
ffffffffc0200ccc:	1e7000ef          	jal	ra,ffffffffc02016b2 <free_pages>

    basic_check();

    struct Page *p0 = alloc_pages(5), *p1, *p2;
ffffffffc0200cd0:	4515                	li	a0,5
ffffffffc0200cd2:	14f000ef          	jal	ra,ffffffffc0201620 <alloc_pages>
ffffffffc0200cd6:	89aa                	mv	s3,a0
    assert(p0 != NULL);
ffffffffc0200cd8:	26050563          	beqz	a0,ffffffffc0200f42 <default_check+0x416>
ffffffffc0200cdc:	651c                	ld	a5,8(a0)
ffffffffc0200cde:	8385                	srli	a5,a5,0x1
    assert(!PageProperty(p0));
ffffffffc0200ce0:	8b85                	andi	a5,a5,1
ffffffffc0200ce2:	54079063          	bnez	a5,ffffffffc0201222 <default_check+0x6f6>

    list_entry_t free_list_store = free_list;
    list_init(&free_list);
    assert(list_empty(&free_list));
    assert(alloc_page() == NULL);
ffffffffc0200ce6:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0200ce8:	00043b03          	ld	s6,0(s0)
ffffffffc0200cec:	00843a83          	ld	s5,8(s0)
ffffffffc0200cf0:	e000                	sd	s0,0(s0)
ffffffffc0200cf2:	e400                	sd	s0,8(s0)
    assert(alloc_page() == NULL);
ffffffffc0200cf4:	12d000ef          	jal	ra,ffffffffc0201620 <alloc_pages>
ffffffffc0200cf8:	50051563          	bnez	a0,ffffffffc0201202 <default_check+0x6d6>

    unsigned int nr_free_store = nr_free;
    nr_free = 0;

    free_pages(p0 + 2, 3);
ffffffffc0200cfc:	09098a13          	addi	s4,s3,144
ffffffffc0200d00:	8552                	mv	a0,s4
ffffffffc0200d02:	458d                	li	a1,3
    unsigned int nr_free_store = nr_free;
ffffffffc0200d04:	01042b83          	lw	s7,16(s0)
    nr_free = 0;
ffffffffc0200d08:	00010797          	auipc	a5,0x10
ffffffffc0200d0c:	3407a423          	sw	zero,840(a5) # ffffffffc0211050 <free_area+0x10>
    free_pages(p0 + 2, 3);
ffffffffc0200d10:	1a3000ef          	jal	ra,ffffffffc02016b2 <free_pages>
    assert(alloc_pages(4) == NULL);
ffffffffc0200d14:	4511                	li	a0,4
ffffffffc0200d16:	10b000ef          	jal	ra,ffffffffc0201620 <alloc_pages>
ffffffffc0200d1a:	4c051463          	bnez	a0,ffffffffc02011e2 <default_check+0x6b6>
ffffffffc0200d1e:	0989b783          	ld	a5,152(s3)
ffffffffc0200d22:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc0200d24:	8b85                	andi	a5,a5,1
ffffffffc0200d26:	48078e63          	beqz	a5,ffffffffc02011c2 <default_check+0x696>
ffffffffc0200d2a:	0a89a703          	lw	a4,168(s3)
ffffffffc0200d2e:	478d                	li	a5,3
ffffffffc0200d30:	48f71963          	bne	a4,a5,ffffffffc02011c2 <default_check+0x696>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc0200d34:	450d                	li	a0,3
ffffffffc0200d36:	0eb000ef          	jal	ra,ffffffffc0201620 <alloc_pages>
ffffffffc0200d3a:	8c2a                	mv	s8,a0
ffffffffc0200d3c:	46050363          	beqz	a0,ffffffffc02011a2 <default_check+0x676>
    assert(alloc_page() == NULL);
ffffffffc0200d40:	4505                	li	a0,1
ffffffffc0200d42:	0df000ef          	jal	ra,ffffffffc0201620 <alloc_pages>
ffffffffc0200d46:	42051e63          	bnez	a0,ffffffffc0201182 <default_check+0x656>
    assert(p0 + 2 == p1);
ffffffffc0200d4a:	418a1c63          	bne	s4,s8,ffffffffc0201162 <default_check+0x636>

    p2 = p0 + 1;
    free_page(p0);
ffffffffc0200d4e:	4585                	li	a1,1
ffffffffc0200d50:	854e                	mv	a0,s3
ffffffffc0200d52:	161000ef          	jal	ra,ffffffffc02016b2 <free_pages>
    free_pages(p1, 3);
ffffffffc0200d56:	458d                	li	a1,3
ffffffffc0200d58:	8552                	mv	a0,s4
ffffffffc0200d5a:	159000ef          	jal	ra,ffffffffc02016b2 <free_pages>
ffffffffc0200d5e:	0089b783          	ld	a5,8(s3)
    p2 = p0 + 1;
ffffffffc0200d62:	04898c13          	addi	s8,s3,72
ffffffffc0200d66:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc0200d68:	8b85                	andi	a5,a5,1
ffffffffc0200d6a:	3c078c63          	beqz	a5,ffffffffc0201142 <default_check+0x616>
ffffffffc0200d6e:	0189a703          	lw	a4,24(s3)
ffffffffc0200d72:	4785                	li	a5,1
ffffffffc0200d74:	3cf71763          	bne	a4,a5,ffffffffc0201142 <default_check+0x616>
ffffffffc0200d78:	008a3783          	ld	a5,8(s4)
ffffffffc0200d7c:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc0200d7e:	8b85                	andi	a5,a5,1
ffffffffc0200d80:	3a078163          	beqz	a5,ffffffffc0201122 <default_check+0x5f6>
ffffffffc0200d84:	018a2703          	lw	a4,24(s4)
ffffffffc0200d88:	478d                	li	a5,3
ffffffffc0200d8a:	38f71c63          	bne	a4,a5,ffffffffc0201122 <default_check+0x5f6>

    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc0200d8e:	4505                	li	a0,1
ffffffffc0200d90:	091000ef          	jal	ra,ffffffffc0201620 <alloc_pages>
ffffffffc0200d94:	36a99763          	bne	s3,a0,ffffffffc0201102 <default_check+0x5d6>
    free_page(p0);
ffffffffc0200d98:	4585                	li	a1,1
ffffffffc0200d9a:	119000ef          	jal	ra,ffffffffc02016b2 <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc0200d9e:	4509                	li	a0,2
ffffffffc0200da0:	081000ef          	jal	ra,ffffffffc0201620 <alloc_pages>
ffffffffc0200da4:	32aa1f63          	bne	s4,a0,ffffffffc02010e2 <default_check+0x5b6>

    free_pages(p0, 2);
ffffffffc0200da8:	4589                	li	a1,2
ffffffffc0200daa:	109000ef          	jal	ra,ffffffffc02016b2 <free_pages>
    free_page(p2);
ffffffffc0200dae:	4585                	li	a1,1
ffffffffc0200db0:	8562                	mv	a0,s8
ffffffffc0200db2:	101000ef          	jal	ra,ffffffffc02016b2 <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0200db6:	4515                	li	a0,5
ffffffffc0200db8:	069000ef          	jal	ra,ffffffffc0201620 <alloc_pages>
ffffffffc0200dbc:	89aa                	mv	s3,a0
ffffffffc0200dbe:	48050263          	beqz	a0,ffffffffc0201242 <default_check+0x716>
    assert(alloc_page() == NULL);
ffffffffc0200dc2:	4505                	li	a0,1
ffffffffc0200dc4:	05d000ef          	jal	ra,ffffffffc0201620 <alloc_pages>
ffffffffc0200dc8:	2c051d63          	bnez	a0,ffffffffc02010a2 <default_check+0x576>

    assert(nr_free == 0);
ffffffffc0200dcc:	481c                	lw	a5,16(s0)
ffffffffc0200dce:	2a079a63          	bnez	a5,ffffffffc0201082 <default_check+0x556>
    nr_free = nr_free_store;

    free_list = free_list_store;
    free_pages(p0, 5);
ffffffffc0200dd2:	4595                	li	a1,5
ffffffffc0200dd4:	854e                	mv	a0,s3
    nr_free = nr_free_store;
ffffffffc0200dd6:	01742823          	sw	s7,16(s0)
    free_list = free_list_store;
ffffffffc0200dda:	01643023          	sd	s6,0(s0)
ffffffffc0200dde:	01543423          	sd	s5,8(s0)
    free_pages(p0, 5);
ffffffffc0200de2:	0d1000ef          	jal	ra,ffffffffc02016b2 <free_pages>
    return listelm->next;
ffffffffc0200de6:	641c                	ld	a5,8(s0)

    le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200de8:	00878963          	beq	a5,s0,ffffffffc0200dfa <default_check+0x2ce>
        struct Page *p = le2page(le, page_link);
        count --, total -= p->property;
ffffffffc0200dec:	ff87a703          	lw	a4,-8(a5)
ffffffffc0200df0:	679c                	ld	a5,8(a5)
ffffffffc0200df2:	397d                	addiw	s2,s2,-1
ffffffffc0200df4:	9c99                	subw	s1,s1,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200df6:	fe879be3          	bne	a5,s0,ffffffffc0200dec <default_check+0x2c0>
    }
    assert(count == 0);
ffffffffc0200dfa:	26091463          	bnez	s2,ffffffffc0201062 <default_check+0x536>
    assert(total == 0);
ffffffffc0200dfe:	46049263          	bnez	s1,ffffffffc0201262 <default_check+0x736>
}
ffffffffc0200e02:	60a6                	ld	ra,72(sp)
ffffffffc0200e04:	6406                	ld	s0,64(sp)
ffffffffc0200e06:	74e2                	ld	s1,56(sp)
ffffffffc0200e08:	7942                	ld	s2,48(sp)
ffffffffc0200e0a:	79a2                	ld	s3,40(sp)
ffffffffc0200e0c:	7a02                	ld	s4,32(sp)
ffffffffc0200e0e:	6ae2                	ld	s5,24(sp)
ffffffffc0200e10:	6b42                	ld	s6,16(sp)
ffffffffc0200e12:	6ba2                	ld	s7,8(sp)
ffffffffc0200e14:	6c02                	ld	s8,0(sp)
ffffffffc0200e16:	6161                	addi	sp,sp,80
ffffffffc0200e18:	8082                	ret
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200e1a:	4981                	li	s3,0
    int count = 0, total = 0;
ffffffffc0200e1c:	4481                	li	s1,0
ffffffffc0200e1e:	4901                	li	s2,0
ffffffffc0200e20:	b3b9                	j	ffffffffc0200b6e <default_check+0x42>
        assert(PageProperty(p));
ffffffffc0200e22:	00004697          	auipc	a3,0x4
ffffffffc0200e26:	02668693          	addi	a3,a3,38 # ffffffffc0204e48 <commands+0x778>
ffffffffc0200e2a:	00004617          	auipc	a2,0x4
ffffffffc0200e2e:	02e60613          	addi	a2,a2,46 # ffffffffc0204e58 <commands+0x788>
ffffffffc0200e32:	0f000593          	li	a1,240
ffffffffc0200e36:	00004517          	auipc	a0,0x4
ffffffffc0200e3a:	03a50513          	addi	a0,a0,58 # ffffffffc0204e70 <commands+0x7a0>
ffffffffc0200e3e:	d36ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0200e42:	00004697          	auipc	a3,0x4
ffffffffc0200e46:	0c668693          	addi	a3,a3,198 # ffffffffc0204f08 <commands+0x838>
ffffffffc0200e4a:	00004617          	auipc	a2,0x4
ffffffffc0200e4e:	00e60613          	addi	a2,a2,14 # ffffffffc0204e58 <commands+0x788>
ffffffffc0200e52:	0bd00593          	li	a1,189
ffffffffc0200e56:	00004517          	auipc	a0,0x4
ffffffffc0200e5a:	01a50513          	addi	a0,a0,26 # ffffffffc0204e70 <commands+0x7a0>
ffffffffc0200e5e:	d16ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0200e62:	00004697          	auipc	a3,0x4
ffffffffc0200e66:	0ce68693          	addi	a3,a3,206 # ffffffffc0204f30 <commands+0x860>
ffffffffc0200e6a:	00004617          	auipc	a2,0x4
ffffffffc0200e6e:	fee60613          	addi	a2,a2,-18 # ffffffffc0204e58 <commands+0x788>
ffffffffc0200e72:	0be00593          	li	a1,190
ffffffffc0200e76:	00004517          	auipc	a0,0x4
ffffffffc0200e7a:	ffa50513          	addi	a0,a0,-6 # ffffffffc0204e70 <commands+0x7a0>
ffffffffc0200e7e:	cf6ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0200e82:	00004697          	auipc	a3,0x4
ffffffffc0200e86:	0ee68693          	addi	a3,a3,238 # ffffffffc0204f70 <commands+0x8a0>
ffffffffc0200e8a:	00004617          	auipc	a2,0x4
ffffffffc0200e8e:	fce60613          	addi	a2,a2,-50 # ffffffffc0204e58 <commands+0x788>
ffffffffc0200e92:	0c000593          	li	a1,192
ffffffffc0200e96:	00004517          	auipc	a0,0x4
ffffffffc0200e9a:	fda50513          	addi	a0,a0,-38 # ffffffffc0204e70 <commands+0x7a0>
ffffffffc0200e9e:	cd6ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(!list_empty(&free_list));
ffffffffc0200ea2:	00004697          	auipc	a3,0x4
ffffffffc0200ea6:	15668693          	addi	a3,a3,342 # ffffffffc0204ff8 <commands+0x928>
ffffffffc0200eaa:	00004617          	auipc	a2,0x4
ffffffffc0200eae:	fae60613          	addi	a2,a2,-82 # ffffffffc0204e58 <commands+0x788>
ffffffffc0200eb2:	0d900593          	li	a1,217
ffffffffc0200eb6:	00004517          	auipc	a0,0x4
ffffffffc0200eba:	fba50513          	addi	a0,a0,-70 # ffffffffc0204e70 <commands+0x7a0>
ffffffffc0200ebe:	cb6ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200ec2:	00004697          	auipc	a3,0x4
ffffffffc0200ec6:	fe668693          	addi	a3,a3,-26 # ffffffffc0204ea8 <commands+0x7d8>
ffffffffc0200eca:	00004617          	auipc	a2,0x4
ffffffffc0200ece:	f8e60613          	addi	a2,a2,-114 # ffffffffc0204e58 <commands+0x788>
ffffffffc0200ed2:	0d200593          	li	a1,210
ffffffffc0200ed6:	00004517          	auipc	a0,0x4
ffffffffc0200eda:	f9a50513          	addi	a0,a0,-102 # ffffffffc0204e70 <commands+0x7a0>
ffffffffc0200ede:	c96ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(nr_free == 3);
ffffffffc0200ee2:	00004697          	auipc	a3,0x4
ffffffffc0200ee6:	10668693          	addi	a3,a3,262 # ffffffffc0204fe8 <commands+0x918>
ffffffffc0200eea:	00004617          	auipc	a2,0x4
ffffffffc0200eee:	f6e60613          	addi	a2,a2,-146 # ffffffffc0204e58 <commands+0x788>
ffffffffc0200ef2:	0d000593          	li	a1,208
ffffffffc0200ef6:	00004517          	auipc	a0,0x4
ffffffffc0200efa:	f7a50513          	addi	a0,a0,-134 # ffffffffc0204e70 <commands+0x7a0>
ffffffffc0200efe:	c76ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200f02:	00004697          	auipc	a3,0x4
ffffffffc0200f06:	0ce68693          	addi	a3,a3,206 # ffffffffc0204fd0 <commands+0x900>
ffffffffc0200f0a:	00004617          	auipc	a2,0x4
ffffffffc0200f0e:	f4e60613          	addi	a2,a2,-178 # ffffffffc0204e58 <commands+0x788>
ffffffffc0200f12:	0cb00593          	li	a1,203
ffffffffc0200f16:	00004517          	auipc	a0,0x4
ffffffffc0200f1a:	f5a50513          	addi	a0,a0,-166 # ffffffffc0204e70 <commands+0x7a0>
ffffffffc0200f1e:	c56ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0200f22:	00004697          	auipc	a3,0x4
ffffffffc0200f26:	08e68693          	addi	a3,a3,142 # ffffffffc0204fb0 <commands+0x8e0>
ffffffffc0200f2a:	00004617          	auipc	a2,0x4
ffffffffc0200f2e:	f2e60613          	addi	a2,a2,-210 # ffffffffc0204e58 <commands+0x788>
ffffffffc0200f32:	0c200593          	li	a1,194
ffffffffc0200f36:	00004517          	auipc	a0,0x4
ffffffffc0200f3a:	f3a50513          	addi	a0,a0,-198 # ffffffffc0204e70 <commands+0x7a0>
ffffffffc0200f3e:	c36ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(p0 != NULL);
ffffffffc0200f42:	00004697          	auipc	a3,0x4
ffffffffc0200f46:	0fe68693          	addi	a3,a3,254 # ffffffffc0205040 <commands+0x970>
ffffffffc0200f4a:	00004617          	auipc	a2,0x4
ffffffffc0200f4e:	f0e60613          	addi	a2,a2,-242 # ffffffffc0204e58 <commands+0x788>
ffffffffc0200f52:	0f800593          	li	a1,248
ffffffffc0200f56:	00004517          	auipc	a0,0x4
ffffffffc0200f5a:	f1a50513          	addi	a0,a0,-230 # ffffffffc0204e70 <commands+0x7a0>
ffffffffc0200f5e:	c16ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(nr_free == 0);
ffffffffc0200f62:	00004697          	auipc	a3,0x4
ffffffffc0200f66:	0ce68693          	addi	a3,a3,206 # ffffffffc0205030 <commands+0x960>
ffffffffc0200f6a:	00004617          	auipc	a2,0x4
ffffffffc0200f6e:	eee60613          	addi	a2,a2,-274 # ffffffffc0204e58 <commands+0x788>
ffffffffc0200f72:	0df00593          	li	a1,223
ffffffffc0200f76:	00004517          	auipc	a0,0x4
ffffffffc0200f7a:	efa50513          	addi	a0,a0,-262 # ffffffffc0204e70 <commands+0x7a0>
ffffffffc0200f7e:	bf6ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200f82:	00004697          	auipc	a3,0x4
ffffffffc0200f86:	04e68693          	addi	a3,a3,78 # ffffffffc0204fd0 <commands+0x900>
ffffffffc0200f8a:	00004617          	auipc	a2,0x4
ffffffffc0200f8e:	ece60613          	addi	a2,a2,-306 # ffffffffc0204e58 <commands+0x788>
ffffffffc0200f92:	0dd00593          	li	a1,221
ffffffffc0200f96:	00004517          	auipc	a0,0x4
ffffffffc0200f9a:	eda50513          	addi	a0,a0,-294 # ffffffffc0204e70 <commands+0x7a0>
ffffffffc0200f9e:	bd6ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert((p = alloc_page()) == p0);
ffffffffc0200fa2:	00004697          	auipc	a3,0x4
ffffffffc0200fa6:	06e68693          	addi	a3,a3,110 # ffffffffc0205010 <commands+0x940>
ffffffffc0200faa:	00004617          	auipc	a2,0x4
ffffffffc0200fae:	eae60613          	addi	a2,a2,-338 # ffffffffc0204e58 <commands+0x788>
ffffffffc0200fb2:	0dc00593          	li	a1,220
ffffffffc0200fb6:	00004517          	auipc	a0,0x4
ffffffffc0200fba:	eba50513          	addi	a0,a0,-326 # ffffffffc0204e70 <commands+0x7a0>
ffffffffc0200fbe:	bb6ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200fc2:	00004697          	auipc	a3,0x4
ffffffffc0200fc6:	ee668693          	addi	a3,a3,-282 # ffffffffc0204ea8 <commands+0x7d8>
ffffffffc0200fca:	00004617          	auipc	a2,0x4
ffffffffc0200fce:	e8e60613          	addi	a2,a2,-370 # ffffffffc0204e58 <commands+0x788>
ffffffffc0200fd2:	0b900593          	li	a1,185
ffffffffc0200fd6:	00004517          	auipc	a0,0x4
ffffffffc0200fda:	e9a50513          	addi	a0,a0,-358 # ffffffffc0204e70 <commands+0x7a0>
ffffffffc0200fde:	b96ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200fe2:	00004697          	auipc	a3,0x4
ffffffffc0200fe6:	fee68693          	addi	a3,a3,-18 # ffffffffc0204fd0 <commands+0x900>
ffffffffc0200fea:	00004617          	auipc	a2,0x4
ffffffffc0200fee:	e6e60613          	addi	a2,a2,-402 # ffffffffc0204e58 <commands+0x788>
ffffffffc0200ff2:	0d600593          	li	a1,214
ffffffffc0200ff6:	00004517          	auipc	a0,0x4
ffffffffc0200ffa:	e7a50513          	addi	a0,a0,-390 # ffffffffc0204e70 <commands+0x7a0>
ffffffffc0200ffe:	b76ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0201002:	00004697          	auipc	a3,0x4
ffffffffc0201006:	ee668693          	addi	a3,a3,-282 # ffffffffc0204ee8 <commands+0x818>
ffffffffc020100a:	00004617          	auipc	a2,0x4
ffffffffc020100e:	e4e60613          	addi	a2,a2,-434 # ffffffffc0204e58 <commands+0x788>
ffffffffc0201012:	0d400593          	li	a1,212
ffffffffc0201016:	00004517          	auipc	a0,0x4
ffffffffc020101a:	e5a50513          	addi	a0,a0,-422 # ffffffffc0204e70 <commands+0x7a0>
ffffffffc020101e:	b56ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0201022:	00004697          	auipc	a3,0x4
ffffffffc0201026:	ea668693          	addi	a3,a3,-346 # ffffffffc0204ec8 <commands+0x7f8>
ffffffffc020102a:	00004617          	auipc	a2,0x4
ffffffffc020102e:	e2e60613          	addi	a2,a2,-466 # ffffffffc0204e58 <commands+0x788>
ffffffffc0201032:	0d300593          	li	a1,211
ffffffffc0201036:	00004517          	auipc	a0,0x4
ffffffffc020103a:	e3a50513          	addi	a0,a0,-454 # ffffffffc0204e70 <commands+0x7a0>
ffffffffc020103e:	b36ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0201042:	00004697          	auipc	a3,0x4
ffffffffc0201046:	ea668693          	addi	a3,a3,-346 # ffffffffc0204ee8 <commands+0x818>
ffffffffc020104a:	00004617          	auipc	a2,0x4
ffffffffc020104e:	e0e60613          	addi	a2,a2,-498 # ffffffffc0204e58 <commands+0x788>
ffffffffc0201052:	0bb00593          	li	a1,187
ffffffffc0201056:	00004517          	auipc	a0,0x4
ffffffffc020105a:	e1a50513          	addi	a0,a0,-486 # ffffffffc0204e70 <commands+0x7a0>
ffffffffc020105e:	b16ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(count == 0);
ffffffffc0201062:	00004697          	auipc	a3,0x4
ffffffffc0201066:	12e68693          	addi	a3,a3,302 # ffffffffc0205190 <commands+0xac0>
ffffffffc020106a:	00004617          	auipc	a2,0x4
ffffffffc020106e:	dee60613          	addi	a2,a2,-530 # ffffffffc0204e58 <commands+0x788>
ffffffffc0201072:	12500593          	li	a1,293
ffffffffc0201076:	00004517          	auipc	a0,0x4
ffffffffc020107a:	dfa50513          	addi	a0,a0,-518 # ffffffffc0204e70 <commands+0x7a0>
ffffffffc020107e:	af6ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(nr_free == 0);
ffffffffc0201082:	00004697          	auipc	a3,0x4
ffffffffc0201086:	fae68693          	addi	a3,a3,-82 # ffffffffc0205030 <commands+0x960>
ffffffffc020108a:	00004617          	auipc	a2,0x4
ffffffffc020108e:	dce60613          	addi	a2,a2,-562 # ffffffffc0204e58 <commands+0x788>
ffffffffc0201092:	11a00593          	li	a1,282
ffffffffc0201096:	00004517          	auipc	a0,0x4
ffffffffc020109a:	dda50513          	addi	a0,a0,-550 # ffffffffc0204e70 <commands+0x7a0>
ffffffffc020109e:	ad6ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(alloc_page() == NULL);
ffffffffc02010a2:	00004697          	auipc	a3,0x4
ffffffffc02010a6:	f2e68693          	addi	a3,a3,-210 # ffffffffc0204fd0 <commands+0x900>
ffffffffc02010aa:	00004617          	auipc	a2,0x4
ffffffffc02010ae:	dae60613          	addi	a2,a2,-594 # ffffffffc0204e58 <commands+0x788>
ffffffffc02010b2:	11800593          	li	a1,280
ffffffffc02010b6:	00004517          	auipc	a0,0x4
ffffffffc02010ba:	dba50513          	addi	a0,a0,-582 # ffffffffc0204e70 <commands+0x7a0>
ffffffffc02010be:	ab6ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc02010c2:	00004697          	auipc	a3,0x4
ffffffffc02010c6:	ece68693          	addi	a3,a3,-306 # ffffffffc0204f90 <commands+0x8c0>
ffffffffc02010ca:	00004617          	auipc	a2,0x4
ffffffffc02010ce:	d8e60613          	addi	a2,a2,-626 # ffffffffc0204e58 <commands+0x788>
ffffffffc02010d2:	0c100593          	li	a1,193
ffffffffc02010d6:	00004517          	auipc	a0,0x4
ffffffffc02010da:	d9a50513          	addi	a0,a0,-614 # ffffffffc0204e70 <commands+0x7a0>
ffffffffc02010de:	a96ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc02010e2:	00004697          	auipc	a3,0x4
ffffffffc02010e6:	06e68693          	addi	a3,a3,110 # ffffffffc0205150 <commands+0xa80>
ffffffffc02010ea:	00004617          	auipc	a2,0x4
ffffffffc02010ee:	d6e60613          	addi	a2,a2,-658 # ffffffffc0204e58 <commands+0x788>
ffffffffc02010f2:	11200593          	li	a1,274
ffffffffc02010f6:	00004517          	auipc	a0,0x4
ffffffffc02010fa:	d7a50513          	addi	a0,a0,-646 # ffffffffc0204e70 <commands+0x7a0>
ffffffffc02010fe:	a76ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc0201102:	00004697          	auipc	a3,0x4
ffffffffc0201106:	02e68693          	addi	a3,a3,46 # ffffffffc0205130 <commands+0xa60>
ffffffffc020110a:	00004617          	auipc	a2,0x4
ffffffffc020110e:	d4e60613          	addi	a2,a2,-690 # ffffffffc0204e58 <commands+0x788>
ffffffffc0201112:	11000593          	li	a1,272
ffffffffc0201116:	00004517          	auipc	a0,0x4
ffffffffc020111a:	d5a50513          	addi	a0,a0,-678 # ffffffffc0204e70 <commands+0x7a0>
ffffffffc020111e:	a56ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc0201122:	00004697          	auipc	a3,0x4
ffffffffc0201126:	fe668693          	addi	a3,a3,-26 # ffffffffc0205108 <commands+0xa38>
ffffffffc020112a:	00004617          	auipc	a2,0x4
ffffffffc020112e:	d2e60613          	addi	a2,a2,-722 # ffffffffc0204e58 <commands+0x788>
ffffffffc0201132:	10e00593          	li	a1,270
ffffffffc0201136:	00004517          	auipc	a0,0x4
ffffffffc020113a:	d3a50513          	addi	a0,a0,-710 # ffffffffc0204e70 <commands+0x7a0>
ffffffffc020113e:	a36ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc0201142:	00004697          	auipc	a3,0x4
ffffffffc0201146:	f9e68693          	addi	a3,a3,-98 # ffffffffc02050e0 <commands+0xa10>
ffffffffc020114a:	00004617          	auipc	a2,0x4
ffffffffc020114e:	d0e60613          	addi	a2,a2,-754 # ffffffffc0204e58 <commands+0x788>
ffffffffc0201152:	10d00593          	li	a1,269
ffffffffc0201156:	00004517          	auipc	a0,0x4
ffffffffc020115a:	d1a50513          	addi	a0,a0,-742 # ffffffffc0204e70 <commands+0x7a0>
ffffffffc020115e:	a16ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(p0 + 2 == p1);
ffffffffc0201162:	00004697          	auipc	a3,0x4
ffffffffc0201166:	f6e68693          	addi	a3,a3,-146 # ffffffffc02050d0 <commands+0xa00>
ffffffffc020116a:	00004617          	auipc	a2,0x4
ffffffffc020116e:	cee60613          	addi	a2,a2,-786 # ffffffffc0204e58 <commands+0x788>
ffffffffc0201172:	10800593          	li	a1,264
ffffffffc0201176:	00004517          	auipc	a0,0x4
ffffffffc020117a:	cfa50513          	addi	a0,a0,-774 # ffffffffc0204e70 <commands+0x7a0>
ffffffffc020117e:	9f6ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201182:	00004697          	auipc	a3,0x4
ffffffffc0201186:	e4e68693          	addi	a3,a3,-434 # ffffffffc0204fd0 <commands+0x900>
ffffffffc020118a:	00004617          	auipc	a2,0x4
ffffffffc020118e:	cce60613          	addi	a2,a2,-818 # ffffffffc0204e58 <commands+0x788>
ffffffffc0201192:	10700593          	li	a1,263
ffffffffc0201196:	00004517          	auipc	a0,0x4
ffffffffc020119a:	cda50513          	addi	a0,a0,-806 # ffffffffc0204e70 <commands+0x7a0>
ffffffffc020119e:	9d6ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc02011a2:	00004697          	auipc	a3,0x4
ffffffffc02011a6:	f0e68693          	addi	a3,a3,-242 # ffffffffc02050b0 <commands+0x9e0>
ffffffffc02011aa:	00004617          	auipc	a2,0x4
ffffffffc02011ae:	cae60613          	addi	a2,a2,-850 # ffffffffc0204e58 <commands+0x788>
ffffffffc02011b2:	10600593          	li	a1,262
ffffffffc02011b6:	00004517          	auipc	a0,0x4
ffffffffc02011ba:	cba50513          	addi	a0,a0,-838 # ffffffffc0204e70 <commands+0x7a0>
ffffffffc02011be:	9b6ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc02011c2:	00004697          	auipc	a3,0x4
ffffffffc02011c6:	ebe68693          	addi	a3,a3,-322 # ffffffffc0205080 <commands+0x9b0>
ffffffffc02011ca:	00004617          	auipc	a2,0x4
ffffffffc02011ce:	c8e60613          	addi	a2,a2,-882 # ffffffffc0204e58 <commands+0x788>
ffffffffc02011d2:	10500593          	li	a1,261
ffffffffc02011d6:	00004517          	auipc	a0,0x4
ffffffffc02011da:	c9a50513          	addi	a0,a0,-870 # ffffffffc0204e70 <commands+0x7a0>
ffffffffc02011de:	996ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(alloc_pages(4) == NULL);
ffffffffc02011e2:	00004697          	auipc	a3,0x4
ffffffffc02011e6:	e8668693          	addi	a3,a3,-378 # ffffffffc0205068 <commands+0x998>
ffffffffc02011ea:	00004617          	auipc	a2,0x4
ffffffffc02011ee:	c6e60613          	addi	a2,a2,-914 # ffffffffc0204e58 <commands+0x788>
ffffffffc02011f2:	10400593          	li	a1,260
ffffffffc02011f6:	00004517          	auipc	a0,0x4
ffffffffc02011fa:	c7a50513          	addi	a0,a0,-902 # ffffffffc0204e70 <commands+0x7a0>
ffffffffc02011fe:	976ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201202:	00004697          	auipc	a3,0x4
ffffffffc0201206:	dce68693          	addi	a3,a3,-562 # ffffffffc0204fd0 <commands+0x900>
ffffffffc020120a:	00004617          	auipc	a2,0x4
ffffffffc020120e:	c4e60613          	addi	a2,a2,-946 # ffffffffc0204e58 <commands+0x788>
ffffffffc0201212:	0fe00593          	li	a1,254
ffffffffc0201216:	00004517          	auipc	a0,0x4
ffffffffc020121a:	c5a50513          	addi	a0,a0,-934 # ffffffffc0204e70 <commands+0x7a0>
ffffffffc020121e:	956ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(!PageProperty(p0));
ffffffffc0201222:	00004697          	auipc	a3,0x4
ffffffffc0201226:	e2e68693          	addi	a3,a3,-466 # ffffffffc0205050 <commands+0x980>
ffffffffc020122a:	00004617          	auipc	a2,0x4
ffffffffc020122e:	c2e60613          	addi	a2,a2,-978 # ffffffffc0204e58 <commands+0x788>
ffffffffc0201232:	0f900593          	li	a1,249
ffffffffc0201236:	00004517          	auipc	a0,0x4
ffffffffc020123a:	c3a50513          	addi	a0,a0,-966 # ffffffffc0204e70 <commands+0x7a0>
ffffffffc020123e:	936ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0201242:	00004697          	auipc	a3,0x4
ffffffffc0201246:	f2e68693          	addi	a3,a3,-210 # ffffffffc0205170 <commands+0xaa0>
ffffffffc020124a:	00004617          	auipc	a2,0x4
ffffffffc020124e:	c0e60613          	addi	a2,a2,-1010 # ffffffffc0204e58 <commands+0x788>
ffffffffc0201252:	11700593          	li	a1,279
ffffffffc0201256:	00004517          	auipc	a0,0x4
ffffffffc020125a:	c1a50513          	addi	a0,a0,-998 # ffffffffc0204e70 <commands+0x7a0>
ffffffffc020125e:	916ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(total == 0);
ffffffffc0201262:	00004697          	auipc	a3,0x4
ffffffffc0201266:	f3e68693          	addi	a3,a3,-194 # ffffffffc02051a0 <commands+0xad0>
ffffffffc020126a:	00004617          	auipc	a2,0x4
ffffffffc020126e:	bee60613          	addi	a2,a2,-1042 # ffffffffc0204e58 <commands+0x788>
ffffffffc0201272:	12600593          	li	a1,294
ffffffffc0201276:	00004517          	auipc	a0,0x4
ffffffffc020127a:	bfa50513          	addi	a0,a0,-1030 # ffffffffc0204e70 <commands+0x7a0>
ffffffffc020127e:	8f6ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(total == nr_free_pages());
ffffffffc0201282:	00004697          	auipc	a3,0x4
ffffffffc0201286:	c0668693          	addi	a3,a3,-1018 # ffffffffc0204e88 <commands+0x7b8>
ffffffffc020128a:	00004617          	auipc	a2,0x4
ffffffffc020128e:	bce60613          	addi	a2,a2,-1074 # ffffffffc0204e58 <commands+0x788>
ffffffffc0201292:	0f300593          	li	a1,243
ffffffffc0201296:	00004517          	auipc	a0,0x4
ffffffffc020129a:	bda50513          	addi	a0,a0,-1062 # ffffffffc0204e70 <commands+0x7a0>
ffffffffc020129e:	8d6ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc02012a2:	00004697          	auipc	a3,0x4
ffffffffc02012a6:	c2668693          	addi	a3,a3,-986 # ffffffffc0204ec8 <commands+0x7f8>
ffffffffc02012aa:	00004617          	auipc	a2,0x4
ffffffffc02012ae:	bae60613          	addi	a2,a2,-1106 # ffffffffc0204e58 <commands+0x788>
ffffffffc02012b2:	0ba00593          	li	a1,186
ffffffffc02012b6:	00004517          	auipc	a0,0x4
ffffffffc02012ba:	bba50513          	addi	a0,a0,-1094 # ffffffffc0204e70 <commands+0x7a0>
ffffffffc02012be:	8b6ff0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc02012c2 <default_free_pages>:
default_free_pages(struct Page *base, size_t n) {
ffffffffc02012c2:	1141                	addi	sp,sp,-16
ffffffffc02012c4:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc02012c6:	14058a63          	beqz	a1,ffffffffc020141a <default_free_pages+0x158>
    for (; p != base + n; p ++) {
ffffffffc02012ca:	00359693          	slli	a3,a1,0x3
ffffffffc02012ce:	96ae                	add	a3,a3,a1
ffffffffc02012d0:	068e                	slli	a3,a3,0x3
ffffffffc02012d2:	96aa                	add	a3,a3,a0
ffffffffc02012d4:	87aa                	mv	a5,a0
ffffffffc02012d6:	02d50263          	beq	a0,a3,ffffffffc02012fa <default_free_pages+0x38>
ffffffffc02012da:	6798                	ld	a4,8(a5)
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc02012dc:	8b05                	andi	a4,a4,1
ffffffffc02012de:	10071e63          	bnez	a4,ffffffffc02013fa <default_free_pages+0x138>
ffffffffc02012e2:	6798                	ld	a4,8(a5)
ffffffffc02012e4:	8b09                	andi	a4,a4,2
ffffffffc02012e6:	10071a63          	bnez	a4,ffffffffc02013fa <default_free_pages+0x138>
        p->flags = 0;
ffffffffc02012ea:	0007b423          	sd	zero,8(a5)
    return pa2page(PDE_ADDR(pde));
}

static inline int page_ref(struct Page *page) { return page->ref; }

static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc02012ee:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc02012f2:	04878793          	addi	a5,a5,72
ffffffffc02012f6:	fed792e3          	bne	a5,a3,ffffffffc02012da <default_free_pages+0x18>
    base->property = n;
ffffffffc02012fa:	2581                	sext.w	a1,a1
ffffffffc02012fc:	cd0c                	sw	a1,24(a0)
    SetPageProperty(base);
ffffffffc02012fe:	00850893          	addi	a7,a0,8
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0201302:	4789                	li	a5,2
ffffffffc0201304:	40f8b02f          	amoor.d	zero,a5,(a7)
    nr_free += n;
ffffffffc0201308:	00010697          	auipc	a3,0x10
ffffffffc020130c:	d3868693          	addi	a3,a3,-712 # ffffffffc0211040 <free_area>
ffffffffc0201310:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc0201312:	669c                	ld	a5,8(a3)
        list_add(&free_list, &(base->page_link));
ffffffffc0201314:	02050613          	addi	a2,a0,32
    nr_free += n;
ffffffffc0201318:	9db9                	addw	a1,a1,a4
ffffffffc020131a:	ca8c                	sw	a1,16(a3)
    if (list_empty(&free_list)) {
ffffffffc020131c:	0ad78863          	beq	a5,a3,ffffffffc02013cc <default_free_pages+0x10a>
            struct Page* page = le2page(le, page_link);
ffffffffc0201320:	fe078713          	addi	a4,a5,-32
ffffffffc0201324:	0006b803          	ld	a6,0(a3)
    if (list_empty(&free_list)) {
ffffffffc0201328:	4581                	li	a1,0
            if (base < page) {
ffffffffc020132a:	00e56a63          	bltu	a0,a4,ffffffffc020133e <default_free_pages+0x7c>
    return listelm->next;
ffffffffc020132e:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc0201330:	06d70263          	beq	a4,a3,ffffffffc0201394 <default_free_pages+0xd2>
    for (; p != base + n; p ++) {
ffffffffc0201334:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc0201336:	fe078713          	addi	a4,a5,-32
            if (base < page) {
ffffffffc020133a:	fee57ae3          	bgeu	a0,a4,ffffffffc020132e <default_free_pages+0x6c>
ffffffffc020133e:	c199                	beqz	a1,ffffffffc0201344 <default_free_pages+0x82>
ffffffffc0201340:	0106b023          	sd	a6,0(a3)
    __list_add(elm, listelm->prev, listelm);
ffffffffc0201344:	6398                	ld	a4,0(a5)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
ffffffffc0201346:	e390                	sd	a2,0(a5)
ffffffffc0201348:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc020134a:	f51c                	sd	a5,40(a0)
    elm->prev = prev;
ffffffffc020134c:	f118                	sd	a4,32(a0)
    if (le != &free_list) {
ffffffffc020134e:	02d70063          	beq	a4,a3,ffffffffc020136e <default_free_pages+0xac>
        if (p + p->property == base) {
ffffffffc0201352:	ff872803          	lw	a6,-8(a4)
        p = le2page(le, page_link);
ffffffffc0201356:	fe070593          	addi	a1,a4,-32
        if (p + p->property == base) {
ffffffffc020135a:	02081613          	slli	a2,a6,0x20
ffffffffc020135e:	9201                	srli	a2,a2,0x20
ffffffffc0201360:	00361793          	slli	a5,a2,0x3
ffffffffc0201364:	97b2                	add	a5,a5,a2
ffffffffc0201366:	078e                	slli	a5,a5,0x3
ffffffffc0201368:	97ae                	add	a5,a5,a1
ffffffffc020136a:	02f50f63          	beq	a0,a5,ffffffffc02013a8 <default_free_pages+0xe6>
    return listelm->next;
ffffffffc020136e:	7518                	ld	a4,40(a0)
    if (le != &free_list) {
ffffffffc0201370:	00d70f63          	beq	a4,a3,ffffffffc020138e <default_free_pages+0xcc>
        if (base + base->property == p) {
ffffffffc0201374:	4d0c                	lw	a1,24(a0)
        p = le2page(le, page_link);
ffffffffc0201376:	fe070693          	addi	a3,a4,-32
        if (base + base->property == p) {
ffffffffc020137a:	02059613          	slli	a2,a1,0x20
ffffffffc020137e:	9201                	srli	a2,a2,0x20
ffffffffc0201380:	00361793          	slli	a5,a2,0x3
ffffffffc0201384:	97b2                	add	a5,a5,a2
ffffffffc0201386:	078e                	slli	a5,a5,0x3
ffffffffc0201388:	97aa                	add	a5,a5,a0
ffffffffc020138a:	04f68863          	beq	a3,a5,ffffffffc02013da <default_free_pages+0x118>
}
ffffffffc020138e:	60a2                	ld	ra,8(sp)
ffffffffc0201390:	0141                	addi	sp,sp,16
ffffffffc0201392:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc0201394:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0201396:	f514                	sd	a3,40(a0)
    return listelm->next;
ffffffffc0201398:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc020139a:	f11c                	sd	a5,32(a0)
        while ((le = list_next(le)) != &free_list) {
ffffffffc020139c:	02d70563          	beq	a4,a3,ffffffffc02013c6 <default_free_pages+0x104>
    prev->next = next->prev = elm;
ffffffffc02013a0:	8832                	mv	a6,a2
ffffffffc02013a2:	4585                	li	a1,1
    for (; p != base + n; p ++) {
ffffffffc02013a4:	87ba                	mv	a5,a4
ffffffffc02013a6:	bf41                	j	ffffffffc0201336 <default_free_pages+0x74>
            p->property += base->property;
ffffffffc02013a8:	4d1c                	lw	a5,24(a0)
ffffffffc02013aa:	0107883b          	addw	a6,a5,a6
ffffffffc02013ae:	ff072c23          	sw	a6,-8(a4)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc02013b2:	57f5                	li	a5,-3
ffffffffc02013b4:	60f8b02f          	amoand.d	zero,a5,(a7)
    __list_del(listelm->prev, listelm->next);
ffffffffc02013b8:	7110                	ld	a2,32(a0)
ffffffffc02013ba:	751c                	ld	a5,40(a0)
            base = p;
ffffffffc02013bc:	852e                	mv	a0,a1
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
ffffffffc02013be:	e61c                	sd	a5,8(a2)
    return listelm->next;
ffffffffc02013c0:	6718                	ld	a4,8(a4)
    next->prev = prev;
ffffffffc02013c2:	e390                	sd	a2,0(a5)
ffffffffc02013c4:	b775                	j	ffffffffc0201370 <default_free_pages+0xae>
ffffffffc02013c6:	e290                	sd	a2,0(a3)
        while ((le = list_next(le)) != &free_list) {
ffffffffc02013c8:	873e                	mv	a4,a5
ffffffffc02013ca:	b761                	j	ffffffffc0201352 <default_free_pages+0x90>
}
ffffffffc02013cc:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc02013ce:	e390                	sd	a2,0(a5)
ffffffffc02013d0:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc02013d2:	f51c                	sd	a5,40(a0)
    elm->prev = prev;
ffffffffc02013d4:	f11c                	sd	a5,32(a0)
ffffffffc02013d6:	0141                	addi	sp,sp,16
ffffffffc02013d8:	8082                	ret
            base->property += p->property;
ffffffffc02013da:	ff872783          	lw	a5,-8(a4)
ffffffffc02013de:	fe870693          	addi	a3,a4,-24
ffffffffc02013e2:	9dbd                	addw	a1,a1,a5
ffffffffc02013e4:	cd0c                	sw	a1,24(a0)
ffffffffc02013e6:	57f5                	li	a5,-3
ffffffffc02013e8:	60f6b02f          	amoand.d	zero,a5,(a3)
    __list_del(listelm->prev, listelm->next);
ffffffffc02013ec:	6314                	ld	a3,0(a4)
ffffffffc02013ee:	671c                	ld	a5,8(a4)
}
ffffffffc02013f0:	60a2                	ld	ra,8(sp)
    prev->next = next;
ffffffffc02013f2:	e69c                	sd	a5,8(a3)
    next->prev = prev;
ffffffffc02013f4:	e394                	sd	a3,0(a5)
ffffffffc02013f6:	0141                	addi	sp,sp,16
ffffffffc02013f8:	8082                	ret
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc02013fa:	00004697          	auipc	a3,0x4
ffffffffc02013fe:	dbe68693          	addi	a3,a3,-578 # ffffffffc02051b8 <commands+0xae8>
ffffffffc0201402:	00004617          	auipc	a2,0x4
ffffffffc0201406:	a5660613          	addi	a2,a2,-1450 # ffffffffc0204e58 <commands+0x788>
ffffffffc020140a:	08300593          	li	a1,131
ffffffffc020140e:	00004517          	auipc	a0,0x4
ffffffffc0201412:	a6250513          	addi	a0,a0,-1438 # ffffffffc0204e70 <commands+0x7a0>
ffffffffc0201416:	f5ffe0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(n > 0);
ffffffffc020141a:	00004697          	auipc	a3,0x4
ffffffffc020141e:	d9668693          	addi	a3,a3,-618 # ffffffffc02051b0 <commands+0xae0>
ffffffffc0201422:	00004617          	auipc	a2,0x4
ffffffffc0201426:	a3660613          	addi	a2,a2,-1482 # ffffffffc0204e58 <commands+0x788>
ffffffffc020142a:	08000593          	li	a1,128
ffffffffc020142e:	00004517          	auipc	a0,0x4
ffffffffc0201432:	a4250513          	addi	a0,a0,-1470 # ffffffffc0204e70 <commands+0x7a0>
ffffffffc0201436:	f3ffe0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc020143a <default_alloc_pages>:
    assert(n > 0);
ffffffffc020143a:	c959                	beqz	a0,ffffffffc02014d0 <default_alloc_pages+0x96>
    if (n > nr_free) {
ffffffffc020143c:	00010597          	auipc	a1,0x10
ffffffffc0201440:	c0458593          	addi	a1,a1,-1020 # ffffffffc0211040 <free_area>
ffffffffc0201444:	0105a803          	lw	a6,16(a1)
ffffffffc0201448:	862a                	mv	a2,a0
ffffffffc020144a:	02081793          	slli	a5,a6,0x20
ffffffffc020144e:	9381                	srli	a5,a5,0x20
ffffffffc0201450:	00a7ee63          	bltu	a5,a0,ffffffffc020146c <default_alloc_pages+0x32>
    list_entry_t *le = &free_list;
ffffffffc0201454:	87ae                	mv	a5,a1
ffffffffc0201456:	a801                	j	ffffffffc0201466 <default_alloc_pages+0x2c>
        if (p->property >= n) {
ffffffffc0201458:	ff87a703          	lw	a4,-8(a5)
ffffffffc020145c:	02071693          	slli	a3,a4,0x20
ffffffffc0201460:	9281                	srli	a3,a3,0x20
ffffffffc0201462:	00c6f763          	bgeu	a3,a2,ffffffffc0201470 <default_alloc_pages+0x36>
    return listelm->next;
ffffffffc0201466:	679c                	ld	a5,8(a5)
    while ((le = list_next(le)) != &free_list) {
ffffffffc0201468:	feb798e3          	bne	a5,a1,ffffffffc0201458 <default_alloc_pages+0x1e>
        return NULL;
ffffffffc020146c:	4501                	li	a0,0
}
ffffffffc020146e:	8082                	ret
    return listelm->prev;
ffffffffc0201470:	0007b883          	ld	a7,0(a5)
    __list_del(listelm->prev, listelm->next);
ffffffffc0201474:	0087b303          	ld	t1,8(a5)
        struct Page *p = le2page(le, page_link);
ffffffffc0201478:	fe078513          	addi	a0,a5,-32
            p->property = page->property - n;
ffffffffc020147c:	00060e1b          	sext.w	t3,a2
    prev->next = next;
ffffffffc0201480:	0068b423          	sd	t1,8(a7)
    next->prev = prev;
ffffffffc0201484:	01133023          	sd	a7,0(t1)
        if (page->property > n) {
ffffffffc0201488:	02d67b63          	bgeu	a2,a3,ffffffffc02014be <default_alloc_pages+0x84>
            struct Page *p = page + n;
ffffffffc020148c:	00361693          	slli	a3,a2,0x3
ffffffffc0201490:	96b2                	add	a3,a3,a2
ffffffffc0201492:	068e                	slli	a3,a3,0x3
ffffffffc0201494:	96aa                	add	a3,a3,a0
            p->property = page->property - n;
ffffffffc0201496:	41c7073b          	subw	a4,a4,t3
ffffffffc020149a:	ce98                	sw	a4,24(a3)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc020149c:	00868613          	addi	a2,a3,8
ffffffffc02014a0:	4709                	li	a4,2
ffffffffc02014a2:	40e6302f          	amoor.d	zero,a4,(a2)
    __list_add(elm, listelm, listelm->next);
ffffffffc02014a6:	0088b703          	ld	a4,8(a7)
            list_add(prev, &(p->page_link));
ffffffffc02014aa:	02068613          	addi	a2,a3,32
        nr_free -= n;
ffffffffc02014ae:	0105a803          	lw	a6,16(a1)
    prev->next = next->prev = elm;
ffffffffc02014b2:	e310                	sd	a2,0(a4)
ffffffffc02014b4:	00c8b423          	sd	a2,8(a7)
    elm->next = next;
ffffffffc02014b8:	f698                	sd	a4,40(a3)
    elm->prev = prev;
ffffffffc02014ba:	0316b023          	sd	a7,32(a3)
ffffffffc02014be:	41c8083b          	subw	a6,a6,t3
ffffffffc02014c2:	0105a823          	sw	a6,16(a1)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc02014c6:	5775                	li	a4,-3
ffffffffc02014c8:	17a1                	addi	a5,a5,-24
ffffffffc02014ca:	60e7b02f          	amoand.d	zero,a4,(a5)
}
ffffffffc02014ce:	8082                	ret
default_alloc_pages(size_t n) {
ffffffffc02014d0:	1141                	addi	sp,sp,-16
    assert(n > 0);
ffffffffc02014d2:	00004697          	auipc	a3,0x4
ffffffffc02014d6:	cde68693          	addi	a3,a3,-802 # ffffffffc02051b0 <commands+0xae0>
ffffffffc02014da:	00004617          	auipc	a2,0x4
ffffffffc02014de:	97e60613          	addi	a2,a2,-1666 # ffffffffc0204e58 <commands+0x788>
ffffffffc02014e2:	06200593          	li	a1,98
ffffffffc02014e6:	00004517          	auipc	a0,0x4
ffffffffc02014ea:	98a50513          	addi	a0,a0,-1654 # ffffffffc0204e70 <commands+0x7a0>
default_alloc_pages(size_t n) {
ffffffffc02014ee:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc02014f0:	e85fe0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc02014f4 <default_init_memmap>:
default_init_memmap(struct Page *base, size_t n) {
ffffffffc02014f4:	1141                	addi	sp,sp,-16
ffffffffc02014f6:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc02014f8:	c9e1                	beqz	a1,ffffffffc02015c8 <default_init_memmap+0xd4>
    for (; p != base + n; p ++) {
ffffffffc02014fa:	00359693          	slli	a3,a1,0x3
ffffffffc02014fe:	96ae                	add	a3,a3,a1
ffffffffc0201500:	068e                	slli	a3,a3,0x3
ffffffffc0201502:	96aa                	add	a3,a3,a0
ffffffffc0201504:	87aa                	mv	a5,a0
ffffffffc0201506:	00d50f63          	beq	a0,a3,ffffffffc0201524 <default_init_memmap+0x30>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc020150a:	6798                	ld	a4,8(a5)
        assert(PageReserved(p));
ffffffffc020150c:	8b05                	andi	a4,a4,1
ffffffffc020150e:	cf49                	beqz	a4,ffffffffc02015a8 <default_init_memmap+0xb4>
        p->flags = p->property = 0;
ffffffffc0201510:	0007ac23          	sw	zero,24(a5)
ffffffffc0201514:	0007b423          	sd	zero,8(a5)
ffffffffc0201518:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc020151c:	04878793          	addi	a5,a5,72
ffffffffc0201520:	fed795e3          	bne	a5,a3,ffffffffc020150a <default_init_memmap+0x16>
    base->property = n;
ffffffffc0201524:	2581                	sext.w	a1,a1
ffffffffc0201526:	cd0c                	sw	a1,24(a0)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0201528:	4789                	li	a5,2
ffffffffc020152a:	00850713          	addi	a4,a0,8
ffffffffc020152e:	40f7302f          	amoor.d	zero,a5,(a4)
    nr_free += n;
ffffffffc0201532:	00010697          	auipc	a3,0x10
ffffffffc0201536:	b0e68693          	addi	a3,a3,-1266 # ffffffffc0211040 <free_area>
ffffffffc020153a:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc020153c:	669c                	ld	a5,8(a3)
        list_add(&free_list, &(base->page_link));
ffffffffc020153e:	02050613          	addi	a2,a0,32
    nr_free += n;
ffffffffc0201542:	9db9                	addw	a1,a1,a4
ffffffffc0201544:	ca8c                	sw	a1,16(a3)
    if (list_empty(&free_list)) {
ffffffffc0201546:	04d78a63          	beq	a5,a3,ffffffffc020159a <default_init_memmap+0xa6>
            struct Page* page = le2page(le, page_link);
ffffffffc020154a:	fe078713          	addi	a4,a5,-32
ffffffffc020154e:	0006b803          	ld	a6,0(a3)
    if (list_empty(&free_list)) {
ffffffffc0201552:	4581                	li	a1,0
            if (base < page) {
ffffffffc0201554:	00e56a63          	bltu	a0,a4,ffffffffc0201568 <default_init_memmap+0x74>
    return listelm->next;
ffffffffc0201558:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc020155a:	02d70263          	beq	a4,a3,ffffffffc020157e <default_init_memmap+0x8a>
    for (; p != base + n; p ++) {
ffffffffc020155e:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc0201560:	fe078713          	addi	a4,a5,-32
            if (base < page) {
ffffffffc0201564:	fee57ae3          	bgeu	a0,a4,ffffffffc0201558 <default_init_memmap+0x64>
ffffffffc0201568:	c199                	beqz	a1,ffffffffc020156e <default_init_memmap+0x7a>
ffffffffc020156a:	0106b023          	sd	a6,0(a3)
    __list_add(elm, listelm->prev, listelm);
ffffffffc020156e:	6398                	ld	a4,0(a5)
}
ffffffffc0201570:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc0201572:	e390                	sd	a2,0(a5)
ffffffffc0201574:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc0201576:	f51c                	sd	a5,40(a0)
    elm->prev = prev;
ffffffffc0201578:	f118                	sd	a4,32(a0)
ffffffffc020157a:	0141                	addi	sp,sp,16
ffffffffc020157c:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc020157e:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0201580:	f514                	sd	a3,40(a0)
    return listelm->next;
ffffffffc0201582:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc0201584:	f11c                	sd	a5,32(a0)
        while ((le = list_next(le)) != &free_list) {
ffffffffc0201586:	00d70663          	beq	a4,a3,ffffffffc0201592 <default_init_memmap+0x9e>
    prev->next = next->prev = elm;
ffffffffc020158a:	8832                	mv	a6,a2
ffffffffc020158c:	4585                	li	a1,1
    for (; p != base + n; p ++) {
ffffffffc020158e:	87ba                	mv	a5,a4
ffffffffc0201590:	bfc1                	j	ffffffffc0201560 <default_init_memmap+0x6c>
}
ffffffffc0201592:	60a2                	ld	ra,8(sp)
ffffffffc0201594:	e290                	sd	a2,0(a3)
ffffffffc0201596:	0141                	addi	sp,sp,16
ffffffffc0201598:	8082                	ret
ffffffffc020159a:	60a2                	ld	ra,8(sp)
ffffffffc020159c:	e390                	sd	a2,0(a5)
ffffffffc020159e:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc02015a0:	f51c                	sd	a5,40(a0)
    elm->prev = prev;
ffffffffc02015a2:	f11c                	sd	a5,32(a0)
ffffffffc02015a4:	0141                	addi	sp,sp,16
ffffffffc02015a6:	8082                	ret
        assert(PageReserved(p));
ffffffffc02015a8:	00004697          	auipc	a3,0x4
ffffffffc02015ac:	c3868693          	addi	a3,a3,-968 # ffffffffc02051e0 <commands+0xb10>
ffffffffc02015b0:	00004617          	auipc	a2,0x4
ffffffffc02015b4:	8a860613          	addi	a2,a2,-1880 # ffffffffc0204e58 <commands+0x788>
ffffffffc02015b8:	04900593          	li	a1,73
ffffffffc02015bc:	00004517          	auipc	a0,0x4
ffffffffc02015c0:	8b450513          	addi	a0,a0,-1868 # ffffffffc0204e70 <commands+0x7a0>
ffffffffc02015c4:	db1fe0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(n > 0);
ffffffffc02015c8:	00004697          	auipc	a3,0x4
ffffffffc02015cc:	be868693          	addi	a3,a3,-1048 # ffffffffc02051b0 <commands+0xae0>
ffffffffc02015d0:	00004617          	auipc	a2,0x4
ffffffffc02015d4:	88860613          	addi	a2,a2,-1912 # ffffffffc0204e58 <commands+0x788>
ffffffffc02015d8:	04600593          	li	a1,70
ffffffffc02015dc:	00004517          	auipc	a0,0x4
ffffffffc02015e0:	89450513          	addi	a0,a0,-1900 # ffffffffc0204e70 <commands+0x7a0>
ffffffffc02015e4:	d91fe0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc02015e8 <pa2page.part.0>:
static inline struct Page *pa2page(uintptr_t pa) {
ffffffffc02015e8:	1141                	addi	sp,sp,-16
        panic("pa2page called with invalid pa");
ffffffffc02015ea:	00004617          	auipc	a2,0x4
ffffffffc02015ee:	c5660613          	addi	a2,a2,-938 # ffffffffc0205240 <default_pmm_manager+0x38>
ffffffffc02015f2:	06500593          	li	a1,101
ffffffffc02015f6:	00004517          	auipc	a0,0x4
ffffffffc02015fa:	c6a50513          	addi	a0,a0,-918 # ffffffffc0205260 <default_pmm_manager+0x58>
static inline struct Page *pa2page(uintptr_t pa) {
ffffffffc02015fe:	e406                	sd	ra,8(sp)
        panic("pa2page called with invalid pa");
ffffffffc0201600:	d75fe0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc0201604 <pte2page.part.0>:
static inline struct Page *pte2page(pte_t pte) {
ffffffffc0201604:	1141                	addi	sp,sp,-16
        panic("pte2page called with invalid pte");
ffffffffc0201606:	00004617          	auipc	a2,0x4
ffffffffc020160a:	c6a60613          	addi	a2,a2,-918 # ffffffffc0205270 <default_pmm_manager+0x68>
ffffffffc020160e:	07000593          	li	a1,112
ffffffffc0201612:	00004517          	auipc	a0,0x4
ffffffffc0201616:	c4e50513          	addi	a0,a0,-946 # ffffffffc0205260 <default_pmm_manager+0x58>
static inline struct Page *pte2page(pte_t pte) {
ffffffffc020161a:	e406                	sd	ra,8(sp)
        panic("pte2page called with invalid pte");
ffffffffc020161c:	d59fe0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc0201620 <alloc_pages>:
    pmm_manager->init_memmap(base, n);
}

// alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE
// memory
struct Page *alloc_pages(size_t n) {
ffffffffc0201620:	7139                	addi	sp,sp,-64
ffffffffc0201622:	f426                	sd	s1,40(sp)
ffffffffc0201624:	f04a                	sd	s2,32(sp)
ffffffffc0201626:	ec4e                	sd	s3,24(sp)
ffffffffc0201628:	e852                	sd	s4,16(sp)
ffffffffc020162a:	e456                	sd	s5,8(sp)
ffffffffc020162c:	e05a                	sd	s6,0(sp)
ffffffffc020162e:	fc06                	sd	ra,56(sp)
ffffffffc0201630:	f822                	sd	s0,48(sp)
ffffffffc0201632:	84aa                	mv	s1,a0
ffffffffc0201634:	00010917          	auipc	s2,0x10
ffffffffc0201638:	f0490913          	addi	s2,s2,-252 # ffffffffc0211538 <pmm_manager>
    while (1) {
        local_intr_save(intr_flag);
        { page = pmm_manager->alloc_pages(n); }
        local_intr_restore(intr_flag);

        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc020163c:	4a05                	li	s4,1
ffffffffc020163e:	00010a97          	auipc	s5,0x10
ffffffffc0201642:	f1aa8a93          	addi	s5,s5,-230 # ffffffffc0211558 <swap_init_ok>

        extern struct mm_struct *check_mm_struct;
        // cprintf("page %x, call swap_out in alloc_pages %d\n",page, n);
        swap_out(check_mm_struct, n, 0);
ffffffffc0201646:	0005099b          	sext.w	s3,a0
ffffffffc020164a:	00010b17          	auipc	s6,0x10
ffffffffc020164e:	f1eb0b13          	addi	s6,s6,-226 # ffffffffc0211568 <check_mm_struct>
ffffffffc0201652:	a01d                	j	ffffffffc0201678 <alloc_pages+0x58>
        { page = pmm_manager->alloc_pages(n); }
ffffffffc0201654:	00093783          	ld	a5,0(s2)
ffffffffc0201658:	6f9c                	ld	a5,24(a5)
ffffffffc020165a:	9782                	jalr	a5
ffffffffc020165c:	842a                	mv	s0,a0
        swap_out(check_mm_struct, n, 0);
ffffffffc020165e:	4601                	li	a2,0
ffffffffc0201660:	85ce                	mv	a1,s3
        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0201662:	ec0d                	bnez	s0,ffffffffc020169c <alloc_pages+0x7c>
ffffffffc0201664:	029a6c63          	bltu	s4,s1,ffffffffc020169c <alloc_pages+0x7c>
ffffffffc0201668:	000aa783          	lw	a5,0(s5)
ffffffffc020166c:	2781                	sext.w	a5,a5
ffffffffc020166e:	c79d                	beqz	a5,ffffffffc020169c <alloc_pages+0x7c>
        swap_out(check_mm_struct, n, 0);
ffffffffc0201670:	000b3503          	ld	a0,0(s6)
ffffffffc0201674:	189010ef          	jal	ra,ffffffffc0202ffc <swap_out>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201678:	100027f3          	csrr	a5,sstatus
ffffffffc020167c:	8b89                	andi	a5,a5,2
        { page = pmm_manager->alloc_pages(n); }
ffffffffc020167e:	8526                	mv	a0,s1
ffffffffc0201680:	dbf1                	beqz	a5,ffffffffc0201654 <alloc_pages+0x34>
        intr_disable();
ffffffffc0201682:	e6dfe0ef          	jal	ra,ffffffffc02004ee <intr_disable>
ffffffffc0201686:	00093783          	ld	a5,0(s2)
ffffffffc020168a:	8526                	mv	a0,s1
ffffffffc020168c:	6f9c                	ld	a5,24(a5)
ffffffffc020168e:	9782                	jalr	a5
ffffffffc0201690:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0201692:	e57fe0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
        swap_out(check_mm_struct, n, 0);
ffffffffc0201696:	4601                	li	a2,0
ffffffffc0201698:	85ce                	mv	a1,s3
        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc020169a:	d469                	beqz	s0,ffffffffc0201664 <alloc_pages+0x44>
    }
    // cprintf("n %d,get page %x, No %d in alloc_pages\n",n,page,(page-pages));
    return page;
}
ffffffffc020169c:	70e2                	ld	ra,56(sp)
ffffffffc020169e:	8522                	mv	a0,s0
ffffffffc02016a0:	7442                	ld	s0,48(sp)
ffffffffc02016a2:	74a2                	ld	s1,40(sp)
ffffffffc02016a4:	7902                	ld	s2,32(sp)
ffffffffc02016a6:	69e2                	ld	s3,24(sp)
ffffffffc02016a8:	6a42                	ld	s4,16(sp)
ffffffffc02016aa:	6aa2                	ld	s5,8(sp)
ffffffffc02016ac:	6b02                	ld	s6,0(sp)
ffffffffc02016ae:	6121                	addi	sp,sp,64
ffffffffc02016b0:	8082                	ret

ffffffffc02016b2 <free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02016b2:	100027f3          	csrr	a5,sstatus
ffffffffc02016b6:	8b89                	andi	a5,a5,2
ffffffffc02016b8:	e799                	bnez	a5,ffffffffc02016c6 <free_pages+0x14>
// free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory
void free_pages(struct Page *base, size_t n) {
    bool intr_flag;

    local_intr_save(intr_flag);
    { pmm_manager->free_pages(base, n); }
ffffffffc02016ba:	00010797          	auipc	a5,0x10
ffffffffc02016be:	e7e7b783          	ld	a5,-386(a5) # ffffffffc0211538 <pmm_manager>
ffffffffc02016c2:	739c                	ld	a5,32(a5)
ffffffffc02016c4:	8782                	jr	a5
void free_pages(struct Page *base, size_t n) {
ffffffffc02016c6:	1101                	addi	sp,sp,-32
ffffffffc02016c8:	ec06                	sd	ra,24(sp)
ffffffffc02016ca:	e822                	sd	s0,16(sp)
ffffffffc02016cc:	e426                	sd	s1,8(sp)
ffffffffc02016ce:	842a                	mv	s0,a0
ffffffffc02016d0:	84ae                	mv	s1,a1
        intr_disable();
ffffffffc02016d2:	e1dfe0ef          	jal	ra,ffffffffc02004ee <intr_disable>
    { pmm_manager->free_pages(base, n); }
ffffffffc02016d6:	00010797          	auipc	a5,0x10
ffffffffc02016da:	e627b783          	ld	a5,-414(a5) # ffffffffc0211538 <pmm_manager>
ffffffffc02016de:	739c                	ld	a5,32(a5)
ffffffffc02016e0:	85a6                	mv	a1,s1
ffffffffc02016e2:	8522                	mv	a0,s0
ffffffffc02016e4:	9782                	jalr	a5
    local_intr_restore(intr_flag);
}
ffffffffc02016e6:	6442                	ld	s0,16(sp)
ffffffffc02016e8:	60e2                	ld	ra,24(sp)
ffffffffc02016ea:	64a2                	ld	s1,8(sp)
ffffffffc02016ec:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc02016ee:	dfbfe06f          	j	ffffffffc02004e8 <intr_enable>

ffffffffc02016f2 <nr_free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02016f2:	100027f3          	csrr	a5,sstatus
ffffffffc02016f6:	8b89                	andi	a5,a5,2
ffffffffc02016f8:	e799                	bnez	a5,ffffffffc0201706 <nr_free_pages+0x14>
// of current free memory
size_t nr_free_pages(void) {
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
    { ret = pmm_manager->nr_free_pages(); }
ffffffffc02016fa:	00010797          	auipc	a5,0x10
ffffffffc02016fe:	e3e7b783          	ld	a5,-450(a5) # ffffffffc0211538 <pmm_manager>
ffffffffc0201702:	779c                	ld	a5,40(a5)
ffffffffc0201704:	8782                	jr	a5
size_t nr_free_pages(void) {
ffffffffc0201706:	1141                	addi	sp,sp,-16
ffffffffc0201708:	e406                	sd	ra,8(sp)
ffffffffc020170a:	e022                	sd	s0,0(sp)
        intr_disable();
ffffffffc020170c:	de3fe0ef          	jal	ra,ffffffffc02004ee <intr_disable>
    { ret = pmm_manager->nr_free_pages(); }
ffffffffc0201710:	00010797          	auipc	a5,0x10
ffffffffc0201714:	e287b783          	ld	a5,-472(a5) # ffffffffc0211538 <pmm_manager>
ffffffffc0201718:	779c                	ld	a5,40(a5)
ffffffffc020171a:	9782                	jalr	a5
ffffffffc020171c:	842a                	mv	s0,a0
        intr_enable();
ffffffffc020171e:	dcbfe0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
    local_intr_restore(intr_flag);
    return ret;
}
ffffffffc0201722:	60a2                	ld	ra,8(sp)
ffffffffc0201724:	8522                	mv	a0,s0
ffffffffc0201726:	6402                	ld	s0,0(sp)
ffffffffc0201728:	0141                	addi	sp,sp,16
ffffffffc020172a:	8082                	ret

ffffffffc020172c <get_pte>:
     *   PTE_W           0x002                   // page table/directory entry
     * flags bit : Writeable
     *   PTE_U           0x004                   // page table/directory entry
     * flags bit : User can access
     */
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc020172c:	01e5d793          	srli	a5,a1,0x1e
ffffffffc0201730:	1ff7f793          	andi	a5,a5,511
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0201734:	715d                	addi	sp,sp,-80
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc0201736:	078e                	slli	a5,a5,0x3
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0201738:	fc26                	sd	s1,56(sp)
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc020173a:	00f504b3          	add	s1,a0,a5
    if (!(*pdep1 & PTE_V)) {
ffffffffc020173e:	6094                	ld	a3,0(s1)
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0201740:	f84a                	sd	s2,48(sp)
ffffffffc0201742:	f44e                	sd	s3,40(sp)
ffffffffc0201744:	f052                	sd	s4,32(sp)
ffffffffc0201746:	e486                	sd	ra,72(sp)
ffffffffc0201748:	e0a2                	sd	s0,64(sp)
ffffffffc020174a:	ec56                	sd	s5,24(sp)
ffffffffc020174c:	e85a                	sd	s6,16(sp)
ffffffffc020174e:	e45e                	sd	s7,8(sp)
    if (!(*pdep1 & PTE_V)) {
ffffffffc0201750:	0016f793          	andi	a5,a3,1
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0201754:	892e                	mv	s2,a1
ffffffffc0201756:	8a32                	mv	s4,a2
ffffffffc0201758:	00010997          	auipc	s3,0x10
ffffffffc020175c:	dd098993          	addi	s3,s3,-560 # ffffffffc0211528 <npage>
    if (!(*pdep1 & PTE_V)) {
ffffffffc0201760:	efb5                	bnez	a5,ffffffffc02017dc <get_pte+0xb0>
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {
ffffffffc0201762:	14060c63          	beqz	a2,ffffffffc02018ba <get_pte+0x18e>
ffffffffc0201766:	4505                	li	a0,1
ffffffffc0201768:	eb9ff0ef          	jal	ra,ffffffffc0201620 <alloc_pages>
ffffffffc020176c:	842a                	mv	s0,a0
ffffffffc020176e:	14050663          	beqz	a0,ffffffffc02018ba <get_pte+0x18e>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201772:	00010b97          	auipc	s7,0x10
ffffffffc0201776:	dbeb8b93          	addi	s7,s7,-578 # ffffffffc0211530 <pages>
ffffffffc020177a:	000bb503          	ld	a0,0(s7)
ffffffffc020177e:	00005b17          	auipc	s6,0x5
ffffffffc0201782:	b72b3b03          	ld	s6,-1166(s6) # ffffffffc02062f0 <error_string+0x38>
ffffffffc0201786:	00080ab7          	lui	s5,0x80
ffffffffc020178a:	40a40533          	sub	a0,s0,a0
ffffffffc020178e:	850d                	srai	a0,a0,0x3
ffffffffc0201790:	03650533          	mul	a0,a0,s6
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0201794:	00010997          	auipc	s3,0x10
ffffffffc0201798:	d9498993          	addi	s3,s3,-620 # ffffffffc0211528 <npage>
static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc020179c:	4785                	li	a5,1
ffffffffc020179e:	0009b703          	ld	a4,0(s3)
ffffffffc02017a2:	c01c                	sw	a5,0(s0)
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc02017a4:	9556                	add	a0,a0,s5
ffffffffc02017a6:	00c51793          	slli	a5,a0,0xc
ffffffffc02017aa:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc02017ac:	0532                	slli	a0,a0,0xc
ffffffffc02017ae:	14e7fd63          	bgeu	a5,a4,ffffffffc0201908 <get_pte+0x1dc>
ffffffffc02017b2:	00010797          	auipc	a5,0x10
ffffffffc02017b6:	d8e7b783          	ld	a5,-626(a5) # ffffffffc0211540 <va_pa_offset>
ffffffffc02017ba:	6605                	lui	a2,0x1
ffffffffc02017bc:	4581                	li	a1,0
ffffffffc02017be:	953e                	add	a0,a0,a5
ffffffffc02017c0:	48d020ef          	jal	ra,ffffffffc020444c <memset>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc02017c4:	000bb683          	ld	a3,0(s7)
ffffffffc02017c8:	40d406b3          	sub	a3,s0,a3
ffffffffc02017cc:	868d                	srai	a3,a3,0x3
ffffffffc02017ce:	036686b3          	mul	a3,a3,s6
ffffffffc02017d2:	96d6                	add	a3,a3,s5

static inline void flush_tlb() { asm volatile("sfence.vma"); }

// construct PTE from a page and permission bits
static inline pte_t pte_create(uintptr_t ppn, int type) {
    return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc02017d4:	06aa                	slli	a3,a3,0xa
ffffffffc02017d6:	0116e693          	ori	a3,a3,17
        *pdep1 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc02017da:	e094                	sd	a3,0(s1)
    }
    pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc02017dc:	77fd                	lui	a5,0xfffff
ffffffffc02017de:	068a                	slli	a3,a3,0x2
ffffffffc02017e0:	0009b703          	ld	a4,0(s3)
ffffffffc02017e4:	8efd                	and	a3,a3,a5
ffffffffc02017e6:	00c6d793          	srli	a5,a3,0xc
ffffffffc02017ea:	0ce7fa63          	bgeu	a5,a4,ffffffffc02018be <get_pte+0x192>
ffffffffc02017ee:	00010a97          	auipc	s5,0x10
ffffffffc02017f2:	d52a8a93          	addi	s5,s5,-686 # ffffffffc0211540 <va_pa_offset>
ffffffffc02017f6:	000ab403          	ld	s0,0(s5)
ffffffffc02017fa:	01595793          	srli	a5,s2,0x15
ffffffffc02017fe:	1ff7f793          	andi	a5,a5,511
ffffffffc0201802:	96a2                	add	a3,a3,s0
ffffffffc0201804:	00379413          	slli	s0,a5,0x3
ffffffffc0201808:	9436                	add	s0,s0,a3
//    pde_t *pdep0 = &((pde_t *)(PDE_ADDR(*pdep1)))[PDX0(la)];
    if (!(*pdep0 & PTE_V)) {
ffffffffc020180a:	6014                	ld	a3,0(s0)
ffffffffc020180c:	0016f793          	andi	a5,a3,1
ffffffffc0201810:	ebad                	bnez	a5,ffffffffc0201882 <get_pte+0x156>
    	struct Page *page;
    	if (!create || (page = alloc_page()) == NULL) {
ffffffffc0201812:	0a0a0463          	beqz	s4,ffffffffc02018ba <get_pte+0x18e>
ffffffffc0201816:	4505                	li	a0,1
ffffffffc0201818:	e09ff0ef          	jal	ra,ffffffffc0201620 <alloc_pages>
ffffffffc020181c:	84aa                	mv	s1,a0
ffffffffc020181e:	cd51                	beqz	a0,ffffffffc02018ba <get_pte+0x18e>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201820:	00010b97          	auipc	s7,0x10
ffffffffc0201824:	d10b8b93          	addi	s7,s7,-752 # ffffffffc0211530 <pages>
ffffffffc0201828:	000bb503          	ld	a0,0(s7)
ffffffffc020182c:	00005b17          	auipc	s6,0x5
ffffffffc0201830:	ac4b3b03          	ld	s6,-1340(s6) # ffffffffc02062f0 <error_string+0x38>
ffffffffc0201834:	00080a37          	lui	s4,0x80
ffffffffc0201838:	40a48533          	sub	a0,s1,a0
ffffffffc020183c:	850d                	srai	a0,a0,0x3
ffffffffc020183e:	03650533          	mul	a0,a0,s6
static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc0201842:	4785                	li	a5,1
    		return NULL;
    	}
    	set_page_ref(page, 1);
    	uintptr_t pa = page2pa(page);
    	memset(KADDR(pa), 0, PGSIZE);
ffffffffc0201844:	0009b703          	ld	a4,0(s3)
ffffffffc0201848:	c09c                	sw	a5,0(s1)
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc020184a:	9552                	add	a0,a0,s4
ffffffffc020184c:	00c51793          	slli	a5,a0,0xc
ffffffffc0201850:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0201852:	0532                	slli	a0,a0,0xc
ffffffffc0201854:	08e7fd63          	bgeu	a5,a4,ffffffffc02018ee <get_pte+0x1c2>
ffffffffc0201858:	000ab783          	ld	a5,0(s5)
ffffffffc020185c:	6605                	lui	a2,0x1
ffffffffc020185e:	4581                	li	a1,0
ffffffffc0201860:	953e                	add	a0,a0,a5
ffffffffc0201862:	3eb020ef          	jal	ra,ffffffffc020444c <memset>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201866:	000bb683          	ld	a3,0(s7)
ffffffffc020186a:	40d486b3          	sub	a3,s1,a3
ffffffffc020186e:	868d                	srai	a3,a3,0x3
ffffffffc0201870:	036686b3          	mul	a3,a3,s6
ffffffffc0201874:	96d2                	add	a3,a3,s4
    return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0201876:	06aa                	slli	a3,a3,0xa
ffffffffc0201878:	0116e693          	ori	a3,a3,17
 //   	memset(pa, 0, PGSIZE);
    	*pdep0 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc020187c:	e014                	sd	a3,0(s0)
    }
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc020187e:	0009b703          	ld	a4,0(s3)
ffffffffc0201882:	068a                	slli	a3,a3,0x2
ffffffffc0201884:	757d                	lui	a0,0xfffff
ffffffffc0201886:	8ee9                	and	a3,a3,a0
ffffffffc0201888:	00c6d793          	srli	a5,a3,0xc
ffffffffc020188c:	04e7f563          	bgeu	a5,a4,ffffffffc02018d6 <get_pte+0x1aa>
ffffffffc0201890:	000ab503          	ld	a0,0(s5)
ffffffffc0201894:	00c95913          	srli	s2,s2,0xc
ffffffffc0201898:	1ff97913          	andi	s2,s2,511
ffffffffc020189c:	96aa                	add	a3,a3,a0
ffffffffc020189e:	00391513          	slli	a0,s2,0x3
ffffffffc02018a2:	9536                	add	a0,a0,a3
}
ffffffffc02018a4:	60a6                	ld	ra,72(sp)
ffffffffc02018a6:	6406                	ld	s0,64(sp)
ffffffffc02018a8:	74e2                	ld	s1,56(sp)
ffffffffc02018aa:	7942                	ld	s2,48(sp)
ffffffffc02018ac:	79a2                	ld	s3,40(sp)
ffffffffc02018ae:	7a02                	ld	s4,32(sp)
ffffffffc02018b0:	6ae2                	ld	s5,24(sp)
ffffffffc02018b2:	6b42                	ld	s6,16(sp)
ffffffffc02018b4:	6ba2                	ld	s7,8(sp)
ffffffffc02018b6:	6161                	addi	sp,sp,80
ffffffffc02018b8:	8082                	ret
            return NULL;
ffffffffc02018ba:	4501                	li	a0,0
ffffffffc02018bc:	b7e5                	j	ffffffffc02018a4 <get_pte+0x178>
    pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc02018be:	00004617          	auipc	a2,0x4
ffffffffc02018c2:	9da60613          	addi	a2,a2,-1574 # ffffffffc0205298 <default_pmm_manager+0x90>
ffffffffc02018c6:	10200593          	li	a1,258
ffffffffc02018ca:	00004517          	auipc	a0,0x4
ffffffffc02018ce:	9f650513          	addi	a0,a0,-1546 # ffffffffc02052c0 <default_pmm_manager+0xb8>
ffffffffc02018d2:	aa3fe0ef          	jal	ra,ffffffffc0200374 <__panic>
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc02018d6:	00004617          	auipc	a2,0x4
ffffffffc02018da:	9c260613          	addi	a2,a2,-1598 # ffffffffc0205298 <default_pmm_manager+0x90>
ffffffffc02018de:	10f00593          	li	a1,271
ffffffffc02018e2:	00004517          	auipc	a0,0x4
ffffffffc02018e6:	9de50513          	addi	a0,a0,-1570 # ffffffffc02052c0 <default_pmm_manager+0xb8>
ffffffffc02018ea:	a8bfe0ef          	jal	ra,ffffffffc0200374 <__panic>
    	memset(KADDR(pa), 0, PGSIZE);
ffffffffc02018ee:	86aa                	mv	a3,a0
ffffffffc02018f0:	00004617          	auipc	a2,0x4
ffffffffc02018f4:	9a860613          	addi	a2,a2,-1624 # ffffffffc0205298 <default_pmm_manager+0x90>
ffffffffc02018f8:	10b00593          	li	a1,267
ffffffffc02018fc:	00004517          	auipc	a0,0x4
ffffffffc0201900:	9c450513          	addi	a0,a0,-1596 # ffffffffc02052c0 <default_pmm_manager+0xb8>
ffffffffc0201904:	a71fe0ef          	jal	ra,ffffffffc0200374 <__panic>
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0201908:	86aa                	mv	a3,a0
ffffffffc020190a:	00004617          	auipc	a2,0x4
ffffffffc020190e:	98e60613          	addi	a2,a2,-1650 # ffffffffc0205298 <default_pmm_manager+0x90>
ffffffffc0201912:	0ff00593          	li	a1,255
ffffffffc0201916:	00004517          	auipc	a0,0x4
ffffffffc020191a:	9aa50513          	addi	a0,a0,-1622 # ffffffffc02052c0 <default_pmm_manager+0xb8>
ffffffffc020191e:	a57fe0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc0201922 <get_page>:

// get_page - get related Page struct for linear address la using PDT pgdir
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
ffffffffc0201922:	1141                	addi	sp,sp,-16
ffffffffc0201924:	e022                	sd	s0,0(sp)
ffffffffc0201926:	8432                	mv	s0,a2
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0201928:	4601                	li	a2,0
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
ffffffffc020192a:	e406                	sd	ra,8(sp)
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc020192c:	e01ff0ef          	jal	ra,ffffffffc020172c <get_pte>
    if (ptep_store != NULL) {
ffffffffc0201930:	c011                	beqz	s0,ffffffffc0201934 <get_page+0x12>
        *ptep_store = ptep;
ffffffffc0201932:	e008                	sd	a0,0(s0)
    }
    if (ptep != NULL && *ptep & PTE_V) {
ffffffffc0201934:	c511                	beqz	a0,ffffffffc0201940 <get_page+0x1e>
ffffffffc0201936:	611c                	ld	a5,0(a0)
        return pte2page(*ptep);
    }
    return NULL;
ffffffffc0201938:	4501                	li	a0,0
    if (ptep != NULL && *ptep & PTE_V) {
ffffffffc020193a:	0017f713          	andi	a4,a5,1
ffffffffc020193e:	e709                	bnez	a4,ffffffffc0201948 <get_page+0x26>
}
ffffffffc0201940:	60a2                	ld	ra,8(sp)
ffffffffc0201942:	6402                	ld	s0,0(sp)
ffffffffc0201944:	0141                	addi	sp,sp,16
ffffffffc0201946:	8082                	ret
    return pa2page(PTE_ADDR(pte));
ffffffffc0201948:	078a                	slli	a5,a5,0x2
ffffffffc020194a:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020194c:	00010717          	auipc	a4,0x10
ffffffffc0201950:	bdc73703          	ld	a4,-1060(a4) # ffffffffc0211528 <npage>
ffffffffc0201954:	02e7f263          	bgeu	a5,a4,ffffffffc0201978 <get_page+0x56>
    return &pages[PPN(pa) - nbase];
ffffffffc0201958:	fff80537          	lui	a0,0xfff80
ffffffffc020195c:	97aa                	add	a5,a5,a0
ffffffffc020195e:	60a2                	ld	ra,8(sp)
ffffffffc0201960:	6402                	ld	s0,0(sp)
ffffffffc0201962:	00379513          	slli	a0,a5,0x3
ffffffffc0201966:	97aa                	add	a5,a5,a0
ffffffffc0201968:	078e                	slli	a5,a5,0x3
ffffffffc020196a:	00010517          	auipc	a0,0x10
ffffffffc020196e:	bc653503          	ld	a0,-1082(a0) # ffffffffc0211530 <pages>
ffffffffc0201972:	953e                	add	a0,a0,a5
ffffffffc0201974:	0141                	addi	sp,sp,16
ffffffffc0201976:	8082                	ret
ffffffffc0201978:	c71ff0ef          	jal	ra,ffffffffc02015e8 <pa2page.part.0>

ffffffffc020197c <page_remove>:
    }
}

// page_remove - free an Page which is related linear address la and has an
// validated pte
void page_remove(pde_t *pgdir, uintptr_t la) {
ffffffffc020197c:	1101                	addi	sp,sp,-32
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc020197e:	4601                	li	a2,0
void page_remove(pde_t *pgdir, uintptr_t la) {
ffffffffc0201980:	ec06                	sd	ra,24(sp)
ffffffffc0201982:	e822                	sd	s0,16(sp)
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0201984:	da9ff0ef          	jal	ra,ffffffffc020172c <get_pte>
    if (ptep != NULL) {
ffffffffc0201988:	c511                	beqz	a0,ffffffffc0201994 <page_remove+0x18>
    if (*ptep & PTE_V) {  //(1) check if this page table entry is
ffffffffc020198a:	611c                	ld	a5,0(a0)
ffffffffc020198c:	842a                	mv	s0,a0
ffffffffc020198e:	0017f713          	andi	a4,a5,1
ffffffffc0201992:	e709                	bnez	a4,ffffffffc020199c <page_remove+0x20>
        page_remove_pte(pgdir, la, ptep);
    }
}
ffffffffc0201994:	60e2                	ld	ra,24(sp)
ffffffffc0201996:	6442                	ld	s0,16(sp)
ffffffffc0201998:	6105                	addi	sp,sp,32
ffffffffc020199a:	8082                	ret
    return pa2page(PTE_ADDR(pte));
ffffffffc020199c:	078a                	slli	a5,a5,0x2
ffffffffc020199e:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02019a0:	00010717          	auipc	a4,0x10
ffffffffc02019a4:	b8873703          	ld	a4,-1144(a4) # ffffffffc0211528 <npage>
ffffffffc02019a8:	06e7f563          	bgeu	a5,a4,ffffffffc0201a12 <page_remove+0x96>
    return &pages[PPN(pa) - nbase];
ffffffffc02019ac:	fff80737          	lui	a4,0xfff80
ffffffffc02019b0:	97ba                	add	a5,a5,a4
ffffffffc02019b2:	00379513          	slli	a0,a5,0x3
ffffffffc02019b6:	97aa                	add	a5,a5,a0
ffffffffc02019b8:	078e                	slli	a5,a5,0x3
ffffffffc02019ba:	00010517          	auipc	a0,0x10
ffffffffc02019be:	b7653503          	ld	a0,-1162(a0) # ffffffffc0211530 <pages>
ffffffffc02019c2:	953e                	add	a0,a0,a5
    page->ref -= 1;
ffffffffc02019c4:	411c                	lw	a5,0(a0)
ffffffffc02019c6:	fff7871b          	addiw	a4,a5,-1
ffffffffc02019ca:	c118                	sw	a4,0(a0)
        if (page_ref(page) ==
ffffffffc02019cc:	cb09                	beqz	a4,ffffffffc02019de <page_remove+0x62>
        *ptep = 0;                  //(5) clear second page table entry
ffffffffc02019ce:	00043023          	sd	zero,0(s0)
static inline void flush_tlb() { asm volatile("sfence.vma"); }
ffffffffc02019d2:	12000073          	sfence.vma
}
ffffffffc02019d6:	60e2                	ld	ra,24(sp)
ffffffffc02019d8:	6442                	ld	s0,16(sp)
ffffffffc02019da:	6105                	addi	sp,sp,32
ffffffffc02019dc:	8082                	ret
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02019de:	100027f3          	csrr	a5,sstatus
ffffffffc02019e2:	8b89                	andi	a5,a5,2
ffffffffc02019e4:	eb89                	bnez	a5,ffffffffc02019f6 <page_remove+0x7a>
    { pmm_manager->free_pages(base, n); }
ffffffffc02019e6:	00010797          	auipc	a5,0x10
ffffffffc02019ea:	b527b783          	ld	a5,-1198(a5) # ffffffffc0211538 <pmm_manager>
ffffffffc02019ee:	739c                	ld	a5,32(a5)
ffffffffc02019f0:	4585                	li	a1,1
ffffffffc02019f2:	9782                	jalr	a5
    if (flag) {
ffffffffc02019f4:	bfe9                	j	ffffffffc02019ce <page_remove+0x52>
        intr_disable();
ffffffffc02019f6:	e42a                	sd	a0,8(sp)
ffffffffc02019f8:	af7fe0ef          	jal	ra,ffffffffc02004ee <intr_disable>
ffffffffc02019fc:	00010797          	auipc	a5,0x10
ffffffffc0201a00:	b3c7b783          	ld	a5,-1220(a5) # ffffffffc0211538 <pmm_manager>
ffffffffc0201a04:	739c                	ld	a5,32(a5)
ffffffffc0201a06:	6522                	ld	a0,8(sp)
ffffffffc0201a08:	4585                	li	a1,1
ffffffffc0201a0a:	9782                	jalr	a5
        intr_enable();
ffffffffc0201a0c:	addfe0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
ffffffffc0201a10:	bf7d                	j	ffffffffc02019ce <page_remove+0x52>
ffffffffc0201a12:	bd7ff0ef          	jal	ra,ffffffffc02015e8 <pa2page.part.0>

ffffffffc0201a16 <page_insert>:
//  page:  the Page which need to map
//  la:    the linear address need to map
//  perm:  the permission of this Page which is setted in related pte
// return value: always 0
// note: PT is changed, so the TLB need to be invalidate
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0201a16:	7179                	addi	sp,sp,-48
ffffffffc0201a18:	87b2                	mv	a5,a2
ffffffffc0201a1a:	f022                	sd	s0,32(sp)
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0201a1c:	4605                	li	a2,1
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0201a1e:	842e                	mv	s0,a1
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0201a20:	85be                	mv	a1,a5
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0201a22:	ec26                	sd	s1,24(sp)
ffffffffc0201a24:	f406                	sd	ra,40(sp)
ffffffffc0201a26:	e84a                	sd	s2,16(sp)
ffffffffc0201a28:	e44e                	sd	s3,8(sp)
ffffffffc0201a2a:	e052                	sd	s4,0(sp)
ffffffffc0201a2c:	84b6                	mv	s1,a3
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0201a2e:	cffff0ef          	jal	ra,ffffffffc020172c <get_pte>
    if (ptep == NULL) {
ffffffffc0201a32:	cd71                	beqz	a0,ffffffffc0201b0e <page_insert+0xf8>
    page->ref += 1;
ffffffffc0201a34:	4014                	lw	a3,0(s0)
        return -E_NO_MEM;
    }
    page_ref_inc(page);
    if (*ptep & PTE_V) {
ffffffffc0201a36:	611c                	ld	a5,0(a0)
ffffffffc0201a38:	89aa                	mv	s3,a0
ffffffffc0201a3a:	0016871b          	addiw	a4,a3,1
ffffffffc0201a3e:	c018                	sw	a4,0(s0)
ffffffffc0201a40:	0017f713          	andi	a4,a5,1
ffffffffc0201a44:	e331                	bnez	a4,ffffffffc0201a88 <page_insert+0x72>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201a46:	00010797          	auipc	a5,0x10
ffffffffc0201a4a:	aea7b783          	ld	a5,-1302(a5) # ffffffffc0211530 <pages>
ffffffffc0201a4e:	40f407b3          	sub	a5,s0,a5
ffffffffc0201a52:	878d                	srai	a5,a5,0x3
ffffffffc0201a54:	00005417          	auipc	s0,0x5
ffffffffc0201a58:	89c43403          	ld	s0,-1892(s0) # ffffffffc02062f0 <error_string+0x38>
ffffffffc0201a5c:	028787b3          	mul	a5,a5,s0
ffffffffc0201a60:	00080437          	lui	s0,0x80
ffffffffc0201a64:	97a2                	add	a5,a5,s0
    return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0201a66:	07aa                	slli	a5,a5,0xa
ffffffffc0201a68:	8cdd                	or	s1,s1,a5
ffffffffc0201a6a:	0014e493          	ori	s1,s1,1
            page_ref_dec(page);
        } else {
            page_remove_pte(pgdir, la, ptep);
        }
    }
    *ptep = pte_create(page2ppn(page), PTE_V | perm);
ffffffffc0201a6e:	0099b023          	sd	s1,0(s3)
static inline void flush_tlb() { asm volatile("sfence.vma"); }
ffffffffc0201a72:	12000073          	sfence.vma
    tlb_invalidate(pgdir, la);
    return 0;
ffffffffc0201a76:	4501                	li	a0,0
}
ffffffffc0201a78:	70a2                	ld	ra,40(sp)
ffffffffc0201a7a:	7402                	ld	s0,32(sp)
ffffffffc0201a7c:	64e2                	ld	s1,24(sp)
ffffffffc0201a7e:	6942                	ld	s2,16(sp)
ffffffffc0201a80:	69a2                	ld	s3,8(sp)
ffffffffc0201a82:	6a02                	ld	s4,0(sp)
ffffffffc0201a84:	6145                	addi	sp,sp,48
ffffffffc0201a86:	8082                	ret
    return pa2page(PTE_ADDR(pte));
ffffffffc0201a88:	00279713          	slli	a4,a5,0x2
ffffffffc0201a8c:	8331                	srli	a4,a4,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201a8e:	00010797          	auipc	a5,0x10
ffffffffc0201a92:	a9a7b783          	ld	a5,-1382(a5) # ffffffffc0211528 <npage>
ffffffffc0201a96:	06f77e63          	bgeu	a4,a5,ffffffffc0201b12 <page_insert+0xfc>
    return &pages[PPN(pa) - nbase];
ffffffffc0201a9a:	fff807b7          	lui	a5,0xfff80
ffffffffc0201a9e:	973e                	add	a4,a4,a5
ffffffffc0201aa0:	00010a17          	auipc	s4,0x10
ffffffffc0201aa4:	a90a0a13          	addi	s4,s4,-1392 # ffffffffc0211530 <pages>
ffffffffc0201aa8:	000a3783          	ld	a5,0(s4)
ffffffffc0201aac:	00371913          	slli	s2,a4,0x3
ffffffffc0201ab0:	993a                	add	s2,s2,a4
ffffffffc0201ab2:	090e                	slli	s2,s2,0x3
ffffffffc0201ab4:	993e                	add	s2,s2,a5
        if (p == page) {
ffffffffc0201ab6:	03240063          	beq	s0,s2,ffffffffc0201ad6 <page_insert+0xc0>
    page->ref -= 1;
ffffffffc0201aba:	00092783          	lw	a5,0(s2)
ffffffffc0201abe:	fff7871b          	addiw	a4,a5,-1
ffffffffc0201ac2:	00e92023          	sw	a4,0(s2)
        if (page_ref(page) ==
ffffffffc0201ac6:	cb11                	beqz	a4,ffffffffc0201ada <page_insert+0xc4>
        *ptep = 0;                  //(5) clear second page table entry
ffffffffc0201ac8:	0009b023          	sd	zero,0(s3)
static inline void flush_tlb() { asm volatile("sfence.vma"); }
ffffffffc0201acc:	12000073          	sfence.vma
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201ad0:	000a3783          	ld	a5,0(s4)
}
ffffffffc0201ad4:	bfad                	j	ffffffffc0201a4e <page_insert+0x38>
    page->ref -= 1;
ffffffffc0201ad6:	c014                	sw	a3,0(s0)
    return page->ref;
ffffffffc0201ad8:	bf9d                	j	ffffffffc0201a4e <page_insert+0x38>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201ada:	100027f3          	csrr	a5,sstatus
ffffffffc0201ade:	8b89                	andi	a5,a5,2
ffffffffc0201ae0:	eb91                	bnez	a5,ffffffffc0201af4 <page_insert+0xde>
    { pmm_manager->free_pages(base, n); }
ffffffffc0201ae2:	00010797          	auipc	a5,0x10
ffffffffc0201ae6:	a567b783          	ld	a5,-1450(a5) # ffffffffc0211538 <pmm_manager>
ffffffffc0201aea:	739c                	ld	a5,32(a5)
ffffffffc0201aec:	4585                	li	a1,1
ffffffffc0201aee:	854a                	mv	a0,s2
ffffffffc0201af0:	9782                	jalr	a5
    if (flag) {
ffffffffc0201af2:	bfd9                	j	ffffffffc0201ac8 <page_insert+0xb2>
        intr_disable();
ffffffffc0201af4:	9fbfe0ef          	jal	ra,ffffffffc02004ee <intr_disable>
ffffffffc0201af8:	00010797          	auipc	a5,0x10
ffffffffc0201afc:	a407b783          	ld	a5,-1472(a5) # ffffffffc0211538 <pmm_manager>
ffffffffc0201b00:	739c                	ld	a5,32(a5)
ffffffffc0201b02:	4585                	li	a1,1
ffffffffc0201b04:	854a                	mv	a0,s2
ffffffffc0201b06:	9782                	jalr	a5
        intr_enable();
ffffffffc0201b08:	9e1fe0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
ffffffffc0201b0c:	bf75                	j	ffffffffc0201ac8 <page_insert+0xb2>
        return -E_NO_MEM;
ffffffffc0201b0e:	5571                	li	a0,-4
ffffffffc0201b10:	b7a5                	j	ffffffffc0201a78 <page_insert+0x62>
ffffffffc0201b12:	ad7ff0ef          	jal	ra,ffffffffc02015e8 <pa2page.part.0>

ffffffffc0201b16 <pmm_init>:
    pmm_manager = &default_pmm_manager;
ffffffffc0201b16:	00003797          	auipc	a5,0x3
ffffffffc0201b1a:	6f278793          	addi	a5,a5,1778 # ffffffffc0205208 <default_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0201b1e:	638c                	ld	a1,0(a5)
void pmm_init(void) {
ffffffffc0201b20:	7159                	addi	sp,sp,-112
ffffffffc0201b22:	f45e                	sd	s7,40(sp)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0201b24:	00003517          	auipc	a0,0x3
ffffffffc0201b28:	7ac50513          	addi	a0,a0,1964 # ffffffffc02052d0 <default_pmm_manager+0xc8>
    pmm_manager = &default_pmm_manager;
ffffffffc0201b2c:	00010b97          	auipc	s7,0x10
ffffffffc0201b30:	a0cb8b93          	addi	s7,s7,-1524 # ffffffffc0211538 <pmm_manager>
void pmm_init(void) {
ffffffffc0201b34:	f486                	sd	ra,104(sp)
ffffffffc0201b36:	f0a2                	sd	s0,96(sp)
ffffffffc0201b38:	eca6                	sd	s1,88(sp)
ffffffffc0201b3a:	e8ca                	sd	s2,80(sp)
ffffffffc0201b3c:	e4ce                	sd	s3,72(sp)
ffffffffc0201b3e:	f85a                	sd	s6,48(sp)
    pmm_manager = &default_pmm_manager;
ffffffffc0201b40:	00fbb023          	sd	a5,0(s7)
void pmm_init(void) {
ffffffffc0201b44:	e0d2                	sd	s4,64(sp)
ffffffffc0201b46:	fc56                	sd	s5,56(sp)
ffffffffc0201b48:	f062                	sd	s8,32(sp)
ffffffffc0201b4a:	ec66                	sd	s9,24(sp)
ffffffffc0201b4c:	e86a                	sd	s10,16(sp)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0201b4e:	d6cfe0ef          	jal	ra,ffffffffc02000ba <cprintf>
    pmm_manager->init();
ffffffffc0201b52:	000bb783          	ld	a5,0(s7)
    cprintf("membegin %llx memend %llx mem_size %llx\n",mem_begin, mem_end, mem_size);
ffffffffc0201b56:	4445                	li	s0,17
ffffffffc0201b58:	40100913          	li	s2,1025
    pmm_manager->init();
ffffffffc0201b5c:	679c                	ld	a5,8(a5)
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc0201b5e:	00010997          	auipc	s3,0x10
ffffffffc0201b62:	9e298993          	addi	s3,s3,-1566 # ffffffffc0211540 <va_pa_offset>
    npage = maxpa / PGSIZE;
ffffffffc0201b66:	00010497          	auipc	s1,0x10
ffffffffc0201b6a:	9c248493          	addi	s1,s1,-1598 # ffffffffc0211528 <npage>
    pmm_manager->init();
ffffffffc0201b6e:	9782                	jalr	a5
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc0201b70:	57f5                	li	a5,-3
ffffffffc0201b72:	07fa                	slli	a5,a5,0x1e
    cprintf("membegin %llx memend %llx mem_size %llx\n",mem_begin, mem_end, mem_size);
ffffffffc0201b74:	07e006b7          	lui	a3,0x7e00
ffffffffc0201b78:	01b41613          	slli	a2,s0,0x1b
ffffffffc0201b7c:	01591593          	slli	a1,s2,0x15
ffffffffc0201b80:	00003517          	auipc	a0,0x3
ffffffffc0201b84:	76850513          	addi	a0,a0,1896 # ffffffffc02052e8 <default_pmm_manager+0xe0>
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc0201b88:	00f9b023          	sd	a5,0(s3)
    cprintf("membegin %llx memend %llx mem_size %llx\n",mem_begin, mem_end, mem_size);
ffffffffc0201b8c:	d2efe0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("physcial memory map:\n");
ffffffffc0201b90:	00003517          	auipc	a0,0x3
ffffffffc0201b94:	78850513          	addi	a0,a0,1928 # ffffffffc0205318 <default_pmm_manager+0x110>
ffffffffc0201b98:	d22fe0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  memory: 0x%08lx, [0x%08lx, 0x%08lx].\n", mem_size, mem_begin,
ffffffffc0201b9c:	01b41693          	slli	a3,s0,0x1b
ffffffffc0201ba0:	16fd                	addi	a3,a3,-1
ffffffffc0201ba2:	07e005b7          	lui	a1,0x7e00
ffffffffc0201ba6:	01591613          	slli	a2,s2,0x15
ffffffffc0201baa:	00003517          	auipc	a0,0x3
ffffffffc0201bae:	78650513          	addi	a0,a0,1926 # ffffffffc0205330 <default_pmm_manager+0x128>
ffffffffc0201bb2:	d08fe0ef          	jal	ra,ffffffffc02000ba <cprintf>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0201bb6:	777d                	lui	a4,0xfffff
ffffffffc0201bb8:	00011797          	auipc	a5,0x11
ffffffffc0201bbc:	9bb78793          	addi	a5,a5,-1605 # ffffffffc0212573 <end+0xfff>
ffffffffc0201bc0:	8ff9                	and	a5,a5,a4
ffffffffc0201bc2:	00010b17          	auipc	s6,0x10
ffffffffc0201bc6:	96eb0b13          	addi	s6,s6,-1682 # ffffffffc0211530 <pages>
    npage = maxpa / PGSIZE;
ffffffffc0201bca:	00088737          	lui	a4,0x88
ffffffffc0201bce:	e098                	sd	a4,0(s1)
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0201bd0:	00fb3023          	sd	a5,0(s6)
ffffffffc0201bd4:	4681                	li	a3,0
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0201bd6:	4701                	li	a4,0
ffffffffc0201bd8:	4505                	li	a0,1
ffffffffc0201bda:	fff805b7          	lui	a1,0xfff80
ffffffffc0201bde:	a019                	j	ffffffffc0201be4 <pmm_init+0xce>
        SetPageReserved(pages + i);
ffffffffc0201be0:	000b3783          	ld	a5,0(s6)
ffffffffc0201be4:	97b6                	add	a5,a5,a3
ffffffffc0201be6:	07a1                	addi	a5,a5,8
ffffffffc0201be8:	40a7b02f          	amoor.d	zero,a0,(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0201bec:	609c                	ld	a5,0(s1)
ffffffffc0201bee:	0705                	addi	a4,a4,1
ffffffffc0201bf0:	04868693          	addi	a3,a3,72 # 7e00048 <kern_entry-0xffffffffb83fffb8>
ffffffffc0201bf4:	00b78633          	add	a2,a5,a1
ffffffffc0201bf8:	fec764e3          	bltu	a4,a2,ffffffffc0201be0 <pmm_init+0xca>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0201bfc:	000b3503          	ld	a0,0(s6)
ffffffffc0201c00:	00379693          	slli	a3,a5,0x3
ffffffffc0201c04:	96be                	add	a3,a3,a5
ffffffffc0201c06:	fdc00737          	lui	a4,0xfdc00
ffffffffc0201c0a:	972a                	add	a4,a4,a0
ffffffffc0201c0c:	068e                	slli	a3,a3,0x3
ffffffffc0201c0e:	96ba                	add	a3,a3,a4
ffffffffc0201c10:	c0200737          	lui	a4,0xc0200
ffffffffc0201c14:	64e6e463          	bltu	a3,a4,ffffffffc020225c <pmm_init+0x746>
ffffffffc0201c18:	0009b703          	ld	a4,0(s3)
    if (freemem < mem_end) {
ffffffffc0201c1c:	4645                	li	a2,17
ffffffffc0201c1e:	066e                	slli	a2,a2,0x1b
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0201c20:	8e99                	sub	a3,a3,a4
    if (freemem < mem_end) {
ffffffffc0201c22:	4ec6e263          	bltu	a3,a2,ffffffffc0202106 <pmm_init+0x5f0>

    return page;
}

static void check_alloc_page(void) {
    pmm_manager->check();
ffffffffc0201c26:	000bb783          	ld	a5,0(s7)
    boot_pgdir = (pte_t*)boot_page_table_sv39;
ffffffffc0201c2a:	00010917          	auipc	s2,0x10
ffffffffc0201c2e:	8f690913          	addi	s2,s2,-1802 # ffffffffc0211520 <boot_pgdir>
    pmm_manager->check();
ffffffffc0201c32:	7b9c                	ld	a5,48(a5)
ffffffffc0201c34:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc0201c36:	00003517          	auipc	a0,0x3
ffffffffc0201c3a:	74a50513          	addi	a0,a0,1866 # ffffffffc0205380 <default_pmm_manager+0x178>
ffffffffc0201c3e:	c7cfe0ef          	jal	ra,ffffffffc02000ba <cprintf>
    boot_pgdir = (pte_t*)boot_page_table_sv39;
ffffffffc0201c42:	00007697          	auipc	a3,0x7
ffffffffc0201c46:	3be68693          	addi	a3,a3,958 # ffffffffc0209000 <boot_page_table_sv39>
ffffffffc0201c4a:	00d93023          	sd	a3,0(s2)
    boot_cr3 = PADDR(boot_pgdir);
ffffffffc0201c4e:	c02007b7          	lui	a5,0xc0200
ffffffffc0201c52:	62f6e163          	bltu	a3,a5,ffffffffc0202274 <pmm_init+0x75e>
ffffffffc0201c56:	0009b783          	ld	a5,0(s3)
ffffffffc0201c5a:	8e9d                	sub	a3,a3,a5
ffffffffc0201c5c:	00010797          	auipc	a5,0x10
ffffffffc0201c60:	8ad7be23          	sd	a3,-1860(a5) # ffffffffc0211518 <boot_cr3>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201c64:	100027f3          	csrr	a5,sstatus
ffffffffc0201c68:	8b89                	andi	a5,a5,2
ffffffffc0201c6a:	4c079763          	bnez	a5,ffffffffc0202138 <pmm_init+0x622>
    { ret = pmm_manager->nr_free_pages(); }
ffffffffc0201c6e:	000bb783          	ld	a5,0(s7)
ffffffffc0201c72:	779c                	ld	a5,40(a5)
ffffffffc0201c74:	9782                	jalr	a5
ffffffffc0201c76:	842a                	mv	s0,a0
    // so npage is always larger than KMEMSIZE / PGSIZE
    size_t nr_free_store;

    nr_free_store=nr_free_pages();

    assert(npage <= KERNTOP / PGSIZE);
ffffffffc0201c78:	6098                	ld	a4,0(s1)
ffffffffc0201c7a:	c80007b7          	lui	a5,0xc8000
ffffffffc0201c7e:	83b1                	srli	a5,a5,0xc
ffffffffc0201c80:	62e7e663          	bltu	a5,a4,ffffffffc02022ac <pmm_init+0x796>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
ffffffffc0201c84:	00093503          	ld	a0,0(s2)
ffffffffc0201c88:	60050263          	beqz	a0,ffffffffc020228c <pmm_init+0x776>
ffffffffc0201c8c:	03451793          	slli	a5,a0,0x34
ffffffffc0201c90:	5e079e63          	bnez	a5,ffffffffc020228c <pmm_init+0x776>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
ffffffffc0201c94:	4601                	li	a2,0
ffffffffc0201c96:	4581                	li	a1,0
ffffffffc0201c98:	c8bff0ef          	jal	ra,ffffffffc0201922 <get_page>
ffffffffc0201c9c:	66051a63          	bnez	a0,ffffffffc0202310 <pmm_init+0x7fa>

    struct Page *p1, *p2;
    p1 = alloc_page();
ffffffffc0201ca0:	4505                	li	a0,1
ffffffffc0201ca2:	97fff0ef          	jal	ra,ffffffffc0201620 <alloc_pages>
ffffffffc0201ca6:	8a2a                	mv	s4,a0
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
ffffffffc0201ca8:	00093503          	ld	a0,0(s2)
ffffffffc0201cac:	4681                	li	a3,0
ffffffffc0201cae:	4601                	li	a2,0
ffffffffc0201cb0:	85d2                	mv	a1,s4
ffffffffc0201cb2:	d65ff0ef          	jal	ra,ffffffffc0201a16 <page_insert>
ffffffffc0201cb6:	62051d63          	bnez	a0,ffffffffc02022f0 <pmm_init+0x7da>
    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
ffffffffc0201cba:	00093503          	ld	a0,0(s2)
ffffffffc0201cbe:	4601                	li	a2,0
ffffffffc0201cc0:	4581                	li	a1,0
ffffffffc0201cc2:	a6bff0ef          	jal	ra,ffffffffc020172c <get_pte>
ffffffffc0201cc6:	60050563          	beqz	a0,ffffffffc02022d0 <pmm_init+0x7ba>
    assert(pte2page(*ptep) == p1);
ffffffffc0201cca:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc0201ccc:	0017f713          	andi	a4,a5,1
ffffffffc0201cd0:	5e070e63          	beqz	a4,ffffffffc02022cc <pmm_init+0x7b6>
    if (PPN(pa) >= npage) {
ffffffffc0201cd4:	6090                	ld	a2,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc0201cd6:	078a                	slli	a5,a5,0x2
ffffffffc0201cd8:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201cda:	56c7ff63          	bgeu	a5,a2,ffffffffc0202258 <pmm_init+0x742>
    return &pages[PPN(pa) - nbase];
ffffffffc0201cde:	fff80737          	lui	a4,0xfff80
ffffffffc0201ce2:	97ba                	add	a5,a5,a4
ffffffffc0201ce4:	000b3683          	ld	a3,0(s6)
ffffffffc0201ce8:	00379713          	slli	a4,a5,0x3
ffffffffc0201cec:	97ba                	add	a5,a5,a4
ffffffffc0201cee:	078e                	slli	a5,a5,0x3
ffffffffc0201cf0:	97b6                	add	a5,a5,a3
ffffffffc0201cf2:	14fa18e3          	bne	s4,a5,ffffffffc0202642 <pmm_init+0xb2c>
    assert(page_ref(p1) == 1);
ffffffffc0201cf6:	000a2703          	lw	a4,0(s4)
ffffffffc0201cfa:	4785                	li	a5,1
ffffffffc0201cfc:	16f71fe3          	bne	a4,a5,ffffffffc020267a <pmm_init+0xb64>

    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir[0]));
ffffffffc0201d00:	00093503          	ld	a0,0(s2)
ffffffffc0201d04:	77fd                	lui	a5,0xfffff
ffffffffc0201d06:	6114                	ld	a3,0(a0)
ffffffffc0201d08:	068a                	slli	a3,a3,0x2
ffffffffc0201d0a:	8efd                	and	a3,a3,a5
ffffffffc0201d0c:	00c6d713          	srli	a4,a3,0xc
ffffffffc0201d10:	14c779e3          	bgeu	a4,a2,ffffffffc0202662 <pmm_init+0xb4c>
ffffffffc0201d14:	0009bc03          	ld	s8,0(s3)
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0201d18:	96e2                	add	a3,a3,s8
ffffffffc0201d1a:	0006ba83          	ld	s5,0(a3)
ffffffffc0201d1e:	0a8a                	slli	s5,s5,0x2
ffffffffc0201d20:	00fafab3          	and	s5,s5,a5
ffffffffc0201d24:	00cad793          	srli	a5,s5,0xc
ffffffffc0201d28:	66c7f463          	bgeu	a5,a2,ffffffffc0202390 <pmm_init+0x87a>
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0201d2c:	4601                	li	a2,0
ffffffffc0201d2e:	6585                	lui	a1,0x1
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0201d30:	9ae2                	add	s5,s5,s8
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0201d32:	9fbff0ef          	jal	ra,ffffffffc020172c <get_pte>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0201d36:	0aa1                	addi	s5,s5,8
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0201d38:	63551c63          	bne	a0,s5,ffffffffc0202370 <pmm_init+0x85a>

    p2 = alloc_page();
ffffffffc0201d3c:	4505                	li	a0,1
ffffffffc0201d3e:	8e3ff0ef          	jal	ra,ffffffffc0201620 <alloc_pages>
ffffffffc0201d42:	8aaa                	mv	s5,a0
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc0201d44:	00093503          	ld	a0,0(s2)
ffffffffc0201d48:	46d1                	li	a3,20
ffffffffc0201d4a:	6605                	lui	a2,0x1
ffffffffc0201d4c:	85d6                	mv	a1,s5
ffffffffc0201d4e:	cc9ff0ef          	jal	ra,ffffffffc0201a16 <page_insert>
ffffffffc0201d52:	5c051f63          	bnez	a0,ffffffffc0202330 <pmm_init+0x81a>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0201d56:	00093503          	ld	a0,0(s2)
ffffffffc0201d5a:	4601                	li	a2,0
ffffffffc0201d5c:	6585                	lui	a1,0x1
ffffffffc0201d5e:	9cfff0ef          	jal	ra,ffffffffc020172c <get_pte>
ffffffffc0201d62:	12050ce3          	beqz	a0,ffffffffc020269a <pmm_init+0xb84>
    assert(*ptep & PTE_U);
ffffffffc0201d66:	611c                	ld	a5,0(a0)
ffffffffc0201d68:	0107f713          	andi	a4,a5,16
ffffffffc0201d6c:	72070f63          	beqz	a4,ffffffffc02024aa <pmm_init+0x994>
    assert(*ptep & PTE_W);
ffffffffc0201d70:	8b91                	andi	a5,a5,4
ffffffffc0201d72:	6e078c63          	beqz	a5,ffffffffc020246a <pmm_init+0x954>
    assert(boot_pgdir[0] & PTE_U);
ffffffffc0201d76:	00093503          	ld	a0,0(s2)
ffffffffc0201d7a:	611c                	ld	a5,0(a0)
ffffffffc0201d7c:	8bc1                	andi	a5,a5,16
ffffffffc0201d7e:	6c078663          	beqz	a5,ffffffffc020244a <pmm_init+0x934>
    assert(page_ref(p2) == 1);
ffffffffc0201d82:	000aa703          	lw	a4,0(s5)
ffffffffc0201d86:	4785                	li	a5,1
ffffffffc0201d88:	5cf71463          	bne	a4,a5,ffffffffc0202350 <pmm_init+0x83a>

    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
ffffffffc0201d8c:	4681                	li	a3,0
ffffffffc0201d8e:	6605                	lui	a2,0x1
ffffffffc0201d90:	85d2                	mv	a1,s4
ffffffffc0201d92:	c85ff0ef          	jal	ra,ffffffffc0201a16 <page_insert>
ffffffffc0201d96:	66051a63          	bnez	a0,ffffffffc020240a <pmm_init+0x8f4>
    assert(page_ref(p1) == 2);
ffffffffc0201d9a:	000a2703          	lw	a4,0(s4)
ffffffffc0201d9e:	4789                	li	a5,2
ffffffffc0201da0:	64f71563          	bne	a4,a5,ffffffffc02023ea <pmm_init+0x8d4>
    assert(page_ref(p2) == 0);
ffffffffc0201da4:	000aa783          	lw	a5,0(s5)
ffffffffc0201da8:	62079163          	bnez	a5,ffffffffc02023ca <pmm_init+0x8b4>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0201dac:	00093503          	ld	a0,0(s2)
ffffffffc0201db0:	4601                	li	a2,0
ffffffffc0201db2:	6585                	lui	a1,0x1
ffffffffc0201db4:	979ff0ef          	jal	ra,ffffffffc020172c <get_pte>
ffffffffc0201db8:	5e050963          	beqz	a0,ffffffffc02023aa <pmm_init+0x894>
    assert(pte2page(*ptep) == p1);
ffffffffc0201dbc:	6118                	ld	a4,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc0201dbe:	00177793          	andi	a5,a4,1
ffffffffc0201dc2:	50078563          	beqz	a5,ffffffffc02022cc <pmm_init+0x7b6>
    if (PPN(pa) >= npage) {
ffffffffc0201dc6:	6094                	ld	a3,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc0201dc8:	00271793          	slli	a5,a4,0x2
ffffffffc0201dcc:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201dce:	48d7f563          	bgeu	a5,a3,ffffffffc0202258 <pmm_init+0x742>
    return &pages[PPN(pa) - nbase];
ffffffffc0201dd2:	fff806b7          	lui	a3,0xfff80
ffffffffc0201dd6:	97b6                	add	a5,a5,a3
ffffffffc0201dd8:	000b3603          	ld	a2,0(s6)
ffffffffc0201ddc:	00379693          	slli	a3,a5,0x3
ffffffffc0201de0:	97b6                	add	a5,a5,a3
ffffffffc0201de2:	078e                	slli	a5,a5,0x3
ffffffffc0201de4:	97b2                	add	a5,a5,a2
ffffffffc0201de6:	72fa1263          	bne	s4,a5,ffffffffc020250a <pmm_init+0x9f4>
    assert((*ptep & PTE_U) == 0);
ffffffffc0201dea:	8b41                	andi	a4,a4,16
ffffffffc0201dec:	6e071f63          	bnez	a4,ffffffffc02024ea <pmm_init+0x9d4>

    page_remove(boot_pgdir, 0x0);
ffffffffc0201df0:	00093503          	ld	a0,0(s2)
ffffffffc0201df4:	4581                	li	a1,0
ffffffffc0201df6:	b87ff0ef          	jal	ra,ffffffffc020197c <page_remove>
    assert(page_ref(p1) == 1);
ffffffffc0201dfa:	000a2703          	lw	a4,0(s4)
ffffffffc0201dfe:	4785                	li	a5,1
ffffffffc0201e00:	6cf71563          	bne	a4,a5,ffffffffc02024ca <pmm_init+0x9b4>
    assert(page_ref(p2) == 0);
ffffffffc0201e04:	000aa783          	lw	a5,0(s5)
ffffffffc0201e08:	78079d63          	bnez	a5,ffffffffc02025a2 <pmm_init+0xa8c>

    page_remove(boot_pgdir, PGSIZE);
ffffffffc0201e0c:	00093503          	ld	a0,0(s2)
ffffffffc0201e10:	6585                	lui	a1,0x1
ffffffffc0201e12:	b6bff0ef          	jal	ra,ffffffffc020197c <page_remove>
    assert(page_ref(p1) == 0);
ffffffffc0201e16:	000a2783          	lw	a5,0(s4)
ffffffffc0201e1a:	76079463          	bnez	a5,ffffffffc0202582 <pmm_init+0xa6c>
    assert(page_ref(p2) == 0);
ffffffffc0201e1e:	000aa783          	lw	a5,0(s5)
ffffffffc0201e22:	74079063          	bnez	a5,ffffffffc0202562 <pmm_init+0xa4c>

    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
ffffffffc0201e26:	00093a03          	ld	s4,0(s2)
    if (PPN(pa) >= npage) {
ffffffffc0201e2a:	6090                	ld	a2,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0201e2c:	000a3783          	ld	a5,0(s4)
ffffffffc0201e30:	078a                	slli	a5,a5,0x2
ffffffffc0201e32:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201e34:	42c7f263          	bgeu	a5,a2,ffffffffc0202258 <pmm_init+0x742>
    return &pages[PPN(pa) - nbase];
ffffffffc0201e38:	fff80737          	lui	a4,0xfff80
ffffffffc0201e3c:	973e                	add	a4,a4,a5
ffffffffc0201e3e:	00371793          	slli	a5,a4,0x3
ffffffffc0201e42:	000b3503          	ld	a0,0(s6)
ffffffffc0201e46:	97ba                	add	a5,a5,a4
ffffffffc0201e48:	078e                	slli	a5,a5,0x3
static inline int page_ref(struct Page *page) { return page->ref; }
ffffffffc0201e4a:	00f50733          	add	a4,a0,a5
ffffffffc0201e4e:	4314                	lw	a3,0(a4)
ffffffffc0201e50:	4705                	li	a4,1
ffffffffc0201e52:	6ee69863          	bne	a3,a4,ffffffffc0202542 <pmm_init+0xa2c>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201e56:	4037d693          	srai	a3,a5,0x3
ffffffffc0201e5a:	00004c97          	auipc	s9,0x4
ffffffffc0201e5e:	496cbc83          	ld	s9,1174(s9) # ffffffffc02062f0 <error_string+0x38>
ffffffffc0201e62:	039686b3          	mul	a3,a3,s9
ffffffffc0201e66:	000805b7          	lui	a1,0x80
ffffffffc0201e6a:	96ae                	add	a3,a3,a1
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0201e6c:	00c69713          	slli	a4,a3,0xc
ffffffffc0201e70:	8331                	srli	a4,a4,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0201e72:	06b2                	slli	a3,a3,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0201e74:	6ac77b63          	bgeu	a4,a2,ffffffffc020252a <pmm_init+0xa14>

    pde_t *pd1=boot_pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
    free_page(pde2page(pd0[0]));
ffffffffc0201e78:	0009b703          	ld	a4,0(s3)
ffffffffc0201e7c:	96ba                	add	a3,a3,a4
    return pa2page(PDE_ADDR(pde));
ffffffffc0201e7e:	629c                	ld	a5,0(a3)
ffffffffc0201e80:	078a                	slli	a5,a5,0x2
ffffffffc0201e82:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201e84:	3cc7fa63          	bgeu	a5,a2,ffffffffc0202258 <pmm_init+0x742>
    return &pages[PPN(pa) - nbase];
ffffffffc0201e88:	8f8d                	sub	a5,a5,a1
ffffffffc0201e8a:	00379713          	slli	a4,a5,0x3
ffffffffc0201e8e:	97ba                	add	a5,a5,a4
ffffffffc0201e90:	078e                	slli	a5,a5,0x3
ffffffffc0201e92:	953e                	add	a0,a0,a5
ffffffffc0201e94:	100027f3          	csrr	a5,sstatus
ffffffffc0201e98:	8b89                	andi	a5,a5,2
ffffffffc0201e9a:	2e079963          	bnez	a5,ffffffffc020218c <pmm_init+0x676>
    { pmm_manager->free_pages(base, n); }
ffffffffc0201e9e:	000bb783          	ld	a5,0(s7)
ffffffffc0201ea2:	4585                	li	a1,1
ffffffffc0201ea4:	739c                	ld	a5,32(a5)
ffffffffc0201ea6:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc0201ea8:	000a3783          	ld	a5,0(s4)
    if (PPN(pa) >= npage) {
ffffffffc0201eac:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0201eae:	078a                	slli	a5,a5,0x2
ffffffffc0201eb0:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201eb2:	3ae7f363          	bgeu	a5,a4,ffffffffc0202258 <pmm_init+0x742>
    return &pages[PPN(pa) - nbase];
ffffffffc0201eb6:	fff80737          	lui	a4,0xfff80
ffffffffc0201eba:	97ba                	add	a5,a5,a4
ffffffffc0201ebc:	000b3503          	ld	a0,0(s6)
ffffffffc0201ec0:	00379713          	slli	a4,a5,0x3
ffffffffc0201ec4:	97ba                	add	a5,a5,a4
ffffffffc0201ec6:	078e                	slli	a5,a5,0x3
ffffffffc0201ec8:	953e                	add	a0,a0,a5
ffffffffc0201eca:	100027f3          	csrr	a5,sstatus
ffffffffc0201ece:	8b89                	andi	a5,a5,2
ffffffffc0201ed0:	2a079263          	bnez	a5,ffffffffc0202174 <pmm_init+0x65e>
ffffffffc0201ed4:	000bb783          	ld	a5,0(s7)
ffffffffc0201ed8:	4585                	li	a1,1
ffffffffc0201eda:	739c                	ld	a5,32(a5)
ffffffffc0201edc:	9782                	jalr	a5
    free_page(pde2page(pd1[0]));
    boot_pgdir[0] = 0;
ffffffffc0201ede:	00093783          	ld	a5,0(s2)
ffffffffc0201ee2:	0007b023          	sd	zero,0(a5) # fffffffffffff000 <end+0x3fdeda8c>
ffffffffc0201ee6:	100027f3          	csrr	a5,sstatus
ffffffffc0201eea:	8b89                	andi	a5,a5,2
ffffffffc0201eec:	26079a63          	bnez	a5,ffffffffc0202160 <pmm_init+0x64a>
    { ret = pmm_manager->nr_free_pages(); }
ffffffffc0201ef0:	000bb783          	ld	a5,0(s7)
ffffffffc0201ef4:	779c                	ld	a5,40(a5)
ffffffffc0201ef6:	9782                	jalr	a5
ffffffffc0201ef8:	8a2a                	mv	s4,a0

    assert(nr_free_store==nr_free_pages());
ffffffffc0201efa:	73441463          	bne	s0,s4,ffffffffc0202622 <pmm_init+0xb0c>

    cprintf("check_pgdir() succeeded!\n");
ffffffffc0201efe:	00003517          	auipc	a0,0x3
ffffffffc0201f02:	76a50513          	addi	a0,a0,1898 # ffffffffc0205668 <default_pmm_manager+0x460>
ffffffffc0201f06:	9b4fe0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc0201f0a:	100027f3          	csrr	a5,sstatus
ffffffffc0201f0e:	8b89                	andi	a5,a5,2
ffffffffc0201f10:	22079e63          	bnez	a5,ffffffffc020214c <pmm_init+0x636>
    { ret = pmm_manager->nr_free_pages(); }
ffffffffc0201f14:	000bb783          	ld	a5,0(s7)
ffffffffc0201f18:	779c                	ld	a5,40(a5)
ffffffffc0201f1a:	9782                	jalr	a5
ffffffffc0201f1c:	8c2a                	mv	s8,a0
    pte_t *ptep;
    int i;

    nr_free_store=nr_free_pages();

    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc0201f1e:	6098                	ld	a4,0(s1)
ffffffffc0201f20:	c0200437          	lui	s0,0xc0200
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0201f24:	7afd                	lui	s5,0xfffff
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc0201f26:	00c71793          	slli	a5,a4,0xc
ffffffffc0201f2a:	6a05                	lui	s4,0x1
ffffffffc0201f2c:	02f47c63          	bgeu	s0,a5,ffffffffc0201f64 <pmm_init+0x44e>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc0201f30:	00c45793          	srli	a5,s0,0xc
ffffffffc0201f34:	00093503          	ld	a0,0(s2)
ffffffffc0201f38:	30e7f363          	bgeu	a5,a4,ffffffffc020223e <pmm_init+0x728>
ffffffffc0201f3c:	0009b583          	ld	a1,0(s3)
ffffffffc0201f40:	4601                	li	a2,0
ffffffffc0201f42:	95a2                	add	a1,a1,s0
ffffffffc0201f44:	fe8ff0ef          	jal	ra,ffffffffc020172c <get_pte>
ffffffffc0201f48:	2c050b63          	beqz	a0,ffffffffc020221e <pmm_init+0x708>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0201f4c:	611c                	ld	a5,0(a0)
ffffffffc0201f4e:	078a                	slli	a5,a5,0x2
ffffffffc0201f50:	0157f7b3          	and	a5,a5,s5
ffffffffc0201f54:	2a879563          	bne	a5,s0,ffffffffc02021fe <pmm_init+0x6e8>
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc0201f58:	6098                	ld	a4,0(s1)
ffffffffc0201f5a:	9452                	add	s0,s0,s4
ffffffffc0201f5c:	00c71793          	slli	a5,a4,0xc
ffffffffc0201f60:	fcf468e3          	bltu	s0,a5,ffffffffc0201f30 <pmm_init+0x41a>
    }


    assert(boot_pgdir[0] == 0);
ffffffffc0201f64:	00093783          	ld	a5,0(s2)
ffffffffc0201f68:	639c                	ld	a5,0(a5)
ffffffffc0201f6a:	68079c63          	bnez	a5,ffffffffc0202602 <pmm_init+0xaec>

    struct Page *p;
    p = alloc_page();
ffffffffc0201f6e:	4505                	li	a0,1
ffffffffc0201f70:	eb0ff0ef          	jal	ra,ffffffffc0201620 <alloc_pages>
ffffffffc0201f74:	8aaa                	mv	s5,a0
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc0201f76:	00093503          	ld	a0,0(s2)
ffffffffc0201f7a:	4699                	li	a3,6
ffffffffc0201f7c:	10000613          	li	a2,256
ffffffffc0201f80:	85d6                	mv	a1,s5
ffffffffc0201f82:	a95ff0ef          	jal	ra,ffffffffc0201a16 <page_insert>
ffffffffc0201f86:	64051e63          	bnez	a0,ffffffffc02025e2 <pmm_init+0xacc>
    assert(page_ref(p) == 1);
ffffffffc0201f8a:	000aa703          	lw	a4,0(s5) # fffffffffffff000 <end+0x3fdeda8c>
ffffffffc0201f8e:	4785                	li	a5,1
ffffffffc0201f90:	62f71963          	bne	a4,a5,ffffffffc02025c2 <pmm_init+0xaac>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc0201f94:	00093503          	ld	a0,0(s2)
ffffffffc0201f98:	6405                	lui	s0,0x1
ffffffffc0201f9a:	4699                	li	a3,6
ffffffffc0201f9c:	10040613          	addi	a2,s0,256 # 1100 <kern_entry-0xffffffffc01fef00>
ffffffffc0201fa0:	85d6                	mv	a1,s5
ffffffffc0201fa2:	a75ff0ef          	jal	ra,ffffffffc0201a16 <page_insert>
ffffffffc0201fa6:	48051263          	bnez	a0,ffffffffc020242a <pmm_init+0x914>
    assert(page_ref(p) == 2);
ffffffffc0201faa:	000aa703          	lw	a4,0(s5)
ffffffffc0201fae:	4789                	li	a5,2
ffffffffc0201fb0:	74f71563          	bne	a4,a5,ffffffffc02026fa <pmm_init+0xbe4>

    const char *str = "ucore: Hello world!!";
    strcpy((void *)0x100, str);
ffffffffc0201fb4:	00003597          	auipc	a1,0x3
ffffffffc0201fb8:	7ec58593          	addi	a1,a1,2028 # ffffffffc02057a0 <default_pmm_manager+0x598>
ffffffffc0201fbc:	10000513          	li	a0,256
ffffffffc0201fc0:	446020ef          	jal	ra,ffffffffc0204406 <strcpy>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc0201fc4:	10040593          	addi	a1,s0,256
ffffffffc0201fc8:	10000513          	li	a0,256
ffffffffc0201fcc:	44c020ef          	jal	ra,ffffffffc0204418 <strcmp>
ffffffffc0201fd0:	70051563          	bnez	a0,ffffffffc02026da <pmm_init+0xbc4>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201fd4:	000b3683          	ld	a3,0(s6)
ffffffffc0201fd8:	00080d37          	lui	s10,0x80
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0201fdc:	547d                	li	s0,-1
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201fde:	40da86b3          	sub	a3,s5,a3
ffffffffc0201fe2:	868d                	srai	a3,a3,0x3
ffffffffc0201fe4:	039686b3          	mul	a3,a3,s9
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0201fe8:	609c                	ld	a5,0(s1)
ffffffffc0201fea:	8031                	srli	s0,s0,0xc
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201fec:	96ea                	add	a3,a3,s10
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0201fee:	0086f733          	and	a4,a3,s0
    return page2ppn(page) << PGSHIFT;
ffffffffc0201ff2:	06b2                	slli	a3,a3,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0201ff4:	52f77b63          	bgeu	a4,a5,ffffffffc020252a <pmm_init+0xa14>

    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc0201ff8:	0009b783          	ld	a5,0(s3)
    assert(strlen((const char *)0x100) == 0);
ffffffffc0201ffc:	10000513          	li	a0,256
    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc0202000:	96be                	add	a3,a3,a5
ffffffffc0202002:	10068023          	sb	zero,256(a3) # fffffffffff80100 <end+0x3fd6eb8c>
    assert(strlen((const char *)0x100) == 0);
ffffffffc0202006:	3ca020ef          	jal	ra,ffffffffc02043d0 <strlen>
ffffffffc020200a:	6a051863          	bnez	a0,ffffffffc02026ba <pmm_init+0xba4>

    pde_t *pd1=boot_pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
ffffffffc020200e:	00093a03          	ld	s4,0(s2)
    if (PPN(pa) >= npage) {
ffffffffc0202012:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202014:	000a3783          	ld	a5,0(s4) # 1000 <kern_entry-0xffffffffc01ff000>
ffffffffc0202018:	078a                	slli	a5,a5,0x2
ffffffffc020201a:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020201c:	22e7fe63          	bgeu	a5,a4,ffffffffc0202258 <pmm_init+0x742>
    return &pages[PPN(pa) - nbase];
ffffffffc0202020:	41a787b3          	sub	a5,a5,s10
ffffffffc0202024:	00379693          	slli	a3,a5,0x3
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0202028:	96be                	add	a3,a3,a5
ffffffffc020202a:	03968cb3          	mul	s9,a3,s9
ffffffffc020202e:	01ac86b3          	add	a3,s9,s10
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0202032:	8c75                	and	s0,s0,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc0202034:	06b2                	slli	a3,a3,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0202036:	4ee47a63          	bgeu	s0,a4,ffffffffc020252a <pmm_init+0xa14>
ffffffffc020203a:	0009b403          	ld	s0,0(s3)
ffffffffc020203e:	9436                	add	s0,s0,a3
ffffffffc0202040:	100027f3          	csrr	a5,sstatus
ffffffffc0202044:	8b89                	andi	a5,a5,2
ffffffffc0202046:	1a079163          	bnez	a5,ffffffffc02021e8 <pmm_init+0x6d2>
    { pmm_manager->free_pages(base, n); }
ffffffffc020204a:	000bb783          	ld	a5,0(s7)
ffffffffc020204e:	4585                	li	a1,1
ffffffffc0202050:	8556                	mv	a0,s5
ffffffffc0202052:	739c                	ld	a5,32(a5)
ffffffffc0202054:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc0202056:	601c                	ld	a5,0(s0)
    if (PPN(pa) >= npage) {
ffffffffc0202058:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc020205a:	078a                	slli	a5,a5,0x2
ffffffffc020205c:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020205e:	1ee7fd63          	bgeu	a5,a4,ffffffffc0202258 <pmm_init+0x742>
    return &pages[PPN(pa) - nbase];
ffffffffc0202062:	fff80737          	lui	a4,0xfff80
ffffffffc0202066:	97ba                	add	a5,a5,a4
ffffffffc0202068:	000b3503          	ld	a0,0(s6)
ffffffffc020206c:	00379713          	slli	a4,a5,0x3
ffffffffc0202070:	97ba                	add	a5,a5,a4
ffffffffc0202072:	078e                	slli	a5,a5,0x3
ffffffffc0202074:	953e                	add	a0,a0,a5
ffffffffc0202076:	100027f3          	csrr	a5,sstatus
ffffffffc020207a:	8b89                	andi	a5,a5,2
ffffffffc020207c:	14079a63          	bnez	a5,ffffffffc02021d0 <pmm_init+0x6ba>
ffffffffc0202080:	000bb783          	ld	a5,0(s7)
ffffffffc0202084:	4585                	li	a1,1
ffffffffc0202086:	739c                	ld	a5,32(a5)
ffffffffc0202088:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc020208a:	000a3783          	ld	a5,0(s4)
    if (PPN(pa) >= npage) {
ffffffffc020208e:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202090:	078a                	slli	a5,a5,0x2
ffffffffc0202092:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202094:	1ce7f263          	bgeu	a5,a4,ffffffffc0202258 <pmm_init+0x742>
    return &pages[PPN(pa) - nbase];
ffffffffc0202098:	fff80737          	lui	a4,0xfff80
ffffffffc020209c:	97ba                	add	a5,a5,a4
ffffffffc020209e:	000b3503          	ld	a0,0(s6)
ffffffffc02020a2:	00379713          	slli	a4,a5,0x3
ffffffffc02020a6:	97ba                	add	a5,a5,a4
ffffffffc02020a8:	078e                	slli	a5,a5,0x3
ffffffffc02020aa:	953e                	add	a0,a0,a5
ffffffffc02020ac:	100027f3          	csrr	a5,sstatus
ffffffffc02020b0:	8b89                	andi	a5,a5,2
ffffffffc02020b2:	10079363          	bnez	a5,ffffffffc02021b8 <pmm_init+0x6a2>
ffffffffc02020b6:	000bb783          	ld	a5,0(s7)
ffffffffc02020ba:	4585                	li	a1,1
ffffffffc02020bc:	739c                	ld	a5,32(a5)
ffffffffc02020be:	9782                	jalr	a5
    free_page(p);
    free_page(pde2page(pd0[0]));
    free_page(pde2page(pd1[0]));
    boot_pgdir[0] = 0;
ffffffffc02020c0:	00093783          	ld	a5,0(s2)
ffffffffc02020c4:	0007b023          	sd	zero,0(a5)
ffffffffc02020c8:	100027f3          	csrr	a5,sstatus
ffffffffc02020cc:	8b89                	andi	a5,a5,2
ffffffffc02020ce:	0c079b63          	bnez	a5,ffffffffc02021a4 <pmm_init+0x68e>
    { ret = pmm_manager->nr_free_pages(); }
ffffffffc02020d2:	000bb783          	ld	a5,0(s7)
ffffffffc02020d6:	779c                	ld	a5,40(a5)
ffffffffc02020d8:	9782                	jalr	a5
ffffffffc02020da:	842a                	mv	s0,a0

    assert(nr_free_store==nr_free_pages());
ffffffffc02020dc:	3a8c1763          	bne	s8,s0,ffffffffc020248a <pmm_init+0x974>
}
ffffffffc02020e0:	7406                	ld	s0,96(sp)
ffffffffc02020e2:	70a6                	ld	ra,104(sp)
ffffffffc02020e4:	64e6                	ld	s1,88(sp)
ffffffffc02020e6:	6946                	ld	s2,80(sp)
ffffffffc02020e8:	69a6                	ld	s3,72(sp)
ffffffffc02020ea:	6a06                	ld	s4,64(sp)
ffffffffc02020ec:	7ae2                	ld	s5,56(sp)
ffffffffc02020ee:	7b42                	ld	s6,48(sp)
ffffffffc02020f0:	7ba2                	ld	s7,40(sp)
ffffffffc02020f2:	7c02                	ld	s8,32(sp)
ffffffffc02020f4:	6ce2                	ld	s9,24(sp)
ffffffffc02020f6:	6d42                	ld	s10,16(sp)

    cprintf("check_boot_pgdir() succeeded!\n");
ffffffffc02020f8:	00003517          	auipc	a0,0x3
ffffffffc02020fc:	72050513          	addi	a0,a0,1824 # ffffffffc0205818 <default_pmm_manager+0x610>
}
ffffffffc0202100:	6165                	addi	sp,sp,112
    cprintf("check_boot_pgdir() succeeded!\n");
ffffffffc0202102:	fb9fd06f          	j	ffffffffc02000ba <cprintf>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc0202106:	6705                	lui	a4,0x1
ffffffffc0202108:	177d                	addi	a4,a4,-1
ffffffffc020210a:	96ba                	add	a3,a3,a4
ffffffffc020210c:	777d                	lui	a4,0xfffff
ffffffffc020210e:	8f75                	and	a4,a4,a3
    if (PPN(pa) >= npage) {
ffffffffc0202110:	00c75693          	srli	a3,a4,0xc
ffffffffc0202114:	14f6f263          	bgeu	a3,a5,ffffffffc0202258 <pmm_init+0x742>
    pmm_manager->init_memmap(base, n);
ffffffffc0202118:	000bb803          	ld	a6,0(s7)
    return &pages[PPN(pa) - nbase];
ffffffffc020211c:	95b6                	add	a1,a1,a3
ffffffffc020211e:	00359793          	slli	a5,a1,0x3
ffffffffc0202122:	97ae                	add	a5,a5,a1
ffffffffc0202124:	01083683          	ld	a3,16(a6)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc0202128:	40e60733          	sub	a4,a2,a4
ffffffffc020212c:	078e                	slli	a5,a5,0x3
    pmm_manager->init_memmap(base, n);
ffffffffc020212e:	00c75593          	srli	a1,a4,0xc
ffffffffc0202132:	953e                	add	a0,a0,a5
ffffffffc0202134:	9682                	jalr	a3
}
ffffffffc0202136:	bcc5                	j	ffffffffc0201c26 <pmm_init+0x110>
        intr_disable();
ffffffffc0202138:	bb6fe0ef          	jal	ra,ffffffffc02004ee <intr_disable>
    { ret = pmm_manager->nr_free_pages(); }
ffffffffc020213c:	000bb783          	ld	a5,0(s7)
ffffffffc0202140:	779c                	ld	a5,40(a5)
ffffffffc0202142:	9782                	jalr	a5
ffffffffc0202144:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0202146:	ba2fe0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
ffffffffc020214a:	b63d                	j	ffffffffc0201c78 <pmm_init+0x162>
        intr_disable();
ffffffffc020214c:	ba2fe0ef          	jal	ra,ffffffffc02004ee <intr_disable>
ffffffffc0202150:	000bb783          	ld	a5,0(s7)
ffffffffc0202154:	779c                	ld	a5,40(a5)
ffffffffc0202156:	9782                	jalr	a5
ffffffffc0202158:	8c2a                	mv	s8,a0
        intr_enable();
ffffffffc020215a:	b8efe0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
ffffffffc020215e:	b3c1                	j	ffffffffc0201f1e <pmm_init+0x408>
        intr_disable();
ffffffffc0202160:	b8efe0ef          	jal	ra,ffffffffc02004ee <intr_disable>
ffffffffc0202164:	000bb783          	ld	a5,0(s7)
ffffffffc0202168:	779c                	ld	a5,40(a5)
ffffffffc020216a:	9782                	jalr	a5
ffffffffc020216c:	8a2a                	mv	s4,a0
        intr_enable();
ffffffffc020216e:	b7afe0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
ffffffffc0202172:	b361                	j	ffffffffc0201efa <pmm_init+0x3e4>
ffffffffc0202174:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0202176:	b78fe0ef          	jal	ra,ffffffffc02004ee <intr_disable>
    { pmm_manager->free_pages(base, n); }
ffffffffc020217a:	000bb783          	ld	a5,0(s7)
ffffffffc020217e:	6522                	ld	a0,8(sp)
ffffffffc0202180:	4585                	li	a1,1
ffffffffc0202182:	739c                	ld	a5,32(a5)
ffffffffc0202184:	9782                	jalr	a5
        intr_enable();
ffffffffc0202186:	b62fe0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
ffffffffc020218a:	bb91                	j	ffffffffc0201ede <pmm_init+0x3c8>
ffffffffc020218c:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc020218e:	b60fe0ef          	jal	ra,ffffffffc02004ee <intr_disable>
ffffffffc0202192:	000bb783          	ld	a5,0(s7)
ffffffffc0202196:	6522                	ld	a0,8(sp)
ffffffffc0202198:	4585                	li	a1,1
ffffffffc020219a:	739c                	ld	a5,32(a5)
ffffffffc020219c:	9782                	jalr	a5
        intr_enable();
ffffffffc020219e:	b4afe0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
ffffffffc02021a2:	b319                	j	ffffffffc0201ea8 <pmm_init+0x392>
        intr_disable();
ffffffffc02021a4:	b4afe0ef          	jal	ra,ffffffffc02004ee <intr_disable>
    { ret = pmm_manager->nr_free_pages(); }
ffffffffc02021a8:	000bb783          	ld	a5,0(s7)
ffffffffc02021ac:	779c                	ld	a5,40(a5)
ffffffffc02021ae:	9782                	jalr	a5
ffffffffc02021b0:	842a                	mv	s0,a0
        intr_enable();
ffffffffc02021b2:	b36fe0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
ffffffffc02021b6:	b71d                	j	ffffffffc02020dc <pmm_init+0x5c6>
ffffffffc02021b8:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc02021ba:	b34fe0ef          	jal	ra,ffffffffc02004ee <intr_disable>
    { pmm_manager->free_pages(base, n); }
ffffffffc02021be:	000bb783          	ld	a5,0(s7)
ffffffffc02021c2:	6522                	ld	a0,8(sp)
ffffffffc02021c4:	4585                	li	a1,1
ffffffffc02021c6:	739c                	ld	a5,32(a5)
ffffffffc02021c8:	9782                	jalr	a5
        intr_enable();
ffffffffc02021ca:	b1efe0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
ffffffffc02021ce:	bdcd                	j	ffffffffc02020c0 <pmm_init+0x5aa>
ffffffffc02021d0:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc02021d2:	b1cfe0ef          	jal	ra,ffffffffc02004ee <intr_disable>
ffffffffc02021d6:	000bb783          	ld	a5,0(s7)
ffffffffc02021da:	6522                	ld	a0,8(sp)
ffffffffc02021dc:	4585                	li	a1,1
ffffffffc02021de:	739c                	ld	a5,32(a5)
ffffffffc02021e0:	9782                	jalr	a5
        intr_enable();
ffffffffc02021e2:	b06fe0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
ffffffffc02021e6:	b555                	j	ffffffffc020208a <pmm_init+0x574>
        intr_disable();
ffffffffc02021e8:	b06fe0ef          	jal	ra,ffffffffc02004ee <intr_disable>
ffffffffc02021ec:	000bb783          	ld	a5,0(s7)
ffffffffc02021f0:	4585                	li	a1,1
ffffffffc02021f2:	8556                	mv	a0,s5
ffffffffc02021f4:	739c                	ld	a5,32(a5)
ffffffffc02021f6:	9782                	jalr	a5
        intr_enable();
ffffffffc02021f8:	af0fe0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
ffffffffc02021fc:	bda9                	j	ffffffffc0202056 <pmm_init+0x540>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc02021fe:	00003697          	auipc	a3,0x3
ffffffffc0202202:	4ca68693          	addi	a3,a3,1226 # ffffffffc02056c8 <default_pmm_manager+0x4c0>
ffffffffc0202206:	00003617          	auipc	a2,0x3
ffffffffc020220a:	c5260613          	addi	a2,a2,-942 # ffffffffc0204e58 <commands+0x788>
ffffffffc020220e:	1ce00593          	li	a1,462
ffffffffc0202212:	00003517          	auipc	a0,0x3
ffffffffc0202216:	0ae50513          	addi	a0,a0,174 # ffffffffc02052c0 <default_pmm_manager+0xb8>
ffffffffc020221a:	95afe0ef          	jal	ra,ffffffffc0200374 <__panic>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc020221e:	00003697          	auipc	a3,0x3
ffffffffc0202222:	46a68693          	addi	a3,a3,1130 # ffffffffc0205688 <default_pmm_manager+0x480>
ffffffffc0202226:	00003617          	auipc	a2,0x3
ffffffffc020222a:	c3260613          	addi	a2,a2,-974 # ffffffffc0204e58 <commands+0x788>
ffffffffc020222e:	1cd00593          	li	a1,461
ffffffffc0202232:	00003517          	auipc	a0,0x3
ffffffffc0202236:	08e50513          	addi	a0,a0,142 # ffffffffc02052c0 <default_pmm_manager+0xb8>
ffffffffc020223a:	93afe0ef          	jal	ra,ffffffffc0200374 <__panic>
ffffffffc020223e:	86a2                	mv	a3,s0
ffffffffc0202240:	00003617          	auipc	a2,0x3
ffffffffc0202244:	05860613          	addi	a2,a2,88 # ffffffffc0205298 <default_pmm_manager+0x90>
ffffffffc0202248:	1cd00593          	li	a1,461
ffffffffc020224c:	00003517          	auipc	a0,0x3
ffffffffc0202250:	07450513          	addi	a0,a0,116 # ffffffffc02052c0 <default_pmm_manager+0xb8>
ffffffffc0202254:	920fe0ef          	jal	ra,ffffffffc0200374 <__panic>
ffffffffc0202258:	b90ff0ef          	jal	ra,ffffffffc02015e8 <pa2page.part.0>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc020225c:	00003617          	auipc	a2,0x3
ffffffffc0202260:	0fc60613          	addi	a2,a2,252 # ffffffffc0205358 <default_pmm_manager+0x150>
ffffffffc0202264:	07700593          	li	a1,119
ffffffffc0202268:	00003517          	auipc	a0,0x3
ffffffffc020226c:	05850513          	addi	a0,a0,88 # ffffffffc02052c0 <default_pmm_manager+0xb8>
ffffffffc0202270:	904fe0ef          	jal	ra,ffffffffc0200374 <__panic>
    boot_cr3 = PADDR(boot_pgdir);
ffffffffc0202274:	00003617          	auipc	a2,0x3
ffffffffc0202278:	0e460613          	addi	a2,a2,228 # ffffffffc0205358 <default_pmm_manager+0x150>
ffffffffc020227c:	0bd00593          	li	a1,189
ffffffffc0202280:	00003517          	auipc	a0,0x3
ffffffffc0202284:	04050513          	addi	a0,a0,64 # ffffffffc02052c0 <default_pmm_manager+0xb8>
ffffffffc0202288:	8ecfe0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
ffffffffc020228c:	00003697          	auipc	a3,0x3
ffffffffc0202290:	13468693          	addi	a3,a3,308 # ffffffffc02053c0 <default_pmm_manager+0x1b8>
ffffffffc0202294:	00003617          	auipc	a2,0x3
ffffffffc0202298:	bc460613          	addi	a2,a2,-1084 # ffffffffc0204e58 <commands+0x788>
ffffffffc020229c:	19300593          	li	a1,403
ffffffffc02022a0:	00003517          	auipc	a0,0x3
ffffffffc02022a4:	02050513          	addi	a0,a0,32 # ffffffffc02052c0 <default_pmm_manager+0xb8>
ffffffffc02022a8:	8ccfe0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(npage <= KERNTOP / PGSIZE);
ffffffffc02022ac:	00003697          	auipc	a3,0x3
ffffffffc02022b0:	0f468693          	addi	a3,a3,244 # ffffffffc02053a0 <default_pmm_manager+0x198>
ffffffffc02022b4:	00003617          	auipc	a2,0x3
ffffffffc02022b8:	ba460613          	addi	a2,a2,-1116 # ffffffffc0204e58 <commands+0x788>
ffffffffc02022bc:	19200593          	li	a1,402
ffffffffc02022c0:	00003517          	auipc	a0,0x3
ffffffffc02022c4:	00050513          	mv	a0,a0
ffffffffc02022c8:	8acfe0ef          	jal	ra,ffffffffc0200374 <__panic>
ffffffffc02022cc:	b38ff0ef          	jal	ra,ffffffffc0201604 <pte2page.part.0>
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
ffffffffc02022d0:	00003697          	auipc	a3,0x3
ffffffffc02022d4:	18068693          	addi	a3,a3,384 # ffffffffc0205450 <default_pmm_manager+0x248>
ffffffffc02022d8:	00003617          	auipc	a2,0x3
ffffffffc02022dc:	b8060613          	addi	a2,a2,-1152 # ffffffffc0204e58 <commands+0x788>
ffffffffc02022e0:	19a00593          	li	a1,410
ffffffffc02022e4:	00003517          	auipc	a0,0x3
ffffffffc02022e8:	fdc50513          	addi	a0,a0,-36 # ffffffffc02052c0 <default_pmm_manager+0xb8>
ffffffffc02022ec:	888fe0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
ffffffffc02022f0:	00003697          	auipc	a3,0x3
ffffffffc02022f4:	13068693          	addi	a3,a3,304 # ffffffffc0205420 <default_pmm_manager+0x218>
ffffffffc02022f8:	00003617          	auipc	a2,0x3
ffffffffc02022fc:	b6060613          	addi	a2,a2,-1184 # ffffffffc0204e58 <commands+0x788>
ffffffffc0202300:	19800593          	li	a1,408
ffffffffc0202304:	00003517          	auipc	a0,0x3
ffffffffc0202308:	fbc50513          	addi	a0,a0,-68 # ffffffffc02052c0 <default_pmm_manager+0xb8>
ffffffffc020230c:	868fe0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
ffffffffc0202310:	00003697          	auipc	a3,0x3
ffffffffc0202314:	0e868693          	addi	a3,a3,232 # ffffffffc02053f8 <default_pmm_manager+0x1f0>
ffffffffc0202318:	00003617          	auipc	a2,0x3
ffffffffc020231c:	b4060613          	addi	a2,a2,-1216 # ffffffffc0204e58 <commands+0x788>
ffffffffc0202320:	19400593          	li	a1,404
ffffffffc0202324:	00003517          	auipc	a0,0x3
ffffffffc0202328:	f9c50513          	addi	a0,a0,-100 # ffffffffc02052c0 <default_pmm_manager+0xb8>
ffffffffc020232c:	848fe0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc0202330:	00003697          	auipc	a3,0x3
ffffffffc0202334:	1a868693          	addi	a3,a3,424 # ffffffffc02054d8 <default_pmm_manager+0x2d0>
ffffffffc0202338:	00003617          	auipc	a2,0x3
ffffffffc020233c:	b2060613          	addi	a2,a2,-1248 # ffffffffc0204e58 <commands+0x788>
ffffffffc0202340:	1a300593          	li	a1,419
ffffffffc0202344:	00003517          	auipc	a0,0x3
ffffffffc0202348:	f7c50513          	addi	a0,a0,-132 # ffffffffc02052c0 <default_pmm_manager+0xb8>
ffffffffc020234c:	828fe0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_ref(p2) == 1);
ffffffffc0202350:	00003697          	auipc	a3,0x3
ffffffffc0202354:	22868693          	addi	a3,a3,552 # ffffffffc0205578 <default_pmm_manager+0x370>
ffffffffc0202358:	00003617          	auipc	a2,0x3
ffffffffc020235c:	b0060613          	addi	a2,a2,-1280 # ffffffffc0204e58 <commands+0x788>
ffffffffc0202360:	1a800593          	li	a1,424
ffffffffc0202364:	00003517          	auipc	a0,0x3
ffffffffc0202368:	f5c50513          	addi	a0,a0,-164 # ffffffffc02052c0 <default_pmm_manager+0xb8>
ffffffffc020236c:	808fe0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0202370:	00003697          	auipc	a3,0x3
ffffffffc0202374:	14068693          	addi	a3,a3,320 # ffffffffc02054b0 <default_pmm_manager+0x2a8>
ffffffffc0202378:	00003617          	auipc	a2,0x3
ffffffffc020237c:	ae060613          	addi	a2,a2,-1312 # ffffffffc0204e58 <commands+0x788>
ffffffffc0202380:	1a000593          	li	a1,416
ffffffffc0202384:	00003517          	auipc	a0,0x3
ffffffffc0202388:	f3c50513          	addi	a0,a0,-196 # ffffffffc02052c0 <default_pmm_manager+0xb8>
ffffffffc020238c:	fe9fd0ef          	jal	ra,ffffffffc0200374 <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0202390:	86d6                	mv	a3,s5
ffffffffc0202392:	00003617          	auipc	a2,0x3
ffffffffc0202396:	f0660613          	addi	a2,a2,-250 # ffffffffc0205298 <default_pmm_manager+0x90>
ffffffffc020239a:	19f00593          	li	a1,415
ffffffffc020239e:	00003517          	auipc	a0,0x3
ffffffffc02023a2:	f2250513          	addi	a0,a0,-222 # ffffffffc02052c0 <default_pmm_manager+0xb8>
ffffffffc02023a6:	fcffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc02023aa:	00003697          	auipc	a3,0x3
ffffffffc02023ae:	16668693          	addi	a3,a3,358 # ffffffffc0205510 <default_pmm_manager+0x308>
ffffffffc02023b2:	00003617          	auipc	a2,0x3
ffffffffc02023b6:	aa660613          	addi	a2,a2,-1370 # ffffffffc0204e58 <commands+0x788>
ffffffffc02023ba:	1ad00593          	li	a1,429
ffffffffc02023be:	00003517          	auipc	a0,0x3
ffffffffc02023c2:	f0250513          	addi	a0,a0,-254 # ffffffffc02052c0 <default_pmm_manager+0xb8>
ffffffffc02023c6:	faffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc02023ca:	00003697          	auipc	a3,0x3
ffffffffc02023ce:	20e68693          	addi	a3,a3,526 # ffffffffc02055d8 <default_pmm_manager+0x3d0>
ffffffffc02023d2:	00003617          	auipc	a2,0x3
ffffffffc02023d6:	a8660613          	addi	a2,a2,-1402 # ffffffffc0204e58 <commands+0x788>
ffffffffc02023da:	1ac00593          	li	a1,428
ffffffffc02023de:	00003517          	auipc	a0,0x3
ffffffffc02023e2:	ee250513          	addi	a0,a0,-286 # ffffffffc02052c0 <default_pmm_manager+0xb8>
ffffffffc02023e6:	f8ffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_ref(p1) == 2);
ffffffffc02023ea:	00003697          	auipc	a3,0x3
ffffffffc02023ee:	1d668693          	addi	a3,a3,470 # ffffffffc02055c0 <default_pmm_manager+0x3b8>
ffffffffc02023f2:	00003617          	auipc	a2,0x3
ffffffffc02023f6:	a6660613          	addi	a2,a2,-1434 # ffffffffc0204e58 <commands+0x788>
ffffffffc02023fa:	1ab00593          	li	a1,427
ffffffffc02023fe:	00003517          	auipc	a0,0x3
ffffffffc0202402:	ec250513          	addi	a0,a0,-318 # ffffffffc02052c0 <default_pmm_manager+0xb8>
ffffffffc0202406:	f6ffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
ffffffffc020240a:	00003697          	auipc	a3,0x3
ffffffffc020240e:	18668693          	addi	a3,a3,390 # ffffffffc0205590 <default_pmm_manager+0x388>
ffffffffc0202412:	00003617          	auipc	a2,0x3
ffffffffc0202416:	a4660613          	addi	a2,a2,-1466 # ffffffffc0204e58 <commands+0x788>
ffffffffc020241a:	1aa00593          	li	a1,426
ffffffffc020241e:	00003517          	auipc	a0,0x3
ffffffffc0202422:	ea250513          	addi	a0,a0,-350 # ffffffffc02052c0 <default_pmm_manager+0xb8>
ffffffffc0202426:	f4ffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc020242a:	00003697          	auipc	a3,0x3
ffffffffc020242e:	31e68693          	addi	a3,a3,798 # ffffffffc0205748 <default_pmm_manager+0x540>
ffffffffc0202432:	00003617          	auipc	a2,0x3
ffffffffc0202436:	a2660613          	addi	a2,a2,-1498 # ffffffffc0204e58 <commands+0x788>
ffffffffc020243a:	1d800593          	li	a1,472
ffffffffc020243e:	00003517          	auipc	a0,0x3
ffffffffc0202442:	e8250513          	addi	a0,a0,-382 # ffffffffc02052c0 <default_pmm_manager+0xb8>
ffffffffc0202446:	f2ffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(boot_pgdir[0] & PTE_U);
ffffffffc020244a:	00003697          	auipc	a3,0x3
ffffffffc020244e:	11668693          	addi	a3,a3,278 # ffffffffc0205560 <default_pmm_manager+0x358>
ffffffffc0202452:	00003617          	auipc	a2,0x3
ffffffffc0202456:	a0660613          	addi	a2,a2,-1530 # ffffffffc0204e58 <commands+0x788>
ffffffffc020245a:	1a700593          	li	a1,423
ffffffffc020245e:	00003517          	auipc	a0,0x3
ffffffffc0202462:	e6250513          	addi	a0,a0,-414 # ffffffffc02052c0 <default_pmm_manager+0xb8>
ffffffffc0202466:	f0ffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(*ptep & PTE_W);
ffffffffc020246a:	00003697          	auipc	a3,0x3
ffffffffc020246e:	0e668693          	addi	a3,a3,230 # ffffffffc0205550 <default_pmm_manager+0x348>
ffffffffc0202472:	00003617          	auipc	a2,0x3
ffffffffc0202476:	9e660613          	addi	a2,a2,-1562 # ffffffffc0204e58 <commands+0x788>
ffffffffc020247a:	1a600593          	li	a1,422
ffffffffc020247e:	00003517          	auipc	a0,0x3
ffffffffc0202482:	e4250513          	addi	a0,a0,-446 # ffffffffc02052c0 <default_pmm_manager+0xb8>
ffffffffc0202486:	eeffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(nr_free_store==nr_free_pages());
ffffffffc020248a:	00003697          	auipc	a3,0x3
ffffffffc020248e:	1be68693          	addi	a3,a3,446 # ffffffffc0205648 <default_pmm_manager+0x440>
ffffffffc0202492:	00003617          	auipc	a2,0x3
ffffffffc0202496:	9c660613          	addi	a2,a2,-1594 # ffffffffc0204e58 <commands+0x788>
ffffffffc020249a:	1e800593          	li	a1,488
ffffffffc020249e:	00003517          	auipc	a0,0x3
ffffffffc02024a2:	e2250513          	addi	a0,a0,-478 # ffffffffc02052c0 <default_pmm_manager+0xb8>
ffffffffc02024a6:	ecffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(*ptep & PTE_U);
ffffffffc02024aa:	00003697          	auipc	a3,0x3
ffffffffc02024ae:	09668693          	addi	a3,a3,150 # ffffffffc0205540 <default_pmm_manager+0x338>
ffffffffc02024b2:	00003617          	auipc	a2,0x3
ffffffffc02024b6:	9a660613          	addi	a2,a2,-1626 # ffffffffc0204e58 <commands+0x788>
ffffffffc02024ba:	1a500593          	li	a1,421
ffffffffc02024be:	00003517          	auipc	a0,0x3
ffffffffc02024c2:	e0250513          	addi	a0,a0,-510 # ffffffffc02052c0 <default_pmm_manager+0xb8>
ffffffffc02024c6:	eaffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_ref(p1) == 1);
ffffffffc02024ca:	00003697          	auipc	a3,0x3
ffffffffc02024ce:	fce68693          	addi	a3,a3,-50 # ffffffffc0205498 <default_pmm_manager+0x290>
ffffffffc02024d2:	00003617          	auipc	a2,0x3
ffffffffc02024d6:	98660613          	addi	a2,a2,-1658 # ffffffffc0204e58 <commands+0x788>
ffffffffc02024da:	1b200593          	li	a1,434
ffffffffc02024de:	00003517          	auipc	a0,0x3
ffffffffc02024e2:	de250513          	addi	a0,a0,-542 # ffffffffc02052c0 <default_pmm_manager+0xb8>
ffffffffc02024e6:	e8ffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert((*ptep & PTE_U) == 0);
ffffffffc02024ea:	00003697          	auipc	a3,0x3
ffffffffc02024ee:	10668693          	addi	a3,a3,262 # ffffffffc02055f0 <default_pmm_manager+0x3e8>
ffffffffc02024f2:	00003617          	auipc	a2,0x3
ffffffffc02024f6:	96660613          	addi	a2,a2,-1690 # ffffffffc0204e58 <commands+0x788>
ffffffffc02024fa:	1af00593          	li	a1,431
ffffffffc02024fe:	00003517          	auipc	a0,0x3
ffffffffc0202502:	dc250513          	addi	a0,a0,-574 # ffffffffc02052c0 <default_pmm_manager+0xb8>
ffffffffc0202506:	e6ffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc020250a:	00003697          	auipc	a3,0x3
ffffffffc020250e:	f7668693          	addi	a3,a3,-138 # ffffffffc0205480 <default_pmm_manager+0x278>
ffffffffc0202512:	00003617          	auipc	a2,0x3
ffffffffc0202516:	94660613          	addi	a2,a2,-1722 # ffffffffc0204e58 <commands+0x788>
ffffffffc020251a:	1ae00593          	li	a1,430
ffffffffc020251e:	00003517          	auipc	a0,0x3
ffffffffc0202522:	da250513          	addi	a0,a0,-606 # ffffffffc02052c0 <default_pmm_manager+0xb8>
ffffffffc0202526:	e4ffd0ef          	jal	ra,ffffffffc0200374 <__panic>
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc020252a:	00003617          	auipc	a2,0x3
ffffffffc020252e:	d6e60613          	addi	a2,a2,-658 # ffffffffc0205298 <default_pmm_manager+0x90>
ffffffffc0202532:	06a00593          	li	a1,106
ffffffffc0202536:	00003517          	auipc	a0,0x3
ffffffffc020253a:	d2a50513          	addi	a0,a0,-726 # ffffffffc0205260 <default_pmm_manager+0x58>
ffffffffc020253e:	e37fd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
ffffffffc0202542:	00003697          	auipc	a3,0x3
ffffffffc0202546:	0de68693          	addi	a3,a3,222 # ffffffffc0205620 <default_pmm_manager+0x418>
ffffffffc020254a:	00003617          	auipc	a2,0x3
ffffffffc020254e:	90e60613          	addi	a2,a2,-1778 # ffffffffc0204e58 <commands+0x788>
ffffffffc0202552:	1b900593          	li	a1,441
ffffffffc0202556:	00003517          	auipc	a0,0x3
ffffffffc020255a:	d6a50513          	addi	a0,a0,-662 # ffffffffc02052c0 <default_pmm_manager+0xb8>
ffffffffc020255e:	e17fd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0202562:	00003697          	auipc	a3,0x3
ffffffffc0202566:	07668693          	addi	a3,a3,118 # ffffffffc02055d8 <default_pmm_manager+0x3d0>
ffffffffc020256a:	00003617          	auipc	a2,0x3
ffffffffc020256e:	8ee60613          	addi	a2,a2,-1810 # ffffffffc0204e58 <commands+0x788>
ffffffffc0202572:	1b700593          	li	a1,439
ffffffffc0202576:	00003517          	auipc	a0,0x3
ffffffffc020257a:	d4a50513          	addi	a0,a0,-694 # ffffffffc02052c0 <default_pmm_manager+0xb8>
ffffffffc020257e:	df7fd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_ref(p1) == 0);
ffffffffc0202582:	00003697          	auipc	a3,0x3
ffffffffc0202586:	08668693          	addi	a3,a3,134 # ffffffffc0205608 <default_pmm_manager+0x400>
ffffffffc020258a:	00003617          	auipc	a2,0x3
ffffffffc020258e:	8ce60613          	addi	a2,a2,-1842 # ffffffffc0204e58 <commands+0x788>
ffffffffc0202592:	1b600593          	li	a1,438
ffffffffc0202596:	00003517          	auipc	a0,0x3
ffffffffc020259a:	d2a50513          	addi	a0,a0,-726 # ffffffffc02052c0 <default_pmm_manager+0xb8>
ffffffffc020259e:	dd7fd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc02025a2:	00003697          	auipc	a3,0x3
ffffffffc02025a6:	03668693          	addi	a3,a3,54 # ffffffffc02055d8 <default_pmm_manager+0x3d0>
ffffffffc02025aa:	00003617          	auipc	a2,0x3
ffffffffc02025ae:	8ae60613          	addi	a2,a2,-1874 # ffffffffc0204e58 <commands+0x788>
ffffffffc02025b2:	1b300593          	li	a1,435
ffffffffc02025b6:	00003517          	auipc	a0,0x3
ffffffffc02025ba:	d0a50513          	addi	a0,a0,-758 # ffffffffc02052c0 <default_pmm_manager+0xb8>
ffffffffc02025be:	db7fd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_ref(p) == 1);
ffffffffc02025c2:	00003697          	auipc	a3,0x3
ffffffffc02025c6:	16e68693          	addi	a3,a3,366 # ffffffffc0205730 <default_pmm_manager+0x528>
ffffffffc02025ca:	00003617          	auipc	a2,0x3
ffffffffc02025ce:	88e60613          	addi	a2,a2,-1906 # ffffffffc0204e58 <commands+0x788>
ffffffffc02025d2:	1d700593          	li	a1,471
ffffffffc02025d6:	00003517          	auipc	a0,0x3
ffffffffc02025da:	cea50513          	addi	a0,a0,-790 # ffffffffc02052c0 <default_pmm_manager+0xb8>
ffffffffc02025de:	d97fd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc02025e2:	00003697          	auipc	a3,0x3
ffffffffc02025e6:	11668693          	addi	a3,a3,278 # ffffffffc02056f8 <default_pmm_manager+0x4f0>
ffffffffc02025ea:	00003617          	auipc	a2,0x3
ffffffffc02025ee:	86e60613          	addi	a2,a2,-1938 # ffffffffc0204e58 <commands+0x788>
ffffffffc02025f2:	1d600593          	li	a1,470
ffffffffc02025f6:	00003517          	auipc	a0,0x3
ffffffffc02025fa:	cca50513          	addi	a0,a0,-822 # ffffffffc02052c0 <default_pmm_manager+0xb8>
ffffffffc02025fe:	d77fd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(boot_pgdir[0] == 0);
ffffffffc0202602:	00003697          	auipc	a3,0x3
ffffffffc0202606:	0de68693          	addi	a3,a3,222 # ffffffffc02056e0 <default_pmm_manager+0x4d8>
ffffffffc020260a:	00003617          	auipc	a2,0x3
ffffffffc020260e:	84e60613          	addi	a2,a2,-1970 # ffffffffc0204e58 <commands+0x788>
ffffffffc0202612:	1d200593          	li	a1,466
ffffffffc0202616:	00003517          	auipc	a0,0x3
ffffffffc020261a:	caa50513          	addi	a0,a0,-854 # ffffffffc02052c0 <default_pmm_manager+0xb8>
ffffffffc020261e:	d57fd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(nr_free_store==nr_free_pages());
ffffffffc0202622:	00003697          	auipc	a3,0x3
ffffffffc0202626:	02668693          	addi	a3,a3,38 # ffffffffc0205648 <default_pmm_manager+0x440>
ffffffffc020262a:	00003617          	auipc	a2,0x3
ffffffffc020262e:	82e60613          	addi	a2,a2,-2002 # ffffffffc0204e58 <commands+0x788>
ffffffffc0202632:	1c000593          	li	a1,448
ffffffffc0202636:	00003517          	auipc	a0,0x3
ffffffffc020263a:	c8a50513          	addi	a0,a0,-886 # ffffffffc02052c0 <default_pmm_manager+0xb8>
ffffffffc020263e:	d37fd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc0202642:	00003697          	auipc	a3,0x3
ffffffffc0202646:	e3e68693          	addi	a3,a3,-450 # ffffffffc0205480 <default_pmm_manager+0x278>
ffffffffc020264a:	00003617          	auipc	a2,0x3
ffffffffc020264e:	80e60613          	addi	a2,a2,-2034 # ffffffffc0204e58 <commands+0x788>
ffffffffc0202652:	19b00593          	li	a1,411
ffffffffc0202656:	00003517          	auipc	a0,0x3
ffffffffc020265a:	c6a50513          	addi	a0,a0,-918 # ffffffffc02052c0 <default_pmm_manager+0xb8>
ffffffffc020265e:	d17fd0ef          	jal	ra,ffffffffc0200374 <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir[0]));
ffffffffc0202662:	00003617          	auipc	a2,0x3
ffffffffc0202666:	c3660613          	addi	a2,a2,-970 # ffffffffc0205298 <default_pmm_manager+0x90>
ffffffffc020266a:	19e00593          	li	a1,414
ffffffffc020266e:	00003517          	auipc	a0,0x3
ffffffffc0202672:	c5250513          	addi	a0,a0,-942 # ffffffffc02052c0 <default_pmm_manager+0xb8>
ffffffffc0202676:	cfffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_ref(p1) == 1);
ffffffffc020267a:	00003697          	auipc	a3,0x3
ffffffffc020267e:	e1e68693          	addi	a3,a3,-482 # ffffffffc0205498 <default_pmm_manager+0x290>
ffffffffc0202682:	00002617          	auipc	a2,0x2
ffffffffc0202686:	7d660613          	addi	a2,a2,2006 # ffffffffc0204e58 <commands+0x788>
ffffffffc020268a:	19c00593          	li	a1,412
ffffffffc020268e:	00003517          	auipc	a0,0x3
ffffffffc0202692:	c3250513          	addi	a0,a0,-974 # ffffffffc02052c0 <default_pmm_manager+0xb8>
ffffffffc0202696:	cdffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc020269a:	00003697          	auipc	a3,0x3
ffffffffc020269e:	e7668693          	addi	a3,a3,-394 # ffffffffc0205510 <default_pmm_manager+0x308>
ffffffffc02026a2:	00002617          	auipc	a2,0x2
ffffffffc02026a6:	7b660613          	addi	a2,a2,1974 # ffffffffc0204e58 <commands+0x788>
ffffffffc02026aa:	1a400593          	li	a1,420
ffffffffc02026ae:	00003517          	auipc	a0,0x3
ffffffffc02026b2:	c1250513          	addi	a0,a0,-1006 # ffffffffc02052c0 <default_pmm_manager+0xb8>
ffffffffc02026b6:	cbffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(strlen((const char *)0x100) == 0);
ffffffffc02026ba:	00003697          	auipc	a3,0x3
ffffffffc02026be:	13668693          	addi	a3,a3,310 # ffffffffc02057f0 <default_pmm_manager+0x5e8>
ffffffffc02026c2:	00002617          	auipc	a2,0x2
ffffffffc02026c6:	79660613          	addi	a2,a2,1942 # ffffffffc0204e58 <commands+0x788>
ffffffffc02026ca:	1e000593          	li	a1,480
ffffffffc02026ce:	00003517          	auipc	a0,0x3
ffffffffc02026d2:	bf250513          	addi	a0,a0,-1038 # ffffffffc02052c0 <default_pmm_manager+0xb8>
ffffffffc02026d6:	c9ffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc02026da:	00003697          	auipc	a3,0x3
ffffffffc02026de:	0de68693          	addi	a3,a3,222 # ffffffffc02057b8 <default_pmm_manager+0x5b0>
ffffffffc02026e2:	00002617          	auipc	a2,0x2
ffffffffc02026e6:	77660613          	addi	a2,a2,1910 # ffffffffc0204e58 <commands+0x788>
ffffffffc02026ea:	1dd00593          	li	a1,477
ffffffffc02026ee:	00003517          	auipc	a0,0x3
ffffffffc02026f2:	bd250513          	addi	a0,a0,-1070 # ffffffffc02052c0 <default_pmm_manager+0xb8>
ffffffffc02026f6:	c7ffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_ref(p) == 2);
ffffffffc02026fa:	00003697          	auipc	a3,0x3
ffffffffc02026fe:	08e68693          	addi	a3,a3,142 # ffffffffc0205788 <default_pmm_manager+0x580>
ffffffffc0202702:	00002617          	auipc	a2,0x2
ffffffffc0202706:	75660613          	addi	a2,a2,1878 # ffffffffc0204e58 <commands+0x788>
ffffffffc020270a:	1d900593          	li	a1,473
ffffffffc020270e:	00003517          	auipc	a0,0x3
ffffffffc0202712:	bb250513          	addi	a0,a0,-1102 # ffffffffc02052c0 <default_pmm_manager+0xb8>
ffffffffc0202716:	c5ffd0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc020271a <tlb_invalidate>:
static inline void flush_tlb() { asm volatile("sfence.vma"); }
ffffffffc020271a:	12000073          	sfence.vma
void tlb_invalidate(pde_t *pgdir, uintptr_t la) { flush_tlb(); }
ffffffffc020271e:	8082                	ret

ffffffffc0202720 <pgdir_alloc_page>:
struct Page *pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
ffffffffc0202720:	7179                	addi	sp,sp,-48
ffffffffc0202722:	e84a                	sd	s2,16(sp)
ffffffffc0202724:	892a                	mv	s2,a0
    struct Page *page = alloc_page();
ffffffffc0202726:	4505                	li	a0,1
struct Page *pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
ffffffffc0202728:	f022                	sd	s0,32(sp)
ffffffffc020272a:	ec26                	sd	s1,24(sp)
ffffffffc020272c:	e44e                	sd	s3,8(sp)
ffffffffc020272e:	f406                	sd	ra,40(sp)
ffffffffc0202730:	84ae                	mv	s1,a1
ffffffffc0202732:	89b2                	mv	s3,a2
    struct Page *page = alloc_page();
ffffffffc0202734:	eedfe0ef          	jal	ra,ffffffffc0201620 <alloc_pages>
ffffffffc0202738:	842a                	mv	s0,a0
    if (page != NULL) {
ffffffffc020273a:	cd09                	beqz	a0,ffffffffc0202754 <pgdir_alloc_page+0x34>
        if (page_insert(pgdir, page, la, perm) != 0) {
ffffffffc020273c:	85aa                	mv	a1,a0
ffffffffc020273e:	86ce                	mv	a3,s3
ffffffffc0202740:	8626                	mv	a2,s1
ffffffffc0202742:	854a                	mv	a0,s2
ffffffffc0202744:	ad2ff0ef          	jal	ra,ffffffffc0201a16 <page_insert>
ffffffffc0202748:	ed21                	bnez	a0,ffffffffc02027a0 <pgdir_alloc_page+0x80>
        if (swap_init_ok) {
ffffffffc020274a:	0000f797          	auipc	a5,0xf
ffffffffc020274e:	e0e7a783          	lw	a5,-498(a5) # ffffffffc0211558 <swap_init_ok>
ffffffffc0202752:	eb89                	bnez	a5,ffffffffc0202764 <pgdir_alloc_page+0x44>
}
ffffffffc0202754:	70a2                	ld	ra,40(sp)
ffffffffc0202756:	8522                	mv	a0,s0
ffffffffc0202758:	7402                	ld	s0,32(sp)
ffffffffc020275a:	64e2                	ld	s1,24(sp)
ffffffffc020275c:	6942                	ld	s2,16(sp)
ffffffffc020275e:	69a2                	ld	s3,8(sp)
ffffffffc0202760:	6145                	addi	sp,sp,48
ffffffffc0202762:	8082                	ret
            swap_map_swappable(check_mm_struct, la, page, 0);
ffffffffc0202764:	4681                	li	a3,0
ffffffffc0202766:	8622                	mv	a2,s0
ffffffffc0202768:	85a6                	mv	a1,s1
ffffffffc020276a:	0000f517          	auipc	a0,0xf
ffffffffc020276e:	dfe53503          	ld	a0,-514(a0) # ffffffffc0211568 <check_mm_struct>
ffffffffc0202772:	07f000ef          	jal	ra,ffffffffc0202ff0 <swap_map_swappable>
            assert(page_ref(page) == 1);
ffffffffc0202776:	4018                	lw	a4,0(s0)
            page->pra_vaddr = la;
ffffffffc0202778:	e024                	sd	s1,64(s0)
            assert(page_ref(page) == 1);
ffffffffc020277a:	4785                	li	a5,1
ffffffffc020277c:	fcf70ce3          	beq	a4,a5,ffffffffc0202754 <pgdir_alloc_page+0x34>
ffffffffc0202780:	00003697          	auipc	a3,0x3
ffffffffc0202784:	0b868693          	addi	a3,a3,184 # ffffffffc0205838 <default_pmm_manager+0x630>
ffffffffc0202788:	00002617          	auipc	a2,0x2
ffffffffc020278c:	6d060613          	addi	a2,a2,1744 # ffffffffc0204e58 <commands+0x788>
ffffffffc0202790:	17a00593          	li	a1,378
ffffffffc0202794:	00003517          	auipc	a0,0x3
ffffffffc0202798:	b2c50513          	addi	a0,a0,-1236 # ffffffffc02052c0 <default_pmm_manager+0xb8>
ffffffffc020279c:	bd9fd0ef          	jal	ra,ffffffffc0200374 <__panic>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02027a0:	100027f3          	csrr	a5,sstatus
ffffffffc02027a4:	8b89                	andi	a5,a5,2
ffffffffc02027a6:	eb99                	bnez	a5,ffffffffc02027bc <pgdir_alloc_page+0x9c>
    { pmm_manager->free_pages(base, n); }
ffffffffc02027a8:	0000f797          	auipc	a5,0xf
ffffffffc02027ac:	d907b783          	ld	a5,-624(a5) # ffffffffc0211538 <pmm_manager>
ffffffffc02027b0:	739c                	ld	a5,32(a5)
ffffffffc02027b2:	8522                	mv	a0,s0
ffffffffc02027b4:	4585                	li	a1,1
ffffffffc02027b6:	9782                	jalr	a5
            return NULL;
ffffffffc02027b8:	4401                	li	s0,0
ffffffffc02027ba:	bf69                	j	ffffffffc0202754 <pgdir_alloc_page+0x34>
        intr_disable();
ffffffffc02027bc:	d33fd0ef          	jal	ra,ffffffffc02004ee <intr_disable>
    { pmm_manager->free_pages(base, n); }
ffffffffc02027c0:	0000f797          	auipc	a5,0xf
ffffffffc02027c4:	d787b783          	ld	a5,-648(a5) # ffffffffc0211538 <pmm_manager>
ffffffffc02027c8:	739c                	ld	a5,32(a5)
ffffffffc02027ca:	8522                	mv	a0,s0
ffffffffc02027cc:	4585                	li	a1,1
ffffffffc02027ce:	9782                	jalr	a5
            return NULL;
ffffffffc02027d0:	4401                	li	s0,0
        intr_enable();
ffffffffc02027d2:	d17fd0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
ffffffffc02027d6:	bfbd                	j	ffffffffc0202754 <pgdir_alloc_page+0x34>

ffffffffc02027d8 <kmalloc>:
}

void *kmalloc(size_t n) {
ffffffffc02027d8:	1141                	addi	sp,sp,-16
    void *ptr = NULL;
    struct Page *base = NULL;
    assert(n > 0 && n < 1024 * 0124);
ffffffffc02027da:	67d5                	lui	a5,0x15
void *kmalloc(size_t n) {
ffffffffc02027dc:	e406                	sd	ra,8(sp)
    assert(n > 0 && n < 1024 * 0124);
ffffffffc02027de:	fff50713          	addi	a4,a0,-1
ffffffffc02027e2:	17f9                	addi	a5,a5,-2
ffffffffc02027e4:	04e7ea63          	bltu	a5,a4,ffffffffc0202838 <kmalloc+0x60>
    int num_pages = (n + PGSIZE - 1) / PGSIZE;
ffffffffc02027e8:	6785                	lui	a5,0x1
ffffffffc02027ea:	17fd                	addi	a5,a5,-1
ffffffffc02027ec:	953e                	add	a0,a0,a5
    base = alloc_pages(num_pages);
ffffffffc02027ee:	8131                	srli	a0,a0,0xc
ffffffffc02027f0:	e31fe0ef          	jal	ra,ffffffffc0201620 <alloc_pages>
    assert(base != NULL);
ffffffffc02027f4:	cd3d                	beqz	a0,ffffffffc0202872 <kmalloc+0x9a>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc02027f6:	0000f797          	auipc	a5,0xf
ffffffffc02027fa:	d3a7b783          	ld	a5,-710(a5) # ffffffffc0211530 <pages>
ffffffffc02027fe:	8d1d                	sub	a0,a0,a5
ffffffffc0202800:	00004697          	auipc	a3,0x4
ffffffffc0202804:	af06b683          	ld	a3,-1296(a3) # ffffffffc02062f0 <error_string+0x38>
ffffffffc0202808:	850d                	srai	a0,a0,0x3
ffffffffc020280a:	02d50533          	mul	a0,a0,a3
ffffffffc020280e:	000806b7          	lui	a3,0x80
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0202812:	0000f717          	auipc	a4,0xf
ffffffffc0202816:	d1673703          	ld	a4,-746(a4) # ffffffffc0211528 <npage>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc020281a:	9536                	add	a0,a0,a3
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc020281c:	00c51793          	slli	a5,a0,0xc
ffffffffc0202820:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0202822:	0532                	slli	a0,a0,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0202824:	02e7fa63          	bgeu	a5,a4,ffffffffc0202858 <kmalloc+0x80>
    ptr = page2kva(base);
    return ptr;
}
ffffffffc0202828:	60a2                	ld	ra,8(sp)
ffffffffc020282a:	0000f797          	auipc	a5,0xf
ffffffffc020282e:	d167b783          	ld	a5,-746(a5) # ffffffffc0211540 <va_pa_offset>
ffffffffc0202832:	953e                	add	a0,a0,a5
ffffffffc0202834:	0141                	addi	sp,sp,16
ffffffffc0202836:	8082                	ret
    assert(n > 0 && n < 1024 * 0124);
ffffffffc0202838:	00003697          	auipc	a3,0x3
ffffffffc020283c:	01868693          	addi	a3,a3,24 # ffffffffc0205850 <default_pmm_manager+0x648>
ffffffffc0202840:	00002617          	auipc	a2,0x2
ffffffffc0202844:	61860613          	addi	a2,a2,1560 # ffffffffc0204e58 <commands+0x788>
ffffffffc0202848:	1f000593          	li	a1,496
ffffffffc020284c:	00003517          	auipc	a0,0x3
ffffffffc0202850:	a7450513          	addi	a0,a0,-1420 # ffffffffc02052c0 <default_pmm_manager+0xb8>
ffffffffc0202854:	b21fd0ef          	jal	ra,ffffffffc0200374 <__panic>
ffffffffc0202858:	86aa                	mv	a3,a0
ffffffffc020285a:	00003617          	auipc	a2,0x3
ffffffffc020285e:	a3e60613          	addi	a2,a2,-1474 # ffffffffc0205298 <default_pmm_manager+0x90>
ffffffffc0202862:	06a00593          	li	a1,106
ffffffffc0202866:	00003517          	auipc	a0,0x3
ffffffffc020286a:	9fa50513          	addi	a0,a0,-1542 # ffffffffc0205260 <default_pmm_manager+0x58>
ffffffffc020286e:	b07fd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(base != NULL);
ffffffffc0202872:	00003697          	auipc	a3,0x3
ffffffffc0202876:	ffe68693          	addi	a3,a3,-2 # ffffffffc0205870 <default_pmm_manager+0x668>
ffffffffc020287a:	00002617          	auipc	a2,0x2
ffffffffc020287e:	5de60613          	addi	a2,a2,1502 # ffffffffc0204e58 <commands+0x788>
ffffffffc0202882:	1f300593          	li	a1,499
ffffffffc0202886:	00003517          	auipc	a0,0x3
ffffffffc020288a:	a3a50513          	addi	a0,a0,-1478 # ffffffffc02052c0 <default_pmm_manager+0xb8>
ffffffffc020288e:	ae7fd0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc0202892 <kfree>:

void kfree(void *ptr, size_t n) {
ffffffffc0202892:	1101                	addi	sp,sp,-32
    assert(n > 0 && n < 1024 * 0124);
ffffffffc0202894:	67d5                	lui	a5,0x15
void kfree(void *ptr, size_t n) {
ffffffffc0202896:	ec06                	sd	ra,24(sp)
    assert(n > 0 && n < 1024 * 0124);
ffffffffc0202898:	fff58713          	addi	a4,a1,-1
ffffffffc020289c:	17f9                	addi	a5,a5,-2
ffffffffc020289e:	0ae7ee63          	bltu	a5,a4,ffffffffc020295a <kfree+0xc8>
    assert(ptr != NULL);
ffffffffc02028a2:	cd41                	beqz	a0,ffffffffc020293a <kfree+0xa8>
    struct Page *base = NULL;
    int num_pages = (n + PGSIZE - 1) / PGSIZE;
ffffffffc02028a4:	6785                	lui	a5,0x1
ffffffffc02028a6:	17fd                	addi	a5,a5,-1
ffffffffc02028a8:	95be                	add	a1,a1,a5
static inline struct Page *kva2page(void *kva) { return pa2page(PADDR(kva)); }
ffffffffc02028aa:	c02007b7          	lui	a5,0xc0200
ffffffffc02028ae:	81b1                	srli	a1,a1,0xc
ffffffffc02028b0:	06f56863          	bltu	a0,a5,ffffffffc0202920 <kfree+0x8e>
ffffffffc02028b4:	0000f697          	auipc	a3,0xf
ffffffffc02028b8:	c8c6b683          	ld	a3,-884(a3) # ffffffffc0211540 <va_pa_offset>
ffffffffc02028bc:	8d15                	sub	a0,a0,a3
    if (PPN(pa) >= npage) {
ffffffffc02028be:	8131                	srli	a0,a0,0xc
ffffffffc02028c0:	0000f797          	auipc	a5,0xf
ffffffffc02028c4:	c687b783          	ld	a5,-920(a5) # ffffffffc0211528 <npage>
ffffffffc02028c8:	04f57a63          	bgeu	a0,a5,ffffffffc020291c <kfree+0x8a>
    return &pages[PPN(pa) - nbase];
ffffffffc02028cc:	fff806b7          	lui	a3,0xfff80
ffffffffc02028d0:	9536                	add	a0,a0,a3
ffffffffc02028d2:	00351793          	slli	a5,a0,0x3
ffffffffc02028d6:	953e                	add	a0,a0,a5
ffffffffc02028d8:	050e                	slli	a0,a0,0x3
ffffffffc02028da:	0000f797          	auipc	a5,0xf
ffffffffc02028de:	c567b783          	ld	a5,-938(a5) # ffffffffc0211530 <pages>
ffffffffc02028e2:	953e                	add	a0,a0,a5
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02028e4:	100027f3          	csrr	a5,sstatus
ffffffffc02028e8:	8b89                	andi	a5,a5,2
ffffffffc02028ea:	eb89                	bnez	a5,ffffffffc02028fc <kfree+0x6a>
    { pmm_manager->free_pages(base, n); }
ffffffffc02028ec:	0000f797          	auipc	a5,0xf
ffffffffc02028f0:	c4c7b783          	ld	a5,-948(a5) # ffffffffc0211538 <pmm_manager>
    base = kva2page(ptr);
    free_pages(base, num_pages);
}
ffffffffc02028f4:	60e2                	ld	ra,24(sp)
    { pmm_manager->free_pages(base, n); }
ffffffffc02028f6:	739c                	ld	a5,32(a5)
}
ffffffffc02028f8:	6105                	addi	sp,sp,32
    { pmm_manager->free_pages(base, n); }
ffffffffc02028fa:	8782                	jr	a5
        intr_disable();
ffffffffc02028fc:	e42a                	sd	a0,8(sp)
ffffffffc02028fe:	e02e                	sd	a1,0(sp)
ffffffffc0202900:	beffd0ef          	jal	ra,ffffffffc02004ee <intr_disable>
ffffffffc0202904:	0000f797          	auipc	a5,0xf
ffffffffc0202908:	c347b783          	ld	a5,-972(a5) # ffffffffc0211538 <pmm_manager>
ffffffffc020290c:	6582                	ld	a1,0(sp)
ffffffffc020290e:	6522                	ld	a0,8(sp)
ffffffffc0202910:	739c                	ld	a5,32(a5)
ffffffffc0202912:	9782                	jalr	a5
}
ffffffffc0202914:	60e2                	ld	ra,24(sp)
ffffffffc0202916:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0202918:	bd1fd06f          	j	ffffffffc02004e8 <intr_enable>
ffffffffc020291c:	ccdfe0ef          	jal	ra,ffffffffc02015e8 <pa2page.part.0>
static inline struct Page *kva2page(void *kva) { return pa2page(PADDR(kva)); }
ffffffffc0202920:	86aa                	mv	a3,a0
ffffffffc0202922:	00003617          	auipc	a2,0x3
ffffffffc0202926:	a3660613          	addi	a2,a2,-1482 # ffffffffc0205358 <default_pmm_manager+0x150>
ffffffffc020292a:	06c00593          	li	a1,108
ffffffffc020292e:	00003517          	auipc	a0,0x3
ffffffffc0202932:	93250513          	addi	a0,a0,-1742 # ffffffffc0205260 <default_pmm_manager+0x58>
ffffffffc0202936:	a3ffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(ptr != NULL);
ffffffffc020293a:	00003697          	auipc	a3,0x3
ffffffffc020293e:	f4668693          	addi	a3,a3,-186 # ffffffffc0205880 <default_pmm_manager+0x678>
ffffffffc0202942:	00002617          	auipc	a2,0x2
ffffffffc0202946:	51660613          	addi	a2,a2,1302 # ffffffffc0204e58 <commands+0x788>
ffffffffc020294a:	1fa00593          	li	a1,506
ffffffffc020294e:	00003517          	auipc	a0,0x3
ffffffffc0202952:	97250513          	addi	a0,a0,-1678 # ffffffffc02052c0 <default_pmm_manager+0xb8>
ffffffffc0202956:	a1ffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(n > 0 && n < 1024 * 0124);
ffffffffc020295a:	00003697          	auipc	a3,0x3
ffffffffc020295e:	ef668693          	addi	a3,a3,-266 # ffffffffc0205850 <default_pmm_manager+0x648>
ffffffffc0202962:	00002617          	auipc	a2,0x2
ffffffffc0202966:	4f660613          	addi	a2,a2,1270 # ffffffffc0204e58 <commands+0x788>
ffffffffc020296a:	1f900593          	li	a1,505
ffffffffc020296e:	00003517          	auipc	a0,0x3
ffffffffc0202972:	95250513          	addi	a0,a0,-1710 # ffffffffc02052c0 <default_pmm_manager+0xb8>
ffffffffc0202976:	9fffd0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc020297a <swap_init>:

static void check_swap(void);

int
swap_init(void)
{
ffffffffc020297a:	7135                	addi	sp,sp,-160
ffffffffc020297c:	ed06                	sd	ra,152(sp)
ffffffffc020297e:	e922                	sd	s0,144(sp)
ffffffffc0202980:	e526                	sd	s1,136(sp)
ffffffffc0202982:	e14a                	sd	s2,128(sp)
ffffffffc0202984:	fcce                	sd	s3,120(sp)
ffffffffc0202986:	f8d2                	sd	s4,112(sp)
ffffffffc0202988:	f4d6                	sd	s5,104(sp)
ffffffffc020298a:	f0da                	sd	s6,96(sp)
ffffffffc020298c:	ecde                	sd	s7,88(sp)
ffffffffc020298e:	e8e2                	sd	s8,80(sp)
ffffffffc0202990:	e4e6                	sd	s9,72(sp)
ffffffffc0202992:	e0ea                	sd	s10,64(sp)
ffffffffc0202994:	fc6e                	sd	s11,56(sp)
     swapfs_init();
ffffffffc0202996:	42c010ef          	jal	ra,ffffffffc0203dc2 <swapfs_init>

     // Since the IDE is faked, it can only store 7 pages at most to pass the test
     if (!(7 <= max_swap_offset &&
ffffffffc020299a:	0000f697          	auipc	a3,0xf
ffffffffc020299e:	bae6b683          	ld	a3,-1106(a3) # ffffffffc0211548 <max_swap_offset>
ffffffffc02029a2:	010007b7          	lui	a5,0x1000
ffffffffc02029a6:	ff968713          	addi	a4,a3,-7
ffffffffc02029aa:	17e1                	addi	a5,a5,-8
ffffffffc02029ac:	3ee7e063          	bltu	a5,a4,ffffffffc0202d8c <swap_init+0x412>
        max_swap_offset < MAX_SWAP_OFFSET_LIMIT)) {
        panic("bad max_swap_offset %08x.\n", max_swap_offset);
     }

     sm = &swap_manager_clock;//use first in first out Page Replacement Algorithm
ffffffffc02029b0:	00007797          	auipc	a5,0x7
ffffffffc02029b4:	65078793          	addi	a5,a5,1616 # ffffffffc020a000 <swap_manager_clock>
     int r = sm->init();
ffffffffc02029b8:	6798                	ld	a4,8(a5)
     sm = &swap_manager_clock;//use first in first out Page Replacement Algorithm
ffffffffc02029ba:	0000fb17          	auipc	s6,0xf
ffffffffc02029be:	b96b0b13          	addi	s6,s6,-1130 # ffffffffc0211550 <sm>
ffffffffc02029c2:	00fb3023          	sd	a5,0(s6)
     int r = sm->init();
ffffffffc02029c6:	9702                	jalr	a4
ffffffffc02029c8:	89aa                	mv	s3,a0
     
     if (r == 0)
ffffffffc02029ca:	c10d                	beqz	a0,ffffffffc02029ec <swap_init+0x72>
          cprintf("SWAP: manager = %s\n", sm->name);
          check_swap();
     }

     return r;
}
ffffffffc02029cc:	60ea                	ld	ra,152(sp)
ffffffffc02029ce:	644a                	ld	s0,144(sp)
ffffffffc02029d0:	64aa                	ld	s1,136(sp)
ffffffffc02029d2:	690a                	ld	s2,128(sp)
ffffffffc02029d4:	7a46                	ld	s4,112(sp)
ffffffffc02029d6:	7aa6                	ld	s5,104(sp)
ffffffffc02029d8:	7b06                	ld	s6,96(sp)
ffffffffc02029da:	6be6                	ld	s7,88(sp)
ffffffffc02029dc:	6c46                	ld	s8,80(sp)
ffffffffc02029de:	6ca6                	ld	s9,72(sp)
ffffffffc02029e0:	6d06                	ld	s10,64(sp)
ffffffffc02029e2:	7de2                	ld	s11,56(sp)
ffffffffc02029e4:	854e                	mv	a0,s3
ffffffffc02029e6:	79e6                	ld	s3,120(sp)
ffffffffc02029e8:	610d                	addi	sp,sp,160
ffffffffc02029ea:	8082                	ret
          cprintf("SWAP: manager = %s\n", sm->name);
ffffffffc02029ec:	000b3783          	ld	a5,0(s6)
ffffffffc02029f0:	00003517          	auipc	a0,0x3
ffffffffc02029f4:	ed050513          	addi	a0,a0,-304 # ffffffffc02058c0 <default_pmm_manager+0x6b8>
    return listelm->next;
ffffffffc02029f8:	0000e497          	auipc	s1,0xe
ffffffffc02029fc:	64848493          	addi	s1,s1,1608 # ffffffffc0211040 <free_area>
ffffffffc0202a00:	638c                	ld	a1,0(a5)
          swap_init_ok = 1;
ffffffffc0202a02:	4785                	li	a5,1
ffffffffc0202a04:	0000f717          	auipc	a4,0xf
ffffffffc0202a08:	b4f72a23          	sw	a5,-1196(a4) # ffffffffc0211558 <swap_init_ok>
          cprintf("SWAP: manager = %s\n", sm->name);
ffffffffc0202a0c:	eaefd0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc0202a10:	649c                	ld	a5,8(s1)

static void
check_swap(void)
{
    //backup mem env
     int ret, count = 0, total = 0, i;
ffffffffc0202a12:	4401                	li	s0,0
ffffffffc0202a14:	4d01                	li	s10,0
     list_entry_t *le = &free_list;
     while ((le = list_next(le)) != &free_list) {
ffffffffc0202a16:	2c978163          	beq	a5,s1,ffffffffc0202cd8 <swap_init+0x35e>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0202a1a:	fe87b703          	ld	a4,-24(a5)
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc0202a1e:	8b09                	andi	a4,a4,2
ffffffffc0202a20:	2a070e63          	beqz	a4,ffffffffc0202cdc <swap_init+0x362>
        count ++, total += p->property;
ffffffffc0202a24:	ff87a703          	lw	a4,-8(a5)
ffffffffc0202a28:	679c                	ld	a5,8(a5)
ffffffffc0202a2a:	2d05                	addiw	s10,s10,1
ffffffffc0202a2c:	9c39                	addw	s0,s0,a4
     while ((le = list_next(le)) != &free_list) {
ffffffffc0202a2e:	fe9796e3          	bne	a5,s1,ffffffffc0202a1a <swap_init+0xa0>
     }
     assert(total == nr_free_pages());
ffffffffc0202a32:	8922                	mv	s2,s0
ffffffffc0202a34:	cbffe0ef          	jal	ra,ffffffffc02016f2 <nr_free_pages>
ffffffffc0202a38:	47251663          	bne	a0,s2,ffffffffc0202ea4 <swap_init+0x52a>
     cprintf("BEGIN check_swap: count %d, total %d\n",count,total);
ffffffffc0202a3c:	8622                	mv	a2,s0
ffffffffc0202a3e:	85ea                	mv	a1,s10
ffffffffc0202a40:	00003517          	auipc	a0,0x3
ffffffffc0202a44:	e9850513          	addi	a0,a0,-360 # ffffffffc02058d8 <default_pmm_manager+0x6d0>
ffffffffc0202a48:	e72fd0ef          	jal	ra,ffffffffc02000ba <cprintf>
     
     //now we set the phy pages env     
     struct mm_struct *mm = mm_create();
ffffffffc0202a4c:	2ed000ef          	jal	ra,ffffffffc0203538 <mm_create>
ffffffffc0202a50:	8aaa                	mv	s5,a0
     assert(mm != NULL);
ffffffffc0202a52:	52050963          	beqz	a0,ffffffffc0202f84 <swap_init+0x60a>

     extern struct mm_struct *check_mm_struct;
     assert(check_mm_struct == NULL);
ffffffffc0202a56:	0000f797          	auipc	a5,0xf
ffffffffc0202a5a:	b1278793          	addi	a5,a5,-1262 # ffffffffc0211568 <check_mm_struct>
ffffffffc0202a5e:	6398                	ld	a4,0(a5)
ffffffffc0202a60:	54071263          	bnez	a4,ffffffffc0202fa4 <swap_init+0x62a>

     check_mm_struct = mm;

     pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0202a64:	0000fb97          	auipc	s7,0xf
ffffffffc0202a68:	abcbbb83          	ld	s7,-1348(s7) # ffffffffc0211520 <boot_pgdir>
     assert(pgdir[0] == 0);
ffffffffc0202a6c:	000bb703          	ld	a4,0(s7)
     check_mm_struct = mm;
ffffffffc0202a70:	e388                	sd	a0,0(a5)
     pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0202a72:	01753c23          	sd	s7,24(a0)
     assert(pgdir[0] == 0);
ffffffffc0202a76:	3c071763          	bnez	a4,ffffffffc0202e44 <swap_init+0x4ca>

     struct vma_struct *vma = vma_create(BEING_CHECK_VALID_VADDR, CHECK_VALID_VADDR, VM_WRITE | VM_READ);
ffffffffc0202a7a:	6599                	lui	a1,0x6
ffffffffc0202a7c:	460d                	li	a2,3
ffffffffc0202a7e:	6505                	lui	a0,0x1
ffffffffc0202a80:	301000ef          	jal	ra,ffffffffc0203580 <vma_create>
ffffffffc0202a84:	85aa                	mv	a1,a0
     assert(vma != NULL);
ffffffffc0202a86:	3c050f63          	beqz	a0,ffffffffc0202e64 <swap_init+0x4ea>

     insert_vma_struct(mm, vma);
ffffffffc0202a8a:	8556                	mv	a0,s5
ffffffffc0202a8c:	363000ef          	jal	ra,ffffffffc02035ee <insert_vma_struct>

     //setup the temp Page Table vaddr 0~4MB
     cprintf("setup Page Table for vaddr 0X1000, so alloc a page\n");
ffffffffc0202a90:	00003517          	auipc	a0,0x3
ffffffffc0202a94:	eb850513          	addi	a0,a0,-328 # ffffffffc0205948 <default_pmm_manager+0x740>
ffffffffc0202a98:	e22fd0ef          	jal	ra,ffffffffc02000ba <cprintf>
     pte_t *temp_ptep=NULL;
     temp_ptep = get_pte(mm->pgdir, BEING_CHECK_VALID_VADDR, 1);
ffffffffc0202a9c:	018ab503          	ld	a0,24(s5)
ffffffffc0202aa0:	4605                	li	a2,1
ffffffffc0202aa2:	6585                	lui	a1,0x1
ffffffffc0202aa4:	c89fe0ef          	jal	ra,ffffffffc020172c <get_pte>
     assert(temp_ptep!= NULL);
ffffffffc0202aa8:	3c050e63          	beqz	a0,ffffffffc0202e84 <swap_init+0x50a>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
ffffffffc0202aac:	00003517          	auipc	a0,0x3
ffffffffc0202ab0:	eec50513          	addi	a0,a0,-276 # ffffffffc0205998 <default_pmm_manager+0x790>
ffffffffc0202ab4:	0000e917          	auipc	s2,0xe
ffffffffc0202ab8:	5c490913          	addi	s2,s2,1476 # ffffffffc0211078 <check_rp>
ffffffffc0202abc:	dfefd0ef          	jal	ra,ffffffffc02000ba <cprintf>
     
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0202ac0:	0000ea17          	auipc	s4,0xe
ffffffffc0202ac4:	5d8a0a13          	addi	s4,s4,1496 # ffffffffc0211098 <swap_in_seq_no>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
ffffffffc0202ac8:	8c4a                	mv	s8,s2
          check_rp[i] = alloc_page();
ffffffffc0202aca:	4505                	li	a0,1
ffffffffc0202acc:	b55fe0ef          	jal	ra,ffffffffc0201620 <alloc_pages>
ffffffffc0202ad0:	00ac3023          	sd	a0,0(s8)
          assert(check_rp[i] != NULL );
ffffffffc0202ad4:	28050c63          	beqz	a0,ffffffffc0202d6c <swap_init+0x3f2>
ffffffffc0202ad8:	651c                	ld	a5,8(a0)
          assert(!PageProperty(check_rp[i]));
ffffffffc0202ada:	8b89                	andi	a5,a5,2
ffffffffc0202adc:	26079863          	bnez	a5,ffffffffc0202d4c <swap_init+0x3d2>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0202ae0:	0c21                	addi	s8,s8,8
ffffffffc0202ae2:	ff4c14e3          	bne	s8,s4,ffffffffc0202aca <swap_init+0x150>
     }
     list_entry_t free_list_store = free_list;
ffffffffc0202ae6:	609c                	ld	a5,0(s1)
ffffffffc0202ae8:	0084bd83          	ld	s11,8(s1)
    elm->prev = elm->next = elm;
ffffffffc0202aec:	e084                	sd	s1,0(s1)
ffffffffc0202aee:	f03e                	sd	a5,32(sp)
     list_init(&free_list);
     assert(list_empty(&free_list));
     
     //assert(alloc_page() == NULL);
     
     unsigned int nr_free_store = nr_free;
ffffffffc0202af0:	489c                	lw	a5,16(s1)
ffffffffc0202af2:	e484                	sd	s1,8(s1)
     nr_free = 0;
ffffffffc0202af4:	0000ec17          	auipc	s8,0xe
ffffffffc0202af8:	584c0c13          	addi	s8,s8,1412 # ffffffffc0211078 <check_rp>
     unsigned int nr_free_store = nr_free;
ffffffffc0202afc:	f43e                	sd	a5,40(sp)
     nr_free = 0;
ffffffffc0202afe:	0000e797          	auipc	a5,0xe
ffffffffc0202b02:	5407a923          	sw	zero,1362(a5) # ffffffffc0211050 <free_area+0x10>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
        free_pages(check_rp[i],1);
ffffffffc0202b06:	000c3503          	ld	a0,0(s8)
ffffffffc0202b0a:	4585                	li	a1,1
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0202b0c:	0c21                	addi	s8,s8,8
        free_pages(check_rp[i],1);
ffffffffc0202b0e:	ba5fe0ef          	jal	ra,ffffffffc02016b2 <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0202b12:	ff4c1ae3          	bne	s8,s4,ffffffffc0202b06 <swap_init+0x18c>
     }
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
ffffffffc0202b16:	0104ac03          	lw	s8,16(s1)
ffffffffc0202b1a:	4791                	li	a5,4
ffffffffc0202b1c:	4afc1463          	bne	s8,a5,ffffffffc0202fc4 <swap_init+0x64a>
     
     cprintf("set up init env for check_swap begin!\n");
ffffffffc0202b20:	00003517          	auipc	a0,0x3
ffffffffc0202b24:	f0050513          	addi	a0,a0,-256 # ffffffffc0205a20 <default_pmm_manager+0x818>
ffffffffc0202b28:	d92fd0ef          	jal	ra,ffffffffc02000ba <cprintf>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc0202b2c:	6605                	lui	a2,0x1
     //setup initial vir_page<->phy_page environment for page relpacement algorithm 

     
     pgfault_num=0;
ffffffffc0202b2e:	0000f797          	auipc	a5,0xf
ffffffffc0202b32:	a407a123          	sw	zero,-1470(a5) # ffffffffc0211570 <pgfault_num>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc0202b36:	4529                	li	a0,10
ffffffffc0202b38:	00a60023          	sb	a0,0(a2) # 1000 <kern_entry-0xffffffffc01ff000>
     assert(pgfault_num==1);
ffffffffc0202b3c:	0000f597          	auipc	a1,0xf
ffffffffc0202b40:	a345a583          	lw	a1,-1484(a1) # ffffffffc0211570 <pgfault_num>
ffffffffc0202b44:	4805                	li	a6,1
ffffffffc0202b46:	0000f797          	auipc	a5,0xf
ffffffffc0202b4a:	a2a78793          	addi	a5,a5,-1494 # ffffffffc0211570 <pgfault_num>
ffffffffc0202b4e:	3f059b63          	bne	a1,a6,ffffffffc0202f44 <swap_init+0x5ca>
     *(unsigned char *)0x1010 = 0x0a;
ffffffffc0202b52:	00a60823          	sb	a0,16(a2)
     assert(pgfault_num==1);
ffffffffc0202b56:	4390                	lw	a2,0(a5)
ffffffffc0202b58:	2601                	sext.w	a2,a2
ffffffffc0202b5a:	40b61563          	bne	a2,a1,ffffffffc0202f64 <swap_init+0x5ea>
     *(unsigned char *)0x2000 = 0x0b;
ffffffffc0202b5e:	6589                	lui	a1,0x2
ffffffffc0202b60:	452d                	li	a0,11
ffffffffc0202b62:	00a58023          	sb	a0,0(a1) # 2000 <kern_entry-0xffffffffc01fe000>
     assert(pgfault_num==2);
ffffffffc0202b66:	4390                	lw	a2,0(a5)
ffffffffc0202b68:	4809                	li	a6,2
ffffffffc0202b6a:	2601                	sext.w	a2,a2
ffffffffc0202b6c:	35061c63          	bne	a2,a6,ffffffffc0202ec4 <swap_init+0x54a>
     *(unsigned char *)0x2010 = 0x0b;
ffffffffc0202b70:	00a58823          	sb	a0,16(a1)
     assert(pgfault_num==2);
ffffffffc0202b74:	438c                	lw	a1,0(a5)
ffffffffc0202b76:	2581                	sext.w	a1,a1
ffffffffc0202b78:	36c59663          	bne	a1,a2,ffffffffc0202ee4 <swap_init+0x56a>
     *(unsigned char *)0x3000 = 0x0c;
ffffffffc0202b7c:	658d                	lui	a1,0x3
ffffffffc0202b7e:	4531                	li	a0,12
ffffffffc0202b80:	00a58023          	sb	a0,0(a1) # 3000 <kern_entry-0xffffffffc01fd000>
     assert(pgfault_num==3);
ffffffffc0202b84:	4390                	lw	a2,0(a5)
ffffffffc0202b86:	480d                	li	a6,3
ffffffffc0202b88:	2601                	sext.w	a2,a2
ffffffffc0202b8a:	37061d63          	bne	a2,a6,ffffffffc0202f04 <swap_init+0x58a>
     *(unsigned char *)0x3010 = 0x0c;
ffffffffc0202b8e:	00a58823          	sb	a0,16(a1)
     assert(pgfault_num==3);
ffffffffc0202b92:	438c                	lw	a1,0(a5)
ffffffffc0202b94:	2581                	sext.w	a1,a1
ffffffffc0202b96:	38c59763          	bne	a1,a2,ffffffffc0202f24 <swap_init+0x5aa>
     *(unsigned char *)0x4000 = 0x0d;
ffffffffc0202b9a:	6591                	lui	a1,0x4
ffffffffc0202b9c:	4535                	li	a0,13
ffffffffc0202b9e:	00a58023          	sb	a0,0(a1) # 4000 <kern_entry-0xffffffffc01fc000>
     assert(pgfault_num==4);
ffffffffc0202ba2:	4390                	lw	a2,0(a5)
ffffffffc0202ba4:	2601                	sext.w	a2,a2
ffffffffc0202ba6:	21861f63          	bne	a2,s8,ffffffffc0202dc4 <swap_init+0x44a>
     *(unsigned char *)0x4010 = 0x0d;
ffffffffc0202baa:	00a58823          	sb	a0,16(a1)
     assert(pgfault_num==4);
ffffffffc0202bae:	439c                	lw	a5,0(a5)
ffffffffc0202bb0:	2781                	sext.w	a5,a5
ffffffffc0202bb2:	22c79963          	bne	a5,a2,ffffffffc0202de4 <swap_init+0x46a>
     
     check_content_set();
     assert( nr_free == 0);         
ffffffffc0202bb6:	489c                	lw	a5,16(s1)
ffffffffc0202bb8:	24079663          	bnez	a5,ffffffffc0202e04 <swap_init+0x48a>
ffffffffc0202bbc:	0000e797          	auipc	a5,0xe
ffffffffc0202bc0:	4dc78793          	addi	a5,a5,1244 # ffffffffc0211098 <swap_in_seq_no>
ffffffffc0202bc4:	0000e617          	auipc	a2,0xe
ffffffffc0202bc8:	4fc60613          	addi	a2,a2,1276 # ffffffffc02110c0 <swap_out_seq_no>
ffffffffc0202bcc:	0000e517          	auipc	a0,0xe
ffffffffc0202bd0:	4f450513          	addi	a0,a0,1268 # ffffffffc02110c0 <swap_out_seq_no>
     for(i = 0; i<MAX_SEQ_NO ; i++) 
         swap_out_seq_no[i]=swap_in_seq_no[i]=-1;
ffffffffc0202bd4:	55fd                	li	a1,-1
ffffffffc0202bd6:	c38c                	sw	a1,0(a5)
ffffffffc0202bd8:	c20c                	sw	a1,0(a2)
     for(i = 0; i<MAX_SEQ_NO ; i++) 
ffffffffc0202bda:	0791                	addi	a5,a5,4
ffffffffc0202bdc:	0611                	addi	a2,a2,4
ffffffffc0202bde:	fef51ce3          	bne	a0,a5,ffffffffc0202bd6 <swap_init+0x25c>
ffffffffc0202be2:	0000e817          	auipc	a6,0xe
ffffffffc0202be6:	47680813          	addi	a6,a6,1142 # ffffffffc0211058 <check_ptep>
ffffffffc0202bea:	0000e897          	auipc	a7,0xe
ffffffffc0202bee:	48e88893          	addi	a7,a7,1166 # ffffffffc0211078 <check_rp>
ffffffffc0202bf2:	6585                	lui	a1,0x1
    return &pages[PPN(pa) - nbase];
ffffffffc0202bf4:	0000fc97          	auipc	s9,0xf
ffffffffc0202bf8:	93cc8c93          	addi	s9,s9,-1732 # ffffffffc0211530 <pages>
ffffffffc0202bfc:	00003c17          	auipc	s8,0x3
ffffffffc0202c00:	6fcc0c13          	addi	s8,s8,1788 # ffffffffc02062f8 <nbase>
     
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
         check_ptep[i]=0;
ffffffffc0202c04:	00083023          	sd	zero,0(a6)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0202c08:	4601                	li	a2,0
ffffffffc0202c0a:	855e                	mv	a0,s7
ffffffffc0202c0c:	ec46                	sd	a7,24(sp)
ffffffffc0202c0e:	e82e                	sd	a1,16(sp)
         check_ptep[i]=0;
ffffffffc0202c10:	e442                	sd	a6,8(sp)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0202c12:	b1bfe0ef          	jal	ra,ffffffffc020172c <get_pte>
ffffffffc0202c16:	6822                	ld	a6,8(sp)
         //cprintf("i %d, check_ptep addr %x, value %x\n", i, check_ptep[i], *check_ptep[i]);
         assert(check_ptep[i] != NULL);
ffffffffc0202c18:	65c2                	ld	a1,16(sp)
ffffffffc0202c1a:	68e2                	ld	a7,24(sp)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0202c1c:	00a83023          	sd	a0,0(a6)
         assert(check_ptep[i] != NULL);
ffffffffc0202c20:	0000f317          	auipc	t1,0xf
ffffffffc0202c24:	90830313          	addi	t1,t1,-1784 # ffffffffc0211528 <npage>
ffffffffc0202c28:	16050e63          	beqz	a0,ffffffffc0202da4 <swap_init+0x42a>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
ffffffffc0202c2c:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc0202c2e:	0017f613          	andi	a2,a5,1
ffffffffc0202c32:	0e060563          	beqz	a2,ffffffffc0202d1c <swap_init+0x3a2>
    if (PPN(pa) >= npage) {
ffffffffc0202c36:	00033603          	ld	a2,0(t1)
    return pa2page(PTE_ADDR(pte));
ffffffffc0202c3a:	078a                	slli	a5,a5,0x2
ffffffffc0202c3c:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202c3e:	0ec7fb63          	bgeu	a5,a2,ffffffffc0202d34 <swap_init+0x3ba>
    return &pages[PPN(pa) - nbase];
ffffffffc0202c42:	000c3603          	ld	a2,0(s8)
ffffffffc0202c46:	000cb503          	ld	a0,0(s9)
ffffffffc0202c4a:	0008bf03          	ld	t5,0(a7)
ffffffffc0202c4e:	8f91                	sub	a5,a5,a2
ffffffffc0202c50:	00379613          	slli	a2,a5,0x3
ffffffffc0202c54:	97b2                	add	a5,a5,a2
ffffffffc0202c56:	078e                	slli	a5,a5,0x3
ffffffffc0202c58:	97aa                	add	a5,a5,a0
ffffffffc0202c5a:	0aff1163          	bne	t5,a5,ffffffffc0202cfc <swap_init+0x382>
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0202c5e:	6785                	lui	a5,0x1
ffffffffc0202c60:	95be                	add	a1,a1,a5
ffffffffc0202c62:	6795                	lui	a5,0x5
ffffffffc0202c64:	0821                	addi	a6,a6,8
ffffffffc0202c66:	08a1                	addi	a7,a7,8
ffffffffc0202c68:	f8f59ee3          	bne	a1,a5,ffffffffc0202c04 <swap_init+0x28a>
         assert((*check_ptep[i] & PTE_V));          
     }
     cprintf("set up init env for check_swap over!\n");
ffffffffc0202c6c:	00003517          	auipc	a0,0x3
ffffffffc0202c70:	e5c50513          	addi	a0,a0,-420 # ffffffffc0205ac8 <default_pmm_manager+0x8c0>
ffffffffc0202c74:	c46fd0ef          	jal	ra,ffffffffc02000ba <cprintf>
    int ret = sm->check_swap();
ffffffffc0202c78:	000b3783          	ld	a5,0(s6)
ffffffffc0202c7c:	7f9c                	ld	a5,56(a5)
ffffffffc0202c7e:	9782                	jalr	a5
     // now access the virt pages to test  page relpacement algorithm 
     ret=check_content_access();
     assert(ret==0);
ffffffffc0202c80:	1a051263          	bnez	a0,ffffffffc0202e24 <swap_init+0x4aa>
     
     //restore kernel mem env
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
         free_pages(check_rp[i],1);
ffffffffc0202c84:	00093503          	ld	a0,0(s2)
ffffffffc0202c88:	4585                	li	a1,1
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0202c8a:	0921                	addi	s2,s2,8
         free_pages(check_rp[i],1);
ffffffffc0202c8c:	a27fe0ef          	jal	ra,ffffffffc02016b2 <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0202c90:	ff491ae3          	bne	s2,s4,ffffffffc0202c84 <swap_init+0x30a>
     } 

     //free_page(pte2page(*temp_ptep));
     
     mm_destroy(mm);
ffffffffc0202c94:	8556                	mv	a0,s5
ffffffffc0202c96:	229000ef          	jal	ra,ffffffffc02036be <mm_destroy>
         
     nr_free = nr_free_store;
ffffffffc0202c9a:	77a2                	ld	a5,40(sp)
     free_list = free_list_store;
ffffffffc0202c9c:	01b4b423          	sd	s11,8(s1)
     nr_free = nr_free_store;
ffffffffc0202ca0:	c89c                	sw	a5,16(s1)
     free_list = free_list_store;
ffffffffc0202ca2:	7782                	ld	a5,32(sp)
ffffffffc0202ca4:	e09c                	sd	a5,0(s1)

     
     le = &free_list;
     while ((le = list_next(le)) != &free_list) {
ffffffffc0202ca6:	009d8a63          	beq	s11,s1,ffffffffc0202cba <swap_init+0x340>
         struct Page *p = le2page(le, page_link);
         count --, total -= p->property;
ffffffffc0202caa:	ff8da783          	lw	a5,-8(s11)
    return listelm->next;
ffffffffc0202cae:	008dbd83          	ld	s11,8(s11)
ffffffffc0202cb2:	3d7d                	addiw	s10,s10,-1
ffffffffc0202cb4:	9c1d                	subw	s0,s0,a5
     while ((le = list_next(le)) != &free_list) {
ffffffffc0202cb6:	fe9d9ae3          	bne	s11,s1,ffffffffc0202caa <swap_init+0x330>
     }
     cprintf("count is %d, total is %d\n",count,total);
ffffffffc0202cba:	8622                	mv	a2,s0
ffffffffc0202cbc:	85ea                	mv	a1,s10
ffffffffc0202cbe:	00003517          	auipc	a0,0x3
ffffffffc0202cc2:	e3a50513          	addi	a0,a0,-454 # ffffffffc0205af8 <default_pmm_manager+0x8f0>
ffffffffc0202cc6:	bf4fd0ef          	jal	ra,ffffffffc02000ba <cprintf>
     //assert(count == 0);
     
     cprintf("check_swap() succeeded!\n");
ffffffffc0202cca:	00003517          	auipc	a0,0x3
ffffffffc0202cce:	e4e50513          	addi	a0,a0,-434 # ffffffffc0205b18 <default_pmm_manager+0x910>
ffffffffc0202cd2:	be8fd0ef          	jal	ra,ffffffffc02000ba <cprintf>
}
ffffffffc0202cd6:	b9dd                	j	ffffffffc02029cc <swap_init+0x52>
     while ((le = list_next(le)) != &free_list) {
ffffffffc0202cd8:	4901                	li	s2,0
ffffffffc0202cda:	bba9                	j	ffffffffc0202a34 <swap_init+0xba>
        assert(PageProperty(p));
ffffffffc0202cdc:	00002697          	auipc	a3,0x2
ffffffffc0202ce0:	16c68693          	addi	a3,a3,364 # ffffffffc0204e48 <commands+0x778>
ffffffffc0202ce4:	00002617          	auipc	a2,0x2
ffffffffc0202ce8:	17460613          	addi	a2,a2,372 # ffffffffc0204e58 <commands+0x788>
ffffffffc0202cec:	0bb00593          	li	a1,187
ffffffffc0202cf0:	00003517          	auipc	a0,0x3
ffffffffc0202cf4:	bc050513          	addi	a0,a0,-1088 # ffffffffc02058b0 <default_pmm_manager+0x6a8>
ffffffffc0202cf8:	e7cfd0ef          	jal	ra,ffffffffc0200374 <__panic>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
ffffffffc0202cfc:	00003697          	auipc	a3,0x3
ffffffffc0202d00:	da468693          	addi	a3,a3,-604 # ffffffffc0205aa0 <default_pmm_manager+0x898>
ffffffffc0202d04:	00002617          	auipc	a2,0x2
ffffffffc0202d08:	15460613          	addi	a2,a2,340 # ffffffffc0204e58 <commands+0x788>
ffffffffc0202d0c:	0fb00593          	li	a1,251
ffffffffc0202d10:	00003517          	auipc	a0,0x3
ffffffffc0202d14:	ba050513          	addi	a0,a0,-1120 # ffffffffc02058b0 <default_pmm_manager+0x6a8>
ffffffffc0202d18:	e5cfd0ef          	jal	ra,ffffffffc0200374 <__panic>
        panic("pte2page called with invalid pte");
ffffffffc0202d1c:	00002617          	auipc	a2,0x2
ffffffffc0202d20:	55460613          	addi	a2,a2,1364 # ffffffffc0205270 <default_pmm_manager+0x68>
ffffffffc0202d24:	07000593          	li	a1,112
ffffffffc0202d28:	00002517          	auipc	a0,0x2
ffffffffc0202d2c:	53850513          	addi	a0,a0,1336 # ffffffffc0205260 <default_pmm_manager+0x58>
ffffffffc0202d30:	e44fd0ef          	jal	ra,ffffffffc0200374 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0202d34:	00002617          	auipc	a2,0x2
ffffffffc0202d38:	50c60613          	addi	a2,a2,1292 # ffffffffc0205240 <default_pmm_manager+0x38>
ffffffffc0202d3c:	06500593          	li	a1,101
ffffffffc0202d40:	00002517          	auipc	a0,0x2
ffffffffc0202d44:	52050513          	addi	a0,a0,1312 # ffffffffc0205260 <default_pmm_manager+0x58>
ffffffffc0202d48:	e2cfd0ef          	jal	ra,ffffffffc0200374 <__panic>
          assert(!PageProperty(check_rp[i]));
ffffffffc0202d4c:	00003697          	auipc	a3,0x3
ffffffffc0202d50:	c8c68693          	addi	a3,a3,-884 # ffffffffc02059d8 <default_pmm_manager+0x7d0>
ffffffffc0202d54:	00002617          	auipc	a2,0x2
ffffffffc0202d58:	10460613          	addi	a2,a2,260 # ffffffffc0204e58 <commands+0x788>
ffffffffc0202d5c:	0dc00593          	li	a1,220
ffffffffc0202d60:	00003517          	auipc	a0,0x3
ffffffffc0202d64:	b5050513          	addi	a0,a0,-1200 # ffffffffc02058b0 <default_pmm_manager+0x6a8>
ffffffffc0202d68:	e0cfd0ef          	jal	ra,ffffffffc0200374 <__panic>
          assert(check_rp[i] != NULL );
ffffffffc0202d6c:	00003697          	auipc	a3,0x3
ffffffffc0202d70:	c5468693          	addi	a3,a3,-940 # ffffffffc02059c0 <default_pmm_manager+0x7b8>
ffffffffc0202d74:	00002617          	auipc	a2,0x2
ffffffffc0202d78:	0e460613          	addi	a2,a2,228 # ffffffffc0204e58 <commands+0x788>
ffffffffc0202d7c:	0db00593          	li	a1,219
ffffffffc0202d80:	00003517          	auipc	a0,0x3
ffffffffc0202d84:	b3050513          	addi	a0,a0,-1232 # ffffffffc02058b0 <default_pmm_manager+0x6a8>
ffffffffc0202d88:	decfd0ef          	jal	ra,ffffffffc0200374 <__panic>
        panic("bad max_swap_offset %08x.\n", max_swap_offset);
ffffffffc0202d8c:	00003617          	auipc	a2,0x3
ffffffffc0202d90:	b0460613          	addi	a2,a2,-1276 # ffffffffc0205890 <default_pmm_manager+0x688>
ffffffffc0202d94:	02800593          	li	a1,40
ffffffffc0202d98:	00003517          	auipc	a0,0x3
ffffffffc0202d9c:	b1850513          	addi	a0,a0,-1256 # ffffffffc02058b0 <default_pmm_manager+0x6a8>
ffffffffc0202da0:	dd4fd0ef          	jal	ra,ffffffffc0200374 <__panic>
         assert(check_ptep[i] != NULL);
ffffffffc0202da4:	00003697          	auipc	a3,0x3
ffffffffc0202da8:	ce468693          	addi	a3,a3,-796 # ffffffffc0205a88 <default_pmm_manager+0x880>
ffffffffc0202dac:	00002617          	auipc	a2,0x2
ffffffffc0202db0:	0ac60613          	addi	a2,a2,172 # ffffffffc0204e58 <commands+0x788>
ffffffffc0202db4:	0fa00593          	li	a1,250
ffffffffc0202db8:	00003517          	auipc	a0,0x3
ffffffffc0202dbc:	af850513          	addi	a0,a0,-1288 # ffffffffc02058b0 <default_pmm_manager+0x6a8>
ffffffffc0202dc0:	db4fd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(pgfault_num==4);
ffffffffc0202dc4:	00003697          	auipc	a3,0x3
ffffffffc0202dc8:	cb468693          	addi	a3,a3,-844 # ffffffffc0205a78 <default_pmm_manager+0x870>
ffffffffc0202dcc:	00002617          	auipc	a2,0x2
ffffffffc0202dd0:	08c60613          	addi	a2,a2,140 # ffffffffc0204e58 <commands+0x788>
ffffffffc0202dd4:	09e00593          	li	a1,158
ffffffffc0202dd8:	00003517          	auipc	a0,0x3
ffffffffc0202ddc:	ad850513          	addi	a0,a0,-1320 # ffffffffc02058b0 <default_pmm_manager+0x6a8>
ffffffffc0202de0:	d94fd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(pgfault_num==4);
ffffffffc0202de4:	00003697          	auipc	a3,0x3
ffffffffc0202de8:	c9468693          	addi	a3,a3,-876 # ffffffffc0205a78 <default_pmm_manager+0x870>
ffffffffc0202dec:	00002617          	auipc	a2,0x2
ffffffffc0202df0:	06c60613          	addi	a2,a2,108 # ffffffffc0204e58 <commands+0x788>
ffffffffc0202df4:	0a000593          	li	a1,160
ffffffffc0202df8:	00003517          	auipc	a0,0x3
ffffffffc0202dfc:	ab850513          	addi	a0,a0,-1352 # ffffffffc02058b0 <default_pmm_manager+0x6a8>
ffffffffc0202e00:	d74fd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert( nr_free == 0);         
ffffffffc0202e04:	00002697          	auipc	a3,0x2
ffffffffc0202e08:	22c68693          	addi	a3,a3,556 # ffffffffc0205030 <commands+0x960>
ffffffffc0202e0c:	00002617          	auipc	a2,0x2
ffffffffc0202e10:	04c60613          	addi	a2,a2,76 # ffffffffc0204e58 <commands+0x788>
ffffffffc0202e14:	0f200593          	li	a1,242
ffffffffc0202e18:	00003517          	auipc	a0,0x3
ffffffffc0202e1c:	a9850513          	addi	a0,a0,-1384 # ffffffffc02058b0 <default_pmm_manager+0x6a8>
ffffffffc0202e20:	d54fd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(ret==0);
ffffffffc0202e24:	00003697          	auipc	a3,0x3
ffffffffc0202e28:	ccc68693          	addi	a3,a3,-820 # ffffffffc0205af0 <default_pmm_manager+0x8e8>
ffffffffc0202e2c:	00002617          	auipc	a2,0x2
ffffffffc0202e30:	02c60613          	addi	a2,a2,44 # ffffffffc0204e58 <commands+0x788>
ffffffffc0202e34:	10100593          	li	a1,257
ffffffffc0202e38:	00003517          	auipc	a0,0x3
ffffffffc0202e3c:	a7850513          	addi	a0,a0,-1416 # ffffffffc02058b0 <default_pmm_manager+0x6a8>
ffffffffc0202e40:	d34fd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(pgdir[0] == 0);
ffffffffc0202e44:	00003697          	auipc	a3,0x3
ffffffffc0202e48:	ae468693          	addi	a3,a3,-1308 # ffffffffc0205928 <default_pmm_manager+0x720>
ffffffffc0202e4c:	00002617          	auipc	a2,0x2
ffffffffc0202e50:	00c60613          	addi	a2,a2,12 # ffffffffc0204e58 <commands+0x788>
ffffffffc0202e54:	0cb00593          	li	a1,203
ffffffffc0202e58:	00003517          	auipc	a0,0x3
ffffffffc0202e5c:	a5850513          	addi	a0,a0,-1448 # ffffffffc02058b0 <default_pmm_manager+0x6a8>
ffffffffc0202e60:	d14fd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(vma != NULL);
ffffffffc0202e64:	00003697          	auipc	a3,0x3
ffffffffc0202e68:	ad468693          	addi	a3,a3,-1324 # ffffffffc0205938 <default_pmm_manager+0x730>
ffffffffc0202e6c:	00002617          	auipc	a2,0x2
ffffffffc0202e70:	fec60613          	addi	a2,a2,-20 # ffffffffc0204e58 <commands+0x788>
ffffffffc0202e74:	0ce00593          	li	a1,206
ffffffffc0202e78:	00003517          	auipc	a0,0x3
ffffffffc0202e7c:	a3850513          	addi	a0,a0,-1480 # ffffffffc02058b0 <default_pmm_manager+0x6a8>
ffffffffc0202e80:	cf4fd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(temp_ptep!= NULL);
ffffffffc0202e84:	00003697          	auipc	a3,0x3
ffffffffc0202e88:	afc68693          	addi	a3,a3,-1284 # ffffffffc0205980 <default_pmm_manager+0x778>
ffffffffc0202e8c:	00002617          	auipc	a2,0x2
ffffffffc0202e90:	fcc60613          	addi	a2,a2,-52 # ffffffffc0204e58 <commands+0x788>
ffffffffc0202e94:	0d600593          	li	a1,214
ffffffffc0202e98:	00003517          	auipc	a0,0x3
ffffffffc0202e9c:	a1850513          	addi	a0,a0,-1512 # ffffffffc02058b0 <default_pmm_manager+0x6a8>
ffffffffc0202ea0:	cd4fd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(total == nr_free_pages());
ffffffffc0202ea4:	00002697          	auipc	a3,0x2
ffffffffc0202ea8:	fe468693          	addi	a3,a3,-28 # ffffffffc0204e88 <commands+0x7b8>
ffffffffc0202eac:	00002617          	auipc	a2,0x2
ffffffffc0202eb0:	fac60613          	addi	a2,a2,-84 # ffffffffc0204e58 <commands+0x788>
ffffffffc0202eb4:	0be00593          	li	a1,190
ffffffffc0202eb8:	00003517          	auipc	a0,0x3
ffffffffc0202ebc:	9f850513          	addi	a0,a0,-1544 # ffffffffc02058b0 <default_pmm_manager+0x6a8>
ffffffffc0202ec0:	cb4fd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(pgfault_num==2);
ffffffffc0202ec4:	00003697          	auipc	a3,0x3
ffffffffc0202ec8:	b9468693          	addi	a3,a3,-1132 # ffffffffc0205a58 <default_pmm_manager+0x850>
ffffffffc0202ecc:	00002617          	auipc	a2,0x2
ffffffffc0202ed0:	f8c60613          	addi	a2,a2,-116 # ffffffffc0204e58 <commands+0x788>
ffffffffc0202ed4:	09600593          	li	a1,150
ffffffffc0202ed8:	00003517          	auipc	a0,0x3
ffffffffc0202edc:	9d850513          	addi	a0,a0,-1576 # ffffffffc02058b0 <default_pmm_manager+0x6a8>
ffffffffc0202ee0:	c94fd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(pgfault_num==2);
ffffffffc0202ee4:	00003697          	auipc	a3,0x3
ffffffffc0202ee8:	b7468693          	addi	a3,a3,-1164 # ffffffffc0205a58 <default_pmm_manager+0x850>
ffffffffc0202eec:	00002617          	auipc	a2,0x2
ffffffffc0202ef0:	f6c60613          	addi	a2,a2,-148 # ffffffffc0204e58 <commands+0x788>
ffffffffc0202ef4:	09800593          	li	a1,152
ffffffffc0202ef8:	00003517          	auipc	a0,0x3
ffffffffc0202efc:	9b850513          	addi	a0,a0,-1608 # ffffffffc02058b0 <default_pmm_manager+0x6a8>
ffffffffc0202f00:	c74fd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(pgfault_num==3);
ffffffffc0202f04:	00003697          	auipc	a3,0x3
ffffffffc0202f08:	b6468693          	addi	a3,a3,-1180 # ffffffffc0205a68 <default_pmm_manager+0x860>
ffffffffc0202f0c:	00002617          	auipc	a2,0x2
ffffffffc0202f10:	f4c60613          	addi	a2,a2,-180 # ffffffffc0204e58 <commands+0x788>
ffffffffc0202f14:	09a00593          	li	a1,154
ffffffffc0202f18:	00003517          	auipc	a0,0x3
ffffffffc0202f1c:	99850513          	addi	a0,a0,-1640 # ffffffffc02058b0 <default_pmm_manager+0x6a8>
ffffffffc0202f20:	c54fd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(pgfault_num==3);
ffffffffc0202f24:	00003697          	auipc	a3,0x3
ffffffffc0202f28:	b4468693          	addi	a3,a3,-1212 # ffffffffc0205a68 <default_pmm_manager+0x860>
ffffffffc0202f2c:	00002617          	auipc	a2,0x2
ffffffffc0202f30:	f2c60613          	addi	a2,a2,-212 # ffffffffc0204e58 <commands+0x788>
ffffffffc0202f34:	09c00593          	li	a1,156
ffffffffc0202f38:	00003517          	auipc	a0,0x3
ffffffffc0202f3c:	97850513          	addi	a0,a0,-1672 # ffffffffc02058b0 <default_pmm_manager+0x6a8>
ffffffffc0202f40:	c34fd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(pgfault_num==1);
ffffffffc0202f44:	00003697          	auipc	a3,0x3
ffffffffc0202f48:	b0468693          	addi	a3,a3,-1276 # ffffffffc0205a48 <default_pmm_manager+0x840>
ffffffffc0202f4c:	00002617          	auipc	a2,0x2
ffffffffc0202f50:	f0c60613          	addi	a2,a2,-244 # ffffffffc0204e58 <commands+0x788>
ffffffffc0202f54:	09200593          	li	a1,146
ffffffffc0202f58:	00003517          	auipc	a0,0x3
ffffffffc0202f5c:	95850513          	addi	a0,a0,-1704 # ffffffffc02058b0 <default_pmm_manager+0x6a8>
ffffffffc0202f60:	c14fd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(pgfault_num==1);
ffffffffc0202f64:	00003697          	auipc	a3,0x3
ffffffffc0202f68:	ae468693          	addi	a3,a3,-1308 # ffffffffc0205a48 <default_pmm_manager+0x840>
ffffffffc0202f6c:	00002617          	auipc	a2,0x2
ffffffffc0202f70:	eec60613          	addi	a2,a2,-276 # ffffffffc0204e58 <commands+0x788>
ffffffffc0202f74:	09400593          	li	a1,148
ffffffffc0202f78:	00003517          	auipc	a0,0x3
ffffffffc0202f7c:	93850513          	addi	a0,a0,-1736 # ffffffffc02058b0 <default_pmm_manager+0x6a8>
ffffffffc0202f80:	bf4fd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(mm != NULL);
ffffffffc0202f84:	00003697          	auipc	a3,0x3
ffffffffc0202f88:	97c68693          	addi	a3,a3,-1668 # ffffffffc0205900 <default_pmm_manager+0x6f8>
ffffffffc0202f8c:	00002617          	auipc	a2,0x2
ffffffffc0202f90:	ecc60613          	addi	a2,a2,-308 # ffffffffc0204e58 <commands+0x788>
ffffffffc0202f94:	0c300593          	li	a1,195
ffffffffc0202f98:	00003517          	auipc	a0,0x3
ffffffffc0202f9c:	91850513          	addi	a0,a0,-1768 # ffffffffc02058b0 <default_pmm_manager+0x6a8>
ffffffffc0202fa0:	bd4fd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(check_mm_struct == NULL);
ffffffffc0202fa4:	00003697          	auipc	a3,0x3
ffffffffc0202fa8:	96c68693          	addi	a3,a3,-1684 # ffffffffc0205910 <default_pmm_manager+0x708>
ffffffffc0202fac:	00002617          	auipc	a2,0x2
ffffffffc0202fb0:	eac60613          	addi	a2,a2,-340 # ffffffffc0204e58 <commands+0x788>
ffffffffc0202fb4:	0c600593          	li	a1,198
ffffffffc0202fb8:	00003517          	auipc	a0,0x3
ffffffffc0202fbc:	8f850513          	addi	a0,a0,-1800 # ffffffffc02058b0 <default_pmm_manager+0x6a8>
ffffffffc0202fc0:	bb4fd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
ffffffffc0202fc4:	00003697          	auipc	a3,0x3
ffffffffc0202fc8:	a3468693          	addi	a3,a3,-1484 # ffffffffc02059f8 <default_pmm_manager+0x7f0>
ffffffffc0202fcc:	00002617          	auipc	a2,0x2
ffffffffc0202fd0:	e8c60613          	addi	a2,a2,-372 # ffffffffc0204e58 <commands+0x788>
ffffffffc0202fd4:	0e900593          	li	a1,233
ffffffffc0202fd8:	00003517          	auipc	a0,0x3
ffffffffc0202fdc:	8d850513          	addi	a0,a0,-1832 # ffffffffc02058b0 <default_pmm_manager+0x6a8>
ffffffffc0202fe0:	b94fd0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc0202fe4 <swap_init_mm>:
     return sm->init_mm(mm);
ffffffffc0202fe4:	0000e797          	auipc	a5,0xe
ffffffffc0202fe8:	56c7b783          	ld	a5,1388(a5) # ffffffffc0211550 <sm>
ffffffffc0202fec:	6b9c                	ld	a5,16(a5)
ffffffffc0202fee:	8782                	jr	a5

ffffffffc0202ff0 <swap_map_swappable>:
     return sm->map_swappable(mm, addr, page, swap_in);
ffffffffc0202ff0:	0000e797          	auipc	a5,0xe
ffffffffc0202ff4:	5607b783          	ld	a5,1376(a5) # ffffffffc0211550 <sm>
ffffffffc0202ff8:	739c                	ld	a5,32(a5)
ffffffffc0202ffa:	8782                	jr	a5

ffffffffc0202ffc <swap_out>:
{
ffffffffc0202ffc:	711d                	addi	sp,sp,-96
ffffffffc0202ffe:	ec86                	sd	ra,88(sp)
ffffffffc0203000:	e8a2                	sd	s0,80(sp)
ffffffffc0203002:	e4a6                	sd	s1,72(sp)
ffffffffc0203004:	e0ca                	sd	s2,64(sp)
ffffffffc0203006:	fc4e                	sd	s3,56(sp)
ffffffffc0203008:	f852                	sd	s4,48(sp)
ffffffffc020300a:	f456                	sd	s5,40(sp)
ffffffffc020300c:	f05a                	sd	s6,32(sp)
ffffffffc020300e:	ec5e                	sd	s7,24(sp)
ffffffffc0203010:	e862                	sd	s8,16(sp)
     for (i = 0; i != n; ++ i)
ffffffffc0203012:	cde9                	beqz	a1,ffffffffc02030ec <swap_out+0xf0>
ffffffffc0203014:	8a2e                	mv	s4,a1
ffffffffc0203016:	892a                	mv	s2,a0
ffffffffc0203018:	8ab2                	mv	s5,a2
ffffffffc020301a:	4401                	li	s0,0
ffffffffc020301c:	0000e997          	auipc	s3,0xe
ffffffffc0203020:	53498993          	addi	s3,s3,1332 # ffffffffc0211550 <sm>
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0203024:	00003b17          	auipc	s6,0x3
ffffffffc0203028:	b74b0b13          	addi	s6,s6,-1164 # ffffffffc0205b98 <default_pmm_manager+0x990>
                    cprintf("SWAP: failed to save\n");
ffffffffc020302c:	00003b97          	auipc	s7,0x3
ffffffffc0203030:	b54b8b93          	addi	s7,s7,-1196 # ffffffffc0205b80 <default_pmm_manager+0x978>
ffffffffc0203034:	a825                	j	ffffffffc020306c <swap_out+0x70>
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0203036:	67a2                	ld	a5,8(sp)
ffffffffc0203038:	8626                	mv	a2,s1
ffffffffc020303a:	85a2                	mv	a1,s0
ffffffffc020303c:	63b4                	ld	a3,64(a5)
ffffffffc020303e:	855a                	mv	a0,s6
     for (i = 0; i != n; ++ i)
ffffffffc0203040:	2405                	addiw	s0,s0,1
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0203042:	82b1                	srli	a3,a3,0xc
ffffffffc0203044:	0685                	addi	a3,a3,1
ffffffffc0203046:	874fd0ef          	jal	ra,ffffffffc02000ba <cprintf>
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
ffffffffc020304a:	6522                	ld	a0,8(sp)
                    free_page(page);
ffffffffc020304c:	4585                	li	a1,1
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
ffffffffc020304e:	613c                	ld	a5,64(a0)
ffffffffc0203050:	83b1                	srli	a5,a5,0xc
ffffffffc0203052:	0785                	addi	a5,a5,1
ffffffffc0203054:	07a2                	slli	a5,a5,0x8
ffffffffc0203056:	00fc3023          	sd	a5,0(s8)
                    free_page(page);
ffffffffc020305a:	e58fe0ef          	jal	ra,ffffffffc02016b2 <free_pages>
          tlb_invalidate(mm->pgdir, v);
ffffffffc020305e:	01893503          	ld	a0,24(s2)
ffffffffc0203062:	85a6                	mv	a1,s1
ffffffffc0203064:	eb6ff0ef          	jal	ra,ffffffffc020271a <tlb_invalidate>
     for (i = 0; i != n; ++ i)
ffffffffc0203068:	048a0d63          	beq	s4,s0,ffffffffc02030c2 <swap_out+0xc6>
          int r = sm->swap_out_victim(mm, &page, in_tick);
ffffffffc020306c:	0009b783          	ld	a5,0(s3)
ffffffffc0203070:	8656                	mv	a2,s5
ffffffffc0203072:	002c                	addi	a1,sp,8
ffffffffc0203074:	7b9c                	ld	a5,48(a5)
ffffffffc0203076:	854a                	mv	a0,s2
ffffffffc0203078:	9782                	jalr	a5
          if (r != 0) {
ffffffffc020307a:	e12d                	bnez	a0,ffffffffc02030dc <swap_out+0xe0>
          v=page->pra_vaddr; 
ffffffffc020307c:	67a2                	ld	a5,8(sp)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc020307e:	01893503          	ld	a0,24(s2)
ffffffffc0203082:	4601                	li	a2,0
          v=page->pra_vaddr; 
ffffffffc0203084:	63a4                	ld	s1,64(a5)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0203086:	85a6                	mv	a1,s1
ffffffffc0203088:	ea4fe0ef          	jal	ra,ffffffffc020172c <get_pte>
          assert((*ptep & PTE_V) != 0);
ffffffffc020308c:	611c                	ld	a5,0(a0)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc020308e:	8c2a                	mv	s8,a0
          assert((*ptep & PTE_V) != 0);
ffffffffc0203090:	8b85                	andi	a5,a5,1
ffffffffc0203092:	cfb9                	beqz	a5,ffffffffc02030f0 <swap_out+0xf4>
          if (swapfs_write( (page->pra_vaddr/PGSIZE+1)<<8, page) != 0) {
ffffffffc0203094:	65a2                	ld	a1,8(sp)
ffffffffc0203096:	61bc                	ld	a5,64(a1)
ffffffffc0203098:	83b1                	srli	a5,a5,0xc
ffffffffc020309a:	0785                	addi	a5,a5,1
ffffffffc020309c:	00879513          	slli	a0,a5,0x8
ffffffffc02030a0:	5f5000ef          	jal	ra,ffffffffc0203e94 <swapfs_write>
ffffffffc02030a4:	d949                	beqz	a0,ffffffffc0203036 <swap_out+0x3a>
                    cprintf("SWAP: failed to save\n");
ffffffffc02030a6:	855e                	mv	a0,s7
ffffffffc02030a8:	812fd0ef          	jal	ra,ffffffffc02000ba <cprintf>
                    sm->map_swappable(mm, v, page, 0);
ffffffffc02030ac:	0009b783          	ld	a5,0(s3)
ffffffffc02030b0:	6622                	ld	a2,8(sp)
ffffffffc02030b2:	4681                	li	a3,0
ffffffffc02030b4:	739c                	ld	a5,32(a5)
ffffffffc02030b6:	85a6                	mv	a1,s1
ffffffffc02030b8:	854a                	mv	a0,s2
     for (i = 0; i != n; ++ i)
ffffffffc02030ba:	2405                	addiw	s0,s0,1
                    sm->map_swappable(mm, v, page, 0);
ffffffffc02030bc:	9782                	jalr	a5
     for (i = 0; i != n; ++ i)
ffffffffc02030be:	fa8a17e3          	bne	s4,s0,ffffffffc020306c <swap_out+0x70>
}
ffffffffc02030c2:	60e6                	ld	ra,88(sp)
ffffffffc02030c4:	8522                	mv	a0,s0
ffffffffc02030c6:	6446                	ld	s0,80(sp)
ffffffffc02030c8:	64a6                	ld	s1,72(sp)
ffffffffc02030ca:	6906                	ld	s2,64(sp)
ffffffffc02030cc:	79e2                	ld	s3,56(sp)
ffffffffc02030ce:	7a42                	ld	s4,48(sp)
ffffffffc02030d0:	7aa2                	ld	s5,40(sp)
ffffffffc02030d2:	7b02                	ld	s6,32(sp)
ffffffffc02030d4:	6be2                	ld	s7,24(sp)
ffffffffc02030d6:	6c42                	ld	s8,16(sp)
ffffffffc02030d8:	6125                	addi	sp,sp,96
ffffffffc02030da:	8082                	ret
                    cprintf("i %d, swap_out: call swap_out_victim failed\n",i);
ffffffffc02030dc:	85a2                	mv	a1,s0
ffffffffc02030de:	00003517          	auipc	a0,0x3
ffffffffc02030e2:	a5a50513          	addi	a0,a0,-1446 # ffffffffc0205b38 <default_pmm_manager+0x930>
ffffffffc02030e6:	fd5fc0ef          	jal	ra,ffffffffc02000ba <cprintf>
                  break;
ffffffffc02030ea:	bfe1                	j	ffffffffc02030c2 <swap_out+0xc6>
     for (i = 0; i != n; ++ i)
ffffffffc02030ec:	4401                	li	s0,0
ffffffffc02030ee:	bfd1                	j	ffffffffc02030c2 <swap_out+0xc6>
          assert((*ptep & PTE_V) != 0);
ffffffffc02030f0:	00003697          	auipc	a3,0x3
ffffffffc02030f4:	a7868693          	addi	a3,a3,-1416 # ffffffffc0205b68 <default_pmm_manager+0x960>
ffffffffc02030f8:	00002617          	auipc	a2,0x2
ffffffffc02030fc:	d6060613          	addi	a2,a2,-672 # ffffffffc0204e58 <commands+0x788>
ffffffffc0203100:	06700593          	li	a1,103
ffffffffc0203104:	00002517          	auipc	a0,0x2
ffffffffc0203108:	7ac50513          	addi	a0,a0,1964 # ffffffffc02058b0 <default_pmm_manager+0x6a8>
ffffffffc020310c:	a68fd0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc0203110 <swap_in>:
{
ffffffffc0203110:	7179                	addi	sp,sp,-48
ffffffffc0203112:	e84a                	sd	s2,16(sp)
ffffffffc0203114:	892a                	mv	s2,a0
     struct Page *result = alloc_page();
ffffffffc0203116:	4505                	li	a0,1
{
ffffffffc0203118:	ec26                	sd	s1,24(sp)
ffffffffc020311a:	e44e                	sd	s3,8(sp)
ffffffffc020311c:	f406                	sd	ra,40(sp)
ffffffffc020311e:	f022                	sd	s0,32(sp)
ffffffffc0203120:	84ae                	mv	s1,a1
ffffffffc0203122:	89b2                	mv	s3,a2
     struct Page *result = alloc_page();
ffffffffc0203124:	cfcfe0ef          	jal	ra,ffffffffc0201620 <alloc_pages>
     assert(result!=NULL);
ffffffffc0203128:	c129                	beqz	a0,ffffffffc020316a <swap_in+0x5a>
     pte_t *ptep = get_pte(mm->pgdir, addr, 0);
ffffffffc020312a:	842a                	mv	s0,a0
ffffffffc020312c:	01893503          	ld	a0,24(s2)
ffffffffc0203130:	4601                	li	a2,0
ffffffffc0203132:	85a6                	mv	a1,s1
ffffffffc0203134:	df8fe0ef          	jal	ra,ffffffffc020172c <get_pte>
ffffffffc0203138:	892a                	mv	s2,a0
     if ((r = swapfs_read((*ptep), result)) != 0)
ffffffffc020313a:	6108                	ld	a0,0(a0)
ffffffffc020313c:	85a2                	mv	a1,s0
ffffffffc020313e:	4bd000ef          	jal	ra,ffffffffc0203dfa <swapfs_read>
     cprintf("swap_in: load disk swap entry %d with swap_page in vadr 0x%x\n", (*ptep)>>8, addr);
ffffffffc0203142:	00093583          	ld	a1,0(s2)
ffffffffc0203146:	8626                	mv	a2,s1
ffffffffc0203148:	00003517          	auipc	a0,0x3
ffffffffc020314c:	aa050513          	addi	a0,a0,-1376 # ffffffffc0205be8 <default_pmm_manager+0x9e0>
ffffffffc0203150:	81a1                	srli	a1,a1,0x8
ffffffffc0203152:	f69fc0ef          	jal	ra,ffffffffc02000ba <cprintf>
}
ffffffffc0203156:	70a2                	ld	ra,40(sp)
     *ptr_result=result;
ffffffffc0203158:	0089b023          	sd	s0,0(s3)
}
ffffffffc020315c:	7402                	ld	s0,32(sp)
ffffffffc020315e:	64e2                	ld	s1,24(sp)
ffffffffc0203160:	6942                	ld	s2,16(sp)
ffffffffc0203162:	69a2                	ld	s3,8(sp)
ffffffffc0203164:	4501                	li	a0,0
ffffffffc0203166:	6145                	addi	sp,sp,48
ffffffffc0203168:	8082                	ret
     assert(result!=NULL);
ffffffffc020316a:	00003697          	auipc	a3,0x3
ffffffffc020316e:	a6e68693          	addi	a3,a3,-1426 # ffffffffc0205bd8 <default_pmm_manager+0x9d0>
ffffffffc0203172:	00002617          	auipc	a2,0x2
ffffffffc0203176:	ce660613          	addi	a2,a2,-794 # ffffffffc0204e58 <commands+0x788>
ffffffffc020317a:	07d00593          	li	a1,125
ffffffffc020317e:	00002517          	auipc	a0,0x2
ffffffffc0203182:	73250513          	addi	a0,a0,1842 # ffffffffc02058b0 <default_pmm_manager+0x6a8>
ffffffffc0203186:	9eefd0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc020318a <_clock_init_mm>:
    elm->prev = elm->next = elm;
ffffffffc020318a:	0000e797          	auipc	a5,0xe
ffffffffc020318e:	f5e78793          	addi	a5,a5,-162 # ffffffffc02110e8 <pra_list_head>
     // 初始化pra_list_head为空链表
     list_init(&pra_list_head);
     // 初始化当前指针curr_ptr指向pra_list_head，表示当前页面替换位置为链表头
     curr_ptr=&pra_list_head;
     // 将mm的私有成员指针指向pra_list_head，用于后续的页面替换算法操作
     mm->sm_priv = &pra_list_head;;
ffffffffc0203192:	f51c                	sd	a5,40(a0)
ffffffffc0203194:	e79c                	sd	a5,8(a5)
ffffffffc0203196:	e39c                	sd	a5,0(a5)
     curr_ptr=&pra_list_head;
ffffffffc0203198:	0000e717          	auipc	a4,0xe
ffffffffc020319c:	3cf73423          	sd	a5,968(a4) # ffffffffc0211560 <curr_ptr>
     //cprintf(" mm->sm_priv %x in fifo_init_mm\n",mm->sm_priv);
     return 0;
}
ffffffffc02031a0:	4501                	li	a0,0
ffffffffc02031a2:	8082                	ret

ffffffffc02031a4 <_clock_init>:

static int
_clock_init(void)
{
    return 0;
}
ffffffffc02031a4:	4501                	li	a0,0
ffffffffc02031a6:	8082                	ret

ffffffffc02031a8 <_clock_set_unswappable>:

static int
_clock_set_unswappable(struct mm_struct *mm, uintptr_t addr)
{
    return 0;
}
ffffffffc02031a8:	4501                	li	a0,0
ffffffffc02031aa:	8082                	ret

ffffffffc02031ac <_clock_tick_event>:

static int
_clock_tick_event(struct mm_struct *mm)
{ return 0; }
ffffffffc02031ac:	4501                	li	a0,0
ffffffffc02031ae:	8082                	ret

ffffffffc02031b0 <_clock_check_swap>:
_clock_check_swap(void) {
ffffffffc02031b0:	1141                	addi	sp,sp,-16
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc02031b2:	4731                	li	a4,12
_clock_check_swap(void) {
ffffffffc02031b4:	e406                	sd	ra,8(sp)
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc02031b6:	678d                	lui	a5,0x3
ffffffffc02031b8:	00e78023          	sb	a4,0(a5) # 3000 <kern_entry-0xffffffffc01fd000>
    assert(pgfault_num==4);
ffffffffc02031bc:	0000e697          	auipc	a3,0xe
ffffffffc02031c0:	3b46a683          	lw	a3,948(a3) # ffffffffc0211570 <pgfault_num>
ffffffffc02031c4:	4711                	li	a4,4
ffffffffc02031c6:	0ae69363          	bne	a3,a4,ffffffffc020326c <_clock_check_swap+0xbc>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc02031ca:	6705                	lui	a4,0x1
ffffffffc02031cc:	4629                	li	a2,10
ffffffffc02031ce:	0000e797          	auipc	a5,0xe
ffffffffc02031d2:	3a278793          	addi	a5,a5,930 # ffffffffc0211570 <pgfault_num>
ffffffffc02031d6:	00c70023          	sb	a2,0(a4) # 1000 <kern_entry-0xffffffffc01ff000>
    assert(pgfault_num==4);
ffffffffc02031da:	4398                	lw	a4,0(a5)
ffffffffc02031dc:	2701                	sext.w	a4,a4
ffffffffc02031de:	20d71763          	bne	a4,a3,ffffffffc02033ec <_clock_check_swap+0x23c>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc02031e2:	6691                	lui	a3,0x4
ffffffffc02031e4:	4635                	li	a2,13
ffffffffc02031e6:	00c68023          	sb	a2,0(a3) # 4000 <kern_entry-0xffffffffc01fc000>
    assert(pgfault_num==4);
ffffffffc02031ea:	4394                	lw	a3,0(a5)
ffffffffc02031ec:	2681                	sext.w	a3,a3
ffffffffc02031ee:	1ce69f63          	bne	a3,a4,ffffffffc02033cc <_clock_check_swap+0x21c>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc02031f2:	6709                	lui	a4,0x2
ffffffffc02031f4:	462d                	li	a2,11
ffffffffc02031f6:	00c70023          	sb	a2,0(a4) # 2000 <kern_entry-0xffffffffc01fe000>
    assert(pgfault_num==4);
ffffffffc02031fa:	4398                	lw	a4,0(a5)
ffffffffc02031fc:	2701                	sext.w	a4,a4
ffffffffc02031fe:	1ad71763          	bne	a4,a3,ffffffffc02033ac <_clock_check_swap+0x1fc>
    *(unsigned char *)0x5000 = 0x0e;
ffffffffc0203202:	6715                	lui	a4,0x5
ffffffffc0203204:	46b9                	li	a3,14
ffffffffc0203206:	00d70023          	sb	a3,0(a4) # 5000 <kern_entry-0xffffffffc01fb000>
    assert(pgfault_num==5);
ffffffffc020320a:	4398                	lw	a4,0(a5)
ffffffffc020320c:	4695                	li	a3,5
ffffffffc020320e:	2701                	sext.w	a4,a4
ffffffffc0203210:	16d71e63          	bne	a4,a3,ffffffffc020338c <_clock_check_swap+0x1dc>
    assert(pgfault_num==5);
ffffffffc0203214:	4394                	lw	a3,0(a5)
ffffffffc0203216:	2681                	sext.w	a3,a3
ffffffffc0203218:	14e69a63          	bne	a3,a4,ffffffffc020336c <_clock_check_swap+0x1bc>
    assert(pgfault_num==5);
ffffffffc020321c:	4398                	lw	a4,0(a5)
ffffffffc020321e:	2701                	sext.w	a4,a4
ffffffffc0203220:	12d71663          	bne	a4,a3,ffffffffc020334c <_clock_check_swap+0x19c>
    assert(pgfault_num==5);
ffffffffc0203224:	4394                	lw	a3,0(a5)
ffffffffc0203226:	2681                	sext.w	a3,a3
ffffffffc0203228:	10e69263          	bne	a3,a4,ffffffffc020332c <_clock_check_swap+0x17c>
    assert(pgfault_num==5);
ffffffffc020322c:	4398                	lw	a4,0(a5)
ffffffffc020322e:	2701                	sext.w	a4,a4
ffffffffc0203230:	0cd71e63          	bne	a4,a3,ffffffffc020330c <_clock_check_swap+0x15c>
    assert(pgfault_num==5);
ffffffffc0203234:	4394                	lw	a3,0(a5)
ffffffffc0203236:	2681                	sext.w	a3,a3
ffffffffc0203238:	0ae69a63          	bne	a3,a4,ffffffffc02032ec <_clock_check_swap+0x13c>
    *(unsigned char *)0x5000 = 0x0e;
ffffffffc020323c:	6715                	lui	a4,0x5
ffffffffc020323e:	46b9                	li	a3,14
ffffffffc0203240:	00d70023          	sb	a3,0(a4) # 5000 <kern_entry-0xffffffffc01fb000>
    assert(pgfault_num==5);
ffffffffc0203244:	4398                	lw	a4,0(a5)
ffffffffc0203246:	4695                	li	a3,5
ffffffffc0203248:	2701                	sext.w	a4,a4
ffffffffc020324a:	08d71163          	bne	a4,a3,ffffffffc02032cc <_clock_check_swap+0x11c>
    assert(*(unsigned char *)0x1000 == 0x0a);
ffffffffc020324e:	6705                	lui	a4,0x1
ffffffffc0203250:	00074683          	lbu	a3,0(a4) # 1000 <kern_entry-0xffffffffc01ff000>
ffffffffc0203254:	4729                	li	a4,10
ffffffffc0203256:	04e69b63          	bne	a3,a4,ffffffffc02032ac <_clock_check_swap+0xfc>
    assert(pgfault_num==6);
ffffffffc020325a:	439c                	lw	a5,0(a5)
ffffffffc020325c:	4719                	li	a4,6
ffffffffc020325e:	2781                	sext.w	a5,a5
ffffffffc0203260:	02e79663          	bne	a5,a4,ffffffffc020328c <_clock_check_swap+0xdc>
}
ffffffffc0203264:	60a2                	ld	ra,8(sp)
ffffffffc0203266:	4501                	li	a0,0
ffffffffc0203268:	0141                	addi	sp,sp,16
ffffffffc020326a:	8082                	ret
    assert(pgfault_num==4);
ffffffffc020326c:	00003697          	auipc	a3,0x3
ffffffffc0203270:	80c68693          	addi	a3,a3,-2036 # ffffffffc0205a78 <default_pmm_manager+0x870>
ffffffffc0203274:	00002617          	auipc	a2,0x2
ffffffffc0203278:	be460613          	addi	a2,a2,-1052 # ffffffffc0204e58 <commands+0x788>
ffffffffc020327c:	09000593          	li	a1,144
ffffffffc0203280:	00003517          	auipc	a0,0x3
ffffffffc0203284:	9a850513          	addi	a0,a0,-1624 # ffffffffc0205c28 <default_pmm_manager+0xa20>
ffffffffc0203288:	8ecfd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(pgfault_num==6);
ffffffffc020328c:	00003697          	auipc	a3,0x3
ffffffffc0203290:	9ec68693          	addi	a3,a3,-1556 # ffffffffc0205c78 <default_pmm_manager+0xa70>
ffffffffc0203294:	00002617          	auipc	a2,0x2
ffffffffc0203298:	bc460613          	addi	a2,a2,-1084 # ffffffffc0204e58 <commands+0x788>
ffffffffc020329c:	0a700593          	li	a1,167
ffffffffc02032a0:	00003517          	auipc	a0,0x3
ffffffffc02032a4:	98850513          	addi	a0,a0,-1656 # ffffffffc0205c28 <default_pmm_manager+0xa20>
ffffffffc02032a8:	8ccfd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(*(unsigned char *)0x1000 == 0x0a);
ffffffffc02032ac:	00003697          	auipc	a3,0x3
ffffffffc02032b0:	9a468693          	addi	a3,a3,-1628 # ffffffffc0205c50 <default_pmm_manager+0xa48>
ffffffffc02032b4:	00002617          	auipc	a2,0x2
ffffffffc02032b8:	ba460613          	addi	a2,a2,-1116 # ffffffffc0204e58 <commands+0x788>
ffffffffc02032bc:	0a500593          	li	a1,165
ffffffffc02032c0:	00003517          	auipc	a0,0x3
ffffffffc02032c4:	96850513          	addi	a0,a0,-1688 # ffffffffc0205c28 <default_pmm_manager+0xa20>
ffffffffc02032c8:	8acfd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(pgfault_num==5);
ffffffffc02032cc:	00003697          	auipc	a3,0x3
ffffffffc02032d0:	97468693          	addi	a3,a3,-1676 # ffffffffc0205c40 <default_pmm_manager+0xa38>
ffffffffc02032d4:	00002617          	auipc	a2,0x2
ffffffffc02032d8:	b8460613          	addi	a2,a2,-1148 # ffffffffc0204e58 <commands+0x788>
ffffffffc02032dc:	0a400593          	li	a1,164
ffffffffc02032e0:	00003517          	auipc	a0,0x3
ffffffffc02032e4:	94850513          	addi	a0,a0,-1720 # ffffffffc0205c28 <default_pmm_manager+0xa20>
ffffffffc02032e8:	88cfd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(pgfault_num==5);
ffffffffc02032ec:	00003697          	auipc	a3,0x3
ffffffffc02032f0:	95468693          	addi	a3,a3,-1708 # ffffffffc0205c40 <default_pmm_manager+0xa38>
ffffffffc02032f4:	00002617          	auipc	a2,0x2
ffffffffc02032f8:	b6460613          	addi	a2,a2,-1180 # ffffffffc0204e58 <commands+0x788>
ffffffffc02032fc:	0a200593          	li	a1,162
ffffffffc0203300:	00003517          	auipc	a0,0x3
ffffffffc0203304:	92850513          	addi	a0,a0,-1752 # ffffffffc0205c28 <default_pmm_manager+0xa20>
ffffffffc0203308:	86cfd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(pgfault_num==5);
ffffffffc020330c:	00003697          	auipc	a3,0x3
ffffffffc0203310:	93468693          	addi	a3,a3,-1740 # ffffffffc0205c40 <default_pmm_manager+0xa38>
ffffffffc0203314:	00002617          	auipc	a2,0x2
ffffffffc0203318:	b4460613          	addi	a2,a2,-1212 # ffffffffc0204e58 <commands+0x788>
ffffffffc020331c:	0a000593          	li	a1,160
ffffffffc0203320:	00003517          	auipc	a0,0x3
ffffffffc0203324:	90850513          	addi	a0,a0,-1784 # ffffffffc0205c28 <default_pmm_manager+0xa20>
ffffffffc0203328:	84cfd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(pgfault_num==5);
ffffffffc020332c:	00003697          	auipc	a3,0x3
ffffffffc0203330:	91468693          	addi	a3,a3,-1772 # ffffffffc0205c40 <default_pmm_manager+0xa38>
ffffffffc0203334:	00002617          	auipc	a2,0x2
ffffffffc0203338:	b2460613          	addi	a2,a2,-1244 # ffffffffc0204e58 <commands+0x788>
ffffffffc020333c:	09e00593          	li	a1,158
ffffffffc0203340:	00003517          	auipc	a0,0x3
ffffffffc0203344:	8e850513          	addi	a0,a0,-1816 # ffffffffc0205c28 <default_pmm_manager+0xa20>
ffffffffc0203348:	82cfd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(pgfault_num==5);
ffffffffc020334c:	00003697          	auipc	a3,0x3
ffffffffc0203350:	8f468693          	addi	a3,a3,-1804 # ffffffffc0205c40 <default_pmm_manager+0xa38>
ffffffffc0203354:	00002617          	auipc	a2,0x2
ffffffffc0203358:	b0460613          	addi	a2,a2,-1276 # ffffffffc0204e58 <commands+0x788>
ffffffffc020335c:	09c00593          	li	a1,156
ffffffffc0203360:	00003517          	auipc	a0,0x3
ffffffffc0203364:	8c850513          	addi	a0,a0,-1848 # ffffffffc0205c28 <default_pmm_manager+0xa20>
ffffffffc0203368:	80cfd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(pgfault_num==5);
ffffffffc020336c:	00003697          	auipc	a3,0x3
ffffffffc0203370:	8d468693          	addi	a3,a3,-1836 # ffffffffc0205c40 <default_pmm_manager+0xa38>
ffffffffc0203374:	00002617          	auipc	a2,0x2
ffffffffc0203378:	ae460613          	addi	a2,a2,-1308 # ffffffffc0204e58 <commands+0x788>
ffffffffc020337c:	09a00593          	li	a1,154
ffffffffc0203380:	00003517          	auipc	a0,0x3
ffffffffc0203384:	8a850513          	addi	a0,a0,-1880 # ffffffffc0205c28 <default_pmm_manager+0xa20>
ffffffffc0203388:	fedfc0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(pgfault_num==5);
ffffffffc020338c:	00003697          	auipc	a3,0x3
ffffffffc0203390:	8b468693          	addi	a3,a3,-1868 # ffffffffc0205c40 <default_pmm_manager+0xa38>
ffffffffc0203394:	00002617          	auipc	a2,0x2
ffffffffc0203398:	ac460613          	addi	a2,a2,-1340 # ffffffffc0204e58 <commands+0x788>
ffffffffc020339c:	09800593          	li	a1,152
ffffffffc02033a0:	00003517          	auipc	a0,0x3
ffffffffc02033a4:	88850513          	addi	a0,a0,-1912 # ffffffffc0205c28 <default_pmm_manager+0xa20>
ffffffffc02033a8:	fcdfc0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(pgfault_num==4);
ffffffffc02033ac:	00002697          	auipc	a3,0x2
ffffffffc02033b0:	6cc68693          	addi	a3,a3,1740 # ffffffffc0205a78 <default_pmm_manager+0x870>
ffffffffc02033b4:	00002617          	auipc	a2,0x2
ffffffffc02033b8:	aa460613          	addi	a2,a2,-1372 # ffffffffc0204e58 <commands+0x788>
ffffffffc02033bc:	09600593          	li	a1,150
ffffffffc02033c0:	00003517          	auipc	a0,0x3
ffffffffc02033c4:	86850513          	addi	a0,a0,-1944 # ffffffffc0205c28 <default_pmm_manager+0xa20>
ffffffffc02033c8:	fadfc0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(pgfault_num==4);
ffffffffc02033cc:	00002697          	auipc	a3,0x2
ffffffffc02033d0:	6ac68693          	addi	a3,a3,1708 # ffffffffc0205a78 <default_pmm_manager+0x870>
ffffffffc02033d4:	00002617          	auipc	a2,0x2
ffffffffc02033d8:	a8460613          	addi	a2,a2,-1404 # ffffffffc0204e58 <commands+0x788>
ffffffffc02033dc:	09400593          	li	a1,148
ffffffffc02033e0:	00003517          	auipc	a0,0x3
ffffffffc02033e4:	84850513          	addi	a0,a0,-1976 # ffffffffc0205c28 <default_pmm_manager+0xa20>
ffffffffc02033e8:	f8dfc0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(pgfault_num==4);
ffffffffc02033ec:	00002697          	auipc	a3,0x2
ffffffffc02033f0:	68c68693          	addi	a3,a3,1676 # ffffffffc0205a78 <default_pmm_manager+0x870>
ffffffffc02033f4:	00002617          	auipc	a2,0x2
ffffffffc02033f8:	a6460613          	addi	a2,a2,-1436 # ffffffffc0204e58 <commands+0x788>
ffffffffc02033fc:	09200593          	li	a1,146
ffffffffc0203400:	00003517          	auipc	a0,0x3
ffffffffc0203404:	82850513          	addi	a0,a0,-2008 # ffffffffc0205c28 <default_pmm_manager+0xa20>
ffffffffc0203408:	f6dfc0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc020340c <_clock_map_swappable>:
    assert(entry != NULL && curr_ptr != NULL);
ffffffffc020340c:	0000e797          	auipc	a5,0xe
ffffffffc0203410:	1547b783          	ld	a5,340(a5) # ffffffffc0211560 <curr_ptr>
ffffffffc0203414:	c385                	beqz	a5,ffffffffc0203434 <_clock_map_swappable+0x28>
    __list_add(elm, listelm->prev, listelm);
ffffffffc0203416:	0000e797          	auipc	a5,0xe
ffffffffc020341a:	cd278793          	addi	a5,a5,-814 # ffffffffc02110e8 <pra_list_head>
ffffffffc020341e:	6394                	ld	a3,0(a5)
ffffffffc0203420:	03060713          	addi	a4,a2,48
    prev->next = next->prev = elm;
ffffffffc0203424:	e398                	sd	a4,0(a5)
ffffffffc0203426:	e698                	sd	a4,8(a3)
    elm->next = next;
ffffffffc0203428:	fe1c                	sd	a5,56(a2)
    page->visited = 1;
ffffffffc020342a:	4785                	li	a5,1
    elm->prev = prev;
ffffffffc020342c:	fa14                	sd	a3,48(a2)
ffffffffc020342e:	ea1c                	sd	a5,16(a2)
}
ffffffffc0203430:	4501                	li	a0,0
ffffffffc0203432:	8082                	ret
{
ffffffffc0203434:	1141                	addi	sp,sp,-16
    assert(entry != NULL && curr_ptr != NULL);
ffffffffc0203436:	00003697          	auipc	a3,0x3
ffffffffc020343a:	85268693          	addi	a3,a3,-1966 # ffffffffc0205c88 <default_pmm_manager+0xa80>
ffffffffc020343e:	00002617          	auipc	a2,0x2
ffffffffc0203442:	a1a60613          	addi	a2,a2,-1510 # ffffffffc0204e58 <commands+0x788>
ffffffffc0203446:	03600593          	li	a1,54
ffffffffc020344a:	00002517          	auipc	a0,0x2
ffffffffc020344e:	7de50513          	addi	a0,a0,2014 # ffffffffc0205c28 <default_pmm_manager+0xa20>
{
ffffffffc0203452:	e406                	sd	ra,8(sp)
    assert(entry != NULL && curr_ptr != NULL);
ffffffffc0203454:	f21fc0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc0203458 <_clock_swap_out_victim>:
    assert(head != NULL);
ffffffffc0203458:	751c                	ld	a5,40(a0)
{
ffffffffc020345a:	1101                	addi	sp,sp,-32
ffffffffc020345c:	ec06                	sd	ra,24(sp)
ffffffffc020345e:	e822                	sd	s0,16(sp)
ffffffffc0203460:	e426                	sd	s1,8(sp)
ffffffffc0203462:	e04a                	sd	s2,0(sp)
    assert(head != NULL);
ffffffffc0203464:	cba5                	beqz	a5,ffffffffc02034d4 <_clock_swap_out_victim+0x7c>
    assert(in_tick==0);
ffffffffc0203466:	e659                	bnez	a2,ffffffffc02034f4 <_clock_swap_out_victim+0x9c>
ffffffffc0203468:	0000e497          	auipc	s1,0xe
ffffffffc020346c:	0f848493          	addi	s1,s1,248 # ffffffffc0211560 <curr_ptr>
ffffffffc0203470:	6080                	ld	s0,0(s1)
    return listelm->next;
ffffffffc0203472:	0000e697          	auipc	a3,0xe
ffffffffc0203476:	c7668693          	addi	a3,a3,-906 # ffffffffc02110e8 <pra_list_head>
ffffffffc020347a:	6690                	ld	a2,8(a3)
ffffffffc020347c:	892e                	mv	s2,a1
ffffffffc020347e:	4701                	li	a4,0
        if (curr_ptr == &pra_list_head)
ffffffffc0203480:	00d40b63          	beq	s0,a3,ffffffffc0203496 <_clock_swap_out_victim+0x3e>
        if (page->visited == 0) {
ffffffffc0203484:	fe043783          	ld	a5,-32(s0)
ffffffffc0203488:	cf81                	beqz	a5,ffffffffc02034a0 <_clock_swap_out_victim+0x48>
            page->visited = 0;
ffffffffc020348a:	fe043023          	sd	zero,-32(s0)
ffffffffc020348e:	6400                	ld	s0,8(s0)
    while(1){
ffffffffc0203490:	4705                	li	a4,1
        if (curr_ptr == &pra_list_head)
ffffffffc0203492:	fed419e3          	bne	s0,a3,ffffffffc0203484 <_clock_swap_out_victim+0x2c>
            curr_ptr = list_next(curr_ptr);
ffffffffc0203496:	8432                	mv	s0,a2
        if (page->visited == 0) {
ffffffffc0203498:	fe043783          	ld	a5,-32(s0)
ffffffffc020349c:	4705                	li	a4,1
ffffffffc020349e:	f7f5                	bnez	a5,ffffffffc020348a <_clock_swap_out_victim+0x32>
ffffffffc02034a0:	c311                	beqz	a4,ffffffffc02034a4 <_clock_swap_out_victim+0x4c>
ffffffffc02034a2:	e080                	sd	s0,0(s1)
            cprintf("curr_ptr %p\n", curr_ptr);
ffffffffc02034a4:	85a2                	mv	a1,s0
ffffffffc02034a6:	00003517          	auipc	a0,0x3
ffffffffc02034aa:	82a50513          	addi	a0,a0,-2006 # ffffffffc0205cd0 <default_pmm_manager+0xac8>
ffffffffc02034ae:	c0dfc0ef          	jal	ra,ffffffffc02000ba <cprintf>
            list_del(curr_ptr);
ffffffffc02034b2:	609c                	ld	a5,0(s1)
        struct Page *page = le2page(curr_ptr, pra_page_link);
ffffffffc02034b4:	fd040413          	addi	s0,s0,-48
}
ffffffffc02034b8:	60e2                	ld	ra,24(sp)
    __list_del(listelm->prev, listelm->next);
ffffffffc02034ba:	6398                	ld	a4,0(a5)
ffffffffc02034bc:	679c                	ld	a5,8(a5)
ffffffffc02034be:	4501                	li	a0,0
    prev->next = next;
ffffffffc02034c0:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc02034c2:	e398                	sd	a4,0(a5)
            *ptr_page = page;
ffffffffc02034c4:	00893023          	sd	s0,0(s2)
}
ffffffffc02034c8:	6442                	ld	s0,16(sp)
            curr_ptr = list_next(curr_ptr);
ffffffffc02034ca:	e09c                	sd	a5,0(s1)
}
ffffffffc02034cc:	6902                	ld	s2,0(sp)
ffffffffc02034ce:	64a2                	ld	s1,8(sp)
ffffffffc02034d0:	6105                	addi	sp,sp,32
ffffffffc02034d2:	8082                	ret
    assert(head != NULL);
ffffffffc02034d4:	00002697          	auipc	a3,0x2
ffffffffc02034d8:	7dc68693          	addi	a3,a3,2012 # ffffffffc0205cb0 <default_pmm_manager+0xaa8>
ffffffffc02034dc:	00002617          	auipc	a2,0x2
ffffffffc02034e0:	97c60613          	addi	a2,a2,-1668 # ffffffffc0204e58 <commands+0x788>
ffffffffc02034e4:	04800593          	li	a1,72
ffffffffc02034e8:	00002517          	auipc	a0,0x2
ffffffffc02034ec:	74050513          	addi	a0,a0,1856 # ffffffffc0205c28 <default_pmm_manager+0xa20>
ffffffffc02034f0:	e85fc0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(in_tick==0);
ffffffffc02034f4:	00002697          	auipc	a3,0x2
ffffffffc02034f8:	7cc68693          	addi	a3,a3,1996 # ffffffffc0205cc0 <default_pmm_manager+0xab8>
ffffffffc02034fc:	00002617          	auipc	a2,0x2
ffffffffc0203500:	95c60613          	addi	a2,a2,-1700 # ffffffffc0204e58 <commands+0x788>
ffffffffc0203504:	04900593          	li	a1,73
ffffffffc0203508:	00002517          	auipc	a0,0x2
ffffffffc020350c:	72050513          	addi	a0,a0,1824 # ffffffffc0205c28 <default_pmm_manager+0xa20>
ffffffffc0203510:	e65fc0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc0203514 <check_vma_overlap.part.0>:
}


// check_vma_overlap - check if vma1 overlaps vma2 ?
static inline void
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
ffffffffc0203514:	1141                	addi	sp,sp,-16
    assert(prev->vm_start < prev->vm_end);
    assert(prev->vm_end <= next->vm_start);
    assert(next->vm_start < next->vm_end);
ffffffffc0203516:	00002697          	auipc	a3,0x2
ffffffffc020351a:	7e268693          	addi	a3,a3,2018 # ffffffffc0205cf8 <default_pmm_manager+0xaf0>
ffffffffc020351e:	00002617          	auipc	a2,0x2
ffffffffc0203522:	93a60613          	addi	a2,a2,-1734 # ffffffffc0204e58 <commands+0x788>
ffffffffc0203526:	07d00593          	li	a1,125
ffffffffc020352a:	00002517          	auipc	a0,0x2
ffffffffc020352e:	7ee50513          	addi	a0,a0,2030 # ffffffffc0205d18 <default_pmm_manager+0xb10>
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
ffffffffc0203532:	e406                	sd	ra,8(sp)
    assert(next->vm_start < next->vm_end);
ffffffffc0203534:	e41fc0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc0203538 <mm_create>:
mm_create(void) {
ffffffffc0203538:	1141                	addi	sp,sp,-16
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc020353a:	03000513          	li	a0,48
mm_create(void) {
ffffffffc020353e:	e022                	sd	s0,0(sp)
ffffffffc0203540:	e406                	sd	ra,8(sp)
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc0203542:	a96ff0ef          	jal	ra,ffffffffc02027d8 <kmalloc>
ffffffffc0203546:	842a                	mv	s0,a0
    if (mm != NULL) {
ffffffffc0203548:	c105                	beqz	a0,ffffffffc0203568 <mm_create+0x30>
    elm->prev = elm->next = elm;
ffffffffc020354a:	e408                	sd	a0,8(s0)
ffffffffc020354c:	e008                	sd	a0,0(s0)
        mm->mmap_cache = NULL;
ffffffffc020354e:	00053823          	sd	zero,16(a0)
        mm->pgdir = NULL;
ffffffffc0203552:	00053c23          	sd	zero,24(a0)
        mm->map_count = 0;
ffffffffc0203556:	02052023          	sw	zero,32(a0)
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc020355a:	0000e797          	auipc	a5,0xe
ffffffffc020355e:	ffe7a783          	lw	a5,-2(a5) # ffffffffc0211558 <swap_init_ok>
ffffffffc0203562:	eb81                	bnez	a5,ffffffffc0203572 <mm_create+0x3a>
        else mm->sm_priv = NULL;
ffffffffc0203564:	02053423          	sd	zero,40(a0)
}
ffffffffc0203568:	60a2                	ld	ra,8(sp)
ffffffffc020356a:	8522                	mv	a0,s0
ffffffffc020356c:	6402                	ld	s0,0(sp)
ffffffffc020356e:	0141                	addi	sp,sp,16
ffffffffc0203570:	8082                	ret
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc0203572:	a73ff0ef          	jal	ra,ffffffffc0202fe4 <swap_init_mm>
}
ffffffffc0203576:	60a2                	ld	ra,8(sp)
ffffffffc0203578:	8522                	mv	a0,s0
ffffffffc020357a:	6402                	ld	s0,0(sp)
ffffffffc020357c:	0141                	addi	sp,sp,16
ffffffffc020357e:	8082                	ret

ffffffffc0203580 <vma_create>:
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint_t vm_flags) {
ffffffffc0203580:	1101                	addi	sp,sp,-32
ffffffffc0203582:	e04a                	sd	s2,0(sp)
ffffffffc0203584:	892a                	mv	s2,a0
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0203586:	03000513          	li	a0,48
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint_t vm_flags) {
ffffffffc020358a:	e822                	sd	s0,16(sp)
ffffffffc020358c:	e426                	sd	s1,8(sp)
ffffffffc020358e:	ec06                	sd	ra,24(sp)
ffffffffc0203590:	84ae                	mv	s1,a1
ffffffffc0203592:	8432                	mv	s0,a2
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0203594:	a44ff0ef          	jal	ra,ffffffffc02027d8 <kmalloc>
    if (vma != NULL) {
ffffffffc0203598:	c509                	beqz	a0,ffffffffc02035a2 <vma_create+0x22>
        vma->vm_start = vm_start;
ffffffffc020359a:	01253423          	sd	s2,8(a0)
        vma->vm_end = vm_end;
ffffffffc020359e:	e904                	sd	s1,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc02035a0:	ed00                	sd	s0,24(a0)
}
ffffffffc02035a2:	60e2                	ld	ra,24(sp)
ffffffffc02035a4:	6442                	ld	s0,16(sp)
ffffffffc02035a6:	64a2                	ld	s1,8(sp)
ffffffffc02035a8:	6902                	ld	s2,0(sp)
ffffffffc02035aa:	6105                	addi	sp,sp,32
ffffffffc02035ac:	8082                	ret

ffffffffc02035ae <find_vma>:
find_vma(struct mm_struct *mm, uintptr_t addr) {
ffffffffc02035ae:	86aa                	mv	a3,a0
    if (mm != NULL) {
ffffffffc02035b0:	c505                	beqz	a0,ffffffffc02035d8 <find_vma+0x2a>
        vma = mm->mmap_cache;
ffffffffc02035b2:	6908                	ld	a0,16(a0)
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
ffffffffc02035b4:	c501                	beqz	a0,ffffffffc02035bc <find_vma+0xe>
ffffffffc02035b6:	651c                	ld	a5,8(a0)
ffffffffc02035b8:	02f5f263          	bgeu	a1,a5,ffffffffc02035dc <find_vma+0x2e>
    return listelm->next;
ffffffffc02035bc:	669c                	ld	a5,8(a3)
                while ((le = list_next(le)) != list) {
ffffffffc02035be:	00f68d63          	beq	a3,a5,ffffffffc02035d8 <find_vma+0x2a>
                    if (vma->vm_start<=addr && addr < vma->vm_end) {
ffffffffc02035c2:	fe87b703          	ld	a4,-24(a5)
ffffffffc02035c6:	00e5e663          	bltu	a1,a4,ffffffffc02035d2 <find_vma+0x24>
ffffffffc02035ca:	ff07b703          	ld	a4,-16(a5)
ffffffffc02035ce:	00e5ec63          	bltu	a1,a4,ffffffffc02035e6 <find_vma+0x38>
ffffffffc02035d2:	679c                	ld	a5,8(a5)
                while ((le = list_next(le)) != list) {
ffffffffc02035d4:	fef697e3          	bne	a3,a5,ffffffffc02035c2 <find_vma+0x14>
    struct vma_struct *vma = NULL;
ffffffffc02035d8:	4501                	li	a0,0
}
ffffffffc02035da:	8082                	ret
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
ffffffffc02035dc:	691c                	ld	a5,16(a0)
ffffffffc02035de:	fcf5ffe3          	bgeu	a1,a5,ffffffffc02035bc <find_vma+0xe>
            mm->mmap_cache = vma;
ffffffffc02035e2:	ea88                	sd	a0,16(a3)
ffffffffc02035e4:	8082                	ret
                    vma = le2vma(le, list_link);
ffffffffc02035e6:	fe078513          	addi	a0,a5,-32
            mm->mmap_cache = vma;
ffffffffc02035ea:	ea88                	sd	a0,16(a3)
ffffffffc02035ec:	8082                	ret

ffffffffc02035ee <insert_vma_struct>:


// insert_vma_struct -insert vma in mm's list link
void
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
    assert(vma->vm_start < vma->vm_end);
ffffffffc02035ee:	6590                	ld	a2,8(a1)
ffffffffc02035f0:	0105b803          	ld	a6,16(a1) # 1010 <kern_entry-0xffffffffc01feff0>
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
ffffffffc02035f4:	1141                	addi	sp,sp,-16
ffffffffc02035f6:	e406                	sd	ra,8(sp)
ffffffffc02035f8:	87aa                	mv	a5,a0
    assert(vma->vm_start < vma->vm_end);
ffffffffc02035fa:	01066763          	bltu	a2,a6,ffffffffc0203608 <insert_vma_struct+0x1a>
ffffffffc02035fe:	a085                	j	ffffffffc020365e <insert_vma_struct+0x70>
    list_entry_t *le_prev = list, *le_next;

        list_entry_t *le = list;
        while ((le = list_next(le)) != list) {
            struct vma_struct *mmap_prev = le2vma(le, list_link);
            if (mmap_prev->vm_start > vma->vm_start) {
ffffffffc0203600:	fe87b703          	ld	a4,-24(a5)
ffffffffc0203604:	04e66863          	bltu	a2,a4,ffffffffc0203654 <insert_vma_struct+0x66>
ffffffffc0203608:	86be                	mv	a3,a5
ffffffffc020360a:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list) {
ffffffffc020360c:	fef51ae3          	bne	a0,a5,ffffffffc0203600 <insert_vma_struct+0x12>
        }

    le_next = list_next(le_prev);

    /* check overlap */
    if (le_prev != list) {
ffffffffc0203610:	02a68463          	beq	a3,a0,ffffffffc0203638 <insert_vma_struct+0x4a>
        check_vma_overlap(le2vma(le_prev, list_link), vma);
ffffffffc0203614:	ff06b703          	ld	a4,-16(a3)
    assert(prev->vm_start < prev->vm_end);
ffffffffc0203618:	fe86b883          	ld	a7,-24(a3)
ffffffffc020361c:	08e8f163          	bgeu	a7,a4,ffffffffc020369e <insert_vma_struct+0xb0>
    assert(prev->vm_end <= next->vm_start);
ffffffffc0203620:	04e66f63          	bltu	a2,a4,ffffffffc020367e <insert_vma_struct+0x90>
    }
    if (le_next != list) {
ffffffffc0203624:	00f50a63          	beq	a0,a5,ffffffffc0203638 <insert_vma_struct+0x4a>
            if (mmap_prev->vm_start > vma->vm_start) {
ffffffffc0203628:	fe87b703          	ld	a4,-24(a5)
    assert(prev->vm_end <= next->vm_start);
ffffffffc020362c:	05076963          	bltu	a4,a6,ffffffffc020367e <insert_vma_struct+0x90>
    assert(next->vm_start < next->vm_end);
ffffffffc0203630:	ff07b603          	ld	a2,-16(a5)
ffffffffc0203634:	02c77363          	bgeu	a4,a2,ffffffffc020365a <insert_vma_struct+0x6c>
    }

    vma->vm_mm = mm;
    list_add_after(le_prev, &(vma->list_link));

    mm->map_count ++;
ffffffffc0203638:	5118                	lw	a4,32(a0)
    vma->vm_mm = mm;
ffffffffc020363a:	e188                	sd	a0,0(a1)
    list_add_after(le_prev, &(vma->list_link));
ffffffffc020363c:	02058613          	addi	a2,a1,32
    prev->next = next->prev = elm;
ffffffffc0203640:	e390                	sd	a2,0(a5)
ffffffffc0203642:	e690                	sd	a2,8(a3)
}
ffffffffc0203644:	60a2                	ld	ra,8(sp)
    elm->next = next;
ffffffffc0203646:	f59c                	sd	a5,40(a1)
    elm->prev = prev;
ffffffffc0203648:	f194                	sd	a3,32(a1)
    mm->map_count ++;
ffffffffc020364a:	0017079b          	addiw	a5,a4,1
ffffffffc020364e:	d11c                	sw	a5,32(a0)
}
ffffffffc0203650:	0141                	addi	sp,sp,16
ffffffffc0203652:	8082                	ret
    if (le_prev != list) {
ffffffffc0203654:	fca690e3          	bne	a3,a0,ffffffffc0203614 <insert_vma_struct+0x26>
ffffffffc0203658:	bfd1                	j	ffffffffc020362c <insert_vma_struct+0x3e>
ffffffffc020365a:	ebbff0ef          	jal	ra,ffffffffc0203514 <check_vma_overlap.part.0>
    assert(vma->vm_start < vma->vm_end);
ffffffffc020365e:	00002697          	auipc	a3,0x2
ffffffffc0203662:	6ca68693          	addi	a3,a3,1738 # ffffffffc0205d28 <default_pmm_manager+0xb20>
ffffffffc0203666:	00001617          	auipc	a2,0x1
ffffffffc020366a:	7f260613          	addi	a2,a2,2034 # ffffffffc0204e58 <commands+0x788>
ffffffffc020366e:	08400593          	li	a1,132
ffffffffc0203672:	00002517          	auipc	a0,0x2
ffffffffc0203676:	6a650513          	addi	a0,a0,1702 # ffffffffc0205d18 <default_pmm_manager+0xb10>
ffffffffc020367a:	cfbfc0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(prev->vm_end <= next->vm_start);
ffffffffc020367e:	00002697          	auipc	a3,0x2
ffffffffc0203682:	6ea68693          	addi	a3,a3,1770 # ffffffffc0205d68 <default_pmm_manager+0xb60>
ffffffffc0203686:	00001617          	auipc	a2,0x1
ffffffffc020368a:	7d260613          	addi	a2,a2,2002 # ffffffffc0204e58 <commands+0x788>
ffffffffc020368e:	07c00593          	li	a1,124
ffffffffc0203692:	00002517          	auipc	a0,0x2
ffffffffc0203696:	68650513          	addi	a0,a0,1670 # ffffffffc0205d18 <default_pmm_manager+0xb10>
ffffffffc020369a:	cdbfc0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(prev->vm_start < prev->vm_end);
ffffffffc020369e:	00002697          	auipc	a3,0x2
ffffffffc02036a2:	6aa68693          	addi	a3,a3,1706 # ffffffffc0205d48 <default_pmm_manager+0xb40>
ffffffffc02036a6:	00001617          	auipc	a2,0x1
ffffffffc02036aa:	7b260613          	addi	a2,a2,1970 # ffffffffc0204e58 <commands+0x788>
ffffffffc02036ae:	07b00593          	li	a1,123
ffffffffc02036b2:	00002517          	auipc	a0,0x2
ffffffffc02036b6:	66650513          	addi	a0,a0,1638 # ffffffffc0205d18 <default_pmm_manager+0xb10>
ffffffffc02036ba:	cbbfc0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc02036be <mm_destroy>:

// mm_destroy - free mm and mm internal fields
void
mm_destroy(struct mm_struct *mm) {
ffffffffc02036be:	1141                	addi	sp,sp,-16
ffffffffc02036c0:	e022                	sd	s0,0(sp)
ffffffffc02036c2:	842a                	mv	s0,a0
    return listelm->next;
ffffffffc02036c4:	6508                	ld	a0,8(a0)
ffffffffc02036c6:	e406                	sd	ra,8(sp)

    list_entry_t *list = &(mm->mmap_list), *le;
    while ((le = list_next(list)) != list) {
ffffffffc02036c8:	00a40e63          	beq	s0,a0,ffffffffc02036e4 <mm_destroy+0x26>
    __list_del(listelm->prev, listelm->next);
ffffffffc02036cc:	6118                	ld	a4,0(a0)
ffffffffc02036ce:	651c                	ld	a5,8(a0)
        list_del(le);
        kfree(le2vma(le, list_link),sizeof(struct vma_struct));  //kfree vma        
ffffffffc02036d0:	03000593          	li	a1,48
ffffffffc02036d4:	1501                	addi	a0,a0,-32
    prev->next = next;
ffffffffc02036d6:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc02036d8:	e398                	sd	a4,0(a5)
ffffffffc02036da:	9b8ff0ef          	jal	ra,ffffffffc0202892 <kfree>
    return listelm->next;
ffffffffc02036de:	6408                	ld	a0,8(s0)
    while ((le = list_next(list)) != list) {
ffffffffc02036e0:	fea416e3          	bne	s0,a0,ffffffffc02036cc <mm_destroy+0xe>
    }
    kfree(mm, sizeof(struct mm_struct)); //kfree mm
ffffffffc02036e4:	8522                	mv	a0,s0
    mm=NULL;
}
ffffffffc02036e6:	6402                	ld	s0,0(sp)
ffffffffc02036e8:	60a2                	ld	ra,8(sp)
    kfree(mm, sizeof(struct mm_struct)); //kfree mm
ffffffffc02036ea:	03000593          	li	a1,48
}
ffffffffc02036ee:	0141                	addi	sp,sp,16
    kfree(mm, sizeof(struct mm_struct)); //kfree mm
ffffffffc02036f0:	9a2ff06f          	j	ffffffffc0202892 <kfree>

ffffffffc02036f4 <vmm_init>:

// vmm_init - initialize virtual memory management
//          - now just call check_vmm to check correctness of vmm
void
vmm_init(void) {
ffffffffc02036f4:	715d                	addi	sp,sp,-80
ffffffffc02036f6:	e486                	sd	ra,72(sp)
ffffffffc02036f8:	f44e                	sd	s3,40(sp)
ffffffffc02036fa:	f052                	sd	s4,32(sp)
ffffffffc02036fc:	e0a2                	sd	s0,64(sp)
ffffffffc02036fe:	fc26                	sd	s1,56(sp)
ffffffffc0203700:	f84a                	sd	s2,48(sp)
ffffffffc0203702:	ec56                	sd	s5,24(sp)
ffffffffc0203704:	e85a                	sd	s6,16(sp)
ffffffffc0203706:	e45e                	sd	s7,8(sp)
}

// check_vmm - check correctness of vmm
static void
check_vmm(void) {
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc0203708:	febfd0ef          	jal	ra,ffffffffc02016f2 <nr_free_pages>
ffffffffc020370c:	89aa                	mv	s3,a0
    cprintf("check_vmm() succeeded.\n");
}

static void
check_vma_struct(void) {
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc020370e:	fe5fd0ef          	jal	ra,ffffffffc02016f2 <nr_free_pages>
ffffffffc0203712:	8a2a                	mv	s4,a0
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc0203714:	03000513          	li	a0,48
ffffffffc0203718:	8c0ff0ef          	jal	ra,ffffffffc02027d8 <kmalloc>
    if (mm != NULL) {
ffffffffc020371c:	56050863          	beqz	a0,ffffffffc0203c8c <vmm_init+0x598>
    elm->prev = elm->next = elm;
ffffffffc0203720:	e508                	sd	a0,8(a0)
ffffffffc0203722:	e108                	sd	a0,0(a0)
        mm->mmap_cache = NULL;
ffffffffc0203724:	00053823          	sd	zero,16(a0)
        mm->pgdir = NULL;
ffffffffc0203728:	00053c23          	sd	zero,24(a0)
        mm->map_count = 0;
ffffffffc020372c:	02052023          	sw	zero,32(a0)
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc0203730:	0000e797          	auipc	a5,0xe
ffffffffc0203734:	e287a783          	lw	a5,-472(a5) # ffffffffc0211558 <swap_init_ok>
ffffffffc0203738:	84aa                	mv	s1,a0
ffffffffc020373a:	e7b9                	bnez	a5,ffffffffc0203788 <vmm_init+0x94>
        else mm->sm_priv = NULL;
ffffffffc020373c:	02053423          	sd	zero,40(a0)
vmm_init(void) {
ffffffffc0203740:	03200413          	li	s0,50
ffffffffc0203744:	a811                	j	ffffffffc0203758 <vmm_init+0x64>
        vma->vm_start = vm_start;
ffffffffc0203746:	e500                	sd	s0,8(a0)
        vma->vm_end = vm_end;
ffffffffc0203748:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc020374a:	00053c23          	sd	zero,24(a0)
    assert(mm != NULL);

    int step1 = 10, step2 = step1 * 10;

    int i;
    for (i = step1; i >= 1; i --) {
ffffffffc020374e:	146d                	addi	s0,s0,-5
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc0203750:	8526                	mv	a0,s1
ffffffffc0203752:	e9dff0ef          	jal	ra,ffffffffc02035ee <insert_vma_struct>
    for (i = step1; i >= 1; i --) {
ffffffffc0203756:	cc05                	beqz	s0,ffffffffc020378e <vmm_init+0x9a>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0203758:	03000513          	li	a0,48
ffffffffc020375c:	87cff0ef          	jal	ra,ffffffffc02027d8 <kmalloc>
ffffffffc0203760:	85aa                	mv	a1,a0
ffffffffc0203762:	00240793          	addi	a5,s0,2
    if (vma != NULL) {
ffffffffc0203766:	f165                	bnez	a0,ffffffffc0203746 <vmm_init+0x52>
        assert(vma != NULL);
ffffffffc0203768:	00002697          	auipc	a3,0x2
ffffffffc020376c:	1d068693          	addi	a3,a3,464 # ffffffffc0205938 <default_pmm_manager+0x730>
ffffffffc0203770:	00001617          	auipc	a2,0x1
ffffffffc0203774:	6e860613          	addi	a2,a2,1768 # ffffffffc0204e58 <commands+0x788>
ffffffffc0203778:	0ce00593          	li	a1,206
ffffffffc020377c:	00002517          	auipc	a0,0x2
ffffffffc0203780:	59c50513          	addi	a0,a0,1436 # ffffffffc0205d18 <default_pmm_manager+0xb10>
ffffffffc0203784:	bf1fc0ef          	jal	ra,ffffffffc0200374 <__panic>
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc0203788:	85dff0ef          	jal	ra,ffffffffc0202fe4 <swap_init_mm>
ffffffffc020378c:	bf55                	j	ffffffffc0203740 <vmm_init+0x4c>
ffffffffc020378e:	03700413          	li	s0,55
    }

    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc0203792:	1f900913          	li	s2,505
ffffffffc0203796:	a819                	j	ffffffffc02037ac <vmm_init+0xb8>
        vma->vm_start = vm_start;
ffffffffc0203798:	e500                	sd	s0,8(a0)
        vma->vm_end = vm_end;
ffffffffc020379a:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc020379c:	00053c23          	sd	zero,24(a0)
    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc02037a0:	0415                	addi	s0,s0,5
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc02037a2:	8526                	mv	a0,s1
ffffffffc02037a4:	e4bff0ef          	jal	ra,ffffffffc02035ee <insert_vma_struct>
    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc02037a8:	03240a63          	beq	s0,s2,ffffffffc02037dc <vmm_init+0xe8>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc02037ac:	03000513          	li	a0,48
ffffffffc02037b0:	828ff0ef          	jal	ra,ffffffffc02027d8 <kmalloc>
ffffffffc02037b4:	85aa                	mv	a1,a0
ffffffffc02037b6:	00240793          	addi	a5,s0,2
    if (vma != NULL) {
ffffffffc02037ba:	fd79                	bnez	a0,ffffffffc0203798 <vmm_init+0xa4>
        assert(vma != NULL);
ffffffffc02037bc:	00002697          	auipc	a3,0x2
ffffffffc02037c0:	17c68693          	addi	a3,a3,380 # ffffffffc0205938 <default_pmm_manager+0x730>
ffffffffc02037c4:	00001617          	auipc	a2,0x1
ffffffffc02037c8:	69460613          	addi	a2,a2,1684 # ffffffffc0204e58 <commands+0x788>
ffffffffc02037cc:	0d400593          	li	a1,212
ffffffffc02037d0:	00002517          	auipc	a0,0x2
ffffffffc02037d4:	54850513          	addi	a0,a0,1352 # ffffffffc0205d18 <default_pmm_manager+0xb10>
ffffffffc02037d8:	b9dfc0ef          	jal	ra,ffffffffc0200374 <__panic>
    return listelm->next;
ffffffffc02037dc:	649c                	ld	a5,8(s1)
ffffffffc02037de:	471d                	li	a4,7
    }

    list_entry_t *le = list_next(&(mm->mmap_list));

    for (i = 1; i <= step2; i ++) {
ffffffffc02037e0:	1fb00593          	li	a1,507
        assert(le != &(mm->mmap_list));
ffffffffc02037e4:	2ef48463          	beq	s1,a5,ffffffffc0203acc <vmm_init+0x3d8>
        struct vma_struct *mmap = le2vma(le, list_link);
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc02037e8:	fe87b603          	ld	a2,-24(a5)
ffffffffc02037ec:	ffe70693          	addi	a3,a4,-2
ffffffffc02037f0:	26d61e63          	bne	a2,a3,ffffffffc0203a6c <vmm_init+0x378>
ffffffffc02037f4:	ff07b683          	ld	a3,-16(a5)
ffffffffc02037f8:	26e69a63          	bne	a3,a4,ffffffffc0203a6c <vmm_init+0x378>
    for (i = 1; i <= step2; i ++) {
ffffffffc02037fc:	0715                	addi	a4,a4,5
ffffffffc02037fe:	679c                	ld	a5,8(a5)
ffffffffc0203800:	feb712e3          	bne	a4,a1,ffffffffc02037e4 <vmm_init+0xf0>
ffffffffc0203804:	4b1d                	li	s6,7
ffffffffc0203806:	4415                	li	s0,5
        le = list_next(le);
    }

    for (i = 5; i <= 5 * step2; i +=5) {
ffffffffc0203808:	1f900b93          	li	s7,505
        struct vma_struct *vma1 = find_vma(mm, i);
ffffffffc020380c:	85a2                	mv	a1,s0
ffffffffc020380e:	8526                	mv	a0,s1
ffffffffc0203810:	d9fff0ef          	jal	ra,ffffffffc02035ae <find_vma>
ffffffffc0203814:	892a                	mv	s2,a0
        assert(vma1 != NULL);
ffffffffc0203816:	2c050b63          	beqz	a0,ffffffffc0203aec <vmm_init+0x3f8>
        struct vma_struct *vma2 = find_vma(mm, i+1);
ffffffffc020381a:	00140593          	addi	a1,s0,1
ffffffffc020381e:	8526                	mv	a0,s1
ffffffffc0203820:	d8fff0ef          	jal	ra,ffffffffc02035ae <find_vma>
ffffffffc0203824:	8aaa                	mv	s5,a0
        assert(vma2 != NULL);
ffffffffc0203826:	2e050363          	beqz	a0,ffffffffc0203b0c <vmm_init+0x418>
        struct vma_struct *vma3 = find_vma(mm, i+2);
ffffffffc020382a:	85da                	mv	a1,s6
ffffffffc020382c:	8526                	mv	a0,s1
ffffffffc020382e:	d81ff0ef          	jal	ra,ffffffffc02035ae <find_vma>
        assert(vma3 == NULL);
ffffffffc0203832:	2e051d63          	bnez	a0,ffffffffc0203b2c <vmm_init+0x438>
        struct vma_struct *vma4 = find_vma(mm, i+3);
ffffffffc0203836:	00340593          	addi	a1,s0,3
ffffffffc020383a:	8526                	mv	a0,s1
ffffffffc020383c:	d73ff0ef          	jal	ra,ffffffffc02035ae <find_vma>
        assert(vma4 == NULL);
ffffffffc0203840:	30051663          	bnez	a0,ffffffffc0203b4c <vmm_init+0x458>
        struct vma_struct *vma5 = find_vma(mm, i+4);
ffffffffc0203844:	00440593          	addi	a1,s0,4
ffffffffc0203848:	8526                	mv	a0,s1
ffffffffc020384a:	d65ff0ef          	jal	ra,ffffffffc02035ae <find_vma>
        assert(vma5 == NULL);
ffffffffc020384e:	30051f63          	bnez	a0,ffffffffc0203b6c <vmm_init+0x478>

        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
ffffffffc0203852:	00893783          	ld	a5,8(s2)
ffffffffc0203856:	24879b63          	bne	a5,s0,ffffffffc0203aac <vmm_init+0x3b8>
ffffffffc020385a:	01093783          	ld	a5,16(s2)
ffffffffc020385e:	25679763          	bne	a5,s6,ffffffffc0203aac <vmm_init+0x3b8>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
ffffffffc0203862:	008ab783          	ld	a5,8(s5)
ffffffffc0203866:	22879363          	bne	a5,s0,ffffffffc0203a8c <vmm_init+0x398>
ffffffffc020386a:	010ab783          	ld	a5,16(s5)
ffffffffc020386e:	21679f63          	bne	a5,s6,ffffffffc0203a8c <vmm_init+0x398>
    for (i = 5; i <= 5 * step2; i +=5) {
ffffffffc0203872:	0415                	addi	s0,s0,5
ffffffffc0203874:	0b15                	addi	s6,s6,5
ffffffffc0203876:	f9741be3          	bne	s0,s7,ffffffffc020380c <vmm_init+0x118>
ffffffffc020387a:	4411                	li	s0,4
    }

    for (i =4; i>=0; i--) {
ffffffffc020387c:	597d                	li	s2,-1
        struct vma_struct *vma_below_5= find_vma(mm,i);
ffffffffc020387e:	85a2                	mv	a1,s0
ffffffffc0203880:	8526                	mv	a0,s1
ffffffffc0203882:	d2dff0ef          	jal	ra,ffffffffc02035ae <find_vma>
ffffffffc0203886:	0004059b          	sext.w	a1,s0
        if (vma_below_5 != NULL ) {
ffffffffc020388a:	c90d                	beqz	a0,ffffffffc02038bc <vmm_init+0x1c8>
           cprintf("vma_below_5: i %x, start %x, end %x\n",i, vma_below_5->vm_start, vma_below_5->vm_end); 
ffffffffc020388c:	6914                	ld	a3,16(a0)
ffffffffc020388e:	6510                	ld	a2,8(a0)
ffffffffc0203890:	00002517          	auipc	a0,0x2
ffffffffc0203894:	5f850513          	addi	a0,a0,1528 # ffffffffc0205e88 <default_pmm_manager+0xc80>
ffffffffc0203898:	823fc0ef          	jal	ra,ffffffffc02000ba <cprintf>
        }
        assert(vma_below_5 == NULL);
ffffffffc020389c:	00002697          	auipc	a3,0x2
ffffffffc02038a0:	61468693          	addi	a3,a3,1556 # ffffffffc0205eb0 <default_pmm_manager+0xca8>
ffffffffc02038a4:	00001617          	auipc	a2,0x1
ffffffffc02038a8:	5b460613          	addi	a2,a2,1460 # ffffffffc0204e58 <commands+0x788>
ffffffffc02038ac:	0f600593          	li	a1,246
ffffffffc02038b0:	00002517          	auipc	a0,0x2
ffffffffc02038b4:	46850513          	addi	a0,a0,1128 # ffffffffc0205d18 <default_pmm_manager+0xb10>
ffffffffc02038b8:	abdfc0ef          	jal	ra,ffffffffc0200374 <__panic>
    for (i =4; i>=0; i--) {
ffffffffc02038bc:	147d                	addi	s0,s0,-1
ffffffffc02038be:	fd2410e3          	bne	s0,s2,ffffffffc020387e <vmm_init+0x18a>
ffffffffc02038c2:	a811                	j	ffffffffc02038d6 <vmm_init+0x1e2>
    __list_del(listelm->prev, listelm->next);
ffffffffc02038c4:	6118                	ld	a4,0(a0)
ffffffffc02038c6:	651c                	ld	a5,8(a0)
        kfree(le2vma(le, list_link),sizeof(struct vma_struct));  //kfree vma        
ffffffffc02038c8:	03000593          	li	a1,48
ffffffffc02038cc:	1501                	addi	a0,a0,-32
    prev->next = next;
ffffffffc02038ce:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc02038d0:	e398                	sd	a4,0(a5)
ffffffffc02038d2:	fc1fe0ef          	jal	ra,ffffffffc0202892 <kfree>
    return listelm->next;
ffffffffc02038d6:	6488                	ld	a0,8(s1)
    while ((le = list_next(list)) != list) {
ffffffffc02038d8:	fea496e3          	bne	s1,a0,ffffffffc02038c4 <vmm_init+0x1d0>
    kfree(mm, sizeof(struct mm_struct)); //kfree mm
ffffffffc02038dc:	03000593          	li	a1,48
ffffffffc02038e0:	8526                	mv	a0,s1
ffffffffc02038e2:	fb1fe0ef          	jal	ra,ffffffffc0202892 <kfree>
    }

    mm_destroy(mm);

    assert(nr_free_pages_store == nr_free_pages());
ffffffffc02038e6:	e0dfd0ef          	jal	ra,ffffffffc02016f2 <nr_free_pages>
ffffffffc02038ea:	3caa1163          	bne	s4,a0,ffffffffc0203cac <vmm_init+0x5b8>

    cprintf("check_vma_struct() succeeded!\n");
ffffffffc02038ee:	00002517          	auipc	a0,0x2
ffffffffc02038f2:	60250513          	addi	a0,a0,1538 # ffffffffc0205ef0 <default_pmm_manager+0xce8>
ffffffffc02038f6:	fc4fc0ef          	jal	ra,ffffffffc02000ba <cprintf>

// check_pgfault - check correctness of pgfault handler
static void
check_pgfault(void) {
	// char *name = "check_pgfault";
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc02038fa:	df9fd0ef          	jal	ra,ffffffffc02016f2 <nr_free_pages>
ffffffffc02038fe:	84aa                	mv	s1,a0
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc0203900:	03000513          	li	a0,48
ffffffffc0203904:	ed5fe0ef          	jal	ra,ffffffffc02027d8 <kmalloc>
ffffffffc0203908:	842a                	mv	s0,a0
    if (mm != NULL) {
ffffffffc020390a:	2a050163          	beqz	a0,ffffffffc0203bac <vmm_init+0x4b8>
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc020390e:	0000e797          	auipc	a5,0xe
ffffffffc0203912:	c4a7a783          	lw	a5,-950(a5) # ffffffffc0211558 <swap_init_ok>
    elm->prev = elm->next = elm;
ffffffffc0203916:	e508                	sd	a0,8(a0)
ffffffffc0203918:	e108                	sd	a0,0(a0)
        mm->mmap_cache = NULL;
ffffffffc020391a:	00053823          	sd	zero,16(a0)
        mm->pgdir = NULL;
ffffffffc020391e:	00053c23          	sd	zero,24(a0)
        mm->map_count = 0;
ffffffffc0203922:	02052023          	sw	zero,32(a0)
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc0203926:	14079063          	bnez	a5,ffffffffc0203a66 <vmm_init+0x372>
        else mm->sm_priv = NULL;
ffffffffc020392a:	02053423          	sd	zero,40(a0)

    check_mm_struct = mm_create();

    assert(check_mm_struct != NULL);
    struct mm_struct *mm = check_mm_struct;
    pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc020392e:	0000e917          	auipc	s2,0xe
ffffffffc0203932:	bf293903          	ld	s2,-1038(s2) # ffffffffc0211520 <boot_pgdir>
    assert(pgdir[0] == 0);
ffffffffc0203936:	00093783          	ld	a5,0(s2)
    check_mm_struct = mm_create();
ffffffffc020393a:	0000e717          	auipc	a4,0xe
ffffffffc020393e:	c2873723          	sd	s0,-978(a4) # ffffffffc0211568 <check_mm_struct>
    pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0203942:	01243c23          	sd	s2,24(s0)
    assert(pgdir[0] == 0);
ffffffffc0203946:	24079363          	bnez	a5,ffffffffc0203b8c <vmm_init+0x498>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc020394a:	03000513          	li	a0,48
ffffffffc020394e:	e8bfe0ef          	jal	ra,ffffffffc02027d8 <kmalloc>
ffffffffc0203952:	8a2a                	mv	s4,a0
    if (vma != NULL) {
ffffffffc0203954:	28050063          	beqz	a0,ffffffffc0203bd4 <vmm_init+0x4e0>
        vma->vm_end = vm_end;
ffffffffc0203958:	002007b7          	lui	a5,0x200
ffffffffc020395c:	00fa3823          	sd	a5,16(s4)
        vma->vm_flags = vm_flags;
ffffffffc0203960:	4789                	li	a5,2

    struct vma_struct *vma = vma_create(0, PTSIZE, VM_WRITE);

    assert(vma != NULL);

    insert_vma_struct(mm, vma);
ffffffffc0203962:	85aa                	mv	a1,a0
        vma->vm_flags = vm_flags;
ffffffffc0203964:	00fa3c23          	sd	a5,24(s4)
    insert_vma_struct(mm, vma);
ffffffffc0203968:	8522                	mv	a0,s0
        vma->vm_start = vm_start;
ffffffffc020396a:	000a3423          	sd	zero,8(s4)
    insert_vma_struct(mm, vma);
ffffffffc020396e:	c81ff0ef          	jal	ra,ffffffffc02035ee <insert_vma_struct>

    uintptr_t addr = 0x100;
    assert(find_vma(mm, addr) == vma);
ffffffffc0203972:	10000593          	li	a1,256
ffffffffc0203976:	8522                	mv	a0,s0
ffffffffc0203978:	c37ff0ef          	jal	ra,ffffffffc02035ae <find_vma>
ffffffffc020397c:	10000793          	li	a5,256

    int i, sum = 0;
    for (i = 0; i < 100; i ++) {
ffffffffc0203980:	16400713          	li	a4,356
    assert(find_vma(mm, addr) == vma);
ffffffffc0203984:	26aa1863          	bne	s4,a0,ffffffffc0203bf4 <vmm_init+0x500>
        *(char *)(addr + i) = i;
ffffffffc0203988:	00f78023          	sb	a5,0(a5) # 200000 <kern_entry-0xffffffffc0000000>
    for (i = 0; i < 100; i ++) {
ffffffffc020398c:	0785                	addi	a5,a5,1
ffffffffc020398e:	fee79de3          	bne	a5,a4,ffffffffc0203988 <vmm_init+0x294>
        sum += i;
ffffffffc0203992:	6705                	lui	a4,0x1
ffffffffc0203994:	10000793          	li	a5,256
ffffffffc0203998:	35670713          	addi	a4,a4,854 # 1356 <kern_entry-0xffffffffc01fecaa>
    }
    for (i = 0; i < 100; i ++) {
ffffffffc020399c:	16400613          	li	a2,356
        sum -= *(char *)(addr + i);
ffffffffc02039a0:	0007c683          	lbu	a3,0(a5)
    for (i = 0; i < 100; i ++) {
ffffffffc02039a4:	0785                	addi	a5,a5,1
        sum -= *(char *)(addr + i);
ffffffffc02039a6:	9f15                	subw	a4,a4,a3
    for (i = 0; i < 100; i ++) {
ffffffffc02039a8:	fec79ce3          	bne	a5,a2,ffffffffc02039a0 <vmm_init+0x2ac>
    }
    assert(sum == 0);
ffffffffc02039ac:	26071463          	bnez	a4,ffffffffc0203c14 <vmm_init+0x520>

    page_remove(pgdir, ROUNDDOWN(addr, PGSIZE));
ffffffffc02039b0:	4581                	li	a1,0
ffffffffc02039b2:	854a                	mv	a0,s2
ffffffffc02039b4:	fc9fd0ef          	jal	ra,ffffffffc020197c <page_remove>
    return pa2page(PDE_ADDR(pde));
ffffffffc02039b8:	00093783          	ld	a5,0(s2)
    if (PPN(pa) >= npage) {
ffffffffc02039bc:	0000e717          	auipc	a4,0xe
ffffffffc02039c0:	b6c73703          	ld	a4,-1172(a4) # ffffffffc0211528 <npage>
    return pa2page(PDE_ADDR(pde));
ffffffffc02039c4:	078a                	slli	a5,a5,0x2
ffffffffc02039c6:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02039c8:	26e7f663          	bgeu	a5,a4,ffffffffc0203c34 <vmm_init+0x540>
    return &pages[PPN(pa) - nbase];
ffffffffc02039cc:	00003717          	auipc	a4,0x3
ffffffffc02039d0:	92c73703          	ld	a4,-1748(a4) # ffffffffc02062f8 <nbase>
ffffffffc02039d4:	8f99                	sub	a5,a5,a4
ffffffffc02039d6:	00379713          	slli	a4,a5,0x3
ffffffffc02039da:	97ba                	add	a5,a5,a4
ffffffffc02039dc:	078e                	slli	a5,a5,0x3

    free_page(pde2page(pgdir[0]));
ffffffffc02039de:	0000e517          	auipc	a0,0xe
ffffffffc02039e2:	b5253503          	ld	a0,-1198(a0) # ffffffffc0211530 <pages>
ffffffffc02039e6:	953e                	add	a0,a0,a5
ffffffffc02039e8:	4585                	li	a1,1
ffffffffc02039ea:	cc9fd0ef          	jal	ra,ffffffffc02016b2 <free_pages>
    return listelm->next;
ffffffffc02039ee:	6408                	ld	a0,8(s0)

    pgdir[0] = 0;
ffffffffc02039f0:	00093023          	sd	zero,0(s2)

    mm->pgdir = NULL;
ffffffffc02039f4:	00043c23          	sd	zero,24(s0)
    while ((le = list_next(list)) != list) {
ffffffffc02039f8:	00a40e63          	beq	s0,a0,ffffffffc0203a14 <vmm_init+0x320>
    __list_del(listelm->prev, listelm->next);
ffffffffc02039fc:	6118                	ld	a4,0(a0)
ffffffffc02039fe:	651c                	ld	a5,8(a0)
        kfree(le2vma(le, list_link),sizeof(struct vma_struct));  //kfree vma        
ffffffffc0203a00:	03000593          	li	a1,48
ffffffffc0203a04:	1501                	addi	a0,a0,-32
    prev->next = next;
ffffffffc0203a06:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0203a08:	e398                	sd	a4,0(a5)
ffffffffc0203a0a:	e89fe0ef          	jal	ra,ffffffffc0202892 <kfree>
    return listelm->next;
ffffffffc0203a0e:	6408                	ld	a0,8(s0)
    while ((le = list_next(list)) != list) {
ffffffffc0203a10:	fea416e3          	bne	s0,a0,ffffffffc02039fc <vmm_init+0x308>
    kfree(mm, sizeof(struct mm_struct)); //kfree mm
ffffffffc0203a14:	03000593          	li	a1,48
ffffffffc0203a18:	8522                	mv	a0,s0
ffffffffc0203a1a:	e79fe0ef          	jal	ra,ffffffffc0202892 <kfree>
    mm_destroy(mm);

    check_mm_struct = NULL;
    nr_free_pages_store--;	// szx : Sv39第二级页表多占了一个内存页，所以执行此操作
ffffffffc0203a1e:	14fd                	addi	s1,s1,-1
    check_mm_struct = NULL;
ffffffffc0203a20:	0000e797          	auipc	a5,0xe
ffffffffc0203a24:	b407b423          	sd	zero,-1208(a5) # ffffffffc0211568 <check_mm_struct>

    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0203a28:	ccbfd0ef          	jal	ra,ffffffffc02016f2 <nr_free_pages>
ffffffffc0203a2c:	22a49063          	bne	s1,a0,ffffffffc0203c4c <vmm_init+0x558>

    cprintf("check_pgfault() succeeded!\n");
ffffffffc0203a30:	00002517          	auipc	a0,0x2
ffffffffc0203a34:	51050513          	addi	a0,a0,1296 # ffffffffc0205f40 <default_pmm_manager+0xd38>
ffffffffc0203a38:	e82fc0ef          	jal	ra,ffffffffc02000ba <cprintf>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0203a3c:	cb7fd0ef          	jal	ra,ffffffffc02016f2 <nr_free_pages>
    nr_free_pages_store--;	// szx : Sv39三级页表多占一个内存页，所以执行此操作
ffffffffc0203a40:	19fd                	addi	s3,s3,-1
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0203a42:	22a99563          	bne	s3,a0,ffffffffc0203c6c <vmm_init+0x578>
}
ffffffffc0203a46:	6406                	ld	s0,64(sp)
ffffffffc0203a48:	60a6                	ld	ra,72(sp)
ffffffffc0203a4a:	74e2                	ld	s1,56(sp)
ffffffffc0203a4c:	7942                	ld	s2,48(sp)
ffffffffc0203a4e:	79a2                	ld	s3,40(sp)
ffffffffc0203a50:	7a02                	ld	s4,32(sp)
ffffffffc0203a52:	6ae2                	ld	s5,24(sp)
ffffffffc0203a54:	6b42                	ld	s6,16(sp)
ffffffffc0203a56:	6ba2                	ld	s7,8(sp)
    cprintf("check_vmm() succeeded.\n");
ffffffffc0203a58:	00002517          	auipc	a0,0x2
ffffffffc0203a5c:	50850513          	addi	a0,a0,1288 # ffffffffc0205f60 <default_pmm_manager+0xd58>
}
ffffffffc0203a60:	6161                	addi	sp,sp,80
    cprintf("check_vmm() succeeded.\n");
ffffffffc0203a62:	e58fc06f          	j	ffffffffc02000ba <cprintf>
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc0203a66:	d7eff0ef          	jal	ra,ffffffffc0202fe4 <swap_init_mm>
ffffffffc0203a6a:	b5d1                	j	ffffffffc020392e <vmm_init+0x23a>
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc0203a6c:	00002697          	auipc	a3,0x2
ffffffffc0203a70:	33468693          	addi	a3,a3,820 # ffffffffc0205da0 <default_pmm_manager+0xb98>
ffffffffc0203a74:	00001617          	auipc	a2,0x1
ffffffffc0203a78:	3e460613          	addi	a2,a2,996 # ffffffffc0204e58 <commands+0x788>
ffffffffc0203a7c:	0dd00593          	li	a1,221
ffffffffc0203a80:	00002517          	auipc	a0,0x2
ffffffffc0203a84:	29850513          	addi	a0,a0,664 # ffffffffc0205d18 <default_pmm_manager+0xb10>
ffffffffc0203a88:	8edfc0ef          	jal	ra,ffffffffc0200374 <__panic>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
ffffffffc0203a8c:	00002697          	auipc	a3,0x2
ffffffffc0203a90:	3cc68693          	addi	a3,a3,972 # ffffffffc0205e58 <default_pmm_manager+0xc50>
ffffffffc0203a94:	00001617          	auipc	a2,0x1
ffffffffc0203a98:	3c460613          	addi	a2,a2,964 # ffffffffc0204e58 <commands+0x788>
ffffffffc0203a9c:	0ee00593          	li	a1,238
ffffffffc0203aa0:	00002517          	auipc	a0,0x2
ffffffffc0203aa4:	27850513          	addi	a0,a0,632 # ffffffffc0205d18 <default_pmm_manager+0xb10>
ffffffffc0203aa8:	8cdfc0ef          	jal	ra,ffffffffc0200374 <__panic>
        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
ffffffffc0203aac:	00002697          	auipc	a3,0x2
ffffffffc0203ab0:	37c68693          	addi	a3,a3,892 # ffffffffc0205e28 <default_pmm_manager+0xc20>
ffffffffc0203ab4:	00001617          	auipc	a2,0x1
ffffffffc0203ab8:	3a460613          	addi	a2,a2,932 # ffffffffc0204e58 <commands+0x788>
ffffffffc0203abc:	0ed00593          	li	a1,237
ffffffffc0203ac0:	00002517          	auipc	a0,0x2
ffffffffc0203ac4:	25850513          	addi	a0,a0,600 # ffffffffc0205d18 <default_pmm_manager+0xb10>
ffffffffc0203ac8:	8adfc0ef          	jal	ra,ffffffffc0200374 <__panic>
        assert(le != &(mm->mmap_list));
ffffffffc0203acc:	00002697          	auipc	a3,0x2
ffffffffc0203ad0:	2bc68693          	addi	a3,a3,700 # ffffffffc0205d88 <default_pmm_manager+0xb80>
ffffffffc0203ad4:	00001617          	auipc	a2,0x1
ffffffffc0203ad8:	38460613          	addi	a2,a2,900 # ffffffffc0204e58 <commands+0x788>
ffffffffc0203adc:	0db00593          	li	a1,219
ffffffffc0203ae0:	00002517          	auipc	a0,0x2
ffffffffc0203ae4:	23850513          	addi	a0,a0,568 # ffffffffc0205d18 <default_pmm_manager+0xb10>
ffffffffc0203ae8:	88dfc0ef          	jal	ra,ffffffffc0200374 <__panic>
        assert(vma1 != NULL);
ffffffffc0203aec:	00002697          	auipc	a3,0x2
ffffffffc0203af0:	2ec68693          	addi	a3,a3,748 # ffffffffc0205dd8 <default_pmm_manager+0xbd0>
ffffffffc0203af4:	00001617          	auipc	a2,0x1
ffffffffc0203af8:	36460613          	addi	a2,a2,868 # ffffffffc0204e58 <commands+0x788>
ffffffffc0203afc:	0e300593          	li	a1,227
ffffffffc0203b00:	00002517          	auipc	a0,0x2
ffffffffc0203b04:	21850513          	addi	a0,a0,536 # ffffffffc0205d18 <default_pmm_manager+0xb10>
ffffffffc0203b08:	86dfc0ef          	jal	ra,ffffffffc0200374 <__panic>
        assert(vma2 != NULL);
ffffffffc0203b0c:	00002697          	auipc	a3,0x2
ffffffffc0203b10:	2dc68693          	addi	a3,a3,732 # ffffffffc0205de8 <default_pmm_manager+0xbe0>
ffffffffc0203b14:	00001617          	auipc	a2,0x1
ffffffffc0203b18:	34460613          	addi	a2,a2,836 # ffffffffc0204e58 <commands+0x788>
ffffffffc0203b1c:	0e500593          	li	a1,229
ffffffffc0203b20:	00002517          	auipc	a0,0x2
ffffffffc0203b24:	1f850513          	addi	a0,a0,504 # ffffffffc0205d18 <default_pmm_manager+0xb10>
ffffffffc0203b28:	84dfc0ef          	jal	ra,ffffffffc0200374 <__panic>
        assert(vma3 == NULL);
ffffffffc0203b2c:	00002697          	auipc	a3,0x2
ffffffffc0203b30:	2cc68693          	addi	a3,a3,716 # ffffffffc0205df8 <default_pmm_manager+0xbf0>
ffffffffc0203b34:	00001617          	auipc	a2,0x1
ffffffffc0203b38:	32460613          	addi	a2,a2,804 # ffffffffc0204e58 <commands+0x788>
ffffffffc0203b3c:	0e700593          	li	a1,231
ffffffffc0203b40:	00002517          	auipc	a0,0x2
ffffffffc0203b44:	1d850513          	addi	a0,a0,472 # ffffffffc0205d18 <default_pmm_manager+0xb10>
ffffffffc0203b48:	82dfc0ef          	jal	ra,ffffffffc0200374 <__panic>
        assert(vma4 == NULL);
ffffffffc0203b4c:	00002697          	auipc	a3,0x2
ffffffffc0203b50:	2bc68693          	addi	a3,a3,700 # ffffffffc0205e08 <default_pmm_manager+0xc00>
ffffffffc0203b54:	00001617          	auipc	a2,0x1
ffffffffc0203b58:	30460613          	addi	a2,a2,772 # ffffffffc0204e58 <commands+0x788>
ffffffffc0203b5c:	0e900593          	li	a1,233
ffffffffc0203b60:	00002517          	auipc	a0,0x2
ffffffffc0203b64:	1b850513          	addi	a0,a0,440 # ffffffffc0205d18 <default_pmm_manager+0xb10>
ffffffffc0203b68:	80dfc0ef          	jal	ra,ffffffffc0200374 <__panic>
        assert(vma5 == NULL);
ffffffffc0203b6c:	00002697          	auipc	a3,0x2
ffffffffc0203b70:	2ac68693          	addi	a3,a3,684 # ffffffffc0205e18 <default_pmm_manager+0xc10>
ffffffffc0203b74:	00001617          	auipc	a2,0x1
ffffffffc0203b78:	2e460613          	addi	a2,a2,740 # ffffffffc0204e58 <commands+0x788>
ffffffffc0203b7c:	0eb00593          	li	a1,235
ffffffffc0203b80:	00002517          	auipc	a0,0x2
ffffffffc0203b84:	19850513          	addi	a0,a0,408 # ffffffffc0205d18 <default_pmm_manager+0xb10>
ffffffffc0203b88:	fecfc0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(pgdir[0] == 0);
ffffffffc0203b8c:	00002697          	auipc	a3,0x2
ffffffffc0203b90:	d9c68693          	addi	a3,a3,-612 # ffffffffc0205928 <default_pmm_manager+0x720>
ffffffffc0203b94:	00001617          	auipc	a2,0x1
ffffffffc0203b98:	2c460613          	addi	a2,a2,708 # ffffffffc0204e58 <commands+0x788>
ffffffffc0203b9c:	10d00593          	li	a1,269
ffffffffc0203ba0:	00002517          	auipc	a0,0x2
ffffffffc0203ba4:	17850513          	addi	a0,a0,376 # ffffffffc0205d18 <default_pmm_manager+0xb10>
ffffffffc0203ba8:	fccfc0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(check_mm_struct != NULL);
ffffffffc0203bac:	00002697          	auipc	a3,0x2
ffffffffc0203bb0:	3cc68693          	addi	a3,a3,972 # ffffffffc0205f78 <default_pmm_manager+0xd70>
ffffffffc0203bb4:	00001617          	auipc	a2,0x1
ffffffffc0203bb8:	2a460613          	addi	a2,a2,676 # ffffffffc0204e58 <commands+0x788>
ffffffffc0203bbc:	10a00593          	li	a1,266
ffffffffc0203bc0:	00002517          	auipc	a0,0x2
ffffffffc0203bc4:	15850513          	addi	a0,a0,344 # ffffffffc0205d18 <default_pmm_manager+0xb10>
    check_mm_struct = mm_create();
ffffffffc0203bc8:	0000e797          	auipc	a5,0xe
ffffffffc0203bcc:	9a07b023          	sd	zero,-1632(a5) # ffffffffc0211568 <check_mm_struct>
    assert(check_mm_struct != NULL);
ffffffffc0203bd0:	fa4fc0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(vma != NULL);
ffffffffc0203bd4:	00002697          	auipc	a3,0x2
ffffffffc0203bd8:	d6468693          	addi	a3,a3,-668 # ffffffffc0205938 <default_pmm_manager+0x730>
ffffffffc0203bdc:	00001617          	auipc	a2,0x1
ffffffffc0203be0:	27c60613          	addi	a2,a2,636 # ffffffffc0204e58 <commands+0x788>
ffffffffc0203be4:	11100593          	li	a1,273
ffffffffc0203be8:	00002517          	auipc	a0,0x2
ffffffffc0203bec:	13050513          	addi	a0,a0,304 # ffffffffc0205d18 <default_pmm_manager+0xb10>
ffffffffc0203bf0:	f84fc0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(find_vma(mm, addr) == vma);
ffffffffc0203bf4:	00002697          	auipc	a3,0x2
ffffffffc0203bf8:	31c68693          	addi	a3,a3,796 # ffffffffc0205f10 <default_pmm_manager+0xd08>
ffffffffc0203bfc:	00001617          	auipc	a2,0x1
ffffffffc0203c00:	25c60613          	addi	a2,a2,604 # ffffffffc0204e58 <commands+0x788>
ffffffffc0203c04:	11600593          	li	a1,278
ffffffffc0203c08:	00002517          	auipc	a0,0x2
ffffffffc0203c0c:	11050513          	addi	a0,a0,272 # ffffffffc0205d18 <default_pmm_manager+0xb10>
ffffffffc0203c10:	f64fc0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(sum == 0);
ffffffffc0203c14:	00002697          	auipc	a3,0x2
ffffffffc0203c18:	31c68693          	addi	a3,a3,796 # ffffffffc0205f30 <default_pmm_manager+0xd28>
ffffffffc0203c1c:	00001617          	auipc	a2,0x1
ffffffffc0203c20:	23c60613          	addi	a2,a2,572 # ffffffffc0204e58 <commands+0x788>
ffffffffc0203c24:	12000593          	li	a1,288
ffffffffc0203c28:	00002517          	auipc	a0,0x2
ffffffffc0203c2c:	0f050513          	addi	a0,a0,240 # ffffffffc0205d18 <default_pmm_manager+0xb10>
ffffffffc0203c30:	f44fc0ef          	jal	ra,ffffffffc0200374 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0203c34:	00001617          	auipc	a2,0x1
ffffffffc0203c38:	60c60613          	addi	a2,a2,1548 # ffffffffc0205240 <default_pmm_manager+0x38>
ffffffffc0203c3c:	06500593          	li	a1,101
ffffffffc0203c40:	00001517          	auipc	a0,0x1
ffffffffc0203c44:	62050513          	addi	a0,a0,1568 # ffffffffc0205260 <default_pmm_manager+0x58>
ffffffffc0203c48:	f2cfc0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0203c4c:	00002697          	auipc	a3,0x2
ffffffffc0203c50:	27c68693          	addi	a3,a3,636 # ffffffffc0205ec8 <default_pmm_manager+0xcc0>
ffffffffc0203c54:	00001617          	auipc	a2,0x1
ffffffffc0203c58:	20460613          	addi	a2,a2,516 # ffffffffc0204e58 <commands+0x788>
ffffffffc0203c5c:	12e00593          	li	a1,302
ffffffffc0203c60:	00002517          	auipc	a0,0x2
ffffffffc0203c64:	0b850513          	addi	a0,a0,184 # ffffffffc0205d18 <default_pmm_manager+0xb10>
ffffffffc0203c68:	f0cfc0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0203c6c:	00002697          	auipc	a3,0x2
ffffffffc0203c70:	25c68693          	addi	a3,a3,604 # ffffffffc0205ec8 <default_pmm_manager+0xcc0>
ffffffffc0203c74:	00001617          	auipc	a2,0x1
ffffffffc0203c78:	1e460613          	addi	a2,a2,484 # ffffffffc0204e58 <commands+0x788>
ffffffffc0203c7c:	0bd00593          	li	a1,189
ffffffffc0203c80:	00002517          	auipc	a0,0x2
ffffffffc0203c84:	09850513          	addi	a0,a0,152 # ffffffffc0205d18 <default_pmm_manager+0xb10>
ffffffffc0203c88:	eecfc0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(mm != NULL);
ffffffffc0203c8c:	00002697          	auipc	a3,0x2
ffffffffc0203c90:	c7468693          	addi	a3,a3,-908 # ffffffffc0205900 <default_pmm_manager+0x6f8>
ffffffffc0203c94:	00001617          	auipc	a2,0x1
ffffffffc0203c98:	1c460613          	addi	a2,a2,452 # ffffffffc0204e58 <commands+0x788>
ffffffffc0203c9c:	0c700593          	li	a1,199
ffffffffc0203ca0:	00002517          	auipc	a0,0x2
ffffffffc0203ca4:	07850513          	addi	a0,a0,120 # ffffffffc0205d18 <default_pmm_manager+0xb10>
ffffffffc0203ca8:	eccfc0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0203cac:	00002697          	auipc	a3,0x2
ffffffffc0203cb0:	21c68693          	addi	a3,a3,540 # ffffffffc0205ec8 <default_pmm_manager+0xcc0>
ffffffffc0203cb4:	00001617          	auipc	a2,0x1
ffffffffc0203cb8:	1a460613          	addi	a2,a2,420 # ffffffffc0204e58 <commands+0x788>
ffffffffc0203cbc:	0fb00593          	li	a1,251
ffffffffc0203cc0:	00002517          	auipc	a0,0x2
ffffffffc0203cc4:	05850513          	addi	a0,a0,88 # ffffffffc0205d18 <default_pmm_manager+0xb10>
ffffffffc0203cc8:	eacfc0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc0203ccc <do_pgfault>:
 *            was a read (0) or write (1).
 *         -- The U/S flag (bit 2) indicates whether the processor was executing at user mode (1)
 *            or supervisor mode (0) at the time of the exception.
 */
int
do_pgfault(struct mm_struct *mm, uint_t error_code, uintptr_t addr) {
ffffffffc0203ccc:	7179                	addi	sp,sp,-48
    //addr: 访问出错的虚拟地址
    int ret = -E_INVAL;
    //try to find a vma which include addr
    struct vma_struct *vma = find_vma(mm, addr);
ffffffffc0203cce:	85b2                	mv	a1,a2
do_pgfault(struct mm_struct *mm, uint_t error_code, uintptr_t addr) {
ffffffffc0203cd0:	f022                	sd	s0,32(sp)
ffffffffc0203cd2:	ec26                	sd	s1,24(sp)
ffffffffc0203cd4:	f406                	sd	ra,40(sp)
ffffffffc0203cd6:	e84a                	sd	s2,16(sp)
ffffffffc0203cd8:	8432                	mv	s0,a2
ffffffffc0203cda:	84aa                	mv	s1,a0
    struct vma_struct *vma = find_vma(mm, addr);
ffffffffc0203cdc:	8d3ff0ef          	jal	ra,ffffffffc02035ae <find_vma>

    pgfault_num++;
ffffffffc0203ce0:	0000e797          	auipc	a5,0xe
ffffffffc0203ce4:	8907a783          	lw	a5,-1904(a5) # ffffffffc0211570 <pgfault_num>
ffffffffc0203ce8:	2785                	addiw	a5,a5,1
ffffffffc0203cea:	0000e717          	auipc	a4,0xe
ffffffffc0203cee:	88f72323          	sw	a5,-1914(a4) # ffffffffc0211570 <pgfault_num>
    //If the addr is in the range of a mm's vma?
    if (vma == NULL || vma->vm_start > addr) {
ffffffffc0203cf2:	c549                	beqz	a0,ffffffffc0203d7c <do_pgfault+0xb0>
ffffffffc0203cf4:	651c                	ld	a5,8(a0)
ffffffffc0203cf6:	08f46363          	bltu	s0,a5,ffffffffc0203d7c <do_pgfault+0xb0>
     *    (read  an non_existed addr && addr is readable)
     * THEN
     *    continue process
     */
    uint32_t perm = PTE_U;
    if (vma->vm_flags & VM_WRITE) {
ffffffffc0203cfa:	6d1c                	ld	a5,24(a0)
    uint32_t perm = PTE_U;
ffffffffc0203cfc:	4941                	li	s2,16
    if (vma->vm_flags & VM_WRITE) {
ffffffffc0203cfe:	8b89                	andi	a5,a5,2
ffffffffc0203d00:	efa9                	bnez	a5,ffffffffc0203d5a <do_pgfault+0x8e>
        perm |= (PTE_R | PTE_W);
    }
    addr = ROUNDDOWN(addr, PGSIZE);
ffffffffc0203d02:	75fd                	lui	a1,0xfffff
    *   mm->pgdir : the PDT of these vma
    *
    */


    ptep = get_pte(mm->pgdir, addr, 1);  //(1) try to find a pte, if pte's
ffffffffc0203d04:	6c88                	ld	a0,24(s1)
    addr = ROUNDDOWN(addr, PGSIZE);
ffffffffc0203d06:	8c6d                	and	s0,s0,a1
    ptep = get_pte(mm->pgdir, addr, 1);  //(1) try to find a pte, if pte's
ffffffffc0203d08:	85a2                	mv	a1,s0
ffffffffc0203d0a:	4605                	li	a2,1
ffffffffc0203d0c:	a21fd0ef          	jal	ra,ffffffffc020172c <get_pte>
                                         //PT(Page Table) isn't existed, then
                                         //create a PT.
    if (*ptep == 0) {
ffffffffc0203d10:	610c                	ld	a1,0(a0)
ffffffffc0203d12:	c5b1                	beqz	a1,ffffffffc0203d5e <do_pgfault+0x92>
        *    swap_in(mm, addr, &page) : 分配一个内存页，然后根据
        *    PTE中的swap条目的addr，找到磁盘页的地址，将磁盘页的内容读入这个内存页
        *    page_insert ： 建立一个Page的phy addr与线性addr la的映射
        *    swap_map_swappable ： 设置页面可交换
        */
        if (swap_init_ok) {
ffffffffc0203d14:	0000e797          	auipc	a5,0xe
ffffffffc0203d18:	8447a783          	lw	a5,-1980(a5) # ffffffffc0211558 <swap_init_ok>
ffffffffc0203d1c:	cbad                	beqz	a5,ffffffffc0203d8e <do_pgfault+0xc2>
            // 你要编写的内容在这里，请基于上文说明以及下文的英文注释完成代码编写
            //(1）According to the mm AND addr, try
            //to load the content of right disk page
            //into the memory which page managed.
            // (1) 根据 mm 和 addr，尝试将正确的磁盘页面内容加载到内存中
            if (swap_in(mm, addr, &page) != 0) {
ffffffffc0203d1e:	0030                	addi	a2,sp,8
ffffffffc0203d20:	85a2                	mv	a1,s0
ffffffffc0203d22:	8526                	mv	a0,s1
            struct Page *page = NULL;
ffffffffc0203d24:	e402                	sd	zero,8(sp)
            if (swap_in(mm, addr, &page) != 0) {
ffffffffc0203d26:	beaff0ef          	jal	ra,ffffffffc0203110 <swap_in>
ffffffffc0203d2a:	e935                	bnez	a0,ffffffffc0203d9e <do_pgfault+0xd2>
            //(2) According to the mm,
            //addr AND page, setup the
            //map of phy addr <--->
            //logical addr
            // (2) 根据 mm，addr 和 page，设置物理地址和逻辑地址的映射
            if (page_insert(mm->pgdir, page, addr, perm) != 0) {
ffffffffc0203d2c:	65a2                	ld	a1,8(sp)
ffffffffc0203d2e:	6c88                	ld	a0,24(s1)
ffffffffc0203d30:	86ca                	mv	a3,s2
ffffffffc0203d32:	8622                	mv	a2,s0
ffffffffc0203d34:	ce3fd0ef          	jal	ra,ffffffffc0201a16 <page_insert>
ffffffffc0203d38:	892a                	mv	s2,a0
ffffffffc0203d3a:	e93d                	bnez	a0,ffffffffc0203db0 <do_pgfault+0xe4>
                cprintf("page_insert failed for addr %x\n", addr);
                goto failed;
            }
            //(3) make the page swappable.
            // (3) 将页面标记为可交换
            swap_map_swappable(mm,addr,page,1);
ffffffffc0203d3c:	6622                	ld	a2,8(sp)
ffffffffc0203d3e:	4685                	li	a3,1
ffffffffc0203d40:	85a2                	mv	a1,s0
ffffffffc0203d42:	8526                	mv	a0,s1
ffffffffc0203d44:	aacff0ef          	jal	ra,ffffffffc0202ff0 <swap_map_swappable>
            
            page->pra_vaddr = addr;
ffffffffc0203d48:	67a2                	ld	a5,8(sp)
ffffffffc0203d4a:	e3a0                	sd	s0,64(a5)
   }

   ret = 0;
failed:
    return ret;
}
ffffffffc0203d4c:	70a2                	ld	ra,40(sp)
ffffffffc0203d4e:	7402                	ld	s0,32(sp)
ffffffffc0203d50:	64e2                	ld	s1,24(sp)
ffffffffc0203d52:	854a                	mv	a0,s2
ffffffffc0203d54:	6942                	ld	s2,16(sp)
ffffffffc0203d56:	6145                	addi	sp,sp,48
ffffffffc0203d58:	8082                	ret
        perm |= (PTE_R | PTE_W);
ffffffffc0203d5a:	4959                	li	s2,22
ffffffffc0203d5c:	b75d                	j	ffffffffc0203d02 <do_pgfault+0x36>
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
ffffffffc0203d5e:	6c88                	ld	a0,24(s1)
ffffffffc0203d60:	864a                	mv	a2,s2
ffffffffc0203d62:	85a2                	mv	a1,s0
ffffffffc0203d64:	9bdfe0ef          	jal	ra,ffffffffc0202720 <pgdir_alloc_page>
   ret = 0;
ffffffffc0203d68:	4901                	li	s2,0
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
ffffffffc0203d6a:	f16d                	bnez	a0,ffffffffc0203d4c <do_pgfault+0x80>
            cprintf("pgdir_alloc_page in do_pgfault failed\n");
ffffffffc0203d6c:	00002517          	auipc	a0,0x2
ffffffffc0203d70:	25450513          	addi	a0,a0,596 # ffffffffc0205fc0 <default_pmm_manager+0xdb8>
ffffffffc0203d74:	b46fc0ef          	jal	ra,ffffffffc02000ba <cprintf>
    ret = -E_NO_MEM;
ffffffffc0203d78:	5971                	li	s2,-4
            goto failed;
ffffffffc0203d7a:	bfc9                	j	ffffffffc0203d4c <do_pgfault+0x80>
        cprintf("not valid addr %x, and  can not find it in vma\n", addr);
ffffffffc0203d7c:	85a2                	mv	a1,s0
ffffffffc0203d7e:	00002517          	auipc	a0,0x2
ffffffffc0203d82:	21250513          	addi	a0,a0,530 # ffffffffc0205f90 <default_pmm_manager+0xd88>
ffffffffc0203d86:	b34fc0ef          	jal	ra,ffffffffc02000ba <cprintf>
    int ret = -E_INVAL;
ffffffffc0203d8a:	5975                	li	s2,-3
        goto failed;
ffffffffc0203d8c:	b7c1                	j	ffffffffc0203d4c <do_pgfault+0x80>
            cprintf("no swap_init_ok but ptep is %x, failed\n", *ptep);
ffffffffc0203d8e:	00002517          	auipc	a0,0x2
ffffffffc0203d92:	29a50513          	addi	a0,a0,666 # ffffffffc0206028 <default_pmm_manager+0xe20>
ffffffffc0203d96:	b24fc0ef          	jal	ra,ffffffffc02000ba <cprintf>
    ret = -E_NO_MEM;
ffffffffc0203d9a:	5971                	li	s2,-4
            goto failed;
ffffffffc0203d9c:	bf45                	j	ffffffffc0203d4c <do_pgfault+0x80>
                cprintf("swap_in failed for addr %x\n", addr);
ffffffffc0203d9e:	85a2                	mv	a1,s0
ffffffffc0203da0:	00002517          	auipc	a0,0x2
ffffffffc0203da4:	24850513          	addi	a0,a0,584 # ffffffffc0205fe8 <default_pmm_manager+0xde0>
ffffffffc0203da8:	b12fc0ef          	jal	ra,ffffffffc02000ba <cprintf>
    ret = -E_NO_MEM;
ffffffffc0203dac:	5971                	li	s2,-4
ffffffffc0203dae:	bf79                	j	ffffffffc0203d4c <do_pgfault+0x80>
                cprintf("page_insert failed for addr %x\n", addr);
ffffffffc0203db0:	85a2                	mv	a1,s0
ffffffffc0203db2:	00002517          	auipc	a0,0x2
ffffffffc0203db6:	25650513          	addi	a0,a0,598 # ffffffffc0206008 <default_pmm_manager+0xe00>
ffffffffc0203dba:	b00fc0ef          	jal	ra,ffffffffc02000ba <cprintf>
    ret = -E_NO_MEM;
ffffffffc0203dbe:	5971                	li	s2,-4
ffffffffc0203dc0:	b771                	j	ffffffffc0203d4c <do_pgfault+0x80>

ffffffffc0203dc2 <swapfs_init>:
#include <ide.h>
#include <pmm.h>
#include <assert.h>

void
swapfs_init(void) {
ffffffffc0203dc2:	1141                	addi	sp,sp,-16
    static_assert((PGSIZE % SECTSIZE) == 0);
    if (!ide_device_valid(SWAP_DEV_NO)) {
ffffffffc0203dc4:	4505                	li	a0,1
swapfs_init(void) {
ffffffffc0203dc6:	e406                	sd	ra,8(sp)
    if (!ide_device_valid(SWAP_DEV_NO)) {
ffffffffc0203dc8:	eccfc0ef          	jal	ra,ffffffffc0200494 <ide_device_valid>
ffffffffc0203dcc:	cd01                	beqz	a0,ffffffffc0203de4 <swapfs_init+0x22>
        panic("swap fs isn't available.\n");
    }
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
ffffffffc0203dce:	4505                	li	a0,1
ffffffffc0203dd0:	ecafc0ef          	jal	ra,ffffffffc020049a <ide_device_size>
}
ffffffffc0203dd4:	60a2                	ld	ra,8(sp)
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
ffffffffc0203dd6:	810d                	srli	a0,a0,0x3
ffffffffc0203dd8:	0000d797          	auipc	a5,0xd
ffffffffc0203ddc:	76a7b823          	sd	a0,1904(a5) # ffffffffc0211548 <max_swap_offset>
}
ffffffffc0203de0:	0141                	addi	sp,sp,16
ffffffffc0203de2:	8082                	ret
        panic("swap fs isn't available.\n");
ffffffffc0203de4:	00002617          	auipc	a2,0x2
ffffffffc0203de8:	26c60613          	addi	a2,a2,620 # ffffffffc0206050 <default_pmm_manager+0xe48>
ffffffffc0203dec:	45b5                	li	a1,13
ffffffffc0203dee:	00002517          	auipc	a0,0x2
ffffffffc0203df2:	28250513          	addi	a0,a0,642 # ffffffffc0206070 <default_pmm_manager+0xe68>
ffffffffc0203df6:	d7efc0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc0203dfa <swapfs_read>:

int
swapfs_read(swap_entry_t entry, struct Page *page) {
ffffffffc0203dfa:	1141                	addi	sp,sp,-16
ffffffffc0203dfc:	e406                	sd	ra,8(sp)
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203dfe:	00855793          	srli	a5,a0,0x8
ffffffffc0203e02:	c3a5                	beqz	a5,ffffffffc0203e62 <swapfs_read+0x68>
ffffffffc0203e04:	0000d717          	auipc	a4,0xd
ffffffffc0203e08:	74473703          	ld	a4,1860(a4) # ffffffffc0211548 <max_swap_offset>
ffffffffc0203e0c:	04e7fb63          	bgeu	a5,a4,ffffffffc0203e62 <swapfs_read+0x68>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203e10:	0000d617          	auipc	a2,0xd
ffffffffc0203e14:	72063603          	ld	a2,1824(a2) # ffffffffc0211530 <pages>
ffffffffc0203e18:	8d91                	sub	a1,a1,a2
ffffffffc0203e1a:	4035d613          	srai	a2,a1,0x3
ffffffffc0203e1e:	00002597          	auipc	a1,0x2
ffffffffc0203e22:	4d25b583          	ld	a1,1234(a1) # ffffffffc02062f0 <error_string+0x38>
ffffffffc0203e26:	02b60633          	mul	a2,a2,a1
ffffffffc0203e2a:	0037959b          	slliw	a1,a5,0x3
ffffffffc0203e2e:	00002797          	auipc	a5,0x2
ffffffffc0203e32:	4ca7b783          	ld	a5,1226(a5) # ffffffffc02062f8 <nbase>
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203e36:	0000d717          	auipc	a4,0xd
ffffffffc0203e3a:	6f273703          	ld	a4,1778(a4) # ffffffffc0211528 <npage>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203e3e:	963e                	add	a2,a2,a5
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203e40:	00c61793          	slli	a5,a2,0xc
ffffffffc0203e44:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0203e46:	0632                	slli	a2,a2,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203e48:	02e7f963          	bgeu	a5,a4,ffffffffc0203e7a <swapfs_read+0x80>
}
ffffffffc0203e4c:	60a2                	ld	ra,8(sp)
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203e4e:	0000d797          	auipc	a5,0xd
ffffffffc0203e52:	6f27b783          	ld	a5,1778(a5) # ffffffffc0211540 <va_pa_offset>
ffffffffc0203e56:	46a1                	li	a3,8
ffffffffc0203e58:	963e                	add	a2,a2,a5
ffffffffc0203e5a:	4505                	li	a0,1
}
ffffffffc0203e5c:	0141                	addi	sp,sp,16
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203e5e:	e42fc06f          	j	ffffffffc02004a0 <ide_read_secs>
ffffffffc0203e62:	86aa                	mv	a3,a0
ffffffffc0203e64:	00002617          	auipc	a2,0x2
ffffffffc0203e68:	22460613          	addi	a2,a2,548 # ffffffffc0206088 <default_pmm_manager+0xe80>
ffffffffc0203e6c:	45d1                	li	a1,20
ffffffffc0203e6e:	00002517          	auipc	a0,0x2
ffffffffc0203e72:	20250513          	addi	a0,a0,514 # ffffffffc0206070 <default_pmm_manager+0xe68>
ffffffffc0203e76:	cfefc0ef          	jal	ra,ffffffffc0200374 <__panic>
ffffffffc0203e7a:	86b2                	mv	a3,a2
ffffffffc0203e7c:	06a00593          	li	a1,106
ffffffffc0203e80:	00001617          	auipc	a2,0x1
ffffffffc0203e84:	41860613          	addi	a2,a2,1048 # ffffffffc0205298 <default_pmm_manager+0x90>
ffffffffc0203e88:	00001517          	auipc	a0,0x1
ffffffffc0203e8c:	3d850513          	addi	a0,a0,984 # ffffffffc0205260 <default_pmm_manager+0x58>
ffffffffc0203e90:	ce4fc0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc0203e94 <swapfs_write>:

int
swapfs_write(swap_entry_t entry, struct Page *page) {
ffffffffc0203e94:	1141                	addi	sp,sp,-16
ffffffffc0203e96:	e406                	sd	ra,8(sp)
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203e98:	00855793          	srli	a5,a0,0x8
ffffffffc0203e9c:	c3a5                	beqz	a5,ffffffffc0203efc <swapfs_write+0x68>
ffffffffc0203e9e:	0000d717          	auipc	a4,0xd
ffffffffc0203ea2:	6aa73703          	ld	a4,1706(a4) # ffffffffc0211548 <max_swap_offset>
ffffffffc0203ea6:	04e7fb63          	bgeu	a5,a4,ffffffffc0203efc <swapfs_write+0x68>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203eaa:	0000d617          	auipc	a2,0xd
ffffffffc0203eae:	68663603          	ld	a2,1670(a2) # ffffffffc0211530 <pages>
ffffffffc0203eb2:	8d91                	sub	a1,a1,a2
ffffffffc0203eb4:	4035d613          	srai	a2,a1,0x3
ffffffffc0203eb8:	00002597          	auipc	a1,0x2
ffffffffc0203ebc:	4385b583          	ld	a1,1080(a1) # ffffffffc02062f0 <error_string+0x38>
ffffffffc0203ec0:	02b60633          	mul	a2,a2,a1
ffffffffc0203ec4:	0037959b          	slliw	a1,a5,0x3
ffffffffc0203ec8:	00002797          	auipc	a5,0x2
ffffffffc0203ecc:	4307b783          	ld	a5,1072(a5) # ffffffffc02062f8 <nbase>
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203ed0:	0000d717          	auipc	a4,0xd
ffffffffc0203ed4:	65873703          	ld	a4,1624(a4) # ffffffffc0211528 <npage>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203ed8:	963e                	add	a2,a2,a5
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203eda:	00c61793          	slli	a5,a2,0xc
ffffffffc0203ede:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0203ee0:	0632                	slli	a2,a2,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203ee2:	02e7f963          	bgeu	a5,a4,ffffffffc0203f14 <swapfs_write+0x80>
}
ffffffffc0203ee6:	60a2                	ld	ra,8(sp)
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203ee8:	0000d797          	auipc	a5,0xd
ffffffffc0203eec:	6587b783          	ld	a5,1624(a5) # ffffffffc0211540 <va_pa_offset>
ffffffffc0203ef0:	46a1                	li	a3,8
ffffffffc0203ef2:	963e                	add	a2,a2,a5
ffffffffc0203ef4:	4505                	li	a0,1
}
ffffffffc0203ef6:	0141                	addi	sp,sp,16
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203ef8:	dccfc06f          	j	ffffffffc02004c4 <ide_write_secs>
ffffffffc0203efc:	86aa                	mv	a3,a0
ffffffffc0203efe:	00002617          	auipc	a2,0x2
ffffffffc0203f02:	18a60613          	addi	a2,a2,394 # ffffffffc0206088 <default_pmm_manager+0xe80>
ffffffffc0203f06:	45e5                	li	a1,25
ffffffffc0203f08:	00002517          	auipc	a0,0x2
ffffffffc0203f0c:	16850513          	addi	a0,a0,360 # ffffffffc0206070 <default_pmm_manager+0xe68>
ffffffffc0203f10:	c64fc0ef          	jal	ra,ffffffffc0200374 <__panic>
ffffffffc0203f14:	86b2                	mv	a3,a2
ffffffffc0203f16:	06a00593          	li	a1,106
ffffffffc0203f1a:	00001617          	auipc	a2,0x1
ffffffffc0203f1e:	37e60613          	addi	a2,a2,894 # ffffffffc0205298 <default_pmm_manager+0x90>
ffffffffc0203f22:	00001517          	auipc	a0,0x1
ffffffffc0203f26:	33e50513          	addi	a0,a0,830 # ffffffffc0205260 <default_pmm_manager+0x58>
ffffffffc0203f2a:	c4afc0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc0203f2e <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc0203f2e:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0203f32:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc0203f34:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0203f38:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc0203f3a:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0203f3e:	f022                	sd	s0,32(sp)
ffffffffc0203f40:	ec26                	sd	s1,24(sp)
ffffffffc0203f42:	e84a                	sd	s2,16(sp)
ffffffffc0203f44:	f406                	sd	ra,40(sp)
ffffffffc0203f46:	e44e                	sd	s3,8(sp)
ffffffffc0203f48:	84aa                	mv	s1,a0
ffffffffc0203f4a:	892e                	mv	s2,a1
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc0203f4c:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc0203f50:	2a01                	sext.w	s4,s4
    if (num >= base) {
ffffffffc0203f52:	03067e63          	bgeu	a2,a6,ffffffffc0203f8e <printnum+0x60>
ffffffffc0203f56:	89be                	mv	s3,a5
        while (-- width > 0)
ffffffffc0203f58:	00805763          	blez	s0,ffffffffc0203f66 <printnum+0x38>
ffffffffc0203f5c:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc0203f5e:	85ca                	mv	a1,s2
ffffffffc0203f60:	854e                	mv	a0,s3
ffffffffc0203f62:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc0203f64:	fc65                	bnez	s0,ffffffffc0203f5c <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0203f66:	1a02                	slli	s4,s4,0x20
ffffffffc0203f68:	00002797          	auipc	a5,0x2
ffffffffc0203f6c:	14078793          	addi	a5,a5,320 # ffffffffc02060a8 <default_pmm_manager+0xea0>
ffffffffc0203f70:	020a5a13          	srli	s4,s4,0x20
ffffffffc0203f74:	9a3e                	add	s4,s4,a5
}
ffffffffc0203f76:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0203f78:	000a4503          	lbu	a0,0(s4)
}
ffffffffc0203f7c:	70a2                	ld	ra,40(sp)
ffffffffc0203f7e:	69a2                	ld	s3,8(sp)
ffffffffc0203f80:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0203f82:	85ca                	mv	a1,s2
ffffffffc0203f84:	87a6                	mv	a5,s1
}
ffffffffc0203f86:	6942                	ld	s2,16(sp)
ffffffffc0203f88:	64e2                	ld	s1,24(sp)
ffffffffc0203f8a:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0203f8c:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc0203f8e:	03065633          	divu	a2,a2,a6
ffffffffc0203f92:	8722                	mv	a4,s0
ffffffffc0203f94:	f9bff0ef          	jal	ra,ffffffffc0203f2e <printnum>
ffffffffc0203f98:	b7f9                	j	ffffffffc0203f66 <printnum+0x38>

ffffffffc0203f9a <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc0203f9a:	7119                	addi	sp,sp,-128
ffffffffc0203f9c:	f4a6                	sd	s1,104(sp)
ffffffffc0203f9e:	f0ca                	sd	s2,96(sp)
ffffffffc0203fa0:	ecce                	sd	s3,88(sp)
ffffffffc0203fa2:	e8d2                	sd	s4,80(sp)
ffffffffc0203fa4:	e4d6                	sd	s5,72(sp)
ffffffffc0203fa6:	e0da                	sd	s6,64(sp)
ffffffffc0203fa8:	fc5e                	sd	s7,56(sp)
ffffffffc0203faa:	f06a                	sd	s10,32(sp)
ffffffffc0203fac:	fc86                	sd	ra,120(sp)
ffffffffc0203fae:	f8a2                	sd	s0,112(sp)
ffffffffc0203fb0:	f862                	sd	s8,48(sp)
ffffffffc0203fb2:	f466                	sd	s9,40(sp)
ffffffffc0203fb4:	ec6e                	sd	s11,24(sp)
ffffffffc0203fb6:	892a                	mv	s2,a0
ffffffffc0203fb8:	84ae                	mv	s1,a1
ffffffffc0203fba:	8d32                	mv	s10,a2
ffffffffc0203fbc:	8a36                	mv	s4,a3
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0203fbe:	02500993          	li	s3,37
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
ffffffffc0203fc2:	5b7d                	li	s6,-1
ffffffffc0203fc4:	00002a97          	auipc	s5,0x2
ffffffffc0203fc8:	118a8a93          	addi	s5,s5,280 # ffffffffc02060dc <default_pmm_manager+0xed4>
        case 'e':
            err = va_arg(ap, int);
            if (err < 0) {
                err = -err;
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0203fcc:	00002b97          	auipc	s7,0x2
ffffffffc0203fd0:	2ecb8b93          	addi	s7,s7,748 # ffffffffc02062b8 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0203fd4:	000d4503          	lbu	a0,0(s10) # 80000 <kern_entry-0xffffffffc0180000>
ffffffffc0203fd8:	001d0413          	addi	s0,s10,1
ffffffffc0203fdc:	01350a63          	beq	a0,s3,ffffffffc0203ff0 <vprintfmt+0x56>
            if (ch == '\0') {
ffffffffc0203fe0:	c121                	beqz	a0,ffffffffc0204020 <vprintfmt+0x86>
            putch(ch, putdat);
ffffffffc0203fe2:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0203fe4:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc0203fe6:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0203fe8:	fff44503          	lbu	a0,-1(s0)
ffffffffc0203fec:	ff351ae3          	bne	a0,s3,ffffffffc0203fe0 <vprintfmt+0x46>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0203ff0:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc0203ff4:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc0203ff8:	4c81                	li	s9,0
ffffffffc0203ffa:	4881                	li	a7,0
        width = precision = -1;
ffffffffc0203ffc:	5c7d                	li	s8,-1
ffffffffc0203ffe:	5dfd                	li	s11,-1
ffffffffc0204000:	05500513          	li	a0,85
                if (ch < '0' || ch > '9') {
ffffffffc0204004:	4825                	li	a6,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204006:	fdd6059b          	addiw	a1,a2,-35
ffffffffc020400a:	0ff5f593          	zext.b	a1,a1
ffffffffc020400e:	00140d13          	addi	s10,s0,1
ffffffffc0204012:	04b56263          	bltu	a0,a1,ffffffffc0204056 <vprintfmt+0xbc>
ffffffffc0204016:	058a                	slli	a1,a1,0x2
ffffffffc0204018:	95d6                	add	a1,a1,s5
ffffffffc020401a:	4194                	lw	a3,0(a1)
ffffffffc020401c:	96d6                	add	a3,a3,s5
ffffffffc020401e:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc0204020:	70e6                	ld	ra,120(sp)
ffffffffc0204022:	7446                	ld	s0,112(sp)
ffffffffc0204024:	74a6                	ld	s1,104(sp)
ffffffffc0204026:	7906                	ld	s2,96(sp)
ffffffffc0204028:	69e6                	ld	s3,88(sp)
ffffffffc020402a:	6a46                	ld	s4,80(sp)
ffffffffc020402c:	6aa6                	ld	s5,72(sp)
ffffffffc020402e:	6b06                	ld	s6,64(sp)
ffffffffc0204030:	7be2                	ld	s7,56(sp)
ffffffffc0204032:	7c42                	ld	s8,48(sp)
ffffffffc0204034:	7ca2                	ld	s9,40(sp)
ffffffffc0204036:	7d02                	ld	s10,32(sp)
ffffffffc0204038:	6de2                	ld	s11,24(sp)
ffffffffc020403a:	6109                	addi	sp,sp,128
ffffffffc020403c:	8082                	ret
            padc = '0';
ffffffffc020403e:	87b2                	mv	a5,a2
            goto reswitch;
ffffffffc0204040:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204044:	846a                	mv	s0,s10
ffffffffc0204046:	00140d13          	addi	s10,s0,1
ffffffffc020404a:	fdd6059b          	addiw	a1,a2,-35
ffffffffc020404e:	0ff5f593          	zext.b	a1,a1
ffffffffc0204052:	fcb572e3          	bgeu	a0,a1,ffffffffc0204016 <vprintfmt+0x7c>
            putch('%', putdat);
ffffffffc0204056:	85a6                	mv	a1,s1
ffffffffc0204058:	02500513          	li	a0,37
ffffffffc020405c:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc020405e:	fff44783          	lbu	a5,-1(s0)
ffffffffc0204062:	8d22                	mv	s10,s0
ffffffffc0204064:	f73788e3          	beq	a5,s3,ffffffffc0203fd4 <vprintfmt+0x3a>
ffffffffc0204068:	ffed4783          	lbu	a5,-2(s10)
ffffffffc020406c:	1d7d                	addi	s10,s10,-1
ffffffffc020406e:	ff379de3          	bne	a5,s3,ffffffffc0204068 <vprintfmt+0xce>
ffffffffc0204072:	b78d                	j	ffffffffc0203fd4 <vprintfmt+0x3a>
                precision = precision * 10 + ch - '0';
ffffffffc0204074:	fd060c1b          	addiw	s8,a2,-48
                ch = *fmt;
ffffffffc0204078:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020407c:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc020407e:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc0204082:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc0204086:	02d86463          	bltu	a6,a3,ffffffffc02040ae <vprintfmt+0x114>
                ch = *fmt;
ffffffffc020408a:	00144603          	lbu	a2,1(s0)
                precision = precision * 10 + ch - '0';
ffffffffc020408e:	002c169b          	slliw	a3,s8,0x2
ffffffffc0204092:	0186873b          	addw	a4,a3,s8
ffffffffc0204096:	0017171b          	slliw	a4,a4,0x1
ffffffffc020409a:	9f2d                	addw	a4,a4,a1
                if (ch < '0' || ch > '9') {
ffffffffc020409c:	fd06069b          	addiw	a3,a2,-48
            for (precision = 0; ; ++ fmt) {
ffffffffc02040a0:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc02040a2:	fd070c1b          	addiw	s8,a4,-48
                ch = *fmt;
ffffffffc02040a6:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc02040aa:	fed870e3          	bgeu	a6,a3,ffffffffc020408a <vprintfmt+0xf0>
            if (width < 0)
ffffffffc02040ae:	f40ddce3          	bgez	s11,ffffffffc0204006 <vprintfmt+0x6c>
                width = precision, precision = -1;
ffffffffc02040b2:	8de2                	mv	s11,s8
ffffffffc02040b4:	5c7d                	li	s8,-1
ffffffffc02040b6:	bf81                	j	ffffffffc0204006 <vprintfmt+0x6c>
            if (width < 0)
ffffffffc02040b8:	fffdc693          	not	a3,s11
ffffffffc02040bc:	96fd                	srai	a3,a3,0x3f
ffffffffc02040be:	00ddfdb3          	and	s11,s11,a3
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02040c2:	00144603          	lbu	a2,1(s0)
ffffffffc02040c6:	2d81                	sext.w	s11,s11
ffffffffc02040c8:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc02040ca:	bf35                	j	ffffffffc0204006 <vprintfmt+0x6c>
            precision = va_arg(ap, int);
ffffffffc02040cc:	000a2c03          	lw	s8,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02040d0:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc02040d4:	0a21                	addi	s4,s4,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02040d6:	846a                	mv	s0,s10
            goto process_precision;
ffffffffc02040d8:	bfd9                	j	ffffffffc02040ae <vprintfmt+0x114>
    if (lflag >= 2) {
ffffffffc02040da:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc02040dc:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc02040e0:	01174463          	blt	a4,a7,ffffffffc02040e8 <vprintfmt+0x14e>
    else if (lflag) {
ffffffffc02040e4:	1a088e63          	beqz	a7,ffffffffc02042a0 <vprintfmt+0x306>
        return va_arg(*ap, unsigned long);
ffffffffc02040e8:	000a3603          	ld	a2,0(s4)
ffffffffc02040ec:	46c1                	li	a3,16
ffffffffc02040ee:	8a2e                	mv	s4,a1
            printnum(putch, putdat, num, base, width, padc);
ffffffffc02040f0:	2781                	sext.w	a5,a5
ffffffffc02040f2:	876e                	mv	a4,s11
ffffffffc02040f4:	85a6                	mv	a1,s1
ffffffffc02040f6:	854a                	mv	a0,s2
ffffffffc02040f8:	e37ff0ef          	jal	ra,ffffffffc0203f2e <printnum>
            break;
ffffffffc02040fc:	bde1                	j	ffffffffc0203fd4 <vprintfmt+0x3a>
            putch(va_arg(ap, int), putdat);
ffffffffc02040fe:	000a2503          	lw	a0,0(s4)
ffffffffc0204102:	85a6                	mv	a1,s1
ffffffffc0204104:	0a21                	addi	s4,s4,8
ffffffffc0204106:	9902                	jalr	s2
            break;
ffffffffc0204108:	b5f1                	j	ffffffffc0203fd4 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc020410a:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc020410c:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0204110:	01174463          	blt	a4,a7,ffffffffc0204118 <vprintfmt+0x17e>
    else if (lflag) {
ffffffffc0204114:	18088163          	beqz	a7,ffffffffc0204296 <vprintfmt+0x2fc>
        return va_arg(*ap, unsigned long);
ffffffffc0204118:	000a3603          	ld	a2,0(s4)
ffffffffc020411c:	46a9                	li	a3,10
ffffffffc020411e:	8a2e                	mv	s4,a1
ffffffffc0204120:	bfc1                	j	ffffffffc02040f0 <vprintfmt+0x156>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204122:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc0204126:	4c85                	li	s9,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204128:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc020412a:	bdf1                	j	ffffffffc0204006 <vprintfmt+0x6c>
            putch(ch, putdat);
ffffffffc020412c:	85a6                	mv	a1,s1
ffffffffc020412e:	02500513          	li	a0,37
ffffffffc0204132:	9902                	jalr	s2
            break;
ffffffffc0204134:	b545                	j	ffffffffc0203fd4 <vprintfmt+0x3a>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204136:	00144603          	lbu	a2,1(s0)
            lflag ++;
ffffffffc020413a:	2885                	addiw	a7,a7,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020413c:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc020413e:	b5e1                	j	ffffffffc0204006 <vprintfmt+0x6c>
    if (lflag >= 2) {
ffffffffc0204140:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0204142:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0204146:	01174463          	blt	a4,a7,ffffffffc020414e <vprintfmt+0x1b4>
    else if (lflag) {
ffffffffc020414a:	14088163          	beqz	a7,ffffffffc020428c <vprintfmt+0x2f2>
        return va_arg(*ap, unsigned long);
ffffffffc020414e:	000a3603          	ld	a2,0(s4)
ffffffffc0204152:	46a1                	li	a3,8
ffffffffc0204154:	8a2e                	mv	s4,a1
ffffffffc0204156:	bf69                	j	ffffffffc02040f0 <vprintfmt+0x156>
            putch('0', putdat);
ffffffffc0204158:	03000513          	li	a0,48
ffffffffc020415c:	85a6                	mv	a1,s1
ffffffffc020415e:	e03e                	sd	a5,0(sp)
ffffffffc0204160:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc0204162:	85a6                	mv	a1,s1
ffffffffc0204164:	07800513          	li	a0,120
ffffffffc0204168:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc020416a:	0a21                	addi	s4,s4,8
            goto number;
ffffffffc020416c:	6782                	ld	a5,0(sp)
ffffffffc020416e:	46c1                	li	a3,16
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc0204170:	ff8a3603          	ld	a2,-8(s4)
            goto number;
ffffffffc0204174:	bfb5                	j	ffffffffc02040f0 <vprintfmt+0x156>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0204176:	000a3403          	ld	s0,0(s4)
ffffffffc020417a:	008a0713          	addi	a4,s4,8
ffffffffc020417e:	e03a                	sd	a4,0(sp)
ffffffffc0204180:	14040263          	beqz	s0,ffffffffc02042c4 <vprintfmt+0x32a>
            if (width > 0 && padc != '-') {
ffffffffc0204184:	0fb05763          	blez	s11,ffffffffc0204272 <vprintfmt+0x2d8>
ffffffffc0204188:	02d00693          	li	a3,45
ffffffffc020418c:	0cd79163          	bne	a5,a3,ffffffffc020424e <vprintfmt+0x2b4>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0204190:	00044783          	lbu	a5,0(s0)
ffffffffc0204194:	0007851b          	sext.w	a0,a5
ffffffffc0204198:	cf85                	beqz	a5,ffffffffc02041d0 <vprintfmt+0x236>
ffffffffc020419a:	00140a13          	addi	s4,s0,1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc020419e:	05e00413          	li	s0,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02041a2:	000c4563          	bltz	s8,ffffffffc02041ac <vprintfmt+0x212>
ffffffffc02041a6:	3c7d                	addiw	s8,s8,-1
ffffffffc02041a8:	036c0263          	beq	s8,s6,ffffffffc02041cc <vprintfmt+0x232>
                    putch('?', putdat);
ffffffffc02041ac:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02041ae:	0e0c8e63          	beqz	s9,ffffffffc02042aa <vprintfmt+0x310>
ffffffffc02041b2:	3781                	addiw	a5,a5,-32
ffffffffc02041b4:	0ef47b63          	bgeu	s0,a5,ffffffffc02042aa <vprintfmt+0x310>
                    putch('?', putdat);
ffffffffc02041b8:	03f00513          	li	a0,63
ffffffffc02041bc:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02041be:	000a4783          	lbu	a5,0(s4)
ffffffffc02041c2:	3dfd                	addiw	s11,s11,-1
ffffffffc02041c4:	0a05                	addi	s4,s4,1
ffffffffc02041c6:	0007851b          	sext.w	a0,a5
ffffffffc02041ca:	ffe1                	bnez	a5,ffffffffc02041a2 <vprintfmt+0x208>
            for (; width > 0; width --) {
ffffffffc02041cc:	01b05963          	blez	s11,ffffffffc02041de <vprintfmt+0x244>
ffffffffc02041d0:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc02041d2:	85a6                	mv	a1,s1
ffffffffc02041d4:	02000513          	li	a0,32
ffffffffc02041d8:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc02041da:	fe0d9be3          	bnez	s11,ffffffffc02041d0 <vprintfmt+0x236>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc02041de:	6a02                	ld	s4,0(sp)
ffffffffc02041e0:	bbd5                	j	ffffffffc0203fd4 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc02041e2:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc02041e4:	008a0c93          	addi	s9,s4,8
    if (lflag >= 2) {
ffffffffc02041e8:	01174463          	blt	a4,a7,ffffffffc02041f0 <vprintfmt+0x256>
    else if (lflag) {
ffffffffc02041ec:	08088d63          	beqz	a7,ffffffffc0204286 <vprintfmt+0x2ec>
        return va_arg(*ap, long);
ffffffffc02041f0:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
ffffffffc02041f4:	0a044d63          	bltz	s0,ffffffffc02042ae <vprintfmt+0x314>
            num = getint(&ap, lflag);
ffffffffc02041f8:	8622                	mv	a2,s0
ffffffffc02041fa:	8a66                	mv	s4,s9
ffffffffc02041fc:	46a9                	li	a3,10
ffffffffc02041fe:	bdcd                	j	ffffffffc02040f0 <vprintfmt+0x156>
            err = va_arg(ap, int);
ffffffffc0204200:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0204204:	4719                	li	a4,6
            err = va_arg(ap, int);
ffffffffc0204206:	0a21                	addi	s4,s4,8
            if (err < 0) {
ffffffffc0204208:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc020420c:	8fb5                	xor	a5,a5,a3
ffffffffc020420e:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0204212:	02d74163          	blt	a4,a3,ffffffffc0204234 <vprintfmt+0x29a>
ffffffffc0204216:	00369793          	slli	a5,a3,0x3
ffffffffc020421a:	97de                	add	a5,a5,s7
ffffffffc020421c:	639c                	ld	a5,0(a5)
ffffffffc020421e:	cb99                	beqz	a5,ffffffffc0204234 <vprintfmt+0x29a>
                printfmt(putch, putdat, "%s", p);
ffffffffc0204220:	86be                	mv	a3,a5
ffffffffc0204222:	00002617          	auipc	a2,0x2
ffffffffc0204226:	eb660613          	addi	a2,a2,-330 # ffffffffc02060d8 <default_pmm_manager+0xed0>
ffffffffc020422a:	85a6                	mv	a1,s1
ffffffffc020422c:	854a                	mv	a0,s2
ffffffffc020422e:	0ce000ef          	jal	ra,ffffffffc02042fc <printfmt>
ffffffffc0204232:	b34d                	j	ffffffffc0203fd4 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc0204234:	00002617          	auipc	a2,0x2
ffffffffc0204238:	e9460613          	addi	a2,a2,-364 # ffffffffc02060c8 <default_pmm_manager+0xec0>
ffffffffc020423c:	85a6                	mv	a1,s1
ffffffffc020423e:	854a                	mv	a0,s2
ffffffffc0204240:	0bc000ef          	jal	ra,ffffffffc02042fc <printfmt>
ffffffffc0204244:	bb41                	j	ffffffffc0203fd4 <vprintfmt+0x3a>
                p = "(null)";
ffffffffc0204246:	00002417          	auipc	s0,0x2
ffffffffc020424a:	e7a40413          	addi	s0,s0,-390 # ffffffffc02060c0 <default_pmm_manager+0xeb8>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc020424e:	85e2                	mv	a1,s8
ffffffffc0204250:	8522                	mv	a0,s0
ffffffffc0204252:	e43e                	sd	a5,8(sp)
ffffffffc0204254:	196000ef          	jal	ra,ffffffffc02043ea <strnlen>
ffffffffc0204258:	40ad8dbb          	subw	s11,s11,a0
ffffffffc020425c:	01b05b63          	blez	s11,ffffffffc0204272 <vprintfmt+0x2d8>
                    putch(padc, putdat);
ffffffffc0204260:	67a2                	ld	a5,8(sp)
ffffffffc0204262:	00078a1b          	sext.w	s4,a5
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0204266:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc0204268:	85a6                	mv	a1,s1
ffffffffc020426a:	8552                	mv	a0,s4
ffffffffc020426c:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc020426e:	fe0d9ce3          	bnez	s11,ffffffffc0204266 <vprintfmt+0x2cc>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0204272:	00044783          	lbu	a5,0(s0)
ffffffffc0204276:	00140a13          	addi	s4,s0,1
ffffffffc020427a:	0007851b          	sext.w	a0,a5
ffffffffc020427e:	d3a5                	beqz	a5,ffffffffc02041de <vprintfmt+0x244>
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0204280:	05e00413          	li	s0,94
ffffffffc0204284:	bf39                	j	ffffffffc02041a2 <vprintfmt+0x208>
        return va_arg(*ap, int);
ffffffffc0204286:	000a2403          	lw	s0,0(s4)
ffffffffc020428a:	b7ad                	j	ffffffffc02041f4 <vprintfmt+0x25a>
        return va_arg(*ap, unsigned int);
ffffffffc020428c:	000a6603          	lwu	a2,0(s4)
ffffffffc0204290:	46a1                	li	a3,8
ffffffffc0204292:	8a2e                	mv	s4,a1
ffffffffc0204294:	bdb1                	j	ffffffffc02040f0 <vprintfmt+0x156>
ffffffffc0204296:	000a6603          	lwu	a2,0(s4)
ffffffffc020429a:	46a9                	li	a3,10
ffffffffc020429c:	8a2e                	mv	s4,a1
ffffffffc020429e:	bd89                	j	ffffffffc02040f0 <vprintfmt+0x156>
ffffffffc02042a0:	000a6603          	lwu	a2,0(s4)
ffffffffc02042a4:	46c1                	li	a3,16
ffffffffc02042a6:	8a2e                	mv	s4,a1
ffffffffc02042a8:	b5a1                	j	ffffffffc02040f0 <vprintfmt+0x156>
                    putch(ch, putdat);
ffffffffc02042aa:	9902                	jalr	s2
ffffffffc02042ac:	bf09                	j	ffffffffc02041be <vprintfmt+0x224>
                putch('-', putdat);
ffffffffc02042ae:	85a6                	mv	a1,s1
ffffffffc02042b0:	02d00513          	li	a0,45
ffffffffc02042b4:	e03e                	sd	a5,0(sp)
ffffffffc02042b6:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc02042b8:	6782                	ld	a5,0(sp)
ffffffffc02042ba:	8a66                	mv	s4,s9
ffffffffc02042bc:	40800633          	neg	a2,s0
ffffffffc02042c0:	46a9                	li	a3,10
ffffffffc02042c2:	b53d                	j	ffffffffc02040f0 <vprintfmt+0x156>
            if (width > 0 && padc != '-') {
ffffffffc02042c4:	03b05163          	blez	s11,ffffffffc02042e6 <vprintfmt+0x34c>
ffffffffc02042c8:	02d00693          	li	a3,45
ffffffffc02042cc:	f6d79de3          	bne	a5,a3,ffffffffc0204246 <vprintfmt+0x2ac>
                p = "(null)";
ffffffffc02042d0:	00002417          	auipc	s0,0x2
ffffffffc02042d4:	df040413          	addi	s0,s0,-528 # ffffffffc02060c0 <default_pmm_manager+0xeb8>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02042d8:	02800793          	li	a5,40
ffffffffc02042dc:	02800513          	li	a0,40
ffffffffc02042e0:	00140a13          	addi	s4,s0,1
ffffffffc02042e4:	bd6d                	j	ffffffffc020419e <vprintfmt+0x204>
ffffffffc02042e6:	00002a17          	auipc	s4,0x2
ffffffffc02042ea:	ddba0a13          	addi	s4,s4,-549 # ffffffffc02060c1 <default_pmm_manager+0xeb9>
ffffffffc02042ee:	02800513          	li	a0,40
ffffffffc02042f2:	02800793          	li	a5,40
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02042f6:	05e00413          	li	s0,94
ffffffffc02042fa:	b565                	j	ffffffffc02041a2 <vprintfmt+0x208>

ffffffffc02042fc <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc02042fc:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc02042fe:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0204302:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0204304:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0204306:	ec06                	sd	ra,24(sp)
ffffffffc0204308:	f83a                	sd	a4,48(sp)
ffffffffc020430a:	fc3e                	sd	a5,56(sp)
ffffffffc020430c:	e0c2                	sd	a6,64(sp)
ffffffffc020430e:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc0204310:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0204312:	c89ff0ef          	jal	ra,ffffffffc0203f9a <vprintfmt>
}
ffffffffc0204316:	60e2                	ld	ra,24(sp)
ffffffffc0204318:	6161                	addi	sp,sp,80
ffffffffc020431a:	8082                	ret

ffffffffc020431c <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
ffffffffc020431c:	715d                	addi	sp,sp,-80
ffffffffc020431e:	e486                	sd	ra,72(sp)
ffffffffc0204320:	e0a6                	sd	s1,64(sp)
ffffffffc0204322:	fc4a                	sd	s2,56(sp)
ffffffffc0204324:	f84e                	sd	s3,48(sp)
ffffffffc0204326:	f452                	sd	s4,40(sp)
ffffffffc0204328:	f056                	sd	s5,32(sp)
ffffffffc020432a:	ec5a                	sd	s6,24(sp)
ffffffffc020432c:	e85e                	sd	s7,16(sp)
    if (prompt != NULL) {
ffffffffc020432e:	c901                	beqz	a0,ffffffffc020433e <readline+0x22>
ffffffffc0204330:	85aa                	mv	a1,a0
        cprintf("%s", prompt);
ffffffffc0204332:	00002517          	auipc	a0,0x2
ffffffffc0204336:	da650513          	addi	a0,a0,-602 # ffffffffc02060d8 <default_pmm_manager+0xed0>
ffffffffc020433a:	d81fb0ef          	jal	ra,ffffffffc02000ba <cprintf>
readline(const char *prompt) {
ffffffffc020433e:	4481                	li	s1,0
    while (1) {
        c = getchar();
        if (c < 0) {
            return NULL;
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0204340:	497d                	li	s2,31
            cputchar(c);
            buf[i ++] = c;
        }
        else if (c == '\b' && i > 0) {
ffffffffc0204342:	49a1                	li	s3,8
            cputchar(c);
            i --;
        }
        else if (c == '\n' || c == '\r') {
ffffffffc0204344:	4aa9                	li	s5,10
ffffffffc0204346:	4b35                	li	s6,13
            buf[i ++] = c;
ffffffffc0204348:	0000db97          	auipc	s7,0xd
ffffffffc020434c:	db0b8b93          	addi	s7,s7,-592 # ffffffffc02110f8 <buf>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0204350:	3fe00a13          	li	s4,1022
        c = getchar();
ffffffffc0204354:	d9ffb0ef          	jal	ra,ffffffffc02000f2 <getchar>
        if (c < 0) {
ffffffffc0204358:	00054a63          	bltz	a0,ffffffffc020436c <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc020435c:	00a95a63          	bge	s2,a0,ffffffffc0204370 <readline+0x54>
ffffffffc0204360:	029a5263          	bge	s4,s1,ffffffffc0204384 <readline+0x68>
        c = getchar();
ffffffffc0204364:	d8ffb0ef          	jal	ra,ffffffffc02000f2 <getchar>
        if (c < 0) {
ffffffffc0204368:	fe055ae3          	bgez	a0,ffffffffc020435c <readline+0x40>
            return NULL;
ffffffffc020436c:	4501                	li	a0,0
ffffffffc020436e:	a091                	j	ffffffffc02043b2 <readline+0x96>
        else if (c == '\b' && i > 0) {
ffffffffc0204370:	03351463          	bne	a0,s3,ffffffffc0204398 <readline+0x7c>
ffffffffc0204374:	e8a9                	bnez	s1,ffffffffc02043c6 <readline+0xaa>
        c = getchar();
ffffffffc0204376:	d7dfb0ef          	jal	ra,ffffffffc02000f2 <getchar>
        if (c < 0) {
ffffffffc020437a:	fe0549e3          	bltz	a0,ffffffffc020436c <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc020437e:	fea959e3          	bge	s2,a0,ffffffffc0204370 <readline+0x54>
ffffffffc0204382:	4481                	li	s1,0
            cputchar(c);
ffffffffc0204384:	e42a                	sd	a0,8(sp)
ffffffffc0204386:	d6bfb0ef          	jal	ra,ffffffffc02000f0 <cputchar>
            buf[i ++] = c;
ffffffffc020438a:	6522                	ld	a0,8(sp)
ffffffffc020438c:	009b87b3          	add	a5,s7,s1
ffffffffc0204390:	2485                	addiw	s1,s1,1
ffffffffc0204392:	00a78023          	sb	a0,0(a5)
ffffffffc0204396:	bf7d                	j	ffffffffc0204354 <readline+0x38>
        else if (c == '\n' || c == '\r') {
ffffffffc0204398:	01550463          	beq	a0,s5,ffffffffc02043a0 <readline+0x84>
ffffffffc020439c:	fb651ce3          	bne	a0,s6,ffffffffc0204354 <readline+0x38>
            cputchar(c);
ffffffffc02043a0:	d51fb0ef          	jal	ra,ffffffffc02000f0 <cputchar>
            buf[i] = '\0';
ffffffffc02043a4:	0000d517          	auipc	a0,0xd
ffffffffc02043a8:	d5450513          	addi	a0,a0,-684 # ffffffffc02110f8 <buf>
ffffffffc02043ac:	94aa                	add	s1,s1,a0
ffffffffc02043ae:	00048023          	sb	zero,0(s1)
            return buf;
        }
    }
}
ffffffffc02043b2:	60a6                	ld	ra,72(sp)
ffffffffc02043b4:	6486                	ld	s1,64(sp)
ffffffffc02043b6:	7962                	ld	s2,56(sp)
ffffffffc02043b8:	79c2                	ld	s3,48(sp)
ffffffffc02043ba:	7a22                	ld	s4,40(sp)
ffffffffc02043bc:	7a82                	ld	s5,32(sp)
ffffffffc02043be:	6b62                	ld	s6,24(sp)
ffffffffc02043c0:	6bc2                	ld	s7,16(sp)
ffffffffc02043c2:	6161                	addi	sp,sp,80
ffffffffc02043c4:	8082                	ret
            cputchar(c);
ffffffffc02043c6:	4521                	li	a0,8
ffffffffc02043c8:	d29fb0ef          	jal	ra,ffffffffc02000f0 <cputchar>
            i --;
ffffffffc02043cc:	34fd                	addiw	s1,s1,-1
ffffffffc02043ce:	b759                	j	ffffffffc0204354 <readline+0x38>

ffffffffc02043d0 <strlen>:
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
ffffffffc02043d0:	00054783          	lbu	a5,0(a0)
strlen(const char *s) {
ffffffffc02043d4:	872a                	mv	a4,a0
    size_t cnt = 0;
ffffffffc02043d6:	4501                	li	a0,0
    while (*s ++ != '\0') {
ffffffffc02043d8:	cb81                	beqz	a5,ffffffffc02043e8 <strlen+0x18>
        cnt ++;
ffffffffc02043da:	0505                	addi	a0,a0,1
    while (*s ++ != '\0') {
ffffffffc02043dc:	00a707b3          	add	a5,a4,a0
ffffffffc02043e0:	0007c783          	lbu	a5,0(a5)
ffffffffc02043e4:	fbfd                	bnez	a5,ffffffffc02043da <strlen+0xa>
ffffffffc02043e6:	8082                	ret
    }
    return cnt;
}
ffffffffc02043e8:	8082                	ret

ffffffffc02043ea <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
ffffffffc02043ea:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
ffffffffc02043ec:	e589                	bnez	a1,ffffffffc02043f6 <strnlen+0xc>
ffffffffc02043ee:	a811                	j	ffffffffc0204402 <strnlen+0x18>
        cnt ++;
ffffffffc02043f0:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc02043f2:	00f58863          	beq	a1,a5,ffffffffc0204402 <strnlen+0x18>
ffffffffc02043f6:	00f50733          	add	a4,a0,a5
ffffffffc02043fa:	00074703          	lbu	a4,0(a4)
ffffffffc02043fe:	fb6d                	bnez	a4,ffffffffc02043f0 <strnlen+0x6>
ffffffffc0204400:	85be                	mv	a1,a5
    }
    return cnt;
}
ffffffffc0204402:	852e                	mv	a0,a1
ffffffffc0204404:	8082                	ret

ffffffffc0204406 <strcpy>:
char *
strcpy(char *dst, const char *src) {
#ifdef __HAVE_ARCH_STRCPY
    return __strcpy(dst, src);
#else
    char *p = dst;
ffffffffc0204406:	87aa                	mv	a5,a0
    while ((*p ++ = *src ++) != '\0')
ffffffffc0204408:	0005c703          	lbu	a4,0(a1)
ffffffffc020440c:	0785                	addi	a5,a5,1
ffffffffc020440e:	0585                	addi	a1,a1,1
ffffffffc0204410:	fee78fa3          	sb	a4,-1(a5)
ffffffffc0204414:	fb75                	bnez	a4,ffffffffc0204408 <strcpy+0x2>
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
ffffffffc0204416:	8082                	ret

ffffffffc0204418 <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0204418:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc020441c:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0204420:	cb89                	beqz	a5,ffffffffc0204432 <strcmp+0x1a>
        s1 ++, s2 ++;
ffffffffc0204422:	0505                	addi	a0,a0,1
ffffffffc0204424:	0585                	addi	a1,a1,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0204426:	fee789e3          	beq	a5,a4,ffffffffc0204418 <strcmp>
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc020442a:	0007851b          	sext.w	a0,a5
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc020442e:	9d19                	subw	a0,a0,a4
ffffffffc0204430:	8082                	ret
ffffffffc0204432:	4501                	li	a0,0
ffffffffc0204434:	bfed                	j	ffffffffc020442e <strcmp+0x16>

ffffffffc0204436 <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc0204436:	00054783          	lbu	a5,0(a0)
ffffffffc020443a:	c799                	beqz	a5,ffffffffc0204448 <strchr+0x12>
        if (*s == c) {
ffffffffc020443c:	00f58763          	beq	a1,a5,ffffffffc020444a <strchr+0x14>
    while (*s != '\0') {
ffffffffc0204440:	00154783          	lbu	a5,1(a0)
            return (char *)s;
        }
        s ++;
ffffffffc0204444:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc0204446:	fbfd                	bnez	a5,ffffffffc020443c <strchr+0x6>
    }
    return NULL;
ffffffffc0204448:	4501                	li	a0,0
}
ffffffffc020444a:	8082                	ret

ffffffffc020444c <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc020444c:	ca01                	beqz	a2,ffffffffc020445c <memset+0x10>
ffffffffc020444e:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc0204450:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc0204452:	0785                	addi	a5,a5,1
ffffffffc0204454:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc0204458:	fec79de3          	bne	a5,a2,ffffffffc0204452 <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc020445c:	8082                	ret

ffffffffc020445e <memcpy>:
#ifdef __HAVE_ARCH_MEMCPY
    return __memcpy(dst, src, n);
#else
    const char *s = src;
    char *d = dst;
    while (n -- > 0) {
ffffffffc020445e:	ca19                	beqz	a2,ffffffffc0204474 <memcpy+0x16>
ffffffffc0204460:	962e                	add	a2,a2,a1
    char *d = dst;
ffffffffc0204462:	87aa                	mv	a5,a0
        *d ++ = *s ++;
ffffffffc0204464:	0005c703          	lbu	a4,0(a1)
ffffffffc0204468:	0585                	addi	a1,a1,1
ffffffffc020446a:	0785                	addi	a5,a5,1
ffffffffc020446c:	fee78fa3          	sb	a4,-1(a5)
    while (n -- > 0) {
ffffffffc0204470:	fec59ae3          	bne	a1,a2,ffffffffc0204464 <memcpy+0x6>
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
ffffffffc0204474:	8082                	ret
