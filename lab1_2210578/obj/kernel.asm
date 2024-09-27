
bin/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080200000 <kern_entry>:
#include <memlayout.h>

    .section .text,"ax",%progbits
    .globl kern_entry
kern_entry:
    la sp, bootstacktop
    80200000:	00004117          	auipc	sp,0x4
    80200004:	00010113          	mv	sp,sp

    tail kern_init
    80200008:	a009                	j	8020000a <kern_init>

000000008020000a <kern_init>:
int kern_init(void) __attribute__((noreturn));
void grade_backtrace(void);

int kern_init(void) {
    extern char edata[], end[];
    memset(edata, 0, end - edata);
    8020000a:	00004517          	auipc	a0,0x4
    8020000e:	00650513          	addi	a0,a0,6 # 80204010 <ticks>
    80200012:	00004617          	auipc	a2,0x4
    80200016:	01660613          	addi	a2,a2,22 # 80204028 <end>
int kern_init(void) {
    8020001a:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
    8020001c:	8e09                	sub	a2,a2,a0
    8020001e:	4581                	li	a1,0
int kern_init(void) {
    80200020:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
    80200022:	1c9000ef          	jal	ra,802009ea <memset>

    cons_init();  // init the console
    80200026:	14a000ef          	jal	ra,80200170 <cons_init>

    const char *message = "(THU.CST) os is loading ...\n";
    cprintf("%s\n\n", message);
    8020002a:	00001597          	auipc	a1,0x1
    8020002e:	9d658593          	addi	a1,a1,-1578 # 80200a00 <etext+0x4>
    80200032:	00001517          	auipc	a0,0x1
    80200036:	9ee50513          	addi	a0,a0,-1554 # 80200a20 <etext+0x24>
    8020003a:	030000ef          	jal	ra,8020006a <cprintf>

    print_kerninfo();
    8020003e:	062000ef          	jal	ra,802000a0 <print_kerninfo>

    // grade_backtrace();

    idt_init();  // init interrupt descriptor table
    80200042:	13e000ef          	jal	ra,80200180 <idt_init>

    // rdtime in mbare mode crashes
    clock_init();  // init clock interrupt
    80200046:	0e8000ef          	jal	ra,8020012e <clock_init>

    intr_enable();  // enable irq interrupt
    8020004a:	130000ef          	jal	ra,8020017a <intr_enable>
    
    while (1)
    8020004e:	a001                	j	8020004e <kern_init+0x44>

0000000080200050 <cputch>:

/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void cputch(int c, int *cnt) {
    80200050:	1141                	addi	sp,sp,-16
    80200052:	e022                	sd	s0,0(sp)
    80200054:	e406                	sd	ra,8(sp)
    80200056:	842e                	mv	s0,a1
    cons_putc(c);
    80200058:	11a000ef          	jal	ra,80200172 <cons_putc>
    (*cnt)++;
    8020005c:	401c                	lw	a5,0(s0)
}
    8020005e:	60a2                	ld	ra,8(sp)
    (*cnt)++;
    80200060:	2785                	addiw	a5,a5,1
    80200062:	c01c                	sw	a5,0(s0)
}
    80200064:	6402                	ld	s0,0(sp)
    80200066:	0141                	addi	sp,sp,16
    80200068:	8082                	ret

000000008020006a <cprintf>:
 * cprintf - formats a string and writes it to stdout
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int cprintf(const char *fmt, ...) {
    8020006a:	711d                	addi	sp,sp,-96
    va_list ap;
    int cnt;
    va_start(ap, fmt);
    8020006c:	02810313          	addi	t1,sp,40 # 80204028 <end>
int cprintf(const char *fmt, ...) {
    80200070:	8e2a                	mv	t3,a0
    80200072:	f42e                	sd	a1,40(sp)
    80200074:	f832                	sd	a2,48(sp)
    80200076:	fc36                	sd	a3,56(sp)
    vprintfmt((void *)cputch, &cnt, fmt, ap);
    80200078:	00000517          	auipc	a0,0x0
    8020007c:	fd850513          	addi	a0,a0,-40 # 80200050 <cputch>
    80200080:	004c                	addi	a1,sp,4
    80200082:	869a                	mv	a3,t1
    80200084:	8672                	mv	a2,t3
int cprintf(const char *fmt, ...) {
    80200086:	ec06                	sd	ra,24(sp)
    80200088:	e0ba                	sd	a4,64(sp)
    8020008a:	e4be                	sd	a5,72(sp)
    8020008c:	e8c2                	sd	a6,80(sp)
    8020008e:	ecc6                	sd	a7,88(sp)
    va_start(ap, fmt);
    80200090:	e41a                	sd	t1,8(sp)
    int cnt = 0;
    80200092:	c202                	sw	zero,4(sp)
    vprintfmt((void *)cputch, &cnt, fmt, ap);
    80200094:	56a000ef          	jal	ra,802005fe <vprintfmt>
    cnt = vcprintf(fmt, ap);
    va_end(ap);
    return cnt;
}
    80200098:	60e2                	ld	ra,24(sp)
    8020009a:	4512                	lw	a0,4(sp)
    8020009c:	6125                	addi	sp,sp,96
    8020009e:	8082                	ret

00000000802000a0 <print_kerninfo>:
/* *
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void print_kerninfo(void) {
    802000a0:	1141                	addi	sp,sp,-16
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
    802000a2:	00001517          	auipc	a0,0x1
    802000a6:	98650513          	addi	a0,a0,-1658 # 80200a28 <etext+0x2c>
void print_kerninfo(void) {
    802000aa:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
    802000ac:	fbfff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  entry  0x%016x (virtual)\n", kern_init);
    802000b0:	00000597          	auipc	a1,0x0
    802000b4:	f5a58593          	addi	a1,a1,-166 # 8020000a <kern_init>
    802000b8:	00001517          	auipc	a0,0x1
    802000bc:	99050513          	addi	a0,a0,-1648 # 80200a48 <etext+0x4c>
    802000c0:	fabff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  etext  0x%016x (virtual)\n", etext);
    802000c4:	00001597          	auipc	a1,0x1
    802000c8:	93858593          	addi	a1,a1,-1736 # 802009fc <etext>
    802000cc:	00001517          	auipc	a0,0x1
    802000d0:	99c50513          	addi	a0,a0,-1636 # 80200a68 <etext+0x6c>
    802000d4:	f97ff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  edata  0x%016x (virtual)\n", edata);
    802000d8:	00004597          	auipc	a1,0x4
    802000dc:	f3858593          	addi	a1,a1,-200 # 80204010 <ticks>
    802000e0:	00001517          	auipc	a0,0x1
    802000e4:	9a850513          	addi	a0,a0,-1624 # 80200a88 <etext+0x8c>
    802000e8:	f83ff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  end    0x%016x (virtual)\n", end);
    802000ec:	00004597          	auipc	a1,0x4
    802000f0:	f3c58593          	addi	a1,a1,-196 # 80204028 <end>
    802000f4:	00001517          	auipc	a0,0x1
    802000f8:	9b450513          	addi	a0,a0,-1612 # 80200aa8 <etext+0xac>
    802000fc:	f6fff0ef          	jal	ra,8020006a <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
    80200100:	00004597          	auipc	a1,0x4
    80200104:	32758593          	addi	a1,a1,807 # 80204427 <end+0x3ff>
    80200108:	00000797          	auipc	a5,0x0
    8020010c:	f0278793          	addi	a5,a5,-254 # 8020000a <kern_init>
    80200110:	40f587b3          	sub	a5,a1,a5
    cprintf("Kernel executable memory footprint: %dKB\n",
    80200114:	43f7d593          	srai	a1,a5,0x3f
}
    80200118:	60a2                	ld	ra,8(sp)
    cprintf("Kernel executable memory footprint: %dKB\n",
    8020011a:	3ff5f593          	andi	a1,a1,1023
    8020011e:	95be                	add	a1,a1,a5
    80200120:	85a9                	srai	a1,a1,0xa
    80200122:	00001517          	auipc	a0,0x1
    80200126:	9a650513          	addi	a0,a0,-1626 # 80200ac8 <etext+0xcc>
}
    8020012a:	0141                	addi	sp,sp,16
    cprintf("Kernel executable memory footprint: %dKB\n",
    8020012c:	bf3d                	j	8020006a <cprintf>

000000008020012e <clock_init>:

/* *
 * clock_init - initialize 8253 clock to interrupt 100 times per second,
 * and then enable IRQ_TIMER.
 * */
void clock_init(void) {
    8020012e:	1141                	addi	sp,sp,-16
    80200130:	e406                	sd	ra,8(sp)
    // enable timer interrupt in sie
    set_csr(sie, MIP_STIP);
    80200132:	02000793          	li	a5,32
    80200136:	1047a7f3          	csrrs	a5,sie,a5
    __asm__ __volatile__("rdtime %0" : "=r"(n));
    8020013a:	c0102573          	rdtime	a0
    ticks = 0;

    cprintf("++ setup timer interrupts\n");
}

void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
    8020013e:	67e1                	lui	a5,0x18
    80200140:	6a078793          	addi	a5,a5,1696 # 186a0 <kern_entry-0x801e7960>
    80200144:	953e                	add	a0,a0,a5
    80200146:	055000ef          	jal	ra,8020099a <sbi_set_timer>
}
    8020014a:	60a2                	ld	ra,8(sp)
    ticks = 0;
    8020014c:	00004797          	auipc	a5,0x4
    80200150:	ec07b223          	sd	zero,-316(a5) # 80204010 <ticks>
    cprintf("++ setup timer interrupts\n");
    80200154:	00001517          	auipc	a0,0x1
    80200158:	9a450513          	addi	a0,a0,-1628 # 80200af8 <etext+0xfc>
}
    8020015c:	0141                	addi	sp,sp,16
    cprintf("++ setup timer interrupts\n");
    8020015e:	b731                	j	8020006a <cprintf>

0000000080200160 <clock_set_next_event>:
    __asm__ __volatile__("rdtime %0" : "=r"(n));
    80200160:	c0102573          	rdtime	a0
void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
    80200164:	67e1                	lui	a5,0x18
    80200166:	6a078793          	addi	a5,a5,1696 # 186a0 <kern_entry-0x801e7960>
    8020016a:	953e                	add	a0,a0,a5
    8020016c:	02f0006f          	j	8020099a <sbi_set_timer>

0000000080200170 <cons_init>:

/* serial_intr - try to feed input characters from serial port */
void serial_intr(void) {}

/* cons_init - initializes the console devices */
void cons_init(void) {}
    80200170:	8082                	ret

0000000080200172 <cons_putc>:

/* cons_putc - print a single character @c to console devices */
void cons_putc(int c) { sbi_console_putchar((unsigned char)c); }
    80200172:	0ff57513          	zext.b	a0,a0
    80200176:	00b0006f          	j	80200980 <sbi_console_putchar>

000000008020017a <intr_enable>:
#include <intr.h>
#include <riscv.h>

/* intr_enable - enable irq interrupt */
void intr_enable(void) { set_csr(sstatus, SSTATUS_SIE); }
    8020017a:	100167f3          	csrrsi	a5,sstatus,2
    8020017e:	8082                	ret

0000000080200180 <idt_init>:
 */
void idt_init(void) {
    extern void __alltraps(void);
    /* Set sscratch register to 0, indicating to exception vector that we are
     * presently executing in the kernel */
    write_csr(sscratch, 0);
    80200180:	14005073          	csrwi	sscratch,0
    /* Set the exception vector address */
    write_csr(stvec, &__alltraps);
    80200184:	00000797          	auipc	a5,0x0
    80200188:	35878793          	addi	a5,a5,856 # 802004dc <__alltraps>
    8020018c:	10579073          	csrw	stvec,a5
}
    80200190:	8082                	ret

0000000080200192 <print_regs>:
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
    cprintf("  cause    0x%08x\n", tf->cause);
}

void print_regs(struct pushregs *gpr) {
    cprintf("  zero     0x%08x\n", gpr->zero);
    80200192:	610c                	ld	a1,0(a0)
void print_regs(struct pushregs *gpr) {
    80200194:	1141                	addi	sp,sp,-16
    80200196:	e022                	sd	s0,0(sp)
    80200198:	842a                	mv	s0,a0
    cprintf("  zero     0x%08x\n", gpr->zero);
    8020019a:	00001517          	auipc	a0,0x1
    8020019e:	97e50513          	addi	a0,a0,-1666 # 80200b18 <etext+0x11c>
void print_regs(struct pushregs *gpr) {
    802001a2:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
    802001a4:	ec7ff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
    802001a8:	640c                	ld	a1,8(s0)
    802001aa:	00001517          	auipc	a0,0x1
    802001ae:	98650513          	addi	a0,a0,-1658 # 80200b30 <etext+0x134>
    802001b2:	eb9ff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
    802001b6:	680c                	ld	a1,16(s0)
    802001b8:	00001517          	auipc	a0,0x1
    802001bc:	99050513          	addi	a0,a0,-1648 # 80200b48 <etext+0x14c>
    802001c0:	eabff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
    802001c4:	6c0c                	ld	a1,24(s0)
    802001c6:	00001517          	auipc	a0,0x1
    802001ca:	99a50513          	addi	a0,a0,-1638 # 80200b60 <etext+0x164>
    802001ce:	e9dff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
    802001d2:	700c                	ld	a1,32(s0)
    802001d4:	00001517          	auipc	a0,0x1
    802001d8:	9a450513          	addi	a0,a0,-1628 # 80200b78 <etext+0x17c>
    802001dc:	e8fff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
    802001e0:	740c                	ld	a1,40(s0)
    802001e2:	00001517          	auipc	a0,0x1
    802001e6:	9ae50513          	addi	a0,a0,-1618 # 80200b90 <etext+0x194>
    802001ea:	e81ff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
    802001ee:	780c                	ld	a1,48(s0)
    802001f0:	00001517          	auipc	a0,0x1
    802001f4:	9b850513          	addi	a0,a0,-1608 # 80200ba8 <etext+0x1ac>
    802001f8:	e73ff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
    802001fc:	7c0c                	ld	a1,56(s0)
    802001fe:	00001517          	auipc	a0,0x1
    80200202:	9c250513          	addi	a0,a0,-1598 # 80200bc0 <etext+0x1c4>
    80200206:	e65ff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
    8020020a:	602c                	ld	a1,64(s0)
    8020020c:	00001517          	auipc	a0,0x1
    80200210:	9cc50513          	addi	a0,a0,-1588 # 80200bd8 <etext+0x1dc>
    80200214:	e57ff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
    80200218:	642c                	ld	a1,72(s0)
    8020021a:	00001517          	auipc	a0,0x1
    8020021e:	9d650513          	addi	a0,a0,-1578 # 80200bf0 <etext+0x1f4>
    80200222:	e49ff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
    80200226:	682c                	ld	a1,80(s0)
    80200228:	00001517          	auipc	a0,0x1
    8020022c:	9e050513          	addi	a0,a0,-1568 # 80200c08 <etext+0x20c>
    80200230:	e3bff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
    80200234:	6c2c                	ld	a1,88(s0)
    80200236:	00001517          	auipc	a0,0x1
    8020023a:	9ea50513          	addi	a0,a0,-1558 # 80200c20 <etext+0x224>
    8020023e:	e2dff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
    80200242:	702c                	ld	a1,96(s0)
    80200244:	00001517          	auipc	a0,0x1
    80200248:	9f450513          	addi	a0,a0,-1548 # 80200c38 <etext+0x23c>
    8020024c:	e1fff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
    80200250:	742c                	ld	a1,104(s0)
    80200252:	00001517          	auipc	a0,0x1
    80200256:	9fe50513          	addi	a0,a0,-1538 # 80200c50 <etext+0x254>
    8020025a:	e11ff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
    8020025e:	782c                	ld	a1,112(s0)
    80200260:	00001517          	auipc	a0,0x1
    80200264:	a0850513          	addi	a0,a0,-1528 # 80200c68 <etext+0x26c>
    80200268:	e03ff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
    8020026c:	7c2c                	ld	a1,120(s0)
    8020026e:	00001517          	auipc	a0,0x1
    80200272:	a1250513          	addi	a0,a0,-1518 # 80200c80 <etext+0x284>
    80200276:	df5ff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
    8020027a:	604c                	ld	a1,128(s0)
    8020027c:	00001517          	auipc	a0,0x1
    80200280:	a1c50513          	addi	a0,a0,-1508 # 80200c98 <etext+0x29c>
    80200284:	de7ff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
    80200288:	644c                	ld	a1,136(s0)
    8020028a:	00001517          	auipc	a0,0x1
    8020028e:	a2650513          	addi	a0,a0,-1498 # 80200cb0 <etext+0x2b4>
    80200292:	dd9ff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
    80200296:	684c                	ld	a1,144(s0)
    80200298:	00001517          	auipc	a0,0x1
    8020029c:	a3050513          	addi	a0,a0,-1488 # 80200cc8 <etext+0x2cc>
    802002a0:	dcbff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
    802002a4:	6c4c                	ld	a1,152(s0)
    802002a6:	00001517          	auipc	a0,0x1
    802002aa:	a3a50513          	addi	a0,a0,-1478 # 80200ce0 <etext+0x2e4>
    802002ae:	dbdff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
    802002b2:	704c                	ld	a1,160(s0)
    802002b4:	00001517          	auipc	a0,0x1
    802002b8:	a4450513          	addi	a0,a0,-1468 # 80200cf8 <etext+0x2fc>
    802002bc:	dafff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
    802002c0:	744c                	ld	a1,168(s0)
    802002c2:	00001517          	auipc	a0,0x1
    802002c6:	a4e50513          	addi	a0,a0,-1458 # 80200d10 <etext+0x314>
    802002ca:	da1ff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
    802002ce:	784c                	ld	a1,176(s0)
    802002d0:	00001517          	auipc	a0,0x1
    802002d4:	a5850513          	addi	a0,a0,-1448 # 80200d28 <etext+0x32c>
    802002d8:	d93ff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
    802002dc:	7c4c                	ld	a1,184(s0)
    802002de:	00001517          	auipc	a0,0x1
    802002e2:	a6250513          	addi	a0,a0,-1438 # 80200d40 <etext+0x344>
    802002e6:	d85ff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
    802002ea:	606c                	ld	a1,192(s0)
    802002ec:	00001517          	auipc	a0,0x1
    802002f0:	a6c50513          	addi	a0,a0,-1428 # 80200d58 <etext+0x35c>
    802002f4:	d77ff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
    802002f8:	646c                	ld	a1,200(s0)
    802002fa:	00001517          	auipc	a0,0x1
    802002fe:	a7650513          	addi	a0,a0,-1418 # 80200d70 <etext+0x374>
    80200302:	d69ff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
    80200306:	686c                	ld	a1,208(s0)
    80200308:	00001517          	auipc	a0,0x1
    8020030c:	a8050513          	addi	a0,a0,-1408 # 80200d88 <etext+0x38c>
    80200310:	d5bff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
    80200314:	6c6c                	ld	a1,216(s0)
    80200316:	00001517          	auipc	a0,0x1
    8020031a:	a8a50513          	addi	a0,a0,-1398 # 80200da0 <etext+0x3a4>
    8020031e:	d4dff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
    80200322:	706c                	ld	a1,224(s0)
    80200324:	00001517          	auipc	a0,0x1
    80200328:	a9450513          	addi	a0,a0,-1388 # 80200db8 <etext+0x3bc>
    8020032c:	d3fff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
    80200330:	746c                	ld	a1,232(s0)
    80200332:	00001517          	auipc	a0,0x1
    80200336:	a9e50513          	addi	a0,a0,-1378 # 80200dd0 <etext+0x3d4>
    8020033a:	d31ff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
    8020033e:	786c                	ld	a1,240(s0)
    80200340:	00001517          	auipc	a0,0x1
    80200344:	aa850513          	addi	a0,a0,-1368 # 80200de8 <etext+0x3ec>
    80200348:	d23ff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
    8020034c:	7c6c                	ld	a1,248(s0)
}
    8020034e:	6402                	ld	s0,0(sp)
    80200350:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
    80200352:	00001517          	auipc	a0,0x1
    80200356:	aae50513          	addi	a0,a0,-1362 # 80200e00 <etext+0x404>
}
    8020035a:	0141                	addi	sp,sp,16
    cprintf("  t6       0x%08x\n", gpr->t6);
    8020035c:	b339                	j	8020006a <cprintf>

000000008020035e <print_trapframe>:
void print_trapframe(struct trapframe *tf) {
    8020035e:	1141                	addi	sp,sp,-16
    80200360:	e022                	sd	s0,0(sp)
    cprintf("trapframe at %p\n", tf);
    80200362:	85aa                	mv	a1,a0
void print_trapframe(struct trapframe *tf) {
    80200364:	842a                	mv	s0,a0
    cprintf("trapframe at %p\n", tf);
    80200366:	00001517          	auipc	a0,0x1
    8020036a:	ab250513          	addi	a0,a0,-1358 # 80200e18 <etext+0x41c>
void print_trapframe(struct trapframe *tf) {
    8020036e:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
    80200370:	cfbff0ef          	jal	ra,8020006a <cprintf>
    print_regs(&tf->gpr);
    80200374:	8522                	mv	a0,s0
    80200376:	e1dff0ef          	jal	ra,80200192 <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
    8020037a:	10043583          	ld	a1,256(s0)
    8020037e:	00001517          	auipc	a0,0x1
    80200382:	ab250513          	addi	a0,a0,-1358 # 80200e30 <etext+0x434>
    80200386:	ce5ff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
    8020038a:	10843583          	ld	a1,264(s0)
    8020038e:	00001517          	auipc	a0,0x1
    80200392:	aba50513          	addi	a0,a0,-1350 # 80200e48 <etext+0x44c>
    80200396:	cd5ff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
    8020039a:	11043583          	ld	a1,272(s0)
    8020039e:	00001517          	auipc	a0,0x1
    802003a2:	ac250513          	addi	a0,a0,-1342 # 80200e60 <etext+0x464>
    802003a6:	cc5ff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
    802003aa:	11843583          	ld	a1,280(s0)
}
    802003ae:	6402                	ld	s0,0(sp)
    802003b0:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
    802003b2:	00001517          	auipc	a0,0x1
    802003b6:	ac650513          	addi	a0,a0,-1338 # 80200e78 <etext+0x47c>
}
    802003ba:	0141                	addi	sp,sp,16
    cprintf("  cause    0x%08x\n", tf->cause);
    802003bc:	b17d                	j	8020006a <cprintf>

00000000802003be <interrupt_handler>:

void interrupt_handler(struct trapframe *tf) {
    intptr_t cause = (tf->cause << 1) >> 1;
    802003be:	11853783          	ld	a5,280(a0)
    802003c2:	472d                	li	a4,11
    802003c4:	0786                	slli	a5,a5,0x1
    802003c6:	8385                	srli	a5,a5,0x1
    802003c8:	08f76163          	bltu	a4,a5,8020044a <interrupt_handler+0x8c>
    802003cc:	00001717          	auipc	a4,0x1
    802003d0:	b7470713          	addi	a4,a4,-1164 # 80200f40 <etext+0x544>
    802003d4:	078a                	slli	a5,a5,0x2
    802003d6:	97ba                	add	a5,a5,a4
    802003d8:	439c                	lw	a5,0(a5)
    802003da:	97ba                	add	a5,a5,a4
    802003dc:	8782                	jr	a5
            break;
        case IRQ_H_SOFT:
            cprintf("Hypervisor software interrupt\n");
            break;
        case IRQ_M_SOFT:
            cprintf("Machine software interrupt\n");
    802003de:	00001517          	auipc	a0,0x1
    802003e2:	b1250513          	addi	a0,a0,-1262 # 80200ef0 <etext+0x4f4>
    802003e6:	b151                	j	8020006a <cprintf>
            cprintf("Hypervisor software interrupt\n");
    802003e8:	00001517          	auipc	a0,0x1
    802003ec:	ae850513          	addi	a0,a0,-1304 # 80200ed0 <etext+0x4d4>
    802003f0:	b9ad                	j	8020006a <cprintf>
            cprintf("User software interrupt\n");
    802003f2:	00001517          	auipc	a0,0x1
    802003f6:	a9e50513          	addi	a0,a0,-1378 # 80200e90 <etext+0x494>
    802003fa:	b985                	j	8020006a <cprintf>
            cprintf("Supervisor software interrupt\n");
    802003fc:	00001517          	auipc	a0,0x1
    80200400:	ab450513          	addi	a0,a0,-1356 # 80200eb0 <etext+0x4b4>
    80200404:	b19d                	j	8020006a <cprintf>
void interrupt_handler(struct trapframe *tf) {
    80200406:	1141                	addi	sp,sp,-16
    80200408:	e022                	sd	s0,0(sp)
    8020040a:	e406                	sd	ra,8(sp)
            /*(1)设置下次时钟中断- clock_set_next_event()
             *(2)计数器（ticks）加一
             *(3)当计数器加到100的时候，我们会输出一个`100ticks`表示我们触发了100次时钟中断，同时打印次数（num）加一
            * (4)判断打印次数，当打印次数为10时，调用<sbi.h>中的关机函数关机
            */
            clock_set_next_event();//发 生 这 次 时 钟 中 断 的 时 候 ， 我 们 要 设 置 下 一 次 时 钟 中 断
    8020040c:	d55ff0ef          	jal	ra,80200160 <clock_set_next_event>
	    if (++ticks % TICK_NUM == 0) { //计数器加一
    80200410:	00004697          	auipc	a3,0x4
    80200414:	c0068693          	addi	a3,a3,-1024 # 80204010 <ticks>
    80200418:	629c                	ld	a5,0(a3)
    8020041a:	06400713          	li	a4,100
    8020041e:	00004417          	auipc	s0,0x4
    80200422:	bfa40413          	addi	s0,s0,-1030 # 80204018 <num>
    80200426:	0785                	addi	a5,a5,1
    80200428:	02e7f733          	remu	a4,a5,a4
    8020042c:	e29c                	sd	a5,0(a3)
    8020042e:	cf19                	beqz	a4,8020044c <interrupt_handler+0x8e>
	    	print_ticks();
	    	num += 1;  //打印次数加一
	    }		
	    if (num == 10){
    80200430:	6018                	ld	a4,0(s0)
    80200432:	47a9                	li	a5,10
    80200434:	02f70863          	beq	a4,a5,80200464 <interrupt_handler+0xa6>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
    80200438:	60a2                	ld	ra,8(sp)
    8020043a:	6402                	ld	s0,0(sp)
    8020043c:	0141                	addi	sp,sp,16
    8020043e:	8082                	ret
            cprintf("Supervisor external interrupt\n");
    80200440:	00001517          	auipc	a0,0x1
    80200444:	ae050513          	addi	a0,a0,-1312 # 80200f20 <etext+0x524>
    80200448:	b10d                	j	8020006a <cprintf>
            print_trapframe(tf);
    8020044a:	bf11                	j	8020035e <print_trapframe>
    cprintf("%d ticks\n", TICK_NUM);
    8020044c:	06400593          	li	a1,100
    80200450:	00001517          	auipc	a0,0x1
    80200454:	ac050513          	addi	a0,a0,-1344 # 80200f10 <etext+0x514>
    80200458:	c13ff0ef          	jal	ra,8020006a <cprintf>
	    	num += 1;  //打印次数加一
    8020045c:	601c                	ld	a5,0(s0)
    8020045e:	0785                	addi	a5,a5,1
    80200460:	e01c                	sd	a5,0(s0)
    80200462:	b7f9                	j	80200430 <interrupt_handler+0x72>
}
    80200464:	6402                	ld	s0,0(sp)
    80200466:	60a2                	ld	ra,8(sp)
    80200468:	0141                	addi	sp,sp,16
	       sbi_shutdown();  //调用关机函数关机
    8020046a:	a3a9                	j	802009b4 <sbi_shutdown>

000000008020046c <exception_handler>:

void exception_handler(struct trapframe *tf) {
    switch (tf->cause) {
    8020046c:	11853783          	ld	a5,280(a0)
void exception_handler(struct trapframe *tf) {
    80200470:	1141                	addi	sp,sp,-16
    80200472:	e022                	sd	s0,0(sp)
    80200474:	e406                	sd	ra,8(sp)
    switch (tf->cause) {
    80200476:	470d                	li	a4,3
void exception_handler(struct trapframe *tf) {
    80200478:	842a                	mv	s0,a0
    switch (tf->cause) {
    8020047a:	04e78663          	beq	a5,a4,802004c6 <exception_handler+0x5a>
    8020047e:	02f76c63          	bltu	a4,a5,802004b6 <exception_handler+0x4a>
    80200482:	4709                	li	a4,2
             /* LAB1 CHALLENGE3   2210578 :  */
            /*(1)输出指令异常类型（ Illegal instruction）
             *(2)输出异常指令地址
             *(3)更新 tf->epc寄存器
            */
            cprintf("Illegal instruction\n");
    80200484:	00001517          	auipc	a0,0x1
    80200488:	aec50513          	addi	a0,a0,-1300 # 80200f70 <etext+0x574>
    switch (tf->cause) {
    8020048c:	02e79163          	bne	a5,a4,802004ae <exception_handler+0x42>
            /* LAB1 CHALLLENGE3   2210578 :  */
            /*(1)输出指令异常类型（ breakpoint）
             *(2)输出异常指令地址
             *(3)更新 tf->epc寄存器
            */
            cprintf("breakpoint\n");
    80200490:	bdbff0ef          	jal	ra,8020006a <cprintf>
            cprintf("Exception instruction address: 0x%x\n", tf->epc);
    80200494:	10843583          	ld	a1,264(s0)
    80200498:	00001517          	auipc	a0,0x1
    8020049c:	af050513          	addi	a0,a0,-1296 # 80200f88 <etext+0x58c>
    802004a0:	bcbff0ef          	jal	ra,8020006a <cprintf>
            tf->epc += 4;
    802004a4:	10843783          	ld	a5,264(s0)
    802004a8:	0791                	addi	a5,a5,4
    802004aa:	10f43423          	sd	a5,264(s0)
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
    802004ae:	60a2                	ld	ra,8(sp)
    802004b0:	6402                	ld	s0,0(sp)
    802004b2:	0141                	addi	sp,sp,16
    802004b4:	8082                	ret
    switch (tf->cause) {
    802004b6:	17f1                	addi	a5,a5,-4
    802004b8:	471d                	li	a4,7
    802004ba:	fef77ae3          	bgeu	a4,a5,802004ae <exception_handler+0x42>
}
    802004be:	6402                	ld	s0,0(sp)
    802004c0:	60a2                	ld	ra,8(sp)
    802004c2:	0141                	addi	sp,sp,16
            print_trapframe(tf);
    802004c4:	bd69                	j	8020035e <print_trapframe>
            cprintf("breakpoint\n");
    802004c6:	00001517          	auipc	a0,0x1
    802004ca:	aea50513          	addi	a0,a0,-1302 # 80200fb0 <etext+0x5b4>
    802004ce:	b7c9                	j	80200490 <exception_handler+0x24>

00000000802004d0 <trap>:

/* trap_dispatch - dispatch based on what type of trap occurred */
static inline void trap_dispatch(struct trapframe *tf) {
    if ((intptr_t)tf->cause < 0) {
    802004d0:	11853783          	ld	a5,280(a0)
    802004d4:	0007c363          	bltz	a5,802004da <trap+0xa>
        // interrupts
        interrupt_handler(tf);
    } else {
        // exceptions
        exception_handler(tf);
    802004d8:	bf51                	j	8020046c <exception_handler>
        interrupt_handler(tf);
    802004da:	b5d5                	j	802003be <interrupt_handler>

00000000802004dc <__alltraps>:
    .endm

    .globl __alltraps
.align(2)
__alltraps:
    SAVE_ALL
    802004dc:	14011073          	csrw	sscratch,sp
    802004e0:	712d                	addi	sp,sp,-288
    802004e2:	e002                	sd	zero,0(sp)
    802004e4:	e406                	sd	ra,8(sp)
    802004e6:	ec0e                	sd	gp,24(sp)
    802004e8:	f012                	sd	tp,32(sp)
    802004ea:	f416                	sd	t0,40(sp)
    802004ec:	f81a                	sd	t1,48(sp)
    802004ee:	fc1e                	sd	t2,56(sp)
    802004f0:	e0a2                	sd	s0,64(sp)
    802004f2:	e4a6                	sd	s1,72(sp)
    802004f4:	e8aa                	sd	a0,80(sp)
    802004f6:	ecae                	sd	a1,88(sp)
    802004f8:	f0b2                	sd	a2,96(sp)
    802004fa:	f4b6                	sd	a3,104(sp)
    802004fc:	f8ba                	sd	a4,112(sp)
    802004fe:	fcbe                	sd	a5,120(sp)
    80200500:	e142                	sd	a6,128(sp)
    80200502:	e546                	sd	a7,136(sp)
    80200504:	e94a                	sd	s2,144(sp)
    80200506:	ed4e                	sd	s3,152(sp)
    80200508:	f152                	sd	s4,160(sp)
    8020050a:	f556                	sd	s5,168(sp)
    8020050c:	f95a                	sd	s6,176(sp)
    8020050e:	fd5e                	sd	s7,184(sp)
    80200510:	e1e2                	sd	s8,192(sp)
    80200512:	e5e6                	sd	s9,200(sp)
    80200514:	e9ea                	sd	s10,208(sp)
    80200516:	edee                	sd	s11,216(sp)
    80200518:	f1f2                	sd	t3,224(sp)
    8020051a:	f5f6                	sd	t4,232(sp)
    8020051c:	f9fa                	sd	t5,240(sp)
    8020051e:	fdfe                	sd	t6,248(sp)
    80200520:	14001473          	csrrw	s0,sscratch,zero
    80200524:	100024f3          	csrr	s1,sstatus
    80200528:	14102973          	csrr	s2,sepc
    8020052c:	143029f3          	csrr	s3,stval
    80200530:	14202a73          	csrr	s4,scause
    80200534:	e822                	sd	s0,16(sp)
    80200536:	e226                	sd	s1,256(sp)
    80200538:	e64a                	sd	s2,264(sp)
    8020053a:	ea4e                	sd	s3,272(sp)
    8020053c:	ee52                	sd	s4,280(sp)

    move  a0, sp
    8020053e:	850a                	mv	a0,sp
    jal trap
    80200540:	f91ff0ef          	jal	ra,802004d0 <trap>

0000000080200544 <__trapret>:
    # sp should be the same as before "jal trap"

    .globl __trapret
__trapret:
    RESTORE_ALL
    80200544:	6492                	ld	s1,256(sp)
    80200546:	6932                	ld	s2,264(sp)
    80200548:	10049073          	csrw	sstatus,s1
    8020054c:	14191073          	csrw	sepc,s2
    80200550:	60a2                	ld	ra,8(sp)
    80200552:	61e2                	ld	gp,24(sp)
    80200554:	7202                	ld	tp,32(sp)
    80200556:	72a2                	ld	t0,40(sp)
    80200558:	7342                	ld	t1,48(sp)
    8020055a:	73e2                	ld	t2,56(sp)
    8020055c:	6406                	ld	s0,64(sp)
    8020055e:	64a6                	ld	s1,72(sp)
    80200560:	6546                	ld	a0,80(sp)
    80200562:	65e6                	ld	a1,88(sp)
    80200564:	7606                	ld	a2,96(sp)
    80200566:	76a6                	ld	a3,104(sp)
    80200568:	7746                	ld	a4,112(sp)
    8020056a:	77e6                	ld	a5,120(sp)
    8020056c:	680a                	ld	a6,128(sp)
    8020056e:	68aa                	ld	a7,136(sp)
    80200570:	694a                	ld	s2,144(sp)
    80200572:	69ea                	ld	s3,152(sp)
    80200574:	7a0a                	ld	s4,160(sp)
    80200576:	7aaa                	ld	s5,168(sp)
    80200578:	7b4a                	ld	s6,176(sp)
    8020057a:	7bea                	ld	s7,184(sp)
    8020057c:	6c0e                	ld	s8,192(sp)
    8020057e:	6cae                	ld	s9,200(sp)
    80200580:	6d4e                	ld	s10,208(sp)
    80200582:	6dee                	ld	s11,216(sp)
    80200584:	7e0e                	ld	t3,224(sp)
    80200586:	7eae                	ld	t4,232(sp)
    80200588:	7f4e                	ld	t5,240(sp)
    8020058a:	7fee                	ld	t6,248(sp)
    8020058c:	6142                	ld	sp,16(sp)
    # return from supervisor call
    sret
    8020058e:	10200073          	sret

0000000080200592 <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
    80200592:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
    80200596:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
    80200598:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
    8020059c:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
    8020059e:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
    802005a2:	f022                	sd	s0,32(sp)
    802005a4:	ec26                	sd	s1,24(sp)
    802005a6:	e84a                	sd	s2,16(sp)
    802005a8:	f406                	sd	ra,40(sp)
    802005aa:	e44e                	sd	s3,8(sp)
    802005ac:	84aa                	mv	s1,a0
    802005ae:	892e                	mv	s2,a1
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
    802005b0:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
    802005b4:	2a01                	sext.w	s4,s4
    if (num >= base) {
    802005b6:	03067e63          	bgeu	a2,a6,802005f2 <printnum+0x60>
    802005ba:	89be                	mv	s3,a5
        while (-- width > 0)
    802005bc:	00805763          	blez	s0,802005ca <printnum+0x38>
    802005c0:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
    802005c2:	85ca                	mv	a1,s2
    802005c4:	854e                	mv	a0,s3
    802005c6:	9482                	jalr	s1
        while (-- width > 0)
    802005c8:	fc65                	bnez	s0,802005c0 <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
    802005ca:	1a02                	slli	s4,s4,0x20
    802005cc:	00001797          	auipc	a5,0x1
    802005d0:	9f478793          	addi	a5,a5,-1548 # 80200fc0 <etext+0x5c4>
    802005d4:	020a5a13          	srli	s4,s4,0x20
    802005d8:	9a3e                	add	s4,s4,a5
}
    802005da:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
    802005dc:	000a4503          	lbu	a0,0(s4)
}
    802005e0:	70a2                	ld	ra,40(sp)
    802005e2:	69a2                	ld	s3,8(sp)
    802005e4:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
    802005e6:	85ca                	mv	a1,s2
    802005e8:	87a6                	mv	a5,s1
}
    802005ea:	6942                	ld	s2,16(sp)
    802005ec:	64e2                	ld	s1,24(sp)
    802005ee:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
    802005f0:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
    802005f2:	03065633          	divu	a2,a2,a6
    802005f6:	8722                	mv	a4,s0
    802005f8:	f9bff0ef          	jal	ra,80200592 <printnum>
    802005fc:	b7f9                	j	802005ca <printnum+0x38>

00000000802005fe <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
    802005fe:	7119                	addi	sp,sp,-128
    80200600:	f4a6                	sd	s1,104(sp)
    80200602:	f0ca                	sd	s2,96(sp)
    80200604:	ecce                	sd	s3,88(sp)
    80200606:	e8d2                	sd	s4,80(sp)
    80200608:	e4d6                	sd	s5,72(sp)
    8020060a:	e0da                	sd	s6,64(sp)
    8020060c:	fc5e                	sd	s7,56(sp)
    8020060e:	f06a                	sd	s10,32(sp)
    80200610:	fc86                	sd	ra,120(sp)
    80200612:	f8a2                	sd	s0,112(sp)
    80200614:	f862                	sd	s8,48(sp)
    80200616:	f466                	sd	s9,40(sp)
    80200618:	ec6e                	sd	s11,24(sp)
    8020061a:	892a                	mv	s2,a0
    8020061c:	84ae                	mv	s1,a1
    8020061e:	8d32                	mv	s10,a2
    80200620:	8a36                	mv	s4,a3
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
    80200622:	02500993          	li	s3,37
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
    80200626:	5b7d                	li	s6,-1
    80200628:	00001a97          	auipc	s5,0x1
    8020062c:	9cca8a93          	addi	s5,s5,-1588 # 80200ff4 <etext+0x5f8>
        case 'e':
            err = va_arg(ap, int);
            if (err < 0) {
                err = -err;
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
    80200630:	00001b97          	auipc	s7,0x1
    80200634:	ba0b8b93          	addi	s7,s7,-1120 # 802011d0 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
    80200638:	000d4503          	lbu	a0,0(s10)
    8020063c:	001d0413          	addi	s0,s10,1
    80200640:	01350a63          	beq	a0,s3,80200654 <vprintfmt+0x56>
            if (ch == '\0') {
    80200644:	c121                	beqz	a0,80200684 <vprintfmt+0x86>
            putch(ch, putdat);
    80200646:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
    80200648:	0405                	addi	s0,s0,1
            putch(ch, putdat);
    8020064a:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
    8020064c:	fff44503          	lbu	a0,-1(s0)
    80200650:	ff351ae3          	bne	a0,s3,80200644 <vprintfmt+0x46>
        switch (ch = *(unsigned char *)fmt ++) {
    80200654:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
    80200658:	02000793          	li	a5,32
        lflag = altflag = 0;
    8020065c:	4c81                	li	s9,0
    8020065e:	4881                	li	a7,0
        width = precision = -1;
    80200660:	5c7d                	li	s8,-1
    80200662:	5dfd                	li	s11,-1
    80200664:	05500513          	li	a0,85
                if (ch < '0' || ch > '9') {
    80200668:	4825                	li	a6,9
        switch (ch = *(unsigned char *)fmt ++) {
    8020066a:	fdd6059b          	addiw	a1,a2,-35
    8020066e:	0ff5f593          	zext.b	a1,a1
    80200672:	00140d13          	addi	s10,s0,1
    80200676:	04b56263          	bltu	a0,a1,802006ba <vprintfmt+0xbc>
    8020067a:	058a                	slli	a1,a1,0x2
    8020067c:	95d6                	add	a1,a1,s5
    8020067e:	4194                	lw	a3,0(a1)
    80200680:	96d6                	add	a3,a3,s5
    80200682:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
    80200684:	70e6                	ld	ra,120(sp)
    80200686:	7446                	ld	s0,112(sp)
    80200688:	74a6                	ld	s1,104(sp)
    8020068a:	7906                	ld	s2,96(sp)
    8020068c:	69e6                	ld	s3,88(sp)
    8020068e:	6a46                	ld	s4,80(sp)
    80200690:	6aa6                	ld	s5,72(sp)
    80200692:	6b06                	ld	s6,64(sp)
    80200694:	7be2                	ld	s7,56(sp)
    80200696:	7c42                	ld	s8,48(sp)
    80200698:	7ca2                	ld	s9,40(sp)
    8020069a:	7d02                	ld	s10,32(sp)
    8020069c:	6de2                	ld	s11,24(sp)
    8020069e:	6109                	addi	sp,sp,128
    802006a0:	8082                	ret
            padc = '0';
    802006a2:	87b2                	mv	a5,a2
            goto reswitch;
    802006a4:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
    802006a8:	846a                	mv	s0,s10
    802006aa:	00140d13          	addi	s10,s0,1
    802006ae:	fdd6059b          	addiw	a1,a2,-35
    802006b2:	0ff5f593          	zext.b	a1,a1
    802006b6:	fcb572e3          	bgeu	a0,a1,8020067a <vprintfmt+0x7c>
            putch('%', putdat);
    802006ba:	85a6                	mv	a1,s1
    802006bc:	02500513          	li	a0,37
    802006c0:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
    802006c2:	fff44783          	lbu	a5,-1(s0)
    802006c6:	8d22                	mv	s10,s0
    802006c8:	f73788e3          	beq	a5,s3,80200638 <vprintfmt+0x3a>
    802006cc:	ffed4783          	lbu	a5,-2(s10)
    802006d0:	1d7d                	addi	s10,s10,-1
    802006d2:	ff379de3          	bne	a5,s3,802006cc <vprintfmt+0xce>
    802006d6:	b78d                	j	80200638 <vprintfmt+0x3a>
                precision = precision * 10 + ch - '0';
    802006d8:	fd060c1b          	addiw	s8,a2,-48
                ch = *fmt;
    802006dc:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
    802006e0:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
    802006e2:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
    802006e6:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
    802006ea:	02d86463          	bltu	a6,a3,80200712 <vprintfmt+0x114>
                ch = *fmt;
    802006ee:	00144603          	lbu	a2,1(s0)
                precision = precision * 10 + ch - '0';
    802006f2:	002c169b          	slliw	a3,s8,0x2
    802006f6:	0186873b          	addw	a4,a3,s8
    802006fa:	0017171b          	slliw	a4,a4,0x1
    802006fe:	9f2d                	addw	a4,a4,a1
                if (ch < '0' || ch > '9') {
    80200700:	fd06069b          	addiw	a3,a2,-48
            for (precision = 0; ; ++ fmt) {
    80200704:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
    80200706:	fd070c1b          	addiw	s8,a4,-48
                ch = *fmt;
    8020070a:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
    8020070e:	fed870e3          	bgeu	a6,a3,802006ee <vprintfmt+0xf0>
            if (width < 0)
    80200712:	f40ddce3          	bgez	s11,8020066a <vprintfmt+0x6c>
                width = precision, precision = -1;
    80200716:	8de2                	mv	s11,s8
    80200718:	5c7d                	li	s8,-1
    8020071a:	bf81                	j	8020066a <vprintfmt+0x6c>
            if (width < 0)
    8020071c:	fffdc693          	not	a3,s11
    80200720:	96fd                	srai	a3,a3,0x3f
    80200722:	00ddfdb3          	and	s11,s11,a3
        switch (ch = *(unsigned char *)fmt ++) {
    80200726:	00144603          	lbu	a2,1(s0)
    8020072a:	2d81                	sext.w	s11,s11
    8020072c:	846a                	mv	s0,s10
            goto reswitch;
    8020072e:	bf35                	j	8020066a <vprintfmt+0x6c>
            precision = va_arg(ap, int);
    80200730:	000a2c03          	lw	s8,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
    80200734:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
    80200738:	0a21                	addi	s4,s4,8
        switch (ch = *(unsigned char *)fmt ++) {
    8020073a:	846a                	mv	s0,s10
            goto process_precision;
    8020073c:	bfd9                	j	80200712 <vprintfmt+0x114>
    if (lflag >= 2) {
    8020073e:	4705                	li	a4,1
            precision = va_arg(ap, int);
    80200740:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
    80200744:	01174463          	blt	a4,a7,8020074c <vprintfmt+0x14e>
    else if (lflag) {
    80200748:	1a088e63          	beqz	a7,80200904 <vprintfmt+0x306>
        return va_arg(*ap, unsigned long);
    8020074c:	000a3603          	ld	a2,0(s4)
    80200750:	46c1                	li	a3,16
    80200752:	8a2e                	mv	s4,a1
            printnum(putch, putdat, num, base, width, padc);
    80200754:	2781                	sext.w	a5,a5
    80200756:	876e                	mv	a4,s11
    80200758:	85a6                	mv	a1,s1
    8020075a:	854a                	mv	a0,s2
    8020075c:	e37ff0ef          	jal	ra,80200592 <printnum>
            break;
    80200760:	bde1                	j	80200638 <vprintfmt+0x3a>
            putch(va_arg(ap, int), putdat);
    80200762:	000a2503          	lw	a0,0(s4)
    80200766:	85a6                	mv	a1,s1
    80200768:	0a21                	addi	s4,s4,8
    8020076a:	9902                	jalr	s2
            break;
    8020076c:	b5f1                	j	80200638 <vprintfmt+0x3a>
    if (lflag >= 2) {
    8020076e:	4705                	li	a4,1
            precision = va_arg(ap, int);
    80200770:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
    80200774:	01174463          	blt	a4,a7,8020077c <vprintfmt+0x17e>
    else if (lflag) {
    80200778:	18088163          	beqz	a7,802008fa <vprintfmt+0x2fc>
        return va_arg(*ap, unsigned long);
    8020077c:	000a3603          	ld	a2,0(s4)
    80200780:	46a9                	li	a3,10
    80200782:	8a2e                	mv	s4,a1
    80200784:	bfc1                	j	80200754 <vprintfmt+0x156>
        switch (ch = *(unsigned char *)fmt ++) {
    80200786:	00144603          	lbu	a2,1(s0)
            altflag = 1;
    8020078a:	4c85                	li	s9,1
        switch (ch = *(unsigned char *)fmt ++) {
    8020078c:	846a                	mv	s0,s10
            goto reswitch;
    8020078e:	bdf1                	j	8020066a <vprintfmt+0x6c>
            putch(ch, putdat);
    80200790:	85a6                	mv	a1,s1
    80200792:	02500513          	li	a0,37
    80200796:	9902                	jalr	s2
            break;
    80200798:	b545                	j	80200638 <vprintfmt+0x3a>
        switch (ch = *(unsigned char *)fmt ++) {
    8020079a:	00144603          	lbu	a2,1(s0)
            lflag ++;
    8020079e:	2885                	addiw	a7,a7,1
        switch (ch = *(unsigned char *)fmt ++) {
    802007a0:	846a                	mv	s0,s10
            goto reswitch;
    802007a2:	b5e1                	j	8020066a <vprintfmt+0x6c>
    if (lflag >= 2) {
    802007a4:	4705                	li	a4,1
            precision = va_arg(ap, int);
    802007a6:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
    802007aa:	01174463          	blt	a4,a7,802007b2 <vprintfmt+0x1b4>
    else if (lflag) {
    802007ae:	14088163          	beqz	a7,802008f0 <vprintfmt+0x2f2>
        return va_arg(*ap, unsigned long);
    802007b2:	000a3603          	ld	a2,0(s4)
    802007b6:	46a1                	li	a3,8
    802007b8:	8a2e                	mv	s4,a1
    802007ba:	bf69                	j	80200754 <vprintfmt+0x156>
            putch('0', putdat);
    802007bc:	03000513          	li	a0,48
    802007c0:	85a6                	mv	a1,s1
    802007c2:	e03e                	sd	a5,0(sp)
    802007c4:	9902                	jalr	s2
            putch('x', putdat);
    802007c6:	85a6                	mv	a1,s1
    802007c8:	07800513          	li	a0,120
    802007cc:	9902                	jalr	s2
            num = (unsigned long long)va_arg(ap, void *);
    802007ce:	0a21                	addi	s4,s4,8
            goto number;
    802007d0:	6782                	ld	a5,0(sp)
    802007d2:	46c1                	li	a3,16
            num = (unsigned long long)va_arg(ap, void *);
    802007d4:	ff8a3603          	ld	a2,-8(s4)
            goto number;
    802007d8:	bfb5                	j	80200754 <vprintfmt+0x156>
            if ((p = va_arg(ap, char *)) == NULL) {
    802007da:	000a3403          	ld	s0,0(s4)
    802007de:	008a0713          	addi	a4,s4,8
    802007e2:	e03a                	sd	a4,0(sp)
    802007e4:	14040263          	beqz	s0,80200928 <vprintfmt+0x32a>
            if (width > 0 && padc != '-') {
    802007e8:	0fb05763          	blez	s11,802008d6 <vprintfmt+0x2d8>
    802007ec:	02d00693          	li	a3,45
    802007f0:	0cd79163          	bne	a5,a3,802008b2 <vprintfmt+0x2b4>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
    802007f4:	00044783          	lbu	a5,0(s0)
    802007f8:	0007851b          	sext.w	a0,a5
    802007fc:	cf85                	beqz	a5,80200834 <vprintfmt+0x236>
    802007fe:	00140a13          	addi	s4,s0,1
                if (altflag && (ch < ' ' || ch > '~')) {
    80200802:	05e00413          	li	s0,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
    80200806:	000c4563          	bltz	s8,80200810 <vprintfmt+0x212>
    8020080a:	3c7d                	addiw	s8,s8,-1
    8020080c:	036c0263          	beq	s8,s6,80200830 <vprintfmt+0x232>
                    putch('?', putdat);
    80200810:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
    80200812:	0e0c8e63          	beqz	s9,8020090e <vprintfmt+0x310>
    80200816:	3781                	addiw	a5,a5,-32
    80200818:	0ef47b63          	bgeu	s0,a5,8020090e <vprintfmt+0x310>
                    putch('?', putdat);
    8020081c:	03f00513          	li	a0,63
    80200820:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
    80200822:	000a4783          	lbu	a5,0(s4)
    80200826:	3dfd                	addiw	s11,s11,-1
    80200828:	0a05                	addi	s4,s4,1
    8020082a:	0007851b          	sext.w	a0,a5
    8020082e:	ffe1                	bnez	a5,80200806 <vprintfmt+0x208>
            for (; width > 0; width --) {
    80200830:	01b05963          	blez	s11,80200842 <vprintfmt+0x244>
    80200834:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
    80200836:	85a6                	mv	a1,s1
    80200838:	02000513          	li	a0,32
    8020083c:	9902                	jalr	s2
            for (; width > 0; width --) {
    8020083e:	fe0d9be3          	bnez	s11,80200834 <vprintfmt+0x236>
            if ((p = va_arg(ap, char *)) == NULL) {
    80200842:	6a02                	ld	s4,0(sp)
    80200844:	bbd5                	j	80200638 <vprintfmt+0x3a>
    if (lflag >= 2) {
    80200846:	4705                	li	a4,1
            precision = va_arg(ap, int);
    80200848:	008a0c93          	addi	s9,s4,8
    if (lflag >= 2) {
    8020084c:	01174463          	blt	a4,a7,80200854 <vprintfmt+0x256>
    else if (lflag) {
    80200850:	08088d63          	beqz	a7,802008ea <vprintfmt+0x2ec>
        return va_arg(*ap, long);
    80200854:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
    80200858:	0a044d63          	bltz	s0,80200912 <vprintfmt+0x314>
            num = getint(&ap, lflag);
    8020085c:	8622                	mv	a2,s0
    8020085e:	8a66                	mv	s4,s9
    80200860:	46a9                	li	a3,10
    80200862:	bdcd                	j	80200754 <vprintfmt+0x156>
            err = va_arg(ap, int);
    80200864:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
    80200868:	4719                	li	a4,6
            err = va_arg(ap, int);
    8020086a:	0a21                	addi	s4,s4,8
            if (err < 0) {
    8020086c:	41f7d69b          	sraiw	a3,a5,0x1f
    80200870:	8fb5                	xor	a5,a5,a3
    80200872:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
    80200876:	02d74163          	blt	a4,a3,80200898 <vprintfmt+0x29a>
    8020087a:	00369793          	slli	a5,a3,0x3
    8020087e:	97de                	add	a5,a5,s7
    80200880:	639c                	ld	a5,0(a5)
    80200882:	cb99                	beqz	a5,80200898 <vprintfmt+0x29a>
                printfmt(putch, putdat, "%s", p);
    80200884:	86be                	mv	a3,a5
    80200886:	00000617          	auipc	a2,0x0
    8020088a:	76a60613          	addi	a2,a2,1898 # 80200ff0 <etext+0x5f4>
    8020088e:	85a6                	mv	a1,s1
    80200890:	854a                	mv	a0,s2
    80200892:	0ce000ef          	jal	ra,80200960 <printfmt>
    80200896:	b34d                	j	80200638 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
    80200898:	00000617          	auipc	a2,0x0
    8020089c:	74860613          	addi	a2,a2,1864 # 80200fe0 <etext+0x5e4>
    802008a0:	85a6                	mv	a1,s1
    802008a2:	854a                	mv	a0,s2
    802008a4:	0bc000ef          	jal	ra,80200960 <printfmt>
    802008a8:	bb41                	j	80200638 <vprintfmt+0x3a>
                p = "(null)";
    802008aa:	00000417          	auipc	s0,0x0
    802008ae:	72e40413          	addi	s0,s0,1838 # 80200fd8 <etext+0x5dc>
                for (width -= strnlen(p, precision); width > 0; width --) {
    802008b2:	85e2                	mv	a1,s8
    802008b4:	8522                	mv	a0,s0
    802008b6:	e43e                	sd	a5,8(sp)
    802008b8:	116000ef          	jal	ra,802009ce <strnlen>
    802008bc:	40ad8dbb          	subw	s11,s11,a0
    802008c0:	01b05b63          	blez	s11,802008d6 <vprintfmt+0x2d8>
                    putch(padc, putdat);
    802008c4:	67a2                	ld	a5,8(sp)
    802008c6:	00078a1b          	sext.w	s4,a5
                for (width -= strnlen(p, precision); width > 0; width --) {
    802008ca:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
    802008cc:	85a6                	mv	a1,s1
    802008ce:	8552                	mv	a0,s4
    802008d0:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
    802008d2:	fe0d9ce3          	bnez	s11,802008ca <vprintfmt+0x2cc>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
    802008d6:	00044783          	lbu	a5,0(s0)
    802008da:	00140a13          	addi	s4,s0,1
    802008de:	0007851b          	sext.w	a0,a5
    802008e2:	d3a5                	beqz	a5,80200842 <vprintfmt+0x244>
                if (altflag && (ch < ' ' || ch > '~')) {
    802008e4:	05e00413          	li	s0,94
    802008e8:	bf39                	j	80200806 <vprintfmt+0x208>
        return va_arg(*ap, int);
    802008ea:	000a2403          	lw	s0,0(s4)
    802008ee:	b7ad                	j	80200858 <vprintfmt+0x25a>
        return va_arg(*ap, unsigned int);
    802008f0:	000a6603          	lwu	a2,0(s4)
    802008f4:	46a1                	li	a3,8
    802008f6:	8a2e                	mv	s4,a1
    802008f8:	bdb1                	j	80200754 <vprintfmt+0x156>
    802008fa:	000a6603          	lwu	a2,0(s4)
    802008fe:	46a9                	li	a3,10
    80200900:	8a2e                	mv	s4,a1
    80200902:	bd89                	j	80200754 <vprintfmt+0x156>
    80200904:	000a6603          	lwu	a2,0(s4)
    80200908:	46c1                	li	a3,16
    8020090a:	8a2e                	mv	s4,a1
    8020090c:	b5a1                	j	80200754 <vprintfmt+0x156>
                    putch(ch, putdat);
    8020090e:	9902                	jalr	s2
    80200910:	bf09                	j	80200822 <vprintfmt+0x224>
                putch('-', putdat);
    80200912:	85a6                	mv	a1,s1
    80200914:	02d00513          	li	a0,45
    80200918:	e03e                	sd	a5,0(sp)
    8020091a:	9902                	jalr	s2
                num = -(long long)num;
    8020091c:	6782                	ld	a5,0(sp)
    8020091e:	8a66                	mv	s4,s9
    80200920:	40800633          	neg	a2,s0
    80200924:	46a9                	li	a3,10
    80200926:	b53d                	j	80200754 <vprintfmt+0x156>
            if (width > 0 && padc != '-') {
    80200928:	03b05163          	blez	s11,8020094a <vprintfmt+0x34c>
    8020092c:	02d00693          	li	a3,45
    80200930:	f6d79de3          	bne	a5,a3,802008aa <vprintfmt+0x2ac>
                p = "(null)";
    80200934:	00000417          	auipc	s0,0x0
    80200938:	6a440413          	addi	s0,s0,1700 # 80200fd8 <etext+0x5dc>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
    8020093c:	02800793          	li	a5,40
    80200940:	02800513          	li	a0,40
    80200944:	00140a13          	addi	s4,s0,1
    80200948:	bd6d                	j	80200802 <vprintfmt+0x204>
    8020094a:	00000a17          	auipc	s4,0x0
    8020094e:	68fa0a13          	addi	s4,s4,1679 # 80200fd9 <etext+0x5dd>
    80200952:	02800513          	li	a0,40
    80200956:	02800793          	li	a5,40
                if (altflag && (ch < ' ' || ch > '~')) {
    8020095a:	05e00413          	li	s0,94
    8020095e:	b565                	j	80200806 <vprintfmt+0x208>

0000000080200960 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
    80200960:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
    80200962:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
    80200966:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
    80200968:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
    8020096a:	ec06                	sd	ra,24(sp)
    8020096c:	f83a                	sd	a4,48(sp)
    8020096e:	fc3e                	sd	a5,56(sp)
    80200970:	e0c2                	sd	a6,64(sp)
    80200972:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
    80200974:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
    80200976:	c89ff0ef          	jal	ra,802005fe <vprintfmt>
}
    8020097a:	60e2                	ld	ra,24(sp)
    8020097c:	6161                	addi	sp,sp,80
    8020097e:	8082                	ret

0000000080200980 <sbi_console_putchar>:
uint64_t SBI_REMOTE_SFENCE_VMA_ASID = 7;
uint64_t SBI_SHUTDOWN = 8;

uint64_t sbi_call(uint64_t sbi_type, uint64_t arg0, uint64_t arg1, uint64_t arg2) {
    uint64_t ret_val;
    __asm__ volatile (
    80200980:	4781                	li	a5,0
    80200982:	00003717          	auipc	a4,0x3
    80200986:	67e73703          	ld	a4,1662(a4) # 80204000 <SBI_CONSOLE_PUTCHAR>
    8020098a:	88ba                	mv	a7,a4
    8020098c:	852a                	mv	a0,a0
    8020098e:	85be                	mv	a1,a5
    80200990:	863e                	mv	a2,a5
    80200992:	00000073          	ecall
    80200996:	87aa                	mv	a5,a0
int sbi_console_getchar(void) {
    return sbi_call(SBI_CONSOLE_GETCHAR, 0, 0, 0);
}
void sbi_console_putchar(unsigned char ch) {
    sbi_call(SBI_CONSOLE_PUTCHAR, ch, 0, 0);
}
    80200998:	8082                	ret

000000008020099a <sbi_set_timer>:
    __asm__ volatile (
    8020099a:	4781                	li	a5,0
    8020099c:	00003717          	auipc	a4,0x3
    802009a0:	68473703          	ld	a4,1668(a4) # 80204020 <SBI_SET_TIMER>
    802009a4:	88ba                	mv	a7,a4
    802009a6:	852a                	mv	a0,a0
    802009a8:	85be                	mv	a1,a5
    802009aa:	863e                	mv	a2,a5
    802009ac:	00000073          	ecall
    802009b0:	87aa                	mv	a5,a0

void sbi_set_timer(unsigned long long stime_value) {
    sbi_call(SBI_SET_TIMER, stime_value, 0, 0);
}
    802009b2:	8082                	ret

00000000802009b4 <sbi_shutdown>:
    __asm__ volatile (
    802009b4:	4781                	li	a5,0
    802009b6:	00003717          	auipc	a4,0x3
    802009ba:	65273703          	ld	a4,1618(a4) # 80204008 <SBI_SHUTDOWN>
    802009be:	88ba                	mv	a7,a4
    802009c0:	853e                	mv	a0,a5
    802009c2:	85be                	mv	a1,a5
    802009c4:	863e                	mv	a2,a5
    802009c6:	00000073          	ecall
    802009ca:	87aa                	mv	a5,a0


void sbi_shutdown(void)
{
    sbi_call(SBI_SHUTDOWN,0,0,0);
    802009cc:	8082                	ret

00000000802009ce <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    802009ce:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
    802009d0:	e589                	bnez	a1,802009da <strnlen+0xc>
    802009d2:	a811                	j	802009e6 <strnlen+0x18>
        cnt ++;
    802009d4:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
    802009d6:	00f58863          	beq	a1,a5,802009e6 <strnlen+0x18>
    802009da:	00f50733          	add	a4,a0,a5
    802009de:	00074703          	lbu	a4,0(a4)
    802009e2:	fb6d                	bnez	a4,802009d4 <strnlen+0x6>
    802009e4:	85be                	mv	a1,a5
    }
    return cnt;
}
    802009e6:	852e                	mv	a0,a1
    802009e8:	8082                	ret

00000000802009ea <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
    802009ea:	ca01                	beqz	a2,802009fa <memset+0x10>
    802009ec:	962a                	add	a2,a2,a0
    char *p = s;
    802009ee:	87aa                	mv	a5,a0
        *p ++ = c;
    802009f0:	0785                	addi	a5,a5,1
    802009f2:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
    802009f6:	fec79de3          	bne	a5,a2,802009f0 <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
    802009fa:	8082                	ret
