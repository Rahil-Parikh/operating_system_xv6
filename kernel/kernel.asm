
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	00009117          	auipc	sp,0x9
    80000004:	b4010113          	addi	sp,sp,-1216 # 80008b40 <stack0>
    80000008:	6505                	lui	a0,0x1
    8000000a:	f14025f3          	csrr	a1,mhartid
    8000000e:	0585                	addi	a1,a1,1
    80000010:	02b50533          	mul	a0,a0,a1
    80000014:	912a                	add	sp,sp,a0
    80000016:	07a000ef          	jal	ra,80000090 <start>

000000008000001a <_entry_kernel>:
    8000001a:	6cf000ef          	jal	ra,80000ee8 <main>

000000008000001e <_entry_test>:
    8000001e:	a001                	j	8000001e <_entry_test>

0000000080000020 <timerinit>:
// at timervec in kernelvec.S,
// which turns them into software interrupts for
// devintr() in trap.c.
void
timerinit()
{
    80000020:	1141                	addi	sp,sp,-16
    80000022:	e422                	sd	s0,8(sp)
    80000024:	0800                	addi	s0,sp,16
// which hart (core) is this?
static inline uint64
r_mhartid()
{
  uint64 x;
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    80000026:	f14027f3          	csrr	a5,mhartid
  // each CPU has a separate source of timer interrupts.
  int id = r_mhartid();
    8000002a:	0007859b          	sext.w	a1,a5

  // ask the CLINT for a timer interrupt.
  int interval = 1000000; // cycles; about 1/10th second in qemu.
  *(uint64*)CLINT_MTIMECMP(id) = *(uint64*)CLINT_MTIME + interval;
    8000002e:	0037979b          	slliw	a5,a5,0x3
    80000032:	02004737          	lui	a4,0x2004
    80000036:	97ba                	add	a5,a5,a4
    80000038:	0200c737          	lui	a4,0x200c
    8000003c:	ff873703          	ld	a4,-8(a4) # 200bff8 <_entry-0x7dff4008>
    80000040:	000f4637          	lui	a2,0xf4
    80000044:	24060613          	addi	a2,a2,576 # f4240 <_entry-0x7ff0bdc0>
    80000048:	9732                	add	a4,a4,a2
    8000004a:	e398                	sd	a4,0(a5)

  // prepare information in scratch[] for timervec.
  // scratch[0..2] : space for timervec to save registers.
  // scratch[3] : address of CLINT MTIMECMP register.
  // scratch[4] : desired interval (in cycles) between timer interrupts.
  uint64 *scratch = &timer_scratch[id][0];
    8000004c:	00259693          	slli	a3,a1,0x2
    80000050:	96ae                	add	a3,a3,a1
    80000052:	068e                	slli	a3,a3,0x3
    80000054:	00009717          	auipc	a4,0x9
    80000058:	9ac70713          	addi	a4,a4,-1620 # 80008a00 <timer_scratch>
    8000005c:	9736                	add	a4,a4,a3
  scratch[3] = CLINT_MTIMECMP(id);
    8000005e:	ef1c                	sd	a5,24(a4)
  scratch[4] = interval;
    80000060:	f310                	sd	a2,32(a4)
}

static inline void 
w_mscratch(uint64 x)
{
  asm volatile("csrw mscratch, %0" : : "r" (x));
    80000062:	34071073          	csrw	mscratch,a4
  asm volatile("csrw mtvec, %0" : : "r" (x));
    80000066:	00006797          	auipc	a5,0x6
    8000006a:	c9a78793          	addi	a5,a5,-870 # 80005d00 <timervec>
    8000006e:	30579073          	csrw	mtvec,a5
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    80000072:	300027f3          	csrr	a5,mstatus

  // set the machine-mode trap handler.
  w_mtvec((uint64)timervec);

  // enable machine-mode interrupts.
  w_mstatus(r_mstatus() | MSTATUS_MIE);
    80000076:	0087e793          	ori	a5,a5,8
  asm volatile("csrw mstatus, %0" : : "r" (x));
    8000007a:	30079073          	csrw	mstatus,a5
  asm volatile("csrr %0, mie" : "=r" (x) );
    8000007e:	304027f3          	csrr	a5,mie

  // enable machine-mode timer interrupts.
  w_mie(r_mie() | MIE_MTIE);
    80000082:	0807e793          	ori	a5,a5,128
  asm volatile("csrw mie, %0" : : "r" (x));
    80000086:	30479073          	csrw	mie,a5
}
    8000008a:	6422                	ld	s0,8(sp)
    8000008c:	0141                	addi	sp,sp,16
    8000008e:	8082                	ret

0000000080000090 <start>:
{
    80000090:	1141                	addi	sp,sp,-16
    80000092:	e406                	sd	ra,8(sp)
    80000094:	e022                	sd	s0,0(sp)
    80000096:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    80000098:	f14027f3          	csrr	a5,mhartid
  w_tp(id);
    8000009c:	2781                	sext.w	a5,a5
}

static inline void 
w_tp(uint64 x)
{
  asm volatile("mv tp, %0" : : "r" (x));
    8000009e:	823e                	mv	tp,a5
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    800000a0:	300027f3          	csrr	a5,mstatus
  x &= ~MSTATUS_MPP_MASK;
    800000a4:	7779                	lui	a4,0xffffe
    800000a6:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffdc3b7>
    800000aa:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    800000ac:	6705                	lui	a4,0x1
    800000ae:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    800000b2:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    800000b4:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    800000b8:	00001797          	auipc	a5,0x1
    800000bc:	e3078793          	addi	a5,a5,-464 # 80000ee8 <main>
    800000c0:	34179073          	csrw	mepc,a5
  asm volatile("csrw satp, %0" : : "r" (x));
    800000c4:	4781                	li	a5,0
    800000c6:	18079073          	csrw	satp,a5
  asm volatile("csrw pmpaddr0, %0" : : "r" (x));
    800000ca:	57fd                	li	a5,-1
    800000cc:	83a9                	srli	a5,a5,0xa
    800000ce:	3b079073          	csrw	pmpaddr0,a5
  asm volatile("csrw pmpcfg0, %0" : : "r" (x));
    800000d2:	47bd                	li	a5,15
    800000d4:	3a079073          	csrw	pmpcfg0,a5
  timerinit();
    800000d8:	00000097          	auipc	ra,0x0
    800000dc:	f48080e7          	jalr	-184(ra) # 80000020 <timerinit>
  asm volatile("csrw medeleg, %0" : : "r" (x));
    800000e0:	67c1                	lui	a5,0x10
    800000e2:	17fd                	addi	a5,a5,-1 # ffff <_entry-0x7fff0001>
    800000e4:	30279073          	csrw	medeleg,a5
  asm volatile("csrw mideleg, %0" : : "r" (x));
    800000e8:	30379073          	csrw	mideleg,a5
  asm volatile("csrr %0, sie" : "=r" (x) );
    800000ec:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE | SIE_SSIE);
    800000f0:	2227e793          	ori	a5,a5,546
  asm volatile("csrw sie, %0" : : "r" (x));
    800000f4:	10479073          	csrw	sie,a5
  asm volatile("mret");
    800000f8:	30200073          	mret
}
    800000fc:	60a2                	ld	ra,8(sp)
    800000fe:	6402                	ld	s0,0(sp)
    80000100:	0141                	addi	sp,sp,16
    80000102:	8082                	ret

0000000080000104 <consolewrite>:
//
// user write()s to the console go here.
//
int
consolewrite(int user_src, uint64 src, int n)
{
    80000104:	715d                	addi	sp,sp,-80
    80000106:	e486                	sd	ra,72(sp)
    80000108:	e0a2                	sd	s0,64(sp)
    8000010a:	fc26                	sd	s1,56(sp)
    8000010c:	f84a                	sd	s2,48(sp)
    8000010e:	f44e                	sd	s3,40(sp)
    80000110:	f052                	sd	s4,32(sp)
    80000112:	ec56                	sd	s5,24(sp)
    80000114:	0880                	addi	s0,sp,80
  int i;

  for(i = 0; i < n; i++){
    80000116:	04c05763          	blez	a2,80000164 <consolewrite+0x60>
    8000011a:	8a2a                	mv	s4,a0
    8000011c:	84ae                	mv	s1,a1
    8000011e:	89b2                	mv	s3,a2
    80000120:	4901                	li	s2,0
    char c;
    if(either_copyin(&c, user_src, src+i, 1) == -1)
    80000122:	5afd                	li	s5,-1
    80000124:	4685                	li	a3,1
    80000126:	8626                	mv	a2,s1
    80000128:	85d2                	mv	a1,s4
    8000012a:	fbf40513          	addi	a0,s0,-65
    8000012e:	00002097          	auipc	ra,0x2
    80000132:	42a080e7          	jalr	1066(ra) # 80002558 <either_copyin>
    80000136:	01550d63          	beq	a0,s5,80000150 <consolewrite+0x4c>
      break;
    uartputc(c);
    8000013a:	fbf44503          	lbu	a0,-65(s0)
    8000013e:	00000097          	auipc	ra,0x0
    80000142:	7f2080e7          	jalr	2034(ra) # 80000930 <uartputc>
  for(i = 0; i < n; i++){
    80000146:	2905                	addiw	s2,s2,1
    80000148:	0485                	addi	s1,s1,1
    8000014a:	fd299de3          	bne	s3,s2,80000124 <consolewrite+0x20>
    8000014e:	894e                	mv	s2,s3
  }

  return i;
}
    80000150:	854a                	mv	a0,s2
    80000152:	60a6                	ld	ra,72(sp)
    80000154:	6406                	ld	s0,64(sp)
    80000156:	74e2                	ld	s1,56(sp)
    80000158:	7942                	ld	s2,48(sp)
    8000015a:	79a2                	ld	s3,40(sp)
    8000015c:	7a02                	ld	s4,32(sp)
    8000015e:	6ae2                	ld	s5,24(sp)
    80000160:	6161                	addi	sp,sp,80
    80000162:	8082                	ret
  for(i = 0; i < n; i++){
    80000164:	4901                	li	s2,0
    80000166:	b7ed                	j	80000150 <consolewrite+0x4c>

0000000080000168 <consoleread>:
// user_dist indicates whether dst is a user
// or kernel address.
//
int
consoleread(int user_dst, uint64 dst, int n)
{
    80000168:	711d                	addi	sp,sp,-96
    8000016a:	ec86                	sd	ra,88(sp)
    8000016c:	e8a2                	sd	s0,80(sp)
    8000016e:	e4a6                	sd	s1,72(sp)
    80000170:	e0ca                	sd	s2,64(sp)
    80000172:	fc4e                	sd	s3,56(sp)
    80000174:	f852                	sd	s4,48(sp)
    80000176:	f456                	sd	s5,40(sp)
    80000178:	f05a                	sd	s6,32(sp)
    8000017a:	ec5e                	sd	s7,24(sp)
    8000017c:	1080                	addi	s0,sp,96
    8000017e:	8aaa                	mv	s5,a0
    80000180:	8a2e                	mv	s4,a1
    80000182:	89b2                	mv	s3,a2
  uint target;
  int c;
  char cbuf;

  target = n;
    80000184:	00060b1b          	sext.w	s6,a2
  acquire(&cons.lock);
    80000188:	00011517          	auipc	a0,0x11
    8000018c:	9b850513          	addi	a0,a0,-1608 # 80010b40 <cons>
    80000190:	00001097          	auipc	ra,0x1
    80000194:	ab8080e7          	jalr	-1352(ra) # 80000c48 <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    80000198:	00011497          	auipc	s1,0x11
    8000019c:	9a848493          	addi	s1,s1,-1624 # 80010b40 <cons>
      if(killed(myproc())){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    800001a0:	00011917          	auipc	s2,0x11
    800001a4:	a3890913          	addi	s2,s2,-1480 # 80010bd8 <cons+0x98>
  while(n > 0){
    800001a8:	09305263          	blez	s3,8000022c <consoleread+0xc4>
    while(cons.r == cons.w){
    800001ac:	0984a783          	lw	a5,152(s1)
    800001b0:	09c4a703          	lw	a4,156(s1)
    800001b4:	02f71763          	bne	a4,a5,800001e2 <consoleread+0x7a>
      if(killed(myproc())){
    800001b8:	00002097          	auipc	ra,0x2
    800001bc:	86c080e7          	jalr	-1940(ra) # 80001a24 <myproc>
    800001c0:	00002097          	auipc	ra,0x2
    800001c4:	1e2080e7          	jalr	482(ra) # 800023a2 <killed>
    800001c8:	ed2d                	bnez	a0,80000242 <consoleread+0xda>
      sleep(&cons.r, &cons.lock);
    800001ca:	85a6                	mv	a1,s1
    800001cc:	854a                	mv	a0,s2
    800001ce:	00002097          	auipc	ra,0x2
    800001d2:	f2c080e7          	jalr	-212(ra) # 800020fa <sleep>
    while(cons.r == cons.w){
    800001d6:	0984a783          	lw	a5,152(s1)
    800001da:	09c4a703          	lw	a4,156(s1)
    800001de:	fcf70de3          	beq	a4,a5,800001b8 <consoleread+0x50>
    }

    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];
    800001e2:	00011717          	auipc	a4,0x11
    800001e6:	95e70713          	addi	a4,a4,-1698 # 80010b40 <cons>
    800001ea:	0017869b          	addiw	a3,a5,1
    800001ee:	08d72c23          	sw	a3,152(a4)
    800001f2:	07f7f693          	andi	a3,a5,127
    800001f6:	9736                	add	a4,a4,a3
    800001f8:	01874703          	lbu	a4,24(a4)
    800001fc:	00070b9b          	sext.w	s7,a4

    if(c == C('D')){  // end-of-file
    80000200:	4691                	li	a3,4
    80000202:	06db8463          	beq	s7,a3,8000026a <consoleread+0x102>
      }
      break;
    }

    // copy the input byte to the user-space buffer.
    cbuf = c;
    80000206:	fae407a3          	sb	a4,-81(s0)
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    8000020a:	4685                	li	a3,1
    8000020c:	faf40613          	addi	a2,s0,-81
    80000210:	85d2                	mv	a1,s4
    80000212:	8556                	mv	a0,s5
    80000214:	00002097          	auipc	ra,0x2
    80000218:	2ee080e7          	jalr	750(ra) # 80002502 <either_copyout>
    8000021c:	57fd                	li	a5,-1
    8000021e:	00f50763          	beq	a0,a5,8000022c <consoleread+0xc4>
      break;

    dst++;
    80000222:	0a05                	addi	s4,s4,1
    --n;
    80000224:	39fd                	addiw	s3,s3,-1

    if(c == '\n'){
    80000226:	47a9                	li	a5,10
    80000228:	f8fb90e3          	bne	s7,a5,800001a8 <consoleread+0x40>
      // a whole line has arrived, return to
      // the user-level read().
      break;
    }
  }
  release(&cons.lock);
    8000022c:	00011517          	auipc	a0,0x11
    80000230:	91450513          	addi	a0,a0,-1772 # 80010b40 <cons>
    80000234:	00001097          	auipc	ra,0x1
    80000238:	ac8080e7          	jalr	-1336(ra) # 80000cfc <release>

  return target - n;
    8000023c:	413b053b          	subw	a0,s6,s3
    80000240:	a811                	j	80000254 <consoleread+0xec>
        release(&cons.lock);
    80000242:	00011517          	auipc	a0,0x11
    80000246:	8fe50513          	addi	a0,a0,-1794 # 80010b40 <cons>
    8000024a:	00001097          	auipc	ra,0x1
    8000024e:	ab2080e7          	jalr	-1358(ra) # 80000cfc <release>
        return -1;
    80000252:	557d                	li	a0,-1
}
    80000254:	60e6                	ld	ra,88(sp)
    80000256:	6446                	ld	s0,80(sp)
    80000258:	64a6                	ld	s1,72(sp)
    8000025a:	6906                	ld	s2,64(sp)
    8000025c:	79e2                	ld	s3,56(sp)
    8000025e:	7a42                	ld	s4,48(sp)
    80000260:	7aa2                	ld	s5,40(sp)
    80000262:	7b02                	ld	s6,32(sp)
    80000264:	6be2                	ld	s7,24(sp)
    80000266:	6125                	addi	sp,sp,96
    80000268:	8082                	ret
      if(n < target){
    8000026a:	0009871b          	sext.w	a4,s3
    8000026e:	fb677fe3          	bgeu	a4,s6,8000022c <consoleread+0xc4>
        cons.r--;
    80000272:	00011717          	auipc	a4,0x11
    80000276:	96f72323          	sw	a5,-1690(a4) # 80010bd8 <cons+0x98>
    8000027a:	bf4d                	j	8000022c <consoleread+0xc4>

000000008000027c <consputc>:
{
    8000027c:	1141                	addi	sp,sp,-16
    8000027e:	e406                	sd	ra,8(sp)
    80000280:	e022                	sd	s0,0(sp)
    80000282:	0800                	addi	s0,sp,16
  if(c == BACKSPACE){
    80000284:	10000793          	li	a5,256
    80000288:	00f50a63          	beq	a0,a5,8000029c <consputc+0x20>
    uartputc_sync(c);
    8000028c:	00000097          	auipc	ra,0x0
    80000290:	5de080e7          	jalr	1502(ra) # 8000086a <uartputc_sync>
}
    80000294:	60a2                	ld	ra,8(sp)
    80000296:	6402                	ld	s0,0(sp)
    80000298:	0141                	addi	sp,sp,16
    8000029a:	8082                	ret
    uartputc_sync('\b'); uartputc_sync(' '); uartputc_sync('\b');
    8000029c:	4521                	li	a0,8
    8000029e:	00000097          	auipc	ra,0x0
    800002a2:	5cc080e7          	jalr	1484(ra) # 8000086a <uartputc_sync>
    800002a6:	02000513          	li	a0,32
    800002aa:	00000097          	auipc	ra,0x0
    800002ae:	5c0080e7          	jalr	1472(ra) # 8000086a <uartputc_sync>
    800002b2:	4521                	li	a0,8
    800002b4:	00000097          	auipc	ra,0x0
    800002b8:	5b6080e7          	jalr	1462(ra) # 8000086a <uartputc_sync>
    800002bc:	bfe1                	j	80000294 <consputc+0x18>

00000000800002be <consoleintr>:
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
//
void
consoleintr(int c)
{
    800002be:	1101                	addi	sp,sp,-32
    800002c0:	ec06                	sd	ra,24(sp)
    800002c2:	e822                	sd	s0,16(sp)
    800002c4:	e426                	sd	s1,8(sp)
    800002c6:	e04a                	sd	s2,0(sp)
    800002c8:	1000                	addi	s0,sp,32
    800002ca:	84aa                	mv	s1,a0
  acquire(&cons.lock);
    800002cc:	00011517          	auipc	a0,0x11
    800002d0:	87450513          	addi	a0,a0,-1932 # 80010b40 <cons>
    800002d4:	00001097          	auipc	ra,0x1
    800002d8:	974080e7          	jalr	-1676(ra) # 80000c48 <acquire>

  switch(c){
    800002dc:	47d5                	li	a5,21
    800002de:	0af48663          	beq	s1,a5,8000038a <consoleintr+0xcc>
    800002e2:	0297ca63          	blt	a5,s1,80000316 <consoleintr+0x58>
    800002e6:	47a1                	li	a5,8
    800002e8:	0ef48763          	beq	s1,a5,800003d6 <consoleintr+0x118>
    800002ec:	47c1                	li	a5,16
    800002ee:	10f49a63          	bne	s1,a5,80000402 <consoleintr+0x144>
  case C('P'):  // Print process list.
    procdump();
    800002f2:	00002097          	auipc	ra,0x2
    800002f6:	2bc080e7          	jalr	700(ra) # 800025ae <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    800002fa:	00011517          	auipc	a0,0x11
    800002fe:	84650513          	addi	a0,a0,-1978 # 80010b40 <cons>
    80000302:	00001097          	auipc	ra,0x1
    80000306:	9fa080e7          	jalr	-1542(ra) # 80000cfc <release>
}
    8000030a:	60e2                	ld	ra,24(sp)
    8000030c:	6442                	ld	s0,16(sp)
    8000030e:	64a2                	ld	s1,8(sp)
    80000310:	6902                	ld	s2,0(sp)
    80000312:	6105                	addi	sp,sp,32
    80000314:	8082                	ret
  switch(c){
    80000316:	07f00793          	li	a5,127
    8000031a:	0af48e63          	beq	s1,a5,800003d6 <consoleintr+0x118>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    8000031e:	00011717          	auipc	a4,0x11
    80000322:	82270713          	addi	a4,a4,-2014 # 80010b40 <cons>
    80000326:	0a072783          	lw	a5,160(a4)
    8000032a:	09872703          	lw	a4,152(a4)
    8000032e:	9f99                	subw	a5,a5,a4
    80000330:	07f00713          	li	a4,127
    80000334:	fcf763e3          	bltu	a4,a5,800002fa <consoleintr+0x3c>
      c = (c == '\r') ? '\n' : c;
    80000338:	47b5                	li	a5,13
    8000033a:	0cf48763          	beq	s1,a5,80000408 <consoleintr+0x14a>
      consputc(c);
    8000033e:	8526                	mv	a0,s1
    80000340:	00000097          	auipc	ra,0x0
    80000344:	f3c080e7          	jalr	-196(ra) # 8000027c <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    80000348:	00010797          	auipc	a5,0x10
    8000034c:	7f878793          	addi	a5,a5,2040 # 80010b40 <cons>
    80000350:	0a07a683          	lw	a3,160(a5)
    80000354:	0016871b          	addiw	a4,a3,1
    80000358:	0007061b          	sext.w	a2,a4
    8000035c:	0ae7a023          	sw	a4,160(a5)
    80000360:	07f6f693          	andi	a3,a3,127
    80000364:	97b6                	add	a5,a5,a3
    80000366:	00978c23          	sb	s1,24(a5)
      if(c == '\n' || c == C('D') || cons.e-cons.r == INPUT_BUF_SIZE){
    8000036a:	47a9                	li	a5,10
    8000036c:	0cf48563          	beq	s1,a5,80000436 <consoleintr+0x178>
    80000370:	4791                	li	a5,4
    80000372:	0cf48263          	beq	s1,a5,80000436 <consoleintr+0x178>
    80000376:	00011797          	auipc	a5,0x11
    8000037a:	8627a783          	lw	a5,-1950(a5) # 80010bd8 <cons+0x98>
    8000037e:	9f1d                	subw	a4,a4,a5
    80000380:	08000793          	li	a5,128
    80000384:	f6f71be3          	bne	a4,a5,800002fa <consoleintr+0x3c>
    80000388:	a07d                	j	80000436 <consoleintr+0x178>
    while(cons.e != cons.w &&
    8000038a:	00010717          	auipc	a4,0x10
    8000038e:	7b670713          	addi	a4,a4,1974 # 80010b40 <cons>
    80000392:	0a072783          	lw	a5,160(a4)
    80000396:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    8000039a:	00010497          	auipc	s1,0x10
    8000039e:	7a648493          	addi	s1,s1,1958 # 80010b40 <cons>
    while(cons.e != cons.w &&
    800003a2:	4929                	li	s2,10
    800003a4:	f4f70be3          	beq	a4,a5,800002fa <consoleintr+0x3c>
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    800003a8:	37fd                	addiw	a5,a5,-1
    800003aa:	07f7f713          	andi	a4,a5,127
    800003ae:	9726                	add	a4,a4,s1
    while(cons.e != cons.w &&
    800003b0:	01874703          	lbu	a4,24(a4)
    800003b4:	f52703e3          	beq	a4,s2,800002fa <consoleintr+0x3c>
      cons.e--;
    800003b8:	0af4a023          	sw	a5,160(s1)
      consputc(BACKSPACE);
    800003bc:	10000513          	li	a0,256
    800003c0:	00000097          	auipc	ra,0x0
    800003c4:	ebc080e7          	jalr	-324(ra) # 8000027c <consputc>
    while(cons.e != cons.w &&
    800003c8:	0a04a783          	lw	a5,160(s1)
    800003cc:	09c4a703          	lw	a4,156(s1)
    800003d0:	fcf71ce3          	bne	a4,a5,800003a8 <consoleintr+0xea>
    800003d4:	b71d                	j	800002fa <consoleintr+0x3c>
    if(cons.e != cons.w){
    800003d6:	00010717          	auipc	a4,0x10
    800003da:	76a70713          	addi	a4,a4,1898 # 80010b40 <cons>
    800003de:	0a072783          	lw	a5,160(a4)
    800003e2:	09c72703          	lw	a4,156(a4)
    800003e6:	f0f70ae3          	beq	a4,a5,800002fa <consoleintr+0x3c>
      cons.e--;
    800003ea:	37fd                	addiw	a5,a5,-1
    800003ec:	00010717          	auipc	a4,0x10
    800003f0:	7ef72a23          	sw	a5,2036(a4) # 80010be0 <cons+0xa0>
      consputc(BACKSPACE);
    800003f4:	10000513          	li	a0,256
    800003f8:	00000097          	auipc	ra,0x0
    800003fc:	e84080e7          	jalr	-380(ra) # 8000027c <consputc>
    80000400:	bded                	j	800002fa <consoleintr+0x3c>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    80000402:	ee048ce3          	beqz	s1,800002fa <consoleintr+0x3c>
    80000406:	bf21                	j	8000031e <consoleintr+0x60>
      consputc(c);
    80000408:	4529                	li	a0,10
    8000040a:	00000097          	auipc	ra,0x0
    8000040e:	e72080e7          	jalr	-398(ra) # 8000027c <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    80000412:	00010797          	auipc	a5,0x10
    80000416:	72e78793          	addi	a5,a5,1838 # 80010b40 <cons>
    8000041a:	0a07a703          	lw	a4,160(a5)
    8000041e:	0017069b          	addiw	a3,a4,1
    80000422:	0006861b          	sext.w	a2,a3
    80000426:	0ad7a023          	sw	a3,160(a5)
    8000042a:	07f77713          	andi	a4,a4,127
    8000042e:	97ba                	add	a5,a5,a4
    80000430:	4729                	li	a4,10
    80000432:	00e78c23          	sb	a4,24(a5)
        cons.w = cons.e;
    80000436:	00010797          	auipc	a5,0x10
    8000043a:	7ac7a323          	sw	a2,1958(a5) # 80010bdc <cons+0x9c>
        wakeup(&cons.r);
    8000043e:	00010517          	auipc	a0,0x10
    80000442:	79a50513          	addi	a0,a0,1946 # 80010bd8 <cons+0x98>
    80000446:	00002097          	auipc	ra,0x2
    8000044a:	d18080e7          	jalr	-744(ra) # 8000215e <wakeup>
    8000044e:	b575                	j	800002fa <consoleintr+0x3c>

0000000080000450 <consoleinit>:

void
consoleinit(void)
{
    80000450:	1141                	addi	sp,sp,-16
    80000452:	e406                	sd	ra,8(sp)
    80000454:	e022                	sd	s0,0(sp)
    80000456:	0800                	addi	s0,sp,16
  initlock(&cons.lock, "cons");
    80000458:	00008597          	auipc	a1,0x8
    8000045c:	bb858593          	addi	a1,a1,-1096 # 80008010 <etext+0x10>
    80000460:	00010517          	auipc	a0,0x10
    80000464:	6e050513          	addi	a0,a0,1760 # 80010b40 <cons>
    80000468:	00000097          	auipc	ra,0x0
    8000046c:	750080e7          	jalr	1872(ra) # 80000bb8 <initlock>

  uartinit();
    80000470:	00000097          	auipc	ra,0x0
    80000474:	3aa080e7          	jalr	938(ra) # 8000081a <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    80000478:	00021797          	auipc	a5,0x21
    8000047c:	a6078793          	addi	a5,a5,-1440 # 80020ed8 <devsw>
    80000480:	00000717          	auipc	a4,0x0
    80000484:	ce870713          	addi	a4,a4,-792 # 80000168 <consoleread>
    80000488:	eb98                	sd	a4,16(a5)
  devsw[CONSOLE].write = consolewrite;
    8000048a:	00000717          	auipc	a4,0x0
    8000048e:	c7a70713          	addi	a4,a4,-902 # 80000104 <consolewrite>
    80000492:	ef98                	sd	a4,24(a5)
}
    80000494:	60a2                	ld	ra,8(sp)
    80000496:	6402                	ld	s0,0(sp)
    80000498:	0141                	addi	sp,sp,16
    8000049a:	8082                	ret

000000008000049c <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(int xx, int base, int sign)
{
    8000049c:	7179                	addi	sp,sp,-48
    8000049e:	f406                	sd	ra,40(sp)
    800004a0:	f022                	sd	s0,32(sp)
    800004a2:	ec26                	sd	s1,24(sp)
    800004a4:	e84a                	sd	s2,16(sp)
    800004a6:	1800                	addi	s0,sp,48
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
    800004a8:	c219                	beqz	a2,800004ae <printint+0x12>
    800004aa:	08054763          	bltz	a0,80000538 <printint+0x9c>
    x = -xx;
  else
    x = xx;
    800004ae:	2501                	sext.w	a0,a0
    800004b0:	4881                	li	a7,0
    800004b2:	fd040693          	addi	a3,s0,-48

  i = 0;
    800004b6:	4701                	li	a4,0
  do {
    buf[i++] = digits[x % base];
    800004b8:	2581                	sext.w	a1,a1
    800004ba:	00008617          	auipc	a2,0x8
    800004be:	b8660613          	addi	a2,a2,-1146 # 80008040 <digits>
    800004c2:	883a                	mv	a6,a4
    800004c4:	2705                	addiw	a4,a4,1
    800004c6:	02b577bb          	remuw	a5,a0,a1
    800004ca:	1782                	slli	a5,a5,0x20
    800004cc:	9381                	srli	a5,a5,0x20
    800004ce:	97b2                	add	a5,a5,a2
    800004d0:	0007c783          	lbu	a5,0(a5)
    800004d4:	00f68023          	sb	a5,0(a3)
  } while((x /= base) != 0);
    800004d8:	0005079b          	sext.w	a5,a0
    800004dc:	02b5553b          	divuw	a0,a0,a1
    800004e0:	0685                	addi	a3,a3,1
    800004e2:	feb7f0e3          	bgeu	a5,a1,800004c2 <printint+0x26>

  if(sign)
    800004e6:	00088c63          	beqz	a7,800004fe <printint+0x62>
    buf[i++] = '-';
    800004ea:	fe070793          	addi	a5,a4,-32
    800004ee:	00878733          	add	a4,a5,s0
    800004f2:	02d00793          	li	a5,45
    800004f6:	fef70823          	sb	a5,-16(a4)
    800004fa:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
    800004fe:	02e05763          	blez	a4,8000052c <printint+0x90>
    80000502:	fd040793          	addi	a5,s0,-48
    80000506:	00e784b3          	add	s1,a5,a4
    8000050a:	fff78913          	addi	s2,a5,-1
    8000050e:	993a                	add	s2,s2,a4
    80000510:	377d                	addiw	a4,a4,-1
    80000512:	1702                	slli	a4,a4,0x20
    80000514:	9301                	srli	a4,a4,0x20
    80000516:	40e90933          	sub	s2,s2,a4
    consputc(buf[i]);
    8000051a:	fff4c503          	lbu	a0,-1(s1)
    8000051e:	00000097          	auipc	ra,0x0
    80000522:	d5e080e7          	jalr	-674(ra) # 8000027c <consputc>
  while(--i >= 0)
    80000526:	14fd                	addi	s1,s1,-1
    80000528:	ff2499e3          	bne	s1,s2,8000051a <printint+0x7e>
}
    8000052c:	70a2                	ld	ra,40(sp)
    8000052e:	7402                	ld	s0,32(sp)
    80000530:	64e2                	ld	s1,24(sp)
    80000532:	6942                	ld	s2,16(sp)
    80000534:	6145                	addi	sp,sp,48
    80000536:	8082                	ret
    x = -xx;
    80000538:	40a0053b          	negw	a0,a0
  if(sign && (sign = xx < 0))
    8000053c:	4885                	li	a7,1
    x = -xx;
    8000053e:	bf95                	j	800004b2 <printint+0x16>

0000000080000540 <panic>:
  //   release(&pr.lock);
}

void
panic(char *s)
{
    80000540:	1101                	addi	sp,sp,-32
    80000542:	ec06                	sd	ra,24(sp)
    80000544:	e822                	sd	s0,16(sp)
    80000546:	e426                	sd	s1,8(sp)
    80000548:	1000                	addi	s0,sp,32
    8000054a:	84aa                	mv	s1,a0
  pr.locking = 0;
    8000054c:	00010797          	auipc	a5,0x10
    80000550:	6a07aa23          	sw	zero,1716(a5) # 80010c00 <pr+0x18>
  printf("panic: ");
    80000554:	00008517          	auipc	a0,0x8
    80000558:	ac450513          	addi	a0,a0,-1340 # 80008018 <etext+0x18>
    8000055c:	00000097          	auipc	ra,0x0
    80000560:	02e080e7          	jalr	46(ra) # 8000058a <printf>
  printf(s);
    80000564:	8526                	mv	a0,s1
    80000566:	00000097          	auipc	ra,0x0
    8000056a:	024080e7          	jalr	36(ra) # 8000058a <printf>
  printf("\n");
    8000056e:	00008517          	auipc	a0,0x8
    80000572:	b5a50513          	addi	a0,a0,-1190 # 800080c8 <digits+0x88>
    80000576:	00000097          	auipc	ra,0x0
    8000057a:	014080e7          	jalr	20(ra) # 8000058a <printf>
  panicked = 1; // freeze uart output from other CPUs
    8000057e:	4785                	li	a5,1
    80000580:	00008717          	auipc	a4,0x8
    80000584:	44f72023          	sw	a5,1088(a4) # 800089c0 <panicked>
  for(;;)
    80000588:	a001                	j	80000588 <panic+0x48>

000000008000058a <printf>:
{
    8000058a:	7131                	addi	sp,sp,-192
    8000058c:	fc86                	sd	ra,120(sp)
    8000058e:	f8a2                	sd	s0,112(sp)
    80000590:	f4a6                	sd	s1,104(sp)
    80000592:	f0ca                	sd	s2,96(sp)
    80000594:	ecce                	sd	s3,88(sp)
    80000596:	e8d2                	sd	s4,80(sp)
    80000598:	e4d6                	sd	s5,72(sp)
    8000059a:	e0da                	sd	s6,64(sp)
    8000059c:	fc5e                	sd	s7,56(sp)
    8000059e:	f862                	sd	s8,48(sp)
    800005a0:	f466                	sd	s9,40(sp)
    800005a2:	f06a                	sd	s10,32(sp)
    800005a4:	ec6e                	sd	s11,24(sp)
    800005a6:	0100                	addi	s0,sp,128
    800005a8:	e40c                	sd	a1,8(s0)
    800005aa:	e810                	sd	a2,16(s0)
    800005ac:	ec14                	sd	a3,24(s0)
    800005ae:	f018                	sd	a4,32(s0)
    800005b0:	f41c                	sd	a5,40(s0)
    800005b2:	03043823          	sd	a6,48(s0)
    800005b6:	03143c23          	sd	a7,56(s0)
  if (fmt == 0)
    800005ba:	c90d                	beqz	a0,800005ec <printf+0x62>
    800005bc:	8a2a                	mv	s4,a0
  va_start(ap, fmt);
    800005be:	00840793          	addi	a5,s0,8
    800005c2:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    800005c6:	00054503          	lbu	a0,0(a0)
    800005ca:	20050063          	beqz	a0,800007ca <printf+0x240>
    800005ce:	4481                	li	s1,0
    if(c != '%'){
    800005d0:	02500b13          	li	s6,37
    switch(c){
    800005d4:	07000b93          	li	s7,112
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800005d8:	00008a97          	auipc	s5,0x8
    800005dc:	a68a8a93          	addi	s5,s5,-1432 # 80008040 <digits>
    switch(c){
    800005e0:	07300c93          	li	s9,115
    800005e4:	03400c13          	li	s8,52
  } while((x /= base) != 0);
    800005e8:	4d3d                	li	s10,15
    800005ea:	a025                	j	80000612 <printf+0x88>
    panic("null fmt");
    800005ec:	00008517          	auipc	a0,0x8
    800005f0:	a3c50513          	addi	a0,a0,-1476 # 80008028 <etext+0x28>
    800005f4:	00000097          	auipc	ra,0x0
    800005f8:	f4c080e7          	jalr	-180(ra) # 80000540 <panic>
      consputc(c);
    800005fc:	00000097          	auipc	ra,0x0
    80000600:	c80080e7          	jalr	-896(ra) # 8000027c <consputc>
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    80000604:	2485                	addiw	s1,s1,1
    80000606:	009a07b3          	add	a5,s4,s1
    8000060a:	0007c503          	lbu	a0,0(a5)
    8000060e:	1a050e63          	beqz	a0,800007ca <printf+0x240>
    if(c != '%'){
    80000612:	ff6515e3          	bne	a0,s6,800005fc <printf+0x72>
    c = fmt[++i] & 0xff;
    80000616:	2485                	addiw	s1,s1,1
    80000618:	009a07b3          	add	a5,s4,s1
    8000061c:	0007c783          	lbu	a5,0(a5)
    80000620:	0007891b          	sext.w	s2,a5
    if(c == 0)
    80000624:	1a078363          	beqz	a5,800007ca <printf+0x240>
    switch(c){
    80000628:	11778563          	beq	a5,s7,80000732 <printf+0x1a8>
    8000062c:	02fbee63          	bltu	s7,a5,80000668 <printf+0xde>
    80000630:	07878063          	beq	a5,s8,80000690 <printf+0x106>
    80000634:	06400713          	li	a4,100
    80000638:	02e79063          	bne	a5,a4,80000658 <printf+0xce>
      printint(va_arg(ap, int), 10, 1);
    8000063c:	f8843783          	ld	a5,-120(s0)
    80000640:	00878713          	addi	a4,a5,8
    80000644:	f8e43423          	sd	a4,-120(s0)
    80000648:	4605                	li	a2,1
    8000064a:	45a9                	li	a1,10
    8000064c:	4388                	lw	a0,0(a5)
    8000064e:	00000097          	auipc	ra,0x0
    80000652:	e4e080e7          	jalr	-434(ra) # 8000049c <printint>
      break;
    80000656:	b77d                	j	80000604 <printf+0x7a>
    switch(c){
    80000658:	15679e63          	bne	a5,s6,800007b4 <printf+0x22a>
      consputc('%');
    8000065c:	855a                	mv	a0,s6
    8000065e:	00000097          	auipc	ra,0x0
    80000662:	c1e080e7          	jalr	-994(ra) # 8000027c <consputc>
      break;
    80000666:	bf79                	j	80000604 <printf+0x7a>
    switch(c){
    80000668:	11978863          	beq	a5,s9,80000778 <printf+0x1ee>
    8000066c:	07800713          	li	a4,120
    80000670:	14e79263          	bne	a5,a4,800007b4 <printf+0x22a>
      printint(va_arg(ap, int), 16, 1);
    80000674:	f8843783          	ld	a5,-120(s0)
    80000678:	00878713          	addi	a4,a5,8
    8000067c:	f8e43423          	sd	a4,-120(s0)
    80000680:	4605                	li	a2,1
    80000682:	45c1                	li	a1,16
    80000684:	4388                	lw	a0,0(a5)
    80000686:	00000097          	auipc	ra,0x0
    8000068a:	e16080e7          	jalr	-490(ra) # 8000049c <printint>
      break;
    8000068e:	bf9d                	j	80000604 <printf+0x7a>
      print4hex(va_arg(ap, int), 16, 1);
    80000690:	f8843783          	ld	a5,-120(s0)
    80000694:	00878713          	addi	a4,a5,8
    80000698:	f8e43423          	sd	a4,-120(s0)
    8000069c:	438c                	lw	a1,0(a5)
    x = xx;
    8000069e:	0005879b          	sext.w	a5,a1
  if(sign && (sign = xx < 0))
    800006a2:	0805c563          	bltz	a1,8000072c <printf+0x1a2>
    800006a6:	f8040693          	addi	a3,s0,-128
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    800006aa:	4901                	li	s2,0
    buf[i++] = digits[x % base];
    800006ac:	864a                	mv	a2,s2
    800006ae:	2905                	addiw	s2,s2,1
    800006b0:	00f7f713          	andi	a4,a5,15
    800006b4:	9756                	add	a4,a4,s5
    800006b6:	00074703          	lbu	a4,0(a4)
    800006ba:	00e68023          	sb	a4,0(a3)
  } while((x /= base) != 0);
    800006be:	0007871b          	sext.w	a4,a5
    800006c2:	0047d79b          	srliw	a5,a5,0x4
    800006c6:	0685                	addi	a3,a3,1
    800006c8:	feed62e3          	bltu	s10,a4,800006ac <printf+0x122>
  if(sign)
    800006cc:	0005dc63          	bgez	a1,800006e4 <printf+0x15a>
    buf[i++] = '-';
    800006d0:	f9090793          	addi	a5,s2,-112
    800006d4:	00878933          	add	s2,a5,s0
    800006d8:	02d00793          	li	a5,45
    800006dc:	fef90823          	sb	a5,-16(s2)
    800006e0:	0026091b          	addiw	s2,a2,2
  for (int p=4-i; p>=0; p--)
    800006e4:	4991                	li	s3,4
    800006e6:	412989bb          	subw	s3,s3,s2
    800006ea:	0009cc63          	bltz	s3,80000702 <printf+0x178>
    800006ee:	5dfd                	li	s11,-1
    consputc('0');
    800006f0:	03000513          	li	a0,48
    800006f4:	00000097          	auipc	ra,0x0
    800006f8:	b88080e7          	jalr	-1144(ra) # 8000027c <consputc>
  for (int p=4-i; p>=0; p--)
    800006fc:	39fd                	addiw	s3,s3,-1
    800006fe:	ffb999e3          	bne	s3,s11,800006f0 <printf+0x166>
  while(--i >= 0)
    80000702:	fff9099b          	addiw	s3,s2,-1
    80000706:	f609c7e3          	bltz	s3,80000674 <printf+0xea>
    8000070a:	f9090793          	addi	a5,s2,-112
    8000070e:	00878933          	add	s2,a5,s0
    80000712:	193d                	addi	s2,s2,-17
    80000714:	5dfd                	li	s11,-1
    consputc(buf[i]);
    80000716:	00094503          	lbu	a0,0(s2)
    8000071a:	00000097          	auipc	ra,0x0
    8000071e:	b62080e7          	jalr	-1182(ra) # 8000027c <consputc>
  while(--i >= 0)
    80000722:	39fd                	addiw	s3,s3,-1
    80000724:	197d                	addi	s2,s2,-1
    80000726:	ffb998e3          	bne	s3,s11,80000716 <printf+0x18c>
    8000072a:	b7a9                	j	80000674 <printf+0xea>
    x = -xx;
    8000072c:	40b007bb          	negw	a5,a1
    80000730:	bf9d                	j	800006a6 <printf+0x11c>
      printptr(va_arg(ap, uint64));
    80000732:	f8843783          	ld	a5,-120(s0)
    80000736:	00878713          	addi	a4,a5,8
    8000073a:	f8e43423          	sd	a4,-120(s0)
    8000073e:	0007b983          	ld	s3,0(a5)
  consputc('0');
    80000742:	03000513          	li	a0,48
    80000746:	00000097          	auipc	ra,0x0
    8000074a:	b36080e7          	jalr	-1226(ra) # 8000027c <consputc>
  consputc('x');
    8000074e:	07800513          	li	a0,120
    80000752:	00000097          	auipc	ra,0x0
    80000756:	b2a080e7          	jalr	-1238(ra) # 8000027c <consputc>
    8000075a:	4941                	li	s2,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    8000075c:	03c9d793          	srli	a5,s3,0x3c
    80000760:	97d6                	add	a5,a5,s5
    80000762:	0007c503          	lbu	a0,0(a5)
    80000766:	00000097          	auipc	ra,0x0
    8000076a:	b16080e7          	jalr	-1258(ra) # 8000027c <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    8000076e:	0992                	slli	s3,s3,0x4
    80000770:	397d                	addiw	s2,s2,-1
    80000772:	fe0915e3          	bnez	s2,8000075c <printf+0x1d2>
    80000776:	b579                	j	80000604 <printf+0x7a>
      if((s = va_arg(ap, char*)) == 0)
    80000778:	f8843783          	ld	a5,-120(s0)
    8000077c:	00878713          	addi	a4,a5,8
    80000780:	f8e43423          	sd	a4,-120(s0)
    80000784:	0007b903          	ld	s2,0(a5)
    80000788:	00090f63          	beqz	s2,800007a6 <printf+0x21c>
      for(; *s; s++)
    8000078c:	00094503          	lbu	a0,0(s2)
    80000790:	e6050ae3          	beqz	a0,80000604 <printf+0x7a>
        consputc(*s);
    80000794:	00000097          	auipc	ra,0x0
    80000798:	ae8080e7          	jalr	-1304(ra) # 8000027c <consputc>
      for(; *s; s++)
    8000079c:	0905                	addi	s2,s2,1
    8000079e:	00094503          	lbu	a0,0(s2)
    800007a2:	f96d                	bnez	a0,80000794 <printf+0x20a>
    800007a4:	b585                	j	80000604 <printf+0x7a>
        s = "(null)";
    800007a6:	00008917          	auipc	s2,0x8
    800007aa:	87a90913          	addi	s2,s2,-1926 # 80008020 <etext+0x20>
      for(; *s; s++)
    800007ae:	02800513          	li	a0,40
    800007b2:	b7cd                	j	80000794 <printf+0x20a>
      consputc('%');
    800007b4:	855a                	mv	a0,s6
    800007b6:	00000097          	auipc	ra,0x0
    800007ba:	ac6080e7          	jalr	-1338(ra) # 8000027c <consputc>
      consputc(c);
    800007be:	854a                	mv	a0,s2
    800007c0:	00000097          	auipc	ra,0x0
    800007c4:	abc080e7          	jalr	-1348(ra) # 8000027c <consputc>
      break;
    800007c8:	bd35                	j	80000604 <printf+0x7a>
}
    800007ca:	70e6                	ld	ra,120(sp)
    800007cc:	7446                	ld	s0,112(sp)
    800007ce:	74a6                	ld	s1,104(sp)
    800007d0:	7906                	ld	s2,96(sp)
    800007d2:	69e6                	ld	s3,88(sp)
    800007d4:	6a46                	ld	s4,80(sp)
    800007d6:	6aa6                	ld	s5,72(sp)
    800007d8:	6b06                	ld	s6,64(sp)
    800007da:	7be2                	ld	s7,56(sp)
    800007dc:	7c42                	ld	s8,48(sp)
    800007de:	7ca2                	ld	s9,40(sp)
    800007e0:	7d02                	ld	s10,32(sp)
    800007e2:	6de2                	ld	s11,24(sp)
    800007e4:	6129                	addi	sp,sp,192
    800007e6:	8082                	ret

00000000800007e8 <printfinit>:
    ;
}

void
printfinit(void)
{
    800007e8:	1101                	addi	sp,sp,-32
    800007ea:	ec06                	sd	ra,24(sp)
    800007ec:	e822                	sd	s0,16(sp)
    800007ee:	e426                	sd	s1,8(sp)
    800007f0:	1000                	addi	s0,sp,32
  initlock(&pr.lock, "pr");
    800007f2:	00010497          	auipc	s1,0x10
    800007f6:	3f648493          	addi	s1,s1,1014 # 80010be8 <pr>
    800007fa:	00008597          	auipc	a1,0x8
    800007fe:	83e58593          	addi	a1,a1,-1986 # 80008038 <etext+0x38>
    80000802:	8526                	mv	a0,s1
    80000804:	00000097          	auipc	ra,0x0
    80000808:	3b4080e7          	jalr	948(ra) # 80000bb8 <initlock>
  pr.locking = 1;
    8000080c:	4785                	li	a5,1
    8000080e:	cc9c                	sw	a5,24(s1)
}
    80000810:	60e2                	ld	ra,24(sp)
    80000812:	6442                	ld	s0,16(sp)
    80000814:	64a2                	ld	s1,8(sp)
    80000816:	6105                	addi	sp,sp,32
    80000818:	8082                	ret

000000008000081a <uartinit>:

void uartstart();

void
uartinit(void)
{
    8000081a:	1141                	addi	sp,sp,-16
    8000081c:	e406                	sd	ra,8(sp)
    8000081e:	e022                	sd	s0,0(sp)
    80000820:	0800                	addi	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    80000822:	100007b7          	lui	a5,0x10000
    80000826:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, LCR_BAUD_LATCH);
    8000082a:	f8000713          	li	a4,-128
    8000082e:	00e781a3          	sb	a4,3(a5)

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    80000832:	470d                	li	a4,3
    80000834:	00e78023          	sb	a4,0(a5)

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    80000838:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    8000083c:	00e781a3          	sb	a4,3(a5)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    80000840:	469d                	li	a3,7
    80000842:	00d78123          	sb	a3,2(a5)

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    80000846:	00e780a3          	sb	a4,1(a5)

  initlock(&uart_tx_lock, "uart");
    8000084a:	00008597          	auipc	a1,0x8
    8000084e:	80e58593          	addi	a1,a1,-2034 # 80008058 <digits+0x18>
    80000852:	00010517          	auipc	a0,0x10
    80000856:	3b650513          	addi	a0,a0,950 # 80010c08 <uart_tx_lock>
    8000085a:	00000097          	auipc	ra,0x0
    8000085e:	35e080e7          	jalr	862(ra) # 80000bb8 <initlock>
}
    80000862:	60a2                	ld	ra,8(sp)
    80000864:	6402                	ld	s0,0(sp)
    80000866:	0141                	addi	sp,sp,16
    80000868:	8082                	ret

000000008000086a <uartputc_sync>:
// use interrupts, for use by kernel printf() and
// to echo characters. it spins waiting for the uart's
// output register to be empty.
void
uartputc_sync(int c)
{
    8000086a:	1101                	addi	sp,sp,-32
    8000086c:	ec06                	sd	ra,24(sp)
    8000086e:	e822                	sd	s0,16(sp)
    80000870:	e426                	sd	s1,8(sp)
    80000872:	1000                	addi	s0,sp,32
    80000874:	84aa                	mv	s1,a0
  push_off();
    80000876:	00000097          	auipc	ra,0x0
    8000087a:	386080e7          	jalr	902(ra) # 80000bfc <push_off>
  //   for(;;)
  //     ;
  // }

  // wait for Transmit Holding Empty to be set in LSR.
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    8000087e:	10000737          	lui	a4,0x10000
    80000882:	00574783          	lbu	a5,5(a4) # 10000005 <_entry-0x6ffffffb>
    80000886:	0207f793          	andi	a5,a5,32
    8000088a:	dfe5                	beqz	a5,80000882 <uartputc_sync+0x18>
    ;
  WriteReg(THR, c);
    8000088c:	0ff4f493          	zext.b	s1,s1
    80000890:	100007b7          	lui	a5,0x10000
    80000894:	00978023          	sb	s1,0(a5) # 10000000 <_entry-0x70000000>

  pop_off();
    80000898:	00000097          	auipc	ra,0x0
    8000089c:	404080e7          	jalr	1028(ra) # 80000c9c <pop_off>
}
    800008a0:	60e2                	ld	ra,24(sp)
    800008a2:	6442                	ld	s0,16(sp)
    800008a4:	64a2                	ld	s1,8(sp)
    800008a6:	6105                	addi	sp,sp,32
    800008a8:	8082                	ret

00000000800008aa <uartstart>:
// called from both the top- and bottom-half.
void
uartstart()
{
  while(1){
    if(uart_tx_w == uart_tx_r){
    800008aa:	00008797          	auipc	a5,0x8
    800008ae:	11e7b783          	ld	a5,286(a5) # 800089c8 <uart_tx_r>
    800008b2:	00008717          	auipc	a4,0x8
    800008b6:	11e73703          	ld	a4,286(a4) # 800089d0 <uart_tx_w>
    800008ba:	06f70a63          	beq	a4,a5,8000092e <uartstart+0x84>
{
    800008be:	7139                	addi	sp,sp,-64
    800008c0:	fc06                	sd	ra,56(sp)
    800008c2:	f822                	sd	s0,48(sp)
    800008c4:	f426                	sd	s1,40(sp)
    800008c6:	f04a                	sd	s2,32(sp)
    800008c8:	ec4e                	sd	s3,24(sp)
    800008ca:	e852                	sd	s4,16(sp)
    800008cc:	e456                	sd	s5,8(sp)
    800008ce:	0080                	addi	s0,sp,64
      // transmit buffer is empty.
      return;
    }
    
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    800008d0:	10000937          	lui	s2,0x10000
      // so we cannot give it another byte.
      // it will interrupt when it's ready for a new byte.
      return;
    }
    
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    800008d4:	00010a17          	auipc	s4,0x10
    800008d8:	334a0a13          	addi	s4,s4,820 # 80010c08 <uart_tx_lock>
    uart_tx_r += 1;
    800008dc:	00008497          	auipc	s1,0x8
    800008e0:	0ec48493          	addi	s1,s1,236 # 800089c8 <uart_tx_r>
    if(uart_tx_w == uart_tx_r){
    800008e4:	00008997          	auipc	s3,0x8
    800008e8:	0ec98993          	addi	s3,s3,236 # 800089d0 <uart_tx_w>
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    800008ec:	00594703          	lbu	a4,5(s2) # 10000005 <_entry-0x6ffffffb>
    800008f0:	02077713          	andi	a4,a4,32
    800008f4:	c705                	beqz	a4,8000091c <uartstart+0x72>
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    800008f6:	01f7f713          	andi	a4,a5,31
    800008fa:	9752                	add	a4,a4,s4
    800008fc:	01874a83          	lbu	s5,24(a4)
    uart_tx_r += 1;
    80000900:	0785                	addi	a5,a5,1
    80000902:	e09c                	sd	a5,0(s1)
    
    // maybe uartputc() is waiting for space in the buffer.
    wakeup(&uart_tx_r);
    80000904:	8526                	mv	a0,s1
    80000906:	00002097          	auipc	ra,0x2
    8000090a:	858080e7          	jalr	-1960(ra) # 8000215e <wakeup>
    
    WriteReg(THR, c);
    8000090e:	01590023          	sb	s5,0(s2)
    if(uart_tx_w == uart_tx_r){
    80000912:	609c                	ld	a5,0(s1)
    80000914:	0009b703          	ld	a4,0(s3)
    80000918:	fcf71ae3          	bne	a4,a5,800008ec <uartstart+0x42>
  }
}
    8000091c:	70e2                	ld	ra,56(sp)
    8000091e:	7442                	ld	s0,48(sp)
    80000920:	74a2                	ld	s1,40(sp)
    80000922:	7902                	ld	s2,32(sp)
    80000924:	69e2                	ld	s3,24(sp)
    80000926:	6a42                	ld	s4,16(sp)
    80000928:	6aa2                	ld	s5,8(sp)
    8000092a:	6121                	addi	sp,sp,64
    8000092c:	8082                	ret
    8000092e:	8082                	ret

0000000080000930 <uartputc>:
{
    80000930:	7179                	addi	sp,sp,-48
    80000932:	f406                	sd	ra,40(sp)
    80000934:	f022                	sd	s0,32(sp)
    80000936:	ec26                	sd	s1,24(sp)
    80000938:	e84a                	sd	s2,16(sp)
    8000093a:	e44e                	sd	s3,8(sp)
    8000093c:	e052                	sd	s4,0(sp)
    8000093e:	1800                	addi	s0,sp,48
    80000940:	8a2a                	mv	s4,a0
  acquire(&uart_tx_lock);
    80000942:	00010517          	auipc	a0,0x10
    80000946:	2c650513          	addi	a0,a0,710 # 80010c08 <uart_tx_lock>
    8000094a:	00000097          	auipc	ra,0x0
    8000094e:	2fe080e7          	jalr	766(ra) # 80000c48 <acquire>
  if(panicked){
    80000952:	00008797          	auipc	a5,0x8
    80000956:	06e7a783          	lw	a5,110(a5) # 800089c0 <panicked>
    8000095a:	e7c9                	bnez	a5,800009e4 <uartputc+0xb4>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    8000095c:	00008717          	auipc	a4,0x8
    80000960:	07473703          	ld	a4,116(a4) # 800089d0 <uart_tx_w>
    80000964:	00008797          	auipc	a5,0x8
    80000968:	0647b783          	ld	a5,100(a5) # 800089c8 <uart_tx_r>
    8000096c:	02078793          	addi	a5,a5,32
    sleep(&uart_tx_r, &uart_tx_lock);
    80000970:	00010997          	auipc	s3,0x10
    80000974:	29898993          	addi	s3,s3,664 # 80010c08 <uart_tx_lock>
    80000978:	00008497          	auipc	s1,0x8
    8000097c:	05048493          	addi	s1,s1,80 # 800089c8 <uart_tx_r>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000980:	00008917          	auipc	s2,0x8
    80000984:	05090913          	addi	s2,s2,80 # 800089d0 <uart_tx_w>
    80000988:	00e79f63          	bne	a5,a4,800009a6 <uartputc+0x76>
    sleep(&uart_tx_r, &uart_tx_lock);
    8000098c:	85ce                	mv	a1,s3
    8000098e:	8526                	mv	a0,s1
    80000990:	00001097          	auipc	ra,0x1
    80000994:	76a080e7          	jalr	1898(ra) # 800020fa <sleep>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000998:	00093703          	ld	a4,0(s2)
    8000099c:	609c                	ld	a5,0(s1)
    8000099e:	02078793          	addi	a5,a5,32
    800009a2:	fee785e3          	beq	a5,a4,8000098c <uartputc+0x5c>
  uart_tx_buf[uart_tx_w % UART_TX_BUF_SIZE] = c;
    800009a6:	00010497          	auipc	s1,0x10
    800009aa:	26248493          	addi	s1,s1,610 # 80010c08 <uart_tx_lock>
    800009ae:	01f77793          	andi	a5,a4,31
    800009b2:	97a6                	add	a5,a5,s1
    800009b4:	01478c23          	sb	s4,24(a5)
  uart_tx_w += 1;
    800009b8:	0705                	addi	a4,a4,1
    800009ba:	00008797          	auipc	a5,0x8
    800009be:	00e7bb23          	sd	a4,22(a5) # 800089d0 <uart_tx_w>
  uartstart();
    800009c2:	00000097          	auipc	ra,0x0
    800009c6:	ee8080e7          	jalr	-280(ra) # 800008aa <uartstart>
  release(&uart_tx_lock);
    800009ca:	8526                	mv	a0,s1
    800009cc:	00000097          	auipc	ra,0x0
    800009d0:	330080e7          	jalr	816(ra) # 80000cfc <release>
}
    800009d4:	70a2                	ld	ra,40(sp)
    800009d6:	7402                	ld	s0,32(sp)
    800009d8:	64e2                	ld	s1,24(sp)
    800009da:	6942                	ld	s2,16(sp)
    800009dc:	69a2                	ld	s3,8(sp)
    800009de:	6a02                	ld	s4,0(sp)
    800009e0:	6145                	addi	sp,sp,48
    800009e2:	8082                	ret
    for(;;)
    800009e4:	a001                	j	800009e4 <uartputc+0xb4>

00000000800009e6 <uartgetc>:

// read one input character from the UART.
// return -1 if none is waiting.
int
uartgetc(void)
{
    800009e6:	1141                	addi	sp,sp,-16
    800009e8:	e422                	sd	s0,8(sp)
    800009ea:	0800                	addi	s0,sp,16
  if(ReadReg(LSR) & 0x01){
    800009ec:	100007b7          	lui	a5,0x10000
    800009f0:	0057c783          	lbu	a5,5(a5) # 10000005 <_entry-0x6ffffffb>
    800009f4:	8b85                	andi	a5,a5,1
    800009f6:	cb81                	beqz	a5,80000a06 <uartgetc+0x20>
    // input data is ready.
    return ReadReg(RHR);
    800009f8:	100007b7          	lui	a5,0x10000
    800009fc:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
  } else {
    return -1;
  }
}
    80000a00:	6422                	ld	s0,8(sp)
    80000a02:	0141                	addi	sp,sp,16
    80000a04:	8082                	ret
    return -1;
    80000a06:	557d                	li	a0,-1
    80000a08:	bfe5                	j	80000a00 <uartgetc+0x1a>

0000000080000a0a <uartintr>:
// handle a uart interrupt, raised because input has
// arrived, or the uart is ready for more output, or
// both. called from devintr().
void
uartintr(void)
{
    80000a0a:	1101                	addi	sp,sp,-32
    80000a0c:	ec06                	sd	ra,24(sp)
    80000a0e:	e822                	sd	s0,16(sp)
    80000a10:	e426                	sd	s1,8(sp)
    80000a12:	1000                	addi	s0,sp,32
  // read and process incoming characters.
  while(1){
    int c = uartgetc();
    if(c == -1)
    80000a14:	54fd                	li	s1,-1
    80000a16:	a029                	j	80000a20 <uartintr+0x16>
      break;
    consoleintr(c);
    80000a18:	00000097          	auipc	ra,0x0
    80000a1c:	8a6080e7          	jalr	-1882(ra) # 800002be <consoleintr>
    int c = uartgetc();
    80000a20:	00000097          	auipc	ra,0x0
    80000a24:	fc6080e7          	jalr	-58(ra) # 800009e6 <uartgetc>
    if(c == -1)
    80000a28:	fe9518e3          	bne	a0,s1,80000a18 <uartintr+0xe>
  }

  // send buffered characters.
  acquire(&uart_tx_lock);
    80000a2c:	00010497          	auipc	s1,0x10
    80000a30:	1dc48493          	addi	s1,s1,476 # 80010c08 <uart_tx_lock>
    80000a34:	8526                	mv	a0,s1
    80000a36:	00000097          	auipc	ra,0x0
    80000a3a:	212080e7          	jalr	530(ra) # 80000c48 <acquire>
  uartstart();
    80000a3e:	00000097          	auipc	ra,0x0
    80000a42:	e6c080e7          	jalr	-404(ra) # 800008aa <uartstart>
  release(&uart_tx_lock);
    80000a46:	8526                	mv	a0,s1
    80000a48:	00000097          	auipc	ra,0x0
    80000a4c:	2b4080e7          	jalr	692(ra) # 80000cfc <release>
}
    80000a50:	60e2                	ld	ra,24(sp)
    80000a52:	6442                	ld	s0,16(sp)
    80000a54:	64a2                	ld	s1,8(sp)
    80000a56:	6105                	addi	sp,sp,32
    80000a58:	8082                	ret

0000000080000a5a <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
    80000a5a:	1101                	addi	sp,sp,-32
    80000a5c:	ec06                	sd	ra,24(sp)
    80000a5e:	e822                	sd	s0,16(sp)
    80000a60:	e426                	sd	s1,8(sp)
    80000a62:	e04a                	sd	s2,0(sp)
    80000a64:	1000                	addi	s0,sp,32
  struct run *r;

  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    80000a66:	03451793          	slli	a5,a0,0x34
    80000a6a:	ebb9                	bnez	a5,80000ac0 <kfree+0x66>
    80000a6c:	84aa                	mv	s1,a0
    80000a6e:	00022797          	auipc	a5,0x22
    80000a72:	9da78793          	addi	a5,a5,-1574 # 80022448 <end>
    80000a76:	04f56563          	bltu	a0,a5,80000ac0 <kfree+0x66>
    80000a7a:	47c5                	li	a5,17
    80000a7c:	07ee                	slli	a5,a5,0x1b
    80000a7e:	04f57163          	bgeu	a0,a5,80000ac0 <kfree+0x66>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);
    80000a82:	6605                	lui	a2,0x1
    80000a84:	4585                	li	a1,1
    80000a86:	00000097          	auipc	ra,0x0
    80000a8a:	2be080e7          	jalr	702(ra) # 80000d44 <memset>

  r = (struct run*)pa;

  acquire(&kmem.lock);
    80000a8e:	00010917          	auipc	s2,0x10
    80000a92:	1b290913          	addi	s2,s2,434 # 80010c40 <kmem>
    80000a96:	854a                	mv	a0,s2
    80000a98:	00000097          	auipc	ra,0x0
    80000a9c:	1b0080e7          	jalr	432(ra) # 80000c48 <acquire>
  r->next = kmem.freelist;
    80000aa0:	01893783          	ld	a5,24(s2)
    80000aa4:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    80000aa6:	00993c23          	sd	s1,24(s2)
  release(&kmem.lock);
    80000aaa:	854a                	mv	a0,s2
    80000aac:	00000097          	auipc	ra,0x0
    80000ab0:	250080e7          	jalr	592(ra) # 80000cfc <release>
}
    80000ab4:	60e2                	ld	ra,24(sp)
    80000ab6:	6442                	ld	s0,16(sp)
    80000ab8:	64a2                	ld	s1,8(sp)
    80000aba:	6902                	ld	s2,0(sp)
    80000abc:	6105                	addi	sp,sp,32
    80000abe:	8082                	ret
    panic("kfree");
    80000ac0:	00007517          	auipc	a0,0x7
    80000ac4:	5a050513          	addi	a0,a0,1440 # 80008060 <digits+0x20>
    80000ac8:	00000097          	auipc	ra,0x0
    80000acc:	a78080e7          	jalr	-1416(ra) # 80000540 <panic>

0000000080000ad0 <freerange>:
{
    80000ad0:	7179                	addi	sp,sp,-48
    80000ad2:	f406                	sd	ra,40(sp)
    80000ad4:	f022                	sd	s0,32(sp)
    80000ad6:	ec26                	sd	s1,24(sp)
    80000ad8:	e84a                	sd	s2,16(sp)
    80000ada:	e44e                	sd	s3,8(sp)
    80000adc:	e052                	sd	s4,0(sp)
    80000ade:	1800                	addi	s0,sp,48
  p = (char*)PGROUNDUP((uint64)pa_start);
    80000ae0:	6785                	lui	a5,0x1
    80000ae2:	fff78713          	addi	a4,a5,-1 # fff <_entry-0x7ffff001>
    80000ae6:	00e504b3          	add	s1,a0,a4
    80000aea:	777d                	lui	a4,0xfffff
    80000aec:	8cf9                	and	s1,s1,a4
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000aee:	94be                	add	s1,s1,a5
    80000af0:	0095ee63          	bltu	a1,s1,80000b0c <freerange+0x3c>
    80000af4:	892e                	mv	s2,a1
    kfree(p);
    80000af6:	7a7d                	lui	s4,0xfffff
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000af8:	6985                	lui	s3,0x1
    kfree(p);
    80000afa:	01448533          	add	a0,s1,s4
    80000afe:	00000097          	auipc	ra,0x0
    80000b02:	f5c080e7          	jalr	-164(ra) # 80000a5a <kfree>
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000b06:	94ce                	add	s1,s1,s3
    80000b08:	fe9979e3          	bgeu	s2,s1,80000afa <freerange+0x2a>
}
    80000b0c:	70a2                	ld	ra,40(sp)
    80000b0e:	7402                	ld	s0,32(sp)
    80000b10:	64e2                	ld	s1,24(sp)
    80000b12:	6942                	ld	s2,16(sp)
    80000b14:	69a2                	ld	s3,8(sp)
    80000b16:	6a02                	ld	s4,0(sp)
    80000b18:	6145                	addi	sp,sp,48
    80000b1a:	8082                	ret

0000000080000b1c <kinit>:
{
    80000b1c:	1141                	addi	sp,sp,-16
    80000b1e:	e406                	sd	ra,8(sp)
    80000b20:	e022                	sd	s0,0(sp)
    80000b22:	0800                	addi	s0,sp,16
  initlock(&kmem.lock, "kmem");
    80000b24:	00007597          	auipc	a1,0x7
    80000b28:	54458593          	addi	a1,a1,1348 # 80008068 <digits+0x28>
    80000b2c:	00010517          	auipc	a0,0x10
    80000b30:	11450513          	addi	a0,a0,276 # 80010c40 <kmem>
    80000b34:	00000097          	auipc	ra,0x0
    80000b38:	084080e7          	jalr	132(ra) # 80000bb8 <initlock>
  freerange(end, (void*)PHYSTOP);
    80000b3c:	45c5                	li	a1,17
    80000b3e:	05ee                	slli	a1,a1,0x1b
    80000b40:	00022517          	auipc	a0,0x22
    80000b44:	90850513          	addi	a0,a0,-1784 # 80022448 <end>
    80000b48:	00000097          	auipc	ra,0x0
    80000b4c:	f88080e7          	jalr	-120(ra) # 80000ad0 <freerange>
}
    80000b50:	60a2                	ld	ra,8(sp)
    80000b52:	6402                	ld	s0,0(sp)
    80000b54:	0141                	addi	sp,sp,16
    80000b56:	8082                	ret

0000000080000b58 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    80000b58:	1101                	addi	sp,sp,-32
    80000b5a:	ec06                	sd	ra,24(sp)
    80000b5c:	e822                	sd	s0,16(sp)
    80000b5e:	e426                	sd	s1,8(sp)
    80000b60:	1000                	addi	s0,sp,32
  struct run *r;

  acquire(&kmem.lock);
    80000b62:	00010497          	auipc	s1,0x10
    80000b66:	0de48493          	addi	s1,s1,222 # 80010c40 <kmem>
    80000b6a:	8526                	mv	a0,s1
    80000b6c:	00000097          	auipc	ra,0x0
    80000b70:	0dc080e7          	jalr	220(ra) # 80000c48 <acquire>
  r = kmem.freelist;
    80000b74:	6c84                	ld	s1,24(s1)
  if(r)
    80000b76:	c885                	beqz	s1,80000ba6 <kalloc+0x4e>
    kmem.freelist = r->next;
    80000b78:	609c                	ld	a5,0(s1)
    80000b7a:	00010517          	auipc	a0,0x10
    80000b7e:	0c650513          	addi	a0,a0,198 # 80010c40 <kmem>
    80000b82:	ed1c                	sd	a5,24(a0)
  release(&kmem.lock);
    80000b84:	00000097          	auipc	ra,0x0
    80000b88:	178080e7          	jalr	376(ra) # 80000cfc <release>

  if(r)
    memset((char*)r, 5, PGSIZE); // fill with junk
    80000b8c:	6605                	lui	a2,0x1
    80000b8e:	4595                	li	a1,5
    80000b90:	8526                	mv	a0,s1
    80000b92:	00000097          	auipc	ra,0x0
    80000b96:	1b2080e7          	jalr	434(ra) # 80000d44 <memset>
  return (void*)r;
}
    80000b9a:	8526                	mv	a0,s1
    80000b9c:	60e2                	ld	ra,24(sp)
    80000b9e:	6442                	ld	s0,16(sp)
    80000ba0:	64a2                	ld	s1,8(sp)
    80000ba2:	6105                	addi	sp,sp,32
    80000ba4:	8082                	ret
  release(&kmem.lock);
    80000ba6:	00010517          	auipc	a0,0x10
    80000baa:	09a50513          	addi	a0,a0,154 # 80010c40 <kmem>
    80000bae:	00000097          	auipc	ra,0x0
    80000bb2:	14e080e7          	jalr	334(ra) # 80000cfc <release>
  if(r)
    80000bb6:	b7d5                	j	80000b9a <kalloc+0x42>

0000000080000bb8 <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    80000bb8:	1141                	addi	sp,sp,-16
    80000bba:	e422                	sd	s0,8(sp)
    80000bbc:	0800                	addi	s0,sp,16
  lk->name = name;
    80000bbe:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80000bc0:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80000bc4:	00053823          	sd	zero,16(a0)
}
    80000bc8:	6422                	ld	s0,8(sp)
    80000bca:	0141                	addi	sp,sp,16
    80000bcc:	8082                	ret

0000000080000bce <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80000bce:	411c                	lw	a5,0(a0)
    80000bd0:	e399                	bnez	a5,80000bd6 <holding+0x8>
    80000bd2:	4501                	li	a0,0
  return r;
}
    80000bd4:	8082                	ret
{
    80000bd6:	1101                	addi	sp,sp,-32
    80000bd8:	ec06                	sd	ra,24(sp)
    80000bda:	e822                	sd	s0,16(sp)
    80000bdc:	e426                	sd	s1,8(sp)
    80000bde:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80000be0:	6904                	ld	s1,16(a0)
    80000be2:	00001097          	auipc	ra,0x1
    80000be6:	e26080e7          	jalr	-474(ra) # 80001a08 <mycpu>
    80000bea:	40a48533          	sub	a0,s1,a0
    80000bee:	00153513          	seqz	a0,a0
}
    80000bf2:	60e2                	ld	ra,24(sp)
    80000bf4:	6442                	ld	s0,16(sp)
    80000bf6:	64a2                	ld	s1,8(sp)
    80000bf8:	6105                	addi	sp,sp,32
    80000bfa:	8082                	ret

0000000080000bfc <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80000bfc:	1101                	addi	sp,sp,-32
    80000bfe:	ec06                	sd	ra,24(sp)
    80000c00:	e822                	sd	s0,16(sp)
    80000c02:	e426                	sd	s1,8(sp)
    80000c04:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c06:	100024f3          	csrr	s1,sstatus
    80000c0a:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80000c0e:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000c10:	10079073          	csrw	sstatus,a5
  int old = intr_get();

  intr_off();
  if(mycpu()->noff == 0)
    80000c14:	00001097          	auipc	ra,0x1
    80000c18:	df4080e7          	jalr	-524(ra) # 80001a08 <mycpu>
    80000c1c:	5d3c                	lw	a5,120(a0)
    80000c1e:	cf89                	beqz	a5,80000c38 <push_off+0x3c>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000c20:	00001097          	auipc	ra,0x1
    80000c24:	de8080e7          	jalr	-536(ra) # 80001a08 <mycpu>
    80000c28:	5d3c                	lw	a5,120(a0)
    80000c2a:	2785                	addiw	a5,a5,1
    80000c2c:	dd3c                	sw	a5,120(a0)
}
    80000c2e:	60e2                	ld	ra,24(sp)
    80000c30:	6442                	ld	s0,16(sp)
    80000c32:	64a2                	ld	s1,8(sp)
    80000c34:	6105                	addi	sp,sp,32
    80000c36:	8082                	ret
    mycpu()->intena = old;
    80000c38:	00001097          	auipc	ra,0x1
    80000c3c:	dd0080e7          	jalr	-560(ra) # 80001a08 <mycpu>
  return (x & SSTATUS_SIE) != 0;
    80000c40:	8085                	srli	s1,s1,0x1
    80000c42:	8885                	andi	s1,s1,1
    80000c44:	dd64                	sw	s1,124(a0)
    80000c46:	bfe9                	j	80000c20 <push_off+0x24>

0000000080000c48 <acquire>:
{
    80000c48:	1101                	addi	sp,sp,-32
    80000c4a:	ec06                	sd	ra,24(sp)
    80000c4c:	e822                	sd	s0,16(sp)
    80000c4e:	e426                	sd	s1,8(sp)
    80000c50:	1000                	addi	s0,sp,32
    80000c52:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000c54:	00000097          	auipc	ra,0x0
    80000c58:	fa8080e7          	jalr	-88(ra) # 80000bfc <push_off>
  if(holding(lk))
    80000c5c:	8526                	mv	a0,s1
    80000c5e:	00000097          	auipc	ra,0x0
    80000c62:	f70080e7          	jalr	-144(ra) # 80000bce <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000c66:	4705                	li	a4,1
  if(holding(lk))
    80000c68:	e115                	bnez	a0,80000c8c <acquire+0x44>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000c6a:	87ba                	mv	a5,a4
    80000c6c:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000c70:	2781                	sext.w	a5,a5
    80000c72:	ffe5                	bnez	a5,80000c6a <acquire+0x22>
  __sync_synchronize();
    80000c74:	0ff0000f          	fence
  lk->cpu = mycpu();
    80000c78:	00001097          	auipc	ra,0x1
    80000c7c:	d90080e7          	jalr	-624(ra) # 80001a08 <mycpu>
    80000c80:	e888                	sd	a0,16(s1)
}
    80000c82:	60e2                	ld	ra,24(sp)
    80000c84:	6442                	ld	s0,16(sp)
    80000c86:	64a2                	ld	s1,8(sp)
    80000c88:	6105                	addi	sp,sp,32
    80000c8a:	8082                	ret
    panic("acquire");
    80000c8c:	00007517          	auipc	a0,0x7
    80000c90:	3e450513          	addi	a0,a0,996 # 80008070 <digits+0x30>
    80000c94:	00000097          	auipc	ra,0x0
    80000c98:	8ac080e7          	jalr	-1876(ra) # 80000540 <panic>

0000000080000c9c <pop_off>:

void
pop_off(void)
{
    80000c9c:	1141                	addi	sp,sp,-16
    80000c9e:	e406                	sd	ra,8(sp)
    80000ca0:	e022                	sd	s0,0(sp)
    80000ca2:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80000ca4:	00001097          	auipc	ra,0x1
    80000ca8:	d64080e7          	jalr	-668(ra) # 80001a08 <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000cac:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000cb0:	8b89                	andi	a5,a5,2
  if(intr_get())
    80000cb2:	e78d                	bnez	a5,80000cdc <pop_off+0x40>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    80000cb4:	5d3c                	lw	a5,120(a0)
    80000cb6:	02f05b63          	blez	a5,80000cec <pop_off+0x50>
    panic("pop_off");
  c->noff -= 1;
    80000cba:	37fd                	addiw	a5,a5,-1
    80000cbc:	0007871b          	sext.w	a4,a5
    80000cc0:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80000cc2:	eb09                	bnez	a4,80000cd4 <pop_off+0x38>
    80000cc4:	5d7c                	lw	a5,124(a0)
    80000cc6:	c799                	beqz	a5,80000cd4 <pop_off+0x38>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000cc8:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000ccc:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000cd0:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80000cd4:	60a2                	ld	ra,8(sp)
    80000cd6:	6402                	ld	s0,0(sp)
    80000cd8:	0141                	addi	sp,sp,16
    80000cda:	8082                	ret
    panic("pop_off - interruptible");
    80000cdc:	00007517          	auipc	a0,0x7
    80000ce0:	39c50513          	addi	a0,a0,924 # 80008078 <digits+0x38>
    80000ce4:	00000097          	auipc	ra,0x0
    80000ce8:	85c080e7          	jalr	-1956(ra) # 80000540 <panic>
    panic("pop_off");
    80000cec:	00007517          	auipc	a0,0x7
    80000cf0:	3a450513          	addi	a0,a0,932 # 80008090 <digits+0x50>
    80000cf4:	00000097          	auipc	ra,0x0
    80000cf8:	84c080e7          	jalr	-1972(ra) # 80000540 <panic>

0000000080000cfc <release>:
{
    80000cfc:	1101                	addi	sp,sp,-32
    80000cfe:	ec06                	sd	ra,24(sp)
    80000d00:	e822                	sd	s0,16(sp)
    80000d02:	e426                	sd	s1,8(sp)
    80000d04:	1000                	addi	s0,sp,32
    80000d06:	84aa                	mv	s1,a0
  if(!holding(lk))
    80000d08:	00000097          	auipc	ra,0x0
    80000d0c:	ec6080e7          	jalr	-314(ra) # 80000bce <holding>
    80000d10:	c115                	beqz	a0,80000d34 <release+0x38>
  lk->cpu = 0;
    80000d12:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80000d16:	0ff0000f          	fence
  __sync_lock_release(&lk->locked);
    80000d1a:	0f50000f          	fence	iorw,ow
    80000d1e:	0804a02f          	amoswap.w	zero,zero,(s1)
  pop_off();
    80000d22:	00000097          	auipc	ra,0x0
    80000d26:	f7a080e7          	jalr	-134(ra) # 80000c9c <pop_off>
}
    80000d2a:	60e2                	ld	ra,24(sp)
    80000d2c:	6442                	ld	s0,16(sp)
    80000d2e:	64a2                	ld	s1,8(sp)
    80000d30:	6105                	addi	sp,sp,32
    80000d32:	8082                	ret
    panic("release");
    80000d34:	00007517          	auipc	a0,0x7
    80000d38:	36450513          	addi	a0,a0,868 # 80008098 <digits+0x58>
    80000d3c:	00000097          	auipc	ra,0x0
    80000d40:	804080e7          	jalr	-2044(ra) # 80000540 <panic>

0000000080000d44 <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    80000d44:	1141                	addi	sp,sp,-16
    80000d46:	e422                	sd	s0,8(sp)
    80000d48:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80000d4a:	ca19                	beqz	a2,80000d60 <memset+0x1c>
    80000d4c:	87aa                	mv	a5,a0
    80000d4e:	1602                	slli	a2,a2,0x20
    80000d50:	9201                	srli	a2,a2,0x20
    80000d52:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    80000d56:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    80000d5a:	0785                	addi	a5,a5,1
    80000d5c:	fee79de3          	bne	a5,a4,80000d56 <memset+0x12>
  }
  return dst;
}
    80000d60:	6422                	ld	s0,8(sp)
    80000d62:	0141                	addi	sp,sp,16
    80000d64:	8082                	ret

0000000080000d66 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000d66:	1141                	addi	sp,sp,-16
    80000d68:	e422                	sd	s0,8(sp)
    80000d6a:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    80000d6c:	ca05                	beqz	a2,80000d9c <memcmp+0x36>
    80000d6e:	fff6069b          	addiw	a3,a2,-1 # fff <_entry-0x7ffff001>
    80000d72:	1682                	slli	a3,a3,0x20
    80000d74:	9281                	srli	a3,a3,0x20
    80000d76:	0685                	addi	a3,a3,1
    80000d78:	96aa                	add	a3,a3,a0
    if(*s1 != *s2)
    80000d7a:	00054783          	lbu	a5,0(a0)
    80000d7e:	0005c703          	lbu	a4,0(a1)
    80000d82:	00e79863          	bne	a5,a4,80000d92 <memcmp+0x2c>
      return *s1 - *s2;
    s1++, s2++;
    80000d86:	0505                	addi	a0,a0,1
    80000d88:	0585                	addi	a1,a1,1
  while(n-- > 0){
    80000d8a:	fed518e3          	bne	a0,a3,80000d7a <memcmp+0x14>
  }

  return 0;
    80000d8e:	4501                	li	a0,0
    80000d90:	a019                	j	80000d96 <memcmp+0x30>
      return *s1 - *s2;
    80000d92:	40e7853b          	subw	a0,a5,a4
}
    80000d96:	6422                	ld	s0,8(sp)
    80000d98:	0141                	addi	sp,sp,16
    80000d9a:	8082                	ret
  return 0;
    80000d9c:	4501                	li	a0,0
    80000d9e:	bfe5                	j	80000d96 <memcmp+0x30>

0000000080000da0 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    80000da0:	1141                	addi	sp,sp,-16
    80000da2:	e422                	sd	s0,8(sp)
    80000da4:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  if(n == 0)
    80000da6:	c205                	beqz	a2,80000dc6 <memmove+0x26>
    return dst;
  
  s = src;
  d = dst;
  if(s < d && s + n > d){
    80000da8:	02a5e263          	bltu	a1,a0,80000dcc <memmove+0x2c>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    80000dac:	1602                	slli	a2,a2,0x20
    80000dae:	9201                	srli	a2,a2,0x20
    80000db0:	00c587b3          	add	a5,a1,a2
{
    80000db4:	872a                	mv	a4,a0
      *d++ = *s++;
    80000db6:	0585                	addi	a1,a1,1
    80000db8:	0705                	addi	a4,a4,1 # fffffffffffff001 <end+0xffffffff7ffdcbb9>
    80000dba:	fff5c683          	lbu	a3,-1(a1)
    80000dbe:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
    80000dc2:	fef59ae3          	bne	a1,a5,80000db6 <memmove+0x16>

  return dst;
}
    80000dc6:	6422                	ld	s0,8(sp)
    80000dc8:	0141                	addi	sp,sp,16
    80000dca:	8082                	ret
  if(s < d && s + n > d){
    80000dcc:	02061693          	slli	a3,a2,0x20
    80000dd0:	9281                	srli	a3,a3,0x20
    80000dd2:	00d58733          	add	a4,a1,a3
    80000dd6:	fce57be3          	bgeu	a0,a4,80000dac <memmove+0xc>
    d += n;
    80000dda:	96aa                	add	a3,a3,a0
    while(n-- > 0)
    80000ddc:	fff6079b          	addiw	a5,a2,-1
    80000de0:	1782                	slli	a5,a5,0x20
    80000de2:	9381                	srli	a5,a5,0x20
    80000de4:	fff7c793          	not	a5,a5
    80000de8:	97ba                	add	a5,a5,a4
      *--d = *--s;
    80000dea:	177d                	addi	a4,a4,-1
    80000dec:	16fd                	addi	a3,a3,-1
    80000dee:	00074603          	lbu	a2,0(a4)
    80000df2:	00c68023          	sb	a2,0(a3)
    while(n-- > 0)
    80000df6:	fee79ae3          	bne	a5,a4,80000dea <memmove+0x4a>
    80000dfa:	b7f1                	j	80000dc6 <memmove+0x26>

0000000080000dfc <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80000dfc:	1141                	addi	sp,sp,-16
    80000dfe:	e406                	sd	ra,8(sp)
    80000e00:	e022                	sd	s0,0(sp)
    80000e02:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80000e04:	00000097          	auipc	ra,0x0
    80000e08:	f9c080e7          	jalr	-100(ra) # 80000da0 <memmove>
}
    80000e0c:	60a2                	ld	ra,8(sp)
    80000e0e:	6402                	ld	s0,0(sp)
    80000e10:	0141                	addi	sp,sp,16
    80000e12:	8082                	ret

0000000080000e14 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000e14:	1141                	addi	sp,sp,-16
    80000e16:	e422                	sd	s0,8(sp)
    80000e18:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80000e1a:	ce11                	beqz	a2,80000e36 <strncmp+0x22>
    80000e1c:	00054783          	lbu	a5,0(a0)
    80000e20:	cf89                	beqz	a5,80000e3a <strncmp+0x26>
    80000e22:	0005c703          	lbu	a4,0(a1)
    80000e26:	00f71a63          	bne	a4,a5,80000e3a <strncmp+0x26>
    n--, p++, q++;
    80000e2a:	367d                	addiw	a2,a2,-1
    80000e2c:	0505                	addi	a0,a0,1
    80000e2e:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    80000e30:	f675                	bnez	a2,80000e1c <strncmp+0x8>
  if(n == 0)
    return 0;
    80000e32:	4501                	li	a0,0
    80000e34:	a809                	j	80000e46 <strncmp+0x32>
    80000e36:	4501                	li	a0,0
    80000e38:	a039                	j	80000e46 <strncmp+0x32>
  if(n == 0)
    80000e3a:	ca09                	beqz	a2,80000e4c <strncmp+0x38>
  return (uchar)*p - (uchar)*q;
    80000e3c:	00054503          	lbu	a0,0(a0)
    80000e40:	0005c783          	lbu	a5,0(a1)
    80000e44:	9d1d                	subw	a0,a0,a5
}
    80000e46:	6422                	ld	s0,8(sp)
    80000e48:	0141                	addi	sp,sp,16
    80000e4a:	8082                	ret
    return 0;
    80000e4c:	4501                	li	a0,0
    80000e4e:	bfe5                	j	80000e46 <strncmp+0x32>

0000000080000e50 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    80000e50:	1141                	addi	sp,sp,-16
    80000e52:	e422                	sd	s0,8(sp)
    80000e54:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    80000e56:	87aa                	mv	a5,a0
    80000e58:	86b2                	mv	a3,a2
    80000e5a:	367d                	addiw	a2,a2,-1
    80000e5c:	00d05963          	blez	a3,80000e6e <strncpy+0x1e>
    80000e60:	0785                	addi	a5,a5,1
    80000e62:	0005c703          	lbu	a4,0(a1)
    80000e66:	fee78fa3          	sb	a4,-1(a5)
    80000e6a:	0585                	addi	a1,a1,1
    80000e6c:	f775                	bnez	a4,80000e58 <strncpy+0x8>
    ;
  while(n-- > 0)
    80000e6e:	873e                	mv	a4,a5
    80000e70:	9fb5                	addw	a5,a5,a3
    80000e72:	37fd                	addiw	a5,a5,-1
    80000e74:	00c05963          	blez	a2,80000e86 <strncpy+0x36>
    *s++ = 0;
    80000e78:	0705                	addi	a4,a4,1
    80000e7a:	fe070fa3          	sb	zero,-1(a4)
  while(n-- > 0)
    80000e7e:	40e786bb          	subw	a3,a5,a4
    80000e82:	fed04be3          	bgtz	a3,80000e78 <strncpy+0x28>
  return os;
}
    80000e86:	6422                	ld	s0,8(sp)
    80000e88:	0141                	addi	sp,sp,16
    80000e8a:	8082                	ret

0000000080000e8c <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    80000e8c:	1141                	addi	sp,sp,-16
    80000e8e:	e422                	sd	s0,8(sp)
    80000e90:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    80000e92:	02c05363          	blez	a2,80000eb8 <safestrcpy+0x2c>
    80000e96:	fff6069b          	addiw	a3,a2,-1
    80000e9a:	1682                	slli	a3,a3,0x20
    80000e9c:	9281                	srli	a3,a3,0x20
    80000e9e:	96ae                	add	a3,a3,a1
    80000ea0:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    80000ea2:	00d58963          	beq	a1,a3,80000eb4 <safestrcpy+0x28>
    80000ea6:	0585                	addi	a1,a1,1
    80000ea8:	0785                	addi	a5,a5,1
    80000eaa:	fff5c703          	lbu	a4,-1(a1)
    80000eae:	fee78fa3          	sb	a4,-1(a5)
    80000eb2:	fb65                	bnez	a4,80000ea2 <safestrcpy+0x16>
    ;
  *s = 0;
    80000eb4:	00078023          	sb	zero,0(a5)
  return os;
}
    80000eb8:	6422                	ld	s0,8(sp)
    80000eba:	0141                	addi	sp,sp,16
    80000ebc:	8082                	ret

0000000080000ebe <strlen>:

int
strlen(const char *s)
{
    80000ebe:	1141                	addi	sp,sp,-16
    80000ec0:	e422                	sd	s0,8(sp)
    80000ec2:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    80000ec4:	00054783          	lbu	a5,0(a0)
    80000ec8:	cf91                	beqz	a5,80000ee4 <strlen+0x26>
    80000eca:	0505                	addi	a0,a0,1
    80000ecc:	87aa                	mv	a5,a0
    80000ece:	86be                	mv	a3,a5
    80000ed0:	0785                	addi	a5,a5,1
    80000ed2:	fff7c703          	lbu	a4,-1(a5)
    80000ed6:	ff65                	bnez	a4,80000ece <strlen+0x10>
    80000ed8:	40a6853b          	subw	a0,a3,a0
    80000edc:	2505                	addiw	a0,a0,1
    ;
  return n;
}
    80000ede:	6422                	ld	s0,8(sp)
    80000ee0:	0141                	addi	sp,sp,16
    80000ee2:	8082                	ret
  for(n = 0; s[n]; n++)
    80000ee4:	4501                	li	a0,0
    80000ee6:	bfe5                	j	80000ede <strlen+0x20>

0000000080000ee8 <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80000ee8:	1141                	addi	sp,sp,-16
    80000eea:	e406                	sd	ra,8(sp)
    80000eec:	e022                	sd	s0,0(sp)
    80000eee:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    80000ef0:	00001097          	auipc	ra,0x1
    80000ef4:	b08080e7          	jalr	-1272(ra) # 800019f8 <cpuid>
    trap_and_emulate_init();

    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000ef8:	00008717          	auipc	a4,0x8
    80000efc:	ae070713          	addi	a4,a4,-1312 # 800089d8 <started>
  if(cpuid() == 0){
    80000f00:	c139                	beqz	a0,80000f46 <main+0x5e>
    while(started == 0)
    80000f02:	431c                	lw	a5,0(a4)
    80000f04:	2781                	sext.w	a5,a5
    80000f06:	dff5                	beqz	a5,80000f02 <main+0x1a>
      ;
    __sync_synchronize();
    80000f08:	0ff0000f          	fence
    printf("hart %d starting\n", cpuid());
    80000f0c:	00001097          	auipc	ra,0x1
    80000f10:	aec080e7          	jalr	-1300(ra) # 800019f8 <cpuid>
    80000f14:	85aa                	mv	a1,a0
    80000f16:	00007517          	auipc	a0,0x7
    80000f1a:	1a250513          	addi	a0,a0,418 # 800080b8 <digits+0x78>
    80000f1e:	fffff097          	auipc	ra,0xfffff
    80000f22:	66c080e7          	jalr	1644(ra) # 8000058a <printf>
    kvminithart();    // turn on paging
    80000f26:	00000097          	auipc	ra,0x0
    80000f2a:	0e0080e7          	jalr	224(ra) # 80001006 <kvminithart>
    trapinithart();   // install kernel trap vector
    80000f2e:	00001097          	auipc	ra,0x1
    80000f32:	7c2080e7          	jalr	1986(ra) # 800026f0 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000f36:	00005097          	auipc	ra,0x5
    80000f3a:	e0a080e7          	jalr	-502(ra) # 80005d40 <plicinithart>
  }

  scheduler();        
    80000f3e:	00001097          	auipc	ra,0x1
    80000f42:	00a080e7          	jalr	10(ra) # 80001f48 <scheduler>
    consoleinit();
    80000f46:	fffff097          	auipc	ra,0xfffff
    80000f4a:	50a080e7          	jalr	1290(ra) # 80000450 <consoleinit>
    printfinit();
    80000f4e:	00000097          	auipc	ra,0x0
    80000f52:	89a080e7          	jalr	-1894(ra) # 800007e8 <printfinit>
    printf("\n");
    80000f56:	00007517          	auipc	a0,0x7
    80000f5a:	17250513          	addi	a0,a0,370 # 800080c8 <digits+0x88>
    80000f5e:	fffff097          	auipc	ra,0xfffff
    80000f62:	62c080e7          	jalr	1580(ra) # 8000058a <printf>
    printf("xv6 kernel is booting\n");
    80000f66:	00007517          	auipc	a0,0x7
    80000f6a:	13a50513          	addi	a0,a0,314 # 800080a0 <digits+0x60>
    80000f6e:	fffff097          	auipc	ra,0xfffff
    80000f72:	61c080e7          	jalr	1564(ra) # 8000058a <printf>
    printf("\n");
    80000f76:	00007517          	auipc	a0,0x7
    80000f7a:	15250513          	addi	a0,a0,338 # 800080c8 <digits+0x88>
    80000f7e:	fffff097          	auipc	ra,0xfffff
    80000f82:	60c080e7          	jalr	1548(ra) # 8000058a <printf>
    kinit();         // physical page allocator
    80000f86:	00000097          	auipc	ra,0x0
    80000f8a:	b96080e7          	jalr	-1130(ra) # 80000b1c <kinit>
    kvminit();       // create kernel page table
    80000f8e:	00000097          	auipc	ra,0x0
    80000f92:	32e080e7          	jalr	814(ra) # 800012bc <kvminit>
    kvminithart();   // turn on paging
    80000f96:	00000097          	auipc	ra,0x0
    80000f9a:	070080e7          	jalr	112(ra) # 80001006 <kvminithart>
    procinit();      // process table
    80000f9e:	00001097          	auipc	ra,0x1
    80000fa2:	9a6080e7          	jalr	-1626(ra) # 80001944 <procinit>
    trapinit();      // trap vectors
    80000fa6:	00001097          	auipc	ra,0x1
    80000faa:	722080e7          	jalr	1826(ra) # 800026c8 <trapinit>
    trapinithart();  // install kernel trap vector
    80000fae:	00001097          	auipc	ra,0x1
    80000fb2:	742080e7          	jalr	1858(ra) # 800026f0 <trapinithart>
    plicinit();      // set up interrupt controller
    80000fb6:	00005097          	auipc	ra,0x5
    80000fba:	d74080e7          	jalr	-652(ra) # 80005d2a <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000fbe:	00005097          	auipc	ra,0x5
    80000fc2:	d82080e7          	jalr	-638(ra) # 80005d40 <plicinithart>
    binit();         // buffer cache
    80000fc6:	00002097          	auipc	ra,0x2
    80000fca:	f1e080e7          	jalr	-226(ra) # 80002ee4 <binit>
    iinit();         // inode table
    80000fce:	00002097          	auipc	ra,0x2
    80000fd2:	5bc080e7          	jalr	1468(ra) # 8000358a <iinit>
    fileinit();      // file table
    80000fd6:	00003097          	auipc	ra,0x3
    80000fda:	532080e7          	jalr	1330(ra) # 80004508 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000fde:	00005097          	auipc	ra,0x5
    80000fe2:	e6a080e7          	jalr	-406(ra) # 80005e48 <virtio_disk_init>
    userinit();      // first user process
    80000fe6:	00001097          	auipc	ra,0x1
    80000fea:	d44080e7          	jalr	-700(ra) # 80001d2a <userinit>
    trap_and_emulate_init();
    80000fee:	00006097          	auipc	ra,0x6
    80000ff2:	dbe080e7          	jalr	-578(ra) # 80006dac <trap_and_emulate_init>
    __sync_synchronize();
    80000ff6:	0ff0000f          	fence
    started = 1;
    80000ffa:	4785                	li	a5,1
    80000ffc:	00008717          	auipc	a4,0x8
    80001000:	9cf72e23          	sw	a5,-1572(a4) # 800089d8 <started>
    80001004:	bf2d                	j	80000f3e <main+0x56>

0000000080001006 <kvminithart>:

// Switch h/w page table register to the kernel's page table,
// and enable paging.
void
kvminithart()
{
    80001006:	1141                	addi	sp,sp,-16
    80001008:	e422                	sd	s0,8(sp)
    8000100a:	0800                	addi	s0,sp,16
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    8000100c:	12000073          	sfence.vma
  // wait for any previous writes to the page table memory to finish.
  sfence_vma();

  w_satp(MAKE_SATP(kernel_pagetable));
    80001010:	00008797          	auipc	a5,0x8
    80001014:	9d07b783          	ld	a5,-1584(a5) # 800089e0 <kernel_pagetable>
    80001018:	83b1                	srli	a5,a5,0xc
    8000101a:	577d                	li	a4,-1
    8000101c:	177e                	slli	a4,a4,0x3f
    8000101e:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    80001020:	18079073          	csrw	satp,a5
  asm volatile("sfence.vma zero, zero");
    80001024:	12000073          	sfence.vma

  // flush stale entries from the TLB.
  sfence_vma();
}
    80001028:	6422                	ld	s0,8(sp)
    8000102a:	0141                	addi	sp,sp,16
    8000102c:	8082                	ret

000000008000102e <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    8000102e:	7139                	addi	sp,sp,-64
    80001030:	fc06                	sd	ra,56(sp)
    80001032:	f822                	sd	s0,48(sp)
    80001034:	f426                	sd	s1,40(sp)
    80001036:	f04a                	sd	s2,32(sp)
    80001038:	ec4e                	sd	s3,24(sp)
    8000103a:	e852                	sd	s4,16(sp)
    8000103c:	e456                	sd	s5,8(sp)
    8000103e:	e05a                	sd	s6,0(sp)
    80001040:	0080                	addi	s0,sp,64
    80001042:	84aa                	mv	s1,a0
    80001044:	89ae                	mv	s3,a1
    80001046:	8ab2                	mv	s5,a2
  if(va >= MAXVA)
    80001048:	57fd                	li	a5,-1
    8000104a:	83e9                	srli	a5,a5,0x1a
    8000104c:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    8000104e:	4b31                	li	s6,12
  if(va >= MAXVA)
    80001050:	04b7f263          	bgeu	a5,a1,80001094 <walk+0x66>
    panic("walk");
    80001054:	00007517          	auipc	a0,0x7
    80001058:	07c50513          	addi	a0,a0,124 # 800080d0 <digits+0x90>
    8000105c:	fffff097          	auipc	ra,0xfffff
    80001060:	4e4080e7          	jalr	1252(ra) # 80000540 <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    80001064:	060a8663          	beqz	s5,800010d0 <walk+0xa2>
    80001068:	00000097          	auipc	ra,0x0
    8000106c:	af0080e7          	jalr	-1296(ra) # 80000b58 <kalloc>
    80001070:	84aa                	mv	s1,a0
    80001072:	c529                	beqz	a0,800010bc <walk+0x8e>
        return 0;
      memset(pagetable, 0, PGSIZE);
    80001074:	6605                	lui	a2,0x1
    80001076:	4581                	li	a1,0
    80001078:	00000097          	auipc	ra,0x0
    8000107c:	ccc080e7          	jalr	-820(ra) # 80000d44 <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    80001080:	00c4d793          	srli	a5,s1,0xc
    80001084:	07aa                	slli	a5,a5,0xa
    80001086:	0017e793          	ori	a5,a5,1
    8000108a:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    8000108e:	3a5d                	addiw	s4,s4,-9 # ffffffffffffeff7 <end+0xffffffff7ffdcbaf>
    80001090:	036a0063          	beq	s4,s6,800010b0 <walk+0x82>
    pte_t *pte = &pagetable[PX(level, va)];
    80001094:	0149d933          	srl	s2,s3,s4
    80001098:	1ff97913          	andi	s2,s2,511
    8000109c:	090e                	slli	s2,s2,0x3
    8000109e:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    800010a0:	00093483          	ld	s1,0(s2)
    800010a4:	0014f793          	andi	a5,s1,1
    800010a8:	dfd5                	beqz	a5,80001064 <walk+0x36>
      pagetable = (pagetable_t)PTE2PA(*pte);
    800010aa:	80a9                	srli	s1,s1,0xa
    800010ac:	04b2                	slli	s1,s1,0xc
    800010ae:	b7c5                	j	8000108e <walk+0x60>
    }
  }
  return &pagetable[PX(0, va)];
    800010b0:	00c9d513          	srli	a0,s3,0xc
    800010b4:	1ff57513          	andi	a0,a0,511
    800010b8:	050e                	slli	a0,a0,0x3
    800010ba:	9526                	add	a0,a0,s1
}
    800010bc:	70e2                	ld	ra,56(sp)
    800010be:	7442                	ld	s0,48(sp)
    800010c0:	74a2                	ld	s1,40(sp)
    800010c2:	7902                	ld	s2,32(sp)
    800010c4:	69e2                	ld	s3,24(sp)
    800010c6:	6a42                	ld	s4,16(sp)
    800010c8:	6aa2                	ld	s5,8(sp)
    800010ca:	6b02                	ld	s6,0(sp)
    800010cc:	6121                	addi	sp,sp,64
    800010ce:	8082                	ret
        return 0;
    800010d0:	4501                	li	a0,0
    800010d2:	b7ed                	j	800010bc <walk+0x8e>

00000000800010d4 <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    800010d4:	57fd                	li	a5,-1
    800010d6:	83e9                	srli	a5,a5,0x1a
    800010d8:	00b7f463          	bgeu	a5,a1,800010e0 <walkaddr+0xc>
    return 0;
    800010dc:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    800010de:	8082                	ret
{
    800010e0:	1141                	addi	sp,sp,-16
    800010e2:	e406                	sd	ra,8(sp)
    800010e4:	e022                	sd	s0,0(sp)
    800010e6:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    800010e8:	4601                	li	a2,0
    800010ea:	00000097          	auipc	ra,0x0
    800010ee:	f44080e7          	jalr	-188(ra) # 8000102e <walk>
  if(pte == 0)
    800010f2:	c105                	beqz	a0,80001112 <walkaddr+0x3e>
  if((*pte & PTE_V) == 0)
    800010f4:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    800010f6:	0117f693          	andi	a3,a5,17
    800010fa:	4745                	li	a4,17
    return 0;
    800010fc:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    800010fe:	00e68663          	beq	a3,a4,8000110a <walkaddr+0x36>
}
    80001102:	60a2                	ld	ra,8(sp)
    80001104:	6402                	ld	s0,0(sp)
    80001106:	0141                	addi	sp,sp,16
    80001108:	8082                	ret
  pa = PTE2PA(*pte);
    8000110a:	83a9                	srli	a5,a5,0xa
    8000110c:	00c79513          	slli	a0,a5,0xc
  return pa;
    80001110:	bfcd                	j	80001102 <walkaddr+0x2e>
    return 0;
    80001112:	4501                	li	a0,0
    80001114:	b7fd                	j	80001102 <walkaddr+0x2e>

0000000080001116 <mappages>:
// physical addresses starting at pa. va and size might not
// be page-aligned. Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    80001116:	715d                	addi	sp,sp,-80
    80001118:	e486                	sd	ra,72(sp)
    8000111a:	e0a2                	sd	s0,64(sp)
    8000111c:	fc26                	sd	s1,56(sp)
    8000111e:	f84a                	sd	s2,48(sp)
    80001120:	f44e                	sd	s3,40(sp)
    80001122:	f052                	sd	s4,32(sp)
    80001124:	ec56                	sd	s5,24(sp)
    80001126:	e85a                	sd	s6,16(sp)
    80001128:	e45e                	sd	s7,8(sp)
    8000112a:	0880                	addi	s0,sp,80
  uint64 a, last;
  pte_t *pte;

  if(size == 0)
    8000112c:	c639                	beqz	a2,8000117a <mappages+0x64>
    8000112e:	8aaa                	mv	s5,a0
    80001130:	8b3a                	mv	s6,a4
    panic("mappages: size");
  
  a = PGROUNDDOWN(va);
    80001132:	777d                	lui	a4,0xfffff
    80001134:	00e5f7b3          	and	a5,a1,a4
  last = PGROUNDDOWN(va + size - 1);
    80001138:	fff58993          	addi	s3,a1,-1
    8000113c:	99b2                	add	s3,s3,a2
    8000113e:	00e9f9b3          	and	s3,s3,a4
  a = PGROUNDDOWN(va);
    80001142:	893e                	mv	s2,a5
    80001144:	40f68a33          	sub	s4,a3,a5
    if(*pte & PTE_V)
      panic("mappages: remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    80001148:	6b85                	lui	s7,0x1
    8000114a:	012a04b3          	add	s1,s4,s2
    if((pte = walk(pagetable, a, 1)) == 0)
    8000114e:	4605                	li	a2,1
    80001150:	85ca                	mv	a1,s2
    80001152:	8556                	mv	a0,s5
    80001154:	00000097          	auipc	ra,0x0
    80001158:	eda080e7          	jalr	-294(ra) # 8000102e <walk>
    8000115c:	cd1d                	beqz	a0,8000119a <mappages+0x84>
    if(*pte & PTE_V)
    8000115e:	611c                	ld	a5,0(a0)
    80001160:	8b85                	andi	a5,a5,1
    80001162:	e785                	bnez	a5,8000118a <mappages+0x74>
    *pte = PA2PTE(pa) | perm | PTE_V;
    80001164:	80b1                	srli	s1,s1,0xc
    80001166:	04aa                	slli	s1,s1,0xa
    80001168:	0164e4b3          	or	s1,s1,s6
    8000116c:	0014e493          	ori	s1,s1,1
    80001170:	e104                	sd	s1,0(a0)
    if(a == last)
    80001172:	05390063          	beq	s2,s3,800011b2 <mappages+0x9c>
    a += PGSIZE;
    80001176:	995e                	add	s2,s2,s7
    if((pte = walk(pagetable, a, 1)) == 0)
    80001178:	bfc9                	j	8000114a <mappages+0x34>
    panic("mappages: size");
    8000117a:	00007517          	auipc	a0,0x7
    8000117e:	f5e50513          	addi	a0,a0,-162 # 800080d8 <digits+0x98>
    80001182:	fffff097          	auipc	ra,0xfffff
    80001186:	3be080e7          	jalr	958(ra) # 80000540 <panic>
      panic("mappages: remap");
    8000118a:	00007517          	auipc	a0,0x7
    8000118e:	f5e50513          	addi	a0,a0,-162 # 800080e8 <digits+0xa8>
    80001192:	fffff097          	auipc	ra,0xfffff
    80001196:	3ae080e7          	jalr	942(ra) # 80000540 <panic>
      return -1;
    8000119a:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    8000119c:	60a6                	ld	ra,72(sp)
    8000119e:	6406                	ld	s0,64(sp)
    800011a0:	74e2                	ld	s1,56(sp)
    800011a2:	7942                	ld	s2,48(sp)
    800011a4:	79a2                	ld	s3,40(sp)
    800011a6:	7a02                	ld	s4,32(sp)
    800011a8:	6ae2                	ld	s5,24(sp)
    800011aa:	6b42                	ld	s6,16(sp)
    800011ac:	6ba2                	ld	s7,8(sp)
    800011ae:	6161                	addi	sp,sp,80
    800011b0:	8082                	ret
  return 0;
    800011b2:	4501                	li	a0,0
    800011b4:	b7e5                	j	8000119c <mappages+0x86>

00000000800011b6 <kvmmap>:
{
    800011b6:	1141                	addi	sp,sp,-16
    800011b8:	e406                	sd	ra,8(sp)
    800011ba:	e022                	sd	s0,0(sp)
    800011bc:	0800                	addi	s0,sp,16
    800011be:	87b6                	mv	a5,a3
  if(mappages(kpgtbl, va, sz, pa, perm) != 0)
    800011c0:	86b2                	mv	a3,a2
    800011c2:	863e                	mv	a2,a5
    800011c4:	00000097          	auipc	ra,0x0
    800011c8:	f52080e7          	jalr	-174(ra) # 80001116 <mappages>
    800011cc:	e509                	bnez	a0,800011d6 <kvmmap+0x20>
}
    800011ce:	60a2                	ld	ra,8(sp)
    800011d0:	6402                	ld	s0,0(sp)
    800011d2:	0141                	addi	sp,sp,16
    800011d4:	8082                	ret
    panic("kvmmap");
    800011d6:	00007517          	auipc	a0,0x7
    800011da:	f2250513          	addi	a0,a0,-222 # 800080f8 <digits+0xb8>
    800011de:	fffff097          	auipc	ra,0xfffff
    800011e2:	362080e7          	jalr	866(ra) # 80000540 <panic>

00000000800011e6 <kvmmake>:
{
    800011e6:	1101                	addi	sp,sp,-32
    800011e8:	ec06                	sd	ra,24(sp)
    800011ea:	e822                	sd	s0,16(sp)
    800011ec:	e426                	sd	s1,8(sp)
    800011ee:	e04a                	sd	s2,0(sp)
    800011f0:	1000                	addi	s0,sp,32
  kpgtbl = (pagetable_t) kalloc();
    800011f2:	00000097          	auipc	ra,0x0
    800011f6:	966080e7          	jalr	-1690(ra) # 80000b58 <kalloc>
    800011fa:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    800011fc:	6605                	lui	a2,0x1
    800011fe:	4581                	li	a1,0
    80001200:	00000097          	auipc	ra,0x0
    80001204:	b44080e7          	jalr	-1212(ra) # 80000d44 <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    80001208:	4719                	li	a4,6
    8000120a:	6685                	lui	a3,0x1
    8000120c:	10000637          	lui	a2,0x10000
    80001210:	100005b7          	lui	a1,0x10000
    80001214:	8526                	mv	a0,s1
    80001216:	00000097          	auipc	ra,0x0
    8000121a:	fa0080e7          	jalr	-96(ra) # 800011b6 <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    8000121e:	4719                	li	a4,6
    80001220:	6685                	lui	a3,0x1
    80001222:	10001637          	lui	a2,0x10001
    80001226:	100015b7          	lui	a1,0x10001
    8000122a:	8526                	mv	a0,s1
    8000122c:	00000097          	auipc	ra,0x0
    80001230:	f8a080e7          	jalr	-118(ra) # 800011b6 <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x400000, PTE_R | PTE_W);
    80001234:	4719                	li	a4,6
    80001236:	004006b7          	lui	a3,0x400
    8000123a:	0c000637          	lui	a2,0xc000
    8000123e:	0c0005b7          	lui	a1,0xc000
    80001242:	8526                	mv	a0,s1
    80001244:	00000097          	auipc	ra,0x0
    80001248:	f72080e7          	jalr	-142(ra) # 800011b6 <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    8000124c:	00007917          	auipc	s2,0x7
    80001250:	db490913          	addi	s2,s2,-588 # 80008000 <etext>
    80001254:	4729                	li	a4,10
    80001256:	80007697          	auipc	a3,0x80007
    8000125a:	daa68693          	addi	a3,a3,-598 # 8000 <_entry-0x7fff8000>
    8000125e:	4605                	li	a2,1
    80001260:	067e                	slli	a2,a2,0x1f
    80001262:	85b2                	mv	a1,a2
    80001264:	8526                	mv	a0,s1
    80001266:	00000097          	auipc	ra,0x0
    8000126a:	f50080e7          	jalr	-176(ra) # 800011b6 <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    8000126e:	4719                	li	a4,6
    80001270:	46c5                	li	a3,17
    80001272:	06ee                	slli	a3,a3,0x1b
    80001274:	412686b3          	sub	a3,a3,s2
    80001278:	864a                	mv	a2,s2
    8000127a:	85ca                	mv	a1,s2
    8000127c:	8526                	mv	a0,s1
    8000127e:	00000097          	auipc	ra,0x0
    80001282:	f38080e7          	jalr	-200(ra) # 800011b6 <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    80001286:	4729                	li	a4,10
    80001288:	6685                	lui	a3,0x1
    8000128a:	00006617          	auipc	a2,0x6
    8000128e:	d7660613          	addi	a2,a2,-650 # 80007000 <_trampoline>
    80001292:	040005b7          	lui	a1,0x4000
    80001296:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001298:	05b2                	slli	a1,a1,0xc
    8000129a:	8526                	mv	a0,s1
    8000129c:	00000097          	auipc	ra,0x0
    800012a0:	f1a080e7          	jalr	-230(ra) # 800011b6 <kvmmap>
  proc_mapstacks(kpgtbl);
    800012a4:	8526                	mv	a0,s1
    800012a6:	00000097          	auipc	ra,0x0
    800012aa:	608080e7          	jalr	1544(ra) # 800018ae <proc_mapstacks>
}
    800012ae:	8526                	mv	a0,s1
    800012b0:	60e2                	ld	ra,24(sp)
    800012b2:	6442                	ld	s0,16(sp)
    800012b4:	64a2                	ld	s1,8(sp)
    800012b6:	6902                	ld	s2,0(sp)
    800012b8:	6105                	addi	sp,sp,32
    800012ba:	8082                	ret

00000000800012bc <kvminit>:
{
    800012bc:	1141                	addi	sp,sp,-16
    800012be:	e406                	sd	ra,8(sp)
    800012c0:	e022                	sd	s0,0(sp)
    800012c2:	0800                	addi	s0,sp,16
  kernel_pagetable = kvmmake();
    800012c4:	00000097          	auipc	ra,0x0
    800012c8:	f22080e7          	jalr	-222(ra) # 800011e6 <kvmmake>
    800012cc:	00007797          	auipc	a5,0x7
    800012d0:	70a7ba23          	sd	a0,1812(a5) # 800089e0 <kernel_pagetable>
}
    800012d4:	60a2                	ld	ra,8(sp)
    800012d6:	6402                	ld	s0,0(sp)
    800012d8:	0141                	addi	sp,sp,16
    800012da:	8082                	ret

00000000800012dc <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. The mappings must exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    800012dc:	715d                	addi	sp,sp,-80
    800012de:	e486                	sd	ra,72(sp)
    800012e0:	e0a2                	sd	s0,64(sp)
    800012e2:	fc26                	sd	s1,56(sp)
    800012e4:	f84a                	sd	s2,48(sp)
    800012e6:	f44e                	sd	s3,40(sp)
    800012e8:	f052                	sd	s4,32(sp)
    800012ea:	ec56                	sd	s5,24(sp)
    800012ec:	e85a                	sd	s6,16(sp)
    800012ee:	e45e                	sd	s7,8(sp)
    800012f0:	0880                	addi	s0,sp,80
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    800012f2:	03459793          	slli	a5,a1,0x34
    800012f6:	e795                	bnez	a5,80001322 <uvmunmap+0x46>
    800012f8:	8a2a                	mv	s4,a0
    800012fa:	892e                	mv	s2,a1
    800012fc:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800012fe:	0632                	slli	a2,a2,0xc
    80001300:	00b609b3          	add	s3,a2,a1
    if((pte = walk(pagetable, a, 0)) == 0)
      panic("uvmunmap: walk");
    if((*pte & PTE_V) == 0)
      panic("uvmunmap: not mapped");
    if(PTE_FLAGS(*pte) == PTE_V)
    80001304:	4b85                	li	s7,1
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001306:	6b05                	lui	s6,0x1
    80001308:	0735e263          	bltu	a1,s3,8000136c <uvmunmap+0x90>
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
  }
}
    8000130c:	60a6                	ld	ra,72(sp)
    8000130e:	6406                	ld	s0,64(sp)
    80001310:	74e2                	ld	s1,56(sp)
    80001312:	7942                	ld	s2,48(sp)
    80001314:	79a2                	ld	s3,40(sp)
    80001316:	7a02                	ld	s4,32(sp)
    80001318:	6ae2                	ld	s5,24(sp)
    8000131a:	6b42                	ld	s6,16(sp)
    8000131c:	6ba2                	ld	s7,8(sp)
    8000131e:	6161                	addi	sp,sp,80
    80001320:	8082                	ret
    panic("uvmunmap: not aligned");
    80001322:	00007517          	auipc	a0,0x7
    80001326:	dde50513          	addi	a0,a0,-546 # 80008100 <digits+0xc0>
    8000132a:	fffff097          	auipc	ra,0xfffff
    8000132e:	216080e7          	jalr	534(ra) # 80000540 <panic>
      panic("uvmunmap: walk");
    80001332:	00007517          	auipc	a0,0x7
    80001336:	de650513          	addi	a0,a0,-538 # 80008118 <digits+0xd8>
    8000133a:	fffff097          	auipc	ra,0xfffff
    8000133e:	206080e7          	jalr	518(ra) # 80000540 <panic>
      panic("uvmunmap: not mapped");
    80001342:	00007517          	auipc	a0,0x7
    80001346:	de650513          	addi	a0,a0,-538 # 80008128 <digits+0xe8>
    8000134a:	fffff097          	auipc	ra,0xfffff
    8000134e:	1f6080e7          	jalr	502(ra) # 80000540 <panic>
      panic("uvmunmap: not a leaf");
    80001352:	00007517          	auipc	a0,0x7
    80001356:	dee50513          	addi	a0,a0,-530 # 80008140 <digits+0x100>
    8000135a:	fffff097          	auipc	ra,0xfffff
    8000135e:	1e6080e7          	jalr	486(ra) # 80000540 <panic>
    *pte = 0;
    80001362:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001366:	995a                	add	s2,s2,s6
    80001368:	fb3972e3          	bgeu	s2,s3,8000130c <uvmunmap+0x30>
    if((pte = walk(pagetable, a, 0)) == 0)
    8000136c:	4601                	li	a2,0
    8000136e:	85ca                	mv	a1,s2
    80001370:	8552                	mv	a0,s4
    80001372:	00000097          	auipc	ra,0x0
    80001376:	cbc080e7          	jalr	-836(ra) # 8000102e <walk>
    8000137a:	84aa                	mv	s1,a0
    8000137c:	d95d                	beqz	a0,80001332 <uvmunmap+0x56>
    if((*pte & PTE_V) == 0)
    8000137e:	6108                	ld	a0,0(a0)
    80001380:	00157793          	andi	a5,a0,1
    80001384:	dfdd                	beqz	a5,80001342 <uvmunmap+0x66>
    if(PTE_FLAGS(*pte) == PTE_V)
    80001386:	3ff57793          	andi	a5,a0,1023
    8000138a:	fd7784e3          	beq	a5,s7,80001352 <uvmunmap+0x76>
    if(do_free){
    8000138e:	fc0a8ae3          	beqz	s5,80001362 <uvmunmap+0x86>
      uint64 pa = PTE2PA(*pte);
    80001392:	8129                	srli	a0,a0,0xa
      kfree((void*)pa);
    80001394:	0532                	slli	a0,a0,0xc
    80001396:	fffff097          	auipc	ra,0xfffff
    8000139a:	6c4080e7          	jalr	1732(ra) # 80000a5a <kfree>
    8000139e:	b7d1                	j	80001362 <uvmunmap+0x86>

00000000800013a0 <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    800013a0:	1101                	addi	sp,sp,-32
    800013a2:	ec06                	sd	ra,24(sp)
    800013a4:	e822                	sd	s0,16(sp)
    800013a6:	e426                	sd	s1,8(sp)
    800013a8:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    800013aa:	fffff097          	auipc	ra,0xfffff
    800013ae:	7ae080e7          	jalr	1966(ra) # 80000b58 <kalloc>
    800013b2:	84aa                	mv	s1,a0
  if(pagetable == 0)
    800013b4:	c519                	beqz	a0,800013c2 <uvmcreate+0x22>
    return 0;
  memset(pagetable, 0, PGSIZE);
    800013b6:	6605                	lui	a2,0x1
    800013b8:	4581                	li	a1,0
    800013ba:	00000097          	auipc	ra,0x0
    800013be:	98a080e7          	jalr	-1654(ra) # 80000d44 <memset>
  return pagetable;
}
    800013c2:	8526                	mv	a0,s1
    800013c4:	60e2                	ld	ra,24(sp)
    800013c6:	6442                	ld	s0,16(sp)
    800013c8:	64a2                	ld	s1,8(sp)
    800013ca:	6105                	addi	sp,sp,32
    800013cc:	8082                	ret

00000000800013ce <uvmfirst>:
// Load the user initcode into address 0 of pagetable,
// for the very first process.
// sz must be less than a page.
void
uvmfirst(pagetable_t pagetable, uchar *src, uint sz)
{
    800013ce:	7179                	addi	sp,sp,-48
    800013d0:	f406                	sd	ra,40(sp)
    800013d2:	f022                	sd	s0,32(sp)
    800013d4:	ec26                	sd	s1,24(sp)
    800013d6:	e84a                	sd	s2,16(sp)
    800013d8:	e44e                	sd	s3,8(sp)
    800013da:	e052                	sd	s4,0(sp)
    800013dc:	1800                	addi	s0,sp,48
  char *mem;

  if(sz >= PGSIZE)
    800013de:	6785                	lui	a5,0x1
    800013e0:	04f67863          	bgeu	a2,a5,80001430 <uvmfirst+0x62>
    800013e4:	8a2a                	mv	s4,a0
    800013e6:	89ae                	mv	s3,a1
    800013e8:	84b2                	mv	s1,a2
    panic("uvmfirst: more than a page");
  mem = kalloc();
    800013ea:	fffff097          	auipc	ra,0xfffff
    800013ee:	76e080e7          	jalr	1902(ra) # 80000b58 <kalloc>
    800013f2:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    800013f4:	6605                	lui	a2,0x1
    800013f6:	4581                	li	a1,0
    800013f8:	00000097          	auipc	ra,0x0
    800013fc:	94c080e7          	jalr	-1716(ra) # 80000d44 <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
    80001400:	4779                	li	a4,30
    80001402:	86ca                	mv	a3,s2
    80001404:	6605                	lui	a2,0x1
    80001406:	4581                	li	a1,0
    80001408:	8552                	mv	a0,s4
    8000140a:	00000097          	auipc	ra,0x0
    8000140e:	d0c080e7          	jalr	-756(ra) # 80001116 <mappages>
  memmove(mem, src, sz);
    80001412:	8626                	mv	a2,s1
    80001414:	85ce                	mv	a1,s3
    80001416:	854a                	mv	a0,s2
    80001418:	00000097          	auipc	ra,0x0
    8000141c:	988080e7          	jalr	-1656(ra) # 80000da0 <memmove>
}
    80001420:	70a2                	ld	ra,40(sp)
    80001422:	7402                	ld	s0,32(sp)
    80001424:	64e2                	ld	s1,24(sp)
    80001426:	6942                	ld	s2,16(sp)
    80001428:	69a2                	ld	s3,8(sp)
    8000142a:	6a02                	ld	s4,0(sp)
    8000142c:	6145                	addi	sp,sp,48
    8000142e:	8082                	ret
    panic("uvmfirst: more than a page");
    80001430:	00007517          	auipc	a0,0x7
    80001434:	d2850513          	addi	a0,a0,-728 # 80008158 <digits+0x118>
    80001438:	fffff097          	auipc	ra,0xfffff
    8000143c:	108080e7          	jalr	264(ra) # 80000540 <panic>

0000000080001440 <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    80001440:	1101                	addi	sp,sp,-32
    80001442:	ec06                	sd	ra,24(sp)
    80001444:	e822                	sd	s0,16(sp)
    80001446:	e426                	sd	s1,8(sp)
    80001448:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    8000144a:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    8000144c:	00b67d63          	bgeu	a2,a1,80001466 <uvmdealloc+0x26>
    80001450:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    80001452:	6785                	lui	a5,0x1
    80001454:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80001456:	00f60733          	add	a4,a2,a5
    8000145a:	76fd                	lui	a3,0xfffff
    8000145c:	8f75                	and	a4,a4,a3
    8000145e:	97ae                	add	a5,a5,a1
    80001460:	8ff5                	and	a5,a5,a3
    80001462:	00f76863          	bltu	a4,a5,80001472 <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    80001466:	8526                	mv	a0,s1
    80001468:	60e2                	ld	ra,24(sp)
    8000146a:	6442                	ld	s0,16(sp)
    8000146c:	64a2                	ld	s1,8(sp)
    8000146e:	6105                	addi	sp,sp,32
    80001470:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    80001472:	8f99                	sub	a5,a5,a4
    80001474:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    80001476:	4685                	li	a3,1
    80001478:	0007861b          	sext.w	a2,a5
    8000147c:	85ba                	mv	a1,a4
    8000147e:	00000097          	auipc	ra,0x0
    80001482:	e5e080e7          	jalr	-418(ra) # 800012dc <uvmunmap>
    80001486:	b7c5                	j	80001466 <uvmdealloc+0x26>

0000000080001488 <uvmalloc>:
  if(newsz < oldsz)
    80001488:	0ab66563          	bltu	a2,a1,80001532 <uvmalloc+0xaa>
{
    8000148c:	7139                	addi	sp,sp,-64
    8000148e:	fc06                	sd	ra,56(sp)
    80001490:	f822                	sd	s0,48(sp)
    80001492:	f426                	sd	s1,40(sp)
    80001494:	f04a                	sd	s2,32(sp)
    80001496:	ec4e                	sd	s3,24(sp)
    80001498:	e852                	sd	s4,16(sp)
    8000149a:	e456                	sd	s5,8(sp)
    8000149c:	e05a                	sd	s6,0(sp)
    8000149e:	0080                	addi	s0,sp,64
    800014a0:	8aaa                	mv	s5,a0
    800014a2:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    800014a4:	6785                	lui	a5,0x1
    800014a6:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    800014a8:	95be                	add	a1,a1,a5
    800014aa:	77fd                	lui	a5,0xfffff
    800014ac:	00f5f9b3          	and	s3,a1,a5
  for(a = oldsz; a < newsz; a += PGSIZE){
    800014b0:	08c9f363          	bgeu	s3,a2,80001536 <uvmalloc+0xae>
    800014b4:	894e                	mv	s2,s3
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    800014b6:	0126eb13          	ori	s6,a3,18
    mem = kalloc();
    800014ba:	fffff097          	auipc	ra,0xfffff
    800014be:	69e080e7          	jalr	1694(ra) # 80000b58 <kalloc>
    800014c2:	84aa                	mv	s1,a0
    if(mem == 0){
    800014c4:	c51d                	beqz	a0,800014f2 <uvmalloc+0x6a>
    memset(mem, 0, PGSIZE);
    800014c6:	6605                	lui	a2,0x1
    800014c8:	4581                	li	a1,0
    800014ca:	00000097          	auipc	ra,0x0
    800014ce:	87a080e7          	jalr	-1926(ra) # 80000d44 <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    800014d2:	875a                	mv	a4,s6
    800014d4:	86a6                	mv	a3,s1
    800014d6:	6605                	lui	a2,0x1
    800014d8:	85ca                	mv	a1,s2
    800014da:	8556                	mv	a0,s5
    800014dc:	00000097          	auipc	ra,0x0
    800014e0:	c3a080e7          	jalr	-966(ra) # 80001116 <mappages>
    800014e4:	e90d                	bnez	a0,80001516 <uvmalloc+0x8e>
  for(a = oldsz; a < newsz; a += PGSIZE){
    800014e6:	6785                	lui	a5,0x1
    800014e8:	993e                	add	s2,s2,a5
    800014ea:	fd4968e3          	bltu	s2,s4,800014ba <uvmalloc+0x32>
  return newsz;
    800014ee:	8552                	mv	a0,s4
    800014f0:	a809                	j	80001502 <uvmalloc+0x7a>
      uvmdealloc(pagetable, a, oldsz);
    800014f2:	864e                	mv	a2,s3
    800014f4:	85ca                	mv	a1,s2
    800014f6:	8556                	mv	a0,s5
    800014f8:	00000097          	auipc	ra,0x0
    800014fc:	f48080e7          	jalr	-184(ra) # 80001440 <uvmdealloc>
      return 0;
    80001500:	4501                	li	a0,0
}
    80001502:	70e2                	ld	ra,56(sp)
    80001504:	7442                	ld	s0,48(sp)
    80001506:	74a2                	ld	s1,40(sp)
    80001508:	7902                	ld	s2,32(sp)
    8000150a:	69e2                	ld	s3,24(sp)
    8000150c:	6a42                	ld	s4,16(sp)
    8000150e:	6aa2                	ld	s5,8(sp)
    80001510:	6b02                	ld	s6,0(sp)
    80001512:	6121                	addi	sp,sp,64
    80001514:	8082                	ret
      kfree(mem);
    80001516:	8526                	mv	a0,s1
    80001518:	fffff097          	auipc	ra,0xfffff
    8000151c:	542080e7          	jalr	1346(ra) # 80000a5a <kfree>
      uvmdealloc(pagetable, a, oldsz);
    80001520:	864e                	mv	a2,s3
    80001522:	85ca                	mv	a1,s2
    80001524:	8556                	mv	a0,s5
    80001526:	00000097          	auipc	ra,0x0
    8000152a:	f1a080e7          	jalr	-230(ra) # 80001440 <uvmdealloc>
      return 0;
    8000152e:	4501                	li	a0,0
    80001530:	bfc9                	j	80001502 <uvmalloc+0x7a>
    return oldsz;
    80001532:	852e                	mv	a0,a1
}
    80001534:	8082                	ret
  return newsz;
    80001536:	8532                	mv	a0,a2
    80001538:	b7e9                	j	80001502 <uvmalloc+0x7a>

000000008000153a <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    8000153a:	7179                	addi	sp,sp,-48
    8000153c:	f406                	sd	ra,40(sp)
    8000153e:	f022                	sd	s0,32(sp)
    80001540:	ec26                	sd	s1,24(sp)
    80001542:	e84a                	sd	s2,16(sp)
    80001544:	e44e                	sd	s3,8(sp)
    80001546:	e052                	sd	s4,0(sp)
    80001548:	1800                	addi	s0,sp,48
    8000154a:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    8000154c:	84aa                	mv	s1,a0
    8000154e:	6905                	lui	s2,0x1
    80001550:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    80001552:	4985                	li	s3,1
    80001554:	a829                	j	8000156e <freewalk+0x34>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    80001556:	83a9                	srli	a5,a5,0xa
      freewalk((pagetable_t)child);
    80001558:	00c79513          	slli	a0,a5,0xc
    8000155c:	00000097          	auipc	ra,0x0
    80001560:	fde080e7          	jalr	-34(ra) # 8000153a <freewalk>
      pagetable[i] = 0;
    80001564:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    80001568:	04a1                	addi	s1,s1,8
    8000156a:	03248163          	beq	s1,s2,8000158c <freewalk+0x52>
    pte_t pte = pagetable[i];
    8000156e:	609c                	ld	a5,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    80001570:	00f7f713          	andi	a4,a5,15
    80001574:	ff3701e3          	beq	a4,s3,80001556 <freewalk+0x1c>
    } else if(pte & PTE_V){
    80001578:	8b85                	andi	a5,a5,1
    8000157a:	d7fd                	beqz	a5,80001568 <freewalk+0x2e>
      panic("freewalk: leaf");
    8000157c:	00007517          	auipc	a0,0x7
    80001580:	bfc50513          	addi	a0,a0,-1028 # 80008178 <digits+0x138>
    80001584:	fffff097          	auipc	ra,0xfffff
    80001588:	fbc080e7          	jalr	-68(ra) # 80000540 <panic>
    }
  }
  kfree((void*)pagetable);
    8000158c:	8552                	mv	a0,s4
    8000158e:	fffff097          	auipc	ra,0xfffff
    80001592:	4cc080e7          	jalr	1228(ra) # 80000a5a <kfree>
}
    80001596:	70a2                	ld	ra,40(sp)
    80001598:	7402                	ld	s0,32(sp)
    8000159a:	64e2                	ld	s1,24(sp)
    8000159c:	6942                	ld	s2,16(sp)
    8000159e:	69a2                	ld	s3,8(sp)
    800015a0:	6a02                	ld	s4,0(sp)
    800015a2:	6145                	addi	sp,sp,48
    800015a4:	8082                	ret

00000000800015a6 <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    800015a6:	1101                	addi	sp,sp,-32
    800015a8:	ec06                	sd	ra,24(sp)
    800015aa:	e822                	sd	s0,16(sp)
    800015ac:	e426                	sd	s1,8(sp)
    800015ae:	1000                	addi	s0,sp,32
    800015b0:	84aa                	mv	s1,a0
  if(sz > 0)
    800015b2:	e999                	bnez	a1,800015c8 <uvmfree+0x22>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    800015b4:	8526                	mv	a0,s1
    800015b6:	00000097          	auipc	ra,0x0
    800015ba:	f84080e7          	jalr	-124(ra) # 8000153a <freewalk>
}
    800015be:	60e2                	ld	ra,24(sp)
    800015c0:	6442                	ld	s0,16(sp)
    800015c2:	64a2                	ld	s1,8(sp)
    800015c4:	6105                	addi	sp,sp,32
    800015c6:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    800015c8:	6785                	lui	a5,0x1
    800015ca:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    800015cc:	95be                	add	a1,a1,a5
    800015ce:	4685                	li	a3,1
    800015d0:	00c5d613          	srli	a2,a1,0xc
    800015d4:	4581                	li	a1,0
    800015d6:	00000097          	auipc	ra,0x0
    800015da:	d06080e7          	jalr	-762(ra) # 800012dc <uvmunmap>
    800015de:	bfd9                	j	800015b4 <uvmfree+0xe>

00000000800015e0 <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    800015e0:	c679                	beqz	a2,800016ae <uvmcopy+0xce>
{
    800015e2:	715d                	addi	sp,sp,-80
    800015e4:	e486                	sd	ra,72(sp)
    800015e6:	e0a2                	sd	s0,64(sp)
    800015e8:	fc26                	sd	s1,56(sp)
    800015ea:	f84a                	sd	s2,48(sp)
    800015ec:	f44e                	sd	s3,40(sp)
    800015ee:	f052                	sd	s4,32(sp)
    800015f0:	ec56                	sd	s5,24(sp)
    800015f2:	e85a                	sd	s6,16(sp)
    800015f4:	e45e                	sd	s7,8(sp)
    800015f6:	0880                	addi	s0,sp,80
    800015f8:	8b2a                	mv	s6,a0
    800015fa:	8aae                	mv	s5,a1
    800015fc:	8a32                	mv	s4,a2
  for(i = 0; i < sz; i += PGSIZE){
    800015fe:	4981                	li	s3,0
    if((pte = walk(old, i, 0)) == 0)
    80001600:	4601                	li	a2,0
    80001602:	85ce                	mv	a1,s3
    80001604:	855a                	mv	a0,s6
    80001606:	00000097          	auipc	ra,0x0
    8000160a:	a28080e7          	jalr	-1496(ra) # 8000102e <walk>
    8000160e:	c531                	beqz	a0,8000165a <uvmcopy+0x7a>
      panic("uvmcopy: pte should exist");
    if((*pte & PTE_V) == 0)
    80001610:	6118                	ld	a4,0(a0)
    80001612:	00177793          	andi	a5,a4,1
    80001616:	cbb1                	beqz	a5,8000166a <uvmcopy+0x8a>
      panic("uvmcopy: page not present");
    pa = PTE2PA(*pte);
    80001618:	00a75593          	srli	a1,a4,0xa
    8000161c:	00c59b93          	slli	s7,a1,0xc
    flags = PTE_FLAGS(*pte);
    80001620:	3ff77493          	andi	s1,a4,1023
    if((mem = kalloc()) == 0)
    80001624:	fffff097          	auipc	ra,0xfffff
    80001628:	534080e7          	jalr	1332(ra) # 80000b58 <kalloc>
    8000162c:	892a                	mv	s2,a0
    8000162e:	c939                	beqz	a0,80001684 <uvmcopy+0xa4>
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    80001630:	6605                	lui	a2,0x1
    80001632:	85de                	mv	a1,s7
    80001634:	fffff097          	auipc	ra,0xfffff
    80001638:	76c080e7          	jalr	1900(ra) # 80000da0 <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    8000163c:	8726                	mv	a4,s1
    8000163e:	86ca                	mv	a3,s2
    80001640:	6605                	lui	a2,0x1
    80001642:	85ce                	mv	a1,s3
    80001644:	8556                	mv	a0,s5
    80001646:	00000097          	auipc	ra,0x0
    8000164a:	ad0080e7          	jalr	-1328(ra) # 80001116 <mappages>
    8000164e:	e515                	bnez	a0,8000167a <uvmcopy+0x9a>
  for(i = 0; i < sz; i += PGSIZE){
    80001650:	6785                	lui	a5,0x1
    80001652:	99be                	add	s3,s3,a5
    80001654:	fb49e6e3          	bltu	s3,s4,80001600 <uvmcopy+0x20>
    80001658:	a081                	j	80001698 <uvmcopy+0xb8>
      panic("uvmcopy: pte should exist");
    8000165a:	00007517          	auipc	a0,0x7
    8000165e:	b2e50513          	addi	a0,a0,-1234 # 80008188 <digits+0x148>
    80001662:	fffff097          	auipc	ra,0xfffff
    80001666:	ede080e7          	jalr	-290(ra) # 80000540 <panic>
      panic("uvmcopy: page not present");
    8000166a:	00007517          	auipc	a0,0x7
    8000166e:	b3e50513          	addi	a0,a0,-1218 # 800081a8 <digits+0x168>
    80001672:	fffff097          	auipc	ra,0xfffff
    80001676:	ece080e7          	jalr	-306(ra) # 80000540 <panic>
      kfree(mem);
    8000167a:	854a                	mv	a0,s2
    8000167c:	fffff097          	auipc	ra,0xfffff
    80001680:	3de080e7          	jalr	990(ra) # 80000a5a <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    80001684:	4685                	li	a3,1
    80001686:	00c9d613          	srli	a2,s3,0xc
    8000168a:	4581                	li	a1,0
    8000168c:	8556                	mv	a0,s5
    8000168e:	00000097          	auipc	ra,0x0
    80001692:	c4e080e7          	jalr	-946(ra) # 800012dc <uvmunmap>
  return -1;
    80001696:	557d                	li	a0,-1
}
    80001698:	60a6                	ld	ra,72(sp)
    8000169a:	6406                	ld	s0,64(sp)
    8000169c:	74e2                	ld	s1,56(sp)
    8000169e:	7942                	ld	s2,48(sp)
    800016a0:	79a2                	ld	s3,40(sp)
    800016a2:	7a02                	ld	s4,32(sp)
    800016a4:	6ae2                	ld	s5,24(sp)
    800016a6:	6b42                	ld	s6,16(sp)
    800016a8:	6ba2                	ld	s7,8(sp)
    800016aa:	6161                	addi	sp,sp,80
    800016ac:	8082                	ret
  return 0;
    800016ae:	4501                	li	a0,0
}
    800016b0:	8082                	ret

00000000800016b2 <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    800016b2:	1141                	addi	sp,sp,-16
    800016b4:	e406                	sd	ra,8(sp)
    800016b6:	e022                	sd	s0,0(sp)
    800016b8:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    800016ba:	4601                	li	a2,0
    800016bc:	00000097          	auipc	ra,0x0
    800016c0:	972080e7          	jalr	-1678(ra) # 8000102e <walk>
  if(pte == 0)
    800016c4:	c901                	beqz	a0,800016d4 <uvmclear+0x22>
    panic("uvmclear");
  *pte &= ~PTE_U;
    800016c6:	611c                	ld	a5,0(a0)
    800016c8:	9bbd                	andi	a5,a5,-17
    800016ca:	e11c                	sd	a5,0(a0)
}
    800016cc:	60a2                	ld	ra,8(sp)
    800016ce:	6402                	ld	s0,0(sp)
    800016d0:	0141                	addi	sp,sp,16
    800016d2:	8082                	ret
    panic("uvmclear");
    800016d4:	00007517          	auipc	a0,0x7
    800016d8:	af450513          	addi	a0,a0,-1292 # 800081c8 <digits+0x188>
    800016dc:	fffff097          	auipc	ra,0xfffff
    800016e0:	e64080e7          	jalr	-412(ra) # 80000540 <panic>

00000000800016e4 <copyout>:
int
copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    800016e4:	c6bd                	beqz	a3,80001752 <copyout+0x6e>
{
    800016e6:	715d                	addi	sp,sp,-80
    800016e8:	e486                	sd	ra,72(sp)
    800016ea:	e0a2                	sd	s0,64(sp)
    800016ec:	fc26                	sd	s1,56(sp)
    800016ee:	f84a                	sd	s2,48(sp)
    800016f0:	f44e                	sd	s3,40(sp)
    800016f2:	f052                	sd	s4,32(sp)
    800016f4:	ec56                	sd	s5,24(sp)
    800016f6:	e85a                	sd	s6,16(sp)
    800016f8:	e45e                	sd	s7,8(sp)
    800016fa:	e062                	sd	s8,0(sp)
    800016fc:	0880                	addi	s0,sp,80
    800016fe:	8b2a                	mv	s6,a0
    80001700:	8c2e                	mv	s8,a1
    80001702:	8a32                	mv	s4,a2
    80001704:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(dstva);
    80001706:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (dstva - va0);
    80001708:	6a85                	lui	s5,0x1
    8000170a:	a015                	j	8000172e <copyout+0x4a>
    if(n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    8000170c:	9562                	add	a0,a0,s8
    8000170e:	0004861b          	sext.w	a2,s1
    80001712:	85d2                	mv	a1,s4
    80001714:	41250533          	sub	a0,a0,s2
    80001718:	fffff097          	auipc	ra,0xfffff
    8000171c:	688080e7          	jalr	1672(ra) # 80000da0 <memmove>

    len -= n;
    80001720:	409989b3          	sub	s3,s3,s1
    src += n;
    80001724:	9a26                	add	s4,s4,s1
    dstva = va0 + PGSIZE;
    80001726:	01590c33          	add	s8,s2,s5
  while(len > 0){
    8000172a:	02098263          	beqz	s3,8000174e <copyout+0x6a>
    va0 = PGROUNDDOWN(dstva);
    8000172e:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    80001732:	85ca                	mv	a1,s2
    80001734:	855a                	mv	a0,s6
    80001736:	00000097          	auipc	ra,0x0
    8000173a:	99e080e7          	jalr	-1634(ra) # 800010d4 <walkaddr>
    if(pa0 == 0)
    8000173e:	cd01                	beqz	a0,80001756 <copyout+0x72>
    n = PGSIZE - (dstva - va0);
    80001740:	418904b3          	sub	s1,s2,s8
    80001744:	94d6                	add	s1,s1,s5
    80001746:	fc99f3e3          	bgeu	s3,s1,8000170c <copyout+0x28>
    8000174a:	84ce                	mv	s1,s3
    8000174c:	b7c1                	j	8000170c <copyout+0x28>
  }
  return 0;
    8000174e:	4501                	li	a0,0
    80001750:	a021                	j	80001758 <copyout+0x74>
    80001752:	4501                	li	a0,0
}
    80001754:	8082                	ret
      return -1;
    80001756:	557d                	li	a0,-1
}
    80001758:	60a6                	ld	ra,72(sp)
    8000175a:	6406                	ld	s0,64(sp)
    8000175c:	74e2                	ld	s1,56(sp)
    8000175e:	7942                	ld	s2,48(sp)
    80001760:	79a2                	ld	s3,40(sp)
    80001762:	7a02                	ld	s4,32(sp)
    80001764:	6ae2                	ld	s5,24(sp)
    80001766:	6b42                	ld	s6,16(sp)
    80001768:	6ba2                	ld	s7,8(sp)
    8000176a:	6c02                	ld	s8,0(sp)
    8000176c:	6161                	addi	sp,sp,80
    8000176e:	8082                	ret

0000000080001770 <copyin>:
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    80001770:	caa5                	beqz	a3,800017e0 <copyin+0x70>
{
    80001772:	715d                	addi	sp,sp,-80
    80001774:	e486                	sd	ra,72(sp)
    80001776:	e0a2                	sd	s0,64(sp)
    80001778:	fc26                	sd	s1,56(sp)
    8000177a:	f84a                	sd	s2,48(sp)
    8000177c:	f44e                	sd	s3,40(sp)
    8000177e:	f052                	sd	s4,32(sp)
    80001780:	ec56                	sd	s5,24(sp)
    80001782:	e85a                	sd	s6,16(sp)
    80001784:	e45e                	sd	s7,8(sp)
    80001786:	e062                	sd	s8,0(sp)
    80001788:	0880                	addi	s0,sp,80
    8000178a:	8b2a                	mv	s6,a0
    8000178c:	8a2e                	mv	s4,a1
    8000178e:	8c32                	mv	s8,a2
    80001790:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    80001792:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80001794:	6a85                	lui	s5,0x1
    80001796:	a01d                	j	800017bc <copyin+0x4c>
    if(n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    80001798:	018505b3          	add	a1,a0,s8
    8000179c:	0004861b          	sext.w	a2,s1
    800017a0:	412585b3          	sub	a1,a1,s2
    800017a4:	8552                	mv	a0,s4
    800017a6:	fffff097          	auipc	ra,0xfffff
    800017aa:	5fa080e7          	jalr	1530(ra) # 80000da0 <memmove>

    len -= n;
    800017ae:	409989b3          	sub	s3,s3,s1
    dst += n;
    800017b2:	9a26                	add	s4,s4,s1
    srcva = va0 + PGSIZE;
    800017b4:	01590c33          	add	s8,s2,s5
  while(len > 0){
    800017b8:	02098263          	beqz	s3,800017dc <copyin+0x6c>
    va0 = PGROUNDDOWN(srcva);
    800017bc:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    800017c0:	85ca                	mv	a1,s2
    800017c2:	855a                	mv	a0,s6
    800017c4:	00000097          	auipc	ra,0x0
    800017c8:	910080e7          	jalr	-1776(ra) # 800010d4 <walkaddr>
    if(pa0 == 0)
    800017cc:	cd01                	beqz	a0,800017e4 <copyin+0x74>
    n = PGSIZE - (srcva - va0);
    800017ce:	418904b3          	sub	s1,s2,s8
    800017d2:	94d6                	add	s1,s1,s5
    800017d4:	fc99f2e3          	bgeu	s3,s1,80001798 <copyin+0x28>
    800017d8:	84ce                	mv	s1,s3
    800017da:	bf7d                	j	80001798 <copyin+0x28>
  }
  return 0;
    800017dc:	4501                	li	a0,0
    800017de:	a021                	j	800017e6 <copyin+0x76>
    800017e0:	4501                	li	a0,0
}
    800017e2:	8082                	ret
      return -1;
    800017e4:	557d                	li	a0,-1
}
    800017e6:	60a6                	ld	ra,72(sp)
    800017e8:	6406                	ld	s0,64(sp)
    800017ea:	74e2                	ld	s1,56(sp)
    800017ec:	7942                	ld	s2,48(sp)
    800017ee:	79a2                	ld	s3,40(sp)
    800017f0:	7a02                	ld	s4,32(sp)
    800017f2:	6ae2                	ld	s5,24(sp)
    800017f4:	6b42                	ld	s6,16(sp)
    800017f6:	6ba2                	ld	s7,8(sp)
    800017f8:	6c02                	ld	s8,0(sp)
    800017fa:	6161                	addi	sp,sp,80
    800017fc:	8082                	ret

00000000800017fe <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    800017fe:	c2dd                	beqz	a3,800018a4 <copyinstr+0xa6>
{
    80001800:	715d                	addi	sp,sp,-80
    80001802:	e486                	sd	ra,72(sp)
    80001804:	e0a2                	sd	s0,64(sp)
    80001806:	fc26                	sd	s1,56(sp)
    80001808:	f84a                	sd	s2,48(sp)
    8000180a:	f44e                	sd	s3,40(sp)
    8000180c:	f052                	sd	s4,32(sp)
    8000180e:	ec56                	sd	s5,24(sp)
    80001810:	e85a                	sd	s6,16(sp)
    80001812:	e45e                	sd	s7,8(sp)
    80001814:	0880                	addi	s0,sp,80
    80001816:	8a2a                	mv	s4,a0
    80001818:	8b2e                	mv	s6,a1
    8000181a:	8bb2                	mv	s7,a2
    8000181c:	84b6                	mv	s1,a3
    va0 = PGROUNDDOWN(srcva);
    8000181e:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80001820:	6985                	lui	s3,0x1
    80001822:	a02d                	j	8000184c <copyinstr+0x4e>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    80001824:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    80001828:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    8000182a:	37fd                	addiw	a5,a5,-1
    8000182c:	0007851b          	sext.w	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    80001830:	60a6                	ld	ra,72(sp)
    80001832:	6406                	ld	s0,64(sp)
    80001834:	74e2                	ld	s1,56(sp)
    80001836:	7942                	ld	s2,48(sp)
    80001838:	79a2                	ld	s3,40(sp)
    8000183a:	7a02                	ld	s4,32(sp)
    8000183c:	6ae2                	ld	s5,24(sp)
    8000183e:	6b42                	ld	s6,16(sp)
    80001840:	6ba2                	ld	s7,8(sp)
    80001842:	6161                	addi	sp,sp,80
    80001844:	8082                	ret
    srcva = va0 + PGSIZE;
    80001846:	01390bb3          	add	s7,s2,s3
  while(got_null == 0 && max > 0){
    8000184a:	c8a9                	beqz	s1,8000189c <copyinstr+0x9e>
    va0 = PGROUNDDOWN(srcva);
    8000184c:	015bf933          	and	s2,s7,s5
    pa0 = walkaddr(pagetable, va0);
    80001850:	85ca                	mv	a1,s2
    80001852:	8552                	mv	a0,s4
    80001854:	00000097          	auipc	ra,0x0
    80001858:	880080e7          	jalr	-1920(ra) # 800010d4 <walkaddr>
    if(pa0 == 0)
    8000185c:	c131                	beqz	a0,800018a0 <copyinstr+0xa2>
    n = PGSIZE - (srcva - va0);
    8000185e:	417906b3          	sub	a3,s2,s7
    80001862:	96ce                	add	a3,a3,s3
    80001864:	00d4f363          	bgeu	s1,a3,8000186a <copyinstr+0x6c>
    80001868:	86a6                	mv	a3,s1
    char *p = (char *) (pa0 + (srcva - va0));
    8000186a:	955e                	add	a0,a0,s7
    8000186c:	41250533          	sub	a0,a0,s2
    while(n > 0){
    80001870:	daf9                	beqz	a3,80001846 <copyinstr+0x48>
    80001872:	87da                	mv	a5,s6
    80001874:	885a                	mv	a6,s6
      if(*p == '\0'){
    80001876:	41650633          	sub	a2,a0,s6
    while(n > 0){
    8000187a:	96da                	add	a3,a3,s6
    8000187c:	85be                	mv	a1,a5
      if(*p == '\0'){
    8000187e:	00f60733          	add	a4,a2,a5
    80001882:	00074703          	lbu	a4,0(a4) # fffffffffffff000 <end+0xffffffff7ffdcbb8>
    80001886:	df59                	beqz	a4,80001824 <copyinstr+0x26>
        *dst = *p;
    80001888:	00e78023          	sb	a4,0(a5)
      dst++;
    8000188c:	0785                	addi	a5,a5,1
    while(n > 0){
    8000188e:	fed797e3          	bne	a5,a3,8000187c <copyinstr+0x7e>
    80001892:	14fd                	addi	s1,s1,-1
    80001894:	94c2                	add	s1,s1,a6
      --max;
    80001896:	8c8d                	sub	s1,s1,a1
      dst++;
    80001898:	8b3e                	mv	s6,a5
    8000189a:	b775                	j	80001846 <copyinstr+0x48>
    8000189c:	4781                	li	a5,0
    8000189e:	b771                	j	8000182a <copyinstr+0x2c>
      return -1;
    800018a0:	557d                	li	a0,-1
    800018a2:	b779                	j	80001830 <copyinstr+0x32>
  int got_null = 0;
    800018a4:	4781                	li	a5,0
  if(got_null){
    800018a6:	37fd                	addiw	a5,a5,-1
    800018a8:	0007851b          	sext.w	a0,a5
}
    800018ac:	8082                	ret

00000000800018ae <proc_mapstacks>:
// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void
proc_mapstacks(pagetable_t kpgtbl)
{
    800018ae:	7139                	addi	sp,sp,-64
    800018b0:	fc06                	sd	ra,56(sp)
    800018b2:	f822                	sd	s0,48(sp)
    800018b4:	f426                	sd	s1,40(sp)
    800018b6:	f04a                	sd	s2,32(sp)
    800018b8:	ec4e                	sd	s3,24(sp)
    800018ba:	e852                	sd	s4,16(sp)
    800018bc:	e456                	sd	s5,8(sp)
    800018be:	e05a                	sd	s6,0(sp)
    800018c0:	0080                	addi	s0,sp,64
    800018c2:	89aa                	mv	s3,a0
  struct proc *p;
  
  for(p = proc; p < &proc[NPROC]; p++) {
    800018c4:	0000f497          	auipc	s1,0xf
    800018c8:	7cc48493          	addi	s1,s1,1996 # 80011090 <proc>
    char *pa = kalloc();
    if(pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int) (p - proc));
    800018cc:	8b26                	mv	s6,s1
    800018ce:	00006a97          	auipc	s5,0x6
    800018d2:	732a8a93          	addi	s5,s5,1842 # 80008000 <etext>
    800018d6:	04000937          	lui	s2,0x4000
    800018da:	197d                	addi	s2,s2,-1 # 3ffffff <_entry-0x7c000001>
    800018dc:	0932                	slli	s2,s2,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    800018de:	00015a17          	auipc	s4,0x15
    800018e2:	3b2a0a13          	addi	s4,s4,946 # 80016c90 <tickslock>
    char *pa = kalloc();
    800018e6:	fffff097          	auipc	ra,0xfffff
    800018ea:	272080e7          	jalr	626(ra) # 80000b58 <kalloc>
    800018ee:	862a                	mv	a2,a0
    if(pa == 0)
    800018f0:	c131                	beqz	a0,80001934 <proc_mapstacks+0x86>
    uint64 va = KSTACK((int) (p - proc));
    800018f2:	416485b3          	sub	a1,s1,s6
    800018f6:	8591                	srai	a1,a1,0x4
    800018f8:	000ab783          	ld	a5,0(s5)
    800018fc:	02f585b3          	mul	a1,a1,a5
    80001900:	2585                	addiw	a1,a1,1
    80001902:	00d5959b          	slliw	a1,a1,0xd
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    80001906:	4719                	li	a4,6
    80001908:	6685                	lui	a3,0x1
    8000190a:	40b905b3          	sub	a1,s2,a1
    8000190e:	854e                	mv	a0,s3
    80001910:	00000097          	auipc	ra,0x0
    80001914:	8a6080e7          	jalr	-1882(ra) # 800011b6 <kvmmap>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001918:	17048493          	addi	s1,s1,368
    8000191c:	fd4495e3          	bne	s1,s4,800018e6 <proc_mapstacks+0x38>
  }
}
    80001920:	70e2                	ld	ra,56(sp)
    80001922:	7442                	ld	s0,48(sp)
    80001924:	74a2                	ld	s1,40(sp)
    80001926:	7902                	ld	s2,32(sp)
    80001928:	69e2                	ld	s3,24(sp)
    8000192a:	6a42                	ld	s4,16(sp)
    8000192c:	6aa2                	ld	s5,8(sp)
    8000192e:	6b02                	ld	s6,0(sp)
    80001930:	6121                	addi	sp,sp,64
    80001932:	8082                	ret
      panic("kalloc");
    80001934:	00007517          	auipc	a0,0x7
    80001938:	8a450513          	addi	a0,a0,-1884 # 800081d8 <digits+0x198>
    8000193c:	fffff097          	auipc	ra,0xfffff
    80001940:	c04080e7          	jalr	-1020(ra) # 80000540 <panic>

0000000080001944 <procinit>:

// initialize the proc table.
void
procinit(void)
{
    80001944:	7139                	addi	sp,sp,-64
    80001946:	fc06                	sd	ra,56(sp)
    80001948:	f822                	sd	s0,48(sp)
    8000194a:	f426                	sd	s1,40(sp)
    8000194c:	f04a                	sd	s2,32(sp)
    8000194e:	ec4e                	sd	s3,24(sp)
    80001950:	e852                	sd	s4,16(sp)
    80001952:	e456                	sd	s5,8(sp)
    80001954:	e05a                	sd	s6,0(sp)
    80001956:	0080                	addi	s0,sp,64
  struct proc *p;
  
  initlock(&pid_lock, "nextpid");
    80001958:	00007597          	auipc	a1,0x7
    8000195c:	88858593          	addi	a1,a1,-1912 # 800081e0 <digits+0x1a0>
    80001960:	0000f517          	auipc	a0,0xf
    80001964:	30050513          	addi	a0,a0,768 # 80010c60 <pid_lock>
    80001968:	fffff097          	auipc	ra,0xfffff
    8000196c:	250080e7          	jalr	592(ra) # 80000bb8 <initlock>
  initlock(&wait_lock, "wait_lock");
    80001970:	00007597          	auipc	a1,0x7
    80001974:	87858593          	addi	a1,a1,-1928 # 800081e8 <digits+0x1a8>
    80001978:	0000f517          	auipc	a0,0xf
    8000197c:	30050513          	addi	a0,a0,768 # 80010c78 <wait_lock>
    80001980:	fffff097          	auipc	ra,0xfffff
    80001984:	238080e7          	jalr	568(ra) # 80000bb8 <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001988:	0000f497          	auipc	s1,0xf
    8000198c:	70848493          	addi	s1,s1,1800 # 80011090 <proc>
      initlock(&p->lock, "proc");
    80001990:	00007b17          	auipc	s6,0x7
    80001994:	868b0b13          	addi	s6,s6,-1944 # 800081f8 <digits+0x1b8>
      p->state = UNUSED;
      p->kstack = KSTACK((int) (p - proc));
    80001998:	8aa6                	mv	s5,s1
    8000199a:	00006a17          	auipc	s4,0x6
    8000199e:	666a0a13          	addi	s4,s4,1638 # 80008000 <etext>
    800019a2:	04000937          	lui	s2,0x4000
    800019a6:	197d                	addi	s2,s2,-1 # 3ffffff <_entry-0x7c000001>
    800019a8:	0932                	slli	s2,s2,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    800019aa:	00015997          	auipc	s3,0x15
    800019ae:	2e698993          	addi	s3,s3,742 # 80016c90 <tickslock>
      initlock(&p->lock, "proc");
    800019b2:	85da                	mv	a1,s6
    800019b4:	8526                	mv	a0,s1
    800019b6:	fffff097          	auipc	ra,0xfffff
    800019ba:	202080e7          	jalr	514(ra) # 80000bb8 <initlock>
      p->state = UNUSED;
    800019be:	0004ac23          	sw	zero,24(s1)
      p->kstack = KSTACK((int) (p - proc));
    800019c2:	415487b3          	sub	a5,s1,s5
    800019c6:	8791                	srai	a5,a5,0x4
    800019c8:	000a3703          	ld	a4,0(s4)
    800019cc:	02e787b3          	mul	a5,a5,a4
    800019d0:	2785                	addiw	a5,a5,1
    800019d2:	00d7979b          	slliw	a5,a5,0xd
    800019d6:	40f907b3          	sub	a5,s2,a5
    800019da:	e0bc                	sd	a5,64(s1)
  for(p = proc; p < &proc[NPROC]; p++) {
    800019dc:	17048493          	addi	s1,s1,368
    800019e0:	fd3499e3          	bne	s1,s3,800019b2 <procinit+0x6e>
  }
}
    800019e4:	70e2                	ld	ra,56(sp)
    800019e6:	7442                	ld	s0,48(sp)
    800019e8:	74a2                	ld	s1,40(sp)
    800019ea:	7902                	ld	s2,32(sp)
    800019ec:	69e2                	ld	s3,24(sp)
    800019ee:	6a42                	ld	s4,16(sp)
    800019f0:	6aa2                	ld	s5,8(sp)
    800019f2:	6b02                	ld	s6,0(sp)
    800019f4:	6121                	addi	sp,sp,64
    800019f6:	8082                	ret

00000000800019f8 <cpuid>:
// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int
cpuid()
{
    800019f8:	1141                	addi	sp,sp,-16
    800019fa:	e422                	sd	s0,8(sp)
    800019fc:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    800019fe:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    80001a00:	2501                	sext.w	a0,a0
    80001a02:	6422                	ld	s0,8(sp)
    80001a04:	0141                	addi	sp,sp,16
    80001a06:	8082                	ret

0000000080001a08 <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu*
mycpu(void)
{
    80001a08:	1141                	addi	sp,sp,-16
    80001a0a:	e422                	sd	s0,8(sp)
    80001a0c:	0800                	addi	s0,sp,16
    80001a0e:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    80001a10:	2781                	sext.w	a5,a5
    80001a12:	079e                	slli	a5,a5,0x7
  return c;
}
    80001a14:	0000f517          	auipc	a0,0xf
    80001a18:	27c50513          	addi	a0,a0,636 # 80010c90 <cpus>
    80001a1c:	953e                	add	a0,a0,a5
    80001a1e:	6422                	ld	s0,8(sp)
    80001a20:	0141                	addi	sp,sp,16
    80001a22:	8082                	ret

0000000080001a24 <myproc>:

// Return the current struct proc *, or zero if none.
struct proc*
myproc(void)
{
    80001a24:	1101                	addi	sp,sp,-32
    80001a26:	ec06                	sd	ra,24(sp)
    80001a28:	e822                	sd	s0,16(sp)
    80001a2a:	e426                	sd	s1,8(sp)
    80001a2c:	1000                	addi	s0,sp,32
  push_off();
    80001a2e:	fffff097          	auipc	ra,0xfffff
    80001a32:	1ce080e7          	jalr	462(ra) # 80000bfc <push_off>
    80001a36:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    80001a38:	2781                	sext.w	a5,a5
    80001a3a:	079e                	slli	a5,a5,0x7
    80001a3c:	0000f717          	auipc	a4,0xf
    80001a40:	22470713          	addi	a4,a4,548 # 80010c60 <pid_lock>
    80001a44:	97ba                	add	a5,a5,a4
    80001a46:	7b84                	ld	s1,48(a5)
  pop_off();
    80001a48:	fffff097          	auipc	ra,0xfffff
    80001a4c:	254080e7          	jalr	596(ra) # 80000c9c <pop_off>
  return p;
}
    80001a50:	8526                	mv	a0,s1
    80001a52:	60e2                	ld	ra,24(sp)
    80001a54:	6442                	ld	s0,16(sp)
    80001a56:	64a2                	ld	s1,8(sp)
    80001a58:	6105                	addi	sp,sp,32
    80001a5a:	8082                	ret

0000000080001a5c <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
    80001a5c:	1141                	addi	sp,sp,-16
    80001a5e:	e406                	sd	ra,8(sp)
    80001a60:	e022                	sd	s0,0(sp)
    80001a62:	0800                	addi	s0,sp,16
  static int first = 1;

  // Still holding p->lock from scheduler.
  release(&myproc()->lock);
    80001a64:	00000097          	auipc	ra,0x0
    80001a68:	fc0080e7          	jalr	-64(ra) # 80001a24 <myproc>
    80001a6c:	fffff097          	auipc	ra,0xfffff
    80001a70:	290080e7          	jalr	656(ra) # 80000cfc <release>

  if (first) {
    80001a74:	00007797          	auipc	a5,0x7
    80001a78:	efc7a783          	lw	a5,-260(a5) # 80008970 <first.1>
    80001a7c:	eb89                	bnez	a5,80001a8e <forkret+0x32>
    // be run from main().
    first = 0;
    fsinit(ROOTDEV);
  }

  usertrapret();
    80001a7e:	00001097          	auipc	ra,0x1
    80001a82:	c8a080e7          	jalr	-886(ra) # 80002708 <usertrapret>
}
    80001a86:	60a2                	ld	ra,8(sp)
    80001a88:	6402                	ld	s0,0(sp)
    80001a8a:	0141                	addi	sp,sp,16
    80001a8c:	8082                	ret
    first = 0;
    80001a8e:	00007797          	auipc	a5,0x7
    80001a92:	ee07a123          	sw	zero,-286(a5) # 80008970 <first.1>
    fsinit(ROOTDEV);
    80001a96:	4505                	li	a0,1
    80001a98:	00002097          	auipc	ra,0x2
    80001a9c:	a72080e7          	jalr	-1422(ra) # 8000350a <fsinit>
    80001aa0:	bff9                	j	80001a7e <forkret+0x22>

0000000080001aa2 <allocpid>:
{
    80001aa2:	1101                	addi	sp,sp,-32
    80001aa4:	ec06                	sd	ra,24(sp)
    80001aa6:	e822                	sd	s0,16(sp)
    80001aa8:	e426                	sd	s1,8(sp)
    80001aaa:	e04a                	sd	s2,0(sp)
    80001aac:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001aae:	0000f917          	auipc	s2,0xf
    80001ab2:	1b290913          	addi	s2,s2,434 # 80010c60 <pid_lock>
    80001ab6:	854a                	mv	a0,s2
    80001ab8:	fffff097          	auipc	ra,0xfffff
    80001abc:	190080e7          	jalr	400(ra) # 80000c48 <acquire>
  pid = nextpid;
    80001ac0:	00007797          	auipc	a5,0x7
    80001ac4:	eb478793          	addi	a5,a5,-332 # 80008974 <nextpid>
    80001ac8:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001aca:	0014871b          	addiw	a4,s1,1
    80001ace:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001ad0:	854a                	mv	a0,s2
    80001ad2:	fffff097          	auipc	ra,0xfffff
    80001ad6:	22a080e7          	jalr	554(ra) # 80000cfc <release>
}
    80001ada:	8526                	mv	a0,s1
    80001adc:	60e2                	ld	ra,24(sp)
    80001ade:	6442                	ld	s0,16(sp)
    80001ae0:	64a2                	ld	s1,8(sp)
    80001ae2:	6902                	ld	s2,0(sp)
    80001ae4:	6105                	addi	sp,sp,32
    80001ae6:	8082                	ret

0000000080001ae8 <proc_pagetable>:
{
    80001ae8:	1101                	addi	sp,sp,-32
    80001aea:	ec06                	sd	ra,24(sp)
    80001aec:	e822                	sd	s0,16(sp)
    80001aee:	e426                	sd	s1,8(sp)
    80001af0:	e04a                	sd	s2,0(sp)
    80001af2:	1000                	addi	s0,sp,32
    80001af4:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001af6:	00000097          	auipc	ra,0x0
    80001afa:	8aa080e7          	jalr	-1878(ra) # 800013a0 <uvmcreate>
    80001afe:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001b00:	c121                	beqz	a0,80001b40 <proc_pagetable+0x58>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001b02:	4729                	li	a4,10
    80001b04:	00005697          	auipc	a3,0x5
    80001b08:	4fc68693          	addi	a3,a3,1276 # 80007000 <_trampoline>
    80001b0c:	6605                	lui	a2,0x1
    80001b0e:	040005b7          	lui	a1,0x4000
    80001b12:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001b14:	05b2                	slli	a1,a1,0xc
    80001b16:	fffff097          	auipc	ra,0xfffff
    80001b1a:	600080e7          	jalr	1536(ra) # 80001116 <mappages>
    80001b1e:	02054863          	bltz	a0,80001b4e <proc_pagetable+0x66>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    80001b22:	4719                	li	a4,6
    80001b24:	05893683          	ld	a3,88(s2)
    80001b28:	6605                	lui	a2,0x1
    80001b2a:	020005b7          	lui	a1,0x2000
    80001b2e:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001b30:	05b6                	slli	a1,a1,0xd
    80001b32:	8526                	mv	a0,s1
    80001b34:	fffff097          	auipc	ra,0xfffff
    80001b38:	5e2080e7          	jalr	1506(ra) # 80001116 <mappages>
    80001b3c:	02054163          	bltz	a0,80001b5e <proc_pagetable+0x76>
}
    80001b40:	8526                	mv	a0,s1
    80001b42:	60e2                	ld	ra,24(sp)
    80001b44:	6442                	ld	s0,16(sp)
    80001b46:	64a2                	ld	s1,8(sp)
    80001b48:	6902                	ld	s2,0(sp)
    80001b4a:	6105                	addi	sp,sp,32
    80001b4c:	8082                	ret
    uvmfree(pagetable, 0);
    80001b4e:	4581                	li	a1,0
    80001b50:	8526                	mv	a0,s1
    80001b52:	00000097          	auipc	ra,0x0
    80001b56:	a54080e7          	jalr	-1452(ra) # 800015a6 <uvmfree>
    return 0;
    80001b5a:	4481                	li	s1,0
    80001b5c:	b7d5                	j	80001b40 <proc_pagetable+0x58>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001b5e:	4681                	li	a3,0
    80001b60:	4605                	li	a2,1
    80001b62:	040005b7          	lui	a1,0x4000
    80001b66:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001b68:	05b2                	slli	a1,a1,0xc
    80001b6a:	8526                	mv	a0,s1
    80001b6c:	fffff097          	auipc	ra,0xfffff
    80001b70:	770080e7          	jalr	1904(ra) # 800012dc <uvmunmap>
    uvmfree(pagetable, 0);
    80001b74:	4581                	li	a1,0
    80001b76:	8526                	mv	a0,s1
    80001b78:	00000097          	auipc	ra,0x0
    80001b7c:	a2e080e7          	jalr	-1490(ra) # 800015a6 <uvmfree>
    return 0;
    80001b80:	4481                	li	s1,0
    80001b82:	bf7d                	j	80001b40 <proc_pagetable+0x58>

0000000080001b84 <proc_freepagetable>:
{
    80001b84:	1101                	addi	sp,sp,-32
    80001b86:	ec06                	sd	ra,24(sp)
    80001b88:	e822                	sd	s0,16(sp)
    80001b8a:	e426                	sd	s1,8(sp)
    80001b8c:	e04a                	sd	s2,0(sp)
    80001b8e:	1000                	addi	s0,sp,32
    80001b90:	84aa                	mv	s1,a0
    80001b92:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001b94:	4681                	li	a3,0
    80001b96:	4605                	li	a2,1
    80001b98:	040005b7          	lui	a1,0x4000
    80001b9c:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001b9e:	05b2                	slli	a1,a1,0xc
    80001ba0:	fffff097          	auipc	ra,0xfffff
    80001ba4:	73c080e7          	jalr	1852(ra) # 800012dc <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001ba8:	4681                	li	a3,0
    80001baa:	4605                	li	a2,1
    80001bac:	020005b7          	lui	a1,0x2000
    80001bb0:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001bb2:	05b6                	slli	a1,a1,0xd
    80001bb4:	8526                	mv	a0,s1
    80001bb6:	fffff097          	auipc	ra,0xfffff
    80001bba:	726080e7          	jalr	1830(ra) # 800012dc <uvmunmap>
  uvmfree(pagetable, sz);
    80001bbe:	85ca                	mv	a1,s2
    80001bc0:	8526                	mv	a0,s1
    80001bc2:	00000097          	auipc	ra,0x0
    80001bc6:	9e4080e7          	jalr	-1564(ra) # 800015a6 <uvmfree>
}
    80001bca:	60e2                	ld	ra,24(sp)
    80001bcc:	6442                	ld	s0,16(sp)
    80001bce:	64a2                	ld	s1,8(sp)
    80001bd0:	6902                	ld	s2,0(sp)
    80001bd2:	6105                	addi	sp,sp,32
    80001bd4:	8082                	ret

0000000080001bd6 <freeproc>:
{
    80001bd6:	1101                	addi	sp,sp,-32
    80001bd8:	ec06                	sd	ra,24(sp)
    80001bda:	e822                	sd	s0,16(sp)
    80001bdc:	e426                	sd	s1,8(sp)
    80001bde:	1000                	addi	s0,sp,32
    80001be0:	84aa                	mv	s1,a0
  if (strncmp(p->name, "vm-", 3) == 0) {
    80001be2:	460d                	li	a2,3
    80001be4:	00006597          	auipc	a1,0x6
    80001be8:	61c58593          	addi	a1,a1,1564 # 80008200 <digits+0x1c0>
    80001bec:	15850513          	addi	a0,a0,344
    80001bf0:	fffff097          	auipc	ra,0xfffff
    80001bf4:	224080e7          	jalr	548(ra) # 80000e14 <strncmp>
    80001bf8:	c539                	beqz	a0,80001c46 <freeproc+0x70>
  if(p->trapframe)
    80001bfa:	6ca8                	ld	a0,88(s1)
    80001bfc:	c509                	beqz	a0,80001c06 <freeproc+0x30>
    kfree((void*)p->trapframe);
    80001bfe:	fffff097          	auipc	ra,0xfffff
    80001c02:	e5c080e7          	jalr	-420(ra) # 80000a5a <kfree>
  p->trapframe = 0;
    80001c06:	0404bc23          	sd	zero,88(s1)
  if(p->pagetable)
    80001c0a:	68a8                	ld	a0,80(s1)
    80001c0c:	c511                	beqz	a0,80001c18 <freeproc+0x42>
    proc_freepagetable(p->pagetable, p->sz);
    80001c0e:	64ac                	ld	a1,72(s1)
    80001c10:	00000097          	auipc	ra,0x0
    80001c14:	f74080e7          	jalr	-140(ra) # 80001b84 <proc_freepagetable>
  p->pagetable = 0;
    80001c18:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80001c1c:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80001c20:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    80001c24:	0204bc23          	sd	zero,56(s1)
  p->name[0] = 0;
    80001c28:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80001c2c:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80001c30:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80001c34:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    80001c38:	0004ac23          	sw	zero,24(s1)
}
    80001c3c:	60e2                	ld	ra,24(sp)
    80001c3e:	6442                	ld	s0,16(sp)
    80001c40:	64a2                	ld	s1,8(sp)
    80001c42:	6105                	addi	sp,sp,32
    80001c44:	8082                	ret
    uvmunmap(p->pagetable, memaddr_start, memaddr_count, 0);
    80001c46:	4681                	li	a3,0
    80001c48:	40000613          	li	a2,1024
    80001c4c:	4585                	li	a1,1
    80001c4e:	05fe                	slli	a1,a1,0x1f
    80001c50:	68a8                	ld	a0,80(s1)
    80001c52:	fffff097          	auipc	ra,0xfffff
    80001c56:	68a080e7          	jalr	1674(ra) # 800012dc <uvmunmap>
    80001c5a:	b745                	j	80001bfa <freeproc+0x24>

0000000080001c5c <allocproc>:
{
    80001c5c:	1101                	addi	sp,sp,-32
    80001c5e:	ec06                	sd	ra,24(sp)
    80001c60:	e822                	sd	s0,16(sp)
    80001c62:	e426                	sd	s1,8(sp)
    80001c64:	e04a                	sd	s2,0(sp)
    80001c66:	1000                	addi	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    80001c68:	0000f497          	auipc	s1,0xf
    80001c6c:	42848493          	addi	s1,s1,1064 # 80011090 <proc>
    80001c70:	00015917          	auipc	s2,0x15
    80001c74:	02090913          	addi	s2,s2,32 # 80016c90 <tickslock>
    acquire(&p->lock);
    80001c78:	8526                	mv	a0,s1
    80001c7a:	fffff097          	auipc	ra,0xfffff
    80001c7e:	fce080e7          	jalr	-50(ra) # 80000c48 <acquire>
    if(p->state == UNUSED) {
    80001c82:	4c9c                	lw	a5,24(s1)
    80001c84:	cf81                	beqz	a5,80001c9c <allocproc+0x40>
      release(&p->lock);
    80001c86:	8526                	mv	a0,s1
    80001c88:	fffff097          	auipc	ra,0xfffff
    80001c8c:	074080e7          	jalr	116(ra) # 80000cfc <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001c90:	17048493          	addi	s1,s1,368
    80001c94:	ff2492e3          	bne	s1,s2,80001c78 <allocproc+0x1c>
  return 0;
    80001c98:	4481                	li	s1,0
    80001c9a:	a889                	j	80001cec <allocproc+0x90>
  p->pid = allocpid();
    80001c9c:	00000097          	auipc	ra,0x0
    80001ca0:	e06080e7          	jalr	-506(ra) # 80001aa2 <allocpid>
    80001ca4:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001ca6:	4785                	li	a5,1
    80001ca8:	cc9c                	sw	a5,24(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    80001caa:	fffff097          	auipc	ra,0xfffff
    80001cae:	eae080e7          	jalr	-338(ra) # 80000b58 <kalloc>
    80001cb2:	892a                	mv	s2,a0
    80001cb4:	eca8                	sd	a0,88(s1)
    80001cb6:	c131                	beqz	a0,80001cfa <allocproc+0x9e>
  p->pagetable = proc_pagetable(p);
    80001cb8:	8526                	mv	a0,s1
    80001cba:	00000097          	auipc	ra,0x0
    80001cbe:	e2e080e7          	jalr	-466(ra) # 80001ae8 <proc_pagetable>
    80001cc2:	892a                	mv	s2,a0
    80001cc4:	e8a8                	sd	a0,80(s1)
  if(p->pagetable == 0){
    80001cc6:	c531                	beqz	a0,80001d12 <allocproc+0xb6>
  memset(&p->context, 0, sizeof(p->context));
    80001cc8:	07000613          	li	a2,112
    80001ccc:	4581                	li	a1,0
    80001cce:	06048513          	addi	a0,s1,96
    80001cd2:	fffff097          	auipc	ra,0xfffff
    80001cd6:	072080e7          	jalr	114(ra) # 80000d44 <memset>
  p->context.ra = (uint64)forkret;
    80001cda:	00000797          	auipc	a5,0x0
    80001cde:	d8278793          	addi	a5,a5,-638 # 80001a5c <forkret>
    80001ce2:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001ce4:	60bc                	ld	a5,64(s1)
    80001ce6:	6705                	lui	a4,0x1
    80001ce8:	97ba                	add	a5,a5,a4
    80001cea:	f4bc                	sd	a5,104(s1)
}
    80001cec:	8526                	mv	a0,s1
    80001cee:	60e2                	ld	ra,24(sp)
    80001cf0:	6442                	ld	s0,16(sp)
    80001cf2:	64a2                	ld	s1,8(sp)
    80001cf4:	6902                	ld	s2,0(sp)
    80001cf6:	6105                	addi	sp,sp,32
    80001cf8:	8082                	ret
    freeproc(p);
    80001cfa:	8526                	mv	a0,s1
    80001cfc:	00000097          	auipc	ra,0x0
    80001d00:	eda080e7          	jalr	-294(ra) # 80001bd6 <freeproc>
    release(&p->lock);
    80001d04:	8526                	mv	a0,s1
    80001d06:	fffff097          	auipc	ra,0xfffff
    80001d0a:	ff6080e7          	jalr	-10(ra) # 80000cfc <release>
    return 0;
    80001d0e:	84ca                	mv	s1,s2
    80001d10:	bff1                	j	80001cec <allocproc+0x90>
    freeproc(p);
    80001d12:	8526                	mv	a0,s1
    80001d14:	00000097          	auipc	ra,0x0
    80001d18:	ec2080e7          	jalr	-318(ra) # 80001bd6 <freeproc>
    release(&p->lock);
    80001d1c:	8526                	mv	a0,s1
    80001d1e:	fffff097          	auipc	ra,0xfffff
    80001d22:	fde080e7          	jalr	-34(ra) # 80000cfc <release>
    return 0;
    80001d26:	84ca                	mv	s1,s2
    80001d28:	b7d1                	j	80001cec <allocproc+0x90>

0000000080001d2a <userinit>:
{
    80001d2a:	1101                	addi	sp,sp,-32
    80001d2c:	ec06                	sd	ra,24(sp)
    80001d2e:	e822                	sd	s0,16(sp)
    80001d30:	e426                	sd	s1,8(sp)
    80001d32:	1000                	addi	s0,sp,32
  p = allocproc();
    80001d34:	00000097          	auipc	ra,0x0
    80001d38:	f28080e7          	jalr	-216(ra) # 80001c5c <allocproc>
    80001d3c:	84aa                	mv	s1,a0
  initproc = p;
    80001d3e:	00007797          	auipc	a5,0x7
    80001d42:	caa7b523          	sd	a0,-854(a5) # 800089e8 <initproc>
  uvmfirst(p->pagetable, initcode, sizeof(initcode));
    80001d46:	03400613          	li	a2,52
    80001d4a:	00007597          	auipc	a1,0x7
    80001d4e:	c3658593          	addi	a1,a1,-970 # 80008980 <initcode>
    80001d52:	6928                	ld	a0,80(a0)
    80001d54:	fffff097          	auipc	ra,0xfffff
    80001d58:	67a080e7          	jalr	1658(ra) # 800013ce <uvmfirst>
  p->sz = PGSIZE;
    80001d5c:	6785                	lui	a5,0x1
    80001d5e:	e4bc                	sd	a5,72(s1)
  p->trapframe->epc = 0;      // user program counter
    80001d60:	6cb8                	ld	a4,88(s1)
    80001d62:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->trapframe->sp = PGSIZE;  // user stack pointer
    80001d66:	6cb8                	ld	a4,88(s1)
    80001d68:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80001d6a:	4641                	li	a2,16
    80001d6c:	00006597          	auipc	a1,0x6
    80001d70:	49c58593          	addi	a1,a1,1180 # 80008208 <digits+0x1c8>
    80001d74:	15848513          	addi	a0,s1,344
    80001d78:	fffff097          	auipc	ra,0xfffff
    80001d7c:	114080e7          	jalr	276(ra) # 80000e8c <safestrcpy>
  p->cwd = namei("/");
    80001d80:	00006517          	auipc	a0,0x6
    80001d84:	49850513          	addi	a0,a0,1176 # 80008218 <digits+0x1d8>
    80001d88:	00002097          	auipc	ra,0x2
    80001d8c:	1a0080e7          	jalr	416(ra) # 80003f28 <namei>
    80001d90:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001d94:	478d                	li	a5,3
    80001d96:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001d98:	8526                	mv	a0,s1
    80001d9a:	fffff097          	auipc	ra,0xfffff
    80001d9e:	f62080e7          	jalr	-158(ra) # 80000cfc <release>
}
    80001da2:	60e2                	ld	ra,24(sp)
    80001da4:	6442                	ld	s0,16(sp)
    80001da6:	64a2                	ld	s1,8(sp)
    80001da8:	6105                	addi	sp,sp,32
    80001daa:	8082                	ret

0000000080001dac <growproc>:
{
    80001dac:	1101                	addi	sp,sp,-32
    80001dae:	ec06                	sd	ra,24(sp)
    80001db0:	e822                	sd	s0,16(sp)
    80001db2:	e426                	sd	s1,8(sp)
    80001db4:	e04a                	sd	s2,0(sp)
    80001db6:	1000                	addi	s0,sp,32
    80001db8:	892a                	mv	s2,a0
  struct proc *p = myproc();
    80001dba:	00000097          	auipc	ra,0x0
    80001dbe:	c6a080e7          	jalr	-918(ra) # 80001a24 <myproc>
    80001dc2:	84aa                	mv	s1,a0
  sz = p->sz;
    80001dc4:	652c                	ld	a1,72(a0)
  if(n > 0){
    80001dc6:	01204c63          	bgtz	s2,80001dde <growproc+0x32>
  } else if(n < 0){
    80001dca:	02094663          	bltz	s2,80001df6 <growproc+0x4a>
  p->sz = sz;
    80001dce:	e4ac                	sd	a1,72(s1)
  return 0;
    80001dd0:	4501                	li	a0,0
}
    80001dd2:	60e2                	ld	ra,24(sp)
    80001dd4:	6442                	ld	s0,16(sp)
    80001dd6:	64a2                	ld	s1,8(sp)
    80001dd8:	6902                	ld	s2,0(sp)
    80001dda:	6105                	addi	sp,sp,32
    80001ddc:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0) {
    80001dde:	4691                	li	a3,4
    80001de0:	00b90633          	add	a2,s2,a1
    80001de4:	6928                	ld	a0,80(a0)
    80001de6:	fffff097          	auipc	ra,0xfffff
    80001dea:	6a2080e7          	jalr	1698(ra) # 80001488 <uvmalloc>
    80001dee:	85aa                	mv	a1,a0
    80001df0:	fd79                	bnez	a0,80001dce <growproc+0x22>
      return -1;
    80001df2:	557d                	li	a0,-1
    80001df4:	bff9                	j	80001dd2 <growproc+0x26>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001df6:	00b90633          	add	a2,s2,a1
    80001dfa:	6928                	ld	a0,80(a0)
    80001dfc:	fffff097          	auipc	ra,0xfffff
    80001e00:	644080e7          	jalr	1604(ra) # 80001440 <uvmdealloc>
    80001e04:	85aa                	mv	a1,a0
    80001e06:	b7e1                	j	80001dce <growproc+0x22>

0000000080001e08 <fork>:
{
    80001e08:	7139                	addi	sp,sp,-64
    80001e0a:	fc06                	sd	ra,56(sp)
    80001e0c:	f822                	sd	s0,48(sp)
    80001e0e:	f426                	sd	s1,40(sp)
    80001e10:	f04a                	sd	s2,32(sp)
    80001e12:	ec4e                	sd	s3,24(sp)
    80001e14:	e852                	sd	s4,16(sp)
    80001e16:	e456                	sd	s5,8(sp)
    80001e18:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80001e1a:	00000097          	auipc	ra,0x0
    80001e1e:	c0a080e7          	jalr	-1014(ra) # 80001a24 <myproc>
    80001e22:	8aaa                	mv	s5,a0
  if((np = allocproc()) == 0){
    80001e24:	00000097          	auipc	ra,0x0
    80001e28:	e38080e7          	jalr	-456(ra) # 80001c5c <allocproc>
    80001e2c:	10050c63          	beqz	a0,80001f44 <fork+0x13c>
    80001e30:	8a2a                	mv	s4,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80001e32:	048ab603          	ld	a2,72(s5)
    80001e36:	692c                	ld	a1,80(a0)
    80001e38:	050ab503          	ld	a0,80(s5)
    80001e3c:	fffff097          	auipc	ra,0xfffff
    80001e40:	7a4080e7          	jalr	1956(ra) # 800015e0 <uvmcopy>
    80001e44:	04054863          	bltz	a0,80001e94 <fork+0x8c>
  np->sz = p->sz;
    80001e48:	048ab783          	ld	a5,72(s5)
    80001e4c:	04fa3423          	sd	a5,72(s4)
  *(np->trapframe) = *(p->trapframe);
    80001e50:	058ab683          	ld	a3,88(s5)
    80001e54:	87b6                	mv	a5,a3
    80001e56:	058a3703          	ld	a4,88(s4)
    80001e5a:	12068693          	addi	a3,a3,288
    80001e5e:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    80001e62:	6788                	ld	a0,8(a5)
    80001e64:	6b8c                	ld	a1,16(a5)
    80001e66:	6f90                	ld	a2,24(a5)
    80001e68:	01073023          	sd	a6,0(a4)
    80001e6c:	e708                	sd	a0,8(a4)
    80001e6e:	eb0c                	sd	a1,16(a4)
    80001e70:	ef10                	sd	a2,24(a4)
    80001e72:	02078793          	addi	a5,a5,32
    80001e76:	02070713          	addi	a4,a4,32
    80001e7a:	fed792e3          	bne	a5,a3,80001e5e <fork+0x56>
  np->trapframe->a0 = 0;
    80001e7e:	058a3783          	ld	a5,88(s4)
    80001e82:	0607b823          	sd	zero,112(a5)
  for(i = 0; i < NOFILE; i++)
    80001e86:	0d0a8493          	addi	s1,s5,208
    80001e8a:	0d0a0913          	addi	s2,s4,208
    80001e8e:	150a8993          	addi	s3,s5,336
    80001e92:	a00d                	j	80001eb4 <fork+0xac>
    freeproc(np);
    80001e94:	8552                	mv	a0,s4
    80001e96:	00000097          	auipc	ra,0x0
    80001e9a:	d40080e7          	jalr	-704(ra) # 80001bd6 <freeproc>
    release(&np->lock);
    80001e9e:	8552                	mv	a0,s4
    80001ea0:	fffff097          	auipc	ra,0xfffff
    80001ea4:	e5c080e7          	jalr	-420(ra) # 80000cfc <release>
    return -1;
    80001ea8:	597d                	li	s2,-1
    80001eaa:	a059                	j	80001f30 <fork+0x128>
  for(i = 0; i < NOFILE; i++)
    80001eac:	04a1                	addi	s1,s1,8
    80001eae:	0921                	addi	s2,s2,8
    80001eb0:	01348b63          	beq	s1,s3,80001ec6 <fork+0xbe>
    if(p->ofile[i])
    80001eb4:	6088                	ld	a0,0(s1)
    80001eb6:	d97d                	beqz	a0,80001eac <fork+0xa4>
      np->ofile[i] = filedup(p->ofile[i]);
    80001eb8:	00002097          	auipc	ra,0x2
    80001ebc:	6e2080e7          	jalr	1762(ra) # 8000459a <filedup>
    80001ec0:	00a93023          	sd	a0,0(s2)
    80001ec4:	b7e5                	j	80001eac <fork+0xa4>
  np->cwd = idup(p->cwd);
    80001ec6:	150ab503          	ld	a0,336(s5)
    80001eca:	00002097          	auipc	ra,0x2
    80001ece:	87a080e7          	jalr	-1926(ra) # 80003744 <idup>
    80001ed2:	14aa3823          	sd	a0,336(s4)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001ed6:	4641                	li	a2,16
    80001ed8:	158a8593          	addi	a1,s5,344
    80001edc:	158a0513          	addi	a0,s4,344
    80001ee0:	fffff097          	auipc	ra,0xfffff
    80001ee4:	fac080e7          	jalr	-84(ra) # 80000e8c <safestrcpy>
  pid = np->pid;
    80001ee8:	030a2903          	lw	s2,48(s4)
  release(&np->lock);
    80001eec:	8552                	mv	a0,s4
    80001eee:	fffff097          	auipc	ra,0xfffff
    80001ef2:	e0e080e7          	jalr	-498(ra) # 80000cfc <release>
  acquire(&wait_lock);
    80001ef6:	0000f497          	auipc	s1,0xf
    80001efa:	d8248493          	addi	s1,s1,-638 # 80010c78 <wait_lock>
    80001efe:	8526                	mv	a0,s1
    80001f00:	fffff097          	auipc	ra,0xfffff
    80001f04:	d48080e7          	jalr	-696(ra) # 80000c48 <acquire>
  np->parent = p;
    80001f08:	035a3c23          	sd	s5,56(s4)
  release(&wait_lock);
    80001f0c:	8526                	mv	a0,s1
    80001f0e:	fffff097          	auipc	ra,0xfffff
    80001f12:	dee080e7          	jalr	-530(ra) # 80000cfc <release>
  acquire(&np->lock);
    80001f16:	8552                	mv	a0,s4
    80001f18:	fffff097          	auipc	ra,0xfffff
    80001f1c:	d30080e7          	jalr	-720(ra) # 80000c48 <acquire>
  np->state = RUNNABLE;
    80001f20:	478d                	li	a5,3
    80001f22:	00fa2c23          	sw	a5,24(s4)
  release(&np->lock);
    80001f26:	8552                	mv	a0,s4
    80001f28:	fffff097          	auipc	ra,0xfffff
    80001f2c:	dd4080e7          	jalr	-556(ra) # 80000cfc <release>
}
    80001f30:	854a                	mv	a0,s2
    80001f32:	70e2                	ld	ra,56(sp)
    80001f34:	7442                	ld	s0,48(sp)
    80001f36:	74a2                	ld	s1,40(sp)
    80001f38:	7902                	ld	s2,32(sp)
    80001f3a:	69e2                	ld	s3,24(sp)
    80001f3c:	6a42                	ld	s4,16(sp)
    80001f3e:	6aa2                	ld	s5,8(sp)
    80001f40:	6121                	addi	sp,sp,64
    80001f42:	8082                	ret
    return -1;
    80001f44:	597d                	li	s2,-1
    80001f46:	b7ed                	j	80001f30 <fork+0x128>

0000000080001f48 <scheduler>:
{
    80001f48:	7139                	addi	sp,sp,-64
    80001f4a:	fc06                	sd	ra,56(sp)
    80001f4c:	f822                	sd	s0,48(sp)
    80001f4e:	f426                	sd	s1,40(sp)
    80001f50:	f04a                	sd	s2,32(sp)
    80001f52:	ec4e                	sd	s3,24(sp)
    80001f54:	e852                	sd	s4,16(sp)
    80001f56:	e456                	sd	s5,8(sp)
    80001f58:	e05a                	sd	s6,0(sp)
    80001f5a:	0080                	addi	s0,sp,64
    80001f5c:	8792                	mv	a5,tp
  int id = r_tp();
    80001f5e:	2781                	sext.w	a5,a5
  c->proc = 0;
    80001f60:	00779a93          	slli	s5,a5,0x7
    80001f64:	0000f717          	auipc	a4,0xf
    80001f68:	cfc70713          	addi	a4,a4,-772 # 80010c60 <pid_lock>
    80001f6c:	9756                	add	a4,a4,s5
    80001f6e:	02073823          	sd	zero,48(a4)
        swtch(&c->context, &p->context);
    80001f72:	0000f717          	auipc	a4,0xf
    80001f76:	d2670713          	addi	a4,a4,-730 # 80010c98 <cpus+0x8>
    80001f7a:	9aba                	add	s5,s5,a4
      if(p->state == RUNNABLE) {
    80001f7c:	498d                	li	s3,3
        p->state = RUNNING;
    80001f7e:	4b11                	li	s6,4
        c->proc = p;
    80001f80:	079e                	slli	a5,a5,0x7
    80001f82:	0000fa17          	auipc	s4,0xf
    80001f86:	cdea0a13          	addi	s4,s4,-802 # 80010c60 <pid_lock>
    80001f8a:	9a3e                	add	s4,s4,a5
    for(p = proc; p < &proc[NPROC]; p++) {
    80001f8c:	00015917          	auipc	s2,0x15
    80001f90:	d0490913          	addi	s2,s2,-764 # 80016c90 <tickslock>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001f94:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001f98:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001f9c:	10079073          	csrw	sstatus,a5
    80001fa0:	0000f497          	auipc	s1,0xf
    80001fa4:	0f048493          	addi	s1,s1,240 # 80011090 <proc>
    80001fa8:	a811                	j	80001fbc <scheduler+0x74>
      release(&p->lock);
    80001faa:	8526                	mv	a0,s1
    80001fac:	fffff097          	auipc	ra,0xfffff
    80001fb0:	d50080e7          	jalr	-688(ra) # 80000cfc <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    80001fb4:	17048493          	addi	s1,s1,368
    80001fb8:	fd248ee3          	beq	s1,s2,80001f94 <scheduler+0x4c>
      acquire(&p->lock);
    80001fbc:	8526                	mv	a0,s1
    80001fbe:	fffff097          	auipc	ra,0xfffff
    80001fc2:	c8a080e7          	jalr	-886(ra) # 80000c48 <acquire>
      if(p->state == RUNNABLE) {
    80001fc6:	4c9c                	lw	a5,24(s1)
    80001fc8:	ff3791e3          	bne	a5,s3,80001faa <scheduler+0x62>
        p->state = RUNNING;
    80001fcc:	0164ac23          	sw	s6,24(s1)
        c->proc = p;
    80001fd0:	029a3823          	sd	s1,48(s4)
        swtch(&c->context, &p->context);
    80001fd4:	06048593          	addi	a1,s1,96
    80001fd8:	8556                	mv	a0,s5
    80001fda:	00000097          	auipc	ra,0x0
    80001fde:	684080e7          	jalr	1668(ra) # 8000265e <swtch>
        c->proc = 0;
    80001fe2:	020a3823          	sd	zero,48(s4)
    80001fe6:	b7d1                	j	80001faa <scheduler+0x62>

0000000080001fe8 <sched>:
{
    80001fe8:	7179                	addi	sp,sp,-48
    80001fea:	f406                	sd	ra,40(sp)
    80001fec:	f022                	sd	s0,32(sp)
    80001fee:	ec26                	sd	s1,24(sp)
    80001ff0:	e84a                	sd	s2,16(sp)
    80001ff2:	e44e                	sd	s3,8(sp)
    80001ff4:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80001ff6:	00000097          	auipc	ra,0x0
    80001ffa:	a2e080e7          	jalr	-1490(ra) # 80001a24 <myproc>
    80001ffe:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    80002000:	fffff097          	auipc	ra,0xfffff
    80002004:	bce080e7          	jalr	-1074(ra) # 80000bce <holding>
    80002008:	c93d                	beqz	a0,8000207e <sched+0x96>
  asm volatile("mv %0, tp" : "=r" (x) );
    8000200a:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    8000200c:	2781                	sext.w	a5,a5
    8000200e:	079e                	slli	a5,a5,0x7
    80002010:	0000f717          	auipc	a4,0xf
    80002014:	c5070713          	addi	a4,a4,-944 # 80010c60 <pid_lock>
    80002018:	97ba                	add	a5,a5,a4
    8000201a:	0a87a703          	lw	a4,168(a5)
    8000201e:	4785                	li	a5,1
    80002020:	06f71763          	bne	a4,a5,8000208e <sched+0xa6>
  if(p->state == RUNNING)
    80002024:	4c98                	lw	a4,24(s1)
    80002026:	4791                	li	a5,4
    80002028:	06f70b63          	beq	a4,a5,8000209e <sched+0xb6>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000202c:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002030:	8b89                	andi	a5,a5,2
  if(intr_get())
    80002032:	efb5                	bnez	a5,800020ae <sched+0xc6>
  asm volatile("mv %0, tp" : "=r" (x) );
    80002034:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80002036:	0000f917          	auipc	s2,0xf
    8000203a:	c2a90913          	addi	s2,s2,-982 # 80010c60 <pid_lock>
    8000203e:	2781                	sext.w	a5,a5
    80002040:	079e                	slli	a5,a5,0x7
    80002042:	97ca                	add	a5,a5,s2
    80002044:	0ac7a983          	lw	s3,172(a5)
    80002048:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    8000204a:	2781                	sext.w	a5,a5
    8000204c:	079e                	slli	a5,a5,0x7
    8000204e:	0000f597          	auipc	a1,0xf
    80002052:	c4a58593          	addi	a1,a1,-950 # 80010c98 <cpus+0x8>
    80002056:	95be                	add	a1,a1,a5
    80002058:	06048513          	addi	a0,s1,96
    8000205c:	00000097          	auipc	ra,0x0
    80002060:	602080e7          	jalr	1538(ra) # 8000265e <swtch>
    80002064:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    80002066:	2781                	sext.w	a5,a5
    80002068:	079e                	slli	a5,a5,0x7
    8000206a:	993e                	add	s2,s2,a5
    8000206c:	0b392623          	sw	s3,172(s2)
}
    80002070:	70a2                	ld	ra,40(sp)
    80002072:	7402                	ld	s0,32(sp)
    80002074:	64e2                	ld	s1,24(sp)
    80002076:	6942                	ld	s2,16(sp)
    80002078:	69a2                	ld	s3,8(sp)
    8000207a:	6145                	addi	sp,sp,48
    8000207c:	8082                	ret
    panic("sched p->lock");
    8000207e:	00006517          	auipc	a0,0x6
    80002082:	1a250513          	addi	a0,a0,418 # 80008220 <digits+0x1e0>
    80002086:	ffffe097          	auipc	ra,0xffffe
    8000208a:	4ba080e7          	jalr	1210(ra) # 80000540 <panic>
    panic("sched locks");
    8000208e:	00006517          	auipc	a0,0x6
    80002092:	1a250513          	addi	a0,a0,418 # 80008230 <digits+0x1f0>
    80002096:	ffffe097          	auipc	ra,0xffffe
    8000209a:	4aa080e7          	jalr	1194(ra) # 80000540 <panic>
    panic("sched running");
    8000209e:	00006517          	auipc	a0,0x6
    800020a2:	1a250513          	addi	a0,a0,418 # 80008240 <digits+0x200>
    800020a6:	ffffe097          	auipc	ra,0xffffe
    800020aa:	49a080e7          	jalr	1178(ra) # 80000540 <panic>
    panic("sched interruptible");
    800020ae:	00006517          	auipc	a0,0x6
    800020b2:	1a250513          	addi	a0,a0,418 # 80008250 <digits+0x210>
    800020b6:	ffffe097          	auipc	ra,0xffffe
    800020ba:	48a080e7          	jalr	1162(ra) # 80000540 <panic>

00000000800020be <yield>:
{
    800020be:	1101                	addi	sp,sp,-32
    800020c0:	ec06                	sd	ra,24(sp)
    800020c2:	e822                	sd	s0,16(sp)
    800020c4:	e426                	sd	s1,8(sp)
    800020c6:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    800020c8:	00000097          	auipc	ra,0x0
    800020cc:	95c080e7          	jalr	-1700(ra) # 80001a24 <myproc>
    800020d0:	84aa                	mv	s1,a0
  acquire(&p->lock);
    800020d2:	fffff097          	auipc	ra,0xfffff
    800020d6:	b76080e7          	jalr	-1162(ra) # 80000c48 <acquire>
  p->state = RUNNABLE;
    800020da:	478d                	li	a5,3
    800020dc:	cc9c                	sw	a5,24(s1)
  sched();
    800020de:	00000097          	auipc	ra,0x0
    800020e2:	f0a080e7          	jalr	-246(ra) # 80001fe8 <sched>
  release(&p->lock);
    800020e6:	8526                	mv	a0,s1
    800020e8:	fffff097          	auipc	ra,0xfffff
    800020ec:	c14080e7          	jalr	-1004(ra) # 80000cfc <release>
}
    800020f0:	60e2                	ld	ra,24(sp)
    800020f2:	6442                	ld	s0,16(sp)
    800020f4:	64a2                	ld	s1,8(sp)
    800020f6:	6105                	addi	sp,sp,32
    800020f8:	8082                	ret

00000000800020fa <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    800020fa:	7179                	addi	sp,sp,-48
    800020fc:	f406                	sd	ra,40(sp)
    800020fe:	f022                	sd	s0,32(sp)
    80002100:	ec26                	sd	s1,24(sp)
    80002102:	e84a                	sd	s2,16(sp)
    80002104:	e44e                	sd	s3,8(sp)
    80002106:	1800                	addi	s0,sp,48
    80002108:	89aa                	mv	s3,a0
    8000210a:	892e                	mv	s2,a1
  struct proc *p = myproc();
    8000210c:	00000097          	auipc	ra,0x0
    80002110:	918080e7          	jalr	-1768(ra) # 80001a24 <myproc>
    80002114:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
    80002116:	fffff097          	auipc	ra,0xfffff
    8000211a:	b32080e7          	jalr	-1230(ra) # 80000c48 <acquire>
  release(lk);
    8000211e:	854a                	mv	a0,s2
    80002120:	fffff097          	auipc	ra,0xfffff
    80002124:	bdc080e7          	jalr	-1060(ra) # 80000cfc <release>

  // Go to sleep.
  p->chan = chan;
    80002128:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    8000212c:	4789                	li	a5,2
    8000212e:	cc9c                	sw	a5,24(s1)

  sched();
    80002130:	00000097          	auipc	ra,0x0
    80002134:	eb8080e7          	jalr	-328(ra) # 80001fe8 <sched>

  // Tidy up.
  p->chan = 0;
    80002138:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    8000213c:	8526                	mv	a0,s1
    8000213e:	fffff097          	auipc	ra,0xfffff
    80002142:	bbe080e7          	jalr	-1090(ra) # 80000cfc <release>
  acquire(lk);
    80002146:	854a                	mv	a0,s2
    80002148:	fffff097          	auipc	ra,0xfffff
    8000214c:	b00080e7          	jalr	-1280(ra) # 80000c48 <acquire>
}
    80002150:	70a2                	ld	ra,40(sp)
    80002152:	7402                	ld	s0,32(sp)
    80002154:	64e2                	ld	s1,24(sp)
    80002156:	6942                	ld	s2,16(sp)
    80002158:	69a2                	ld	s3,8(sp)
    8000215a:	6145                	addi	sp,sp,48
    8000215c:	8082                	ret

000000008000215e <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void
wakeup(void *chan)
{
    8000215e:	7139                	addi	sp,sp,-64
    80002160:	fc06                	sd	ra,56(sp)
    80002162:	f822                	sd	s0,48(sp)
    80002164:	f426                	sd	s1,40(sp)
    80002166:	f04a                	sd	s2,32(sp)
    80002168:	ec4e                	sd	s3,24(sp)
    8000216a:	e852                	sd	s4,16(sp)
    8000216c:	e456                	sd	s5,8(sp)
    8000216e:	0080                	addi	s0,sp,64
    80002170:	8a2a                	mv	s4,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    80002172:	0000f497          	auipc	s1,0xf
    80002176:	f1e48493          	addi	s1,s1,-226 # 80011090 <proc>
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
    8000217a:	4989                	li	s3,2
        p->state = RUNNABLE;
    8000217c:	4a8d                	li	s5,3
  for(p = proc; p < &proc[NPROC]; p++) {
    8000217e:	00015917          	auipc	s2,0x15
    80002182:	b1290913          	addi	s2,s2,-1262 # 80016c90 <tickslock>
    80002186:	a811                	j	8000219a <wakeup+0x3c>
      }
      release(&p->lock);
    80002188:	8526                	mv	a0,s1
    8000218a:	fffff097          	auipc	ra,0xfffff
    8000218e:	b72080e7          	jalr	-1166(ra) # 80000cfc <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80002192:	17048493          	addi	s1,s1,368
    80002196:	03248663          	beq	s1,s2,800021c2 <wakeup+0x64>
    if(p != myproc()){
    8000219a:	00000097          	auipc	ra,0x0
    8000219e:	88a080e7          	jalr	-1910(ra) # 80001a24 <myproc>
    800021a2:	fea488e3          	beq	s1,a0,80002192 <wakeup+0x34>
      acquire(&p->lock);
    800021a6:	8526                	mv	a0,s1
    800021a8:	fffff097          	auipc	ra,0xfffff
    800021ac:	aa0080e7          	jalr	-1376(ra) # 80000c48 <acquire>
      if(p->state == SLEEPING && p->chan == chan) {
    800021b0:	4c9c                	lw	a5,24(s1)
    800021b2:	fd379be3          	bne	a5,s3,80002188 <wakeup+0x2a>
    800021b6:	709c                	ld	a5,32(s1)
    800021b8:	fd4798e3          	bne	a5,s4,80002188 <wakeup+0x2a>
        p->state = RUNNABLE;
    800021bc:	0154ac23          	sw	s5,24(s1)
    800021c0:	b7e1                	j	80002188 <wakeup+0x2a>
    }
  }
}
    800021c2:	70e2                	ld	ra,56(sp)
    800021c4:	7442                	ld	s0,48(sp)
    800021c6:	74a2                	ld	s1,40(sp)
    800021c8:	7902                	ld	s2,32(sp)
    800021ca:	69e2                	ld	s3,24(sp)
    800021cc:	6a42                	ld	s4,16(sp)
    800021ce:	6aa2                	ld	s5,8(sp)
    800021d0:	6121                	addi	sp,sp,64
    800021d2:	8082                	ret

00000000800021d4 <reparent>:
{
    800021d4:	7179                	addi	sp,sp,-48
    800021d6:	f406                	sd	ra,40(sp)
    800021d8:	f022                	sd	s0,32(sp)
    800021da:	ec26                	sd	s1,24(sp)
    800021dc:	e84a                	sd	s2,16(sp)
    800021de:	e44e                	sd	s3,8(sp)
    800021e0:	e052                	sd	s4,0(sp)
    800021e2:	1800                	addi	s0,sp,48
    800021e4:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    800021e6:	0000f497          	auipc	s1,0xf
    800021ea:	eaa48493          	addi	s1,s1,-342 # 80011090 <proc>
      pp->parent = initproc;
    800021ee:	00006a17          	auipc	s4,0x6
    800021f2:	7faa0a13          	addi	s4,s4,2042 # 800089e8 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    800021f6:	00015997          	auipc	s3,0x15
    800021fa:	a9a98993          	addi	s3,s3,-1382 # 80016c90 <tickslock>
    800021fe:	a029                	j	80002208 <reparent+0x34>
    80002200:	17048493          	addi	s1,s1,368
    80002204:	01348d63          	beq	s1,s3,8000221e <reparent+0x4a>
    if(pp->parent == p){
    80002208:	7c9c                	ld	a5,56(s1)
    8000220a:	ff279be3          	bne	a5,s2,80002200 <reparent+0x2c>
      pp->parent = initproc;
    8000220e:	000a3503          	ld	a0,0(s4)
    80002212:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    80002214:	00000097          	auipc	ra,0x0
    80002218:	f4a080e7          	jalr	-182(ra) # 8000215e <wakeup>
    8000221c:	b7d5                	j	80002200 <reparent+0x2c>
}
    8000221e:	70a2                	ld	ra,40(sp)
    80002220:	7402                	ld	s0,32(sp)
    80002222:	64e2                	ld	s1,24(sp)
    80002224:	6942                	ld	s2,16(sp)
    80002226:	69a2                	ld	s3,8(sp)
    80002228:	6a02                	ld	s4,0(sp)
    8000222a:	6145                	addi	sp,sp,48
    8000222c:	8082                	ret

000000008000222e <exit>:
{
    8000222e:	7179                	addi	sp,sp,-48
    80002230:	f406                	sd	ra,40(sp)
    80002232:	f022                	sd	s0,32(sp)
    80002234:	ec26                	sd	s1,24(sp)
    80002236:	e84a                	sd	s2,16(sp)
    80002238:	e44e                	sd	s3,8(sp)
    8000223a:	e052                	sd	s4,0(sp)
    8000223c:	1800                	addi	s0,sp,48
    8000223e:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    80002240:	fffff097          	auipc	ra,0xfffff
    80002244:	7e4080e7          	jalr	2020(ra) # 80001a24 <myproc>
    80002248:	89aa                	mv	s3,a0
  if(p == initproc)
    8000224a:	00006797          	auipc	a5,0x6
    8000224e:	79e7b783          	ld	a5,1950(a5) # 800089e8 <initproc>
    80002252:	0d050493          	addi	s1,a0,208
    80002256:	15050913          	addi	s2,a0,336
    8000225a:	02a79363          	bne	a5,a0,80002280 <exit+0x52>
    panic("init exiting");
    8000225e:	00006517          	auipc	a0,0x6
    80002262:	00a50513          	addi	a0,a0,10 # 80008268 <digits+0x228>
    80002266:	ffffe097          	auipc	ra,0xffffe
    8000226a:	2da080e7          	jalr	730(ra) # 80000540 <panic>
      fileclose(f);
    8000226e:	00002097          	auipc	ra,0x2
    80002272:	37e080e7          	jalr	894(ra) # 800045ec <fileclose>
      p->ofile[fd] = 0;
    80002276:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    8000227a:	04a1                	addi	s1,s1,8
    8000227c:	01248563          	beq	s1,s2,80002286 <exit+0x58>
    if(p->ofile[fd]){
    80002280:	6088                	ld	a0,0(s1)
    80002282:	f575                	bnez	a0,8000226e <exit+0x40>
    80002284:	bfdd                	j	8000227a <exit+0x4c>
  begin_op();
    80002286:	00002097          	auipc	ra,0x2
    8000228a:	ea2080e7          	jalr	-350(ra) # 80004128 <begin_op>
  iput(p->cwd);
    8000228e:	1509b503          	ld	a0,336(s3)
    80002292:	00001097          	auipc	ra,0x1
    80002296:	6aa080e7          	jalr	1706(ra) # 8000393c <iput>
  end_op();
    8000229a:	00002097          	auipc	ra,0x2
    8000229e:	f08080e7          	jalr	-248(ra) # 800041a2 <end_op>
  p->cwd = 0;
    800022a2:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    800022a6:	0000f497          	auipc	s1,0xf
    800022aa:	9d248493          	addi	s1,s1,-1582 # 80010c78 <wait_lock>
    800022ae:	8526                	mv	a0,s1
    800022b0:	fffff097          	auipc	ra,0xfffff
    800022b4:	998080e7          	jalr	-1640(ra) # 80000c48 <acquire>
  reparent(p);
    800022b8:	854e                	mv	a0,s3
    800022ba:	00000097          	auipc	ra,0x0
    800022be:	f1a080e7          	jalr	-230(ra) # 800021d4 <reparent>
  wakeup(p->parent);
    800022c2:	0389b503          	ld	a0,56(s3)
    800022c6:	00000097          	auipc	ra,0x0
    800022ca:	e98080e7          	jalr	-360(ra) # 8000215e <wakeup>
  acquire(&p->lock);
    800022ce:	854e                	mv	a0,s3
    800022d0:	fffff097          	auipc	ra,0xfffff
    800022d4:	978080e7          	jalr	-1672(ra) # 80000c48 <acquire>
  p->xstate = status;
    800022d8:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    800022dc:	4795                	li	a5,5
    800022de:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    800022e2:	8526                	mv	a0,s1
    800022e4:	fffff097          	auipc	ra,0xfffff
    800022e8:	a18080e7          	jalr	-1512(ra) # 80000cfc <release>
  sched();
    800022ec:	00000097          	auipc	ra,0x0
    800022f0:	cfc080e7          	jalr	-772(ra) # 80001fe8 <sched>
  panic("zombie exit");
    800022f4:	00006517          	auipc	a0,0x6
    800022f8:	f8450513          	addi	a0,a0,-124 # 80008278 <digits+0x238>
    800022fc:	ffffe097          	auipc	ra,0xffffe
    80002300:	244080e7          	jalr	580(ra) # 80000540 <panic>

0000000080002304 <kill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
    80002304:	7179                	addi	sp,sp,-48
    80002306:	f406                	sd	ra,40(sp)
    80002308:	f022                	sd	s0,32(sp)
    8000230a:	ec26                	sd	s1,24(sp)
    8000230c:	e84a                	sd	s2,16(sp)
    8000230e:	e44e                	sd	s3,8(sp)
    80002310:	1800                	addi	s0,sp,48
    80002312:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    80002314:	0000f497          	auipc	s1,0xf
    80002318:	d7c48493          	addi	s1,s1,-644 # 80011090 <proc>
    8000231c:	00015997          	auipc	s3,0x15
    80002320:	97498993          	addi	s3,s3,-1676 # 80016c90 <tickslock>
    acquire(&p->lock);
    80002324:	8526                	mv	a0,s1
    80002326:	fffff097          	auipc	ra,0xfffff
    8000232a:	922080e7          	jalr	-1758(ra) # 80000c48 <acquire>
    if(p->pid == pid){
    8000232e:	589c                	lw	a5,48(s1)
    80002330:	01278d63          	beq	a5,s2,8000234a <kill+0x46>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    80002334:	8526                	mv	a0,s1
    80002336:	fffff097          	auipc	ra,0xfffff
    8000233a:	9c6080e7          	jalr	-1594(ra) # 80000cfc <release>
  for(p = proc; p < &proc[NPROC]; p++){
    8000233e:	17048493          	addi	s1,s1,368
    80002342:	ff3491e3          	bne	s1,s3,80002324 <kill+0x20>
  }
  return -1;
    80002346:	557d                	li	a0,-1
    80002348:	a829                	j	80002362 <kill+0x5e>
      p->killed = 1;
    8000234a:	4785                	li	a5,1
    8000234c:	d49c                	sw	a5,40(s1)
      if(p->state == SLEEPING){
    8000234e:	4c98                	lw	a4,24(s1)
    80002350:	4789                	li	a5,2
    80002352:	00f70f63          	beq	a4,a5,80002370 <kill+0x6c>
      release(&p->lock);
    80002356:	8526                	mv	a0,s1
    80002358:	fffff097          	auipc	ra,0xfffff
    8000235c:	9a4080e7          	jalr	-1628(ra) # 80000cfc <release>
      return 0;
    80002360:	4501                	li	a0,0
}
    80002362:	70a2                	ld	ra,40(sp)
    80002364:	7402                	ld	s0,32(sp)
    80002366:	64e2                	ld	s1,24(sp)
    80002368:	6942                	ld	s2,16(sp)
    8000236a:	69a2                	ld	s3,8(sp)
    8000236c:	6145                	addi	sp,sp,48
    8000236e:	8082                	ret
        p->state = RUNNABLE;
    80002370:	478d                	li	a5,3
    80002372:	cc9c                	sw	a5,24(s1)
    80002374:	b7cd                	j	80002356 <kill+0x52>

0000000080002376 <setkilled>:

void
setkilled(struct proc *p)
{
    80002376:	1101                	addi	sp,sp,-32
    80002378:	ec06                	sd	ra,24(sp)
    8000237a:	e822                	sd	s0,16(sp)
    8000237c:	e426                	sd	s1,8(sp)
    8000237e:	1000                	addi	s0,sp,32
    80002380:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80002382:	fffff097          	auipc	ra,0xfffff
    80002386:	8c6080e7          	jalr	-1850(ra) # 80000c48 <acquire>
  p->killed = 1;
    8000238a:	4785                	li	a5,1
    8000238c:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    8000238e:	8526                	mv	a0,s1
    80002390:	fffff097          	auipc	ra,0xfffff
    80002394:	96c080e7          	jalr	-1684(ra) # 80000cfc <release>
}
    80002398:	60e2                	ld	ra,24(sp)
    8000239a:	6442                	ld	s0,16(sp)
    8000239c:	64a2                	ld	s1,8(sp)
    8000239e:	6105                	addi	sp,sp,32
    800023a0:	8082                	ret

00000000800023a2 <killed>:

int
killed(struct proc *p)
{
    800023a2:	1101                	addi	sp,sp,-32
    800023a4:	ec06                	sd	ra,24(sp)
    800023a6:	e822                	sd	s0,16(sp)
    800023a8:	e426                	sd	s1,8(sp)
    800023aa:	e04a                	sd	s2,0(sp)
    800023ac:	1000                	addi	s0,sp,32
    800023ae:	84aa                	mv	s1,a0
  int k;
  
  acquire(&p->lock);
    800023b0:	fffff097          	auipc	ra,0xfffff
    800023b4:	898080e7          	jalr	-1896(ra) # 80000c48 <acquire>
  k = p->killed;
    800023b8:	0284a903          	lw	s2,40(s1)
  release(&p->lock);
    800023bc:	8526                	mv	a0,s1
    800023be:	fffff097          	auipc	ra,0xfffff
    800023c2:	93e080e7          	jalr	-1730(ra) # 80000cfc <release>
  return k;
}
    800023c6:	854a                	mv	a0,s2
    800023c8:	60e2                	ld	ra,24(sp)
    800023ca:	6442                	ld	s0,16(sp)
    800023cc:	64a2                	ld	s1,8(sp)
    800023ce:	6902                	ld	s2,0(sp)
    800023d0:	6105                	addi	sp,sp,32
    800023d2:	8082                	ret

00000000800023d4 <wait>:
{
    800023d4:	715d                	addi	sp,sp,-80
    800023d6:	e486                	sd	ra,72(sp)
    800023d8:	e0a2                	sd	s0,64(sp)
    800023da:	fc26                	sd	s1,56(sp)
    800023dc:	f84a                	sd	s2,48(sp)
    800023de:	f44e                	sd	s3,40(sp)
    800023e0:	f052                	sd	s4,32(sp)
    800023e2:	ec56                	sd	s5,24(sp)
    800023e4:	e85a                	sd	s6,16(sp)
    800023e6:	e45e                	sd	s7,8(sp)
    800023e8:	e062                	sd	s8,0(sp)
    800023ea:	0880                	addi	s0,sp,80
    800023ec:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    800023ee:	fffff097          	auipc	ra,0xfffff
    800023f2:	636080e7          	jalr	1590(ra) # 80001a24 <myproc>
    800023f6:	892a                	mv	s2,a0
  acquire(&wait_lock);
    800023f8:	0000f517          	auipc	a0,0xf
    800023fc:	88050513          	addi	a0,a0,-1920 # 80010c78 <wait_lock>
    80002400:	fffff097          	auipc	ra,0xfffff
    80002404:	848080e7          	jalr	-1976(ra) # 80000c48 <acquire>
    havekids = 0;
    80002408:	4b81                	li	s7,0
        if(pp->state == ZOMBIE){
    8000240a:	4a15                	li	s4,5
        havekids = 1;
    8000240c:	4a85                	li	s5,1
    for(pp = proc; pp < &proc[NPROC]; pp++){
    8000240e:	00015997          	auipc	s3,0x15
    80002412:	88298993          	addi	s3,s3,-1918 # 80016c90 <tickslock>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80002416:	0000fc17          	auipc	s8,0xf
    8000241a:	862c0c13          	addi	s8,s8,-1950 # 80010c78 <wait_lock>
    8000241e:	a0d1                	j	800024e2 <wait+0x10e>
          pid = pp->pid;
    80002420:	0304a983          	lw	s3,48(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    80002424:	000b0e63          	beqz	s6,80002440 <wait+0x6c>
    80002428:	4691                	li	a3,4
    8000242a:	02c48613          	addi	a2,s1,44
    8000242e:	85da                	mv	a1,s6
    80002430:	05093503          	ld	a0,80(s2)
    80002434:	fffff097          	auipc	ra,0xfffff
    80002438:	2b0080e7          	jalr	688(ra) # 800016e4 <copyout>
    8000243c:	04054163          	bltz	a0,8000247e <wait+0xaa>
          freeproc(pp);
    80002440:	8526                	mv	a0,s1
    80002442:	fffff097          	auipc	ra,0xfffff
    80002446:	794080e7          	jalr	1940(ra) # 80001bd6 <freeproc>
          release(&pp->lock);
    8000244a:	8526                	mv	a0,s1
    8000244c:	fffff097          	auipc	ra,0xfffff
    80002450:	8b0080e7          	jalr	-1872(ra) # 80000cfc <release>
          release(&wait_lock);
    80002454:	0000f517          	auipc	a0,0xf
    80002458:	82450513          	addi	a0,a0,-2012 # 80010c78 <wait_lock>
    8000245c:	fffff097          	auipc	ra,0xfffff
    80002460:	8a0080e7          	jalr	-1888(ra) # 80000cfc <release>
}
    80002464:	854e                	mv	a0,s3
    80002466:	60a6                	ld	ra,72(sp)
    80002468:	6406                	ld	s0,64(sp)
    8000246a:	74e2                	ld	s1,56(sp)
    8000246c:	7942                	ld	s2,48(sp)
    8000246e:	79a2                	ld	s3,40(sp)
    80002470:	7a02                	ld	s4,32(sp)
    80002472:	6ae2                	ld	s5,24(sp)
    80002474:	6b42                	ld	s6,16(sp)
    80002476:	6ba2                	ld	s7,8(sp)
    80002478:	6c02                	ld	s8,0(sp)
    8000247a:	6161                	addi	sp,sp,80
    8000247c:	8082                	ret
            release(&pp->lock);
    8000247e:	8526                	mv	a0,s1
    80002480:	fffff097          	auipc	ra,0xfffff
    80002484:	87c080e7          	jalr	-1924(ra) # 80000cfc <release>
            release(&wait_lock);
    80002488:	0000e517          	auipc	a0,0xe
    8000248c:	7f050513          	addi	a0,a0,2032 # 80010c78 <wait_lock>
    80002490:	fffff097          	auipc	ra,0xfffff
    80002494:	86c080e7          	jalr	-1940(ra) # 80000cfc <release>
            return -1;
    80002498:	59fd                	li	s3,-1
    8000249a:	b7e9                	j	80002464 <wait+0x90>
    for(pp = proc; pp < &proc[NPROC]; pp++){
    8000249c:	17048493          	addi	s1,s1,368
    800024a0:	03348463          	beq	s1,s3,800024c8 <wait+0xf4>
      if(pp->parent == p){
    800024a4:	7c9c                	ld	a5,56(s1)
    800024a6:	ff279be3          	bne	a5,s2,8000249c <wait+0xc8>
        acquire(&pp->lock);
    800024aa:	8526                	mv	a0,s1
    800024ac:	ffffe097          	auipc	ra,0xffffe
    800024b0:	79c080e7          	jalr	1948(ra) # 80000c48 <acquire>
        if(pp->state == ZOMBIE){
    800024b4:	4c9c                	lw	a5,24(s1)
    800024b6:	f74785e3          	beq	a5,s4,80002420 <wait+0x4c>
        release(&pp->lock);
    800024ba:	8526                	mv	a0,s1
    800024bc:	fffff097          	auipc	ra,0xfffff
    800024c0:	840080e7          	jalr	-1984(ra) # 80000cfc <release>
        havekids = 1;
    800024c4:	8756                	mv	a4,s5
    800024c6:	bfd9                	j	8000249c <wait+0xc8>
    if(!havekids || killed(p)){
    800024c8:	c31d                	beqz	a4,800024ee <wait+0x11a>
    800024ca:	854a                	mv	a0,s2
    800024cc:	00000097          	auipc	ra,0x0
    800024d0:	ed6080e7          	jalr	-298(ra) # 800023a2 <killed>
    800024d4:	ed09                	bnez	a0,800024ee <wait+0x11a>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    800024d6:	85e2                	mv	a1,s8
    800024d8:	854a                	mv	a0,s2
    800024da:	00000097          	auipc	ra,0x0
    800024de:	c20080e7          	jalr	-992(ra) # 800020fa <sleep>
    havekids = 0;
    800024e2:	875e                	mv	a4,s7
    for(pp = proc; pp < &proc[NPROC]; pp++){
    800024e4:	0000f497          	auipc	s1,0xf
    800024e8:	bac48493          	addi	s1,s1,-1108 # 80011090 <proc>
    800024ec:	bf65                	j	800024a4 <wait+0xd0>
      release(&wait_lock);
    800024ee:	0000e517          	auipc	a0,0xe
    800024f2:	78a50513          	addi	a0,a0,1930 # 80010c78 <wait_lock>
    800024f6:	fffff097          	auipc	ra,0xfffff
    800024fa:	806080e7          	jalr	-2042(ra) # 80000cfc <release>
      return -1;
    800024fe:	59fd                	li	s3,-1
    80002500:	b795                	j	80002464 <wait+0x90>

0000000080002502 <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    80002502:	7179                	addi	sp,sp,-48
    80002504:	f406                	sd	ra,40(sp)
    80002506:	f022                	sd	s0,32(sp)
    80002508:	ec26                	sd	s1,24(sp)
    8000250a:	e84a                	sd	s2,16(sp)
    8000250c:	e44e                	sd	s3,8(sp)
    8000250e:	e052                	sd	s4,0(sp)
    80002510:	1800                	addi	s0,sp,48
    80002512:	84aa                	mv	s1,a0
    80002514:	892e                	mv	s2,a1
    80002516:	89b2                	mv	s3,a2
    80002518:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    8000251a:	fffff097          	auipc	ra,0xfffff
    8000251e:	50a080e7          	jalr	1290(ra) # 80001a24 <myproc>
  if(user_dst){
    80002522:	c08d                	beqz	s1,80002544 <either_copyout+0x42>
    return copyout(p->pagetable, dst, src, len);
    80002524:	86d2                	mv	a3,s4
    80002526:	864e                	mv	a2,s3
    80002528:	85ca                	mv	a1,s2
    8000252a:	6928                	ld	a0,80(a0)
    8000252c:	fffff097          	auipc	ra,0xfffff
    80002530:	1b8080e7          	jalr	440(ra) # 800016e4 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    80002534:	70a2                	ld	ra,40(sp)
    80002536:	7402                	ld	s0,32(sp)
    80002538:	64e2                	ld	s1,24(sp)
    8000253a:	6942                	ld	s2,16(sp)
    8000253c:	69a2                	ld	s3,8(sp)
    8000253e:	6a02                	ld	s4,0(sp)
    80002540:	6145                	addi	sp,sp,48
    80002542:	8082                	ret
    memmove((char *)dst, src, len);
    80002544:	000a061b          	sext.w	a2,s4
    80002548:	85ce                	mv	a1,s3
    8000254a:	854a                	mv	a0,s2
    8000254c:	fffff097          	auipc	ra,0xfffff
    80002550:	854080e7          	jalr	-1964(ra) # 80000da0 <memmove>
    return 0;
    80002554:	8526                	mv	a0,s1
    80002556:	bff9                	j	80002534 <either_copyout+0x32>

0000000080002558 <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    80002558:	7179                	addi	sp,sp,-48
    8000255a:	f406                	sd	ra,40(sp)
    8000255c:	f022                	sd	s0,32(sp)
    8000255e:	ec26                	sd	s1,24(sp)
    80002560:	e84a                	sd	s2,16(sp)
    80002562:	e44e                	sd	s3,8(sp)
    80002564:	e052                	sd	s4,0(sp)
    80002566:	1800                	addi	s0,sp,48
    80002568:	892a                	mv	s2,a0
    8000256a:	84ae                	mv	s1,a1
    8000256c:	89b2                	mv	s3,a2
    8000256e:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002570:	fffff097          	auipc	ra,0xfffff
    80002574:	4b4080e7          	jalr	1204(ra) # 80001a24 <myproc>
  if(user_src){
    80002578:	c08d                	beqz	s1,8000259a <either_copyin+0x42>
    return copyin(p->pagetable, dst, src, len);
    8000257a:	86d2                	mv	a3,s4
    8000257c:	864e                	mv	a2,s3
    8000257e:	85ca                	mv	a1,s2
    80002580:	6928                	ld	a0,80(a0)
    80002582:	fffff097          	auipc	ra,0xfffff
    80002586:	1ee080e7          	jalr	494(ra) # 80001770 <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    8000258a:	70a2                	ld	ra,40(sp)
    8000258c:	7402                	ld	s0,32(sp)
    8000258e:	64e2                	ld	s1,24(sp)
    80002590:	6942                	ld	s2,16(sp)
    80002592:	69a2                	ld	s3,8(sp)
    80002594:	6a02                	ld	s4,0(sp)
    80002596:	6145                	addi	sp,sp,48
    80002598:	8082                	ret
    memmove(dst, (char*)src, len);
    8000259a:	000a061b          	sext.w	a2,s4
    8000259e:	85ce                	mv	a1,s3
    800025a0:	854a                	mv	a0,s2
    800025a2:	ffffe097          	auipc	ra,0xffffe
    800025a6:	7fe080e7          	jalr	2046(ra) # 80000da0 <memmove>
    return 0;
    800025aa:	8526                	mv	a0,s1
    800025ac:	bff9                	j	8000258a <either_copyin+0x32>

00000000800025ae <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    800025ae:	715d                	addi	sp,sp,-80
    800025b0:	e486                	sd	ra,72(sp)
    800025b2:	e0a2                	sd	s0,64(sp)
    800025b4:	fc26                	sd	s1,56(sp)
    800025b6:	f84a                	sd	s2,48(sp)
    800025b8:	f44e                	sd	s3,40(sp)
    800025ba:	f052                	sd	s4,32(sp)
    800025bc:	ec56                	sd	s5,24(sp)
    800025be:	e85a                	sd	s6,16(sp)
    800025c0:	e45e                	sd	s7,8(sp)
    800025c2:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    800025c4:	00006517          	auipc	a0,0x6
    800025c8:	b0450513          	addi	a0,a0,-1276 # 800080c8 <digits+0x88>
    800025cc:	ffffe097          	auipc	ra,0xffffe
    800025d0:	fbe080e7          	jalr	-66(ra) # 8000058a <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    800025d4:	0000f497          	auipc	s1,0xf
    800025d8:	c1448493          	addi	s1,s1,-1004 # 800111e8 <proc+0x158>
    800025dc:	00015917          	auipc	s2,0x15
    800025e0:	80c90913          	addi	s2,s2,-2036 # 80016de8 <bcache+0x140>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800025e4:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    800025e6:	00006997          	auipc	s3,0x6
    800025ea:	ca298993          	addi	s3,s3,-862 # 80008288 <digits+0x248>
    printf("%d %s %s", p->pid, state, p->name);
    800025ee:	00006a97          	auipc	s5,0x6
    800025f2:	ca2a8a93          	addi	s5,s5,-862 # 80008290 <digits+0x250>
    printf("\n");
    800025f6:	00006a17          	auipc	s4,0x6
    800025fa:	ad2a0a13          	addi	s4,s4,-1326 # 800080c8 <digits+0x88>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800025fe:	00006b97          	auipc	s7,0x6
    80002602:	cd2b8b93          	addi	s7,s7,-814 # 800082d0 <states.0>
    80002606:	a00d                	j	80002628 <procdump+0x7a>
    printf("%d %s %s", p->pid, state, p->name);
    80002608:	ed86a583          	lw	a1,-296(a3)
    8000260c:	8556                	mv	a0,s5
    8000260e:	ffffe097          	auipc	ra,0xffffe
    80002612:	f7c080e7          	jalr	-132(ra) # 8000058a <printf>
    printf("\n");
    80002616:	8552                	mv	a0,s4
    80002618:	ffffe097          	auipc	ra,0xffffe
    8000261c:	f72080e7          	jalr	-142(ra) # 8000058a <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002620:	17048493          	addi	s1,s1,368
    80002624:	03248263          	beq	s1,s2,80002648 <procdump+0x9a>
    if(p->state == UNUSED)
    80002628:	86a6                	mv	a3,s1
    8000262a:	ec04a783          	lw	a5,-320(s1)
    8000262e:	dbed                	beqz	a5,80002620 <procdump+0x72>
      state = "???";
    80002630:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002632:	fcfb6be3          	bltu	s6,a5,80002608 <procdump+0x5a>
    80002636:	02079713          	slli	a4,a5,0x20
    8000263a:	01d75793          	srli	a5,a4,0x1d
    8000263e:	97de                	add	a5,a5,s7
    80002640:	6390                	ld	a2,0(a5)
    80002642:	f279                	bnez	a2,80002608 <procdump+0x5a>
      state = "???";
    80002644:	864e                	mv	a2,s3
    80002646:	b7c9                	j	80002608 <procdump+0x5a>
  }
}
    80002648:	60a6                	ld	ra,72(sp)
    8000264a:	6406                	ld	s0,64(sp)
    8000264c:	74e2                	ld	s1,56(sp)
    8000264e:	7942                	ld	s2,48(sp)
    80002650:	79a2                	ld	s3,40(sp)
    80002652:	7a02                	ld	s4,32(sp)
    80002654:	6ae2                	ld	s5,24(sp)
    80002656:	6b42                	ld	s6,16(sp)
    80002658:	6ba2                	ld	s7,8(sp)
    8000265a:	6161                	addi	sp,sp,80
    8000265c:	8082                	ret

000000008000265e <swtch>:
    8000265e:	00153023          	sd	ra,0(a0)
    80002662:	00253423          	sd	sp,8(a0)
    80002666:	e900                	sd	s0,16(a0)
    80002668:	ed04                	sd	s1,24(a0)
    8000266a:	03253023          	sd	s2,32(a0)
    8000266e:	03353423          	sd	s3,40(a0)
    80002672:	03453823          	sd	s4,48(a0)
    80002676:	03553c23          	sd	s5,56(a0)
    8000267a:	05653023          	sd	s6,64(a0)
    8000267e:	05753423          	sd	s7,72(a0)
    80002682:	05853823          	sd	s8,80(a0)
    80002686:	05953c23          	sd	s9,88(a0)
    8000268a:	07a53023          	sd	s10,96(a0)
    8000268e:	07b53423          	sd	s11,104(a0)
    80002692:	0005b083          	ld	ra,0(a1)
    80002696:	0085b103          	ld	sp,8(a1)
    8000269a:	6980                	ld	s0,16(a1)
    8000269c:	6d84                	ld	s1,24(a1)
    8000269e:	0205b903          	ld	s2,32(a1)
    800026a2:	0285b983          	ld	s3,40(a1)
    800026a6:	0305ba03          	ld	s4,48(a1)
    800026aa:	0385ba83          	ld	s5,56(a1)
    800026ae:	0405bb03          	ld	s6,64(a1)
    800026b2:	0485bb83          	ld	s7,72(a1)
    800026b6:	0505bc03          	ld	s8,80(a1)
    800026ba:	0585bc83          	ld	s9,88(a1)
    800026be:	0605bd03          	ld	s10,96(a1)
    800026c2:	0685bd83          	ld	s11,104(a1)
    800026c6:	8082                	ret

00000000800026c8 <trapinit>:

extern int devintr();

void
trapinit(void)
{
    800026c8:	1141                	addi	sp,sp,-16
    800026ca:	e406                	sd	ra,8(sp)
    800026cc:	e022                	sd	s0,0(sp)
    800026ce:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    800026d0:	00006597          	auipc	a1,0x6
    800026d4:	c3058593          	addi	a1,a1,-976 # 80008300 <states.0+0x30>
    800026d8:	00014517          	auipc	a0,0x14
    800026dc:	5b850513          	addi	a0,a0,1464 # 80016c90 <tickslock>
    800026e0:	ffffe097          	auipc	ra,0xffffe
    800026e4:	4d8080e7          	jalr	1240(ra) # 80000bb8 <initlock>
}
    800026e8:	60a2                	ld	ra,8(sp)
    800026ea:	6402                	ld	s0,0(sp)
    800026ec:	0141                	addi	sp,sp,16
    800026ee:	8082                	ret

00000000800026f0 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    800026f0:	1141                	addi	sp,sp,-16
    800026f2:	e422                	sd	s0,8(sp)
    800026f4:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    800026f6:	00003797          	auipc	a5,0x3
    800026fa:	57a78793          	addi	a5,a5,1402 # 80005c70 <kernelvec>
    800026fe:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80002702:	6422                	ld	s0,8(sp)
    80002704:	0141                	addi	sp,sp,16
    80002706:	8082                	ret

0000000080002708 <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    80002708:	1141                	addi	sp,sp,-16
    8000270a:	e406                	sd	ra,8(sp)
    8000270c:	e022                	sd	s0,0(sp)
    8000270e:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80002710:	fffff097          	auipc	ra,0xfffff
    80002714:	314080e7          	jalr	788(ra) # 80001a24 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002718:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    8000271c:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000271e:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    80002722:	00005697          	auipc	a3,0x5
    80002726:	8de68693          	addi	a3,a3,-1826 # 80007000 <_trampoline>
    8000272a:	00005717          	auipc	a4,0x5
    8000272e:	8d670713          	addi	a4,a4,-1834 # 80007000 <_trampoline>
    80002732:	8f15                	sub	a4,a4,a3
    80002734:	040007b7          	lui	a5,0x4000
    80002738:	17fd                	addi	a5,a5,-1 # 3ffffff <_entry-0x7c000001>
    8000273a:	07b2                	slli	a5,a5,0xc
    8000273c:	973e                	add	a4,a4,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    8000273e:	10571073          	csrw	stvec,a4
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    80002742:	6d38                	ld	a4,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    80002744:	18002673          	csrr	a2,satp
    80002748:	e310                	sd	a2,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    8000274a:	6d30                	ld	a2,88(a0)
    8000274c:	6138                	ld	a4,64(a0)
    8000274e:	6585                	lui	a1,0x1
    80002750:	972e                	add	a4,a4,a1
    80002752:	e618                	sd	a4,8(a2)
  p->trapframe->kernel_trap = (uint64)usertrap;
    80002754:	6d38                	ld	a4,88(a0)
    80002756:	00000617          	auipc	a2,0x0
    8000275a:	13460613          	addi	a2,a2,308 # 8000288a <usertrap>
    8000275e:	eb10                	sd	a2,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    80002760:	6d38                	ld	a4,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    80002762:	8612                	mv	a2,tp
    80002764:	f310                	sd	a2,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002766:	10002773          	csrr	a4,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    8000276a:	eff77713          	andi	a4,a4,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    8000276e:	02076713          	ori	a4,a4,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002772:	10071073          	csrw	sstatus,a4
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    80002776:	6d38                	ld	a4,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002778:	6f18                	ld	a4,24(a4)
    8000277a:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    8000277e:	6928                	ld	a0,80(a0)
    80002780:	8131                	srli	a0,a0,0xc

  // jump to userret in trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    80002782:	00005717          	auipc	a4,0x5
    80002786:	91a70713          	addi	a4,a4,-1766 # 8000709c <userret>
    8000278a:	8f15                	sub	a4,a4,a3
    8000278c:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    8000278e:	577d                	li	a4,-1
    80002790:	177e                	slli	a4,a4,0x3f
    80002792:	8d59                	or	a0,a0,a4
    80002794:	9782                	jalr	a5
}
    80002796:	60a2                	ld	ra,8(sp)
    80002798:	6402                	ld	s0,0(sp)
    8000279a:	0141                	addi	sp,sp,16
    8000279c:	8082                	ret

000000008000279e <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    8000279e:	1101                	addi	sp,sp,-32
    800027a0:	ec06                	sd	ra,24(sp)
    800027a2:	e822                	sd	s0,16(sp)
    800027a4:	e426                	sd	s1,8(sp)
    800027a6:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    800027a8:	00014497          	auipc	s1,0x14
    800027ac:	4e848493          	addi	s1,s1,1256 # 80016c90 <tickslock>
    800027b0:	8526                	mv	a0,s1
    800027b2:	ffffe097          	auipc	ra,0xffffe
    800027b6:	496080e7          	jalr	1174(ra) # 80000c48 <acquire>
  ticks++;
    800027ba:	00006517          	auipc	a0,0x6
    800027be:	23650513          	addi	a0,a0,566 # 800089f0 <ticks>
    800027c2:	411c                	lw	a5,0(a0)
    800027c4:	2785                	addiw	a5,a5,1
    800027c6:	c11c                	sw	a5,0(a0)
  wakeup(&ticks);
    800027c8:	00000097          	auipc	ra,0x0
    800027cc:	996080e7          	jalr	-1642(ra) # 8000215e <wakeup>
  release(&tickslock);
    800027d0:	8526                	mv	a0,s1
    800027d2:	ffffe097          	auipc	ra,0xffffe
    800027d6:	52a080e7          	jalr	1322(ra) # 80000cfc <release>
}
    800027da:	60e2                	ld	ra,24(sp)
    800027dc:	6442                	ld	s0,16(sp)
    800027de:	64a2                	ld	s1,8(sp)
    800027e0:	6105                	addi	sp,sp,32
    800027e2:	8082                	ret

00000000800027e4 <devintr>:
  asm volatile("csrr %0, scause" : "=r" (x) );
    800027e4:	142027f3          	csrr	a5,scause
    // the SSIP bit in sip.
    w_sip(r_sip() & ~2);

    return 2;
  } else {
    return 0;
    800027e8:	4501                	li	a0,0
  if((scause & 0x8000000000000000L) &&
    800027ea:	0807df63          	bgez	a5,80002888 <devintr+0xa4>
{
    800027ee:	1101                	addi	sp,sp,-32
    800027f0:	ec06                	sd	ra,24(sp)
    800027f2:	e822                	sd	s0,16(sp)
    800027f4:	e426                	sd	s1,8(sp)
    800027f6:	1000                	addi	s0,sp,32
     (scause & 0xff) == 9){
    800027f8:	0ff7f713          	zext.b	a4,a5
  if((scause & 0x8000000000000000L) &&
    800027fc:	46a5                	li	a3,9
    800027fe:	00d70d63          	beq	a4,a3,80002818 <devintr+0x34>
  } else if(scause == 0x8000000000000001L){
    80002802:	577d                	li	a4,-1
    80002804:	177e                	slli	a4,a4,0x3f
    80002806:	0705                	addi	a4,a4,1
    return 0;
    80002808:	4501                	li	a0,0
  } else if(scause == 0x8000000000000001L){
    8000280a:	04e78e63          	beq	a5,a4,80002866 <devintr+0x82>
  }
}
    8000280e:	60e2                	ld	ra,24(sp)
    80002810:	6442                	ld	s0,16(sp)
    80002812:	64a2                	ld	s1,8(sp)
    80002814:	6105                	addi	sp,sp,32
    80002816:	8082                	ret
    int irq = plic_claim();
    80002818:	00003097          	auipc	ra,0x3
    8000281c:	560080e7          	jalr	1376(ra) # 80005d78 <plic_claim>
    80002820:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    80002822:	47a9                	li	a5,10
    80002824:	02f50763          	beq	a0,a5,80002852 <devintr+0x6e>
    } else if(irq == VIRTIO0_IRQ){
    80002828:	4785                	li	a5,1
    8000282a:	02f50963          	beq	a0,a5,8000285c <devintr+0x78>
    return 1;
    8000282e:	4505                	li	a0,1
    } else if(irq){
    80002830:	dcf9                	beqz	s1,8000280e <devintr+0x2a>
      printf("unexpected interrupt irq=%d\n", irq);
    80002832:	85a6                	mv	a1,s1
    80002834:	00006517          	auipc	a0,0x6
    80002838:	ad450513          	addi	a0,a0,-1324 # 80008308 <states.0+0x38>
    8000283c:	ffffe097          	auipc	ra,0xffffe
    80002840:	d4e080e7          	jalr	-690(ra) # 8000058a <printf>
      plic_complete(irq);
    80002844:	8526                	mv	a0,s1
    80002846:	00003097          	auipc	ra,0x3
    8000284a:	556080e7          	jalr	1366(ra) # 80005d9c <plic_complete>
    return 1;
    8000284e:	4505                	li	a0,1
    80002850:	bf7d                	j	8000280e <devintr+0x2a>
      uartintr();
    80002852:	ffffe097          	auipc	ra,0xffffe
    80002856:	1b8080e7          	jalr	440(ra) # 80000a0a <uartintr>
    if(irq)
    8000285a:	b7ed                	j	80002844 <devintr+0x60>
      virtio_disk_intr();
    8000285c:	00004097          	auipc	ra,0x4
    80002860:	bb8080e7          	jalr	-1096(ra) # 80006414 <virtio_disk_intr>
    if(irq)
    80002864:	b7c5                	j	80002844 <devintr+0x60>
    if(cpuid() == 0){
    80002866:	fffff097          	auipc	ra,0xfffff
    8000286a:	192080e7          	jalr	402(ra) # 800019f8 <cpuid>
    8000286e:	c901                	beqz	a0,8000287e <devintr+0x9a>
  asm volatile("csrr %0, sip" : "=r" (x) );
    80002870:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    80002874:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    80002876:	14479073          	csrw	sip,a5
    return 2;
    8000287a:	4509                	li	a0,2
    8000287c:	bf49                	j	8000280e <devintr+0x2a>
      clockintr();
    8000287e:	00000097          	auipc	ra,0x0
    80002882:	f20080e7          	jalr	-224(ra) # 8000279e <clockintr>
    80002886:	b7ed                	j	80002870 <devintr+0x8c>
}
    80002888:	8082                	ret

000000008000288a <usertrap>:
{
    8000288a:	1101                	addi	sp,sp,-32
    8000288c:	ec06                	sd	ra,24(sp)
    8000288e:	e822                	sd	s0,16(sp)
    80002890:	e426                	sd	s1,8(sp)
    80002892:	e04a                	sd	s2,0(sp)
    80002894:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002896:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    8000289a:	1007f793          	andi	a5,a5,256
    8000289e:	e3b1                	bnez	a5,800028e2 <usertrap+0x58>
  asm volatile("csrw stvec, %0" : : "r" (x));
    800028a0:	00003797          	auipc	a5,0x3
    800028a4:	3d078793          	addi	a5,a5,976 # 80005c70 <kernelvec>
    800028a8:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    800028ac:	fffff097          	auipc	ra,0xfffff
    800028b0:	178080e7          	jalr	376(ra) # 80001a24 <myproc>
    800028b4:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    800028b6:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800028b8:	14102773          	csrr	a4,sepc
    800028bc:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    800028be:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    800028c2:	47a1                	li	a5,8
    800028c4:	02f70763          	beq	a4,a5,800028f2 <usertrap+0x68>
  } else if((which_dev = devintr()) != 0){
    800028c8:	00000097          	auipc	ra,0x0
    800028cc:	f1c080e7          	jalr	-228(ra) # 800027e4 <devintr>
    800028d0:	892a                	mv	s2,a0
    800028d2:	c55d                	beqz	a0,80002980 <usertrap+0xf6>
  if(killed(p))
    800028d4:	8526                	mv	a0,s1
    800028d6:	00000097          	auipc	ra,0x0
    800028da:	acc080e7          	jalr	-1332(ra) # 800023a2 <killed>
    800028de:	c535                	beqz	a0,8000294a <usertrap+0xc0>
    800028e0:	a085                	j	80002940 <usertrap+0xb6>
    panic("usertrap: not from user mode");
    800028e2:	00006517          	auipc	a0,0x6
    800028e6:	a4650513          	addi	a0,a0,-1466 # 80008328 <states.0+0x58>
    800028ea:	ffffe097          	auipc	ra,0xffffe
    800028ee:	c56080e7          	jalr	-938(ra) # 80000540 <panic>
    if (strncmp(p->name, "vm-", 3) == 0) {
    800028f2:	460d                	li	a2,3
    800028f4:	00006597          	auipc	a1,0x6
    800028f8:	90c58593          	addi	a1,a1,-1780 # 80008200 <digits+0x1c0>
    800028fc:	15850513          	addi	a0,a0,344
    80002900:	ffffe097          	auipc	ra,0xffffe
    80002904:	514080e7          	jalr	1300(ra) # 80000e14 <strncmp>
    80002908:	cd31                	beqz	a0,80002964 <usertrap+0xda>
    if(killed(p))
    8000290a:	8526                	mv	a0,s1
    8000290c:	00000097          	auipc	ra,0x0
    80002910:	a96080e7          	jalr	-1386(ra) # 800023a2 <killed>
    80002914:	e125                	bnez	a0,80002974 <usertrap+0xea>
    p->trapframe->epc += 4;
    80002916:	6cb8                	ld	a4,88(s1)
    80002918:	6f1c                	ld	a5,24(a4)
    8000291a:	0791                	addi	a5,a5,4
    8000291c:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000291e:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002922:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002926:	10079073          	csrw	sstatus,a5
    syscall();
    8000292a:	00000097          	auipc	ra,0x0
    8000292e:	36e080e7          	jalr	878(ra) # 80002c98 <syscall>
  if(killed(p))
    80002932:	8526                	mv	a0,s1
    80002934:	00000097          	auipc	ra,0x0
    80002938:	a6e080e7          	jalr	-1426(ra) # 800023a2 <killed>
    8000293c:	c911                	beqz	a0,80002950 <usertrap+0xc6>
    8000293e:	4901                	li	s2,0
    exit(-1);
    80002940:	557d                	li	a0,-1
    80002942:	00000097          	auipc	ra,0x0
    80002946:	8ec080e7          	jalr	-1812(ra) # 8000222e <exit>
  if(which_dev == 2)
    8000294a:	4789                	li	a5,2
    8000294c:	0ef90c63          	beq	s2,a5,80002a44 <usertrap+0x1ba>
  usertrapret();
    80002950:	00000097          	auipc	ra,0x0
    80002954:	db8080e7          	jalr	-584(ra) # 80002708 <usertrapret>
}
    80002958:	60e2                	ld	ra,24(sp)
    8000295a:	6442                	ld	s0,16(sp)
    8000295c:	64a2                	ld	s1,8(sp)
    8000295e:	6902                	ld	s2,0(sp)
    80002960:	6105                	addi	sp,sp,32
    80002962:	8082                	ret
      p->proc_te_vm = 1;
    80002964:	4785                	li	a5,1
    80002966:	16f4a423          	sw	a5,360(s1)
      trap_and_emulate();
    8000296a:	00004097          	auipc	ra,0x4
    8000296e:	018080e7          	jalr	24(ra) # 80006982 <trap_and_emulate>
    80002972:	bf61                	j	8000290a <usertrap+0x80>
      exit(-1);
    80002974:	557d                	li	a0,-1
    80002976:	00000097          	auipc	ra,0x0
    8000297a:	8b8080e7          	jalr	-1864(ra) # 8000222e <exit>
    8000297e:	bf61                	j	80002916 <usertrap+0x8c>
  } else if (strncmp(p->name, "vm-", 3) == 0) {
    80002980:	460d                	li	a2,3
    80002982:	00006597          	auipc	a1,0x6
    80002986:	87e58593          	addi	a1,a1,-1922 # 80008200 <digits+0x1c0>
    8000298a:	15848513          	addi	a0,s1,344
    8000298e:	ffffe097          	auipc	ra,0xffffe
    80002992:	486080e7          	jalr	1158(ra) # 80000e14 <strncmp>
    80002996:	e935                	bnez	a0,80002a0a <usertrap+0x180>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002998:	14202773          	csrr	a4,scause
    if (r_scause() == 12 || r_scause() == 13 || r_scause() == 15)     // Page Fault Here
    8000299c:	47b1                	li	a5,12
    8000299e:	00f70c63          	beq	a4,a5,800029b6 <usertrap+0x12c>
    800029a2:	14202773          	csrr	a4,scause
    800029a6:	47b5                	li	a5,13
    800029a8:	00f70763          	beq	a4,a5,800029b6 <usertrap+0x12c>
    800029ac:	14202773          	csrr	a4,scause
    800029b0:	47bd                	li	a5,15
    800029b2:	04f71763          	bne	a4,a5,80002a00 <usertrap+0x176>
      printf("Page Fault\n");
    800029b6:	00006517          	auipc	a0,0x6
    800029ba:	99250513          	addi	a0,a0,-1646 # 80008348 <states.0+0x78>
    800029be:	ffffe097          	auipc	ra,0xffffe
    800029c2:	bcc080e7          	jalr	-1076(ra) # 8000058a <printf>
    800029c6:	142025f3          	csrr	a1,scause
      printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    800029ca:	5890                	lw	a2,48(s1)
    800029cc:	00006517          	auipc	a0,0x6
    800029d0:	98c50513          	addi	a0,a0,-1652 # 80008358 <states.0+0x88>
    800029d4:	ffffe097          	auipc	ra,0xffffe
    800029d8:	bb6080e7          	jalr	-1098(ra) # 8000058a <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800029dc:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    800029e0:	14302673          	csrr	a2,stval
      printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    800029e4:	00006517          	auipc	a0,0x6
    800029e8:	9a450513          	addi	a0,a0,-1628 # 80008388 <states.0+0xb8>
    800029ec:	ffffe097          	auipc	ra,0xffffe
    800029f0:	b9e080e7          	jalr	-1122(ra) # 8000058a <printf>
      setkilled(p);
    800029f4:	8526                	mv	a0,s1
    800029f6:	00000097          	auipc	ra,0x0
    800029fa:	980080e7          	jalr	-1664(ra) # 80002376 <setkilled>
    800029fe:	bf15                	j	80002932 <usertrap+0xa8>
      trap_and_emulate();
    80002a00:	00004097          	auipc	ra,0x4
    80002a04:	f82080e7          	jalr	-126(ra) # 80006982 <trap_and_emulate>
    80002a08:	b72d                	j	80002932 <usertrap+0xa8>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002a0a:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    80002a0e:	5890                	lw	a2,48(s1)
    80002a10:	00006517          	auipc	a0,0x6
    80002a14:	94850513          	addi	a0,a0,-1720 # 80008358 <states.0+0x88>
    80002a18:	ffffe097          	auipc	ra,0xffffe
    80002a1c:	b72080e7          	jalr	-1166(ra) # 8000058a <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002a20:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002a24:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002a28:	00006517          	auipc	a0,0x6
    80002a2c:	96050513          	addi	a0,a0,-1696 # 80008388 <states.0+0xb8>
    80002a30:	ffffe097          	auipc	ra,0xffffe
    80002a34:	b5a080e7          	jalr	-1190(ra) # 8000058a <printf>
    setkilled(p);
    80002a38:	8526                	mv	a0,s1
    80002a3a:	00000097          	auipc	ra,0x0
    80002a3e:	93c080e7          	jalr	-1732(ra) # 80002376 <setkilled>
    80002a42:	bdc5                	j	80002932 <usertrap+0xa8>
    yield();
    80002a44:	fffff097          	auipc	ra,0xfffff
    80002a48:	67a080e7          	jalr	1658(ra) # 800020be <yield>
    80002a4c:	b711                	j	80002950 <usertrap+0xc6>

0000000080002a4e <kerneltrap>:
{
    80002a4e:	7179                	addi	sp,sp,-48
    80002a50:	f406                	sd	ra,40(sp)
    80002a52:	f022                	sd	s0,32(sp)
    80002a54:	ec26                	sd	s1,24(sp)
    80002a56:	e84a                	sd	s2,16(sp)
    80002a58:	e44e                	sd	s3,8(sp)
    80002a5a:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002a5c:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002a60:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002a64:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80002a68:	1004f793          	andi	a5,s1,256
    80002a6c:	cb85                	beqz	a5,80002a9c <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002a6e:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002a72:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80002a74:	ef85                	bnez	a5,80002aac <kerneltrap+0x5e>
  if((which_dev = devintr()) == 0){
    80002a76:	00000097          	auipc	ra,0x0
    80002a7a:	d6e080e7          	jalr	-658(ra) # 800027e4 <devintr>
    80002a7e:	cd1d                	beqz	a0,80002abc <kerneltrap+0x6e>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002a80:	4789                	li	a5,2
    80002a82:	06f50a63          	beq	a0,a5,80002af6 <kerneltrap+0xa8>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002a86:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002a8a:	10049073          	csrw	sstatus,s1
}
    80002a8e:	70a2                	ld	ra,40(sp)
    80002a90:	7402                	ld	s0,32(sp)
    80002a92:	64e2                	ld	s1,24(sp)
    80002a94:	6942                	ld	s2,16(sp)
    80002a96:	69a2                	ld	s3,8(sp)
    80002a98:	6145                	addi	sp,sp,48
    80002a9a:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002a9c:	00006517          	auipc	a0,0x6
    80002aa0:	90c50513          	addi	a0,a0,-1780 # 800083a8 <states.0+0xd8>
    80002aa4:	ffffe097          	auipc	ra,0xffffe
    80002aa8:	a9c080e7          	jalr	-1380(ra) # 80000540 <panic>
    panic("kerneltrap: interrupts enabled");
    80002aac:	00006517          	auipc	a0,0x6
    80002ab0:	92450513          	addi	a0,a0,-1756 # 800083d0 <states.0+0x100>
    80002ab4:	ffffe097          	auipc	ra,0xffffe
    80002ab8:	a8c080e7          	jalr	-1396(ra) # 80000540 <panic>
    printf("scause %p\n", scause);
    80002abc:	85ce                	mv	a1,s3
    80002abe:	00006517          	auipc	a0,0x6
    80002ac2:	93250513          	addi	a0,a0,-1742 # 800083f0 <states.0+0x120>
    80002ac6:	ffffe097          	auipc	ra,0xffffe
    80002aca:	ac4080e7          	jalr	-1340(ra) # 8000058a <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002ace:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002ad2:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002ad6:	00006517          	auipc	a0,0x6
    80002ada:	92a50513          	addi	a0,a0,-1750 # 80008400 <states.0+0x130>
    80002ade:	ffffe097          	auipc	ra,0xffffe
    80002ae2:	aac080e7          	jalr	-1364(ra) # 8000058a <printf>
    panic("kerneltrap");
    80002ae6:	00006517          	auipc	a0,0x6
    80002aea:	93250513          	addi	a0,a0,-1742 # 80008418 <states.0+0x148>
    80002aee:	ffffe097          	auipc	ra,0xffffe
    80002af2:	a52080e7          	jalr	-1454(ra) # 80000540 <panic>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002af6:	fffff097          	auipc	ra,0xfffff
    80002afa:	f2e080e7          	jalr	-210(ra) # 80001a24 <myproc>
    80002afe:	d541                	beqz	a0,80002a86 <kerneltrap+0x38>
    80002b00:	fffff097          	auipc	ra,0xfffff
    80002b04:	f24080e7          	jalr	-220(ra) # 80001a24 <myproc>
    80002b08:	4d18                	lw	a4,24(a0)
    80002b0a:	4791                	li	a5,4
    80002b0c:	f6f71de3          	bne	a4,a5,80002a86 <kerneltrap+0x38>
    yield();
    80002b10:	fffff097          	auipc	ra,0xfffff
    80002b14:	5ae080e7          	jalr	1454(ra) # 800020be <yield>
    80002b18:	b7bd                	j	80002a86 <kerneltrap+0x38>

0000000080002b1a <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002b1a:	1101                	addi	sp,sp,-32
    80002b1c:	ec06                	sd	ra,24(sp)
    80002b1e:	e822                	sd	s0,16(sp)
    80002b20:	e426                	sd	s1,8(sp)
    80002b22:	1000                	addi	s0,sp,32
    80002b24:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002b26:	fffff097          	auipc	ra,0xfffff
    80002b2a:	efe080e7          	jalr	-258(ra) # 80001a24 <myproc>
  switch (n) {
    80002b2e:	4795                	li	a5,5
    80002b30:	0497e163          	bltu	a5,s1,80002b72 <argraw+0x58>
    80002b34:	048a                	slli	s1,s1,0x2
    80002b36:	00006717          	auipc	a4,0x6
    80002b3a:	91a70713          	addi	a4,a4,-1766 # 80008450 <states.0+0x180>
    80002b3e:	94ba                	add	s1,s1,a4
    80002b40:	409c                	lw	a5,0(s1)
    80002b42:	97ba                	add	a5,a5,a4
    80002b44:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80002b46:	6d3c                	ld	a5,88(a0)
    80002b48:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002b4a:	60e2                	ld	ra,24(sp)
    80002b4c:	6442                	ld	s0,16(sp)
    80002b4e:	64a2                	ld	s1,8(sp)
    80002b50:	6105                	addi	sp,sp,32
    80002b52:	8082                	ret
    return p->trapframe->a1;
    80002b54:	6d3c                	ld	a5,88(a0)
    80002b56:	7fa8                	ld	a0,120(a5)
    80002b58:	bfcd                	j	80002b4a <argraw+0x30>
    return p->trapframe->a2;
    80002b5a:	6d3c                	ld	a5,88(a0)
    80002b5c:	63c8                	ld	a0,128(a5)
    80002b5e:	b7f5                	j	80002b4a <argraw+0x30>
    return p->trapframe->a3;
    80002b60:	6d3c                	ld	a5,88(a0)
    80002b62:	67c8                	ld	a0,136(a5)
    80002b64:	b7dd                	j	80002b4a <argraw+0x30>
    return p->trapframe->a4;
    80002b66:	6d3c                	ld	a5,88(a0)
    80002b68:	6bc8                	ld	a0,144(a5)
    80002b6a:	b7c5                	j	80002b4a <argraw+0x30>
    return p->trapframe->a5;
    80002b6c:	6d3c                	ld	a5,88(a0)
    80002b6e:	6fc8                	ld	a0,152(a5)
    80002b70:	bfe9                	j	80002b4a <argraw+0x30>
  panic("argraw");
    80002b72:	00006517          	auipc	a0,0x6
    80002b76:	8b650513          	addi	a0,a0,-1866 # 80008428 <states.0+0x158>
    80002b7a:	ffffe097          	auipc	ra,0xffffe
    80002b7e:	9c6080e7          	jalr	-1594(ra) # 80000540 <panic>

0000000080002b82 <fetchaddr>:
{
    80002b82:	1101                	addi	sp,sp,-32
    80002b84:	ec06                	sd	ra,24(sp)
    80002b86:	e822                	sd	s0,16(sp)
    80002b88:	e426                	sd	s1,8(sp)
    80002b8a:	e04a                	sd	s2,0(sp)
    80002b8c:	1000                	addi	s0,sp,32
    80002b8e:	84aa                	mv	s1,a0
    80002b90:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002b92:	fffff097          	auipc	ra,0xfffff
    80002b96:	e92080e7          	jalr	-366(ra) # 80001a24 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    80002b9a:	653c                	ld	a5,72(a0)
    80002b9c:	02f4f863          	bgeu	s1,a5,80002bcc <fetchaddr+0x4a>
    80002ba0:	00848713          	addi	a4,s1,8
    80002ba4:	02e7e663          	bltu	a5,a4,80002bd0 <fetchaddr+0x4e>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002ba8:	46a1                	li	a3,8
    80002baa:	8626                	mv	a2,s1
    80002bac:	85ca                	mv	a1,s2
    80002bae:	6928                	ld	a0,80(a0)
    80002bb0:	fffff097          	auipc	ra,0xfffff
    80002bb4:	bc0080e7          	jalr	-1088(ra) # 80001770 <copyin>
    80002bb8:	00a03533          	snez	a0,a0
    80002bbc:	40a00533          	neg	a0,a0
}
    80002bc0:	60e2                	ld	ra,24(sp)
    80002bc2:	6442                	ld	s0,16(sp)
    80002bc4:	64a2                	ld	s1,8(sp)
    80002bc6:	6902                	ld	s2,0(sp)
    80002bc8:	6105                	addi	sp,sp,32
    80002bca:	8082                	ret
    return -1;
    80002bcc:	557d                	li	a0,-1
    80002bce:	bfcd                	j	80002bc0 <fetchaddr+0x3e>
    80002bd0:	557d                	li	a0,-1
    80002bd2:	b7fd                	j	80002bc0 <fetchaddr+0x3e>

0000000080002bd4 <fetchstr>:
{
    80002bd4:	7179                	addi	sp,sp,-48
    80002bd6:	f406                	sd	ra,40(sp)
    80002bd8:	f022                	sd	s0,32(sp)
    80002bda:	ec26                	sd	s1,24(sp)
    80002bdc:	e84a                	sd	s2,16(sp)
    80002bde:	e44e                	sd	s3,8(sp)
    80002be0:	1800                	addi	s0,sp,48
    80002be2:	892a                	mv	s2,a0
    80002be4:	84ae                	mv	s1,a1
    80002be6:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80002be8:	fffff097          	auipc	ra,0xfffff
    80002bec:	e3c080e7          	jalr	-452(ra) # 80001a24 <myproc>
  if(copyinstr(p->pagetable, buf, addr, max) < 0)
    80002bf0:	86ce                	mv	a3,s3
    80002bf2:	864a                	mv	a2,s2
    80002bf4:	85a6                	mv	a1,s1
    80002bf6:	6928                	ld	a0,80(a0)
    80002bf8:	fffff097          	auipc	ra,0xfffff
    80002bfc:	c06080e7          	jalr	-1018(ra) # 800017fe <copyinstr>
    80002c00:	00054e63          	bltz	a0,80002c1c <fetchstr+0x48>
  return strlen(buf);
    80002c04:	8526                	mv	a0,s1
    80002c06:	ffffe097          	auipc	ra,0xffffe
    80002c0a:	2b8080e7          	jalr	696(ra) # 80000ebe <strlen>
}
    80002c0e:	70a2                	ld	ra,40(sp)
    80002c10:	7402                	ld	s0,32(sp)
    80002c12:	64e2                	ld	s1,24(sp)
    80002c14:	6942                	ld	s2,16(sp)
    80002c16:	69a2                	ld	s3,8(sp)
    80002c18:	6145                	addi	sp,sp,48
    80002c1a:	8082                	ret
    return -1;
    80002c1c:	557d                	li	a0,-1
    80002c1e:	bfc5                	j	80002c0e <fetchstr+0x3a>

0000000080002c20 <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    80002c20:	1101                	addi	sp,sp,-32
    80002c22:	ec06                	sd	ra,24(sp)
    80002c24:	e822                	sd	s0,16(sp)
    80002c26:	e426                	sd	s1,8(sp)
    80002c28:	1000                	addi	s0,sp,32
    80002c2a:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002c2c:	00000097          	auipc	ra,0x0
    80002c30:	eee080e7          	jalr	-274(ra) # 80002b1a <argraw>
    80002c34:	c088                	sw	a0,0(s1)
}
    80002c36:	60e2                	ld	ra,24(sp)
    80002c38:	6442                	ld	s0,16(sp)
    80002c3a:	64a2                	ld	s1,8(sp)
    80002c3c:	6105                	addi	sp,sp,32
    80002c3e:	8082                	ret

0000000080002c40 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    80002c40:	1101                	addi	sp,sp,-32
    80002c42:	ec06                	sd	ra,24(sp)
    80002c44:	e822                	sd	s0,16(sp)
    80002c46:	e426                	sd	s1,8(sp)
    80002c48:	1000                	addi	s0,sp,32
    80002c4a:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002c4c:	00000097          	auipc	ra,0x0
    80002c50:	ece080e7          	jalr	-306(ra) # 80002b1a <argraw>
    80002c54:	e088                	sd	a0,0(s1)
}
    80002c56:	60e2                	ld	ra,24(sp)
    80002c58:	6442                	ld	s0,16(sp)
    80002c5a:	64a2                	ld	s1,8(sp)
    80002c5c:	6105                	addi	sp,sp,32
    80002c5e:	8082                	ret

0000000080002c60 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002c60:	7179                	addi	sp,sp,-48
    80002c62:	f406                	sd	ra,40(sp)
    80002c64:	f022                	sd	s0,32(sp)
    80002c66:	ec26                	sd	s1,24(sp)
    80002c68:	e84a                	sd	s2,16(sp)
    80002c6a:	1800                	addi	s0,sp,48
    80002c6c:	84ae                	mv	s1,a1
    80002c6e:	8932                	mv	s2,a2
  uint64 addr;
  argaddr(n, &addr);
    80002c70:	fd840593          	addi	a1,s0,-40
    80002c74:	00000097          	auipc	ra,0x0
    80002c78:	fcc080e7          	jalr	-52(ra) # 80002c40 <argaddr>
  return fetchstr(addr, buf, max);
    80002c7c:	864a                	mv	a2,s2
    80002c7e:	85a6                	mv	a1,s1
    80002c80:	fd843503          	ld	a0,-40(s0)
    80002c84:	00000097          	auipc	ra,0x0
    80002c88:	f50080e7          	jalr	-176(ra) # 80002bd4 <fetchstr>
}
    80002c8c:	70a2                	ld	ra,40(sp)
    80002c8e:	7402                	ld	s0,32(sp)
    80002c90:	64e2                	ld	s1,24(sp)
    80002c92:	6942                	ld	s2,16(sp)
    80002c94:	6145                	addi	sp,sp,48
    80002c96:	8082                	ret

0000000080002c98 <syscall>:
[SYS_close]   sys_close,
};

void
syscall(void)
{
    80002c98:	1101                	addi	sp,sp,-32
    80002c9a:	ec06                	sd	ra,24(sp)
    80002c9c:	e822                	sd	s0,16(sp)
    80002c9e:	e426                	sd	s1,8(sp)
    80002ca0:	e04a                	sd	s2,0(sp)
    80002ca2:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80002ca4:	fffff097          	auipc	ra,0xfffff
    80002ca8:	d80080e7          	jalr	-640(ra) # 80001a24 <myproc>
    80002cac:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80002cae:	05853903          	ld	s2,88(a0)
    80002cb2:	0a893783          	ld	a5,168(s2)
    80002cb6:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002cba:	37fd                	addiw	a5,a5,-1
    80002cbc:	4751                	li	a4,20
    80002cbe:	00f76f63          	bltu	a4,a5,80002cdc <syscall+0x44>
    80002cc2:	00369713          	slli	a4,a3,0x3
    80002cc6:	00005797          	auipc	a5,0x5
    80002cca:	7a278793          	addi	a5,a5,1954 # 80008468 <syscalls>
    80002cce:	97ba                	add	a5,a5,a4
    80002cd0:	639c                	ld	a5,0(a5)
    80002cd2:	c789                	beqz	a5,80002cdc <syscall+0x44>
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    80002cd4:	9782                	jalr	a5
    80002cd6:	06a93823          	sd	a0,112(s2)
    80002cda:	a839                	j	80002cf8 <syscall+0x60>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80002cdc:	15848613          	addi	a2,s1,344
    80002ce0:	588c                	lw	a1,48(s1)
    80002ce2:	00005517          	auipc	a0,0x5
    80002ce6:	74e50513          	addi	a0,a0,1870 # 80008430 <states.0+0x160>
    80002cea:	ffffe097          	auipc	ra,0xffffe
    80002cee:	8a0080e7          	jalr	-1888(ra) # 8000058a <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80002cf2:	6cbc                	ld	a5,88(s1)
    80002cf4:	577d                	li	a4,-1
    80002cf6:	fbb8                	sd	a4,112(a5)
  }
}
    80002cf8:	60e2                	ld	ra,24(sp)
    80002cfa:	6442                	ld	s0,16(sp)
    80002cfc:	64a2                	ld	s1,8(sp)
    80002cfe:	6902                	ld	s2,0(sp)
    80002d00:	6105                	addi	sp,sp,32
    80002d02:	8082                	ret

0000000080002d04 <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    80002d04:	1101                	addi	sp,sp,-32
    80002d06:	ec06                	sd	ra,24(sp)
    80002d08:	e822                	sd	s0,16(sp)
    80002d0a:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    80002d0c:	fec40593          	addi	a1,s0,-20
    80002d10:	4501                	li	a0,0
    80002d12:	00000097          	auipc	ra,0x0
    80002d16:	f0e080e7          	jalr	-242(ra) # 80002c20 <argint>
  exit(n);
    80002d1a:	fec42503          	lw	a0,-20(s0)
    80002d1e:	fffff097          	auipc	ra,0xfffff
    80002d22:	510080e7          	jalr	1296(ra) # 8000222e <exit>
  return 0;  // not reached
}
    80002d26:	4501                	li	a0,0
    80002d28:	60e2                	ld	ra,24(sp)
    80002d2a:	6442                	ld	s0,16(sp)
    80002d2c:	6105                	addi	sp,sp,32
    80002d2e:	8082                	ret

0000000080002d30 <sys_getpid>:

uint64
sys_getpid(void)
{
    80002d30:	1141                	addi	sp,sp,-16
    80002d32:	e406                	sd	ra,8(sp)
    80002d34:	e022                	sd	s0,0(sp)
    80002d36:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80002d38:	fffff097          	auipc	ra,0xfffff
    80002d3c:	cec080e7          	jalr	-788(ra) # 80001a24 <myproc>
}
    80002d40:	5908                	lw	a0,48(a0)
    80002d42:	60a2                	ld	ra,8(sp)
    80002d44:	6402                	ld	s0,0(sp)
    80002d46:	0141                	addi	sp,sp,16
    80002d48:	8082                	ret

0000000080002d4a <sys_fork>:

uint64
sys_fork(void)
{
    80002d4a:	1141                	addi	sp,sp,-16
    80002d4c:	e406                	sd	ra,8(sp)
    80002d4e:	e022                	sd	s0,0(sp)
    80002d50:	0800                	addi	s0,sp,16
  return fork();
    80002d52:	fffff097          	auipc	ra,0xfffff
    80002d56:	0b6080e7          	jalr	182(ra) # 80001e08 <fork>
}
    80002d5a:	60a2                	ld	ra,8(sp)
    80002d5c:	6402                	ld	s0,0(sp)
    80002d5e:	0141                	addi	sp,sp,16
    80002d60:	8082                	ret

0000000080002d62 <sys_wait>:

uint64
sys_wait(void)
{
    80002d62:	1101                	addi	sp,sp,-32
    80002d64:	ec06                	sd	ra,24(sp)
    80002d66:	e822                	sd	s0,16(sp)
    80002d68:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    80002d6a:	fe840593          	addi	a1,s0,-24
    80002d6e:	4501                	li	a0,0
    80002d70:	00000097          	auipc	ra,0x0
    80002d74:	ed0080e7          	jalr	-304(ra) # 80002c40 <argaddr>
  return wait(p);
    80002d78:	fe843503          	ld	a0,-24(s0)
    80002d7c:	fffff097          	auipc	ra,0xfffff
    80002d80:	658080e7          	jalr	1624(ra) # 800023d4 <wait>
}
    80002d84:	60e2                	ld	ra,24(sp)
    80002d86:	6442                	ld	s0,16(sp)
    80002d88:	6105                	addi	sp,sp,32
    80002d8a:	8082                	ret

0000000080002d8c <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002d8c:	7179                	addi	sp,sp,-48
    80002d8e:	f406                	sd	ra,40(sp)
    80002d90:	f022                	sd	s0,32(sp)
    80002d92:	ec26                	sd	s1,24(sp)
    80002d94:	1800                	addi	s0,sp,48
  uint64 addr;
  int n;

  argint(0, &n);
    80002d96:	fdc40593          	addi	a1,s0,-36
    80002d9a:	4501                	li	a0,0
    80002d9c:	00000097          	auipc	ra,0x0
    80002da0:	e84080e7          	jalr	-380(ra) # 80002c20 <argint>
  addr = myproc()->sz;
    80002da4:	fffff097          	auipc	ra,0xfffff
    80002da8:	c80080e7          	jalr	-896(ra) # 80001a24 <myproc>
    80002dac:	6524                	ld	s1,72(a0)
  if(growproc(n) < 0)
    80002dae:	fdc42503          	lw	a0,-36(s0)
    80002db2:	fffff097          	auipc	ra,0xfffff
    80002db6:	ffa080e7          	jalr	-6(ra) # 80001dac <growproc>
    80002dba:	00054863          	bltz	a0,80002dca <sys_sbrk+0x3e>
    return -1;
  return addr;
}
    80002dbe:	8526                	mv	a0,s1
    80002dc0:	70a2                	ld	ra,40(sp)
    80002dc2:	7402                	ld	s0,32(sp)
    80002dc4:	64e2                	ld	s1,24(sp)
    80002dc6:	6145                	addi	sp,sp,48
    80002dc8:	8082                	ret
    return -1;
    80002dca:	54fd                	li	s1,-1
    80002dcc:	bfcd                	j	80002dbe <sys_sbrk+0x32>

0000000080002dce <sys_sleep>:

uint64
sys_sleep(void)
{
    80002dce:	7139                	addi	sp,sp,-64
    80002dd0:	fc06                	sd	ra,56(sp)
    80002dd2:	f822                	sd	s0,48(sp)
    80002dd4:	f426                	sd	s1,40(sp)
    80002dd6:	f04a                	sd	s2,32(sp)
    80002dd8:	ec4e                	sd	s3,24(sp)
    80002dda:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    80002ddc:	fcc40593          	addi	a1,s0,-52
    80002de0:	4501                	li	a0,0
    80002de2:	00000097          	auipc	ra,0x0
    80002de6:	e3e080e7          	jalr	-450(ra) # 80002c20 <argint>
  acquire(&tickslock);
    80002dea:	00014517          	auipc	a0,0x14
    80002dee:	ea650513          	addi	a0,a0,-346 # 80016c90 <tickslock>
    80002df2:	ffffe097          	auipc	ra,0xffffe
    80002df6:	e56080e7          	jalr	-426(ra) # 80000c48 <acquire>
  ticks0 = ticks;
    80002dfa:	00006917          	auipc	s2,0x6
    80002dfe:	bf692903          	lw	s2,-1034(s2) # 800089f0 <ticks>
  while(ticks - ticks0 < n){
    80002e02:	fcc42783          	lw	a5,-52(s0)
    80002e06:	cf9d                	beqz	a5,80002e44 <sys_sleep+0x76>
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80002e08:	00014997          	auipc	s3,0x14
    80002e0c:	e8898993          	addi	s3,s3,-376 # 80016c90 <tickslock>
    80002e10:	00006497          	auipc	s1,0x6
    80002e14:	be048493          	addi	s1,s1,-1056 # 800089f0 <ticks>
    if(killed(myproc())){
    80002e18:	fffff097          	auipc	ra,0xfffff
    80002e1c:	c0c080e7          	jalr	-1012(ra) # 80001a24 <myproc>
    80002e20:	fffff097          	auipc	ra,0xfffff
    80002e24:	582080e7          	jalr	1410(ra) # 800023a2 <killed>
    80002e28:	ed15                	bnez	a0,80002e64 <sys_sleep+0x96>
    sleep(&ticks, &tickslock);
    80002e2a:	85ce                	mv	a1,s3
    80002e2c:	8526                	mv	a0,s1
    80002e2e:	fffff097          	auipc	ra,0xfffff
    80002e32:	2cc080e7          	jalr	716(ra) # 800020fa <sleep>
  while(ticks - ticks0 < n){
    80002e36:	409c                	lw	a5,0(s1)
    80002e38:	412787bb          	subw	a5,a5,s2
    80002e3c:	fcc42703          	lw	a4,-52(s0)
    80002e40:	fce7ece3          	bltu	a5,a4,80002e18 <sys_sleep+0x4a>
  }
  release(&tickslock);
    80002e44:	00014517          	auipc	a0,0x14
    80002e48:	e4c50513          	addi	a0,a0,-436 # 80016c90 <tickslock>
    80002e4c:	ffffe097          	auipc	ra,0xffffe
    80002e50:	eb0080e7          	jalr	-336(ra) # 80000cfc <release>
  return 0;
    80002e54:	4501                	li	a0,0
}
    80002e56:	70e2                	ld	ra,56(sp)
    80002e58:	7442                	ld	s0,48(sp)
    80002e5a:	74a2                	ld	s1,40(sp)
    80002e5c:	7902                	ld	s2,32(sp)
    80002e5e:	69e2                	ld	s3,24(sp)
    80002e60:	6121                	addi	sp,sp,64
    80002e62:	8082                	ret
      release(&tickslock);
    80002e64:	00014517          	auipc	a0,0x14
    80002e68:	e2c50513          	addi	a0,a0,-468 # 80016c90 <tickslock>
    80002e6c:	ffffe097          	auipc	ra,0xffffe
    80002e70:	e90080e7          	jalr	-368(ra) # 80000cfc <release>
      return -1;
    80002e74:	557d                	li	a0,-1
    80002e76:	b7c5                	j	80002e56 <sys_sleep+0x88>

0000000080002e78 <sys_kill>:

uint64
sys_kill(void)
{
    80002e78:	1101                	addi	sp,sp,-32
    80002e7a:	ec06                	sd	ra,24(sp)
    80002e7c:	e822                	sd	s0,16(sp)
    80002e7e:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    80002e80:	fec40593          	addi	a1,s0,-20
    80002e84:	4501                	li	a0,0
    80002e86:	00000097          	auipc	ra,0x0
    80002e8a:	d9a080e7          	jalr	-614(ra) # 80002c20 <argint>
  return kill(pid);
    80002e8e:	fec42503          	lw	a0,-20(s0)
    80002e92:	fffff097          	auipc	ra,0xfffff
    80002e96:	472080e7          	jalr	1138(ra) # 80002304 <kill>
}
    80002e9a:	60e2                	ld	ra,24(sp)
    80002e9c:	6442                	ld	s0,16(sp)
    80002e9e:	6105                	addi	sp,sp,32
    80002ea0:	8082                	ret

0000000080002ea2 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80002ea2:	1101                	addi	sp,sp,-32
    80002ea4:	ec06                	sd	ra,24(sp)
    80002ea6:	e822                	sd	s0,16(sp)
    80002ea8:	e426                	sd	s1,8(sp)
    80002eaa:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80002eac:	00014517          	auipc	a0,0x14
    80002eb0:	de450513          	addi	a0,a0,-540 # 80016c90 <tickslock>
    80002eb4:	ffffe097          	auipc	ra,0xffffe
    80002eb8:	d94080e7          	jalr	-620(ra) # 80000c48 <acquire>
  xticks = ticks;
    80002ebc:	00006497          	auipc	s1,0x6
    80002ec0:	b344a483          	lw	s1,-1228(s1) # 800089f0 <ticks>
  release(&tickslock);
    80002ec4:	00014517          	auipc	a0,0x14
    80002ec8:	dcc50513          	addi	a0,a0,-564 # 80016c90 <tickslock>
    80002ecc:	ffffe097          	auipc	ra,0xffffe
    80002ed0:	e30080e7          	jalr	-464(ra) # 80000cfc <release>
  return xticks;
}
    80002ed4:	02049513          	slli	a0,s1,0x20
    80002ed8:	9101                	srli	a0,a0,0x20
    80002eda:	60e2                	ld	ra,24(sp)
    80002edc:	6442                	ld	s0,16(sp)
    80002ede:	64a2                	ld	s1,8(sp)
    80002ee0:	6105                	addi	sp,sp,32
    80002ee2:	8082                	ret

0000000080002ee4 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80002ee4:	7179                	addi	sp,sp,-48
    80002ee6:	f406                	sd	ra,40(sp)
    80002ee8:	f022                	sd	s0,32(sp)
    80002eea:	ec26                	sd	s1,24(sp)
    80002eec:	e84a                	sd	s2,16(sp)
    80002eee:	e44e                	sd	s3,8(sp)
    80002ef0:	e052                	sd	s4,0(sp)
    80002ef2:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80002ef4:	00005597          	auipc	a1,0x5
    80002ef8:	62458593          	addi	a1,a1,1572 # 80008518 <syscalls+0xb0>
    80002efc:	00014517          	auipc	a0,0x14
    80002f00:	dac50513          	addi	a0,a0,-596 # 80016ca8 <bcache>
    80002f04:	ffffe097          	auipc	ra,0xffffe
    80002f08:	cb4080e7          	jalr	-844(ra) # 80000bb8 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80002f0c:	0001c797          	auipc	a5,0x1c
    80002f10:	d9c78793          	addi	a5,a5,-612 # 8001eca8 <bcache+0x8000>
    80002f14:	0001c717          	auipc	a4,0x1c
    80002f18:	ffc70713          	addi	a4,a4,-4 # 8001ef10 <bcache+0x8268>
    80002f1c:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80002f20:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002f24:	00014497          	auipc	s1,0x14
    80002f28:	d9c48493          	addi	s1,s1,-612 # 80016cc0 <bcache+0x18>
    b->next = bcache.head.next;
    80002f2c:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80002f2e:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80002f30:	00005a17          	auipc	s4,0x5
    80002f34:	5f0a0a13          	addi	s4,s4,1520 # 80008520 <syscalls+0xb8>
    b->next = bcache.head.next;
    80002f38:	2b893783          	ld	a5,696(s2)
    80002f3c:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80002f3e:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80002f42:	85d2                	mv	a1,s4
    80002f44:	01048513          	addi	a0,s1,16
    80002f48:	00001097          	auipc	ra,0x1
    80002f4c:	496080e7          	jalr	1174(ra) # 800043de <initsleeplock>
    bcache.head.next->prev = b;
    80002f50:	2b893783          	ld	a5,696(s2)
    80002f54:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80002f56:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002f5a:	45848493          	addi	s1,s1,1112
    80002f5e:	fd349de3          	bne	s1,s3,80002f38 <binit+0x54>
  }
}
    80002f62:	70a2                	ld	ra,40(sp)
    80002f64:	7402                	ld	s0,32(sp)
    80002f66:	64e2                	ld	s1,24(sp)
    80002f68:	6942                	ld	s2,16(sp)
    80002f6a:	69a2                	ld	s3,8(sp)
    80002f6c:	6a02                	ld	s4,0(sp)
    80002f6e:	6145                	addi	sp,sp,48
    80002f70:	8082                	ret

0000000080002f72 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80002f72:	7179                	addi	sp,sp,-48
    80002f74:	f406                	sd	ra,40(sp)
    80002f76:	f022                	sd	s0,32(sp)
    80002f78:	ec26                	sd	s1,24(sp)
    80002f7a:	e84a                	sd	s2,16(sp)
    80002f7c:	e44e                	sd	s3,8(sp)
    80002f7e:	1800                	addi	s0,sp,48
    80002f80:	892a                	mv	s2,a0
    80002f82:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    80002f84:	00014517          	auipc	a0,0x14
    80002f88:	d2450513          	addi	a0,a0,-732 # 80016ca8 <bcache>
    80002f8c:	ffffe097          	auipc	ra,0xffffe
    80002f90:	cbc080e7          	jalr	-836(ra) # 80000c48 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80002f94:	0001c497          	auipc	s1,0x1c
    80002f98:	fcc4b483          	ld	s1,-52(s1) # 8001ef60 <bcache+0x82b8>
    80002f9c:	0001c797          	auipc	a5,0x1c
    80002fa0:	f7478793          	addi	a5,a5,-140 # 8001ef10 <bcache+0x8268>
    80002fa4:	02f48f63          	beq	s1,a5,80002fe2 <bread+0x70>
    80002fa8:	873e                	mv	a4,a5
    80002faa:	a021                	j	80002fb2 <bread+0x40>
    80002fac:	68a4                	ld	s1,80(s1)
    80002fae:	02e48a63          	beq	s1,a4,80002fe2 <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    80002fb2:	449c                	lw	a5,8(s1)
    80002fb4:	ff279ce3          	bne	a5,s2,80002fac <bread+0x3a>
    80002fb8:	44dc                	lw	a5,12(s1)
    80002fba:	ff3799e3          	bne	a5,s3,80002fac <bread+0x3a>
      b->refcnt++;
    80002fbe:	40bc                	lw	a5,64(s1)
    80002fc0:	2785                	addiw	a5,a5,1
    80002fc2:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002fc4:	00014517          	auipc	a0,0x14
    80002fc8:	ce450513          	addi	a0,a0,-796 # 80016ca8 <bcache>
    80002fcc:	ffffe097          	auipc	ra,0xffffe
    80002fd0:	d30080e7          	jalr	-720(ra) # 80000cfc <release>
      acquiresleep(&b->lock);
    80002fd4:	01048513          	addi	a0,s1,16
    80002fd8:	00001097          	auipc	ra,0x1
    80002fdc:	440080e7          	jalr	1088(ra) # 80004418 <acquiresleep>
      return b;
    80002fe0:	a8b9                	j	8000303e <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002fe2:	0001c497          	auipc	s1,0x1c
    80002fe6:	f764b483          	ld	s1,-138(s1) # 8001ef58 <bcache+0x82b0>
    80002fea:	0001c797          	auipc	a5,0x1c
    80002fee:	f2678793          	addi	a5,a5,-218 # 8001ef10 <bcache+0x8268>
    80002ff2:	00f48863          	beq	s1,a5,80003002 <bread+0x90>
    80002ff6:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80002ff8:	40bc                	lw	a5,64(s1)
    80002ffa:	cf81                	beqz	a5,80003012 <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002ffc:	64a4                	ld	s1,72(s1)
    80002ffe:	fee49de3          	bne	s1,a4,80002ff8 <bread+0x86>
  panic("bget: no buffers");
    80003002:	00005517          	auipc	a0,0x5
    80003006:	52650513          	addi	a0,a0,1318 # 80008528 <syscalls+0xc0>
    8000300a:	ffffd097          	auipc	ra,0xffffd
    8000300e:	536080e7          	jalr	1334(ra) # 80000540 <panic>
      b->dev = dev;
    80003012:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80003016:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    8000301a:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    8000301e:	4785                	li	a5,1
    80003020:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80003022:	00014517          	auipc	a0,0x14
    80003026:	c8650513          	addi	a0,a0,-890 # 80016ca8 <bcache>
    8000302a:	ffffe097          	auipc	ra,0xffffe
    8000302e:	cd2080e7          	jalr	-814(ra) # 80000cfc <release>
      acquiresleep(&b->lock);
    80003032:	01048513          	addi	a0,s1,16
    80003036:	00001097          	auipc	ra,0x1
    8000303a:	3e2080e7          	jalr	994(ra) # 80004418 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    8000303e:	409c                	lw	a5,0(s1)
    80003040:	cb89                	beqz	a5,80003052 <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80003042:	8526                	mv	a0,s1
    80003044:	70a2                	ld	ra,40(sp)
    80003046:	7402                	ld	s0,32(sp)
    80003048:	64e2                	ld	s1,24(sp)
    8000304a:	6942                	ld	s2,16(sp)
    8000304c:	69a2                	ld	s3,8(sp)
    8000304e:	6145                	addi	sp,sp,48
    80003050:	8082                	ret
    virtio_disk_rw(b, 0);
    80003052:	4581                	li	a1,0
    80003054:	8526                	mv	a0,s1
    80003056:	00003097          	auipc	ra,0x3
    8000305a:	18e080e7          	jalr	398(ra) # 800061e4 <virtio_disk_rw>
    b->valid = 1;
    8000305e:	4785                	li	a5,1
    80003060:	c09c                	sw	a5,0(s1)
  return b;
    80003062:	b7c5                	j	80003042 <bread+0xd0>

0000000080003064 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    80003064:	1101                	addi	sp,sp,-32
    80003066:	ec06                	sd	ra,24(sp)
    80003068:	e822                	sd	s0,16(sp)
    8000306a:	e426                	sd	s1,8(sp)
    8000306c:	1000                	addi	s0,sp,32
    8000306e:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80003070:	0541                	addi	a0,a0,16
    80003072:	00001097          	auipc	ra,0x1
    80003076:	440080e7          	jalr	1088(ra) # 800044b2 <holdingsleep>
    8000307a:	cd01                	beqz	a0,80003092 <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    8000307c:	4585                	li	a1,1
    8000307e:	8526                	mv	a0,s1
    80003080:	00003097          	auipc	ra,0x3
    80003084:	164080e7          	jalr	356(ra) # 800061e4 <virtio_disk_rw>
}
    80003088:	60e2                	ld	ra,24(sp)
    8000308a:	6442                	ld	s0,16(sp)
    8000308c:	64a2                	ld	s1,8(sp)
    8000308e:	6105                	addi	sp,sp,32
    80003090:	8082                	ret
    panic("bwrite");
    80003092:	00005517          	auipc	a0,0x5
    80003096:	4ae50513          	addi	a0,a0,1198 # 80008540 <syscalls+0xd8>
    8000309a:	ffffd097          	auipc	ra,0xffffd
    8000309e:	4a6080e7          	jalr	1190(ra) # 80000540 <panic>

00000000800030a2 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    800030a2:	1101                	addi	sp,sp,-32
    800030a4:	ec06                	sd	ra,24(sp)
    800030a6:	e822                	sd	s0,16(sp)
    800030a8:	e426                	sd	s1,8(sp)
    800030aa:	e04a                	sd	s2,0(sp)
    800030ac:	1000                	addi	s0,sp,32
    800030ae:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    800030b0:	01050913          	addi	s2,a0,16
    800030b4:	854a                	mv	a0,s2
    800030b6:	00001097          	auipc	ra,0x1
    800030ba:	3fc080e7          	jalr	1020(ra) # 800044b2 <holdingsleep>
    800030be:	c925                	beqz	a0,8000312e <brelse+0x8c>
    panic("brelse");

  releasesleep(&b->lock);
    800030c0:	854a                	mv	a0,s2
    800030c2:	00001097          	auipc	ra,0x1
    800030c6:	3ac080e7          	jalr	940(ra) # 8000446e <releasesleep>

  acquire(&bcache.lock);
    800030ca:	00014517          	auipc	a0,0x14
    800030ce:	bde50513          	addi	a0,a0,-1058 # 80016ca8 <bcache>
    800030d2:	ffffe097          	auipc	ra,0xffffe
    800030d6:	b76080e7          	jalr	-1162(ra) # 80000c48 <acquire>
  b->refcnt--;
    800030da:	40bc                	lw	a5,64(s1)
    800030dc:	37fd                	addiw	a5,a5,-1
    800030de:	0007871b          	sext.w	a4,a5
    800030e2:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    800030e4:	e71d                	bnez	a4,80003112 <brelse+0x70>
    // no one is waiting for it.
    b->next->prev = b->prev;
    800030e6:	68b8                	ld	a4,80(s1)
    800030e8:	64bc                	ld	a5,72(s1)
    800030ea:	e73c                	sd	a5,72(a4)
    b->prev->next = b->next;
    800030ec:	68b8                	ld	a4,80(s1)
    800030ee:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    800030f0:	0001c797          	auipc	a5,0x1c
    800030f4:	bb878793          	addi	a5,a5,-1096 # 8001eca8 <bcache+0x8000>
    800030f8:	2b87b703          	ld	a4,696(a5)
    800030fc:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    800030fe:	0001c717          	auipc	a4,0x1c
    80003102:	e1270713          	addi	a4,a4,-494 # 8001ef10 <bcache+0x8268>
    80003106:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80003108:	2b87b703          	ld	a4,696(a5)
    8000310c:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    8000310e:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    80003112:	00014517          	auipc	a0,0x14
    80003116:	b9650513          	addi	a0,a0,-1130 # 80016ca8 <bcache>
    8000311a:	ffffe097          	auipc	ra,0xffffe
    8000311e:	be2080e7          	jalr	-1054(ra) # 80000cfc <release>
}
    80003122:	60e2                	ld	ra,24(sp)
    80003124:	6442                	ld	s0,16(sp)
    80003126:	64a2                	ld	s1,8(sp)
    80003128:	6902                	ld	s2,0(sp)
    8000312a:	6105                	addi	sp,sp,32
    8000312c:	8082                	ret
    panic("brelse");
    8000312e:	00005517          	auipc	a0,0x5
    80003132:	41a50513          	addi	a0,a0,1050 # 80008548 <syscalls+0xe0>
    80003136:	ffffd097          	auipc	ra,0xffffd
    8000313a:	40a080e7          	jalr	1034(ra) # 80000540 <panic>

000000008000313e <bpin>:

void
bpin(struct buf *b) {
    8000313e:	1101                	addi	sp,sp,-32
    80003140:	ec06                	sd	ra,24(sp)
    80003142:	e822                	sd	s0,16(sp)
    80003144:	e426                	sd	s1,8(sp)
    80003146:	1000                	addi	s0,sp,32
    80003148:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    8000314a:	00014517          	auipc	a0,0x14
    8000314e:	b5e50513          	addi	a0,a0,-1186 # 80016ca8 <bcache>
    80003152:	ffffe097          	auipc	ra,0xffffe
    80003156:	af6080e7          	jalr	-1290(ra) # 80000c48 <acquire>
  b->refcnt++;
    8000315a:	40bc                	lw	a5,64(s1)
    8000315c:	2785                	addiw	a5,a5,1
    8000315e:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80003160:	00014517          	auipc	a0,0x14
    80003164:	b4850513          	addi	a0,a0,-1208 # 80016ca8 <bcache>
    80003168:	ffffe097          	auipc	ra,0xffffe
    8000316c:	b94080e7          	jalr	-1132(ra) # 80000cfc <release>
}
    80003170:	60e2                	ld	ra,24(sp)
    80003172:	6442                	ld	s0,16(sp)
    80003174:	64a2                	ld	s1,8(sp)
    80003176:	6105                	addi	sp,sp,32
    80003178:	8082                	ret

000000008000317a <bunpin>:

void
bunpin(struct buf *b) {
    8000317a:	1101                	addi	sp,sp,-32
    8000317c:	ec06                	sd	ra,24(sp)
    8000317e:	e822                	sd	s0,16(sp)
    80003180:	e426                	sd	s1,8(sp)
    80003182:	1000                	addi	s0,sp,32
    80003184:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003186:	00014517          	auipc	a0,0x14
    8000318a:	b2250513          	addi	a0,a0,-1246 # 80016ca8 <bcache>
    8000318e:	ffffe097          	auipc	ra,0xffffe
    80003192:	aba080e7          	jalr	-1350(ra) # 80000c48 <acquire>
  b->refcnt--;
    80003196:	40bc                	lw	a5,64(s1)
    80003198:	37fd                	addiw	a5,a5,-1
    8000319a:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    8000319c:	00014517          	auipc	a0,0x14
    800031a0:	b0c50513          	addi	a0,a0,-1268 # 80016ca8 <bcache>
    800031a4:	ffffe097          	auipc	ra,0xffffe
    800031a8:	b58080e7          	jalr	-1192(ra) # 80000cfc <release>
}
    800031ac:	60e2                	ld	ra,24(sp)
    800031ae:	6442                	ld	s0,16(sp)
    800031b0:	64a2                	ld	s1,8(sp)
    800031b2:	6105                	addi	sp,sp,32
    800031b4:	8082                	ret

00000000800031b6 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    800031b6:	1101                	addi	sp,sp,-32
    800031b8:	ec06                	sd	ra,24(sp)
    800031ba:	e822                	sd	s0,16(sp)
    800031bc:	e426                	sd	s1,8(sp)
    800031be:	e04a                	sd	s2,0(sp)
    800031c0:	1000                	addi	s0,sp,32
    800031c2:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    800031c4:	00d5d59b          	srliw	a1,a1,0xd
    800031c8:	0001c797          	auipc	a5,0x1c
    800031cc:	1bc7a783          	lw	a5,444(a5) # 8001f384 <sb+0x1c>
    800031d0:	9dbd                	addw	a1,a1,a5
    800031d2:	00000097          	auipc	ra,0x0
    800031d6:	da0080e7          	jalr	-608(ra) # 80002f72 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    800031da:	0074f713          	andi	a4,s1,7
    800031de:	4785                	li	a5,1
    800031e0:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    800031e4:	14ce                	slli	s1,s1,0x33
    800031e6:	90d9                	srli	s1,s1,0x36
    800031e8:	00950733          	add	a4,a0,s1
    800031ec:	05874703          	lbu	a4,88(a4)
    800031f0:	00e7f6b3          	and	a3,a5,a4
    800031f4:	c69d                	beqz	a3,80003222 <bfree+0x6c>
    800031f6:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    800031f8:	94aa                	add	s1,s1,a0
    800031fa:	fff7c793          	not	a5,a5
    800031fe:	8f7d                	and	a4,a4,a5
    80003200:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    80003204:	00001097          	auipc	ra,0x1
    80003208:	0f6080e7          	jalr	246(ra) # 800042fa <log_write>
  brelse(bp);
    8000320c:	854a                	mv	a0,s2
    8000320e:	00000097          	auipc	ra,0x0
    80003212:	e94080e7          	jalr	-364(ra) # 800030a2 <brelse>
}
    80003216:	60e2                	ld	ra,24(sp)
    80003218:	6442                	ld	s0,16(sp)
    8000321a:	64a2                	ld	s1,8(sp)
    8000321c:	6902                	ld	s2,0(sp)
    8000321e:	6105                	addi	sp,sp,32
    80003220:	8082                	ret
    panic("freeing free block");
    80003222:	00005517          	auipc	a0,0x5
    80003226:	32e50513          	addi	a0,a0,814 # 80008550 <syscalls+0xe8>
    8000322a:	ffffd097          	auipc	ra,0xffffd
    8000322e:	316080e7          	jalr	790(ra) # 80000540 <panic>

0000000080003232 <balloc>:
{
    80003232:	711d                	addi	sp,sp,-96
    80003234:	ec86                	sd	ra,88(sp)
    80003236:	e8a2                	sd	s0,80(sp)
    80003238:	e4a6                	sd	s1,72(sp)
    8000323a:	e0ca                	sd	s2,64(sp)
    8000323c:	fc4e                	sd	s3,56(sp)
    8000323e:	f852                	sd	s4,48(sp)
    80003240:	f456                	sd	s5,40(sp)
    80003242:	f05a                	sd	s6,32(sp)
    80003244:	ec5e                	sd	s7,24(sp)
    80003246:	e862                	sd	s8,16(sp)
    80003248:	e466                	sd	s9,8(sp)
    8000324a:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    8000324c:	0001c797          	auipc	a5,0x1c
    80003250:	1207a783          	lw	a5,288(a5) # 8001f36c <sb+0x4>
    80003254:	cff5                	beqz	a5,80003350 <balloc+0x11e>
    80003256:	8baa                	mv	s7,a0
    80003258:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    8000325a:	0001cb17          	auipc	s6,0x1c
    8000325e:	10eb0b13          	addi	s6,s6,270 # 8001f368 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003262:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    80003264:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003266:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    80003268:	6c89                	lui	s9,0x2
    8000326a:	a061                	j	800032f2 <balloc+0xc0>
        bp->data[bi/8] |= m;  // Mark block in use.
    8000326c:	97ca                	add	a5,a5,s2
    8000326e:	8e55                	or	a2,a2,a3
    80003270:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    80003274:	854a                	mv	a0,s2
    80003276:	00001097          	auipc	ra,0x1
    8000327a:	084080e7          	jalr	132(ra) # 800042fa <log_write>
        brelse(bp);
    8000327e:	854a                	mv	a0,s2
    80003280:	00000097          	auipc	ra,0x0
    80003284:	e22080e7          	jalr	-478(ra) # 800030a2 <brelse>
  bp = bread(dev, bno);
    80003288:	85a6                	mv	a1,s1
    8000328a:	855e                	mv	a0,s7
    8000328c:	00000097          	auipc	ra,0x0
    80003290:	ce6080e7          	jalr	-794(ra) # 80002f72 <bread>
    80003294:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80003296:	40000613          	li	a2,1024
    8000329a:	4581                	li	a1,0
    8000329c:	05850513          	addi	a0,a0,88
    800032a0:	ffffe097          	auipc	ra,0xffffe
    800032a4:	aa4080e7          	jalr	-1372(ra) # 80000d44 <memset>
  log_write(bp);
    800032a8:	854a                	mv	a0,s2
    800032aa:	00001097          	auipc	ra,0x1
    800032ae:	050080e7          	jalr	80(ra) # 800042fa <log_write>
  brelse(bp);
    800032b2:	854a                	mv	a0,s2
    800032b4:	00000097          	auipc	ra,0x0
    800032b8:	dee080e7          	jalr	-530(ra) # 800030a2 <brelse>
}
    800032bc:	8526                	mv	a0,s1
    800032be:	60e6                	ld	ra,88(sp)
    800032c0:	6446                	ld	s0,80(sp)
    800032c2:	64a6                	ld	s1,72(sp)
    800032c4:	6906                	ld	s2,64(sp)
    800032c6:	79e2                	ld	s3,56(sp)
    800032c8:	7a42                	ld	s4,48(sp)
    800032ca:	7aa2                	ld	s5,40(sp)
    800032cc:	7b02                	ld	s6,32(sp)
    800032ce:	6be2                	ld	s7,24(sp)
    800032d0:	6c42                	ld	s8,16(sp)
    800032d2:	6ca2                	ld	s9,8(sp)
    800032d4:	6125                	addi	sp,sp,96
    800032d6:	8082                	ret
    brelse(bp);
    800032d8:	854a                	mv	a0,s2
    800032da:	00000097          	auipc	ra,0x0
    800032de:	dc8080e7          	jalr	-568(ra) # 800030a2 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    800032e2:	015c87bb          	addw	a5,s9,s5
    800032e6:	00078a9b          	sext.w	s5,a5
    800032ea:	004b2703          	lw	a4,4(s6)
    800032ee:	06eaf163          	bgeu	s5,a4,80003350 <balloc+0x11e>
    bp = bread(dev, BBLOCK(b, sb));
    800032f2:	41fad79b          	sraiw	a5,s5,0x1f
    800032f6:	0137d79b          	srliw	a5,a5,0x13
    800032fa:	015787bb          	addw	a5,a5,s5
    800032fe:	40d7d79b          	sraiw	a5,a5,0xd
    80003302:	01cb2583          	lw	a1,28(s6)
    80003306:	9dbd                	addw	a1,a1,a5
    80003308:	855e                	mv	a0,s7
    8000330a:	00000097          	auipc	ra,0x0
    8000330e:	c68080e7          	jalr	-920(ra) # 80002f72 <bread>
    80003312:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003314:	004b2503          	lw	a0,4(s6)
    80003318:	000a849b          	sext.w	s1,s5
    8000331c:	8762                	mv	a4,s8
    8000331e:	faa4fde3          	bgeu	s1,a0,800032d8 <balloc+0xa6>
      m = 1 << (bi % 8);
    80003322:	00777693          	andi	a3,a4,7
    80003326:	00d996bb          	sllw	a3,s3,a3
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    8000332a:	41f7579b          	sraiw	a5,a4,0x1f
    8000332e:	01d7d79b          	srliw	a5,a5,0x1d
    80003332:	9fb9                	addw	a5,a5,a4
    80003334:	4037d79b          	sraiw	a5,a5,0x3
    80003338:	00f90633          	add	a2,s2,a5
    8000333c:	05864603          	lbu	a2,88(a2)
    80003340:	00c6f5b3          	and	a1,a3,a2
    80003344:	d585                	beqz	a1,8000326c <balloc+0x3a>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003346:	2705                	addiw	a4,a4,1
    80003348:	2485                	addiw	s1,s1,1
    8000334a:	fd471ae3          	bne	a4,s4,8000331e <balloc+0xec>
    8000334e:	b769                	j	800032d8 <balloc+0xa6>
  printf("balloc: out of blocks\n");
    80003350:	00005517          	auipc	a0,0x5
    80003354:	21850513          	addi	a0,a0,536 # 80008568 <syscalls+0x100>
    80003358:	ffffd097          	auipc	ra,0xffffd
    8000335c:	232080e7          	jalr	562(ra) # 8000058a <printf>
  return 0;
    80003360:	4481                	li	s1,0
    80003362:	bfa9                	j	800032bc <balloc+0x8a>

0000000080003364 <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    80003364:	7179                	addi	sp,sp,-48
    80003366:	f406                	sd	ra,40(sp)
    80003368:	f022                	sd	s0,32(sp)
    8000336a:	ec26                	sd	s1,24(sp)
    8000336c:	e84a                	sd	s2,16(sp)
    8000336e:	e44e                	sd	s3,8(sp)
    80003370:	e052                	sd	s4,0(sp)
    80003372:	1800                	addi	s0,sp,48
    80003374:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    80003376:	47ad                	li	a5,11
    80003378:	02b7e863          	bltu	a5,a1,800033a8 <bmap+0x44>
    if((addr = ip->addrs[bn]) == 0){
    8000337c:	02059793          	slli	a5,a1,0x20
    80003380:	01e7d593          	srli	a1,a5,0x1e
    80003384:	00b504b3          	add	s1,a0,a1
    80003388:	0504a903          	lw	s2,80(s1)
    8000338c:	06091e63          	bnez	s2,80003408 <bmap+0xa4>
      addr = balloc(ip->dev);
    80003390:	4108                	lw	a0,0(a0)
    80003392:	00000097          	auipc	ra,0x0
    80003396:	ea0080e7          	jalr	-352(ra) # 80003232 <balloc>
    8000339a:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    8000339e:	06090563          	beqz	s2,80003408 <bmap+0xa4>
        return 0;
      ip->addrs[bn] = addr;
    800033a2:	0524a823          	sw	s2,80(s1)
    800033a6:	a08d                	j	80003408 <bmap+0xa4>
    }
    return addr;
  }
  bn -= NDIRECT;
    800033a8:	ff45849b          	addiw	s1,a1,-12
    800033ac:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    800033b0:	0ff00793          	li	a5,255
    800033b4:	08e7e563          	bltu	a5,a4,8000343e <bmap+0xda>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    800033b8:	08052903          	lw	s2,128(a0)
    800033bc:	00091d63          	bnez	s2,800033d6 <bmap+0x72>
      addr = balloc(ip->dev);
    800033c0:	4108                	lw	a0,0(a0)
    800033c2:	00000097          	auipc	ra,0x0
    800033c6:	e70080e7          	jalr	-400(ra) # 80003232 <balloc>
    800033ca:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    800033ce:	02090d63          	beqz	s2,80003408 <bmap+0xa4>
        return 0;
      ip->addrs[NDIRECT] = addr;
    800033d2:	0929a023          	sw	s2,128(s3)
    }
    bp = bread(ip->dev, addr);
    800033d6:	85ca                	mv	a1,s2
    800033d8:	0009a503          	lw	a0,0(s3)
    800033dc:	00000097          	auipc	ra,0x0
    800033e0:	b96080e7          	jalr	-1130(ra) # 80002f72 <bread>
    800033e4:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    800033e6:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    800033ea:	02049713          	slli	a4,s1,0x20
    800033ee:	01e75593          	srli	a1,a4,0x1e
    800033f2:	00b784b3          	add	s1,a5,a1
    800033f6:	0004a903          	lw	s2,0(s1)
    800033fa:	02090063          	beqz	s2,8000341a <bmap+0xb6>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    800033fe:	8552                	mv	a0,s4
    80003400:	00000097          	auipc	ra,0x0
    80003404:	ca2080e7          	jalr	-862(ra) # 800030a2 <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    80003408:	854a                	mv	a0,s2
    8000340a:	70a2                	ld	ra,40(sp)
    8000340c:	7402                	ld	s0,32(sp)
    8000340e:	64e2                	ld	s1,24(sp)
    80003410:	6942                	ld	s2,16(sp)
    80003412:	69a2                	ld	s3,8(sp)
    80003414:	6a02                	ld	s4,0(sp)
    80003416:	6145                	addi	sp,sp,48
    80003418:	8082                	ret
      addr = balloc(ip->dev);
    8000341a:	0009a503          	lw	a0,0(s3)
    8000341e:	00000097          	auipc	ra,0x0
    80003422:	e14080e7          	jalr	-492(ra) # 80003232 <balloc>
    80003426:	0005091b          	sext.w	s2,a0
      if(addr){
    8000342a:	fc090ae3          	beqz	s2,800033fe <bmap+0x9a>
        a[bn] = addr;
    8000342e:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    80003432:	8552                	mv	a0,s4
    80003434:	00001097          	auipc	ra,0x1
    80003438:	ec6080e7          	jalr	-314(ra) # 800042fa <log_write>
    8000343c:	b7c9                	j	800033fe <bmap+0x9a>
  panic("bmap: out of range");
    8000343e:	00005517          	auipc	a0,0x5
    80003442:	14250513          	addi	a0,a0,322 # 80008580 <syscalls+0x118>
    80003446:	ffffd097          	auipc	ra,0xffffd
    8000344a:	0fa080e7          	jalr	250(ra) # 80000540 <panic>

000000008000344e <iget>:
{
    8000344e:	7179                	addi	sp,sp,-48
    80003450:	f406                	sd	ra,40(sp)
    80003452:	f022                	sd	s0,32(sp)
    80003454:	ec26                	sd	s1,24(sp)
    80003456:	e84a                	sd	s2,16(sp)
    80003458:	e44e                	sd	s3,8(sp)
    8000345a:	e052                	sd	s4,0(sp)
    8000345c:	1800                	addi	s0,sp,48
    8000345e:	89aa                	mv	s3,a0
    80003460:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    80003462:	0001c517          	auipc	a0,0x1c
    80003466:	f2650513          	addi	a0,a0,-218 # 8001f388 <itable>
    8000346a:	ffffd097          	auipc	ra,0xffffd
    8000346e:	7de080e7          	jalr	2014(ra) # 80000c48 <acquire>
  empty = 0;
    80003472:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003474:	0001c497          	auipc	s1,0x1c
    80003478:	f2c48493          	addi	s1,s1,-212 # 8001f3a0 <itable+0x18>
    8000347c:	0001e697          	auipc	a3,0x1e
    80003480:	9b468693          	addi	a3,a3,-1612 # 80020e30 <log>
    80003484:	a039                	j	80003492 <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003486:	02090b63          	beqz	s2,800034bc <iget+0x6e>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    8000348a:	08848493          	addi	s1,s1,136
    8000348e:	02d48a63          	beq	s1,a3,800034c2 <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    80003492:	449c                	lw	a5,8(s1)
    80003494:	fef059e3          	blez	a5,80003486 <iget+0x38>
    80003498:	4098                	lw	a4,0(s1)
    8000349a:	ff3716e3          	bne	a4,s3,80003486 <iget+0x38>
    8000349e:	40d8                	lw	a4,4(s1)
    800034a0:	ff4713e3          	bne	a4,s4,80003486 <iget+0x38>
      ip->ref++;
    800034a4:	2785                	addiw	a5,a5,1
    800034a6:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    800034a8:	0001c517          	auipc	a0,0x1c
    800034ac:	ee050513          	addi	a0,a0,-288 # 8001f388 <itable>
    800034b0:	ffffe097          	auipc	ra,0xffffe
    800034b4:	84c080e7          	jalr	-1972(ra) # 80000cfc <release>
      return ip;
    800034b8:	8926                	mv	s2,s1
    800034ba:	a03d                	j	800034e8 <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    800034bc:	f7f9                	bnez	a5,8000348a <iget+0x3c>
    800034be:	8926                	mv	s2,s1
    800034c0:	b7e9                	j	8000348a <iget+0x3c>
  if(empty == 0)
    800034c2:	02090c63          	beqz	s2,800034fa <iget+0xac>
  ip->dev = dev;
    800034c6:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    800034ca:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    800034ce:	4785                	li	a5,1
    800034d0:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    800034d4:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    800034d8:	0001c517          	auipc	a0,0x1c
    800034dc:	eb050513          	addi	a0,a0,-336 # 8001f388 <itable>
    800034e0:	ffffe097          	auipc	ra,0xffffe
    800034e4:	81c080e7          	jalr	-2020(ra) # 80000cfc <release>
}
    800034e8:	854a                	mv	a0,s2
    800034ea:	70a2                	ld	ra,40(sp)
    800034ec:	7402                	ld	s0,32(sp)
    800034ee:	64e2                	ld	s1,24(sp)
    800034f0:	6942                	ld	s2,16(sp)
    800034f2:	69a2                	ld	s3,8(sp)
    800034f4:	6a02                	ld	s4,0(sp)
    800034f6:	6145                	addi	sp,sp,48
    800034f8:	8082                	ret
    panic("iget: no inodes");
    800034fa:	00005517          	auipc	a0,0x5
    800034fe:	09e50513          	addi	a0,a0,158 # 80008598 <syscalls+0x130>
    80003502:	ffffd097          	auipc	ra,0xffffd
    80003506:	03e080e7          	jalr	62(ra) # 80000540 <panic>

000000008000350a <fsinit>:
fsinit(int dev) {
    8000350a:	7179                	addi	sp,sp,-48
    8000350c:	f406                	sd	ra,40(sp)
    8000350e:	f022                	sd	s0,32(sp)
    80003510:	ec26                	sd	s1,24(sp)
    80003512:	e84a                	sd	s2,16(sp)
    80003514:	e44e                	sd	s3,8(sp)
    80003516:	1800                	addi	s0,sp,48
    80003518:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    8000351a:	4585                	li	a1,1
    8000351c:	00000097          	auipc	ra,0x0
    80003520:	a56080e7          	jalr	-1450(ra) # 80002f72 <bread>
    80003524:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    80003526:	0001c997          	auipc	s3,0x1c
    8000352a:	e4298993          	addi	s3,s3,-446 # 8001f368 <sb>
    8000352e:	02000613          	li	a2,32
    80003532:	05850593          	addi	a1,a0,88
    80003536:	854e                	mv	a0,s3
    80003538:	ffffe097          	auipc	ra,0xffffe
    8000353c:	868080e7          	jalr	-1944(ra) # 80000da0 <memmove>
  brelse(bp);
    80003540:	8526                	mv	a0,s1
    80003542:	00000097          	auipc	ra,0x0
    80003546:	b60080e7          	jalr	-1184(ra) # 800030a2 <brelse>
  if(sb.magic != FSMAGIC)
    8000354a:	0009a703          	lw	a4,0(s3)
    8000354e:	102037b7          	lui	a5,0x10203
    80003552:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80003556:	02f71263          	bne	a4,a5,8000357a <fsinit+0x70>
  initlog(dev, &sb);
    8000355a:	0001c597          	auipc	a1,0x1c
    8000355e:	e0e58593          	addi	a1,a1,-498 # 8001f368 <sb>
    80003562:	854a                	mv	a0,s2
    80003564:	00001097          	auipc	ra,0x1
    80003568:	b2c080e7          	jalr	-1236(ra) # 80004090 <initlog>
}
    8000356c:	70a2                	ld	ra,40(sp)
    8000356e:	7402                	ld	s0,32(sp)
    80003570:	64e2                	ld	s1,24(sp)
    80003572:	6942                	ld	s2,16(sp)
    80003574:	69a2                	ld	s3,8(sp)
    80003576:	6145                	addi	sp,sp,48
    80003578:	8082                	ret
    panic("invalid file system");
    8000357a:	00005517          	auipc	a0,0x5
    8000357e:	02e50513          	addi	a0,a0,46 # 800085a8 <syscalls+0x140>
    80003582:	ffffd097          	auipc	ra,0xffffd
    80003586:	fbe080e7          	jalr	-66(ra) # 80000540 <panic>

000000008000358a <iinit>:
{
    8000358a:	7179                	addi	sp,sp,-48
    8000358c:	f406                	sd	ra,40(sp)
    8000358e:	f022                	sd	s0,32(sp)
    80003590:	ec26                	sd	s1,24(sp)
    80003592:	e84a                	sd	s2,16(sp)
    80003594:	e44e                	sd	s3,8(sp)
    80003596:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    80003598:	00005597          	auipc	a1,0x5
    8000359c:	02858593          	addi	a1,a1,40 # 800085c0 <syscalls+0x158>
    800035a0:	0001c517          	auipc	a0,0x1c
    800035a4:	de850513          	addi	a0,a0,-536 # 8001f388 <itable>
    800035a8:	ffffd097          	auipc	ra,0xffffd
    800035ac:	610080e7          	jalr	1552(ra) # 80000bb8 <initlock>
  for(i = 0; i < NINODE; i++) {
    800035b0:	0001c497          	auipc	s1,0x1c
    800035b4:	e0048493          	addi	s1,s1,-512 # 8001f3b0 <itable+0x28>
    800035b8:	0001e997          	auipc	s3,0x1e
    800035bc:	88898993          	addi	s3,s3,-1912 # 80020e40 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    800035c0:	00005917          	auipc	s2,0x5
    800035c4:	00890913          	addi	s2,s2,8 # 800085c8 <syscalls+0x160>
    800035c8:	85ca                	mv	a1,s2
    800035ca:	8526                	mv	a0,s1
    800035cc:	00001097          	auipc	ra,0x1
    800035d0:	e12080e7          	jalr	-494(ra) # 800043de <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    800035d4:	08848493          	addi	s1,s1,136
    800035d8:	ff3498e3          	bne	s1,s3,800035c8 <iinit+0x3e>
}
    800035dc:	70a2                	ld	ra,40(sp)
    800035de:	7402                	ld	s0,32(sp)
    800035e0:	64e2                	ld	s1,24(sp)
    800035e2:	6942                	ld	s2,16(sp)
    800035e4:	69a2                	ld	s3,8(sp)
    800035e6:	6145                	addi	sp,sp,48
    800035e8:	8082                	ret

00000000800035ea <ialloc>:
{
    800035ea:	7139                	addi	sp,sp,-64
    800035ec:	fc06                	sd	ra,56(sp)
    800035ee:	f822                	sd	s0,48(sp)
    800035f0:	f426                	sd	s1,40(sp)
    800035f2:	f04a                	sd	s2,32(sp)
    800035f4:	ec4e                	sd	s3,24(sp)
    800035f6:	e852                	sd	s4,16(sp)
    800035f8:	e456                	sd	s5,8(sp)
    800035fa:	e05a                	sd	s6,0(sp)
    800035fc:	0080                	addi	s0,sp,64
  for(inum = 1; inum < sb.ninodes; inum++){
    800035fe:	0001c717          	auipc	a4,0x1c
    80003602:	d7672703          	lw	a4,-650(a4) # 8001f374 <sb+0xc>
    80003606:	4785                	li	a5,1
    80003608:	04e7f863          	bgeu	a5,a4,80003658 <ialloc+0x6e>
    8000360c:	8aaa                	mv	s5,a0
    8000360e:	8b2e                	mv	s6,a1
    80003610:	4905                	li	s2,1
    bp = bread(dev, IBLOCK(inum, sb));
    80003612:	0001ca17          	auipc	s4,0x1c
    80003616:	d56a0a13          	addi	s4,s4,-682 # 8001f368 <sb>
    8000361a:	00495593          	srli	a1,s2,0x4
    8000361e:	018a2783          	lw	a5,24(s4)
    80003622:	9dbd                	addw	a1,a1,a5
    80003624:	8556                	mv	a0,s5
    80003626:	00000097          	auipc	ra,0x0
    8000362a:	94c080e7          	jalr	-1716(ra) # 80002f72 <bread>
    8000362e:	84aa                	mv	s1,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    80003630:	05850993          	addi	s3,a0,88
    80003634:	00f97793          	andi	a5,s2,15
    80003638:	079a                	slli	a5,a5,0x6
    8000363a:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    8000363c:	00099783          	lh	a5,0(s3)
    80003640:	cf9d                	beqz	a5,8000367e <ialloc+0x94>
    brelse(bp);
    80003642:	00000097          	auipc	ra,0x0
    80003646:	a60080e7          	jalr	-1440(ra) # 800030a2 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    8000364a:	0905                	addi	s2,s2,1
    8000364c:	00ca2703          	lw	a4,12(s4)
    80003650:	0009079b          	sext.w	a5,s2
    80003654:	fce7e3e3          	bltu	a5,a4,8000361a <ialloc+0x30>
  printf("ialloc: no inodes\n");
    80003658:	00005517          	auipc	a0,0x5
    8000365c:	f7850513          	addi	a0,a0,-136 # 800085d0 <syscalls+0x168>
    80003660:	ffffd097          	auipc	ra,0xffffd
    80003664:	f2a080e7          	jalr	-214(ra) # 8000058a <printf>
  return 0;
    80003668:	4501                	li	a0,0
}
    8000366a:	70e2                	ld	ra,56(sp)
    8000366c:	7442                	ld	s0,48(sp)
    8000366e:	74a2                	ld	s1,40(sp)
    80003670:	7902                	ld	s2,32(sp)
    80003672:	69e2                	ld	s3,24(sp)
    80003674:	6a42                	ld	s4,16(sp)
    80003676:	6aa2                	ld	s5,8(sp)
    80003678:	6b02                	ld	s6,0(sp)
    8000367a:	6121                	addi	sp,sp,64
    8000367c:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    8000367e:	04000613          	li	a2,64
    80003682:	4581                	li	a1,0
    80003684:	854e                	mv	a0,s3
    80003686:	ffffd097          	auipc	ra,0xffffd
    8000368a:	6be080e7          	jalr	1726(ra) # 80000d44 <memset>
      dip->type = type;
    8000368e:	01699023          	sh	s6,0(s3)
      log_write(bp);   // mark it allocated on the disk
    80003692:	8526                	mv	a0,s1
    80003694:	00001097          	auipc	ra,0x1
    80003698:	c66080e7          	jalr	-922(ra) # 800042fa <log_write>
      brelse(bp);
    8000369c:	8526                	mv	a0,s1
    8000369e:	00000097          	auipc	ra,0x0
    800036a2:	a04080e7          	jalr	-1532(ra) # 800030a2 <brelse>
      return iget(dev, inum);
    800036a6:	0009059b          	sext.w	a1,s2
    800036aa:	8556                	mv	a0,s5
    800036ac:	00000097          	auipc	ra,0x0
    800036b0:	da2080e7          	jalr	-606(ra) # 8000344e <iget>
    800036b4:	bf5d                	j	8000366a <ialloc+0x80>

00000000800036b6 <iupdate>:
{
    800036b6:	1101                	addi	sp,sp,-32
    800036b8:	ec06                	sd	ra,24(sp)
    800036ba:	e822                	sd	s0,16(sp)
    800036bc:	e426                	sd	s1,8(sp)
    800036be:	e04a                	sd	s2,0(sp)
    800036c0:	1000                	addi	s0,sp,32
    800036c2:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    800036c4:	415c                	lw	a5,4(a0)
    800036c6:	0047d79b          	srliw	a5,a5,0x4
    800036ca:	0001c597          	auipc	a1,0x1c
    800036ce:	cb65a583          	lw	a1,-842(a1) # 8001f380 <sb+0x18>
    800036d2:	9dbd                	addw	a1,a1,a5
    800036d4:	4108                	lw	a0,0(a0)
    800036d6:	00000097          	auipc	ra,0x0
    800036da:	89c080e7          	jalr	-1892(ra) # 80002f72 <bread>
    800036de:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    800036e0:	05850793          	addi	a5,a0,88
    800036e4:	40d8                	lw	a4,4(s1)
    800036e6:	8b3d                	andi	a4,a4,15
    800036e8:	071a                	slli	a4,a4,0x6
    800036ea:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    800036ec:	04449703          	lh	a4,68(s1)
    800036f0:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    800036f4:	04649703          	lh	a4,70(s1)
    800036f8:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    800036fc:	04849703          	lh	a4,72(s1)
    80003700:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    80003704:	04a49703          	lh	a4,74(s1)
    80003708:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    8000370c:	44f8                	lw	a4,76(s1)
    8000370e:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80003710:	03400613          	li	a2,52
    80003714:	05048593          	addi	a1,s1,80
    80003718:	00c78513          	addi	a0,a5,12
    8000371c:	ffffd097          	auipc	ra,0xffffd
    80003720:	684080e7          	jalr	1668(ra) # 80000da0 <memmove>
  log_write(bp);
    80003724:	854a                	mv	a0,s2
    80003726:	00001097          	auipc	ra,0x1
    8000372a:	bd4080e7          	jalr	-1068(ra) # 800042fa <log_write>
  brelse(bp);
    8000372e:	854a                	mv	a0,s2
    80003730:	00000097          	auipc	ra,0x0
    80003734:	972080e7          	jalr	-1678(ra) # 800030a2 <brelse>
}
    80003738:	60e2                	ld	ra,24(sp)
    8000373a:	6442                	ld	s0,16(sp)
    8000373c:	64a2                	ld	s1,8(sp)
    8000373e:	6902                	ld	s2,0(sp)
    80003740:	6105                	addi	sp,sp,32
    80003742:	8082                	ret

0000000080003744 <idup>:
{
    80003744:	1101                	addi	sp,sp,-32
    80003746:	ec06                	sd	ra,24(sp)
    80003748:	e822                	sd	s0,16(sp)
    8000374a:	e426                	sd	s1,8(sp)
    8000374c:	1000                	addi	s0,sp,32
    8000374e:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003750:	0001c517          	auipc	a0,0x1c
    80003754:	c3850513          	addi	a0,a0,-968 # 8001f388 <itable>
    80003758:	ffffd097          	auipc	ra,0xffffd
    8000375c:	4f0080e7          	jalr	1264(ra) # 80000c48 <acquire>
  ip->ref++;
    80003760:	449c                	lw	a5,8(s1)
    80003762:	2785                	addiw	a5,a5,1
    80003764:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003766:	0001c517          	auipc	a0,0x1c
    8000376a:	c2250513          	addi	a0,a0,-990 # 8001f388 <itable>
    8000376e:	ffffd097          	auipc	ra,0xffffd
    80003772:	58e080e7          	jalr	1422(ra) # 80000cfc <release>
}
    80003776:	8526                	mv	a0,s1
    80003778:	60e2                	ld	ra,24(sp)
    8000377a:	6442                	ld	s0,16(sp)
    8000377c:	64a2                	ld	s1,8(sp)
    8000377e:	6105                	addi	sp,sp,32
    80003780:	8082                	ret

0000000080003782 <ilock>:
{
    80003782:	1101                	addi	sp,sp,-32
    80003784:	ec06                	sd	ra,24(sp)
    80003786:	e822                	sd	s0,16(sp)
    80003788:	e426                	sd	s1,8(sp)
    8000378a:	e04a                	sd	s2,0(sp)
    8000378c:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    8000378e:	c115                	beqz	a0,800037b2 <ilock+0x30>
    80003790:	84aa                	mv	s1,a0
    80003792:	451c                	lw	a5,8(a0)
    80003794:	00f05f63          	blez	a5,800037b2 <ilock+0x30>
  acquiresleep(&ip->lock);
    80003798:	0541                	addi	a0,a0,16
    8000379a:	00001097          	auipc	ra,0x1
    8000379e:	c7e080e7          	jalr	-898(ra) # 80004418 <acquiresleep>
  if(ip->valid == 0){
    800037a2:	40bc                	lw	a5,64(s1)
    800037a4:	cf99                	beqz	a5,800037c2 <ilock+0x40>
}
    800037a6:	60e2                	ld	ra,24(sp)
    800037a8:	6442                	ld	s0,16(sp)
    800037aa:	64a2                	ld	s1,8(sp)
    800037ac:	6902                	ld	s2,0(sp)
    800037ae:	6105                	addi	sp,sp,32
    800037b0:	8082                	ret
    panic("ilock");
    800037b2:	00005517          	auipc	a0,0x5
    800037b6:	e3650513          	addi	a0,a0,-458 # 800085e8 <syscalls+0x180>
    800037ba:	ffffd097          	auipc	ra,0xffffd
    800037be:	d86080e7          	jalr	-634(ra) # 80000540 <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    800037c2:	40dc                	lw	a5,4(s1)
    800037c4:	0047d79b          	srliw	a5,a5,0x4
    800037c8:	0001c597          	auipc	a1,0x1c
    800037cc:	bb85a583          	lw	a1,-1096(a1) # 8001f380 <sb+0x18>
    800037d0:	9dbd                	addw	a1,a1,a5
    800037d2:	4088                	lw	a0,0(s1)
    800037d4:	fffff097          	auipc	ra,0xfffff
    800037d8:	79e080e7          	jalr	1950(ra) # 80002f72 <bread>
    800037dc:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    800037de:	05850593          	addi	a1,a0,88
    800037e2:	40dc                	lw	a5,4(s1)
    800037e4:	8bbd                	andi	a5,a5,15
    800037e6:	079a                	slli	a5,a5,0x6
    800037e8:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    800037ea:	00059783          	lh	a5,0(a1)
    800037ee:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    800037f2:	00259783          	lh	a5,2(a1)
    800037f6:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    800037fa:	00459783          	lh	a5,4(a1)
    800037fe:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80003802:	00659783          	lh	a5,6(a1)
    80003806:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    8000380a:	459c                	lw	a5,8(a1)
    8000380c:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    8000380e:	03400613          	li	a2,52
    80003812:	05b1                	addi	a1,a1,12
    80003814:	05048513          	addi	a0,s1,80
    80003818:	ffffd097          	auipc	ra,0xffffd
    8000381c:	588080e7          	jalr	1416(ra) # 80000da0 <memmove>
    brelse(bp);
    80003820:	854a                	mv	a0,s2
    80003822:	00000097          	auipc	ra,0x0
    80003826:	880080e7          	jalr	-1920(ra) # 800030a2 <brelse>
    ip->valid = 1;
    8000382a:	4785                	li	a5,1
    8000382c:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    8000382e:	04449783          	lh	a5,68(s1)
    80003832:	fbb5                	bnez	a5,800037a6 <ilock+0x24>
      panic("ilock: no type");
    80003834:	00005517          	auipc	a0,0x5
    80003838:	dbc50513          	addi	a0,a0,-580 # 800085f0 <syscalls+0x188>
    8000383c:	ffffd097          	auipc	ra,0xffffd
    80003840:	d04080e7          	jalr	-764(ra) # 80000540 <panic>

0000000080003844 <iunlock>:
{
    80003844:	1101                	addi	sp,sp,-32
    80003846:	ec06                	sd	ra,24(sp)
    80003848:	e822                	sd	s0,16(sp)
    8000384a:	e426                	sd	s1,8(sp)
    8000384c:	e04a                	sd	s2,0(sp)
    8000384e:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80003850:	c905                	beqz	a0,80003880 <iunlock+0x3c>
    80003852:	84aa                	mv	s1,a0
    80003854:	01050913          	addi	s2,a0,16
    80003858:	854a                	mv	a0,s2
    8000385a:	00001097          	auipc	ra,0x1
    8000385e:	c58080e7          	jalr	-936(ra) # 800044b2 <holdingsleep>
    80003862:	cd19                	beqz	a0,80003880 <iunlock+0x3c>
    80003864:	449c                	lw	a5,8(s1)
    80003866:	00f05d63          	blez	a5,80003880 <iunlock+0x3c>
  releasesleep(&ip->lock);
    8000386a:	854a                	mv	a0,s2
    8000386c:	00001097          	auipc	ra,0x1
    80003870:	c02080e7          	jalr	-1022(ra) # 8000446e <releasesleep>
}
    80003874:	60e2                	ld	ra,24(sp)
    80003876:	6442                	ld	s0,16(sp)
    80003878:	64a2                	ld	s1,8(sp)
    8000387a:	6902                	ld	s2,0(sp)
    8000387c:	6105                	addi	sp,sp,32
    8000387e:	8082                	ret
    panic("iunlock");
    80003880:	00005517          	auipc	a0,0x5
    80003884:	d8050513          	addi	a0,a0,-640 # 80008600 <syscalls+0x198>
    80003888:	ffffd097          	auipc	ra,0xffffd
    8000388c:	cb8080e7          	jalr	-840(ra) # 80000540 <panic>

0000000080003890 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80003890:	7179                	addi	sp,sp,-48
    80003892:	f406                	sd	ra,40(sp)
    80003894:	f022                	sd	s0,32(sp)
    80003896:	ec26                	sd	s1,24(sp)
    80003898:	e84a                	sd	s2,16(sp)
    8000389a:	e44e                	sd	s3,8(sp)
    8000389c:	e052                	sd	s4,0(sp)
    8000389e:	1800                	addi	s0,sp,48
    800038a0:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    800038a2:	05050493          	addi	s1,a0,80
    800038a6:	08050913          	addi	s2,a0,128
    800038aa:	a021                	j	800038b2 <itrunc+0x22>
    800038ac:	0491                	addi	s1,s1,4
    800038ae:	01248d63          	beq	s1,s2,800038c8 <itrunc+0x38>
    if(ip->addrs[i]){
    800038b2:	408c                	lw	a1,0(s1)
    800038b4:	dde5                	beqz	a1,800038ac <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    800038b6:	0009a503          	lw	a0,0(s3)
    800038ba:	00000097          	auipc	ra,0x0
    800038be:	8fc080e7          	jalr	-1796(ra) # 800031b6 <bfree>
      ip->addrs[i] = 0;
    800038c2:	0004a023          	sw	zero,0(s1)
    800038c6:	b7dd                	j	800038ac <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    800038c8:	0809a583          	lw	a1,128(s3)
    800038cc:	e185                	bnez	a1,800038ec <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    800038ce:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    800038d2:	854e                	mv	a0,s3
    800038d4:	00000097          	auipc	ra,0x0
    800038d8:	de2080e7          	jalr	-542(ra) # 800036b6 <iupdate>
}
    800038dc:	70a2                	ld	ra,40(sp)
    800038de:	7402                	ld	s0,32(sp)
    800038e0:	64e2                	ld	s1,24(sp)
    800038e2:	6942                	ld	s2,16(sp)
    800038e4:	69a2                	ld	s3,8(sp)
    800038e6:	6a02                	ld	s4,0(sp)
    800038e8:	6145                	addi	sp,sp,48
    800038ea:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    800038ec:	0009a503          	lw	a0,0(s3)
    800038f0:	fffff097          	auipc	ra,0xfffff
    800038f4:	682080e7          	jalr	1666(ra) # 80002f72 <bread>
    800038f8:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    800038fa:	05850493          	addi	s1,a0,88
    800038fe:	45850913          	addi	s2,a0,1112
    80003902:	a021                	j	8000390a <itrunc+0x7a>
    80003904:	0491                	addi	s1,s1,4
    80003906:	01248b63          	beq	s1,s2,8000391c <itrunc+0x8c>
      if(a[j])
    8000390a:	408c                	lw	a1,0(s1)
    8000390c:	dde5                	beqz	a1,80003904 <itrunc+0x74>
        bfree(ip->dev, a[j]);
    8000390e:	0009a503          	lw	a0,0(s3)
    80003912:	00000097          	auipc	ra,0x0
    80003916:	8a4080e7          	jalr	-1884(ra) # 800031b6 <bfree>
    8000391a:	b7ed                	j	80003904 <itrunc+0x74>
    brelse(bp);
    8000391c:	8552                	mv	a0,s4
    8000391e:	fffff097          	auipc	ra,0xfffff
    80003922:	784080e7          	jalr	1924(ra) # 800030a2 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003926:	0809a583          	lw	a1,128(s3)
    8000392a:	0009a503          	lw	a0,0(s3)
    8000392e:	00000097          	auipc	ra,0x0
    80003932:	888080e7          	jalr	-1912(ra) # 800031b6 <bfree>
    ip->addrs[NDIRECT] = 0;
    80003936:	0809a023          	sw	zero,128(s3)
    8000393a:	bf51                	j	800038ce <itrunc+0x3e>

000000008000393c <iput>:
{
    8000393c:	1101                	addi	sp,sp,-32
    8000393e:	ec06                	sd	ra,24(sp)
    80003940:	e822                	sd	s0,16(sp)
    80003942:	e426                	sd	s1,8(sp)
    80003944:	e04a                	sd	s2,0(sp)
    80003946:	1000                	addi	s0,sp,32
    80003948:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    8000394a:	0001c517          	auipc	a0,0x1c
    8000394e:	a3e50513          	addi	a0,a0,-1474 # 8001f388 <itable>
    80003952:	ffffd097          	auipc	ra,0xffffd
    80003956:	2f6080e7          	jalr	758(ra) # 80000c48 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    8000395a:	4498                	lw	a4,8(s1)
    8000395c:	4785                	li	a5,1
    8000395e:	02f70363          	beq	a4,a5,80003984 <iput+0x48>
  ip->ref--;
    80003962:	449c                	lw	a5,8(s1)
    80003964:	37fd                	addiw	a5,a5,-1
    80003966:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003968:	0001c517          	auipc	a0,0x1c
    8000396c:	a2050513          	addi	a0,a0,-1504 # 8001f388 <itable>
    80003970:	ffffd097          	auipc	ra,0xffffd
    80003974:	38c080e7          	jalr	908(ra) # 80000cfc <release>
}
    80003978:	60e2                	ld	ra,24(sp)
    8000397a:	6442                	ld	s0,16(sp)
    8000397c:	64a2                	ld	s1,8(sp)
    8000397e:	6902                	ld	s2,0(sp)
    80003980:	6105                	addi	sp,sp,32
    80003982:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003984:	40bc                	lw	a5,64(s1)
    80003986:	dff1                	beqz	a5,80003962 <iput+0x26>
    80003988:	04a49783          	lh	a5,74(s1)
    8000398c:	fbf9                	bnez	a5,80003962 <iput+0x26>
    acquiresleep(&ip->lock);
    8000398e:	01048913          	addi	s2,s1,16
    80003992:	854a                	mv	a0,s2
    80003994:	00001097          	auipc	ra,0x1
    80003998:	a84080e7          	jalr	-1404(ra) # 80004418 <acquiresleep>
    release(&itable.lock);
    8000399c:	0001c517          	auipc	a0,0x1c
    800039a0:	9ec50513          	addi	a0,a0,-1556 # 8001f388 <itable>
    800039a4:	ffffd097          	auipc	ra,0xffffd
    800039a8:	358080e7          	jalr	856(ra) # 80000cfc <release>
    itrunc(ip);
    800039ac:	8526                	mv	a0,s1
    800039ae:	00000097          	auipc	ra,0x0
    800039b2:	ee2080e7          	jalr	-286(ra) # 80003890 <itrunc>
    ip->type = 0;
    800039b6:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    800039ba:	8526                	mv	a0,s1
    800039bc:	00000097          	auipc	ra,0x0
    800039c0:	cfa080e7          	jalr	-774(ra) # 800036b6 <iupdate>
    ip->valid = 0;
    800039c4:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    800039c8:	854a                	mv	a0,s2
    800039ca:	00001097          	auipc	ra,0x1
    800039ce:	aa4080e7          	jalr	-1372(ra) # 8000446e <releasesleep>
    acquire(&itable.lock);
    800039d2:	0001c517          	auipc	a0,0x1c
    800039d6:	9b650513          	addi	a0,a0,-1610 # 8001f388 <itable>
    800039da:	ffffd097          	auipc	ra,0xffffd
    800039de:	26e080e7          	jalr	622(ra) # 80000c48 <acquire>
    800039e2:	b741                	j	80003962 <iput+0x26>

00000000800039e4 <iunlockput>:
{
    800039e4:	1101                	addi	sp,sp,-32
    800039e6:	ec06                	sd	ra,24(sp)
    800039e8:	e822                	sd	s0,16(sp)
    800039ea:	e426                	sd	s1,8(sp)
    800039ec:	1000                	addi	s0,sp,32
    800039ee:	84aa                	mv	s1,a0
  iunlock(ip);
    800039f0:	00000097          	auipc	ra,0x0
    800039f4:	e54080e7          	jalr	-428(ra) # 80003844 <iunlock>
  iput(ip);
    800039f8:	8526                	mv	a0,s1
    800039fa:	00000097          	auipc	ra,0x0
    800039fe:	f42080e7          	jalr	-190(ra) # 8000393c <iput>
}
    80003a02:	60e2                	ld	ra,24(sp)
    80003a04:	6442                	ld	s0,16(sp)
    80003a06:	64a2                	ld	s1,8(sp)
    80003a08:	6105                	addi	sp,sp,32
    80003a0a:	8082                	ret

0000000080003a0c <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003a0c:	1141                	addi	sp,sp,-16
    80003a0e:	e422                	sd	s0,8(sp)
    80003a10:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80003a12:	411c                	lw	a5,0(a0)
    80003a14:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003a16:	415c                	lw	a5,4(a0)
    80003a18:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003a1a:	04451783          	lh	a5,68(a0)
    80003a1e:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003a22:	04a51783          	lh	a5,74(a0)
    80003a26:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003a2a:	04c56783          	lwu	a5,76(a0)
    80003a2e:	e99c                	sd	a5,16(a1)
}
    80003a30:	6422                	ld	s0,8(sp)
    80003a32:	0141                	addi	sp,sp,16
    80003a34:	8082                	ret

0000000080003a36 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003a36:	457c                	lw	a5,76(a0)
    80003a38:	0ed7e963          	bltu	a5,a3,80003b2a <readi+0xf4>
{
    80003a3c:	7159                	addi	sp,sp,-112
    80003a3e:	f486                	sd	ra,104(sp)
    80003a40:	f0a2                	sd	s0,96(sp)
    80003a42:	eca6                	sd	s1,88(sp)
    80003a44:	e8ca                	sd	s2,80(sp)
    80003a46:	e4ce                	sd	s3,72(sp)
    80003a48:	e0d2                	sd	s4,64(sp)
    80003a4a:	fc56                	sd	s5,56(sp)
    80003a4c:	f85a                	sd	s6,48(sp)
    80003a4e:	f45e                	sd	s7,40(sp)
    80003a50:	f062                	sd	s8,32(sp)
    80003a52:	ec66                	sd	s9,24(sp)
    80003a54:	e86a                	sd	s10,16(sp)
    80003a56:	e46e                	sd	s11,8(sp)
    80003a58:	1880                	addi	s0,sp,112
    80003a5a:	8b2a                	mv	s6,a0
    80003a5c:	8bae                	mv	s7,a1
    80003a5e:	8a32                	mv	s4,a2
    80003a60:	84b6                	mv	s1,a3
    80003a62:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    80003a64:	9f35                	addw	a4,a4,a3
    return 0;
    80003a66:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80003a68:	0ad76063          	bltu	a4,a3,80003b08 <readi+0xd2>
  if(off + n > ip->size)
    80003a6c:	00e7f463          	bgeu	a5,a4,80003a74 <readi+0x3e>
    n = ip->size - off;
    80003a70:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003a74:	0a0a8963          	beqz	s5,80003b26 <readi+0xf0>
    80003a78:	4981                	li	s3,0
#if 0
    // Adil: Remove later
    printf("ip->dev; %d\n", ip->dev);
#endif

    m = min(n - tot, BSIZE - off%BSIZE);
    80003a7a:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003a7e:	5c7d                	li	s8,-1
    80003a80:	a82d                	j	80003aba <readi+0x84>
    80003a82:	020d1d93          	slli	s11,s10,0x20
    80003a86:	020ddd93          	srli	s11,s11,0x20
    80003a8a:	05890613          	addi	a2,s2,88
    80003a8e:	86ee                	mv	a3,s11
    80003a90:	963a                	add	a2,a2,a4
    80003a92:	85d2                	mv	a1,s4
    80003a94:	855e                	mv	a0,s7
    80003a96:	fffff097          	auipc	ra,0xfffff
    80003a9a:	a6c080e7          	jalr	-1428(ra) # 80002502 <either_copyout>
    80003a9e:	05850d63          	beq	a0,s8,80003af8 <readi+0xc2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80003aa2:	854a                	mv	a0,s2
    80003aa4:	fffff097          	auipc	ra,0xfffff
    80003aa8:	5fe080e7          	jalr	1534(ra) # 800030a2 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003aac:	013d09bb          	addw	s3,s10,s3
    80003ab0:	009d04bb          	addw	s1,s10,s1
    80003ab4:	9a6e                	add	s4,s4,s11
    80003ab6:	0559f763          	bgeu	s3,s5,80003b04 <readi+0xce>
    uint addr = bmap(ip, off/BSIZE);
    80003aba:	00a4d59b          	srliw	a1,s1,0xa
    80003abe:	855a                	mv	a0,s6
    80003ac0:	00000097          	auipc	ra,0x0
    80003ac4:	8a4080e7          	jalr	-1884(ra) # 80003364 <bmap>
    80003ac8:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80003acc:	cd85                	beqz	a1,80003b04 <readi+0xce>
    bp = bread(ip->dev, addr);
    80003ace:	000b2503          	lw	a0,0(s6)
    80003ad2:	fffff097          	auipc	ra,0xfffff
    80003ad6:	4a0080e7          	jalr	1184(ra) # 80002f72 <bread>
    80003ada:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003adc:	3ff4f713          	andi	a4,s1,1023
    80003ae0:	40ec87bb          	subw	a5,s9,a4
    80003ae4:	413a86bb          	subw	a3,s5,s3
    80003ae8:	8d3e                	mv	s10,a5
    80003aea:	2781                	sext.w	a5,a5
    80003aec:	0006861b          	sext.w	a2,a3
    80003af0:	f8f679e3          	bgeu	a2,a5,80003a82 <readi+0x4c>
    80003af4:	8d36                	mv	s10,a3
    80003af6:	b771                	j	80003a82 <readi+0x4c>
      brelse(bp);
    80003af8:	854a                	mv	a0,s2
    80003afa:	fffff097          	auipc	ra,0xfffff
    80003afe:	5a8080e7          	jalr	1448(ra) # 800030a2 <brelse>
      tot = -1;
    80003b02:	59fd                	li	s3,-1
  }
  return tot;
    80003b04:	0009851b          	sext.w	a0,s3
}
    80003b08:	70a6                	ld	ra,104(sp)
    80003b0a:	7406                	ld	s0,96(sp)
    80003b0c:	64e6                	ld	s1,88(sp)
    80003b0e:	6946                	ld	s2,80(sp)
    80003b10:	69a6                	ld	s3,72(sp)
    80003b12:	6a06                	ld	s4,64(sp)
    80003b14:	7ae2                	ld	s5,56(sp)
    80003b16:	7b42                	ld	s6,48(sp)
    80003b18:	7ba2                	ld	s7,40(sp)
    80003b1a:	7c02                	ld	s8,32(sp)
    80003b1c:	6ce2                	ld	s9,24(sp)
    80003b1e:	6d42                	ld	s10,16(sp)
    80003b20:	6da2                	ld	s11,8(sp)
    80003b22:	6165                	addi	sp,sp,112
    80003b24:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003b26:	89d6                	mv	s3,s5
    80003b28:	bff1                	j	80003b04 <readi+0xce>
    return 0;
    80003b2a:	4501                	li	a0,0
}
    80003b2c:	8082                	ret

0000000080003b2e <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003b2e:	457c                	lw	a5,76(a0)
    80003b30:	10d7e863          	bltu	a5,a3,80003c40 <writei+0x112>
{
    80003b34:	7159                	addi	sp,sp,-112
    80003b36:	f486                	sd	ra,104(sp)
    80003b38:	f0a2                	sd	s0,96(sp)
    80003b3a:	eca6                	sd	s1,88(sp)
    80003b3c:	e8ca                	sd	s2,80(sp)
    80003b3e:	e4ce                	sd	s3,72(sp)
    80003b40:	e0d2                	sd	s4,64(sp)
    80003b42:	fc56                	sd	s5,56(sp)
    80003b44:	f85a                	sd	s6,48(sp)
    80003b46:	f45e                	sd	s7,40(sp)
    80003b48:	f062                	sd	s8,32(sp)
    80003b4a:	ec66                	sd	s9,24(sp)
    80003b4c:	e86a                	sd	s10,16(sp)
    80003b4e:	e46e                	sd	s11,8(sp)
    80003b50:	1880                	addi	s0,sp,112
    80003b52:	8aaa                	mv	s5,a0
    80003b54:	8bae                	mv	s7,a1
    80003b56:	8a32                	mv	s4,a2
    80003b58:	8936                	mv	s2,a3
    80003b5a:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003b5c:	00e687bb          	addw	a5,a3,a4
    80003b60:	0ed7e263          	bltu	a5,a3,80003c44 <writei+0x116>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80003b64:	00043737          	lui	a4,0x43
    80003b68:	0ef76063          	bltu	a4,a5,80003c48 <writei+0x11a>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003b6c:	0c0b0863          	beqz	s6,80003c3c <writei+0x10e>
    80003b70:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003b72:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003b76:	5c7d                	li	s8,-1
    80003b78:	a091                	j	80003bbc <writei+0x8e>
    80003b7a:	020d1d93          	slli	s11,s10,0x20
    80003b7e:	020ddd93          	srli	s11,s11,0x20
    80003b82:	05848513          	addi	a0,s1,88
    80003b86:	86ee                	mv	a3,s11
    80003b88:	8652                	mv	a2,s4
    80003b8a:	85de                	mv	a1,s7
    80003b8c:	953a                	add	a0,a0,a4
    80003b8e:	fffff097          	auipc	ra,0xfffff
    80003b92:	9ca080e7          	jalr	-1590(ra) # 80002558 <either_copyin>
    80003b96:	07850263          	beq	a0,s8,80003bfa <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    80003b9a:	8526                	mv	a0,s1
    80003b9c:	00000097          	auipc	ra,0x0
    80003ba0:	75e080e7          	jalr	1886(ra) # 800042fa <log_write>
    brelse(bp);
    80003ba4:	8526                	mv	a0,s1
    80003ba6:	fffff097          	auipc	ra,0xfffff
    80003baa:	4fc080e7          	jalr	1276(ra) # 800030a2 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003bae:	013d09bb          	addw	s3,s10,s3
    80003bb2:	012d093b          	addw	s2,s10,s2
    80003bb6:	9a6e                	add	s4,s4,s11
    80003bb8:	0569f663          	bgeu	s3,s6,80003c04 <writei+0xd6>
    uint addr = bmap(ip, off/BSIZE);
    80003bbc:	00a9559b          	srliw	a1,s2,0xa
    80003bc0:	8556                	mv	a0,s5
    80003bc2:	fffff097          	auipc	ra,0xfffff
    80003bc6:	7a2080e7          	jalr	1954(ra) # 80003364 <bmap>
    80003bca:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80003bce:	c99d                	beqz	a1,80003c04 <writei+0xd6>
    bp = bread(ip->dev, addr);
    80003bd0:	000aa503          	lw	a0,0(s5)
    80003bd4:	fffff097          	auipc	ra,0xfffff
    80003bd8:	39e080e7          	jalr	926(ra) # 80002f72 <bread>
    80003bdc:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003bde:	3ff97713          	andi	a4,s2,1023
    80003be2:	40ec87bb          	subw	a5,s9,a4
    80003be6:	413b06bb          	subw	a3,s6,s3
    80003bea:	8d3e                	mv	s10,a5
    80003bec:	2781                	sext.w	a5,a5
    80003bee:	0006861b          	sext.w	a2,a3
    80003bf2:	f8f674e3          	bgeu	a2,a5,80003b7a <writei+0x4c>
    80003bf6:	8d36                	mv	s10,a3
    80003bf8:	b749                	j	80003b7a <writei+0x4c>
      brelse(bp);
    80003bfa:	8526                	mv	a0,s1
    80003bfc:	fffff097          	auipc	ra,0xfffff
    80003c00:	4a6080e7          	jalr	1190(ra) # 800030a2 <brelse>
  }

  if(off > ip->size)
    80003c04:	04caa783          	lw	a5,76(s5)
    80003c08:	0127f463          	bgeu	a5,s2,80003c10 <writei+0xe2>
    ip->size = off;
    80003c0c:	052aa623          	sw	s2,76(s5)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80003c10:	8556                	mv	a0,s5
    80003c12:	00000097          	auipc	ra,0x0
    80003c16:	aa4080e7          	jalr	-1372(ra) # 800036b6 <iupdate>

  return tot;
    80003c1a:	0009851b          	sext.w	a0,s3
}
    80003c1e:	70a6                	ld	ra,104(sp)
    80003c20:	7406                	ld	s0,96(sp)
    80003c22:	64e6                	ld	s1,88(sp)
    80003c24:	6946                	ld	s2,80(sp)
    80003c26:	69a6                	ld	s3,72(sp)
    80003c28:	6a06                	ld	s4,64(sp)
    80003c2a:	7ae2                	ld	s5,56(sp)
    80003c2c:	7b42                	ld	s6,48(sp)
    80003c2e:	7ba2                	ld	s7,40(sp)
    80003c30:	7c02                	ld	s8,32(sp)
    80003c32:	6ce2                	ld	s9,24(sp)
    80003c34:	6d42                	ld	s10,16(sp)
    80003c36:	6da2                	ld	s11,8(sp)
    80003c38:	6165                	addi	sp,sp,112
    80003c3a:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003c3c:	89da                	mv	s3,s6
    80003c3e:	bfc9                	j	80003c10 <writei+0xe2>
    return -1;
    80003c40:	557d                	li	a0,-1
}
    80003c42:	8082                	ret
    return -1;
    80003c44:	557d                	li	a0,-1
    80003c46:	bfe1                	j	80003c1e <writei+0xf0>
    return -1;
    80003c48:	557d                	li	a0,-1
    80003c4a:	bfd1                	j	80003c1e <writei+0xf0>

0000000080003c4c <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80003c4c:	1141                	addi	sp,sp,-16
    80003c4e:	e406                	sd	ra,8(sp)
    80003c50:	e022                	sd	s0,0(sp)
    80003c52:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80003c54:	4639                	li	a2,14
    80003c56:	ffffd097          	auipc	ra,0xffffd
    80003c5a:	1be080e7          	jalr	446(ra) # 80000e14 <strncmp>
}
    80003c5e:	60a2                	ld	ra,8(sp)
    80003c60:	6402                	ld	s0,0(sp)
    80003c62:	0141                	addi	sp,sp,16
    80003c64:	8082                	ret

0000000080003c66 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003c66:	7139                	addi	sp,sp,-64
    80003c68:	fc06                	sd	ra,56(sp)
    80003c6a:	f822                	sd	s0,48(sp)
    80003c6c:	f426                	sd	s1,40(sp)
    80003c6e:	f04a                	sd	s2,32(sp)
    80003c70:	ec4e                	sd	s3,24(sp)
    80003c72:	e852                	sd	s4,16(sp)
    80003c74:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80003c76:	04451703          	lh	a4,68(a0)
    80003c7a:	4785                	li	a5,1
    80003c7c:	00f71a63          	bne	a4,a5,80003c90 <dirlookup+0x2a>
    80003c80:	892a                	mv	s2,a0
    80003c82:	89ae                	mv	s3,a1
    80003c84:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80003c86:	457c                	lw	a5,76(a0)
    80003c88:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80003c8a:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003c8c:	e79d                	bnez	a5,80003cba <dirlookup+0x54>
    80003c8e:	a8a5                	j	80003d06 <dirlookup+0xa0>
    panic("dirlookup not DIR");
    80003c90:	00005517          	auipc	a0,0x5
    80003c94:	97850513          	addi	a0,a0,-1672 # 80008608 <syscalls+0x1a0>
    80003c98:	ffffd097          	auipc	ra,0xffffd
    80003c9c:	8a8080e7          	jalr	-1880(ra) # 80000540 <panic>
      panic("dirlookup read");
    80003ca0:	00005517          	auipc	a0,0x5
    80003ca4:	98050513          	addi	a0,a0,-1664 # 80008620 <syscalls+0x1b8>
    80003ca8:	ffffd097          	auipc	ra,0xffffd
    80003cac:	898080e7          	jalr	-1896(ra) # 80000540 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003cb0:	24c1                	addiw	s1,s1,16
    80003cb2:	04c92783          	lw	a5,76(s2)
    80003cb6:	04f4f763          	bgeu	s1,a5,80003d04 <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003cba:	4741                	li	a4,16
    80003cbc:	86a6                	mv	a3,s1
    80003cbe:	fc040613          	addi	a2,s0,-64
    80003cc2:	4581                	li	a1,0
    80003cc4:	854a                	mv	a0,s2
    80003cc6:	00000097          	auipc	ra,0x0
    80003cca:	d70080e7          	jalr	-656(ra) # 80003a36 <readi>
    80003cce:	47c1                	li	a5,16
    80003cd0:	fcf518e3          	bne	a0,a5,80003ca0 <dirlookup+0x3a>
    if(de.inum == 0)
    80003cd4:	fc045783          	lhu	a5,-64(s0)
    80003cd8:	dfe1                	beqz	a5,80003cb0 <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    80003cda:	fc240593          	addi	a1,s0,-62
    80003cde:	854e                	mv	a0,s3
    80003ce0:	00000097          	auipc	ra,0x0
    80003ce4:	f6c080e7          	jalr	-148(ra) # 80003c4c <namecmp>
    80003ce8:	f561                	bnez	a0,80003cb0 <dirlookup+0x4a>
      if(poff)
    80003cea:	000a0463          	beqz	s4,80003cf2 <dirlookup+0x8c>
        *poff = off;
    80003cee:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80003cf2:	fc045583          	lhu	a1,-64(s0)
    80003cf6:	00092503          	lw	a0,0(s2)
    80003cfa:	fffff097          	auipc	ra,0xfffff
    80003cfe:	754080e7          	jalr	1876(ra) # 8000344e <iget>
    80003d02:	a011                	j	80003d06 <dirlookup+0xa0>
  return 0;
    80003d04:	4501                	li	a0,0
}
    80003d06:	70e2                	ld	ra,56(sp)
    80003d08:	7442                	ld	s0,48(sp)
    80003d0a:	74a2                	ld	s1,40(sp)
    80003d0c:	7902                	ld	s2,32(sp)
    80003d0e:	69e2                	ld	s3,24(sp)
    80003d10:	6a42                	ld	s4,16(sp)
    80003d12:	6121                	addi	sp,sp,64
    80003d14:	8082                	ret

0000000080003d16 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80003d16:	711d                	addi	sp,sp,-96
    80003d18:	ec86                	sd	ra,88(sp)
    80003d1a:	e8a2                	sd	s0,80(sp)
    80003d1c:	e4a6                	sd	s1,72(sp)
    80003d1e:	e0ca                	sd	s2,64(sp)
    80003d20:	fc4e                	sd	s3,56(sp)
    80003d22:	f852                	sd	s4,48(sp)
    80003d24:	f456                	sd	s5,40(sp)
    80003d26:	f05a                	sd	s6,32(sp)
    80003d28:	ec5e                	sd	s7,24(sp)
    80003d2a:	e862                	sd	s8,16(sp)
    80003d2c:	e466                	sd	s9,8(sp)
    80003d2e:	1080                	addi	s0,sp,96
    80003d30:	84aa                	mv	s1,a0
    80003d32:	8b2e                	mv	s6,a1
    80003d34:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    80003d36:	00054703          	lbu	a4,0(a0)
    80003d3a:	02f00793          	li	a5,47
    80003d3e:	02f70263          	beq	a4,a5,80003d62 <namex+0x4c>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80003d42:	ffffe097          	auipc	ra,0xffffe
    80003d46:	ce2080e7          	jalr	-798(ra) # 80001a24 <myproc>
    80003d4a:	15053503          	ld	a0,336(a0)
    80003d4e:	00000097          	auipc	ra,0x0
    80003d52:	9f6080e7          	jalr	-1546(ra) # 80003744 <idup>
    80003d56:	8a2a                	mv	s4,a0
  while(*path == '/')
    80003d58:	02f00913          	li	s2,47
  if(len >= DIRSIZ)
    80003d5c:	4c35                	li	s8,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80003d5e:	4b85                	li	s7,1
    80003d60:	a875                	j	80003e1c <namex+0x106>
    ip = iget(ROOTDEV, ROOTINO);
    80003d62:	4585                	li	a1,1
    80003d64:	4505                	li	a0,1
    80003d66:	fffff097          	auipc	ra,0xfffff
    80003d6a:	6e8080e7          	jalr	1768(ra) # 8000344e <iget>
    80003d6e:	8a2a                	mv	s4,a0
    80003d70:	b7e5                	j	80003d58 <namex+0x42>
      iunlockput(ip);
    80003d72:	8552                	mv	a0,s4
    80003d74:	00000097          	auipc	ra,0x0
    80003d78:	c70080e7          	jalr	-912(ra) # 800039e4 <iunlockput>
      return 0;
    80003d7c:	4a01                	li	s4,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80003d7e:	8552                	mv	a0,s4
    80003d80:	60e6                	ld	ra,88(sp)
    80003d82:	6446                	ld	s0,80(sp)
    80003d84:	64a6                	ld	s1,72(sp)
    80003d86:	6906                	ld	s2,64(sp)
    80003d88:	79e2                	ld	s3,56(sp)
    80003d8a:	7a42                	ld	s4,48(sp)
    80003d8c:	7aa2                	ld	s5,40(sp)
    80003d8e:	7b02                	ld	s6,32(sp)
    80003d90:	6be2                	ld	s7,24(sp)
    80003d92:	6c42                	ld	s8,16(sp)
    80003d94:	6ca2                	ld	s9,8(sp)
    80003d96:	6125                	addi	sp,sp,96
    80003d98:	8082                	ret
      iunlock(ip);
    80003d9a:	8552                	mv	a0,s4
    80003d9c:	00000097          	auipc	ra,0x0
    80003da0:	aa8080e7          	jalr	-1368(ra) # 80003844 <iunlock>
      return ip;
    80003da4:	bfe9                	j	80003d7e <namex+0x68>
      iunlockput(ip);
    80003da6:	8552                	mv	a0,s4
    80003da8:	00000097          	auipc	ra,0x0
    80003dac:	c3c080e7          	jalr	-964(ra) # 800039e4 <iunlockput>
      return 0;
    80003db0:	8a4e                	mv	s4,s3
    80003db2:	b7f1                	j	80003d7e <namex+0x68>
  len = path - s;
    80003db4:	40998633          	sub	a2,s3,s1
    80003db8:	00060c9b          	sext.w	s9,a2
  if(len >= DIRSIZ)
    80003dbc:	099c5863          	bge	s8,s9,80003e4c <namex+0x136>
    memmove(name, s, DIRSIZ);
    80003dc0:	4639                	li	a2,14
    80003dc2:	85a6                	mv	a1,s1
    80003dc4:	8556                	mv	a0,s5
    80003dc6:	ffffd097          	auipc	ra,0xffffd
    80003dca:	fda080e7          	jalr	-38(ra) # 80000da0 <memmove>
    80003dce:	84ce                	mv	s1,s3
  while(*path == '/')
    80003dd0:	0004c783          	lbu	a5,0(s1)
    80003dd4:	01279763          	bne	a5,s2,80003de2 <namex+0xcc>
    path++;
    80003dd8:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003dda:	0004c783          	lbu	a5,0(s1)
    80003dde:	ff278de3          	beq	a5,s2,80003dd8 <namex+0xc2>
    ilock(ip);
    80003de2:	8552                	mv	a0,s4
    80003de4:	00000097          	auipc	ra,0x0
    80003de8:	99e080e7          	jalr	-1634(ra) # 80003782 <ilock>
    if(ip->type != T_DIR){
    80003dec:	044a1783          	lh	a5,68(s4)
    80003df0:	f97791e3          	bne	a5,s7,80003d72 <namex+0x5c>
    if(nameiparent && *path == '\0'){
    80003df4:	000b0563          	beqz	s6,80003dfe <namex+0xe8>
    80003df8:	0004c783          	lbu	a5,0(s1)
    80003dfc:	dfd9                	beqz	a5,80003d9a <namex+0x84>
    if((next = dirlookup(ip, name, 0)) == 0){
    80003dfe:	4601                	li	a2,0
    80003e00:	85d6                	mv	a1,s5
    80003e02:	8552                	mv	a0,s4
    80003e04:	00000097          	auipc	ra,0x0
    80003e08:	e62080e7          	jalr	-414(ra) # 80003c66 <dirlookup>
    80003e0c:	89aa                	mv	s3,a0
    80003e0e:	dd41                	beqz	a0,80003da6 <namex+0x90>
    iunlockput(ip);
    80003e10:	8552                	mv	a0,s4
    80003e12:	00000097          	auipc	ra,0x0
    80003e16:	bd2080e7          	jalr	-1070(ra) # 800039e4 <iunlockput>
    ip = next;
    80003e1a:	8a4e                	mv	s4,s3
  while(*path == '/')
    80003e1c:	0004c783          	lbu	a5,0(s1)
    80003e20:	01279763          	bne	a5,s2,80003e2e <namex+0x118>
    path++;
    80003e24:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003e26:	0004c783          	lbu	a5,0(s1)
    80003e2a:	ff278de3          	beq	a5,s2,80003e24 <namex+0x10e>
  if(*path == 0)
    80003e2e:	cb9d                	beqz	a5,80003e64 <namex+0x14e>
  while(*path != '/' && *path != 0)
    80003e30:	0004c783          	lbu	a5,0(s1)
    80003e34:	89a6                	mv	s3,s1
  len = path - s;
    80003e36:	4c81                	li	s9,0
    80003e38:	4601                	li	a2,0
  while(*path != '/' && *path != 0)
    80003e3a:	01278963          	beq	a5,s2,80003e4c <namex+0x136>
    80003e3e:	dbbd                	beqz	a5,80003db4 <namex+0x9e>
    path++;
    80003e40:	0985                	addi	s3,s3,1
  while(*path != '/' && *path != 0)
    80003e42:	0009c783          	lbu	a5,0(s3)
    80003e46:	ff279ce3          	bne	a5,s2,80003e3e <namex+0x128>
    80003e4a:	b7ad                	j	80003db4 <namex+0x9e>
    memmove(name, s, len);
    80003e4c:	2601                	sext.w	a2,a2
    80003e4e:	85a6                	mv	a1,s1
    80003e50:	8556                	mv	a0,s5
    80003e52:	ffffd097          	auipc	ra,0xffffd
    80003e56:	f4e080e7          	jalr	-178(ra) # 80000da0 <memmove>
    name[len] = 0;
    80003e5a:	9cd6                	add	s9,s9,s5
    80003e5c:	000c8023          	sb	zero,0(s9) # 2000 <_entry-0x7fffe000>
    80003e60:	84ce                	mv	s1,s3
    80003e62:	b7bd                	j	80003dd0 <namex+0xba>
  if(nameiparent){
    80003e64:	f00b0de3          	beqz	s6,80003d7e <namex+0x68>
    iput(ip);
    80003e68:	8552                	mv	a0,s4
    80003e6a:	00000097          	auipc	ra,0x0
    80003e6e:	ad2080e7          	jalr	-1326(ra) # 8000393c <iput>
    return 0;
    80003e72:	4a01                	li	s4,0
    80003e74:	b729                	j	80003d7e <namex+0x68>

0000000080003e76 <dirlink>:
{
    80003e76:	7139                	addi	sp,sp,-64
    80003e78:	fc06                	sd	ra,56(sp)
    80003e7a:	f822                	sd	s0,48(sp)
    80003e7c:	f426                	sd	s1,40(sp)
    80003e7e:	f04a                	sd	s2,32(sp)
    80003e80:	ec4e                	sd	s3,24(sp)
    80003e82:	e852                	sd	s4,16(sp)
    80003e84:	0080                	addi	s0,sp,64
    80003e86:	892a                	mv	s2,a0
    80003e88:	8a2e                	mv	s4,a1
    80003e8a:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80003e8c:	4601                	li	a2,0
    80003e8e:	00000097          	auipc	ra,0x0
    80003e92:	dd8080e7          	jalr	-552(ra) # 80003c66 <dirlookup>
    80003e96:	e93d                	bnez	a0,80003f0c <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003e98:	04c92483          	lw	s1,76(s2)
    80003e9c:	c49d                	beqz	s1,80003eca <dirlink+0x54>
    80003e9e:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003ea0:	4741                	li	a4,16
    80003ea2:	86a6                	mv	a3,s1
    80003ea4:	fc040613          	addi	a2,s0,-64
    80003ea8:	4581                	li	a1,0
    80003eaa:	854a                	mv	a0,s2
    80003eac:	00000097          	auipc	ra,0x0
    80003eb0:	b8a080e7          	jalr	-1142(ra) # 80003a36 <readi>
    80003eb4:	47c1                	li	a5,16
    80003eb6:	06f51163          	bne	a0,a5,80003f18 <dirlink+0xa2>
    if(de.inum == 0)
    80003eba:	fc045783          	lhu	a5,-64(s0)
    80003ebe:	c791                	beqz	a5,80003eca <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003ec0:	24c1                	addiw	s1,s1,16
    80003ec2:	04c92783          	lw	a5,76(s2)
    80003ec6:	fcf4ede3          	bltu	s1,a5,80003ea0 <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    80003eca:	4639                	li	a2,14
    80003ecc:	85d2                	mv	a1,s4
    80003ece:	fc240513          	addi	a0,s0,-62
    80003ed2:	ffffd097          	auipc	ra,0xffffd
    80003ed6:	f7e080e7          	jalr	-130(ra) # 80000e50 <strncpy>
  de.inum = inum;
    80003eda:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003ede:	4741                	li	a4,16
    80003ee0:	86a6                	mv	a3,s1
    80003ee2:	fc040613          	addi	a2,s0,-64
    80003ee6:	4581                	li	a1,0
    80003ee8:	854a                	mv	a0,s2
    80003eea:	00000097          	auipc	ra,0x0
    80003eee:	c44080e7          	jalr	-956(ra) # 80003b2e <writei>
    80003ef2:	1541                	addi	a0,a0,-16
    80003ef4:	00a03533          	snez	a0,a0
    80003ef8:	40a00533          	neg	a0,a0
}
    80003efc:	70e2                	ld	ra,56(sp)
    80003efe:	7442                	ld	s0,48(sp)
    80003f00:	74a2                	ld	s1,40(sp)
    80003f02:	7902                	ld	s2,32(sp)
    80003f04:	69e2                	ld	s3,24(sp)
    80003f06:	6a42                	ld	s4,16(sp)
    80003f08:	6121                	addi	sp,sp,64
    80003f0a:	8082                	ret
    iput(ip);
    80003f0c:	00000097          	auipc	ra,0x0
    80003f10:	a30080e7          	jalr	-1488(ra) # 8000393c <iput>
    return -1;
    80003f14:	557d                	li	a0,-1
    80003f16:	b7dd                	j	80003efc <dirlink+0x86>
      panic("dirlink read");
    80003f18:	00004517          	auipc	a0,0x4
    80003f1c:	71850513          	addi	a0,a0,1816 # 80008630 <syscalls+0x1c8>
    80003f20:	ffffc097          	auipc	ra,0xffffc
    80003f24:	620080e7          	jalr	1568(ra) # 80000540 <panic>

0000000080003f28 <namei>:

struct inode*
namei(char *path)
{
    80003f28:	1101                	addi	sp,sp,-32
    80003f2a:	ec06                	sd	ra,24(sp)
    80003f2c:	e822                	sd	s0,16(sp)
    80003f2e:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80003f30:	fe040613          	addi	a2,s0,-32
    80003f34:	4581                	li	a1,0
    80003f36:	00000097          	auipc	ra,0x0
    80003f3a:	de0080e7          	jalr	-544(ra) # 80003d16 <namex>
}
    80003f3e:	60e2                	ld	ra,24(sp)
    80003f40:	6442                	ld	s0,16(sp)
    80003f42:	6105                	addi	sp,sp,32
    80003f44:	8082                	ret

0000000080003f46 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80003f46:	1141                	addi	sp,sp,-16
    80003f48:	e406                	sd	ra,8(sp)
    80003f4a:	e022                	sd	s0,0(sp)
    80003f4c:	0800                	addi	s0,sp,16
    80003f4e:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80003f50:	4585                	li	a1,1
    80003f52:	00000097          	auipc	ra,0x0
    80003f56:	dc4080e7          	jalr	-572(ra) # 80003d16 <namex>
}
    80003f5a:	60a2                	ld	ra,8(sp)
    80003f5c:	6402                	ld	s0,0(sp)
    80003f5e:	0141                	addi	sp,sp,16
    80003f60:	8082                	ret

0000000080003f62 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80003f62:	1101                	addi	sp,sp,-32
    80003f64:	ec06                	sd	ra,24(sp)
    80003f66:	e822                	sd	s0,16(sp)
    80003f68:	e426                	sd	s1,8(sp)
    80003f6a:	e04a                	sd	s2,0(sp)
    80003f6c:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80003f6e:	0001d917          	auipc	s2,0x1d
    80003f72:	ec290913          	addi	s2,s2,-318 # 80020e30 <log>
    80003f76:	01892583          	lw	a1,24(s2)
    80003f7a:	02892503          	lw	a0,40(s2)
    80003f7e:	fffff097          	auipc	ra,0xfffff
    80003f82:	ff4080e7          	jalr	-12(ra) # 80002f72 <bread>
    80003f86:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80003f88:	02c92603          	lw	a2,44(s2)
    80003f8c:	cd30                	sw	a2,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80003f8e:	00c05f63          	blez	a2,80003fac <write_head+0x4a>
    80003f92:	0001d717          	auipc	a4,0x1d
    80003f96:	ece70713          	addi	a4,a4,-306 # 80020e60 <log+0x30>
    80003f9a:	87aa                	mv	a5,a0
    80003f9c:	060a                	slli	a2,a2,0x2
    80003f9e:	962a                	add	a2,a2,a0
    hb->block[i] = log.lh.block[i];
    80003fa0:	4314                	lw	a3,0(a4)
    80003fa2:	cff4                	sw	a3,92(a5)
  for (i = 0; i < log.lh.n; i++) {
    80003fa4:	0711                	addi	a4,a4,4
    80003fa6:	0791                	addi	a5,a5,4
    80003fa8:	fec79ce3          	bne	a5,a2,80003fa0 <write_head+0x3e>
  }
  bwrite(buf);
    80003fac:	8526                	mv	a0,s1
    80003fae:	fffff097          	auipc	ra,0xfffff
    80003fb2:	0b6080e7          	jalr	182(ra) # 80003064 <bwrite>
  brelse(buf);
    80003fb6:	8526                	mv	a0,s1
    80003fb8:	fffff097          	auipc	ra,0xfffff
    80003fbc:	0ea080e7          	jalr	234(ra) # 800030a2 <brelse>
}
    80003fc0:	60e2                	ld	ra,24(sp)
    80003fc2:	6442                	ld	s0,16(sp)
    80003fc4:	64a2                	ld	s1,8(sp)
    80003fc6:	6902                	ld	s2,0(sp)
    80003fc8:	6105                	addi	sp,sp,32
    80003fca:	8082                	ret

0000000080003fcc <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80003fcc:	0001d797          	auipc	a5,0x1d
    80003fd0:	e907a783          	lw	a5,-368(a5) # 80020e5c <log+0x2c>
    80003fd4:	0af05d63          	blez	a5,8000408e <install_trans+0xc2>
{
    80003fd8:	7139                	addi	sp,sp,-64
    80003fda:	fc06                	sd	ra,56(sp)
    80003fdc:	f822                	sd	s0,48(sp)
    80003fde:	f426                	sd	s1,40(sp)
    80003fe0:	f04a                	sd	s2,32(sp)
    80003fe2:	ec4e                	sd	s3,24(sp)
    80003fe4:	e852                	sd	s4,16(sp)
    80003fe6:	e456                	sd	s5,8(sp)
    80003fe8:	e05a                	sd	s6,0(sp)
    80003fea:	0080                	addi	s0,sp,64
    80003fec:	8b2a                	mv	s6,a0
    80003fee:	0001da97          	auipc	s5,0x1d
    80003ff2:	e72a8a93          	addi	s5,s5,-398 # 80020e60 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003ff6:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003ff8:	0001d997          	auipc	s3,0x1d
    80003ffc:	e3898993          	addi	s3,s3,-456 # 80020e30 <log>
    80004000:	a00d                	j	80004022 <install_trans+0x56>
    brelse(lbuf);
    80004002:	854a                	mv	a0,s2
    80004004:	fffff097          	auipc	ra,0xfffff
    80004008:	09e080e7          	jalr	158(ra) # 800030a2 <brelse>
    brelse(dbuf);
    8000400c:	8526                	mv	a0,s1
    8000400e:	fffff097          	auipc	ra,0xfffff
    80004012:	094080e7          	jalr	148(ra) # 800030a2 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004016:	2a05                	addiw	s4,s4,1
    80004018:	0a91                	addi	s5,s5,4
    8000401a:	02c9a783          	lw	a5,44(s3)
    8000401e:	04fa5e63          	bge	s4,a5,8000407a <install_trans+0xae>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80004022:	0189a583          	lw	a1,24(s3)
    80004026:	014585bb          	addw	a1,a1,s4
    8000402a:	2585                	addiw	a1,a1,1
    8000402c:	0289a503          	lw	a0,40(s3)
    80004030:	fffff097          	auipc	ra,0xfffff
    80004034:	f42080e7          	jalr	-190(ra) # 80002f72 <bread>
    80004038:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    8000403a:	000aa583          	lw	a1,0(s5)
    8000403e:	0289a503          	lw	a0,40(s3)
    80004042:	fffff097          	auipc	ra,0xfffff
    80004046:	f30080e7          	jalr	-208(ra) # 80002f72 <bread>
    8000404a:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    8000404c:	40000613          	li	a2,1024
    80004050:	05890593          	addi	a1,s2,88
    80004054:	05850513          	addi	a0,a0,88
    80004058:	ffffd097          	auipc	ra,0xffffd
    8000405c:	d48080e7          	jalr	-696(ra) # 80000da0 <memmove>
    bwrite(dbuf);  // write dst to disk
    80004060:	8526                	mv	a0,s1
    80004062:	fffff097          	auipc	ra,0xfffff
    80004066:	002080e7          	jalr	2(ra) # 80003064 <bwrite>
    if(recovering == 0)
    8000406a:	f80b1ce3          	bnez	s6,80004002 <install_trans+0x36>
      bunpin(dbuf);
    8000406e:	8526                	mv	a0,s1
    80004070:	fffff097          	auipc	ra,0xfffff
    80004074:	10a080e7          	jalr	266(ra) # 8000317a <bunpin>
    80004078:	b769                	j	80004002 <install_trans+0x36>
}
    8000407a:	70e2                	ld	ra,56(sp)
    8000407c:	7442                	ld	s0,48(sp)
    8000407e:	74a2                	ld	s1,40(sp)
    80004080:	7902                	ld	s2,32(sp)
    80004082:	69e2                	ld	s3,24(sp)
    80004084:	6a42                	ld	s4,16(sp)
    80004086:	6aa2                	ld	s5,8(sp)
    80004088:	6b02                	ld	s6,0(sp)
    8000408a:	6121                	addi	sp,sp,64
    8000408c:	8082                	ret
    8000408e:	8082                	ret

0000000080004090 <initlog>:
{
    80004090:	7179                	addi	sp,sp,-48
    80004092:	f406                	sd	ra,40(sp)
    80004094:	f022                	sd	s0,32(sp)
    80004096:	ec26                	sd	s1,24(sp)
    80004098:	e84a                	sd	s2,16(sp)
    8000409a:	e44e                	sd	s3,8(sp)
    8000409c:	1800                	addi	s0,sp,48
    8000409e:	892a                	mv	s2,a0
    800040a0:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    800040a2:	0001d497          	auipc	s1,0x1d
    800040a6:	d8e48493          	addi	s1,s1,-626 # 80020e30 <log>
    800040aa:	00004597          	auipc	a1,0x4
    800040ae:	59658593          	addi	a1,a1,1430 # 80008640 <syscalls+0x1d8>
    800040b2:	8526                	mv	a0,s1
    800040b4:	ffffd097          	auipc	ra,0xffffd
    800040b8:	b04080e7          	jalr	-1276(ra) # 80000bb8 <initlock>
  log.start = sb->logstart;
    800040bc:	0149a583          	lw	a1,20(s3)
    800040c0:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    800040c2:	0109a783          	lw	a5,16(s3)
    800040c6:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    800040c8:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    800040cc:	854a                	mv	a0,s2
    800040ce:	fffff097          	auipc	ra,0xfffff
    800040d2:	ea4080e7          	jalr	-348(ra) # 80002f72 <bread>
  log.lh.n = lh->n;
    800040d6:	4d30                	lw	a2,88(a0)
    800040d8:	d4d0                	sw	a2,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    800040da:	00c05f63          	blez	a2,800040f8 <initlog+0x68>
    800040de:	87aa                	mv	a5,a0
    800040e0:	0001d717          	auipc	a4,0x1d
    800040e4:	d8070713          	addi	a4,a4,-640 # 80020e60 <log+0x30>
    800040e8:	060a                	slli	a2,a2,0x2
    800040ea:	962a                	add	a2,a2,a0
    log.lh.block[i] = lh->block[i];
    800040ec:	4ff4                	lw	a3,92(a5)
    800040ee:	c314                	sw	a3,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    800040f0:	0791                	addi	a5,a5,4
    800040f2:	0711                	addi	a4,a4,4
    800040f4:	fec79ce3          	bne	a5,a2,800040ec <initlog+0x5c>
  brelse(buf);
    800040f8:	fffff097          	auipc	ra,0xfffff
    800040fc:	faa080e7          	jalr	-86(ra) # 800030a2 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80004100:	4505                	li	a0,1
    80004102:	00000097          	auipc	ra,0x0
    80004106:	eca080e7          	jalr	-310(ra) # 80003fcc <install_trans>
  log.lh.n = 0;
    8000410a:	0001d797          	auipc	a5,0x1d
    8000410e:	d407a923          	sw	zero,-686(a5) # 80020e5c <log+0x2c>
  write_head(); // clear the log
    80004112:	00000097          	auipc	ra,0x0
    80004116:	e50080e7          	jalr	-432(ra) # 80003f62 <write_head>
}
    8000411a:	70a2                	ld	ra,40(sp)
    8000411c:	7402                	ld	s0,32(sp)
    8000411e:	64e2                	ld	s1,24(sp)
    80004120:	6942                	ld	s2,16(sp)
    80004122:	69a2                	ld	s3,8(sp)
    80004124:	6145                	addi	sp,sp,48
    80004126:	8082                	ret

0000000080004128 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80004128:	1101                	addi	sp,sp,-32
    8000412a:	ec06                	sd	ra,24(sp)
    8000412c:	e822                	sd	s0,16(sp)
    8000412e:	e426                	sd	s1,8(sp)
    80004130:	e04a                	sd	s2,0(sp)
    80004132:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80004134:	0001d517          	auipc	a0,0x1d
    80004138:	cfc50513          	addi	a0,a0,-772 # 80020e30 <log>
    8000413c:	ffffd097          	auipc	ra,0xffffd
    80004140:	b0c080e7          	jalr	-1268(ra) # 80000c48 <acquire>
  while(1){
    if(log.committing){
    80004144:	0001d497          	auipc	s1,0x1d
    80004148:	cec48493          	addi	s1,s1,-788 # 80020e30 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    8000414c:	4979                	li	s2,30
    8000414e:	a039                	j	8000415c <begin_op+0x34>
      sleep(&log, &log.lock);
    80004150:	85a6                	mv	a1,s1
    80004152:	8526                	mv	a0,s1
    80004154:	ffffe097          	auipc	ra,0xffffe
    80004158:	fa6080e7          	jalr	-90(ra) # 800020fa <sleep>
    if(log.committing){
    8000415c:	50dc                	lw	a5,36(s1)
    8000415e:	fbed                	bnez	a5,80004150 <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80004160:	5098                	lw	a4,32(s1)
    80004162:	2705                	addiw	a4,a4,1
    80004164:	0027179b          	slliw	a5,a4,0x2
    80004168:	9fb9                	addw	a5,a5,a4
    8000416a:	0017979b          	slliw	a5,a5,0x1
    8000416e:	54d4                	lw	a3,44(s1)
    80004170:	9fb5                	addw	a5,a5,a3
    80004172:	00f95963          	bge	s2,a5,80004184 <begin_op+0x5c>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    80004176:	85a6                	mv	a1,s1
    80004178:	8526                	mv	a0,s1
    8000417a:	ffffe097          	auipc	ra,0xffffe
    8000417e:	f80080e7          	jalr	-128(ra) # 800020fa <sleep>
    80004182:	bfe9                	j	8000415c <begin_op+0x34>
    } else {
      log.outstanding += 1;
    80004184:	0001d517          	auipc	a0,0x1d
    80004188:	cac50513          	addi	a0,a0,-852 # 80020e30 <log>
    8000418c:	d118                	sw	a4,32(a0)
      release(&log.lock);
    8000418e:	ffffd097          	auipc	ra,0xffffd
    80004192:	b6e080e7          	jalr	-1170(ra) # 80000cfc <release>
      break;
    }
  }
}
    80004196:	60e2                	ld	ra,24(sp)
    80004198:	6442                	ld	s0,16(sp)
    8000419a:	64a2                	ld	s1,8(sp)
    8000419c:	6902                	ld	s2,0(sp)
    8000419e:	6105                	addi	sp,sp,32
    800041a0:	8082                	ret

00000000800041a2 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    800041a2:	7139                	addi	sp,sp,-64
    800041a4:	fc06                	sd	ra,56(sp)
    800041a6:	f822                	sd	s0,48(sp)
    800041a8:	f426                	sd	s1,40(sp)
    800041aa:	f04a                	sd	s2,32(sp)
    800041ac:	ec4e                	sd	s3,24(sp)
    800041ae:	e852                	sd	s4,16(sp)
    800041b0:	e456                	sd	s5,8(sp)
    800041b2:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    800041b4:	0001d497          	auipc	s1,0x1d
    800041b8:	c7c48493          	addi	s1,s1,-900 # 80020e30 <log>
    800041bc:	8526                	mv	a0,s1
    800041be:	ffffd097          	auipc	ra,0xffffd
    800041c2:	a8a080e7          	jalr	-1398(ra) # 80000c48 <acquire>
  log.outstanding -= 1;
    800041c6:	509c                	lw	a5,32(s1)
    800041c8:	37fd                	addiw	a5,a5,-1
    800041ca:	0007891b          	sext.w	s2,a5
    800041ce:	d09c                	sw	a5,32(s1)
  if(log.committing)
    800041d0:	50dc                	lw	a5,36(s1)
    800041d2:	e7b9                	bnez	a5,80004220 <end_op+0x7e>
    panic("log.committing");
  if(log.outstanding == 0){
    800041d4:	04091e63          	bnez	s2,80004230 <end_op+0x8e>
    do_commit = 1;
    log.committing = 1;
    800041d8:	0001d497          	auipc	s1,0x1d
    800041dc:	c5848493          	addi	s1,s1,-936 # 80020e30 <log>
    800041e0:	4785                	li	a5,1
    800041e2:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    800041e4:	8526                	mv	a0,s1
    800041e6:	ffffd097          	auipc	ra,0xffffd
    800041ea:	b16080e7          	jalr	-1258(ra) # 80000cfc <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    800041ee:	54dc                	lw	a5,44(s1)
    800041f0:	06f04763          	bgtz	a5,8000425e <end_op+0xbc>
    acquire(&log.lock);
    800041f4:	0001d497          	auipc	s1,0x1d
    800041f8:	c3c48493          	addi	s1,s1,-964 # 80020e30 <log>
    800041fc:	8526                	mv	a0,s1
    800041fe:	ffffd097          	auipc	ra,0xffffd
    80004202:	a4a080e7          	jalr	-1462(ra) # 80000c48 <acquire>
    log.committing = 0;
    80004206:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    8000420a:	8526                	mv	a0,s1
    8000420c:	ffffe097          	auipc	ra,0xffffe
    80004210:	f52080e7          	jalr	-174(ra) # 8000215e <wakeup>
    release(&log.lock);
    80004214:	8526                	mv	a0,s1
    80004216:	ffffd097          	auipc	ra,0xffffd
    8000421a:	ae6080e7          	jalr	-1306(ra) # 80000cfc <release>
}
    8000421e:	a03d                	j	8000424c <end_op+0xaa>
    panic("log.committing");
    80004220:	00004517          	auipc	a0,0x4
    80004224:	42850513          	addi	a0,a0,1064 # 80008648 <syscalls+0x1e0>
    80004228:	ffffc097          	auipc	ra,0xffffc
    8000422c:	318080e7          	jalr	792(ra) # 80000540 <panic>
    wakeup(&log);
    80004230:	0001d497          	auipc	s1,0x1d
    80004234:	c0048493          	addi	s1,s1,-1024 # 80020e30 <log>
    80004238:	8526                	mv	a0,s1
    8000423a:	ffffe097          	auipc	ra,0xffffe
    8000423e:	f24080e7          	jalr	-220(ra) # 8000215e <wakeup>
  release(&log.lock);
    80004242:	8526                	mv	a0,s1
    80004244:	ffffd097          	auipc	ra,0xffffd
    80004248:	ab8080e7          	jalr	-1352(ra) # 80000cfc <release>
}
    8000424c:	70e2                	ld	ra,56(sp)
    8000424e:	7442                	ld	s0,48(sp)
    80004250:	74a2                	ld	s1,40(sp)
    80004252:	7902                	ld	s2,32(sp)
    80004254:	69e2                	ld	s3,24(sp)
    80004256:	6a42                	ld	s4,16(sp)
    80004258:	6aa2                	ld	s5,8(sp)
    8000425a:	6121                	addi	sp,sp,64
    8000425c:	8082                	ret
  for (tail = 0; tail < log.lh.n; tail++) {
    8000425e:	0001da97          	auipc	s5,0x1d
    80004262:	c02a8a93          	addi	s5,s5,-1022 # 80020e60 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    80004266:	0001da17          	auipc	s4,0x1d
    8000426a:	bcaa0a13          	addi	s4,s4,-1078 # 80020e30 <log>
    8000426e:	018a2583          	lw	a1,24(s4)
    80004272:	012585bb          	addw	a1,a1,s2
    80004276:	2585                	addiw	a1,a1,1
    80004278:	028a2503          	lw	a0,40(s4)
    8000427c:	fffff097          	auipc	ra,0xfffff
    80004280:	cf6080e7          	jalr	-778(ra) # 80002f72 <bread>
    80004284:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80004286:	000aa583          	lw	a1,0(s5)
    8000428a:	028a2503          	lw	a0,40(s4)
    8000428e:	fffff097          	auipc	ra,0xfffff
    80004292:	ce4080e7          	jalr	-796(ra) # 80002f72 <bread>
    80004296:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80004298:	40000613          	li	a2,1024
    8000429c:	05850593          	addi	a1,a0,88
    800042a0:	05848513          	addi	a0,s1,88
    800042a4:	ffffd097          	auipc	ra,0xffffd
    800042a8:	afc080e7          	jalr	-1284(ra) # 80000da0 <memmove>
    bwrite(to);  // write the log
    800042ac:	8526                	mv	a0,s1
    800042ae:	fffff097          	auipc	ra,0xfffff
    800042b2:	db6080e7          	jalr	-586(ra) # 80003064 <bwrite>
    brelse(from);
    800042b6:	854e                	mv	a0,s3
    800042b8:	fffff097          	auipc	ra,0xfffff
    800042bc:	dea080e7          	jalr	-534(ra) # 800030a2 <brelse>
    brelse(to);
    800042c0:	8526                	mv	a0,s1
    800042c2:	fffff097          	auipc	ra,0xfffff
    800042c6:	de0080e7          	jalr	-544(ra) # 800030a2 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    800042ca:	2905                	addiw	s2,s2,1
    800042cc:	0a91                	addi	s5,s5,4
    800042ce:	02ca2783          	lw	a5,44(s4)
    800042d2:	f8f94ee3          	blt	s2,a5,8000426e <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    800042d6:	00000097          	auipc	ra,0x0
    800042da:	c8c080e7          	jalr	-884(ra) # 80003f62 <write_head>
    install_trans(0); // Now install writes to home locations
    800042de:	4501                	li	a0,0
    800042e0:	00000097          	auipc	ra,0x0
    800042e4:	cec080e7          	jalr	-788(ra) # 80003fcc <install_trans>
    log.lh.n = 0;
    800042e8:	0001d797          	auipc	a5,0x1d
    800042ec:	b607aa23          	sw	zero,-1164(a5) # 80020e5c <log+0x2c>
    write_head();    // Erase the transaction from the log
    800042f0:	00000097          	auipc	ra,0x0
    800042f4:	c72080e7          	jalr	-910(ra) # 80003f62 <write_head>
    800042f8:	bdf5                	j	800041f4 <end_op+0x52>

00000000800042fa <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    800042fa:	1101                	addi	sp,sp,-32
    800042fc:	ec06                	sd	ra,24(sp)
    800042fe:	e822                	sd	s0,16(sp)
    80004300:	e426                	sd	s1,8(sp)
    80004302:	e04a                	sd	s2,0(sp)
    80004304:	1000                	addi	s0,sp,32
    80004306:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    80004308:	0001d917          	auipc	s2,0x1d
    8000430c:	b2890913          	addi	s2,s2,-1240 # 80020e30 <log>
    80004310:	854a                	mv	a0,s2
    80004312:	ffffd097          	auipc	ra,0xffffd
    80004316:	936080e7          	jalr	-1738(ra) # 80000c48 <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    8000431a:	02c92603          	lw	a2,44(s2)
    8000431e:	47f5                	li	a5,29
    80004320:	06c7c563          	blt	a5,a2,8000438a <log_write+0x90>
    80004324:	0001d797          	auipc	a5,0x1d
    80004328:	b287a783          	lw	a5,-1240(a5) # 80020e4c <log+0x1c>
    8000432c:	37fd                	addiw	a5,a5,-1
    8000432e:	04f65e63          	bge	a2,a5,8000438a <log_write+0x90>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80004332:	0001d797          	auipc	a5,0x1d
    80004336:	b1e7a783          	lw	a5,-1250(a5) # 80020e50 <log+0x20>
    8000433a:	06f05063          	blez	a5,8000439a <log_write+0xa0>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    8000433e:	4781                	li	a5,0
    80004340:	06c05563          	blez	a2,800043aa <log_write+0xb0>
    if (log.lh.block[i] == b->blockno)   // log absorption
    80004344:	44cc                	lw	a1,12(s1)
    80004346:	0001d717          	auipc	a4,0x1d
    8000434a:	b1a70713          	addi	a4,a4,-1254 # 80020e60 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    8000434e:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    80004350:	4314                	lw	a3,0(a4)
    80004352:	04b68c63          	beq	a3,a1,800043aa <log_write+0xb0>
  for (i = 0; i < log.lh.n; i++) {
    80004356:	2785                	addiw	a5,a5,1
    80004358:	0711                	addi	a4,a4,4
    8000435a:	fef61be3          	bne	a2,a5,80004350 <log_write+0x56>
      break;
  }
  log.lh.block[i] = b->blockno;
    8000435e:	0621                	addi	a2,a2,8
    80004360:	060a                	slli	a2,a2,0x2
    80004362:	0001d797          	auipc	a5,0x1d
    80004366:	ace78793          	addi	a5,a5,-1330 # 80020e30 <log>
    8000436a:	97b2                	add	a5,a5,a2
    8000436c:	44d8                	lw	a4,12(s1)
    8000436e:	cb98                	sw	a4,16(a5)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    80004370:	8526                	mv	a0,s1
    80004372:	fffff097          	auipc	ra,0xfffff
    80004376:	dcc080e7          	jalr	-564(ra) # 8000313e <bpin>
    log.lh.n++;
    8000437a:	0001d717          	auipc	a4,0x1d
    8000437e:	ab670713          	addi	a4,a4,-1354 # 80020e30 <log>
    80004382:	575c                	lw	a5,44(a4)
    80004384:	2785                	addiw	a5,a5,1
    80004386:	d75c                	sw	a5,44(a4)
    80004388:	a82d                	j	800043c2 <log_write+0xc8>
    panic("too big a transaction");
    8000438a:	00004517          	auipc	a0,0x4
    8000438e:	2ce50513          	addi	a0,a0,718 # 80008658 <syscalls+0x1f0>
    80004392:	ffffc097          	auipc	ra,0xffffc
    80004396:	1ae080e7          	jalr	430(ra) # 80000540 <panic>
    panic("log_write outside of trans");
    8000439a:	00004517          	auipc	a0,0x4
    8000439e:	2d650513          	addi	a0,a0,726 # 80008670 <syscalls+0x208>
    800043a2:	ffffc097          	auipc	ra,0xffffc
    800043a6:	19e080e7          	jalr	414(ra) # 80000540 <panic>
  log.lh.block[i] = b->blockno;
    800043aa:	00878693          	addi	a3,a5,8
    800043ae:	068a                	slli	a3,a3,0x2
    800043b0:	0001d717          	auipc	a4,0x1d
    800043b4:	a8070713          	addi	a4,a4,-1408 # 80020e30 <log>
    800043b8:	9736                	add	a4,a4,a3
    800043ba:	44d4                	lw	a3,12(s1)
    800043bc:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    800043be:	faf609e3          	beq	a2,a5,80004370 <log_write+0x76>
  }
  release(&log.lock);
    800043c2:	0001d517          	auipc	a0,0x1d
    800043c6:	a6e50513          	addi	a0,a0,-1426 # 80020e30 <log>
    800043ca:	ffffd097          	auipc	ra,0xffffd
    800043ce:	932080e7          	jalr	-1742(ra) # 80000cfc <release>
}
    800043d2:	60e2                	ld	ra,24(sp)
    800043d4:	6442                	ld	s0,16(sp)
    800043d6:	64a2                	ld	s1,8(sp)
    800043d8:	6902                	ld	s2,0(sp)
    800043da:	6105                	addi	sp,sp,32
    800043dc:	8082                	ret

00000000800043de <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    800043de:	1101                	addi	sp,sp,-32
    800043e0:	ec06                	sd	ra,24(sp)
    800043e2:	e822                	sd	s0,16(sp)
    800043e4:	e426                	sd	s1,8(sp)
    800043e6:	e04a                	sd	s2,0(sp)
    800043e8:	1000                	addi	s0,sp,32
    800043ea:	84aa                	mv	s1,a0
    800043ec:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    800043ee:	00004597          	auipc	a1,0x4
    800043f2:	2a258593          	addi	a1,a1,674 # 80008690 <syscalls+0x228>
    800043f6:	0521                	addi	a0,a0,8
    800043f8:	ffffc097          	auipc	ra,0xffffc
    800043fc:	7c0080e7          	jalr	1984(ra) # 80000bb8 <initlock>
  lk->name = name;
    80004400:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80004404:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004408:	0204a423          	sw	zero,40(s1)
}
    8000440c:	60e2                	ld	ra,24(sp)
    8000440e:	6442                	ld	s0,16(sp)
    80004410:	64a2                	ld	s1,8(sp)
    80004412:	6902                	ld	s2,0(sp)
    80004414:	6105                	addi	sp,sp,32
    80004416:	8082                	ret

0000000080004418 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80004418:	1101                	addi	sp,sp,-32
    8000441a:	ec06                	sd	ra,24(sp)
    8000441c:	e822                	sd	s0,16(sp)
    8000441e:	e426                	sd	s1,8(sp)
    80004420:	e04a                	sd	s2,0(sp)
    80004422:	1000                	addi	s0,sp,32
    80004424:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004426:	00850913          	addi	s2,a0,8
    8000442a:	854a                	mv	a0,s2
    8000442c:	ffffd097          	auipc	ra,0xffffd
    80004430:	81c080e7          	jalr	-2020(ra) # 80000c48 <acquire>
  while (lk->locked) {
    80004434:	409c                	lw	a5,0(s1)
    80004436:	cb89                	beqz	a5,80004448 <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    80004438:	85ca                	mv	a1,s2
    8000443a:	8526                	mv	a0,s1
    8000443c:	ffffe097          	auipc	ra,0xffffe
    80004440:	cbe080e7          	jalr	-834(ra) # 800020fa <sleep>
  while (lk->locked) {
    80004444:	409c                	lw	a5,0(s1)
    80004446:	fbed                	bnez	a5,80004438 <acquiresleep+0x20>
  }
  lk->locked = 1;
    80004448:	4785                	li	a5,1
    8000444a:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    8000444c:	ffffd097          	auipc	ra,0xffffd
    80004450:	5d8080e7          	jalr	1496(ra) # 80001a24 <myproc>
    80004454:	591c                	lw	a5,48(a0)
    80004456:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    80004458:	854a                	mv	a0,s2
    8000445a:	ffffd097          	auipc	ra,0xffffd
    8000445e:	8a2080e7          	jalr	-1886(ra) # 80000cfc <release>
}
    80004462:	60e2                	ld	ra,24(sp)
    80004464:	6442                	ld	s0,16(sp)
    80004466:	64a2                	ld	s1,8(sp)
    80004468:	6902                	ld	s2,0(sp)
    8000446a:	6105                	addi	sp,sp,32
    8000446c:	8082                	ret

000000008000446e <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    8000446e:	1101                	addi	sp,sp,-32
    80004470:	ec06                	sd	ra,24(sp)
    80004472:	e822                	sd	s0,16(sp)
    80004474:	e426                	sd	s1,8(sp)
    80004476:	e04a                	sd	s2,0(sp)
    80004478:	1000                	addi	s0,sp,32
    8000447a:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    8000447c:	00850913          	addi	s2,a0,8
    80004480:	854a                	mv	a0,s2
    80004482:	ffffc097          	auipc	ra,0xffffc
    80004486:	7c6080e7          	jalr	1990(ra) # 80000c48 <acquire>
  lk->locked = 0;
    8000448a:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    8000448e:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80004492:	8526                	mv	a0,s1
    80004494:	ffffe097          	auipc	ra,0xffffe
    80004498:	cca080e7          	jalr	-822(ra) # 8000215e <wakeup>
  release(&lk->lk);
    8000449c:	854a                	mv	a0,s2
    8000449e:	ffffd097          	auipc	ra,0xffffd
    800044a2:	85e080e7          	jalr	-1954(ra) # 80000cfc <release>
}
    800044a6:	60e2                	ld	ra,24(sp)
    800044a8:	6442                	ld	s0,16(sp)
    800044aa:	64a2                	ld	s1,8(sp)
    800044ac:	6902                	ld	s2,0(sp)
    800044ae:	6105                	addi	sp,sp,32
    800044b0:	8082                	ret

00000000800044b2 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    800044b2:	7179                	addi	sp,sp,-48
    800044b4:	f406                	sd	ra,40(sp)
    800044b6:	f022                	sd	s0,32(sp)
    800044b8:	ec26                	sd	s1,24(sp)
    800044ba:	e84a                	sd	s2,16(sp)
    800044bc:	e44e                	sd	s3,8(sp)
    800044be:	1800                	addi	s0,sp,48
    800044c0:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    800044c2:	00850913          	addi	s2,a0,8
    800044c6:	854a                	mv	a0,s2
    800044c8:	ffffc097          	auipc	ra,0xffffc
    800044cc:	780080e7          	jalr	1920(ra) # 80000c48 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    800044d0:	409c                	lw	a5,0(s1)
    800044d2:	ef99                	bnez	a5,800044f0 <holdingsleep+0x3e>
    800044d4:	4481                	li	s1,0
  release(&lk->lk);
    800044d6:	854a                	mv	a0,s2
    800044d8:	ffffd097          	auipc	ra,0xffffd
    800044dc:	824080e7          	jalr	-2012(ra) # 80000cfc <release>
  return r;
}
    800044e0:	8526                	mv	a0,s1
    800044e2:	70a2                	ld	ra,40(sp)
    800044e4:	7402                	ld	s0,32(sp)
    800044e6:	64e2                	ld	s1,24(sp)
    800044e8:	6942                	ld	s2,16(sp)
    800044ea:	69a2                	ld	s3,8(sp)
    800044ec:	6145                	addi	sp,sp,48
    800044ee:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    800044f0:	0284a983          	lw	s3,40(s1)
    800044f4:	ffffd097          	auipc	ra,0xffffd
    800044f8:	530080e7          	jalr	1328(ra) # 80001a24 <myproc>
    800044fc:	5904                	lw	s1,48(a0)
    800044fe:	413484b3          	sub	s1,s1,s3
    80004502:	0014b493          	seqz	s1,s1
    80004506:	bfc1                	j	800044d6 <holdingsleep+0x24>

0000000080004508 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80004508:	1141                	addi	sp,sp,-16
    8000450a:	e406                	sd	ra,8(sp)
    8000450c:	e022                	sd	s0,0(sp)
    8000450e:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80004510:	00004597          	auipc	a1,0x4
    80004514:	19058593          	addi	a1,a1,400 # 800086a0 <syscalls+0x238>
    80004518:	0001d517          	auipc	a0,0x1d
    8000451c:	a6050513          	addi	a0,a0,-1440 # 80020f78 <ftable>
    80004520:	ffffc097          	auipc	ra,0xffffc
    80004524:	698080e7          	jalr	1688(ra) # 80000bb8 <initlock>
}
    80004528:	60a2                	ld	ra,8(sp)
    8000452a:	6402                	ld	s0,0(sp)
    8000452c:	0141                	addi	sp,sp,16
    8000452e:	8082                	ret

0000000080004530 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    80004530:	1101                	addi	sp,sp,-32
    80004532:	ec06                	sd	ra,24(sp)
    80004534:	e822                	sd	s0,16(sp)
    80004536:	e426                	sd	s1,8(sp)
    80004538:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    8000453a:	0001d517          	auipc	a0,0x1d
    8000453e:	a3e50513          	addi	a0,a0,-1474 # 80020f78 <ftable>
    80004542:	ffffc097          	auipc	ra,0xffffc
    80004546:	706080e7          	jalr	1798(ra) # 80000c48 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    8000454a:	0001d497          	auipc	s1,0x1d
    8000454e:	a4648493          	addi	s1,s1,-1466 # 80020f90 <ftable+0x18>
    80004552:	0001e717          	auipc	a4,0x1e
    80004556:	9de70713          	addi	a4,a4,-1570 # 80021f30 <disk>
    if(f->ref == 0){
    8000455a:	40dc                	lw	a5,4(s1)
    8000455c:	cf99                	beqz	a5,8000457a <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    8000455e:	02848493          	addi	s1,s1,40
    80004562:	fee49ce3          	bne	s1,a4,8000455a <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80004566:	0001d517          	auipc	a0,0x1d
    8000456a:	a1250513          	addi	a0,a0,-1518 # 80020f78 <ftable>
    8000456e:	ffffc097          	auipc	ra,0xffffc
    80004572:	78e080e7          	jalr	1934(ra) # 80000cfc <release>
  return 0;
    80004576:	4481                	li	s1,0
    80004578:	a819                	j	8000458e <filealloc+0x5e>
      f->ref = 1;
    8000457a:	4785                	li	a5,1
    8000457c:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    8000457e:	0001d517          	auipc	a0,0x1d
    80004582:	9fa50513          	addi	a0,a0,-1542 # 80020f78 <ftable>
    80004586:	ffffc097          	auipc	ra,0xffffc
    8000458a:	776080e7          	jalr	1910(ra) # 80000cfc <release>
}
    8000458e:	8526                	mv	a0,s1
    80004590:	60e2                	ld	ra,24(sp)
    80004592:	6442                	ld	s0,16(sp)
    80004594:	64a2                	ld	s1,8(sp)
    80004596:	6105                	addi	sp,sp,32
    80004598:	8082                	ret

000000008000459a <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    8000459a:	1101                	addi	sp,sp,-32
    8000459c:	ec06                	sd	ra,24(sp)
    8000459e:	e822                	sd	s0,16(sp)
    800045a0:	e426                	sd	s1,8(sp)
    800045a2:	1000                	addi	s0,sp,32
    800045a4:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    800045a6:	0001d517          	auipc	a0,0x1d
    800045aa:	9d250513          	addi	a0,a0,-1582 # 80020f78 <ftable>
    800045ae:	ffffc097          	auipc	ra,0xffffc
    800045b2:	69a080e7          	jalr	1690(ra) # 80000c48 <acquire>
  if(f->ref < 1)
    800045b6:	40dc                	lw	a5,4(s1)
    800045b8:	02f05263          	blez	a5,800045dc <filedup+0x42>
    panic("filedup");
  f->ref++;
    800045bc:	2785                	addiw	a5,a5,1
    800045be:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    800045c0:	0001d517          	auipc	a0,0x1d
    800045c4:	9b850513          	addi	a0,a0,-1608 # 80020f78 <ftable>
    800045c8:	ffffc097          	auipc	ra,0xffffc
    800045cc:	734080e7          	jalr	1844(ra) # 80000cfc <release>
  return f;
}
    800045d0:	8526                	mv	a0,s1
    800045d2:	60e2                	ld	ra,24(sp)
    800045d4:	6442                	ld	s0,16(sp)
    800045d6:	64a2                	ld	s1,8(sp)
    800045d8:	6105                	addi	sp,sp,32
    800045da:	8082                	ret
    panic("filedup");
    800045dc:	00004517          	auipc	a0,0x4
    800045e0:	0cc50513          	addi	a0,a0,204 # 800086a8 <syscalls+0x240>
    800045e4:	ffffc097          	auipc	ra,0xffffc
    800045e8:	f5c080e7          	jalr	-164(ra) # 80000540 <panic>

00000000800045ec <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    800045ec:	7139                	addi	sp,sp,-64
    800045ee:	fc06                	sd	ra,56(sp)
    800045f0:	f822                	sd	s0,48(sp)
    800045f2:	f426                	sd	s1,40(sp)
    800045f4:	f04a                	sd	s2,32(sp)
    800045f6:	ec4e                	sd	s3,24(sp)
    800045f8:	e852                	sd	s4,16(sp)
    800045fa:	e456                	sd	s5,8(sp)
    800045fc:	0080                	addi	s0,sp,64
    800045fe:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80004600:	0001d517          	auipc	a0,0x1d
    80004604:	97850513          	addi	a0,a0,-1672 # 80020f78 <ftable>
    80004608:	ffffc097          	auipc	ra,0xffffc
    8000460c:	640080e7          	jalr	1600(ra) # 80000c48 <acquire>
  if(f->ref < 1)
    80004610:	40dc                	lw	a5,4(s1)
    80004612:	06f05163          	blez	a5,80004674 <fileclose+0x88>
    panic("fileclose");
  if(--f->ref > 0){
    80004616:	37fd                	addiw	a5,a5,-1
    80004618:	0007871b          	sext.w	a4,a5
    8000461c:	c0dc                	sw	a5,4(s1)
    8000461e:	06e04363          	bgtz	a4,80004684 <fileclose+0x98>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80004622:	0004a903          	lw	s2,0(s1)
    80004626:	0094ca83          	lbu	s5,9(s1)
    8000462a:	0104ba03          	ld	s4,16(s1)
    8000462e:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    80004632:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80004636:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    8000463a:	0001d517          	auipc	a0,0x1d
    8000463e:	93e50513          	addi	a0,a0,-1730 # 80020f78 <ftable>
    80004642:	ffffc097          	auipc	ra,0xffffc
    80004646:	6ba080e7          	jalr	1722(ra) # 80000cfc <release>

  if(ff.type == FD_PIPE){
    8000464a:	4785                	li	a5,1
    8000464c:	04f90d63          	beq	s2,a5,800046a6 <fileclose+0xba>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80004650:	3979                	addiw	s2,s2,-2
    80004652:	4785                	li	a5,1
    80004654:	0527e063          	bltu	a5,s2,80004694 <fileclose+0xa8>
    begin_op();
    80004658:	00000097          	auipc	ra,0x0
    8000465c:	ad0080e7          	jalr	-1328(ra) # 80004128 <begin_op>
    iput(ff.ip);
    80004660:	854e                	mv	a0,s3
    80004662:	fffff097          	auipc	ra,0xfffff
    80004666:	2da080e7          	jalr	730(ra) # 8000393c <iput>
    end_op();
    8000466a:	00000097          	auipc	ra,0x0
    8000466e:	b38080e7          	jalr	-1224(ra) # 800041a2 <end_op>
    80004672:	a00d                	j	80004694 <fileclose+0xa8>
    panic("fileclose");
    80004674:	00004517          	auipc	a0,0x4
    80004678:	03c50513          	addi	a0,a0,60 # 800086b0 <syscalls+0x248>
    8000467c:	ffffc097          	auipc	ra,0xffffc
    80004680:	ec4080e7          	jalr	-316(ra) # 80000540 <panic>
    release(&ftable.lock);
    80004684:	0001d517          	auipc	a0,0x1d
    80004688:	8f450513          	addi	a0,a0,-1804 # 80020f78 <ftable>
    8000468c:	ffffc097          	auipc	ra,0xffffc
    80004690:	670080e7          	jalr	1648(ra) # 80000cfc <release>
  }
}
    80004694:	70e2                	ld	ra,56(sp)
    80004696:	7442                	ld	s0,48(sp)
    80004698:	74a2                	ld	s1,40(sp)
    8000469a:	7902                	ld	s2,32(sp)
    8000469c:	69e2                	ld	s3,24(sp)
    8000469e:	6a42                	ld	s4,16(sp)
    800046a0:	6aa2                	ld	s5,8(sp)
    800046a2:	6121                	addi	sp,sp,64
    800046a4:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    800046a6:	85d6                	mv	a1,s5
    800046a8:	8552                	mv	a0,s4
    800046aa:	00000097          	auipc	ra,0x0
    800046ae:	348080e7          	jalr	840(ra) # 800049f2 <pipeclose>
    800046b2:	b7cd                	j	80004694 <fileclose+0xa8>

00000000800046b4 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    800046b4:	715d                	addi	sp,sp,-80
    800046b6:	e486                	sd	ra,72(sp)
    800046b8:	e0a2                	sd	s0,64(sp)
    800046ba:	fc26                	sd	s1,56(sp)
    800046bc:	f84a                	sd	s2,48(sp)
    800046be:	f44e                	sd	s3,40(sp)
    800046c0:	0880                	addi	s0,sp,80
    800046c2:	84aa                	mv	s1,a0
    800046c4:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    800046c6:	ffffd097          	auipc	ra,0xffffd
    800046ca:	35e080e7          	jalr	862(ra) # 80001a24 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    800046ce:	409c                	lw	a5,0(s1)
    800046d0:	37f9                	addiw	a5,a5,-2
    800046d2:	4705                	li	a4,1
    800046d4:	04f76763          	bltu	a4,a5,80004722 <filestat+0x6e>
    800046d8:	892a                	mv	s2,a0
    ilock(f->ip);
    800046da:	6c88                	ld	a0,24(s1)
    800046dc:	fffff097          	auipc	ra,0xfffff
    800046e0:	0a6080e7          	jalr	166(ra) # 80003782 <ilock>
    stati(f->ip, &st);
    800046e4:	fb840593          	addi	a1,s0,-72
    800046e8:	6c88                	ld	a0,24(s1)
    800046ea:	fffff097          	auipc	ra,0xfffff
    800046ee:	322080e7          	jalr	802(ra) # 80003a0c <stati>
    iunlock(f->ip);
    800046f2:	6c88                	ld	a0,24(s1)
    800046f4:	fffff097          	auipc	ra,0xfffff
    800046f8:	150080e7          	jalr	336(ra) # 80003844 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    800046fc:	46e1                	li	a3,24
    800046fe:	fb840613          	addi	a2,s0,-72
    80004702:	85ce                	mv	a1,s3
    80004704:	05093503          	ld	a0,80(s2)
    80004708:	ffffd097          	auipc	ra,0xffffd
    8000470c:	fdc080e7          	jalr	-36(ra) # 800016e4 <copyout>
    80004710:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    80004714:	60a6                	ld	ra,72(sp)
    80004716:	6406                	ld	s0,64(sp)
    80004718:	74e2                	ld	s1,56(sp)
    8000471a:	7942                	ld	s2,48(sp)
    8000471c:	79a2                	ld	s3,40(sp)
    8000471e:	6161                	addi	sp,sp,80
    80004720:	8082                	ret
  return -1;
    80004722:	557d                	li	a0,-1
    80004724:	bfc5                	j	80004714 <filestat+0x60>

0000000080004726 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80004726:	7179                	addi	sp,sp,-48
    80004728:	f406                	sd	ra,40(sp)
    8000472a:	f022                	sd	s0,32(sp)
    8000472c:	ec26                	sd	s1,24(sp)
    8000472e:	e84a                	sd	s2,16(sp)
    80004730:	e44e                	sd	s3,8(sp)
    80004732:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80004734:	00854783          	lbu	a5,8(a0)
    80004738:	c3d5                	beqz	a5,800047dc <fileread+0xb6>
    8000473a:	84aa                	mv	s1,a0
    8000473c:	89ae                	mv	s3,a1
    8000473e:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    80004740:	411c                	lw	a5,0(a0)
    80004742:	4705                	li	a4,1
    80004744:	04e78963          	beq	a5,a4,80004796 <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004748:	470d                	li	a4,3
    8000474a:	04e78d63          	beq	a5,a4,800047a4 <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    8000474e:	4709                	li	a4,2
    80004750:	06e79e63          	bne	a5,a4,800047cc <fileread+0xa6>
    ilock(f->ip);
    80004754:	6d08                	ld	a0,24(a0)
    80004756:	fffff097          	auipc	ra,0xfffff
    8000475a:	02c080e7          	jalr	44(ra) # 80003782 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    8000475e:	874a                	mv	a4,s2
    80004760:	5094                	lw	a3,32(s1)
    80004762:	864e                	mv	a2,s3
    80004764:	4585                	li	a1,1
    80004766:	6c88                	ld	a0,24(s1)
    80004768:	fffff097          	auipc	ra,0xfffff
    8000476c:	2ce080e7          	jalr	718(ra) # 80003a36 <readi>
    80004770:	892a                	mv	s2,a0
    80004772:	00a05563          	blez	a0,8000477c <fileread+0x56>
      f->off += r;
    80004776:	509c                	lw	a5,32(s1)
    80004778:	9fa9                	addw	a5,a5,a0
    8000477a:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    8000477c:	6c88                	ld	a0,24(s1)
    8000477e:	fffff097          	auipc	ra,0xfffff
    80004782:	0c6080e7          	jalr	198(ra) # 80003844 <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    80004786:	854a                	mv	a0,s2
    80004788:	70a2                	ld	ra,40(sp)
    8000478a:	7402                	ld	s0,32(sp)
    8000478c:	64e2                	ld	s1,24(sp)
    8000478e:	6942                	ld	s2,16(sp)
    80004790:	69a2                	ld	s3,8(sp)
    80004792:	6145                	addi	sp,sp,48
    80004794:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80004796:	6908                	ld	a0,16(a0)
    80004798:	00000097          	auipc	ra,0x0
    8000479c:	3c2080e7          	jalr	962(ra) # 80004b5a <piperead>
    800047a0:	892a                	mv	s2,a0
    800047a2:	b7d5                	j	80004786 <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    800047a4:	02451783          	lh	a5,36(a0)
    800047a8:	03079693          	slli	a3,a5,0x30
    800047ac:	92c1                	srli	a3,a3,0x30
    800047ae:	4725                	li	a4,9
    800047b0:	02d76863          	bltu	a4,a3,800047e0 <fileread+0xba>
    800047b4:	0792                	slli	a5,a5,0x4
    800047b6:	0001c717          	auipc	a4,0x1c
    800047ba:	72270713          	addi	a4,a4,1826 # 80020ed8 <devsw>
    800047be:	97ba                	add	a5,a5,a4
    800047c0:	639c                	ld	a5,0(a5)
    800047c2:	c38d                	beqz	a5,800047e4 <fileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    800047c4:	4505                	li	a0,1
    800047c6:	9782                	jalr	a5
    800047c8:	892a                	mv	s2,a0
    800047ca:	bf75                	j	80004786 <fileread+0x60>
    panic("fileread");
    800047cc:	00004517          	auipc	a0,0x4
    800047d0:	ef450513          	addi	a0,a0,-268 # 800086c0 <syscalls+0x258>
    800047d4:	ffffc097          	auipc	ra,0xffffc
    800047d8:	d6c080e7          	jalr	-660(ra) # 80000540 <panic>
    return -1;
    800047dc:	597d                	li	s2,-1
    800047de:	b765                	j	80004786 <fileread+0x60>
      return -1;
    800047e0:	597d                	li	s2,-1
    800047e2:	b755                	j	80004786 <fileread+0x60>
    800047e4:	597d                	li	s2,-1
    800047e6:	b745                	j	80004786 <fileread+0x60>

00000000800047e8 <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if(f->writable == 0)
    800047e8:	00954783          	lbu	a5,9(a0)
    800047ec:	10078e63          	beqz	a5,80004908 <filewrite+0x120>
{
    800047f0:	715d                	addi	sp,sp,-80
    800047f2:	e486                	sd	ra,72(sp)
    800047f4:	e0a2                	sd	s0,64(sp)
    800047f6:	fc26                	sd	s1,56(sp)
    800047f8:	f84a                	sd	s2,48(sp)
    800047fa:	f44e                	sd	s3,40(sp)
    800047fc:	f052                	sd	s4,32(sp)
    800047fe:	ec56                	sd	s5,24(sp)
    80004800:	e85a                	sd	s6,16(sp)
    80004802:	e45e                	sd	s7,8(sp)
    80004804:	e062                	sd	s8,0(sp)
    80004806:	0880                	addi	s0,sp,80
    80004808:	892a                	mv	s2,a0
    8000480a:	8b2e                	mv	s6,a1
    8000480c:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    8000480e:	411c                	lw	a5,0(a0)
    80004810:	4705                	li	a4,1
    80004812:	02e78263          	beq	a5,a4,80004836 <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004816:	470d                	li	a4,3
    80004818:	02e78563          	beq	a5,a4,80004842 <filewrite+0x5a>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    8000481c:	4709                	li	a4,2
    8000481e:	0ce79d63          	bne	a5,a4,800048f8 <filewrite+0x110>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80004822:	0ac05b63          	blez	a2,800048d8 <filewrite+0xf0>
    int i = 0;
    80004826:	4981                	li	s3,0
      int n1 = n - i;
      if(n1 > max)
    80004828:	6b85                	lui	s7,0x1
    8000482a:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    8000482e:	6c05                	lui	s8,0x1
    80004830:	c00c0c1b          	addiw	s8,s8,-1024 # c00 <_entry-0x7ffff400>
    80004834:	a851                	j	800048c8 <filewrite+0xe0>
    ret = pipewrite(f->pipe, addr, n);
    80004836:	6908                	ld	a0,16(a0)
    80004838:	00000097          	auipc	ra,0x0
    8000483c:	22a080e7          	jalr	554(ra) # 80004a62 <pipewrite>
    80004840:	a045                	j	800048e0 <filewrite+0xf8>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80004842:	02451783          	lh	a5,36(a0)
    80004846:	03079693          	slli	a3,a5,0x30
    8000484a:	92c1                	srli	a3,a3,0x30
    8000484c:	4725                	li	a4,9
    8000484e:	0ad76f63          	bltu	a4,a3,8000490c <filewrite+0x124>
    80004852:	0792                	slli	a5,a5,0x4
    80004854:	0001c717          	auipc	a4,0x1c
    80004858:	68470713          	addi	a4,a4,1668 # 80020ed8 <devsw>
    8000485c:	97ba                	add	a5,a5,a4
    8000485e:	679c                	ld	a5,8(a5)
    80004860:	cbc5                	beqz	a5,80004910 <filewrite+0x128>
    ret = devsw[f->major].write(1, addr, n);
    80004862:	4505                	li	a0,1
    80004864:	9782                	jalr	a5
    80004866:	a8ad                	j	800048e0 <filewrite+0xf8>
      if(n1 > max)
    80004868:	00048a9b          	sext.w	s5,s1
        n1 = max;

      begin_op();
    8000486c:	00000097          	auipc	ra,0x0
    80004870:	8bc080e7          	jalr	-1860(ra) # 80004128 <begin_op>
      ilock(f->ip);
    80004874:	01893503          	ld	a0,24(s2)
    80004878:	fffff097          	auipc	ra,0xfffff
    8000487c:	f0a080e7          	jalr	-246(ra) # 80003782 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004880:	8756                	mv	a4,s5
    80004882:	02092683          	lw	a3,32(s2)
    80004886:	01698633          	add	a2,s3,s6
    8000488a:	4585                	li	a1,1
    8000488c:	01893503          	ld	a0,24(s2)
    80004890:	fffff097          	auipc	ra,0xfffff
    80004894:	29e080e7          	jalr	670(ra) # 80003b2e <writei>
    80004898:	84aa                	mv	s1,a0
    8000489a:	00a05763          	blez	a0,800048a8 <filewrite+0xc0>
        f->off += r;
    8000489e:	02092783          	lw	a5,32(s2)
    800048a2:	9fa9                	addw	a5,a5,a0
    800048a4:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    800048a8:	01893503          	ld	a0,24(s2)
    800048ac:	fffff097          	auipc	ra,0xfffff
    800048b0:	f98080e7          	jalr	-104(ra) # 80003844 <iunlock>
      end_op();
    800048b4:	00000097          	auipc	ra,0x0
    800048b8:	8ee080e7          	jalr	-1810(ra) # 800041a2 <end_op>

      if(r != n1){
    800048bc:	009a9f63          	bne	s5,s1,800048da <filewrite+0xf2>
        // error from writei
        break;
      }
      i += r;
    800048c0:	013489bb          	addw	s3,s1,s3
    while(i < n){
    800048c4:	0149db63          	bge	s3,s4,800048da <filewrite+0xf2>
      int n1 = n - i;
    800048c8:	413a04bb          	subw	s1,s4,s3
      if(n1 > max)
    800048cc:	0004879b          	sext.w	a5,s1
    800048d0:	f8fbdce3          	bge	s7,a5,80004868 <filewrite+0x80>
    800048d4:	84e2                	mv	s1,s8
    800048d6:	bf49                	j	80004868 <filewrite+0x80>
    int i = 0;
    800048d8:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    800048da:	033a1d63          	bne	s4,s3,80004914 <filewrite+0x12c>
    800048de:	8552                	mv	a0,s4
  } else {
    panic("filewrite");
  }

  return ret;
}
    800048e0:	60a6                	ld	ra,72(sp)
    800048e2:	6406                	ld	s0,64(sp)
    800048e4:	74e2                	ld	s1,56(sp)
    800048e6:	7942                	ld	s2,48(sp)
    800048e8:	79a2                	ld	s3,40(sp)
    800048ea:	7a02                	ld	s4,32(sp)
    800048ec:	6ae2                	ld	s5,24(sp)
    800048ee:	6b42                	ld	s6,16(sp)
    800048f0:	6ba2                	ld	s7,8(sp)
    800048f2:	6c02                	ld	s8,0(sp)
    800048f4:	6161                	addi	sp,sp,80
    800048f6:	8082                	ret
    panic("filewrite");
    800048f8:	00004517          	auipc	a0,0x4
    800048fc:	dd850513          	addi	a0,a0,-552 # 800086d0 <syscalls+0x268>
    80004900:	ffffc097          	auipc	ra,0xffffc
    80004904:	c40080e7          	jalr	-960(ra) # 80000540 <panic>
    return -1;
    80004908:	557d                	li	a0,-1
}
    8000490a:	8082                	ret
      return -1;
    8000490c:	557d                	li	a0,-1
    8000490e:	bfc9                	j	800048e0 <filewrite+0xf8>
    80004910:	557d                	li	a0,-1
    80004912:	b7f9                	j	800048e0 <filewrite+0xf8>
    ret = (i == n ? n : -1);
    80004914:	557d                	li	a0,-1
    80004916:	b7e9                	j	800048e0 <filewrite+0xf8>

0000000080004918 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80004918:	7179                	addi	sp,sp,-48
    8000491a:	f406                	sd	ra,40(sp)
    8000491c:	f022                	sd	s0,32(sp)
    8000491e:	ec26                	sd	s1,24(sp)
    80004920:	e84a                	sd	s2,16(sp)
    80004922:	e44e                	sd	s3,8(sp)
    80004924:	e052                	sd	s4,0(sp)
    80004926:	1800                	addi	s0,sp,48
    80004928:	84aa                	mv	s1,a0
    8000492a:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    8000492c:	0005b023          	sd	zero,0(a1)
    80004930:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80004934:	00000097          	auipc	ra,0x0
    80004938:	bfc080e7          	jalr	-1028(ra) # 80004530 <filealloc>
    8000493c:	e088                	sd	a0,0(s1)
    8000493e:	c551                	beqz	a0,800049ca <pipealloc+0xb2>
    80004940:	00000097          	auipc	ra,0x0
    80004944:	bf0080e7          	jalr	-1040(ra) # 80004530 <filealloc>
    80004948:	00aa3023          	sd	a0,0(s4)
    8000494c:	c92d                	beqz	a0,800049be <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    8000494e:	ffffc097          	auipc	ra,0xffffc
    80004952:	20a080e7          	jalr	522(ra) # 80000b58 <kalloc>
    80004956:	892a                	mv	s2,a0
    80004958:	c125                	beqz	a0,800049b8 <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    8000495a:	4985                	li	s3,1
    8000495c:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80004960:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80004964:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80004968:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    8000496c:	00004597          	auipc	a1,0x4
    80004970:	d7458593          	addi	a1,a1,-652 # 800086e0 <syscalls+0x278>
    80004974:	ffffc097          	auipc	ra,0xffffc
    80004978:	244080e7          	jalr	580(ra) # 80000bb8 <initlock>
  (*f0)->type = FD_PIPE;
    8000497c:	609c                	ld	a5,0(s1)
    8000497e:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80004982:	609c                	ld	a5,0(s1)
    80004984:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80004988:	609c                	ld	a5,0(s1)
    8000498a:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    8000498e:	609c                	ld	a5,0(s1)
    80004990:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80004994:	000a3783          	ld	a5,0(s4)
    80004998:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    8000499c:	000a3783          	ld	a5,0(s4)
    800049a0:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    800049a4:	000a3783          	ld	a5,0(s4)
    800049a8:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    800049ac:	000a3783          	ld	a5,0(s4)
    800049b0:	0127b823          	sd	s2,16(a5)
  return 0;
    800049b4:	4501                	li	a0,0
    800049b6:	a025                	j	800049de <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    800049b8:	6088                	ld	a0,0(s1)
    800049ba:	e501                	bnez	a0,800049c2 <pipealloc+0xaa>
    800049bc:	a039                	j	800049ca <pipealloc+0xb2>
    800049be:	6088                	ld	a0,0(s1)
    800049c0:	c51d                	beqz	a0,800049ee <pipealloc+0xd6>
    fileclose(*f0);
    800049c2:	00000097          	auipc	ra,0x0
    800049c6:	c2a080e7          	jalr	-982(ra) # 800045ec <fileclose>
  if(*f1)
    800049ca:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    800049ce:	557d                	li	a0,-1
  if(*f1)
    800049d0:	c799                	beqz	a5,800049de <pipealloc+0xc6>
    fileclose(*f1);
    800049d2:	853e                	mv	a0,a5
    800049d4:	00000097          	auipc	ra,0x0
    800049d8:	c18080e7          	jalr	-1000(ra) # 800045ec <fileclose>
  return -1;
    800049dc:	557d                	li	a0,-1
}
    800049de:	70a2                	ld	ra,40(sp)
    800049e0:	7402                	ld	s0,32(sp)
    800049e2:	64e2                	ld	s1,24(sp)
    800049e4:	6942                	ld	s2,16(sp)
    800049e6:	69a2                	ld	s3,8(sp)
    800049e8:	6a02                	ld	s4,0(sp)
    800049ea:	6145                	addi	sp,sp,48
    800049ec:	8082                	ret
  return -1;
    800049ee:	557d                	li	a0,-1
    800049f0:	b7fd                	j	800049de <pipealloc+0xc6>

00000000800049f2 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    800049f2:	1101                	addi	sp,sp,-32
    800049f4:	ec06                	sd	ra,24(sp)
    800049f6:	e822                	sd	s0,16(sp)
    800049f8:	e426                	sd	s1,8(sp)
    800049fa:	e04a                	sd	s2,0(sp)
    800049fc:	1000                	addi	s0,sp,32
    800049fe:	84aa                	mv	s1,a0
    80004a00:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80004a02:	ffffc097          	auipc	ra,0xffffc
    80004a06:	246080e7          	jalr	582(ra) # 80000c48 <acquire>
  if(writable){
    80004a0a:	02090d63          	beqz	s2,80004a44 <pipeclose+0x52>
    pi->writeopen = 0;
    80004a0e:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80004a12:	21848513          	addi	a0,s1,536
    80004a16:	ffffd097          	auipc	ra,0xffffd
    80004a1a:	748080e7          	jalr	1864(ra) # 8000215e <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80004a1e:	2204b783          	ld	a5,544(s1)
    80004a22:	eb95                	bnez	a5,80004a56 <pipeclose+0x64>
    release(&pi->lock);
    80004a24:	8526                	mv	a0,s1
    80004a26:	ffffc097          	auipc	ra,0xffffc
    80004a2a:	2d6080e7          	jalr	726(ra) # 80000cfc <release>
    kfree((char*)pi);
    80004a2e:	8526                	mv	a0,s1
    80004a30:	ffffc097          	auipc	ra,0xffffc
    80004a34:	02a080e7          	jalr	42(ra) # 80000a5a <kfree>
  } else
    release(&pi->lock);
}
    80004a38:	60e2                	ld	ra,24(sp)
    80004a3a:	6442                	ld	s0,16(sp)
    80004a3c:	64a2                	ld	s1,8(sp)
    80004a3e:	6902                	ld	s2,0(sp)
    80004a40:	6105                	addi	sp,sp,32
    80004a42:	8082                	ret
    pi->readopen = 0;
    80004a44:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80004a48:	21c48513          	addi	a0,s1,540
    80004a4c:	ffffd097          	auipc	ra,0xffffd
    80004a50:	712080e7          	jalr	1810(ra) # 8000215e <wakeup>
    80004a54:	b7e9                	j	80004a1e <pipeclose+0x2c>
    release(&pi->lock);
    80004a56:	8526                	mv	a0,s1
    80004a58:	ffffc097          	auipc	ra,0xffffc
    80004a5c:	2a4080e7          	jalr	676(ra) # 80000cfc <release>
}
    80004a60:	bfe1                	j	80004a38 <pipeclose+0x46>

0000000080004a62 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80004a62:	711d                	addi	sp,sp,-96
    80004a64:	ec86                	sd	ra,88(sp)
    80004a66:	e8a2                	sd	s0,80(sp)
    80004a68:	e4a6                	sd	s1,72(sp)
    80004a6a:	e0ca                	sd	s2,64(sp)
    80004a6c:	fc4e                	sd	s3,56(sp)
    80004a6e:	f852                	sd	s4,48(sp)
    80004a70:	f456                	sd	s5,40(sp)
    80004a72:	f05a                	sd	s6,32(sp)
    80004a74:	ec5e                	sd	s7,24(sp)
    80004a76:	e862                	sd	s8,16(sp)
    80004a78:	1080                	addi	s0,sp,96
    80004a7a:	84aa                	mv	s1,a0
    80004a7c:	8aae                	mv	s5,a1
    80004a7e:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    80004a80:	ffffd097          	auipc	ra,0xffffd
    80004a84:	fa4080e7          	jalr	-92(ra) # 80001a24 <myproc>
    80004a88:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80004a8a:	8526                	mv	a0,s1
    80004a8c:	ffffc097          	auipc	ra,0xffffc
    80004a90:	1bc080e7          	jalr	444(ra) # 80000c48 <acquire>
  while(i < n){
    80004a94:	0b405663          	blez	s4,80004b40 <pipewrite+0xde>
  int i = 0;
    80004a98:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004a9a:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80004a9c:	21848c13          	addi	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80004aa0:	21c48b93          	addi	s7,s1,540
    80004aa4:	a089                	j	80004ae6 <pipewrite+0x84>
      release(&pi->lock);
    80004aa6:	8526                	mv	a0,s1
    80004aa8:	ffffc097          	auipc	ra,0xffffc
    80004aac:	254080e7          	jalr	596(ra) # 80000cfc <release>
      return -1;
    80004ab0:	597d                	li	s2,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80004ab2:	854a                	mv	a0,s2
    80004ab4:	60e6                	ld	ra,88(sp)
    80004ab6:	6446                	ld	s0,80(sp)
    80004ab8:	64a6                	ld	s1,72(sp)
    80004aba:	6906                	ld	s2,64(sp)
    80004abc:	79e2                	ld	s3,56(sp)
    80004abe:	7a42                	ld	s4,48(sp)
    80004ac0:	7aa2                	ld	s5,40(sp)
    80004ac2:	7b02                	ld	s6,32(sp)
    80004ac4:	6be2                	ld	s7,24(sp)
    80004ac6:	6c42                	ld	s8,16(sp)
    80004ac8:	6125                	addi	sp,sp,96
    80004aca:	8082                	ret
      wakeup(&pi->nread);
    80004acc:	8562                	mv	a0,s8
    80004ace:	ffffd097          	auipc	ra,0xffffd
    80004ad2:	690080e7          	jalr	1680(ra) # 8000215e <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80004ad6:	85a6                	mv	a1,s1
    80004ad8:	855e                	mv	a0,s7
    80004ada:	ffffd097          	auipc	ra,0xffffd
    80004ade:	620080e7          	jalr	1568(ra) # 800020fa <sleep>
  while(i < n){
    80004ae2:	07495063          	bge	s2,s4,80004b42 <pipewrite+0xe0>
    if(pi->readopen == 0 || killed(pr)){
    80004ae6:	2204a783          	lw	a5,544(s1)
    80004aea:	dfd5                	beqz	a5,80004aa6 <pipewrite+0x44>
    80004aec:	854e                	mv	a0,s3
    80004aee:	ffffe097          	auipc	ra,0xffffe
    80004af2:	8b4080e7          	jalr	-1868(ra) # 800023a2 <killed>
    80004af6:	f945                	bnez	a0,80004aa6 <pipewrite+0x44>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    80004af8:	2184a783          	lw	a5,536(s1)
    80004afc:	21c4a703          	lw	a4,540(s1)
    80004b00:	2007879b          	addiw	a5,a5,512
    80004b04:	fcf704e3          	beq	a4,a5,80004acc <pipewrite+0x6a>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004b08:	4685                	li	a3,1
    80004b0a:	01590633          	add	a2,s2,s5
    80004b0e:	faf40593          	addi	a1,s0,-81
    80004b12:	0509b503          	ld	a0,80(s3)
    80004b16:	ffffd097          	auipc	ra,0xffffd
    80004b1a:	c5a080e7          	jalr	-934(ra) # 80001770 <copyin>
    80004b1e:	03650263          	beq	a0,s6,80004b42 <pipewrite+0xe0>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004b22:	21c4a783          	lw	a5,540(s1)
    80004b26:	0017871b          	addiw	a4,a5,1
    80004b2a:	20e4ae23          	sw	a4,540(s1)
    80004b2e:	1ff7f793          	andi	a5,a5,511
    80004b32:	97a6                	add	a5,a5,s1
    80004b34:	faf44703          	lbu	a4,-81(s0)
    80004b38:	00e78c23          	sb	a4,24(a5)
      i++;
    80004b3c:	2905                	addiw	s2,s2,1
    80004b3e:	b755                	j	80004ae2 <pipewrite+0x80>
  int i = 0;
    80004b40:	4901                	li	s2,0
  wakeup(&pi->nread);
    80004b42:	21848513          	addi	a0,s1,536
    80004b46:	ffffd097          	auipc	ra,0xffffd
    80004b4a:	618080e7          	jalr	1560(ra) # 8000215e <wakeup>
  release(&pi->lock);
    80004b4e:	8526                	mv	a0,s1
    80004b50:	ffffc097          	auipc	ra,0xffffc
    80004b54:	1ac080e7          	jalr	428(ra) # 80000cfc <release>
  return i;
    80004b58:	bfa9                	j	80004ab2 <pipewrite+0x50>

0000000080004b5a <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80004b5a:	715d                	addi	sp,sp,-80
    80004b5c:	e486                	sd	ra,72(sp)
    80004b5e:	e0a2                	sd	s0,64(sp)
    80004b60:	fc26                	sd	s1,56(sp)
    80004b62:	f84a                	sd	s2,48(sp)
    80004b64:	f44e                	sd	s3,40(sp)
    80004b66:	f052                	sd	s4,32(sp)
    80004b68:	ec56                	sd	s5,24(sp)
    80004b6a:	e85a                	sd	s6,16(sp)
    80004b6c:	0880                	addi	s0,sp,80
    80004b6e:	84aa                	mv	s1,a0
    80004b70:	892e                	mv	s2,a1
    80004b72:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80004b74:	ffffd097          	auipc	ra,0xffffd
    80004b78:	eb0080e7          	jalr	-336(ra) # 80001a24 <myproc>
    80004b7c:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80004b7e:	8526                	mv	a0,s1
    80004b80:	ffffc097          	auipc	ra,0xffffc
    80004b84:	0c8080e7          	jalr	200(ra) # 80000c48 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004b88:	2184a703          	lw	a4,536(s1)
    80004b8c:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004b90:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004b94:	02f71763          	bne	a4,a5,80004bc2 <piperead+0x68>
    80004b98:	2244a783          	lw	a5,548(s1)
    80004b9c:	c39d                	beqz	a5,80004bc2 <piperead+0x68>
    if(killed(pr)){
    80004b9e:	8552                	mv	a0,s4
    80004ba0:	ffffe097          	auipc	ra,0xffffe
    80004ba4:	802080e7          	jalr	-2046(ra) # 800023a2 <killed>
    80004ba8:	e949                	bnez	a0,80004c3a <piperead+0xe0>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004baa:	85a6                	mv	a1,s1
    80004bac:	854e                	mv	a0,s3
    80004bae:	ffffd097          	auipc	ra,0xffffd
    80004bb2:	54c080e7          	jalr	1356(ra) # 800020fa <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004bb6:	2184a703          	lw	a4,536(s1)
    80004bba:	21c4a783          	lw	a5,540(s1)
    80004bbe:	fcf70de3          	beq	a4,a5,80004b98 <piperead+0x3e>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004bc2:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004bc4:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004bc6:	05505463          	blez	s5,80004c0e <piperead+0xb4>
    if(pi->nread == pi->nwrite)
    80004bca:	2184a783          	lw	a5,536(s1)
    80004bce:	21c4a703          	lw	a4,540(s1)
    80004bd2:	02f70e63          	beq	a4,a5,80004c0e <piperead+0xb4>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80004bd6:	0017871b          	addiw	a4,a5,1
    80004bda:	20e4ac23          	sw	a4,536(s1)
    80004bde:	1ff7f793          	andi	a5,a5,511
    80004be2:	97a6                	add	a5,a5,s1
    80004be4:	0187c783          	lbu	a5,24(a5)
    80004be8:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004bec:	4685                	li	a3,1
    80004bee:	fbf40613          	addi	a2,s0,-65
    80004bf2:	85ca                	mv	a1,s2
    80004bf4:	050a3503          	ld	a0,80(s4)
    80004bf8:	ffffd097          	auipc	ra,0xffffd
    80004bfc:	aec080e7          	jalr	-1300(ra) # 800016e4 <copyout>
    80004c00:	01650763          	beq	a0,s6,80004c0e <piperead+0xb4>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004c04:	2985                	addiw	s3,s3,1
    80004c06:	0905                	addi	s2,s2,1
    80004c08:	fd3a91e3          	bne	s5,s3,80004bca <piperead+0x70>
    80004c0c:	89d6                	mv	s3,s5
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80004c0e:	21c48513          	addi	a0,s1,540
    80004c12:	ffffd097          	auipc	ra,0xffffd
    80004c16:	54c080e7          	jalr	1356(ra) # 8000215e <wakeup>
  release(&pi->lock);
    80004c1a:	8526                	mv	a0,s1
    80004c1c:	ffffc097          	auipc	ra,0xffffc
    80004c20:	0e0080e7          	jalr	224(ra) # 80000cfc <release>
  return i;
}
    80004c24:	854e                	mv	a0,s3
    80004c26:	60a6                	ld	ra,72(sp)
    80004c28:	6406                	ld	s0,64(sp)
    80004c2a:	74e2                	ld	s1,56(sp)
    80004c2c:	7942                	ld	s2,48(sp)
    80004c2e:	79a2                	ld	s3,40(sp)
    80004c30:	7a02                	ld	s4,32(sp)
    80004c32:	6ae2                	ld	s5,24(sp)
    80004c34:	6b42                	ld	s6,16(sp)
    80004c36:	6161                	addi	sp,sp,80
    80004c38:	8082                	ret
      release(&pi->lock);
    80004c3a:	8526                	mv	a0,s1
    80004c3c:	ffffc097          	auipc	ra,0xffffc
    80004c40:	0c0080e7          	jalr	192(ra) # 80000cfc <release>
      return -1;
    80004c44:	59fd                	li	s3,-1
    80004c46:	bff9                	j	80004c24 <piperead+0xca>

0000000080004c48 <flags2perm>:
#include "elf.h"

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

int flags2perm(int flags)
{
    80004c48:	1141                	addi	sp,sp,-16
    80004c4a:	e422                	sd	s0,8(sp)
    80004c4c:	0800                	addi	s0,sp,16
    80004c4e:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    80004c50:	8905                	andi	a0,a0,1
    80004c52:	050e                	slli	a0,a0,0x3
      perm = PTE_X;
    if(flags & 0x2)
    80004c54:	8b89                	andi	a5,a5,2
    80004c56:	c399                	beqz	a5,80004c5c <flags2perm+0x14>
      perm |= PTE_W;
    80004c58:	00456513          	ori	a0,a0,4
    return perm;
}
    80004c5c:	6422                	ld	s0,8(sp)
    80004c5e:	0141                	addi	sp,sp,16
    80004c60:	8082                	ret

0000000080004c62 <exec>:

int
exec(char *path, char **argv)
{
    80004c62:	df010113          	addi	sp,sp,-528
    80004c66:	20113423          	sd	ra,520(sp)
    80004c6a:	20813023          	sd	s0,512(sp)
    80004c6e:	ffa6                	sd	s1,504(sp)
    80004c70:	fbca                	sd	s2,496(sp)
    80004c72:	f7ce                	sd	s3,488(sp)
    80004c74:	f3d2                	sd	s4,480(sp)
    80004c76:	efd6                	sd	s5,472(sp)
    80004c78:	ebda                	sd	s6,464(sp)
    80004c7a:	e7de                	sd	s7,456(sp)
    80004c7c:	e3e2                	sd	s8,448(sp)
    80004c7e:	ff66                	sd	s9,440(sp)
    80004c80:	fb6a                	sd	s10,432(sp)
    80004c82:	f76e                	sd	s11,424(sp)
    80004c84:	0c00                	addi	s0,sp,528
    80004c86:	892a                	mv	s2,a0
    80004c88:	dea43c23          	sd	a0,-520(s0)
    80004c8c:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80004c90:	ffffd097          	auipc	ra,0xffffd
    80004c94:	d94080e7          	jalr	-620(ra) # 80001a24 <myproc>
    80004c98:	84aa                	mv	s1,a0

  begin_op();
    80004c9a:	fffff097          	auipc	ra,0xfffff
    80004c9e:	48e080e7          	jalr	1166(ra) # 80004128 <begin_op>

  if((ip = namei(path)) == 0){
    80004ca2:	854a                	mv	a0,s2
    80004ca4:	fffff097          	auipc	ra,0xfffff
    80004ca8:	284080e7          	jalr	644(ra) # 80003f28 <namei>
    80004cac:	c92d                	beqz	a0,80004d1e <exec+0xbc>
    80004cae:	8a2a                	mv	s4,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80004cb0:	fffff097          	auipc	ra,0xfffff
    80004cb4:	ad2080e7          	jalr	-1326(ra) # 80003782 <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80004cb8:	04000713          	li	a4,64
    80004cbc:	4681                	li	a3,0
    80004cbe:	e5040613          	addi	a2,s0,-432
    80004cc2:	4581                	li	a1,0
    80004cc4:	8552                	mv	a0,s4
    80004cc6:	fffff097          	auipc	ra,0xfffff
    80004cca:	d70080e7          	jalr	-656(ra) # 80003a36 <readi>
    80004cce:	04000793          	li	a5,64
    80004cd2:	00f51a63          	bne	a0,a5,80004ce6 <exec+0x84>
    goto bad;

  if(elf.magic != ELF_MAGIC)
    80004cd6:	e5042703          	lw	a4,-432(s0)
    80004cda:	464c47b7          	lui	a5,0x464c4
    80004cde:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80004ce2:	04f70463          	beq	a4,a5,80004d2a <exec+0xc8>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80004ce6:	8552                	mv	a0,s4
    80004ce8:	fffff097          	auipc	ra,0xfffff
    80004cec:	cfc080e7          	jalr	-772(ra) # 800039e4 <iunlockput>
    end_op();
    80004cf0:	fffff097          	auipc	ra,0xfffff
    80004cf4:	4b2080e7          	jalr	1202(ra) # 800041a2 <end_op>
  }
  return -1;
    80004cf8:	557d                	li	a0,-1
}
    80004cfa:	20813083          	ld	ra,520(sp)
    80004cfe:	20013403          	ld	s0,512(sp)
    80004d02:	74fe                	ld	s1,504(sp)
    80004d04:	795e                	ld	s2,496(sp)
    80004d06:	79be                	ld	s3,488(sp)
    80004d08:	7a1e                	ld	s4,480(sp)
    80004d0a:	6afe                	ld	s5,472(sp)
    80004d0c:	6b5e                	ld	s6,464(sp)
    80004d0e:	6bbe                	ld	s7,456(sp)
    80004d10:	6c1e                	ld	s8,448(sp)
    80004d12:	7cfa                	ld	s9,440(sp)
    80004d14:	7d5a                	ld	s10,432(sp)
    80004d16:	7dba                	ld	s11,424(sp)
    80004d18:	21010113          	addi	sp,sp,528
    80004d1c:	8082                	ret
    end_op();
    80004d1e:	fffff097          	auipc	ra,0xfffff
    80004d22:	484080e7          	jalr	1156(ra) # 800041a2 <end_op>
    return -1;
    80004d26:	557d                	li	a0,-1
    80004d28:	bfc9                	j	80004cfa <exec+0x98>
  if((pagetable = proc_pagetable(p)) == 0)
    80004d2a:	8526                	mv	a0,s1
    80004d2c:	ffffd097          	auipc	ra,0xffffd
    80004d30:	dbc080e7          	jalr	-580(ra) # 80001ae8 <proc_pagetable>
    80004d34:	8b2a                	mv	s6,a0
    80004d36:	d945                	beqz	a0,80004ce6 <exec+0x84>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004d38:	e7042d03          	lw	s10,-400(s0)
    80004d3c:	e8845783          	lhu	a5,-376(s0)
    80004d40:	10078463          	beqz	a5,80004e48 <exec+0x1e6>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004d44:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004d46:	4d81                	li	s11,0
    if(ph.vaddr % PGSIZE != 0)
    80004d48:	6c85                	lui	s9,0x1
    80004d4a:	fffc8793          	addi	a5,s9,-1 # fff <_entry-0x7ffff001>
    80004d4e:	def43823          	sd	a5,-528(s0)

  for(i = 0; i < sz; i += PGSIZE){
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    if(sz - i < PGSIZE)
    80004d52:	6a85                	lui	s5,0x1
    80004d54:	a0b5                	j	80004dc0 <exec+0x15e>
      panic("loadseg: address should exist");
    80004d56:	00004517          	auipc	a0,0x4
    80004d5a:	99250513          	addi	a0,a0,-1646 # 800086e8 <syscalls+0x280>
    80004d5e:	ffffb097          	auipc	ra,0xffffb
    80004d62:	7e2080e7          	jalr	2018(ra) # 80000540 <panic>
    if(sz - i < PGSIZE)
    80004d66:	2481                	sext.w	s1,s1
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80004d68:	8726                	mv	a4,s1
    80004d6a:	012c06bb          	addw	a3,s8,s2
    80004d6e:	4581                	li	a1,0
    80004d70:	8552                	mv	a0,s4
    80004d72:	fffff097          	auipc	ra,0xfffff
    80004d76:	cc4080e7          	jalr	-828(ra) # 80003a36 <readi>
    80004d7a:	2501                	sext.w	a0,a0
    80004d7c:	2aa49963          	bne	s1,a0,8000502e <exec+0x3cc>
  for(i = 0; i < sz; i += PGSIZE){
    80004d80:	012a893b          	addw	s2,s5,s2
    80004d84:	03397563          	bgeu	s2,s3,80004dae <exec+0x14c>
    pa = walkaddr(pagetable, va + i);
    80004d88:	02091593          	slli	a1,s2,0x20
    80004d8c:	9181                	srli	a1,a1,0x20
    80004d8e:	95de                	add	a1,a1,s7
    80004d90:	855a                	mv	a0,s6
    80004d92:	ffffc097          	auipc	ra,0xffffc
    80004d96:	342080e7          	jalr	834(ra) # 800010d4 <walkaddr>
    80004d9a:	862a                	mv	a2,a0
    if(pa == 0)
    80004d9c:	dd4d                	beqz	a0,80004d56 <exec+0xf4>
    if(sz - i < PGSIZE)
    80004d9e:	412984bb          	subw	s1,s3,s2
    80004da2:	0004879b          	sext.w	a5,s1
    80004da6:	fcfcf0e3          	bgeu	s9,a5,80004d66 <exec+0x104>
    80004daa:	84d6                	mv	s1,s5
    80004dac:	bf6d                	j	80004d66 <exec+0x104>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80004dae:	e0843903          	ld	s2,-504(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004db2:	2d85                	addiw	s11,s11,1
    80004db4:	038d0d1b          	addiw	s10,s10,56
    80004db8:	e8845783          	lhu	a5,-376(s0)
    80004dbc:	08fdd763          	bge	s11,a5,80004e4a <exec+0x1e8>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80004dc0:	2d01                	sext.w	s10,s10
    80004dc2:	03800713          	li	a4,56
    80004dc6:	86ea                	mv	a3,s10
    80004dc8:	e1840613          	addi	a2,s0,-488
    80004dcc:	4581                	li	a1,0
    80004dce:	8552                	mv	a0,s4
    80004dd0:	fffff097          	auipc	ra,0xfffff
    80004dd4:	c66080e7          	jalr	-922(ra) # 80003a36 <readi>
    80004dd8:	03800793          	li	a5,56
    80004ddc:	24f51763          	bne	a0,a5,8000502a <exec+0x3c8>
    if(ph.type != ELF_PROG_LOAD)
    80004de0:	e1842783          	lw	a5,-488(s0)
    80004de4:	4705                	li	a4,1
    80004de6:	fce796e3          	bne	a5,a4,80004db2 <exec+0x150>
    if(ph.memsz < ph.filesz)
    80004dea:	e4043483          	ld	s1,-448(s0)
    80004dee:	e3843783          	ld	a5,-456(s0)
    80004df2:	24f4e963          	bltu	s1,a5,80005044 <exec+0x3e2>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80004df6:	e2843783          	ld	a5,-472(s0)
    80004dfa:	94be                	add	s1,s1,a5
    80004dfc:	24f4e763          	bltu	s1,a5,8000504a <exec+0x3e8>
    if(ph.vaddr % PGSIZE != 0)
    80004e00:	df043703          	ld	a4,-528(s0)
    80004e04:	8ff9                	and	a5,a5,a4
    80004e06:	24079563          	bnez	a5,80005050 <exec+0x3ee>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80004e0a:	e1c42503          	lw	a0,-484(s0)
    80004e0e:	00000097          	auipc	ra,0x0
    80004e12:	e3a080e7          	jalr	-454(ra) # 80004c48 <flags2perm>
    80004e16:	86aa                	mv	a3,a0
    80004e18:	8626                	mv	a2,s1
    80004e1a:	85ca                	mv	a1,s2
    80004e1c:	855a                	mv	a0,s6
    80004e1e:	ffffc097          	auipc	ra,0xffffc
    80004e22:	66a080e7          	jalr	1642(ra) # 80001488 <uvmalloc>
    80004e26:	e0a43423          	sd	a0,-504(s0)
    80004e2a:	22050663          	beqz	a0,80005056 <exec+0x3f4>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80004e2e:	e2843b83          	ld	s7,-472(s0)
    80004e32:	e2042c03          	lw	s8,-480(s0)
    80004e36:	e3842983          	lw	s3,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80004e3a:	00098463          	beqz	s3,80004e42 <exec+0x1e0>
    80004e3e:	4901                	li	s2,0
    80004e40:	b7a1                	j	80004d88 <exec+0x126>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80004e42:	e0843903          	ld	s2,-504(s0)
    80004e46:	b7b5                	j	80004db2 <exec+0x150>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004e48:	4901                	li	s2,0
  iunlockput(ip);
    80004e4a:	8552                	mv	a0,s4
    80004e4c:	fffff097          	auipc	ra,0xfffff
    80004e50:	b98080e7          	jalr	-1128(ra) # 800039e4 <iunlockput>
  end_op();
    80004e54:	fffff097          	auipc	ra,0xfffff
    80004e58:	34e080e7          	jalr	846(ra) # 800041a2 <end_op>
  p = myproc();
    80004e5c:	ffffd097          	auipc	ra,0xffffd
    80004e60:	bc8080e7          	jalr	-1080(ra) # 80001a24 <myproc>
    80004e64:	8aaa                	mv	s5,a0
  uint64 oldsz = p->sz;
    80004e66:	04853c83          	ld	s9,72(a0)
  sz = PGROUNDUP(sz);
    80004e6a:	6985                	lui	s3,0x1
    80004e6c:	19fd                	addi	s3,s3,-1 # fff <_entry-0x7ffff001>
    80004e6e:	99ca                	add	s3,s3,s2
    80004e70:	77fd                	lui	a5,0xfffff
    80004e72:	00f9f9b3          	and	s3,s3,a5
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE, PTE_W)) == 0)
    80004e76:	4691                	li	a3,4
    80004e78:	6609                	lui	a2,0x2
    80004e7a:	964e                	add	a2,a2,s3
    80004e7c:	85ce                	mv	a1,s3
    80004e7e:	855a                	mv	a0,s6
    80004e80:	ffffc097          	auipc	ra,0xffffc
    80004e84:	608080e7          	jalr	1544(ra) # 80001488 <uvmalloc>
    80004e88:	892a                	mv	s2,a0
    80004e8a:	e0a43423          	sd	a0,-504(s0)
    80004e8e:	e509                	bnez	a0,80004e98 <exec+0x236>
  if(pagetable)
    80004e90:	e1343423          	sd	s3,-504(s0)
    80004e94:	4a01                	li	s4,0
    80004e96:	aa61                	j	8000502e <exec+0x3cc>
  uvmclear(pagetable, sz-2*PGSIZE);
    80004e98:	75f9                	lui	a1,0xffffe
    80004e9a:	95aa                	add	a1,a1,a0
    80004e9c:	855a                	mv	a0,s6
    80004e9e:	ffffd097          	auipc	ra,0xffffd
    80004ea2:	814080e7          	jalr	-2028(ra) # 800016b2 <uvmclear>
  stackbase = sp - PGSIZE;
    80004ea6:	7bfd                	lui	s7,0xfffff
    80004ea8:	9bca                	add	s7,s7,s2
  for(argc = 0; argv[argc]; argc++) {
    80004eaa:	e0043783          	ld	a5,-512(s0)
    80004eae:	6388                	ld	a0,0(a5)
    80004eb0:	c52d                	beqz	a0,80004f1a <exec+0x2b8>
    80004eb2:	e9040993          	addi	s3,s0,-368
    80004eb6:	f9040c13          	addi	s8,s0,-112
    80004eba:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    80004ebc:	ffffc097          	auipc	ra,0xffffc
    80004ec0:	002080e7          	jalr	2(ra) # 80000ebe <strlen>
    80004ec4:	0015079b          	addiw	a5,a0,1
    80004ec8:	40f907b3          	sub	a5,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80004ecc:	ff07f913          	andi	s2,a5,-16
    if(sp < stackbase)
    80004ed0:	19796663          	bltu	s2,s7,8000505c <exec+0x3fa>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80004ed4:	e0043d03          	ld	s10,-512(s0)
    80004ed8:	000d3a03          	ld	s4,0(s10)
    80004edc:	8552                	mv	a0,s4
    80004ede:	ffffc097          	auipc	ra,0xffffc
    80004ee2:	fe0080e7          	jalr	-32(ra) # 80000ebe <strlen>
    80004ee6:	0015069b          	addiw	a3,a0,1
    80004eea:	8652                	mv	a2,s4
    80004eec:	85ca                	mv	a1,s2
    80004eee:	855a                	mv	a0,s6
    80004ef0:	ffffc097          	auipc	ra,0xffffc
    80004ef4:	7f4080e7          	jalr	2036(ra) # 800016e4 <copyout>
    80004ef8:	16054463          	bltz	a0,80005060 <exec+0x3fe>
    ustack[argc] = sp;
    80004efc:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    80004f00:	0485                	addi	s1,s1,1
    80004f02:	008d0793          	addi	a5,s10,8
    80004f06:	e0f43023          	sd	a5,-512(s0)
    80004f0a:	008d3503          	ld	a0,8(s10)
    80004f0e:	c909                	beqz	a0,80004f20 <exec+0x2be>
    if(argc >= MAXARG)
    80004f10:	09a1                	addi	s3,s3,8
    80004f12:	fb8995e3          	bne	s3,s8,80004ebc <exec+0x25a>
  ip = 0;
    80004f16:	4a01                	li	s4,0
    80004f18:	aa19                	j	8000502e <exec+0x3cc>
  sp = sz;
    80004f1a:	e0843903          	ld	s2,-504(s0)
  for(argc = 0; argv[argc]; argc++) {
    80004f1e:	4481                	li	s1,0
  ustack[argc] = 0;
    80004f20:	00349793          	slli	a5,s1,0x3
    80004f24:	f9078793          	addi	a5,a5,-112 # ffffffffffffef90 <end+0xffffffff7ffdcb48>
    80004f28:	97a2                	add	a5,a5,s0
    80004f2a:	f007b023          	sd	zero,-256(a5)
  sp -= (argc+1) * sizeof(uint64);
    80004f2e:	00148693          	addi	a3,s1,1
    80004f32:	068e                	slli	a3,a3,0x3
    80004f34:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80004f38:	ff097913          	andi	s2,s2,-16
  sz = sz1;
    80004f3c:	e0843983          	ld	s3,-504(s0)
  if(sp < stackbase)
    80004f40:	f57968e3          	bltu	s2,s7,80004e90 <exec+0x22e>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80004f44:	e9040613          	addi	a2,s0,-368
    80004f48:	85ca                	mv	a1,s2
    80004f4a:	855a                	mv	a0,s6
    80004f4c:	ffffc097          	auipc	ra,0xffffc
    80004f50:	798080e7          	jalr	1944(ra) # 800016e4 <copyout>
    80004f54:	10054863          	bltz	a0,80005064 <exec+0x402>
  p->trapframe->a1 = sp;
    80004f58:	058ab783          	ld	a5,88(s5) # 1058 <_entry-0x7fffefa8>
    80004f5c:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80004f60:	df843783          	ld	a5,-520(s0)
    80004f64:	0007c703          	lbu	a4,0(a5)
    80004f68:	cf11                	beqz	a4,80004f84 <exec+0x322>
    80004f6a:	0785                	addi	a5,a5,1
    if(*s == '/')
    80004f6c:	02f00693          	li	a3,47
    80004f70:	a039                	j	80004f7e <exec+0x31c>
      last = s+1;
    80004f72:	def43c23          	sd	a5,-520(s0)
  for(last=s=path; *s; s++)
    80004f76:	0785                	addi	a5,a5,1
    80004f78:	fff7c703          	lbu	a4,-1(a5)
    80004f7c:	c701                	beqz	a4,80004f84 <exec+0x322>
    if(*s == '/')
    80004f7e:	fed71ce3          	bne	a4,a3,80004f76 <exec+0x314>
    80004f82:	bfc5                	j	80004f72 <exec+0x310>
  safestrcpy(p->name, last, sizeof(p->name));
    80004f84:	158a8993          	addi	s3,s5,344
    80004f88:	4641                	li	a2,16
    80004f8a:	df843583          	ld	a1,-520(s0)
    80004f8e:	854e                	mv	a0,s3
    80004f90:	ffffc097          	auipc	ra,0xffffc
    80004f94:	efc080e7          	jalr	-260(ra) # 80000e8c <safestrcpy>
  oldpagetable = p->pagetable;
    80004f98:	050ab503          	ld	a0,80(s5)
  p->pagetable = pagetable;
    80004f9c:	056ab823          	sd	s6,80(s5)
  p->sz = sz;
    80004fa0:	e0843783          	ld	a5,-504(s0)
    80004fa4:	04fab423          	sd	a5,72(s5)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    80004fa8:	058ab783          	ld	a5,88(s5)
    80004fac:	e6843703          	ld	a4,-408(s0)
    80004fb0:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    80004fb2:	058ab783          	ld	a5,88(s5)
    80004fb6:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80004fba:	85e6                	mv	a1,s9
    80004fbc:	ffffd097          	auipc	ra,0xffffd
    80004fc0:	bc8080e7          	jalr	-1080(ra) # 80001b84 <proc_freepagetable>
  if (strncmp(p->name, "vm-", 3) == 0) {
    80004fc4:	460d                	li	a2,3
    80004fc6:	00003597          	auipc	a1,0x3
    80004fca:	23a58593          	addi	a1,a1,570 # 80008200 <digits+0x1c0>
    80004fce:	854e                	mv	a0,s3
    80004fd0:	ffffc097          	auipc	ra,0xffffc
    80004fd4:	e44080e7          	jalr	-444(ra) # 80000e14 <strncmp>
    80004fd8:	c501                	beqz	a0,80004fe0 <exec+0x37e>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80004fda:	0004851b          	sext.w	a0,s1
    80004fde:	bb31                	j	80004cfa <exec+0x98>
    if((sz1 = uvmalloc(pagetable, memaddr, memaddr + 1024*PGSIZE, PTE_W)) == 0) {
    80004fe0:	4691                	li	a3,4
    80004fe2:	20100613          	li	a2,513
    80004fe6:	065a                	slli	a2,a2,0x16
    80004fe8:	4585                	li	a1,1
    80004fea:	05fe                	slli	a1,a1,0x1f
    80004fec:	855a                	mv	a0,s6
    80004fee:	ffffc097          	auipc	ra,0xffffc
    80004ff2:	49a080e7          	jalr	1178(ra) # 80001488 <uvmalloc>
    80004ff6:	cd19                	beqz	a0,80005014 <exec+0x3b2>
    printf("Created a VM process and allocated memory region (%p - %p).\n", memaddr, memaddr + 1024*PGSIZE);
    80004ff8:	20100613          	li	a2,513
    80004ffc:	065a                	slli	a2,a2,0x16
    80004ffe:	4585                	li	a1,1
    80005000:	05fe                	slli	a1,a1,0x1f
    80005002:	00003517          	auipc	a0,0x3
    80005006:	73e50513          	addi	a0,a0,1854 # 80008740 <syscalls+0x2d8>
    8000500a:	ffffb097          	auipc	ra,0xffffb
    8000500e:	580080e7          	jalr	1408(ra) # 8000058a <printf>
    80005012:	b7e1                	j	80004fda <exec+0x378>
      printf("Error: could not allocate memory at 0x80000000 for VM.\n");
    80005014:	00003517          	auipc	a0,0x3
    80005018:	6f450513          	addi	a0,a0,1780 # 80008708 <syscalls+0x2a0>
    8000501c:	ffffb097          	auipc	ra,0xffffb
    80005020:	56e080e7          	jalr	1390(ra) # 8000058a <printf>
  sz = sz1;
    80005024:	e0843983          	ld	s3,-504(s0)
      goto bad;
    80005028:	b5a5                	j	80004e90 <exec+0x22e>
    8000502a:	e1243423          	sd	s2,-504(s0)
    proc_freepagetable(pagetable, sz);
    8000502e:	e0843583          	ld	a1,-504(s0)
    80005032:	855a                	mv	a0,s6
    80005034:	ffffd097          	auipc	ra,0xffffd
    80005038:	b50080e7          	jalr	-1200(ra) # 80001b84 <proc_freepagetable>
  return -1;
    8000503c:	557d                	li	a0,-1
  if(ip){
    8000503e:	ca0a0ee3          	beqz	s4,80004cfa <exec+0x98>
    80005042:	b155                	j	80004ce6 <exec+0x84>
    80005044:	e1243423          	sd	s2,-504(s0)
    80005048:	b7dd                	j	8000502e <exec+0x3cc>
    8000504a:	e1243423          	sd	s2,-504(s0)
    8000504e:	b7c5                	j	8000502e <exec+0x3cc>
    80005050:	e1243423          	sd	s2,-504(s0)
    80005054:	bfe9                	j	8000502e <exec+0x3cc>
    80005056:	e1243423          	sd	s2,-504(s0)
    8000505a:	bfd1                	j	8000502e <exec+0x3cc>
  ip = 0;
    8000505c:	4a01                	li	s4,0
    8000505e:	bfc1                	j	8000502e <exec+0x3cc>
    80005060:	4a01                	li	s4,0
  if(pagetable)
    80005062:	b7f1                	j	8000502e <exec+0x3cc>
  sz = sz1;
    80005064:	e0843983          	ld	s3,-504(s0)
    80005068:	b525                	j	80004e90 <exec+0x22e>

000000008000506a <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    8000506a:	7179                	addi	sp,sp,-48
    8000506c:	f406                	sd	ra,40(sp)
    8000506e:	f022                	sd	s0,32(sp)
    80005070:	ec26                	sd	s1,24(sp)
    80005072:	e84a                	sd	s2,16(sp)
    80005074:	1800                	addi	s0,sp,48
    80005076:	892e                	mv	s2,a1
    80005078:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    8000507a:	fdc40593          	addi	a1,s0,-36
    8000507e:	ffffe097          	auipc	ra,0xffffe
    80005082:	ba2080e7          	jalr	-1118(ra) # 80002c20 <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80005086:	fdc42703          	lw	a4,-36(s0)
    8000508a:	47bd                	li	a5,15
    8000508c:	02e7eb63          	bltu	a5,a4,800050c2 <argfd+0x58>
    80005090:	ffffd097          	auipc	ra,0xffffd
    80005094:	994080e7          	jalr	-1644(ra) # 80001a24 <myproc>
    80005098:	fdc42703          	lw	a4,-36(s0)
    8000509c:	01a70793          	addi	a5,a4,26
    800050a0:	078e                	slli	a5,a5,0x3
    800050a2:	953e                	add	a0,a0,a5
    800050a4:	611c                	ld	a5,0(a0)
    800050a6:	c385                	beqz	a5,800050c6 <argfd+0x5c>
    return -1;
  if(pfd)
    800050a8:	00090463          	beqz	s2,800050b0 <argfd+0x46>
    *pfd = fd;
    800050ac:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    800050b0:	4501                	li	a0,0
  if(pf)
    800050b2:	c091                	beqz	s1,800050b6 <argfd+0x4c>
    *pf = f;
    800050b4:	e09c                	sd	a5,0(s1)
}
    800050b6:	70a2                	ld	ra,40(sp)
    800050b8:	7402                	ld	s0,32(sp)
    800050ba:	64e2                	ld	s1,24(sp)
    800050bc:	6942                	ld	s2,16(sp)
    800050be:	6145                	addi	sp,sp,48
    800050c0:	8082                	ret
    return -1;
    800050c2:	557d                	li	a0,-1
    800050c4:	bfcd                	j	800050b6 <argfd+0x4c>
    800050c6:	557d                	li	a0,-1
    800050c8:	b7fd                	j	800050b6 <argfd+0x4c>

00000000800050ca <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    800050ca:	1101                	addi	sp,sp,-32
    800050cc:	ec06                	sd	ra,24(sp)
    800050ce:	e822                	sd	s0,16(sp)
    800050d0:	e426                	sd	s1,8(sp)
    800050d2:	1000                	addi	s0,sp,32
    800050d4:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    800050d6:	ffffd097          	auipc	ra,0xffffd
    800050da:	94e080e7          	jalr	-1714(ra) # 80001a24 <myproc>
    800050de:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    800050e0:	0d050793          	addi	a5,a0,208
    800050e4:	4501                	li	a0,0
    800050e6:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    800050e8:	6398                	ld	a4,0(a5)
    800050ea:	cb19                	beqz	a4,80005100 <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    800050ec:	2505                	addiw	a0,a0,1
    800050ee:	07a1                	addi	a5,a5,8
    800050f0:	fed51ce3          	bne	a0,a3,800050e8 <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    800050f4:	557d                	li	a0,-1
}
    800050f6:	60e2                	ld	ra,24(sp)
    800050f8:	6442                	ld	s0,16(sp)
    800050fa:	64a2                	ld	s1,8(sp)
    800050fc:	6105                	addi	sp,sp,32
    800050fe:	8082                	ret
      p->ofile[fd] = f;
    80005100:	01a50793          	addi	a5,a0,26
    80005104:	078e                	slli	a5,a5,0x3
    80005106:	963e                	add	a2,a2,a5
    80005108:	e204                	sd	s1,0(a2)
      return fd;
    8000510a:	b7f5                	j	800050f6 <fdalloc+0x2c>

000000008000510c <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    8000510c:	715d                	addi	sp,sp,-80
    8000510e:	e486                	sd	ra,72(sp)
    80005110:	e0a2                	sd	s0,64(sp)
    80005112:	fc26                	sd	s1,56(sp)
    80005114:	f84a                	sd	s2,48(sp)
    80005116:	f44e                	sd	s3,40(sp)
    80005118:	f052                	sd	s4,32(sp)
    8000511a:	ec56                	sd	s5,24(sp)
    8000511c:	e85a                	sd	s6,16(sp)
    8000511e:	0880                	addi	s0,sp,80
    80005120:	8b2e                	mv	s6,a1
    80005122:	89b2                	mv	s3,a2
    80005124:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80005126:	fb040593          	addi	a1,s0,-80
    8000512a:	fffff097          	auipc	ra,0xfffff
    8000512e:	e1c080e7          	jalr	-484(ra) # 80003f46 <nameiparent>
    80005132:	84aa                	mv	s1,a0
    80005134:	14050b63          	beqz	a0,8000528a <create+0x17e>
    return 0;

  ilock(dp);
    80005138:	ffffe097          	auipc	ra,0xffffe
    8000513c:	64a080e7          	jalr	1610(ra) # 80003782 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    80005140:	4601                	li	a2,0
    80005142:	fb040593          	addi	a1,s0,-80
    80005146:	8526                	mv	a0,s1
    80005148:	fffff097          	auipc	ra,0xfffff
    8000514c:	b1e080e7          	jalr	-1250(ra) # 80003c66 <dirlookup>
    80005150:	8aaa                	mv	s5,a0
    80005152:	c921                	beqz	a0,800051a2 <create+0x96>
    iunlockput(dp);
    80005154:	8526                	mv	a0,s1
    80005156:	fffff097          	auipc	ra,0xfffff
    8000515a:	88e080e7          	jalr	-1906(ra) # 800039e4 <iunlockput>
    ilock(ip);
    8000515e:	8556                	mv	a0,s5
    80005160:	ffffe097          	auipc	ra,0xffffe
    80005164:	622080e7          	jalr	1570(ra) # 80003782 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80005168:	4789                	li	a5,2
    8000516a:	02fb1563          	bne	s6,a5,80005194 <create+0x88>
    8000516e:	044ad783          	lhu	a5,68(s5)
    80005172:	37f9                	addiw	a5,a5,-2
    80005174:	17c2                	slli	a5,a5,0x30
    80005176:	93c1                	srli	a5,a5,0x30
    80005178:	4705                	li	a4,1
    8000517a:	00f76d63          	bltu	a4,a5,80005194 <create+0x88>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    8000517e:	8556                	mv	a0,s5
    80005180:	60a6                	ld	ra,72(sp)
    80005182:	6406                	ld	s0,64(sp)
    80005184:	74e2                	ld	s1,56(sp)
    80005186:	7942                	ld	s2,48(sp)
    80005188:	79a2                	ld	s3,40(sp)
    8000518a:	7a02                	ld	s4,32(sp)
    8000518c:	6ae2                	ld	s5,24(sp)
    8000518e:	6b42                	ld	s6,16(sp)
    80005190:	6161                	addi	sp,sp,80
    80005192:	8082                	ret
    iunlockput(ip);
    80005194:	8556                	mv	a0,s5
    80005196:	fffff097          	auipc	ra,0xfffff
    8000519a:	84e080e7          	jalr	-1970(ra) # 800039e4 <iunlockput>
    return 0;
    8000519e:	4a81                	li	s5,0
    800051a0:	bff9                	j	8000517e <create+0x72>
  if((ip = ialloc(dp->dev, type)) == 0){
    800051a2:	85da                	mv	a1,s6
    800051a4:	4088                	lw	a0,0(s1)
    800051a6:	ffffe097          	auipc	ra,0xffffe
    800051aa:	444080e7          	jalr	1092(ra) # 800035ea <ialloc>
    800051ae:	8a2a                	mv	s4,a0
    800051b0:	c529                	beqz	a0,800051fa <create+0xee>
  ilock(ip);
    800051b2:	ffffe097          	auipc	ra,0xffffe
    800051b6:	5d0080e7          	jalr	1488(ra) # 80003782 <ilock>
  ip->major = major;
    800051ba:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    800051be:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    800051c2:	4905                	li	s2,1
    800051c4:	052a1523          	sh	s2,74(s4)
  iupdate(ip);
    800051c8:	8552                	mv	a0,s4
    800051ca:	ffffe097          	auipc	ra,0xffffe
    800051ce:	4ec080e7          	jalr	1260(ra) # 800036b6 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    800051d2:	032b0b63          	beq	s6,s2,80005208 <create+0xfc>
  if(dirlink(dp, name, ip->inum) < 0)
    800051d6:	004a2603          	lw	a2,4(s4)
    800051da:	fb040593          	addi	a1,s0,-80
    800051de:	8526                	mv	a0,s1
    800051e0:	fffff097          	auipc	ra,0xfffff
    800051e4:	c96080e7          	jalr	-874(ra) # 80003e76 <dirlink>
    800051e8:	06054f63          	bltz	a0,80005266 <create+0x15a>
  iunlockput(dp);
    800051ec:	8526                	mv	a0,s1
    800051ee:	ffffe097          	auipc	ra,0xffffe
    800051f2:	7f6080e7          	jalr	2038(ra) # 800039e4 <iunlockput>
  return ip;
    800051f6:	8ad2                	mv	s5,s4
    800051f8:	b759                	j	8000517e <create+0x72>
    iunlockput(dp);
    800051fa:	8526                	mv	a0,s1
    800051fc:	ffffe097          	auipc	ra,0xffffe
    80005200:	7e8080e7          	jalr	2024(ra) # 800039e4 <iunlockput>
    return 0;
    80005204:	8ad2                	mv	s5,s4
    80005206:	bfa5                	j	8000517e <create+0x72>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80005208:	004a2603          	lw	a2,4(s4)
    8000520c:	00003597          	auipc	a1,0x3
    80005210:	57458593          	addi	a1,a1,1396 # 80008780 <syscalls+0x318>
    80005214:	8552                	mv	a0,s4
    80005216:	fffff097          	auipc	ra,0xfffff
    8000521a:	c60080e7          	jalr	-928(ra) # 80003e76 <dirlink>
    8000521e:	04054463          	bltz	a0,80005266 <create+0x15a>
    80005222:	40d0                	lw	a2,4(s1)
    80005224:	00003597          	auipc	a1,0x3
    80005228:	56458593          	addi	a1,a1,1380 # 80008788 <syscalls+0x320>
    8000522c:	8552                	mv	a0,s4
    8000522e:	fffff097          	auipc	ra,0xfffff
    80005232:	c48080e7          	jalr	-952(ra) # 80003e76 <dirlink>
    80005236:	02054863          	bltz	a0,80005266 <create+0x15a>
  if(dirlink(dp, name, ip->inum) < 0)
    8000523a:	004a2603          	lw	a2,4(s4)
    8000523e:	fb040593          	addi	a1,s0,-80
    80005242:	8526                	mv	a0,s1
    80005244:	fffff097          	auipc	ra,0xfffff
    80005248:	c32080e7          	jalr	-974(ra) # 80003e76 <dirlink>
    8000524c:	00054d63          	bltz	a0,80005266 <create+0x15a>
    dp->nlink++;  // for ".."
    80005250:	04a4d783          	lhu	a5,74(s1)
    80005254:	2785                	addiw	a5,a5,1
    80005256:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    8000525a:	8526                	mv	a0,s1
    8000525c:	ffffe097          	auipc	ra,0xffffe
    80005260:	45a080e7          	jalr	1114(ra) # 800036b6 <iupdate>
    80005264:	b761                	j	800051ec <create+0xe0>
  ip->nlink = 0;
    80005266:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    8000526a:	8552                	mv	a0,s4
    8000526c:	ffffe097          	auipc	ra,0xffffe
    80005270:	44a080e7          	jalr	1098(ra) # 800036b6 <iupdate>
  iunlockput(ip);
    80005274:	8552                	mv	a0,s4
    80005276:	ffffe097          	auipc	ra,0xffffe
    8000527a:	76e080e7          	jalr	1902(ra) # 800039e4 <iunlockput>
  iunlockput(dp);
    8000527e:	8526                	mv	a0,s1
    80005280:	ffffe097          	auipc	ra,0xffffe
    80005284:	764080e7          	jalr	1892(ra) # 800039e4 <iunlockput>
  return 0;
    80005288:	bddd                	j	8000517e <create+0x72>
    return 0;
    8000528a:	8aaa                	mv	s5,a0
    8000528c:	bdcd                	j	8000517e <create+0x72>

000000008000528e <sys_dup>:
{
    8000528e:	7179                	addi	sp,sp,-48
    80005290:	f406                	sd	ra,40(sp)
    80005292:	f022                	sd	s0,32(sp)
    80005294:	ec26                	sd	s1,24(sp)
    80005296:	e84a                	sd	s2,16(sp)
    80005298:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    8000529a:	fd840613          	addi	a2,s0,-40
    8000529e:	4581                	li	a1,0
    800052a0:	4501                	li	a0,0
    800052a2:	00000097          	auipc	ra,0x0
    800052a6:	dc8080e7          	jalr	-568(ra) # 8000506a <argfd>
    return -1;
    800052aa:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    800052ac:	02054363          	bltz	a0,800052d2 <sys_dup+0x44>
  if((fd=fdalloc(f)) < 0)
    800052b0:	fd843903          	ld	s2,-40(s0)
    800052b4:	854a                	mv	a0,s2
    800052b6:	00000097          	auipc	ra,0x0
    800052ba:	e14080e7          	jalr	-492(ra) # 800050ca <fdalloc>
    800052be:	84aa                	mv	s1,a0
    return -1;
    800052c0:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    800052c2:	00054863          	bltz	a0,800052d2 <sys_dup+0x44>
  filedup(f);
    800052c6:	854a                	mv	a0,s2
    800052c8:	fffff097          	auipc	ra,0xfffff
    800052cc:	2d2080e7          	jalr	722(ra) # 8000459a <filedup>
  return fd;
    800052d0:	87a6                	mv	a5,s1
}
    800052d2:	853e                	mv	a0,a5
    800052d4:	70a2                	ld	ra,40(sp)
    800052d6:	7402                	ld	s0,32(sp)
    800052d8:	64e2                	ld	s1,24(sp)
    800052da:	6942                	ld	s2,16(sp)
    800052dc:	6145                	addi	sp,sp,48
    800052de:	8082                	ret

00000000800052e0 <sys_read>:
{
    800052e0:	7179                	addi	sp,sp,-48
    800052e2:	f406                	sd	ra,40(sp)
    800052e4:	f022                	sd	s0,32(sp)
    800052e6:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    800052e8:	fd840593          	addi	a1,s0,-40
    800052ec:	4505                	li	a0,1
    800052ee:	ffffe097          	auipc	ra,0xffffe
    800052f2:	952080e7          	jalr	-1710(ra) # 80002c40 <argaddr>
  argint(2, &n);
    800052f6:	fe440593          	addi	a1,s0,-28
    800052fa:	4509                	li	a0,2
    800052fc:	ffffe097          	auipc	ra,0xffffe
    80005300:	924080e7          	jalr	-1756(ra) # 80002c20 <argint>
  if(argfd(0, 0, &f) < 0)
    80005304:	fe840613          	addi	a2,s0,-24
    80005308:	4581                	li	a1,0
    8000530a:	4501                	li	a0,0
    8000530c:	00000097          	auipc	ra,0x0
    80005310:	d5e080e7          	jalr	-674(ra) # 8000506a <argfd>
    80005314:	87aa                	mv	a5,a0
    return -1;
    80005316:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005318:	0007cc63          	bltz	a5,80005330 <sys_read+0x50>
  return fileread(f, p, n);
    8000531c:	fe442603          	lw	a2,-28(s0)
    80005320:	fd843583          	ld	a1,-40(s0)
    80005324:	fe843503          	ld	a0,-24(s0)
    80005328:	fffff097          	auipc	ra,0xfffff
    8000532c:	3fe080e7          	jalr	1022(ra) # 80004726 <fileread>
}
    80005330:	70a2                	ld	ra,40(sp)
    80005332:	7402                	ld	s0,32(sp)
    80005334:	6145                	addi	sp,sp,48
    80005336:	8082                	ret

0000000080005338 <sys_write>:
{
    80005338:	7179                	addi	sp,sp,-48
    8000533a:	f406                	sd	ra,40(sp)
    8000533c:	f022                	sd	s0,32(sp)
    8000533e:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80005340:	fd840593          	addi	a1,s0,-40
    80005344:	4505                	li	a0,1
    80005346:	ffffe097          	auipc	ra,0xffffe
    8000534a:	8fa080e7          	jalr	-1798(ra) # 80002c40 <argaddr>
  argint(2, &n);
    8000534e:	fe440593          	addi	a1,s0,-28
    80005352:	4509                	li	a0,2
    80005354:	ffffe097          	auipc	ra,0xffffe
    80005358:	8cc080e7          	jalr	-1844(ra) # 80002c20 <argint>
  if(argfd(0, 0, &f) < 0)
    8000535c:	fe840613          	addi	a2,s0,-24
    80005360:	4581                	li	a1,0
    80005362:	4501                	li	a0,0
    80005364:	00000097          	auipc	ra,0x0
    80005368:	d06080e7          	jalr	-762(ra) # 8000506a <argfd>
    8000536c:	87aa                	mv	a5,a0
    return -1;
    8000536e:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005370:	0007cc63          	bltz	a5,80005388 <sys_write+0x50>
  return filewrite(f, p, n);
    80005374:	fe442603          	lw	a2,-28(s0)
    80005378:	fd843583          	ld	a1,-40(s0)
    8000537c:	fe843503          	ld	a0,-24(s0)
    80005380:	fffff097          	auipc	ra,0xfffff
    80005384:	468080e7          	jalr	1128(ra) # 800047e8 <filewrite>
}
    80005388:	70a2                	ld	ra,40(sp)
    8000538a:	7402                	ld	s0,32(sp)
    8000538c:	6145                	addi	sp,sp,48
    8000538e:	8082                	ret

0000000080005390 <sys_close>:
{
    80005390:	1101                	addi	sp,sp,-32
    80005392:	ec06                	sd	ra,24(sp)
    80005394:	e822                	sd	s0,16(sp)
    80005396:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    80005398:	fe040613          	addi	a2,s0,-32
    8000539c:	fec40593          	addi	a1,s0,-20
    800053a0:	4501                	li	a0,0
    800053a2:	00000097          	auipc	ra,0x0
    800053a6:	cc8080e7          	jalr	-824(ra) # 8000506a <argfd>
    return -1;
    800053aa:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    800053ac:	02054463          	bltz	a0,800053d4 <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    800053b0:	ffffc097          	auipc	ra,0xffffc
    800053b4:	674080e7          	jalr	1652(ra) # 80001a24 <myproc>
    800053b8:	fec42783          	lw	a5,-20(s0)
    800053bc:	07e9                	addi	a5,a5,26
    800053be:	078e                	slli	a5,a5,0x3
    800053c0:	953e                	add	a0,a0,a5
    800053c2:	00053023          	sd	zero,0(a0)
  fileclose(f);
    800053c6:	fe043503          	ld	a0,-32(s0)
    800053ca:	fffff097          	auipc	ra,0xfffff
    800053ce:	222080e7          	jalr	546(ra) # 800045ec <fileclose>
  return 0;
    800053d2:	4781                	li	a5,0
}
    800053d4:	853e                	mv	a0,a5
    800053d6:	60e2                	ld	ra,24(sp)
    800053d8:	6442                	ld	s0,16(sp)
    800053da:	6105                	addi	sp,sp,32
    800053dc:	8082                	ret

00000000800053de <sys_fstat>:
{
    800053de:	1101                	addi	sp,sp,-32
    800053e0:	ec06                	sd	ra,24(sp)
    800053e2:	e822                	sd	s0,16(sp)
    800053e4:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    800053e6:	fe040593          	addi	a1,s0,-32
    800053ea:	4505                	li	a0,1
    800053ec:	ffffe097          	auipc	ra,0xffffe
    800053f0:	854080e7          	jalr	-1964(ra) # 80002c40 <argaddr>
  if(argfd(0, 0, &f) < 0)
    800053f4:	fe840613          	addi	a2,s0,-24
    800053f8:	4581                	li	a1,0
    800053fa:	4501                	li	a0,0
    800053fc:	00000097          	auipc	ra,0x0
    80005400:	c6e080e7          	jalr	-914(ra) # 8000506a <argfd>
    80005404:	87aa                	mv	a5,a0
    return -1;
    80005406:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005408:	0007ca63          	bltz	a5,8000541c <sys_fstat+0x3e>
  return filestat(f, st);
    8000540c:	fe043583          	ld	a1,-32(s0)
    80005410:	fe843503          	ld	a0,-24(s0)
    80005414:	fffff097          	auipc	ra,0xfffff
    80005418:	2a0080e7          	jalr	672(ra) # 800046b4 <filestat>
}
    8000541c:	60e2                	ld	ra,24(sp)
    8000541e:	6442                	ld	s0,16(sp)
    80005420:	6105                	addi	sp,sp,32
    80005422:	8082                	ret

0000000080005424 <sys_link>:
{
    80005424:	7169                	addi	sp,sp,-304
    80005426:	f606                	sd	ra,296(sp)
    80005428:	f222                	sd	s0,288(sp)
    8000542a:	ee26                	sd	s1,280(sp)
    8000542c:	ea4a                	sd	s2,272(sp)
    8000542e:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005430:	08000613          	li	a2,128
    80005434:	ed040593          	addi	a1,s0,-304
    80005438:	4501                	li	a0,0
    8000543a:	ffffe097          	auipc	ra,0xffffe
    8000543e:	826080e7          	jalr	-2010(ra) # 80002c60 <argstr>
    return -1;
    80005442:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005444:	10054e63          	bltz	a0,80005560 <sys_link+0x13c>
    80005448:	08000613          	li	a2,128
    8000544c:	f5040593          	addi	a1,s0,-176
    80005450:	4505                	li	a0,1
    80005452:	ffffe097          	auipc	ra,0xffffe
    80005456:	80e080e7          	jalr	-2034(ra) # 80002c60 <argstr>
    return -1;
    8000545a:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    8000545c:	10054263          	bltz	a0,80005560 <sys_link+0x13c>
  begin_op();
    80005460:	fffff097          	auipc	ra,0xfffff
    80005464:	cc8080e7          	jalr	-824(ra) # 80004128 <begin_op>
  if((ip = namei(old)) == 0){
    80005468:	ed040513          	addi	a0,s0,-304
    8000546c:	fffff097          	auipc	ra,0xfffff
    80005470:	abc080e7          	jalr	-1348(ra) # 80003f28 <namei>
    80005474:	84aa                	mv	s1,a0
    80005476:	c551                	beqz	a0,80005502 <sys_link+0xde>
  ilock(ip);
    80005478:	ffffe097          	auipc	ra,0xffffe
    8000547c:	30a080e7          	jalr	778(ra) # 80003782 <ilock>
  if(ip->type == T_DIR){
    80005480:	04449703          	lh	a4,68(s1)
    80005484:	4785                	li	a5,1
    80005486:	08f70463          	beq	a4,a5,8000550e <sys_link+0xea>
  ip->nlink++;
    8000548a:	04a4d783          	lhu	a5,74(s1)
    8000548e:	2785                	addiw	a5,a5,1
    80005490:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005494:	8526                	mv	a0,s1
    80005496:	ffffe097          	auipc	ra,0xffffe
    8000549a:	220080e7          	jalr	544(ra) # 800036b6 <iupdate>
  iunlock(ip);
    8000549e:	8526                	mv	a0,s1
    800054a0:	ffffe097          	auipc	ra,0xffffe
    800054a4:	3a4080e7          	jalr	932(ra) # 80003844 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    800054a8:	fd040593          	addi	a1,s0,-48
    800054ac:	f5040513          	addi	a0,s0,-176
    800054b0:	fffff097          	auipc	ra,0xfffff
    800054b4:	a96080e7          	jalr	-1386(ra) # 80003f46 <nameiparent>
    800054b8:	892a                	mv	s2,a0
    800054ba:	c935                	beqz	a0,8000552e <sys_link+0x10a>
  ilock(dp);
    800054bc:	ffffe097          	auipc	ra,0xffffe
    800054c0:	2c6080e7          	jalr	710(ra) # 80003782 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    800054c4:	00092703          	lw	a4,0(s2)
    800054c8:	409c                	lw	a5,0(s1)
    800054ca:	04f71d63          	bne	a4,a5,80005524 <sys_link+0x100>
    800054ce:	40d0                	lw	a2,4(s1)
    800054d0:	fd040593          	addi	a1,s0,-48
    800054d4:	854a                	mv	a0,s2
    800054d6:	fffff097          	auipc	ra,0xfffff
    800054da:	9a0080e7          	jalr	-1632(ra) # 80003e76 <dirlink>
    800054de:	04054363          	bltz	a0,80005524 <sys_link+0x100>
  iunlockput(dp);
    800054e2:	854a                	mv	a0,s2
    800054e4:	ffffe097          	auipc	ra,0xffffe
    800054e8:	500080e7          	jalr	1280(ra) # 800039e4 <iunlockput>
  iput(ip);
    800054ec:	8526                	mv	a0,s1
    800054ee:	ffffe097          	auipc	ra,0xffffe
    800054f2:	44e080e7          	jalr	1102(ra) # 8000393c <iput>
  end_op();
    800054f6:	fffff097          	auipc	ra,0xfffff
    800054fa:	cac080e7          	jalr	-852(ra) # 800041a2 <end_op>
  return 0;
    800054fe:	4781                	li	a5,0
    80005500:	a085                	j	80005560 <sys_link+0x13c>
    end_op();
    80005502:	fffff097          	auipc	ra,0xfffff
    80005506:	ca0080e7          	jalr	-864(ra) # 800041a2 <end_op>
    return -1;
    8000550a:	57fd                	li	a5,-1
    8000550c:	a891                	j	80005560 <sys_link+0x13c>
    iunlockput(ip);
    8000550e:	8526                	mv	a0,s1
    80005510:	ffffe097          	auipc	ra,0xffffe
    80005514:	4d4080e7          	jalr	1236(ra) # 800039e4 <iunlockput>
    end_op();
    80005518:	fffff097          	auipc	ra,0xfffff
    8000551c:	c8a080e7          	jalr	-886(ra) # 800041a2 <end_op>
    return -1;
    80005520:	57fd                	li	a5,-1
    80005522:	a83d                	j	80005560 <sys_link+0x13c>
    iunlockput(dp);
    80005524:	854a                	mv	a0,s2
    80005526:	ffffe097          	auipc	ra,0xffffe
    8000552a:	4be080e7          	jalr	1214(ra) # 800039e4 <iunlockput>
  ilock(ip);
    8000552e:	8526                	mv	a0,s1
    80005530:	ffffe097          	auipc	ra,0xffffe
    80005534:	252080e7          	jalr	594(ra) # 80003782 <ilock>
  ip->nlink--;
    80005538:	04a4d783          	lhu	a5,74(s1)
    8000553c:	37fd                	addiw	a5,a5,-1
    8000553e:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005542:	8526                	mv	a0,s1
    80005544:	ffffe097          	auipc	ra,0xffffe
    80005548:	172080e7          	jalr	370(ra) # 800036b6 <iupdate>
  iunlockput(ip);
    8000554c:	8526                	mv	a0,s1
    8000554e:	ffffe097          	auipc	ra,0xffffe
    80005552:	496080e7          	jalr	1174(ra) # 800039e4 <iunlockput>
  end_op();
    80005556:	fffff097          	auipc	ra,0xfffff
    8000555a:	c4c080e7          	jalr	-948(ra) # 800041a2 <end_op>
  return -1;
    8000555e:	57fd                	li	a5,-1
}
    80005560:	853e                	mv	a0,a5
    80005562:	70b2                	ld	ra,296(sp)
    80005564:	7412                	ld	s0,288(sp)
    80005566:	64f2                	ld	s1,280(sp)
    80005568:	6952                	ld	s2,272(sp)
    8000556a:	6155                	addi	sp,sp,304
    8000556c:	8082                	ret

000000008000556e <sys_unlink>:
{
    8000556e:	7151                	addi	sp,sp,-240
    80005570:	f586                	sd	ra,232(sp)
    80005572:	f1a2                	sd	s0,224(sp)
    80005574:	eda6                	sd	s1,216(sp)
    80005576:	e9ca                	sd	s2,208(sp)
    80005578:	e5ce                	sd	s3,200(sp)
    8000557a:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    8000557c:	08000613          	li	a2,128
    80005580:	f3040593          	addi	a1,s0,-208
    80005584:	4501                	li	a0,0
    80005586:	ffffd097          	auipc	ra,0xffffd
    8000558a:	6da080e7          	jalr	1754(ra) # 80002c60 <argstr>
    8000558e:	18054163          	bltz	a0,80005710 <sys_unlink+0x1a2>
  begin_op();
    80005592:	fffff097          	auipc	ra,0xfffff
    80005596:	b96080e7          	jalr	-1130(ra) # 80004128 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    8000559a:	fb040593          	addi	a1,s0,-80
    8000559e:	f3040513          	addi	a0,s0,-208
    800055a2:	fffff097          	auipc	ra,0xfffff
    800055a6:	9a4080e7          	jalr	-1628(ra) # 80003f46 <nameiparent>
    800055aa:	84aa                	mv	s1,a0
    800055ac:	c979                	beqz	a0,80005682 <sys_unlink+0x114>
  ilock(dp);
    800055ae:	ffffe097          	auipc	ra,0xffffe
    800055b2:	1d4080e7          	jalr	468(ra) # 80003782 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    800055b6:	00003597          	auipc	a1,0x3
    800055ba:	1ca58593          	addi	a1,a1,458 # 80008780 <syscalls+0x318>
    800055be:	fb040513          	addi	a0,s0,-80
    800055c2:	ffffe097          	auipc	ra,0xffffe
    800055c6:	68a080e7          	jalr	1674(ra) # 80003c4c <namecmp>
    800055ca:	14050a63          	beqz	a0,8000571e <sys_unlink+0x1b0>
    800055ce:	00003597          	auipc	a1,0x3
    800055d2:	1ba58593          	addi	a1,a1,442 # 80008788 <syscalls+0x320>
    800055d6:	fb040513          	addi	a0,s0,-80
    800055da:	ffffe097          	auipc	ra,0xffffe
    800055de:	672080e7          	jalr	1650(ra) # 80003c4c <namecmp>
    800055e2:	12050e63          	beqz	a0,8000571e <sys_unlink+0x1b0>
  if((ip = dirlookup(dp, name, &off)) == 0)
    800055e6:	f2c40613          	addi	a2,s0,-212
    800055ea:	fb040593          	addi	a1,s0,-80
    800055ee:	8526                	mv	a0,s1
    800055f0:	ffffe097          	auipc	ra,0xffffe
    800055f4:	676080e7          	jalr	1654(ra) # 80003c66 <dirlookup>
    800055f8:	892a                	mv	s2,a0
    800055fa:	12050263          	beqz	a0,8000571e <sys_unlink+0x1b0>
  ilock(ip);
    800055fe:	ffffe097          	auipc	ra,0xffffe
    80005602:	184080e7          	jalr	388(ra) # 80003782 <ilock>
  if(ip->nlink < 1)
    80005606:	04a91783          	lh	a5,74(s2)
    8000560a:	08f05263          	blez	a5,8000568e <sys_unlink+0x120>
  if(ip->type == T_DIR && !isdirempty(ip)){
    8000560e:	04491703          	lh	a4,68(s2)
    80005612:	4785                	li	a5,1
    80005614:	08f70563          	beq	a4,a5,8000569e <sys_unlink+0x130>
  memset(&de, 0, sizeof(de));
    80005618:	4641                	li	a2,16
    8000561a:	4581                	li	a1,0
    8000561c:	fc040513          	addi	a0,s0,-64
    80005620:	ffffb097          	auipc	ra,0xffffb
    80005624:	724080e7          	jalr	1828(ra) # 80000d44 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005628:	4741                	li	a4,16
    8000562a:	f2c42683          	lw	a3,-212(s0)
    8000562e:	fc040613          	addi	a2,s0,-64
    80005632:	4581                	li	a1,0
    80005634:	8526                	mv	a0,s1
    80005636:	ffffe097          	auipc	ra,0xffffe
    8000563a:	4f8080e7          	jalr	1272(ra) # 80003b2e <writei>
    8000563e:	47c1                	li	a5,16
    80005640:	0af51563          	bne	a0,a5,800056ea <sys_unlink+0x17c>
  if(ip->type == T_DIR){
    80005644:	04491703          	lh	a4,68(s2)
    80005648:	4785                	li	a5,1
    8000564a:	0af70863          	beq	a4,a5,800056fa <sys_unlink+0x18c>
  iunlockput(dp);
    8000564e:	8526                	mv	a0,s1
    80005650:	ffffe097          	auipc	ra,0xffffe
    80005654:	394080e7          	jalr	916(ra) # 800039e4 <iunlockput>
  ip->nlink--;
    80005658:	04a95783          	lhu	a5,74(s2)
    8000565c:	37fd                	addiw	a5,a5,-1
    8000565e:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80005662:	854a                	mv	a0,s2
    80005664:	ffffe097          	auipc	ra,0xffffe
    80005668:	052080e7          	jalr	82(ra) # 800036b6 <iupdate>
  iunlockput(ip);
    8000566c:	854a                	mv	a0,s2
    8000566e:	ffffe097          	auipc	ra,0xffffe
    80005672:	376080e7          	jalr	886(ra) # 800039e4 <iunlockput>
  end_op();
    80005676:	fffff097          	auipc	ra,0xfffff
    8000567a:	b2c080e7          	jalr	-1236(ra) # 800041a2 <end_op>
  return 0;
    8000567e:	4501                	li	a0,0
    80005680:	a84d                	j	80005732 <sys_unlink+0x1c4>
    end_op();
    80005682:	fffff097          	auipc	ra,0xfffff
    80005686:	b20080e7          	jalr	-1248(ra) # 800041a2 <end_op>
    return -1;
    8000568a:	557d                	li	a0,-1
    8000568c:	a05d                	j	80005732 <sys_unlink+0x1c4>
    panic("unlink: nlink < 1");
    8000568e:	00003517          	auipc	a0,0x3
    80005692:	10250513          	addi	a0,a0,258 # 80008790 <syscalls+0x328>
    80005696:	ffffb097          	auipc	ra,0xffffb
    8000569a:	eaa080e7          	jalr	-342(ra) # 80000540 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    8000569e:	04c92703          	lw	a4,76(s2)
    800056a2:	02000793          	li	a5,32
    800056a6:	f6e7f9e3          	bgeu	a5,a4,80005618 <sys_unlink+0xaa>
    800056aa:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800056ae:	4741                	li	a4,16
    800056b0:	86ce                	mv	a3,s3
    800056b2:	f1840613          	addi	a2,s0,-232
    800056b6:	4581                	li	a1,0
    800056b8:	854a                	mv	a0,s2
    800056ba:	ffffe097          	auipc	ra,0xffffe
    800056be:	37c080e7          	jalr	892(ra) # 80003a36 <readi>
    800056c2:	47c1                	li	a5,16
    800056c4:	00f51b63          	bne	a0,a5,800056da <sys_unlink+0x16c>
    if(de.inum != 0)
    800056c8:	f1845783          	lhu	a5,-232(s0)
    800056cc:	e7a1                	bnez	a5,80005714 <sys_unlink+0x1a6>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    800056ce:	29c1                	addiw	s3,s3,16
    800056d0:	04c92783          	lw	a5,76(s2)
    800056d4:	fcf9ede3          	bltu	s3,a5,800056ae <sys_unlink+0x140>
    800056d8:	b781                	j	80005618 <sys_unlink+0xaa>
      panic("isdirempty: readi");
    800056da:	00003517          	auipc	a0,0x3
    800056de:	0ce50513          	addi	a0,a0,206 # 800087a8 <syscalls+0x340>
    800056e2:	ffffb097          	auipc	ra,0xffffb
    800056e6:	e5e080e7          	jalr	-418(ra) # 80000540 <panic>
    panic("unlink: writei");
    800056ea:	00003517          	auipc	a0,0x3
    800056ee:	0d650513          	addi	a0,a0,214 # 800087c0 <syscalls+0x358>
    800056f2:	ffffb097          	auipc	ra,0xffffb
    800056f6:	e4e080e7          	jalr	-434(ra) # 80000540 <panic>
    dp->nlink--;
    800056fa:	04a4d783          	lhu	a5,74(s1)
    800056fe:	37fd                	addiw	a5,a5,-1
    80005700:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005704:	8526                	mv	a0,s1
    80005706:	ffffe097          	auipc	ra,0xffffe
    8000570a:	fb0080e7          	jalr	-80(ra) # 800036b6 <iupdate>
    8000570e:	b781                	j	8000564e <sys_unlink+0xe0>
    return -1;
    80005710:	557d                	li	a0,-1
    80005712:	a005                	j	80005732 <sys_unlink+0x1c4>
    iunlockput(ip);
    80005714:	854a                	mv	a0,s2
    80005716:	ffffe097          	auipc	ra,0xffffe
    8000571a:	2ce080e7          	jalr	718(ra) # 800039e4 <iunlockput>
  iunlockput(dp);
    8000571e:	8526                	mv	a0,s1
    80005720:	ffffe097          	auipc	ra,0xffffe
    80005724:	2c4080e7          	jalr	708(ra) # 800039e4 <iunlockput>
  end_op();
    80005728:	fffff097          	auipc	ra,0xfffff
    8000572c:	a7a080e7          	jalr	-1414(ra) # 800041a2 <end_op>
  return -1;
    80005730:	557d                	li	a0,-1
}
    80005732:	70ae                	ld	ra,232(sp)
    80005734:	740e                	ld	s0,224(sp)
    80005736:	64ee                	ld	s1,216(sp)
    80005738:	694e                	ld	s2,208(sp)
    8000573a:	69ae                	ld	s3,200(sp)
    8000573c:	616d                	addi	sp,sp,240
    8000573e:	8082                	ret

0000000080005740 <sys_open>:

uint64
sys_open(void)
{
    80005740:	7131                	addi	sp,sp,-192
    80005742:	fd06                	sd	ra,184(sp)
    80005744:	f922                	sd	s0,176(sp)
    80005746:	f526                	sd	s1,168(sp)
    80005748:	f14a                	sd	s2,160(sp)
    8000574a:	ed4e                	sd	s3,152(sp)
    8000574c:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    8000574e:	f4c40593          	addi	a1,s0,-180
    80005752:	4505                	li	a0,1
    80005754:	ffffd097          	auipc	ra,0xffffd
    80005758:	4cc080e7          	jalr	1228(ra) # 80002c20 <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    8000575c:	08000613          	li	a2,128
    80005760:	f5040593          	addi	a1,s0,-176
    80005764:	4501                	li	a0,0
    80005766:	ffffd097          	auipc	ra,0xffffd
    8000576a:	4fa080e7          	jalr	1274(ra) # 80002c60 <argstr>
    8000576e:	87aa                	mv	a5,a0
    return -1;
    80005770:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005772:	0a07c863          	bltz	a5,80005822 <sys_open+0xe2>

  begin_op();
    80005776:	fffff097          	auipc	ra,0xfffff
    8000577a:	9b2080e7          	jalr	-1614(ra) # 80004128 <begin_op>

  if(omode & O_CREATE){
    8000577e:	f4c42783          	lw	a5,-180(s0)
    80005782:	2007f793          	andi	a5,a5,512
    80005786:	cbdd                	beqz	a5,8000583c <sys_open+0xfc>
    ip = create(path, T_FILE, 0, 0);
    80005788:	4681                	li	a3,0
    8000578a:	4601                	li	a2,0
    8000578c:	4589                	li	a1,2
    8000578e:	f5040513          	addi	a0,s0,-176
    80005792:	00000097          	auipc	ra,0x0
    80005796:	97a080e7          	jalr	-1670(ra) # 8000510c <create>
    8000579a:	84aa                	mv	s1,a0
    if(ip == 0){
    8000579c:	c951                	beqz	a0,80005830 <sys_open+0xf0>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    8000579e:	04449703          	lh	a4,68(s1)
    800057a2:	478d                	li	a5,3
    800057a4:	00f71763          	bne	a4,a5,800057b2 <sys_open+0x72>
    800057a8:	0464d703          	lhu	a4,70(s1)
    800057ac:	47a5                	li	a5,9
    800057ae:	0ce7ec63          	bltu	a5,a4,80005886 <sys_open+0x146>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    800057b2:	fffff097          	auipc	ra,0xfffff
    800057b6:	d7e080e7          	jalr	-642(ra) # 80004530 <filealloc>
    800057ba:	892a                	mv	s2,a0
    800057bc:	c56d                	beqz	a0,800058a6 <sys_open+0x166>
    800057be:	00000097          	auipc	ra,0x0
    800057c2:	90c080e7          	jalr	-1780(ra) # 800050ca <fdalloc>
    800057c6:	89aa                	mv	s3,a0
    800057c8:	0c054a63          	bltz	a0,8000589c <sys_open+0x15c>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    800057cc:	04449703          	lh	a4,68(s1)
    800057d0:	478d                	li	a5,3
    800057d2:	0ef70563          	beq	a4,a5,800058bc <sys_open+0x17c>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    800057d6:	4789                	li	a5,2
    800057d8:	00f92023          	sw	a5,0(s2)
    f->off = 0;
    800057dc:	02092023          	sw	zero,32(s2)
  }
  f->ip = ip;
    800057e0:	00993c23          	sd	s1,24(s2)
  f->readable = !(omode & O_WRONLY);
    800057e4:	f4c42783          	lw	a5,-180(s0)
    800057e8:	0017c713          	xori	a4,a5,1
    800057ec:	8b05                	andi	a4,a4,1
    800057ee:	00e90423          	sb	a4,8(s2)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    800057f2:	0037f713          	andi	a4,a5,3
    800057f6:	00e03733          	snez	a4,a4
    800057fa:	00e904a3          	sb	a4,9(s2)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    800057fe:	4007f793          	andi	a5,a5,1024
    80005802:	c791                	beqz	a5,8000580e <sys_open+0xce>
    80005804:	04449703          	lh	a4,68(s1)
    80005808:	4789                	li	a5,2
    8000580a:	0cf70063          	beq	a4,a5,800058ca <sys_open+0x18a>
    itrunc(ip);
  }

  iunlock(ip);
    8000580e:	8526                	mv	a0,s1
    80005810:	ffffe097          	auipc	ra,0xffffe
    80005814:	034080e7          	jalr	52(ra) # 80003844 <iunlock>
  end_op();
    80005818:	fffff097          	auipc	ra,0xfffff
    8000581c:	98a080e7          	jalr	-1654(ra) # 800041a2 <end_op>

  return fd;
    80005820:	854e                	mv	a0,s3
}
    80005822:	70ea                	ld	ra,184(sp)
    80005824:	744a                	ld	s0,176(sp)
    80005826:	74aa                	ld	s1,168(sp)
    80005828:	790a                	ld	s2,160(sp)
    8000582a:	69ea                	ld	s3,152(sp)
    8000582c:	6129                	addi	sp,sp,192
    8000582e:	8082                	ret
      end_op();
    80005830:	fffff097          	auipc	ra,0xfffff
    80005834:	972080e7          	jalr	-1678(ra) # 800041a2 <end_op>
      return -1;
    80005838:	557d                	li	a0,-1
    8000583a:	b7e5                	j	80005822 <sys_open+0xe2>
    if((ip = namei(path)) == 0){
    8000583c:	f5040513          	addi	a0,s0,-176
    80005840:	ffffe097          	auipc	ra,0xffffe
    80005844:	6e8080e7          	jalr	1768(ra) # 80003f28 <namei>
    80005848:	84aa                	mv	s1,a0
    8000584a:	c905                	beqz	a0,8000587a <sys_open+0x13a>
    ilock(ip);
    8000584c:	ffffe097          	auipc	ra,0xffffe
    80005850:	f36080e7          	jalr	-202(ra) # 80003782 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80005854:	04449703          	lh	a4,68(s1)
    80005858:	4785                	li	a5,1
    8000585a:	f4f712e3          	bne	a4,a5,8000579e <sys_open+0x5e>
    8000585e:	f4c42783          	lw	a5,-180(s0)
    80005862:	dba1                	beqz	a5,800057b2 <sys_open+0x72>
      iunlockput(ip);
    80005864:	8526                	mv	a0,s1
    80005866:	ffffe097          	auipc	ra,0xffffe
    8000586a:	17e080e7          	jalr	382(ra) # 800039e4 <iunlockput>
      end_op();
    8000586e:	fffff097          	auipc	ra,0xfffff
    80005872:	934080e7          	jalr	-1740(ra) # 800041a2 <end_op>
      return -1;
    80005876:	557d                	li	a0,-1
    80005878:	b76d                	j	80005822 <sys_open+0xe2>
      end_op();
    8000587a:	fffff097          	auipc	ra,0xfffff
    8000587e:	928080e7          	jalr	-1752(ra) # 800041a2 <end_op>
      return -1;
    80005882:	557d                	li	a0,-1
    80005884:	bf79                	j	80005822 <sys_open+0xe2>
    iunlockput(ip);
    80005886:	8526                	mv	a0,s1
    80005888:	ffffe097          	auipc	ra,0xffffe
    8000588c:	15c080e7          	jalr	348(ra) # 800039e4 <iunlockput>
    end_op();
    80005890:	fffff097          	auipc	ra,0xfffff
    80005894:	912080e7          	jalr	-1774(ra) # 800041a2 <end_op>
    return -1;
    80005898:	557d                	li	a0,-1
    8000589a:	b761                	j	80005822 <sys_open+0xe2>
      fileclose(f);
    8000589c:	854a                	mv	a0,s2
    8000589e:	fffff097          	auipc	ra,0xfffff
    800058a2:	d4e080e7          	jalr	-690(ra) # 800045ec <fileclose>
    iunlockput(ip);
    800058a6:	8526                	mv	a0,s1
    800058a8:	ffffe097          	auipc	ra,0xffffe
    800058ac:	13c080e7          	jalr	316(ra) # 800039e4 <iunlockput>
    end_op();
    800058b0:	fffff097          	auipc	ra,0xfffff
    800058b4:	8f2080e7          	jalr	-1806(ra) # 800041a2 <end_op>
    return -1;
    800058b8:	557d                	li	a0,-1
    800058ba:	b7a5                	j	80005822 <sys_open+0xe2>
    f->type = FD_DEVICE;
    800058bc:	00f92023          	sw	a5,0(s2)
    f->major = ip->major;
    800058c0:	04649783          	lh	a5,70(s1)
    800058c4:	02f91223          	sh	a5,36(s2)
    800058c8:	bf21                	j	800057e0 <sys_open+0xa0>
    itrunc(ip);
    800058ca:	8526                	mv	a0,s1
    800058cc:	ffffe097          	auipc	ra,0xffffe
    800058d0:	fc4080e7          	jalr	-60(ra) # 80003890 <itrunc>
    800058d4:	bf2d                	j	8000580e <sys_open+0xce>

00000000800058d6 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    800058d6:	7175                	addi	sp,sp,-144
    800058d8:	e506                	sd	ra,136(sp)
    800058da:	e122                	sd	s0,128(sp)
    800058dc:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    800058de:	fffff097          	auipc	ra,0xfffff
    800058e2:	84a080e7          	jalr	-1974(ra) # 80004128 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    800058e6:	08000613          	li	a2,128
    800058ea:	f7040593          	addi	a1,s0,-144
    800058ee:	4501                	li	a0,0
    800058f0:	ffffd097          	auipc	ra,0xffffd
    800058f4:	370080e7          	jalr	880(ra) # 80002c60 <argstr>
    800058f8:	02054963          	bltz	a0,8000592a <sys_mkdir+0x54>
    800058fc:	4681                	li	a3,0
    800058fe:	4601                	li	a2,0
    80005900:	4585                	li	a1,1
    80005902:	f7040513          	addi	a0,s0,-144
    80005906:	00000097          	auipc	ra,0x0
    8000590a:	806080e7          	jalr	-2042(ra) # 8000510c <create>
    8000590e:	cd11                	beqz	a0,8000592a <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005910:	ffffe097          	auipc	ra,0xffffe
    80005914:	0d4080e7          	jalr	212(ra) # 800039e4 <iunlockput>
  end_op();
    80005918:	fffff097          	auipc	ra,0xfffff
    8000591c:	88a080e7          	jalr	-1910(ra) # 800041a2 <end_op>
  return 0;
    80005920:	4501                	li	a0,0
}
    80005922:	60aa                	ld	ra,136(sp)
    80005924:	640a                	ld	s0,128(sp)
    80005926:	6149                	addi	sp,sp,144
    80005928:	8082                	ret
    end_op();
    8000592a:	fffff097          	auipc	ra,0xfffff
    8000592e:	878080e7          	jalr	-1928(ra) # 800041a2 <end_op>
    return -1;
    80005932:	557d                	li	a0,-1
    80005934:	b7fd                	j	80005922 <sys_mkdir+0x4c>

0000000080005936 <sys_mknod>:

uint64
sys_mknod(void)
{
    80005936:	7135                	addi	sp,sp,-160
    80005938:	ed06                	sd	ra,152(sp)
    8000593a:	e922                	sd	s0,144(sp)
    8000593c:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    8000593e:	ffffe097          	auipc	ra,0xffffe
    80005942:	7ea080e7          	jalr	2026(ra) # 80004128 <begin_op>
  argint(1, &major);
    80005946:	f6c40593          	addi	a1,s0,-148
    8000594a:	4505                	li	a0,1
    8000594c:	ffffd097          	auipc	ra,0xffffd
    80005950:	2d4080e7          	jalr	724(ra) # 80002c20 <argint>
  argint(2, &minor);
    80005954:	f6840593          	addi	a1,s0,-152
    80005958:	4509                	li	a0,2
    8000595a:	ffffd097          	auipc	ra,0xffffd
    8000595e:	2c6080e7          	jalr	710(ra) # 80002c20 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005962:	08000613          	li	a2,128
    80005966:	f7040593          	addi	a1,s0,-144
    8000596a:	4501                	li	a0,0
    8000596c:	ffffd097          	auipc	ra,0xffffd
    80005970:	2f4080e7          	jalr	756(ra) # 80002c60 <argstr>
    80005974:	02054b63          	bltz	a0,800059aa <sys_mknod+0x74>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80005978:	f6841683          	lh	a3,-152(s0)
    8000597c:	f6c41603          	lh	a2,-148(s0)
    80005980:	458d                	li	a1,3
    80005982:	f7040513          	addi	a0,s0,-144
    80005986:	fffff097          	auipc	ra,0xfffff
    8000598a:	786080e7          	jalr	1926(ra) # 8000510c <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    8000598e:	cd11                	beqz	a0,800059aa <sys_mknod+0x74>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005990:	ffffe097          	auipc	ra,0xffffe
    80005994:	054080e7          	jalr	84(ra) # 800039e4 <iunlockput>
  end_op();
    80005998:	fffff097          	auipc	ra,0xfffff
    8000599c:	80a080e7          	jalr	-2038(ra) # 800041a2 <end_op>
  return 0;
    800059a0:	4501                	li	a0,0
}
    800059a2:	60ea                	ld	ra,152(sp)
    800059a4:	644a                	ld	s0,144(sp)
    800059a6:	610d                	addi	sp,sp,160
    800059a8:	8082                	ret
    end_op();
    800059aa:	ffffe097          	auipc	ra,0xffffe
    800059ae:	7f8080e7          	jalr	2040(ra) # 800041a2 <end_op>
    return -1;
    800059b2:	557d                	li	a0,-1
    800059b4:	b7fd                	j	800059a2 <sys_mknod+0x6c>

00000000800059b6 <sys_chdir>:

uint64
sys_chdir(void)
{
    800059b6:	7135                	addi	sp,sp,-160
    800059b8:	ed06                	sd	ra,152(sp)
    800059ba:	e922                	sd	s0,144(sp)
    800059bc:	e526                	sd	s1,136(sp)
    800059be:	e14a                	sd	s2,128(sp)
    800059c0:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    800059c2:	ffffc097          	auipc	ra,0xffffc
    800059c6:	062080e7          	jalr	98(ra) # 80001a24 <myproc>
    800059ca:	892a                	mv	s2,a0
  
  begin_op();
    800059cc:	ffffe097          	auipc	ra,0xffffe
    800059d0:	75c080e7          	jalr	1884(ra) # 80004128 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    800059d4:	08000613          	li	a2,128
    800059d8:	f6040593          	addi	a1,s0,-160
    800059dc:	4501                	li	a0,0
    800059de:	ffffd097          	auipc	ra,0xffffd
    800059e2:	282080e7          	jalr	642(ra) # 80002c60 <argstr>
    800059e6:	04054b63          	bltz	a0,80005a3c <sys_chdir+0x86>
    800059ea:	f6040513          	addi	a0,s0,-160
    800059ee:	ffffe097          	auipc	ra,0xffffe
    800059f2:	53a080e7          	jalr	1338(ra) # 80003f28 <namei>
    800059f6:	84aa                	mv	s1,a0
    800059f8:	c131                	beqz	a0,80005a3c <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    800059fa:	ffffe097          	auipc	ra,0xffffe
    800059fe:	d88080e7          	jalr	-632(ra) # 80003782 <ilock>
  if(ip->type != T_DIR){
    80005a02:	04449703          	lh	a4,68(s1)
    80005a06:	4785                	li	a5,1
    80005a08:	04f71063          	bne	a4,a5,80005a48 <sys_chdir+0x92>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80005a0c:	8526                	mv	a0,s1
    80005a0e:	ffffe097          	auipc	ra,0xffffe
    80005a12:	e36080e7          	jalr	-458(ra) # 80003844 <iunlock>
  iput(p->cwd);
    80005a16:	15093503          	ld	a0,336(s2)
    80005a1a:	ffffe097          	auipc	ra,0xffffe
    80005a1e:	f22080e7          	jalr	-222(ra) # 8000393c <iput>
  end_op();
    80005a22:	ffffe097          	auipc	ra,0xffffe
    80005a26:	780080e7          	jalr	1920(ra) # 800041a2 <end_op>
  p->cwd = ip;
    80005a2a:	14993823          	sd	s1,336(s2)
  return 0;
    80005a2e:	4501                	li	a0,0
}
    80005a30:	60ea                	ld	ra,152(sp)
    80005a32:	644a                	ld	s0,144(sp)
    80005a34:	64aa                	ld	s1,136(sp)
    80005a36:	690a                	ld	s2,128(sp)
    80005a38:	610d                	addi	sp,sp,160
    80005a3a:	8082                	ret
    end_op();
    80005a3c:	ffffe097          	auipc	ra,0xffffe
    80005a40:	766080e7          	jalr	1894(ra) # 800041a2 <end_op>
    return -1;
    80005a44:	557d                	li	a0,-1
    80005a46:	b7ed                	j	80005a30 <sys_chdir+0x7a>
    iunlockput(ip);
    80005a48:	8526                	mv	a0,s1
    80005a4a:	ffffe097          	auipc	ra,0xffffe
    80005a4e:	f9a080e7          	jalr	-102(ra) # 800039e4 <iunlockput>
    end_op();
    80005a52:	ffffe097          	auipc	ra,0xffffe
    80005a56:	750080e7          	jalr	1872(ra) # 800041a2 <end_op>
    return -1;
    80005a5a:	557d                	li	a0,-1
    80005a5c:	bfd1                	j	80005a30 <sys_chdir+0x7a>

0000000080005a5e <sys_exec>:

uint64
sys_exec(void)
{
    80005a5e:	7121                	addi	sp,sp,-448
    80005a60:	ff06                	sd	ra,440(sp)
    80005a62:	fb22                	sd	s0,432(sp)
    80005a64:	f726                	sd	s1,424(sp)
    80005a66:	f34a                	sd	s2,416(sp)
    80005a68:	ef4e                	sd	s3,408(sp)
    80005a6a:	eb52                	sd	s4,400(sp)
    80005a6c:	0380                	addi	s0,sp,448
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    80005a6e:	e4840593          	addi	a1,s0,-440
    80005a72:	4505                	li	a0,1
    80005a74:	ffffd097          	auipc	ra,0xffffd
    80005a78:	1cc080e7          	jalr	460(ra) # 80002c40 <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    80005a7c:	08000613          	li	a2,128
    80005a80:	f5040593          	addi	a1,s0,-176
    80005a84:	4501                	li	a0,0
    80005a86:	ffffd097          	auipc	ra,0xffffd
    80005a8a:	1da080e7          	jalr	474(ra) # 80002c60 <argstr>
    80005a8e:	87aa                	mv	a5,a0
    return -1;
    80005a90:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    80005a92:	0c07c263          	bltz	a5,80005b56 <sys_exec+0xf8>
  }
  memset(argv, 0, sizeof(argv));
    80005a96:	10000613          	li	a2,256
    80005a9a:	4581                	li	a1,0
    80005a9c:	e5040513          	addi	a0,s0,-432
    80005aa0:	ffffb097          	auipc	ra,0xffffb
    80005aa4:	2a4080e7          	jalr	676(ra) # 80000d44 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80005aa8:	e5040493          	addi	s1,s0,-432
  memset(argv, 0, sizeof(argv));
    80005aac:	89a6                	mv	s3,s1
    80005aae:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80005ab0:	02000a13          	li	s4,32
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80005ab4:	00391513          	slli	a0,s2,0x3
    80005ab8:	e4040593          	addi	a1,s0,-448
    80005abc:	e4843783          	ld	a5,-440(s0)
    80005ac0:	953e                	add	a0,a0,a5
    80005ac2:	ffffd097          	auipc	ra,0xffffd
    80005ac6:	0c0080e7          	jalr	192(ra) # 80002b82 <fetchaddr>
    80005aca:	02054a63          	bltz	a0,80005afe <sys_exec+0xa0>
      goto bad;
    }
    if(uarg == 0){
    80005ace:	e4043783          	ld	a5,-448(s0)
    80005ad2:	c3b9                	beqz	a5,80005b18 <sys_exec+0xba>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80005ad4:	ffffb097          	auipc	ra,0xffffb
    80005ad8:	084080e7          	jalr	132(ra) # 80000b58 <kalloc>
    80005adc:	85aa                	mv	a1,a0
    80005ade:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80005ae2:	cd11                	beqz	a0,80005afe <sys_exec+0xa0>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005ae4:	6605                	lui	a2,0x1
    80005ae6:	e4043503          	ld	a0,-448(s0)
    80005aea:	ffffd097          	auipc	ra,0xffffd
    80005aee:	0ea080e7          	jalr	234(ra) # 80002bd4 <fetchstr>
    80005af2:	00054663          	bltz	a0,80005afe <sys_exec+0xa0>
    if(i >= NELEM(argv)){
    80005af6:	0905                	addi	s2,s2,1
    80005af8:	09a1                	addi	s3,s3,8
    80005afa:	fb491de3          	bne	s2,s4,80005ab4 <sys_exec+0x56>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005afe:	f5040913          	addi	s2,s0,-176
    80005b02:	6088                	ld	a0,0(s1)
    80005b04:	c921                	beqz	a0,80005b54 <sys_exec+0xf6>
    kfree(argv[i]);
    80005b06:	ffffb097          	auipc	ra,0xffffb
    80005b0a:	f54080e7          	jalr	-172(ra) # 80000a5a <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005b0e:	04a1                	addi	s1,s1,8
    80005b10:	ff2499e3          	bne	s1,s2,80005b02 <sys_exec+0xa4>
  return -1;
    80005b14:	557d                	li	a0,-1
    80005b16:	a081                	j	80005b56 <sys_exec+0xf8>
      argv[i] = 0;
    80005b18:	0009079b          	sext.w	a5,s2
    80005b1c:	078e                	slli	a5,a5,0x3
    80005b1e:	fd078793          	addi	a5,a5,-48
    80005b22:	97a2                	add	a5,a5,s0
    80005b24:	e807b023          	sd	zero,-384(a5)
  int ret = exec(path, argv);
    80005b28:	e5040593          	addi	a1,s0,-432
    80005b2c:	f5040513          	addi	a0,s0,-176
    80005b30:	fffff097          	auipc	ra,0xfffff
    80005b34:	132080e7          	jalr	306(ra) # 80004c62 <exec>
    80005b38:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005b3a:	f5040993          	addi	s3,s0,-176
    80005b3e:	6088                	ld	a0,0(s1)
    80005b40:	c901                	beqz	a0,80005b50 <sys_exec+0xf2>
    kfree(argv[i]);
    80005b42:	ffffb097          	auipc	ra,0xffffb
    80005b46:	f18080e7          	jalr	-232(ra) # 80000a5a <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005b4a:	04a1                	addi	s1,s1,8
    80005b4c:	ff3499e3          	bne	s1,s3,80005b3e <sys_exec+0xe0>
  return ret;
    80005b50:	854a                	mv	a0,s2
    80005b52:	a011                	j	80005b56 <sys_exec+0xf8>
  return -1;
    80005b54:	557d                	li	a0,-1
}
    80005b56:	70fa                	ld	ra,440(sp)
    80005b58:	745a                	ld	s0,432(sp)
    80005b5a:	74ba                	ld	s1,424(sp)
    80005b5c:	791a                	ld	s2,416(sp)
    80005b5e:	69fa                	ld	s3,408(sp)
    80005b60:	6a5a                	ld	s4,400(sp)
    80005b62:	6139                	addi	sp,sp,448
    80005b64:	8082                	ret

0000000080005b66 <sys_pipe>:

uint64
sys_pipe(void)
{
    80005b66:	7139                	addi	sp,sp,-64
    80005b68:	fc06                	sd	ra,56(sp)
    80005b6a:	f822                	sd	s0,48(sp)
    80005b6c:	f426                	sd	s1,40(sp)
    80005b6e:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005b70:	ffffc097          	auipc	ra,0xffffc
    80005b74:	eb4080e7          	jalr	-332(ra) # 80001a24 <myproc>
    80005b78:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    80005b7a:	fd840593          	addi	a1,s0,-40
    80005b7e:	4501                	li	a0,0
    80005b80:	ffffd097          	auipc	ra,0xffffd
    80005b84:	0c0080e7          	jalr	192(ra) # 80002c40 <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    80005b88:	fc840593          	addi	a1,s0,-56
    80005b8c:	fd040513          	addi	a0,s0,-48
    80005b90:	fffff097          	auipc	ra,0xfffff
    80005b94:	d88080e7          	jalr	-632(ra) # 80004918 <pipealloc>
    return -1;
    80005b98:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80005b9a:	0c054463          	bltz	a0,80005c62 <sys_pipe+0xfc>
  fd0 = -1;
    80005b9e:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80005ba2:	fd043503          	ld	a0,-48(s0)
    80005ba6:	fffff097          	auipc	ra,0xfffff
    80005baa:	524080e7          	jalr	1316(ra) # 800050ca <fdalloc>
    80005bae:	fca42223          	sw	a0,-60(s0)
    80005bb2:	08054b63          	bltz	a0,80005c48 <sys_pipe+0xe2>
    80005bb6:	fc843503          	ld	a0,-56(s0)
    80005bba:	fffff097          	auipc	ra,0xfffff
    80005bbe:	510080e7          	jalr	1296(ra) # 800050ca <fdalloc>
    80005bc2:	fca42023          	sw	a0,-64(s0)
    80005bc6:	06054863          	bltz	a0,80005c36 <sys_pipe+0xd0>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005bca:	4691                	li	a3,4
    80005bcc:	fc440613          	addi	a2,s0,-60
    80005bd0:	fd843583          	ld	a1,-40(s0)
    80005bd4:	68a8                	ld	a0,80(s1)
    80005bd6:	ffffc097          	auipc	ra,0xffffc
    80005bda:	b0e080e7          	jalr	-1266(ra) # 800016e4 <copyout>
    80005bde:	02054063          	bltz	a0,80005bfe <sys_pipe+0x98>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80005be2:	4691                	li	a3,4
    80005be4:	fc040613          	addi	a2,s0,-64
    80005be8:	fd843583          	ld	a1,-40(s0)
    80005bec:	0591                	addi	a1,a1,4
    80005bee:	68a8                	ld	a0,80(s1)
    80005bf0:	ffffc097          	auipc	ra,0xffffc
    80005bf4:	af4080e7          	jalr	-1292(ra) # 800016e4 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80005bf8:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005bfa:	06055463          	bgez	a0,80005c62 <sys_pipe+0xfc>
    p->ofile[fd0] = 0;
    80005bfe:	fc442783          	lw	a5,-60(s0)
    80005c02:	07e9                	addi	a5,a5,26
    80005c04:	078e                	slli	a5,a5,0x3
    80005c06:	97a6                	add	a5,a5,s1
    80005c08:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80005c0c:	fc042783          	lw	a5,-64(s0)
    80005c10:	07e9                	addi	a5,a5,26
    80005c12:	078e                	slli	a5,a5,0x3
    80005c14:	94be                	add	s1,s1,a5
    80005c16:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    80005c1a:	fd043503          	ld	a0,-48(s0)
    80005c1e:	fffff097          	auipc	ra,0xfffff
    80005c22:	9ce080e7          	jalr	-1586(ra) # 800045ec <fileclose>
    fileclose(wf);
    80005c26:	fc843503          	ld	a0,-56(s0)
    80005c2a:	fffff097          	auipc	ra,0xfffff
    80005c2e:	9c2080e7          	jalr	-1598(ra) # 800045ec <fileclose>
    return -1;
    80005c32:	57fd                	li	a5,-1
    80005c34:	a03d                	j	80005c62 <sys_pipe+0xfc>
    if(fd0 >= 0)
    80005c36:	fc442783          	lw	a5,-60(s0)
    80005c3a:	0007c763          	bltz	a5,80005c48 <sys_pipe+0xe2>
      p->ofile[fd0] = 0;
    80005c3e:	07e9                	addi	a5,a5,26
    80005c40:	078e                	slli	a5,a5,0x3
    80005c42:	97a6                	add	a5,a5,s1
    80005c44:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    80005c48:	fd043503          	ld	a0,-48(s0)
    80005c4c:	fffff097          	auipc	ra,0xfffff
    80005c50:	9a0080e7          	jalr	-1632(ra) # 800045ec <fileclose>
    fileclose(wf);
    80005c54:	fc843503          	ld	a0,-56(s0)
    80005c58:	fffff097          	auipc	ra,0xfffff
    80005c5c:	994080e7          	jalr	-1644(ra) # 800045ec <fileclose>
    return -1;
    80005c60:	57fd                	li	a5,-1
}
    80005c62:	853e                	mv	a0,a5
    80005c64:	70e2                	ld	ra,56(sp)
    80005c66:	7442                	ld	s0,48(sp)
    80005c68:	74a2                	ld	s1,40(sp)
    80005c6a:	6121                	addi	sp,sp,64
    80005c6c:	8082                	ret
	...

0000000080005c70 <kernelvec>:
    80005c70:	7111                	addi	sp,sp,-256
    80005c72:	e006                	sd	ra,0(sp)
    80005c74:	e40a                	sd	sp,8(sp)
    80005c76:	e80e                	sd	gp,16(sp)
    80005c78:	ec12                	sd	tp,24(sp)
    80005c7a:	f016                	sd	t0,32(sp)
    80005c7c:	f41a                	sd	t1,40(sp)
    80005c7e:	f81e                	sd	t2,48(sp)
    80005c80:	fc22                	sd	s0,56(sp)
    80005c82:	e0a6                	sd	s1,64(sp)
    80005c84:	e4aa                	sd	a0,72(sp)
    80005c86:	e8ae                	sd	a1,80(sp)
    80005c88:	ecb2                	sd	a2,88(sp)
    80005c8a:	f0b6                	sd	a3,96(sp)
    80005c8c:	f4ba                	sd	a4,104(sp)
    80005c8e:	f8be                	sd	a5,112(sp)
    80005c90:	fcc2                	sd	a6,120(sp)
    80005c92:	e146                	sd	a7,128(sp)
    80005c94:	e54a                	sd	s2,136(sp)
    80005c96:	e94e                	sd	s3,144(sp)
    80005c98:	ed52                	sd	s4,152(sp)
    80005c9a:	f156                	sd	s5,160(sp)
    80005c9c:	f55a                	sd	s6,168(sp)
    80005c9e:	f95e                	sd	s7,176(sp)
    80005ca0:	fd62                	sd	s8,184(sp)
    80005ca2:	e1e6                	sd	s9,192(sp)
    80005ca4:	e5ea                	sd	s10,200(sp)
    80005ca6:	e9ee                	sd	s11,208(sp)
    80005ca8:	edf2                	sd	t3,216(sp)
    80005caa:	f1f6                	sd	t4,224(sp)
    80005cac:	f5fa                	sd	t5,232(sp)
    80005cae:	f9fe                	sd	t6,240(sp)
    80005cb0:	d9ffc0ef          	jal	ra,80002a4e <kerneltrap>
    80005cb4:	6082                	ld	ra,0(sp)
    80005cb6:	6122                	ld	sp,8(sp)
    80005cb8:	61c2                	ld	gp,16(sp)
    80005cba:	7282                	ld	t0,32(sp)
    80005cbc:	7322                	ld	t1,40(sp)
    80005cbe:	73c2                	ld	t2,48(sp)
    80005cc0:	7462                	ld	s0,56(sp)
    80005cc2:	6486                	ld	s1,64(sp)
    80005cc4:	6526                	ld	a0,72(sp)
    80005cc6:	65c6                	ld	a1,80(sp)
    80005cc8:	6666                	ld	a2,88(sp)
    80005cca:	7686                	ld	a3,96(sp)
    80005ccc:	7726                	ld	a4,104(sp)
    80005cce:	77c6                	ld	a5,112(sp)
    80005cd0:	7866                	ld	a6,120(sp)
    80005cd2:	688a                	ld	a7,128(sp)
    80005cd4:	692a                	ld	s2,136(sp)
    80005cd6:	69ca                	ld	s3,144(sp)
    80005cd8:	6a6a                	ld	s4,152(sp)
    80005cda:	7a8a                	ld	s5,160(sp)
    80005cdc:	7b2a                	ld	s6,168(sp)
    80005cde:	7bca                	ld	s7,176(sp)
    80005ce0:	7c6a                	ld	s8,184(sp)
    80005ce2:	6c8e                	ld	s9,192(sp)
    80005ce4:	6d2e                	ld	s10,200(sp)
    80005ce6:	6dce                	ld	s11,208(sp)
    80005ce8:	6e6e                	ld	t3,216(sp)
    80005cea:	7e8e                	ld	t4,224(sp)
    80005cec:	7f2e                	ld	t5,232(sp)
    80005cee:	7fce                	ld	t6,240(sp)
    80005cf0:	6111                	addi	sp,sp,256
    80005cf2:	10200073          	sret
    80005cf6:	00000013          	nop
    80005cfa:	00000013          	nop
    80005cfe:	0001                	nop

0000000080005d00 <timervec>:
    80005d00:	34051573          	csrrw	a0,mscratch,a0
    80005d04:	e10c                	sd	a1,0(a0)
    80005d06:	e510                	sd	a2,8(a0)
    80005d08:	e914                	sd	a3,16(a0)
    80005d0a:	6d0c                	ld	a1,24(a0)
    80005d0c:	7110                	ld	a2,32(a0)
    80005d0e:	6194                	ld	a3,0(a1)
    80005d10:	96b2                	add	a3,a3,a2
    80005d12:	e194                	sd	a3,0(a1)
    80005d14:	4589                	li	a1,2
    80005d16:	14459073          	csrw	sip,a1
    80005d1a:	6914                	ld	a3,16(a0)
    80005d1c:	6510                	ld	a2,8(a0)
    80005d1e:	610c                	ld	a1,0(a0)
    80005d20:	34051573          	csrrw	a0,mscratch,a0
    80005d24:	30200073          	mret
	...

0000000080005d2a <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    80005d2a:	1141                	addi	sp,sp,-16
    80005d2c:	e422                	sd	s0,8(sp)
    80005d2e:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80005d30:	0c0007b7          	lui	a5,0xc000
    80005d34:	4705                	li	a4,1
    80005d36:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80005d38:	c3d8                	sw	a4,4(a5)
}
    80005d3a:	6422                	ld	s0,8(sp)
    80005d3c:	0141                	addi	sp,sp,16
    80005d3e:	8082                	ret

0000000080005d40 <plicinithart>:

void
plicinithart(void)
{
    80005d40:	1141                	addi	sp,sp,-16
    80005d42:	e406                	sd	ra,8(sp)
    80005d44:	e022                	sd	s0,0(sp)
    80005d46:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005d48:	ffffc097          	auipc	ra,0xffffc
    80005d4c:	cb0080e7          	jalr	-848(ra) # 800019f8 <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80005d50:	0085171b          	slliw	a4,a0,0x8
    80005d54:	0c0027b7          	lui	a5,0xc002
    80005d58:	97ba                	add	a5,a5,a4
    80005d5a:	40200713          	li	a4,1026
    80005d5e:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80005d62:	00d5151b          	slliw	a0,a0,0xd
    80005d66:	0c2017b7          	lui	a5,0xc201
    80005d6a:	97aa                	add	a5,a5,a0
    80005d6c:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
}
    80005d70:	60a2                	ld	ra,8(sp)
    80005d72:	6402                	ld	s0,0(sp)
    80005d74:	0141                	addi	sp,sp,16
    80005d76:	8082                	ret

0000000080005d78 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80005d78:	1141                	addi	sp,sp,-16
    80005d7a:	e406                	sd	ra,8(sp)
    80005d7c:	e022                	sd	s0,0(sp)
    80005d7e:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005d80:	ffffc097          	auipc	ra,0xffffc
    80005d84:	c78080e7          	jalr	-904(ra) # 800019f8 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80005d88:	00d5151b          	slliw	a0,a0,0xd
    80005d8c:	0c2017b7          	lui	a5,0xc201
    80005d90:	97aa                	add	a5,a5,a0
  return irq;
}
    80005d92:	43c8                	lw	a0,4(a5)
    80005d94:	60a2                	ld	ra,8(sp)
    80005d96:	6402                	ld	s0,0(sp)
    80005d98:	0141                	addi	sp,sp,16
    80005d9a:	8082                	ret

0000000080005d9c <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    80005d9c:	1101                	addi	sp,sp,-32
    80005d9e:	ec06                	sd	ra,24(sp)
    80005da0:	e822                	sd	s0,16(sp)
    80005da2:	e426                	sd	s1,8(sp)
    80005da4:	1000                	addi	s0,sp,32
    80005da6:	84aa                	mv	s1,a0
  int hart = cpuid();
    80005da8:	ffffc097          	auipc	ra,0xffffc
    80005dac:	c50080e7          	jalr	-944(ra) # 800019f8 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80005db0:	00d5151b          	slliw	a0,a0,0xd
    80005db4:	0c2017b7          	lui	a5,0xc201
    80005db8:	97aa                	add	a5,a5,a0
    80005dba:	c3c4                	sw	s1,4(a5)
}
    80005dbc:	60e2                	ld	ra,24(sp)
    80005dbe:	6442                	ld	s0,16(sp)
    80005dc0:	64a2                	ld	s1,8(sp)
    80005dc2:	6105                	addi	sp,sp,32
    80005dc4:	8082                	ret

0000000080005dc6 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80005dc6:	1141                	addi	sp,sp,-16
    80005dc8:	e406                	sd	ra,8(sp)
    80005dca:	e022                	sd	s0,0(sp)
    80005dcc:	0800                	addi	s0,sp,16
  if(i >= NUM)
    80005dce:	479d                	li	a5,7
    80005dd0:	04a7cc63          	blt	a5,a0,80005e28 <free_desc+0x62>
    panic("free_desc 1");
  if(disk.free[i])
    80005dd4:	0001c797          	auipc	a5,0x1c
    80005dd8:	15c78793          	addi	a5,a5,348 # 80021f30 <disk>
    80005ddc:	97aa                	add	a5,a5,a0
    80005dde:	0187c783          	lbu	a5,24(a5)
    80005de2:	ebb9                	bnez	a5,80005e38 <free_desc+0x72>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80005de4:	00451693          	slli	a3,a0,0x4
    80005de8:	0001c797          	auipc	a5,0x1c
    80005dec:	14878793          	addi	a5,a5,328 # 80021f30 <disk>
    80005df0:	6398                	ld	a4,0(a5)
    80005df2:	9736                	add	a4,a4,a3
    80005df4:	00073023          	sd	zero,0(a4)
  disk.desc[i].len = 0;
    80005df8:	6398                	ld	a4,0(a5)
    80005dfa:	9736                	add	a4,a4,a3
    80005dfc:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    80005e00:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    80005e04:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    80005e08:	97aa                	add	a5,a5,a0
    80005e0a:	4705                	li	a4,1
    80005e0c:	00e78c23          	sb	a4,24(a5)
  wakeup(&disk.free[0]);
    80005e10:	0001c517          	auipc	a0,0x1c
    80005e14:	13850513          	addi	a0,a0,312 # 80021f48 <disk+0x18>
    80005e18:	ffffc097          	auipc	ra,0xffffc
    80005e1c:	346080e7          	jalr	838(ra) # 8000215e <wakeup>
}
    80005e20:	60a2                	ld	ra,8(sp)
    80005e22:	6402                	ld	s0,0(sp)
    80005e24:	0141                	addi	sp,sp,16
    80005e26:	8082                	ret
    panic("free_desc 1");
    80005e28:	00003517          	auipc	a0,0x3
    80005e2c:	9a850513          	addi	a0,a0,-1624 # 800087d0 <syscalls+0x368>
    80005e30:	ffffa097          	auipc	ra,0xffffa
    80005e34:	710080e7          	jalr	1808(ra) # 80000540 <panic>
    panic("free_desc 2");
    80005e38:	00003517          	auipc	a0,0x3
    80005e3c:	9a850513          	addi	a0,a0,-1624 # 800087e0 <syscalls+0x378>
    80005e40:	ffffa097          	auipc	ra,0xffffa
    80005e44:	700080e7          	jalr	1792(ra) # 80000540 <panic>

0000000080005e48 <virtio_disk_init>:
{
    80005e48:	1101                	addi	sp,sp,-32
    80005e4a:	ec06                	sd	ra,24(sp)
    80005e4c:	e822                	sd	s0,16(sp)
    80005e4e:	e426                	sd	s1,8(sp)
    80005e50:	e04a                	sd	s2,0(sp)
    80005e52:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80005e54:	00003597          	auipc	a1,0x3
    80005e58:	99c58593          	addi	a1,a1,-1636 # 800087f0 <syscalls+0x388>
    80005e5c:	0001c517          	auipc	a0,0x1c
    80005e60:	1fc50513          	addi	a0,a0,508 # 80022058 <disk+0x128>
    80005e64:	ffffb097          	auipc	ra,0xffffb
    80005e68:	d54080e7          	jalr	-684(ra) # 80000bb8 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005e6c:	100017b7          	lui	a5,0x10001
    80005e70:	4398                	lw	a4,0(a5)
    80005e72:	2701                	sext.w	a4,a4
    80005e74:	747277b7          	lui	a5,0x74727
    80005e78:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80005e7c:	14f71b63          	bne	a4,a5,80005fd2 <virtio_disk_init+0x18a>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80005e80:	100017b7          	lui	a5,0x10001
    80005e84:	43dc                	lw	a5,4(a5)
    80005e86:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005e88:	4709                	li	a4,2
    80005e8a:	14e79463          	bne	a5,a4,80005fd2 <virtio_disk_init+0x18a>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005e8e:	100017b7          	lui	a5,0x10001
    80005e92:	479c                	lw	a5,8(a5)
    80005e94:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80005e96:	12e79e63          	bne	a5,a4,80005fd2 <virtio_disk_init+0x18a>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    80005e9a:	100017b7          	lui	a5,0x10001
    80005e9e:	47d8                	lw	a4,12(a5)
    80005ea0:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005ea2:	554d47b7          	lui	a5,0x554d4
    80005ea6:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    80005eaa:	12f71463          	bne	a4,a5,80005fd2 <virtio_disk_init+0x18a>
  *R(VIRTIO_MMIO_STATUS) = status;
    80005eae:	100017b7          	lui	a5,0x10001
    80005eb2:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    80005eb6:	4705                	li	a4,1
    80005eb8:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005eba:	470d                	li	a4,3
    80005ebc:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    80005ebe:	4b98                	lw	a4,16(a5)
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80005ec0:	c7ffe6b7          	lui	a3,0xc7ffe
    80005ec4:	75f68693          	addi	a3,a3,1887 # ffffffffc7ffe75f <end+0xffffffff47fdc317>
    80005ec8:	8f75                	and	a4,a4,a3
    80005eca:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005ecc:	472d                	li	a4,11
    80005ece:	dbb8                	sw	a4,112(a5)
  status = *R(VIRTIO_MMIO_STATUS);
    80005ed0:	5bbc                	lw	a5,112(a5)
    80005ed2:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    80005ed6:	8ba1                	andi	a5,a5,8
    80005ed8:	10078563          	beqz	a5,80005fe2 <virtio_disk_init+0x19a>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80005edc:	100017b7          	lui	a5,0x10001
    80005ee0:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    80005ee4:	43fc                	lw	a5,68(a5)
    80005ee6:	2781                	sext.w	a5,a5
    80005ee8:	10079563          	bnez	a5,80005ff2 <virtio_disk_init+0x1aa>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80005eec:	100017b7          	lui	a5,0x10001
    80005ef0:	5bdc                	lw	a5,52(a5)
    80005ef2:	2781                	sext.w	a5,a5
  if(max == 0)
    80005ef4:	10078763          	beqz	a5,80006002 <virtio_disk_init+0x1ba>
  if(max < NUM)
    80005ef8:	471d                	li	a4,7
    80005efa:	10f77c63          	bgeu	a4,a5,80006012 <virtio_disk_init+0x1ca>
  disk.desc = kalloc();
    80005efe:	ffffb097          	auipc	ra,0xffffb
    80005f02:	c5a080e7          	jalr	-934(ra) # 80000b58 <kalloc>
    80005f06:	0001c497          	auipc	s1,0x1c
    80005f0a:	02a48493          	addi	s1,s1,42 # 80021f30 <disk>
    80005f0e:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    80005f10:	ffffb097          	auipc	ra,0xffffb
    80005f14:	c48080e7          	jalr	-952(ra) # 80000b58 <kalloc>
    80005f18:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    80005f1a:	ffffb097          	auipc	ra,0xffffb
    80005f1e:	c3e080e7          	jalr	-962(ra) # 80000b58 <kalloc>
    80005f22:	87aa                	mv	a5,a0
    80005f24:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    80005f26:	6088                	ld	a0,0(s1)
    80005f28:	cd6d                	beqz	a0,80006022 <virtio_disk_init+0x1da>
    80005f2a:	0001c717          	auipc	a4,0x1c
    80005f2e:	00e73703          	ld	a4,14(a4) # 80021f38 <disk+0x8>
    80005f32:	cb65                	beqz	a4,80006022 <virtio_disk_init+0x1da>
    80005f34:	c7fd                	beqz	a5,80006022 <virtio_disk_init+0x1da>
  memset(disk.desc, 0, PGSIZE);
    80005f36:	6605                	lui	a2,0x1
    80005f38:	4581                	li	a1,0
    80005f3a:	ffffb097          	auipc	ra,0xffffb
    80005f3e:	e0a080e7          	jalr	-502(ra) # 80000d44 <memset>
  memset(disk.avail, 0, PGSIZE);
    80005f42:	0001c497          	auipc	s1,0x1c
    80005f46:	fee48493          	addi	s1,s1,-18 # 80021f30 <disk>
    80005f4a:	6605                	lui	a2,0x1
    80005f4c:	4581                	li	a1,0
    80005f4e:	6488                	ld	a0,8(s1)
    80005f50:	ffffb097          	auipc	ra,0xffffb
    80005f54:	df4080e7          	jalr	-524(ra) # 80000d44 <memset>
  memset(disk.used, 0, PGSIZE);
    80005f58:	6605                	lui	a2,0x1
    80005f5a:	4581                	li	a1,0
    80005f5c:	6888                	ld	a0,16(s1)
    80005f5e:	ffffb097          	auipc	ra,0xffffb
    80005f62:	de6080e7          	jalr	-538(ra) # 80000d44 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80005f66:	100017b7          	lui	a5,0x10001
    80005f6a:	4721                	li	a4,8
    80005f6c:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    80005f6e:	4098                	lw	a4,0(s1)
    80005f70:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    80005f74:	40d8                	lw	a4,4(s1)
    80005f76:	08e7a223          	sw	a4,132(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    80005f7a:	6498                	ld	a4,8(s1)
    80005f7c:	0007069b          	sext.w	a3,a4
    80005f80:	08d7a823          	sw	a3,144(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    80005f84:	9701                	srai	a4,a4,0x20
    80005f86:	08e7aa23          	sw	a4,148(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    80005f8a:	6898                	ld	a4,16(s1)
    80005f8c:	0007069b          	sext.w	a3,a4
    80005f90:	0ad7a023          	sw	a3,160(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    80005f94:	9701                	srai	a4,a4,0x20
    80005f96:	0ae7a223          	sw	a4,164(a5)
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    80005f9a:	4705                	li	a4,1
    80005f9c:	c3f8                	sw	a4,68(a5)
    disk.free[i] = 1;
    80005f9e:	00e48c23          	sb	a4,24(s1)
    80005fa2:	00e48ca3          	sb	a4,25(s1)
    80005fa6:	00e48d23          	sb	a4,26(s1)
    80005faa:	00e48da3          	sb	a4,27(s1)
    80005fae:	00e48e23          	sb	a4,28(s1)
    80005fb2:	00e48ea3          	sb	a4,29(s1)
    80005fb6:	00e48f23          	sb	a4,30(s1)
    80005fba:	00e48fa3          	sb	a4,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    80005fbe:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    80005fc2:	0727a823          	sw	s2,112(a5)
}
    80005fc6:	60e2                	ld	ra,24(sp)
    80005fc8:	6442                	ld	s0,16(sp)
    80005fca:	64a2                	ld	s1,8(sp)
    80005fcc:	6902                	ld	s2,0(sp)
    80005fce:	6105                	addi	sp,sp,32
    80005fd0:	8082                	ret
    panic("could not find virtio disk");
    80005fd2:	00003517          	auipc	a0,0x3
    80005fd6:	82e50513          	addi	a0,a0,-2002 # 80008800 <syscalls+0x398>
    80005fda:	ffffa097          	auipc	ra,0xffffa
    80005fde:	566080e7          	jalr	1382(ra) # 80000540 <panic>
    panic("virtio disk FEATURES_OK unset");
    80005fe2:	00003517          	auipc	a0,0x3
    80005fe6:	83e50513          	addi	a0,a0,-1986 # 80008820 <syscalls+0x3b8>
    80005fea:	ffffa097          	auipc	ra,0xffffa
    80005fee:	556080e7          	jalr	1366(ra) # 80000540 <panic>
    panic("virtio disk should not be ready");
    80005ff2:	00003517          	auipc	a0,0x3
    80005ff6:	84e50513          	addi	a0,a0,-1970 # 80008840 <syscalls+0x3d8>
    80005ffa:	ffffa097          	auipc	ra,0xffffa
    80005ffe:	546080e7          	jalr	1350(ra) # 80000540 <panic>
    panic("virtio disk has no queue 0");
    80006002:	00003517          	auipc	a0,0x3
    80006006:	85e50513          	addi	a0,a0,-1954 # 80008860 <syscalls+0x3f8>
    8000600a:	ffffa097          	auipc	ra,0xffffa
    8000600e:	536080e7          	jalr	1334(ra) # 80000540 <panic>
    panic("virtio disk max queue too short");
    80006012:	00003517          	auipc	a0,0x3
    80006016:	86e50513          	addi	a0,a0,-1938 # 80008880 <syscalls+0x418>
    8000601a:	ffffa097          	auipc	ra,0xffffa
    8000601e:	526080e7          	jalr	1318(ra) # 80000540 <panic>
    panic("virtio disk kalloc");
    80006022:	00003517          	auipc	a0,0x3
    80006026:	87e50513          	addi	a0,a0,-1922 # 800088a0 <syscalls+0x438>
    8000602a:	ffffa097          	auipc	ra,0xffffa
    8000602e:	516080e7          	jalr	1302(ra) # 80000540 <panic>

0000000080006032 <virtio_disk_init_bootloader>:
{
    80006032:	1101                	addi	sp,sp,-32
    80006034:	ec06                	sd	ra,24(sp)
    80006036:	e822                	sd	s0,16(sp)
    80006038:	e426                	sd	s1,8(sp)
    8000603a:	e04a                	sd	s2,0(sp)
    8000603c:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    8000603e:	00002597          	auipc	a1,0x2
    80006042:	7b258593          	addi	a1,a1,1970 # 800087f0 <syscalls+0x388>
    80006046:	0001c517          	auipc	a0,0x1c
    8000604a:	01250513          	addi	a0,a0,18 # 80022058 <disk+0x128>
    8000604e:	ffffb097          	auipc	ra,0xffffb
    80006052:	b6a080e7          	jalr	-1174(ra) # 80000bb8 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80006056:	100017b7          	lui	a5,0x10001
    8000605a:	4398                	lw	a4,0(a5)
    8000605c:	2701                	sext.w	a4,a4
    8000605e:	747277b7          	lui	a5,0x74727
    80006062:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80006066:	12f71763          	bne	a4,a5,80006194 <virtio_disk_init_bootloader+0x162>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    8000606a:	100017b7          	lui	a5,0x10001
    8000606e:	43dc                	lw	a5,4(a5)
    80006070:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80006072:	4709                	li	a4,2
    80006074:	12e79063          	bne	a5,a4,80006194 <virtio_disk_init_bootloader+0x162>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80006078:	100017b7          	lui	a5,0x10001
    8000607c:	479c                	lw	a5,8(a5)
    8000607e:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80006080:	10e79a63          	bne	a5,a4,80006194 <virtio_disk_init_bootloader+0x162>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    80006084:	100017b7          	lui	a5,0x10001
    80006088:	47d8                	lw	a4,12(a5)
    8000608a:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    8000608c:	554d47b7          	lui	a5,0x554d4
    80006090:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    80006094:	10f71063          	bne	a4,a5,80006194 <virtio_disk_init_bootloader+0x162>
  *R(VIRTIO_MMIO_STATUS) = status;
    80006098:	100017b7          	lui	a5,0x10001
    8000609c:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    800060a0:	4705                	li	a4,1
    800060a2:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800060a4:	470d                	li	a4,3
    800060a6:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    800060a8:	4b98                	lw	a4,16(a5)
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    800060aa:	c7ffe6b7          	lui	a3,0xc7ffe
    800060ae:	75f68693          	addi	a3,a3,1887 # ffffffffc7ffe75f <end+0xffffffff47fdc317>
    800060b2:	8f75                	and	a4,a4,a3
    800060b4:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800060b6:	472d                	li	a4,11
    800060b8:	dbb8                	sw	a4,112(a5)
  status = *R(VIRTIO_MMIO_STATUS);
    800060ba:	5bbc                	lw	a5,112(a5)
    800060bc:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    800060c0:	8ba1                	andi	a5,a5,8
    800060c2:	c3ed                	beqz	a5,800061a4 <virtio_disk_init_bootloader+0x172>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    800060c4:	100017b7          	lui	a5,0x10001
    800060c8:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    800060cc:	43fc                	lw	a5,68(a5)
    800060ce:	2781                	sext.w	a5,a5
    800060d0:	e3f5                	bnez	a5,800061b4 <virtio_disk_init_bootloader+0x182>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    800060d2:	100017b7          	lui	a5,0x10001
    800060d6:	5bdc                	lw	a5,52(a5)
    800060d8:	2781                	sext.w	a5,a5
  if(max == 0)
    800060da:	c7ed                	beqz	a5,800061c4 <virtio_disk_init_bootloader+0x192>
  if(max < NUM)
    800060dc:	471d                	li	a4,7
    800060de:	0ef77b63          	bgeu	a4,a5,800061d4 <virtio_disk_init_bootloader+0x1a2>
  disk.desc  = (void*) 0x77000000;
    800060e2:	0001c497          	auipc	s1,0x1c
    800060e6:	e4e48493          	addi	s1,s1,-434 # 80021f30 <disk>
    800060ea:	770007b7          	lui	a5,0x77000
    800060ee:	e09c                	sd	a5,0(s1)
  disk.avail = (void*) 0x77001000;
    800060f0:	770017b7          	lui	a5,0x77001
    800060f4:	e49c                	sd	a5,8(s1)
  disk.used  = (void*) 0x77002000;
    800060f6:	770027b7          	lui	a5,0x77002
    800060fa:	e89c                	sd	a5,16(s1)
  memset(disk.desc, 0, PGSIZE);
    800060fc:	6605                	lui	a2,0x1
    800060fe:	4581                	li	a1,0
    80006100:	77000537          	lui	a0,0x77000
    80006104:	ffffb097          	auipc	ra,0xffffb
    80006108:	c40080e7          	jalr	-960(ra) # 80000d44 <memset>
  memset(disk.avail, 0, PGSIZE);
    8000610c:	6605                	lui	a2,0x1
    8000610e:	4581                	li	a1,0
    80006110:	6488                	ld	a0,8(s1)
    80006112:	ffffb097          	auipc	ra,0xffffb
    80006116:	c32080e7          	jalr	-974(ra) # 80000d44 <memset>
  memset(disk.used, 0, PGSIZE);
    8000611a:	6605                	lui	a2,0x1
    8000611c:	4581                	li	a1,0
    8000611e:	6888                	ld	a0,16(s1)
    80006120:	ffffb097          	auipc	ra,0xffffb
    80006124:	c24080e7          	jalr	-988(ra) # 80000d44 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80006128:	100017b7          	lui	a5,0x10001
    8000612c:	4721                	li	a4,8
    8000612e:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    80006130:	4098                	lw	a4,0(s1)
    80006132:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    80006136:	40d8                	lw	a4,4(s1)
    80006138:	08e7a223          	sw	a4,132(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    8000613c:	6498                	ld	a4,8(s1)
    8000613e:	0007069b          	sext.w	a3,a4
    80006142:	08d7a823          	sw	a3,144(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    80006146:	9701                	srai	a4,a4,0x20
    80006148:	08e7aa23          	sw	a4,148(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    8000614c:	6898                	ld	a4,16(s1)
    8000614e:	0007069b          	sext.w	a3,a4
    80006152:	0ad7a023          	sw	a3,160(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    80006156:	9701                	srai	a4,a4,0x20
    80006158:	0ae7a223          	sw	a4,164(a5)
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    8000615c:	4705                	li	a4,1
    8000615e:	c3f8                	sw	a4,68(a5)
    disk.free[i] = 1;
    80006160:	00e48c23          	sb	a4,24(s1)
    80006164:	00e48ca3          	sb	a4,25(s1)
    80006168:	00e48d23          	sb	a4,26(s1)
    8000616c:	00e48da3          	sb	a4,27(s1)
    80006170:	00e48e23          	sb	a4,28(s1)
    80006174:	00e48ea3          	sb	a4,29(s1)
    80006178:	00e48f23          	sb	a4,30(s1)
    8000617c:	00e48fa3          	sb	a4,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    80006180:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    80006184:	0727a823          	sw	s2,112(a5)
}
    80006188:	60e2                	ld	ra,24(sp)
    8000618a:	6442                	ld	s0,16(sp)
    8000618c:	64a2                	ld	s1,8(sp)
    8000618e:	6902                	ld	s2,0(sp)
    80006190:	6105                	addi	sp,sp,32
    80006192:	8082                	ret
    panic("could not find virtio disk");
    80006194:	00002517          	auipc	a0,0x2
    80006198:	66c50513          	addi	a0,a0,1644 # 80008800 <syscalls+0x398>
    8000619c:	ffffa097          	auipc	ra,0xffffa
    800061a0:	3a4080e7          	jalr	932(ra) # 80000540 <panic>
    panic("virtio disk FEATURES_OK unset");
    800061a4:	00002517          	auipc	a0,0x2
    800061a8:	67c50513          	addi	a0,a0,1660 # 80008820 <syscalls+0x3b8>
    800061ac:	ffffa097          	auipc	ra,0xffffa
    800061b0:	394080e7          	jalr	916(ra) # 80000540 <panic>
    panic("virtio disk should not be ready");
    800061b4:	00002517          	auipc	a0,0x2
    800061b8:	68c50513          	addi	a0,a0,1676 # 80008840 <syscalls+0x3d8>
    800061bc:	ffffa097          	auipc	ra,0xffffa
    800061c0:	384080e7          	jalr	900(ra) # 80000540 <panic>
    panic("virtio disk has no queue 0");
    800061c4:	00002517          	auipc	a0,0x2
    800061c8:	69c50513          	addi	a0,a0,1692 # 80008860 <syscalls+0x3f8>
    800061cc:	ffffa097          	auipc	ra,0xffffa
    800061d0:	374080e7          	jalr	884(ra) # 80000540 <panic>
    panic("virtio disk max queue too short");
    800061d4:	00002517          	auipc	a0,0x2
    800061d8:	6ac50513          	addi	a0,a0,1708 # 80008880 <syscalls+0x418>
    800061dc:	ffffa097          	auipc	ra,0xffffa
    800061e0:	364080e7          	jalr	868(ra) # 80000540 <panic>

00000000800061e4 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    800061e4:	7159                	addi	sp,sp,-112
    800061e6:	f486                	sd	ra,104(sp)
    800061e8:	f0a2                	sd	s0,96(sp)
    800061ea:	eca6                	sd	s1,88(sp)
    800061ec:	e8ca                	sd	s2,80(sp)
    800061ee:	e4ce                	sd	s3,72(sp)
    800061f0:	e0d2                	sd	s4,64(sp)
    800061f2:	fc56                	sd	s5,56(sp)
    800061f4:	f85a                	sd	s6,48(sp)
    800061f6:	f45e                	sd	s7,40(sp)
    800061f8:	f062                	sd	s8,32(sp)
    800061fa:	ec66                	sd	s9,24(sp)
    800061fc:	e86a                	sd	s10,16(sp)
    800061fe:	1880                	addi	s0,sp,112
    80006200:	8a2a                	mv	s4,a0
    80006202:	8bae                	mv	s7,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80006204:	00c52c83          	lw	s9,12(a0)
    80006208:	001c9c9b          	slliw	s9,s9,0x1
    8000620c:	1c82                	slli	s9,s9,0x20
    8000620e:	020cdc93          	srli	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    80006212:	0001c517          	auipc	a0,0x1c
    80006216:	e4650513          	addi	a0,a0,-442 # 80022058 <disk+0x128>
    8000621a:	ffffb097          	auipc	ra,0xffffb
    8000621e:	a2e080e7          	jalr	-1490(ra) # 80000c48 <acquire>
  for(int i = 0; i < 3; i++){
    80006222:	4901                	li	s2,0
  for(int i = 0; i < NUM; i++){
    80006224:	44a1                	li	s1,8
      disk.free[i] = 0;
    80006226:	0001cb17          	auipc	s6,0x1c
    8000622a:	d0ab0b13          	addi	s6,s6,-758 # 80021f30 <disk>
  for(int i = 0; i < 3; i++){
    8000622e:	4a8d                	li	s5,3
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80006230:	0001cc17          	auipc	s8,0x1c
    80006234:	e28c0c13          	addi	s8,s8,-472 # 80022058 <disk+0x128>
    80006238:	a095                	j	8000629c <virtio_disk_rw+0xb8>
      disk.free[i] = 0;
    8000623a:	00fb0733          	add	a4,s6,a5
    8000623e:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    80006242:	c11c                	sw	a5,0(a0)
    if(idx[i] < 0){
    80006244:	0207c563          	bltz	a5,8000626e <virtio_disk_rw+0x8a>
  for(int i = 0; i < 3; i++){
    80006248:	2605                	addiw	a2,a2,1 # 1001 <_entry-0x7fffefff>
    8000624a:	0591                	addi	a1,a1,4
    8000624c:	05560d63          	beq	a2,s5,800062a6 <virtio_disk_rw+0xc2>
    idx[i] = alloc_desc();
    80006250:	852e                	mv	a0,a1
  for(int i = 0; i < NUM; i++){
    80006252:	0001c717          	auipc	a4,0x1c
    80006256:	cde70713          	addi	a4,a4,-802 # 80021f30 <disk>
    8000625a:	87ca                	mv	a5,s2
    if(disk.free[i]){
    8000625c:	01874683          	lbu	a3,24(a4)
    80006260:	fee9                	bnez	a3,8000623a <virtio_disk_rw+0x56>
  for(int i = 0; i < NUM; i++){
    80006262:	2785                	addiw	a5,a5,1
    80006264:	0705                	addi	a4,a4,1
    80006266:	fe979be3          	bne	a5,s1,8000625c <virtio_disk_rw+0x78>
    idx[i] = alloc_desc();
    8000626a:	57fd                	li	a5,-1
    8000626c:	c11c                	sw	a5,0(a0)
      for(int j = 0; j < i; j++)
    8000626e:	00c05e63          	blez	a2,8000628a <virtio_disk_rw+0xa6>
    80006272:	060a                	slli	a2,a2,0x2
    80006274:	01360d33          	add	s10,a2,s3
        free_desc(idx[j]);
    80006278:	0009a503          	lw	a0,0(s3)
    8000627c:	00000097          	auipc	ra,0x0
    80006280:	b4a080e7          	jalr	-1206(ra) # 80005dc6 <free_desc>
      for(int j = 0; j < i; j++)
    80006284:	0991                	addi	s3,s3,4
    80006286:	ffa999e3          	bne	s3,s10,80006278 <virtio_disk_rw+0x94>
    sleep(&disk.free[0], &disk.vdisk_lock);
    8000628a:	85e2                	mv	a1,s8
    8000628c:	0001c517          	auipc	a0,0x1c
    80006290:	cbc50513          	addi	a0,a0,-836 # 80021f48 <disk+0x18>
    80006294:	ffffc097          	auipc	ra,0xffffc
    80006298:	e66080e7          	jalr	-410(ra) # 800020fa <sleep>
  for(int i = 0; i < 3; i++){
    8000629c:	f9040993          	addi	s3,s0,-112
{
    800062a0:	85ce                	mv	a1,s3
  for(int i = 0; i < 3; i++){
    800062a2:	864a                	mv	a2,s2
    800062a4:	b775                	j	80006250 <virtio_disk_rw+0x6c>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    800062a6:	f9042503          	lw	a0,-112(s0)
    800062aa:	00a50713          	addi	a4,a0,10
    800062ae:	0712                	slli	a4,a4,0x4

  if(write)
    800062b0:	0001c797          	auipc	a5,0x1c
    800062b4:	c8078793          	addi	a5,a5,-896 # 80021f30 <disk>
    800062b8:	00e786b3          	add	a3,a5,a4
    800062bc:	01703633          	snez	a2,s7
    800062c0:	c690                	sw	a2,8(a3)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    800062c2:	0006a623          	sw	zero,12(a3)
  buf0->sector = sector;
    800062c6:	0196b823          	sd	s9,16(a3)

  disk.desc[idx[0]].addr = (uint64) buf0;
    800062ca:	f6070613          	addi	a2,a4,-160
    800062ce:	6394                	ld	a3,0(a5)
    800062d0:	96b2                	add	a3,a3,a2
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    800062d2:	00870593          	addi	a1,a4,8
    800062d6:	95be                	add	a1,a1,a5
  disk.desc[idx[0]].addr = (uint64) buf0;
    800062d8:	e28c                	sd	a1,0(a3)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    800062da:	0007b803          	ld	a6,0(a5)
    800062de:	9642                	add	a2,a2,a6
    800062e0:	46c1                	li	a3,16
    800062e2:	c614                	sw	a3,8(a2)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    800062e4:	4585                	li	a1,1
    800062e6:	00b61623          	sh	a1,12(a2)
  disk.desc[idx[0]].next = idx[1];
    800062ea:	f9442683          	lw	a3,-108(s0)
    800062ee:	00d61723          	sh	a3,14(a2)

  disk.desc[idx[1]].addr = (uint64) b->data;
    800062f2:	0692                	slli	a3,a3,0x4
    800062f4:	9836                	add	a6,a6,a3
    800062f6:	058a0613          	addi	a2,s4,88
    800062fa:	00c83023          	sd	a2,0(a6)
  disk.desc[idx[1]].len = BSIZE;
    800062fe:	0007b803          	ld	a6,0(a5)
    80006302:	96c2                	add	a3,a3,a6
    80006304:	40000613          	li	a2,1024
    80006308:	c690                	sw	a2,8(a3)
  if(write)
    8000630a:	001bb613          	seqz	a2,s7
    8000630e:	0016161b          	slliw	a2,a2,0x1
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    80006312:	00166613          	ori	a2,a2,1
    80006316:	00c69623          	sh	a2,12(a3)
  disk.desc[idx[1]].next = idx[2];
    8000631a:	f9842603          	lw	a2,-104(s0)
    8000631e:	00c69723          	sh	a2,14(a3)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    80006322:	00250693          	addi	a3,a0,2
    80006326:	0692                	slli	a3,a3,0x4
    80006328:	96be                	add	a3,a3,a5
    8000632a:	58fd                	li	a7,-1
    8000632c:	01168823          	sb	a7,16(a3)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    80006330:	0612                	slli	a2,a2,0x4
    80006332:	9832                	add	a6,a6,a2
    80006334:	f9070713          	addi	a4,a4,-112
    80006338:	973e                	add	a4,a4,a5
    8000633a:	00e83023          	sd	a4,0(a6)
  disk.desc[idx[2]].len = 1;
    8000633e:	6398                	ld	a4,0(a5)
    80006340:	9732                	add	a4,a4,a2
    80006342:	c70c                	sw	a1,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80006344:	4609                	li	a2,2
    80006346:	00c71623          	sh	a2,12(a4)
  disk.desc[idx[2]].next = 0;
    8000634a:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    8000634e:	00ba2223          	sw	a1,4(s4)
  disk.info[idx[0]].b = b;
    80006352:	0146b423          	sd	s4,8(a3)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80006356:	6794                	ld	a3,8(a5)
    80006358:	0026d703          	lhu	a4,2(a3)
    8000635c:	8b1d                	andi	a4,a4,7
    8000635e:	0706                	slli	a4,a4,0x1
    80006360:	96ba                	add	a3,a3,a4
    80006362:	00a69223          	sh	a0,4(a3)

  __sync_synchronize();
    80006366:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    8000636a:	6798                	ld	a4,8(a5)
    8000636c:	00275783          	lhu	a5,2(a4)
    80006370:	2785                	addiw	a5,a5,1
    80006372:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80006376:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    8000637a:	100017b7          	lui	a5,0x10001
    8000637e:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80006382:	004a2783          	lw	a5,4(s4)
    sleep(b, &disk.vdisk_lock);
    80006386:	0001c917          	auipc	s2,0x1c
    8000638a:	cd290913          	addi	s2,s2,-814 # 80022058 <disk+0x128>
  while(b->disk == 1) {
    8000638e:	4485                	li	s1,1
    80006390:	00b79c63          	bne	a5,a1,800063a8 <virtio_disk_rw+0x1c4>
    sleep(b, &disk.vdisk_lock);
    80006394:	85ca                	mv	a1,s2
    80006396:	8552                	mv	a0,s4
    80006398:	ffffc097          	auipc	ra,0xffffc
    8000639c:	d62080e7          	jalr	-670(ra) # 800020fa <sleep>
  while(b->disk == 1) {
    800063a0:	004a2783          	lw	a5,4(s4)
    800063a4:	fe9788e3          	beq	a5,s1,80006394 <virtio_disk_rw+0x1b0>
  }

  disk.info[idx[0]].b = 0;
    800063a8:	f9042903          	lw	s2,-112(s0)
    800063ac:	00290713          	addi	a4,s2,2
    800063b0:	0712                	slli	a4,a4,0x4
    800063b2:	0001c797          	auipc	a5,0x1c
    800063b6:	b7e78793          	addi	a5,a5,-1154 # 80021f30 <disk>
    800063ba:	97ba                	add	a5,a5,a4
    800063bc:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    800063c0:	0001c997          	auipc	s3,0x1c
    800063c4:	b7098993          	addi	s3,s3,-1168 # 80021f30 <disk>
    800063c8:	00491713          	slli	a4,s2,0x4
    800063cc:	0009b783          	ld	a5,0(s3)
    800063d0:	97ba                	add	a5,a5,a4
    800063d2:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    800063d6:	854a                	mv	a0,s2
    800063d8:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    800063dc:	00000097          	auipc	ra,0x0
    800063e0:	9ea080e7          	jalr	-1558(ra) # 80005dc6 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    800063e4:	8885                	andi	s1,s1,1
    800063e6:	f0ed                	bnez	s1,800063c8 <virtio_disk_rw+0x1e4>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    800063e8:	0001c517          	auipc	a0,0x1c
    800063ec:	c7050513          	addi	a0,a0,-912 # 80022058 <disk+0x128>
    800063f0:	ffffb097          	auipc	ra,0xffffb
    800063f4:	90c080e7          	jalr	-1780(ra) # 80000cfc <release>
}
    800063f8:	70a6                	ld	ra,104(sp)
    800063fa:	7406                	ld	s0,96(sp)
    800063fc:	64e6                	ld	s1,88(sp)
    800063fe:	6946                	ld	s2,80(sp)
    80006400:	69a6                	ld	s3,72(sp)
    80006402:	6a06                	ld	s4,64(sp)
    80006404:	7ae2                	ld	s5,56(sp)
    80006406:	7b42                	ld	s6,48(sp)
    80006408:	7ba2                	ld	s7,40(sp)
    8000640a:	7c02                	ld	s8,32(sp)
    8000640c:	6ce2                	ld	s9,24(sp)
    8000640e:	6d42                	ld	s10,16(sp)
    80006410:	6165                	addi	sp,sp,112
    80006412:	8082                	ret

0000000080006414 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80006414:	1101                	addi	sp,sp,-32
    80006416:	ec06                	sd	ra,24(sp)
    80006418:	e822                	sd	s0,16(sp)
    8000641a:	e426                	sd	s1,8(sp)
    8000641c:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    8000641e:	0001c497          	auipc	s1,0x1c
    80006422:	b1248493          	addi	s1,s1,-1262 # 80021f30 <disk>
    80006426:	0001c517          	auipc	a0,0x1c
    8000642a:	c3250513          	addi	a0,a0,-974 # 80022058 <disk+0x128>
    8000642e:	ffffb097          	auipc	ra,0xffffb
    80006432:	81a080e7          	jalr	-2022(ra) # 80000c48 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80006436:	10001737          	lui	a4,0x10001
    8000643a:	533c                	lw	a5,96(a4)
    8000643c:	8b8d                	andi	a5,a5,3
    8000643e:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    80006440:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    80006444:	689c                	ld	a5,16(s1)
    80006446:	0204d703          	lhu	a4,32(s1)
    8000644a:	0027d783          	lhu	a5,2(a5)
    8000644e:	04f70863          	beq	a4,a5,8000649e <virtio_disk_intr+0x8a>
    __sync_synchronize();
    80006452:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80006456:	6898                	ld	a4,16(s1)
    80006458:	0204d783          	lhu	a5,32(s1)
    8000645c:	8b9d                	andi	a5,a5,7
    8000645e:	078e                	slli	a5,a5,0x3
    80006460:	97ba                	add	a5,a5,a4
    80006462:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    80006464:	00278713          	addi	a4,a5,2
    80006468:	0712                	slli	a4,a4,0x4
    8000646a:	9726                	add	a4,a4,s1
    8000646c:	01074703          	lbu	a4,16(a4) # 10001010 <_entry-0x6fffeff0>
    80006470:	e721                	bnez	a4,800064b8 <virtio_disk_intr+0xa4>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80006472:	0789                	addi	a5,a5,2
    80006474:	0792                	slli	a5,a5,0x4
    80006476:	97a6                	add	a5,a5,s1
    80006478:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    8000647a:	00052223          	sw	zero,4(a0)
    wakeup(b);
    8000647e:	ffffc097          	auipc	ra,0xffffc
    80006482:	ce0080e7          	jalr	-800(ra) # 8000215e <wakeup>

    disk.used_idx += 1;
    80006486:	0204d783          	lhu	a5,32(s1)
    8000648a:	2785                	addiw	a5,a5,1
    8000648c:	17c2                	slli	a5,a5,0x30
    8000648e:	93c1                	srli	a5,a5,0x30
    80006490:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    80006494:	6898                	ld	a4,16(s1)
    80006496:	00275703          	lhu	a4,2(a4)
    8000649a:	faf71ce3          	bne	a4,a5,80006452 <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    8000649e:	0001c517          	auipc	a0,0x1c
    800064a2:	bba50513          	addi	a0,a0,-1094 # 80022058 <disk+0x128>
    800064a6:	ffffb097          	auipc	ra,0xffffb
    800064aa:	856080e7          	jalr	-1962(ra) # 80000cfc <release>
}
    800064ae:	60e2                	ld	ra,24(sp)
    800064b0:	6442                	ld	s0,16(sp)
    800064b2:	64a2                	ld	s1,8(sp)
    800064b4:	6105                	addi	sp,sp,32
    800064b6:	8082                	ret
      panic("virtio_disk_intr status");
    800064b8:	00002517          	auipc	a0,0x2
    800064bc:	40050513          	addi	a0,a0,1024 # 800088b8 <syscalls+0x450>
    800064c0:	ffffa097          	auipc	ra,0xffffa
    800064c4:	080080e7          	jalr	128(ra) # 80000540 <panic>

00000000800064c8 <ramdiskinit>:
/* TODO: find the location of the QEMU ramdisk. */
#define RAMDISK 0x84000000

void
ramdiskinit(void)
{
    800064c8:	1141                	addi	sp,sp,-16
    800064ca:	e422                	sd	s0,8(sp)
    800064cc:	0800                	addi	s0,sp,16
}
    800064ce:	6422                	ld	s0,8(sp)
    800064d0:	0141                	addi	sp,sp,16
    800064d2:	8082                	ret

00000000800064d4 <ramdiskrw>:

// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
ramdiskrw(struct buf *b)
{
    800064d4:	1101                	addi	sp,sp,-32
    800064d6:	ec06                	sd	ra,24(sp)
    800064d8:	e822                	sd	s0,16(sp)
    800064da:	e426                	sd	s1,8(sp)
    800064dc:	1000                	addi	s0,sp,32
    panic("ramdiskrw: buf not locked");
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
    panic("ramdiskrw: nothing to do");
#endif

  if(b->blockno >= FSSIZE)
    800064de:	454c                	lw	a1,12(a0)
    800064e0:	7cf00793          	li	a5,1999
    800064e4:	02b7ea63          	bltu	a5,a1,80006518 <ramdiskrw+0x44>
    800064e8:	84aa                	mv	s1,a0
    panic("ramdiskrw: blockno too big");

  uint64 diskaddr = b->blockno * BSIZE;
    800064ea:	00a5959b          	slliw	a1,a1,0xa
    800064ee:	1582                	slli	a1,a1,0x20
    800064f0:	9181                	srli	a1,a1,0x20
  char *addr = (char *)RAMDISK + diskaddr;

  // read from the location
  memmove(b->data, addr, BSIZE);
    800064f2:	40000613          	li	a2,1024
    800064f6:	02100793          	li	a5,33
    800064fa:	07ea                	slli	a5,a5,0x1a
    800064fc:	95be                	add	a1,a1,a5
    800064fe:	05850513          	addi	a0,a0,88
    80006502:	ffffb097          	auipc	ra,0xffffb
    80006506:	89e080e7          	jalr	-1890(ra) # 80000da0 <memmove>
  b->valid = 1;
    8000650a:	4785                	li	a5,1
    8000650c:	c09c                	sw	a5,0(s1)
    // read
    memmove(b->data, addr, BSIZE);
    b->flags |= B_VALID;
  }
#endif
}
    8000650e:	60e2                	ld	ra,24(sp)
    80006510:	6442                	ld	s0,16(sp)
    80006512:	64a2                	ld	s1,8(sp)
    80006514:	6105                	addi	sp,sp,32
    80006516:	8082                	ret
    panic("ramdiskrw: blockno too big");
    80006518:	00002517          	auipc	a0,0x2
    8000651c:	3b850513          	addi	a0,a0,952 # 800088d0 <syscalls+0x468>
    80006520:	ffffa097          	auipc	ra,0xffffa
    80006524:	020080e7          	jalr	32(ra) # 80000540 <panic>

0000000080006528 <dump_hex>:
#include "fs.h"
#include "buf.h"
#include <stddef.h>

/* Acknowledgement: https://gist.github.com/ccbrown/9722406 */
void dump_hex(const void* data, size_t size) {
    80006528:	7119                	addi	sp,sp,-128
    8000652a:	fc86                	sd	ra,120(sp)
    8000652c:	f8a2                	sd	s0,112(sp)
    8000652e:	f4a6                	sd	s1,104(sp)
    80006530:	f0ca                	sd	s2,96(sp)
    80006532:	ecce                	sd	s3,88(sp)
    80006534:	e8d2                	sd	s4,80(sp)
    80006536:	e4d6                	sd	s5,72(sp)
    80006538:	e0da                	sd	s6,64(sp)
    8000653a:	fc5e                	sd	s7,56(sp)
    8000653c:	f862                	sd	s8,48(sp)
    8000653e:	f466                	sd	s9,40(sp)
    80006540:	0100                	addi	s0,sp,128
	char ascii[17];
	size_t i, j;
	ascii[16] = '\0';
    80006542:	f8040c23          	sb	zero,-104(s0)
	for (i = 0; i < size; ++i) {
    80006546:	c5e1                	beqz	a1,8000660e <dump_hex+0xe6>
    80006548:	89ae                	mv	s3,a1
    8000654a:	892a                	mv	s2,a0
    8000654c:	4481                	li	s1,0
		printf("%x ", ((unsigned char*)data)[i]);
    8000654e:	00002a97          	auipc	s5,0x2
    80006552:	3a2a8a93          	addi	s5,s5,930 # 800088f0 <syscalls+0x488>
		if (((unsigned char*)data)[i] >= ' ' && ((unsigned char*)data)[i] <= '~') {
    80006556:	05e00a13          	li	s4,94
			ascii[i % 16] = ((unsigned char*)data)[i];
		} else {
			ascii[i % 16] = '.';
    8000655a:	02e00b13          	li	s6,46
		}
		if ((i+1) % 8 == 0 || i+1 == size) {
			printf(" ");
			if ((i+1) % 16 == 0) {
				printf("|  %s \n", ascii);
    8000655e:	00002c17          	auipc	s8,0x2
    80006562:	3a2c0c13          	addi	s8,s8,930 # 80008900 <syscalls+0x498>
			printf(" ");
    80006566:	00002b97          	auipc	s7,0x2
    8000656a:	392b8b93          	addi	s7,s7,914 # 800088f8 <syscalls+0x490>
    8000656e:	a839                	j	8000658c <dump_hex+0x64>
			ascii[i % 16] = '.';
    80006570:	00f4f793          	andi	a5,s1,15
    80006574:	fa078793          	addi	a5,a5,-96
    80006578:	97a2                	add	a5,a5,s0
    8000657a:	ff678423          	sb	s6,-24(a5)
		if ((i+1) % 8 == 0 || i+1 == size) {
    8000657e:	0485                	addi	s1,s1,1
    80006580:	0074f793          	andi	a5,s1,7
    80006584:	cb9d                	beqz	a5,800065ba <dump_hex+0x92>
    80006586:	0b348a63          	beq	s1,s3,8000663a <dump_hex+0x112>
	for (i = 0; i < size; ++i) {
    8000658a:	0905                	addi	s2,s2,1
		printf("%x ", ((unsigned char*)data)[i]);
    8000658c:	00094583          	lbu	a1,0(s2)
    80006590:	8556                	mv	a0,s5
    80006592:	ffffa097          	auipc	ra,0xffffa
    80006596:	ff8080e7          	jalr	-8(ra) # 8000058a <printf>
		if (((unsigned char*)data)[i] >= ' ' && ((unsigned char*)data)[i] <= '~') {
    8000659a:	00094703          	lbu	a4,0(s2)
    8000659e:	fe07079b          	addiw	a5,a4,-32
    800065a2:	0ff7f793          	zext.b	a5,a5
    800065a6:	fcfa65e3          	bltu	s4,a5,80006570 <dump_hex+0x48>
			ascii[i % 16] = ((unsigned char*)data)[i];
    800065aa:	00f4f793          	andi	a5,s1,15
    800065ae:	fa078793          	addi	a5,a5,-96
    800065b2:	97a2                	add	a5,a5,s0
    800065b4:	fee78423          	sb	a4,-24(a5)
    800065b8:	b7d9                	j	8000657e <dump_hex+0x56>
			printf(" ");
    800065ba:	855e                	mv	a0,s7
    800065bc:	ffffa097          	auipc	ra,0xffffa
    800065c0:	fce080e7          	jalr	-50(ra) # 8000058a <printf>
			if ((i+1) % 16 == 0) {
    800065c4:	00f4fc93          	andi	s9,s1,15
    800065c8:	080c8263          	beqz	s9,8000664c <dump_hex+0x124>
			} else if (i+1 == size) {
    800065cc:	fb349fe3          	bne	s1,s3,8000658a <dump_hex+0x62>
				ascii[(i+1) % 16] = '\0';
    800065d0:	fa0c8793          	addi	a5,s9,-96
    800065d4:	97a2                	add	a5,a5,s0
    800065d6:	fe078423          	sb	zero,-24(a5)
				if ((i+1) % 16 <= 8) {
    800065da:	47a1                	li	a5,8
    800065dc:	0597f663          	bgeu	a5,s9,80006628 <dump_hex+0x100>
					printf(" ");
				}
				for (j = (i+1) % 16; j < 16; ++j) {
					printf("   ");
    800065e0:	00002917          	auipc	s2,0x2
    800065e4:	32890913          	addi	s2,s2,808 # 80008908 <syscalls+0x4a0>
				for (j = (i+1) % 16; j < 16; ++j) {
    800065e8:	44bd                	li	s1,15
					printf("   ");
    800065ea:	854a                	mv	a0,s2
    800065ec:	ffffa097          	auipc	ra,0xffffa
    800065f0:	f9e080e7          	jalr	-98(ra) # 8000058a <printf>
				for (j = (i+1) % 16; j < 16; ++j) {
    800065f4:	0c85                	addi	s9,s9,1
    800065f6:	ff94fae3          	bgeu	s1,s9,800065ea <dump_hex+0xc2>
				}
				printf("|  %s \n", ascii);
    800065fa:	f8840593          	addi	a1,s0,-120
    800065fe:	00002517          	auipc	a0,0x2
    80006602:	30250513          	addi	a0,a0,770 # 80008900 <syscalls+0x498>
    80006606:	ffffa097          	auipc	ra,0xffffa
    8000660a:	f84080e7          	jalr	-124(ra) # 8000058a <printf>
			}
		}
	}
    8000660e:	70e6                	ld	ra,120(sp)
    80006610:	7446                	ld	s0,112(sp)
    80006612:	74a6                	ld	s1,104(sp)
    80006614:	7906                	ld	s2,96(sp)
    80006616:	69e6                	ld	s3,88(sp)
    80006618:	6a46                	ld	s4,80(sp)
    8000661a:	6aa6                	ld	s5,72(sp)
    8000661c:	6b06                	ld	s6,64(sp)
    8000661e:	7be2                	ld	s7,56(sp)
    80006620:	7c42                	ld	s8,48(sp)
    80006622:	7ca2                	ld	s9,40(sp)
    80006624:	6109                	addi	sp,sp,128
    80006626:	8082                	ret
					printf(" ");
    80006628:	00002517          	auipc	a0,0x2
    8000662c:	2d050513          	addi	a0,a0,720 # 800088f8 <syscalls+0x490>
    80006630:	ffffa097          	auipc	ra,0xffffa
    80006634:	f5a080e7          	jalr	-166(ra) # 8000058a <printf>
    80006638:	b765                	j	800065e0 <dump_hex+0xb8>
			printf(" ");
    8000663a:	855e                	mv	a0,s7
    8000663c:	ffffa097          	auipc	ra,0xffffa
    80006640:	f4e080e7          	jalr	-178(ra) # 8000058a <printf>
			if ((i+1) % 16 == 0) {
    80006644:	00f9fc93          	andi	s9,s3,15
    80006648:	f80c94e3          	bnez	s9,800065d0 <dump_hex+0xa8>
				printf("|  %s \n", ascii);
    8000664c:	f8840593          	addi	a1,s0,-120
    80006650:	8562                	mv	a0,s8
    80006652:	ffffa097          	auipc	ra,0xffffa
    80006656:	f38080e7          	jalr	-200(ra) # 8000058a <printf>
	for (i = 0; i < size; ++i) {
    8000665a:	fb348ae3          	beq	s1,s3,8000660e <dump_hex+0xe6>
    8000665e:	0905                	addi	s2,s2,1
    80006660:	b735                	j	8000658c <dump_hex+0x64>

0000000080006662 <get_vm_privileged_register>:
} vm;

int allowed_mode = 3;

uint64 *get_vm_privileged_register(uint32 reg, struct vm_virtual_state *vm)
{
    80006662:	1141                	addi	sp,sp,-16
    80006664:	e422                	sd	s0,8(sp)
    80006666:	0800                	addi	s0,sp,16
    int base_reg = 0;
    uint64 base_addr = 0;

    // Machine trap handling registers
    if (reg >= 0x340 && reg <= 0x344)
    80006668:	cc05071b          	addiw	a4,a0,-832
    8000666c:	4791                	li	a5,4
    8000666e:	02e7e363          	bltu	a5,a4,80006694 <get_vm_privileged_register+0x32>
    {
        base_reg = 0x340;
        base_addr = (uint64)&vm->mscratch;
    80006672:	872e                	mv	a4,a1
        allowed_mode = 3;
    80006674:	478d                	li	a5,3
    80006676:	00002697          	auipc	a3,0x2
    8000667a:	30f6a123          	sw	a5,770(a3) # 80008978 <allowed_mode>
        base_reg = 0x340;
    8000667e:	34000793          	li	a5,832
    {
        base_reg = 0x004;
        base_addr = (uint64)&vm->uie;
        allowed_mode = 1;
    }
    return (uint64 *)((reg - base_reg) * 8 + base_addr);
    80006682:	9d1d                	subw	a0,a0,a5
    80006684:	0035151b          	slliw	a0,a0,0x3
    80006688:	1502                	slli	a0,a0,0x20
    8000668a:	9101                	srli	a0,a0,0x20
}
    8000668c:	953a                	add	a0,a0,a4
    8000668e:	6422                	ld	s0,8(sp)
    80006690:	0141                	addi	sp,sp,16
    80006692:	8082                	ret
    else if (reg >= 0x34A && reg <= 0x34B)
    80006694:	cb65079b          	addiw	a5,a0,-842
    80006698:	4705                	li	a4,1
    8000669a:	02f77163          	bgeu	a4,a5,800066bc <get_vm_privileged_register+0x5a>
    else if (reg >= 0x300 && reg <= 0x306)
    8000669e:	d005079b          	addiw	a5,a0,-768
    800066a2:	4719                	li	a4,6
    800066a4:	02f76663          	bltu	a4,a5,800066d0 <get_vm_privileged_register+0x6e>
        base_addr = (uint64)&vm->mstatus;
    800066a8:	03858713          	addi	a4,a1,56
        allowed_mode = 3;
    800066ac:	478d                	li	a5,3
    800066ae:	00002697          	auipc	a3,0x2
    800066b2:	2cf6a523          	sw	a5,714(a3) # 80008978 <allowed_mode>
        base_reg = 0x300;
    800066b6:	30000793          	li	a5,768
    800066ba:	b7e1                	j	80006682 <get_vm_privileged_register+0x20>
        base_addr = (uint64)&vm->mtinst;
    800066bc:	02858713          	addi	a4,a1,40
        allowed_mode = 3;
    800066c0:	478d                	li	a5,3
    800066c2:	00002697          	auipc	a3,0x2
    800066c6:	2af6ab23          	sw	a5,694(a3) # 80008978 <allowed_mode>
        base_reg = 0x34A;
    800066ca:	34a00793          	li	a5,842
    800066ce:	bf55                	j	80006682 <get_vm_privileged_register+0x20>
    else if (reg == 0x310)
    800066d0:	31000793          	li	a5,784
    800066d4:	02f50463          	beq	a0,a5,800066fc <get_vm_privileged_register+0x9a>
    else if (reg >= 0xf11 && reg <= 0xf14)
    800066d8:	77fd                	lui	a5,0xfffff
    800066da:	0ef7879b          	addiw	a5,a5,239 # fffffffffffff0ef <end+0xffffffff7ffdcca7>
    800066de:	9fa9                	addw	a5,a5,a0
    800066e0:	470d                	li	a4,3
    800066e2:	02f76763          	bltu	a4,a5,80006710 <get_vm_privileged_register+0xae>
        base_addr = (uint64)&vm->mvendorid;
    800066e6:	07858713          	addi	a4,a1,120
        allowed_mode = 3;
    800066ea:	478d                	li	a5,3
    800066ec:	00002697          	auipc	a3,0x2
    800066f0:	28f6a623          	sw	a5,652(a3) # 80008978 <allowed_mode>
        base_reg = 0xf11;
    800066f4:	6785                	lui	a5,0x1
    800066f6:	f1178793          	addi	a5,a5,-239 # f11 <_entry-0x7ffff0ef>
    800066fa:	b761                	j	80006682 <get_vm_privileged_register+0x20>
        base_addr = (uint64)&vm->mstatush;
    800066fc:	07058713          	addi	a4,a1,112
        allowed_mode = 3;
    80006700:	478d                	li	a5,3
    80006702:	00002697          	auipc	a3,0x2
    80006706:	26f6ab23          	sw	a5,630(a3) # 80008978 <allowed_mode>
        base_reg = 0x310;
    8000670a:	31000793          	li	a5,784
    8000670e:	bf95                	j	80006682 <get_vm_privileged_register+0x20>
    else if (reg >= 0x3a0 && reg <= 0x3ef)
    80006710:	c605079b          	addiw	a5,a0,-928
    80006714:	04f00713          	li	a4,79
    80006718:	02f76563          	bltu	a4,a5,80006742 <get_vm_privileged_register+0xe0>
        base_addr = (uint64)&vm->pmpcfg;
    8000671c:	09858713          	addi	a4,a1,152
        allowed_mode = 3;
    80006720:	478d                	li	a5,3
    80006722:	00002697          	auipc	a3,0x2
    80006726:	24f6ab23          	sw	a5,598(a3) # 80008978 <allowed_mode>
        if (reg <= base_reg + 15)
    8000672a:	3af00693          	li	a3,943
        base_reg = 0x3a0;
    8000672e:	3a000793          	li	a5,928
        if (reg <= base_reg + 15)
    80006732:	f4a6e8e3          	bltu	a3,a0,80006682 <get_vm_privileged_register+0x20>
            vm->pmp_setup = 1;
    80006736:	4785                	li	a5,1
    80006738:	3cf5a223          	sw	a5,964(a1)
        base_reg = 0x3a0;
    8000673c:	3a000793          	li	a5,928
    80006740:	b789                	j	80006682 <get_vm_privileged_register+0x20>
    else if (reg == 0x180)
    80006742:	18000793          	li	a5,384
    80006746:	02f50163          	beq	a0,a5,80006768 <get_vm_privileged_register+0x106>
    else if (reg >= 0x140 && reg <= 0x144)
    8000674a:	ec05079b          	addiw	a5,a0,-320
    8000674e:	4711                	li	a4,4
    80006750:	02f76663          	bltu	a4,a5,8000677c <get_vm_privileged_register+0x11a>
        base_addr = (uint64)&vm->sscratch;
    80006754:	32058713          	addi	a4,a1,800
        allowed_mode = 1;
    80006758:	4785                	li	a5,1
    8000675a:	00002697          	auipc	a3,0x2
    8000675e:	20f6af23          	sw	a5,542(a3) # 80008978 <allowed_mode>
        base_reg = 0x140;
    80006762:	14000793          	li	a5,320
    80006766:	bf31                	j	80006682 <get_vm_privileged_register+0x20>
        base_addr = (uint64)&vm->satp;
    80006768:	31858713          	addi	a4,a1,792
        allowed_mode = 1;
    8000676c:	4785                	li	a5,1
    8000676e:	00002697          	auipc	a3,0x2
    80006772:	20f6a523          	sw	a5,522(a3) # 80008978 <allowed_mode>
        base_reg = 0x180;
    80006776:	18000793          	li	a5,384
    8000677a:	b721                	j	80006682 <get_vm_privileged_register+0x20>
    else if (reg == 0x100)
    8000677c:	10000793          	li	a5,256
    80006780:	02f50163          	beq	a0,a5,800067a2 <get_vm_privileged_register+0x140>
    else if (reg >= 0x102 && reg <= 0x106)
    80006784:	efe5079b          	addiw	a5,a0,-258
    80006788:	4711                	li	a4,4
    8000678a:	02f76663          	bltu	a4,a5,800067b6 <get_vm_privileged_register+0x154>
        base_addr = (uint64)&vm->sedeleg;
    8000678e:	35058713          	addi	a4,a1,848
        allowed_mode = 1;
    80006792:	4785                	li	a5,1
    80006794:	00002697          	auipc	a3,0x2
    80006798:	1ef6a223          	sw	a5,484(a3) # 80008978 <allowed_mode>
        base_reg = 0x102;
    8000679c:	10200793          	li	a5,258
    800067a0:	b5cd                	j	80006682 <get_vm_privileged_register+0x20>
        base_addr = (uint64)&vm->sstatus;
    800067a2:	34858713          	addi	a4,a1,840
        allowed_mode = 1;
    800067a6:	4785                	li	a5,1
    800067a8:	00002697          	auipc	a3,0x2
    800067ac:	1cf6a823          	sw	a5,464(a3) # 80008978 <allowed_mode>
        base_reg = 0x100;
    800067b0:	10000793          	li	a5,256
    800067b4:	b5f9                	j	80006682 <get_vm_privileged_register+0x20>
    else if (reg >= 0x040 && reg <= 0x044)
    800067b6:	fc05079b          	addiw	a5,a0,-64
    800067ba:	4711                	li	a4,4
    800067bc:	00f76c63          	bltu	a4,a5,800067d4 <get_vm_privileged_register+0x172>
        base_addr = (uint64)&vm->uscratch;
    800067c0:	37858713          	addi	a4,a1,888
        allowed_mode = 1;
    800067c4:	4785                	li	a5,1
    800067c6:	00002697          	auipc	a3,0x2
    800067ca:	1af6a923          	sw	a5,434(a3) # 80008978 <allowed_mode>
        base_reg = 0x040;
    800067ce:	04000793          	li	a5,64
    800067d2:	bd45                	j	80006682 <get_vm_privileged_register+0x20>
    else if (reg == 0x000)
    800067d4:	e911                	bnez	a0,800067e8 <get_vm_privileged_register+0x186>
        base_addr = (uint64)&vm->ustatus;
    800067d6:	3a058713          	addi	a4,a1,928
        allowed_mode = 1;
    800067da:	4785                	li	a5,1
    800067dc:	00002697          	auipc	a3,0x2
    800067e0:	18f6ae23          	sw	a5,412(a3) # 80008978 <allowed_mode>
        base_reg = 0x000;
    800067e4:	4781                	li	a5,0
    800067e6:	bd71                	j	80006682 <get_vm_privileged_register+0x20>
    else if (reg >= 0x004 && reg <= 0x005)
    800067e8:	ffc5079b          	addiw	a5,a0,-4
    800067ec:	4705                	li	a4,1
    800067ee:	00f77563          	bgeu	a4,a5,800067f8 <get_vm_privileged_register+0x196>
    uint64 base_addr = 0;
    800067f2:	4701                	li	a4,0
    int base_reg = 0;
    800067f4:	4781                	li	a5,0
    800067f6:	b571                	j	80006682 <get_vm_privileged_register+0x20>
        base_addr = (uint64)&vm->uie;
    800067f8:	3a858713          	addi	a4,a1,936
        allowed_mode = 1;
    800067fc:	4785                	li	a5,1
    800067fe:	00002697          	auipc	a3,0x2
    80006802:	16f6ad23          	sw	a5,378(a3) # 80008978 <allowed_mode>
        base_reg = 0x004;
    80006806:	4791                	li	a5,4
    80006808:	bdad                	j	80006682 <get_vm_privileged_register+0x20>

000000008000680a <get_vm_trapframe_register>:

uint64 *get_vm_trapframe_register(uint32 reg, struct trapframe *tf)
{
    8000680a:	1141                	addi	sp,sp,-16
    8000680c:	e422                	sd	s0,8(sp)
    8000680e:	0800                	addi	s0,sp,16
    uint64 base_reg = 1;
    uint64 base_addr = (uint64)&tf->ra;
    return (uint64 *)((reg - base_reg) * 8 + base_addr);
    80006810:	02051793          	slli	a5,a0,0x20
    80006814:	01d7d513          	srli	a0,a5,0x1d
    uint64 base_addr = (uint64)&tf->ra;
    80006818:	952e                	add	a0,a0,a1
}
    8000681a:	02050513          	addi	a0,a0,32
    8000681e:	6422                	ld	s0,8(sp)
    80006820:	0141                	addi	sp,sp,16
    80006822:	8082                	ret

0000000080006824 <copy_psuedo>:
    pte_t *pte;
    uint64 pa, i;
    uint flags;
    //   char *mem;

    for (i = 0; i < sz; i += PGSIZE)
    80006824:	c64d                	beqz	a2,800068ce <copy_psuedo+0xaa>
{
    80006826:	7179                	addi	sp,sp,-48
    80006828:	f406                	sd	ra,40(sp)
    8000682a:	f022                	sd	s0,32(sp)
    8000682c:	ec26                	sd	s1,24(sp)
    8000682e:	e84a                	sd	s2,16(sp)
    80006830:	e44e                	sd	s3,8(sp)
    80006832:	e052                	sd	s4,0(sp)
    80006834:	1800                	addi	s0,sp,48
    80006836:	8a2a                	mv	s4,a0
    80006838:	89ae                	mv	s3,a1
    8000683a:	8932                	mv	s2,a2
    for (i = 0; i < sz; i += PGSIZE)
    8000683c:	4481                	li	s1,0
    {
        if ((pte = walk(old, i, 0)) == 0)
    8000683e:	4601                	li	a2,0
    80006840:	85a6                	mv	a1,s1
    80006842:	8552                	mv	a0,s4
    80006844:	ffffa097          	auipc	ra,0xffffa
    80006848:	7ea080e7          	jalr	2026(ra) # 8000102e <walk>
    8000684c:	c51d                	beqz	a0,8000687a <copy_psuedo+0x56>
            panic("uvmcopy: pte should exist");
        if ((*pte & PTE_V) == 0)
    8000684e:	6118                	ld	a4,0(a0)
    80006850:	00177793          	andi	a5,a4,1
    80006854:	cb9d                	beqz	a5,8000688a <copy_psuedo+0x66>
            panic("uvmcopy: page not present");
        pa = PTE2PA(*pte);
    80006856:	00a75693          	srli	a3,a4,0xa
        flags = PTE_FLAGS(*pte);

        // if((mem = kalloc()) == 0)
        //   goto err;
        // memmove(mem, (char*)pa, PGSIZE);
        if (mappages(new, i, PGSIZE, pa, flags) != 0)
    8000685a:	3ff77713          	andi	a4,a4,1023
    8000685e:	06b2                	slli	a3,a3,0xc
    80006860:	6605                	lui	a2,0x1
    80006862:	85a6                	mv	a1,s1
    80006864:	854e                	mv	a0,s3
    80006866:	ffffb097          	auipc	ra,0xffffb
    8000686a:	8b0080e7          	jalr	-1872(ra) # 80001116 <mappages>
    8000686e:	e515                	bnez	a0,8000689a <copy_psuedo+0x76>
    for (i = 0; i < sz; i += PGSIZE)
    80006870:	6785                	lui	a5,0x1
    80006872:	94be                	add	s1,s1,a5
    80006874:	fd24e5e3          	bltu	s1,s2,8000683e <copy_psuedo+0x1a>
    80006878:	a099                	j	800068be <copy_psuedo+0x9a>
            panic("uvmcopy: pte should exist");
    8000687a:	00002517          	auipc	a0,0x2
    8000687e:	90e50513          	addi	a0,a0,-1778 # 80008188 <digits+0x148>
    80006882:	ffffa097          	auipc	ra,0xffffa
    80006886:	cbe080e7          	jalr	-834(ra) # 80000540 <panic>
            panic("uvmcopy: page not present");
    8000688a:	00002517          	auipc	a0,0x2
    8000688e:	91e50513          	addi	a0,a0,-1762 # 800081a8 <digits+0x168>
    80006892:	ffffa097          	auipc	ra,0xffffa
    80006896:	cae080e7          	jalr	-850(ra) # 80000540 <panic>
        {
            printf("------ERROR");
    8000689a:	00002517          	auipc	a0,0x2
    8000689e:	07650513          	addi	a0,a0,118 # 80008910 <syscalls+0x4a8>
    800068a2:	ffffa097          	auipc	ra,0xffffa
    800068a6:	ce8080e7          	jalr	-792(ra) # 8000058a <printf>
        }
    }
    return 0;

err:
    uvmunmap(new, 0, i / PGSIZE, 1);
    800068aa:	4685                	li	a3,1
    800068ac:	00c4d613          	srli	a2,s1,0xc
    800068b0:	4581                	li	a1,0
    800068b2:	854e                	mv	a0,s3
    800068b4:	ffffb097          	auipc	ra,0xffffb
    800068b8:	a28080e7          	jalr	-1496(ra) # 800012dc <uvmunmap>
    return -1;
    800068bc:	557d                	li	a0,-1
}
    800068be:	70a2                	ld	ra,40(sp)
    800068c0:	7402                	ld	s0,32(sp)
    800068c2:	64e2                	ld	s1,24(sp)
    800068c4:	6942                	ld	s2,16(sp)
    800068c6:	69a2                	ld	s3,8(sp)
    800068c8:	6a02                	ld	s4,0(sp)
    800068ca:	6145                	addi	sp,sp,48
    800068cc:	8082                	ret
    return 0;
    800068ce:	4501                	li	a0,0
}
    800068d0:	8082                	ret

00000000800068d2 <map_psuedo>:

int map_psuedo(pagetable_t old, pagetable_t new, uint64 lowerbound, uint64 upperbound)
{
    800068d2:	7179                	addi	sp,sp,-48
    800068d4:	f406                	sd	ra,40(sp)
    800068d6:	f022                	sd	s0,32(sp)
    800068d8:	ec26                	sd	s1,24(sp)
    800068da:	e84a                	sd	s2,16(sp)
    800068dc:	e44e                	sd	s3,8(sp)
    800068de:	e052                	sd	s4,0(sp)
    800068e0:	1800                	addi	s0,sp,48
    800068e2:	8a2a                	mv	s4,a0
    800068e4:	89ae                	mv	s3,a1
    800068e6:	84b2                	mv	s1,a2
    800068e8:	8936                	mv	s2,a3

    pte_t *pte;
    uint64 pa, i;
    uint flags;
    for (i = lowerbound; i < upperbound; i += PGSIZE)
    800068ea:	08d67a63          	bgeu	a2,a3,8000697e <map_psuedo+0xac>
    {
        if ((pte = walk(old, i, 0)) == 0)
    800068ee:	4601                	li	a2,0
    800068f0:	85a6                	mv	a1,s1
    800068f2:	8552                	mv	a0,s4
    800068f4:	ffffa097          	auipc	ra,0xffffa
    800068f8:	73a080e7          	jalr	1850(ra) # 8000102e <walk>
    800068fc:	c51d                	beqz	a0,8000692a <map_psuedo+0x58>
            panic("uvmcopy: pte should exist");
        if ((*pte & PTE_V) == 0)
    800068fe:	6118                	ld	a4,0(a0)
    80006900:	00177793          	andi	a5,a4,1
    80006904:	cb9d                	beqz	a5,8000693a <map_psuedo+0x68>
            panic("uvmcopy: page not present");
        pa = PTE2PA(*pte);
    80006906:	00a75693          	srli	a3,a4,0xa
        flags = PTE_FLAGS(*pte);

        // if((mem = kalloc()) == 0)
        //   goto err;
        // memmove(mem, (char*)pa, PGSIZE);
        if (mappages(new, i, PGSIZE, pa, flags) != 0)
    8000690a:	3ff77713          	andi	a4,a4,1023
    8000690e:	06b2                	slli	a3,a3,0xc
    80006910:	6605                	lui	a2,0x1
    80006912:	85a6                	mv	a1,s1
    80006914:	854e                	mv	a0,s3
    80006916:	ffffb097          	auipc	ra,0xffffb
    8000691a:	800080e7          	jalr	-2048(ra) # 80001116 <mappages>
    8000691e:	e515                	bnez	a0,8000694a <map_psuedo+0x78>
    for (i = lowerbound; i < upperbound; i += PGSIZE)
    80006920:	6785                	lui	a5,0x1
    80006922:	94be                	add	s1,s1,a5
    80006924:	fd24e5e3          	bltu	s1,s2,800068ee <map_psuedo+0x1c>
    80006928:	a099                	j	8000696e <map_psuedo+0x9c>
            panic("uvmcopy: pte should exist");
    8000692a:	00002517          	auipc	a0,0x2
    8000692e:	85e50513          	addi	a0,a0,-1954 # 80008188 <digits+0x148>
    80006932:	ffffa097          	auipc	ra,0xffffa
    80006936:	c0e080e7          	jalr	-1010(ra) # 80000540 <panic>
            panic("uvmcopy: page not present");
    8000693a:	00002517          	auipc	a0,0x2
    8000693e:	86e50513          	addi	a0,a0,-1938 # 800081a8 <digits+0x168>
    80006942:	ffffa097          	auipc	ra,0xffffa
    80006946:	bfe080e7          	jalr	-1026(ra) # 80000540 <panic>
        {
            printf("------ERROR");
    8000694a:	00002517          	auipc	a0,0x2
    8000694e:	fc650513          	addi	a0,a0,-58 # 80008910 <syscalls+0x4a8>
    80006952:	ffffa097          	auipc	ra,0xffffa
    80006956:	c38080e7          	jalr	-968(ra) # 8000058a <printf>
        }
    }

    return 0;
err:
    uvmunmap(new, 0, i / PGSIZE, 1);
    8000695a:	4685                	li	a3,1
    8000695c:	00c4d613          	srli	a2,s1,0xc
    80006960:	4581                	li	a1,0
    80006962:	854e                	mv	a0,s3
    80006964:	ffffb097          	auipc	ra,0xffffb
    80006968:	978080e7          	jalr	-1672(ra) # 800012dc <uvmunmap>
    return -1;
    8000696c:	557d                	li	a0,-1
}
    8000696e:	70a2                	ld	ra,40(sp)
    80006970:	7402                	ld	s0,32(sp)
    80006972:	64e2                	ld	s1,24(sp)
    80006974:	6942                	ld	s2,16(sp)
    80006976:	69a2                	ld	s3,8(sp)
    80006978:	6a02                	ld	s4,0(sp)
    8000697a:	6145                	addi	sp,sp,48
    8000697c:	8082                	ret
    return 0;
    8000697e:	4501                	li	a0,0
    80006980:	b7fd                	j	8000696e <map_psuedo+0x9c>

0000000080006982 <trap_and_emulate>:

void trap_and_emulate(void)
{
    80006982:	7139                	addi	sp,sp,-64
    80006984:	fc06                	sd	ra,56(sp)
    80006986:	f822                	sd	s0,48(sp)
    80006988:	f426                	sd	s1,40(sp)
    8000698a:	f04a                	sd	s2,32(sp)
    8000698c:	ec4e                	sd	s3,24(sp)
    8000698e:	e852                	sd	s4,16(sp)
    80006990:	e456                	sd	s5,8(sp)
    80006992:	0080                	addi	s0,sp,64
    /* Comes here when a VM tries to execute a supervisor instruction. */
    struct proc *p = myproc();
    80006994:	ffffb097          	auipc	ra,0xffffb
    80006998:	090080e7          	jalr	144(ra) # 80001a24 <myproc>
    8000699c:	892a                	mv	s2,a0
  asm volatile("csrr %0, sepc" : "=r" (x) );
    8000699e:	141029f3          	csrr	s3,sepc

    /* Retrieve all required values from the instruction */
    uint64 addr = r_sepc();
    char *pa = kalloc();
    800069a2:	ffffa097          	auipc	ra,0xffffa
    800069a6:	1b6080e7          	jalr	438(ra) # 80000b58 <kalloc>
    800069aa:	84aa                	mv	s1,a0
    copyin(p->pagetable, pa, addr, PGSIZE);
    800069ac:	6685                	lui	a3,0x1
    800069ae:	864e                	mv	a2,s3
    800069b0:	85aa                	mv	a1,a0
    800069b2:	05093503          	ld	a0,80(s2)
    800069b6:	ffffb097          	auipc	ra,0xffffb
    800069ba:	dba080e7          	jalr	-582(ra) # 80001770 <copyin>
    uint32 inst = *(uint32 *)pa;
    800069be:	0004a803          	lw	a6,0(s1)
    uint32 op = (inst)&0x7F;
    800069c2:	07f87613          	andi	a2,a6,127
    uint32 rd = (inst >> 7) & 0x1F;
    800069c6:	0078571b          	srliw	a4,a6,0x7
    800069ca:	01f77a13          	andi	s4,a4,31
    uint32 funct3 = (inst >> 12) & 0x7;
    800069ce:	00c8579b          	srliw	a5,a6,0xc
    800069d2:	8b9d                	andi	a5,a5,7
    uint32 rs1 = (inst >> 15) & 0x1F;
    800069d4:	00f8569b          	srliw	a3,a6,0xf
    800069d8:	01f6fa93          	andi	s5,a3,31
    uint32 uimm = (inst) >> 20 & 0xFFF;
    800069dc:	0148549b          	srliw	s1,a6,0x14
    // https://five-embeddev.com/quickref/interrupts.html
    // https://jborza.com/emulation/2021/04/22/ecalls-and-syscalls.html
    switch (funct3)
    800069e0:	4585                	li	a1,1
    800069e2:	1eb78163          	beq	a5,a1,80006bc4 <trap_and_emulate+0x242>
    800069e6:	4589                	li	a1,2
    800069e8:	30b78b63          	beq	a5,a1,80006cfe <trap_and_emulate+0x37c>
    800069ec:	cb91                	beqz	a5,80006a00 <trap_and_emulate+0x7e>
        break;
    }

    /* Print the statement */
    // printf("(PI at %p) op = %x, rd = %x, funct3 = %x, rs1 = %x, uimm = %x\n",addr, op, rd, funct3, rs1, uimm);
}
    800069ee:	70e2                	ld	ra,56(sp)
    800069f0:	7442                	ld	s0,48(sp)
    800069f2:	74a2                	ld	s1,40(sp)
    800069f4:	7902                	ld	s2,32(sp)
    800069f6:	69e2                	ld	s3,24(sp)
    800069f8:	6a42                	ld	s4,16(sp)
    800069fa:	6aa2                	ld	s5,8(sp)
    800069fc:	6121                	addi	sp,sp,64
    800069fe:	8082                	ret
        if (rd == 0x0 && rs1 == 0x0)
    80006a00:	8f55                	or	a4,a4,a3
    80006a02:	8b7d                	andi	a4,a4,31
    80006a04:	18071763          	bnez	a4,80006b92 <trap_and_emulate+0x210>
            if (uimm == 0x0 && p->proc_te_vm == 1) // ECALL
    80006a08:	e8f1                	bnez	s1,80006adc <trap_and_emulate+0x15a>
    80006a0a:	16892703          	lw	a4,360(s2)
    80006a0e:	4785                	li	a5,1
    80006a10:	02f70b63          	beq	a4,a5,80006a46 <trap_and_emulate+0xc4>
                printf("(PI at %p) op = %x, rd = %x, funct3 = %x, rs1 = %x, uimm = %x\n", addr, op, rd, funct3, rs1, uimm);
    80006a14:	8826                	mv	a6,s1
    80006a16:	87d6                	mv	a5,s5
    80006a18:	4701                	li	a4,0
    80006a1a:	86d2                	mv	a3,s4
    80006a1c:	85ce                	mv	a1,s3
    80006a1e:	00002517          	auipc	a0,0x2
    80006a22:	f1250513          	addi	a0,a0,-238 # 80008930 <syscalls+0x4c8>
    80006a26:	ffffa097          	auipc	ra,0xffffa
    80006a2a:	b64080e7          	jalr	-1180(ra) # 8000058a <printf>
                                p->pagetable = vm.og_pagetable;
    80006a2e:	0001c797          	auipc	a5,0x1c
    80006a32:	a127b783          	ld	a5,-1518(a5) # 80022440 <vm+0x3d0>
    80006a36:	04f93823          	sd	a5,80(s2)
                setkilled(p);
    80006a3a:	854a                	mv	a0,s2
    80006a3c:	ffffc097          	auipc	ra,0xffffc
    80006a40:	93a080e7          	jalr	-1734(ra) # 80002376 <setkilled>
    80006a44:	b76d                	j	800069ee <trap_and_emulate+0x6c>
                printf("(EC at %p)\n", p->trapframe->epc);
    80006a46:	05893783          	ld	a5,88(s2)
    80006a4a:	6f8c                	ld	a1,24(a5)
    80006a4c:	00002517          	auipc	a0,0x2
    80006a50:	ed450513          	addi	a0,a0,-300 # 80008920 <syscalls+0x4b8>
    80006a54:	ffffa097          	auipc	ra,0xffffa
    80006a58:	b36080e7          	jalr	-1226(ra) # 8000058a <printf>
                if (vm.priviledge_mode == 0)
    80006a5c:	0001c797          	auipc	a5,0x1c
    80006a60:	9cc7b783          	ld	a5,-1588(a5) # 80022428 <vm+0x3b8>
    80006a64:	ef95                	bnez	a5,80006aa0 <trap_and_emulate+0x11e>
                    vm.sepc = p->trapframe->epc;  // save pc in SEPC
    80006a66:	05893783          	ld	a5,88(s2)
    80006a6a:	6f98                	ld	a4,24(a5)
    80006a6c:	0001b797          	auipc	a5,0x1b
    80006a70:	60478793          	addi	a5,a5,1540 # 80022070 <vm>
    80006a74:	32e7b423          	sd	a4,808(a5)
                    vm.priviledge_mode = 1;       // raise privilege to S
    80006a78:	4705                	li	a4,1
    80006a7a:	3ae7bc23          	sd	a4,952(a5)
                    p->trapframe->epc = vm.stvec; // jump to STVEC
    80006a7e:	05893703          	ld	a4,88(s2)
    80006a82:	3687b683          	ld	a3,872(a5)
    80006a86:	ef14                	sd	a3,24(a4)
                    if (vm.pmp_setup == 2)
    80006a88:	3c47a703          	lw	a4,964(a5)
    80006a8c:	4789                	li	a5,2
    80006a8e:	f6f710e3          	bne	a4,a5,800069ee <trap_and_emulate+0x6c>
                        p->pagetable = vm.psuedo_pagetable;
    80006a92:	0001c797          	auipc	a5,0x1c
    80006a96:	9a67b783          	ld	a5,-1626(a5) # 80022438 <vm+0x3c8>
    80006a9a:	04f93823          	sd	a5,80(s2)
    80006a9e:	bf81                	j	800069ee <trap_and_emulate+0x6c>
                else if (vm.priviledge_mode == 1)
    80006aa0:	4705                	li	a4,1
    80006aa2:	f4e796e3          	bne	a5,a4,800069ee <trap_and_emulate+0x6c>
                    vm.mepc = p->trapframe->epc;  // save pc in MEPC
    80006aa6:	0001b797          	auipc	a5,0x1b
    80006aaa:	5ca78793          	addi	a5,a5,1482 # 80022070 <vm>
    80006aae:	05893703          	ld	a4,88(s2)
    80006ab2:	6f18                	ld	a4,24(a4)
    80006ab4:	e798                	sd	a4,8(a5)
                    vm.priviledge_mode = 3;                  // raise privilege to M
    80006ab6:	470d                	li	a4,3
    80006ab8:	3ae7bc23          	sd	a4,952(a5)
                    p->trapframe->epc = vm.mtvec; // jump to MTVEC
    80006abc:	05893703          	ld	a4,88(s2)
    80006ac0:	73b4                	ld	a3,96(a5)
    80006ac2:	ef14                	sd	a3,24(a4)
                    if (vm.pmp_setup == 2)
    80006ac4:	3c47a703          	lw	a4,964(a5)
    80006ac8:	4789                	li	a5,2
    80006aca:	f2f712e3          	bne	a4,a5,800069ee <trap_and_emulate+0x6c>
                        p->pagetable = vm.og_pagetable;
    80006ace:	0001c797          	auipc	a5,0x1c
    80006ad2:	9727b783          	ld	a5,-1678(a5) # 80022440 <vm+0x3d0>
    80006ad6:	04f93823          	sd	a5,80(s2)
    80006ada:	bf11                	j	800069ee <trap_and_emulate+0x6c>
            else if (uimm == 0x102 && vm.priviledge_mode == 1) // SRET
    80006adc:	10200793          	li	a5,258
    80006ae0:	06f48463          	beq	s1,a5,80006b48 <trap_and_emulate+0x1c6>
            else if (uimm == 0x302 && vm.priviledge_mode == 3) // MRET
    80006ae4:	30200793          	li	a5,770
    80006ae8:	f2f496e3          	bne	s1,a5,80006a14 <trap_and_emulate+0x92>
    80006aec:	0001c717          	auipc	a4,0x1c
    80006af0:	93c73703          	ld	a4,-1732(a4) # 80022428 <vm+0x3b8>
    80006af4:	478d                	li	a5,3
    80006af6:	f0f71fe3          	bne	a4,a5,80006a14 <trap_and_emulate+0x92>
                printf("(PI at %p) op = %x, rd = %x, funct3 = %x, rs1 = %x, uimm = %x\n", addr, op, rd, funct3, rs1, uimm);
    80006afa:	30200813          	li	a6,770
    80006afe:	87d6                	mv	a5,s5
    80006b00:	4701                	li	a4,0
    80006b02:	86d2                	mv	a3,s4
    80006b04:	85ce                	mv	a1,s3
    80006b06:	00002517          	auipc	a0,0x2
    80006b0a:	e2a50513          	addi	a0,a0,-470 # 80008930 <syscalls+0x4c8>
    80006b0e:	ffffa097          	auipc	ra,0xffffa
    80006b12:	a7c080e7          	jalr	-1412(ra) # 8000058a <printf>
                vm.priviledge_mode = (vm.mstatus & MSTATUS_MPP_MASK) >> 11;
    80006b16:	0001b717          	auipc	a4,0x1b
    80006b1a:	55a70713          	addi	a4,a4,1370 # 80022070 <vm>
    80006b1e:	7f1c                	ld	a5,56(a4)
    80006b20:	83ad                	srli	a5,a5,0xb
    80006b22:	8b8d                	andi	a5,a5,3
    80006b24:	3af73c23          	sd	a5,952(a4)
                p->trapframe->epc = vm.mepc;
    80006b28:	05893783          	ld	a5,88(s2)
    80006b2c:	6714                	ld	a3,8(a4)
    80006b2e:	ef94                	sd	a3,24(a5)
                if (vm.pmp_setup == 2)
    80006b30:	3c472703          	lw	a4,964(a4)
    80006b34:	4789                	li	a5,2
    80006b36:	eaf71ce3          	bne	a4,a5,800069ee <trap_and_emulate+0x6c>
                    p->pagetable = vm.psuedo_pagetable;
    80006b3a:	0001c797          	auipc	a5,0x1c
    80006b3e:	8fe7b783          	ld	a5,-1794(a5) # 80022438 <vm+0x3c8>
    80006b42:	04f93823          	sd	a5,80(s2)
    80006b46:	b565                	j	800069ee <trap_and_emulate+0x6c>
            else if (uimm == 0x102 && vm.priviledge_mode == 1) // SRET
    80006b48:	0001c717          	auipc	a4,0x1c
    80006b4c:	8e073703          	ld	a4,-1824(a4) # 80022428 <vm+0x3b8>
    80006b50:	4785                	li	a5,1
    80006b52:	ecf711e3          	bne	a4,a5,80006a14 <trap_and_emulate+0x92>
                printf("(PI at %p) op = %x, rd = %x, funct3 = %x, rs1 = %x, uimm = %x\n", addr, op, rd, funct3, rs1, uimm);
    80006b56:	10200813          	li	a6,258
    80006b5a:	87d6                	mv	a5,s5
    80006b5c:	4701                	li	a4,0
    80006b5e:	86d2                	mv	a3,s4
    80006b60:	85ce                	mv	a1,s3
    80006b62:	00002517          	auipc	a0,0x2
    80006b66:	dce50513          	addi	a0,a0,-562 # 80008930 <syscalls+0x4c8>
    80006b6a:	ffffa097          	auipc	ra,0xffffa
    80006b6e:	a20080e7          	jalr	-1504(ra) # 8000058a <printf>
                vm.priviledge_mode = (vm.sstatus & SSTATUS_SPP) >> 8;
    80006b72:	0001b717          	auipc	a4,0x1b
    80006b76:	4fe70713          	addi	a4,a4,1278 # 80022070 <vm>
    80006b7a:	34873783          	ld	a5,840(a4)
    80006b7e:	83a1                	srli	a5,a5,0x8
    80006b80:	8b85                	andi	a5,a5,1
    80006b82:	3af73c23          	sd	a5,952(a4)
                p->trapframe->epc = vm.sepc;
    80006b86:	05893783          	ld	a5,88(s2)
    80006b8a:	32873703          	ld	a4,808(a4)
    80006b8e:	ef98                	sd	a4,24(a5)
    80006b90:	bdb9                	j	800069ee <trap_and_emulate+0x6c>
            printf("(PI at %p) op = %x, rd = %x, funct3 = %x, rs1 = %x, uimm = %x\n", addr, op, rd, funct3, rs1, uimm);
    80006b92:	8826                	mv	a6,s1
    80006b94:	87d6                	mv	a5,s5
    80006b96:	4701                	li	a4,0
    80006b98:	86d2                	mv	a3,s4
    80006b9a:	85ce                	mv	a1,s3
    80006b9c:	00002517          	auipc	a0,0x2
    80006ba0:	d9450513          	addi	a0,a0,-620 # 80008930 <syscalls+0x4c8>
    80006ba4:	ffffa097          	auipc	ra,0xffffa
    80006ba8:	9e6080e7          	jalr	-1562(ra) # 8000058a <printf>
                            p->pagetable = vm.og_pagetable;
    80006bac:	0001c797          	auipc	a5,0x1c
    80006bb0:	8947b783          	ld	a5,-1900(a5) # 80022440 <vm+0x3d0>
    80006bb4:	04f93823          	sd	a5,80(s2)
            setkilled(p);
    80006bb8:	854a                	mv	a0,s2
    80006bba:	ffffb097          	auipc	ra,0xffffb
    80006bbe:	7bc080e7          	jalr	1980(ra) # 80002376 <setkilled>
    80006bc2:	b535                	j	800069ee <trap_and_emulate+0x6c>
        if (rd == 0x0 && uimm != 0xf11) // CSRW
    80006bc4:	000a1763          	bnez	s4,80006bd2 <trap_and_emulate+0x250>
    80006bc8:	6785                	lui	a5,0x1
    80006bca:	f1178793          	addi	a5,a5,-239 # f11 <_entry-0x7ffff0ef>
    80006bce:	02f49b63          	bne	s1,a5,80006c04 <trap_and_emulate+0x282>
            printf("(PI at %p) op = %x, rd = %x, funct3 = %x, rs1 = %x, uimm = %x\n", addr, op, rd, funct3, rs1, uimm);
    80006bd2:	8826                	mv	a6,s1
    80006bd4:	87d6                	mv	a5,s5
    80006bd6:	4705                	li	a4,1
    80006bd8:	86d2                	mv	a3,s4
    80006bda:	85ce                	mv	a1,s3
    80006bdc:	00002517          	auipc	a0,0x2
    80006be0:	d5450513          	addi	a0,a0,-684 # 80008930 <syscalls+0x4c8>
    80006be4:	ffffa097          	auipc	ra,0xffffa
    80006be8:	9a6080e7          	jalr	-1626(ra) # 8000058a <printf>
            p->pagetable = vm.og_pagetable;
    80006bec:	0001c797          	auipc	a5,0x1c
    80006bf0:	8547b783          	ld	a5,-1964(a5) # 80022440 <vm+0x3d0>
    80006bf4:	04f93823          	sd	a5,80(s2)
            setkilled(p);
    80006bf8:	854a                	mv	a0,s2
    80006bfa:	ffffb097          	auipc	ra,0xffffb
    80006bfe:	77c080e7          	jalr	1916(ra) # 80002376 <setkilled>
    80006c02:	b3f5                	j	800069ee <trap_and_emulate+0x6c>
            printf("(PI at %p) op = %x, rd = %x, funct3 = %x, rs1 = %x, uimm = %x\n", addr, op, rd, funct3, rs1, uimm);
    80006c04:	8826                	mv	a6,s1
    80006c06:	87d6                	mv	a5,s5
    80006c08:	4705                	li	a4,1
    80006c0a:	4681                	li	a3,0
    80006c0c:	85ce                	mv	a1,s3
    80006c0e:	00002517          	auipc	a0,0x2
    80006c12:	d2250513          	addi	a0,a0,-734 # 80008930 <syscalls+0x4c8>
    80006c16:	ffffa097          	auipc	ra,0xffffa
    80006c1a:	974080e7          	jalr	-1676(ra) # 8000058a <printf>
            uint64 *src = get_vm_trapframe_register(rs1, p->trapframe);
    80006c1e:	05893a03          	ld	s4,88(s2)
            uint64 *dest = get_vm_privileged_register(uimm, &vm);
    80006c22:	0001b997          	auipc	s3,0x1b
    80006c26:	44e98993          	addi	s3,s3,1102 # 80022070 <vm>
    80006c2a:	85ce                	mv	a1,s3
    80006c2c:	8526                	mv	a0,s1
    80006c2e:	00000097          	auipc	ra,0x0
    80006c32:	a34080e7          	jalr	-1484(ra) # 80006662 <get_vm_privileged_register>
            if (vm.priviledge_mode >= allowed_mode && uimm != 0xf11)
    80006c36:	00002797          	auipc	a5,0x2
    80006c3a:	d427a783          	lw	a5,-702(a5) # 80008978 <allowed_mode>
    80006c3e:	3b89b703          	ld	a4,952(s3)
    80006c42:	08f76c63          	bltu	a4,a5,80006cda <trap_and_emulate+0x358>
    return (uint64 *)((reg - base_reg) * 8 + base_addr);
    80006c46:	1afd                	addi	s5,s5,-1
                *dest = *src;
    80006c48:	0a8e                	slli	s5,s5,0x3
    80006c4a:	9a56                	add	s4,s4,s5
    80006c4c:	028a3783          	ld	a5,40(s4)
    80006c50:	e11c                	sd	a5,0(a0)
                p->trapframe->epc += 4;
    80006c52:	05893703          	ld	a4,88(s2)
    80006c56:	6f1c                	ld	a5,24(a4)
    80006c58:	0791                	addi	a5,a5,4
    80006c5a:	ef1c                	sd	a5,24(a4)
                if (vm.pmp_setup == 1)
    80006c5c:	0001b717          	auipc	a4,0x1b
    80006c60:	7d872703          	lw	a4,2008(a4) # 80022434 <vm+0x3c4>
    80006c64:	4785                	li	a5,1
    80006c66:	d8f714e3          	bne	a4,a5,800069ee <trap_and_emulate+0x6c>
                    int bit_a = (*dest >> 3) & 1;
    80006c6a:	611c                	ld	a5,0(a0)
    80006c6c:	838d                	srli	a5,a5,0x3
                    if (bit_a == 1)
    80006c6e:	8b85                	andi	a5,a5,1
    80006c70:	e791                	bnez	a5,80006c7c <trap_and_emulate+0x2fa>
                        vm.pmp_setup = 0;
    80006c72:	0001b797          	auipc	a5,0x1b
    80006c76:	7c07a123          	sw	zero,1986(a5) # 80022434 <vm+0x3c4>
    80006c7a:	bb95                	j	800069ee <trap_and_emulate+0x6c>
                        uint64 pmp_addr0 = *(dest + 16);
    80006c7c:	08053983          	ld	s3,128(a0)
                        vm.og_pagetable = p->pagetable;
    80006c80:	05093783          	ld	a5,80(s2)
    80006c84:	0001b497          	auipc	s1,0x1b
    80006c88:	3ec48493          	addi	s1,s1,1004 # 80022070 <vm>
    80006c8c:	3cf4b823          	sd	a5,976(s1)
                        vm.psuedo_pagetable = proc_pagetable(p);
    80006c90:	854a                	mv	a0,s2
    80006c92:	ffffb097          	auipc	ra,0xffffb
    80006c96:	e56080e7          	jalr	-426(ra) # 80001ae8 <proc_pagetable>
    80006c9a:	85aa                	mv	a1,a0
    80006c9c:	3ca4b423          	sd	a0,968(s1)
                        copy_psuedo(vm.og_pagetable, vm.psuedo_pagetable, p->sz);
    80006ca0:	04893603          	ld	a2,72(s2)
    80006ca4:	3d04b503          	ld	a0,976(s1)
    80006ca8:	00000097          	auipc	ra,0x0
    80006cac:	b7c080e7          	jalr	-1156(ra) # 80006824 <copy_psuedo>
                        pmp_addr0 = pmp_addr0 << 2;
    80006cb0:	00299793          	slli	a5,s3,0x2
                        map_psuedo(vm.og_pagetable, vm.psuedo_pagetable, 0x80000000, PGROUNDUP(pmp_addr0));
    80006cb4:	6705                	lui	a4,0x1
    80006cb6:	177d                	addi	a4,a4,-1 # fff <_entry-0x7ffff001>
    80006cb8:	97ba                	add	a5,a5,a4
    80006cba:	76fd                	lui	a3,0xfffff
    80006cbc:	8efd                	and	a3,a3,a5
    80006cbe:	4605                	li	a2,1
    80006cc0:	067e                	slli	a2,a2,0x1f
    80006cc2:	3c84b583          	ld	a1,968(s1)
    80006cc6:	3d04b503          	ld	a0,976(s1)
    80006cca:	00000097          	auipc	ra,0x0
    80006cce:	c08080e7          	jalr	-1016(ra) # 800068d2 <map_psuedo>
                        vm.pmp_setup = 2;
    80006cd2:	4789                	li	a5,2
    80006cd4:	3cf4a223          	sw	a5,964(s1)
    80006cd8:	bb19                	j	800069ee <trap_and_emulate+0x6c>
                vm.sepc = p->trapframe->epc;  // save pc in SEPC
    80006cda:	05893783          	ld	a5,88(s2)
    80006cde:	6f98                	ld	a4,24(a5)
    80006ce0:	0001b797          	auipc	a5,0x1b
    80006ce4:	39078793          	addi	a5,a5,912 # 80022070 <vm>
    80006ce8:	32e7b423          	sd	a4,808(a5)
                vm.priviledge_mode = 1;       // raise privilege to S
    80006cec:	4705                	li	a4,1
    80006cee:	3ae7bc23          	sd	a4,952(a5)
                p->trapframe->epc = vm.stvec; // jump to STVEC
    80006cf2:	05893703          	ld	a4,88(s2)
    80006cf6:	3687b783          	ld	a5,872(a5)
    80006cfa:	ef1c                	sd	a5,24(a4)
    80006cfc:	b9cd                	j	800069ee <trap_and_emulate+0x6c>
        if (rs1 == 0x0) // CSRR
    80006cfe:	060a9e63          	bnez	s5,80006d7a <trap_and_emulate+0x3f8>
            printf("(PI at %p) op = %x, rd = %x, funct3 = %x, rs1 = %x, uimm = %x\n",
    80006d02:	8826                	mv	a6,s1
    80006d04:	4781                	li	a5,0
    80006d06:	4709                	li	a4,2
    80006d08:	86d2                	mv	a3,s4
    80006d0a:	85ce                	mv	a1,s3
    80006d0c:	00002517          	auipc	a0,0x2
    80006d10:	c2450513          	addi	a0,a0,-988 # 80008930 <syscalls+0x4c8>
    80006d14:	ffffa097          	auipc	ra,0xffffa
    80006d18:	876080e7          	jalr	-1930(ra) # 8000058a <printf>
            uint64 *src = get_vm_privileged_register(uimm, &vm);
    80006d1c:	0001b997          	auipc	s3,0x1b
    80006d20:	35498993          	addi	s3,s3,852 # 80022070 <vm>
    80006d24:	85ce                	mv	a1,s3
    80006d26:	8526                	mv	a0,s1
    80006d28:	00000097          	auipc	ra,0x0
    80006d2c:	93a080e7          	jalr	-1734(ra) # 80006662 <get_vm_privileged_register>
            uint64 *dest = get_vm_trapframe_register(rd, p->trapframe);
    80006d30:	05893783          	ld	a5,88(s2)
            if (vm.priviledge_mode >= allowed_mode)
    80006d34:	00002717          	auipc	a4,0x2
    80006d38:	c4472703          	lw	a4,-956(a4) # 80008978 <allowed_mode>
    80006d3c:	3b89b683          	ld	a3,952(s3)
    80006d40:	00e6ed63          	bltu	a3,a4,80006d5a <trap_and_emulate+0x3d8>
                *dest = *src;
    80006d44:	6118                	ld	a4,0(a0)
    return (uint64 *)((reg - base_reg) * 8 + base_addr);
    80006d46:	1a7d                	addi	s4,s4,-1
                *dest = *src;
    80006d48:	0a0e                	slli	s4,s4,0x3
    80006d4a:	97d2                	add	a5,a5,s4
    80006d4c:	f798                	sd	a4,40(a5)
                p->trapframe->epc += 4;
    80006d4e:	05893703          	ld	a4,88(s2)
    80006d52:	6f1c                	ld	a5,24(a4)
    80006d54:	0791                	addi	a5,a5,4
    80006d56:	ef1c                	sd	a5,24(a4)
    80006d58:	b959                	j	800069ee <trap_and_emulate+0x6c>
                vm.sepc = p->trapframe->epc;  // save pc in SEPC
    80006d5a:	6f98                	ld	a4,24(a5)
    80006d5c:	0001b797          	auipc	a5,0x1b
    80006d60:	31478793          	addi	a5,a5,788 # 80022070 <vm>
    80006d64:	32e7b423          	sd	a4,808(a5)
                vm.priviledge_mode = 1;       // raise privilege to S
    80006d68:	4705                	li	a4,1
    80006d6a:	3ae7bc23          	sd	a4,952(a5)
                p->trapframe->epc = vm.stvec; // jump to STVEC
    80006d6e:	05893703          	ld	a4,88(s2)
    80006d72:	3687b783          	ld	a5,872(a5)
    80006d76:	ef1c                	sd	a5,24(a4)
    80006d78:	b99d                	j	800069ee <trap_and_emulate+0x6c>
            printf("(PI at %p) op = %x, rd = %x, funct3 = %x, rs1 = %x, uimm = %x\n", addr, op, rd, funct3, rs1, uimm);
    80006d7a:	8826                	mv	a6,s1
    80006d7c:	87d6                	mv	a5,s5
    80006d7e:	4709                	li	a4,2
    80006d80:	86d2                	mv	a3,s4
    80006d82:	85ce                	mv	a1,s3
    80006d84:	00002517          	auipc	a0,0x2
    80006d88:	bac50513          	addi	a0,a0,-1108 # 80008930 <syscalls+0x4c8>
    80006d8c:	ffff9097          	auipc	ra,0xffff9
    80006d90:	7fe080e7          	jalr	2046(ra) # 8000058a <printf>
            p->pagetable = vm.og_pagetable;
    80006d94:	0001b797          	auipc	a5,0x1b
    80006d98:	6ac7b783          	ld	a5,1708(a5) # 80022440 <vm+0x3d0>
    80006d9c:	04f93823          	sd	a5,80(s2)
            setkilled(p);
    80006da0:	854a                	mv	a0,s2
    80006da2:	ffffb097          	auipc	ra,0xffffb
    80006da6:	5d4080e7          	jalr	1492(ra) # 80002376 <setkilled>
}
    80006daa:	b191                	j	800069ee <trap_and_emulate+0x6c>

0000000080006dac <trap_and_emulate_init>:

void trap_and_emulate_init(void)
{
    80006dac:	1141                	addi	sp,sp,-16
    80006dae:	e422                	sd	s0,8(sp)
    80006db0:	0800                	addi	s0,sp,16
    /* Create and initialize all state for the VM */
    // Initialize VM state struct
    //  vm = { 0 };   // Set all registers to zero
    vm.mvendorid = 0xc5e536; // Set mvendorid to "cse536" in hexadecimal
    80006db2:	0001b717          	auipc	a4,0x1b
    80006db6:	2be70713          	addi	a4,a4,702 # 80022070 <vm>
    80006dba:	00c5e7b7          	lui	a5,0xc5e
    80006dbe:	53678793          	addi	a5,a5,1334 # c5e536 <_entry-0x7f3a1aca>
    80006dc2:	ff3c                	sd	a5,120(a4)
    vm.priviledge_mode = 3;
    80006dc4:	478d                	li	a5,3
    80006dc6:	3af73c23          	sd	a5,952(a4)
    80006dca:	6422                	ld	s0,8(sp)
    80006dcc:	0141                	addi	sp,sp,16
    80006dce:	8082                	ret
	...

0000000080007000 <_trampoline>:
    80007000:	14051073          	csrw	sscratch,a0
    80007004:	02000537          	lui	a0,0x2000
    80007008:	357d                	addiw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    8000700a:	0536                	slli	a0,a0,0xd
    8000700c:	02153423          	sd	ra,40(a0)
    80007010:	02253823          	sd	sp,48(a0)
    80007014:	02353c23          	sd	gp,56(a0)
    80007018:	04453023          	sd	tp,64(a0)
    8000701c:	04553423          	sd	t0,72(a0)
    80007020:	04653823          	sd	t1,80(a0)
    80007024:	04753c23          	sd	t2,88(a0)
    80007028:	f120                	sd	s0,96(a0)
    8000702a:	f524                	sd	s1,104(a0)
    8000702c:	fd2c                	sd	a1,120(a0)
    8000702e:	e150                	sd	a2,128(a0)
    80007030:	e554                	sd	a3,136(a0)
    80007032:	e958                	sd	a4,144(a0)
    80007034:	ed5c                	sd	a5,152(a0)
    80007036:	0b053023          	sd	a6,160(a0)
    8000703a:	0b153423          	sd	a7,168(a0)
    8000703e:	0b253823          	sd	s2,176(a0)
    80007042:	0b353c23          	sd	s3,184(a0)
    80007046:	0d453023          	sd	s4,192(a0)
    8000704a:	0d553423          	sd	s5,200(a0)
    8000704e:	0d653823          	sd	s6,208(a0)
    80007052:	0d753c23          	sd	s7,216(a0)
    80007056:	0f853023          	sd	s8,224(a0)
    8000705a:	0f953423          	sd	s9,232(a0)
    8000705e:	0fa53823          	sd	s10,240(a0)
    80007062:	0fb53c23          	sd	s11,248(a0)
    80007066:	11c53023          	sd	t3,256(a0)
    8000706a:	11d53423          	sd	t4,264(a0)
    8000706e:	11e53823          	sd	t5,272(a0)
    80007072:	11f53c23          	sd	t6,280(a0)
    80007076:	140022f3          	csrr	t0,sscratch
    8000707a:	06553823          	sd	t0,112(a0)
    8000707e:	00853103          	ld	sp,8(a0)
    80007082:	02053203          	ld	tp,32(a0)
    80007086:	01053283          	ld	t0,16(a0)
    8000708a:	00053303          	ld	t1,0(a0)
    8000708e:	12000073          	sfence.vma
    80007092:	18031073          	csrw	satp,t1
    80007096:	12000073          	sfence.vma
    8000709a:	8282                	jr	t0

000000008000709c <userret>:
    8000709c:	12000073          	sfence.vma
    800070a0:	18051073          	csrw	satp,a0
    800070a4:	12000073          	sfence.vma
    800070a8:	02000537          	lui	a0,0x2000
    800070ac:	357d                	addiw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    800070ae:	0536                	slli	a0,a0,0xd
    800070b0:	02853083          	ld	ra,40(a0)
    800070b4:	03053103          	ld	sp,48(a0)
    800070b8:	03853183          	ld	gp,56(a0)
    800070bc:	04053203          	ld	tp,64(a0)
    800070c0:	04853283          	ld	t0,72(a0)
    800070c4:	05053303          	ld	t1,80(a0)
    800070c8:	05853383          	ld	t2,88(a0)
    800070cc:	7120                	ld	s0,96(a0)
    800070ce:	7524                	ld	s1,104(a0)
    800070d0:	7d2c                	ld	a1,120(a0)
    800070d2:	6150                	ld	a2,128(a0)
    800070d4:	6554                	ld	a3,136(a0)
    800070d6:	6958                	ld	a4,144(a0)
    800070d8:	6d5c                	ld	a5,152(a0)
    800070da:	0a053803          	ld	a6,160(a0)
    800070de:	0a853883          	ld	a7,168(a0)
    800070e2:	0b053903          	ld	s2,176(a0)
    800070e6:	0b853983          	ld	s3,184(a0)
    800070ea:	0c053a03          	ld	s4,192(a0)
    800070ee:	0c853a83          	ld	s5,200(a0)
    800070f2:	0d053b03          	ld	s6,208(a0)
    800070f6:	0d853b83          	ld	s7,216(a0)
    800070fa:	0e053c03          	ld	s8,224(a0)
    800070fe:	0e853c83          	ld	s9,232(a0)
    80007102:	0f053d03          	ld	s10,240(a0)
    80007106:	0f853d83          	ld	s11,248(a0)
    8000710a:	10053e03          	ld	t3,256(a0)
    8000710e:	10853e83          	ld	t4,264(a0)
    80007112:	11053f03          	ld	t5,272(a0)
    80007116:	11853f83          	ld	t6,280(a0)
    8000711a:	7928                	ld	a0,112(a0)
    8000711c:	10200073          	sret
	...
