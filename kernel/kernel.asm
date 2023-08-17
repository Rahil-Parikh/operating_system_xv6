
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	00009117          	auipc	sp,0x9
    80000004:	bc010113          	addi	sp,sp,-1088 # 80008bc0 <stack0>
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
    80000054:	a3070713          	addi	a4,a4,-1488 # 80008a80 <timer_scratch>
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
    80000066:	b0e78793          	addi	a5,a5,-1266 # 80005b70 <timervec>
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
    8000009a:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffdc907>
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
    8000012e:	3ae080e7          	jalr	942(ra) # 800024d8 <either_copyin>
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
    80000188:	a3c50513          	addi	a0,a0,-1476 # 80010bc0 <cons>
    8000018c:	00001097          	auipc	ra,0x1
    80000190:	a46080e7          	jalr	-1466(ra) # 80000bd2 <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    80000194:	00011497          	auipc	s1,0x11
    80000198:	a2c48493          	addi	s1,s1,-1492 # 80010bc0 <cons>
      if(killed(myproc())){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    8000019c:	00011917          	auipc	s2,0x11
    800001a0:	abc90913          	addi	s2,s2,-1348 # 80010c58 <cons+0x98>
  while(n > 0){
    800001a4:	09305263          	blez	s3,80000228 <consoleread+0xc4>
    while(cons.r == cons.w){
    800001a8:	0984a783          	lw	a5,152(s1)
    800001ac:	09c4a703          	lw	a4,156(s1)
    800001b0:	02f71763          	bne	a4,a5,800001de <consoleread+0x7a>
      if(killed(myproc())){
    800001b4:	00002097          	auipc	ra,0x2
    800001b8:	816080e7          	jalr	-2026(ra) # 800019ca <myproc>
    800001bc:	00002097          	auipc	ra,0x2
    800001c0:	166080e7          	jalr	358(ra) # 80002322 <killed>
    800001c4:	ed2d                	bnez	a0,8000023e <consoleread+0xda>
      sleep(&cons.r, &cons.lock);
    800001c6:	85a6                	mv	a1,s1
    800001c8:	854a                	mv	a0,s2
    800001ca:	00002097          	auipc	ra,0x2
    800001ce:	eb0080e7          	jalr	-336(ra) # 8000207a <sleep>
    while(cons.r == cons.w){
    800001d2:	0984a783          	lw	a5,152(s1)
    800001d6:	09c4a703          	lw	a4,156(s1)
    800001da:	fcf70de3          	beq	a4,a5,800001b4 <consoleread+0x50>
    }

    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];
    800001de:	00011717          	auipc	a4,0x11
    800001e2:	9e270713          	addi	a4,a4,-1566 # 80010bc0 <cons>
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
    80000214:	272080e7          	jalr	626(ra) # 80002482 <either_copyout>
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
    8000022c:	99850513          	addi	a0,a0,-1640 # 80010bc0 <cons>
    80000230:	00001097          	auipc	ra,0x1
    80000234:	a56080e7          	jalr	-1450(ra) # 80000c86 <release>

  return target - n;
    80000238:	413b053b          	subw	a0,s6,s3
    8000023c:	a811                	j	80000250 <consoleread+0xec>
        release(&cons.lock);
    8000023e:	00011517          	auipc	a0,0x11
    80000242:	98250513          	addi	a0,a0,-1662 # 80010bc0 <cons>
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
    80000272:	9ef72523          	sw	a5,-1558(a4) # 80010c58 <cons+0x98>
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
    800002cc:	8f850513          	addi	a0,a0,-1800 # 80010bc0 <cons>
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
    800002f2:	240080e7          	jalr	576(ra) # 8000252e <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    800002f6:	00011517          	auipc	a0,0x11
    800002fa:	8ca50513          	addi	a0,a0,-1846 # 80010bc0 <cons>
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
    8000031e:	8a670713          	addi	a4,a4,-1882 # 80010bc0 <cons>
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
    80000348:	87c78793          	addi	a5,a5,-1924 # 80010bc0 <cons>
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
    80000376:	8e67a783          	lw	a5,-1818(a5) # 80010c58 <cons+0x98>
    8000037a:	9f1d                	subw	a4,a4,a5
    8000037c:	08000793          	li	a5,128
    80000380:	f6f71be3          	bne	a4,a5,800002f6 <consoleintr+0x3c>
    80000384:	a07d                	j	80000432 <consoleintr+0x178>
    while(cons.e != cons.w &&
    80000386:	00011717          	auipc	a4,0x11
    8000038a:	83a70713          	addi	a4,a4,-1990 # 80010bc0 <cons>
    8000038e:	0a072783          	lw	a5,160(a4)
    80000392:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    80000396:	00011497          	auipc	s1,0x11
    8000039a:	82a48493          	addi	s1,s1,-2006 # 80010bc0 <cons>
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
    800003d2:	00010717          	auipc	a4,0x10
    800003d6:	7ee70713          	addi	a4,a4,2030 # 80010bc0 <cons>
    800003da:	0a072783          	lw	a5,160(a4)
    800003de:	09c72703          	lw	a4,156(a4)
    800003e2:	f0f70ae3          	beq	a4,a5,800002f6 <consoleintr+0x3c>
      cons.e--;
    800003e6:	37fd                	addiw	a5,a5,-1
    800003e8:	00011717          	auipc	a4,0x11
    800003ec:	86f72c23          	sw	a5,-1928(a4) # 80010c60 <cons+0xa0>
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
    80000412:	7b278793          	addi	a5,a5,1970 # 80010bc0 <cons>
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
    80000436:	82c7a523          	sw	a2,-2006(a5) # 80010c5c <cons+0x9c>
        wakeup(&cons.r);
    8000043a:	00011517          	auipc	a0,0x11
    8000043e:	81e50513          	addi	a0,a0,-2018 # 80010c58 <cons+0x98>
    80000442:	00002097          	auipc	ra,0x2
    80000446:	c9c080e7          	jalr	-868(ra) # 800020de <wakeup>
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
    80000460:	76450513          	addi	a0,a0,1892 # 80010bc0 <cons>
    80000464:	00000097          	auipc	ra,0x0
    80000468:	6de080e7          	jalr	1758(ra) # 80000b42 <initlock>

  uartinit();
    8000046c:	00000097          	auipc	ra,0x0
    80000470:	32c080e7          	jalr	812(ra) # 80000798 <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    80000474:	00021797          	auipc	a5,0x21
    80000478:	8ec78793          	addi	a5,a5,-1812 # 80020d60 <devsw>
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
    8000054c:	7207ac23          	sw	zero,1848(a5) # 80010c80 <pr+0x18>
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
    8000056e:	47650513          	addi	a0,a0,1142 # 800089e0 <syscalls+0x598>
    80000572:	00000097          	auipc	ra,0x0
    80000576:	014080e7          	jalr	20(ra) # 80000586 <printf>
  panicked = 1; // freeze uart output from other CPUs
    8000057a:	4785                	li	a5,1
    8000057c:	00008717          	auipc	a4,0x8
    80000580:	4cf72223          	sw	a5,1220(a4) # 80008a40 <panicked>
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
    800005bc:	6c8dad83          	lw	s11,1736(s11) # 80010c80 <pr+0x18>
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
    800005fa:	67250513          	addi	a0,a0,1650 # 80010c68 <pr>
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
    80000758:	51450513          	addi	a0,a0,1300 # 80010c68 <pr>
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
    80000774:	4f848493          	addi	s1,s1,1272 # 80010c68 <pr>
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
    800007d4:	4b850513          	addi	a0,a0,1208 # 80010c88 <uart_tx_lock>
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
    80000800:	2447a783          	lw	a5,580(a5) # 80008a40 <panicked>
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
    80000838:	2147b783          	ld	a5,532(a5) # 80008a48 <uart_tx_r>
    8000083c:	00008717          	auipc	a4,0x8
    80000840:	21473703          	ld	a4,532(a4) # 80008a50 <uart_tx_w>
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
    80000862:	42aa0a13          	addi	s4,s4,1066 # 80010c88 <uart_tx_lock>
    uart_tx_r += 1;
    80000866:	00008497          	auipc	s1,0x8
    8000086a:	1e248493          	addi	s1,s1,482 # 80008a48 <uart_tx_r>
    if(uart_tx_w == uart_tx_r){
    8000086e:	00008997          	auipc	s3,0x8
    80000872:	1e298993          	addi	s3,s3,482 # 80008a50 <uart_tx_w>
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
    80000894:	84e080e7          	jalr	-1970(ra) # 800020de <wakeup>
    
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
    800008d0:	3bc50513          	addi	a0,a0,956 # 80010c88 <uart_tx_lock>
    800008d4:	00000097          	auipc	ra,0x0
    800008d8:	2fe080e7          	jalr	766(ra) # 80000bd2 <acquire>
  if(panicked){
    800008dc:	00008797          	auipc	a5,0x8
    800008e0:	1647a783          	lw	a5,356(a5) # 80008a40 <panicked>
    800008e4:	e7c9                	bnez	a5,8000096e <uartputc+0xb4>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    800008e6:	00008717          	auipc	a4,0x8
    800008ea:	16a73703          	ld	a4,362(a4) # 80008a50 <uart_tx_w>
    800008ee:	00008797          	auipc	a5,0x8
    800008f2:	15a7b783          	ld	a5,346(a5) # 80008a48 <uart_tx_r>
    800008f6:	02078793          	addi	a5,a5,32
    sleep(&uart_tx_r, &uart_tx_lock);
    800008fa:	00010997          	auipc	s3,0x10
    800008fe:	38e98993          	addi	s3,s3,910 # 80010c88 <uart_tx_lock>
    80000902:	00008497          	auipc	s1,0x8
    80000906:	14648493          	addi	s1,s1,326 # 80008a48 <uart_tx_r>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    8000090a:	00008917          	auipc	s2,0x8
    8000090e:	14690913          	addi	s2,s2,326 # 80008a50 <uart_tx_w>
    80000912:	00e79f63          	bne	a5,a4,80000930 <uartputc+0x76>
    sleep(&uart_tx_r, &uart_tx_lock);
    80000916:	85ce                	mv	a1,s3
    80000918:	8526                	mv	a0,s1
    8000091a:	00001097          	auipc	ra,0x1
    8000091e:	760080e7          	jalr	1888(ra) # 8000207a <sleep>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000922:	00093703          	ld	a4,0(s2)
    80000926:	609c                	ld	a5,0(s1)
    80000928:	02078793          	addi	a5,a5,32
    8000092c:	fee785e3          	beq	a5,a4,80000916 <uartputc+0x5c>
  uart_tx_buf[uart_tx_w % UART_TX_BUF_SIZE] = c;
    80000930:	00010497          	auipc	s1,0x10
    80000934:	35848493          	addi	s1,s1,856 # 80010c88 <uart_tx_lock>
    80000938:	01f77793          	andi	a5,a4,31
    8000093c:	97a6                	add	a5,a5,s1
    8000093e:	01478c23          	sb	s4,24(a5)
  uart_tx_w += 1;
    80000942:	0705                	addi	a4,a4,1
    80000944:	00008797          	auipc	a5,0x8
    80000948:	10e7b623          	sd	a4,268(a5) # 80008a50 <uart_tx_w>
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
    800009ba:	2d248493          	addi	s1,s1,722 # 80010c88 <uart_tx_lock>
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
    800009f8:	00021797          	auipc	a5,0x21
    800009fc:	50078793          	addi	a5,a5,1280 # 80021ef8 <end>
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
    80000a1c:	2a890913          	addi	s2,s2,680 # 80010cc0 <kmem>
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
    80000aba:	20a50513          	addi	a0,a0,522 # 80010cc0 <kmem>
    80000abe:	00000097          	auipc	ra,0x0
    80000ac2:	084080e7          	jalr	132(ra) # 80000b42 <initlock>
  freerange(end, (void*)PHYSTOP);
    80000ac6:	45c5                	li	a1,17
    80000ac8:	05ee                	slli	a1,a1,0x1b
    80000aca:	00021517          	auipc	a0,0x21
    80000ace:	42e50513          	addi	a0,a0,1070 # 80021ef8 <end>
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
    80000af0:	1d448493          	addi	s1,s1,468 # 80010cc0 <kmem>
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
    80000b08:	1bc50513          	addi	a0,a0,444 # 80010cc0 <kmem>
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
    80000b34:	19050513          	addi	a0,a0,400 # 80010cc0 <kmem>
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
    80000b70:	e42080e7          	jalr	-446(ra) # 800019ae <mycpu>
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
    80000ba2:	e10080e7          	jalr	-496(ra) # 800019ae <mycpu>
    80000ba6:	5d3c                	lw	a5,120(a0)
    80000ba8:	cf89                	beqz	a5,80000bc2 <push_off+0x3c>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000baa:	00001097          	auipc	ra,0x1
    80000bae:	e04080e7          	jalr	-508(ra) # 800019ae <mycpu>
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
    80000bc6:	dec080e7          	jalr	-532(ra) # 800019ae <mycpu>
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
    80000c06:	dac080e7          	jalr	-596(ra) # 800019ae <mycpu>
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
    80000c32:	d80080e7          	jalr	-640(ra) # 800019ae <mycpu>
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
    80000d42:	0705                	addi	a4,a4,1 # fffffffffffff001 <end+0xffffffff7ffdd109>
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
    80000e7e:	b24080e7          	jalr	-1244(ra) # 8000199e <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000e82:	00008717          	auipc	a4,0x8
    80000e86:	bd670713          	addi	a4,a4,-1066 # 80008a58 <started>
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
    80000e9a:	b08080e7          	jalr	-1272(ra) # 8000199e <cpuid>
    80000e9e:	85aa                	mv	a1,a0
    80000ea0:	00007517          	auipc	a0,0x7
    80000ea4:	21850513          	addi	a0,a0,536 # 800080b8 <digits+0x78>
    80000ea8:	fffff097          	auipc	ra,0xfffff
    80000eac:	6de080e7          	jalr	1758(ra) # 80000586 <printf>
    kvminithart();    // turn on paging
    80000eb0:	00000097          	auipc	ra,0x0
    80000eb4:	0d8080e7          	jalr	216(ra) # 80000f88 <kvminithart>
    trapinithart();   // install kernel trap vector
    80000eb8:	00001097          	auipc	ra,0x1
    80000ebc:	7b8080e7          	jalr	1976(ra) # 80002670 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000ec0:	00005097          	auipc	ra,0x5
    80000ec4:	cf0080e7          	jalr	-784(ra) # 80005bb0 <plicinithart>
  }

  scheduler();        
    80000ec8:	00001097          	auipc	ra,0x1
    80000ecc:	000080e7          	jalr	ra # 80001ec8 <scheduler>
    consoleinit();
    80000ed0:	fffff097          	auipc	ra,0xfffff
    80000ed4:	57c080e7          	jalr	1404(ra) # 8000044c <consoleinit>
    printfinit();
    80000ed8:	00000097          	auipc	ra,0x0
    80000edc:	88e080e7          	jalr	-1906(ra) # 80000766 <printfinit>
    printf("\n");
    80000ee0:	00008517          	auipc	a0,0x8
    80000ee4:	b0050513          	addi	a0,a0,-1280 # 800089e0 <syscalls+0x598>
    80000ee8:	fffff097          	auipc	ra,0xfffff
    80000eec:	69e080e7          	jalr	1694(ra) # 80000586 <printf>
    printf("xv6 kernel is booting\n");
    80000ef0:	00007517          	auipc	a0,0x7
    80000ef4:	1b050513          	addi	a0,a0,432 # 800080a0 <digits+0x60>
    80000ef8:	fffff097          	auipc	ra,0xfffff
    80000efc:	68e080e7          	jalr	1678(ra) # 80000586 <printf>
    printf("\n");
    80000f00:	00008517          	auipc	a0,0x8
    80000f04:	ae050513          	addi	a0,a0,-1312 # 800089e0 <syscalls+0x598>
    80000f08:	fffff097          	auipc	ra,0xfffff
    80000f0c:	67e080e7          	jalr	1662(ra) # 80000586 <printf>
    kinit();         // physical page allocator
    80000f10:	00000097          	auipc	ra,0x0
    80000f14:	b96080e7          	jalr	-1130(ra) # 80000aa6 <kinit>
    kvminit();       // create kernel page table
    80000f18:	00000097          	auipc	ra,0x0
    80000f1c:	326080e7          	jalr	806(ra) # 8000123e <kvminit>
    kvminithart();   // turn on paging
    80000f20:	00000097          	auipc	ra,0x0
    80000f24:	068080e7          	jalr	104(ra) # 80000f88 <kvminithart>
    procinit();      // process table
    80000f28:	00001097          	auipc	ra,0x1
    80000f2c:	9c2080e7          	jalr	-1598(ra) # 800018ea <procinit>
    trapinit();      // trap vectors
    80000f30:	00001097          	auipc	ra,0x1
    80000f34:	718080e7          	jalr	1816(ra) # 80002648 <trapinit>
    trapinithart();  // install kernel trap vector
    80000f38:	00001097          	auipc	ra,0x1
    80000f3c:	738080e7          	jalr	1848(ra) # 80002670 <trapinithart>
    plicinit();      // set up interrupt controller
    80000f40:	00005097          	auipc	ra,0x5
    80000f44:	c5a080e7          	jalr	-934(ra) # 80005b9a <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000f48:	00005097          	auipc	ra,0x5
    80000f4c:	c68080e7          	jalr	-920(ra) # 80005bb0 <plicinithart>
    binit();         // buffer cache
    80000f50:	00002097          	auipc	ra,0x2
    80000f54:	e70080e7          	jalr	-400(ra) # 80002dc0 <binit>
    iinit();         // inode table
    80000f58:	00002097          	auipc	ra,0x2
    80000f5c:	50e080e7          	jalr	1294(ra) # 80003466 <iinit>
    fileinit();      // file table
    80000f60:	00003097          	auipc	ra,0x3
    80000f64:	484080e7          	jalr	1156(ra) # 800043e4 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000f68:	00005097          	auipc	ra,0x5
    80000f6c:	d50080e7          	jalr	-688(ra) # 80005cb8 <virtio_disk_init>
    userinit();      // first user process
    80000f70:	00001097          	auipc	ra,0x1
    80000f74:	d32080e7          	jalr	-718(ra) # 80001ca2 <userinit>
    __sync_synchronize();
    80000f78:	0ff0000f          	fence
    started = 1;
    80000f7c:	4785                	li	a5,1
    80000f7e:	00008717          	auipc	a4,0x8
    80000f82:	acf72d23          	sw	a5,-1318(a4) # 80008a58 <started>
    80000f86:	b789                	j	80000ec8 <main+0x56>

0000000080000f88 <kvminithart>:

// Switch h/w page table register to the kernel's page table,
// and enable paging.
void
kvminithart()
{
    80000f88:	1141                	addi	sp,sp,-16
    80000f8a:	e422                	sd	s0,8(sp)
    80000f8c:	0800                	addi	s0,sp,16
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    80000f8e:	12000073          	sfence.vma
  // wait for any previous writes to the page table memory to finish.
  sfence_vma();

  w_satp(MAKE_SATP(kernel_pagetable));
    80000f92:	00008797          	auipc	a5,0x8
    80000f96:	ace7b783          	ld	a5,-1330(a5) # 80008a60 <kernel_pagetable>
    80000f9a:	83b1                	srli	a5,a5,0xc
    80000f9c:	577d                	li	a4,-1
    80000f9e:	177e                	slli	a4,a4,0x3f
    80000fa0:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    80000fa2:	18079073          	csrw	satp,a5
  asm volatile("sfence.vma zero, zero");
    80000fa6:	12000073          	sfence.vma

  // flush stale entries from the TLB.
  sfence_vma();
}
    80000faa:	6422                	ld	s0,8(sp)
    80000fac:	0141                	addi	sp,sp,16
    80000fae:	8082                	ret

0000000080000fb0 <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    80000fb0:	7139                	addi	sp,sp,-64
    80000fb2:	fc06                	sd	ra,56(sp)
    80000fb4:	f822                	sd	s0,48(sp)
    80000fb6:	f426                	sd	s1,40(sp)
    80000fb8:	f04a                	sd	s2,32(sp)
    80000fba:	ec4e                	sd	s3,24(sp)
    80000fbc:	e852                	sd	s4,16(sp)
    80000fbe:	e456                	sd	s5,8(sp)
    80000fc0:	e05a                	sd	s6,0(sp)
    80000fc2:	0080                	addi	s0,sp,64
    80000fc4:	84aa                	mv	s1,a0
    80000fc6:	89ae                	mv	s3,a1
    80000fc8:	8ab2                	mv	s5,a2
  if(va >= MAXVA)
    80000fca:	57fd                	li	a5,-1
    80000fcc:	83e9                	srli	a5,a5,0x1a
    80000fce:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    80000fd0:	4b31                	li	s6,12
  if(va >= MAXVA)
    80000fd2:	04b7f263          	bgeu	a5,a1,80001016 <walk+0x66>
    panic("walk");
    80000fd6:	00007517          	auipc	a0,0x7
    80000fda:	0fa50513          	addi	a0,a0,250 # 800080d0 <digits+0x90>
    80000fde:	fffff097          	auipc	ra,0xfffff
    80000fe2:	55e080e7          	jalr	1374(ra) # 8000053c <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    80000fe6:	060a8663          	beqz	s5,80001052 <walk+0xa2>
    80000fea:	00000097          	auipc	ra,0x0
    80000fee:	af8080e7          	jalr	-1288(ra) # 80000ae2 <kalloc>
    80000ff2:	84aa                	mv	s1,a0
    80000ff4:	c529                	beqz	a0,8000103e <walk+0x8e>
        return 0;
      memset(pagetable, 0, PGSIZE);
    80000ff6:	6605                	lui	a2,0x1
    80000ff8:	4581                	li	a1,0
    80000ffa:	00000097          	auipc	ra,0x0
    80000ffe:	cd4080e7          	jalr	-812(ra) # 80000cce <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    80001002:	00c4d793          	srli	a5,s1,0xc
    80001006:	07aa                	slli	a5,a5,0xa
    80001008:	0017e793          	ori	a5,a5,1
    8000100c:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    80001010:	3a5d                	addiw	s4,s4,-9 # ffffffffffffeff7 <end+0xffffffff7ffdd0ff>
    80001012:	036a0063          	beq	s4,s6,80001032 <walk+0x82>
    pte_t *pte = &pagetable[PX(level, va)];
    80001016:	0149d933          	srl	s2,s3,s4
    8000101a:	1ff97913          	andi	s2,s2,511
    8000101e:	090e                	slli	s2,s2,0x3
    80001020:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    80001022:	00093483          	ld	s1,0(s2)
    80001026:	0014f793          	andi	a5,s1,1
    8000102a:	dfd5                	beqz	a5,80000fe6 <walk+0x36>
      pagetable = (pagetable_t)PTE2PA(*pte);
    8000102c:	80a9                	srli	s1,s1,0xa
    8000102e:	04b2                	slli	s1,s1,0xc
    80001030:	b7c5                	j	80001010 <walk+0x60>
    }
  }
  return &pagetable[PX(0, va)];
    80001032:	00c9d513          	srli	a0,s3,0xc
    80001036:	1ff57513          	andi	a0,a0,511
    8000103a:	050e                	slli	a0,a0,0x3
    8000103c:	9526                	add	a0,a0,s1
}
    8000103e:	70e2                	ld	ra,56(sp)
    80001040:	7442                	ld	s0,48(sp)
    80001042:	74a2                	ld	s1,40(sp)
    80001044:	7902                	ld	s2,32(sp)
    80001046:	69e2                	ld	s3,24(sp)
    80001048:	6a42                	ld	s4,16(sp)
    8000104a:	6aa2                	ld	s5,8(sp)
    8000104c:	6b02                	ld	s6,0(sp)
    8000104e:	6121                	addi	sp,sp,64
    80001050:	8082                	ret
        return 0;
    80001052:	4501                	li	a0,0
    80001054:	b7ed                	j	8000103e <walk+0x8e>

0000000080001056 <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    80001056:	57fd                	li	a5,-1
    80001058:	83e9                	srli	a5,a5,0x1a
    8000105a:	00b7f463          	bgeu	a5,a1,80001062 <walkaddr+0xc>
    return 0;
    8000105e:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    80001060:	8082                	ret
{
    80001062:	1141                	addi	sp,sp,-16
    80001064:	e406                	sd	ra,8(sp)
    80001066:	e022                	sd	s0,0(sp)
    80001068:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    8000106a:	4601                	li	a2,0
    8000106c:	00000097          	auipc	ra,0x0
    80001070:	f44080e7          	jalr	-188(ra) # 80000fb0 <walk>
  if(pte == 0)
    80001074:	c105                	beqz	a0,80001094 <walkaddr+0x3e>
  if((*pte & PTE_V) == 0)
    80001076:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    80001078:	0117f693          	andi	a3,a5,17
    8000107c:	4745                	li	a4,17
    return 0;
    8000107e:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    80001080:	00e68663          	beq	a3,a4,8000108c <walkaddr+0x36>
}
    80001084:	60a2                	ld	ra,8(sp)
    80001086:	6402                	ld	s0,0(sp)
    80001088:	0141                	addi	sp,sp,16
    8000108a:	8082                	ret
  pa = PTE2PA(*pte);
    8000108c:	83a9                	srli	a5,a5,0xa
    8000108e:	00c79513          	slli	a0,a5,0xc
  return pa;
    80001092:	bfcd                	j	80001084 <walkaddr+0x2e>
    return 0;
    80001094:	4501                	li	a0,0
    80001096:	b7fd                	j	80001084 <walkaddr+0x2e>

0000000080001098 <mappages>:
// physical addresses starting at pa. va and size might not
// be page-aligned. Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    80001098:	715d                	addi	sp,sp,-80
    8000109a:	e486                	sd	ra,72(sp)
    8000109c:	e0a2                	sd	s0,64(sp)
    8000109e:	fc26                	sd	s1,56(sp)
    800010a0:	f84a                	sd	s2,48(sp)
    800010a2:	f44e                	sd	s3,40(sp)
    800010a4:	f052                	sd	s4,32(sp)
    800010a6:	ec56                	sd	s5,24(sp)
    800010a8:	e85a                	sd	s6,16(sp)
    800010aa:	e45e                	sd	s7,8(sp)
    800010ac:	0880                	addi	s0,sp,80
  uint64 a, last;
  pte_t *pte;

  if(size == 0)
    800010ae:	c639                	beqz	a2,800010fc <mappages+0x64>
    800010b0:	8aaa                	mv	s5,a0
    800010b2:	8b3a                	mv	s6,a4
    panic("mappages: size");
  
  a = PGROUNDDOWN(va);
    800010b4:	777d                	lui	a4,0xfffff
    800010b6:	00e5f7b3          	and	a5,a1,a4
  last = PGROUNDDOWN(va + size - 1);
    800010ba:	fff58993          	addi	s3,a1,-1
    800010be:	99b2                	add	s3,s3,a2
    800010c0:	00e9f9b3          	and	s3,s3,a4
  a = PGROUNDDOWN(va);
    800010c4:	893e                	mv	s2,a5
    800010c6:	40f68a33          	sub	s4,a3,a5
    if(*pte & PTE_V)
      panic("mappages: remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    800010ca:	6b85                	lui	s7,0x1
    800010cc:	012a04b3          	add	s1,s4,s2
    if((pte = walk(pagetable, a, 1)) == 0)
    800010d0:	4605                	li	a2,1
    800010d2:	85ca                	mv	a1,s2
    800010d4:	8556                	mv	a0,s5
    800010d6:	00000097          	auipc	ra,0x0
    800010da:	eda080e7          	jalr	-294(ra) # 80000fb0 <walk>
    800010de:	cd1d                	beqz	a0,8000111c <mappages+0x84>
    if(*pte & PTE_V)
    800010e0:	611c                	ld	a5,0(a0)
    800010e2:	8b85                	andi	a5,a5,1
    800010e4:	e785                	bnez	a5,8000110c <mappages+0x74>
    *pte = PA2PTE(pa) | perm | PTE_V;
    800010e6:	80b1                	srli	s1,s1,0xc
    800010e8:	04aa                	slli	s1,s1,0xa
    800010ea:	0164e4b3          	or	s1,s1,s6
    800010ee:	0014e493          	ori	s1,s1,1
    800010f2:	e104                	sd	s1,0(a0)
    if(a == last)
    800010f4:	05390063          	beq	s2,s3,80001134 <mappages+0x9c>
    a += PGSIZE;
    800010f8:	995e                	add	s2,s2,s7
    if((pte = walk(pagetable, a, 1)) == 0)
    800010fa:	bfc9                	j	800010cc <mappages+0x34>
    panic("mappages: size");
    800010fc:	00007517          	auipc	a0,0x7
    80001100:	fdc50513          	addi	a0,a0,-36 # 800080d8 <digits+0x98>
    80001104:	fffff097          	auipc	ra,0xfffff
    80001108:	438080e7          	jalr	1080(ra) # 8000053c <panic>
      panic("mappages: remap");
    8000110c:	00007517          	auipc	a0,0x7
    80001110:	fdc50513          	addi	a0,a0,-36 # 800080e8 <digits+0xa8>
    80001114:	fffff097          	auipc	ra,0xfffff
    80001118:	428080e7          	jalr	1064(ra) # 8000053c <panic>
      return -1;
    8000111c:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    8000111e:	60a6                	ld	ra,72(sp)
    80001120:	6406                	ld	s0,64(sp)
    80001122:	74e2                	ld	s1,56(sp)
    80001124:	7942                	ld	s2,48(sp)
    80001126:	79a2                	ld	s3,40(sp)
    80001128:	7a02                	ld	s4,32(sp)
    8000112a:	6ae2                	ld	s5,24(sp)
    8000112c:	6b42                	ld	s6,16(sp)
    8000112e:	6ba2                	ld	s7,8(sp)
    80001130:	6161                	addi	sp,sp,80
    80001132:	8082                	ret
  return 0;
    80001134:	4501                	li	a0,0
    80001136:	b7e5                	j	8000111e <mappages+0x86>

0000000080001138 <kvmmap>:
{
    80001138:	1141                	addi	sp,sp,-16
    8000113a:	e406                	sd	ra,8(sp)
    8000113c:	e022                	sd	s0,0(sp)
    8000113e:	0800                	addi	s0,sp,16
    80001140:	87b6                	mv	a5,a3
  if(mappages(kpgtbl, va, sz, pa, perm) != 0)
    80001142:	86b2                	mv	a3,a2
    80001144:	863e                	mv	a2,a5
    80001146:	00000097          	auipc	ra,0x0
    8000114a:	f52080e7          	jalr	-174(ra) # 80001098 <mappages>
    8000114e:	e509                	bnez	a0,80001158 <kvmmap+0x20>
}
    80001150:	60a2                	ld	ra,8(sp)
    80001152:	6402                	ld	s0,0(sp)
    80001154:	0141                	addi	sp,sp,16
    80001156:	8082                	ret
    panic("kvmmap");
    80001158:	00007517          	auipc	a0,0x7
    8000115c:	fa050513          	addi	a0,a0,-96 # 800080f8 <digits+0xb8>
    80001160:	fffff097          	auipc	ra,0xfffff
    80001164:	3dc080e7          	jalr	988(ra) # 8000053c <panic>

0000000080001168 <kvmmake>:
{
    80001168:	1101                	addi	sp,sp,-32
    8000116a:	ec06                	sd	ra,24(sp)
    8000116c:	e822                	sd	s0,16(sp)
    8000116e:	e426                	sd	s1,8(sp)
    80001170:	e04a                	sd	s2,0(sp)
    80001172:	1000                	addi	s0,sp,32
  kpgtbl = (pagetable_t) kalloc();
    80001174:	00000097          	auipc	ra,0x0
    80001178:	96e080e7          	jalr	-1682(ra) # 80000ae2 <kalloc>
    8000117c:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    8000117e:	6605                	lui	a2,0x1
    80001180:	4581                	li	a1,0
    80001182:	00000097          	auipc	ra,0x0
    80001186:	b4c080e7          	jalr	-1204(ra) # 80000cce <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    8000118a:	4719                	li	a4,6
    8000118c:	6685                	lui	a3,0x1
    8000118e:	10000637          	lui	a2,0x10000
    80001192:	100005b7          	lui	a1,0x10000
    80001196:	8526                	mv	a0,s1
    80001198:	00000097          	auipc	ra,0x0
    8000119c:	fa0080e7          	jalr	-96(ra) # 80001138 <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    800011a0:	4719                	li	a4,6
    800011a2:	6685                	lui	a3,0x1
    800011a4:	10001637          	lui	a2,0x10001
    800011a8:	100015b7          	lui	a1,0x10001
    800011ac:	8526                	mv	a0,s1
    800011ae:	00000097          	auipc	ra,0x0
    800011b2:	f8a080e7          	jalr	-118(ra) # 80001138 <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x400000, PTE_R | PTE_W);
    800011b6:	4719                	li	a4,6
    800011b8:	004006b7          	lui	a3,0x400
    800011bc:	0c000637          	lui	a2,0xc000
    800011c0:	0c0005b7          	lui	a1,0xc000
    800011c4:	8526                	mv	a0,s1
    800011c6:	00000097          	auipc	ra,0x0
    800011ca:	f72080e7          	jalr	-142(ra) # 80001138 <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    800011ce:	00007917          	auipc	s2,0x7
    800011d2:	e3290913          	addi	s2,s2,-462 # 80008000 <etext>
    800011d6:	4729                	li	a4,10
    800011d8:	80007697          	auipc	a3,0x80007
    800011dc:	e2868693          	addi	a3,a3,-472 # 8000 <_entry-0x7fff8000>
    800011e0:	4605                	li	a2,1
    800011e2:	067e                	slli	a2,a2,0x1f
    800011e4:	85b2                	mv	a1,a2
    800011e6:	8526                	mv	a0,s1
    800011e8:	00000097          	auipc	ra,0x0
    800011ec:	f50080e7          	jalr	-176(ra) # 80001138 <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    800011f0:	4719                	li	a4,6
    800011f2:	46c5                	li	a3,17
    800011f4:	06ee                	slli	a3,a3,0x1b
    800011f6:	412686b3          	sub	a3,a3,s2
    800011fa:	864a                	mv	a2,s2
    800011fc:	85ca                	mv	a1,s2
    800011fe:	8526                	mv	a0,s1
    80001200:	00000097          	auipc	ra,0x0
    80001204:	f38080e7          	jalr	-200(ra) # 80001138 <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    80001208:	4729                	li	a4,10
    8000120a:	6685                	lui	a3,0x1
    8000120c:	00006617          	auipc	a2,0x6
    80001210:	df460613          	addi	a2,a2,-524 # 80007000 <_trampoline>
    80001214:	040005b7          	lui	a1,0x4000
    80001218:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    8000121a:	05b2                	slli	a1,a1,0xc
    8000121c:	8526                	mv	a0,s1
    8000121e:	00000097          	auipc	ra,0x0
    80001222:	f1a080e7          	jalr	-230(ra) # 80001138 <kvmmap>
  proc_mapstacks(kpgtbl);
    80001226:	8526                	mv	a0,s1
    80001228:	00000097          	auipc	ra,0x0
    8000122c:	62c080e7          	jalr	1580(ra) # 80001854 <proc_mapstacks>
}
    80001230:	8526                	mv	a0,s1
    80001232:	60e2                	ld	ra,24(sp)
    80001234:	6442                	ld	s0,16(sp)
    80001236:	64a2                	ld	s1,8(sp)
    80001238:	6902                	ld	s2,0(sp)
    8000123a:	6105                	addi	sp,sp,32
    8000123c:	8082                	ret

000000008000123e <kvminit>:
{
    8000123e:	1141                	addi	sp,sp,-16
    80001240:	e406                	sd	ra,8(sp)
    80001242:	e022                	sd	s0,0(sp)
    80001244:	0800                	addi	s0,sp,16
  kernel_pagetable = kvmmake();
    80001246:	00000097          	auipc	ra,0x0
    8000124a:	f22080e7          	jalr	-222(ra) # 80001168 <kvmmake>
    8000124e:	00008797          	auipc	a5,0x8
    80001252:	80a7b923          	sd	a0,-2030(a5) # 80008a60 <kernel_pagetable>
}
    80001256:	60a2                	ld	ra,8(sp)
    80001258:	6402                	ld	s0,0(sp)
    8000125a:	0141                	addi	sp,sp,16
    8000125c:	8082                	ret

000000008000125e <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. The mappings must exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    8000125e:	715d                	addi	sp,sp,-80
    80001260:	e486                	sd	ra,72(sp)
    80001262:	e0a2                	sd	s0,64(sp)
    80001264:	fc26                	sd	s1,56(sp)
    80001266:	f84a                	sd	s2,48(sp)
    80001268:	f44e                	sd	s3,40(sp)
    8000126a:	f052                	sd	s4,32(sp)
    8000126c:	ec56                	sd	s5,24(sp)
    8000126e:	e85a                	sd	s6,16(sp)
    80001270:	e45e                	sd	s7,8(sp)
    80001272:	0880                	addi	s0,sp,80
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    80001274:	03459793          	slli	a5,a1,0x34
    80001278:	e795                	bnez	a5,800012a4 <uvmunmap+0x46>
    8000127a:	8a2a                	mv	s4,a0
    8000127c:	892e                	mv	s2,a1
    8000127e:	8b36                	mv	s6,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001280:	0632                	slli	a2,a2,0xc
    80001282:	00b609b3          	add	s3,a2,a1
      panic("uvmunmap: walk");
    if((*pte & PTE_V) == 0)
      continue;
      /* CSE 536: removed for on-demand allocation. */
      // panic("uvmunmap: not mapped");
    if(PTE_FLAGS(*pte) == PTE_V)
    80001286:	4b85                	li	s7,1
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001288:	6a85                	lui	s5,0x1
    8000128a:	0535ea63          	bltu	a1,s3,800012de <uvmunmap+0x80>
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
  }
}
    8000128e:	60a6                	ld	ra,72(sp)
    80001290:	6406                	ld	s0,64(sp)
    80001292:	74e2                	ld	s1,56(sp)
    80001294:	7942                	ld	s2,48(sp)
    80001296:	79a2                	ld	s3,40(sp)
    80001298:	7a02                	ld	s4,32(sp)
    8000129a:	6ae2                	ld	s5,24(sp)
    8000129c:	6b42                	ld	s6,16(sp)
    8000129e:	6ba2                	ld	s7,8(sp)
    800012a0:	6161                	addi	sp,sp,80
    800012a2:	8082                	ret
    panic("uvmunmap: not aligned");
    800012a4:	00007517          	auipc	a0,0x7
    800012a8:	e5c50513          	addi	a0,a0,-420 # 80008100 <digits+0xc0>
    800012ac:	fffff097          	auipc	ra,0xfffff
    800012b0:	290080e7          	jalr	656(ra) # 8000053c <panic>
      panic("uvmunmap: walk");
    800012b4:	00007517          	auipc	a0,0x7
    800012b8:	e6450513          	addi	a0,a0,-412 # 80008118 <digits+0xd8>
    800012bc:	fffff097          	auipc	ra,0xfffff
    800012c0:	280080e7          	jalr	640(ra) # 8000053c <panic>
      panic("uvmunmap: not a leaf");
    800012c4:	00007517          	auipc	a0,0x7
    800012c8:	e6450513          	addi	a0,a0,-412 # 80008128 <digits+0xe8>
    800012cc:	fffff097          	auipc	ra,0xfffff
    800012d0:	270080e7          	jalr	624(ra) # 8000053c <panic>
    *pte = 0;
    800012d4:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800012d8:	9956                	add	s2,s2,s5
    800012da:	fb397ae3          	bgeu	s2,s3,8000128e <uvmunmap+0x30>
    if((pte = walk(pagetable, a, 0)) == 0)
    800012de:	4601                	li	a2,0
    800012e0:	85ca                	mv	a1,s2
    800012e2:	8552                	mv	a0,s4
    800012e4:	00000097          	auipc	ra,0x0
    800012e8:	ccc080e7          	jalr	-820(ra) # 80000fb0 <walk>
    800012ec:	84aa                	mv	s1,a0
    800012ee:	d179                	beqz	a0,800012b4 <uvmunmap+0x56>
    if((*pte & PTE_V) == 0)
    800012f0:	611c                	ld	a5,0(a0)
    800012f2:	0017f713          	andi	a4,a5,1
    800012f6:	d36d                	beqz	a4,800012d8 <uvmunmap+0x7a>
    if(PTE_FLAGS(*pte) == PTE_V)
    800012f8:	3ff7f713          	andi	a4,a5,1023
    800012fc:	fd7704e3          	beq	a4,s7,800012c4 <uvmunmap+0x66>
    if(do_free){
    80001300:	fc0b0ae3          	beqz	s6,800012d4 <uvmunmap+0x76>
      uint64 pa = PTE2PA(*pte);
    80001304:	83a9                	srli	a5,a5,0xa
      kfree((void*)pa);
    80001306:	00c79513          	slli	a0,a5,0xc
    8000130a:	fffff097          	auipc	ra,0xfffff
    8000130e:	6da080e7          	jalr	1754(ra) # 800009e4 <kfree>
    80001312:	b7c9                	j	800012d4 <uvmunmap+0x76>

0000000080001314 <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    80001314:	1101                	addi	sp,sp,-32
    80001316:	ec06                	sd	ra,24(sp)
    80001318:	e822                	sd	s0,16(sp)
    8000131a:	e426                	sd	s1,8(sp)
    8000131c:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    8000131e:	fffff097          	auipc	ra,0xfffff
    80001322:	7c4080e7          	jalr	1988(ra) # 80000ae2 <kalloc>
    80001326:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001328:	c519                	beqz	a0,80001336 <uvmcreate+0x22>
    return 0;
  memset(pagetable, 0, PGSIZE);
    8000132a:	6605                	lui	a2,0x1
    8000132c:	4581                	li	a1,0
    8000132e:	00000097          	auipc	ra,0x0
    80001332:	9a0080e7          	jalr	-1632(ra) # 80000cce <memset>
  return pagetable;
}
    80001336:	8526                	mv	a0,s1
    80001338:	60e2                	ld	ra,24(sp)
    8000133a:	6442                	ld	s0,16(sp)
    8000133c:	64a2                	ld	s1,8(sp)
    8000133e:	6105                	addi	sp,sp,32
    80001340:	8082                	ret

0000000080001342 <uvmfirst>:
// Load the user initcode into address 0 of pagetable,
// for the very first process.
// sz must be less than a page.
void
uvmfirst(pagetable_t pagetable, uchar *src, uint sz)
{
    80001342:	7179                	addi	sp,sp,-48
    80001344:	f406                	sd	ra,40(sp)
    80001346:	f022                	sd	s0,32(sp)
    80001348:	ec26                	sd	s1,24(sp)
    8000134a:	e84a                	sd	s2,16(sp)
    8000134c:	e44e                	sd	s3,8(sp)
    8000134e:	e052                	sd	s4,0(sp)
    80001350:	1800                	addi	s0,sp,48
  char *mem;

  if(sz >= PGSIZE)
    80001352:	6785                	lui	a5,0x1
    80001354:	04f67863          	bgeu	a2,a5,800013a4 <uvmfirst+0x62>
    80001358:	8a2a                	mv	s4,a0
    8000135a:	89ae                	mv	s3,a1
    8000135c:	84b2                	mv	s1,a2
    panic("uvmfirst: more than a page");
  mem = kalloc();
    8000135e:	fffff097          	auipc	ra,0xfffff
    80001362:	784080e7          	jalr	1924(ra) # 80000ae2 <kalloc>
    80001366:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    80001368:	6605                	lui	a2,0x1
    8000136a:	4581                	li	a1,0
    8000136c:	00000097          	auipc	ra,0x0
    80001370:	962080e7          	jalr	-1694(ra) # 80000cce <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
    80001374:	4779                	li	a4,30
    80001376:	86ca                	mv	a3,s2
    80001378:	6605                	lui	a2,0x1
    8000137a:	4581                	li	a1,0
    8000137c:	8552                	mv	a0,s4
    8000137e:	00000097          	auipc	ra,0x0
    80001382:	d1a080e7          	jalr	-742(ra) # 80001098 <mappages>
  memmove(mem, src, sz);
    80001386:	8626                	mv	a2,s1
    80001388:	85ce                	mv	a1,s3
    8000138a:	854a                	mv	a0,s2
    8000138c:	00000097          	auipc	ra,0x0
    80001390:	99e080e7          	jalr	-1634(ra) # 80000d2a <memmove>
}
    80001394:	70a2                	ld	ra,40(sp)
    80001396:	7402                	ld	s0,32(sp)
    80001398:	64e2                	ld	s1,24(sp)
    8000139a:	6942                	ld	s2,16(sp)
    8000139c:	69a2                	ld	s3,8(sp)
    8000139e:	6a02                	ld	s4,0(sp)
    800013a0:	6145                	addi	sp,sp,48
    800013a2:	8082                	ret
    panic("uvmfirst: more than a page");
    800013a4:	00007517          	auipc	a0,0x7
    800013a8:	d9c50513          	addi	a0,a0,-612 # 80008140 <digits+0x100>
    800013ac:	fffff097          	auipc	ra,0xfffff
    800013b0:	190080e7          	jalr	400(ra) # 8000053c <panic>

00000000800013b4 <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    800013b4:	1101                	addi	sp,sp,-32
    800013b6:	ec06                	sd	ra,24(sp)
    800013b8:	e822                	sd	s0,16(sp)
    800013ba:	e426                	sd	s1,8(sp)
    800013bc:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    800013be:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    800013c0:	00b67d63          	bgeu	a2,a1,800013da <uvmdealloc+0x26>
    800013c4:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    800013c6:	6785                	lui	a5,0x1
    800013c8:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    800013ca:	00f60733          	add	a4,a2,a5
    800013ce:	76fd                	lui	a3,0xfffff
    800013d0:	8f75                	and	a4,a4,a3
    800013d2:	97ae                	add	a5,a5,a1
    800013d4:	8ff5                	and	a5,a5,a3
    800013d6:	00f76863          	bltu	a4,a5,800013e6 <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    800013da:	8526                	mv	a0,s1
    800013dc:	60e2                	ld	ra,24(sp)
    800013de:	6442                	ld	s0,16(sp)
    800013e0:	64a2                	ld	s1,8(sp)
    800013e2:	6105                	addi	sp,sp,32
    800013e4:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    800013e6:	8f99                	sub	a5,a5,a4
    800013e8:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    800013ea:	4685                	li	a3,1
    800013ec:	0007861b          	sext.w	a2,a5
    800013f0:	85ba                	mv	a1,a4
    800013f2:	00000097          	auipc	ra,0x0
    800013f6:	e6c080e7          	jalr	-404(ra) # 8000125e <uvmunmap>
    800013fa:	b7c5                	j	800013da <uvmdealloc+0x26>

00000000800013fc <uvmalloc>:
  if(newsz < oldsz)
    800013fc:	0ab66563          	bltu	a2,a1,800014a6 <uvmalloc+0xaa>
{
    80001400:	7139                	addi	sp,sp,-64
    80001402:	fc06                	sd	ra,56(sp)
    80001404:	f822                	sd	s0,48(sp)
    80001406:	f426                	sd	s1,40(sp)
    80001408:	f04a                	sd	s2,32(sp)
    8000140a:	ec4e                	sd	s3,24(sp)
    8000140c:	e852                	sd	s4,16(sp)
    8000140e:	e456                	sd	s5,8(sp)
    80001410:	e05a                	sd	s6,0(sp)
    80001412:	0080                	addi	s0,sp,64
    80001414:	8aaa                	mv	s5,a0
    80001416:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    80001418:	6785                	lui	a5,0x1
    8000141a:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    8000141c:	95be                	add	a1,a1,a5
    8000141e:	77fd                	lui	a5,0xfffff
    80001420:	00f5f9b3          	and	s3,a1,a5
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001424:	08c9f363          	bgeu	s3,a2,800014aa <uvmalloc+0xae>
    80001428:	894e                	mv	s2,s3
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    8000142a:	0126eb13          	ori	s6,a3,18
    mem = kalloc();
    8000142e:	fffff097          	auipc	ra,0xfffff
    80001432:	6b4080e7          	jalr	1716(ra) # 80000ae2 <kalloc>
    80001436:	84aa                	mv	s1,a0
    if(mem == 0){
    80001438:	c51d                	beqz	a0,80001466 <uvmalloc+0x6a>
    memset(mem, 0, PGSIZE);
    8000143a:	6605                	lui	a2,0x1
    8000143c:	4581                	li	a1,0
    8000143e:	00000097          	auipc	ra,0x0
    80001442:	890080e7          	jalr	-1904(ra) # 80000cce <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    80001446:	875a                	mv	a4,s6
    80001448:	86a6                	mv	a3,s1
    8000144a:	6605                	lui	a2,0x1
    8000144c:	85ca                	mv	a1,s2
    8000144e:	8556                	mv	a0,s5
    80001450:	00000097          	auipc	ra,0x0
    80001454:	c48080e7          	jalr	-952(ra) # 80001098 <mappages>
    80001458:	e90d                	bnez	a0,8000148a <uvmalloc+0x8e>
  for(a = oldsz; a < newsz; a += PGSIZE){
    8000145a:	6785                	lui	a5,0x1
    8000145c:	993e                	add	s2,s2,a5
    8000145e:	fd4968e3          	bltu	s2,s4,8000142e <uvmalloc+0x32>
  return newsz;
    80001462:	8552                	mv	a0,s4
    80001464:	a809                	j	80001476 <uvmalloc+0x7a>
      uvmdealloc(pagetable, a, oldsz);
    80001466:	864e                	mv	a2,s3
    80001468:	85ca                	mv	a1,s2
    8000146a:	8556                	mv	a0,s5
    8000146c:	00000097          	auipc	ra,0x0
    80001470:	f48080e7          	jalr	-184(ra) # 800013b4 <uvmdealloc>
      return 0;
    80001474:	4501                	li	a0,0
}
    80001476:	70e2                	ld	ra,56(sp)
    80001478:	7442                	ld	s0,48(sp)
    8000147a:	74a2                	ld	s1,40(sp)
    8000147c:	7902                	ld	s2,32(sp)
    8000147e:	69e2                	ld	s3,24(sp)
    80001480:	6a42                	ld	s4,16(sp)
    80001482:	6aa2                	ld	s5,8(sp)
    80001484:	6b02                	ld	s6,0(sp)
    80001486:	6121                	addi	sp,sp,64
    80001488:	8082                	ret
      kfree(mem);
    8000148a:	8526                	mv	a0,s1
    8000148c:	fffff097          	auipc	ra,0xfffff
    80001490:	558080e7          	jalr	1368(ra) # 800009e4 <kfree>
      uvmdealloc(pagetable, a, oldsz);
    80001494:	864e                	mv	a2,s3
    80001496:	85ca                	mv	a1,s2
    80001498:	8556                	mv	a0,s5
    8000149a:	00000097          	auipc	ra,0x0
    8000149e:	f1a080e7          	jalr	-230(ra) # 800013b4 <uvmdealloc>
      return 0;
    800014a2:	4501                	li	a0,0
    800014a4:	bfc9                	j	80001476 <uvmalloc+0x7a>
    return oldsz;
    800014a6:	852e                	mv	a0,a1
}
    800014a8:	8082                	ret
  return newsz;
    800014aa:	8532                	mv	a0,a2
    800014ac:	b7e9                	j	80001476 <uvmalloc+0x7a>

00000000800014ae <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    800014ae:	7179                	addi	sp,sp,-48
    800014b0:	f406                	sd	ra,40(sp)
    800014b2:	f022                	sd	s0,32(sp)
    800014b4:	ec26                	sd	s1,24(sp)
    800014b6:	e84a                	sd	s2,16(sp)
    800014b8:	e44e                	sd	s3,8(sp)
    800014ba:	e052                	sd	s4,0(sp)
    800014bc:	1800                	addi	s0,sp,48
    800014be:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    800014c0:	84aa                	mv	s1,a0
    800014c2:	6905                	lui	s2,0x1
    800014c4:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800014c6:	4985                	li	s3,1
    800014c8:	a829                	j	800014e2 <freewalk+0x34>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    800014ca:	83a9                	srli	a5,a5,0xa
      freewalk((pagetable_t)child);
    800014cc:	00c79513          	slli	a0,a5,0xc
    800014d0:	00000097          	auipc	ra,0x0
    800014d4:	fde080e7          	jalr	-34(ra) # 800014ae <freewalk>
      pagetable[i] = 0;
    800014d8:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    800014dc:	04a1                	addi	s1,s1,8
    800014de:	03248163          	beq	s1,s2,80001500 <freewalk+0x52>
    pte_t pte = pagetable[i];
    800014e2:	609c                	ld	a5,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800014e4:	00f7f713          	andi	a4,a5,15
    800014e8:	ff3701e3          	beq	a4,s3,800014ca <freewalk+0x1c>
    } else if(pte & PTE_V){
    800014ec:	8b85                	andi	a5,a5,1
    800014ee:	d7fd                	beqz	a5,800014dc <freewalk+0x2e>
      panic("freewalk: leaf");
    800014f0:	00007517          	auipc	a0,0x7
    800014f4:	c7050513          	addi	a0,a0,-912 # 80008160 <digits+0x120>
    800014f8:	fffff097          	auipc	ra,0xfffff
    800014fc:	044080e7          	jalr	68(ra) # 8000053c <panic>
    }
  }
  kfree((void*)pagetable);
    80001500:	8552                	mv	a0,s4
    80001502:	fffff097          	auipc	ra,0xfffff
    80001506:	4e2080e7          	jalr	1250(ra) # 800009e4 <kfree>
}
    8000150a:	70a2                	ld	ra,40(sp)
    8000150c:	7402                	ld	s0,32(sp)
    8000150e:	64e2                	ld	s1,24(sp)
    80001510:	6942                	ld	s2,16(sp)
    80001512:	69a2                	ld	s3,8(sp)
    80001514:	6a02                	ld	s4,0(sp)
    80001516:	6145                	addi	sp,sp,48
    80001518:	8082                	ret

000000008000151a <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    8000151a:	1101                	addi	sp,sp,-32
    8000151c:	ec06                	sd	ra,24(sp)
    8000151e:	e822                	sd	s0,16(sp)
    80001520:	e426                	sd	s1,8(sp)
    80001522:	1000                	addi	s0,sp,32
    80001524:	84aa                	mv	s1,a0
  if(sz > 0)
    80001526:	e999                	bnez	a1,8000153c <uvmfree+0x22>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    80001528:	8526                	mv	a0,s1
    8000152a:	00000097          	auipc	ra,0x0
    8000152e:	f84080e7          	jalr	-124(ra) # 800014ae <freewalk>
}
    80001532:	60e2                	ld	ra,24(sp)
    80001534:	6442                	ld	s0,16(sp)
    80001536:	64a2                	ld	s1,8(sp)
    80001538:	6105                	addi	sp,sp,32
    8000153a:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    8000153c:	6785                	lui	a5,0x1
    8000153e:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80001540:	95be                	add	a1,a1,a5
    80001542:	4685                	li	a3,1
    80001544:	00c5d613          	srli	a2,a1,0xc
    80001548:	4581                	li	a1,0
    8000154a:	00000097          	auipc	ra,0x0
    8000154e:	d14080e7          	jalr	-748(ra) # 8000125e <uvmunmap>
    80001552:	bfd9                	j	80001528 <uvmfree+0xe>

0000000080001554 <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    80001554:	c679                	beqz	a2,80001622 <uvmcopy+0xce>
{
    80001556:	715d                	addi	sp,sp,-80
    80001558:	e486                	sd	ra,72(sp)
    8000155a:	e0a2                	sd	s0,64(sp)
    8000155c:	fc26                	sd	s1,56(sp)
    8000155e:	f84a                	sd	s2,48(sp)
    80001560:	f44e                	sd	s3,40(sp)
    80001562:	f052                	sd	s4,32(sp)
    80001564:	ec56                	sd	s5,24(sp)
    80001566:	e85a                	sd	s6,16(sp)
    80001568:	e45e                	sd	s7,8(sp)
    8000156a:	0880                	addi	s0,sp,80
    8000156c:	8b2a                	mv	s6,a0
    8000156e:	8aae                	mv	s5,a1
    80001570:	8a32                	mv	s4,a2
  for(i = 0; i < sz; i += PGSIZE){
    80001572:	4981                	li	s3,0
    if((pte = walk(old, i, 0)) == 0)
    80001574:	4601                	li	a2,0
    80001576:	85ce                	mv	a1,s3
    80001578:	855a                	mv	a0,s6
    8000157a:	00000097          	auipc	ra,0x0
    8000157e:	a36080e7          	jalr	-1482(ra) # 80000fb0 <walk>
    80001582:	c531                	beqz	a0,800015ce <uvmcopy+0x7a>
      panic("uvmcopy: pte should exist");
    if((*pte & PTE_V) == 0)
    80001584:	6118                	ld	a4,0(a0)
    80001586:	00177793          	andi	a5,a4,1
    8000158a:	cbb1                	beqz	a5,800015de <uvmcopy+0x8a>
      panic("uvmcopy: page not present");
    pa = PTE2PA(*pte);
    8000158c:	00a75593          	srli	a1,a4,0xa
    80001590:	00c59b93          	slli	s7,a1,0xc
    flags = PTE_FLAGS(*pte);
    80001594:	3ff77493          	andi	s1,a4,1023
    if((mem = kalloc()) == 0)
    80001598:	fffff097          	auipc	ra,0xfffff
    8000159c:	54a080e7          	jalr	1354(ra) # 80000ae2 <kalloc>
    800015a0:	892a                	mv	s2,a0
    800015a2:	c939                	beqz	a0,800015f8 <uvmcopy+0xa4>
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    800015a4:	6605                	lui	a2,0x1
    800015a6:	85de                	mv	a1,s7
    800015a8:	fffff097          	auipc	ra,0xfffff
    800015ac:	782080e7          	jalr	1922(ra) # 80000d2a <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    800015b0:	8726                	mv	a4,s1
    800015b2:	86ca                	mv	a3,s2
    800015b4:	6605                	lui	a2,0x1
    800015b6:	85ce                	mv	a1,s3
    800015b8:	8556                	mv	a0,s5
    800015ba:	00000097          	auipc	ra,0x0
    800015be:	ade080e7          	jalr	-1314(ra) # 80001098 <mappages>
    800015c2:	e515                	bnez	a0,800015ee <uvmcopy+0x9a>
  for(i = 0; i < sz; i += PGSIZE){
    800015c4:	6785                	lui	a5,0x1
    800015c6:	99be                	add	s3,s3,a5
    800015c8:	fb49e6e3          	bltu	s3,s4,80001574 <uvmcopy+0x20>
    800015cc:	a081                	j	8000160c <uvmcopy+0xb8>
      panic("uvmcopy: pte should exist");
    800015ce:	00007517          	auipc	a0,0x7
    800015d2:	ba250513          	addi	a0,a0,-1118 # 80008170 <digits+0x130>
    800015d6:	fffff097          	auipc	ra,0xfffff
    800015da:	f66080e7          	jalr	-154(ra) # 8000053c <panic>
      panic("uvmcopy: page not present");
    800015de:	00007517          	auipc	a0,0x7
    800015e2:	bb250513          	addi	a0,a0,-1102 # 80008190 <digits+0x150>
    800015e6:	fffff097          	auipc	ra,0xfffff
    800015ea:	f56080e7          	jalr	-170(ra) # 8000053c <panic>
      kfree(mem);
    800015ee:	854a                	mv	a0,s2
    800015f0:	fffff097          	auipc	ra,0xfffff
    800015f4:	3f4080e7          	jalr	1012(ra) # 800009e4 <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    800015f8:	4685                	li	a3,1
    800015fa:	00c9d613          	srli	a2,s3,0xc
    800015fe:	4581                	li	a1,0
    80001600:	8556                	mv	a0,s5
    80001602:	00000097          	auipc	ra,0x0
    80001606:	c5c080e7          	jalr	-932(ra) # 8000125e <uvmunmap>
  return -1;
    8000160a:	557d                	li	a0,-1
}
    8000160c:	60a6                	ld	ra,72(sp)
    8000160e:	6406                	ld	s0,64(sp)
    80001610:	74e2                	ld	s1,56(sp)
    80001612:	7942                	ld	s2,48(sp)
    80001614:	79a2                	ld	s3,40(sp)
    80001616:	7a02                	ld	s4,32(sp)
    80001618:	6ae2                	ld	s5,24(sp)
    8000161a:	6b42                	ld	s6,16(sp)
    8000161c:	6ba2                	ld	s7,8(sp)
    8000161e:	6161                	addi	sp,sp,80
    80001620:	8082                	ret
  return 0;
    80001622:	4501                	li	a0,0
}
    80001624:	8082                	ret

0000000080001626 <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    80001626:	1141                	addi	sp,sp,-16
    80001628:	e406                	sd	ra,8(sp)
    8000162a:	e022                	sd	s0,0(sp)
    8000162c:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    8000162e:	4601                	li	a2,0
    80001630:	00000097          	auipc	ra,0x0
    80001634:	980080e7          	jalr	-1664(ra) # 80000fb0 <walk>
  if(pte == 0)
    80001638:	c901                	beqz	a0,80001648 <uvmclear+0x22>
    panic("uvmclear");
  *pte &= ~PTE_U;
    8000163a:	611c                	ld	a5,0(a0)
    8000163c:	9bbd                	andi	a5,a5,-17
    8000163e:	e11c                	sd	a5,0(a0)
}
    80001640:	60a2                	ld	ra,8(sp)
    80001642:	6402                	ld	s0,0(sp)
    80001644:	0141                	addi	sp,sp,16
    80001646:	8082                	ret
    panic("uvmclear");
    80001648:	00007517          	auipc	a0,0x7
    8000164c:	b6850513          	addi	a0,a0,-1176 # 800081b0 <digits+0x170>
    80001650:	fffff097          	auipc	ra,0xfffff
    80001654:	eec080e7          	jalr	-276(ra) # 8000053c <panic>

0000000080001658 <uvminvalid>:

// CSE 536: mark a PTE invalid. For swapping 
// pages in and out of memory.
void
uvminvalid(pagetable_t pagetable, uint64 va)
{
    80001658:	1141                	addi	sp,sp,-16
    8000165a:	e406                	sd	ra,8(sp)
    8000165c:	e022                	sd	s0,0(sp)
    8000165e:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    80001660:	4601                	li	a2,0
    80001662:	00000097          	auipc	ra,0x0
    80001666:	94e080e7          	jalr	-1714(ra) # 80000fb0 <walk>
  if(pte == 0)
    8000166a:	c901                	beqz	a0,8000167a <uvminvalid+0x22>
    panic("uvminvalid");
  *pte &= ~PTE_V;
    8000166c:	611c                	ld	a5,0(a0)
    8000166e:	9bf9                	andi	a5,a5,-2
    80001670:	e11c                	sd	a5,0(a0)
}
    80001672:	60a2                	ld	ra,8(sp)
    80001674:	6402                	ld	s0,0(sp)
    80001676:	0141                	addi	sp,sp,16
    80001678:	8082                	ret
    panic("uvminvalid");
    8000167a:	00007517          	auipc	a0,0x7
    8000167e:	b4650513          	addi	a0,a0,-1210 # 800081c0 <digits+0x180>
    80001682:	fffff097          	auipc	ra,0xfffff
    80001686:	eba080e7          	jalr	-326(ra) # 8000053c <panic>

000000008000168a <copyout>:
int
copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    8000168a:	c6bd                	beqz	a3,800016f8 <copyout+0x6e>
{
    8000168c:	715d                	addi	sp,sp,-80
    8000168e:	e486                	sd	ra,72(sp)
    80001690:	e0a2                	sd	s0,64(sp)
    80001692:	fc26                	sd	s1,56(sp)
    80001694:	f84a                	sd	s2,48(sp)
    80001696:	f44e                	sd	s3,40(sp)
    80001698:	f052                	sd	s4,32(sp)
    8000169a:	ec56                	sd	s5,24(sp)
    8000169c:	e85a                	sd	s6,16(sp)
    8000169e:	e45e                	sd	s7,8(sp)
    800016a0:	e062                	sd	s8,0(sp)
    800016a2:	0880                	addi	s0,sp,80
    800016a4:	8b2a                	mv	s6,a0
    800016a6:	8c2e                	mv	s8,a1
    800016a8:	8a32                	mv	s4,a2
    800016aa:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(dstva);
    800016ac:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if (pa0 == 0){
      return -1;
    }
    n = PGSIZE - (dstva - va0);
    800016ae:	6a85                	lui	s5,0x1
    800016b0:	a015                	j	800016d4 <copyout+0x4a>
    if(n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    800016b2:	9562                	add	a0,a0,s8
    800016b4:	0004861b          	sext.w	a2,s1
    800016b8:	85d2                	mv	a1,s4
    800016ba:	41250533          	sub	a0,a0,s2
    800016be:	fffff097          	auipc	ra,0xfffff
    800016c2:	66c080e7          	jalr	1644(ra) # 80000d2a <memmove>

    len -= n;
    800016c6:	409989b3          	sub	s3,s3,s1
    src += n;
    800016ca:	9a26                	add	s4,s4,s1
    dstva = va0 + PGSIZE;
    800016cc:	01590c33          	add	s8,s2,s5
  while(len > 0){
    800016d0:	02098263          	beqz	s3,800016f4 <copyout+0x6a>
    va0 = PGROUNDDOWN(dstva);
    800016d4:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    800016d8:	85ca                	mv	a1,s2
    800016da:	855a                	mv	a0,s6
    800016dc:	00000097          	auipc	ra,0x0
    800016e0:	97a080e7          	jalr	-1670(ra) # 80001056 <walkaddr>
    if (pa0 == 0){
    800016e4:	cd01                	beqz	a0,800016fc <copyout+0x72>
    n = PGSIZE - (dstva - va0);
    800016e6:	418904b3          	sub	s1,s2,s8
    800016ea:	94d6                	add	s1,s1,s5
    800016ec:	fc99f3e3          	bgeu	s3,s1,800016b2 <copyout+0x28>
    800016f0:	84ce                	mv	s1,s3
    800016f2:	b7c1                	j	800016b2 <copyout+0x28>
  }
  return 0;
    800016f4:	4501                	li	a0,0
    800016f6:	a021                	j	800016fe <copyout+0x74>
    800016f8:	4501                	li	a0,0
}
    800016fa:	8082                	ret
      return -1;
    800016fc:	557d                	li	a0,-1
}
    800016fe:	60a6                	ld	ra,72(sp)
    80001700:	6406                	ld	s0,64(sp)
    80001702:	74e2                	ld	s1,56(sp)
    80001704:	7942                	ld	s2,48(sp)
    80001706:	79a2                	ld	s3,40(sp)
    80001708:	7a02                	ld	s4,32(sp)
    8000170a:	6ae2                	ld	s5,24(sp)
    8000170c:	6b42                	ld	s6,16(sp)
    8000170e:	6ba2                	ld	s7,8(sp)
    80001710:	6c02                	ld	s8,0(sp)
    80001712:	6161                	addi	sp,sp,80
    80001714:	8082                	ret

0000000080001716 <copyin>:
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    80001716:	caa5                	beqz	a3,80001786 <copyin+0x70>
{
    80001718:	715d                	addi	sp,sp,-80
    8000171a:	e486                	sd	ra,72(sp)
    8000171c:	e0a2                	sd	s0,64(sp)
    8000171e:	fc26                	sd	s1,56(sp)
    80001720:	f84a                	sd	s2,48(sp)
    80001722:	f44e                	sd	s3,40(sp)
    80001724:	f052                	sd	s4,32(sp)
    80001726:	ec56                	sd	s5,24(sp)
    80001728:	e85a                	sd	s6,16(sp)
    8000172a:	e45e                	sd	s7,8(sp)
    8000172c:	e062                	sd	s8,0(sp)
    8000172e:	0880                	addi	s0,sp,80
    80001730:	8b2a                	mv	s6,a0
    80001732:	8a2e                	mv	s4,a1
    80001734:	8c32                	mv	s8,a2
    80001736:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    80001738:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    8000173a:	6a85                	lui	s5,0x1
    8000173c:	a01d                	j	80001762 <copyin+0x4c>
    if(n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    8000173e:	018505b3          	add	a1,a0,s8
    80001742:	0004861b          	sext.w	a2,s1
    80001746:	412585b3          	sub	a1,a1,s2
    8000174a:	8552                	mv	a0,s4
    8000174c:	fffff097          	auipc	ra,0xfffff
    80001750:	5de080e7          	jalr	1502(ra) # 80000d2a <memmove>

    len -= n;
    80001754:	409989b3          	sub	s3,s3,s1
    dst += n;
    80001758:	9a26                	add	s4,s4,s1
    srcva = va0 + PGSIZE;
    8000175a:	01590c33          	add	s8,s2,s5
  while(len > 0){
    8000175e:	02098263          	beqz	s3,80001782 <copyin+0x6c>
    va0 = PGROUNDDOWN(srcva);
    80001762:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    80001766:	85ca                	mv	a1,s2
    80001768:	855a                	mv	a0,s6
    8000176a:	00000097          	auipc	ra,0x0
    8000176e:	8ec080e7          	jalr	-1812(ra) # 80001056 <walkaddr>
    if(pa0 == 0)
    80001772:	cd01                	beqz	a0,8000178a <copyin+0x74>
    n = PGSIZE - (srcva - va0);
    80001774:	418904b3          	sub	s1,s2,s8
    80001778:	94d6                	add	s1,s1,s5
    8000177a:	fc99f2e3          	bgeu	s3,s1,8000173e <copyin+0x28>
    8000177e:	84ce                	mv	s1,s3
    80001780:	bf7d                	j	8000173e <copyin+0x28>
  }
  return 0;
    80001782:	4501                	li	a0,0
    80001784:	a021                	j	8000178c <copyin+0x76>
    80001786:	4501                	li	a0,0
}
    80001788:	8082                	ret
      return -1;
    8000178a:	557d                	li	a0,-1
}
    8000178c:	60a6                	ld	ra,72(sp)
    8000178e:	6406                	ld	s0,64(sp)
    80001790:	74e2                	ld	s1,56(sp)
    80001792:	7942                	ld	s2,48(sp)
    80001794:	79a2                	ld	s3,40(sp)
    80001796:	7a02                	ld	s4,32(sp)
    80001798:	6ae2                	ld	s5,24(sp)
    8000179a:	6b42                	ld	s6,16(sp)
    8000179c:	6ba2                	ld	s7,8(sp)
    8000179e:	6c02                	ld	s8,0(sp)
    800017a0:	6161                	addi	sp,sp,80
    800017a2:	8082                	ret

00000000800017a4 <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    800017a4:	c2dd                	beqz	a3,8000184a <copyinstr+0xa6>
{
    800017a6:	715d                	addi	sp,sp,-80
    800017a8:	e486                	sd	ra,72(sp)
    800017aa:	e0a2                	sd	s0,64(sp)
    800017ac:	fc26                	sd	s1,56(sp)
    800017ae:	f84a                	sd	s2,48(sp)
    800017b0:	f44e                	sd	s3,40(sp)
    800017b2:	f052                	sd	s4,32(sp)
    800017b4:	ec56                	sd	s5,24(sp)
    800017b6:	e85a                	sd	s6,16(sp)
    800017b8:	e45e                	sd	s7,8(sp)
    800017ba:	0880                	addi	s0,sp,80
    800017bc:	8a2a                	mv	s4,a0
    800017be:	8b2e                	mv	s6,a1
    800017c0:	8bb2                	mv	s7,a2
    800017c2:	84b6                	mv	s1,a3
    va0 = PGROUNDDOWN(srcva);
    800017c4:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    800017c6:	6985                	lui	s3,0x1
    800017c8:	a02d                	j	800017f2 <copyinstr+0x4e>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    800017ca:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    800017ce:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    800017d0:	37fd                	addiw	a5,a5,-1
    800017d2:	0007851b          	sext.w	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    800017d6:	60a6                	ld	ra,72(sp)
    800017d8:	6406                	ld	s0,64(sp)
    800017da:	74e2                	ld	s1,56(sp)
    800017dc:	7942                	ld	s2,48(sp)
    800017de:	79a2                	ld	s3,40(sp)
    800017e0:	7a02                	ld	s4,32(sp)
    800017e2:	6ae2                	ld	s5,24(sp)
    800017e4:	6b42                	ld	s6,16(sp)
    800017e6:	6ba2                	ld	s7,8(sp)
    800017e8:	6161                	addi	sp,sp,80
    800017ea:	8082                	ret
    srcva = va0 + PGSIZE;
    800017ec:	01390bb3          	add	s7,s2,s3
  while(got_null == 0 && max > 0){
    800017f0:	c8a9                	beqz	s1,80001842 <copyinstr+0x9e>
    va0 = PGROUNDDOWN(srcva);
    800017f2:	015bf933          	and	s2,s7,s5
    pa0 = walkaddr(pagetable, va0);
    800017f6:	85ca                	mv	a1,s2
    800017f8:	8552                	mv	a0,s4
    800017fa:	00000097          	auipc	ra,0x0
    800017fe:	85c080e7          	jalr	-1956(ra) # 80001056 <walkaddr>
    if(pa0 == 0)
    80001802:	c131                	beqz	a0,80001846 <copyinstr+0xa2>
    n = PGSIZE - (srcva - va0);
    80001804:	417906b3          	sub	a3,s2,s7
    80001808:	96ce                	add	a3,a3,s3
    8000180a:	00d4f363          	bgeu	s1,a3,80001810 <copyinstr+0x6c>
    8000180e:	86a6                	mv	a3,s1
    char *p = (char *) (pa0 + (srcva - va0));
    80001810:	955e                	add	a0,a0,s7
    80001812:	41250533          	sub	a0,a0,s2
    while(n > 0){
    80001816:	daf9                	beqz	a3,800017ec <copyinstr+0x48>
    80001818:	87da                	mv	a5,s6
    8000181a:	885a                	mv	a6,s6
      if(*p == '\0'){
    8000181c:	41650633          	sub	a2,a0,s6
    while(n > 0){
    80001820:	96da                	add	a3,a3,s6
    80001822:	85be                	mv	a1,a5
      if(*p == '\0'){
    80001824:	00f60733          	add	a4,a2,a5
    80001828:	00074703          	lbu	a4,0(a4) # fffffffffffff000 <end+0xffffffff7ffdd108>
    8000182c:	df59                	beqz	a4,800017ca <copyinstr+0x26>
        *dst = *p;
    8000182e:	00e78023          	sb	a4,0(a5)
      dst++;
    80001832:	0785                	addi	a5,a5,1
    while(n > 0){
    80001834:	fed797e3          	bne	a5,a3,80001822 <copyinstr+0x7e>
    80001838:	14fd                	addi	s1,s1,-1
    8000183a:	94c2                	add	s1,s1,a6
      --max;
    8000183c:	8c8d                	sub	s1,s1,a1
      dst++;
    8000183e:	8b3e                	mv	s6,a5
    80001840:	b775                	j	800017ec <copyinstr+0x48>
    80001842:	4781                	li	a5,0
    80001844:	b771                	j	800017d0 <copyinstr+0x2c>
      return -1;
    80001846:	557d                	li	a0,-1
    80001848:	b779                	j	800017d6 <copyinstr+0x32>
  int got_null = 0;
    8000184a:	4781                	li	a5,0
  if(got_null){
    8000184c:	37fd                	addiw	a5,a5,-1
    8000184e:	0007851b          	sext.w	a0,a5
}
    80001852:	8082                	ret

0000000080001854 <proc_mapstacks>:
// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void
proc_mapstacks(pagetable_t kpgtbl)
{
    80001854:	7139                	addi	sp,sp,-64
    80001856:	fc06                	sd	ra,56(sp)
    80001858:	f822                	sd	s0,48(sp)
    8000185a:	f426                	sd	s1,40(sp)
    8000185c:	f04a                	sd	s2,32(sp)
    8000185e:	ec4e                	sd	s3,24(sp)
    80001860:	e852                	sd	s4,16(sp)
    80001862:	e456                	sd	s5,8(sp)
    80001864:	e05a                	sd	s6,0(sp)
    80001866:	0080                	addi	s0,sp,64
    80001868:	89aa                	mv	s3,a0
  struct proc *p;
  
  for(p = proc; p < &proc[NPROC]; p++) {
    8000186a:	00010497          	auipc	s1,0x10
    8000186e:	8a648493          	addi	s1,s1,-1882 # 80011110 <proc>
    char *pa = kalloc();
    if(pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int) (p - proc));
    80001872:	8b26                	mv	s6,s1
    80001874:	00006a97          	auipc	s5,0x6
    80001878:	78ca8a93          	addi	s5,s5,1932 # 80008000 <etext>
    8000187c:	04000937          	lui	s2,0x4000
    80001880:	197d                	addi	s2,s2,-1 # 3ffffff <_entry-0x7c000001>
    80001882:	0932                	slli	s2,s2,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80001884:	00015a17          	auipc	s4,0x15
    80001888:	28ca0a13          	addi	s4,s4,652 # 80016b10 <tickslock>
    char *pa = kalloc();
    8000188c:	fffff097          	auipc	ra,0xfffff
    80001890:	256080e7          	jalr	598(ra) # 80000ae2 <kalloc>
    80001894:	862a                	mv	a2,a0
    if(pa == 0)
    80001896:	c131                	beqz	a0,800018da <proc_mapstacks+0x86>
    uint64 va = KSTACK((int) (p - proc));
    80001898:	416485b3          	sub	a1,s1,s6
    8000189c:	858d                	srai	a1,a1,0x3
    8000189e:	000ab783          	ld	a5,0(s5)
    800018a2:	02f585b3          	mul	a1,a1,a5
    800018a6:	2585                	addiw	a1,a1,1
    800018a8:	00d5959b          	slliw	a1,a1,0xd
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    800018ac:	4719                	li	a4,6
    800018ae:	6685                	lui	a3,0x1
    800018b0:	40b905b3          	sub	a1,s2,a1
    800018b4:	854e                	mv	a0,s3
    800018b6:	00000097          	auipc	ra,0x0
    800018ba:	882080e7          	jalr	-1918(ra) # 80001138 <kvmmap>
  for(p = proc; p < &proc[NPROC]; p++) {
    800018be:	16848493          	addi	s1,s1,360
    800018c2:	fd4495e3          	bne	s1,s4,8000188c <proc_mapstacks+0x38>
  }
}
    800018c6:	70e2                	ld	ra,56(sp)
    800018c8:	7442                	ld	s0,48(sp)
    800018ca:	74a2                	ld	s1,40(sp)
    800018cc:	7902                	ld	s2,32(sp)
    800018ce:	69e2                	ld	s3,24(sp)
    800018d0:	6a42                	ld	s4,16(sp)
    800018d2:	6aa2                	ld	s5,8(sp)
    800018d4:	6b02                	ld	s6,0(sp)
    800018d6:	6121                	addi	sp,sp,64
    800018d8:	8082                	ret
      panic("kalloc");
    800018da:	00007517          	auipc	a0,0x7
    800018de:	8f650513          	addi	a0,a0,-1802 # 800081d0 <digits+0x190>
    800018e2:	fffff097          	auipc	ra,0xfffff
    800018e6:	c5a080e7          	jalr	-934(ra) # 8000053c <panic>

00000000800018ea <procinit>:

// initialize the proc table.
void
procinit(void)
{
    800018ea:	7139                	addi	sp,sp,-64
    800018ec:	fc06                	sd	ra,56(sp)
    800018ee:	f822                	sd	s0,48(sp)
    800018f0:	f426                	sd	s1,40(sp)
    800018f2:	f04a                	sd	s2,32(sp)
    800018f4:	ec4e                	sd	s3,24(sp)
    800018f6:	e852                	sd	s4,16(sp)
    800018f8:	e456                	sd	s5,8(sp)
    800018fa:	e05a                	sd	s6,0(sp)
    800018fc:	0080                	addi	s0,sp,64
  struct proc *p;
  
  initlock(&pid_lock, "nextpid");
    800018fe:	00007597          	auipc	a1,0x7
    80001902:	8da58593          	addi	a1,a1,-1830 # 800081d8 <digits+0x198>
    80001906:	0000f517          	auipc	a0,0xf
    8000190a:	3da50513          	addi	a0,a0,986 # 80010ce0 <pid_lock>
    8000190e:	fffff097          	auipc	ra,0xfffff
    80001912:	234080e7          	jalr	564(ra) # 80000b42 <initlock>
  initlock(&wait_lock, "wait_lock");
    80001916:	00007597          	auipc	a1,0x7
    8000191a:	8ca58593          	addi	a1,a1,-1846 # 800081e0 <digits+0x1a0>
    8000191e:	0000f517          	auipc	a0,0xf
    80001922:	3da50513          	addi	a0,a0,986 # 80010cf8 <wait_lock>
    80001926:	fffff097          	auipc	ra,0xfffff
    8000192a:	21c080e7          	jalr	540(ra) # 80000b42 <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    8000192e:	0000f497          	auipc	s1,0xf
    80001932:	7e248493          	addi	s1,s1,2018 # 80011110 <proc>
      initlock(&p->lock, "proc");
    80001936:	00007b17          	auipc	s6,0x7
    8000193a:	8bab0b13          	addi	s6,s6,-1862 # 800081f0 <digits+0x1b0>
      p->state = UNUSED;
      p->kstack = KSTACK((int) (p - proc));
    8000193e:	8aa6                	mv	s5,s1
    80001940:	00006a17          	auipc	s4,0x6
    80001944:	6c0a0a13          	addi	s4,s4,1728 # 80008000 <etext>
    80001948:	04000937          	lui	s2,0x4000
    8000194c:	197d                	addi	s2,s2,-1 # 3ffffff <_entry-0x7c000001>
    8000194e:	0932                	slli	s2,s2,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80001950:	00015997          	auipc	s3,0x15
    80001954:	1c098993          	addi	s3,s3,448 # 80016b10 <tickslock>
      initlock(&p->lock, "proc");
    80001958:	85da                	mv	a1,s6
    8000195a:	8526                	mv	a0,s1
    8000195c:	fffff097          	auipc	ra,0xfffff
    80001960:	1e6080e7          	jalr	486(ra) # 80000b42 <initlock>
      p->state = UNUSED;
    80001964:	0004ac23          	sw	zero,24(s1)
      p->kstack = KSTACK((int) (p - proc));
    80001968:	415487b3          	sub	a5,s1,s5
    8000196c:	878d                	srai	a5,a5,0x3
    8000196e:	000a3703          	ld	a4,0(s4)
    80001972:	02e787b3          	mul	a5,a5,a4
    80001976:	2785                	addiw	a5,a5,1
    80001978:	00d7979b          	slliw	a5,a5,0xd
    8000197c:	40f907b3          	sub	a5,s2,a5
    80001980:	e0bc                	sd	a5,64(s1)
  for(p = proc; p < &proc[NPROC]; p++) {
    80001982:	16848493          	addi	s1,s1,360
    80001986:	fd3499e3          	bne	s1,s3,80001958 <procinit+0x6e>
  }
}
    8000198a:	70e2                	ld	ra,56(sp)
    8000198c:	7442                	ld	s0,48(sp)
    8000198e:	74a2                	ld	s1,40(sp)
    80001990:	7902                	ld	s2,32(sp)
    80001992:	69e2                	ld	s3,24(sp)
    80001994:	6a42                	ld	s4,16(sp)
    80001996:	6aa2                	ld	s5,8(sp)
    80001998:	6b02                	ld	s6,0(sp)
    8000199a:	6121                	addi	sp,sp,64
    8000199c:	8082                	ret

000000008000199e <cpuid>:
// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int
cpuid()
{
    8000199e:	1141                	addi	sp,sp,-16
    800019a0:	e422                	sd	s0,8(sp)
    800019a2:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    800019a4:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    800019a6:	2501                	sext.w	a0,a0
    800019a8:	6422                	ld	s0,8(sp)
    800019aa:	0141                	addi	sp,sp,16
    800019ac:	8082                	ret

00000000800019ae <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu*
mycpu(void)
{
    800019ae:	1141                	addi	sp,sp,-16
    800019b0:	e422                	sd	s0,8(sp)
    800019b2:	0800                	addi	s0,sp,16
    800019b4:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    800019b6:	2781                	sext.w	a5,a5
    800019b8:	079e                	slli	a5,a5,0x7
  return c;
}
    800019ba:	0000f517          	auipc	a0,0xf
    800019be:	35650513          	addi	a0,a0,854 # 80010d10 <cpus>
    800019c2:	953e                	add	a0,a0,a5
    800019c4:	6422                	ld	s0,8(sp)
    800019c6:	0141                	addi	sp,sp,16
    800019c8:	8082                	ret

00000000800019ca <myproc>:

// Return the current struct proc *, or zero if none.
struct proc*
myproc(void)
{
    800019ca:	1101                	addi	sp,sp,-32
    800019cc:	ec06                	sd	ra,24(sp)
    800019ce:	e822                	sd	s0,16(sp)
    800019d0:	e426                	sd	s1,8(sp)
    800019d2:	1000                	addi	s0,sp,32
  push_off();
    800019d4:	fffff097          	auipc	ra,0xfffff
    800019d8:	1b2080e7          	jalr	434(ra) # 80000b86 <push_off>
    800019dc:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    800019de:	2781                	sext.w	a5,a5
    800019e0:	079e                	slli	a5,a5,0x7
    800019e2:	0000f717          	auipc	a4,0xf
    800019e6:	2fe70713          	addi	a4,a4,766 # 80010ce0 <pid_lock>
    800019ea:	97ba                	add	a5,a5,a4
    800019ec:	7b84                	ld	s1,48(a5)
  pop_off();
    800019ee:	fffff097          	auipc	ra,0xfffff
    800019f2:	238080e7          	jalr	568(ra) # 80000c26 <pop_off>
  return p;
}
    800019f6:	8526                	mv	a0,s1
    800019f8:	60e2                	ld	ra,24(sp)
    800019fa:	6442                	ld	s0,16(sp)
    800019fc:	64a2                	ld	s1,8(sp)
    800019fe:	6105                	addi	sp,sp,32
    80001a00:	8082                	ret

0000000080001a02 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
    80001a02:	1141                	addi	sp,sp,-16
    80001a04:	e406                	sd	ra,8(sp)
    80001a06:	e022                	sd	s0,0(sp)
    80001a08:	0800                	addi	s0,sp,16
  static int first = 1;

  // Still holding p->lock from scheduler.
  release(&myproc()->lock);
    80001a0a:	00000097          	auipc	ra,0x0
    80001a0e:	fc0080e7          	jalr	-64(ra) # 800019ca <myproc>
    80001a12:	fffff097          	auipc	ra,0xfffff
    80001a16:	274080e7          	jalr	628(ra) # 80000c86 <release>

  if (first) {
    80001a1a:	00007797          	auipc	a5,0x7
    80001a1e:	fd67a783          	lw	a5,-42(a5) # 800089f0 <first.1>
    80001a22:	eb89                	bnez	a5,80001a34 <forkret+0x32>
    // be run from main().
    first = 0;
    fsinit(ROOTDEV);
  }

  usertrapret();
    80001a24:	00001097          	auipc	ra,0x1
    80001a28:	c64080e7          	jalr	-924(ra) # 80002688 <usertrapret>
}
    80001a2c:	60a2                	ld	ra,8(sp)
    80001a2e:	6402                	ld	s0,0(sp)
    80001a30:	0141                	addi	sp,sp,16
    80001a32:	8082                	ret
    first = 0;
    80001a34:	00007797          	auipc	a5,0x7
    80001a38:	fa07ae23          	sw	zero,-68(a5) # 800089f0 <first.1>
    fsinit(ROOTDEV);
    80001a3c:	4505                	li	a0,1
    80001a3e:	00002097          	auipc	ra,0x2
    80001a42:	9a8080e7          	jalr	-1624(ra) # 800033e6 <fsinit>
    80001a46:	bff9                	j	80001a24 <forkret+0x22>

0000000080001a48 <allocpid>:
{
    80001a48:	1101                	addi	sp,sp,-32
    80001a4a:	ec06                	sd	ra,24(sp)
    80001a4c:	e822                	sd	s0,16(sp)
    80001a4e:	e426                	sd	s1,8(sp)
    80001a50:	e04a                	sd	s2,0(sp)
    80001a52:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001a54:	0000f917          	auipc	s2,0xf
    80001a58:	28c90913          	addi	s2,s2,652 # 80010ce0 <pid_lock>
    80001a5c:	854a                	mv	a0,s2
    80001a5e:	fffff097          	auipc	ra,0xfffff
    80001a62:	174080e7          	jalr	372(ra) # 80000bd2 <acquire>
  pid = nextpid;
    80001a66:	00007797          	auipc	a5,0x7
    80001a6a:	f8e78793          	addi	a5,a5,-114 # 800089f4 <nextpid>
    80001a6e:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001a70:	0014871b          	addiw	a4,s1,1
    80001a74:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001a76:	854a                	mv	a0,s2
    80001a78:	fffff097          	auipc	ra,0xfffff
    80001a7c:	20e080e7          	jalr	526(ra) # 80000c86 <release>
}
    80001a80:	8526                	mv	a0,s1
    80001a82:	60e2                	ld	ra,24(sp)
    80001a84:	6442                	ld	s0,16(sp)
    80001a86:	64a2                	ld	s1,8(sp)
    80001a88:	6902                	ld	s2,0(sp)
    80001a8a:	6105                	addi	sp,sp,32
    80001a8c:	8082                	ret

0000000080001a8e <proc_pagetable>:
{
    80001a8e:	1101                	addi	sp,sp,-32
    80001a90:	ec06                	sd	ra,24(sp)
    80001a92:	e822                	sd	s0,16(sp)
    80001a94:	e426                	sd	s1,8(sp)
    80001a96:	e04a                	sd	s2,0(sp)
    80001a98:	1000                	addi	s0,sp,32
    80001a9a:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001a9c:	00000097          	auipc	ra,0x0
    80001aa0:	878080e7          	jalr	-1928(ra) # 80001314 <uvmcreate>
    80001aa4:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001aa6:	c121                	beqz	a0,80001ae6 <proc_pagetable+0x58>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001aa8:	4729                	li	a4,10
    80001aaa:	00005697          	auipc	a3,0x5
    80001aae:	55668693          	addi	a3,a3,1366 # 80007000 <_trampoline>
    80001ab2:	6605                	lui	a2,0x1
    80001ab4:	040005b7          	lui	a1,0x4000
    80001ab8:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001aba:	05b2                	slli	a1,a1,0xc
    80001abc:	fffff097          	auipc	ra,0xfffff
    80001ac0:	5dc080e7          	jalr	1500(ra) # 80001098 <mappages>
    80001ac4:	02054863          	bltz	a0,80001af4 <proc_pagetable+0x66>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    80001ac8:	4719                	li	a4,6
    80001aca:	05893683          	ld	a3,88(s2)
    80001ace:	6605                	lui	a2,0x1
    80001ad0:	020005b7          	lui	a1,0x2000
    80001ad4:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001ad6:	05b6                	slli	a1,a1,0xd
    80001ad8:	8526                	mv	a0,s1
    80001ada:	fffff097          	auipc	ra,0xfffff
    80001ade:	5be080e7          	jalr	1470(ra) # 80001098 <mappages>
    80001ae2:	02054163          	bltz	a0,80001b04 <proc_pagetable+0x76>
}
    80001ae6:	8526                	mv	a0,s1
    80001ae8:	60e2                	ld	ra,24(sp)
    80001aea:	6442                	ld	s0,16(sp)
    80001aec:	64a2                	ld	s1,8(sp)
    80001aee:	6902                	ld	s2,0(sp)
    80001af0:	6105                	addi	sp,sp,32
    80001af2:	8082                	ret
    uvmfree(pagetable, 0);
    80001af4:	4581                	li	a1,0
    80001af6:	8526                	mv	a0,s1
    80001af8:	00000097          	auipc	ra,0x0
    80001afc:	a22080e7          	jalr	-1502(ra) # 8000151a <uvmfree>
    return 0;
    80001b00:	4481                	li	s1,0
    80001b02:	b7d5                	j	80001ae6 <proc_pagetable+0x58>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001b04:	4681                	li	a3,0
    80001b06:	4605                	li	a2,1
    80001b08:	040005b7          	lui	a1,0x4000
    80001b0c:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001b0e:	05b2                	slli	a1,a1,0xc
    80001b10:	8526                	mv	a0,s1
    80001b12:	fffff097          	auipc	ra,0xfffff
    80001b16:	74c080e7          	jalr	1868(ra) # 8000125e <uvmunmap>
    uvmfree(pagetable, 0);
    80001b1a:	4581                	li	a1,0
    80001b1c:	8526                	mv	a0,s1
    80001b1e:	00000097          	auipc	ra,0x0
    80001b22:	9fc080e7          	jalr	-1540(ra) # 8000151a <uvmfree>
    return 0;
    80001b26:	4481                	li	s1,0
    80001b28:	bf7d                	j	80001ae6 <proc_pagetable+0x58>

0000000080001b2a <proc_freepagetable>:
{
    80001b2a:	1101                	addi	sp,sp,-32
    80001b2c:	ec06                	sd	ra,24(sp)
    80001b2e:	e822                	sd	s0,16(sp)
    80001b30:	e426                	sd	s1,8(sp)
    80001b32:	e04a                	sd	s2,0(sp)
    80001b34:	1000                	addi	s0,sp,32
    80001b36:	84aa                	mv	s1,a0
    80001b38:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001b3a:	4681                	li	a3,0
    80001b3c:	4605                	li	a2,1
    80001b3e:	040005b7          	lui	a1,0x4000
    80001b42:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001b44:	05b2                	slli	a1,a1,0xc
    80001b46:	fffff097          	auipc	ra,0xfffff
    80001b4a:	718080e7          	jalr	1816(ra) # 8000125e <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001b4e:	4681                	li	a3,0
    80001b50:	4605                	li	a2,1
    80001b52:	020005b7          	lui	a1,0x2000
    80001b56:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001b58:	05b6                	slli	a1,a1,0xd
    80001b5a:	8526                	mv	a0,s1
    80001b5c:	fffff097          	auipc	ra,0xfffff
    80001b60:	702080e7          	jalr	1794(ra) # 8000125e <uvmunmap>
  uvmfree(pagetable, sz);
    80001b64:	85ca                	mv	a1,s2
    80001b66:	8526                	mv	a0,s1
    80001b68:	00000097          	auipc	ra,0x0
    80001b6c:	9b2080e7          	jalr	-1614(ra) # 8000151a <uvmfree>
}
    80001b70:	60e2                	ld	ra,24(sp)
    80001b72:	6442                	ld	s0,16(sp)
    80001b74:	64a2                	ld	s1,8(sp)
    80001b76:	6902                	ld	s2,0(sp)
    80001b78:	6105                	addi	sp,sp,32
    80001b7a:	8082                	ret

0000000080001b7c <freeproc>:
{
    80001b7c:	1101                	addi	sp,sp,-32
    80001b7e:	ec06                	sd	ra,24(sp)
    80001b80:	e822                	sd	s0,16(sp)
    80001b82:	e426                	sd	s1,8(sp)
    80001b84:	1000                	addi	s0,sp,32
    80001b86:	84aa                	mv	s1,a0
  if(p->trapframe)
    80001b88:	6d28                	ld	a0,88(a0)
    80001b8a:	c509                	beqz	a0,80001b94 <freeproc+0x18>
    kfree((void*)p->trapframe);
    80001b8c:	fffff097          	auipc	ra,0xfffff
    80001b90:	e58080e7          	jalr	-424(ra) # 800009e4 <kfree>
  p->trapframe = 0;
    80001b94:	0404bc23          	sd	zero,88(s1)
  if(p->pagetable)
    80001b98:	68a8                	ld	a0,80(s1)
    80001b9a:	c511                	beqz	a0,80001ba6 <freeproc+0x2a>
    proc_freepagetable(p->pagetable, p->sz);
    80001b9c:	64ac                	ld	a1,72(s1)
    80001b9e:	00000097          	auipc	ra,0x0
    80001ba2:	f8c080e7          	jalr	-116(ra) # 80001b2a <proc_freepagetable>
  p->pagetable = 0;
    80001ba6:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80001baa:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80001bae:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    80001bb2:	0204bc23          	sd	zero,56(s1)
  p->name[0] = 0;
    80001bb6:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80001bba:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80001bbe:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80001bc2:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    80001bc6:	0004ac23          	sw	zero,24(s1)
}
    80001bca:	60e2                	ld	ra,24(sp)
    80001bcc:	6442                	ld	s0,16(sp)
    80001bce:	64a2                	ld	s1,8(sp)
    80001bd0:	6105                	addi	sp,sp,32
    80001bd2:	8082                	ret

0000000080001bd4 <allocproc>:
{
    80001bd4:	1101                	addi	sp,sp,-32
    80001bd6:	ec06                	sd	ra,24(sp)
    80001bd8:	e822                	sd	s0,16(sp)
    80001bda:	e426                	sd	s1,8(sp)
    80001bdc:	e04a                	sd	s2,0(sp)
    80001bde:	1000                	addi	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    80001be0:	0000f497          	auipc	s1,0xf
    80001be4:	53048493          	addi	s1,s1,1328 # 80011110 <proc>
    80001be8:	00015917          	auipc	s2,0x15
    80001bec:	f2890913          	addi	s2,s2,-216 # 80016b10 <tickslock>
    acquire(&p->lock);
    80001bf0:	8526                	mv	a0,s1
    80001bf2:	fffff097          	auipc	ra,0xfffff
    80001bf6:	fe0080e7          	jalr	-32(ra) # 80000bd2 <acquire>
    if(p->state == UNUSED) {
    80001bfa:	4c9c                	lw	a5,24(s1)
    80001bfc:	cf81                	beqz	a5,80001c14 <allocproc+0x40>
      release(&p->lock);
    80001bfe:	8526                	mv	a0,s1
    80001c00:	fffff097          	auipc	ra,0xfffff
    80001c04:	086080e7          	jalr	134(ra) # 80000c86 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001c08:	16848493          	addi	s1,s1,360
    80001c0c:	ff2492e3          	bne	s1,s2,80001bf0 <allocproc+0x1c>
  return 0;
    80001c10:	4481                	li	s1,0
    80001c12:	a889                	j	80001c64 <allocproc+0x90>
  p->pid = allocpid();
    80001c14:	00000097          	auipc	ra,0x0
    80001c18:	e34080e7          	jalr	-460(ra) # 80001a48 <allocpid>
    80001c1c:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001c1e:	4785                	li	a5,1
    80001c20:	cc9c                	sw	a5,24(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    80001c22:	fffff097          	auipc	ra,0xfffff
    80001c26:	ec0080e7          	jalr	-320(ra) # 80000ae2 <kalloc>
    80001c2a:	892a                	mv	s2,a0
    80001c2c:	eca8                	sd	a0,88(s1)
    80001c2e:	c131                	beqz	a0,80001c72 <allocproc+0x9e>
  p->pagetable = proc_pagetable(p);
    80001c30:	8526                	mv	a0,s1
    80001c32:	00000097          	auipc	ra,0x0
    80001c36:	e5c080e7          	jalr	-420(ra) # 80001a8e <proc_pagetable>
    80001c3a:	892a                	mv	s2,a0
    80001c3c:	e8a8                	sd	a0,80(s1)
  if(p->pagetable == 0){
    80001c3e:	c531                	beqz	a0,80001c8a <allocproc+0xb6>
  memset(&p->context, 0, sizeof(p->context));
    80001c40:	07000613          	li	a2,112
    80001c44:	4581                	li	a1,0
    80001c46:	06048513          	addi	a0,s1,96
    80001c4a:	fffff097          	auipc	ra,0xfffff
    80001c4e:	084080e7          	jalr	132(ra) # 80000cce <memset>
  p->context.ra = (uint64)forkret;
    80001c52:	00000797          	auipc	a5,0x0
    80001c56:	db078793          	addi	a5,a5,-592 # 80001a02 <forkret>
    80001c5a:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001c5c:	60bc                	ld	a5,64(s1)
    80001c5e:	6705                	lui	a4,0x1
    80001c60:	97ba                	add	a5,a5,a4
    80001c62:	f4bc                	sd	a5,104(s1)
}
    80001c64:	8526                	mv	a0,s1
    80001c66:	60e2                	ld	ra,24(sp)
    80001c68:	6442                	ld	s0,16(sp)
    80001c6a:	64a2                	ld	s1,8(sp)
    80001c6c:	6902                	ld	s2,0(sp)
    80001c6e:	6105                	addi	sp,sp,32
    80001c70:	8082                	ret
    freeproc(p);
    80001c72:	8526                	mv	a0,s1
    80001c74:	00000097          	auipc	ra,0x0
    80001c78:	f08080e7          	jalr	-248(ra) # 80001b7c <freeproc>
    release(&p->lock);
    80001c7c:	8526                	mv	a0,s1
    80001c7e:	fffff097          	auipc	ra,0xfffff
    80001c82:	008080e7          	jalr	8(ra) # 80000c86 <release>
    return 0;
    80001c86:	84ca                	mv	s1,s2
    80001c88:	bff1                	j	80001c64 <allocproc+0x90>
    freeproc(p);
    80001c8a:	8526                	mv	a0,s1
    80001c8c:	00000097          	auipc	ra,0x0
    80001c90:	ef0080e7          	jalr	-272(ra) # 80001b7c <freeproc>
    release(&p->lock);
    80001c94:	8526                	mv	a0,s1
    80001c96:	fffff097          	auipc	ra,0xfffff
    80001c9a:	ff0080e7          	jalr	-16(ra) # 80000c86 <release>
    return 0;
    80001c9e:	84ca                	mv	s1,s2
    80001ca0:	b7d1                	j	80001c64 <allocproc+0x90>

0000000080001ca2 <userinit>:
{
    80001ca2:	1101                	addi	sp,sp,-32
    80001ca4:	ec06                	sd	ra,24(sp)
    80001ca6:	e822                	sd	s0,16(sp)
    80001ca8:	e426                	sd	s1,8(sp)
    80001caa:	1000                	addi	s0,sp,32
  p = allocproc();
    80001cac:	00000097          	auipc	ra,0x0
    80001cb0:	f28080e7          	jalr	-216(ra) # 80001bd4 <allocproc>
    80001cb4:	84aa                	mv	s1,a0
  initproc = p;
    80001cb6:	00007797          	auipc	a5,0x7
    80001cba:	daa7b923          	sd	a0,-590(a5) # 80008a68 <initproc>
  uvmfirst(p->pagetable, initcode, sizeof(initcode));
    80001cbe:	03400613          	li	a2,52
    80001cc2:	00007597          	auipc	a1,0x7
    80001cc6:	d3e58593          	addi	a1,a1,-706 # 80008a00 <initcode>
    80001cca:	6928                	ld	a0,80(a0)
    80001ccc:	fffff097          	auipc	ra,0xfffff
    80001cd0:	676080e7          	jalr	1654(ra) # 80001342 <uvmfirst>
  p->sz = PGSIZE;
    80001cd4:	6785                	lui	a5,0x1
    80001cd6:	e4bc                	sd	a5,72(s1)
  p->trapframe->epc = 0;      // user program counter
    80001cd8:	6cb8                	ld	a4,88(s1)
    80001cda:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->trapframe->sp = PGSIZE;  // user stack pointer
    80001cde:	6cb8                	ld	a4,88(s1)
    80001ce0:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80001ce2:	4641                	li	a2,16
    80001ce4:	00006597          	auipc	a1,0x6
    80001ce8:	51458593          	addi	a1,a1,1300 # 800081f8 <digits+0x1b8>
    80001cec:	15848513          	addi	a0,s1,344
    80001cf0:	fffff097          	auipc	ra,0xfffff
    80001cf4:	126080e7          	jalr	294(ra) # 80000e16 <safestrcpy>
  p->cwd = namei("/");
    80001cf8:	00006517          	auipc	a0,0x6
    80001cfc:	51050513          	addi	a0,a0,1296 # 80008208 <digits+0x1c8>
    80001d00:	00002097          	auipc	ra,0x2
    80001d04:	104080e7          	jalr	260(ra) # 80003e04 <namei>
    80001d08:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001d0c:	478d                	li	a5,3
    80001d0e:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001d10:	8526                	mv	a0,s1
    80001d12:	fffff097          	auipc	ra,0xfffff
    80001d16:	f74080e7          	jalr	-140(ra) # 80000c86 <release>
}
    80001d1a:	60e2                	ld	ra,24(sp)
    80001d1c:	6442                	ld	s0,16(sp)
    80001d1e:	64a2                	ld	s1,8(sp)
    80001d20:	6105                	addi	sp,sp,32
    80001d22:	8082                	ret

0000000080001d24 <growproc>:
{
    80001d24:	1101                	addi	sp,sp,-32
    80001d26:	ec06                	sd	ra,24(sp)
    80001d28:	e822                	sd	s0,16(sp)
    80001d2a:	e426                	sd	s1,8(sp)
    80001d2c:	e04a                	sd	s2,0(sp)
    80001d2e:	1000                	addi	s0,sp,32
    80001d30:	892a                	mv	s2,a0
  struct proc *p = myproc();
    80001d32:	00000097          	auipc	ra,0x0
    80001d36:	c98080e7          	jalr	-872(ra) # 800019ca <myproc>
    80001d3a:	84aa                	mv	s1,a0
  n = PGROUNDUP(n);
    80001d3c:	6605                	lui	a2,0x1
    80001d3e:	367d                	addiw	a2,a2,-1 # fff <_entry-0x7ffff001>
    80001d40:	0126063b          	addw	a2,a2,s2
    80001d44:	77fd                	lui	a5,0xfffff
    80001d46:	8e7d                	and	a2,a2,a5
  sz = p->sz;
    80001d48:	652c                	ld	a1,72(a0)
  if(n > 0){
    80001d4a:	00c04c63          	bgtz	a2,80001d62 <growproc+0x3e>
  } else if(n < 0){
    80001d4e:	02064563          	bltz	a2,80001d78 <growproc+0x54>
  p->sz = sz;
    80001d52:	e4ac                	sd	a1,72(s1)
  return 0;
    80001d54:	4501                	li	a0,0
}
    80001d56:	60e2                	ld	ra,24(sp)
    80001d58:	6442                	ld	s0,16(sp)
    80001d5a:	64a2                	ld	s1,8(sp)
    80001d5c:	6902                	ld	s2,0(sp)
    80001d5e:	6105                	addi	sp,sp,32
    80001d60:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0) {
    80001d62:	4691                	li	a3,4
    80001d64:	962e                	add	a2,a2,a1
    80001d66:	6928                	ld	a0,80(a0)
    80001d68:	fffff097          	auipc	ra,0xfffff
    80001d6c:	694080e7          	jalr	1684(ra) # 800013fc <uvmalloc>
    80001d70:	85aa                	mv	a1,a0
    80001d72:	f165                	bnez	a0,80001d52 <growproc+0x2e>
      return -1;
    80001d74:	557d                	li	a0,-1
    80001d76:	b7c5                	j	80001d56 <growproc+0x32>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001d78:	962e                	add	a2,a2,a1
    80001d7a:	6928                	ld	a0,80(a0)
    80001d7c:	fffff097          	auipc	ra,0xfffff
    80001d80:	638080e7          	jalr	1592(ra) # 800013b4 <uvmdealloc>
    80001d84:	85aa                	mv	a1,a0
    80001d86:	b7f1                	j	80001d52 <growproc+0x2e>

0000000080001d88 <fork>:
{
    80001d88:	7139                	addi	sp,sp,-64
    80001d8a:	fc06                	sd	ra,56(sp)
    80001d8c:	f822                	sd	s0,48(sp)
    80001d8e:	f426                	sd	s1,40(sp)
    80001d90:	f04a                	sd	s2,32(sp)
    80001d92:	ec4e                	sd	s3,24(sp)
    80001d94:	e852                	sd	s4,16(sp)
    80001d96:	e456                	sd	s5,8(sp)
    80001d98:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80001d9a:	00000097          	auipc	ra,0x0
    80001d9e:	c30080e7          	jalr	-976(ra) # 800019ca <myproc>
    80001da2:	8aaa                	mv	s5,a0
  if((np = allocproc()) == 0){
    80001da4:	00000097          	auipc	ra,0x0
    80001da8:	e30080e7          	jalr	-464(ra) # 80001bd4 <allocproc>
    80001dac:	10050c63          	beqz	a0,80001ec4 <fork+0x13c>
    80001db0:	8a2a                	mv	s4,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80001db2:	048ab603          	ld	a2,72(s5)
    80001db6:	692c                	ld	a1,80(a0)
    80001db8:	050ab503          	ld	a0,80(s5)
    80001dbc:	fffff097          	auipc	ra,0xfffff
    80001dc0:	798080e7          	jalr	1944(ra) # 80001554 <uvmcopy>
    80001dc4:	04054863          	bltz	a0,80001e14 <fork+0x8c>
  np->sz = p->sz;
    80001dc8:	048ab783          	ld	a5,72(s5)
    80001dcc:	04fa3423          	sd	a5,72(s4)
  *(np->trapframe) = *(p->trapframe);
    80001dd0:	058ab683          	ld	a3,88(s5)
    80001dd4:	87b6                	mv	a5,a3
    80001dd6:	058a3703          	ld	a4,88(s4)
    80001dda:	12068693          	addi	a3,a3,288
    80001dde:	0007b803          	ld	a6,0(a5) # fffffffffffff000 <end+0xffffffff7ffdd108>
    80001de2:	6788                	ld	a0,8(a5)
    80001de4:	6b8c                	ld	a1,16(a5)
    80001de6:	6f90                	ld	a2,24(a5)
    80001de8:	01073023          	sd	a6,0(a4)
    80001dec:	e708                	sd	a0,8(a4)
    80001dee:	eb0c                	sd	a1,16(a4)
    80001df0:	ef10                	sd	a2,24(a4)
    80001df2:	02078793          	addi	a5,a5,32
    80001df6:	02070713          	addi	a4,a4,32
    80001dfa:	fed792e3          	bne	a5,a3,80001dde <fork+0x56>
  np->trapframe->a0 = 0;
    80001dfe:	058a3783          	ld	a5,88(s4)
    80001e02:	0607b823          	sd	zero,112(a5)
  for(i = 0; i < NOFILE; i++)
    80001e06:	0d0a8493          	addi	s1,s5,208
    80001e0a:	0d0a0913          	addi	s2,s4,208
    80001e0e:	150a8993          	addi	s3,s5,336
    80001e12:	a00d                	j	80001e34 <fork+0xac>
    freeproc(np);
    80001e14:	8552                	mv	a0,s4
    80001e16:	00000097          	auipc	ra,0x0
    80001e1a:	d66080e7          	jalr	-666(ra) # 80001b7c <freeproc>
    release(&np->lock);
    80001e1e:	8552                	mv	a0,s4
    80001e20:	fffff097          	auipc	ra,0xfffff
    80001e24:	e66080e7          	jalr	-410(ra) # 80000c86 <release>
    return -1;
    80001e28:	597d                	li	s2,-1
    80001e2a:	a059                	j	80001eb0 <fork+0x128>
  for(i = 0; i < NOFILE; i++)
    80001e2c:	04a1                	addi	s1,s1,8
    80001e2e:	0921                	addi	s2,s2,8
    80001e30:	01348b63          	beq	s1,s3,80001e46 <fork+0xbe>
    if(p->ofile[i])
    80001e34:	6088                	ld	a0,0(s1)
    80001e36:	d97d                	beqz	a0,80001e2c <fork+0xa4>
      np->ofile[i] = filedup(p->ofile[i]);
    80001e38:	00002097          	auipc	ra,0x2
    80001e3c:	63e080e7          	jalr	1598(ra) # 80004476 <filedup>
    80001e40:	00a93023          	sd	a0,0(s2)
    80001e44:	b7e5                	j	80001e2c <fork+0xa4>
  np->cwd = idup(p->cwd);
    80001e46:	150ab503          	ld	a0,336(s5)
    80001e4a:	00001097          	auipc	ra,0x1
    80001e4e:	7d6080e7          	jalr	2006(ra) # 80003620 <idup>
    80001e52:	14aa3823          	sd	a0,336(s4)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001e56:	4641                	li	a2,16
    80001e58:	158a8593          	addi	a1,s5,344
    80001e5c:	158a0513          	addi	a0,s4,344
    80001e60:	fffff097          	auipc	ra,0xfffff
    80001e64:	fb6080e7          	jalr	-74(ra) # 80000e16 <safestrcpy>
  pid = np->pid;
    80001e68:	030a2903          	lw	s2,48(s4)
  release(&np->lock);
    80001e6c:	8552                	mv	a0,s4
    80001e6e:	fffff097          	auipc	ra,0xfffff
    80001e72:	e18080e7          	jalr	-488(ra) # 80000c86 <release>
  acquire(&wait_lock);
    80001e76:	0000f497          	auipc	s1,0xf
    80001e7a:	e8248493          	addi	s1,s1,-382 # 80010cf8 <wait_lock>
    80001e7e:	8526                	mv	a0,s1
    80001e80:	fffff097          	auipc	ra,0xfffff
    80001e84:	d52080e7          	jalr	-686(ra) # 80000bd2 <acquire>
  np->parent = p;
    80001e88:	035a3c23          	sd	s5,56(s4)
  release(&wait_lock);
    80001e8c:	8526                	mv	a0,s1
    80001e8e:	fffff097          	auipc	ra,0xfffff
    80001e92:	df8080e7          	jalr	-520(ra) # 80000c86 <release>
  acquire(&np->lock);
    80001e96:	8552                	mv	a0,s4
    80001e98:	fffff097          	auipc	ra,0xfffff
    80001e9c:	d3a080e7          	jalr	-710(ra) # 80000bd2 <acquire>
  np->state = RUNNABLE;
    80001ea0:	478d                	li	a5,3
    80001ea2:	00fa2c23          	sw	a5,24(s4)
  release(&np->lock);
    80001ea6:	8552                	mv	a0,s4
    80001ea8:	fffff097          	auipc	ra,0xfffff
    80001eac:	dde080e7          	jalr	-546(ra) # 80000c86 <release>
}
    80001eb0:	854a                	mv	a0,s2
    80001eb2:	70e2                	ld	ra,56(sp)
    80001eb4:	7442                	ld	s0,48(sp)
    80001eb6:	74a2                	ld	s1,40(sp)
    80001eb8:	7902                	ld	s2,32(sp)
    80001eba:	69e2                	ld	s3,24(sp)
    80001ebc:	6a42                	ld	s4,16(sp)
    80001ebe:	6aa2                	ld	s5,8(sp)
    80001ec0:	6121                	addi	sp,sp,64
    80001ec2:	8082                	ret
    return -1;
    80001ec4:	597d                	li	s2,-1
    80001ec6:	b7ed                	j	80001eb0 <fork+0x128>

0000000080001ec8 <scheduler>:
{
    80001ec8:	7139                	addi	sp,sp,-64
    80001eca:	fc06                	sd	ra,56(sp)
    80001ecc:	f822                	sd	s0,48(sp)
    80001ece:	f426                	sd	s1,40(sp)
    80001ed0:	f04a                	sd	s2,32(sp)
    80001ed2:	ec4e                	sd	s3,24(sp)
    80001ed4:	e852                	sd	s4,16(sp)
    80001ed6:	e456                	sd	s5,8(sp)
    80001ed8:	e05a                	sd	s6,0(sp)
    80001eda:	0080                	addi	s0,sp,64
    80001edc:	8792                	mv	a5,tp
  int id = r_tp();
    80001ede:	2781                	sext.w	a5,a5
  c->proc = 0;
    80001ee0:	00779a93          	slli	s5,a5,0x7
    80001ee4:	0000f717          	auipc	a4,0xf
    80001ee8:	dfc70713          	addi	a4,a4,-516 # 80010ce0 <pid_lock>
    80001eec:	9756                	add	a4,a4,s5
    80001eee:	02073823          	sd	zero,48(a4)
        swtch(&c->context, &p->context);
    80001ef2:	0000f717          	auipc	a4,0xf
    80001ef6:	e2670713          	addi	a4,a4,-474 # 80010d18 <cpus+0x8>
    80001efa:	9aba                	add	s5,s5,a4
      if(p->state == RUNNABLE) {
    80001efc:	498d                	li	s3,3
        p->state = RUNNING;
    80001efe:	4b11                	li	s6,4
        c->proc = p;
    80001f00:	079e                	slli	a5,a5,0x7
    80001f02:	0000fa17          	auipc	s4,0xf
    80001f06:	ddea0a13          	addi	s4,s4,-546 # 80010ce0 <pid_lock>
    80001f0a:	9a3e                	add	s4,s4,a5
    for(p = proc; p < &proc[NPROC]; p++) {
    80001f0c:	00015917          	auipc	s2,0x15
    80001f10:	c0490913          	addi	s2,s2,-1020 # 80016b10 <tickslock>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001f14:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001f18:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001f1c:	10079073          	csrw	sstatus,a5
    80001f20:	0000f497          	auipc	s1,0xf
    80001f24:	1f048493          	addi	s1,s1,496 # 80011110 <proc>
    80001f28:	a811                	j	80001f3c <scheduler+0x74>
      release(&p->lock);
    80001f2a:	8526                	mv	a0,s1
    80001f2c:	fffff097          	auipc	ra,0xfffff
    80001f30:	d5a080e7          	jalr	-678(ra) # 80000c86 <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    80001f34:	16848493          	addi	s1,s1,360
    80001f38:	fd248ee3          	beq	s1,s2,80001f14 <scheduler+0x4c>
      acquire(&p->lock);
    80001f3c:	8526                	mv	a0,s1
    80001f3e:	fffff097          	auipc	ra,0xfffff
    80001f42:	c94080e7          	jalr	-876(ra) # 80000bd2 <acquire>
      if(p->state == RUNNABLE) {
    80001f46:	4c9c                	lw	a5,24(s1)
    80001f48:	ff3791e3          	bne	a5,s3,80001f2a <scheduler+0x62>
        p->state = RUNNING;
    80001f4c:	0164ac23          	sw	s6,24(s1)
        c->proc = p;
    80001f50:	029a3823          	sd	s1,48(s4)
        swtch(&c->context, &p->context);
    80001f54:	06048593          	addi	a1,s1,96
    80001f58:	8556                	mv	a0,s5
    80001f5a:	00000097          	auipc	ra,0x0
    80001f5e:	684080e7          	jalr	1668(ra) # 800025de <swtch>
        c->proc = 0;
    80001f62:	020a3823          	sd	zero,48(s4)
    80001f66:	b7d1                	j	80001f2a <scheduler+0x62>

0000000080001f68 <sched>:
{
    80001f68:	7179                	addi	sp,sp,-48
    80001f6a:	f406                	sd	ra,40(sp)
    80001f6c:	f022                	sd	s0,32(sp)
    80001f6e:	ec26                	sd	s1,24(sp)
    80001f70:	e84a                	sd	s2,16(sp)
    80001f72:	e44e                	sd	s3,8(sp)
    80001f74:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80001f76:	00000097          	auipc	ra,0x0
    80001f7a:	a54080e7          	jalr	-1452(ra) # 800019ca <myproc>
    80001f7e:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    80001f80:	fffff097          	auipc	ra,0xfffff
    80001f84:	bd8080e7          	jalr	-1064(ra) # 80000b58 <holding>
    80001f88:	c93d                	beqz	a0,80001ffe <sched+0x96>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001f8a:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    80001f8c:	2781                	sext.w	a5,a5
    80001f8e:	079e                	slli	a5,a5,0x7
    80001f90:	0000f717          	auipc	a4,0xf
    80001f94:	d5070713          	addi	a4,a4,-688 # 80010ce0 <pid_lock>
    80001f98:	97ba                	add	a5,a5,a4
    80001f9a:	0a87a703          	lw	a4,168(a5)
    80001f9e:	4785                	li	a5,1
    80001fa0:	06f71763          	bne	a4,a5,8000200e <sched+0xa6>
  if(p->state == RUNNING)
    80001fa4:	4c98                	lw	a4,24(s1)
    80001fa6:	4791                	li	a5,4
    80001fa8:	06f70b63          	beq	a4,a5,8000201e <sched+0xb6>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001fac:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80001fb0:	8b89                	andi	a5,a5,2
  if(intr_get())
    80001fb2:	efb5                	bnez	a5,8000202e <sched+0xc6>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001fb4:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80001fb6:	0000f917          	auipc	s2,0xf
    80001fba:	d2a90913          	addi	s2,s2,-726 # 80010ce0 <pid_lock>
    80001fbe:	2781                	sext.w	a5,a5
    80001fc0:	079e                	slli	a5,a5,0x7
    80001fc2:	97ca                	add	a5,a5,s2
    80001fc4:	0ac7a983          	lw	s3,172(a5)
    80001fc8:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    80001fca:	2781                	sext.w	a5,a5
    80001fcc:	079e                	slli	a5,a5,0x7
    80001fce:	0000f597          	auipc	a1,0xf
    80001fd2:	d4a58593          	addi	a1,a1,-694 # 80010d18 <cpus+0x8>
    80001fd6:	95be                	add	a1,a1,a5
    80001fd8:	06048513          	addi	a0,s1,96
    80001fdc:	00000097          	auipc	ra,0x0
    80001fe0:	602080e7          	jalr	1538(ra) # 800025de <swtch>
    80001fe4:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    80001fe6:	2781                	sext.w	a5,a5
    80001fe8:	079e                	slli	a5,a5,0x7
    80001fea:	993e                	add	s2,s2,a5
    80001fec:	0b392623          	sw	s3,172(s2)
}
    80001ff0:	70a2                	ld	ra,40(sp)
    80001ff2:	7402                	ld	s0,32(sp)
    80001ff4:	64e2                	ld	s1,24(sp)
    80001ff6:	6942                	ld	s2,16(sp)
    80001ff8:	69a2                	ld	s3,8(sp)
    80001ffa:	6145                	addi	sp,sp,48
    80001ffc:	8082                	ret
    panic("sched p->lock");
    80001ffe:	00006517          	auipc	a0,0x6
    80002002:	21250513          	addi	a0,a0,530 # 80008210 <digits+0x1d0>
    80002006:	ffffe097          	auipc	ra,0xffffe
    8000200a:	536080e7          	jalr	1334(ra) # 8000053c <panic>
    panic("sched locks");
    8000200e:	00006517          	auipc	a0,0x6
    80002012:	21250513          	addi	a0,a0,530 # 80008220 <digits+0x1e0>
    80002016:	ffffe097          	auipc	ra,0xffffe
    8000201a:	526080e7          	jalr	1318(ra) # 8000053c <panic>
    panic("sched running");
    8000201e:	00006517          	auipc	a0,0x6
    80002022:	21250513          	addi	a0,a0,530 # 80008230 <digits+0x1f0>
    80002026:	ffffe097          	auipc	ra,0xffffe
    8000202a:	516080e7          	jalr	1302(ra) # 8000053c <panic>
    panic("sched interruptible");
    8000202e:	00006517          	auipc	a0,0x6
    80002032:	21250513          	addi	a0,a0,530 # 80008240 <digits+0x200>
    80002036:	ffffe097          	auipc	ra,0xffffe
    8000203a:	506080e7          	jalr	1286(ra) # 8000053c <panic>

000000008000203e <yield>:
{
    8000203e:	1101                	addi	sp,sp,-32
    80002040:	ec06                	sd	ra,24(sp)
    80002042:	e822                	sd	s0,16(sp)
    80002044:	e426                	sd	s1,8(sp)
    80002046:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80002048:	00000097          	auipc	ra,0x0
    8000204c:	982080e7          	jalr	-1662(ra) # 800019ca <myproc>
    80002050:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80002052:	fffff097          	auipc	ra,0xfffff
    80002056:	b80080e7          	jalr	-1152(ra) # 80000bd2 <acquire>
  p->state = RUNNABLE;
    8000205a:	478d                	li	a5,3
    8000205c:	cc9c                	sw	a5,24(s1)
  sched();
    8000205e:	00000097          	auipc	ra,0x0
    80002062:	f0a080e7          	jalr	-246(ra) # 80001f68 <sched>
  release(&p->lock);
    80002066:	8526                	mv	a0,s1
    80002068:	fffff097          	auipc	ra,0xfffff
    8000206c:	c1e080e7          	jalr	-994(ra) # 80000c86 <release>
}
    80002070:	60e2                	ld	ra,24(sp)
    80002072:	6442                	ld	s0,16(sp)
    80002074:	64a2                	ld	s1,8(sp)
    80002076:	6105                	addi	sp,sp,32
    80002078:	8082                	ret

000000008000207a <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    8000207a:	7179                	addi	sp,sp,-48
    8000207c:	f406                	sd	ra,40(sp)
    8000207e:	f022                	sd	s0,32(sp)
    80002080:	ec26                	sd	s1,24(sp)
    80002082:	e84a                	sd	s2,16(sp)
    80002084:	e44e                	sd	s3,8(sp)
    80002086:	1800                	addi	s0,sp,48
    80002088:	89aa                	mv	s3,a0
    8000208a:	892e                	mv	s2,a1
  struct proc *p = myproc();
    8000208c:	00000097          	auipc	ra,0x0
    80002090:	93e080e7          	jalr	-1730(ra) # 800019ca <myproc>
    80002094:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
    80002096:	fffff097          	auipc	ra,0xfffff
    8000209a:	b3c080e7          	jalr	-1220(ra) # 80000bd2 <acquire>
  release(lk);
    8000209e:	854a                	mv	a0,s2
    800020a0:	fffff097          	auipc	ra,0xfffff
    800020a4:	be6080e7          	jalr	-1050(ra) # 80000c86 <release>

  // Go to sleep.
  p->chan = chan;
    800020a8:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    800020ac:	4789                	li	a5,2
    800020ae:	cc9c                	sw	a5,24(s1)

  /* Adil: sleeping. */
  // printf("Sleeping and yielding CPU.");

  sched();
    800020b0:	00000097          	auipc	ra,0x0
    800020b4:	eb8080e7          	jalr	-328(ra) # 80001f68 <sched>

  // Tidy up.
  p->chan = 0;
    800020b8:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    800020bc:	8526                	mv	a0,s1
    800020be:	fffff097          	auipc	ra,0xfffff
    800020c2:	bc8080e7          	jalr	-1080(ra) # 80000c86 <release>
  acquire(lk);
    800020c6:	854a                	mv	a0,s2
    800020c8:	fffff097          	auipc	ra,0xfffff
    800020cc:	b0a080e7          	jalr	-1270(ra) # 80000bd2 <acquire>
}
    800020d0:	70a2                	ld	ra,40(sp)
    800020d2:	7402                	ld	s0,32(sp)
    800020d4:	64e2                	ld	s1,24(sp)
    800020d6:	6942                	ld	s2,16(sp)
    800020d8:	69a2                	ld	s3,8(sp)
    800020da:	6145                	addi	sp,sp,48
    800020dc:	8082                	ret

00000000800020de <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void
wakeup(void *chan)
{
    800020de:	7139                	addi	sp,sp,-64
    800020e0:	fc06                	sd	ra,56(sp)
    800020e2:	f822                	sd	s0,48(sp)
    800020e4:	f426                	sd	s1,40(sp)
    800020e6:	f04a                	sd	s2,32(sp)
    800020e8:	ec4e                	sd	s3,24(sp)
    800020ea:	e852                	sd	s4,16(sp)
    800020ec:	e456                	sd	s5,8(sp)
    800020ee:	0080                	addi	s0,sp,64
    800020f0:	8a2a                	mv	s4,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    800020f2:	0000f497          	auipc	s1,0xf
    800020f6:	01e48493          	addi	s1,s1,30 # 80011110 <proc>
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
    800020fa:	4989                	li	s3,2
        p->state = RUNNABLE;
    800020fc:	4a8d                	li	s5,3
  for(p = proc; p < &proc[NPROC]; p++) {
    800020fe:	00015917          	auipc	s2,0x15
    80002102:	a1290913          	addi	s2,s2,-1518 # 80016b10 <tickslock>
    80002106:	a811                	j	8000211a <wakeup+0x3c>
      }
      release(&p->lock);
    80002108:	8526                	mv	a0,s1
    8000210a:	fffff097          	auipc	ra,0xfffff
    8000210e:	b7c080e7          	jalr	-1156(ra) # 80000c86 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80002112:	16848493          	addi	s1,s1,360
    80002116:	03248663          	beq	s1,s2,80002142 <wakeup+0x64>
    if(p != myproc()){
    8000211a:	00000097          	auipc	ra,0x0
    8000211e:	8b0080e7          	jalr	-1872(ra) # 800019ca <myproc>
    80002122:	fea488e3          	beq	s1,a0,80002112 <wakeup+0x34>
      acquire(&p->lock);
    80002126:	8526                	mv	a0,s1
    80002128:	fffff097          	auipc	ra,0xfffff
    8000212c:	aaa080e7          	jalr	-1366(ra) # 80000bd2 <acquire>
      if(p->state == SLEEPING && p->chan == chan) {
    80002130:	4c9c                	lw	a5,24(s1)
    80002132:	fd379be3          	bne	a5,s3,80002108 <wakeup+0x2a>
    80002136:	709c                	ld	a5,32(s1)
    80002138:	fd4798e3          	bne	a5,s4,80002108 <wakeup+0x2a>
        p->state = RUNNABLE;
    8000213c:	0154ac23          	sw	s5,24(s1)
    80002140:	b7e1                	j	80002108 <wakeup+0x2a>
    }
  }
}
    80002142:	70e2                	ld	ra,56(sp)
    80002144:	7442                	ld	s0,48(sp)
    80002146:	74a2                	ld	s1,40(sp)
    80002148:	7902                	ld	s2,32(sp)
    8000214a:	69e2                	ld	s3,24(sp)
    8000214c:	6a42                	ld	s4,16(sp)
    8000214e:	6aa2                	ld	s5,8(sp)
    80002150:	6121                	addi	sp,sp,64
    80002152:	8082                	ret

0000000080002154 <reparent>:
{
    80002154:	7179                	addi	sp,sp,-48
    80002156:	f406                	sd	ra,40(sp)
    80002158:	f022                	sd	s0,32(sp)
    8000215a:	ec26                	sd	s1,24(sp)
    8000215c:	e84a                	sd	s2,16(sp)
    8000215e:	e44e                	sd	s3,8(sp)
    80002160:	e052                	sd	s4,0(sp)
    80002162:	1800                	addi	s0,sp,48
    80002164:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80002166:	0000f497          	auipc	s1,0xf
    8000216a:	faa48493          	addi	s1,s1,-86 # 80011110 <proc>
      pp->parent = initproc;
    8000216e:	00007a17          	auipc	s4,0x7
    80002172:	8faa0a13          	addi	s4,s4,-1798 # 80008a68 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80002176:	00015997          	auipc	s3,0x15
    8000217a:	99a98993          	addi	s3,s3,-1638 # 80016b10 <tickslock>
    8000217e:	a029                	j	80002188 <reparent+0x34>
    80002180:	16848493          	addi	s1,s1,360
    80002184:	01348d63          	beq	s1,s3,8000219e <reparent+0x4a>
    if(pp->parent == p){
    80002188:	7c9c                	ld	a5,56(s1)
    8000218a:	ff279be3          	bne	a5,s2,80002180 <reparent+0x2c>
      pp->parent = initproc;
    8000218e:	000a3503          	ld	a0,0(s4)
    80002192:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    80002194:	00000097          	auipc	ra,0x0
    80002198:	f4a080e7          	jalr	-182(ra) # 800020de <wakeup>
    8000219c:	b7d5                	j	80002180 <reparent+0x2c>
}
    8000219e:	70a2                	ld	ra,40(sp)
    800021a0:	7402                	ld	s0,32(sp)
    800021a2:	64e2                	ld	s1,24(sp)
    800021a4:	6942                	ld	s2,16(sp)
    800021a6:	69a2                	ld	s3,8(sp)
    800021a8:	6a02                	ld	s4,0(sp)
    800021aa:	6145                	addi	sp,sp,48
    800021ac:	8082                	ret

00000000800021ae <exit>:
{
    800021ae:	7179                	addi	sp,sp,-48
    800021b0:	f406                	sd	ra,40(sp)
    800021b2:	f022                	sd	s0,32(sp)
    800021b4:	ec26                	sd	s1,24(sp)
    800021b6:	e84a                	sd	s2,16(sp)
    800021b8:	e44e                	sd	s3,8(sp)
    800021ba:	e052                	sd	s4,0(sp)
    800021bc:	1800                	addi	s0,sp,48
    800021be:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    800021c0:	00000097          	auipc	ra,0x0
    800021c4:	80a080e7          	jalr	-2038(ra) # 800019ca <myproc>
    800021c8:	89aa                	mv	s3,a0
  if(p == initproc)
    800021ca:	00007797          	auipc	a5,0x7
    800021ce:	89e7b783          	ld	a5,-1890(a5) # 80008a68 <initproc>
    800021d2:	0d050493          	addi	s1,a0,208
    800021d6:	15050913          	addi	s2,a0,336
    800021da:	02a79363          	bne	a5,a0,80002200 <exit+0x52>
    panic("init exiting");
    800021de:	00006517          	auipc	a0,0x6
    800021e2:	07a50513          	addi	a0,a0,122 # 80008258 <digits+0x218>
    800021e6:	ffffe097          	auipc	ra,0xffffe
    800021ea:	356080e7          	jalr	854(ra) # 8000053c <panic>
      fileclose(f);
    800021ee:	00002097          	auipc	ra,0x2
    800021f2:	2da080e7          	jalr	730(ra) # 800044c8 <fileclose>
      p->ofile[fd] = 0;
    800021f6:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    800021fa:	04a1                	addi	s1,s1,8
    800021fc:	01248563          	beq	s1,s2,80002206 <exit+0x58>
    if(p->ofile[fd]){
    80002200:	6088                	ld	a0,0(s1)
    80002202:	f575                	bnez	a0,800021ee <exit+0x40>
    80002204:	bfdd                	j	800021fa <exit+0x4c>
  begin_op();
    80002206:	00002097          	auipc	ra,0x2
    8000220a:	dfe080e7          	jalr	-514(ra) # 80004004 <begin_op>
  iput(p->cwd);
    8000220e:	1509b503          	ld	a0,336(s3)
    80002212:	00001097          	auipc	ra,0x1
    80002216:	606080e7          	jalr	1542(ra) # 80003818 <iput>
  end_op();
    8000221a:	00002097          	auipc	ra,0x2
    8000221e:	e64080e7          	jalr	-412(ra) # 8000407e <end_op>
  p->cwd = 0;
    80002222:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    80002226:	0000f497          	auipc	s1,0xf
    8000222a:	ad248493          	addi	s1,s1,-1326 # 80010cf8 <wait_lock>
    8000222e:	8526                	mv	a0,s1
    80002230:	fffff097          	auipc	ra,0xfffff
    80002234:	9a2080e7          	jalr	-1630(ra) # 80000bd2 <acquire>
  reparent(p);
    80002238:	854e                	mv	a0,s3
    8000223a:	00000097          	auipc	ra,0x0
    8000223e:	f1a080e7          	jalr	-230(ra) # 80002154 <reparent>
  wakeup(p->parent);
    80002242:	0389b503          	ld	a0,56(s3)
    80002246:	00000097          	auipc	ra,0x0
    8000224a:	e98080e7          	jalr	-360(ra) # 800020de <wakeup>
  acquire(&p->lock);
    8000224e:	854e                	mv	a0,s3
    80002250:	fffff097          	auipc	ra,0xfffff
    80002254:	982080e7          	jalr	-1662(ra) # 80000bd2 <acquire>
  p->xstate = status;
    80002258:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    8000225c:	4795                	li	a5,5
    8000225e:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    80002262:	8526                	mv	a0,s1
    80002264:	fffff097          	auipc	ra,0xfffff
    80002268:	a22080e7          	jalr	-1502(ra) # 80000c86 <release>
  sched();
    8000226c:	00000097          	auipc	ra,0x0
    80002270:	cfc080e7          	jalr	-772(ra) # 80001f68 <sched>
  panic("zombie exit");
    80002274:	00006517          	auipc	a0,0x6
    80002278:	ff450513          	addi	a0,a0,-12 # 80008268 <digits+0x228>
    8000227c:	ffffe097          	auipc	ra,0xffffe
    80002280:	2c0080e7          	jalr	704(ra) # 8000053c <panic>

0000000080002284 <kill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
    80002284:	7179                	addi	sp,sp,-48
    80002286:	f406                	sd	ra,40(sp)
    80002288:	f022                	sd	s0,32(sp)
    8000228a:	ec26                	sd	s1,24(sp)
    8000228c:	e84a                	sd	s2,16(sp)
    8000228e:	e44e                	sd	s3,8(sp)
    80002290:	1800                	addi	s0,sp,48
    80002292:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    80002294:	0000f497          	auipc	s1,0xf
    80002298:	e7c48493          	addi	s1,s1,-388 # 80011110 <proc>
    8000229c:	00015997          	auipc	s3,0x15
    800022a0:	87498993          	addi	s3,s3,-1932 # 80016b10 <tickslock>
    acquire(&p->lock);
    800022a4:	8526                	mv	a0,s1
    800022a6:	fffff097          	auipc	ra,0xfffff
    800022aa:	92c080e7          	jalr	-1748(ra) # 80000bd2 <acquire>
    if(p->pid == pid){
    800022ae:	589c                	lw	a5,48(s1)
    800022b0:	01278d63          	beq	a5,s2,800022ca <kill+0x46>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    800022b4:	8526                	mv	a0,s1
    800022b6:	fffff097          	auipc	ra,0xfffff
    800022ba:	9d0080e7          	jalr	-1584(ra) # 80000c86 <release>
  for(p = proc; p < &proc[NPROC]; p++){
    800022be:	16848493          	addi	s1,s1,360
    800022c2:	ff3491e3          	bne	s1,s3,800022a4 <kill+0x20>
  }
  return -1;
    800022c6:	557d                	li	a0,-1
    800022c8:	a829                	j	800022e2 <kill+0x5e>
      p->killed = 1;
    800022ca:	4785                	li	a5,1
    800022cc:	d49c                	sw	a5,40(s1)
      if(p->state == SLEEPING){
    800022ce:	4c98                	lw	a4,24(s1)
    800022d0:	4789                	li	a5,2
    800022d2:	00f70f63          	beq	a4,a5,800022f0 <kill+0x6c>
      release(&p->lock);
    800022d6:	8526                	mv	a0,s1
    800022d8:	fffff097          	auipc	ra,0xfffff
    800022dc:	9ae080e7          	jalr	-1618(ra) # 80000c86 <release>
      return 0;
    800022e0:	4501                	li	a0,0
}
    800022e2:	70a2                	ld	ra,40(sp)
    800022e4:	7402                	ld	s0,32(sp)
    800022e6:	64e2                	ld	s1,24(sp)
    800022e8:	6942                	ld	s2,16(sp)
    800022ea:	69a2                	ld	s3,8(sp)
    800022ec:	6145                	addi	sp,sp,48
    800022ee:	8082                	ret
        p->state = RUNNABLE;
    800022f0:	478d                	li	a5,3
    800022f2:	cc9c                	sw	a5,24(s1)
    800022f4:	b7cd                	j	800022d6 <kill+0x52>

00000000800022f6 <setkilled>:

void
setkilled(struct proc *p)
{
    800022f6:	1101                	addi	sp,sp,-32
    800022f8:	ec06                	sd	ra,24(sp)
    800022fa:	e822                	sd	s0,16(sp)
    800022fc:	e426                	sd	s1,8(sp)
    800022fe:	1000                	addi	s0,sp,32
    80002300:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80002302:	fffff097          	auipc	ra,0xfffff
    80002306:	8d0080e7          	jalr	-1840(ra) # 80000bd2 <acquire>
  p->killed = 1;
    8000230a:	4785                	li	a5,1
    8000230c:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    8000230e:	8526                	mv	a0,s1
    80002310:	fffff097          	auipc	ra,0xfffff
    80002314:	976080e7          	jalr	-1674(ra) # 80000c86 <release>
}
    80002318:	60e2                	ld	ra,24(sp)
    8000231a:	6442                	ld	s0,16(sp)
    8000231c:	64a2                	ld	s1,8(sp)
    8000231e:	6105                	addi	sp,sp,32
    80002320:	8082                	ret

0000000080002322 <killed>:

int
killed(struct proc *p)
{
    80002322:	1101                	addi	sp,sp,-32
    80002324:	ec06                	sd	ra,24(sp)
    80002326:	e822                	sd	s0,16(sp)
    80002328:	e426                	sd	s1,8(sp)
    8000232a:	e04a                	sd	s2,0(sp)
    8000232c:	1000                	addi	s0,sp,32
    8000232e:	84aa                	mv	s1,a0
  int k;
  
  acquire(&p->lock);
    80002330:	fffff097          	auipc	ra,0xfffff
    80002334:	8a2080e7          	jalr	-1886(ra) # 80000bd2 <acquire>
  k = p->killed;
    80002338:	0284a903          	lw	s2,40(s1)
  release(&p->lock);
    8000233c:	8526                	mv	a0,s1
    8000233e:	fffff097          	auipc	ra,0xfffff
    80002342:	948080e7          	jalr	-1720(ra) # 80000c86 <release>
  return k;
}
    80002346:	854a                	mv	a0,s2
    80002348:	60e2                	ld	ra,24(sp)
    8000234a:	6442                	ld	s0,16(sp)
    8000234c:	64a2                	ld	s1,8(sp)
    8000234e:	6902                	ld	s2,0(sp)
    80002350:	6105                	addi	sp,sp,32
    80002352:	8082                	ret

0000000080002354 <wait>:
{
    80002354:	715d                	addi	sp,sp,-80
    80002356:	e486                	sd	ra,72(sp)
    80002358:	e0a2                	sd	s0,64(sp)
    8000235a:	fc26                	sd	s1,56(sp)
    8000235c:	f84a                	sd	s2,48(sp)
    8000235e:	f44e                	sd	s3,40(sp)
    80002360:	f052                	sd	s4,32(sp)
    80002362:	ec56                	sd	s5,24(sp)
    80002364:	e85a                	sd	s6,16(sp)
    80002366:	e45e                	sd	s7,8(sp)
    80002368:	e062                	sd	s8,0(sp)
    8000236a:	0880                	addi	s0,sp,80
    8000236c:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    8000236e:	fffff097          	auipc	ra,0xfffff
    80002372:	65c080e7          	jalr	1628(ra) # 800019ca <myproc>
    80002376:	892a                	mv	s2,a0
  acquire(&wait_lock);
    80002378:	0000f517          	auipc	a0,0xf
    8000237c:	98050513          	addi	a0,a0,-1664 # 80010cf8 <wait_lock>
    80002380:	fffff097          	auipc	ra,0xfffff
    80002384:	852080e7          	jalr	-1966(ra) # 80000bd2 <acquire>
    havekids = 0;
    80002388:	4b81                	li	s7,0
        if(pp->state == ZOMBIE){
    8000238a:	4a15                	li	s4,5
        havekids = 1;
    8000238c:	4a85                	li	s5,1
    for(pp = proc; pp < &proc[NPROC]; pp++){
    8000238e:	00014997          	auipc	s3,0x14
    80002392:	78298993          	addi	s3,s3,1922 # 80016b10 <tickslock>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80002396:	0000fc17          	auipc	s8,0xf
    8000239a:	962c0c13          	addi	s8,s8,-1694 # 80010cf8 <wait_lock>
    8000239e:	a0d1                	j	80002462 <wait+0x10e>
          pid = pp->pid;
    800023a0:	0304a983          	lw	s3,48(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    800023a4:	000b0e63          	beqz	s6,800023c0 <wait+0x6c>
    800023a8:	4691                	li	a3,4
    800023aa:	02c48613          	addi	a2,s1,44
    800023ae:	85da                	mv	a1,s6
    800023b0:	05093503          	ld	a0,80(s2)
    800023b4:	fffff097          	auipc	ra,0xfffff
    800023b8:	2d6080e7          	jalr	726(ra) # 8000168a <copyout>
    800023bc:	04054163          	bltz	a0,800023fe <wait+0xaa>
          freeproc(pp);
    800023c0:	8526                	mv	a0,s1
    800023c2:	fffff097          	auipc	ra,0xfffff
    800023c6:	7ba080e7          	jalr	1978(ra) # 80001b7c <freeproc>
          release(&pp->lock);
    800023ca:	8526                	mv	a0,s1
    800023cc:	fffff097          	auipc	ra,0xfffff
    800023d0:	8ba080e7          	jalr	-1862(ra) # 80000c86 <release>
          release(&wait_lock);
    800023d4:	0000f517          	auipc	a0,0xf
    800023d8:	92450513          	addi	a0,a0,-1756 # 80010cf8 <wait_lock>
    800023dc:	fffff097          	auipc	ra,0xfffff
    800023e0:	8aa080e7          	jalr	-1878(ra) # 80000c86 <release>
}
    800023e4:	854e                	mv	a0,s3
    800023e6:	60a6                	ld	ra,72(sp)
    800023e8:	6406                	ld	s0,64(sp)
    800023ea:	74e2                	ld	s1,56(sp)
    800023ec:	7942                	ld	s2,48(sp)
    800023ee:	79a2                	ld	s3,40(sp)
    800023f0:	7a02                	ld	s4,32(sp)
    800023f2:	6ae2                	ld	s5,24(sp)
    800023f4:	6b42                	ld	s6,16(sp)
    800023f6:	6ba2                	ld	s7,8(sp)
    800023f8:	6c02                	ld	s8,0(sp)
    800023fa:	6161                	addi	sp,sp,80
    800023fc:	8082                	ret
            release(&pp->lock);
    800023fe:	8526                	mv	a0,s1
    80002400:	fffff097          	auipc	ra,0xfffff
    80002404:	886080e7          	jalr	-1914(ra) # 80000c86 <release>
            release(&wait_lock);
    80002408:	0000f517          	auipc	a0,0xf
    8000240c:	8f050513          	addi	a0,a0,-1808 # 80010cf8 <wait_lock>
    80002410:	fffff097          	auipc	ra,0xfffff
    80002414:	876080e7          	jalr	-1930(ra) # 80000c86 <release>
            return -1;
    80002418:	59fd                	li	s3,-1
    8000241a:	b7e9                	j	800023e4 <wait+0x90>
    for(pp = proc; pp < &proc[NPROC]; pp++){
    8000241c:	16848493          	addi	s1,s1,360
    80002420:	03348463          	beq	s1,s3,80002448 <wait+0xf4>
      if(pp->parent == p){
    80002424:	7c9c                	ld	a5,56(s1)
    80002426:	ff279be3          	bne	a5,s2,8000241c <wait+0xc8>
        acquire(&pp->lock);
    8000242a:	8526                	mv	a0,s1
    8000242c:	ffffe097          	auipc	ra,0xffffe
    80002430:	7a6080e7          	jalr	1958(ra) # 80000bd2 <acquire>
        if(pp->state == ZOMBIE){
    80002434:	4c9c                	lw	a5,24(s1)
    80002436:	f74785e3          	beq	a5,s4,800023a0 <wait+0x4c>
        release(&pp->lock);
    8000243a:	8526                	mv	a0,s1
    8000243c:	fffff097          	auipc	ra,0xfffff
    80002440:	84a080e7          	jalr	-1974(ra) # 80000c86 <release>
        havekids = 1;
    80002444:	8756                	mv	a4,s5
    80002446:	bfd9                	j	8000241c <wait+0xc8>
    if(!havekids || killed(p)){
    80002448:	c31d                	beqz	a4,8000246e <wait+0x11a>
    8000244a:	854a                	mv	a0,s2
    8000244c:	00000097          	auipc	ra,0x0
    80002450:	ed6080e7          	jalr	-298(ra) # 80002322 <killed>
    80002454:	ed09                	bnez	a0,8000246e <wait+0x11a>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80002456:	85e2                	mv	a1,s8
    80002458:	854a                	mv	a0,s2
    8000245a:	00000097          	auipc	ra,0x0
    8000245e:	c20080e7          	jalr	-992(ra) # 8000207a <sleep>
    havekids = 0;
    80002462:	875e                	mv	a4,s7
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80002464:	0000f497          	auipc	s1,0xf
    80002468:	cac48493          	addi	s1,s1,-852 # 80011110 <proc>
    8000246c:	bf65                	j	80002424 <wait+0xd0>
      release(&wait_lock);
    8000246e:	0000f517          	auipc	a0,0xf
    80002472:	88a50513          	addi	a0,a0,-1910 # 80010cf8 <wait_lock>
    80002476:	fffff097          	auipc	ra,0xfffff
    8000247a:	810080e7          	jalr	-2032(ra) # 80000c86 <release>
      return -1;
    8000247e:	59fd                	li	s3,-1
    80002480:	b795                	j	800023e4 <wait+0x90>

0000000080002482 <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    80002482:	7179                	addi	sp,sp,-48
    80002484:	f406                	sd	ra,40(sp)
    80002486:	f022                	sd	s0,32(sp)
    80002488:	ec26                	sd	s1,24(sp)
    8000248a:	e84a                	sd	s2,16(sp)
    8000248c:	e44e                	sd	s3,8(sp)
    8000248e:	e052                	sd	s4,0(sp)
    80002490:	1800                	addi	s0,sp,48
    80002492:	84aa                	mv	s1,a0
    80002494:	892e                	mv	s2,a1
    80002496:	89b2                	mv	s3,a2
    80002498:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    8000249a:	fffff097          	auipc	ra,0xfffff
    8000249e:	530080e7          	jalr	1328(ra) # 800019ca <myproc>
  if(user_dst){
    800024a2:	c08d                	beqz	s1,800024c4 <either_copyout+0x42>
    return copyout(p->pagetable, dst, src, len);
    800024a4:	86d2                	mv	a3,s4
    800024a6:	864e                	mv	a2,s3
    800024a8:	85ca                	mv	a1,s2
    800024aa:	6928                	ld	a0,80(a0)
    800024ac:	fffff097          	auipc	ra,0xfffff
    800024b0:	1de080e7          	jalr	478(ra) # 8000168a <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    800024b4:	70a2                	ld	ra,40(sp)
    800024b6:	7402                	ld	s0,32(sp)
    800024b8:	64e2                	ld	s1,24(sp)
    800024ba:	6942                	ld	s2,16(sp)
    800024bc:	69a2                	ld	s3,8(sp)
    800024be:	6a02                	ld	s4,0(sp)
    800024c0:	6145                	addi	sp,sp,48
    800024c2:	8082                	ret
    memmove((char *)dst, src, len);
    800024c4:	000a061b          	sext.w	a2,s4
    800024c8:	85ce                	mv	a1,s3
    800024ca:	854a                	mv	a0,s2
    800024cc:	fffff097          	auipc	ra,0xfffff
    800024d0:	85e080e7          	jalr	-1954(ra) # 80000d2a <memmove>
    return 0;
    800024d4:	8526                	mv	a0,s1
    800024d6:	bff9                	j	800024b4 <either_copyout+0x32>

00000000800024d8 <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    800024d8:	7179                	addi	sp,sp,-48
    800024da:	f406                	sd	ra,40(sp)
    800024dc:	f022                	sd	s0,32(sp)
    800024de:	ec26                	sd	s1,24(sp)
    800024e0:	e84a                	sd	s2,16(sp)
    800024e2:	e44e                	sd	s3,8(sp)
    800024e4:	e052                	sd	s4,0(sp)
    800024e6:	1800                	addi	s0,sp,48
    800024e8:	892a                	mv	s2,a0
    800024ea:	84ae                	mv	s1,a1
    800024ec:	89b2                	mv	s3,a2
    800024ee:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800024f0:	fffff097          	auipc	ra,0xfffff
    800024f4:	4da080e7          	jalr	1242(ra) # 800019ca <myproc>
  if(user_src){
    800024f8:	c08d                	beqz	s1,8000251a <either_copyin+0x42>
    return copyin(p->pagetable, dst, src, len);
    800024fa:	86d2                	mv	a3,s4
    800024fc:	864e                	mv	a2,s3
    800024fe:	85ca                	mv	a1,s2
    80002500:	6928                	ld	a0,80(a0)
    80002502:	fffff097          	auipc	ra,0xfffff
    80002506:	214080e7          	jalr	532(ra) # 80001716 <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    8000250a:	70a2                	ld	ra,40(sp)
    8000250c:	7402                	ld	s0,32(sp)
    8000250e:	64e2                	ld	s1,24(sp)
    80002510:	6942                	ld	s2,16(sp)
    80002512:	69a2                	ld	s3,8(sp)
    80002514:	6a02                	ld	s4,0(sp)
    80002516:	6145                	addi	sp,sp,48
    80002518:	8082                	ret
    memmove(dst, (char*)src, len);
    8000251a:	000a061b          	sext.w	a2,s4
    8000251e:	85ce                	mv	a1,s3
    80002520:	854a                	mv	a0,s2
    80002522:	fffff097          	auipc	ra,0xfffff
    80002526:	808080e7          	jalr	-2040(ra) # 80000d2a <memmove>
    return 0;
    8000252a:	8526                	mv	a0,s1
    8000252c:	bff9                	j	8000250a <either_copyin+0x32>

000000008000252e <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    8000252e:	715d                	addi	sp,sp,-80
    80002530:	e486                	sd	ra,72(sp)
    80002532:	e0a2                	sd	s0,64(sp)
    80002534:	fc26                	sd	s1,56(sp)
    80002536:	f84a                	sd	s2,48(sp)
    80002538:	f44e                	sd	s3,40(sp)
    8000253a:	f052                	sd	s4,32(sp)
    8000253c:	ec56                	sd	s5,24(sp)
    8000253e:	e85a                	sd	s6,16(sp)
    80002540:	e45e                	sd	s7,8(sp)
    80002542:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    80002544:	00006517          	auipc	a0,0x6
    80002548:	49c50513          	addi	a0,a0,1180 # 800089e0 <syscalls+0x598>
    8000254c:	ffffe097          	auipc	ra,0xffffe
    80002550:	03a080e7          	jalr	58(ra) # 80000586 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002554:	0000f497          	auipc	s1,0xf
    80002558:	d1448493          	addi	s1,s1,-748 # 80011268 <proc+0x158>
    8000255c:	00014917          	auipc	s2,0x14
    80002560:	70c90913          	addi	s2,s2,1804 # 80016c68 <bcache+0x140>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002564:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    80002566:	00006997          	auipc	s3,0x6
    8000256a:	d1298993          	addi	s3,s3,-750 # 80008278 <digits+0x238>
    printf("%d %s %s", p->pid, state, p->name);
    8000256e:	00006a97          	auipc	s5,0x6
    80002572:	d12a8a93          	addi	s5,s5,-750 # 80008280 <digits+0x240>
    printf("\n");
    80002576:	00006a17          	auipc	s4,0x6
    8000257a:	46aa0a13          	addi	s4,s4,1130 # 800089e0 <syscalls+0x598>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000257e:	00006b97          	auipc	s7,0x6
    80002582:	d42b8b93          	addi	s7,s7,-702 # 800082c0 <states.0>
    80002586:	a00d                	j	800025a8 <procdump+0x7a>
    printf("%d %s %s", p->pid, state, p->name);
    80002588:	ed86a583          	lw	a1,-296(a3)
    8000258c:	8556                	mv	a0,s5
    8000258e:	ffffe097          	auipc	ra,0xffffe
    80002592:	ff8080e7          	jalr	-8(ra) # 80000586 <printf>
    printf("\n");
    80002596:	8552                	mv	a0,s4
    80002598:	ffffe097          	auipc	ra,0xffffe
    8000259c:	fee080e7          	jalr	-18(ra) # 80000586 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    800025a0:	16848493          	addi	s1,s1,360
    800025a4:	03248263          	beq	s1,s2,800025c8 <procdump+0x9a>
    if(p->state == UNUSED)
    800025a8:	86a6                	mv	a3,s1
    800025aa:	ec04a783          	lw	a5,-320(s1)
    800025ae:	dbed                	beqz	a5,800025a0 <procdump+0x72>
      state = "???";
    800025b0:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800025b2:	fcfb6be3          	bltu	s6,a5,80002588 <procdump+0x5a>
    800025b6:	02079713          	slli	a4,a5,0x20
    800025ba:	01d75793          	srli	a5,a4,0x1d
    800025be:	97de                	add	a5,a5,s7
    800025c0:	6390                	ld	a2,0(a5)
    800025c2:	f279                	bnez	a2,80002588 <procdump+0x5a>
      state = "???";
    800025c4:	864e                	mv	a2,s3
    800025c6:	b7c9                	j	80002588 <procdump+0x5a>
  }
}
    800025c8:	60a6                	ld	ra,72(sp)
    800025ca:	6406                	ld	s0,64(sp)
    800025cc:	74e2                	ld	s1,56(sp)
    800025ce:	7942                	ld	s2,48(sp)
    800025d0:	79a2                	ld	s3,40(sp)
    800025d2:	7a02                	ld	s4,32(sp)
    800025d4:	6ae2                	ld	s5,24(sp)
    800025d6:	6b42                	ld	s6,16(sp)
    800025d8:	6ba2                	ld	s7,8(sp)
    800025da:	6161                	addi	sp,sp,80
    800025dc:	8082                	ret

00000000800025de <swtch>:
    800025de:	00153023          	sd	ra,0(a0)
    800025e2:	00253423          	sd	sp,8(a0)
    800025e6:	e900                	sd	s0,16(a0)
    800025e8:	ed04                	sd	s1,24(a0)
    800025ea:	03253023          	sd	s2,32(a0)
    800025ee:	03353423          	sd	s3,40(a0)
    800025f2:	03453823          	sd	s4,48(a0)
    800025f6:	03553c23          	sd	s5,56(a0)
    800025fa:	05653023          	sd	s6,64(a0)
    800025fe:	05753423          	sd	s7,72(a0)
    80002602:	05853823          	sd	s8,80(a0)
    80002606:	05953c23          	sd	s9,88(a0)
    8000260a:	07a53023          	sd	s10,96(a0)
    8000260e:	07b53423          	sd	s11,104(a0)
    80002612:	0005b083          	ld	ra,0(a1)
    80002616:	0085b103          	ld	sp,8(a1)
    8000261a:	6980                	ld	s0,16(a1)
    8000261c:	6d84                	ld	s1,24(a1)
    8000261e:	0205b903          	ld	s2,32(a1)
    80002622:	0285b983          	ld	s3,40(a1)
    80002626:	0305ba03          	ld	s4,48(a1)
    8000262a:	0385ba83          	ld	s5,56(a1)
    8000262e:	0405bb03          	ld	s6,64(a1)
    80002632:	0485bb83          	ld	s7,72(a1)
    80002636:	0505bc03          	ld	s8,80(a1)
    8000263a:	0585bc83          	ld	s9,88(a1)
    8000263e:	0605bd03          	ld	s10,96(a1)
    80002642:	0685bd83          	ld	s11,104(a1)
    80002646:	8082                	ret

0000000080002648 <trapinit>:

extern int devintr();

void
trapinit(void)
{
    80002648:	1141                	addi	sp,sp,-16
    8000264a:	e406                	sd	ra,8(sp)
    8000264c:	e022                	sd	s0,0(sp)
    8000264e:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80002650:	00006597          	auipc	a1,0x6
    80002654:	ca058593          	addi	a1,a1,-864 # 800082f0 <states.0+0x30>
    80002658:	00014517          	auipc	a0,0x14
    8000265c:	4b850513          	addi	a0,a0,1208 # 80016b10 <tickslock>
    80002660:	ffffe097          	auipc	ra,0xffffe
    80002664:	4e2080e7          	jalr	1250(ra) # 80000b42 <initlock>
}
    80002668:	60a2                	ld	ra,8(sp)
    8000266a:	6402                	ld	s0,0(sp)
    8000266c:	0141                	addi	sp,sp,16
    8000266e:	8082                	ret

0000000080002670 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    80002670:	1141                	addi	sp,sp,-16
    80002672:	e422                	sd	s0,8(sp)
    80002674:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002676:	00003797          	auipc	a5,0x3
    8000267a:	46a78793          	addi	a5,a5,1130 # 80005ae0 <kernelvec>
    8000267e:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80002682:	6422                	ld	s0,8(sp)
    80002684:	0141                	addi	sp,sp,16
    80002686:	8082                	ret

0000000080002688 <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    80002688:	1141                	addi	sp,sp,-16
    8000268a:	e406                	sd	ra,8(sp)
    8000268c:	e022                	sd	s0,0(sp)
    8000268e:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80002690:	fffff097          	auipc	ra,0xfffff
    80002694:	33a080e7          	jalr	826(ra) # 800019ca <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002698:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    8000269c:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000269e:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    800026a2:	00005697          	auipc	a3,0x5
    800026a6:	95e68693          	addi	a3,a3,-1698 # 80007000 <_trampoline>
    800026aa:	00005717          	auipc	a4,0x5
    800026ae:	95670713          	addi	a4,a4,-1706 # 80007000 <_trampoline>
    800026b2:	8f15                	sub	a4,a4,a3
    800026b4:	040007b7          	lui	a5,0x4000
    800026b8:	17fd                	addi	a5,a5,-1 # 3ffffff <_entry-0x7c000001>
    800026ba:	07b2                	slli	a5,a5,0xc
    800026bc:	973e                	add	a4,a4,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    800026be:	10571073          	csrw	stvec,a4
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    800026c2:	6d38                	ld	a4,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    800026c4:	18002673          	csrr	a2,satp
    800026c8:	e310                	sd	a2,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    800026ca:	6d30                	ld	a2,88(a0)
    800026cc:	6138                	ld	a4,64(a0)
    800026ce:	6585                	lui	a1,0x1
    800026d0:	972e                	add	a4,a4,a1
    800026d2:	e618                	sd	a4,8(a2)
  p->trapframe->kernel_trap = (uint64)usertrap;
    800026d4:	6d38                	ld	a4,88(a0)
    800026d6:	00000617          	auipc	a2,0x0
    800026da:	13460613          	addi	a2,a2,308 # 8000280a <usertrap>
    800026de:	eb10                	sd	a2,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    800026e0:	6d38                	ld	a4,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    800026e2:	8612                	mv	a2,tp
    800026e4:	f310                	sd	a2,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800026e6:	10002773          	csrr	a4,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    800026ea:	eff77713          	andi	a4,a4,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    800026ee:	02076713          	ori	a4,a4,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800026f2:	10071073          	csrw	sstatus,a4
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    800026f6:	6d38                	ld	a4,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    800026f8:	6f18                	ld	a4,24(a4)
    800026fa:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    800026fe:	6928                	ld	a0,80(a0)
    80002700:	8131                	srli	a0,a0,0xc

  // jump to userret in trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    80002702:	00005717          	auipc	a4,0x5
    80002706:	99a70713          	addi	a4,a4,-1638 # 8000709c <userret>
    8000270a:	8f15                	sub	a4,a4,a3
    8000270c:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    8000270e:	577d                	li	a4,-1
    80002710:	177e                	slli	a4,a4,0x3f
    80002712:	8d59                	or	a0,a0,a4
    80002714:	9782                	jalr	a5
}
    80002716:	60a2                	ld	ra,8(sp)
    80002718:	6402                	ld	s0,0(sp)
    8000271a:	0141                	addi	sp,sp,16
    8000271c:	8082                	ret

000000008000271e <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    8000271e:	1101                	addi	sp,sp,-32
    80002720:	ec06                	sd	ra,24(sp)
    80002722:	e822                	sd	s0,16(sp)
    80002724:	e426                	sd	s1,8(sp)
    80002726:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    80002728:	00014497          	auipc	s1,0x14
    8000272c:	3e848493          	addi	s1,s1,1000 # 80016b10 <tickslock>
    80002730:	8526                	mv	a0,s1
    80002732:	ffffe097          	auipc	ra,0xffffe
    80002736:	4a0080e7          	jalr	1184(ra) # 80000bd2 <acquire>
  ticks++;
    8000273a:	00006517          	auipc	a0,0x6
    8000273e:	33650513          	addi	a0,a0,822 # 80008a70 <ticks>
    80002742:	411c                	lw	a5,0(a0)
    80002744:	2785                	addiw	a5,a5,1
    80002746:	c11c                	sw	a5,0(a0)
  wakeup(&ticks);
    80002748:	00000097          	auipc	ra,0x0
    8000274c:	996080e7          	jalr	-1642(ra) # 800020de <wakeup>
  release(&tickslock);
    80002750:	8526                	mv	a0,s1
    80002752:	ffffe097          	auipc	ra,0xffffe
    80002756:	534080e7          	jalr	1332(ra) # 80000c86 <release>
}
    8000275a:	60e2                	ld	ra,24(sp)
    8000275c:	6442                	ld	s0,16(sp)
    8000275e:	64a2                	ld	s1,8(sp)
    80002760:	6105                	addi	sp,sp,32
    80002762:	8082                	ret

0000000080002764 <devintr>:
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002764:	142027f3          	csrr	a5,scause
    // the SSIP bit in sip.
    w_sip(r_sip() & ~2);

    return 2;
  } else {
    return 0;
    80002768:	4501                	li	a0,0
  if((scause & 0x8000000000000000L) &&
    8000276a:	0807df63          	bgez	a5,80002808 <devintr+0xa4>
{
    8000276e:	1101                	addi	sp,sp,-32
    80002770:	ec06                	sd	ra,24(sp)
    80002772:	e822                	sd	s0,16(sp)
    80002774:	e426                	sd	s1,8(sp)
    80002776:	1000                	addi	s0,sp,32
     (scause & 0xff) == 9){
    80002778:	0ff7f713          	zext.b	a4,a5
  if((scause & 0x8000000000000000L) &&
    8000277c:	46a5                	li	a3,9
    8000277e:	00d70d63          	beq	a4,a3,80002798 <devintr+0x34>
  } else if(scause == 0x8000000000000001L){
    80002782:	577d                	li	a4,-1
    80002784:	177e                	slli	a4,a4,0x3f
    80002786:	0705                	addi	a4,a4,1
    return 0;
    80002788:	4501                	li	a0,0
  } else if(scause == 0x8000000000000001L){
    8000278a:	04e78e63          	beq	a5,a4,800027e6 <devintr+0x82>
  }
}
    8000278e:	60e2                	ld	ra,24(sp)
    80002790:	6442                	ld	s0,16(sp)
    80002792:	64a2                	ld	s1,8(sp)
    80002794:	6105                	addi	sp,sp,32
    80002796:	8082                	ret
    int irq = plic_claim();
    80002798:	00003097          	auipc	ra,0x3
    8000279c:	450080e7          	jalr	1104(ra) # 80005be8 <plic_claim>
    800027a0:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    800027a2:	47a9                	li	a5,10
    800027a4:	02f50763          	beq	a0,a5,800027d2 <devintr+0x6e>
    } else if(irq == VIRTIO0_IRQ){
    800027a8:	4785                	li	a5,1
    800027aa:	02f50963          	beq	a0,a5,800027dc <devintr+0x78>
    return 1;
    800027ae:	4505                	li	a0,1
    } else if(irq){
    800027b0:	dcf9                	beqz	s1,8000278e <devintr+0x2a>
      printf("unexpected interrupt irq=%d\n", irq);
    800027b2:	85a6                	mv	a1,s1
    800027b4:	00006517          	auipc	a0,0x6
    800027b8:	b4450513          	addi	a0,a0,-1212 # 800082f8 <states.0+0x38>
    800027bc:	ffffe097          	auipc	ra,0xffffe
    800027c0:	dca080e7          	jalr	-566(ra) # 80000586 <printf>
      plic_complete(irq);
    800027c4:	8526                	mv	a0,s1
    800027c6:	00003097          	auipc	ra,0x3
    800027ca:	446080e7          	jalr	1094(ra) # 80005c0c <plic_complete>
    return 1;
    800027ce:	4505                	li	a0,1
    800027d0:	bf7d                	j	8000278e <devintr+0x2a>
      uartintr();
    800027d2:	ffffe097          	auipc	ra,0xffffe
    800027d6:	1c2080e7          	jalr	450(ra) # 80000994 <uartintr>
    if(irq)
    800027da:	b7ed                	j	800027c4 <devintr+0x60>
      virtio_disk_intr();
    800027dc:	00004097          	auipc	ra,0x4
    800027e0:	8f6080e7          	jalr	-1802(ra) # 800060d2 <virtio_disk_intr>
    if(irq)
    800027e4:	b7c5                	j	800027c4 <devintr+0x60>
    if(cpuid() == 0){
    800027e6:	fffff097          	auipc	ra,0xfffff
    800027ea:	1b8080e7          	jalr	440(ra) # 8000199e <cpuid>
    800027ee:	c901                	beqz	a0,800027fe <devintr+0x9a>
  asm volatile("csrr %0, sip" : "=r" (x) );
    800027f0:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    800027f4:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    800027f6:	14479073          	csrw	sip,a5
    return 2;
    800027fa:	4509                	li	a0,2
    800027fc:	bf49                	j	8000278e <devintr+0x2a>
      clockintr();
    800027fe:	00000097          	auipc	ra,0x0
    80002802:	f20080e7          	jalr	-224(ra) # 8000271e <clockintr>
    80002806:	b7ed                	j	800027f0 <devintr+0x8c>
}
    80002808:	8082                	ret

000000008000280a <usertrap>:
{
    8000280a:	1101                	addi	sp,sp,-32
    8000280c:	ec06                	sd	ra,24(sp)
    8000280e:	e822                	sd	s0,16(sp)
    80002810:	e426                	sd	s1,8(sp)
    80002812:	e04a                	sd	s2,0(sp)
    80002814:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002816:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    8000281a:	1007f793          	andi	a5,a5,256
    8000281e:	e3b1                	bnez	a5,80002862 <usertrap+0x58>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002820:	00003797          	auipc	a5,0x3
    80002824:	2c078793          	addi	a5,a5,704 # 80005ae0 <kernelvec>
    80002828:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    8000282c:	fffff097          	auipc	ra,0xfffff
    80002830:	19e080e7          	jalr	414(ra) # 800019ca <myproc>
    80002834:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80002836:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002838:	14102773          	csrr	a4,sepc
    8000283c:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    8000283e:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80002842:	47a1                	li	a5,8
    80002844:	02f70763          	beq	a4,a5,80002872 <usertrap+0x68>
  } else if((which_dev = devintr()) != 0){
    80002848:	00000097          	auipc	ra,0x0
    8000284c:	f1c080e7          	jalr	-228(ra) # 80002764 <devintr>
    80002850:	892a                	mv	s2,a0
    80002852:	c151                	beqz	a0,800028d6 <usertrap+0xcc>
  if(killed(p))
    80002854:	8526                	mv	a0,s1
    80002856:	00000097          	auipc	ra,0x0
    8000285a:	acc080e7          	jalr	-1332(ra) # 80002322 <killed>
    8000285e:	c929                	beqz	a0,800028b0 <usertrap+0xa6>
    80002860:	a099                	j	800028a6 <usertrap+0x9c>
    panic("usertrap: not from user mode");
    80002862:	00006517          	auipc	a0,0x6
    80002866:	ab650513          	addi	a0,a0,-1354 # 80008318 <states.0+0x58>
    8000286a:	ffffe097          	auipc	ra,0xffffe
    8000286e:	cd2080e7          	jalr	-814(ra) # 8000053c <panic>
    if(killed(p))
    80002872:	00000097          	auipc	ra,0x0
    80002876:	ab0080e7          	jalr	-1360(ra) # 80002322 <killed>
    8000287a:	e921                	bnez	a0,800028ca <usertrap+0xc0>
    p->trapframe->epc += 4;
    8000287c:	6cb8                	ld	a4,88(s1)
    8000287e:	6f1c                	ld	a5,24(a4)
    80002880:	0791                	addi	a5,a5,4
    80002882:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002884:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002888:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000288c:	10079073          	csrw	sstatus,a5
    syscall();
    80002890:	00000097          	auipc	ra,0x0
    80002894:	2d4080e7          	jalr	724(ra) # 80002b64 <syscall>
  if(killed(p))
    80002898:	8526                	mv	a0,s1
    8000289a:	00000097          	auipc	ra,0x0
    8000289e:	a88080e7          	jalr	-1400(ra) # 80002322 <killed>
    800028a2:	c911                	beqz	a0,800028b6 <usertrap+0xac>
    800028a4:	4901                	li	s2,0
    exit(-1);
    800028a6:	557d                	li	a0,-1
    800028a8:	00000097          	auipc	ra,0x0
    800028ac:	906080e7          	jalr	-1786(ra) # 800021ae <exit>
  if(which_dev == 2)
    800028b0:	4789                	li	a5,2
    800028b2:	04f90f63          	beq	s2,a5,80002910 <usertrap+0x106>
  usertrapret();
    800028b6:	00000097          	auipc	ra,0x0
    800028ba:	dd2080e7          	jalr	-558(ra) # 80002688 <usertrapret>
}
    800028be:	60e2                	ld	ra,24(sp)
    800028c0:	6442                	ld	s0,16(sp)
    800028c2:	64a2                	ld	s1,8(sp)
    800028c4:	6902                	ld	s2,0(sp)
    800028c6:	6105                	addi	sp,sp,32
    800028c8:	8082                	ret
      exit(-1);
    800028ca:	557d                	li	a0,-1
    800028cc:	00000097          	auipc	ra,0x0
    800028d0:	8e2080e7          	jalr	-1822(ra) # 800021ae <exit>
    800028d4:	b765                	j	8000287c <usertrap+0x72>
  asm volatile("csrr %0, scause" : "=r" (x) );
    800028d6:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    800028da:	5890                	lw	a2,48(s1)
    800028dc:	00006517          	auipc	a0,0x6
    800028e0:	a5c50513          	addi	a0,a0,-1444 # 80008338 <states.0+0x78>
    800028e4:	ffffe097          	auipc	ra,0xffffe
    800028e8:	ca2080e7          	jalr	-862(ra) # 80000586 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800028ec:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    800028f0:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    800028f4:	00006517          	auipc	a0,0x6
    800028f8:	a7450513          	addi	a0,a0,-1420 # 80008368 <states.0+0xa8>
    800028fc:	ffffe097          	auipc	ra,0xffffe
    80002900:	c8a080e7          	jalr	-886(ra) # 80000586 <printf>
    setkilled(p);
    80002904:	8526                	mv	a0,s1
    80002906:	00000097          	auipc	ra,0x0
    8000290a:	9f0080e7          	jalr	-1552(ra) # 800022f6 <setkilled>
    8000290e:	b769                	j	80002898 <usertrap+0x8e>
    yield();
    80002910:	fffff097          	auipc	ra,0xfffff
    80002914:	72e080e7          	jalr	1838(ra) # 8000203e <yield>
    80002918:	bf79                	j	800028b6 <usertrap+0xac>

000000008000291a <kerneltrap>:
{
    8000291a:	7179                	addi	sp,sp,-48
    8000291c:	f406                	sd	ra,40(sp)
    8000291e:	f022                	sd	s0,32(sp)
    80002920:	ec26                	sd	s1,24(sp)
    80002922:	e84a                	sd	s2,16(sp)
    80002924:	e44e                	sd	s3,8(sp)
    80002926:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002928:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000292c:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002930:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80002934:	1004f793          	andi	a5,s1,256
    80002938:	cb85                	beqz	a5,80002968 <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000293a:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    8000293e:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80002940:	ef85                	bnez	a5,80002978 <kerneltrap+0x5e>
  if((which_dev = devintr()) == 0){
    80002942:	00000097          	auipc	ra,0x0
    80002946:	e22080e7          	jalr	-478(ra) # 80002764 <devintr>
    8000294a:	cd1d                	beqz	a0,80002988 <kerneltrap+0x6e>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING) {
    8000294c:	4789                	li	a5,2
    8000294e:	06f50a63          	beq	a0,a5,800029c2 <kerneltrap+0xa8>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002952:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002956:	10049073          	csrw	sstatus,s1
}
    8000295a:	70a2                	ld	ra,40(sp)
    8000295c:	7402                	ld	s0,32(sp)
    8000295e:	64e2                	ld	s1,24(sp)
    80002960:	6942                	ld	s2,16(sp)
    80002962:	69a2                	ld	s3,8(sp)
    80002964:	6145                	addi	sp,sp,48
    80002966:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002968:	00006517          	auipc	a0,0x6
    8000296c:	a2050513          	addi	a0,a0,-1504 # 80008388 <states.0+0xc8>
    80002970:	ffffe097          	auipc	ra,0xffffe
    80002974:	bcc080e7          	jalr	-1076(ra) # 8000053c <panic>
    panic("kerneltrap: interrupts enabled");
    80002978:	00006517          	auipc	a0,0x6
    8000297c:	a3850513          	addi	a0,a0,-1480 # 800083b0 <states.0+0xf0>
    80002980:	ffffe097          	auipc	ra,0xffffe
    80002984:	bbc080e7          	jalr	-1092(ra) # 8000053c <panic>
    printf("scause %p\n", scause);
    80002988:	85ce                	mv	a1,s3
    8000298a:	00006517          	auipc	a0,0x6
    8000298e:	a4650513          	addi	a0,a0,-1466 # 800083d0 <states.0+0x110>
    80002992:	ffffe097          	auipc	ra,0xffffe
    80002996:	bf4080e7          	jalr	-1036(ra) # 80000586 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    8000299a:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    8000299e:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    800029a2:	00006517          	auipc	a0,0x6
    800029a6:	a3e50513          	addi	a0,a0,-1474 # 800083e0 <states.0+0x120>
    800029aa:	ffffe097          	auipc	ra,0xffffe
    800029ae:	bdc080e7          	jalr	-1060(ra) # 80000586 <printf>
    panic("kerneltrap");
    800029b2:	00006517          	auipc	a0,0x6
    800029b6:	a4650513          	addi	a0,a0,-1466 # 800083f8 <states.0+0x138>
    800029ba:	ffffe097          	auipc	ra,0xffffe
    800029be:	b82080e7          	jalr	-1150(ra) # 8000053c <panic>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING) {
    800029c2:	fffff097          	auipc	ra,0xfffff
    800029c6:	008080e7          	jalr	8(ra) # 800019ca <myproc>
    800029ca:	d541                	beqz	a0,80002952 <kerneltrap+0x38>
    800029cc:	fffff097          	auipc	ra,0xfffff
    800029d0:	ffe080e7          	jalr	-2(ra) # 800019ca <myproc>
    800029d4:	4d18                	lw	a4,24(a0)
    800029d6:	4791                	li	a5,4
    800029d8:	f6f71de3          	bne	a4,a5,80002952 <kerneltrap+0x38>
    yield();
    800029dc:	fffff097          	auipc	ra,0xfffff
    800029e0:	662080e7          	jalr	1634(ra) # 8000203e <yield>
    800029e4:	b7bd                	j	80002952 <kerneltrap+0x38>

00000000800029e6 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    800029e6:	1101                	addi	sp,sp,-32
    800029e8:	ec06                	sd	ra,24(sp)
    800029ea:	e822                	sd	s0,16(sp)
    800029ec:	e426                	sd	s1,8(sp)
    800029ee:	1000                	addi	s0,sp,32
    800029f0:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    800029f2:	fffff097          	auipc	ra,0xfffff
    800029f6:	fd8080e7          	jalr	-40(ra) # 800019ca <myproc>
  switch (n)
    800029fa:	4795                	li	a5,5
    800029fc:	0497e163          	bltu	a5,s1,80002a3e <argraw+0x58>
    80002a00:	048a                	slli	s1,s1,0x2
    80002a02:	00006717          	auipc	a4,0x6
    80002a06:	a2e70713          	addi	a4,a4,-1490 # 80008430 <states.0+0x170>
    80002a0a:	94ba                	add	s1,s1,a4
    80002a0c:	409c                	lw	a5,0(s1)
    80002a0e:	97ba                	add	a5,a5,a4
    80002a10:	8782                	jr	a5
  {
  case 0:
    return p->trapframe->a0;
    80002a12:	6d3c                	ld	a5,88(a0)
    80002a14:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002a16:	60e2                	ld	ra,24(sp)
    80002a18:	6442                	ld	s0,16(sp)
    80002a1a:	64a2                	ld	s1,8(sp)
    80002a1c:	6105                	addi	sp,sp,32
    80002a1e:	8082                	ret
    return p->trapframe->a1;
    80002a20:	6d3c                	ld	a5,88(a0)
    80002a22:	7fa8                	ld	a0,120(a5)
    80002a24:	bfcd                	j	80002a16 <argraw+0x30>
    return p->trapframe->a2;
    80002a26:	6d3c                	ld	a5,88(a0)
    80002a28:	63c8                	ld	a0,128(a5)
    80002a2a:	b7f5                	j	80002a16 <argraw+0x30>
    return p->trapframe->a3;
    80002a2c:	6d3c                	ld	a5,88(a0)
    80002a2e:	67c8                	ld	a0,136(a5)
    80002a30:	b7dd                	j	80002a16 <argraw+0x30>
    return p->trapframe->a4;
    80002a32:	6d3c                	ld	a5,88(a0)
    80002a34:	6bc8                	ld	a0,144(a5)
    80002a36:	b7c5                	j	80002a16 <argraw+0x30>
    return p->trapframe->a5;
    80002a38:	6d3c                	ld	a5,88(a0)
    80002a3a:	6fc8                	ld	a0,152(a5)
    80002a3c:	bfe9                	j	80002a16 <argraw+0x30>
  panic("argraw");
    80002a3e:	00006517          	auipc	a0,0x6
    80002a42:	9ca50513          	addi	a0,a0,-1590 # 80008408 <states.0+0x148>
    80002a46:	ffffe097          	auipc	ra,0xffffe
    80002a4a:	af6080e7          	jalr	-1290(ra) # 8000053c <panic>

0000000080002a4e <fetchaddr>:
{
    80002a4e:	1101                	addi	sp,sp,-32
    80002a50:	ec06                	sd	ra,24(sp)
    80002a52:	e822                	sd	s0,16(sp)
    80002a54:	e426                	sd	s1,8(sp)
    80002a56:	e04a                	sd	s2,0(sp)
    80002a58:	1000                	addi	s0,sp,32
    80002a5a:	84aa                	mv	s1,a0
    80002a5c:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002a5e:	fffff097          	auipc	ra,0xfffff
    80002a62:	f6c080e7          	jalr	-148(ra) # 800019ca <myproc>
  if (addr >= p->sz || addr + sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    80002a66:	653c                	ld	a5,72(a0)
    80002a68:	02f4f863          	bgeu	s1,a5,80002a98 <fetchaddr+0x4a>
    80002a6c:	00848713          	addi	a4,s1,8
    80002a70:	02e7e663          	bltu	a5,a4,80002a9c <fetchaddr+0x4e>
  if (copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002a74:	46a1                	li	a3,8
    80002a76:	8626                	mv	a2,s1
    80002a78:	85ca                	mv	a1,s2
    80002a7a:	6928                	ld	a0,80(a0)
    80002a7c:	fffff097          	auipc	ra,0xfffff
    80002a80:	c9a080e7          	jalr	-870(ra) # 80001716 <copyin>
    80002a84:	00a03533          	snez	a0,a0
    80002a88:	40a00533          	neg	a0,a0
}
    80002a8c:	60e2                	ld	ra,24(sp)
    80002a8e:	6442                	ld	s0,16(sp)
    80002a90:	64a2                	ld	s1,8(sp)
    80002a92:	6902                	ld	s2,0(sp)
    80002a94:	6105                	addi	sp,sp,32
    80002a96:	8082                	ret
    return -1;
    80002a98:	557d                	li	a0,-1
    80002a9a:	bfcd                	j	80002a8c <fetchaddr+0x3e>
    80002a9c:	557d                	li	a0,-1
    80002a9e:	b7fd                	j	80002a8c <fetchaddr+0x3e>

0000000080002aa0 <fetchstr>:
{
    80002aa0:	7179                	addi	sp,sp,-48
    80002aa2:	f406                	sd	ra,40(sp)
    80002aa4:	f022                	sd	s0,32(sp)
    80002aa6:	ec26                	sd	s1,24(sp)
    80002aa8:	e84a                	sd	s2,16(sp)
    80002aaa:	e44e                	sd	s3,8(sp)
    80002aac:	1800                	addi	s0,sp,48
    80002aae:	892a                	mv	s2,a0
    80002ab0:	84ae                	mv	s1,a1
    80002ab2:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80002ab4:	fffff097          	auipc	ra,0xfffff
    80002ab8:	f16080e7          	jalr	-234(ra) # 800019ca <myproc>
  if (copyinstr(p->pagetable, buf, addr, max) < 0)
    80002abc:	86ce                	mv	a3,s3
    80002abe:	864a                	mv	a2,s2
    80002ac0:	85a6                	mv	a1,s1
    80002ac2:	6928                	ld	a0,80(a0)
    80002ac4:	fffff097          	auipc	ra,0xfffff
    80002ac8:	ce0080e7          	jalr	-800(ra) # 800017a4 <copyinstr>
    80002acc:	00054e63          	bltz	a0,80002ae8 <fetchstr+0x48>
  return strlen(buf);
    80002ad0:	8526                	mv	a0,s1
    80002ad2:	ffffe097          	auipc	ra,0xffffe
    80002ad6:	376080e7          	jalr	886(ra) # 80000e48 <strlen>
}
    80002ada:	70a2                	ld	ra,40(sp)
    80002adc:	7402                	ld	s0,32(sp)
    80002ade:	64e2                	ld	s1,24(sp)
    80002ae0:	6942                	ld	s2,16(sp)
    80002ae2:	69a2                	ld	s3,8(sp)
    80002ae4:	6145                	addi	sp,sp,48
    80002ae6:	8082                	ret
    return -1;
    80002ae8:	557d                	li	a0,-1
    80002aea:	bfc5                	j	80002ada <fetchstr+0x3a>

0000000080002aec <argint>:

// Fetch the nth 32-bit system call argument.
void argint(int n, int *ip)
{
    80002aec:	1101                	addi	sp,sp,-32
    80002aee:	ec06                	sd	ra,24(sp)
    80002af0:	e822                	sd	s0,16(sp)
    80002af2:	e426                	sd	s1,8(sp)
    80002af4:	1000                	addi	s0,sp,32
    80002af6:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002af8:	00000097          	auipc	ra,0x0
    80002afc:	eee080e7          	jalr	-274(ra) # 800029e6 <argraw>
    80002b00:	c088                	sw	a0,0(s1)
}
    80002b02:	60e2                	ld	ra,24(sp)
    80002b04:	6442                	ld	s0,16(sp)
    80002b06:	64a2                	ld	s1,8(sp)
    80002b08:	6105                	addi	sp,sp,32
    80002b0a:	8082                	ret

0000000080002b0c <argaddr>:

// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void argaddr(int n, uint64 *ip)
{
    80002b0c:	1101                	addi	sp,sp,-32
    80002b0e:	ec06                	sd	ra,24(sp)
    80002b10:	e822                	sd	s0,16(sp)
    80002b12:	e426                	sd	s1,8(sp)
    80002b14:	1000                	addi	s0,sp,32
    80002b16:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002b18:	00000097          	auipc	ra,0x0
    80002b1c:	ece080e7          	jalr	-306(ra) # 800029e6 <argraw>
    80002b20:	e088                	sd	a0,0(s1)
}
    80002b22:	60e2                	ld	ra,24(sp)
    80002b24:	6442                	ld	s0,16(sp)
    80002b26:	64a2                	ld	s1,8(sp)
    80002b28:	6105                	addi	sp,sp,32
    80002b2a:	8082                	ret

0000000080002b2c <argstr>:

// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int argstr(int n, char *buf, int max)
{
    80002b2c:	7179                	addi	sp,sp,-48
    80002b2e:	f406                	sd	ra,40(sp)
    80002b30:	f022                	sd	s0,32(sp)
    80002b32:	ec26                	sd	s1,24(sp)
    80002b34:	e84a                	sd	s2,16(sp)
    80002b36:	1800                	addi	s0,sp,48
    80002b38:	84ae                	mv	s1,a1
    80002b3a:	8932                	mv	s2,a2
  uint64 addr;
  argaddr(n, &addr);
    80002b3c:	fd840593          	addi	a1,s0,-40
    80002b40:	00000097          	auipc	ra,0x0
    80002b44:	fcc080e7          	jalr	-52(ra) # 80002b0c <argaddr>
  return fetchstr(addr, buf, max);
    80002b48:	864a                	mv	a2,s2
    80002b4a:	85a6                	mv	a1,s1
    80002b4c:	fd843503          	ld	a0,-40(s0)
    80002b50:	00000097          	auipc	ra,0x0
    80002b54:	f50080e7          	jalr	-176(ra) # 80002aa0 <fetchstr>
}
    80002b58:	70a2                	ld	ra,40(sp)
    80002b5a:	7402                	ld	s0,32(sp)
    80002b5c:	64e2                	ld	s1,24(sp)
    80002b5e:	6942                	ld	s2,16(sp)
    80002b60:	6145                	addi	sp,sp,48
    80002b62:	8082                	ret

0000000080002b64 <syscall>:
    [SYS_close] sys_close,
    [SYS_ctime] sys_ctime,
};

void syscall(void)
{
    80002b64:	1101                	addi	sp,sp,-32
    80002b66:	ec06                	sd	ra,24(sp)
    80002b68:	e822                	sd	s0,16(sp)
    80002b6a:	e426                	sd	s1,8(sp)
    80002b6c:	e04a                	sd	s2,0(sp)
    80002b6e:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80002b70:	fffff097          	auipc	ra,0xfffff
    80002b74:	e5a080e7          	jalr	-422(ra) # 800019ca <myproc>
    80002b78:	84aa                	mv	s1,a0
  num = p->trapframe->a7;
    80002b7a:	05853903          	ld	s2,88(a0)
    80002b7e:	0a893783          	ld	a5,168(s2)
    80002b82:	0007869b          	sext.w	a3,a5

  /* Adil: debugging */
  if (num > 0 && num < NELEM(syscalls) && syscalls[num])
    80002b86:	37fd                	addiw	a5,a5,-1
    80002b88:	4755                	li	a4,21
    80002b8a:	00f76f63          	bltu	a4,a5,80002ba8 <syscall+0x44>
    80002b8e:	00369713          	slli	a4,a3,0x3
    80002b92:	00006797          	auipc	a5,0x6
    80002b96:	8b678793          	addi	a5,a5,-1866 # 80008448 <syscalls>
    80002b9a:	97ba                	add	a5,a5,a4
    80002b9c:	639c                	ld	a5,0(a5)
    80002b9e:	c789                	beqz	a5,80002ba8 <syscall+0x44>
  {
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    80002ba0:	9782                	jalr	a5
    80002ba2:	06a93823          	sd	a0,112(s2)
    80002ba6:	a839                	j	80002bc4 <syscall+0x60>
  }
  else
  {
    printf("%d %s: unknown sys call %d\n",
    80002ba8:	15848613          	addi	a2,s1,344
    80002bac:	588c                	lw	a1,48(s1)
    80002bae:	00006517          	auipc	a0,0x6
    80002bb2:	86250513          	addi	a0,a0,-1950 # 80008410 <states.0+0x150>
    80002bb6:	ffffe097          	auipc	ra,0xffffe
    80002bba:	9d0080e7          	jalr	-1584(ra) # 80000586 <printf>
           p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80002bbe:	6cbc                	ld	a5,88(s1)
    80002bc0:	577d                	li	a4,-1
    80002bc2:	fbb8                	sd	a4,112(a5)
  }
}
    80002bc4:	60e2                	ld	ra,24(sp)
    80002bc6:	6442                	ld	s0,16(sp)
    80002bc8:	64a2                	ld	s1,8(sp)
    80002bca:	6902                	ld	s2,0(sp)
    80002bcc:	6105                	addi	sp,sp,32
    80002bce:	8082                	ret

0000000080002bd0 <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    80002bd0:	1101                	addi	sp,sp,-32
    80002bd2:	ec06                	sd	ra,24(sp)
    80002bd4:	e822                	sd	s0,16(sp)
    80002bd6:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    80002bd8:	fec40593          	addi	a1,s0,-20
    80002bdc:	4501                	li	a0,0
    80002bde:	00000097          	auipc	ra,0x0
    80002be2:	f0e080e7          	jalr	-242(ra) # 80002aec <argint>
  exit(n);
    80002be6:	fec42503          	lw	a0,-20(s0)
    80002bea:	fffff097          	auipc	ra,0xfffff
    80002bee:	5c4080e7          	jalr	1476(ra) # 800021ae <exit>
  return 0; // not reached
}
    80002bf2:	4501                	li	a0,0
    80002bf4:	60e2                	ld	ra,24(sp)
    80002bf6:	6442                	ld	s0,16(sp)
    80002bf8:	6105                	addi	sp,sp,32
    80002bfa:	8082                	ret

0000000080002bfc <sys_getpid>:

uint64
sys_getpid(void)
{
    80002bfc:	1141                	addi	sp,sp,-16
    80002bfe:	e406                	sd	ra,8(sp)
    80002c00:	e022                	sd	s0,0(sp)
    80002c02:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80002c04:	fffff097          	auipc	ra,0xfffff
    80002c08:	dc6080e7          	jalr	-570(ra) # 800019ca <myproc>
}
    80002c0c:	5908                	lw	a0,48(a0)
    80002c0e:	60a2                	ld	ra,8(sp)
    80002c10:	6402                	ld	s0,0(sp)
    80002c12:	0141                	addi	sp,sp,16
    80002c14:	8082                	ret

0000000080002c16 <sys_fork>:

uint64
sys_fork(void)
{
    80002c16:	1141                	addi	sp,sp,-16
    80002c18:	e406                	sd	ra,8(sp)
    80002c1a:	e022                	sd	s0,0(sp)
    80002c1c:	0800                	addi	s0,sp,16
  return fork();
    80002c1e:	fffff097          	auipc	ra,0xfffff
    80002c22:	16a080e7          	jalr	362(ra) # 80001d88 <fork>
}
    80002c26:	60a2                	ld	ra,8(sp)
    80002c28:	6402                	ld	s0,0(sp)
    80002c2a:	0141                	addi	sp,sp,16
    80002c2c:	8082                	ret

0000000080002c2e <sys_wait>:

uint64
sys_wait(void)
{
    80002c2e:	1101                	addi	sp,sp,-32
    80002c30:	ec06                	sd	ra,24(sp)
    80002c32:	e822                	sd	s0,16(sp)
    80002c34:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    80002c36:	fe840593          	addi	a1,s0,-24
    80002c3a:	4501                	li	a0,0
    80002c3c:	00000097          	auipc	ra,0x0
    80002c40:	ed0080e7          	jalr	-304(ra) # 80002b0c <argaddr>
  return wait(p);
    80002c44:	fe843503          	ld	a0,-24(s0)
    80002c48:	fffff097          	auipc	ra,0xfffff
    80002c4c:	70c080e7          	jalr	1804(ra) # 80002354 <wait>
}
    80002c50:	60e2                	ld	ra,24(sp)
    80002c52:	6442                	ld	s0,16(sp)
    80002c54:	6105                	addi	sp,sp,32
    80002c56:	8082                	ret

0000000080002c58 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002c58:	7179                	addi	sp,sp,-48
    80002c5a:	f406                	sd	ra,40(sp)
    80002c5c:	f022                	sd	s0,32(sp)
    80002c5e:	ec26                	sd	s1,24(sp)
    80002c60:	1800                	addi	s0,sp,48
  uint64 addr;
  int n;

  argint(0, &n);
    80002c62:	fdc40593          	addi	a1,s0,-36
    80002c66:	4501                	li	a0,0
    80002c68:	00000097          	auipc	ra,0x0
    80002c6c:	e84080e7          	jalr	-380(ra) # 80002aec <argint>
  addr = myproc()->sz;
    80002c70:	fffff097          	auipc	ra,0xfffff
    80002c74:	d5a080e7          	jalr	-678(ra) # 800019ca <myproc>
    80002c78:	6524                	ld	s1,72(a0)
  if (growproc(n) < 0)
    80002c7a:	fdc42503          	lw	a0,-36(s0)
    80002c7e:	fffff097          	auipc	ra,0xfffff
    80002c82:	0a6080e7          	jalr	166(ra) # 80001d24 <growproc>
    80002c86:	00054863          	bltz	a0,80002c96 <sys_sbrk+0x3e>
    return -1;

  return addr;
}
    80002c8a:	8526                	mv	a0,s1
    80002c8c:	70a2                	ld	ra,40(sp)
    80002c8e:	7402                	ld	s0,32(sp)
    80002c90:	64e2                	ld	s1,24(sp)
    80002c92:	6145                	addi	sp,sp,48
    80002c94:	8082                	ret
    return -1;
    80002c96:	54fd                	li	s1,-1
    80002c98:	bfcd                	j	80002c8a <sys_sbrk+0x32>

0000000080002c9a <sys_sleep>:

uint64
sys_sleep(void)
{
    80002c9a:	7139                	addi	sp,sp,-64
    80002c9c:	fc06                	sd	ra,56(sp)
    80002c9e:	f822                	sd	s0,48(sp)
    80002ca0:	f426                	sd	s1,40(sp)
    80002ca2:	f04a                	sd	s2,32(sp)
    80002ca4:	ec4e                	sd	s3,24(sp)
    80002ca6:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    80002ca8:	fcc40593          	addi	a1,s0,-52
    80002cac:	4501                	li	a0,0
    80002cae:	00000097          	auipc	ra,0x0
    80002cb2:	e3e080e7          	jalr	-450(ra) # 80002aec <argint>
  acquire(&tickslock);
    80002cb6:	00014517          	auipc	a0,0x14
    80002cba:	e5a50513          	addi	a0,a0,-422 # 80016b10 <tickslock>
    80002cbe:	ffffe097          	auipc	ra,0xffffe
    80002cc2:	f14080e7          	jalr	-236(ra) # 80000bd2 <acquire>
  ticks0 = ticks;
    80002cc6:	00006917          	auipc	s2,0x6
    80002cca:	daa92903          	lw	s2,-598(s2) # 80008a70 <ticks>
  while (ticks - ticks0 < n)
    80002cce:	fcc42783          	lw	a5,-52(s0)
    80002cd2:	cf9d                	beqz	a5,80002d10 <sys_sleep+0x76>
    if (killed(myproc()))
    {
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80002cd4:	00014997          	auipc	s3,0x14
    80002cd8:	e3c98993          	addi	s3,s3,-452 # 80016b10 <tickslock>
    80002cdc:	00006497          	auipc	s1,0x6
    80002ce0:	d9448493          	addi	s1,s1,-620 # 80008a70 <ticks>
    if (killed(myproc()))
    80002ce4:	fffff097          	auipc	ra,0xfffff
    80002ce8:	ce6080e7          	jalr	-794(ra) # 800019ca <myproc>
    80002cec:	fffff097          	auipc	ra,0xfffff
    80002cf0:	636080e7          	jalr	1590(ra) # 80002322 <killed>
    80002cf4:	ed15                	bnez	a0,80002d30 <sys_sleep+0x96>
    sleep(&ticks, &tickslock);
    80002cf6:	85ce                	mv	a1,s3
    80002cf8:	8526                	mv	a0,s1
    80002cfa:	fffff097          	auipc	ra,0xfffff
    80002cfe:	380080e7          	jalr	896(ra) # 8000207a <sleep>
  while (ticks - ticks0 < n)
    80002d02:	409c                	lw	a5,0(s1)
    80002d04:	412787bb          	subw	a5,a5,s2
    80002d08:	fcc42703          	lw	a4,-52(s0)
    80002d0c:	fce7ece3          	bltu	a5,a4,80002ce4 <sys_sleep+0x4a>
  }
  release(&tickslock);
    80002d10:	00014517          	auipc	a0,0x14
    80002d14:	e0050513          	addi	a0,a0,-512 # 80016b10 <tickslock>
    80002d18:	ffffe097          	auipc	ra,0xffffe
    80002d1c:	f6e080e7          	jalr	-146(ra) # 80000c86 <release>
  return 0;
    80002d20:	4501                	li	a0,0
}
    80002d22:	70e2                	ld	ra,56(sp)
    80002d24:	7442                	ld	s0,48(sp)
    80002d26:	74a2                	ld	s1,40(sp)
    80002d28:	7902                	ld	s2,32(sp)
    80002d2a:	69e2                	ld	s3,24(sp)
    80002d2c:	6121                	addi	sp,sp,64
    80002d2e:	8082                	ret
      release(&tickslock);
    80002d30:	00014517          	auipc	a0,0x14
    80002d34:	de050513          	addi	a0,a0,-544 # 80016b10 <tickslock>
    80002d38:	ffffe097          	auipc	ra,0xffffe
    80002d3c:	f4e080e7          	jalr	-178(ra) # 80000c86 <release>
      return -1;
    80002d40:	557d                	li	a0,-1
    80002d42:	b7c5                	j	80002d22 <sys_sleep+0x88>

0000000080002d44 <sys_kill>:

uint64
sys_kill(void)
{
    80002d44:	1101                	addi	sp,sp,-32
    80002d46:	ec06                	sd	ra,24(sp)
    80002d48:	e822                	sd	s0,16(sp)
    80002d4a:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    80002d4c:	fec40593          	addi	a1,s0,-20
    80002d50:	4501                	li	a0,0
    80002d52:	00000097          	auipc	ra,0x0
    80002d56:	d9a080e7          	jalr	-614(ra) # 80002aec <argint>
  return kill(pid);
    80002d5a:	fec42503          	lw	a0,-20(s0)
    80002d5e:	fffff097          	auipc	ra,0xfffff
    80002d62:	526080e7          	jalr	1318(ra) # 80002284 <kill>
}
    80002d66:	60e2                	ld	ra,24(sp)
    80002d68:	6442                	ld	s0,16(sp)
    80002d6a:	6105                	addi	sp,sp,32
    80002d6c:	8082                	ret

0000000080002d6e <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80002d6e:	1101                	addi	sp,sp,-32
    80002d70:	ec06                	sd	ra,24(sp)
    80002d72:	e822                	sd	s0,16(sp)
    80002d74:	e426                	sd	s1,8(sp)
    80002d76:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80002d78:	00014517          	auipc	a0,0x14
    80002d7c:	d9850513          	addi	a0,a0,-616 # 80016b10 <tickslock>
    80002d80:	ffffe097          	auipc	ra,0xffffe
    80002d84:	e52080e7          	jalr	-430(ra) # 80000bd2 <acquire>
  xticks = ticks;
    80002d88:	00006497          	auipc	s1,0x6
    80002d8c:	ce84a483          	lw	s1,-792(s1) # 80008a70 <ticks>
  release(&tickslock);
    80002d90:	00014517          	auipc	a0,0x14
    80002d94:	d8050513          	addi	a0,a0,-640 # 80016b10 <tickslock>
    80002d98:	ffffe097          	auipc	ra,0xffffe
    80002d9c:	eee080e7          	jalr	-274(ra) # 80000c86 <release>
  return xticks;
}
    80002da0:	02049513          	slli	a0,s1,0x20
    80002da4:	9101                	srli	a0,a0,0x20
    80002da6:	60e2                	ld	ra,24(sp)
    80002da8:	6442                	ld	s0,16(sp)
    80002daa:	64a2                	ld	s1,8(sp)
    80002dac:	6105                	addi	sp,sp,32
    80002dae:	8082                	ret

0000000080002db0 <sys_ctime>:

// return the current_time
uint64
sys_ctime(void)
{
    80002db0:	1141                	addi	sp,sp,-16
    80002db2:	e422                	sd	s0,8(sp)
    80002db4:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, time" : "=r" (x) );
    80002db6:	c0102573          	rdtime	a0
  return r_time();
    80002dba:	6422                	ld	s0,8(sp)
    80002dbc:	0141                	addi	sp,sp,16
    80002dbe:	8082                	ret

0000000080002dc0 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80002dc0:	7179                	addi	sp,sp,-48
    80002dc2:	f406                	sd	ra,40(sp)
    80002dc4:	f022                	sd	s0,32(sp)
    80002dc6:	ec26                	sd	s1,24(sp)
    80002dc8:	e84a                	sd	s2,16(sp)
    80002dca:	e44e                	sd	s3,8(sp)
    80002dcc:	e052                	sd	s4,0(sp)
    80002dce:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80002dd0:	00005597          	auipc	a1,0x5
    80002dd4:	73058593          	addi	a1,a1,1840 # 80008500 <syscalls+0xb8>
    80002dd8:	00014517          	auipc	a0,0x14
    80002ddc:	d5050513          	addi	a0,a0,-688 # 80016b28 <bcache>
    80002de0:	ffffe097          	auipc	ra,0xffffe
    80002de4:	d62080e7          	jalr	-670(ra) # 80000b42 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80002de8:	0001c797          	auipc	a5,0x1c
    80002dec:	d4078793          	addi	a5,a5,-704 # 8001eb28 <bcache+0x8000>
    80002df0:	0001c717          	auipc	a4,0x1c
    80002df4:	fa070713          	addi	a4,a4,-96 # 8001ed90 <bcache+0x8268>
    80002df8:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80002dfc:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002e00:	00014497          	auipc	s1,0x14
    80002e04:	d4048493          	addi	s1,s1,-704 # 80016b40 <bcache+0x18>
    b->next = bcache.head.next;
    80002e08:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80002e0a:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80002e0c:	00005a17          	auipc	s4,0x5
    80002e10:	6fca0a13          	addi	s4,s4,1788 # 80008508 <syscalls+0xc0>
    b->next = bcache.head.next;
    80002e14:	2b893783          	ld	a5,696(s2)
    80002e18:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80002e1a:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80002e1e:	85d2                	mv	a1,s4
    80002e20:	01048513          	addi	a0,s1,16
    80002e24:	00001097          	auipc	ra,0x1
    80002e28:	496080e7          	jalr	1174(ra) # 800042ba <initsleeplock>
    bcache.head.next->prev = b;
    80002e2c:	2b893783          	ld	a5,696(s2)
    80002e30:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80002e32:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002e36:	45848493          	addi	s1,s1,1112
    80002e3a:	fd349de3          	bne	s1,s3,80002e14 <binit+0x54>
  }
}
    80002e3e:	70a2                	ld	ra,40(sp)
    80002e40:	7402                	ld	s0,32(sp)
    80002e42:	64e2                	ld	s1,24(sp)
    80002e44:	6942                	ld	s2,16(sp)
    80002e46:	69a2                	ld	s3,8(sp)
    80002e48:	6a02                	ld	s4,0(sp)
    80002e4a:	6145                	addi	sp,sp,48
    80002e4c:	8082                	ret

0000000080002e4e <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80002e4e:	7179                	addi	sp,sp,-48
    80002e50:	f406                	sd	ra,40(sp)
    80002e52:	f022                	sd	s0,32(sp)
    80002e54:	ec26                	sd	s1,24(sp)
    80002e56:	e84a                	sd	s2,16(sp)
    80002e58:	e44e                	sd	s3,8(sp)
    80002e5a:	1800                	addi	s0,sp,48
    80002e5c:	892a                	mv	s2,a0
    80002e5e:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    80002e60:	00014517          	auipc	a0,0x14
    80002e64:	cc850513          	addi	a0,a0,-824 # 80016b28 <bcache>
    80002e68:	ffffe097          	auipc	ra,0xffffe
    80002e6c:	d6a080e7          	jalr	-662(ra) # 80000bd2 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80002e70:	0001c497          	auipc	s1,0x1c
    80002e74:	f704b483          	ld	s1,-144(s1) # 8001ede0 <bcache+0x82b8>
    80002e78:	0001c797          	auipc	a5,0x1c
    80002e7c:	f1878793          	addi	a5,a5,-232 # 8001ed90 <bcache+0x8268>
    80002e80:	02f48f63          	beq	s1,a5,80002ebe <bread+0x70>
    80002e84:	873e                	mv	a4,a5
    80002e86:	a021                	j	80002e8e <bread+0x40>
    80002e88:	68a4                	ld	s1,80(s1)
    80002e8a:	02e48a63          	beq	s1,a4,80002ebe <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    80002e8e:	449c                	lw	a5,8(s1)
    80002e90:	ff279ce3          	bne	a5,s2,80002e88 <bread+0x3a>
    80002e94:	44dc                	lw	a5,12(s1)
    80002e96:	ff3799e3          	bne	a5,s3,80002e88 <bread+0x3a>
      b->refcnt++;
    80002e9a:	40bc                	lw	a5,64(s1)
    80002e9c:	2785                	addiw	a5,a5,1
    80002e9e:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002ea0:	00014517          	auipc	a0,0x14
    80002ea4:	c8850513          	addi	a0,a0,-888 # 80016b28 <bcache>
    80002ea8:	ffffe097          	auipc	ra,0xffffe
    80002eac:	dde080e7          	jalr	-546(ra) # 80000c86 <release>
      acquiresleep(&b->lock);
    80002eb0:	01048513          	addi	a0,s1,16
    80002eb4:	00001097          	auipc	ra,0x1
    80002eb8:	440080e7          	jalr	1088(ra) # 800042f4 <acquiresleep>
      return b;
    80002ebc:	a8b9                	j	80002f1a <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002ebe:	0001c497          	auipc	s1,0x1c
    80002ec2:	f1a4b483          	ld	s1,-230(s1) # 8001edd8 <bcache+0x82b0>
    80002ec6:	0001c797          	auipc	a5,0x1c
    80002eca:	eca78793          	addi	a5,a5,-310 # 8001ed90 <bcache+0x8268>
    80002ece:	00f48863          	beq	s1,a5,80002ede <bread+0x90>
    80002ed2:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80002ed4:	40bc                	lw	a5,64(s1)
    80002ed6:	cf81                	beqz	a5,80002eee <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002ed8:	64a4                	ld	s1,72(s1)
    80002eda:	fee49de3          	bne	s1,a4,80002ed4 <bread+0x86>
  panic("bget: no buffers");
    80002ede:	00005517          	auipc	a0,0x5
    80002ee2:	63250513          	addi	a0,a0,1586 # 80008510 <syscalls+0xc8>
    80002ee6:	ffffd097          	auipc	ra,0xffffd
    80002eea:	656080e7          	jalr	1622(ra) # 8000053c <panic>
      b->dev = dev;
    80002eee:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80002ef2:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80002ef6:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80002efa:	4785                	li	a5,1
    80002efc:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002efe:	00014517          	auipc	a0,0x14
    80002f02:	c2a50513          	addi	a0,a0,-982 # 80016b28 <bcache>
    80002f06:	ffffe097          	auipc	ra,0xffffe
    80002f0a:	d80080e7          	jalr	-640(ra) # 80000c86 <release>
      acquiresleep(&b->lock);
    80002f0e:	01048513          	addi	a0,s1,16
    80002f12:	00001097          	auipc	ra,0x1
    80002f16:	3e2080e7          	jalr	994(ra) # 800042f4 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80002f1a:	409c                	lw	a5,0(s1)
    80002f1c:	cb89                	beqz	a5,80002f2e <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80002f1e:	8526                	mv	a0,s1
    80002f20:	70a2                	ld	ra,40(sp)
    80002f22:	7402                	ld	s0,32(sp)
    80002f24:	64e2                	ld	s1,24(sp)
    80002f26:	6942                	ld	s2,16(sp)
    80002f28:	69a2                	ld	s3,8(sp)
    80002f2a:	6145                	addi	sp,sp,48
    80002f2c:	8082                	ret
    virtio_disk_rw(b, 0);
    80002f2e:	4581                	li	a1,0
    80002f30:	8526                	mv	a0,s1
    80002f32:	00003097          	auipc	ra,0x3
    80002f36:	f70080e7          	jalr	-144(ra) # 80005ea2 <virtio_disk_rw>
    b->valid = 1;
    80002f3a:	4785                	li	a5,1
    80002f3c:	c09c                	sw	a5,0(s1)
  return b;
    80002f3e:	b7c5                	j	80002f1e <bread+0xd0>

0000000080002f40 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    80002f40:	1101                	addi	sp,sp,-32
    80002f42:	ec06                	sd	ra,24(sp)
    80002f44:	e822                	sd	s0,16(sp)
    80002f46:	e426                	sd	s1,8(sp)
    80002f48:	1000                	addi	s0,sp,32
    80002f4a:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80002f4c:	0541                	addi	a0,a0,16
    80002f4e:	00001097          	auipc	ra,0x1
    80002f52:	440080e7          	jalr	1088(ra) # 8000438e <holdingsleep>
    80002f56:	cd01                	beqz	a0,80002f6e <bwrite+0x2e>
    panic("bwrite");

  virtio_disk_rw(b, 1);
    80002f58:	4585                	li	a1,1
    80002f5a:	8526                	mv	a0,s1
    80002f5c:	00003097          	auipc	ra,0x3
    80002f60:	f46080e7          	jalr	-186(ra) # 80005ea2 <virtio_disk_rw>
}
    80002f64:	60e2                	ld	ra,24(sp)
    80002f66:	6442                	ld	s0,16(sp)
    80002f68:	64a2                	ld	s1,8(sp)
    80002f6a:	6105                	addi	sp,sp,32
    80002f6c:	8082                	ret
    panic("bwrite");
    80002f6e:	00005517          	auipc	a0,0x5
    80002f72:	5ba50513          	addi	a0,a0,1466 # 80008528 <syscalls+0xe0>
    80002f76:	ffffd097          	auipc	ra,0xffffd
    80002f7a:	5c6080e7          	jalr	1478(ra) # 8000053c <panic>

0000000080002f7e <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80002f7e:	1101                	addi	sp,sp,-32
    80002f80:	ec06                	sd	ra,24(sp)
    80002f82:	e822                	sd	s0,16(sp)
    80002f84:	e426                	sd	s1,8(sp)
    80002f86:	e04a                	sd	s2,0(sp)
    80002f88:	1000                	addi	s0,sp,32
    80002f8a:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80002f8c:	01050913          	addi	s2,a0,16
    80002f90:	854a                	mv	a0,s2
    80002f92:	00001097          	auipc	ra,0x1
    80002f96:	3fc080e7          	jalr	1020(ra) # 8000438e <holdingsleep>
    80002f9a:	c925                	beqz	a0,8000300a <brelse+0x8c>
    panic("brelse");

  releasesleep(&b->lock);
    80002f9c:	854a                	mv	a0,s2
    80002f9e:	00001097          	auipc	ra,0x1
    80002fa2:	3ac080e7          	jalr	940(ra) # 8000434a <releasesleep>

  acquire(&bcache.lock);
    80002fa6:	00014517          	auipc	a0,0x14
    80002faa:	b8250513          	addi	a0,a0,-1150 # 80016b28 <bcache>
    80002fae:	ffffe097          	auipc	ra,0xffffe
    80002fb2:	c24080e7          	jalr	-988(ra) # 80000bd2 <acquire>
  b->refcnt--;
    80002fb6:	40bc                	lw	a5,64(s1)
    80002fb8:	37fd                	addiw	a5,a5,-1
    80002fba:	0007871b          	sext.w	a4,a5
    80002fbe:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80002fc0:	e71d                	bnez	a4,80002fee <brelse+0x70>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80002fc2:	68b8                	ld	a4,80(s1)
    80002fc4:	64bc                	ld	a5,72(s1)
    80002fc6:	e73c                	sd	a5,72(a4)
    b->prev->next = b->next;
    80002fc8:	68b8                	ld	a4,80(s1)
    80002fca:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80002fcc:	0001c797          	auipc	a5,0x1c
    80002fd0:	b5c78793          	addi	a5,a5,-1188 # 8001eb28 <bcache+0x8000>
    80002fd4:	2b87b703          	ld	a4,696(a5)
    80002fd8:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80002fda:	0001c717          	auipc	a4,0x1c
    80002fde:	db670713          	addi	a4,a4,-586 # 8001ed90 <bcache+0x8268>
    80002fe2:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80002fe4:	2b87b703          	ld	a4,696(a5)
    80002fe8:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80002fea:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    80002fee:	00014517          	auipc	a0,0x14
    80002ff2:	b3a50513          	addi	a0,a0,-1222 # 80016b28 <bcache>
    80002ff6:	ffffe097          	auipc	ra,0xffffe
    80002ffa:	c90080e7          	jalr	-880(ra) # 80000c86 <release>
}
    80002ffe:	60e2                	ld	ra,24(sp)
    80003000:	6442                	ld	s0,16(sp)
    80003002:	64a2                	ld	s1,8(sp)
    80003004:	6902                	ld	s2,0(sp)
    80003006:	6105                	addi	sp,sp,32
    80003008:	8082                	ret
    panic("brelse");
    8000300a:	00005517          	auipc	a0,0x5
    8000300e:	52650513          	addi	a0,a0,1318 # 80008530 <syscalls+0xe8>
    80003012:	ffffd097          	auipc	ra,0xffffd
    80003016:	52a080e7          	jalr	1322(ra) # 8000053c <panic>

000000008000301a <bpin>:

void
bpin(struct buf *b) {
    8000301a:	1101                	addi	sp,sp,-32
    8000301c:	ec06                	sd	ra,24(sp)
    8000301e:	e822                	sd	s0,16(sp)
    80003020:	e426                	sd	s1,8(sp)
    80003022:	1000                	addi	s0,sp,32
    80003024:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003026:	00014517          	auipc	a0,0x14
    8000302a:	b0250513          	addi	a0,a0,-1278 # 80016b28 <bcache>
    8000302e:	ffffe097          	auipc	ra,0xffffe
    80003032:	ba4080e7          	jalr	-1116(ra) # 80000bd2 <acquire>
  b->refcnt++;
    80003036:	40bc                	lw	a5,64(s1)
    80003038:	2785                	addiw	a5,a5,1
    8000303a:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    8000303c:	00014517          	auipc	a0,0x14
    80003040:	aec50513          	addi	a0,a0,-1300 # 80016b28 <bcache>
    80003044:	ffffe097          	auipc	ra,0xffffe
    80003048:	c42080e7          	jalr	-958(ra) # 80000c86 <release>
}
    8000304c:	60e2                	ld	ra,24(sp)
    8000304e:	6442                	ld	s0,16(sp)
    80003050:	64a2                	ld	s1,8(sp)
    80003052:	6105                	addi	sp,sp,32
    80003054:	8082                	ret

0000000080003056 <bunpin>:

void
bunpin(struct buf *b) {
    80003056:	1101                	addi	sp,sp,-32
    80003058:	ec06                	sd	ra,24(sp)
    8000305a:	e822                	sd	s0,16(sp)
    8000305c:	e426                	sd	s1,8(sp)
    8000305e:	1000                	addi	s0,sp,32
    80003060:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003062:	00014517          	auipc	a0,0x14
    80003066:	ac650513          	addi	a0,a0,-1338 # 80016b28 <bcache>
    8000306a:	ffffe097          	auipc	ra,0xffffe
    8000306e:	b68080e7          	jalr	-1176(ra) # 80000bd2 <acquire>
  b->refcnt--;
    80003072:	40bc                	lw	a5,64(s1)
    80003074:	37fd                	addiw	a5,a5,-1
    80003076:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80003078:	00014517          	auipc	a0,0x14
    8000307c:	ab050513          	addi	a0,a0,-1360 # 80016b28 <bcache>
    80003080:	ffffe097          	auipc	ra,0xffffe
    80003084:	c06080e7          	jalr	-1018(ra) # 80000c86 <release>
}
    80003088:	60e2                	ld	ra,24(sp)
    8000308a:	6442                	ld	s0,16(sp)
    8000308c:	64a2                	ld	s1,8(sp)
    8000308e:	6105                	addi	sp,sp,32
    80003090:	8082                	ret

0000000080003092 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80003092:	1101                	addi	sp,sp,-32
    80003094:	ec06                	sd	ra,24(sp)
    80003096:	e822                	sd	s0,16(sp)
    80003098:	e426                	sd	s1,8(sp)
    8000309a:	e04a                	sd	s2,0(sp)
    8000309c:	1000                	addi	s0,sp,32
    8000309e:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    800030a0:	00d5d59b          	srliw	a1,a1,0xd
    800030a4:	0001c797          	auipc	a5,0x1c
    800030a8:	1607a783          	lw	a5,352(a5) # 8001f204 <sb+0x1c>
    800030ac:	9dbd                	addw	a1,a1,a5
    800030ae:	00000097          	auipc	ra,0x0
    800030b2:	da0080e7          	jalr	-608(ra) # 80002e4e <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    800030b6:	0074f713          	andi	a4,s1,7
    800030ba:	4785                	li	a5,1
    800030bc:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    800030c0:	14ce                	slli	s1,s1,0x33
    800030c2:	90d9                	srli	s1,s1,0x36
    800030c4:	00950733          	add	a4,a0,s1
    800030c8:	05874703          	lbu	a4,88(a4)
    800030cc:	00e7f6b3          	and	a3,a5,a4
    800030d0:	c69d                	beqz	a3,800030fe <bfree+0x6c>
    800030d2:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    800030d4:	94aa                	add	s1,s1,a0
    800030d6:	fff7c793          	not	a5,a5
    800030da:	8f7d                	and	a4,a4,a5
    800030dc:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    800030e0:	00001097          	auipc	ra,0x1
    800030e4:	0f6080e7          	jalr	246(ra) # 800041d6 <log_write>
  brelse(bp);
    800030e8:	854a                	mv	a0,s2
    800030ea:	00000097          	auipc	ra,0x0
    800030ee:	e94080e7          	jalr	-364(ra) # 80002f7e <brelse>
}
    800030f2:	60e2                	ld	ra,24(sp)
    800030f4:	6442                	ld	s0,16(sp)
    800030f6:	64a2                	ld	s1,8(sp)
    800030f8:	6902                	ld	s2,0(sp)
    800030fa:	6105                	addi	sp,sp,32
    800030fc:	8082                	ret
    panic("freeing free block");
    800030fe:	00005517          	auipc	a0,0x5
    80003102:	43a50513          	addi	a0,a0,1082 # 80008538 <syscalls+0xf0>
    80003106:	ffffd097          	auipc	ra,0xffffd
    8000310a:	436080e7          	jalr	1078(ra) # 8000053c <panic>

000000008000310e <balloc>:
{
    8000310e:	711d                	addi	sp,sp,-96
    80003110:	ec86                	sd	ra,88(sp)
    80003112:	e8a2                	sd	s0,80(sp)
    80003114:	e4a6                	sd	s1,72(sp)
    80003116:	e0ca                	sd	s2,64(sp)
    80003118:	fc4e                	sd	s3,56(sp)
    8000311a:	f852                	sd	s4,48(sp)
    8000311c:	f456                	sd	s5,40(sp)
    8000311e:	f05a                	sd	s6,32(sp)
    80003120:	ec5e                	sd	s7,24(sp)
    80003122:	e862                	sd	s8,16(sp)
    80003124:	e466                	sd	s9,8(sp)
    80003126:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    80003128:	0001c797          	auipc	a5,0x1c
    8000312c:	0c47a783          	lw	a5,196(a5) # 8001f1ec <sb+0x4>
    80003130:	cff5                	beqz	a5,8000322c <balloc+0x11e>
    80003132:	8baa                	mv	s7,a0
    80003134:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80003136:	0001cb17          	auipc	s6,0x1c
    8000313a:	0b2b0b13          	addi	s6,s6,178 # 8001f1e8 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000313e:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    80003140:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003142:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    80003144:	6c89                	lui	s9,0x2
    80003146:	a061                	j	800031ce <balloc+0xc0>
        bp->data[bi/8] |= m;  // Mark block in use.
    80003148:	97ca                	add	a5,a5,s2
    8000314a:	8e55                	or	a2,a2,a3
    8000314c:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    80003150:	854a                	mv	a0,s2
    80003152:	00001097          	auipc	ra,0x1
    80003156:	084080e7          	jalr	132(ra) # 800041d6 <log_write>
        brelse(bp);
    8000315a:	854a                	mv	a0,s2
    8000315c:	00000097          	auipc	ra,0x0
    80003160:	e22080e7          	jalr	-478(ra) # 80002f7e <brelse>
  bp = bread(dev, bno);
    80003164:	85a6                	mv	a1,s1
    80003166:	855e                	mv	a0,s7
    80003168:	00000097          	auipc	ra,0x0
    8000316c:	ce6080e7          	jalr	-794(ra) # 80002e4e <bread>
    80003170:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80003172:	40000613          	li	a2,1024
    80003176:	4581                	li	a1,0
    80003178:	05850513          	addi	a0,a0,88
    8000317c:	ffffe097          	auipc	ra,0xffffe
    80003180:	b52080e7          	jalr	-1198(ra) # 80000cce <memset>
  log_write(bp);
    80003184:	854a                	mv	a0,s2
    80003186:	00001097          	auipc	ra,0x1
    8000318a:	050080e7          	jalr	80(ra) # 800041d6 <log_write>
  brelse(bp);
    8000318e:	854a                	mv	a0,s2
    80003190:	00000097          	auipc	ra,0x0
    80003194:	dee080e7          	jalr	-530(ra) # 80002f7e <brelse>
}
    80003198:	8526                	mv	a0,s1
    8000319a:	60e6                	ld	ra,88(sp)
    8000319c:	6446                	ld	s0,80(sp)
    8000319e:	64a6                	ld	s1,72(sp)
    800031a0:	6906                	ld	s2,64(sp)
    800031a2:	79e2                	ld	s3,56(sp)
    800031a4:	7a42                	ld	s4,48(sp)
    800031a6:	7aa2                	ld	s5,40(sp)
    800031a8:	7b02                	ld	s6,32(sp)
    800031aa:	6be2                	ld	s7,24(sp)
    800031ac:	6c42                	ld	s8,16(sp)
    800031ae:	6ca2                	ld	s9,8(sp)
    800031b0:	6125                	addi	sp,sp,96
    800031b2:	8082                	ret
    brelse(bp);
    800031b4:	854a                	mv	a0,s2
    800031b6:	00000097          	auipc	ra,0x0
    800031ba:	dc8080e7          	jalr	-568(ra) # 80002f7e <brelse>
  for(b = 0; b < sb.size; b += BPB){
    800031be:	015c87bb          	addw	a5,s9,s5
    800031c2:	00078a9b          	sext.w	s5,a5
    800031c6:	004b2703          	lw	a4,4(s6)
    800031ca:	06eaf163          	bgeu	s5,a4,8000322c <balloc+0x11e>
    bp = bread(dev, BBLOCK(b, sb));
    800031ce:	41fad79b          	sraiw	a5,s5,0x1f
    800031d2:	0137d79b          	srliw	a5,a5,0x13
    800031d6:	015787bb          	addw	a5,a5,s5
    800031da:	40d7d79b          	sraiw	a5,a5,0xd
    800031de:	01cb2583          	lw	a1,28(s6)
    800031e2:	9dbd                	addw	a1,a1,a5
    800031e4:	855e                	mv	a0,s7
    800031e6:	00000097          	auipc	ra,0x0
    800031ea:	c68080e7          	jalr	-920(ra) # 80002e4e <bread>
    800031ee:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800031f0:	004b2503          	lw	a0,4(s6)
    800031f4:	000a849b          	sext.w	s1,s5
    800031f8:	8762                	mv	a4,s8
    800031fa:	faa4fde3          	bgeu	s1,a0,800031b4 <balloc+0xa6>
      m = 1 << (bi % 8);
    800031fe:	00777693          	andi	a3,a4,7
    80003202:	00d996bb          	sllw	a3,s3,a3
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    80003206:	41f7579b          	sraiw	a5,a4,0x1f
    8000320a:	01d7d79b          	srliw	a5,a5,0x1d
    8000320e:	9fb9                	addw	a5,a5,a4
    80003210:	4037d79b          	sraiw	a5,a5,0x3
    80003214:	00f90633          	add	a2,s2,a5
    80003218:	05864603          	lbu	a2,88(a2)
    8000321c:	00c6f5b3          	and	a1,a3,a2
    80003220:	d585                	beqz	a1,80003148 <balloc+0x3a>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003222:	2705                	addiw	a4,a4,1
    80003224:	2485                	addiw	s1,s1,1
    80003226:	fd471ae3          	bne	a4,s4,800031fa <balloc+0xec>
    8000322a:	b769                	j	800031b4 <balloc+0xa6>
  printf("balloc: out of blocks\n");
    8000322c:	00005517          	auipc	a0,0x5
    80003230:	32450513          	addi	a0,a0,804 # 80008550 <syscalls+0x108>
    80003234:	ffffd097          	auipc	ra,0xffffd
    80003238:	352080e7          	jalr	850(ra) # 80000586 <printf>
  return 0;
    8000323c:	4481                	li	s1,0
    8000323e:	bfa9                	j	80003198 <balloc+0x8a>

0000000080003240 <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    80003240:	7179                	addi	sp,sp,-48
    80003242:	f406                	sd	ra,40(sp)
    80003244:	f022                	sd	s0,32(sp)
    80003246:	ec26                	sd	s1,24(sp)
    80003248:	e84a                	sd	s2,16(sp)
    8000324a:	e44e                	sd	s3,8(sp)
    8000324c:	e052                	sd	s4,0(sp)
    8000324e:	1800                	addi	s0,sp,48
    80003250:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    80003252:	47ad                	li	a5,11
    80003254:	02b7e863          	bltu	a5,a1,80003284 <bmap+0x44>
    if((addr = ip->addrs[bn]) == 0){
    80003258:	02059793          	slli	a5,a1,0x20
    8000325c:	01e7d593          	srli	a1,a5,0x1e
    80003260:	00b504b3          	add	s1,a0,a1
    80003264:	0504a903          	lw	s2,80(s1)
    80003268:	06091e63          	bnez	s2,800032e4 <bmap+0xa4>
      addr = balloc(ip->dev);
    8000326c:	4108                	lw	a0,0(a0)
    8000326e:	00000097          	auipc	ra,0x0
    80003272:	ea0080e7          	jalr	-352(ra) # 8000310e <balloc>
    80003276:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    8000327a:	06090563          	beqz	s2,800032e4 <bmap+0xa4>
        return 0;
      ip->addrs[bn] = addr;
    8000327e:	0524a823          	sw	s2,80(s1)
    80003282:	a08d                	j	800032e4 <bmap+0xa4>
    }
    return addr;
  }
  bn -= NDIRECT;
    80003284:	ff45849b          	addiw	s1,a1,-12
    80003288:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    8000328c:	0ff00793          	li	a5,255
    80003290:	08e7e563          	bltu	a5,a4,8000331a <bmap+0xda>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    80003294:	08052903          	lw	s2,128(a0)
    80003298:	00091d63          	bnez	s2,800032b2 <bmap+0x72>
      addr = balloc(ip->dev);
    8000329c:	4108                	lw	a0,0(a0)
    8000329e:	00000097          	auipc	ra,0x0
    800032a2:	e70080e7          	jalr	-400(ra) # 8000310e <balloc>
    800032a6:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    800032aa:	02090d63          	beqz	s2,800032e4 <bmap+0xa4>
        return 0;
      ip->addrs[NDIRECT] = addr;
    800032ae:	0929a023          	sw	s2,128(s3)
    }
    bp = bread(ip->dev, addr);
    800032b2:	85ca                	mv	a1,s2
    800032b4:	0009a503          	lw	a0,0(s3)
    800032b8:	00000097          	auipc	ra,0x0
    800032bc:	b96080e7          	jalr	-1130(ra) # 80002e4e <bread>
    800032c0:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    800032c2:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    800032c6:	02049713          	slli	a4,s1,0x20
    800032ca:	01e75593          	srli	a1,a4,0x1e
    800032ce:	00b784b3          	add	s1,a5,a1
    800032d2:	0004a903          	lw	s2,0(s1)
    800032d6:	02090063          	beqz	s2,800032f6 <bmap+0xb6>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    800032da:	8552                	mv	a0,s4
    800032dc:	00000097          	auipc	ra,0x0
    800032e0:	ca2080e7          	jalr	-862(ra) # 80002f7e <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    800032e4:	854a                	mv	a0,s2
    800032e6:	70a2                	ld	ra,40(sp)
    800032e8:	7402                	ld	s0,32(sp)
    800032ea:	64e2                	ld	s1,24(sp)
    800032ec:	6942                	ld	s2,16(sp)
    800032ee:	69a2                	ld	s3,8(sp)
    800032f0:	6a02                	ld	s4,0(sp)
    800032f2:	6145                	addi	sp,sp,48
    800032f4:	8082                	ret
      addr = balloc(ip->dev);
    800032f6:	0009a503          	lw	a0,0(s3)
    800032fa:	00000097          	auipc	ra,0x0
    800032fe:	e14080e7          	jalr	-492(ra) # 8000310e <balloc>
    80003302:	0005091b          	sext.w	s2,a0
      if(addr){
    80003306:	fc090ae3          	beqz	s2,800032da <bmap+0x9a>
        a[bn] = addr;
    8000330a:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    8000330e:	8552                	mv	a0,s4
    80003310:	00001097          	auipc	ra,0x1
    80003314:	ec6080e7          	jalr	-314(ra) # 800041d6 <log_write>
    80003318:	b7c9                	j	800032da <bmap+0x9a>
  panic("bmap: out of range");
    8000331a:	00005517          	auipc	a0,0x5
    8000331e:	24e50513          	addi	a0,a0,590 # 80008568 <syscalls+0x120>
    80003322:	ffffd097          	auipc	ra,0xffffd
    80003326:	21a080e7          	jalr	538(ra) # 8000053c <panic>

000000008000332a <iget>:
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
    8000333c:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    8000333e:	0001c517          	auipc	a0,0x1c
    80003342:	ed250513          	addi	a0,a0,-302 # 8001f210 <itable>
    80003346:	ffffe097          	auipc	ra,0xffffe
    8000334a:	88c080e7          	jalr	-1908(ra) # 80000bd2 <acquire>
  empty = 0;
    8000334e:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003350:	0001c497          	auipc	s1,0x1c
    80003354:	ed848493          	addi	s1,s1,-296 # 8001f228 <itable+0x18>
    80003358:	0001e697          	auipc	a3,0x1e
    8000335c:	96068693          	addi	a3,a3,-1696 # 80020cb8 <log>
    80003360:	a039                	j	8000336e <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003362:	02090b63          	beqz	s2,80003398 <iget+0x6e>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003366:	08848493          	addi	s1,s1,136
    8000336a:	02d48a63          	beq	s1,a3,8000339e <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    8000336e:	449c                	lw	a5,8(s1)
    80003370:	fef059e3          	blez	a5,80003362 <iget+0x38>
    80003374:	4098                	lw	a4,0(s1)
    80003376:	ff3716e3          	bne	a4,s3,80003362 <iget+0x38>
    8000337a:	40d8                	lw	a4,4(s1)
    8000337c:	ff4713e3          	bne	a4,s4,80003362 <iget+0x38>
      ip->ref++;
    80003380:	2785                	addiw	a5,a5,1
    80003382:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    80003384:	0001c517          	auipc	a0,0x1c
    80003388:	e8c50513          	addi	a0,a0,-372 # 8001f210 <itable>
    8000338c:	ffffe097          	auipc	ra,0xffffe
    80003390:	8fa080e7          	jalr	-1798(ra) # 80000c86 <release>
      return ip;
    80003394:	8926                	mv	s2,s1
    80003396:	a03d                	j	800033c4 <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003398:	f7f9                	bnez	a5,80003366 <iget+0x3c>
    8000339a:	8926                	mv	s2,s1
    8000339c:	b7e9                	j	80003366 <iget+0x3c>
  if(empty == 0)
    8000339e:	02090c63          	beqz	s2,800033d6 <iget+0xac>
  ip->dev = dev;
    800033a2:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    800033a6:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    800033aa:	4785                	li	a5,1
    800033ac:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    800033b0:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    800033b4:	0001c517          	auipc	a0,0x1c
    800033b8:	e5c50513          	addi	a0,a0,-420 # 8001f210 <itable>
    800033bc:	ffffe097          	auipc	ra,0xffffe
    800033c0:	8ca080e7          	jalr	-1846(ra) # 80000c86 <release>
}
    800033c4:	854a                	mv	a0,s2
    800033c6:	70a2                	ld	ra,40(sp)
    800033c8:	7402                	ld	s0,32(sp)
    800033ca:	64e2                	ld	s1,24(sp)
    800033cc:	6942                	ld	s2,16(sp)
    800033ce:	69a2                	ld	s3,8(sp)
    800033d0:	6a02                	ld	s4,0(sp)
    800033d2:	6145                	addi	sp,sp,48
    800033d4:	8082                	ret
    panic("iget: no inodes");
    800033d6:	00005517          	auipc	a0,0x5
    800033da:	1aa50513          	addi	a0,a0,426 # 80008580 <syscalls+0x138>
    800033de:	ffffd097          	auipc	ra,0xffffd
    800033e2:	15e080e7          	jalr	350(ra) # 8000053c <panic>

00000000800033e6 <fsinit>:
fsinit(int dev) {
    800033e6:	7179                	addi	sp,sp,-48
    800033e8:	f406                	sd	ra,40(sp)
    800033ea:	f022                	sd	s0,32(sp)
    800033ec:	ec26                	sd	s1,24(sp)
    800033ee:	e84a                	sd	s2,16(sp)
    800033f0:	e44e                	sd	s3,8(sp)
    800033f2:	1800                	addi	s0,sp,48
    800033f4:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    800033f6:	4585                	li	a1,1
    800033f8:	00000097          	auipc	ra,0x0
    800033fc:	a56080e7          	jalr	-1450(ra) # 80002e4e <bread>
    80003400:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    80003402:	0001c997          	auipc	s3,0x1c
    80003406:	de698993          	addi	s3,s3,-538 # 8001f1e8 <sb>
    8000340a:	02800613          	li	a2,40
    8000340e:	05850593          	addi	a1,a0,88
    80003412:	854e                	mv	a0,s3
    80003414:	ffffe097          	auipc	ra,0xffffe
    80003418:	916080e7          	jalr	-1770(ra) # 80000d2a <memmove>
  brelse(bp);
    8000341c:	8526                	mv	a0,s1
    8000341e:	00000097          	auipc	ra,0x0
    80003422:	b60080e7          	jalr	-1184(ra) # 80002f7e <brelse>
  if(sb.magic != FSMAGIC)
    80003426:	0009a703          	lw	a4,0(s3)
    8000342a:	102037b7          	lui	a5,0x10203
    8000342e:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80003432:	02f71263          	bne	a4,a5,80003456 <fsinit+0x70>
  initlog(dev, &sb);
    80003436:	0001c597          	auipc	a1,0x1c
    8000343a:	db258593          	addi	a1,a1,-590 # 8001f1e8 <sb>
    8000343e:	854a                	mv	a0,s2
    80003440:	00001097          	auipc	ra,0x1
    80003444:	b2c080e7          	jalr	-1236(ra) # 80003f6c <initlog>
}
    80003448:	70a2                	ld	ra,40(sp)
    8000344a:	7402                	ld	s0,32(sp)
    8000344c:	64e2                	ld	s1,24(sp)
    8000344e:	6942                	ld	s2,16(sp)
    80003450:	69a2                	ld	s3,8(sp)
    80003452:	6145                	addi	sp,sp,48
    80003454:	8082                	ret
    panic("invalid file system");
    80003456:	00005517          	auipc	a0,0x5
    8000345a:	13a50513          	addi	a0,a0,314 # 80008590 <syscalls+0x148>
    8000345e:	ffffd097          	auipc	ra,0xffffd
    80003462:	0de080e7          	jalr	222(ra) # 8000053c <panic>

0000000080003466 <iinit>:
{
    80003466:	7179                	addi	sp,sp,-48
    80003468:	f406                	sd	ra,40(sp)
    8000346a:	f022                	sd	s0,32(sp)
    8000346c:	ec26                	sd	s1,24(sp)
    8000346e:	e84a                	sd	s2,16(sp)
    80003470:	e44e                	sd	s3,8(sp)
    80003472:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    80003474:	00005597          	auipc	a1,0x5
    80003478:	13458593          	addi	a1,a1,308 # 800085a8 <syscalls+0x160>
    8000347c:	0001c517          	auipc	a0,0x1c
    80003480:	d9450513          	addi	a0,a0,-620 # 8001f210 <itable>
    80003484:	ffffd097          	auipc	ra,0xffffd
    80003488:	6be080e7          	jalr	1726(ra) # 80000b42 <initlock>
  for(i = 0; i < NINODE; i++) {
    8000348c:	0001c497          	auipc	s1,0x1c
    80003490:	dac48493          	addi	s1,s1,-596 # 8001f238 <itable+0x28>
    80003494:	0001e997          	auipc	s3,0x1e
    80003498:	83498993          	addi	s3,s3,-1996 # 80020cc8 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    8000349c:	00005917          	auipc	s2,0x5
    800034a0:	11490913          	addi	s2,s2,276 # 800085b0 <syscalls+0x168>
    800034a4:	85ca                	mv	a1,s2
    800034a6:	8526                	mv	a0,s1
    800034a8:	00001097          	auipc	ra,0x1
    800034ac:	e12080e7          	jalr	-494(ra) # 800042ba <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    800034b0:	08848493          	addi	s1,s1,136
    800034b4:	ff3498e3          	bne	s1,s3,800034a4 <iinit+0x3e>
}
    800034b8:	70a2                	ld	ra,40(sp)
    800034ba:	7402                	ld	s0,32(sp)
    800034bc:	64e2                	ld	s1,24(sp)
    800034be:	6942                	ld	s2,16(sp)
    800034c0:	69a2                	ld	s3,8(sp)
    800034c2:	6145                	addi	sp,sp,48
    800034c4:	8082                	ret

00000000800034c6 <ialloc>:
{
    800034c6:	7139                	addi	sp,sp,-64
    800034c8:	fc06                	sd	ra,56(sp)
    800034ca:	f822                	sd	s0,48(sp)
    800034cc:	f426                	sd	s1,40(sp)
    800034ce:	f04a                	sd	s2,32(sp)
    800034d0:	ec4e                	sd	s3,24(sp)
    800034d2:	e852                	sd	s4,16(sp)
    800034d4:	e456                	sd	s5,8(sp)
    800034d6:	e05a                	sd	s6,0(sp)
    800034d8:	0080                	addi	s0,sp,64
  for(inum = 1; inum < sb.ninodes; inum++){
    800034da:	0001c717          	auipc	a4,0x1c
    800034de:	d1a72703          	lw	a4,-742(a4) # 8001f1f4 <sb+0xc>
    800034e2:	4785                	li	a5,1
    800034e4:	04e7f863          	bgeu	a5,a4,80003534 <ialloc+0x6e>
    800034e8:	8aaa                	mv	s5,a0
    800034ea:	8b2e                	mv	s6,a1
    800034ec:	4905                	li	s2,1
    bp = bread(dev, IBLOCK(inum, sb));
    800034ee:	0001ca17          	auipc	s4,0x1c
    800034f2:	cfaa0a13          	addi	s4,s4,-774 # 8001f1e8 <sb>
    800034f6:	00495593          	srli	a1,s2,0x4
    800034fa:	018a2783          	lw	a5,24(s4)
    800034fe:	9dbd                	addw	a1,a1,a5
    80003500:	8556                	mv	a0,s5
    80003502:	00000097          	auipc	ra,0x0
    80003506:	94c080e7          	jalr	-1716(ra) # 80002e4e <bread>
    8000350a:	84aa                	mv	s1,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    8000350c:	05850993          	addi	s3,a0,88
    80003510:	00f97793          	andi	a5,s2,15
    80003514:	079a                	slli	a5,a5,0x6
    80003516:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    80003518:	00099783          	lh	a5,0(s3)
    8000351c:	cf9d                	beqz	a5,8000355a <ialloc+0x94>
    brelse(bp);
    8000351e:	00000097          	auipc	ra,0x0
    80003522:	a60080e7          	jalr	-1440(ra) # 80002f7e <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    80003526:	0905                	addi	s2,s2,1
    80003528:	00ca2703          	lw	a4,12(s4)
    8000352c:	0009079b          	sext.w	a5,s2
    80003530:	fce7e3e3          	bltu	a5,a4,800034f6 <ialloc+0x30>
  printf("ialloc: no inodes\n");
    80003534:	00005517          	auipc	a0,0x5
    80003538:	08450513          	addi	a0,a0,132 # 800085b8 <syscalls+0x170>
    8000353c:	ffffd097          	auipc	ra,0xffffd
    80003540:	04a080e7          	jalr	74(ra) # 80000586 <printf>
  return 0;
    80003544:	4501                	li	a0,0
}
    80003546:	70e2                	ld	ra,56(sp)
    80003548:	7442                	ld	s0,48(sp)
    8000354a:	74a2                	ld	s1,40(sp)
    8000354c:	7902                	ld	s2,32(sp)
    8000354e:	69e2                	ld	s3,24(sp)
    80003550:	6a42                	ld	s4,16(sp)
    80003552:	6aa2                	ld	s5,8(sp)
    80003554:	6b02                	ld	s6,0(sp)
    80003556:	6121                	addi	sp,sp,64
    80003558:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    8000355a:	04000613          	li	a2,64
    8000355e:	4581                	li	a1,0
    80003560:	854e                	mv	a0,s3
    80003562:	ffffd097          	auipc	ra,0xffffd
    80003566:	76c080e7          	jalr	1900(ra) # 80000cce <memset>
      dip->type = type;
    8000356a:	01699023          	sh	s6,0(s3)
      log_write(bp);   // mark it allocated on the disk
    8000356e:	8526                	mv	a0,s1
    80003570:	00001097          	auipc	ra,0x1
    80003574:	c66080e7          	jalr	-922(ra) # 800041d6 <log_write>
      brelse(bp);
    80003578:	8526                	mv	a0,s1
    8000357a:	00000097          	auipc	ra,0x0
    8000357e:	a04080e7          	jalr	-1532(ra) # 80002f7e <brelse>
      return iget(dev, inum);
    80003582:	0009059b          	sext.w	a1,s2
    80003586:	8556                	mv	a0,s5
    80003588:	00000097          	auipc	ra,0x0
    8000358c:	da2080e7          	jalr	-606(ra) # 8000332a <iget>
    80003590:	bf5d                	j	80003546 <ialloc+0x80>

0000000080003592 <iupdate>:
{
    80003592:	1101                	addi	sp,sp,-32
    80003594:	ec06                	sd	ra,24(sp)
    80003596:	e822                	sd	s0,16(sp)
    80003598:	e426                	sd	s1,8(sp)
    8000359a:	e04a                	sd	s2,0(sp)
    8000359c:	1000                	addi	s0,sp,32
    8000359e:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    800035a0:	415c                	lw	a5,4(a0)
    800035a2:	0047d79b          	srliw	a5,a5,0x4
    800035a6:	0001c597          	auipc	a1,0x1c
    800035aa:	c5a5a583          	lw	a1,-934(a1) # 8001f200 <sb+0x18>
    800035ae:	9dbd                	addw	a1,a1,a5
    800035b0:	4108                	lw	a0,0(a0)
    800035b2:	00000097          	auipc	ra,0x0
    800035b6:	89c080e7          	jalr	-1892(ra) # 80002e4e <bread>
    800035ba:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    800035bc:	05850793          	addi	a5,a0,88
    800035c0:	40d8                	lw	a4,4(s1)
    800035c2:	8b3d                	andi	a4,a4,15
    800035c4:	071a                	slli	a4,a4,0x6
    800035c6:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    800035c8:	04449703          	lh	a4,68(s1)
    800035cc:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    800035d0:	04649703          	lh	a4,70(s1)
    800035d4:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    800035d8:	04849703          	lh	a4,72(s1)
    800035dc:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    800035e0:	04a49703          	lh	a4,74(s1)
    800035e4:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    800035e8:	44f8                	lw	a4,76(s1)
    800035ea:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    800035ec:	03400613          	li	a2,52
    800035f0:	05048593          	addi	a1,s1,80
    800035f4:	00c78513          	addi	a0,a5,12
    800035f8:	ffffd097          	auipc	ra,0xffffd
    800035fc:	732080e7          	jalr	1842(ra) # 80000d2a <memmove>
  log_write(bp);
    80003600:	854a                	mv	a0,s2
    80003602:	00001097          	auipc	ra,0x1
    80003606:	bd4080e7          	jalr	-1068(ra) # 800041d6 <log_write>
  brelse(bp);
    8000360a:	854a                	mv	a0,s2
    8000360c:	00000097          	auipc	ra,0x0
    80003610:	972080e7          	jalr	-1678(ra) # 80002f7e <brelse>
}
    80003614:	60e2                	ld	ra,24(sp)
    80003616:	6442                	ld	s0,16(sp)
    80003618:	64a2                	ld	s1,8(sp)
    8000361a:	6902                	ld	s2,0(sp)
    8000361c:	6105                	addi	sp,sp,32
    8000361e:	8082                	ret

0000000080003620 <idup>:
{
    80003620:	1101                	addi	sp,sp,-32
    80003622:	ec06                	sd	ra,24(sp)
    80003624:	e822                	sd	s0,16(sp)
    80003626:	e426                	sd	s1,8(sp)
    80003628:	1000                	addi	s0,sp,32
    8000362a:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    8000362c:	0001c517          	auipc	a0,0x1c
    80003630:	be450513          	addi	a0,a0,-1052 # 8001f210 <itable>
    80003634:	ffffd097          	auipc	ra,0xffffd
    80003638:	59e080e7          	jalr	1438(ra) # 80000bd2 <acquire>
  ip->ref++;
    8000363c:	449c                	lw	a5,8(s1)
    8000363e:	2785                	addiw	a5,a5,1
    80003640:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003642:	0001c517          	auipc	a0,0x1c
    80003646:	bce50513          	addi	a0,a0,-1074 # 8001f210 <itable>
    8000364a:	ffffd097          	auipc	ra,0xffffd
    8000364e:	63c080e7          	jalr	1596(ra) # 80000c86 <release>
}
    80003652:	8526                	mv	a0,s1
    80003654:	60e2                	ld	ra,24(sp)
    80003656:	6442                	ld	s0,16(sp)
    80003658:	64a2                	ld	s1,8(sp)
    8000365a:	6105                	addi	sp,sp,32
    8000365c:	8082                	ret

000000008000365e <ilock>:
{
    8000365e:	1101                	addi	sp,sp,-32
    80003660:	ec06                	sd	ra,24(sp)
    80003662:	e822                	sd	s0,16(sp)
    80003664:	e426                	sd	s1,8(sp)
    80003666:	e04a                	sd	s2,0(sp)
    80003668:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    8000366a:	c115                	beqz	a0,8000368e <ilock+0x30>
    8000366c:	84aa                	mv	s1,a0
    8000366e:	451c                	lw	a5,8(a0)
    80003670:	00f05f63          	blez	a5,8000368e <ilock+0x30>
  acquiresleep(&ip->lock);
    80003674:	0541                	addi	a0,a0,16
    80003676:	00001097          	auipc	ra,0x1
    8000367a:	c7e080e7          	jalr	-898(ra) # 800042f4 <acquiresleep>
  if(ip->valid == 0){
    8000367e:	40bc                	lw	a5,64(s1)
    80003680:	cf99                	beqz	a5,8000369e <ilock+0x40>
}
    80003682:	60e2                	ld	ra,24(sp)
    80003684:	6442                	ld	s0,16(sp)
    80003686:	64a2                	ld	s1,8(sp)
    80003688:	6902                	ld	s2,0(sp)
    8000368a:	6105                	addi	sp,sp,32
    8000368c:	8082                	ret
    panic("ilock");
    8000368e:	00005517          	auipc	a0,0x5
    80003692:	f4250513          	addi	a0,a0,-190 # 800085d0 <syscalls+0x188>
    80003696:	ffffd097          	auipc	ra,0xffffd
    8000369a:	ea6080e7          	jalr	-346(ra) # 8000053c <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    8000369e:	40dc                	lw	a5,4(s1)
    800036a0:	0047d79b          	srliw	a5,a5,0x4
    800036a4:	0001c597          	auipc	a1,0x1c
    800036a8:	b5c5a583          	lw	a1,-1188(a1) # 8001f200 <sb+0x18>
    800036ac:	9dbd                	addw	a1,a1,a5
    800036ae:	4088                	lw	a0,0(s1)
    800036b0:	fffff097          	auipc	ra,0xfffff
    800036b4:	79e080e7          	jalr	1950(ra) # 80002e4e <bread>
    800036b8:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    800036ba:	05850593          	addi	a1,a0,88
    800036be:	40dc                	lw	a5,4(s1)
    800036c0:	8bbd                	andi	a5,a5,15
    800036c2:	079a                	slli	a5,a5,0x6
    800036c4:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    800036c6:	00059783          	lh	a5,0(a1)
    800036ca:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    800036ce:	00259783          	lh	a5,2(a1)
    800036d2:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    800036d6:	00459783          	lh	a5,4(a1)
    800036da:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    800036de:	00659783          	lh	a5,6(a1)
    800036e2:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    800036e6:	459c                	lw	a5,8(a1)
    800036e8:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    800036ea:	03400613          	li	a2,52
    800036ee:	05b1                	addi	a1,a1,12
    800036f0:	05048513          	addi	a0,s1,80
    800036f4:	ffffd097          	auipc	ra,0xffffd
    800036f8:	636080e7          	jalr	1590(ra) # 80000d2a <memmove>
    brelse(bp);
    800036fc:	854a                	mv	a0,s2
    800036fe:	00000097          	auipc	ra,0x0
    80003702:	880080e7          	jalr	-1920(ra) # 80002f7e <brelse>
    ip->valid = 1;
    80003706:	4785                	li	a5,1
    80003708:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    8000370a:	04449783          	lh	a5,68(s1)
    8000370e:	fbb5                	bnez	a5,80003682 <ilock+0x24>
      panic("ilock: no type");
    80003710:	00005517          	auipc	a0,0x5
    80003714:	ec850513          	addi	a0,a0,-312 # 800085d8 <syscalls+0x190>
    80003718:	ffffd097          	auipc	ra,0xffffd
    8000371c:	e24080e7          	jalr	-476(ra) # 8000053c <panic>

0000000080003720 <iunlock>:
{
    80003720:	1101                	addi	sp,sp,-32
    80003722:	ec06                	sd	ra,24(sp)
    80003724:	e822                	sd	s0,16(sp)
    80003726:	e426                	sd	s1,8(sp)
    80003728:	e04a                	sd	s2,0(sp)
    8000372a:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    8000372c:	c905                	beqz	a0,8000375c <iunlock+0x3c>
    8000372e:	84aa                	mv	s1,a0
    80003730:	01050913          	addi	s2,a0,16
    80003734:	854a                	mv	a0,s2
    80003736:	00001097          	auipc	ra,0x1
    8000373a:	c58080e7          	jalr	-936(ra) # 8000438e <holdingsleep>
    8000373e:	cd19                	beqz	a0,8000375c <iunlock+0x3c>
    80003740:	449c                	lw	a5,8(s1)
    80003742:	00f05d63          	blez	a5,8000375c <iunlock+0x3c>
  releasesleep(&ip->lock);
    80003746:	854a                	mv	a0,s2
    80003748:	00001097          	auipc	ra,0x1
    8000374c:	c02080e7          	jalr	-1022(ra) # 8000434a <releasesleep>
}
    80003750:	60e2                	ld	ra,24(sp)
    80003752:	6442                	ld	s0,16(sp)
    80003754:	64a2                	ld	s1,8(sp)
    80003756:	6902                	ld	s2,0(sp)
    80003758:	6105                	addi	sp,sp,32
    8000375a:	8082                	ret
    panic("iunlock");
    8000375c:	00005517          	auipc	a0,0x5
    80003760:	e8c50513          	addi	a0,a0,-372 # 800085e8 <syscalls+0x1a0>
    80003764:	ffffd097          	auipc	ra,0xffffd
    80003768:	dd8080e7          	jalr	-552(ra) # 8000053c <panic>

000000008000376c <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    8000376c:	7179                	addi	sp,sp,-48
    8000376e:	f406                	sd	ra,40(sp)
    80003770:	f022                	sd	s0,32(sp)
    80003772:	ec26                	sd	s1,24(sp)
    80003774:	e84a                	sd	s2,16(sp)
    80003776:	e44e                	sd	s3,8(sp)
    80003778:	e052                	sd	s4,0(sp)
    8000377a:	1800                	addi	s0,sp,48
    8000377c:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    8000377e:	05050493          	addi	s1,a0,80
    80003782:	08050913          	addi	s2,a0,128
    80003786:	a021                	j	8000378e <itrunc+0x22>
    80003788:	0491                	addi	s1,s1,4
    8000378a:	01248d63          	beq	s1,s2,800037a4 <itrunc+0x38>
    if(ip->addrs[i]){
    8000378e:	408c                	lw	a1,0(s1)
    80003790:	dde5                	beqz	a1,80003788 <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    80003792:	0009a503          	lw	a0,0(s3)
    80003796:	00000097          	auipc	ra,0x0
    8000379a:	8fc080e7          	jalr	-1796(ra) # 80003092 <bfree>
      ip->addrs[i] = 0;
    8000379e:	0004a023          	sw	zero,0(s1)
    800037a2:	b7dd                	j	80003788 <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    800037a4:	0809a583          	lw	a1,128(s3)
    800037a8:	e185                	bnez	a1,800037c8 <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    800037aa:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    800037ae:	854e                	mv	a0,s3
    800037b0:	00000097          	auipc	ra,0x0
    800037b4:	de2080e7          	jalr	-542(ra) # 80003592 <iupdate>
}
    800037b8:	70a2                	ld	ra,40(sp)
    800037ba:	7402                	ld	s0,32(sp)
    800037bc:	64e2                	ld	s1,24(sp)
    800037be:	6942                	ld	s2,16(sp)
    800037c0:	69a2                	ld	s3,8(sp)
    800037c2:	6a02                	ld	s4,0(sp)
    800037c4:	6145                	addi	sp,sp,48
    800037c6:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    800037c8:	0009a503          	lw	a0,0(s3)
    800037cc:	fffff097          	auipc	ra,0xfffff
    800037d0:	682080e7          	jalr	1666(ra) # 80002e4e <bread>
    800037d4:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    800037d6:	05850493          	addi	s1,a0,88
    800037da:	45850913          	addi	s2,a0,1112
    800037de:	a021                	j	800037e6 <itrunc+0x7a>
    800037e0:	0491                	addi	s1,s1,4
    800037e2:	01248b63          	beq	s1,s2,800037f8 <itrunc+0x8c>
      if(a[j])
    800037e6:	408c                	lw	a1,0(s1)
    800037e8:	dde5                	beqz	a1,800037e0 <itrunc+0x74>
        bfree(ip->dev, a[j]);
    800037ea:	0009a503          	lw	a0,0(s3)
    800037ee:	00000097          	auipc	ra,0x0
    800037f2:	8a4080e7          	jalr	-1884(ra) # 80003092 <bfree>
    800037f6:	b7ed                	j	800037e0 <itrunc+0x74>
    brelse(bp);
    800037f8:	8552                	mv	a0,s4
    800037fa:	fffff097          	auipc	ra,0xfffff
    800037fe:	784080e7          	jalr	1924(ra) # 80002f7e <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003802:	0809a583          	lw	a1,128(s3)
    80003806:	0009a503          	lw	a0,0(s3)
    8000380a:	00000097          	auipc	ra,0x0
    8000380e:	888080e7          	jalr	-1912(ra) # 80003092 <bfree>
    ip->addrs[NDIRECT] = 0;
    80003812:	0809a023          	sw	zero,128(s3)
    80003816:	bf51                	j	800037aa <itrunc+0x3e>

0000000080003818 <iput>:
{
    80003818:	1101                	addi	sp,sp,-32
    8000381a:	ec06                	sd	ra,24(sp)
    8000381c:	e822                	sd	s0,16(sp)
    8000381e:	e426                	sd	s1,8(sp)
    80003820:	e04a                	sd	s2,0(sp)
    80003822:	1000                	addi	s0,sp,32
    80003824:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003826:	0001c517          	auipc	a0,0x1c
    8000382a:	9ea50513          	addi	a0,a0,-1558 # 8001f210 <itable>
    8000382e:	ffffd097          	auipc	ra,0xffffd
    80003832:	3a4080e7          	jalr	932(ra) # 80000bd2 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003836:	4498                	lw	a4,8(s1)
    80003838:	4785                	li	a5,1
    8000383a:	02f70363          	beq	a4,a5,80003860 <iput+0x48>
  ip->ref--;
    8000383e:	449c                	lw	a5,8(s1)
    80003840:	37fd                	addiw	a5,a5,-1
    80003842:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003844:	0001c517          	auipc	a0,0x1c
    80003848:	9cc50513          	addi	a0,a0,-1588 # 8001f210 <itable>
    8000384c:	ffffd097          	auipc	ra,0xffffd
    80003850:	43a080e7          	jalr	1082(ra) # 80000c86 <release>
}
    80003854:	60e2                	ld	ra,24(sp)
    80003856:	6442                	ld	s0,16(sp)
    80003858:	64a2                	ld	s1,8(sp)
    8000385a:	6902                	ld	s2,0(sp)
    8000385c:	6105                	addi	sp,sp,32
    8000385e:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003860:	40bc                	lw	a5,64(s1)
    80003862:	dff1                	beqz	a5,8000383e <iput+0x26>
    80003864:	04a49783          	lh	a5,74(s1)
    80003868:	fbf9                	bnez	a5,8000383e <iput+0x26>
    acquiresleep(&ip->lock);
    8000386a:	01048913          	addi	s2,s1,16
    8000386e:	854a                	mv	a0,s2
    80003870:	00001097          	auipc	ra,0x1
    80003874:	a84080e7          	jalr	-1404(ra) # 800042f4 <acquiresleep>
    release(&itable.lock);
    80003878:	0001c517          	auipc	a0,0x1c
    8000387c:	99850513          	addi	a0,a0,-1640 # 8001f210 <itable>
    80003880:	ffffd097          	auipc	ra,0xffffd
    80003884:	406080e7          	jalr	1030(ra) # 80000c86 <release>
    itrunc(ip);
    80003888:	8526                	mv	a0,s1
    8000388a:	00000097          	auipc	ra,0x0
    8000388e:	ee2080e7          	jalr	-286(ra) # 8000376c <itrunc>
    ip->type = 0;
    80003892:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80003896:	8526                	mv	a0,s1
    80003898:	00000097          	auipc	ra,0x0
    8000389c:	cfa080e7          	jalr	-774(ra) # 80003592 <iupdate>
    ip->valid = 0;
    800038a0:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    800038a4:	854a                	mv	a0,s2
    800038a6:	00001097          	auipc	ra,0x1
    800038aa:	aa4080e7          	jalr	-1372(ra) # 8000434a <releasesleep>
    acquire(&itable.lock);
    800038ae:	0001c517          	auipc	a0,0x1c
    800038b2:	96250513          	addi	a0,a0,-1694 # 8001f210 <itable>
    800038b6:	ffffd097          	auipc	ra,0xffffd
    800038ba:	31c080e7          	jalr	796(ra) # 80000bd2 <acquire>
    800038be:	b741                	j	8000383e <iput+0x26>

00000000800038c0 <iunlockput>:
{
    800038c0:	1101                	addi	sp,sp,-32
    800038c2:	ec06                	sd	ra,24(sp)
    800038c4:	e822                	sd	s0,16(sp)
    800038c6:	e426                	sd	s1,8(sp)
    800038c8:	1000                	addi	s0,sp,32
    800038ca:	84aa                	mv	s1,a0
  iunlock(ip);
    800038cc:	00000097          	auipc	ra,0x0
    800038d0:	e54080e7          	jalr	-428(ra) # 80003720 <iunlock>
  iput(ip);
    800038d4:	8526                	mv	a0,s1
    800038d6:	00000097          	auipc	ra,0x0
    800038da:	f42080e7          	jalr	-190(ra) # 80003818 <iput>
}
    800038de:	60e2                	ld	ra,24(sp)
    800038e0:	6442                	ld	s0,16(sp)
    800038e2:	64a2                	ld	s1,8(sp)
    800038e4:	6105                	addi	sp,sp,32
    800038e6:	8082                	ret

00000000800038e8 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    800038e8:	1141                	addi	sp,sp,-16
    800038ea:	e422                	sd	s0,8(sp)
    800038ec:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    800038ee:	411c                	lw	a5,0(a0)
    800038f0:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    800038f2:	415c                	lw	a5,4(a0)
    800038f4:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    800038f6:	04451783          	lh	a5,68(a0)
    800038fa:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    800038fe:	04a51783          	lh	a5,74(a0)
    80003902:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003906:	04c56783          	lwu	a5,76(a0)
    8000390a:	e99c                	sd	a5,16(a1)
}
    8000390c:	6422                	ld	s0,8(sp)
    8000390e:	0141                	addi	sp,sp,16
    80003910:	8082                	ret

0000000080003912 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003912:	457c                	lw	a5,76(a0)
    80003914:	0ed7e963          	bltu	a5,a3,80003a06 <readi+0xf4>
{
    80003918:	7159                	addi	sp,sp,-112
    8000391a:	f486                	sd	ra,104(sp)
    8000391c:	f0a2                	sd	s0,96(sp)
    8000391e:	eca6                	sd	s1,88(sp)
    80003920:	e8ca                	sd	s2,80(sp)
    80003922:	e4ce                	sd	s3,72(sp)
    80003924:	e0d2                	sd	s4,64(sp)
    80003926:	fc56                	sd	s5,56(sp)
    80003928:	f85a                	sd	s6,48(sp)
    8000392a:	f45e                	sd	s7,40(sp)
    8000392c:	f062                	sd	s8,32(sp)
    8000392e:	ec66                	sd	s9,24(sp)
    80003930:	e86a                	sd	s10,16(sp)
    80003932:	e46e                	sd	s11,8(sp)
    80003934:	1880                	addi	s0,sp,112
    80003936:	8b2a                	mv	s6,a0
    80003938:	8bae                	mv	s7,a1
    8000393a:	8a32                	mv	s4,a2
    8000393c:	84b6                	mv	s1,a3
    8000393e:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    80003940:	9f35                	addw	a4,a4,a3
    return 0;
    80003942:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80003944:	0ad76063          	bltu	a4,a3,800039e4 <readi+0xd2>
  if(off + n > ip->size)
    80003948:	00e7f463          	bgeu	a5,a4,80003950 <readi+0x3e>
    n = ip->size - off;
    8000394c:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003950:	0a0a8963          	beqz	s5,80003a02 <readi+0xf0>
    80003954:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003956:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    8000395a:	5c7d                	li	s8,-1
    8000395c:	a82d                	j	80003996 <readi+0x84>
    8000395e:	020d1d93          	slli	s11,s10,0x20
    80003962:	020ddd93          	srli	s11,s11,0x20
    80003966:	05890613          	addi	a2,s2,88
    8000396a:	86ee                	mv	a3,s11
    8000396c:	963a                	add	a2,a2,a4
    8000396e:	85d2                	mv	a1,s4
    80003970:	855e                	mv	a0,s7
    80003972:	fffff097          	auipc	ra,0xfffff
    80003976:	b10080e7          	jalr	-1264(ra) # 80002482 <either_copyout>
    8000397a:	05850d63          	beq	a0,s8,800039d4 <readi+0xc2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    8000397e:	854a                	mv	a0,s2
    80003980:	fffff097          	auipc	ra,0xfffff
    80003984:	5fe080e7          	jalr	1534(ra) # 80002f7e <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003988:	013d09bb          	addw	s3,s10,s3
    8000398c:	009d04bb          	addw	s1,s10,s1
    80003990:	9a6e                	add	s4,s4,s11
    80003992:	0559f763          	bgeu	s3,s5,800039e0 <readi+0xce>
    uint addr = bmap(ip, off/BSIZE);
    80003996:	00a4d59b          	srliw	a1,s1,0xa
    8000399a:	855a                	mv	a0,s6
    8000399c:	00000097          	auipc	ra,0x0
    800039a0:	8a4080e7          	jalr	-1884(ra) # 80003240 <bmap>
    800039a4:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    800039a8:	cd85                	beqz	a1,800039e0 <readi+0xce>
    bp = bread(ip->dev, addr);
    800039aa:	000b2503          	lw	a0,0(s6)
    800039ae:	fffff097          	auipc	ra,0xfffff
    800039b2:	4a0080e7          	jalr	1184(ra) # 80002e4e <bread>
    800039b6:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    800039b8:	3ff4f713          	andi	a4,s1,1023
    800039bc:	40ec87bb          	subw	a5,s9,a4
    800039c0:	413a86bb          	subw	a3,s5,s3
    800039c4:	8d3e                	mv	s10,a5
    800039c6:	2781                	sext.w	a5,a5
    800039c8:	0006861b          	sext.w	a2,a3
    800039cc:	f8f679e3          	bgeu	a2,a5,8000395e <readi+0x4c>
    800039d0:	8d36                	mv	s10,a3
    800039d2:	b771                	j	8000395e <readi+0x4c>
      brelse(bp);
    800039d4:	854a                	mv	a0,s2
    800039d6:	fffff097          	auipc	ra,0xfffff
    800039da:	5a8080e7          	jalr	1448(ra) # 80002f7e <brelse>
      tot = -1;
    800039de:	59fd                	li	s3,-1
  }
  return tot;
    800039e0:	0009851b          	sext.w	a0,s3
}
    800039e4:	70a6                	ld	ra,104(sp)
    800039e6:	7406                	ld	s0,96(sp)
    800039e8:	64e6                	ld	s1,88(sp)
    800039ea:	6946                	ld	s2,80(sp)
    800039ec:	69a6                	ld	s3,72(sp)
    800039ee:	6a06                	ld	s4,64(sp)
    800039f0:	7ae2                	ld	s5,56(sp)
    800039f2:	7b42                	ld	s6,48(sp)
    800039f4:	7ba2                	ld	s7,40(sp)
    800039f6:	7c02                	ld	s8,32(sp)
    800039f8:	6ce2                	ld	s9,24(sp)
    800039fa:	6d42                	ld	s10,16(sp)
    800039fc:	6da2                	ld	s11,8(sp)
    800039fe:	6165                	addi	sp,sp,112
    80003a00:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003a02:	89d6                	mv	s3,s5
    80003a04:	bff1                	j	800039e0 <readi+0xce>
    return 0;
    80003a06:	4501                	li	a0,0
}
    80003a08:	8082                	ret

0000000080003a0a <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003a0a:	457c                	lw	a5,76(a0)
    80003a0c:	10d7e863          	bltu	a5,a3,80003b1c <writei+0x112>
{
    80003a10:	7159                	addi	sp,sp,-112
    80003a12:	f486                	sd	ra,104(sp)
    80003a14:	f0a2                	sd	s0,96(sp)
    80003a16:	eca6                	sd	s1,88(sp)
    80003a18:	e8ca                	sd	s2,80(sp)
    80003a1a:	e4ce                	sd	s3,72(sp)
    80003a1c:	e0d2                	sd	s4,64(sp)
    80003a1e:	fc56                	sd	s5,56(sp)
    80003a20:	f85a                	sd	s6,48(sp)
    80003a22:	f45e                	sd	s7,40(sp)
    80003a24:	f062                	sd	s8,32(sp)
    80003a26:	ec66                	sd	s9,24(sp)
    80003a28:	e86a                	sd	s10,16(sp)
    80003a2a:	e46e                	sd	s11,8(sp)
    80003a2c:	1880                	addi	s0,sp,112
    80003a2e:	8aaa                	mv	s5,a0
    80003a30:	8bae                	mv	s7,a1
    80003a32:	8a32                	mv	s4,a2
    80003a34:	8936                	mv	s2,a3
    80003a36:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003a38:	00e687bb          	addw	a5,a3,a4
    80003a3c:	0ed7e263          	bltu	a5,a3,80003b20 <writei+0x116>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80003a40:	00043737          	lui	a4,0x43
    80003a44:	0ef76063          	bltu	a4,a5,80003b24 <writei+0x11a>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003a48:	0c0b0863          	beqz	s6,80003b18 <writei+0x10e>
    80003a4c:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003a4e:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003a52:	5c7d                	li	s8,-1
    80003a54:	a091                	j	80003a98 <writei+0x8e>
    80003a56:	020d1d93          	slli	s11,s10,0x20
    80003a5a:	020ddd93          	srli	s11,s11,0x20
    80003a5e:	05848513          	addi	a0,s1,88
    80003a62:	86ee                	mv	a3,s11
    80003a64:	8652                	mv	a2,s4
    80003a66:	85de                	mv	a1,s7
    80003a68:	953a                	add	a0,a0,a4
    80003a6a:	fffff097          	auipc	ra,0xfffff
    80003a6e:	a6e080e7          	jalr	-1426(ra) # 800024d8 <either_copyin>
    80003a72:	07850263          	beq	a0,s8,80003ad6 <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    80003a76:	8526                	mv	a0,s1
    80003a78:	00000097          	auipc	ra,0x0
    80003a7c:	75e080e7          	jalr	1886(ra) # 800041d6 <log_write>
    brelse(bp);
    80003a80:	8526                	mv	a0,s1
    80003a82:	fffff097          	auipc	ra,0xfffff
    80003a86:	4fc080e7          	jalr	1276(ra) # 80002f7e <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003a8a:	013d09bb          	addw	s3,s10,s3
    80003a8e:	012d093b          	addw	s2,s10,s2
    80003a92:	9a6e                	add	s4,s4,s11
    80003a94:	0569f663          	bgeu	s3,s6,80003ae0 <writei+0xd6>
    uint addr = bmap(ip, off/BSIZE);
    80003a98:	00a9559b          	srliw	a1,s2,0xa
    80003a9c:	8556                	mv	a0,s5
    80003a9e:	fffff097          	auipc	ra,0xfffff
    80003aa2:	7a2080e7          	jalr	1954(ra) # 80003240 <bmap>
    80003aa6:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80003aaa:	c99d                	beqz	a1,80003ae0 <writei+0xd6>
    bp = bread(ip->dev, addr);
    80003aac:	000aa503          	lw	a0,0(s5)
    80003ab0:	fffff097          	auipc	ra,0xfffff
    80003ab4:	39e080e7          	jalr	926(ra) # 80002e4e <bread>
    80003ab8:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003aba:	3ff97713          	andi	a4,s2,1023
    80003abe:	40ec87bb          	subw	a5,s9,a4
    80003ac2:	413b06bb          	subw	a3,s6,s3
    80003ac6:	8d3e                	mv	s10,a5
    80003ac8:	2781                	sext.w	a5,a5
    80003aca:	0006861b          	sext.w	a2,a3
    80003ace:	f8f674e3          	bgeu	a2,a5,80003a56 <writei+0x4c>
    80003ad2:	8d36                	mv	s10,a3
    80003ad4:	b749                	j	80003a56 <writei+0x4c>
      brelse(bp);
    80003ad6:	8526                	mv	a0,s1
    80003ad8:	fffff097          	auipc	ra,0xfffff
    80003adc:	4a6080e7          	jalr	1190(ra) # 80002f7e <brelse>
  }

  if(off > ip->size)
    80003ae0:	04caa783          	lw	a5,76(s5)
    80003ae4:	0127f463          	bgeu	a5,s2,80003aec <writei+0xe2>
    ip->size = off;
    80003ae8:	052aa623          	sw	s2,76(s5)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80003aec:	8556                	mv	a0,s5
    80003aee:	00000097          	auipc	ra,0x0
    80003af2:	aa4080e7          	jalr	-1372(ra) # 80003592 <iupdate>

  return tot;
    80003af6:	0009851b          	sext.w	a0,s3
}
    80003afa:	70a6                	ld	ra,104(sp)
    80003afc:	7406                	ld	s0,96(sp)
    80003afe:	64e6                	ld	s1,88(sp)
    80003b00:	6946                	ld	s2,80(sp)
    80003b02:	69a6                	ld	s3,72(sp)
    80003b04:	6a06                	ld	s4,64(sp)
    80003b06:	7ae2                	ld	s5,56(sp)
    80003b08:	7b42                	ld	s6,48(sp)
    80003b0a:	7ba2                	ld	s7,40(sp)
    80003b0c:	7c02                	ld	s8,32(sp)
    80003b0e:	6ce2                	ld	s9,24(sp)
    80003b10:	6d42                	ld	s10,16(sp)
    80003b12:	6da2                	ld	s11,8(sp)
    80003b14:	6165                	addi	sp,sp,112
    80003b16:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003b18:	89da                	mv	s3,s6
    80003b1a:	bfc9                	j	80003aec <writei+0xe2>
    return -1;
    80003b1c:	557d                	li	a0,-1
}
    80003b1e:	8082                	ret
    return -1;
    80003b20:	557d                	li	a0,-1
    80003b22:	bfe1                	j	80003afa <writei+0xf0>
    return -1;
    80003b24:	557d                	li	a0,-1
    80003b26:	bfd1                	j	80003afa <writei+0xf0>

0000000080003b28 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80003b28:	1141                	addi	sp,sp,-16
    80003b2a:	e406                	sd	ra,8(sp)
    80003b2c:	e022                	sd	s0,0(sp)
    80003b2e:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80003b30:	4639                	li	a2,14
    80003b32:	ffffd097          	auipc	ra,0xffffd
    80003b36:	26c080e7          	jalr	620(ra) # 80000d9e <strncmp>
}
    80003b3a:	60a2                	ld	ra,8(sp)
    80003b3c:	6402                	ld	s0,0(sp)
    80003b3e:	0141                	addi	sp,sp,16
    80003b40:	8082                	ret

0000000080003b42 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003b42:	7139                	addi	sp,sp,-64
    80003b44:	fc06                	sd	ra,56(sp)
    80003b46:	f822                	sd	s0,48(sp)
    80003b48:	f426                	sd	s1,40(sp)
    80003b4a:	f04a                	sd	s2,32(sp)
    80003b4c:	ec4e                	sd	s3,24(sp)
    80003b4e:	e852                	sd	s4,16(sp)
    80003b50:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80003b52:	04451703          	lh	a4,68(a0)
    80003b56:	4785                	li	a5,1
    80003b58:	00f71a63          	bne	a4,a5,80003b6c <dirlookup+0x2a>
    80003b5c:	892a                	mv	s2,a0
    80003b5e:	89ae                	mv	s3,a1
    80003b60:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80003b62:	457c                	lw	a5,76(a0)
    80003b64:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80003b66:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003b68:	e79d                	bnez	a5,80003b96 <dirlookup+0x54>
    80003b6a:	a8a5                	j	80003be2 <dirlookup+0xa0>
    panic("dirlookup not DIR");
    80003b6c:	00005517          	auipc	a0,0x5
    80003b70:	a8450513          	addi	a0,a0,-1404 # 800085f0 <syscalls+0x1a8>
    80003b74:	ffffd097          	auipc	ra,0xffffd
    80003b78:	9c8080e7          	jalr	-1592(ra) # 8000053c <panic>
      panic("dirlookup read");
    80003b7c:	00005517          	auipc	a0,0x5
    80003b80:	a8c50513          	addi	a0,a0,-1396 # 80008608 <syscalls+0x1c0>
    80003b84:	ffffd097          	auipc	ra,0xffffd
    80003b88:	9b8080e7          	jalr	-1608(ra) # 8000053c <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003b8c:	24c1                	addiw	s1,s1,16
    80003b8e:	04c92783          	lw	a5,76(s2)
    80003b92:	04f4f763          	bgeu	s1,a5,80003be0 <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003b96:	4741                	li	a4,16
    80003b98:	86a6                	mv	a3,s1
    80003b9a:	fc040613          	addi	a2,s0,-64
    80003b9e:	4581                	li	a1,0
    80003ba0:	854a                	mv	a0,s2
    80003ba2:	00000097          	auipc	ra,0x0
    80003ba6:	d70080e7          	jalr	-656(ra) # 80003912 <readi>
    80003baa:	47c1                	li	a5,16
    80003bac:	fcf518e3          	bne	a0,a5,80003b7c <dirlookup+0x3a>
    if(de.inum == 0)
    80003bb0:	fc045783          	lhu	a5,-64(s0)
    80003bb4:	dfe1                	beqz	a5,80003b8c <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    80003bb6:	fc240593          	addi	a1,s0,-62
    80003bba:	854e                	mv	a0,s3
    80003bbc:	00000097          	auipc	ra,0x0
    80003bc0:	f6c080e7          	jalr	-148(ra) # 80003b28 <namecmp>
    80003bc4:	f561                	bnez	a0,80003b8c <dirlookup+0x4a>
      if(poff)
    80003bc6:	000a0463          	beqz	s4,80003bce <dirlookup+0x8c>
        *poff = off;
    80003bca:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80003bce:	fc045583          	lhu	a1,-64(s0)
    80003bd2:	00092503          	lw	a0,0(s2)
    80003bd6:	fffff097          	auipc	ra,0xfffff
    80003bda:	754080e7          	jalr	1876(ra) # 8000332a <iget>
    80003bde:	a011                	j	80003be2 <dirlookup+0xa0>
  return 0;
    80003be0:	4501                	li	a0,0
}
    80003be2:	70e2                	ld	ra,56(sp)
    80003be4:	7442                	ld	s0,48(sp)
    80003be6:	74a2                	ld	s1,40(sp)
    80003be8:	7902                	ld	s2,32(sp)
    80003bea:	69e2                	ld	s3,24(sp)
    80003bec:	6a42                	ld	s4,16(sp)
    80003bee:	6121                	addi	sp,sp,64
    80003bf0:	8082                	ret

0000000080003bf2 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80003bf2:	711d                	addi	sp,sp,-96
    80003bf4:	ec86                	sd	ra,88(sp)
    80003bf6:	e8a2                	sd	s0,80(sp)
    80003bf8:	e4a6                	sd	s1,72(sp)
    80003bfa:	e0ca                	sd	s2,64(sp)
    80003bfc:	fc4e                	sd	s3,56(sp)
    80003bfe:	f852                	sd	s4,48(sp)
    80003c00:	f456                	sd	s5,40(sp)
    80003c02:	f05a                	sd	s6,32(sp)
    80003c04:	ec5e                	sd	s7,24(sp)
    80003c06:	e862                	sd	s8,16(sp)
    80003c08:	e466                	sd	s9,8(sp)
    80003c0a:	1080                	addi	s0,sp,96
    80003c0c:	84aa                	mv	s1,a0
    80003c0e:	8b2e                	mv	s6,a1
    80003c10:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    80003c12:	00054703          	lbu	a4,0(a0)
    80003c16:	02f00793          	li	a5,47
    80003c1a:	02f70263          	beq	a4,a5,80003c3e <namex+0x4c>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80003c1e:	ffffe097          	auipc	ra,0xffffe
    80003c22:	dac080e7          	jalr	-596(ra) # 800019ca <myproc>
    80003c26:	15053503          	ld	a0,336(a0)
    80003c2a:	00000097          	auipc	ra,0x0
    80003c2e:	9f6080e7          	jalr	-1546(ra) # 80003620 <idup>
    80003c32:	8a2a                	mv	s4,a0
  while(*path == '/')
    80003c34:	02f00913          	li	s2,47
  if(len >= DIRSIZ)
    80003c38:	4c35                	li	s8,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80003c3a:	4b85                	li	s7,1
    80003c3c:	a875                	j	80003cf8 <namex+0x106>
    ip = iget(ROOTDEV, ROOTINO);
    80003c3e:	4585                	li	a1,1
    80003c40:	4505                	li	a0,1
    80003c42:	fffff097          	auipc	ra,0xfffff
    80003c46:	6e8080e7          	jalr	1768(ra) # 8000332a <iget>
    80003c4a:	8a2a                	mv	s4,a0
    80003c4c:	b7e5                	j	80003c34 <namex+0x42>
      iunlockput(ip);
    80003c4e:	8552                	mv	a0,s4
    80003c50:	00000097          	auipc	ra,0x0
    80003c54:	c70080e7          	jalr	-912(ra) # 800038c0 <iunlockput>
      return 0;
    80003c58:	4a01                	li	s4,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80003c5a:	8552                	mv	a0,s4
    80003c5c:	60e6                	ld	ra,88(sp)
    80003c5e:	6446                	ld	s0,80(sp)
    80003c60:	64a6                	ld	s1,72(sp)
    80003c62:	6906                	ld	s2,64(sp)
    80003c64:	79e2                	ld	s3,56(sp)
    80003c66:	7a42                	ld	s4,48(sp)
    80003c68:	7aa2                	ld	s5,40(sp)
    80003c6a:	7b02                	ld	s6,32(sp)
    80003c6c:	6be2                	ld	s7,24(sp)
    80003c6e:	6c42                	ld	s8,16(sp)
    80003c70:	6ca2                	ld	s9,8(sp)
    80003c72:	6125                	addi	sp,sp,96
    80003c74:	8082                	ret
      iunlock(ip);
    80003c76:	8552                	mv	a0,s4
    80003c78:	00000097          	auipc	ra,0x0
    80003c7c:	aa8080e7          	jalr	-1368(ra) # 80003720 <iunlock>
      return ip;
    80003c80:	bfe9                	j	80003c5a <namex+0x68>
      iunlockput(ip);
    80003c82:	8552                	mv	a0,s4
    80003c84:	00000097          	auipc	ra,0x0
    80003c88:	c3c080e7          	jalr	-964(ra) # 800038c0 <iunlockput>
      return 0;
    80003c8c:	8a4e                	mv	s4,s3
    80003c8e:	b7f1                	j	80003c5a <namex+0x68>
  len = path - s;
    80003c90:	40998633          	sub	a2,s3,s1
    80003c94:	00060c9b          	sext.w	s9,a2
  if(len >= DIRSIZ)
    80003c98:	099c5863          	bge	s8,s9,80003d28 <namex+0x136>
    memmove(name, s, DIRSIZ);
    80003c9c:	4639                	li	a2,14
    80003c9e:	85a6                	mv	a1,s1
    80003ca0:	8556                	mv	a0,s5
    80003ca2:	ffffd097          	auipc	ra,0xffffd
    80003ca6:	088080e7          	jalr	136(ra) # 80000d2a <memmove>
    80003caa:	84ce                	mv	s1,s3
  while(*path == '/')
    80003cac:	0004c783          	lbu	a5,0(s1)
    80003cb0:	01279763          	bne	a5,s2,80003cbe <namex+0xcc>
    path++;
    80003cb4:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003cb6:	0004c783          	lbu	a5,0(s1)
    80003cba:	ff278de3          	beq	a5,s2,80003cb4 <namex+0xc2>
    ilock(ip);
    80003cbe:	8552                	mv	a0,s4
    80003cc0:	00000097          	auipc	ra,0x0
    80003cc4:	99e080e7          	jalr	-1634(ra) # 8000365e <ilock>
    if(ip->type != T_DIR){
    80003cc8:	044a1783          	lh	a5,68(s4)
    80003ccc:	f97791e3          	bne	a5,s7,80003c4e <namex+0x5c>
    if(nameiparent && *path == '\0'){
    80003cd0:	000b0563          	beqz	s6,80003cda <namex+0xe8>
    80003cd4:	0004c783          	lbu	a5,0(s1)
    80003cd8:	dfd9                	beqz	a5,80003c76 <namex+0x84>
    if((next = dirlookup(ip, name, 0)) == 0){
    80003cda:	4601                	li	a2,0
    80003cdc:	85d6                	mv	a1,s5
    80003cde:	8552                	mv	a0,s4
    80003ce0:	00000097          	auipc	ra,0x0
    80003ce4:	e62080e7          	jalr	-414(ra) # 80003b42 <dirlookup>
    80003ce8:	89aa                	mv	s3,a0
    80003cea:	dd41                	beqz	a0,80003c82 <namex+0x90>
    iunlockput(ip);
    80003cec:	8552                	mv	a0,s4
    80003cee:	00000097          	auipc	ra,0x0
    80003cf2:	bd2080e7          	jalr	-1070(ra) # 800038c0 <iunlockput>
    ip = next;
    80003cf6:	8a4e                	mv	s4,s3
  while(*path == '/')
    80003cf8:	0004c783          	lbu	a5,0(s1)
    80003cfc:	01279763          	bne	a5,s2,80003d0a <namex+0x118>
    path++;
    80003d00:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003d02:	0004c783          	lbu	a5,0(s1)
    80003d06:	ff278de3          	beq	a5,s2,80003d00 <namex+0x10e>
  if(*path == 0)
    80003d0a:	cb9d                	beqz	a5,80003d40 <namex+0x14e>
  while(*path != '/' && *path != 0)
    80003d0c:	0004c783          	lbu	a5,0(s1)
    80003d10:	89a6                	mv	s3,s1
  len = path - s;
    80003d12:	4c81                	li	s9,0
    80003d14:	4601                	li	a2,0
  while(*path != '/' && *path != 0)
    80003d16:	01278963          	beq	a5,s2,80003d28 <namex+0x136>
    80003d1a:	dbbd                	beqz	a5,80003c90 <namex+0x9e>
    path++;
    80003d1c:	0985                	addi	s3,s3,1
  while(*path != '/' && *path != 0)
    80003d1e:	0009c783          	lbu	a5,0(s3)
    80003d22:	ff279ce3          	bne	a5,s2,80003d1a <namex+0x128>
    80003d26:	b7ad                	j	80003c90 <namex+0x9e>
    memmove(name, s, len);
    80003d28:	2601                	sext.w	a2,a2
    80003d2a:	85a6                	mv	a1,s1
    80003d2c:	8556                	mv	a0,s5
    80003d2e:	ffffd097          	auipc	ra,0xffffd
    80003d32:	ffc080e7          	jalr	-4(ra) # 80000d2a <memmove>
    name[len] = 0;
    80003d36:	9cd6                	add	s9,s9,s5
    80003d38:	000c8023          	sb	zero,0(s9) # 2000 <_entry-0x7fffe000>
    80003d3c:	84ce                	mv	s1,s3
    80003d3e:	b7bd                	j	80003cac <namex+0xba>
  if(nameiparent){
    80003d40:	f00b0de3          	beqz	s6,80003c5a <namex+0x68>
    iput(ip);
    80003d44:	8552                	mv	a0,s4
    80003d46:	00000097          	auipc	ra,0x0
    80003d4a:	ad2080e7          	jalr	-1326(ra) # 80003818 <iput>
    return 0;
    80003d4e:	4a01                	li	s4,0
    80003d50:	b729                	j	80003c5a <namex+0x68>

0000000080003d52 <dirlink>:
{
    80003d52:	7139                	addi	sp,sp,-64
    80003d54:	fc06                	sd	ra,56(sp)
    80003d56:	f822                	sd	s0,48(sp)
    80003d58:	f426                	sd	s1,40(sp)
    80003d5a:	f04a                	sd	s2,32(sp)
    80003d5c:	ec4e                	sd	s3,24(sp)
    80003d5e:	e852                	sd	s4,16(sp)
    80003d60:	0080                	addi	s0,sp,64
    80003d62:	892a                	mv	s2,a0
    80003d64:	8a2e                	mv	s4,a1
    80003d66:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80003d68:	4601                	li	a2,0
    80003d6a:	00000097          	auipc	ra,0x0
    80003d6e:	dd8080e7          	jalr	-552(ra) # 80003b42 <dirlookup>
    80003d72:	e93d                	bnez	a0,80003de8 <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003d74:	04c92483          	lw	s1,76(s2)
    80003d78:	c49d                	beqz	s1,80003da6 <dirlink+0x54>
    80003d7a:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003d7c:	4741                	li	a4,16
    80003d7e:	86a6                	mv	a3,s1
    80003d80:	fc040613          	addi	a2,s0,-64
    80003d84:	4581                	li	a1,0
    80003d86:	854a                	mv	a0,s2
    80003d88:	00000097          	auipc	ra,0x0
    80003d8c:	b8a080e7          	jalr	-1142(ra) # 80003912 <readi>
    80003d90:	47c1                	li	a5,16
    80003d92:	06f51163          	bne	a0,a5,80003df4 <dirlink+0xa2>
    if(de.inum == 0)
    80003d96:	fc045783          	lhu	a5,-64(s0)
    80003d9a:	c791                	beqz	a5,80003da6 <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003d9c:	24c1                	addiw	s1,s1,16
    80003d9e:	04c92783          	lw	a5,76(s2)
    80003da2:	fcf4ede3          	bltu	s1,a5,80003d7c <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    80003da6:	4639                	li	a2,14
    80003da8:	85d2                	mv	a1,s4
    80003daa:	fc240513          	addi	a0,s0,-62
    80003dae:	ffffd097          	auipc	ra,0xffffd
    80003db2:	02c080e7          	jalr	44(ra) # 80000dda <strncpy>
  de.inum = inum;
    80003db6:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003dba:	4741                	li	a4,16
    80003dbc:	86a6                	mv	a3,s1
    80003dbe:	fc040613          	addi	a2,s0,-64
    80003dc2:	4581                	li	a1,0
    80003dc4:	854a                	mv	a0,s2
    80003dc6:	00000097          	auipc	ra,0x0
    80003dca:	c44080e7          	jalr	-956(ra) # 80003a0a <writei>
    80003dce:	1541                	addi	a0,a0,-16
    80003dd0:	00a03533          	snez	a0,a0
    80003dd4:	40a00533          	neg	a0,a0
}
    80003dd8:	70e2                	ld	ra,56(sp)
    80003dda:	7442                	ld	s0,48(sp)
    80003ddc:	74a2                	ld	s1,40(sp)
    80003dde:	7902                	ld	s2,32(sp)
    80003de0:	69e2                	ld	s3,24(sp)
    80003de2:	6a42                	ld	s4,16(sp)
    80003de4:	6121                	addi	sp,sp,64
    80003de6:	8082                	ret
    iput(ip);
    80003de8:	00000097          	auipc	ra,0x0
    80003dec:	a30080e7          	jalr	-1488(ra) # 80003818 <iput>
    return -1;
    80003df0:	557d                	li	a0,-1
    80003df2:	b7dd                	j	80003dd8 <dirlink+0x86>
      panic("dirlink read");
    80003df4:	00005517          	auipc	a0,0x5
    80003df8:	82450513          	addi	a0,a0,-2012 # 80008618 <syscalls+0x1d0>
    80003dfc:	ffffc097          	auipc	ra,0xffffc
    80003e00:	740080e7          	jalr	1856(ra) # 8000053c <panic>

0000000080003e04 <namei>:

struct inode*
namei(char *path)
{
    80003e04:	1101                	addi	sp,sp,-32
    80003e06:	ec06                	sd	ra,24(sp)
    80003e08:	e822                	sd	s0,16(sp)
    80003e0a:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80003e0c:	fe040613          	addi	a2,s0,-32
    80003e10:	4581                	li	a1,0
    80003e12:	00000097          	auipc	ra,0x0
    80003e16:	de0080e7          	jalr	-544(ra) # 80003bf2 <namex>
}
    80003e1a:	60e2                	ld	ra,24(sp)
    80003e1c:	6442                	ld	s0,16(sp)
    80003e1e:	6105                	addi	sp,sp,32
    80003e20:	8082                	ret

0000000080003e22 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80003e22:	1141                	addi	sp,sp,-16
    80003e24:	e406                	sd	ra,8(sp)
    80003e26:	e022                	sd	s0,0(sp)
    80003e28:	0800                	addi	s0,sp,16
    80003e2a:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80003e2c:	4585                	li	a1,1
    80003e2e:	00000097          	auipc	ra,0x0
    80003e32:	dc4080e7          	jalr	-572(ra) # 80003bf2 <namex>
}
    80003e36:	60a2                	ld	ra,8(sp)
    80003e38:	6402                	ld	s0,0(sp)
    80003e3a:	0141                	addi	sp,sp,16
    80003e3c:	8082                	ret

0000000080003e3e <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80003e3e:	1101                	addi	sp,sp,-32
    80003e40:	ec06                	sd	ra,24(sp)
    80003e42:	e822                	sd	s0,16(sp)
    80003e44:	e426                	sd	s1,8(sp)
    80003e46:	e04a                	sd	s2,0(sp)
    80003e48:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80003e4a:	0001d917          	auipc	s2,0x1d
    80003e4e:	e6e90913          	addi	s2,s2,-402 # 80020cb8 <log>
    80003e52:	01892583          	lw	a1,24(s2)
    80003e56:	02892503          	lw	a0,40(s2)
    80003e5a:	fffff097          	auipc	ra,0xfffff
    80003e5e:	ff4080e7          	jalr	-12(ra) # 80002e4e <bread>
    80003e62:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80003e64:	02c92603          	lw	a2,44(s2)
    80003e68:	cd30                	sw	a2,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80003e6a:	00c05f63          	blez	a2,80003e88 <write_head+0x4a>
    80003e6e:	0001d717          	auipc	a4,0x1d
    80003e72:	e7a70713          	addi	a4,a4,-390 # 80020ce8 <log+0x30>
    80003e76:	87aa                	mv	a5,a0
    80003e78:	060a                	slli	a2,a2,0x2
    80003e7a:	962a                	add	a2,a2,a0
    hb->block[i] = log.lh.block[i];
    80003e7c:	4314                	lw	a3,0(a4)
    80003e7e:	cff4                	sw	a3,92(a5)
  for (i = 0; i < log.lh.n; i++) {
    80003e80:	0711                	addi	a4,a4,4
    80003e82:	0791                	addi	a5,a5,4
    80003e84:	fec79ce3          	bne	a5,a2,80003e7c <write_head+0x3e>
  }
  bwrite(buf);
    80003e88:	8526                	mv	a0,s1
    80003e8a:	fffff097          	auipc	ra,0xfffff
    80003e8e:	0b6080e7          	jalr	182(ra) # 80002f40 <bwrite>
  brelse(buf);
    80003e92:	8526                	mv	a0,s1
    80003e94:	fffff097          	auipc	ra,0xfffff
    80003e98:	0ea080e7          	jalr	234(ra) # 80002f7e <brelse>
}
    80003e9c:	60e2                	ld	ra,24(sp)
    80003e9e:	6442                	ld	s0,16(sp)
    80003ea0:	64a2                	ld	s1,8(sp)
    80003ea2:	6902                	ld	s2,0(sp)
    80003ea4:	6105                	addi	sp,sp,32
    80003ea6:	8082                	ret

0000000080003ea8 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80003ea8:	0001d797          	auipc	a5,0x1d
    80003eac:	e3c7a783          	lw	a5,-452(a5) # 80020ce4 <log+0x2c>
    80003eb0:	0af05d63          	blez	a5,80003f6a <install_trans+0xc2>
{
    80003eb4:	7139                	addi	sp,sp,-64
    80003eb6:	fc06                	sd	ra,56(sp)
    80003eb8:	f822                	sd	s0,48(sp)
    80003eba:	f426                	sd	s1,40(sp)
    80003ebc:	f04a                	sd	s2,32(sp)
    80003ebe:	ec4e                	sd	s3,24(sp)
    80003ec0:	e852                	sd	s4,16(sp)
    80003ec2:	e456                	sd	s5,8(sp)
    80003ec4:	e05a                	sd	s6,0(sp)
    80003ec6:	0080                	addi	s0,sp,64
    80003ec8:	8b2a                	mv	s6,a0
    80003eca:	0001da97          	auipc	s5,0x1d
    80003ece:	e1ea8a93          	addi	s5,s5,-482 # 80020ce8 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003ed2:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003ed4:	0001d997          	auipc	s3,0x1d
    80003ed8:	de498993          	addi	s3,s3,-540 # 80020cb8 <log>
    80003edc:	a00d                	j	80003efe <install_trans+0x56>
    brelse(lbuf);
    80003ede:	854a                	mv	a0,s2
    80003ee0:	fffff097          	auipc	ra,0xfffff
    80003ee4:	09e080e7          	jalr	158(ra) # 80002f7e <brelse>
    brelse(dbuf);
    80003ee8:	8526                	mv	a0,s1
    80003eea:	fffff097          	auipc	ra,0xfffff
    80003eee:	094080e7          	jalr	148(ra) # 80002f7e <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003ef2:	2a05                	addiw	s4,s4,1
    80003ef4:	0a91                	addi	s5,s5,4
    80003ef6:	02c9a783          	lw	a5,44(s3)
    80003efa:	04fa5e63          	bge	s4,a5,80003f56 <install_trans+0xae>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003efe:	0189a583          	lw	a1,24(s3)
    80003f02:	014585bb          	addw	a1,a1,s4
    80003f06:	2585                	addiw	a1,a1,1
    80003f08:	0289a503          	lw	a0,40(s3)
    80003f0c:	fffff097          	auipc	ra,0xfffff
    80003f10:	f42080e7          	jalr	-190(ra) # 80002e4e <bread>
    80003f14:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    80003f16:	000aa583          	lw	a1,0(s5)
    80003f1a:	0289a503          	lw	a0,40(s3)
    80003f1e:	fffff097          	auipc	ra,0xfffff
    80003f22:	f30080e7          	jalr	-208(ra) # 80002e4e <bread>
    80003f26:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80003f28:	40000613          	li	a2,1024
    80003f2c:	05890593          	addi	a1,s2,88
    80003f30:	05850513          	addi	a0,a0,88
    80003f34:	ffffd097          	auipc	ra,0xffffd
    80003f38:	df6080e7          	jalr	-522(ra) # 80000d2a <memmove>
    bwrite(dbuf);  // write dst to disk
    80003f3c:	8526                	mv	a0,s1
    80003f3e:	fffff097          	auipc	ra,0xfffff
    80003f42:	002080e7          	jalr	2(ra) # 80002f40 <bwrite>
    if(recovering == 0)
    80003f46:	f80b1ce3          	bnez	s6,80003ede <install_trans+0x36>
      bunpin(dbuf);
    80003f4a:	8526                	mv	a0,s1
    80003f4c:	fffff097          	auipc	ra,0xfffff
    80003f50:	10a080e7          	jalr	266(ra) # 80003056 <bunpin>
    80003f54:	b769                	j	80003ede <install_trans+0x36>
}
    80003f56:	70e2                	ld	ra,56(sp)
    80003f58:	7442                	ld	s0,48(sp)
    80003f5a:	74a2                	ld	s1,40(sp)
    80003f5c:	7902                	ld	s2,32(sp)
    80003f5e:	69e2                	ld	s3,24(sp)
    80003f60:	6a42                	ld	s4,16(sp)
    80003f62:	6aa2                	ld	s5,8(sp)
    80003f64:	6b02                	ld	s6,0(sp)
    80003f66:	6121                	addi	sp,sp,64
    80003f68:	8082                	ret
    80003f6a:	8082                	ret

0000000080003f6c <initlog>:
{
    80003f6c:	7179                	addi	sp,sp,-48
    80003f6e:	f406                	sd	ra,40(sp)
    80003f70:	f022                	sd	s0,32(sp)
    80003f72:	ec26                	sd	s1,24(sp)
    80003f74:	e84a                	sd	s2,16(sp)
    80003f76:	e44e                	sd	s3,8(sp)
    80003f78:	1800                	addi	s0,sp,48
    80003f7a:	892a                	mv	s2,a0
    80003f7c:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80003f7e:	0001d497          	auipc	s1,0x1d
    80003f82:	d3a48493          	addi	s1,s1,-710 # 80020cb8 <log>
    80003f86:	00004597          	auipc	a1,0x4
    80003f8a:	6a258593          	addi	a1,a1,1698 # 80008628 <syscalls+0x1e0>
    80003f8e:	8526                	mv	a0,s1
    80003f90:	ffffd097          	auipc	ra,0xffffd
    80003f94:	bb2080e7          	jalr	-1102(ra) # 80000b42 <initlock>
  log.start = sb->logstart;
    80003f98:	0149a583          	lw	a1,20(s3)
    80003f9c:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    80003f9e:	0109a783          	lw	a5,16(s3)
    80003fa2:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    80003fa4:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    80003fa8:	854a                	mv	a0,s2
    80003faa:	fffff097          	auipc	ra,0xfffff
    80003fae:	ea4080e7          	jalr	-348(ra) # 80002e4e <bread>
  log.lh.n = lh->n;
    80003fb2:	4d30                	lw	a2,88(a0)
    80003fb4:	d4d0                	sw	a2,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    80003fb6:	00c05f63          	blez	a2,80003fd4 <initlog+0x68>
    80003fba:	87aa                	mv	a5,a0
    80003fbc:	0001d717          	auipc	a4,0x1d
    80003fc0:	d2c70713          	addi	a4,a4,-724 # 80020ce8 <log+0x30>
    80003fc4:	060a                	slli	a2,a2,0x2
    80003fc6:	962a                	add	a2,a2,a0
    log.lh.block[i] = lh->block[i];
    80003fc8:	4ff4                	lw	a3,92(a5)
    80003fca:	c314                	sw	a3,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80003fcc:	0791                	addi	a5,a5,4
    80003fce:	0711                	addi	a4,a4,4
    80003fd0:	fec79ce3          	bne	a5,a2,80003fc8 <initlog+0x5c>
  brelse(buf);
    80003fd4:	fffff097          	auipc	ra,0xfffff
    80003fd8:	faa080e7          	jalr	-86(ra) # 80002f7e <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80003fdc:	4505                	li	a0,1
    80003fde:	00000097          	auipc	ra,0x0
    80003fe2:	eca080e7          	jalr	-310(ra) # 80003ea8 <install_trans>
  log.lh.n = 0;
    80003fe6:	0001d797          	auipc	a5,0x1d
    80003fea:	ce07af23          	sw	zero,-770(a5) # 80020ce4 <log+0x2c>
  write_head(); // clear the log
    80003fee:	00000097          	auipc	ra,0x0
    80003ff2:	e50080e7          	jalr	-432(ra) # 80003e3e <write_head>
}
    80003ff6:	70a2                	ld	ra,40(sp)
    80003ff8:	7402                	ld	s0,32(sp)
    80003ffa:	64e2                	ld	s1,24(sp)
    80003ffc:	6942                	ld	s2,16(sp)
    80003ffe:	69a2                	ld	s3,8(sp)
    80004000:	6145                	addi	sp,sp,48
    80004002:	8082                	ret

0000000080004004 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80004004:	1101                	addi	sp,sp,-32
    80004006:	ec06                	sd	ra,24(sp)
    80004008:	e822                	sd	s0,16(sp)
    8000400a:	e426                	sd	s1,8(sp)
    8000400c:	e04a                	sd	s2,0(sp)
    8000400e:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80004010:	0001d517          	auipc	a0,0x1d
    80004014:	ca850513          	addi	a0,a0,-856 # 80020cb8 <log>
    80004018:	ffffd097          	auipc	ra,0xffffd
    8000401c:	bba080e7          	jalr	-1094(ra) # 80000bd2 <acquire>
  while(1){
    if(log.committing){
    80004020:	0001d497          	auipc	s1,0x1d
    80004024:	c9848493          	addi	s1,s1,-872 # 80020cb8 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80004028:	4979                	li	s2,30
    8000402a:	a039                	j	80004038 <begin_op+0x34>
      sleep(&log, &log.lock);
    8000402c:	85a6                	mv	a1,s1
    8000402e:	8526                	mv	a0,s1
    80004030:	ffffe097          	auipc	ra,0xffffe
    80004034:	04a080e7          	jalr	74(ra) # 8000207a <sleep>
    if(log.committing){
    80004038:	50dc                	lw	a5,36(s1)
    8000403a:	fbed                	bnez	a5,8000402c <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    8000403c:	5098                	lw	a4,32(s1)
    8000403e:	2705                	addiw	a4,a4,1
    80004040:	0027179b          	slliw	a5,a4,0x2
    80004044:	9fb9                	addw	a5,a5,a4
    80004046:	0017979b          	slliw	a5,a5,0x1
    8000404a:	54d4                	lw	a3,44(s1)
    8000404c:	9fb5                	addw	a5,a5,a3
    8000404e:	00f95963          	bge	s2,a5,80004060 <begin_op+0x5c>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    80004052:	85a6                	mv	a1,s1
    80004054:	8526                	mv	a0,s1
    80004056:	ffffe097          	auipc	ra,0xffffe
    8000405a:	024080e7          	jalr	36(ra) # 8000207a <sleep>
    8000405e:	bfe9                	j	80004038 <begin_op+0x34>
    } else {
      log.outstanding += 1;
    80004060:	0001d517          	auipc	a0,0x1d
    80004064:	c5850513          	addi	a0,a0,-936 # 80020cb8 <log>
    80004068:	d118                	sw	a4,32(a0)
      release(&log.lock);
    8000406a:	ffffd097          	auipc	ra,0xffffd
    8000406e:	c1c080e7          	jalr	-996(ra) # 80000c86 <release>
      break;
    }
  }
}
    80004072:	60e2                	ld	ra,24(sp)
    80004074:	6442                	ld	s0,16(sp)
    80004076:	64a2                	ld	s1,8(sp)
    80004078:	6902                	ld	s2,0(sp)
    8000407a:	6105                	addi	sp,sp,32
    8000407c:	8082                	ret

000000008000407e <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    8000407e:	7139                	addi	sp,sp,-64
    80004080:	fc06                	sd	ra,56(sp)
    80004082:	f822                	sd	s0,48(sp)
    80004084:	f426                	sd	s1,40(sp)
    80004086:	f04a                	sd	s2,32(sp)
    80004088:	ec4e                	sd	s3,24(sp)
    8000408a:	e852                	sd	s4,16(sp)
    8000408c:	e456                	sd	s5,8(sp)
    8000408e:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    80004090:	0001d497          	auipc	s1,0x1d
    80004094:	c2848493          	addi	s1,s1,-984 # 80020cb8 <log>
    80004098:	8526                	mv	a0,s1
    8000409a:	ffffd097          	auipc	ra,0xffffd
    8000409e:	b38080e7          	jalr	-1224(ra) # 80000bd2 <acquire>
  log.outstanding -= 1;
    800040a2:	509c                	lw	a5,32(s1)
    800040a4:	37fd                	addiw	a5,a5,-1
    800040a6:	0007891b          	sext.w	s2,a5
    800040aa:	d09c                	sw	a5,32(s1)
  if(log.committing)
    800040ac:	50dc                	lw	a5,36(s1)
    800040ae:	e7b9                	bnez	a5,800040fc <end_op+0x7e>
    panic("log.committing");
  if(log.outstanding == 0){
    800040b0:	04091e63          	bnez	s2,8000410c <end_op+0x8e>
    do_commit = 1;
    log.committing = 1;
    800040b4:	0001d497          	auipc	s1,0x1d
    800040b8:	c0448493          	addi	s1,s1,-1020 # 80020cb8 <log>
    800040bc:	4785                	li	a5,1
    800040be:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    800040c0:	8526                	mv	a0,s1
    800040c2:	ffffd097          	auipc	ra,0xffffd
    800040c6:	bc4080e7          	jalr	-1084(ra) # 80000c86 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    800040ca:	54dc                	lw	a5,44(s1)
    800040cc:	06f04763          	bgtz	a5,8000413a <end_op+0xbc>
    acquire(&log.lock);
    800040d0:	0001d497          	auipc	s1,0x1d
    800040d4:	be848493          	addi	s1,s1,-1048 # 80020cb8 <log>
    800040d8:	8526                	mv	a0,s1
    800040da:	ffffd097          	auipc	ra,0xffffd
    800040de:	af8080e7          	jalr	-1288(ra) # 80000bd2 <acquire>
    log.committing = 0;
    800040e2:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    800040e6:	8526                	mv	a0,s1
    800040e8:	ffffe097          	auipc	ra,0xffffe
    800040ec:	ff6080e7          	jalr	-10(ra) # 800020de <wakeup>
    release(&log.lock);
    800040f0:	8526                	mv	a0,s1
    800040f2:	ffffd097          	auipc	ra,0xffffd
    800040f6:	b94080e7          	jalr	-1132(ra) # 80000c86 <release>
}
    800040fa:	a03d                	j	80004128 <end_op+0xaa>
    panic("log.committing");
    800040fc:	00004517          	auipc	a0,0x4
    80004100:	53450513          	addi	a0,a0,1332 # 80008630 <syscalls+0x1e8>
    80004104:	ffffc097          	auipc	ra,0xffffc
    80004108:	438080e7          	jalr	1080(ra) # 8000053c <panic>
    wakeup(&log);
    8000410c:	0001d497          	auipc	s1,0x1d
    80004110:	bac48493          	addi	s1,s1,-1108 # 80020cb8 <log>
    80004114:	8526                	mv	a0,s1
    80004116:	ffffe097          	auipc	ra,0xffffe
    8000411a:	fc8080e7          	jalr	-56(ra) # 800020de <wakeup>
  release(&log.lock);
    8000411e:	8526                	mv	a0,s1
    80004120:	ffffd097          	auipc	ra,0xffffd
    80004124:	b66080e7          	jalr	-1178(ra) # 80000c86 <release>
}
    80004128:	70e2                	ld	ra,56(sp)
    8000412a:	7442                	ld	s0,48(sp)
    8000412c:	74a2                	ld	s1,40(sp)
    8000412e:	7902                	ld	s2,32(sp)
    80004130:	69e2                	ld	s3,24(sp)
    80004132:	6a42                	ld	s4,16(sp)
    80004134:	6aa2                	ld	s5,8(sp)
    80004136:	6121                	addi	sp,sp,64
    80004138:	8082                	ret
  for (tail = 0; tail < log.lh.n; tail++) {
    8000413a:	0001da97          	auipc	s5,0x1d
    8000413e:	baea8a93          	addi	s5,s5,-1106 # 80020ce8 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    80004142:	0001da17          	auipc	s4,0x1d
    80004146:	b76a0a13          	addi	s4,s4,-1162 # 80020cb8 <log>
    8000414a:	018a2583          	lw	a1,24(s4)
    8000414e:	012585bb          	addw	a1,a1,s2
    80004152:	2585                	addiw	a1,a1,1
    80004154:	028a2503          	lw	a0,40(s4)
    80004158:	fffff097          	auipc	ra,0xfffff
    8000415c:	cf6080e7          	jalr	-778(ra) # 80002e4e <bread>
    80004160:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80004162:	000aa583          	lw	a1,0(s5)
    80004166:	028a2503          	lw	a0,40(s4)
    8000416a:	fffff097          	auipc	ra,0xfffff
    8000416e:	ce4080e7          	jalr	-796(ra) # 80002e4e <bread>
    80004172:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80004174:	40000613          	li	a2,1024
    80004178:	05850593          	addi	a1,a0,88
    8000417c:	05848513          	addi	a0,s1,88
    80004180:	ffffd097          	auipc	ra,0xffffd
    80004184:	baa080e7          	jalr	-1110(ra) # 80000d2a <memmove>
    bwrite(to);  // write the log
    80004188:	8526                	mv	a0,s1
    8000418a:	fffff097          	auipc	ra,0xfffff
    8000418e:	db6080e7          	jalr	-586(ra) # 80002f40 <bwrite>
    brelse(from);
    80004192:	854e                	mv	a0,s3
    80004194:	fffff097          	auipc	ra,0xfffff
    80004198:	dea080e7          	jalr	-534(ra) # 80002f7e <brelse>
    brelse(to);
    8000419c:	8526                	mv	a0,s1
    8000419e:	fffff097          	auipc	ra,0xfffff
    800041a2:	de0080e7          	jalr	-544(ra) # 80002f7e <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    800041a6:	2905                	addiw	s2,s2,1
    800041a8:	0a91                	addi	s5,s5,4
    800041aa:	02ca2783          	lw	a5,44(s4)
    800041ae:	f8f94ee3          	blt	s2,a5,8000414a <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    800041b2:	00000097          	auipc	ra,0x0
    800041b6:	c8c080e7          	jalr	-884(ra) # 80003e3e <write_head>
    install_trans(0); // Now install writes to home locations
    800041ba:	4501                	li	a0,0
    800041bc:	00000097          	auipc	ra,0x0
    800041c0:	cec080e7          	jalr	-788(ra) # 80003ea8 <install_trans>
    log.lh.n = 0;
    800041c4:	0001d797          	auipc	a5,0x1d
    800041c8:	b207a023          	sw	zero,-1248(a5) # 80020ce4 <log+0x2c>
    write_head();    // Erase the transaction from the log
    800041cc:	00000097          	auipc	ra,0x0
    800041d0:	c72080e7          	jalr	-910(ra) # 80003e3e <write_head>
    800041d4:	bdf5                	j	800040d0 <end_op+0x52>

00000000800041d6 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    800041d6:	1101                	addi	sp,sp,-32
    800041d8:	ec06                	sd	ra,24(sp)
    800041da:	e822                	sd	s0,16(sp)
    800041dc:	e426                	sd	s1,8(sp)
    800041de:	e04a                	sd	s2,0(sp)
    800041e0:	1000                	addi	s0,sp,32
    800041e2:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    800041e4:	0001d917          	auipc	s2,0x1d
    800041e8:	ad490913          	addi	s2,s2,-1324 # 80020cb8 <log>
    800041ec:	854a                	mv	a0,s2
    800041ee:	ffffd097          	auipc	ra,0xffffd
    800041f2:	9e4080e7          	jalr	-1564(ra) # 80000bd2 <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    800041f6:	02c92603          	lw	a2,44(s2)
    800041fa:	47f5                	li	a5,29
    800041fc:	06c7c563          	blt	a5,a2,80004266 <log_write+0x90>
    80004200:	0001d797          	auipc	a5,0x1d
    80004204:	ad47a783          	lw	a5,-1324(a5) # 80020cd4 <log+0x1c>
    80004208:	37fd                	addiw	a5,a5,-1
    8000420a:	04f65e63          	bge	a2,a5,80004266 <log_write+0x90>
    panic("too big a transaction");
  if (log.outstanding < 1)
    8000420e:	0001d797          	auipc	a5,0x1d
    80004212:	aca7a783          	lw	a5,-1334(a5) # 80020cd8 <log+0x20>
    80004216:	06f05063          	blez	a5,80004276 <log_write+0xa0>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    8000421a:	4781                	li	a5,0
    8000421c:	06c05563          	blez	a2,80004286 <log_write+0xb0>
    if (log.lh.block[i] == b->blockno)   // log absorption
    80004220:	44cc                	lw	a1,12(s1)
    80004222:	0001d717          	auipc	a4,0x1d
    80004226:	ac670713          	addi	a4,a4,-1338 # 80020ce8 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    8000422a:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    8000422c:	4314                	lw	a3,0(a4)
    8000422e:	04b68c63          	beq	a3,a1,80004286 <log_write+0xb0>
  for (i = 0; i < log.lh.n; i++) {
    80004232:	2785                	addiw	a5,a5,1
    80004234:	0711                	addi	a4,a4,4
    80004236:	fef61be3          	bne	a2,a5,8000422c <log_write+0x56>
      break;
  }
  log.lh.block[i] = b->blockno;
    8000423a:	0621                	addi	a2,a2,8
    8000423c:	060a                	slli	a2,a2,0x2
    8000423e:	0001d797          	auipc	a5,0x1d
    80004242:	a7a78793          	addi	a5,a5,-1414 # 80020cb8 <log>
    80004246:	97b2                	add	a5,a5,a2
    80004248:	44d8                	lw	a4,12(s1)
    8000424a:	cb98                	sw	a4,16(a5)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    8000424c:	8526                	mv	a0,s1
    8000424e:	fffff097          	auipc	ra,0xfffff
    80004252:	dcc080e7          	jalr	-564(ra) # 8000301a <bpin>
    log.lh.n++;
    80004256:	0001d717          	auipc	a4,0x1d
    8000425a:	a6270713          	addi	a4,a4,-1438 # 80020cb8 <log>
    8000425e:	575c                	lw	a5,44(a4)
    80004260:	2785                	addiw	a5,a5,1
    80004262:	d75c                	sw	a5,44(a4)
    80004264:	a82d                	j	8000429e <log_write+0xc8>
    panic("too big a transaction");
    80004266:	00004517          	auipc	a0,0x4
    8000426a:	3da50513          	addi	a0,a0,986 # 80008640 <syscalls+0x1f8>
    8000426e:	ffffc097          	auipc	ra,0xffffc
    80004272:	2ce080e7          	jalr	718(ra) # 8000053c <panic>
    panic("log_write outside of trans");
    80004276:	00004517          	auipc	a0,0x4
    8000427a:	3e250513          	addi	a0,a0,994 # 80008658 <syscalls+0x210>
    8000427e:	ffffc097          	auipc	ra,0xffffc
    80004282:	2be080e7          	jalr	702(ra) # 8000053c <panic>
  log.lh.block[i] = b->blockno;
    80004286:	00878693          	addi	a3,a5,8
    8000428a:	068a                	slli	a3,a3,0x2
    8000428c:	0001d717          	auipc	a4,0x1d
    80004290:	a2c70713          	addi	a4,a4,-1492 # 80020cb8 <log>
    80004294:	9736                	add	a4,a4,a3
    80004296:	44d4                	lw	a3,12(s1)
    80004298:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    8000429a:	faf609e3          	beq	a2,a5,8000424c <log_write+0x76>
  }
  release(&log.lock);
    8000429e:	0001d517          	auipc	a0,0x1d
    800042a2:	a1a50513          	addi	a0,a0,-1510 # 80020cb8 <log>
    800042a6:	ffffd097          	auipc	ra,0xffffd
    800042aa:	9e0080e7          	jalr	-1568(ra) # 80000c86 <release>
}
    800042ae:	60e2                	ld	ra,24(sp)
    800042b0:	6442                	ld	s0,16(sp)
    800042b2:	64a2                	ld	s1,8(sp)
    800042b4:	6902                	ld	s2,0(sp)
    800042b6:	6105                	addi	sp,sp,32
    800042b8:	8082                	ret

00000000800042ba <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    800042ba:	1101                	addi	sp,sp,-32
    800042bc:	ec06                	sd	ra,24(sp)
    800042be:	e822                	sd	s0,16(sp)
    800042c0:	e426                	sd	s1,8(sp)
    800042c2:	e04a                	sd	s2,0(sp)
    800042c4:	1000                	addi	s0,sp,32
    800042c6:	84aa                	mv	s1,a0
    800042c8:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    800042ca:	00004597          	auipc	a1,0x4
    800042ce:	3ae58593          	addi	a1,a1,942 # 80008678 <syscalls+0x230>
    800042d2:	0521                	addi	a0,a0,8
    800042d4:	ffffd097          	auipc	ra,0xffffd
    800042d8:	86e080e7          	jalr	-1938(ra) # 80000b42 <initlock>
  lk->name = name;
    800042dc:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    800042e0:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800042e4:	0204a423          	sw	zero,40(s1)
}
    800042e8:	60e2                	ld	ra,24(sp)
    800042ea:	6442                	ld	s0,16(sp)
    800042ec:	64a2                	ld	s1,8(sp)
    800042ee:	6902                	ld	s2,0(sp)
    800042f0:	6105                	addi	sp,sp,32
    800042f2:	8082                	ret

00000000800042f4 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    800042f4:	1101                	addi	sp,sp,-32
    800042f6:	ec06                	sd	ra,24(sp)
    800042f8:	e822                	sd	s0,16(sp)
    800042fa:	e426                	sd	s1,8(sp)
    800042fc:	e04a                	sd	s2,0(sp)
    800042fe:	1000                	addi	s0,sp,32
    80004300:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004302:	00850913          	addi	s2,a0,8
    80004306:	854a                	mv	a0,s2
    80004308:	ffffd097          	auipc	ra,0xffffd
    8000430c:	8ca080e7          	jalr	-1846(ra) # 80000bd2 <acquire>
  while (lk->locked) {
    80004310:	409c                	lw	a5,0(s1)
    80004312:	cb89                	beqz	a5,80004324 <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    80004314:	85ca                	mv	a1,s2
    80004316:	8526                	mv	a0,s1
    80004318:	ffffe097          	auipc	ra,0xffffe
    8000431c:	d62080e7          	jalr	-670(ra) # 8000207a <sleep>
  while (lk->locked) {
    80004320:	409c                	lw	a5,0(s1)
    80004322:	fbed                	bnez	a5,80004314 <acquiresleep+0x20>
  }
  lk->locked = 1;
    80004324:	4785                	li	a5,1
    80004326:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80004328:	ffffd097          	auipc	ra,0xffffd
    8000432c:	6a2080e7          	jalr	1698(ra) # 800019ca <myproc>
    80004330:	591c                	lw	a5,48(a0)
    80004332:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    80004334:	854a                	mv	a0,s2
    80004336:	ffffd097          	auipc	ra,0xffffd
    8000433a:	950080e7          	jalr	-1712(ra) # 80000c86 <release>
}
    8000433e:	60e2                	ld	ra,24(sp)
    80004340:	6442                	ld	s0,16(sp)
    80004342:	64a2                	ld	s1,8(sp)
    80004344:	6902                	ld	s2,0(sp)
    80004346:	6105                	addi	sp,sp,32
    80004348:	8082                	ret

000000008000434a <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    8000434a:	1101                	addi	sp,sp,-32
    8000434c:	ec06                	sd	ra,24(sp)
    8000434e:	e822                	sd	s0,16(sp)
    80004350:	e426                	sd	s1,8(sp)
    80004352:	e04a                	sd	s2,0(sp)
    80004354:	1000                	addi	s0,sp,32
    80004356:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004358:	00850913          	addi	s2,a0,8
    8000435c:	854a                	mv	a0,s2
    8000435e:	ffffd097          	auipc	ra,0xffffd
    80004362:	874080e7          	jalr	-1932(ra) # 80000bd2 <acquire>
  lk->locked = 0;
    80004366:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    8000436a:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    8000436e:	8526                	mv	a0,s1
    80004370:	ffffe097          	auipc	ra,0xffffe
    80004374:	d6e080e7          	jalr	-658(ra) # 800020de <wakeup>
  release(&lk->lk);
    80004378:	854a                	mv	a0,s2
    8000437a:	ffffd097          	auipc	ra,0xffffd
    8000437e:	90c080e7          	jalr	-1780(ra) # 80000c86 <release>
}
    80004382:	60e2                	ld	ra,24(sp)
    80004384:	6442                	ld	s0,16(sp)
    80004386:	64a2                	ld	s1,8(sp)
    80004388:	6902                	ld	s2,0(sp)
    8000438a:	6105                	addi	sp,sp,32
    8000438c:	8082                	ret

000000008000438e <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    8000438e:	7179                	addi	sp,sp,-48
    80004390:	f406                	sd	ra,40(sp)
    80004392:	f022                	sd	s0,32(sp)
    80004394:	ec26                	sd	s1,24(sp)
    80004396:	e84a                	sd	s2,16(sp)
    80004398:	e44e                	sd	s3,8(sp)
    8000439a:	1800                	addi	s0,sp,48
    8000439c:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    8000439e:	00850913          	addi	s2,a0,8
    800043a2:	854a                	mv	a0,s2
    800043a4:	ffffd097          	auipc	ra,0xffffd
    800043a8:	82e080e7          	jalr	-2002(ra) # 80000bd2 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    800043ac:	409c                	lw	a5,0(s1)
    800043ae:	ef99                	bnez	a5,800043cc <holdingsleep+0x3e>
    800043b0:	4481                	li	s1,0
  release(&lk->lk);
    800043b2:	854a                	mv	a0,s2
    800043b4:	ffffd097          	auipc	ra,0xffffd
    800043b8:	8d2080e7          	jalr	-1838(ra) # 80000c86 <release>
  return r;
}
    800043bc:	8526                	mv	a0,s1
    800043be:	70a2                	ld	ra,40(sp)
    800043c0:	7402                	ld	s0,32(sp)
    800043c2:	64e2                	ld	s1,24(sp)
    800043c4:	6942                	ld	s2,16(sp)
    800043c6:	69a2                	ld	s3,8(sp)
    800043c8:	6145                	addi	sp,sp,48
    800043ca:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    800043cc:	0284a983          	lw	s3,40(s1)
    800043d0:	ffffd097          	auipc	ra,0xffffd
    800043d4:	5fa080e7          	jalr	1530(ra) # 800019ca <myproc>
    800043d8:	5904                	lw	s1,48(a0)
    800043da:	413484b3          	sub	s1,s1,s3
    800043de:	0014b493          	seqz	s1,s1
    800043e2:	bfc1                	j	800043b2 <holdingsleep+0x24>

00000000800043e4 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    800043e4:	1141                	addi	sp,sp,-16
    800043e6:	e406                	sd	ra,8(sp)
    800043e8:	e022                	sd	s0,0(sp)
    800043ea:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    800043ec:	00004597          	auipc	a1,0x4
    800043f0:	29c58593          	addi	a1,a1,668 # 80008688 <syscalls+0x240>
    800043f4:	0001d517          	auipc	a0,0x1d
    800043f8:	a0c50513          	addi	a0,a0,-1524 # 80020e00 <ftable>
    800043fc:	ffffc097          	auipc	ra,0xffffc
    80004400:	746080e7          	jalr	1862(ra) # 80000b42 <initlock>
}
    80004404:	60a2                	ld	ra,8(sp)
    80004406:	6402                	ld	s0,0(sp)
    80004408:	0141                	addi	sp,sp,16
    8000440a:	8082                	ret

000000008000440c <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    8000440c:	1101                	addi	sp,sp,-32
    8000440e:	ec06                	sd	ra,24(sp)
    80004410:	e822                	sd	s0,16(sp)
    80004412:	e426                	sd	s1,8(sp)
    80004414:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80004416:	0001d517          	auipc	a0,0x1d
    8000441a:	9ea50513          	addi	a0,a0,-1558 # 80020e00 <ftable>
    8000441e:	ffffc097          	auipc	ra,0xffffc
    80004422:	7b4080e7          	jalr	1972(ra) # 80000bd2 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004426:	0001d497          	auipc	s1,0x1d
    8000442a:	9f248493          	addi	s1,s1,-1550 # 80020e18 <ftable+0x18>
    8000442e:	0001e717          	auipc	a4,0x1e
    80004432:	98a70713          	addi	a4,a4,-1654 # 80021db8 <disk>
    if(f->ref == 0){
    80004436:	40dc                	lw	a5,4(s1)
    80004438:	cf99                	beqz	a5,80004456 <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    8000443a:	02848493          	addi	s1,s1,40
    8000443e:	fee49ce3          	bne	s1,a4,80004436 <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80004442:	0001d517          	auipc	a0,0x1d
    80004446:	9be50513          	addi	a0,a0,-1602 # 80020e00 <ftable>
    8000444a:	ffffd097          	auipc	ra,0xffffd
    8000444e:	83c080e7          	jalr	-1988(ra) # 80000c86 <release>
  return 0;
    80004452:	4481                	li	s1,0
    80004454:	a819                	j	8000446a <filealloc+0x5e>
      f->ref = 1;
    80004456:	4785                	li	a5,1
    80004458:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    8000445a:	0001d517          	auipc	a0,0x1d
    8000445e:	9a650513          	addi	a0,a0,-1626 # 80020e00 <ftable>
    80004462:	ffffd097          	auipc	ra,0xffffd
    80004466:	824080e7          	jalr	-2012(ra) # 80000c86 <release>
}
    8000446a:	8526                	mv	a0,s1
    8000446c:	60e2                	ld	ra,24(sp)
    8000446e:	6442                	ld	s0,16(sp)
    80004470:	64a2                	ld	s1,8(sp)
    80004472:	6105                	addi	sp,sp,32
    80004474:	8082                	ret

0000000080004476 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80004476:	1101                	addi	sp,sp,-32
    80004478:	ec06                	sd	ra,24(sp)
    8000447a:	e822                	sd	s0,16(sp)
    8000447c:	e426                	sd	s1,8(sp)
    8000447e:	1000                	addi	s0,sp,32
    80004480:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80004482:	0001d517          	auipc	a0,0x1d
    80004486:	97e50513          	addi	a0,a0,-1666 # 80020e00 <ftable>
    8000448a:	ffffc097          	auipc	ra,0xffffc
    8000448e:	748080e7          	jalr	1864(ra) # 80000bd2 <acquire>
  if(f->ref < 1)
    80004492:	40dc                	lw	a5,4(s1)
    80004494:	02f05263          	blez	a5,800044b8 <filedup+0x42>
    panic("filedup");
  f->ref++;
    80004498:	2785                	addiw	a5,a5,1
    8000449a:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    8000449c:	0001d517          	auipc	a0,0x1d
    800044a0:	96450513          	addi	a0,a0,-1692 # 80020e00 <ftable>
    800044a4:	ffffc097          	auipc	ra,0xffffc
    800044a8:	7e2080e7          	jalr	2018(ra) # 80000c86 <release>
  return f;
}
    800044ac:	8526                	mv	a0,s1
    800044ae:	60e2                	ld	ra,24(sp)
    800044b0:	6442                	ld	s0,16(sp)
    800044b2:	64a2                	ld	s1,8(sp)
    800044b4:	6105                	addi	sp,sp,32
    800044b6:	8082                	ret
    panic("filedup");
    800044b8:	00004517          	auipc	a0,0x4
    800044bc:	1d850513          	addi	a0,a0,472 # 80008690 <syscalls+0x248>
    800044c0:	ffffc097          	auipc	ra,0xffffc
    800044c4:	07c080e7          	jalr	124(ra) # 8000053c <panic>

00000000800044c8 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    800044c8:	7139                	addi	sp,sp,-64
    800044ca:	fc06                	sd	ra,56(sp)
    800044cc:	f822                	sd	s0,48(sp)
    800044ce:	f426                	sd	s1,40(sp)
    800044d0:	f04a                	sd	s2,32(sp)
    800044d2:	ec4e                	sd	s3,24(sp)
    800044d4:	e852                	sd	s4,16(sp)
    800044d6:	e456                	sd	s5,8(sp)
    800044d8:	0080                	addi	s0,sp,64
    800044da:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    800044dc:	0001d517          	auipc	a0,0x1d
    800044e0:	92450513          	addi	a0,a0,-1756 # 80020e00 <ftable>
    800044e4:	ffffc097          	auipc	ra,0xffffc
    800044e8:	6ee080e7          	jalr	1774(ra) # 80000bd2 <acquire>
  if(f->ref < 1)
    800044ec:	40dc                	lw	a5,4(s1)
    800044ee:	06f05163          	blez	a5,80004550 <fileclose+0x88>
    panic("fileclose");
  if(--f->ref > 0){
    800044f2:	37fd                	addiw	a5,a5,-1
    800044f4:	0007871b          	sext.w	a4,a5
    800044f8:	c0dc                	sw	a5,4(s1)
    800044fa:	06e04363          	bgtz	a4,80004560 <fileclose+0x98>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    800044fe:	0004a903          	lw	s2,0(s1)
    80004502:	0094ca83          	lbu	s5,9(s1)
    80004506:	0104ba03          	ld	s4,16(s1)
    8000450a:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    8000450e:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80004512:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80004516:	0001d517          	auipc	a0,0x1d
    8000451a:	8ea50513          	addi	a0,a0,-1814 # 80020e00 <ftable>
    8000451e:	ffffc097          	auipc	ra,0xffffc
    80004522:	768080e7          	jalr	1896(ra) # 80000c86 <release>

  if(ff.type == FD_PIPE){
    80004526:	4785                	li	a5,1
    80004528:	04f90d63          	beq	s2,a5,80004582 <fileclose+0xba>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    8000452c:	3979                	addiw	s2,s2,-2
    8000452e:	4785                	li	a5,1
    80004530:	0527e063          	bltu	a5,s2,80004570 <fileclose+0xa8>
    begin_op();
    80004534:	00000097          	auipc	ra,0x0
    80004538:	ad0080e7          	jalr	-1328(ra) # 80004004 <begin_op>
    iput(ff.ip);
    8000453c:	854e                	mv	a0,s3
    8000453e:	fffff097          	auipc	ra,0xfffff
    80004542:	2da080e7          	jalr	730(ra) # 80003818 <iput>
    end_op();
    80004546:	00000097          	auipc	ra,0x0
    8000454a:	b38080e7          	jalr	-1224(ra) # 8000407e <end_op>
    8000454e:	a00d                	j	80004570 <fileclose+0xa8>
    panic("fileclose");
    80004550:	00004517          	auipc	a0,0x4
    80004554:	14850513          	addi	a0,a0,328 # 80008698 <syscalls+0x250>
    80004558:	ffffc097          	auipc	ra,0xffffc
    8000455c:	fe4080e7          	jalr	-28(ra) # 8000053c <panic>
    release(&ftable.lock);
    80004560:	0001d517          	auipc	a0,0x1d
    80004564:	8a050513          	addi	a0,a0,-1888 # 80020e00 <ftable>
    80004568:	ffffc097          	auipc	ra,0xffffc
    8000456c:	71e080e7          	jalr	1822(ra) # 80000c86 <release>
  }
}
    80004570:	70e2                	ld	ra,56(sp)
    80004572:	7442                	ld	s0,48(sp)
    80004574:	74a2                	ld	s1,40(sp)
    80004576:	7902                	ld	s2,32(sp)
    80004578:	69e2                	ld	s3,24(sp)
    8000457a:	6a42                	ld	s4,16(sp)
    8000457c:	6aa2                	ld	s5,8(sp)
    8000457e:	6121                	addi	sp,sp,64
    80004580:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80004582:	85d6                	mv	a1,s5
    80004584:	8552                	mv	a0,s4
    80004586:	00000097          	auipc	ra,0x0
    8000458a:	348080e7          	jalr	840(ra) # 800048ce <pipeclose>
    8000458e:	b7cd                	j	80004570 <fileclose+0xa8>

0000000080004590 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80004590:	715d                	addi	sp,sp,-80
    80004592:	e486                	sd	ra,72(sp)
    80004594:	e0a2                	sd	s0,64(sp)
    80004596:	fc26                	sd	s1,56(sp)
    80004598:	f84a                	sd	s2,48(sp)
    8000459a:	f44e                	sd	s3,40(sp)
    8000459c:	0880                	addi	s0,sp,80
    8000459e:	84aa                	mv	s1,a0
    800045a0:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    800045a2:	ffffd097          	auipc	ra,0xffffd
    800045a6:	428080e7          	jalr	1064(ra) # 800019ca <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    800045aa:	409c                	lw	a5,0(s1)
    800045ac:	37f9                	addiw	a5,a5,-2
    800045ae:	4705                	li	a4,1
    800045b0:	04f76763          	bltu	a4,a5,800045fe <filestat+0x6e>
    800045b4:	892a                	mv	s2,a0
    ilock(f->ip);
    800045b6:	6c88                	ld	a0,24(s1)
    800045b8:	fffff097          	auipc	ra,0xfffff
    800045bc:	0a6080e7          	jalr	166(ra) # 8000365e <ilock>
    stati(f->ip, &st);
    800045c0:	fb840593          	addi	a1,s0,-72
    800045c4:	6c88                	ld	a0,24(s1)
    800045c6:	fffff097          	auipc	ra,0xfffff
    800045ca:	322080e7          	jalr	802(ra) # 800038e8 <stati>
    iunlock(f->ip);
    800045ce:	6c88                	ld	a0,24(s1)
    800045d0:	fffff097          	auipc	ra,0xfffff
    800045d4:	150080e7          	jalr	336(ra) # 80003720 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    800045d8:	46e1                	li	a3,24
    800045da:	fb840613          	addi	a2,s0,-72
    800045de:	85ce                	mv	a1,s3
    800045e0:	05093503          	ld	a0,80(s2)
    800045e4:	ffffd097          	auipc	ra,0xffffd
    800045e8:	0a6080e7          	jalr	166(ra) # 8000168a <copyout>
    800045ec:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    800045f0:	60a6                	ld	ra,72(sp)
    800045f2:	6406                	ld	s0,64(sp)
    800045f4:	74e2                	ld	s1,56(sp)
    800045f6:	7942                	ld	s2,48(sp)
    800045f8:	79a2                	ld	s3,40(sp)
    800045fa:	6161                	addi	sp,sp,80
    800045fc:	8082                	ret
  return -1;
    800045fe:	557d                	li	a0,-1
    80004600:	bfc5                	j	800045f0 <filestat+0x60>

0000000080004602 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80004602:	7179                	addi	sp,sp,-48
    80004604:	f406                	sd	ra,40(sp)
    80004606:	f022                	sd	s0,32(sp)
    80004608:	ec26                	sd	s1,24(sp)
    8000460a:	e84a                	sd	s2,16(sp)
    8000460c:	e44e                	sd	s3,8(sp)
    8000460e:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80004610:	00854783          	lbu	a5,8(a0)
    80004614:	c3d5                	beqz	a5,800046b8 <fileread+0xb6>
    80004616:	84aa                	mv	s1,a0
    80004618:	89ae                	mv	s3,a1
    8000461a:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    8000461c:	411c                	lw	a5,0(a0)
    8000461e:	4705                	li	a4,1
    80004620:	04e78963          	beq	a5,a4,80004672 <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004624:	470d                	li	a4,3
    80004626:	04e78d63          	beq	a5,a4,80004680 <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    8000462a:	4709                	li	a4,2
    8000462c:	06e79e63          	bne	a5,a4,800046a8 <fileread+0xa6>
    ilock(f->ip);
    80004630:	6d08                	ld	a0,24(a0)
    80004632:	fffff097          	auipc	ra,0xfffff
    80004636:	02c080e7          	jalr	44(ra) # 8000365e <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    8000463a:	874a                	mv	a4,s2
    8000463c:	5094                	lw	a3,32(s1)
    8000463e:	864e                	mv	a2,s3
    80004640:	4585                	li	a1,1
    80004642:	6c88                	ld	a0,24(s1)
    80004644:	fffff097          	auipc	ra,0xfffff
    80004648:	2ce080e7          	jalr	718(ra) # 80003912 <readi>
    8000464c:	892a                	mv	s2,a0
    8000464e:	00a05563          	blez	a0,80004658 <fileread+0x56>
      f->off += r;
    80004652:	509c                	lw	a5,32(s1)
    80004654:	9fa9                	addw	a5,a5,a0
    80004656:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80004658:	6c88                	ld	a0,24(s1)
    8000465a:	fffff097          	auipc	ra,0xfffff
    8000465e:	0c6080e7          	jalr	198(ra) # 80003720 <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    80004662:	854a                	mv	a0,s2
    80004664:	70a2                	ld	ra,40(sp)
    80004666:	7402                	ld	s0,32(sp)
    80004668:	64e2                	ld	s1,24(sp)
    8000466a:	6942                	ld	s2,16(sp)
    8000466c:	69a2                	ld	s3,8(sp)
    8000466e:	6145                	addi	sp,sp,48
    80004670:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80004672:	6908                	ld	a0,16(a0)
    80004674:	00000097          	auipc	ra,0x0
    80004678:	3c2080e7          	jalr	962(ra) # 80004a36 <piperead>
    8000467c:	892a                	mv	s2,a0
    8000467e:	b7d5                	j	80004662 <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80004680:	02451783          	lh	a5,36(a0)
    80004684:	03079693          	slli	a3,a5,0x30
    80004688:	92c1                	srli	a3,a3,0x30
    8000468a:	4725                	li	a4,9
    8000468c:	02d76863          	bltu	a4,a3,800046bc <fileread+0xba>
    80004690:	0792                	slli	a5,a5,0x4
    80004692:	0001c717          	auipc	a4,0x1c
    80004696:	6ce70713          	addi	a4,a4,1742 # 80020d60 <devsw>
    8000469a:	97ba                	add	a5,a5,a4
    8000469c:	639c                	ld	a5,0(a5)
    8000469e:	c38d                	beqz	a5,800046c0 <fileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    800046a0:	4505                	li	a0,1
    800046a2:	9782                	jalr	a5
    800046a4:	892a                	mv	s2,a0
    800046a6:	bf75                	j	80004662 <fileread+0x60>
    panic("fileread");
    800046a8:	00004517          	auipc	a0,0x4
    800046ac:	00050513          	mv	a0,a0
    800046b0:	ffffc097          	auipc	ra,0xffffc
    800046b4:	e8c080e7          	jalr	-372(ra) # 8000053c <panic>
    return -1;
    800046b8:	597d                	li	s2,-1
    800046ba:	b765                	j	80004662 <fileread+0x60>
      return -1;
    800046bc:	597d                	li	s2,-1
    800046be:	b755                	j	80004662 <fileread+0x60>
    800046c0:	597d                	li	s2,-1
    800046c2:	b745                	j	80004662 <fileread+0x60>

00000000800046c4 <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if(f->writable == 0)
    800046c4:	00954783          	lbu	a5,9(a0) # 800086b1 <syscalls+0x269>
    800046c8:	10078e63          	beqz	a5,800047e4 <filewrite+0x120>
{
    800046cc:	715d                	addi	sp,sp,-80
    800046ce:	e486                	sd	ra,72(sp)
    800046d0:	e0a2                	sd	s0,64(sp)
    800046d2:	fc26                	sd	s1,56(sp)
    800046d4:	f84a                	sd	s2,48(sp)
    800046d6:	f44e                	sd	s3,40(sp)
    800046d8:	f052                	sd	s4,32(sp)
    800046da:	ec56                	sd	s5,24(sp)
    800046dc:	e85a                	sd	s6,16(sp)
    800046de:	e45e                	sd	s7,8(sp)
    800046e0:	e062                	sd	s8,0(sp)
    800046e2:	0880                	addi	s0,sp,80
    800046e4:	892a                	mv	s2,a0
    800046e6:	8b2e                	mv	s6,a1
    800046e8:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    800046ea:	411c                	lw	a5,0(a0)
    800046ec:	4705                	li	a4,1
    800046ee:	02e78263          	beq	a5,a4,80004712 <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    800046f2:	470d                	li	a4,3
    800046f4:	02e78563          	beq	a5,a4,8000471e <filewrite+0x5a>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    800046f8:	4709                	li	a4,2
    800046fa:	0ce79d63          	bne	a5,a4,800047d4 <filewrite+0x110>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    800046fe:	0ac05b63          	blez	a2,800047b4 <filewrite+0xf0>
    int i = 0;
    80004702:	4981                	li	s3,0
      int n1 = n - i;
      if(n1 > max)
    80004704:	6b85                	lui	s7,0x1
    80004706:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    8000470a:	6c05                	lui	s8,0x1
    8000470c:	c00c0c1b          	addiw	s8,s8,-1024 # c00 <_entry-0x7ffff400>
    80004710:	a851                	j	800047a4 <filewrite+0xe0>
    ret = pipewrite(f->pipe, addr, n);
    80004712:	6908                	ld	a0,16(a0)
    80004714:	00000097          	auipc	ra,0x0
    80004718:	22a080e7          	jalr	554(ra) # 8000493e <pipewrite>
    8000471c:	a045                	j	800047bc <filewrite+0xf8>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    8000471e:	02451783          	lh	a5,36(a0)
    80004722:	03079693          	slli	a3,a5,0x30
    80004726:	92c1                	srli	a3,a3,0x30
    80004728:	4725                	li	a4,9
    8000472a:	0ad76f63          	bltu	a4,a3,800047e8 <filewrite+0x124>
    8000472e:	0792                	slli	a5,a5,0x4
    80004730:	0001c717          	auipc	a4,0x1c
    80004734:	63070713          	addi	a4,a4,1584 # 80020d60 <devsw>
    80004738:	97ba                	add	a5,a5,a4
    8000473a:	679c                	ld	a5,8(a5)
    8000473c:	cbc5                	beqz	a5,800047ec <filewrite+0x128>
    ret = devsw[f->major].write(1, addr, n);
    8000473e:	4505                	li	a0,1
    80004740:	9782                	jalr	a5
    80004742:	a8ad                	j	800047bc <filewrite+0xf8>
      if(n1 > max)
    80004744:	00048a9b          	sext.w	s5,s1
        n1 = max;

      begin_op();
    80004748:	00000097          	auipc	ra,0x0
    8000474c:	8bc080e7          	jalr	-1860(ra) # 80004004 <begin_op>
      ilock(f->ip);
    80004750:	01893503          	ld	a0,24(s2)
    80004754:	fffff097          	auipc	ra,0xfffff
    80004758:	f0a080e7          	jalr	-246(ra) # 8000365e <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    8000475c:	8756                	mv	a4,s5
    8000475e:	02092683          	lw	a3,32(s2)
    80004762:	01698633          	add	a2,s3,s6
    80004766:	4585                	li	a1,1
    80004768:	01893503          	ld	a0,24(s2)
    8000476c:	fffff097          	auipc	ra,0xfffff
    80004770:	29e080e7          	jalr	670(ra) # 80003a0a <writei>
    80004774:	84aa                	mv	s1,a0
    80004776:	00a05763          	blez	a0,80004784 <filewrite+0xc0>
        f->off += r;
    8000477a:	02092783          	lw	a5,32(s2)
    8000477e:	9fa9                	addw	a5,a5,a0
    80004780:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80004784:	01893503          	ld	a0,24(s2)
    80004788:	fffff097          	auipc	ra,0xfffff
    8000478c:	f98080e7          	jalr	-104(ra) # 80003720 <iunlock>
      end_op();
    80004790:	00000097          	auipc	ra,0x0
    80004794:	8ee080e7          	jalr	-1810(ra) # 8000407e <end_op>

      if(r != n1){
    80004798:	009a9f63          	bne	s5,s1,800047b6 <filewrite+0xf2>
        // error from writei
        break;
      }
      i += r;
    8000479c:	013489bb          	addw	s3,s1,s3
    while(i < n){
    800047a0:	0149db63          	bge	s3,s4,800047b6 <filewrite+0xf2>
      int n1 = n - i;
    800047a4:	413a04bb          	subw	s1,s4,s3
      if(n1 > max)
    800047a8:	0004879b          	sext.w	a5,s1
    800047ac:	f8fbdce3          	bge	s7,a5,80004744 <filewrite+0x80>
    800047b0:	84e2                	mv	s1,s8
    800047b2:	bf49                	j	80004744 <filewrite+0x80>
    int i = 0;
    800047b4:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    800047b6:	033a1d63          	bne	s4,s3,800047f0 <filewrite+0x12c>
    800047ba:	8552                	mv	a0,s4
  } else {
    panic("filewrite");
  }

  return ret;
}
    800047bc:	60a6                	ld	ra,72(sp)
    800047be:	6406                	ld	s0,64(sp)
    800047c0:	74e2                	ld	s1,56(sp)
    800047c2:	7942                	ld	s2,48(sp)
    800047c4:	79a2                	ld	s3,40(sp)
    800047c6:	7a02                	ld	s4,32(sp)
    800047c8:	6ae2                	ld	s5,24(sp)
    800047ca:	6b42                	ld	s6,16(sp)
    800047cc:	6ba2                	ld	s7,8(sp)
    800047ce:	6c02                	ld	s8,0(sp)
    800047d0:	6161                	addi	sp,sp,80
    800047d2:	8082                	ret
    panic("filewrite");
    800047d4:	00004517          	auipc	a0,0x4
    800047d8:	ee450513          	addi	a0,a0,-284 # 800086b8 <syscalls+0x270>
    800047dc:	ffffc097          	auipc	ra,0xffffc
    800047e0:	d60080e7          	jalr	-672(ra) # 8000053c <panic>
    return -1;
    800047e4:	557d                	li	a0,-1
}
    800047e6:	8082                	ret
      return -1;
    800047e8:	557d                	li	a0,-1
    800047ea:	bfc9                	j	800047bc <filewrite+0xf8>
    800047ec:	557d                	li	a0,-1
    800047ee:	b7f9                	j	800047bc <filewrite+0xf8>
    ret = (i == n ? n : -1);
    800047f0:	557d                	li	a0,-1
    800047f2:	b7e9                	j	800047bc <filewrite+0xf8>

00000000800047f4 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    800047f4:	7179                	addi	sp,sp,-48
    800047f6:	f406                	sd	ra,40(sp)
    800047f8:	f022                	sd	s0,32(sp)
    800047fa:	ec26                	sd	s1,24(sp)
    800047fc:	e84a                	sd	s2,16(sp)
    800047fe:	e44e                	sd	s3,8(sp)
    80004800:	e052                	sd	s4,0(sp)
    80004802:	1800                	addi	s0,sp,48
    80004804:	84aa                	mv	s1,a0
    80004806:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80004808:	0005b023          	sd	zero,0(a1)
    8000480c:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80004810:	00000097          	auipc	ra,0x0
    80004814:	bfc080e7          	jalr	-1028(ra) # 8000440c <filealloc>
    80004818:	e088                	sd	a0,0(s1)
    8000481a:	c551                	beqz	a0,800048a6 <pipealloc+0xb2>
    8000481c:	00000097          	auipc	ra,0x0
    80004820:	bf0080e7          	jalr	-1040(ra) # 8000440c <filealloc>
    80004824:	00aa3023          	sd	a0,0(s4)
    80004828:	c92d                	beqz	a0,8000489a <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    8000482a:	ffffc097          	auipc	ra,0xffffc
    8000482e:	2b8080e7          	jalr	696(ra) # 80000ae2 <kalloc>
    80004832:	892a                	mv	s2,a0
    80004834:	c125                	beqz	a0,80004894 <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    80004836:	4985                	li	s3,1
    80004838:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    8000483c:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80004840:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80004844:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80004848:	00004597          	auipc	a1,0x4
    8000484c:	e8058593          	addi	a1,a1,-384 # 800086c8 <syscalls+0x280>
    80004850:	ffffc097          	auipc	ra,0xffffc
    80004854:	2f2080e7          	jalr	754(ra) # 80000b42 <initlock>
  (*f0)->type = FD_PIPE;
    80004858:	609c                	ld	a5,0(s1)
    8000485a:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    8000485e:	609c                	ld	a5,0(s1)
    80004860:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80004864:	609c                	ld	a5,0(s1)
    80004866:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    8000486a:	609c                	ld	a5,0(s1)
    8000486c:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80004870:	000a3783          	ld	a5,0(s4)
    80004874:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80004878:	000a3783          	ld	a5,0(s4)
    8000487c:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80004880:	000a3783          	ld	a5,0(s4)
    80004884:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80004888:	000a3783          	ld	a5,0(s4)
    8000488c:	0127b823          	sd	s2,16(a5)
  return 0;
    80004890:	4501                	li	a0,0
    80004892:	a025                	j	800048ba <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80004894:	6088                	ld	a0,0(s1)
    80004896:	e501                	bnez	a0,8000489e <pipealloc+0xaa>
    80004898:	a039                	j	800048a6 <pipealloc+0xb2>
    8000489a:	6088                	ld	a0,0(s1)
    8000489c:	c51d                	beqz	a0,800048ca <pipealloc+0xd6>
    fileclose(*f0);
    8000489e:	00000097          	auipc	ra,0x0
    800048a2:	c2a080e7          	jalr	-982(ra) # 800044c8 <fileclose>
  if(*f1)
    800048a6:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    800048aa:	557d                	li	a0,-1
  if(*f1)
    800048ac:	c799                	beqz	a5,800048ba <pipealloc+0xc6>
    fileclose(*f1);
    800048ae:	853e                	mv	a0,a5
    800048b0:	00000097          	auipc	ra,0x0
    800048b4:	c18080e7          	jalr	-1000(ra) # 800044c8 <fileclose>
  return -1;
    800048b8:	557d                	li	a0,-1
}
    800048ba:	70a2                	ld	ra,40(sp)
    800048bc:	7402                	ld	s0,32(sp)
    800048be:	64e2                	ld	s1,24(sp)
    800048c0:	6942                	ld	s2,16(sp)
    800048c2:	69a2                	ld	s3,8(sp)
    800048c4:	6a02                	ld	s4,0(sp)
    800048c6:	6145                	addi	sp,sp,48
    800048c8:	8082                	ret
  return -1;
    800048ca:	557d                	li	a0,-1
    800048cc:	b7fd                	j	800048ba <pipealloc+0xc6>

00000000800048ce <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    800048ce:	1101                	addi	sp,sp,-32
    800048d0:	ec06                	sd	ra,24(sp)
    800048d2:	e822                	sd	s0,16(sp)
    800048d4:	e426                	sd	s1,8(sp)
    800048d6:	e04a                	sd	s2,0(sp)
    800048d8:	1000                	addi	s0,sp,32
    800048da:	84aa                	mv	s1,a0
    800048dc:	892e                	mv	s2,a1
  acquire(&pi->lock);
    800048de:	ffffc097          	auipc	ra,0xffffc
    800048e2:	2f4080e7          	jalr	756(ra) # 80000bd2 <acquire>
  if(writable){
    800048e6:	02090d63          	beqz	s2,80004920 <pipeclose+0x52>
    pi->writeopen = 0;
    800048ea:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    800048ee:	21848513          	addi	a0,s1,536
    800048f2:	ffffd097          	auipc	ra,0xffffd
    800048f6:	7ec080e7          	jalr	2028(ra) # 800020de <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    800048fa:	2204b783          	ld	a5,544(s1)
    800048fe:	eb95                	bnez	a5,80004932 <pipeclose+0x64>
    release(&pi->lock);
    80004900:	8526                	mv	a0,s1
    80004902:	ffffc097          	auipc	ra,0xffffc
    80004906:	384080e7          	jalr	900(ra) # 80000c86 <release>
    kfree((char*)pi);
    8000490a:	8526                	mv	a0,s1
    8000490c:	ffffc097          	auipc	ra,0xffffc
    80004910:	0d8080e7          	jalr	216(ra) # 800009e4 <kfree>
  } else
    release(&pi->lock);
}
    80004914:	60e2                	ld	ra,24(sp)
    80004916:	6442                	ld	s0,16(sp)
    80004918:	64a2                	ld	s1,8(sp)
    8000491a:	6902                	ld	s2,0(sp)
    8000491c:	6105                	addi	sp,sp,32
    8000491e:	8082                	ret
    pi->readopen = 0;
    80004920:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80004924:	21c48513          	addi	a0,s1,540
    80004928:	ffffd097          	auipc	ra,0xffffd
    8000492c:	7b6080e7          	jalr	1974(ra) # 800020de <wakeup>
    80004930:	b7e9                	j	800048fa <pipeclose+0x2c>
    release(&pi->lock);
    80004932:	8526                	mv	a0,s1
    80004934:	ffffc097          	auipc	ra,0xffffc
    80004938:	352080e7          	jalr	850(ra) # 80000c86 <release>
}
    8000493c:	bfe1                	j	80004914 <pipeclose+0x46>

000000008000493e <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    8000493e:	711d                	addi	sp,sp,-96
    80004940:	ec86                	sd	ra,88(sp)
    80004942:	e8a2                	sd	s0,80(sp)
    80004944:	e4a6                	sd	s1,72(sp)
    80004946:	e0ca                	sd	s2,64(sp)
    80004948:	fc4e                	sd	s3,56(sp)
    8000494a:	f852                	sd	s4,48(sp)
    8000494c:	f456                	sd	s5,40(sp)
    8000494e:	f05a                	sd	s6,32(sp)
    80004950:	ec5e                	sd	s7,24(sp)
    80004952:	e862                	sd	s8,16(sp)
    80004954:	1080                	addi	s0,sp,96
    80004956:	84aa                	mv	s1,a0
    80004958:	8aae                	mv	s5,a1
    8000495a:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    8000495c:	ffffd097          	auipc	ra,0xffffd
    80004960:	06e080e7          	jalr	110(ra) # 800019ca <myproc>
    80004964:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80004966:	8526                	mv	a0,s1
    80004968:	ffffc097          	auipc	ra,0xffffc
    8000496c:	26a080e7          	jalr	618(ra) # 80000bd2 <acquire>
  while(i < n){
    80004970:	0b405663          	blez	s4,80004a1c <pipewrite+0xde>
  int i = 0;
    80004974:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004976:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80004978:	21848c13          	addi	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    8000497c:	21c48b93          	addi	s7,s1,540
    80004980:	a089                	j	800049c2 <pipewrite+0x84>
      release(&pi->lock);
    80004982:	8526                	mv	a0,s1
    80004984:	ffffc097          	auipc	ra,0xffffc
    80004988:	302080e7          	jalr	770(ra) # 80000c86 <release>
      return -1;
    8000498c:	597d                	li	s2,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    8000498e:	854a                	mv	a0,s2
    80004990:	60e6                	ld	ra,88(sp)
    80004992:	6446                	ld	s0,80(sp)
    80004994:	64a6                	ld	s1,72(sp)
    80004996:	6906                	ld	s2,64(sp)
    80004998:	79e2                	ld	s3,56(sp)
    8000499a:	7a42                	ld	s4,48(sp)
    8000499c:	7aa2                	ld	s5,40(sp)
    8000499e:	7b02                	ld	s6,32(sp)
    800049a0:	6be2                	ld	s7,24(sp)
    800049a2:	6c42                	ld	s8,16(sp)
    800049a4:	6125                	addi	sp,sp,96
    800049a6:	8082                	ret
      wakeup(&pi->nread);
    800049a8:	8562                	mv	a0,s8
    800049aa:	ffffd097          	auipc	ra,0xffffd
    800049ae:	734080e7          	jalr	1844(ra) # 800020de <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    800049b2:	85a6                	mv	a1,s1
    800049b4:	855e                	mv	a0,s7
    800049b6:	ffffd097          	auipc	ra,0xffffd
    800049ba:	6c4080e7          	jalr	1732(ra) # 8000207a <sleep>
  while(i < n){
    800049be:	07495063          	bge	s2,s4,80004a1e <pipewrite+0xe0>
    if(pi->readopen == 0 || killed(pr)){
    800049c2:	2204a783          	lw	a5,544(s1)
    800049c6:	dfd5                	beqz	a5,80004982 <pipewrite+0x44>
    800049c8:	854e                	mv	a0,s3
    800049ca:	ffffe097          	auipc	ra,0xffffe
    800049ce:	958080e7          	jalr	-1704(ra) # 80002322 <killed>
    800049d2:	f945                	bnez	a0,80004982 <pipewrite+0x44>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    800049d4:	2184a783          	lw	a5,536(s1)
    800049d8:	21c4a703          	lw	a4,540(s1)
    800049dc:	2007879b          	addiw	a5,a5,512
    800049e0:	fcf704e3          	beq	a4,a5,800049a8 <pipewrite+0x6a>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    800049e4:	4685                	li	a3,1
    800049e6:	01590633          	add	a2,s2,s5
    800049ea:	faf40593          	addi	a1,s0,-81
    800049ee:	0509b503          	ld	a0,80(s3)
    800049f2:	ffffd097          	auipc	ra,0xffffd
    800049f6:	d24080e7          	jalr	-732(ra) # 80001716 <copyin>
    800049fa:	03650263          	beq	a0,s6,80004a1e <pipewrite+0xe0>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    800049fe:	21c4a783          	lw	a5,540(s1)
    80004a02:	0017871b          	addiw	a4,a5,1
    80004a06:	20e4ae23          	sw	a4,540(s1)
    80004a0a:	1ff7f793          	andi	a5,a5,511
    80004a0e:	97a6                	add	a5,a5,s1
    80004a10:	faf44703          	lbu	a4,-81(s0)
    80004a14:	00e78c23          	sb	a4,24(a5)
      i++;
    80004a18:	2905                	addiw	s2,s2,1
    80004a1a:	b755                	j	800049be <pipewrite+0x80>
  int i = 0;
    80004a1c:	4901                	li	s2,0
  wakeup(&pi->nread);
    80004a1e:	21848513          	addi	a0,s1,536
    80004a22:	ffffd097          	auipc	ra,0xffffd
    80004a26:	6bc080e7          	jalr	1724(ra) # 800020de <wakeup>
  release(&pi->lock);
    80004a2a:	8526                	mv	a0,s1
    80004a2c:	ffffc097          	auipc	ra,0xffffc
    80004a30:	25a080e7          	jalr	602(ra) # 80000c86 <release>
  return i;
    80004a34:	bfa9                	j	8000498e <pipewrite+0x50>

0000000080004a36 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80004a36:	715d                	addi	sp,sp,-80
    80004a38:	e486                	sd	ra,72(sp)
    80004a3a:	e0a2                	sd	s0,64(sp)
    80004a3c:	fc26                	sd	s1,56(sp)
    80004a3e:	f84a                	sd	s2,48(sp)
    80004a40:	f44e                	sd	s3,40(sp)
    80004a42:	f052                	sd	s4,32(sp)
    80004a44:	ec56                	sd	s5,24(sp)
    80004a46:	e85a                	sd	s6,16(sp)
    80004a48:	0880                	addi	s0,sp,80
    80004a4a:	84aa                	mv	s1,a0
    80004a4c:	892e                	mv	s2,a1
    80004a4e:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80004a50:	ffffd097          	auipc	ra,0xffffd
    80004a54:	f7a080e7          	jalr	-134(ra) # 800019ca <myproc>
    80004a58:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80004a5a:	8526                	mv	a0,s1
    80004a5c:	ffffc097          	auipc	ra,0xffffc
    80004a60:	176080e7          	jalr	374(ra) # 80000bd2 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004a64:	2184a703          	lw	a4,536(s1)
    80004a68:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004a6c:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004a70:	02f71763          	bne	a4,a5,80004a9e <piperead+0x68>
    80004a74:	2244a783          	lw	a5,548(s1)
    80004a78:	c39d                	beqz	a5,80004a9e <piperead+0x68>
    if(killed(pr)){
    80004a7a:	8552                	mv	a0,s4
    80004a7c:	ffffe097          	auipc	ra,0xffffe
    80004a80:	8a6080e7          	jalr	-1882(ra) # 80002322 <killed>
    80004a84:	e949                	bnez	a0,80004b16 <piperead+0xe0>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004a86:	85a6                	mv	a1,s1
    80004a88:	854e                	mv	a0,s3
    80004a8a:	ffffd097          	auipc	ra,0xffffd
    80004a8e:	5f0080e7          	jalr	1520(ra) # 8000207a <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004a92:	2184a703          	lw	a4,536(s1)
    80004a96:	21c4a783          	lw	a5,540(s1)
    80004a9a:	fcf70de3          	beq	a4,a5,80004a74 <piperead+0x3e>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004a9e:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004aa0:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004aa2:	05505463          	blez	s5,80004aea <piperead+0xb4>
    if(pi->nread == pi->nwrite)
    80004aa6:	2184a783          	lw	a5,536(s1)
    80004aaa:	21c4a703          	lw	a4,540(s1)
    80004aae:	02f70e63          	beq	a4,a5,80004aea <piperead+0xb4>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80004ab2:	0017871b          	addiw	a4,a5,1
    80004ab6:	20e4ac23          	sw	a4,536(s1)
    80004aba:	1ff7f793          	andi	a5,a5,511
    80004abe:	97a6                	add	a5,a5,s1
    80004ac0:	0187c783          	lbu	a5,24(a5)
    80004ac4:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004ac8:	4685                	li	a3,1
    80004aca:	fbf40613          	addi	a2,s0,-65
    80004ace:	85ca                	mv	a1,s2
    80004ad0:	050a3503          	ld	a0,80(s4)
    80004ad4:	ffffd097          	auipc	ra,0xffffd
    80004ad8:	bb6080e7          	jalr	-1098(ra) # 8000168a <copyout>
    80004adc:	01650763          	beq	a0,s6,80004aea <piperead+0xb4>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004ae0:	2985                	addiw	s3,s3,1
    80004ae2:	0905                	addi	s2,s2,1
    80004ae4:	fd3a91e3          	bne	s5,s3,80004aa6 <piperead+0x70>
    80004ae8:	89d6                	mv	s3,s5
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80004aea:	21c48513          	addi	a0,s1,540
    80004aee:	ffffd097          	auipc	ra,0xffffd
    80004af2:	5f0080e7          	jalr	1520(ra) # 800020de <wakeup>
  release(&pi->lock);
    80004af6:	8526                	mv	a0,s1
    80004af8:	ffffc097          	auipc	ra,0xffffc
    80004afc:	18e080e7          	jalr	398(ra) # 80000c86 <release>
  return i;
}
    80004b00:	854e                	mv	a0,s3
    80004b02:	60a6                	ld	ra,72(sp)
    80004b04:	6406                	ld	s0,64(sp)
    80004b06:	74e2                	ld	s1,56(sp)
    80004b08:	7942                	ld	s2,48(sp)
    80004b0a:	79a2                	ld	s3,40(sp)
    80004b0c:	7a02                	ld	s4,32(sp)
    80004b0e:	6ae2                	ld	s5,24(sp)
    80004b10:	6b42                	ld	s6,16(sp)
    80004b12:	6161                	addi	sp,sp,80
    80004b14:	8082                	ret
      release(&pi->lock);
    80004b16:	8526                	mv	a0,s1
    80004b18:	ffffc097          	auipc	ra,0xffffc
    80004b1c:	16e080e7          	jalr	366(ra) # 80000c86 <release>
      return -1;
    80004b20:	59fd                	li	s3,-1
    80004b22:	bff9                	j	80004b00 <piperead+0xca>

0000000080004b24 <flags2perm>:

// static 
int loadseg(pde_t *, uint64, struct inode *, uint, uint);

int flags2perm(int flags)
{
    80004b24:	1141                	addi	sp,sp,-16
    80004b26:	e422                	sd	s0,8(sp)
    80004b28:	0800                	addi	s0,sp,16
    80004b2a:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    80004b2c:	8905                	andi	a0,a0,1
    80004b2e:	050e                	slli	a0,a0,0x3
      perm = PTE_X;
    if(flags & 0x2)
    80004b30:	8b89                	andi	a5,a5,2
    80004b32:	c399                	beqz	a5,80004b38 <flags2perm+0x14>
      perm |= PTE_W;
    80004b34:	00456513          	ori	a0,a0,4
    return perm;
}
    80004b38:	6422                	ld	s0,8(sp)
    80004b3a:	0141                	addi	sp,sp,16
    80004b3c:	8082                	ret

0000000080004b3e <loadseg>:
loadseg(pagetable_t pagetable, uint64 va, struct inode *ip, uint offset, uint sz)
{
  uint i, n;
  uint64 pa;

  for(i = 0; i < sz; i += PGSIZE){
    80004b3e:	c749                	beqz	a4,80004bc8 <loadseg+0x8a>
{
    80004b40:	711d                	addi	sp,sp,-96
    80004b42:	ec86                	sd	ra,88(sp)
    80004b44:	e8a2                	sd	s0,80(sp)
    80004b46:	e4a6                	sd	s1,72(sp)
    80004b48:	e0ca                	sd	s2,64(sp)
    80004b4a:	fc4e                	sd	s3,56(sp)
    80004b4c:	f852                	sd	s4,48(sp)
    80004b4e:	f456                	sd	s5,40(sp)
    80004b50:	f05a                	sd	s6,32(sp)
    80004b52:	ec5e                	sd	s7,24(sp)
    80004b54:	e862                	sd	s8,16(sp)
    80004b56:	e466                	sd	s9,8(sp)
    80004b58:	1080                	addi	s0,sp,96
    80004b5a:	8aaa                	mv	s5,a0
    80004b5c:	8b2e                	mv	s6,a1
    80004b5e:	8bb2                	mv	s7,a2
    80004b60:	8c36                	mv	s8,a3
    80004b62:	89ba                	mv	s3,a4
  for(i = 0; i < sz; i += PGSIZE){
    80004b64:	4901                	li	s2,0
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    if(sz - i < PGSIZE)
    80004b66:	6c85                	lui	s9,0x1
    80004b68:	6a05                	lui	s4,0x1
    80004b6a:	a815                	j	80004b9e <loadseg+0x60>
      panic("loadseg: address should exist");
    80004b6c:	00004517          	auipc	a0,0x4
    80004b70:	b6450513          	addi	a0,a0,-1180 # 800086d0 <syscalls+0x288>
    80004b74:	ffffc097          	auipc	ra,0xffffc
    80004b78:	9c8080e7          	jalr	-1592(ra) # 8000053c <panic>
    if(sz - i < PGSIZE)
    80004b7c:	2481                	sext.w	s1,s1
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80004b7e:	8726                	mv	a4,s1
    80004b80:	012c06bb          	addw	a3,s8,s2
    80004b84:	4581                	li	a1,0
    80004b86:	855e                	mv	a0,s7
    80004b88:	fffff097          	auipc	ra,0xfffff
    80004b8c:	d8a080e7          	jalr	-630(ra) # 80003912 <readi>
    80004b90:	2501                	sext.w	a0,a0
    80004b92:	02951d63          	bne	a0,s1,80004bcc <loadseg+0x8e>
  for(i = 0; i < sz; i += PGSIZE){
    80004b96:	012a093b          	addw	s2,s4,s2
    80004b9a:	03397563          	bgeu	s2,s3,80004bc4 <loadseg+0x86>
    pa = walkaddr(pagetable, va + i);
    80004b9e:	02091593          	slli	a1,s2,0x20
    80004ba2:	9181                	srli	a1,a1,0x20
    80004ba4:	95da                	add	a1,a1,s6
    80004ba6:	8556                	mv	a0,s5
    80004ba8:	ffffc097          	auipc	ra,0xffffc
    80004bac:	4ae080e7          	jalr	1198(ra) # 80001056 <walkaddr>
    80004bb0:	862a                	mv	a2,a0
    if(pa == 0)
    80004bb2:	dd4d                	beqz	a0,80004b6c <loadseg+0x2e>
    if(sz - i < PGSIZE)
    80004bb4:	412984bb          	subw	s1,s3,s2
    80004bb8:	0004879b          	sext.w	a5,s1
    80004bbc:	fcfcf0e3          	bgeu	s9,a5,80004b7c <loadseg+0x3e>
    80004bc0:	84d2                	mv	s1,s4
    80004bc2:	bf6d                	j	80004b7c <loadseg+0x3e>
      return -1;
  }
  
  return 0;
    80004bc4:	4501                	li	a0,0
    80004bc6:	a021                	j	80004bce <loadseg+0x90>
    80004bc8:	4501                	li	a0,0
}
    80004bca:	8082                	ret
      return -1;
    80004bcc:	557d                	li	a0,-1
}
    80004bce:	60e6                	ld	ra,88(sp)
    80004bd0:	6446                	ld	s0,80(sp)
    80004bd2:	64a6                	ld	s1,72(sp)
    80004bd4:	6906                	ld	s2,64(sp)
    80004bd6:	79e2                	ld	s3,56(sp)
    80004bd8:	7a42                	ld	s4,48(sp)
    80004bda:	7aa2                	ld	s5,40(sp)
    80004bdc:	7b02                	ld	s6,32(sp)
    80004bde:	6be2                	ld	s7,24(sp)
    80004be0:	6c42                	ld	s8,16(sp)
    80004be2:	6ca2                	ld	s9,8(sp)
    80004be4:	6125                	addi	sp,sp,96
    80004be6:	8082                	ret

0000000080004be8 <exec>:
{
    80004be8:	7101                	addi	sp,sp,-512
    80004bea:	ff86                	sd	ra,504(sp)
    80004bec:	fba2                	sd	s0,496(sp)
    80004bee:	f7a6                	sd	s1,488(sp)
    80004bf0:	f3ca                	sd	s2,480(sp)
    80004bf2:	efce                	sd	s3,472(sp)
    80004bf4:	ebd2                	sd	s4,464(sp)
    80004bf6:	e7d6                	sd	s5,456(sp)
    80004bf8:	e3da                	sd	s6,448(sp)
    80004bfa:	ff5e                	sd	s7,440(sp)
    80004bfc:	fb62                	sd	s8,432(sp)
    80004bfe:	f766                	sd	s9,424(sp)
    80004c00:	f36a                	sd	s10,416(sp)
    80004c02:	ef6e                	sd	s11,408(sp)
    80004c04:	0400                	addi	s0,sp,512
    80004c06:	84aa                	mv	s1,a0
    80004c08:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80004c0a:	ffffd097          	auipc	ra,0xffffd
    80004c0e:	dc0080e7          	jalr	-576(ra) # 800019ca <myproc>
    80004c12:	89aa                	mv	s3,a0
  begin_op();
    80004c14:	fffff097          	auipc	ra,0xfffff
    80004c18:	3f0080e7          	jalr	1008(ra) # 80004004 <begin_op>
  if((ip = namei(path)) == 0){
    80004c1c:	8526                	mv	a0,s1
    80004c1e:	fffff097          	auipc	ra,0xfffff
    80004c22:	1e6080e7          	jalr	486(ra) # 80003e04 <namei>
    80004c26:	c53d                	beqz	a0,80004c94 <exec+0xac>
    80004c28:	8b2a                	mv	s6,a0
  ilock(ip);
    80004c2a:	fffff097          	auipc	ra,0xfffff
    80004c2e:	a34080e7          	jalr	-1484(ra) # 8000365e <ilock>
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80004c32:	04000713          	li	a4,64
    80004c36:	4681                	li	a3,0
    80004c38:	e5040613          	addi	a2,s0,-432
    80004c3c:	4581                	li	a1,0
    80004c3e:	855a                	mv	a0,s6
    80004c40:	fffff097          	auipc	ra,0xfffff
    80004c44:	cd2080e7          	jalr	-814(ra) # 80003912 <readi>
    80004c48:	04000793          	li	a5,64
    80004c4c:	00f51a63          	bne	a0,a5,80004c60 <exec+0x78>
  if(elf.magic != ELF_MAGIC)
    80004c50:	e5042703          	lw	a4,-432(s0)
    80004c54:	464c47b7          	lui	a5,0x464c4
    80004c58:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80004c5c:	04f70263          	beq	a4,a5,80004ca0 <exec+0xb8>
    iunlockput(ip);
    80004c60:	855a                	mv	a0,s6
    80004c62:	fffff097          	auipc	ra,0xfffff
    80004c66:	c5e080e7          	jalr	-930(ra) # 800038c0 <iunlockput>
    end_op();
    80004c6a:	fffff097          	auipc	ra,0xfffff
    80004c6e:	414080e7          	jalr	1044(ra) # 8000407e <end_op>
  return -1;
    80004c72:	557d                	li	a0,-1
}
    80004c74:	70fe                	ld	ra,504(sp)
    80004c76:	745e                	ld	s0,496(sp)
    80004c78:	74be                	ld	s1,488(sp)
    80004c7a:	791e                	ld	s2,480(sp)
    80004c7c:	69fe                	ld	s3,472(sp)
    80004c7e:	6a5e                	ld	s4,464(sp)
    80004c80:	6abe                	ld	s5,456(sp)
    80004c82:	6b1e                	ld	s6,448(sp)
    80004c84:	7bfa                	ld	s7,440(sp)
    80004c86:	7c5a                	ld	s8,432(sp)
    80004c88:	7cba                	ld	s9,424(sp)
    80004c8a:	7d1a                	ld	s10,416(sp)
    80004c8c:	6dfa                	ld	s11,408(sp)
    80004c8e:	20010113          	addi	sp,sp,512
    80004c92:	8082                	ret
    end_op();
    80004c94:	fffff097          	auipc	ra,0xfffff
    80004c98:	3ea080e7          	jalr	1002(ra) # 8000407e <end_op>
    return -1;
    80004c9c:	557d                	li	a0,-1
    80004c9e:	bfd9                	j	80004c74 <exec+0x8c>
  if((pagetable = proc_pagetable(p)) == 0)
    80004ca0:	854e                	mv	a0,s3
    80004ca2:	ffffd097          	auipc	ra,0xffffd
    80004ca6:	dec080e7          	jalr	-532(ra) # 80001a8e <proc_pagetable>
    80004caa:	89aa                	mv	s3,a0
    80004cac:	d955                	beqz	a0,80004c60 <exec+0x78>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004cae:	e7042a03          	lw	s4,-400(s0)
    80004cb2:	e8845783          	lhu	a5,-376(s0)
    80004cb6:	c3c5                	beqz	a5,80004d56 <exec+0x16e>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004cb8:	4a81                	li	s5,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004cba:	4c01                	li	s8,0
    if(ph.type != ELF_PROG_LOAD)
    80004cbc:	4c85                	li	s9,1
    if(ph.vaddr % PGSIZE != 0)
    80004cbe:	6d05                	lui	s10,0x1
    80004cc0:	1d7d                	addi	s10,s10,-1 # fff <_entry-0x7ffff001>
    80004cc2:	a801                	j	80004cd2 <exec+0xea>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004cc4:	2c05                	addiw	s8,s8,1
    80004cc6:	038a0a1b          	addiw	s4,s4,56 # 1038 <_entry-0x7fffefc8>
    80004cca:	e8845783          	lhu	a5,-376(s0)
    80004cce:	08fc5563          	bge	s8,a5,80004d58 <exec+0x170>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80004cd2:	2a01                	sext.w	s4,s4
    80004cd4:	03800713          	li	a4,56
    80004cd8:	86d2                	mv	a3,s4
    80004cda:	e1840613          	addi	a2,s0,-488
    80004cde:	4581                	li	a1,0
    80004ce0:	855a                	mv	a0,s6
    80004ce2:	fffff097          	auipc	ra,0xfffff
    80004ce6:	c30080e7          	jalr	-976(ra) # 80003912 <readi>
    80004cea:	03800793          	li	a5,56
    80004cee:	0af51963          	bne	a0,a5,80004da0 <exec+0x1b8>
    if(ph.type != ELF_PROG_LOAD)
    80004cf2:	e1842783          	lw	a5,-488(s0)
    80004cf6:	fd9797e3          	bne	a5,s9,80004cc4 <exec+0xdc>
    if(ph.memsz < ph.filesz)
    80004cfa:	e4043b83          	ld	s7,-448(s0)
    80004cfe:	e3843783          	ld	a5,-456(s0)
    80004d02:	08fbef63          	bltu	s7,a5,80004da0 <exec+0x1b8>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80004d06:	e2843783          	ld	a5,-472(s0)
    80004d0a:	9bbe                	add	s7,s7,a5
    80004d0c:	08fbea63          	bltu	s7,a5,80004da0 <exec+0x1b8>
    if(ph.vaddr % PGSIZE != 0)
    80004d10:	01a7f7b3          	and	a5,a5,s10
    80004d14:	e7d1                	bnez	a5,80004da0 <exec+0x1b8>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80004d16:	e1c42503          	lw	a0,-484(s0)
    80004d1a:	00000097          	auipc	ra,0x0
    80004d1e:	e0a080e7          	jalr	-502(ra) # 80004b24 <flags2perm>
    80004d22:	86aa                	mv	a3,a0
    80004d24:	865e                	mv	a2,s7
    80004d26:	85d6                	mv	a1,s5
    80004d28:	854e                	mv	a0,s3
    80004d2a:	ffffc097          	auipc	ra,0xffffc
    80004d2e:	6d2080e7          	jalr	1746(ra) # 800013fc <uvmalloc>
    80004d32:	8baa                	mv	s7,a0
    80004d34:	c535                	beqz	a0,80004da0 <exec+0x1b8>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80004d36:	e3842703          	lw	a4,-456(s0)
    80004d3a:	e2042683          	lw	a3,-480(s0)
    80004d3e:	865a                	mv	a2,s6
    80004d40:	e2843583          	ld	a1,-472(s0)
    80004d44:	854e                	mv	a0,s3
    80004d46:	00000097          	auipc	ra,0x0
    80004d4a:	df8080e7          	jalr	-520(ra) # 80004b3e <loadseg>
    80004d4e:	16054f63          	bltz	a0,80004ecc <exec+0x2e4>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80004d52:	8ade                	mv	s5,s7
    80004d54:	bf85                	j	80004cc4 <exec+0xdc>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004d56:	4a81                	li	s5,0
  iunlockput(ip);
    80004d58:	855a                	mv	a0,s6
    80004d5a:	fffff097          	auipc	ra,0xfffff
    80004d5e:	b66080e7          	jalr	-1178(ra) # 800038c0 <iunlockput>
  end_op();
    80004d62:	fffff097          	auipc	ra,0xfffff
    80004d66:	31c080e7          	jalr	796(ra) # 8000407e <end_op>
  p = myproc();
    80004d6a:	ffffd097          	auipc	ra,0xffffd
    80004d6e:	c60080e7          	jalr	-928(ra) # 800019ca <myproc>
    80004d72:	8d2a                	mv	s10,a0
  uint64 oldsz = p->sz;
    80004d74:	653c                	ld	a5,72(a0)
    80004d76:	e0f43423          	sd	a5,-504(s0)
  sz = PGROUNDUP(sz);
    80004d7a:	6b05                	lui	s6,0x1
    80004d7c:	1b7d                	addi	s6,s6,-1 # fff <_entry-0x7ffff001>
    80004d7e:	9b56                	add	s6,s6,s5
    80004d80:	77fd                	lui	a5,0xfffff
    80004d82:	00fb7b33          	and	s6,s6,a5
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE, PTE_W)) == 0)
    80004d86:	4691                	li	a3,4
    80004d88:	6609                	lui	a2,0x2
    80004d8a:	965a                	add	a2,a2,s6
    80004d8c:	85da                	mv	a1,s6
    80004d8e:	854e                	mv	a0,s3
    80004d90:	ffffc097          	auipc	ra,0xffffc
    80004d94:	66c080e7          	jalr	1644(ra) # 800013fc <uvmalloc>
    80004d98:	8aaa                	mv	s5,a0
    80004d9a:	ed09                	bnez	a0,80004db4 <exec+0x1cc>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80004d9c:	8ada                	mv	s5,s6
    80004d9e:	4b01                	li	s6,0
    proc_freepagetable(pagetable, sz);
    80004da0:	85d6                	mv	a1,s5
    80004da2:	854e                	mv	a0,s3
    80004da4:	ffffd097          	auipc	ra,0xffffd
    80004da8:	d86080e7          	jalr	-634(ra) # 80001b2a <proc_freepagetable>
  return -1;
    80004dac:	557d                	li	a0,-1
  if(ip){
    80004dae:	ec0b03e3          	beqz	s6,80004c74 <exec+0x8c>
    80004db2:	b57d                	j	80004c60 <exec+0x78>
  uvmclear(pagetable, sz-2*PGSIZE);
    80004db4:	75f9                	lui	a1,0xffffe
    80004db6:	95aa                	add	a1,a1,a0
    80004db8:	854e                	mv	a0,s3
    80004dba:	ffffd097          	auipc	ra,0xffffd
    80004dbe:	86c080e7          	jalr	-1940(ra) # 80001626 <uvmclear>
  stackbase = sp - PGSIZE;
    80004dc2:	7cfd                	lui	s9,0xfffff
    80004dc4:	9cd6                	add	s9,s9,s5
  for(argc = 0; argv[argc]; argc++) {
    80004dc6:	00093503          	ld	a0,0(s2)
    80004dca:	c125                	beqz	a0,80004e2a <exec+0x242>
    80004dcc:	e9040b93          	addi	s7,s0,-368
    80004dd0:	f9040d93          	addi	s11,s0,-112
  sp = sz;
    80004dd4:	8b56                	mv	s6,s5
  for(argc = 0; argv[argc]; argc++) {
    80004dd6:	4a01                	li	s4,0
    sp -= strlen(argv[argc]) + 1;
    80004dd8:	ffffc097          	auipc	ra,0xffffc
    80004ddc:	070080e7          	jalr	112(ra) # 80000e48 <strlen>
    80004de0:	2505                	addiw	a0,a0,1
    80004de2:	40ab0533          	sub	a0,s6,a0
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80004de6:	ff057b13          	andi	s6,a0,-16
    if(sp < stackbase)
    80004dea:	0f9b6363          	bltu	s6,s9,80004ed0 <exec+0x2e8>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80004dee:	00093c03          	ld	s8,0(s2)
    80004df2:	8562                	mv	a0,s8
    80004df4:	ffffc097          	auipc	ra,0xffffc
    80004df8:	054080e7          	jalr	84(ra) # 80000e48 <strlen>
    80004dfc:	0015069b          	addiw	a3,a0,1
    80004e00:	8662                	mv	a2,s8
    80004e02:	85da                	mv	a1,s6
    80004e04:	854e                	mv	a0,s3
    80004e06:	ffffd097          	auipc	ra,0xffffd
    80004e0a:	884080e7          	jalr	-1916(ra) # 8000168a <copyout>
    80004e0e:	0c054363          	bltz	a0,80004ed4 <exec+0x2ec>
    ustack[argc] = sp;
    80004e12:	016bb023          	sd	s6,0(s7)
  for(argc = 0; argv[argc]; argc++) {
    80004e16:	0a05                	addi	s4,s4,1
    80004e18:	0921                	addi	s2,s2,8
    80004e1a:	00093503          	ld	a0,0(s2)
    80004e1e:	c901                	beqz	a0,80004e2e <exec+0x246>
    if(argc >= MAXARG)
    80004e20:	0ba1                	addi	s7,s7,8
    80004e22:	fbbb9be3          	bne	s7,s11,80004dd8 <exec+0x1f0>
  ip = 0;
    80004e26:	4b01                	li	s6,0
    80004e28:	bfa5                	j	80004da0 <exec+0x1b8>
  sp = sz;
    80004e2a:	8b56                	mv	s6,s5
  for(argc = 0; argv[argc]; argc++) {
    80004e2c:	4a01                	li	s4,0
  ustack[argc] = 0;
    80004e2e:	003a1793          	slli	a5,s4,0x3
    80004e32:	f9078793          	addi	a5,a5,-112 # ffffffffffffef90 <end+0xffffffff7ffdd098>
    80004e36:	97a2                	add	a5,a5,s0
    80004e38:	f007b023          	sd	zero,-256(a5)
  sp -= (argc+1) * sizeof(uint64);
    80004e3c:	001a0693          	addi	a3,s4,1
    80004e40:	068e                	slli	a3,a3,0x3
    80004e42:	40db0933          	sub	s2,s6,a3
  sp -= sp % 16;
    80004e46:	ff097913          	andi	s2,s2,-16
  sz = sz1;
    80004e4a:	8b56                	mv	s6,s5
  if(sp < stackbase)
    80004e4c:	f59968e3          	bltu	s2,s9,80004d9c <exec+0x1b4>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80004e50:	e9040613          	addi	a2,s0,-368
    80004e54:	85ca                	mv	a1,s2
    80004e56:	854e                	mv	a0,s3
    80004e58:	ffffd097          	auipc	ra,0xffffd
    80004e5c:	832080e7          	jalr	-1998(ra) # 8000168a <copyout>
    80004e60:	f2054ee3          	bltz	a0,80004d9c <exec+0x1b4>
  p->trapframe->a1 = sp;
    80004e64:	058d3783          	ld	a5,88(s10)
    80004e68:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80004e6c:	0004c703          	lbu	a4,0(s1)
    80004e70:	cf11                	beqz	a4,80004e8c <exec+0x2a4>
    80004e72:	00148793          	addi	a5,s1,1
    if(*s == '/')
    80004e76:	02f00693          	li	a3,47
    80004e7a:	a029                	j	80004e84 <exec+0x29c>
  for(last=s=path; *s; s++)
    80004e7c:	0785                	addi	a5,a5,1
    80004e7e:	fff7c703          	lbu	a4,-1(a5)
    80004e82:	c709                	beqz	a4,80004e8c <exec+0x2a4>
    if(*s == '/')
    80004e84:	fed71ce3          	bne	a4,a3,80004e7c <exec+0x294>
      last = s+1;
    80004e88:	84be                	mv	s1,a5
    80004e8a:	bfcd                	j	80004e7c <exec+0x294>
  safestrcpy(p->name, last, sizeof(p->name));
    80004e8c:	4641                	li	a2,16
    80004e8e:	85a6                	mv	a1,s1
    80004e90:	158d0513          	addi	a0,s10,344
    80004e94:	ffffc097          	auipc	ra,0xffffc
    80004e98:	f82080e7          	jalr	-126(ra) # 80000e16 <safestrcpy>
  oldpagetable = p->pagetable;
    80004e9c:	050d3503          	ld	a0,80(s10)
  p->pagetable = pagetable;
    80004ea0:	053d3823          	sd	s3,80(s10)
  p->sz = sz;
    80004ea4:	055d3423          	sd	s5,72(s10)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    80004ea8:	058d3783          	ld	a5,88(s10)
    80004eac:	e6843703          	ld	a4,-408(s0)
    80004eb0:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    80004eb2:	058d3783          	ld	a5,88(s10)
    80004eb6:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80004eba:	e0843583          	ld	a1,-504(s0)
    80004ebe:	ffffd097          	auipc	ra,0xffffd
    80004ec2:	c6c080e7          	jalr	-916(ra) # 80001b2a <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80004ec6:	000a051b          	sext.w	a0,s4
    80004eca:	b36d                	j	80004c74 <exec+0x8c>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80004ecc:	8ade                	mv	s5,s7
    80004ece:	bdc9                	j	80004da0 <exec+0x1b8>
  ip = 0;
    80004ed0:	4b01                	li	s6,0
    80004ed2:	b5f9                	j	80004da0 <exec+0x1b8>
    80004ed4:	4b01                	li	s6,0
  if(pagetable)
    80004ed6:	b5e9                	j	80004da0 <exec+0x1b8>

0000000080004ed8 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80004ed8:	7179                	addi	sp,sp,-48
    80004eda:	f406                	sd	ra,40(sp)
    80004edc:	f022                	sd	s0,32(sp)
    80004ede:	ec26                	sd	s1,24(sp)
    80004ee0:	e84a                	sd	s2,16(sp)
    80004ee2:	1800                	addi	s0,sp,48
    80004ee4:	892e                	mv	s2,a1
    80004ee6:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    80004ee8:	fdc40593          	addi	a1,s0,-36
    80004eec:	ffffe097          	auipc	ra,0xffffe
    80004ef0:	c00080e7          	jalr	-1024(ra) # 80002aec <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80004ef4:	fdc42703          	lw	a4,-36(s0)
    80004ef8:	47bd                	li	a5,15
    80004efa:	02e7eb63          	bltu	a5,a4,80004f30 <argfd+0x58>
    80004efe:	ffffd097          	auipc	ra,0xffffd
    80004f02:	acc080e7          	jalr	-1332(ra) # 800019ca <myproc>
    80004f06:	fdc42703          	lw	a4,-36(s0)
    80004f0a:	01a70793          	addi	a5,a4,26
    80004f0e:	078e                	slli	a5,a5,0x3
    80004f10:	953e                	add	a0,a0,a5
    80004f12:	611c                	ld	a5,0(a0)
    80004f14:	c385                	beqz	a5,80004f34 <argfd+0x5c>
    return -1;
  if(pfd)
    80004f16:	00090463          	beqz	s2,80004f1e <argfd+0x46>
    *pfd = fd;
    80004f1a:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80004f1e:	4501                	li	a0,0
  if(pf)
    80004f20:	c091                	beqz	s1,80004f24 <argfd+0x4c>
    *pf = f;
    80004f22:	e09c                	sd	a5,0(s1)
}
    80004f24:	70a2                	ld	ra,40(sp)
    80004f26:	7402                	ld	s0,32(sp)
    80004f28:	64e2                	ld	s1,24(sp)
    80004f2a:	6942                	ld	s2,16(sp)
    80004f2c:	6145                	addi	sp,sp,48
    80004f2e:	8082                	ret
    return -1;
    80004f30:	557d                	li	a0,-1
    80004f32:	bfcd                	j	80004f24 <argfd+0x4c>
    80004f34:	557d                	li	a0,-1
    80004f36:	b7fd                	j	80004f24 <argfd+0x4c>

0000000080004f38 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80004f38:	1101                	addi	sp,sp,-32
    80004f3a:	ec06                	sd	ra,24(sp)
    80004f3c:	e822                	sd	s0,16(sp)
    80004f3e:	e426                	sd	s1,8(sp)
    80004f40:	1000                	addi	s0,sp,32
    80004f42:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80004f44:	ffffd097          	auipc	ra,0xffffd
    80004f48:	a86080e7          	jalr	-1402(ra) # 800019ca <myproc>
    80004f4c:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    80004f4e:	0d050793          	addi	a5,a0,208
    80004f52:	4501                	li	a0,0
    80004f54:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    80004f56:	6398                	ld	a4,0(a5)
    80004f58:	cb19                	beqz	a4,80004f6e <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    80004f5a:	2505                	addiw	a0,a0,1
    80004f5c:	07a1                	addi	a5,a5,8
    80004f5e:	fed51ce3          	bne	a0,a3,80004f56 <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80004f62:	557d                	li	a0,-1
}
    80004f64:	60e2                	ld	ra,24(sp)
    80004f66:	6442                	ld	s0,16(sp)
    80004f68:	64a2                	ld	s1,8(sp)
    80004f6a:	6105                	addi	sp,sp,32
    80004f6c:	8082                	ret
      p->ofile[fd] = f;
    80004f6e:	01a50793          	addi	a5,a0,26
    80004f72:	078e                	slli	a5,a5,0x3
    80004f74:	963e                	add	a2,a2,a5
    80004f76:	e204                	sd	s1,0(a2)
      return fd;
    80004f78:	b7f5                	j	80004f64 <fdalloc+0x2c>

0000000080004f7a <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    80004f7a:	715d                	addi	sp,sp,-80
    80004f7c:	e486                	sd	ra,72(sp)
    80004f7e:	e0a2                	sd	s0,64(sp)
    80004f80:	fc26                	sd	s1,56(sp)
    80004f82:	f84a                	sd	s2,48(sp)
    80004f84:	f44e                	sd	s3,40(sp)
    80004f86:	f052                	sd	s4,32(sp)
    80004f88:	ec56                	sd	s5,24(sp)
    80004f8a:	e85a                	sd	s6,16(sp)
    80004f8c:	0880                	addi	s0,sp,80
    80004f8e:	8b2e                	mv	s6,a1
    80004f90:	89b2                	mv	s3,a2
    80004f92:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80004f94:	fb040593          	addi	a1,s0,-80
    80004f98:	fffff097          	auipc	ra,0xfffff
    80004f9c:	e8a080e7          	jalr	-374(ra) # 80003e22 <nameiparent>
    80004fa0:	84aa                	mv	s1,a0
    80004fa2:	14050b63          	beqz	a0,800050f8 <create+0x17e>
    return 0;

  ilock(dp);
    80004fa6:	ffffe097          	auipc	ra,0xffffe
    80004faa:	6b8080e7          	jalr	1720(ra) # 8000365e <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    80004fae:	4601                	li	a2,0
    80004fb0:	fb040593          	addi	a1,s0,-80
    80004fb4:	8526                	mv	a0,s1
    80004fb6:	fffff097          	auipc	ra,0xfffff
    80004fba:	b8c080e7          	jalr	-1140(ra) # 80003b42 <dirlookup>
    80004fbe:	8aaa                	mv	s5,a0
    80004fc0:	c921                	beqz	a0,80005010 <create+0x96>
    iunlockput(dp);
    80004fc2:	8526                	mv	a0,s1
    80004fc4:	fffff097          	auipc	ra,0xfffff
    80004fc8:	8fc080e7          	jalr	-1796(ra) # 800038c0 <iunlockput>
    ilock(ip);
    80004fcc:	8556                	mv	a0,s5
    80004fce:	ffffe097          	auipc	ra,0xffffe
    80004fd2:	690080e7          	jalr	1680(ra) # 8000365e <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80004fd6:	4789                	li	a5,2
    80004fd8:	02fb1563          	bne	s6,a5,80005002 <create+0x88>
    80004fdc:	044ad783          	lhu	a5,68(s5)
    80004fe0:	37f9                	addiw	a5,a5,-2
    80004fe2:	17c2                	slli	a5,a5,0x30
    80004fe4:	93c1                	srli	a5,a5,0x30
    80004fe6:	4705                	li	a4,1
    80004fe8:	00f76d63          	bltu	a4,a5,80005002 <create+0x88>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    80004fec:	8556                	mv	a0,s5
    80004fee:	60a6                	ld	ra,72(sp)
    80004ff0:	6406                	ld	s0,64(sp)
    80004ff2:	74e2                	ld	s1,56(sp)
    80004ff4:	7942                	ld	s2,48(sp)
    80004ff6:	79a2                	ld	s3,40(sp)
    80004ff8:	7a02                	ld	s4,32(sp)
    80004ffa:	6ae2                	ld	s5,24(sp)
    80004ffc:	6b42                	ld	s6,16(sp)
    80004ffe:	6161                	addi	sp,sp,80
    80005000:	8082                	ret
    iunlockput(ip);
    80005002:	8556                	mv	a0,s5
    80005004:	fffff097          	auipc	ra,0xfffff
    80005008:	8bc080e7          	jalr	-1860(ra) # 800038c0 <iunlockput>
    return 0;
    8000500c:	4a81                	li	s5,0
    8000500e:	bff9                	j	80004fec <create+0x72>
  if((ip = ialloc(dp->dev, type)) == 0){
    80005010:	85da                	mv	a1,s6
    80005012:	4088                	lw	a0,0(s1)
    80005014:	ffffe097          	auipc	ra,0xffffe
    80005018:	4b2080e7          	jalr	1202(ra) # 800034c6 <ialloc>
    8000501c:	8a2a                	mv	s4,a0
    8000501e:	c529                	beqz	a0,80005068 <create+0xee>
  ilock(ip);
    80005020:	ffffe097          	auipc	ra,0xffffe
    80005024:	63e080e7          	jalr	1598(ra) # 8000365e <ilock>
  ip->major = major;
    80005028:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    8000502c:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    80005030:	4905                	li	s2,1
    80005032:	052a1523          	sh	s2,74(s4)
  iupdate(ip);
    80005036:	8552                	mv	a0,s4
    80005038:	ffffe097          	auipc	ra,0xffffe
    8000503c:	55a080e7          	jalr	1370(ra) # 80003592 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    80005040:	032b0b63          	beq	s6,s2,80005076 <create+0xfc>
  if(dirlink(dp, name, ip->inum) < 0)
    80005044:	004a2603          	lw	a2,4(s4)
    80005048:	fb040593          	addi	a1,s0,-80
    8000504c:	8526                	mv	a0,s1
    8000504e:	fffff097          	auipc	ra,0xfffff
    80005052:	d04080e7          	jalr	-764(ra) # 80003d52 <dirlink>
    80005056:	06054f63          	bltz	a0,800050d4 <create+0x15a>
  iunlockput(dp);
    8000505a:	8526                	mv	a0,s1
    8000505c:	fffff097          	auipc	ra,0xfffff
    80005060:	864080e7          	jalr	-1948(ra) # 800038c0 <iunlockput>
  return ip;
    80005064:	8ad2                	mv	s5,s4
    80005066:	b759                	j	80004fec <create+0x72>
    iunlockput(dp);
    80005068:	8526                	mv	a0,s1
    8000506a:	fffff097          	auipc	ra,0xfffff
    8000506e:	856080e7          	jalr	-1962(ra) # 800038c0 <iunlockput>
    return 0;
    80005072:	8ad2                	mv	s5,s4
    80005074:	bfa5                	j	80004fec <create+0x72>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80005076:	004a2603          	lw	a2,4(s4)
    8000507a:	00003597          	auipc	a1,0x3
    8000507e:	67658593          	addi	a1,a1,1654 # 800086f0 <syscalls+0x2a8>
    80005082:	8552                	mv	a0,s4
    80005084:	fffff097          	auipc	ra,0xfffff
    80005088:	cce080e7          	jalr	-818(ra) # 80003d52 <dirlink>
    8000508c:	04054463          	bltz	a0,800050d4 <create+0x15a>
    80005090:	40d0                	lw	a2,4(s1)
    80005092:	00003597          	auipc	a1,0x3
    80005096:	66658593          	addi	a1,a1,1638 # 800086f8 <syscalls+0x2b0>
    8000509a:	8552                	mv	a0,s4
    8000509c:	fffff097          	auipc	ra,0xfffff
    800050a0:	cb6080e7          	jalr	-842(ra) # 80003d52 <dirlink>
    800050a4:	02054863          	bltz	a0,800050d4 <create+0x15a>
  if(dirlink(dp, name, ip->inum) < 0)
    800050a8:	004a2603          	lw	a2,4(s4)
    800050ac:	fb040593          	addi	a1,s0,-80
    800050b0:	8526                	mv	a0,s1
    800050b2:	fffff097          	auipc	ra,0xfffff
    800050b6:	ca0080e7          	jalr	-864(ra) # 80003d52 <dirlink>
    800050ba:	00054d63          	bltz	a0,800050d4 <create+0x15a>
    dp->nlink++;  // for ".."
    800050be:	04a4d783          	lhu	a5,74(s1)
    800050c2:	2785                	addiw	a5,a5,1
    800050c4:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    800050c8:	8526                	mv	a0,s1
    800050ca:	ffffe097          	auipc	ra,0xffffe
    800050ce:	4c8080e7          	jalr	1224(ra) # 80003592 <iupdate>
    800050d2:	b761                	j	8000505a <create+0xe0>
  ip->nlink = 0;
    800050d4:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    800050d8:	8552                	mv	a0,s4
    800050da:	ffffe097          	auipc	ra,0xffffe
    800050de:	4b8080e7          	jalr	1208(ra) # 80003592 <iupdate>
  iunlockput(ip);
    800050e2:	8552                	mv	a0,s4
    800050e4:	ffffe097          	auipc	ra,0xffffe
    800050e8:	7dc080e7          	jalr	2012(ra) # 800038c0 <iunlockput>
  iunlockput(dp);
    800050ec:	8526                	mv	a0,s1
    800050ee:	ffffe097          	auipc	ra,0xffffe
    800050f2:	7d2080e7          	jalr	2002(ra) # 800038c0 <iunlockput>
  return 0;
    800050f6:	bddd                	j	80004fec <create+0x72>
    return 0;
    800050f8:	8aaa                	mv	s5,a0
    800050fa:	bdcd                	j	80004fec <create+0x72>

00000000800050fc <sys_dup>:
{
    800050fc:	7179                	addi	sp,sp,-48
    800050fe:	f406                	sd	ra,40(sp)
    80005100:	f022                	sd	s0,32(sp)
    80005102:	ec26                	sd	s1,24(sp)
    80005104:	e84a                	sd	s2,16(sp)
    80005106:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    80005108:	fd840613          	addi	a2,s0,-40
    8000510c:	4581                	li	a1,0
    8000510e:	4501                	li	a0,0
    80005110:	00000097          	auipc	ra,0x0
    80005114:	dc8080e7          	jalr	-568(ra) # 80004ed8 <argfd>
    return -1;
    80005118:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    8000511a:	02054363          	bltz	a0,80005140 <sys_dup+0x44>
  if((fd=fdalloc(f)) < 0)
    8000511e:	fd843903          	ld	s2,-40(s0)
    80005122:	854a                	mv	a0,s2
    80005124:	00000097          	auipc	ra,0x0
    80005128:	e14080e7          	jalr	-492(ra) # 80004f38 <fdalloc>
    8000512c:	84aa                	mv	s1,a0
    return -1;
    8000512e:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    80005130:	00054863          	bltz	a0,80005140 <sys_dup+0x44>
  filedup(f);
    80005134:	854a                	mv	a0,s2
    80005136:	fffff097          	auipc	ra,0xfffff
    8000513a:	340080e7          	jalr	832(ra) # 80004476 <filedup>
  return fd;
    8000513e:	87a6                	mv	a5,s1
}
    80005140:	853e                	mv	a0,a5
    80005142:	70a2                	ld	ra,40(sp)
    80005144:	7402                	ld	s0,32(sp)
    80005146:	64e2                	ld	s1,24(sp)
    80005148:	6942                	ld	s2,16(sp)
    8000514a:	6145                	addi	sp,sp,48
    8000514c:	8082                	ret

000000008000514e <sys_read>:
{
    8000514e:	7179                	addi	sp,sp,-48
    80005150:	f406                	sd	ra,40(sp)
    80005152:	f022                	sd	s0,32(sp)
    80005154:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80005156:	fd840593          	addi	a1,s0,-40
    8000515a:	4505                	li	a0,1
    8000515c:	ffffe097          	auipc	ra,0xffffe
    80005160:	9b0080e7          	jalr	-1616(ra) # 80002b0c <argaddr>
  argint(2, &n);
    80005164:	fe440593          	addi	a1,s0,-28
    80005168:	4509                	li	a0,2
    8000516a:	ffffe097          	auipc	ra,0xffffe
    8000516e:	982080e7          	jalr	-1662(ra) # 80002aec <argint>
  if(argfd(0, 0, &f) < 0)
    80005172:	fe840613          	addi	a2,s0,-24
    80005176:	4581                	li	a1,0
    80005178:	4501                	li	a0,0
    8000517a:	00000097          	auipc	ra,0x0
    8000517e:	d5e080e7          	jalr	-674(ra) # 80004ed8 <argfd>
    80005182:	87aa                	mv	a5,a0
    return -1;
    80005184:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005186:	0007cc63          	bltz	a5,8000519e <sys_read+0x50>
  return fileread(f, p, n);
    8000518a:	fe442603          	lw	a2,-28(s0)
    8000518e:	fd843583          	ld	a1,-40(s0)
    80005192:	fe843503          	ld	a0,-24(s0)
    80005196:	fffff097          	auipc	ra,0xfffff
    8000519a:	46c080e7          	jalr	1132(ra) # 80004602 <fileread>
}
    8000519e:	70a2                	ld	ra,40(sp)
    800051a0:	7402                	ld	s0,32(sp)
    800051a2:	6145                	addi	sp,sp,48
    800051a4:	8082                	ret

00000000800051a6 <sys_write>:
{
    800051a6:	7179                	addi	sp,sp,-48
    800051a8:	f406                	sd	ra,40(sp)
    800051aa:	f022                	sd	s0,32(sp)
    800051ac:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    800051ae:	fd840593          	addi	a1,s0,-40
    800051b2:	4505                	li	a0,1
    800051b4:	ffffe097          	auipc	ra,0xffffe
    800051b8:	958080e7          	jalr	-1704(ra) # 80002b0c <argaddr>
  argint(2, &n);
    800051bc:	fe440593          	addi	a1,s0,-28
    800051c0:	4509                	li	a0,2
    800051c2:	ffffe097          	auipc	ra,0xffffe
    800051c6:	92a080e7          	jalr	-1750(ra) # 80002aec <argint>
  if(argfd(0, 0, &f) < 0)
    800051ca:	fe840613          	addi	a2,s0,-24
    800051ce:	4581                	li	a1,0
    800051d0:	4501                	li	a0,0
    800051d2:	00000097          	auipc	ra,0x0
    800051d6:	d06080e7          	jalr	-762(ra) # 80004ed8 <argfd>
    800051da:	87aa                	mv	a5,a0
    return -1;
    800051dc:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    800051de:	0007cc63          	bltz	a5,800051f6 <sys_write+0x50>
  return filewrite(f, p, n);
    800051e2:	fe442603          	lw	a2,-28(s0)
    800051e6:	fd843583          	ld	a1,-40(s0)
    800051ea:	fe843503          	ld	a0,-24(s0)
    800051ee:	fffff097          	auipc	ra,0xfffff
    800051f2:	4d6080e7          	jalr	1238(ra) # 800046c4 <filewrite>
}
    800051f6:	70a2                	ld	ra,40(sp)
    800051f8:	7402                	ld	s0,32(sp)
    800051fa:	6145                	addi	sp,sp,48
    800051fc:	8082                	ret

00000000800051fe <sys_close>:
{
    800051fe:	1101                	addi	sp,sp,-32
    80005200:	ec06                	sd	ra,24(sp)
    80005202:	e822                	sd	s0,16(sp)
    80005204:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    80005206:	fe040613          	addi	a2,s0,-32
    8000520a:	fec40593          	addi	a1,s0,-20
    8000520e:	4501                	li	a0,0
    80005210:	00000097          	auipc	ra,0x0
    80005214:	cc8080e7          	jalr	-824(ra) # 80004ed8 <argfd>
    return -1;
    80005218:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    8000521a:	02054463          	bltz	a0,80005242 <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    8000521e:	ffffc097          	auipc	ra,0xffffc
    80005222:	7ac080e7          	jalr	1964(ra) # 800019ca <myproc>
    80005226:	fec42783          	lw	a5,-20(s0)
    8000522a:	07e9                	addi	a5,a5,26
    8000522c:	078e                	slli	a5,a5,0x3
    8000522e:	953e                	add	a0,a0,a5
    80005230:	00053023          	sd	zero,0(a0)
  fileclose(f);
    80005234:	fe043503          	ld	a0,-32(s0)
    80005238:	fffff097          	auipc	ra,0xfffff
    8000523c:	290080e7          	jalr	656(ra) # 800044c8 <fileclose>
  return 0;
    80005240:	4781                	li	a5,0
}
    80005242:	853e                	mv	a0,a5
    80005244:	60e2                	ld	ra,24(sp)
    80005246:	6442                	ld	s0,16(sp)
    80005248:	6105                	addi	sp,sp,32
    8000524a:	8082                	ret

000000008000524c <sys_fstat>:
{
    8000524c:	1101                	addi	sp,sp,-32
    8000524e:	ec06                	sd	ra,24(sp)
    80005250:	e822                	sd	s0,16(sp)
    80005252:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    80005254:	fe040593          	addi	a1,s0,-32
    80005258:	4505                	li	a0,1
    8000525a:	ffffe097          	auipc	ra,0xffffe
    8000525e:	8b2080e7          	jalr	-1870(ra) # 80002b0c <argaddr>
  if(argfd(0, 0, &f) < 0)
    80005262:	fe840613          	addi	a2,s0,-24
    80005266:	4581                	li	a1,0
    80005268:	4501                	li	a0,0
    8000526a:	00000097          	auipc	ra,0x0
    8000526e:	c6e080e7          	jalr	-914(ra) # 80004ed8 <argfd>
    80005272:	87aa                	mv	a5,a0
    return -1;
    80005274:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005276:	0007ca63          	bltz	a5,8000528a <sys_fstat+0x3e>
  return filestat(f, st);
    8000527a:	fe043583          	ld	a1,-32(s0)
    8000527e:	fe843503          	ld	a0,-24(s0)
    80005282:	fffff097          	auipc	ra,0xfffff
    80005286:	30e080e7          	jalr	782(ra) # 80004590 <filestat>
}
    8000528a:	60e2                	ld	ra,24(sp)
    8000528c:	6442                	ld	s0,16(sp)
    8000528e:	6105                	addi	sp,sp,32
    80005290:	8082                	ret

0000000080005292 <sys_link>:
{
    80005292:	7169                	addi	sp,sp,-304
    80005294:	f606                	sd	ra,296(sp)
    80005296:	f222                	sd	s0,288(sp)
    80005298:	ee26                	sd	s1,280(sp)
    8000529a:	ea4a                	sd	s2,272(sp)
    8000529c:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    8000529e:	08000613          	li	a2,128
    800052a2:	ed040593          	addi	a1,s0,-304
    800052a6:	4501                	li	a0,0
    800052a8:	ffffe097          	auipc	ra,0xffffe
    800052ac:	884080e7          	jalr	-1916(ra) # 80002b2c <argstr>
    return -1;
    800052b0:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800052b2:	10054e63          	bltz	a0,800053ce <sys_link+0x13c>
    800052b6:	08000613          	li	a2,128
    800052ba:	f5040593          	addi	a1,s0,-176
    800052be:	4505                	li	a0,1
    800052c0:	ffffe097          	auipc	ra,0xffffe
    800052c4:	86c080e7          	jalr	-1940(ra) # 80002b2c <argstr>
    return -1;
    800052c8:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800052ca:	10054263          	bltz	a0,800053ce <sys_link+0x13c>
  begin_op();
    800052ce:	fffff097          	auipc	ra,0xfffff
    800052d2:	d36080e7          	jalr	-714(ra) # 80004004 <begin_op>
  if((ip = namei(old)) == 0){
    800052d6:	ed040513          	addi	a0,s0,-304
    800052da:	fffff097          	auipc	ra,0xfffff
    800052de:	b2a080e7          	jalr	-1238(ra) # 80003e04 <namei>
    800052e2:	84aa                	mv	s1,a0
    800052e4:	c551                	beqz	a0,80005370 <sys_link+0xde>
  ilock(ip);
    800052e6:	ffffe097          	auipc	ra,0xffffe
    800052ea:	378080e7          	jalr	888(ra) # 8000365e <ilock>
  if(ip->type == T_DIR){
    800052ee:	04449703          	lh	a4,68(s1)
    800052f2:	4785                	li	a5,1
    800052f4:	08f70463          	beq	a4,a5,8000537c <sys_link+0xea>
  ip->nlink++;
    800052f8:	04a4d783          	lhu	a5,74(s1)
    800052fc:	2785                	addiw	a5,a5,1
    800052fe:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005302:	8526                	mv	a0,s1
    80005304:	ffffe097          	auipc	ra,0xffffe
    80005308:	28e080e7          	jalr	654(ra) # 80003592 <iupdate>
  iunlock(ip);
    8000530c:	8526                	mv	a0,s1
    8000530e:	ffffe097          	auipc	ra,0xffffe
    80005312:	412080e7          	jalr	1042(ra) # 80003720 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80005316:	fd040593          	addi	a1,s0,-48
    8000531a:	f5040513          	addi	a0,s0,-176
    8000531e:	fffff097          	auipc	ra,0xfffff
    80005322:	b04080e7          	jalr	-1276(ra) # 80003e22 <nameiparent>
    80005326:	892a                	mv	s2,a0
    80005328:	c935                	beqz	a0,8000539c <sys_link+0x10a>
  ilock(dp);
    8000532a:	ffffe097          	auipc	ra,0xffffe
    8000532e:	334080e7          	jalr	820(ra) # 8000365e <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    80005332:	00092703          	lw	a4,0(s2)
    80005336:	409c                	lw	a5,0(s1)
    80005338:	04f71d63          	bne	a4,a5,80005392 <sys_link+0x100>
    8000533c:	40d0                	lw	a2,4(s1)
    8000533e:	fd040593          	addi	a1,s0,-48
    80005342:	854a                	mv	a0,s2
    80005344:	fffff097          	auipc	ra,0xfffff
    80005348:	a0e080e7          	jalr	-1522(ra) # 80003d52 <dirlink>
    8000534c:	04054363          	bltz	a0,80005392 <sys_link+0x100>
  iunlockput(dp);
    80005350:	854a                	mv	a0,s2
    80005352:	ffffe097          	auipc	ra,0xffffe
    80005356:	56e080e7          	jalr	1390(ra) # 800038c0 <iunlockput>
  iput(ip);
    8000535a:	8526                	mv	a0,s1
    8000535c:	ffffe097          	auipc	ra,0xffffe
    80005360:	4bc080e7          	jalr	1212(ra) # 80003818 <iput>
  end_op();
    80005364:	fffff097          	auipc	ra,0xfffff
    80005368:	d1a080e7          	jalr	-742(ra) # 8000407e <end_op>
  return 0;
    8000536c:	4781                	li	a5,0
    8000536e:	a085                	j	800053ce <sys_link+0x13c>
    end_op();
    80005370:	fffff097          	auipc	ra,0xfffff
    80005374:	d0e080e7          	jalr	-754(ra) # 8000407e <end_op>
    return -1;
    80005378:	57fd                	li	a5,-1
    8000537a:	a891                	j	800053ce <sys_link+0x13c>
    iunlockput(ip);
    8000537c:	8526                	mv	a0,s1
    8000537e:	ffffe097          	auipc	ra,0xffffe
    80005382:	542080e7          	jalr	1346(ra) # 800038c0 <iunlockput>
    end_op();
    80005386:	fffff097          	auipc	ra,0xfffff
    8000538a:	cf8080e7          	jalr	-776(ra) # 8000407e <end_op>
    return -1;
    8000538e:	57fd                	li	a5,-1
    80005390:	a83d                	j	800053ce <sys_link+0x13c>
    iunlockput(dp);
    80005392:	854a                	mv	a0,s2
    80005394:	ffffe097          	auipc	ra,0xffffe
    80005398:	52c080e7          	jalr	1324(ra) # 800038c0 <iunlockput>
  ilock(ip);
    8000539c:	8526                	mv	a0,s1
    8000539e:	ffffe097          	auipc	ra,0xffffe
    800053a2:	2c0080e7          	jalr	704(ra) # 8000365e <ilock>
  ip->nlink--;
    800053a6:	04a4d783          	lhu	a5,74(s1)
    800053aa:	37fd                	addiw	a5,a5,-1
    800053ac:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800053b0:	8526                	mv	a0,s1
    800053b2:	ffffe097          	auipc	ra,0xffffe
    800053b6:	1e0080e7          	jalr	480(ra) # 80003592 <iupdate>
  iunlockput(ip);
    800053ba:	8526                	mv	a0,s1
    800053bc:	ffffe097          	auipc	ra,0xffffe
    800053c0:	504080e7          	jalr	1284(ra) # 800038c0 <iunlockput>
  end_op();
    800053c4:	fffff097          	auipc	ra,0xfffff
    800053c8:	cba080e7          	jalr	-838(ra) # 8000407e <end_op>
  return -1;
    800053cc:	57fd                	li	a5,-1
}
    800053ce:	853e                	mv	a0,a5
    800053d0:	70b2                	ld	ra,296(sp)
    800053d2:	7412                	ld	s0,288(sp)
    800053d4:	64f2                	ld	s1,280(sp)
    800053d6:	6952                	ld	s2,272(sp)
    800053d8:	6155                	addi	sp,sp,304
    800053da:	8082                	ret

00000000800053dc <sys_unlink>:
{
    800053dc:	7151                	addi	sp,sp,-240
    800053de:	f586                	sd	ra,232(sp)
    800053e0:	f1a2                	sd	s0,224(sp)
    800053e2:	eda6                	sd	s1,216(sp)
    800053e4:	e9ca                	sd	s2,208(sp)
    800053e6:	e5ce                	sd	s3,200(sp)
    800053e8:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    800053ea:	08000613          	li	a2,128
    800053ee:	f3040593          	addi	a1,s0,-208
    800053f2:	4501                	li	a0,0
    800053f4:	ffffd097          	auipc	ra,0xffffd
    800053f8:	738080e7          	jalr	1848(ra) # 80002b2c <argstr>
    800053fc:	18054163          	bltz	a0,8000557e <sys_unlink+0x1a2>
  begin_op();
    80005400:	fffff097          	auipc	ra,0xfffff
    80005404:	c04080e7          	jalr	-1020(ra) # 80004004 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80005408:	fb040593          	addi	a1,s0,-80
    8000540c:	f3040513          	addi	a0,s0,-208
    80005410:	fffff097          	auipc	ra,0xfffff
    80005414:	a12080e7          	jalr	-1518(ra) # 80003e22 <nameiparent>
    80005418:	84aa                	mv	s1,a0
    8000541a:	c979                	beqz	a0,800054f0 <sys_unlink+0x114>
  ilock(dp);
    8000541c:	ffffe097          	auipc	ra,0xffffe
    80005420:	242080e7          	jalr	578(ra) # 8000365e <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80005424:	00003597          	auipc	a1,0x3
    80005428:	2cc58593          	addi	a1,a1,716 # 800086f0 <syscalls+0x2a8>
    8000542c:	fb040513          	addi	a0,s0,-80
    80005430:	ffffe097          	auipc	ra,0xffffe
    80005434:	6f8080e7          	jalr	1784(ra) # 80003b28 <namecmp>
    80005438:	14050a63          	beqz	a0,8000558c <sys_unlink+0x1b0>
    8000543c:	00003597          	auipc	a1,0x3
    80005440:	2bc58593          	addi	a1,a1,700 # 800086f8 <syscalls+0x2b0>
    80005444:	fb040513          	addi	a0,s0,-80
    80005448:	ffffe097          	auipc	ra,0xffffe
    8000544c:	6e0080e7          	jalr	1760(ra) # 80003b28 <namecmp>
    80005450:	12050e63          	beqz	a0,8000558c <sys_unlink+0x1b0>
  if((ip = dirlookup(dp, name, &off)) == 0)
    80005454:	f2c40613          	addi	a2,s0,-212
    80005458:	fb040593          	addi	a1,s0,-80
    8000545c:	8526                	mv	a0,s1
    8000545e:	ffffe097          	auipc	ra,0xffffe
    80005462:	6e4080e7          	jalr	1764(ra) # 80003b42 <dirlookup>
    80005466:	892a                	mv	s2,a0
    80005468:	12050263          	beqz	a0,8000558c <sys_unlink+0x1b0>
  ilock(ip);
    8000546c:	ffffe097          	auipc	ra,0xffffe
    80005470:	1f2080e7          	jalr	498(ra) # 8000365e <ilock>
  if(ip->nlink < 1)
    80005474:	04a91783          	lh	a5,74(s2)
    80005478:	08f05263          	blez	a5,800054fc <sys_unlink+0x120>
  if(ip->type == T_DIR && !isdirempty(ip)){
    8000547c:	04491703          	lh	a4,68(s2)
    80005480:	4785                	li	a5,1
    80005482:	08f70563          	beq	a4,a5,8000550c <sys_unlink+0x130>
  memset(&de, 0, sizeof(de));
    80005486:	4641                	li	a2,16
    80005488:	4581                	li	a1,0
    8000548a:	fc040513          	addi	a0,s0,-64
    8000548e:	ffffc097          	auipc	ra,0xffffc
    80005492:	840080e7          	jalr	-1984(ra) # 80000cce <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005496:	4741                	li	a4,16
    80005498:	f2c42683          	lw	a3,-212(s0)
    8000549c:	fc040613          	addi	a2,s0,-64
    800054a0:	4581                	li	a1,0
    800054a2:	8526                	mv	a0,s1
    800054a4:	ffffe097          	auipc	ra,0xffffe
    800054a8:	566080e7          	jalr	1382(ra) # 80003a0a <writei>
    800054ac:	47c1                	li	a5,16
    800054ae:	0af51563          	bne	a0,a5,80005558 <sys_unlink+0x17c>
  if(ip->type == T_DIR){
    800054b2:	04491703          	lh	a4,68(s2)
    800054b6:	4785                	li	a5,1
    800054b8:	0af70863          	beq	a4,a5,80005568 <sys_unlink+0x18c>
  iunlockput(dp);
    800054bc:	8526                	mv	a0,s1
    800054be:	ffffe097          	auipc	ra,0xffffe
    800054c2:	402080e7          	jalr	1026(ra) # 800038c0 <iunlockput>
  ip->nlink--;
    800054c6:	04a95783          	lhu	a5,74(s2)
    800054ca:	37fd                	addiw	a5,a5,-1
    800054cc:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    800054d0:	854a                	mv	a0,s2
    800054d2:	ffffe097          	auipc	ra,0xffffe
    800054d6:	0c0080e7          	jalr	192(ra) # 80003592 <iupdate>
  iunlockput(ip);
    800054da:	854a                	mv	a0,s2
    800054dc:	ffffe097          	auipc	ra,0xffffe
    800054e0:	3e4080e7          	jalr	996(ra) # 800038c0 <iunlockput>
  end_op();
    800054e4:	fffff097          	auipc	ra,0xfffff
    800054e8:	b9a080e7          	jalr	-1126(ra) # 8000407e <end_op>
  return 0;
    800054ec:	4501                	li	a0,0
    800054ee:	a84d                	j	800055a0 <sys_unlink+0x1c4>
    end_op();
    800054f0:	fffff097          	auipc	ra,0xfffff
    800054f4:	b8e080e7          	jalr	-1138(ra) # 8000407e <end_op>
    return -1;
    800054f8:	557d                	li	a0,-1
    800054fa:	a05d                	j	800055a0 <sys_unlink+0x1c4>
    panic("unlink: nlink < 1");
    800054fc:	00003517          	auipc	a0,0x3
    80005500:	20450513          	addi	a0,a0,516 # 80008700 <syscalls+0x2b8>
    80005504:	ffffb097          	auipc	ra,0xffffb
    80005508:	038080e7          	jalr	56(ra) # 8000053c <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    8000550c:	04c92703          	lw	a4,76(s2)
    80005510:	02000793          	li	a5,32
    80005514:	f6e7f9e3          	bgeu	a5,a4,80005486 <sys_unlink+0xaa>
    80005518:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000551c:	4741                	li	a4,16
    8000551e:	86ce                	mv	a3,s3
    80005520:	f1840613          	addi	a2,s0,-232
    80005524:	4581                	li	a1,0
    80005526:	854a                	mv	a0,s2
    80005528:	ffffe097          	auipc	ra,0xffffe
    8000552c:	3ea080e7          	jalr	1002(ra) # 80003912 <readi>
    80005530:	47c1                	li	a5,16
    80005532:	00f51b63          	bne	a0,a5,80005548 <sys_unlink+0x16c>
    if(de.inum != 0)
    80005536:	f1845783          	lhu	a5,-232(s0)
    8000553a:	e7a1                	bnez	a5,80005582 <sys_unlink+0x1a6>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    8000553c:	29c1                	addiw	s3,s3,16
    8000553e:	04c92783          	lw	a5,76(s2)
    80005542:	fcf9ede3          	bltu	s3,a5,8000551c <sys_unlink+0x140>
    80005546:	b781                	j	80005486 <sys_unlink+0xaa>
      panic("isdirempty: readi");
    80005548:	00003517          	auipc	a0,0x3
    8000554c:	1d050513          	addi	a0,a0,464 # 80008718 <syscalls+0x2d0>
    80005550:	ffffb097          	auipc	ra,0xffffb
    80005554:	fec080e7          	jalr	-20(ra) # 8000053c <panic>
    panic("unlink: writei");
    80005558:	00003517          	auipc	a0,0x3
    8000555c:	1d850513          	addi	a0,a0,472 # 80008730 <syscalls+0x2e8>
    80005560:	ffffb097          	auipc	ra,0xffffb
    80005564:	fdc080e7          	jalr	-36(ra) # 8000053c <panic>
    dp->nlink--;
    80005568:	04a4d783          	lhu	a5,74(s1)
    8000556c:	37fd                	addiw	a5,a5,-1
    8000556e:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005572:	8526                	mv	a0,s1
    80005574:	ffffe097          	auipc	ra,0xffffe
    80005578:	01e080e7          	jalr	30(ra) # 80003592 <iupdate>
    8000557c:	b781                	j	800054bc <sys_unlink+0xe0>
    return -1;
    8000557e:	557d                	li	a0,-1
    80005580:	a005                	j	800055a0 <sys_unlink+0x1c4>
    iunlockput(ip);
    80005582:	854a                	mv	a0,s2
    80005584:	ffffe097          	auipc	ra,0xffffe
    80005588:	33c080e7          	jalr	828(ra) # 800038c0 <iunlockput>
  iunlockput(dp);
    8000558c:	8526                	mv	a0,s1
    8000558e:	ffffe097          	auipc	ra,0xffffe
    80005592:	332080e7          	jalr	818(ra) # 800038c0 <iunlockput>
  end_op();
    80005596:	fffff097          	auipc	ra,0xfffff
    8000559a:	ae8080e7          	jalr	-1304(ra) # 8000407e <end_op>
  return -1;
    8000559e:	557d                	li	a0,-1
}
    800055a0:	70ae                	ld	ra,232(sp)
    800055a2:	740e                	ld	s0,224(sp)
    800055a4:	64ee                	ld	s1,216(sp)
    800055a6:	694e                	ld	s2,208(sp)
    800055a8:	69ae                	ld	s3,200(sp)
    800055aa:	616d                	addi	sp,sp,240
    800055ac:	8082                	ret

00000000800055ae <sys_open>:

uint64
sys_open(void)
{
    800055ae:	7131                	addi	sp,sp,-192
    800055b0:	fd06                	sd	ra,184(sp)
    800055b2:	f922                	sd	s0,176(sp)
    800055b4:	f526                	sd	s1,168(sp)
    800055b6:	f14a                	sd	s2,160(sp)
    800055b8:	ed4e                	sd	s3,152(sp)
    800055ba:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    800055bc:	f4c40593          	addi	a1,s0,-180
    800055c0:	4505                	li	a0,1
    800055c2:	ffffd097          	auipc	ra,0xffffd
    800055c6:	52a080e7          	jalr	1322(ra) # 80002aec <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    800055ca:	08000613          	li	a2,128
    800055ce:	f5040593          	addi	a1,s0,-176
    800055d2:	4501                	li	a0,0
    800055d4:	ffffd097          	auipc	ra,0xffffd
    800055d8:	558080e7          	jalr	1368(ra) # 80002b2c <argstr>
    800055dc:	87aa                	mv	a5,a0
    return -1;
    800055de:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    800055e0:	0a07c863          	bltz	a5,80005690 <sys_open+0xe2>

  begin_op();
    800055e4:	fffff097          	auipc	ra,0xfffff
    800055e8:	a20080e7          	jalr	-1504(ra) # 80004004 <begin_op>

  if(omode & O_CREATE){
    800055ec:	f4c42783          	lw	a5,-180(s0)
    800055f0:	2007f793          	andi	a5,a5,512
    800055f4:	cbdd                	beqz	a5,800056aa <sys_open+0xfc>
    ip = create(path, T_FILE, 0, 0);
    800055f6:	4681                	li	a3,0
    800055f8:	4601                	li	a2,0
    800055fa:	4589                	li	a1,2
    800055fc:	f5040513          	addi	a0,s0,-176
    80005600:	00000097          	auipc	ra,0x0
    80005604:	97a080e7          	jalr	-1670(ra) # 80004f7a <create>
    80005608:	84aa                	mv	s1,a0
    if(ip == 0){
    8000560a:	c951                	beqz	a0,8000569e <sys_open+0xf0>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    8000560c:	04449703          	lh	a4,68(s1)
    80005610:	478d                	li	a5,3
    80005612:	00f71763          	bne	a4,a5,80005620 <sys_open+0x72>
    80005616:	0464d703          	lhu	a4,70(s1)
    8000561a:	47a5                	li	a5,9
    8000561c:	0ce7ec63          	bltu	a5,a4,800056f4 <sys_open+0x146>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80005620:	fffff097          	auipc	ra,0xfffff
    80005624:	dec080e7          	jalr	-532(ra) # 8000440c <filealloc>
    80005628:	892a                	mv	s2,a0
    8000562a:	c56d                	beqz	a0,80005714 <sys_open+0x166>
    8000562c:	00000097          	auipc	ra,0x0
    80005630:	90c080e7          	jalr	-1780(ra) # 80004f38 <fdalloc>
    80005634:	89aa                	mv	s3,a0
    80005636:	0c054a63          	bltz	a0,8000570a <sys_open+0x15c>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    8000563a:	04449703          	lh	a4,68(s1)
    8000563e:	478d                	li	a5,3
    80005640:	0ef70563          	beq	a4,a5,8000572a <sys_open+0x17c>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80005644:	4789                	li	a5,2
    80005646:	00f92023          	sw	a5,0(s2)
    f->off = 0;
    8000564a:	02092023          	sw	zero,32(s2)
  }
  f->ip = ip;
    8000564e:	00993c23          	sd	s1,24(s2)
  f->readable = !(omode & O_WRONLY);
    80005652:	f4c42783          	lw	a5,-180(s0)
    80005656:	0017c713          	xori	a4,a5,1
    8000565a:	8b05                	andi	a4,a4,1
    8000565c:	00e90423          	sb	a4,8(s2)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80005660:	0037f713          	andi	a4,a5,3
    80005664:	00e03733          	snez	a4,a4
    80005668:	00e904a3          	sb	a4,9(s2)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    8000566c:	4007f793          	andi	a5,a5,1024
    80005670:	c791                	beqz	a5,8000567c <sys_open+0xce>
    80005672:	04449703          	lh	a4,68(s1)
    80005676:	4789                	li	a5,2
    80005678:	0cf70063          	beq	a4,a5,80005738 <sys_open+0x18a>
    itrunc(ip);
  }

  iunlock(ip);
    8000567c:	8526                	mv	a0,s1
    8000567e:	ffffe097          	auipc	ra,0xffffe
    80005682:	0a2080e7          	jalr	162(ra) # 80003720 <iunlock>
  end_op();
    80005686:	fffff097          	auipc	ra,0xfffff
    8000568a:	9f8080e7          	jalr	-1544(ra) # 8000407e <end_op>

  return fd;
    8000568e:	854e                	mv	a0,s3
}
    80005690:	70ea                	ld	ra,184(sp)
    80005692:	744a                	ld	s0,176(sp)
    80005694:	74aa                	ld	s1,168(sp)
    80005696:	790a                	ld	s2,160(sp)
    80005698:	69ea                	ld	s3,152(sp)
    8000569a:	6129                	addi	sp,sp,192
    8000569c:	8082                	ret
      end_op();
    8000569e:	fffff097          	auipc	ra,0xfffff
    800056a2:	9e0080e7          	jalr	-1568(ra) # 8000407e <end_op>
      return -1;
    800056a6:	557d                	li	a0,-1
    800056a8:	b7e5                	j	80005690 <sys_open+0xe2>
    if((ip = namei(path)) == 0){
    800056aa:	f5040513          	addi	a0,s0,-176
    800056ae:	ffffe097          	auipc	ra,0xffffe
    800056b2:	756080e7          	jalr	1878(ra) # 80003e04 <namei>
    800056b6:	84aa                	mv	s1,a0
    800056b8:	c905                	beqz	a0,800056e8 <sys_open+0x13a>
    ilock(ip);
    800056ba:	ffffe097          	auipc	ra,0xffffe
    800056be:	fa4080e7          	jalr	-92(ra) # 8000365e <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    800056c2:	04449703          	lh	a4,68(s1)
    800056c6:	4785                	li	a5,1
    800056c8:	f4f712e3          	bne	a4,a5,8000560c <sys_open+0x5e>
    800056cc:	f4c42783          	lw	a5,-180(s0)
    800056d0:	dba1                	beqz	a5,80005620 <sys_open+0x72>
      iunlockput(ip);
    800056d2:	8526                	mv	a0,s1
    800056d4:	ffffe097          	auipc	ra,0xffffe
    800056d8:	1ec080e7          	jalr	492(ra) # 800038c0 <iunlockput>
      end_op();
    800056dc:	fffff097          	auipc	ra,0xfffff
    800056e0:	9a2080e7          	jalr	-1630(ra) # 8000407e <end_op>
      return -1;
    800056e4:	557d                	li	a0,-1
    800056e6:	b76d                	j	80005690 <sys_open+0xe2>
      end_op();
    800056e8:	fffff097          	auipc	ra,0xfffff
    800056ec:	996080e7          	jalr	-1642(ra) # 8000407e <end_op>
      return -1;
    800056f0:	557d                	li	a0,-1
    800056f2:	bf79                	j	80005690 <sys_open+0xe2>
    iunlockput(ip);
    800056f4:	8526                	mv	a0,s1
    800056f6:	ffffe097          	auipc	ra,0xffffe
    800056fa:	1ca080e7          	jalr	458(ra) # 800038c0 <iunlockput>
    end_op();
    800056fe:	fffff097          	auipc	ra,0xfffff
    80005702:	980080e7          	jalr	-1664(ra) # 8000407e <end_op>
    return -1;
    80005706:	557d                	li	a0,-1
    80005708:	b761                	j	80005690 <sys_open+0xe2>
      fileclose(f);
    8000570a:	854a                	mv	a0,s2
    8000570c:	fffff097          	auipc	ra,0xfffff
    80005710:	dbc080e7          	jalr	-580(ra) # 800044c8 <fileclose>
    iunlockput(ip);
    80005714:	8526                	mv	a0,s1
    80005716:	ffffe097          	auipc	ra,0xffffe
    8000571a:	1aa080e7          	jalr	426(ra) # 800038c0 <iunlockput>
    end_op();
    8000571e:	fffff097          	auipc	ra,0xfffff
    80005722:	960080e7          	jalr	-1696(ra) # 8000407e <end_op>
    return -1;
    80005726:	557d                	li	a0,-1
    80005728:	b7a5                	j	80005690 <sys_open+0xe2>
    f->type = FD_DEVICE;
    8000572a:	00f92023          	sw	a5,0(s2)
    f->major = ip->major;
    8000572e:	04649783          	lh	a5,70(s1)
    80005732:	02f91223          	sh	a5,36(s2)
    80005736:	bf21                	j	8000564e <sys_open+0xa0>
    itrunc(ip);
    80005738:	8526                	mv	a0,s1
    8000573a:	ffffe097          	auipc	ra,0xffffe
    8000573e:	032080e7          	jalr	50(ra) # 8000376c <itrunc>
    80005742:	bf2d                	j	8000567c <sys_open+0xce>

0000000080005744 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005744:	7175                	addi	sp,sp,-144
    80005746:	e506                	sd	ra,136(sp)
    80005748:	e122                	sd	s0,128(sp)
    8000574a:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    8000574c:	fffff097          	auipc	ra,0xfffff
    80005750:	8b8080e7          	jalr	-1864(ra) # 80004004 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80005754:	08000613          	li	a2,128
    80005758:	f7040593          	addi	a1,s0,-144
    8000575c:	4501                	li	a0,0
    8000575e:	ffffd097          	auipc	ra,0xffffd
    80005762:	3ce080e7          	jalr	974(ra) # 80002b2c <argstr>
    80005766:	02054963          	bltz	a0,80005798 <sys_mkdir+0x54>
    8000576a:	4681                	li	a3,0
    8000576c:	4601                	li	a2,0
    8000576e:	4585                	li	a1,1
    80005770:	f7040513          	addi	a0,s0,-144
    80005774:	00000097          	auipc	ra,0x0
    80005778:	806080e7          	jalr	-2042(ra) # 80004f7a <create>
    8000577c:	cd11                	beqz	a0,80005798 <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    8000577e:	ffffe097          	auipc	ra,0xffffe
    80005782:	142080e7          	jalr	322(ra) # 800038c0 <iunlockput>
  end_op();
    80005786:	fffff097          	auipc	ra,0xfffff
    8000578a:	8f8080e7          	jalr	-1800(ra) # 8000407e <end_op>
  return 0;
    8000578e:	4501                	li	a0,0
}
    80005790:	60aa                	ld	ra,136(sp)
    80005792:	640a                	ld	s0,128(sp)
    80005794:	6149                	addi	sp,sp,144
    80005796:	8082                	ret
    end_op();
    80005798:	fffff097          	auipc	ra,0xfffff
    8000579c:	8e6080e7          	jalr	-1818(ra) # 8000407e <end_op>
    return -1;
    800057a0:	557d                	li	a0,-1
    800057a2:	b7fd                	j	80005790 <sys_mkdir+0x4c>

00000000800057a4 <sys_mknod>:

uint64
sys_mknod(void)
{
    800057a4:	7135                	addi	sp,sp,-160
    800057a6:	ed06                	sd	ra,152(sp)
    800057a8:	e922                	sd	s0,144(sp)
    800057aa:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    800057ac:	fffff097          	auipc	ra,0xfffff
    800057b0:	858080e7          	jalr	-1960(ra) # 80004004 <begin_op>
  argint(1, &major);
    800057b4:	f6c40593          	addi	a1,s0,-148
    800057b8:	4505                	li	a0,1
    800057ba:	ffffd097          	auipc	ra,0xffffd
    800057be:	332080e7          	jalr	818(ra) # 80002aec <argint>
  argint(2, &minor);
    800057c2:	f6840593          	addi	a1,s0,-152
    800057c6:	4509                	li	a0,2
    800057c8:	ffffd097          	auipc	ra,0xffffd
    800057cc:	324080e7          	jalr	804(ra) # 80002aec <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    800057d0:	08000613          	li	a2,128
    800057d4:	f7040593          	addi	a1,s0,-144
    800057d8:	4501                	li	a0,0
    800057da:	ffffd097          	auipc	ra,0xffffd
    800057de:	352080e7          	jalr	850(ra) # 80002b2c <argstr>
    800057e2:	02054b63          	bltz	a0,80005818 <sys_mknod+0x74>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    800057e6:	f6841683          	lh	a3,-152(s0)
    800057ea:	f6c41603          	lh	a2,-148(s0)
    800057ee:	458d                	li	a1,3
    800057f0:	f7040513          	addi	a0,s0,-144
    800057f4:	fffff097          	auipc	ra,0xfffff
    800057f8:	786080e7          	jalr	1926(ra) # 80004f7a <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    800057fc:	cd11                	beqz	a0,80005818 <sys_mknod+0x74>
    end_op();
    return -1;
  }
  iunlockput(ip);
    800057fe:	ffffe097          	auipc	ra,0xffffe
    80005802:	0c2080e7          	jalr	194(ra) # 800038c0 <iunlockput>
  end_op();
    80005806:	fffff097          	auipc	ra,0xfffff
    8000580a:	878080e7          	jalr	-1928(ra) # 8000407e <end_op>
  return 0;
    8000580e:	4501                	li	a0,0
}
    80005810:	60ea                	ld	ra,152(sp)
    80005812:	644a                	ld	s0,144(sp)
    80005814:	610d                	addi	sp,sp,160
    80005816:	8082                	ret
    end_op();
    80005818:	fffff097          	auipc	ra,0xfffff
    8000581c:	866080e7          	jalr	-1946(ra) # 8000407e <end_op>
    return -1;
    80005820:	557d                	li	a0,-1
    80005822:	b7fd                	j	80005810 <sys_mknod+0x6c>

0000000080005824 <sys_chdir>:

uint64
sys_chdir(void)
{
    80005824:	7135                	addi	sp,sp,-160
    80005826:	ed06                	sd	ra,152(sp)
    80005828:	e922                	sd	s0,144(sp)
    8000582a:	e526                	sd	s1,136(sp)
    8000582c:	e14a                	sd	s2,128(sp)
    8000582e:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80005830:	ffffc097          	auipc	ra,0xffffc
    80005834:	19a080e7          	jalr	410(ra) # 800019ca <myproc>
    80005838:	892a                	mv	s2,a0
  
  begin_op();
    8000583a:	ffffe097          	auipc	ra,0xffffe
    8000583e:	7ca080e7          	jalr	1994(ra) # 80004004 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80005842:	08000613          	li	a2,128
    80005846:	f6040593          	addi	a1,s0,-160
    8000584a:	4501                	li	a0,0
    8000584c:	ffffd097          	auipc	ra,0xffffd
    80005850:	2e0080e7          	jalr	736(ra) # 80002b2c <argstr>
    80005854:	04054b63          	bltz	a0,800058aa <sys_chdir+0x86>
    80005858:	f6040513          	addi	a0,s0,-160
    8000585c:	ffffe097          	auipc	ra,0xffffe
    80005860:	5a8080e7          	jalr	1448(ra) # 80003e04 <namei>
    80005864:	84aa                	mv	s1,a0
    80005866:	c131                	beqz	a0,800058aa <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    80005868:	ffffe097          	auipc	ra,0xffffe
    8000586c:	df6080e7          	jalr	-522(ra) # 8000365e <ilock>
  if(ip->type != T_DIR){
    80005870:	04449703          	lh	a4,68(s1)
    80005874:	4785                	li	a5,1
    80005876:	04f71063          	bne	a4,a5,800058b6 <sys_chdir+0x92>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    8000587a:	8526                	mv	a0,s1
    8000587c:	ffffe097          	auipc	ra,0xffffe
    80005880:	ea4080e7          	jalr	-348(ra) # 80003720 <iunlock>
  iput(p->cwd);
    80005884:	15093503          	ld	a0,336(s2)
    80005888:	ffffe097          	auipc	ra,0xffffe
    8000588c:	f90080e7          	jalr	-112(ra) # 80003818 <iput>
  end_op();
    80005890:	ffffe097          	auipc	ra,0xffffe
    80005894:	7ee080e7          	jalr	2030(ra) # 8000407e <end_op>
  p->cwd = ip;
    80005898:	14993823          	sd	s1,336(s2)
  return 0;
    8000589c:	4501                	li	a0,0
}
    8000589e:	60ea                	ld	ra,152(sp)
    800058a0:	644a                	ld	s0,144(sp)
    800058a2:	64aa                	ld	s1,136(sp)
    800058a4:	690a                	ld	s2,128(sp)
    800058a6:	610d                	addi	sp,sp,160
    800058a8:	8082                	ret
    end_op();
    800058aa:	ffffe097          	auipc	ra,0xffffe
    800058ae:	7d4080e7          	jalr	2004(ra) # 8000407e <end_op>
    return -1;
    800058b2:	557d                	li	a0,-1
    800058b4:	b7ed                	j	8000589e <sys_chdir+0x7a>
    iunlockput(ip);
    800058b6:	8526                	mv	a0,s1
    800058b8:	ffffe097          	auipc	ra,0xffffe
    800058bc:	008080e7          	jalr	8(ra) # 800038c0 <iunlockput>
    end_op();
    800058c0:	ffffe097          	auipc	ra,0xffffe
    800058c4:	7be080e7          	jalr	1982(ra) # 8000407e <end_op>
    return -1;
    800058c8:	557d                	li	a0,-1
    800058ca:	bfd1                	j	8000589e <sys_chdir+0x7a>

00000000800058cc <sys_exec>:

uint64
sys_exec(void)
{
    800058cc:	7121                	addi	sp,sp,-448
    800058ce:	ff06                	sd	ra,440(sp)
    800058d0:	fb22                	sd	s0,432(sp)
    800058d2:	f726                	sd	s1,424(sp)
    800058d4:	f34a                	sd	s2,416(sp)
    800058d6:	ef4e                	sd	s3,408(sp)
    800058d8:	eb52                	sd	s4,400(sp)
    800058da:	0380                	addi	s0,sp,448
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    800058dc:	e4840593          	addi	a1,s0,-440
    800058e0:	4505                	li	a0,1
    800058e2:	ffffd097          	auipc	ra,0xffffd
    800058e6:	22a080e7          	jalr	554(ra) # 80002b0c <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    800058ea:	08000613          	li	a2,128
    800058ee:	f5040593          	addi	a1,s0,-176
    800058f2:	4501                	li	a0,0
    800058f4:	ffffd097          	auipc	ra,0xffffd
    800058f8:	238080e7          	jalr	568(ra) # 80002b2c <argstr>
    800058fc:	87aa                	mv	a5,a0
    return -1;
    800058fe:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    80005900:	0c07c263          	bltz	a5,800059c4 <sys_exec+0xf8>
  }
  memset(argv, 0, sizeof(argv));
    80005904:	10000613          	li	a2,256
    80005908:	4581                	li	a1,0
    8000590a:	e5040513          	addi	a0,s0,-432
    8000590e:	ffffb097          	auipc	ra,0xffffb
    80005912:	3c0080e7          	jalr	960(ra) # 80000cce <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80005916:	e5040493          	addi	s1,s0,-432
  memset(argv, 0, sizeof(argv));
    8000591a:	89a6                	mv	s3,s1
    8000591c:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    8000591e:	02000a13          	li	s4,32
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80005922:	00391513          	slli	a0,s2,0x3
    80005926:	e4040593          	addi	a1,s0,-448
    8000592a:	e4843783          	ld	a5,-440(s0)
    8000592e:	953e                	add	a0,a0,a5
    80005930:	ffffd097          	auipc	ra,0xffffd
    80005934:	11e080e7          	jalr	286(ra) # 80002a4e <fetchaddr>
    80005938:	02054a63          	bltz	a0,8000596c <sys_exec+0xa0>
      goto bad;
    }
    if(uarg == 0){
    8000593c:	e4043783          	ld	a5,-448(s0)
    80005940:	c3b9                	beqz	a5,80005986 <sys_exec+0xba>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80005942:	ffffb097          	auipc	ra,0xffffb
    80005946:	1a0080e7          	jalr	416(ra) # 80000ae2 <kalloc>
    8000594a:	85aa                	mv	a1,a0
    8000594c:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80005950:	cd11                	beqz	a0,8000596c <sys_exec+0xa0>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005952:	6605                	lui	a2,0x1
    80005954:	e4043503          	ld	a0,-448(s0)
    80005958:	ffffd097          	auipc	ra,0xffffd
    8000595c:	148080e7          	jalr	328(ra) # 80002aa0 <fetchstr>
    80005960:	00054663          	bltz	a0,8000596c <sys_exec+0xa0>
    if(i >= NELEM(argv)){
    80005964:	0905                	addi	s2,s2,1
    80005966:	09a1                	addi	s3,s3,8
    80005968:	fb491de3          	bne	s2,s4,80005922 <sys_exec+0x56>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    8000596c:	f5040913          	addi	s2,s0,-176
    80005970:	6088                	ld	a0,0(s1)
    80005972:	c921                	beqz	a0,800059c2 <sys_exec+0xf6>
    kfree(argv[i]);
    80005974:	ffffb097          	auipc	ra,0xffffb
    80005978:	070080e7          	jalr	112(ra) # 800009e4 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    8000597c:	04a1                	addi	s1,s1,8
    8000597e:	ff2499e3          	bne	s1,s2,80005970 <sys_exec+0xa4>
  return -1;
    80005982:	557d                	li	a0,-1
    80005984:	a081                	j	800059c4 <sys_exec+0xf8>
      argv[i] = 0;
    80005986:	0009079b          	sext.w	a5,s2
    8000598a:	078e                	slli	a5,a5,0x3
    8000598c:	fd078793          	addi	a5,a5,-48
    80005990:	97a2                	add	a5,a5,s0
    80005992:	e807b023          	sd	zero,-384(a5)
  int ret = exec(path, argv);
    80005996:	e5040593          	addi	a1,s0,-432
    8000599a:	f5040513          	addi	a0,s0,-176
    8000599e:	fffff097          	auipc	ra,0xfffff
    800059a2:	24a080e7          	jalr	586(ra) # 80004be8 <exec>
    800059a6:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800059a8:	f5040993          	addi	s3,s0,-176
    800059ac:	6088                	ld	a0,0(s1)
    800059ae:	c901                	beqz	a0,800059be <sys_exec+0xf2>
    kfree(argv[i]);
    800059b0:	ffffb097          	auipc	ra,0xffffb
    800059b4:	034080e7          	jalr	52(ra) # 800009e4 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800059b8:	04a1                	addi	s1,s1,8
    800059ba:	ff3499e3          	bne	s1,s3,800059ac <sys_exec+0xe0>
  return ret;
    800059be:	854a                	mv	a0,s2
    800059c0:	a011                	j	800059c4 <sys_exec+0xf8>
  return -1;
    800059c2:	557d                	li	a0,-1
}
    800059c4:	70fa                	ld	ra,440(sp)
    800059c6:	745a                	ld	s0,432(sp)
    800059c8:	74ba                	ld	s1,424(sp)
    800059ca:	791a                	ld	s2,416(sp)
    800059cc:	69fa                	ld	s3,408(sp)
    800059ce:	6a5a                	ld	s4,400(sp)
    800059d0:	6139                	addi	sp,sp,448
    800059d2:	8082                	ret

00000000800059d4 <sys_pipe>:

uint64
sys_pipe(void)
{
    800059d4:	7139                	addi	sp,sp,-64
    800059d6:	fc06                	sd	ra,56(sp)
    800059d8:	f822                	sd	s0,48(sp)
    800059da:	f426                	sd	s1,40(sp)
    800059dc:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    800059de:	ffffc097          	auipc	ra,0xffffc
    800059e2:	fec080e7          	jalr	-20(ra) # 800019ca <myproc>
    800059e6:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    800059e8:	fd840593          	addi	a1,s0,-40
    800059ec:	4501                	li	a0,0
    800059ee:	ffffd097          	auipc	ra,0xffffd
    800059f2:	11e080e7          	jalr	286(ra) # 80002b0c <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    800059f6:	fc840593          	addi	a1,s0,-56
    800059fa:	fd040513          	addi	a0,s0,-48
    800059fe:	fffff097          	auipc	ra,0xfffff
    80005a02:	df6080e7          	jalr	-522(ra) # 800047f4 <pipealloc>
    return -1;
    80005a06:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80005a08:	0c054463          	bltz	a0,80005ad0 <sys_pipe+0xfc>
  fd0 = -1;
    80005a0c:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80005a10:	fd043503          	ld	a0,-48(s0)
    80005a14:	fffff097          	auipc	ra,0xfffff
    80005a18:	524080e7          	jalr	1316(ra) # 80004f38 <fdalloc>
    80005a1c:	fca42223          	sw	a0,-60(s0)
    80005a20:	08054b63          	bltz	a0,80005ab6 <sys_pipe+0xe2>
    80005a24:	fc843503          	ld	a0,-56(s0)
    80005a28:	fffff097          	auipc	ra,0xfffff
    80005a2c:	510080e7          	jalr	1296(ra) # 80004f38 <fdalloc>
    80005a30:	fca42023          	sw	a0,-64(s0)
    80005a34:	06054863          	bltz	a0,80005aa4 <sys_pipe+0xd0>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005a38:	4691                	li	a3,4
    80005a3a:	fc440613          	addi	a2,s0,-60
    80005a3e:	fd843583          	ld	a1,-40(s0)
    80005a42:	68a8                	ld	a0,80(s1)
    80005a44:	ffffc097          	auipc	ra,0xffffc
    80005a48:	c46080e7          	jalr	-954(ra) # 8000168a <copyout>
    80005a4c:	02054063          	bltz	a0,80005a6c <sys_pipe+0x98>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80005a50:	4691                	li	a3,4
    80005a52:	fc040613          	addi	a2,s0,-64
    80005a56:	fd843583          	ld	a1,-40(s0)
    80005a5a:	0591                	addi	a1,a1,4
    80005a5c:	68a8                	ld	a0,80(s1)
    80005a5e:	ffffc097          	auipc	ra,0xffffc
    80005a62:	c2c080e7          	jalr	-980(ra) # 8000168a <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80005a66:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005a68:	06055463          	bgez	a0,80005ad0 <sys_pipe+0xfc>
    p->ofile[fd0] = 0;
    80005a6c:	fc442783          	lw	a5,-60(s0)
    80005a70:	07e9                	addi	a5,a5,26
    80005a72:	078e                	slli	a5,a5,0x3
    80005a74:	97a6                	add	a5,a5,s1
    80005a76:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80005a7a:	fc042783          	lw	a5,-64(s0)
    80005a7e:	07e9                	addi	a5,a5,26
    80005a80:	078e                	slli	a5,a5,0x3
    80005a82:	94be                	add	s1,s1,a5
    80005a84:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    80005a88:	fd043503          	ld	a0,-48(s0)
    80005a8c:	fffff097          	auipc	ra,0xfffff
    80005a90:	a3c080e7          	jalr	-1476(ra) # 800044c8 <fileclose>
    fileclose(wf);
    80005a94:	fc843503          	ld	a0,-56(s0)
    80005a98:	fffff097          	auipc	ra,0xfffff
    80005a9c:	a30080e7          	jalr	-1488(ra) # 800044c8 <fileclose>
    return -1;
    80005aa0:	57fd                	li	a5,-1
    80005aa2:	a03d                	j	80005ad0 <sys_pipe+0xfc>
    if(fd0 >= 0)
    80005aa4:	fc442783          	lw	a5,-60(s0)
    80005aa8:	0007c763          	bltz	a5,80005ab6 <sys_pipe+0xe2>
      p->ofile[fd0] = 0;
    80005aac:	07e9                	addi	a5,a5,26
    80005aae:	078e                	slli	a5,a5,0x3
    80005ab0:	97a6                	add	a5,a5,s1
    80005ab2:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    80005ab6:	fd043503          	ld	a0,-48(s0)
    80005aba:	fffff097          	auipc	ra,0xfffff
    80005abe:	a0e080e7          	jalr	-1522(ra) # 800044c8 <fileclose>
    fileclose(wf);
    80005ac2:	fc843503          	ld	a0,-56(s0)
    80005ac6:	fffff097          	auipc	ra,0xfffff
    80005aca:	a02080e7          	jalr	-1534(ra) # 800044c8 <fileclose>
    return -1;
    80005ace:	57fd                	li	a5,-1
}
    80005ad0:	853e                	mv	a0,a5
    80005ad2:	70e2                	ld	ra,56(sp)
    80005ad4:	7442                	ld	s0,48(sp)
    80005ad6:	74a2                	ld	s1,40(sp)
    80005ad8:	6121                	addi	sp,sp,64
    80005ada:	8082                	ret
    80005adc:	0000                	unimp
	...

0000000080005ae0 <kernelvec>:
    80005ae0:	7111                	addi	sp,sp,-256
    80005ae2:	e006                	sd	ra,0(sp)
    80005ae4:	e40a                	sd	sp,8(sp)
    80005ae6:	e80e                	sd	gp,16(sp)
    80005ae8:	ec12                	sd	tp,24(sp)
    80005aea:	f016                	sd	t0,32(sp)
    80005aec:	f41a                	sd	t1,40(sp)
    80005aee:	f81e                	sd	t2,48(sp)
    80005af0:	fc22                	sd	s0,56(sp)
    80005af2:	e0a6                	sd	s1,64(sp)
    80005af4:	e4aa                	sd	a0,72(sp)
    80005af6:	e8ae                	sd	a1,80(sp)
    80005af8:	ecb2                	sd	a2,88(sp)
    80005afa:	f0b6                	sd	a3,96(sp)
    80005afc:	f4ba                	sd	a4,104(sp)
    80005afe:	f8be                	sd	a5,112(sp)
    80005b00:	fcc2                	sd	a6,120(sp)
    80005b02:	e146                	sd	a7,128(sp)
    80005b04:	e54a                	sd	s2,136(sp)
    80005b06:	e94e                	sd	s3,144(sp)
    80005b08:	ed52                	sd	s4,152(sp)
    80005b0a:	f156                	sd	s5,160(sp)
    80005b0c:	f55a                	sd	s6,168(sp)
    80005b0e:	f95e                	sd	s7,176(sp)
    80005b10:	fd62                	sd	s8,184(sp)
    80005b12:	e1e6                	sd	s9,192(sp)
    80005b14:	e5ea                	sd	s10,200(sp)
    80005b16:	e9ee                	sd	s11,208(sp)
    80005b18:	edf2                	sd	t3,216(sp)
    80005b1a:	f1f6                	sd	t4,224(sp)
    80005b1c:	f5fa                	sd	t5,232(sp)
    80005b1e:	f9fe                	sd	t6,240(sp)
    80005b20:	dfbfc0ef          	jal	ra,8000291a <kerneltrap>
    80005b24:	6082                	ld	ra,0(sp)
    80005b26:	6122                	ld	sp,8(sp)
    80005b28:	61c2                	ld	gp,16(sp)
    80005b2a:	7282                	ld	t0,32(sp)
    80005b2c:	7322                	ld	t1,40(sp)
    80005b2e:	73c2                	ld	t2,48(sp)
    80005b30:	7462                	ld	s0,56(sp)
    80005b32:	6486                	ld	s1,64(sp)
    80005b34:	6526                	ld	a0,72(sp)
    80005b36:	65c6                	ld	a1,80(sp)
    80005b38:	6666                	ld	a2,88(sp)
    80005b3a:	7686                	ld	a3,96(sp)
    80005b3c:	7726                	ld	a4,104(sp)
    80005b3e:	77c6                	ld	a5,112(sp)
    80005b40:	7866                	ld	a6,120(sp)
    80005b42:	688a                	ld	a7,128(sp)
    80005b44:	692a                	ld	s2,136(sp)
    80005b46:	69ca                	ld	s3,144(sp)
    80005b48:	6a6a                	ld	s4,152(sp)
    80005b4a:	7a8a                	ld	s5,160(sp)
    80005b4c:	7b2a                	ld	s6,168(sp)
    80005b4e:	7bca                	ld	s7,176(sp)
    80005b50:	7c6a                	ld	s8,184(sp)
    80005b52:	6c8e                	ld	s9,192(sp)
    80005b54:	6d2e                	ld	s10,200(sp)
    80005b56:	6dce                	ld	s11,208(sp)
    80005b58:	6e6e                	ld	t3,216(sp)
    80005b5a:	7e8e                	ld	t4,224(sp)
    80005b5c:	7f2e                	ld	t5,232(sp)
    80005b5e:	7fce                	ld	t6,240(sp)
    80005b60:	6111                	addi	sp,sp,256
    80005b62:	10200073          	sret
    80005b66:	00000013          	nop
    80005b6a:	00000013          	nop
    80005b6e:	0001                	nop

0000000080005b70 <timervec>:
    80005b70:	34051573          	csrrw	a0,mscratch,a0
    80005b74:	e10c                	sd	a1,0(a0)
    80005b76:	e510                	sd	a2,8(a0)
    80005b78:	e914                	sd	a3,16(a0)
    80005b7a:	6d0c                	ld	a1,24(a0)
    80005b7c:	7110                	ld	a2,32(a0)
    80005b7e:	6194                	ld	a3,0(a1)
    80005b80:	96b2                	add	a3,a3,a2
    80005b82:	e194                	sd	a3,0(a1)
    80005b84:	4589                	li	a1,2
    80005b86:	14459073          	csrw	sip,a1
    80005b8a:	6914                	ld	a3,16(a0)
    80005b8c:	6510                	ld	a2,8(a0)
    80005b8e:	610c                	ld	a1,0(a0)
    80005b90:	34051573          	csrrw	a0,mscratch,a0
    80005b94:	30200073          	mret
	...

0000000080005b9a <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    80005b9a:	1141                	addi	sp,sp,-16
    80005b9c:	e422                	sd	s0,8(sp)
    80005b9e:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80005ba0:	0c0007b7          	lui	a5,0xc000
    80005ba4:	4705                	li	a4,1
    80005ba6:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80005ba8:	c3d8                	sw	a4,4(a5)
}
    80005baa:	6422                	ld	s0,8(sp)
    80005bac:	0141                	addi	sp,sp,16
    80005bae:	8082                	ret

0000000080005bb0 <plicinithart>:

void
plicinithart(void)
{
    80005bb0:	1141                	addi	sp,sp,-16
    80005bb2:	e406                	sd	ra,8(sp)
    80005bb4:	e022                	sd	s0,0(sp)
    80005bb6:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005bb8:	ffffc097          	auipc	ra,0xffffc
    80005bbc:	de6080e7          	jalr	-538(ra) # 8000199e <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80005bc0:	0085171b          	slliw	a4,a0,0x8
    80005bc4:	0c0027b7          	lui	a5,0xc002
    80005bc8:	97ba                	add	a5,a5,a4
    80005bca:	40200713          	li	a4,1026
    80005bce:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80005bd2:	00d5151b          	slliw	a0,a0,0xd
    80005bd6:	0c2017b7          	lui	a5,0xc201
    80005bda:	97aa                	add	a5,a5,a0
    80005bdc:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
}
    80005be0:	60a2                	ld	ra,8(sp)
    80005be2:	6402                	ld	s0,0(sp)
    80005be4:	0141                	addi	sp,sp,16
    80005be6:	8082                	ret

0000000080005be8 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80005be8:	1141                	addi	sp,sp,-16
    80005bea:	e406                	sd	ra,8(sp)
    80005bec:	e022                	sd	s0,0(sp)
    80005bee:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005bf0:	ffffc097          	auipc	ra,0xffffc
    80005bf4:	dae080e7          	jalr	-594(ra) # 8000199e <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80005bf8:	00d5151b          	slliw	a0,a0,0xd
    80005bfc:	0c2017b7          	lui	a5,0xc201
    80005c00:	97aa                	add	a5,a5,a0
  return irq;
}
    80005c02:	43c8                	lw	a0,4(a5)
    80005c04:	60a2                	ld	ra,8(sp)
    80005c06:	6402                	ld	s0,0(sp)
    80005c08:	0141                	addi	sp,sp,16
    80005c0a:	8082                	ret

0000000080005c0c <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    80005c0c:	1101                	addi	sp,sp,-32
    80005c0e:	ec06                	sd	ra,24(sp)
    80005c10:	e822                	sd	s0,16(sp)
    80005c12:	e426                	sd	s1,8(sp)
    80005c14:	1000                	addi	s0,sp,32
    80005c16:	84aa                	mv	s1,a0
  int hart = cpuid();
    80005c18:	ffffc097          	auipc	ra,0xffffc
    80005c1c:	d86080e7          	jalr	-634(ra) # 8000199e <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80005c20:	00d5151b          	slliw	a0,a0,0xd
    80005c24:	0c2017b7          	lui	a5,0xc201
    80005c28:	97aa                	add	a5,a5,a0
    80005c2a:	c3c4                	sw	s1,4(a5)
}
    80005c2c:	60e2                	ld	ra,24(sp)
    80005c2e:	6442                	ld	s0,16(sp)
    80005c30:	64a2                	ld	s1,8(sp)
    80005c32:	6105                	addi	sp,sp,32
    80005c34:	8082                	ret

0000000080005c36 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80005c36:	1141                	addi	sp,sp,-16
    80005c38:	e406                	sd	ra,8(sp)
    80005c3a:	e022                	sd	s0,0(sp)
    80005c3c:	0800                	addi	s0,sp,16
  if(i >= NUM)
    80005c3e:	479d                	li	a5,7
    80005c40:	04a7cc63          	blt	a5,a0,80005c98 <free_desc+0x62>
    panic("free_desc 1");
  if(disk.free[i])
    80005c44:	0001c797          	auipc	a5,0x1c
    80005c48:	17478793          	addi	a5,a5,372 # 80021db8 <disk>
    80005c4c:	97aa                	add	a5,a5,a0
    80005c4e:	0187c783          	lbu	a5,24(a5)
    80005c52:	ebb9                	bnez	a5,80005ca8 <free_desc+0x72>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80005c54:	00451693          	slli	a3,a0,0x4
    80005c58:	0001c797          	auipc	a5,0x1c
    80005c5c:	16078793          	addi	a5,a5,352 # 80021db8 <disk>
    80005c60:	6398                	ld	a4,0(a5)
    80005c62:	9736                	add	a4,a4,a3
    80005c64:	00073023          	sd	zero,0(a4)
  disk.desc[i].len = 0;
    80005c68:	6398                	ld	a4,0(a5)
    80005c6a:	9736                	add	a4,a4,a3
    80005c6c:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    80005c70:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    80005c74:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    80005c78:	97aa                	add	a5,a5,a0
    80005c7a:	4705                	li	a4,1
    80005c7c:	00e78c23          	sb	a4,24(a5)
  wakeup(&disk.free[0]);
    80005c80:	0001c517          	auipc	a0,0x1c
    80005c84:	15050513          	addi	a0,a0,336 # 80021dd0 <disk+0x18>
    80005c88:	ffffc097          	auipc	ra,0xffffc
    80005c8c:	456080e7          	jalr	1110(ra) # 800020de <wakeup>
}
    80005c90:	60a2                	ld	ra,8(sp)
    80005c92:	6402                	ld	s0,0(sp)
    80005c94:	0141                	addi	sp,sp,16
    80005c96:	8082                	ret
    panic("free_desc 1");
    80005c98:	00003517          	auipc	a0,0x3
    80005c9c:	aa850513          	addi	a0,a0,-1368 # 80008740 <syscalls+0x2f8>
    80005ca0:	ffffb097          	auipc	ra,0xffffb
    80005ca4:	89c080e7          	jalr	-1892(ra) # 8000053c <panic>
    panic("free_desc 2");
    80005ca8:	00003517          	auipc	a0,0x3
    80005cac:	aa850513          	addi	a0,a0,-1368 # 80008750 <syscalls+0x308>
    80005cb0:	ffffb097          	auipc	ra,0xffffb
    80005cb4:	88c080e7          	jalr	-1908(ra) # 8000053c <panic>

0000000080005cb8 <virtio_disk_init>:
{
    80005cb8:	1101                	addi	sp,sp,-32
    80005cba:	ec06                	sd	ra,24(sp)
    80005cbc:	e822                	sd	s0,16(sp)
    80005cbe:	e426                	sd	s1,8(sp)
    80005cc0:	e04a                	sd	s2,0(sp)
    80005cc2:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80005cc4:	00003597          	auipc	a1,0x3
    80005cc8:	a9c58593          	addi	a1,a1,-1380 # 80008760 <syscalls+0x318>
    80005ccc:	0001c517          	auipc	a0,0x1c
    80005cd0:	21450513          	addi	a0,a0,532 # 80021ee0 <disk+0x128>
    80005cd4:	ffffb097          	auipc	ra,0xffffb
    80005cd8:	e6e080e7          	jalr	-402(ra) # 80000b42 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005cdc:	100017b7          	lui	a5,0x10001
    80005ce0:	4398                	lw	a4,0(a5)
    80005ce2:	2701                	sext.w	a4,a4
    80005ce4:	747277b7          	lui	a5,0x74727
    80005ce8:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80005cec:	14f71b63          	bne	a4,a5,80005e42 <virtio_disk_init+0x18a>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80005cf0:	100017b7          	lui	a5,0x10001
    80005cf4:	43dc                	lw	a5,4(a5)
    80005cf6:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005cf8:	4709                	li	a4,2
    80005cfa:	14e79463          	bne	a5,a4,80005e42 <virtio_disk_init+0x18a>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005cfe:	100017b7          	lui	a5,0x10001
    80005d02:	479c                	lw	a5,8(a5)
    80005d04:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80005d06:	12e79e63          	bne	a5,a4,80005e42 <virtio_disk_init+0x18a>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    80005d0a:	100017b7          	lui	a5,0x10001
    80005d0e:	47d8                	lw	a4,12(a5)
    80005d10:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005d12:	554d47b7          	lui	a5,0x554d4
    80005d16:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    80005d1a:	12f71463          	bne	a4,a5,80005e42 <virtio_disk_init+0x18a>
  *R(VIRTIO_MMIO_STATUS) = status;
    80005d1e:	100017b7          	lui	a5,0x10001
    80005d22:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    80005d26:	4705                	li	a4,1
    80005d28:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005d2a:	470d                	li	a4,3
    80005d2c:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    80005d2e:	4b98                	lw	a4,16(a5)
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80005d30:	c7ffe6b7          	lui	a3,0xc7ffe
    80005d34:	75f68693          	addi	a3,a3,1887 # ffffffffc7ffe75f <end+0xffffffff47fdc867>
    80005d38:	8f75                	and	a4,a4,a3
    80005d3a:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005d3c:	472d                	li	a4,11
    80005d3e:	dbb8                	sw	a4,112(a5)
  status = *R(VIRTIO_MMIO_STATUS);
    80005d40:	5bbc                	lw	a5,112(a5)
    80005d42:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    80005d46:	8ba1                	andi	a5,a5,8
    80005d48:	10078563          	beqz	a5,80005e52 <virtio_disk_init+0x19a>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80005d4c:	100017b7          	lui	a5,0x10001
    80005d50:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    80005d54:	43fc                	lw	a5,68(a5)
    80005d56:	2781                	sext.w	a5,a5
    80005d58:	10079563          	bnez	a5,80005e62 <virtio_disk_init+0x1aa>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80005d5c:	100017b7          	lui	a5,0x10001
    80005d60:	5bdc                	lw	a5,52(a5)
    80005d62:	2781                	sext.w	a5,a5
  if(max == 0)
    80005d64:	10078763          	beqz	a5,80005e72 <virtio_disk_init+0x1ba>
  if(max < NUM)
    80005d68:	471d                	li	a4,7
    80005d6a:	10f77c63          	bgeu	a4,a5,80005e82 <virtio_disk_init+0x1ca>
  disk.desc = kalloc();
    80005d6e:	ffffb097          	auipc	ra,0xffffb
    80005d72:	d74080e7          	jalr	-652(ra) # 80000ae2 <kalloc>
    80005d76:	0001c497          	auipc	s1,0x1c
    80005d7a:	04248493          	addi	s1,s1,66 # 80021db8 <disk>
    80005d7e:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    80005d80:	ffffb097          	auipc	ra,0xffffb
    80005d84:	d62080e7          	jalr	-670(ra) # 80000ae2 <kalloc>
    80005d88:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    80005d8a:	ffffb097          	auipc	ra,0xffffb
    80005d8e:	d58080e7          	jalr	-680(ra) # 80000ae2 <kalloc>
    80005d92:	87aa                	mv	a5,a0
    80005d94:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    80005d96:	6088                	ld	a0,0(s1)
    80005d98:	cd6d                	beqz	a0,80005e92 <virtio_disk_init+0x1da>
    80005d9a:	0001c717          	auipc	a4,0x1c
    80005d9e:	02673703          	ld	a4,38(a4) # 80021dc0 <disk+0x8>
    80005da2:	cb65                	beqz	a4,80005e92 <virtio_disk_init+0x1da>
    80005da4:	c7fd                	beqz	a5,80005e92 <virtio_disk_init+0x1da>
  memset(disk.desc, 0, PGSIZE);
    80005da6:	6605                	lui	a2,0x1
    80005da8:	4581                	li	a1,0
    80005daa:	ffffb097          	auipc	ra,0xffffb
    80005dae:	f24080e7          	jalr	-220(ra) # 80000cce <memset>
  memset(disk.avail, 0, PGSIZE);
    80005db2:	0001c497          	auipc	s1,0x1c
    80005db6:	00648493          	addi	s1,s1,6 # 80021db8 <disk>
    80005dba:	6605                	lui	a2,0x1
    80005dbc:	4581                	li	a1,0
    80005dbe:	6488                	ld	a0,8(s1)
    80005dc0:	ffffb097          	auipc	ra,0xffffb
    80005dc4:	f0e080e7          	jalr	-242(ra) # 80000cce <memset>
  memset(disk.used, 0, PGSIZE);
    80005dc8:	6605                	lui	a2,0x1
    80005dca:	4581                	li	a1,0
    80005dcc:	6888                	ld	a0,16(s1)
    80005dce:	ffffb097          	auipc	ra,0xffffb
    80005dd2:	f00080e7          	jalr	-256(ra) # 80000cce <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80005dd6:	100017b7          	lui	a5,0x10001
    80005dda:	4721                	li	a4,8
    80005ddc:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    80005dde:	4098                	lw	a4,0(s1)
    80005de0:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    80005de4:	40d8                	lw	a4,4(s1)
    80005de6:	08e7a223          	sw	a4,132(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    80005dea:	6498                	ld	a4,8(s1)
    80005dec:	0007069b          	sext.w	a3,a4
    80005df0:	08d7a823          	sw	a3,144(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    80005df4:	9701                	srai	a4,a4,0x20
    80005df6:	08e7aa23          	sw	a4,148(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    80005dfa:	6898                	ld	a4,16(s1)
    80005dfc:	0007069b          	sext.w	a3,a4
    80005e00:	0ad7a023          	sw	a3,160(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    80005e04:	9701                	srai	a4,a4,0x20
    80005e06:	0ae7a223          	sw	a4,164(a5)
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    80005e0a:	4705                	li	a4,1
    80005e0c:	c3f8                	sw	a4,68(a5)
    disk.free[i] = 1;
    80005e0e:	00e48c23          	sb	a4,24(s1)
    80005e12:	00e48ca3          	sb	a4,25(s1)
    80005e16:	00e48d23          	sb	a4,26(s1)
    80005e1a:	00e48da3          	sb	a4,27(s1)
    80005e1e:	00e48e23          	sb	a4,28(s1)
    80005e22:	00e48ea3          	sb	a4,29(s1)
    80005e26:	00e48f23          	sb	a4,30(s1)
    80005e2a:	00e48fa3          	sb	a4,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    80005e2e:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    80005e32:	0727a823          	sw	s2,112(a5)
}
    80005e36:	60e2                	ld	ra,24(sp)
    80005e38:	6442                	ld	s0,16(sp)
    80005e3a:	64a2                	ld	s1,8(sp)
    80005e3c:	6902                	ld	s2,0(sp)
    80005e3e:	6105                	addi	sp,sp,32
    80005e40:	8082                	ret
    panic("could not find virtio disk");
    80005e42:	00003517          	auipc	a0,0x3
    80005e46:	92e50513          	addi	a0,a0,-1746 # 80008770 <syscalls+0x328>
    80005e4a:	ffffa097          	auipc	ra,0xffffa
    80005e4e:	6f2080e7          	jalr	1778(ra) # 8000053c <panic>
    panic("virtio disk FEATURES_OK unset");
    80005e52:	00003517          	auipc	a0,0x3
    80005e56:	93e50513          	addi	a0,a0,-1730 # 80008790 <syscalls+0x348>
    80005e5a:	ffffa097          	auipc	ra,0xffffa
    80005e5e:	6e2080e7          	jalr	1762(ra) # 8000053c <panic>
    panic("virtio disk should not be ready");
    80005e62:	00003517          	auipc	a0,0x3
    80005e66:	94e50513          	addi	a0,a0,-1714 # 800087b0 <syscalls+0x368>
    80005e6a:	ffffa097          	auipc	ra,0xffffa
    80005e6e:	6d2080e7          	jalr	1746(ra) # 8000053c <panic>
    panic("virtio disk has no queue 0");
    80005e72:	00003517          	auipc	a0,0x3
    80005e76:	95e50513          	addi	a0,a0,-1698 # 800087d0 <syscalls+0x388>
    80005e7a:	ffffa097          	auipc	ra,0xffffa
    80005e7e:	6c2080e7          	jalr	1730(ra) # 8000053c <panic>
    panic("virtio disk max queue too short");
    80005e82:	00003517          	auipc	a0,0x3
    80005e86:	96e50513          	addi	a0,a0,-1682 # 800087f0 <syscalls+0x3a8>
    80005e8a:	ffffa097          	auipc	ra,0xffffa
    80005e8e:	6b2080e7          	jalr	1714(ra) # 8000053c <panic>
    panic("virtio disk kalloc");
    80005e92:	00003517          	auipc	a0,0x3
    80005e96:	97e50513          	addi	a0,a0,-1666 # 80008810 <syscalls+0x3c8>
    80005e9a:	ffffa097          	auipc	ra,0xffffa
    80005e9e:	6a2080e7          	jalr	1698(ra) # 8000053c <panic>

0000000080005ea2 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80005ea2:	7159                	addi	sp,sp,-112
    80005ea4:	f486                	sd	ra,104(sp)
    80005ea6:	f0a2                	sd	s0,96(sp)
    80005ea8:	eca6                	sd	s1,88(sp)
    80005eaa:	e8ca                	sd	s2,80(sp)
    80005eac:	e4ce                	sd	s3,72(sp)
    80005eae:	e0d2                	sd	s4,64(sp)
    80005eb0:	fc56                	sd	s5,56(sp)
    80005eb2:	f85a                	sd	s6,48(sp)
    80005eb4:	f45e                	sd	s7,40(sp)
    80005eb6:	f062                	sd	s8,32(sp)
    80005eb8:	ec66                	sd	s9,24(sp)
    80005eba:	e86a                	sd	s10,16(sp)
    80005ebc:	1880                	addi	s0,sp,112
    80005ebe:	8a2a                	mv	s4,a0
    80005ec0:	8bae                	mv	s7,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80005ec2:	00c52c83          	lw	s9,12(a0)
    80005ec6:	001c9c9b          	slliw	s9,s9,0x1
    80005eca:	1c82                	slli	s9,s9,0x20
    80005ecc:	020cdc93          	srli	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    80005ed0:	0001c517          	auipc	a0,0x1c
    80005ed4:	01050513          	addi	a0,a0,16 # 80021ee0 <disk+0x128>
    80005ed8:	ffffb097          	auipc	ra,0xffffb
    80005edc:	cfa080e7          	jalr	-774(ra) # 80000bd2 <acquire>
  for(int i = 0; i < 3; i++){
    80005ee0:	4901                	li	s2,0
  for(int i = 0; i < NUM; i++){
    80005ee2:	44a1                	li	s1,8
      disk.free[i] = 0;
    80005ee4:	0001cb17          	auipc	s6,0x1c
    80005ee8:	ed4b0b13          	addi	s6,s6,-300 # 80021db8 <disk>
  for(int i = 0; i < 3; i++){
    80005eec:	4a8d                	li	s5,3
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80005eee:	0001cc17          	auipc	s8,0x1c
    80005ef2:	ff2c0c13          	addi	s8,s8,-14 # 80021ee0 <disk+0x128>
    80005ef6:	a095                	j	80005f5a <virtio_disk_rw+0xb8>
      disk.free[i] = 0;
    80005ef8:	00fb0733          	add	a4,s6,a5
    80005efc:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    80005f00:	c11c                	sw	a5,0(a0)
    if(idx[i] < 0){
    80005f02:	0207c563          	bltz	a5,80005f2c <virtio_disk_rw+0x8a>
  for(int i = 0; i < 3; i++){
    80005f06:	2605                	addiw	a2,a2,1 # 1001 <_entry-0x7fffefff>
    80005f08:	0591                	addi	a1,a1,4
    80005f0a:	05560d63          	beq	a2,s5,80005f64 <virtio_disk_rw+0xc2>
    idx[i] = alloc_desc();
    80005f0e:	852e                	mv	a0,a1
  for(int i = 0; i < NUM; i++){
    80005f10:	0001c717          	auipc	a4,0x1c
    80005f14:	ea870713          	addi	a4,a4,-344 # 80021db8 <disk>
    80005f18:	87ca                	mv	a5,s2
    if(disk.free[i]){
    80005f1a:	01874683          	lbu	a3,24(a4)
    80005f1e:	fee9                	bnez	a3,80005ef8 <virtio_disk_rw+0x56>
  for(int i = 0; i < NUM; i++){
    80005f20:	2785                	addiw	a5,a5,1
    80005f22:	0705                	addi	a4,a4,1
    80005f24:	fe979be3          	bne	a5,s1,80005f1a <virtio_disk_rw+0x78>
    idx[i] = alloc_desc();
    80005f28:	57fd                	li	a5,-1
    80005f2a:	c11c                	sw	a5,0(a0)
      for(int j = 0; j < i; j++)
    80005f2c:	00c05e63          	blez	a2,80005f48 <virtio_disk_rw+0xa6>
    80005f30:	060a                	slli	a2,a2,0x2
    80005f32:	01360d33          	add	s10,a2,s3
        free_desc(idx[j]);
    80005f36:	0009a503          	lw	a0,0(s3)
    80005f3a:	00000097          	auipc	ra,0x0
    80005f3e:	cfc080e7          	jalr	-772(ra) # 80005c36 <free_desc>
      for(int j = 0; j < i; j++)
    80005f42:	0991                	addi	s3,s3,4
    80005f44:	ffa999e3          	bne	s3,s10,80005f36 <virtio_disk_rw+0x94>
    sleep(&disk.free[0], &disk.vdisk_lock);
    80005f48:	85e2                	mv	a1,s8
    80005f4a:	0001c517          	auipc	a0,0x1c
    80005f4e:	e8650513          	addi	a0,a0,-378 # 80021dd0 <disk+0x18>
    80005f52:	ffffc097          	auipc	ra,0xffffc
    80005f56:	128080e7          	jalr	296(ra) # 8000207a <sleep>
  for(int i = 0; i < 3; i++){
    80005f5a:	f9040993          	addi	s3,s0,-112
{
    80005f5e:	85ce                	mv	a1,s3
  for(int i = 0; i < 3; i++){
    80005f60:	864a                	mv	a2,s2
    80005f62:	b775                	j	80005f0e <virtio_disk_rw+0x6c>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80005f64:	f9042503          	lw	a0,-112(s0)
    80005f68:	00a50713          	addi	a4,a0,10
    80005f6c:	0712                	slli	a4,a4,0x4

  if(write)
    80005f6e:	0001c797          	auipc	a5,0x1c
    80005f72:	e4a78793          	addi	a5,a5,-438 # 80021db8 <disk>
    80005f76:	00e786b3          	add	a3,a5,a4
    80005f7a:	01703633          	snez	a2,s7
    80005f7e:	c690                	sw	a2,8(a3)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    80005f80:	0006a623          	sw	zero,12(a3)
  buf0->sector = sector;
    80005f84:	0196b823          	sd	s9,16(a3)

  disk.desc[idx[0]].addr = (uint64) buf0;
    80005f88:	f6070613          	addi	a2,a4,-160
    80005f8c:	6394                	ld	a3,0(a5)
    80005f8e:	96b2                	add	a3,a3,a2
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80005f90:	00870593          	addi	a1,a4,8
    80005f94:	95be                	add	a1,a1,a5
  disk.desc[idx[0]].addr = (uint64) buf0;
    80005f96:	e28c                	sd	a1,0(a3)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    80005f98:	0007b803          	ld	a6,0(a5)
    80005f9c:	9642                	add	a2,a2,a6
    80005f9e:	46c1                	li	a3,16
    80005fa0:	c614                	sw	a3,8(a2)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80005fa2:	4585                	li	a1,1
    80005fa4:	00b61623          	sh	a1,12(a2)
  disk.desc[idx[0]].next = idx[1];
    80005fa8:	f9442683          	lw	a3,-108(s0)
    80005fac:	00d61723          	sh	a3,14(a2)

  disk.desc[idx[1]].addr = (uint64) b->data;
    80005fb0:	0692                	slli	a3,a3,0x4
    80005fb2:	9836                	add	a6,a6,a3
    80005fb4:	058a0613          	addi	a2,s4,88
    80005fb8:	00c83023          	sd	a2,0(a6)
  disk.desc[idx[1]].len = BSIZE;
    80005fbc:	0007b803          	ld	a6,0(a5)
    80005fc0:	96c2                	add	a3,a3,a6
    80005fc2:	40000613          	li	a2,1024
    80005fc6:	c690                	sw	a2,8(a3)
  if(write)
    80005fc8:	001bb613          	seqz	a2,s7
    80005fcc:	0016161b          	slliw	a2,a2,0x1
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    80005fd0:	00166613          	ori	a2,a2,1
    80005fd4:	00c69623          	sh	a2,12(a3)
  disk.desc[idx[1]].next = idx[2];
    80005fd8:	f9842603          	lw	a2,-104(s0)
    80005fdc:	00c69723          	sh	a2,14(a3)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    80005fe0:	00250693          	addi	a3,a0,2
    80005fe4:	0692                	slli	a3,a3,0x4
    80005fe6:	96be                	add	a3,a3,a5
    80005fe8:	58fd                	li	a7,-1
    80005fea:	01168823          	sb	a7,16(a3)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    80005fee:	0612                	slli	a2,a2,0x4
    80005ff0:	9832                	add	a6,a6,a2
    80005ff2:	f9070713          	addi	a4,a4,-112
    80005ff6:	973e                	add	a4,a4,a5
    80005ff8:	00e83023          	sd	a4,0(a6)
  disk.desc[idx[2]].len = 1;
    80005ffc:	6398                	ld	a4,0(a5)
    80005ffe:	9732                	add	a4,a4,a2
    80006000:	c70c                	sw	a1,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80006002:	4609                	li	a2,2
    80006004:	00c71623          	sh	a2,12(a4)
  disk.desc[idx[2]].next = 0;
    80006008:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    8000600c:	00ba2223          	sw	a1,4(s4)
  disk.info[idx[0]].b = b;
    80006010:	0146b423          	sd	s4,8(a3)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80006014:	6794                	ld	a3,8(a5)
    80006016:	0026d703          	lhu	a4,2(a3)
    8000601a:	8b1d                	andi	a4,a4,7
    8000601c:	0706                	slli	a4,a4,0x1
    8000601e:	96ba                	add	a3,a3,a4
    80006020:	00a69223          	sh	a0,4(a3)

  __sync_synchronize();
    80006024:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80006028:	6798                	ld	a4,8(a5)
    8000602a:	00275783          	lhu	a5,2(a4)
    8000602e:	2785                	addiw	a5,a5,1
    80006030:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80006034:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80006038:	100017b7          	lui	a5,0x10001
    8000603c:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80006040:	004a2783          	lw	a5,4(s4)
    sleep(b, &disk.vdisk_lock);
    80006044:	0001c917          	auipc	s2,0x1c
    80006048:	e9c90913          	addi	s2,s2,-356 # 80021ee0 <disk+0x128>
  while(b->disk == 1) {
    8000604c:	4485                	li	s1,1
    8000604e:	00b79c63          	bne	a5,a1,80006066 <virtio_disk_rw+0x1c4>
    sleep(b, &disk.vdisk_lock);
    80006052:	85ca                	mv	a1,s2
    80006054:	8552                	mv	a0,s4
    80006056:	ffffc097          	auipc	ra,0xffffc
    8000605a:	024080e7          	jalr	36(ra) # 8000207a <sleep>
  while(b->disk == 1) {
    8000605e:	004a2783          	lw	a5,4(s4)
    80006062:	fe9788e3          	beq	a5,s1,80006052 <virtio_disk_rw+0x1b0>
  }

  disk.info[idx[0]].b = 0;
    80006066:	f9042903          	lw	s2,-112(s0)
    8000606a:	00290713          	addi	a4,s2,2
    8000606e:	0712                	slli	a4,a4,0x4
    80006070:	0001c797          	auipc	a5,0x1c
    80006074:	d4878793          	addi	a5,a5,-696 # 80021db8 <disk>
    80006078:	97ba                	add	a5,a5,a4
    8000607a:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    8000607e:	0001c997          	auipc	s3,0x1c
    80006082:	d3a98993          	addi	s3,s3,-710 # 80021db8 <disk>
    80006086:	00491713          	slli	a4,s2,0x4
    8000608a:	0009b783          	ld	a5,0(s3)
    8000608e:	97ba                	add	a5,a5,a4
    80006090:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    80006094:	854a                	mv	a0,s2
    80006096:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    8000609a:	00000097          	auipc	ra,0x0
    8000609e:	b9c080e7          	jalr	-1124(ra) # 80005c36 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    800060a2:	8885                	andi	s1,s1,1
    800060a4:	f0ed                	bnez	s1,80006086 <virtio_disk_rw+0x1e4>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    800060a6:	0001c517          	auipc	a0,0x1c
    800060aa:	e3a50513          	addi	a0,a0,-454 # 80021ee0 <disk+0x128>
    800060ae:	ffffb097          	auipc	ra,0xffffb
    800060b2:	bd8080e7          	jalr	-1064(ra) # 80000c86 <release>
}
    800060b6:	70a6                	ld	ra,104(sp)
    800060b8:	7406                	ld	s0,96(sp)
    800060ba:	64e6                	ld	s1,88(sp)
    800060bc:	6946                	ld	s2,80(sp)
    800060be:	69a6                	ld	s3,72(sp)
    800060c0:	6a06                	ld	s4,64(sp)
    800060c2:	7ae2                	ld	s5,56(sp)
    800060c4:	7b42                	ld	s6,48(sp)
    800060c6:	7ba2                	ld	s7,40(sp)
    800060c8:	7c02                	ld	s8,32(sp)
    800060ca:	6ce2                	ld	s9,24(sp)
    800060cc:	6d42                	ld	s10,16(sp)
    800060ce:	6165                	addi	sp,sp,112
    800060d0:	8082                	ret

00000000800060d2 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    800060d2:	1101                	addi	sp,sp,-32
    800060d4:	ec06                	sd	ra,24(sp)
    800060d6:	e822                	sd	s0,16(sp)
    800060d8:	e426                	sd	s1,8(sp)
    800060da:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    800060dc:	0001c497          	auipc	s1,0x1c
    800060e0:	cdc48493          	addi	s1,s1,-804 # 80021db8 <disk>
    800060e4:	0001c517          	auipc	a0,0x1c
    800060e8:	dfc50513          	addi	a0,a0,-516 # 80021ee0 <disk+0x128>
    800060ec:	ffffb097          	auipc	ra,0xffffb
    800060f0:	ae6080e7          	jalr	-1306(ra) # 80000bd2 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    800060f4:	10001737          	lui	a4,0x10001
    800060f8:	533c                	lw	a5,96(a4)
    800060fa:	8b8d                	andi	a5,a5,3
    800060fc:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    800060fe:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    80006102:	689c                	ld	a5,16(s1)
    80006104:	0204d703          	lhu	a4,32(s1)
    80006108:	0027d783          	lhu	a5,2(a5)
    8000610c:	04f70863          	beq	a4,a5,8000615c <virtio_disk_intr+0x8a>
    __sync_synchronize();
    80006110:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80006114:	6898                	ld	a4,16(s1)
    80006116:	0204d783          	lhu	a5,32(s1)
    8000611a:	8b9d                	andi	a5,a5,7
    8000611c:	078e                	slli	a5,a5,0x3
    8000611e:	97ba                	add	a5,a5,a4
    80006120:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    80006122:	00278713          	addi	a4,a5,2
    80006126:	0712                	slli	a4,a4,0x4
    80006128:	9726                	add	a4,a4,s1
    8000612a:	01074703          	lbu	a4,16(a4) # 10001010 <_entry-0x6fffeff0>
    8000612e:	e721                	bnez	a4,80006176 <virtio_disk_intr+0xa4>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80006130:	0789                	addi	a5,a5,2
    80006132:	0792                	slli	a5,a5,0x4
    80006134:	97a6                	add	a5,a5,s1
    80006136:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    80006138:	00052223          	sw	zero,4(a0)
    wakeup(b);
    8000613c:	ffffc097          	auipc	ra,0xffffc
    80006140:	fa2080e7          	jalr	-94(ra) # 800020de <wakeup>

    disk.used_idx += 1;
    80006144:	0204d783          	lhu	a5,32(s1)
    80006148:	2785                	addiw	a5,a5,1
    8000614a:	17c2                	slli	a5,a5,0x30
    8000614c:	93c1                	srli	a5,a5,0x30
    8000614e:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    80006152:	6898                	ld	a4,16(s1)
    80006154:	00275703          	lhu	a4,2(a4)
    80006158:	faf71ce3          	bne	a4,a5,80006110 <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    8000615c:	0001c517          	auipc	a0,0x1c
    80006160:	d8450513          	addi	a0,a0,-636 # 80021ee0 <disk+0x128>
    80006164:	ffffb097          	auipc	ra,0xffffb
    80006168:	b22080e7          	jalr	-1246(ra) # 80000c86 <release>
}
    8000616c:	60e2                	ld	ra,24(sp)
    8000616e:	6442                	ld	s0,16(sp)
    80006170:	64a2                	ld	s1,8(sp)
    80006172:	6105                	addi	sp,sp,32
    80006174:	8082                	ret
      panic("virtio_disk_intr status");
    80006176:	00002517          	auipc	a0,0x2
    8000617a:	6b250513          	addi	a0,a0,1714 # 80008828 <syscalls+0x3e0>
    8000617e:	ffffa097          	auipc	ra,0xffffa
    80006182:	3be080e7          	jalr	958(ra) # 8000053c <panic>

0000000080006186 <print_static_proc>:
#include "spinlock.h"
#include "proc.h"
#include "defs.h"
#include "elf.h"

void print_static_proc(char* name) {
    80006186:	1141                	addi	sp,sp,-16
    80006188:	e406                	sd	ra,8(sp)
    8000618a:	e022                	sd	s0,0(sp)
    8000618c:	0800                	addi	s0,sp,16
    8000618e:	85aa                	mv	a1,a0
    printf("Static process creation (proc: %s)\n", name);
    80006190:	00002517          	auipc	a0,0x2
    80006194:	6b050513          	addi	a0,a0,1712 # 80008840 <syscalls+0x3f8>
    80006198:	ffffa097          	auipc	ra,0xffffa
    8000619c:	3ee080e7          	jalr	1006(ra) # 80000586 <printf>
}
    800061a0:	60a2                	ld	ra,8(sp)
    800061a2:	6402                	ld	s0,0(sp)
    800061a4:	0141                	addi	sp,sp,16
    800061a6:	8082                	ret

00000000800061a8 <print_ondemand_proc>:

void print_ondemand_proc(char* name) {
    800061a8:	1141                	addi	sp,sp,-16
    800061aa:	e406                	sd	ra,8(sp)
    800061ac:	e022                	sd	s0,0(sp)
    800061ae:	0800                	addi	s0,sp,16
    800061b0:	85aa                	mv	a1,a0
    printf("Ondemand process creation (proc: %s)\n", name);
    800061b2:	00002517          	auipc	a0,0x2
    800061b6:	6b650513          	addi	a0,a0,1718 # 80008868 <syscalls+0x420>
    800061ba:	ffffa097          	auipc	ra,0xffffa
    800061be:	3cc080e7          	jalr	972(ra) # 80000586 <printf>
}
    800061c2:	60a2                	ld	ra,8(sp)
    800061c4:	6402                	ld	s0,0(sp)
    800061c6:	0141                	addi	sp,sp,16
    800061c8:	8082                	ret

00000000800061ca <print_skip_section>:

void print_skip_section(char* name, uint64 vaddr, int size) {
    800061ca:	1141                	addi	sp,sp,-16
    800061cc:	e406                	sd	ra,8(sp)
    800061ce:	e022                	sd	s0,0(sp)
    800061d0:	0800                	addi	s0,sp,16
    800061d2:	86b2                	mv	a3,a2
    printf("Skipping program section loading (proc: %s, addr: %x, size: %d)\n", 
    800061d4:	862e                	mv	a2,a1
    800061d6:	85aa                	mv	a1,a0
    800061d8:	00002517          	auipc	a0,0x2
    800061dc:	6b850513          	addi	a0,a0,1720 # 80008890 <syscalls+0x448>
    800061e0:	ffffa097          	auipc	ra,0xffffa
    800061e4:	3a6080e7          	jalr	934(ra) # 80000586 <printf>
        name, vaddr, size);
}
    800061e8:	60a2                	ld	ra,8(sp)
    800061ea:	6402                	ld	s0,0(sp)
    800061ec:	0141                	addi	sp,sp,16
    800061ee:	8082                	ret

00000000800061f0 <print_page_fault>:

void print_page_fault(char* name, uint64 vaddr) {
    800061f0:	1101                	addi	sp,sp,-32
    800061f2:	ec06                	sd	ra,24(sp)
    800061f4:	e822                	sd	s0,16(sp)
    800061f6:	e426                	sd	s1,8(sp)
    800061f8:	e04a                	sd	s2,0(sp)
    800061fa:	1000                	addi	s0,sp,32
    800061fc:	84aa                	mv	s1,a0
    800061fe:	892e                	mv	s2,a1
    printf("----------------------------------------\n");
    80006200:	00002517          	auipc	a0,0x2
    80006204:	6d850513          	addi	a0,a0,1752 # 800088d8 <syscalls+0x490>
    80006208:	ffffa097          	auipc	ra,0xffffa
    8000620c:	37e080e7          	jalr	894(ra) # 80000586 <printf>
    printf("#PF: Proc (%s), Page (%x)\n", name, vaddr);
    80006210:	864a                	mv	a2,s2
    80006212:	85a6                	mv	a1,s1
    80006214:	00002517          	auipc	a0,0x2
    80006218:	6f450513          	addi	a0,a0,1780 # 80008908 <syscalls+0x4c0>
    8000621c:	ffffa097          	auipc	ra,0xffffa
    80006220:	36a080e7          	jalr	874(ra) # 80000586 <printf>
}
    80006224:	60e2                	ld	ra,24(sp)
    80006226:	6442                	ld	s0,16(sp)
    80006228:	64a2                	ld	s1,8(sp)
    8000622a:	6902                	ld	s2,0(sp)
    8000622c:	6105                	addi	sp,sp,32
    8000622e:	8082                	ret

0000000080006230 <print_evict_page>:

void print_evict_page(uint64 vaddr, int startblock) {
    80006230:	1141                	addi	sp,sp,-16
    80006232:	e406                	sd	ra,8(sp)
    80006234:	e022                	sd	s0,0(sp)
    80006236:	0800                	addi	s0,sp,16
    80006238:	862e                	mv	a2,a1
    printf("EVICT: Page (%x) --> PSA (%d - %d)\n", vaddr, startblock, startblock+3);
    8000623a:	0035869b          	addiw	a3,a1,3
    8000623e:	85aa                	mv	a1,a0
    80006240:	00002517          	auipc	a0,0x2
    80006244:	6e850513          	addi	a0,a0,1768 # 80008928 <syscalls+0x4e0>
    80006248:	ffffa097          	auipc	ra,0xffffa
    8000624c:	33e080e7          	jalr	830(ra) # 80000586 <printf>
}
    80006250:	60a2                	ld	ra,8(sp)
    80006252:	6402                	ld	s0,0(sp)
    80006254:	0141                	addi	sp,sp,16
    80006256:	8082                	ret

0000000080006258 <print_retrieve_page>:

void print_retrieve_page(uint64 vaddr, int startblock) {
    80006258:	1141                	addi	sp,sp,-16
    8000625a:	e406                	sd	ra,8(sp)
    8000625c:	e022                	sd	s0,0(sp)
    8000625e:	0800                	addi	s0,sp,16
    80006260:	862e                	mv	a2,a1
    printf("RETRIEVE: Page (%x) --> PSA (%d - %d)\n", vaddr, startblock, startblock+3);
    80006262:	0035869b          	addiw	a3,a1,3
    80006266:	85aa                	mv	a1,a0
    80006268:	00002517          	auipc	a0,0x2
    8000626c:	6e850513          	addi	a0,a0,1768 # 80008950 <syscalls+0x508>
    80006270:	ffffa097          	auipc	ra,0xffffa
    80006274:	316080e7          	jalr	790(ra) # 80000586 <printf>
}
    80006278:	60a2                	ld	ra,8(sp)
    8000627a:	6402                	ld	s0,0(sp)
    8000627c:	0141                	addi	sp,sp,16
    8000627e:	8082                	ret

0000000080006280 <print_load_seg>:

void print_load_seg(uint64 vaddr, uint64 seg, int size) {
    80006280:	1141                	addi	sp,sp,-16
    80006282:	e406                	sd	ra,8(sp)
    80006284:	e022                	sd	s0,0(sp)
    80006286:	0800                	addi	s0,sp,16
    80006288:	86b2                	mv	a3,a2
    printf("LOAD: Addr (%x), SEG: (%x), SIZE (%d)\n", vaddr, seg, size);
    8000628a:	862e                	mv	a2,a1
    8000628c:	85aa                	mv	a1,a0
    8000628e:	00002517          	auipc	a0,0x2
    80006292:	6ea50513          	addi	a0,a0,1770 # 80008978 <syscalls+0x530>
    80006296:	ffffa097          	auipc	ra,0xffffa
    8000629a:	2f0080e7          	jalr	752(ra) # 80000586 <printf>
}
    8000629e:	60a2                	ld	ra,8(sp)
    800062a0:	6402                	ld	s0,0(sp)
    800062a2:	0141                	addi	sp,sp,16
    800062a4:	8082                	ret

00000000800062a6 <print_skip_heap_region>:

void print_skip_heap_region(char* name, uint64 vaddr, int npages) {
    800062a6:	1141                	addi	sp,sp,-16
    800062a8:	e406                	sd	ra,8(sp)
    800062aa:	e022                	sd	s0,0(sp)
    800062ac:	0800                	addi	s0,sp,16
    800062ae:	86b2                	mv	a3,a2
    printf("Skipping heap region allocation (proc: %s, addr: %x, npages: %d)\n", 
    800062b0:	862e                	mv	a2,a1
    800062b2:	85aa                	mv	a1,a0
    800062b4:	00002517          	auipc	a0,0x2
    800062b8:	6ec50513          	addi	a0,a0,1772 # 800089a0 <syscalls+0x558>
    800062bc:	ffffa097          	auipc	ra,0xffffa
    800062c0:	2ca080e7          	jalr	714(ra) # 80000586 <printf>
        name, vaddr, npages);
}
    800062c4:	60a2                	ld	ra,8(sp)
    800062c6:	6402                	ld	s0,0(sp)
    800062c8:	0141                	addi	sp,sp,16
    800062ca:	8082                	ret
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
