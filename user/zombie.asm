
user/_zombie:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "kernel/stat.h"
#include "user/user.h"

int
main(void)
{
   0:	1141                	addi	sp,sp,-16
   2:	e406                	sd	ra,8(sp)
   4:	e022                	sd	s0,0(sp)
   6:	0800                	addi	s0,sp,16
  if(fork() > 0)
   8:	00000097          	auipc	ra,0x0
   c:	2a0080e7          	jalr	672(ra) # 2a8 <fork>
  10:	00a04763          	bgtz	a0,1e <main+0x1e>
    sleep(5);  // Let child exit before parent.
  exit(0);
  14:	4501                	li	a0,0
  16:	00000097          	auipc	ra,0x0
  1a:	29a080e7          	jalr	666(ra) # 2b0 <exit>
    sleep(5);  // Let child exit before parent.
  1e:	4515                	li	a0,5
  20:	00000097          	auipc	ra,0x0
  24:	320080e7          	jalr	800(ra) # 340 <sleep>
  28:	b7f5                	j	14 <main+0x14>

000000000000002a <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
  2a:	1141                	addi	sp,sp,-16
  2c:	e406                	sd	ra,8(sp)
  2e:	e022                	sd	s0,0(sp)
  30:	0800                	addi	s0,sp,16
  extern int main();
  main();
  32:	00000097          	auipc	ra,0x0
  36:	fce080e7          	jalr	-50(ra) # 0 <main>
  exit(0);
  3a:	4501                	li	a0,0
  3c:	00000097          	auipc	ra,0x0
  40:	274080e7          	jalr	628(ra) # 2b0 <exit>

0000000000000044 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
  44:	1141                	addi	sp,sp,-16
  46:	e422                	sd	s0,8(sp)
  48:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  4a:	87aa                	mv	a5,a0
  4c:	0585                	addi	a1,a1,1
  4e:	0785                	addi	a5,a5,1
  50:	fff5c703          	lbu	a4,-1(a1)
  54:	fee78fa3          	sb	a4,-1(a5)
  58:	fb75                	bnez	a4,4c <strcpy+0x8>
    ;
  return os;
}
  5a:	6422                	ld	s0,8(sp)
  5c:	0141                	addi	sp,sp,16
  5e:	8082                	ret

0000000000000060 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  60:	1141                	addi	sp,sp,-16
  62:	e422                	sd	s0,8(sp)
  64:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
  66:	00054783          	lbu	a5,0(a0)
  6a:	cb91                	beqz	a5,7e <strcmp+0x1e>
  6c:	0005c703          	lbu	a4,0(a1)
  70:	00f71763          	bne	a4,a5,7e <strcmp+0x1e>
    p++, q++;
  74:	0505                	addi	a0,a0,1
  76:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
  78:	00054783          	lbu	a5,0(a0)
  7c:	fbe5                	bnez	a5,6c <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
  7e:	0005c503          	lbu	a0,0(a1)
}
  82:	40a7853b          	subw	a0,a5,a0
  86:	6422                	ld	s0,8(sp)
  88:	0141                	addi	sp,sp,16
  8a:	8082                	ret

000000000000008c <strlen>:

uint
strlen(const char *s)
{
  8c:	1141                	addi	sp,sp,-16
  8e:	e422                	sd	s0,8(sp)
  90:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
  92:	00054783          	lbu	a5,0(a0)
  96:	cf91                	beqz	a5,b2 <strlen+0x26>
  98:	0505                	addi	a0,a0,1
  9a:	87aa                	mv	a5,a0
  9c:	86be                	mv	a3,a5
  9e:	0785                	addi	a5,a5,1
  a0:	fff7c703          	lbu	a4,-1(a5)
  a4:	ff65                	bnez	a4,9c <strlen+0x10>
  a6:	40a6853b          	subw	a0,a3,a0
  aa:	2505                	addiw	a0,a0,1
    ;
  return n;
}
  ac:	6422                	ld	s0,8(sp)
  ae:	0141                	addi	sp,sp,16
  b0:	8082                	ret
  for(n = 0; s[n]; n++)
  b2:	4501                	li	a0,0
  b4:	bfe5                	j	ac <strlen+0x20>

00000000000000b6 <memset>:

void*
memset(void *dst, int c, uint n)
{
  b6:	1141                	addi	sp,sp,-16
  b8:	e422                	sd	s0,8(sp)
  ba:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
  bc:	ca19                	beqz	a2,d2 <memset+0x1c>
  be:	87aa                	mv	a5,a0
  c0:	1602                	slli	a2,a2,0x20
  c2:	9201                	srli	a2,a2,0x20
  c4:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
  c8:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
  cc:	0785                	addi	a5,a5,1
  ce:	fee79de3          	bne	a5,a4,c8 <memset+0x12>
  }
  return dst;
}
  d2:	6422                	ld	s0,8(sp)
  d4:	0141                	addi	sp,sp,16
  d6:	8082                	ret

00000000000000d8 <strchr>:

char*
strchr(const char *s, char c)
{
  d8:	1141                	addi	sp,sp,-16
  da:	e422                	sd	s0,8(sp)
  dc:	0800                	addi	s0,sp,16
  for(; *s; s++)
  de:	00054783          	lbu	a5,0(a0)
  e2:	cb99                	beqz	a5,f8 <strchr+0x20>
    if(*s == c)
  e4:	00f58763          	beq	a1,a5,f2 <strchr+0x1a>
  for(; *s; s++)
  e8:	0505                	addi	a0,a0,1
  ea:	00054783          	lbu	a5,0(a0)
  ee:	fbfd                	bnez	a5,e4 <strchr+0xc>
      return (char*)s;
  return 0;
  f0:	4501                	li	a0,0
}
  f2:	6422                	ld	s0,8(sp)
  f4:	0141                	addi	sp,sp,16
  f6:	8082                	ret
  return 0;
  f8:	4501                	li	a0,0
  fa:	bfe5                	j	f2 <strchr+0x1a>

00000000000000fc <gets>:

char*
gets(char *buf, int max)
{
  fc:	711d                	addi	sp,sp,-96
  fe:	ec86                	sd	ra,88(sp)
 100:	e8a2                	sd	s0,80(sp)
 102:	e4a6                	sd	s1,72(sp)
 104:	e0ca                	sd	s2,64(sp)
 106:	fc4e                	sd	s3,56(sp)
 108:	f852                	sd	s4,48(sp)
 10a:	f456                	sd	s5,40(sp)
 10c:	f05a                	sd	s6,32(sp)
 10e:	ec5e                	sd	s7,24(sp)
 110:	1080                	addi	s0,sp,96
 112:	8baa                	mv	s7,a0
 114:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 116:	892a                	mv	s2,a0
 118:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 11a:	4aa9                	li	s5,10
 11c:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 11e:	89a6                	mv	s3,s1
 120:	2485                	addiw	s1,s1,1
 122:	0344d863          	bge	s1,s4,152 <gets+0x56>
    cc = read(0, &c, 1);
 126:	4605                	li	a2,1
 128:	faf40593          	addi	a1,s0,-81
 12c:	4501                	li	a0,0
 12e:	00000097          	auipc	ra,0x0
 132:	19a080e7          	jalr	410(ra) # 2c8 <read>
    if(cc < 1)
 136:	00a05e63          	blez	a0,152 <gets+0x56>
    buf[i++] = c;
 13a:	faf44783          	lbu	a5,-81(s0)
 13e:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 142:	01578763          	beq	a5,s5,150 <gets+0x54>
 146:	0905                	addi	s2,s2,1
 148:	fd679be3          	bne	a5,s6,11e <gets+0x22>
  for(i=0; i+1 < max; ){
 14c:	89a6                	mv	s3,s1
 14e:	a011                	j	152 <gets+0x56>
 150:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 152:	99de                	add	s3,s3,s7
 154:	00098023          	sb	zero,0(s3)
  return buf;
}
 158:	855e                	mv	a0,s7
 15a:	60e6                	ld	ra,88(sp)
 15c:	6446                	ld	s0,80(sp)
 15e:	64a6                	ld	s1,72(sp)
 160:	6906                	ld	s2,64(sp)
 162:	79e2                	ld	s3,56(sp)
 164:	7a42                	ld	s4,48(sp)
 166:	7aa2                	ld	s5,40(sp)
 168:	7b02                	ld	s6,32(sp)
 16a:	6be2                	ld	s7,24(sp)
 16c:	6125                	addi	sp,sp,96
 16e:	8082                	ret

0000000000000170 <stat>:

int
stat(const char *n, struct stat *st)
{
 170:	1101                	addi	sp,sp,-32
 172:	ec06                	sd	ra,24(sp)
 174:	e822                	sd	s0,16(sp)
 176:	e426                	sd	s1,8(sp)
 178:	e04a                	sd	s2,0(sp)
 17a:	1000                	addi	s0,sp,32
 17c:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 17e:	4581                	li	a1,0
 180:	00000097          	auipc	ra,0x0
 184:	170080e7          	jalr	368(ra) # 2f0 <open>
  if(fd < 0)
 188:	02054563          	bltz	a0,1b2 <stat+0x42>
 18c:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 18e:	85ca                	mv	a1,s2
 190:	00000097          	auipc	ra,0x0
 194:	178080e7          	jalr	376(ra) # 308 <fstat>
 198:	892a                	mv	s2,a0
  close(fd);
 19a:	8526                	mv	a0,s1
 19c:	00000097          	auipc	ra,0x0
 1a0:	13c080e7          	jalr	316(ra) # 2d8 <close>
  return r;
}
 1a4:	854a                	mv	a0,s2
 1a6:	60e2                	ld	ra,24(sp)
 1a8:	6442                	ld	s0,16(sp)
 1aa:	64a2                	ld	s1,8(sp)
 1ac:	6902                	ld	s2,0(sp)
 1ae:	6105                	addi	sp,sp,32
 1b0:	8082                	ret
    return -1;
 1b2:	597d                	li	s2,-1
 1b4:	bfc5                	j	1a4 <stat+0x34>

00000000000001b6 <atoi>:

int
atoi(const char *s)
{
 1b6:	1141                	addi	sp,sp,-16
 1b8:	e422                	sd	s0,8(sp)
 1ba:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 1bc:	00054683          	lbu	a3,0(a0)
 1c0:	fd06879b          	addiw	a5,a3,-48
 1c4:	0ff7f793          	zext.b	a5,a5
 1c8:	4625                	li	a2,9
 1ca:	02f66863          	bltu	a2,a5,1fa <atoi+0x44>
 1ce:	872a                	mv	a4,a0
  n = 0;
 1d0:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 1d2:	0705                	addi	a4,a4,1
 1d4:	0025179b          	slliw	a5,a0,0x2
 1d8:	9fa9                	addw	a5,a5,a0
 1da:	0017979b          	slliw	a5,a5,0x1
 1de:	9fb5                	addw	a5,a5,a3
 1e0:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 1e4:	00074683          	lbu	a3,0(a4)
 1e8:	fd06879b          	addiw	a5,a3,-48
 1ec:	0ff7f793          	zext.b	a5,a5
 1f0:	fef671e3          	bgeu	a2,a5,1d2 <atoi+0x1c>
  return n;
}
 1f4:	6422                	ld	s0,8(sp)
 1f6:	0141                	addi	sp,sp,16
 1f8:	8082                	ret
  n = 0;
 1fa:	4501                	li	a0,0
 1fc:	bfe5                	j	1f4 <atoi+0x3e>

00000000000001fe <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 1fe:	1141                	addi	sp,sp,-16
 200:	e422                	sd	s0,8(sp)
 202:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 204:	02b57463          	bgeu	a0,a1,22c <memmove+0x2e>
    while(n-- > 0)
 208:	00c05f63          	blez	a2,226 <memmove+0x28>
 20c:	1602                	slli	a2,a2,0x20
 20e:	9201                	srli	a2,a2,0x20
 210:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 214:	872a                	mv	a4,a0
      *dst++ = *src++;
 216:	0585                	addi	a1,a1,1
 218:	0705                	addi	a4,a4,1
 21a:	fff5c683          	lbu	a3,-1(a1)
 21e:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 222:	fee79ae3          	bne	a5,a4,216 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 226:	6422                	ld	s0,8(sp)
 228:	0141                	addi	sp,sp,16
 22a:	8082                	ret
    dst += n;
 22c:	00c50733          	add	a4,a0,a2
    src += n;
 230:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 232:	fec05ae3          	blez	a2,226 <memmove+0x28>
 236:	fff6079b          	addiw	a5,a2,-1
 23a:	1782                	slli	a5,a5,0x20
 23c:	9381                	srli	a5,a5,0x20
 23e:	fff7c793          	not	a5,a5
 242:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 244:	15fd                	addi	a1,a1,-1
 246:	177d                	addi	a4,a4,-1
 248:	0005c683          	lbu	a3,0(a1)
 24c:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 250:	fee79ae3          	bne	a5,a4,244 <memmove+0x46>
 254:	bfc9                	j	226 <memmove+0x28>

0000000000000256 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 256:	1141                	addi	sp,sp,-16
 258:	e422                	sd	s0,8(sp)
 25a:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 25c:	ca05                	beqz	a2,28c <memcmp+0x36>
 25e:	fff6069b          	addiw	a3,a2,-1
 262:	1682                	slli	a3,a3,0x20
 264:	9281                	srli	a3,a3,0x20
 266:	0685                	addi	a3,a3,1
 268:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 26a:	00054783          	lbu	a5,0(a0)
 26e:	0005c703          	lbu	a4,0(a1)
 272:	00e79863          	bne	a5,a4,282 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 276:	0505                	addi	a0,a0,1
    p2++;
 278:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 27a:	fed518e3          	bne	a0,a3,26a <memcmp+0x14>
  }
  return 0;
 27e:	4501                	li	a0,0
 280:	a019                	j	286 <memcmp+0x30>
      return *p1 - *p2;
 282:	40e7853b          	subw	a0,a5,a4
}
 286:	6422                	ld	s0,8(sp)
 288:	0141                	addi	sp,sp,16
 28a:	8082                	ret
  return 0;
 28c:	4501                	li	a0,0
 28e:	bfe5                	j	286 <memcmp+0x30>

0000000000000290 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 290:	1141                	addi	sp,sp,-16
 292:	e406                	sd	ra,8(sp)
 294:	e022                	sd	s0,0(sp)
 296:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 298:	00000097          	auipc	ra,0x0
 29c:	f66080e7          	jalr	-154(ra) # 1fe <memmove>
}
 2a0:	60a2                	ld	ra,8(sp)
 2a2:	6402                	ld	s0,0(sp)
 2a4:	0141                	addi	sp,sp,16
 2a6:	8082                	ret

00000000000002a8 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 2a8:	4885                	li	a7,1
 ecall
 2aa:	00000073          	ecall
 ret
 2ae:	8082                	ret

00000000000002b0 <exit>:
.global exit
exit:
 li a7, SYS_exit
 2b0:	4889                	li	a7,2
 ecall
 2b2:	00000073          	ecall
 ret
 2b6:	8082                	ret

00000000000002b8 <wait>:
.global wait
wait:
 li a7, SYS_wait
 2b8:	488d                	li	a7,3
 ecall
 2ba:	00000073          	ecall
 ret
 2be:	8082                	ret

00000000000002c0 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 2c0:	4891                	li	a7,4
 ecall
 2c2:	00000073          	ecall
 ret
 2c6:	8082                	ret

00000000000002c8 <read>:
.global read
read:
 li a7, SYS_read
 2c8:	4895                	li	a7,5
 ecall
 2ca:	00000073          	ecall
 ret
 2ce:	8082                	ret

00000000000002d0 <write>:
.global write
write:
 li a7, SYS_write
 2d0:	48c1                	li	a7,16
 ecall
 2d2:	00000073          	ecall
 ret
 2d6:	8082                	ret

00000000000002d8 <close>:
.global close
close:
 li a7, SYS_close
 2d8:	48d5                	li	a7,21
 ecall
 2da:	00000073          	ecall
 ret
 2de:	8082                	ret

00000000000002e0 <kill>:
.global kill
kill:
 li a7, SYS_kill
 2e0:	4899                	li	a7,6
 ecall
 2e2:	00000073          	ecall
 ret
 2e6:	8082                	ret

00000000000002e8 <exec>:
.global exec
exec:
 li a7, SYS_exec
 2e8:	489d                	li	a7,7
 ecall
 2ea:	00000073          	ecall
 ret
 2ee:	8082                	ret

00000000000002f0 <open>:
.global open
open:
 li a7, SYS_open
 2f0:	48bd                	li	a7,15
 ecall
 2f2:	00000073          	ecall
 ret
 2f6:	8082                	ret

00000000000002f8 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 2f8:	48c5                	li	a7,17
 ecall
 2fa:	00000073          	ecall
 ret
 2fe:	8082                	ret

0000000000000300 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 300:	48c9                	li	a7,18
 ecall
 302:	00000073          	ecall
 ret
 306:	8082                	ret

0000000000000308 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 308:	48a1                	li	a7,8
 ecall
 30a:	00000073          	ecall
 ret
 30e:	8082                	ret

0000000000000310 <link>:
.global link
link:
 li a7, SYS_link
 310:	48cd                	li	a7,19
 ecall
 312:	00000073          	ecall
 ret
 316:	8082                	ret

0000000000000318 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 318:	48d1                	li	a7,20
 ecall
 31a:	00000073          	ecall
 ret
 31e:	8082                	ret

0000000000000320 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 320:	48a5                	li	a7,9
 ecall
 322:	00000073          	ecall
 ret
 326:	8082                	ret

0000000000000328 <dup>:
.global dup
dup:
 li a7, SYS_dup
 328:	48a9                	li	a7,10
 ecall
 32a:	00000073          	ecall
 ret
 32e:	8082                	ret

0000000000000330 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 330:	48ad                	li	a7,11
 ecall
 332:	00000073          	ecall
 ret
 336:	8082                	ret

0000000000000338 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 338:	48b1                	li	a7,12
 ecall
 33a:	00000073          	ecall
 ret
 33e:	8082                	ret

0000000000000340 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 340:	48b5                	li	a7,13
 ecall
 342:	00000073          	ecall
 ret
 346:	8082                	ret

0000000000000348 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 348:	48b9                	li	a7,14
 ecall
 34a:	00000073          	ecall
 ret
 34e:	8082                	ret

0000000000000350 <ctime>:
.global ctime
ctime:
 li a7, SYS_ctime
 350:	48d9                	li	a7,22
 ecall
 352:	00000073          	ecall
 ret
 356:	8082                	ret

0000000000000358 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 358:	1101                	addi	sp,sp,-32
 35a:	ec06                	sd	ra,24(sp)
 35c:	e822                	sd	s0,16(sp)
 35e:	1000                	addi	s0,sp,32
 360:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 364:	4605                	li	a2,1
 366:	fef40593          	addi	a1,s0,-17
 36a:	00000097          	auipc	ra,0x0
 36e:	f66080e7          	jalr	-154(ra) # 2d0 <write>
}
 372:	60e2                	ld	ra,24(sp)
 374:	6442                	ld	s0,16(sp)
 376:	6105                	addi	sp,sp,32
 378:	8082                	ret

000000000000037a <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 37a:	7139                	addi	sp,sp,-64
 37c:	fc06                	sd	ra,56(sp)
 37e:	f822                	sd	s0,48(sp)
 380:	f426                	sd	s1,40(sp)
 382:	f04a                	sd	s2,32(sp)
 384:	ec4e                	sd	s3,24(sp)
 386:	0080                	addi	s0,sp,64
 388:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 38a:	c299                	beqz	a3,390 <printint+0x16>
 38c:	0805c963          	bltz	a1,41e <printint+0xa4>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 390:	2581                	sext.w	a1,a1
  neg = 0;
 392:	4881                	li	a7,0
 394:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 398:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 39a:	2601                	sext.w	a2,a2
 39c:	00001517          	auipc	a0,0x1
 3a0:	9e450513          	addi	a0,a0,-1564 # d80 <digits>
 3a4:	883a                	mv	a6,a4
 3a6:	2705                	addiw	a4,a4,1
 3a8:	02c5f7bb          	remuw	a5,a1,a2
 3ac:	1782                	slli	a5,a5,0x20
 3ae:	9381                	srli	a5,a5,0x20
 3b0:	97aa                	add	a5,a5,a0
 3b2:	0007c783          	lbu	a5,0(a5)
 3b6:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 3ba:	0005879b          	sext.w	a5,a1
 3be:	02c5d5bb          	divuw	a1,a1,a2
 3c2:	0685                	addi	a3,a3,1
 3c4:	fec7f0e3          	bgeu	a5,a2,3a4 <printint+0x2a>
  if(neg)
 3c8:	00088c63          	beqz	a7,3e0 <printint+0x66>
    buf[i++] = '-';
 3cc:	fd070793          	addi	a5,a4,-48
 3d0:	00878733          	add	a4,a5,s0
 3d4:	02d00793          	li	a5,45
 3d8:	fef70823          	sb	a5,-16(a4)
 3dc:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 3e0:	02e05863          	blez	a4,410 <printint+0x96>
 3e4:	fc040793          	addi	a5,s0,-64
 3e8:	00e78933          	add	s2,a5,a4
 3ec:	fff78993          	addi	s3,a5,-1
 3f0:	99ba                	add	s3,s3,a4
 3f2:	377d                	addiw	a4,a4,-1
 3f4:	1702                	slli	a4,a4,0x20
 3f6:	9301                	srli	a4,a4,0x20
 3f8:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 3fc:	fff94583          	lbu	a1,-1(s2)
 400:	8526                	mv	a0,s1
 402:	00000097          	auipc	ra,0x0
 406:	f56080e7          	jalr	-170(ra) # 358 <putc>
  while(--i >= 0)
 40a:	197d                	addi	s2,s2,-1
 40c:	ff3918e3          	bne	s2,s3,3fc <printint+0x82>
}
 410:	70e2                	ld	ra,56(sp)
 412:	7442                	ld	s0,48(sp)
 414:	74a2                	ld	s1,40(sp)
 416:	7902                	ld	s2,32(sp)
 418:	69e2                	ld	s3,24(sp)
 41a:	6121                	addi	sp,sp,64
 41c:	8082                	ret
    x = -xx;
 41e:	40b005bb          	negw	a1,a1
    neg = 1;
 422:	4885                	li	a7,1
    x = -xx;
 424:	bf85                	j	394 <printint+0x1a>

0000000000000426 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 426:	715d                	addi	sp,sp,-80
 428:	e486                	sd	ra,72(sp)
 42a:	e0a2                	sd	s0,64(sp)
 42c:	fc26                	sd	s1,56(sp)
 42e:	f84a                	sd	s2,48(sp)
 430:	f44e                	sd	s3,40(sp)
 432:	f052                	sd	s4,32(sp)
 434:	ec56                	sd	s5,24(sp)
 436:	e85a                	sd	s6,16(sp)
 438:	e45e                	sd	s7,8(sp)
 43a:	e062                	sd	s8,0(sp)
 43c:	0880                	addi	s0,sp,80
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 43e:	0005c903          	lbu	s2,0(a1)
 442:	18090c63          	beqz	s2,5da <vprintf+0x1b4>
 446:	8aaa                	mv	s5,a0
 448:	8bb2                	mv	s7,a2
 44a:	00158493          	addi	s1,a1,1
  state = 0;
 44e:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 450:	02500a13          	li	s4,37
 454:	4b55                	li	s6,21
 456:	a839                	j	474 <vprintf+0x4e>
        putc(fd, c);
 458:	85ca                	mv	a1,s2
 45a:	8556                	mv	a0,s5
 45c:	00000097          	auipc	ra,0x0
 460:	efc080e7          	jalr	-260(ra) # 358 <putc>
 464:	a019                	j	46a <vprintf+0x44>
    } else if(state == '%'){
 466:	01498d63          	beq	s3,s4,480 <vprintf+0x5a>
  for(i = 0; fmt[i]; i++){
 46a:	0485                	addi	s1,s1,1
 46c:	fff4c903          	lbu	s2,-1(s1)
 470:	16090563          	beqz	s2,5da <vprintf+0x1b4>
    if(state == 0){
 474:	fe0999e3          	bnez	s3,466 <vprintf+0x40>
      if(c == '%'){
 478:	ff4910e3          	bne	s2,s4,458 <vprintf+0x32>
        state = '%';
 47c:	89d2                	mv	s3,s4
 47e:	b7f5                	j	46a <vprintf+0x44>
      if(c == 'd'){
 480:	13490263          	beq	s2,s4,5a4 <vprintf+0x17e>
 484:	f9d9079b          	addiw	a5,s2,-99
 488:	0ff7f793          	zext.b	a5,a5
 48c:	12fb6563          	bltu	s6,a5,5b6 <vprintf+0x190>
 490:	f9d9079b          	addiw	a5,s2,-99
 494:	0ff7f713          	zext.b	a4,a5
 498:	10eb6f63          	bltu	s6,a4,5b6 <vprintf+0x190>
 49c:	00271793          	slli	a5,a4,0x2
 4a0:	00001717          	auipc	a4,0x1
 4a4:	88870713          	addi	a4,a4,-1912 # d28 <ulthread_context_switch+0x8a>
 4a8:	97ba                	add	a5,a5,a4
 4aa:	439c                	lw	a5,0(a5)
 4ac:	97ba                	add	a5,a5,a4
 4ae:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
 4b0:	008b8913          	addi	s2,s7,8
 4b4:	4685                	li	a3,1
 4b6:	4629                	li	a2,10
 4b8:	000ba583          	lw	a1,0(s7)
 4bc:	8556                	mv	a0,s5
 4be:	00000097          	auipc	ra,0x0
 4c2:	ebc080e7          	jalr	-324(ra) # 37a <printint>
 4c6:	8bca                	mv	s7,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 4c8:	4981                	li	s3,0
 4ca:	b745                	j	46a <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 4cc:	008b8913          	addi	s2,s7,8
 4d0:	4681                	li	a3,0
 4d2:	4629                	li	a2,10
 4d4:	000ba583          	lw	a1,0(s7)
 4d8:	8556                	mv	a0,s5
 4da:	00000097          	auipc	ra,0x0
 4de:	ea0080e7          	jalr	-352(ra) # 37a <printint>
 4e2:	8bca                	mv	s7,s2
      state = 0;
 4e4:	4981                	li	s3,0
 4e6:	b751                	j	46a <vprintf+0x44>
        printint(fd, va_arg(ap, int), 16, 0);
 4e8:	008b8913          	addi	s2,s7,8
 4ec:	4681                	li	a3,0
 4ee:	4641                	li	a2,16
 4f0:	000ba583          	lw	a1,0(s7)
 4f4:	8556                	mv	a0,s5
 4f6:	00000097          	auipc	ra,0x0
 4fa:	e84080e7          	jalr	-380(ra) # 37a <printint>
 4fe:	8bca                	mv	s7,s2
      state = 0;
 500:	4981                	li	s3,0
 502:	b7a5                	j	46a <vprintf+0x44>
        printptr(fd, va_arg(ap, uint64));
 504:	008b8c13          	addi	s8,s7,8
 508:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 50c:	03000593          	li	a1,48
 510:	8556                	mv	a0,s5
 512:	00000097          	auipc	ra,0x0
 516:	e46080e7          	jalr	-442(ra) # 358 <putc>
  putc(fd, 'x');
 51a:	07800593          	li	a1,120
 51e:	8556                	mv	a0,s5
 520:	00000097          	auipc	ra,0x0
 524:	e38080e7          	jalr	-456(ra) # 358 <putc>
 528:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 52a:	00001b97          	auipc	s7,0x1
 52e:	856b8b93          	addi	s7,s7,-1962 # d80 <digits>
 532:	03c9d793          	srli	a5,s3,0x3c
 536:	97de                	add	a5,a5,s7
 538:	0007c583          	lbu	a1,0(a5)
 53c:	8556                	mv	a0,s5
 53e:	00000097          	auipc	ra,0x0
 542:	e1a080e7          	jalr	-486(ra) # 358 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 546:	0992                	slli	s3,s3,0x4
 548:	397d                	addiw	s2,s2,-1
 54a:	fe0914e3          	bnez	s2,532 <vprintf+0x10c>
        printptr(fd, va_arg(ap, uint64));
 54e:	8be2                	mv	s7,s8
      state = 0;
 550:	4981                	li	s3,0
 552:	bf21                	j	46a <vprintf+0x44>
        s = va_arg(ap, char*);
 554:	008b8993          	addi	s3,s7,8
 558:	000bb903          	ld	s2,0(s7)
        if(s == 0)
 55c:	02090163          	beqz	s2,57e <vprintf+0x158>
        while(*s != 0){
 560:	00094583          	lbu	a1,0(s2)
 564:	c9a5                	beqz	a1,5d4 <vprintf+0x1ae>
          putc(fd, *s);
 566:	8556                	mv	a0,s5
 568:	00000097          	auipc	ra,0x0
 56c:	df0080e7          	jalr	-528(ra) # 358 <putc>
          s++;
 570:	0905                	addi	s2,s2,1
        while(*s != 0){
 572:	00094583          	lbu	a1,0(s2)
 576:	f9e5                	bnez	a1,566 <vprintf+0x140>
        s = va_arg(ap, char*);
 578:	8bce                	mv	s7,s3
      state = 0;
 57a:	4981                	li	s3,0
 57c:	b5fd                	j	46a <vprintf+0x44>
          s = "(null)";
 57e:	00000917          	auipc	s2,0x0
 582:	7a290913          	addi	s2,s2,1954 # d20 <ulthread_context_switch+0x82>
        while(*s != 0){
 586:	02800593          	li	a1,40
 58a:	bff1                	j	566 <vprintf+0x140>
        putc(fd, va_arg(ap, uint));
 58c:	008b8913          	addi	s2,s7,8
 590:	000bc583          	lbu	a1,0(s7)
 594:	8556                	mv	a0,s5
 596:	00000097          	auipc	ra,0x0
 59a:	dc2080e7          	jalr	-574(ra) # 358 <putc>
 59e:	8bca                	mv	s7,s2
      state = 0;
 5a0:	4981                	li	s3,0
 5a2:	b5e1                	j	46a <vprintf+0x44>
        putc(fd, c);
 5a4:	02500593          	li	a1,37
 5a8:	8556                	mv	a0,s5
 5aa:	00000097          	auipc	ra,0x0
 5ae:	dae080e7          	jalr	-594(ra) # 358 <putc>
      state = 0;
 5b2:	4981                	li	s3,0
 5b4:	bd5d                	j	46a <vprintf+0x44>
        putc(fd, '%');
 5b6:	02500593          	li	a1,37
 5ba:	8556                	mv	a0,s5
 5bc:	00000097          	auipc	ra,0x0
 5c0:	d9c080e7          	jalr	-612(ra) # 358 <putc>
        putc(fd, c);
 5c4:	85ca                	mv	a1,s2
 5c6:	8556                	mv	a0,s5
 5c8:	00000097          	auipc	ra,0x0
 5cc:	d90080e7          	jalr	-624(ra) # 358 <putc>
      state = 0;
 5d0:	4981                	li	s3,0
 5d2:	bd61                	j	46a <vprintf+0x44>
        s = va_arg(ap, char*);
 5d4:	8bce                	mv	s7,s3
      state = 0;
 5d6:	4981                	li	s3,0
 5d8:	bd49                	j	46a <vprintf+0x44>
    }
  }
}
 5da:	60a6                	ld	ra,72(sp)
 5dc:	6406                	ld	s0,64(sp)
 5de:	74e2                	ld	s1,56(sp)
 5e0:	7942                	ld	s2,48(sp)
 5e2:	79a2                	ld	s3,40(sp)
 5e4:	7a02                	ld	s4,32(sp)
 5e6:	6ae2                	ld	s5,24(sp)
 5e8:	6b42                	ld	s6,16(sp)
 5ea:	6ba2                	ld	s7,8(sp)
 5ec:	6c02                	ld	s8,0(sp)
 5ee:	6161                	addi	sp,sp,80
 5f0:	8082                	ret

00000000000005f2 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 5f2:	715d                	addi	sp,sp,-80
 5f4:	ec06                	sd	ra,24(sp)
 5f6:	e822                	sd	s0,16(sp)
 5f8:	1000                	addi	s0,sp,32
 5fa:	e010                	sd	a2,0(s0)
 5fc:	e414                	sd	a3,8(s0)
 5fe:	e818                	sd	a4,16(s0)
 600:	ec1c                	sd	a5,24(s0)
 602:	03043023          	sd	a6,32(s0)
 606:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 60a:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 60e:	8622                	mv	a2,s0
 610:	00000097          	auipc	ra,0x0
 614:	e16080e7          	jalr	-490(ra) # 426 <vprintf>
}
 618:	60e2                	ld	ra,24(sp)
 61a:	6442                	ld	s0,16(sp)
 61c:	6161                	addi	sp,sp,80
 61e:	8082                	ret

0000000000000620 <printf>:

void
printf(const char *fmt, ...)
{
 620:	711d                	addi	sp,sp,-96
 622:	ec06                	sd	ra,24(sp)
 624:	e822                	sd	s0,16(sp)
 626:	1000                	addi	s0,sp,32
 628:	e40c                	sd	a1,8(s0)
 62a:	e810                	sd	a2,16(s0)
 62c:	ec14                	sd	a3,24(s0)
 62e:	f018                	sd	a4,32(s0)
 630:	f41c                	sd	a5,40(s0)
 632:	03043823          	sd	a6,48(s0)
 636:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 63a:	00840613          	addi	a2,s0,8
 63e:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 642:	85aa                	mv	a1,a0
 644:	4505                	li	a0,1
 646:	00000097          	auipc	ra,0x0
 64a:	de0080e7          	jalr	-544(ra) # 426 <vprintf>
}
 64e:	60e2                	ld	ra,24(sp)
 650:	6442                	ld	s0,16(sp)
 652:	6125                	addi	sp,sp,96
 654:	8082                	ret

0000000000000656 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 656:	1141                	addi	sp,sp,-16
 658:	e422                	sd	s0,8(sp)
 65a:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 65c:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 660:	00001797          	auipc	a5,0x1
 664:	9a07b783          	ld	a5,-1632(a5) # 1000 <freep>
 668:	a02d                	j	692 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 66a:	4618                	lw	a4,8(a2)
 66c:	9f2d                	addw	a4,a4,a1
 66e:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 672:	6398                	ld	a4,0(a5)
 674:	6310                	ld	a2,0(a4)
 676:	a83d                	j	6b4 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 678:	ff852703          	lw	a4,-8(a0)
 67c:	9f31                	addw	a4,a4,a2
 67e:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 680:	ff053683          	ld	a3,-16(a0)
 684:	a091                	j	6c8 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 686:	6398                	ld	a4,0(a5)
 688:	00e7e463          	bltu	a5,a4,690 <free+0x3a>
 68c:	00e6ea63          	bltu	a3,a4,6a0 <free+0x4a>
{
 690:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 692:	fed7fae3          	bgeu	a5,a3,686 <free+0x30>
 696:	6398                	ld	a4,0(a5)
 698:	00e6e463          	bltu	a3,a4,6a0 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 69c:	fee7eae3          	bltu	a5,a4,690 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 6a0:	ff852583          	lw	a1,-8(a0)
 6a4:	6390                	ld	a2,0(a5)
 6a6:	02059813          	slli	a6,a1,0x20
 6aa:	01c85713          	srli	a4,a6,0x1c
 6ae:	9736                	add	a4,a4,a3
 6b0:	fae60de3          	beq	a2,a4,66a <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 6b4:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 6b8:	4790                	lw	a2,8(a5)
 6ba:	02061593          	slli	a1,a2,0x20
 6be:	01c5d713          	srli	a4,a1,0x1c
 6c2:	973e                	add	a4,a4,a5
 6c4:	fae68ae3          	beq	a3,a4,678 <free+0x22>
    p->s.ptr = bp->s.ptr;
 6c8:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 6ca:	00001717          	auipc	a4,0x1
 6ce:	92f73b23          	sd	a5,-1738(a4) # 1000 <freep>
}
 6d2:	6422                	ld	s0,8(sp)
 6d4:	0141                	addi	sp,sp,16
 6d6:	8082                	ret

00000000000006d8 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 6d8:	7139                	addi	sp,sp,-64
 6da:	fc06                	sd	ra,56(sp)
 6dc:	f822                	sd	s0,48(sp)
 6de:	f426                	sd	s1,40(sp)
 6e0:	f04a                	sd	s2,32(sp)
 6e2:	ec4e                	sd	s3,24(sp)
 6e4:	e852                	sd	s4,16(sp)
 6e6:	e456                	sd	s5,8(sp)
 6e8:	e05a                	sd	s6,0(sp)
 6ea:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 6ec:	02051493          	slli	s1,a0,0x20
 6f0:	9081                	srli	s1,s1,0x20
 6f2:	04bd                	addi	s1,s1,15
 6f4:	8091                	srli	s1,s1,0x4
 6f6:	0014899b          	addiw	s3,s1,1
 6fa:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 6fc:	00001517          	auipc	a0,0x1
 700:	90453503          	ld	a0,-1788(a0) # 1000 <freep>
 704:	c515                	beqz	a0,730 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 706:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 708:	4798                	lw	a4,8(a5)
 70a:	02977f63          	bgeu	a4,s1,748 <malloc+0x70>
  if(nu < 4096)
 70e:	8a4e                	mv	s4,s3
 710:	0009871b          	sext.w	a4,s3
 714:	6685                	lui	a3,0x1
 716:	00d77363          	bgeu	a4,a3,71c <malloc+0x44>
 71a:	6a05                	lui	s4,0x1
 71c:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 720:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 724:	00001917          	auipc	s2,0x1
 728:	8dc90913          	addi	s2,s2,-1828 # 1000 <freep>
  if(p == (char*)-1)
 72c:	5afd                	li	s5,-1
 72e:	a895                	j	7a2 <malloc+0xca>
    base.s.ptr = freep = prevp = &base;
 730:	00001797          	auipc	a5,0x1
 734:	8f078793          	addi	a5,a5,-1808 # 1020 <base>
 738:	00001717          	auipc	a4,0x1
 73c:	8cf73423          	sd	a5,-1848(a4) # 1000 <freep>
 740:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 742:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 746:	b7e1                	j	70e <malloc+0x36>
      if(p->s.size == nunits)
 748:	02e48c63          	beq	s1,a4,780 <malloc+0xa8>
        p->s.size -= nunits;
 74c:	4137073b          	subw	a4,a4,s3
 750:	c798                	sw	a4,8(a5)
        p += p->s.size;
 752:	02071693          	slli	a3,a4,0x20
 756:	01c6d713          	srli	a4,a3,0x1c
 75a:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 75c:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 760:	00001717          	auipc	a4,0x1
 764:	8aa73023          	sd	a0,-1888(a4) # 1000 <freep>
      return (void*)(p + 1);
 768:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 76c:	70e2                	ld	ra,56(sp)
 76e:	7442                	ld	s0,48(sp)
 770:	74a2                	ld	s1,40(sp)
 772:	7902                	ld	s2,32(sp)
 774:	69e2                	ld	s3,24(sp)
 776:	6a42                	ld	s4,16(sp)
 778:	6aa2                	ld	s5,8(sp)
 77a:	6b02                	ld	s6,0(sp)
 77c:	6121                	addi	sp,sp,64
 77e:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 780:	6398                	ld	a4,0(a5)
 782:	e118                	sd	a4,0(a0)
 784:	bff1                	j	760 <malloc+0x88>
  hp->s.size = nu;
 786:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 78a:	0541                	addi	a0,a0,16
 78c:	00000097          	auipc	ra,0x0
 790:	eca080e7          	jalr	-310(ra) # 656 <free>
  return freep;
 794:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 798:	d971                	beqz	a0,76c <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 79a:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 79c:	4798                	lw	a4,8(a5)
 79e:	fa9775e3          	bgeu	a4,s1,748 <malloc+0x70>
    if(p == freep)
 7a2:	00093703          	ld	a4,0(s2)
 7a6:	853e                	mv	a0,a5
 7a8:	fef719e3          	bne	a4,a5,79a <malloc+0xc2>
  p = sbrk(nu * sizeof(Header));
 7ac:	8552                	mv	a0,s4
 7ae:	00000097          	auipc	ra,0x0
 7b2:	b8a080e7          	jalr	-1142(ra) # 338 <sbrk>
  if(p == (char*)-1)
 7b6:	fd5518e3          	bne	a0,s5,786 <malloc+0xae>
        return 0;
 7ba:	4501                	li	a0,0
 7bc:	bf45                	j	76c <malloc+0x94>

00000000000007be <get_current_tid>:
struct ulthread *scheduler_thread;
enum ulthread_scheduling_algorithm algorithm;

/* Get thread ID */
int get_current_tid(void)
{
 7be:	1141                	addi	sp,sp,-16
 7c0:	e422                	sd	s0,8(sp)
 7c2:	0800                	addi	s0,sp,16
  return current_thread->tid;
}
 7c4:	00001797          	auipc	a5,0x1
 7c8:	8547b783          	ld	a5,-1964(a5) # 1018 <current_thread>
 7cc:	43c8                	lw	a0,4(a5)
 7ce:	6422                	ld	s0,8(sp)
 7d0:	0141                	addi	sp,sp,16
 7d2:	8082                	ret

00000000000007d4 <roundRobin>:

void roundRobin(void)
{
 7d4:	715d                	addi	sp,sp,-80
 7d6:	e486                	sd	ra,72(sp)
 7d8:	e0a2                	sd	s0,64(sp)
 7da:	fc26                	sd	s1,56(sp)
 7dc:	f84a                	sd	s2,48(sp)
 7de:	f44e                	sd	s3,40(sp)
 7e0:	f052                	sd	s4,32(sp)
 7e2:	ec56                	sd	s5,24(sp)
 7e4:	e85a                	sd	s6,16(sp)
 7e6:	e45e                	sd	s7,8(sp)
 7e8:	e062                	sd	s8,0(sp)
 7ea:	0880                	addi	s0,sp,80
        struct ulthread *temp = current_thread;
        current_thread = t;
        printf("[*] ultschedule (next tid: %d)\n", get_current_tid());
        ulthread_context_switch(&temp->context, &t->context);
      }
      if (t->state == YIELD)
 7ec:	4a09                	li	s4,2
      if (t->state == RUNNABLE && t != scheduler_thread)
 7ee:	00001b97          	auipc	s7,0x1
 7f2:	822b8b93          	addi	s7,s7,-2014 # 1010 <scheduler_thread>
        struct ulthread *temp = current_thread;
 7f6:	00001a97          	auipc	s5,0x1
 7fa:	822a8a93          	addi	s5,s5,-2014 # 1018 <current_thread>
        printf("[*] ultschedule (next tid: %d)\n", get_current_tid());
 7fe:	00000c17          	auipc	s8,0x0
 802:	59ac0c13          	addi	s8,s8,1434 # d98 <digits+0x18>
    for (t = ulthreads; t < &ulthreads[MAXULTHREADS]; t++)
 806:	00004997          	auipc	s3,0x4
 80a:	d4a98993          	addi	s3,s3,-694 # 4550 <ulthreads+0x3520>
 80e:	a0b9                	j	85c <roundRobin+0x88>
      if (t->state == RUNNABLE && t != scheduler_thread)
 810:	000bb783          	ld	a5,0(s7)
 814:	02978863          	beq	a5,s1,844 <roundRobin+0x70>
        struct ulthread *temp = current_thread;
 818:	000abb03          	ld	s6,0(s5)
        current_thread = t;
 81c:	009ab023          	sd	s1,0(s5)
        printf("[*] ultschedule (next tid: %d)\n", get_current_tid());
 820:	40cc                	lw	a1,4(s1)
 822:	8562                	mv	a0,s8
 824:	00000097          	auipc	ra,0x0
 828:	dfc080e7          	jalr	-516(ra) # 620 <printf>
        ulthread_context_switch(&temp->context, &t->context);
 82c:	01848593          	addi	a1,s1,24
 830:	018b0513          	addi	a0,s6,24
 834:	00000097          	auipc	ra,0x0
 838:	46a080e7          	jalr	1130(ra) # c9e <ulthread_context_switch>
        threadAvailable = true;
 83c:	874a                	mv	a4,s2
 83e:	a811                	j	852 <roundRobin+0x7e>
      {
        t->state = RUNNABLE;
 840:	0124a023          	sw	s2,0(s1)
    for (t = ulthreads; t < &ulthreads[MAXULTHREADS]; t++)
 844:	08848493          	addi	s1,s1,136
 848:	01348963          	beq	s1,s3,85a <roundRobin+0x86>
      if (t->state == RUNNABLE && t != scheduler_thread)
 84c:	409c                	lw	a5,0(s1)
 84e:	fd2781e3          	beq	a5,s2,810 <roundRobin+0x3c>
      if (t->state == YIELD)
 852:	409c                	lw	a5,0(s1)
 854:	ff4798e3          	bne	a5,s4,844 <roundRobin+0x70>
 858:	b7e5                	j	840 <roundRobin+0x6c>
      }
    }
    if (!threadAvailable)
 85a:	cb01                	beqz	a4,86a <roundRobin+0x96>
    bool threadAvailable = false;
 85c:	4701                	li	a4,0
    for (t = ulthreads; t < &ulthreads[MAXULTHREADS]; t++)
 85e:	00000497          	auipc	s1,0x0
 862:	7d248493          	addi	s1,s1,2002 # 1030 <ulthreads>
      if (t->state == RUNNABLE && t != scheduler_thread)
 866:	4905                	li	s2,1
 868:	b7d5                	j	84c <roundRobin+0x78>
    {
      break;
    }
  }
}
 86a:	60a6                	ld	ra,72(sp)
 86c:	6406                	ld	s0,64(sp)
 86e:	74e2                	ld	s1,56(sp)
 870:	7942                	ld	s2,48(sp)
 872:	79a2                	ld	s3,40(sp)
 874:	7a02                	ld	s4,32(sp)
 876:	6ae2                	ld	s5,24(sp)
 878:	6b42                	ld	s6,16(sp)
 87a:	6ba2                	ld	s7,8(sp)
 87c:	6c02                	ld	s8,0(sp)
 87e:	6161                	addi	sp,sp,80
 880:	8082                	ret

0000000000000882 <firstComeFirstServe>:

void firstComeFirstServe(void)
{
 882:	715d                	addi	sp,sp,-80
 884:	e486                	sd	ra,72(sp)
 886:	e0a2                	sd	s0,64(sp)
 888:	fc26                	sd	s1,56(sp)
 88a:	f84a                	sd	s2,48(sp)
 88c:	f44e                	sd	s3,40(sp)
 88e:	f052                	sd	s4,32(sp)
 890:	ec56                	sd	s5,24(sp)
 892:	e85a                	sd	s6,16(sp)
 894:	e45e                	sd	s7,8(sp)
 896:	e062                	sd	s8,0(sp)
 898:	0880                	addi	s0,sp,80
    uint64 oldest = __INT64_MAX__;
    int threadIndex = -1;
    int alternativeIndex = -1;
    for (t = ulthreads+1; t < &ulthreads[MAXULTHREADS]; t++)
    {
      if (t->state == RUNNABLE && t != scheduler_thread && t->lastTime < oldest)
 89a:	00000b97          	auipc	s7,0x0
 89e:	776b8b93          	addi	s7,s7,1910 # 1010 <scheduler_thread>
    int alternativeIndex = -1;
 8a2:	5afd                	li	s5,-1
    uint64 oldest = __INT64_MAX__;
 8a4:	001adb13          	srli	s6,s5,0x1
      if (t->state == RUNNABLE && t != scheduler_thread && t->lastTime < oldest)
 8a8:	4485                	li	s1,1
        oldest = t->lastTime;
        threadIndex = t->tid;
        threadAvailable = true;
      }

      if (t->state == YIELD){
 8aa:	4989                	li	s3,2
    for (t = ulthreads+1; t < &ulthreads[MAXULTHREADS]; t++)
 8ac:	00004917          	auipc	s2,0x4
 8b0:	ca490913          	addi	s2,s2,-860 # 4550 <ulthreads+0x3520>
        break;
      }
      
    }
    label : 
      struct ulthread *temp = current_thread;
 8b4:	00000a17          	auipc	s4,0x0
 8b8:	764a0a13          	addi	s4,s4,1892 # 1018 <current_thread>
 8bc:	a88d                	j	92e <firstComeFirstServe+0xac>
      if (t->state == RUNNABLE && t != scheduler_thread && t->lastTime < oldest)
 8be:	00f58963          	beq	a1,a5,8d0 <firstComeFirstServe+0x4e>
 8c2:	6b98                	ld	a4,16(a5)
 8c4:	00c77663          	bgeu	a4,a2,8d0 <firstComeFirstServe+0x4e>
        threadIndex = t->tid;
 8c8:	0047a803          	lw	a6,4(a5)
        oldest = t->lastTime;
 8cc:	863a                	mv	a2,a4
        threadAvailable = true;
 8ce:	8526                	mv	a0,s1
    for (t = ulthreads+1; t < &ulthreads[MAXULTHREADS]; t++)
 8d0:	08878793          	addi	a5,a5,136
 8d4:	01278a63          	beq	a5,s2,8e8 <firstComeFirstServe+0x66>
      if (t->state == RUNNABLE && t != scheduler_thread && t->lastTime < oldest)
 8d8:	4398                	lw	a4,0(a5)
 8da:	fe9702e3          	beq	a4,s1,8be <firstComeFirstServe+0x3c>
      if (t->state == YIELD){
 8de:	ff3719e3          	bne	a4,s3,8d0 <firstComeFirstServe+0x4e>
        t->state = RUNNABLE;
 8e2:	c384                	sw	s1,0(a5)
        alternativeIndex = t->tid;
 8e4:	43d4                	lw	a3,4(a5)
 8e6:	b7ed                	j	8d0 <firstComeFirstServe+0x4e>
    if (!threadAvailable)
 8e8:	ed31                	bnez	a0,944 <firstComeFirstServe+0xc2>
      if(alternativeIndex > 0){
 8ea:	04d05f63          	blez	a3,948 <firstComeFirstServe+0xc6>
      struct ulthread *temp = current_thread;
 8ee:	000a3c03          	ld	s8,0(s4)
      current_thread = &ulthreads[threadIndex];
 8f2:	00469793          	slli	a5,a3,0x4
 8f6:	00d78733          	add	a4,a5,a3
 8fa:	070e                	slli	a4,a4,0x3
 8fc:	00000617          	auipc	a2,0x0
 900:	73460613          	addi	a2,a2,1844 # 1030 <ulthreads>
 904:	9732                	add	a4,a4,a2
 906:	00ea3023          	sd	a4,0(s4)
      printf("[*] ultschedule (next tid: %d), time = %d\n", get_current_tid());
 90a:	434c                	lw	a1,4(a4)
 90c:	00000517          	auipc	a0,0x0
 910:	4ac50513          	addi	a0,a0,1196 # db8 <digits+0x38>
 914:	00000097          	auipc	ra,0x0
 918:	d0c080e7          	jalr	-756(ra) # 620 <printf>
      ulthread_context_switch(&temp->context, &current_thread->context);
 91c:	000a3583          	ld	a1,0(s4)
 920:	05e1                	addi	a1,a1,24
 922:	018c0513          	addi	a0,s8,24
 926:	00000097          	auipc	ra,0x0
 92a:	378080e7          	jalr	888(ra) # c9e <ulthread_context_switch>
      if (t->state == RUNNABLE && t != scheduler_thread && t->lastTime < oldest)
 92e:	000bb583          	ld	a1,0(s7)
    int alternativeIndex = -1;
 932:	86d6                	mv	a3,s5
    int threadIndex = -1;
 934:	8856                	mv	a6,s5
    uint64 oldest = __INT64_MAX__;
 936:	865a                	mv	a2,s6
    bool threadAvailable = false;
 938:	4501                	li	a0,0
    for (t = ulthreads+1; t < &ulthreads[MAXULTHREADS]; t++)
 93a:	00000797          	auipc	a5,0x0
 93e:	77e78793          	addi	a5,a5,1918 # 10b8 <ulthreads+0x88>
 942:	bf59                	j	8d8 <firstComeFirstServe+0x56>
    label : 
 944:	86c2                	mv	a3,a6
 946:	b765                	j	8ee <firstComeFirstServe+0x6c>
  }
}
 948:	60a6                	ld	ra,72(sp)
 94a:	6406                	ld	s0,64(sp)
 94c:	74e2                	ld	s1,56(sp)
 94e:	7942                	ld	s2,48(sp)
 950:	79a2                	ld	s3,40(sp)
 952:	7a02                	ld	s4,32(sp)
 954:	6ae2                	ld	s5,24(sp)
 956:	6b42                	ld	s6,16(sp)
 958:	6ba2                	ld	s7,8(sp)
 95a:	6c02                	ld	s8,0(sp)
 95c:	6161                	addi	sp,sp,80
 95e:	8082                	ret

0000000000000960 <priorityScheduling>:


void priorityScheduling(void)
{
 960:	715d                	addi	sp,sp,-80
 962:	e486                	sd	ra,72(sp)
 964:	e0a2                	sd	s0,64(sp)
 966:	fc26                	sd	s1,56(sp)
 968:	f84a                	sd	s2,48(sp)
 96a:	f44e                	sd	s3,40(sp)
 96c:	f052                	sd	s4,32(sp)
 96e:	ec56                	sd	s5,24(sp)
 970:	e85a                	sd	s6,16(sp)
 972:	e45e                	sd	s7,8(sp)
 974:	0880                	addi	s0,sp,80
    int maxPriority = -1;
    int threadIndex = -1;
    int alternativeIndex = -1;
    for (t = ulthreads+1; t < &ulthreads[MAXULTHREADS]; t++)
    {
      if (t->state == RUNNABLE && t != scheduler_thread && t->priority > maxPriority)
 976:	00000b17          	auipc	s6,0x0
 97a:	69ab0b13          	addi	s6,s6,1690 # 1010 <scheduler_thread>
    int alternativeIndex = -1;
 97e:	5a7d                	li	s4,-1
      if (t->state == RUNNABLE && t != scheduler_thread && t->priority > maxPriority)
 980:	4485                	li	s1,1
        // flag = true;

        // break; // switch to highest-priority thread and exit loop
      }

      if (t->state == YIELD){
 982:	4989                	li	s3,2
    for (t = ulthreads+1; t < &ulthreads[MAXULTHREADS]; t++)
 984:	00004917          	auipc	s2,0x4
 988:	bcc90913          	addi	s2,s2,-1076 # 4550 <ulthreads+0x3520>
        break;
      }
      
    }
    label : 
      struct ulthread *temp = current_thread;
 98c:	00000a97          	auipc	s5,0x0
 990:	68ca8a93          	addi	s5,s5,1676 # 1018 <current_thread>
 994:	a88d                	j	a06 <priorityScheduling+0xa6>
      if (t->state == RUNNABLE && t != scheduler_thread && t->priority > maxPriority)
 996:	00f58963          	beq	a1,a5,9a8 <priorityScheduling+0x48>
 99a:	47d8                	lw	a4,12(a5)
 99c:	00e65663          	bge	a2,a4,9a8 <priorityScheduling+0x48>
        threadIndex = t->tid;
 9a0:	0047a803          	lw	a6,4(a5)
        maxPriority = t->priority;
 9a4:	863a                	mv	a2,a4
        threadAvailable = true;
 9a6:	8526                	mv	a0,s1
    for (t = ulthreads+1; t < &ulthreads[MAXULTHREADS]; t++)
 9a8:	08878793          	addi	a5,a5,136
 9ac:	01278a63          	beq	a5,s2,9c0 <priorityScheduling+0x60>
      if (t->state == RUNNABLE && t != scheduler_thread && t->priority > maxPriority)
 9b0:	4398                	lw	a4,0(a5)
 9b2:	fe9702e3          	beq	a4,s1,996 <priorityScheduling+0x36>
      if (t->state == YIELD){
 9b6:	ff3719e3          	bne	a4,s3,9a8 <priorityScheduling+0x48>
        t->state = RUNNABLE;
 9ba:	c384                	sw	s1,0(a5)
        alternativeIndex = t->tid;
 9bc:	43d4                	lw	a3,4(a5)
 9be:	b7ed                	j	9a8 <priorityScheduling+0x48>
    if (!threadAvailable)
 9c0:	ed31                	bnez	a0,a1c <priorityScheduling+0xbc>
      if(alternativeIndex > 0){
 9c2:	04d05f63          	blez	a3,a20 <priorityScheduling+0xc0>
      struct ulthread *temp = current_thread;
 9c6:	000abb83          	ld	s7,0(s5)
      current_thread = &ulthreads[threadIndex];
 9ca:	00469793          	slli	a5,a3,0x4
 9ce:	00d78733          	add	a4,a5,a3
 9d2:	070e                	slli	a4,a4,0x3
 9d4:	00000617          	auipc	a2,0x0
 9d8:	65c60613          	addi	a2,a2,1628 # 1030 <ulthreads>
 9dc:	9732                	add	a4,a4,a2
 9de:	00eab023          	sd	a4,0(s5)
      printf("[*] ultschedule (next tid: %d)\n", get_current_tid());
 9e2:	434c                	lw	a1,4(a4)
 9e4:	00000517          	auipc	a0,0x0
 9e8:	3b450513          	addi	a0,a0,948 # d98 <digits+0x18>
 9ec:	00000097          	auipc	ra,0x0
 9f0:	c34080e7          	jalr	-972(ra) # 620 <printf>
      ulthread_context_switch(&temp->context, &current_thread->context);
 9f4:	000ab583          	ld	a1,0(s5)
 9f8:	05e1                	addi	a1,a1,24
 9fa:	018b8513          	addi	a0,s7,24
 9fe:	00000097          	auipc	ra,0x0
 a02:	2a0080e7          	jalr	672(ra) # c9e <ulthread_context_switch>
      if (t->state == RUNNABLE && t != scheduler_thread && t->priority > maxPriority)
 a06:	000b3583          	ld	a1,0(s6)
    int alternativeIndex = -1;
 a0a:	86d2                	mv	a3,s4
    int threadIndex = -1;
 a0c:	8852                	mv	a6,s4
    int maxPriority = -1;
 a0e:	8652                	mv	a2,s4
    bool threadAvailable = false;
 a10:	4501                	li	a0,0
    for (t = ulthreads+1; t < &ulthreads[MAXULTHREADS]; t++)
 a12:	00000797          	auipc	a5,0x0
 a16:	6a678793          	addi	a5,a5,1702 # 10b8 <ulthreads+0x88>
 a1a:	bf59                	j	9b0 <priorityScheduling+0x50>
    label : 
 a1c:	86c2                	mv	a3,a6
 a1e:	b765                	j	9c6 <priorityScheduling+0x66>
  }
}
 a20:	60a6                	ld	ra,72(sp)
 a22:	6406                	ld	s0,64(sp)
 a24:	74e2                	ld	s1,56(sp)
 a26:	7942                	ld	s2,48(sp)
 a28:	79a2                	ld	s3,40(sp)
 a2a:	7a02                	ld	s4,32(sp)
 a2c:	6ae2                	ld	s5,24(sp)
 a2e:	6b42                	ld	s6,16(sp)
 a30:	6ba2                	ld	s7,8(sp)
 a32:	6161                	addi	sp,sp,80
 a34:	8082                	ret

0000000000000a36 <ulthread_init>:

/* Thread initialization */
void ulthread_init(int schedalgo)
{
 a36:	1141                	addi	sp,sp,-16
 a38:	e422                	sd	s0,8(sp)
 a3a:	0800                	addi	s0,sp,16
  struct ulthread *t;
  int i;
  for (i = 0, t = ulthreads; t < &ulthreads[MAXULTHREADS]; t++, i++)
 a3c:	4701                	li	a4,0
 a3e:	00000797          	auipc	a5,0x0
 a42:	5f278793          	addi	a5,a5,1522 # 1030 <ulthreads>
 a46:	00004697          	auipc	a3,0x4
 a4a:	b0a68693          	addi	a3,a3,-1270 # 4550 <ulthreads+0x3520>
  {
    t->state = FREE;
 a4e:	0007a023          	sw	zero,0(a5)
    t->tid = i;
 a52:	c3d8                	sw	a4,4(a5)
  for (i = 0, t = ulthreads; t < &ulthreads[MAXULTHREADS]; t++, i++)
 a54:	08878793          	addi	a5,a5,136
 a58:	2705                	addiw	a4,a4,1
 a5a:	fed79ae3          	bne	a5,a3,a4e <ulthread_init+0x18>
  }
  current_thread = &ulthreads[0];
 a5e:	00000797          	auipc	a5,0x0
 a62:	5d278793          	addi	a5,a5,1490 # 1030 <ulthreads>
 a66:	00000717          	auipc	a4,0x0
 a6a:	5af73923          	sd	a5,1458(a4) # 1018 <current_thread>
  scheduler_thread = &ulthreads[0];
 a6e:	00000717          	auipc	a4,0x0
 a72:	5af73123          	sd	a5,1442(a4) # 1010 <scheduler_thread>
  scheduler_thread->state = RUNNABLE;
 a76:	4705                	li	a4,1
 a78:	c398                	sw	a4,0(a5)
  t->state = FREE;
 a7a:	00004797          	auipc	a5,0x4
 a7e:	ac07ab23          	sw	zero,-1322(a5) # 4550 <ulthreads+0x3520>
  algorithm = schedalgo;
 a82:	00000797          	auipc	a5,0x0
 a86:	58a7a323          	sw	a0,1414(a5) # 1008 <algorithm>
}
 a8a:	6422                	ld	s0,8(sp)
 a8c:	0141                	addi	sp,sp,16
 a8e:	8082                	ret

0000000000000a90 <ulthread_create>:

/* Thread creation */
bool ulthread_create(uint64 start, uint64 stack, uint64 args[], int priority)
{
 a90:	7179                	addi	sp,sp,-48
 a92:	f406                	sd	ra,40(sp)
 a94:	f022                	sd	s0,32(sp)
 a96:	ec26                	sd	s1,24(sp)
 a98:	e84a                	sd	s2,16(sp)
 a9a:	e44e                	sd	s3,8(sp)
 a9c:	e052                	sd	s4,0(sp)
 a9e:	1800                	addi	s0,sp,48
 aa0:	89aa                	mv	s3,a0
 aa2:	8a2e                	mv	s4,a1
 aa4:	8932                	mv	s2,a2
  /* Please add thread-id instead of '0' here. */
  struct ulthread *t;
  bool flag = false;
  for (t = ulthreads; t < &ulthreads[MAXULTHREADS]; t++)
 aa6:	00000497          	auipc	s1,0x0
 aaa:	58a48493          	addi	s1,s1,1418 # 1030 <ulthreads>
 aae:	00004717          	auipc	a4,0x4
 ab2:	aa270713          	addi	a4,a4,-1374 # 4550 <ulthreads+0x3520>
  {
    if (t->state == FREE)
 ab6:	409c                	lw	a5,0(s1)
 ab8:	cf89                	beqz	a5,ad2 <ulthread_create+0x42>
  for (t = ulthreads; t < &ulthreads[MAXULTHREADS]; t++)
 aba:	08848493          	addi	s1,s1,136
 abe:	fee49ce3          	bne	s1,a4,ab6 <ulthread_create+0x26>
      break;
    }
  }
  if (!flag)
  {
    return false;
 ac2:	4501                	li	a0,0
 ac4:	a871                	j	b60 <ulthread_create+0xd0>
  t->sp = (int)(stack + USTACKSIZE); // set sp to the top of the stack
  t->state = RUNNABLE;
  t->priority = priority;

  if(algorithm==FCFS){
    t->lastTime = ctime();
 ac6:	00000097          	auipc	ra,0x0
 aca:	88a080e7          	jalr	-1910(ra) # 350 <ctime>
 ace:	e888                	sd	a0,16(s1)
 ad0:	a839                	j	aee <ulthread_create+0x5e>
  t->sp = (int)(stack + USTACKSIZE); // set sp to the top of the stack
 ad2:	6785                	lui	a5,0x1
 ad4:	014787bb          	addw	a5,a5,s4
 ad8:	c49c                	sw	a5,8(s1)
  t->state = RUNNABLE;
 ada:	4785                	li	a5,1
 adc:	c09c                	sw	a5,0(s1)
  t->priority = priority;
 ade:	c4d4                	sw	a3,12(s1)
  if(algorithm==FCFS){
 ae0:	00000717          	auipc	a4,0x0
 ae4:	52872703          	lw	a4,1320(a4) # 1008 <algorithm>
 ae8:	4789                	li	a5,2
 aea:	fcf70ee3          	beq	a4,a5,ac6 <ulthread_create+0x36>
  }

  for (int argc = 0; argc < 6; argc++)
 aee:	874a                	mv	a4,s2
 af0:	03090693          	addi	a3,s2,48
  {
    t->sp -= 16;
 af4:	449c                	lw	a5,8(s1)
 af6:	37c1                	addiw	a5,a5,-16 # ff0 <digits+0x270>
 af8:	0007881b          	sext.w	a6,a5
 afc:	c49c                	sw	a5,8(s1)
    *(uint64 *)(t->sp) = (uint64)args[argc];
 afe:	631c                	ld	a5,0(a4)
 b00:	00f83023          	sd	a5,0(a6)
  for (int argc = 0; argc < 6; argc++)
 b04:	0721                	addi	a4,a4,8
 b06:	fed717e3          	bne	a4,a3,af4 <ulthread_create+0x64>
  }

  memset(&t->context, 0, sizeof(t->context));
 b0a:	07000613          	li	a2,112
 b0e:	4581                	li	a1,0
 b10:	01848513          	addi	a0,s1,24
 b14:	fffff097          	auipc	ra,0xfffff
 b18:	5a2080e7          	jalr	1442(ra) # b6 <memset>
  t->context.ra = start;
 b1c:	0134bc23          	sd	s3,24(s1)
  t->context.sp = t->sp;
 b20:	449c                	lw	a5,8(s1)
 b22:	f09c                	sd	a5,32(s1)
  t->context.s0 = args[0];
 b24:	00093783          	ld	a5,0(s2)
 b28:	f49c                	sd	a5,40(s1)
  t->context.s1 = args[1];
 b2a:	00893783          	ld	a5,8(s2)
 b2e:	f89c                	sd	a5,48(s1)
  t->context.s2 = args[2];
 b30:	01093783          	ld	a5,16(s2)
 b34:	fc9c                	sd	a5,56(s1)
  t->context.s3 = args[3];
 b36:	01893783          	ld	a5,24(s2)
 b3a:	e0bc                	sd	a5,64(s1)
  t->context.s4 = args[4];
 b3c:	02093783          	ld	a5,32(s2)
 b40:	e4bc                	sd	a5,72(s1)
  t->context.s5 = args[5];
 b42:	02893783          	ld	a5,40(s2)
 b46:	e8bc                	sd	a5,80(s1)

  printf("[*] ultcreate(tid: %d, ra: %p, sp: %p)\n", t->tid, start, stack);
 b48:	86d2                	mv	a3,s4
 b4a:	864e                	mv	a2,s3
 b4c:	40cc                	lw	a1,4(s1)
 b4e:	00000517          	auipc	a0,0x0
 b52:	29a50513          	addi	a0,a0,666 # de8 <digits+0x68>
 b56:	00000097          	auipc	ra,0x0
 b5a:	aca080e7          	jalr	-1334(ra) # 620 <printf>
  return true;
 b5e:	4505                	li	a0,1
}
 b60:	70a2                	ld	ra,40(sp)
 b62:	7402                	ld	s0,32(sp)
 b64:	64e2                	ld	s1,24(sp)
 b66:	6942                	ld	s2,16(sp)
 b68:	69a2                	ld	s3,8(sp)
 b6a:	6a02                	ld	s4,0(sp)
 b6c:	6145                	addi	sp,sp,48
 b6e:	8082                	ret

0000000000000b70 <ulthread_schedule>:

/* Thread scheduler */
void ulthread_schedule(void)
{
 b70:	1141                	addi	sp,sp,-16
 b72:	e406                	sd	ra,8(sp)
 b74:	e022                	sd	s0,0(sp)
 b76:	0800                	addi	s0,sp,16
  switch (algorithm)
 b78:	00000797          	auipc	a5,0x0
 b7c:	4907a783          	lw	a5,1168(a5) # 1008 <algorithm>
 b80:	4705                	li	a4,1
 b82:	02e78463          	beq	a5,a4,baa <ulthread_schedule+0x3a>
 b86:	4709                	li	a4,2
 b88:	00e78c63          	beq	a5,a4,ba0 <ulthread_schedule+0x30>
 b8c:	c789                	beqz	a5,b96 <ulthread_schedule+0x26>

  // Push argument strings, prepare rest of stack in ustack.

  // Switch between thread contexts
  // ulthread_context_switch(NULL, NULL);
}
 b8e:	60a2                	ld	ra,8(sp)
 b90:	6402                	ld	s0,0(sp)
 b92:	0141                	addi	sp,sp,16
 b94:	8082                	ret
    roundRobin();
 b96:	00000097          	auipc	ra,0x0
 b9a:	c3e080e7          	jalr	-962(ra) # 7d4 <roundRobin>
    break;
 b9e:	bfc5                	j	b8e <ulthread_schedule+0x1e>
    firstComeFirstServe();
 ba0:	00000097          	auipc	ra,0x0
 ba4:	ce2080e7          	jalr	-798(ra) # 882 <firstComeFirstServe>
    break;
 ba8:	b7dd                	j	b8e <ulthread_schedule+0x1e>
    priorityScheduling();
 baa:	00000097          	auipc	ra,0x0
 bae:	db6080e7          	jalr	-586(ra) # 960 <priorityScheduling>
}
 bb2:	bff1                	j	b8e <ulthread_schedule+0x1e>

0000000000000bb4 <ulthread_yield>:

/* Yield CPU time to some other thread. */
void ulthread_yield(void)
{
 bb4:	1101                	addi	sp,sp,-32
 bb6:	ec06                	sd	ra,24(sp)
 bb8:	e822                	sd	s0,16(sp)
 bba:	e426                	sd	s1,8(sp)
 bbc:	e04a                	sd	s2,0(sp)
 bbe:	1000                	addi	s0,sp,32
  current_thread->state = YIELD;
 bc0:	00000797          	auipc	a5,0x0
 bc4:	45878793          	addi	a5,a5,1112 # 1018 <current_thread>
 bc8:	6398                	ld	a4,0(a5)
 bca:	4909                	li	s2,2
 bcc:	01272023          	sw	s2,0(a4)
  struct ulthread *temp = current_thread;
 bd0:	6384                	ld	s1,0(a5)
  printf("[*] ultyield(tid: %d)\n", current_thread->tid);
 bd2:	40cc                	lw	a1,4(s1)
 bd4:	00000517          	auipc	a0,0x0
 bd8:	23c50513          	addi	a0,a0,572 # e10 <digits+0x90>
 bdc:	00000097          	auipc	ra,0x0
 be0:	a44080e7          	jalr	-1468(ra) # 620 <printf>
  if(algorithm==FCFS){
 be4:	00000797          	auipc	a5,0x0
 be8:	4247a783          	lw	a5,1060(a5) # 1008 <algorithm>
 bec:	03278763          	beq	a5,s2,c1a <ulthread_yield+0x66>
    current_thread->lastTime = ctime();
  }
  current_thread = scheduler_thread;
 bf0:	00000597          	auipc	a1,0x0
 bf4:	4205b583          	ld	a1,1056(a1) # 1010 <scheduler_thread>
 bf8:	00000797          	auipc	a5,0x0
 bfc:	42b7b023          	sd	a1,1056(a5) # 1018 <current_thread>
  
  ulthread_context_switch(&temp->context, &scheduler_thread->context);
 c00:	05e1                	addi	a1,a1,24
 c02:	01848513          	addi	a0,s1,24
 c06:	00000097          	auipc	ra,0x0
 c0a:	098080e7          	jalr	152(ra) # c9e <ulthread_context_switch>
  // ulthread_schedule();
}
 c0e:	60e2                	ld	ra,24(sp)
 c10:	6442                	ld	s0,16(sp)
 c12:	64a2                	ld	s1,8(sp)
 c14:	6902                	ld	s2,0(sp)
 c16:	6105                	addi	sp,sp,32
 c18:	8082                	ret
    current_thread->lastTime = ctime();
 c1a:	fffff097          	auipc	ra,0xfffff
 c1e:	736080e7          	jalr	1846(ra) # 350 <ctime>
 c22:	00000797          	auipc	a5,0x0
 c26:	3f67b783          	ld	a5,1014(a5) # 1018 <current_thread>
 c2a:	eb88                	sd	a0,16(a5)
 c2c:	b7d1                	j	bf0 <ulthread_yield+0x3c>

0000000000000c2e <ulthread_destroy>:

/* Destroy thread */
void ulthread_destroy(void)
{
 c2e:	1101                	addi	sp,sp,-32
 c30:	ec06                	sd	ra,24(sp)
 c32:	e822                	sd	s0,16(sp)
 c34:	e426                	sd	s1,8(sp)
 c36:	e04a                	sd	s2,0(sp)
 c38:	1000                	addi	s0,sp,32
  memset(&current_thread->context, 0, sizeof(current_thread->context));
 c3a:	00000497          	auipc	s1,0x0
 c3e:	3de48493          	addi	s1,s1,990 # 1018 <current_thread>
 c42:	6088                	ld	a0,0(s1)
 c44:	07000613          	li	a2,112
 c48:	4581                	li	a1,0
 c4a:	0561                	addi	a0,a0,24
 c4c:	fffff097          	auipc	ra,0xfffff
 c50:	46a080e7          	jalr	1130(ra) # b6 <memset>
  current_thread->sp = 0;
 c54:	609c                	ld	a5,0(s1)
 c56:	0007a423          	sw	zero,8(a5)
  current_thread->priority = -1;
 c5a:	577d                	li	a4,-1
 c5c:	c7d8                	sw	a4,12(a5)
  current_thread->state = FREE;
 c5e:	0007a023          	sw	zero,0(a5)

  struct ulthread *temp = current_thread;
 c62:	0004b903          	ld	s2,0(s1)

  printf("[*] ultdestroy(tid: %d)\n", get_current_tid());
 c66:	00492583          	lw	a1,4(s2)
 c6a:	00000517          	auipc	a0,0x0
 c6e:	1be50513          	addi	a0,a0,446 # e28 <digits+0xa8>
 c72:	00000097          	auipc	ra,0x0
 c76:	9ae080e7          	jalr	-1618(ra) # 620 <printf>
  current_thread = scheduler_thread;
 c7a:	00000597          	auipc	a1,0x0
 c7e:	3965b583          	ld	a1,918(a1) # 1010 <scheduler_thread>
 c82:	e08c                	sd	a1,0(s1)
  ulthread_context_switch(&temp->context, &scheduler_thread->context);
 c84:	05e1                	addi	a1,a1,24
 c86:	01890513          	addi	a0,s2,24
 c8a:	00000097          	auipc	ra,0x0
 c8e:	014080e7          	jalr	20(ra) # c9e <ulthread_context_switch>
}
 c92:	60e2                	ld	ra,24(sp)
 c94:	6442                	ld	s0,16(sp)
 c96:	64a2                	ld	s1,8(sp)
 c98:	6902                	ld	s2,0(sp)
 c9a:	6105                	addi	sp,sp,32
 c9c:	8082                	ret

0000000000000c9e <ulthread_context_switch>:
 c9e:	00153023          	sd	ra,0(a0)
 ca2:	00253423          	sd	sp,8(a0)
 ca6:	e900                	sd	s0,16(a0)
 ca8:	ed04                	sd	s1,24(a0)
 caa:	03253023          	sd	s2,32(a0)
 cae:	03353423          	sd	s3,40(a0)
 cb2:	03453823          	sd	s4,48(a0)
 cb6:	03553c23          	sd	s5,56(a0)
 cba:	05653023          	sd	s6,64(a0)
 cbe:	05753423          	sd	s7,72(a0)
 cc2:	05853823          	sd	s8,80(a0)
 cc6:	05953c23          	sd	s9,88(a0)
 cca:	07a53023          	sd	s10,96(a0)
 cce:	07b53423          	sd	s11,104(a0)
 cd2:	0005b083          	ld	ra,0(a1)
 cd6:	0085b103          	ld	sp,8(a1)
 cda:	6980                	ld	s0,16(a1)
 cdc:	6d84                	ld	s1,24(a1)
 cde:	0205b903          	ld	s2,32(a1)
 ce2:	0285b983          	ld	s3,40(a1)
 ce6:	0305ba03          	ld	s4,48(a1)
 cea:	0385ba83          	ld	s5,56(a1)
 cee:	0405bb03          	ld	s6,64(a1)
 cf2:	0485bb83          	ld	s7,72(a1)
 cf6:	0505bc03          	ld	s8,80(a1)
 cfa:	0585bc83          	ld	s9,88(a1)
 cfe:	0605bd03          	ld	s10,96(a1)
 d02:	0685bd83          	ld	s11,104(a1)
 d06:	6546                	ld	a0,80(sp)
 d08:	6586                	ld	a1,64(sp)
 d0a:	7642                	ld	a2,48(sp)
 d0c:	7682                	ld	a3,32(sp)
 d0e:	6742                	ld	a4,16(sp)
 d10:	6782                	ld	a5,0(sp)
 d12:	8082                	ret
