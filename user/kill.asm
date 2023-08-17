
user/_kill:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "kernel/stat.h"
#include "user/user.h"

int
main(int argc, char **argv)
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
   e:	02a7dd63          	bge	a5,a0,48 <main+0x48>
  12:	00858493          	addi	s1,a1,8
  16:	ffe5091b          	addiw	s2,a0,-2
  1a:	02091793          	slli	a5,s2,0x20
  1e:	01d7d913          	srli	s2,a5,0x1d
  22:	05c1                	addi	a1,a1,16
  24:	992e                	add	s2,s2,a1
    fprintf(2, "usage: kill pid...\n");
    exit(1);
  }
  for(i=1; i<argc; i++)
    kill(atoi(argv[i]));
  26:	6088                	ld	a0,0(s1)
  28:	00000097          	auipc	ra,0x0
  2c:	1c8080e7          	jalr	456(ra) # 1f0 <atoi>
  30:	00000097          	auipc	ra,0x0
  34:	2ea080e7          	jalr	746(ra) # 31a <kill>
  for(i=1; i<argc; i++)
  38:	04a1                	addi	s1,s1,8
  3a:	ff2496e3          	bne	s1,s2,26 <main+0x26>
  exit(0);
  3e:	4501                	li	a0,0
  40:	00000097          	auipc	ra,0x0
  44:	2aa080e7          	jalr	682(ra) # 2ea <exit>
    fprintf(2, "usage: kill pid...\n");
  48:	00001597          	auipc	a1,0x1
  4c:	d0858593          	addi	a1,a1,-760 # d50 <ulthread_context_switch+0x78>
  50:	4509                	li	a0,2
  52:	00000097          	auipc	ra,0x0
  56:	5da080e7          	jalr	1498(ra) # 62c <fprintf>
    exit(1);
  5a:	4505                	li	a0,1
  5c:	00000097          	auipc	ra,0x0
  60:	28e080e7          	jalr	654(ra) # 2ea <exit>

0000000000000064 <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
  64:	1141                	addi	sp,sp,-16
  66:	e406                	sd	ra,8(sp)
  68:	e022                	sd	s0,0(sp)
  6a:	0800                	addi	s0,sp,16
  extern int main();
  main();
  6c:	00000097          	auipc	ra,0x0
  70:	f94080e7          	jalr	-108(ra) # 0 <main>
  exit(0);
  74:	4501                	li	a0,0
  76:	00000097          	auipc	ra,0x0
  7a:	274080e7          	jalr	628(ra) # 2ea <exit>

000000000000007e <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
  7e:	1141                	addi	sp,sp,-16
  80:	e422                	sd	s0,8(sp)
  82:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  84:	87aa                	mv	a5,a0
  86:	0585                	addi	a1,a1,1
  88:	0785                	addi	a5,a5,1
  8a:	fff5c703          	lbu	a4,-1(a1)
  8e:	fee78fa3          	sb	a4,-1(a5)
  92:	fb75                	bnez	a4,86 <strcpy+0x8>
    ;
  return os;
}
  94:	6422                	ld	s0,8(sp)
  96:	0141                	addi	sp,sp,16
  98:	8082                	ret

000000000000009a <strcmp>:

int
strcmp(const char *p, const char *q)
{
  9a:	1141                	addi	sp,sp,-16
  9c:	e422                	sd	s0,8(sp)
  9e:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
  a0:	00054783          	lbu	a5,0(a0)
  a4:	cb91                	beqz	a5,b8 <strcmp+0x1e>
  a6:	0005c703          	lbu	a4,0(a1)
  aa:	00f71763          	bne	a4,a5,b8 <strcmp+0x1e>
    p++, q++;
  ae:	0505                	addi	a0,a0,1
  b0:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
  b2:	00054783          	lbu	a5,0(a0)
  b6:	fbe5                	bnez	a5,a6 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
  b8:	0005c503          	lbu	a0,0(a1)
}
  bc:	40a7853b          	subw	a0,a5,a0
  c0:	6422                	ld	s0,8(sp)
  c2:	0141                	addi	sp,sp,16
  c4:	8082                	ret

00000000000000c6 <strlen>:

uint
strlen(const char *s)
{
  c6:	1141                	addi	sp,sp,-16
  c8:	e422                	sd	s0,8(sp)
  ca:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
  cc:	00054783          	lbu	a5,0(a0)
  d0:	cf91                	beqz	a5,ec <strlen+0x26>
  d2:	0505                	addi	a0,a0,1
  d4:	87aa                	mv	a5,a0
  d6:	86be                	mv	a3,a5
  d8:	0785                	addi	a5,a5,1
  da:	fff7c703          	lbu	a4,-1(a5)
  de:	ff65                	bnez	a4,d6 <strlen+0x10>
  e0:	40a6853b          	subw	a0,a3,a0
  e4:	2505                	addiw	a0,a0,1
    ;
  return n;
}
  e6:	6422                	ld	s0,8(sp)
  e8:	0141                	addi	sp,sp,16
  ea:	8082                	ret
  for(n = 0; s[n]; n++)
  ec:	4501                	li	a0,0
  ee:	bfe5                	j	e6 <strlen+0x20>

00000000000000f0 <memset>:

void*
memset(void *dst, int c, uint n)
{
  f0:	1141                	addi	sp,sp,-16
  f2:	e422                	sd	s0,8(sp)
  f4:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
  f6:	ca19                	beqz	a2,10c <memset+0x1c>
  f8:	87aa                	mv	a5,a0
  fa:	1602                	slli	a2,a2,0x20
  fc:	9201                	srli	a2,a2,0x20
  fe:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 102:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 106:	0785                	addi	a5,a5,1
 108:	fee79de3          	bne	a5,a4,102 <memset+0x12>
  }
  return dst;
}
 10c:	6422                	ld	s0,8(sp)
 10e:	0141                	addi	sp,sp,16
 110:	8082                	ret

0000000000000112 <strchr>:

char*
strchr(const char *s, char c)
{
 112:	1141                	addi	sp,sp,-16
 114:	e422                	sd	s0,8(sp)
 116:	0800                	addi	s0,sp,16
  for(; *s; s++)
 118:	00054783          	lbu	a5,0(a0)
 11c:	cb99                	beqz	a5,132 <strchr+0x20>
    if(*s == c)
 11e:	00f58763          	beq	a1,a5,12c <strchr+0x1a>
  for(; *s; s++)
 122:	0505                	addi	a0,a0,1
 124:	00054783          	lbu	a5,0(a0)
 128:	fbfd                	bnez	a5,11e <strchr+0xc>
      return (char*)s;
  return 0;
 12a:	4501                	li	a0,0
}
 12c:	6422                	ld	s0,8(sp)
 12e:	0141                	addi	sp,sp,16
 130:	8082                	ret
  return 0;
 132:	4501                	li	a0,0
 134:	bfe5                	j	12c <strchr+0x1a>

0000000000000136 <gets>:

char*
gets(char *buf, int max)
{
 136:	711d                	addi	sp,sp,-96
 138:	ec86                	sd	ra,88(sp)
 13a:	e8a2                	sd	s0,80(sp)
 13c:	e4a6                	sd	s1,72(sp)
 13e:	e0ca                	sd	s2,64(sp)
 140:	fc4e                	sd	s3,56(sp)
 142:	f852                	sd	s4,48(sp)
 144:	f456                	sd	s5,40(sp)
 146:	f05a                	sd	s6,32(sp)
 148:	ec5e                	sd	s7,24(sp)
 14a:	1080                	addi	s0,sp,96
 14c:	8baa                	mv	s7,a0
 14e:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 150:	892a                	mv	s2,a0
 152:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 154:	4aa9                	li	s5,10
 156:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 158:	89a6                	mv	s3,s1
 15a:	2485                	addiw	s1,s1,1
 15c:	0344d863          	bge	s1,s4,18c <gets+0x56>
    cc = read(0, &c, 1);
 160:	4605                	li	a2,1
 162:	faf40593          	addi	a1,s0,-81
 166:	4501                	li	a0,0
 168:	00000097          	auipc	ra,0x0
 16c:	19a080e7          	jalr	410(ra) # 302 <read>
    if(cc < 1)
 170:	00a05e63          	blez	a0,18c <gets+0x56>
    buf[i++] = c;
 174:	faf44783          	lbu	a5,-81(s0)
 178:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 17c:	01578763          	beq	a5,s5,18a <gets+0x54>
 180:	0905                	addi	s2,s2,1
 182:	fd679be3          	bne	a5,s6,158 <gets+0x22>
  for(i=0; i+1 < max; ){
 186:	89a6                	mv	s3,s1
 188:	a011                	j	18c <gets+0x56>
 18a:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 18c:	99de                	add	s3,s3,s7
 18e:	00098023          	sb	zero,0(s3)
  return buf;
}
 192:	855e                	mv	a0,s7
 194:	60e6                	ld	ra,88(sp)
 196:	6446                	ld	s0,80(sp)
 198:	64a6                	ld	s1,72(sp)
 19a:	6906                	ld	s2,64(sp)
 19c:	79e2                	ld	s3,56(sp)
 19e:	7a42                	ld	s4,48(sp)
 1a0:	7aa2                	ld	s5,40(sp)
 1a2:	7b02                	ld	s6,32(sp)
 1a4:	6be2                	ld	s7,24(sp)
 1a6:	6125                	addi	sp,sp,96
 1a8:	8082                	ret

00000000000001aa <stat>:

int
stat(const char *n, struct stat *st)
{
 1aa:	1101                	addi	sp,sp,-32
 1ac:	ec06                	sd	ra,24(sp)
 1ae:	e822                	sd	s0,16(sp)
 1b0:	e426                	sd	s1,8(sp)
 1b2:	e04a                	sd	s2,0(sp)
 1b4:	1000                	addi	s0,sp,32
 1b6:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 1b8:	4581                	li	a1,0
 1ba:	00000097          	auipc	ra,0x0
 1be:	170080e7          	jalr	368(ra) # 32a <open>
  if(fd < 0)
 1c2:	02054563          	bltz	a0,1ec <stat+0x42>
 1c6:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 1c8:	85ca                	mv	a1,s2
 1ca:	00000097          	auipc	ra,0x0
 1ce:	178080e7          	jalr	376(ra) # 342 <fstat>
 1d2:	892a                	mv	s2,a0
  close(fd);
 1d4:	8526                	mv	a0,s1
 1d6:	00000097          	auipc	ra,0x0
 1da:	13c080e7          	jalr	316(ra) # 312 <close>
  return r;
}
 1de:	854a                	mv	a0,s2
 1e0:	60e2                	ld	ra,24(sp)
 1e2:	6442                	ld	s0,16(sp)
 1e4:	64a2                	ld	s1,8(sp)
 1e6:	6902                	ld	s2,0(sp)
 1e8:	6105                	addi	sp,sp,32
 1ea:	8082                	ret
    return -1;
 1ec:	597d                	li	s2,-1
 1ee:	bfc5                	j	1de <stat+0x34>

00000000000001f0 <atoi>:

int
atoi(const char *s)
{
 1f0:	1141                	addi	sp,sp,-16
 1f2:	e422                	sd	s0,8(sp)
 1f4:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 1f6:	00054683          	lbu	a3,0(a0)
 1fa:	fd06879b          	addiw	a5,a3,-48
 1fe:	0ff7f793          	zext.b	a5,a5
 202:	4625                	li	a2,9
 204:	02f66863          	bltu	a2,a5,234 <atoi+0x44>
 208:	872a                	mv	a4,a0
  n = 0;
 20a:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 20c:	0705                	addi	a4,a4,1
 20e:	0025179b          	slliw	a5,a0,0x2
 212:	9fa9                	addw	a5,a5,a0
 214:	0017979b          	slliw	a5,a5,0x1
 218:	9fb5                	addw	a5,a5,a3
 21a:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 21e:	00074683          	lbu	a3,0(a4)
 222:	fd06879b          	addiw	a5,a3,-48
 226:	0ff7f793          	zext.b	a5,a5
 22a:	fef671e3          	bgeu	a2,a5,20c <atoi+0x1c>
  return n;
}
 22e:	6422                	ld	s0,8(sp)
 230:	0141                	addi	sp,sp,16
 232:	8082                	ret
  n = 0;
 234:	4501                	li	a0,0
 236:	bfe5                	j	22e <atoi+0x3e>

0000000000000238 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 238:	1141                	addi	sp,sp,-16
 23a:	e422                	sd	s0,8(sp)
 23c:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 23e:	02b57463          	bgeu	a0,a1,266 <memmove+0x2e>
    while(n-- > 0)
 242:	00c05f63          	blez	a2,260 <memmove+0x28>
 246:	1602                	slli	a2,a2,0x20
 248:	9201                	srli	a2,a2,0x20
 24a:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 24e:	872a                	mv	a4,a0
      *dst++ = *src++;
 250:	0585                	addi	a1,a1,1
 252:	0705                	addi	a4,a4,1
 254:	fff5c683          	lbu	a3,-1(a1)
 258:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 25c:	fee79ae3          	bne	a5,a4,250 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 260:	6422                	ld	s0,8(sp)
 262:	0141                	addi	sp,sp,16
 264:	8082                	ret
    dst += n;
 266:	00c50733          	add	a4,a0,a2
    src += n;
 26a:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 26c:	fec05ae3          	blez	a2,260 <memmove+0x28>
 270:	fff6079b          	addiw	a5,a2,-1
 274:	1782                	slli	a5,a5,0x20
 276:	9381                	srli	a5,a5,0x20
 278:	fff7c793          	not	a5,a5
 27c:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 27e:	15fd                	addi	a1,a1,-1
 280:	177d                	addi	a4,a4,-1
 282:	0005c683          	lbu	a3,0(a1)
 286:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 28a:	fee79ae3          	bne	a5,a4,27e <memmove+0x46>
 28e:	bfc9                	j	260 <memmove+0x28>

0000000000000290 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 290:	1141                	addi	sp,sp,-16
 292:	e422                	sd	s0,8(sp)
 294:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 296:	ca05                	beqz	a2,2c6 <memcmp+0x36>
 298:	fff6069b          	addiw	a3,a2,-1
 29c:	1682                	slli	a3,a3,0x20
 29e:	9281                	srli	a3,a3,0x20
 2a0:	0685                	addi	a3,a3,1
 2a2:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 2a4:	00054783          	lbu	a5,0(a0)
 2a8:	0005c703          	lbu	a4,0(a1)
 2ac:	00e79863          	bne	a5,a4,2bc <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 2b0:	0505                	addi	a0,a0,1
    p2++;
 2b2:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 2b4:	fed518e3          	bne	a0,a3,2a4 <memcmp+0x14>
  }
  return 0;
 2b8:	4501                	li	a0,0
 2ba:	a019                	j	2c0 <memcmp+0x30>
      return *p1 - *p2;
 2bc:	40e7853b          	subw	a0,a5,a4
}
 2c0:	6422                	ld	s0,8(sp)
 2c2:	0141                	addi	sp,sp,16
 2c4:	8082                	ret
  return 0;
 2c6:	4501                	li	a0,0
 2c8:	bfe5                	j	2c0 <memcmp+0x30>

00000000000002ca <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 2ca:	1141                	addi	sp,sp,-16
 2cc:	e406                	sd	ra,8(sp)
 2ce:	e022                	sd	s0,0(sp)
 2d0:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 2d2:	00000097          	auipc	ra,0x0
 2d6:	f66080e7          	jalr	-154(ra) # 238 <memmove>
}
 2da:	60a2                	ld	ra,8(sp)
 2dc:	6402                	ld	s0,0(sp)
 2de:	0141                	addi	sp,sp,16
 2e0:	8082                	ret

00000000000002e2 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 2e2:	4885                	li	a7,1
 ecall
 2e4:	00000073          	ecall
 ret
 2e8:	8082                	ret

00000000000002ea <exit>:
.global exit
exit:
 li a7, SYS_exit
 2ea:	4889                	li	a7,2
 ecall
 2ec:	00000073          	ecall
 ret
 2f0:	8082                	ret

00000000000002f2 <wait>:
.global wait
wait:
 li a7, SYS_wait
 2f2:	488d                	li	a7,3
 ecall
 2f4:	00000073          	ecall
 ret
 2f8:	8082                	ret

00000000000002fa <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 2fa:	4891                	li	a7,4
 ecall
 2fc:	00000073          	ecall
 ret
 300:	8082                	ret

0000000000000302 <read>:
.global read
read:
 li a7, SYS_read
 302:	4895                	li	a7,5
 ecall
 304:	00000073          	ecall
 ret
 308:	8082                	ret

000000000000030a <write>:
.global write
write:
 li a7, SYS_write
 30a:	48c1                	li	a7,16
 ecall
 30c:	00000073          	ecall
 ret
 310:	8082                	ret

0000000000000312 <close>:
.global close
close:
 li a7, SYS_close
 312:	48d5                	li	a7,21
 ecall
 314:	00000073          	ecall
 ret
 318:	8082                	ret

000000000000031a <kill>:
.global kill
kill:
 li a7, SYS_kill
 31a:	4899                	li	a7,6
 ecall
 31c:	00000073          	ecall
 ret
 320:	8082                	ret

0000000000000322 <exec>:
.global exec
exec:
 li a7, SYS_exec
 322:	489d                	li	a7,7
 ecall
 324:	00000073          	ecall
 ret
 328:	8082                	ret

000000000000032a <open>:
.global open
open:
 li a7, SYS_open
 32a:	48bd                	li	a7,15
 ecall
 32c:	00000073          	ecall
 ret
 330:	8082                	ret

0000000000000332 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 332:	48c5                	li	a7,17
 ecall
 334:	00000073          	ecall
 ret
 338:	8082                	ret

000000000000033a <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 33a:	48c9                	li	a7,18
 ecall
 33c:	00000073          	ecall
 ret
 340:	8082                	ret

0000000000000342 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 342:	48a1                	li	a7,8
 ecall
 344:	00000073          	ecall
 ret
 348:	8082                	ret

000000000000034a <link>:
.global link
link:
 li a7, SYS_link
 34a:	48cd                	li	a7,19
 ecall
 34c:	00000073          	ecall
 ret
 350:	8082                	ret

0000000000000352 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 352:	48d1                	li	a7,20
 ecall
 354:	00000073          	ecall
 ret
 358:	8082                	ret

000000000000035a <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 35a:	48a5                	li	a7,9
 ecall
 35c:	00000073          	ecall
 ret
 360:	8082                	ret

0000000000000362 <dup>:
.global dup
dup:
 li a7, SYS_dup
 362:	48a9                	li	a7,10
 ecall
 364:	00000073          	ecall
 ret
 368:	8082                	ret

000000000000036a <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 36a:	48ad                	li	a7,11
 ecall
 36c:	00000073          	ecall
 ret
 370:	8082                	ret

0000000000000372 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 372:	48b1                	li	a7,12
 ecall
 374:	00000073          	ecall
 ret
 378:	8082                	ret

000000000000037a <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 37a:	48b5                	li	a7,13
 ecall
 37c:	00000073          	ecall
 ret
 380:	8082                	ret

0000000000000382 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 382:	48b9                	li	a7,14
 ecall
 384:	00000073          	ecall
 ret
 388:	8082                	ret

000000000000038a <ctime>:
.global ctime
ctime:
 li a7, SYS_ctime
 38a:	48d9                	li	a7,22
 ecall
 38c:	00000073          	ecall
 ret
 390:	8082                	ret

0000000000000392 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 392:	1101                	addi	sp,sp,-32
 394:	ec06                	sd	ra,24(sp)
 396:	e822                	sd	s0,16(sp)
 398:	1000                	addi	s0,sp,32
 39a:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 39e:	4605                	li	a2,1
 3a0:	fef40593          	addi	a1,s0,-17
 3a4:	00000097          	auipc	ra,0x0
 3a8:	f66080e7          	jalr	-154(ra) # 30a <write>
}
 3ac:	60e2                	ld	ra,24(sp)
 3ae:	6442                	ld	s0,16(sp)
 3b0:	6105                	addi	sp,sp,32
 3b2:	8082                	ret

00000000000003b4 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 3b4:	7139                	addi	sp,sp,-64
 3b6:	fc06                	sd	ra,56(sp)
 3b8:	f822                	sd	s0,48(sp)
 3ba:	f426                	sd	s1,40(sp)
 3bc:	f04a                	sd	s2,32(sp)
 3be:	ec4e                	sd	s3,24(sp)
 3c0:	0080                	addi	s0,sp,64
 3c2:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 3c4:	c299                	beqz	a3,3ca <printint+0x16>
 3c6:	0805c963          	bltz	a1,458 <printint+0xa4>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 3ca:	2581                	sext.w	a1,a1
  neg = 0;
 3cc:	4881                	li	a7,0
 3ce:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 3d2:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 3d4:	2601                	sext.w	a2,a2
 3d6:	00001517          	auipc	a0,0x1
 3da:	9f250513          	addi	a0,a0,-1550 # dc8 <digits>
 3de:	883a                	mv	a6,a4
 3e0:	2705                	addiw	a4,a4,1
 3e2:	02c5f7bb          	remuw	a5,a1,a2
 3e6:	1782                	slli	a5,a5,0x20
 3e8:	9381                	srli	a5,a5,0x20
 3ea:	97aa                	add	a5,a5,a0
 3ec:	0007c783          	lbu	a5,0(a5)
 3f0:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 3f4:	0005879b          	sext.w	a5,a1
 3f8:	02c5d5bb          	divuw	a1,a1,a2
 3fc:	0685                	addi	a3,a3,1
 3fe:	fec7f0e3          	bgeu	a5,a2,3de <printint+0x2a>
  if(neg)
 402:	00088c63          	beqz	a7,41a <printint+0x66>
    buf[i++] = '-';
 406:	fd070793          	addi	a5,a4,-48
 40a:	00878733          	add	a4,a5,s0
 40e:	02d00793          	li	a5,45
 412:	fef70823          	sb	a5,-16(a4)
 416:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 41a:	02e05863          	blez	a4,44a <printint+0x96>
 41e:	fc040793          	addi	a5,s0,-64
 422:	00e78933          	add	s2,a5,a4
 426:	fff78993          	addi	s3,a5,-1
 42a:	99ba                	add	s3,s3,a4
 42c:	377d                	addiw	a4,a4,-1
 42e:	1702                	slli	a4,a4,0x20
 430:	9301                	srli	a4,a4,0x20
 432:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 436:	fff94583          	lbu	a1,-1(s2)
 43a:	8526                	mv	a0,s1
 43c:	00000097          	auipc	ra,0x0
 440:	f56080e7          	jalr	-170(ra) # 392 <putc>
  while(--i >= 0)
 444:	197d                	addi	s2,s2,-1
 446:	ff3918e3          	bne	s2,s3,436 <printint+0x82>
}
 44a:	70e2                	ld	ra,56(sp)
 44c:	7442                	ld	s0,48(sp)
 44e:	74a2                	ld	s1,40(sp)
 450:	7902                	ld	s2,32(sp)
 452:	69e2                	ld	s3,24(sp)
 454:	6121                	addi	sp,sp,64
 456:	8082                	ret
    x = -xx;
 458:	40b005bb          	negw	a1,a1
    neg = 1;
 45c:	4885                	li	a7,1
    x = -xx;
 45e:	bf85                	j	3ce <printint+0x1a>

0000000000000460 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 460:	715d                	addi	sp,sp,-80
 462:	e486                	sd	ra,72(sp)
 464:	e0a2                	sd	s0,64(sp)
 466:	fc26                	sd	s1,56(sp)
 468:	f84a                	sd	s2,48(sp)
 46a:	f44e                	sd	s3,40(sp)
 46c:	f052                	sd	s4,32(sp)
 46e:	ec56                	sd	s5,24(sp)
 470:	e85a                	sd	s6,16(sp)
 472:	e45e                	sd	s7,8(sp)
 474:	e062                	sd	s8,0(sp)
 476:	0880                	addi	s0,sp,80
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 478:	0005c903          	lbu	s2,0(a1)
 47c:	18090c63          	beqz	s2,614 <vprintf+0x1b4>
 480:	8aaa                	mv	s5,a0
 482:	8bb2                	mv	s7,a2
 484:	00158493          	addi	s1,a1,1
  state = 0;
 488:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 48a:	02500a13          	li	s4,37
 48e:	4b55                	li	s6,21
 490:	a839                	j	4ae <vprintf+0x4e>
        putc(fd, c);
 492:	85ca                	mv	a1,s2
 494:	8556                	mv	a0,s5
 496:	00000097          	auipc	ra,0x0
 49a:	efc080e7          	jalr	-260(ra) # 392 <putc>
 49e:	a019                	j	4a4 <vprintf+0x44>
    } else if(state == '%'){
 4a0:	01498d63          	beq	s3,s4,4ba <vprintf+0x5a>
  for(i = 0; fmt[i]; i++){
 4a4:	0485                	addi	s1,s1,1
 4a6:	fff4c903          	lbu	s2,-1(s1)
 4aa:	16090563          	beqz	s2,614 <vprintf+0x1b4>
    if(state == 0){
 4ae:	fe0999e3          	bnez	s3,4a0 <vprintf+0x40>
      if(c == '%'){
 4b2:	ff4910e3          	bne	s2,s4,492 <vprintf+0x32>
        state = '%';
 4b6:	89d2                	mv	s3,s4
 4b8:	b7f5                	j	4a4 <vprintf+0x44>
      if(c == 'd'){
 4ba:	13490263          	beq	s2,s4,5de <vprintf+0x17e>
 4be:	f9d9079b          	addiw	a5,s2,-99
 4c2:	0ff7f793          	zext.b	a5,a5
 4c6:	12fb6563          	bltu	s6,a5,5f0 <vprintf+0x190>
 4ca:	f9d9079b          	addiw	a5,s2,-99
 4ce:	0ff7f713          	zext.b	a4,a5
 4d2:	10eb6f63          	bltu	s6,a4,5f0 <vprintf+0x190>
 4d6:	00271793          	slli	a5,a4,0x2
 4da:	00001717          	auipc	a4,0x1
 4de:	89670713          	addi	a4,a4,-1898 # d70 <ulthread_context_switch+0x98>
 4e2:	97ba                	add	a5,a5,a4
 4e4:	439c                	lw	a5,0(a5)
 4e6:	97ba                	add	a5,a5,a4
 4e8:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
 4ea:	008b8913          	addi	s2,s7,8
 4ee:	4685                	li	a3,1
 4f0:	4629                	li	a2,10
 4f2:	000ba583          	lw	a1,0(s7)
 4f6:	8556                	mv	a0,s5
 4f8:	00000097          	auipc	ra,0x0
 4fc:	ebc080e7          	jalr	-324(ra) # 3b4 <printint>
 500:	8bca                	mv	s7,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 502:	4981                	li	s3,0
 504:	b745                	j	4a4 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 506:	008b8913          	addi	s2,s7,8
 50a:	4681                	li	a3,0
 50c:	4629                	li	a2,10
 50e:	000ba583          	lw	a1,0(s7)
 512:	8556                	mv	a0,s5
 514:	00000097          	auipc	ra,0x0
 518:	ea0080e7          	jalr	-352(ra) # 3b4 <printint>
 51c:	8bca                	mv	s7,s2
      state = 0;
 51e:	4981                	li	s3,0
 520:	b751                	j	4a4 <vprintf+0x44>
        printint(fd, va_arg(ap, int), 16, 0);
 522:	008b8913          	addi	s2,s7,8
 526:	4681                	li	a3,0
 528:	4641                	li	a2,16
 52a:	000ba583          	lw	a1,0(s7)
 52e:	8556                	mv	a0,s5
 530:	00000097          	auipc	ra,0x0
 534:	e84080e7          	jalr	-380(ra) # 3b4 <printint>
 538:	8bca                	mv	s7,s2
      state = 0;
 53a:	4981                	li	s3,0
 53c:	b7a5                	j	4a4 <vprintf+0x44>
        printptr(fd, va_arg(ap, uint64));
 53e:	008b8c13          	addi	s8,s7,8
 542:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 546:	03000593          	li	a1,48
 54a:	8556                	mv	a0,s5
 54c:	00000097          	auipc	ra,0x0
 550:	e46080e7          	jalr	-442(ra) # 392 <putc>
  putc(fd, 'x');
 554:	07800593          	li	a1,120
 558:	8556                	mv	a0,s5
 55a:	00000097          	auipc	ra,0x0
 55e:	e38080e7          	jalr	-456(ra) # 392 <putc>
 562:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 564:	00001b97          	auipc	s7,0x1
 568:	864b8b93          	addi	s7,s7,-1948 # dc8 <digits>
 56c:	03c9d793          	srli	a5,s3,0x3c
 570:	97de                	add	a5,a5,s7
 572:	0007c583          	lbu	a1,0(a5)
 576:	8556                	mv	a0,s5
 578:	00000097          	auipc	ra,0x0
 57c:	e1a080e7          	jalr	-486(ra) # 392 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 580:	0992                	slli	s3,s3,0x4
 582:	397d                	addiw	s2,s2,-1
 584:	fe0914e3          	bnez	s2,56c <vprintf+0x10c>
        printptr(fd, va_arg(ap, uint64));
 588:	8be2                	mv	s7,s8
      state = 0;
 58a:	4981                	li	s3,0
 58c:	bf21                	j	4a4 <vprintf+0x44>
        s = va_arg(ap, char*);
 58e:	008b8993          	addi	s3,s7,8
 592:	000bb903          	ld	s2,0(s7)
        if(s == 0)
 596:	02090163          	beqz	s2,5b8 <vprintf+0x158>
        while(*s != 0){
 59a:	00094583          	lbu	a1,0(s2)
 59e:	c9a5                	beqz	a1,60e <vprintf+0x1ae>
          putc(fd, *s);
 5a0:	8556                	mv	a0,s5
 5a2:	00000097          	auipc	ra,0x0
 5a6:	df0080e7          	jalr	-528(ra) # 392 <putc>
          s++;
 5aa:	0905                	addi	s2,s2,1
        while(*s != 0){
 5ac:	00094583          	lbu	a1,0(s2)
 5b0:	f9e5                	bnez	a1,5a0 <vprintf+0x140>
        s = va_arg(ap, char*);
 5b2:	8bce                	mv	s7,s3
      state = 0;
 5b4:	4981                	li	s3,0
 5b6:	b5fd                	j	4a4 <vprintf+0x44>
          s = "(null)";
 5b8:	00000917          	auipc	s2,0x0
 5bc:	7b090913          	addi	s2,s2,1968 # d68 <ulthread_context_switch+0x90>
        while(*s != 0){
 5c0:	02800593          	li	a1,40
 5c4:	bff1                	j	5a0 <vprintf+0x140>
        putc(fd, va_arg(ap, uint));
 5c6:	008b8913          	addi	s2,s7,8
 5ca:	000bc583          	lbu	a1,0(s7)
 5ce:	8556                	mv	a0,s5
 5d0:	00000097          	auipc	ra,0x0
 5d4:	dc2080e7          	jalr	-574(ra) # 392 <putc>
 5d8:	8bca                	mv	s7,s2
      state = 0;
 5da:	4981                	li	s3,0
 5dc:	b5e1                	j	4a4 <vprintf+0x44>
        putc(fd, c);
 5de:	02500593          	li	a1,37
 5e2:	8556                	mv	a0,s5
 5e4:	00000097          	auipc	ra,0x0
 5e8:	dae080e7          	jalr	-594(ra) # 392 <putc>
      state = 0;
 5ec:	4981                	li	s3,0
 5ee:	bd5d                	j	4a4 <vprintf+0x44>
        putc(fd, '%');
 5f0:	02500593          	li	a1,37
 5f4:	8556                	mv	a0,s5
 5f6:	00000097          	auipc	ra,0x0
 5fa:	d9c080e7          	jalr	-612(ra) # 392 <putc>
        putc(fd, c);
 5fe:	85ca                	mv	a1,s2
 600:	8556                	mv	a0,s5
 602:	00000097          	auipc	ra,0x0
 606:	d90080e7          	jalr	-624(ra) # 392 <putc>
      state = 0;
 60a:	4981                	li	s3,0
 60c:	bd61                	j	4a4 <vprintf+0x44>
        s = va_arg(ap, char*);
 60e:	8bce                	mv	s7,s3
      state = 0;
 610:	4981                	li	s3,0
 612:	bd49                	j	4a4 <vprintf+0x44>
    }
  }
}
 614:	60a6                	ld	ra,72(sp)
 616:	6406                	ld	s0,64(sp)
 618:	74e2                	ld	s1,56(sp)
 61a:	7942                	ld	s2,48(sp)
 61c:	79a2                	ld	s3,40(sp)
 61e:	7a02                	ld	s4,32(sp)
 620:	6ae2                	ld	s5,24(sp)
 622:	6b42                	ld	s6,16(sp)
 624:	6ba2                	ld	s7,8(sp)
 626:	6c02                	ld	s8,0(sp)
 628:	6161                	addi	sp,sp,80
 62a:	8082                	ret

000000000000062c <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 62c:	715d                	addi	sp,sp,-80
 62e:	ec06                	sd	ra,24(sp)
 630:	e822                	sd	s0,16(sp)
 632:	1000                	addi	s0,sp,32
 634:	e010                	sd	a2,0(s0)
 636:	e414                	sd	a3,8(s0)
 638:	e818                	sd	a4,16(s0)
 63a:	ec1c                	sd	a5,24(s0)
 63c:	03043023          	sd	a6,32(s0)
 640:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 644:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 648:	8622                	mv	a2,s0
 64a:	00000097          	auipc	ra,0x0
 64e:	e16080e7          	jalr	-490(ra) # 460 <vprintf>
}
 652:	60e2                	ld	ra,24(sp)
 654:	6442                	ld	s0,16(sp)
 656:	6161                	addi	sp,sp,80
 658:	8082                	ret

000000000000065a <printf>:

void
printf(const char *fmt, ...)
{
 65a:	711d                	addi	sp,sp,-96
 65c:	ec06                	sd	ra,24(sp)
 65e:	e822                	sd	s0,16(sp)
 660:	1000                	addi	s0,sp,32
 662:	e40c                	sd	a1,8(s0)
 664:	e810                	sd	a2,16(s0)
 666:	ec14                	sd	a3,24(s0)
 668:	f018                	sd	a4,32(s0)
 66a:	f41c                	sd	a5,40(s0)
 66c:	03043823          	sd	a6,48(s0)
 670:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 674:	00840613          	addi	a2,s0,8
 678:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 67c:	85aa                	mv	a1,a0
 67e:	4505                	li	a0,1
 680:	00000097          	auipc	ra,0x0
 684:	de0080e7          	jalr	-544(ra) # 460 <vprintf>
}
 688:	60e2                	ld	ra,24(sp)
 68a:	6442                	ld	s0,16(sp)
 68c:	6125                	addi	sp,sp,96
 68e:	8082                	ret

0000000000000690 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 690:	1141                	addi	sp,sp,-16
 692:	e422                	sd	s0,8(sp)
 694:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 696:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 69a:	00001797          	auipc	a5,0x1
 69e:	9667b783          	ld	a5,-1690(a5) # 1000 <freep>
 6a2:	a02d                	j	6cc <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 6a4:	4618                	lw	a4,8(a2)
 6a6:	9f2d                	addw	a4,a4,a1
 6a8:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 6ac:	6398                	ld	a4,0(a5)
 6ae:	6310                	ld	a2,0(a4)
 6b0:	a83d                	j	6ee <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 6b2:	ff852703          	lw	a4,-8(a0)
 6b6:	9f31                	addw	a4,a4,a2
 6b8:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 6ba:	ff053683          	ld	a3,-16(a0)
 6be:	a091                	j	702 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 6c0:	6398                	ld	a4,0(a5)
 6c2:	00e7e463          	bltu	a5,a4,6ca <free+0x3a>
 6c6:	00e6ea63          	bltu	a3,a4,6da <free+0x4a>
{
 6ca:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 6cc:	fed7fae3          	bgeu	a5,a3,6c0 <free+0x30>
 6d0:	6398                	ld	a4,0(a5)
 6d2:	00e6e463          	bltu	a3,a4,6da <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 6d6:	fee7eae3          	bltu	a5,a4,6ca <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 6da:	ff852583          	lw	a1,-8(a0)
 6de:	6390                	ld	a2,0(a5)
 6e0:	02059813          	slli	a6,a1,0x20
 6e4:	01c85713          	srli	a4,a6,0x1c
 6e8:	9736                	add	a4,a4,a3
 6ea:	fae60de3          	beq	a2,a4,6a4 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 6ee:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 6f2:	4790                	lw	a2,8(a5)
 6f4:	02061593          	slli	a1,a2,0x20
 6f8:	01c5d713          	srli	a4,a1,0x1c
 6fc:	973e                	add	a4,a4,a5
 6fe:	fae68ae3          	beq	a3,a4,6b2 <free+0x22>
    p->s.ptr = bp->s.ptr;
 702:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 704:	00001717          	auipc	a4,0x1
 708:	8ef73e23          	sd	a5,-1796(a4) # 1000 <freep>
}
 70c:	6422                	ld	s0,8(sp)
 70e:	0141                	addi	sp,sp,16
 710:	8082                	ret

0000000000000712 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 712:	7139                	addi	sp,sp,-64
 714:	fc06                	sd	ra,56(sp)
 716:	f822                	sd	s0,48(sp)
 718:	f426                	sd	s1,40(sp)
 71a:	f04a                	sd	s2,32(sp)
 71c:	ec4e                	sd	s3,24(sp)
 71e:	e852                	sd	s4,16(sp)
 720:	e456                	sd	s5,8(sp)
 722:	e05a                	sd	s6,0(sp)
 724:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 726:	02051493          	slli	s1,a0,0x20
 72a:	9081                	srli	s1,s1,0x20
 72c:	04bd                	addi	s1,s1,15
 72e:	8091                	srli	s1,s1,0x4
 730:	0014899b          	addiw	s3,s1,1
 734:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 736:	00001517          	auipc	a0,0x1
 73a:	8ca53503          	ld	a0,-1846(a0) # 1000 <freep>
 73e:	c515                	beqz	a0,76a <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 740:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 742:	4798                	lw	a4,8(a5)
 744:	02977f63          	bgeu	a4,s1,782 <malloc+0x70>
  if(nu < 4096)
 748:	8a4e                	mv	s4,s3
 74a:	0009871b          	sext.w	a4,s3
 74e:	6685                	lui	a3,0x1
 750:	00d77363          	bgeu	a4,a3,756 <malloc+0x44>
 754:	6a05                	lui	s4,0x1
 756:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 75a:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 75e:	00001917          	auipc	s2,0x1
 762:	8a290913          	addi	s2,s2,-1886 # 1000 <freep>
  if(p == (char*)-1)
 766:	5afd                	li	s5,-1
 768:	a895                	j	7dc <malloc+0xca>
    base.s.ptr = freep = prevp = &base;
 76a:	00001797          	auipc	a5,0x1
 76e:	8b678793          	addi	a5,a5,-1866 # 1020 <base>
 772:	00001717          	auipc	a4,0x1
 776:	88f73723          	sd	a5,-1906(a4) # 1000 <freep>
 77a:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 77c:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 780:	b7e1                	j	748 <malloc+0x36>
      if(p->s.size == nunits)
 782:	02e48c63          	beq	s1,a4,7ba <malloc+0xa8>
        p->s.size -= nunits;
 786:	4137073b          	subw	a4,a4,s3
 78a:	c798                	sw	a4,8(a5)
        p += p->s.size;
 78c:	02071693          	slli	a3,a4,0x20
 790:	01c6d713          	srli	a4,a3,0x1c
 794:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 796:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 79a:	00001717          	auipc	a4,0x1
 79e:	86a73323          	sd	a0,-1946(a4) # 1000 <freep>
      return (void*)(p + 1);
 7a2:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 7a6:	70e2                	ld	ra,56(sp)
 7a8:	7442                	ld	s0,48(sp)
 7aa:	74a2                	ld	s1,40(sp)
 7ac:	7902                	ld	s2,32(sp)
 7ae:	69e2                	ld	s3,24(sp)
 7b0:	6a42                	ld	s4,16(sp)
 7b2:	6aa2                	ld	s5,8(sp)
 7b4:	6b02                	ld	s6,0(sp)
 7b6:	6121                	addi	sp,sp,64
 7b8:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 7ba:	6398                	ld	a4,0(a5)
 7bc:	e118                	sd	a4,0(a0)
 7be:	bff1                	j	79a <malloc+0x88>
  hp->s.size = nu;
 7c0:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 7c4:	0541                	addi	a0,a0,16
 7c6:	00000097          	auipc	ra,0x0
 7ca:	eca080e7          	jalr	-310(ra) # 690 <free>
  return freep;
 7ce:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 7d2:	d971                	beqz	a0,7a6 <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 7d4:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 7d6:	4798                	lw	a4,8(a5)
 7d8:	fa9775e3          	bgeu	a4,s1,782 <malloc+0x70>
    if(p == freep)
 7dc:	00093703          	ld	a4,0(s2)
 7e0:	853e                	mv	a0,a5
 7e2:	fef719e3          	bne	a4,a5,7d4 <malloc+0xc2>
  p = sbrk(nu * sizeof(Header));
 7e6:	8552                	mv	a0,s4
 7e8:	00000097          	auipc	ra,0x0
 7ec:	b8a080e7          	jalr	-1142(ra) # 372 <sbrk>
  if(p == (char*)-1)
 7f0:	fd5518e3          	bne	a0,s5,7c0 <malloc+0xae>
        return 0;
 7f4:	4501                	li	a0,0
 7f6:	bf45                	j	7a6 <malloc+0x94>

00000000000007f8 <get_current_tid>:
struct ulthread *scheduler_thread;
enum ulthread_scheduling_algorithm algorithm;

/* Get thread ID */
int get_current_tid(void)
{
 7f8:	1141                	addi	sp,sp,-16
 7fa:	e422                	sd	s0,8(sp)
 7fc:	0800                	addi	s0,sp,16
  return current_thread->tid;
}
 7fe:	00001797          	auipc	a5,0x1
 802:	81a7b783          	ld	a5,-2022(a5) # 1018 <current_thread>
 806:	43c8                	lw	a0,4(a5)
 808:	6422                	ld	s0,8(sp)
 80a:	0141                	addi	sp,sp,16
 80c:	8082                	ret

000000000000080e <roundRobin>:

void roundRobin(void)
{
 80e:	715d                	addi	sp,sp,-80
 810:	e486                	sd	ra,72(sp)
 812:	e0a2                	sd	s0,64(sp)
 814:	fc26                	sd	s1,56(sp)
 816:	f84a                	sd	s2,48(sp)
 818:	f44e                	sd	s3,40(sp)
 81a:	f052                	sd	s4,32(sp)
 81c:	ec56                	sd	s5,24(sp)
 81e:	e85a                	sd	s6,16(sp)
 820:	e45e                	sd	s7,8(sp)
 822:	e062                	sd	s8,0(sp)
 824:	0880                	addi	s0,sp,80
        struct ulthread *temp = current_thread;
        current_thread = t;
        printf("[*] ultschedule (next tid: %d)\n", get_current_tid());
        ulthread_context_switch(&temp->context, &t->context);
      }
      if (t->state == YIELD)
 826:	4a09                	li	s4,2
      if (t->state == RUNNABLE && t != scheduler_thread)
 828:	00000b97          	auipc	s7,0x0
 82c:	7e8b8b93          	addi	s7,s7,2024 # 1010 <scheduler_thread>
        struct ulthread *temp = current_thread;
 830:	00000a97          	auipc	s5,0x0
 834:	7e8a8a93          	addi	s5,s5,2024 # 1018 <current_thread>
        printf("[*] ultschedule (next tid: %d)\n", get_current_tid());
 838:	00000c17          	auipc	s8,0x0
 83c:	5a8c0c13          	addi	s8,s8,1448 # de0 <digits+0x18>
    for (t = ulthreads; t < &ulthreads[MAXULTHREADS]; t++)
 840:	00004997          	auipc	s3,0x4
 844:	d1098993          	addi	s3,s3,-752 # 4550 <ulthreads+0x3520>
 848:	a0b9                	j	896 <roundRobin+0x88>
      if (t->state == RUNNABLE && t != scheduler_thread)
 84a:	000bb783          	ld	a5,0(s7)
 84e:	02978863          	beq	a5,s1,87e <roundRobin+0x70>
        struct ulthread *temp = current_thread;
 852:	000abb03          	ld	s6,0(s5)
        current_thread = t;
 856:	009ab023          	sd	s1,0(s5)
        printf("[*] ultschedule (next tid: %d)\n", get_current_tid());
 85a:	40cc                	lw	a1,4(s1)
 85c:	8562                	mv	a0,s8
 85e:	00000097          	auipc	ra,0x0
 862:	dfc080e7          	jalr	-516(ra) # 65a <printf>
        ulthread_context_switch(&temp->context, &t->context);
 866:	01848593          	addi	a1,s1,24
 86a:	018b0513          	addi	a0,s6,24
 86e:	00000097          	auipc	ra,0x0
 872:	46a080e7          	jalr	1130(ra) # cd8 <ulthread_context_switch>
        threadAvailable = true;
 876:	874a                	mv	a4,s2
 878:	a811                	j	88c <roundRobin+0x7e>
      {
        t->state = RUNNABLE;
 87a:	0124a023          	sw	s2,0(s1)
    for (t = ulthreads; t < &ulthreads[MAXULTHREADS]; t++)
 87e:	08848493          	addi	s1,s1,136
 882:	01348963          	beq	s1,s3,894 <roundRobin+0x86>
      if (t->state == RUNNABLE && t != scheduler_thread)
 886:	409c                	lw	a5,0(s1)
 888:	fd2781e3          	beq	a5,s2,84a <roundRobin+0x3c>
      if (t->state == YIELD)
 88c:	409c                	lw	a5,0(s1)
 88e:	ff4798e3          	bne	a5,s4,87e <roundRobin+0x70>
 892:	b7e5                	j	87a <roundRobin+0x6c>
      }
    }
    if (!threadAvailable)
 894:	cb01                	beqz	a4,8a4 <roundRobin+0x96>
    bool threadAvailable = false;
 896:	4701                	li	a4,0
    for (t = ulthreads; t < &ulthreads[MAXULTHREADS]; t++)
 898:	00000497          	auipc	s1,0x0
 89c:	79848493          	addi	s1,s1,1944 # 1030 <ulthreads>
      if (t->state == RUNNABLE && t != scheduler_thread)
 8a0:	4905                	li	s2,1
 8a2:	b7d5                	j	886 <roundRobin+0x78>
    {
      break;
    }
  }
}
 8a4:	60a6                	ld	ra,72(sp)
 8a6:	6406                	ld	s0,64(sp)
 8a8:	74e2                	ld	s1,56(sp)
 8aa:	7942                	ld	s2,48(sp)
 8ac:	79a2                	ld	s3,40(sp)
 8ae:	7a02                	ld	s4,32(sp)
 8b0:	6ae2                	ld	s5,24(sp)
 8b2:	6b42                	ld	s6,16(sp)
 8b4:	6ba2                	ld	s7,8(sp)
 8b6:	6c02                	ld	s8,0(sp)
 8b8:	6161                	addi	sp,sp,80
 8ba:	8082                	ret

00000000000008bc <firstComeFirstServe>:

void firstComeFirstServe(void)
{
 8bc:	715d                	addi	sp,sp,-80
 8be:	e486                	sd	ra,72(sp)
 8c0:	e0a2                	sd	s0,64(sp)
 8c2:	fc26                	sd	s1,56(sp)
 8c4:	f84a                	sd	s2,48(sp)
 8c6:	f44e                	sd	s3,40(sp)
 8c8:	f052                	sd	s4,32(sp)
 8ca:	ec56                	sd	s5,24(sp)
 8cc:	e85a                	sd	s6,16(sp)
 8ce:	e45e                	sd	s7,8(sp)
 8d0:	e062                	sd	s8,0(sp)
 8d2:	0880                	addi	s0,sp,80
    uint64 oldest = __INT64_MAX__;
    int threadIndex = -1;
    int alternativeIndex = -1;
    for (t = ulthreads+1; t < &ulthreads[MAXULTHREADS]; t++)
    {
      if (t->state == RUNNABLE && t != scheduler_thread && t->lastTime < oldest)
 8d4:	00000b97          	auipc	s7,0x0
 8d8:	73cb8b93          	addi	s7,s7,1852 # 1010 <scheduler_thread>
    int alternativeIndex = -1;
 8dc:	5afd                	li	s5,-1
    uint64 oldest = __INT64_MAX__;
 8de:	001adb13          	srli	s6,s5,0x1
      if (t->state == RUNNABLE && t != scheduler_thread && t->lastTime < oldest)
 8e2:	4485                	li	s1,1
        oldest = t->lastTime;
        threadIndex = t->tid;
        threadAvailable = true;
      }

      if (t->state == YIELD){
 8e4:	4989                	li	s3,2
    for (t = ulthreads+1; t < &ulthreads[MAXULTHREADS]; t++)
 8e6:	00004917          	auipc	s2,0x4
 8ea:	c6a90913          	addi	s2,s2,-918 # 4550 <ulthreads+0x3520>
        break;
      }
      
    }
    label : 
      struct ulthread *temp = current_thread;
 8ee:	00000a17          	auipc	s4,0x0
 8f2:	72aa0a13          	addi	s4,s4,1834 # 1018 <current_thread>
 8f6:	a88d                	j	968 <firstComeFirstServe+0xac>
      if (t->state == RUNNABLE && t != scheduler_thread && t->lastTime < oldest)
 8f8:	00f58963          	beq	a1,a5,90a <firstComeFirstServe+0x4e>
 8fc:	6b98                	ld	a4,16(a5)
 8fe:	00c77663          	bgeu	a4,a2,90a <firstComeFirstServe+0x4e>
        threadIndex = t->tid;
 902:	0047a803          	lw	a6,4(a5)
        oldest = t->lastTime;
 906:	863a                	mv	a2,a4
        threadAvailable = true;
 908:	8526                	mv	a0,s1
    for (t = ulthreads+1; t < &ulthreads[MAXULTHREADS]; t++)
 90a:	08878793          	addi	a5,a5,136
 90e:	01278a63          	beq	a5,s2,922 <firstComeFirstServe+0x66>
      if (t->state == RUNNABLE && t != scheduler_thread && t->lastTime < oldest)
 912:	4398                	lw	a4,0(a5)
 914:	fe9702e3          	beq	a4,s1,8f8 <firstComeFirstServe+0x3c>
      if (t->state == YIELD){
 918:	ff3719e3          	bne	a4,s3,90a <firstComeFirstServe+0x4e>
        t->state = RUNNABLE;
 91c:	c384                	sw	s1,0(a5)
        alternativeIndex = t->tid;
 91e:	43d4                	lw	a3,4(a5)
 920:	b7ed                	j	90a <firstComeFirstServe+0x4e>
    if (!threadAvailable)
 922:	ed31                	bnez	a0,97e <firstComeFirstServe+0xc2>
      if(alternativeIndex > 0){
 924:	04d05f63          	blez	a3,982 <firstComeFirstServe+0xc6>
      struct ulthread *temp = current_thread;
 928:	000a3c03          	ld	s8,0(s4)
      current_thread = &ulthreads[threadIndex];
 92c:	00469793          	slli	a5,a3,0x4
 930:	00d78733          	add	a4,a5,a3
 934:	070e                	slli	a4,a4,0x3
 936:	00000617          	auipc	a2,0x0
 93a:	6fa60613          	addi	a2,a2,1786 # 1030 <ulthreads>
 93e:	9732                	add	a4,a4,a2
 940:	00ea3023          	sd	a4,0(s4)
      printf("[*] ultschedule (next tid: %d), time = %d\n", get_current_tid());
 944:	434c                	lw	a1,4(a4)
 946:	00000517          	auipc	a0,0x0
 94a:	4ba50513          	addi	a0,a0,1210 # e00 <digits+0x38>
 94e:	00000097          	auipc	ra,0x0
 952:	d0c080e7          	jalr	-756(ra) # 65a <printf>
      ulthread_context_switch(&temp->context, &current_thread->context);
 956:	000a3583          	ld	a1,0(s4)
 95a:	05e1                	addi	a1,a1,24
 95c:	018c0513          	addi	a0,s8,24
 960:	00000097          	auipc	ra,0x0
 964:	378080e7          	jalr	888(ra) # cd8 <ulthread_context_switch>
      if (t->state == RUNNABLE && t != scheduler_thread && t->lastTime < oldest)
 968:	000bb583          	ld	a1,0(s7)
    int alternativeIndex = -1;
 96c:	86d6                	mv	a3,s5
    int threadIndex = -1;
 96e:	8856                	mv	a6,s5
    uint64 oldest = __INT64_MAX__;
 970:	865a                	mv	a2,s6
    bool threadAvailable = false;
 972:	4501                	li	a0,0
    for (t = ulthreads+1; t < &ulthreads[MAXULTHREADS]; t++)
 974:	00000797          	auipc	a5,0x0
 978:	74478793          	addi	a5,a5,1860 # 10b8 <ulthreads+0x88>
 97c:	bf59                	j	912 <firstComeFirstServe+0x56>
    label : 
 97e:	86c2                	mv	a3,a6
 980:	b765                	j	928 <firstComeFirstServe+0x6c>
  }
}
 982:	60a6                	ld	ra,72(sp)
 984:	6406                	ld	s0,64(sp)
 986:	74e2                	ld	s1,56(sp)
 988:	7942                	ld	s2,48(sp)
 98a:	79a2                	ld	s3,40(sp)
 98c:	7a02                	ld	s4,32(sp)
 98e:	6ae2                	ld	s5,24(sp)
 990:	6b42                	ld	s6,16(sp)
 992:	6ba2                	ld	s7,8(sp)
 994:	6c02                	ld	s8,0(sp)
 996:	6161                	addi	sp,sp,80
 998:	8082                	ret

000000000000099a <priorityScheduling>:


void priorityScheduling(void)
{
 99a:	715d                	addi	sp,sp,-80
 99c:	e486                	sd	ra,72(sp)
 99e:	e0a2                	sd	s0,64(sp)
 9a0:	fc26                	sd	s1,56(sp)
 9a2:	f84a                	sd	s2,48(sp)
 9a4:	f44e                	sd	s3,40(sp)
 9a6:	f052                	sd	s4,32(sp)
 9a8:	ec56                	sd	s5,24(sp)
 9aa:	e85a                	sd	s6,16(sp)
 9ac:	e45e                	sd	s7,8(sp)
 9ae:	0880                	addi	s0,sp,80
    int maxPriority = -1;
    int threadIndex = -1;
    int alternativeIndex = -1;
    for (t = ulthreads+1; t < &ulthreads[MAXULTHREADS]; t++)
    {
      if (t->state == RUNNABLE && t != scheduler_thread && t->priority > maxPriority)
 9b0:	00000b17          	auipc	s6,0x0
 9b4:	660b0b13          	addi	s6,s6,1632 # 1010 <scheduler_thread>
    int alternativeIndex = -1;
 9b8:	5a7d                	li	s4,-1
      if (t->state == RUNNABLE && t != scheduler_thread && t->priority > maxPriority)
 9ba:	4485                	li	s1,1
        // flag = true;

        // break; // switch to highest-priority thread and exit loop
      }

      if (t->state == YIELD){
 9bc:	4989                	li	s3,2
    for (t = ulthreads+1; t < &ulthreads[MAXULTHREADS]; t++)
 9be:	00004917          	auipc	s2,0x4
 9c2:	b9290913          	addi	s2,s2,-1134 # 4550 <ulthreads+0x3520>
        break;
      }
      
    }
    label : 
      struct ulthread *temp = current_thread;
 9c6:	00000a97          	auipc	s5,0x0
 9ca:	652a8a93          	addi	s5,s5,1618 # 1018 <current_thread>
 9ce:	a88d                	j	a40 <priorityScheduling+0xa6>
      if (t->state == RUNNABLE && t != scheduler_thread && t->priority > maxPriority)
 9d0:	00f58963          	beq	a1,a5,9e2 <priorityScheduling+0x48>
 9d4:	47d8                	lw	a4,12(a5)
 9d6:	00e65663          	bge	a2,a4,9e2 <priorityScheduling+0x48>
        threadIndex = t->tid;
 9da:	0047a803          	lw	a6,4(a5)
        maxPriority = t->priority;
 9de:	863a                	mv	a2,a4
        threadAvailable = true;
 9e0:	8526                	mv	a0,s1
    for (t = ulthreads+1; t < &ulthreads[MAXULTHREADS]; t++)
 9e2:	08878793          	addi	a5,a5,136
 9e6:	01278a63          	beq	a5,s2,9fa <priorityScheduling+0x60>
      if (t->state == RUNNABLE && t != scheduler_thread && t->priority > maxPriority)
 9ea:	4398                	lw	a4,0(a5)
 9ec:	fe9702e3          	beq	a4,s1,9d0 <priorityScheduling+0x36>
      if (t->state == YIELD){
 9f0:	ff3719e3          	bne	a4,s3,9e2 <priorityScheduling+0x48>
        t->state = RUNNABLE;
 9f4:	c384                	sw	s1,0(a5)
        alternativeIndex = t->tid;
 9f6:	43d4                	lw	a3,4(a5)
 9f8:	b7ed                	j	9e2 <priorityScheduling+0x48>
    if (!threadAvailable)
 9fa:	ed31                	bnez	a0,a56 <priorityScheduling+0xbc>
      if(alternativeIndex > 0){
 9fc:	04d05f63          	blez	a3,a5a <priorityScheduling+0xc0>
      struct ulthread *temp = current_thread;
 a00:	000abb83          	ld	s7,0(s5)
      current_thread = &ulthreads[threadIndex];
 a04:	00469793          	slli	a5,a3,0x4
 a08:	00d78733          	add	a4,a5,a3
 a0c:	070e                	slli	a4,a4,0x3
 a0e:	00000617          	auipc	a2,0x0
 a12:	62260613          	addi	a2,a2,1570 # 1030 <ulthreads>
 a16:	9732                	add	a4,a4,a2
 a18:	00eab023          	sd	a4,0(s5)
      printf("[*] ultschedule (next tid: %d)\n", get_current_tid());
 a1c:	434c                	lw	a1,4(a4)
 a1e:	00000517          	auipc	a0,0x0
 a22:	3c250513          	addi	a0,a0,962 # de0 <digits+0x18>
 a26:	00000097          	auipc	ra,0x0
 a2a:	c34080e7          	jalr	-972(ra) # 65a <printf>
      ulthread_context_switch(&temp->context, &current_thread->context);
 a2e:	000ab583          	ld	a1,0(s5)
 a32:	05e1                	addi	a1,a1,24
 a34:	018b8513          	addi	a0,s7,24
 a38:	00000097          	auipc	ra,0x0
 a3c:	2a0080e7          	jalr	672(ra) # cd8 <ulthread_context_switch>
      if (t->state == RUNNABLE && t != scheduler_thread && t->priority > maxPriority)
 a40:	000b3583          	ld	a1,0(s6)
    int alternativeIndex = -1;
 a44:	86d2                	mv	a3,s4
    int threadIndex = -1;
 a46:	8852                	mv	a6,s4
    int maxPriority = -1;
 a48:	8652                	mv	a2,s4
    bool threadAvailable = false;
 a4a:	4501                	li	a0,0
    for (t = ulthreads+1; t < &ulthreads[MAXULTHREADS]; t++)
 a4c:	00000797          	auipc	a5,0x0
 a50:	66c78793          	addi	a5,a5,1644 # 10b8 <ulthreads+0x88>
 a54:	bf59                	j	9ea <priorityScheduling+0x50>
    label : 
 a56:	86c2                	mv	a3,a6
 a58:	b765                	j	a00 <priorityScheduling+0x66>
  }
}
 a5a:	60a6                	ld	ra,72(sp)
 a5c:	6406                	ld	s0,64(sp)
 a5e:	74e2                	ld	s1,56(sp)
 a60:	7942                	ld	s2,48(sp)
 a62:	79a2                	ld	s3,40(sp)
 a64:	7a02                	ld	s4,32(sp)
 a66:	6ae2                	ld	s5,24(sp)
 a68:	6b42                	ld	s6,16(sp)
 a6a:	6ba2                	ld	s7,8(sp)
 a6c:	6161                	addi	sp,sp,80
 a6e:	8082                	ret

0000000000000a70 <ulthread_init>:

/* Thread initialization */
void ulthread_init(int schedalgo)
{
 a70:	1141                	addi	sp,sp,-16
 a72:	e422                	sd	s0,8(sp)
 a74:	0800                	addi	s0,sp,16
  struct ulthread *t;
  int i;
  for (i = 0, t = ulthreads; t < &ulthreads[MAXULTHREADS]; t++, i++)
 a76:	4701                	li	a4,0
 a78:	00000797          	auipc	a5,0x0
 a7c:	5b878793          	addi	a5,a5,1464 # 1030 <ulthreads>
 a80:	00004697          	auipc	a3,0x4
 a84:	ad068693          	addi	a3,a3,-1328 # 4550 <ulthreads+0x3520>
  {
    t->state = FREE;
 a88:	0007a023          	sw	zero,0(a5)
    t->tid = i;
 a8c:	c3d8                	sw	a4,4(a5)
  for (i = 0, t = ulthreads; t < &ulthreads[MAXULTHREADS]; t++, i++)
 a8e:	08878793          	addi	a5,a5,136
 a92:	2705                	addiw	a4,a4,1
 a94:	fed79ae3          	bne	a5,a3,a88 <ulthread_init+0x18>
  }
  current_thread = &ulthreads[0];
 a98:	00000797          	auipc	a5,0x0
 a9c:	59878793          	addi	a5,a5,1432 # 1030 <ulthreads>
 aa0:	00000717          	auipc	a4,0x0
 aa4:	56f73c23          	sd	a5,1400(a4) # 1018 <current_thread>
  scheduler_thread = &ulthreads[0];
 aa8:	00000717          	auipc	a4,0x0
 aac:	56f73423          	sd	a5,1384(a4) # 1010 <scheduler_thread>
  scheduler_thread->state = RUNNABLE;
 ab0:	4705                	li	a4,1
 ab2:	c398                	sw	a4,0(a5)
  t->state = FREE;
 ab4:	00004797          	auipc	a5,0x4
 ab8:	a807ae23          	sw	zero,-1380(a5) # 4550 <ulthreads+0x3520>
  algorithm = schedalgo;
 abc:	00000797          	auipc	a5,0x0
 ac0:	54a7a623          	sw	a0,1356(a5) # 1008 <algorithm>
}
 ac4:	6422                	ld	s0,8(sp)
 ac6:	0141                	addi	sp,sp,16
 ac8:	8082                	ret

0000000000000aca <ulthread_create>:

/* Thread creation */
bool ulthread_create(uint64 start, uint64 stack, uint64 args[], int priority)
{
 aca:	7179                	addi	sp,sp,-48
 acc:	f406                	sd	ra,40(sp)
 ace:	f022                	sd	s0,32(sp)
 ad0:	ec26                	sd	s1,24(sp)
 ad2:	e84a                	sd	s2,16(sp)
 ad4:	e44e                	sd	s3,8(sp)
 ad6:	e052                	sd	s4,0(sp)
 ad8:	1800                	addi	s0,sp,48
 ada:	89aa                	mv	s3,a0
 adc:	8a2e                	mv	s4,a1
 ade:	8932                	mv	s2,a2
  /* Please add thread-id instead of '0' here. */
  struct ulthread *t;
  bool flag = false;
  for (t = ulthreads; t < &ulthreads[MAXULTHREADS]; t++)
 ae0:	00000497          	auipc	s1,0x0
 ae4:	55048493          	addi	s1,s1,1360 # 1030 <ulthreads>
 ae8:	00004717          	auipc	a4,0x4
 aec:	a6870713          	addi	a4,a4,-1432 # 4550 <ulthreads+0x3520>
  {
    if (t->state == FREE)
 af0:	409c                	lw	a5,0(s1)
 af2:	cf89                	beqz	a5,b0c <ulthread_create+0x42>
  for (t = ulthreads; t < &ulthreads[MAXULTHREADS]; t++)
 af4:	08848493          	addi	s1,s1,136
 af8:	fee49ce3          	bne	s1,a4,af0 <ulthread_create+0x26>
      break;
    }
  }
  if (!flag)
  {
    return false;
 afc:	4501                	li	a0,0
 afe:	a871                	j	b9a <ulthread_create+0xd0>
  t->sp = (int)(stack + USTACKSIZE); // set sp to the top of the stack
  t->state = RUNNABLE;
  t->priority = priority;

  if(algorithm==FCFS){
    t->lastTime = ctime();
 b00:	00000097          	auipc	ra,0x0
 b04:	88a080e7          	jalr	-1910(ra) # 38a <ctime>
 b08:	e888                	sd	a0,16(s1)
 b0a:	a839                	j	b28 <ulthread_create+0x5e>
  t->sp = (int)(stack + USTACKSIZE); // set sp to the top of the stack
 b0c:	6785                	lui	a5,0x1
 b0e:	014787bb          	addw	a5,a5,s4
 b12:	c49c                	sw	a5,8(s1)
  t->state = RUNNABLE;
 b14:	4785                	li	a5,1
 b16:	c09c                	sw	a5,0(s1)
  t->priority = priority;
 b18:	c4d4                	sw	a3,12(s1)
  if(algorithm==FCFS){
 b1a:	00000717          	auipc	a4,0x0
 b1e:	4ee72703          	lw	a4,1262(a4) # 1008 <algorithm>
 b22:	4789                	li	a5,2
 b24:	fcf70ee3          	beq	a4,a5,b00 <ulthread_create+0x36>
  }

  for (int argc = 0; argc < 6; argc++)
 b28:	874a                	mv	a4,s2
 b2a:	03090693          	addi	a3,s2,48
  {
    t->sp -= 16;
 b2e:	449c                	lw	a5,8(s1)
 b30:	37c1                	addiw	a5,a5,-16 # ff0 <digits+0x228>
 b32:	0007881b          	sext.w	a6,a5
 b36:	c49c                	sw	a5,8(s1)
    *(uint64 *)(t->sp) = (uint64)args[argc];
 b38:	631c                	ld	a5,0(a4)
 b3a:	00f83023          	sd	a5,0(a6)
  for (int argc = 0; argc < 6; argc++)
 b3e:	0721                	addi	a4,a4,8
 b40:	fed717e3          	bne	a4,a3,b2e <ulthread_create+0x64>
  }

  memset(&t->context, 0, sizeof(t->context));
 b44:	07000613          	li	a2,112
 b48:	4581                	li	a1,0
 b4a:	01848513          	addi	a0,s1,24
 b4e:	fffff097          	auipc	ra,0xfffff
 b52:	5a2080e7          	jalr	1442(ra) # f0 <memset>
  t->context.ra = start;
 b56:	0134bc23          	sd	s3,24(s1)
  t->context.sp = t->sp;
 b5a:	449c                	lw	a5,8(s1)
 b5c:	f09c                	sd	a5,32(s1)
  t->context.s0 = args[0];
 b5e:	00093783          	ld	a5,0(s2)
 b62:	f49c                	sd	a5,40(s1)
  t->context.s1 = args[1];
 b64:	00893783          	ld	a5,8(s2)
 b68:	f89c                	sd	a5,48(s1)
  t->context.s2 = args[2];
 b6a:	01093783          	ld	a5,16(s2)
 b6e:	fc9c                	sd	a5,56(s1)
  t->context.s3 = args[3];
 b70:	01893783          	ld	a5,24(s2)
 b74:	e0bc                	sd	a5,64(s1)
  t->context.s4 = args[4];
 b76:	02093783          	ld	a5,32(s2)
 b7a:	e4bc                	sd	a5,72(s1)
  t->context.s5 = args[5];
 b7c:	02893783          	ld	a5,40(s2)
 b80:	e8bc                	sd	a5,80(s1)

  printf("[*] ultcreate(tid: %d, ra: %p, sp: %p)\n", t->tid, start, stack);
 b82:	86d2                	mv	a3,s4
 b84:	864e                	mv	a2,s3
 b86:	40cc                	lw	a1,4(s1)
 b88:	00000517          	auipc	a0,0x0
 b8c:	2a850513          	addi	a0,a0,680 # e30 <digits+0x68>
 b90:	00000097          	auipc	ra,0x0
 b94:	aca080e7          	jalr	-1334(ra) # 65a <printf>
  return true;
 b98:	4505                	li	a0,1
}
 b9a:	70a2                	ld	ra,40(sp)
 b9c:	7402                	ld	s0,32(sp)
 b9e:	64e2                	ld	s1,24(sp)
 ba0:	6942                	ld	s2,16(sp)
 ba2:	69a2                	ld	s3,8(sp)
 ba4:	6a02                	ld	s4,0(sp)
 ba6:	6145                	addi	sp,sp,48
 ba8:	8082                	ret

0000000000000baa <ulthread_schedule>:

/* Thread scheduler */
void ulthread_schedule(void)
{
 baa:	1141                	addi	sp,sp,-16
 bac:	e406                	sd	ra,8(sp)
 bae:	e022                	sd	s0,0(sp)
 bb0:	0800                	addi	s0,sp,16
  switch (algorithm)
 bb2:	00000797          	auipc	a5,0x0
 bb6:	4567a783          	lw	a5,1110(a5) # 1008 <algorithm>
 bba:	4705                	li	a4,1
 bbc:	02e78463          	beq	a5,a4,be4 <ulthread_schedule+0x3a>
 bc0:	4709                	li	a4,2
 bc2:	00e78c63          	beq	a5,a4,bda <ulthread_schedule+0x30>
 bc6:	c789                	beqz	a5,bd0 <ulthread_schedule+0x26>

  // Push argument strings, prepare rest of stack in ustack.

  // Switch between thread contexts
  // ulthread_context_switch(NULL, NULL);
}
 bc8:	60a2                	ld	ra,8(sp)
 bca:	6402                	ld	s0,0(sp)
 bcc:	0141                	addi	sp,sp,16
 bce:	8082                	ret
    roundRobin();
 bd0:	00000097          	auipc	ra,0x0
 bd4:	c3e080e7          	jalr	-962(ra) # 80e <roundRobin>
    break;
 bd8:	bfc5                	j	bc8 <ulthread_schedule+0x1e>
    firstComeFirstServe();
 bda:	00000097          	auipc	ra,0x0
 bde:	ce2080e7          	jalr	-798(ra) # 8bc <firstComeFirstServe>
    break;
 be2:	b7dd                	j	bc8 <ulthread_schedule+0x1e>
    priorityScheduling();
 be4:	00000097          	auipc	ra,0x0
 be8:	db6080e7          	jalr	-586(ra) # 99a <priorityScheduling>
}
 bec:	bff1                	j	bc8 <ulthread_schedule+0x1e>

0000000000000bee <ulthread_yield>:

/* Yield CPU time to some other thread. */
void ulthread_yield(void)
{
 bee:	1101                	addi	sp,sp,-32
 bf0:	ec06                	sd	ra,24(sp)
 bf2:	e822                	sd	s0,16(sp)
 bf4:	e426                	sd	s1,8(sp)
 bf6:	e04a                	sd	s2,0(sp)
 bf8:	1000                	addi	s0,sp,32
  current_thread->state = YIELD;
 bfa:	00000797          	auipc	a5,0x0
 bfe:	41e78793          	addi	a5,a5,1054 # 1018 <current_thread>
 c02:	6398                	ld	a4,0(a5)
 c04:	4909                	li	s2,2
 c06:	01272023          	sw	s2,0(a4)
  struct ulthread *temp = current_thread;
 c0a:	6384                	ld	s1,0(a5)
  printf("[*] ultyield(tid: %d)\n", current_thread->tid);
 c0c:	40cc                	lw	a1,4(s1)
 c0e:	00000517          	auipc	a0,0x0
 c12:	24a50513          	addi	a0,a0,586 # e58 <digits+0x90>
 c16:	00000097          	auipc	ra,0x0
 c1a:	a44080e7          	jalr	-1468(ra) # 65a <printf>
  if(algorithm==FCFS){
 c1e:	00000797          	auipc	a5,0x0
 c22:	3ea7a783          	lw	a5,1002(a5) # 1008 <algorithm>
 c26:	03278763          	beq	a5,s2,c54 <ulthread_yield+0x66>
    current_thread->lastTime = ctime();
  }
  current_thread = scheduler_thread;
 c2a:	00000597          	auipc	a1,0x0
 c2e:	3e65b583          	ld	a1,998(a1) # 1010 <scheduler_thread>
 c32:	00000797          	auipc	a5,0x0
 c36:	3eb7b323          	sd	a1,998(a5) # 1018 <current_thread>
  
  ulthread_context_switch(&temp->context, &scheduler_thread->context);
 c3a:	05e1                	addi	a1,a1,24
 c3c:	01848513          	addi	a0,s1,24
 c40:	00000097          	auipc	ra,0x0
 c44:	098080e7          	jalr	152(ra) # cd8 <ulthread_context_switch>
  // ulthread_schedule();
}
 c48:	60e2                	ld	ra,24(sp)
 c4a:	6442                	ld	s0,16(sp)
 c4c:	64a2                	ld	s1,8(sp)
 c4e:	6902                	ld	s2,0(sp)
 c50:	6105                	addi	sp,sp,32
 c52:	8082                	ret
    current_thread->lastTime = ctime();
 c54:	fffff097          	auipc	ra,0xfffff
 c58:	736080e7          	jalr	1846(ra) # 38a <ctime>
 c5c:	00000797          	auipc	a5,0x0
 c60:	3bc7b783          	ld	a5,956(a5) # 1018 <current_thread>
 c64:	eb88                	sd	a0,16(a5)
 c66:	b7d1                	j	c2a <ulthread_yield+0x3c>

0000000000000c68 <ulthread_destroy>:

/* Destroy thread */
void ulthread_destroy(void)
{
 c68:	1101                	addi	sp,sp,-32
 c6a:	ec06                	sd	ra,24(sp)
 c6c:	e822                	sd	s0,16(sp)
 c6e:	e426                	sd	s1,8(sp)
 c70:	e04a                	sd	s2,0(sp)
 c72:	1000                	addi	s0,sp,32
  memset(&current_thread->context, 0, sizeof(current_thread->context));
 c74:	00000497          	auipc	s1,0x0
 c78:	3a448493          	addi	s1,s1,932 # 1018 <current_thread>
 c7c:	6088                	ld	a0,0(s1)
 c7e:	07000613          	li	a2,112
 c82:	4581                	li	a1,0
 c84:	0561                	addi	a0,a0,24
 c86:	fffff097          	auipc	ra,0xfffff
 c8a:	46a080e7          	jalr	1130(ra) # f0 <memset>
  current_thread->sp = 0;
 c8e:	609c                	ld	a5,0(s1)
 c90:	0007a423          	sw	zero,8(a5)
  current_thread->priority = -1;
 c94:	577d                	li	a4,-1
 c96:	c7d8                	sw	a4,12(a5)
  current_thread->state = FREE;
 c98:	0007a023          	sw	zero,0(a5)

  struct ulthread *temp = current_thread;
 c9c:	0004b903          	ld	s2,0(s1)

  printf("[*] ultdestroy(tid: %d)\n", get_current_tid());
 ca0:	00492583          	lw	a1,4(s2)
 ca4:	00000517          	auipc	a0,0x0
 ca8:	1cc50513          	addi	a0,a0,460 # e70 <digits+0xa8>
 cac:	00000097          	auipc	ra,0x0
 cb0:	9ae080e7          	jalr	-1618(ra) # 65a <printf>
  current_thread = scheduler_thread;
 cb4:	00000597          	auipc	a1,0x0
 cb8:	35c5b583          	ld	a1,860(a1) # 1010 <scheduler_thread>
 cbc:	e08c                	sd	a1,0(s1)
  ulthread_context_switch(&temp->context, &scheduler_thread->context);
 cbe:	05e1                	addi	a1,a1,24
 cc0:	01890513          	addi	a0,s2,24
 cc4:	00000097          	auipc	ra,0x0
 cc8:	014080e7          	jalr	20(ra) # cd8 <ulthread_context_switch>
}
 ccc:	60e2                	ld	ra,24(sp)
 cce:	6442                	ld	s0,16(sp)
 cd0:	64a2                	ld	s1,8(sp)
 cd2:	6902                	ld	s2,0(sp)
 cd4:	6105                	addi	sp,sp,32
 cd6:	8082                	ret

0000000000000cd8 <ulthread_context_switch>:
 cd8:	00153023          	sd	ra,0(a0)
 cdc:	00253423          	sd	sp,8(a0)
 ce0:	e900                	sd	s0,16(a0)
 ce2:	ed04                	sd	s1,24(a0)
 ce4:	03253023          	sd	s2,32(a0)
 ce8:	03353423          	sd	s3,40(a0)
 cec:	03453823          	sd	s4,48(a0)
 cf0:	03553c23          	sd	s5,56(a0)
 cf4:	05653023          	sd	s6,64(a0)
 cf8:	05753423          	sd	s7,72(a0)
 cfc:	05853823          	sd	s8,80(a0)
 d00:	05953c23          	sd	s9,88(a0)
 d04:	07a53023          	sd	s10,96(a0)
 d08:	07b53423          	sd	s11,104(a0)
 d0c:	0005b083          	ld	ra,0(a1)
 d10:	0085b103          	ld	sp,8(a1)
 d14:	6980                	ld	s0,16(a1)
 d16:	6d84                	ld	s1,24(a1)
 d18:	0205b903          	ld	s2,32(a1)
 d1c:	0285b983          	ld	s3,40(a1)
 d20:	0305ba03          	ld	s4,48(a1)
 d24:	0385ba83          	ld	s5,56(a1)
 d28:	0405bb03          	ld	s6,64(a1)
 d2c:	0485bb83          	ld	s7,72(a1)
 d30:	0505bc03          	ld	s8,80(a1)
 d34:	0585bc83          	ld	s9,88(a1)
 d38:	0605bd03          	ld	s10,96(a1)
 d3c:	0685bd83          	ld	s11,104(a1)
 d40:	6546                	ld	a0,80(sp)
 d42:	6586                	ld	a1,64(sp)
 d44:	7642                	ld	a2,48(sp)
 d46:	7682                	ld	a3,32(sp)
 d48:	6742                	ld	a4,16(sp)
 d4a:	6782                	ld	a5,0(sp)
 d4c:	8082                	ret
