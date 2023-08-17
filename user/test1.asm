
user/_test1:     file format elf64-littleriscv


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
   8:	3e800793          	li	a5,1000
    /* Start the thread here. */
    for (int i = 0; i < 1000; i++);
   c:	37fd                	addiw	a5,a5,-1
   e:	fffd                	bnez	a5,c <ul_start_func+0xc>

    printf("[.] started the thread function (tid = %d)\n", get_current_tid());
  10:	00001097          	auipc	ra,0x1
  14:	858080e7          	jalr	-1960(ra) # 868 <get_current_tid>
  18:	85aa                	mv	a1,a0
  1a:	00001517          	auipc	a0,0x1
  1e:	da650513          	addi	a0,a0,-602 # dc0 <ulthread_context_switch+0x78>
  22:	00000097          	auipc	ra,0x0
  26:	6a8080e7          	jalr	1704(ra) # 6ca <printf>

    /* Notify for a thread exit. */
    ulthread_destroy();
  2a:	00001097          	auipc	ra,0x1
  2e:	cae080e7          	jalr	-850(ra) # cd8 <ulthread_destroy>
    printf("[*] ultdestroy(tid: %d) \n", get_current_tid());
  32:	00001097          	auipc	ra,0x1
  36:	836080e7          	jalr	-1994(ra) # 868 <get_current_tid>
  3a:	85aa                	mv	a1,a0
  3c:	00001517          	auipc	a0,0x1
  40:	db450513          	addi	a0,a0,-588 # df0 <ulthread_context_switch+0xa8>
  44:	00000097          	auipc	ra,0x0
  48:	686080e7          	jalr	1670(ra) # 6ca <printf>
}
  4c:	60a2                	ld	ra,8(sp)
  4e:	6402                	ld	s0,0(sp)
  50:	0141                	addi	sp,sp,16
  52:	8082                	ret

0000000000000054 <main>:

int
main(int argc, char *argv[])
{
  54:	7139                	addi	sp,sp,-64
  56:	fc06                	sd	ra,56(sp)
  58:	f822                	sd	s0,48(sp)
  5a:	0080                	addi	s0,sp,64
    /* Clear the stack region */
    memset(&stacks, 0, sizeof(stacks));
  5c:	00064637          	lui	a2,0x64
  60:	4581                	li	a1,0
  62:	00001517          	auipc	a0,0x1
  66:	fbe50513          	addi	a0,a0,-66 # 1020 <stacks>
  6a:	00000097          	auipc	ra,0x0
  6e:	0f6080e7          	jalr	246(ra) # 160 <memset>

    /* Initialize the user-level threading library */
    ulthread_init(ROUNDROBIN);
  72:	4501                	li	a0,0
  74:	00001097          	auipc	ra,0x1
  78:	a6c080e7          	jalr	-1428(ra) # ae0 <ulthread_init>

    /* Create a user-level thread */
    uint64 args[6] = {0,0,0,0,0,0};   
  7c:	fc043023          	sd	zero,-64(s0)
  80:	fc043423          	sd	zero,-56(s0)
  84:	fc043823          	sd	zero,-48(s0)
  88:	fc043c23          	sd	zero,-40(s0)
  8c:	fe043023          	sd	zero,-32(s0)
  90:	fe043423          	sd	zero,-24(s0)
 
    ulthread_create((uint64) ul_start_func, (uint64) stacks+PGSIZE, args, -1);
  94:	56fd                	li	a3,-1
  96:	fc040613          	addi	a2,s0,-64
  9a:	00002597          	auipc	a1,0x2
  9e:	f8658593          	addi	a1,a1,-122 # 2020 <stacks+0x1000>
  a2:	00000517          	auipc	a0,0x0
  a6:	f5e50513          	addi	a0,a0,-162 # 0 <ul_start_func>
  aa:	00001097          	auipc	ra,0x1
  ae:	a90080e7          	jalr	-1392(ra) # b3a <ulthread_create>
    /* Schedule some of the threads */
    ulthread_schedule();
  b2:	00001097          	auipc	ra,0x1
  b6:	b68080e7          	jalr	-1176(ra) # c1a <ulthread_schedule>

    printf("[*] User-Level Threading Test #1 Complete.\n");
  ba:	00001517          	auipc	a0,0x1
  be:	d5650513          	addi	a0,a0,-682 # e10 <ulthread_context_switch+0xc8>
  c2:	00000097          	auipc	ra,0x0
  c6:	608080e7          	jalr	1544(ra) # 6ca <printf>
    return 0;
}
  ca:	4501                	li	a0,0
  cc:	70e2                	ld	ra,56(sp)
  ce:	7442                	ld	s0,48(sp)
  d0:	6121                	addi	sp,sp,64
  d2:	8082                	ret

00000000000000d4 <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
  d4:	1141                	addi	sp,sp,-16
  d6:	e406                	sd	ra,8(sp)
  d8:	e022                	sd	s0,0(sp)
  da:	0800                	addi	s0,sp,16
  extern int main();
  main();
  dc:	00000097          	auipc	ra,0x0
  e0:	f78080e7          	jalr	-136(ra) # 54 <main>
  exit(0);
  e4:	4501                	li	a0,0
  e6:	00000097          	auipc	ra,0x0
  ea:	274080e7          	jalr	628(ra) # 35a <exit>

00000000000000ee <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
  ee:	1141                	addi	sp,sp,-16
  f0:	e422                	sd	s0,8(sp)
  f2:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  f4:	87aa                	mv	a5,a0
  f6:	0585                	addi	a1,a1,1
  f8:	0785                	addi	a5,a5,1
  fa:	fff5c703          	lbu	a4,-1(a1)
  fe:	fee78fa3          	sb	a4,-1(a5)
 102:	fb75                	bnez	a4,f6 <strcpy+0x8>
    ;
  return os;
}
 104:	6422                	ld	s0,8(sp)
 106:	0141                	addi	sp,sp,16
 108:	8082                	ret

000000000000010a <strcmp>:

int
strcmp(const char *p, const char *q)
{
 10a:	1141                	addi	sp,sp,-16
 10c:	e422                	sd	s0,8(sp)
 10e:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 110:	00054783          	lbu	a5,0(a0)
 114:	cb91                	beqz	a5,128 <strcmp+0x1e>
 116:	0005c703          	lbu	a4,0(a1)
 11a:	00f71763          	bne	a4,a5,128 <strcmp+0x1e>
    p++, q++;
 11e:	0505                	addi	a0,a0,1
 120:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 122:	00054783          	lbu	a5,0(a0)
 126:	fbe5                	bnez	a5,116 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 128:	0005c503          	lbu	a0,0(a1)
}
 12c:	40a7853b          	subw	a0,a5,a0
 130:	6422                	ld	s0,8(sp)
 132:	0141                	addi	sp,sp,16
 134:	8082                	ret

0000000000000136 <strlen>:

uint
strlen(const char *s)
{
 136:	1141                	addi	sp,sp,-16
 138:	e422                	sd	s0,8(sp)
 13a:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 13c:	00054783          	lbu	a5,0(a0)
 140:	cf91                	beqz	a5,15c <strlen+0x26>
 142:	0505                	addi	a0,a0,1
 144:	87aa                	mv	a5,a0
 146:	86be                	mv	a3,a5
 148:	0785                	addi	a5,a5,1
 14a:	fff7c703          	lbu	a4,-1(a5)
 14e:	ff65                	bnez	a4,146 <strlen+0x10>
 150:	40a6853b          	subw	a0,a3,a0
 154:	2505                	addiw	a0,a0,1
    ;
  return n;
}
 156:	6422                	ld	s0,8(sp)
 158:	0141                	addi	sp,sp,16
 15a:	8082                	ret
  for(n = 0; s[n]; n++)
 15c:	4501                	li	a0,0
 15e:	bfe5                	j	156 <strlen+0x20>

0000000000000160 <memset>:

void*
memset(void *dst, int c, uint n)
{
 160:	1141                	addi	sp,sp,-16
 162:	e422                	sd	s0,8(sp)
 164:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 166:	ca19                	beqz	a2,17c <memset+0x1c>
 168:	87aa                	mv	a5,a0
 16a:	1602                	slli	a2,a2,0x20
 16c:	9201                	srli	a2,a2,0x20
 16e:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 172:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 176:	0785                	addi	a5,a5,1
 178:	fee79de3          	bne	a5,a4,172 <memset+0x12>
  }
  return dst;
}
 17c:	6422                	ld	s0,8(sp)
 17e:	0141                	addi	sp,sp,16
 180:	8082                	ret

0000000000000182 <strchr>:

char*
strchr(const char *s, char c)
{
 182:	1141                	addi	sp,sp,-16
 184:	e422                	sd	s0,8(sp)
 186:	0800                	addi	s0,sp,16
  for(; *s; s++)
 188:	00054783          	lbu	a5,0(a0)
 18c:	cb99                	beqz	a5,1a2 <strchr+0x20>
    if(*s == c)
 18e:	00f58763          	beq	a1,a5,19c <strchr+0x1a>
  for(; *s; s++)
 192:	0505                	addi	a0,a0,1
 194:	00054783          	lbu	a5,0(a0)
 198:	fbfd                	bnez	a5,18e <strchr+0xc>
      return (char*)s;
  return 0;
 19a:	4501                	li	a0,0
}
 19c:	6422                	ld	s0,8(sp)
 19e:	0141                	addi	sp,sp,16
 1a0:	8082                	ret
  return 0;
 1a2:	4501                	li	a0,0
 1a4:	bfe5                	j	19c <strchr+0x1a>

00000000000001a6 <gets>:

char*
gets(char *buf, int max)
{
 1a6:	711d                	addi	sp,sp,-96
 1a8:	ec86                	sd	ra,88(sp)
 1aa:	e8a2                	sd	s0,80(sp)
 1ac:	e4a6                	sd	s1,72(sp)
 1ae:	e0ca                	sd	s2,64(sp)
 1b0:	fc4e                	sd	s3,56(sp)
 1b2:	f852                	sd	s4,48(sp)
 1b4:	f456                	sd	s5,40(sp)
 1b6:	f05a                	sd	s6,32(sp)
 1b8:	ec5e                	sd	s7,24(sp)
 1ba:	1080                	addi	s0,sp,96
 1bc:	8baa                	mv	s7,a0
 1be:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1c0:	892a                	mv	s2,a0
 1c2:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 1c4:	4aa9                	li	s5,10
 1c6:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 1c8:	89a6                	mv	s3,s1
 1ca:	2485                	addiw	s1,s1,1
 1cc:	0344d863          	bge	s1,s4,1fc <gets+0x56>
    cc = read(0, &c, 1);
 1d0:	4605                	li	a2,1
 1d2:	faf40593          	addi	a1,s0,-81
 1d6:	4501                	li	a0,0
 1d8:	00000097          	auipc	ra,0x0
 1dc:	19a080e7          	jalr	410(ra) # 372 <read>
    if(cc < 1)
 1e0:	00a05e63          	blez	a0,1fc <gets+0x56>
    buf[i++] = c;
 1e4:	faf44783          	lbu	a5,-81(s0)
 1e8:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 1ec:	01578763          	beq	a5,s5,1fa <gets+0x54>
 1f0:	0905                	addi	s2,s2,1
 1f2:	fd679be3          	bne	a5,s6,1c8 <gets+0x22>
  for(i=0; i+1 < max; ){
 1f6:	89a6                	mv	s3,s1
 1f8:	a011                	j	1fc <gets+0x56>
 1fa:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 1fc:	99de                	add	s3,s3,s7
 1fe:	00098023          	sb	zero,0(s3)
  return buf;
}
 202:	855e                	mv	a0,s7
 204:	60e6                	ld	ra,88(sp)
 206:	6446                	ld	s0,80(sp)
 208:	64a6                	ld	s1,72(sp)
 20a:	6906                	ld	s2,64(sp)
 20c:	79e2                	ld	s3,56(sp)
 20e:	7a42                	ld	s4,48(sp)
 210:	7aa2                	ld	s5,40(sp)
 212:	7b02                	ld	s6,32(sp)
 214:	6be2                	ld	s7,24(sp)
 216:	6125                	addi	sp,sp,96
 218:	8082                	ret

000000000000021a <stat>:

int
stat(const char *n, struct stat *st)
{
 21a:	1101                	addi	sp,sp,-32
 21c:	ec06                	sd	ra,24(sp)
 21e:	e822                	sd	s0,16(sp)
 220:	e426                	sd	s1,8(sp)
 222:	e04a                	sd	s2,0(sp)
 224:	1000                	addi	s0,sp,32
 226:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 228:	4581                	li	a1,0
 22a:	00000097          	auipc	ra,0x0
 22e:	170080e7          	jalr	368(ra) # 39a <open>
  if(fd < 0)
 232:	02054563          	bltz	a0,25c <stat+0x42>
 236:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 238:	85ca                	mv	a1,s2
 23a:	00000097          	auipc	ra,0x0
 23e:	178080e7          	jalr	376(ra) # 3b2 <fstat>
 242:	892a                	mv	s2,a0
  close(fd);
 244:	8526                	mv	a0,s1
 246:	00000097          	auipc	ra,0x0
 24a:	13c080e7          	jalr	316(ra) # 382 <close>
  return r;
}
 24e:	854a                	mv	a0,s2
 250:	60e2                	ld	ra,24(sp)
 252:	6442                	ld	s0,16(sp)
 254:	64a2                	ld	s1,8(sp)
 256:	6902                	ld	s2,0(sp)
 258:	6105                	addi	sp,sp,32
 25a:	8082                	ret
    return -1;
 25c:	597d                	li	s2,-1
 25e:	bfc5                	j	24e <stat+0x34>

0000000000000260 <atoi>:

int
atoi(const char *s)
{
 260:	1141                	addi	sp,sp,-16
 262:	e422                	sd	s0,8(sp)
 264:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 266:	00054683          	lbu	a3,0(a0)
 26a:	fd06879b          	addiw	a5,a3,-48
 26e:	0ff7f793          	zext.b	a5,a5
 272:	4625                	li	a2,9
 274:	02f66863          	bltu	a2,a5,2a4 <atoi+0x44>
 278:	872a                	mv	a4,a0
  n = 0;
 27a:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 27c:	0705                	addi	a4,a4,1
 27e:	0025179b          	slliw	a5,a0,0x2
 282:	9fa9                	addw	a5,a5,a0
 284:	0017979b          	slliw	a5,a5,0x1
 288:	9fb5                	addw	a5,a5,a3
 28a:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 28e:	00074683          	lbu	a3,0(a4)
 292:	fd06879b          	addiw	a5,a3,-48
 296:	0ff7f793          	zext.b	a5,a5
 29a:	fef671e3          	bgeu	a2,a5,27c <atoi+0x1c>
  return n;
}
 29e:	6422                	ld	s0,8(sp)
 2a0:	0141                	addi	sp,sp,16
 2a2:	8082                	ret
  n = 0;
 2a4:	4501                	li	a0,0
 2a6:	bfe5                	j	29e <atoi+0x3e>

00000000000002a8 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 2a8:	1141                	addi	sp,sp,-16
 2aa:	e422                	sd	s0,8(sp)
 2ac:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 2ae:	02b57463          	bgeu	a0,a1,2d6 <memmove+0x2e>
    while(n-- > 0)
 2b2:	00c05f63          	blez	a2,2d0 <memmove+0x28>
 2b6:	1602                	slli	a2,a2,0x20
 2b8:	9201                	srli	a2,a2,0x20
 2ba:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 2be:	872a                	mv	a4,a0
      *dst++ = *src++;
 2c0:	0585                	addi	a1,a1,1
 2c2:	0705                	addi	a4,a4,1
 2c4:	fff5c683          	lbu	a3,-1(a1)
 2c8:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 2cc:	fee79ae3          	bne	a5,a4,2c0 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 2d0:	6422                	ld	s0,8(sp)
 2d2:	0141                	addi	sp,sp,16
 2d4:	8082                	ret
    dst += n;
 2d6:	00c50733          	add	a4,a0,a2
    src += n;
 2da:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 2dc:	fec05ae3          	blez	a2,2d0 <memmove+0x28>
 2e0:	fff6079b          	addiw	a5,a2,-1 # 63fff <stacks+0x62fdf>
 2e4:	1782                	slli	a5,a5,0x20
 2e6:	9381                	srli	a5,a5,0x20
 2e8:	fff7c793          	not	a5,a5
 2ec:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 2ee:	15fd                	addi	a1,a1,-1
 2f0:	177d                	addi	a4,a4,-1
 2f2:	0005c683          	lbu	a3,0(a1)
 2f6:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 2fa:	fee79ae3          	bne	a5,a4,2ee <memmove+0x46>
 2fe:	bfc9                	j	2d0 <memmove+0x28>

0000000000000300 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 300:	1141                	addi	sp,sp,-16
 302:	e422                	sd	s0,8(sp)
 304:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 306:	ca05                	beqz	a2,336 <memcmp+0x36>
 308:	fff6069b          	addiw	a3,a2,-1
 30c:	1682                	slli	a3,a3,0x20
 30e:	9281                	srli	a3,a3,0x20
 310:	0685                	addi	a3,a3,1
 312:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 314:	00054783          	lbu	a5,0(a0)
 318:	0005c703          	lbu	a4,0(a1)
 31c:	00e79863          	bne	a5,a4,32c <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 320:	0505                	addi	a0,a0,1
    p2++;
 322:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 324:	fed518e3          	bne	a0,a3,314 <memcmp+0x14>
  }
  return 0;
 328:	4501                	li	a0,0
 32a:	a019                	j	330 <memcmp+0x30>
      return *p1 - *p2;
 32c:	40e7853b          	subw	a0,a5,a4
}
 330:	6422                	ld	s0,8(sp)
 332:	0141                	addi	sp,sp,16
 334:	8082                	ret
  return 0;
 336:	4501                	li	a0,0
 338:	bfe5                	j	330 <memcmp+0x30>

000000000000033a <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 33a:	1141                	addi	sp,sp,-16
 33c:	e406                	sd	ra,8(sp)
 33e:	e022                	sd	s0,0(sp)
 340:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 342:	00000097          	auipc	ra,0x0
 346:	f66080e7          	jalr	-154(ra) # 2a8 <memmove>
}
 34a:	60a2                	ld	ra,8(sp)
 34c:	6402                	ld	s0,0(sp)
 34e:	0141                	addi	sp,sp,16
 350:	8082                	ret

0000000000000352 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 352:	4885                	li	a7,1
 ecall
 354:	00000073          	ecall
 ret
 358:	8082                	ret

000000000000035a <exit>:
.global exit
exit:
 li a7, SYS_exit
 35a:	4889                	li	a7,2
 ecall
 35c:	00000073          	ecall
 ret
 360:	8082                	ret

0000000000000362 <wait>:
.global wait
wait:
 li a7, SYS_wait
 362:	488d                	li	a7,3
 ecall
 364:	00000073          	ecall
 ret
 368:	8082                	ret

000000000000036a <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 36a:	4891                	li	a7,4
 ecall
 36c:	00000073          	ecall
 ret
 370:	8082                	ret

0000000000000372 <read>:
.global read
read:
 li a7, SYS_read
 372:	4895                	li	a7,5
 ecall
 374:	00000073          	ecall
 ret
 378:	8082                	ret

000000000000037a <write>:
.global write
write:
 li a7, SYS_write
 37a:	48c1                	li	a7,16
 ecall
 37c:	00000073          	ecall
 ret
 380:	8082                	ret

0000000000000382 <close>:
.global close
close:
 li a7, SYS_close
 382:	48d5                	li	a7,21
 ecall
 384:	00000073          	ecall
 ret
 388:	8082                	ret

000000000000038a <kill>:
.global kill
kill:
 li a7, SYS_kill
 38a:	4899                	li	a7,6
 ecall
 38c:	00000073          	ecall
 ret
 390:	8082                	ret

0000000000000392 <exec>:
.global exec
exec:
 li a7, SYS_exec
 392:	489d                	li	a7,7
 ecall
 394:	00000073          	ecall
 ret
 398:	8082                	ret

000000000000039a <open>:
.global open
open:
 li a7, SYS_open
 39a:	48bd                	li	a7,15
 ecall
 39c:	00000073          	ecall
 ret
 3a0:	8082                	ret

00000000000003a2 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 3a2:	48c5                	li	a7,17
 ecall
 3a4:	00000073          	ecall
 ret
 3a8:	8082                	ret

00000000000003aa <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 3aa:	48c9                	li	a7,18
 ecall
 3ac:	00000073          	ecall
 ret
 3b0:	8082                	ret

00000000000003b2 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 3b2:	48a1                	li	a7,8
 ecall
 3b4:	00000073          	ecall
 ret
 3b8:	8082                	ret

00000000000003ba <link>:
.global link
link:
 li a7, SYS_link
 3ba:	48cd                	li	a7,19
 ecall
 3bc:	00000073          	ecall
 ret
 3c0:	8082                	ret

00000000000003c2 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 3c2:	48d1                	li	a7,20
 ecall
 3c4:	00000073          	ecall
 ret
 3c8:	8082                	ret

00000000000003ca <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 3ca:	48a5                	li	a7,9
 ecall
 3cc:	00000073          	ecall
 ret
 3d0:	8082                	ret

00000000000003d2 <dup>:
.global dup
dup:
 li a7, SYS_dup
 3d2:	48a9                	li	a7,10
 ecall
 3d4:	00000073          	ecall
 ret
 3d8:	8082                	ret

00000000000003da <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 3da:	48ad                	li	a7,11
 ecall
 3dc:	00000073          	ecall
 ret
 3e0:	8082                	ret

00000000000003e2 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 3e2:	48b1                	li	a7,12
 ecall
 3e4:	00000073          	ecall
 ret
 3e8:	8082                	ret

00000000000003ea <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 3ea:	48b5                	li	a7,13
 ecall
 3ec:	00000073          	ecall
 ret
 3f0:	8082                	ret

00000000000003f2 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 3f2:	48b9                	li	a7,14
 ecall
 3f4:	00000073          	ecall
 ret
 3f8:	8082                	ret

00000000000003fa <ctime>:
.global ctime
ctime:
 li a7, SYS_ctime
 3fa:	48d9                	li	a7,22
 ecall
 3fc:	00000073          	ecall
 ret
 400:	8082                	ret

0000000000000402 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 402:	1101                	addi	sp,sp,-32
 404:	ec06                	sd	ra,24(sp)
 406:	e822                	sd	s0,16(sp)
 408:	1000                	addi	s0,sp,32
 40a:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 40e:	4605                	li	a2,1
 410:	fef40593          	addi	a1,s0,-17
 414:	00000097          	auipc	ra,0x0
 418:	f66080e7          	jalr	-154(ra) # 37a <write>
}
 41c:	60e2                	ld	ra,24(sp)
 41e:	6442                	ld	s0,16(sp)
 420:	6105                	addi	sp,sp,32
 422:	8082                	ret

0000000000000424 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 424:	7139                	addi	sp,sp,-64
 426:	fc06                	sd	ra,56(sp)
 428:	f822                	sd	s0,48(sp)
 42a:	f426                	sd	s1,40(sp)
 42c:	f04a                	sd	s2,32(sp)
 42e:	ec4e                	sd	s3,24(sp)
 430:	0080                	addi	s0,sp,64
 432:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 434:	c299                	beqz	a3,43a <printint+0x16>
 436:	0805c963          	bltz	a1,4c8 <printint+0xa4>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 43a:	2581                	sext.w	a1,a1
  neg = 0;
 43c:	4881                	li	a7,0
 43e:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 442:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 444:	2601                	sext.w	a2,a2
 446:	00001517          	auipc	a0,0x1
 44a:	a5a50513          	addi	a0,a0,-1446 # ea0 <digits>
 44e:	883a                	mv	a6,a4
 450:	2705                	addiw	a4,a4,1
 452:	02c5f7bb          	remuw	a5,a1,a2
 456:	1782                	slli	a5,a5,0x20
 458:	9381                	srli	a5,a5,0x20
 45a:	97aa                	add	a5,a5,a0
 45c:	0007c783          	lbu	a5,0(a5)
 460:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 464:	0005879b          	sext.w	a5,a1
 468:	02c5d5bb          	divuw	a1,a1,a2
 46c:	0685                	addi	a3,a3,1
 46e:	fec7f0e3          	bgeu	a5,a2,44e <printint+0x2a>
  if(neg)
 472:	00088c63          	beqz	a7,48a <printint+0x66>
    buf[i++] = '-';
 476:	fd070793          	addi	a5,a4,-48
 47a:	00878733          	add	a4,a5,s0
 47e:	02d00793          	li	a5,45
 482:	fef70823          	sb	a5,-16(a4)
 486:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 48a:	02e05863          	blez	a4,4ba <printint+0x96>
 48e:	fc040793          	addi	a5,s0,-64
 492:	00e78933          	add	s2,a5,a4
 496:	fff78993          	addi	s3,a5,-1
 49a:	99ba                	add	s3,s3,a4
 49c:	377d                	addiw	a4,a4,-1
 49e:	1702                	slli	a4,a4,0x20
 4a0:	9301                	srli	a4,a4,0x20
 4a2:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 4a6:	fff94583          	lbu	a1,-1(s2)
 4aa:	8526                	mv	a0,s1
 4ac:	00000097          	auipc	ra,0x0
 4b0:	f56080e7          	jalr	-170(ra) # 402 <putc>
  while(--i >= 0)
 4b4:	197d                	addi	s2,s2,-1
 4b6:	ff3918e3          	bne	s2,s3,4a6 <printint+0x82>
}
 4ba:	70e2                	ld	ra,56(sp)
 4bc:	7442                	ld	s0,48(sp)
 4be:	74a2                	ld	s1,40(sp)
 4c0:	7902                	ld	s2,32(sp)
 4c2:	69e2                	ld	s3,24(sp)
 4c4:	6121                	addi	sp,sp,64
 4c6:	8082                	ret
    x = -xx;
 4c8:	40b005bb          	negw	a1,a1
    neg = 1;
 4cc:	4885                	li	a7,1
    x = -xx;
 4ce:	bf85                	j	43e <printint+0x1a>

00000000000004d0 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 4d0:	715d                	addi	sp,sp,-80
 4d2:	e486                	sd	ra,72(sp)
 4d4:	e0a2                	sd	s0,64(sp)
 4d6:	fc26                	sd	s1,56(sp)
 4d8:	f84a                	sd	s2,48(sp)
 4da:	f44e                	sd	s3,40(sp)
 4dc:	f052                	sd	s4,32(sp)
 4de:	ec56                	sd	s5,24(sp)
 4e0:	e85a                	sd	s6,16(sp)
 4e2:	e45e                	sd	s7,8(sp)
 4e4:	e062                	sd	s8,0(sp)
 4e6:	0880                	addi	s0,sp,80
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 4e8:	0005c903          	lbu	s2,0(a1)
 4ec:	18090c63          	beqz	s2,684 <vprintf+0x1b4>
 4f0:	8aaa                	mv	s5,a0
 4f2:	8bb2                	mv	s7,a2
 4f4:	00158493          	addi	s1,a1,1
  state = 0;
 4f8:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 4fa:	02500a13          	li	s4,37
 4fe:	4b55                	li	s6,21
 500:	a839                	j	51e <vprintf+0x4e>
        putc(fd, c);
 502:	85ca                	mv	a1,s2
 504:	8556                	mv	a0,s5
 506:	00000097          	auipc	ra,0x0
 50a:	efc080e7          	jalr	-260(ra) # 402 <putc>
 50e:	a019                	j	514 <vprintf+0x44>
    } else if(state == '%'){
 510:	01498d63          	beq	s3,s4,52a <vprintf+0x5a>
  for(i = 0; fmt[i]; i++){
 514:	0485                	addi	s1,s1,1
 516:	fff4c903          	lbu	s2,-1(s1)
 51a:	16090563          	beqz	s2,684 <vprintf+0x1b4>
    if(state == 0){
 51e:	fe0999e3          	bnez	s3,510 <vprintf+0x40>
      if(c == '%'){
 522:	ff4910e3          	bne	s2,s4,502 <vprintf+0x32>
        state = '%';
 526:	89d2                	mv	s3,s4
 528:	b7f5                	j	514 <vprintf+0x44>
      if(c == 'd'){
 52a:	13490263          	beq	s2,s4,64e <vprintf+0x17e>
 52e:	f9d9079b          	addiw	a5,s2,-99
 532:	0ff7f793          	zext.b	a5,a5
 536:	12fb6563          	bltu	s6,a5,660 <vprintf+0x190>
 53a:	f9d9079b          	addiw	a5,s2,-99
 53e:	0ff7f713          	zext.b	a4,a5
 542:	10eb6f63          	bltu	s6,a4,660 <vprintf+0x190>
 546:	00271793          	slli	a5,a4,0x2
 54a:	00001717          	auipc	a4,0x1
 54e:	8fe70713          	addi	a4,a4,-1794 # e48 <ulthread_context_switch+0x100>
 552:	97ba                	add	a5,a5,a4
 554:	439c                	lw	a5,0(a5)
 556:	97ba                	add	a5,a5,a4
 558:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
 55a:	008b8913          	addi	s2,s7,8
 55e:	4685                	li	a3,1
 560:	4629                	li	a2,10
 562:	000ba583          	lw	a1,0(s7)
 566:	8556                	mv	a0,s5
 568:	00000097          	auipc	ra,0x0
 56c:	ebc080e7          	jalr	-324(ra) # 424 <printint>
 570:	8bca                	mv	s7,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 572:	4981                	li	s3,0
 574:	b745                	j	514 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 576:	008b8913          	addi	s2,s7,8
 57a:	4681                	li	a3,0
 57c:	4629                	li	a2,10
 57e:	000ba583          	lw	a1,0(s7)
 582:	8556                	mv	a0,s5
 584:	00000097          	auipc	ra,0x0
 588:	ea0080e7          	jalr	-352(ra) # 424 <printint>
 58c:	8bca                	mv	s7,s2
      state = 0;
 58e:	4981                	li	s3,0
 590:	b751                	j	514 <vprintf+0x44>
        printint(fd, va_arg(ap, int), 16, 0);
 592:	008b8913          	addi	s2,s7,8
 596:	4681                	li	a3,0
 598:	4641                	li	a2,16
 59a:	000ba583          	lw	a1,0(s7)
 59e:	8556                	mv	a0,s5
 5a0:	00000097          	auipc	ra,0x0
 5a4:	e84080e7          	jalr	-380(ra) # 424 <printint>
 5a8:	8bca                	mv	s7,s2
      state = 0;
 5aa:	4981                	li	s3,0
 5ac:	b7a5                	j	514 <vprintf+0x44>
        printptr(fd, va_arg(ap, uint64));
 5ae:	008b8c13          	addi	s8,s7,8
 5b2:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 5b6:	03000593          	li	a1,48
 5ba:	8556                	mv	a0,s5
 5bc:	00000097          	auipc	ra,0x0
 5c0:	e46080e7          	jalr	-442(ra) # 402 <putc>
  putc(fd, 'x');
 5c4:	07800593          	li	a1,120
 5c8:	8556                	mv	a0,s5
 5ca:	00000097          	auipc	ra,0x0
 5ce:	e38080e7          	jalr	-456(ra) # 402 <putc>
 5d2:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 5d4:	00001b97          	auipc	s7,0x1
 5d8:	8ccb8b93          	addi	s7,s7,-1844 # ea0 <digits>
 5dc:	03c9d793          	srli	a5,s3,0x3c
 5e0:	97de                	add	a5,a5,s7
 5e2:	0007c583          	lbu	a1,0(a5)
 5e6:	8556                	mv	a0,s5
 5e8:	00000097          	auipc	ra,0x0
 5ec:	e1a080e7          	jalr	-486(ra) # 402 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 5f0:	0992                	slli	s3,s3,0x4
 5f2:	397d                	addiw	s2,s2,-1
 5f4:	fe0914e3          	bnez	s2,5dc <vprintf+0x10c>
        printptr(fd, va_arg(ap, uint64));
 5f8:	8be2                	mv	s7,s8
      state = 0;
 5fa:	4981                	li	s3,0
 5fc:	bf21                	j	514 <vprintf+0x44>
        s = va_arg(ap, char*);
 5fe:	008b8993          	addi	s3,s7,8
 602:	000bb903          	ld	s2,0(s7)
        if(s == 0)
 606:	02090163          	beqz	s2,628 <vprintf+0x158>
        while(*s != 0){
 60a:	00094583          	lbu	a1,0(s2)
 60e:	c9a5                	beqz	a1,67e <vprintf+0x1ae>
          putc(fd, *s);
 610:	8556                	mv	a0,s5
 612:	00000097          	auipc	ra,0x0
 616:	df0080e7          	jalr	-528(ra) # 402 <putc>
          s++;
 61a:	0905                	addi	s2,s2,1
        while(*s != 0){
 61c:	00094583          	lbu	a1,0(s2)
 620:	f9e5                	bnez	a1,610 <vprintf+0x140>
        s = va_arg(ap, char*);
 622:	8bce                	mv	s7,s3
      state = 0;
 624:	4981                	li	s3,0
 626:	b5fd                	j	514 <vprintf+0x44>
          s = "(null)";
 628:	00001917          	auipc	s2,0x1
 62c:	81890913          	addi	s2,s2,-2024 # e40 <ulthread_context_switch+0xf8>
        while(*s != 0){
 630:	02800593          	li	a1,40
 634:	bff1                	j	610 <vprintf+0x140>
        putc(fd, va_arg(ap, uint));
 636:	008b8913          	addi	s2,s7,8
 63a:	000bc583          	lbu	a1,0(s7)
 63e:	8556                	mv	a0,s5
 640:	00000097          	auipc	ra,0x0
 644:	dc2080e7          	jalr	-574(ra) # 402 <putc>
 648:	8bca                	mv	s7,s2
      state = 0;
 64a:	4981                	li	s3,0
 64c:	b5e1                	j	514 <vprintf+0x44>
        putc(fd, c);
 64e:	02500593          	li	a1,37
 652:	8556                	mv	a0,s5
 654:	00000097          	auipc	ra,0x0
 658:	dae080e7          	jalr	-594(ra) # 402 <putc>
      state = 0;
 65c:	4981                	li	s3,0
 65e:	bd5d                	j	514 <vprintf+0x44>
        putc(fd, '%');
 660:	02500593          	li	a1,37
 664:	8556                	mv	a0,s5
 666:	00000097          	auipc	ra,0x0
 66a:	d9c080e7          	jalr	-612(ra) # 402 <putc>
        putc(fd, c);
 66e:	85ca                	mv	a1,s2
 670:	8556                	mv	a0,s5
 672:	00000097          	auipc	ra,0x0
 676:	d90080e7          	jalr	-624(ra) # 402 <putc>
      state = 0;
 67a:	4981                	li	s3,0
 67c:	bd61                	j	514 <vprintf+0x44>
        s = va_arg(ap, char*);
 67e:	8bce                	mv	s7,s3
      state = 0;
 680:	4981                	li	s3,0
 682:	bd49                	j	514 <vprintf+0x44>
    }
  }
}
 684:	60a6                	ld	ra,72(sp)
 686:	6406                	ld	s0,64(sp)
 688:	74e2                	ld	s1,56(sp)
 68a:	7942                	ld	s2,48(sp)
 68c:	79a2                	ld	s3,40(sp)
 68e:	7a02                	ld	s4,32(sp)
 690:	6ae2                	ld	s5,24(sp)
 692:	6b42                	ld	s6,16(sp)
 694:	6ba2                	ld	s7,8(sp)
 696:	6c02                	ld	s8,0(sp)
 698:	6161                	addi	sp,sp,80
 69a:	8082                	ret

000000000000069c <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 69c:	715d                	addi	sp,sp,-80
 69e:	ec06                	sd	ra,24(sp)
 6a0:	e822                	sd	s0,16(sp)
 6a2:	1000                	addi	s0,sp,32
 6a4:	e010                	sd	a2,0(s0)
 6a6:	e414                	sd	a3,8(s0)
 6a8:	e818                	sd	a4,16(s0)
 6aa:	ec1c                	sd	a5,24(s0)
 6ac:	03043023          	sd	a6,32(s0)
 6b0:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 6b4:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 6b8:	8622                	mv	a2,s0
 6ba:	00000097          	auipc	ra,0x0
 6be:	e16080e7          	jalr	-490(ra) # 4d0 <vprintf>
}
 6c2:	60e2                	ld	ra,24(sp)
 6c4:	6442                	ld	s0,16(sp)
 6c6:	6161                	addi	sp,sp,80
 6c8:	8082                	ret

00000000000006ca <printf>:

void
printf(const char *fmt, ...)
{
 6ca:	711d                	addi	sp,sp,-96
 6cc:	ec06                	sd	ra,24(sp)
 6ce:	e822                	sd	s0,16(sp)
 6d0:	1000                	addi	s0,sp,32
 6d2:	e40c                	sd	a1,8(s0)
 6d4:	e810                	sd	a2,16(s0)
 6d6:	ec14                	sd	a3,24(s0)
 6d8:	f018                	sd	a4,32(s0)
 6da:	f41c                	sd	a5,40(s0)
 6dc:	03043823          	sd	a6,48(s0)
 6e0:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 6e4:	00840613          	addi	a2,s0,8
 6e8:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 6ec:	85aa                	mv	a1,a0
 6ee:	4505                	li	a0,1
 6f0:	00000097          	auipc	ra,0x0
 6f4:	de0080e7          	jalr	-544(ra) # 4d0 <vprintf>
}
 6f8:	60e2                	ld	ra,24(sp)
 6fa:	6442                	ld	s0,16(sp)
 6fc:	6125                	addi	sp,sp,96
 6fe:	8082                	ret

0000000000000700 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 700:	1141                	addi	sp,sp,-16
 702:	e422                	sd	s0,8(sp)
 704:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 706:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 70a:	00001797          	auipc	a5,0x1
 70e:	8f67b783          	ld	a5,-1802(a5) # 1000 <freep>
 712:	a02d                	j	73c <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 714:	4618                	lw	a4,8(a2)
 716:	9f2d                	addw	a4,a4,a1
 718:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 71c:	6398                	ld	a4,0(a5)
 71e:	6310                	ld	a2,0(a4)
 720:	a83d                	j	75e <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 722:	ff852703          	lw	a4,-8(a0)
 726:	9f31                	addw	a4,a4,a2
 728:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 72a:	ff053683          	ld	a3,-16(a0)
 72e:	a091                	j	772 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 730:	6398                	ld	a4,0(a5)
 732:	00e7e463          	bltu	a5,a4,73a <free+0x3a>
 736:	00e6ea63          	bltu	a3,a4,74a <free+0x4a>
{
 73a:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 73c:	fed7fae3          	bgeu	a5,a3,730 <free+0x30>
 740:	6398                	ld	a4,0(a5)
 742:	00e6e463          	bltu	a3,a4,74a <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 746:	fee7eae3          	bltu	a5,a4,73a <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 74a:	ff852583          	lw	a1,-8(a0)
 74e:	6390                	ld	a2,0(a5)
 750:	02059813          	slli	a6,a1,0x20
 754:	01c85713          	srli	a4,a6,0x1c
 758:	9736                	add	a4,a4,a3
 75a:	fae60de3          	beq	a2,a4,714 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 75e:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 762:	4790                	lw	a2,8(a5)
 764:	02061593          	slli	a1,a2,0x20
 768:	01c5d713          	srli	a4,a1,0x1c
 76c:	973e                	add	a4,a4,a5
 76e:	fae68ae3          	beq	a3,a4,722 <free+0x22>
    p->s.ptr = bp->s.ptr;
 772:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 774:	00001717          	auipc	a4,0x1
 778:	88f73623          	sd	a5,-1908(a4) # 1000 <freep>
}
 77c:	6422                	ld	s0,8(sp)
 77e:	0141                	addi	sp,sp,16
 780:	8082                	ret

0000000000000782 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 782:	7139                	addi	sp,sp,-64
 784:	fc06                	sd	ra,56(sp)
 786:	f822                	sd	s0,48(sp)
 788:	f426                	sd	s1,40(sp)
 78a:	f04a                	sd	s2,32(sp)
 78c:	ec4e                	sd	s3,24(sp)
 78e:	e852                	sd	s4,16(sp)
 790:	e456                	sd	s5,8(sp)
 792:	e05a                	sd	s6,0(sp)
 794:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 796:	02051493          	slli	s1,a0,0x20
 79a:	9081                	srli	s1,s1,0x20
 79c:	04bd                	addi	s1,s1,15
 79e:	8091                	srli	s1,s1,0x4
 7a0:	0014899b          	addiw	s3,s1,1
 7a4:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 7a6:	00001517          	auipc	a0,0x1
 7aa:	85a53503          	ld	a0,-1958(a0) # 1000 <freep>
 7ae:	c515                	beqz	a0,7da <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 7b0:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 7b2:	4798                	lw	a4,8(a5)
 7b4:	02977f63          	bgeu	a4,s1,7f2 <malloc+0x70>
  if(nu < 4096)
 7b8:	8a4e                	mv	s4,s3
 7ba:	0009871b          	sext.w	a4,s3
 7be:	6685                	lui	a3,0x1
 7c0:	00d77363          	bgeu	a4,a3,7c6 <malloc+0x44>
 7c4:	6a05                	lui	s4,0x1
 7c6:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 7ca:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 7ce:	00001917          	auipc	s2,0x1
 7d2:	83290913          	addi	s2,s2,-1998 # 1000 <freep>
  if(p == (char*)-1)
 7d6:	5afd                	li	s5,-1
 7d8:	a895                	j	84c <malloc+0xca>
    base.s.ptr = freep = prevp = &base;
 7da:	00065797          	auipc	a5,0x65
 7de:	84678793          	addi	a5,a5,-1978 # 65020 <base>
 7e2:	00001717          	auipc	a4,0x1
 7e6:	80f73f23          	sd	a5,-2018(a4) # 1000 <freep>
 7ea:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 7ec:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 7f0:	b7e1                	j	7b8 <malloc+0x36>
      if(p->s.size == nunits)
 7f2:	02e48c63          	beq	s1,a4,82a <malloc+0xa8>
        p->s.size -= nunits;
 7f6:	4137073b          	subw	a4,a4,s3
 7fa:	c798                	sw	a4,8(a5)
        p += p->s.size;
 7fc:	02071693          	slli	a3,a4,0x20
 800:	01c6d713          	srli	a4,a3,0x1c
 804:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 806:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 80a:	00000717          	auipc	a4,0x0
 80e:	7ea73b23          	sd	a0,2038(a4) # 1000 <freep>
      return (void*)(p + 1);
 812:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 816:	70e2                	ld	ra,56(sp)
 818:	7442                	ld	s0,48(sp)
 81a:	74a2                	ld	s1,40(sp)
 81c:	7902                	ld	s2,32(sp)
 81e:	69e2                	ld	s3,24(sp)
 820:	6a42                	ld	s4,16(sp)
 822:	6aa2                	ld	s5,8(sp)
 824:	6b02                	ld	s6,0(sp)
 826:	6121                	addi	sp,sp,64
 828:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 82a:	6398                	ld	a4,0(a5)
 82c:	e118                	sd	a4,0(a0)
 82e:	bff1                	j	80a <malloc+0x88>
  hp->s.size = nu;
 830:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 834:	0541                	addi	a0,a0,16
 836:	00000097          	auipc	ra,0x0
 83a:	eca080e7          	jalr	-310(ra) # 700 <free>
  return freep;
 83e:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 842:	d971                	beqz	a0,816 <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 844:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 846:	4798                	lw	a4,8(a5)
 848:	fa9775e3          	bgeu	a4,s1,7f2 <malloc+0x70>
    if(p == freep)
 84c:	00093703          	ld	a4,0(s2)
 850:	853e                	mv	a0,a5
 852:	fef719e3          	bne	a4,a5,844 <malloc+0xc2>
  p = sbrk(nu * sizeof(Header));
 856:	8552                	mv	a0,s4
 858:	00000097          	auipc	ra,0x0
 85c:	b8a080e7          	jalr	-1142(ra) # 3e2 <sbrk>
  if(p == (char*)-1)
 860:	fd5518e3          	bne	a0,s5,830 <malloc+0xae>
        return 0;
 864:	4501                	li	a0,0
 866:	bf45                	j	816 <malloc+0x94>

0000000000000868 <get_current_tid>:
struct ulthread *scheduler_thread;
enum ulthread_scheduling_algorithm algorithm;

/* Get thread ID */
int get_current_tid(void)
{
 868:	1141                	addi	sp,sp,-16
 86a:	e422                	sd	s0,8(sp)
 86c:	0800                	addi	s0,sp,16
  return current_thread->tid;
}
 86e:	00000797          	auipc	a5,0x0
 872:	7aa7b783          	ld	a5,1962(a5) # 1018 <current_thread>
 876:	43c8                	lw	a0,4(a5)
 878:	6422                	ld	s0,8(sp)
 87a:	0141                	addi	sp,sp,16
 87c:	8082                	ret

000000000000087e <roundRobin>:

void roundRobin(void)
{
 87e:	715d                	addi	sp,sp,-80
 880:	e486                	sd	ra,72(sp)
 882:	e0a2                	sd	s0,64(sp)
 884:	fc26                	sd	s1,56(sp)
 886:	f84a                	sd	s2,48(sp)
 888:	f44e                	sd	s3,40(sp)
 88a:	f052                	sd	s4,32(sp)
 88c:	ec56                	sd	s5,24(sp)
 88e:	e85a                	sd	s6,16(sp)
 890:	e45e                	sd	s7,8(sp)
 892:	e062                	sd	s8,0(sp)
 894:	0880                	addi	s0,sp,80
        struct ulthread *temp = current_thread;
        current_thread = t;
        printf("[*] ultschedule (next tid: %d)\n", get_current_tid());
        ulthread_context_switch(&temp->context, &t->context);
      }
      if (t->state == YIELD)
 896:	4a09                	li	s4,2
      if (t->state == RUNNABLE && t != scheduler_thread)
 898:	00000b97          	auipc	s7,0x0
 89c:	778b8b93          	addi	s7,s7,1912 # 1010 <scheduler_thread>
        struct ulthread *temp = current_thread;
 8a0:	00000a97          	auipc	s5,0x0
 8a4:	778a8a93          	addi	s5,s5,1912 # 1018 <current_thread>
        printf("[*] ultschedule (next tid: %d)\n", get_current_tid());
 8a8:	00000c17          	auipc	s8,0x0
 8ac:	610c0c13          	addi	s8,s8,1552 # eb8 <digits+0x18>
    for (t = ulthreads; t < &ulthreads[MAXULTHREADS]; t++)
 8b0:	00068997          	auipc	s3,0x68
 8b4:	ca098993          	addi	s3,s3,-864 # 68550 <ulthreads+0x3520>
 8b8:	a0b9                	j	906 <roundRobin+0x88>
      if (t->state == RUNNABLE && t != scheduler_thread)
 8ba:	000bb783          	ld	a5,0(s7)
 8be:	02978863          	beq	a5,s1,8ee <roundRobin+0x70>
        struct ulthread *temp = current_thread;
 8c2:	000abb03          	ld	s6,0(s5)
        current_thread = t;
 8c6:	009ab023          	sd	s1,0(s5)
        printf("[*] ultschedule (next tid: %d)\n", get_current_tid());
 8ca:	40cc                	lw	a1,4(s1)
 8cc:	8562                	mv	a0,s8
 8ce:	00000097          	auipc	ra,0x0
 8d2:	dfc080e7          	jalr	-516(ra) # 6ca <printf>
        ulthread_context_switch(&temp->context, &t->context);
 8d6:	01848593          	addi	a1,s1,24
 8da:	018b0513          	addi	a0,s6,24
 8de:	00000097          	auipc	ra,0x0
 8e2:	46a080e7          	jalr	1130(ra) # d48 <ulthread_context_switch>
        threadAvailable = true;
 8e6:	874a                	mv	a4,s2
 8e8:	a811                	j	8fc <roundRobin+0x7e>
      {
        t->state = RUNNABLE;
 8ea:	0124a023          	sw	s2,0(s1)
    for (t = ulthreads; t < &ulthreads[MAXULTHREADS]; t++)
 8ee:	08848493          	addi	s1,s1,136
 8f2:	01348963          	beq	s1,s3,904 <roundRobin+0x86>
      if (t->state == RUNNABLE && t != scheduler_thread)
 8f6:	409c                	lw	a5,0(s1)
 8f8:	fd2781e3          	beq	a5,s2,8ba <roundRobin+0x3c>
      if (t->state == YIELD)
 8fc:	409c                	lw	a5,0(s1)
 8fe:	ff4798e3          	bne	a5,s4,8ee <roundRobin+0x70>
 902:	b7e5                	j	8ea <roundRobin+0x6c>
      }
    }
    if (!threadAvailable)
 904:	cb01                	beqz	a4,914 <roundRobin+0x96>
    bool threadAvailable = false;
 906:	4701                	li	a4,0
    for (t = ulthreads; t < &ulthreads[MAXULTHREADS]; t++)
 908:	00064497          	auipc	s1,0x64
 90c:	72848493          	addi	s1,s1,1832 # 65030 <ulthreads>
      if (t->state == RUNNABLE && t != scheduler_thread)
 910:	4905                	li	s2,1
 912:	b7d5                	j	8f6 <roundRobin+0x78>
    {
      break;
    }
  }
}
 914:	60a6                	ld	ra,72(sp)
 916:	6406                	ld	s0,64(sp)
 918:	74e2                	ld	s1,56(sp)
 91a:	7942                	ld	s2,48(sp)
 91c:	79a2                	ld	s3,40(sp)
 91e:	7a02                	ld	s4,32(sp)
 920:	6ae2                	ld	s5,24(sp)
 922:	6b42                	ld	s6,16(sp)
 924:	6ba2                	ld	s7,8(sp)
 926:	6c02                	ld	s8,0(sp)
 928:	6161                	addi	sp,sp,80
 92a:	8082                	ret

000000000000092c <firstComeFirstServe>:

void firstComeFirstServe(void)
{
 92c:	715d                	addi	sp,sp,-80
 92e:	e486                	sd	ra,72(sp)
 930:	e0a2                	sd	s0,64(sp)
 932:	fc26                	sd	s1,56(sp)
 934:	f84a                	sd	s2,48(sp)
 936:	f44e                	sd	s3,40(sp)
 938:	f052                	sd	s4,32(sp)
 93a:	ec56                	sd	s5,24(sp)
 93c:	e85a                	sd	s6,16(sp)
 93e:	e45e                	sd	s7,8(sp)
 940:	e062                	sd	s8,0(sp)
 942:	0880                	addi	s0,sp,80
    uint64 oldest = __INT64_MAX__;
    int threadIndex = -1;
    int alternativeIndex = -1;
    for (t = ulthreads+1; t < &ulthreads[MAXULTHREADS]; t++)
    {
      if (t->state == RUNNABLE && t != scheduler_thread && t->lastTime < oldest)
 944:	00000b97          	auipc	s7,0x0
 948:	6ccb8b93          	addi	s7,s7,1740 # 1010 <scheduler_thread>
    int alternativeIndex = -1;
 94c:	5afd                	li	s5,-1
    uint64 oldest = __INT64_MAX__;
 94e:	001adb13          	srli	s6,s5,0x1
      if (t->state == RUNNABLE && t != scheduler_thread && t->lastTime < oldest)
 952:	4485                	li	s1,1
        oldest = t->lastTime;
        threadIndex = t->tid;
        threadAvailable = true;
      }

      if (t->state == YIELD){
 954:	4989                	li	s3,2
    for (t = ulthreads+1; t < &ulthreads[MAXULTHREADS]; t++)
 956:	00068917          	auipc	s2,0x68
 95a:	bfa90913          	addi	s2,s2,-1030 # 68550 <ulthreads+0x3520>
        break;
      }
      
    }
    label : 
      struct ulthread *temp = current_thread;
 95e:	00000a17          	auipc	s4,0x0
 962:	6baa0a13          	addi	s4,s4,1722 # 1018 <current_thread>
 966:	a88d                	j	9d8 <firstComeFirstServe+0xac>
      if (t->state == RUNNABLE && t != scheduler_thread && t->lastTime < oldest)
 968:	00f58963          	beq	a1,a5,97a <firstComeFirstServe+0x4e>
 96c:	6b98                	ld	a4,16(a5)
 96e:	00c77663          	bgeu	a4,a2,97a <firstComeFirstServe+0x4e>
        threadIndex = t->tid;
 972:	0047a803          	lw	a6,4(a5)
        oldest = t->lastTime;
 976:	863a                	mv	a2,a4
        threadAvailable = true;
 978:	8526                	mv	a0,s1
    for (t = ulthreads+1; t < &ulthreads[MAXULTHREADS]; t++)
 97a:	08878793          	addi	a5,a5,136
 97e:	01278a63          	beq	a5,s2,992 <firstComeFirstServe+0x66>
      if (t->state == RUNNABLE && t != scheduler_thread && t->lastTime < oldest)
 982:	4398                	lw	a4,0(a5)
 984:	fe9702e3          	beq	a4,s1,968 <firstComeFirstServe+0x3c>
      if (t->state == YIELD){
 988:	ff3719e3          	bne	a4,s3,97a <firstComeFirstServe+0x4e>
        t->state = RUNNABLE;
 98c:	c384                	sw	s1,0(a5)
        alternativeIndex = t->tid;
 98e:	43d4                	lw	a3,4(a5)
 990:	b7ed                	j	97a <firstComeFirstServe+0x4e>
    if (!threadAvailable)
 992:	ed31                	bnez	a0,9ee <firstComeFirstServe+0xc2>
      if(alternativeIndex > 0){
 994:	04d05f63          	blez	a3,9f2 <firstComeFirstServe+0xc6>
      struct ulthread *temp = current_thread;
 998:	000a3c03          	ld	s8,0(s4)
      current_thread = &ulthreads[threadIndex];
 99c:	00469793          	slli	a5,a3,0x4
 9a0:	00d78733          	add	a4,a5,a3
 9a4:	070e                	slli	a4,a4,0x3
 9a6:	00064617          	auipc	a2,0x64
 9aa:	68a60613          	addi	a2,a2,1674 # 65030 <ulthreads>
 9ae:	9732                	add	a4,a4,a2
 9b0:	00ea3023          	sd	a4,0(s4)
      printf("[*] ultschedule (next tid: %d), time = %d\n", get_current_tid());
 9b4:	434c                	lw	a1,4(a4)
 9b6:	00000517          	auipc	a0,0x0
 9ba:	52250513          	addi	a0,a0,1314 # ed8 <digits+0x38>
 9be:	00000097          	auipc	ra,0x0
 9c2:	d0c080e7          	jalr	-756(ra) # 6ca <printf>
      ulthread_context_switch(&temp->context, &current_thread->context);
 9c6:	000a3583          	ld	a1,0(s4)
 9ca:	05e1                	addi	a1,a1,24
 9cc:	018c0513          	addi	a0,s8,24
 9d0:	00000097          	auipc	ra,0x0
 9d4:	378080e7          	jalr	888(ra) # d48 <ulthread_context_switch>
      if (t->state == RUNNABLE && t != scheduler_thread && t->lastTime < oldest)
 9d8:	000bb583          	ld	a1,0(s7)
    int alternativeIndex = -1;
 9dc:	86d6                	mv	a3,s5
    int threadIndex = -1;
 9de:	8856                	mv	a6,s5
    uint64 oldest = __INT64_MAX__;
 9e0:	865a                	mv	a2,s6
    bool threadAvailable = false;
 9e2:	4501                	li	a0,0
    for (t = ulthreads+1; t < &ulthreads[MAXULTHREADS]; t++)
 9e4:	00064797          	auipc	a5,0x64
 9e8:	6d478793          	addi	a5,a5,1748 # 650b8 <ulthreads+0x88>
 9ec:	bf59                	j	982 <firstComeFirstServe+0x56>
    label : 
 9ee:	86c2                	mv	a3,a6
 9f0:	b765                	j	998 <firstComeFirstServe+0x6c>
  }
}
 9f2:	60a6                	ld	ra,72(sp)
 9f4:	6406                	ld	s0,64(sp)
 9f6:	74e2                	ld	s1,56(sp)
 9f8:	7942                	ld	s2,48(sp)
 9fa:	79a2                	ld	s3,40(sp)
 9fc:	7a02                	ld	s4,32(sp)
 9fe:	6ae2                	ld	s5,24(sp)
 a00:	6b42                	ld	s6,16(sp)
 a02:	6ba2                	ld	s7,8(sp)
 a04:	6c02                	ld	s8,0(sp)
 a06:	6161                	addi	sp,sp,80
 a08:	8082                	ret

0000000000000a0a <priorityScheduling>:


void priorityScheduling(void)
{
 a0a:	715d                	addi	sp,sp,-80
 a0c:	e486                	sd	ra,72(sp)
 a0e:	e0a2                	sd	s0,64(sp)
 a10:	fc26                	sd	s1,56(sp)
 a12:	f84a                	sd	s2,48(sp)
 a14:	f44e                	sd	s3,40(sp)
 a16:	f052                	sd	s4,32(sp)
 a18:	ec56                	sd	s5,24(sp)
 a1a:	e85a                	sd	s6,16(sp)
 a1c:	e45e                	sd	s7,8(sp)
 a1e:	0880                	addi	s0,sp,80
    int maxPriority = -1;
    int threadIndex = -1;
    int alternativeIndex = -1;
    for (t = ulthreads+1; t < &ulthreads[MAXULTHREADS]; t++)
    {
      if (t->state == RUNNABLE && t != scheduler_thread && t->priority > maxPriority)
 a20:	00000b17          	auipc	s6,0x0
 a24:	5f0b0b13          	addi	s6,s6,1520 # 1010 <scheduler_thread>
    int alternativeIndex = -1;
 a28:	5a7d                	li	s4,-1
      if (t->state == RUNNABLE && t != scheduler_thread && t->priority > maxPriority)
 a2a:	4485                	li	s1,1
        // flag = true;

        // break; // switch to highest-priority thread and exit loop
      }

      if (t->state == YIELD){
 a2c:	4989                	li	s3,2
    for (t = ulthreads+1; t < &ulthreads[MAXULTHREADS]; t++)
 a2e:	00068917          	auipc	s2,0x68
 a32:	b2290913          	addi	s2,s2,-1246 # 68550 <ulthreads+0x3520>
        break;
      }
      
    }
    label : 
      struct ulthread *temp = current_thread;
 a36:	00000a97          	auipc	s5,0x0
 a3a:	5e2a8a93          	addi	s5,s5,1506 # 1018 <current_thread>
 a3e:	a88d                	j	ab0 <priorityScheduling+0xa6>
      if (t->state == RUNNABLE && t != scheduler_thread && t->priority > maxPriority)
 a40:	00f58963          	beq	a1,a5,a52 <priorityScheduling+0x48>
 a44:	47d8                	lw	a4,12(a5)
 a46:	00e65663          	bge	a2,a4,a52 <priorityScheduling+0x48>
        threadIndex = t->tid;
 a4a:	0047a803          	lw	a6,4(a5)
        maxPriority = t->priority;
 a4e:	863a                	mv	a2,a4
        threadAvailable = true;
 a50:	8526                	mv	a0,s1
    for (t = ulthreads+1; t < &ulthreads[MAXULTHREADS]; t++)
 a52:	08878793          	addi	a5,a5,136
 a56:	01278a63          	beq	a5,s2,a6a <priorityScheduling+0x60>
      if (t->state == RUNNABLE && t != scheduler_thread && t->priority > maxPriority)
 a5a:	4398                	lw	a4,0(a5)
 a5c:	fe9702e3          	beq	a4,s1,a40 <priorityScheduling+0x36>
      if (t->state == YIELD){
 a60:	ff3719e3          	bne	a4,s3,a52 <priorityScheduling+0x48>
        t->state = RUNNABLE;
 a64:	c384                	sw	s1,0(a5)
        alternativeIndex = t->tid;
 a66:	43d4                	lw	a3,4(a5)
 a68:	b7ed                	j	a52 <priorityScheduling+0x48>
    if (!threadAvailable)
 a6a:	ed31                	bnez	a0,ac6 <priorityScheduling+0xbc>
      if(alternativeIndex > 0){
 a6c:	04d05f63          	blez	a3,aca <priorityScheduling+0xc0>
      struct ulthread *temp = current_thread;
 a70:	000abb83          	ld	s7,0(s5)
      current_thread = &ulthreads[threadIndex];
 a74:	00469793          	slli	a5,a3,0x4
 a78:	00d78733          	add	a4,a5,a3
 a7c:	070e                	slli	a4,a4,0x3
 a7e:	00064617          	auipc	a2,0x64
 a82:	5b260613          	addi	a2,a2,1458 # 65030 <ulthreads>
 a86:	9732                	add	a4,a4,a2
 a88:	00eab023          	sd	a4,0(s5)
      printf("[*] ultschedule (next tid: %d)\n", get_current_tid());
 a8c:	434c                	lw	a1,4(a4)
 a8e:	00000517          	auipc	a0,0x0
 a92:	42a50513          	addi	a0,a0,1066 # eb8 <digits+0x18>
 a96:	00000097          	auipc	ra,0x0
 a9a:	c34080e7          	jalr	-972(ra) # 6ca <printf>
      ulthread_context_switch(&temp->context, &current_thread->context);
 a9e:	000ab583          	ld	a1,0(s5)
 aa2:	05e1                	addi	a1,a1,24
 aa4:	018b8513          	addi	a0,s7,24
 aa8:	00000097          	auipc	ra,0x0
 aac:	2a0080e7          	jalr	672(ra) # d48 <ulthread_context_switch>
      if (t->state == RUNNABLE && t != scheduler_thread && t->priority > maxPriority)
 ab0:	000b3583          	ld	a1,0(s6)
    int alternativeIndex = -1;
 ab4:	86d2                	mv	a3,s4
    int threadIndex = -1;
 ab6:	8852                	mv	a6,s4
    int maxPriority = -1;
 ab8:	8652                	mv	a2,s4
    bool threadAvailable = false;
 aba:	4501                	li	a0,0
    for (t = ulthreads+1; t < &ulthreads[MAXULTHREADS]; t++)
 abc:	00064797          	auipc	a5,0x64
 ac0:	5fc78793          	addi	a5,a5,1532 # 650b8 <ulthreads+0x88>
 ac4:	bf59                	j	a5a <priorityScheduling+0x50>
    label : 
 ac6:	86c2                	mv	a3,a6
 ac8:	b765                	j	a70 <priorityScheduling+0x66>
  }
}
 aca:	60a6                	ld	ra,72(sp)
 acc:	6406                	ld	s0,64(sp)
 ace:	74e2                	ld	s1,56(sp)
 ad0:	7942                	ld	s2,48(sp)
 ad2:	79a2                	ld	s3,40(sp)
 ad4:	7a02                	ld	s4,32(sp)
 ad6:	6ae2                	ld	s5,24(sp)
 ad8:	6b42                	ld	s6,16(sp)
 ada:	6ba2                	ld	s7,8(sp)
 adc:	6161                	addi	sp,sp,80
 ade:	8082                	ret

0000000000000ae0 <ulthread_init>:

/* Thread initialization */
void ulthread_init(int schedalgo)
{
 ae0:	1141                	addi	sp,sp,-16
 ae2:	e422                	sd	s0,8(sp)
 ae4:	0800                	addi	s0,sp,16
  struct ulthread *t;
  int i;
  for (i = 0, t = ulthreads; t < &ulthreads[MAXULTHREADS]; t++, i++)
 ae6:	4701                	li	a4,0
 ae8:	00064797          	auipc	a5,0x64
 aec:	54878793          	addi	a5,a5,1352 # 65030 <ulthreads>
 af0:	00068697          	auipc	a3,0x68
 af4:	a6068693          	addi	a3,a3,-1440 # 68550 <ulthreads+0x3520>
  {
    t->state = FREE;
 af8:	0007a023          	sw	zero,0(a5)
    t->tid = i;
 afc:	c3d8                	sw	a4,4(a5)
  for (i = 0, t = ulthreads; t < &ulthreads[MAXULTHREADS]; t++, i++)
 afe:	08878793          	addi	a5,a5,136
 b02:	2705                	addiw	a4,a4,1
 b04:	fed79ae3          	bne	a5,a3,af8 <ulthread_init+0x18>
  }
  current_thread = &ulthreads[0];
 b08:	00064797          	auipc	a5,0x64
 b0c:	52878793          	addi	a5,a5,1320 # 65030 <ulthreads>
 b10:	00000717          	auipc	a4,0x0
 b14:	50f73423          	sd	a5,1288(a4) # 1018 <current_thread>
  scheduler_thread = &ulthreads[0];
 b18:	00000717          	auipc	a4,0x0
 b1c:	4ef73c23          	sd	a5,1272(a4) # 1010 <scheduler_thread>
  scheduler_thread->state = RUNNABLE;
 b20:	4705                	li	a4,1
 b22:	c398                	sw	a4,0(a5)
  t->state = FREE;
 b24:	00068797          	auipc	a5,0x68
 b28:	a207a623          	sw	zero,-1492(a5) # 68550 <ulthreads+0x3520>
  algorithm = schedalgo;
 b2c:	00000797          	auipc	a5,0x0
 b30:	4ca7ae23          	sw	a0,1244(a5) # 1008 <algorithm>
}
 b34:	6422                	ld	s0,8(sp)
 b36:	0141                	addi	sp,sp,16
 b38:	8082                	ret

0000000000000b3a <ulthread_create>:

/* Thread creation */
bool ulthread_create(uint64 start, uint64 stack, uint64 args[], int priority)
{
 b3a:	7179                	addi	sp,sp,-48
 b3c:	f406                	sd	ra,40(sp)
 b3e:	f022                	sd	s0,32(sp)
 b40:	ec26                	sd	s1,24(sp)
 b42:	e84a                	sd	s2,16(sp)
 b44:	e44e                	sd	s3,8(sp)
 b46:	e052                	sd	s4,0(sp)
 b48:	1800                	addi	s0,sp,48
 b4a:	89aa                	mv	s3,a0
 b4c:	8a2e                	mv	s4,a1
 b4e:	8932                	mv	s2,a2
  /* Please add thread-id instead of '0' here. */
  struct ulthread *t;
  bool flag = false;
  for (t = ulthreads; t < &ulthreads[MAXULTHREADS]; t++)
 b50:	00064497          	auipc	s1,0x64
 b54:	4e048493          	addi	s1,s1,1248 # 65030 <ulthreads>
 b58:	00068717          	auipc	a4,0x68
 b5c:	9f870713          	addi	a4,a4,-1544 # 68550 <ulthreads+0x3520>
  {
    if (t->state == FREE)
 b60:	409c                	lw	a5,0(s1)
 b62:	cf89                	beqz	a5,b7c <ulthread_create+0x42>
  for (t = ulthreads; t < &ulthreads[MAXULTHREADS]; t++)
 b64:	08848493          	addi	s1,s1,136
 b68:	fee49ce3          	bne	s1,a4,b60 <ulthread_create+0x26>
      break;
    }
  }
  if (!flag)
  {
    return false;
 b6c:	4501                	li	a0,0
 b6e:	a871                	j	c0a <ulthread_create+0xd0>
  t->sp = (int)(stack + USTACKSIZE); // set sp to the top of the stack
  t->state = RUNNABLE;
  t->priority = priority;

  if(algorithm==FCFS){
    t->lastTime = ctime();
 b70:	00000097          	auipc	ra,0x0
 b74:	88a080e7          	jalr	-1910(ra) # 3fa <ctime>
 b78:	e888                	sd	a0,16(s1)
 b7a:	a839                	j	b98 <ulthread_create+0x5e>
  t->sp = (int)(stack + USTACKSIZE); // set sp to the top of the stack
 b7c:	6785                	lui	a5,0x1
 b7e:	014787bb          	addw	a5,a5,s4
 b82:	c49c                	sw	a5,8(s1)
  t->state = RUNNABLE;
 b84:	4785                	li	a5,1
 b86:	c09c                	sw	a5,0(s1)
  t->priority = priority;
 b88:	c4d4                	sw	a3,12(s1)
  if(algorithm==FCFS){
 b8a:	00000717          	auipc	a4,0x0
 b8e:	47e72703          	lw	a4,1150(a4) # 1008 <algorithm>
 b92:	4789                	li	a5,2
 b94:	fcf70ee3          	beq	a4,a5,b70 <ulthread_create+0x36>
  }

  for (int argc = 0; argc < 6; argc++)
 b98:	874a                	mv	a4,s2
 b9a:	03090693          	addi	a3,s2,48
  {
    t->sp -= 16;
 b9e:	449c                	lw	a5,8(s1)
 ba0:	37c1                	addiw	a5,a5,-16 # ff0 <digits+0x150>
 ba2:	0007881b          	sext.w	a6,a5
 ba6:	c49c                	sw	a5,8(s1)
    *(uint64 *)(t->sp) = (uint64)args[argc];
 ba8:	631c                	ld	a5,0(a4)
 baa:	00f83023          	sd	a5,0(a6)
  for (int argc = 0; argc < 6; argc++)
 bae:	0721                	addi	a4,a4,8
 bb0:	fed717e3          	bne	a4,a3,b9e <ulthread_create+0x64>
  }

  memset(&t->context, 0, sizeof(t->context));
 bb4:	07000613          	li	a2,112
 bb8:	4581                	li	a1,0
 bba:	01848513          	addi	a0,s1,24
 bbe:	fffff097          	auipc	ra,0xfffff
 bc2:	5a2080e7          	jalr	1442(ra) # 160 <memset>
  t->context.ra = start;
 bc6:	0134bc23          	sd	s3,24(s1)
  t->context.sp = t->sp;
 bca:	449c                	lw	a5,8(s1)
 bcc:	f09c                	sd	a5,32(s1)
  t->context.s0 = args[0];
 bce:	00093783          	ld	a5,0(s2)
 bd2:	f49c                	sd	a5,40(s1)
  t->context.s1 = args[1];
 bd4:	00893783          	ld	a5,8(s2)
 bd8:	f89c                	sd	a5,48(s1)
  t->context.s2 = args[2];
 bda:	01093783          	ld	a5,16(s2)
 bde:	fc9c                	sd	a5,56(s1)
  t->context.s3 = args[3];
 be0:	01893783          	ld	a5,24(s2)
 be4:	e0bc                	sd	a5,64(s1)
  t->context.s4 = args[4];
 be6:	02093783          	ld	a5,32(s2)
 bea:	e4bc                	sd	a5,72(s1)
  t->context.s5 = args[5];
 bec:	02893783          	ld	a5,40(s2)
 bf0:	e8bc                	sd	a5,80(s1)

  printf("[*] ultcreate(tid: %d, ra: %p, sp: %p)\n", t->tid, start, stack);
 bf2:	86d2                	mv	a3,s4
 bf4:	864e                	mv	a2,s3
 bf6:	40cc                	lw	a1,4(s1)
 bf8:	00000517          	auipc	a0,0x0
 bfc:	31050513          	addi	a0,a0,784 # f08 <digits+0x68>
 c00:	00000097          	auipc	ra,0x0
 c04:	aca080e7          	jalr	-1334(ra) # 6ca <printf>
  return true;
 c08:	4505                	li	a0,1
}
 c0a:	70a2                	ld	ra,40(sp)
 c0c:	7402                	ld	s0,32(sp)
 c0e:	64e2                	ld	s1,24(sp)
 c10:	6942                	ld	s2,16(sp)
 c12:	69a2                	ld	s3,8(sp)
 c14:	6a02                	ld	s4,0(sp)
 c16:	6145                	addi	sp,sp,48
 c18:	8082                	ret

0000000000000c1a <ulthread_schedule>:

/* Thread scheduler */
void ulthread_schedule(void)
{
 c1a:	1141                	addi	sp,sp,-16
 c1c:	e406                	sd	ra,8(sp)
 c1e:	e022                	sd	s0,0(sp)
 c20:	0800                	addi	s0,sp,16
  switch (algorithm)
 c22:	00000797          	auipc	a5,0x0
 c26:	3e67a783          	lw	a5,998(a5) # 1008 <algorithm>
 c2a:	4705                	li	a4,1
 c2c:	02e78463          	beq	a5,a4,c54 <ulthread_schedule+0x3a>
 c30:	4709                	li	a4,2
 c32:	00e78c63          	beq	a5,a4,c4a <ulthread_schedule+0x30>
 c36:	c789                	beqz	a5,c40 <ulthread_schedule+0x26>

  // Push argument strings, prepare rest of stack in ustack.

  // Switch between thread contexts
  // ulthread_context_switch(NULL, NULL);
}
 c38:	60a2                	ld	ra,8(sp)
 c3a:	6402                	ld	s0,0(sp)
 c3c:	0141                	addi	sp,sp,16
 c3e:	8082                	ret
    roundRobin();
 c40:	00000097          	auipc	ra,0x0
 c44:	c3e080e7          	jalr	-962(ra) # 87e <roundRobin>
    break;
 c48:	bfc5                	j	c38 <ulthread_schedule+0x1e>
    firstComeFirstServe();
 c4a:	00000097          	auipc	ra,0x0
 c4e:	ce2080e7          	jalr	-798(ra) # 92c <firstComeFirstServe>
    break;
 c52:	b7dd                	j	c38 <ulthread_schedule+0x1e>
    priorityScheduling();
 c54:	00000097          	auipc	ra,0x0
 c58:	db6080e7          	jalr	-586(ra) # a0a <priorityScheduling>
}
 c5c:	bff1                	j	c38 <ulthread_schedule+0x1e>

0000000000000c5e <ulthread_yield>:

/* Yield CPU time to some other thread. */
void ulthread_yield(void)
{
 c5e:	1101                	addi	sp,sp,-32
 c60:	ec06                	sd	ra,24(sp)
 c62:	e822                	sd	s0,16(sp)
 c64:	e426                	sd	s1,8(sp)
 c66:	e04a                	sd	s2,0(sp)
 c68:	1000                	addi	s0,sp,32
  current_thread->state = YIELD;
 c6a:	00000797          	auipc	a5,0x0
 c6e:	3ae78793          	addi	a5,a5,942 # 1018 <current_thread>
 c72:	6398                	ld	a4,0(a5)
 c74:	4909                	li	s2,2
 c76:	01272023          	sw	s2,0(a4)
  struct ulthread *temp = current_thread;
 c7a:	6384                	ld	s1,0(a5)
  printf("[*] ultyield(tid: %d)\n", current_thread->tid);
 c7c:	40cc                	lw	a1,4(s1)
 c7e:	00000517          	auipc	a0,0x0
 c82:	2b250513          	addi	a0,a0,690 # f30 <digits+0x90>
 c86:	00000097          	auipc	ra,0x0
 c8a:	a44080e7          	jalr	-1468(ra) # 6ca <printf>
  if(algorithm==FCFS){
 c8e:	00000797          	auipc	a5,0x0
 c92:	37a7a783          	lw	a5,890(a5) # 1008 <algorithm>
 c96:	03278763          	beq	a5,s2,cc4 <ulthread_yield+0x66>
    current_thread->lastTime = ctime();
  }
  current_thread = scheduler_thread;
 c9a:	00000597          	auipc	a1,0x0
 c9e:	3765b583          	ld	a1,886(a1) # 1010 <scheduler_thread>
 ca2:	00000797          	auipc	a5,0x0
 ca6:	36b7bb23          	sd	a1,886(a5) # 1018 <current_thread>
  
  ulthread_context_switch(&temp->context, &scheduler_thread->context);
 caa:	05e1                	addi	a1,a1,24
 cac:	01848513          	addi	a0,s1,24
 cb0:	00000097          	auipc	ra,0x0
 cb4:	098080e7          	jalr	152(ra) # d48 <ulthread_context_switch>
  // ulthread_schedule();
}
 cb8:	60e2                	ld	ra,24(sp)
 cba:	6442                	ld	s0,16(sp)
 cbc:	64a2                	ld	s1,8(sp)
 cbe:	6902                	ld	s2,0(sp)
 cc0:	6105                	addi	sp,sp,32
 cc2:	8082                	ret
    current_thread->lastTime = ctime();
 cc4:	fffff097          	auipc	ra,0xfffff
 cc8:	736080e7          	jalr	1846(ra) # 3fa <ctime>
 ccc:	00000797          	auipc	a5,0x0
 cd0:	34c7b783          	ld	a5,844(a5) # 1018 <current_thread>
 cd4:	eb88                	sd	a0,16(a5)
 cd6:	b7d1                	j	c9a <ulthread_yield+0x3c>

0000000000000cd8 <ulthread_destroy>:

/* Destroy thread */
void ulthread_destroy(void)
{
 cd8:	1101                	addi	sp,sp,-32
 cda:	ec06                	sd	ra,24(sp)
 cdc:	e822                	sd	s0,16(sp)
 cde:	e426                	sd	s1,8(sp)
 ce0:	e04a                	sd	s2,0(sp)
 ce2:	1000                	addi	s0,sp,32
  memset(&current_thread->context, 0, sizeof(current_thread->context));
 ce4:	00000497          	auipc	s1,0x0
 ce8:	33448493          	addi	s1,s1,820 # 1018 <current_thread>
 cec:	6088                	ld	a0,0(s1)
 cee:	07000613          	li	a2,112
 cf2:	4581                	li	a1,0
 cf4:	0561                	addi	a0,a0,24
 cf6:	fffff097          	auipc	ra,0xfffff
 cfa:	46a080e7          	jalr	1130(ra) # 160 <memset>
  current_thread->sp = 0;
 cfe:	609c                	ld	a5,0(s1)
 d00:	0007a423          	sw	zero,8(a5)
  current_thread->priority = -1;
 d04:	577d                	li	a4,-1
 d06:	c7d8                	sw	a4,12(a5)
  current_thread->state = FREE;
 d08:	0007a023          	sw	zero,0(a5)

  struct ulthread *temp = current_thread;
 d0c:	0004b903          	ld	s2,0(s1)

  printf("[*] ultdestroy(tid: %d)\n", get_current_tid());
 d10:	00492583          	lw	a1,4(s2)
 d14:	00000517          	auipc	a0,0x0
 d18:	23450513          	addi	a0,a0,564 # f48 <digits+0xa8>
 d1c:	00000097          	auipc	ra,0x0
 d20:	9ae080e7          	jalr	-1618(ra) # 6ca <printf>
  current_thread = scheduler_thread;
 d24:	00000597          	auipc	a1,0x0
 d28:	2ec5b583          	ld	a1,748(a1) # 1010 <scheduler_thread>
 d2c:	e08c                	sd	a1,0(s1)
  ulthread_context_switch(&temp->context, &scheduler_thread->context);
 d2e:	05e1                	addi	a1,a1,24
 d30:	01890513          	addi	a0,s2,24
 d34:	00000097          	auipc	ra,0x0
 d38:	014080e7          	jalr	20(ra) # d48 <ulthread_context_switch>
}
 d3c:	60e2                	ld	ra,24(sp)
 d3e:	6442                	ld	s0,16(sp)
 d40:	64a2                	ld	s1,8(sp)
 d42:	6902                	ld	s2,0(sp)
 d44:	6105                	addi	sp,sp,32
 d46:	8082                	ret

0000000000000d48 <ulthread_context_switch>:
 d48:	00153023          	sd	ra,0(a0)
 d4c:	00253423          	sd	sp,8(a0)
 d50:	e900                	sd	s0,16(a0)
 d52:	ed04                	sd	s1,24(a0)
 d54:	03253023          	sd	s2,32(a0)
 d58:	03353423          	sd	s3,40(a0)
 d5c:	03453823          	sd	s4,48(a0)
 d60:	03553c23          	sd	s5,56(a0)
 d64:	05653023          	sd	s6,64(a0)
 d68:	05753423          	sd	s7,72(a0)
 d6c:	05853823          	sd	s8,80(a0)
 d70:	05953c23          	sd	s9,88(a0)
 d74:	07a53023          	sd	s10,96(a0)
 d78:	07b53423          	sd	s11,104(a0)
 d7c:	0005b083          	ld	ra,0(a1)
 d80:	0085b103          	ld	sp,8(a1)
 d84:	6980                	ld	s0,16(a1)
 d86:	6d84                	ld	s1,24(a1)
 d88:	0205b903          	ld	s2,32(a1)
 d8c:	0285b983          	ld	s3,40(a1)
 d90:	0305ba03          	ld	s4,48(a1)
 d94:	0385ba83          	ld	s5,56(a1)
 d98:	0405bb03          	ld	s6,64(a1)
 d9c:	0485bb83          	ld	s7,72(a1)
 da0:	0505bc03          	ld	s8,80(a1)
 da4:	0585bc83          	ld	s9,88(a1)
 da8:	0605bd03          	ld	s10,96(a1)
 dac:	0685bd83          	ld	s11,104(a1)
 db0:	6546                	ld	a0,80(sp)
 db2:	6586                	ld	a1,64(sp)
 db4:	7642                	ld	a2,48(sp)
 db6:	7682                	ld	a3,32(sp)
 db8:	6742                	ld	a4,16(sp)
 dba:	6782                	ld	a5,0(sp)
 dbc:	8082                	ret
