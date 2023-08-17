
user/_test2:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <ul_start_func>:
#include <stdarg.h>

/* Stack region for different threads */
char stacks[PGSIZE*MAXULTHREADS];

void ul_start_func(void) {
   0:	1141                	addi	sp,sp,-16
   2:	e406                	sd	ra,8(sp)
   4:	e022                	sd	s0,0(sp)
   6:	0800                	addi	s0,sp,16
    printf("[.] started the thread function (tid = %d)\n", get_current_tid());
   8:	00001097          	auipc	ra,0x1
   c:	86e080e7          	jalr	-1938(ra) # 876 <get_current_tid>
  10:	85aa                	mv	a1,a0
  12:	00001517          	auipc	a0,0x1
  16:	dbe50513          	addi	a0,a0,-578 # dd0 <ulthread_context_switch+0x7a>
  1a:	00000097          	auipc	ra,0x0
  1e:	6be080e7          	jalr	1726(ra) # 6d8 <printf>

    /* Notify for a thread exit. */
    ulthread_destroy();
  22:	00001097          	auipc	ra,0x1
  26:	cc4080e7          	jalr	-828(ra) # ce6 <ulthread_destroy>
}
  2a:	60a2                	ld	ra,8(sp)
  2c:	6402                	ld	s0,0(sp)
  2e:	0141                	addi	sp,sp,16
  30:	8082                	ret

0000000000000032 <main>:

int
main(int argc, char *argv[])
{
  32:	7159                	addi	sp,sp,-112
  34:	f486                	sd	ra,104(sp)
  36:	f0a2                	sd	s0,96(sp)
  38:	eca6                	sd	s1,88(sp)
  3a:	e8ca                	sd	s2,80(sp)
  3c:	e4ce                	sd	s3,72(sp)
  3e:	e0d2                	sd	s4,64(sp)
  40:	fc56                	sd	s5,56(sp)
  42:	f85a                	sd	s6,48(sp)
  44:	1880                	addi	s0,sp,112
    /* Clear the stack region */
    memset(&stacks, 0, sizeof(stacks));
  46:	00064637          	lui	a2,0x64
  4a:	4581                	li	a1,0
  4c:	00001517          	auipc	a0,0x1
  50:	fd450513          	addi	a0,a0,-44 # 1020 <stacks>
  54:	00000097          	auipc	ra,0x0
  58:	11a080e7          	jalr	282(ra) # 16e <memset>

    /* Initialize the user-level threading library */
    ulthread_init(PRIORITY);
  5c:	4505                	li	a0,1
  5e:	00001097          	auipc	ra,0x1
  62:	a90080e7          	jalr	-1392(ra) # aee <ulthread_init>

    /* Create a user-level thread */
    uint64 args[6] = {0,0,0,0,0,0};
  66:	f8043823          	sd	zero,-112(s0)
  6a:	f8043c23          	sd	zero,-104(s0)
  6e:	fa043023          	sd	zero,-96(s0)
  72:	fa043423          	sd	zero,-88(s0)
  76:	fa043823          	sd	zero,-80(s0)
  7a:	fa043c23          	sd	zero,-72(s0)
    for (int i = 0; i < 10; i++)
  7e:	00002917          	auipc	s2,0x2
  82:	fa290913          	addi	s2,s2,-94 # 2020 <stacks+0x1000>
  86:	4481                	li	s1,0
        ulthread_create((uint64) ul_start_func, (uint64) (stacks+((i+1)*PGSIZE)), args, i%10);
  88:	4b29                	li	s6,10
  8a:	00000a97          	auipc	s5,0x0
  8e:	f76a8a93          	addi	s5,s5,-138 # 0 <ul_start_func>
    for (int i = 0; i < 10; i++)
  92:	6a05                	lui	s4,0x1
  94:	49a9                	li	s3,10
        ulthread_create((uint64) ul_start_func, (uint64) (stacks+((i+1)*PGSIZE)), args, i%10);
  96:	86a6                	mv	a3,s1
  98:	2485                	addiw	s1,s1,1
  9a:	0366e6bb          	remw	a3,a3,s6
  9e:	f9040613          	addi	a2,s0,-112
  a2:	85ca                	mv	a1,s2
  a4:	8556                	mv	a0,s5
  a6:	00001097          	auipc	ra,0x1
  aa:	aa2080e7          	jalr	-1374(ra) # b48 <ulthread_create>
    for (int i = 0; i < 10; i++)
  ae:	9952                	add	s2,s2,s4
  b0:	ff3493e3          	bne	s1,s3,96 <main+0x64>

    /* Schedule all of the threads */
    ulthread_schedule();
  b4:	00001097          	auipc	ra,0x1
  b8:	b74080e7          	jalr	-1164(ra) # c28 <ulthread_schedule>

    printf("[*] User-Level Threading Test #2 (Priority Scheduling) Complete.\n");
  bc:	00001517          	auipc	a0,0x1
  c0:	d4450513          	addi	a0,a0,-700 # e00 <ulthread_context_switch+0xaa>
  c4:	00000097          	auipc	ra,0x0
  c8:	614080e7          	jalr	1556(ra) # 6d8 <printf>
    return 0;
}
  cc:	4501                	li	a0,0
  ce:	70a6                	ld	ra,104(sp)
  d0:	7406                	ld	s0,96(sp)
  d2:	64e6                	ld	s1,88(sp)
  d4:	6946                	ld	s2,80(sp)
  d6:	69a6                	ld	s3,72(sp)
  d8:	6a06                	ld	s4,64(sp)
  da:	7ae2                	ld	s5,56(sp)
  dc:	7b42                	ld	s6,48(sp)
  de:	6165                	addi	sp,sp,112
  e0:	8082                	ret

00000000000000e2 <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
  e2:	1141                	addi	sp,sp,-16
  e4:	e406                	sd	ra,8(sp)
  e6:	e022                	sd	s0,0(sp)
  e8:	0800                	addi	s0,sp,16
  extern int main();
  main();
  ea:	00000097          	auipc	ra,0x0
  ee:	f48080e7          	jalr	-184(ra) # 32 <main>
  exit(0);
  f2:	4501                	li	a0,0
  f4:	00000097          	auipc	ra,0x0
  f8:	274080e7          	jalr	628(ra) # 368 <exit>

00000000000000fc <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
  fc:	1141                	addi	sp,sp,-16
  fe:	e422                	sd	s0,8(sp)
 100:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 102:	87aa                	mv	a5,a0
 104:	0585                	addi	a1,a1,1
 106:	0785                	addi	a5,a5,1
 108:	fff5c703          	lbu	a4,-1(a1)
 10c:	fee78fa3          	sb	a4,-1(a5)
 110:	fb75                	bnez	a4,104 <strcpy+0x8>
    ;
  return os;
}
 112:	6422                	ld	s0,8(sp)
 114:	0141                	addi	sp,sp,16
 116:	8082                	ret

0000000000000118 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 118:	1141                	addi	sp,sp,-16
 11a:	e422                	sd	s0,8(sp)
 11c:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 11e:	00054783          	lbu	a5,0(a0)
 122:	cb91                	beqz	a5,136 <strcmp+0x1e>
 124:	0005c703          	lbu	a4,0(a1)
 128:	00f71763          	bne	a4,a5,136 <strcmp+0x1e>
    p++, q++;
 12c:	0505                	addi	a0,a0,1
 12e:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 130:	00054783          	lbu	a5,0(a0)
 134:	fbe5                	bnez	a5,124 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 136:	0005c503          	lbu	a0,0(a1)
}
 13a:	40a7853b          	subw	a0,a5,a0
 13e:	6422                	ld	s0,8(sp)
 140:	0141                	addi	sp,sp,16
 142:	8082                	ret

0000000000000144 <strlen>:

uint
strlen(const char *s)
{
 144:	1141                	addi	sp,sp,-16
 146:	e422                	sd	s0,8(sp)
 148:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 14a:	00054783          	lbu	a5,0(a0)
 14e:	cf91                	beqz	a5,16a <strlen+0x26>
 150:	0505                	addi	a0,a0,1
 152:	87aa                	mv	a5,a0
 154:	86be                	mv	a3,a5
 156:	0785                	addi	a5,a5,1
 158:	fff7c703          	lbu	a4,-1(a5)
 15c:	ff65                	bnez	a4,154 <strlen+0x10>
 15e:	40a6853b          	subw	a0,a3,a0
 162:	2505                	addiw	a0,a0,1
    ;
  return n;
}
 164:	6422                	ld	s0,8(sp)
 166:	0141                	addi	sp,sp,16
 168:	8082                	ret
  for(n = 0; s[n]; n++)
 16a:	4501                	li	a0,0
 16c:	bfe5                	j	164 <strlen+0x20>

000000000000016e <memset>:

void*
memset(void *dst, int c, uint n)
{
 16e:	1141                	addi	sp,sp,-16
 170:	e422                	sd	s0,8(sp)
 172:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 174:	ca19                	beqz	a2,18a <memset+0x1c>
 176:	87aa                	mv	a5,a0
 178:	1602                	slli	a2,a2,0x20
 17a:	9201                	srli	a2,a2,0x20
 17c:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 180:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 184:	0785                	addi	a5,a5,1
 186:	fee79de3          	bne	a5,a4,180 <memset+0x12>
  }
  return dst;
}
 18a:	6422                	ld	s0,8(sp)
 18c:	0141                	addi	sp,sp,16
 18e:	8082                	ret

0000000000000190 <strchr>:

char*
strchr(const char *s, char c)
{
 190:	1141                	addi	sp,sp,-16
 192:	e422                	sd	s0,8(sp)
 194:	0800                	addi	s0,sp,16
  for(; *s; s++)
 196:	00054783          	lbu	a5,0(a0)
 19a:	cb99                	beqz	a5,1b0 <strchr+0x20>
    if(*s == c)
 19c:	00f58763          	beq	a1,a5,1aa <strchr+0x1a>
  for(; *s; s++)
 1a0:	0505                	addi	a0,a0,1
 1a2:	00054783          	lbu	a5,0(a0)
 1a6:	fbfd                	bnez	a5,19c <strchr+0xc>
      return (char*)s;
  return 0;
 1a8:	4501                	li	a0,0
}
 1aa:	6422                	ld	s0,8(sp)
 1ac:	0141                	addi	sp,sp,16
 1ae:	8082                	ret
  return 0;
 1b0:	4501                	li	a0,0
 1b2:	bfe5                	j	1aa <strchr+0x1a>

00000000000001b4 <gets>:

char*
gets(char *buf, int max)
{
 1b4:	711d                	addi	sp,sp,-96
 1b6:	ec86                	sd	ra,88(sp)
 1b8:	e8a2                	sd	s0,80(sp)
 1ba:	e4a6                	sd	s1,72(sp)
 1bc:	e0ca                	sd	s2,64(sp)
 1be:	fc4e                	sd	s3,56(sp)
 1c0:	f852                	sd	s4,48(sp)
 1c2:	f456                	sd	s5,40(sp)
 1c4:	f05a                	sd	s6,32(sp)
 1c6:	ec5e                	sd	s7,24(sp)
 1c8:	1080                	addi	s0,sp,96
 1ca:	8baa                	mv	s7,a0
 1cc:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1ce:	892a                	mv	s2,a0
 1d0:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 1d2:	4aa9                	li	s5,10
 1d4:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 1d6:	89a6                	mv	s3,s1
 1d8:	2485                	addiw	s1,s1,1
 1da:	0344d863          	bge	s1,s4,20a <gets+0x56>
    cc = read(0, &c, 1);
 1de:	4605                	li	a2,1
 1e0:	faf40593          	addi	a1,s0,-81
 1e4:	4501                	li	a0,0
 1e6:	00000097          	auipc	ra,0x0
 1ea:	19a080e7          	jalr	410(ra) # 380 <read>
    if(cc < 1)
 1ee:	00a05e63          	blez	a0,20a <gets+0x56>
    buf[i++] = c;
 1f2:	faf44783          	lbu	a5,-81(s0)
 1f6:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 1fa:	01578763          	beq	a5,s5,208 <gets+0x54>
 1fe:	0905                	addi	s2,s2,1
 200:	fd679be3          	bne	a5,s6,1d6 <gets+0x22>
  for(i=0; i+1 < max; ){
 204:	89a6                	mv	s3,s1
 206:	a011                	j	20a <gets+0x56>
 208:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 20a:	99de                	add	s3,s3,s7
 20c:	00098023          	sb	zero,0(s3)
  return buf;
}
 210:	855e                	mv	a0,s7
 212:	60e6                	ld	ra,88(sp)
 214:	6446                	ld	s0,80(sp)
 216:	64a6                	ld	s1,72(sp)
 218:	6906                	ld	s2,64(sp)
 21a:	79e2                	ld	s3,56(sp)
 21c:	7a42                	ld	s4,48(sp)
 21e:	7aa2                	ld	s5,40(sp)
 220:	7b02                	ld	s6,32(sp)
 222:	6be2                	ld	s7,24(sp)
 224:	6125                	addi	sp,sp,96
 226:	8082                	ret

0000000000000228 <stat>:

int
stat(const char *n, struct stat *st)
{
 228:	1101                	addi	sp,sp,-32
 22a:	ec06                	sd	ra,24(sp)
 22c:	e822                	sd	s0,16(sp)
 22e:	e426                	sd	s1,8(sp)
 230:	e04a                	sd	s2,0(sp)
 232:	1000                	addi	s0,sp,32
 234:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 236:	4581                	li	a1,0
 238:	00000097          	auipc	ra,0x0
 23c:	170080e7          	jalr	368(ra) # 3a8 <open>
  if(fd < 0)
 240:	02054563          	bltz	a0,26a <stat+0x42>
 244:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 246:	85ca                	mv	a1,s2
 248:	00000097          	auipc	ra,0x0
 24c:	178080e7          	jalr	376(ra) # 3c0 <fstat>
 250:	892a                	mv	s2,a0
  close(fd);
 252:	8526                	mv	a0,s1
 254:	00000097          	auipc	ra,0x0
 258:	13c080e7          	jalr	316(ra) # 390 <close>
  return r;
}
 25c:	854a                	mv	a0,s2
 25e:	60e2                	ld	ra,24(sp)
 260:	6442                	ld	s0,16(sp)
 262:	64a2                	ld	s1,8(sp)
 264:	6902                	ld	s2,0(sp)
 266:	6105                	addi	sp,sp,32
 268:	8082                	ret
    return -1;
 26a:	597d                	li	s2,-1
 26c:	bfc5                	j	25c <stat+0x34>

000000000000026e <atoi>:

int
atoi(const char *s)
{
 26e:	1141                	addi	sp,sp,-16
 270:	e422                	sd	s0,8(sp)
 272:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 274:	00054683          	lbu	a3,0(a0)
 278:	fd06879b          	addiw	a5,a3,-48
 27c:	0ff7f793          	zext.b	a5,a5
 280:	4625                	li	a2,9
 282:	02f66863          	bltu	a2,a5,2b2 <atoi+0x44>
 286:	872a                	mv	a4,a0
  n = 0;
 288:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 28a:	0705                	addi	a4,a4,1
 28c:	0025179b          	slliw	a5,a0,0x2
 290:	9fa9                	addw	a5,a5,a0
 292:	0017979b          	slliw	a5,a5,0x1
 296:	9fb5                	addw	a5,a5,a3
 298:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 29c:	00074683          	lbu	a3,0(a4)
 2a0:	fd06879b          	addiw	a5,a3,-48
 2a4:	0ff7f793          	zext.b	a5,a5
 2a8:	fef671e3          	bgeu	a2,a5,28a <atoi+0x1c>
  return n;
}
 2ac:	6422                	ld	s0,8(sp)
 2ae:	0141                	addi	sp,sp,16
 2b0:	8082                	ret
  n = 0;
 2b2:	4501                	li	a0,0
 2b4:	bfe5                	j	2ac <atoi+0x3e>

00000000000002b6 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 2b6:	1141                	addi	sp,sp,-16
 2b8:	e422                	sd	s0,8(sp)
 2ba:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 2bc:	02b57463          	bgeu	a0,a1,2e4 <memmove+0x2e>
    while(n-- > 0)
 2c0:	00c05f63          	blez	a2,2de <memmove+0x28>
 2c4:	1602                	slli	a2,a2,0x20
 2c6:	9201                	srli	a2,a2,0x20
 2c8:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 2cc:	872a                	mv	a4,a0
      *dst++ = *src++;
 2ce:	0585                	addi	a1,a1,1
 2d0:	0705                	addi	a4,a4,1
 2d2:	fff5c683          	lbu	a3,-1(a1)
 2d6:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 2da:	fee79ae3          	bne	a5,a4,2ce <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 2de:	6422                	ld	s0,8(sp)
 2e0:	0141                	addi	sp,sp,16
 2e2:	8082                	ret
    dst += n;
 2e4:	00c50733          	add	a4,a0,a2
    src += n;
 2e8:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 2ea:	fec05ae3          	blez	a2,2de <memmove+0x28>
 2ee:	fff6079b          	addiw	a5,a2,-1 # 63fff <stacks+0x62fdf>
 2f2:	1782                	slli	a5,a5,0x20
 2f4:	9381                	srli	a5,a5,0x20
 2f6:	fff7c793          	not	a5,a5
 2fa:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 2fc:	15fd                	addi	a1,a1,-1
 2fe:	177d                	addi	a4,a4,-1
 300:	0005c683          	lbu	a3,0(a1)
 304:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 308:	fee79ae3          	bne	a5,a4,2fc <memmove+0x46>
 30c:	bfc9                	j	2de <memmove+0x28>

000000000000030e <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 30e:	1141                	addi	sp,sp,-16
 310:	e422                	sd	s0,8(sp)
 312:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 314:	ca05                	beqz	a2,344 <memcmp+0x36>
 316:	fff6069b          	addiw	a3,a2,-1
 31a:	1682                	slli	a3,a3,0x20
 31c:	9281                	srli	a3,a3,0x20
 31e:	0685                	addi	a3,a3,1
 320:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 322:	00054783          	lbu	a5,0(a0)
 326:	0005c703          	lbu	a4,0(a1)
 32a:	00e79863          	bne	a5,a4,33a <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 32e:	0505                	addi	a0,a0,1
    p2++;
 330:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 332:	fed518e3          	bne	a0,a3,322 <memcmp+0x14>
  }
  return 0;
 336:	4501                	li	a0,0
 338:	a019                	j	33e <memcmp+0x30>
      return *p1 - *p2;
 33a:	40e7853b          	subw	a0,a5,a4
}
 33e:	6422                	ld	s0,8(sp)
 340:	0141                	addi	sp,sp,16
 342:	8082                	ret
  return 0;
 344:	4501                	li	a0,0
 346:	bfe5                	j	33e <memcmp+0x30>

0000000000000348 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 348:	1141                	addi	sp,sp,-16
 34a:	e406                	sd	ra,8(sp)
 34c:	e022                	sd	s0,0(sp)
 34e:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 350:	00000097          	auipc	ra,0x0
 354:	f66080e7          	jalr	-154(ra) # 2b6 <memmove>
}
 358:	60a2                	ld	ra,8(sp)
 35a:	6402                	ld	s0,0(sp)
 35c:	0141                	addi	sp,sp,16
 35e:	8082                	ret

0000000000000360 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 360:	4885                	li	a7,1
 ecall
 362:	00000073          	ecall
 ret
 366:	8082                	ret

0000000000000368 <exit>:
.global exit
exit:
 li a7, SYS_exit
 368:	4889                	li	a7,2
 ecall
 36a:	00000073          	ecall
 ret
 36e:	8082                	ret

0000000000000370 <wait>:
.global wait
wait:
 li a7, SYS_wait
 370:	488d                	li	a7,3
 ecall
 372:	00000073          	ecall
 ret
 376:	8082                	ret

0000000000000378 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 378:	4891                	li	a7,4
 ecall
 37a:	00000073          	ecall
 ret
 37e:	8082                	ret

0000000000000380 <read>:
.global read
read:
 li a7, SYS_read
 380:	4895                	li	a7,5
 ecall
 382:	00000073          	ecall
 ret
 386:	8082                	ret

0000000000000388 <write>:
.global write
write:
 li a7, SYS_write
 388:	48c1                	li	a7,16
 ecall
 38a:	00000073          	ecall
 ret
 38e:	8082                	ret

0000000000000390 <close>:
.global close
close:
 li a7, SYS_close
 390:	48d5                	li	a7,21
 ecall
 392:	00000073          	ecall
 ret
 396:	8082                	ret

0000000000000398 <kill>:
.global kill
kill:
 li a7, SYS_kill
 398:	4899                	li	a7,6
 ecall
 39a:	00000073          	ecall
 ret
 39e:	8082                	ret

00000000000003a0 <exec>:
.global exec
exec:
 li a7, SYS_exec
 3a0:	489d                	li	a7,7
 ecall
 3a2:	00000073          	ecall
 ret
 3a6:	8082                	ret

00000000000003a8 <open>:
.global open
open:
 li a7, SYS_open
 3a8:	48bd                	li	a7,15
 ecall
 3aa:	00000073          	ecall
 ret
 3ae:	8082                	ret

00000000000003b0 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 3b0:	48c5                	li	a7,17
 ecall
 3b2:	00000073          	ecall
 ret
 3b6:	8082                	ret

00000000000003b8 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 3b8:	48c9                	li	a7,18
 ecall
 3ba:	00000073          	ecall
 ret
 3be:	8082                	ret

00000000000003c0 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 3c0:	48a1                	li	a7,8
 ecall
 3c2:	00000073          	ecall
 ret
 3c6:	8082                	ret

00000000000003c8 <link>:
.global link
link:
 li a7, SYS_link
 3c8:	48cd                	li	a7,19
 ecall
 3ca:	00000073          	ecall
 ret
 3ce:	8082                	ret

00000000000003d0 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 3d0:	48d1                	li	a7,20
 ecall
 3d2:	00000073          	ecall
 ret
 3d6:	8082                	ret

00000000000003d8 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 3d8:	48a5                	li	a7,9
 ecall
 3da:	00000073          	ecall
 ret
 3de:	8082                	ret

00000000000003e0 <dup>:
.global dup
dup:
 li a7, SYS_dup
 3e0:	48a9                	li	a7,10
 ecall
 3e2:	00000073          	ecall
 ret
 3e6:	8082                	ret

00000000000003e8 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 3e8:	48ad                	li	a7,11
 ecall
 3ea:	00000073          	ecall
 ret
 3ee:	8082                	ret

00000000000003f0 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 3f0:	48b1                	li	a7,12
 ecall
 3f2:	00000073          	ecall
 ret
 3f6:	8082                	ret

00000000000003f8 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 3f8:	48b5                	li	a7,13
 ecall
 3fa:	00000073          	ecall
 ret
 3fe:	8082                	ret

0000000000000400 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 400:	48b9                	li	a7,14
 ecall
 402:	00000073          	ecall
 ret
 406:	8082                	ret

0000000000000408 <ctime>:
.global ctime
ctime:
 li a7, SYS_ctime
 408:	48d9                	li	a7,22
 ecall
 40a:	00000073          	ecall
 ret
 40e:	8082                	ret

0000000000000410 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 410:	1101                	addi	sp,sp,-32
 412:	ec06                	sd	ra,24(sp)
 414:	e822                	sd	s0,16(sp)
 416:	1000                	addi	s0,sp,32
 418:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 41c:	4605                	li	a2,1
 41e:	fef40593          	addi	a1,s0,-17
 422:	00000097          	auipc	ra,0x0
 426:	f66080e7          	jalr	-154(ra) # 388 <write>
}
 42a:	60e2                	ld	ra,24(sp)
 42c:	6442                	ld	s0,16(sp)
 42e:	6105                	addi	sp,sp,32
 430:	8082                	ret

0000000000000432 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 432:	7139                	addi	sp,sp,-64
 434:	fc06                	sd	ra,56(sp)
 436:	f822                	sd	s0,48(sp)
 438:	f426                	sd	s1,40(sp)
 43a:	f04a                	sd	s2,32(sp)
 43c:	ec4e                	sd	s3,24(sp)
 43e:	0080                	addi	s0,sp,64
 440:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 442:	c299                	beqz	a3,448 <printint+0x16>
 444:	0805c963          	bltz	a1,4d6 <printint+0xa4>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 448:	2581                	sext.w	a1,a1
  neg = 0;
 44a:	4881                	li	a7,0
 44c:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 450:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 452:	2601                	sext.w	a2,a2
 454:	00001517          	auipc	a0,0x1
 458:	a5450513          	addi	a0,a0,-1452 # ea8 <digits>
 45c:	883a                	mv	a6,a4
 45e:	2705                	addiw	a4,a4,1
 460:	02c5f7bb          	remuw	a5,a1,a2
 464:	1782                	slli	a5,a5,0x20
 466:	9381                	srli	a5,a5,0x20
 468:	97aa                	add	a5,a5,a0
 46a:	0007c783          	lbu	a5,0(a5)
 46e:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 472:	0005879b          	sext.w	a5,a1
 476:	02c5d5bb          	divuw	a1,a1,a2
 47a:	0685                	addi	a3,a3,1
 47c:	fec7f0e3          	bgeu	a5,a2,45c <printint+0x2a>
  if(neg)
 480:	00088c63          	beqz	a7,498 <printint+0x66>
    buf[i++] = '-';
 484:	fd070793          	addi	a5,a4,-48
 488:	00878733          	add	a4,a5,s0
 48c:	02d00793          	li	a5,45
 490:	fef70823          	sb	a5,-16(a4)
 494:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 498:	02e05863          	blez	a4,4c8 <printint+0x96>
 49c:	fc040793          	addi	a5,s0,-64
 4a0:	00e78933          	add	s2,a5,a4
 4a4:	fff78993          	addi	s3,a5,-1
 4a8:	99ba                	add	s3,s3,a4
 4aa:	377d                	addiw	a4,a4,-1
 4ac:	1702                	slli	a4,a4,0x20
 4ae:	9301                	srli	a4,a4,0x20
 4b0:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 4b4:	fff94583          	lbu	a1,-1(s2)
 4b8:	8526                	mv	a0,s1
 4ba:	00000097          	auipc	ra,0x0
 4be:	f56080e7          	jalr	-170(ra) # 410 <putc>
  while(--i >= 0)
 4c2:	197d                	addi	s2,s2,-1
 4c4:	ff3918e3          	bne	s2,s3,4b4 <printint+0x82>
}
 4c8:	70e2                	ld	ra,56(sp)
 4ca:	7442                	ld	s0,48(sp)
 4cc:	74a2                	ld	s1,40(sp)
 4ce:	7902                	ld	s2,32(sp)
 4d0:	69e2                	ld	s3,24(sp)
 4d2:	6121                	addi	sp,sp,64
 4d4:	8082                	ret
    x = -xx;
 4d6:	40b005bb          	negw	a1,a1
    neg = 1;
 4da:	4885                	li	a7,1
    x = -xx;
 4dc:	bf85                	j	44c <printint+0x1a>

00000000000004de <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 4de:	715d                	addi	sp,sp,-80
 4e0:	e486                	sd	ra,72(sp)
 4e2:	e0a2                	sd	s0,64(sp)
 4e4:	fc26                	sd	s1,56(sp)
 4e6:	f84a                	sd	s2,48(sp)
 4e8:	f44e                	sd	s3,40(sp)
 4ea:	f052                	sd	s4,32(sp)
 4ec:	ec56                	sd	s5,24(sp)
 4ee:	e85a                	sd	s6,16(sp)
 4f0:	e45e                	sd	s7,8(sp)
 4f2:	e062                	sd	s8,0(sp)
 4f4:	0880                	addi	s0,sp,80
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 4f6:	0005c903          	lbu	s2,0(a1)
 4fa:	18090c63          	beqz	s2,692 <vprintf+0x1b4>
 4fe:	8aaa                	mv	s5,a0
 500:	8bb2                	mv	s7,a2
 502:	00158493          	addi	s1,a1,1
  state = 0;
 506:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 508:	02500a13          	li	s4,37
 50c:	4b55                	li	s6,21
 50e:	a839                	j	52c <vprintf+0x4e>
        putc(fd, c);
 510:	85ca                	mv	a1,s2
 512:	8556                	mv	a0,s5
 514:	00000097          	auipc	ra,0x0
 518:	efc080e7          	jalr	-260(ra) # 410 <putc>
 51c:	a019                	j	522 <vprintf+0x44>
    } else if(state == '%'){
 51e:	01498d63          	beq	s3,s4,538 <vprintf+0x5a>
  for(i = 0; fmt[i]; i++){
 522:	0485                	addi	s1,s1,1
 524:	fff4c903          	lbu	s2,-1(s1)
 528:	16090563          	beqz	s2,692 <vprintf+0x1b4>
    if(state == 0){
 52c:	fe0999e3          	bnez	s3,51e <vprintf+0x40>
      if(c == '%'){
 530:	ff4910e3          	bne	s2,s4,510 <vprintf+0x32>
        state = '%';
 534:	89d2                	mv	s3,s4
 536:	b7f5                	j	522 <vprintf+0x44>
      if(c == 'd'){
 538:	13490263          	beq	s2,s4,65c <vprintf+0x17e>
 53c:	f9d9079b          	addiw	a5,s2,-99
 540:	0ff7f793          	zext.b	a5,a5
 544:	12fb6563          	bltu	s6,a5,66e <vprintf+0x190>
 548:	f9d9079b          	addiw	a5,s2,-99
 54c:	0ff7f713          	zext.b	a4,a5
 550:	10eb6f63          	bltu	s6,a4,66e <vprintf+0x190>
 554:	00271793          	slli	a5,a4,0x2
 558:	00001717          	auipc	a4,0x1
 55c:	8f870713          	addi	a4,a4,-1800 # e50 <ulthread_context_switch+0xfa>
 560:	97ba                	add	a5,a5,a4
 562:	439c                	lw	a5,0(a5)
 564:	97ba                	add	a5,a5,a4
 566:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
 568:	008b8913          	addi	s2,s7,8
 56c:	4685                	li	a3,1
 56e:	4629                	li	a2,10
 570:	000ba583          	lw	a1,0(s7)
 574:	8556                	mv	a0,s5
 576:	00000097          	auipc	ra,0x0
 57a:	ebc080e7          	jalr	-324(ra) # 432 <printint>
 57e:	8bca                	mv	s7,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 580:	4981                	li	s3,0
 582:	b745                	j	522 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 584:	008b8913          	addi	s2,s7,8
 588:	4681                	li	a3,0
 58a:	4629                	li	a2,10
 58c:	000ba583          	lw	a1,0(s7)
 590:	8556                	mv	a0,s5
 592:	00000097          	auipc	ra,0x0
 596:	ea0080e7          	jalr	-352(ra) # 432 <printint>
 59a:	8bca                	mv	s7,s2
      state = 0;
 59c:	4981                	li	s3,0
 59e:	b751                	j	522 <vprintf+0x44>
        printint(fd, va_arg(ap, int), 16, 0);
 5a0:	008b8913          	addi	s2,s7,8
 5a4:	4681                	li	a3,0
 5a6:	4641                	li	a2,16
 5a8:	000ba583          	lw	a1,0(s7)
 5ac:	8556                	mv	a0,s5
 5ae:	00000097          	auipc	ra,0x0
 5b2:	e84080e7          	jalr	-380(ra) # 432 <printint>
 5b6:	8bca                	mv	s7,s2
      state = 0;
 5b8:	4981                	li	s3,0
 5ba:	b7a5                	j	522 <vprintf+0x44>
        printptr(fd, va_arg(ap, uint64));
 5bc:	008b8c13          	addi	s8,s7,8
 5c0:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 5c4:	03000593          	li	a1,48
 5c8:	8556                	mv	a0,s5
 5ca:	00000097          	auipc	ra,0x0
 5ce:	e46080e7          	jalr	-442(ra) # 410 <putc>
  putc(fd, 'x');
 5d2:	07800593          	li	a1,120
 5d6:	8556                	mv	a0,s5
 5d8:	00000097          	auipc	ra,0x0
 5dc:	e38080e7          	jalr	-456(ra) # 410 <putc>
 5e0:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 5e2:	00001b97          	auipc	s7,0x1
 5e6:	8c6b8b93          	addi	s7,s7,-1850 # ea8 <digits>
 5ea:	03c9d793          	srli	a5,s3,0x3c
 5ee:	97de                	add	a5,a5,s7
 5f0:	0007c583          	lbu	a1,0(a5)
 5f4:	8556                	mv	a0,s5
 5f6:	00000097          	auipc	ra,0x0
 5fa:	e1a080e7          	jalr	-486(ra) # 410 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 5fe:	0992                	slli	s3,s3,0x4
 600:	397d                	addiw	s2,s2,-1
 602:	fe0914e3          	bnez	s2,5ea <vprintf+0x10c>
        printptr(fd, va_arg(ap, uint64));
 606:	8be2                	mv	s7,s8
      state = 0;
 608:	4981                	li	s3,0
 60a:	bf21                	j	522 <vprintf+0x44>
        s = va_arg(ap, char*);
 60c:	008b8993          	addi	s3,s7,8
 610:	000bb903          	ld	s2,0(s7)
        if(s == 0)
 614:	02090163          	beqz	s2,636 <vprintf+0x158>
        while(*s != 0){
 618:	00094583          	lbu	a1,0(s2)
 61c:	c9a5                	beqz	a1,68c <vprintf+0x1ae>
          putc(fd, *s);
 61e:	8556                	mv	a0,s5
 620:	00000097          	auipc	ra,0x0
 624:	df0080e7          	jalr	-528(ra) # 410 <putc>
          s++;
 628:	0905                	addi	s2,s2,1
        while(*s != 0){
 62a:	00094583          	lbu	a1,0(s2)
 62e:	f9e5                	bnez	a1,61e <vprintf+0x140>
        s = va_arg(ap, char*);
 630:	8bce                	mv	s7,s3
      state = 0;
 632:	4981                	li	s3,0
 634:	b5fd                	j	522 <vprintf+0x44>
          s = "(null)";
 636:	00001917          	auipc	s2,0x1
 63a:	81290913          	addi	s2,s2,-2030 # e48 <ulthread_context_switch+0xf2>
        while(*s != 0){
 63e:	02800593          	li	a1,40
 642:	bff1                	j	61e <vprintf+0x140>
        putc(fd, va_arg(ap, uint));
 644:	008b8913          	addi	s2,s7,8
 648:	000bc583          	lbu	a1,0(s7)
 64c:	8556                	mv	a0,s5
 64e:	00000097          	auipc	ra,0x0
 652:	dc2080e7          	jalr	-574(ra) # 410 <putc>
 656:	8bca                	mv	s7,s2
      state = 0;
 658:	4981                	li	s3,0
 65a:	b5e1                	j	522 <vprintf+0x44>
        putc(fd, c);
 65c:	02500593          	li	a1,37
 660:	8556                	mv	a0,s5
 662:	00000097          	auipc	ra,0x0
 666:	dae080e7          	jalr	-594(ra) # 410 <putc>
      state = 0;
 66a:	4981                	li	s3,0
 66c:	bd5d                	j	522 <vprintf+0x44>
        putc(fd, '%');
 66e:	02500593          	li	a1,37
 672:	8556                	mv	a0,s5
 674:	00000097          	auipc	ra,0x0
 678:	d9c080e7          	jalr	-612(ra) # 410 <putc>
        putc(fd, c);
 67c:	85ca                	mv	a1,s2
 67e:	8556                	mv	a0,s5
 680:	00000097          	auipc	ra,0x0
 684:	d90080e7          	jalr	-624(ra) # 410 <putc>
      state = 0;
 688:	4981                	li	s3,0
 68a:	bd61                	j	522 <vprintf+0x44>
        s = va_arg(ap, char*);
 68c:	8bce                	mv	s7,s3
      state = 0;
 68e:	4981                	li	s3,0
 690:	bd49                	j	522 <vprintf+0x44>
    }
  }
}
 692:	60a6                	ld	ra,72(sp)
 694:	6406                	ld	s0,64(sp)
 696:	74e2                	ld	s1,56(sp)
 698:	7942                	ld	s2,48(sp)
 69a:	79a2                	ld	s3,40(sp)
 69c:	7a02                	ld	s4,32(sp)
 69e:	6ae2                	ld	s5,24(sp)
 6a0:	6b42                	ld	s6,16(sp)
 6a2:	6ba2                	ld	s7,8(sp)
 6a4:	6c02                	ld	s8,0(sp)
 6a6:	6161                	addi	sp,sp,80
 6a8:	8082                	ret

00000000000006aa <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 6aa:	715d                	addi	sp,sp,-80
 6ac:	ec06                	sd	ra,24(sp)
 6ae:	e822                	sd	s0,16(sp)
 6b0:	1000                	addi	s0,sp,32
 6b2:	e010                	sd	a2,0(s0)
 6b4:	e414                	sd	a3,8(s0)
 6b6:	e818                	sd	a4,16(s0)
 6b8:	ec1c                	sd	a5,24(s0)
 6ba:	03043023          	sd	a6,32(s0)
 6be:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 6c2:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 6c6:	8622                	mv	a2,s0
 6c8:	00000097          	auipc	ra,0x0
 6cc:	e16080e7          	jalr	-490(ra) # 4de <vprintf>
}
 6d0:	60e2                	ld	ra,24(sp)
 6d2:	6442                	ld	s0,16(sp)
 6d4:	6161                	addi	sp,sp,80
 6d6:	8082                	ret

00000000000006d8 <printf>:

void
printf(const char *fmt, ...)
{
 6d8:	711d                	addi	sp,sp,-96
 6da:	ec06                	sd	ra,24(sp)
 6dc:	e822                	sd	s0,16(sp)
 6de:	1000                	addi	s0,sp,32
 6e0:	e40c                	sd	a1,8(s0)
 6e2:	e810                	sd	a2,16(s0)
 6e4:	ec14                	sd	a3,24(s0)
 6e6:	f018                	sd	a4,32(s0)
 6e8:	f41c                	sd	a5,40(s0)
 6ea:	03043823          	sd	a6,48(s0)
 6ee:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 6f2:	00840613          	addi	a2,s0,8
 6f6:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 6fa:	85aa                	mv	a1,a0
 6fc:	4505                	li	a0,1
 6fe:	00000097          	auipc	ra,0x0
 702:	de0080e7          	jalr	-544(ra) # 4de <vprintf>
}
 706:	60e2                	ld	ra,24(sp)
 708:	6442                	ld	s0,16(sp)
 70a:	6125                	addi	sp,sp,96
 70c:	8082                	ret

000000000000070e <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 70e:	1141                	addi	sp,sp,-16
 710:	e422                	sd	s0,8(sp)
 712:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 714:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 718:	00001797          	auipc	a5,0x1
 71c:	8e87b783          	ld	a5,-1816(a5) # 1000 <freep>
 720:	a02d                	j	74a <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 722:	4618                	lw	a4,8(a2)
 724:	9f2d                	addw	a4,a4,a1
 726:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 72a:	6398                	ld	a4,0(a5)
 72c:	6310                	ld	a2,0(a4)
 72e:	a83d                	j	76c <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 730:	ff852703          	lw	a4,-8(a0)
 734:	9f31                	addw	a4,a4,a2
 736:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 738:	ff053683          	ld	a3,-16(a0)
 73c:	a091                	j	780 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 73e:	6398                	ld	a4,0(a5)
 740:	00e7e463          	bltu	a5,a4,748 <free+0x3a>
 744:	00e6ea63          	bltu	a3,a4,758 <free+0x4a>
{
 748:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 74a:	fed7fae3          	bgeu	a5,a3,73e <free+0x30>
 74e:	6398                	ld	a4,0(a5)
 750:	00e6e463          	bltu	a3,a4,758 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 754:	fee7eae3          	bltu	a5,a4,748 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 758:	ff852583          	lw	a1,-8(a0)
 75c:	6390                	ld	a2,0(a5)
 75e:	02059813          	slli	a6,a1,0x20
 762:	01c85713          	srli	a4,a6,0x1c
 766:	9736                	add	a4,a4,a3
 768:	fae60de3          	beq	a2,a4,722 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 76c:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 770:	4790                	lw	a2,8(a5)
 772:	02061593          	slli	a1,a2,0x20
 776:	01c5d713          	srli	a4,a1,0x1c
 77a:	973e                	add	a4,a4,a5
 77c:	fae68ae3          	beq	a3,a4,730 <free+0x22>
    p->s.ptr = bp->s.ptr;
 780:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 782:	00001717          	auipc	a4,0x1
 786:	86f73f23          	sd	a5,-1922(a4) # 1000 <freep>
}
 78a:	6422                	ld	s0,8(sp)
 78c:	0141                	addi	sp,sp,16
 78e:	8082                	ret

0000000000000790 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 790:	7139                	addi	sp,sp,-64
 792:	fc06                	sd	ra,56(sp)
 794:	f822                	sd	s0,48(sp)
 796:	f426                	sd	s1,40(sp)
 798:	f04a                	sd	s2,32(sp)
 79a:	ec4e                	sd	s3,24(sp)
 79c:	e852                	sd	s4,16(sp)
 79e:	e456                	sd	s5,8(sp)
 7a0:	e05a                	sd	s6,0(sp)
 7a2:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 7a4:	02051493          	slli	s1,a0,0x20
 7a8:	9081                	srli	s1,s1,0x20
 7aa:	04bd                	addi	s1,s1,15
 7ac:	8091                	srli	s1,s1,0x4
 7ae:	0014899b          	addiw	s3,s1,1
 7b2:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 7b4:	00001517          	auipc	a0,0x1
 7b8:	84c53503          	ld	a0,-1972(a0) # 1000 <freep>
 7bc:	c515                	beqz	a0,7e8 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 7be:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 7c0:	4798                	lw	a4,8(a5)
 7c2:	02977f63          	bgeu	a4,s1,800 <malloc+0x70>
  if(nu < 4096)
 7c6:	8a4e                	mv	s4,s3
 7c8:	0009871b          	sext.w	a4,s3
 7cc:	6685                	lui	a3,0x1
 7ce:	00d77363          	bgeu	a4,a3,7d4 <malloc+0x44>
 7d2:	6a05                	lui	s4,0x1
 7d4:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 7d8:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 7dc:	00001917          	auipc	s2,0x1
 7e0:	82490913          	addi	s2,s2,-2012 # 1000 <freep>
  if(p == (char*)-1)
 7e4:	5afd                	li	s5,-1
 7e6:	a895                	j	85a <malloc+0xca>
    base.s.ptr = freep = prevp = &base;
 7e8:	00065797          	auipc	a5,0x65
 7ec:	83878793          	addi	a5,a5,-1992 # 65020 <base>
 7f0:	00001717          	auipc	a4,0x1
 7f4:	80f73823          	sd	a5,-2032(a4) # 1000 <freep>
 7f8:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 7fa:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 7fe:	b7e1                	j	7c6 <malloc+0x36>
      if(p->s.size == nunits)
 800:	02e48c63          	beq	s1,a4,838 <malloc+0xa8>
        p->s.size -= nunits;
 804:	4137073b          	subw	a4,a4,s3
 808:	c798                	sw	a4,8(a5)
        p += p->s.size;
 80a:	02071693          	slli	a3,a4,0x20
 80e:	01c6d713          	srli	a4,a3,0x1c
 812:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 814:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 818:	00000717          	auipc	a4,0x0
 81c:	7ea73423          	sd	a0,2024(a4) # 1000 <freep>
      return (void*)(p + 1);
 820:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 824:	70e2                	ld	ra,56(sp)
 826:	7442                	ld	s0,48(sp)
 828:	74a2                	ld	s1,40(sp)
 82a:	7902                	ld	s2,32(sp)
 82c:	69e2                	ld	s3,24(sp)
 82e:	6a42                	ld	s4,16(sp)
 830:	6aa2                	ld	s5,8(sp)
 832:	6b02                	ld	s6,0(sp)
 834:	6121                	addi	sp,sp,64
 836:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 838:	6398                	ld	a4,0(a5)
 83a:	e118                	sd	a4,0(a0)
 83c:	bff1                	j	818 <malloc+0x88>
  hp->s.size = nu;
 83e:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 842:	0541                	addi	a0,a0,16
 844:	00000097          	auipc	ra,0x0
 848:	eca080e7          	jalr	-310(ra) # 70e <free>
  return freep;
 84c:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 850:	d971                	beqz	a0,824 <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 852:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 854:	4798                	lw	a4,8(a5)
 856:	fa9775e3          	bgeu	a4,s1,800 <malloc+0x70>
    if(p == freep)
 85a:	00093703          	ld	a4,0(s2)
 85e:	853e                	mv	a0,a5
 860:	fef719e3          	bne	a4,a5,852 <malloc+0xc2>
  p = sbrk(nu * sizeof(Header));
 864:	8552                	mv	a0,s4
 866:	00000097          	auipc	ra,0x0
 86a:	b8a080e7          	jalr	-1142(ra) # 3f0 <sbrk>
  if(p == (char*)-1)
 86e:	fd5518e3          	bne	a0,s5,83e <malloc+0xae>
        return 0;
 872:	4501                	li	a0,0
 874:	bf45                	j	824 <malloc+0x94>

0000000000000876 <get_current_tid>:
struct ulthread *scheduler_thread;
enum ulthread_scheduling_algorithm algorithm;

/* Get thread ID */
int get_current_tid(void)
{
 876:	1141                	addi	sp,sp,-16
 878:	e422                	sd	s0,8(sp)
 87a:	0800                	addi	s0,sp,16
  return current_thread->tid;
}
 87c:	00000797          	auipc	a5,0x0
 880:	79c7b783          	ld	a5,1948(a5) # 1018 <current_thread>
 884:	43c8                	lw	a0,4(a5)
 886:	6422                	ld	s0,8(sp)
 888:	0141                	addi	sp,sp,16
 88a:	8082                	ret

000000000000088c <roundRobin>:

void roundRobin(void)
{
 88c:	715d                	addi	sp,sp,-80
 88e:	e486                	sd	ra,72(sp)
 890:	e0a2                	sd	s0,64(sp)
 892:	fc26                	sd	s1,56(sp)
 894:	f84a                	sd	s2,48(sp)
 896:	f44e                	sd	s3,40(sp)
 898:	f052                	sd	s4,32(sp)
 89a:	ec56                	sd	s5,24(sp)
 89c:	e85a                	sd	s6,16(sp)
 89e:	e45e                	sd	s7,8(sp)
 8a0:	e062                	sd	s8,0(sp)
 8a2:	0880                	addi	s0,sp,80
        struct ulthread *temp = current_thread;
        current_thread = t;
        printf("[*] ultschedule (next tid: %d)\n", get_current_tid());
        ulthread_context_switch(&temp->context, &t->context);
      }
      if (t->state == YIELD)
 8a4:	4a09                	li	s4,2
      if (t->state == RUNNABLE && t != scheduler_thread)
 8a6:	00000b97          	auipc	s7,0x0
 8aa:	76ab8b93          	addi	s7,s7,1898 # 1010 <scheduler_thread>
        struct ulthread *temp = current_thread;
 8ae:	00000a97          	auipc	s5,0x0
 8b2:	76aa8a93          	addi	s5,s5,1898 # 1018 <current_thread>
        printf("[*] ultschedule (next tid: %d)\n", get_current_tid());
 8b6:	00000c17          	auipc	s8,0x0
 8ba:	60ac0c13          	addi	s8,s8,1546 # ec0 <digits+0x18>
    for (t = ulthreads; t < &ulthreads[MAXULTHREADS]; t++)
 8be:	00068997          	auipc	s3,0x68
 8c2:	c9298993          	addi	s3,s3,-878 # 68550 <ulthreads+0x3520>
 8c6:	a0b9                	j	914 <roundRobin+0x88>
      if (t->state == RUNNABLE && t != scheduler_thread)
 8c8:	000bb783          	ld	a5,0(s7)
 8cc:	02978863          	beq	a5,s1,8fc <roundRobin+0x70>
        struct ulthread *temp = current_thread;
 8d0:	000abb03          	ld	s6,0(s5)
        current_thread = t;
 8d4:	009ab023          	sd	s1,0(s5)
        printf("[*] ultschedule (next tid: %d)\n", get_current_tid());
 8d8:	40cc                	lw	a1,4(s1)
 8da:	8562                	mv	a0,s8
 8dc:	00000097          	auipc	ra,0x0
 8e0:	dfc080e7          	jalr	-516(ra) # 6d8 <printf>
        ulthread_context_switch(&temp->context, &t->context);
 8e4:	01848593          	addi	a1,s1,24
 8e8:	018b0513          	addi	a0,s6,24
 8ec:	00000097          	auipc	ra,0x0
 8f0:	46a080e7          	jalr	1130(ra) # d56 <ulthread_context_switch>
        threadAvailable = true;
 8f4:	874a                	mv	a4,s2
 8f6:	a811                	j	90a <roundRobin+0x7e>
      {
        t->state = RUNNABLE;
 8f8:	0124a023          	sw	s2,0(s1)
    for (t = ulthreads; t < &ulthreads[MAXULTHREADS]; t++)
 8fc:	08848493          	addi	s1,s1,136
 900:	01348963          	beq	s1,s3,912 <roundRobin+0x86>
      if (t->state == RUNNABLE && t != scheduler_thread)
 904:	409c                	lw	a5,0(s1)
 906:	fd2781e3          	beq	a5,s2,8c8 <roundRobin+0x3c>
      if (t->state == YIELD)
 90a:	409c                	lw	a5,0(s1)
 90c:	ff4798e3          	bne	a5,s4,8fc <roundRobin+0x70>
 910:	b7e5                	j	8f8 <roundRobin+0x6c>
      }
    }
    if (!threadAvailable)
 912:	cb01                	beqz	a4,922 <roundRobin+0x96>
    bool threadAvailable = false;
 914:	4701                	li	a4,0
    for (t = ulthreads; t < &ulthreads[MAXULTHREADS]; t++)
 916:	00064497          	auipc	s1,0x64
 91a:	71a48493          	addi	s1,s1,1818 # 65030 <ulthreads>
      if (t->state == RUNNABLE && t != scheduler_thread)
 91e:	4905                	li	s2,1
 920:	b7d5                	j	904 <roundRobin+0x78>
    {
      break;
    }
  }
}
 922:	60a6                	ld	ra,72(sp)
 924:	6406                	ld	s0,64(sp)
 926:	74e2                	ld	s1,56(sp)
 928:	7942                	ld	s2,48(sp)
 92a:	79a2                	ld	s3,40(sp)
 92c:	7a02                	ld	s4,32(sp)
 92e:	6ae2                	ld	s5,24(sp)
 930:	6b42                	ld	s6,16(sp)
 932:	6ba2                	ld	s7,8(sp)
 934:	6c02                	ld	s8,0(sp)
 936:	6161                	addi	sp,sp,80
 938:	8082                	ret

000000000000093a <firstComeFirstServe>:

void firstComeFirstServe(void)
{
 93a:	715d                	addi	sp,sp,-80
 93c:	e486                	sd	ra,72(sp)
 93e:	e0a2                	sd	s0,64(sp)
 940:	fc26                	sd	s1,56(sp)
 942:	f84a                	sd	s2,48(sp)
 944:	f44e                	sd	s3,40(sp)
 946:	f052                	sd	s4,32(sp)
 948:	ec56                	sd	s5,24(sp)
 94a:	e85a                	sd	s6,16(sp)
 94c:	e45e                	sd	s7,8(sp)
 94e:	e062                	sd	s8,0(sp)
 950:	0880                	addi	s0,sp,80
    uint64 oldest = __INT64_MAX__;
    int threadIndex = -1;
    int alternativeIndex = -1;
    for (t = ulthreads+1; t < &ulthreads[MAXULTHREADS]; t++)
    {
      if (t->state == RUNNABLE && t != scheduler_thread && t->lastTime < oldest)
 952:	00000b97          	auipc	s7,0x0
 956:	6beb8b93          	addi	s7,s7,1726 # 1010 <scheduler_thread>
    int alternativeIndex = -1;
 95a:	5afd                	li	s5,-1
    uint64 oldest = __INT64_MAX__;
 95c:	001adb13          	srli	s6,s5,0x1
      if (t->state == RUNNABLE && t != scheduler_thread && t->lastTime < oldest)
 960:	4485                	li	s1,1
        oldest = t->lastTime;
        threadIndex = t->tid;
        threadAvailable = true;
      }

      if (t->state == YIELD){
 962:	4989                	li	s3,2
    for (t = ulthreads+1; t < &ulthreads[MAXULTHREADS]; t++)
 964:	00068917          	auipc	s2,0x68
 968:	bec90913          	addi	s2,s2,-1044 # 68550 <ulthreads+0x3520>
        break;
      }
      
    }
    label : 
      struct ulthread *temp = current_thread;
 96c:	00000a17          	auipc	s4,0x0
 970:	6aca0a13          	addi	s4,s4,1708 # 1018 <current_thread>
 974:	a88d                	j	9e6 <firstComeFirstServe+0xac>
      if (t->state == RUNNABLE && t != scheduler_thread && t->lastTime < oldest)
 976:	00f58963          	beq	a1,a5,988 <firstComeFirstServe+0x4e>
 97a:	6b98                	ld	a4,16(a5)
 97c:	00c77663          	bgeu	a4,a2,988 <firstComeFirstServe+0x4e>
        threadIndex = t->tid;
 980:	0047a803          	lw	a6,4(a5)
        oldest = t->lastTime;
 984:	863a                	mv	a2,a4
        threadAvailable = true;
 986:	8526                	mv	a0,s1
    for (t = ulthreads+1; t < &ulthreads[MAXULTHREADS]; t++)
 988:	08878793          	addi	a5,a5,136
 98c:	01278a63          	beq	a5,s2,9a0 <firstComeFirstServe+0x66>
      if (t->state == RUNNABLE && t != scheduler_thread && t->lastTime < oldest)
 990:	4398                	lw	a4,0(a5)
 992:	fe9702e3          	beq	a4,s1,976 <firstComeFirstServe+0x3c>
      if (t->state == YIELD){
 996:	ff3719e3          	bne	a4,s3,988 <firstComeFirstServe+0x4e>
        t->state = RUNNABLE;
 99a:	c384                	sw	s1,0(a5)
        alternativeIndex = t->tid;
 99c:	43d4                	lw	a3,4(a5)
 99e:	b7ed                	j	988 <firstComeFirstServe+0x4e>
    if (!threadAvailable)
 9a0:	ed31                	bnez	a0,9fc <firstComeFirstServe+0xc2>
      if(alternativeIndex > 0){
 9a2:	04d05f63          	blez	a3,a00 <firstComeFirstServe+0xc6>
      struct ulthread *temp = current_thread;
 9a6:	000a3c03          	ld	s8,0(s4)
      current_thread = &ulthreads[threadIndex];
 9aa:	00469793          	slli	a5,a3,0x4
 9ae:	00d78733          	add	a4,a5,a3
 9b2:	070e                	slli	a4,a4,0x3
 9b4:	00064617          	auipc	a2,0x64
 9b8:	67c60613          	addi	a2,a2,1660 # 65030 <ulthreads>
 9bc:	9732                	add	a4,a4,a2
 9be:	00ea3023          	sd	a4,0(s4)
      printf("[*] ultschedule (next tid: %d), time = %d\n", get_current_tid());
 9c2:	434c                	lw	a1,4(a4)
 9c4:	00000517          	auipc	a0,0x0
 9c8:	51c50513          	addi	a0,a0,1308 # ee0 <digits+0x38>
 9cc:	00000097          	auipc	ra,0x0
 9d0:	d0c080e7          	jalr	-756(ra) # 6d8 <printf>
      ulthread_context_switch(&temp->context, &current_thread->context);
 9d4:	000a3583          	ld	a1,0(s4)
 9d8:	05e1                	addi	a1,a1,24
 9da:	018c0513          	addi	a0,s8,24
 9de:	00000097          	auipc	ra,0x0
 9e2:	378080e7          	jalr	888(ra) # d56 <ulthread_context_switch>
      if (t->state == RUNNABLE && t != scheduler_thread && t->lastTime < oldest)
 9e6:	000bb583          	ld	a1,0(s7)
    int alternativeIndex = -1;
 9ea:	86d6                	mv	a3,s5
    int threadIndex = -1;
 9ec:	8856                	mv	a6,s5
    uint64 oldest = __INT64_MAX__;
 9ee:	865a                	mv	a2,s6
    bool threadAvailable = false;
 9f0:	4501                	li	a0,0
    for (t = ulthreads+1; t < &ulthreads[MAXULTHREADS]; t++)
 9f2:	00064797          	auipc	a5,0x64
 9f6:	6c678793          	addi	a5,a5,1734 # 650b8 <ulthreads+0x88>
 9fa:	bf59                	j	990 <firstComeFirstServe+0x56>
    label : 
 9fc:	86c2                	mv	a3,a6
 9fe:	b765                	j	9a6 <firstComeFirstServe+0x6c>
  }
}
 a00:	60a6                	ld	ra,72(sp)
 a02:	6406                	ld	s0,64(sp)
 a04:	74e2                	ld	s1,56(sp)
 a06:	7942                	ld	s2,48(sp)
 a08:	79a2                	ld	s3,40(sp)
 a0a:	7a02                	ld	s4,32(sp)
 a0c:	6ae2                	ld	s5,24(sp)
 a0e:	6b42                	ld	s6,16(sp)
 a10:	6ba2                	ld	s7,8(sp)
 a12:	6c02                	ld	s8,0(sp)
 a14:	6161                	addi	sp,sp,80
 a16:	8082                	ret

0000000000000a18 <priorityScheduling>:


void priorityScheduling(void)
{
 a18:	715d                	addi	sp,sp,-80
 a1a:	e486                	sd	ra,72(sp)
 a1c:	e0a2                	sd	s0,64(sp)
 a1e:	fc26                	sd	s1,56(sp)
 a20:	f84a                	sd	s2,48(sp)
 a22:	f44e                	sd	s3,40(sp)
 a24:	f052                	sd	s4,32(sp)
 a26:	ec56                	sd	s5,24(sp)
 a28:	e85a                	sd	s6,16(sp)
 a2a:	e45e                	sd	s7,8(sp)
 a2c:	0880                	addi	s0,sp,80
    int maxPriority = -1;
    int threadIndex = -1;
    int alternativeIndex = -1;
    for (t = ulthreads+1; t < &ulthreads[MAXULTHREADS]; t++)
    {
      if (t->state == RUNNABLE && t != scheduler_thread && t->priority > maxPriority)
 a2e:	00000b17          	auipc	s6,0x0
 a32:	5e2b0b13          	addi	s6,s6,1506 # 1010 <scheduler_thread>
    int alternativeIndex = -1;
 a36:	5a7d                	li	s4,-1
      if (t->state == RUNNABLE && t != scheduler_thread && t->priority > maxPriority)
 a38:	4485                	li	s1,1
        // flag = true;

        // break; // switch to highest-priority thread and exit loop
      }

      if (t->state == YIELD){
 a3a:	4989                	li	s3,2
    for (t = ulthreads+1; t < &ulthreads[MAXULTHREADS]; t++)
 a3c:	00068917          	auipc	s2,0x68
 a40:	b1490913          	addi	s2,s2,-1260 # 68550 <ulthreads+0x3520>
        break;
      }
      
    }
    label : 
      struct ulthread *temp = current_thread;
 a44:	00000a97          	auipc	s5,0x0
 a48:	5d4a8a93          	addi	s5,s5,1492 # 1018 <current_thread>
 a4c:	a88d                	j	abe <priorityScheduling+0xa6>
      if (t->state == RUNNABLE && t != scheduler_thread && t->priority > maxPriority)
 a4e:	00f58963          	beq	a1,a5,a60 <priorityScheduling+0x48>
 a52:	47d8                	lw	a4,12(a5)
 a54:	00e65663          	bge	a2,a4,a60 <priorityScheduling+0x48>
        threadIndex = t->tid;
 a58:	0047a803          	lw	a6,4(a5)
        maxPriority = t->priority;
 a5c:	863a                	mv	a2,a4
        threadAvailable = true;
 a5e:	8526                	mv	a0,s1
    for (t = ulthreads+1; t < &ulthreads[MAXULTHREADS]; t++)
 a60:	08878793          	addi	a5,a5,136
 a64:	01278a63          	beq	a5,s2,a78 <priorityScheduling+0x60>
      if (t->state == RUNNABLE && t != scheduler_thread && t->priority > maxPriority)
 a68:	4398                	lw	a4,0(a5)
 a6a:	fe9702e3          	beq	a4,s1,a4e <priorityScheduling+0x36>
      if (t->state == YIELD){
 a6e:	ff3719e3          	bne	a4,s3,a60 <priorityScheduling+0x48>
        t->state = RUNNABLE;
 a72:	c384                	sw	s1,0(a5)
        alternativeIndex = t->tid;
 a74:	43d4                	lw	a3,4(a5)
 a76:	b7ed                	j	a60 <priorityScheduling+0x48>
    if (!threadAvailable)
 a78:	ed31                	bnez	a0,ad4 <priorityScheduling+0xbc>
      if(alternativeIndex > 0){
 a7a:	04d05f63          	blez	a3,ad8 <priorityScheduling+0xc0>
      struct ulthread *temp = current_thread;
 a7e:	000abb83          	ld	s7,0(s5)
      current_thread = &ulthreads[threadIndex];
 a82:	00469793          	slli	a5,a3,0x4
 a86:	00d78733          	add	a4,a5,a3
 a8a:	070e                	slli	a4,a4,0x3
 a8c:	00064617          	auipc	a2,0x64
 a90:	5a460613          	addi	a2,a2,1444 # 65030 <ulthreads>
 a94:	9732                	add	a4,a4,a2
 a96:	00eab023          	sd	a4,0(s5)
      printf("[*] ultschedule (next tid: %d)\n", get_current_tid());
 a9a:	434c                	lw	a1,4(a4)
 a9c:	00000517          	auipc	a0,0x0
 aa0:	42450513          	addi	a0,a0,1060 # ec0 <digits+0x18>
 aa4:	00000097          	auipc	ra,0x0
 aa8:	c34080e7          	jalr	-972(ra) # 6d8 <printf>
      ulthread_context_switch(&temp->context, &current_thread->context);
 aac:	000ab583          	ld	a1,0(s5)
 ab0:	05e1                	addi	a1,a1,24
 ab2:	018b8513          	addi	a0,s7,24
 ab6:	00000097          	auipc	ra,0x0
 aba:	2a0080e7          	jalr	672(ra) # d56 <ulthread_context_switch>
      if (t->state == RUNNABLE && t != scheduler_thread && t->priority > maxPriority)
 abe:	000b3583          	ld	a1,0(s6)
    int alternativeIndex = -1;
 ac2:	86d2                	mv	a3,s4
    int threadIndex = -1;
 ac4:	8852                	mv	a6,s4
    int maxPriority = -1;
 ac6:	8652                	mv	a2,s4
    bool threadAvailable = false;
 ac8:	4501                	li	a0,0
    for (t = ulthreads+1; t < &ulthreads[MAXULTHREADS]; t++)
 aca:	00064797          	auipc	a5,0x64
 ace:	5ee78793          	addi	a5,a5,1518 # 650b8 <ulthreads+0x88>
 ad2:	bf59                	j	a68 <priorityScheduling+0x50>
    label : 
 ad4:	86c2                	mv	a3,a6
 ad6:	b765                	j	a7e <priorityScheduling+0x66>
  }
}
 ad8:	60a6                	ld	ra,72(sp)
 ada:	6406                	ld	s0,64(sp)
 adc:	74e2                	ld	s1,56(sp)
 ade:	7942                	ld	s2,48(sp)
 ae0:	79a2                	ld	s3,40(sp)
 ae2:	7a02                	ld	s4,32(sp)
 ae4:	6ae2                	ld	s5,24(sp)
 ae6:	6b42                	ld	s6,16(sp)
 ae8:	6ba2                	ld	s7,8(sp)
 aea:	6161                	addi	sp,sp,80
 aec:	8082                	ret

0000000000000aee <ulthread_init>:

/* Thread initialization */
void ulthread_init(int schedalgo)
{
 aee:	1141                	addi	sp,sp,-16
 af0:	e422                	sd	s0,8(sp)
 af2:	0800                	addi	s0,sp,16
  struct ulthread *t;
  int i;
  for (i = 0, t = ulthreads; t < &ulthreads[MAXULTHREADS]; t++, i++)
 af4:	4701                	li	a4,0
 af6:	00064797          	auipc	a5,0x64
 afa:	53a78793          	addi	a5,a5,1338 # 65030 <ulthreads>
 afe:	00068697          	auipc	a3,0x68
 b02:	a5268693          	addi	a3,a3,-1454 # 68550 <ulthreads+0x3520>
  {
    t->state = FREE;
 b06:	0007a023          	sw	zero,0(a5)
    t->tid = i;
 b0a:	c3d8                	sw	a4,4(a5)
  for (i = 0, t = ulthreads; t < &ulthreads[MAXULTHREADS]; t++, i++)
 b0c:	08878793          	addi	a5,a5,136
 b10:	2705                	addiw	a4,a4,1
 b12:	fed79ae3          	bne	a5,a3,b06 <ulthread_init+0x18>
  }
  current_thread = &ulthreads[0];
 b16:	00064797          	auipc	a5,0x64
 b1a:	51a78793          	addi	a5,a5,1306 # 65030 <ulthreads>
 b1e:	00000717          	auipc	a4,0x0
 b22:	4ef73d23          	sd	a5,1274(a4) # 1018 <current_thread>
  scheduler_thread = &ulthreads[0];
 b26:	00000717          	auipc	a4,0x0
 b2a:	4ef73523          	sd	a5,1258(a4) # 1010 <scheduler_thread>
  scheduler_thread->state = RUNNABLE;
 b2e:	4705                	li	a4,1
 b30:	c398                	sw	a4,0(a5)
  t->state = FREE;
 b32:	00068797          	auipc	a5,0x68
 b36:	a007af23          	sw	zero,-1506(a5) # 68550 <ulthreads+0x3520>
  algorithm = schedalgo;
 b3a:	00000797          	auipc	a5,0x0
 b3e:	4ca7a723          	sw	a0,1230(a5) # 1008 <algorithm>
}
 b42:	6422                	ld	s0,8(sp)
 b44:	0141                	addi	sp,sp,16
 b46:	8082                	ret

0000000000000b48 <ulthread_create>:

/* Thread creation */
bool ulthread_create(uint64 start, uint64 stack, uint64 args[], int priority)
{
 b48:	7179                	addi	sp,sp,-48
 b4a:	f406                	sd	ra,40(sp)
 b4c:	f022                	sd	s0,32(sp)
 b4e:	ec26                	sd	s1,24(sp)
 b50:	e84a                	sd	s2,16(sp)
 b52:	e44e                	sd	s3,8(sp)
 b54:	e052                	sd	s4,0(sp)
 b56:	1800                	addi	s0,sp,48
 b58:	89aa                	mv	s3,a0
 b5a:	8a2e                	mv	s4,a1
 b5c:	8932                	mv	s2,a2
  /* Please add thread-id instead of '0' here. */
  struct ulthread *t;
  bool flag = false;
  for (t = ulthreads; t < &ulthreads[MAXULTHREADS]; t++)
 b5e:	00064497          	auipc	s1,0x64
 b62:	4d248493          	addi	s1,s1,1234 # 65030 <ulthreads>
 b66:	00068717          	auipc	a4,0x68
 b6a:	9ea70713          	addi	a4,a4,-1558 # 68550 <ulthreads+0x3520>
  {
    if (t->state == FREE)
 b6e:	409c                	lw	a5,0(s1)
 b70:	cf89                	beqz	a5,b8a <ulthread_create+0x42>
  for (t = ulthreads; t < &ulthreads[MAXULTHREADS]; t++)
 b72:	08848493          	addi	s1,s1,136
 b76:	fee49ce3          	bne	s1,a4,b6e <ulthread_create+0x26>
      break;
    }
  }
  if (!flag)
  {
    return false;
 b7a:	4501                	li	a0,0
 b7c:	a871                	j	c18 <ulthread_create+0xd0>
  t->sp = (int)(stack + USTACKSIZE); // set sp to the top of the stack
  t->state = RUNNABLE;
  t->priority = priority;

  if(algorithm==FCFS){
    t->lastTime = ctime();
 b7e:	00000097          	auipc	ra,0x0
 b82:	88a080e7          	jalr	-1910(ra) # 408 <ctime>
 b86:	e888                	sd	a0,16(s1)
 b88:	a839                	j	ba6 <ulthread_create+0x5e>
  t->sp = (int)(stack + USTACKSIZE); // set sp to the top of the stack
 b8a:	6785                	lui	a5,0x1
 b8c:	014787bb          	addw	a5,a5,s4
 b90:	c49c                	sw	a5,8(s1)
  t->state = RUNNABLE;
 b92:	4785                	li	a5,1
 b94:	c09c                	sw	a5,0(s1)
  t->priority = priority;
 b96:	c4d4                	sw	a3,12(s1)
  if(algorithm==FCFS){
 b98:	00000717          	auipc	a4,0x0
 b9c:	47072703          	lw	a4,1136(a4) # 1008 <algorithm>
 ba0:	4789                	li	a5,2
 ba2:	fcf70ee3          	beq	a4,a5,b7e <ulthread_create+0x36>
  }

  for (int argc = 0; argc < 6; argc++)
 ba6:	874a                	mv	a4,s2
 ba8:	03090693          	addi	a3,s2,48
  {
    t->sp -= 16;
 bac:	449c                	lw	a5,8(s1)
 bae:	37c1                	addiw	a5,a5,-16 # ff0 <digits+0x148>
 bb0:	0007881b          	sext.w	a6,a5
 bb4:	c49c                	sw	a5,8(s1)
    *(uint64 *)(t->sp) = (uint64)args[argc];
 bb6:	631c                	ld	a5,0(a4)
 bb8:	00f83023          	sd	a5,0(a6)
  for (int argc = 0; argc < 6; argc++)
 bbc:	0721                	addi	a4,a4,8
 bbe:	fed717e3          	bne	a4,a3,bac <ulthread_create+0x64>
  }

  memset(&t->context, 0, sizeof(t->context));
 bc2:	07000613          	li	a2,112
 bc6:	4581                	li	a1,0
 bc8:	01848513          	addi	a0,s1,24
 bcc:	fffff097          	auipc	ra,0xfffff
 bd0:	5a2080e7          	jalr	1442(ra) # 16e <memset>
  t->context.ra = start;
 bd4:	0134bc23          	sd	s3,24(s1)
  t->context.sp = t->sp;
 bd8:	449c                	lw	a5,8(s1)
 bda:	f09c                	sd	a5,32(s1)
  t->context.s0 = args[0];
 bdc:	00093783          	ld	a5,0(s2)
 be0:	f49c                	sd	a5,40(s1)
  t->context.s1 = args[1];
 be2:	00893783          	ld	a5,8(s2)
 be6:	f89c                	sd	a5,48(s1)
  t->context.s2 = args[2];
 be8:	01093783          	ld	a5,16(s2)
 bec:	fc9c                	sd	a5,56(s1)
  t->context.s3 = args[3];
 bee:	01893783          	ld	a5,24(s2)
 bf2:	e0bc                	sd	a5,64(s1)
  t->context.s4 = args[4];
 bf4:	02093783          	ld	a5,32(s2)
 bf8:	e4bc                	sd	a5,72(s1)
  t->context.s5 = args[5];
 bfa:	02893783          	ld	a5,40(s2)
 bfe:	e8bc                	sd	a5,80(s1)

  printf("[*] ultcreate(tid: %d, ra: %p, sp: %p)\n", t->tid, start, stack);
 c00:	86d2                	mv	a3,s4
 c02:	864e                	mv	a2,s3
 c04:	40cc                	lw	a1,4(s1)
 c06:	00000517          	auipc	a0,0x0
 c0a:	30a50513          	addi	a0,a0,778 # f10 <digits+0x68>
 c0e:	00000097          	auipc	ra,0x0
 c12:	aca080e7          	jalr	-1334(ra) # 6d8 <printf>
  return true;
 c16:	4505                	li	a0,1
}
 c18:	70a2                	ld	ra,40(sp)
 c1a:	7402                	ld	s0,32(sp)
 c1c:	64e2                	ld	s1,24(sp)
 c1e:	6942                	ld	s2,16(sp)
 c20:	69a2                	ld	s3,8(sp)
 c22:	6a02                	ld	s4,0(sp)
 c24:	6145                	addi	sp,sp,48
 c26:	8082                	ret

0000000000000c28 <ulthread_schedule>:

/* Thread scheduler */
void ulthread_schedule(void)
{
 c28:	1141                	addi	sp,sp,-16
 c2a:	e406                	sd	ra,8(sp)
 c2c:	e022                	sd	s0,0(sp)
 c2e:	0800                	addi	s0,sp,16
  switch (algorithm)
 c30:	00000797          	auipc	a5,0x0
 c34:	3d87a783          	lw	a5,984(a5) # 1008 <algorithm>
 c38:	4705                	li	a4,1
 c3a:	02e78463          	beq	a5,a4,c62 <ulthread_schedule+0x3a>
 c3e:	4709                	li	a4,2
 c40:	00e78c63          	beq	a5,a4,c58 <ulthread_schedule+0x30>
 c44:	c789                	beqz	a5,c4e <ulthread_schedule+0x26>

  // Push argument strings, prepare rest of stack in ustack.

  // Switch between thread contexts
  // ulthread_context_switch(NULL, NULL);
}
 c46:	60a2                	ld	ra,8(sp)
 c48:	6402                	ld	s0,0(sp)
 c4a:	0141                	addi	sp,sp,16
 c4c:	8082                	ret
    roundRobin();
 c4e:	00000097          	auipc	ra,0x0
 c52:	c3e080e7          	jalr	-962(ra) # 88c <roundRobin>
    break;
 c56:	bfc5                	j	c46 <ulthread_schedule+0x1e>
    firstComeFirstServe();
 c58:	00000097          	auipc	ra,0x0
 c5c:	ce2080e7          	jalr	-798(ra) # 93a <firstComeFirstServe>
    break;
 c60:	b7dd                	j	c46 <ulthread_schedule+0x1e>
    priorityScheduling();
 c62:	00000097          	auipc	ra,0x0
 c66:	db6080e7          	jalr	-586(ra) # a18 <priorityScheduling>
}
 c6a:	bff1                	j	c46 <ulthread_schedule+0x1e>

0000000000000c6c <ulthread_yield>:

/* Yield CPU time to some other thread. */
void ulthread_yield(void)
{
 c6c:	1101                	addi	sp,sp,-32
 c6e:	ec06                	sd	ra,24(sp)
 c70:	e822                	sd	s0,16(sp)
 c72:	e426                	sd	s1,8(sp)
 c74:	e04a                	sd	s2,0(sp)
 c76:	1000                	addi	s0,sp,32
  current_thread->state = YIELD;
 c78:	00000797          	auipc	a5,0x0
 c7c:	3a078793          	addi	a5,a5,928 # 1018 <current_thread>
 c80:	6398                	ld	a4,0(a5)
 c82:	4909                	li	s2,2
 c84:	01272023          	sw	s2,0(a4)
  struct ulthread *temp = current_thread;
 c88:	6384                	ld	s1,0(a5)
  printf("[*] ultyield(tid: %d)\n", current_thread->tid);
 c8a:	40cc                	lw	a1,4(s1)
 c8c:	00000517          	auipc	a0,0x0
 c90:	2ac50513          	addi	a0,a0,684 # f38 <digits+0x90>
 c94:	00000097          	auipc	ra,0x0
 c98:	a44080e7          	jalr	-1468(ra) # 6d8 <printf>
  if(algorithm==FCFS){
 c9c:	00000797          	auipc	a5,0x0
 ca0:	36c7a783          	lw	a5,876(a5) # 1008 <algorithm>
 ca4:	03278763          	beq	a5,s2,cd2 <ulthread_yield+0x66>
    current_thread->lastTime = ctime();
  }
  current_thread = scheduler_thread;
 ca8:	00000597          	auipc	a1,0x0
 cac:	3685b583          	ld	a1,872(a1) # 1010 <scheduler_thread>
 cb0:	00000797          	auipc	a5,0x0
 cb4:	36b7b423          	sd	a1,872(a5) # 1018 <current_thread>
  
  ulthread_context_switch(&temp->context, &scheduler_thread->context);
 cb8:	05e1                	addi	a1,a1,24
 cba:	01848513          	addi	a0,s1,24
 cbe:	00000097          	auipc	ra,0x0
 cc2:	098080e7          	jalr	152(ra) # d56 <ulthread_context_switch>
  // ulthread_schedule();
}
 cc6:	60e2                	ld	ra,24(sp)
 cc8:	6442                	ld	s0,16(sp)
 cca:	64a2                	ld	s1,8(sp)
 ccc:	6902                	ld	s2,0(sp)
 cce:	6105                	addi	sp,sp,32
 cd0:	8082                	ret
    current_thread->lastTime = ctime();
 cd2:	fffff097          	auipc	ra,0xfffff
 cd6:	736080e7          	jalr	1846(ra) # 408 <ctime>
 cda:	00000797          	auipc	a5,0x0
 cde:	33e7b783          	ld	a5,830(a5) # 1018 <current_thread>
 ce2:	eb88                	sd	a0,16(a5)
 ce4:	b7d1                	j	ca8 <ulthread_yield+0x3c>

0000000000000ce6 <ulthread_destroy>:

/* Destroy thread */
void ulthread_destroy(void)
{
 ce6:	1101                	addi	sp,sp,-32
 ce8:	ec06                	sd	ra,24(sp)
 cea:	e822                	sd	s0,16(sp)
 cec:	e426                	sd	s1,8(sp)
 cee:	e04a                	sd	s2,0(sp)
 cf0:	1000                	addi	s0,sp,32
  memset(&current_thread->context, 0, sizeof(current_thread->context));
 cf2:	00000497          	auipc	s1,0x0
 cf6:	32648493          	addi	s1,s1,806 # 1018 <current_thread>
 cfa:	6088                	ld	a0,0(s1)
 cfc:	07000613          	li	a2,112
 d00:	4581                	li	a1,0
 d02:	0561                	addi	a0,a0,24
 d04:	fffff097          	auipc	ra,0xfffff
 d08:	46a080e7          	jalr	1130(ra) # 16e <memset>
  current_thread->sp = 0;
 d0c:	609c                	ld	a5,0(s1)
 d0e:	0007a423          	sw	zero,8(a5)
  current_thread->priority = -1;
 d12:	577d                	li	a4,-1
 d14:	c7d8                	sw	a4,12(a5)
  current_thread->state = FREE;
 d16:	0007a023          	sw	zero,0(a5)

  struct ulthread *temp = current_thread;
 d1a:	0004b903          	ld	s2,0(s1)

  printf("[*] ultdestroy(tid: %d)\n", get_current_tid());
 d1e:	00492583          	lw	a1,4(s2)
 d22:	00000517          	auipc	a0,0x0
 d26:	22e50513          	addi	a0,a0,558 # f50 <digits+0xa8>
 d2a:	00000097          	auipc	ra,0x0
 d2e:	9ae080e7          	jalr	-1618(ra) # 6d8 <printf>
  current_thread = scheduler_thread;
 d32:	00000597          	auipc	a1,0x0
 d36:	2de5b583          	ld	a1,734(a1) # 1010 <scheduler_thread>
 d3a:	e08c                	sd	a1,0(s1)
  ulthread_context_switch(&temp->context, &scheduler_thread->context);
 d3c:	05e1                	addi	a1,a1,24
 d3e:	01890513          	addi	a0,s2,24
 d42:	00000097          	auipc	ra,0x0
 d46:	014080e7          	jalr	20(ra) # d56 <ulthread_context_switch>
}
 d4a:	60e2                	ld	ra,24(sp)
 d4c:	6442                	ld	s0,16(sp)
 d4e:	64a2                	ld	s1,8(sp)
 d50:	6902                	ld	s2,0(sp)
 d52:	6105                	addi	sp,sp,32
 d54:	8082                	ret

0000000000000d56 <ulthread_context_switch>:
 d56:	00153023          	sd	ra,0(a0)
 d5a:	00253423          	sd	sp,8(a0)
 d5e:	e900                	sd	s0,16(a0)
 d60:	ed04                	sd	s1,24(a0)
 d62:	03253023          	sd	s2,32(a0)
 d66:	03353423          	sd	s3,40(a0)
 d6a:	03453823          	sd	s4,48(a0)
 d6e:	03553c23          	sd	s5,56(a0)
 d72:	05653023          	sd	s6,64(a0)
 d76:	05753423          	sd	s7,72(a0)
 d7a:	05853823          	sd	s8,80(a0)
 d7e:	05953c23          	sd	s9,88(a0)
 d82:	07a53023          	sd	s10,96(a0)
 d86:	07b53423          	sd	s11,104(a0)
 d8a:	0005b083          	ld	ra,0(a1)
 d8e:	0085b103          	ld	sp,8(a1)
 d92:	6980                	ld	s0,16(a1)
 d94:	6d84                	ld	s1,24(a1)
 d96:	0205b903          	ld	s2,32(a1)
 d9a:	0285b983          	ld	s3,40(a1)
 d9e:	0305ba03          	ld	s4,48(a1)
 da2:	0385ba83          	ld	s5,56(a1)
 da6:	0405bb03          	ld	s6,64(a1)
 daa:	0485bb83          	ld	s7,72(a1)
 dae:	0505bc03          	ld	s8,80(a1)
 db2:	0585bc83          	ld	s9,88(a1)
 db6:	0605bd03          	ld	s10,96(a1)
 dba:	0685bd83          	ld	s11,104(a1)
 dbe:	6546                	ld	a0,80(sp)
 dc0:	6586                	ld	a1,64(sp)
 dc2:	7642                	ld	a2,48(sp)
 dc4:	7682                	ld	a3,32(sp)
 dc6:	6742                	ld	a4,16(sp)
 dc8:	6782                	ld	a5,0(sp)
 dca:	8082                	ret
