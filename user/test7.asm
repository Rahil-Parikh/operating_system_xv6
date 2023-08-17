
user/_test7:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <ul_start_func>:
#include <stdarg.h>

/* Stack region for different threads */
char stacks[PGSIZE*MAXULTHREADS];

void ul_start_func(int a1,int a2, int a3, int a4, int a5, int a6, int a7, int a8) {
   0:	7139                	addi	sp,sp,-64
   2:	fc06                	sd	ra,56(sp)
   4:	f822                	sd	s0,48(sp)
   6:	f426                	sd	s1,40(sp)
   8:	f04a                	sd	s2,32(sp)
   a:	ec4e                	sd	s3,24(sp)
   c:	e852                	sd	s4,16(sp)
   e:	e456                	sd	s5,8(sp)
  10:	e05a                	sd	s6,0(sp)
  12:	0080                	addi	s0,sp,64
  14:	84aa                	mv	s1,a0
  16:	892e                	mv	s2,a1
  18:	89b2                	mv	s3,a2
  1a:	8a36                	mv	s4,a3
  1c:	8aba                	mv	s5,a4
  1e:	8b3e                	mv	s6,a5
    printf("[.] started the thread function (tid = %d, a1 = %d, a2 = %d, a3 = %d, a4 = %d, a5 = %d, a6 = %d)\n", get_current_tid(), a1, a2, a3, a4, a5, a6);
  20:	00001097          	auipc	ra,0x1
  24:	86a080e7          	jalr	-1942(ra) # 88a <get_current_tid>
  28:	85aa                	mv	a1,a0
  2a:	88da                	mv	a7,s6
  2c:	8856                	mv	a6,s5
  2e:	87d2                	mv	a5,s4
  30:	874e                	mv	a4,s3
  32:	86ca                	mv	a3,s2
  34:	8626                	mv	a2,s1
  36:	00001517          	auipc	a0,0x1
  3a:	daa50513          	addi	a0,a0,-598 # de0 <ulthread_context_switch+0x76>
  3e:	00000097          	auipc	ra,0x0
  42:	6ae080e7          	jalr	1710(ra) # 6ec <printf>

    /* Notify for a thread exit. */
    ulthread_destroy();
  46:	00001097          	auipc	ra,0x1
  4a:	cb4080e7          	jalr	-844(ra) # cfa <ulthread_destroy>
}
  4e:	70e2                	ld	ra,56(sp)
  50:	7442                	ld	s0,48(sp)
  52:	74a2                	ld	s1,40(sp)
  54:	7902                	ld	s2,32(sp)
  56:	69e2                	ld	s3,24(sp)
  58:	6a42                	ld	s4,16(sp)
  5a:	6aa2                	ld	s5,8(sp)
  5c:	6b02                	ld	s6,0(sp)
  5e:	6121                	addi	sp,sp,64
  60:	8082                	ret

0000000000000062 <main>:

int
main(int argc, char *argv[])
{
  62:	7139                	addi	sp,sp,-64
  64:	fc06                	sd	ra,56(sp)
  66:	f822                	sd	s0,48(sp)
  68:	0080                	addi	s0,sp,64
    /* Clear the stack region */
    memset(&stacks, 0, sizeof(stacks));
  6a:	00064637          	lui	a2,0x64
  6e:	4581                	li	a1,0
  70:	00001517          	auipc	a0,0x1
  74:	fb050513          	addi	a0,a0,-80 # 1020 <stacks>
  78:	00000097          	auipc	ra,0x0
  7c:	10a080e7          	jalr	266(ra) # 182 <memset>

    uint64 args[6] = {6,5,4,3,2,1};
  80:	00001797          	auipc	a5,0x1
  84:	e1078793          	addi	a5,a5,-496 # e90 <ulthread_context_switch+0x126>
  88:	6388                	ld	a0,0(a5)
  8a:	678c                	ld	a1,8(a5)
  8c:	6b90                	ld	a2,16(a5)
  8e:	6f94                	ld	a3,24(a5)
  90:	7398                	ld	a4,32(a5)
  92:	779c                	ld	a5,40(a5)
  94:	fca43023          	sd	a0,-64(s0)
  98:	fcb43423          	sd	a1,-56(s0)
  9c:	fcc43823          	sd	a2,-48(s0)
  a0:	fcd43c23          	sd	a3,-40(s0)
  a4:	fee43023          	sd	a4,-32(s0)
  a8:	fef43423          	sd	a5,-24(s0)


    ulthread_init(FCFS);
  ac:	4509                	li	a0,2
  ae:	00001097          	auipc	ra,0x1
  b2:	a54080e7          	jalr	-1452(ra) # b02 <ulthread_init>

   
    ulthread_create((uint64) ul_start_func, (uint64) stacks+PGSIZE, args, -1);
  b6:	56fd                	li	a3,-1
  b8:	fc040613          	addi	a2,s0,-64
  bc:	00002597          	auipc	a1,0x2
  c0:	f6458593          	addi	a1,a1,-156 # 2020 <stacks+0x1000>
  c4:	00000517          	auipc	a0,0x0
  c8:	f3c50513          	addi	a0,a0,-196 # 0 <ul_start_func>
  cc:	00001097          	auipc	ra,0x1
  d0:	a90080e7          	jalr	-1392(ra) # b5c <ulthread_create>

    /* Schedule all of the threads */
    ulthread_schedule();
  d4:	00001097          	auipc	ra,0x1
  d8:	b68080e7          	jalr	-1176(ra) # c3c <ulthread_schedule>

    printf("[*] User-Level Threading Test #7 (Arguments Checking - FCFS) Complete.\n");
  dc:	00001517          	auipc	a0,0x1
  e0:	d6c50513          	addi	a0,a0,-660 # e48 <ulthread_context_switch+0xde>
  e4:	00000097          	auipc	ra,0x0
  e8:	608080e7          	jalr	1544(ra) # 6ec <printf>
    return 0;
}
  ec:	4501                	li	a0,0
  ee:	70e2                	ld	ra,56(sp)
  f0:	7442                	ld	s0,48(sp)
  f2:	6121                	addi	sp,sp,64
  f4:	8082                	ret

00000000000000f6 <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
  f6:	1141                	addi	sp,sp,-16
  f8:	e406                	sd	ra,8(sp)
  fa:	e022                	sd	s0,0(sp)
  fc:	0800                	addi	s0,sp,16
  extern int main();
  main();
  fe:	00000097          	auipc	ra,0x0
 102:	f64080e7          	jalr	-156(ra) # 62 <main>
  exit(0);
 106:	4501                	li	a0,0
 108:	00000097          	auipc	ra,0x0
 10c:	274080e7          	jalr	628(ra) # 37c <exit>

0000000000000110 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 110:	1141                	addi	sp,sp,-16
 112:	e422                	sd	s0,8(sp)
 114:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 116:	87aa                	mv	a5,a0
 118:	0585                	addi	a1,a1,1
 11a:	0785                	addi	a5,a5,1
 11c:	fff5c703          	lbu	a4,-1(a1)
 120:	fee78fa3          	sb	a4,-1(a5)
 124:	fb75                	bnez	a4,118 <strcpy+0x8>
    ;
  return os;
}
 126:	6422                	ld	s0,8(sp)
 128:	0141                	addi	sp,sp,16
 12a:	8082                	ret

000000000000012c <strcmp>:

int
strcmp(const char *p, const char *q)
{
 12c:	1141                	addi	sp,sp,-16
 12e:	e422                	sd	s0,8(sp)
 130:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 132:	00054783          	lbu	a5,0(a0)
 136:	cb91                	beqz	a5,14a <strcmp+0x1e>
 138:	0005c703          	lbu	a4,0(a1)
 13c:	00f71763          	bne	a4,a5,14a <strcmp+0x1e>
    p++, q++;
 140:	0505                	addi	a0,a0,1
 142:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 144:	00054783          	lbu	a5,0(a0)
 148:	fbe5                	bnez	a5,138 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 14a:	0005c503          	lbu	a0,0(a1)
}
 14e:	40a7853b          	subw	a0,a5,a0
 152:	6422                	ld	s0,8(sp)
 154:	0141                	addi	sp,sp,16
 156:	8082                	ret

0000000000000158 <strlen>:

uint
strlen(const char *s)
{
 158:	1141                	addi	sp,sp,-16
 15a:	e422                	sd	s0,8(sp)
 15c:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 15e:	00054783          	lbu	a5,0(a0)
 162:	cf91                	beqz	a5,17e <strlen+0x26>
 164:	0505                	addi	a0,a0,1
 166:	87aa                	mv	a5,a0
 168:	86be                	mv	a3,a5
 16a:	0785                	addi	a5,a5,1
 16c:	fff7c703          	lbu	a4,-1(a5)
 170:	ff65                	bnez	a4,168 <strlen+0x10>
 172:	40a6853b          	subw	a0,a3,a0
 176:	2505                	addiw	a0,a0,1
    ;
  return n;
}
 178:	6422                	ld	s0,8(sp)
 17a:	0141                	addi	sp,sp,16
 17c:	8082                	ret
  for(n = 0; s[n]; n++)
 17e:	4501                	li	a0,0
 180:	bfe5                	j	178 <strlen+0x20>

0000000000000182 <memset>:

void*
memset(void *dst, int c, uint n)
{
 182:	1141                	addi	sp,sp,-16
 184:	e422                	sd	s0,8(sp)
 186:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 188:	ca19                	beqz	a2,19e <memset+0x1c>
 18a:	87aa                	mv	a5,a0
 18c:	1602                	slli	a2,a2,0x20
 18e:	9201                	srli	a2,a2,0x20
 190:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 194:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 198:	0785                	addi	a5,a5,1
 19a:	fee79de3          	bne	a5,a4,194 <memset+0x12>
  }
  return dst;
}
 19e:	6422                	ld	s0,8(sp)
 1a0:	0141                	addi	sp,sp,16
 1a2:	8082                	ret

00000000000001a4 <strchr>:

char*
strchr(const char *s, char c)
{
 1a4:	1141                	addi	sp,sp,-16
 1a6:	e422                	sd	s0,8(sp)
 1a8:	0800                	addi	s0,sp,16
  for(; *s; s++)
 1aa:	00054783          	lbu	a5,0(a0)
 1ae:	cb99                	beqz	a5,1c4 <strchr+0x20>
    if(*s == c)
 1b0:	00f58763          	beq	a1,a5,1be <strchr+0x1a>
  for(; *s; s++)
 1b4:	0505                	addi	a0,a0,1
 1b6:	00054783          	lbu	a5,0(a0)
 1ba:	fbfd                	bnez	a5,1b0 <strchr+0xc>
      return (char*)s;
  return 0;
 1bc:	4501                	li	a0,0
}
 1be:	6422                	ld	s0,8(sp)
 1c0:	0141                	addi	sp,sp,16
 1c2:	8082                	ret
  return 0;
 1c4:	4501                	li	a0,0
 1c6:	bfe5                	j	1be <strchr+0x1a>

00000000000001c8 <gets>:

char*
gets(char *buf, int max)
{
 1c8:	711d                	addi	sp,sp,-96
 1ca:	ec86                	sd	ra,88(sp)
 1cc:	e8a2                	sd	s0,80(sp)
 1ce:	e4a6                	sd	s1,72(sp)
 1d0:	e0ca                	sd	s2,64(sp)
 1d2:	fc4e                	sd	s3,56(sp)
 1d4:	f852                	sd	s4,48(sp)
 1d6:	f456                	sd	s5,40(sp)
 1d8:	f05a                	sd	s6,32(sp)
 1da:	ec5e                	sd	s7,24(sp)
 1dc:	1080                	addi	s0,sp,96
 1de:	8baa                	mv	s7,a0
 1e0:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1e2:	892a                	mv	s2,a0
 1e4:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 1e6:	4aa9                	li	s5,10
 1e8:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 1ea:	89a6                	mv	s3,s1
 1ec:	2485                	addiw	s1,s1,1
 1ee:	0344d863          	bge	s1,s4,21e <gets+0x56>
    cc = read(0, &c, 1);
 1f2:	4605                	li	a2,1
 1f4:	faf40593          	addi	a1,s0,-81
 1f8:	4501                	li	a0,0
 1fa:	00000097          	auipc	ra,0x0
 1fe:	19a080e7          	jalr	410(ra) # 394 <read>
    if(cc < 1)
 202:	00a05e63          	blez	a0,21e <gets+0x56>
    buf[i++] = c;
 206:	faf44783          	lbu	a5,-81(s0)
 20a:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 20e:	01578763          	beq	a5,s5,21c <gets+0x54>
 212:	0905                	addi	s2,s2,1
 214:	fd679be3          	bne	a5,s6,1ea <gets+0x22>
  for(i=0; i+1 < max; ){
 218:	89a6                	mv	s3,s1
 21a:	a011                	j	21e <gets+0x56>
 21c:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 21e:	99de                	add	s3,s3,s7
 220:	00098023          	sb	zero,0(s3)
  return buf;
}
 224:	855e                	mv	a0,s7
 226:	60e6                	ld	ra,88(sp)
 228:	6446                	ld	s0,80(sp)
 22a:	64a6                	ld	s1,72(sp)
 22c:	6906                	ld	s2,64(sp)
 22e:	79e2                	ld	s3,56(sp)
 230:	7a42                	ld	s4,48(sp)
 232:	7aa2                	ld	s5,40(sp)
 234:	7b02                	ld	s6,32(sp)
 236:	6be2                	ld	s7,24(sp)
 238:	6125                	addi	sp,sp,96
 23a:	8082                	ret

000000000000023c <stat>:

int
stat(const char *n, struct stat *st)
{
 23c:	1101                	addi	sp,sp,-32
 23e:	ec06                	sd	ra,24(sp)
 240:	e822                	sd	s0,16(sp)
 242:	e426                	sd	s1,8(sp)
 244:	e04a                	sd	s2,0(sp)
 246:	1000                	addi	s0,sp,32
 248:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 24a:	4581                	li	a1,0
 24c:	00000097          	auipc	ra,0x0
 250:	170080e7          	jalr	368(ra) # 3bc <open>
  if(fd < 0)
 254:	02054563          	bltz	a0,27e <stat+0x42>
 258:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 25a:	85ca                	mv	a1,s2
 25c:	00000097          	auipc	ra,0x0
 260:	178080e7          	jalr	376(ra) # 3d4 <fstat>
 264:	892a                	mv	s2,a0
  close(fd);
 266:	8526                	mv	a0,s1
 268:	00000097          	auipc	ra,0x0
 26c:	13c080e7          	jalr	316(ra) # 3a4 <close>
  return r;
}
 270:	854a                	mv	a0,s2
 272:	60e2                	ld	ra,24(sp)
 274:	6442                	ld	s0,16(sp)
 276:	64a2                	ld	s1,8(sp)
 278:	6902                	ld	s2,0(sp)
 27a:	6105                	addi	sp,sp,32
 27c:	8082                	ret
    return -1;
 27e:	597d                	li	s2,-1
 280:	bfc5                	j	270 <stat+0x34>

0000000000000282 <atoi>:

int
atoi(const char *s)
{
 282:	1141                	addi	sp,sp,-16
 284:	e422                	sd	s0,8(sp)
 286:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 288:	00054683          	lbu	a3,0(a0)
 28c:	fd06879b          	addiw	a5,a3,-48
 290:	0ff7f793          	zext.b	a5,a5
 294:	4625                	li	a2,9
 296:	02f66863          	bltu	a2,a5,2c6 <atoi+0x44>
 29a:	872a                	mv	a4,a0
  n = 0;
 29c:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 29e:	0705                	addi	a4,a4,1
 2a0:	0025179b          	slliw	a5,a0,0x2
 2a4:	9fa9                	addw	a5,a5,a0
 2a6:	0017979b          	slliw	a5,a5,0x1
 2aa:	9fb5                	addw	a5,a5,a3
 2ac:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 2b0:	00074683          	lbu	a3,0(a4)
 2b4:	fd06879b          	addiw	a5,a3,-48
 2b8:	0ff7f793          	zext.b	a5,a5
 2bc:	fef671e3          	bgeu	a2,a5,29e <atoi+0x1c>
  return n;
}
 2c0:	6422                	ld	s0,8(sp)
 2c2:	0141                	addi	sp,sp,16
 2c4:	8082                	ret
  n = 0;
 2c6:	4501                	li	a0,0
 2c8:	bfe5                	j	2c0 <atoi+0x3e>

00000000000002ca <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 2ca:	1141                	addi	sp,sp,-16
 2cc:	e422                	sd	s0,8(sp)
 2ce:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 2d0:	02b57463          	bgeu	a0,a1,2f8 <memmove+0x2e>
    while(n-- > 0)
 2d4:	00c05f63          	blez	a2,2f2 <memmove+0x28>
 2d8:	1602                	slli	a2,a2,0x20
 2da:	9201                	srli	a2,a2,0x20
 2dc:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 2e0:	872a                	mv	a4,a0
      *dst++ = *src++;
 2e2:	0585                	addi	a1,a1,1
 2e4:	0705                	addi	a4,a4,1
 2e6:	fff5c683          	lbu	a3,-1(a1)
 2ea:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 2ee:	fee79ae3          	bne	a5,a4,2e2 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 2f2:	6422                	ld	s0,8(sp)
 2f4:	0141                	addi	sp,sp,16
 2f6:	8082                	ret
    dst += n;
 2f8:	00c50733          	add	a4,a0,a2
    src += n;
 2fc:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 2fe:	fec05ae3          	blez	a2,2f2 <memmove+0x28>
 302:	fff6079b          	addiw	a5,a2,-1 # 63fff <stacks+0x62fdf>
 306:	1782                	slli	a5,a5,0x20
 308:	9381                	srli	a5,a5,0x20
 30a:	fff7c793          	not	a5,a5
 30e:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 310:	15fd                	addi	a1,a1,-1
 312:	177d                	addi	a4,a4,-1
 314:	0005c683          	lbu	a3,0(a1)
 318:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 31c:	fee79ae3          	bne	a5,a4,310 <memmove+0x46>
 320:	bfc9                	j	2f2 <memmove+0x28>

0000000000000322 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 322:	1141                	addi	sp,sp,-16
 324:	e422                	sd	s0,8(sp)
 326:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 328:	ca05                	beqz	a2,358 <memcmp+0x36>
 32a:	fff6069b          	addiw	a3,a2,-1
 32e:	1682                	slli	a3,a3,0x20
 330:	9281                	srli	a3,a3,0x20
 332:	0685                	addi	a3,a3,1
 334:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 336:	00054783          	lbu	a5,0(a0)
 33a:	0005c703          	lbu	a4,0(a1)
 33e:	00e79863          	bne	a5,a4,34e <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 342:	0505                	addi	a0,a0,1
    p2++;
 344:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 346:	fed518e3          	bne	a0,a3,336 <memcmp+0x14>
  }
  return 0;
 34a:	4501                	li	a0,0
 34c:	a019                	j	352 <memcmp+0x30>
      return *p1 - *p2;
 34e:	40e7853b          	subw	a0,a5,a4
}
 352:	6422                	ld	s0,8(sp)
 354:	0141                	addi	sp,sp,16
 356:	8082                	ret
  return 0;
 358:	4501                	li	a0,0
 35a:	bfe5                	j	352 <memcmp+0x30>

000000000000035c <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 35c:	1141                	addi	sp,sp,-16
 35e:	e406                	sd	ra,8(sp)
 360:	e022                	sd	s0,0(sp)
 362:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 364:	00000097          	auipc	ra,0x0
 368:	f66080e7          	jalr	-154(ra) # 2ca <memmove>
}
 36c:	60a2                	ld	ra,8(sp)
 36e:	6402                	ld	s0,0(sp)
 370:	0141                	addi	sp,sp,16
 372:	8082                	ret

0000000000000374 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 374:	4885                	li	a7,1
 ecall
 376:	00000073          	ecall
 ret
 37a:	8082                	ret

000000000000037c <exit>:
.global exit
exit:
 li a7, SYS_exit
 37c:	4889                	li	a7,2
 ecall
 37e:	00000073          	ecall
 ret
 382:	8082                	ret

0000000000000384 <wait>:
.global wait
wait:
 li a7, SYS_wait
 384:	488d                	li	a7,3
 ecall
 386:	00000073          	ecall
 ret
 38a:	8082                	ret

000000000000038c <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 38c:	4891                	li	a7,4
 ecall
 38e:	00000073          	ecall
 ret
 392:	8082                	ret

0000000000000394 <read>:
.global read
read:
 li a7, SYS_read
 394:	4895                	li	a7,5
 ecall
 396:	00000073          	ecall
 ret
 39a:	8082                	ret

000000000000039c <write>:
.global write
write:
 li a7, SYS_write
 39c:	48c1                	li	a7,16
 ecall
 39e:	00000073          	ecall
 ret
 3a2:	8082                	ret

00000000000003a4 <close>:
.global close
close:
 li a7, SYS_close
 3a4:	48d5                	li	a7,21
 ecall
 3a6:	00000073          	ecall
 ret
 3aa:	8082                	ret

00000000000003ac <kill>:
.global kill
kill:
 li a7, SYS_kill
 3ac:	4899                	li	a7,6
 ecall
 3ae:	00000073          	ecall
 ret
 3b2:	8082                	ret

00000000000003b4 <exec>:
.global exec
exec:
 li a7, SYS_exec
 3b4:	489d                	li	a7,7
 ecall
 3b6:	00000073          	ecall
 ret
 3ba:	8082                	ret

00000000000003bc <open>:
.global open
open:
 li a7, SYS_open
 3bc:	48bd                	li	a7,15
 ecall
 3be:	00000073          	ecall
 ret
 3c2:	8082                	ret

00000000000003c4 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 3c4:	48c5                	li	a7,17
 ecall
 3c6:	00000073          	ecall
 ret
 3ca:	8082                	ret

00000000000003cc <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 3cc:	48c9                	li	a7,18
 ecall
 3ce:	00000073          	ecall
 ret
 3d2:	8082                	ret

00000000000003d4 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 3d4:	48a1                	li	a7,8
 ecall
 3d6:	00000073          	ecall
 ret
 3da:	8082                	ret

00000000000003dc <link>:
.global link
link:
 li a7, SYS_link
 3dc:	48cd                	li	a7,19
 ecall
 3de:	00000073          	ecall
 ret
 3e2:	8082                	ret

00000000000003e4 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 3e4:	48d1                	li	a7,20
 ecall
 3e6:	00000073          	ecall
 ret
 3ea:	8082                	ret

00000000000003ec <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 3ec:	48a5                	li	a7,9
 ecall
 3ee:	00000073          	ecall
 ret
 3f2:	8082                	ret

00000000000003f4 <dup>:
.global dup
dup:
 li a7, SYS_dup
 3f4:	48a9                	li	a7,10
 ecall
 3f6:	00000073          	ecall
 ret
 3fa:	8082                	ret

00000000000003fc <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 3fc:	48ad                	li	a7,11
 ecall
 3fe:	00000073          	ecall
 ret
 402:	8082                	ret

0000000000000404 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 404:	48b1                	li	a7,12
 ecall
 406:	00000073          	ecall
 ret
 40a:	8082                	ret

000000000000040c <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 40c:	48b5                	li	a7,13
 ecall
 40e:	00000073          	ecall
 ret
 412:	8082                	ret

0000000000000414 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 414:	48b9                	li	a7,14
 ecall
 416:	00000073          	ecall
 ret
 41a:	8082                	ret

000000000000041c <ctime>:
.global ctime
ctime:
 li a7, SYS_ctime
 41c:	48d9                	li	a7,22
 ecall
 41e:	00000073          	ecall
 ret
 422:	8082                	ret

0000000000000424 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 424:	1101                	addi	sp,sp,-32
 426:	ec06                	sd	ra,24(sp)
 428:	e822                	sd	s0,16(sp)
 42a:	1000                	addi	s0,sp,32
 42c:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 430:	4605                	li	a2,1
 432:	fef40593          	addi	a1,s0,-17
 436:	00000097          	auipc	ra,0x0
 43a:	f66080e7          	jalr	-154(ra) # 39c <write>
}
 43e:	60e2                	ld	ra,24(sp)
 440:	6442                	ld	s0,16(sp)
 442:	6105                	addi	sp,sp,32
 444:	8082                	ret

0000000000000446 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 446:	7139                	addi	sp,sp,-64
 448:	fc06                	sd	ra,56(sp)
 44a:	f822                	sd	s0,48(sp)
 44c:	f426                	sd	s1,40(sp)
 44e:	f04a                	sd	s2,32(sp)
 450:	ec4e                	sd	s3,24(sp)
 452:	0080                	addi	s0,sp,64
 454:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 456:	c299                	beqz	a3,45c <printint+0x16>
 458:	0805c963          	bltz	a1,4ea <printint+0xa4>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 45c:	2581                	sext.w	a1,a1
  neg = 0;
 45e:	4881                	li	a7,0
 460:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 464:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 466:	2601                	sext.w	a2,a2
 468:	00001517          	auipc	a0,0x1
 46c:	ab850513          	addi	a0,a0,-1352 # f20 <digits>
 470:	883a                	mv	a6,a4
 472:	2705                	addiw	a4,a4,1
 474:	02c5f7bb          	remuw	a5,a1,a2
 478:	1782                	slli	a5,a5,0x20
 47a:	9381                	srli	a5,a5,0x20
 47c:	97aa                	add	a5,a5,a0
 47e:	0007c783          	lbu	a5,0(a5)
 482:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 486:	0005879b          	sext.w	a5,a1
 48a:	02c5d5bb          	divuw	a1,a1,a2
 48e:	0685                	addi	a3,a3,1
 490:	fec7f0e3          	bgeu	a5,a2,470 <printint+0x2a>
  if(neg)
 494:	00088c63          	beqz	a7,4ac <printint+0x66>
    buf[i++] = '-';
 498:	fd070793          	addi	a5,a4,-48
 49c:	00878733          	add	a4,a5,s0
 4a0:	02d00793          	li	a5,45
 4a4:	fef70823          	sb	a5,-16(a4)
 4a8:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 4ac:	02e05863          	blez	a4,4dc <printint+0x96>
 4b0:	fc040793          	addi	a5,s0,-64
 4b4:	00e78933          	add	s2,a5,a4
 4b8:	fff78993          	addi	s3,a5,-1
 4bc:	99ba                	add	s3,s3,a4
 4be:	377d                	addiw	a4,a4,-1
 4c0:	1702                	slli	a4,a4,0x20
 4c2:	9301                	srli	a4,a4,0x20
 4c4:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 4c8:	fff94583          	lbu	a1,-1(s2)
 4cc:	8526                	mv	a0,s1
 4ce:	00000097          	auipc	ra,0x0
 4d2:	f56080e7          	jalr	-170(ra) # 424 <putc>
  while(--i >= 0)
 4d6:	197d                	addi	s2,s2,-1
 4d8:	ff3918e3          	bne	s2,s3,4c8 <printint+0x82>
}
 4dc:	70e2                	ld	ra,56(sp)
 4de:	7442                	ld	s0,48(sp)
 4e0:	74a2                	ld	s1,40(sp)
 4e2:	7902                	ld	s2,32(sp)
 4e4:	69e2                	ld	s3,24(sp)
 4e6:	6121                	addi	sp,sp,64
 4e8:	8082                	ret
    x = -xx;
 4ea:	40b005bb          	negw	a1,a1
    neg = 1;
 4ee:	4885                	li	a7,1
    x = -xx;
 4f0:	bf85                	j	460 <printint+0x1a>

00000000000004f2 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 4f2:	715d                	addi	sp,sp,-80
 4f4:	e486                	sd	ra,72(sp)
 4f6:	e0a2                	sd	s0,64(sp)
 4f8:	fc26                	sd	s1,56(sp)
 4fa:	f84a                	sd	s2,48(sp)
 4fc:	f44e                	sd	s3,40(sp)
 4fe:	f052                	sd	s4,32(sp)
 500:	ec56                	sd	s5,24(sp)
 502:	e85a                	sd	s6,16(sp)
 504:	e45e                	sd	s7,8(sp)
 506:	e062                	sd	s8,0(sp)
 508:	0880                	addi	s0,sp,80
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 50a:	0005c903          	lbu	s2,0(a1)
 50e:	18090c63          	beqz	s2,6a6 <vprintf+0x1b4>
 512:	8aaa                	mv	s5,a0
 514:	8bb2                	mv	s7,a2
 516:	00158493          	addi	s1,a1,1
  state = 0;
 51a:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 51c:	02500a13          	li	s4,37
 520:	4b55                	li	s6,21
 522:	a839                	j	540 <vprintf+0x4e>
        putc(fd, c);
 524:	85ca                	mv	a1,s2
 526:	8556                	mv	a0,s5
 528:	00000097          	auipc	ra,0x0
 52c:	efc080e7          	jalr	-260(ra) # 424 <putc>
 530:	a019                	j	536 <vprintf+0x44>
    } else if(state == '%'){
 532:	01498d63          	beq	s3,s4,54c <vprintf+0x5a>
  for(i = 0; fmt[i]; i++){
 536:	0485                	addi	s1,s1,1
 538:	fff4c903          	lbu	s2,-1(s1)
 53c:	16090563          	beqz	s2,6a6 <vprintf+0x1b4>
    if(state == 0){
 540:	fe0999e3          	bnez	s3,532 <vprintf+0x40>
      if(c == '%'){
 544:	ff4910e3          	bne	s2,s4,524 <vprintf+0x32>
        state = '%';
 548:	89d2                	mv	s3,s4
 54a:	b7f5                	j	536 <vprintf+0x44>
      if(c == 'd'){
 54c:	13490263          	beq	s2,s4,670 <vprintf+0x17e>
 550:	f9d9079b          	addiw	a5,s2,-99
 554:	0ff7f793          	zext.b	a5,a5
 558:	12fb6563          	bltu	s6,a5,682 <vprintf+0x190>
 55c:	f9d9079b          	addiw	a5,s2,-99
 560:	0ff7f713          	zext.b	a4,a5
 564:	10eb6f63          	bltu	s6,a4,682 <vprintf+0x190>
 568:	00271793          	slli	a5,a4,0x2
 56c:	00001717          	auipc	a4,0x1
 570:	95c70713          	addi	a4,a4,-1700 # ec8 <ulthread_context_switch+0x15e>
 574:	97ba                	add	a5,a5,a4
 576:	439c                	lw	a5,0(a5)
 578:	97ba                	add	a5,a5,a4
 57a:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
 57c:	008b8913          	addi	s2,s7,8
 580:	4685                	li	a3,1
 582:	4629                	li	a2,10
 584:	000ba583          	lw	a1,0(s7)
 588:	8556                	mv	a0,s5
 58a:	00000097          	auipc	ra,0x0
 58e:	ebc080e7          	jalr	-324(ra) # 446 <printint>
 592:	8bca                	mv	s7,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 594:	4981                	li	s3,0
 596:	b745                	j	536 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 598:	008b8913          	addi	s2,s7,8
 59c:	4681                	li	a3,0
 59e:	4629                	li	a2,10
 5a0:	000ba583          	lw	a1,0(s7)
 5a4:	8556                	mv	a0,s5
 5a6:	00000097          	auipc	ra,0x0
 5aa:	ea0080e7          	jalr	-352(ra) # 446 <printint>
 5ae:	8bca                	mv	s7,s2
      state = 0;
 5b0:	4981                	li	s3,0
 5b2:	b751                	j	536 <vprintf+0x44>
        printint(fd, va_arg(ap, int), 16, 0);
 5b4:	008b8913          	addi	s2,s7,8
 5b8:	4681                	li	a3,0
 5ba:	4641                	li	a2,16
 5bc:	000ba583          	lw	a1,0(s7)
 5c0:	8556                	mv	a0,s5
 5c2:	00000097          	auipc	ra,0x0
 5c6:	e84080e7          	jalr	-380(ra) # 446 <printint>
 5ca:	8bca                	mv	s7,s2
      state = 0;
 5cc:	4981                	li	s3,0
 5ce:	b7a5                	j	536 <vprintf+0x44>
        printptr(fd, va_arg(ap, uint64));
 5d0:	008b8c13          	addi	s8,s7,8
 5d4:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 5d8:	03000593          	li	a1,48
 5dc:	8556                	mv	a0,s5
 5de:	00000097          	auipc	ra,0x0
 5e2:	e46080e7          	jalr	-442(ra) # 424 <putc>
  putc(fd, 'x');
 5e6:	07800593          	li	a1,120
 5ea:	8556                	mv	a0,s5
 5ec:	00000097          	auipc	ra,0x0
 5f0:	e38080e7          	jalr	-456(ra) # 424 <putc>
 5f4:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 5f6:	00001b97          	auipc	s7,0x1
 5fa:	92ab8b93          	addi	s7,s7,-1750 # f20 <digits>
 5fe:	03c9d793          	srli	a5,s3,0x3c
 602:	97de                	add	a5,a5,s7
 604:	0007c583          	lbu	a1,0(a5)
 608:	8556                	mv	a0,s5
 60a:	00000097          	auipc	ra,0x0
 60e:	e1a080e7          	jalr	-486(ra) # 424 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 612:	0992                	slli	s3,s3,0x4
 614:	397d                	addiw	s2,s2,-1
 616:	fe0914e3          	bnez	s2,5fe <vprintf+0x10c>
        printptr(fd, va_arg(ap, uint64));
 61a:	8be2                	mv	s7,s8
      state = 0;
 61c:	4981                	li	s3,0
 61e:	bf21                	j	536 <vprintf+0x44>
        s = va_arg(ap, char*);
 620:	008b8993          	addi	s3,s7,8
 624:	000bb903          	ld	s2,0(s7)
        if(s == 0)
 628:	02090163          	beqz	s2,64a <vprintf+0x158>
        while(*s != 0){
 62c:	00094583          	lbu	a1,0(s2)
 630:	c9a5                	beqz	a1,6a0 <vprintf+0x1ae>
          putc(fd, *s);
 632:	8556                	mv	a0,s5
 634:	00000097          	auipc	ra,0x0
 638:	df0080e7          	jalr	-528(ra) # 424 <putc>
          s++;
 63c:	0905                	addi	s2,s2,1
        while(*s != 0){
 63e:	00094583          	lbu	a1,0(s2)
 642:	f9e5                	bnez	a1,632 <vprintf+0x140>
        s = va_arg(ap, char*);
 644:	8bce                	mv	s7,s3
      state = 0;
 646:	4981                	li	s3,0
 648:	b5fd                	j	536 <vprintf+0x44>
          s = "(null)";
 64a:	00001917          	auipc	s2,0x1
 64e:	87690913          	addi	s2,s2,-1930 # ec0 <ulthread_context_switch+0x156>
        while(*s != 0){
 652:	02800593          	li	a1,40
 656:	bff1                	j	632 <vprintf+0x140>
        putc(fd, va_arg(ap, uint));
 658:	008b8913          	addi	s2,s7,8
 65c:	000bc583          	lbu	a1,0(s7)
 660:	8556                	mv	a0,s5
 662:	00000097          	auipc	ra,0x0
 666:	dc2080e7          	jalr	-574(ra) # 424 <putc>
 66a:	8bca                	mv	s7,s2
      state = 0;
 66c:	4981                	li	s3,0
 66e:	b5e1                	j	536 <vprintf+0x44>
        putc(fd, c);
 670:	02500593          	li	a1,37
 674:	8556                	mv	a0,s5
 676:	00000097          	auipc	ra,0x0
 67a:	dae080e7          	jalr	-594(ra) # 424 <putc>
      state = 0;
 67e:	4981                	li	s3,0
 680:	bd5d                	j	536 <vprintf+0x44>
        putc(fd, '%');
 682:	02500593          	li	a1,37
 686:	8556                	mv	a0,s5
 688:	00000097          	auipc	ra,0x0
 68c:	d9c080e7          	jalr	-612(ra) # 424 <putc>
        putc(fd, c);
 690:	85ca                	mv	a1,s2
 692:	8556                	mv	a0,s5
 694:	00000097          	auipc	ra,0x0
 698:	d90080e7          	jalr	-624(ra) # 424 <putc>
      state = 0;
 69c:	4981                	li	s3,0
 69e:	bd61                	j	536 <vprintf+0x44>
        s = va_arg(ap, char*);
 6a0:	8bce                	mv	s7,s3
      state = 0;
 6a2:	4981                	li	s3,0
 6a4:	bd49                	j	536 <vprintf+0x44>
    }
  }
}
 6a6:	60a6                	ld	ra,72(sp)
 6a8:	6406                	ld	s0,64(sp)
 6aa:	74e2                	ld	s1,56(sp)
 6ac:	7942                	ld	s2,48(sp)
 6ae:	79a2                	ld	s3,40(sp)
 6b0:	7a02                	ld	s4,32(sp)
 6b2:	6ae2                	ld	s5,24(sp)
 6b4:	6b42                	ld	s6,16(sp)
 6b6:	6ba2                	ld	s7,8(sp)
 6b8:	6c02                	ld	s8,0(sp)
 6ba:	6161                	addi	sp,sp,80
 6bc:	8082                	ret

00000000000006be <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 6be:	715d                	addi	sp,sp,-80
 6c0:	ec06                	sd	ra,24(sp)
 6c2:	e822                	sd	s0,16(sp)
 6c4:	1000                	addi	s0,sp,32
 6c6:	e010                	sd	a2,0(s0)
 6c8:	e414                	sd	a3,8(s0)
 6ca:	e818                	sd	a4,16(s0)
 6cc:	ec1c                	sd	a5,24(s0)
 6ce:	03043023          	sd	a6,32(s0)
 6d2:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 6d6:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 6da:	8622                	mv	a2,s0
 6dc:	00000097          	auipc	ra,0x0
 6e0:	e16080e7          	jalr	-490(ra) # 4f2 <vprintf>
}
 6e4:	60e2                	ld	ra,24(sp)
 6e6:	6442                	ld	s0,16(sp)
 6e8:	6161                	addi	sp,sp,80
 6ea:	8082                	ret

00000000000006ec <printf>:

void
printf(const char *fmt, ...)
{
 6ec:	711d                	addi	sp,sp,-96
 6ee:	ec06                	sd	ra,24(sp)
 6f0:	e822                	sd	s0,16(sp)
 6f2:	1000                	addi	s0,sp,32
 6f4:	e40c                	sd	a1,8(s0)
 6f6:	e810                	sd	a2,16(s0)
 6f8:	ec14                	sd	a3,24(s0)
 6fa:	f018                	sd	a4,32(s0)
 6fc:	f41c                	sd	a5,40(s0)
 6fe:	03043823          	sd	a6,48(s0)
 702:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 706:	00840613          	addi	a2,s0,8
 70a:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 70e:	85aa                	mv	a1,a0
 710:	4505                	li	a0,1
 712:	00000097          	auipc	ra,0x0
 716:	de0080e7          	jalr	-544(ra) # 4f2 <vprintf>
}
 71a:	60e2                	ld	ra,24(sp)
 71c:	6442                	ld	s0,16(sp)
 71e:	6125                	addi	sp,sp,96
 720:	8082                	ret

0000000000000722 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 722:	1141                	addi	sp,sp,-16
 724:	e422                	sd	s0,8(sp)
 726:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 728:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 72c:	00001797          	auipc	a5,0x1
 730:	8d47b783          	ld	a5,-1836(a5) # 1000 <freep>
 734:	a02d                	j	75e <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 736:	4618                	lw	a4,8(a2)
 738:	9f2d                	addw	a4,a4,a1
 73a:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 73e:	6398                	ld	a4,0(a5)
 740:	6310                	ld	a2,0(a4)
 742:	a83d                	j	780 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 744:	ff852703          	lw	a4,-8(a0)
 748:	9f31                	addw	a4,a4,a2
 74a:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 74c:	ff053683          	ld	a3,-16(a0)
 750:	a091                	j	794 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 752:	6398                	ld	a4,0(a5)
 754:	00e7e463          	bltu	a5,a4,75c <free+0x3a>
 758:	00e6ea63          	bltu	a3,a4,76c <free+0x4a>
{
 75c:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 75e:	fed7fae3          	bgeu	a5,a3,752 <free+0x30>
 762:	6398                	ld	a4,0(a5)
 764:	00e6e463          	bltu	a3,a4,76c <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 768:	fee7eae3          	bltu	a5,a4,75c <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 76c:	ff852583          	lw	a1,-8(a0)
 770:	6390                	ld	a2,0(a5)
 772:	02059813          	slli	a6,a1,0x20
 776:	01c85713          	srli	a4,a6,0x1c
 77a:	9736                	add	a4,a4,a3
 77c:	fae60de3          	beq	a2,a4,736 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 780:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 784:	4790                	lw	a2,8(a5)
 786:	02061593          	slli	a1,a2,0x20
 78a:	01c5d713          	srli	a4,a1,0x1c
 78e:	973e                	add	a4,a4,a5
 790:	fae68ae3          	beq	a3,a4,744 <free+0x22>
    p->s.ptr = bp->s.ptr;
 794:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 796:	00001717          	auipc	a4,0x1
 79a:	86f73523          	sd	a5,-1942(a4) # 1000 <freep>
}
 79e:	6422                	ld	s0,8(sp)
 7a0:	0141                	addi	sp,sp,16
 7a2:	8082                	ret

00000000000007a4 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 7a4:	7139                	addi	sp,sp,-64
 7a6:	fc06                	sd	ra,56(sp)
 7a8:	f822                	sd	s0,48(sp)
 7aa:	f426                	sd	s1,40(sp)
 7ac:	f04a                	sd	s2,32(sp)
 7ae:	ec4e                	sd	s3,24(sp)
 7b0:	e852                	sd	s4,16(sp)
 7b2:	e456                	sd	s5,8(sp)
 7b4:	e05a                	sd	s6,0(sp)
 7b6:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 7b8:	02051493          	slli	s1,a0,0x20
 7bc:	9081                	srli	s1,s1,0x20
 7be:	04bd                	addi	s1,s1,15
 7c0:	8091                	srli	s1,s1,0x4
 7c2:	0014899b          	addiw	s3,s1,1
 7c6:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 7c8:	00001517          	auipc	a0,0x1
 7cc:	83853503          	ld	a0,-1992(a0) # 1000 <freep>
 7d0:	c515                	beqz	a0,7fc <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 7d2:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 7d4:	4798                	lw	a4,8(a5)
 7d6:	02977f63          	bgeu	a4,s1,814 <malloc+0x70>
  if(nu < 4096)
 7da:	8a4e                	mv	s4,s3
 7dc:	0009871b          	sext.w	a4,s3
 7e0:	6685                	lui	a3,0x1
 7e2:	00d77363          	bgeu	a4,a3,7e8 <malloc+0x44>
 7e6:	6a05                	lui	s4,0x1
 7e8:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 7ec:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 7f0:	00001917          	auipc	s2,0x1
 7f4:	81090913          	addi	s2,s2,-2032 # 1000 <freep>
  if(p == (char*)-1)
 7f8:	5afd                	li	s5,-1
 7fa:	a895                	j	86e <malloc+0xca>
    base.s.ptr = freep = prevp = &base;
 7fc:	00065797          	auipc	a5,0x65
 800:	82478793          	addi	a5,a5,-2012 # 65020 <base>
 804:	00000717          	auipc	a4,0x0
 808:	7ef73e23          	sd	a5,2044(a4) # 1000 <freep>
 80c:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 80e:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 812:	b7e1                	j	7da <malloc+0x36>
      if(p->s.size == nunits)
 814:	02e48c63          	beq	s1,a4,84c <malloc+0xa8>
        p->s.size -= nunits;
 818:	4137073b          	subw	a4,a4,s3
 81c:	c798                	sw	a4,8(a5)
        p += p->s.size;
 81e:	02071693          	slli	a3,a4,0x20
 822:	01c6d713          	srli	a4,a3,0x1c
 826:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 828:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 82c:	00000717          	auipc	a4,0x0
 830:	7ca73a23          	sd	a0,2004(a4) # 1000 <freep>
      return (void*)(p + 1);
 834:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 838:	70e2                	ld	ra,56(sp)
 83a:	7442                	ld	s0,48(sp)
 83c:	74a2                	ld	s1,40(sp)
 83e:	7902                	ld	s2,32(sp)
 840:	69e2                	ld	s3,24(sp)
 842:	6a42                	ld	s4,16(sp)
 844:	6aa2                	ld	s5,8(sp)
 846:	6b02                	ld	s6,0(sp)
 848:	6121                	addi	sp,sp,64
 84a:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 84c:	6398                	ld	a4,0(a5)
 84e:	e118                	sd	a4,0(a0)
 850:	bff1                	j	82c <malloc+0x88>
  hp->s.size = nu;
 852:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 856:	0541                	addi	a0,a0,16
 858:	00000097          	auipc	ra,0x0
 85c:	eca080e7          	jalr	-310(ra) # 722 <free>
  return freep;
 860:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 864:	d971                	beqz	a0,838 <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 866:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 868:	4798                	lw	a4,8(a5)
 86a:	fa9775e3          	bgeu	a4,s1,814 <malloc+0x70>
    if(p == freep)
 86e:	00093703          	ld	a4,0(s2)
 872:	853e                	mv	a0,a5
 874:	fef719e3          	bne	a4,a5,866 <malloc+0xc2>
  p = sbrk(nu * sizeof(Header));
 878:	8552                	mv	a0,s4
 87a:	00000097          	auipc	ra,0x0
 87e:	b8a080e7          	jalr	-1142(ra) # 404 <sbrk>
  if(p == (char*)-1)
 882:	fd5518e3          	bne	a0,s5,852 <malloc+0xae>
        return 0;
 886:	4501                	li	a0,0
 888:	bf45                	j	838 <malloc+0x94>

000000000000088a <get_current_tid>:
struct ulthread *scheduler_thread;
enum ulthread_scheduling_algorithm algorithm;

/* Get thread ID */
int get_current_tid(void)
{
 88a:	1141                	addi	sp,sp,-16
 88c:	e422                	sd	s0,8(sp)
 88e:	0800                	addi	s0,sp,16
  return current_thread->tid;
}
 890:	00000797          	auipc	a5,0x0
 894:	7887b783          	ld	a5,1928(a5) # 1018 <current_thread>
 898:	43c8                	lw	a0,4(a5)
 89a:	6422                	ld	s0,8(sp)
 89c:	0141                	addi	sp,sp,16
 89e:	8082                	ret

00000000000008a0 <roundRobin>:

void roundRobin(void)
{
 8a0:	715d                	addi	sp,sp,-80
 8a2:	e486                	sd	ra,72(sp)
 8a4:	e0a2                	sd	s0,64(sp)
 8a6:	fc26                	sd	s1,56(sp)
 8a8:	f84a                	sd	s2,48(sp)
 8aa:	f44e                	sd	s3,40(sp)
 8ac:	f052                	sd	s4,32(sp)
 8ae:	ec56                	sd	s5,24(sp)
 8b0:	e85a                	sd	s6,16(sp)
 8b2:	e45e                	sd	s7,8(sp)
 8b4:	e062                	sd	s8,0(sp)
 8b6:	0880                	addi	s0,sp,80
        struct ulthread *temp = current_thread;
        current_thread = t;
        printf("[*] ultschedule (next tid: %d)\n", get_current_tid());
        ulthread_context_switch(&temp->context, &t->context);
      }
      if (t->state == YIELD)
 8b8:	4a09                	li	s4,2
      if (t->state == RUNNABLE && t != scheduler_thread)
 8ba:	00000b97          	auipc	s7,0x0
 8be:	756b8b93          	addi	s7,s7,1878 # 1010 <scheduler_thread>
        struct ulthread *temp = current_thread;
 8c2:	00000a97          	auipc	s5,0x0
 8c6:	756a8a93          	addi	s5,s5,1878 # 1018 <current_thread>
        printf("[*] ultschedule (next tid: %d)\n", get_current_tid());
 8ca:	00000c17          	auipc	s8,0x0
 8ce:	66ec0c13          	addi	s8,s8,1646 # f38 <digits+0x18>
    for (t = ulthreads; t < &ulthreads[MAXULTHREADS]; t++)
 8d2:	00068997          	auipc	s3,0x68
 8d6:	c7e98993          	addi	s3,s3,-898 # 68550 <ulthreads+0x3520>
 8da:	a0b9                	j	928 <roundRobin+0x88>
      if (t->state == RUNNABLE && t != scheduler_thread)
 8dc:	000bb783          	ld	a5,0(s7)
 8e0:	02978863          	beq	a5,s1,910 <roundRobin+0x70>
        struct ulthread *temp = current_thread;
 8e4:	000abb03          	ld	s6,0(s5)
        current_thread = t;
 8e8:	009ab023          	sd	s1,0(s5)
        printf("[*] ultschedule (next tid: %d)\n", get_current_tid());
 8ec:	40cc                	lw	a1,4(s1)
 8ee:	8562                	mv	a0,s8
 8f0:	00000097          	auipc	ra,0x0
 8f4:	dfc080e7          	jalr	-516(ra) # 6ec <printf>
        ulthread_context_switch(&temp->context, &t->context);
 8f8:	01848593          	addi	a1,s1,24
 8fc:	018b0513          	addi	a0,s6,24
 900:	00000097          	auipc	ra,0x0
 904:	46a080e7          	jalr	1130(ra) # d6a <ulthread_context_switch>
        threadAvailable = true;
 908:	874a                	mv	a4,s2
 90a:	a811                	j	91e <roundRobin+0x7e>
      {
        t->state = RUNNABLE;
 90c:	0124a023          	sw	s2,0(s1)
    for (t = ulthreads; t < &ulthreads[MAXULTHREADS]; t++)
 910:	08848493          	addi	s1,s1,136
 914:	01348963          	beq	s1,s3,926 <roundRobin+0x86>
      if (t->state == RUNNABLE && t != scheduler_thread)
 918:	409c                	lw	a5,0(s1)
 91a:	fd2781e3          	beq	a5,s2,8dc <roundRobin+0x3c>
      if (t->state == YIELD)
 91e:	409c                	lw	a5,0(s1)
 920:	ff4798e3          	bne	a5,s4,910 <roundRobin+0x70>
 924:	b7e5                	j	90c <roundRobin+0x6c>
      }
    }
    if (!threadAvailable)
 926:	cb01                	beqz	a4,936 <roundRobin+0x96>
    bool threadAvailable = false;
 928:	4701                	li	a4,0
    for (t = ulthreads; t < &ulthreads[MAXULTHREADS]; t++)
 92a:	00064497          	auipc	s1,0x64
 92e:	70648493          	addi	s1,s1,1798 # 65030 <ulthreads>
      if (t->state == RUNNABLE && t != scheduler_thread)
 932:	4905                	li	s2,1
 934:	b7d5                	j	918 <roundRobin+0x78>
    {
      break;
    }
  }
}
 936:	60a6                	ld	ra,72(sp)
 938:	6406                	ld	s0,64(sp)
 93a:	74e2                	ld	s1,56(sp)
 93c:	7942                	ld	s2,48(sp)
 93e:	79a2                	ld	s3,40(sp)
 940:	7a02                	ld	s4,32(sp)
 942:	6ae2                	ld	s5,24(sp)
 944:	6b42                	ld	s6,16(sp)
 946:	6ba2                	ld	s7,8(sp)
 948:	6c02                	ld	s8,0(sp)
 94a:	6161                	addi	sp,sp,80
 94c:	8082                	ret

000000000000094e <firstComeFirstServe>:

void firstComeFirstServe(void)
{
 94e:	715d                	addi	sp,sp,-80
 950:	e486                	sd	ra,72(sp)
 952:	e0a2                	sd	s0,64(sp)
 954:	fc26                	sd	s1,56(sp)
 956:	f84a                	sd	s2,48(sp)
 958:	f44e                	sd	s3,40(sp)
 95a:	f052                	sd	s4,32(sp)
 95c:	ec56                	sd	s5,24(sp)
 95e:	e85a                	sd	s6,16(sp)
 960:	e45e                	sd	s7,8(sp)
 962:	e062                	sd	s8,0(sp)
 964:	0880                	addi	s0,sp,80
    uint64 oldest = __INT64_MAX__;
    int threadIndex = -1;
    int alternativeIndex = -1;
    for (t = ulthreads+1; t < &ulthreads[MAXULTHREADS]; t++)
    {
      if (t->state == RUNNABLE && t != scheduler_thread && t->lastTime < oldest)
 966:	00000b97          	auipc	s7,0x0
 96a:	6aab8b93          	addi	s7,s7,1706 # 1010 <scheduler_thread>
    int alternativeIndex = -1;
 96e:	5afd                	li	s5,-1
    uint64 oldest = __INT64_MAX__;
 970:	001adb13          	srli	s6,s5,0x1
      if (t->state == RUNNABLE && t != scheduler_thread && t->lastTime < oldest)
 974:	4485                	li	s1,1
        oldest = t->lastTime;
        threadIndex = t->tid;
        threadAvailable = true;
      }

      if (t->state == YIELD){
 976:	4989                	li	s3,2
    for (t = ulthreads+1; t < &ulthreads[MAXULTHREADS]; t++)
 978:	00068917          	auipc	s2,0x68
 97c:	bd890913          	addi	s2,s2,-1064 # 68550 <ulthreads+0x3520>
        break;
      }
      
    }
    label : 
      struct ulthread *temp = current_thread;
 980:	00000a17          	auipc	s4,0x0
 984:	698a0a13          	addi	s4,s4,1688 # 1018 <current_thread>
 988:	a88d                	j	9fa <firstComeFirstServe+0xac>
      if (t->state == RUNNABLE && t != scheduler_thread && t->lastTime < oldest)
 98a:	00f58963          	beq	a1,a5,99c <firstComeFirstServe+0x4e>
 98e:	6b98                	ld	a4,16(a5)
 990:	00c77663          	bgeu	a4,a2,99c <firstComeFirstServe+0x4e>
        threadIndex = t->tid;
 994:	0047a803          	lw	a6,4(a5)
        oldest = t->lastTime;
 998:	863a                	mv	a2,a4
        threadAvailable = true;
 99a:	8526                	mv	a0,s1
    for (t = ulthreads+1; t < &ulthreads[MAXULTHREADS]; t++)
 99c:	08878793          	addi	a5,a5,136
 9a0:	01278a63          	beq	a5,s2,9b4 <firstComeFirstServe+0x66>
      if (t->state == RUNNABLE && t != scheduler_thread && t->lastTime < oldest)
 9a4:	4398                	lw	a4,0(a5)
 9a6:	fe9702e3          	beq	a4,s1,98a <firstComeFirstServe+0x3c>
      if (t->state == YIELD){
 9aa:	ff3719e3          	bne	a4,s3,99c <firstComeFirstServe+0x4e>
        t->state = RUNNABLE;
 9ae:	c384                	sw	s1,0(a5)
        alternativeIndex = t->tid;
 9b0:	43d4                	lw	a3,4(a5)
 9b2:	b7ed                	j	99c <firstComeFirstServe+0x4e>
    if (!threadAvailable)
 9b4:	ed31                	bnez	a0,a10 <firstComeFirstServe+0xc2>
      if(alternativeIndex > 0){
 9b6:	04d05f63          	blez	a3,a14 <firstComeFirstServe+0xc6>
      struct ulthread *temp = current_thread;
 9ba:	000a3c03          	ld	s8,0(s4)
      current_thread = &ulthreads[threadIndex];
 9be:	00469793          	slli	a5,a3,0x4
 9c2:	00d78733          	add	a4,a5,a3
 9c6:	070e                	slli	a4,a4,0x3
 9c8:	00064617          	auipc	a2,0x64
 9cc:	66860613          	addi	a2,a2,1640 # 65030 <ulthreads>
 9d0:	9732                	add	a4,a4,a2
 9d2:	00ea3023          	sd	a4,0(s4)
      printf("[*] ultschedule (next tid: %d), time = %d\n", get_current_tid());
 9d6:	434c                	lw	a1,4(a4)
 9d8:	00000517          	auipc	a0,0x0
 9dc:	58050513          	addi	a0,a0,1408 # f58 <digits+0x38>
 9e0:	00000097          	auipc	ra,0x0
 9e4:	d0c080e7          	jalr	-756(ra) # 6ec <printf>
      ulthread_context_switch(&temp->context, &current_thread->context);
 9e8:	000a3583          	ld	a1,0(s4)
 9ec:	05e1                	addi	a1,a1,24
 9ee:	018c0513          	addi	a0,s8,24
 9f2:	00000097          	auipc	ra,0x0
 9f6:	378080e7          	jalr	888(ra) # d6a <ulthread_context_switch>
      if (t->state == RUNNABLE && t != scheduler_thread && t->lastTime < oldest)
 9fa:	000bb583          	ld	a1,0(s7)
    int alternativeIndex = -1;
 9fe:	86d6                	mv	a3,s5
    int threadIndex = -1;
 a00:	8856                	mv	a6,s5
    uint64 oldest = __INT64_MAX__;
 a02:	865a                	mv	a2,s6
    bool threadAvailable = false;
 a04:	4501                	li	a0,0
    for (t = ulthreads+1; t < &ulthreads[MAXULTHREADS]; t++)
 a06:	00064797          	auipc	a5,0x64
 a0a:	6b278793          	addi	a5,a5,1714 # 650b8 <ulthreads+0x88>
 a0e:	bf59                	j	9a4 <firstComeFirstServe+0x56>
    label : 
 a10:	86c2                	mv	a3,a6
 a12:	b765                	j	9ba <firstComeFirstServe+0x6c>
  }
}
 a14:	60a6                	ld	ra,72(sp)
 a16:	6406                	ld	s0,64(sp)
 a18:	74e2                	ld	s1,56(sp)
 a1a:	7942                	ld	s2,48(sp)
 a1c:	79a2                	ld	s3,40(sp)
 a1e:	7a02                	ld	s4,32(sp)
 a20:	6ae2                	ld	s5,24(sp)
 a22:	6b42                	ld	s6,16(sp)
 a24:	6ba2                	ld	s7,8(sp)
 a26:	6c02                	ld	s8,0(sp)
 a28:	6161                	addi	sp,sp,80
 a2a:	8082                	ret

0000000000000a2c <priorityScheduling>:


void priorityScheduling(void)
{
 a2c:	715d                	addi	sp,sp,-80
 a2e:	e486                	sd	ra,72(sp)
 a30:	e0a2                	sd	s0,64(sp)
 a32:	fc26                	sd	s1,56(sp)
 a34:	f84a                	sd	s2,48(sp)
 a36:	f44e                	sd	s3,40(sp)
 a38:	f052                	sd	s4,32(sp)
 a3a:	ec56                	sd	s5,24(sp)
 a3c:	e85a                	sd	s6,16(sp)
 a3e:	e45e                	sd	s7,8(sp)
 a40:	0880                	addi	s0,sp,80
    int maxPriority = -1;
    int threadIndex = -1;
    int alternativeIndex = -1;
    for (t = ulthreads+1; t < &ulthreads[MAXULTHREADS]; t++)
    {
      if (t->state == RUNNABLE && t != scheduler_thread && t->priority > maxPriority)
 a42:	00000b17          	auipc	s6,0x0
 a46:	5ceb0b13          	addi	s6,s6,1486 # 1010 <scheduler_thread>
    int alternativeIndex = -1;
 a4a:	5a7d                	li	s4,-1
      if (t->state == RUNNABLE && t != scheduler_thread && t->priority > maxPriority)
 a4c:	4485                	li	s1,1
        // flag = true;

        // break; // switch to highest-priority thread and exit loop
      }

      if (t->state == YIELD){
 a4e:	4989                	li	s3,2
    for (t = ulthreads+1; t < &ulthreads[MAXULTHREADS]; t++)
 a50:	00068917          	auipc	s2,0x68
 a54:	b0090913          	addi	s2,s2,-1280 # 68550 <ulthreads+0x3520>
        break;
      }
      
    }
    label : 
      struct ulthread *temp = current_thread;
 a58:	00000a97          	auipc	s5,0x0
 a5c:	5c0a8a93          	addi	s5,s5,1472 # 1018 <current_thread>
 a60:	a88d                	j	ad2 <priorityScheduling+0xa6>
      if (t->state == RUNNABLE && t != scheduler_thread && t->priority > maxPriority)
 a62:	00f58963          	beq	a1,a5,a74 <priorityScheduling+0x48>
 a66:	47d8                	lw	a4,12(a5)
 a68:	00e65663          	bge	a2,a4,a74 <priorityScheduling+0x48>
        threadIndex = t->tid;
 a6c:	0047a803          	lw	a6,4(a5)
        maxPriority = t->priority;
 a70:	863a                	mv	a2,a4
        threadAvailable = true;
 a72:	8526                	mv	a0,s1
    for (t = ulthreads+1; t < &ulthreads[MAXULTHREADS]; t++)
 a74:	08878793          	addi	a5,a5,136
 a78:	01278a63          	beq	a5,s2,a8c <priorityScheduling+0x60>
      if (t->state == RUNNABLE && t != scheduler_thread && t->priority > maxPriority)
 a7c:	4398                	lw	a4,0(a5)
 a7e:	fe9702e3          	beq	a4,s1,a62 <priorityScheduling+0x36>
      if (t->state == YIELD){
 a82:	ff3719e3          	bne	a4,s3,a74 <priorityScheduling+0x48>
        t->state = RUNNABLE;
 a86:	c384                	sw	s1,0(a5)
        alternativeIndex = t->tid;
 a88:	43d4                	lw	a3,4(a5)
 a8a:	b7ed                	j	a74 <priorityScheduling+0x48>
    if (!threadAvailable)
 a8c:	ed31                	bnez	a0,ae8 <priorityScheduling+0xbc>
      if(alternativeIndex > 0){
 a8e:	04d05f63          	blez	a3,aec <priorityScheduling+0xc0>
      struct ulthread *temp = current_thread;
 a92:	000abb83          	ld	s7,0(s5)
      current_thread = &ulthreads[threadIndex];
 a96:	00469793          	slli	a5,a3,0x4
 a9a:	00d78733          	add	a4,a5,a3
 a9e:	070e                	slli	a4,a4,0x3
 aa0:	00064617          	auipc	a2,0x64
 aa4:	59060613          	addi	a2,a2,1424 # 65030 <ulthreads>
 aa8:	9732                	add	a4,a4,a2
 aaa:	00eab023          	sd	a4,0(s5)
      printf("[*] ultschedule (next tid: %d)\n", get_current_tid());
 aae:	434c                	lw	a1,4(a4)
 ab0:	00000517          	auipc	a0,0x0
 ab4:	48850513          	addi	a0,a0,1160 # f38 <digits+0x18>
 ab8:	00000097          	auipc	ra,0x0
 abc:	c34080e7          	jalr	-972(ra) # 6ec <printf>
      ulthread_context_switch(&temp->context, &current_thread->context);
 ac0:	000ab583          	ld	a1,0(s5)
 ac4:	05e1                	addi	a1,a1,24
 ac6:	018b8513          	addi	a0,s7,24
 aca:	00000097          	auipc	ra,0x0
 ace:	2a0080e7          	jalr	672(ra) # d6a <ulthread_context_switch>
      if (t->state == RUNNABLE && t != scheduler_thread && t->priority > maxPriority)
 ad2:	000b3583          	ld	a1,0(s6)
    int alternativeIndex = -1;
 ad6:	86d2                	mv	a3,s4
    int threadIndex = -1;
 ad8:	8852                	mv	a6,s4
    int maxPriority = -1;
 ada:	8652                	mv	a2,s4
    bool threadAvailable = false;
 adc:	4501                	li	a0,0
    for (t = ulthreads+1; t < &ulthreads[MAXULTHREADS]; t++)
 ade:	00064797          	auipc	a5,0x64
 ae2:	5da78793          	addi	a5,a5,1498 # 650b8 <ulthreads+0x88>
 ae6:	bf59                	j	a7c <priorityScheduling+0x50>
    label : 
 ae8:	86c2                	mv	a3,a6
 aea:	b765                	j	a92 <priorityScheduling+0x66>
  }
}
 aec:	60a6                	ld	ra,72(sp)
 aee:	6406                	ld	s0,64(sp)
 af0:	74e2                	ld	s1,56(sp)
 af2:	7942                	ld	s2,48(sp)
 af4:	79a2                	ld	s3,40(sp)
 af6:	7a02                	ld	s4,32(sp)
 af8:	6ae2                	ld	s5,24(sp)
 afa:	6b42                	ld	s6,16(sp)
 afc:	6ba2                	ld	s7,8(sp)
 afe:	6161                	addi	sp,sp,80
 b00:	8082                	ret

0000000000000b02 <ulthread_init>:

/* Thread initialization */
void ulthread_init(int schedalgo)
{
 b02:	1141                	addi	sp,sp,-16
 b04:	e422                	sd	s0,8(sp)
 b06:	0800                	addi	s0,sp,16
  struct ulthread *t;
  int i;
  for (i = 0, t = ulthreads; t < &ulthreads[MAXULTHREADS]; t++, i++)
 b08:	4701                	li	a4,0
 b0a:	00064797          	auipc	a5,0x64
 b0e:	52678793          	addi	a5,a5,1318 # 65030 <ulthreads>
 b12:	00068697          	auipc	a3,0x68
 b16:	a3e68693          	addi	a3,a3,-1474 # 68550 <ulthreads+0x3520>
  {
    t->state = FREE;
 b1a:	0007a023          	sw	zero,0(a5)
    t->tid = i;
 b1e:	c3d8                	sw	a4,4(a5)
  for (i = 0, t = ulthreads; t < &ulthreads[MAXULTHREADS]; t++, i++)
 b20:	08878793          	addi	a5,a5,136
 b24:	2705                	addiw	a4,a4,1
 b26:	fed79ae3          	bne	a5,a3,b1a <ulthread_init+0x18>
  }
  current_thread = &ulthreads[0];
 b2a:	00064797          	auipc	a5,0x64
 b2e:	50678793          	addi	a5,a5,1286 # 65030 <ulthreads>
 b32:	00000717          	auipc	a4,0x0
 b36:	4ef73323          	sd	a5,1254(a4) # 1018 <current_thread>
  scheduler_thread = &ulthreads[0];
 b3a:	00000717          	auipc	a4,0x0
 b3e:	4cf73b23          	sd	a5,1238(a4) # 1010 <scheduler_thread>
  scheduler_thread->state = RUNNABLE;
 b42:	4705                	li	a4,1
 b44:	c398                	sw	a4,0(a5)
  t->state = FREE;
 b46:	00068797          	auipc	a5,0x68
 b4a:	a007a523          	sw	zero,-1526(a5) # 68550 <ulthreads+0x3520>
  algorithm = schedalgo;
 b4e:	00000797          	auipc	a5,0x0
 b52:	4aa7ad23          	sw	a0,1210(a5) # 1008 <algorithm>
}
 b56:	6422                	ld	s0,8(sp)
 b58:	0141                	addi	sp,sp,16
 b5a:	8082                	ret

0000000000000b5c <ulthread_create>:

/* Thread creation */
bool ulthread_create(uint64 start, uint64 stack, uint64 args[], int priority)
{
 b5c:	7179                	addi	sp,sp,-48
 b5e:	f406                	sd	ra,40(sp)
 b60:	f022                	sd	s0,32(sp)
 b62:	ec26                	sd	s1,24(sp)
 b64:	e84a                	sd	s2,16(sp)
 b66:	e44e                	sd	s3,8(sp)
 b68:	e052                	sd	s4,0(sp)
 b6a:	1800                	addi	s0,sp,48
 b6c:	89aa                	mv	s3,a0
 b6e:	8a2e                	mv	s4,a1
 b70:	8932                	mv	s2,a2
  /* Please add thread-id instead of '0' here. */
  struct ulthread *t;
  bool flag = false;
  for (t = ulthreads; t < &ulthreads[MAXULTHREADS]; t++)
 b72:	00064497          	auipc	s1,0x64
 b76:	4be48493          	addi	s1,s1,1214 # 65030 <ulthreads>
 b7a:	00068717          	auipc	a4,0x68
 b7e:	9d670713          	addi	a4,a4,-1578 # 68550 <ulthreads+0x3520>
  {
    if (t->state == FREE)
 b82:	409c                	lw	a5,0(s1)
 b84:	cf89                	beqz	a5,b9e <ulthread_create+0x42>
  for (t = ulthreads; t < &ulthreads[MAXULTHREADS]; t++)
 b86:	08848493          	addi	s1,s1,136
 b8a:	fee49ce3          	bne	s1,a4,b82 <ulthread_create+0x26>
      break;
    }
  }
  if (!flag)
  {
    return false;
 b8e:	4501                	li	a0,0
 b90:	a871                	j	c2c <ulthread_create+0xd0>
  t->sp = (int)(stack + USTACKSIZE); // set sp to the top of the stack
  t->state = RUNNABLE;
  t->priority = priority;

  if(algorithm==FCFS){
    t->lastTime = ctime();
 b92:	00000097          	auipc	ra,0x0
 b96:	88a080e7          	jalr	-1910(ra) # 41c <ctime>
 b9a:	e888                	sd	a0,16(s1)
 b9c:	a839                	j	bba <ulthread_create+0x5e>
  t->sp = (int)(stack + USTACKSIZE); // set sp to the top of the stack
 b9e:	6785                	lui	a5,0x1
 ba0:	014787bb          	addw	a5,a5,s4
 ba4:	c49c                	sw	a5,8(s1)
  t->state = RUNNABLE;
 ba6:	4785                	li	a5,1
 ba8:	c09c                	sw	a5,0(s1)
  t->priority = priority;
 baa:	c4d4                	sw	a3,12(s1)
  if(algorithm==FCFS){
 bac:	00000717          	auipc	a4,0x0
 bb0:	45c72703          	lw	a4,1116(a4) # 1008 <algorithm>
 bb4:	4789                	li	a5,2
 bb6:	fcf70ee3          	beq	a4,a5,b92 <ulthread_create+0x36>
  }

  for (int argc = 0; argc < 6; argc++)
 bba:	874a                	mv	a4,s2
 bbc:	03090693          	addi	a3,s2,48
  {
    t->sp -= 16;
 bc0:	449c                	lw	a5,8(s1)
 bc2:	37c1                	addiw	a5,a5,-16 # ff0 <digits+0xd0>
 bc4:	0007881b          	sext.w	a6,a5
 bc8:	c49c                	sw	a5,8(s1)
    *(uint64 *)(t->sp) = (uint64)args[argc];
 bca:	631c                	ld	a5,0(a4)
 bcc:	00f83023          	sd	a5,0(a6)
  for (int argc = 0; argc < 6; argc++)
 bd0:	0721                	addi	a4,a4,8
 bd2:	fed717e3          	bne	a4,a3,bc0 <ulthread_create+0x64>
  }

  memset(&t->context, 0, sizeof(t->context));
 bd6:	07000613          	li	a2,112
 bda:	4581                	li	a1,0
 bdc:	01848513          	addi	a0,s1,24
 be0:	fffff097          	auipc	ra,0xfffff
 be4:	5a2080e7          	jalr	1442(ra) # 182 <memset>
  t->context.ra = start;
 be8:	0134bc23          	sd	s3,24(s1)
  t->context.sp = t->sp;
 bec:	449c                	lw	a5,8(s1)
 bee:	f09c                	sd	a5,32(s1)
  t->context.s0 = args[0];
 bf0:	00093783          	ld	a5,0(s2)
 bf4:	f49c                	sd	a5,40(s1)
  t->context.s1 = args[1];
 bf6:	00893783          	ld	a5,8(s2)
 bfa:	f89c                	sd	a5,48(s1)
  t->context.s2 = args[2];
 bfc:	01093783          	ld	a5,16(s2)
 c00:	fc9c                	sd	a5,56(s1)
  t->context.s3 = args[3];
 c02:	01893783          	ld	a5,24(s2)
 c06:	e0bc                	sd	a5,64(s1)
  t->context.s4 = args[4];
 c08:	02093783          	ld	a5,32(s2)
 c0c:	e4bc                	sd	a5,72(s1)
  t->context.s5 = args[5];
 c0e:	02893783          	ld	a5,40(s2)
 c12:	e8bc                	sd	a5,80(s1)

  printf("[*] ultcreate(tid: %d, ra: %p, sp: %p)\n", t->tid, start, stack);
 c14:	86d2                	mv	a3,s4
 c16:	864e                	mv	a2,s3
 c18:	40cc                	lw	a1,4(s1)
 c1a:	00000517          	auipc	a0,0x0
 c1e:	36e50513          	addi	a0,a0,878 # f88 <digits+0x68>
 c22:	00000097          	auipc	ra,0x0
 c26:	aca080e7          	jalr	-1334(ra) # 6ec <printf>
  return true;
 c2a:	4505                	li	a0,1
}
 c2c:	70a2                	ld	ra,40(sp)
 c2e:	7402                	ld	s0,32(sp)
 c30:	64e2                	ld	s1,24(sp)
 c32:	6942                	ld	s2,16(sp)
 c34:	69a2                	ld	s3,8(sp)
 c36:	6a02                	ld	s4,0(sp)
 c38:	6145                	addi	sp,sp,48
 c3a:	8082                	ret

0000000000000c3c <ulthread_schedule>:

/* Thread scheduler */
void ulthread_schedule(void)
{
 c3c:	1141                	addi	sp,sp,-16
 c3e:	e406                	sd	ra,8(sp)
 c40:	e022                	sd	s0,0(sp)
 c42:	0800                	addi	s0,sp,16
  switch (algorithm)
 c44:	00000797          	auipc	a5,0x0
 c48:	3c47a783          	lw	a5,964(a5) # 1008 <algorithm>
 c4c:	4705                	li	a4,1
 c4e:	02e78463          	beq	a5,a4,c76 <ulthread_schedule+0x3a>
 c52:	4709                	li	a4,2
 c54:	00e78c63          	beq	a5,a4,c6c <ulthread_schedule+0x30>
 c58:	c789                	beqz	a5,c62 <ulthread_schedule+0x26>

  // Push argument strings, prepare rest of stack in ustack.

  // Switch between thread contexts
  // ulthread_context_switch(NULL, NULL);
}
 c5a:	60a2                	ld	ra,8(sp)
 c5c:	6402                	ld	s0,0(sp)
 c5e:	0141                	addi	sp,sp,16
 c60:	8082                	ret
    roundRobin();
 c62:	00000097          	auipc	ra,0x0
 c66:	c3e080e7          	jalr	-962(ra) # 8a0 <roundRobin>
    break;
 c6a:	bfc5                	j	c5a <ulthread_schedule+0x1e>
    firstComeFirstServe();
 c6c:	00000097          	auipc	ra,0x0
 c70:	ce2080e7          	jalr	-798(ra) # 94e <firstComeFirstServe>
    break;
 c74:	b7dd                	j	c5a <ulthread_schedule+0x1e>
    priorityScheduling();
 c76:	00000097          	auipc	ra,0x0
 c7a:	db6080e7          	jalr	-586(ra) # a2c <priorityScheduling>
}
 c7e:	bff1                	j	c5a <ulthread_schedule+0x1e>

0000000000000c80 <ulthread_yield>:

/* Yield CPU time to some other thread. */
void ulthread_yield(void)
{
 c80:	1101                	addi	sp,sp,-32
 c82:	ec06                	sd	ra,24(sp)
 c84:	e822                	sd	s0,16(sp)
 c86:	e426                	sd	s1,8(sp)
 c88:	e04a                	sd	s2,0(sp)
 c8a:	1000                	addi	s0,sp,32
  current_thread->state = YIELD;
 c8c:	00000797          	auipc	a5,0x0
 c90:	38c78793          	addi	a5,a5,908 # 1018 <current_thread>
 c94:	6398                	ld	a4,0(a5)
 c96:	4909                	li	s2,2
 c98:	01272023          	sw	s2,0(a4)
  struct ulthread *temp = current_thread;
 c9c:	6384                	ld	s1,0(a5)
  printf("[*] ultyield(tid: %d)\n", current_thread->tid);
 c9e:	40cc                	lw	a1,4(s1)
 ca0:	00000517          	auipc	a0,0x0
 ca4:	31050513          	addi	a0,a0,784 # fb0 <digits+0x90>
 ca8:	00000097          	auipc	ra,0x0
 cac:	a44080e7          	jalr	-1468(ra) # 6ec <printf>
  if(algorithm==FCFS){
 cb0:	00000797          	auipc	a5,0x0
 cb4:	3587a783          	lw	a5,856(a5) # 1008 <algorithm>
 cb8:	03278763          	beq	a5,s2,ce6 <ulthread_yield+0x66>
    current_thread->lastTime = ctime();
  }
  current_thread = scheduler_thread;
 cbc:	00000597          	auipc	a1,0x0
 cc0:	3545b583          	ld	a1,852(a1) # 1010 <scheduler_thread>
 cc4:	00000797          	auipc	a5,0x0
 cc8:	34b7ba23          	sd	a1,852(a5) # 1018 <current_thread>
  
  ulthread_context_switch(&temp->context, &scheduler_thread->context);
 ccc:	05e1                	addi	a1,a1,24
 cce:	01848513          	addi	a0,s1,24
 cd2:	00000097          	auipc	ra,0x0
 cd6:	098080e7          	jalr	152(ra) # d6a <ulthread_context_switch>
  // ulthread_schedule();
}
 cda:	60e2                	ld	ra,24(sp)
 cdc:	6442                	ld	s0,16(sp)
 cde:	64a2                	ld	s1,8(sp)
 ce0:	6902                	ld	s2,0(sp)
 ce2:	6105                	addi	sp,sp,32
 ce4:	8082                	ret
    current_thread->lastTime = ctime();
 ce6:	fffff097          	auipc	ra,0xfffff
 cea:	736080e7          	jalr	1846(ra) # 41c <ctime>
 cee:	00000797          	auipc	a5,0x0
 cf2:	32a7b783          	ld	a5,810(a5) # 1018 <current_thread>
 cf6:	eb88                	sd	a0,16(a5)
 cf8:	b7d1                	j	cbc <ulthread_yield+0x3c>

0000000000000cfa <ulthread_destroy>:

/* Destroy thread */
void ulthread_destroy(void)
{
 cfa:	1101                	addi	sp,sp,-32
 cfc:	ec06                	sd	ra,24(sp)
 cfe:	e822                	sd	s0,16(sp)
 d00:	e426                	sd	s1,8(sp)
 d02:	e04a                	sd	s2,0(sp)
 d04:	1000                	addi	s0,sp,32
  memset(&current_thread->context, 0, sizeof(current_thread->context));
 d06:	00000497          	auipc	s1,0x0
 d0a:	31248493          	addi	s1,s1,786 # 1018 <current_thread>
 d0e:	6088                	ld	a0,0(s1)
 d10:	07000613          	li	a2,112
 d14:	4581                	li	a1,0
 d16:	0561                	addi	a0,a0,24
 d18:	fffff097          	auipc	ra,0xfffff
 d1c:	46a080e7          	jalr	1130(ra) # 182 <memset>
  current_thread->sp = 0;
 d20:	609c                	ld	a5,0(s1)
 d22:	0007a423          	sw	zero,8(a5)
  current_thread->priority = -1;
 d26:	577d                	li	a4,-1
 d28:	c7d8                	sw	a4,12(a5)
  current_thread->state = FREE;
 d2a:	0007a023          	sw	zero,0(a5)

  struct ulthread *temp = current_thread;
 d2e:	0004b903          	ld	s2,0(s1)

  printf("[*] ultdestroy(tid: %d)\n", get_current_tid());
 d32:	00492583          	lw	a1,4(s2)
 d36:	00000517          	auipc	a0,0x0
 d3a:	29250513          	addi	a0,a0,658 # fc8 <digits+0xa8>
 d3e:	00000097          	auipc	ra,0x0
 d42:	9ae080e7          	jalr	-1618(ra) # 6ec <printf>
  current_thread = scheduler_thread;
 d46:	00000597          	auipc	a1,0x0
 d4a:	2ca5b583          	ld	a1,714(a1) # 1010 <scheduler_thread>
 d4e:	e08c                	sd	a1,0(s1)
  ulthread_context_switch(&temp->context, &scheduler_thread->context);
 d50:	05e1                	addi	a1,a1,24
 d52:	01890513          	addi	a0,s2,24
 d56:	00000097          	auipc	ra,0x0
 d5a:	014080e7          	jalr	20(ra) # d6a <ulthread_context_switch>
}
 d5e:	60e2                	ld	ra,24(sp)
 d60:	6442                	ld	s0,16(sp)
 d62:	64a2                	ld	s1,8(sp)
 d64:	6902                	ld	s2,0(sp)
 d66:	6105                	addi	sp,sp,32
 d68:	8082                	ret

0000000000000d6a <ulthread_context_switch>:
 d6a:	00153023          	sd	ra,0(a0)
 d6e:	00253423          	sd	sp,8(a0)
 d72:	e900                	sd	s0,16(a0)
 d74:	ed04                	sd	s1,24(a0)
 d76:	03253023          	sd	s2,32(a0)
 d7a:	03353423          	sd	s3,40(a0)
 d7e:	03453823          	sd	s4,48(a0)
 d82:	03553c23          	sd	s5,56(a0)
 d86:	05653023          	sd	s6,64(a0)
 d8a:	05753423          	sd	s7,72(a0)
 d8e:	05853823          	sd	s8,80(a0)
 d92:	05953c23          	sd	s9,88(a0)
 d96:	07a53023          	sd	s10,96(a0)
 d9a:	07b53423          	sd	s11,104(a0)
 d9e:	0005b083          	ld	ra,0(a1)
 da2:	0085b103          	ld	sp,8(a1)
 da6:	6980                	ld	s0,16(a1)
 da8:	6d84                	ld	s1,24(a1)
 daa:	0205b903          	ld	s2,32(a1)
 dae:	0285b983          	ld	s3,40(a1)
 db2:	0305ba03          	ld	s4,48(a1)
 db6:	0385ba83          	ld	s5,56(a1)
 dba:	0405bb03          	ld	s6,64(a1)
 dbe:	0485bb83          	ld	s7,72(a1)
 dc2:	0505bc03          	ld	s8,80(a1)
 dc6:	0585bc83          	ld	s9,88(a1)
 dca:	0605bd03          	ld	s10,96(a1)
 dce:	0685bd83          	ld	s11,104(a1)
 dd2:	6546                	ld	a0,80(sp)
 dd4:	6586                	ld	a1,64(sp)
 dd6:	7642                	ld	a2,48(sp)
 dd8:	7682                	ld	a3,32(sp)
 dda:	6742                	ld	a4,16(sp)
 ddc:	6782                	ld	a5,0(sp)
 dde:	8082                	ret
