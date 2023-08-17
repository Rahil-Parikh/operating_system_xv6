
user/_test3:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <ul_start_func>:
#include <stdarg.h>

/* Stack region for different threads */
char stacks[PGSIZE*MAXULTHREADS];

void ul_start_func(int a1) {
   0:	1101                	addi	sp,sp,-32
   2:	ec06                	sd	ra,24(sp)
   4:	e822                	sd	s0,16(sp)
   6:	e426                	sd	s1,8(sp)
   8:	1000                	addi	s0,sp,32
   a:	84aa                	mv	s1,a0
    printf("[.] started the thread function (tid = %d, a1 = %d)\n", get_current_tid(), a1);
   c:	00001097          	auipc	ra,0x1
  10:	856080e7          	jalr	-1962(ra) # 862 <get_current_tid>
  14:	85aa                	mv	a1,a0
  16:	8626                	mv	a2,s1
  18:	00001517          	auipc	a0,0x1
  1c:	da850513          	addi	a0,a0,-600 # dc0 <ulthread_context_switch+0x7e>
  20:	00000097          	auipc	ra,0x0
  24:	6a4080e7          	jalr	1700(ra) # 6c4 <printf>

    /* Notify for a thread exit. */
    ulthread_destroy();
  28:	00001097          	auipc	ra,0x1
  2c:	caa080e7          	jalr	-854(ra) # cd2 <ulthread_destroy>
}
  30:	60e2                	ld	ra,24(sp)
  32:	6442                	ld	s0,16(sp)
  34:	64a2                	ld	s1,8(sp)
  36:	6105                	addi	sp,sp,32
  38:	8082                	ret

000000000000003a <main>:

int
main(int argc, char *argv[])
{
  3a:	7139                	addi	sp,sp,-64
  3c:	fc06                	sd	ra,56(sp)
  3e:	f822                	sd	s0,48(sp)
  40:	0080                	addi	s0,sp,64
    /* Clear the stack region */
    memset(&stacks, 0, sizeof(stacks));
  42:	00064637          	lui	a2,0x64
  46:	4581                	li	a1,0
  48:	00001517          	auipc	a0,0x1
  4c:	fd850513          	addi	a0,a0,-40 # 1020 <stacks>
  50:	00000097          	auipc	ra,0x0
  54:	10a080e7          	jalr	266(ra) # 15a <memset>

    /* Initialize the user-level threading library */
    ulthread_init(ROUNDROBIN);
  58:	4501                	li	a0,0
  5a:	00001097          	auipc	ra,0x1
  5e:	a80080e7          	jalr	-1408(ra) # ada <ulthread_init>

    /* Create a user-level thread */
    uint64 args[6] = {1,1,1,1,0,0};
  62:	00001797          	auipc	a5,0x1
  66:	dde78793          	addi	a5,a5,-546 # e40 <ulthread_context_switch+0xfe>
  6a:	6388                	ld	a0,0(a5)
  6c:	678c                	ld	a1,8(a5)
  6e:	6b90                	ld	a2,16(a5)
  70:	6f94                	ld	a3,24(a5)
  72:	7398                	ld	a4,32(a5)
  74:	779c                	ld	a5,40(a5)
  76:	fca43023          	sd	a0,-64(s0)
  7a:	fcb43423          	sd	a1,-56(s0)
  7e:	fcc43823          	sd	a2,-48(s0)
  82:	fcd43c23          	sd	a3,-40(s0)
  86:	fee43023          	sd	a4,-32(s0)
  8a:	fef43423          	sd	a5,-24(s0)
    ulthread_create((uint64) ul_start_func, (uint64) stacks+PGSIZE, args, -1);
  8e:	56fd                	li	a3,-1
  90:	fc040613          	addi	a2,s0,-64
  94:	00002597          	auipc	a1,0x2
  98:	f8c58593          	addi	a1,a1,-116 # 2020 <stacks+0x1000>
  9c:	00000517          	auipc	a0,0x0
  a0:	f6450513          	addi	a0,a0,-156 # 0 <ul_start_func>
  a4:	00001097          	auipc	ra,0x1
  a8:	a90080e7          	jalr	-1392(ra) # b34 <ulthread_create>

    /* Schedule all of the threads */
    ulthread_schedule();
  ac:	00001097          	auipc	ra,0x1
  b0:	b68080e7          	jalr	-1176(ra) # c14 <ulthread_schedule>

    printf("[*] User-Level Threading Test #3 (Arguments Checking) Complete.\n");
  b4:	00001517          	auipc	a0,0x1
  b8:	d4450513          	addi	a0,a0,-700 # df8 <ulthread_context_switch+0xb6>
  bc:	00000097          	auipc	ra,0x0
  c0:	608080e7          	jalr	1544(ra) # 6c4 <printf>
    return 0;
}
  c4:	4501                	li	a0,0
  c6:	70e2                	ld	ra,56(sp)
  c8:	7442                	ld	s0,48(sp)
  ca:	6121                	addi	sp,sp,64
  cc:	8082                	ret

00000000000000ce <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
  ce:	1141                	addi	sp,sp,-16
  d0:	e406                	sd	ra,8(sp)
  d2:	e022                	sd	s0,0(sp)
  d4:	0800                	addi	s0,sp,16
  extern int main();
  main();
  d6:	00000097          	auipc	ra,0x0
  da:	f64080e7          	jalr	-156(ra) # 3a <main>
  exit(0);
  de:	4501                	li	a0,0
  e0:	00000097          	auipc	ra,0x0
  e4:	274080e7          	jalr	628(ra) # 354 <exit>

00000000000000e8 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
  e8:	1141                	addi	sp,sp,-16
  ea:	e422                	sd	s0,8(sp)
  ec:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  ee:	87aa                	mv	a5,a0
  f0:	0585                	addi	a1,a1,1
  f2:	0785                	addi	a5,a5,1
  f4:	fff5c703          	lbu	a4,-1(a1)
  f8:	fee78fa3          	sb	a4,-1(a5)
  fc:	fb75                	bnez	a4,f0 <strcpy+0x8>
    ;
  return os;
}
  fe:	6422                	ld	s0,8(sp)
 100:	0141                	addi	sp,sp,16
 102:	8082                	ret

0000000000000104 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 104:	1141                	addi	sp,sp,-16
 106:	e422                	sd	s0,8(sp)
 108:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 10a:	00054783          	lbu	a5,0(a0)
 10e:	cb91                	beqz	a5,122 <strcmp+0x1e>
 110:	0005c703          	lbu	a4,0(a1)
 114:	00f71763          	bne	a4,a5,122 <strcmp+0x1e>
    p++, q++;
 118:	0505                	addi	a0,a0,1
 11a:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 11c:	00054783          	lbu	a5,0(a0)
 120:	fbe5                	bnez	a5,110 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 122:	0005c503          	lbu	a0,0(a1)
}
 126:	40a7853b          	subw	a0,a5,a0
 12a:	6422                	ld	s0,8(sp)
 12c:	0141                	addi	sp,sp,16
 12e:	8082                	ret

0000000000000130 <strlen>:

uint
strlen(const char *s)
{
 130:	1141                	addi	sp,sp,-16
 132:	e422                	sd	s0,8(sp)
 134:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 136:	00054783          	lbu	a5,0(a0)
 13a:	cf91                	beqz	a5,156 <strlen+0x26>
 13c:	0505                	addi	a0,a0,1
 13e:	87aa                	mv	a5,a0
 140:	86be                	mv	a3,a5
 142:	0785                	addi	a5,a5,1
 144:	fff7c703          	lbu	a4,-1(a5)
 148:	ff65                	bnez	a4,140 <strlen+0x10>
 14a:	40a6853b          	subw	a0,a3,a0
 14e:	2505                	addiw	a0,a0,1
    ;
  return n;
}
 150:	6422                	ld	s0,8(sp)
 152:	0141                	addi	sp,sp,16
 154:	8082                	ret
  for(n = 0; s[n]; n++)
 156:	4501                	li	a0,0
 158:	bfe5                	j	150 <strlen+0x20>

000000000000015a <memset>:

void*
memset(void *dst, int c, uint n)
{
 15a:	1141                	addi	sp,sp,-16
 15c:	e422                	sd	s0,8(sp)
 15e:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 160:	ca19                	beqz	a2,176 <memset+0x1c>
 162:	87aa                	mv	a5,a0
 164:	1602                	slli	a2,a2,0x20
 166:	9201                	srli	a2,a2,0x20
 168:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 16c:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 170:	0785                	addi	a5,a5,1
 172:	fee79de3          	bne	a5,a4,16c <memset+0x12>
  }
  return dst;
}
 176:	6422                	ld	s0,8(sp)
 178:	0141                	addi	sp,sp,16
 17a:	8082                	ret

000000000000017c <strchr>:

char*
strchr(const char *s, char c)
{
 17c:	1141                	addi	sp,sp,-16
 17e:	e422                	sd	s0,8(sp)
 180:	0800                	addi	s0,sp,16
  for(; *s; s++)
 182:	00054783          	lbu	a5,0(a0)
 186:	cb99                	beqz	a5,19c <strchr+0x20>
    if(*s == c)
 188:	00f58763          	beq	a1,a5,196 <strchr+0x1a>
  for(; *s; s++)
 18c:	0505                	addi	a0,a0,1
 18e:	00054783          	lbu	a5,0(a0)
 192:	fbfd                	bnez	a5,188 <strchr+0xc>
      return (char*)s;
  return 0;
 194:	4501                	li	a0,0
}
 196:	6422                	ld	s0,8(sp)
 198:	0141                	addi	sp,sp,16
 19a:	8082                	ret
  return 0;
 19c:	4501                	li	a0,0
 19e:	bfe5                	j	196 <strchr+0x1a>

00000000000001a0 <gets>:

char*
gets(char *buf, int max)
{
 1a0:	711d                	addi	sp,sp,-96
 1a2:	ec86                	sd	ra,88(sp)
 1a4:	e8a2                	sd	s0,80(sp)
 1a6:	e4a6                	sd	s1,72(sp)
 1a8:	e0ca                	sd	s2,64(sp)
 1aa:	fc4e                	sd	s3,56(sp)
 1ac:	f852                	sd	s4,48(sp)
 1ae:	f456                	sd	s5,40(sp)
 1b0:	f05a                	sd	s6,32(sp)
 1b2:	ec5e                	sd	s7,24(sp)
 1b4:	1080                	addi	s0,sp,96
 1b6:	8baa                	mv	s7,a0
 1b8:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1ba:	892a                	mv	s2,a0
 1bc:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 1be:	4aa9                	li	s5,10
 1c0:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 1c2:	89a6                	mv	s3,s1
 1c4:	2485                	addiw	s1,s1,1
 1c6:	0344d863          	bge	s1,s4,1f6 <gets+0x56>
    cc = read(0, &c, 1);
 1ca:	4605                	li	a2,1
 1cc:	faf40593          	addi	a1,s0,-81
 1d0:	4501                	li	a0,0
 1d2:	00000097          	auipc	ra,0x0
 1d6:	19a080e7          	jalr	410(ra) # 36c <read>
    if(cc < 1)
 1da:	00a05e63          	blez	a0,1f6 <gets+0x56>
    buf[i++] = c;
 1de:	faf44783          	lbu	a5,-81(s0)
 1e2:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 1e6:	01578763          	beq	a5,s5,1f4 <gets+0x54>
 1ea:	0905                	addi	s2,s2,1
 1ec:	fd679be3          	bne	a5,s6,1c2 <gets+0x22>
  for(i=0; i+1 < max; ){
 1f0:	89a6                	mv	s3,s1
 1f2:	a011                	j	1f6 <gets+0x56>
 1f4:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 1f6:	99de                	add	s3,s3,s7
 1f8:	00098023          	sb	zero,0(s3)
  return buf;
}
 1fc:	855e                	mv	a0,s7
 1fe:	60e6                	ld	ra,88(sp)
 200:	6446                	ld	s0,80(sp)
 202:	64a6                	ld	s1,72(sp)
 204:	6906                	ld	s2,64(sp)
 206:	79e2                	ld	s3,56(sp)
 208:	7a42                	ld	s4,48(sp)
 20a:	7aa2                	ld	s5,40(sp)
 20c:	7b02                	ld	s6,32(sp)
 20e:	6be2                	ld	s7,24(sp)
 210:	6125                	addi	sp,sp,96
 212:	8082                	ret

0000000000000214 <stat>:

int
stat(const char *n, struct stat *st)
{
 214:	1101                	addi	sp,sp,-32
 216:	ec06                	sd	ra,24(sp)
 218:	e822                	sd	s0,16(sp)
 21a:	e426                	sd	s1,8(sp)
 21c:	e04a                	sd	s2,0(sp)
 21e:	1000                	addi	s0,sp,32
 220:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 222:	4581                	li	a1,0
 224:	00000097          	auipc	ra,0x0
 228:	170080e7          	jalr	368(ra) # 394 <open>
  if(fd < 0)
 22c:	02054563          	bltz	a0,256 <stat+0x42>
 230:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 232:	85ca                	mv	a1,s2
 234:	00000097          	auipc	ra,0x0
 238:	178080e7          	jalr	376(ra) # 3ac <fstat>
 23c:	892a                	mv	s2,a0
  close(fd);
 23e:	8526                	mv	a0,s1
 240:	00000097          	auipc	ra,0x0
 244:	13c080e7          	jalr	316(ra) # 37c <close>
  return r;
}
 248:	854a                	mv	a0,s2
 24a:	60e2                	ld	ra,24(sp)
 24c:	6442                	ld	s0,16(sp)
 24e:	64a2                	ld	s1,8(sp)
 250:	6902                	ld	s2,0(sp)
 252:	6105                	addi	sp,sp,32
 254:	8082                	ret
    return -1;
 256:	597d                	li	s2,-1
 258:	bfc5                	j	248 <stat+0x34>

000000000000025a <atoi>:

int
atoi(const char *s)
{
 25a:	1141                	addi	sp,sp,-16
 25c:	e422                	sd	s0,8(sp)
 25e:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 260:	00054683          	lbu	a3,0(a0)
 264:	fd06879b          	addiw	a5,a3,-48
 268:	0ff7f793          	zext.b	a5,a5
 26c:	4625                	li	a2,9
 26e:	02f66863          	bltu	a2,a5,29e <atoi+0x44>
 272:	872a                	mv	a4,a0
  n = 0;
 274:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 276:	0705                	addi	a4,a4,1
 278:	0025179b          	slliw	a5,a0,0x2
 27c:	9fa9                	addw	a5,a5,a0
 27e:	0017979b          	slliw	a5,a5,0x1
 282:	9fb5                	addw	a5,a5,a3
 284:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 288:	00074683          	lbu	a3,0(a4)
 28c:	fd06879b          	addiw	a5,a3,-48
 290:	0ff7f793          	zext.b	a5,a5
 294:	fef671e3          	bgeu	a2,a5,276 <atoi+0x1c>
  return n;
}
 298:	6422                	ld	s0,8(sp)
 29a:	0141                	addi	sp,sp,16
 29c:	8082                	ret
  n = 0;
 29e:	4501                	li	a0,0
 2a0:	bfe5                	j	298 <atoi+0x3e>

00000000000002a2 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 2a2:	1141                	addi	sp,sp,-16
 2a4:	e422                	sd	s0,8(sp)
 2a6:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 2a8:	02b57463          	bgeu	a0,a1,2d0 <memmove+0x2e>
    while(n-- > 0)
 2ac:	00c05f63          	blez	a2,2ca <memmove+0x28>
 2b0:	1602                	slli	a2,a2,0x20
 2b2:	9201                	srli	a2,a2,0x20
 2b4:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 2b8:	872a                	mv	a4,a0
      *dst++ = *src++;
 2ba:	0585                	addi	a1,a1,1
 2bc:	0705                	addi	a4,a4,1
 2be:	fff5c683          	lbu	a3,-1(a1)
 2c2:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 2c6:	fee79ae3          	bne	a5,a4,2ba <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 2ca:	6422                	ld	s0,8(sp)
 2cc:	0141                	addi	sp,sp,16
 2ce:	8082                	ret
    dst += n;
 2d0:	00c50733          	add	a4,a0,a2
    src += n;
 2d4:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 2d6:	fec05ae3          	blez	a2,2ca <memmove+0x28>
 2da:	fff6079b          	addiw	a5,a2,-1 # 63fff <stacks+0x62fdf>
 2de:	1782                	slli	a5,a5,0x20
 2e0:	9381                	srli	a5,a5,0x20
 2e2:	fff7c793          	not	a5,a5
 2e6:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 2e8:	15fd                	addi	a1,a1,-1
 2ea:	177d                	addi	a4,a4,-1
 2ec:	0005c683          	lbu	a3,0(a1)
 2f0:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 2f4:	fee79ae3          	bne	a5,a4,2e8 <memmove+0x46>
 2f8:	bfc9                	j	2ca <memmove+0x28>

00000000000002fa <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 2fa:	1141                	addi	sp,sp,-16
 2fc:	e422                	sd	s0,8(sp)
 2fe:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 300:	ca05                	beqz	a2,330 <memcmp+0x36>
 302:	fff6069b          	addiw	a3,a2,-1
 306:	1682                	slli	a3,a3,0x20
 308:	9281                	srli	a3,a3,0x20
 30a:	0685                	addi	a3,a3,1
 30c:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 30e:	00054783          	lbu	a5,0(a0)
 312:	0005c703          	lbu	a4,0(a1)
 316:	00e79863          	bne	a5,a4,326 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 31a:	0505                	addi	a0,a0,1
    p2++;
 31c:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 31e:	fed518e3          	bne	a0,a3,30e <memcmp+0x14>
  }
  return 0;
 322:	4501                	li	a0,0
 324:	a019                	j	32a <memcmp+0x30>
      return *p1 - *p2;
 326:	40e7853b          	subw	a0,a5,a4
}
 32a:	6422                	ld	s0,8(sp)
 32c:	0141                	addi	sp,sp,16
 32e:	8082                	ret
  return 0;
 330:	4501                	li	a0,0
 332:	bfe5                	j	32a <memcmp+0x30>

0000000000000334 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 334:	1141                	addi	sp,sp,-16
 336:	e406                	sd	ra,8(sp)
 338:	e022                	sd	s0,0(sp)
 33a:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 33c:	00000097          	auipc	ra,0x0
 340:	f66080e7          	jalr	-154(ra) # 2a2 <memmove>
}
 344:	60a2                	ld	ra,8(sp)
 346:	6402                	ld	s0,0(sp)
 348:	0141                	addi	sp,sp,16
 34a:	8082                	ret

000000000000034c <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 34c:	4885                	li	a7,1
 ecall
 34e:	00000073          	ecall
 ret
 352:	8082                	ret

0000000000000354 <exit>:
.global exit
exit:
 li a7, SYS_exit
 354:	4889                	li	a7,2
 ecall
 356:	00000073          	ecall
 ret
 35a:	8082                	ret

000000000000035c <wait>:
.global wait
wait:
 li a7, SYS_wait
 35c:	488d                	li	a7,3
 ecall
 35e:	00000073          	ecall
 ret
 362:	8082                	ret

0000000000000364 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 364:	4891                	li	a7,4
 ecall
 366:	00000073          	ecall
 ret
 36a:	8082                	ret

000000000000036c <read>:
.global read
read:
 li a7, SYS_read
 36c:	4895                	li	a7,5
 ecall
 36e:	00000073          	ecall
 ret
 372:	8082                	ret

0000000000000374 <write>:
.global write
write:
 li a7, SYS_write
 374:	48c1                	li	a7,16
 ecall
 376:	00000073          	ecall
 ret
 37a:	8082                	ret

000000000000037c <close>:
.global close
close:
 li a7, SYS_close
 37c:	48d5                	li	a7,21
 ecall
 37e:	00000073          	ecall
 ret
 382:	8082                	ret

0000000000000384 <kill>:
.global kill
kill:
 li a7, SYS_kill
 384:	4899                	li	a7,6
 ecall
 386:	00000073          	ecall
 ret
 38a:	8082                	ret

000000000000038c <exec>:
.global exec
exec:
 li a7, SYS_exec
 38c:	489d                	li	a7,7
 ecall
 38e:	00000073          	ecall
 ret
 392:	8082                	ret

0000000000000394 <open>:
.global open
open:
 li a7, SYS_open
 394:	48bd                	li	a7,15
 ecall
 396:	00000073          	ecall
 ret
 39a:	8082                	ret

000000000000039c <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 39c:	48c5                	li	a7,17
 ecall
 39e:	00000073          	ecall
 ret
 3a2:	8082                	ret

00000000000003a4 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 3a4:	48c9                	li	a7,18
 ecall
 3a6:	00000073          	ecall
 ret
 3aa:	8082                	ret

00000000000003ac <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 3ac:	48a1                	li	a7,8
 ecall
 3ae:	00000073          	ecall
 ret
 3b2:	8082                	ret

00000000000003b4 <link>:
.global link
link:
 li a7, SYS_link
 3b4:	48cd                	li	a7,19
 ecall
 3b6:	00000073          	ecall
 ret
 3ba:	8082                	ret

00000000000003bc <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 3bc:	48d1                	li	a7,20
 ecall
 3be:	00000073          	ecall
 ret
 3c2:	8082                	ret

00000000000003c4 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 3c4:	48a5                	li	a7,9
 ecall
 3c6:	00000073          	ecall
 ret
 3ca:	8082                	ret

00000000000003cc <dup>:
.global dup
dup:
 li a7, SYS_dup
 3cc:	48a9                	li	a7,10
 ecall
 3ce:	00000073          	ecall
 ret
 3d2:	8082                	ret

00000000000003d4 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 3d4:	48ad                	li	a7,11
 ecall
 3d6:	00000073          	ecall
 ret
 3da:	8082                	ret

00000000000003dc <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 3dc:	48b1                	li	a7,12
 ecall
 3de:	00000073          	ecall
 ret
 3e2:	8082                	ret

00000000000003e4 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 3e4:	48b5                	li	a7,13
 ecall
 3e6:	00000073          	ecall
 ret
 3ea:	8082                	ret

00000000000003ec <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 3ec:	48b9                	li	a7,14
 ecall
 3ee:	00000073          	ecall
 ret
 3f2:	8082                	ret

00000000000003f4 <ctime>:
.global ctime
ctime:
 li a7, SYS_ctime
 3f4:	48d9                	li	a7,22
 ecall
 3f6:	00000073          	ecall
 ret
 3fa:	8082                	ret

00000000000003fc <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 3fc:	1101                	addi	sp,sp,-32
 3fe:	ec06                	sd	ra,24(sp)
 400:	e822                	sd	s0,16(sp)
 402:	1000                	addi	s0,sp,32
 404:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 408:	4605                	li	a2,1
 40a:	fef40593          	addi	a1,s0,-17
 40e:	00000097          	auipc	ra,0x0
 412:	f66080e7          	jalr	-154(ra) # 374 <write>
}
 416:	60e2                	ld	ra,24(sp)
 418:	6442                	ld	s0,16(sp)
 41a:	6105                	addi	sp,sp,32
 41c:	8082                	ret

000000000000041e <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 41e:	7139                	addi	sp,sp,-64
 420:	fc06                	sd	ra,56(sp)
 422:	f822                	sd	s0,48(sp)
 424:	f426                	sd	s1,40(sp)
 426:	f04a                	sd	s2,32(sp)
 428:	ec4e                	sd	s3,24(sp)
 42a:	0080                	addi	s0,sp,64
 42c:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 42e:	c299                	beqz	a3,434 <printint+0x16>
 430:	0805c963          	bltz	a1,4c2 <printint+0xa4>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 434:	2581                	sext.w	a1,a1
  neg = 0;
 436:	4881                	li	a7,0
 438:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 43c:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 43e:	2601                	sext.w	a2,a2
 440:	00001517          	auipc	a0,0x1
 444:	a9050513          	addi	a0,a0,-1392 # ed0 <digits>
 448:	883a                	mv	a6,a4
 44a:	2705                	addiw	a4,a4,1
 44c:	02c5f7bb          	remuw	a5,a1,a2
 450:	1782                	slli	a5,a5,0x20
 452:	9381                	srli	a5,a5,0x20
 454:	97aa                	add	a5,a5,a0
 456:	0007c783          	lbu	a5,0(a5)
 45a:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 45e:	0005879b          	sext.w	a5,a1
 462:	02c5d5bb          	divuw	a1,a1,a2
 466:	0685                	addi	a3,a3,1
 468:	fec7f0e3          	bgeu	a5,a2,448 <printint+0x2a>
  if(neg)
 46c:	00088c63          	beqz	a7,484 <printint+0x66>
    buf[i++] = '-';
 470:	fd070793          	addi	a5,a4,-48
 474:	00878733          	add	a4,a5,s0
 478:	02d00793          	li	a5,45
 47c:	fef70823          	sb	a5,-16(a4)
 480:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 484:	02e05863          	blez	a4,4b4 <printint+0x96>
 488:	fc040793          	addi	a5,s0,-64
 48c:	00e78933          	add	s2,a5,a4
 490:	fff78993          	addi	s3,a5,-1
 494:	99ba                	add	s3,s3,a4
 496:	377d                	addiw	a4,a4,-1
 498:	1702                	slli	a4,a4,0x20
 49a:	9301                	srli	a4,a4,0x20
 49c:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 4a0:	fff94583          	lbu	a1,-1(s2)
 4a4:	8526                	mv	a0,s1
 4a6:	00000097          	auipc	ra,0x0
 4aa:	f56080e7          	jalr	-170(ra) # 3fc <putc>
  while(--i >= 0)
 4ae:	197d                	addi	s2,s2,-1
 4b0:	ff3918e3          	bne	s2,s3,4a0 <printint+0x82>
}
 4b4:	70e2                	ld	ra,56(sp)
 4b6:	7442                	ld	s0,48(sp)
 4b8:	74a2                	ld	s1,40(sp)
 4ba:	7902                	ld	s2,32(sp)
 4bc:	69e2                	ld	s3,24(sp)
 4be:	6121                	addi	sp,sp,64
 4c0:	8082                	ret
    x = -xx;
 4c2:	40b005bb          	negw	a1,a1
    neg = 1;
 4c6:	4885                	li	a7,1
    x = -xx;
 4c8:	bf85                	j	438 <printint+0x1a>

00000000000004ca <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 4ca:	715d                	addi	sp,sp,-80
 4cc:	e486                	sd	ra,72(sp)
 4ce:	e0a2                	sd	s0,64(sp)
 4d0:	fc26                	sd	s1,56(sp)
 4d2:	f84a                	sd	s2,48(sp)
 4d4:	f44e                	sd	s3,40(sp)
 4d6:	f052                	sd	s4,32(sp)
 4d8:	ec56                	sd	s5,24(sp)
 4da:	e85a                	sd	s6,16(sp)
 4dc:	e45e                	sd	s7,8(sp)
 4de:	e062                	sd	s8,0(sp)
 4e0:	0880                	addi	s0,sp,80
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 4e2:	0005c903          	lbu	s2,0(a1)
 4e6:	18090c63          	beqz	s2,67e <vprintf+0x1b4>
 4ea:	8aaa                	mv	s5,a0
 4ec:	8bb2                	mv	s7,a2
 4ee:	00158493          	addi	s1,a1,1
  state = 0;
 4f2:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 4f4:	02500a13          	li	s4,37
 4f8:	4b55                	li	s6,21
 4fa:	a839                	j	518 <vprintf+0x4e>
        putc(fd, c);
 4fc:	85ca                	mv	a1,s2
 4fe:	8556                	mv	a0,s5
 500:	00000097          	auipc	ra,0x0
 504:	efc080e7          	jalr	-260(ra) # 3fc <putc>
 508:	a019                	j	50e <vprintf+0x44>
    } else if(state == '%'){
 50a:	01498d63          	beq	s3,s4,524 <vprintf+0x5a>
  for(i = 0; fmt[i]; i++){
 50e:	0485                	addi	s1,s1,1
 510:	fff4c903          	lbu	s2,-1(s1)
 514:	16090563          	beqz	s2,67e <vprintf+0x1b4>
    if(state == 0){
 518:	fe0999e3          	bnez	s3,50a <vprintf+0x40>
      if(c == '%'){
 51c:	ff4910e3          	bne	s2,s4,4fc <vprintf+0x32>
        state = '%';
 520:	89d2                	mv	s3,s4
 522:	b7f5                	j	50e <vprintf+0x44>
      if(c == 'd'){
 524:	13490263          	beq	s2,s4,648 <vprintf+0x17e>
 528:	f9d9079b          	addiw	a5,s2,-99
 52c:	0ff7f793          	zext.b	a5,a5
 530:	12fb6563          	bltu	s6,a5,65a <vprintf+0x190>
 534:	f9d9079b          	addiw	a5,s2,-99
 538:	0ff7f713          	zext.b	a4,a5
 53c:	10eb6f63          	bltu	s6,a4,65a <vprintf+0x190>
 540:	00271793          	slli	a5,a4,0x2
 544:	00001717          	auipc	a4,0x1
 548:	93470713          	addi	a4,a4,-1740 # e78 <ulthread_context_switch+0x136>
 54c:	97ba                	add	a5,a5,a4
 54e:	439c                	lw	a5,0(a5)
 550:	97ba                	add	a5,a5,a4
 552:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
 554:	008b8913          	addi	s2,s7,8
 558:	4685                	li	a3,1
 55a:	4629                	li	a2,10
 55c:	000ba583          	lw	a1,0(s7)
 560:	8556                	mv	a0,s5
 562:	00000097          	auipc	ra,0x0
 566:	ebc080e7          	jalr	-324(ra) # 41e <printint>
 56a:	8bca                	mv	s7,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 56c:	4981                	li	s3,0
 56e:	b745                	j	50e <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 570:	008b8913          	addi	s2,s7,8
 574:	4681                	li	a3,0
 576:	4629                	li	a2,10
 578:	000ba583          	lw	a1,0(s7)
 57c:	8556                	mv	a0,s5
 57e:	00000097          	auipc	ra,0x0
 582:	ea0080e7          	jalr	-352(ra) # 41e <printint>
 586:	8bca                	mv	s7,s2
      state = 0;
 588:	4981                	li	s3,0
 58a:	b751                	j	50e <vprintf+0x44>
        printint(fd, va_arg(ap, int), 16, 0);
 58c:	008b8913          	addi	s2,s7,8
 590:	4681                	li	a3,0
 592:	4641                	li	a2,16
 594:	000ba583          	lw	a1,0(s7)
 598:	8556                	mv	a0,s5
 59a:	00000097          	auipc	ra,0x0
 59e:	e84080e7          	jalr	-380(ra) # 41e <printint>
 5a2:	8bca                	mv	s7,s2
      state = 0;
 5a4:	4981                	li	s3,0
 5a6:	b7a5                	j	50e <vprintf+0x44>
        printptr(fd, va_arg(ap, uint64));
 5a8:	008b8c13          	addi	s8,s7,8
 5ac:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 5b0:	03000593          	li	a1,48
 5b4:	8556                	mv	a0,s5
 5b6:	00000097          	auipc	ra,0x0
 5ba:	e46080e7          	jalr	-442(ra) # 3fc <putc>
  putc(fd, 'x');
 5be:	07800593          	li	a1,120
 5c2:	8556                	mv	a0,s5
 5c4:	00000097          	auipc	ra,0x0
 5c8:	e38080e7          	jalr	-456(ra) # 3fc <putc>
 5cc:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 5ce:	00001b97          	auipc	s7,0x1
 5d2:	902b8b93          	addi	s7,s7,-1790 # ed0 <digits>
 5d6:	03c9d793          	srli	a5,s3,0x3c
 5da:	97de                	add	a5,a5,s7
 5dc:	0007c583          	lbu	a1,0(a5)
 5e0:	8556                	mv	a0,s5
 5e2:	00000097          	auipc	ra,0x0
 5e6:	e1a080e7          	jalr	-486(ra) # 3fc <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 5ea:	0992                	slli	s3,s3,0x4
 5ec:	397d                	addiw	s2,s2,-1
 5ee:	fe0914e3          	bnez	s2,5d6 <vprintf+0x10c>
        printptr(fd, va_arg(ap, uint64));
 5f2:	8be2                	mv	s7,s8
      state = 0;
 5f4:	4981                	li	s3,0
 5f6:	bf21                	j	50e <vprintf+0x44>
        s = va_arg(ap, char*);
 5f8:	008b8993          	addi	s3,s7,8
 5fc:	000bb903          	ld	s2,0(s7)
        if(s == 0)
 600:	02090163          	beqz	s2,622 <vprintf+0x158>
        while(*s != 0){
 604:	00094583          	lbu	a1,0(s2)
 608:	c9a5                	beqz	a1,678 <vprintf+0x1ae>
          putc(fd, *s);
 60a:	8556                	mv	a0,s5
 60c:	00000097          	auipc	ra,0x0
 610:	df0080e7          	jalr	-528(ra) # 3fc <putc>
          s++;
 614:	0905                	addi	s2,s2,1
        while(*s != 0){
 616:	00094583          	lbu	a1,0(s2)
 61a:	f9e5                	bnez	a1,60a <vprintf+0x140>
        s = va_arg(ap, char*);
 61c:	8bce                	mv	s7,s3
      state = 0;
 61e:	4981                	li	s3,0
 620:	b5fd                	j	50e <vprintf+0x44>
          s = "(null)";
 622:	00001917          	auipc	s2,0x1
 626:	84e90913          	addi	s2,s2,-1970 # e70 <ulthread_context_switch+0x12e>
        while(*s != 0){
 62a:	02800593          	li	a1,40
 62e:	bff1                	j	60a <vprintf+0x140>
        putc(fd, va_arg(ap, uint));
 630:	008b8913          	addi	s2,s7,8
 634:	000bc583          	lbu	a1,0(s7)
 638:	8556                	mv	a0,s5
 63a:	00000097          	auipc	ra,0x0
 63e:	dc2080e7          	jalr	-574(ra) # 3fc <putc>
 642:	8bca                	mv	s7,s2
      state = 0;
 644:	4981                	li	s3,0
 646:	b5e1                	j	50e <vprintf+0x44>
        putc(fd, c);
 648:	02500593          	li	a1,37
 64c:	8556                	mv	a0,s5
 64e:	00000097          	auipc	ra,0x0
 652:	dae080e7          	jalr	-594(ra) # 3fc <putc>
      state = 0;
 656:	4981                	li	s3,0
 658:	bd5d                	j	50e <vprintf+0x44>
        putc(fd, '%');
 65a:	02500593          	li	a1,37
 65e:	8556                	mv	a0,s5
 660:	00000097          	auipc	ra,0x0
 664:	d9c080e7          	jalr	-612(ra) # 3fc <putc>
        putc(fd, c);
 668:	85ca                	mv	a1,s2
 66a:	8556                	mv	a0,s5
 66c:	00000097          	auipc	ra,0x0
 670:	d90080e7          	jalr	-624(ra) # 3fc <putc>
      state = 0;
 674:	4981                	li	s3,0
 676:	bd61                	j	50e <vprintf+0x44>
        s = va_arg(ap, char*);
 678:	8bce                	mv	s7,s3
      state = 0;
 67a:	4981                	li	s3,0
 67c:	bd49                	j	50e <vprintf+0x44>
    }
  }
}
 67e:	60a6                	ld	ra,72(sp)
 680:	6406                	ld	s0,64(sp)
 682:	74e2                	ld	s1,56(sp)
 684:	7942                	ld	s2,48(sp)
 686:	79a2                	ld	s3,40(sp)
 688:	7a02                	ld	s4,32(sp)
 68a:	6ae2                	ld	s5,24(sp)
 68c:	6b42                	ld	s6,16(sp)
 68e:	6ba2                	ld	s7,8(sp)
 690:	6c02                	ld	s8,0(sp)
 692:	6161                	addi	sp,sp,80
 694:	8082                	ret

0000000000000696 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 696:	715d                	addi	sp,sp,-80
 698:	ec06                	sd	ra,24(sp)
 69a:	e822                	sd	s0,16(sp)
 69c:	1000                	addi	s0,sp,32
 69e:	e010                	sd	a2,0(s0)
 6a0:	e414                	sd	a3,8(s0)
 6a2:	e818                	sd	a4,16(s0)
 6a4:	ec1c                	sd	a5,24(s0)
 6a6:	03043023          	sd	a6,32(s0)
 6aa:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 6ae:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 6b2:	8622                	mv	a2,s0
 6b4:	00000097          	auipc	ra,0x0
 6b8:	e16080e7          	jalr	-490(ra) # 4ca <vprintf>
}
 6bc:	60e2                	ld	ra,24(sp)
 6be:	6442                	ld	s0,16(sp)
 6c0:	6161                	addi	sp,sp,80
 6c2:	8082                	ret

00000000000006c4 <printf>:

void
printf(const char *fmt, ...)
{
 6c4:	711d                	addi	sp,sp,-96
 6c6:	ec06                	sd	ra,24(sp)
 6c8:	e822                	sd	s0,16(sp)
 6ca:	1000                	addi	s0,sp,32
 6cc:	e40c                	sd	a1,8(s0)
 6ce:	e810                	sd	a2,16(s0)
 6d0:	ec14                	sd	a3,24(s0)
 6d2:	f018                	sd	a4,32(s0)
 6d4:	f41c                	sd	a5,40(s0)
 6d6:	03043823          	sd	a6,48(s0)
 6da:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 6de:	00840613          	addi	a2,s0,8
 6e2:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 6e6:	85aa                	mv	a1,a0
 6e8:	4505                	li	a0,1
 6ea:	00000097          	auipc	ra,0x0
 6ee:	de0080e7          	jalr	-544(ra) # 4ca <vprintf>
}
 6f2:	60e2                	ld	ra,24(sp)
 6f4:	6442                	ld	s0,16(sp)
 6f6:	6125                	addi	sp,sp,96
 6f8:	8082                	ret

00000000000006fa <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 6fa:	1141                	addi	sp,sp,-16
 6fc:	e422                	sd	s0,8(sp)
 6fe:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 700:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 704:	00001797          	auipc	a5,0x1
 708:	8fc7b783          	ld	a5,-1796(a5) # 1000 <freep>
 70c:	a02d                	j	736 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 70e:	4618                	lw	a4,8(a2)
 710:	9f2d                	addw	a4,a4,a1
 712:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 716:	6398                	ld	a4,0(a5)
 718:	6310                	ld	a2,0(a4)
 71a:	a83d                	j	758 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 71c:	ff852703          	lw	a4,-8(a0)
 720:	9f31                	addw	a4,a4,a2
 722:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 724:	ff053683          	ld	a3,-16(a0)
 728:	a091                	j	76c <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 72a:	6398                	ld	a4,0(a5)
 72c:	00e7e463          	bltu	a5,a4,734 <free+0x3a>
 730:	00e6ea63          	bltu	a3,a4,744 <free+0x4a>
{
 734:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 736:	fed7fae3          	bgeu	a5,a3,72a <free+0x30>
 73a:	6398                	ld	a4,0(a5)
 73c:	00e6e463          	bltu	a3,a4,744 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 740:	fee7eae3          	bltu	a5,a4,734 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 744:	ff852583          	lw	a1,-8(a0)
 748:	6390                	ld	a2,0(a5)
 74a:	02059813          	slli	a6,a1,0x20
 74e:	01c85713          	srli	a4,a6,0x1c
 752:	9736                	add	a4,a4,a3
 754:	fae60de3          	beq	a2,a4,70e <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 758:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 75c:	4790                	lw	a2,8(a5)
 75e:	02061593          	slli	a1,a2,0x20
 762:	01c5d713          	srli	a4,a1,0x1c
 766:	973e                	add	a4,a4,a5
 768:	fae68ae3          	beq	a3,a4,71c <free+0x22>
    p->s.ptr = bp->s.ptr;
 76c:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 76e:	00001717          	auipc	a4,0x1
 772:	88f73923          	sd	a5,-1902(a4) # 1000 <freep>
}
 776:	6422                	ld	s0,8(sp)
 778:	0141                	addi	sp,sp,16
 77a:	8082                	ret

000000000000077c <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 77c:	7139                	addi	sp,sp,-64
 77e:	fc06                	sd	ra,56(sp)
 780:	f822                	sd	s0,48(sp)
 782:	f426                	sd	s1,40(sp)
 784:	f04a                	sd	s2,32(sp)
 786:	ec4e                	sd	s3,24(sp)
 788:	e852                	sd	s4,16(sp)
 78a:	e456                	sd	s5,8(sp)
 78c:	e05a                	sd	s6,0(sp)
 78e:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 790:	02051493          	slli	s1,a0,0x20
 794:	9081                	srli	s1,s1,0x20
 796:	04bd                	addi	s1,s1,15
 798:	8091                	srli	s1,s1,0x4
 79a:	0014899b          	addiw	s3,s1,1
 79e:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 7a0:	00001517          	auipc	a0,0x1
 7a4:	86053503          	ld	a0,-1952(a0) # 1000 <freep>
 7a8:	c515                	beqz	a0,7d4 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 7aa:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 7ac:	4798                	lw	a4,8(a5)
 7ae:	02977f63          	bgeu	a4,s1,7ec <malloc+0x70>
  if(nu < 4096)
 7b2:	8a4e                	mv	s4,s3
 7b4:	0009871b          	sext.w	a4,s3
 7b8:	6685                	lui	a3,0x1
 7ba:	00d77363          	bgeu	a4,a3,7c0 <malloc+0x44>
 7be:	6a05                	lui	s4,0x1
 7c0:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 7c4:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 7c8:	00001917          	auipc	s2,0x1
 7cc:	83890913          	addi	s2,s2,-1992 # 1000 <freep>
  if(p == (char*)-1)
 7d0:	5afd                	li	s5,-1
 7d2:	a895                	j	846 <malloc+0xca>
    base.s.ptr = freep = prevp = &base;
 7d4:	00065797          	auipc	a5,0x65
 7d8:	84c78793          	addi	a5,a5,-1972 # 65020 <base>
 7dc:	00001717          	auipc	a4,0x1
 7e0:	82f73223          	sd	a5,-2012(a4) # 1000 <freep>
 7e4:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 7e6:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 7ea:	b7e1                	j	7b2 <malloc+0x36>
      if(p->s.size == nunits)
 7ec:	02e48c63          	beq	s1,a4,824 <malloc+0xa8>
        p->s.size -= nunits;
 7f0:	4137073b          	subw	a4,a4,s3
 7f4:	c798                	sw	a4,8(a5)
        p += p->s.size;
 7f6:	02071693          	slli	a3,a4,0x20
 7fa:	01c6d713          	srli	a4,a3,0x1c
 7fe:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 800:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 804:	00000717          	auipc	a4,0x0
 808:	7ea73e23          	sd	a0,2044(a4) # 1000 <freep>
      return (void*)(p + 1);
 80c:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 810:	70e2                	ld	ra,56(sp)
 812:	7442                	ld	s0,48(sp)
 814:	74a2                	ld	s1,40(sp)
 816:	7902                	ld	s2,32(sp)
 818:	69e2                	ld	s3,24(sp)
 81a:	6a42                	ld	s4,16(sp)
 81c:	6aa2                	ld	s5,8(sp)
 81e:	6b02                	ld	s6,0(sp)
 820:	6121                	addi	sp,sp,64
 822:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 824:	6398                	ld	a4,0(a5)
 826:	e118                	sd	a4,0(a0)
 828:	bff1                	j	804 <malloc+0x88>
  hp->s.size = nu;
 82a:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 82e:	0541                	addi	a0,a0,16
 830:	00000097          	auipc	ra,0x0
 834:	eca080e7          	jalr	-310(ra) # 6fa <free>
  return freep;
 838:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 83c:	d971                	beqz	a0,810 <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 83e:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 840:	4798                	lw	a4,8(a5)
 842:	fa9775e3          	bgeu	a4,s1,7ec <malloc+0x70>
    if(p == freep)
 846:	00093703          	ld	a4,0(s2)
 84a:	853e                	mv	a0,a5
 84c:	fef719e3          	bne	a4,a5,83e <malloc+0xc2>
  p = sbrk(nu * sizeof(Header));
 850:	8552                	mv	a0,s4
 852:	00000097          	auipc	ra,0x0
 856:	b8a080e7          	jalr	-1142(ra) # 3dc <sbrk>
  if(p == (char*)-1)
 85a:	fd5518e3          	bne	a0,s5,82a <malloc+0xae>
        return 0;
 85e:	4501                	li	a0,0
 860:	bf45                	j	810 <malloc+0x94>

0000000000000862 <get_current_tid>:
struct ulthread *scheduler_thread;
enum ulthread_scheduling_algorithm algorithm;

/* Get thread ID */
int get_current_tid(void)
{
 862:	1141                	addi	sp,sp,-16
 864:	e422                	sd	s0,8(sp)
 866:	0800                	addi	s0,sp,16
  return current_thread->tid;
}
 868:	00000797          	auipc	a5,0x0
 86c:	7b07b783          	ld	a5,1968(a5) # 1018 <current_thread>
 870:	43c8                	lw	a0,4(a5)
 872:	6422                	ld	s0,8(sp)
 874:	0141                	addi	sp,sp,16
 876:	8082                	ret

0000000000000878 <roundRobin>:

void roundRobin(void)
{
 878:	715d                	addi	sp,sp,-80
 87a:	e486                	sd	ra,72(sp)
 87c:	e0a2                	sd	s0,64(sp)
 87e:	fc26                	sd	s1,56(sp)
 880:	f84a                	sd	s2,48(sp)
 882:	f44e                	sd	s3,40(sp)
 884:	f052                	sd	s4,32(sp)
 886:	ec56                	sd	s5,24(sp)
 888:	e85a                	sd	s6,16(sp)
 88a:	e45e                	sd	s7,8(sp)
 88c:	e062                	sd	s8,0(sp)
 88e:	0880                	addi	s0,sp,80
        struct ulthread *temp = current_thread;
        current_thread = t;
        printf("[*] ultschedule (next tid: %d)\n", get_current_tid());
        ulthread_context_switch(&temp->context, &t->context);
      }
      if (t->state == YIELD)
 890:	4a09                	li	s4,2
      if (t->state == RUNNABLE && t != scheduler_thread)
 892:	00000b97          	auipc	s7,0x0
 896:	77eb8b93          	addi	s7,s7,1918 # 1010 <scheduler_thread>
        struct ulthread *temp = current_thread;
 89a:	00000a97          	auipc	s5,0x0
 89e:	77ea8a93          	addi	s5,s5,1918 # 1018 <current_thread>
        printf("[*] ultschedule (next tid: %d)\n", get_current_tid());
 8a2:	00000c17          	auipc	s8,0x0
 8a6:	646c0c13          	addi	s8,s8,1606 # ee8 <digits+0x18>
    for (t = ulthreads; t < &ulthreads[MAXULTHREADS]; t++)
 8aa:	00068997          	auipc	s3,0x68
 8ae:	ca698993          	addi	s3,s3,-858 # 68550 <ulthreads+0x3520>
 8b2:	a0b9                	j	900 <roundRobin+0x88>
      if (t->state == RUNNABLE && t != scheduler_thread)
 8b4:	000bb783          	ld	a5,0(s7)
 8b8:	02978863          	beq	a5,s1,8e8 <roundRobin+0x70>
        struct ulthread *temp = current_thread;
 8bc:	000abb03          	ld	s6,0(s5)
        current_thread = t;
 8c0:	009ab023          	sd	s1,0(s5)
        printf("[*] ultschedule (next tid: %d)\n", get_current_tid());
 8c4:	40cc                	lw	a1,4(s1)
 8c6:	8562                	mv	a0,s8
 8c8:	00000097          	auipc	ra,0x0
 8cc:	dfc080e7          	jalr	-516(ra) # 6c4 <printf>
        ulthread_context_switch(&temp->context, &t->context);
 8d0:	01848593          	addi	a1,s1,24
 8d4:	018b0513          	addi	a0,s6,24
 8d8:	00000097          	auipc	ra,0x0
 8dc:	46a080e7          	jalr	1130(ra) # d42 <ulthread_context_switch>
        threadAvailable = true;
 8e0:	874a                	mv	a4,s2
 8e2:	a811                	j	8f6 <roundRobin+0x7e>
      {
        t->state = RUNNABLE;
 8e4:	0124a023          	sw	s2,0(s1)
    for (t = ulthreads; t < &ulthreads[MAXULTHREADS]; t++)
 8e8:	08848493          	addi	s1,s1,136
 8ec:	01348963          	beq	s1,s3,8fe <roundRobin+0x86>
      if (t->state == RUNNABLE && t != scheduler_thread)
 8f0:	409c                	lw	a5,0(s1)
 8f2:	fd2781e3          	beq	a5,s2,8b4 <roundRobin+0x3c>
      if (t->state == YIELD)
 8f6:	409c                	lw	a5,0(s1)
 8f8:	ff4798e3          	bne	a5,s4,8e8 <roundRobin+0x70>
 8fc:	b7e5                	j	8e4 <roundRobin+0x6c>
      }
    }
    if (!threadAvailable)
 8fe:	cb01                	beqz	a4,90e <roundRobin+0x96>
    bool threadAvailable = false;
 900:	4701                	li	a4,0
    for (t = ulthreads; t < &ulthreads[MAXULTHREADS]; t++)
 902:	00064497          	auipc	s1,0x64
 906:	72e48493          	addi	s1,s1,1838 # 65030 <ulthreads>
      if (t->state == RUNNABLE && t != scheduler_thread)
 90a:	4905                	li	s2,1
 90c:	b7d5                	j	8f0 <roundRobin+0x78>
    {
      break;
    }
  }
}
 90e:	60a6                	ld	ra,72(sp)
 910:	6406                	ld	s0,64(sp)
 912:	74e2                	ld	s1,56(sp)
 914:	7942                	ld	s2,48(sp)
 916:	79a2                	ld	s3,40(sp)
 918:	7a02                	ld	s4,32(sp)
 91a:	6ae2                	ld	s5,24(sp)
 91c:	6b42                	ld	s6,16(sp)
 91e:	6ba2                	ld	s7,8(sp)
 920:	6c02                	ld	s8,0(sp)
 922:	6161                	addi	sp,sp,80
 924:	8082                	ret

0000000000000926 <firstComeFirstServe>:

void firstComeFirstServe(void)
{
 926:	715d                	addi	sp,sp,-80
 928:	e486                	sd	ra,72(sp)
 92a:	e0a2                	sd	s0,64(sp)
 92c:	fc26                	sd	s1,56(sp)
 92e:	f84a                	sd	s2,48(sp)
 930:	f44e                	sd	s3,40(sp)
 932:	f052                	sd	s4,32(sp)
 934:	ec56                	sd	s5,24(sp)
 936:	e85a                	sd	s6,16(sp)
 938:	e45e                	sd	s7,8(sp)
 93a:	e062                	sd	s8,0(sp)
 93c:	0880                	addi	s0,sp,80
    uint64 oldest = __INT64_MAX__;
    int threadIndex = -1;
    int alternativeIndex = -1;
    for (t = ulthreads+1; t < &ulthreads[MAXULTHREADS]; t++)
    {
      if (t->state == RUNNABLE && t != scheduler_thread && t->lastTime < oldest)
 93e:	00000b97          	auipc	s7,0x0
 942:	6d2b8b93          	addi	s7,s7,1746 # 1010 <scheduler_thread>
    int alternativeIndex = -1;
 946:	5afd                	li	s5,-1
    uint64 oldest = __INT64_MAX__;
 948:	001adb13          	srli	s6,s5,0x1
      if (t->state == RUNNABLE && t != scheduler_thread && t->lastTime < oldest)
 94c:	4485                	li	s1,1
        oldest = t->lastTime;
        threadIndex = t->tid;
        threadAvailable = true;
      }

      if (t->state == YIELD){
 94e:	4989                	li	s3,2
    for (t = ulthreads+1; t < &ulthreads[MAXULTHREADS]; t++)
 950:	00068917          	auipc	s2,0x68
 954:	c0090913          	addi	s2,s2,-1024 # 68550 <ulthreads+0x3520>
        break;
      }
      
    }
    label : 
      struct ulthread *temp = current_thread;
 958:	00000a17          	auipc	s4,0x0
 95c:	6c0a0a13          	addi	s4,s4,1728 # 1018 <current_thread>
 960:	a88d                	j	9d2 <firstComeFirstServe+0xac>
      if (t->state == RUNNABLE && t != scheduler_thread && t->lastTime < oldest)
 962:	00f58963          	beq	a1,a5,974 <firstComeFirstServe+0x4e>
 966:	6b98                	ld	a4,16(a5)
 968:	00c77663          	bgeu	a4,a2,974 <firstComeFirstServe+0x4e>
        threadIndex = t->tid;
 96c:	0047a803          	lw	a6,4(a5)
        oldest = t->lastTime;
 970:	863a                	mv	a2,a4
        threadAvailable = true;
 972:	8526                	mv	a0,s1
    for (t = ulthreads+1; t < &ulthreads[MAXULTHREADS]; t++)
 974:	08878793          	addi	a5,a5,136
 978:	01278a63          	beq	a5,s2,98c <firstComeFirstServe+0x66>
      if (t->state == RUNNABLE && t != scheduler_thread && t->lastTime < oldest)
 97c:	4398                	lw	a4,0(a5)
 97e:	fe9702e3          	beq	a4,s1,962 <firstComeFirstServe+0x3c>
      if (t->state == YIELD){
 982:	ff3719e3          	bne	a4,s3,974 <firstComeFirstServe+0x4e>
        t->state = RUNNABLE;
 986:	c384                	sw	s1,0(a5)
        alternativeIndex = t->tid;
 988:	43d4                	lw	a3,4(a5)
 98a:	b7ed                	j	974 <firstComeFirstServe+0x4e>
    if (!threadAvailable)
 98c:	ed31                	bnez	a0,9e8 <firstComeFirstServe+0xc2>
      if(alternativeIndex > 0){
 98e:	04d05f63          	blez	a3,9ec <firstComeFirstServe+0xc6>
      struct ulthread *temp = current_thread;
 992:	000a3c03          	ld	s8,0(s4)
      current_thread = &ulthreads[threadIndex];
 996:	00469793          	slli	a5,a3,0x4
 99a:	00d78733          	add	a4,a5,a3
 99e:	070e                	slli	a4,a4,0x3
 9a0:	00064617          	auipc	a2,0x64
 9a4:	69060613          	addi	a2,a2,1680 # 65030 <ulthreads>
 9a8:	9732                	add	a4,a4,a2
 9aa:	00ea3023          	sd	a4,0(s4)
      printf("[*] ultschedule (next tid: %d), time = %d\n", get_current_tid());
 9ae:	434c                	lw	a1,4(a4)
 9b0:	00000517          	auipc	a0,0x0
 9b4:	55850513          	addi	a0,a0,1368 # f08 <digits+0x38>
 9b8:	00000097          	auipc	ra,0x0
 9bc:	d0c080e7          	jalr	-756(ra) # 6c4 <printf>
      ulthread_context_switch(&temp->context, &current_thread->context);
 9c0:	000a3583          	ld	a1,0(s4)
 9c4:	05e1                	addi	a1,a1,24
 9c6:	018c0513          	addi	a0,s8,24
 9ca:	00000097          	auipc	ra,0x0
 9ce:	378080e7          	jalr	888(ra) # d42 <ulthread_context_switch>
      if (t->state == RUNNABLE && t != scheduler_thread && t->lastTime < oldest)
 9d2:	000bb583          	ld	a1,0(s7)
    int alternativeIndex = -1;
 9d6:	86d6                	mv	a3,s5
    int threadIndex = -1;
 9d8:	8856                	mv	a6,s5
    uint64 oldest = __INT64_MAX__;
 9da:	865a                	mv	a2,s6
    bool threadAvailable = false;
 9dc:	4501                	li	a0,0
    for (t = ulthreads+1; t < &ulthreads[MAXULTHREADS]; t++)
 9de:	00064797          	auipc	a5,0x64
 9e2:	6da78793          	addi	a5,a5,1754 # 650b8 <ulthreads+0x88>
 9e6:	bf59                	j	97c <firstComeFirstServe+0x56>
    label : 
 9e8:	86c2                	mv	a3,a6
 9ea:	b765                	j	992 <firstComeFirstServe+0x6c>
  }
}
 9ec:	60a6                	ld	ra,72(sp)
 9ee:	6406                	ld	s0,64(sp)
 9f0:	74e2                	ld	s1,56(sp)
 9f2:	7942                	ld	s2,48(sp)
 9f4:	79a2                	ld	s3,40(sp)
 9f6:	7a02                	ld	s4,32(sp)
 9f8:	6ae2                	ld	s5,24(sp)
 9fa:	6b42                	ld	s6,16(sp)
 9fc:	6ba2                	ld	s7,8(sp)
 9fe:	6c02                	ld	s8,0(sp)
 a00:	6161                	addi	sp,sp,80
 a02:	8082                	ret

0000000000000a04 <priorityScheduling>:


void priorityScheduling(void)
{
 a04:	715d                	addi	sp,sp,-80
 a06:	e486                	sd	ra,72(sp)
 a08:	e0a2                	sd	s0,64(sp)
 a0a:	fc26                	sd	s1,56(sp)
 a0c:	f84a                	sd	s2,48(sp)
 a0e:	f44e                	sd	s3,40(sp)
 a10:	f052                	sd	s4,32(sp)
 a12:	ec56                	sd	s5,24(sp)
 a14:	e85a                	sd	s6,16(sp)
 a16:	e45e                	sd	s7,8(sp)
 a18:	0880                	addi	s0,sp,80
    int maxPriority = -1;
    int threadIndex = -1;
    int alternativeIndex = -1;
    for (t = ulthreads+1; t < &ulthreads[MAXULTHREADS]; t++)
    {
      if (t->state == RUNNABLE && t != scheduler_thread && t->priority > maxPriority)
 a1a:	00000b17          	auipc	s6,0x0
 a1e:	5f6b0b13          	addi	s6,s6,1526 # 1010 <scheduler_thread>
    int alternativeIndex = -1;
 a22:	5a7d                	li	s4,-1
      if (t->state == RUNNABLE && t != scheduler_thread && t->priority > maxPriority)
 a24:	4485                	li	s1,1
        // flag = true;

        // break; // switch to highest-priority thread and exit loop
      }

      if (t->state == YIELD){
 a26:	4989                	li	s3,2
    for (t = ulthreads+1; t < &ulthreads[MAXULTHREADS]; t++)
 a28:	00068917          	auipc	s2,0x68
 a2c:	b2890913          	addi	s2,s2,-1240 # 68550 <ulthreads+0x3520>
        break;
      }
      
    }
    label : 
      struct ulthread *temp = current_thread;
 a30:	00000a97          	auipc	s5,0x0
 a34:	5e8a8a93          	addi	s5,s5,1512 # 1018 <current_thread>
 a38:	a88d                	j	aaa <priorityScheduling+0xa6>
      if (t->state == RUNNABLE && t != scheduler_thread && t->priority > maxPriority)
 a3a:	00f58963          	beq	a1,a5,a4c <priorityScheduling+0x48>
 a3e:	47d8                	lw	a4,12(a5)
 a40:	00e65663          	bge	a2,a4,a4c <priorityScheduling+0x48>
        threadIndex = t->tid;
 a44:	0047a803          	lw	a6,4(a5)
        maxPriority = t->priority;
 a48:	863a                	mv	a2,a4
        threadAvailable = true;
 a4a:	8526                	mv	a0,s1
    for (t = ulthreads+1; t < &ulthreads[MAXULTHREADS]; t++)
 a4c:	08878793          	addi	a5,a5,136
 a50:	01278a63          	beq	a5,s2,a64 <priorityScheduling+0x60>
      if (t->state == RUNNABLE && t != scheduler_thread && t->priority > maxPriority)
 a54:	4398                	lw	a4,0(a5)
 a56:	fe9702e3          	beq	a4,s1,a3a <priorityScheduling+0x36>
      if (t->state == YIELD){
 a5a:	ff3719e3          	bne	a4,s3,a4c <priorityScheduling+0x48>
        t->state = RUNNABLE;
 a5e:	c384                	sw	s1,0(a5)
        alternativeIndex = t->tid;
 a60:	43d4                	lw	a3,4(a5)
 a62:	b7ed                	j	a4c <priorityScheduling+0x48>
    if (!threadAvailable)
 a64:	ed31                	bnez	a0,ac0 <priorityScheduling+0xbc>
      if(alternativeIndex > 0){
 a66:	04d05f63          	blez	a3,ac4 <priorityScheduling+0xc0>
      struct ulthread *temp = current_thread;
 a6a:	000abb83          	ld	s7,0(s5)
      current_thread = &ulthreads[threadIndex];
 a6e:	00469793          	slli	a5,a3,0x4
 a72:	00d78733          	add	a4,a5,a3
 a76:	070e                	slli	a4,a4,0x3
 a78:	00064617          	auipc	a2,0x64
 a7c:	5b860613          	addi	a2,a2,1464 # 65030 <ulthreads>
 a80:	9732                	add	a4,a4,a2
 a82:	00eab023          	sd	a4,0(s5)
      printf("[*] ultschedule (next tid: %d)\n", get_current_tid());
 a86:	434c                	lw	a1,4(a4)
 a88:	00000517          	auipc	a0,0x0
 a8c:	46050513          	addi	a0,a0,1120 # ee8 <digits+0x18>
 a90:	00000097          	auipc	ra,0x0
 a94:	c34080e7          	jalr	-972(ra) # 6c4 <printf>
      ulthread_context_switch(&temp->context, &current_thread->context);
 a98:	000ab583          	ld	a1,0(s5)
 a9c:	05e1                	addi	a1,a1,24
 a9e:	018b8513          	addi	a0,s7,24
 aa2:	00000097          	auipc	ra,0x0
 aa6:	2a0080e7          	jalr	672(ra) # d42 <ulthread_context_switch>
      if (t->state == RUNNABLE && t != scheduler_thread && t->priority > maxPriority)
 aaa:	000b3583          	ld	a1,0(s6)
    int alternativeIndex = -1;
 aae:	86d2                	mv	a3,s4
    int threadIndex = -1;
 ab0:	8852                	mv	a6,s4
    int maxPriority = -1;
 ab2:	8652                	mv	a2,s4
    bool threadAvailable = false;
 ab4:	4501                	li	a0,0
    for (t = ulthreads+1; t < &ulthreads[MAXULTHREADS]; t++)
 ab6:	00064797          	auipc	a5,0x64
 aba:	60278793          	addi	a5,a5,1538 # 650b8 <ulthreads+0x88>
 abe:	bf59                	j	a54 <priorityScheduling+0x50>
    label : 
 ac0:	86c2                	mv	a3,a6
 ac2:	b765                	j	a6a <priorityScheduling+0x66>
  }
}
 ac4:	60a6                	ld	ra,72(sp)
 ac6:	6406                	ld	s0,64(sp)
 ac8:	74e2                	ld	s1,56(sp)
 aca:	7942                	ld	s2,48(sp)
 acc:	79a2                	ld	s3,40(sp)
 ace:	7a02                	ld	s4,32(sp)
 ad0:	6ae2                	ld	s5,24(sp)
 ad2:	6b42                	ld	s6,16(sp)
 ad4:	6ba2                	ld	s7,8(sp)
 ad6:	6161                	addi	sp,sp,80
 ad8:	8082                	ret

0000000000000ada <ulthread_init>:

/* Thread initialization */
void ulthread_init(int schedalgo)
{
 ada:	1141                	addi	sp,sp,-16
 adc:	e422                	sd	s0,8(sp)
 ade:	0800                	addi	s0,sp,16
  struct ulthread *t;
  int i;
  for (i = 0, t = ulthreads; t < &ulthreads[MAXULTHREADS]; t++, i++)
 ae0:	4701                	li	a4,0
 ae2:	00064797          	auipc	a5,0x64
 ae6:	54e78793          	addi	a5,a5,1358 # 65030 <ulthreads>
 aea:	00068697          	auipc	a3,0x68
 aee:	a6668693          	addi	a3,a3,-1434 # 68550 <ulthreads+0x3520>
  {
    t->state = FREE;
 af2:	0007a023          	sw	zero,0(a5)
    t->tid = i;
 af6:	c3d8                	sw	a4,4(a5)
  for (i = 0, t = ulthreads; t < &ulthreads[MAXULTHREADS]; t++, i++)
 af8:	08878793          	addi	a5,a5,136
 afc:	2705                	addiw	a4,a4,1
 afe:	fed79ae3          	bne	a5,a3,af2 <ulthread_init+0x18>
  }
  current_thread = &ulthreads[0];
 b02:	00064797          	auipc	a5,0x64
 b06:	52e78793          	addi	a5,a5,1326 # 65030 <ulthreads>
 b0a:	00000717          	auipc	a4,0x0
 b0e:	50f73723          	sd	a5,1294(a4) # 1018 <current_thread>
  scheduler_thread = &ulthreads[0];
 b12:	00000717          	auipc	a4,0x0
 b16:	4ef73f23          	sd	a5,1278(a4) # 1010 <scheduler_thread>
  scheduler_thread->state = RUNNABLE;
 b1a:	4705                	li	a4,1
 b1c:	c398                	sw	a4,0(a5)
  t->state = FREE;
 b1e:	00068797          	auipc	a5,0x68
 b22:	a207a923          	sw	zero,-1486(a5) # 68550 <ulthreads+0x3520>
  algorithm = schedalgo;
 b26:	00000797          	auipc	a5,0x0
 b2a:	4ea7a123          	sw	a0,1250(a5) # 1008 <algorithm>
}
 b2e:	6422                	ld	s0,8(sp)
 b30:	0141                	addi	sp,sp,16
 b32:	8082                	ret

0000000000000b34 <ulthread_create>:

/* Thread creation */
bool ulthread_create(uint64 start, uint64 stack, uint64 args[], int priority)
{
 b34:	7179                	addi	sp,sp,-48
 b36:	f406                	sd	ra,40(sp)
 b38:	f022                	sd	s0,32(sp)
 b3a:	ec26                	sd	s1,24(sp)
 b3c:	e84a                	sd	s2,16(sp)
 b3e:	e44e                	sd	s3,8(sp)
 b40:	e052                	sd	s4,0(sp)
 b42:	1800                	addi	s0,sp,48
 b44:	89aa                	mv	s3,a0
 b46:	8a2e                	mv	s4,a1
 b48:	8932                	mv	s2,a2
  /* Please add thread-id instead of '0' here. */
  struct ulthread *t;
  bool flag = false;
  for (t = ulthreads; t < &ulthreads[MAXULTHREADS]; t++)
 b4a:	00064497          	auipc	s1,0x64
 b4e:	4e648493          	addi	s1,s1,1254 # 65030 <ulthreads>
 b52:	00068717          	auipc	a4,0x68
 b56:	9fe70713          	addi	a4,a4,-1538 # 68550 <ulthreads+0x3520>
  {
    if (t->state == FREE)
 b5a:	409c                	lw	a5,0(s1)
 b5c:	cf89                	beqz	a5,b76 <ulthread_create+0x42>
  for (t = ulthreads; t < &ulthreads[MAXULTHREADS]; t++)
 b5e:	08848493          	addi	s1,s1,136
 b62:	fee49ce3          	bne	s1,a4,b5a <ulthread_create+0x26>
      break;
    }
  }
  if (!flag)
  {
    return false;
 b66:	4501                	li	a0,0
 b68:	a871                	j	c04 <ulthread_create+0xd0>
  t->sp = (int)(stack + USTACKSIZE); // set sp to the top of the stack
  t->state = RUNNABLE;
  t->priority = priority;

  if(algorithm==FCFS){
    t->lastTime = ctime();
 b6a:	00000097          	auipc	ra,0x0
 b6e:	88a080e7          	jalr	-1910(ra) # 3f4 <ctime>
 b72:	e888                	sd	a0,16(s1)
 b74:	a839                	j	b92 <ulthread_create+0x5e>
  t->sp = (int)(stack + USTACKSIZE); // set sp to the top of the stack
 b76:	6785                	lui	a5,0x1
 b78:	014787bb          	addw	a5,a5,s4
 b7c:	c49c                	sw	a5,8(s1)
  t->state = RUNNABLE;
 b7e:	4785                	li	a5,1
 b80:	c09c                	sw	a5,0(s1)
  t->priority = priority;
 b82:	c4d4                	sw	a3,12(s1)
  if(algorithm==FCFS){
 b84:	00000717          	auipc	a4,0x0
 b88:	48472703          	lw	a4,1156(a4) # 1008 <algorithm>
 b8c:	4789                	li	a5,2
 b8e:	fcf70ee3          	beq	a4,a5,b6a <ulthread_create+0x36>
  }

  for (int argc = 0; argc < 6; argc++)
 b92:	874a                	mv	a4,s2
 b94:	03090693          	addi	a3,s2,48
  {
    t->sp -= 16;
 b98:	449c                	lw	a5,8(s1)
 b9a:	37c1                	addiw	a5,a5,-16 # ff0 <digits+0x120>
 b9c:	0007881b          	sext.w	a6,a5
 ba0:	c49c                	sw	a5,8(s1)
    *(uint64 *)(t->sp) = (uint64)args[argc];
 ba2:	631c                	ld	a5,0(a4)
 ba4:	00f83023          	sd	a5,0(a6)
  for (int argc = 0; argc < 6; argc++)
 ba8:	0721                	addi	a4,a4,8
 baa:	fed717e3          	bne	a4,a3,b98 <ulthread_create+0x64>
  }

  memset(&t->context, 0, sizeof(t->context));
 bae:	07000613          	li	a2,112
 bb2:	4581                	li	a1,0
 bb4:	01848513          	addi	a0,s1,24
 bb8:	fffff097          	auipc	ra,0xfffff
 bbc:	5a2080e7          	jalr	1442(ra) # 15a <memset>
  t->context.ra = start;
 bc0:	0134bc23          	sd	s3,24(s1)
  t->context.sp = t->sp;
 bc4:	449c                	lw	a5,8(s1)
 bc6:	f09c                	sd	a5,32(s1)
  t->context.s0 = args[0];
 bc8:	00093783          	ld	a5,0(s2)
 bcc:	f49c                	sd	a5,40(s1)
  t->context.s1 = args[1];
 bce:	00893783          	ld	a5,8(s2)
 bd2:	f89c                	sd	a5,48(s1)
  t->context.s2 = args[2];
 bd4:	01093783          	ld	a5,16(s2)
 bd8:	fc9c                	sd	a5,56(s1)
  t->context.s3 = args[3];
 bda:	01893783          	ld	a5,24(s2)
 bde:	e0bc                	sd	a5,64(s1)
  t->context.s4 = args[4];
 be0:	02093783          	ld	a5,32(s2)
 be4:	e4bc                	sd	a5,72(s1)
  t->context.s5 = args[5];
 be6:	02893783          	ld	a5,40(s2)
 bea:	e8bc                	sd	a5,80(s1)

  printf("[*] ultcreate(tid: %d, ra: %p, sp: %p)\n", t->tid, start, stack);
 bec:	86d2                	mv	a3,s4
 bee:	864e                	mv	a2,s3
 bf0:	40cc                	lw	a1,4(s1)
 bf2:	00000517          	auipc	a0,0x0
 bf6:	34650513          	addi	a0,a0,838 # f38 <digits+0x68>
 bfa:	00000097          	auipc	ra,0x0
 bfe:	aca080e7          	jalr	-1334(ra) # 6c4 <printf>
  return true;
 c02:	4505                	li	a0,1
}
 c04:	70a2                	ld	ra,40(sp)
 c06:	7402                	ld	s0,32(sp)
 c08:	64e2                	ld	s1,24(sp)
 c0a:	6942                	ld	s2,16(sp)
 c0c:	69a2                	ld	s3,8(sp)
 c0e:	6a02                	ld	s4,0(sp)
 c10:	6145                	addi	sp,sp,48
 c12:	8082                	ret

0000000000000c14 <ulthread_schedule>:

/* Thread scheduler */
void ulthread_schedule(void)
{
 c14:	1141                	addi	sp,sp,-16
 c16:	e406                	sd	ra,8(sp)
 c18:	e022                	sd	s0,0(sp)
 c1a:	0800                	addi	s0,sp,16
  switch (algorithm)
 c1c:	00000797          	auipc	a5,0x0
 c20:	3ec7a783          	lw	a5,1004(a5) # 1008 <algorithm>
 c24:	4705                	li	a4,1
 c26:	02e78463          	beq	a5,a4,c4e <ulthread_schedule+0x3a>
 c2a:	4709                	li	a4,2
 c2c:	00e78c63          	beq	a5,a4,c44 <ulthread_schedule+0x30>
 c30:	c789                	beqz	a5,c3a <ulthread_schedule+0x26>

  // Push argument strings, prepare rest of stack in ustack.

  // Switch between thread contexts
  // ulthread_context_switch(NULL, NULL);
}
 c32:	60a2                	ld	ra,8(sp)
 c34:	6402                	ld	s0,0(sp)
 c36:	0141                	addi	sp,sp,16
 c38:	8082                	ret
    roundRobin();
 c3a:	00000097          	auipc	ra,0x0
 c3e:	c3e080e7          	jalr	-962(ra) # 878 <roundRobin>
    break;
 c42:	bfc5                	j	c32 <ulthread_schedule+0x1e>
    firstComeFirstServe();
 c44:	00000097          	auipc	ra,0x0
 c48:	ce2080e7          	jalr	-798(ra) # 926 <firstComeFirstServe>
    break;
 c4c:	b7dd                	j	c32 <ulthread_schedule+0x1e>
    priorityScheduling();
 c4e:	00000097          	auipc	ra,0x0
 c52:	db6080e7          	jalr	-586(ra) # a04 <priorityScheduling>
}
 c56:	bff1                	j	c32 <ulthread_schedule+0x1e>

0000000000000c58 <ulthread_yield>:

/* Yield CPU time to some other thread. */
void ulthread_yield(void)
{
 c58:	1101                	addi	sp,sp,-32
 c5a:	ec06                	sd	ra,24(sp)
 c5c:	e822                	sd	s0,16(sp)
 c5e:	e426                	sd	s1,8(sp)
 c60:	e04a                	sd	s2,0(sp)
 c62:	1000                	addi	s0,sp,32
  current_thread->state = YIELD;
 c64:	00000797          	auipc	a5,0x0
 c68:	3b478793          	addi	a5,a5,948 # 1018 <current_thread>
 c6c:	6398                	ld	a4,0(a5)
 c6e:	4909                	li	s2,2
 c70:	01272023          	sw	s2,0(a4)
  struct ulthread *temp = current_thread;
 c74:	6384                	ld	s1,0(a5)
  printf("[*] ultyield(tid: %d)\n", current_thread->tid);
 c76:	40cc                	lw	a1,4(s1)
 c78:	00000517          	auipc	a0,0x0
 c7c:	2e850513          	addi	a0,a0,744 # f60 <digits+0x90>
 c80:	00000097          	auipc	ra,0x0
 c84:	a44080e7          	jalr	-1468(ra) # 6c4 <printf>
  if(algorithm==FCFS){
 c88:	00000797          	auipc	a5,0x0
 c8c:	3807a783          	lw	a5,896(a5) # 1008 <algorithm>
 c90:	03278763          	beq	a5,s2,cbe <ulthread_yield+0x66>
    current_thread->lastTime = ctime();
  }
  current_thread = scheduler_thread;
 c94:	00000597          	auipc	a1,0x0
 c98:	37c5b583          	ld	a1,892(a1) # 1010 <scheduler_thread>
 c9c:	00000797          	auipc	a5,0x0
 ca0:	36b7be23          	sd	a1,892(a5) # 1018 <current_thread>
  
  ulthread_context_switch(&temp->context, &scheduler_thread->context);
 ca4:	05e1                	addi	a1,a1,24
 ca6:	01848513          	addi	a0,s1,24
 caa:	00000097          	auipc	ra,0x0
 cae:	098080e7          	jalr	152(ra) # d42 <ulthread_context_switch>
  // ulthread_schedule();
}
 cb2:	60e2                	ld	ra,24(sp)
 cb4:	6442                	ld	s0,16(sp)
 cb6:	64a2                	ld	s1,8(sp)
 cb8:	6902                	ld	s2,0(sp)
 cba:	6105                	addi	sp,sp,32
 cbc:	8082                	ret
    current_thread->lastTime = ctime();
 cbe:	fffff097          	auipc	ra,0xfffff
 cc2:	736080e7          	jalr	1846(ra) # 3f4 <ctime>
 cc6:	00000797          	auipc	a5,0x0
 cca:	3527b783          	ld	a5,850(a5) # 1018 <current_thread>
 cce:	eb88                	sd	a0,16(a5)
 cd0:	b7d1                	j	c94 <ulthread_yield+0x3c>

0000000000000cd2 <ulthread_destroy>:

/* Destroy thread */
void ulthread_destroy(void)
{
 cd2:	1101                	addi	sp,sp,-32
 cd4:	ec06                	sd	ra,24(sp)
 cd6:	e822                	sd	s0,16(sp)
 cd8:	e426                	sd	s1,8(sp)
 cda:	e04a                	sd	s2,0(sp)
 cdc:	1000                	addi	s0,sp,32
  memset(&current_thread->context, 0, sizeof(current_thread->context));
 cde:	00000497          	auipc	s1,0x0
 ce2:	33a48493          	addi	s1,s1,826 # 1018 <current_thread>
 ce6:	6088                	ld	a0,0(s1)
 ce8:	07000613          	li	a2,112
 cec:	4581                	li	a1,0
 cee:	0561                	addi	a0,a0,24
 cf0:	fffff097          	auipc	ra,0xfffff
 cf4:	46a080e7          	jalr	1130(ra) # 15a <memset>
  current_thread->sp = 0;
 cf8:	609c                	ld	a5,0(s1)
 cfa:	0007a423          	sw	zero,8(a5)
  current_thread->priority = -1;
 cfe:	577d                	li	a4,-1
 d00:	c7d8                	sw	a4,12(a5)
  current_thread->state = FREE;
 d02:	0007a023          	sw	zero,0(a5)

  struct ulthread *temp = current_thread;
 d06:	0004b903          	ld	s2,0(s1)

  printf("[*] ultdestroy(tid: %d)\n", get_current_tid());
 d0a:	00492583          	lw	a1,4(s2)
 d0e:	00000517          	auipc	a0,0x0
 d12:	26a50513          	addi	a0,a0,618 # f78 <digits+0xa8>
 d16:	00000097          	auipc	ra,0x0
 d1a:	9ae080e7          	jalr	-1618(ra) # 6c4 <printf>
  current_thread = scheduler_thread;
 d1e:	00000597          	auipc	a1,0x0
 d22:	2f25b583          	ld	a1,754(a1) # 1010 <scheduler_thread>
 d26:	e08c                	sd	a1,0(s1)
  ulthread_context_switch(&temp->context, &scheduler_thread->context);
 d28:	05e1                	addi	a1,a1,24
 d2a:	01890513          	addi	a0,s2,24
 d2e:	00000097          	auipc	ra,0x0
 d32:	014080e7          	jalr	20(ra) # d42 <ulthread_context_switch>
}
 d36:	60e2                	ld	ra,24(sp)
 d38:	6442                	ld	s0,16(sp)
 d3a:	64a2                	ld	s1,8(sp)
 d3c:	6902                	ld	s2,0(sp)
 d3e:	6105                	addi	sp,sp,32
 d40:	8082                	ret

0000000000000d42 <ulthread_context_switch>:
 d42:	00153023          	sd	ra,0(a0)
 d46:	00253423          	sd	sp,8(a0)
 d4a:	e900                	sd	s0,16(a0)
 d4c:	ed04                	sd	s1,24(a0)
 d4e:	03253023          	sd	s2,32(a0)
 d52:	03353423          	sd	s3,40(a0)
 d56:	03453823          	sd	s4,48(a0)
 d5a:	03553c23          	sd	s5,56(a0)
 d5e:	05653023          	sd	s6,64(a0)
 d62:	05753423          	sd	s7,72(a0)
 d66:	05853823          	sd	s8,80(a0)
 d6a:	05953c23          	sd	s9,88(a0)
 d6e:	07a53023          	sd	s10,96(a0)
 d72:	07b53423          	sd	s11,104(a0)
 d76:	0005b083          	ld	ra,0(a1)
 d7a:	0085b103          	ld	sp,8(a1)
 d7e:	6980                	ld	s0,16(a1)
 d80:	6d84                	ld	s1,24(a1)
 d82:	0205b903          	ld	s2,32(a1)
 d86:	0285b983          	ld	s3,40(a1)
 d8a:	0305ba03          	ld	s4,48(a1)
 d8e:	0385ba83          	ld	s5,56(a1)
 d92:	0405bb03          	ld	s6,64(a1)
 d96:	0485bb83          	ld	s7,72(a1)
 d9a:	0505bc03          	ld	s8,80(a1)
 d9e:	0585bc83          	ld	s9,88(a1)
 da2:	0605bd03          	ld	s10,96(a1)
 da6:	0685bd83          	ld	s11,104(a1)
 daa:	6546                	ld	a0,80(sp)
 dac:	6586                	ld	a1,64(sp)
 dae:	7642                	ld	a2,48(sp)
 db0:	7682                	ld	a3,32(sp)
 db2:	6742                	ld	a4,16(sp)
 db4:	6782                	ld	a5,0(sp)
 db6:	8082                	ret
