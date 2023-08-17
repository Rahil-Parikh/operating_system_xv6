
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	00009117          	auipc	sp,0x9
    80000004:	bf010113          	addi	sp,sp,-1040 # 80008bf0 <stack0>
    80000008:	6505                	lui	a0,0x1
    8000000a:	f14025f3          	csrr	a1,mhartid
    8000000e:	0585                	addi	a1,a1,1
    80000010:	02b50533          	mul	a0,a0,a1
    80000014:	912a                	add	sp,sp,a0
    80000016:	076000ef          	jal	ra,8000008c <start>

000000008000001a <spin>:
    8000001a:	a001                	j	8000001a <spin>

000000008000001c <timerinit>:
// at timervec in kernelvec.S,
// which turns them into software interrupts for
// devintr() in trap.c.
void
timerinit()
{
    8000001c:	1141                	addi	sp,sp,-16
    8000001e:	e422                	sd	s0,8(sp)
    80000020:	0800                	addi	s0,sp,16
// which hart (core) is this?
static inline uint64
r_mhartid()
{
  uint64 x;
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    80000022:	f14027f3          	csrr	a5,mhartid
  // each CPU has a separate source of timer interrupts.
  int id = r_mhartid();
    80000026:	0007859b          	sext.w	a1,a5

  // ask the CLINT for a timer interrupt.
  int interval = 1000000; // cycles; about 1/10th second in qemu.
  *(uint64*)CLINT_MTIMECMP(id) = *(uint64*)CLINT_MTIME + interval;
    8000002a:	0037979b          	slliw	a5,a5,0x3
    8000002e:	02004737          	lui	a4,0x2004
    80000032:	97ba                	add	a5,a5,a4
    80000034:	0200c737          	lui	a4,0x200c
    80000038:	ff873703          	ld	a4,-8(a4) # 200bff8 <_entry-0x7dff4008>
    8000003c:	000f4637          	lui	a2,0xf4
    80000040:	24060613          	addi	a2,a2,576 # f4240 <_entry-0x7ff0bdc0>
    80000044:	9732                	add	a4,a4,a2
    80000046:	e398                	sd	a4,0(a5)

  // prepare information in scratch[] for timervec.
  // scratch[0..2] : space for timervec to save registers.
  // scratch[3] : address of CLINT MTIMECMP register.
  // scratch[4] : desired interval (in cycles) between timer interrupts.
  uint64 *scratch = &timer_scratch[id][0];
    80000048:	00259693          	slli	a3,a1,0x2
    8000004c:	96ae                	add	a3,a3,a1
    8000004e:	068e                	slli	a3,a3,0x3
    80000050:	00009717          	auipc	a4,0x9
    80000054:	a6070713          	addi	a4,a4,-1440 # 80008ab0 <timer_scratch>
    80000058:	9736                	add	a4,a4,a3
  scratch[3] = CLINT_MTIMECMP(id);
    8000005a:	ef1c                	sd	a5,24(a4)
  scratch[4] = interval;
    8000005c:	f310                	sd	a2,32(a4)
}

static inline void 
w_mscratch(uint64 x)
{
  asm volatile("csrw mscratch, %0" : : "r" (x));
    8000005e:	34071073          	csrw	mscratch,a4
  asm volatile("csrw mtvec, %0" : : "r" (x));
    80000062:	00006797          	auipc	a5,0x6
    80000066:	c6e78793          	addi	a5,a5,-914 # 80005cd0 <timervec>
    8000006a:	30579073          	csrw	mtvec,a5
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    8000006e:	300027f3          	csrr	a5,mstatus

  // set the machine-mode trap handler.
  w_mtvec((uint64)timervec);

  // enable machine-mode interrupts.
  w_mstatus(r_mstatus() | MSTATUS_MIE);
    80000072:	0087e793          	ori	a5,a5,8
  asm volatile("csrw mstatus, %0" : : "r" (x));
    80000076:	30079073          	csrw	mstatus,a5
  asm volatile("csrr %0, mie" : "=r" (x) );
    8000007a:	304027f3          	csrr	a5,mie

  // enable machine-mode timer interrupts.
  w_mie(r_mie() | MIE_MTIE);
    8000007e:	0807e793          	ori	a5,a5,128
  asm volatile("csrw mie, %0" : : "r" (x));
    80000082:	30479073          	csrw	mie,a5
}
    80000086:	6422                	ld	s0,8(sp)
    80000088:	0141                	addi	sp,sp,16
    8000008a:	8082                	ret

000000008000008c <start>:
{
    8000008c:	1141                	addi	sp,sp,-16
    8000008e:	e406                	sd	ra,8(sp)
    80000090:	e022                	sd	s0,0(sp)
    80000092:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    80000094:	300027f3          	csrr	a5,mstatus
  x &= ~MSTATUS_MPP_MASK;
    80000098:	7779                	lui	a4,0xffffe
    8000009a:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7fe650ef>
    8000009e:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    800000a0:	6705                	lui	a4,0x1
    800000a2:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    800000a6:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    800000a8:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    800000ac:	00001797          	auipc	a5,0x1
    800000b0:	dc678793          	addi	a5,a5,-570 # 80000e72 <main>
    800000b4:	34179073          	csrw	mepc,a5
  asm volatile("csrw satp, %0" : : "r" (x));
    800000b8:	4781                	li	a5,0
    800000ba:	18079073          	csrw	satp,a5
  asm volatile("csrw medeleg, %0" : : "r" (x));
    800000be:	67c1                	lui	a5,0x10
    800000c0:	17fd                	addi	a5,a5,-1 # ffff <_entry-0x7fff0001>
    800000c2:	30279073          	csrw	medeleg,a5
  asm volatile("csrw mideleg, %0" : : "r" (x));
    800000c6:	30379073          	csrw	mideleg,a5
  asm volatile("csrr %0, sie" : "=r" (x) );
    800000ca:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE | SIE_SSIE);
    800000ce:	2227e793          	ori	a5,a5,546
  asm volatile("csrw sie, %0" : : "r" (x));
    800000d2:	10479073          	csrw	sie,a5
  asm volatile("csrw pmpaddr0, %0" : : "r" (x));
    800000d6:	57fd                	li	a5,-1
    800000d8:	83a9                	srli	a5,a5,0xa
    800000da:	3b079073          	csrw	pmpaddr0,a5
  asm volatile("csrw pmpcfg0, %0" : : "r" (x));
    800000de:	47bd                	li	a5,15
    800000e0:	3a079073          	csrw	pmpcfg0,a5
  timerinit();
    800000e4:	00000097          	auipc	ra,0x0
    800000e8:	f38080e7          	jalr	-200(ra) # 8000001c <timerinit>
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    800000ec:	f14027f3          	csrr	a5,mhartid
  w_tp(id);
    800000f0:	2781                	sext.w	a5,a5
}

static inline void 
w_tp(uint64 x)
{
  asm volatile("mv tp, %0" : : "r" (x));
    800000f2:	823e                	mv	tp,a5
  asm volatile("mret");
    800000f4:	30200073          	mret
}
    800000f8:	60a2                	ld	ra,8(sp)
    800000fa:	6402                	ld	s0,0(sp)
    800000fc:	0141                	addi	sp,sp,16
    800000fe:	8082                	ret

0000000080000100 <consolewrite>:
//
// user write()s to the console go here.
//
int
consolewrite(int user_src, uint64 src, int n)
{
    80000100:	715d                	addi	sp,sp,-80
    80000102:	e486                	sd	ra,72(sp)
    80000104:	e0a2                	sd	s0,64(sp)
    80000106:	fc26                	sd	s1,56(sp)
    80000108:	f84a                	sd	s2,48(sp)
    8000010a:	f44e                	sd	s3,40(sp)
    8000010c:	f052                	sd	s4,32(sp)
    8000010e:	ec56                	sd	s5,24(sp)
    80000110:	0880                	addi	s0,sp,80
  int i;

  for(i = 0; i < n; i++){
    80000112:	04c05763          	blez	a2,80000160 <consolewrite+0x60>
    80000116:	8a2a                	mv	s4,a0
    80000118:	84ae                	mv	s1,a1
    8000011a:	89b2                	mv	s3,a2
    8000011c:	4901                	li	s2,0
    char c;
    if(either_copyin(&c, user_src, src+i, 1) == -1)
    8000011e:	5afd                	li	s5,-1
    80000120:	4685                	li	a3,1
    80000122:	8626                	mv	a2,s1
    80000124:	85d2                	mv	a1,s4
    80000126:	fbf40513          	addi	a0,s0,-65
    8000012a:	00002097          	auipc	ra,0x2
    8000012e:	478080e7          	jalr	1144(ra) # 800025a2 <either_copyin>
    80000132:	01550d63          	beq	a0,s5,8000014c <consolewrite+0x4c>
      break;
    uartputc(c);
    80000136:	fbf44503          	lbu	a0,-65(s0)
    8000013a:	00000097          	auipc	ra,0x0
    8000013e:	780080e7          	jalr	1920(ra) # 800008ba <uartputc>
  for(i = 0; i < n; i++){
    80000142:	2905                	addiw	s2,s2,1
    80000144:	0485                	addi	s1,s1,1
    80000146:	fd299de3          	bne	s3,s2,80000120 <consolewrite+0x20>
    8000014a:	894e                	mv	s2,s3
  }

  return i;
}
    8000014c:	854a                	mv	a0,s2
    8000014e:	60a6                	ld	ra,72(sp)
    80000150:	6406                	ld	s0,64(sp)
    80000152:	74e2                	ld	s1,56(sp)
    80000154:	7942                	ld	s2,48(sp)
    80000156:	79a2                	ld	s3,40(sp)
    80000158:	7a02                	ld	s4,32(sp)
    8000015a:	6ae2                	ld	s5,24(sp)
    8000015c:	6161                	addi	sp,sp,80
    8000015e:	8082                	ret
  for(i = 0; i < n; i++){
    80000160:	4901                	li	s2,0
    80000162:	b7ed                	j	8000014c <consolewrite+0x4c>

0000000080000164 <consoleread>:
// user_dist indicates whether dst is a user
// or kernel address.
//
int
consoleread(int user_dst, uint64 dst, int n)
{
    80000164:	711d                	addi	sp,sp,-96
    80000166:	ec86                	sd	ra,88(sp)
    80000168:	e8a2                	sd	s0,80(sp)
    8000016a:	e4a6                	sd	s1,72(sp)
    8000016c:	e0ca                	sd	s2,64(sp)
    8000016e:	fc4e                	sd	s3,56(sp)
    80000170:	f852                	sd	s4,48(sp)
    80000172:	f456                	sd	s5,40(sp)
    80000174:	f05a                	sd	s6,32(sp)
    80000176:	ec5e                	sd	s7,24(sp)
    80000178:	1080                	addi	s0,sp,96
    8000017a:	8aaa                	mv	s5,a0
    8000017c:	8a2e                	mv	s4,a1
    8000017e:	89b2                	mv	s3,a2
  uint target;
  int c;
  char cbuf;

  target = n;
    80000180:	00060b1b          	sext.w	s6,a2
  acquire(&cons.lock);
    80000184:	00011517          	auipc	a0,0x11
    80000188:	a6c50513          	addi	a0,a0,-1428 # 80010bf0 <cons>
    8000018c:	00001097          	auipc	ra,0x1
    80000190:	a46080e7          	jalr	-1466(ra) # 80000bd2 <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    80000194:	00011497          	auipc	s1,0x11
    80000198:	a5c48493          	addi	s1,s1,-1444 # 80010bf0 <cons>
      if(killed(myproc())){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    8000019c:	00011917          	auipc	s2,0x11
    800001a0:	aec90913          	addi	s2,s2,-1300 # 80010c88 <cons+0x98>
  while(n > 0){
    800001a4:	09305263          	blez	s3,80000228 <consoleread+0xc4>
    while(cons.r == cons.w){
    800001a8:	0984a783          	lw	a5,152(s1)
    800001ac:	09c4a703          	lw	a4,156(s1)
    800001b0:	02f71763          	bne	a4,a5,800001de <consoleread+0x7a>
      if(killed(myproc())){
    800001b4:	00002097          	auipc	ra,0x2
    800001b8:	82e080e7          	jalr	-2002(ra) # 800019e2 <myproc>
    800001bc:	00002097          	auipc	ra,0x2
    800001c0:	234080e7          	jalr	564(ra) # 800023f0 <killed>
    800001c4:	ed2d                	bnez	a0,8000023e <consoleread+0xda>
      sleep(&cons.r, &cons.lock);
    800001c6:	85a6                	mv	a1,s1
    800001c8:	854a                	mv	a0,s2
    800001ca:	00002097          	auipc	ra,0x2
    800001ce:	f66080e7          	jalr	-154(ra) # 80002130 <sleep>
    while(cons.r == cons.w){
    800001d2:	0984a783          	lw	a5,152(s1)
    800001d6:	09c4a703          	lw	a4,156(s1)
    800001da:	fcf70de3          	beq	a4,a5,800001b4 <consoleread+0x50>
    }

    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];
    800001de:	00011717          	auipc	a4,0x11
    800001e2:	a1270713          	addi	a4,a4,-1518 # 80010bf0 <cons>
    800001e6:	0017869b          	addiw	a3,a5,1
    800001ea:	08d72c23          	sw	a3,152(a4)
    800001ee:	07f7f693          	andi	a3,a5,127
    800001f2:	9736                	add	a4,a4,a3
    800001f4:	01874703          	lbu	a4,24(a4)
    800001f8:	00070b9b          	sext.w	s7,a4

    if(c == C('D')){  // end-of-file
    800001fc:	4691                	li	a3,4
    800001fe:	06db8463          	beq	s7,a3,80000266 <consoleread+0x102>
      }
      break;
    }

    // copy the input byte to the user-space buffer.
    cbuf = c;
    80000202:	fae407a3          	sb	a4,-81(s0)
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    80000206:	4685                	li	a3,1
    80000208:	faf40613          	addi	a2,s0,-81
    8000020c:	85d2                	mv	a1,s4
    8000020e:	8556                	mv	a0,s5
    80000210:	00002097          	auipc	ra,0x2
    80000214:	33c080e7          	jalr	828(ra) # 8000254c <either_copyout>
    80000218:	57fd                	li	a5,-1
    8000021a:	00f50763          	beq	a0,a5,80000228 <consoleread+0xc4>
      break;

    dst++;
    8000021e:	0a05                	addi	s4,s4,1
    --n;
    80000220:	39fd                	addiw	s3,s3,-1

    if(c == '\n'){
    80000222:	47a9                	li	a5,10
    80000224:	f8fb90e3          	bne	s7,a5,800001a4 <consoleread+0x40>
      // a whole line has arrived, return to
      // the user-level read().
      break;
    }
  }
  release(&cons.lock);
    80000228:	00011517          	auipc	a0,0x11
    8000022c:	9c850513          	addi	a0,a0,-1592 # 80010bf0 <cons>
    80000230:	00001097          	auipc	ra,0x1
    80000234:	a56080e7          	jalr	-1450(ra) # 80000c86 <release>

  return target - n;
    80000238:	413b053b          	subw	a0,s6,s3
    8000023c:	a811                	j	80000250 <consoleread+0xec>
        release(&cons.lock);
    8000023e:	00011517          	auipc	a0,0x11
    80000242:	9b250513          	addi	a0,a0,-1614 # 80010bf0 <cons>
    80000246:	00001097          	auipc	ra,0x1
    8000024a:	a40080e7          	jalr	-1472(ra) # 80000c86 <release>
        return -1;
    8000024e:	557d                	li	a0,-1
}
    80000250:	60e6                	ld	ra,88(sp)
    80000252:	6446                	ld	s0,80(sp)
    80000254:	64a6                	ld	s1,72(sp)
    80000256:	6906                	ld	s2,64(sp)
    80000258:	79e2                	ld	s3,56(sp)
    8000025a:	7a42                	ld	s4,48(sp)
    8000025c:	7aa2                	ld	s5,40(sp)
    8000025e:	7b02                	ld	s6,32(sp)
    80000260:	6be2                	ld	s7,24(sp)
    80000262:	6125                	addi	sp,sp,96
    80000264:	8082                	ret
      if(n < target){
    80000266:	0009871b          	sext.w	a4,s3
    8000026a:	fb677fe3          	bgeu	a4,s6,80000228 <consoleread+0xc4>
        cons.r--;
    8000026e:	00011717          	auipc	a4,0x11
    80000272:	a0f72d23          	sw	a5,-1510(a4) # 80010c88 <cons+0x98>
    80000276:	bf4d                	j	80000228 <consoleread+0xc4>

0000000080000278 <consputc>:
{
    80000278:	1141                	addi	sp,sp,-16
    8000027a:	e406                	sd	ra,8(sp)
    8000027c:	e022                	sd	s0,0(sp)
    8000027e:	0800                	addi	s0,sp,16
  if(c == BACKSPACE){
    80000280:	10000793          	li	a5,256
    80000284:	00f50a63          	beq	a0,a5,80000298 <consputc+0x20>
    uartputc_sync(c);
    80000288:	00000097          	auipc	ra,0x0
    8000028c:	560080e7          	jalr	1376(ra) # 800007e8 <uartputc_sync>
}
    80000290:	60a2                	ld	ra,8(sp)
    80000292:	6402                	ld	s0,0(sp)
    80000294:	0141                	addi	sp,sp,16
    80000296:	8082                	ret
    uartputc_sync('\b'); uartputc_sync(' '); uartputc_sync('\b');
    80000298:	4521                	li	a0,8
    8000029a:	00000097          	auipc	ra,0x0
    8000029e:	54e080e7          	jalr	1358(ra) # 800007e8 <uartputc_sync>
    800002a2:	02000513          	li	a0,32
    800002a6:	00000097          	auipc	ra,0x0
    800002aa:	542080e7          	jalr	1346(ra) # 800007e8 <uartputc_sync>
    800002ae:	4521                	li	a0,8
    800002b0:	00000097          	auipc	ra,0x0
    800002b4:	538080e7          	jalr	1336(ra) # 800007e8 <uartputc_sync>
    800002b8:	bfe1                	j	80000290 <consputc+0x18>

00000000800002ba <consoleintr>:
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
//
void
consoleintr(int c)
{
    800002ba:	1101                	addi	sp,sp,-32
    800002bc:	ec06                	sd	ra,24(sp)
    800002be:	e822                	sd	s0,16(sp)
    800002c0:	e426                	sd	s1,8(sp)
    800002c2:	e04a                	sd	s2,0(sp)
    800002c4:	1000                	addi	s0,sp,32
    800002c6:	84aa                	mv	s1,a0
  acquire(&cons.lock);
    800002c8:	00011517          	auipc	a0,0x11
    800002cc:	92850513          	addi	a0,a0,-1752 # 80010bf0 <cons>
    800002d0:	00001097          	auipc	ra,0x1
    800002d4:	902080e7          	jalr	-1790(ra) # 80000bd2 <acquire>

  switch(c){
    800002d8:	47d5                	li	a5,21
    800002da:	0af48663          	beq	s1,a5,80000386 <consoleintr+0xcc>
    800002de:	0297ca63          	blt	a5,s1,80000312 <consoleintr+0x58>
    800002e2:	47a1                	li	a5,8
    800002e4:	0ef48763          	beq	s1,a5,800003d2 <consoleintr+0x118>
    800002e8:	47c1                	li	a5,16
    800002ea:	10f49a63          	bne	s1,a5,800003fe <consoleintr+0x144>
  case C('P'):  // Print process list.
    procdump();
    800002ee:	00002097          	auipc	ra,0x2
    800002f2:	30a080e7          	jalr	778(ra) # 800025f8 <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    800002f6:	00011517          	auipc	a0,0x11
    800002fa:	8fa50513          	addi	a0,a0,-1798 # 80010bf0 <cons>
    800002fe:	00001097          	auipc	ra,0x1
    80000302:	988080e7          	jalr	-1656(ra) # 80000c86 <release>
}
    80000306:	60e2                	ld	ra,24(sp)
    80000308:	6442                	ld	s0,16(sp)
    8000030a:	64a2                	ld	s1,8(sp)
    8000030c:	6902                	ld	s2,0(sp)
    8000030e:	6105                	addi	sp,sp,32
    80000310:	8082                	ret
  switch(c){
    80000312:	07f00793          	li	a5,127
    80000316:	0af48e63          	beq	s1,a5,800003d2 <consoleintr+0x118>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    8000031a:	00011717          	auipc	a4,0x11
    8000031e:	8d670713          	addi	a4,a4,-1834 # 80010bf0 <cons>
    80000322:	0a072783          	lw	a5,160(a4)
    80000326:	09872703          	lw	a4,152(a4)
    8000032a:	9f99                	subw	a5,a5,a4
    8000032c:	07f00713          	li	a4,127
    80000330:	fcf763e3          	bltu	a4,a5,800002f6 <consoleintr+0x3c>
      c = (c == '\r') ? '\n' : c;
    80000334:	47b5                	li	a5,13
    80000336:	0cf48763          	beq	s1,a5,80000404 <consoleintr+0x14a>
      consputc(c);
    8000033a:	8526                	mv	a0,s1
    8000033c:	00000097          	auipc	ra,0x0
    80000340:	f3c080e7          	jalr	-196(ra) # 80000278 <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    80000344:	00011797          	auipc	a5,0x11
    80000348:	8ac78793          	addi	a5,a5,-1876 # 80010bf0 <cons>
    8000034c:	0a07a683          	lw	a3,160(a5)
    80000350:	0016871b          	addiw	a4,a3,1
    80000354:	0007061b          	sext.w	a2,a4
    80000358:	0ae7a023          	sw	a4,160(a5)
    8000035c:	07f6f693          	andi	a3,a3,127
    80000360:	97b6                	add	a5,a5,a3
    80000362:	00978c23          	sb	s1,24(a5)
      if(c == '\n' || c == C('D') || cons.e-cons.r == INPUT_BUF_SIZE){
    80000366:	47a9                	li	a5,10
    80000368:	0cf48563          	beq	s1,a5,80000432 <consoleintr+0x178>
    8000036c:	4791                	li	a5,4
    8000036e:	0cf48263          	beq	s1,a5,80000432 <consoleintr+0x178>
    80000372:	00011797          	auipc	a5,0x11
    80000376:	9167a783          	lw	a5,-1770(a5) # 80010c88 <cons+0x98>
    8000037a:	9f1d                	subw	a4,a4,a5
    8000037c:	08000793          	li	a5,128
    80000380:	f6f71be3          	bne	a4,a5,800002f6 <consoleintr+0x3c>
    80000384:	a07d                	j	80000432 <consoleintr+0x178>
    while(cons.e != cons.w &&
    80000386:	00011717          	auipc	a4,0x11
    8000038a:	86a70713          	addi	a4,a4,-1942 # 80010bf0 <cons>
    8000038e:	0a072783          	lw	a5,160(a4)
    80000392:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    80000396:	00011497          	auipc	s1,0x11
    8000039a:	85a48493          	addi	s1,s1,-1958 # 80010bf0 <cons>
    while(cons.e != cons.w &&
    8000039e:	4929                	li	s2,10
    800003a0:	f4f70be3          	beq	a4,a5,800002f6 <consoleintr+0x3c>
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    800003a4:	37fd                	addiw	a5,a5,-1
    800003a6:	07f7f713          	andi	a4,a5,127
    800003aa:	9726                	add	a4,a4,s1
    while(cons.e != cons.w &&
    800003ac:	01874703          	lbu	a4,24(a4)
    800003b0:	f52703e3          	beq	a4,s2,800002f6 <consoleintr+0x3c>
      cons.e--;
    800003b4:	0af4a023          	sw	a5,160(s1)
      consputc(BACKSPACE);
    800003b8:	10000513          	li	a0,256
    800003bc:	00000097          	auipc	ra,0x0
    800003c0:	ebc080e7          	jalr	-324(ra) # 80000278 <consputc>
    while(cons.e != cons.w &&
    800003c4:	0a04a783          	lw	a5,160(s1)
    800003c8:	09c4a703          	lw	a4,156(s1)
    800003cc:	fcf71ce3          	bne	a4,a5,800003a4 <consoleintr+0xea>
    800003d0:	b71d                	j	800002f6 <consoleintr+0x3c>
    if(cons.e != cons.w){
    800003d2:	00011717          	auipc	a4,0x11
    800003d6:	81e70713          	addi	a4,a4,-2018 # 80010bf0 <cons>
    800003da:	0a072783          	lw	a5,160(a4)
    800003de:	09c72703          	lw	a4,156(a4)
    800003e2:	f0f70ae3          	beq	a4,a5,800002f6 <consoleintr+0x3c>
      cons.e--;
    800003e6:	37fd                	addiw	a5,a5,-1
    800003e8:	00011717          	auipc	a4,0x11
    800003ec:	8af72423          	sw	a5,-1880(a4) # 80010c90 <cons+0xa0>
      consputc(BACKSPACE);
    800003f0:	10000513          	li	a0,256
    800003f4:	00000097          	auipc	ra,0x0
    800003f8:	e84080e7          	jalr	-380(ra) # 80000278 <consputc>
    800003fc:	bded                	j	800002f6 <consoleintr+0x3c>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    800003fe:	ee048ce3          	beqz	s1,800002f6 <consoleintr+0x3c>
    80000402:	bf21                	j	8000031a <consoleintr+0x60>
      consputc(c);
    80000404:	4529                	li	a0,10
    80000406:	00000097          	auipc	ra,0x0
    8000040a:	e72080e7          	jalr	-398(ra) # 80000278 <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    8000040e:	00010797          	auipc	a5,0x10
    80000412:	7e278793          	addi	a5,a5,2018 # 80010bf0 <cons>
    80000416:	0a07a703          	lw	a4,160(a5)
    8000041a:	0017069b          	addiw	a3,a4,1
    8000041e:	0006861b          	sext.w	a2,a3
    80000422:	0ad7a023          	sw	a3,160(a5)
    80000426:	07f77713          	andi	a4,a4,127
    8000042a:	97ba                	add	a5,a5,a4
    8000042c:	4729                	li	a4,10
    8000042e:	00e78c23          	sb	a4,24(a5)
        cons.w = cons.e;
    80000432:	00011797          	auipc	a5,0x11
    80000436:	84c7ad23          	sw	a2,-1958(a5) # 80010c8c <cons+0x9c>
        wakeup(&cons.r);
    8000043a:	00011517          	auipc	a0,0x11
    8000043e:	84e50513          	addi	a0,a0,-1970 # 80010c88 <cons+0x98>
    80000442:	00002097          	auipc	ra,0x2
    80000446:	d52080e7          	jalr	-686(ra) # 80002194 <wakeup>
    8000044a:	b575                	j	800002f6 <consoleintr+0x3c>

000000008000044c <consoleinit>:

void
consoleinit(void)
{
    8000044c:	1141                	addi	sp,sp,-16
    8000044e:	e406                	sd	ra,8(sp)
    80000450:	e022                	sd	s0,0(sp)
    80000452:	0800                	addi	s0,sp,16
  initlock(&cons.lock, "cons");
    80000454:	00008597          	auipc	a1,0x8
    80000458:	bbc58593          	addi	a1,a1,-1092 # 80008010 <etext+0x10>
    8000045c:	00010517          	auipc	a0,0x10
    80000460:	79450513          	addi	a0,a0,1940 # 80010bf0 <cons>
    80000464:	00000097          	auipc	ra,0x0
    80000468:	6de080e7          	jalr	1758(ra) # 80000b42 <initlock>

  uartinit();
    8000046c:	00000097          	auipc	ra,0x0
    80000470:	32c080e7          	jalr	812(ra) # 80000798 <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    80000474:	00198797          	auipc	a5,0x198
    80000478:	d1c78793          	addi	a5,a5,-740 # 80198190 <devsw>
    8000047c:	00000717          	auipc	a4,0x0
    80000480:	ce870713          	addi	a4,a4,-792 # 80000164 <consoleread>
    80000484:	eb98                	sd	a4,16(a5)
  devsw[CONSOLE].write = consolewrite;
    80000486:	00000717          	auipc	a4,0x0
    8000048a:	c7a70713          	addi	a4,a4,-902 # 80000100 <consolewrite>
    8000048e:	ef98                	sd	a4,24(a5)
}
    80000490:	60a2                	ld	ra,8(sp)
    80000492:	6402                	ld	s0,0(sp)
    80000494:	0141                	addi	sp,sp,16
    80000496:	8082                	ret

0000000080000498 <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(int xx, int base, int sign)
{
    80000498:	7179                	addi	sp,sp,-48
    8000049a:	f406                	sd	ra,40(sp)
    8000049c:	f022                	sd	s0,32(sp)
    8000049e:	ec26                	sd	s1,24(sp)
    800004a0:	e84a                	sd	s2,16(sp)
    800004a2:	1800                	addi	s0,sp,48
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
    800004a4:	c219                	beqz	a2,800004aa <printint+0x12>
    800004a6:	08054763          	bltz	a0,80000534 <printint+0x9c>
    x = -xx;
  else
    x = xx;
    800004aa:	2501                	sext.w	a0,a0
    800004ac:	4881                	li	a7,0
    800004ae:	fd040693          	addi	a3,s0,-48

  i = 0;
    800004b2:	4701                	li	a4,0
  do {
    buf[i++] = digits[x % base];
    800004b4:	2581                	sext.w	a1,a1
    800004b6:	00008617          	auipc	a2,0x8
    800004ba:	b8a60613          	addi	a2,a2,-1142 # 80008040 <digits>
    800004be:	883a                	mv	a6,a4
    800004c0:	2705                	addiw	a4,a4,1
    800004c2:	02b577bb          	remuw	a5,a0,a1
    800004c6:	1782                	slli	a5,a5,0x20
    800004c8:	9381                	srli	a5,a5,0x20
    800004ca:	97b2                	add	a5,a5,a2
    800004cc:	0007c783          	lbu	a5,0(a5)
    800004d0:	00f68023          	sb	a5,0(a3)
  } while((x /= base) != 0);
    800004d4:	0005079b          	sext.w	a5,a0
    800004d8:	02b5553b          	divuw	a0,a0,a1
    800004dc:	0685                	addi	a3,a3,1
    800004de:	feb7f0e3          	bgeu	a5,a1,800004be <printint+0x26>

  if(sign)
    800004e2:	00088c63          	beqz	a7,800004fa <printint+0x62>
    buf[i++] = '-';
    800004e6:	fe070793          	addi	a5,a4,-32
    800004ea:	00878733          	add	a4,a5,s0
    800004ee:	02d00793          	li	a5,45
    800004f2:	fef70823          	sb	a5,-16(a4)
    800004f6:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
    800004fa:	02e05763          	blez	a4,80000528 <printint+0x90>
    800004fe:	fd040793          	addi	a5,s0,-48
    80000502:	00e784b3          	add	s1,a5,a4
    80000506:	fff78913          	addi	s2,a5,-1
    8000050a:	993a                	add	s2,s2,a4
    8000050c:	377d                	addiw	a4,a4,-1
    8000050e:	1702                	slli	a4,a4,0x20
    80000510:	9301                	srli	a4,a4,0x20
    80000512:	40e90933          	sub	s2,s2,a4
    consputc(buf[i]);
    80000516:	fff4c503          	lbu	a0,-1(s1)
    8000051a:	00000097          	auipc	ra,0x0
    8000051e:	d5e080e7          	jalr	-674(ra) # 80000278 <consputc>
  while(--i >= 0)
    80000522:	14fd                	addi	s1,s1,-1
    80000524:	ff2499e3          	bne	s1,s2,80000516 <printint+0x7e>
}
    80000528:	70a2                	ld	ra,40(sp)
    8000052a:	7402                	ld	s0,32(sp)
    8000052c:	64e2                	ld	s1,24(sp)
    8000052e:	6942                	ld	s2,16(sp)
    80000530:	6145                	addi	sp,sp,48
    80000532:	8082                	ret
    x = -xx;
    80000534:	40a0053b          	negw	a0,a0
  if(sign && (sign = xx < 0))
    80000538:	4885                	li	a7,1
    x = -xx;
    8000053a:	bf95                	j	800004ae <printint+0x16>

000000008000053c <panic>:
    release(&pr.lock);
}

void
panic(char *s)
{
    8000053c:	1101                	addi	sp,sp,-32
    8000053e:	ec06                	sd	ra,24(sp)
    80000540:	e822                	sd	s0,16(sp)
    80000542:	e426                	sd	s1,8(sp)
    80000544:	1000                	addi	s0,sp,32
    80000546:	84aa                	mv	s1,a0
  pr.locking = 0;
    80000548:	00010797          	auipc	a5,0x10
    8000054c:	7607a423          	sw	zero,1896(a5) # 80010cb0 <pr+0x18>
  printf("panic: ");
    80000550:	00008517          	auipc	a0,0x8
    80000554:	ac850513          	addi	a0,a0,-1336 # 80008018 <etext+0x18>
    80000558:	00000097          	auipc	ra,0x0
    8000055c:	02e080e7          	jalr	46(ra) # 80000586 <printf>
  printf(s);
    80000560:	8526                	mv	a0,s1
    80000562:	00000097          	auipc	ra,0x0
    80000566:	024080e7          	jalr	36(ra) # 80000586 <printf>
  printf("\n");
    8000056a:	00008517          	auipc	a0,0x8
    8000056e:	4ae50513          	addi	a0,a0,1198 # 80008a18 <syscalls+0x5a0>
    80000572:	00000097          	auipc	ra,0x0
    80000576:	014080e7          	jalr	20(ra) # 80000586 <printf>
  panicked = 1; // freeze uart output from other CPUs
    8000057a:	4785                	li	a5,1
    8000057c:	00008717          	auipc	a4,0x8
    80000580:	4ef72a23          	sw	a5,1268(a4) # 80008a70 <panicked>
  for(;;)
    80000584:	a001                	j	80000584 <panic+0x48>

0000000080000586 <printf>:
{
    80000586:	7131                	addi	sp,sp,-192
    80000588:	fc86                	sd	ra,120(sp)
    8000058a:	f8a2                	sd	s0,112(sp)
    8000058c:	f4a6                	sd	s1,104(sp)
    8000058e:	f0ca                	sd	s2,96(sp)
    80000590:	ecce                	sd	s3,88(sp)
    80000592:	e8d2                	sd	s4,80(sp)
    80000594:	e4d6                	sd	s5,72(sp)
    80000596:	e0da                	sd	s6,64(sp)
    80000598:	fc5e                	sd	s7,56(sp)
    8000059a:	f862                	sd	s8,48(sp)
    8000059c:	f466                	sd	s9,40(sp)
    8000059e:	f06a                	sd	s10,32(sp)
    800005a0:	ec6e                	sd	s11,24(sp)
    800005a2:	0100                	addi	s0,sp,128
    800005a4:	8a2a                	mv	s4,a0
    800005a6:	e40c                	sd	a1,8(s0)
    800005a8:	e810                	sd	a2,16(s0)
    800005aa:	ec14                	sd	a3,24(s0)
    800005ac:	f018                	sd	a4,32(s0)
    800005ae:	f41c                	sd	a5,40(s0)
    800005b0:	03043823          	sd	a6,48(s0)
    800005b4:	03143c23          	sd	a7,56(s0)
  locking = pr.locking;
    800005b8:	00010d97          	auipc	s11,0x10
    800005bc:	6f8dad83          	lw	s11,1784(s11) # 80010cb0 <pr+0x18>
  if(locking)
    800005c0:	020d9b63          	bnez	s11,800005f6 <printf+0x70>
  if (fmt == 0)
    800005c4:	040a0263          	beqz	s4,80000608 <printf+0x82>
  va_start(ap, fmt);
    800005c8:	00840793          	addi	a5,s0,8
    800005cc:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    800005d0:	000a4503          	lbu	a0,0(s4)
    800005d4:	14050f63          	beqz	a0,80000732 <printf+0x1ac>
    800005d8:	4981                	li	s3,0
    if(c != '%'){
    800005da:	02500a93          	li	s5,37
    switch(c){
    800005de:	07000b93          	li	s7,112
  consputc('x');
    800005e2:	4d41                	li	s10,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800005e4:	00008b17          	auipc	s6,0x8
    800005e8:	a5cb0b13          	addi	s6,s6,-1444 # 80008040 <digits>
    switch(c){
    800005ec:	07300c93          	li	s9,115
    800005f0:	06400c13          	li	s8,100
    800005f4:	a82d                	j	8000062e <printf+0xa8>
    acquire(&pr.lock);
    800005f6:	00010517          	auipc	a0,0x10
    800005fa:	6a250513          	addi	a0,a0,1698 # 80010c98 <pr>
    800005fe:	00000097          	auipc	ra,0x0
    80000602:	5d4080e7          	jalr	1492(ra) # 80000bd2 <acquire>
    80000606:	bf7d                	j	800005c4 <printf+0x3e>
    panic("null fmt");
    80000608:	00008517          	auipc	a0,0x8
    8000060c:	a2050513          	addi	a0,a0,-1504 # 80008028 <etext+0x28>
    80000610:	00000097          	auipc	ra,0x0
    80000614:	f2c080e7          	jalr	-212(ra) # 8000053c <panic>
      consputc(c);
    80000618:	00000097          	auipc	ra,0x0
    8000061c:	c60080e7          	jalr	-928(ra) # 80000278 <consputc>
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    80000620:	2985                	addiw	s3,s3,1
    80000622:	013a07b3          	add	a5,s4,s3
    80000626:	0007c503          	lbu	a0,0(a5)
    8000062a:	10050463          	beqz	a0,80000732 <printf+0x1ac>
    if(c != '%'){
    8000062e:	ff5515e3          	bne	a0,s5,80000618 <printf+0x92>
    c = fmt[++i] & 0xff;
    80000632:	2985                	addiw	s3,s3,1
    80000634:	013a07b3          	add	a5,s4,s3
    80000638:	0007c783          	lbu	a5,0(a5)
    8000063c:	0007849b          	sext.w	s1,a5
    if(c == 0)
    80000640:	cbed                	beqz	a5,80000732 <printf+0x1ac>
    switch(c){
    80000642:	05778a63          	beq	a5,s7,80000696 <printf+0x110>
    80000646:	02fbf663          	bgeu	s7,a5,80000672 <printf+0xec>
    8000064a:	09978863          	beq	a5,s9,800006da <printf+0x154>
    8000064e:	07800713          	li	a4,120
    80000652:	0ce79563          	bne	a5,a4,8000071c <printf+0x196>
      printint(va_arg(ap, int), 16, 1);
    80000656:	f8843783          	ld	a5,-120(s0)
    8000065a:	00878713          	addi	a4,a5,8
    8000065e:	f8e43423          	sd	a4,-120(s0)
    80000662:	4605                	li	a2,1
    80000664:	85ea                	mv	a1,s10
    80000666:	4388                	lw	a0,0(a5)
    80000668:	00000097          	auipc	ra,0x0
    8000066c:	e30080e7          	jalr	-464(ra) # 80000498 <printint>
      break;
    80000670:	bf45                	j	80000620 <printf+0x9a>
    switch(c){
    80000672:	09578f63          	beq	a5,s5,80000710 <printf+0x18a>
    80000676:	0b879363          	bne	a5,s8,8000071c <printf+0x196>
      printint(va_arg(ap, int), 10, 1);
    8000067a:	f8843783          	ld	a5,-120(s0)
    8000067e:	00878713          	addi	a4,a5,8
    80000682:	f8e43423          	sd	a4,-120(s0)
    80000686:	4605                	li	a2,1
    80000688:	45a9                	li	a1,10
    8000068a:	4388                	lw	a0,0(a5)
    8000068c:	00000097          	auipc	ra,0x0
    80000690:	e0c080e7          	jalr	-500(ra) # 80000498 <printint>
      break;
    80000694:	b771                	j	80000620 <printf+0x9a>
      printptr(va_arg(ap, uint64));
    80000696:	f8843783          	ld	a5,-120(s0)
    8000069a:	00878713          	addi	a4,a5,8
    8000069e:	f8e43423          	sd	a4,-120(s0)
    800006a2:	0007b903          	ld	s2,0(a5)
  consputc('0');
    800006a6:	03000513          	li	a0,48
    800006aa:	00000097          	auipc	ra,0x0
    800006ae:	bce080e7          	jalr	-1074(ra) # 80000278 <consputc>
  consputc('x');
    800006b2:	07800513          	li	a0,120
    800006b6:	00000097          	auipc	ra,0x0
    800006ba:	bc2080e7          	jalr	-1086(ra) # 80000278 <consputc>
    800006be:	84ea                	mv	s1,s10
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800006c0:	03c95793          	srli	a5,s2,0x3c
    800006c4:	97da                	add	a5,a5,s6
    800006c6:	0007c503          	lbu	a0,0(a5)
    800006ca:	00000097          	auipc	ra,0x0
    800006ce:	bae080e7          	jalr	-1106(ra) # 80000278 <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    800006d2:	0912                	slli	s2,s2,0x4
    800006d4:	34fd                	addiw	s1,s1,-1
    800006d6:	f4ed                	bnez	s1,800006c0 <printf+0x13a>
    800006d8:	b7a1                	j	80000620 <printf+0x9a>
      if((s = va_arg(ap, char*)) == 0)
    800006da:	f8843783          	ld	a5,-120(s0)
    800006de:	00878713          	addi	a4,a5,8
    800006e2:	f8e43423          	sd	a4,-120(s0)
    800006e6:	6384                	ld	s1,0(a5)
    800006e8:	cc89                	beqz	s1,80000702 <printf+0x17c>
      for(; *s; s++)
    800006ea:	0004c503          	lbu	a0,0(s1)
    800006ee:	d90d                	beqz	a0,80000620 <printf+0x9a>
        consputc(*s);
    800006f0:	00000097          	auipc	ra,0x0
    800006f4:	b88080e7          	jalr	-1144(ra) # 80000278 <consputc>
      for(; *s; s++)
    800006f8:	0485                	addi	s1,s1,1
    800006fa:	0004c503          	lbu	a0,0(s1)
    800006fe:	f96d                	bnez	a0,800006f0 <printf+0x16a>
    80000700:	b705                	j	80000620 <printf+0x9a>
        s = "(null)";
    80000702:	00008497          	auipc	s1,0x8
    80000706:	91e48493          	addi	s1,s1,-1762 # 80008020 <etext+0x20>
      for(; *s; s++)
    8000070a:	02800513          	li	a0,40
    8000070e:	b7cd                	j	800006f0 <printf+0x16a>
      consputc('%');
    80000710:	8556                	mv	a0,s5
    80000712:	00000097          	auipc	ra,0x0
    80000716:	b66080e7          	jalr	-1178(ra) # 80000278 <consputc>
      break;
    8000071a:	b719                	j	80000620 <printf+0x9a>
      consputc('%');
    8000071c:	8556                	mv	a0,s5
    8000071e:	00000097          	auipc	ra,0x0
    80000722:	b5a080e7          	jalr	-1190(ra) # 80000278 <consputc>
      consputc(c);
    80000726:	8526                	mv	a0,s1
    80000728:	00000097          	auipc	ra,0x0
    8000072c:	b50080e7          	jalr	-1200(ra) # 80000278 <consputc>
      break;
    80000730:	bdc5                	j	80000620 <printf+0x9a>
  if(locking)
    80000732:	020d9163          	bnez	s11,80000754 <printf+0x1ce>
}
    80000736:	70e6                	ld	ra,120(sp)
    80000738:	7446                	ld	s0,112(sp)
    8000073a:	74a6                	ld	s1,104(sp)
    8000073c:	7906                	ld	s2,96(sp)
    8000073e:	69e6                	ld	s3,88(sp)
    80000740:	6a46                	ld	s4,80(sp)
    80000742:	6aa6                	ld	s5,72(sp)
    80000744:	6b06                	ld	s6,64(sp)
    80000746:	7be2                	ld	s7,56(sp)
    80000748:	7c42                	ld	s8,48(sp)
    8000074a:	7ca2                	ld	s9,40(sp)
    8000074c:	7d02                	ld	s10,32(sp)
    8000074e:	6de2                	ld	s11,24(sp)
    80000750:	6129                	addi	sp,sp,192
    80000752:	8082                	ret
    release(&pr.lock);
    80000754:	00010517          	auipc	a0,0x10
    80000758:	54450513          	addi	a0,a0,1348 # 80010c98 <pr>
    8000075c:	00000097          	auipc	ra,0x0
    80000760:	52a080e7          	jalr	1322(ra) # 80000c86 <release>
}
    80000764:	bfc9                	j	80000736 <printf+0x1b0>

0000000080000766 <printfinit>:
    ;
}

void
printfinit(void)
{
    80000766:	1101                	addi	sp,sp,-32
    80000768:	ec06                	sd	ra,24(sp)
    8000076a:	e822                	sd	s0,16(sp)
    8000076c:	e426                	sd	s1,8(sp)
    8000076e:	1000                	addi	s0,sp,32
  initlock(&pr.lock, "pr");
    80000770:	00010497          	auipc	s1,0x10
    80000774:	52848493          	addi	s1,s1,1320 # 80010c98 <pr>
    80000778:	00008597          	auipc	a1,0x8
    8000077c:	8c058593          	addi	a1,a1,-1856 # 80008038 <etext+0x38>
    80000780:	8526                	mv	a0,s1
    80000782:	00000097          	auipc	ra,0x0
    80000786:	3c0080e7          	jalr	960(ra) # 80000b42 <initlock>
  pr.locking = 1;
    8000078a:	4785                	li	a5,1
    8000078c:	cc9c                	sw	a5,24(s1)
}
    8000078e:	60e2                	ld	ra,24(sp)
    80000790:	6442                	ld	s0,16(sp)
    80000792:	64a2                	ld	s1,8(sp)
    80000794:	6105                	addi	sp,sp,32
    80000796:	8082                	ret

0000000080000798 <uartinit>:

void uartstart();

void
uartinit(void)
{
    80000798:	1141                	addi	sp,sp,-16
    8000079a:	e406                	sd	ra,8(sp)
    8000079c:	e022                	sd	s0,0(sp)
    8000079e:	0800                	addi	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    800007a0:	100007b7          	lui	a5,0x10000
    800007a4:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, LCR_BAUD_LATCH);
    800007a8:	f8000713          	li	a4,-128
    800007ac:	00e781a3          	sb	a4,3(a5)

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    800007b0:	470d                	li	a4,3
    800007b2:	00e78023          	sb	a4,0(a5)

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    800007b6:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    800007ba:	00e781a3          	sb	a4,3(a5)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    800007be:	469d                	li	a3,7
    800007c0:	00d78123          	sb	a3,2(a5)

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    800007c4:	00e780a3          	sb	a4,1(a5)

  initlock(&uart_tx_lock, "uart");
    800007c8:	00008597          	auipc	a1,0x8
    800007cc:	89058593          	addi	a1,a1,-1904 # 80008058 <digits+0x18>
    800007d0:	00010517          	auipc	a0,0x10
    800007d4:	4e850513          	addi	a0,a0,1256 # 80010cb8 <uart_tx_lock>
    800007d8:	00000097          	auipc	ra,0x0
    800007dc:	36a080e7          	jalr	874(ra) # 80000b42 <initlock>
}
    800007e0:	60a2                	ld	ra,8(sp)
    800007e2:	6402                	ld	s0,0(sp)
    800007e4:	0141                	addi	sp,sp,16
    800007e6:	8082                	ret

00000000800007e8 <uartputc_sync>:
// use interrupts, for use by kernel printf() and
// to echo characters. it spins waiting for the uart's
// output register to be empty.
void
uartputc_sync(int c)
{
    800007e8:	1101                	addi	sp,sp,-32
    800007ea:	ec06                	sd	ra,24(sp)
    800007ec:	e822                	sd	s0,16(sp)
    800007ee:	e426                	sd	s1,8(sp)
    800007f0:	1000                	addi	s0,sp,32
    800007f2:	84aa                	mv	s1,a0
  push_off();
    800007f4:	00000097          	auipc	ra,0x0
    800007f8:	392080e7          	jalr	914(ra) # 80000b86 <push_off>

  if(panicked){
    800007fc:	00008797          	auipc	a5,0x8
    80000800:	2747a783          	lw	a5,628(a5) # 80008a70 <panicked>
    for(;;)
      ;
  }

  // wait for Transmit Holding Empty to be set in LSR.
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    80000804:	10000737          	lui	a4,0x10000
  if(panicked){
    80000808:	c391                	beqz	a5,8000080c <uartputc_sync+0x24>
    for(;;)
    8000080a:	a001                	j	8000080a <uartputc_sync+0x22>
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    8000080c:	00574783          	lbu	a5,5(a4) # 10000005 <_entry-0x6ffffffb>
    80000810:	0207f793          	andi	a5,a5,32
    80000814:	dfe5                	beqz	a5,8000080c <uartputc_sync+0x24>
    ;
  WriteReg(THR, c);
    80000816:	0ff4f513          	zext.b	a0,s1
    8000081a:	100007b7          	lui	a5,0x10000
    8000081e:	00a78023          	sb	a0,0(a5) # 10000000 <_entry-0x70000000>

  pop_off();
    80000822:	00000097          	auipc	ra,0x0
    80000826:	404080e7          	jalr	1028(ra) # 80000c26 <pop_off>
}
    8000082a:	60e2                	ld	ra,24(sp)
    8000082c:	6442                	ld	s0,16(sp)
    8000082e:	64a2                	ld	s1,8(sp)
    80000830:	6105                	addi	sp,sp,32
    80000832:	8082                	ret

0000000080000834 <uartstart>:
// called from both the top- and bottom-half.
void
uartstart()
{
  while(1){
    if(uart_tx_w == uart_tx_r){
    80000834:	00008797          	auipc	a5,0x8
    80000838:	2447b783          	ld	a5,580(a5) # 80008a78 <uart_tx_r>
    8000083c:	00008717          	auipc	a4,0x8
    80000840:	24473703          	ld	a4,580(a4) # 80008a80 <uart_tx_w>
    80000844:	06f70a63          	beq	a4,a5,800008b8 <uartstart+0x84>
{
    80000848:	7139                	addi	sp,sp,-64
    8000084a:	fc06                	sd	ra,56(sp)
    8000084c:	f822                	sd	s0,48(sp)
    8000084e:	f426                	sd	s1,40(sp)
    80000850:	f04a                	sd	s2,32(sp)
    80000852:	ec4e                	sd	s3,24(sp)
    80000854:	e852                	sd	s4,16(sp)
    80000856:	e456                	sd	s5,8(sp)
    80000858:	0080                	addi	s0,sp,64
      // transmit buffer is empty.
      return;
    }
    
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    8000085a:	10000937          	lui	s2,0x10000
      // so we cannot give it another byte.
      // it will interrupt when it's ready for a new byte.
      return;
    }
    
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    8000085e:	00010a17          	auipc	s4,0x10
    80000862:	45aa0a13          	addi	s4,s4,1114 # 80010cb8 <uart_tx_lock>
    uart_tx_r += 1;
    80000866:	00008497          	auipc	s1,0x8
    8000086a:	21248493          	addi	s1,s1,530 # 80008a78 <uart_tx_r>
    if(uart_tx_w == uart_tx_r){
    8000086e:	00008997          	auipc	s3,0x8
    80000872:	21298993          	addi	s3,s3,530 # 80008a80 <uart_tx_w>
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    80000876:	00594703          	lbu	a4,5(s2) # 10000005 <_entry-0x6ffffffb>
    8000087a:	02077713          	andi	a4,a4,32
    8000087e:	c705                	beqz	a4,800008a6 <uartstart+0x72>
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    80000880:	01f7f713          	andi	a4,a5,31
    80000884:	9752                	add	a4,a4,s4
    80000886:	01874a83          	lbu	s5,24(a4)
    uart_tx_r += 1;
    8000088a:	0785                	addi	a5,a5,1
    8000088c:	e09c                	sd	a5,0(s1)
    
    // maybe uartputc() is waiting for space in the buffer.
    wakeup(&uart_tx_r);
    8000088e:	8526                	mv	a0,s1
    80000890:	00002097          	auipc	ra,0x2
    80000894:	904080e7          	jalr	-1788(ra) # 80002194 <wakeup>
    
    WriteReg(THR, c);
    80000898:	01590023          	sb	s5,0(s2)
    if(uart_tx_w == uart_tx_r){
    8000089c:	609c                	ld	a5,0(s1)
    8000089e:	0009b703          	ld	a4,0(s3)
    800008a2:	fcf71ae3          	bne	a4,a5,80000876 <uartstart+0x42>
  }
}
    800008a6:	70e2                	ld	ra,56(sp)
    800008a8:	7442                	ld	s0,48(sp)
    800008aa:	74a2                	ld	s1,40(sp)
    800008ac:	7902                	ld	s2,32(sp)
    800008ae:	69e2                	ld	s3,24(sp)
    800008b0:	6a42                	ld	s4,16(sp)
    800008b2:	6aa2                	ld	s5,8(sp)
    800008b4:	6121                	addi	sp,sp,64
    800008b6:	8082                	ret
    800008b8:	8082                	ret

00000000800008ba <uartputc>:
{
    800008ba:	7179                	addi	sp,sp,-48
    800008bc:	f406                	sd	ra,40(sp)
    800008be:	f022                	sd	s0,32(sp)
    800008c0:	ec26                	sd	s1,24(sp)
    800008c2:	e84a                	sd	s2,16(sp)
    800008c4:	e44e                	sd	s3,8(sp)
    800008c6:	e052                	sd	s4,0(sp)
    800008c8:	1800                	addi	s0,sp,48
    800008ca:	8a2a                	mv	s4,a0
  acquire(&uart_tx_lock);
    800008cc:	00010517          	auipc	a0,0x10
    800008d0:	3ec50513          	addi	a0,a0,1004 # 80010cb8 <uart_tx_lock>
    800008d4:	00000097          	auipc	ra,0x0
    800008d8:	2fe080e7          	jalr	766(ra) # 80000bd2 <acquire>
  if(panicked){
    800008dc:	00008797          	auipc	a5,0x8
    800008e0:	1947a783          	lw	a5,404(a5) # 80008a70 <panicked>
    800008e4:	e7c9                	bnez	a5,8000096e <uartputc+0xb4>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    800008e6:	00008717          	auipc	a4,0x8
    800008ea:	19a73703          	ld	a4,410(a4) # 80008a80 <uart_tx_w>
    800008ee:	00008797          	auipc	a5,0x8
    800008f2:	18a7b783          	ld	a5,394(a5) # 80008a78 <uart_tx_r>
    800008f6:	02078793          	addi	a5,a5,32
    sleep(&uart_tx_r, &uart_tx_lock);
    800008fa:	00010997          	auipc	s3,0x10
    800008fe:	3be98993          	addi	s3,s3,958 # 80010cb8 <uart_tx_lock>
    80000902:	00008497          	auipc	s1,0x8
    80000906:	17648493          	addi	s1,s1,374 # 80008a78 <uart_tx_r>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    8000090a:	00008917          	auipc	s2,0x8
    8000090e:	17690913          	addi	s2,s2,374 # 80008a80 <uart_tx_w>
    80000912:	00e79f63          	bne	a5,a4,80000930 <uartputc+0x76>
    sleep(&uart_tx_r, &uart_tx_lock);
    80000916:	85ce                	mv	a1,s3
    80000918:	8526                	mv	a0,s1
    8000091a:	00002097          	auipc	ra,0x2
    8000091e:	816080e7          	jalr	-2026(ra) # 80002130 <sleep>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000922:	00093703          	ld	a4,0(s2)
    80000926:	609c                	ld	a5,0(s1)
    80000928:	02078793          	addi	a5,a5,32
    8000092c:	fee785e3          	beq	a5,a4,80000916 <uartputc+0x5c>
  uart_tx_buf[uart_tx_w % UART_TX_BUF_SIZE] = c;
    80000930:	00010497          	auipc	s1,0x10
    80000934:	38848493          	addi	s1,s1,904 # 80010cb8 <uart_tx_lock>
    80000938:	01f77793          	andi	a5,a4,31
    8000093c:	97a6                	add	a5,a5,s1
    8000093e:	01478c23          	sb	s4,24(a5)
  uart_tx_w += 1;
    80000942:	0705                	addi	a4,a4,1
    80000944:	00008797          	auipc	a5,0x8
    80000948:	12e7be23          	sd	a4,316(a5) # 80008a80 <uart_tx_w>
  uartstart();
    8000094c:	00000097          	auipc	ra,0x0
    80000950:	ee8080e7          	jalr	-280(ra) # 80000834 <uartstart>
  release(&uart_tx_lock);
    80000954:	8526                	mv	a0,s1
    80000956:	00000097          	auipc	ra,0x0
    8000095a:	330080e7          	jalr	816(ra) # 80000c86 <release>
}
    8000095e:	70a2                	ld	ra,40(sp)
    80000960:	7402                	ld	s0,32(sp)
    80000962:	64e2                	ld	s1,24(sp)
    80000964:	6942                	ld	s2,16(sp)
    80000966:	69a2                	ld	s3,8(sp)
    80000968:	6a02                	ld	s4,0(sp)
    8000096a:	6145                	addi	sp,sp,48
    8000096c:	8082                	ret
    for(;;)
    8000096e:	a001                	j	8000096e <uartputc+0xb4>

0000000080000970 <uartgetc>:

// read one input character from the UART.
// return -1 if none is waiting.
int
uartgetc(void)
{
    80000970:	1141                	addi	sp,sp,-16
    80000972:	e422                	sd	s0,8(sp)
    80000974:	0800                	addi	s0,sp,16
  if(ReadReg(LSR) & 0x01){
    80000976:	100007b7          	lui	a5,0x10000
    8000097a:	0057c783          	lbu	a5,5(a5) # 10000005 <_entry-0x6ffffffb>
    8000097e:	8b85                	andi	a5,a5,1
    80000980:	cb81                	beqz	a5,80000990 <uartgetc+0x20>
    // input data is ready.
    return ReadReg(RHR);
    80000982:	100007b7          	lui	a5,0x10000
    80000986:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
  } else {
    return -1;
  }
}
    8000098a:	6422                	ld	s0,8(sp)
    8000098c:	0141                	addi	sp,sp,16
    8000098e:	8082                	ret
    return -1;
    80000990:	557d                	li	a0,-1
    80000992:	bfe5                	j	8000098a <uartgetc+0x1a>

0000000080000994 <uartintr>:
// handle a uart interrupt, raised because input has
// arrived, or the uart is ready for more output, or
// both. called from devintr().
void
uartintr(void)
{
    80000994:	1101                	addi	sp,sp,-32
    80000996:	ec06                	sd	ra,24(sp)
    80000998:	e822                	sd	s0,16(sp)
    8000099a:	e426                	sd	s1,8(sp)
    8000099c:	1000                	addi	s0,sp,32
  // read and process incoming characters.
  while(1){
    int c = uartgetc();
    if(c == -1)
    8000099e:	54fd                	li	s1,-1
    800009a0:	a029                	j	800009aa <uartintr+0x16>
      break;
    consoleintr(c);
    800009a2:	00000097          	auipc	ra,0x0
    800009a6:	918080e7          	jalr	-1768(ra) # 800002ba <consoleintr>
    int c = uartgetc();
    800009aa:	00000097          	auipc	ra,0x0
    800009ae:	fc6080e7          	jalr	-58(ra) # 80000970 <uartgetc>
    if(c == -1)
    800009b2:	fe9518e3          	bne	a0,s1,800009a2 <uartintr+0xe>
  }

  // send buffered characters.
  acquire(&uart_tx_lock);
    800009b6:	00010497          	auipc	s1,0x10
    800009ba:	30248493          	addi	s1,s1,770 # 80010cb8 <uart_tx_lock>
    800009be:	8526                	mv	a0,s1
    800009c0:	00000097          	auipc	ra,0x0
    800009c4:	212080e7          	jalr	530(ra) # 80000bd2 <acquire>
  uartstart();
    800009c8:	00000097          	auipc	ra,0x0
    800009cc:	e6c080e7          	jalr	-404(ra) # 80000834 <uartstart>
  release(&uart_tx_lock);
    800009d0:	8526                	mv	a0,s1
    800009d2:	00000097          	auipc	ra,0x0
    800009d6:	2b4080e7          	jalr	692(ra) # 80000c86 <release>
}
    800009da:	60e2                	ld	ra,24(sp)
    800009dc:	6442                	ld	s0,16(sp)
    800009de:	64a2                	ld	s1,8(sp)
    800009e0:	6105                	addi	sp,sp,32
    800009e2:	8082                	ret

00000000800009e4 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
    800009e4:	1101                	addi	sp,sp,-32
    800009e6:	ec06                	sd	ra,24(sp)
    800009e8:	e822                	sd	s0,16(sp)
    800009ea:	e426                	sd	s1,8(sp)
    800009ec:	e04a                	sd	s2,0(sp)
    800009ee:	1000                	addi	s0,sp,32
  struct run *r;

  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    800009f0:	03451793          	slli	a5,a0,0x34
    800009f4:	ebb9                	bnez	a5,80000a4a <kfree+0x66>
    800009f6:	84aa                	mv	s1,a0
    800009f8:	00199797          	auipc	a5,0x199
    800009fc:	d1878793          	addi	a5,a5,-744 # 80199710 <end>
    80000a00:	04f56563          	bltu	a0,a5,80000a4a <kfree+0x66>
    80000a04:	47c5                	li	a5,17
    80000a06:	07ee                	slli	a5,a5,0x1b
    80000a08:	04f57163          	bgeu	a0,a5,80000a4a <kfree+0x66>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);
    80000a0c:	6605                	lui	a2,0x1
    80000a0e:	4585                	li	a1,1
    80000a10:	00000097          	auipc	ra,0x0
    80000a14:	2be080e7          	jalr	702(ra) # 80000cce <memset>

  r = (struct run*)pa;

  acquire(&kmem.lock);
    80000a18:	00010917          	auipc	s2,0x10
    80000a1c:	2d890913          	addi	s2,s2,728 # 80010cf0 <kmem>
    80000a20:	854a                	mv	a0,s2
    80000a22:	00000097          	auipc	ra,0x0
    80000a26:	1b0080e7          	jalr	432(ra) # 80000bd2 <acquire>
  r->next = kmem.freelist;
    80000a2a:	01893783          	ld	a5,24(s2)
    80000a2e:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    80000a30:	00993c23          	sd	s1,24(s2)
  release(&kmem.lock);
    80000a34:	854a                	mv	a0,s2
    80000a36:	00000097          	auipc	ra,0x0
    80000a3a:	250080e7          	jalr	592(ra) # 80000c86 <release>
}
    80000a3e:	60e2                	ld	ra,24(sp)
    80000a40:	6442                	ld	s0,16(sp)
    80000a42:	64a2                	ld	s1,8(sp)
    80000a44:	6902                	ld	s2,0(sp)
    80000a46:	6105                	addi	sp,sp,32
    80000a48:	8082                	ret
    panic("kfree");
    80000a4a:	00007517          	auipc	a0,0x7
    80000a4e:	61650513          	addi	a0,a0,1558 # 80008060 <digits+0x20>
    80000a52:	00000097          	auipc	ra,0x0
    80000a56:	aea080e7          	jalr	-1302(ra) # 8000053c <panic>

0000000080000a5a <freerange>:
{
    80000a5a:	7179                	addi	sp,sp,-48
    80000a5c:	f406                	sd	ra,40(sp)
    80000a5e:	f022                	sd	s0,32(sp)
    80000a60:	ec26                	sd	s1,24(sp)
    80000a62:	e84a                	sd	s2,16(sp)
    80000a64:	e44e                	sd	s3,8(sp)
    80000a66:	e052                	sd	s4,0(sp)
    80000a68:	1800                	addi	s0,sp,48
  p = (char*)PGROUNDUP((uint64)pa_start);
    80000a6a:	6785                	lui	a5,0x1
    80000a6c:	fff78713          	addi	a4,a5,-1 # fff <_entry-0x7ffff001>
    80000a70:	00e504b3          	add	s1,a0,a4
    80000a74:	777d                	lui	a4,0xfffff
    80000a76:	8cf9                	and	s1,s1,a4
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a78:	94be                	add	s1,s1,a5
    80000a7a:	0095ee63          	bltu	a1,s1,80000a96 <freerange+0x3c>
    80000a7e:	892e                	mv	s2,a1
    kfree(p);
    80000a80:	7a7d                	lui	s4,0xfffff
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a82:	6985                	lui	s3,0x1
    kfree(p);
    80000a84:	01448533          	add	a0,s1,s4
    80000a88:	00000097          	auipc	ra,0x0
    80000a8c:	f5c080e7          	jalr	-164(ra) # 800009e4 <kfree>
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a90:	94ce                	add	s1,s1,s3
    80000a92:	fe9979e3          	bgeu	s2,s1,80000a84 <freerange+0x2a>
}
    80000a96:	70a2                	ld	ra,40(sp)
    80000a98:	7402                	ld	s0,32(sp)
    80000a9a:	64e2                	ld	s1,24(sp)
    80000a9c:	6942                	ld	s2,16(sp)
    80000a9e:	69a2                	ld	s3,8(sp)
    80000aa0:	6a02                	ld	s4,0(sp)
    80000aa2:	6145                	addi	sp,sp,48
    80000aa4:	8082                	ret

0000000080000aa6 <kinit>:
{
    80000aa6:	1141                	addi	sp,sp,-16
    80000aa8:	e406                	sd	ra,8(sp)
    80000aaa:	e022                	sd	s0,0(sp)
    80000aac:	0800                	addi	s0,sp,16
  initlock(&kmem.lock, "kmem");
    80000aae:	00007597          	auipc	a1,0x7
    80000ab2:	5ba58593          	addi	a1,a1,1466 # 80008068 <digits+0x28>
    80000ab6:	00010517          	auipc	a0,0x10
    80000aba:	23a50513          	addi	a0,a0,570 # 80010cf0 <kmem>
    80000abe:	00000097          	auipc	ra,0x0
    80000ac2:	084080e7          	jalr	132(ra) # 80000b42 <initlock>
  freerange(end, (void*)PHYSTOP);
    80000ac6:	45c5                	li	a1,17
    80000ac8:	05ee                	slli	a1,a1,0x1b
    80000aca:	00199517          	auipc	a0,0x199
    80000ace:	c4650513          	addi	a0,a0,-954 # 80199710 <end>
    80000ad2:	00000097          	auipc	ra,0x0
    80000ad6:	f88080e7          	jalr	-120(ra) # 80000a5a <freerange>
}
    80000ada:	60a2                	ld	ra,8(sp)
    80000adc:	6402                	ld	s0,0(sp)
    80000ade:	0141                	addi	sp,sp,16
    80000ae0:	8082                	ret

0000000080000ae2 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    80000ae2:	1101                	addi	sp,sp,-32
    80000ae4:	ec06                	sd	ra,24(sp)
    80000ae6:	e822                	sd	s0,16(sp)
    80000ae8:	e426                	sd	s1,8(sp)
    80000aea:	1000                	addi	s0,sp,32
  struct run *r;

  acquire(&kmem.lock);
    80000aec:	00010497          	auipc	s1,0x10
    80000af0:	20448493          	addi	s1,s1,516 # 80010cf0 <kmem>
    80000af4:	8526                	mv	a0,s1
    80000af6:	00000097          	auipc	ra,0x0
    80000afa:	0dc080e7          	jalr	220(ra) # 80000bd2 <acquire>
  r = kmem.freelist;
    80000afe:	6c84                	ld	s1,24(s1)
  if(r)
    80000b00:	c885                	beqz	s1,80000b30 <kalloc+0x4e>
    kmem.freelist = r->next;
    80000b02:	609c                	ld	a5,0(s1)
    80000b04:	00010517          	auipc	a0,0x10
    80000b08:	1ec50513          	addi	a0,a0,492 # 80010cf0 <kmem>
    80000b0c:	ed1c                	sd	a5,24(a0)
  release(&kmem.lock);
    80000b0e:	00000097          	auipc	ra,0x0
    80000b12:	178080e7          	jalr	376(ra) # 80000c86 <release>

  if(r)
    memset((char*)r, 5, PGSIZE); // fill with junk
    80000b16:	6605                	lui	a2,0x1
    80000b18:	4595                	li	a1,5
    80000b1a:	8526                	mv	a0,s1
    80000b1c:	00000097          	auipc	ra,0x0
    80000b20:	1b2080e7          	jalr	434(ra) # 80000cce <memset>
  return (void*)r;
}
    80000b24:	8526                	mv	a0,s1
    80000b26:	60e2                	ld	ra,24(sp)
    80000b28:	6442                	ld	s0,16(sp)
    80000b2a:	64a2                	ld	s1,8(sp)
    80000b2c:	6105                	addi	sp,sp,32
    80000b2e:	8082                	ret
  release(&kmem.lock);
    80000b30:	00010517          	auipc	a0,0x10
    80000b34:	1c050513          	addi	a0,a0,448 # 80010cf0 <kmem>
    80000b38:	00000097          	auipc	ra,0x0
    80000b3c:	14e080e7          	jalr	334(ra) # 80000c86 <release>
  if(r)
    80000b40:	b7d5                	j	80000b24 <kalloc+0x42>

0000000080000b42 <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    80000b42:	1141                	addi	sp,sp,-16
    80000b44:	e422                	sd	s0,8(sp)
    80000b46:	0800                	addi	s0,sp,16
  lk->name = name;
    80000b48:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80000b4a:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80000b4e:	00053823          	sd	zero,16(a0)
}
    80000b52:	6422                	ld	s0,8(sp)
    80000b54:	0141                	addi	sp,sp,16
    80000b56:	8082                	ret

0000000080000b58 <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80000b58:	411c                	lw	a5,0(a0)
    80000b5a:	e399                	bnez	a5,80000b60 <holding+0x8>
    80000b5c:	4501                	li	a0,0
  return r;
}
    80000b5e:	8082                	ret
{
    80000b60:	1101                	addi	sp,sp,-32
    80000b62:	ec06                	sd	ra,24(sp)
    80000b64:	e822                	sd	s0,16(sp)
    80000b66:	e426                	sd	s1,8(sp)
    80000b68:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80000b6a:	6904                	ld	s1,16(a0)
    80000b6c:	00001097          	auipc	ra,0x1
    80000b70:	e5a080e7          	jalr	-422(ra) # 800019c6 <mycpu>
    80000b74:	40a48533          	sub	a0,s1,a0
    80000b78:	00153513          	seqz	a0,a0
}
    80000b7c:	60e2                	ld	ra,24(sp)
    80000b7e:	6442                	ld	s0,16(sp)
    80000b80:	64a2                	ld	s1,8(sp)
    80000b82:	6105                	addi	sp,sp,32
    80000b84:	8082                	ret

0000000080000b86 <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80000b86:	1101                	addi	sp,sp,-32
    80000b88:	ec06                	sd	ra,24(sp)
    80000b8a:	e822                	sd	s0,16(sp)
    80000b8c:	e426                	sd	s1,8(sp)
    80000b8e:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000b90:	100024f3          	csrr	s1,sstatus
    80000b94:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80000b98:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000b9a:	10079073          	csrw	sstatus,a5
  int old = intr_get();

  intr_off();
  if(mycpu()->noff == 0)
    80000b9e:	00001097          	auipc	ra,0x1
    80000ba2:	e28080e7          	jalr	-472(ra) # 800019c6 <mycpu>
    80000ba6:	5d3c                	lw	a5,120(a0)
    80000ba8:	cf89                	beqz	a5,80000bc2 <push_off+0x3c>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000baa:	00001097          	auipc	ra,0x1
    80000bae:	e1c080e7          	jalr	-484(ra) # 800019c6 <mycpu>
    80000bb2:	5d3c                	lw	a5,120(a0)
    80000bb4:	2785                	addiw	a5,a5,1
    80000bb6:	dd3c                	sw	a5,120(a0)
}
    80000bb8:	60e2                	ld	ra,24(sp)
    80000bba:	6442                	ld	s0,16(sp)
    80000bbc:	64a2                	ld	s1,8(sp)
    80000bbe:	6105                	addi	sp,sp,32
    80000bc0:	8082                	ret
    mycpu()->intena = old;
    80000bc2:	00001097          	auipc	ra,0x1
    80000bc6:	e04080e7          	jalr	-508(ra) # 800019c6 <mycpu>
  return (x & SSTATUS_SIE) != 0;
    80000bca:	8085                	srli	s1,s1,0x1
    80000bcc:	8885                	andi	s1,s1,1
    80000bce:	dd64                	sw	s1,124(a0)
    80000bd0:	bfe9                	j	80000baa <push_off+0x24>

0000000080000bd2 <acquire>:
{
    80000bd2:	1101                	addi	sp,sp,-32
    80000bd4:	ec06                	sd	ra,24(sp)
    80000bd6:	e822                	sd	s0,16(sp)
    80000bd8:	e426                	sd	s1,8(sp)
    80000bda:	1000                	addi	s0,sp,32
    80000bdc:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000bde:	00000097          	auipc	ra,0x0
    80000be2:	fa8080e7          	jalr	-88(ra) # 80000b86 <push_off>
  if(holding(lk))
    80000be6:	8526                	mv	a0,s1
    80000be8:	00000097          	auipc	ra,0x0
    80000bec:	f70080e7          	jalr	-144(ra) # 80000b58 <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000bf0:	4705                	li	a4,1
  if(holding(lk))
    80000bf2:	e115                	bnez	a0,80000c16 <acquire+0x44>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000bf4:	87ba                	mv	a5,a4
    80000bf6:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000bfa:	2781                	sext.w	a5,a5
    80000bfc:	ffe5                	bnez	a5,80000bf4 <acquire+0x22>
  __sync_synchronize();
    80000bfe:	0ff0000f          	fence
  lk->cpu = mycpu();
    80000c02:	00001097          	auipc	ra,0x1
    80000c06:	dc4080e7          	jalr	-572(ra) # 800019c6 <mycpu>
    80000c0a:	e888                	sd	a0,16(s1)
}
    80000c0c:	60e2                	ld	ra,24(sp)
    80000c0e:	6442                	ld	s0,16(sp)
    80000c10:	64a2                	ld	s1,8(sp)
    80000c12:	6105                	addi	sp,sp,32
    80000c14:	8082                	ret
    panic("acquire");
    80000c16:	00007517          	auipc	a0,0x7
    80000c1a:	45a50513          	addi	a0,a0,1114 # 80008070 <digits+0x30>
    80000c1e:	00000097          	auipc	ra,0x0
    80000c22:	91e080e7          	jalr	-1762(ra) # 8000053c <panic>

0000000080000c26 <pop_off>:

void
pop_off(void)
{
    80000c26:	1141                	addi	sp,sp,-16
    80000c28:	e406                	sd	ra,8(sp)
    80000c2a:	e022                	sd	s0,0(sp)
    80000c2c:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80000c2e:	00001097          	auipc	ra,0x1
    80000c32:	d98080e7          	jalr	-616(ra) # 800019c6 <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c36:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000c3a:	8b89                	andi	a5,a5,2
  if(intr_get())
    80000c3c:	e78d                	bnez	a5,80000c66 <pop_off+0x40>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    80000c3e:	5d3c                	lw	a5,120(a0)
    80000c40:	02f05b63          	blez	a5,80000c76 <pop_off+0x50>
    panic("pop_off");
  c->noff -= 1;
    80000c44:	37fd                	addiw	a5,a5,-1
    80000c46:	0007871b          	sext.w	a4,a5
    80000c4a:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80000c4c:	eb09                	bnez	a4,80000c5e <pop_off+0x38>
    80000c4e:	5d7c                	lw	a5,124(a0)
    80000c50:	c799                	beqz	a5,80000c5e <pop_off+0x38>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c52:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000c56:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000c5a:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80000c5e:	60a2                	ld	ra,8(sp)
    80000c60:	6402                	ld	s0,0(sp)
    80000c62:	0141                	addi	sp,sp,16
    80000c64:	8082                	ret
    panic("pop_off - interruptible");
    80000c66:	00007517          	auipc	a0,0x7
    80000c6a:	41250513          	addi	a0,a0,1042 # 80008078 <digits+0x38>
    80000c6e:	00000097          	auipc	ra,0x0
    80000c72:	8ce080e7          	jalr	-1842(ra) # 8000053c <panic>
    panic("pop_off");
    80000c76:	00007517          	auipc	a0,0x7
    80000c7a:	41a50513          	addi	a0,a0,1050 # 80008090 <digits+0x50>
    80000c7e:	00000097          	auipc	ra,0x0
    80000c82:	8be080e7          	jalr	-1858(ra) # 8000053c <panic>

0000000080000c86 <release>:
{
    80000c86:	1101                	addi	sp,sp,-32
    80000c88:	ec06                	sd	ra,24(sp)
    80000c8a:	e822                	sd	s0,16(sp)
    80000c8c:	e426                	sd	s1,8(sp)
    80000c8e:	1000                	addi	s0,sp,32
    80000c90:	84aa                	mv	s1,a0
  if(!holding(lk))
    80000c92:	00000097          	auipc	ra,0x0
    80000c96:	ec6080e7          	jalr	-314(ra) # 80000b58 <holding>
    80000c9a:	c115                	beqz	a0,80000cbe <release+0x38>
  lk->cpu = 0;
    80000c9c:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80000ca0:	0ff0000f          	fence
  __sync_lock_release(&lk->locked);
    80000ca4:	0f50000f          	fence	iorw,ow
    80000ca8:	0804a02f          	amoswap.w	zero,zero,(s1)
  pop_off();
    80000cac:	00000097          	auipc	ra,0x0
    80000cb0:	f7a080e7          	jalr	-134(ra) # 80000c26 <pop_off>
}
    80000cb4:	60e2                	ld	ra,24(sp)
    80000cb6:	6442                	ld	s0,16(sp)
    80000cb8:	64a2                	ld	s1,8(sp)
    80000cba:	6105                	addi	sp,sp,32
    80000cbc:	8082                	ret
    panic("release");
    80000cbe:	00007517          	auipc	a0,0x7
    80000cc2:	3da50513          	addi	a0,a0,986 # 80008098 <digits+0x58>
    80000cc6:	00000097          	auipc	ra,0x0
    80000cca:	876080e7          	jalr	-1930(ra) # 8000053c <panic>

0000000080000cce <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    80000cce:	1141                	addi	sp,sp,-16
    80000cd0:	e422                	sd	s0,8(sp)
    80000cd2:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80000cd4:	ca19                	beqz	a2,80000cea <memset+0x1c>
    80000cd6:	87aa                	mv	a5,a0
    80000cd8:	1602                	slli	a2,a2,0x20
    80000cda:	9201                	srli	a2,a2,0x20
    80000cdc:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    80000ce0:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    80000ce4:	0785                	addi	a5,a5,1
    80000ce6:	fee79de3          	bne	a5,a4,80000ce0 <memset+0x12>
  }
  return dst;
}
    80000cea:	6422                	ld	s0,8(sp)
    80000cec:	0141                	addi	sp,sp,16
    80000cee:	8082                	ret

0000000080000cf0 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000cf0:	1141                	addi	sp,sp,-16
    80000cf2:	e422                	sd	s0,8(sp)
    80000cf4:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    80000cf6:	ca05                	beqz	a2,80000d26 <memcmp+0x36>
    80000cf8:	fff6069b          	addiw	a3,a2,-1 # fff <_entry-0x7ffff001>
    80000cfc:	1682                	slli	a3,a3,0x20
    80000cfe:	9281                	srli	a3,a3,0x20
    80000d00:	0685                	addi	a3,a3,1
    80000d02:	96aa                	add	a3,a3,a0
    if(*s1 != *s2)
    80000d04:	00054783          	lbu	a5,0(a0)
    80000d08:	0005c703          	lbu	a4,0(a1)
    80000d0c:	00e79863          	bne	a5,a4,80000d1c <memcmp+0x2c>
      return *s1 - *s2;
    s1++, s2++;
    80000d10:	0505                	addi	a0,a0,1
    80000d12:	0585                	addi	a1,a1,1
  while(n-- > 0){
    80000d14:	fed518e3          	bne	a0,a3,80000d04 <memcmp+0x14>
  }

  return 0;
    80000d18:	4501                	li	a0,0
    80000d1a:	a019                	j	80000d20 <memcmp+0x30>
      return *s1 - *s2;
    80000d1c:	40e7853b          	subw	a0,a5,a4
}
    80000d20:	6422                	ld	s0,8(sp)
    80000d22:	0141                	addi	sp,sp,16
    80000d24:	8082                	ret
  return 0;
    80000d26:	4501                	li	a0,0
    80000d28:	bfe5                	j	80000d20 <memcmp+0x30>

0000000080000d2a <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    80000d2a:	1141                	addi	sp,sp,-16
    80000d2c:	e422                	sd	s0,8(sp)
    80000d2e:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  if(n == 0)
    80000d30:	c205                	beqz	a2,80000d50 <memmove+0x26>
    return dst;
  
  s = src;
  d = dst;
  if(s < d && s + n > d){
    80000d32:	02a5e263          	bltu	a1,a0,80000d56 <memmove+0x2c>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    80000d36:	1602                	slli	a2,a2,0x20
    80000d38:	9201                	srli	a2,a2,0x20
    80000d3a:	00c587b3          	add	a5,a1,a2
{
    80000d3e:	872a                	mv	a4,a0
      *d++ = *s++;
    80000d40:	0585                	addi	a1,a1,1
    80000d42:	0705                	addi	a4,a4,1 # fffffffffffff001 <end+0xffffffff7fe658f1>
    80000d44:	fff5c683          	lbu	a3,-1(a1)
    80000d48:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
    80000d4c:	fef59ae3          	bne	a1,a5,80000d40 <memmove+0x16>

  return dst;
}
    80000d50:	6422                	ld	s0,8(sp)
    80000d52:	0141                	addi	sp,sp,16
    80000d54:	8082                	ret
  if(s < d && s + n > d){
    80000d56:	02061693          	slli	a3,a2,0x20
    80000d5a:	9281                	srli	a3,a3,0x20
    80000d5c:	00d58733          	add	a4,a1,a3
    80000d60:	fce57be3          	bgeu	a0,a4,80000d36 <memmove+0xc>
    d += n;
    80000d64:	96aa                	add	a3,a3,a0
    while(n-- > 0)
    80000d66:	fff6079b          	addiw	a5,a2,-1
    80000d6a:	1782                	slli	a5,a5,0x20
    80000d6c:	9381                	srli	a5,a5,0x20
    80000d6e:	fff7c793          	not	a5,a5
    80000d72:	97ba                	add	a5,a5,a4
      *--d = *--s;
    80000d74:	177d                	addi	a4,a4,-1
    80000d76:	16fd                	addi	a3,a3,-1
    80000d78:	00074603          	lbu	a2,0(a4)
    80000d7c:	00c68023          	sb	a2,0(a3)
    while(n-- > 0)
    80000d80:	fee79ae3          	bne	a5,a4,80000d74 <memmove+0x4a>
    80000d84:	b7f1                	j	80000d50 <memmove+0x26>

0000000080000d86 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80000d86:	1141                	addi	sp,sp,-16
    80000d88:	e406                	sd	ra,8(sp)
    80000d8a:	e022                	sd	s0,0(sp)
    80000d8c:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80000d8e:	00000097          	auipc	ra,0x0
    80000d92:	f9c080e7          	jalr	-100(ra) # 80000d2a <memmove>
}
    80000d96:	60a2                	ld	ra,8(sp)
    80000d98:	6402                	ld	s0,0(sp)
    80000d9a:	0141                	addi	sp,sp,16
    80000d9c:	8082                	ret

0000000080000d9e <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000d9e:	1141                	addi	sp,sp,-16
    80000da0:	e422                	sd	s0,8(sp)
    80000da2:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80000da4:	ce11                	beqz	a2,80000dc0 <strncmp+0x22>
    80000da6:	00054783          	lbu	a5,0(a0)
    80000daa:	cf89                	beqz	a5,80000dc4 <strncmp+0x26>
    80000dac:	0005c703          	lbu	a4,0(a1)
    80000db0:	00f71a63          	bne	a4,a5,80000dc4 <strncmp+0x26>
    n--, p++, q++;
    80000db4:	367d                	addiw	a2,a2,-1
    80000db6:	0505                	addi	a0,a0,1
    80000db8:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    80000dba:	f675                	bnez	a2,80000da6 <strncmp+0x8>
  if(n == 0)
    return 0;
    80000dbc:	4501                	li	a0,0
    80000dbe:	a809                	j	80000dd0 <strncmp+0x32>
    80000dc0:	4501                	li	a0,0
    80000dc2:	a039                	j	80000dd0 <strncmp+0x32>
  if(n == 0)
    80000dc4:	ca09                	beqz	a2,80000dd6 <strncmp+0x38>
  return (uchar)*p - (uchar)*q;
    80000dc6:	00054503          	lbu	a0,0(a0)
    80000dca:	0005c783          	lbu	a5,0(a1)
    80000dce:	9d1d                	subw	a0,a0,a5
}
    80000dd0:	6422                	ld	s0,8(sp)
    80000dd2:	0141                	addi	sp,sp,16
    80000dd4:	8082                	ret
    return 0;
    80000dd6:	4501                	li	a0,0
    80000dd8:	bfe5                	j	80000dd0 <strncmp+0x32>

0000000080000dda <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    80000dda:	1141                	addi	sp,sp,-16
    80000ddc:	e422                	sd	s0,8(sp)
    80000dde:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    80000de0:	87aa                	mv	a5,a0
    80000de2:	86b2                	mv	a3,a2
    80000de4:	367d                	addiw	a2,a2,-1
    80000de6:	00d05963          	blez	a3,80000df8 <strncpy+0x1e>
    80000dea:	0785                	addi	a5,a5,1
    80000dec:	0005c703          	lbu	a4,0(a1)
    80000df0:	fee78fa3          	sb	a4,-1(a5)
    80000df4:	0585                	addi	a1,a1,1
    80000df6:	f775                	bnez	a4,80000de2 <strncpy+0x8>
    ;
  while(n-- > 0)
    80000df8:	873e                	mv	a4,a5
    80000dfa:	9fb5                	addw	a5,a5,a3
    80000dfc:	37fd                	addiw	a5,a5,-1
    80000dfe:	00c05963          	blez	a2,80000e10 <strncpy+0x36>
    *s++ = 0;
    80000e02:	0705                	addi	a4,a4,1
    80000e04:	fe070fa3          	sb	zero,-1(a4)
  while(n-- > 0)
    80000e08:	40e786bb          	subw	a3,a5,a4
    80000e0c:	fed04be3          	bgtz	a3,80000e02 <strncpy+0x28>
  return os;
}
    80000e10:	6422                	ld	s0,8(sp)
    80000e12:	0141                	addi	sp,sp,16
    80000e14:	8082                	ret

0000000080000e16 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    80000e16:	1141                	addi	sp,sp,-16
    80000e18:	e422                	sd	s0,8(sp)
    80000e1a:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    80000e1c:	02c05363          	blez	a2,80000e42 <safestrcpy+0x2c>
    80000e20:	fff6069b          	addiw	a3,a2,-1
    80000e24:	1682                	slli	a3,a3,0x20
    80000e26:	9281                	srli	a3,a3,0x20
    80000e28:	96ae                	add	a3,a3,a1
    80000e2a:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    80000e2c:	00d58963          	beq	a1,a3,80000e3e <safestrcpy+0x28>
    80000e30:	0585                	addi	a1,a1,1
    80000e32:	0785                	addi	a5,a5,1
    80000e34:	fff5c703          	lbu	a4,-1(a1)
    80000e38:	fee78fa3          	sb	a4,-1(a5)
    80000e3c:	fb65                	bnez	a4,80000e2c <safestrcpy+0x16>
    ;
  *s = 0;
    80000e3e:	00078023          	sb	zero,0(a5)
  return os;
}
    80000e42:	6422                	ld	s0,8(sp)
    80000e44:	0141                	addi	sp,sp,16
    80000e46:	8082                	ret

0000000080000e48 <strlen>:

int
strlen(const char *s)
{
    80000e48:	1141                	addi	sp,sp,-16
    80000e4a:	e422                	sd	s0,8(sp)
    80000e4c:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    80000e4e:	00054783          	lbu	a5,0(a0)
    80000e52:	cf91                	beqz	a5,80000e6e <strlen+0x26>
    80000e54:	0505                	addi	a0,a0,1
    80000e56:	87aa                	mv	a5,a0
    80000e58:	86be                	mv	a3,a5
    80000e5a:	0785                	addi	a5,a5,1
    80000e5c:	fff7c703          	lbu	a4,-1(a5)
    80000e60:	ff65                	bnez	a4,80000e58 <strlen+0x10>
    80000e62:	40a6853b          	subw	a0,a3,a0
    80000e66:	2505                	addiw	a0,a0,1
    ;
  return n;
}
    80000e68:	6422                	ld	s0,8(sp)
    80000e6a:	0141                	addi	sp,sp,16
    80000e6c:	8082                	ret
  for(n = 0; s[n]; n++)
    80000e6e:	4501                	li	a0,0
    80000e70:	bfe5                	j	80000e68 <strlen+0x20>

0000000080000e72 <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80000e72:	1141                	addi	sp,sp,-16
    80000e74:	e406                	sd	ra,8(sp)
    80000e76:	e022                	sd	s0,0(sp)
    80000e78:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    80000e7a:	00001097          	auipc	ra,0x1
    80000e7e:	b3c080e7          	jalr	-1220(ra) # 800019b6 <cpuid>

    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000e82:	00008717          	auipc	a4,0x8
    80000e86:	c0670713          	addi	a4,a4,-1018 # 80008a88 <started>
  if(cpuid() == 0){
    80000e8a:	c139                	beqz	a0,80000ed0 <main+0x5e>
    while(started == 0)
    80000e8c:	431c                	lw	a5,0(a4)
    80000e8e:	2781                	sext.w	a5,a5
    80000e90:	dff5                	beqz	a5,80000e8c <main+0x1a>
      ;
    __sync_synchronize();
    80000e92:	0ff0000f          	fence
    printf("hart %d starting\n", cpuid());
    80000e96:	00001097          	auipc	ra,0x1
    80000e9a:	b20080e7          	jalr	-1248(ra) # 800019b6 <cpuid>
    80000e9e:	85aa                	mv	a1,a0
    80000ea0:	00007517          	auipc	a0,0x7
    80000ea4:	21850513          	addi	a0,a0,536 # 800080b8 <digits+0x78>
    80000ea8:	fffff097          	auipc	ra,0xfffff
    80000eac:	6de080e7          	jalr	1758(ra) # 80000586 <printf>
    kvminithart();    // turn on paging
    80000eb0:	00000097          	auipc	ra,0x0
    80000eb4:	0e0080e7          	jalr	224(ra) # 80000f90 <kvminithart>
    trapinithart();   // install kernel trap vector
    80000eb8:	00002097          	auipc	ra,0x2
    80000ebc:	88a080e7          	jalr	-1910(ra) # 80002742 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000ec0:	00005097          	auipc	ra,0x5
    80000ec4:	e50080e7          	jalr	-432(ra) # 80005d10 <plicinithart>
  }

  scheduler();        
    80000ec8:	00001097          	auipc	ra,0x1
    80000ecc:	0b0080e7          	jalr	176(ra) # 80001f78 <scheduler>
    consoleinit();
    80000ed0:	fffff097          	auipc	ra,0xfffff
    80000ed4:	57c080e7          	jalr	1404(ra) # 8000044c <consoleinit>
    printfinit();
    80000ed8:	00000097          	auipc	ra,0x0
    80000edc:	88e080e7          	jalr	-1906(ra) # 80000766 <printfinit>
    printf("\n");
    80000ee0:	00008517          	auipc	a0,0x8
    80000ee4:	b3850513          	addi	a0,a0,-1224 # 80008a18 <syscalls+0x5a0>
    80000ee8:	fffff097          	auipc	ra,0xfffff
    80000eec:	69e080e7          	jalr	1694(ra) # 80000586 <printf>
    printf("xv6 kernel is booting\n");
    80000ef0:	00007517          	auipc	a0,0x7
    80000ef4:	1b050513          	addi	a0,a0,432 # 800080a0 <digits+0x60>
    80000ef8:	fffff097          	auipc	ra,0xfffff
    80000efc:	68e080e7          	jalr	1678(ra) # 80000586 <printf>
    printf("\n");
    80000f00:	00008517          	auipc	a0,0x8
    80000f04:	b1850513          	addi	a0,a0,-1256 # 80008a18 <syscalls+0x5a0>
    80000f08:	fffff097          	auipc	ra,0xfffff
    80000f0c:	67e080e7          	jalr	1662(ra) # 80000586 <printf>
    kinit();         // physical page allocator
    80000f10:	00000097          	auipc	ra,0x0
    80000f14:	b96080e7          	jalr	-1130(ra) # 80000aa6 <kinit>
    kvminit();       // create kernel page table
    80000f18:	00000097          	auipc	ra,0x0
    80000f1c:	32e080e7          	jalr	814(ra) # 80001246 <kvminit>
    kvminithart();   // turn on paging
    80000f20:	00000097          	auipc	ra,0x0
    80000f24:	070080e7          	jalr	112(ra) # 80000f90 <kvminithart>
    procinit();      // process table
    80000f28:	00001097          	auipc	ra,0x1
    80000f2c:	9d2080e7          	jalr	-1582(ra) # 800018fa <procinit>
    trapinit();      // trap vectors
    80000f30:	00001097          	auipc	ra,0x1
    80000f34:	7ea080e7          	jalr	2026(ra) # 8000271a <trapinit>
    trapinithart();  // install kernel trap vector
    80000f38:	00002097          	auipc	ra,0x2
    80000f3c:	80a080e7          	jalr	-2038(ra) # 80002742 <trapinithart>
    plicinit();      // set up interrupt controller
    80000f40:	00005097          	auipc	ra,0x5
    80000f44:	dba080e7          	jalr	-582(ra) # 80005cfa <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000f48:	00005097          	auipc	ra,0x5
    80000f4c:	dc8080e7          	jalr	-568(ra) # 80005d10 <plicinithart>
    binit();         // buffer cache
    80000f50:	00002097          	auipc	ra,0x2
    80000f54:	f5a080e7          	jalr	-166(ra) # 80002eaa <binit>
    iinit();         // inode table
    80000f58:	00002097          	auipc	ra,0x2
    80000f5c:	5f8080e7          	jalr	1528(ra) # 80003550 <iinit>
    fileinit();      // file table
    80000f60:	00003097          	auipc	ra,0x3
    80000f64:	56e080e7          	jalr	1390(ra) # 800044ce <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000f68:	00005097          	auipc	ra,0x5
    80000f6c:	eb0080e7          	jalr	-336(ra) # 80005e18 <virtio_disk_init>
    init_psa_regions();
    80000f70:	00005097          	auipc	ra,0x5
    80000f74:	3c0080e7          	jalr	960(ra) # 80006330 <init_psa_regions>
    userinit();      // first user process
    80000f78:	00001097          	auipc	ra,0x1
    80000f7c:	d4a080e7          	jalr	-694(ra) # 80001cc2 <userinit>
    __sync_synchronize();
    80000f80:	0ff0000f          	fence
    started = 1;
    80000f84:	4785                	li	a5,1
    80000f86:	00008717          	auipc	a4,0x8
    80000f8a:	b0f72123          	sw	a5,-1278(a4) # 80008a88 <started>
    80000f8e:	bf2d                	j	80000ec8 <main+0x56>

0000000080000f90 <kvminithart>:

// Switch h/w page table register to the kernel's page table,
// and enable paging.
void
kvminithart()
{
    80000f90:	1141                	addi	sp,sp,-16
    80000f92:	e422                	sd	s0,8(sp)
    80000f94:	0800                	addi	s0,sp,16
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    80000f96:	12000073          	sfence.vma
  // wait for any previous writes to the page table memory to finish.
  sfence_vma();

  w_satp(MAKE_SATP(kernel_pagetable));
    80000f9a:	00008797          	auipc	a5,0x8
    80000f9e:	af67b783          	ld	a5,-1290(a5) # 80008a90 <kernel_pagetable>
    80000fa2:	83b1                	srli	a5,a5,0xc
    80000fa4:	577d                	li	a4,-1
    80000fa6:	177e                	slli	a4,a4,0x3f
    80000fa8:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    80000faa:	18079073          	csrw	satp,a5
  asm volatile("sfence.vma zero, zero");
    80000fae:	12000073          	sfence.vma

  // flush stale entries from the TLB.
  sfence_vma();
}
    80000fb2:	6422                	ld	s0,8(sp)
    80000fb4:	0141                	addi	sp,sp,16
    80000fb6:	8082                	ret

0000000080000fb8 <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    80000fb8:	7139                	addi	sp,sp,-64
    80000fba:	fc06                	sd	ra,56(sp)
    80000fbc:	f822                	sd	s0,48(sp)
    80000fbe:	f426                	sd	s1,40(sp)
    80000fc0:	f04a                	sd	s2,32(sp)
    80000fc2:	ec4e                	sd	s3,24(sp)
    80000fc4:	e852                	sd	s4,16(sp)
    80000fc6:	e456                	sd	s5,8(sp)
    80000fc8:	e05a                	sd	s6,0(sp)
    80000fca:	0080                	addi	s0,sp,64
    80000fcc:	84aa                	mv	s1,a0
    80000fce:	89ae                	mv	s3,a1
    80000fd0:	8ab2                	mv	s5,a2
  if(va >= MAXVA)
    80000fd2:	57fd                	li	a5,-1
    80000fd4:	83e9                	srli	a5,a5,0x1a
    80000fd6:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    80000fd8:	4b31                	li	s6,12
  if(va >= MAXVA)
    80000fda:	04b7f263          	bgeu	a5,a1,8000101e <walk+0x66>
    panic("walk");
    80000fde:	00007517          	auipc	a0,0x7
    80000fe2:	0f250513          	addi	a0,a0,242 # 800080d0 <digits+0x90>
    80000fe6:	fffff097          	auipc	ra,0xfffff
    80000fea:	556080e7          	jalr	1366(ra) # 8000053c <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    80000fee:	060a8663          	beqz	s5,8000105a <walk+0xa2>
    80000ff2:	00000097          	auipc	ra,0x0
    80000ff6:	af0080e7          	jalr	-1296(ra) # 80000ae2 <kalloc>
    80000ffa:	84aa                	mv	s1,a0
    80000ffc:	c529                	beqz	a0,80001046 <walk+0x8e>
        return 0;
      memset(pagetable, 0, PGSIZE);
    80000ffe:	6605                	lui	a2,0x1
    80001000:	4581                	li	a1,0
    80001002:	00000097          	auipc	ra,0x0
    80001006:	ccc080e7          	jalr	-820(ra) # 80000cce <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    8000100a:	00c4d793          	srli	a5,s1,0xc
    8000100e:	07aa                	slli	a5,a5,0xa
    80001010:	0017e793          	ori	a5,a5,1
    80001014:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    80001018:	3a5d                	addiw	s4,s4,-9 # ffffffffffffeff7 <end+0xffffffff7fe658e7>
    8000101a:	036a0063          	beq	s4,s6,8000103a <walk+0x82>
    pte_t *pte = &pagetable[PX(level, va)];
    8000101e:	0149d933          	srl	s2,s3,s4
    80001022:	1ff97913          	andi	s2,s2,511
    80001026:	090e                	slli	s2,s2,0x3
    80001028:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    8000102a:	00093483          	ld	s1,0(s2)
    8000102e:	0014f793          	andi	a5,s1,1
    80001032:	dfd5                	beqz	a5,80000fee <walk+0x36>
      pagetable = (pagetable_t)PTE2PA(*pte);
    80001034:	80a9                	srli	s1,s1,0xa
    80001036:	04b2                	slli	s1,s1,0xc
    80001038:	b7c5                	j	80001018 <walk+0x60>
    }
  }
  return &pagetable[PX(0, va)];
    8000103a:	00c9d513          	srli	a0,s3,0xc
    8000103e:	1ff57513          	andi	a0,a0,511
    80001042:	050e                	slli	a0,a0,0x3
    80001044:	9526                	add	a0,a0,s1
}
    80001046:	70e2                	ld	ra,56(sp)
    80001048:	7442                	ld	s0,48(sp)
    8000104a:	74a2                	ld	s1,40(sp)
    8000104c:	7902                	ld	s2,32(sp)
    8000104e:	69e2                	ld	s3,24(sp)
    80001050:	6a42                	ld	s4,16(sp)
    80001052:	6aa2                	ld	s5,8(sp)
    80001054:	6b02                	ld	s6,0(sp)
    80001056:	6121                	addi	sp,sp,64
    80001058:	8082                	ret
        return 0;
    8000105a:	4501                	li	a0,0
    8000105c:	b7ed                	j	80001046 <walk+0x8e>

000000008000105e <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    8000105e:	57fd                	li	a5,-1
    80001060:	83e9                	srli	a5,a5,0x1a
    80001062:	00b7f463          	bgeu	a5,a1,8000106a <walkaddr+0xc>
    return 0;
    80001066:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    80001068:	8082                	ret
{
    8000106a:	1141                	addi	sp,sp,-16
    8000106c:	e406                	sd	ra,8(sp)
    8000106e:	e022                	sd	s0,0(sp)
    80001070:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    80001072:	4601                	li	a2,0
    80001074:	00000097          	auipc	ra,0x0
    80001078:	f44080e7          	jalr	-188(ra) # 80000fb8 <walk>
  if(pte == 0)
    8000107c:	c105                	beqz	a0,8000109c <walkaddr+0x3e>
  if((*pte & PTE_V) == 0)
    8000107e:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    80001080:	0117f693          	andi	a3,a5,17
    80001084:	4745                	li	a4,17
    return 0;
    80001086:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    80001088:	00e68663          	beq	a3,a4,80001094 <walkaddr+0x36>
}
    8000108c:	60a2                	ld	ra,8(sp)
    8000108e:	6402                	ld	s0,0(sp)
    80001090:	0141                	addi	sp,sp,16
    80001092:	8082                	ret
  pa = PTE2PA(*pte);
    80001094:	83a9                	srli	a5,a5,0xa
    80001096:	00c79513          	slli	a0,a5,0xc
  return pa;
    8000109a:	bfcd                	j	8000108c <walkaddr+0x2e>
    return 0;
    8000109c:	4501                	li	a0,0
    8000109e:	b7fd                	j	8000108c <walkaddr+0x2e>

00000000800010a0 <mappages>:
// physical addresses starting at pa. va and size might not
// be page-aligned. Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    800010a0:	715d                	addi	sp,sp,-80
    800010a2:	e486                	sd	ra,72(sp)
    800010a4:	e0a2                	sd	s0,64(sp)
    800010a6:	fc26                	sd	s1,56(sp)
    800010a8:	f84a                	sd	s2,48(sp)
    800010aa:	f44e                	sd	s3,40(sp)
    800010ac:	f052                	sd	s4,32(sp)
    800010ae:	ec56                	sd	s5,24(sp)
    800010b0:	e85a                	sd	s6,16(sp)
    800010b2:	e45e                	sd	s7,8(sp)
    800010b4:	0880                	addi	s0,sp,80
  uint64 a, last;
  pte_t *pte;

  if(size == 0)
    800010b6:	c639                	beqz	a2,80001104 <mappages+0x64>
    800010b8:	8aaa                	mv	s5,a0
    800010ba:	8b3a                	mv	s6,a4
    panic("mappages: size");
  
  a = PGROUNDDOWN(va);
    800010bc:	777d                	lui	a4,0xfffff
    800010be:	00e5f7b3          	and	a5,a1,a4
  last = PGROUNDDOWN(va + size - 1);
    800010c2:	fff58993          	addi	s3,a1,-1
    800010c6:	99b2                	add	s3,s3,a2
    800010c8:	00e9f9b3          	and	s3,s3,a4
  a = PGROUNDDOWN(va);
    800010cc:	893e                	mv	s2,a5
    800010ce:	40f68a33          	sub	s4,a3,a5
    if(*pte & PTE_V)
      panic("mappages: remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    800010d2:	6b85                	lui	s7,0x1
    800010d4:	012a04b3          	add	s1,s4,s2
    if((pte = walk(pagetable, a, 1)) == 0)
    800010d8:	4605                	li	a2,1
    800010da:	85ca                	mv	a1,s2
    800010dc:	8556                	mv	a0,s5
    800010de:	00000097          	auipc	ra,0x0
    800010e2:	eda080e7          	jalr	-294(ra) # 80000fb8 <walk>
    800010e6:	cd1d                	beqz	a0,80001124 <mappages+0x84>
    if(*pte & PTE_V)
    800010e8:	611c                	ld	a5,0(a0)
    800010ea:	8b85                	andi	a5,a5,1
    800010ec:	e785                	bnez	a5,80001114 <mappages+0x74>
    *pte = PA2PTE(pa) | perm | PTE_V;
    800010ee:	80b1                	srli	s1,s1,0xc
    800010f0:	04aa                	slli	s1,s1,0xa
    800010f2:	0164e4b3          	or	s1,s1,s6
    800010f6:	0014e493          	ori	s1,s1,1
    800010fa:	e104                	sd	s1,0(a0)
    if(a == last)
    800010fc:	05390063          	beq	s2,s3,8000113c <mappages+0x9c>
    a += PGSIZE;
    80001100:	995e                	add	s2,s2,s7
    if((pte = walk(pagetable, a, 1)) == 0)
    80001102:	bfc9                	j	800010d4 <mappages+0x34>
    panic("mappages: size");
    80001104:	00007517          	auipc	a0,0x7
    80001108:	fd450513          	addi	a0,a0,-44 # 800080d8 <digits+0x98>
    8000110c:	fffff097          	auipc	ra,0xfffff
    80001110:	430080e7          	jalr	1072(ra) # 8000053c <panic>
      panic("mappages: remap");
    80001114:	00007517          	auipc	a0,0x7
    80001118:	fd450513          	addi	a0,a0,-44 # 800080e8 <digits+0xa8>
    8000111c:	fffff097          	auipc	ra,0xfffff
    80001120:	420080e7          	jalr	1056(ra) # 8000053c <panic>
      return -1;
    80001124:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    80001126:	60a6                	ld	ra,72(sp)
    80001128:	6406                	ld	s0,64(sp)
    8000112a:	74e2                	ld	s1,56(sp)
    8000112c:	7942                	ld	s2,48(sp)
    8000112e:	79a2                	ld	s3,40(sp)
    80001130:	7a02                	ld	s4,32(sp)
    80001132:	6ae2                	ld	s5,24(sp)
    80001134:	6b42                	ld	s6,16(sp)
    80001136:	6ba2                	ld	s7,8(sp)
    80001138:	6161                	addi	sp,sp,80
    8000113a:	8082                	ret
  return 0;
    8000113c:	4501                	li	a0,0
    8000113e:	b7e5                	j	80001126 <mappages+0x86>

0000000080001140 <kvmmap>:
{
    80001140:	1141                	addi	sp,sp,-16
    80001142:	e406                	sd	ra,8(sp)
    80001144:	e022                	sd	s0,0(sp)
    80001146:	0800                	addi	s0,sp,16
    80001148:	87b6                	mv	a5,a3
  if(mappages(kpgtbl, va, sz, pa, perm) != 0)
    8000114a:	86b2                	mv	a3,a2
    8000114c:	863e                	mv	a2,a5
    8000114e:	00000097          	auipc	ra,0x0
    80001152:	f52080e7          	jalr	-174(ra) # 800010a0 <mappages>
    80001156:	e509                	bnez	a0,80001160 <kvmmap+0x20>
}
    80001158:	60a2                	ld	ra,8(sp)
    8000115a:	6402                	ld	s0,0(sp)
    8000115c:	0141                	addi	sp,sp,16
    8000115e:	8082                	ret
    panic("kvmmap");
    80001160:	00007517          	auipc	a0,0x7
    80001164:	f9850513          	addi	a0,a0,-104 # 800080f8 <digits+0xb8>
    80001168:	fffff097          	auipc	ra,0xfffff
    8000116c:	3d4080e7          	jalr	980(ra) # 8000053c <panic>

0000000080001170 <kvmmake>:
{
    80001170:	1101                	addi	sp,sp,-32
    80001172:	ec06                	sd	ra,24(sp)
    80001174:	e822                	sd	s0,16(sp)
    80001176:	e426                	sd	s1,8(sp)
    80001178:	e04a                	sd	s2,0(sp)
    8000117a:	1000                	addi	s0,sp,32
  kpgtbl = (pagetable_t) kalloc();
    8000117c:	00000097          	auipc	ra,0x0
    80001180:	966080e7          	jalr	-1690(ra) # 80000ae2 <kalloc>
    80001184:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    80001186:	6605                	lui	a2,0x1
    80001188:	4581                	li	a1,0
    8000118a:	00000097          	auipc	ra,0x0
    8000118e:	b44080e7          	jalr	-1212(ra) # 80000cce <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    80001192:	4719                	li	a4,6
    80001194:	6685                	lui	a3,0x1
    80001196:	10000637          	lui	a2,0x10000
    8000119a:	100005b7          	lui	a1,0x10000
    8000119e:	8526                	mv	a0,s1
    800011a0:	00000097          	auipc	ra,0x0
    800011a4:	fa0080e7          	jalr	-96(ra) # 80001140 <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    800011a8:	4719                	li	a4,6
    800011aa:	6685                	lui	a3,0x1
    800011ac:	10001637          	lui	a2,0x10001
    800011b0:	100015b7          	lui	a1,0x10001
    800011b4:	8526                	mv	a0,s1
    800011b6:	00000097          	auipc	ra,0x0
    800011ba:	f8a080e7          	jalr	-118(ra) # 80001140 <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x400000, PTE_R | PTE_W);
    800011be:	4719                	li	a4,6
    800011c0:	004006b7          	lui	a3,0x400
    800011c4:	0c000637          	lui	a2,0xc000
    800011c8:	0c0005b7          	lui	a1,0xc000
    800011cc:	8526                	mv	a0,s1
    800011ce:	00000097          	auipc	ra,0x0
    800011d2:	f72080e7          	jalr	-142(ra) # 80001140 <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    800011d6:	00007917          	auipc	s2,0x7
    800011da:	e2a90913          	addi	s2,s2,-470 # 80008000 <etext>
    800011de:	4729                	li	a4,10
    800011e0:	80007697          	auipc	a3,0x80007
    800011e4:	e2068693          	addi	a3,a3,-480 # 8000 <_entry-0x7fff8000>
    800011e8:	4605                	li	a2,1
    800011ea:	067e                	slli	a2,a2,0x1f
    800011ec:	85b2                	mv	a1,a2
    800011ee:	8526                	mv	a0,s1
    800011f0:	00000097          	auipc	ra,0x0
    800011f4:	f50080e7          	jalr	-176(ra) # 80001140 <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    800011f8:	4719                	li	a4,6
    800011fa:	46c5                	li	a3,17
    800011fc:	06ee                	slli	a3,a3,0x1b
    800011fe:	412686b3          	sub	a3,a3,s2
    80001202:	864a                	mv	a2,s2
    80001204:	85ca                	mv	a1,s2
    80001206:	8526                	mv	a0,s1
    80001208:	00000097          	auipc	ra,0x0
    8000120c:	f38080e7          	jalr	-200(ra) # 80001140 <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    80001210:	4729                	li	a4,10
    80001212:	6685                	lui	a3,0x1
    80001214:	00006617          	auipc	a2,0x6
    80001218:	dec60613          	addi	a2,a2,-532 # 80007000 <_trampoline>
    8000121c:	040005b7          	lui	a1,0x4000
    80001220:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001222:	05b2                	slli	a1,a1,0xc
    80001224:	8526                	mv	a0,s1
    80001226:	00000097          	auipc	ra,0x0
    8000122a:	f1a080e7          	jalr	-230(ra) # 80001140 <kvmmap>
  proc_mapstacks(kpgtbl);
    8000122e:	8526                	mv	a0,s1
    80001230:	00000097          	auipc	ra,0x0
    80001234:	62c080e7          	jalr	1580(ra) # 8000185c <proc_mapstacks>
}
    80001238:	8526                	mv	a0,s1
    8000123a:	60e2                	ld	ra,24(sp)
    8000123c:	6442                	ld	s0,16(sp)
    8000123e:	64a2                	ld	s1,8(sp)
    80001240:	6902                	ld	s2,0(sp)
    80001242:	6105                	addi	sp,sp,32
    80001244:	8082                	ret

0000000080001246 <kvminit>:
{
    80001246:	1141                	addi	sp,sp,-16
    80001248:	e406                	sd	ra,8(sp)
    8000124a:	e022                	sd	s0,0(sp)
    8000124c:	0800                	addi	s0,sp,16
  kernel_pagetable = kvmmake();
    8000124e:	00000097          	auipc	ra,0x0
    80001252:	f22080e7          	jalr	-222(ra) # 80001170 <kvmmake>
    80001256:	00008797          	auipc	a5,0x8
    8000125a:	82a7bd23          	sd	a0,-1990(a5) # 80008a90 <kernel_pagetable>
}
    8000125e:	60a2                	ld	ra,8(sp)
    80001260:	6402                	ld	s0,0(sp)
    80001262:	0141                	addi	sp,sp,16
    80001264:	8082                	ret

0000000080001266 <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. The mappings must exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    80001266:	715d                	addi	sp,sp,-80
    80001268:	e486                	sd	ra,72(sp)
    8000126a:	e0a2                	sd	s0,64(sp)
    8000126c:	fc26                	sd	s1,56(sp)
    8000126e:	f84a                	sd	s2,48(sp)
    80001270:	f44e                	sd	s3,40(sp)
    80001272:	f052                	sd	s4,32(sp)
    80001274:	ec56                	sd	s5,24(sp)
    80001276:	e85a                	sd	s6,16(sp)
    80001278:	e45e                	sd	s7,8(sp)
    8000127a:	0880                	addi	s0,sp,80
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    8000127c:	03459793          	slli	a5,a1,0x34
    80001280:	e795                	bnez	a5,800012ac <uvmunmap+0x46>
    80001282:	8a2a                	mv	s4,a0
    80001284:	892e                	mv	s2,a1
    80001286:	8b36                	mv	s6,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001288:	0632                	slli	a2,a2,0xc
    8000128a:	00b609b3          	add	s3,a2,a1
      panic("uvmunmap: walk");
    if((*pte & PTE_V) == 0)
      continue;
      /* CSE 536: removed for on-demand allocation. */
      // panic("uvmunmap: not mapped");
    if(PTE_FLAGS(*pte) == PTE_V)
    8000128e:	4b85                	li	s7,1
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001290:	6a85                	lui	s5,0x1
    80001292:	0535ea63          	bltu	a1,s3,800012e6 <uvmunmap+0x80>
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
  }
}
    80001296:	60a6                	ld	ra,72(sp)
    80001298:	6406                	ld	s0,64(sp)
    8000129a:	74e2                	ld	s1,56(sp)
    8000129c:	7942                	ld	s2,48(sp)
    8000129e:	79a2                	ld	s3,40(sp)
    800012a0:	7a02                	ld	s4,32(sp)
    800012a2:	6ae2                	ld	s5,24(sp)
    800012a4:	6b42                	ld	s6,16(sp)
    800012a6:	6ba2                	ld	s7,8(sp)
    800012a8:	6161                	addi	sp,sp,80
    800012aa:	8082                	ret
    panic("uvmunmap: not aligned");
    800012ac:	00007517          	auipc	a0,0x7
    800012b0:	e5450513          	addi	a0,a0,-428 # 80008100 <digits+0xc0>
    800012b4:	fffff097          	auipc	ra,0xfffff
    800012b8:	288080e7          	jalr	648(ra) # 8000053c <panic>
      panic("uvmunmap: walk");
    800012bc:	00007517          	auipc	a0,0x7
    800012c0:	e5c50513          	addi	a0,a0,-420 # 80008118 <digits+0xd8>
    800012c4:	fffff097          	auipc	ra,0xfffff
    800012c8:	278080e7          	jalr	632(ra) # 8000053c <panic>
      panic("uvmunmap: not a leaf");
    800012cc:	00007517          	auipc	a0,0x7
    800012d0:	e5c50513          	addi	a0,a0,-420 # 80008128 <digits+0xe8>
    800012d4:	fffff097          	auipc	ra,0xfffff
    800012d8:	268080e7          	jalr	616(ra) # 8000053c <panic>
    *pte = 0;
    800012dc:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800012e0:	9956                	add	s2,s2,s5
    800012e2:	fb397ae3          	bgeu	s2,s3,80001296 <uvmunmap+0x30>
    if((pte = walk(pagetable, a, 0)) == 0)
    800012e6:	4601                	li	a2,0
    800012e8:	85ca                	mv	a1,s2
    800012ea:	8552                	mv	a0,s4
    800012ec:	00000097          	auipc	ra,0x0
    800012f0:	ccc080e7          	jalr	-820(ra) # 80000fb8 <walk>
    800012f4:	84aa                	mv	s1,a0
    800012f6:	d179                	beqz	a0,800012bc <uvmunmap+0x56>
    if((*pte & PTE_V) == 0)
    800012f8:	611c                	ld	a5,0(a0)
    800012fa:	0017f713          	andi	a4,a5,1
    800012fe:	d36d                	beqz	a4,800012e0 <uvmunmap+0x7a>
    if(PTE_FLAGS(*pte) == PTE_V)
    80001300:	3ff7f713          	andi	a4,a5,1023
    80001304:	fd7704e3          	beq	a4,s7,800012cc <uvmunmap+0x66>
    if(do_free){
    80001308:	fc0b0ae3          	beqz	s6,800012dc <uvmunmap+0x76>
      uint64 pa = PTE2PA(*pte);
    8000130c:	83a9                	srli	a5,a5,0xa
      kfree((void*)pa);
    8000130e:	00c79513          	slli	a0,a5,0xc
    80001312:	fffff097          	auipc	ra,0xfffff
    80001316:	6d2080e7          	jalr	1746(ra) # 800009e4 <kfree>
    8000131a:	b7c9                	j	800012dc <uvmunmap+0x76>

000000008000131c <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    8000131c:	1101                	addi	sp,sp,-32
    8000131e:	ec06                	sd	ra,24(sp)
    80001320:	e822                	sd	s0,16(sp)
    80001322:	e426                	sd	s1,8(sp)
    80001324:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    80001326:	fffff097          	auipc	ra,0xfffff
    8000132a:	7bc080e7          	jalr	1980(ra) # 80000ae2 <kalloc>
    8000132e:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001330:	c519                	beqz	a0,8000133e <uvmcreate+0x22>
    return 0;
  memset(pagetable, 0, PGSIZE);
    80001332:	6605                	lui	a2,0x1
    80001334:	4581                	li	a1,0
    80001336:	00000097          	auipc	ra,0x0
    8000133a:	998080e7          	jalr	-1640(ra) # 80000cce <memset>
  return pagetable;
}
    8000133e:	8526                	mv	a0,s1
    80001340:	60e2                	ld	ra,24(sp)
    80001342:	6442                	ld	s0,16(sp)
    80001344:	64a2                	ld	s1,8(sp)
    80001346:	6105                	addi	sp,sp,32
    80001348:	8082                	ret

000000008000134a <uvmfirst>:
// Load the user initcode into address 0 of pagetable,
// for the very first process.
// sz must be less than a page.
void
uvmfirst(pagetable_t pagetable, uchar *src, uint sz)
{
    8000134a:	7179                	addi	sp,sp,-48
    8000134c:	f406                	sd	ra,40(sp)
    8000134e:	f022                	sd	s0,32(sp)
    80001350:	ec26                	sd	s1,24(sp)
    80001352:	e84a                	sd	s2,16(sp)
    80001354:	e44e                	sd	s3,8(sp)
    80001356:	e052                	sd	s4,0(sp)
    80001358:	1800                	addi	s0,sp,48
  char *mem;

  if(sz >= PGSIZE)
    8000135a:	6785                	lui	a5,0x1
    8000135c:	04f67863          	bgeu	a2,a5,800013ac <uvmfirst+0x62>
    80001360:	8a2a                	mv	s4,a0
    80001362:	89ae                	mv	s3,a1
    80001364:	84b2                	mv	s1,a2
    panic("uvmfirst: more than a page");
  mem = kalloc();
    80001366:	fffff097          	auipc	ra,0xfffff
    8000136a:	77c080e7          	jalr	1916(ra) # 80000ae2 <kalloc>
    8000136e:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    80001370:	6605                	lui	a2,0x1
    80001372:	4581                	li	a1,0
    80001374:	00000097          	auipc	ra,0x0
    80001378:	95a080e7          	jalr	-1702(ra) # 80000cce <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
    8000137c:	4779                	li	a4,30
    8000137e:	86ca                	mv	a3,s2
    80001380:	6605                	lui	a2,0x1
    80001382:	4581                	li	a1,0
    80001384:	8552                	mv	a0,s4
    80001386:	00000097          	auipc	ra,0x0
    8000138a:	d1a080e7          	jalr	-742(ra) # 800010a0 <mappages>
  memmove(mem, src, sz);
    8000138e:	8626                	mv	a2,s1
    80001390:	85ce                	mv	a1,s3
    80001392:	854a                	mv	a0,s2
    80001394:	00000097          	auipc	ra,0x0
    80001398:	996080e7          	jalr	-1642(ra) # 80000d2a <memmove>
}
    8000139c:	70a2                	ld	ra,40(sp)
    8000139e:	7402                	ld	s0,32(sp)
    800013a0:	64e2                	ld	s1,24(sp)
    800013a2:	6942                	ld	s2,16(sp)
    800013a4:	69a2                	ld	s3,8(sp)
    800013a6:	6a02                	ld	s4,0(sp)
    800013a8:	6145                	addi	sp,sp,48
    800013aa:	8082                	ret
    panic("uvmfirst: more than a page");
    800013ac:	00007517          	auipc	a0,0x7
    800013b0:	d9450513          	addi	a0,a0,-620 # 80008140 <digits+0x100>
    800013b4:	fffff097          	auipc	ra,0xfffff
    800013b8:	188080e7          	jalr	392(ra) # 8000053c <panic>

00000000800013bc <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    800013bc:	1101                	addi	sp,sp,-32
    800013be:	ec06                	sd	ra,24(sp)
    800013c0:	e822                	sd	s0,16(sp)
    800013c2:	e426                	sd	s1,8(sp)
    800013c4:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    800013c6:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    800013c8:	00b67d63          	bgeu	a2,a1,800013e2 <uvmdealloc+0x26>
    800013cc:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    800013ce:	6785                	lui	a5,0x1
    800013d0:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    800013d2:	00f60733          	add	a4,a2,a5
    800013d6:	76fd                	lui	a3,0xfffff
    800013d8:	8f75                	and	a4,a4,a3
    800013da:	97ae                	add	a5,a5,a1
    800013dc:	8ff5                	and	a5,a5,a3
    800013de:	00f76863          	bltu	a4,a5,800013ee <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    800013e2:	8526                	mv	a0,s1
    800013e4:	60e2                	ld	ra,24(sp)
    800013e6:	6442                	ld	s0,16(sp)
    800013e8:	64a2                	ld	s1,8(sp)
    800013ea:	6105                	addi	sp,sp,32
    800013ec:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    800013ee:	8f99                	sub	a5,a5,a4
    800013f0:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    800013f2:	4685                	li	a3,1
    800013f4:	0007861b          	sext.w	a2,a5
    800013f8:	85ba                	mv	a1,a4
    800013fa:	00000097          	auipc	ra,0x0
    800013fe:	e6c080e7          	jalr	-404(ra) # 80001266 <uvmunmap>
    80001402:	b7c5                	j	800013e2 <uvmdealloc+0x26>

0000000080001404 <uvmalloc>:
  if(newsz < oldsz)
    80001404:	0ab66563          	bltu	a2,a1,800014ae <uvmalloc+0xaa>
{
    80001408:	7139                	addi	sp,sp,-64
    8000140a:	fc06                	sd	ra,56(sp)
    8000140c:	f822                	sd	s0,48(sp)
    8000140e:	f426                	sd	s1,40(sp)
    80001410:	f04a                	sd	s2,32(sp)
    80001412:	ec4e                	sd	s3,24(sp)
    80001414:	e852                	sd	s4,16(sp)
    80001416:	e456                	sd	s5,8(sp)
    80001418:	e05a                	sd	s6,0(sp)
    8000141a:	0080                	addi	s0,sp,64
    8000141c:	8aaa                	mv	s5,a0
    8000141e:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    80001420:	6785                	lui	a5,0x1
    80001422:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80001424:	95be                	add	a1,a1,a5
    80001426:	77fd                	lui	a5,0xfffff
    80001428:	00f5f9b3          	and	s3,a1,a5
  for(a = oldsz; a < newsz; a += PGSIZE){
    8000142c:	08c9f363          	bgeu	s3,a2,800014b2 <uvmalloc+0xae>
    80001430:	894e                	mv	s2,s3
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    80001432:	0126eb13          	ori	s6,a3,18
    mem = kalloc();
    80001436:	fffff097          	auipc	ra,0xfffff
    8000143a:	6ac080e7          	jalr	1708(ra) # 80000ae2 <kalloc>
    8000143e:	84aa                	mv	s1,a0
    if(mem == 0){
    80001440:	c51d                	beqz	a0,8000146e <uvmalloc+0x6a>
    memset(mem, 0, PGSIZE);
    80001442:	6605                	lui	a2,0x1
    80001444:	4581                	li	a1,0
    80001446:	00000097          	auipc	ra,0x0
    8000144a:	888080e7          	jalr	-1912(ra) # 80000cce <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    8000144e:	875a                	mv	a4,s6
    80001450:	86a6                	mv	a3,s1
    80001452:	6605                	lui	a2,0x1
    80001454:	85ca                	mv	a1,s2
    80001456:	8556                	mv	a0,s5
    80001458:	00000097          	auipc	ra,0x0
    8000145c:	c48080e7          	jalr	-952(ra) # 800010a0 <mappages>
    80001460:	e90d                	bnez	a0,80001492 <uvmalloc+0x8e>
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001462:	6785                	lui	a5,0x1
    80001464:	993e                	add	s2,s2,a5
    80001466:	fd4968e3          	bltu	s2,s4,80001436 <uvmalloc+0x32>
  return newsz;
    8000146a:	8552                	mv	a0,s4
    8000146c:	a809                	j	8000147e <uvmalloc+0x7a>
      uvmdealloc(pagetable, a, oldsz);
    8000146e:	864e                	mv	a2,s3
    80001470:	85ca                	mv	a1,s2
    80001472:	8556                	mv	a0,s5
    80001474:	00000097          	auipc	ra,0x0
    80001478:	f48080e7          	jalr	-184(ra) # 800013bc <uvmdealloc>
      return 0;
    8000147c:	4501                	li	a0,0
}
    8000147e:	70e2                	ld	ra,56(sp)
    80001480:	7442                	ld	s0,48(sp)
    80001482:	74a2                	ld	s1,40(sp)
    80001484:	7902                	ld	s2,32(sp)
    80001486:	69e2                	ld	s3,24(sp)
    80001488:	6a42                	ld	s4,16(sp)
    8000148a:	6aa2                	ld	s5,8(sp)
    8000148c:	6b02                	ld	s6,0(sp)
    8000148e:	6121                	addi	sp,sp,64
    80001490:	8082                	ret
      kfree(mem);
    80001492:	8526                	mv	a0,s1
    80001494:	fffff097          	auipc	ra,0xfffff
    80001498:	550080e7          	jalr	1360(ra) # 800009e4 <kfree>
      uvmdealloc(pagetable, a, oldsz);
    8000149c:	864e                	mv	a2,s3
    8000149e:	85ca                	mv	a1,s2
    800014a0:	8556                	mv	a0,s5
    800014a2:	00000097          	auipc	ra,0x0
    800014a6:	f1a080e7          	jalr	-230(ra) # 800013bc <uvmdealloc>
      return 0;
    800014aa:	4501                	li	a0,0
    800014ac:	bfc9                	j	8000147e <uvmalloc+0x7a>
    return oldsz;
    800014ae:	852e                	mv	a0,a1
}
    800014b0:	8082                	ret
  return newsz;
    800014b2:	8532                	mv	a0,a2
    800014b4:	b7e9                	j	8000147e <uvmalloc+0x7a>

00000000800014b6 <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    800014b6:	7179                	addi	sp,sp,-48
    800014b8:	f406                	sd	ra,40(sp)
    800014ba:	f022                	sd	s0,32(sp)
    800014bc:	ec26                	sd	s1,24(sp)
    800014be:	e84a                	sd	s2,16(sp)
    800014c0:	e44e                	sd	s3,8(sp)
    800014c2:	e052                	sd	s4,0(sp)
    800014c4:	1800                	addi	s0,sp,48
    800014c6:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    800014c8:	84aa                	mv	s1,a0
    800014ca:	6905                	lui	s2,0x1
    800014cc:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800014ce:	4985                	li	s3,1
    800014d0:	a829                	j	800014ea <freewalk+0x34>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    800014d2:	83a9                	srli	a5,a5,0xa
      freewalk((pagetable_t)child);
    800014d4:	00c79513          	slli	a0,a5,0xc
    800014d8:	00000097          	auipc	ra,0x0
    800014dc:	fde080e7          	jalr	-34(ra) # 800014b6 <freewalk>
      pagetable[i] = 0;
    800014e0:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    800014e4:	04a1                	addi	s1,s1,8
    800014e6:	03248163          	beq	s1,s2,80001508 <freewalk+0x52>
    pte_t pte = pagetable[i];
    800014ea:	609c                	ld	a5,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800014ec:	00f7f713          	andi	a4,a5,15
    800014f0:	ff3701e3          	beq	a4,s3,800014d2 <freewalk+0x1c>
    } else if(pte & PTE_V){
    800014f4:	8b85                	andi	a5,a5,1
    800014f6:	d7fd                	beqz	a5,800014e4 <freewalk+0x2e>
      panic("freewalk: leaf");
    800014f8:	00007517          	auipc	a0,0x7
    800014fc:	c6850513          	addi	a0,a0,-920 # 80008160 <digits+0x120>
    80001500:	fffff097          	auipc	ra,0xfffff
    80001504:	03c080e7          	jalr	60(ra) # 8000053c <panic>
    }
  }
  kfree((void*)pagetable);
    80001508:	8552                	mv	a0,s4
    8000150a:	fffff097          	auipc	ra,0xfffff
    8000150e:	4da080e7          	jalr	1242(ra) # 800009e4 <kfree>
}
    80001512:	70a2                	ld	ra,40(sp)
    80001514:	7402                	ld	s0,32(sp)
    80001516:	64e2                	ld	s1,24(sp)
    80001518:	6942                	ld	s2,16(sp)
    8000151a:	69a2                	ld	s3,8(sp)
    8000151c:	6a02                	ld	s4,0(sp)
    8000151e:	6145                	addi	sp,sp,48
    80001520:	8082                	ret

0000000080001522 <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    80001522:	1101                	addi	sp,sp,-32
    80001524:	ec06                	sd	ra,24(sp)
    80001526:	e822                	sd	s0,16(sp)
    80001528:	e426                	sd	s1,8(sp)
    8000152a:	1000                	addi	s0,sp,32
    8000152c:	84aa                	mv	s1,a0
  if(sz > 0)
    8000152e:	e999                	bnez	a1,80001544 <uvmfree+0x22>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    80001530:	8526                	mv	a0,s1
    80001532:	00000097          	auipc	ra,0x0
    80001536:	f84080e7          	jalr	-124(ra) # 800014b6 <freewalk>
}
    8000153a:	60e2                	ld	ra,24(sp)
    8000153c:	6442                	ld	s0,16(sp)
    8000153e:	64a2                	ld	s1,8(sp)
    80001540:	6105                	addi	sp,sp,32
    80001542:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    80001544:	6785                	lui	a5,0x1
    80001546:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80001548:	95be                	add	a1,a1,a5
    8000154a:	4685                	li	a3,1
    8000154c:	00c5d613          	srli	a2,a1,0xc
    80001550:	4581                	li	a1,0
    80001552:	00000097          	auipc	ra,0x0
    80001556:	d14080e7          	jalr	-748(ra) # 80001266 <uvmunmap>
    8000155a:	bfd9                	j	80001530 <uvmfree+0xe>

000000008000155c <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    8000155c:	c679                	beqz	a2,8000162a <uvmcopy+0xce>
{
    8000155e:	715d                	addi	sp,sp,-80
    80001560:	e486                	sd	ra,72(sp)
    80001562:	e0a2                	sd	s0,64(sp)
    80001564:	fc26                	sd	s1,56(sp)
    80001566:	f84a                	sd	s2,48(sp)
    80001568:	f44e                	sd	s3,40(sp)
    8000156a:	f052                	sd	s4,32(sp)
    8000156c:	ec56                	sd	s5,24(sp)
    8000156e:	e85a                	sd	s6,16(sp)
    80001570:	e45e                	sd	s7,8(sp)
    80001572:	0880                	addi	s0,sp,80
    80001574:	8b2a                	mv	s6,a0
    80001576:	8aae                	mv	s5,a1
    80001578:	8a32                	mv	s4,a2
  for(i = 0; i < sz; i += PGSIZE){
    8000157a:	4981                	li	s3,0
    if((pte = walk(old, i, 0)) == 0)
    8000157c:	4601                	li	a2,0
    8000157e:	85ce                	mv	a1,s3
    80001580:	855a                	mv	a0,s6
    80001582:	00000097          	auipc	ra,0x0
    80001586:	a36080e7          	jalr	-1482(ra) # 80000fb8 <walk>
    8000158a:	c531                	beqz	a0,800015d6 <uvmcopy+0x7a>
      panic("uvmcopy: pte should exist");
    if((*pte & PTE_V) == 0)
    8000158c:	6118                	ld	a4,0(a0)
    8000158e:	00177793          	andi	a5,a4,1
    80001592:	cbb1                	beqz	a5,800015e6 <uvmcopy+0x8a>
      panic("uvmcopy: page not present");
    pa = PTE2PA(*pte);
    80001594:	00a75593          	srli	a1,a4,0xa
    80001598:	00c59b93          	slli	s7,a1,0xc
    flags = PTE_FLAGS(*pte);
    8000159c:	3ff77493          	andi	s1,a4,1023
    if((mem = kalloc()) == 0)
    800015a0:	fffff097          	auipc	ra,0xfffff
    800015a4:	542080e7          	jalr	1346(ra) # 80000ae2 <kalloc>
    800015a8:	892a                	mv	s2,a0
    800015aa:	c939                	beqz	a0,80001600 <uvmcopy+0xa4>
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    800015ac:	6605                	lui	a2,0x1
    800015ae:	85de                	mv	a1,s7
    800015b0:	fffff097          	auipc	ra,0xfffff
    800015b4:	77a080e7          	jalr	1914(ra) # 80000d2a <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    800015b8:	8726                	mv	a4,s1
    800015ba:	86ca                	mv	a3,s2
    800015bc:	6605                	lui	a2,0x1
    800015be:	85ce                	mv	a1,s3
    800015c0:	8556                	mv	a0,s5
    800015c2:	00000097          	auipc	ra,0x0
    800015c6:	ade080e7          	jalr	-1314(ra) # 800010a0 <mappages>
    800015ca:	e515                	bnez	a0,800015f6 <uvmcopy+0x9a>
  for(i = 0; i < sz; i += PGSIZE){
    800015cc:	6785                	lui	a5,0x1
    800015ce:	99be                	add	s3,s3,a5
    800015d0:	fb49e6e3          	bltu	s3,s4,8000157c <uvmcopy+0x20>
    800015d4:	a081                	j	80001614 <uvmcopy+0xb8>
      panic("uvmcopy: pte should exist");
    800015d6:	00007517          	auipc	a0,0x7
    800015da:	b9a50513          	addi	a0,a0,-1126 # 80008170 <digits+0x130>
    800015de:	fffff097          	auipc	ra,0xfffff
    800015e2:	f5e080e7          	jalr	-162(ra) # 8000053c <panic>
      panic("uvmcopy: page not present");
    800015e6:	00007517          	auipc	a0,0x7
    800015ea:	baa50513          	addi	a0,a0,-1110 # 80008190 <digits+0x150>
    800015ee:	fffff097          	auipc	ra,0xfffff
    800015f2:	f4e080e7          	jalr	-178(ra) # 8000053c <panic>
      kfree(mem);
    800015f6:	854a                	mv	a0,s2
    800015f8:	fffff097          	auipc	ra,0xfffff
    800015fc:	3ec080e7          	jalr	1004(ra) # 800009e4 <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    80001600:	4685                	li	a3,1
    80001602:	00c9d613          	srli	a2,s3,0xc
    80001606:	4581                	li	a1,0
    80001608:	8556                	mv	a0,s5
    8000160a:	00000097          	auipc	ra,0x0
    8000160e:	c5c080e7          	jalr	-932(ra) # 80001266 <uvmunmap>
  return -1;
    80001612:	557d                	li	a0,-1
}
    80001614:	60a6                	ld	ra,72(sp)
    80001616:	6406                	ld	s0,64(sp)
    80001618:	74e2                	ld	s1,56(sp)
    8000161a:	7942                	ld	s2,48(sp)
    8000161c:	79a2                	ld	s3,40(sp)
    8000161e:	7a02                	ld	s4,32(sp)
    80001620:	6ae2                	ld	s5,24(sp)
    80001622:	6b42                	ld	s6,16(sp)
    80001624:	6ba2                	ld	s7,8(sp)
    80001626:	6161                	addi	sp,sp,80
    80001628:	8082                	ret
  return 0;
    8000162a:	4501                	li	a0,0
}
    8000162c:	8082                	ret

000000008000162e <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    8000162e:	1141                	addi	sp,sp,-16
    80001630:	e406                	sd	ra,8(sp)
    80001632:	e022                	sd	s0,0(sp)
    80001634:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    80001636:	4601                	li	a2,0
    80001638:	00000097          	auipc	ra,0x0
    8000163c:	980080e7          	jalr	-1664(ra) # 80000fb8 <walk>
  if(pte == 0)
    80001640:	c901                	beqz	a0,80001650 <uvmclear+0x22>
    panic("uvmclear");
  *pte &= ~PTE_U;
    80001642:	611c                	ld	a5,0(a0)
    80001644:	9bbd                	andi	a5,a5,-17
    80001646:	e11c                	sd	a5,0(a0)
}
    80001648:	60a2                	ld	ra,8(sp)
    8000164a:	6402                	ld	s0,0(sp)
    8000164c:	0141                	addi	sp,sp,16
    8000164e:	8082                	ret
    panic("uvmclear");
    80001650:	00007517          	auipc	a0,0x7
    80001654:	b6050513          	addi	a0,a0,-1184 # 800081b0 <digits+0x170>
    80001658:	fffff097          	auipc	ra,0xfffff
    8000165c:	ee4080e7          	jalr	-284(ra) # 8000053c <panic>

0000000080001660 <uvminvalid>:

// CSE 536: mark a PTE invalid. For swapping 
// pages in and out of memory.
void
uvminvalid(pagetable_t pagetable, uint64 va)
{
    80001660:	1141                	addi	sp,sp,-16
    80001662:	e406                	sd	ra,8(sp)
    80001664:	e022                	sd	s0,0(sp)
    80001666:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    80001668:	4601                	li	a2,0
    8000166a:	00000097          	auipc	ra,0x0
    8000166e:	94e080e7          	jalr	-1714(ra) # 80000fb8 <walk>
  if(pte == 0)
    80001672:	c901                	beqz	a0,80001682 <uvminvalid+0x22>
    panic("uvminvalid");
  *pte &= ~PTE_V;
    80001674:	611c                	ld	a5,0(a0)
    80001676:	9bf9                	andi	a5,a5,-2
    80001678:	e11c                	sd	a5,0(a0)
}
    8000167a:	60a2                	ld	ra,8(sp)
    8000167c:	6402                	ld	s0,0(sp)
    8000167e:	0141                	addi	sp,sp,16
    80001680:	8082                	ret
    panic("uvminvalid");
    80001682:	00007517          	auipc	a0,0x7
    80001686:	b3e50513          	addi	a0,a0,-1218 # 800081c0 <digits+0x180>
    8000168a:	fffff097          	auipc	ra,0xfffff
    8000168e:	eb2080e7          	jalr	-334(ra) # 8000053c <panic>

0000000080001692 <copyout>:
int
copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    80001692:	c6bd                	beqz	a3,80001700 <copyout+0x6e>
{
    80001694:	715d                	addi	sp,sp,-80
    80001696:	e486                	sd	ra,72(sp)
    80001698:	e0a2                	sd	s0,64(sp)
    8000169a:	fc26                	sd	s1,56(sp)
    8000169c:	f84a                	sd	s2,48(sp)
    8000169e:	f44e                	sd	s3,40(sp)
    800016a0:	f052                	sd	s4,32(sp)
    800016a2:	ec56                	sd	s5,24(sp)
    800016a4:	e85a                	sd	s6,16(sp)
    800016a6:	e45e                	sd	s7,8(sp)
    800016a8:	e062                	sd	s8,0(sp)
    800016aa:	0880                	addi	s0,sp,80
    800016ac:	8b2a                	mv	s6,a0
    800016ae:	8c2e                	mv	s8,a1
    800016b0:	8a32                	mv	s4,a2
    800016b2:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(dstva);
    800016b4:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if (pa0 == 0){
      return -1;
    }
    n = PGSIZE - (dstva - va0);
    800016b6:	6a85                	lui	s5,0x1
    800016b8:	a015                	j	800016dc <copyout+0x4a>
    if(n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    800016ba:	9562                	add	a0,a0,s8
    800016bc:	0004861b          	sext.w	a2,s1
    800016c0:	85d2                	mv	a1,s4
    800016c2:	41250533          	sub	a0,a0,s2
    800016c6:	fffff097          	auipc	ra,0xfffff
    800016ca:	664080e7          	jalr	1636(ra) # 80000d2a <memmove>

    len -= n;
    800016ce:	409989b3          	sub	s3,s3,s1
    src += n;
    800016d2:	9a26                	add	s4,s4,s1
    dstva = va0 + PGSIZE;
    800016d4:	01590c33          	add	s8,s2,s5
  while(len > 0){
    800016d8:	02098263          	beqz	s3,800016fc <copyout+0x6a>
    va0 = PGROUNDDOWN(dstva);
    800016dc:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    800016e0:	85ca                	mv	a1,s2
    800016e2:	855a                	mv	a0,s6
    800016e4:	00000097          	auipc	ra,0x0
    800016e8:	97a080e7          	jalr	-1670(ra) # 8000105e <walkaddr>
    if (pa0 == 0){
    800016ec:	cd01                	beqz	a0,80001704 <copyout+0x72>
    n = PGSIZE - (dstva - va0);
    800016ee:	418904b3          	sub	s1,s2,s8
    800016f2:	94d6                	add	s1,s1,s5
    800016f4:	fc99f3e3          	bgeu	s3,s1,800016ba <copyout+0x28>
    800016f8:	84ce                	mv	s1,s3
    800016fa:	b7c1                	j	800016ba <copyout+0x28>
  }
  return 0;
    800016fc:	4501                	li	a0,0
    800016fe:	a021                	j	80001706 <copyout+0x74>
    80001700:	4501                	li	a0,0
}
    80001702:	8082                	ret
      return -1;
    80001704:	557d                	li	a0,-1
}
    80001706:	60a6                	ld	ra,72(sp)
    80001708:	6406                	ld	s0,64(sp)
    8000170a:	74e2                	ld	s1,56(sp)
    8000170c:	7942                	ld	s2,48(sp)
    8000170e:	79a2                	ld	s3,40(sp)
    80001710:	7a02                	ld	s4,32(sp)
    80001712:	6ae2                	ld	s5,24(sp)
    80001714:	6b42                	ld	s6,16(sp)
    80001716:	6ba2                	ld	s7,8(sp)
    80001718:	6c02                	ld	s8,0(sp)
    8000171a:	6161                	addi	sp,sp,80
    8000171c:	8082                	ret

000000008000171e <copyin>:
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    8000171e:	caa5                	beqz	a3,8000178e <copyin+0x70>
{
    80001720:	715d                	addi	sp,sp,-80
    80001722:	e486                	sd	ra,72(sp)
    80001724:	e0a2                	sd	s0,64(sp)
    80001726:	fc26                	sd	s1,56(sp)
    80001728:	f84a                	sd	s2,48(sp)
    8000172a:	f44e                	sd	s3,40(sp)
    8000172c:	f052                	sd	s4,32(sp)
    8000172e:	ec56                	sd	s5,24(sp)
    80001730:	e85a                	sd	s6,16(sp)
    80001732:	e45e                	sd	s7,8(sp)
    80001734:	e062                	sd	s8,0(sp)
    80001736:	0880                	addi	s0,sp,80
    80001738:	8b2a                	mv	s6,a0
    8000173a:	8a2e                	mv	s4,a1
    8000173c:	8c32                	mv	s8,a2
    8000173e:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    80001740:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80001742:	6a85                	lui	s5,0x1
    80001744:	a01d                	j	8000176a <copyin+0x4c>
    if(n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    80001746:	018505b3          	add	a1,a0,s8
    8000174a:	0004861b          	sext.w	a2,s1
    8000174e:	412585b3          	sub	a1,a1,s2
    80001752:	8552                	mv	a0,s4
    80001754:	fffff097          	auipc	ra,0xfffff
    80001758:	5d6080e7          	jalr	1494(ra) # 80000d2a <memmove>

    len -= n;
    8000175c:	409989b3          	sub	s3,s3,s1
    dst += n;
    80001760:	9a26                	add	s4,s4,s1
    srcva = va0 + PGSIZE;
    80001762:	01590c33          	add	s8,s2,s5
  while(len > 0){
    80001766:	02098263          	beqz	s3,8000178a <copyin+0x6c>
    va0 = PGROUNDDOWN(srcva);
    8000176a:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    8000176e:	85ca                	mv	a1,s2
    80001770:	855a                	mv	a0,s6
    80001772:	00000097          	auipc	ra,0x0
    80001776:	8ec080e7          	jalr	-1812(ra) # 8000105e <walkaddr>
    if(pa0 == 0)
    8000177a:	cd01                	beqz	a0,80001792 <copyin+0x74>
    n = PGSIZE - (srcva - va0);
    8000177c:	418904b3          	sub	s1,s2,s8
    80001780:	94d6                	add	s1,s1,s5
    80001782:	fc99f2e3          	bgeu	s3,s1,80001746 <copyin+0x28>
    80001786:	84ce                	mv	s1,s3
    80001788:	bf7d                	j	80001746 <copyin+0x28>
  }
  return 0;
    8000178a:	4501                	li	a0,0
    8000178c:	a021                	j	80001794 <copyin+0x76>
    8000178e:	4501                	li	a0,0
}
    80001790:	8082                	ret
      return -1;
    80001792:	557d                	li	a0,-1
}
    80001794:	60a6                	ld	ra,72(sp)
    80001796:	6406                	ld	s0,64(sp)
    80001798:	74e2                	ld	s1,56(sp)
    8000179a:	7942                	ld	s2,48(sp)
    8000179c:	79a2                	ld	s3,40(sp)
    8000179e:	7a02                	ld	s4,32(sp)
    800017a0:	6ae2                	ld	s5,24(sp)
    800017a2:	6b42                	ld	s6,16(sp)
    800017a4:	6ba2                	ld	s7,8(sp)
    800017a6:	6c02                	ld	s8,0(sp)
    800017a8:	6161                	addi	sp,sp,80
    800017aa:	8082                	ret

00000000800017ac <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    800017ac:	c2dd                	beqz	a3,80001852 <copyinstr+0xa6>
{
    800017ae:	715d                	addi	sp,sp,-80
    800017b0:	e486                	sd	ra,72(sp)
    800017b2:	e0a2                	sd	s0,64(sp)
    800017b4:	fc26                	sd	s1,56(sp)
    800017b6:	f84a                	sd	s2,48(sp)
    800017b8:	f44e                	sd	s3,40(sp)
    800017ba:	f052                	sd	s4,32(sp)
    800017bc:	ec56                	sd	s5,24(sp)
    800017be:	e85a                	sd	s6,16(sp)
    800017c0:	e45e                	sd	s7,8(sp)
    800017c2:	0880                	addi	s0,sp,80
    800017c4:	8a2a                	mv	s4,a0
    800017c6:	8b2e                	mv	s6,a1
    800017c8:	8bb2                	mv	s7,a2
    800017ca:	84b6                	mv	s1,a3
    va0 = PGROUNDDOWN(srcva);
    800017cc:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    800017ce:	6985                	lui	s3,0x1
    800017d0:	a02d                	j	800017fa <copyinstr+0x4e>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    800017d2:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    800017d6:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    800017d8:	37fd                	addiw	a5,a5,-1
    800017da:	0007851b          	sext.w	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    800017de:	60a6                	ld	ra,72(sp)
    800017e0:	6406                	ld	s0,64(sp)
    800017e2:	74e2                	ld	s1,56(sp)
    800017e4:	7942                	ld	s2,48(sp)
    800017e6:	79a2                	ld	s3,40(sp)
    800017e8:	7a02                	ld	s4,32(sp)
    800017ea:	6ae2                	ld	s5,24(sp)
    800017ec:	6b42                	ld	s6,16(sp)
    800017ee:	6ba2                	ld	s7,8(sp)
    800017f0:	6161                	addi	sp,sp,80
    800017f2:	8082                	ret
    srcva = va0 + PGSIZE;
    800017f4:	01390bb3          	add	s7,s2,s3
  while(got_null == 0 && max > 0){
    800017f8:	c8a9                	beqz	s1,8000184a <copyinstr+0x9e>
    va0 = PGROUNDDOWN(srcva);
    800017fa:	015bf933          	and	s2,s7,s5
    pa0 = walkaddr(pagetable, va0);
    800017fe:	85ca                	mv	a1,s2
    80001800:	8552                	mv	a0,s4
    80001802:	00000097          	auipc	ra,0x0
    80001806:	85c080e7          	jalr	-1956(ra) # 8000105e <walkaddr>
    if(pa0 == 0)
    8000180a:	c131                	beqz	a0,8000184e <copyinstr+0xa2>
    n = PGSIZE - (srcva - va0);
    8000180c:	417906b3          	sub	a3,s2,s7
    80001810:	96ce                	add	a3,a3,s3
    80001812:	00d4f363          	bgeu	s1,a3,80001818 <copyinstr+0x6c>
    80001816:	86a6                	mv	a3,s1
    char *p = (char *) (pa0 + (srcva - va0));
    80001818:	955e                	add	a0,a0,s7
    8000181a:	41250533          	sub	a0,a0,s2
    while(n > 0){
    8000181e:	daf9                	beqz	a3,800017f4 <copyinstr+0x48>
    80001820:	87da                	mv	a5,s6
    80001822:	885a                	mv	a6,s6
      if(*p == '\0'){
    80001824:	41650633          	sub	a2,a0,s6
    while(n > 0){
    80001828:	96da                	add	a3,a3,s6
    8000182a:	85be                	mv	a1,a5
      if(*p == '\0'){
    8000182c:	00f60733          	add	a4,a2,a5
    80001830:	00074703          	lbu	a4,0(a4) # fffffffffffff000 <end+0xffffffff7fe658f0>
    80001834:	df59                	beqz	a4,800017d2 <copyinstr+0x26>
        *dst = *p;
    80001836:	00e78023          	sb	a4,0(a5)
      dst++;
    8000183a:	0785                	addi	a5,a5,1
    while(n > 0){
    8000183c:	fed797e3          	bne	a5,a3,8000182a <copyinstr+0x7e>
    80001840:	14fd                	addi	s1,s1,-1
    80001842:	94c2                	add	s1,s1,a6
      --max;
    80001844:	8c8d                	sub	s1,s1,a1
      dst++;
    80001846:	8b3e                	mv	s6,a5
    80001848:	b775                	j	800017f4 <copyinstr+0x48>
    8000184a:	4781                	li	a5,0
    8000184c:	b771                	j	800017d8 <copyinstr+0x2c>
      return -1;
    8000184e:	557d                	li	a0,-1
    80001850:	b779                	j	800017de <copyinstr+0x32>
  int got_null = 0;
    80001852:	4781                	li	a5,0
  if(got_null){
    80001854:	37fd                	addiw	a5,a5,-1
    80001856:	0007851b          	sext.w	a0,a5
}
    8000185a:	8082                	ret

000000008000185c <proc_mapstacks>:
// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void
proc_mapstacks(pagetable_t kpgtbl)
{
    8000185c:	715d                	addi	sp,sp,-80
    8000185e:	e486                	sd	ra,72(sp)
    80001860:	e0a2                	sd	s0,64(sp)
    80001862:	fc26                	sd	s1,56(sp)
    80001864:	f84a                	sd	s2,48(sp)
    80001866:	f44e                	sd	s3,40(sp)
    80001868:	f052                	sd	s4,32(sp)
    8000186a:	ec56                	sd	s5,24(sp)
    8000186c:	e85a                	sd	s6,16(sp)
    8000186e:	e45e                	sd	s7,8(sp)
    80001870:	0880                	addi	s0,sp,80
    80001872:	8a2a                	mv	s4,a0
  struct proc *p;
  
  for(p = proc; p < &proc[NPROC]; p++) {
    80001874:	00010497          	auipc	s1,0x10
    80001878:	8cc48493          	addi	s1,s1,-1844 # 80011140 <proc>
    char *pa = kalloc();
    if(pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int) (p - proc));
    8000187c:	8ba6                	mv	s7,s1
    8000187e:	00006b17          	auipc	s6,0x6
    80001882:	782b0b13          	addi	s6,s6,1922 # 80008000 <etext>
    80001886:	04000937          	lui	s2,0x4000
    8000188a:	197d                	addi	s2,s2,-1 # 3ffffff <_entry-0x7c000001>
    8000188c:	0932                	slli	s2,s2,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    8000188e:	6999                	lui	s3,0x6
    80001890:	f3898993          	addi	s3,s3,-200 # 5f38 <_entry-0x7fffa0c8>
    80001894:	0018ca97          	auipc	s5,0x18c
    80001898:	6aca8a93          	addi	s5,s5,1708 # 8018df40 <tickslock>
    char *pa = kalloc();
    8000189c:	fffff097          	auipc	ra,0xfffff
    800018a0:	246080e7          	jalr	582(ra) # 80000ae2 <kalloc>
    800018a4:	862a                	mv	a2,a0
    if(pa == 0)
    800018a6:	c131                	beqz	a0,800018ea <proc_mapstacks+0x8e>
    uint64 va = KSTACK((int) (p - proc));
    800018a8:	417485b3          	sub	a1,s1,s7
    800018ac:	858d                	srai	a1,a1,0x3
    800018ae:	000b3783          	ld	a5,0(s6)
    800018b2:	02f585b3          	mul	a1,a1,a5
    800018b6:	2585                	addiw	a1,a1,1
    800018b8:	00d5959b          	slliw	a1,a1,0xd
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    800018bc:	4719                	li	a4,6
    800018be:	6685                	lui	a3,0x1
    800018c0:	40b905b3          	sub	a1,s2,a1
    800018c4:	8552                	mv	a0,s4
    800018c6:	00000097          	auipc	ra,0x0
    800018ca:	87a080e7          	jalr	-1926(ra) # 80001140 <kvmmap>
  for(p = proc; p < &proc[NPROC]; p++) {
    800018ce:	94ce                	add	s1,s1,s3
    800018d0:	fd5496e3          	bne	s1,s5,8000189c <proc_mapstacks+0x40>
  }
}
    800018d4:	60a6                	ld	ra,72(sp)
    800018d6:	6406                	ld	s0,64(sp)
    800018d8:	74e2                	ld	s1,56(sp)
    800018da:	7942                	ld	s2,48(sp)
    800018dc:	79a2                	ld	s3,40(sp)
    800018de:	7a02                	ld	s4,32(sp)
    800018e0:	6ae2                	ld	s5,24(sp)
    800018e2:	6b42                	ld	s6,16(sp)
    800018e4:	6ba2                	ld	s7,8(sp)
    800018e6:	6161                	addi	sp,sp,80
    800018e8:	8082                	ret
      panic("kalloc");
    800018ea:	00007517          	auipc	a0,0x7
    800018ee:	8e650513          	addi	a0,a0,-1818 # 800081d0 <digits+0x190>
    800018f2:	fffff097          	auipc	ra,0xfffff
    800018f6:	c4a080e7          	jalr	-950(ra) # 8000053c <panic>

00000000800018fa <procinit>:

// initialize the proc table.
void
procinit(void)
{
    800018fa:	715d                	addi	sp,sp,-80
    800018fc:	e486                	sd	ra,72(sp)
    800018fe:	e0a2                	sd	s0,64(sp)
    80001900:	fc26                	sd	s1,56(sp)
    80001902:	f84a                	sd	s2,48(sp)
    80001904:	f44e                	sd	s3,40(sp)
    80001906:	f052                	sd	s4,32(sp)
    80001908:	ec56                	sd	s5,24(sp)
    8000190a:	e85a                	sd	s6,16(sp)
    8000190c:	e45e                	sd	s7,8(sp)
    8000190e:	0880                	addi	s0,sp,80
  struct proc *p;
  
  initlock(&pid_lock, "nextpid");
    80001910:	00007597          	auipc	a1,0x7
    80001914:	8c858593          	addi	a1,a1,-1848 # 800081d8 <digits+0x198>
    80001918:	0000f517          	auipc	a0,0xf
    8000191c:	3f850513          	addi	a0,a0,1016 # 80010d10 <pid_lock>
    80001920:	fffff097          	auipc	ra,0xfffff
    80001924:	222080e7          	jalr	546(ra) # 80000b42 <initlock>
  initlock(&wait_lock, "wait_lock");
    80001928:	00007597          	auipc	a1,0x7
    8000192c:	8b858593          	addi	a1,a1,-1864 # 800081e0 <digits+0x1a0>
    80001930:	0000f517          	auipc	a0,0xf
    80001934:	3f850513          	addi	a0,a0,1016 # 80010d28 <wait_lock>
    80001938:	fffff097          	auipc	ra,0xfffff
    8000193c:	20a080e7          	jalr	522(ra) # 80000b42 <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001940:	00010497          	auipc	s1,0x10
    80001944:	80048493          	addi	s1,s1,-2048 # 80011140 <proc>
      initlock(&p->lock, "proc");
    80001948:	00007b97          	auipc	s7,0x7
    8000194c:	8a8b8b93          	addi	s7,s7,-1880 # 800081f0 <digits+0x1b0>
      p->state = UNUSED;
      p->kstack = KSTACK((int) (p - proc));
    80001950:	8b26                	mv	s6,s1
    80001952:	00006a97          	auipc	s5,0x6
    80001956:	6aea8a93          	addi	s5,s5,1710 # 80008000 <etext>
    8000195a:	04000937          	lui	s2,0x4000
    8000195e:	197d                	addi	s2,s2,-1 # 3ffffff <_entry-0x7c000001>
    80001960:	0932                	slli	s2,s2,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80001962:	6999                	lui	s3,0x6
    80001964:	f3898993          	addi	s3,s3,-200 # 5f38 <_entry-0x7fffa0c8>
    80001968:	0018ca17          	auipc	s4,0x18c
    8000196c:	5d8a0a13          	addi	s4,s4,1496 # 8018df40 <tickslock>
      initlock(&p->lock, "proc");
    80001970:	85de                	mv	a1,s7
    80001972:	8526                	mv	a0,s1
    80001974:	fffff097          	auipc	ra,0xfffff
    80001978:	1ce080e7          	jalr	462(ra) # 80000b42 <initlock>
      p->state = UNUSED;
    8000197c:	0004ac23          	sw	zero,24(s1)
      p->kstack = KSTACK((int) (p - proc));
    80001980:	416487b3          	sub	a5,s1,s6
    80001984:	878d                	srai	a5,a5,0x3
    80001986:	000ab703          	ld	a4,0(s5)
    8000198a:	02e787b3          	mul	a5,a5,a4
    8000198e:	2785                	addiw	a5,a5,1
    80001990:	00d7979b          	slliw	a5,a5,0xd
    80001994:	40f907b3          	sub	a5,s2,a5
    80001998:	e0bc                	sd	a5,64(s1)
  for(p = proc; p < &proc[NPROC]; p++) {
    8000199a:	94ce                	add	s1,s1,s3
    8000199c:	fd449ae3          	bne	s1,s4,80001970 <procinit+0x76>
  }
}
    800019a0:	60a6                	ld	ra,72(sp)
    800019a2:	6406                	ld	s0,64(sp)
    800019a4:	74e2                	ld	s1,56(sp)
    800019a6:	7942                	ld	s2,48(sp)
    800019a8:	79a2                	ld	s3,40(sp)
    800019aa:	7a02                	ld	s4,32(sp)
    800019ac:	6ae2                	ld	s5,24(sp)
    800019ae:	6b42                	ld	s6,16(sp)
    800019b0:	6ba2                	ld	s7,8(sp)
    800019b2:	6161                	addi	sp,sp,80
    800019b4:	8082                	ret

00000000800019b6 <cpuid>:
// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int
cpuid()
{
    800019b6:	1141                	addi	sp,sp,-16
    800019b8:	e422                	sd	s0,8(sp)
    800019ba:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    800019bc:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    800019be:	2501                	sext.w	a0,a0
    800019c0:	6422                	ld	s0,8(sp)
    800019c2:	0141                	addi	sp,sp,16
    800019c4:	8082                	ret

00000000800019c6 <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu*
mycpu(void)
{
    800019c6:	1141                	addi	sp,sp,-16
    800019c8:	e422                	sd	s0,8(sp)
    800019ca:	0800                	addi	s0,sp,16
    800019cc:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    800019ce:	2781                	sext.w	a5,a5
    800019d0:	079e                	slli	a5,a5,0x7
  return c;
}
    800019d2:	0000f517          	auipc	a0,0xf
    800019d6:	36e50513          	addi	a0,a0,878 # 80010d40 <cpus>
    800019da:	953e                	add	a0,a0,a5
    800019dc:	6422                	ld	s0,8(sp)
    800019de:	0141                	addi	sp,sp,16
    800019e0:	8082                	ret

00000000800019e2 <myproc>:

// Return the current struct proc *, or zero if none.
struct proc*
myproc(void)
{
    800019e2:	1101                	addi	sp,sp,-32
    800019e4:	ec06                	sd	ra,24(sp)
    800019e6:	e822                	sd	s0,16(sp)
    800019e8:	e426                	sd	s1,8(sp)
    800019ea:	1000                	addi	s0,sp,32
  push_off();
    800019ec:	fffff097          	auipc	ra,0xfffff
    800019f0:	19a080e7          	jalr	410(ra) # 80000b86 <push_off>
    800019f4:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    800019f6:	2781                	sext.w	a5,a5
    800019f8:	079e                	slli	a5,a5,0x7
    800019fa:	0000f717          	auipc	a4,0xf
    800019fe:	31670713          	addi	a4,a4,790 # 80010d10 <pid_lock>
    80001a02:	97ba                	add	a5,a5,a4
    80001a04:	7b84                	ld	s1,48(a5)
  pop_off();
    80001a06:	fffff097          	auipc	ra,0xfffff
    80001a0a:	220080e7          	jalr	544(ra) # 80000c26 <pop_off>
  return p;
}
    80001a0e:	8526                	mv	a0,s1
    80001a10:	60e2                	ld	ra,24(sp)
    80001a12:	6442                	ld	s0,16(sp)
    80001a14:	64a2                	ld	s1,8(sp)
    80001a16:	6105                	addi	sp,sp,32
    80001a18:	8082                	ret

0000000080001a1a <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
    80001a1a:	1141                	addi	sp,sp,-16
    80001a1c:	e406                	sd	ra,8(sp)
    80001a1e:	e022                	sd	s0,0(sp)
    80001a20:	0800                	addi	s0,sp,16
  static int first = 1;

  // Still holding p->lock from scheduler.
  release(&myproc()->lock);
    80001a22:	00000097          	auipc	ra,0x0
    80001a26:	fc0080e7          	jalr	-64(ra) # 800019e2 <myproc>
    80001a2a:	fffff097          	auipc	ra,0xfffff
    80001a2e:	25c080e7          	jalr	604(ra) # 80000c86 <release>

  if (first) {
    80001a32:	00007797          	auipc	a5,0x7
    80001a36:	fee7a783          	lw	a5,-18(a5) # 80008a20 <first.1>
    80001a3a:	eb89                	bnez	a5,80001a4c <forkret+0x32>
    // be run from main().
    first = 0;
    fsinit(ROOTDEV);
  }

  usertrapret();
    80001a3c:	00001097          	auipc	ra,0x1
    80001a40:	d1e080e7          	jalr	-738(ra) # 8000275a <usertrapret>
}
    80001a44:	60a2                	ld	ra,8(sp)
    80001a46:	6402                	ld	s0,0(sp)
    80001a48:	0141                	addi	sp,sp,16
    80001a4a:	8082                	ret
    first = 0;
    80001a4c:	00007797          	auipc	a5,0x7
    80001a50:	fc07aa23          	sw	zero,-44(a5) # 80008a20 <first.1>
    fsinit(ROOTDEV);
    80001a54:	4505                	li	a0,1
    80001a56:	00002097          	auipc	ra,0x2
    80001a5a:	a7a080e7          	jalr	-1414(ra) # 800034d0 <fsinit>
    80001a5e:	bff9                	j	80001a3c <forkret+0x22>

0000000080001a60 <allocpid>:
{
    80001a60:	1101                	addi	sp,sp,-32
    80001a62:	ec06                	sd	ra,24(sp)
    80001a64:	e822                	sd	s0,16(sp)
    80001a66:	e426                	sd	s1,8(sp)
    80001a68:	e04a                	sd	s2,0(sp)
    80001a6a:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001a6c:	0000f917          	auipc	s2,0xf
    80001a70:	2a490913          	addi	s2,s2,676 # 80010d10 <pid_lock>
    80001a74:	854a                	mv	a0,s2
    80001a76:	fffff097          	auipc	ra,0xfffff
    80001a7a:	15c080e7          	jalr	348(ra) # 80000bd2 <acquire>
  pid = nextpid;
    80001a7e:	00007797          	auipc	a5,0x7
    80001a82:	fa678793          	addi	a5,a5,-90 # 80008a24 <nextpid>
    80001a86:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001a88:	0014871b          	addiw	a4,s1,1
    80001a8c:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001a8e:	854a                	mv	a0,s2
    80001a90:	fffff097          	auipc	ra,0xfffff
    80001a94:	1f6080e7          	jalr	502(ra) # 80000c86 <release>
}
    80001a98:	8526                	mv	a0,s1
    80001a9a:	60e2                	ld	ra,24(sp)
    80001a9c:	6442                	ld	s0,16(sp)
    80001a9e:	64a2                	ld	s1,8(sp)
    80001aa0:	6902                	ld	s2,0(sp)
    80001aa2:	6105                	addi	sp,sp,32
    80001aa4:	8082                	ret

0000000080001aa6 <proc_pagetable>:
{
    80001aa6:	1101                	addi	sp,sp,-32
    80001aa8:	ec06                	sd	ra,24(sp)
    80001aaa:	e822                	sd	s0,16(sp)
    80001aac:	e426                	sd	s1,8(sp)
    80001aae:	e04a                	sd	s2,0(sp)
    80001ab0:	1000                	addi	s0,sp,32
    80001ab2:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001ab4:	00000097          	auipc	ra,0x0
    80001ab8:	868080e7          	jalr	-1944(ra) # 8000131c <uvmcreate>
    80001abc:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001abe:	c121                	beqz	a0,80001afe <proc_pagetable+0x58>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001ac0:	4729                	li	a4,10
    80001ac2:	00005697          	auipc	a3,0x5
    80001ac6:	53e68693          	addi	a3,a3,1342 # 80007000 <_trampoline>
    80001aca:	6605                	lui	a2,0x1
    80001acc:	040005b7          	lui	a1,0x4000
    80001ad0:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001ad2:	05b2                	slli	a1,a1,0xc
    80001ad4:	fffff097          	auipc	ra,0xfffff
    80001ad8:	5cc080e7          	jalr	1484(ra) # 800010a0 <mappages>
    80001adc:	02054863          	bltz	a0,80001b0c <proc_pagetable+0x66>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    80001ae0:	4719                	li	a4,6
    80001ae2:	05893683          	ld	a3,88(s2)
    80001ae6:	6605                	lui	a2,0x1
    80001ae8:	020005b7          	lui	a1,0x2000
    80001aec:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001aee:	05b6                	slli	a1,a1,0xd
    80001af0:	8526                	mv	a0,s1
    80001af2:	fffff097          	auipc	ra,0xfffff
    80001af6:	5ae080e7          	jalr	1454(ra) # 800010a0 <mappages>
    80001afa:	02054163          	bltz	a0,80001b1c <proc_pagetable+0x76>
}
    80001afe:	8526                	mv	a0,s1
    80001b00:	60e2                	ld	ra,24(sp)
    80001b02:	6442                	ld	s0,16(sp)
    80001b04:	64a2                	ld	s1,8(sp)
    80001b06:	6902                	ld	s2,0(sp)
    80001b08:	6105                	addi	sp,sp,32
    80001b0a:	8082                	ret
    uvmfree(pagetable, 0);
    80001b0c:	4581                	li	a1,0
    80001b0e:	8526                	mv	a0,s1
    80001b10:	00000097          	auipc	ra,0x0
    80001b14:	a12080e7          	jalr	-1518(ra) # 80001522 <uvmfree>
    return 0;
    80001b18:	4481                	li	s1,0
    80001b1a:	b7d5                	j	80001afe <proc_pagetable+0x58>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001b1c:	4681                	li	a3,0
    80001b1e:	4605                	li	a2,1
    80001b20:	040005b7          	lui	a1,0x4000
    80001b24:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001b26:	05b2                	slli	a1,a1,0xc
    80001b28:	8526                	mv	a0,s1
    80001b2a:	fffff097          	auipc	ra,0xfffff
    80001b2e:	73c080e7          	jalr	1852(ra) # 80001266 <uvmunmap>
    uvmfree(pagetable, 0);
    80001b32:	4581                	li	a1,0
    80001b34:	8526                	mv	a0,s1
    80001b36:	00000097          	auipc	ra,0x0
    80001b3a:	9ec080e7          	jalr	-1556(ra) # 80001522 <uvmfree>
    return 0;
    80001b3e:	4481                	li	s1,0
    80001b40:	bf7d                	j	80001afe <proc_pagetable+0x58>

0000000080001b42 <proc_freepagetable>:
{
    80001b42:	1101                	addi	sp,sp,-32
    80001b44:	ec06                	sd	ra,24(sp)
    80001b46:	e822                	sd	s0,16(sp)
    80001b48:	e426                	sd	s1,8(sp)
    80001b4a:	e04a                	sd	s2,0(sp)
    80001b4c:	1000                	addi	s0,sp,32
    80001b4e:	84aa                	mv	s1,a0
    80001b50:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001b52:	4681                	li	a3,0
    80001b54:	4605                	li	a2,1
    80001b56:	040005b7          	lui	a1,0x4000
    80001b5a:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001b5c:	05b2                	slli	a1,a1,0xc
    80001b5e:	fffff097          	auipc	ra,0xfffff
    80001b62:	708080e7          	jalr	1800(ra) # 80001266 <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001b66:	4681                	li	a3,0
    80001b68:	4605                	li	a2,1
    80001b6a:	020005b7          	lui	a1,0x2000
    80001b6e:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001b70:	05b6                	slli	a1,a1,0xd
    80001b72:	8526                	mv	a0,s1
    80001b74:	fffff097          	auipc	ra,0xfffff
    80001b78:	6f2080e7          	jalr	1778(ra) # 80001266 <uvmunmap>
  uvmfree(pagetable, sz);
    80001b7c:	85ca                	mv	a1,s2
    80001b7e:	8526                	mv	a0,s1
    80001b80:	00000097          	auipc	ra,0x0
    80001b84:	9a2080e7          	jalr	-1630(ra) # 80001522 <uvmfree>
}
    80001b88:	60e2                	ld	ra,24(sp)
    80001b8a:	6442                	ld	s0,16(sp)
    80001b8c:	64a2                	ld	s1,8(sp)
    80001b8e:	6902                	ld	s2,0(sp)
    80001b90:	6105                	addi	sp,sp,32
    80001b92:	8082                	ret

0000000080001b94 <freeproc>:
{
    80001b94:	1101                	addi	sp,sp,-32
    80001b96:	ec06                	sd	ra,24(sp)
    80001b98:	e822                	sd	s0,16(sp)
    80001b9a:	e426                	sd	s1,8(sp)
    80001b9c:	1000                	addi	s0,sp,32
    80001b9e:	84aa                	mv	s1,a0
  if(p->trapframe)
    80001ba0:	6d28                	ld	a0,88(a0)
    80001ba2:	c509                	beqz	a0,80001bac <freeproc+0x18>
    kfree((void*)p->trapframe);
    80001ba4:	fffff097          	auipc	ra,0xfffff
    80001ba8:	e40080e7          	jalr	-448(ra) # 800009e4 <kfree>
  p->trapframe = 0;
    80001bac:	0404bc23          	sd	zero,88(s1)
  if(p->pagetable)
    80001bb0:	68a8                	ld	a0,80(s1)
    80001bb2:	c511                	beqz	a0,80001bbe <freeproc+0x2a>
    proc_freepagetable(p->pagetable, p->sz);
    80001bb4:	64ac                	ld	a1,72(s1)
    80001bb6:	00000097          	auipc	ra,0x0
    80001bba:	f8c080e7          	jalr	-116(ra) # 80001b42 <proc_freepagetable>
  p->pagetable = 0;
    80001bbe:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80001bc2:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80001bc6:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    80001bca:	0204bc23          	sd	zero,56(s1)
  p->name[0] = 0;
    80001bce:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80001bd2:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80001bd6:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80001bda:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    80001bde:	0004ac23          	sw	zero,24(s1)
}
    80001be2:	60e2                	ld	ra,24(sp)
    80001be4:	6442                	ld	s0,16(sp)
    80001be6:	64a2                	ld	s1,8(sp)
    80001be8:	6105                	addi	sp,sp,32
    80001bea:	8082                	ret

0000000080001bec <allocproc>:
{
    80001bec:	7179                	addi	sp,sp,-48
    80001bee:	f406                	sd	ra,40(sp)
    80001bf0:	f022                	sd	s0,32(sp)
    80001bf2:	ec26                	sd	s1,24(sp)
    80001bf4:	e84a                	sd	s2,16(sp)
    80001bf6:	e44e                	sd	s3,8(sp)
    80001bf8:	1800                	addi	s0,sp,48
  for(p = proc; p < &proc[NPROC]; p++) {
    80001bfa:	0000f497          	auipc	s1,0xf
    80001bfe:	54648493          	addi	s1,s1,1350 # 80011140 <proc>
    80001c02:	6919                	lui	s2,0x6
    80001c04:	f3890913          	addi	s2,s2,-200 # 5f38 <_entry-0x7fffa0c8>
    80001c08:	0018c997          	auipc	s3,0x18c
    80001c0c:	33898993          	addi	s3,s3,824 # 8018df40 <tickslock>
    acquire(&p->lock);
    80001c10:	8526                	mv	a0,s1
    80001c12:	fffff097          	auipc	ra,0xfffff
    80001c16:	fc0080e7          	jalr	-64(ra) # 80000bd2 <acquire>
    if(p->state == UNUSED) {
    80001c1a:	4c9c                	lw	a5,24(s1)
    80001c1c:	cb99                	beqz	a5,80001c32 <allocproc+0x46>
      release(&p->lock);
    80001c1e:	8526                	mv	a0,s1
    80001c20:	fffff097          	auipc	ra,0xfffff
    80001c24:	066080e7          	jalr	102(ra) # 80000c86 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001c28:	94ca                	add	s1,s1,s2
    80001c2a:	ff3493e3          	bne	s1,s3,80001c10 <allocproc+0x24>
  return 0;
    80001c2e:	4481                	li	s1,0
    80001c30:	a889                	j	80001c82 <allocproc+0x96>
  p->pid = allocpid();
    80001c32:	00000097          	auipc	ra,0x0
    80001c36:	e2e080e7          	jalr	-466(ra) # 80001a60 <allocpid>
    80001c3a:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001c3c:	4785                	li	a5,1
    80001c3e:	cc9c                	sw	a5,24(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    80001c40:	fffff097          	auipc	ra,0xfffff
    80001c44:	ea2080e7          	jalr	-350(ra) # 80000ae2 <kalloc>
    80001c48:	892a                	mv	s2,a0
    80001c4a:	eca8                	sd	a0,88(s1)
    80001c4c:	c139                	beqz	a0,80001c92 <allocproc+0xa6>
  p->pagetable = proc_pagetable(p);
    80001c4e:	8526                	mv	a0,s1
    80001c50:	00000097          	auipc	ra,0x0
    80001c54:	e56080e7          	jalr	-426(ra) # 80001aa6 <proc_pagetable>
    80001c58:	892a                	mv	s2,a0
    80001c5a:	e8a8                	sd	a0,80(s1)
  if(p->pagetable == 0){
    80001c5c:	c539                	beqz	a0,80001caa <allocproc+0xbe>
  memset(&p->context, 0, sizeof(p->context));
    80001c5e:	07000613          	li	a2,112
    80001c62:	4581                	li	a1,0
    80001c64:	06048513          	addi	a0,s1,96
    80001c68:	fffff097          	auipc	ra,0xfffff
    80001c6c:	066080e7          	jalr	102(ra) # 80000cce <memset>
  p->context.ra = (uint64)forkret;
    80001c70:	00000797          	auipc	a5,0x0
    80001c74:	daa78793          	addi	a5,a5,-598 # 80001a1a <forkret>
    80001c78:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001c7a:	60bc                	ld	a5,64(s1)
    80001c7c:	6705                	lui	a4,0x1
    80001c7e:	97ba                	add	a5,a5,a4
    80001c80:	f4bc                	sd	a5,104(s1)
}
    80001c82:	8526                	mv	a0,s1
    80001c84:	70a2                	ld	ra,40(sp)
    80001c86:	7402                	ld	s0,32(sp)
    80001c88:	64e2                	ld	s1,24(sp)
    80001c8a:	6942                	ld	s2,16(sp)
    80001c8c:	69a2                	ld	s3,8(sp)
    80001c8e:	6145                	addi	sp,sp,48
    80001c90:	8082                	ret
    freeproc(p);
    80001c92:	8526                	mv	a0,s1
    80001c94:	00000097          	auipc	ra,0x0
    80001c98:	f00080e7          	jalr	-256(ra) # 80001b94 <freeproc>
    release(&p->lock);
    80001c9c:	8526                	mv	a0,s1
    80001c9e:	fffff097          	auipc	ra,0xfffff
    80001ca2:	fe8080e7          	jalr	-24(ra) # 80000c86 <release>
    return 0;
    80001ca6:	84ca                	mv	s1,s2
    80001ca8:	bfe9                	j	80001c82 <allocproc+0x96>
    freeproc(p);
    80001caa:	8526                	mv	a0,s1
    80001cac:	00000097          	auipc	ra,0x0
    80001cb0:	ee8080e7          	jalr	-280(ra) # 80001b94 <freeproc>
    release(&p->lock);
    80001cb4:	8526                	mv	a0,s1
    80001cb6:	fffff097          	auipc	ra,0xfffff
    80001cba:	fd0080e7          	jalr	-48(ra) # 80000c86 <release>
    return 0;
    80001cbe:	84ca                	mv	s1,s2
    80001cc0:	b7c9                	j	80001c82 <allocproc+0x96>

0000000080001cc2 <userinit>:
{
    80001cc2:	1101                	addi	sp,sp,-32
    80001cc4:	ec06                	sd	ra,24(sp)
    80001cc6:	e822                	sd	s0,16(sp)
    80001cc8:	e426                	sd	s1,8(sp)
    80001cca:	1000                	addi	s0,sp,32
  p = allocproc();
    80001ccc:	00000097          	auipc	ra,0x0
    80001cd0:	f20080e7          	jalr	-224(ra) # 80001bec <allocproc>
    80001cd4:	84aa                	mv	s1,a0
  initproc = p;
    80001cd6:	00007797          	auipc	a5,0x7
    80001cda:	dca7b123          	sd	a0,-574(a5) # 80008a98 <initproc>
  uvmfirst(p->pagetable, initcode, sizeof(initcode));
    80001cde:	03400613          	li	a2,52
    80001ce2:	00007597          	auipc	a1,0x7
    80001ce6:	d4e58593          	addi	a1,a1,-690 # 80008a30 <initcode>
    80001cea:	6928                	ld	a0,80(a0)
    80001cec:	fffff097          	auipc	ra,0xfffff
    80001cf0:	65e080e7          	jalr	1630(ra) # 8000134a <uvmfirst>
  p->sz = PGSIZE;
    80001cf4:	6785                	lui	a5,0x1
    80001cf6:	e4bc                	sd	a5,72(s1)
  p->trapframe->epc = 0;      // user program counter
    80001cf8:	6cb8                	ld	a4,88(s1)
    80001cfa:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->trapframe->sp = PGSIZE;  // user stack pointer
    80001cfe:	6cb8                	ld	a4,88(s1)
    80001d00:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80001d02:	4641                	li	a2,16
    80001d04:	00006597          	auipc	a1,0x6
    80001d08:	4f458593          	addi	a1,a1,1268 # 800081f8 <digits+0x1b8>
    80001d0c:	15848513          	addi	a0,s1,344
    80001d10:	fffff097          	auipc	ra,0xfffff
    80001d14:	106080e7          	jalr	262(ra) # 80000e16 <safestrcpy>
  p->cwd = namei("/");
    80001d18:	00006517          	auipc	a0,0x6
    80001d1c:	4f050513          	addi	a0,a0,1264 # 80008208 <digits+0x1c8>
    80001d20:	00002097          	auipc	ra,0x2
    80001d24:	1ce080e7          	jalr	462(ra) # 80003eee <namei>
    80001d28:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001d2c:	478d                	li	a5,3
    80001d2e:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001d30:	8526                	mv	a0,s1
    80001d32:	fffff097          	auipc	ra,0xfffff
    80001d36:	f54080e7          	jalr	-172(ra) # 80000c86 <release>
}
    80001d3a:	60e2                	ld	ra,24(sp)
    80001d3c:	6442                	ld	s0,16(sp)
    80001d3e:	64a2                	ld	s1,8(sp)
    80001d40:	6105                	addi	sp,sp,32
    80001d42:	8082                	ret

0000000080001d44 <track_heap>:
  for (int i = 0; i < MAXHEAP; i++) {
    80001d44:	17050793          	addi	a5,a0,368
    80001d48:	6719                	lui	a4,0x6
    80001d4a:	f3070713          	addi	a4,a4,-208 # 5f30 <_entry-0x7fffa0d0>
    80001d4e:	953a                	add	a0,a0,a4
    if (p->heap_tracker[i].addr == 0xFFFFFFFFFFFFFFFF) {
    80001d50:	56fd                	li	a3,-1
  for (int i = 0; i < MAXHEAP; i++) {
    80001d52:	6805                	lui	a6,0x1
    80001d54:	a029                	j	80001d5e <track_heap+0x1a>
    80001d56:	07e1                	addi	a5,a5,24 # 1018 <_entry-0x7fffefe8>
    80001d58:	95c2                	add	a1,a1,a6
    80001d5a:	00a78c63          	beq	a5,a0,80001d72 <track_heap+0x2e>
    if (p->heap_tracker[i].addr == 0xFFFFFFFFFFFFFFFF) {
    80001d5e:	6398                	ld	a4,0(a5)
    80001d60:	fed71be3          	bne	a4,a3,80001d56 <track_heap+0x12>
      p->heap_tracker[i].addr           = start + (i*PGSIZE);
    80001d64:	e38c                	sd	a1,0(a5)
      p->heap_tracker[i].loaded         = 0;   
    80001d66:	00078823          	sb	zero,16(a5)
      p->heap_tracker[i].startblock     = -1;
    80001d6a:	cbd4                	sw	a3,20(a5)
      npages--;
    80001d6c:	367d                	addiw	a2,a2,-1 # fff <_entry-0x7ffff001>
      if (npages == 0) return;
    80001d6e:	f665                	bnez	a2,80001d56 <track_heap+0x12>
    80001d70:	8082                	ret
void track_heap(struct proc* p, uint64 start, int npages) {
    80001d72:	1141                	addi	sp,sp,-16
    80001d74:	e406                	sd	ra,8(sp)
    80001d76:	e022                	sd	s0,0(sp)
    80001d78:	0800                	addi	s0,sp,16
  panic("Error: No more process heap pages allowed.\n");
    80001d7a:	00006517          	auipc	a0,0x6
    80001d7e:	49650513          	addi	a0,a0,1174 # 80008210 <digits+0x1d0>
    80001d82:	ffffe097          	auipc	ra,0xffffe
    80001d86:	7ba080e7          	jalr	1978(ra) # 8000053c <panic>

0000000080001d8a <growproc>:
{
    80001d8a:	1101                	addi	sp,sp,-32
    80001d8c:	ec06                	sd	ra,24(sp)
    80001d8e:	e822                	sd	s0,16(sp)
    80001d90:	e426                	sd	s1,8(sp)
    80001d92:	e04a                	sd	s2,0(sp)
    80001d94:	1000                	addi	s0,sp,32
    80001d96:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80001d98:	00000097          	auipc	ra,0x0
    80001d9c:	c4a080e7          	jalr	-950(ra) # 800019e2 <myproc>
    80001da0:	892a                	mv	s2,a0
  n = PGROUNDUP(n);
    80001da2:	6605                	lui	a2,0x1
    80001da4:	367d                	addiw	a2,a2,-1 # fff <_entry-0x7ffff001>
    80001da6:	9e25                	addw	a2,a2,s1
    80001da8:	77fd                	lui	a5,0xfffff
    80001daa:	8e7d                	and	a2,a2,a5
  sz = p->sz;
    80001dac:	652c                	ld	a1,72(a0)
  if(p->ondemand && n>0){
    80001dae:	16854783          	lbu	a5,360(a0)
    80001db2:	cf95                	beqz	a5,80001dee <growproc+0x64>
    80001db4:	02c05f63          	blez	a2,80001df2 <growproc+0x68>
    for(uint64 a = sz, i=0; a <  sz + n; a += PGSIZE, i++){
    80001db8:	00b604b3          	add	s1,a2,a1
    80001dbc:	0095fb63          	bgeu	a1,s1,80001dd2 <growproc+0x48>
    80001dc0:	17050713          	addi	a4,a0,368
    80001dc4:	87ae                	mv	a5,a1
    80001dc6:	6685                	lui	a3,0x1
      p->heap_tracker[i].addr =  a;
    80001dc8:	e31c                	sd	a5,0(a4)
    for(uint64 a = sz, i=0; a <  sz + n; a += PGSIZE, i++){
    80001dca:	97b6                	add	a5,a5,a3
    80001dcc:	0761                	addi	a4,a4,24
    80001dce:	fe97ede3          	bltu	a5,s1,80001dc8 <growproc+0x3e>
    print_skip_heap_region(p->name,sz,p->resident_heap_pages);
    80001dd2:	6799                	lui	a5,0x6
    80001dd4:	97ca                	add	a5,a5,s2
    80001dd6:	f307a603          	lw	a2,-208(a5) # 5f30 <_entry-0x7fffa0d0>
    80001dda:	15890513          	addi	a0,s2,344
    80001dde:	00005097          	auipc	ra,0x5
    80001de2:	928080e7          	jalr	-1752(ra) # 80006706 <print_skip_heap_region>
    p->sz =  sz + n;
    80001de6:	04993423          	sd	s1,72(s2)
    return 0;
    80001dea:	4501                	li	a0,0
    80001dec:	a801                	j	80001dfc <growproc+0x72>
  }else if(n > 0){
    80001dee:	00c04d63          	bgtz	a2,80001e08 <growproc+0x7e>
  } else if(n < 0){
    80001df2:	02064663          	bltz	a2,80001e1e <growproc+0x94>
  p->sz = sz;
    80001df6:	04b93423          	sd	a1,72(s2)
  return 0;
    80001dfa:	4501                	li	a0,0
}
    80001dfc:	60e2                	ld	ra,24(sp)
    80001dfe:	6442                	ld	s0,16(sp)
    80001e00:	64a2                	ld	s1,8(sp)
    80001e02:	6902                	ld	s2,0(sp)
    80001e04:	6105                	addi	sp,sp,32
    80001e06:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0) {
    80001e08:	4691                	li	a3,4
    80001e0a:	962e                	add	a2,a2,a1
    80001e0c:	6928                	ld	a0,80(a0)
    80001e0e:	fffff097          	auipc	ra,0xfffff
    80001e12:	5f6080e7          	jalr	1526(ra) # 80001404 <uvmalloc>
    80001e16:	85aa                	mv	a1,a0
    80001e18:	fd79                	bnez	a0,80001df6 <growproc+0x6c>
      return -1;
    80001e1a:	557d                	li	a0,-1
    80001e1c:	b7c5                	j	80001dfc <growproc+0x72>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001e1e:	962e                	add	a2,a2,a1
    80001e20:	05093503          	ld	a0,80(s2)
    80001e24:	fffff097          	auipc	ra,0xfffff
    80001e28:	598080e7          	jalr	1432(ra) # 800013bc <uvmdealloc>
    80001e2c:	85aa                	mv	a1,a0
    80001e2e:	b7e1                	j	80001df6 <growproc+0x6c>

0000000080001e30 <fork>:
{
    80001e30:	7139                	addi	sp,sp,-64
    80001e32:	fc06                	sd	ra,56(sp)
    80001e34:	f822                	sd	s0,48(sp)
    80001e36:	f426                	sd	s1,40(sp)
    80001e38:	f04a                	sd	s2,32(sp)
    80001e3a:	ec4e                	sd	s3,24(sp)
    80001e3c:	e852                	sd	s4,16(sp)
    80001e3e:	e456                	sd	s5,8(sp)
    80001e40:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80001e42:	00000097          	auipc	ra,0x0
    80001e46:	ba0080e7          	jalr	-1120(ra) # 800019e2 <myproc>
    80001e4a:	8aaa                	mv	s5,a0
  if((np = allocproc()) == 0){
    80001e4c:	00000097          	auipc	ra,0x0
    80001e50:	da0080e7          	jalr	-608(ra) # 80001bec <allocproc>
    80001e54:	12050063          	beqz	a0,80001f74 <fork+0x144>
    80001e58:	89aa                	mv	s3,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80001e5a:	048ab603          	ld	a2,72(s5)
    80001e5e:	692c                	ld	a1,80(a0)
    80001e60:	050ab503          	ld	a0,80(s5)
    80001e64:	fffff097          	auipc	ra,0xfffff
    80001e68:	6f8080e7          	jalr	1784(ra) # 8000155c <uvmcopy>
    80001e6c:	04054863          	bltz	a0,80001ebc <fork+0x8c>
  np->sz = p->sz;
    80001e70:	048ab783          	ld	a5,72(s5)
    80001e74:	04f9b423          	sd	a5,72(s3)
  *(np->trapframe) = *(p->trapframe);
    80001e78:	058ab683          	ld	a3,88(s5)
    80001e7c:	87b6                	mv	a5,a3
    80001e7e:	0589b703          	ld	a4,88(s3)
    80001e82:	12068693          	addi	a3,a3,288 # 1120 <_entry-0x7fffeee0>
    80001e86:	0007b803          	ld	a6,0(a5)
    80001e8a:	6788                	ld	a0,8(a5)
    80001e8c:	6b8c                	ld	a1,16(a5)
    80001e8e:	6f90                	ld	a2,24(a5)
    80001e90:	01073023          	sd	a6,0(a4)
    80001e94:	e708                	sd	a0,8(a4)
    80001e96:	eb0c                	sd	a1,16(a4)
    80001e98:	ef10                	sd	a2,24(a4)
    80001e9a:	02078793          	addi	a5,a5,32
    80001e9e:	02070713          	addi	a4,a4,32
    80001ea2:	fed792e3          	bne	a5,a3,80001e86 <fork+0x56>
  np->trapframe->a0 = 0;
    80001ea6:	0589b783          	ld	a5,88(s3)
    80001eaa:	0607b823          	sd	zero,112(a5)
  for(i = 0; i < NOFILE; i++)
    80001eae:	0d0a8493          	addi	s1,s5,208
    80001eb2:	0d098913          	addi	s2,s3,208
    80001eb6:	150a8a13          	addi	s4,s5,336
    80001eba:	a00d                	j	80001edc <fork+0xac>
    freeproc(np);
    80001ebc:	854e                	mv	a0,s3
    80001ebe:	00000097          	auipc	ra,0x0
    80001ec2:	cd6080e7          	jalr	-810(ra) # 80001b94 <freeproc>
    release(&np->lock);
    80001ec6:	854e                	mv	a0,s3
    80001ec8:	fffff097          	auipc	ra,0xfffff
    80001ecc:	dbe080e7          	jalr	-578(ra) # 80000c86 <release>
    return -1;
    80001ed0:	597d                	li	s2,-1
    80001ed2:	a079                	j	80001f60 <fork+0x130>
  for(i = 0; i < NOFILE; i++)
    80001ed4:	04a1                	addi	s1,s1,8
    80001ed6:	0921                	addi	s2,s2,8
    80001ed8:	01448b63          	beq	s1,s4,80001eee <fork+0xbe>
    if(p->ofile[i])
    80001edc:	6088                	ld	a0,0(s1)
    80001ede:	d97d                	beqz	a0,80001ed4 <fork+0xa4>
      np->ofile[i] = filedup(p->ofile[i]);
    80001ee0:	00002097          	auipc	ra,0x2
    80001ee4:	680080e7          	jalr	1664(ra) # 80004560 <filedup>
    80001ee8:	00a93023          	sd	a0,0(s2)
    80001eec:	b7e5                	j	80001ed4 <fork+0xa4>
  np->cwd = idup(p->cwd);
    80001eee:	150ab503          	ld	a0,336(s5)
    80001ef2:	00002097          	auipc	ra,0x2
    80001ef6:	818080e7          	jalr	-2024(ra) # 8000370a <idup>
    80001efa:	14a9b823          	sd	a0,336(s3)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001efe:	4641                	li	a2,16
    80001f00:	158a8593          	addi	a1,s5,344
    80001f04:	15898513          	addi	a0,s3,344
    80001f08:	fffff097          	auipc	ra,0xfffff
    80001f0c:	f0e080e7          	jalr	-242(ra) # 80000e16 <safestrcpy>
  np->ondemand = p->ondemand;
    80001f10:	168ac783          	lbu	a5,360(s5)
    80001f14:	16f98423          	sb	a5,360(s3)
  pid = np->pid;
    80001f18:	0309a903          	lw	s2,48(s3)
  release(&np->lock);
    80001f1c:	854e                	mv	a0,s3
    80001f1e:	fffff097          	auipc	ra,0xfffff
    80001f22:	d68080e7          	jalr	-664(ra) # 80000c86 <release>
  acquire(&wait_lock);
    80001f26:	0000f497          	auipc	s1,0xf
    80001f2a:	e0248493          	addi	s1,s1,-510 # 80010d28 <wait_lock>
    80001f2e:	8526                	mv	a0,s1
    80001f30:	fffff097          	auipc	ra,0xfffff
    80001f34:	ca2080e7          	jalr	-862(ra) # 80000bd2 <acquire>
  np->parent = p;
    80001f38:	0359bc23          	sd	s5,56(s3)
  release(&wait_lock);
    80001f3c:	8526                	mv	a0,s1
    80001f3e:	fffff097          	auipc	ra,0xfffff
    80001f42:	d48080e7          	jalr	-696(ra) # 80000c86 <release>
  acquire(&np->lock);
    80001f46:	854e                	mv	a0,s3
    80001f48:	fffff097          	auipc	ra,0xfffff
    80001f4c:	c8a080e7          	jalr	-886(ra) # 80000bd2 <acquire>
  np->state = RUNNABLE;
    80001f50:	478d                	li	a5,3
    80001f52:	00f9ac23          	sw	a5,24(s3)
  release(&np->lock);
    80001f56:	854e                	mv	a0,s3
    80001f58:	fffff097          	auipc	ra,0xfffff
    80001f5c:	d2e080e7          	jalr	-722(ra) # 80000c86 <release>
}
    80001f60:	854a                	mv	a0,s2
    80001f62:	70e2                	ld	ra,56(sp)
    80001f64:	7442                	ld	s0,48(sp)
    80001f66:	74a2                	ld	s1,40(sp)
    80001f68:	7902                	ld	s2,32(sp)
    80001f6a:	69e2                	ld	s3,24(sp)
    80001f6c:	6a42                	ld	s4,16(sp)
    80001f6e:	6aa2                	ld	s5,8(sp)
    80001f70:	6121                	addi	sp,sp,64
    80001f72:	8082                	ret
    return -1;
    80001f74:	597d                	li	s2,-1
    80001f76:	b7ed                	j	80001f60 <fork+0x130>

0000000080001f78 <scheduler>:
{
    80001f78:	715d                	addi	sp,sp,-80
    80001f7a:	e486                	sd	ra,72(sp)
    80001f7c:	e0a2                	sd	s0,64(sp)
    80001f7e:	fc26                	sd	s1,56(sp)
    80001f80:	f84a                	sd	s2,48(sp)
    80001f82:	f44e                	sd	s3,40(sp)
    80001f84:	f052                	sd	s4,32(sp)
    80001f86:	ec56                	sd	s5,24(sp)
    80001f88:	e85a                	sd	s6,16(sp)
    80001f8a:	e45e                	sd	s7,8(sp)
    80001f8c:	0880                	addi	s0,sp,80
    80001f8e:	8792                	mv	a5,tp
  int id = r_tp();
    80001f90:	2781                	sext.w	a5,a5
  c->proc = 0;
    80001f92:	00779b13          	slli	s6,a5,0x7
    80001f96:	0000f717          	auipc	a4,0xf
    80001f9a:	d7a70713          	addi	a4,a4,-646 # 80010d10 <pid_lock>
    80001f9e:	975a                	add	a4,a4,s6
    80001fa0:	02073823          	sd	zero,48(a4)
        swtch(&c->context, &p->context);
    80001fa4:	0000f717          	auipc	a4,0xf
    80001fa8:	da470713          	addi	a4,a4,-604 # 80010d48 <cpus+0x8>
    80001fac:	9b3a                	add	s6,s6,a4
        p->state = RUNNING;
    80001fae:	4b91                	li	s7,4
        c->proc = p;
    80001fb0:	079e                	slli	a5,a5,0x7
    80001fb2:	0000fa97          	auipc	s5,0xf
    80001fb6:	d5ea8a93          	addi	s5,s5,-674 # 80010d10 <pid_lock>
    80001fba:	9abe                	add	s5,s5,a5
    for(p = proc; p < &proc[NPROC]; p++) {
    80001fbc:	6999                	lui	s3,0x6
    80001fbe:	f3898993          	addi	s3,s3,-200 # 5f38 <_entry-0x7fffa0c8>
    80001fc2:	0018ca17          	auipc	s4,0x18c
    80001fc6:	f7ea0a13          	addi	s4,s4,-130 # 8018df40 <tickslock>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001fca:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001fce:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001fd2:	10079073          	csrw	sstatus,a5
    80001fd6:	0000f497          	auipc	s1,0xf
    80001fda:	16a48493          	addi	s1,s1,362 # 80011140 <proc>
      if(p->state == RUNNABLE) {
    80001fde:	490d                	li	s2,3
    80001fe0:	a809                	j	80001ff2 <scheduler+0x7a>
      release(&p->lock);
    80001fe2:	8526                	mv	a0,s1
    80001fe4:	fffff097          	auipc	ra,0xfffff
    80001fe8:	ca2080e7          	jalr	-862(ra) # 80000c86 <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    80001fec:	94ce                	add	s1,s1,s3
    80001fee:	fd448ee3          	beq	s1,s4,80001fca <scheduler+0x52>
      acquire(&p->lock);
    80001ff2:	8526                	mv	a0,s1
    80001ff4:	fffff097          	auipc	ra,0xfffff
    80001ff8:	bde080e7          	jalr	-1058(ra) # 80000bd2 <acquire>
      if(p->state == RUNNABLE) {
    80001ffc:	4c9c                	lw	a5,24(s1)
    80001ffe:	ff2792e3          	bne	a5,s2,80001fe2 <scheduler+0x6a>
        p->state = RUNNING;
    80002002:	0174ac23          	sw	s7,24(s1)
        c->proc = p;
    80002006:	029ab823          	sd	s1,48(s5)
        swtch(&c->context, &p->context);
    8000200a:	06048593          	addi	a1,s1,96
    8000200e:	855a                	mv	a0,s6
    80002010:	00000097          	auipc	ra,0x0
    80002014:	6a0080e7          	jalr	1696(ra) # 800026b0 <swtch>
        c->proc = 0;
    80002018:	020ab823          	sd	zero,48(s5)
    8000201c:	b7d9                	j	80001fe2 <scheduler+0x6a>

000000008000201e <sched>:
{
    8000201e:	7179                	addi	sp,sp,-48
    80002020:	f406                	sd	ra,40(sp)
    80002022:	f022                	sd	s0,32(sp)
    80002024:	ec26                	sd	s1,24(sp)
    80002026:	e84a                	sd	s2,16(sp)
    80002028:	e44e                	sd	s3,8(sp)
    8000202a:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    8000202c:	00000097          	auipc	ra,0x0
    80002030:	9b6080e7          	jalr	-1610(ra) # 800019e2 <myproc>
    80002034:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    80002036:	fffff097          	auipc	ra,0xfffff
    8000203a:	b22080e7          	jalr	-1246(ra) # 80000b58 <holding>
    8000203e:	c93d                	beqz	a0,800020b4 <sched+0x96>
  asm volatile("mv %0, tp" : "=r" (x) );
    80002040:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    80002042:	2781                	sext.w	a5,a5
    80002044:	079e                	slli	a5,a5,0x7
    80002046:	0000f717          	auipc	a4,0xf
    8000204a:	cca70713          	addi	a4,a4,-822 # 80010d10 <pid_lock>
    8000204e:	97ba                	add	a5,a5,a4
    80002050:	0a87a703          	lw	a4,168(a5)
    80002054:	4785                	li	a5,1
    80002056:	06f71763          	bne	a4,a5,800020c4 <sched+0xa6>
  if(p->state == RUNNING)
    8000205a:	4c98                	lw	a4,24(s1)
    8000205c:	4791                	li	a5,4
    8000205e:	06f70b63          	beq	a4,a5,800020d4 <sched+0xb6>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002062:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002066:	8b89                	andi	a5,a5,2
  if(intr_get())
    80002068:	efb5                	bnez	a5,800020e4 <sched+0xc6>
  asm volatile("mv %0, tp" : "=r" (x) );
    8000206a:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    8000206c:	0000f917          	auipc	s2,0xf
    80002070:	ca490913          	addi	s2,s2,-860 # 80010d10 <pid_lock>
    80002074:	2781                	sext.w	a5,a5
    80002076:	079e                	slli	a5,a5,0x7
    80002078:	97ca                	add	a5,a5,s2
    8000207a:	0ac7a983          	lw	s3,172(a5)
    8000207e:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    80002080:	2781                	sext.w	a5,a5
    80002082:	079e                	slli	a5,a5,0x7
    80002084:	0000f597          	auipc	a1,0xf
    80002088:	cc458593          	addi	a1,a1,-828 # 80010d48 <cpus+0x8>
    8000208c:	95be                	add	a1,a1,a5
    8000208e:	06048513          	addi	a0,s1,96
    80002092:	00000097          	auipc	ra,0x0
    80002096:	61e080e7          	jalr	1566(ra) # 800026b0 <swtch>
    8000209a:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    8000209c:	2781                	sext.w	a5,a5
    8000209e:	079e                	slli	a5,a5,0x7
    800020a0:	993e                	add	s2,s2,a5
    800020a2:	0b392623          	sw	s3,172(s2)
}
    800020a6:	70a2                	ld	ra,40(sp)
    800020a8:	7402                	ld	s0,32(sp)
    800020aa:	64e2                	ld	s1,24(sp)
    800020ac:	6942                	ld	s2,16(sp)
    800020ae:	69a2                	ld	s3,8(sp)
    800020b0:	6145                	addi	sp,sp,48
    800020b2:	8082                	ret
    panic("sched p->lock");
    800020b4:	00006517          	auipc	a0,0x6
    800020b8:	18c50513          	addi	a0,a0,396 # 80008240 <digits+0x200>
    800020bc:	ffffe097          	auipc	ra,0xffffe
    800020c0:	480080e7          	jalr	1152(ra) # 8000053c <panic>
    panic("sched locks");
    800020c4:	00006517          	auipc	a0,0x6
    800020c8:	18c50513          	addi	a0,a0,396 # 80008250 <digits+0x210>
    800020cc:	ffffe097          	auipc	ra,0xffffe
    800020d0:	470080e7          	jalr	1136(ra) # 8000053c <panic>
    panic("sched running");
    800020d4:	00006517          	auipc	a0,0x6
    800020d8:	18c50513          	addi	a0,a0,396 # 80008260 <digits+0x220>
    800020dc:	ffffe097          	auipc	ra,0xffffe
    800020e0:	460080e7          	jalr	1120(ra) # 8000053c <panic>
    panic("sched interruptible");
    800020e4:	00006517          	auipc	a0,0x6
    800020e8:	18c50513          	addi	a0,a0,396 # 80008270 <digits+0x230>
    800020ec:	ffffe097          	auipc	ra,0xffffe
    800020f0:	450080e7          	jalr	1104(ra) # 8000053c <panic>

00000000800020f4 <yield>:
{
    800020f4:	1101                	addi	sp,sp,-32
    800020f6:	ec06                	sd	ra,24(sp)
    800020f8:	e822                	sd	s0,16(sp)
    800020fa:	e426                	sd	s1,8(sp)
    800020fc:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    800020fe:	00000097          	auipc	ra,0x0
    80002102:	8e4080e7          	jalr	-1820(ra) # 800019e2 <myproc>
    80002106:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80002108:	fffff097          	auipc	ra,0xfffff
    8000210c:	aca080e7          	jalr	-1334(ra) # 80000bd2 <acquire>
  p->state = RUNNABLE;
    80002110:	478d                	li	a5,3
    80002112:	cc9c                	sw	a5,24(s1)
  sched();
    80002114:	00000097          	auipc	ra,0x0
    80002118:	f0a080e7          	jalr	-246(ra) # 8000201e <sched>
  release(&p->lock);
    8000211c:	8526                	mv	a0,s1
    8000211e:	fffff097          	auipc	ra,0xfffff
    80002122:	b68080e7          	jalr	-1176(ra) # 80000c86 <release>
}
    80002126:	60e2                	ld	ra,24(sp)
    80002128:	6442                	ld	s0,16(sp)
    8000212a:	64a2                	ld	s1,8(sp)
    8000212c:	6105                	addi	sp,sp,32
    8000212e:	8082                	ret

0000000080002130 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    80002130:	7179                	addi	sp,sp,-48
    80002132:	f406                	sd	ra,40(sp)
    80002134:	f022                	sd	s0,32(sp)
    80002136:	ec26                	sd	s1,24(sp)
    80002138:	e84a                	sd	s2,16(sp)
    8000213a:	e44e                	sd	s3,8(sp)
    8000213c:	1800                	addi	s0,sp,48
    8000213e:	89aa                	mv	s3,a0
    80002140:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002142:	00000097          	auipc	ra,0x0
    80002146:	8a0080e7          	jalr	-1888(ra) # 800019e2 <myproc>
    8000214a:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
    8000214c:	fffff097          	auipc	ra,0xfffff
    80002150:	a86080e7          	jalr	-1402(ra) # 80000bd2 <acquire>
  release(lk);
    80002154:	854a                	mv	a0,s2
    80002156:	fffff097          	auipc	ra,0xfffff
    8000215a:	b30080e7          	jalr	-1232(ra) # 80000c86 <release>

  // Go to sleep.
  p->chan = chan;
    8000215e:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    80002162:	4789                	li	a5,2
    80002164:	cc9c                	sw	a5,24(s1)

  /* Adil: sleeping. */
  // printf("Sleeping and yielding CPU.");

  sched();
    80002166:	00000097          	auipc	ra,0x0
    8000216a:	eb8080e7          	jalr	-328(ra) # 8000201e <sched>

  // Tidy up.
  p->chan = 0;
    8000216e:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    80002172:	8526                	mv	a0,s1
    80002174:	fffff097          	auipc	ra,0xfffff
    80002178:	b12080e7          	jalr	-1262(ra) # 80000c86 <release>
  acquire(lk);
    8000217c:	854a                	mv	a0,s2
    8000217e:	fffff097          	auipc	ra,0xfffff
    80002182:	a54080e7          	jalr	-1452(ra) # 80000bd2 <acquire>
}
    80002186:	70a2                	ld	ra,40(sp)
    80002188:	7402                	ld	s0,32(sp)
    8000218a:	64e2                	ld	s1,24(sp)
    8000218c:	6942                	ld	s2,16(sp)
    8000218e:	69a2                	ld	s3,8(sp)
    80002190:	6145                	addi	sp,sp,48
    80002192:	8082                	ret

0000000080002194 <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void
wakeup(void *chan)
{
    80002194:	7139                	addi	sp,sp,-64
    80002196:	fc06                	sd	ra,56(sp)
    80002198:	f822                	sd	s0,48(sp)
    8000219a:	f426                	sd	s1,40(sp)
    8000219c:	f04a                	sd	s2,32(sp)
    8000219e:	ec4e                	sd	s3,24(sp)
    800021a0:	e852                	sd	s4,16(sp)
    800021a2:	e456                	sd	s5,8(sp)
    800021a4:	e05a                	sd	s6,0(sp)
    800021a6:	0080                	addi	s0,sp,64
    800021a8:	8aaa                	mv	s5,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    800021aa:	0000f497          	auipc	s1,0xf
    800021ae:	f9648493          	addi	s1,s1,-106 # 80011140 <proc>
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
    800021b2:	4a09                	li	s4,2
        p->state = RUNNABLE;
    800021b4:	4b0d                	li	s6,3
  for(p = proc; p < &proc[NPROC]; p++) {
    800021b6:	6919                	lui	s2,0x6
    800021b8:	f3890913          	addi	s2,s2,-200 # 5f38 <_entry-0x7fffa0c8>
    800021bc:	0018c997          	auipc	s3,0x18c
    800021c0:	d8498993          	addi	s3,s3,-636 # 8018df40 <tickslock>
    800021c4:	a809                	j	800021d6 <wakeup+0x42>
      }
      release(&p->lock);
    800021c6:	8526                	mv	a0,s1
    800021c8:	fffff097          	auipc	ra,0xfffff
    800021cc:	abe080e7          	jalr	-1346(ra) # 80000c86 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    800021d0:	94ca                	add	s1,s1,s2
    800021d2:	03348663          	beq	s1,s3,800021fe <wakeup+0x6a>
    if(p != myproc()){
    800021d6:	00000097          	auipc	ra,0x0
    800021da:	80c080e7          	jalr	-2036(ra) # 800019e2 <myproc>
    800021de:	fea489e3          	beq	s1,a0,800021d0 <wakeup+0x3c>
      acquire(&p->lock);
    800021e2:	8526                	mv	a0,s1
    800021e4:	fffff097          	auipc	ra,0xfffff
    800021e8:	9ee080e7          	jalr	-1554(ra) # 80000bd2 <acquire>
      if(p->state == SLEEPING && p->chan == chan) {
    800021ec:	4c9c                	lw	a5,24(s1)
    800021ee:	fd479ce3          	bne	a5,s4,800021c6 <wakeup+0x32>
    800021f2:	709c                	ld	a5,32(s1)
    800021f4:	fd5799e3          	bne	a5,s5,800021c6 <wakeup+0x32>
        p->state = RUNNABLE;
    800021f8:	0164ac23          	sw	s6,24(s1)
    800021fc:	b7e9                	j	800021c6 <wakeup+0x32>
    }
  }
}
    800021fe:	70e2                	ld	ra,56(sp)
    80002200:	7442                	ld	s0,48(sp)
    80002202:	74a2                	ld	s1,40(sp)
    80002204:	7902                	ld	s2,32(sp)
    80002206:	69e2                	ld	s3,24(sp)
    80002208:	6a42                	ld	s4,16(sp)
    8000220a:	6aa2                	ld	s5,8(sp)
    8000220c:	6b02                	ld	s6,0(sp)
    8000220e:	6121                	addi	sp,sp,64
    80002210:	8082                	ret

0000000080002212 <reparent>:
{
    80002212:	7139                	addi	sp,sp,-64
    80002214:	fc06                	sd	ra,56(sp)
    80002216:	f822                	sd	s0,48(sp)
    80002218:	f426                	sd	s1,40(sp)
    8000221a:	f04a                	sd	s2,32(sp)
    8000221c:	ec4e                	sd	s3,24(sp)
    8000221e:	e852                	sd	s4,16(sp)
    80002220:	e456                	sd	s5,8(sp)
    80002222:	0080                	addi	s0,sp,64
    80002224:	89aa                	mv	s3,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80002226:	0000f497          	auipc	s1,0xf
    8000222a:	f1a48493          	addi	s1,s1,-230 # 80011140 <proc>
      pp->parent = initproc;
    8000222e:	00007a97          	auipc	s5,0x7
    80002232:	86aa8a93          	addi	s5,s5,-1942 # 80008a98 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80002236:	6919                	lui	s2,0x6
    80002238:	f3890913          	addi	s2,s2,-200 # 5f38 <_entry-0x7fffa0c8>
    8000223c:	0018ca17          	auipc	s4,0x18c
    80002240:	d04a0a13          	addi	s4,s4,-764 # 8018df40 <tickslock>
    80002244:	a021                	j	8000224c <reparent+0x3a>
    80002246:	94ca                	add	s1,s1,s2
    80002248:	01448d63          	beq	s1,s4,80002262 <reparent+0x50>
    if(pp->parent == p){
    8000224c:	7c9c                	ld	a5,56(s1)
    8000224e:	ff379ce3          	bne	a5,s3,80002246 <reparent+0x34>
      pp->parent = initproc;
    80002252:	000ab503          	ld	a0,0(s5)
    80002256:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    80002258:	00000097          	auipc	ra,0x0
    8000225c:	f3c080e7          	jalr	-196(ra) # 80002194 <wakeup>
    80002260:	b7dd                	j	80002246 <reparent+0x34>
}
    80002262:	70e2                	ld	ra,56(sp)
    80002264:	7442                	ld	s0,48(sp)
    80002266:	74a2                	ld	s1,40(sp)
    80002268:	7902                	ld	s2,32(sp)
    8000226a:	69e2                	ld	s3,24(sp)
    8000226c:	6a42                	ld	s4,16(sp)
    8000226e:	6aa2                	ld	s5,8(sp)
    80002270:	6121                	addi	sp,sp,64
    80002272:	8082                	ret

0000000080002274 <exit>:
{
    80002274:	7179                	addi	sp,sp,-48
    80002276:	f406                	sd	ra,40(sp)
    80002278:	f022                	sd	s0,32(sp)
    8000227a:	ec26                	sd	s1,24(sp)
    8000227c:	e84a                	sd	s2,16(sp)
    8000227e:	e44e                	sd	s3,8(sp)
    80002280:	e052                	sd	s4,0(sp)
    80002282:	1800                	addi	s0,sp,48
    80002284:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    80002286:	fffff097          	auipc	ra,0xfffff
    8000228a:	75c080e7          	jalr	1884(ra) # 800019e2 <myproc>
    8000228e:	89aa                	mv	s3,a0
  if(p == initproc)
    80002290:	00007797          	auipc	a5,0x7
    80002294:	8087b783          	ld	a5,-2040(a5) # 80008a98 <initproc>
    80002298:	0d050493          	addi	s1,a0,208
    8000229c:	15050913          	addi	s2,a0,336
    800022a0:	02a79363          	bne	a5,a0,800022c6 <exit+0x52>
    panic("init exiting");
    800022a4:	00006517          	auipc	a0,0x6
    800022a8:	fe450513          	addi	a0,a0,-28 # 80008288 <digits+0x248>
    800022ac:	ffffe097          	auipc	ra,0xffffe
    800022b0:	290080e7          	jalr	656(ra) # 8000053c <panic>
      fileclose(f);
    800022b4:	00002097          	auipc	ra,0x2
    800022b8:	2fe080e7          	jalr	766(ra) # 800045b2 <fileclose>
      p->ofile[fd] = 0;
    800022bc:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    800022c0:	04a1                	addi	s1,s1,8
    800022c2:	01248563          	beq	s1,s2,800022cc <exit+0x58>
    if(p->ofile[fd]){
    800022c6:	6088                	ld	a0,0(s1)
    800022c8:	f575                	bnez	a0,800022b4 <exit+0x40>
    800022ca:	bfdd                	j	800022c0 <exit+0x4c>
  begin_op();
    800022cc:	00002097          	auipc	ra,0x2
    800022d0:	e22080e7          	jalr	-478(ra) # 800040ee <begin_op>
  iput(p->cwd);
    800022d4:	1509b503          	ld	a0,336(s3)
    800022d8:	00001097          	auipc	ra,0x1
    800022dc:	62a080e7          	jalr	1578(ra) # 80003902 <iput>
  end_op();
    800022e0:	00002097          	auipc	ra,0x2
    800022e4:	e88080e7          	jalr	-376(ra) # 80004168 <end_op>
  p->cwd = 0;
    800022e8:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    800022ec:	0000f497          	auipc	s1,0xf
    800022f0:	a3c48493          	addi	s1,s1,-1476 # 80010d28 <wait_lock>
    800022f4:	8526                	mv	a0,s1
    800022f6:	fffff097          	auipc	ra,0xfffff
    800022fa:	8dc080e7          	jalr	-1828(ra) # 80000bd2 <acquire>
  reparent(p);
    800022fe:	854e                	mv	a0,s3
    80002300:	00000097          	auipc	ra,0x0
    80002304:	f12080e7          	jalr	-238(ra) # 80002212 <reparent>
  wakeup(p->parent);
    80002308:	0389b503          	ld	a0,56(s3)
    8000230c:	00000097          	auipc	ra,0x0
    80002310:	e88080e7          	jalr	-376(ra) # 80002194 <wakeup>
  acquire(&p->lock);
    80002314:	854e                	mv	a0,s3
    80002316:	fffff097          	auipc	ra,0xfffff
    8000231a:	8bc080e7          	jalr	-1860(ra) # 80000bd2 <acquire>
  p->xstate = status;
    8000231e:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    80002322:	4795                	li	a5,5
    80002324:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    80002328:	8526                	mv	a0,s1
    8000232a:	fffff097          	auipc	ra,0xfffff
    8000232e:	95c080e7          	jalr	-1700(ra) # 80000c86 <release>
  sched();
    80002332:	00000097          	auipc	ra,0x0
    80002336:	cec080e7          	jalr	-788(ra) # 8000201e <sched>
  panic("zombie exit");
    8000233a:	00006517          	auipc	a0,0x6
    8000233e:	f5e50513          	addi	a0,a0,-162 # 80008298 <digits+0x258>
    80002342:	ffffe097          	auipc	ra,0xffffe
    80002346:	1fa080e7          	jalr	506(ra) # 8000053c <panic>

000000008000234a <kill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
    8000234a:	7179                	addi	sp,sp,-48
    8000234c:	f406                	sd	ra,40(sp)
    8000234e:	f022                	sd	s0,32(sp)
    80002350:	ec26                	sd	s1,24(sp)
    80002352:	e84a                	sd	s2,16(sp)
    80002354:	e44e                	sd	s3,8(sp)
    80002356:	e052                	sd	s4,0(sp)
    80002358:	1800                	addi	s0,sp,48
    8000235a:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    8000235c:	0000f497          	auipc	s1,0xf
    80002360:	de448493          	addi	s1,s1,-540 # 80011140 <proc>
    80002364:	6999                	lui	s3,0x6
    80002366:	f3898993          	addi	s3,s3,-200 # 5f38 <_entry-0x7fffa0c8>
    8000236a:	0018ca17          	auipc	s4,0x18c
    8000236e:	bd6a0a13          	addi	s4,s4,-1066 # 8018df40 <tickslock>
    acquire(&p->lock);
    80002372:	8526                	mv	a0,s1
    80002374:	fffff097          	auipc	ra,0xfffff
    80002378:	85e080e7          	jalr	-1954(ra) # 80000bd2 <acquire>
    if(p->pid == pid){
    8000237c:	589c                	lw	a5,48(s1)
    8000237e:	01278c63          	beq	a5,s2,80002396 <kill+0x4c>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    80002382:	8526                	mv	a0,s1
    80002384:	fffff097          	auipc	ra,0xfffff
    80002388:	902080e7          	jalr	-1790(ra) # 80000c86 <release>
  for(p = proc; p < &proc[NPROC]; p++){
    8000238c:	94ce                	add	s1,s1,s3
    8000238e:	ff4492e3          	bne	s1,s4,80002372 <kill+0x28>
  }
  return -1;
    80002392:	557d                	li	a0,-1
    80002394:	a829                	j	800023ae <kill+0x64>
      p->killed = 1;
    80002396:	4785                	li	a5,1
    80002398:	d49c                	sw	a5,40(s1)
      if(p->state == SLEEPING){
    8000239a:	4c98                	lw	a4,24(s1)
    8000239c:	4789                	li	a5,2
    8000239e:	02f70063          	beq	a4,a5,800023be <kill+0x74>
      release(&p->lock);
    800023a2:	8526                	mv	a0,s1
    800023a4:	fffff097          	auipc	ra,0xfffff
    800023a8:	8e2080e7          	jalr	-1822(ra) # 80000c86 <release>
      return 0;
    800023ac:	4501                	li	a0,0
}
    800023ae:	70a2                	ld	ra,40(sp)
    800023b0:	7402                	ld	s0,32(sp)
    800023b2:	64e2                	ld	s1,24(sp)
    800023b4:	6942                	ld	s2,16(sp)
    800023b6:	69a2                	ld	s3,8(sp)
    800023b8:	6a02                	ld	s4,0(sp)
    800023ba:	6145                	addi	sp,sp,48
    800023bc:	8082                	ret
        p->state = RUNNABLE;
    800023be:	478d                	li	a5,3
    800023c0:	cc9c                	sw	a5,24(s1)
    800023c2:	b7c5                	j	800023a2 <kill+0x58>

00000000800023c4 <setkilled>:

void
setkilled(struct proc *p)
{
    800023c4:	1101                	addi	sp,sp,-32
    800023c6:	ec06                	sd	ra,24(sp)
    800023c8:	e822                	sd	s0,16(sp)
    800023ca:	e426                	sd	s1,8(sp)
    800023cc:	1000                	addi	s0,sp,32
    800023ce:	84aa                	mv	s1,a0
  acquire(&p->lock);
    800023d0:	fffff097          	auipc	ra,0xfffff
    800023d4:	802080e7          	jalr	-2046(ra) # 80000bd2 <acquire>
  p->killed = 1;
    800023d8:	4785                	li	a5,1
    800023da:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    800023dc:	8526                	mv	a0,s1
    800023de:	fffff097          	auipc	ra,0xfffff
    800023e2:	8a8080e7          	jalr	-1880(ra) # 80000c86 <release>
}
    800023e6:	60e2                	ld	ra,24(sp)
    800023e8:	6442                	ld	s0,16(sp)
    800023ea:	64a2                	ld	s1,8(sp)
    800023ec:	6105                	addi	sp,sp,32
    800023ee:	8082                	ret

00000000800023f0 <killed>:

int
killed(struct proc *p)
{
    800023f0:	1101                	addi	sp,sp,-32
    800023f2:	ec06                	sd	ra,24(sp)
    800023f4:	e822                	sd	s0,16(sp)
    800023f6:	e426                	sd	s1,8(sp)
    800023f8:	e04a                	sd	s2,0(sp)
    800023fa:	1000                	addi	s0,sp,32
    800023fc:	84aa                	mv	s1,a0
  int k;
  
  acquire(&p->lock);
    800023fe:	ffffe097          	auipc	ra,0xffffe
    80002402:	7d4080e7          	jalr	2004(ra) # 80000bd2 <acquire>
  k = p->killed;
    80002406:	0284a903          	lw	s2,40(s1)
  release(&p->lock);
    8000240a:	8526                	mv	a0,s1
    8000240c:	fffff097          	auipc	ra,0xfffff
    80002410:	87a080e7          	jalr	-1926(ra) # 80000c86 <release>
  return k;
}
    80002414:	854a                	mv	a0,s2
    80002416:	60e2                	ld	ra,24(sp)
    80002418:	6442                	ld	s0,16(sp)
    8000241a:	64a2                	ld	s1,8(sp)
    8000241c:	6902                	ld	s2,0(sp)
    8000241e:	6105                	addi	sp,sp,32
    80002420:	8082                	ret

0000000080002422 <wait>:
{
    80002422:	715d                	addi	sp,sp,-80
    80002424:	e486                	sd	ra,72(sp)
    80002426:	e0a2                	sd	s0,64(sp)
    80002428:	fc26                	sd	s1,56(sp)
    8000242a:	f84a                	sd	s2,48(sp)
    8000242c:	f44e                	sd	s3,40(sp)
    8000242e:	f052                	sd	s4,32(sp)
    80002430:	ec56                	sd	s5,24(sp)
    80002432:	e85a                	sd	s6,16(sp)
    80002434:	e45e                	sd	s7,8(sp)
    80002436:	0880                	addi	s0,sp,80
    80002438:	8baa                	mv	s7,a0
  struct proc *p = myproc();
    8000243a:	fffff097          	auipc	ra,0xfffff
    8000243e:	5a8080e7          	jalr	1448(ra) # 800019e2 <myproc>
    80002442:	892a                	mv	s2,a0
  acquire(&wait_lock);
    80002444:	0000f517          	auipc	a0,0xf
    80002448:	8e450513          	addi	a0,a0,-1820 # 80010d28 <wait_lock>
    8000244c:	ffffe097          	auipc	ra,0xffffe
    80002450:	786080e7          	jalr	1926(ra) # 80000bd2 <acquire>
        if(pp->state == ZOMBIE){
    80002454:	4a95                	li	s5,5
        havekids = 1;
    80002456:	4b05                	li	s6,1
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80002458:	6999                	lui	s3,0x6
    8000245a:	f3898993          	addi	s3,s3,-200 # 5f38 <_entry-0x7fffa0c8>
    8000245e:	0018ca17          	auipc	s4,0x18c
    80002462:	ae2a0a13          	addi	s4,s4,-1310 # 8018df40 <tickslock>
    80002466:	a0d9                	j	8000252c <wait+0x10a>
          pid = pp->pid;
    80002468:	0304a983          	lw	s3,48(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    8000246c:	000b8e63          	beqz	s7,80002488 <wait+0x66>
    80002470:	4691                	li	a3,4
    80002472:	02c48613          	addi	a2,s1,44
    80002476:	85de                	mv	a1,s7
    80002478:	05093503          	ld	a0,80(s2)
    8000247c:	fffff097          	auipc	ra,0xfffff
    80002480:	216080e7          	jalr	534(ra) # 80001692 <copyout>
    80002484:	04054063          	bltz	a0,800024c4 <wait+0xa2>
          freeproc(pp);
    80002488:	8526                	mv	a0,s1
    8000248a:	fffff097          	auipc	ra,0xfffff
    8000248e:	70a080e7          	jalr	1802(ra) # 80001b94 <freeproc>
          release(&pp->lock);
    80002492:	8526                	mv	a0,s1
    80002494:	ffffe097          	auipc	ra,0xffffe
    80002498:	7f2080e7          	jalr	2034(ra) # 80000c86 <release>
          release(&wait_lock);
    8000249c:	0000f517          	auipc	a0,0xf
    800024a0:	88c50513          	addi	a0,a0,-1908 # 80010d28 <wait_lock>
    800024a4:	ffffe097          	auipc	ra,0xffffe
    800024a8:	7e2080e7          	jalr	2018(ra) # 80000c86 <release>
}
    800024ac:	854e                	mv	a0,s3
    800024ae:	60a6                	ld	ra,72(sp)
    800024b0:	6406                	ld	s0,64(sp)
    800024b2:	74e2                	ld	s1,56(sp)
    800024b4:	7942                	ld	s2,48(sp)
    800024b6:	79a2                	ld	s3,40(sp)
    800024b8:	7a02                	ld	s4,32(sp)
    800024ba:	6ae2                	ld	s5,24(sp)
    800024bc:	6b42                	ld	s6,16(sp)
    800024be:	6ba2                	ld	s7,8(sp)
    800024c0:	6161                	addi	sp,sp,80
    800024c2:	8082                	ret
            release(&pp->lock);
    800024c4:	8526                	mv	a0,s1
    800024c6:	ffffe097          	auipc	ra,0xffffe
    800024ca:	7c0080e7          	jalr	1984(ra) # 80000c86 <release>
            release(&wait_lock);
    800024ce:	0000f517          	auipc	a0,0xf
    800024d2:	85a50513          	addi	a0,a0,-1958 # 80010d28 <wait_lock>
    800024d6:	ffffe097          	auipc	ra,0xffffe
    800024da:	7b0080e7          	jalr	1968(ra) # 80000c86 <release>
            return -1;
    800024de:	59fd                	li	s3,-1
    800024e0:	b7f1                	j	800024ac <wait+0x8a>
    for(pp = proc; pp < &proc[NPROC]; pp++){
    800024e2:	94ce                	add	s1,s1,s3
    800024e4:	03448463          	beq	s1,s4,8000250c <wait+0xea>
      if(pp->parent == p){
    800024e8:	7c9c                	ld	a5,56(s1)
    800024ea:	ff279ce3          	bne	a5,s2,800024e2 <wait+0xc0>
        acquire(&pp->lock);
    800024ee:	8526                	mv	a0,s1
    800024f0:	ffffe097          	auipc	ra,0xffffe
    800024f4:	6e2080e7          	jalr	1762(ra) # 80000bd2 <acquire>
        if(pp->state == ZOMBIE){
    800024f8:	4c9c                	lw	a5,24(s1)
    800024fa:	f75787e3          	beq	a5,s5,80002468 <wait+0x46>
        release(&pp->lock);
    800024fe:	8526                	mv	a0,s1
    80002500:	ffffe097          	auipc	ra,0xffffe
    80002504:	786080e7          	jalr	1926(ra) # 80000c86 <release>
        havekids = 1;
    80002508:	875a                	mv	a4,s6
    8000250a:	bfe1                	j	800024e2 <wait+0xc0>
    if(!havekids || killed(p)){
    8000250c:	c715                	beqz	a4,80002538 <wait+0x116>
    8000250e:	854a                	mv	a0,s2
    80002510:	00000097          	auipc	ra,0x0
    80002514:	ee0080e7          	jalr	-288(ra) # 800023f0 <killed>
    80002518:	e105                	bnez	a0,80002538 <wait+0x116>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    8000251a:	0000f597          	auipc	a1,0xf
    8000251e:	80e58593          	addi	a1,a1,-2034 # 80010d28 <wait_lock>
    80002522:	854a                	mv	a0,s2
    80002524:	00000097          	auipc	ra,0x0
    80002528:	c0c080e7          	jalr	-1012(ra) # 80002130 <sleep>
    havekids = 0;
    8000252c:	4701                	li	a4,0
    for(pp = proc; pp < &proc[NPROC]; pp++){
    8000252e:	0000f497          	auipc	s1,0xf
    80002532:	c1248493          	addi	s1,s1,-1006 # 80011140 <proc>
    80002536:	bf4d                	j	800024e8 <wait+0xc6>
      release(&wait_lock);
    80002538:	0000e517          	auipc	a0,0xe
    8000253c:	7f050513          	addi	a0,a0,2032 # 80010d28 <wait_lock>
    80002540:	ffffe097          	auipc	ra,0xffffe
    80002544:	746080e7          	jalr	1862(ra) # 80000c86 <release>
      return -1;
    80002548:	59fd                	li	s3,-1
    8000254a:	b78d                	j	800024ac <wait+0x8a>

000000008000254c <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    8000254c:	7179                	addi	sp,sp,-48
    8000254e:	f406                	sd	ra,40(sp)
    80002550:	f022                	sd	s0,32(sp)
    80002552:	ec26                	sd	s1,24(sp)
    80002554:	e84a                	sd	s2,16(sp)
    80002556:	e44e                	sd	s3,8(sp)
    80002558:	e052                	sd	s4,0(sp)
    8000255a:	1800                	addi	s0,sp,48
    8000255c:	84aa                	mv	s1,a0
    8000255e:	892e                	mv	s2,a1
    80002560:	89b2                	mv	s3,a2
    80002562:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002564:	fffff097          	auipc	ra,0xfffff
    80002568:	47e080e7          	jalr	1150(ra) # 800019e2 <myproc>
  if(user_dst){
    8000256c:	c08d                	beqz	s1,8000258e <either_copyout+0x42>
    return copyout(p->pagetable, dst, src, len);
    8000256e:	86d2                	mv	a3,s4
    80002570:	864e                	mv	a2,s3
    80002572:	85ca                	mv	a1,s2
    80002574:	6928                	ld	a0,80(a0)
    80002576:	fffff097          	auipc	ra,0xfffff
    8000257a:	11c080e7          	jalr	284(ra) # 80001692 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    8000257e:	70a2                	ld	ra,40(sp)
    80002580:	7402                	ld	s0,32(sp)
    80002582:	64e2                	ld	s1,24(sp)
    80002584:	6942                	ld	s2,16(sp)
    80002586:	69a2                	ld	s3,8(sp)
    80002588:	6a02                	ld	s4,0(sp)
    8000258a:	6145                	addi	sp,sp,48
    8000258c:	8082                	ret
    memmove((char *)dst, src, len);
    8000258e:	000a061b          	sext.w	a2,s4
    80002592:	85ce                	mv	a1,s3
    80002594:	854a                	mv	a0,s2
    80002596:	ffffe097          	auipc	ra,0xffffe
    8000259a:	794080e7          	jalr	1940(ra) # 80000d2a <memmove>
    return 0;
    8000259e:	8526                	mv	a0,s1
    800025a0:	bff9                	j	8000257e <either_copyout+0x32>

00000000800025a2 <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    800025a2:	7179                	addi	sp,sp,-48
    800025a4:	f406                	sd	ra,40(sp)
    800025a6:	f022                	sd	s0,32(sp)
    800025a8:	ec26                	sd	s1,24(sp)
    800025aa:	e84a                	sd	s2,16(sp)
    800025ac:	e44e                	sd	s3,8(sp)
    800025ae:	e052                	sd	s4,0(sp)
    800025b0:	1800                	addi	s0,sp,48
    800025b2:	892a                	mv	s2,a0
    800025b4:	84ae                	mv	s1,a1
    800025b6:	89b2                	mv	s3,a2
    800025b8:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800025ba:	fffff097          	auipc	ra,0xfffff
    800025be:	428080e7          	jalr	1064(ra) # 800019e2 <myproc>
  if(user_src){
    800025c2:	c08d                	beqz	s1,800025e4 <either_copyin+0x42>
    return copyin(p->pagetable, dst, src, len);
    800025c4:	86d2                	mv	a3,s4
    800025c6:	864e                	mv	a2,s3
    800025c8:	85ca                	mv	a1,s2
    800025ca:	6928                	ld	a0,80(a0)
    800025cc:	fffff097          	auipc	ra,0xfffff
    800025d0:	152080e7          	jalr	338(ra) # 8000171e <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    800025d4:	70a2                	ld	ra,40(sp)
    800025d6:	7402                	ld	s0,32(sp)
    800025d8:	64e2                	ld	s1,24(sp)
    800025da:	6942                	ld	s2,16(sp)
    800025dc:	69a2                	ld	s3,8(sp)
    800025de:	6a02                	ld	s4,0(sp)
    800025e0:	6145                	addi	sp,sp,48
    800025e2:	8082                	ret
    memmove(dst, (char*)src, len);
    800025e4:	000a061b          	sext.w	a2,s4
    800025e8:	85ce                	mv	a1,s3
    800025ea:	854a                	mv	a0,s2
    800025ec:	ffffe097          	auipc	ra,0xffffe
    800025f0:	73e080e7          	jalr	1854(ra) # 80000d2a <memmove>
    return 0;
    800025f4:	8526                	mv	a0,s1
    800025f6:	bff9                	j	800025d4 <either_copyin+0x32>

00000000800025f8 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    800025f8:	715d                	addi	sp,sp,-80
    800025fa:	e486                	sd	ra,72(sp)
    800025fc:	e0a2                	sd	s0,64(sp)
    800025fe:	fc26                	sd	s1,56(sp)
    80002600:	f84a                	sd	s2,48(sp)
    80002602:	f44e                	sd	s3,40(sp)
    80002604:	f052                	sd	s4,32(sp)
    80002606:	ec56                	sd	s5,24(sp)
    80002608:	e85a                	sd	s6,16(sp)
    8000260a:	e45e                	sd	s7,8(sp)
    8000260c:	e062                	sd	s8,0(sp)
    8000260e:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    80002610:	00006517          	auipc	a0,0x6
    80002614:	40850513          	addi	a0,a0,1032 # 80008a18 <syscalls+0x5a0>
    80002618:	ffffe097          	auipc	ra,0xffffe
    8000261c:	f6e080e7          	jalr	-146(ra) # 80000586 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002620:	0000f497          	auipc	s1,0xf
    80002624:	c7848493          	addi	s1,s1,-904 # 80011298 <proc+0x158>
    80002628:	0018c997          	auipc	s3,0x18c
    8000262c:	a7098993          	addi	s3,s3,-1424 # 8018e098 <bcache+0x140>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002630:	4b95                	li	s7,5
      state = states[p->state];
    else
      state = "???";
    80002632:	00006a17          	auipc	s4,0x6
    80002636:	c76a0a13          	addi	s4,s4,-906 # 800082a8 <digits+0x268>
    printf("%d %s %s", p->pid, state, p->name);
    8000263a:	00006b17          	auipc	s6,0x6
    8000263e:	c76b0b13          	addi	s6,s6,-906 # 800082b0 <digits+0x270>
    printf("\n");
    80002642:	00006a97          	auipc	s5,0x6
    80002646:	3d6a8a93          	addi	s5,s5,982 # 80008a18 <syscalls+0x5a0>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000264a:	00006c17          	auipc	s8,0x6
    8000264e:	ca6c0c13          	addi	s8,s8,-858 # 800082f0 <states.0>
  for(p = proc; p < &proc[NPROC]; p++){
    80002652:	6919                	lui	s2,0x6
    80002654:	f3890913          	addi	s2,s2,-200 # 5f38 <_entry-0x7fffa0c8>
    80002658:	a005                	j	80002678 <procdump+0x80>
    printf("%d %s %s", p->pid, state, p->name);
    8000265a:	ed86a583          	lw	a1,-296(a3)
    8000265e:	855a                	mv	a0,s6
    80002660:	ffffe097          	auipc	ra,0xffffe
    80002664:	f26080e7          	jalr	-218(ra) # 80000586 <printf>
    printf("\n");
    80002668:	8556                	mv	a0,s5
    8000266a:	ffffe097          	auipc	ra,0xffffe
    8000266e:	f1c080e7          	jalr	-228(ra) # 80000586 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002672:	94ca                	add	s1,s1,s2
    80002674:	03348263          	beq	s1,s3,80002698 <procdump+0xa0>
    if(p->state == UNUSED)
    80002678:	86a6                	mv	a3,s1
    8000267a:	ec04a783          	lw	a5,-320(s1)
    8000267e:	dbf5                	beqz	a5,80002672 <procdump+0x7a>
      state = "???";
    80002680:	8652                	mv	a2,s4
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002682:	fcfbece3          	bltu	s7,a5,8000265a <procdump+0x62>
    80002686:	02079713          	slli	a4,a5,0x20
    8000268a:	01d75793          	srli	a5,a4,0x1d
    8000268e:	97e2                	add	a5,a5,s8
    80002690:	6390                	ld	a2,0(a5)
    80002692:	f661                	bnez	a2,8000265a <procdump+0x62>
      state = "???";
    80002694:	8652                	mv	a2,s4
    80002696:	b7d1                	j	8000265a <procdump+0x62>
  }
}
    80002698:	60a6                	ld	ra,72(sp)
    8000269a:	6406                	ld	s0,64(sp)
    8000269c:	74e2                	ld	s1,56(sp)
    8000269e:	7942                	ld	s2,48(sp)
    800026a0:	79a2                	ld	s3,40(sp)
    800026a2:	7a02                	ld	s4,32(sp)
    800026a4:	6ae2                	ld	s5,24(sp)
    800026a6:	6b42                	ld	s6,16(sp)
    800026a8:	6ba2                	ld	s7,8(sp)
    800026aa:	6c02                	ld	s8,0(sp)
    800026ac:	6161                	addi	sp,sp,80
    800026ae:	8082                	ret

00000000800026b0 <swtch>:
    800026b0:	00153023          	sd	ra,0(a0)
    800026b4:	00253423          	sd	sp,8(a0)
    800026b8:	e900                	sd	s0,16(a0)
    800026ba:	ed04                	sd	s1,24(a0)
    800026bc:	03253023          	sd	s2,32(a0)
    800026c0:	03353423          	sd	s3,40(a0)
    800026c4:	03453823          	sd	s4,48(a0)
    800026c8:	03553c23          	sd	s5,56(a0)
    800026cc:	05653023          	sd	s6,64(a0)
    800026d0:	05753423          	sd	s7,72(a0)
    800026d4:	05853823          	sd	s8,80(a0)
    800026d8:	05953c23          	sd	s9,88(a0)
    800026dc:	07a53023          	sd	s10,96(a0)
    800026e0:	07b53423          	sd	s11,104(a0)
    800026e4:	0005b083          	ld	ra,0(a1)
    800026e8:	0085b103          	ld	sp,8(a1)
    800026ec:	6980                	ld	s0,16(a1)
    800026ee:	6d84                	ld	s1,24(a1)
    800026f0:	0205b903          	ld	s2,32(a1)
    800026f4:	0285b983          	ld	s3,40(a1)
    800026f8:	0305ba03          	ld	s4,48(a1)
    800026fc:	0385ba83          	ld	s5,56(a1)
    80002700:	0405bb03          	ld	s6,64(a1)
    80002704:	0485bb83          	ld	s7,72(a1)
    80002708:	0505bc03          	ld	s8,80(a1)
    8000270c:	0585bc83          	ld	s9,88(a1)
    80002710:	0605bd03          	ld	s10,96(a1)
    80002714:	0685bd83          	ld	s11,104(a1)
    80002718:	8082                	ret

000000008000271a <trapinit>:

extern int devintr();

void
trapinit(void)
{
    8000271a:	1141                	addi	sp,sp,-16
    8000271c:	e406                	sd	ra,8(sp)
    8000271e:	e022                	sd	s0,0(sp)
    80002720:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80002722:	00006597          	auipc	a1,0x6
    80002726:	bfe58593          	addi	a1,a1,-1026 # 80008320 <states.0+0x30>
    8000272a:	0018c517          	auipc	a0,0x18c
    8000272e:	81650513          	addi	a0,a0,-2026 # 8018df40 <tickslock>
    80002732:	ffffe097          	auipc	ra,0xffffe
    80002736:	410080e7          	jalr	1040(ra) # 80000b42 <initlock>
}
    8000273a:	60a2                	ld	ra,8(sp)
    8000273c:	6402                	ld	s0,0(sp)
    8000273e:	0141                	addi	sp,sp,16
    80002740:	8082                	ret

0000000080002742 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    80002742:	1141                	addi	sp,sp,-16
    80002744:	e422                	sd	s0,8(sp)
    80002746:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002748:	00003797          	auipc	a5,0x3
    8000274c:	4f878793          	addi	a5,a5,1272 # 80005c40 <kernelvec>
    80002750:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80002754:	6422                	ld	s0,8(sp)
    80002756:	0141                	addi	sp,sp,16
    80002758:	8082                	ret

000000008000275a <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    8000275a:	1141                	addi	sp,sp,-16
    8000275c:	e406                	sd	ra,8(sp)
    8000275e:	e022                	sd	s0,0(sp)
    80002760:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80002762:	fffff097          	auipc	ra,0xfffff
    80002766:	280080e7          	jalr	640(ra) # 800019e2 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000276a:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    8000276e:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002770:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    80002774:	00005697          	auipc	a3,0x5
    80002778:	88c68693          	addi	a3,a3,-1908 # 80007000 <_trampoline>
    8000277c:	00005717          	auipc	a4,0x5
    80002780:	88470713          	addi	a4,a4,-1916 # 80007000 <_trampoline>
    80002784:	8f15                	sub	a4,a4,a3
    80002786:	040007b7          	lui	a5,0x4000
    8000278a:	17fd                	addi	a5,a5,-1 # 3ffffff <_entry-0x7c000001>
    8000278c:	07b2                	slli	a5,a5,0xc
    8000278e:	973e                	add	a4,a4,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002790:	10571073          	csrw	stvec,a4
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    80002794:	6d38                	ld	a4,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    80002796:	18002673          	csrr	a2,satp
    8000279a:	e310                	sd	a2,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    8000279c:	6d30                	ld	a2,88(a0)
    8000279e:	6138                	ld	a4,64(a0)
    800027a0:	6585                	lui	a1,0x1
    800027a2:	972e                	add	a4,a4,a1
    800027a4:	e618                	sd	a4,8(a2)
  p->trapframe->kernel_trap = (uint64)usertrap;
    800027a6:	6d38                	ld	a4,88(a0)
    800027a8:	00000617          	auipc	a2,0x0
    800027ac:	13460613          	addi	a2,a2,308 # 800028dc <usertrap>
    800027b0:	eb10                	sd	a2,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    800027b2:	6d38                	ld	a4,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    800027b4:	8612                	mv	a2,tp
    800027b6:	f310                	sd	a2,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800027b8:	10002773          	csrr	a4,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    800027bc:	eff77713          	andi	a4,a4,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    800027c0:	02076713          	ori	a4,a4,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800027c4:	10071073          	csrw	sstatus,a4
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    800027c8:	6d38                	ld	a4,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    800027ca:	6f18                	ld	a4,24(a4)
    800027cc:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    800027d0:	6928                	ld	a0,80(a0)
    800027d2:	8131                	srli	a0,a0,0xc

  // jump to userret in trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    800027d4:	00005717          	auipc	a4,0x5
    800027d8:	8c870713          	addi	a4,a4,-1848 # 8000709c <userret>
    800027dc:	8f15                	sub	a4,a4,a3
    800027de:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    800027e0:	577d                	li	a4,-1
    800027e2:	177e                	slli	a4,a4,0x3f
    800027e4:	8d59                	or	a0,a0,a4
    800027e6:	9782                	jalr	a5
}
    800027e8:	60a2                	ld	ra,8(sp)
    800027ea:	6402                	ld	s0,0(sp)
    800027ec:	0141                	addi	sp,sp,16
    800027ee:	8082                	ret

00000000800027f0 <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    800027f0:	1101                	addi	sp,sp,-32
    800027f2:	ec06                	sd	ra,24(sp)
    800027f4:	e822                	sd	s0,16(sp)
    800027f6:	e426                	sd	s1,8(sp)
    800027f8:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    800027fa:	0018b497          	auipc	s1,0x18b
    800027fe:	74648493          	addi	s1,s1,1862 # 8018df40 <tickslock>
    80002802:	8526                	mv	a0,s1
    80002804:	ffffe097          	auipc	ra,0xffffe
    80002808:	3ce080e7          	jalr	974(ra) # 80000bd2 <acquire>
  ticks++;
    8000280c:	00006517          	auipc	a0,0x6
    80002810:	29450513          	addi	a0,a0,660 # 80008aa0 <ticks>
    80002814:	411c                	lw	a5,0(a0)
    80002816:	2785                	addiw	a5,a5,1
    80002818:	c11c                	sw	a5,0(a0)
  wakeup(&ticks);
    8000281a:	00000097          	auipc	ra,0x0
    8000281e:	97a080e7          	jalr	-1670(ra) # 80002194 <wakeup>
  release(&tickslock);
    80002822:	8526                	mv	a0,s1
    80002824:	ffffe097          	auipc	ra,0xffffe
    80002828:	462080e7          	jalr	1122(ra) # 80000c86 <release>
}
    8000282c:	60e2                	ld	ra,24(sp)
    8000282e:	6442                	ld	s0,16(sp)
    80002830:	64a2                	ld	s1,8(sp)
    80002832:	6105                	addi	sp,sp,32
    80002834:	8082                	ret

0000000080002836 <devintr>:
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002836:	142027f3          	csrr	a5,scause
    // the SSIP bit in sip.
    w_sip(r_sip() & ~2);

    return 2;
  } else {
    return 0;
    8000283a:	4501                	li	a0,0
  if((scause & 0x8000000000000000L) &&
    8000283c:	0807df63          	bgez	a5,800028da <devintr+0xa4>
{
    80002840:	1101                	addi	sp,sp,-32
    80002842:	ec06                	sd	ra,24(sp)
    80002844:	e822                	sd	s0,16(sp)
    80002846:	e426                	sd	s1,8(sp)
    80002848:	1000                	addi	s0,sp,32
     (scause & 0xff) == 9){
    8000284a:	0ff7f713          	zext.b	a4,a5
  if((scause & 0x8000000000000000L) &&
    8000284e:	46a5                	li	a3,9
    80002850:	00d70d63          	beq	a4,a3,8000286a <devintr+0x34>
  } else if(scause == 0x8000000000000001L){
    80002854:	577d                	li	a4,-1
    80002856:	177e                	slli	a4,a4,0x3f
    80002858:	0705                	addi	a4,a4,1
    return 0;
    8000285a:	4501                	li	a0,0
  } else if(scause == 0x8000000000000001L){
    8000285c:	04e78e63          	beq	a5,a4,800028b8 <devintr+0x82>
  }
}
    80002860:	60e2                	ld	ra,24(sp)
    80002862:	6442                	ld	s0,16(sp)
    80002864:	64a2                	ld	s1,8(sp)
    80002866:	6105                	addi	sp,sp,32
    80002868:	8082                	ret
    int irq = plic_claim();
    8000286a:	00003097          	auipc	ra,0x3
    8000286e:	4de080e7          	jalr	1246(ra) # 80005d48 <plic_claim>
    80002872:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    80002874:	47a9                	li	a5,10
    80002876:	02f50763          	beq	a0,a5,800028a4 <devintr+0x6e>
    } else if(irq == VIRTIO0_IRQ){
    8000287a:	4785                	li	a5,1
    8000287c:	02f50963          	beq	a0,a5,800028ae <devintr+0x78>
    return 1;
    80002880:	4505                	li	a0,1
    } else if(irq){
    80002882:	dcf9                	beqz	s1,80002860 <devintr+0x2a>
      printf("unexpected interrupt irq=%d\n", irq);
    80002884:	85a6                	mv	a1,s1
    80002886:	00006517          	auipc	a0,0x6
    8000288a:	aa250513          	addi	a0,a0,-1374 # 80008328 <states.0+0x38>
    8000288e:	ffffe097          	auipc	ra,0xffffe
    80002892:	cf8080e7          	jalr	-776(ra) # 80000586 <printf>
      plic_complete(irq);
    80002896:	8526                	mv	a0,s1
    80002898:	00003097          	auipc	ra,0x3
    8000289c:	4d4080e7          	jalr	1236(ra) # 80005d6c <plic_complete>
    return 1;
    800028a0:	4505                	li	a0,1
    800028a2:	bf7d                	j	80002860 <devintr+0x2a>
      uartintr();
    800028a4:	ffffe097          	auipc	ra,0xffffe
    800028a8:	0f0080e7          	jalr	240(ra) # 80000994 <uartintr>
    if(irq)
    800028ac:	b7ed                	j	80002896 <devintr+0x60>
      virtio_disk_intr();
    800028ae:	00004097          	auipc	ra,0x4
    800028b2:	984080e7          	jalr	-1660(ra) # 80006232 <virtio_disk_intr>
    if(irq)
    800028b6:	b7c5                	j	80002896 <devintr+0x60>
    if(cpuid() == 0){
    800028b8:	fffff097          	auipc	ra,0xfffff
    800028bc:	0fe080e7          	jalr	254(ra) # 800019b6 <cpuid>
    800028c0:	c901                	beqz	a0,800028d0 <devintr+0x9a>
  asm volatile("csrr %0, sip" : "=r" (x) );
    800028c2:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    800028c6:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    800028c8:	14479073          	csrw	sip,a5
    return 2;
    800028cc:	4509                	li	a0,2
    800028ce:	bf49                	j	80002860 <devintr+0x2a>
      clockintr();
    800028d0:	00000097          	auipc	ra,0x0
    800028d4:	f20080e7          	jalr	-224(ra) # 800027f0 <clockintr>
    800028d8:	b7ed                	j	800028c2 <devintr+0x8c>
}
    800028da:	8082                	ret

00000000800028dc <usertrap>:
{
    800028dc:	1101                	addi	sp,sp,-32
    800028de:	ec06                	sd	ra,24(sp)
    800028e0:	e822                	sd	s0,16(sp)
    800028e2:	e426                	sd	s1,8(sp)
    800028e4:	e04a                	sd	s2,0(sp)
    800028e6:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800028e8:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    800028ec:	1007f793          	andi	a5,a5,256
    800028f0:	eba5                	bnez	a5,80002960 <usertrap+0x84>
  asm volatile("csrw stvec, %0" : : "r" (x));
    800028f2:	00003797          	auipc	a5,0x3
    800028f6:	34e78793          	addi	a5,a5,846 # 80005c40 <kernelvec>
    800028fa:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    800028fe:	fffff097          	auipc	ra,0xfffff
    80002902:	0e4080e7          	jalr	228(ra) # 800019e2 <myproc>
    80002906:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80002908:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    8000290a:	14102773          	csrr	a4,sepc
    8000290e:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002910:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80002914:	47a1                	li	a5,8
    80002916:	04f70d63          	beq	a4,a5,80002970 <usertrap+0x94>
    8000291a:	14202773          	csrr	a4,scause
  } else if(r_scause()==12||r_scause()==13||r_scause()==15){
    8000291e:	47b1                	li	a5,12
    80002920:	00f70c63          	beq	a4,a5,80002938 <usertrap+0x5c>
    80002924:	14202773          	csrr	a4,scause
    80002928:	47b5                	li	a5,13
    8000292a:	00f70763          	beq	a4,a5,80002938 <usertrap+0x5c>
    8000292e:	14202773          	csrr	a4,scause
    80002932:	47bd                	li	a5,15
    80002934:	06f71863          	bne	a4,a5,800029a4 <usertrap+0xc8>
    page_fault_handler();
    80002938:	00004097          	auipc	ra,0x4
    8000293c:	a7c080e7          	jalr	-1412(ra) # 800063b4 <page_fault_handler>
  if(killed(p))
    80002940:	8526                	mv	a0,s1
    80002942:	00000097          	auipc	ra,0x0
    80002946:	aae080e7          	jalr	-1362(ra) # 800023f0 <killed>
    8000294a:	e55d                	bnez	a0,800029f8 <usertrap+0x11c>
  usertrapret();
    8000294c:	00000097          	auipc	ra,0x0
    80002950:	e0e080e7          	jalr	-498(ra) # 8000275a <usertrapret>
}
    80002954:	60e2                	ld	ra,24(sp)
    80002956:	6442                	ld	s0,16(sp)
    80002958:	64a2                	ld	s1,8(sp)
    8000295a:	6902                	ld	s2,0(sp)
    8000295c:	6105                	addi	sp,sp,32
    8000295e:	8082                	ret
    panic("usertrap: not from user mode");
    80002960:	00006517          	auipc	a0,0x6
    80002964:	9e850513          	addi	a0,a0,-1560 # 80008348 <states.0+0x58>
    80002968:	ffffe097          	auipc	ra,0xffffe
    8000296c:	bd4080e7          	jalr	-1068(ra) # 8000053c <panic>
    if(killed(p))
    80002970:	00000097          	auipc	ra,0x0
    80002974:	a80080e7          	jalr	-1408(ra) # 800023f0 <killed>
    80002978:	e105                	bnez	a0,80002998 <usertrap+0xbc>
    p->trapframe->epc += 4;
    8000297a:	6cb8                	ld	a4,88(s1)
    8000297c:	6f1c                	ld	a5,24(a4)
    8000297e:	0791                	addi	a5,a5,4
    80002980:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002982:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002986:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000298a:	10079073          	csrw	sstatus,a5
    syscall();
    8000298e:	00000097          	auipc	ra,0x0
    80002992:	2d0080e7          	jalr	720(ra) # 80002c5e <syscall>
    80002996:	b76d                	j	80002940 <usertrap+0x64>
      exit(-1);
    80002998:	557d                	li	a0,-1
    8000299a:	00000097          	auipc	ra,0x0
    8000299e:	8da080e7          	jalr	-1830(ra) # 80002274 <exit>
    800029a2:	bfe1                	j	8000297a <usertrap+0x9e>
  } else if((which_dev = devintr()) != 0){
    800029a4:	00000097          	auipc	ra,0x0
    800029a8:	e92080e7          	jalr	-366(ra) # 80002836 <devintr>
    800029ac:	892a                	mv	s2,a0
    800029ae:	c901                	beqz	a0,800029be <usertrap+0xe2>
  if(killed(p))
    800029b0:	8526                	mv	a0,s1
    800029b2:	00000097          	auipc	ra,0x0
    800029b6:	a3e080e7          	jalr	-1474(ra) # 800023f0 <killed>
    800029ba:	c529                	beqz	a0,80002a04 <usertrap+0x128>
    800029bc:	a83d                	j	800029fa <usertrap+0x11e>
  asm volatile("csrr %0, scause" : "=r" (x) );
    800029be:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    800029c2:	5890                	lw	a2,48(s1)
    800029c4:	00006517          	auipc	a0,0x6
    800029c8:	9a450513          	addi	a0,a0,-1628 # 80008368 <states.0+0x78>
    800029cc:	ffffe097          	auipc	ra,0xffffe
    800029d0:	bba080e7          	jalr	-1094(ra) # 80000586 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800029d4:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    800029d8:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    800029dc:	00006517          	auipc	a0,0x6
    800029e0:	9bc50513          	addi	a0,a0,-1604 # 80008398 <states.0+0xa8>
    800029e4:	ffffe097          	auipc	ra,0xffffe
    800029e8:	ba2080e7          	jalr	-1118(ra) # 80000586 <printf>
    setkilled(p);
    800029ec:	8526                	mv	a0,s1
    800029ee:	00000097          	auipc	ra,0x0
    800029f2:	9d6080e7          	jalr	-1578(ra) # 800023c4 <setkilled>
    800029f6:	b7a9                	j	80002940 <usertrap+0x64>
  if(killed(p))
    800029f8:	4901                	li	s2,0
    exit(-1);
    800029fa:	557d                	li	a0,-1
    800029fc:	00000097          	auipc	ra,0x0
    80002a00:	878080e7          	jalr	-1928(ra) # 80002274 <exit>
  if(which_dev == 2)
    80002a04:	4789                	li	a5,2
    80002a06:	f4f913e3          	bne	s2,a5,8000294c <usertrap+0x70>
    yield();
    80002a0a:	fffff097          	auipc	ra,0xfffff
    80002a0e:	6ea080e7          	jalr	1770(ra) # 800020f4 <yield>
    80002a12:	bf2d                	j	8000294c <usertrap+0x70>

0000000080002a14 <kerneltrap>:
{
    80002a14:	7179                	addi	sp,sp,-48
    80002a16:	f406                	sd	ra,40(sp)
    80002a18:	f022                	sd	s0,32(sp)
    80002a1a:	ec26                	sd	s1,24(sp)
    80002a1c:	e84a                	sd	s2,16(sp)
    80002a1e:	e44e                	sd	s3,8(sp)
    80002a20:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002a22:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002a26:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002a2a:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80002a2e:	1004f793          	andi	a5,s1,256
    80002a32:	cb85                	beqz	a5,80002a62 <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002a34:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002a38:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80002a3a:	ef85                	bnez	a5,80002a72 <kerneltrap+0x5e>
  if((which_dev = devintr()) == 0){
    80002a3c:	00000097          	auipc	ra,0x0
    80002a40:	dfa080e7          	jalr	-518(ra) # 80002836 <devintr>
    80002a44:	cd1d                	beqz	a0,80002a82 <kerneltrap+0x6e>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING) {
    80002a46:	4789                	li	a5,2
    80002a48:	06f50a63          	beq	a0,a5,80002abc <kerneltrap+0xa8>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002a4c:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002a50:	10049073          	csrw	sstatus,s1
}
    80002a54:	70a2                	ld	ra,40(sp)
    80002a56:	7402                	ld	s0,32(sp)
    80002a58:	64e2                	ld	s1,24(sp)
    80002a5a:	6942                	ld	s2,16(sp)
    80002a5c:	69a2                	ld	s3,8(sp)
    80002a5e:	6145                	addi	sp,sp,48
    80002a60:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002a62:	00006517          	auipc	a0,0x6
    80002a66:	95650513          	addi	a0,a0,-1706 # 800083b8 <states.0+0xc8>
    80002a6a:	ffffe097          	auipc	ra,0xffffe
    80002a6e:	ad2080e7          	jalr	-1326(ra) # 8000053c <panic>
    panic("kerneltrap: interrupts enabled");
    80002a72:	00006517          	auipc	a0,0x6
    80002a76:	96e50513          	addi	a0,a0,-1682 # 800083e0 <states.0+0xf0>
    80002a7a:	ffffe097          	auipc	ra,0xffffe
    80002a7e:	ac2080e7          	jalr	-1342(ra) # 8000053c <panic>
    printf("scause %p\n", scause);
    80002a82:	85ce                	mv	a1,s3
    80002a84:	00006517          	auipc	a0,0x6
    80002a88:	97c50513          	addi	a0,a0,-1668 # 80008400 <states.0+0x110>
    80002a8c:	ffffe097          	auipc	ra,0xffffe
    80002a90:	afa080e7          	jalr	-1286(ra) # 80000586 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002a94:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002a98:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002a9c:	00006517          	auipc	a0,0x6
    80002aa0:	97450513          	addi	a0,a0,-1676 # 80008410 <states.0+0x120>
    80002aa4:	ffffe097          	auipc	ra,0xffffe
    80002aa8:	ae2080e7          	jalr	-1310(ra) # 80000586 <printf>
    panic("kerneltrap");
    80002aac:	00006517          	auipc	a0,0x6
    80002ab0:	97c50513          	addi	a0,a0,-1668 # 80008428 <states.0+0x138>
    80002ab4:	ffffe097          	auipc	ra,0xffffe
    80002ab8:	a88080e7          	jalr	-1400(ra) # 8000053c <panic>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING) {
    80002abc:	fffff097          	auipc	ra,0xfffff
    80002ac0:	f26080e7          	jalr	-218(ra) # 800019e2 <myproc>
    80002ac4:	d541                	beqz	a0,80002a4c <kerneltrap+0x38>
    80002ac6:	fffff097          	auipc	ra,0xfffff
    80002aca:	f1c080e7          	jalr	-228(ra) # 800019e2 <myproc>
    80002ace:	4d18                	lw	a4,24(a0)
    80002ad0:	4791                	li	a5,4
    80002ad2:	f6f71de3          	bne	a4,a5,80002a4c <kerneltrap+0x38>
    yield();
    80002ad6:	fffff097          	auipc	ra,0xfffff
    80002ada:	61e080e7          	jalr	1566(ra) # 800020f4 <yield>
    80002ade:	b7bd                	j	80002a4c <kerneltrap+0x38>

0000000080002ae0 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002ae0:	1101                	addi	sp,sp,-32
    80002ae2:	ec06                	sd	ra,24(sp)
    80002ae4:	e822                	sd	s0,16(sp)
    80002ae6:	e426                	sd	s1,8(sp)
    80002ae8:	1000                	addi	s0,sp,32
    80002aea:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002aec:	fffff097          	auipc	ra,0xfffff
    80002af0:	ef6080e7          	jalr	-266(ra) # 800019e2 <myproc>
  switch (n) {
    80002af4:	4795                	li	a5,5
    80002af6:	0497e163          	bltu	a5,s1,80002b38 <argraw+0x58>
    80002afa:	048a                	slli	s1,s1,0x2
    80002afc:	00006717          	auipc	a4,0x6
    80002b00:	96470713          	addi	a4,a4,-1692 # 80008460 <states.0+0x170>
    80002b04:	94ba                	add	s1,s1,a4
    80002b06:	409c                	lw	a5,0(s1)
    80002b08:	97ba                	add	a5,a5,a4
    80002b0a:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80002b0c:	6d3c                	ld	a5,88(a0)
    80002b0e:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002b10:	60e2                	ld	ra,24(sp)
    80002b12:	6442                	ld	s0,16(sp)
    80002b14:	64a2                	ld	s1,8(sp)
    80002b16:	6105                	addi	sp,sp,32
    80002b18:	8082                	ret
    return p->trapframe->a1;
    80002b1a:	6d3c                	ld	a5,88(a0)
    80002b1c:	7fa8                	ld	a0,120(a5)
    80002b1e:	bfcd                	j	80002b10 <argraw+0x30>
    return p->trapframe->a2;
    80002b20:	6d3c                	ld	a5,88(a0)
    80002b22:	63c8                	ld	a0,128(a5)
    80002b24:	b7f5                	j	80002b10 <argraw+0x30>
    return p->trapframe->a3;
    80002b26:	6d3c                	ld	a5,88(a0)
    80002b28:	67c8                	ld	a0,136(a5)
    80002b2a:	b7dd                	j	80002b10 <argraw+0x30>
    return p->trapframe->a4;
    80002b2c:	6d3c                	ld	a5,88(a0)
    80002b2e:	6bc8                	ld	a0,144(a5)
    80002b30:	b7c5                	j	80002b10 <argraw+0x30>
    return p->trapframe->a5;
    80002b32:	6d3c                	ld	a5,88(a0)
    80002b34:	6fc8                	ld	a0,152(a5)
    80002b36:	bfe9                	j	80002b10 <argraw+0x30>
  panic("argraw");
    80002b38:	00006517          	auipc	a0,0x6
    80002b3c:	90050513          	addi	a0,a0,-1792 # 80008438 <states.0+0x148>
    80002b40:	ffffe097          	auipc	ra,0xffffe
    80002b44:	9fc080e7          	jalr	-1540(ra) # 8000053c <panic>

0000000080002b48 <fetchaddr>:
{
    80002b48:	1101                	addi	sp,sp,-32
    80002b4a:	ec06                	sd	ra,24(sp)
    80002b4c:	e822                	sd	s0,16(sp)
    80002b4e:	e426                	sd	s1,8(sp)
    80002b50:	e04a                	sd	s2,0(sp)
    80002b52:	1000                	addi	s0,sp,32
    80002b54:	84aa                	mv	s1,a0
    80002b56:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002b58:	fffff097          	auipc	ra,0xfffff
    80002b5c:	e8a080e7          	jalr	-374(ra) # 800019e2 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    80002b60:	653c                	ld	a5,72(a0)
    80002b62:	02f4f863          	bgeu	s1,a5,80002b92 <fetchaddr+0x4a>
    80002b66:	00848713          	addi	a4,s1,8
    80002b6a:	02e7e663          	bltu	a5,a4,80002b96 <fetchaddr+0x4e>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002b6e:	46a1                	li	a3,8
    80002b70:	8626                	mv	a2,s1
    80002b72:	85ca                	mv	a1,s2
    80002b74:	6928                	ld	a0,80(a0)
    80002b76:	fffff097          	auipc	ra,0xfffff
    80002b7a:	ba8080e7          	jalr	-1112(ra) # 8000171e <copyin>
    80002b7e:	00a03533          	snez	a0,a0
    80002b82:	40a00533          	neg	a0,a0
}
    80002b86:	60e2                	ld	ra,24(sp)
    80002b88:	6442                	ld	s0,16(sp)
    80002b8a:	64a2                	ld	s1,8(sp)
    80002b8c:	6902                	ld	s2,0(sp)
    80002b8e:	6105                	addi	sp,sp,32
    80002b90:	8082                	ret
    return -1;
    80002b92:	557d                	li	a0,-1
    80002b94:	bfcd                	j	80002b86 <fetchaddr+0x3e>
    80002b96:	557d                	li	a0,-1
    80002b98:	b7fd                	j	80002b86 <fetchaddr+0x3e>

0000000080002b9a <fetchstr>:
{
    80002b9a:	7179                	addi	sp,sp,-48
    80002b9c:	f406                	sd	ra,40(sp)
    80002b9e:	f022                	sd	s0,32(sp)
    80002ba0:	ec26                	sd	s1,24(sp)
    80002ba2:	e84a                	sd	s2,16(sp)
    80002ba4:	e44e                	sd	s3,8(sp)
    80002ba6:	1800                	addi	s0,sp,48
    80002ba8:	892a                	mv	s2,a0
    80002baa:	84ae                	mv	s1,a1
    80002bac:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80002bae:	fffff097          	auipc	ra,0xfffff
    80002bb2:	e34080e7          	jalr	-460(ra) # 800019e2 <myproc>
  if(copyinstr(p->pagetable, buf, addr, max) < 0)
    80002bb6:	86ce                	mv	a3,s3
    80002bb8:	864a                	mv	a2,s2
    80002bba:	85a6                	mv	a1,s1
    80002bbc:	6928                	ld	a0,80(a0)
    80002bbe:	fffff097          	auipc	ra,0xfffff
    80002bc2:	bee080e7          	jalr	-1042(ra) # 800017ac <copyinstr>
    80002bc6:	00054e63          	bltz	a0,80002be2 <fetchstr+0x48>
  return strlen(buf);
    80002bca:	8526                	mv	a0,s1
    80002bcc:	ffffe097          	auipc	ra,0xffffe
    80002bd0:	27c080e7          	jalr	636(ra) # 80000e48 <strlen>
}
    80002bd4:	70a2                	ld	ra,40(sp)
    80002bd6:	7402                	ld	s0,32(sp)
    80002bd8:	64e2                	ld	s1,24(sp)
    80002bda:	6942                	ld	s2,16(sp)
    80002bdc:	69a2                	ld	s3,8(sp)
    80002bde:	6145                	addi	sp,sp,48
    80002be0:	8082                	ret
    return -1;
    80002be2:	557d                	li	a0,-1
    80002be4:	bfc5                	j	80002bd4 <fetchstr+0x3a>

0000000080002be6 <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    80002be6:	1101                	addi	sp,sp,-32
    80002be8:	ec06                	sd	ra,24(sp)
    80002bea:	e822                	sd	s0,16(sp)
    80002bec:	e426                	sd	s1,8(sp)
    80002bee:	1000                	addi	s0,sp,32
    80002bf0:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002bf2:	00000097          	auipc	ra,0x0
    80002bf6:	eee080e7          	jalr	-274(ra) # 80002ae0 <argraw>
    80002bfa:	c088                	sw	a0,0(s1)
}
    80002bfc:	60e2                	ld	ra,24(sp)
    80002bfe:	6442                	ld	s0,16(sp)
    80002c00:	64a2                	ld	s1,8(sp)
    80002c02:	6105                	addi	sp,sp,32
    80002c04:	8082                	ret

0000000080002c06 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    80002c06:	1101                	addi	sp,sp,-32
    80002c08:	ec06                	sd	ra,24(sp)
    80002c0a:	e822                	sd	s0,16(sp)
    80002c0c:	e426                	sd	s1,8(sp)
    80002c0e:	1000                	addi	s0,sp,32
    80002c10:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002c12:	00000097          	auipc	ra,0x0
    80002c16:	ece080e7          	jalr	-306(ra) # 80002ae0 <argraw>
    80002c1a:	e088                	sd	a0,0(s1)
}
    80002c1c:	60e2                	ld	ra,24(sp)
    80002c1e:	6442                	ld	s0,16(sp)
    80002c20:	64a2                	ld	s1,8(sp)
    80002c22:	6105                	addi	sp,sp,32
    80002c24:	8082                	ret

0000000080002c26 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002c26:	7179                	addi	sp,sp,-48
    80002c28:	f406                	sd	ra,40(sp)
    80002c2a:	f022                	sd	s0,32(sp)
    80002c2c:	ec26                	sd	s1,24(sp)
    80002c2e:	e84a                	sd	s2,16(sp)
    80002c30:	1800                	addi	s0,sp,48
    80002c32:	84ae                	mv	s1,a1
    80002c34:	8932                	mv	s2,a2
  uint64 addr;
  argaddr(n, &addr);
    80002c36:	fd840593          	addi	a1,s0,-40
    80002c3a:	00000097          	auipc	ra,0x0
    80002c3e:	fcc080e7          	jalr	-52(ra) # 80002c06 <argaddr>
  return fetchstr(addr, buf, max);
    80002c42:	864a                	mv	a2,s2
    80002c44:	85a6                	mv	a1,s1
    80002c46:	fd843503          	ld	a0,-40(s0)
    80002c4a:	00000097          	auipc	ra,0x0
    80002c4e:	f50080e7          	jalr	-176(ra) # 80002b9a <fetchstr>
}
    80002c52:	70a2                	ld	ra,40(sp)
    80002c54:	7402                	ld	s0,32(sp)
    80002c56:	64e2                	ld	s1,24(sp)
    80002c58:	6942                	ld	s2,16(sp)
    80002c5a:	6145                	addi	sp,sp,48
    80002c5c:	8082                	ret

0000000080002c5e <syscall>:
[SYS_close]   sys_close,
};

void
syscall(void)
{
    80002c5e:	1101                	addi	sp,sp,-32
    80002c60:	ec06                	sd	ra,24(sp)
    80002c62:	e822                	sd	s0,16(sp)
    80002c64:	e426                	sd	s1,8(sp)
    80002c66:	e04a                	sd	s2,0(sp)
    80002c68:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80002c6a:	fffff097          	auipc	ra,0xfffff
    80002c6e:	d78080e7          	jalr	-648(ra) # 800019e2 <myproc>
    80002c72:	84aa                	mv	s1,a0
  num = p->trapframe->a7;
    80002c74:	05853903          	ld	s2,88(a0)
    80002c78:	0a893783          	ld	a5,168(s2)
    80002c7c:	0007869b          	sext.w	a3,a5
  
  /* Adil: debugging */
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002c80:	37fd                	addiw	a5,a5,-1
    80002c82:	4751                	li	a4,20
    80002c84:	00f76f63          	bltu	a4,a5,80002ca2 <syscall+0x44>
    80002c88:	00369713          	slli	a4,a3,0x3
    80002c8c:	00005797          	auipc	a5,0x5
    80002c90:	7ec78793          	addi	a5,a5,2028 # 80008478 <syscalls>
    80002c94:	97ba                	add	a5,a5,a4
    80002c96:	639c                	ld	a5,0(a5)
    80002c98:	c789                	beqz	a5,80002ca2 <syscall+0x44>
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    80002c9a:	9782                	jalr	a5
    80002c9c:	06a93823          	sd	a0,112(s2)
    80002ca0:	a839                	j	80002cbe <syscall+0x60>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80002ca2:	15848613          	addi	a2,s1,344
    80002ca6:	588c                	lw	a1,48(s1)
    80002ca8:	00005517          	auipc	a0,0x5
    80002cac:	79850513          	addi	a0,a0,1944 # 80008440 <states.0+0x150>
    80002cb0:	ffffe097          	auipc	ra,0xffffe
    80002cb4:	8d6080e7          	jalr	-1834(ra) # 80000586 <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80002cb8:	6cbc                	ld	a5,88(s1)
    80002cba:	577d                	li	a4,-1
    80002cbc:	fbb8                	sd	a4,112(a5)
  }
}
    80002cbe:	60e2                	ld	ra,24(sp)
    80002cc0:	6442                	ld	s0,16(sp)
    80002cc2:	64a2                	ld	s1,8(sp)
    80002cc4:	6902                	ld	s2,0(sp)
    80002cc6:	6105                	addi	sp,sp,32
    80002cc8:	8082                	ret

0000000080002cca <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    80002cca:	1101                	addi	sp,sp,-32
    80002ccc:	ec06                	sd	ra,24(sp)
    80002cce:	e822                	sd	s0,16(sp)
    80002cd0:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    80002cd2:	fec40593          	addi	a1,s0,-20
    80002cd6:	4501                	li	a0,0
    80002cd8:	00000097          	auipc	ra,0x0
    80002cdc:	f0e080e7          	jalr	-242(ra) # 80002be6 <argint>
  exit(n);
    80002ce0:	fec42503          	lw	a0,-20(s0)
    80002ce4:	fffff097          	auipc	ra,0xfffff
    80002ce8:	590080e7          	jalr	1424(ra) # 80002274 <exit>
  return 0;  // not reached
}
    80002cec:	4501                	li	a0,0
    80002cee:	60e2                	ld	ra,24(sp)
    80002cf0:	6442                	ld	s0,16(sp)
    80002cf2:	6105                	addi	sp,sp,32
    80002cf4:	8082                	ret

0000000080002cf6 <sys_getpid>:

uint64
sys_getpid(void)
{
    80002cf6:	1141                	addi	sp,sp,-16
    80002cf8:	e406                	sd	ra,8(sp)
    80002cfa:	e022                	sd	s0,0(sp)
    80002cfc:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80002cfe:	fffff097          	auipc	ra,0xfffff
    80002d02:	ce4080e7          	jalr	-796(ra) # 800019e2 <myproc>
}
    80002d06:	5908                	lw	a0,48(a0)
    80002d08:	60a2                	ld	ra,8(sp)
    80002d0a:	6402                	ld	s0,0(sp)
    80002d0c:	0141                	addi	sp,sp,16
    80002d0e:	8082                	ret

0000000080002d10 <sys_fork>:

uint64
sys_fork(void)
{
    80002d10:	1141                	addi	sp,sp,-16
    80002d12:	e406                	sd	ra,8(sp)
    80002d14:	e022                	sd	s0,0(sp)
    80002d16:	0800                	addi	s0,sp,16
  return fork();
    80002d18:	fffff097          	auipc	ra,0xfffff
    80002d1c:	118080e7          	jalr	280(ra) # 80001e30 <fork>
}
    80002d20:	60a2                	ld	ra,8(sp)
    80002d22:	6402                	ld	s0,0(sp)
    80002d24:	0141                	addi	sp,sp,16
    80002d26:	8082                	ret

0000000080002d28 <sys_wait>:

uint64
sys_wait(void)
{
    80002d28:	1101                	addi	sp,sp,-32
    80002d2a:	ec06                	sd	ra,24(sp)
    80002d2c:	e822                	sd	s0,16(sp)
    80002d2e:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    80002d30:	fe840593          	addi	a1,s0,-24
    80002d34:	4501                	li	a0,0
    80002d36:	00000097          	auipc	ra,0x0
    80002d3a:	ed0080e7          	jalr	-304(ra) # 80002c06 <argaddr>
  return wait(p);
    80002d3e:	fe843503          	ld	a0,-24(s0)
    80002d42:	fffff097          	auipc	ra,0xfffff
    80002d46:	6e0080e7          	jalr	1760(ra) # 80002422 <wait>
}
    80002d4a:	60e2                	ld	ra,24(sp)
    80002d4c:	6442                	ld	s0,16(sp)
    80002d4e:	6105                	addi	sp,sp,32
    80002d50:	8082                	ret

0000000080002d52 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002d52:	7179                	addi	sp,sp,-48
    80002d54:	f406                	sd	ra,40(sp)
    80002d56:	f022                	sd	s0,32(sp)
    80002d58:	ec26                	sd	s1,24(sp)
    80002d5a:	1800                	addi	s0,sp,48
  uint64 addr;
  int n;

  argint(0, &n);
    80002d5c:	fdc40593          	addi	a1,s0,-36
    80002d60:	4501                	li	a0,0
    80002d62:	00000097          	auipc	ra,0x0
    80002d66:	e84080e7          	jalr	-380(ra) # 80002be6 <argint>
  addr = myproc()->sz;
    80002d6a:	fffff097          	auipc	ra,0xfffff
    80002d6e:	c78080e7          	jalr	-904(ra) # 800019e2 <myproc>
    80002d72:	6524                	ld	s1,72(a0)
  if(growproc(n) < 0)
    80002d74:	fdc42503          	lw	a0,-36(s0)
    80002d78:	fffff097          	auipc	ra,0xfffff
    80002d7c:	012080e7          	jalr	18(ra) # 80001d8a <growproc>
    80002d80:	00054863          	bltz	a0,80002d90 <sys_sbrk+0x3e>
    return -1;

  return addr;
}
    80002d84:	8526                	mv	a0,s1
    80002d86:	70a2                	ld	ra,40(sp)
    80002d88:	7402                	ld	s0,32(sp)
    80002d8a:	64e2                	ld	s1,24(sp)
    80002d8c:	6145                	addi	sp,sp,48
    80002d8e:	8082                	ret
    return -1;
    80002d90:	54fd                	li	s1,-1
    80002d92:	bfcd                	j	80002d84 <sys_sbrk+0x32>

0000000080002d94 <sys_sleep>:

uint64
sys_sleep(void)
{
    80002d94:	7139                	addi	sp,sp,-64
    80002d96:	fc06                	sd	ra,56(sp)
    80002d98:	f822                	sd	s0,48(sp)
    80002d9a:	f426                	sd	s1,40(sp)
    80002d9c:	f04a                	sd	s2,32(sp)
    80002d9e:	ec4e                	sd	s3,24(sp)
    80002da0:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    80002da2:	fcc40593          	addi	a1,s0,-52
    80002da6:	4501                	li	a0,0
    80002da8:	00000097          	auipc	ra,0x0
    80002dac:	e3e080e7          	jalr	-450(ra) # 80002be6 <argint>
  acquire(&tickslock);
    80002db0:	0018b517          	auipc	a0,0x18b
    80002db4:	19050513          	addi	a0,a0,400 # 8018df40 <tickslock>
    80002db8:	ffffe097          	auipc	ra,0xffffe
    80002dbc:	e1a080e7          	jalr	-486(ra) # 80000bd2 <acquire>
  ticks0 = ticks;
    80002dc0:	00006917          	auipc	s2,0x6
    80002dc4:	ce092903          	lw	s2,-800(s2) # 80008aa0 <ticks>
  while(ticks - ticks0 < n){
    80002dc8:	fcc42783          	lw	a5,-52(s0)
    80002dcc:	cf9d                	beqz	a5,80002e0a <sys_sleep+0x76>
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80002dce:	0018b997          	auipc	s3,0x18b
    80002dd2:	17298993          	addi	s3,s3,370 # 8018df40 <tickslock>
    80002dd6:	00006497          	auipc	s1,0x6
    80002dda:	cca48493          	addi	s1,s1,-822 # 80008aa0 <ticks>
    if(killed(myproc())){
    80002dde:	fffff097          	auipc	ra,0xfffff
    80002de2:	c04080e7          	jalr	-1020(ra) # 800019e2 <myproc>
    80002de6:	fffff097          	auipc	ra,0xfffff
    80002dea:	60a080e7          	jalr	1546(ra) # 800023f0 <killed>
    80002dee:	ed15                	bnez	a0,80002e2a <sys_sleep+0x96>
    sleep(&ticks, &tickslock);
    80002df0:	85ce                	mv	a1,s3
    80002df2:	8526                	mv	a0,s1
    80002df4:	fffff097          	auipc	ra,0xfffff
    80002df8:	33c080e7          	jalr	828(ra) # 80002130 <sleep>
  while(ticks - ticks0 < n){
    80002dfc:	409c                	lw	a5,0(s1)
    80002dfe:	412787bb          	subw	a5,a5,s2
    80002e02:	fcc42703          	lw	a4,-52(s0)
    80002e06:	fce7ece3          	bltu	a5,a4,80002dde <sys_sleep+0x4a>
  }
  release(&tickslock);
    80002e0a:	0018b517          	auipc	a0,0x18b
    80002e0e:	13650513          	addi	a0,a0,310 # 8018df40 <tickslock>
    80002e12:	ffffe097          	auipc	ra,0xffffe
    80002e16:	e74080e7          	jalr	-396(ra) # 80000c86 <release>
  return 0;
    80002e1a:	4501                	li	a0,0
}
    80002e1c:	70e2                	ld	ra,56(sp)
    80002e1e:	7442                	ld	s0,48(sp)
    80002e20:	74a2                	ld	s1,40(sp)
    80002e22:	7902                	ld	s2,32(sp)
    80002e24:	69e2                	ld	s3,24(sp)
    80002e26:	6121                	addi	sp,sp,64
    80002e28:	8082                	ret
      release(&tickslock);
    80002e2a:	0018b517          	auipc	a0,0x18b
    80002e2e:	11650513          	addi	a0,a0,278 # 8018df40 <tickslock>
    80002e32:	ffffe097          	auipc	ra,0xffffe
    80002e36:	e54080e7          	jalr	-428(ra) # 80000c86 <release>
      return -1;
    80002e3a:	557d                	li	a0,-1
    80002e3c:	b7c5                	j	80002e1c <sys_sleep+0x88>

0000000080002e3e <sys_kill>:

uint64
sys_kill(void)
{
    80002e3e:	1101                	addi	sp,sp,-32
    80002e40:	ec06                	sd	ra,24(sp)
    80002e42:	e822                	sd	s0,16(sp)
    80002e44:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    80002e46:	fec40593          	addi	a1,s0,-20
    80002e4a:	4501                	li	a0,0
    80002e4c:	00000097          	auipc	ra,0x0
    80002e50:	d9a080e7          	jalr	-614(ra) # 80002be6 <argint>
  return kill(pid);
    80002e54:	fec42503          	lw	a0,-20(s0)
    80002e58:	fffff097          	auipc	ra,0xfffff
    80002e5c:	4f2080e7          	jalr	1266(ra) # 8000234a <kill>
}
    80002e60:	60e2                	ld	ra,24(sp)
    80002e62:	6442                	ld	s0,16(sp)
    80002e64:	6105                	addi	sp,sp,32
    80002e66:	8082                	ret

0000000080002e68 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80002e68:	1101                	addi	sp,sp,-32
    80002e6a:	ec06                	sd	ra,24(sp)
    80002e6c:	e822                	sd	s0,16(sp)
    80002e6e:	e426                	sd	s1,8(sp)
    80002e70:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80002e72:	0018b517          	auipc	a0,0x18b
    80002e76:	0ce50513          	addi	a0,a0,206 # 8018df40 <tickslock>
    80002e7a:	ffffe097          	auipc	ra,0xffffe
    80002e7e:	d58080e7          	jalr	-680(ra) # 80000bd2 <acquire>
  xticks = ticks;
    80002e82:	00006497          	auipc	s1,0x6
    80002e86:	c1e4a483          	lw	s1,-994(s1) # 80008aa0 <ticks>
  release(&tickslock);
    80002e8a:	0018b517          	auipc	a0,0x18b
    80002e8e:	0b650513          	addi	a0,a0,182 # 8018df40 <tickslock>
    80002e92:	ffffe097          	auipc	ra,0xffffe
    80002e96:	df4080e7          	jalr	-524(ra) # 80000c86 <release>
  return xticks;
}
    80002e9a:	02049513          	slli	a0,s1,0x20
    80002e9e:	9101                	srli	a0,a0,0x20
    80002ea0:	60e2                	ld	ra,24(sp)
    80002ea2:	6442                	ld	s0,16(sp)
    80002ea4:	64a2                	ld	s1,8(sp)
    80002ea6:	6105                	addi	sp,sp,32
    80002ea8:	8082                	ret

0000000080002eaa <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80002eaa:	7179                	addi	sp,sp,-48
    80002eac:	f406                	sd	ra,40(sp)
    80002eae:	f022                	sd	s0,32(sp)
    80002eb0:	ec26                	sd	s1,24(sp)
    80002eb2:	e84a                	sd	s2,16(sp)
    80002eb4:	e44e                	sd	s3,8(sp)
    80002eb6:	e052                	sd	s4,0(sp)
    80002eb8:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80002eba:	00005597          	auipc	a1,0x5
    80002ebe:	66e58593          	addi	a1,a1,1646 # 80008528 <syscalls+0xb0>
    80002ec2:	0018b517          	auipc	a0,0x18b
    80002ec6:	09650513          	addi	a0,a0,150 # 8018df58 <bcache>
    80002eca:	ffffe097          	auipc	ra,0xffffe
    80002ece:	c78080e7          	jalr	-904(ra) # 80000b42 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80002ed2:	00193797          	auipc	a5,0x193
    80002ed6:	08678793          	addi	a5,a5,134 # 80195f58 <bcache+0x8000>
    80002eda:	00193717          	auipc	a4,0x193
    80002ede:	2e670713          	addi	a4,a4,742 # 801961c0 <bcache+0x8268>
    80002ee2:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80002ee6:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002eea:	0018b497          	auipc	s1,0x18b
    80002eee:	08648493          	addi	s1,s1,134 # 8018df70 <bcache+0x18>
    b->next = bcache.head.next;
    80002ef2:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80002ef4:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80002ef6:	00005a17          	auipc	s4,0x5
    80002efa:	63aa0a13          	addi	s4,s4,1594 # 80008530 <syscalls+0xb8>
    b->next = bcache.head.next;
    80002efe:	2b893783          	ld	a5,696(s2)
    80002f02:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80002f04:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80002f08:	85d2                	mv	a1,s4
    80002f0a:	01048513          	addi	a0,s1,16
    80002f0e:	00001097          	auipc	ra,0x1
    80002f12:	496080e7          	jalr	1174(ra) # 800043a4 <initsleeplock>
    bcache.head.next->prev = b;
    80002f16:	2b893783          	ld	a5,696(s2)
    80002f1a:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80002f1c:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002f20:	45848493          	addi	s1,s1,1112
    80002f24:	fd349de3          	bne	s1,s3,80002efe <binit+0x54>
  }
}
    80002f28:	70a2                	ld	ra,40(sp)
    80002f2a:	7402                	ld	s0,32(sp)
    80002f2c:	64e2                	ld	s1,24(sp)
    80002f2e:	6942                	ld	s2,16(sp)
    80002f30:	69a2                	ld	s3,8(sp)
    80002f32:	6a02                	ld	s4,0(sp)
    80002f34:	6145                	addi	sp,sp,48
    80002f36:	8082                	ret

0000000080002f38 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80002f38:	7179                	addi	sp,sp,-48
    80002f3a:	f406                	sd	ra,40(sp)
    80002f3c:	f022                	sd	s0,32(sp)
    80002f3e:	ec26                	sd	s1,24(sp)
    80002f40:	e84a                	sd	s2,16(sp)
    80002f42:	e44e                	sd	s3,8(sp)
    80002f44:	1800                	addi	s0,sp,48
    80002f46:	892a                	mv	s2,a0
    80002f48:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    80002f4a:	0018b517          	auipc	a0,0x18b
    80002f4e:	00e50513          	addi	a0,a0,14 # 8018df58 <bcache>
    80002f52:	ffffe097          	auipc	ra,0xffffe
    80002f56:	c80080e7          	jalr	-896(ra) # 80000bd2 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80002f5a:	00193497          	auipc	s1,0x193
    80002f5e:	2b64b483          	ld	s1,694(s1) # 80196210 <bcache+0x82b8>
    80002f62:	00193797          	auipc	a5,0x193
    80002f66:	25e78793          	addi	a5,a5,606 # 801961c0 <bcache+0x8268>
    80002f6a:	02f48f63          	beq	s1,a5,80002fa8 <bread+0x70>
    80002f6e:	873e                	mv	a4,a5
    80002f70:	a021                	j	80002f78 <bread+0x40>
    80002f72:	68a4                	ld	s1,80(s1)
    80002f74:	02e48a63          	beq	s1,a4,80002fa8 <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    80002f78:	449c                	lw	a5,8(s1)
    80002f7a:	ff279ce3          	bne	a5,s2,80002f72 <bread+0x3a>
    80002f7e:	44dc                	lw	a5,12(s1)
    80002f80:	ff3799e3          	bne	a5,s3,80002f72 <bread+0x3a>
      b->refcnt++;
    80002f84:	40bc                	lw	a5,64(s1)
    80002f86:	2785                	addiw	a5,a5,1
    80002f88:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002f8a:	0018b517          	auipc	a0,0x18b
    80002f8e:	fce50513          	addi	a0,a0,-50 # 8018df58 <bcache>
    80002f92:	ffffe097          	auipc	ra,0xffffe
    80002f96:	cf4080e7          	jalr	-780(ra) # 80000c86 <release>
      acquiresleep(&b->lock);
    80002f9a:	01048513          	addi	a0,s1,16
    80002f9e:	00001097          	auipc	ra,0x1
    80002fa2:	440080e7          	jalr	1088(ra) # 800043de <acquiresleep>
      return b;
    80002fa6:	a8b9                	j	80003004 <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002fa8:	00193497          	auipc	s1,0x193
    80002fac:	2604b483          	ld	s1,608(s1) # 80196208 <bcache+0x82b0>
    80002fb0:	00193797          	auipc	a5,0x193
    80002fb4:	21078793          	addi	a5,a5,528 # 801961c0 <bcache+0x8268>
    80002fb8:	00f48863          	beq	s1,a5,80002fc8 <bread+0x90>
    80002fbc:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80002fbe:	40bc                	lw	a5,64(s1)
    80002fc0:	cf81                	beqz	a5,80002fd8 <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002fc2:	64a4                	ld	s1,72(s1)
    80002fc4:	fee49de3          	bne	s1,a4,80002fbe <bread+0x86>
  panic("bget: no buffers");
    80002fc8:	00005517          	auipc	a0,0x5
    80002fcc:	57050513          	addi	a0,a0,1392 # 80008538 <syscalls+0xc0>
    80002fd0:	ffffd097          	auipc	ra,0xffffd
    80002fd4:	56c080e7          	jalr	1388(ra) # 8000053c <panic>
      b->dev = dev;
    80002fd8:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80002fdc:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80002fe0:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80002fe4:	4785                	li	a5,1
    80002fe6:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002fe8:	0018b517          	auipc	a0,0x18b
    80002fec:	f7050513          	addi	a0,a0,-144 # 8018df58 <bcache>
    80002ff0:	ffffe097          	auipc	ra,0xffffe
    80002ff4:	c96080e7          	jalr	-874(ra) # 80000c86 <release>
      acquiresleep(&b->lock);
    80002ff8:	01048513          	addi	a0,s1,16
    80002ffc:	00001097          	auipc	ra,0x1
    80003000:	3e2080e7          	jalr	994(ra) # 800043de <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80003004:	409c                	lw	a5,0(s1)
    80003006:	cb89                	beqz	a5,80003018 <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80003008:	8526                	mv	a0,s1
    8000300a:	70a2                	ld	ra,40(sp)
    8000300c:	7402                	ld	s0,32(sp)
    8000300e:	64e2                	ld	s1,24(sp)
    80003010:	6942                	ld	s2,16(sp)
    80003012:	69a2                	ld	s3,8(sp)
    80003014:	6145                	addi	sp,sp,48
    80003016:	8082                	ret
    virtio_disk_rw(b, 0);
    80003018:	4581                	li	a1,0
    8000301a:	8526                	mv	a0,s1
    8000301c:	00003097          	auipc	ra,0x3
    80003020:	fe6080e7          	jalr	-26(ra) # 80006002 <virtio_disk_rw>
    b->valid = 1;
    80003024:	4785                	li	a5,1
    80003026:	c09c                	sw	a5,0(s1)
  return b;
    80003028:	b7c5                	j	80003008 <bread+0xd0>

000000008000302a <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    8000302a:	1101                	addi	sp,sp,-32
    8000302c:	ec06                	sd	ra,24(sp)
    8000302e:	e822                	sd	s0,16(sp)
    80003030:	e426                	sd	s1,8(sp)
    80003032:	1000                	addi	s0,sp,32
    80003034:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80003036:	0541                	addi	a0,a0,16
    80003038:	00001097          	auipc	ra,0x1
    8000303c:	440080e7          	jalr	1088(ra) # 80004478 <holdingsleep>
    80003040:	cd01                	beqz	a0,80003058 <bwrite+0x2e>
    panic("bwrite");

  virtio_disk_rw(b, 1);
    80003042:	4585                	li	a1,1
    80003044:	8526                	mv	a0,s1
    80003046:	00003097          	auipc	ra,0x3
    8000304a:	fbc080e7          	jalr	-68(ra) # 80006002 <virtio_disk_rw>
}
    8000304e:	60e2                	ld	ra,24(sp)
    80003050:	6442                	ld	s0,16(sp)
    80003052:	64a2                	ld	s1,8(sp)
    80003054:	6105                	addi	sp,sp,32
    80003056:	8082                	ret
    panic("bwrite");
    80003058:	00005517          	auipc	a0,0x5
    8000305c:	4f850513          	addi	a0,a0,1272 # 80008550 <syscalls+0xd8>
    80003060:	ffffd097          	auipc	ra,0xffffd
    80003064:	4dc080e7          	jalr	1244(ra) # 8000053c <panic>

0000000080003068 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80003068:	1101                	addi	sp,sp,-32
    8000306a:	ec06                	sd	ra,24(sp)
    8000306c:	e822                	sd	s0,16(sp)
    8000306e:	e426                	sd	s1,8(sp)
    80003070:	e04a                	sd	s2,0(sp)
    80003072:	1000                	addi	s0,sp,32
    80003074:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80003076:	01050913          	addi	s2,a0,16
    8000307a:	854a                	mv	a0,s2
    8000307c:	00001097          	auipc	ra,0x1
    80003080:	3fc080e7          	jalr	1020(ra) # 80004478 <holdingsleep>
    80003084:	c925                	beqz	a0,800030f4 <brelse+0x8c>
    panic("brelse");

  releasesleep(&b->lock);
    80003086:	854a                	mv	a0,s2
    80003088:	00001097          	auipc	ra,0x1
    8000308c:	3ac080e7          	jalr	940(ra) # 80004434 <releasesleep>

  acquire(&bcache.lock);
    80003090:	0018b517          	auipc	a0,0x18b
    80003094:	ec850513          	addi	a0,a0,-312 # 8018df58 <bcache>
    80003098:	ffffe097          	auipc	ra,0xffffe
    8000309c:	b3a080e7          	jalr	-1222(ra) # 80000bd2 <acquire>
  b->refcnt--;
    800030a0:	40bc                	lw	a5,64(s1)
    800030a2:	37fd                	addiw	a5,a5,-1
    800030a4:	0007871b          	sext.w	a4,a5
    800030a8:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    800030aa:	e71d                	bnez	a4,800030d8 <brelse+0x70>
    // no one is waiting for it.
    b->next->prev = b->prev;
    800030ac:	68b8                	ld	a4,80(s1)
    800030ae:	64bc                	ld	a5,72(s1)
    800030b0:	e73c                	sd	a5,72(a4)
    b->prev->next = b->next;
    800030b2:	68b8                	ld	a4,80(s1)
    800030b4:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    800030b6:	00193797          	auipc	a5,0x193
    800030ba:	ea278793          	addi	a5,a5,-350 # 80195f58 <bcache+0x8000>
    800030be:	2b87b703          	ld	a4,696(a5)
    800030c2:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    800030c4:	00193717          	auipc	a4,0x193
    800030c8:	0fc70713          	addi	a4,a4,252 # 801961c0 <bcache+0x8268>
    800030cc:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    800030ce:	2b87b703          	ld	a4,696(a5)
    800030d2:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    800030d4:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    800030d8:	0018b517          	auipc	a0,0x18b
    800030dc:	e8050513          	addi	a0,a0,-384 # 8018df58 <bcache>
    800030e0:	ffffe097          	auipc	ra,0xffffe
    800030e4:	ba6080e7          	jalr	-1114(ra) # 80000c86 <release>
}
    800030e8:	60e2                	ld	ra,24(sp)
    800030ea:	6442                	ld	s0,16(sp)
    800030ec:	64a2                	ld	s1,8(sp)
    800030ee:	6902                	ld	s2,0(sp)
    800030f0:	6105                	addi	sp,sp,32
    800030f2:	8082                	ret
    panic("brelse");
    800030f4:	00005517          	auipc	a0,0x5
    800030f8:	46450513          	addi	a0,a0,1124 # 80008558 <syscalls+0xe0>
    800030fc:	ffffd097          	auipc	ra,0xffffd
    80003100:	440080e7          	jalr	1088(ra) # 8000053c <panic>

0000000080003104 <bpin>:

void
bpin(struct buf *b) {
    80003104:	1101                	addi	sp,sp,-32
    80003106:	ec06                	sd	ra,24(sp)
    80003108:	e822                	sd	s0,16(sp)
    8000310a:	e426                	sd	s1,8(sp)
    8000310c:	1000                	addi	s0,sp,32
    8000310e:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003110:	0018b517          	auipc	a0,0x18b
    80003114:	e4850513          	addi	a0,a0,-440 # 8018df58 <bcache>
    80003118:	ffffe097          	auipc	ra,0xffffe
    8000311c:	aba080e7          	jalr	-1350(ra) # 80000bd2 <acquire>
  b->refcnt++;
    80003120:	40bc                	lw	a5,64(s1)
    80003122:	2785                	addiw	a5,a5,1
    80003124:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80003126:	0018b517          	auipc	a0,0x18b
    8000312a:	e3250513          	addi	a0,a0,-462 # 8018df58 <bcache>
    8000312e:	ffffe097          	auipc	ra,0xffffe
    80003132:	b58080e7          	jalr	-1192(ra) # 80000c86 <release>
}
    80003136:	60e2                	ld	ra,24(sp)
    80003138:	6442                	ld	s0,16(sp)
    8000313a:	64a2                	ld	s1,8(sp)
    8000313c:	6105                	addi	sp,sp,32
    8000313e:	8082                	ret

0000000080003140 <bunpin>:

void
bunpin(struct buf *b) {
    80003140:	1101                	addi	sp,sp,-32
    80003142:	ec06                	sd	ra,24(sp)
    80003144:	e822                	sd	s0,16(sp)
    80003146:	e426                	sd	s1,8(sp)
    80003148:	1000                	addi	s0,sp,32
    8000314a:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    8000314c:	0018b517          	auipc	a0,0x18b
    80003150:	e0c50513          	addi	a0,a0,-500 # 8018df58 <bcache>
    80003154:	ffffe097          	auipc	ra,0xffffe
    80003158:	a7e080e7          	jalr	-1410(ra) # 80000bd2 <acquire>
  b->refcnt--;
    8000315c:	40bc                	lw	a5,64(s1)
    8000315e:	37fd                	addiw	a5,a5,-1
    80003160:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80003162:	0018b517          	auipc	a0,0x18b
    80003166:	df650513          	addi	a0,a0,-522 # 8018df58 <bcache>
    8000316a:	ffffe097          	auipc	ra,0xffffe
    8000316e:	b1c080e7          	jalr	-1252(ra) # 80000c86 <release>
}
    80003172:	60e2                	ld	ra,24(sp)
    80003174:	6442                	ld	s0,16(sp)
    80003176:	64a2                	ld	s1,8(sp)
    80003178:	6105                	addi	sp,sp,32
    8000317a:	8082                	ret

000000008000317c <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    8000317c:	1101                	addi	sp,sp,-32
    8000317e:	ec06                	sd	ra,24(sp)
    80003180:	e822                	sd	s0,16(sp)
    80003182:	e426                	sd	s1,8(sp)
    80003184:	e04a                	sd	s2,0(sp)
    80003186:	1000                	addi	s0,sp,32
    80003188:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    8000318a:	00d5d59b          	srliw	a1,a1,0xd
    8000318e:	00193797          	auipc	a5,0x193
    80003192:	4a67a783          	lw	a5,1190(a5) # 80196634 <sb+0x1c>
    80003196:	9dbd                	addw	a1,a1,a5
    80003198:	00000097          	auipc	ra,0x0
    8000319c:	da0080e7          	jalr	-608(ra) # 80002f38 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    800031a0:	0074f713          	andi	a4,s1,7
    800031a4:	4785                	li	a5,1
    800031a6:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    800031aa:	14ce                	slli	s1,s1,0x33
    800031ac:	90d9                	srli	s1,s1,0x36
    800031ae:	00950733          	add	a4,a0,s1
    800031b2:	05874703          	lbu	a4,88(a4)
    800031b6:	00e7f6b3          	and	a3,a5,a4
    800031ba:	c69d                	beqz	a3,800031e8 <bfree+0x6c>
    800031bc:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    800031be:	94aa                	add	s1,s1,a0
    800031c0:	fff7c793          	not	a5,a5
    800031c4:	8f7d                	and	a4,a4,a5
    800031c6:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    800031ca:	00001097          	auipc	ra,0x1
    800031ce:	0f6080e7          	jalr	246(ra) # 800042c0 <log_write>
  brelse(bp);
    800031d2:	854a                	mv	a0,s2
    800031d4:	00000097          	auipc	ra,0x0
    800031d8:	e94080e7          	jalr	-364(ra) # 80003068 <brelse>
}
    800031dc:	60e2                	ld	ra,24(sp)
    800031de:	6442                	ld	s0,16(sp)
    800031e0:	64a2                	ld	s1,8(sp)
    800031e2:	6902                	ld	s2,0(sp)
    800031e4:	6105                	addi	sp,sp,32
    800031e6:	8082                	ret
    panic("freeing free block");
    800031e8:	00005517          	auipc	a0,0x5
    800031ec:	37850513          	addi	a0,a0,888 # 80008560 <syscalls+0xe8>
    800031f0:	ffffd097          	auipc	ra,0xffffd
    800031f4:	34c080e7          	jalr	844(ra) # 8000053c <panic>

00000000800031f8 <balloc>:
{
    800031f8:	711d                	addi	sp,sp,-96
    800031fa:	ec86                	sd	ra,88(sp)
    800031fc:	e8a2                	sd	s0,80(sp)
    800031fe:	e4a6                	sd	s1,72(sp)
    80003200:	e0ca                	sd	s2,64(sp)
    80003202:	fc4e                	sd	s3,56(sp)
    80003204:	f852                	sd	s4,48(sp)
    80003206:	f456                	sd	s5,40(sp)
    80003208:	f05a                	sd	s6,32(sp)
    8000320a:	ec5e                	sd	s7,24(sp)
    8000320c:	e862                	sd	s8,16(sp)
    8000320e:	e466                	sd	s9,8(sp)
    80003210:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    80003212:	00193797          	auipc	a5,0x193
    80003216:	40a7a783          	lw	a5,1034(a5) # 8019661c <sb+0x4>
    8000321a:	cff5                	beqz	a5,80003316 <balloc+0x11e>
    8000321c:	8baa                	mv	s7,a0
    8000321e:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80003220:	00193b17          	auipc	s6,0x193
    80003224:	3f8b0b13          	addi	s6,s6,1016 # 80196618 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003228:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    8000322a:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000322c:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    8000322e:	6c89                	lui	s9,0x2
    80003230:	a061                	j	800032b8 <balloc+0xc0>
        bp->data[bi/8] |= m;  // Mark block in use.
    80003232:	97ca                	add	a5,a5,s2
    80003234:	8e55                	or	a2,a2,a3
    80003236:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    8000323a:	854a                	mv	a0,s2
    8000323c:	00001097          	auipc	ra,0x1
    80003240:	084080e7          	jalr	132(ra) # 800042c0 <log_write>
        brelse(bp);
    80003244:	854a                	mv	a0,s2
    80003246:	00000097          	auipc	ra,0x0
    8000324a:	e22080e7          	jalr	-478(ra) # 80003068 <brelse>
  bp = bread(dev, bno);
    8000324e:	85a6                	mv	a1,s1
    80003250:	855e                	mv	a0,s7
    80003252:	00000097          	auipc	ra,0x0
    80003256:	ce6080e7          	jalr	-794(ra) # 80002f38 <bread>
    8000325a:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    8000325c:	40000613          	li	a2,1024
    80003260:	4581                	li	a1,0
    80003262:	05850513          	addi	a0,a0,88
    80003266:	ffffe097          	auipc	ra,0xffffe
    8000326a:	a68080e7          	jalr	-1432(ra) # 80000cce <memset>
  log_write(bp);
    8000326e:	854a                	mv	a0,s2
    80003270:	00001097          	auipc	ra,0x1
    80003274:	050080e7          	jalr	80(ra) # 800042c0 <log_write>
  brelse(bp);
    80003278:	854a                	mv	a0,s2
    8000327a:	00000097          	auipc	ra,0x0
    8000327e:	dee080e7          	jalr	-530(ra) # 80003068 <brelse>
}
    80003282:	8526                	mv	a0,s1
    80003284:	60e6                	ld	ra,88(sp)
    80003286:	6446                	ld	s0,80(sp)
    80003288:	64a6                	ld	s1,72(sp)
    8000328a:	6906                	ld	s2,64(sp)
    8000328c:	79e2                	ld	s3,56(sp)
    8000328e:	7a42                	ld	s4,48(sp)
    80003290:	7aa2                	ld	s5,40(sp)
    80003292:	7b02                	ld	s6,32(sp)
    80003294:	6be2                	ld	s7,24(sp)
    80003296:	6c42                	ld	s8,16(sp)
    80003298:	6ca2                	ld	s9,8(sp)
    8000329a:	6125                	addi	sp,sp,96
    8000329c:	8082                	ret
    brelse(bp);
    8000329e:	854a                	mv	a0,s2
    800032a0:	00000097          	auipc	ra,0x0
    800032a4:	dc8080e7          	jalr	-568(ra) # 80003068 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    800032a8:	015c87bb          	addw	a5,s9,s5
    800032ac:	00078a9b          	sext.w	s5,a5
    800032b0:	004b2703          	lw	a4,4(s6)
    800032b4:	06eaf163          	bgeu	s5,a4,80003316 <balloc+0x11e>
    bp = bread(dev, BBLOCK(b, sb));
    800032b8:	41fad79b          	sraiw	a5,s5,0x1f
    800032bc:	0137d79b          	srliw	a5,a5,0x13
    800032c0:	015787bb          	addw	a5,a5,s5
    800032c4:	40d7d79b          	sraiw	a5,a5,0xd
    800032c8:	01cb2583          	lw	a1,28(s6)
    800032cc:	9dbd                	addw	a1,a1,a5
    800032ce:	855e                	mv	a0,s7
    800032d0:	00000097          	auipc	ra,0x0
    800032d4:	c68080e7          	jalr	-920(ra) # 80002f38 <bread>
    800032d8:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800032da:	004b2503          	lw	a0,4(s6)
    800032de:	000a849b          	sext.w	s1,s5
    800032e2:	8762                	mv	a4,s8
    800032e4:	faa4fde3          	bgeu	s1,a0,8000329e <balloc+0xa6>
      m = 1 << (bi % 8);
    800032e8:	00777693          	andi	a3,a4,7
    800032ec:	00d996bb          	sllw	a3,s3,a3
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    800032f0:	41f7579b          	sraiw	a5,a4,0x1f
    800032f4:	01d7d79b          	srliw	a5,a5,0x1d
    800032f8:	9fb9                	addw	a5,a5,a4
    800032fa:	4037d79b          	sraiw	a5,a5,0x3
    800032fe:	00f90633          	add	a2,s2,a5
    80003302:	05864603          	lbu	a2,88(a2)
    80003306:	00c6f5b3          	and	a1,a3,a2
    8000330a:	d585                	beqz	a1,80003232 <balloc+0x3a>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000330c:	2705                	addiw	a4,a4,1
    8000330e:	2485                	addiw	s1,s1,1
    80003310:	fd471ae3          	bne	a4,s4,800032e4 <balloc+0xec>
    80003314:	b769                	j	8000329e <balloc+0xa6>
  printf("balloc: out of blocks\n");
    80003316:	00005517          	auipc	a0,0x5
    8000331a:	26250513          	addi	a0,a0,610 # 80008578 <syscalls+0x100>
    8000331e:	ffffd097          	auipc	ra,0xffffd
    80003322:	268080e7          	jalr	616(ra) # 80000586 <printf>
  return 0;
    80003326:	4481                	li	s1,0
    80003328:	bfa9                	j	80003282 <balloc+0x8a>

000000008000332a <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    8000332a:	7179                	addi	sp,sp,-48
    8000332c:	f406                	sd	ra,40(sp)
    8000332e:	f022                	sd	s0,32(sp)
    80003330:	ec26                	sd	s1,24(sp)
    80003332:	e84a                	sd	s2,16(sp)
    80003334:	e44e                	sd	s3,8(sp)
    80003336:	e052                	sd	s4,0(sp)
    80003338:	1800                	addi	s0,sp,48
    8000333a:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    8000333c:	47ad                	li	a5,11
    8000333e:	02b7e863          	bltu	a5,a1,8000336e <bmap+0x44>
    if((addr = ip->addrs[bn]) == 0){
    80003342:	02059793          	slli	a5,a1,0x20
    80003346:	01e7d593          	srli	a1,a5,0x1e
    8000334a:	00b504b3          	add	s1,a0,a1
    8000334e:	0504a903          	lw	s2,80(s1)
    80003352:	06091e63          	bnez	s2,800033ce <bmap+0xa4>
      addr = balloc(ip->dev);
    80003356:	4108                	lw	a0,0(a0)
    80003358:	00000097          	auipc	ra,0x0
    8000335c:	ea0080e7          	jalr	-352(ra) # 800031f8 <balloc>
    80003360:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80003364:	06090563          	beqz	s2,800033ce <bmap+0xa4>
        return 0;
      ip->addrs[bn] = addr;
    80003368:	0524a823          	sw	s2,80(s1)
    8000336c:	a08d                	j	800033ce <bmap+0xa4>
    }
    return addr;
  }
  bn -= NDIRECT;
    8000336e:	ff45849b          	addiw	s1,a1,-12
    80003372:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    80003376:	0ff00793          	li	a5,255
    8000337a:	08e7e563          	bltu	a5,a4,80003404 <bmap+0xda>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    8000337e:	08052903          	lw	s2,128(a0)
    80003382:	00091d63          	bnez	s2,8000339c <bmap+0x72>
      addr = balloc(ip->dev);
    80003386:	4108                	lw	a0,0(a0)
    80003388:	00000097          	auipc	ra,0x0
    8000338c:	e70080e7          	jalr	-400(ra) # 800031f8 <balloc>
    80003390:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80003394:	02090d63          	beqz	s2,800033ce <bmap+0xa4>
        return 0;
      ip->addrs[NDIRECT] = addr;
    80003398:	0929a023          	sw	s2,128(s3)
    }
    bp = bread(ip->dev, addr);
    8000339c:	85ca                	mv	a1,s2
    8000339e:	0009a503          	lw	a0,0(s3)
    800033a2:	00000097          	auipc	ra,0x0
    800033a6:	b96080e7          	jalr	-1130(ra) # 80002f38 <bread>
    800033aa:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    800033ac:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    800033b0:	02049713          	slli	a4,s1,0x20
    800033b4:	01e75593          	srli	a1,a4,0x1e
    800033b8:	00b784b3          	add	s1,a5,a1
    800033bc:	0004a903          	lw	s2,0(s1)
    800033c0:	02090063          	beqz	s2,800033e0 <bmap+0xb6>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    800033c4:	8552                	mv	a0,s4
    800033c6:	00000097          	auipc	ra,0x0
    800033ca:	ca2080e7          	jalr	-862(ra) # 80003068 <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    800033ce:	854a                	mv	a0,s2
    800033d0:	70a2                	ld	ra,40(sp)
    800033d2:	7402                	ld	s0,32(sp)
    800033d4:	64e2                	ld	s1,24(sp)
    800033d6:	6942                	ld	s2,16(sp)
    800033d8:	69a2                	ld	s3,8(sp)
    800033da:	6a02                	ld	s4,0(sp)
    800033dc:	6145                	addi	sp,sp,48
    800033de:	8082                	ret
      addr = balloc(ip->dev);
    800033e0:	0009a503          	lw	a0,0(s3)
    800033e4:	00000097          	auipc	ra,0x0
    800033e8:	e14080e7          	jalr	-492(ra) # 800031f8 <balloc>
    800033ec:	0005091b          	sext.w	s2,a0
      if(addr){
    800033f0:	fc090ae3          	beqz	s2,800033c4 <bmap+0x9a>
        a[bn] = addr;
    800033f4:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    800033f8:	8552                	mv	a0,s4
    800033fa:	00001097          	auipc	ra,0x1
    800033fe:	ec6080e7          	jalr	-314(ra) # 800042c0 <log_write>
    80003402:	b7c9                	j	800033c4 <bmap+0x9a>
  panic("bmap: out of range");
    80003404:	00005517          	auipc	a0,0x5
    80003408:	18c50513          	addi	a0,a0,396 # 80008590 <syscalls+0x118>
    8000340c:	ffffd097          	auipc	ra,0xffffd
    80003410:	130080e7          	jalr	304(ra) # 8000053c <panic>

0000000080003414 <iget>:
{
    80003414:	7179                	addi	sp,sp,-48
    80003416:	f406                	sd	ra,40(sp)
    80003418:	f022                	sd	s0,32(sp)
    8000341a:	ec26                	sd	s1,24(sp)
    8000341c:	e84a                	sd	s2,16(sp)
    8000341e:	e44e                	sd	s3,8(sp)
    80003420:	e052                	sd	s4,0(sp)
    80003422:	1800                	addi	s0,sp,48
    80003424:	89aa                	mv	s3,a0
    80003426:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    80003428:	00193517          	auipc	a0,0x193
    8000342c:	21850513          	addi	a0,a0,536 # 80196640 <itable>
    80003430:	ffffd097          	auipc	ra,0xffffd
    80003434:	7a2080e7          	jalr	1954(ra) # 80000bd2 <acquire>
  empty = 0;
    80003438:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    8000343a:	00193497          	auipc	s1,0x193
    8000343e:	21e48493          	addi	s1,s1,542 # 80196658 <itable+0x18>
    80003442:	00195697          	auipc	a3,0x195
    80003446:	ca668693          	addi	a3,a3,-858 # 801980e8 <log>
    8000344a:	a039                	j	80003458 <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    8000344c:	02090b63          	beqz	s2,80003482 <iget+0x6e>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003450:	08848493          	addi	s1,s1,136
    80003454:	02d48a63          	beq	s1,a3,80003488 <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    80003458:	449c                	lw	a5,8(s1)
    8000345a:	fef059e3          	blez	a5,8000344c <iget+0x38>
    8000345e:	4098                	lw	a4,0(s1)
    80003460:	ff3716e3          	bne	a4,s3,8000344c <iget+0x38>
    80003464:	40d8                	lw	a4,4(s1)
    80003466:	ff4713e3          	bne	a4,s4,8000344c <iget+0x38>
      ip->ref++;
    8000346a:	2785                	addiw	a5,a5,1
    8000346c:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    8000346e:	00193517          	auipc	a0,0x193
    80003472:	1d250513          	addi	a0,a0,466 # 80196640 <itable>
    80003476:	ffffe097          	auipc	ra,0xffffe
    8000347a:	810080e7          	jalr	-2032(ra) # 80000c86 <release>
      return ip;
    8000347e:	8926                	mv	s2,s1
    80003480:	a03d                	j	800034ae <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003482:	f7f9                	bnez	a5,80003450 <iget+0x3c>
    80003484:	8926                	mv	s2,s1
    80003486:	b7e9                	j	80003450 <iget+0x3c>
  if(empty == 0)
    80003488:	02090c63          	beqz	s2,800034c0 <iget+0xac>
  ip->dev = dev;
    8000348c:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    80003490:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    80003494:	4785                	li	a5,1
    80003496:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    8000349a:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    8000349e:	00193517          	auipc	a0,0x193
    800034a2:	1a250513          	addi	a0,a0,418 # 80196640 <itable>
    800034a6:	ffffd097          	auipc	ra,0xffffd
    800034aa:	7e0080e7          	jalr	2016(ra) # 80000c86 <release>
}
    800034ae:	854a                	mv	a0,s2
    800034b0:	70a2                	ld	ra,40(sp)
    800034b2:	7402                	ld	s0,32(sp)
    800034b4:	64e2                	ld	s1,24(sp)
    800034b6:	6942                	ld	s2,16(sp)
    800034b8:	69a2                	ld	s3,8(sp)
    800034ba:	6a02                	ld	s4,0(sp)
    800034bc:	6145                	addi	sp,sp,48
    800034be:	8082                	ret
    panic("iget: no inodes");
    800034c0:	00005517          	auipc	a0,0x5
    800034c4:	0e850513          	addi	a0,a0,232 # 800085a8 <syscalls+0x130>
    800034c8:	ffffd097          	auipc	ra,0xffffd
    800034cc:	074080e7          	jalr	116(ra) # 8000053c <panic>

00000000800034d0 <fsinit>:
fsinit(int dev) {
    800034d0:	7179                	addi	sp,sp,-48
    800034d2:	f406                	sd	ra,40(sp)
    800034d4:	f022                	sd	s0,32(sp)
    800034d6:	ec26                	sd	s1,24(sp)
    800034d8:	e84a                	sd	s2,16(sp)
    800034da:	e44e                	sd	s3,8(sp)
    800034dc:	1800                	addi	s0,sp,48
    800034de:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    800034e0:	4585                	li	a1,1
    800034e2:	00000097          	auipc	ra,0x0
    800034e6:	a56080e7          	jalr	-1450(ra) # 80002f38 <bread>
    800034ea:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    800034ec:	00193997          	auipc	s3,0x193
    800034f0:	12c98993          	addi	s3,s3,300 # 80196618 <sb>
    800034f4:	02800613          	li	a2,40
    800034f8:	05850593          	addi	a1,a0,88
    800034fc:	854e                	mv	a0,s3
    800034fe:	ffffe097          	auipc	ra,0xffffe
    80003502:	82c080e7          	jalr	-2004(ra) # 80000d2a <memmove>
  brelse(bp);
    80003506:	8526                	mv	a0,s1
    80003508:	00000097          	auipc	ra,0x0
    8000350c:	b60080e7          	jalr	-1184(ra) # 80003068 <brelse>
  if(sb.magic != FSMAGIC)
    80003510:	0009a703          	lw	a4,0(s3)
    80003514:	102037b7          	lui	a5,0x10203
    80003518:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    8000351c:	02f71263          	bne	a4,a5,80003540 <fsinit+0x70>
  initlog(dev, &sb);
    80003520:	00193597          	auipc	a1,0x193
    80003524:	0f858593          	addi	a1,a1,248 # 80196618 <sb>
    80003528:	854a                	mv	a0,s2
    8000352a:	00001097          	auipc	ra,0x1
    8000352e:	b2c080e7          	jalr	-1236(ra) # 80004056 <initlog>
}
    80003532:	70a2                	ld	ra,40(sp)
    80003534:	7402                	ld	s0,32(sp)
    80003536:	64e2                	ld	s1,24(sp)
    80003538:	6942                	ld	s2,16(sp)
    8000353a:	69a2                	ld	s3,8(sp)
    8000353c:	6145                	addi	sp,sp,48
    8000353e:	8082                	ret
    panic("invalid file system");
    80003540:	00005517          	auipc	a0,0x5
    80003544:	07850513          	addi	a0,a0,120 # 800085b8 <syscalls+0x140>
    80003548:	ffffd097          	auipc	ra,0xffffd
    8000354c:	ff4080e7          	jalr	-12(ra) # 8000053c <panic>

0000000080003550 <iinit>:
{
    80003550:	7179                	addi	sp,sp,-48
    80003552:	f406                	sd	ra,40(sp)
    80003554:	f022                	sd	s0,32(sp)
    80003556:	ec26                	sd	s1,24(sp)
    80003558:	e84a                	sd	s2,16(sp)
    8000355a:	e44e                	sd	s3,8(sp)
    8000355c:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    8000355e:	00005597          	auipc	a1,0x5
    80003562:	07258593          	addi	a1,a1,114 # 800085d0 <syscalls+0x158>
    80003566:	00193517          	auipc	a0,0x193
    8000356a:	0da50513          	addi	a0,a0,218 # 80196640 <itable>
    8000356e:	ffffd097          	auipc	ra,0xffffd
    80003572:	5d4080e7          	jalr	1492(ra) # 80000b42 <initlock>
  for(i = 0; i < NINODE; i++) {
    80003576:	00193497          	auipc	s1,0x193
    8000357a:	0f248493          	addi	s1,s1,242 # 80196668 <itable+0x28>
    8000357e:	00195997          	auipc	s3,0x195
    80003582:	b7a98993          	addi	s3,s3,-1158 # 801980f8 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    80003586:	00005917          	auipc	s2,0x5
    8000358a:	05290913          	addi	s2,s2,82 # 800085d8 <syscalls+0x160>
    8000358e:	85ca                	mv	a1,s2
    80003590:	8526                	mv	a0,s1
    80003592:	00001097          	auipc	ra,0x1
    80003596:	e12080e7          	jalr	-494(ra) # 800043a4 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    8000359a:	08848493          	addi	s1,s1,136
    8000359e:	ff3498e3          	bne	s1,s3,8000358e <iinit+0x3e>
}
    800035a2:	70a2                	ld	ra,40(sp)
    800035a4:	7402                	ld	s0,32(sp)
    800035a6:	64e2                	ld	s1,24(sp)
    800035a8:	6942                	ld	s2,16(sp)
    800035aa:	69a2                	ld	s3,8(sp)
    800035ac:	6145                	addi	sp,sp,48
    800035ae:	8082                	ret

00000000800035b0 <ialloc>:
{
    800035b0:	7139                	addi	sp,sp,-64
    800035b2:	fc06                	sd	ra,56(sp)
    800035b4:	f822                	sd	s0,48(sp)
    800035b6:	f426                	sd	s1,40(sp)
    800035b8:	f04a                	sd	s2,32(sp)
    800035ba:	ec4e                	sd	s3,24(sp)
    800035bc:	e852                	sd	s4,16(sp)
    800035be:	e456                	sd	s5,8(sp)
    800035c0:	e05a                	sd	s6,0(sp)
    800035c2:	0080                	addi	s0,sp,64
  for(inum = 1; inum < sb.ninodes; inum++){
    800035c4:	00193717          	auipc	a4,0x193
    800035c8:	06072703          	lw	a4,96(a4) # 80196624 <sb+0xc>
    800035cc:	4785                	li	a5,1
    800035ce:	04e7f863          	bgeu	a5,a4,8000361e <ialloc+0x6e>
    800035d2:	8aaa                	mv	s5,a0
    800035d4:	8b2e                	mv	s6,a1
    800035d6:	4905                	li	s2,1
    bp = bread(dev, IBLOCK(inum, sb));
    800035d8:	00193a17          	auipc	s4,0x193
    800035dc:	040a0a13          	addi	s4,s4,64 # 80196618 <sb>
    800035e0:	00495593          	srli	a1,s2,0x4
    800035e4:	018a2783          	lw	a5,24(s4)
    800035e8:	9dbd                	addw	a1,a1,a5
    800035ea:	8556                	mv	a0,s5
    800035ec:	00000097          	auipc	ra,0x0
    800035f0:	94c080e7          	jalr	-1716(ra) # 80002f38 <bread>
    800035f4:	84aa                	mv	s1,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    800035f6:	05850993          	addi	s3,a0,88
    800035fa:	00f97793          	andi	a5,s2,15
    800035fe:	079a                	slli	a5,a5,0x6
    80003600:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    80003602:	00099783          	lh	a5,0(s3)
    80003606:	cf9d                	beqz	a5,80003644 <ialloc+0x94>
    brelse(bp);
    80003608:	00000097          	auipc	ra,0x0
    8000360c:	a60080e7          	jalr	-1440(ra) # 80003068 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    80003610:	0905                	addi	s2,s2,1
    80003612:	00ca2703          	lw	a4,12(s4)
    80003616:	0009079b          	sext.w	a5,s2
    8000361a:	fce7e3e3          	bltu	a5,a4,800035e0 <ialloc+0x30>
  printf("ialloc: no inodes\n");
    8000361e:	00005517          	auipc	a0,0x5
    80003622:	fc250513          	addi	a0,a0,-62 # 800085e0 <syscalls+0x168>
    80003626:	ffffd097          	auipc	ra,0xffffd
    8000362a:	f60080e7          	jalr	-160(ra) # 80000586 <printf>
  return 0;
    8000362e:	4501                	li	a0,0
}
    80003630:	70e2                	ld	ra,56(sp)
    80003632:	7442                	ld	s0,48(sp)
    80003634:	74a2                	ld	s1,40(sp)
    80003636:	7902                	ld	s2,32(sp)
    80003638:	69e2                	ld	s3,24(sp)
    8000363a:	6a42                	ld	s4,16(sp)
    8000363c:	6aa2                	ld	s5,8(sp)
    8000363e:	6b02                	ld	s6,0(sp)
    80003640:	6121                	addi	sp,sp,64
    80003642:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    80003644:	04000613          	li	a2,64
    80003648:	4581                	li	a1,0
    8000364a:	854e                	mv	a0,s3
    8000364c:	ffffd097          	auipc	ra,0xffffd
    80003650:	682080e7          	jalr	1666(ra) # 80000cce <memset>
      dip->type = type;
    80003654:	01699023          	sh	s6,0(s3)
      log_write(bp);   // mark it allocated on the disk
    80003658:	8526                	mv	a0,s1
    8000365a:	00001097          	auipc	ra,0x1
    8000365e:	c66080e7          	jalr	-922(ra) # 800042c0 <log_write>
      brelse(bp);
    80003662:	8526                	mv	a0,s1
    80003664:	00000097          	auipc	ra,0x0
    80003668:	a04080e7          	jalr	-1532(ra) # 80003068 <brelse>
      return iget(dev, inum);
    8000366c:	0009059b          	sext.w	a1,s2
    80003670:	8556                	mv	a0,s5
    80003672:	00000097          	auipc	ra,0x0
    80003676:	da2080e7          	jalr	-606(ra) # 80003414 <iget>
    8000367a:	bf5d                	j	80003630 <ialloc+0x80>

000000008000367c <iupdate>:
{
    8000367c:	1101                	addi	sp,sp,-32
    8000367e:	ec06                	sd	ra,24(sp)
    80003680:	e822                	sd	s0,16(sp)
    80003682:	e426                	sd	s1,8(sp)
    80003684:	e04a                	sd	s2,0(sp)
    80003686:	1000                	addi	s0,sp,32
    80003688:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    8000368a:	415c                	lw	a5,4(a0)
    8000368c:	0047d79b          	srliw	a5,a5,0x4
    80003690:	00193597          	auipc	a1,0x193
    80003694:	fa05a583          	lw	a1,-96(a1) # 80196630 <sb+0x18>
    80003698:	9dbd                	addw	a1,a1,a5
    8000369a:	4108                	lw	a0,0(a0)
    8000369c:	00000097          	auipc	ra,0x0
    800036a0:	89c080e7          	jalr	-1892(ra) # 80002f38 <bread>
    800036a4:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    800036a6:	05850793          	addi	a5,a0,88
    800036aa:	40d8                	lw	a4,4(s1)
    800036ac:	8b3d                	andi	a4,a4,15
    800036ae:	071a                	slli	a4,a4,0x6
    800036b0:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    800036b2:	04449703          	lh	a4,68(s1)
    800036b6:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    800036ba:	04649703          	lh	a4,70(s1)
    800036be:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    800036c2:	04849703          	lh	a4,72(s1)
    800036c6:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    800036ca:	04a49703          	lh	a4,74(s1)
    800036ce:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    800036d2:	44f8                	lw	a4,76(s1)
    800036d4:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    800036d6:	03400613          	li	a2,52
    800036da:	05048593          	addi	a1,s1,80
    800036de:	00c78513          	addi	a0,a5,12
    800036e2:	ffffd097          	auipc	ra,0xffffd
    800036e6:	648080e7          	jalr	1608(ra) # 80000d2a <memmove>
  log_write(bp);
    800036ea:	854a                	mv	a0,s2
    800036ec:	00001097          	auipc	ra,0x1
    800036f0:	bd4080e7          	jalr	-1068(ra) # 800042c0 <log_write>
  brelse(bp);
    800036f4:	854a                	mv	a0,s2
    800036f6:	00000097          	auipc	ra,0x0
    800036fa:	972080e7          	jalr	-1678(ra) # 80003068 <brelse>
}
    800036fe:	60e2                	ld	ra,24(sp)
    80003700:	6442                	ld	s0,16(sp)
    80003702:	64a2                	ld	s1,8(sp)
    80003704:	6902                	ld	s2,0(sp)
    80003706:	6105                	addi	sp,sp,32
    80003708:	8082                	ret

000000008000370a <idup>:
{
    8000370a:	1101                	addi	sp,sp,-32
    8000370c:	ec06                	sd	ra,24(sp)
    8000370e:	e822                	sd	s0,16(sp)
    80003710:	e426                	sd	s1,8(sp)
    80003712:	1000                	addi	s0,sp,32
    80003714:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003716:	00193517          	auipc	a0,0x193
    8000371a:	f2a50513          	addi	a0,a0,-214 # 80196640 <itable>
    8000371e:	ffffd097          	auipc	ra,0xffffd
    80003722:	4b4080e7          	jalr	1204(ra) # 80000bd2 <acquire>
  ip->ref++;
    80003726:	449c                	lw	a5,8(s1)
    80003728:	2785                	addiw	a5,a5,1
    8000372a:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    8000372c:	00193517          	auipc	a0,0x193
    80003730:	f1450513          	addi	a0,a0,-236 # 80196640 <itable>
    80003734:	ffffd097          	auipc	ra,0xffffd
    80003738:	552080e7          	jalr	1362(ra) # 80000c86 <release>
}
    8000373c:	8526                	mv	a0,s1
    8000373e:	60e2                	ld	ra,24(sp)
    80003740:	6442                	ld	s0,16(sp)
    80003742:	64a2                	ld	s1,8(sp)
    80003744:	6105                	addi	sp,sp,32
    80003746:	8082                	ret

0000000080003748 <ilock>:
{
    80003748:	1101                	addi	sp,sp,-32
    8000374a:	ec06                	sd	ra,24(sp)
    8000374c:	e822                	sd	s0,16(sp)
    8000374e:	e426                	sd	s1,8(sp)
    80003750:	e04a                	sd	s2,0(sp)
    80003752:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80003754:	c115                	beqz	a0,80003778 <ilock+0x30>
    80003756:	84aa                	mv	s1,a0
    80003758:	451c                	lw	a5,8(a0)
    8000375a:	00f05f63          	blez	a5,80003778 <ilock+0x30>
  acquiresleep(&ip->lock);
    8000375e:	0541                	addi	a0,a0,16
    80003760:	00001097          	auipc	ra,0x1
    80003764:	c7e080e7          	jalr	-898(ra) # 800043de <acquiresleep>
  if(ip->valid == 0){
    80003768:	40bc                	lw	a5,64(s1)
    8000376a:	cf99                	beqz	a5,80003788 <ilock+0x40>
}
    8000376c:	60e2                	ld	ra,24(sp)
    8000376e:	6442                	ld	s0,16(sp)
    80003770:	64a2                	ld	s1,8(sp)
    80003772:	6902                	ld	s2,0(sp)
    80003774:	6105                	addi	sp,sp,32
    80003776:	8082                	ret
    panic("ilock");
    80003778:	00005517          	auipc	a0,0x5
    8000377c:	e8050513          	addi	a0,a0,-384 # 800085f8 <syscalls+0x180>
    80003780:	ffffd097          	auipc	ra,0xffffd
    80003784:	dbc080e7          	jalr	-580(ra) # 8000053c <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003788:	40dc                	lw	a5,4(s1)
    8000378a:	0047d79b          	srliw	a5,a5,0x4
    8000378e:	00193597          	auipc	a1,0x193
    80003792:	ea25a583          	lw	a1,-350(a1) # 80196630 <sb+0x18>
    80003796:	9dbd                	addw	a1,a1,a5
    80003798:	4088                	lw	a0,0(s1)
    8000379a:	fffff097          	auipc	ra,0xfffff
    8000379e:	79e080e7          	jalr	1950(ra) # 80002f38 <bread>
    800037a2:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    800037a4:	05850593          	addi	a1,a0,88
    800037a8:	40dc                	lw	a5,4(s1)
    800037aa:	8bbd                	andi	a5,a5,15
    800037ac:	079a                	slli	a5,a5,0x6
    800037ae:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    800037b0:	00059783          	lh	a5,0(a1)
    800037b4:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    800037b8:	00259783          	lh	a5,2(a1)
    800037bc:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    800037c0:	00459783          	lh	a5,4(a1)
    800037c4:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    800037c8:	00659783          	lh	a5,6(a1)
    800037cc:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    800037d0:	459c                	lw	a5,8(a1)
    800037d2:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    800037d4:	03400613          	li	a2,52
    800037d8:	05b1                	addi	a1,a1,12
    800037da:	05048513          	addi	a0,s1,80
    800037de:	ffffd097          	auipc	ra,0xffffd
    800037e2:	54c080e7          	jalr	1356(ra) # 80000d2a <memmove>
    brelse(bp);
    800037e6:	854a                	mv	a0,s2
    800037e8:	00000097          	auipc	ra,0x0
    800037ec:	880080e7          	jalr	-1920(ra) # 80003068 <brelse>
    ip->valid = 1;
    800037f0:	4785                	li	a5,1
    800037f2:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    800037f4:	04449783          	lh	a5,68(s1)
    800037f8:	fbb5                	bnez	a5,8000376c <ilock+0x24>
      panic("ilock: no type");
    800037fa:	00005517          	auipc	a0,0x5
    800037fe:	e0650513          	addi	a0,a0,-506 # 80008600 <syscalls+0x188>
    80003802:	ffffd097          	auipc	ra,0xffffd
    80003806:	d3a080e7          	jalr	-710(ra) # 8000053c <panic>

000000008000380a <iunlock>:
{
    8000380a:	1101                	addi	sp,sp,-32
    8000380c:	ec06                	sd	ra,24(sp)
    8000380e:	e822                	sd	s0,16(sp)
    80003810:	e426                	sd	s1,8(sp)
    80003812:	e04a                	sd	s2,0(sp)
    80003814:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80003816:	c905                	beqz	a0,80003846 <iunlock+0x3c>
    80003818:	84aa                	mv	s1,a0
    8000381a:	01050913          	addi	s2,a0,16
    8000381e:	854a                	mv	a0,s2
    80003820:	00001097          	auipc	ra,0x1
    80003824:	c58080e7          	jalr	-936(ra) # 80004478 <holdingsleep>
    80003828:	cd19                	beqz	a0,80003846 <iunlock+0x3c>
    8000382a:	449c                	lw	a5,8(s1)
    8000382c:	00f05d63          	blez	a5,80003846 <iunlock+0x3c>
  releasesleep(&ip->lock);
    80003830:	854a                	mv	a0,s2
    80003832:	00001097          	auipc	ra,0x1
    80003836:	c02080e7          	jalr	-1022(ra) # 80004434 <releasesleep>
}
    8000383a:	60e2                	ld	ra,24(sp)
    8000383c:	6442                	ld	s0,16(sp)
    8000383e:	64a2                	ld	s1,8(sp)
    80003840:	6902                	ld	s2,0(sp)
    80003842:	6105                	addi	sp,sp,32
    80003844:	8082                	ret
    panic("iunlock");
    80003846:	00005517          	auipc	a0,0x5
    8000384a:	dca50513          	addi	a0,a0,-566 # 80008610 <syscalls+0x198>
    8000384e:	ffffd097          	auipc	ra,0xffffd
    80003852:	cee080e7          	jalr	-786(ra) # 8000053c <panic>

0000000080003856 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80003856:	7179                	addi	sp,sp,-48
    80003858:	f406                	sd	ra,40(sp)
    8000385a:	f022                	sd	s0,32(sp)
    8000385c:	ec26                	sd	s1,24(sp)
    8000385e:	e84a                	sd	s2,16(sp)
    80003860:	e44e                	sd	s3,8(sp)
    80003862:	e052                	sd	s4,0(sp)
    80003864:	1800                	addi	s0,sp,48
    80003866:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80003868:	05050493          	addi	s1,a0,80
    8000386c:	08050913          	addi	s2,a0,128
    80003870:	a021                	j	80003878 <itrunc+0x22>
    80003872:	0491                	addi	s1,s1,4
    80003874:	01248d63          	beq	s1,s2,8000388e <itrunc+0x38>
    if(ip->addrs[i]){
    80003878:	408c                	lw	a1,0(s1)
    8000387a:	dde5                	beqz	a1,80003872 <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    8000387c:	0009a503          	lw	a0,0(s3)
    80003880:	00000097          	auipc	ra,0x0
    80003884:	8fc080e7          	jalr	-1796(ra) # 8000317c <bfree>
      ip->addrs[i] = 0;
    80003888:	0004a023          	sw	zero,0(s1)
    8000388c:	b7dd                	j	80003872 <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    8000388e:	0809a583          	lw	a1,128(s3)
    80003892:	e185                	bnez	a1,800038b2 <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80003894:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80003898:	854e                	mv	a0,s3
    8000389a:	00000097          	auipc	ra,0x0
    8000389e:	de2080e7          	jalr	-542(ra) # 8000367c <iupdate>
}
    800038a2:	70a2                	ld	ra,40(sp)
    800038a4:	7402                	ld	s0,32(sp)
    800038a6:	64e2                	ld	s1,24(sp)
    800038a8:	6942                	ld	s2,16(sp)
    800038aa:	69a2                	ld	s3,8(sp)
    800038ac:	6a02                	ld	s4,0(sp)
    800038ae:	6145                	addi	sp,sp,48
    800038b0:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    800038b2:	0009a503          	lw	a0,0(s3)
    800038b6:	fffff097          	auipc	ra,0xfffff
    800038ba:	682080e7          	jalr	1666(ra) # 80002f38 <bread>
    800038be:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    800038c0:	05850493          	addi	s1,a0,88
    800038c4:	45850913          	addi	s2,a0,1112
    800038c8:	a021                	j	800038d0 <itrunc+0x7a>
    800038ca:	0491                	addi	s1,s1,4
    800038cc:	01248b63          	beq	s1,s2,800038e2 <itrunc+0x8c>
      if(a[j])
    800038d0:	408c                	lw	a1,0(s1)
    800038d2:	dde5                	beqz	a1,800038ca <itrunc+0x74>
        bfree(ip->dev, a[j]);
    800038d4:	0009a503          	lw	a0,0(s3)
    800038d8:	00000097          	auipc	ra,0x0
    800038dc:	8a4080e7          	jalr	-1884(ra) # 8000317c <bfree>
    800038e0:	b7ed                	j	800038ca <itrunc+0x74>
    brelse(bp);
    800038e2:	8552                	mv	a0,s4
    800038e4:	fffff097          	auipc	ra,0xfffff
    800038e8:	784080e7          	jalr	1924(ra) # 80003068 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    800038ec:	0809a583          	lw	a1,128(s3)
    800038f0:	0009a503          	lw	a0,0(s3)
    800038f4:	00000097          	auipc	ra,0x0
    800038f8:	888080e7          	jalr	-1912(ra) # 8000317c <bfree>
    ip->addrs[NDIRECT] = 0;
    800038fc:	0809a023          	sw	zero,128(s3)
    80003900:	bf51                	j	80003894 <itrunc+0x3e>

0000000080003902 <iput>:
{
    80003902:	1101                	addi	sp,sp,-32
    80003904:	ec06                	sd	ra,24(sp)
    80003906:	e822                	sd	s0,16(sp)
    80003908:	e426                	sd	s1,8(sp)
    8000390a:	e04a                	sd	s2,0(sp)
    8000390c:	1000                	addi	s0,sp,32
    8000390e:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003910:	00193517          	auipc	a0,0x193
    80003914:	d3050513          	addi	a0,a0,-720 # 80196640 <itable>
    80003918:	ffffd097          	auipc	ra,0xffffd
    8000391c:	2ba080e7          	jalr	698(ra) # 80000bd2 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003920:	4498                	lw	a4,8(s1)
    80003922:	4785                	li	a5,1
    80003924:	02f70363          	beq	a4,a5,8000394a <iput+0x48>
  ip->ref--;
    80003928:	449c                	lw	a5,8(s1)
    8000392a:	37fd                	addiw	a5,a5,-1
    8000392c:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    8000392e:	00193517          	auipc	a0,0x193
    80003932:	d1250513          	addi	a0,a0,-750 # 80196640 <itable>
    80003936:	ffffd097          	auipc	ra,0xffffd
    8000393a:	350080e7          	jalr	848(ra) # 80000c86 <release>
}
    8000393e:	60e2                	ld	ra,24(sp)
    80003940:	6442                	ld	s0,16(sp)
    80003942:	64a2                	ld	s1,8(sp)
    80003944:	6902                	ld	s2,0(sp)
    80003946:	6105                	addi	sp,sp,32
    80003948:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    8000394a:	40bc                	lw	a5,64(s1)
    8000394c:	dff1                	beqz	a5,80003928 <iput+0x26>
    8000394e:	04a49783          	lh	a5,74(s1)
    80003952:	fbf9                	bnez	a5,80003928 <iput+0x26>
    acquiresleep(&ip->lock);
    80003954:	01048913          	addi	s2,s1,16
    80003958:	854a                	mv	a0,s2
    8000395a:	00001097          	auipc	ra,0x1
    8000395e:	a84080e7          	jalr	-1404(ra) # 800043de <acquiresleep>
    release(&itable.lock);
    80003962:	00193517          	auipc	a0,0x193
    80003966:	cde50513          	addi	a0,a0,-802 # 80196640 <itable>
    8000396a:	ffffd097          	auipc	ra,0xffffd
    8000396e:	31c080e7          	jalr	796(ra) # 80000c86 <release>
    itrunc(ip);
    80003972:	8526                	mv	a0,s1
    80003974:	00000097          	auipc	ra,0x0
    80003978:	ee2080e7          	jalr	-286(ra) # 80003856 <itrunc>
    ip->type = 0;
    8000397c:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80003980:	8526                	mv	a0,s1
    80003982:	00000097          	auipc	ra,0x0
    80003986:	cfa080e7          	jalr	-774(ra) # 8000367c <iupdate>
    ip->valid = 0;
    8000398a:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    8000398e:	854a                	mv	a0,s2
    80003990:	00001097          	auipc	ra,0x1
    80003994:	aa4080e7          	jalr	-1372(ra) # 80004434 <releasesleep>
    acquire(&itable.lock);
    80003998:	00193517          	auipc	a0,0x193
    8000399c:	ca850513          	addi	a0,a0,-856 # 80196640 <itable>
    800039a0:	ffffd097          	auipc	ra,0xffffd
    800039a4:	232080e7          	jalr	562(ra) # 80000bd2 <acquire>
    800039a8:	b741                	j	80003928 <iput+0x26>

00000000800039aa <iunlockput>:
{
    800039aa:	1101                	addi	sp,sp,-32
    800039ac:	ec06                	sd	ra,24(sp)
    800039ae:	e822                	sd	s0,16(sp)
    800039b0:	e426                	sd	s1,8(sp)
    800039b2:	1000                	addi	s0,sp,32
    800039b4:	84aa                	mv	s1,a0
  iunlock(ip);
    800039b6:	00000097          	auipc	ra,0x0
    800039ba:	e54080e7          	jalr	-428(ra) # 8000380a <iunlock>
  iput(ip);
    800039be:	8526                	mv	a0,s1
    800039c0:	00000097          	auipc	ra,0x0
    800039c4:	f42080e7          	jalr	-190(ra) # 80003902 <iput>
}
    800039c8:	60e2                	ld	ra,24(sp)
    800039ca:	6442                	ld	s0,16(sp)
    800039cc:	64a2                	ld	s1,8(sp)
    800039ce:	6105                	addi	sp,sp,32
    800039d0:	8082                	ret

00000000800039d2 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    800039d2:	1141                	addi	sp,sp,-16
    800039d4:	e422                	sd	s0,8(sp)
    800039d6:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    800039d8:	411c                	lw	a5,0(a0)
    800039da:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    800039dc:	415c                	lw	a5,4(a0)
    800039de:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    800039e0:	04451783          	lh	a5,68(a0)
    800039e4:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    800039e8:	04a51783          	lh	a5,74(a0)
    800039ec:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    800039f0:	04c56783          	lwu	a5,76(a0)
    800039f4:	e99c                	sd	a5,16(a1)
}
    800039f6:	6422                	ld	s0,8(sp)
    800039f8:	0141                	addi	sp,sp,16
    800039fa:	8082                	ret

00000000800039fc <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    800039fc:	457c                	lw	a5,76(a0)
    800039fe:	0ed7e963          	bltu	a5,a3,80003af0 <readi+0xf4>
{
    80003a02:	7159                	addi	sp,sp,-112
    80003a04:	f486                	sd	ra,104(sp)
    80003a06:	f0a2                	sd	s0,96(sp)
    80003a08:	eca6                	sd	s1,88(sp)
    80003a0a:	e8ca                	sd	s2,80(sp)
    80003a0c:	e4ce                	sd	s3,72(sp)
    80003a0e:	e0d2                	sd	s4,64(sp)
    80003a10:	fc56                	sd	s5,56(sp)
    80003a12:	f85a                	sd	s6,48(sp)
    80003a14:	f45e                	sd	s7,40(sp)
    80003a16:	f062                	sd	s8,32(sp)
    80003a18:	ec66                	sd	s9,24(sp)
    80003a1a:	e86a                	sd	s10,16(sp)
    80003a1c:	e46e                	sd	s11,8(sp)
    80003a1e:	1880                	addi	s0,sp,112
    80003a20:	8b2a                	mv	s6,a0
    80003a22:	8bae                	mv	s7,a1
    80003a24:	8a32                	mv	s4,a2
    80003a26:	84b6                	mv	s1,a3
    80003a28:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    80003a2a:	9f35                	addw	a4,a4,a3
    return 0;
    80003a2c:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80003a2e:	0ad76063          	bltu	a4,a3,80003ace <readi+0xd2>
  if(off + n > ip->size)
    80003a32:	00e7f463          	bgeu	a5,a4,80003a3a <readi+0x3e>
    n = ip->size - off;
    80003a36:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003a3a:	0a0a8963          	beqz	s5,80003aec <readi+0xf0>
    80003a3e:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003a40:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003a44:	5c7d                	li	s8,-1
    80003a46:	a82d                	j	80003a80 <readi+0x84>
    80003a48:	020d1d93          	slli	s11,s10,0x20
    80003a4c:	020ddd93          	srli	s11,s11,0x20
    80003a50:	05890613          	addi	a2,s2,88
    80003a54:	86ee                	mv	a3,s11
    80003a56:	963a                	add	a2,a2,a4
    80003a58:	85d2                	mv	a1,s4
    80003a5a:	855e                	mv	a0,s7
    80003a5c:	fffff097          	auipc	ra,0xfffff
    80003a60:	af0080e7          	jalr	-1296(ra) # 8000254c <either_copyout>
    80003a64:	05850d63          	beq	a0,s8,80003abe <readi+0xc2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80003a68:	854a                	mv	a0,s2
    80003a6a:	fffff097          	auipc	ra,0xfffff
    80003a6e:	5fe080e7          	jalr	1534(ra) # 80003068 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003a72:	013d09bb          	addw	s3,s10,s3
    80003a76:	009d04bb          	addw	s1,s10,s1
    80003a7a:	9a6e                	add	s4,s4,s11
    80003a7c:	0559f763          	bgeu	s3,s5,80003aca <readi+0xce>
    uint addr = bmap(ip, off/BSIZE);
    80003a80:	00a4d59b          	srliw	a1,s1,0xa
    80003a84:	855a                	mv	a0,s6
    80003a86:	00000097          	auipc	ra,0x0
    80003a8a:	8a4080e7          	jalr	-1884(ra) # 8000332a <bmap>
    80003a8e:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80003a92:	cd85                	beqz	a1,80003aca <readi+0xce>
    bp = bread(ip->dev, addr);
    80003a94:	000b2503          	lw	a0,0(s6)
    80003a98:	fffff097          	auipc	ra,0xfffff
    80003a9c:	4a0080e7          	jalr	1184(ra) # 80002f38 <bread>
    80003aa0:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003aa2:	3ff4f713          	andi	a4,s1,1023
    80003aa6:	40ec87bb          	subw	a5,s9,a4
    80003aaa:	413a86bb          	subw	a3,s5,s3
    80003aae:	8d3e                	mv	s10,a5
    80003ab0:	2781                	sext.w	a5,a5
    80003ab2:	0006861b          	sext.w	a2,a3
    80003ab6:	f8f679e3          	bgeu	a2,a5,80003a48 <readi+0x4c>
    80003aba:	8d36                	mv	s10,a3
    80003abc:	b771                	j	80003a48 <readi+0x4c>
      brelse(bp);
    80003abe:	854a                	mv	a0,s2
    80003ac0:	fffff097          	auipc	ra,0xfffff
    80003ac4:	5a8080e7          	jalr	1448(ra) # 80003068 <brelse>
      tot = -1;
    80003ac8:	59fd                	li	s3,-1
  }
  return tot;
    80003aca:	0009851b          	sext.w	a0,s3
}
    80003ace:	70a6                	ld	ra,104(sp)
    80003ad0:	7406                	ld	s0,96(sp)
    80003ad2:	64e6                	ld	s1,88(sp)
    80003ad4:	6946                	ld	s2,80(sp)
    80003ad6:	69a6                	ld	s3,72(sp)
    80003ad8:	6a06                	ld	s4,64(sp)
    80003ada:	7ae2                	ld	s5,56(sp)
    80003adc:	7b42                	ld	s6,48(sp)
    80003ade:	7ba2                	ld	s7,40(sp)
    80003ae0:	7c02                	ld	s8,32(sp)
    80003ae2:	6ce2                	ld	s9,24(sp)
    80003ae4:	6d42                	ld	s10,16(sp)
    80003ae6:	6da2                	ld	s11,8(sp)
    80003ae8:	6165                	addi	sp,sp,112
    80003aea:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003aec:	89d6                	mv	s3,s5
    80003aee:	bff1                	j	80003aca <readi+0xce>
    return 0;
    80003af0:	4501                	li	a0,0
}
    80003af2:	8082                	ret

0000000080003af4 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003af4:	457c                	lw	a5,76(a0)
    80003af6:	10d7e863          	bltu	a5,a3,80003c06 <writei+0x112>
{
    80003afa:	7159                	addi	sp,sp,-112
    80003afc:	f486                	sd	ra,104(sp)
    80003afe:	f0a2                	sd	s0,96(sp)
    80003b00:	eca6                	sd	s1,88(sp)
    80003b02:	e8ca                	sd	s2,80(sp)
    80003b04:	e4ce                	sd	s3,72(sp)
    80003b06:	e0d2                	sd	s4,64(sp)
    80003b08:	fc56                	sd	s5,56(sp)
    80003b0a:	f85a                	sd	s6,48(sp)
    80003b0c:	f45e                	sd	s7,40(sp)
    80003b0e:	f062                	sd	s8,32(sp)
    80003b10:	ec66                	sd	s9,24(sp)
    80003b12:	e86a                	sd	s10,16(sp)
    80003b14:	e46e                	sd	s11,8(sp)
    80003b16:	1880                	addi	s0,sp,112
    80003b18:	8aaa                	mv	s5,a0
    80003b1a:	8bae                	mv	s7,a1
    80003b1c:	8a32                	mv	s4,a2
    80003b1e:	8936                	mv	s2,a3
    80003b20:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003b22:	00e687bb          	addw	a5,a3,a4
    80003b26:	0ed7e263          	bltu	a5,a3,80003c0a <writei+0x116>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80003b2a:	00043737          	lui	a4,0x43
    80003b2e:	0ef76063          	bltu	a4,a5,80003c0e <writei+0x11a>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003b32:	0c0b0863          	beqz	s6,80003c02 <writei+0x10e>
    80003b36:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003b38:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003b3c:	5c7d                	li	s8,-1
    80003b3e:	a091                	j	80003b82 <writei+0x8e>
    80003b40:	020d1d93          	slli	s11,s10,0x20
    80003b44:	020ddd93          	srli	s11,s11,0x20
    80003b48:	05848513          	addi	a0,s1,88
    80003b4c:	86ee                	mv	a3,s11
    80003b4e:	8652                	mv	a2,s4
    80003b50:	85de                	mv	a1,s7
    80003b52:	953a                	add	a0,a0,a4
    80003b54:	fffff097          	auipc	ra,0xfffff
    80003b58:	a4e080e7          	jalr	-1458(ra) # 800025a2 <either_copyin>
    80003b5c:	07850263          	beq	a0,s8,80003bc0 <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    80003b60:	8526                	mv	a0,s1
    80003b62:	00000097          	auipc	ra,0x0
    80003b66:	75e080e7          	jalr	1886(ra) # 800042c0 <log_write>
    brelse(bp);
    80003b6a:	8526                	mv	a0,s1
    80003b6c:	fffff097          	auipc	ra,0xfffff
    80003b70:	4fc080e7          	jalr	1276(ra) # 80003068 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003b74:	013d09bb          	addw	s3,s10,s3
    80003b78:	012d093b          	addw	s2,s10,s2
    80003b7c:	9a6e                	add	s4,s4,s11
    80003b7e:	0569f663          	bgeu	s3,s6,80003bca <writei+0xd6>
    uint addr = bmap(ip, off/BSIZE);
    80003b82:	00a9559b          	srliw	a1,s2,0xa
    80003b86:	8556                	mv	a0,s5
    80003b88:	fffff097          	auipc	ra,0xfffff
    80003b8c:	7a2080e7          	jalr	1954(ra) # 8000332a <bmap>
    80003b90:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80003b94:	c99d                	beqz	a1,80003bca <writei+0xd6>
    bp = bread(ip->dev, addr);
    80003b96:	000aa503          	lw	a0,0(s5)
    80003b9a:	fffff097          	auipc	ra,0xfffff
    80003b9e:	39e080e7          	jalr	926(ra) # 80002f38 <bread>
    80003ba2:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003ba4:	3ff97713          	andi	a4,s2,1023
    80003ba8:	40ec87bb          	subw	a5,s9,a4
    80003bac:	413b06bb          	subw	a3,s6,s3
    80003bb0:	8d3e                	mv	s10,a5
    80003bb2:	2781                	sext.w	a5,a5
    80003bb4:	0006861b          	sext.w	a2,a3
    80003bb8:	f8f674e3          	bgeu	a2,a5,80003b40 <writei+0x4c>
    80003bbc:	8d36                	mv	s10,a3
    80003bbe:	b749                	j	80003b40 <writei+0x4c>
      brelse(bp);
    80003bc0:	8526                	mv	a0,s1
    80003bc2:	fffff097          	auipc	ra,0xfffff
    80003bc6:	4a6080e7          	jalr	1190(ra) # 80003068 <brelse>
  }

  if(off > ip->size)
    80003bca:	04caa783          	lw	a5,76(s5)
    80003bce:	0127f463          	bgeu	a5,s2,80003bd6 <writei+0xe2>
    ip->size = off;
    80003bd2:	052aa623          	sw	s2,76(s5)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80003bd6:	8556                	mv	a0,s5
    80003bd8:	00000097          	auipc	ra,0x0
    80003bdc:	aa4080e7          	jalr	-1372(ra) # 8000367c <iupdate>

  return tot;
    80003be0:	0009851b          	sext.w	a0,s3
}
    80003be4:	70a6                	ld	ra,104(sp)
    80003be6:	7406                	ld	s0,96(sp)
    80003be8:	64e6                	ld	s1,88(sp)
    80003bea:	6946                	ld	s2,80(sp)
    80003bec:	69a6                	ld	s3,72(sp)
    80003bee:	6a06                	ld	s4,64(sp)
    80003bf0:	7ae2                	ld	s5,56(sp)
    80003bf2:	7b42                	ld	s6,48(sp)
    80003bf4:	7ba2                	ld	s7,40(sp)
    80003bf6:	7c02                	ld	s8,32(sp)
    80003bf8:	6ce2                	ld	s9,24(sp)
    80003bfa:	6d42                	ld	s10,16(sp)
    80003bfc:	6da2                	ld	s11,8(sp)
    80003bfe:	6165                	addi	sp,sp,112
    80003c00:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003c02:	89da                	mv	s3,s6
    80003c04:	bfc9                	j	80003bd6 <writei+0xe2>
    return -1;
    80003c06:	557d                	li	a0,-1
}
    80003c08:	8082                	ret
    return -1;
    80003c0a:	557d                	li	a0,-1
    80003c0c:	bfe1                	j	80003be4 <writei+0xf0>
    return -1;
    80003c0e:	557d                	li	a0,-1
    80003c10:	bfd1                	j	80003be4 <writei+0xf0>

0000000080003c12 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80003c12:	1141                	addi	sp,sp,-16
    80003c14:	e406                	sd	ra,8(sp)
    80003c16:	e022                	sd	s0,0(sp)
    80003c18:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80003c1a:	4639                	li	a2,14
    80003c1c:	ffffd097          	auipc	ra,0xffffd
    80003c20:	182080e7          	jalr	386(ra) # 80000d9e <strncmp>
}
    80003c24:	60a2                	ld	ra,8(sp)
    80003c26:	6402                	ld	s0,0(sp)
    80003c28:	0141                	addi	sp,sp,16
    80003c2a:	8082                	ret

0000000080003c2c <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003c2c:	7139                	addi	sp,sp,-64
    80003c2e:	fc06                	sd	ra,56(sp)
    80003c30:	f822                	sd	s0,48(sp)
    80003c32:	f426                	sd	s1,40(sp)
    80003c34:	f04a                	sd	s2,32(sp)
    80003c36:	ec4e                	sd	s3,24(sp)
    80003c38:	e852                	sd	s4,16(sp)
    80003c3a:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80003c3c:	04451703          	lh	a4,68(a0)
    80003c40:	4785                	li	a5,1
    80003c42:	00f71a63          	bne	a4,a5,80003c56 <dirlookup+0x2a>
    80003c46:	892a                	mv	s2,a0
    80003c48:	89ae                	mv	s3,a1
    80003c4a:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80003c4c:	457c                	lw	a5,76(a0)
    80003c4e:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80003c50:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003c52:	e79d                	bnez	a5,80003c80 <dirlookup+0x54>
    80003c54:	a8a5                	j	80003ccc <dirlookup+0xa0>
    panic("dirlookup not DIR");
    80003c56:	00005517          	auipc	a0,0x5
    80003c5a:	9c250513          	addi	a0,a0,-1598 # 80008618 <syscalls+0x1a0>
    80003c5e:	ffffd097          	auipc	ra,0xffffd
    80003c62:	8de080e7          	jalr	-1826(ra) # 8000053c <panic>
      panic("dirlookup read");
    80003c66:	00005517          	auipc	a0,0x5
    80003c6a:	9ca50513          	addi	a0,a0,-1590 # 80008630 <syscalls+0x1b8>
    80003c6e:	ffffd097          	auipc	ra,0xffffd
    80003c72:	8ce080e7          	jalr	-1842(ra) # 8000053c <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003c76:	24c1                	addiw	s1,s1,16
    80003c78:	04c92783          	lw	a5,76(s2)
    80003c7c:	04f4f763          	bgeu	s1,a5,80003cca <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003c80:	4741                	li	a4,16
    80003c82:	86a6                	mv	a3,s1
    80003c84:	fc040613          	addi	a2,s0,-64
    80003c88:	4581                	li	a1,0
    80003c8a:	854a                	mv	a0,s2
    80003c8c:	00000097          	auipc	ra,0x0
    80003c90:	d70080e7          	jalr	-656(ra) # 800039fc <readi>
    80003c94:	47c1                	li	a5,16
    80003c96:	fcf518e3          	bne	a0,a5,80003c66 <dirlookup+0x3a>
    if(de.inum == 0)
    80003c9a:	fc045783          	lhu	a5,-64(s0)
    80003c9e:	dfe1                	beqz	a5,80003c76 <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    80003ca0:	fc240593          	addi	a1,s0,-62
    80003ca4:	854e                	mv	a0,s3
    80003ca6:	00000097          	auipc	ra,0x0
    80003caa:	f6c080e7          	jalr	-148(ra) # 80003c12 <namecmp>
    80003cae:	f561                	bnez	a0,80003c76 <dirlookup+0x4a>
      if(poff)
    80003cb0:	000a0463          	beqz	s4,80003cb8 <dirlookup+0x8c>
        *poff = off;
    80003cb4:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80003cb8:	fc045583          	lhu	a1,-64(s0)
    80003cbc:	00092503          	lw	a0,0(s2)
    80003cc0:	fffff097          	auipc	ra,0xfffff
    80003cc4:	754080e7          	jalr	1876(ra) # 80003414 <iget>
    80003cc8:	a011                	j	80003ccc <dirlookup+0xa0>
  return 0;
    80003cca:	4501                	li	a0,0
}
    80003ccc:	70e2                	ld	ra,56(sp)
    80003cce:	7442                	ld	s0,48(sp)
    80003cd0:	74a2                	ld	s1,40(sp)
    80003cd2:	7902                	ld	s2,32(sp)
    80003cd4:	69e2                	ld	s3,24(sp)
    80003cd6:	6a42                	ld	s4,16(sp)
    80003cd8:	6121                	addi	sp,sp,64
    80003cda:	8082                	ret

0000000080003cdc <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80003cdc:	711d                	addi	sp,sp,-96
    80003cde:	ec86                	sd	ra,88(sp)
    80003ce0:	e8a2                	sd	s0,80(sp)
    80003ce2:	e4a6                	sd	s1,72(sp)
    80003ce4:	e0ca                	sd	s2,64(sp)
    80003ce6:	fc4e                	sd	s3,56(sp)
    80003ce8:	f852                	sd	s4,48(sp)
    80003cea:	f456                	sd	s5,40(sp)
    80003cec:	f05a                	sd	s6,32(sp)
    80003cee:	ec5e                	sd	s7,24(sp)
    80003cf0:	e862                	sd	s8,16(sp)
    80003cf2:	e466                	sd	s9,8(sp)
    80003cf4:	1080                	addi	s0,sp,96
    80003cf6:	84aa                	mv	s1,a0
    80003cf8:	8b2e                	mv	s6,a1
    80003cfa:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    80003cfc:	00054703          	lbu	a4,0(a0)
    80003d00:	02f00793          	li	a5,47
    80003d04:	02f70263          	beq	a4,a5,80003d28 <namex+0x4c>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80003d08:	ffffe097          	auipc	ra,0xffffe
    80003d0c:	cda080e7          	jalr	-806(ra) # 800019e2 <myproc>
    80003d10:	15053503          	ld	a0,336(a0)
    80003d14:	00000097          	auipc	ra,0x0
    80003d18:	9f6080e7          	jalr	-1546(ra) # 8000370a <idup>
    80003d1c:	8a2a                	mv	s4,a0
  while(*path == '/')
    80003d1e:	02f00913          	li	s2,47
  if(len >= DIRSIZ)
    80003d22:	4c35                	li	s8,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80003d24:	4b85                	li	s7,1
    80003d26:	a875                	j	80003de2 <namex+0x106>
    ip = iget(ROOTDEV, ROOTINO);
    80003d28:	4585                	li	a1,1
    80003d2a:	4505                	li	a0,1
    80003d2c:	fffff097          	auipc	ra,0xfffff
    80003d30:	6e8080e7          	jalr	1768(ra) # 80003414 <iget>
    80003d34:	8a2a                	mv	s4,a0
    80003d36:	b7e5                	j	80003d1e <namex+0x42>
      iunlockput(ip);
    80003d38:	8552                	mv	a0,s4
    80003d3a:	00000097          	auipc	ra,0x0
    80003d3e:	c70080e7          	jalr	-912(ra) # 800039aa <iunlockput>
      return 0;
    80003d42:	4a01                	li	s4,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80003d44:	8552                	mv	a0,s4
    80003d46:	60e6                	ld	ra,88(sp)
    80003d48:	6446                	ld	s0,80(sp)
    80003d4a:	64a6                	ld	s1,72(sp)
    80003d4c:	6906                	ld	s2,64(sp)
    80003d4e:	79e2                	ld	s3,56(sp)
    80003d50:	7a42                	ld	s4,48(sp)
    80003d52:	7aa2                	ld	s5,40(sp)
    80003d54:	7b02                	ld	s6,32(sp)
    80003d56:	6be2                	ld	s7,24(sp)
    80003d58:	6c42                	ld	s8,16(sp)
    80003d5a:	6ca2                	ld	s9,8(sp)
    80003d5c:	6125                	addi	sp,sp,96
    80003d5e:	8082                	ret
      iunlock(ip);
    80003d60:	8552                	mv	a0,s4
    80003d62:	00000097          	auipc	ra,0x0
    80003d66:	aa8080e7          	jalr	-1368(ra) # 8000380a <iunlock>
      return ip;
    80003d6a:	bfe9                	j	80003d44 <namex+0x68>
      iunlockput(ip);
    80003d6c:	8552                	mv	a0,s4
    80003d6e:	00000097          	auipc	ra,0x0
    80003d72:	c3c080e7          	jalr	-964(ra) # 800039aa <iunlockput>
      return 0;
    80003d76:	8a4e                	mv	s4,s3
    80003d78:	b7f1                	j	80003d44 <namex+0x68>
  len = path - s;
    80003d7a:	40998633          	sub	a2,s3,s1
    80003d7e:	00060c9b          	sext.w	s9,a2
  if(len >= DIRSIZ)
    80003d82:	099c5863          	bge	s8,s9,80003e12 <namex+0x136>
    memmove(name, s, DIRSIZ);
    80003d86:	4639                	li	a2,14
    80003d88:	85a6                	mv	a1,s1
    80003d8a:	8556                	mv	a0,s5
    80003d8c:	ffffd097          	auipc	ra,0xffffd
    80003d90:	f9e080e7          	jalr	-98(ra) # 80000d2a <memmove>
    80003d94:	84ce                	mv	s1,s3
  while(*path == '/')
    80003d96:	0004c783          	lbu	a5,0(s1)
    80003d9a:	01279763          	bne	a5,s2,80003da8 <namex+0xcc>
    path++;
    80003d9e:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003da0:	0004c783          	lbu	a5,0(s1)
    80003da4:	ff278de3          	beq	a5,s2,80003d9e <namex+0xc2>
    ilock(ip);
    80003da8:	8552                	mv	a0,s4
    80003daa:	00000097          	auipc	ra,0x0
    80003dae:	99e080e7          	jalr	-1634(ra) # 80003748 <ilock>
    if(ip->type != T_DIR){
    80003db2:	044a1783          	lh	a5,68(s4)
    80003db6:	f97791e3          	bne	a5,s7,80003d38 <namex+0x5c>
    if(nameiparent && *path == '\0'){
    80003dba:	000b0563          	beqz	s6,80003dc4 <namex+0xe8>
    80003dbe:	0004c783          	lbu	a5,0(s1)
    80003dc2:	dfd9                	beqz	a5,80003d60 <namex+0x84>
    if((next = dirlookup(ip, name, 0)) == 0){
    80003dc4:	4601                	li	a2,0
    80003dc6:	85d6                	mv	a1,s5
    80003dc8:	8552                	mv	a0,s4
    80003dca:	00000097          	auipc	ra,0x0
    80003dce:	e62080e7          	jalr	-414(ra) # 80003c2c <dirlookup>
    80003dd2:	89aa                	mv	s3,a0
    80003dd4:	dd41                	beqz	a0,80003d6c <namex+0x90>
    iunlockput(ip);
    80003dd6:	8552                	mv	a0,s4
    80003dd8:	00000097          	auipc	ra,0x0
    80003ddc:	bd2080e7          	jalr	-1070(ra) # 800039aa <iunlockput>
    ip = next;
    80003de0:	8a4e                	mv	s4,s3
  while(*path == '/')
    80003de2:	0004c783          	lbu	a5,0(s1)
    80003de6:	01279763          	bne	a5,s2,80003df4 <namex+0x118>
    path++;
    80003dea:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003dec:	0004c783          	lbu	a5,0(s1)
    80003df0:	ff278de3          	beq	a5,s2,80003dea <namex+0x10e>
  if(*path == 0)
    80003df4:	cb9d                	beqz	a5,80003e2a <namex+0x14e>
  while(*path != '/' && *path != 0)
    80003df6:	0004c783          	lbu	a5,0(s1)
    80003dfa:	89a6                	mv	s3,s1
  len = path - s;
    80003dfc:	4c81                	li	s9,0
    80003dfe:	4601                	li	a2,0
  while(*path != '/' && *path != 0)
    80003e00:	01278963          	beq	a5,s2,80003e12 <namex+0x136>
    80003e04:	dbbd                	beqz	a5,80003d7a <namex+0x9e>
    path++;
    80003e06:	0985                	addi	s3,s3,1
  while(*path != '/' && *path != 0)
    80003e08:	0009c783          	lbu	a5,0(s3)
    80003e0c:	ff279ce3          	bne	a5,s2,80003e04 <namex+0x128>
    80003e10:	b7ad                	j	80003d7a <namex+0x9e>
    memmove(name, s, len);
    80003e12:	2601                	sext.w	a2,a2
    80003e14:	85a6                	mv	a1,s1
    80003e16:	8556                	mv	a0,s5
    80003e18:	ffffd097          	auipc	ra,0xffffd
    80003e1c:	f12080e7          	jalr	-238(ra) # 80000d2a <memmove>
    name[len] = 0;
    80003e20:	9cd6                	add	s9,s9,s5
    80003e22:	000c8023          	sb	zero,0(s9) # 2000 <_entry-0x7fffe000>
    80003e26:	84ce                	mv	s1,s3
    80003e28:	b7bd                	j	80003d96 <namex+0xba>
  if(nameiparent){
    80003e2a:	f00b0de3          	beqz	s6,80003d44 <namex+0x68>
    iput(ip);
    80003e2e:	8552                	mv	a0,s4
    80003e30:	00000097          	auipc	ra,0x0
    80003e34:	ad2080e7          	jalr	-1326(ra) # 80003902 <iput>
    return 0;
    80003e38:	4a01                	li	s4,0
    80003e3a:	b729                	j	80003d44 <namex+0x68>

0000000080003e3c <dirlink>:
{
    80003e3c:	7139                	addi	sp,sp,-64
    80003e3e:	fc06                	sd	ra,56(sp)
    80003e40:	f822                	sd	s0,48(sp)
    80003e42:	f426                	sd	s1,40(sp)
    80003e44:	f04a                	sd	s2,32(sp)
    80003e46:	ec4e                	sd	s3,24(sp)
    80003e48:	e852                	sd	s4,16(sp)
    80003e4a:	0080                	addi	s0,sp,64
    80003e4c:	892a                	mv	s2,a0
    80003e4e:	8a2e                	mv	s4,a1
    80003e50:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80003e52:	4601                	li	a2,0
    80003e54:	00000097          	auipc	ra,0x0
    80003e58:	dd8080e7          	jalr	-552(ra) # 80003c2c <dirlookup>
    80003e5c:	e93d                	bnez	a0,80003ed2 <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003e5e:	04c92483          	lw	s1,76(s2)
    80003e62:	c49d                	beqz	s1,80003e90 <dirlink+0x54>
    80003e64:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003e66:	4741                	li	a4,16
    80003e68:	86a6                	mv	a3,s1
    80003e6a:	fc040613          	addi	a2,s0,-64
    80003e6e:	4581                	li	a1,0
    80003e70:	854a                	mv	a0,s2
    80003e72:	00000097          	auipc	ra,0x0
    80003e76:	b8a080e7          	jalr	-1142(ra) # 800039fc <readi>
    80003e7a:	47c1                	li	a5,16
    80003e7c:	06f51163          	bne	a0,a5,80003ede <dirlink+0xa2>
    if(de.inum == 0)
    80003e80:	fc045783          	lhu	a5,-64(s0)
    80003e84:	c791                	beqz	a5,80003e90 <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003e86:	24c1                	addiw	s1,s1,16
    80003e88:	04c92783          	lw	a5,76(s2)
    80003e8c:	fcf4ede3          	bltu	s1,a5,80003e66 <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    80003e90:	4639                	li	a2,14
    80003e92:	85d2                	mv	a1,s4
    80003e94:	fc240513          	addi	a0,s0,-62
    80003e98:	ffffd097          	auipc	ra,0xffffd
    80003e9c:	f42080e7          	jalr	-190(ra) # 80000dda <strncpy>
  de.inum = inum;
    80003ea0:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003ea4:	4741                	li	a4,16
    80003ea6:	86a6                	mv	a3,s1
    80003ea8:	fc040613          	addi	a2,s0,-64
    80003eac:	4581                	li	a1,0
    80003eae:	854a                	mv	a0,s2
    80003eb0:	00000097          	auipc	ra,0x0
    80003eb4:	c44080e7          	jalr	-956(ra) # 80003af4 <writei>
    80003eb8:	1541                	addi	a0,a0,-16
    80003eba:	00a03533          	snez	a0,a0
    80003ebe:	40a00533          	neg	a0,a0
}
    80003ec2:	70e2                	ld	ra,56(sp)
    80003ec4:	7442                	ld	s0,48(sp)
    80003ec6:	74a2                	ld	s1,40(sp)
    80003ec8:	7902                	ld	s2,32(sp)
    80003eca:	69e2                	ld	s3,24(sp)
    80003ecc:	6a42                	ld	s4,16(sp)
    80003ece:	6121                	addi	sp,sp,64
    80003ed0:	8082                	ret
    iput(ip);
    80003ed2:	00000097          	auipc	ra,0x0
    80003ed6:	a30080e7          	jalr	-1488(ra) # 80003902 <iput>
    return -1;
    80003eda:	557d                	li	a0,-1
    80003edc:	b7dd                	j	80003ec2 <dirlink+0x86>
      panic("dirlink read");
    80003ede:	00004517          	auipc	a0,0x4
    80003ee2:	76250513          	addi	a0,a0,1890 # 80008640 <syscalls+0x1c8>
    80003ee6:	ffffc097          	auipc	ra,0xffffc
    80003eea:	656080e7          	jalr	1622(ra) # 8000053c <panic>

0000000080003eee <namei>:

struct inode*
namei(char *path)
{
    80003eee:	1101                	addi	sp,sp,-32
    80003ef0:	ec06                	sd	ra,24(sp)
    80003ef2:	e822                	sd	s0,16(sp)
    80003ef4:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80003ef6:	fe040613          	addi	a2,s0,-32
    80003efa:	4581                	li	a1,0
    80003efc:	00000097          	auipc	ra,0x0
    80003f00:	de0080e7          	jalr	-544(ra) # 80003cdc <namex>
}
    80003f04:	60e2                	ld	ra,24(sp)
    80003f06:	6442                	ld	s0,16(sp)
    80003f08:	6105                	addi	sp,sp,32
    80003f0a:	8082                	ret

0000000080003f0c <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80003f0c:	1141                	addi	sp,sp,-16
    80003f0e:	e406                	sd	ra,8(sp)
    80003f10:	e022                	sd	s0,0(sp)
    80003f12:	0800                	addi	s0,sp,16
    80003f14:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80003f16:	4585                	li	a1,1
    80003f18:	00000097          	auipc	ra,0x0
    80003f1c:	dc4080e7          	jalr	-572(ra) # 80003cdc <namex>
}
    80003f20:	60a2                	ld	ra,8(sp)
    80003f22:	6402                	ld	s0,0(sp)
    80003f24:	0141                	addi	sp,sp,16
    80003f26:	8082                	ret

0000000080003f28 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80003f28:	1101                	addi	sp,sp,-32
    80003f2a:	ec06                	sd	ra,24(sp)
    80003f2c:	e822                	sd	s0,16(sp)
    80003f2e:	e426                	sd	s1,8(sp)
    80003f30:	e04a                	sd	s2,0(sp)
    80003f32:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80003f34:	00194917          	auipc	s2,0x194
    80003f38:	1b490913          	addi	s2,s2,436 # 801980e8 <log>
    80003f3c:	01892583          	lw	a1,24(s2)
    80003f40:	02892503          	lw	a0,40(s2)
    80003f44:	fffff097          	auipc	ra,0xfffff
    80003f48:	ff4080e7          	jalr	-12(ra) # 80002f38 <bread>
    80003f4c:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80003f4e:	02c92603          	lw	a2,44(s2)
    80003f52:	cd30                	sw	a2,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80003f54:	00c05f63          	blez	a2,80003f72 <write_head+0x4a>
    80003f58:	00194717          	auipc	a4,0x194
    80003f5c:	1c070713          	addi	a4,a4,448 # 80198118 <log+0x30>
    80003f60:	87aa                	mv	a5,a0
    80003f62:	060a                	slli	a2,a2,0x2
    80003f64:	962a                	add	a2,a2,a0
    hb->block[i] = log.lh.block[i];
    80003f66:	4314                	lw	a3,0(a4)
    80003f68:	cff4                	sw	a3,92(a5)
  for (i = 0; i < log.lh.n; i++) {
    80003f6a:	0711                	addi	a4,a4,4
    80003f6c:	0791                	addi	a5,a5,4
    80003f6e:	fec79ce3          	bne	a5,a2,80003f66 <write_head+0x3e>
  }
  bwrite(buf);
    80003f72:	8526                	mv	a0,s1
    80003f74:	fffff097          	auipc	ra,0xfffff
    80003f78:	0b6080e7          	jalr	182(ra) # 8000302a <bwrite>
  brelse(buf);
    80003f7c:	8526                	mv	a0,s1
    80003f7e:	fffff097          	auipc	ra,0xfffff
    80003f82:	0ea080e7          	jalr	234(ra) # 80003068 <brelse>
}
    80003f86:	60e2                	ld	ra,24(sp)
    80003f88:	6442                	ld	s0,16(sp)
    80003f8a:	64a2                	ld	s1,8(sp)
    80003f8c:	6902                	ld	s2,0(sp)
    80003f8e:	6105                	addi	sp,sp,32
    80003f90:	8082                	ret

0000000080003f92 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80003f92:	00194797          	auipc	a5,0x194
    80003f96:	1827a783          	lw	a5,386(a5) # 80198114 <log+0x2c>
    80003f9a:	0af05d63          	blez	a5,80004054 <install_trans+0xc2>
{
    80003f9e:	7139                	addi	sp,sp,-64
    80003fa0:	fc06                	sd	ra,56(sp)
    80003fa2:	f822                	sd	s0,48(sp)
    80003fa4:	f426                	sd	s1,40(sp)
    80003fa6:	f04a                	sd	s2,32(sp)
    80003fa8:	ec4e                	sd	s3,24(sp)
    80003faa:	e852                	sd	s4,16(sp)
    80003fac:	e456                	sd	s5,8(sp)
    80003fae:	e05a                	sd	s6,0(sp)
    80003fb0:	0080                	addi	s0,sp,64
    80003fb2:	8b2a                	mv	s6,a0
    80003fb4:	00194a97          	auipc	s5,0x194
    80003fb8:	164a8a93          	addi	s5,s5,356 # 80198118 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003fbc:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003fbe:	00194997          	auipc	s3,0x194
    80003fc2:	12a98993          	addi	s3,s3,298 # 801980e8 <log>
    80003fc6:	a00d                	j	80003fe8 <install_trans+0x56>
    brelse(lbuf);
    80003fc8:	854a                	mv	a0,s2
    80003fca:	fffff097          	auipc	ra,0xfffff
    80003fce:	09e080e7          	jalr	158(ra) # 80003068 <brelse>
    brelse(dbuf);
    80003fd2:	8526                	mv	a0,s1
    80003fd4:	fffff097          	auipc	ra,0xfffff
    80003fd8:	094080e7          	jalr	148(ra) # 80003068 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003fdc:	2a05                	addiw	s4,s4,1
    80003fde:	0a91                	addi	s5,s5,4
    80003fe0:	02c9a783          	lw	a5,44(s3)
    80003fe4:	04fa5e63          	bge	s4,a5,80004040 <install_trans+0xae>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003fe8:	0189a583          	lw	a1,24(s3)
    80003fec:	014585bb          	addw	a1,a1,s4
    80003ff0:	2585                	addiw	a1,a1,1
    80003ff2:	0289a503          	lw	a0,40(s3)
    80003ff6:	fffff097          	auipc	ra,0xfffff
    80003ffa:	f42080e7          	jalr	-190(ra) # 80002f38 <bread>
    80003ffe:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    80004000:	000aa583          	lw	a1,0(s5)
    80004004:	0289a503          	lw	a0,40(s3)
    80004008:	fffff097          	auipc	ra,0xfffff
    8000400c:	f30080e7          	jalr	-208(ra) # 80002f38 <bread>
    80004010:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80004012:	40000613          	li	a2,1024
    80004016:	05890593          	addi	a1,s2,88
    8000401a:	05850513          	addi	a0,a0,88
    8000401e:	ffffd097          	auipc	ra,0xffffd
    80004022:	d0c080e7          	jalr	-756(ra) # 80000d2a <memmove>
    bwrite(dbuf);  // write dst to disk
    80004026:	8526                	mv	a0,s1
    80004028:	fffff097          	auipc	ra,0xfffff
    8000402c:	002080e7          	jalr	2(ra) # 8000302a <bwrite>
    if(recovering == 0)
    80004030:	f80b1ce3          	bnez	s6,80003fc8 <install_trans+0x36>
      bunpin(dbuf);
    80004034:	8526                	mv	a0,s1
    80004036:	fffff097          	auipc	ra,0xfffff
    8000403a:	10a080e7          	jalr	266(ra) # 80003140 <bunpin>
    8000403e:	b769                	j	80003fc8 <install_trans+0x36>
}
    80004040:	70e2                	ld	ra,56(sp)
    80004042:	7442                	ld	s0,48(sp)
    80004044:	74a2                	ld	s1,40(sp)
    80004046:	7902                	ld	s2,32(sp)
    80004048:	69e2                	ld	s3,24(sp)
    8000404a:	6a42                	ld	s4,16(sp)
    8000404c:	6aa2                	ld	s5,8(sp)
    8000404e:	6b02                	ld	s6,0(sp)
    80004050:	6121                	addi	sp,sp,64
    80004052:	8082                	ret
    80004054:	8082                	ret

0000000080004056 <initlog>:
{
    80004056:	7179                	addi	sp,sp,-48
    80004058:	f406                	sd	ra,40(sp)
    8000405a:	f022                	sd	s0,32(sp)
    8000405c:	ec26                	sd	s1,24(sp)
    8000405e:	e84a                	sd	s2,16(sp)
    80004060:	e44e                	sd	s3,8(sp)
    80004062:	1800                	addi	s0,sp,48
    80004064:	892a                	mv	s2,a0
    80004066:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80004068:	00194497          	auipc	s1,0x194
    8000406c:	08048493          	addi	s1,s1,128 # 801980e8 <log>
    80004070:	00004597          	auipc	a1,0x4
    80004074:	5e058593          	addi	a1,a1,1504 # 80008650 <syscalls+0x1d8>
    80004078:	8526                	mv	a0,s1
    8000407a:	ffffd097          	auipc	ra,0xffffd
    8000407e:	ac8080e7          	jalr	-1336(ra) # 80000b42 <initlock>
  log.start = sb->logstart;
    80004082:	0149a583          	lw	a1,20(s3)
    80004086:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    80004088:	0109a783          	lw	a5,16(s3)
    8000408c:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    8000408e:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    80004092:	854a                	mv	a0,s2
    80004094:	fffff097          	auipc	ra,0xfffff
    80004098:	ea4080e7          	jalr	-348(ra) # 80002f38 <bread>
  log.lh.n = lh->n;
    8000409c:	4d30                	lw	a2,88(a0)
    8000409e:	d4d0                	sw	a2,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    800040a0:	00c05f63          	blez	a2,800040be <initlog+0x68>
    800040a4:	87aa                	mv	a5,a0
    800040a6:	00194717          	auipc	a4,0x194
    800040aa:	07270713          	addi	a4,a4,114 # 80198118 <log+0x30>
    800040ae:	060a                	slli	a2,a2,0x2
    800040b0:	962a                	add	a2,a2,a0
    log.lh.block[i] = lh->block[i];
    800040b2:	4ff4                	lw	a3,92(a5)
    800040b4:	c314                	sw	a3,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    800040b6:	0791                	addi	a5,a5,4
    800040b8:	0711                	addi	a4,a4,4
    800040ba:	fec79ce3          	bne	a5,a2,800040b2 <initlog+0x5c>
  brelse(buf);
    800040be:	fffff097          	auipc	ra,0xfffff
    800040c2:	faa080e7          	jalr	-86(ra) # 80003068 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    800040c6:	4505                	li	a0,1
    800040c8:	00000097          	auipc	ra,0x0
    800040cc:	eca080e7          	jalr	-310(ra) # 80003f92 <install_trans>
  log.lh.n = 0;
    800040d0:	00194797          	auipc	a5,0x194
    800040d4:	0407a223          	sw	zero,68(a5) # 80198114 <log+0x2c>
  write_head(); // clear the log
    800040d8:	00000097          	auipc	ra,0x0
    800040dc:	e50080e7          	jalr	-432(ra) # 80003f28 <write_head>
}
    800040e0:	70a2                	ld	ra,40(sp)
    800040e2:	7402                	ld	s0,32(sp)
    800040e4:	64e2                	ld	s1,24(sp)
    800040e6:	6942                	ld	s2,16(sp)
    800040e8:	69a2                	ld	s3,8(sp)
    800040ea:	6145                	addi	sp,sp,48
    800040ec:	8082                	ret

00000000800040ee <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    800040ee:	1101                	addi	sp,sp,-32
    800040f0:	ec06                	sd	ra,24(sp)
    800040f2:	e822                	sd	s0,16(sp)
    800040f4:	e426                	sd	s1,8(sp)
    800040f6:	e04a                	sd	s2,0(sp)
    800040f8:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    800040fa:	00194517          	auipc	a0,0x194
    800040fe:	fee50513          	addi	a0,a0,-18 # 801980e8 <log>
    80004102:	ffffd097          	auipc	ra,0xffffd
    80004106:	ad0080e7          	jalr	-1328(ra) # 80000bd2 <acquire>
  while(1){
    if(log.committing){
    8000410a:	00194497          	auipc	s1,0x194
    8000410e:	fde48493          	addi	s1,s1,-34 # 801980e8 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80004112:	4979                	li	s2,30
    80004114:	a039                	j	80004122 <begin_op+0x34>
      sleep(&log, &log.lock);
    80004116:	85a6                	mv	a1,s1
    80004118:	8526                	mv	a0,s1
    8000411a:	ffffe097          	auipc	ra,0xffffe
    8000411e:	016080e7          	jalr	22(ra) # 80002130 <sleep>
    if(log.committing){
    80004122:	50dc                	lw	a5,36(s1)
    80004124:	fbed                	bnez	a5,80004116 <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80004126:	5098                	lw	a4,32(s1)
    80004128:	2705                	addiw	a4,a4,1
    8000412a:	0027179b          	slliw	a5,a4,0x2
    8000412e:	9fb9                	addw	a5,a5,a4
    80004130:	0017979b          	slliw	a5,a5,0x1
    80004134:	54d4                	lw	a3,44(s1)
    80004136:	9fb5                	addw	a5,a5,a3
    80004138:	00f95963          	bge	s2,a5,8000414a <begin_op+0x5c>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    8000413c:	85a6                	mv	a1,s1
    8000413e:	8526                	mv	a0,s1
    80004140:	ffffe097          	auipc	ra,0xffffe
    80004144:	ff0080e7          	jalr	-16(ra) # 80002130 <sleep>
    80004148:	bfe9                	j	80004122 <begin_op+0x34>
    } else {
      log.outstanding += 1;
    8000414a:	00194517          	auipc	a0,0x194
    8000414e:	f9e50513          	addi	a0,a0,-98 # 801980e8 <log>
    80004152:	d118                	sw	a4,32(a0)
      release(&log.lock);
    80004154:	ffffd097          	auipc	ra,0xffffd
    80004158:	b32080e7          	jalr	-1230(ra) # 80000c86 <release>
      break;
    }
  }
}
    8000415c:	60e2                	ld	ra,24(sp)
    8000415e:	6442                	ld	s0,16(sp)
    80004160:	64a2                	ld	s1,8(sp)
    80004162:	6902                	ld	s2,0(sp)
    80004164:	6105                	addi	sp,sp,32
    80004166:	8082                	ret

0000000080004168 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    80004168:	7139                	addi	sp,sp,-64
    8000416a:	fc06                	sd	ra,56(sp)
    8000416c:	f822                	sd	s0,48(sp)
    8000416e:	f426                	sd	s1,40(sp)
    80004170:	f04a                	sd	s2,32(sp)
    80004172:	ec4e                	sd	s3,24(sp)
    80004174:	e852                	sd	s4,16(sp)
    80004176:	e456                	sd	s5,8(sp)
    80004178:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    8000417a:	00194497          	auipc	s1,0x194
    8000417e:	f6e48493          	addi	s1,s1,-146 # 801980e8 <log>
    80004182:	8526                	mv	a0,s1
    80004184:	ffffd097          	auipc	ra,0xffffd
    80004188:	a4e080e7          	jalr	-1458(ra) # 80000bd2 <acquire>
  log.outstanding -= 1;
    8000418c:	509c                	lw	a5,32(s1)
    8000418e:	37fd                	addiw	a5,a5,-1
    80004190:	0007891b          	sext.w	s2,a5
    80004194:	d09c                	sw	a5,32(s1)
  if(log.committing)
    80004196:	50dc                	lw	a5,36(s1)
    80004198:	e7b9                	bnez	a5,800041e6 <end_op+0x7e>
    panic("log.committing");
  if(log.outstanding == 0){
    8000419a:	04091e63          	bnez	s2,800041f6 <end_op+0x8e>
    do_commit = 1;
    log.committing = 1;
    8000419e:	00194497          	auipc	s1,0x194
    800041a2:	f4a48493          	addi	s1,s1,-182 # 801980e8 <log>
    800041a6:	4785                	li	a5,1
    800041a8:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    800041aa:	8526                	mv	a0,s1
    800041ac:	ffffd097          	auipc	ra,0xffffd
    800041b0:	ada080e7          	jalr	-1318(ra) # 80000c86 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    800041b4:	54dc                	lw	a5,44(s1)
    800041b6:	06f04763          	bgtz	a5,80004224 <end_op+0xbc>
    acquire(&log.lock);
    800041ba:	00194497          	auipc	s1,0x194
    800041be:	f2e48493          	addi	s1,s1,-210 # 801980e8 <log>
    800041c2:	8526                	mv	a0,s1
    800041c4:	ffffd097          	auipc	ra,0xffffd
    800041c8:	a0e080e7          	jalr	-1522(ra) # 80000bd2 <acquire>
    log.committing = 0;
    800041cc:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    800041d0:	8526                	mv	a0,s1
    800041d2:	ffffe097          	auipc	ra,0xffffe
    800041d6:	fc2080e7          	jalr	-62(ra) # 80002194 <wakeup>
    release(&log.lock);
    800041da:	8526                	mv	a0,s1
    800041dc:	ffffd097          	auipc	ra,0xffffd
    800041e0:	aaa080e7          	jalr	-1366(ra) # 80000c86 <release>
}
    800041e4:	a03d                	j	80004212 <end_op+0xaa>
    panic("log.committing");
    800041e6:	00004517          	auipc	a0,0x4
    800041ea:	47250513          	addi	a0,a0,1138 # 80008658 <syscalls+0x1e0>
    800041ee:	ffffc097          	auipc	ra,0xffffc
    800041f2:	34e080e7          	jalr	846(ra) # 8000053c <panic>
    wakeup(&log);
    800041f6:	00194497          	auipc	s1,0x194
    800041fa:	ef248493          	addi	s1,s1,-270 # 801980e8 <log>
    800041fe:	8526                	mv	a0,s1
    80004200:	ffffe097          	auipc	ra,0xffffe
    80004204:	f94080e7          	jalr	-108(ra) # 80002194 <wakeup>
  release(&log.lock);
    80004208:	8526                	mv	a0,s1
    8000420a:	ffffd097          	auipc	ra,0xffffd
    8000420e:	a7c080e7          	jalr	-1412(ra) # 80000c86 <release>
}
    80004212:	70e2                	ld	ra,56(sp)
    80004214:	7442                	ld	s0,48(sp)
    80004216:	74a2                	ld	s1,40(sp)
    80004218:	7902                	ld	s2,32(sp)
    8000421a:	69e2                	ld	s3,24(sp)
    8000421c:	6a42                	ld	s4,16(sp)
    8000421e:	6aa2                	ld	s5,8(sp)
    80004220:	6121                	addi	sp,sp,64
    80004222:	8082                	ret
  for (tail = 0; tail < log.lh.n; tail++) {
    80004224:	00194a97          	auipc	s5,0x194
    80004228:	ef4a8a93          	addi	s5,s5,-268 # 80198118 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    8000422c:	00194a17          	auipc	s4,0x194
    80004230:	ebca0a13          	addi	s4,s4,-324 # 801980e8 <log>
    80004234:	018a2583          	lw	a1,24(s4)
    80004238:	012585bb          	addw	a1,a1,s2
    8000423c:	2585                	addiw	a1,a1,1
    8000423e:	028a2503          	lw	a0,40(s4)
    80004242:	fffff097          	auipc	ra,0xfffff
    80004246:	cf6080e7          	jalr	-778(ra) # 80002f38 <bread>
    8000424a:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    8000424c:	000aa583          	lw	a1,0(s5)
    80004250:	028a2503          	lw	a0,40(s4)
    80004254:	fffff097          	auipc	ra,0xfffff
    80004258:	ce4080e7          	jalr	-796(ra) # 80002f38 <bread>
    8000425c:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    8000425e:	40000613          	li	a2,1024
    80004262:	05850593          	addi	a1,a0,88
    80004266:	05848513          	addi	a0,s1,88
    8000426a:	ffffd097          	auipc	ra,0xffffd
    8000426e:	ac0080e7          	jalr	-1344(ra) # 80000d2a <memmove>
    bwrite(to);  // write the log
    80004272:	8526                	mv	a0,s1
    80004274:	fffff097          	auipc	ra,0xfffff
    80004278:	db6080e7          	jalr	-586(ra) # 8000302a <bwrite>
    brelse(from);
    8000427c:	854e                	mv	a0,s3
    8000427e:	fffff097          	auipc	ra,0xfffff
    80004282:	dea080e7          	jalr	-534(ra) # 80003068 <brelse>
    brelse(to);
    80004286:	8526                	mv	a0,s1
    80004288:	fffff097          	auipc	ra,0xfffff
    8000428c:	de0080e7          	jalr	-544(ra) # 80003068 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004290:	2905                	addiw	s2,s2,1
    80004292:	0a91                	addi	s5,s5,4
    80004294:	02ca2783          	lw	a5,44(s4)
    80004298:	f8f94ee3          	blt	s2,a5,80004234 <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    8000429c:	00000097          	auipc	ra,0x0
    800042a0:	c8c080e7          	jalr	-884(ra) # 80003f28 <write_head>
    install_trans(0); // Now install writes to home locations
    800042a4:	4501                	li	a0,0
    800042a6:	00000097          	auipc	ra,0x0
    800042aa:	cec080e7          	jalr	-788(ra) # 80003f92 <install_trans>
    log.lh.n = 0;
    800042ae:	00194797          	auipc	a5,0x194
    800042b2:	e607a323          	sw	zero,-410(a5) # 80198114 <log+0x2c>
    write_head();    // Erase the transaction from the log
    800042b6:	00000097          	auipc	ra,0x0
    800042ba:	c72080e7          	jalr	-910(ra) # 80003f28 <write_head>
    800042be:	bdf5                	j	800041ba <end_op+0x52>

00000000800042c0 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    800042c0:	1101                	addi	sp,sp,-32
    800042c2:	ec06                	sd	ra,24(sp)
    800042c4:	e822                	sd	s0,16(sp)
    800042c6:	e426                	sd	s1,8(sp)
    800042c8:	e04a                	sd	s2,0(sp)
    800042ca:	1000                	addi	s0,sp,32
    800042cc:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    800042ce:	00194917          	auipc	s2,0x194
    800042d2:	e1a90913          	addi	s2,s2,-486 # 801980e8 <log>
    800042d6:	854a                	mv	a0,s2
    800042d8:	ffffd097          	auipc	ra,0xffffd
    800042dc:	8fa080e7          	jalr	-1798(ra) # 80000bd2 <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    800042e0:	02c92603          	lw	a2,44(s2)
    800042e4:	47f5                	li	a5,29
    800042e6:	06c7c563          	blt	a5,a2,80004350 <log_write+0x90>
    800042ea:	00194797          	auipc	a5,0x194
    800042ee:	e1a7a783          	lw	a5,-486(a5) # 80198104 <log+0x1c>
    800042f2:	37fd                	addiw	a5,a5,-1
    800042f4:	04f65e63          	bge	a2,a5,80004350 <log_write+0x90>
    panic("too big a transaction");
  if (log.outstanding < 1)
    800042f8:	00194797          	auipc	a5,0x194
    800042fc:	e107a783          	lw	a5,-496(a5) # 80198108 <log+0x20>
    80004300:	06f05063          	blez	a5,80004360 <log_write+0xa0>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    80004304:	4781                	li	a5,0
    80004306:	06c05563          	blez	a2,80004370 <log_write+0xb0>
    if (log.lh.block[i] == b->blockno)   // log absorption
    8000430a:	44cc                	lw	a1,12(s1)
    8000430c:	00194717          	auipc	a4,0x194
    80004310:	e0c70713          	addi	a4,a4,-500 # 80198118 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    80004314:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    80004316:	4314                	lw	a3,0(a4)
    80004318:	04b68c63          	beq	a3,a1,80004370 <log_write+0xb0>
  for (i = 0; i < log.lh.n; i++) {
    8000431c:	2785                	addiw	a5,a5,1
    8000431e:	0711                	addi	a4,a4,4
    80004320:	fef61be3          	bne	a2,a5,80004316 <log_write+0x56>
      break;
  }
  log.lh.block[i] = b->blockno;
    80004324:	0621                	addi	a2,a2,8
    80004326:	060a                	slli	a2,a2,0x2
    80004328:	00194797          	auipc	a5,0x194
    8000432c:	dc078793          	addi	a5,a5,-576 # 801980e8 <log>
    80004330:	97b2                	add	a5,a5,a2
    80004332:	44d8                	lw	a4,12(s1)
    80004334:	cb98                	sw	a4,16(a5)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    80004336:	8526                	mv	a0,s1
    80004338:	fffff097          	auipc	ra,0xfffff
    8000433c:	dcc080e7          	jalr	-564(ra) # 80003104 <bpin>
    log.lh.n++;
    80004340:	00194717          	auipc	a4,0x194
    80004344:	da870713          	addi	a4,a4,-600 # 801980e8 <log>
    80004348:	575c                	lw	a5,44(a4)
    8000434a:	2785                	addiw	a5,a5,1
    8000434c:	d75c                	sw	a5,44(a4)
    8000434e:	a82d                	j	80004388 <log_write+0xc8>
    panic("too big a transaction");
    80004350:	00004517          	auipc	a0,0x4
    80004354:	31850513          	addi	a0,a0,792 # 80008668 <syscalls+0x1f0>
    80004358:	ffffc097          	auipc	ra,0xffffc
    8000435c:	1e4080e7          	jalr	484(ra) # 8000053c <panic>
    panic("log_write outside of trans");
    80004360:	00004517          	auipc	a0,0x4
    80004364:	32050513          	addi	a0,a0,800 # 80008680 <syscalls+0x208>
    80004368:	ffffc097          	auipc	ra,0xffffc
    8000436c:	1d4080e7          	jalr	468(ra) # 8000053c <panic>
  log.lh.block[i] = b->blockno;
    80004370:	00878693          	addi	a3,a5,8
    80004374:	068a                	slli	a3,a3,0x2
    80004376:	00194717          	auipc	a4,0x194
    8000437a:	d7270713          	addi	a4,a4,-654 # 801980e8 <log>
    8000437e:	9736                	add	a4,a4,a3
    80004380:	44d4                	lw	a3,12(s1)
    80004382:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    80004384:	faf609e3          	beq	a2,a5,80004336 <log_write+0x76>
  }
  release(&log.lock);
    80004388:	00194517          	auipc	a0,0x194
    8000438c:	d6050513          	addi	a0,a0,-672 # 801980e8 <log>
    80004390:	ffffd097          	auipc	ra,0xffffd
    80004394:	8f6080e7          	jalr	-1802(ra) # 80000c86 <release>
}
    80004398:	60e2                	ld	ra,24(sp)
    8000439a:	6442                	ld	s0,16(sp)
    8000439c:	64a2                	ld	s1,8(sp)
    8000439e:	6902                	ld	s2,0(sp)
    800043a0:	6105                	addi	sp,sp,32
    800043a2:	8082                	ret

00000000800043a4 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    800043a4:	1101                	addi	sp,sp,-32
    800043a6:	ec06                	sd	ra,24(sp)
    800043a8:	e822                	sd	s0,16(sp)
    800043aa:	e426                	sd	s1,8(sp)
    800043ac:	e04a                	sd	s2,0(sp)
    800043ae:	1000                	addi	s0,sp,32
    800043b0:	84aa                	mv	s1,a0
    800043b2:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    800043b4:	00004597          	auipc	a1,0x4
    800043b8:	2ec58593          	addi	a1,a1,748 # 800086a0 <syscalls+0x228>
    800043bc:	0521                	addi	a0,a0,8
    800043be:	ffffc097          	auipc	ra,0xffffc
    800043c2:	784080e7          	jalr	1924(ra) # 80000b42 <initlock>
  lk->name = name;
    800043c6:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    800043ca:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800043ce:	0204a423          	sw	zero,40(s1)
}
    800043d2:	60e2                	ld	ra,24(sp)
    800043d4:	6442                	ld	s0,16(sp)
    800043d6:	64a2                	ld	s1,8(sp)
    800043d8:	6902                	ld	s2,0(sp)
    800043da:	6105                	addi	sp,sp,32
    800043dc:	8082                	ret

00000000800043de <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    800043de:	1101                	addi	sp,sp,-32
    800043e0:	ec06                	sd	ra,24(sp)
    800043e2:	e822                	sd	s0,16(sp)
    800043e4:	e426                	sd	s1,8(sp)
    800043e6:	e04a                	sd	s2,0(sp)
    800043e8:	1000                	addi	s0,sp,32
    800043ea:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800043ec:	00850913          	addi	s2,a0,8
    800043f0:	854a                	mv	a0,s2
    800043f2:	ffffc097          	auipc	ra,0xffffc
    800043f6:	7e0080e7          	jalr	2016(ra) # 80000bd2 <acquire>
  while (lk->locked) {
    800043fa:	409c                	lw	a5,0(s1)
    800043fc:	cb89                	beqz	a5,8000440e <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    800043fe:	85ca                	mv	a1,s2
    80004400:	8526                	mv	a0,s1
    80004402:	ffffe097          	auipc	ra,0xffffe
    80004406:	d2e080e7          	jalr	-722(ra) # 80002130 <sleep>
  while (lk->locked) {
    8000440a:	409c                	lw	a5,0(s1)
    8000440c:	fbed                	bnez	a5,800043fe <acquiresleep+0x20>
  }
  lk->locked = 1;
    8000440e:	4785                	li	a5,1
    80004410:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80004412:	ffffd097          	auipc	ra,0xffffd
    80004416:	5d0080e7          	jalr	1488(ra) # 800019e2 <myproc>
    8000441a:	591c                	lw	a5,48(a0)
    8000441c:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    8000441e:	854a                	mv	a0,s2
    80004420:	ffffd097          	auipc	ra,0xffffd
    80004424:	866080e7          	jalr	-1946(ra) # 80000c86 <release>
}
    80004428:	60e2                	ld	ra,24(sp)
    8000442a:	6442                	ld	s0,16(sp)
    8000442c:	64a2                	ld	s1,8(sp)
    8000442e:	6902                	ld	s2,0(sp)
    80004430:	6105                	addi	sp,sp,32
    80004432:	8082                	ret

0000000080004434 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80004434:	1101                	addi	sp,sp,-32
    80004436:	ec06                	sd	ra,24(sp)
    80004438:	e822                	sd	s0,16(sp)
    8000443a:	e426                	sd	s1,8(sp)
    8000443c:	e04a                	sd	s2,0(sp)
    8000443e:	1000                	addi	s0,sp,32
    80004440:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004442:	00850913          	addi	s2,a0,8
    80004446:	854a                	mv	a0,s2
    80004448:	ffffc097          	auipc	ra,0xffffc
    8000444c:	78a080e7          	jalr	1930(ra) # 80000bd2 <acquire>
  lk->locked = 0;
    80004450:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004454:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80004458:	8526                	mv	a0,s1
    8000445a:	ffffe097          	auipc	ra,0xffffe
    8000445e:	d3a080e7          	jalr	-710(ra) # 80002194 <wakeup>
  release(&lk->lk);
    80004462:	854a                	mv	a0,s2
    80004464:	ffffd097          	auipc	ra,0xffffd
    80004468:	822080e7          	jalr	-2014(ra) # 80000c86 <release>
}
    8000446c:	60e2                	ld	ra,24(sp)
    8000446e:	6442                	ld	s0,16(sp)
    80004470:	64a2                	ld	s1,8(sp)
    80004472:	6902                	ld	s2,0(sp)
    80004474:	6105                	addi	sp,sp,32
    80004476:	8082                	ret

0000000080004478 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80004478:	7179                	addi	sp,sp,-48
    8000447a:	f406                	sd	ra,40(sp)
    8000447c:	f022                	sd	s0,32(sp)
    8000447e:	ec26                	sd	s1,24(sp)
    80004480:	e84a                	sd	s2,16(sp)
    80004482:	e44e                	sd	s3,8(sp)
    80004484:	1800                	addi	s0,sp,48
    80004486:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80004488:	00850913          	addi	s2,a0,8
    8000448c:	854a                	mv	a0,s2
    8000448e:	ffffc097          	auipc	ra,0xffffc
    80004492:	744080e7          	jalr	1860(ra) # 80000bd2 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80004496:	409c                	lw	a5,0(s1)
    80004498:	ef99                	bnez	a5,800044b6 <holdingsleep+0x3e>
    8000449a:	4481                	li	s1,0
  release(&lk->lk);
    8000449c:	854a                	mv	a0,s2
    8000449e:	ffffc097          	auipc	ra,0xffffc
    800044a2:	7e8080e7          	jalr	2024(ra) # 80000c86 <release>
  return r;
}
    800044a6:	8526                	mv	a0,s1
    800044a8:	70a2                	ld	ra,40(sp)
    800044aa:	7402                	ld	s0,32(sp)
    800044ac:	64e2                	ld	s1,24(sp)
    800044ae:	6942                	ld	s2,16(sp)
    800044b0:	69a2                	ld	s3,8(sp)
    800044b2:	6145                	addi	sp,sp,48
    800044b4:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    800044b6:	0284a983          	lw	s3,40(s1)
    800044ba:	ffffd097          	auipc	ra,0xffffd
    800044be:	528080e7          	jalr	1320(ra) # 800019e2 <myproc>
    800044c2:	5904                	lw	s1,48(a0)
    800044c4:	413484b3          	sub	s1,s1,s3
    800044c8:	0014b493          	seqz	s1,s1
    800044cc:	bfc1                	j	8000449c <holdingsleep+0x24>

00000000800044ce <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    800044ce:	1141                	addi	sp,sp,-16
    800044d0:	e406                	sd	ra,8(sp)
    800044d2:	e022                	sd	s0,0(sp)
    800044d4:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    800044d6:	00004597          	auipc	a1,0x4
    800044da:	1da58593          	addi	a1,a1,474 # 800086b0 <syscalls+0x238>
    800044de:	00194517          	auipc	a0,0x194
    800044e2:	d5250513          	addi	a0,a0,-686 # 80198230 <ftable>
    800044e6:	ffffc097          	auipc	ra,0xffffc
    800044ea:	65c080e7          	jalr	1628(ra) # 80000b42 <initlock>
}
    800044ee:	60a2                	ld	ra,8(sp)
    800044f0:	6402                	ld	s0,0(sp)
    800044f2:	0141                	addi	sp,sp,16
    800044f4:	8082                	ret

00000000800044f6 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    800044f6:	1101                	addi	sp,sp,-32
    800044f8:	ec06                	sd	ra,24(sp)
    800044fa:	e822                	sd	s0,16(sp)
    800044fc:	e426                	sd	s1,8(sp)
    800044fe:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80004500:	00194517          	auipc	a0,0x194
    80004504:	d3050513          	addi	a0,a0,-720 # 80198230 <ftable>
    80004508:	ffffc097          	auipc	ra,0xffffc
    8000450c:	6ca080e7          	jalr	1738(ra) # 80000bd2 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004510:	00194497          	auipc	s1,0x194
    80004514:	d3848493          	addi	s1,s1,-712 # 80198248 <ftable+0x18>
    80004518:	00195717          	auipc	a4,0x195
    8000451c:	cd070713          	addi	a4,a4,-816 # 801991e8 <disk>
    if(f->ref == 0){
    80004520:	40dc                	lw	a5,4(s1)
    80004522:	cf99                	beqz	a5,80004540 <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004524:	02848493          	addi	s1,s1,40
    80004528:	fee49ce3          	bne	s1,a4,80004520 <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    8000452c:	00194517          	auipc	a0,0x194
    80004530:	d0450513          	addi	a0,a0,-764 # 80198230 <ftable>
    80004534:	ffffc097          	auipc	ra,0xffffc
    80004538:	752080e7          	jalr	1874(ra) # 80000c86 <release>
  return 0;
    8000453c:	4481                	li	s1,0
    8000453e:	a819                	j	80004554 <filealloc+0x5e>
      f->ref = 1;
    80004540:	4785                	li	a5,1
    80004542:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80004544:	00194517          	auipc	a0,0x194
    80004548:	cec50513          	addi	a0,a0,-788 # 80198230 <ftable>
    8000454c:	ffffc097          	auipc	ra,0xffffc
    80004550:	73a080e7          	jalr	1850(ra) # 80000c86 <release>
}
    80004554:	8526                	mv	a0,s1
    80004556:	60e2                	ld	ra,24(sp)
    80004558:	6442                	ld	s0,16(sp)
    8000455a:	64a2                	ld	s1,8(sp)
    8000455c:	6105                	addi	sp,sp,32
    8000455e:	8082                	ret

0000000080004560 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80004560:	1101                	addi	sp,sp,-32
    80004562:	ec06                	sd	ra,24(sp)
    80004564:	e822                	sd	s0,16(sp)
    80004566:	e426                	sd	s1,8(sp)
    80004568:	1000                	addi	s0,sp,32
    8000456a:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    8000456c:	00194517          	auipc	a0,0x194
    80004570:	cc450513          	addi	a0,a0,-828 # 80198230 <ftable>
    80004574:	ffffc097          	auipc	ra,0xffffc
    80004578:	65e080e7          	jalr	1630(ra) # 80000bd2 <acquire>
  if(f->ref < 1)
    8000457c:	40dc                	lw	a5,4(s1)
    8000457e:	02f05263          	blez	a5,800045a2 <filedup+0x42>
    panic("filedup");
  f->ref++;
    80004582:	2785                	addiw	a5,a5,1
    80004584:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80004586:	00194517          	auipc	a0,0x194
    8000458a:	caa50513          	addi	a0,a0,-854 # 80198230 <ftable>
    8000458e:	ffffc097          	auipc	ra,0xffffc
    80004592:	6f8080e7          	jalr	1784(ra) # 80000c86 <release>
  return f;
}
    80004596:	8526                	mv	a0,s1
    80004598:	60e2                	ld	ra,24(sp)
    8000459a:	6442                	ld	s0,16(sp)
    8000459c:	64a2                	ld	s1,8(sp)
    8000459e:	6105                	addi	sp,sp,32
    800045a0:	8082                	ret
    panic("filedup");
    800045a2:	00004517          	auipc	a0,0x4
    800045a6:	11650513          	addi	a0,a0,278 # 800086b8 <syscalls+0x240>
    800045aa:	ffffc097          	auipc	ra,0xffffc
    800045ae:	f92080e7          	jalr	-110(ra) # 8000053c <panic>

00000000800045b2 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    800045b2:	7139                	addi	sp,sp,-64
    800045b4:	fc06                	sd	ra,56(sp)
    800045b6:	f822                	sd	s0,48(sp)
    800045b8:	f426                	sd	s1,40(sp)
    800045ba:	f04a                	sd	s2,32(sp)
    800045bc:	ec4e                	sd	s3,24(sp)
    800045be:	e852                	sd	s4,16(sp)
    800045c0:	e456                	sd	s5,8(sp)
    800045c2:	0080                	addi	s0,sp,64
    800045c4:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    800045c6:	00194517          	auipc	a0,0x194
    800045ca:	c6a50513          	addi	a0,a0,-918 # 80198230 <ftable>
    800045ce:	ffffc097          	auipc	ra,0xffffc
    800045d2:	604080e7          	jalr	1540(ra) # 80000bd2 <acquire>
  if(f->ref < 1)
    800045d6:	40dc                	lw	a5,4(s1)
    800045d8:	06f05163          	blez	a5,8000463a <fileclose+0x88>
    panic("fileclose");
  if(--f->ref > 0){
    800045dc:	37fd                	addiw	a5,a5,-1
    800045de:	0007871b          	sext.w	a4,a5
    800045e2:	c0dc                	sw	a5,4(s1)
    800045e4:	06e04363          	bgtz	a4,8000464a <fileclose+0x98>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    800045e8:	0004a903          	lw	s2,0(s1)
    800045ec:	0094ca83          	lbu	s5,9(s1)
    800045f0:	0104ba03          	ld	s4,16(s1)
    800045f4:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    800045f8:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    800045fc:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80004600:	00194517          	auipc	a0,0x194
    80004604:	c3050513          	addi	a0,a0,-976 # 80198230 <ftable>
    80004608:	ffffc097          	auipc	ra,0xffffc
    8000460c:	67e080e7          	jalr	1662(ra) # 80000c86 <release>

  if(ff.type == FD_PIPE){
    80004610:	4785                	li	a5,1
    80004612:	04f90d63          	beq	s2,a5,8000466c <fileclose+0xba>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80004616:	3979                	addiw	s2,s2,-2
    80004618:	4785                	li	a5,1
    8000461a:	0527e063          	bltu	a5,s2,8000465a <fileclose+0xa8>
    begin_op();
    8000461e:	00000097          	auipc	ra,0x0
    80004622:	ad0080e7          	jalr	-1328(ra) # 800040ee <begin_op>
    iput(ff.ip);
    80004626:	854e                	mv	a0,s3
    80004628:	fffff097          	auipc	ra,0xfffff
    8000462c:	2da080e7          	jalr	730(ra) # 80003902 <iput>
    end_op();
    80004630:	00000097          	auipc	ra,0x0
    80004634:	b38080e7          	jalr	-1224(ra) # 80004168 <end_op>
    80004638:	a00d                	j	8000465a <fileclose+0xa8>
    panic("fileclose");
    8000463a:	00004517          	auipc	a0,0x4
    8000463e:	08650513          	addi	a0,a0,134 # 800086c0 <syscalls+0x248>
    80004642:	ffffc097          	auipc	ra,0xffffc
    80004646:	efa080e7          	jalr	-262(ra) # 8000053c <panic>
    release(&ftable.lock);
    8000464a:	00194517          	auipc	a0,0x194
    8000464e:	be650513          	addi	a0,a0,-1050 # 80198230 <ftable>
    80004652:	ffffc097          	auipc	ra,0xffffc
    80004656:	634080e7          	jalr	1588(ra) # 80000c86 <release>
  }
}
    8000465a:	70e2                	ld	ra,56(sp)
    8000465c:	7442                	ld	s0,48(sp)
    8000465e:	74a2                	ld	s1,40(sp)
    80004660:	7902                	ld	s2,32(sp)
    80004662:	69e2                	ld	s3,24(sp)
    80004664:	6a42                	ld	s4,16(sp)
    80004666:	6aa2                	ld	s5,8(sp)
    80004668:	6121                	addi	sp,sp,64
    8000466a:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    8000466c:	85d6                	mv	a1,s5
    8000466e:	8552                	mv	a0,s4
    80004670:	00000097          	auipc	ra,0x0
    80004674:	348080e7          	jalr	840(ra) # 800049b8 <pipeclose>
    80004678:	b7cd                	j	8000465a <fileclose+0xa8>

000000008000467a <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    8000467a:	715d                	addi	sp,sp,-80
    8000467c:	e486                	sd	ra,72(sp)
    8000467e:	e0a2                	sd	s0,64(sp)
    80004680:	fc26                	sd	s1,56(sp)
    80004682:	f84a                	sd	s2,48(sp)
    80004684:	f44e                	sd	s3,40(sp)
    80004686:	0880                	addi	s0,sp,80
    80004688:	84aa                	mv	s1,a0
    8000468a:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    8000468c:	ffffd097          	auipc	ra,0xffffd
    80004690:	356080e7          	jalr	854(ra) # 800019e2 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80004694:	409c                	lw	a5,0(s1)
    80004696:	37f9                	addiw	a5,a5,-2
    80004698:	4705                	li	a4,1
    8000469a:	04f76763          	bltu	a4,a5,800046e8 <filestat+0x6e>
    8000469e:	892a                	mv	s2,a0
    ilock(f->ip);
    800046a0:	6c88                	ld	a0,24(s1)
    800046a2:	fffff097          	auipc	ra,0xfffff
    800046a6:	0a6080e7          	jalr	166(ra) # 80003748 <ilock>
    stati(f->ip, &st);
    800046aa:	fb840593          	addi	a1,s0,-72
    800046ae:	6c88                	ld	a0,24(s1)
    800046b0:	fffff097          	auipc	ra,0xfffff
    800046b4:	322080e7          	jalr	802(ra) # 800039d2 <stati>
    iunlock(f->ip);
    800046b8:	6c88                	ld	a0,24(s1)
    800046ba:	fffff097          	auipc	ra,0xfffff
    800046be:	150080e7          	jalr	336(ra) # 8000380a <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    800046c2:	46e1                	li	a3,24
    800046c4:	fb840613          	addi	a2,s0,-72
    800046c8:	85ce                	mv	a1,s3
    800046ca:	05093503          	ld	a0,80(s2)
    800046ce:	ffffd097          	auipc	ra,0xffffd
    800046d2:	fc4080e7          	jalr	-60(ra) # 80001692 <copyout>
    800046d6:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    800046da:	60a6                	ld	ra,72(sp)
    800046dc:	6406                	ld	s0,64(sp)
    800046de:	74e2                	ld	s1,56(sp)
    800046e0:	7942                	ld	s2,48(sp)
    800046e2:	79a2                	ld	s3,40(sp)
    800046e4:	6161                	addi	sp,sp,80
    800046e6:	8082                	ret
  return -1;
    800046e8:	557d                	li	a0,-1
    800046ea:	bfc5                	j	800046da <filestat+0x60>

00000000800046ec <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    800046ec:	7179                	addi	sp,sp,-48
    800046ee:	f406                	sd	ra,40(sp)
    800046f0:	f022                	sd	s0,32(sp)
    800046f2:	ec26                	sd	s1,24(sp)
    800046f4:	e84a                	sd	s2,16(sp)
    800046f6:	e44e                	sd	s3,8(sp)
    800046f8:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    800046fa:	00854783          	lbu	a5,8(a0)
    800046fe:	c3d5                	beqz	a5,800047a2 <fileread+0xb6>
    80004700:	84aa                	mv	s1,a0
    80004702:	89ae                	mv	s3,a1
    80004704:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    80004706:	411c                	lw	a5,0(a0)
    80004708:	4705                	li	a4,1
    8000470a:	04e78963          	beq	a5,a4,8000475c <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    8000470e:	470d                	li	a4,3
    80004710:	04e78d63          	beq	a5,a4,8000476a <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80004714:	4709                	li	a4,2
    80004716:	06e79e63          	bne	a5,a4,80004792 <fileread+0xa6>
    ilock(f->ip);
    8000471a:	6d08                	ld	a0,24(a0)
    8000471c:	fffff097          	auipc	ra,0xfffff
    80004720:	02c080e7          	jalr	44(ra) # 80003748 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80004724:	874a                	mv	a4,s2
    80004726:	5094                	lw	a3,32(s1)
    80004728:	864e                	mv	a2,s3
    8000472a:	4585                	li	a1,1
    8000472c:	6c88                	ld	a0,24(s1)
    8000472e:	fffff097          	auipc	ra,0xfffff
    80004732:	2ce080e7          	jalr	718(ra) # 800039fc <readi>
    80004736:	892a                	mv	s2,a0
    80004738:	00a05563          	blez	a0,80004742 <fileread+0x56>
      f->off += r;
    8000473c:	509c                	lw	a5,32(s1)
    8000473e:	9fa9                	addw	a5,a5,a0
    80004740:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80004742:	6c88                	ld	a0,24(s1)
    80004744:	fffff097          	auipc	ra,0xfffff
    80004748:	0c6080e7          	jalr	198(ra) # 8000380a <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    8000474c:	854a                	mv	a0,s2
    8000474e:	70a2                	ld	ra,40(sp)
    80004750:	7402                	ld	s0,32(sp)
    80004752:	64e2                	ld	s1,24(sp)
    80004754:	6942                	ld	s2,16(sp)
    80004756:	69a2                	ld	s3,8(sp)
    80004758:	6145                	addi	sp,sp,48
    8000475a:	8082                	ret
    r = piperead(f->pipe, addr, n);
    8000475c:	6908                	ld	a0,16(a0)
    8000475e:	00000097          	auipc	ra,0x0
    80004762:	3c2080e7          	jalr	962(ra) # 80004b20 <piperead>
    80004766:	892a                	mv	s2,a0
    80004768:	b7d5                	j	8000474c <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    8000476a:	02451783          	lh	a5,36(a0)
    8000476e:	03079693          	slli	a3,a5,0x30
    80004772:	92c1                	srli	a3,a3,0x30
    80004774:	4725                	li	a4,9
    80004776:	02d76863          	bltu	a4,a3,800047a6 <fileread+0xba>
    8000477a:	0792                	slli	a5,a5,0x4
    8000477c:	00194717          	auipc	a4,0x194
    80004780:	a1470713          	addi	a4,a4,-1516 # 80198190 <devsw>
    80004784:	97ba                	add	a5,a5,a4
    80004786:	639c                	ld	a5,0(a5)
    80004788:	c38d                	beqz	a5,800047aa <fileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    8000478a:	4505                	li	a0,1
    8000478c:	9782                	jalr	a5
    8000478e:	892a                	mv	s2,a0
    80004790:	bf75                	j	8000474c <fileread+0x60>
    panic("fileread");
    80004792:	00004517          	auipc	a0,0x4
    80004796:	f3e50513          	addi	a0,a0,-194 # 800086d0 <syscalls+0x258>
    8000479a:	ffffc097          	auipc	ra,0xffffc
    8000479e:	da2080e7          	jalr	-606(ra) # 8000053c <panic>
    return -1;
    800047a2:	597d                	li	s2,-1
    800047a4:	b765                	j	8000474c <fileread+0x60>
      return -1;
    800047a6:	597d                	li	s2,-1
    800047a8:	b755                	j	8000474c <fileread+0x60>
    800047aa:	597d                	li	s2,-1
    800047ac:	b745                	j	8000474c <fileread+0x60>

00000000800047ae <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if(f->writable == 0)
    800047ae:	00954783          	lbu	a5,9(a0)
    800047b2:	10078e63          	beqz	a5,800048ce <filewrite+0x120>
{
    800047b6:	715d                	addi	sp,sp,-80
    800047b8:	e486                	sd	ra,72(sp)
    800047ba:	e0a2                	sd	s0,64(sp)
    800047bc:	fc26                	sd	s1,56(sp)
    800047be:	f84a                	sd	s2,48(sp)
    800047c0:	f44e                	sd	s3,40(sp)
    800047c2:	f052                	sd	s4,32(sp)
    800047c4:	ec56                	sd	s5,24(sp)
    800047c6:	e85a                	sd	s6,16(sp)
    800047c8:	e45e                	sd	s7,8(sp)
    800047ca:	e062                	sd	s8,0(sp)
    800047cc:	0880                	addi	s0,sp,80
    800047ce:	892a                	mv	s2,a0
    800047d0:	8b2e                	mv	s6,a1
    800047d2:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    800047d4:	411c                	lw	a5,0(a0)
    800047d6:	4705                	li	a4,1
    800047d8:	02e78263          	beq	a5,a4,800047fc <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    800047dc:	470d                	li	a4,3
    800047de:	02e78563          	beq	a5,a4,80004808 <filewrite+0x5a>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    800047e2:	4709                	li	a4,2
    800047e4:	0ce79d63          	bne	a5,a4,800048be <filewrite+0x110>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    800047e8:	0ac05b63          	blez	a2,8000489e <filewrite+0xf0>
    int i = 0;
    800047ec:	4981                	li	s3,0
      int n1 = n - i;
      if(n1 > max)
    800047ee:	6b85                	lui	s7,0x1
    800047f0:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    800047f4:	6c05                	lui	s8,0x1
    800047f6:	c00c0c1b          	addiw	s8,s8,-1024 # c00 <_entry-0x7ffff400>
    800047fa:	a851                	j	8000488e <filewrite+0xe0>
    ret = pipewrite(f->pipe, addr, n);
    800047fc:	6908                	ld	a0,16(a0)
    800047fe:	00000097          	auipc	ra,0x0
    80004802:	22a080e7          	jalr	554(ra) # 80004a28 <pipewrite>
    80004806:	a045                	j	800048a6 <filewrite+0xf8>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80004808:	02451783          	lh	a5,36(a0)
    8000480c:	03079693          	slli	a3,a5,0x30
    80004810:	92c1                	srli	a3,a3,0x30
    80004812:	4725                	li	a4,9
    80004814:	0ad76f63          	bltu	a4,a3,800048d2 <filewrite+0x124>
    80004818:	0792                	slli	a5,a5,0x4
    8000481a:	00194717          	auipc	a4,0x194
    8000481e:	97670713          	addi	a4,a4,-1674 # 80198190 <devsw>
    80004822:	97ba                	add	a5,a5,a4
    80004824:	679c                	ld	a5,8(a5)
    80004826:	cbc5                	beqz	a5,800048d6 <filewrite+0x128>
    ret = devsw[f->major].write(1, addr, n);
    80004828:	4505                	li	a0,1
    8000482a:	9782                	jalr	a5
    8000482c:	a8ad                	j	800048a6 <filewrite+0xf8>
      if(n1 > max)
    8000482e:	00048a9b          	sext.w	s5,s1
        n1 = max;

      begin_op();
    80004832:	00000097          	auipc	ra,0x0
    80004836:	8bc080e7          	jalr	-1860(ra) # 800040ee <begin_op>
      ilock(f->ip);
    8000483a:	01893503          	ld	a0,24(s2)
    8000483e:	fffff097          	auipc	ra,0xfffff
    80004842:	f0a080e7          	jalr	-246(ra) # 80003748 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004846:	8756                	mv	a4,s5
    80004848:	02092683          	lw	a3,32(s2)
    8000484c:	01698633          	add	a2,s3,s6
    80004850:	4585                	li	a1,1
    80004852:	01893503          	ld	a0,24(s2)
    80004856:	fffff097          	auipc	ra,0xfffff
    8000485a:	29e080e7          	jalr	670(ra) # 80003af4 <writei>
    8000485e:	84aa                	mv	s1,a0
    80004860:	00a05763          	blez	a0,8000486e <filewrite+0xc0>
        f->off += r;
    80004864:	02092783          	lw	a5,32(s2)
    80004868:	9fa9                	addw	a5,a5,a0
    8000486a:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    8000486e:	01893503          	ld	a0,24(s2)
    80004872:	fffff097          	auipc	ra,0xfffff
    80004876:	f98080e7          	jalr	-104(ra) # 8000380a <iunlock>
      end_op();
    8000487a:	00000097          	auipc	ra,0x0
    8000487e:	8ee080e7          	jalr	-1810(ra) # 80004168 <end_op>

      if(r != n1){
    80004882:	009a9f63          	bne	s5,s1,800048a0 <filewrite+0xf2>
        // error from writei
        break;
      }
      i += r;
    80004886:	013489bb          	addw	s3,s1,s3
    while(i < n){
    8000488a:	0149db63          	bge	s3,s4,800048a0 <filewrite+0xf2>
      int n1 = n - i;
    8000488e:	413a04bb          	subw	s1,s4,s3
      if(n1 > max)
    80004892:	0004879b          	sext.w	a5,s1
    80004896:	f8fbdce3          	bge	s7,a5,8000482e <filewrite+0x80>
    8000489a:	84e2                	mv	s1,s8
    8000489c:	bf49                	j	8000482e <filewrite+0x80>
    int i = 0;
    8000489e:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    800048a0:	033a1d63          	bne	s4,s3,800048da <filewrite+0x12c>
    800048a4:	8552                	mv	a0,s4
  } else {
    panic("filewrite");
  }

  return ret;
}
    800048a6:	60a6                	ld	ra,72(sp)
    800048a8:	6406                	ld	s0,64(sp)
    800048aa:	74e2                	ld	s1,56(sp)
    800048ac:	7942                	ld	s2,48(sp)
    800048ae:	79a2                	ld	s3,40(sp)
    800048b0:	7a02                	ld	s4,32(sp)
    800048b2:	6ae2                	ld	s5,24(sp)
    800048b4:	6b42                	ld	s6,16(sp)
    800048b6:	6ba2                	ld	s7,8(sp)
    800048b8:	6c02                	ld	s8,0(sp)
    800048ba:	6161                	addi	sp,sp,80
    800048bc:	8082                	ret
    panic("filewrite");
    800048be:	00004517          	auipc	a0,0x4
    800048c2:	e2250513          	addi	a0,a0,-478 # 800086e0 <syscalls+0x268>
    800048c6:	ffffc097          	auipc	ra,0xffffc
    800048ca:	c76080e7          	jalr	-906(ra) # 8000053c <panic>
    return -1;
    800048ce:	557d                	li	a0,-1
}
    800048d0:	8082                	ret
      return -1;
    800048d2:	557d                	li	a0,-1
    800048d4:	bfc9                	j	800048a6 <filewrite+0xf8>
    800048d6:	557d                	li	a0,-1
    800048d8:	b7f9                	j	800048a6 <filewrite+0xf8>
    ret = (i == n ? n : -1);
    800048da:	557d                	li	a0,-1
    800048dc:	b7e9                	j	800048a6 <filewrite+0xf8>

00000000800048de <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    800048de:	7179                	addi	sp,sp,-48
    800048e0:	f406                	sd	ra,40(sp)
    800048e2:	f022                	sd	s0,32(sp)
    800048e4:	ec26                	sd	s1,24(sp)
    800048e6:	e84a                	sd	s2,16(sp)
    800048e8:	e44e                	sd	s3,8(sp)
    800048ea:	e052                	sd	s4,0(sp)
    800048ec:	1800                	addi	s0,sp,48
    800048ee:	84aa                	mv	s1,a0
    800048f0:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    800048f2:	0005b023          	sd	zero,0(a1)
    800048f6:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    800048fa:	00000097          	auipc	ra,0x0
    800048fe:	bfc080e7          	jalr	-1028(ra) # 800044f6 <filealloc>
    80004902:	e088                	sd	a0,0(s1)
    80004904:	c551                	beqz	a0,80004990 <pipealloc+0xb2>
    80004906:	00000097          	auipc	ra,0x0
    8000490a:	bf0080e7          	jalr	-1040(ra) # 800044f6 <filealloc>
    8000490e:	00aa3023          	sd	a0,0(s4)
    80004912:	c92d                	beqz	a0,80004984 <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80004914:	ffffc097          	auipc	ra,0xffffc
    80004918:	1ce080e7          	jalr	462(ra) # 80000ae2 <kalloc>
    8000491c:	892a                	mv	s2,a0
    8000491e:	c125                	beqz	a0,8000497e <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    80004920:	4985                	li	s3,1
    80004922:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80004926:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    8000492a:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    8000492e:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80004932:	00004597          	auipc	a1,0x4
    80004936:	dbe58593          	addi	a1,a1,-578 # 800086f0 <syscalls+0x278>
    8000493a:	ffffc097          	auipc	ra,0xffffc
    8000493e:	208080e7          	jalr	520(ra) # 80000b42 <initlock>
  (*f0)->type = FD_PIPE;
    80004942:	609c                	ld	a5,0(s1)
    80004944:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80004948:	609c                	ld	a5,0(s1)
    8000494a:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    8000494e:	609c                	ld	a5,0(s1)
    80004950:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004954:	609c                	ld	a5,0(s1)
    80004956:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    8000495a:	000a3783          	ld	a5,0(s4)
    8000495e:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80004962:	000a3783          	ld	a5,0(s4)
    80004966:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    8000496a:	000a3783          	ld	a5,0(s4)
    8000496e:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80004972:	000a3783          	ld	a5,0(s4)
    80004976:	0127b823          	sd	s2,16(a5)
  return 0;
    8000497a:	4501                	li	a0,0
    8000497c:	a025                	j	800049a4 <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    8000497e:	6088                	ld	a0,0(s1)
    80004980:	e501                	bnez	a0,80004988 <pipealloc+0xaa>
    80004982:	a039                	j	80004990 <pipealloc+0xb2>
    80004984:	6088                	ld	a0,0(s1)
    80004986:	c51d                	beqz	a0,800049b4 <pipealloc+0xd6>
    fileclose(*f0);
    80004988:	00000097          	auipc	ra,0x0
    8000498c:	c2a080e7          	jalr	-982(ra) # 800045b2 <fileclose>
  if(*f1)
    80004990:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80004994:	557d                	li	a0,-1
  if(*f1)
    80004996:	c799                	beqz	a5,800049a4 <pipealloc+0xc6>
    fileclose(*f1);
    80004998:	853e                	mv	a0,a5
    8000499a:	00000097          	auipc	ra,0x0
    8000499e:	c18080e7          	jalr	-1000(ra) # 800045b2 <fileclose>
  return -1;
    800049a2:	557d                	li	a0,-1
}
    800049a4:	70a2                	ld	ra,40(sp)
    800049a6:	7402                	ld	s0,32(sp)
    800049a8:	64e2                	ld	s1,24(sp)
    800049aa:	6942                	ld	s2,16(sp)
    800049ac:	69a2                	ld	s3,8(sp)
    800049ae:	6a02                	ld	s4,0(sp)
    800049b0:	6145                	addi	sp,sp,48
    800049b2:	8082                	ret
  return -1;
    800049b4:	557d                	li	a0,-1
    800049b6:	b7fd                	j	800049a4 <pipealloc+0xc6>

00000000800049b8 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    800049b8:	1101                	addi	sp,sp,-32
    800049ba:	ec06                	sd	ra,24(sp)
    800049bc:	e822                	sd	s0,16(sp)
    800049be:	e426                	sd	s1,8(sp)
    800049c0:	e04a                	sd	s2,0(sp)
    800049c2:	1000                	addi	s0,sp,32
    800049c4:	84aa                	mv	s1,a0
    800049c6:	892e                	mv	s2,a1
  acquire(&pi->lock);
    800049c8:	ffffc097          	auipc	ra,0xffffc
    800049cc:	20a080e7          	jalr	522(ra) # 80000bd2 <acquire>
  if(writable){
    800049d0:	02090d63          	beqz	s2,80004a0a <pipeclose+0x52>
    pi->writeopen = 0;
    800049d4:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    800049d8:	21848513          	addi	a0,s1,536
    800049dc:	ffffd097          	auipc	ra,0xffffd
    800049e0:	7b8080e7          	jalr	1976(ra) # 80002194 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    800049e4:	2204b783          	ld	a5,544(s1)
    800049e8:	eb95                	bnez	a5,80004a1c <pipeclose+0x64>
    release(&pi->lock);
    800049ea:	8526                	mv	a0,s1
    800049ec:	ffffc097          	auipc	ra,0xffffc
    800049f0:	29a080e7          	jalr	666(ra) # 80000c86 <release>
    kfree((char*)pi);
    800049f4:	8526                	mv	a0,s1
    800049f6:	ffffc097          	auipc	ra,0xffffc
    800049fa:	fee080e7          	jalr	-18(ra) # 800009e4 <kfree>
  } else
    release(&pi->lock);
}
    800049fe:	60e2                	ld	ra,24(sp)
    80004a00:	6442                	ld	s0,16(sp)
    80004a02:	64a2                	ld	s1,8(sp)
    80004a04:	6902                	ld	s2,0(sp)
    80004a06:	6105                	addi	sp,sp,32
    80004a08:	8082                	ret
    pi->readopen = 0;
    80004a0a:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80004a0e:	21c48513          	addi	a0,s1,540
    80004a12:	ffffd097          	auipc	ra,0xffffd
    80004a16:	782080e7          	jalr	1922(ra) # 80002194 <wakeup>
    80004a1a:	b7e9                	j	800049e4 <pipeclose+0x2c>
    release(&pi->lock);
    80004a1c:	8526                	mv	a0,s1
    80004a1e:	ffffc097          	auipc	ra,0xffffc
    80004a22:	268080e7          	jalr	616(ra) # 80000c86 <release>
}
    80004a26:	bfe1                	j	800049fe <pipeclose+0x46>

0000000080004a28 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80004a28:	711d                	addi	sp,sp,-96
    80004a2a:	ec86                	sd	ra,88(sp)
    80004a2c:	e8a2                	sd	s0,80(sp)
    80004a2e:	e4a6                	sd	s1,72(sp)
    80004a30:	e0ca                	sd	s2,64(sp)
    80004a32:	fc4e                	sd	s3,56(sp)
    80004a34:	f852                	sd	s4,48(sp)
    80004a36:	f456                	sd	s5,40(sp)
    80004a38:	f05a                	sd	s6,32(sp)
    80004a3a:	ec5e                	sd	s7,24(sp)
    80004a3c:	e862                	sd	s8,16(sp)
    80004a3e:	1080                	addi	s0,sp,96
    80004a40:	84aa                	mv	s1,a0
    80004a42:	8aae                	mv	s5,a1
    80004a44:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    80004a46:	ffffd097          	auipc	ra,0xffffd
    80004a4a:	f9c080e7          	jalr	-100(ra) # 800019e2 <myproc>
    80004a4e:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80004a50:	8526                	mv	a0,s1
    80004a52:	ffffc097          	auipc	ra,0xffffc
    80004a56:	180080e7          	jalr	384(ra) # 80000bd2 <acquire>
  while(i < n){
    80004a5a:	0b405663          	blez	s4,80004b06 <pipewrite+0xde>
  int i = 0;
    80004a5e:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004a60:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80004a62:	21848c13          	addi	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80004a66:	21c48b93          	addi	s7,s1,540
    80004a6a:	a089                	j	80004aac <pipewrite+0x84>
      release(&pi->lock);
    80004a6c:	8526                	mv	a0,s1
    80004a6e:	ffffc097          	auipc	ra,0xffffc
    80004a72:	218080e7          	jalr	536(ra) # 80000c86 <release>
      return -1;
    80004a76:	597d                	li	s2,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80004a78:	854a                	mv	a0,s2
    80004a7a:	60e6                	ld	ra,88(sp)
    80004a7c:	6446                	ld	s0,80(sp)
    80004a7e:	64a6                	ld	s1,72(sp)
    80004a80:	6906                	ld	s2,64(sp)
    80004a82:	79e2                	ld	s3,56(sp)
    80004a84:	7a42                	ld	s4,48(sp)
    80004a86:	7aa2                	ld	s5,40(sp)
    80004a88:	7b02                	ld	s6,32(sp)
    80004a8a:	6be2                	ld	s7,24(sp)
    80004a8c:	6c42                	ld	s8,16(sp)
    80004a8e:	6125                	addi	sp,sp,96
    80004a90:	8082                	ret
      wakeup(&pi->nread);
    80004a92:	8562                	mv	a0,s8
    80004a94:	ffffd097          	auipc	ra,0xffffd
    80004a98:	700080e7          	jalr	1792(ra) # 80002194 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80004a9c:	85a6                	mv	a1,s1
    80004a9e:	855e                	mv	a0,s7
    80004aa0:	ffffd097          	auipc	ra,0xffffd
    80004aa4:	690080e7          	jalr	1680(ra) # 80002130 <sleep>
  while(i < n){
    80004aa8:	07495063          	bge	s2,s4,80004b08 <pipewrite+0xe0>
    if(pi->readopen == 0 || killed(pr)){
    80004aac:	2204a783          	lw	a5,544(s1)
    80004ab0:	dfd5                	beqz	a5,80004a6c <pipewrite+0x44>
    80004ab2:	854e                	mv	a0,s3
    80004ab4:	ffffe097          	auipc	ra,0xffffe
    80004ab8:	93c080e7          	jalr	-1732(ra) # 800023f0 <killed>
    80004abc:	f945                	bnez	a0,80004a6c <pipewrite+0x44>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    80004abe:	2184a783          	lw	a5,536(s1)
    80004ac2:	21c4a703          	lw	a4,540(s1)
    80004ac6:	2007879b          	addiw	a5,a5,512
    80004aca:	fcf704e3          	beq	a4,a5,80004a92 <pipewrite+0x6a>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004ace:	4685                	li	a3,1
    80004ad0:	01590633          	add	a2,s2,s5
    80004ad4:	faf40593          	addi	a1,s0,-81
    80004ad8:	0509b503          	ld	a0,80(s3)
    80004adc:	ffffd097          	auipc	ra,0xffffd
    80004ae0:	c42080e7          	jalr	-958(ra) # 8000171e <copyin>
    80004ae4:	03650263          	beq	a0,s6,80004b08 <pipewrite+0xe0>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004ae8:	21c4a783          	lw	a5,540(s1)
    80004aec:	0017871b          	addiw	a4,a5,1
    80004af0:	20e4ae23          	sw	a4,540(s1)
    80004af4:	1ff7f793          	andi	a5,a5,511
    80004af8:	97a6                	add	a5,a5,s1
    80004afa:	faf44703          	lbu	a4,-81(s0)
    80004afe:	00e78c23          	sb	a4,24(a5)
      i++;
    80004b02:	2905                	addiw	s2,s2,1
    80004b04:	b755                	j	80004aa8 <pipewrite+0x80>
  int i = 0;
    80004b06:	4901                	li	s2,0
  wakeup(&pi->nread);
    80004b08:	21848513          	addi	a0,s1,536
    80004b0c:	ffffd097          	auipc	ra,0xffffd
    80004b10:	688080e7          	jalr	1672(ra) # 80002194 <wakeup>
  release(&pi->lock);
    80004b14:	8526                	mv	a0,s1
    80004b16:	ffffc097          	auipc	ra,0xffffc
    80004b1a:	170080e7          	jalr	368(ra) # 80000c86 <release>
  return i;
    80004b1e:	bfa9                	j	80004a78 <pipewrite+0x50>

0000000080004b20 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80004b20:	715d                	addi	sp,sp,-80
    80004b22:	e486                	sd	ra,72(sp)
    80004b24:	e0a2                	sd	s0,64(sp)
    80004b26:	fc26                	sd	s1,56(sp)
    80004b28:	f84a                	sd	s2,48(sp)
    80004b2a:	f44e                	sd	s3,40(sp)
    80004b2c:	f052                	sd	s4,32(sp)
    80004b2e:	ec56                	sd	s5,24(sp)
    80004b30:	e85a                	sd	s6,16(sp)
    80004b32:	0880                	addi	s0,sp,80
    80004b34:	84aa                	mv	s1,a0
    80004b36:	892e                	mv	s2,a1
    80004b38:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80004b3a:	ffffd097          	auipc	ra,0xffffd
    80004b3e:	ea8080e7          	jalr	-344(ra) # 800019e2 <myproc>
    80004b42:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80004b44:	8526                	mv	a0,s1
    80004b46:	ffffc097          	auipc	ra,0xffffc
    80004b4a:	08c080e7          	jalr	140(ra) # 80000bd2 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004b4e:	2184a703          	lw	a4,536(s1)
    80004b52:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004b56:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004b5a:	02f71763          	bne	a4,a5,80004b88 <piperead+0x68>
    80004b5e:	2244a783          	lw	a5,548(s1)
    80004b62:	c39d                	beqz	a5,80004b88 <piperead+0x68>
    if(killed(pr)){
    80004b64:	8552                	mv	a0,s4
    80004b66:	ffffe097          	auipc	ra,0xffffe
    80004b6a:	88a080e7          	jalr	-1910(ra) # 800023f0 <killed>
    80004b6e:	e949                	bnez	a0,80004c00 <piperead+0xe0>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004b70:	85a6                	mv	a1,s1
    80004b72:	854e                	mv	a0,s3
    80004b74:	ffffd097          	auipc	ra,0xffffd
    80004b78:	5bc080e7          	jalr	1468(ra) # 80002130 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004b7c:	2184a703          	lw	a4,536(s1)
    80004b80:	21c4a783          	lw	a5,540(s1)
    80004b84:	fcf70de3          	beq	a4,a5,80004b5e <piperead+0x3e>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004b88:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004b8a:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004b8c:	05505463          	blez	s5,80004bd4 <piperead+0xb4>
    if(pi->nread == pi->nwrite)
    80004b90:	2184a783          	lw	a5,536(s1)
    80004b94:	21c4a703          	lw	a4,540(s1)
    80004b98:	02f70e63          	beq	a4,a5,80004bd4 <piperead+0xb4>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80004b9c:	0017871b          	addiw	a4,a5,1
    80004ba0:	20e4ac23          	sw	a4,536(s1)
    80004ba4:	1ff7f793          	andi	a5,a5,511
    80004ba8:	97a6                	add	a5,a5,s1
    80004baa:	0187c783          	lbu	a5,24(a5)
    80004bae:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004bb2:	4685                	li	a3,1
    80004bb4:	fbf40613          	addi	a2,s0,-65
    80004bb8:	85ca                	mv	a1,s2
    80004bba:	050a3503          	ld	a0,80(s4)
    80004bbe:	ffffd097          	auipc	ra,0xffffd
    80004bc2:	ad4080e7          	jalr	-1324(ra) # 80001692 <copyout>
    80004bc6:	01650763          	beq	a0,s6,80004bd4 <piperead+0xb4>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004bca:	2985                	addiw	s3,s3,1
    80004bcc:	0905                	addi	s2,s2,1
    80004bce:	fd3a91e3          	bne	s5,s3,80004b90 <piperead+0x70>
    80004bd2:	89d6                	mv	s3,s5
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80004bd4:	21c48513          	addi	a0,s1,540
    80004bd8:	ffffd097          	auipc	ra,0xffffd
    80004bdc:	5bc080e7          	jalr	1468(ra) # 80002194 <wakeup>
  release(&pi->lock);
    80004be0:	8526                	mv	a0,s1
    80004be2:	ffffc097          	auipc	ra,0xffffc
    80004be6:	0a4080e7          	jalr	164(ra) # 80000c86 <release>
  return i;
}
    80004bea:	854e                	mv	a0,s3
    80004bec:	60a6                	ld	ra,72(sp)
    80004bee:	6406                	ld	s0,64(sp)
    80004bf0:	74e2                	ld	s1,56(sp)
    80004bf2:	7942                	ld	s2,48(sp)
    80004bf4:	79a2                	ld	s3,40(sp)
    80004bf6:	7a02                	ld	s4,32(sp)
    80004bf8:	6ae2                	ld	s5,24(sp)
    80004bfa:	6b42                	ld	s6,16(sp)
    80004bfc:	6161                	addi	sp,sp,80
    80004bfe:	8082                	ret
      release(&pi->lock);
    80004c00:	8526                	mv	a0,s1
    80004c02:	ffffc097          	auipc	ra,0xffffc
    80004c06:	084080e7          	jalr	132(ra) # 80000c86 <release>
      return -1;
    80004c0a:	59fd                	li	s3,-1
    80004c0c:	bff9                	j	80004bea <piperead+0xca>

0000000080004c0e <flags2perm>:
#include "elf.h"
// static 
int loadseg(pde_t *, uint64, struct inode *, uint, uint);

int flags2perm(int flags)
{
    80004c0e:	1141                	addi	sp,sp,-16
    80004c10:	e422                	sd	s0,8(sp)
    80004c12:	0800                	addi	s0,sp,16
    80004c14:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    80004c16:	8905                	andi	a0,a0,1
    80004c18:	050e                	slli	a0,a0,0x3
      perm = PTE_X;
    if(flags & 0x2)
    80004c1a:	8b89                	andi	a5,a5,2
    80004c1c:	c399                	beqz	a5,80004c22 <flags2perm+0x14>
      perm |= PTE_W;
    80004c1e:	00456513          	ori	a0,a0,4
    return perm;
}
    80004c22:	6422                	ld	s0,8(sp)
    80004c24:	0141                	addi	sp,sp,16
    80004c26:	8082                	ret

0000000080004c28 <loadseg>:
loadseg(pagetable_t pagetable, uint64 va, struct inode *ip, uint offset, uint sz)
{
  uint i, n;
  uint64 pa;

  for(i = 0; i < sz; i += PGSIZE){
    80004c28:	c749                	beqz	a4,80004cb2 <loadseg+0x8a>
{
    80004c2a:	711d                	addi	sp,sp,-96
    80004c2c:	ec86                	sd	ra,88(sp)
    80004c2e:	e8a2                	sd	s0,80(sp)
    80004c30:	e4a6                	sd	s1,72(sp)
    80004c32:	e0ca                	sd	s2,64(sp)
    80004c34:	fc4e                	sd	s3,56(sp)
    80004c36:	f852                	sd	s4,48(sp)
    80004c38:	f456                	sd	s5,40(sp)
    80004c3a:	f05a                	sd	s6,32(sp)
    80004c3c:	ec5e                	sd	s7,24(sp)
    80004c3e:	e862                	sd	s8,16(sp)
    80004c40:	e466                	sd	s9,8(sp)
    80004c42:	1080                	addi	s0,sp,96
    80004c44:	8aaa                	mv	s5,a0
    80004c46:	8b2e                	mv	s6,a1
    80004c48:	8bb2                	mv	s7,a2
    80004c4a:	8c36                	mv	s8,a3
    80004c4c:	89ba                	mv	s3,a4
  for(i = 0; i < sz; i += PGSIZE){
    80004c4e:	4901                	li	s2,0
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    if(sz - i < PGSIZE)
    80004c50:	6c85                	lui	s9,0x1
    80004c52:	6a05                	lui	s4,0x1
    80004c54:	a815                	j	80004c88 <loadseg+0x60>
      panic("loadseg: address should exist");
    80004c56:	00004517          	auipc	a0,0x4
    80004c5a:	aa250513          	addi	a0,a0,-1374 # 800086f8 <syscalls+0x280>
    80004c5e:	ffffc097          	auipc	ra,0xffffc
    80004c62:	8de080e7          	jalr	-1826(ra) # 8000053c <panic>
    if(sz - i < PGSIZE)
    80004c66:	2481                	sext.w	s1,s1
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80004c68:	8726                	mv	a4,s1
    80004c6a:	012c06bb          	addw	a3,s8,s2
    80004c6e:	4581                	li	a1,0
    80004c70:	855e                	mv	a0,s7
    80004c72:	fffff097          	auipc	ra,0xfffff
    80004c76:	d8a080e7          	jalr	-630(ra) # 800039fc <readi>
    80004c7a:	2501                	sext.w	a0,a0
    80004c7c:	02951d63          	bne	a0,s1,80004cb6 <loadseg+0x8e>
  for(i = 0; i < sz; i += PGSIZE){
    80004c80:	012a093b          	addw	s2,s4,s2
    80004c84:	03397563          	bgeu	s2,s3,80004cae <loadseg+0x86>
    pa = walkaddr(pagetable, va + i);
    80004c88:	02091593          	slli	a1,s2,0x20
    80004c8c:	9181                	srli	a1,a1,0x20
    80004c8e:	95da                	add	a1,a1,s6
    80004c90:	8556                	mv	a0,s5
    80004c92:	ffffc097          	auipc	ra,0xffffc
    80004c96:	3cc080e7          	jalr	972(ra) # 8000105e <walkaddr>
    80004c9a:	862a                	mv	a2,a0
    if(pa == 0)
    80004c9c:	dd4d                	beqz	a0,80004c56 <loadseg+0x2e>
    if(sz - i < PGSIZE)
    80004c9e:	412984bb          	subw	s1,s3,s2
    80004ca2:	0004879b          	sext.w	a5,s1
    80004ca6:	fcfcf0e3          	bgeu	s9,a5,80004c66 <loadseg+0x3e>
    80004caa:	84d2                	mv	s1,s4
    80004cac:	bf6d                	j	80004c66 <loadseg+0x3e>
      return -1;
  }
  
  return 0;
    80004cae:	4501                	li	a0,0
    80004cb0:	a021                	j	80004cb8 <loadseg+0x90>
    80004cb2:	4501                	li	a0,0
}
    80004cb4:	8082                	ret
      return -1;
    80004cb6:	557d                	li	a0,-1
}
    80004cb8:	60e6                	ld	ra,88(sp)
    80004cba:	6446                	ld	s0,80(sp)
    80004cbc:	64a6                	ld	s1,72(sp)
    80004cbe:	6906                	ld	s2,64(sp)
    80004cc0:	79e2                	ld	s3,56(sp)
    80004cc2:	7a42                	ld	s4,48(sp)
    80004cc4:	7aa2                	ld	s5,40(sp)
    80004cc6:	7b02                	ld	s6,32(sp)
    80004cc8:	6be2                	ld	s7,24(sp)
    80004cca:	6c42                	ld	s8,16(sp)
    80004ccc:	6ca2                	ld	s9,8(sp)
    80004cce:	6125                	addi	sp,sp,96
    80004cd0:	8082                	ret

0000000080004cd2 <exec>:
{
    80004cd2:	7101                	addi	sp,sp,-512
    80004cd4:	ff86                	sd	ra,504(sp)
    80004cd6:	fba2                	sd	s0,496(sp)
    80004cd8:	f7a6                	sd	s1,488(sp)
    80004cda:	f3ca                	sd	s2,480(sp)
    80004cdc:	efce                	sd	s3,472(sp)
    80004cde:	ebd2                	sd	s4,464(sp)
    80004ce0:	e7d6                	sd	s5,456(sp)
    80004ce2:	e3da                	sd	s6,448(sp)
    80004ce4:	ff5e                	sd	s7,440(sp)
    80004ce6:	fb62                	sd	s8,432(sp)
    80004ce8:	f766                	sd	s9,424(sp)
    80004cea:	f36a                	sd	s10,416(sp)
    80004cec:	ef6e                	sd	s11,408(sp)
    80004cee:	0400                	addi	s0,sp,512
    80004cf0:	84aa                	mv	s1,a0
    80004cf2:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80004cf4:	ffffd097          	auipc	ra,0xffffd
    80004cf8:	cee080e7          	jalr	-786(ra) # 800019e2 <myproc>
    80004cfc:	8c2a                	mv	s8,a0
  if (!(strncmp(path,"/init",5)==0 || strncmp(path,"sh",2)==0)) {
    80004cfe:	4615                	li	a2,5
    80004d00:	00004597          	auipc	a1,0x4
    80004d04:	a1858593          	addi	a1,a1,-1512 # 80008718 <syscalls+0x2a0>
    80004d08:	8526                	mv	a0,s1
    80004d0a:	ffffc097          	auipc	ra,0xffffc
    80004d0e:	094080e7          	jalr	148(ra) # 80000d9e <strncmp>
    80004d12:	e149                	bnez	a0,80004d94 <exec+0xc2>
  begin_op();
    80004d14:	fffff097          	auipc	ra,0xfffff
    80004d18:	3da080e7          	jalr	986(ra) # 800040ee <begin_op>
  if((ip = namei(path)) == 0){
    80004d1c:	8526                	mv	a0,s1
    80004d1e:	fffff097          	auipc	ra,0xfffff
    80004d22:	1d0080e7          	jalr	464(ra) # 80003eee <namei>
    80004d26:	8b2a                	mv	s6,a0
    80004d28:	c951                	beqz	a0,80004dbc <exec+0xea>
  ilock(ip);
    80004d2a:	fffff097          	auipc	ra,0xfffff
    80004d2e:	a1e080e7          	jalr	-1506(ra) # 80003748 <ilock>
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80004d32:	04000713          	li	a4,64
    80004d36:	4681                	li	a3,0
    80004d38:	e5040613          	addi	a2,s0,-432
    80004d3c:	4581                	li	a1,0
    80004d3e:	855a                	mv	a0,s6
    80004d40:	fffff097          	auipc	ra,0xfffff
    80004d44:	cbc080e7          	jalr	-836(ra) # 800039fc <readi>
    80004d48:	04000793          	li	a5,64
    80004d4c:	00f51a63          	bne	a0,a5,80004d60 <exec+0x8e>
  if(elf.magic != ELF_MAGIC)
    80004d50:	e5042703          	lw	a4,-432(s0)
    80004d54:	464c47b7          	lui	a5,0x464c4
    80004d58:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80004d5c:	06f70663          	beq	a4,a5,80004dc8 <exec+0xf6>
    iunlockput(ip);
    80004d60:	855a                	mv	a0,s6
    80004d62:	fffff097          	auipc	ra,0xfffff
    80004d66:	c48080e7          	jalr	-952(ra) # 800039aa <iunlockput>
    end_op();
    80004d6a:	fffff097          	auipc	ra,0xfffff
    80004d6e:	3fe080e7          	jalr	1022(ra) # 80004168 <end_op>
  return -1;
    80004d72:	557d                	li	a0,-1
}
    80004d74:	70fe                	ld	ra,504(sp)
    80004d76:	745e                	ld	s0,496(sp)
    80004d78:	74be                	ld	s1,488(sp)
    80004d7a:	791e                	ld	s2,480(sp)
    80004d7c:	69fe                	ld	s3,472(sp)
    80004d7e:	6a5e                	ld	s4,464(sp)
    80004d80:	6abe                	ld	s5,456(sp)
    80004d82:	6b1e                	ld	s6,448(sp)
    80004d84:	7bfa                	ld	s7,440(sp)
    80004d86:	7c5a                	ld	s8,432(sp)
    80004d88:	7cba                	ld	s9,424(sp)
    80004d8a:	7d1a                	ld	s10,416(sp)
    80004d8c:	6dfa                	ld	s11,408(sp)
    80004d8e:	20010113          	addi	sp,sp,512
    80004d92:	8082                	ret
  if (!(strncmp(path,"/init",5)==0 || strncmp(path,"sh",2)==0)) {
    80004d94:	4609                	li	a2,2
    80004d96:	00004597          	auipc	a1,0x4
    80004d9a:	98a58593          	addi	a1,a1,-1654 # 80008720 <syscalls+0x2a8>
    80004d9e:	8526                	mv	a0,s1
    80004da0:	ffffc097          	auipc	ra,0xffffc
    80004da4:	ffe080e7          	jalr	-2(ra) # 80000d9e <strncmp>
    80004da8:	d535                	beqz	a0,80004d14 <exec+0x42>
    print_ondemand_proc(path);
    80004daa:	8526                	mv	a0,s1
    80004dac:	00002097          	auipc	ra,0x2
    80004db0:	85c080e7          	jalr	-1956(ra) # 80006608 <print_ondemand_proc>
    p->ondemand = true;
    80004db4:	4785                	li	a5,1
    80004db6:	16fc0423          	sb	a5,360(s8)
    80004dba:	bfa9                	j	80004d14 <exec+0x42>
    end_op();
    80004dbc:	fffff097          	auipc	ra,0xfffff
    80004dc0:	3ac080e7          	jalr	940(ra) # 80004168 <end_op>
    return -1;
    80004dc4:	557d                	li	a0,-1
    80004dc6:	b77d                	j	80004d74 <exec+0xa2>
  if((pagetable = proc_pagetable(p)) == 0)
    80004dc8:	8562                	mv	a0,s8
    80004dca:	ffffd097          	auipc	ra,0xffffd
    80004dce:	cdc080e7          	jalr	-804(ra) # 80001aa6 <proc_pagetable>
    80004dd2:	8a2a                	mv	s4,a0
    80004dd4:	d551                	beqz	a0,80004d60 <exec+0x8e>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004dd6:	e7042983          	lw	s3,-400(s0)
    80004dda:	e8845783          	lhu	a5,-376(s0)
    80004dde:	cbdd                	beqz	a5,80004e94 <exec+0x1c2>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004de0:	4a81                	li	s5,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004de2:	4b81                	li	s7,0
    if(ph.type != ELF_PROG_LOAD)
    80004de4:	4c85                	li	s9,1
    if(ph.vaddr % PGSIZE != 0)
    80004de6:	6d05                	lui	s10,0x1
    80004de8:	1d7d                	addi	s10,s10,-1 # fff <_entry-0x7ffff001>
    80004dea:	a0b9                	j	80004e38 <exec+0x166>
      if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80004dec:	e1c42503          	lw	a0,-484(s0)
    80004df0:	00000097          	auipc	ra,0x0
    80004df4:	e1e080e7          	jalr	-482(ra) # 80004c0e <flags2perm>
    80004df8:	86aa                	mv	a3,a0
    80004dfa:	866e                	mv	a2,s11
    80004dfc:	85d6                	mv	a1,s5
    80004dfe:	8552                	mv	a0,s4
    80004e00:	ffffc097          	auipc	ra,0xffffc
    80004e04:	604080e7          	jalr	1540(ra) # 80001404 <uvmalloc>
    80004e08:	8daa                	mv	s11,a0
    80004e0a:	c971                	beqz	a0,80004ede <exec+0x20c>
      if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80004e0c:	e3842703          	lw	a4,-456(s0)
    80004e10:	e2042683          	lw	a3,-480(s0)
    80004e14:	865a                	mv	a2,s6
    80004e16:	e2843583          	ld	a1,-472(s0)
    80004e1a:	8552                	mv	a0,s4
    80004e1c:	00000097          	auipc	ra,0x0
    80004e20:	e0c080e7          	jalr	-500(ra) # 80004c28 <loadseg>
    80004e24:	20054663          	bltz	a0,80005030 <exec+0x35e>
      if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80004e28:	8aee                	mv	s5,s11
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004e2a:	2b85                	addiw	s7,s7,1
    80004e2c:	0389899b          	addiw	s3,s3,56
    80004e30:	e8845783          	lhu	a5,-376(s0)
    80004e34:	06fbd163          	bge	s7,a5,80004e96 <exec+0x1c4>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80004e38:	2981                	sext.w	s3,s3
    80004e3a:	03800713          	li	a4,56
    80004e3e:	86ce                	mv	a3,s3
    80004e40:	e1840613          	addi	a2,s0,-488
    80004e44:	4581                	li	a1,0
    80004e46:	855a                	mv	a0,s6
    80004e48:	fffff097          	auipc	ra,0xfffff
    80004e4c:	bb4080e7          	jalr	-1100(ra) # 800039fc <readi>
    80004e50:	03800793          	li	a5,56
    80004e54:	08f51563          	bne	a0,a5,80004ede <exec+0x20c>
    if(ph.type != ELF_PROG_LOAD)
    80004e58:	e1842783          	lw	a5,-488(s0)
    80004e5c:	fd9797e3          	bne	a5,s9,80004e2a <exec+0x158>
    if(ph.memsz < ph.filesz)
    80004e60:	e4043603          	ld	a2,-448(s0)
    80004e64:	e3843783          	ld	a5,-456(s0)
    80004e68:	06f66b63          	bltu	a2,a5,80004ede <exec+0x20c>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80004e6c:	e2843583          	ld	a1,-472(s0)
    80004e70:	00b60db3          	add	s11,a2,a1
    80004e74:	06bde563          	bltu	s11,a1,80004ede <exec+0x20c>
    if(ph.vaddr % PGSIZE != 0)
    80004e78:	01a5f7b3          	and	a5,a1,s10
    80004e7c:	e3ad                	bnez	a5,80004ede <exec+0x20c>
    if(p->ondemand){
    80004e7e:	168c4783          	lbu	a5,360(s8)
    80004e82:	d7ad                	beqz	a5,80004dec <exec+0x11a>
      print_skip_section(path, ph.vaddr, ph.memsz);      
    80004e84:	2601                	sext.w	a2,a2
    80004e86:	8526                	mv	a0,s1
    80004e88:	00001097          	auipc	ra,0x1
    80004e8c:	7a2080e7          	jalr	1954(ra) # 8000662a <print_skip_section>
      sz = ph.vaddr + ph.memsz;
    80004e90:	8aee                	mv	s5,s11
    80004e92:	bf61                	j	80004e2a <exec+0x158>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004e94:	4a81                	li	s5,0
  iunlockput(ip);
    80004e96:	855a                	mv	a0,s6
    80004e98:	fffff097          	auipc	ra,0xfffff
    80004e9c:	b12080e7          	jalr	-1262(ra) # 800039aa <iunlockput>
  end_op();
    80004ea0:	fffff097          	auipc	ra,0xfffff
    80004ea4:	2c8080e7          	jalr	712(ra) # 80004168 <end_op>
  p = myproc();
    80004ea8:	ffffd097          	auipc	ra,0xffffd
    80004eac:	b3a080e7          	jalr	-1222(ra) # 800019e2 <myproc>
    80004eb0:	8d2a                	mv	s10,a0
  uint64 oldsz = p->sz;
    80004eb2:	653c                	ld	a5,72(a0)
    80004eb4:	e0f43423          	sd	a5,-504(s0)
  sz = PGROUNDUP(sz);
    80004eb8:	6b05                	lui	s6,0x1
    80004eba:	1b7d                	addi	s6,s6,-1 # fff <_entry-0x7ffff001>
    80004ebc:	9b56                	add	s6,s6,s5
    80004ebe:	77fd                	lui	a5,0xfffff
    80004ec0:	00fb7b33          	and	s6,s6,a5
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE, PTE_W)) == 0)
    80004ec4:	4691                	li	a3,4
    80004ec6:	6609                	lui	a2,0x2
    80004ec8:	965a                	add	a2,a2,s6
    80004eca:	85da                	mv	a1,s6
    80004ecc:	8552                	mv	a0,s4
    80004ece:	ffffc097          	auipc	ra,0xffffc
    80004ed2:	536080e7          	jalr	1334(ra) # 80001404 <uvmalloc>
    80004ed6:	8aaa                	mv	s5,a0
    80004ed8:	ed09                	bnez	a0,80004ef2 <exec+0x220>
      if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80004eda:	8ada                	mv	s5,s6
    80004edc:	4b01                	li	s6,0
    proc_freepagetable(pagetable, sz);
    80004ede:	85d6                	mv	a1,s5
    80004ee0:	8552                	mv	a0,s4
    80004ee2:	ffffd097          	auipc	ra,0xffffd
    80004ee6:	c60080e7          	jalr	-928(ra) # 80001b42 <proc_freepagetable>
  return -1;
    80004eea:	557d                	li	a0,-1
  if(ip){
    80004eec:	e80b04e3          	beqz	s6,80004d74 <exec+0xa2>
    80004ef0:	bd85                	j	80004d60 <exec+0x8e>
  uvmclear(pagetable, sz-2*PGSIZE);
    80004ef2:	75f9                	lui	a1,0xffffe
    80004ef4:	95aa                	add	a1,a1,a0
    80004ef6:	8552                	mv	a0,s4
    80004ef8:	ffffc097          	auipc	ra,0xffffc
    80004efc:	736080e7          	jalr	1846(ra) # 8000162e <uvmclear>
  stackbase = sp - PGSIZE;
    80004f00:	7cfd                	lui	s9,0xfffff
    80004f02:	9cd6                	add	s9,s9,s5
  for(argc = 0; argv[argc]; argc++) {
    80004f04:	00093503          	ld	a0,0(s2)
    80004f08:	c125                	beqz	a0,80004f68 <exec+0x296>
    80004f0a:	e9040b93          	addi	s7,s0,-368
    80004f0e:	f9040d93          	addi	s11,s0,-112
  sp = sz;
    80004f12:	8b56                	mv	s6,s5
  for(argc = 0; argv[argc]; argc++) {
    80004f14:	4981                	li	s3,0
    sp -= strlen(argv[argc]) + 1;
    80004f16:	ffffc097          	auipc	ra,0xffffc
    80004f1a:	f32080e7          	jalr	-206(ra) # 80000e48 <strlen>
    80004f1e:	2505                	addiw	a0,a0,1
    80004f20:	40ab0533          	sub	a0,s6,a0
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80004f24:	ff057b13          	andi	s6,a0,-16
    if(sp < stackbase)
    80004f28:	119b6663          	bltu	s6,s9,80005034 <exec+0x362>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80004f2c:	00093c03          	ld	s8,0(s2)
    80004f30:	8562                	mv	a0,s8
    80004f32:	ffffc097          	auipc	ra,0xffffc
    80004f36:	f16080e7          	jalr	-234(ra) # 80000e48 <strlen>
    80004f3a:	0015069b          	addiw	a3,a0,1
    80004f3e:	8662                	mv	a2,s8
    80004f40:	85da                	mv	a1,s6
    80004f42:	8552                	mv	a0,s4
    80004f44:	ffffc097          	auipc	ra,0xffffc
    80004f48:	74e080e7          	jalr	1870(ra) # 80001692 <copyout>
    80004f4c:	0e054663          	bltz	a0,80005038 <exec+0x366>
    ustack[argc] = sp;
    80004f50:	016bb023          	sd	s6,0(s7)
  for(argc = 0; argv[argc]; argc++) {
    80004f54:	0985                	addi	s3,s3,1
    80004f56:	0921                	addi	s2,s2,8
    80004f58:	00093503          	ld	a0,0(s2)
    80004f5c:	c901                	beqz	a0,80004f6c <exec+0x29a>
    if(argc >= MAXARG)
    80004f5e:	0ba1                	addi	s7,s7,8
    80004f60:	fbbb9be3          	bne	s7,s11,80004f16 <exec+0x244>
  ip = 0;
    80004f64:	4b01                	li	s6,0
    80004f66:	bfa5                	j	80004ede <exec+0x20c>
  sp = sz;
    80004f68:	8b56                	mv	s6,s5
  for(argc = 0; argv[argc]; argc++) {
    80004f6a:	4981                	li	s3,0
  ustack[argc] = 0;
    80004f6c:	00399793          	slli	a5,s3,0x3
    80004f70:	f9078793          	addi	a5,a5,-112 # ffffffffffffef90 <end+0xffffffff7fe65880>
    80004f74:	97a2                	add	a5,a5,s0
    80004f76:	f007b023          	sd	zero,-256(a5)
  sp -= (argc+1) * sizeof(uint64);
    80004f7a:	00198693          	addi	a3,s3,1
    80004f7e:	068e                	slli	a3,a3,0x3
    80004f80:	40db0933          	sub	s2,s6,a3
  sp -= sp % 16;
    80004f84:	ff097913          	andi	s2,s2,-16
  sz = sz1;
    80004f88:	8b56                	mv	s6,s5
  if(sp < stackbase)
    80004f8a:	f59968e3          	bltu	s2,s9,80004eda <exec+0x208>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80004f8e:	e9040613          	addi	a2,s0,-368
    80004f92:	85ca                	mv	a1,s2
    80004f94:	8552                	mv	a0,s4
    80004f96:	ffffc097          	auipc	ra,0xffffc
    80004f9a:	6fc080e7          	jalr	1788(ra) # 80001692 <copyout>
    80004f9e:	f2054ee3          	bltz	a0,80004eda <exec+0x208>
  p->trapframe->a1 = sp;
    80004fa2:	058d3783          	ld	a5,88(s10)
    80004fa6:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80004faa:	0004c703          	lbu	a4,0(s1)
    80004fae:	cf11                	beqz	a4,80004fca <exec+0x2f8>
    80004fb0:	00148793          	addi	a5,s1,1
    if(*s == '/')
    80004fb4:	02f00693          	li	a3,47
    80004fb8:	a029                	j	80004fc2 <exec+0x2f0>
  for(last=s=path; *s; s++)
    80004fba:	0785                	addi	a5,a5,1
    80004fbc:	fff7c703          	lbu	a4,-1(a5)
    80004fc0:	c709                	beqz	a4,80004fca <exec+0x2f8>
    if(*s == '/')
    80004fc2:	fed71ce3          	bne	a4,a3,80004fba <exec+0x2e8>
      last = s+1;
    80004fc6:	84be                	mv	s1,a5
    80004fc8:	bfcd                	j	80004fba <exec+0x2e8>
  safestrcpy(p->name, last, sizeof(p->name));
    80004fca:	4641                	li	a2,16
    80004fcc:	85a6                	mv	a1,s1
    80004fce:	158d0513          	addi	a0,s10,344
    80004fd2:	ffffc097          	auipc	ra,0xffffc
    80004fd6:	e44080e7          	jalr	-444(ra) # 80000e16 <safestrcpy>
  oldpagetable = p->pagetable;
    80004fda:	050d3503          	ld	a0,80(s10)
  p->pagetable = pagetable;
    80004fde:	054d3823          	sd	s4,80(s10)
  p->sz = sz;
    80004fe2:	055d3423          	sd	s5,72(s10)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    80004fe6:	058d3783          	ld	a5,88(s10)
    80004fea:	e6843703          	ld	a4,-408(s0)
    80004fee:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    80004ff0:	058d3783          	ld	a5,88(s10)
    80004ff4:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80004ff8:	e0843583          	ld	a1,-504(s0)
    80004ffc:	ffffd097          	auipc	ra,0xffffd
    80005000:	b46080e7          	jalr	-1210(ra) # 80001b42 <proc_freepagetable>
  for (int i = 0; i < MAXHEAP; i++) {
    80005004:	170d0793          	addi	a5,s10,368
    80005008:	6699                	lui	a3,0x6
    8000500a:	f3068693          	addi	a3,a3,-208 # 5f30 <_entry-0x7fffa0d0>
    8000500e:	96ea                	add	a3,a3,s10
    p->heap_tracker[i].addr            = 0xFFFFFFFFFFFFFFFF;
    80005010:	577d                	li	a4,-1
    80005012:	e398                	sd	a4,0(a5)
    p->heap_tracker[i].startblock      = -1;
    80005014:	cbd8                	sw	a4,20(a5)
    p->heap_tracker[i].last_load_time  = 0xFFFFFFFFFFFFFFFF;
    80005016:	e798                	sd	a4,8(a5)
    p->heap_tracker[i].loaded          = false;
    80005018:	00078823          	sb	zero,16(a5)
  for (int i = 0; i < MAXHEAP; i++) {
    8000501c:	07e1                	addi	a5,a5,24
    8000501e:	fed79ae3          	bne	a5,a3,80005012 <exec+0x340>
  p->resident_heap_pages = 0;
    80005022:	6799                	lui	a5,0x6
    80005024:	9d3e                	add	s10,s10,a5
    80005026:	f20d2823          	sw	zero,-208(s10)
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    8000502a:	0009851b          	sext.w	a0,s3
    8000502e:	b399                	j	80004d74 <exec+0xa2>
      if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80005030:	8aee                	mv	s5,s11
    80005032:	b575                	j	80004ede <exec+0x20c>
  ip = 0;
    80005034:	4b01                	li	s6,0
    80005036:	b565                	j	80004ede <exec+0x20c>
    80005038:	4b01                	li	s6,0
  if(pagetable)
    8000503a:	b555                	j	80004ede <exec+0x20c>

000000008000503c <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    8000503c:	7179                	addi	sp,sp,-48
    8000503e:	f406                	sd	ra,40(sp)
    80005040:	f022                	sd	s0,32(sp)
    80005042:	ec26                	sd	s1,24(sp)
    80005044:	e84a                	sd	s2,16(sp)
    80005046:	1800                	addi	s0,sp,48
    80005048:	892e                	mv	s2,a1
    8000504a:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    8000504c:	fdc40593          	addi	a1,s0,-36
    80005050:	ffffe097          	auipc	ra,0xffffe
    80005054:	b96080e7          	jalr	-1130(ra) # 80002be6 <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80005058:	fdc42703          	lw	a4,-36(s0)
    8000505c:	47bd                	li	a5,15
    8000505e:	02e7eb63          	bltu	a5,a4,80005094 <argfd+0x58>
    80005062:	ffffd097          	auipc	ra,0xffffd
    80005066:	980080e7          	jalr	-1664(ra) # 800019e2 <myproc>
    8000506a:	fdc42703          	lw	a4,-36(s0)
    8000506e:	01a70793          	addi	a5,a4,26
    80005072:	078e                	slli	a5,a5,0x3
    80005074:	953e                	add	a0,a0,a5
    80005076:	611c                	ld	a5,0(a0)
    80005078:	c385                	beqz	a5,80005098 <argfd+0x5c>
    return -1;
  if(pfd)
    8000507a:	00090463          	beqz	s2,80005082 <argfd+0x46>
    *pfd = fd;
    8000507e:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80005082:	4501                	li	a0,0
  if(pf)
    80005084:	c091                	beqz	s1,80005088 <argfd+0x4c>
    *pf = f;
    80005086:	e09c                	sd	a5,0(s1)
}
    80005088:	70a2                	ld	ra,40(sp)
    8000508a:	7402                	ld	s0,32(sp)
    8000508c:	64e2                	ld	s1,24(sp)
    8000508e:	6942                	ld	s2,16(sp)
    80005090:	6145                	addi	sp,sp,48
    80005092:	8082                	ret
    return -1;
    80005094:	557d                	li	a0,-1
    80005096:	bfcd                	j	80005088 <argfd+0x4c>
    80005098:	557d                	li	a0,-1
    8000509a:	b7fd                	j	80005088 <argfd+0x4c>

000000008000509c <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    8000509c:	1101                	addi	sp,sp,-32
    8000509e:	ec06                	sd	ra,24(sp)
    800050a0:	e822                	sd	s0,16(sp)
    800050a2:	e426                	sd	s1,8(sp)
    800050a4:	1000                	addi	s0,sp,32
    800050a6:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    800050a8:	ffffd097          	auipc	ra,0xffffd
    800050ac:	93a080e7          	jalr	-1734(ra) # 800019e2 <myproc>
    800050b0:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    800050b2:	0d050793          	addi	a5,a0,208
    800050b6:	4501                	li	a0,0
    800050b8:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    800050ba:	6398                	ld	a4,0(a5)
    800050bc:	cb19                	beqz	a4,800050d2 <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    800050be:	2505                	addiw	a0,a0,1
    800050c0:	07a1                	addi	a5,a5,8 # 6008 <_entry-0x7fff9ff8>
    800050c2:	fed51ce3          	bne	a0,a3,800050ba <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    800050c6:	557d                	li	a0,-1
}
    800050c8:	60e2                	ld	ra,24(sp)
    800050ca:	6442                	ld	s0,16(sp)
    800050cc:	64a2                	ld	s1,8(sp)
    800050ce:	6105                	addi	sp,sp,32
    800050d0:	8082                	ret
      p->ofile[fd] = f;
    800050d2:	01a50793          	addi	a5,a0,26
    800050d6:	078e                	slli	a5,a5,0x3
    800050d8:	963e                	add	a2,a2,a5
    800050da:	e204                	sd	s1,0(a2)
      return fd;
    800050dc:	b7f5                	j	800050c8 <fdalloc+0x2c>

00000000800050de <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    800050de:	715d                	addi	sp,sp,-80
    800050e0:	e486                	sd	ra,72(sp)
    800050e2:	e0a2                	sd	s0,64(sp)
    800050e4:	fc26                	sd	s1,56(sp)
    800050e6:	f84a                	sd	s2,48(sp)
    800050e8:	f44e                	sd	s3,40(sp)
    800050ea:	f052                	sd	s4,32(sp)
    800050ec:	ec56                	sd	s5,24(sp)
    800050ee:	e85a                	sd	s6,16(sp)
    800050f0:	0880                	addi	s0,sp,80
    800050f2:	8b2e                	mv	s6,a1
    800050f4:	89b2                	mv	s3,a2
    800050f6:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    800050f8:	fb040593          	addi	a1,s0,-80
    800050fc:	fffff097          	auipc	ra,0xfffff
    80005100:	e10080e7          	jalr	-496(ra) # 80003f0c <nameiparent>
    80005104:	84aa                	mv	s1,a0
    80005106:	14050b63          	beqz	a0,8000525c <create+0x17e>
    return 0;

  ilock(dp);
    8000510a:	ffffe097          	auipc	ra,0xffffe
    8000510e:	63e080e7          	jalr	1598(ra) # 80003748 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    80005112:	4601                	li	a2,0
    80005114:	fb040593          	addi	a1,s0,-80
    80005118:	8526                	mv	a0,s1
    8000511a:	fffff097          	auipc	ra,0xfffff
    8000511e:	b12080e7          	jalr	-1262(ra) # 80003c2c <dirlookup>
    80005122:	8aaa                	mv	s5,a0
    80005124:	c921                	beqz	a0,80005174 <create+0x96>
    iunlockput(dp);
    80005126:	8526                	mv	a0,s1
    80005128:	fffff097          	auipc	ra,0xfffff
    8000512c:	882080e7          	jalr	-1918(ra) # 800039aa <iunlockput>
    ilock(ip);
    80005130:	8556                	mv	a0,s5
    80005132:	ffffe097          	auipc	ra,0xffffe
    80005136:	616080e7          	jalr	1558(ra) # 80003748 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    8000513a:	4789                	li	a5,2
    8000513c:	02fb1563          	bne	s6,a5,80005166 <create+0x88>
    80005140:	044ad783          	lhu	a5,68(s5)
    80005144:	37f9                	addiw	a5,a5,-2
    80005146:	17c2                	slli	a5,a5,0x30
    80005148:	93c1                	srli	a5,a5,0x30
    8000514a:	4705                	li	a4,1
    8000514c:	00f76d63          	bltu	a4,a5,80005166 <create+0x88>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    80005150:	8556                	mv	a0,s5
    80005152:	60a6                	ld	ra,72(sp)
    80005154:	6406                	ld	s0,64(sp)
    80005156:	74e2                	ld	s1,56(sp)
    80005158:	7942                	ld	s2,48(sp)
    8000515a:	79a2                	ld	s3,40(sp)
    8000515c:	7a02                	ld	s4,32(sp)
    8000515e:	6ae2                	ld	s5,24(sp)
    80005160:	6b42                	ld	s6,16(sp)
    80005162:	6161                	addi	sp,sp,80
    80005164:	8082                	ret
    iunlockput(ip);
    80005166:	8556                	mv	a0,s5
    80005168:	fffff097          	auipc	ra,0xfffff
    8000516c:	842080e7          	jalr	-1982(ra) # 800039aa <iunlockput>
    return 0;
    80005170:	4a81                	li	s5,0
    80005172:	bff9                	j	80005150 <create+0x72>
  if((ip = ialloc(dp->dev, type)) == 0){
    80005174:	85da                	mv	a1,s6
    80005176:	4088                	lw	a0,0(s1)
    80005178:	ffffe097          	auipc	ra,0xffffe
    8000517c:	438080e7          	jalr	1080(ra) # 800035b0 <ialloc>
    80005180:	8a2a                	mv	s4,a0
    80005182:	c529                	beqz	a0,800051cc <create+0xee>
  ilock(ip);
    80005184:	ffffe097          	auipc	ra,0xffffe
    80005188:	5c4080e7          	jalr	1476(ra) # 80003748 <ilock>
  ip->major = major;
    8000518c:	053a1323          	sh	s3,70(s4) # 1046 <_entry-0x7fffefba>
  ip->minor = minor;
    80005190:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    80005194:	4905                	li	s2,1
    80005196:	052a1523          	sh	s2,74(s4)
  iupdate(ip);
    8000519a:	8552                	mv	a0,s4
    8000519c:	ffffe097          	auipc	ra,0xffffe
    800051a0:	4e0080e7          	jalr	1248(ra) # 8000367c <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    800051a4:	032b0b63          	beq	s6,s2,800051da <create+0xfc>
  if(dirlink(dp, name, ip->inum) < 0)
    800051a8:	004a2603          	lw	a2,4(s4)
    800051ac:	fb040593          	addi	a1,s0,-80
    800051b0:	8526                	mv	a0,s1
    800051b2:	fffff097          	auipc	ra,0xfffff
    800051b6:	c8a080e7          	jalr	-886(ra) # 80003e3c <dirlink>
    800051ba:	06054f63          	bltz	a0,80005238 <create+0x15a>
  iunlockput(dp);
    800051be:	8526                	mv	a0,s1
    800051c0:	ffffe097          	auipc	ra,0xffffe
    800051c4:	7ea080e7          	jalr	2026(ra) # 800039aa <iunlockput>
  return ip;
    800051c8:	8ad2                	mv	s5,s4
    800051ca:	b759                	j	80005150 <create+0x72>
    iunlockput(dp);
    800051cc:	8526                	mv	a0,s1
    800051ce:	ffffe097          	auipc	ra,0xffffe
    800051d2:	7dc080e7          	jalr	2012(ra) # 800039aa <iunlockput>
    return 0;
    800051d6:	8ad2                	mv	s5,s4
    800051d8:	bfa5                	j	80005150 <create+0x72>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    800051da:	004a2603          	lw	a2,4(s4)
    800051de:	00003597          	auipc	a1,0x3
    800051e2:	54a58593          	addi	a1,a1,1354 # 80008728 <syscalls+0x2b0>
    800051e6:	8552                	mv	a0,s4
    800051e8:	fffff097          	auipc	ra,0xfffff
    800051ec:	c54080e7          	jalr	-940(ra) # 80003e3c <dirlink>
    800051f0:	04054463          	bltz	a0,80005238 <create+0x15a>
    800051f4:	40d0                	lw	a2,4(s1)
    800051f6:	00003597          	auipc	a1,0x3
    800051fa:	53a58593          	addi	a1,a1,1338 # 80008730 <syscalls+0x2b8>
    800051fe:	8552                	mv	a0,s4
    80005200:	fffff097          	auipc	ra,0xfffff
    80005204:	c3c080e7          	jalr	-964(ra) # 80003e3c <dirlink>
    80005208:	02054863          	bltz	a0,80005238 <create+0x15a>
  if(dirlink(dp, name, ip->inum) < 0)
    8000520c:	004a2603          	lw	a2,4(s4)
    80005210:	fb040593          	addi	a1,s0,-80
    80005214:	8526                	mv	a0,s1
    80005216:	fffff097          	auipc	ra,0xfffff
    8000521a:	c26080e7          	jalr	-986(ra) # 80003e3c <dirlink>
    8000521e:	00054d63          	bltz	a0,80005238 <create+0x15a>
    dp->nlink++;  // for ".."
    80005222:	04a4d783          	lhu	a5,74(s1)
    80005226:	2785                	addiw	a5,a5,1
    80005228:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    8000522c:	8526                	mv	a0,s1
    8000522e:	ffffe097          	auipc	ra,0xffffe
    80005232:	44e080e7          	jalr	1102(ra) # 8000367c <iupdate>
    80005236:	b761                	j	800051be <create+0xe0>
  ip->nlink = 0;
    80005238:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    8000523c:	8552                	mv	a0,s4
    8000523e:	ffffe097          	auipc	ra,0xffffe
    80005242:	43e080e7          	jalr	1086(ra) # 8000367c <iupdate>
  iunlockput(ip);
    80005246:	8552                	mv	a0,s4
    80005248:	ffffe097          	auipc	ra,0xffffe
    8000524c:	762080e7          	jalr	1890(ra) # 800039aa <iunlockput>
  iunlockput(dp);
    80005250:	8526                	mv	a0,s1
    80005252:	ffffe097          	auipc	ra,0xffffe
    80005256:	758080e7          	jalr	1880(ra) # 800039aa <iunlockput>
  return 0;
    8000525a:	bddd                	j	80005150 <create+0x72>
    return 0;
    8000525c:	8aaa                	mv	s5,a0
    8000525e:	bdcd                	j	80005150 <create+0x72>

0000000080005260 <sys_dup>:
{
    80005260:	7179                	addi	sp,sp,-48
    80005262:	f406                	sd	ra,40(sp)
    80005264:	f022                	sd	s0,32(sp)
    80005266:	ec26                	sd	s1,24(sp)
    80005268:	e84a                	sd	s2,16(sp)
    8000526a:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    8000526c:	fd840613          	addi	a2,s0,-40
    80005270:	4581                	li	a1,0
    80005272:	4501                	li	a0,0
    80005274:	00000097          	auipc	ra,0x0
    80005278:	dc8080e7          	jalr	-568(ra) # 8000503c <argfd>
    return -1;
    8000527c:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    8000527e:	02054363          	bltz	a0,800052a4 <sys_dup+0x44>
  if((fd=fdalloc(f)) < 0)
    80005282:	fd843903          	ld	s2,-40(s0)
    80005286:	854a                	mv	a0,s2
    80005288:	00000097          	auipc	ra,0x0
    8000528c:	e14080e7          	jalr	-492(ra) # 8000509c <fdalloc>
    80005290:	84aa                	mv	s1,a0
    return -1;
    80005292:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    80005294:	00054863          	bltz	a0,800052a4 <sys_dup+0x44>
  filedup(f);
    80005298:	854a                	mv	a0,s2
    8000529a:	fffff097          	auipc	ra,0xfffff
    8000529e:	2c6080e7          	jalr	710(ra) # 80004560 <filedup>
  return fd;
    800052a2:	87a6                	mv	a5,s1
}
    800052a4:	853e                	mv	a0,a5
    800052a6:	70a2                	ld	ra,40(sp)
    800052a8:	7402                	ld	s0,32(sp)
    800052aa:	64e2                	ld	s1,24(sp)
    800052ac:	6942                	ld	s2,16(sp)
    800052ae:	6145                	addi	sp,sp,48
    800052b0:	8082                	ret

00000000800052b2 <sys_read>:
{
    800052b2:	7179                	addi	sp,sp,-48
    800052b4:	f406                	sd	ra,40(sp)
    800052b6:	f022                	sd	s0,32(sp)
    800052b8:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    800052ba:	fd840593          	addi	a1,s0,-40
    800052be:	4505                	li	a0,1
    800052c0:	ffffe097          	auipc	ra,0xffffe
    800052c4:	946080e7          	jalr	-1722(ra) # 80002c06 <argaddr>
  argint(2, &n);
    800052c8:	fe440593          	addi	a1,s0,-28
    800052cc:	4509                	li	a0,2
    800052ce:	ffffe097          	auipc	ra,0xffffe
    800052d2:	918080e7          	jalr	-1768(ra) # 80002be6 <argint>
  if(argfd(0, 0, &f) < 0)
    800052d6:	fe840613          	addi	a2,s0,-24
    800052da:	4581                	li	a1,0
    800052dc:	4501                	li	a0,0
    800052de:	00000097          	auipc	ra,0x0
    800052e2:	d5e080e7          	jalr	-674(ra) # 8000503c <argfd>
    800052e6:	87aa                	mv	a5,a0
    return -1;
    800052e8:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    800052ea:	0007cc63          	bltz	a5,80005302 <sys_read+0x50>
  return fileread(f, p, n);
    800052ee:	fe442603          	lw	a2,-28(s0)
    800052f2:	fd843583          	ld	a1,-40(s0)
    800052f6:	fe843503          	ld	a0,-24(s0)
    800052fa:	fffff097          	auipc	ra,0xfffff
    800052fe:	3f2080e7          	jalr	1010(ra) # 800046ec <fileread>
}
    80005302:	70a2                	ld	ra,40(sp)
    80005304:	7402                	ld	s0,32(sp)
    80005306:	6145                	addi	sp,sp,48
    80005308:	8082                	ret

000000008000530a <sys_write>:
{
    8000530a:	7179                	addi	sp,sp,-48
    8000530c:	f406                	sd	ra,40(sp)
    8000530e:	f022                	sd	s0,32(sp)
    80005310:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80005312:	fd840593          	addi	a1,s0,-40
    80005316:	4505                	li	a0,1
    80005318:	ffffe097          	auipc	ra,0xffffe
    8000531c:	8ee080e7          	jalr	-1810(ra) # 80002c06 <argaddr>
  argint(2, &n);
    80005320:	fe440593          	addi	a1,s0,-28
    80005324:	4509                	li	a0,2
    80005326:	ffffe097          	auipc	ra,0xffffe
    8000532a:	8c0080e7          	jalr	-1856(ra) # 80002be6 <argint>
  if(argfd(0, 0, &f) < 0)
    8000532e:	fe840613          	addi	a2,s0,-24
    80005332:	4581                	li	a1,0
    80005334:	4501                	li	a0,0
    80005336:	00000097          	auipc	ra,0x0
    8000533a:	d06080e7          	jalr	-762(ra) # 8000503c <argfd>
    8000533e:	87aa                	mv	a5,a0
    return -1;
    80005340:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005342:	0007cc63          	bltz	a5,8000535a <sys_write+0x50>
  return filewrite(f, p, n);
    80005346:	fe442603          	lw	a2,-28(s0)
    8000534a:	fd843583          	ld	a1,-40(s0)
    8000534e:	fe843503          	ld	a0,-24(s0)
    80005352:	fffff097          	auipc	ra,0xfffff
    80005356:	45c080e7          	jalr	1116(ra) # 800047ae <filewrite>
}
    8000535a:	70a2                	ld	ra,40(sp)
    8000535c:	7402                	ld	s0,32(sp)
    8000535e:	6145                	addi	sp,sp,48
    80005360:	8082                	ret

0000000080005362 <sys_close>:
{
    80005362:	1101                	addi	sp,sp,-32
    80005364:	ec06                	sd	ra,24(sp)
    80005366:	e822                	sd	s0,16(sp)
    80005368:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    8000536a:	fe040613          	addi	a2,s0,-32
    8000536e:	fec40593          	addi	a1,s0,-20
    80005372:	4501                	li	a0,0
    80005374:	00000097          	auipc	ra,0x0
    80005378:	cc8080e7          	jalr	-824(ra) # 8000503c <argfd>
    return -1;
    8000537c:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    8000537e:	02054463          	bltz	a0,800053a6 <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    80005382:	ffffc097          	auipc	ra,0xffffc
    80005386:	660080e7          	jalr	1632(ra) # 800019e2 <myproc>
    8000538a:	fec42783          	lw	a5,-20(s0)
    8000538e:	07e9                	addi	a5,a5,26
    80005390:	078e                	slli	a5,a5,0x3
    80005392:	953e                	add	a0,a0,a5
    80005394:	00053023          	sd	zero,0(a0)
  fileclose(f);
    80005398:	fe043503          	ld	a0,-32(s0)
    8000539c:	fffff097          	auipc	ra,0xfffff
    800053a0:	216080e7          	jalr	534(ra) # 800045b2 <fileclose>
  return 0;
    800053a4:	4781                	li	a5,0
}
    800053a6:	853e                	mv	a0,a5
    800053a8:	60e2                	ld	ra,24(sp)
    800053aa:	6442                	ld	s0,16(sp)
    800053ac:	6105                	addi	sp,sp,32
    800053ae:	8082                	ret

00000000800053b0 <sys_fstat>:
{
    800053b0:	1101                	addi	sp,sp,-32
    800053b2:	ec06                	sd	ra,24(sp)
    800053b4:	e822                	sd	s0,16(sp)
    800053b6:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    800053b8:	fe040593          	addi	a1,s0,-32
    800053bc:	4505                	li	a0,1
    800053be:	ffffe097          	auipc	ra,0xffffe
    800053c2:	848080e7          	jalr	-1976(ra) # 80002c06 <argaddr>
  if(argfd(0, 0, &f) < 0)
    800053c6:	fe840613          	addi	a2,s0,-24
    800053ca:	4581                	li	a1,0
    800053cc:	4501                	li	a0,0
    800053ce:	00000097          	auipc	ra,0x0
    800053d2:	c6e080e7          	jalr	-914(ra) # 8000503c <argfd>
    800053d6:	87aa                	mv	a5,a0
    return -1;
    800053d8:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    800053da:	0007ca63          	bltz	a5,800053ee <sys_fstat+0x3e>
  return filestat(f, st);
    800053de:	fe043583          	ld	a1,-32(s0)
    800053e2:	fe843503          	ld	a0,-24(s0)
    800053e6:	fffff097          	auipc	ra,0xfffff
    800053ea:	294080e7          	jalr	660(ra) # 8000467a <filestat>
}
    800053ee:	60e2                	ld	ra,24(sp)
    800053f0:	6442                	ld	s0,16(sp)
    800053f2:	6105                	addi	sp,sp,32
    800053f4:	8082                	ret

00000000800053f6 <sys_link>:
{
    800053f6:	7169                	addi	sp,sp,-304
    800053f8:	f606                	sd	ra,296(sp)
    800053fa:	f222                	sd	s0,288(sp)
    800053fc:	ee26                	sd	s1,280(sp)
    800053fe:	ea4a                	sd	s2,272(sp)
    80005400:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005402:	08000613          	li	a2,128
    80005406:	ed040593          	addi	a1,s0,-304
    8000540a:	4501                	li	a0,0
    8000540c:	ffffe097          	auipc	ra,0xffffe
    80005410:	81a080e7          	jalr	-2022(ra) # 80002c26 <argstr>
    return -1;
    80005414:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005416:	10054e63          	bltz	a0,80005532 <sys_link+0x13c>
    8000541a:	08000613          	li	a2,128
    8000541e:	f5040593          	addi	a1,s0,-176
    80005422:	4505                	li	a0,1
    80005424:	ffffe097          	auipc	ra,0xffffe
    80005428:	802080e7          	jalr	-2046(ra) # 80002c26 <argstr>
    return -1;
    8000542c:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    8000542e:	10054263          	bltz	a0,80005532 <sys_link+0x13c>
  begin_op();
    80005432:	fffff097          	auipc	ra,0xfffff
    80005436:	cbc080e7          	jalr	-836(ra) # 800040ee <begin_op>
  if((ip = namei(old)) == 0){
    8000543a:	ed040513          	addi	a0,s0,-304
    8000543e:	fffff097          	auipc	ra,0xfffff
    80005442:	ab0080e7          	jalr	-1360(ra) # 80003eee <namei>
    80005446:	84aa                	mv	s1,a0
    80005448:	c551                	beqz	a0,800054d4 <sys_link+0xde>
  ilock(ip);
    8000544a:	ffffe097          	auipc	ra,0xffffe
    8000544e:	2fe080e7          	jalr	766(ra) # 80003748 <ilock>
  if(ip->type == T_DIR){
    80005452:	04449703          	lh	a4,68(s1)
    80005456:	4785                	li	a5,1
    80005458:	08f70463          	beq	a4,a5,800054e0 <sys_link+0xea>
  ip->nlink++;
    8000545c:	04a4d783          	lhu	a5,74(s1)
    80005460:	2785                	addiw	a5,a5,1
    80005462:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005466:	8526                	mv	a0,s1
    80005468:	ffffe097          	auipc	ra,0xffffe
    8000546c:	214080e7          	jalr	532(ra) # 8000367c <iupdate>
  iunlock(ip);
    80005470:	8526                	mv	a0,s1
    80005472:	ffffe097          	auipc	ra,0xffffe
    80005476:	398080e7          	jalr	920(ra) # 8000380a <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    8000547a:	fd040593          	addi	a1,s0,-48
    8000547e:	f5040513          	addi	a0,s0,-176
    80005482:	fffff097          	auipc	ra,0xfffff
    80005486:	a8a080e7          	jalr	-1398(ra) # 80003f0c <nameiparent>
    8000548a:	892a                	mv	s2,a0
    8000548c:	c935                	beqz	a0,80005500 <sys_link+0x10a>
  ilock(dp);
    8000548e:	ffffe097          	auipc	ra,0xffffe
    80005492:	2ba080e7          	jalr	698(ra) # 80003748 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    80005496:	00092703          	lw	a4,0(s2)
    8000549a:	409c                	lw	a5,0(s1)
    8000549c:	04f71d63          	bne	a4,a5,800054f6 <sys_link+0x100>
    800054a0:	40d0                	lw	a2,4(s1)
    800054a2:	fd040593          	addi	a1,s0,-48
    800054a6:	854a                	mv	a0,s2
    800054a8:	fffff097          	auipc	ra,0xfffff
    800054ac:	994080e7          	jalr	-1644(ra) # 80003e3c <dirlink>
    800054b0:	04054363          	bltz	a0,800054f6 <sys_link+0x100>
  iunlockput(dp);
    800054b4:	854a                	mv	a0,s2
    800054b6:	ffffe097          	auipc	ra,0xffffe
    800054ba:	4f4080e7          	jalr	1268(ra) # 800039aa <iunlockput>
  iput(ip);
    800054be:	8526                	mv	a0,s1
    800054c0:	ffffe097          	auipc	ra,0xffffe
    800054c4:	442080e7          	jalr	1090(ra) # 80003902 <iput>
  end_op();
    800054c8:	fffff097          	auipc	ra,0xfffff
    800054cc:	ca0080e7          	jalr	-864(ra) # 80004168 <end_op>
  return 0;
    800054d0:	4781                	li	a5,0
    800054d2:	a085                	j	80005532 <sys_link+0x13c>
    end_op();
    800054d4:	fffff097          	auipc	ra,0xfffff
    800054d8:	c94080e7          	jalr	-876(ra) # 80004168 <end_op>
    return -1;
    800054dc:	57fd                	li	a5,-1
    800054de:	a891                	j	80005532 <sys_link+0x13c>
    iunlockput(ip);
    800054e0:	8526                	mv	a0,s1
    800054e2:	ffffe097          	auipc	ra,0xffffe
    800054e6:	4c8080e7          	jalr	1224(ra) # 800039aa <iunlockput>
    end_op();
    800054ea:	fffff097          	auipc	ra,0xfffff
    800054ee:	c7e080e7          	jalr	-898(ra) # 80004168 <end_op>
    return -1;
    800054f2:	57fd                	li	a5,-1
    800054f4:	a83d                	j	80005532 <sys_link+0x13c>
    iunlockput(dp);
    800054f6:	854a                	mv	a0,s2
    800054f8:	ffffe097          	auipc	ra,0xffffe
    800054fc:	4b2080e7          	jalr	1202(ra) # 800039aa <iunlockput>
  ilock(ip);
    80005500:	8526                	mv	a0,s1
    80005502:	ffffe097          	auipc	ra,0xffffe
    80005506:	246080e7          	jalr	582(ra) # 80003748 <ilock>
  ip->nlink--;
    8000550a:	04a4d783          	lhu	a5,74(s1)
    8000550e:	37fd                	addiw	a5,a5,-1
    80005510:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005514:	8526                	mv	a0,s1
    80005516:	ffffe097          	auipc	ra,0xffffe
    8000551a:	166080e7          	jalr	358(ra) # 8000367c <iupdate>
  iunlockput(ip);
    8000551e:	8526                	mv	a0,s1
    80005520:	ffffe097          	auipc	ra,0xffffe
    80005524:	48a080e7          	jalr	1162(ra) # 800039aa <iunlockput>
  end_op();
    80005528:	fffff097          	auipc	ra,0xfffff
    8000552c:	c40080e7          	jalr	-960(ra) # 80004168 <end_op>
  return -1;
    80005530:	57fd                	li	a5,-1
}
    80005532:	853e                	mv	a0,a5
    80005534:	70b2                	ld	ra,296(sp)
    80005536:	7412                	ld	s0,288(sp)
    80005538:	64f2                	ld	s1,280(sp)
    8000553a:	6952                	ld	s2,272(sp)
    8000553c:	6155                	addi	sp,sp,304
    8000553e:	8082                	ret

0000000080005540 <sys_unlink>:
{
    80005540:	7151                	addi	sp,sp,-240
    80005542:	f586                	sd	ra,232(sp)
    80005544:	f1a2                	sd	s0,224(sp)
    80005546:	eda6                	sd	s1,216(sp)
    80005548:	e9ca                	sd	s2,208(sp)
    8000554a:	e5ce                	sd	s3,200(sp)
    8000554c:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    8000554e:	08000613          	li	a2,128
    80005552:	f3040593          	addi	a1,s0,-208
    80005556:	4501                	li	a0,0
    80005558:	ffffd097          	auipc	ra,0xffffd
    8000555c:	6ce080e7          	jalr	1742(ra) # 80002c26 <argstr>
    80005560:	18054163          	bltz	a0,800056e2 <sys_unlink+0x1a2>
  begin_op();
    80005564:	fffff097          	auipc	ra,0xfffff
    80005568:	b8a080e7          	jalr	-1142(ra) # 800040ee <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    8000556c:	fb040593          	addi	a1,s0,-80
    80005570:	f3040513          	addi	a0,s0,-208
    80005574:	fffff097          	auipc	ra,0xfffff
    80005578:	998080e7          	jalr	-1640(ra) # 80003f0c <nameiparent>
    8000557c:	84aa                	mv	s1,a0
    8000557e:	c979                	beqz	a0,80005654 <sys_unlink+0x114>
  ilock(dp);
    80005580:	ffffe097          	auipc	ra,0xffffe
    80005584:	1c8080e7          	jalr	456(ra) # 80003748 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80005588:	00003597          	auipc	a1,0x3
    8000558c:	1a058593          	addi	a1,a1,416 # 80008728 <syscalls+0x2b0>
    80005590:	fb040513          	addi	a0,s0,-80
    80005594:	ffffe097          	auipc	ra,0xffffe
    80005598:	67e080e7          	jalr	1662(ra) # 80003c12 <namecmp>
    8000559c:	14050a63          	beqz	a0,800056f0 <sys_unlink+0x1b0>
    800055a0:	00003597          	auipc	a1,0x3
    800055a4:	19058593          	addi	a1,a1,400 # 80008730 <syscalls+0x2b8>
    800055a8:	fb040513          	addi	a0,s0,-80
    800055ac:	ffffe097          	auipc	ra,0xffffe
    800055b0:	666080e7          	jalr	1638(ra) # 80003c12 <namecmp>
    800055b4:	12050e63          	beqz	a0,800056f0 <sys_unlink+0x1b0>
  if((ip = dirlookup(dp, name, &off)) == 0)
    800055b8:	f2c40613          	addi	a2,s0,-212
    800055bc:	fb040593          	addi	a1,s0,-80
    800055c0:	8526                	mv	a0,s1
    800055c2:	ffffe097          	auipc	ra,0xffffe
    800055c6:	66a080e7          	jalr	1642(ra) # 80003c2c <dirlookup>
    800055ca:	892a                	mv	s2,a0
    800055cc:	12050263          	beqz	a0,800056f0 <sys_unlink+0x1b0>
  ilock(ip);
    800055d0:	ffffe097          	auipc	ra,0xffffe
    800055d4:	178080e7          	jalr	376(ra) # 80003748 <ilock>
  if(ip->nlink < 1)
    800055d8:	04a91783          	lh	a5,74(s2)
    800055dc:	08f05263          	blez	a5,80005660 <sys_unlink+0x120>
  if(ip->type == T_DIR && !isdirempty(ip)){
    800055e0:	04491703          	lh	a4,68(s2)
    800055e4:	4785                	li	a5,1
    800055e6:	08f70563          	beq	a4,a5,80005670 <sys_unlink+0x130>
  memset(&de, 0, sizeof(de));
    800055ea:	4641                	li	a2,16
    800055ec:	4581                	li	a1,0
    800055ee:	fc040513          	addi	a0,s0,-64
    800055f2:	ffffb097          	auipc	ra,0xffffb
    800055f6:	6dc080e7          	jalr	1756(ra) # 80000cce <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800055fa:	4741                	li	a4,16
    800055fc:	f2c42683          	lw	a3,-212(s0)
    80005600:	fc040613          	addi	a2,s0,-64
    80005604:	4581                	li	a1,0
    80005606:	8526                	mv	a0,s1
    80005608:	ffffe097          	auipc	ra,0xffffe
    8000560c:	4ec080e7          	jalr	1260(ra) # 80003af4 <writei>
    80005610:	47c1                	li	a5,16
    80005612:	0af51563          	bne	a0,a5,800056bc <sys_unlink+0x17c>
  if(ip->type == T_DIR){
    80005616:	04491703          	lh	a4,68(s2)
    8000561a:	4785                	li	a5,1
    8000561c:	0af70863          	beq	a4,a5,800056cc <sys_unlink+0x18c>
  iunlockput(dp);
    80005620:	8526                	mv	a0,s1
    80005622:	ffffe097          	auipc	ra,0xffffe
    80005626:	388080e7          	jalr	904(ra) # 800039aa <iunlockput>
  ip->nlink--;
    8000562a:	04a95783          	lhu	a5,74(s2)
    8000562e:	37fd                	addiw	a5,a5,-1
    80005630:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80005634:	854a                	mv	a0,s2
    80005636:	ffffe097          	auipc	ra,0xffffe
    8000563a:	046080e7          	jalr	70(ra) # 8000367c <iupdate>
  iunlockput(ip);
    8000563e:	854a                	mv	a0,s2
    80005640:	ffffe097          	auipc	ra,0xffffe
    80005644:	36a080e7          	jalr	874(ra) # 800039aa <iunlockput>
  end_op();
    80005648:	fffff097          	auipc	ra,0xfffff
    8000564c:	b20080e7          	jalr	-1248(ra) # 80004168 <end_op>
  return 0;
    80005650:	4501                	li	a0,0
    80005652:	a84d                	j	80005704 <sys_unlink+0x1c4>
    end_op();
    80005654:	fffff097          	auipc	ra,0xfffff
    80005658:	b14080e7          	jalr	-1260(ra) # 80004168 <end_op>
    return -1;
    8000565c:	557d                	li	a0,-1
    8000565e:	a05d                	j	80005704 <sys_unlink+0x1c4>
    panic("unlink: nlink < 1");
    80005660:	00003517          	auipc	a0,0x3
    80005664:	0d850513          	addi	a0,a0,216 # 80008738 <syscalls+0x2c0>
    80005668:	ffffb097          	auipc	ra,0xffffb
    8000566c:	ed4080e7          	jalr	-300(ra) # 8000053c <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005670:	04c92703          	lw	a4,76(s2)
    80005674:	02000793          	li	a5,32
    80005678:	f6e7f9e3          	bgeu	a5,a4,800055ea <sys_unlink+0xaa>
    8000567c:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005680:	4741                	li	a4,16
    80005682:	86ce                	mv	a3,s3
    80005684:	f1840613          	addi	a2,s0,-232
    80005688:	4581                	li	a1,0
    8000568a:	854a                	mv	a0,s2
    8000568c:	ffffe097          	auipc	ra,0xffffe
    80005690:	370080e7          	jalr	880(ra) # 800039fc <readi>
    80005694:	47c1                	li	a5,16
    80005696:	00f51b63          	bne	a0,a5,800056ac <sys_unlink+0x16c>
    if(de.inum != 0)
    8000569a:	f1845783          	lhu	a5,-232(s0)
    8000569e:	e7a1                	bnez	a5,800056e6 <sys_unlink+0x1a6>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    800056a0:	29c1                	addiw	s3,s3,16
    800056a2:	04c92783          	lw	a5,76(s2)
    800056a6:	fcf9ede3          	bltu	s3,a5,80005680 <sys_unlink+0x140>
    800056aa:	b781                	j	800055ea <sys_unlink+0xaa>
      panic("isdirempty: readi");
    800056ac:	00003517          	auipc	a0,0x3
    800056b0:	0a450513          	addi	a0,a0,164 # 80008750 <syscalls+0x2d8>
    800056b4:	ffffb097          	auipc	ra,0xffffb
    800056b8:	e88080e7          	jalr	-376(ra) # 8000053c <panic>
    panic("unlink: writei");
    800056bc:	00003517          	auipc	a0,0x3
    800056c0:	0ac50513          	addi	a0,a0,172 # 80008768 <syscalls+0x2f0>
    800056c4:	ffffb097          	auipc	ra,0xffffb
    800056c8:	e78080e7          	jalr	-392(ra) # 8000053c <panic>
    dp->nlink--;
    800056cc:	04a4d783          	lhu	a5,74(s1)
    800056d0:	37fd                	addiw	a5,a5,-1
    800056d2:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    800056d6:	8526                	mv	a0,s1
    800056d8:	ffffe097          	auipc	ra,0xffffe
    800056dc:	fa4080e7          	jalr	-92(ra) # 8000367c <iupdate>
    800056e0:	b781                	j	80005620 <sys_unlink+0xe0>
    return -1;
    800056e2:	557d                	li	a0,-1
    800056e4:	a005                	j	80005704 <sys_unlink+0x1c4>
    iunlockput(ip);
    800056e6:	854a                	mv	a0,s2
    800056e8:	ffffe097          	auipc	ra,0xffffe
    800056ec:	2c2080e7          	jalr	706(ra) # 800039aa <iunlockput>
  iunlockput(dp);
    800056f0:	8526                	mv	a0,s1
    800056f2:	ffffe097          	auipc	ra,0xffffe
    800056f6:	2b8080e7          	jalr	696(ra) # 800039aa <iunlockput>
  end_op();
    800056fa:	fffff097          	auipc	ra,0xfffff
    800056fe:	a6e080e7          	jalr	-1426(ra) # 80004168 <end_op>
  return -1;
    80005702:	557d                	li	a0,-1
}
    80005704:	70ae                	ld	ra,232(sp)
    80005706:	740e                	ld	s0,224(sp)
    80005708:	64ee                	ld	s1,216(sp)
    8000570a:	694e                	ld	s2,208(sp)
    8000570c:	69ae                	ld	s3,200(sp)
    8000570e:	616d                	addi	sp,sp,240
    80005710:	8082                	ret

0000000080005712 <sys_open>:

uint64
sys_open(void)
{
    80005712:	7131                	addi	sp,sp,-192
    80005714:	fd06                	sd	ra,184(sp)
    80005716:	f922                	sd	s0,176(sp)
    80005718:	f526                	sd	s1,168(sp)
    8000571a:	f14a                	sd	s2,160(sp)
    8000571c:	ed4e                	sd	s3,152(sp)
    8000571e:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    80005720:	f4c40593          	addi	a1,s0,-180
    80005724:	4505                	li	a0,1
    80005726:	ffffd097          	auipc	ra,0xffffd
    8000572a:	4c0080e7          	jalr	1216(ra) # 80002be6 <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    8000572e:	08000613          	li	a2,128
    80005732:	f5040593          	addi	a1,s0,-176
    80005736:	4501                	li	a0,0
    80005738:	ffffd097          	auipc	ra,0xffffd
    8000573c:	4ee080e7          	jalr	1262(ra) # 80002c26 <argstr>
    80005740:	87aa                	mv	a5,a0
    return -1;
    80005742:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005744:	0a07c863          	bltz	a5,800057f4 <sys_open+0xe2>

  begin_op();
    80005748:	fffff097          	auipc	ra,0xfffff
    8000574c:	9a6080e7          	jalr	-1626(ra) # 800040ee <begin_op>

  if(omode & O_CREATE){
    80005750:	f4c42783          	lw	a5,-180(s0)
    80005754:	2007f793          	andi	a5,a5,512
    80005758:	cbdd                	beqz	a5,8000580e <sys_open+0xfc>
    ip = create(path, T_FILE, 0, 0);
    8000575a:	4681                	li	a3,0
    8000575c:	4601                	li	a2,0
    8000575e:	4589                	li	a1,2
    80005760:	f5040513          	addi	a0,s0,-176
    80005764:	00000097          	auipc	ra,0x0
    80005768:	97a080e7          	jalr	-1670(ra) # 800050de <create>
    8000576c:	84aa                	mv	s1,a0
    if(ip == 0){
    8000576e:	c951                	beqz	a0,80005802 <sys_open+0xf0>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80005770:	04449703          	lh	a4,68(s1)
    80005774:	478d                	li	a5,3
    80005776:	00f71763          	bne	a4,a5,80005784 <sys_open+0x72>
    8000577a:	0464d703          	lhu	a4,70(s1)
    8000577e:	47a5                	li	a5,9
    80005780:	0ce7ec63          	bltu	a5,a4,80005858 <sys_open+0x146>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80005784:	fffff097          	auipc	ra,0xfffff
    80005788:	d72080e7          	jalr	-654(ra) # 800044f6 <filealloc>
    8000578c:	892a                	mv	s2,a0
    8000578e:	c56d                	beqz	a0,80005878 <sys_open+0x166>
    80005790:	00000097          	auipc	ra,0x0
    80005794:	90c080e7          	jalr	-1780(ra) # 8000509c <fdalloc>
    80005798:	89aa                	mv	s3,a0
    8000579a:	0c054a63          	bltz	a0,8000586e <sys_open+0x15c>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    8000579e:	04449703          	lh	a4,68(s1)
    800057a2:	478d                	li	a5,3
    800057a4:	0ef70563          	beq	a4,a5,8000588e <sys_open+0x17c>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    800057a8:	4789                	li	a5,2
    800057aa:	00f92023          	sw	a5,0(s2)
    f->off = 0;
    800057ae:	02092023          	sw	zero,32(s2)
  }
  f->ip = ip;
    800057b2:	00993c23          	sd	s1,24(s2)
  f->readable = !(omode & O_WRONLY);
    800057b6:	f4c42783          	lw	a5,-180(s0)
    800057ba:	0017c713          	xori	a4,a5,1
    800057be:	8b05                	andi	a4,a4,1
    800057c0:	00e90423          	sb	a4,8(s2)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    800057c4:	0037f713          	andi	a4,a5,3
    800057c8:	00e03733          	snez	a4,a4
    800057cc:	00e904a3          	sb	a4,9(s2)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    800057d0:	4007f793          	andi	a5,a5,1024
    800057d4:	c791                	beqz	a5,800057e0 <sys_open+0xce>
    800057d6:	04449703          	lh	a4,68(s1)
    800057da:	4789                	li	a5,2
    800057dc:	0cf70063          	beq	a4,a5,8000589c <sys_open+0x18a>
    itrunc(ip);
  }

  iunlock(ip);
    800057e0:	8526                	mv	a0,s1
    800057e2:	ffffe097          	auipc	ra,0xffffe
    800057e6:	028080e7          	jalr	40(ra) # 8000380a <iunlock>
  end_op();
    800057ea:	fffff097          	auipc	ra,0xfffff
    800057ee:	97e080e7          	jalr	-1666(ra) # 80004168 <end_op>

  return fd;
    800057f2:	854e                	mv	a0,s3
}
    800057f4:	70ea                	ld	ra,184(sp)
    800057f6:	744a                	ld	s0,176(sp)
    800057f8:	74aa                	ld	s1,168(sp)
    800057fa:	790a                	ld	s2,160(sp)
    800057fc:	69ea                	ld	s3,152(sp)
    800057fe:	6129                	addi	sp,sp,192
    80005800:	8082                	ret
      end_op();
    80005802:	fffff097          	auipc	ra,0xfffff
    80005806:	966080e7          	jalr	-1690(ra) # 80004168 <end_op>
      return -1;
    8000580a:	557d                	li	a0,-1
    8000580c:	b7e5                	j	800057f4 <sys_open+0xe2>
    if((ip = namei(path)) == 0){
    8000580e:	f5040513          	addi	a0,s0,-176
    80005812:	ffffe097          	auipc	ra,0xffffe
    80005816:	6dc080e7          	jalr	1756(ra) # 80003eee <namei>
    8000581a:	84aa                	mv	s1,a0
    8000581c:	c905                	beqz	a0,8000584c <sys_open+0x13a>
    ilock(ip);
    8000581e:	ffffe097          	auipc	ra,0xffffe
    80005822:	f2a080e7          	jalr	-214(ra) # 80003748 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80005826:	04449703          	lh	a4,68(s1)
    8000582a:	4785                	li	a5,1
    8000582c:	f4f712e3          	bne	a4,a5,80005770 <sys_open+0x5e>
    80005830:	f4c42783          	lw	a5,-180(s0)
    80005834:	dba1                	beqz	a5,80005784 <sys_open+0x72>
      iunlockput(ip);
    80005836:	8526                	mv	a0,s1
    80005838:	ffffe097          	auipc	ra,0xffffe
    8000583c:	172080e7          	jalr	370(ra) # 800039aa <iunlockput>
      end_op();
    80005840:	fffff097          	auipc	ra,0xfffff
    80005844:	928080e7          	jalr	-1752(ra) # 80004168 <end_op>
      return -1;
    80005848:	557d                	li	a0,-1
    8000584a:	b76d                	j	800057f4 <sys_open+0xe2>
      end_op();
    8000584c:	fffff097          	auipc	ra,0xfffff
    80005850:	91c080e7          	jalr	-1764(ra) # 80004168 <end_op>
      return -1;
    80005854:	557d                	li	a0,-1
    80005856:	bf79                	j	800057f4 <sys_open+0xe2>
    iunlockput(ip);
    80005858:	8526                	mv	a0,s1
    8000585a:	ffffe097          	auipc	ra,0xffffe
    8000585e:	150080e7          	jalr	336(ra) # 800039aa <iunlockput>
    end_op();
    80005862:	fffff097          	auipc	ra,0xfffff
    80005866:	906080e7          	jalr	-1786(ra) # 80004168 <end_op>
    return -1;
    8000586a:	557d                	li	a0,-1
    8000586c:	b761                	j	800057f4 <sys_open+0xe2>
      fileclose(f);
    8000586e:	854a                	mv	a0,s2
    80005870:	fffff097          	auipc	ra,0xfffff
    80005874:	d42080e7          	jalr	-702(ra) # 800045b2 <fileclose>
    iunlockput(ip);
    80005878:	8526                	mv	a0,s1
    8000587a:	ffffe097          	auipc	ra,0xffffe
    8000587e:	130080e7          	jalr	304(ra) # 800039aa <iunlockput>
    end_op();
    80005882:	fffff097          	auipc	ra,0xfffff
    80005886:	8e6080e7          	jalr	-1818(ra) # 80004168 <end_op>
    return -1;
    8000588a:	557d                	li	a0,-1
    8000588c:	b7a5                	j	800057f4 <sys_open+0xe2>
    f->type = FD_DEVICE;
    8000588e:	00f92023          	sw	a5,0(s2)
    f->major = ip->major;
    80005892:	04649783          	lh	a5,70(s1)
    80005896:	02f91223          	sh	a5,36(s2)
    8000589a:	bf21                	j	800057b2 <sys_open+0xa0>
    itrunc(ip);
    8000589c:	8526                	mv	a0,s1
    8000589e:	ffffe097          	auipc	ra,0xffffe
    800058a2:	fb8080e7          	jalr	-72(ra) # 80003856 <itrunc>
    800058a6:	bf2d                	j	800057e0 <sys_open+0xce>

00000000800058a8 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    800058a8:	7175                	addi	sp,sp,-144
    800058aa:	e506                	sd	ra,136(sp)
    800058ac:	e122                	sd	s0,128(sp)
    800058ae:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    800058b0:	fffff097          	auipc	ra,0xfffff
    800058b4:	83e080e7          	jalr	-1986(ra) # 800040ee <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    800058b8:	08000613          	li	a2,128
    800058bc:	f7040593          	addi	a1,s0,-144
    800058c0:	4501                	li	a0,0
    800058c2:	ffffd097          	auipc	ra,0xffffd
    800058c6:	364080e7          	jalr	868(ra) # 80002c26 <argstr>
    800058ca:	02054963          	bltz	a0,800058fc <sys_mkdir+0x54>
    800058ce:	4681                	li	a3,0
    800058d0:	4601                	li	a2,0
    800058d2:	4585                	li	a1,1
    800058d4:	f7040513          	addi	a0,s0,-144
    800058d8:	00000097          	auipc	ra,0x0
    800058dc:	806080e7          	jalr	-2042(ra) # 800050de <create>
    800058e0:	cd11                	beqz	a0,800058fc <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    800058e2:	ffffe097          	auipc	ra,0xffffe
    800058e6:	0c8080e7          	jalr	200(ra) # 800039aa <iunlockput>
  end_op();
    800058ea:	fffff097          	auipc	ra,0xfffff
    800058ee:	87e080e7          	jalr	-1922(ra) # 80004168 <end_op>
  return 0;
    800058f2:	4501                	li	a0,0
}
    800058f4:	60aa                	ld	ra,136(sp)
    800058f6:	640a                	ld	s0,128(sp)
    800058f8:	6149                	addi	sp,sp,144
    800058fa:	8082                	ret
    end_op();
    800058fc:	fffff097          	auipc	ra,0xfffff
    80005900:	86c080e7          	jalr	-1940(ra) # 80004168 <end_op>
    return -1;
    80005904:	557d                	li	a0,-1
    80005906:	b7fd                	j	800058f4 <sys_mkdir+0x4c>

0000000080005908 <sys_mknod>:

uint64
sys_mknod(void)
{
    80005908:	7135                	addi	sp,sp,-160
    8000590a:	ed06                	sd	ra,152(sp)
    8000590c:	e922                	sd	s0,144(sp)
    8000590e:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80005910:	ffffe097          	auipc	ra,0xffffe
    80005914:	7de080e7          	jalr	2014(ra) # 800040ee <begin_op>
  argint(1, &major);
    80005918:	f6c40593          	addi	a1,s0,-148
    8000591c:	4505                	li	a0,1
    8000591e:	ffffd097          	auipc	ra,0xffffd
    80005922:	2c8080e7          	jalr	712(ra) # 80002be6 <argint>
  argint(2, &minor);
    80005926:	f6840593          	addi	a1,s0,-152
    8000592a:	4509                	li	a0,2
    8000592c:	ffffd097          	auipc	ra,0xffffd
    80005930:	2ba080e7          	jalr	698(ra) # 80002be6 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005934:	08000613          	li	a2,128
    80005938:	f7040593          	addi	a1,s0,-144
    8000593c:	4501                	li	a0,0
    8000593e:	ffffd097          	auipc	ra,0xffffd
    80005942:	2e8080e7          	jalr	744(ra) # 80002c26 <argstr>
    80005946:	02054b63          	bltz	a0,8000597c <sys_mknod+0x74>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    8000594a:	f6841683          	lh	a3,-152(s0)
    8000594e:	f6c41603          	lh	a2,-148(s0)
    80005952:	458d                	li	a1,3
    80005954:	f7040513          	addi	a0,s0,-144
    80005958:	fffff097          	auipc	ra,0xfffff
    8000595c:	786080e7          	jalr	1926(ra) # 800050de <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005960:	cd11                	beqz	a0,8000597c <sys_mknod+0x74>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005962:	ffffe097          	auipc	ra,0xffffe
    80005966:	048080e7          	jalr	72(ra) # 800039aa <iunlockput>
  end_op();
    8000596a:	ffffe097          	auipc	ra,0xffffe
    8000596e:	7fe080e7          	jalr	2046(ra) # 80004168 <end_op>
  return 0;
    80005972:	4501                	li	a0,0
}
    80005974:	60ea                	ld	ra,152(sp)
    80005976:	644a                	ld	s0,144(sp)
    80005978:	610d                	addi	sp,sp,160
    8000597a:	8082                	ret
    end_op();
    8000597c:	ffffe097          	auipc	ra,0xffffe
    80005980:	7ec080e7          	jalr	2028(ra) # 80004168 <end_op>
    return -1;
    80005984:	557d                	li	a0,-1
    80005986:	b7fd                	j	80005974 <sys_mknod+0x6c>

0000000080005988 <sys_chdir>:

uint64
sys_chdir(void)
{
    80005988:	7135                	addi	sp,sp,-160
    8000598a:	ed06                	sd	ra,152(sp)
    8000598c:	e922                	sd	s0,144(sp)
    8000598e:	e526                	sd	s1,136(sp)
    80005990:	e14a                	sd	s2,128(sp)
    80005992:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80005994:	ffffc097          	auipc	ra,0xffffc
    80005998:	04e080e7          	jalr	78(ra) # 800019e2 <myproc>
    8000599c:	892a                	mv	s2,a0
  
  begin_op();
    8000599e:	ffffe097          	auipc	ra,0xffffe
    800059a2:	750080e7          	jalr	1872(ra) # 800040ee <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    800059a6:	08000613          	li	a2,128
    800059aa:	f6040593          	addi	a1,s0,-160
    800059ae:	4501                	li	a0,0
    800059b0:	ffffd097          	auipc	ra,0xffffd
    800059b4:	276080e7          	jalr	630(ra) # 80002c26 <argstr>
    800059b8:	04054b63          	bltz	a0,80005a0e <sys_chdir+0x86>
    800059bc:	f6040513          	addi	a0,s0,-160
    800059c0:	ffffe097          	auipc	ra,0xffffe
    800059c4:	52e080e7          	jalr	1326(ra) # 80003eee <namei>
    800059c8:	84aa                	mv	s1,a0
    800059ca:	c131                	beqz	a0,80005a0e <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    800059cc:	ffffe097          	auipc	ra,0xffffe
    800059d0:	d7c080e7          	jalr	-644(ra) # 80003748 <ilock>
  if(ip->type != T_DIR){
    800059d4:	04449703          	lh	a4,68(s1)
    800059d8:	4785                	li	a5,1
    800059da:	04f71063          	bne	a4,a5,80005a1a <sys_chdir+0x92>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    800059de:	8526                	mv	a0,s1
    800059e0:	ffffe097          	auipc	ra,0xffffe
    800059e4:	e2a080e7          	jalr	-470(ra) # 8000380a <iunlock>
  iput(p->cwd);
    800059e8:	15093503          	ld	a0,336(s2)
    800059ec:	ffffe097          	auipc	ra,0xffffe
    800059f0:	f16080e7          	jalr	-234(ra) # 80003902 <iput>
  end_op();
    800059f4:	ffffe097          	auipc	ra,0xffffe
    800059f8:	774080e7          	jalr	1908(ra) # 80004168 <end_op>
  p->cwd = ip;
    800059fc:	14993823          	sd	s1,336(s2)
  return 0;
    80005a00:	4501                	li	a0,0
}
    80005a02:	60ea                	ld	ra,152(sp)
    80005a04:	644a                	ld	s0,144(sp)
    80005a06:	64aa                	ld	s1,136(sp)
    80005a08:	690a                	ld	s2,128(sp)
    80005a0a:	610d                	addi	sp,sp,160
    80005a0c:	8082                	ret
    end_op();
    80005a0e:	ffffe097          	auipc	ra,0xffffe
    80005a12:	75a080e7          	jalr	1882(ra) # 80004168 <end_op>
    return -1;
    80005a16:	557d                	li	a0,-1
    80005a18:	b7ed                	j	80005a02 <sys_chdir+0x7a>
    iunlockput(ip);
    80005a1a:	8526                	mv	a0,s1
    80005a1c:	ffffe097          	auipc	ra,0xffffe
    80005a20:	f8e080e7          	jalr	-114(ra) # 800039aa <iunlockput>
    end_op();
    80005a24:	ffffe097          	auipc	ra,0xffffe
    80005a28:	744080e7          	jalr	1860(ra) # 80004168 <end_op>
    return -1;
    80005a2c:	557d                	li	a0,-1
    80005a2e:	bfd1                	j	80005a02 <sys_chdir+0x7a>

0000000080005a30 <sys_exec>:

uint64
sys_exec(void)
{
    80005a30:	7121                	addi	sp,sp,-448
    80005a32:	ff06                	sd	ra,440(sp)
    80005a34:	fb22                	sd	s0,432(sp)
    80005a36:	f726                	sd	s1,424(sp)
    80005a38:	f34a                	sd	s2,416(sp)
    80005a3a:	ef4e                	sd	s3,408(sp)
    80005a3c:	eb52                	sd	s4,400(sp)
    80005a3e:	0380                	addi	s0,sp,448
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    80005a40:	e4840593          	addi	a1,s0,-440
    80005a44:	4505                	li	a0,1
    80005a46:	ffffd097          	auipc	ra,0xffffd
    80005a4a:	1c0080e7          	jalr	448(ra) # 80002c06 <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    80005a4e:	08000613          	li	a2,128
    80005a52:	f5040593          	addi	a1,s0,-176
    80005a56:	4501                	li	a0,0
    80005a58:	ffffd097          	auipc	ra,0xffffd
    80005a5c:	1ce080e7          	jalr	462(ra) # 80002c26 <argstr>
    80005a60:	87aa                	mv	a5,a0
    return -1;
    80005a62:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    80005a64:	0c07c263          	bltz	a5,80005b28 <sys_exec+0xf8>
  }
  memset(argv, 0, sizeof(argv));
    80005a68:	10000613          	li	a2,256
    80005a6c:	4581                	li	a1,0
    80005a6e:	e5040513          	addi	a0,s0,-432
    80005a72:	ffffb097          	auipc	ra,0xffffb
    80005a76:	25c080e7          	jalr	604(ra) # 80000cce <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80005a7a:	e5040493          	addi	s1,s0,-432
  memset(argv, 0, sizeof(argv));
    80005a7e:	89a6                	mv	s3,s1
    80005a80:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80005a82:	02000a13          	li	s4,32
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80005a86:	00391513          	slli	a0,s2,0x3
    80005a8a:	e4040593          	addi	a1,s0,-448
    80005a8e:	e4843783          	ld	a5,-440(s0)
    80005a92:	953e                	add	a0,a0,a5
    80005a94:	ffffd097          	auipc	ra,0xffffd
    80005a98:	0b4080e7          	jalr	180(ra) # 80002b48 <fetchaddr>
    80005a9c:	02054a63          	bltz	a0,80005ad0 <sys_exec+0xa0>
      goto bad;
    }
    if(uarg == 0){
    80005aa0:	e4043783          	ld	a5,-448(s0)
    80005aa4:	c3b9                	beqz	a5,80005aea <sys_exec+0xba>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80005aa6:	ffffb097          	auipc	ra,0xffffb
    80005aaa:	03c080e7          	jalr	60(ra) # 80000ae2 <kalloc>
    80005aae:	85aa                	mv	a1,a0
    80005ab0:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80005ab4:	cd11                	beqz	a0,80005ad0 <sys_exec+0xa0>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005ab6:	6605                	lui	a2,0x1
    80005ab8:	e4043503          	ld	a0,-448(s0)
    80005abc:	ffffd097          	auipc	ra,0xffffd
    80005ac0:	0de080e7          	jalr	222(ra) # 80002b9a <fetchstr>
    80005ac4:	00054663          	bltz	a0,80005ad0 <sys_exec+0xa0>
    if(i >= NELEM(argv)){
    80005ac8:	0905                	addi	s2,s2,1
    80005aca:	09a1                	addi	s3,s3,8
    80005acc:	fb491de3          	bne	s2,s4,80005a86 <sys_exec+0x56>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005ad0:	f5040913          	addi	s2,s0,-176
    80005ad4:	6088                	ld	a0,0(s1)
    80005ad6:	c921                	beqz	a0,80005b26 <sys_exec+0xf6>
    kfree(argv[i]);
    80005ad8:	ffffb097          	auipc	ra,0xffffb
    80005adc:	f0c080e7          	jalr	-244(ra) # 800009e4 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005ae0:	04a1                	addi	s1,s1,8
    80005ae2:	ff2499e3          	bne	s1,s2,80005ad4 <sys_exec+0xa4>
  return -1;
    80005ae6:	557d                	li	a0,-1
    80005ae8:	a081                	j	80005b28 <sys_exec+0xf8>
      argv[i] = 0;
    80005aea:	0009079b          	sext.w	a5,s2
    80005aee:	078e                	slli	a5,a5,0x3
    80005af0:	fd078793          	addi	a5,a5,-48
    80005af4:	97a2                	add	a5,a5,s0
    80005af6:	e807b023          	sd	zero,-384(a5)
  int ret = exec(path, argv);
    80005afa:	e5040593          	addi	a1,s0,-432
    80005afe:	f5040513          	addi	a0,s0,-176
    80005b02:	fffff097          	auipc	ra,0xfffff
    80005b06:	1d0080e7          	jalr	464(ra) # 80004cd2 <exec>
    80005b0a:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005b0c:	f5040993          	addi	s3,s0,-176
    80005b10:	6088                	ld	a0,0(s1)
    80005b12:	c901                	beqz	a0,80005b22 <sys_exec+0xf2>
    kfree(argv[i]);
    80005b14:	ffffb097          	auipc	ra,0xffffb
    80005b18:	ed0080e7          	jalr	-304(ra) # 800009e4 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005b1c:	04a1                	addi	s1,s1,8
    80005b1e:	ff3499e3          	bne	s1,s3,80005b10 <sys_exec+0xe0>
  return ret;
    80005b22:	854a                	mv	a0,s2
    80005b24:	a011                	j	80005b28 <sys_exec+0xf8>
  return -1;
    80005b26:	557d                	li	a0,-1
}
    80005b28:	70fa                	ld	ra,440(sp)
    80005b2a:	745a                	ld	s0,432(sp)
    80005b2c:	74ba                	ld	s1,424(sp)
    80005b2e:	791a                	ld	s2,416(sp)
    80005b30:	69fa                	ld	s3,408(sp)
    80005b32:	6a5a                	ld	s4,400(sp)
    80005b34:	6139                	addi	sp,sp,448
    80005b36:	8082                	ret

0000000080005b38 <sys_pipe>:

uint64
sys_pipe(void)
{
    80005b38:	7139                	addi	sp,sp,-64
    80005b3a:	fc06                	sd	ra,56(sp)
    80005b3c:	f822                	sd	s0,48(sp)
    80005b3e:	f426                	sd	s1,40(sp)
    80005b40:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005b42:	ffffc097          	auipc	ra,0xffffc
    80005b46:	ea0080e7          	jalr	-352(ra) # 800019e2 <myproc>
    80005b4a:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    80005b4c:	fd840593          	addi	a1,s0,-40
    80005b50:	4501                	li	a0,0
    80005b52:	ffffd097          	auipc	ra,0xffffd
    80005b56:	0b4080e7          	jalr	180(ra) # 80002c06 <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    80005b5a:	fc840593          	addi	a1,s0,-56
    80005b5e:	fd040513          	addi	a0,s0,-48
    80005b62:	fffff097          	auipc	ra,0xfffff
    80005b66:	d7c080e7          	jalr	-644(ra) # 800048de <pipealloc>
    return -1;
    80005b6a:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80005b6c:	0c054463          	bltz	a0,80005c34 <sys_pipe+0xfc>
  fd0 = -1;
    80005b70:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80005b74:	fd043503          	ld	a0,-48(s0)
    80005b78:	fffff097          	auipc	ra,0xfffff
    80005b7c:	524080e7          	jalr	1316(ra) # 8000509c <fdalloc>
    80005b80:	fca42223          	sw	a0,-60(s0)
    80005b84:	08054b63          	bltz	a0,80005c1a <sys_pipe+0xe2>
    80005b88:	fc843503          	ld	a0,-56(s0)
    80005b8c:	fffff097          	auipc	ra,0xfffff
    80005b90:	510080e7          	jalr	1296(ra) # 8000509c <fdalloc>
    80005b94:	fca42023          	sw	a0,-64(s0)
    80005b98:	06054863          	bltz	a0,80005c08 <sys_pipe+0xd0>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005b9c:	4691                	li	a3,4
    80005b9e:	fc440613          	addi	a2,s0,-60
    80005ba2:	fd843583          	ld	a1,-40(s0)
    80005ba6:	68a8                	ld	a0,80(s1)
    80005ba8:	ffffc097          	auipc	ra,0xffffc
    80005bac:	aea080e7          	jalr	-1302(ra) # 80001692 <copyout>
    80005bb0:	02054063          	bltz	a0,80005bd0 <sys_pipe+0x98>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80005bb4:	4691                	li	a3,4
    80005bb6:	fc040613          	addi	a2,s0,-64
    80005bba:	fd843583          	ld	a1,-40(s0)
    80005bbe:	0591                	addi	a1,a1,4
    80005bc0:	68a8                	ld	a0,80(s1)
    80005bc2:	ffffc097          	auipc	ra,0xffffc
    80005bc6:	ad0080e7          	jalr	-1328(ra) # 80001692 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80005bca:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005bcc:	06055463          	bgez	a0,80005c34 <sys_pipe+0xfc>
    p->ofile[fd0] = 0;
    80005bd0:	fc442783          	lw	a5,-60(s0)
    80005bd4:	07e9                	addi	a5,a5,26
    80005bd6:	078e                	slli	a5,a5,0x3
    80005bd8:	97a6                	add	a5,a5,s1
    80005bda:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80005bde:	fc042783          	lw	a5,-64(s0)
    80005be2:	07e9                	addi	a5,a5,26
    80005be4:	078e                	slli	a5,a5,0x3
    80005be6:	94be                	add	s1,s1,a5
    80005be8:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    80005bec:	fd043503          	ld	a0,-48(s0)
    80005bf0:	fffff097          	auipc	ra,0xfffff
    80005bf4:	9c2080e7          	jalr	-1598(ra) # 800045b2 <fileclose>
    fileclose(wf);
    80005bf8:	fc843503          	ld	a0,-56(s0)
    80005bfc:	fffff097          	auipc	ra,0xfffff
    80005c00:	9b6080e7          	jalr	-1610(ra) # 800045b2 <fileclose>
    return -1;
    80005c04:	57fd                	li	a5,-1
    80005c06:	a03d                	j	80005c34 <sys_pipe+0xfc>
    if(fd0 >= 0)
    80005c08:	fc442783          	lw	a5,-60(s0)
    80005c0c:	0007c763          	bltz	a5,80005c1a <sys_pipe+0xe2>
      p->ofile[fd0] = 0;
    80005c10:	07e9                	addi	a5,a5,26
    80005c12:	078e                	slli	a5,a5,0x3
    80005c14:	97a6                	add	a5,a5,s1
    80005c16:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    80005c1a:	fd043503          	ld	a0,-48(s0)
    80005c1e:	fffff097          	auipc	ra,0xfffff
    80005c22:	994080e7          	jalr	-1644(ra) # 800045b2 <fileclose>
    fileclose(wf);
    80005c26:	fc843503          	ld	a0,-56(s0)
    80005c2a:	fffff097          	auipc	ra,0xfffff
    80005c2e:	988080e7          	jalr	-1656(ra) # 800045b2 <fileclose>
    return -1;
    80005c32:	57fd                	li	a5,-1
}
    80005c34:	853e                	mv	a0,a5
    80005c36:	70e2                	ld	ra,56(sp)
    80005c38:	7442                	ld	s0,48(sp)
    80005c3a:	74a2                	ld	s1,40(sp)
    80005c3c:	6121                	addi	sp,sp,64
    80005c3e:	8082                	ret

0000000080005c40 <kernelvec>:
    80005c40:	7111                	addi	sp,sp,-256
    80005c42:	e006                	sd	ra,0(sp)
    80005c44:	e40a                	sd	sp,8(sp)
    80005c46:	e80e                	sd	gp,16(sp)
    80005c48:	ec12                	sd	tp,24(sp)
    80005c4a:	f016                	sd	t0,32(sp)
    80005c4c:	f41a                	sd	t1,40(sp)
    80005c4e:	f81e                	sd	t2,48(sp)
    80005c50:	fc22                	sd	s0,56(sp)
    80005c52:	e0a6                	sd	s1,64(sp)
    80005c54:	e4aa                	sd	a0,72(sp)
    80005c56:	e8ae                	sd	a1,80(sp)
    80005c58:	ecb2                	sd	a2,88(sp)
    80005c5a:	f0b6                	sd	a3,96(sp)
    80005c5c:	f4ba                	sd	a4,104(sp)
    80005c5e:	f8be                	sd	a5,112(sp)
    80005c60:	fcc2                	sd	a6,120(sp)
    80005c62:	e146                	sd	a7,128(sp)
    80005c64:	e54a                	sd	s2,136(sp)
    80005c66:	e94e                	sd	s3,144(sp)
    80005c68:	ed52                	sd	s4,152(sp)
    80005c6a:	f156                	sd	s5,160(sp)
    80005c6c:	f55a                	sd	s6,168(sp)
    80005c6e:	f95e                	sd	s7,176(sp)
    80005c70:	fd62                	sd	s8,184(sp)
    80005c72:	e1e6                	sd	s9,192(sp)
    80005c74:	e5ea                	sd	s10,200(sp)
    80005c76:	e9ee                	sd	s11,208(sp)
    80005c78:	edf2                	sd	t3,216(sp)
    80005c7a:	f1f6                	sd	t4,224(sp)
    80005c7c:	f5fa                	sd	t5,232(sp)
    80005c7e:	f9fe                	sd	t6,240(sp)
    80005c80:	d95fc0ef          	jal	ra,80002a14 <kerneltrap>
    80005c84:	6082                	ld	ra,0(sp)
    80005c86:	6122                	ld	sp,8(sp)
    80005c88:	61c2                	ld	gp,16(sp)
    80005c8a:	7282                	ld	t0,32(sp)
    80005c8c:	7322                	ld	t1,40(sp)
    80005c8e:	73c2                	ld	t2,48(sp)
    80005c90:	7462                	ld	s0,56(sp)
    80005c92:	6486                	ld	s1,64(sp)
    80005c94:	6526                	ld	a0,72(sp)
    80005c96:	65c6                	ld	a1,80(sp)
    80005c98:	6666                	ld	a2,88(sp)
    80005c9a:	7686                	ld	a3,96(sp)
    80005c9c:	7726                	ld	a4,104(sp)
    80005c9e:	77c6                	ld	a5,112(sp)
    80005ca0:	7866                	ld	a6,120(sp)
    80005ca2:	688a                	ld	a7,128(sp)
    80005ca4:	692a                	ld	s2,136(sp)
    80005ca6:	69ca                	ld	s3,144(sp)
    80005ca8:	6a6a                	ld	s4,152(sp)
    80005caa:	7a8a                	ld	s5,160(sp)
    80005cac:	7b2a                	ld	s6,168(sp)
    80005cae:	7bca                	ld	s7,176(sp)
    80005cb0:	7c6a                	ld	s8,184(sp)
    80005cb2:	6c8e                	ld	s9,192(sp)
    80005cb4:	6d2e                	ld	s10,200(sp)
    80005cb6:	6dce                	ld	s11,208(sp)
    80005cb8:	6e6e                	ld	t3,216(sp)
    80005cba:	7e8e                	ld	t4,224(sp)
    80005cbc:	7f2e                	ld	t5,232(sp)
    80005cbe:	7fce                	ld	t6,240(sp)
    80005cc0:	6111                	addi	sp,sp,256
    80005cc2:	10200073          	sret
    80005cc6:	00000013          	nop
    80005cca:	00000013          	nop
    80005cce:	0001                	nop

0000000080005cd0 <timervec>:
    80005cd0:	34051573          	csrrw	a0,mscratch,a0
    80005cd4:	e10c                	sd	a1,0(a0)
    80005cd6:	e510                	sd	a2,8(a0)
    80005cd8:	e914                	sd	a3,16(a0)
    80005cda:	6d0c                	ld	a1,24(a0)
    80005cdc:	7110                	ld	a2,32(a0)
    80005cde:	6194                	ld	a3,0(a1)
    80005ce0:	96b2                	add	a3,a3,a2
    80005ce2:	e194                	sd	a3,0(a1)
    80005ce4:	4589                	li	a1,2
    80005ce6:	14459073          	csrw	sip,a1
    80005cea:	6914                	ld	a3,16(a0)
    80005cec:	6510                	ld	a2,8(a0)
    80005cee:	610c                	ld	a1,0(a0)
    80005cf0:	34051573          	csrrw	a0,mscratch,a0
    80005cf4:	30200073          	mret
	...

0000000080005cfa <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    80005cfa:	1141                	addi	sp,sp,-16
    80005cfc:	e422                	sd	s0,8(sp)
    80005cfe:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80005d00:	0c0007b7          	lui	a5,0xc000
    80005d04:	4705                	li	a4,1
    80005d06:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80005d08:	c3d8                	sw	a4,4(a5)
}
    80005d0a:	6422                	ld	s0,8(sp)
    80005d0c:	0141                	addi	sp,sp,16
    80005d0e:	8082                	ret

0000000080005d10 <plicinithart>:

void
plicinithart(void)
{
    80005d10:	1141                	addi	sp,sp,-16
    80005d12:	e406                	sd	ra,8(sp)
    80005d14:	e022                	sd	s0,0(sp)
    80005d16:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005d18:	ffffc097          	auipc	ra,0xffffc
    80005d1c:	c9e080e7          	jalr	-866(ra) # 800019b6 <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80005d20:	0085171b          	slliw	a4,a0,0x8
    80005d24:	0c0027b7          	lui	a5,0xc002
    80005d28:	97ba                	add	a5,a5,a4
    80005d2a:	40200713          	li	a4,1026
    80005d2e:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80005d32:	00d5151b          	slliw	a0,a0,0xd
    80005d36:	0c2017b7          	lui	a5,0xc201
    80005d3a:	97aa                	add	a5,a5,a0
    80005d3c:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
}
    80005d40:	60a2                	ld	ra,8(sp)
    80005d42:	6402                	ld	s0,0(sp)
    80005d44:	0141                	addi	sp,sp,16
    80005d46:	8082                	ret

0000000080005d48 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80005d48:	1141                	addi	sp,sp,-16
    80005d4a:	e406                	sd	ra,8(sp)
    80005d4c:	e022                	sd	s0,0(sp)
    80005d4e:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005d50:	ffffc097          	auipc	ra,0xffffc
    80005d54:	c66080e7          	jalr	-922(ra) # 800019b6 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80005d58:	00d5151b          	slliw	a0,a0,0xd
    80005d5c:	0c2017b7          	lui	a5,0xc201
    80005d60:	97aa                	add	a5,a5,a0
  return irq;
}
    80005d62:	43c8                	lw	a0,4(a5)
    80005d64:	60a2                	ld	ra,8(sp)
    80005d66:	6402                	ld	s0,0(sp)
    80005d68:	0141                	addi	sp,sp,16
    80005d6a:	8082                	ret

0000000080005d6c <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    80005d6c:	1101                	addi	sp,sp,-32
    80005d6e:	ec06                	sd	ra,24(sp)
    80005d70:	e822                	sd	s0,16(sp)
    80005d72:	e426                	sd	s1,8(sp)
    80005d74:	1000                	addi	s0,sp,32
    80005d76:	84aa                	mv	s1,a0
  int hart = cpuid();
    80005d78:	ffffc097          	auipc	ra,0xffffc
    80005d7c:	c3e080e7          	jalr	-962(ra) # 800019b6 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80005d80:	00d5151b          	slliw	a0,a0,0xd
    80005d84:	0c2017b7          	lui	a5,0xc201
    80005d88:	97aa                	add	a5,a5,a0
    80005d8a:	c3c4                	sw	s1,4(a5)
}
    80005d8c:	60e2                	ld	ra,24(sp)
    80005d8e:	6442                	ld	s0,16(sp)
    80005d90:	64a2                	ld	s1,8(sp)
    80005d92:	6105                	addi	sp,sp,32
    80005d94:	8082                	ret

0000000080005d96 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80005d96:	1141                	addi	sp,sp,-16
    80005d98:	e406                	sd	ra,8(sp)
    80005d9a:	e022                	sd	s0,0(sp)
    80005d9c:	0800                	addi	s0,sp,16
  if(i >= NUM)
    80005d9e:	479d                	li	a5,7
    80005da0:	04a7cc63          	blt	a5,a0,80005df8 <free_desc+0x62>
    panic("free_desc 1");
  if(disk.free[i])
    80005da4:	00193797          	auipc	a5,0x193
    80005da8:	44478793          	addi	a5,a5,1092 # 801991e8 <disk>
    80005dac:	97aa                	add	a5,a5,a0
    80005dae:	0187c783          	lbu	a5,24(a5)
    80005db2:	ebb9                	bnez	a5,80005e08 <free_desc+0x72>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80005db4:	00451693          	slli	a3,a0,0x4
    80005db8:	00193797          	auipc	a5,0x193
    80005dbc:	43078793          	addi	a5,a5,1072 # 801991e8 <disk>
    80005dc0:	6398                	ld	a4,0(a5)
    80005dc2:	9736                	add	a4,a4,a3
    80005dc4:	00073023          	sd	zero,0(a4)
  disk.desc[i].len = 0;
    80005dc8:	6398                	ld	a4,0(a5)
    80005dca:	9736                	add	a4,a4,a3
    80005dcc:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    80005dd0:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    80005dd4:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    80005dd8:	97aa                	add	a5,a5,a0
    80005dda:	4705                	li	a4,1
    80005ddc:	00e78c23          	sb	a4,24(a5)
  wakeup(&disk.free[0]);
    80005de0:	00193517          	auipc	a0,0x193
    80005de4:	42050513          	addi	a0,a0,1056 # 80199200 <disk+0x18>
    80005de8:	ffffc097          	auipc	ra,0xffffc
    80005dec:	3ac080e7          	jalr	940(ra) # 80002194 <wakeup>
}
    80005df0:	60a2                	ld	ra,8(sp)
    80005df2:	6402                	ld	s0,0(sp)
    80005df4:	0141                	addi	sp,sp,16
    80005df6:	8082                	ret
    panic("free_desc 1");
    80005df8:	00003517          	auipc	a0,0x3
    80005dfc:	98050513          	addi	a0,a0,-1664 # 80008778 <syscalls+0x300>
    80005e00:	ffffa097          	auipc	ra,0xffffa
    80005e04:	73c080e7          	jalr	1852(ra) # 8000053c <panic>
    panic("free_desc 2");
    80005e08:	00003517          	auipc	a0,0x3
    80005e0c:	98050513          	addi	a0,a0,-1664 # 80008788 <syscalls+0x310>
    80005e10:	ffffa097          	auipc	ra,0xffffa
    80005e14:	72c080e7          	jalr	1836(ra) # 8000053c <panic>

0000000080005e18 <virtio_disk_init>:
{
    80005e18:	1101                	addi	sp,sp,-32
    80005e1a:	ec06                	sd	ra,24(sp)
    80005e1c:	e822                	sd	s0,16(sp)
    80005e1e:	e426                	sd	s1,8(sp)
    80005e20:	e04a                	sd	s2,0(sp)
    80005e22:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80005e24:	00003597          	auipc	a1,0x3
    80005e28:	97458593          	addi	a1,a1,-1676 # 80008798 <syscalls+0x320>
    80005e2c:	00193517          	auipc	a0,0x193
    80005e30:	4e450513          	addi	a0,a0,1252 # 80199310 <disk+0x128>
    80005e34:	ffffb097          	auipc	ra,0xffffb
    80005e38:	d0e080e7          	jalr	-754(ra) # 80000b42 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005e3c:	100017b7          	lui	a5,0x10001
    80005e40:	4398                	lw	a4,0(a5)
    80005e42:	2701                	sext.w	a4,a4
    80005e44:	747277b7          	lui	a5,0x74727
    80005e48:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80005e4c:	14f71b63          	bne	a4,a5,80005fa2 <virtio_disk_init+0x18a>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80005e50:	100017b7          	lui	a5,0x10001
    80005e54:	43dc                	lw	a5,4(a5)
    80005e56:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005e58:	4709                	li	a4,2
    80005e5a:	14e79463          	bne	a5,a4,80005fa2 <virtio_disk_init+0x18a>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005e5e:	100017b7          	lui	a5,0x10001
    80005e62:	479c                	lw	a5,8(a5)
    80005e64:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80005e66:	12e79e63          	bne	a5,a4,80005fa2 <virtio_disk_init+0x18a>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    80005e6a:	100017b7          	lui	a5,0x10001
    80005e6e:	47d8                	lw	a4,12(a5)
    80005e70:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005e72:	554d47b7          	lui	a5,0x554d4
    80005e76:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    80005e7a:	12f71463          	bne	a4,a5,80005fa2 <virtio_disk_init+0x18a>
  *R(VIRTIO_MMIO_STATUS) = status;
    80005e7e:	100017b7          	lui	a5,0x10001
    80005e82:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    80005e86:	4705                	li	a4,1
    80005e88:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005e8a:	470d                	li	a4,3
    80005e8c:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    80005e8e:	4b98                	lw	a4,16(a5)
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80005e90:	c7ffe6b7          	lui	a3,0xc7ffe
    80005e94:	75f68693          	addi	a3,a3,1887 # ffffffffc7ffe75f <end+0xffffffff47e6504f>
    80005e98:	8f75                	and	a4,a4,a3
    80005e9a:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005e9c:	472d                	li	a4,11
    80005e9e:	dbb8                	sw	a4,112(a5)
  status = *R(VIRTIO_MMIO_STATUS);
    80005ea0:	5bbc                	lw	a5,112(a5)
    80005ea2:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    80005ea6:	8ba1                	andi	a5,a5,8
    80005ea8:	10078563          	beqz	a5,80005fb2 <virtio_disk_init+0x19a>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80005eac:	100017b7          	lui	a5,0x10001
    80005eb0:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    80005eb4:	43fc                	lw	a5,68(a5)
    80005eb6:	2781                	sext.w	a5,a5
    80005eb8:	10079563          	bnez	a5,80005fc2 <virtio_disk_init+0x1aa>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80005ebc:	100017b7          	lui	a5,0x10001
    80005ec0:	5bdc                	lw	a5,52(a5)
    80005ec2:	2781                	sext.w	a5,a5
  if(max == 0)
    80005ec4:	10078763          	beqz	a5,80005fd2 <virtio_disk_init+0x1ba>
  if(max < NUM)
    80005ec8:	471d                	li	a4,7
    80005eca:	10f77c63          	bgeu	a4,a5,80005fe2 <virtio_disk_init+0x1ca>
  disk.desc = kalloc();
    80005ece:	ffffb097          	auipc	ra,0xffffb
    80005ed2:	c14080e7          	jalr	-1004(ra) # 80000ae2 <kalloc>
    80005ed6:	00193497          	auipc	s1,0x193
    80005eda:	31248493          	addi	s1,s1,786 # 801991e8 <disk>
    80005ede:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    80005ee0:	ffffb097          	auipc	ra,0xffffb
    80005ee4:	c02080e7          	jalr	-1022(ra) # 80000ae2 <kalloc>
    80005ee8:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    80005eea:	ffffb097          	auipc	ra,0xffffb
    80005eee:	bf8080e7          	jalr	-1032(ra) # 80000ae2 <kalloc>
    80005ef2:	87aa                	mv	a5,a0
    80005ef4:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    80005ef6:	6088                	ld	a0,0(s1)
    80005ef8:	cd6d                	beqz	a0,80005ff2 <virtio_disk_init+0x1da>
    80005efa:	00193717          	auipc	a4,0x193
    80005efe:	2f673703          	ld	a4,758(a4) # 801991f0 <disk+0x8>
    80005f02:	cb65                	beqz	a4,80005ff2 <virtio_disk_init+0x1da>
    80005f04:	c7fd                	beqz	a5,80005ff2 <virtio_disk_init+0x1da>
  memset(disk.desc, 0, PGSIZE);
    80005f06:	6605                	lui	a2,0x1
    80005f08:	4581                	li	a1,0
    80005f0a:	ffffb097          	auipc	ra,0xffffb
    80005f0e:	dc4080e7          	jalr	-572(ra) # 80000cce <memset>
  memset(disk.avail, 0, PGSIZE);
    80005f12:	00193497          	auipc	s1,0x193
    80005f16:	2d648493          	addi	s1,s1,726 # 801991e8 <disk>
    80005f1a:	6605                	lui	a2,0x1
    80005f1c:	4581                	li	a1,0
    80005f1e:	6488                	ld	a0,8(s1)
    80005f20:	ffffb097          	auipc	ra,0xffffb
    80005f24:	dae080e7          	jalr	-594(ra) # 80000cce <memset>
  memset(disk.used, 0, PGSIZE);
    80005f28:	6605                	lui	a2,0x1
    80005f2a:	4581                	li	a1,0
    80005f2c:	6888                	ld	a0,16(s1)
    80005f2e:	ffffb097          	auipc	ra,0xffffb
    80005f32:	da0080e7          	jalr	-608(ra) # 80000cce <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80005f36:	100017b7          	lui	a5,0x10001
    80005f3a:	4721                	li	a4,8
    80005f3c:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    80005f3e:	4098                	lw	a4,0(s1)
    80005f40:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    80005f44:	40d8                	lw	a4,4(s1)
    80005f46:	08e7a223          	sw	a4,132(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    80005f4a:	6498                	ld	a4,8(s1)
    80005f4c:	0007069b          	sext.w	a3,a4
    80005f50:	08d7a823          	sw	a3,144(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    80005f54:	9701                	srai	a4,a4,0x20
    80005f56:	08e7aa23          	sw	a4,148(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    80005f5a:	6898                	ld	a4,16(s1)
    80005f5c:	0007069b          	sext.w	a3,a4
    80005f60:	0ad7a023          	sw	a3,160(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    80005f64:	9701                	srai	a4,a4,0x20
    80005f66:	0ae7a223          	sw	a4,164(a5)
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    80005f6a:	4705                	li	a4,1
    80005f6c:	c3f8                	sw	a4,68(a5)
    disk.free[i] = 1;
    80005f6e:	00e48c23          	sb	a4,24(s1)
    80005f72:	00e48ca3          	sb	a4,25(s1)
    80005f76:	00e48d23          	sb	a4,26(s1)
    80005f7a:	00e48da3          	sb	a4,27(s1)
    80005f7e:	00e48e23          	sb	a4,28(s1)
    80005f82:	00e48ea3          	sb	a4,29(s1)
    80005f86:	00e48f23          	sb	a4,30(s1)
    80005f8a:	00e48fa3          	sb	a4,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    80005f8e:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    80005f92:	0727a823          	sw	s2,112(a5)
}
    80005f96:	60e2                	ld	ra,24(sp)
    80005f98:	6442                	ld	s0,16(sp)
    80005f9a:	64a2                	ld	s1,8(sp)
    80005f9c:	6902                	ld	s2,0(sp)
    80005f9e:	6105                	addi	sp,sp,32
    80005fa0:	8082                	ret
    panic("could not find virtio disk");
    80005fa2:	00003517          	auipc	a0,0x3
    80005fa6:	80650513          	addi	a0,a0,-2042 # 800087a8 <syscalls+0x330>
    80005faa:	ffffa097          	auipc	ra,0xffffa
    80005fae:	592080e7          	jalr	1426(ra) # 8000053c <panic>
    panic("virtio disk FEATURES_OK unset");
    80005fb2:	00003517          	auipc	a0,0x3
    80005fb6:	81650513          	addi	a0,a0,-2026 # 800087c8 <syscalls+0x350>
    80005fba:	ffffa097          	auipc	ra,0xffffa
    80005fbe:	582080e7          	jalr	1410(ra) # 8000053c <panic>
    panic("virtio disk should not be ready");
    80005fc2:	00003517          	auipc	a0,0x3
    80005fc6:	82650513          	addi	a0,a0,-2010 # 800087e8 <syscalls+0x370>
    80005fca:	ffffa097          	auipc	ra,0xffffa
    80005fce:	572080e7          	jalr	1394(ra) # 8000053c <panic>
    panic("virtio disk has no queue 0");
    80005fd2:	00003517          	auipc	a0,0x3
    80005fd6:	83650513          	addi	a0,a0,-1994 # 80008808 <syscalls+0x390>
    80005fda:	ffffa097          	auipc	ra,0xffffa
    80005fde:	562080e7          	jalr	1378(ra) # 8000053c <panic>
    panic("virtio disk max queue too short");
    80005fe2:	00003517          	auipc	a0,0x3
    80005fe6:	84650513          	addi	a0,a0,-1978 # 80008828 <syscalls+0x3b0>
    80005fea:	ffffa097          	auipc	ra,0xffffa
    80005fee:	552080e7          	jalr	1362(ra) # 8000053c <panic>
    panic("virtio disk kalloc");
    80005ff2:	00003517          	auipc	a0,0x3
    80005ff6:	85650513          	addi	a0,a0,-1962 # 80008848 <syscalls+0x3d0>
    80005ffa:	ffffa097          	auipc	ra,0xffffa
    80005ffe:	542080e7          	jalr	1346(ra) # 8000053c <panic>

0000000080006002 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80006002:	7159                	addi	sp,sp,-112
    80006004:	f486                	sd	ra,104(sp)
    80006006:	f0a2                	sd	s0,96(sp)
    80006008:	eca6                	sd	s1,88(sp)
    8000600a:	e8ca                	sd	s2,80(sp)
    8000600c:	e4ce                	sd	s3,72(sp)
    8000600e:	e0d2                	sd	s4,64(sp)
    80006010:	fc56                	sd	s5,56(sp)
    80006012:	f85a                	sd	s6,48(sp)
    80006014:	f45e                	sd	s7,40(sp)
    80006016:	f062                	sd	s8,32(sp)
    80006018:	ec66                	sd	s9,24(sp)
    8000601a:	e86a                	sd	s10,16(sp)
    8000601c:	1880                	addi	s0,sp,112
    8000601e:	8a2a                	mv	s4,a0
    80006020:	8bae                	mv	s7,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80006022:	00c52c83          	lw	s9,12(a0)
    80006026:	001c9c9b          	slliw	s9,s9,0x1
    8000602a:	1c82                	slli	s9,s9,0x20
    8000602c:	020cdc93          	srli	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    80006030:	00193517          	auipc	a0,0x193
    80006034:	2e050513          	addi	a0,a0,736 # 80199310 <disk+0x128>
    80006038:	ffffb097          	auipc	ra,0xffffb
    8000603c:	b9a080e7          	jalr	-1126(ra) # 80000bd2 <acquire>
  for(int i = 0; i < 3; i++){
    80006040:	4901                	li	s2,0
  for(int i = 0; i < NUM; i++){
    80006042:	44a1                	li	s1,8
      disk.free[i] = 0;
    80006044:	00193b17          	auipc	s6,0x193
    80006048:	1a4b0b13          	addi	s6,s6,420 # 801991e8 <disk>
  for(int i = 0; i < 3; i++){
    8000604c:	4a8d                	li	s5,3
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    8000604e:	00193c17          	auipc	s8,0x193
    80006052:	2c2c0c13          	addi	s8,s8,706 # 80199310 <disk+0x128>
    80006056:	a095                	j	800060ba <virtio_disk_rw+0xb8>
      disk.free[i] = 0;
    80006058:	00fb0733          	add	a4,s6,a5
    8000605c:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    80006060:	c11c                	sw	a5,0(a0)
    if(idx[i] < 0){
    80006062:	0207c563          	bltz	a5,8000608c <virtio_disk_rw+0x8a>
  for(int i = 0; i < 3; i++){
    80006066:	2605                	addiw	a2,a2,1 # 1001 <_entry-0x7fffefff>
    80006068:	0591                	addi	a1,a1,4
    8000606a:	05560d63          	beq	a2,s5,800060c4 <virtio_disk_rw+0xc2>
    idx[i] = alloc_desc();
    8000606e:	852e                	mv	a0,a1
  for(int i = 0; i < NUM; i++){
    80006070:	00193717          	auipc	a4,0x193
    80006074:	17870713          	addi	a4,a4,376 # 801991e8 <disk>
    80006078:	87ca                	mv	a5,s2
    if(disk.free[i]){
    8000607a:	01874683          	lbu	a3,24(a4)
    8000607e:	fee9                	bnez	a3,80006058 <virtio_disk_rw+0x56>
  for(int i = 0; i < NUM; i++){
    80006080:	2785                	addiw	a5,a5,1
    80006082:	0705                	addi	a4,a4,1
    80006084:	fe979be3          	bne	a5,s1,8000607a <virtio_disk_rw+0x78>
    idx[i] = alloc_desc();
    80006088:	57fd                	li	a5,-1
    8000608a:	c11c                	sw	a5,0(a0)
      for(int j = 0; j < i; j++)
    8000608c:	00c05e63          	blez	a2,800060a8 <virtio_disk_rw+0xa6>
    80006090:	060a                	slli	a2,a2,0x2
    80006092:	01360d33          	add	s10,a2,s3
        free_desc(idx[j]);
    80006096:	0009a503          	lw	a0,0(s3)
    8000609a:	00000097          	auipc	ra,0x0
    8000609e:	cfc080e7          	jalr	-772(ra) # 80005d96 <free_desc>
      for(int j = 0; j < i; j++)
    800060a2:	0991                	addi	s3,s3,4
    800060a4:	ffa999e3          	bne	s3,s10,80006096 <virtio_disk_rw+0x94>
    sleep(&disk.free[0], &disk.vdisk_lock);
    800060a8:	85e2                	mv	a1,s8
    800060aa:	00193517          	auipc	a0,0x193
    800060ae:	15650513          	addi	a0,a0,342 # 80199200 <disk+0x18>
    800060b2:	ffffc097          	auipc	ra,0xffffc
    800060b6:	07e080e7          	jalr	126(ra) # 80002130 <sleep>
  for(int i = 0; i < 3; i++){
    800060ba:	f9040993          	addi	s3,s0,-112
{
    800060be:	85ce                	mv	a1,s3
  for(int i = 0; i < 3; i++){
    800060c0:	864a                	mv	a2,s2
    800060c2:	b775                	j	8000606e <virtio_disk_rw+0x6c>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    800060c4:	f9042503          	lw	a0,-112(s0)
    800060c8:	00a50713          	addi	a4,a0,10
    800060cc:	0712                	slli	a4,a4,0x4

  if(write)
    800060ce:	00193797          	auipc	a5,0x193
    800060d2:	11a78793          	addi	a5,a5,282 # 801991e8 <disk>
    800060d6:	00e786b3          	add	a3,a5,a4
    800060da:	01703633          	snez	a2,s7
    800060de:	c690                	sw	a2,8(a3)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    800060e0:	0006a623          	sw	zero,12(a3)
  buf0->sector = sector;
    800060e4:	0196b823          	sd	s9,16(a3)

  disk.desc[idx[0]].addr = (uint64) buf0;
    800060e8:	f6070613          	addi	a2,a4,-160
    800060ec:	6394                	ld	a3,0(a5)
    800060ee:	96b2                	add	a3,a3,a2
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    800060f0:	00870593          	addi	a1,a4,8
    800060f4:	95be                	add	a1,a1,a5
  disk.desc[idx[0]].addr = (uint64) buf0;
    800060f6:	e28c                	sd	a1,0(a3)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    800060f8:	0007b803          	ld	a6,0(a5)
    800060fc:	9642                	add	a2,a2,a6
    800060fe:	46c1                	li	a3,16
    80006100:	c614                	sw	a3,8(a2)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80006102:	4585                	li	a1,1
    80006104:	00b61623          	sh	a1,12(a2)
  disk.desc[idx[0]].next = idx[1];
    80006108:	f9442683          	lw	a3,-108(s0)
    8000610c:	00d61723          	sh	a3,14(a2)

  disk.desc[idx[1]].addr = (uint64) b->data;
    80006110:	0692                	slli	a3,a3,0x4
    80006112:	9836                	add	a6,a6,a3
    80006114:	058a0613          	addi	a2,s4,88
    80006118:	00c83023          	sd	a2,0(a6) # 1000 <_entry-0x7ffff000>
  disk.desc[idx[1]].len = BSIZE;
    8000611c:	0007b803          	ld	a6,0(a5)
    80006120:	96c2                	add	a3,a3,a6
    80006122:	40000613          	li	a2,1024
    80006126:	c690                	sw	a2,8(a3)
  if(write)
    80006128:	001bb613          	seqz	a2,s7
    8000612c:	0016161b          	slliw	a2,a2,0x1
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    80006130:	00166613          	ori	a2,a2,1
    80006134:	00c69623          	sh	a2,12(a3)
  disk.desc[idx[1]].next = idx[2];
    80006138:	f9842603          	lw	a2,-104(s0)
    8000613c:	00c69723          	sh	a2,14(a3)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    80006140:	00250693          	addi	a3,a0,2
    80006144:	0692                	slli	a3,a3,0x4
    80006146:	96be                	add	a3,a3,a5
    80006148:	58fd                	li	a7,-1
    8000614a:	01168823          	sb	a7,16(a3)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    8000614e:	0612                	slli	a2,a2,0x4
    80006150:	9832                	add	a6,a6,a2
    80006152:	f9070713          	addi	a4,a4,-112
    80006156:	973e                	add	a4,a4,a5
    80006158:	00e83023          	sd	a4,0(a6)
  disk.desc[idx[2]].len = 1;
    8000615c:	6398                	ld	a4,0(a5)
    8000615e:	9732                	add	a4,a4,a2
    80006160:	c70c                	sw	a1,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80006162:	4609                	li	a2,2
    80006164:	00c71623          	sh	a2,12(a4)
  disk.desc[idx[2]].next = 0;
    80006168:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    8000616c:	00ba2223          	sw	a1,4(s4)
  disk.info[idx[0]].b = b;
    80006170:	0146b423          	sd	s4,8(a3)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80006174:	6794                	ld	a3,8(a5)
    80006176:	0026d703          	lhu	a4,2(a3)
    8000617a:	8b1d                	andi	a4,a4,7
    8000617c:	0706                	slli	a4,a4,0x1
    8000617e:	96ba                	add	a3,a3,a4
    80006180:	00a69223          	sh	a0,4(a3)

  __sync_synchronize();
    80006184:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80006188:	6798                	ld	a4,8(a5)
    8000618a:	00275783          	lhu	a5,2(a4)
    8000618e:	2785                	addiw	a5,a5,1
    80006190:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80006194:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80006198:	100017b7          	lui	a5,0x10001
    8000619c:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    800061a0:	004a2783          	lw	a5,4(s4)
    sleep(b, &disk.vdisk_lock);
    800061a4:	00193917          	auipc	s2,0x193
    800061a8:	16c90913          	addi	s2,s2,364 # 80199310 <disk+0x128>
  while(b->disk == 1) {
    800061ac:	4485                	li	s1,1
    800061ae:	00b79c63          	bne	a5,a1,800061c6 <virtio_disk_rw+0x1c4>
    sleep(b, &disk.vdisk_lock);
    800061b2:	85ca                	mv	a1,s2
    800061b4:	8552                	mv	a0,s4
    800061b6:	ffffc097          	auipc	ra,0xffffc
    800061ba:	f7a080e7          	jalr	-134(ra) # 80002130 <sleep>
  while(b->disk == 1) {
    800061be:	004a2783          	lw	a5,4(s4)
    800061c2:	fe9788e3          	beq	a5,s1,800061b2 <virtio_disk_rw+0x1b0>
  }

  disk.info[idx[0]].b = 0;
    800061c6:	f9042903          	lw	s2,-112(s0)
    800061ca:	00290713          	addi	a4,s2,2
    800061ce:	0712                	slli	a4,a4,0x4
    800061d0:	00193797          	auipc	a5,0x193
    800061d4:	01878793          	addi	a5,a5,24 # 801991e8 <disk>
    800061d8:	97ba                	add	a5,a5,a4
    800061da:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    800061de:	00193997          	auipc	s3,0x193
    800061e2:	00a98993          	addi	s3,s3,10 # 801991e8 <disk>
    800061e6:	00491713          	slli	a4,s2,0x4
    800061ea:	0009b783          	ld	a5,0(s3)
    800061ee:	97ba                	add	a5,a5,a4
    800061f0:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    800061f4:	854a                	mv	a0,s2
    800061f6:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    800061fa:	00000097          	auipc	ra,0x0
    800061fe:	b9c080e7          	jalr	-1124(ra) # 80005d96 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    80006202:	8885                	andi	s1,s1,1
    80006204:	f0ed                	bnez	s1,800061e6 <virtio_disk_rw+0x1e4>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    80006206:	00193517          	auipc	a0,0x193
    8000620a:	10a50513          	addi	a0,a0,266 # 80199310 <disk+0x128>
    8000620e:	ffffb097          	auipc	ra,0xffffb
    80006212:	a78080e7          	jalr	-1416(ra) # 80000c86 <release>
}
    80006216:	70a6                	ld	ra,104(sp)
    80006218:	7406                	ld	s0,96(sp)
    8000621a:	64e6                	ld	s1,88(sp)
    8000621c:	6946                	ld	s2,80(sp)
    8000621e:	69a6                	ld	s3,72(sp)
    80006220:	6a06                	ld	s4,64(sp)
    80006222:	7ae2                	ld	s5,56(sp)
    80006224:	7b42                	ld	s6,48(sp)
    80006226:	7ba2                	ld	s7,40(sp)
    80006228:	7c02                	ld	s8,32(sp)
    8000622a:	6ce2                	ld	s9,24(sp)
    8000622c:	6d42                	ld	s10,16(sp)
    8000622e:	6165                	addi	sp,sp,112
    80006230:	8082                	ret

0000000080006232 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80006232:	1101                	addi	sp,sp,-32
    80006234:	ec06                	sd	ra,24(sp)
    80006236:	e822                	sd	s0,16(sp)
    80006238:	e426                	sd	s1,8(sp)
    8000623a:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    8000623c:	00193497          	auipc	s1,0x193
    80006240:	fac48493          	addi	s1,s1,-84 # 801991e8 <disk>
    80006244:	00193517          	auipc	a0,0x193
    80006248:	0cc50513          	addi	a0,a0,204 # 80199310 <disk+0x128>
    8000624c:	ffffb097          	auipc	ra,0xffffb
    80006250:	986080e7          	jalr	-1658(ra) # 80000bd2 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80006254:	10001737          	lui	a4,0x10001
    80006258:	533c                	lw	a5,96(a4)
    8000625a:	8b8d                	andi	a5,a5,3
    8000625c:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    8000625e:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    80006262:	689c                	ld	a5,16(s1)
    80006264:	0204d703          	lhu	a4,32(s1)
    80006268:	0027d783          	lhu	a5,2(a5)
    8000626c:	04f70863          	beq	a4,a5,800062bc <virtio_disk_intr+0x8a>
    __sync_synchronize();
    80006270:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80006274:	6898                	ld	a4,16(s1)
    80006276:	0204d783          	lhu	a5,32(s1)
    8000627a:	8b9d                	andi	a5,a5,7
    8000627c:	078e                	slli	a5,a5,0x3
    8000627e:	97ba                	add	a5,a5,a4
    80006280:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    80006282:	00278713          	addi	a4,a5,2
    80006286:	0712                	slli	a4,a4,0x4
    80006288:	9726                	add	a4,a4,s1
    8000628a:	01074703          	lbu	a4,16(a4) # 10001010 <_entry-0x6fffeff0>
    8000628e:	e721                	bnez	a4,800062d6 <virtio_disk_intr+0xa4>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80006290:	0789                	addi	a5,a5,2
    80006292:	0792                	slli	a5,a5,0x4
    80006294:	97a6                	add	a5,a5,s1
    80006296:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    80006298:	00052223          	sw	zero,4(a0)
    wakeup(b);
    8000629c:	ffffc097          	auipc	ra,0xffffc
    800062a0:	ef8080e7          	jalr	-264(ra) # 80002194 <wakeup>

    disk.used_idx += 1;
    800062a4:	0204d783          	lhu	a5,32(s1)
    800062a8:	2785                	addiw	a5,a5,1
    800062aa:	17c2                	slli	a5,a5,0x30
    800062ac:	93c1                	srli	a5,a5,0x30
    800062ae:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    800062b2:	6898                	ld	a4,16(s1)
    800062b4:	00275703          	lhu	a4,2(a4)
    800062b8:	faf71ce3          	bne	a4,a5,80006270 <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    800062bc:	00193517          	auipc	a0,0x193
    800062c0:	05450513          	addi	a0,a0,84 # 80199310 <disk+0x128>
    800062c4:	ffffb097          	auipc	ra,0xffffb
    800062c8:	9c2080e7          	jalr	-1598(ra) # 80000c86 <release>
}
    800062cc:	60e2                	ld	ra,24(sp)
    800062ce:	6442                	ld	s0,16(sp)
    800062d0:	64a2                	ld	s1,8(sp)
    800062d2:	6105                	addi	sp,sp,32
    800062d4:	8082                	ret
      panic("virtio_disk_intr status");
    800062d6:	00002517          	auipc	a0,0x2
    800062da:	58a50513          	addi	a0,a0,1418 # 80008860 <syscalls+0x3e8>
    800062de:	ffffa097          	auipc	ra,0xffffa
    800062e2:	25e080e7          	jalr	606(ra) # 8000053c <panic>

00000000800062e6 <read_current_timestamp>:

int loadseg(pagetable_t pagetable, uint64 va, struct inode *ip, uint offset, uint sz);
int flags2perm(int flags);

/* CSE 536: (2.4) read current time. */
uint64 read_current_timestamp() {
    800062e6:	1101                	addi	sp,sp,-32
    800062e8:	ec06                	sd	ra,24(sp)
    800062ea:	e822                	sd	s0,16(sp)
    800062ec:	e426                	sd	s1,8(sp)
    800062ee:	1000                	addi	s0,sp,32
  uint64 curticks = 0;
  acquire(&tickslock);
    800062f0:	00188517          	auipc	a0,0x188
    800062f4:	c5050513          	addi	a0,a0,-944 # 8018df40 <tickslock>
    800062f8:	ffffb097          	auipc	ra,0xffffb
    800062fc:	8da080e7          	jalr	-1830(ra) # 80000bd2 <acquire>
  curticks = ticks;
    80006300:	00002517          	auipc	a0,0x2
    80006304:	7a050513          	addi	a0,a0,1952 # 80008aa0 <ticks>
    80006308:	00056483          	lwu	s1,0(a0)
  wakeup(&ticks);
    8000630c:	ffffc097          	auipc	ra,0xffffc
    80006310:	e88080e7          	jalr	-376(ra) # 80002194 <wakeup>
  release(&tickslock);
    80006314:	00188517          	auipc	a0,0x188
    80006318:	c2c50513          	addi	a0,a0,-980 # 8018df40 <tickslock>
    8000631c:	ffffb097          	auipc	ra,0xffffb
    80006320:	96a080e7          	jalr	-1686(ra) # 80000c86 <release>
  return curticks;
}
    80006324:	8526                	mv	a0,s1
    80006326:	60e2                	ld	ra,24(sp)
    80006328:	6442                	ld	s0,16(sp)
    8000632a:	64a2                	ld	s1,8(sp)
    8000632c:	6105                	addi	sp,sp,32
    8000632e:	8082                	ret

0000000080006330 <init_psa_regions>:

bool psa_tracker[PSASIZE];

/* All blocks are free during initialization. */
void init_psa_regions(void)
{
    80006330:	1141                	addi	sp,sp,-16
    80006332:	e422                	sd	s0,8(sp)
    80006334:	0800                	addi	s0,sp,16
    for (int i = 0; i < PSASIZE; i++) 
    80006336:	00193797          	auipc	a5,0x193
    8000633a:	ff278793          	addi	a5,a5,-14 # 80199328 <psa_tracker>
    8000633e:	00193717          	auipc	a4,0x193
    80006342:	3d270713          	addi	a4,a4,978 # 80199710 <end>
        psa_tracker[i] = false;
    80006346:	00078023          	sb	zero,0(a5)
    for (int i = 0; i < PSASIZE; i++) 
    8000634a:	0785                	addi	a5,a5,1
    8000634c:	fee79de3          	bne	a5,a4,80006346 <init_psa_regions+0x16>
}
    80006350:	6422                	ld	s0,8(sp)
    80006352:	0141                	addi	sp,sp,16
    80006354:	8082                	ret

0000000080006356 <evict_page_to_disk>:

/* Evict heap page to disk when resident pages exceed limit */
void evict_page_to_disk(struct proc* p) {
    80006356:	1101                	addi	sp,sp,-32
    80006358:	ec06                	sd	ra,24(sp)
    8000635a:	e822                	sd	s0,16(sp)
    8000635c:	e426                	sd	s1,8(sp)
    8000635e:	1000                	addi	s0,sp,32
    /* Find free block */
    int blockno = 0;
    /* Find victim page using FIFO. */
    /* Print statement. */
    print_evict_page(0, 0);
    80006360:	4581                	li	a1,0
    80006362:	4501                	li	a0,0
    80006364:	00000097          	auipc	ra,0x0
    80006368:	32c080e7          	jalr	812(ra) # 80006690 <print_evict_page>
    /* Read memory from the user to kernel memory first. */
    
    /* Write to the disk blocks. Below is a template as to how this works. There is
     * definitely a better way but this works for now. :p */
    struct buf* b;
    b = bread(1, PSASTART+(blockno));
    8000636c:	02100593          	li	a1,33
    80006370:	4505                	li	a0,1
    80006372:	ffffd097          	auipc	ra,0xffffd
    80006376:	bc6080e7          	jalr	-1082(ra) # 80002f38 <bread>
    8000637a:	84aa                	mv	s1,a0
        // Copy page contents to b.data using memmove.
    bwrite(b);
    8000637c:	ffffd097          	auipc	ra,0xffffd
    80006380:	cae080e7          	jalr	-850(ra) # 8000302a <bwrite>
    brelse(b);
    80006384:	8526                	mv	a0,s1
    80006386:	ffffd097          	auipc	ra,0xffffd
    8000638a:	ce2080e7          	jalr	-798(ra) # 80003068 <brelse>

    /* Unmap swapped out page */
    /* Update the resident heap tracker. */
}
    8000638e:	60e2                	ld	ra,24(sp)
    80006390:	6442                	ld	s0,16(sp)
    80006392:	64a2                	ld	s1,8(sp)
    80006394:	6105                	addi	sp,sp,32
    80006396:	8082                	ret

0000000080006398 <retrieve_page_from_disk>:

/* Retrieve faulted page from disk. */
void retrieve_page_from_disk(struct proc* p, uint64 uvaddr) {
    80006398:	1141                	addi	sp,sp,-16
    8000639a:	e406                	sd	ra,8(sp)
    8000639c:	e022                	sd	s0,0(sp)
    8000639e:	0800                	addi	s0,sp,16
    /* Find where the page is located in disk */

    /* Print statement. */
    print_retrieve_page(0, 0);
    800063a0:	4581                	li	a1,0
    800063a2:	4501                	li	a0,0
    800063a4:	00000097          	auipc	ra,0x0
    800063a8:	314080e7          	jalr	788(ra) # 800066b8 <print_retrieve_page>
    /* Create a kernel page to read memory temporarily into first. */
    
    /* Read the disk block into temp kernel page. */

    /* Copy from temp kernel page to uvaddr (use copyout) */
}
    800063ac:	60a2                	ld	ra,8(sp)
    800063ae:	6402                	ld	s0,0(sp)
    800063b0:	0141                	addi	sp,sp,16
    800063b2:	8082                	ret

00000000800063b4 <page_fault_handler>:


void page_fault_handler(void) 
{
    800063b4:	7115                	addi	sp,sp,-224
    800063b6:	ed86                	sd	ra,216(sp)
    800063b8:	e9a2                	sd	s0,208(sp)
    800063ba:	e5a6                	sd	s1,200(sp)
    800063bc:	e1ca                	sd	s2,192(sp)
    800063be:	fd4e                	sd	s3,184(sp)
    800063c0:	f952                	sd	s4,176(sp)
    800063c2:	f556                	sd	s5,168(sp)
    800063c4:	f15a                	sd	s6,160(sp)
    800063c6:	ed5e                	sd	s7,152(sp)
    800063c8:	e962                	sd	s8,144(sp)
    800063ca:	e566                	sd	s9,136(sp)
    800063cc:	1180                	addi	s0,sp,224
    /* Current process struct */
    struct proc *p = myproc();
    800063ce:	ffffb097          	auipc	ra,0xffffb
    800063d2:	614080e7          	jalr	1556(ra) # 800019e2 <myproc>
    800063d6:	89aa                	mv	s3,a0
    800063d8:	14302973          	csrr	s2,stval
    // }

    uint64 faulting_addr = r_stval();
    // printf("r_stval : %d\n",faulting_addr);
    faulting_addr = faulting_addr>>PGSHIFT;
    faulting_addr = faulting_addr<<PGSHIFT;
    800063dc:	77fd                	lui	a5,0xfffff
    800063de:	00f97933          	and	s2,s2,a5
    print_page_fault(p->name, faulting_addr);
    800063e2:	15850a93          	addi	s5,a0,344
    800063e6:	85ca                	mv	a1,s2
    800063e8:	8556                	mv	a0,s5
    800063ea:	00000097          	auipc	ra,0x0
    800063ee:	266080e7          	jalr	614(ra) # 80006650 <print_page_fault>
    uint64 sz = 0;
    uint64 index = 0;

    // pagetable_t pagetable = 0, oldpagetable;
    /* Check if the fault address is a heap page. Use p->heap_tracker */
    for(index = 0; index < MAXHEAP; index ++){
    800063f2:	17098793          	addi	a5,s3,368
    800063f6:	4481                	li	s1,0
    800063f8:	3e800693          	li	a3,1000
        if (p->heap_tracker[index].addr==faulting_addr) {
    800063fc:	6398                	ld	a4,0(a5)
    800063fe:	07270663          	beq	a4,s2,8000646a <page_fault_handler+0xb6>
    for(index = 0; index < MAXHEAP; index ++){
    80006402:	0485                	addi	s1,s1,1
    80006404:	07e1                	addi	a5,a5,24 # fffffffffffff018 <end+0xffffffff7fe65908>
    80006406:	fed49be3          	bne	s1,a3,800063fc <page_fault_handler+0x48>
    }
    
    /* If it came here, it is a page from the program binary that we must load. */
    // print_load_seg(faulting_addr, 0, 0);
    // print_load_seg(faulting_addr,off,sz);
    begin_op();
    8000640a:	ffffe097          	auipc	ra,0xffffe
    8000640e:	ce4080e7          	jalr	-796(ra) # 800040ee <begin_op>
    if((ip = namei(p->name)) == 0){
    80006412:	8556                	mv	a0,s5
    80006414:	ffffe097          	auipc	ra,0xffffe
    80006418:	ada080e7          	jalr	-1318(ra) # 80003eee <namei>
    8000641c:	8a2a                	mv	s4,a0
    8000641e:	cd4d                	beqz	a0,800064d8 <page_fault_handler+0x124>
        end_op();
        return;
    }
    ilock(ip);
    80006420:	ffffd097          	auipc	ra,0xffffd
    80006424:	328080e7          	jalr	808(ra) # 80003748 <ilock>

    if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80006428:	04000713          	li	a4,64
    8000642c:	4681                	li	a3,0
    8000642e:	f6040613          	addi	a2,s0,-160
    80006432:	4581                	li	a1,0
    80006434:	8552                	mv	a0,s4
    80006436:	ffffd097          	auipc	ra,0xffffd
    8000643a:	5c6080e7          	jalr	1478(ra) # 800039fc <readi>
    8000643e:	04000793          	li	a5,64
    80006442:	14f51f63          	bne	a0,a5,800065a0 <page_fault_handler+0x1ec>
        goto bad;

    if(elf.magic != ELF_MAGIC)
    80006446:	f6042703          	lw	a4,-160(s0)
    8000644a:	464c47b7          	lui	a5,0x464c4
    8000644e:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80006452:	14f71763          	bne	a4,a5,800065a0 <page_fault_handler+0x1ec>
        goto bad;
    // if((pagetable = proc_pagetable(p)) == 0)
    //     goto bad;
    //Load program into memory.
    for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80006456:	f8042483          	lw	s1,-128(s0)
    8000645a:	f9845783          	lhu	a5,-104(s0)
    8000645e:	cbd5                	beqz	a5,80006512 <page_fault_handler+0x15e>
    80006460:	4a81                	li	s5,0
        if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
            goto bad;
        if(ph.type != ELF_PROG_LOAD)
    80006462:	4b85                	li	s7,1
            continue;
        if(ph.memsz < ph.filesz)
            goto bad;
        if(ph.vaddr + ph.memsz < ph.vaddr)
            goto bad;
        if(ph.vaddr % PGSIZE != 0)
    80006464:	6c05                	lui	s8,0x1
    80006466:	1c7d                	addi	s8,s8,-1 # fff <_entry-0x7ffff001>
    80006468:	a0f1                	j	80006534 <page_fault_handler+0x180>
    /* Go to out, since the remainder of this code is for the heap. */
    goto out;
    
    heap_handle:
        /* 2.4: Check if resident pages are more than heap pages. If yes, evict. */
        if (p->resident_heap_pages == MAXRESHEAP) {
    8000646a:	6799                	lui	a5,0x6
    8000646c:	97ce                	add	a5,a5,s3
    8000646e:	f307a703          	lw	a4,-208(a5) # 5f30 <_entry-0x7fffa0d0>
    80006472:	06400793          	li	a5,100
    80006476:	12f70a63          	beq	a4,a5,800065aa <page_fault_handler+0x1f6>
            evict_page_to_disk(p);
        }

        /* 2.3: Map a heap page into the process' address space. (Hint: check growproc) */
        if((sz = uvmalloc(p->pagetable, faulting_addr, faulting_addr+PGSIZE, PTE_W)) == 0) {
    8000647a:	4691                	li	a3,4
    8000647c:	6605                	lui	a2,0x1
    8000647e:	964a                	add	a2,a2,s2
    80006480:	85ca                	mv	a1,s2
    80006482:	0509b503          	ld	a0,80(s3)
    80006486:	ffffb097          	auipc	ra,0xffffb
    8000648a:	f7e080e7          	jalr	-130(ra) # 80001404 <uvmalloc>
    8000648e:	12051463          	bnez	a0,800065b6 <page_fault_handler+0x202>

        /* Track that another heap page has been brought into memory. */
        p->resident_heap_pages++;
        goto out;
    bad:
        if(p->pagetable){
    80006492:	0509b503          	ld	a0,80(s3)
    80006496:	c519                	beqz	a0,800064a4 <page_fault_handler+0xf0>
            proc_freepagetable(p->pagetable, p->sz);
    80006498:	0489b583          	ld	a1,72(s3)
    8000649c:	ffffb097          	auipc	ra,0xffffb
    800064a0:	6a6080e7          	jalr	1702(ra) # 80001b42 <proc_freepagetable>
        }
        if(ip){
    800064a4:	000a0b63          	beqz	s4,800064ba <page_fault_handler+0x106>
            iunlockput(ip);
    800064a8:	8552                	mv	a0,s4
    800064aa:	ffffd097          	auipc	ra,0xffffd
    800064ae:	500080e7          	jalr	1280(ra) # 800039aa <iunlockput>
            end_op();
    800064b2:	ffffe097          	auipc	ra,0xffffe
    800064b6:	cb6080e7          	jalr	-842(ra) # 80004168 <end_op>
  asm volatile("sfence.vma zero, zero");
    800064ba:	12000073          	sfence.vma
        sfence_vma();
        return;
    
        

    800064be:	60ee                	ld	ra,216(sp)
    800064c0:	644e                	ld	s0,208(sp)
    800064c2:	64ae                	ld	s1,200(sp)
    800064c4:	690e                	ld	s2,192(sp)
    800064c6:	79ea                	ld	s3,184(sp)
    800064c8:	7a4a                	ld	s4,176(sp)
    800064ca:	7aaa                	ld	s5,168(sp)
    800064cc:	7b0a                	ld	s6,160(sp)
    800064ce:	6bea                	ld	s7,152(sp)
    800064d0:	6c4a                	ld	s8,144(sp)
    800064d2:	6caa                	ld	s9,136(sp)
    800064d4:	612d                	addi	sp,sp,224
    800064d6:	8082                	ret
        end_op();
    800064d8:	ffffe097          	auipc	ra,0xffffe
    800064dc:	c90080e7          	jalr	-880(ra) # 80004168 <end_op>
        return;
    800064e0:	bff9                	j	800064be <page_fault_handler+0x10a>
            if(loadseg(p->pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    800064e2:	f4842703          	lw	a4,-184(s0)
    800064e6:	f3042683          	lw	a3,-208(s0)
    800064ea:	8652                	mv	a2,s4
    800064ec:	f3843583          	ld	a1,-200(s0)
    800064f0:	0509b503          	ld	a0,80(s3)
    800064f4:	ffffe097          	auipc	ra,0xffffe
    800064f8:	734080e7          	jalr	1844(ra) # 80004c28 <loadseg>
    800064fc:	0a054263          	bltz	a0,800065a0 <page_fault_handler+0x1ec>
            print_load_seg(faulting_addr,ph.off,ph.memsz);
    80006500:	f5042603          	lw	a2,-176(s0)
    80006504:	f3043583          	ld	a1,-208(s0)
    80006508:	854a                	mv	a0,s2
    8000650a:	00000097          	auipc	ra,0x0
    8000650e:	1d6080e7          	jalr	470(ra) # 800066e0 <print_load_seg>
    iunlockput(ip);
    80006512:	8552                	mv	a0,s4
    80006514:	ffffd097          	auipc	ra,0xffffd
    80006518:	496080e7          	jalr	1174(ra) # 800039aa <iunlockput>
    end_op();
    8000651c:	ffffe097          	auipc	ra,0xffffe
    80006520:	c4c080e7          	jalr	-948(ra) # 80004168 <end_op>
    goto out;
    80006524:	bf59                	j	800064ba <page_fault_handler+0x106>
    for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80006526:	2a85                	addiw	s5,s5,1
    80006528:	0384849b          	addiw	s1,s1,56
    8000652c:	f9845783          	lhu	a5,-104(s0)
    80006530:	fefad1e3          	bge	s5,a5,80006512 <page_fault_handler+0x15e>
        if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80006534:	2481                	sext.w	s1,s1
    80006536:	03800713          	li	a4,56
    8000653a:	86a6                	mv	a3,s1
    8000653c:	f2840613          	addi	a2,s0,-216
    80006540:	4581                	li	a1,0
    80006542:	8552                	mv	a0,s4
    80006544:	ffffd097          	auipc	ra,0xffffd
    80006548:	4b8080e7          	jalr	1208(ra) # 800039fc <readi>
    8000654c:	03800793          	li	a5,56
    80006550:	08f51663          	bne	a0,a5,800065dc <page_fault_handler+0x228>
        if(ph.type != ELF_PROG_LOAD)
    80006554:	f2842783          	lw	a5,-216(s0)
    80006558:	fd7797e3          	bne	a5,s7,80006526 <page_fault_handler+0x172>
        if(ph.memsz < ph.filesz)
    8000655c:	f5043783          	ld	a5,-176(s0)
    80006560:	f4843703          	ld	a4,-184(s0)
    80006564:	06e7ec63          	bltu	a5,a4,800065dc <page_fault_handler+0x228>
        if(ph.vaddr + ph.memsz < ph.vaddr)
    80006568:	f3843b03          	ld	s6,-200(s0)
    8000656c:	01678cb3          	add	s9,a5,s6
    80006570:	076ce663          	bltu	s9,s6,800065dc <page_fault_handler+0x228>
        if(ph.vaddr % PGSIZE != 0)
    80006574:	018b77b3          	and	a5,s6,s8
    80006578:	e3b5                	bnez	a5,800065dc <page_fault_handler+0x228>
        if(ph.vaddr==faulting_addr){
    8000657a:	fb2b16e3          	bne	s6,s2,80006526 <page_fault_handler+0x172>
            if((sz1 = uvmalloc(p->pagetable, ph.vaddr, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    8000657e:	0509b483          	ld	s1,80(s3)
    80006582:	f2c42503          	lw	a0,-212(s0)
    80006586:	ffffe097          	auipc	ra,0xffffe
    8000658a:	688080e7          	jalr	1672(ra) # 80004c0e <flags2perm>
    8000658e:	86aa                	mv	a3,a0
    80006590:	8666                	mv	a2,s9
    80006592:	85da                	mv	a1,s6
    80006594:	8526                	mv	a0,s1
    80006596:	ffffb097          	auipc	ra,0xffffb
    8000659a:	e6e080e7          	jalr	-402(ra) # 80001404 <uvmalloc>
    8000659e:	f131                	bnez	a0,800064e2 <page_fault_handler+0x12e>
        if(p->pagetable){
    800065a0:	0509b503          	ld	a0,80(s3)
    800065a4:	ee051ae3          	bnez	a0,80006498 <page_fault_handler+0xe4>
    800065a8:	b701                	j	800064a8 <page_fault_handler+0xf4>
            evict_page_to_disk(p);
    800065aa:	854e                	mv	a0,s3
    800065ac:	00000097          	auipc	ra,0x0
    800065b0:	daa080e7          	jalr	-598(ra) # 80006356 <evict_page_to_disk>
    800065b4:	b5d9                	j	8000647a <page_fault_handler+0xc6>
        p->heap_tracker[index].last_load_time = read_current_timestamp();
    800065b6:	00000097          	auipc	ra,0x0
    800065ba:	d30080e7          	jalr	-720(ra) # 800062e6 <read_current_timestamp>
    800065be:	00149793          	slli	a5,s1,0x1
    800065c2:	97a6                	add	a5,a5,s1
    800065c4:	078e                	slli	a5,a5,0x3
    800065c6:	97ce                	add	a5,a5,s3
    800065c8:	16a7bc23          	sd	a0,376(a5)
        p->resident_heap_pages++;
    800065cc:	6799                	lui	a5,0x6
    800065ce:	97ce                	add	a5,a5,s3
    800065d0:	f307a703          	lw	a4,-208(a5) # 5f30 <_entry-0x7fffa0d0>
    800065d4:	2705                	addiw	a4,a4,1
    800065d6:	f2e7a823          	sw	a4,-208(a5)
        goto out;
    800065da:	b5c5                	j	800064ba <page_fault_handler+0x106>
        if(p->pagetable){
    800065dc:	0509b503          	ld	a0,80(s3)
    800065e0:	ea051ce3          	bnez	a0,80006498 <page_fault_handler+0xe4>
    800065e4:	b5d1                	j	800064a8 <page_fault_handler+0xf4>

00000000800065e6 <print_static_proc>:
#include "spinlock.h"
#include "proc.h"
#include "defs.h"
#include "elf.h"

void print_static_proc(char* name) {
    800065e6:	1141                	addi	sp,sp,-16
    800065e8:	e406                	sd	ra,8(sp)
    800065ea:	e022                	sd	s0,0(sp)
    800065ec:	0800                	addi	s0,sp,16
    800065ee:	85aa                	mv	a1,a0
    printf("Static process creation (proc: %s)\n", name);
    800065f0:	00002517          	auipc	a0,0x2
    800065f4:	28850513          	addi	a0,a0,648 # 80008878 <syscalls+0x400>
    800065f8:	ffffa097          	auipc	ra,0xffffa
    800065fc:	f8e080e7          	jalr	-114(ra) # 80000586 <printf>
}
    80006600:	60a2                	ld	ra,8(sp)
    80006602:	6402                	ld	s0,0(sp)
    80006604:	0141                	addi	sp,sp,16
    80006606:	8082                	ret

0000000080006608 <print_ondemand_proc>:

void print_ondemand_proc(char* name) {
    80006608:	1141                	addi	sp,sp,-16
    8000660a:	e406                	sd	ra,8(sp)
    8000660c:	e022                	sd	s0,0(sp)
    8000660e:	0800                	addi	s0,sp,16
    80006610:	85aa                	mv	a1,a0
    printf("Ondemand process creation (proc: %s)\n", name);
    80006612:	00002517          	auipc	a0,0x2
    80006616:	28e50513          	addi	a0,a0,654 # 800088a0 <syscalls+0x428>
    8000661a:	ffffa097          	auipc	ra,0xffffa
    8000661e:	f6c080e7          	jalr	-148(ra) # 80000586 <printf>
}
    80006622:	60a2                	ld	ra,8(sp)
    80006624:	6402                	ld	s0,0(sp)
    80006626:	0141                	addi	sp,sp,16
    80006628:	8082                	ret

000000008000662a <print_skip_section>:

void print_skip_section(char* name, uint64 vaddr, int size) {
    8000662a:	1141                	addi	sp,sp,-16
    8000662c:	e406                	sd	ra,8(sp)
    8000662e:	e022                	sd	s0,0(sp)
    80006630:	0800                	addi	s0,sp,16
    80006632:	86b2                	mv	a3,a2
    printf("Skipping program section loading (proc: %s, addr: %x, size: %d)\n", 
    80006634:	862e                	mv	a2,a1
    80006636:	85aa                	mv	a1,a0
    80006638:	00002517          	auipc	a0,0x2
    8000663c:	29050513          	addi	a0,a0,656 # 800088c8 <syscalls+0x450>
    80006640:	ffffa097          	auipc	ra,0xffffa
    80006644:	f46080e7          	jalr	-186(ra) # 80000586 <printf>
        name, vaddr, size);
}
    80006648:	60a2                	ld	ra,8(sp)
    8000664a:	6402                	ld	s0,0(sp)
    8000664c:	0141                	addi	sp,sp,16
    8000664e:	8082                	ret

0000000080006650 <print_page_fault>:

void print_page_fault(char* name, uint64 vaddr) {
    80006650:	1101                	addi	sp,sp,-32
    80006652:	ec06                	sd	ra,24(sp)
    80006654:	e822                	sd	s0,16(sp)
    80006656:	e426                	sd	s1,8(sp)
    80006658:	e04a                	sd	s2,0(sp)
    8000665a:	1000                	addi	s0,sp,32
    8000665c:	84aa                	mv	s1,a0
    8000665e:	892e                	mv	s2,a1
    printf("----------------------------------------\n");
    80006660:	00002517          	auipc	a0,0x2
    80006664:	2b050513          	addi	a0,a0,688 # 80008910 <syscalls+0x498>
    80006668:	ffffa097          	auipc	ra,0xffffa
    8000666c:	f1e080e7          	jalr	-226(ra) # 80000586 <printf>
    printf("#PF: Proc (%s), Page (%x)\n", name, vaddr);
    80006670:	864a                	mv	a2,s2
    80006672:	85a6                	mv	a1,s1
    80006674:	00002517          	auipc	a0,0x2
    80006678:	2cc50513          	addi	a0,a0,716 # 80008940 <syscalls+0x4c8>
    8000667c:	ffffa097          	auipc	ra,0xffffa
    80006680:	f0a080e7          	jalr	-246(ra) # 80000586 <printf>
}
    80006684:	60e2                	ld	ra,24(sp)
    80006686:	6442                	ld	s0,16(sp)
    80006688:	64a2                	ld	s1,8(sp)
    8000668a:	6902                	ld	s2,0(sp)
    8000668c:	6105                	addi	sp,sp,32
    8000668e:	8082                	ret

0000000080006690 <print_evict_page>:

void print_evict_page(uint64 vaddr, int startblock) {
    80006690:	1141                	addi	sp,sp,-16
    80006692:	e406                	sd	ra,8(sp)
    80006694:	e022                	sd	s0,0(sp)
    80006696:	0800                	addi	s0,sp,16
    80006698:	862e                	mv	a2,a1
    printf("EVICT: Page (%x) --> PSA (%d - %d)\n", vaddr, startblock, startblock+3);
    8000669a:	0035869b          	addiw	a3,a1,3
    8000669e:	85aa                	mv	a1,a0
    800066a0:	00002517          	auipc	a0,0x2
    800066a4:	2c050513          	addi	a0,a0,704 # 80008960 <syscalls+0x4e8>
    800066a8:	ffffa097          	auipc	ra,0xffffa
    800066ac:	ede080e7          	jalr	-290(ra) # 80000586 <printf>
}
    800066b0:	60a2                	ld	ra,8(sp)
    800066b2:	6402                	ld	s0,0(sp)
    800066b4:	0141                	addi	sp,sp,16
    800066b6:	8082                	ret

00000000800066b8 <print_retrieve_page>:

void print_retrieve_page(uint64 vaddr, int startblock) {
    800066b8:	1141                	addi	sp,sp,-16
    800066ba:	e406                	sd	ra,8(sp)
    800066bc:	e022                	sd	s0,0(sp)
    800066be:	0800                	addi	s0,sp,16
    800066c0:	862e                	mv	a2,a1
    printf("RETRIEVE: Page (%x) --> PSA (%d - %d)\n", vaddr, startblock, startblock+3);
    800066c2:	0035869b          	addiw	a3,a1,3
    800066c6:	85aa                	mv	a1,a0
    800066c8:	00002517          	auipc	a0,0x2
    800066cc:	2c050513          	addi	a0,a0,704 # 80008988 <syscalls+0x510>
    800066d0:	ffffa097          	auipc	ra,0xffffa
    800066d4:	eb6080e7          	jalr	-330(ra) # 80000586 <printf>
}
    800066d8:	60a2                	ld	ra,8(sp)
    800066da:	6402                	ld	s0,0(sp)
    800066dc:	0141                	addi	sp,sp,16
    800066de:	8082                	ret

00000000800066e0 <print_load_seg>:

void print_load_seg(uint64 vaddr, uint64 seg, int size) {
    800066e0:	1141                	addi	sp,sp,-16
    800066e2:	e406                	sd	ra,8(sp)
    800066e4:	e022                	sd	s0,0(sp)
    800066e6:	0800                	addi	s0,sp,16
    800066e8:	86b2                	mv	a3,a2
    printf("LOAD: Addr (%x), SEG: (%x), SIZE (%d)\n", vaddr, seg, size);
    800066ea:	862e                	mv	a2,a1
    800066ec:	85aa                	mv	a1,a0
    800066ee:	00002517          	auipc	a0,0x2
    800066f2:	2c250513          	addi	a0,a0,706 # 800089b0 <syscalls+0x538>
    800066f6:	ffffa097          	auipc	ra,0xffffa
    800066fa:	e90080e7          	jalr	-368(ra) # 80000586 <printf>
}
    800066fe:	60a2                	ld	ra,8(sp)
    80006700:	6402                	ld	s0,0(sp)
    80006702:	0141                	addi	sp,sp,16
    80006704:	8082                	ret

0000000080006706 <print_skip_heap_region>:

void print_skip_heap_region(char* name, uint64 vaddr, int npages) {
    80006706:	1141                	addi	sp,sp,-16
    80006708:	e406                	sd	ra,8(sp)
    8000670a:	e022                	sd	s0,0(sp)
    8000670c:	0800                	addi	s0,sp,16
    8000670e:	86b2                	mv	a3,a2
    printf("Skipping heap region allocation (proc: %s, addr: %x, npages: %d)\n", 
    80006710:	862e                	mv	a2,a1
    80006712:	85aa                	mv	a1,a0
    80006714:	00002517          	auipc	a0,0x2
    80006718:	2c450513          	addi	a0,a0,708 # 800089d8 <syscalls+0x560>
    8000671c:	ffffa097          	auipc	ra,0xffffa
    80006720:	e6a080e7          	jalr	-406(ra) # 80000586 <printf>
        name, vaddr, npages);
}
    80006724:	60a2                	ld	ra,8(sp)
    80006726:	6402                	ld	s0,0(sp)
    80006728:	0141                	addi	sp,sp,16
    8000672a:	8082                	ret
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
