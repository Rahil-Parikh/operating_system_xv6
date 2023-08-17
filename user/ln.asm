
user/_ln:     file format elf64-littleriscv


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
   8:	1000                	addi	s0,sp,32
  if(argc != 3){
   a:	478d                	li	a5,3
   c:	02f50063          	beq	a0,a5,2c <main+0x2c>
    fprintf(2, "Usage: ln old new\n");
  10:	00001597          	auipc	a1,0x1
  14:	d4058593          	addi	a1,a1,-704 # d50 <ulthread_context_switch+0x7c>
  18:	4509                	li	a0,2
  1a:	00000097          	auipc	ra,0x0
  1e:	60e080e7          	jalr	1550(ra) # 628 <fprintf>
    exit(1);
  22:	4505                	li	a0,1
  24:	00000097          	auipc	ra,0x0
  28:	2c2080e7          	jalr	706(ra) # 2e6 <exit>
  2c:	84ae                	mv	s1,a1
  }
  if(link(argv[1], argv[2]) < 0)
  2e:	698c                	ld	a1,16(a1)
  30:	6488                	ld	a0,8(s1)
  32:	00000097          	auipc	ra,0x0
  36:	314080e7          	jalr	788(ra) # 346 <link>
  3a:	00054763          	bltz	a0,48 <main+0x48>
    fprintf(2, "link %s %s: failed\n", argv[1], argv[2]);
  exit(0);
  3e:	4501                	li	a0,0
  40:	00000097          	auipc	ra,0x0
  44:	2a6080e7          	jalr	678(ra) # 2e6 <exit>
    fprintf(2, "link %s %s: failed\n", argv[1], argv[2]);
  48:	6894                	ld	a3,16(s1)
  4a:	6490                	ld	a2,8(s1)
  4c:	00001597          	auipc	a1,0x1
  50:	d1c58593          	addi	a1,a1,-740 # d68 <ulthread_context_switch+0x94>
  54:	4509                	li	a0,2
  56:	00000097          	auipc	ra,0x0
  5a:	5d2080e7          	jalr	1490(ra) # 628 <fprintf>
  5e:	b7c5                	j	3e <main+0x3e>

0000000000000060 <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
  60:	1141                	addi	sp,sp,-16
  62:	e406                	sd	ra,8(sp)
  64:	e022                	sd	s0,0(sp)
  66:	0800                	addi	s0,sp,16
  extern int main();
  main();
  68:	00000097          	auipc	ra,0x0
  6c:	f98080e7          	jalr	-104(ra) # 0 <main>
  exit(0);
  70:	4501                	li	a0,0
  72:	00000097          	auipc	ra,0x0
  76:	274080e7          	jalr	628(ra) # 2e6 <exit>

000000000000007a <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
  7a:	1141                	addi	sp,sp,-16
  7c:	e422                	sd	s0,8(sp)
  7e:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  80:	87aa                	mv	a5,a0
  82:	0585                	addi	a1,a1,1
  84:	0785                	addi	a5,a5,1
  86:	fff5c703          	lbu	a4,-1(a1)
  8a:	fee78fa3          	sb	a4,-1(a5)
  8e:	fb75                	bnez	a4,82 <strcpy+0x8>
    ;
  return os;
}
  90:	6422                	ld	s0,8(sp)
  92:	0141                	addi	sp,sp,16
  94:	8082                	ret

0000000000000096 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  96:	1141                	addi	sp,sp,-16
  98:	e422                	sd	s0,8(sp)
  9a:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
  9c:	00054783          	lbu	a5,0(a0)
  a0:	cb91                	beqz	a5,b4 <strcmp+0x1e>
  a2:	0005c703          	lbu	a4,0(a1)
  a6:	00f71763          	bne	a4,a5,b4 <strcmp+0x1e>
    p++, q++;
  aa:	0505                	addi	a0,a0,1
  ac:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
  ae:	00054783          	lbu	a5,0(a0)
  b2:	fbe5                	bnez	a5,a2 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
  b4:	0005c503          	lbu	a0,0(a1)
}
  b8:	40a7853b          	subw	a0,a5,a0
  bc:	6422                	ld	s0,8(sp)
  be:	0141                	addi	sp,sp,16
  c0:	8082                	ret

00000000000000c2 <strlen>:

uint
strlen(const char *s)
{
  c2:	1141                	addi	sp,sp,-16
  c4:	e422                	sd	s0,8(sp)
  c6:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
  c8:	00054783          	lbu	a5,0(a0)
  cc:	cf91                	beqz	a5,e8 <strlen+0x26>
  ce:	0505                	addi	a0,a0,1
  d0:	87aa                	mv	a5,a0
  d2:	86be                	mv	a3,a5
  d4:	0785                	addi	a5,a5,1
  d6:	fff7c703          	lbu	a4,-1(a5)
  da:	ff65                	bnez	a4,d2 <strlen+0x10>
  dc:	40a6853b          	subw	a0,a3,a0
  e0:	2505                	addiw	a0,a0,1
    ;
  return n;
}
  e2:	6422                	ld	s0,8(sp)
  e4:	0141                	addi	sp,sp,16
  e6:	8082                	ret
  for(n = 0; s[n]; n++)
  e8:	4501                	li	a0,0
  ea:	bfe5                	j	e2 <strlen+0x20>

00000000000000ec <memset>:

void*
memset(void *dst, int c, uint n)
{
  ec:	1141                	addi	sp,sp,-16
  ee:	e422                	sd	s0,8(sp)
  f0:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
  f2:	ca19                	beqz	a2,108 <memset+0x1c>
  f4:	87aa                	mv	a5,a0
  f6:	1602                	slli	a2,a2,0x20
  f8:	9201                	srli	a2,a2,0x20
  fa:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
  fe:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 102:	0785                	addi	a5,a5,1
 104:	fee79de3          	bne	a5,a4,fe <memset+0x12>
  }
  return dst;
}
 108:	6422                	ld	s0,8(sp)
 10a:	0141                	addi	sp,sp,16
 10c:	8082                	ret

000000000000010e <strchr>:

char*
strchr(const char *s, char c)
{
 10e:	1141                	addi	sp,sp,-16
 110:	e422                	sd	s0,8(sp)
 112:	0800                	addi	s0,sp,16
  for(; *s; s++)
 114:	00054783          	lbu	a5,0(a0)
 118:	cb99                	beqz	a5,12e <strchr+0x20>
    if(*s == c)
 11a:	00f58763          	beq	a1,a5,128 <strchr+0x1a>
  for(; *s; s++)
 11e:	0505                	addi	a0,a0,1
 120:	00054783          	lbu	a5,0(a0)
 124:	fbfd                	bnez	a5,11a <strchr+0xc>
      return (char*)s;
  return 0;
 126:	4501                	li	a0,0
}
 128:	6422                	ld	s0,8(sp)
 12a:	0141                	addi	sp,sp,16
 12c:	8082                	ret
  return 0;
 12e:	4501                	li	a0,0
 130:	bfe5                	j	128 <strchr+0x1a>

0000000000000132 <gets>:

char*
gets(char *buf, int max)
{
 132:	711d                	addi	sp,sp,-96
 134:	ec86                	sd	ra,88(sp)
 136:	e8a2                	sd	s0,80(sp)
 138:	e4a6                	sd	s1,72(sp)
 13a:	e0ca                	sd	s2,64(sp)
 13c:	fc4e                	sd	s3,56(sp)
 13e:	f852                	sd	s4,48(sp)
 140:	f456                	sd	s5,40(sp)
 142:	f05a                	sd	s6,32(sp)
 144:	ec5e                	sd	s7,24(sp)
 146:	1080                	addi	s0,sp,96
 148:	8baa                	mv	s7,a0
 14a:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 14c:	892a                	mv	s2,a0
 14e:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 150:	4aa9                	li	s5,10
 152:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 154:	89a6                	mv	s3,s1
 156:	2485                	addiw	s1,s1,1
 158:	0344d863          	bge	s1,s4,188 <gets+0x56>
    cc = read(0, &c, 1);
 15c:	4605                	li	a2,1
 15e:	faf40593          	addi	a1,s0,-81
 162:	4501                	li	a0,0
 164:	00000097          	auipc	ra,0x0
 168:	19a080e7          	jalr	410(ra) # 2fe <read>
    if(cc < 1)
 16c:	00a05e63          	blez	a0,188 <gets+0x56>
    buf[i++] = c;
 170:	faf44783          	lbu	a5,-81(s0)
 174:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 178:	01578763          	beq	a5,s5,186 <gets+0x54>
 17c:	0905                	addi	s2,s2,1
 17e:	fd679be3          	bne	a5,s6,154 <gets+0x22>
  for(i=0; i+1 < max; ){
 182:	89a6                	mv	s3,s1
 184:	a011                	j	188 <gets+0x56>
 186:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 188:	99de                	add	s3,s3,s7
 18a:	00098023          	sb	zero,0(s3)
  return buf;
}
 18e:	855e                	mv	a0,s7
 190:	60e6                	ld	ra,88(sp)
 192:	6446                	ld	s0,80(sp)
 194:	64a6                	ld	s1,72(sp)
 196:	6906                	ld	s2,64(sp)
 198:	79e2                	ld	s3,56(sp)
 19a:	7a42                	ld	s4,48(sp)
 19c:	7aa2                	ld	s5,40(sp)
 19e:	7b02                	ld	s6,32(sp)
 1a0:	6be2                	ld	s7,24(sp)
 1a2:	6125                	addi	sp,sp,96
 1a4:	8082                	ret

00000000000001a6 <stat>:

int
stat(const char *n, struct stat *st)
{
 1a6:	1101                	addi	sp,sp,-32
 1a8:	ec06                	sd	ra,24(sp)
 1aa:	e822                	sd	s0,16(sp)
 1ac:	e426                	sd	s1,8(sp)
 1ae:	e04a                	sd	s2,0(sp)
 1b0:	1000                	addi	s0,sp,32
 1b2:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 1b4:	4581                	li	a1,0
 1b6:	00000097          	auipc	ra,0x0
 1ba:	170080e7          	jalr	368(ra) # 326 <open>
  if(fd < 0)
 1be:	02054563          	bltz	a0,1e8 <stat+0x42>
 1c2:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 1c4:	85ca                	mv	a1,s2
 1c6:	00000097          	auipc	ra,0x0
 1ca:	178080e7          	jalr	376(ra) # 33e <fstat>
 1ce:	892a                	mv	s2,a0
  close(fd);
 1d0:	8526                	mv	a0,s1
 1d2:	00000097          	auipc	ra,0x0
 1d6:	13c080e7          	jalr	316(ra) # 30e <close>
  return r;
}
 1da:	854a                	mv	a0,s2
 1dc:	60e2                	ld	ra,24(sp)
 1de:	6442                	ld	s0,16(sp)
 1e0:	64a2                	ld	s1,8(sp)
 1e2:	6902                	ld	s2,0(sp)
 1e4:	6105                	addi	sp,sp,32
 1e6:	8082                	ret
    return -1;
 1e8:	597d                	li	s2,-1
 1ea:	bfc5                	j	1da <stat+0x34>

00000000000001ec <atoi>:

int
atoi(const char *s)
{
 1ec:	1141                	addi	sp,sp,-16
 1ee:	e422                	sd	s0,8(sp)
 1f0:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 1f2:	00054683          	lbu	a3,0(a0)
 1f6:	fd06879b          	addiw	a5,a3,-48
 1fa:	0ff7f793          	zext.b	a5,a5
 1fe:	4625                	li	a2,9
 200:	02f66863          	bltu	a2,a5,230 <atoi+0x44>
 204:	872a                	mv	a4,a0
  n = 0;
 206:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 208:	0705                	addi	a4,a4,1
 20a:	0025179b          	slliw	a5,a0,0x2
 20e:	9fa9                	addw	a5,a5,a0
 210:	0017979b          	slliw	a5,a5,0x1
 214:	9fb5                	addw	a5,a5,a3
 216:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 21a:	00074683          	lbu	a3,0(a4)
 21e:	fd06879b          	addiw	a5,a3,-48
 222:	0ff7f793          	zext.b	a5,a5
 226:	fef671e3          	bgeu	a2,a5,208 <atoi+0x1c>
  return n;
}
 22a:	6422                	ld	s0,8(sp)
 22c:	0141                	addi	sp,sp,16
 22e:	8082                	ret
  n = 0;
 230:	4501                	li	a0,0
 232:	bfe5                	j	22a <atoi+0x3e>

0000000000000234 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 234:	1141                	addi	sp,sp,-16
 236:	e422                	sd	s0,8(sp)
 238:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 23a:	02b57463          	bgeu	a0,a1,262 <memmove+0x2e>
    while(n-- > 0)
 23e:	00c05f63          	blez	a2,25c <memmove+0x28>
 242:	1602                	slli	a2,a2,0x20
 244:	9201                	srli	a2,a2,0x20
 246:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 24a:	872a                	mv	a4,a0
      *dst++ = *src++;
 24c:	0585                	addi	a1,a1,1
 24e:	0705                	addi	a4,a4,1
 250:	fff5c683          	lbu	a3,-1(a1)
 254:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 258:	fee79ae3          	bne	a5,a4,24c <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 25c:	6422                	ld	s0,8(sp)
 25e:	0141                	addi	sp,sp,16
 260:	8082                	ret
    dst += n;
 262:	00c50733          	add	a4,a0,a2
    src += n;
 266:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 268:	fec05ae3          	blez	a2,25c <memmove+0x28>
 26c:	fff6079b          	addiw	a5,a2,-1
 270:	1782                	slli	a5,a5,0x20
 272:	9381                	srli	a5,a5,0x20
 274:	fff7c793          	not	a5,a5
 278:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 27a:	15fd                	addi	a1,a1,-1
 27c:	177d                	addi	a4,a4,-1
 27e:	0005c683          	lbu	a3,0(a1)
 282:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 286:	fee79ae3          	bne	a5,a4,27a <memmove+0x46>
 28a:	bfc9                	j	25c <memmove+0x28>

000000000000028c <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 28c:	1141                	addi	sp,sp,-16
 28e:	e422                	sd	s0,8(sp)
 290:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 292:	ca05                	beqz	a2,2c2 <memcmp+0x36>
 294:	fff6069b          	addiw	a3,a2,-1
 298:	1682                	slli	a3,a3,0x20
 29a:	9281                	srli	a3,a3,0x20
 29c:	0685                	addi	a3,a3,1
 29e:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 2a0:	00054783          	lbu	a5,0(a0)
 2a4:	0005c703          	lbu	a4,0(a1)
 2a8:	00e79863          	bne	a5,a4,2b8 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 2ac:	0505                	addi	a0,a0,1
    p2++;
 2ae:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 2b0:	fed518e3          	bne	a0,a3,2a0 <memcmp+0x14>
  }
  return 0;
 2b4:	4501                	li	a0,0
 2b6:	a019                	j	2bc <memcmp+0x30>
      return *p1 - *p2;
 2b8:	40e7853b          	subw	a0,a5,a4
}
 2bc:	6422                	ld	s0,8(sp)
 2be:	0141                	addi	sp,sp,16
 2c0:	8082                	ret
  return 0;
 2c2:	4501                	li	a0,0
 2c4:	bfe5                	j	2bc <memcmp+0x30>

00000000000002c6 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 2c6:	1141                	addi	sp,sp,-16
 2c8:	e406                	sd	ra,8(sp)
 2ca:	e022                	sd	s0,0(sp)
 2cc:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 2ce:	00000097          	auipc	ra,0x0
 2d2:	f66080e7          	jalr	-154(ra) # 234 <memmove>
}
 2d6:	60a2                	ld	ra,8(sp)
 2d8:	6402                	ld	s0,0(sp)
 2da:	0141                	addi	sp,sp,16
 2dc:	8082                	ret

00000000000002de <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 2de:	4885                	li	a7,1
 ecall
 2e0:	00000073          	ecall
 ret
 2e4:	8082                	ret

00000000000002e6 <exit>:
.global exit
exit:
 li a7, SYS_exit
 2e6:	4889                	li	a7,2
 ecall
 2e8:	00000073          	ecall
 ret
 2ec:	8082                	ret

00000000000002ee <wait>:
.global wait
wait:
 li a7, SYS_wait
 2ee:	488d                	li	a7,3
 ecall
 2f0:	00000073          	ecall
 ret
 2f4:	8082                	ret

00000000000002f6 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 2f6:	4891                	li	a7,4
 ecall
 2f8:	00000073          	ecall
 ret
 2fc:	8082                	ret

00000000000002fe <read>:
.global read
read:
 li a7, SYS_read
 2fe:	4895                	li	a7,5
 ecall
 300:	00000073          	ecall
 ret
 304:	8082                	ret

0000000000000306 <write>:
.global write
write:
 li a7, SYS_write
 306:	48c1                	li	a7,16
 ecall
 308:	00000073          	ecall
 ret
 30c:	8082                	ret

000000000000030e <close>:
.global close
close:
 li a7, SYS_close
 30e:	48d5                	li	a7,21
 ecall
 310:	00000073          	ecall
 ret
 314:	8082                	ret

0000000000000316 <kill>:
.global kill
kill:
 li a7, SYS_kill
 316:	4899                	li	a7,6
 ecall
 318:	00000073          	ecall
 ret
 31c:	8082                	ret

000000000000031e <exec>:
.global exec
exec:
 li a7, SYS_exec
 31e:	489d                	li	a7,7
 ecall
 320:	00000073          	ecall
 ret
 324:	8082                	ret

0000000000000326 <open>:
.global open
open:
 li a7, SYS_open
 326:	48bd                	li	a7,15
 ecall
 328:	00000073          	ecall
 ret
 32c:	8082                	ret

000000000000032e <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 32e:	48c5                	li	a7,17
 ecall
 330:	00000073          	ecall
 ret
 334:	8082                	ret

0000000000000336 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 336:	48c9                	li	a7,18
 ecall
 338:	00000073          	ecall
 ret
 33c:	8082                	ret

000000000000033e <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 33e:	48a1                	li	a7,8
 ecall
 340:	00000073          	ecall
 ret
 344:	8082                	ret

0000000000000346 <link>:
.global link
link:
 li a7, SYS_link
 346:	48cd                	li	a7,19
 ecall
 348:	00000073          	ecall
 ret
 34c:	8082                	ret

000000000000034e <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 34e:	48d1                	li	a7,20
 ecall
 350:	00000073          	ecall
 ret
 354:	8082                	ret

0000000000000356 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 356:	48a5                	li	a7,9
 ecall
 358:	00000073          	ecall
 ret
 35c:	8082                	ret

000000000000035e <dup>:
.global dup
dup:
 li a7, SYS_dup
 35e:	48a9                	li	a7,10
 ecall
 360:	00000073          	ecall
 ret
 364:	8082                	ret

0000000000000366 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 366:	48ad                	li	a7,11
 ecall
 368:	00000073          	ecall
 ret
 36c:	8082                	ret

000000000000036e <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 36e:	48b1                	li	a7,12
 ecall
 370:	00000073          	ecall
 ret
 374:	8082                	ret

0000000000000376 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 376:	48b5                	li	a7,13
 ecall
 378:	00000073          	ecall
 ret
 37c:	8082                	ret

000000000000037e <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 37e:	48b9                	li	a7,14
 ecall
 380:	00000073          	ecall
 ret
 384:	8082                	ret

0000000000000386 <ctime>:
.global ctime
ctime:
 li a7, SYS_ctime
 386:	48d9                	li	a7,22
 ecall
 388:	00000073          	ecall
 ret
 38c:	8082                	ret

000000000000038e <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 38e:	1101                	addi	sp,sp,-32
 390:	ec06                	sd	ra,24(sp)
 392:	e822                	sd	s0,16(sp)
 394:	1000                	addi	s0,sp,32
 396:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 39a:	4605                	li	a2,1
 39c:	fef40593          	addi	a1,s0,-17
 3a0:	00000097          	auipc	ra,0x0
 3a4:	f66080e7          	jalr	-154(ra) # 306 <write>
}
 3a8:	60e2                	ld	ra,24(sp)
 3aa:	6442                	ld	s0,16(sp)
 3ac:	6105                	addi	sp,sp,32
 3ae:	8082                	ret

00000000000003b0 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 3b0:	7139                	addi	sp,sp,-64
 3b2:	fc06                	sd	ra,56(sp)
 3b4:	f822                	sd	s0,48(sp)
 3b6:	f426                	sd	s1,40(sp)
 3b8:	f04a                	sd	s2,32(sp)
 3ba:	ec4e                	sd	s3,24(sp)
 3bc:	0080                	addi	s0,sp,64
 3be:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 3c0:	c299                	beqz	a3,3c6 <printint+0x16>
 3c2:	0805c963          	bltz	a1,454 <printint+0xa4>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 3c6:	2581                	sext.w	a1,a1
  neg = 0;
 3c8:	4881                	li	a7,0
 3ca:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 3ce:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 3d0:	2601                	sext.w	a2,a2
 3d2:	00001517          	auipc	a0,0x1
 3d6:	a0e50513          	addi	a0,a0,-1522 # de0 <digits>
 3da:	883a                	mv	a6,a4
 3dc:	2705                	addiw	a4,a4,1
 3de:	02c5f7bb          	remuw	a5,a1,a2
 3e2:	1782                	slli	a5,a5,0x20
 3e4:	9381                	srli	a5,a5,0x20
 3e6:	97aa                	add	a5,a5,a0
 3e8:	0007c783          	lbu	a5,0(a5)
 3ec:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 3f0:	0005879b          	sext.w	a5,a1
 3f4:	02c5d5bb          	divuw	a1,a1,a2
 3f8:	0685                	addi	a3,a3,1
 3fa:	fec7f0e3          	bgeu	a5,a2,3da <printint+0x2a>
  if(neg)
 3fe:	00088c63          	beqz	a7,416 <printint+0x66>
    buf[i++] = '-';
 402:	fd070793          	addi	a5,a4,-48
 406:	00878733          	add	a4,a5,s0
 40a:	02d00793          	li	a5,45
 40e:	fef70823          	sb	a5,-16(a4)
 412:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 416:	02e05863          	blez	a4,446 <printint+0x96>
 41a:	fc040793          	addi	a5,s0,-64
 41e:	00e78933          	add	s2,a5,a4
 422:	fff78993          	addi	s3,a5,-1
 426:	99ba                	add	s3,s3,a4
 428:	377d                	addiw	a4,a4,-1
 42a:	1702                	slli	a4,a4,0x20
 42c:	9301                	srli	a4,a4,0x20
 42e:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 432:	fff94583          	lbu	a1,-1(s2)
 436:	8526                	mv	a0,s1
 438:	00000097          	auipc	ra,0x0
 43c:	f56080e7          	jalr	-170(ra) # 38e <putc>
  while(--i >= 0)
 440:	197d                	addi	s2,s2,-1
 442:	ff3918e3          	bne	s2,s3,432 <printint+0x82>
}
 446:	70e2                	ld	ra,56(sp)
 448:	7442                	ld	s0,48(sp)
 44a:	74a2                	ld	s1,40(sp)
 44c:	7902                	ld	s2,32(sp)
 44e:	69e2                	ld	s3,24(sp)
 450:	6121                	addi	sp,sp,64
 452:	8082                	ret
    x = -xx;
 454:	40b005bb          	negw	a1,a1
    neg = 1;
 458:	4885                	li	a7,1
    x = -xx;
 45a:	bf85                	j	3ca <printint+0x1a>

000000000000045c <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 45c:	715d                	addi	sp,sp,-80
 45e:	e486                	sd	ra,72(sp)
 460:	e0a2                	sd	s0,64(sp)
 462:	fc26                	sd	s1,56(sp)
 464:	f84a                	sd	s2,48(sp)
 466:	f44e                	sd	s3,40(sp)
 468:	f052                	sd	s4,32(sp)
 46a:	ec56                	sd	s5,24(sp)
 46c:	e85a                	sd	s6,16(sp)
 46e:	e45e                	sd	s7,8(sp)
 470:	e062                	sd	s8,0(sp)
 472:	0880                	addi	s0,sp,80
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 474:	0005c903          	lbu	s2,0(a1)
 478:	18090c63          	beqz	s2,610 <vprintf+0x1b4>
 47c:	8aaa                	mv	s5,a0
 47e:	8bb2                	mv	s7,a2
 480:	00158493          	addi	s1,a1,1
  state = 0;
 484:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 486:	02500a13          	li	s4,37
 48a:	4b55                	li	s6,21
 48c:	a839                	j	4aa <vprintf+0x4e>
        putc(fd, c);
 48e:	85ca                	mv	a1,s2
 490:	8556                	mv	a0,s5
 492:	00000097          	auipc	ra,0x0
 496:	efc080e7          	jalr	-260(ra) # 38e <putc>
 49a:	a019                	j	4a0 <vprintf+0x44>
    } else if(state == '%'){
 49c:	01498d63          	beq	s3,s4,4b6 <vprintf+0x5a>
  for(i = 0; fmt[i]; i++){
 4a0:	0485                	addi	s1,s1,1
 4a2:	fff4c903          	lbu	s2,-1(s1)
 4a6:	16090563          	beqz	s2,610 <vprintf+0x1b4>
    if(state == 0){
 4aa:	fe0999e3          	bnez	s3,49c <vprintf+0x40>
      if(c == '%'){
 4ae:	ff4910e3          	bne	s2,s4,48e <vprintf+0x32>
        state = '%';
 4b2:	89d2                	mv	s3,s4
 4b4:	b7f5                	j	4a0 <vprintf+0x44>
      if(c == 'd'){
 4b6:	13490263          	beq	s2,s4,5da <vprintf+0x17e>
 4ba:	f9d9079b          	addiw	a5,s2,-99
 4be:	0ff7f793          	zext.b	a5,a5
 4c2:	12fb6563          	bltu	s6,a5,5ec <vprintf+0x190>
 4c6:	f9d9079b          	addiw	a5,s2,-99
 4ca:	0ff7f713          	zext.b	a4,a5
 4ce:	10eb6f63          	bltu	s6,a4,5ec <vprintf+0x190>
 4d2:	00271793          	slli	a5,a4,0x2
 4d6:	00001717          	auipc	a4,0x1
 4da:	8b270713          	addi	a4,a4,-1870 # d88 <ulthread_context_switch+0xb4>
 4de:	97ba                	add	a5,a5,a4
 4e0:	439c                	lw	a5,0(a5)
 4e2:	97ba                	add	a5,a5,a4
 4e4:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
 4e6:	008b8913          	addi	s2,s7,8
 4ea:	4685                	li	a3,1
 4ec:	4629                	li	a2,10
 4ee:	000ba583          	lw	a1,0(s7)
 4f2:	8556                	mv	a0,s5
 4f4:	00000097          	auipc	ra,0x0
 4f8:	ebc080e7          	jalr	-324(ra) # 3b0 <printint>
 4fc:	8bca                	mv	s7,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 4fe:	4981                	li	s3,0
 500:	b745                	j	4a0 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 502:	008b8913          	addi	s2,s7,8
 506:	4681                	li	a3,0
 508:	4629                	li	a2,10
 50a:	000ba583          	lw	a1,0(s7)
 50e:	8556                	mv	a0,s5
 510:	00000097          	auipc	ra,0x0
 514:	ea0080e7          	jalr	-352(ra) # 3b0 <printint>
 518:	8bca                	mv	s7,s2
      state = 0;
 51a:	4981                	li	s3,0
 51c:	b751                	j	4a0 <vprintf+0x44>
        printint(fd, va_arg(ap, int), 16, 0);
 51e:	008b8913          	addi	s2,s7,8
 522:	4681                	li	a3,0
 524:	4641                	li	a2,16
 526:	000ba583          	lw	a1,0(s7)
 52a:	8556                	mv	a0,s5
 52c:	00000097          	auipc	ra,0x0
 530:	e84080e7          	jalr	-380(ra) # 3b0 <printint>
 534:	8bca                	mv	s7,s2
      state = 0;
 536:	4981                	li	s3,0
 538:	b7a5                	j	4a0 <vprintf+0x44>
        printptr(fd, va_arg(ap, uint64));
 53a:	008b8c13          	addi	s8,s7,8
 53e:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 542:	03000593          	li	a1,48
 546:	8556                	mv	a0,s5
 548:	00000097          	auipc	ra,0x0
 54c:	e46080e7          	jalr	-442(ra) # 38e <putc>
  putc(fd, 'x');
 550:	07800593          	li	a1,120
 554:	8556                	mv	a0,s5
 556:	00000097          	auipc	ra,0x0
 55a:	e38080e7          	jalr	-456(ra) # 38e <putc>
 55e:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 560:	00001b97          	auipc	s7,0x1
 564:	880b8b93          	addi	s7,s7,-1920 # de0 <digits>
 568:	03c9d793          	srli	a5,s3,0x3c
 56c:	97de                	add	a5,a5,s7
 56e:	0007c583          	lbu	a1,0(a5)
 572:	8556                	mv	a0,s5
 574:	00000097          	auipc	ra,0x0
 578:	e1a080e7          	jalr	-486(ra) # 38e <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 57c:	0992                	slli	s3,s3,0x4
 57e:	397d                	addiw	s2,s2,-1
 580:	fe0914e3          	bnez	s2,568 <vprintf+0x10c>
        printptr(fd, va_arg(ap, uint64));
 584:	8be2                	mv	s7,s8
      state = 0;
 586:	4981                	li	s3,0
 588:	bf21                	j	4a0 <vprintf+0x44>
        s = va_arg(ap, char*);
 58a:	008b8993          	addi	s3,s7,8
 58e:	000bb903          	ld	s2,0(s7)
        if(s == 0)
 592:	02090163          	beqz	s2,5b4 <vprintf+0x158>
        while(*s != 0){
 596:	00094583          	lbu	a1,0(s2)
 59a:	c9a5                	beqz	a1,60a <vprintf+0x1ae>
          putc(fd, *s);
 59c:	8556                	mv	a0,s5
 59e:	00000097          	auipc	ra,0x0
 5a2:	df0080e7          	jalr	-528(ra) # 38e <putc>
          s++;
 5a6:	0905                	addi	s2,s2,1
        while(*s != 0){
 5a8:	00094583          	lbu	a1,0(s2)
 5ac:	f9e5                	bnez	a1,59c <vprintf+0x140>
        s = va_arg(ap, char*);
 5ae:	8bce                	mv	s7,s3
      state = 0;
 5b0:	4981                	li	s3,0
 5b2:	b5fd                	j	4a0 <vprintf+0x44>
          s = "(null)";
 5b4:	00000917          	auipc	s2,0x0
 5b8:	7cc90913          	addi	s2,s2,1996 # d80 <ulthread_context_switch+0xac>
        while(*s != 0){
 5bc:	02800593          	li	a1,40
 5c0:	bff1                	j	59c <vprintf+0x140>
        putc(fd, va_arg(ap, uint));
 5c2:	008b8913          	addi	s2,s7,8
 5c6:	000bc583          	lbu	a1,0(s7)
 5ca:	8556                	mv	a0,s5
 5cc:	00000097          	auipc	ra,0x0
 5d0:	dc2080e7          	jalr	-574(ra) # 38e <putc>
 5d4:	8bca                	mv	s7,s2
      state = 0;
 5d6:	4981                	li	s3,0
 5d8:	b5e1                	j	4a0 <vprintf+0x44>
        putc(fd, c);
 5da:	02500593          	li	a1,37
 5de:	8556                	mv	a0,s5
 5e0:	00000097          	auipc	ra,0x0
 5e4:	dae080e7          	jalr	-594(ra) # 38e <putc>
      state = 0;
 5e8:	4981                	li	s3,0
 5ea:	bd5d                	j	4a0 <vprintf+0x44>
        putc(fd, '%');
 5ec:	02500593          	li	a1,37
 5f0:	8556                	mv	a0,s5
 5f2:	00000097          	auipc	ra,0x0
 5f6:	d9c080e7          	jalr	-612(ra) # 38e <putc>
        putc(fd, c);
 5fa:	85ca                	mv	a1,s2
 5fc:	8556                	mv	a0,s5
 5fe:	00000097          	auipc	ra,0x0
 602:	d90080e7          	jalr	-624(ra) # 38e <putc>
      state = 0;
 606:	4981                	li	s3,0
 608:	bd61                	j	4a0 <vprintf+0x44>
        s = va_arg(ap, char*);
 60a:	8bce                	mv	s7,s3
      state = 0;
 60c:	4981                	li	s3,0
 60e:	bd49                	j	4a0 <vprintf+0x44>
    }
  }
}
 610:	60a6                	ld	ra,72(sp)
 612:	6406                	ld	s0,64(sp)
 614:	74e2                	ld	s1,56(sp)
 616:	7942                	ld	s2,48(sp)
 618:	79a2                	ld	s3,40(sp)
 61a:	7a02                	ld	s4,32(sp)
 61c:	6ae2                	ld	s5,24(sp)
 61e:	6b42                	ld	s6,16(sp)
 620:	6ba2                	ld	s7,8(sp)
 622:	6c02                	ld	s8,0(sp)
 624:	6161                	addi	sp,sp,80
 626:	8082                	ret

0000000000000628 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 628:	715d                	addi	sp,sp,-80
 62a:	ec06                	sd	ra,24(sp)
 62c:	e822                	sd	s0,16(sp)
 62e:	1000                	addi	s0,sp,32
 630:	e010                	sd	a2,0(s0)
 632:	e414                	sd	a3,8(s0)
 634:	e818                	sd	a4,16(s0)
 636:	ec1c                	sd	a5,24(s0)
 638:	03043023          	sd	a6,32(s0)
 63c:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 640:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 644:	8622                	mv	a2,s0
 646:	00000097          	auipc	ra,0x0
 64a:	e16080e7          	jalr	-490(ra) # 45c <vprintf>
}
 64e:	60e2                	ld	ra,24(sp)
 650:	6442                	ld	s0,16(sp)
 652:	6161                	addi	sp,sp,80
 654:	8082                	ret

0000000000000656 <printf>:

void
printf(const char *fmt, ...)
{
 656:	711d                	addi	sp,sp,-96
 658:	ec06                	sd	ra,24(sp)
 65a:	e822                	sd	s0,16(sp)
 65c:	1000                	addi	s0,sp,32
 65e:	e40c                	sd	a1,8(s0)
 660:	e810                	sd	a2,16(s0)
 662:	ec14                	sd	a3,24(s0)
 664:	f018                	sd	a4,32(s0)
 666:	f41c                	sd	a5,40(s0)
 668:	03043823          	sd	a6,48(s0)
 66c:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 670:	00840613          	addi	a2,s0,8
 674:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 678:	85aa                	mv	a1,a0
 67a:	4505                	li	a0,1
 67c:	00000097          	auipc	ra,0x0
 680:	de0080e7          	jalr	-544(ra) # 45c <vprintf>
}
 684:	60e2                	ld	ra,24(sp)
 686:	6442                	ld	s0,16(sp)
 688:	6125                	addi	sp,sp,96
 68a:	8082                	ret

000000000000068c <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 68c:	1141                	addi	sp,sp,-16
 68e:	e422                	sd	s0,8(sp)
 690:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 692:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 696:	00001797          	auipc	a5,0x1
 69a:	96a7b783          	ld	a5,-1686(a5) # 1000 <freep>
 69e:	a02d                	j	6c8 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 6a0:	4618                	lw	a4,8(a2)
 6a2:	9f2d                	addw	a4,a4,a1
 6a4:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 6a8:	6398                	ld	a4,0(a5)
 6aa:	6310                	ld	a2,0(a4)
 6ac:	a83d                	j	6ea <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 6ae:	ff852703          	lw	a4,-8(a0)
 6b2:	9f31                	addw	a4,a4,a2
 6b4:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 6b6:	ff053683          	ld	a3,-16(a0)
 6ba:	a091                	j	6fe <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 6bc:	6398                	ld	a4,0(a5)
 6be:	00e7e463          	bltu	a5,a4,6c6 <free+0x3a>
 6c2:	00e6ea63          	bltu	a3,a4,6d6 <free+0x4a>
{
 6c6:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 6c8:	fed7fae3          	bgeu	a5,a3,6bc <free+0x30>
 6cc:	6398                	ld	a4,0(a5)
 6ce:	00e6e463          	bltu	a3,a4,6d6 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 6d2:	fee7eae3          	bltu	a5,a4,6c6 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 6d6:	ff852583          	lw	a1,-8(a0)
 6da:	6390                	ld	a2,0(a5)
 6dc:	02059813          	slli	a6,a1,0x20
 6e0:	01c85713          	srli	a4,a6,0x1c
 6e4:	9736                	add	a4,a4,a3
 6e6:	fae60de3          	beq	a2,a4,6a0 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 6ea:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 6ee:	4790                	lw	a2,8(a5)
 6f0:	02061593          	slli	a1,a2,0x20
 6f4:	01c5d713          	srli	a4,a1,0x1c
 6f8:	973e                	add	a4,a4,a5
 6fa:	fae68ae3          	beq	a3,a4,6ae <free+0x22>
    p->s.ptr = bp->s.ptr;
 6fe:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 700:	00001717          	auipc	a4,0x1
 704:	90f73023          	sd	a5,-1792(a4) # 1000 <freep>
}
 708:	6422                	ld	s0,8(sp)
 70a:	0141                	addi	sp,sp,16
 70c:	8082                	ret

000000000000070e <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 70e:	7139                	addi	sp,sp,-64
 710:	fc06                	sd	ra,56(sp)
 712:	f822                	sd	s0,48(sp)
 714:	f426                	sd	s1,40(sp)
 716:	f04a                	sd	s2,32(sp)
 718:	ec4e                	sd	s3,24(sp)
 71a:	e852                	sd	s4,16(sp)
 71c:	e456                	sd	s5,8(sp)
 71e:	e05a                	sd	s6,0(sp)
 720:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 722:	02051493          	slli	s1,a0,0x20
 726:	9081                	srli	s1,s1,0x20
 728:	04bd                	addi	s1,s1,15
 72a:	8091                	srli	s1,s1,0x4
 72c:	0014899b          	addiw	s3,s1,1
 730:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 732:	00001517          	auipc	a0,0x1
 736:	8ce53503          	ld	a0,-1842(a0) # 1000 <freep>
 73a:	c515                	beqz	a0,766 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 73c:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 73e:	4798                	lw	a4,8(a5)
 740:	02977f63          	bgeu	a4,s1,77e <malloc+0x70>
  if(nu < 4096)
 744:	8a4e                	mv	s4,s3
 746:	0009871b          	sext.w	a4,s3
 74a:	6685                	lui	a3,0x1
 74c:	00d77363          	bgeu	a4,a3,752 <malloc+0x44>
 750:	6a05                	lui	s4,0x1
 752:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 756:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 75a:	00001917          	auipc	s2,0x1
 75e:	8a690913          	addi	s2,s2,-1882 # 1000 <freep>
  if(p == (char*)-1)
 762:	5afd                	li	s5,-1
 764:	a895                	j	7d8 <malloc+0xca>
    base.s.ptr = freep = prevp = &base;
 766:	00001797          	auipc	a5,0x1
 76a:	8ba78793          	addi	a5,a5,-1862 # 1020 <base>
 76e:	00001717          	auipc	a4,0x1
 772:	88f73923          	sd	a5,-1902(a4) # 1000 <freep>
 776:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 778:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 77c:	b7e1                	j	744 <malloc+0x36>
      if(p->s.size == nunits)
 77e:	02e48c63          	beq	s1,a4,7b6 <malloc+0xa8>
        p->s.size -= nunits;
 782:	4137073b          	subw	a4,a4,s3
 786:	c798                	sw	a4,8(a5)
        p += p->s.size;
 788:	02071693          	slli	a3,a4,0x20
 78c:	01c6d713          	srli	a4,a3,0x1c
 790:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 792:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 796:	00001717          	auipc	a4,0x1
 79a:	86a73523          	sd	a0,-1942(a4) # 1000 <freep>
      return (void*)(p + 1);
 79e:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 7a2:	70e2                	ld	ra,56(sp)
 7a4:	7442                	ld	s0,48(sp)
 7a6:	74a2                	ld	s1,40(sp)
 7a8:	7902                	ld	s2,32(sp)
 7aa:	69e2                	ld	s3,24(sp)
 7ac:	6a42                	ld	s4,16(sp)
 7ae:	6aa2                	ld	s5,8(sp)
 7b0:	6b02                	ld	s6,0(sp)
 7b2:	6121                	addi	sp,sp,64
 7b4:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 7b6:	6398                	ld	a4,0(a5)
 7b8:	e118                	sd	a4,0(a0)
 7ba:	bff1                	j	796 <malloc+0x88>
  hp->s.size = nu;
 7bc:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 7c0:	0541                	addi	a0,a0,16
 7c2:	00000097          	auipc	ra,0x0
 7c6:	eca080e7          	jalr	-310(ra) # 68c <free>
  return freep;
 7ca:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 7ce:	d971                	beqz	a0,7a2 <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 7d0:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 7d2:	4798                	lw	a4,8(a5)
 7d4:	fa9775e3          	bgeu	a4,s1,77e <malloc+0x70>
    if(p == freep)
 7d8:	00093703          	ld	a4,0(s2)
 7dc:	853e                	mv	a0,a5
 7de:	fef719e3          	bne	a4,a5,7d0 <malloc+0xc2>
  p = sbrk(nu * sizeof(Header));
 7e2:	8552                	mv	a0,s4
 7e4:	00000097          	auipc	ra,0x0
 7e8:	b8a080e7          	jalr	-1142(ra) # 36e <sbrk>
  if(p == (char*)-1)
 7ec:	fd5518e3          	bne	a0,s5,7bc <malloc+0xae>
        return 0;
 7f0:	4501                	li	a0,0
 7f2:	bf45                	j	7a2 <malloc+0x94>

00000000000007f4 <get_current_tid>:
struct ulthread *scheduler_thread;
enum ulthread_scheduling_algorithm algorithm;

/* Get thread ID */
int get_current_tid(void)
{
 7f4:	1141                	addi	sp,sp,-16
 7f6:	e422                	sd	s0,8(sp)
 7f8:	0800                	addi	s0,sp,16
  return current_thread->tid;
}
 7fa:	00001797          	auipc	a5,0x1
 7fe:	81e7b783          	ld	a5,-2018(a5) # 1018 <current_thread>
 802:	43c8                	lw	a0,4(a5)
 804:	6422                	ld	s0,8(sp)
 806:	0141                	addi	sp,sp,16
 808:	8082                	ret

000000000000080a <roundRobin>:

void roundRobin(void)
{
 80a:	715d                	addi	sp,sp,-80
 80c:	e486                	sd	ra,72(sp)
 80e:	e0a2                	sd	s0,64(sp)
 810:	fc26                	sd	s1,56(sp)
 812:	f84a                	sd	s2,48(sp)
 814:	f44e                	sd	s3,40(sp)
 816:	f052                	sd	s4,32(sp)
 818:	ec56                	sd	s5,24(sp)
 81a:	e85a                	sd	s6,16(sp)
 81c:	e45e                	sd	s7,8(sp)
 81e:	e062                	sd	s8,0(sp)
 820:	0880                	addi	s0,sp,80
        struct ulthread *temp = current_thread;
        current_thread = t;
        printf("[*] ultschedule (next tid: %d)\n", get_current_tid());
        ulthread_context_switch(&temp->context, &t->context);
      }
      if (t->state == YIELD)
 822:	4a09                	li	s4,2
      if (t->state == RUNNABLE && t != scheduler_thread)
 824:	00000b97          	auipc	s7,0x0
 828:	7ecb8b93          	addi	s7,s7,2028 # 1010 <scheduler_thread>
        struct ulthread *temp = current_thread;
 82c:	00000a97          	auipc	s5,0x0
 830:	7eca8a93          	addi	s5,s5,2028 # 1018 <current_thread>
        printf("[*] ultschedule (next tid: %d)\n", get_current_tid());
 834:	00000c17          	auipc	s8,0x0
 838:	5c4c0c13          	addi	s8,s8,1476 # df8 <digits+0x18>
    for (t = ulthreads; t < &ulthreads[MAXULTHREADS]; t++)
 83c:	00004997          	auipc	s3,0x4
 840:	d1498993          	addi	s3,s3,-748 # 4550 <ulthreads+0x3520>
 844:	a0b9                	j	892 <roundRobin+0x88>
      if (t->state == RUNNABLE && t != scheduler_thread)
 846:	000bb783          	ld	a5,0(s7)
 84a:	02978863          	beq	a5,s1,87a <roundRobin+0x70>
        struct ulthread *temp = current_thread;
 84e:	000abb03          	ld	s6,0(s5)
        current_thread = t;
 852:	009ab023          	sd	s1,0(s5)
        printf("[*] ultschedule (next tid: %d)\n", get_current_tid());
 856:	40cc                	lw	a1,4(s1)
 858:	8562                	mv	a0,s8
 85a:	00000097          	auipc	ra,0x0
 85e:	dfc080e7          	jalr	-516(ra) # 656 <printf>
        ulthread_context_switch(&temp->context, &t->context);
 862:	01848593          	addi	a1,s1,24
 866:	018b0513          	addi	a0,s6,24
 86a:	00000097          	auipc	ra,0x0
 86e:	46a080e7          	jalr	1130(ra) # cd4 <ulthread_context_switch>
        threadAvailable = true;
 872:	874a                	mv	a4,s2
 874:	a811                	j	888 <roundRobin+0x7e>
      {
        t->state = RUNNABLE;
 876:	0124a023          	sw	s2,0(s1)
    for (t = ulthreads; t < &ulthreads[MAXULTHREADS]; t++)
 87a:	08848493          	addi	s1,s1,136
 87e:	01348963          	beq	s1,s3,890 <roundRobin+0x86>
      if (t->state == RUNNABLE && t != scheduler_thread)
 882:	409c                	lw	a5,0(s1)
 884:	fd2781e3          	beq	a5,s2,846 <roundRobin+0x3c>
      if (t->state == YIELD)
 888:	409c                	lw	a5,0(s1)
 88a:	ff4798e3          	bne	a5,s4,87a <roundRobin+0x70>
 88e:	b7e5                	j	876 <roundRobin+0x6c>
      }
    }
    if (!threadAvailable)
 890:	cb01                	beqz	a4,8a0 <roundRobin+0x96>
    bool threadAvailable = false;
 892:	4701                	li	a4,0
    for (t = ulthreads; t < &ulthreads[MAXULTHREADS]; t++)
 894:	00000497          	auipc	s1,0x0
 898:	79c48493          	addi	s1,s1,1948 # 1030 <ulthreads>
      if (t->state == RUNNABLE && t != scheduler_thread)
 89c:	4905                	li	s2,1
 89e:	b7d5                	j	882 <roundRobin+0x78>
    {
      break;
    }
  }
}
 8a0:	60a6                	ld	ra,72(sp)
 8a2:	6406                	ld	s0,64(sp)
 8a4:	74e2                	ld	s1,56(sp)
 8a6:	7942                	ld	s2,48(sp)
 8a8:	79a2                	ld	s3,40(sp)
 8aa:	7a02                	ld	s4,32(sp)
 8ac:	6ae2                	ld	s5,24(sp)
 8ae:	6b42                	ld	s6,16(sp)
 8b0:	6ba2                	ld	s7,8(sp)
 8b2:	6c02                	ld	s8,0(sp)
 8b4:	6161                	addi	sp,sp,80
 8b6:	8082                	ret

00000000000008b8 <firstComeFirstServe>:

void firstComeFirstServe(void)
{
 8b8:	715d                	addi	sp,sp,-80
 8ba:	e486                	sd	ra,72(sp)
 8bc:	e0a2                	sd	s0,64(sp)
 8be:	fc26                	sd	s1,56(sp)
 8c0:	f84a                	sd	s2,48(sp)
 8c2:	f44e                	sd	s3,40(sp)
 8c4:	f052                	sd	s4,32(sp)
 8c6:	ec56                	sd	s5,24(sp)
 8c8:	e85a                	sd	s6,16(sp)
 8ca:	e45e                	sd	s7,8(sp)
 8cc:	e062                	sd	s8,0(sp)
 8ce:	0880                	addi	s0,sp,80
    uint64 oldest = __INT64_MAX__;
    int threadIndex = -1;
    int alternativeIndex = -1;
    for (t = ulthreads+1; t < &ulthreads[MAXULTHREADS]; t++)
    {
      if (t->state == RUNNABLE && t != scheduler_thread && t->lastTime < oldest)
 8d0:	00000b97          	auipc	s7,0x0
 8d4:	740b8b93          	addi	s7,s7,1856 # 1010 <scheduler_thread>
    int alternativeIndex = -1;
 8d8:	5afd                	li	s5,-1
    uint64 oldest = __INT64_MAX__;
 8da:	001adb13          	srli	s6,s5,0x1
      if (t->state == RUNNABLE && t != scheduler_thread && t->lastTime < oldest)
 8de:	4485                	li	s1,1
        oldest = t->lastTime;
        threadIndex = t->tid;
        threadAvailable = true;
      }

      if (t->state == YIELD){
 8e0:	4989                	li	s3,2
    for (t = ulthreads+1; t < &ulthreads[MAXULTHREADS]; t++)
 8e2:	00004917          	auipc	s2,0x4
 8e6:	c6e90913          	addi	s2,s2,-914 # 4550 <ulthreads+0x3520>
        break;
      }
      
    }
    label : 
      struct ulthread *temp = current_thread;
 8ea:	00000a17          	auipc	s4,0x0
 8ee:	72ea0a13          	addi	s4,s4,1838 # 1018 <current_thread>
 8f2:	a88d                	j	964 <firstComeFirstServe+0xac>
      if (t->state == RUNNABLE && t != scheduler_thread && t->lastTime < oldest)
 8f4:	00f58963          	beq	a1,a5,906 <firstComeFirstServe+0x4e>
 8f8:	6b98                	ld	a4,16(a5)
 8fa:	00c77663          	bgeu	a4,a2,906 <firstComeFirstServe+0x4e>
        threadIndex = t->tid;
 8fe:	0047a803          	lw	a6,4(a5)
        oldest = t->lastTime;
 902:	863a                	mv	a2,a4
        threadAvailable = true;
 904:	8526                	mv	a0,s1
    for (t = ulthreads+1; t < &ulthreads[MAXULTHREADS]; t++)
 906:	08878793          	addi	a5,a5,136
 90a:	01278a63          	beq	a5,s2,91e <firstComeFirstServe+0x66>
      if (t->state == RUNNABLE && t != scheduler_thread && t->lastTime < oldest)
 90e:	4398                	lw	a4,0(a5)
 910:	fe9702e3          	beq	a4,s1,8f4 <firstComeFirstServe+0x3c>
      if (t->state == YIELD){
 914:	ff3719e3          	bne	a4,s3,906 <firstComeFirstServe+0x4e>
        t->state = RUNNABLE;
 918:	c384                	sw	s1,0(a5)
        alternativeIndex = t->tid;
 91a:	43d4                	lw	a3,4(a5)
 91c:	b7ed                	j	906 <firstComeFirstServe+0x4e>
    if (!threadAvailable)
 91e:	ed31                	bnez	a0,97a <firstComeFirstServe+0xc2>
      if(alternativeIndex > 0){
 920:	04d05f63          	blez	a3,97e <firstComeFirstServe+0xc6>
      struct ulthread *temp = current_thread;
 924:	000a3c03          	ld	s8,0(s4)
      current_thread = &ulthreads[threadIndex];
 928:	00469793          	slli	a5,a3,0x4
 92c:	00d78733          	add	a4,a5,a3
 930:	070e                	slli	a4,a4,0x3
 932:	00000617          	auipc	a2,0x0
 936:	6fe60613          	addi	a2,a2,1790 # 1030 <ulthreads>
 93a:	9732                	add	a4,a4,a2
 93c:	00ea3023          	sd	a4,0(s4)
      printf("[*] ultschedule (next tid: %d), time = %d\n", get_current_tid());
 940:	434c                	lw	a1,4(a4)
 942:	00000517          	auipc	a0,0x0
 946:	4d650513          	addi	a0,a0,1238 # e18 <digits+0x38>
 94a:	00000097          	auipc	ra,0x0
 94e:	d0c080e7          	jalr	-756(ra) # 656 <printf>
      ulthread_context_switch(&temp->context, &current_thread->context);
 952:	000a3583          	ld	a1,0(s4)
 956:	05e1                	addi	a1,a1,24
 958:	018c0513          	addi	a0,s8,24
 95c:	00000097          	auipc	ra,0x0
 960:	378080e7          	jalr	888(ra) # cd4 <ulthread_context_switch>
      if (t->state == RUNNABLE && t != scheduler_thread && t->lastTime < oldest)
 964:	000bb583          	ld	a1,0(s7)
    int alternativeIndex = -1;
 968:	86d6                	mv	a3,s5
    int threadIndex = -1;
 96a:	8856                	mv	a6,s5
    uint64 oldest = __INT64_MAX__;
 96c:	865a                	mv	a2,s6
    bool threadAvailable = false;
 96e:	4501                	li	a0,0
    for (t = ulthreads+1; t < &ulthreads[MAXULTHREADS]; t++)
 970:	00000797          	auipc	a5,0x0
 974:	74878793          	addi	a5,a5,1864 # 10b8 <ulthreads+0x88>
 978:	bf59                	j	90e <firstComeFirstServe+0x56>
    label : 
 97a:	86c2                	mv	a3,a6
 97c:	b765                	j	924 <firstComeFirstServe+0x6c>
  }
}
 97e:	60a6                	ld	ra,72(sp)
 980:	6406                	ld	s0,64(sp)
 982:	74e2                	ld	s1,56(sp)
 984:	7942                	ld	s2,48(sp)
 986:	79a2                	ld	s3,40(sp)
 988:	7a02                	ld	s4,32(sp)
 98a:	6ae2                	ld	s5,24(sp)
 98c:	6b42                	ld	s6,16(sp)
 98e:	6ba2                	ld	s7,8(sp)
 990:	6c02                	ld	s8,0(sp)
 992:	6161                	addi	sp,sp,80
 994:	8082                	ret

0000000000000996 <priorityScheduling>:


void priorityScheduling(void)
{
 996:	715d                	addi	sp,sp,-80
 998:	e486                	sd	ra,72(sp)
 99a:	e0a2                	sd	s0,64(sp)
 99c:	fc26                	sd	s1,56(sp)
 99e:	f84a                	sd	s2,48(sp)
 9a0:	f44e                	sd	s3,40(sp)
 9a2:	f052                	sd	s4,32(sp)
 9a4:	ec56                	sd	s5,24(sp)
 9a6:	e85a                	sd	s6,16(sp)
 9a8:	e45e                	sd	s7,8(sp)
 9aa:	0880                	addi	s0,sp,80
    int maxPriority = -1;
    int threadIndex = -1;
    int alternativeIndex = -1;
    for (t = ulthreads+1; t < &ulthreads[MAXULTHREADS]; t++)
    {
      if (t->state == RUNNABLE && t != scheduler_thread && t->priority > maxPriority)
 9ac:	00000b17          	auipc	s6,0x0
 9b0:	664b0b13          	addi	s6,s6,1636 # 1010 <scheduler_thread>
    int alternativeIndex = -1;
 9b4:	5a7d                	li	s4,-1
      if (t->state == RUNNABLE && t != scheduler_thread && t->priority > maxPriority)
 9b6:	4485                	li	s1,1
        // flag = true;

        // break; // switch to highest-priority thread and exit loop
      }

      if (t->state == YIELD){
 9b8:	4989                	li	s3,2
    for (t = ulthreads+1; t < &ulthreads[MAXULTHREADS]; t++)
 9ba:	00004917          	auipc	s2,0x4
 9be:	b9690913          	addi	s2,s2,-1130 # 4550 <ulthreads+0x3520>
        break;
      }
      
    }
    label : 
      struct ulthread *temp = current_thread;
 9c2:	00000a97          	auipc	s5,0x0
 9c6:	656a8a93          	addi	s5,s5,1622 # 1018 <current_thread>
 9ca:	a88d                	j	a3c <priorityScheduling+0xa6>
      if (t->state == RUNNABLE && t != scheduler_thread && t->priority > maxPriority)
 9cc:	00f58963          	beq	a1,a5,9de <priorityScheduling+0x48>
 9d0:	47d8                	lw	a4,12(a5)
 9d2:	00e65663          	bge	a2,a4,9de <priorityScheduling+0x48>
        threadIndex = t->tid;
 9d6:	0047a803          	lw	a6,4(a5)
        maxPriority = t->priority;
 9da:	863a                	mv	a2,a4
        threadAvailable = true;
 9dc:	8526                	mv	a0,s1
    for (t = ulthreads+1; t < &ulthreads[MAXULTHREADS]; t++)
 9de:	08878793          	addi	a5,a5,136
 9e2:	01278a63          	beq	a5,s2,9f6 <priorityScheduling+0x60>
      if (t->state == RUNNABLE && t != scheduler_thread && t->priority > maxPriority)
 9e6:	4398                	lw	a4,0(a5)
 9e8:	fe9702e3          	beq	a4,s1,9cc <priorityScheduling+0x36>
      if (t->state == YIELD){
 9ec:	ff3719e3          	bne	a4,s3,9de <priorityScheduling+0x48>
        t->state = RUNNABLE;
 9f0:	c384                	sw	s1,0(a5)
        alternativeIndex = t->tid;
 9f2:	43d4                	lw	a3,4(a5)
 9f4:	b7ed                	j	9de <priorityScheduling+0x48>
    if (!threadAvailable)
 9f6:	ed31                	bnez	a0,a52 <priorityScheduling+0xbc>
      if(alternativeIndex > 0){
 9f8:	04d05f63          	blez	a3,a56 <priorityScheduling+0xc0>
      struct ulthread *temp = current_thread;
 9fc:	000abb83          	ld	s7,0(s5)
      current_thread = &ulthreads[threadIndex];
 a00:	00469793          	slli	a5,a3,0x4
 a04:	00d78733          	add	a4,a5,a3
 a08:	070e                	slli	a4,a4,0x3
 a0a:	00000617          	auipc	a2,0x0
 a0e:	62660613          	addi	a2,a2,1574 # 1030 <ulthreads>
 a12:	9732                	add	a4,a4,a2
 a14:	00eab023          	sd	a4,0(s5)
      printf("[*] ultschedule (next tid: %d)\n", get_current_tid());
 a18:	434c                	lw	a1,4(a4)
 a1a:	00000517          	auipc	a0,0x0
 a1e:	3de50513          	addi	a0,a0,990 # df8 <digits+0x18>
 a22:	00000097          	auipc	ra,0x0
 a26:	c34080e7          	jalr	-972(ra) # 656 <printf>
      ulthread_context_switch(&temp->context, &current_thread->context);
 a2a:	000ab583          	ld	a1,0(s5)
 a2e:	05e1                	addi	a1,a1,24
 a30:	018b8513          	addi	a0,s7,24
 a34:	00000097          	auipc	ra,0x0
 a38:	2a0080e7          	jalr	672(ra) # cd4 <ulthread_context_switch>
      if (t->state == RUNNABLE && t != scheduler_thread && t->priority > maxPriority)
 a3c:	000b3583          	ld	a1,0(s6)
    int alternativeIndex = -1;
 a40:	86d2                	mv	a3,s4
    int threadIndex = -1;
 a42:	8852                	mv	a6,s4
    int maxPriority = -1;
 a44:	8652                	mv	a2,s4
    bool threadAvailable = false;
 a46:	4501                	li	a0,0
    for (t = ulthreads+1; t < &ulthreads[MAXULTHREADS]; t++)
 a48:	00000797          	auipc	a5,0x0
 a4c:	67078793          	addi	a5,a5,1648 # 10b8 <ulthreads+0x88>
 a50:	bf59                	j	9e6 <priorityScheduling+0x50>
    label : 
 a52:	86c2                	mv	a3,a6
 a54:	b765                	j	9fc <priorityScheduling+0x66>
  }
}
 a56:	60a6                	ld	ra,72(sp)
 a58:	6406                	ld	s0,64(sp)
 a5a:	74e2                	ld	s1,56(sp)
 a5c:	7942                	ld	s2,48(sp)
 a5e:	79a2                	ld	s3,40(sp)
 a60:	7a02                	ld	s4,32(sp)
 a62:	6ae2                	ld	s5,24(sp)
 a64:	6b42                	ld	s6,16(sp)
 a66:	6ba2                	ld	s7,8(sp)
 a68:	6161                	addi	sp,sp,80
 a6a:	8082                	ret

0000000000000a6c <ulthread_init>:

/* Thread initialization */
void ulthread_init(int schedalgo)
{
 a6c:	1141                	addi	sp,sp,-16
 a6e:	e422                	sd	s0,8(sp)
 a70:	0800                	addi	s0,sp,16
  struct ulthread *t;
  int i;
  for (i = 0, t = ulthreads; t < &ulthreads[MAXULTHREADS]; t++, i++)
 a72:	4701                	li	a4,0
 a74:	00000797          	auipc	a5,0x0
 a78:	5bc78793          	addi	a5,a5,1468 # 1030 <ulthreads>
 a7c:	00004697          	auipc	a3,0x4
 a80:	ad468693          	addi	a3,a3,-1324 # 4550 <ulthreads+0x3520>
  {
    t->state = FREE;
 a84:	0007a023          	sw	zero,0(a5)
    t->tid = i;
 a88:	c3d8                	sw	a4,4(a5)
  for (i = 0, t = ulthreads; t < &ulthreads[MAXULTHREADS]; t++, i++)
 a8a:	08878793          	addi	a5,a5,136
 a8e:	2705                	addiw	a4,a4,1
 a90:	fed79ae3          	bne	a5,a3,a84 <ulthread_init+0x18>
  }
  current_thread = &ulthreads[0];
 a94:	00000797          	auipc	a5,0x0
 a98:	59c78793          	addi	a5,a5,1436 # 1030 <ulthreads>
 a9c:	00000717          	auipc	a4,0x0
 aa0:	56f73e23          	sd	a5,1404(a4) # 1018 <current_thread>
  scheduler_thread = &ulthreads[0];
 aa4:	00000717          	auipc	a4,0x0
 aa8:	56f73623          	sd	a5,1388(a4) # 1010 <scheduler_thread>
  scheduler_thread->state = RUNNABLE;
 aac:	4705                	li	a4,1
 aae:	c398                	sw	a4,0(a5)
  t->state = FREE;
 ab0:	00004797          	auipc	a5,0x4
 ab4:	aa07a023          	sw	zero,-1376(a5) # 4550 <ulthreads+0x3520>
  algorithm = schedalgo;
 ab8:	00000797          	auipc	a5,0x0
 abc:	54a7a823          	sw	a0,1360(a5) # 1008 <algorithm>
}
 ac0:	6422                	ld	s0,8(sp)
 ac2:	0141                	addi	sp,sp,16
 ac4:	8082                	ret

0000000000000ac6 <ulthread_create>:

/* Thread creation */
bool ulthread_create(uint64 start, uint64 stack, uint64 args[], int priority)
{
 ac6:	7179                	addi	sp,sp,-48
 ac8:	f406                	sd	ra,40(sp)
 aca:	f022                	sd	s0,32(sp)
 acc:	ec26                	sd	s1,24(sp)
 ace:	e84a                	sd	s2,16(sp)
 ad0:	e44e                	sd	s3,8(sp)
 ad2:	e052                	sd	s4,0(sp)
 ad4:	1800                	addi	s0,sp,48
 ad6:	89aa                	mv	s3,a0
 ad8:	8a2e                	mv	s4,a1
 ada:	8932                	mv	s2,a2
  /* Please add thread-id instead of '0' here. */
  struct ulthread *t;
  bool flag = false;
  for (t = ulthreads; t < &ulthreads[MAXULTHREADS]; t++)
 adc:	00000497          	auipc	s1,0x0
 ae0:	55448493          	addi	s1,s1,1364 # 1030 <ulthreads>
 ae4:	00004717          	auipc	a4,0x4
 ae8:	a6c70713          	addi	a4,a4,-1428 # 4550 <ulthreads+0x3520>
  {
    if (t->state == FREE)
 aec:	409c                	lw	a5,0(s1)
 aee:	cf89                	beqz	a5,b08 <ulthread_create+0x42>
  for (t = ulthreads; t < &ulthreads[MAXULTHREADS]; t++)
 af0:	08848493          	addi	s1,s1,136
 af4:	fee49ce3          	bne	s1,a4,aec <ulthread_create+0x26>
      break;
    }
  }
  if (!flag)
  {
    return false;
 af8:	4501                	li	a0,0
 afa:	a871                	j	b96 <ulthread_create+0xd0>
  t->sp = (int)(stack + USTACKSIZE); // set sp to the top of the stack
  t->state = RUNNABLE;
  t->priority = priority;

  if(algorithm==FCFS){
    t->lastTime = ctime();
 afc:	00000097          	auipc	ra,0x0
 b00:	88a080e7          	jalr	-1910(ra) # 386 <ctime>
 b04:	e888                	sd	a0,16(s1)
 b06:	a839                	j	b24 <ulthread_create+0x5e>
  t->sp = (int)(stack + USTACKSIZE); // set sp to the top of the stack
 b08:	6785                	lui	a5,0x1
 b0a:	014787bb          	addw	a5,a5,s4
 b0e:	c49c                	sw	a5,8(s1)
  t->state = RUNNABLE;
 b10:	4785                	li	a5,1
 b12:	c09c                	sw	a5,0(s1)
  t->priority = priority;
 b14:	c4d4                	sw	a3,12(s1)
  if(algorithm==FCFS){
 b16:	00000717          	auipc	a4,0x0
 b1a:	4f272703          	lw	a4,1266(a4) # 1008 <algorithm>
 b1e:	4789                	li	a5,2
 b20:	fcf70ee3          	beq	a4,a5,afc <ulthread_create+0x36>
  }

  for (int argc = 0; argc < 6; argc++)
 b24:	874a                	mv	a4,s2
 b26:	03090693          	addi	a3,s2,48
  {
    t->sp -= 16;
 b2a:	449c                	lw	a5,8(s1)
 b2c:	37c1                	addiw	a5,a5,-16 # ff0 <digits+0x210>
 b2e:	0007881b          	sext.w	a6,a5
 b32:	c49c                	sw	a5,8(s1)
    *(uint64 *)(t->sp) = (uint64)args[argc];
 b34:	631c                	ld	a5,0(a4)
 b36:	00f83023          	sd	a5,0(a6)
  for (int argc = 0; argc < 6; argc++)
 b3a:	0721                	addi	a4,a4,8
 b3c:	fed717e3          	bne	a4,a3,b2a <ulthread_create+0x64>
  }

  memset(&t->context, 0, sizeof(t->context));
 b40:	07000613          	li	a2,112
 b44:	4581                	li	a1,0
 b46:	01848513          	addi	a0,s1,24
 b4a:	fffff097          	auipc	ra,0xfffff
 b4e:	5a2080e7          	jalr	1442(ra) # ec <memset>
  t->context.ra = start;
 b52:	0134bc23          	sd	s3,24(s1)
  t->context.sp = t->sp;
 b56:	449c                	lw	a5,8(s1)
 b58:	f09c                	sd	a5,32(s1)
  t->context.s0 = args[0];
 b5a:	00093783          	ld	a5,0(s2)
 b5e:	f49c                	sd	a5,40(s1)
  t->context.s1 = args[1];
 b60:	00893783          	ld	a5,8(s2)
 b64:	f89c                	sd	a5,48(s1)
  t->context.s2 = args[2];
 b66:	01093783          	ld	a5,16(s2)
 b6a:	fc9c                	sd	a5,56(s1)
  t->context.s3 = args[3];
 b6c:	01893783          	ld	a5,24(s2)
 b70:	e0bc                	sd	a5,64(s1)
  t->context.s4 = args[4];
 b72:	02093783          	ld	a5,32(s2)
 b76:	e4bc                	sd	a5,72(s1)
  t->context.s5 = args[5];
 b78:	02893783          	ld	a5,40(s2)
 b7c:	e8bc                	sd	a5,80(s1)

  printf("[*] ultcreate(tid: %d, ra: %p, sp: %p)\n", t->tid, start, stack);
 b7e:	86d2                	mv	a3,s4
 b80:	864e                	mv	a2,s3
 b82:	40cc                	lw	a1,4(s1)
 b84:	00000517          	auipc	a0,0x0
 b88:	2c450513          	addi	a0,a0,708 # e48 <digits+0x68>
 b8c:	00000097          	auipc	ra,0x0
 b90:	aca080e7          	jalr	-1334(ra) # 656 <printf>
  return true;
 b94:	4505                	li	a0,1
}
 b96:	70a2                	ld	ra,40(sp)
 b98:	7402                	ld	s0,32(sp)
 b9a:	64e2                	ld	s1,24(sp)
 b9c:	6942                	ld	s2,16(sp)
 b9e:	69a2                	ld	s3,8(sp)
 ba0:	6a02                	ld	s4,0(sp)
 ba2:	6145                	addi	sp,sp,48
 ba4:	8082                	ret

0000000000000ba6 <ulthread_schedule>:

/* Thread scheduler */
void ulthread_schedule(void)
{
 ba6:	1141                	addi	sp,sp,-16
 ba8:	e406                	sd	ra,8(sp)
 baa:	e022                	sd	s0,0(sp)
 bac:	0800                	addi	s0,sp,16
  switch (algorithm)
 bae:	00000797          	auipc	a5,0x0
 bb2:	45a7a783          	lw	a5,1114(a5) # 1008 <algorithm>
 bb6:	4705                	li	a4,1
 bb8:	02e78463          	beq	a5,a4,be0 <ulthread_schedule+0x3a>
 bbc:	4709                	li	a4,2
 bbe:	00e78c63          	beq	a5,a4,bd6 <ulthread_schedule+0x30>
 bc2:	c789                	beqz	a5,bcc <ulthread_schedule+0x26>

  // Push argument strings, prepare rest of stack in ustack.

  // Switch between thread contexts
  // ulthread_context_switch(NULL, NULL);
}
 bc4:	60a2                	ld	ra,8(sp)
 bc6:	6402                	ld	s0,0(sp)
 bc8:	0141                	addi	sp,sp,16
 bca:	8082                	ret
    roundRobin();
 bcc:	00000097          	auipc	ra,0x0
 bd0:	c3e080e7          	jalr	-962(ra) # 80a <roundRobin>
    break;
 bd4:	bfc5                	j	bc4 <ulthread_schedule+0x1e>
    firstComeFirstServe();
 bd6:	00000097          	auipc	ra,0x0
 bda:	ce2080e7          	jalr	-798(ra) # 8b8 <firstComeFirstServe>
    break;
 bde:	b7dd                	j	bc4 <ulthread_schedule+0x1e>
    priorityScheduling();
 be0:	00000097          	auipc	ra,0x0
 be4:	db6080e7          	jalr	-586(ra) # 996 <priorityScheduling>
}
 be8:	bff1                	j	bc4 <ulthread_schedule+0x1e>

0000000000000bea <ulthread_yield>:

/* Yield CPU time to some other thread. */
void ulthread_yield(void)
{
 bea:	1101                	addi	sp,sp,-32
 bec:	ec06                	sd	ra,24(sp)
 bee:	e822                	sd	s0,16(sp)
 bf0:	e426                	sd	s1,8(sp)
 bf2:	e04a                	sd	s2,0(sp)
 bf4:	1000                	addi	s0,sp,32
  current_thread->state = YIELD;
 bf6:	00000797          	auipc	a5,0x0
 bfa:	42278793          	addi	a5,a5,1058 # 1018 <current_thread>
 bfe:	6398                	ld	a4,0(a5)
 c00:	4909                	li	s2,2
 c02:	01272023          	sw	s2,0(a4)
  struct ulthread *temp = current_thread;
 c06:	6384                	ld	s1,0(a5)
  printf("[*] ultyield(tid: %d)\n", current_thread->tid);
 c08:	40cc                	lw	a1,4(s1)
 c0a:	00000517          	auipc	a0,0x0
 c0e:	26650513          	addi	a0,a0,614 # e70 <digits+0x90>
 c12:	00000097          	auipc	ra,0x0
 c16:	a44080e7          	jalr	-1468(ra) # 656 <printf>
  if(algorithm==FCFS){
 c1a:	00000797          	auipc	a5,0x0
 c1e:	3ee7a783          	lw	a5,1006(a5) # 1008 <algorithm>
 c22:	03278763          	beq	a5,s2,c50 <ulthread_yield+0x66>
    current_thread->lastTime = ctime();
  }
  current_thread = scheduler_thread;
 c26:	00000597          	auipc	a1,0x0
 c2a:	3ea5b583          	ld	a1,1002(a1) # 1010 <scheduler_thread>
 c2e:	00000797          	auipc	a5,0x0
 c32:	3eb7b523          	sd	a1,1002(a5) # 1018 <current_thread>
  
  ulthread_context_switch(&temp->context, &scheduler_thread->context);
 c36:	05e1                	addi	a1,a1,24
 c38:	01848513          	addi	a0,s1,24
 c3c:	00000097          	auipc	ra,0x0
 c40:	098080e7          	jalr	152(ra) # cd4 <ulthread_context_switch>
  // ulthread_schedule();
}
 c44:	60e2                	ld	ra,24(sp)
 c46:	6442                	ld	s0,16(sp)
 c48:	64a2                	ld	s1,8(sp)
 c4a:	6902                	ld	s2,0(sp)
 c4c:	6105                	addi	sp,sp,32
 c4e:	8082                	ret
    current_thread->lastTime = ctime();
 c50:	fffff097          	auipc	ra,0xfffff
 c54:	736080e7          	jalr	1846(ra) # 386 <ctime>
 c58:	00000797          	auipc	a5,0x0
 c5c:	3c07b783          	ld	a5,960(a5) # 1018 <current_thread>
 c60:	eb88                	sd	a0,16(a5)
 c62:	b7d1                	j	c26 <ulthread_yield+0x3c>

0000000000000c64 <ulthread_destroy>:

/* Destroy thread */
void ulthread_destroy(void)
{
 c64:	1101                	addi	sp,sp,-32
 c66:	ec06                	sd	ra,24(sp)
 c68:	e822                	sd	s0,16(sp)
 c6a:	e426                	sd	s1,8(sp)
 c6c:	e04a                	sd	s2,0(sp)
 c6e:	1000                	addi	s0,sp,32
  memset(&current_thread->context, 0, sizeof(current_thread->context));
 c70:	00000497          	auipc	s1,0x0
 c74:	3a848493          	addi	s1,s1,936 # 1018 <current_thread>
 c78:	6088                	ld	a0,0(s1)
 c7a:	07000613          	li	a2,112
 c7e:	4581                	li	a1,0
 c80:	0561                	addi	a0,a0,24
 c82:	fffff097          	auipc	ra,0xfffff
 c86:	46a080e7          	jalr	1130(ra) # ec <memset>
  current_thread->sp = 0;
 c8a:	609c                	ld	a5,0(s1)
 c8c:	0007a423          	sw	zero,8(a5)
  current_thread->priority = -1;
 c90:	577d                	li	a4,-1
 c92:	c7d8                	sw	a4,12(a5)
  current_thread->state = FREE;
 c94:	0007a023          	sw	zero,0(a5)

  struct ulthread *temp = current_thread;
 c98:	0004b903          	ld	s2,0(s1)

  printf("[*] ultdestroy(tid: %d)\n", get_current_tid());
 c9c:	00492583          	lw	a1,4(s2)
 ca0:	00000517          	auipc	a0,0x0
 ca4:	1e850513          	addi	a0,a0,488 # e88 <digits+0xa8>
 ca8:	00000097          	auipc	ra,0x0
 cac:	9ae080e7          	jalr	-1618(ra) # 656 <printf>
  current_thread = scheduler_thread;
 cb0:	00000597          	auipc	a1,0x0
 cb4:	3605b583          	ld	a1,864(a1) # 1010 <scheduler_thread>
 cb8:	e08c                	sd	a1,0(s1)
  ulthread_context_switch(&temp->context, &scheduler_thread->context);
 cba:	05e1                	addi	a1,a1,24
 cbc:	01890513          	addi	a0,s2,24
 cc0:	00000097          	auipc	ra,0x0
 cc4:	014080e7          	jalr	20(ra) # cd4 <ulthread_context_switch>
}
 cc8:	60e2                	ld	ra,24(sp)
 cca:	6442                	ld	s0,16(sp)
 ccc:	64a2                	ld	s1,8(sp)
 cce:	6902                	ld	s2,0(sp)
 cd0:	6105                	addi	sp,sp,32
 cd2:	8082                	ret

0000000000000cd4 <ulthread_context_switch>:
 cd4:	00153023          	sd	ra,0(a0)
 cd8:	00253423          	sd	sp,8(a0)
 cdc:	e900                	sd	s0,16(a0)
 cde:	ed04                	sd	s1,24(a0)
 ce0:	03253023          	sd	s2,32(a0)
 ce4:	03353423          	sd	s3,40(a0)
 ce8:	03453823          	sd	s4,48(a0)
 cec:	03553c23          	sd	s5,56(a0)
 cf0:	05653023          	sd	s6,64(a0)
 cf4:	05753423          	sd	s7,72(a0)
 cf8:	05853823          	sd	s8,80(a0)
 cfc:	05953c23          	sd	s9,88(a0)
 d00:	07a53023          	sd	s10,96(a0)
 d04:	07b53423          	sd	s11,104(a0)
 d08:	0005b083          	ld	ra,0(a1)
 d0c:	0085b103          	ld	sp,8(a1)
 d10:	6980                	ld	s0,16(a1)
 d12:	6d84                	ld	s1,24(a1)
 d14:	0205b903          	ld	s2,32(a1)
 d18:	0285b983          	ld	s3,40(a1)
 d1c:	0305ba03          	ld	s4,48(a1)
 d20:	0385ba83          	ld	s5,56(a1)
 d24:	0405bb03          	ld	s6,64(a1)
 d28:	0485bb83          	ld	s7,72(a1)
 d2c:	0505bc03          	ld	s8,80(a1)
 d30:	0585bc83          	ld	s9,88(a1)
 d34:	0605bd03          	ld	s10,96(a1)
 d38:	0685bd83          	ld	s11,104(a1)
 d3c:	6546                	ld	a0,80(sp)
 d3e:	6586                	ld	a1,64(sp)
 d40:	7642                	ld	a2,48(sp)
 d42:	7682                	ld	a3,32(sp)
 d44:	6742                	ld	a4,16(sp)
 d46:	6782                	ld	a5,0(sp)
 d48:	8082                	ret
