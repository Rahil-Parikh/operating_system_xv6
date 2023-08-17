
user/_mkdir:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "kernel/stat.h"
#include "user/user.h"

int
main(int argc, char *argv[])
{
   0:	1101                	addi	sp,sp,-32
   2:	ec06                	sd	ra,24(sp)
   4:	e822                	sd	s0,16(sp)
   6:	e426                	sd	s1,8(sp)
   8:	e04a                	sd	s2,0(sp)
   a:	1000                	addi	s0,sp,32
  int i;

  if(argc < 2){
   c:	4785                	li	a5,1
   e:	02a7d763          	bge	a5,a0,3c <main+0x3c>
  12:	00858493          	addi	s1,a1,8
  16:	ffe5091b          	addiw	s2,a0,-2
  1a:	02091793          	slli	a5,s2,0x20
  1e:	01d7d913          	srli	s2,a5,0x1d
  22:	05c1                	addi	a1,a1,16
  24:	992e                	add	s2,s2,a1
    fprintf(2, "Usage: mkdir files...\n");
    exit(1);
  }

  for(i = 1; i < argc; i++){
    if(mkdir(argv[i]) < 0){
  26:	6088                	ld	a0,0(s1)
  28:	00000097          	auipc	ra,0x0
  2c:	33c080e7          	jalr	828(ra) # 364 <mkdir>
  30:	02054463          	bltz	a0,58 <main+0x58>
  for(i = 1; i < argc; i++){
  34:	04a1                	addi	s1,s1,8
  36:	ff2498e3          	bne	s1,s2,26 <main+0x26>
  3a:	a80d                	j	6c <main+0x6c>
    fprintf(2, "Usage: mkdir files...\n");
  3c:	00001597          	auipc	a1,0x1
  40:	d2458593          	addi	a1,a1,-732 # d60 <ulthread_context_switch+0x76>
  44:	4509                	li	a0,2
  46:	00000097          	auipc	ra,0x0
  4a:	5f8080e7          	jalr	1528(ra) # 63e <fprintf>
    exit(1);
  4e:	4505                	li	a0,1
  50:	00000097          	auipc	ra,0x0
  54:	2ac080e7          	jalr	684(ra) # 2fc <exit>
      fprintf(2, "mkdir: %s failed to create\n", argv[i]);
  58:	6090                	ld	a2,0(s1)
  5a:	00001597          	auipc	a1,0x1
  5e:	d1e58593          	addi	a1,a1,-738 # d78 <ulthread_context_switch+0x8e>
  62:	4509                	li	a0,2
  64:	00000097          	auipc	ra,0x0
  68:	5da080e7          	jalr	1498(ra) # 63e <fprintf>
      break;
    }
  }

  exit(0);
  6c:	4501                	li	a0,0
  6e:	00000097          	auipc	ra,0x0
  72:	28e080e7          	jalr	654(ra) # 2fc <exit>

0000000000000076 <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
  76:	1141                	addi	sp,sp,-16
  78:	e406                	sd	ra,8(sp)
  7a:	e022                	sd	s0,0(sp)
  7c:	0800                	addi	s0,sp,16
  extern int main();
  main();
  7e:	00000097          	auipc	ra,0x0
  82:	f82080e7          	jalr	-126(ra) # 0 <main>
  exit(0);
  86:	4501                	li	a0,0
  88:	00000097          	auipc	ra,0x0
  8c:	274080e7          	jalr	628(ra) # 2fc <exit>

0000000000000090 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
  90:	1141                	addi	sp,sp,-16
  92:	e422                	sd	s0,8(sp)
  94:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  96:	87aa                	mv	a5,a0
  98:	0585                	addi	a1,a1,1
  9a:	0785                	addi	a5,a5,1
  9c:	fff5c703          	lbu	a4,-1(a1)
  a0:	fee78fa3          	sb	a4,-1(a5)
  a4:	fb75                	bnez	a4,98 <strcpy+0x8>
    ;
  return os;
}
  a6:	6422                	ld	s0,8(sp)
  a8:	0141                	addi	sp,sp,16
  aa:	8082                	ret

00000000000000ac <strcmp>:

int
strcmp(const char *p, const char *q)
{
  ac:	1141                	addi	sp,sp,-16
  ae:	e422                	sd	s0,8(sp)
  b0:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
  b2:	00054783          	lbu	a5,0(a0)
  b6:	cb91                	beqz	a5,ca <strcmp+0x1e>
  b8:	0005c703          	lbu	a4,0(a1)
  bc:	00f71763          	bne	a4,a5,ca <strcmp+0x1e>
    p++, q++;
  c0:	0505                	addi	a0,a0,1
  c2:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
  c4:	00054783          	lbu	a5,0(a0)
  c8:	fbe5                	bnez	a5,b8 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
  ca:	0005c503          	lbu	a0,0(a1)
}
  ce:	40a7853b          	subw	a0,a5,a0
  d2:	6422                	ld	s0,8(sp)
  d4:	0141                	addi	sp,sp,16
  d6:	8082                	ret

00000000000000d8 <strlen>:

uint
strlen(const char *s)
{
  d8:	1141                	addi	sp,sp,-16
  da:	e422                	sd	s0,8(sp)
  dc:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
  de:	00054783          	lbu	a5,0(a0)
  e2:	cf91                	beqz	a5,fe <strlen+0x26>
  e4:	0505                	addi	a0,a0,1
  e6:	87aa                	mv	a5,a0
  e8:	86be                	mv	a3,a5
  ea:	0785                	addi	a5,a5,1
  ec:	fff7c703          	lbu	a4,-1(a5)
  f0:	ff65                	bnez	a4,e8 <strlen+0x10>
  f2:	40a6853b          	subw	a0,a3,a0
  f6:	2505                	addiw	a0,a0,1
    ;
  return n;
}
  f8:	6422                	ld	s0,8(sp)
  fa:	0141                	addi	sp,sp,16
  fc:	8082                	ret
  for(n = 0; s[n]; n++)
  fe:	4501                	li	a0,0
 100:	bfe5                	j	f8 <strlen+0x20>

0000000000000102 <memset>:

void*
memset(void *dst, int c, uint n)
{
 102:	1141                	addi	sp,sp,-16
 104:	e422                	sd	s0,8(sp)
 106:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 108:	ca19                	beqz	a2,11e <memset+0x1c>
 10a:	87aa                	mv	a5,a0
 10c:	1602                	slli	a2,a2,0x20
 10e:	9201                	srli	a2,a2,0x20
 110:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 114:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 118:	0785                	addi	a5,a5,1
 11a:	fee79de3          	bne	a5,a4,114 <memset+0x12>
  }
  return dst;
}
 11e:	6422                	ld	s0,8(sp)
 120:	0141                	addi	sp,sp,16
 122:	8082                	ret

0000000000000124 <strchr>:

char*
strchr(const char *s, char c)
{
 124:	1141                	addi	sp,sp,-16
 126:	e422                	sd	s0,8(sp)
 128:	0800                	addi	s0,sp,16
  for(; *s; s++)
 12a:	00054783          	lbu	a5,0(a0)
 12e:	cb99                	beqz	a5,144 <strchr+0x20>
    if(*s == c)
 130:	00f58763          	beq	a1,a5,13e <strchr+0x1a>
  for(; *s; s++)
 134:	0505                	addi	a0,a0,1
 136:	00054783          	lbu	a5,0(a0)
 13a:	fbfd                	bnez	a5,130 <strchr+0xc>
      return (char*)s;
  return 0;
 13c:	4501                	li	a0,0
}
 13e:	6422                	ld	s0,8(sp)
 140:	0141                	addi	sp,sp,16
 142:	8082                	ret
  return 0;
 144:	4501                	li	a0,0
 146:	bfe5                	j	13e <strchr+0x1a>

0000000000000148 <gets>:

char*
gets(char *buf, int max)
{
 148:	711d                	addi	sp,sp,-96
 14a:	ec86                	sd	ra,88(sp)
 14c:	e8a2                	sd	s0,80(sp)
 14e:	e4a6                	sd	s1,72(sp)
 150:	e0ca                	sd	s2,64(sp)
 152:	fc4e                	sd	s3,56(sp)
 154:	f852                	sd	s4,48(sp)
 156:	f456                	sd	s5,40(sp)
 158:	f05a                	sd	s6,32(sp)
 15a:	ec5e                	sd	s7,24(sp)
 15c:	1080                	addi	s0,sp,96
 15e:	8baa                	mv	s7,a0
 160:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 162:	892a                	mv	s2,a0
 164:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 166:	4aa9                	li	s5,10
 168:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 16a:	89a6                	mv	s3,s1
 16c:	2485                	addiw	s1,s1,1
 16e:	0344d863          	bge	s1,s4,19e <gets+0x56>
    cc = read(0, &c, 1);
 172:	4605                	li	a2,1
 174:	faf40593          	addi	a1,s0,-81
 178:	4501                	li	a0,0
 17a:	00000097          	auipc	ra,0x0
 17e:	19a080e7          	jalr	410(ra) # 314 <read>
    if(cc < 1)
 182:	00a05e63          	blez	a0,19e <gets+0x56>
    buf[i++] = c;
 186:	faf44783          	lbu	a5,-81(s0)
 18a:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 18e:	01578763          	beq	a5,s5,19c <gets+0x54>
 192:	0905                	addi	s2,s2,1
 194:	fd679be3          	bne	a5,s6,16a <gets+0x22>
  for(i=0; i+1 < max; ){
 198:	89a6                	mv	s3,s1
 19a:	a011                	j	19e <gets+0x56>
 19c:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 19e:	99de                	add	s3,s3,s7
 1a0:	00098023          	sb	zero,0(s3)
  return buf;
}
 1a4:	855e                	mv	a0,s7
 1a6:	60e6                	ld	ra,88(sp)
 1a8:	6446                	ld	s0,80(sp)
 1aa:	64a6                	ld	s1,72(sp)
 1ac:	6906                	ld	s2,64(sp)
 1ae:	79e2                	ld	s3,56(sp)
 1b0:	7a42                	ld	s4,48(sp)
 1b2:	7aa2                	ld	s5,40(sp)
 1b4:	7b02                	ld	s6,32(sp)
 1b6:	6be2                	ld	s7,24(sp)
 1b8:	6125                	addi	sp,sp,96
 1ba:	8082                	ret

00000000000001bc <stat>:

int
stat(const char *n, struct stat *st)
{
 1bc:	1101                	addi	sp,sp,-32
 1be:	ec06                	sd	ra,24(sp)
 1c0:	e822                	sd	s0,16(sp)
 1c2:	e426                	sd	s1,8(sp)
 1c4:	e04a                	sd	s2,0(sp)
 1c6:	1000                	addi	s0,sp,32
 1c8:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 1ca:	4581                	li	a1,0
 1cc:	00000097          	auipc	ra,0x0
 1d0:	170080e7          	jalr	368(ra) # 33c <open>
  if(fd < 0)
 1d4:	02054563          	bltz	a0,1fe <stat+0x42>
 1d8:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 1da:	85ca                	mv	a1,s2
 1dc:	00000097          	auipc	ra,0x0
 1e0:	178080e7          	jalr	376(ra) # 354 <fstat>
 1e4:	892a                	mv	s2,a0
  close(fd);
 1e6:	8526                	mv	a0,s1
 1e8:	00000097          	auipc	ra,0x0
 1ec:	13c080e7          	jalr	316(ra) # 324 <close>
  return r;
}
 1f0:	854a                	mv	a0,s2
 1f2:	60e2                	ld	ra,24(sp)
 1f4:	6442                	ld	s0,16(sp)
 1f6:	64a2                	ld	s1,8(sp)
 1f8:	6902                	ld	s2,0(sp)
 1fa:	6105                	addi	sp,sp,32
 1fc:	8082                	ret
    return -1;
 1fe:	597d                	li	s2,-1
 200:	bfc5                	j	1f0 <stat+0x34>

0000000000000202 <atoi>:

int
atoi(const char *s)
{
 202:	1141                	addi	sp,sp,-16
 204:	e422                	sd	s0,8(sp)
 206:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 208:	00054683          	lbu	a3,0(a0)
 20c:	fd06879b          	addiw	a5,a3,-48
 210:	0ff7f793          	zext.b	a5,a5
 214:	4625                	li	a2,9
 216:	02f66863          	bltu	a2,a5,246 <atoi+0x44>
 21a:	872a                	mv	a4,a0
  n = 0;
 21c:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 21e:	0705                	addi	a4,a4,1
 220:	0025179b          	slliw	a5,a0,0x2
 224:	9fa9                	addw	a5,a5,a0
 226:	0017979b          	slliw	a5,a5,0x1
 22a:	9fb5                	addw	a5,a5,a3
 22c:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 230:	00074683          	lbu	a3,0(a4)
 234:	fd06879b          	addiw	a5,a3,-48
 238:	0ff7f793          	zext.b	a5,a5
 23c:	fef671e3          	bgeu	a2,a5,21e <atoi+0x1c>
  return n;
}
 240:	6422                	ld	s0,8(sp)
 242:	0141                	addi	sp,sp,16
 244:	8082                	ret
  n = 0;
 246:	4501                	li	a0,0
 248:	bfe5                	j	240 <atoi+0x3e>

000000000000024a <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 24a:	1141                	addi	sp,sp,-16
 24c:	e422                	sd	s0,8(sp)
 24e:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 250:	02b57463          	bgeu	a0,a1,278 <memmove+0x2e>
    while(n-- > 0)
 254:	00c05f63          	blez	a2,272 <memmove+0x28>
 258:	1602                	slli	a2,a2,0x20
 25a:	9201                	srli	a2,a2,0x20
 25c:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 260:	872a                	mv	a4,a0
      *dst++ = *src++;
 262:	0585                	addi	a1,a1,1
 264:	0705                	addi	a4,a4,1
 266:	fff5c683          	lbu	a3,-1(a1)
 26a:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 26e:	fee79ae3          	bne	a5,a4,262 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 272:	6422                	ld	s0,8(sp)
 274:	0141                	addi	sp,sp,16
 276:	8082                	ret
    dst += n;
 278:	00c50733          	add	a4,a0,a2
    src += n;
 27c:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 27e:	fec05ae3          	blez	a2,272 <memmove+0x28>
 282:	fff6079b          	addiw	a5,a2,-1
 286:	1782                	slli	a5,a5,0x20
 288:	9381                	srli	a5,a5,0x20
 28a:	fff7c793          	not	a5,a5
 28e:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 290:	15fd                	addi	a1,a1,-1
 292:	177d                	addi	a4,a4,-1
 294:	0005c683          	lbu	a3,0(a1)
 298:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 29c:	fee79ae3          	bne	a5,a4,290 <memmove+0x46>
 2a0:	bfc9                	j	272 <memmove+0x28>

00000000000002a2 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 2a2:	1141                	addi	sp,sp,-16
 2a4:	e422                	sd	s0,8(sp)
 2a6:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 2a8:	ca05                	beqz	a2,2d8 <memcmp+0x36>
 2aa:	fff6069b          	addiw	a3,a2,-1
 2ae:	1682                	slli	a3,a3,0x20
 2b0:	9281                	srli	a3,a3,0x20
 2b2:	0685                	addi	a3,a3,1
 2b4:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 2b6:	00054783          	lbu	a5,0(a0)
 2ba:	0005c703          	lbu	a4,0(a1)
 2be:	00e79863          	bne	a5,a4,2ce <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 2c2:	0505                	addi	a0,a0,1
    p2++;
 2c4:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 2c6:	fed518e3          	bne	a0,a3,2b6 <memcmp+0x14>
  }
  return 0;
 2ca:	4501                	li	a0,0
 2cc:	a019                	j	2d2 <memcmp+0x30>
      return *p1 - *p2;
 2ce:	40e7853b          	subw	a0,a5,a4
}
 2d2:	6422                	ld	s0,8(sp)
 2d4:	0141                	addi	sp,sp,16
 2d6:	8082                	ret
  return 0;
 2d8:	4501                	li	a0,0
 2da:	bfe5                	j	2d2 <memcmp+0x30>

00000000000002dc <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 2dc:	1141                	addi	sp,sp,-16
 2de:	e406                	sd	ra,8(sp)
 2e0:	e022                	sd	s0,0(sp)
 2e2:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 2e4:	00000097          	auipc	ra,0x0
 2e8:	f66080e7          	jalr	-154(ra) # 24a <memmove>
}
 2ec:	60a2                	ld	ra,8(sp)
 2ee:	6402                	ld	s0,0(sp)
 2f0:	0141                	addi	sp,sp,16
 2f2:	8082                	ret

00000000000002f4 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 2f4:	4885                	li	a7,1
 ecall
 2f6:	00000073          	ecall
 ret
 2fa:	8082                	ret

00000000000002fc <exit>:
.global exit
exit:
 li a7, SYS_exit
 2fc:	4889                	li	a7,2
 ecall
 2fe:	00000073          	ecall
 ret
 302:	8082                	ret

0000000000000304 <wait>:
.global wait
wait:
 li a7, SYS_wait
 304:	488d                	li	a7,3
 ecall
 306:	00000073          	ecall
 ret
 30a:	8082                	ret

000000000000030c <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 30c:	4891                	li	a7,4
 ecall
 30e:	00000073          	ecall
 ret
 312:	8082                	ret

0000000000000314 <read>:
.global read
read:
 li a7, SYS_read
 314:	4895                	li	a7,5
 ecall
 316:	00000073          	ecall
 ret
 31a:	8082                	ret

000000000000031c <write>:
.global write
write:
 li a7, SYS_write
 31c:	48c1                	li	a7,16
 ecall
 31e:	00000073          	ecall
 ret
 322:	8082                	ret

0000000000000324 <close>:
.global close
close:
 li a7, SYS_close
 324:	48d5                	li	a7,21
 ecall
 326:	00000073          	ecall
 ret
 32a:	8082                	ret

000000000000032c <kill>:
.global kill
kill:
 li a7, SYS_kill
 32c:	4899                	li	a7,6
 ecall
 32e:	00000073          	ecall
 ret
 332:	8082                	ret

0000000000000334 <exec>:
.global exec
exec:
 li a7, SYS_exec
 334:	489d                	li	a7,7
 ecall
 336:	00000073          	ecall
 ret
 33a:	8082                	ret

000000000000033c <open>:
.global open
open:
 li a7, SYS_open
 33c:	48bd                	li	a7,15
 ecall
 33e:	00000073          	ecall
 ret
 342:	8082                	ret

0000000000000344 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 344:	48c5                	li	a7,17
 ecall
 346:	00000073          	ecall
 ret
 34a:	8082                	ret

000000000000034c <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 34c:	48c9                	li	a7,18
 ecall
 34e:	00000073          	ecall
 ret
 352:	8082                	ret

0000000000000354 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 354:	48a1                	li	a7,8
 ecall
 356:	00000073          	ecall
 ret
 35a:	8082                	ret

000000000000035c <link>:
.global link
link:
 li a7, SYS_link
 35c:	48cd                	li	a7,19
 ecall
 35e:	00000073          	ecall
 ret
 362:	8082                	ret

0000000000000364 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 364:	48d1                	li	a7,20
 ecall
 366:	00000073          	ecall
 ret
 36a:	8082                	ret

000000000000036c <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 36c:	48a5                	li	a7,9
 ecall
 36e:	00000073          	ecall
 ret
 372:	8082                	ret

0000000000000374 <dup>:
.global dup
dup:
 li a7, SYS_dup
 374:	48a9                	li	a7,10
 ecall
 376:	00000073          	ecall
 ret
 37a:	8082                	ret

000000000000037c <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 37c:	48ad                	li	a7,11
 ecall
 37e:	00000073          	ecall
 ret
 382:	8082                	ret

0000000000000384 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 384:	48b1                	li	a7,12
 ecall
 386:	00000073          	ecall
 ret
 38a:	8082                	ret

000000000000038c <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 38c:	48b5                	li	a7,13
 ecall
 38e:	00000073          	ecall
 ret
 392:	8082                	ret

0000000000000394 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 394:	48b9                	li	a7,14
 ecall
 396:	00000073          	ecall
 ret
 39a:	8082                	ret

000000000000039c <ctime>:
.global ctime
ctime:
 li a7, SYS_ctime
 39c:	48d9                	li	a7,22
 ecall
 39e:	00000073          	ecall
 ret
 3a2:	8082                	ret

00000000000003a4 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 3a4:	1101                	addi	sp,sp,-32
 3a6:	ec06                	sd	ra,24(sp)
 3a8:	e822                	sd	s0,16(sp)
 3aa:	1000                	addi	s0,sp,32
 3ac:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 3b0:	4605                	li	a2,1
 3b2:	fef40593          	addi	a1,s0,-17
 3b6:	00000097          	auipc	ra,0x0
 3ba:	f66080e7          	jalr	-154(ra) # 31c <write>
}
 3be:	60e2                	ld	ra,24(sp)
 3c0:	6442                	ld	s0,16(sp)
 3c2:	6105                	addi	sp,sp,32
 3c4:	8082                	ret

00000000000003c6 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 3c6:	7139                	addi	sp,sp,-64
 3c8:	fc06                	sd	ra,56(sp)
 3ca:	f822                	sd	s0,48(sp)
 3cc:	f426                	sd	s1,40(sp)
 3ce:	f04a                	sd	s2,32(sp)
 3d0:	ec4e                	sd	s3,24(sp)
 3d2:	0080                	addi	s0,sp,64
 3d4:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 3d6:	c299                	beqz	a3,3dc <printint+0x16>
 3d8:	0805c963          	bltz	a1,46a <printint+0xa4>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 3dc:	2581                	sext.w	a1,a1
  neg = 0;
 3de:	4881                	li	a7,0
 3e0:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 3e4:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 3e6:	2601                	sext.w	a2,a2
 3e8:	00001517          	auipc	a0,0x1
 3ec:	a1050513          	addi	a0,a0,-1520 # df8 <digits>
 3f0:	883a                	mv	a6,a4
 3f2:	2705                	addiw	a4,a4,1
 3f4:	02c5f7bb          	remuw	a5,a1,a2
 3f8:	1782                	slli	a5,a5,0x20
 3fa:	9381                	srli	a5,a5,0x20
 3fc:	97aa                	add	a5,a5,a0
 3fe:	0007c783          	lbu	a5,0(a5)
 402:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 406:	0005879b          	sext.w	a5,a1
 40a:	02c5d5bb          	divuw	a1,a1,a2
 40e:	0685                	addi	a3,a3,1
 410:	fec7f0e3          	bgeu	a5,a2,3f0 <printint+0x2a>
  if(neg)
 414:	00088c63          	beqz	a7,42c <printint+0x66>
    buf[i++] = '-';
 418:	fd070793          	addi	a5,a4,-48
 41c:	00878733          	add	a4,a5,s0
 420:	02d00793          	li	a5,45
 424:	fef70823          	sb	a5,-16(a4)
 428:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 42c:	02e05863          	blez	a4,45c <printint+0x96>
 430:	fc040793          	addi	a5,s0,-64
 434:	00e78933          	add	s2,a5,a4
 438:	fff78993          	addi	s3,a5,-1
 43c:	99ba                	add	s3,s3,a4
 43e:	377d                	addiw	a4,a4,-1
 440:	1702                	slli	a4,a4,0x20
 442:	9301                	srli	a4,a4,0x20
 444:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 448:	fff94583          	lbu	a1,-1(s2)
 44c:	8526                	mv	a0,s1
 44e:	00000097          	auipc	ra,0x0
 452:	f56080e7          	jalr	-170(ra) # 3a4 <putc>
  while(--i >= 0)
 456:	197d                	addi	s2,s2,-1
 458:	ff3918e3          	bne	s2,s3,448 <printint+0x82>
}
 45c:	70e2                	ld	ra,56(sp)
 45e:	7442                	ld	s0,48(sp)
 460:	74a2                	ld	s1,40(sp)
 462:	7902                	ld	s2,32(sp)
 464:	69e2                	ld	s3,24(sp)
 466:	6121                	addi	sp,sp,64
 468:	8082                	ret
    x = -xx;
 46a:	40b005bb          	negw	a1,a1
    neg = 1;
 46e:	4885                	li	a7,1
    x = -xx;
 470:	bf85                	j	3e0 <printint+0x1a>

0000000000000472 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 472:	715d                	addi	sp,sp,-80
 474:	e486                	sd	ra,72(sp)
 476:	e0a2                	sd	s0,64(sp)
 478:	fc26                	sd	s1,56(sp)
 47a:	f84a                	sd	s2,48(sp)
 47c:	f44e                	sd	s3,40(sp)
 47e:	f052                	sd	s4,32(sp)
 480:	ec56                	sd	s5,24(sp)
 482:	e85a                	sd	s6,16(sp)
 484:	e45e                	sd	s7,8(sp)
 486:	e062                	sd	s8,0(sp)
 488:	0880                	addi	s0,sp,80
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 48a:	0005c903          	lbu	s2,0(a1)
 48e:	18090c63          	beqz	s2,626 <vprintf+0x1b4>
 492:	8aaa                	mv	s5,a0
 494:	8bb2                	mv	s7,a2
 496:	00158493          	addi	s1,a1,1
  state = 0;
 49a:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 49c:	02500a13          	li	s4,37
 4a0:	4b55                	li	s6,21
 4a2:	a839                	j	4c0 <vprintf+0x4e>
        putc(fd, c);
 4a4:	85ca                	mv	a1,s2
 4a6:	8556                	mv	a0,s5
 4a8:	00000097          	auipc	ra,0x0
 4ac:	efc080e7          	jalr	-260(ra) # 3a4 <putc>
 4b0:	a019                	j	4b6 <vprintf+0x44>
    } else if(state == '%'){
 4b2:	01498d63          	beq	s3,s4,4cc <vprintf+0x5a>
  for(i = 0; fmt[i]; i++){
 4b6:	0485                	addi	s1,s1,1
 4b8:	fff4c903          	lbu	s2,-1(s1)
 4bc:	16090563          	beqz	s2,626 <vprintf+0x1b4>
    if(state == 0){
 4c0:	fe0999e3          	bnez	s3,4b2 <vprintf+0x40>
      if(c == '%'){
 4c4:	ff4910e3          	bne	s2,s4,4a4 <vprintf+0x32>
        state = '%';
 4c8:	89d2                	mv	s3,s4
 4ca:	b7f5                	j	4b6 <vprintf+0x44>
      if(c == 'd'){
 4cc:	13490263          	beq	s2,s4,5f0 <vprintf+0x17e>
 4d0:	f9d9079b          	addiw	a5,s2,-99
 4d4:	0ff7f793          	zext.b	a5,a5
 4d8:	12fb6563          	bltu	s6,a5,602 <vprintf+0x190>
 4dc:	f9d9079b          	addiw	a5,s2,-99
 4e0:	0ff7f713          	zext.b	a4,a5
 4e4:	10eb6f63          	bltu	s6,a4,602 <vprintf+0x190>
 4e8:	00271793          	slli	a5,a4,0x2
 4ec:	00001717          	auipc	a4,0x1
 4f0:	8b470713          	addi	a4,a4,-1868 # da0 <ulthread_context_switch+0xb6>
 4f4:	97ba                	add	a5,a5,a4
 4f6:	439c                	lw	a5,0(a5)
 4f8:	97ba                	add	a5,a5,a4
 4fa:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
 4fc:	008b8913          	addi	s2,s7,8
 500:	4685                	li	a3,1
 502:	4629                	li	a2,10
 504:	000ba583          	lw	a1,0(s7)
 508:	8556                	mv	a0,s5
 50a:	00000097          	auipc	ra,0x0
 50e:	ebc080e7          	jalr	-324(ra) # 3c6 <printint>
 512:	8bca                	mv	s7,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 514:	4981                	li	s3,0
 516:	b745                	j	4b6 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 518:	008b8913          	addi	s2,s7,8
 51c:	4681                	li	a3,0
 51e:	4629                	li	a2,10
 520:	000ba583          	lw	a1,0(s7)
 524:	8556                	mv	a0,s5
 526:	00000097          	auipc	ra,0x0
 52a:	ea0080e7          	jalr	-352(ra) # 3c6 <printint>
 52e:	8bca                	mv	s7,s2
      state = 0;
 530:	4981                	li	s3,0
 532:	b751                	j	4b6 <vprintf+0x44>
        printint(fd, va_arg(ap, int), 16, 0);
 534:	008b8913          	addi	s2,s7,8
 538:	4681                	li	a3,0
 53a:	4641                	li	a2,16
 53c:	000ba583          	lw	a1,0(s7)
 540:	8556                	mv	a0,s5
 542:	00000097          	auipc	ra,0x0
 546:	e84080e7          	jalr	-380(ra) # 3c6 <printint>
 54a:	8bca                	mv	s7,s2
      state = 0;
 54c:	4981                	li	s3,0
 54e:	b7a5                	j	4b6 <vprintf+0x44>
        printptr(fd, va_arg(ap, uint64));
 550:	008b8c13          	addi	s8,s7,8
 554:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 558:	03000593          	li	a1,48
 55c:	8556                	mv	a0,s5
 55e:	00000097          	auipc	ra,0x0
 562:	e46080e7          	jalr	-442(ra) # 3a4 <putc>
  putc(fd, 'x');
 566:	07800593          	li	a1,120
 56a:	8556                	mv	a0,s5
 56c:	00000097          	auipc	ra,0x0
 570:	e38080e7          	jalr	-456(ra) # 3a4 <putc>
 574:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 576:	00001b97          	auipc	s7,0x1
 57a:	882b8b93          	addi	s7,s7,-1918 # df8 <digits>
 57e:	03c9d793          	srli	a5,s3,0x3c
 582:	97de                	add	a5,a5,s7
 584:	0007c583          	lbu	a1,0(a5)
 588:	8556                	mv	a0,s5
 58a:	00000097          	auipc	ra,0x0
 58e:	e1a080e7          	jalr	-486(ra) # 3a4 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 592:	0992                	slli	s3,s3,0x4
 594:	397d                	addiw	s2,s2,-1
 596:	fe0914e3          	bnez	s2,57e <vprintf+0x10c>
        printptr(fd, va_arg(ap, uint64));
 59a:	8be2                	mv	s7,s8
      state = 0;
 59c:	4981                	li	s3,0
 59e:	bf21                	j	4b6 <vprintf+0x44>
        s = va_arg(ap, char*);
 5a0:	008b8993          	addi	s3,s7,8
 5a4:	000bb903          	ld	s2,0(s7)
        if(s == 0)
 5a8:	02090163          	beqz	s2,5ca <vprintf+0x158>
        while(*s != 0){
 5ac:	00094583          	lbu	a1,0(s2)
 5b0:	c9a5                	beqz	a1,620 <vprintf+0x1ae>
          putc(fd, *s);
 5b2:	8556                	mv	a0,s5
 5b4:	00000097          	auipc	ra,0x0
 5b8:	df0080e7          	jalr	-528(ra) # 3a4 <putc>
          s++;
 5bc:	0905                	addi	s2,s2,1
        while(*s != 0){
 5be:	00094583          	lbu	a1,0(s2)
 5c2:	f9e5                	bnez	a1,5b2 <vprintf+0x140>
        s = va_arg(ap, char*);
 5c4:	8bce                	mv	s7,s3
      state = 0;
 5c6:	4981                	li	s3,0
 5c8:	b5fd                	j	4b6 <vprintf+0x44>
          s = "(null)";
 5ca:	00000917          	auipc	s2,0x0
 5ce:	7ce90913          	addi	s2,s2,1998 # d98 <ulthread_context_switch+0xae>
        while(*s != 0){
 5d2:	02800593          	li	a1,40
 5d6:	bff1                	j	5b2 <vprintf+0x140>
        putc(fd, va_arg(ap, uint));
 5d8:	008b8913          	addi	s2,s7,8
 5dc:	000bc583          	lbu	a1,0(s7)
 5e0:	8556                	mv	a0,s5
 5e2:	00000097          	auipc	ra,0x0
 5e6:	dc2080e7          	jalr	-574(ra) # 3a4 <putc>
 5ea:	8bca                	mv	s7,s2
      state = 0;
 5ec:	4981                	li	s3,0
 5ee:	b5e1                	j	4b6 <vprintf+0x44>
        putc(fd, c);
 5f0:	02500593          	li	a1,37
 5f4:	8556                	mv	a0,s5
 5f6:	00000097          	auipc	ra,0x0
 5fa:	dae080e7          	jalr	-594(ra) # 3a4 <putc>
      state = 0;
 5fe:	4981                	li	s3,0
 600:	bd5d                	j	4b6 <vprintf+0x44>
        putc(fd, '%');
 602:	02500593          	li	a1,37
 606:	8556                	mv	a0,s5
 608:	00000097          	auipc	ra,0x0
 60c:	d9c080e7          	jalr	-612(ra) # 3a4 <putc>
        putc(fd, c);
 610:	85ca                	mv	a1,s2
 612:	8556                	mv	a0,s5
 614:	00000097          	auipc	ra,0x0
 618:	d90080e7          	jalr	-624(ra) # 3a4 <putc>
      state = 0;
 61c:	4981                	li	s3,0
 61e:	bd61                	j	4b6 <vprintf+0x44>
        s = va_arg(ap, char*);
 620:	8bce                	mv	s7,s3
      state = 0;
 622:	4981                	li	s3,0
 624:	bd49                	j	4b6 <vprintf+0x44>
    }
  }
}
 626:	60a6                	ld	ra,72(sp)
 628:	6406                	ld	s0,64(sp)
 62a:	74e2                	ld	s1,56(sp)
 62c:	7942                	ld	s2,48(sp)
 62e:	79a2                	ld	s3,40(sp)
 630:	7a02                	ld	s4,32(sp)
 632:	6ae2                	ld	s5,24(sp)
 634:	6b42                	ld	s6,16(sp)
 636:	6ba2                	ld	s7,8(sp)
 638:	6c02                	ld	s8,0(sp)
 63a:	6161                	addi	sp,sp,80
 63c:	8082                	ret

000000000000063e <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 63e:	715d                	addi	sp,sp,-80
 640:	ec06                	sd	ra,24(sp)
 642:	e822                	sd	s0,16(sp)
 644:	1000                	addi	s0,sp,32
 646:	e010                	sd	a2,0(s0)
 648:	e414                	sd	a3,8(s0)
 64a:	e818                	sd	a4,16(s0)
 64c:	ec1c                	sd	a5,24(s0)
 64e:	03043023          	sd	a6,32(s0)
 652:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 656:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 65a:	8622                	mv	a2,s0
 65c:	00000097          	auipc	ra,0x0
 660:	e16080e7          	jalr	-490(ra) # 472 <vprintf>
}
 664:	60e2                	ld	ra,24(sp)
 666:	6442                	ld	s0,16(sp)
 668:	6161                	addi	sp,sp,80
 66a:	8082                	ret

000000000000066c <printf>:

void
printf(const char *fmt, ...)
{
 66c:	711d                	addi	sp,sp,-96
 66e:	ec06                	sd	ra,24(sp)
 670:	e822                	sd	s0,16(sp)
 672:	1000                	addi	s0,sp,32
 674:	e40c                	sd	a1,8(s0)
 676:	e810                	sd	a2,16(s0)
 678:	ec14                	sd	a3,24(s0)
 67a:	f018                	sd	a4,32(s0)
 67c:	f41c                	sd	a5,40(s0)
 67e:	03043823          	sd	a6,48(s0)
 682:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 686:	00840613          	addi	a2,s0,8
 68a:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 68e:	85aa                	mv	a1,a0
 690:	4505                	li	a0,1
 692:	00000097          	auipc	ra,0x0
 696:	de0080e7          	jalr	-544(ra) # 472 <vprintf>
}
 69a:	60e2                	ld	ra,24(sp)
 69c:	6442                	ld	s0,16(sp)
 69e:	6125                	addi	sp,sp,96
 6a0:	8082                	ret

00000000000006a2 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 6a2:	1141                	addi	sp,sp,-16
 6a4:	e422                	sd	s0,8(sp)
 6a6:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 6a8:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 6ac:	00001797          	auipc	a5,0x1
 6b0:	9547b783          	ld	a5,-1708(a5) # 1000 <freep>
 6b4:	a02d                	j	6de <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 6b6:	4618                	lw	a4,8(a2)
 6b8:	9f2d                	addw	a4,a4,a1
 6ba:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 6be:	6398                	ld	a4,0(a5)
 6c0:	6310                	ld	a2,0(a4)
 6c2:	a83d                	j	700 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 6c4:	ff852703          	lw	a4,-8(a0)
 6c8:	9f31                	addw	a4,a4,a2
 6ca:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 6cc:	ff053683          	ld	a3,-16(a0)
 6d0:	a091                	j	714 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 6d2:	6398                	ld	a4,0(a5)
 6d4:	00e7e463          	bltu	a5,a4,6dc <free+0x3a>
 6d8:	00e6ea63          	bltu	a3,a4,6ec <free+0x4a>
{
 6dc:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 6de:	fed7fae3          	bgeu	a5,a3,6d2 <free+0x30>
 6e2:	6398                	ld	a4,0(a5)
 6e4:	00e6e463          	bltu	a3,a4,6ec <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 6e8:	fee7eae3          	bltu	a5,a4,6dc <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 6ec:	ff852583          	lw	a1,-8(a0)
 6f0:	6390                	ld	a2,0(a5)
 6f2:	02059813          	slli	a6,a1,0x20
 6f6:	01c85713          	srli	a4,a6,0x1c
 6fa:	9736                	add	a4,a4,a3
 6fc:	fae60de3          	beq	a2,a4,6b6 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 700:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 704:	4790                	lw	a2,8(a5)
 706:	02061593          	slli	a1,a2,0x20
 70a:	01c5d713          	srli	a4,a1,0x1c
 70e:	973e                	add	a4,a4,a5
 710:	fae68ae3          	beq	a3,a4,6c4 <free+0x22>
    p->s.ptr = bp->s.ptr;
 714:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 716:	00001717          	auipc	a4,0x1
 71a:	8ef73523          	sd	a5,-1814(a4) # 1000 <freep>
}
 71e:	6422                	ld	s0,8(sp)
 720:	0141                	addi	sp,sp,16
 722:	8082                	ret

0000000000000724 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 724:	7139                	addi	sp,sp,-64
 726:	fc06                	sd	ra,56(sp)
 728:	f822                	sd	s0,48(sp)
 72a:	f426                	sd	s1,40(sp)
 72c:	f04a                	sd	s2,32(sp)
 72e:	ec4e                	sd	s3,24(sp)
 730:	e852                	sd	s4,16(sp)
 732:	e456                	sd	s5,8(sp)
 734:	e05a                	sd	s6,0(sp)
 736:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 738:	02051493          	slli	s1,a0,0x20
 73c:	9081                	srli	s1,s1,0x20
 73e:	04bd                	addi	s1,s1,15
 740:	8091                	srli	s1,s1,0x4
 742:	0014899b          	addiw	s3,s1,1
 746:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 748:	00001517          	auipc	a0,0x1
 74c:	8b853503          	ld	a0,-1864(a0) # 1000 <freep>
 750:	c515                	beqz	a0,77c <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 752:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 754:	4798                	lw	a4,8(a5)
 756:	02977f63          	bgeu	a4,s1,794 <malloc+0x70>
  if(nu < 4096)
 75a:	8a4e                	mv	s4,s3
 75c:	0009871b          	sext.w	a4,s3
 760:	6685                	lui	a3,0x1
 762:	00d77363          	bgeu	a4,a3,768 <malloc+0x44>
 766:	6a05                	lui	s4,0x1
 768:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 76c:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 770:	00001917          	auipc	s2,0x1
 774:	89090913          	addi	s2,s2,-1904 # 1000 <freep>
  if(p == (char*)-1)
 778:	5afd                	li	s5,-1
 77a:	a895                	j	7ee <malloc+0xca>
    base.s.ptr = freep = prevp = &base;
 77c:	00001797          	auipc	a5,0x1
 780:	8a478793          	addi	a5,a5,-1884 # 1020 <base>
 784:	00001717          	auipc	a4,0x1
 788:	86f73e23          	sd	a5,-1924(a4) # 1000 <freep>
 78c:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 78e:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 792:	b7e1                	j	75a <malloc+0x36>
      if(p->s.size == nunits)
 794:	02e48c63          	beq	s1,a4,7cc <malloc+0xa8>
        p->s.size -= nunits;
 798:	4137073b          	subw	a4,a4,s3
 79c:	c798                	sw	a4,8(a5)
        p += p->s.size;
 79e:	02071693          	slli	a3,a4,0x20
 7a2:	01c6d713          	srli	a4,a3,0x1c
 7a6:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 7a8:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 7ac:	00001717          	auipc	a4,0x1
 7b0:	84a73a23          	sd	a0,-1964(a4) # 1000 <freep>
      return (void*)(p + 1);
 7b4:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 7b8:	70e2                	ld	ra,56(sp)
 7ba:	7442                	ld	s0,48(sp)
 7bc:	74a2                	ld	s1,40(sp)
 7be:	7902                	ld	s2,32(sp)
 7c0:	69e2                	ld	s3,24(sp)
 7c2:	6a42                	ld	s4,16(sp)
 7c4:	6aa2                	ld	s5,8(sp)
 7c6:	6b02                	ld	s6,0(sp)
 7c8:	6121                	addi	sp,sp,64
 7ca:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 7cc:	6398                	ld	a4,0(a5)
 7ce:	e118                	sd	a4,0(a0)
 7d0:	bff1                	j	7ac <malloc+0x88>
  hp->s.size = nu;
 7d2:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 7d6:	0541                	addi	a0,a0,16
 7d8:	00000097          	auipc	ra,0x0
 7dc:	eca080e7          	jalr	-310(ra) # 6a2 <free>
  return freep;
 7e0:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 7e4:	d971                	beqz	a0,7b8 <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 7e6:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 7e8:	4798                	lw	a4,8(a5)
 7ea:	fa9775e3          	bgeu	a4,s1,794 <malloc+0x70>
    if(p == freep)
 7ee:	00093703          	ld	a4,0(s2)
 7f2:	853e                	mv	a0,a5
 7f4:	fef719e3          	bne	a4,a5,7e6 <malloc+0xc2>
  p = sbrk(nu * sizeof(Header));
 7f8:	8552                	mv	a0,s4
 7fa:	00000097          	auipc	ra,0x0
 7fe:	b8a080e7          	jalr	-1142(ra) # 384 <sbrk>
  if(p == (char*)-1)
 802:	fd5518e3          	bne	a0,s5,7d2 <malloc+0xae>
        return 0;
 806:	4501                	li	a0,0
 808:	bf45                	j	7b8 <malloc+0x94>

000000000000080a <get_current_tid>:
struct ulthread *scheduler_thread;
enum ulthread_scheduling_algorithm algorithm;

/* Get thread ID */
int get_current_tid(void)
{
 80a:	1141                	addi	sp,sp,-16
 80c:	e422                	sd	s0,8(sp)
 80e:	0800                	addi	s0,sp,16
  return current_thread->tid;
}
 810:	00001797          	auipc	a5,0x1
 814:	8087b783          	ld	a5,-2040(a5) # 1018 <current_thread>
 818:	43c8                	lw	a0,4(a5)
 81a:	6422                	ld	s0,8(sp)
 81c:	0141                	addi	sp,sp,16
 81e:	8082                	ret

0000000000000820 <roundRobin>:

void roundRobin(void)
{
 820:	715d                	addi	sp,sp,-80
 822:	e486                	sd	ra,72(sp)
 824:	e0a2                	sd	s0,64(sp)
 826:	fc26                	sd	s1,56(sp)
 828:	f84a                	sd	s2,48(sp)
 82a:	f44e                	sd	s3,40(sp)
 82c:	f052                	sd	s4,32(sp)
 82e:	ec56                	sd	s5,24(sp)
 830:	e85a                	sd	s6,16(sp)
 832:	e45e                	sd	s7,8(sp)
 834:	e062                	sd	s8,0(sp)
 836:	0880                	addi	s0,sp,80
        struct ulthread *temp = current_thread;
        current_thread = t;
        printf("[*] ultschedule (next tid: %d)\n", get_current_tid());
        ulthread_context_switch(&temp->context, &t->context);
      }
      if (t->state == YIELD)
 838:	4a09                	li	s4,2
      if (t->state == RUNNABLE && t != scheduler_thread)
 83a:	00000b97          	auipc	s7,0x0
 83e:	7d6b8b93          	addi	s7,s7,2006 # 1010 <scheduler_thread>
        struct ulthread *temp = current_thread;
 842:	00000a97          	auipc	s5,0x0
 846:	7d6a8a93          	addi	s5,s5,2006 # 1018 <current_thread>
        printf("[*] ultschedule (next tid: %d)\n", get_current_tid());
 84a:	00000c17          	auipc	s8,0x0
 84e:	5c6c0c13          	addi	s8,s8,1478 # e10 <digits+0x18>
    for (t = ulthreads; t < &ulthreads[MAXULTHREADS]; t++)
 852:	00004997          	auipc	s3,0x4
 856:	cfe98993          	addi	s3,s3,-770 # 4550 <ulthreads+0x3520>
 85a:	a0b9                	j	8a8 <roundRobin+0x88>
      if (t->state == RUNNABLE && t != scheduler_thread)
 85c:	000bb783          	ld	a5,0(s7)
 860:	02978863          	beq	a5,s1,890 <roundRobin+0x70>
        struct ulthread *temp = current_thread;
 864:	000abb03          	ld	s6,0(s5)
        current_thread = t;
 868:	009ab023          	sd	s1,0(s5)
        printf("[*] ultschedule (next tid: %d)\n", get_current_tid());
 86c:	40cc                	lw	a1,4(s1)
 86e:	8562                	mv	a0,s8
 870:	00000097          	auipc	ra,0x0
 874:	dfc080e7          	jalr	-516(ra) # 66c <printf>
        ulthread_context_switch(&temp->context, &t->context);
 878:	01848593          	addi	a1,s1,24
 87c:	018b0513          	addi	a0,s6,24
 880:	00000097          	auipc	ra,0x0
 884:	46a080e7          	jalr	1130(ra) # cea <ulthread_context_switch>
        threadAvailable = true;
 888:	874a                	mv	a4,s2
 88a:	a811                	j	89e <roundRobin+0x7e>
      {
        t->state = RUNNABLE;
 88c:	0124a023          	sw	s2,0(s1)
    for (t = ulthreads; t < &ulthreads[MAXULTHREADS]; t++)
 890:	08848493          	addi	s1,s1,136
 894:	01348963          	beq	s1,s3,8a6 <roundRobin+0x86>
      if (t->state == RUNNABLE && t != scheduler_thread)
 898:	409c                	lw	a5,0(s1)
 89a:	fd2781e3          	beq	a5,s2,85c <roundRobin+0x3c>
      if (t->state == YIELD)
 89e:	409c                	lw	a5,0(s1)
 8a0:	ff4798e3          	bne	a5,s4,890 <roundRobin+0x70>
 8a4:	b7e5                	j	88c <roundRobin+0x6c>
      }
    }
    if (!threadAvailable)
 8a6:	cb01                	beqz	a4,8b6 <roundRobin+0x96>
    bool threadAvailable = false;
 8a8:	4701                	li	a4,0
    for (t = ulthreads; t < &ulthreads[MAXULTHREADS]; t++)
 8aa:	00000497          	auipc	s1,0x0
 8ae:	78648493          	addi	s1,s1,1926 # 1030 <ulthreads>
      if (t->state == RUNNABLE && t != scheduler_thread)
 8b2:	4905                	li	s2,1
 8b4:	b7d5                	j	898 <roundRobin+0x78>
    {
      break;
    }
  }
}
 8b6:	60a6                	ld	ra,72(sp)
 8b8:	6406                	ld	s0,64(sp)
 8ba:	74e2                	ld	s1,56(sp)
 8bc:	7942                	ld	s2,48(sp)
 8be:	79a2                	ld	s3,40(sp)
 8c0:	7a02                	ld	s4,32(sp)
 8c2:	6ae2                	ld	s5,24(sp)
 8c4:	6b42                	ld	s6,16(sp)
 8c6:	6ba2                	ld	s7,8(sp)
 8c8:	6c02                	ld	s8,0(sp)
 8ca:	6161                	addi	sp,sp,80
 8cc:	8082                	ret

00000000000008ce <firstComeFirstServe>:

void firstComeFirstServe(void)
{
 8ce:	715d                	addi	sp,sp,-80
 8d0:	e486                	sd	ra,72(sp)
 8d2:	e0a2                	sd	s0,64(sp)
 8d4:	fc26                	sd	s1,56(sp)
 8d6:	f84a                	sd	s2,48(sp)
 8d8:	f44e                	sd	s3,40(sp)
 8da:	f052                	sd	s4,32(sp)
 8dc:	ec56                	sd	s5,24(sp)
 8de:	e85a                	sd	s6,16(sp)
 8e0:	e45e                	sd	s7,8(sp)
 8e2:	e062                	sd	s8,0(sp)
 8e4:	0880                	addi	s0,sp,80
    uint64 oldest = __INT64_MAX__;
    int threadIndex = -1;
    int alternativeIndex = -1;
    for (t = ulthreads+1; t < &ulthreads[MAXULTHREADS]; t++)
    {
      if (t->state == RUNNABLE && t != scheduler_thread && t->lastTime < oldest)
 8e6:	00000b97          	auipc	s7,0x0
 8ea:	72ab8b93          	addi	s7,s7,1834 # 1010 <scheduler_thread>
    int alternativeIndex = -1;
 8ee:	5afd                	li	s5,-1
    uint64 oldest = __INT64_MAX__;
 8f0:	001adb13          	srli	s6,s5,0x1
      if (t->state == RUNNABLE && t != scheduler_thread && t->lastTime < oldest)
 8f4:	4485                	li	s1,1
        oldest = t->lastTime;
        threadIndex = t->tid;
        threadAvailable = true;
      }

      if (t->state == YIELD){
 8f6:	4989                	li	s3,2
    for (t = ulthreads+1; t < &ulthreads[MAXULTHREADS]; t++)
 8f8:	00004917          	auipc	s2,0x4
 8fc:	c5890913          	addi	s2,s2,-936 # 4550 <ulthreads+0x3520>
        break;
      }
      
    }
    label : 
      struct ulthread *temp = current_thread;
 900:	00000a17          	auipc	s4,0x0
 904:	718a0a13          	addi	s4,s4,1816 # 1018 <current_thread>
 908:	a88d                	j	97a <firstComeFirstServe+0xac>
      if (t->state == RUNNABLE && t != scheduler_thread && t->lastTime < oldest)
 90a:	00f58963          	beq	a1,a5,91c <firstComeFirstServe+0x4e>
 90e:	6b98                	ld	a4,16(a5)
 910:	00c77663          	bgeu	a4,a2,91c <firstComeFirstServe+0x4e>
        threadIndex = t->tid;
 914:	0047a803          	lw	a6,4(a5)
        oldest = t->lastTime;
 918:	863a                	mv	a2,a4
        threadAvailable = true;
 91a:	8526                	mv	a0,s1
    for (t = ulthreads+1; t < &ulthreads[MAXULTHREADS]; t++)
 91c:	08878793          	addi	a5,a5,136
 920:	01278a63          	beq	a5,s2,934 <firstComeFirstServe+0x66>
      if (t->state == RUNNABLE && t != scheduler_thread && t->lastTime < oldest)
 924:	4398                	lw	a4,0(a5)
 926:	fe9702e3          	beq	a4,s1,90a <firstComeFirstServe+0x3c>
      if (t->state == YIELD){
 92a:	ff3719e3          	bne	a4,s3,91c <firstComeFirstServe+0x4e>
        t->state = RUNNABLE;
 92e:	c384                	sw	s1,0(a5)
        alternativeIndex = t->tid;
 930:	43d4                	lw	a3,4(a5)
 932:	b7ed                	j	91c <firstComeFirstServe+0x4e>
    if (!threadAvailable)
 934:	ed31                	bnez	a0,990 <firstComeFirstServe+0xc2>
      if(alternativeIndex > 0){
 936:	04d05f63          	blez	a3,994 <firstComeFirstServe+0xc6>
      struct ulthread *temp = current_thread;
 93a:	000a3c03          	ld	s8,0(s4)
      current_thread = &ulthreads[threadIndex];
 93e:	00469793          	slli	a5,a3,0x4
 942:	00d78733          	add	a4,a5,a3
 946:	070e                	slli	a4,a4,0x3
 948:	00000617          	auipc	a2,0x0
 94c:	6e860613          	addi	a2,a2,1768 # 1030 <ulthreads>
 950:	9732                	add	a4,a4,a2
 952:	00ea3023          	sd	a4,0(s4)
      printf("[*] ultschedule (next tid: %d), time = %d\n", get_current_tid());
 956:	434c                	lw	a1,4(a4)
 958:	00000517          	auipc	a0,0x0
 95c:	4d850513          	addi	a0,a0,1240 # e30 <digits+0x38>
 960:	00000097          	auipc	ra,0x0
 964:	d0c080e7          	jalr	-756(ra) # 66c <printf>
      ulthread_context_switch(&temp->context, &current_thread->context);
 968:	000a3583          	ld	a1,0(s4)
 96c:	05e1                	addi	a1,a1,24
 96e:	018c0513          	addi	a0,s8,24
 972:	00000097          	auipc	ra,0x0
 976:	378080e7          	jalr	888(ra) # cea <ulthread_context_switch>
      if (t->state == RUNNABLE && t != scheduler_thread && t->lastTime < oldest)
 97a:	000bb583          	ld	a1,0(s7)
    int alternativeIndex = -1;
 97e:	86d6                	mv	a3,s5
    int threadIndex = -1;
 980:	8856                	mv	a6,s5
    uint64 oldest = __INT64_MAX__;
 982:	865a                	mv	a2,s6
    bool threadAvailable = false;
 984:	4501                	li	a0,0
    for (t = ulthreads+1; t < &ulthreads[MAXULTHREADS]; t++)
 986:	00000797          	auipc	a5,0x0
 98a:	73278793          	addi	a5,a5,1842 # 10b8 <ulthreads+0x88>
 98e:	bf59                	j	924 <firstComeFirstServe+0x56>
    label : 
 990:	86c2                	mv	a3,a6
 992:	b765                	j	93a <firstComeFirstServe+0x6c>
  }
}
 994:	60a6                	ld	ra,72(sp)
 996:	6406                	ld	s0,64(sp)
 998:	74e2                	ld	s1,56(sp)
 99a:	7942                	ld	s2,48(sp)
 99c:	79a2                	ld	s3,40(sp)
 99e:	7a02                	ld	s4,32(sp)
 9a0:	6ae2                	ld	s5,24(sp)
 9a2:	6b42                	ld	s6,16(sp)
 9a4:	6ba2                	ld	s7,8(sp)
 9a6:	6c02                	ld	s8,0(sp)
 9a8:	6161                	addi	sp,sp,80
 9aa:	8082                	ret

00000000000009ac <priorityScheduling>:


void priorityScheduling(void)
{
 9ac:	715d                	addi	sp,sp,-80
 9ae:	e486                	sd	ra,72(sp)
 9b0:	e0a2                	sd	s0,64(sp)
 9b2:	fc26                	sd	s1,56(sp)
 9b4:	f84a                	sd	s2,48(sp)
 9b6:	f44e                	sd	s3,40(sp)
 9b8:	f052                	sd	s4,32(sp)
 9ba:	ec56                	sd	s5,24(sp)
 9bc:	e85a                	sd	s6,16(sp)
 9be:	e45e                	sd	s7,8(sp)
 9c0:	0880                	addi	s0,sp,80
    int maxPriority = -1;
    int threadIndex = -1;
    int alternativeIndex = -1;
    for (t = ulthreads+1; t < &ulthreads[MAXULTHREADS]; t++)
    {
      if (t->state == RUNNABLE && t != scheduler_thread && t->priority > maxPriority)
 9c2:	00000b17          	auipc	s6,0x0
 9c6:	64eb0b13          	addi	s6,s6,1614 # 1010 <scheduler_thread>
    int alternativeIndex = -1;
 9ca:	5a7d                	li	s4,-1
      if (t->state == RUNNABLE && t != scheduler_thread && t->priority > maxPriority)
 9cc:	4485                	li	s1,1
        // flag = true;

        // break; // switch to highest-priority thread and exit loop
      }

      if (t->state == YIELD){
 9ce:	4989                	li	s3,2
    for (t = ulthreads+1; t < &ulthreads[MAXULTHREADS]; t++)
 9d0:	00004917          	auipc	s2,0x4
 9d4:	b8090913          	addi	s2,s2,-1152 # 4550 <ulthreads+0x3520>
        break;
      }
      
    }
    label : 
      struct ulthread *temp = current_thread;
 9d8:	00000a97          	auipc	s5,0x0
 9dc:	640a8a93          	addi	s5,s5,1600 # 1018 <current_thread>
 9e0:	a88d                	j	a52 <priorityScheduling+0xa6>
      if (t->state == RUNNABLE && t != scheduler_thread && t->priority > maxPriority)
 9e2:	00f58963          	beq	a1,a5,9f4 <priorityScheduling+0x48>
 9e6:	47d8                	lw	a4,12(a5)
 9e8:	00e65663          	bge	a2,a4,9f4 <priorityScheduling+0x48>
        threadIndex = t->tid;
 9ec:	0047a803          	lw	a6,4(a5)
        maxPriority = t->priority;
 9f0:	863a                	mv	a2,a4
        threadAvailable = true;
 9f2:	8526                	mv	a0,s1
    for (t = ulthreads+1; t < &ulthreads[MAXULTHREADS]; t++)
 9f4:	08878793          	addi	a5,a5,136
 9f8:	01278a63          	beq	a5,s2,a0c <priorityScheduling+0x60>
      if (t->state == RUNNABLE && t != scheduler_thread && t->priority > maxPriority)
 9fc:	4398                	lw	a4,0(a5)
 9fe:	fe9702e3          	beq	a4,s1,9e2 <priorityScheduling+0x36>
      if (t->state == YIELD){
 a02:	ff3719e3          	bne	a4,s3,9f4 <priorityScheduling+0x48>
        t->state = RUNNABLE;
 a06:	c384                	sw	s1,0(a5)
        alternativeIndex = t->tid;
 a08:	43d4                	lw	a3,4(a5)
 a0a:	b7ed                	j	9f4 <priorityScheduling+0x48>
    if (!threadAvailable)
 a0c:	ed31                	bnez	a0,a68 <priorityScheduling+0xbc>
      if(alternativeIndex > 0){
 a0e:	04d05f63          	blez	a3,a6c <priorityScheduling+0xc0>
      struct ulthread *temp = current_thread;
 a12:	000abb83          	ld	s7,0(s5)
      current_thread = &ulthreads[threadIndex];
 a16:	00469793          	slli	a5,a3,0x4
 a1a:	00d78733          	add	a4,a5,a3
 a1e:	070e                	slli	a4,a4,0x3
 a20:	00000617          	auipc	a2,0x0
 a24:	61060613          	addi	a2,a2,1552 # 1030 <ulthreads>
 a28:	9732                	add	a4,a4,a2
 a2a:	00eab023          	sd	a4,0(s5)
      printf("[*] ultschedule (next tid: %d)\n", get_current_tid());
 a2e:	434c                	lw	a1,4(a4)
 a30:	00000517          	auipc	a0,0x0
 a34:	3e050513          	addi	a0,a0,992 # e10 <digits+0x18>
 a38:	00000097          	auipc	ra,0x0
 a3c:	c34080e7          	jalr	-972(ra) # 66c <printf>
      ulthread_context_switch(&temp->context, &current_thread->context);
 a40:	000ab583          	ld	a1,0(s5)
 a44:	05e1                	addi	a1,a1,24
 a46:	018b8513          	addi	a0,s7,24
 a4a:	00000097          	auipc	ra,0x0
 a4e:	2a0080e7          	jalr	672(ra) # cea <ulthread_context_switch>
      if (t->state == RUNNABLE && t != scheduler_thread && t->priority > maxPriority)
 a52:	000b3583          	ld	a1,0(s6)
    int alternativeIndex = -1;
 a56:	86d2                	mv	a3,s4
    int threadIndex = -1;
 a58:	8852                	mv	a6,s4
    int maxPriority = -1;
 a5a:	8652                	mv	a2,s4
    bool threadAvailable = false;
 a5c:	4501                	li	a0,0
    for (t = ulthreads+1; t < &ulthreads[MAXULTHREADS]; t++)
 a5e:	00000797          	auipc	a5,0x0
 a62:	65a78793          	addi	a5,a5,1626 # 10b8 <ulthreads+0x88>
 a66:	bf59                	j	9fc <priorityScheduling+0x50>
    label : 
 a68:	86c2                	mv	a3,a6
 a6a:	b765                	j	a12 <priorityScheduling+0x66>
  }
}
 a6c:	60a6                	ld	ra,72(sp)
 a6e:	6406                	ld	s0,64(sp)
 a70:	74e2                	ld	s1,56(sp)
 a72:	7942                	ld	s2,48(sp)
 a74:	79a2                	ld	s3,40(sp)
 a76:	7a02                	ld	s4,32(sp)
 a78:	6ae2                	ld	s5,24(sp)
 a7a:	6b42                	ld	s6,16(sp)
 a7c:	6ba2                	ld	s7,8(sp)
 a7e:	6161                	addi	sp,sp,80
 a80:	8082                	ret

0000000000000a82 <ulthread_init>:

/* Thread initialization */
void ulthread_init(int schedalgo)
{
 a82:	1141                	addi	sp,sp,-16
 a84:	e422                	sd	s0,8(sp)
 a86:	0800                	addi	s0,sp,16
  struct ulthread *t;
  int i;
  for (i = 0, t = ulthreads; t < &ulthreads[MAXULTHREADS]; t++, i++)
 a88:	4701                	li	a4,0
 a8a:	00000797          	auipc	a5,0x0
 a8e:	5a678793          	addi	a5,a5,1446 # 1030 <ulthreads>
 a92:	00004697          	auipc	a3,0x4
 a96:	abe68693          	addi	a3,a3,-1346 # 4550 <ulthreads+0x3520>
  {
    t->state = FREE;
 a9a:	0007a023          	sw	zero,0(a5)
    t->tid = i;
 a9e:	c3d8                	sw	a4,4(a5)
  for (i = 0, t = ulthreads; t < &ulthreads[MAXULTHREADS]; t++, i++)
 aa0:	08878793          	addi	a5,a5,136
 aa4:	2705                	addiw	a4,a4,1
 aa6:	fed79ae3          	bne	a5,a3,a9a <ulthread_init+0x18>
  }
  current_thread = &ulthreads[0];
 aaa:	00000797          	auipc	a5,0x0
 aae:	58678793          	addi	a5,a5,1414 # 1030 <ulthreads>
 ab2:	00000717          	auipc	a4,0x0
 ab6:	56f73323          	sd	a5,1382(a4) # 1018 <current_thread>
  scheduler_thread = &ulthreads[0];
 aba:	00000717          	auipc	a4,0x0
 abe:	54f73b23          	sd	a5,1366(a4) # 1010 <scheduler_thread>
  scheduler_thread->state = RUNNABLE;
 ac2:	4705                	li	a4,1
 ac4:	c398                	sw	a4,0(a5)
  t->state = FREE;
 ac6:	00004797          	auipc	a5,0x4
 aca:	a807a523          	sw	zero,-1398(a5) # 4550 <ulthreads+0x3520>
  algorithm = schedalgo;
 ace:	00000797          	auipc	a5,0x0
 ad2:	52a7ad23          	sw	a0,1338(a5) # 1008 <algorithm>
}
 ad6:	6422                	ld	s0,8(sp)
 ad8:	0141                	addi	sp,sp,16
 ada:	8082                	ret

0000000000000adc <ulthread_create>:

/* Thread creation */
bool ulthread_create(uint64 start, uint64 stack, uint64 args[], int priority)
{
 adc:	7179                	addi	sp,sp,-48
 ade:	f406                	sd	ra,40(sp)
 ae0:	f022                	sd	s0,32(sp)
 ae2:	ec26                	sd	s1,24(sp)
 ae4:	e84a                	sd	s2,16(sp)
 ae6:	e44e                	sd	s3,8(sp)
 ae8:	e052                	sd	s4,0(sp)
 aea:	1800                	addi	s0,sp,48
 aec:	89aa                	mv	s3,a0
 aee:	8a2e                	mv	s4,a1
 af0:	8932                	mv	s2,a2
  /* Please add thread-id instead of '0' here. */
  struct ulthread *t;
  bool flag = false;
  for (t = ulthreads; t < &ulthreads[MAXULTHREADS]; t++)
 af2:	00000497          	auipc	s1,0x0
 af6:	53e48493          	addi	s1,s1,1342 # 1030 <ulthreads>
 afa:	00004717          	auipc	a4,0x4
 afe:	a5670713          	addi	a4,a4,-1450 # 4550 <ulthreads+0x3520>
  {
    if (t->state == FREE)
 b02:	409c                	lw	a5,0(s1)
 b04:	cf89                	beqz	a5,b1e <ulthread_create+0x42>
  for (t = ulthreads; t < &ulthreads[MAXULTHREADS]; t++)
 b06:	08848493          	addi	s1,s1,136
 b0a:	fee49ce3          	bne	s1,a4,b02 <ulthread_create+0x26>
      break;
    }
  }
  if (!flag)
  {
    return false;
 b0e:	4501                	li	a0,0
 b10:	a871                	j	bac <ulthread_create+0xd0>
  t->sp = (int)(stack + USTACKSIZE); // set sp to the top of the stack
  t->state = RUNNABLE;
  t->priority = priority;

  if(algorithm==FCFS){
    t->lastTime = ctime();
 b12:	00000097          	auipc	ra,0x0
 b16:	88a080e7          	jalr	-1910(ra) # 39c <ctime>
 b1a:	e888                	sd	a0,16(s1)
 b1c:	a839                	j	b3a <ulthread_create+0x5e>
  t->sp = (int)(stack + USTACKSIZE); // set sp to the top of the stack
 b1e:	6785                	lui	a5,0x1
 b20:	014787bb          	addw	a5,a5,s4
 b24:	c49c                	sw	a5,8(s1)
  t->state = RUNNABLE;
 b26:	4785                	li	a5,1
 b28:	c09c                	sw	a5,0(s1)
  t->priority = priority;
 b2a:	c4d4                	sw	a3,12(s1)
  if(algorithm==FCFS){
 b2c:	00000717          	auipc	a4,0x0
 b30:	4dc72703          	lw	a4,1244(a4) # 1008 <algorithm>
 b34:	4789                	li	a5,2
 b36:	fcf70ee3          	beq	a4,a5,b12 <ulthread_create+0x36>
  }

  for (int argc = 0; argc < 6; argc++)
 b3a:	874a                	mv	a4,s2
 b3c:	03090693          	addi	a3,s2,48
  {
    t->sp -= 16;
 b40:	449c                	lw	a5,8(s1)
 b42:	37c1                	addiw	a5,a5,-16 # ff0 <digits+0x1f8>
 b44:	0007881b          	sext.w	a6,a5
 b48:	c49c                	sw	a5,8(s1)
    *(uint64 *)(t->sp) = (uint64)args[argc];
 b4a:	631c                	ld	a5,0(a4)
 b4c:	00f83023          	sd	a5,0(a6)
  for (int argc = 0; argc < 6; argc++)
 b50:	0721                	addi	a4,a4,8
 b52:	fed717e3          	bne	a4,a3,b40 <ulthread_create+0x64>
  }

  memset(&t->context, 0, sizeof(t->context));
 b56:	07000613          	li	a2,112
 b5a:	4581                	li	a1,0
 b5c:	01848513          	addi	a0,s1,24
 b60:	fffff097          	auipc	ra,0xfffff
 b64:	5a2080e7          	jalr	1442(ra) # 102 <memset>
  t->context.ra = start;
 b68:	0134bc23          	sd	s3,24(s1)
  t->context.sp = t->sp;
 b6c:	449c                	lw	a5,8(s1)
 b6e:	f09c                	sd	a5,32(s1)
  t->context.s0 = args[0];
 b70:	00093783          	ld	a5,0(s2)
 b74:	f49c                	sd	a5,40(s1)
  t->context.s1 = args[1];
 b76:	00893783          	ld	a5,8(s2)
 b7a:	f89c                	sd	a5,48(s1)
  t->context.s2 = args[2];
 b7c:	01093783          	ld	a5,16(s2)
 b80:	fc9c                	sd	a5,56(s1)
  t->context.s3 = args[3];
 b82:	01893783          	ld	a5,24(s2)
 b86:	e0bc                	sd	a5,64(s1)
  t->context.s4 = args[4];
 b88:	02093783          	ld	a5,32(s2)
 b8c:	e4bc                	sd	a5,72(s1)
  t->context.s5 = args[5];
 b8e:	02893783          	ld	a5,40(s2)
 b92:	e8bc                	sd	a5,80(s1)

  printf("[*] ultcreate(tid: %d, ra: %p, sp: %p)\n", t->tid, start, stack);
 b94:	86d2                	mv	a3,s4
 b96:	864e                	mv	a2,s3
 b98:	40cc                	lw	a1,4(s1)
 b9a:	00000517          	auipc	a0,0x0
 b9e:	2c650513          	addi	a0,a0,710 # e60 <digits+0x68>
 ba2:	00000097          	auipc	ra,0x0
 ba6:	aca080e7          	jalr	-1334(ra) # 66c <printf>
  return true;
 baa:	4505                	li	a0,1
}
 bac:	70a2                	ld	ra,40(sp)
 bae:	7402                	ld	s0,32(sp)
 bb0:	64e2                	ld	s1,24(sp)
 bb2:	6942                	ld	s2,16(sp)
 bb4:	69a2                	ld	s3,8(sp)
 bb6:	6a02                	ld	s4,0(sp)
 bb8:	6145                	addi	sp,sp,48
 bba:	8082                	ret

0000000000000bbc <ulthread_schedule>:

/* Thread scheduler */
void ulthread_schedule(void)
{
 bbc:	1141                	addi	sp,sp,-16
 bbe:	e406                	sd	ra,8(sp)
 bc0:	e022                	sd	s0,0(sp)
 bc2:	0800                	addi	s0,sp,16
  switch (algorithm)
 bc4:	00000797          	auipc	a5,0x0
 bc8:	4447a783          	lw	a5,1092(a5) # 1008 <algorithm>
 bcc:	4705                	li	a4,1
 bce:	02e78463          	beq	a5,a4,bf6 <ulthread_schedule+0x3a>
 bd2:	4709                	li	a4,2
 bd4:	00e78c63          	beq	a5,a4,bec <ulthread_schedule+0x30>
 bd8:	c789                	beqz	a5,be2 <ulthread_schedule+0x26>

  // Push argument strings, prepare rest of stack in ustack.

  // Switch between thread contexts
  // ulthread_context_switch(NULL, NULL);
}
 bda:	60a2                	ld	ra,8(sp)
 bdc:	6402                	ld	s0,0(sp)
 bde:	0141                	addi	sp,sp,16
 be0:	8082                	ret
    roundRobin();
 be2:	00000097          	auipc	ra,0x0
 be6:	c3e080e7          	jalr	-962(ra) # 820 <roundRobin>
    break;
 bea:	bfc5                	j	bda <ulthread_schedule+0x1e>
    firstComeFirstServe();
 bec:	00000097          	auipc	ra,0x0
 bf0:	ce2080e7          	jalr	-798(ra) # 8ce <firstComeFirstServe>
    break;
 bf4:	b7dd                	j	bda <ulthread_schedule+0x1e>
    priorityScheduling();
 bf6:	00000097          	auipc	ra,0x0
 bfa:	db6080e7          	jalr	-586(ra) # 9ac <priorityScheduling>
}
 bfe:	bff1                	j	bda <ulthread_schedule+0x1e>

0000000000000c00 <ulthread_yield>:

/* Yield CPU time to some other thread. */
void ulthread_yield(void)
{
 c00:	1101                	addi	sp,sp,-32
 c02:	ec06                	sd	ra,24(sp)
 c04:	e822                	sd	s0,16(sp)
 c06:	e426                	sd	s1,8(sp)
 c08:	e04a                	sd	s2,0(sp)
 c0a:	1000                	addi	s0,sp,32
  current_thread->state = YIELD;
 c0c:	00000797          	auipc	a5,0x0
 c10:	40c78793          	addi	a5,a5,1036 # 1018 <current_thread>
 c14:	6398                	ld	a4,0(a5)
 c16:	4909                	li	s2,2
 c18:	01272023          	sw	s2,0(a4)
  struct ulthread *temp = current_thread;
 c1c:	6384                	ld	s1,0(a5)
  printf("[*] ultyield(tid: %d)\n", current_thread->tid);
 c1e:	40cc                	lw	a1,4(s1)
 c20:	00000517          	auipc	a0,0x0
 c24:	26850513          	addi	a0,a0,616 # e88 <digits+0x90>
 c28:	00000097          	auipc	ra,0x0
 c2c:	a44080e7          	jalr	-1468(ra) # 66c <printf>
  if(algorithm==FCFS){
 c30:	00000797          	auipc	a5,0x0
 c34:	3d87a783          	lw	a5,984(a5) # 1008 <algorithm>
 c38:	03278763          	beq	a5,s2,c66 <ulthread_yield+0x66>
    current_thread->lastTime = ctime();
  }
  current_thread = scheduler_thread;
 c3c:	00000597          	auipc	a1,0x0
 c40:	3d45b583          	ld	a1,980(a1) # 1010 <scheduler_thread>
 c44:	00000797          	auipc	a5,0x0
 c48:	3cb7ba23          	sd	a1,980(a5) # 1018 <current_thread>
  
  ulthread_context_switch(&temp->context, &scheduler_thread->context);
 c4c:	05e1                	addi	a1,a1,24
 c4e:	01848513          	addi	a0,s1,24
 c52:	00000097          	auipc	ra,0x0
 c56:	098080e7          	jalr	152(ra) # cea <ulthread_context_switch>
  // ulthread_schedule();
}
 c5a:	60e2                	ld	ra,24(sp)
 c5c:	6442                	ld	s0,16(sp)
 c5e:	64a2                	ld	s1,8(sp)
 c60:	6902                	ld	s2,0(sp)
 c62:	6105                	addi	sp,sp,32
 c64:	8082                	ret
    current_thread->lastTime = ctime();
 c66:	fffff097          	auipc	ra,0xfffff
 c6a:	736080e7          	jalr	1846(ra) # 39c <ctime>
 c6e:	00000797          	auipc	a5,0x0
 c72:	3aa7b783          	ld	a5,938(a5) # 1018 <current_thread>
 c76:	eb88                	sd	a0,16(a5)
 c78:	b7d1                	j	c3c <ulthread_yield+0x3c>

0000000000000c7a <ulthread_destroy>:

/* Destroy thread */
void ulthread_destroy(void)
{
 c7a:	1101                	addi	sp,sp,-32
 c7c:	ec06                	sd	ra,24(sp)
 c7e:	e822                	sd	s0,16(sp)
 c80:	e426                	sd	s1,8(sp)
 c82:	e04a                	sd	s2,0(sp)
 c84:	1000                	addi	s0,sp,32
  memset(&current_thread->context, 0, sizeof(current_thread->context));
 c86:	00000497          	auipc	s1,0x0
 c8a:	39248493          	addi	s1,s1,914 # 1018 <current_thread>
 c8e:	6088                	ld	a0,0(s1)
 c90:	07000613          	li	a2,112
 c94:	4581                	li	a1,0
 c96:	0561                	addi	a0,a0,24
 c98:	fffff097          	auipc	ra,0xfffff
 c9c:	46a080e7          	jalr	1130(ra) # 102 <memset>
  current_thread->sp = 0;
 ca0:	609c                	ld	a5,0(s1)
 ca2:	0007a423          	sw	zero,8(a5)
  current_thread->priority = -1;
 ca6:	577d                	li	a4,-1
 ca8:	c7d8                	sw	a4,12(a5)
  current_thread->state = FREE;
 caa:	0007a023          	sw	zero,0(a5)

  struct ulthread *temp = current_thread;
 cae:	0004b903          	ld	s2,0(s1)

  printf("[*] ultdestroy(tid: %d)\n", get_current_tid());
 cb2:	00492583          	lw	a1,4(s2)
 cb6:	00000517          	auipc	a0,0x0
 cba:	1ea50513          	addi	a0,a0,490 # ea0 <digits+0xa8>
 cbe:	00000097          	auipc	ra,0x0
 cc2:	9ae080e7          	jalr	-1618(ra) # 66c <printf>
  current_thread = scheduler_thread;
 cc6:	00000597          	auipc	a1,0x0
 cca:	34a5b583          	ld	a1,842(a1) # 1010 <scheduler_thread>
 cce:	e08c                	sd	a1,0(s1)
  ulthread_context_switch(&temp->context, &scheduler_thread->context);
 cd0:	05e1                	addi	a1,a1,24
 cd2:	01890513          	addi	a0,s2,24
 cd6:	00000097          	auipc	ra,0x0
 cda:	014080e7          	jalr	20(ra) # cea <ulthread_context_switch>
}
 cde:	60e2                	ld	ra,24(sp)
 ce0:	6442                	ld	s0,16(sp)
 ce2:	64a2                	ld	s1,8(sp)
 ce4:	6902                	ld	s2,0(sp)
 ce6:	6105                	addi	sp,sp,32
 ce8:	8082                	ret

0000000000000cea <ulthread_context_switch>:
 cea:	00153023          	sd	ra,0(a0)
 cee:	00253423          	sd	sp,8(a0)
 cf2:	e900                	sd	s0,16(a0)
 cf4:	ed04                	sd	s1,24(a0)
 cf6:	03253023          	sd	s2,32(a0)
 cfa:	03353423          	sd	s3,40(a0)
 cfe:	03453823          	sd	s4,48(a0)
 d02:	03553c23          	sd	s5,56(a0)
 d06:	05653023          	sd	s6,64(a0)
 d0a:	05753423          	sd	s7,72(a0)
 d0e:	05853823          	sd	s8,80(a0)
 d12:	05953c23          	sd	s9,88(a0)
 d16:	07a53023          	sd	s10,96(a0)
 d1a:	07b53423          	sd	s11,104(a0)
 d1e:	0005b083          	ld	ra,0(a1)
 d22:	0085b103          	ld	sp,8(a1)
 d26:	6980                	ld	s0,16(a1)
 d28:	6d84                	ld	s1,24(a1)
 d2a:	0205b903          	ld	s2,32(a1)
 d2e:	0285b983          	ld	s3,40(a1)
 d32:	0305ba03          	ld	s4,48(a1)
 d36:	0385ba83          	ld	s5,56(a1)
 d3a:	0405bb03          	ld	s6,64(a1)
 d3e:	0485bb83          	ld	s7,72(a1)
 d42:	0505bc03          	ld	s8,80(a1)
 d46:	0585bc83          	ld	s9,88(a1)
 d4a:	0605bd03          	ld	s10,96(a1)
 d4e:	0685bd83          	ld	s11,104(a1)
 d52:	6546                	ld	a0,80(sp)
 d54:	6586                	ld	a1,64(sp)
 d56:	7642                	ld	a2,48(sp)
 d58:	7682                	ld	a3,32(sp)
 d5a:	6742                	ld	a4,16(sp)
 d5c:	6782                	ld	a5,0(sp)
 d5e:	8082                	ret
