
bootloader/bootloader:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	00001117          	auipc	sp,0x1
    80000004:	00010113          	mv	sp,sp
    80000008:	6505                	lui	a0,0x1
    8000000a:	f14025f3          	csrr	a1,mhartid
    8000000e:	0585                	addi	a1,a1,1
    80000010:	02b50533          	mul	a0,a0,a1
    80000014:	912a                	add	sp,sp,a0
    80000016:	18a000ef          	jal	ra,800001a0 <start>

000000008000001a <spin>:
    8000001a:	a001                	j	8000001a <spin>

000000008000001c <r_vendor>:
#ifndef __ASSEMBLER__

// CSE 536: Task 2.6
static inline uint64
r_vendor()
{
    8000001c:	1101                	addi	sp,sp,-32 # 80000fe0 <find_kernel_entry_addr+0x7c2>
    8000001e:	ec22                	sd	s0,24(sp)
    80000020:	1000                	addi	s0,sp,32
  uint64 x;
  asm volatile ("csrr %0, mvendorid" : "=r" (x));
    80000022:	f11027f3          	csrr	a5,mvendorid
    80000026:	fef43423          	sd	a5,-24(s0)
  return x;
    8000002a:	fe843783          	ld	a5,-24(s0)
}
    8000002e:	853e                	mv	a0,a5
    80000030:	6462                	ld	s0,24(sp)
    80000032:	6105                	addi	sp,sp,32
    80000034:	8082                	ret

0000000080000036 <r_architecture>:
 
// CSE 536: Task 2.6
static inline uint64
r_architecture()
{
    80000036:	1101                	addi	sp,sp,-32
    80000038:	ec22                	sd	s0,24(sp)
    8000003a:	1000                	addi	s0,sp,32
  uint64 x;
  asm volatile("csrr %0, marchid" : "=r" (x) );
    8000003c:	f12027f3          	csrr	a5,marchid
    80000040:	fef43423          	sd	a5,-24(s0)
  return x;
    80000044:	fe843783          	ld	a5,-24(s0)
}
    80000048:	853e                	mv	a0,a5
    8000004a:	6462                	ld	s0,24(sp)
    8000004c:	6105                	addi	sp,sp,32
    8000004e:	8082                	ret

0000000080000050 <r_implementation>:
 
// CSE 536: Task 2.6
static inline uint64
r_implementation()
{
    80000050:	1101                	addi	sp,sp,-32
    80000052:	ec22                	sd	s0,24(sp)
    80000054:	1000                	addi	s0,sp,32
  uint64 x;
  asm volatile("csrr %0, mimpid" : "=r" (x) );
    80000056:	f13027f3          	csrr	a5,mimpid
    8000005a:	fef43423          	sd	a5,-24(s0)
  return x;
    8000005e:	fe843783          	ld	a5,-24(s0)
}
    80000062:	853e                	mv	a0,a5
    80000064:	6462                	ld	s0,24(sp)
    80000066:	6105                	addi	sp,sp,32
    80000068:	8082                	ret

000000008000006a <r_mhartid>:

// which hart (core) is this?
static inline uint64
r_mhartid()
{
    8000006a:	1101                	addi	sp,sp,-32
    8000006c:	ec22                	sd	s0,24(sp)
    8000006e:	1000                	addi	s0,sp,32
  uint64 x;
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    80000070:	f14027f3          	csrr	a5,mhartid
    80000074:	fef43423          	sd	a5,-24(s0)
  return x;
    80000078:	fe843783          	ld	a5,-24(s0)
}
    8000007c:	853e                	mv	a0,a5
    8000007e:	6462                	ld	s0,24(sp)
    80000080:	6105                	addi	sp,sp,32
    80000082:	8082                	ret

0000000080000084 <r_mstatus>:
#define MSTATUS_MPP_U (0L << 11)
#define MSTATUS_MIE (1L << 3)    // machine-mode interrupt enable.

static inline uint64
r_mstatus()
{
    80000084:	1101                	addi	sp,sp,-32
    80000086:	ec22                	sd	s0,24(sp)
    80000088:	1000                	addi	s0,sp,32
  uint64 x;
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    8000008a:	300027f3          	csrr	a5,mstatus
    8000008e:	fef43423          	sd	a5,-24(s0)
  return x;
    80000092:	fe843783          	ld	a5,-24(s0)
}
    80000096:	853e                	mv	a0,a5
    80000098:	6462                	ld	s0,24(sp)
    8000009a:	6105                	addi	sp,sp,32
    8000009c:	8082                	ret

000000008000009e <w_mstatus>:

static inline void 
w_mstatus(uint64 x)
{
    8000009e:	1101                	addi	sp,sp,-32
    800000a0:	ec22                	sd	s0,24(sp)
    800000a2:	1000                	addi	s0,sp,32
    800000a4:	fea43423          	sd	a0,-24(s0)
  asm volatile("csrw mstatus, %0" : : "r" (x));
    800000a8:	fe843783          	ld	a5,-24(s0)
    800000ac:	30079073          	csrw	mstatus,a5
}
    800000b0:	0001                	nop
    800000b2:	6462                	ld	s0,24(sp)
    800000b4:	6105                	addi	sp,sp,32
    800000b6:	8082                	ret

00000000800000b8 <w_mepc>:
// machine exception program counter, holds the
// instruction address to which a return from
// exception will go.
static inline void 
w_mepc(uint64 x)
{
    800000b8:	1101                	addi	sp,sp,-32
    800000ba:	ec22                	sd	s0,24(sp)
    800000bc:	1000                	addi	s0,sp,32
    800000be:	fea43423          	sd	a0,-24(s0)
  asm volatile("csrw mepc, %0" : : "r" (x));
    800000c2:	fe843783          	ld	a5,-24(s0)
    800000c6:	34179073          	csrw	mepc,a5
}
    800000ca:	0001                	nop
    800000cc:	6462                	ld	s0,24(sp)
    800000ce:	6105                	addi	sp,sp,32
    800000d0:	8082                	ret

00000000800000d2 <r_sie>:
#define SIE_SEIE (1L << 9) // external
#define SIE_STIE (1L << 5) // timer
#define SIE_SSIE (1L << 1) // software
static inline uint64
r_sie()
{
    800000d2:	1101                	addi	sp,sp,-32
    800000d4:	ec22                	sd	s0,24(sp)
    800000d6:	1000                	addi	s0,sp,32
  uint64 x;
  asm volatile("csrr %0, sie" : "=r" (x) );
    800000d8:	104027f3          	csrr	a5,sie
    800000dc:	fef43423          	sd	a5,-24(s0)
  return x;
    800000e0:	fe843783          	ld	a5,-24(s0)
}
    800000e4:	853e                	mv	a0,a5
    800000e6:	6462                	ld	s0,24(sp)
    800000e8:	6105                	addi	sp,sp,32
    800000ea:	8082                	ret

00000000800000ec <w_sie>:

static inline void 
w_sie(uint64 x)
{
    800000ec:	1101                	addi	sp,sp,-32
    800000ee:	ec22                	sd	s0,24(sp)
    800000f0:	1000                	addi	s0,sp,32
    800000f2:	fea43423          	sd	a0,-24(s0)
  asm volatile("csrw sie, %0" : : "r" (x));
    800000f6:	fe843783          	ld	a5,-24(s0)
    800000fa:	10479073          	csrw	sie,a5
}
    800000fe:	0001                	nop
    80000100:	6462                	ld	s0,24(sp)
    80000102:	6105                	addi	sp,sp,32
    80000104:	8082                	ret

0000000080000106 <w_medeleg>:
  return x;
}

static inline void 
w_medeleg(uint64 x)
{
    80000106:	1101                	addi	sp,sp,-32
    80000108:	ec22                	sd	s0,24(sp)
    8000010a:	1000                	addi	s0,sp,32
    8000010c:	fea43423          	sd	a0,-24(s0)
  asm volatile("csrw medeleg, %0" : : "r" (x));
    80000110:	fe843783          	ld	a5,-24(s0)
    80000114:	30279073          	csrw	medeleg,a5
}
    80000118:	0001                	nop
    8000011a:	6462                	ld	s0,24(sp)
    8000011c:	6105                	addi	sp,sp,32
    8000011e:	8082                	ret

0000000080000120 <w_mideleg>:
  return x;
}

static inline void 
w_mideleg(uint64 x)
{
    80000120:	1101                	addi	sp,sp,-32
    80000122:	ec22                	sd	s0,24(sp)
    80000124:	1000                	addi	s0,sp,32
    80000126:	fea43423          	sd	a0,-24(s0)
  asm volatile("csrw mideleg, %0" : : "r" (x));
    8000012a:	fe843783          	ld	a5,-24(s0)
    8000012e:	30379073          	csrw	mideleg,a5
}
    80000132:	0001                	nop
    80000134:	6462                	ld	s0,24(sp)
    80000136:	6105                	addi	sp,sp,32
    80000138:	8082                	ret

000000008000013a <w_pmpcfg0>:
}

// Physical Memory Protection
static inline void
w_pmpcfg0(uint64 x)
{
    8000013a:	1101                	addi	sp,sp,-32
    8000013c:	ec22                	sd	s0,24(sp)
    8000013e:	1000                	addi	s0,sp,32
    80000140:	fea43423          	sd	a0,-24(s0)
  asm volatile("csrw pmpcfg0, %0" : : "r" (x));
    80000144:	fe843783          	ld	a5,-24(s0)
    80000148:	3a079073          	csrw	pmpcfg0,a5
}
    8000014c:	0001                	nop
    8000014e:	6462                	ld	s0,24(sp)
    80000150:	6105                	addi	sp,sp,32
    80000152:	8082                	ret

0000000080000154 <w_pmpaddr0>:

static inline void
w_pmpaddr0(uint64 x)
{
    80000154:	1101                	addi	sp,sp,-32
    80000156:	ec22                	sd	s0,24(sp)
    80000158:	1000                	addi	s0,sp,32
    8000015a:	fea43423          	sd	a0,-24(s0)
  asm volatile("csrw pmpaddr0, %0" : : "r" (x));
    8000015e:	fe843783          	ld	a5,-24(s0)
    80000162:	3b079073          	csrw	pmpaddr0,a5
}
    80000166:	0001                	nop
    80000168:	6462                	ld	s0,24(sp)
    8000016a:	6105                	addi	sp,sp,32
    8000016c:	8082                	ret

000000008000016e <w_satp>:

// supervisor address translation and protection;
// holds the address of the page table.
static inline void 
w_satp(uint64 x)
{
    8000016e:	1101                	addi	sp,sp,-32
    80000170:	ec22                	sd	s0,24(sp)
    80000172:	1000                	addi	s0,sp,32
    80000174:	fea43423          	sd	a0,-24(s0)
  asm volatile("csrw satp, %0" : : "r" (x));
    80000178:	fe843783          	ld	a5,-24(s0)
    8000017c:	18079073          	csrw	satp,a5
}
    80000180:	0001                	nop
    80000182:	6462                	ld	s0,24(sp)
    80000184:	6105                	addi	sp,sp,32
    80000186:	8082                	ret

0000000080000188 <w_tp>:
  return x;
}

static inline void 
w_tp(uint64 x)
{
    80000188:	1101                	addi	sp,sp,-32
    8000018a:	ec22                	sd	s0,24(sp)
    8000018c:	1000                	addi	s0,sp,32
    8000018e:	fea43423          	sd	a0,-24(s0)
  asm volatile("mv tp, %0" : : "r" (x));
    80000192:	fe843783          	ld	a5,-24(s0)
    80000196:	823e                	mv	tp,a5
}
    80000198:	0001                	nop
    8000019a:	6462                	ld	s0,24(sp)
    8000019c:	6105                	addi	sp,sp,32
    8000019e:	8082                	ret

00000000800001a0 <start>:
extern void _entry(void);

// entry.S jumps here in machine mode on stack0.
void
start()
{
    800001a0:	715d                	addi	sp,sp,-80
    800001a2:	e486                	sd	ra,72(sp)
    800001a4:	e0a2                	sd	s0,64(sp)
    800001a6:	fc26                	sd	s1,56(sp)
    800001a8:	0880                	addi	s0,sp,80
  // keep each CPU's hartid in its tp register, for cpuid().
  int id = r_mhartid();
    800001aa:	00000097          	auipc	ra,0x0
    800001ae:	ec0080e7          	jalr	-320(ra) # 8000006a <r_mhartid>
    800001b2:	87aa                	mv	a5,a0
    800001b4:	fcf42e23          	sw	a5,-36(s0)
  w_tp(id);
    800001b8:	fdc42783          	lw	a5,-36(s0)
    800001bc:	853e                	mv	a0,a5
    800001be:	00000097          	auipc	ra,0x0
    800001c2:	fca080e7          	jalr	-54(ra) # 80000188 <w_tp>

  // set M Previous Privilege mode to Supervisor, for mret.
  unsigned long x = r_mstatus();
    800001c6:	00000097          	auipc	ra,0x0
    800001ca:	ebe080e7          	jalr	-322(ra) # 80000084 <r_mstatus>
    800001ce:	fca43823          	sd	a0,-48(s0)
  // MSTATUS_MPP_MASK 3 << 11=>   0001 1000 0000 0000 => 6144
  // Then negation           .... 1110 0111 1111 1111 ANDing it with MSTATUS
  // MSTATUS_MPP_S   1 << 11 =>   0000 1000 0000 0000 => 2048 ORing with x which is Zero and writing it to mstatus            
  x &= ~MSTATUS_MPP_MASK;
    800001d2:	fd043703          	ld	a4,-48(s0)
    800001d6:	77f9                	lui	a5,0xffffe
    800001d8:	7ff78793          	addi	a5,a5,2047 # ffffffffffffe7ff <kernel_phdr+0xffffffff7fff57ef>
    800001dc:	8ff9                	and	a5,a5,a4
    800001de:	fcf43823          	sd	a5,-48(s0)
  x |= MSTATUS_MPP_S;
    800001e2:	fd043703          	ld	a4,-48(s0)
    800001e6:	6785                	lui	a5,0x1
    800001e8:	80078793          	addi	a5,a5,-2048 # 800 <_entry-0x7ffff800>
    800001ec:	8fd9                	or	a5,a5,a4
    800001ee:	fcf43823          	sd	a5,-48(s0)
  w_mstatus(x);
    800001f2:	fd043503          	ld	a0,-48(s0)
    800001f6:	00000097          	auipc	ra,0x0
    800001fa:	ea8080e7          	jalr	-344(ra) # 8000009e <w_mstatus>

  // disable paging for now.
  w_satp(0);
    800001fe:	4501                	li	a0,0
    80000200:	00000097          	auipc	ra,0x0
    80000204:	f6e080e7          	jalr	-146(ra) # 8000016e <w_satp>

  // delegate all interrupts and exceptions to supervisor mode.
  w_medeleg(0xffff);
    80000208:	67c1                	lui	a5,0x10
    8000020a:	fff78513          	addi	a0,a5,-1 # ffff <_entry-0x7fff0001>
    8000020e:	00000097          	auipc	ra,0x0
    80000212:	ef8080e7          	jalr	-264(ra) # 80000106 <w_medeleg>
  w_mideleg(0xffff);
    80000216:	67c1                	lui	a5,0x10
    80000218:	fff78513          	addi	a0,a5,-1 # ffff <_entry-0x7fff0001>
    8000021c:	00000097          	auipc	ra,0x0
    80000220:	f04080e7          	jalr	-252(ra) # 80000120 <w_mideleg>
  w_sie(r_sie() | SIE_SEIE | SIE_STIE | SIE_SSIE);
    80000224:	00000097          	auipc	ra,0x0
    80000228:	eae080e7          	jalr	-338(ra) # 800000d2 <r_sie>
    8000022c:	87aa                	mv	a5,a0
    8000022e:	2227e793          	ori	a5,a5,546
    80000232:	853e                	mv	a0,a5
    80000234:	00000097          	auipc	ra,0x0
    80000238:	eb8080e7          	jalr	-328(ra) # 800000ec <w_sie>

  // CSE 536: Task 2.4
  //  Enable R/W/X access to all parts of the address space, 
  //  except for the upper 10 MB (0 - 117 MB) using PMP
  w_pmpaddr0(0x21D40000ull);
    8000023c:	21d40537          	lui	a0,0x21d40
    80000240:	00000097          	auipc	ra,0x0
    80000244:	f14080e7          	jalr	-236(ra) # 80000154 <w_pmpaddr0>
  w_pmpcfg0(0xf);
    80000248:	453d                	li	a0,15
    8000024a:	00000097          	auipc	ra,0x0
    8000024e:	ef0080e7          	jalr	-272(ra) # 8000013a <w_pmpcfg0>

  // CSE 536: Task 2.5
  // Load the kernel binary to its correct location
  uint64 kernel_entry_addr = 0;
    80000252:	fc043423          	sd	zero,-56(s0)
  uint64 kernel_load_addr  = 0;
    80000256:	fc043023          	sd	zero,-64(s0)
  uint64 kernel_size       = 0;
    8000025a:	fa043c23          	sd	zero,-72(s0)

  // CSE 536: Task 2.5.1
  // Find the loading address of the kernel binary
  // .text starting address
  kernel_load_addr  = find_kernel_load_addr();
    8000025e:	00000097          	auipc	ra,0x0
    80000262:	522080e7          	jalr	1314(ra) # 80000780 <find_kernel_load_addr>
    80000266:	fca43023          	sd	a0,-64(s0)

  // CSE 536: Task 2.5.2
  // Find the kernel binary size and copy it to the load address
  // Total file size
  kernel_size       = find_kernel_size();
    8000026a:	00000097          	auipc	ra,0x0
    8000026e:	570080e7          	jalr	1392(ra) # 800007da <find_kernel_size>
    80000272:	faa43c23          	sd	a0,-72(s0)
  // Copying without headers
  // write into kernel_load_addr = entry header of xv6, reading from kernel's .text = RAMDISK + 4096
  memmove((int *)kernel_load_addr,(int *)(RAMDISK + 4096), kernel_size - 4096);
    80000276:	fc043683          	ld	a3,-64(s0)
    8000027a:	fb843783          	ld	a5,-72(s0)
    8000027e:	0007871b          	sext.w	a4,a5
    80000282:	77fd                	lui	a5,0xfffff
    80000284:	9fb9                	addw	a5,a5,a4
    80000286:	2781                	sext.w	a5,a5
    80000288:	863e                	mv	a2,a5
    8000028a:	000847b7          	lui	a5,0x84
    8000028e:	0785                	addi	a5,a5,1 # 84001 <_entry-0x7ff7bfff>
    80000290:	00c79593          	slli	a1,a5,0xc
    80000294:	8536                	mv	a0,a3
    80000296:	00000097          	auipc	ra,0x0
    8000029a:	218080e7          	jalr	536(ra) # 800004ae <memmove>
  
  // CSE 536: Task 2.5.34096
  // Find the entry address and write it to mepc
  kernel_entry_addr = find_kernel_entry_addr();
    8000029e:	00000097          	auipc	ra,0x0
    800002a2:	580080e7          	jalr	1408(ra) # 8000081e <find_kernel_entry_addr>
    800002a6:	fca43423          	sd	a0,-56(s0)

  w_mepc(kernel_entry_addr);
    800002aa:	fc843503          	ld	a0,-56(s0)
    800002ae:	00000097          	auipc	ra,0x0
    800002b2:	e0a080e7          	jalr	-502(ra) # 800000b8 <w_mepc>
  
  // CSE 536: Task 2.6
  // Provide system information to the kernel
  sys_info_ptr = (struct sys_info *)0x80080000;
    800002b6:	00009797          	auipc	a5,0x9
    800002ba:	d4a78793          	addi	a5,a5,-694 # 80009000 <sys_info_ptr>
    800002be:	01001737          	lui	a4,0x1001
    800002c2:	071e                	slli	a4,a4,0x7
    800002c4:	e398                	sd	a4,0(a5)
  // Info collected from CPU registers
  sys_info_ptr->vendor = r_vendor();
    800002c6:	00009797          	auipc	a5,0x9
    800002ca:	d3a78793          	addi	a5,a5,-710 # 80009000 <sys_info_ptr>
    800002ce:	6384                	ld	s1,0(a5)
    800002d0:	00000097          	auipc	ra,0x0
    800002d4:	d4c080e7          	jalr	-692(ra) # 8000001c <r_vendor>
    800002d8:	87aa                	mv	a5,a0
    800002da:	e09c                	sd	a5,0(s1)
  sys_info_ptr->arch = r_architecture();
    800002dc:	00009797          	auipc	a5,0x9
    800002e0:	d2478793          	addi	a5,a5,-732 # 80009000 <sys_info_ptr>
    800002e4:	6384                	ld	s1,0(a5)
    800002e6:	00000097          	auipc	ra,0x0
    800002ea:	d50080e7          	jalr	-688(ra) # 80000036 <r_architecture>
    800002ee:	87aa                	mv	a5,a0
    800002f0:	e49c                	sd	a5,8(s1)
  sys_info_ptr->impl = r_implementation();
    800002f2:	00009797          	auipc	a5,0x9
    800002f6:	d0e78793          	addi	a5,a5,-754 # 80009000 <sys_info_ptr>
    800002fa:	6384                	ld	s1,0(a5)
    800002fc:	00000097          	auipc	ra,0x0
    80000300:	d54080e7          	jalr	-684(ra) # 80000050 <r_implementation>
    80000304:	87aa                	mv	a5,a0
    80000306:	e89c                	sd	a5,16(s1)
  // Info collected from Bootloader binary addresses
  sys_info_ptr->bl_start = 0x80000000;
    80000308:	00009797          	auipc	a5,0x9
    8000030c:	cf878793          	addi	a5,a5,-776 # 80009000 <sys_info_ptr>
    80000310:	639c                	ld	a5,0(a5)
    80000312:	4705                	li	a4,1
    80000314:	077e                	slli	a4,a4,0x1f
    80000316:	ef98                	sd	a4,24(a5)
  sys_info_ptr->bl_end = end;
    80000318:	00009797          	auipc	a5,0x9
    8000031c:	ce878793          	addi	a5,a5,-792 # 80009000 <sys_info_ptr>
    80000320:	639c                	ld	a5,0(a5)
    80000322:	00009717          	auipc	a4,0x9
    80000326:	cde70713          	addi	a4,a4,-802 # 80009000 <sys_info_ptr>
    8000032a:	6318                	ld	a4,0(a4)
    8000032c:	f398                	sd	a4,32(a5)
  // // Accessible DRAM addresses //  except for the upper 10 MB (0 - 117 MB)
  sys_info_ptr->dr_start = 0x80000000;
    8000032e:	00009797          	auipc	a5,0x9
    80000332:	cd278793          	addi	a5,a5,-814 # 80009000 <sys_info_ptr>
    80000336:	639c                	ld	a5,0(a5)
    80000338:	4705                	li	a4,1
    8000033a:	077e                	slli	a4,a4,0x1f
    8000033c:	f798                	sd	a4,40(a5)
  // //(KERNBASE + 128*1024*1024) = 2270167040 which is 0x87500000
  sys_info_ptr->dr_end =  PHYSTOP;
    8000033e:	00009797          	auipc	a5,0x9
    80000342:	cc278793          	addi	a5,a5,-830 # 80009000 <sys_info_ptr>
    80000346:	639c                	ld	a5,0(a5)
    80000348:	4745                	li	a4,17
    8000034a:	076e                	slli	a4,a4,0x1b
    8000034c:	fb98                	sd	a4,48(a5)
  // CSE 536: Task 2.5.3
  // switch to supervisor mode and jum0x87600000p to main().
  // Jump to the OS kernel code
  asm volatile("mret");
    8000034e:	30200073          	mret
    80000352:	0001                	nop
    80000354:	60a6                	ld	ra,72(sp)
    80000356:	6406                	ld	s0,64(sp)
    80000358:	74e2                	ld	s1,56(sp)
    8000035a:	6161                	addi	sp,sp,80
    8000035c:	8082                	ret

000000008000035e <kernel_copy>:

// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
kernel_copy(struct buf *b)
{
    8000035e:	7179                	addi	sp,sp,-48
    80000360:	f406                	sd	ra,40(sp)
    80000362:	f022                	sd	s0,32(sp)
    80000364:	1800                	addi	s0,sp,48
    80000366:	fca43c23          	sd	a0,-40(s0)
  /* Ramdisk is not even reading from the damn file.. */
  if(b->blockno >= FSSIZE)
    8000036a:	fd843783          	ld	a5,-40(s0)
    8000036e:	47dc                	lw	a5,12(a5)
    80000370:	873e                	mv	a4,a5
    80000372:	7cf00793          	li	a5,1999
    80000376:	00e7f663          	bgeu	a5,a4,80000382 <kernel_copy+0x24>
    spin();
    8000037a:	00000097          	auipc	ra,0x0
    8000037e:	ca0080e7          	jalr	-864(ra) # 8000001a <spin>

  uint64 diskaddr = b->blockno * BSIZE;
    80000382:	fd843783          	ld	a5,-40(s0)
    80000386:	47dc                	lw	a5,12(a5)
    80000388:	00a7979b          	slliw	a5,a5,0xa
    8000038c:	2781                	sext.w	a5,a5
    8000038e:	1782                	slli	a5,a5,0x20
    80000390:	9381                	srli	a5,a5,0x20
    80000392:	fef43423          	sd	a5,-24(s0)
  char *addr = (char *)RAMDISK + diskaddr;
    80000396:	fe843703          	ld	a4,-24(s0)
    8000039a:	02100793          	li	a5,33
    8000039e:	07ea                	slli	a5,a5,0x1a
    800003a0:	97ba                	add	a5,a5,a4
    800003a2:	fef43023          	sd	a5,-32(s0)

  // read from the location
  memmove(b->data, addr, BSIZE);
    800003a6:	fd843783          	ld	a5,-40(s0)
    800003aa:	02878793          	addi	a5,a5,40
    800003ae:	40000613          	li	a2,1024
    800003b2:	fe043583          	ld	a1,-32(s0)
    800003b6:	853e                	mv	a0,a5
    800003b8:	00000097          	auipc	ra,0x0
    800003bc:	0f6080e7          	jalr	246(ra) # 800004ae <memmove>
    800003c0:	0001                	nop
    800003c2:	70a2                	ld	ra,40(sp)
    800003c4:	7402                	ld	s0,32(sp)
    800003c6:	6145                	addi	sp,sp,48
    800003c8:	8082                	ret

00000000800003ca <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    800003ca:	7179                	addi	sp,sp,-48
    800003cc:	f422                	sd	s0,40(sp)
    800003ce:	1800                	addi	s0,sp,48
    800003d0:	fca43c23          	sd	a0,-40(s0)
    800003d4:	87ae                	mv	a5,a1
    800003d6:	8732                	mv	a4,a2
    800003d8:	fcf42a23          	sw	a5,-44(s0)
    800003dc:	87ba                	mv	a5,a4
    800003de:	fcf42823          	sw	a5,-48(s0)
  char *cdst = (char *) dst;
    800003e2:	fd843783          	ld	a5,-40(s0)
    800003e6:	fef43023          	sd	a5,-32(s0)
  int i;
  for(i = 0; i < n; i++){
    800003ea:	fe042623          	sw	zero,-20(s0)
    800003ee:	a00d                	j	80000410 <memset+0x46>
    cdst[i] = c;
    800003f0:	fec42783          	lw	a5,-20(s0)
    800003f4:	fe043703          	ld	a4,-32(s0)
    800003f8:	97ba                	add	a5,a5,a4
    800003fa:	fd442703          	lw	a4,-44(s0)
    800003fe:	0ff77713          	zext.b	a4,a4
    80000402:	00e78023          	sb	a4,0(a5)
  for(i = 0; i < n; i++){
    80000406:	fec42783          	lw	a5,-20(s0)
    8000040a:	2785                	addiw	a5,a5,1
    8000040c:	fef42623          	sw	a5,-20(s0)
    80000410:	fec42703          	lw	a4,-20(s0)
    80000414:	fd042783          	lw	a5,-48(s0)
    80000418:	2781                	sext.w	a5,a5
    8000041a:	fcf76be3          	bltu	a4,a5,800003f0 <memset+0x26>
  }
  return dst;
    8000041e:	fd843783          	ld	a5,-40(s0)
}
    80000422:	853e                	mv	a0,a5
    80000424:	7422                	ld	s0,40(sp)
    80000426:	6145                	addi	sp,sp,48
    80000428:	8082                	ret

000000008000042a <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    8000042a:	7139                	addi	sp,sp,-64
    8000042c:	fc22                	sd	s0,56(sp)
    8000042e:	0080                	addi	s0,sp,64
    80000430:	fca43c23          	sd	a0,-40(s0)
    80000434:	fcb43823          	sd	a1,-48(s0)
    80000438:	87b2                	mv	a5,a2
    8000043a:	fcf42623          	sw	a5,-52(s0)
  const uchar *s1, *s2;

  s1 = v1;
    8000043e:	fd843783          	ld	a5,-40(s0)
    80000442:	fef43423          	sd	a5,-24(s0)
  s2 = v2;
    80000446:	fd043783          	ld	a5,-48(s0)
    8000044a:	fef43023          	sd	a5,-32(s0)
  while(n-- > 0){
    8000044e:	a0a1                	j	80000496 <memcmp+0x6c>
    if(*s1 != *s2)
    80000450:	fe843783          	ld	a5,-24(s0)
    80000454:	0007c703          	lbu	a4,0(a5)
    80000458:	fe043783          	ld	a5,-32(s0)
    8000045c:	0007c783          	lbu	a5,0(a5)
    80000460:	02f70163          	beq	a4,a5,80000482 <memcmp+0x58>
      return *s1 - *s2;
    80000464:	fe843783          	ld	a5,-24(s0)
    80000468:	0007c783          	lbu	a5,0(a5)
    8000046c:	0007871b          	sext.w	a4,a5
    80000470:	fe043783          	ld	a5,-32(s0)
    80000474:	0007c783          	lbu	a5,0(a5)
    80000478:	2781                	sext.w	a5,a5
    8000047a:	40f707bb          	subw	a5,a4,a5
    8000047e:	2781                	sext.w	a5,a5
    80000480:	a01d                	j	800004a6 <memcmp+0x7c>
    s1++, s2++;
    80000482:	fe843783          	ld	a5,-24(s0)
    80000486:	0785                	addi	a5,a5,1
    80000488:	fef43423          	sd	a5,-24(s0)
    8000048c:	fe043783          	ld	a5,-32(s0)
    80000490:	0785                	addi	a5,a5,1
    80000492:	fef43023          	sd	a5,-32(s0)
  while(n-- > 0){
    80000496:	fcc42783          	lw	a5,-52(s0)
    8000049a:	fff7871b          	addiw	a4,a5,-1
    8000049e:	fce42623          	sw	a4,-52(s0)
    800004a2:	f7dd                	bnez	a5,80000450 <memcmp+0x26>
  }

  return 0;
    800004a4:	4781                	li	a5,0
}
    800004a6:	853e                	mv	a0,a5
    800004a8:	7462                	ld	s0,56(sp)
    800004aa:	6121                	addi	sp,sp,64
    800004ac:	8082                	ret

00000000800004ae <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    800004ae:	7139                	addi	sp,sp,-64
    800004b0:	fc22                	sd	s0,56(sp)
    800004b2:	0080                	addi	s0,sp,64
    800004b4:	fca43c23          	sd	a0,-40(s0)
    800004b8:	fcb43823          	sd	a1,-48(s0)
    800004bc:	87b2                	mv	a5,a2
    800004be:	fcf42623          	sw	a5,-52(s0)
  const char *s;
  char *d;

  if(n == 0)
    800004c2:	fcc42783          	lw	a5,-52(s0)
    800004c6:	2781                	sext.w	a5,a5
    800004c8:	e781                	bnez	a5,800004d0 <memmove+0x22>
    return dst;
    800004ca:	fd843783          	ld	a5,-40(s0)
    800004ce:	a855                	j	80000582 <memmove+0xd4>
  
  s = src;
    800004d0:	fd043783          	ld	a5,-48(s0)
    800004d4:	fef43423          	sd	a5,-24(s0)
  d = dst;
    800004d8:	fd843783          	ld	a5,-40(s0)
    800004dc:	fef43023          	sd	a5,-32(s0)
  if(s < d && s + n > d){
    800004e0:	fe843703          	ld	a4,-24(s0)
    800004e4:	fe043783          	ld	a5,-32(s0)
    800004e8:	08f77463          	bgeu	a4,a5,80000570 <memmove+0xc2>
    800004ec:	fcc46783          	lwu	a5,-52(s0)
    800004f0:	fe843703          	ld	a4,-24(s0)
    800004f4:	97ba                	add	a5,a5,a4
    800004f6:	fe043703          	ld	a4,-32(s0)
    800004fa:	06f77b63          	bgeu	a4,a5,80000570 <memmove+0xc2>
    s += n;
    800004fe:	fcc46783          	lwu	a5,-52(s0)
    80000502:	fe843703          	ld	a4,-24(s0)
    80000506:	97ba                	add	a5,a5,a4
    80000508:	fef43423          	sd	a5,-24(s0)
    d += n;
    8000050c:	fcc46783          	lwu	a5,-52(s0)
    80000510:	fe043703          	ld	a4,-32(s0)
    80000514:	97ba                	add	a5,a5,a4
    80000516:	fef43023          	sd	a5,-32(s0)
    while(n-- > 0)
    8000051a:	a01d                	j	80000540 <memmove+0x92>
      *--d = *--s;
    8000051c:	fe843783          	ld	a5,-24(s0)
    80000520:	17fd                	addi	a5,a5,-1
    80000522:	fef43423          	sd	a5,-24(s0)
    80000526:	fe043783          	ld	a5,-32(s0)
    8000052a:	17fd                	addi	a5,a5,-1
    8000052c:	fef43023          	sd	a5,-32(s0)
    80000530:	fe843783          	ld	a5,-24(s0)
    80000534:	0007c703          	lbu	a4,0(a5)
    80000538:	fe043783          	ld	a5,-32(s0)
    8000053c:	00e78023          	sb	a4,0(a5)
    while(n-- > 0)
    80000540:	fcc42783          	lw	a5,-52(s0)
    80000544:	fff7871b          	addiw	a4,a5,-1
    80000548:	fce42623          	sw	a4,-52(s0)
    8000054c:	fbe1                	bnez	a5,8000051c <memmove+0x6e>
  if(s < d && s + n > d){
    8000054e:	a805                	j	8000057e <memmove+0xd0>
  } else
    while(n-- > 0)
      *d++ = *s++;
    80000550:	fe843703          	ld	a4,-24(s0)
    80000554:	00170793          	addi	a5,a4,1
    80000558:	fef43423          	sd	a5,-24(s0)
    8000055c:	fe043783          	ld	a5,-32(s0)
    80000560:	00178693          	addi	a3,a5,1
    80000564:	fed43023          	sd	a3,-32(s0)
    80000568:	00074703          	lbu	a4,0(a4)
    8000056c:	00e78023          	sb	a4,0(a5)
    while(n-- > 0)
    80000570:	fcc42783          	lw	a5,-52(s0)
    80000574:	fff7871b          	addiw	a4,a5,-1
    80000578:	fce42623          	sw	a4,-52(s0)
    8000057c:	fbf1                	bnez	a5,80000550 <memmove+0xa2>

  return dst;
    8000057e:	fd843783          	ld	a5,-40(s0)
}
    80000582:	853e                	mv	a0,a5
    80000584:	7462                	ld	s0,56(sp)
    80000586:	6121                	addi	sp,sp,64
    80000588:	8082                	ret

000000008000058a <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    8000058a:	7179                	addi	sp,sp,-48
    8000058c:	f406                	sd	ra,40(sp)
    8000058e:	f022                	sd	s0,32(sp)
    80000590:	1800                	addi	s0,sp,48
    80000592:	fea43423          	sd	a0,-24(s0)
    80000596:	feb43023          	sd	a1,-32(s0)
    8000059a:	87b2                	mv	a5,a2
    8000059c:	fcf42e23          	sw	a5,-36(s0)
  return memmove(dst, src, n);
    800005a0:	fdc42783          	lw	a5,-36(s0)
    800005a4:	863e                	mv	a2,a5
    800005a6:	fe043583          	ld	a1,-32(s0)
    800005aa:	fe843503          	ld	a0,-24(s0)
    800005ae:	00000097          	auipc	ra,0x0
    800005b2:	f00080e7          	jalr	-256(ra) # 800004ae <memmove>
    800005b6:	87aa                	mv	a5,a0
}
    800005b8:	853e                	mv	a0,a5
    800005ba:	70a2                	ld	ra,40(sp)
    800005bc:	7402                	ld	s0,32(sp)
    800005be:	6145                	addi	sp,sp,48
    800005c0:	8082                	ret

00000000800005c2 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    800005c2:	7179                	addi	sp,sp,-48
    800005c4:	f422                	sd	s0,40(sp)
    800005c6:	1800                	addi	s0,sp,48
    800005c8:	fea43423          	sd	a0,-24(s0)
    800005cc:	feb43023          	sd	a1,-32(s0)
    800005d0:	87b2                	mv	a5,a2
    800005d2:	fcf42e23          	sw	a5,-36(s0)
  while(n > 0 && *p && *p == *q)
    800005d6:	a005                	j	800005f6 <strncmp+0x34>
    n--, p++, q++;
    800005d8:	fdc42783          	lw	a5,-36(s0)
    800005dc:	37fd                	addiw	a5,a5,-1
    800005de:	fcf42e23          	sw	a5,-36(s0)
    800005e2:	fe843783          	ld	a5,-24(s0)
    800005e6:	0785                	addi	a5,a5,1
    800005e8:	fef43423          	sd	a5,-24(s0)
    800005ec:	fe043783          	ld	a5,-32(s0)
    800005f0:	0785                	addi	a5,a5,1
    800005f2:	fef43023          	sd	a5,-32(s0)
  while(n > 0 && *p && *p == *q)
    800005f6:	fdc42783          	lw	a5,-36(s0)
    800005fa:	2781                	sext.w	a5,a5
    800005fc:	c385                	beqz	a5,8000061c <strncmp+0x5a>
    800005fe:	fe843783          	ld	a5,-24(s0)
    80000602:	0007c783          	lbu	a5,0(a5)
    80000606:	cb99                	beqz	a5,8000061c <strncmp+0x5a>
    80000608:	fe843783          	ld	a5,-24(s0)
    8000060c:	0007c703          	lbu	a4,0(a5)
    80000610:	fe043783          	ld	a5,-32(s0)
    80000614:	0007c783          	lbu	a5,0(a5)
    80000618:	fcf700e3          	beq	a4,a5,800005d8 <strncmp+0x16>
  if(n == 0)
    8000061c:	fdc42783          	lw	a5,-36(s0)
    80000620:	2781                	sext.w	a5,a5
    80000622:	e399                	bnez	a5,80000628 <strncmp+0x66>
    return 0;
    80000624:	4781                	li	a5,0
    80000626:	a839                	j	80000644 <strncmp+0x82>
  return (uchar)*p - (uchar)*q;
    80000628:	fe843783          	ld	a5,-24(s0)
    8000062c:	0007c783          	lbu	a5,0(a5)
    80000630:	0007871b          	sext.w	a4,a5
    80000634:	fe043783          	ld	a5,-32(s0)
    80000638:	0007c783          	lbu	a5,0(a5)
    8000063c:	2781                	sext.w	a5,a5
    8000063e:	40f707bb          	subw	a5,a4,a5
    80000642:	2781                	sext.w	a5,a5
}
    80000644:	853e                	mv	a0,a5
    80000646:	7422                	ld	s0,40(sp)
    80000648:	6145                	addi	sp,sp,48
    8000064a:	8082                	ret

000000008000064c <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    8000064c:	7139                	addi	sp,sp,-64
    8000064e:	fc22                	sd	s0,56(sp)
    80000650:	0080                	addi	s0,sp,64
    80000652:	fca43c23          	sd	a0,-40(s0)
    80000656:	fcb43823          	sd	a1,-48(s0)
    8000065a:	87b2                	mv	a5,a2
    8000065c:	fcf42623          	sw	a5,-52(s0)
  char *os;

  os = s;
    80000660:	fd843783          	ld	a5,-40(s0)
    80000664:	fef43423          	sd	a5,-24(s0)
  while(n-- > 0 && (*s++ = *t++) != 0)
    80000668:	0001                	nop
    8000066a:	fcc42783          	lw	a5,-52(s0)
    8000066e:	fff7871b          	addiw	a4,a5,-1
    80000672:	fce42623          	sw	a4,-52(s0)
    80000676:	02f05e63          	blez	a5,800006b2 <strncpy+0x66>
    8000067a:	fd043703          	ld	a4,-48(s0)
    8000067e:	00170793          	addi	a5,a4,1
    80000682:	fcf43823          	sd	a5,-48(s0)
    80000686:	fd843783          	ld	a5,-40(s0)
    8000068a:	00178693          	addi	a3,a5,1
    8000068e:	fcd43c23          	sd	a3,-40(s0)
    80000692:	00074703          	lbu	a4,0(a4)
    80000696:	00e78023          	sb	a4,0(a5)
    8000069a:	0007c783          	lbu	a5,0(a5)
    8000069e:	f7f1                	bnez	a5,8000066a <strncpy+0x1e>
    ;
  while(n-- > 0)
    800006a0:	a809                	j	800006b2 <strncpy+0x66>
    *s++ = 0;
    800006a2:	fd843783          	ld	a5,-40(s0)
    800006a6:	00178713          	addi	a4,a5,1
    800006aa:	fce43c23          	sd	a4,-40(s0)
    800006ae:	00078023          	sb	zero,0(a5)
  while(n-- > 0)
    800006b2:	fcc42783          	lw	a5,-52(s0)
    800006b6:	fff7871b          	addiw	a4,a5,-1
    800006ba:	fce42623          	sw	a4,-52(s0)
    800006be:	fef042e3          	bgtz	a5,800006a2 <strncpy+0x56>
  return os;
    800006c2:	fe843783          	ld	a5,-24(s0)
}
    800006c6:	853e                	mv	a0,a5
    800006c8:	7462                	ld	s0,56(sp)
    800006ca:	6121                	addi	sp,sp,64
    800006cc:	8082                	ret

00000000800006ce <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    800006ce:	7139                	addi	sp,sp,-64
    800006d0:	fc22                	sd	s0,56(sp)
    800006d2:	0080                	addi	s0,sp,64
    800006d4:	fca43c23          	sd	a0,-40(s0)
    800006d8:	fcb43823          	sd	a1,-48(s0)
    800006dc:	87b2                	mv	a5,a2
    800006de:	fcf42623          	sw	a5,-52(s0)
  char *os;

  os = s;
    800006e2:	fd843783          	ld	a5,-40(s0)
    800006e6:	fef43423          	sd	a5,-24(s0)
  if(n <= 0)
    800006ea:	fcc42783          	lw	a5,-52(s0)
    800006ee:	2781                	sext.w	a5,a5
    800006f0:	00f04563          	bgtz	a5,800006fa <safestrcpy+0x2c>
    return os;
    800006f4:	fe843783          	ld	a5,-24(s0)
    800006f8:	a0a9                	j	80000742 <safestrcpy+0x74>
  while(--n > 0 && (*s++ = *t++) != 0)
    800006fa:	0001                	nop
    800006fc:	fcc42783          	lw	a5,-52(s0)
    80000700:	37fd                	addiw	a5,a5,-1
    80000702:	fcf42623          	sw	a5,-52(s0)
    80000706:	fcc42783          	lw	a5,-52(s0)
    8000070a:	2781                	sext.w	a5,a5
    8000070c:	02f05563          	blez	a5,80000736 <safestrcpy+0x68>
    80000710:	fd043703          	ld	a4,-48(s0)
    80000714:	00170793          	addi	a5,a4,1
    80000718:	fcf43823          	sd	a5,-48(s0)
    8000071c:	fd843783          	ld	a5,-40(s0)
    80000720:	00178693          	addi	a3,a5,1
    80000724:	fcd43c23          	sd	a3,-40(s0)
    80000728:	00074703          	lbu	a4,0(a4)
    8000072c:	00e78023          	sb	a4,0(a5)
    80000730:	0007c783          	lbu	a5,0(a5)
    80000734:	f7e1                	bnez	a5,800006fc <safestrcpy+0x2e>
    ;
  *s = 0;
    80000736:	fd843783          	ld	a5,-40(s0)
    8000073a:	00078023          	sb	zero,0(a5)
  return os;
    8000073e:	fe843783          	ld	a5,-24(s0)
}
    80000742:	853e                	mv	a0,a5
    80000744:	7462                	ld	s0,56(sp)
    80000746:	6121                	addi	sp,sp,64
    80000748:	8082                	ret

000000008000074a <strlen>:

int
strlen(const char *s)
{
    8000074a:	7179                	addi	sp,sp,-48
    8000074c:	f422                	sd	s0,40(sp)
    8000074e:	1800                	addi	s0,sp,48
    80000750:	fca43c23          	sd	a0,-40(s0)
  int n;

  for(n = 0; s[n]; n++)
    80000754:	fe042623          	sw	zero,-20(s0)
    80000758:	a031                	j	80000764 <strlen+0x1a>
    8000075a:	fec42783          	lw	a5,-20(s0)
    8000075e:	2785                	addiw	a5,a5,1
    80000760:	fef42623          	sw	a5,-20(s0)
    80000764:	fec42783          	lw	a5,-20(s0)
    80000768:	fd843703          	ld	a4,-40(s0)
    8000076c:	97ba                	add	a5,a5,a4
    8000076e:	0007c783          	lbu	a5,0(a5)
    80000772:	f7e5                	bnez	a5,8000075a <strlen+0x10>
    ;
  return n;
    80000774:	fec42783          	lw	a5,-20(s0)
}
    80000778:	853e                	mv	a0,a5
    8000077a:	7422                	ld	s0,40(sp)
    8000077c:	6145                	addi	sp,sp,48
    8000077e:	8082                	ret

0000000080000780 <find_kernel_load_addr>:
#include <stdbool.h>

struct elfhdr* kernel_elfhdr;
struct proghdr* kernel_phdr;

uint64 find_kernel_load_addr(void) {
    80000780:	1141                	addi	sp,sp,-16
    80000782:	e422                	sd	s0,8(sp)
    80000784:	0800                	addi	s0,sp,16
    // CSE 536: task 2.5.1
    //Initializing elfhdr struct (elfhdr) to RAMDISK (where the kernel is currently loaded)
    kernel_elfhdr = RAMDISK;
    80000786:	00009797          	auipc	a5,0x9
    8000078a:	88278793          	addi	a5,a5,-1918 # 80009008 <kernel_elfhdr>
    8000078e:	02100713          	li	a4,33
    80000792:	076a                	slli	a4,a4,0x1a
    80000794:	e398                	sd	a4,0(a5)
    //Initializing proghdr struct (proghdr) to RAMDISK + phoff + phentsize
    kernel_phdr = RAMDISK + (*kernel_elfhdr).phoff + (*kernel_elfhdr).phentsize;
    80000796:	00009797          	auipc	a5,0x9
    8000079a:	87278793          	addi	a5,a5,-1934 # 80009008 <kernel_elfhdr>
    8000079e:	639c                	ld	a5,0(a5)
    800007a0:	739c                	ld	a5,32(a5)
    800007a2:	00009717          	auipc	a4,0x9
    800007a6:	86670713          	addi	a4,a4,-1946 # 80009008 <kernel_elfhdr>
    800007aa:	6318                	ld	a4,0(a4)
    800007ac:	03675703          	lhu	a4,54(a4)
    800007b0:	973e                	add	a4,a4,a5
    800007b2:	02100793          	li	a5,33
    800007b6:	07ea                	slli	a5,a5,0x1a
    800007b8:	97ba                	add	a5,a5,a4
    800007ba:	873e                	mv	a4,a5
    800007bc:	00009797          	auipc	a5,0x9
    800007c0:	85478793          	addi	a5,a5,-1964 # 80009010 <kernel_phdr>
    800007c4:	e398                	sd	a4,0(a5)
    //Returning starting address of the .text section by retrieving the vaddr field within proghdr
    return (*kernel_phdr).vaddr;
    800007c6:	00009797          	auipc	a5,0x9
    800007ca:	84a78793          	addi	a5,a5,-1974 # 80009010 <kernel_phdr>
    800007ce:	639c                	ld	a5,0(a5)
    800007d0:	6b9c                	ld	a5,16(a5)
}
    800007d2:	853e                	mv	a0,a5
    800007d4:	6422                	ld	s0,8(sp)
    800007d6:	0141                	addi	sp,sp,16
    800007d8:	8082                	ret

00000000800007da <find_kernel_size>:

uint64 find_kernel_size(void) {
    800007da:	1141                	addi	sp,sp,-16
    800007dc:	e422                	sd	s0,8(sp)
    800007de:	0800                	addi	s0,sp,16
    // CSE 536: task 2.5.2
    // riscv64-unknown-elf-readelf -h kernel1
    // Start of section headers + (Size of section headers)*(Number of section headers)
    return (*kernel_elfhdr).shoff + (*kernel_elfhdr).shentsize * (*kernel_elfhdr).shnum;
    800007e0:	00009797          	auipc	a5,0x9
    800007e4:	82878793          	addi	a5,a5,-2008 # 80009008 <kernel_elfhdr>
    800007e8:	639c                	ld	a5,0(a5)
    800007ea:	779c                	ld	a5,40(a5)
    800007ec:	00009717          	auipc	a4,0x9
    800007f0:	81c70713          	addi	a4,a4,-2020 # 80009008 <kernel_elfhdr>
    800007f4:	6318                	ld	a4,0(a4)
    800007f6:	03a75703          	lhu	a4,58(a4)
    800007fa:	0007069b          	sext.w	a3,a4
    800007fe:	00009717          	auipc	a4,0x9
    80000802:	80a70713          	addi	a4,a4,-2038 # 80009008 <kernel_elfhdr>
    80000806:	6318                	ld	a4,0(a4)
    80000808:	03c75703          	lhu	a4,60(a4)
    8000080c:	2701                	sext.w	a4,a4
    8000080e:	02e6873b          	mulw	a4,a3,a4
    80000812:	2701                	sext.w	a4,a4
    80000814:	97ba                	add	a5,a5,a4
}
    80000816:	853e                	mv	a0,a5
    80000818:	6422                	ld	s0,8(sp)
    8000081a:	0141                	addi	sp,sp,16
    8000081c:	8082                	ret

000000008000081e <find_kernel_entry_addr>:

uint64 find_kernel_entry_addr(void) {
    8000081e:	1141                	addi	sp,sp,-16
    80000820:	e422                	sd	s0,8(sp)
    80000822:	0800                	addi	s0,sp,16
    // CSE 536: task 2.5.3
    return (*kernel_elfhdr).entry;
    80000824:	00008797          	auipc	a5,0x8
    80000828:	7e478793          	addi	a5,a5,2020 # 80009008 <kernel_elfhdr>
    8000082c:	639c                	ld	a5,0(a5)
    8000082e:	6f9c                	ld	a5,24(a5)
    80000830:	853e                	mv	a0,a5
    80000832:	6422                	ld	s0,8(sp)
    80000834:	0141                	addi	sp,sp,16
    80000836:	8082                	ret
	...
