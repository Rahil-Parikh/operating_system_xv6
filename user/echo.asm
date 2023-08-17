
user/_echo:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "kernel/stat.h"
#include "user/user.h"

int
main(int argc, char *argv[])
{
   0:	7139                	addi	sp,sp,-64
   2:	fc06                	sd	ra,56(sp)
   4:	f822                	sd	s0,48(sp)
   6:	f426                	sd	s1,40(sp)
   8:	f04a                	sd	s2,32(sp)
   a:	ec4e                	sd	s3,24(sp)
   c:	e852                	sd	s4,16(sp)
   e:	e456                	sd	s5,8(sp)
  10:	0080                	addi	s0,sp,64
  int i;

  for(i = 1; i < argc; i++){
  12:	4785                	li	a5,1
  14:	06a7d863          	bge	a5,a0,84 <main+0x84>
  18:	00858493          	addi	s1,a1,8
  1c:	3579                	addiw	a0,a0,-2
  1e:	02051793          	slli	a5,a0,0x20
  22:	01d7d513          	srli	a0,a5,0x1d
  26:	00a48a33          	add	s4,s1,a0
  2a:	05c1                	addi	a1,a1,16
  2c:	00a589b3          	add	s3,a1,a0
    write(1, argv[i], strlen(argv[i]));
    if(i + 1 < argc){
      write(1, " ", 1);
  30:	00001a97          	auipc	s5,0x1
  34:	d50a8a93          	addi	s5,s5,-688 # d80 <ulthread_context_switch+0x7e>
  38:	a819                	j	4e <main+0x4e>
  3a:	4605                	li	a2,1
  3c:	85d6                	mv	a1,s5
  3e:	4505                	li	a0,1
  40:	00000097          	auipc	ra,0x0
  44:	2f4080e7          	jalr	756(ra) # 334 <write>
  for(i = 1; i < argc; i++){
  48:	04a1                	addi	s1,s1,8
  4a:	03348d63          	beq	s1,s3,84 <main+0x84>
    write(1, argv[i], strlen(argv[i]));
  4e:	0004b903          	ld	s2,0(s1)
  52:	854a                	mv	a0,s2
  54:	00000097          	auipc	ra,0x0
  58:	09c080e7          	jalr	156(ra) # f0 <strlen>
  5c:	0005061b          	sext.w	a2,a0
  60:	85ca                	mv	a1,s2
  62:	4505                	li	a0,1
  64:	00000097          	auipc	ra,0x0
  68:	2d0080e7          	jalr	720(ra) # 334 <write>
    if(i + 1 < argc){
  6c:	fd4497e3          	bne	s1,s4,3a <main+0x3a>
    } else {
      write(1, "\n", 1);
  70:	4605                	li	a2,1
  72:	00001597          	auipc	a1,0x1
  76:	d1658593          	addi	a1,a1,-746 # d88 <ulthread_context_switch+0x86>
  7a:	4505                	li	a0,1
  7c:	00000097          	auipc	ra,0x0
  80:	2b8080e7          	jalr	696(ra) # 334 <write>
    }
  }
  exit(0);
  84:	4501                	li	a0,0
  86:	00000097          	auipc	ra,0x0
  8a:	28e080e7          	jalr	654(ra) # 314 <exit>

000000000000008e <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
  8e:	1141                	addi	sp,sp,-16
  90:	e406                	sd	ra,8(sp)
  92:	e022                	sd	s0,0(sp)
  94:	0800                	addi	s0,sp,16
  extern int main();
  main();
  96:	00000097          	auipc	ra,0x0
  9a:	f6a080e7          	jalr	-150(ra) # 0 <main>
  exit(0);
  9e:	4501                	li	a0,0
  a0:	00000097          	auipc	ra,0x0
  a4:	274080e7          	jalr	628(ra) # 314 <exit>

00000000000000a8 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
  a8:	1141                	addi	sp,sp,-16
  aa:	e422                	sd	s0,8(sp)
  ac:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  ae:	87aa                	mv	a5,a0
  b0:	0585                	addi	a1,a1,1
  b2:	0785                	addi	a5,a5,1
  b4:	fff5c703          	lbu	a4,-1(a1)
  b8:	fee78fa3          	sb	a4,-1(a5)
  bc:	fb75                	bnez	a4,b0 <strcpy+0x8>
    ;
  return os;
}
  be:	6422                	ld	s0,8(sp)
  c0:	0141                	addi	sp,sp,16
  c2:	8082                	ret

00000000000000c4 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  c4:	1141                	addi	sp,sp,-16
  c6:	e422                	sd	s0,8(sp)
  c8:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
  ca:	00054783          	lbu	a5,0(a0)
  ce:	cb91                	beqz	a5,e2 <strcmp+0x1e>
  d0:	0005c703          	lbu	a4,0(a1)
  d4:	00f71763          	bne	a4,a5,e2 <strcmp+0x1e>
    p++, q++;
  d8:	0505                	addi	a0,a0,1
  da:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
  dc:	00054783          	lbu	a5,0(a0)
  e0:	fbe5                	bnez	a5,d0 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
  e2:	0005c503          	lbu	a0,0(a1)
}
  e6:	40a7853b          	subw	a0,a5,a0
  ea:	6422                	ld	s0,8(sp)
  ec:	0141                	addi	sp,sp,16
  ee:	8082                	ret

00000000000000f0 <strlen>:

uint
strlen(const char *s)
{
  f0:	1141                	addi	sp,sp,-16
  f2:	e422                	sd	s0,8(sp)
  f4:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
  f6:	00054783          	lbu	a5,0(a0)
  fa:	cf91                	beqz	a5,116 <strlen+0x26>
  fc:	0505                	addi	a0,a0,1
  fe:	87aa                	mv	a5,a0
 100:	86be                	mv	a3,a5
 102:	0785                	addi	a5,a5,1
 104:	fff7c703          	lbu	a4,-1(a5)
 108:	ff65                	bnez	a4,100 <strlen+0x10>
 10a:	40a6853b          	subw	a0,a3,a0
 10e:	2505                	addiw	a0,a0,1
    ;
  return n;
}
 110:	6422                	ld	s0,8(sp)
 112:	0141                	addi	sp,sp,16
 114:	8082                	ret
  for(n = 0; s[n]; n++)
 116:	4501                	li	a0,0
 118:	bfe5                	j	110 <strlen+0x20>

000000000000011a <memset>:

void*
memset(void *dst, int c, uint n)
{
 11a:	1141                	addi	sp,sp,-16
 11c:	e422                	sd	s0,8(sp)
 11e:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 120:	ca19                	beqz	a2,136 <memset+0x1c>
 122:	87aa                	mv	a5,a0
 124:	1602                	slli	a2,a2,0x20
 126:	9201                	srli	a2,a2,0x20
 128:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 12c:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 130:	0785                	addi	a5,a5,1
 132:	fee79de3          	bne	a5,a4,12c <memset+0x12>
  }
  return dst;
}
 136:	6422                	ld	s0,8(sp)
 138:	0141                	addi	sp,sp,16
 13a:	8082                	ret

000000000000013c <strchr>:

char*
strchr(const char *s, char c)
{
 13c:	1141                	addi	sp,sp,-16
 13e:	e422                	sd	s0,8(sp)
 140:	0800                	addi	s0,sp,16
  for(; *s; s++)
 142:	00054783          	lbu	a5,0(a0)
 146:	cb99                	beqz	a5,15c <strchr+0x20>
    if(*s == c)
 148:	00f58763          	beq	a1,a5,156 <strchr+0x1a>
  for(; *s; s++)
 14c:	0505                	addi	a0,a0,1
 14e:	00054783          	lbu	a5,0(a0)
 152:	fbfd                	bnez	a5,148 <strchr+0xc>
      return (char*)s;
  return 0;
 154:	4501                	li	a0,0
}
 156:	6422                	ld	s0,8(sp)
 158:	0141                	addi	sp,sp,16
 15a:	8082                	ret
  return 0;
 15c:	4501                	li	a0,0
 15e:	bfe5                	j	156 <strchr+0x1a>

0000000000000160 <gets>:

char*
gets(char *buf, int max)
{
 160:	711d                	addi	sp,sp,-96
 162:	ec86                	sd	ra,88(sp)
 164:	e8a2                	sd	s0,80(sp)
 166:	e4a6                	sd	s1,72(sp)
 168:	e0ca                	sd	s2,64(sp)
 16a:	fc4e                	sd	s3,56(sp)
 16c:	f852                	sd	s4,48(sp)
 16e:	f456                	sd	s5,40(sp)
 170:	f05a                	sd	s6,32(sp)
 172:	ec5e                	sd	s7,24(sp)
 174:	1080                	addi	s0,sp,96
 176:	8baa                	mv	s7,a0
 178:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 17a:	892a                	mv	s2,a0
 17c:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 17e:	4aa9                	li	s5,10
 180:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 182:	89a6                	mv	s3,s1
 184:	2485                	addiw	s1,s1,1
 186:	0344d863          	bge	s1,s4,1b6 <gets+0x56>
    cc = read(0, &c, 1);
 18a:	4605                	li	a2,1
 18c:	faf40593          	addi	a1,s0,-81
 190:	4501                	li	a0,0
 192:	00000097          	auipc	ra,0x0
 196:	19a080e7          	jalr	410(ra) # 32c <read>
    if(cc < 1)
 19a:	00a05e63          	blez	a0,1b6 <gets+0x56>
    buf[i++] = c;
 19e:	faf44783          	lbu	a5,-81(s0)
 1a2:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 1a6:	01578763          	beq	a5,s5,1b4 <gets+0x54>
 1aa:	0905                	addi	s2,s2,1
 1ac:	fd679be3          	bne	a5,s6,182 <gets+0x22>
  for(i=0; i+1 < max; ){
 1b0:	89a6                	mv	s3,s1
 1b2:	a011                	j	1b6 <gets+0x56>
 1b4:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 1b6:	99de                	add	s3,s3,s7
 1b8:	00098023          	sb	zero,0(s3)
  return buf;
}
 1bc:	855e                	mv	a0,s7
 1be:	60e6                	ld	ra,88(sp)
 1c0:	6446                	ld	s0,80(sp)
 1c2:	64a6                	ld	s1,72(sp)
 1c4:	6906                	ld	s2,64(sp)
 1c6:	79e2                	ld	s3,56(sp)
 1c8:	7a42                	ld	s4,48(sp)
 1ca:	7aa2                	ld	s5,40(sp)
 1cc:	7b02                	ld	s6,32(sp)
 1ce:	6be2                	ld	s7,24(sp)
 1d0:	6125                	addi	sp,sp,96
 1d2:	8082                	ret

00000000000001d4 <stat>:

int
stat(const char *n, struct stat *st)
{
 1d4:	1101                	addi	sp,sp,-32
 1d6:	ec06                	sd	ra,24(sp)
 1d8:	e822                	sd	s0,16(sp)
 1da:	e426                	sd	s1,8(sp)
 1dc:	e04a                	sd	s2,0(sp)
 1de:	1000                	addi	s0,sp,32
 1e0:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 1e2:	4581                	li	a1,0
 1e4:	00000097          	auipc	ra,0x0
 1e8:	170080e7          	jalr	368(ra) # 354 <open>
  if(fd < 0)
 1ec:	02054563          	bltz	a0,216 <stat+0x42>
 1f0:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 1f2:	85ca                	mv	a1,s2
 1f4:	00000097          	auipc	ra,0x0
 1f8:	178080e7          	jalr	376(ra) # 36c <fstat>
 1fc:	892a                	mv	s2,a0
  close(fd);
 1fe:	8526                	mv	a0,s1
 200:	00000097          	auipc	ra,0x0
 204:	13c080e7          	jalr	316(ra) # 33c <close>
  return r;
}
 208:	854a                	mv	a0,s2
 20a:	60e2                	ld	ra,24(sp)
 20c:	6442                	ld	s0,16(sp)
 20e:	64a2                	ld	s1,8(sp)
 210:	6902                	ld	s2,0(sp)
 212:	6105                	addi	sp,sp,32
 214:	8082                	ret
    return -1;
 216:	597d                	li	s2,-1
 218:	bfc5                	j	208 <stat+0x34>

000000000000021a <atoi>:

int
atoi(const char *s)
{
 21a:	1141                	addi	sp,sp,-16
 21c:	e422                	sd	s0,8(sp)
 21e:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 220:	00054683          	lbu	a3,0(a0)
 224:	fd06879b          	addiw	a5,a3,-48
 228:	0ff7f793          	zext.b	a5,a5
 22c:	4625                	li	a2,9
 22e:	02f66863          	bltu	a2,a5,25e <atoi+0x44>
 232:	872a                	mv	a4,a0
  n = 0;
 234:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 236:	0705                	addi	a4,a4,1
 238:	0025179b          	slliw	a5,a0,0x2
 23c:	9fa9                	addw	a5,a5,a0
 23e:	0017979b          	slliw	a5,a5,0x1
 242:	9fb5                	addw	a5,a5,a3
 244:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 248:	00074683          	lbu	a3,0(a4)
 24c:	fd06879b          	addiw	a5,a3,-48
 250:	0ff7f793          	zext.b	a5,a5
 254:	fef671e3          	bgeu	a2,a5,236 <atoi+0x1c>
  return n;
}
 258:	6422                	ld	s0,8(sp)
 25a:	0141                	addi	sp,sp,16
 25c:	8082                	ret
  n = 0;
 25e:	4501                	li	a0,0
 260:	bfe5                	j	258 <atoi+0x3e>

0000000000000262 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 262:	1141                	addi	sp,sp,-16
 264:	e422                	sd	s0,8(sp)
 266:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 268:	02b57463          	bgeu	a0,a1,290 <memmove+0x2e>
    while(n-- > 0)
 26c:	00c05f63          	blez	a2,28a <memmove+0x28>
 270:	1602                	slli	a2,a2,0x20
 272:	9201                	srli	a2,a2,0x20
 274:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 278:	872a                	mv	a4,a0
      *dst++ = *src++;
 27a:	0585                	addi	a1,a1,1
 27c:	0705                	addi	a4,a4,1
 27e:	fff5c683          	lbu	a3,-1(a1)
 282:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 286:	fee79ae3          	bne	a5,a4,27a <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 28a:	6422                	ld	s0,8(sp)
 28c:	0141                	addi	sp,sp,16
 28e:	8082                	ret
    dst += n;
 290:	00c50733          	add	a4,a0,a2
    src += n;
 294:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 296:	fec05ae3          	blez	a2,28a <memmove+0x28>
 29a:	fff6079b          	addiw	a5,a2,-1
 29e:	1782                	slli	a5,a5,0x20
 2a0:	9381                	srli	a5,a5,0x20
 2a2:	fff7c793          	not	a5,a5
 2a6:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 2a8:	15fd                	addi	a1,a1,-1
 2aa:	177d                	addi	a4,a4,-1
 2ac:	0005c683          	lbu	a3,0(a1)
 2b0:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 2b4:	fee79ae3          	bne	a5,a4,2a8 <memmove+0x46>
 2b8:	bfc9                	j	28a <memmove+0x28>

00000000000002ba <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 2ba:	1141                	addi	sp,sp,-16
 2bc:	e422                	sd	s0,8(sp)
 2be:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 2c0:	ca05                	beqz	a2,2f0 <memcmp+0x36>
 2c2:	fff6069b          	addiw	a3,a2,-1
 2c6:	1682                	slli	a3,a3,0x20
 2c8:	9281                	srli	a3,a3,0x20
 2ca:	0685                	addi	a3,a3,1
 2cc:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 2ce:	00054783          	lbu	a5,0(a0)
 2d2:	0005c703          	lbu	a4,0(a1)
 2d6:	00e79863          	bne	a5,a4,2e6 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 2da:	0505                	addi	a0,a0,1
    p2++;
 2dc:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 2de:	fed518e3          	bne	a0,a3,2ce <memcmp+0x14>
  }
  return 0;
 2e2:	4501                	li	a0,0
 2e4:	a019                	j	2ea <memcmp+0x30>
      return *p1 - *p2;
 2e6:	40e7853b          	subw	a0,a5,a4
}
 2ea:	6422                	ld	s0,8(sp)
 2ec:	0141                	addi	sp,sp,16
 2ee:	8082                	ret
  return 0;
 2f0:	4501                	li	a0,0
 2f2:	bfe5                	j	2ea <memcmp+0x30>

00000000000002f4 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 2f4:	1141                	addi	sp,sp,-16
 2f6:	e406                	sd	ra,8(sp)
 2f8:	e022                	sd	s0,0(sp)
 2fa:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 2fc:	00000097          	auipc	ra,0x0
 300:	f66080e7          	jalr	-154(ra) # 262 <memmove>
}
 304:	60a2                	ld	ra,8(sp)
 306:	6402                	ld	s0,0(sp)
 308:	0141                	addi	sp,sp,16
 30a:	8082                	ret

000000000000030c <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 30c:	4885                	li	a7,1
 ecall
 30e:	00000073          	ecall
 ret
 312:	8082                	ret

0000000000000314 <exit>:
.global exit
exit:
 li a7, SYS_exit
 314:	4889                	li	a7,2
 ecall
 316:	00000073          	ecall
 ret
 31a:	8082                	ret

000000000000031c <wait>:
.global wait
wait:
 li a7, SYS_wait
 31c:	488d                	li	a7,3
 ecall
 31e:	00000073          	ecall
 ret
 322:	8082                	ret

0000000000000324 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 324:	4891                	li	a7,4
 ecall
 326:	00000073          	ecall
 ret
 32a:	8082                	ret

000000000000032c <read>:
.global read
read:
 li a7, SYS_read
 32c:	4895                	li	a7,5
 ecall
 32e:	00000073          	ecall
 ret
 332:	8082                	ret

0000000000000334 <write>:
.global write
write:
 li a7, SYS_write
 334:	48c1                	li	a7,16
 ecall
 336:	00000073          	ecall
 ret
 33a:	8082                	ret

000000000000033c <close>:
.global close
close:
 li a7, SYS_close
 33c:	48d5                	li	a7,21
 ecall
 33e:	00000073          	ecall
 ret
 342:	8082                	ret

0000000000000344 <kill>:
.global kill
kill:
 li a7, SYS_kill
 344:	4899                	li	a7,6
 ecall
 346:	00000073          	ecall
 ret
 34a:	8082                	ret

000000000000034c <exec>:
.global exec
exec:
 li a7, SYS_exec
 34c:	489d                	li	a7,7
 ecall
 34e:	00000073          	ecall
 ret
 352:	8082                	ret

0000000000000354 <open>:
.global open
open:
 li a7, SYS_open
 354:	48bd                	li	a7,15
 ecall
 356:	00000073          	ecall
 ret
 35a:	8082                	ret

000000000000035c <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 35c:	48c5                	li	a7,17
 ecall
 35e:	00000073          	ecall
 ret
 362:	8082                	ret

0000000000000364 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 364:	48c9                	li	a7,18
 ecall
 366:	00000073          	ecall
 ret
 36a:	8082                	ret

000000000000036c <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 36c:	48a1                	li	a7,8
 ecall
 36e:	00000073          	ecall
 ret
 372:	8082                	ret

0000000000000374 <link>:
.global link
link:
 li a7, SYS_link
 374:	48cd                	li	a7,19
 ecall
 376:	00000073          	ecall
 ret
 37a:	8082                	ret

000000000000037c <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 37c:	48d1                	li	a7,20
 ecall
 37e:	00000073          	ecall
 ret
 382:	8082                	ret

0000000000000384 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 384:	48a5                	li	a7,9
 ecall
 386:	00000073          	ecall
 ret
 38a:	8082                	ret

000000000000038c <dup>:
.global dup
dup:
 li a7, SYS_dup
 38c:	48a9                	li	a7,10
 ecall
 38e:	00000073          	ecall
 ret
 392:	8082                	ret

0000000000000394 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 394:	48ad                	li	a7,11
 ecall
 396:	00000073          	ecall
 ret
 39a:	8082                	ret

000000000000039c <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 39c:	48b1                	li	a7,12
 ecall
 39e:	00000073          	ecall
 ret
 3a2:	8082                	ret

00000000000003a4 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 3a4:	48b5                	li	a7,13
 ecall
 3a6:	00000073          	ecall
 ret
 3aa:	8082                	ret

00000000000003ac <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 3ac:	48b9                	li	a7,14
 ecall
 3ae:	00000073          	ecall
 ret
 3b2:	8082                	ret

00000000000003b4 <ctime>:
.global ctime
ctime:
 li a7, SYS_ctime
 3b4:	48d9                	li	a7,22
 ecall
 3b6:	00000073          	ecall
 ret
 3ba:	8082                	ret

00000000000003bc <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 3bc:	1101                	addi	sp,sp,-32
 3be:	ec06                	sd	ra,24(sp)
 3c0:	e822                	sd	s0,16(sp)
 3c2:	1000                	addi	s0,sp,32
 3c4:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 3c8:	4605                	li	a2,1
 3ca:	fef40593          	addi	a1,s0,-17
 3ce:	00000097          	auipc	ra,0x0
 3d2:	f66080e7          	jalr	-154(ra) # 334 <write>
}
 3d6:	60e2                	ld	ra,24(sp)
 3d8:	6442                	ld	s0,16(sp)
 3da:	6105                	addi	sp,sp,32
 3dc:	8082                	ret

00000000000003de <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 3de:	7139                	addi	sp,sp,-64
 3e0:	fc06                	sd	ra,56(sp)
 3e2:	f822                	sd	s0,48(sp)
 3e4:	f426                	sd	s1,40(sp)
 3e6:	f04a                	sd	s2,32(sp)
 3e8:	ec4e                	sd	s3,24(sp)
 3ea:	0080                	addi	s0,sp,64
 3ec:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 3ee:	c299                	beqz	a3,3f4 <printint+0x16>
 3f0:	0805c963          	bltz	a1,482 <printint+0xa4>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 3f4:	2581                	sext.w	a1,a1
  neg = 0;
 3f6:	4881                	li	a7,0
 3f8:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 3fc:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 3fe:	2601                	sext.w	a2,a2
 400:	00001517          	auipc	a0,0x1
 404:	9f050513          	addi	a0,a0,-1552 # df0 <digits>
 408:	883a                	mv	a6,a4
 40a:	2705                	addiw	a4,a4,1
 40c:	02c5f7bb          	remuw	a5,a1,a2
 410:	1782                	slli	a5,a5,0x20
 412:	9381                	srli	a5,a5,0x20
 414:	97aa                	add	a5,a5,a0
 416:	0007c783          	lbu	a5,0(a5)
 41a:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 41e:	0005879b          	sext.w	a5,a1
 422:	02c5d5bb          	divuw	a1,a1,a2
 426:	0685                	addi	a3,a3,1
 428:	fec7f0e3          	bgeu	a5,a2,408 <printint+0x2a>
  if(neg)
 42c:	00088c63          	beqz	a7,444 <printint+0x66>
    buf[i++] = '-';
 430:	fd070793          	addi	a5,a4,-48
 434:	00878733          	add	a4,a5,s0
 438:	02d00793          	li	a5,45
 43c:	fef70823          	sb	a5,-16(a4)
 440:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 444:	02e05863          	blez	a4,474 <printint+0x96>
 448:	fc040793          	addi	a5,s0,-64
 44c:	00e78933          	add	s2,a5,a4
 450:	fff78993          	addi	s3,a5,-1
 454:	99ba                	add	s3,s3,a4
 456:	377d                	addiw	a4,a4,-1
 458:	1702                	slli	a4,a4,0x20
 45a:	9301                	srli	a4,a4,0x20
 45c:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 460:	fff94583          	lbu	a1,-1(s2)
 464:	8526                	mv	a0,s1
 466:	00000097          	auipc	ra,0x0
 46a:	f56080e7          	jalr	-170(ra) # 3bc <putc>
  while(--i >= 0)
 46e:	197d                	addi	s2,s2,-1
 470:	ff3918e3          	bne	s2,s3,460 <printint+0x82>
}
 474:	70e2                	ld	ra,56(sp)
 476:	7442                	ld	s0,48(sp)
 478:	74a2                	ld	s1,40(sp)
 47a:	7902                	ld	s2,32(sp)
 47c:	69e2                	ld	s3,24(sp)
 47e:	6121                	addi	sp,sp,64
 480:	8082                	ret
    x = -xx;
 482:	40b005bb          	negw	a1,a1
    neg = 1;
 486:	4885                	li	a7,1
    x = -xx;
 488:	bf85                	j	3f8 <printint+0x1a>

000000000000048a <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 48a:	715d                	addi	sp,sp,-80
 48c:	e486                	sd	ra,72(sp)
 48e:	e0a2                	sd	s0,64(sp)
 490:	fc26                	sd	s1,56(sp)
 492:	f84a                	sd	s2,48(sp)
 494:	f44e                	sd	s3,40(sp)
 496:	f052                	sd	s4,32(sp)
 498:	ec56                	sd	s5,24(sp)
 49a:	e85a                	sd	s6,16(sp)
 49c:	e45e                	sd	s7,8(sp)
 49e:	e062                	sd	s8,0(sp)
 4a0:	0880                	addi	s0,sp,80
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 4a2:	0005c903          	lbu	s2,0(a1)
 4a6:	18090c63          	beqz	s2,63e <vprintf+0x1b4>
 4aa:	8aaa                	mv	s5,a0
 4ac:	8bb2                	mv	s7,a2
 4ae:	00158493          	addi	s1,a1,1
  state = 0;
 4b2:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 4b4:	02500a13          	li	s4,37
 4b8:	4b55                	li	s6,21
 4ba:	a839                	j	4d8 <vprintf+0x4e>
        putc(fd, c);
 4bc:	85ca                	mv	a1,s2
 4be:	8556                	mv	a0,s5
 4c0:	00000097          	auipc	ra,0x0
 4c4:	efc080e7          	jalr	-260(ra) # 3bc <putc>
 4c8:	a019                	j	4ce <vprintf+0x44>
    } else if(state == '%'){
 4ca:	01498d63          	beq	s3,s4,4e4 <vprintf+0x5a>
  for(i = 0; fmt[i]; i++){
 4ce:	0485                	addi	s1,s1,1
 4d0:	fff4c903          	lbu	s2,-1(s1)
 4d4:	16090563          	beqz	s2,63e <vprintf+0x1b4>
    if(state == 0){
 4d8:	fe0999e3          	bnez	s3,4ca <vprintf+0x40>
      if(c == '%'){
 4dc:	ff4910e3          	bne	s2,s4,4bc <vprintf+0x32>
        state = '%';
 4e0:	89d2                	mv	s3,s4
 4e2:	b7f5                	j	4ce <vprintf+0x44>
      if(c == 'd'){
 4e4:	13490263          	beq	s2,s4,608 <vprintf+0x17e>
 4e8:	f9d9079b          	addiw	a5,s2,-99
 4ec:	0ff7f793          	zext.b	a5,a5
 4f0:	12fb6563          	bltu	s6,a5,61a <vprintf+0x190>
 4f4:	f9d9079b          	addiw	a5,s2,-99
 4f8:	0ff7f713          	zext.b	a4,a5
 4fc:	10eb6f63          	bltu	s6,a4,61a <vprintf+0x190>
 500:	00271793          	slli	a5,a4,0x2
 504:	00001717          	auipc	a4,0x1
 508:	89470713          	addi	a4,a4,-1900 # d98 <ulthread_context_switch+0x96>
 50c:	97ba                	add	a5,a5,a4
 50e:	439c                	lw	a5,0(a5)
 510:	97ba                	add	a5,a5,a4
 512:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
 514:	008b8913          	addi	s2,s7,8
 518:	4685                	li	a3,1
 51a:	4629                	li	a2,10
 51c:	000ba583          	lw	a1,0(s7)
 520:	8556                	mv	a0,s5
 522:	00000097          	auipc	ra,0x0
 526:	ebc080e7          	jalr	-324(ra) # 3de <printint>
 52a:	8bca                	mv	s7,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 52c:	4981                	li	s3,0
 52e:	b745                	j	4ce <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 530:	008b8913          	addi	s2,s7,8
 534:	4681                	li	a3,0
 536:	4629                	li	a2,10
 538:	000ba583          	lw	a1,0(s7)
 53c:	8556                	mv	a0,s5
 53e:	00000097          	auipc	ra,0x0
 542:	ea0080e7          	jalr	-352(ra) # 3de <printint>
 546:	8bca                	mv	s7,s2
      state = 0;
 548:	4981                	li	s3,0
 54a:	b751                	j	4ce <vprintf+0x44>
        printint(fd, va_arg(ap, int), 16, 0);
 54c:	008b8913          	addi	s2,s7,8
 550:	4681                	li	a3,0
 552:	4641                	li	a2,16
 554:	000ba583          	lw	a1,0(s7)
 558:	8556                	mv	a0,s5
 55a:	00000097          	auipc	ra,0x0
 55e:	e84080e7          	jalr	-380(ra) # 3de <printint>
 562:	8bca                	mv	s7,s2
      state = 0;
 564:	4981                	li	s3,0
 566:	b7a5                	j	4ce <vprintf+0x44>
        printptr(fd, va_arg(ap, uint64));
 568:	008b8c13          	addi	s8,s7,8
 56c:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 570:	03000593          	li	a1,48
 574:	8556                	mv	a0,s5
 576:	00000097          	auipc	ra,0x0
 57a:	e46080e7          	jalr	-442(ra) # 3bc <putc>
  putc(fd, 'x');
 57e:	07800593          	li	a1,120
 582:	8556                	mv	a0,s5
 584:	00000097          	auipc	ra,0x0
 588:	e38080e7          	jalr	-456(ra) # 3bc <putc>
 58c:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 58e:	00001b97          	auipc	s7,0x1
 592:	862b8b93          	addi	s7,s7,-1950 # df0 <digits>
 596:	03c9d793          	srli	a5,s3,0x3c
 59a:	97de                	add	a5,a5,s7
 59c:	0007c583          	lbu	a1,0(a5)
 5a0:	8556                	mv	a0,s5
 5a2:	00000097          	auipc	ra,0x0
 5a6:	e1a080e7          	jalr	-486(ra) # 3bc <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 5aa:	0992                	slli	s3,s3,0x4
 5ac:	397d                	addiw	s2,s2,-1
 5ae:	fe0914e3          	bnez	s2,596 <vprintf+0x10c>
        printptr(fd, va_arg(ap, uint64));
 5b2:	8be2                	mv	s7,s8
      state = 0;
 5b4:	4981                	li	s3,0
 5b6:	bf21                	j	4ce <vprintf+0x44>
        s = va_arg(ap, char*);
 5b8:	008b8993          	addi	s3,s7,8
 5bc:	000bb903          	ld	s2,0(s7)
        if(s == 0)
 5c0:	02090163          	beqz	s2,5e2 <vprintf+0x158>
        while(*s != 0){
 5c4:	00094583          	lbu	a1,0(s2)
 5c8:	c9a5                	beqz	a1,638 <vprintf+0x1ae>
          putc(fd, *s);
 5ca:	8556                	mv	a0,s5
 5cc:	00000097          	auipc	ra,0x0
 5d0:	df0080e7          	jalr	-528(ra) # 3bc <putc>
          s++;
 5d4:	0905                	addi	s2,s2,1
        while(*s != 0){
 5d6:	00094583          	lbu	a1,0(s2)
 5da:	f9e5                	bnez	a1,5ca <vprintf+0x140>
        s = va_arg(ap, char*);
 5dc:	8bce                	mv	s7,s3
      state = 0;
 5de:	4981                	li	s3,0
 5e0:	b5fd                	j	4ce <vprintf+0x44>
          s = "(null)";
 5e2:	00000917          	auipc	s2,0x0
 5e6:	7ae90913          	addi	s2,s2,1966 # d90 <ulthread_context_switch+0x8e>
        while(*s != 0){
 5ea:	02800593          	li	a1,40
 5ee:	bff1                	j	5ca <vprintf+0x140>
        putc(fd, va_arg(ap, uint));
 5f0:	008b8913          	addi	s2,s7,8
 5f4:	000bc583          	lbu	a1,0(s7)
 5f8:	8556                	mv	a0,s5
 5fa:	00000097          	auipc	ra,0x0
 5fe:	dc2080e7          	jalr	-574(ra) # 3bc <putc>
 602:	8bca                	mv	s7,s2
      state = 0;
 604:	4981                	li	s3,0
 606:	b5e1                	j	4ce <vprintf+0x44>
        putc(fd, c);
 608:	02500593          	li	a1,37
 60c:	8556                	mv	a0,s5
 60e:	00000097          	auipc	ra,0x0
 612:	dae080e7          	jalr	-594(ra) # 3bc <putc>
      state = 0;
 616:	4981                	li	s3,0
 618:	bd5d                	j	4ce <vprintf+0x44>
        putc(fd, '%');
 61a:	02500593          	li	a1,37
 61e:	8556                	mv	a0,s5
 620:	00000097          	auipc	ra,0x0
 624:	d9c080e7          	jalr	-612(ra) # 3bc <putc>
        putc(fd, c);
 628:	85ca                	mv	a1,s2
 62a:	8556                	mv	a0,s5
 62c:	00000097          	auipc	ra,0x0
 630:	d90080e7          	jalr	-624(ra) # 3bc <putc>
      state = 0;
 634:	4981                	li	s3,0
 636:	bd61                	j	4ce <vprintf+0x44>
        s = va_arg(ap, char*);
 638:	8bce                	mv	s7,s3
      state = 0;
 63a:	4981                	li	s3,0
 63c:	bd49                	j	4ce <vprintf+0x44>
    }
  }
}
 63e:	60a6                	ld	ra,72(sp)
 640:	6406                	ld	s0,64(sp)
 642:	74e2                	ld	s1,56(sp)
 644:	7942                	ld	s2,48(sp)
 646:	79a2                	ld	s3,40(sp)
 648:	7a02                	ld	s4,32(sp)
 64a:	6ae2                	ld	s5,24(sp)
 64c:	6b42                	ld	s6,16(sp)
 64e:	6ba2                	ld	s7,8(sp)
 650:	6c02                	ld	s8,0(sp)
 652:	6161                	addi	sp,sp,80
 654:	8082                	ret

0000000000000656 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 656:	715d                	addi	sp,sp,-80
 658:	ec06                	sd	ra,24(sp)
 65a:	e822                	sd	s0,16(sp)
 65c:	1000                	addi	s0,sp,32
 65e:	e010                	sd	a2,0(s0)
 660:	e414                	sd	a3,8(s0)
 662:	e818                	sd	a4,16(s0)
 664:	ec1c                	sd	a5,24(s0)
 666:	03043023          	sd	a6,32(s0)
 66a:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 66e:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 672:	8622                	mv	a2,s0
 674:	00000097          	auipc	ra,0x0
 678:	e16080e7          	jalr	-490(ra) # 48a <vprintf>
}
 67c:	60e2                	ld	ra,24(sp)
 67e:	6442                	ld	s0,16(sp)
 680:	6161                	addi	sp,sp,80
 682:	8082                	ret

0000000000000684 <printf>:

void
printf(const char *fmt, ...)
{
 684:	711d                	addi	sp,sp,-96
 686:	ec06                	sd	ra,24(sp)
 688:	e822                	sd	s0,16(sp)
 68a:	1000                	addi	s0,sp,32
 68c:	e40c                	sd	a1,8(s0)
 68e:	e810                	sd	a2,16(s0)
 690:	ec14                	sd	a3,24(s0)
 692:	f018                	sd	a4,32(s0)
 694:	f41c                	sd	a5,40(s0)
 696:	03043823          	sd	a6,48(s0)
 69a:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 69e:	00840613          	addi	a2,s0,8
 6a2:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 6a6:	85aa                	mv	a1,a0
 6a8:	4505                	li	a0,1
 6aa:	00000097          	auipc	ra,0x0
 6ae:	de0080e7          	jalr	-544(ra) # 48a <vprintf>
}
 6b2:	60e2                	ld	ra,24(sp)
 6b4:	6442                	ld	s0,16(sp)
 6b6:	6125                	addi	sp,sp,96
 6b8:	8082                	ret

00000000000006ba <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 6ba:	1141                	addi	sp,sp,-16
 6bc:	e422                	sd	s0,8(sp)
 6be:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 6c0:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 6c4:	00001797          	auipc	a5,0x1
 6c8:	93c7b783          	ld	a5,-1732(a5) # 1000 <freep>
 6cc:	a02d                	j	6f6 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 6ce:	4618                	lw	a4,8(a2)
 6d0:	9f2d                	addw	a4,a4,a1
 6d2:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 6d6:	6398                	ld	a4,0(a5)
 6d8:	6310                	ld	a2,0(a4)
 6da:	a83d                	j	718 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 6dc:	ff852703          	lw	a4,-8(a0)
 6e0:	9f31                	addw	a4,a4,a2
 6e2:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 6e4:	ff053683          	ld	a3,-16(a0)
 6e8:	a091                	j	72c <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 6ea:	6398                	ld	a4,0(a5)
 6ec:	00e7e463          	bltu	a5,a4,6f4 <free+0x3a>
 6f0:	00e6ea63          	bltu	a3,a4,704 <free+0x4a>
{
 6f4:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 6f6:	fed7fae3          	bgeu	a5,a3,6ea <free+0x30>
 6fa:	6398                	ld	a4,0(a5)
 6fc:	00e6e463          	bltu	a3,a4,704 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 700:	fee7eae3          	bltu	a5,a4,6f4 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 704:	ff852583          	lw	a1,-8(a0)
 708:	6390                	ld	a2,0(a5)
 70a:	02059813          	slli	a6,a1,0x20
 70e:	01c85713          	srli	a4,a6,0x1c
 712:	9736                	add	a4,a4,a3
 714:	fae60de3          	beq	a2,a4,6ce <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 718:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 71c:	4790                	lw	a2,8(a5)
 71e:	02061593          	slli	a1,a2,0x20
 722:	01c5d713          	srli	a4,a1,0x1c
 726:	973e                	add	a4,a4,a5
 728:	fae68ae3          	beq	a3,a4,6dc <free+0x22>
    p->s.ptr = bp->s.ptr;
 72c:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 72e:	00001717          	auipc	a4,0x1
 732:	8cf73923          	sd	a5,-1838(a4) # 1000 <freep>
}
 736:	6422                	ld	s0,8(sp)
 738:	0141                	addi	sp,sp,16
 73a:	8082                	ret

000000000000073c <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 73c:	7139                	addi	sp,sp,-64
 73e:	fc06                	sd	ra,56(sp)
 740:	f822                	sd	s0,48(sp)
 742:	f426                	sd	s1,40(sp)
 744:	f04a                	sd	s2,32(sp)
 746:	ec4e                	sd	s3,24(sp)
 748:	e852                	sd	s4,16(sp)
 74a:	e456                	sd	s5,8(sp)
 74c:	e05a                	sd	s6,0(sp)
 74e:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 750:	02051493          	slli	s1,a0,0x20
 754:	9081                	srli	s1,s1,0x20
 756:	04bd                	addi	s1,s1,15
 758:	8091                	srli	s1,s1,0x4
 75a:	0014899b          	addiw	s3,s1,1
 75e:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 760:	00001517          	auipc	a0,0x1
 764:	8a053503          	ld	a0,-1888(a0) # 1000 <freep>
 768:	c515                	beqz	a0,794 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 76a:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 76c:	4798                	lw	a4,8(a5)
 76e:	02977f63          	bgeu	a4,s1,7ac <malloc+0x70>
  if(nu < 4096)
 772:	8a4e                	mv	s4,s3
 774:	0009871b          	sext.w	a4,s3
 778:	6685                	lui	a3,0x1
 77a:	00d77363          	bgeu	a4,a3,780 <malloc+0x44>
 77e:	6a05                	lui	s4,0x1
 780:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 784:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 788:	00001917          	auipc	s2,0x1
 78c:	87890913          	addi	s2,s2,-1928 # 1000 <freep>
  if(p == (char*)-1)
 790:	5afd                	li	s5,-1
 792:	a895                	j	806 <malloc+0xca>
    base.s.ptr = freep = prevp = &base;
 794:	00001797          	auipc	a5,0x1
 798:	88c78793          	addi	a5,a5,-1908 # 1020 <base>
 79c:	00001717          	auipc	a4,0x1
 7a0:	86f73223          	sd	a5,-1948(a4) # 1000 <freep>
 7a4:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 7a6:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 7aa:	b7e1                	j	772 <malloc+0x36>
      if(p->s.size == nunits)
 7ac:	02e48c63          	beq	s1,a4,7e4 <malloc+0xa8>
        p->s.size -= nunits;
 7b0:	4137073b          	subw	a4,a4,s3
 7b4:	c798                	sw	a4,8(a5)
        p += p->s.size;
 7b6:	02071693          	slli	a3,a4,0x20
 7ba:	01c6d713          	srli	a4,a3,0x1c
 7be:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 7c0:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 7c4:	00001717          	auipc	a4,0x1
 7c8:	82a73e23          	sd	a0,-1988(a4) # 1000 <freep>
      return (void*)(p + 1);
 7cc:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 7d0:	70e2                	ld	ra,56(sp)
 7d2:	7442                	ld	s0,48(sp)
 7d4:	74a2                	ld	s1,40(sp)
 7d6:	7902                	ld	s2,32(sp)
 7d8:	69e2                	ld	s3,24(sp)
 7da:	6a42                	ld	s4,16(sp)
 7dc:	6aa2                	ld	s5,8(sp)
 7de:	6b02                	ld	s6,0(sp)
 7e0:	6121                	addi	sp,sp,64
 7e2:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 7e4:	6398                	ld	a4,0(a5)
 7e6:	e118                	sd	a4,0(a0)
 7e8:	bff1                	j	7c4 <malloc+0x88>
  hp->s.size = nu;
 7ea:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 7ee:	0541                	addi	a0,a0,16
 7f0:	00000097          	auipc	ra,0x0
 7f4:	eca080e7          	jalr	-310(ra) # 6ba <free>
  return freep;
 7f8:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 7fc:	d971                	beqz	a0,7d0 <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 7fe:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 800:	4798                	lw	a4,8(a5)
 802:	fa9775e3          	bgeu	a4,s1,7ac <malloc+0x70>
    if(p == freep)
 806:	00093703          	ld	a4,0(s2)
 80a:	853e                	mv	a0,a5
 80c:	fef719e3          	bne	a4,a5,7fe <malloc+0xc2>
  p = sbrk(nu * sizeof(Header));
 810:	8552                	mv	a0,s4
 812:	00000097          	auipc	ra,0x0
 816:	b8a080e7          	jalr	-1142(ra) # 39c <sbrk>
  if(p == (char*)-1)
 81a:	fd5518e3          	bne	a0,s5,7ea <malloc+0xae>
        return 0;
 81e:	4501                	li	a0,0
 820:	bf45                	j	7d0 <malloc+0x94>

0000000000000822 <get_current_tid>:
struct ulthread *scheduler_thread;
enum ulthread_scheduling_algorithm algorithm;

/* Get thread ID */
int get_current_tid(void)
{
 822:	1141                	addi	sp,sp,-16
 824:	e422                	sd	s0,8(sp)
 826:	0800                	addi	s0,sp,16
  return current_thread->tid;
}
 828:	00000797          	auipc	a5,0x0
 82c:	7f07b783          	ld	a5,2032(a5) # 1018 <current_thread>
 830:	43c8                	lw	a0,4(a5)
 832:	6422                	ld	s0,8(sp)
 834:	0141                	addi	sp,sp,16
 836:	8082                	ret

0000000000000838 <roundRobin>:

void roundRobin(void)
{
 838:	715d                	addi	sp,sp,-80
 83a:	e486                	sd	ra,72(sp)
 83c:	e0a2                	sd	s0,64(sp)
 83e:	fc26                	sd	s1,56(sp)
 840:	f84a                	sd	s2,48(sp)
 842:	f44e                	sd	s3,40(sp)
 844:	f052                	sd	s4,32(sp)
 846:	ec56                	sd	s5,24(sp)
 848:	e85a                	sd	s6,16(sp)
 84a:	e45e                	sd	s7,8(sp)
 84c:	e062                	sd	s8,0(sp)
 84e:	0880                	addi	s0,sp,80
        struct ulthread *temp = current_thread;
        current_thread = t;
        printf("[*] ultschedule (next tid: %d)\n", get_current_tid());
        ulthread_context_switch(&temp->context, &t->context);
      }
      if (t->state == YIELD)
 850:	4a09                	li	s4,2
      if (t->state == RUNNABLE && t != scheduler_thread)
 852:	00000b97          	auipc	s7,0x0
 856:	7beb8b93          	addi	s7,s7,1982 # 1010 <scheduler_thread>
        struct ulthread *temp = current_thread;
 85a:	00000a97          	auipc	s5,0x0
 85e:	7bea8a93          	addi	s5,s5,1982 # 1018 <current_thread>
        printf("[*] ultschedule (next tid: %d)\n", get_current_tid());
 862:	00000c17          	auipc	s8,0x0
 866:	5a6c0c13          	addi	s8,s8,1446 # e08 <digits+0x18>
    for (t = ulthreads; t < &ulthreads[MAXULTHREADS]; t++)
 86a:	00004997          	auipc	s3,0x4
 86e:	ce698993          	addi	s3,s3,-794 # 4550 <ulthreads+0x3520>
 872:	a0b9                	j	8c0 <roundRobin+0x88>
      if (t->state == RUNNABLE && t != scheduler_thread)
 874:	000bb783          	ld	a5,0(s7)
 878:	02978863          	beq	a5,s1,8a8 <roundRobin+0x70>
        struct ulthread *temp = current_thread;
 87c:	000abb03          	ld	s6,0(s5)
        current_thread = t;
 880:	009ab023          	sd	s1,0(s5)
        printf("[*] ultschedule (next tid: %d)\n", get_current_tid());
 884:	40cc                	lw	a1,4(s1)
 886:	8562                	mv	a0,s8
 888:	00000097          	auipc	ra,0x0
 88c:	dfc080e7          	jalr	-516(ra) # 684 <printf>
        ulthread_context_switch(&temp->context, &t->context);
 890:	01848593          	addi	a1,s1,24
 894:	018b0513          	addi	a0,s6,24
 898:	00000097          	auipc	ra,0x0
 89c:	46a080e7          	jalr	1130(ra) # d02 <ulthread_context_switch>
        threadAvailable = true;
 8a0:	874a                	mv	a4,s2
 8a2:	a811                	j	8b6 <roundRobin+0x7e>
      {
        t->state = RUNNABLE;
 8a4:	0124a023          	sw	s2,0(s1)
    for (t = ulthreads; t < &ulthreads[MAXULTHREADS]; t++)
 8a8:	08848493          	addi	s1,s1,136
 8ac:	01348963          	beq	s1,s3,8be <roundRobin+0x86>
      if (t->state == RUNNABLE && t != scheduler_thread)
 8b0:	409c                	lw	a5,0(s1)
 8b2:	fd2781e3          	beq	a5,s2,874 <roundRobin+0x3c>
      if (t->state == YIELD)
 8b6:	409c                	lw	a5,0(s1)
 8b8:	ff4798e3          	bne	a5,s4,8a8 <roundRobin+0x70>
 8bc:	b7e5                	j	8a4 <roundRobin+0x6c>
      }
    }
    if (!threadAvailable)
 8be:	cb01                	beqz	a4,8ce <roundRobin+0x96>
    bool threadAvailable = false;
 8c0:	4701                	li	a4,0
    for (t = ulthreads; t < &ulthreads[MAXULTHREADS]; t++)
 8c2:	00000497          	auipc	s1,0x0
 8c6:	76e48493          	addi	s1,s1,1902 # 1030 <ulthreads>
      if (t->state == RUNNABLE && t != scheduler_thread)
 8ca:	4905                	li	s2,1
 8cc:	b7d5                	j	8b0 <roundRobin+0x78>
    {
      break;
    }
  }
}
 8ce:	60a6                	ld	ra,72(sp)
 8d0:	6406                	ld	s0,64(sp)
 8d2:	74e2                	ld	s1,56(sp)
 8d4:	7942                	ld	s2,48(sp)
 8d6:	79a2                	ld	s3,40(sp)
 8d8:	7a02                	ld	s4,32(sp)
 8da:	6ae2                	ld	s5,24(sp)
 8dc:	6b42                	ld	s6,16(sp)
 8de:	6ba2                	ld	s7,8(sp)
 8e0:	6c02                	ld	s8,0(sp)
 8e2:	6161                	addi	sp,sp,80
 8e4:	8082                	ret

00000000000008e6 <firstComeFirstServe>:

void firstComeFirstServe(void)
{
 8e6:	715d                	addi	sp,sp,-80
 8e8:	e486                	sd	ra,72(sp)
 8ea:	e0a2                	sd	s0,64(sp)
 8ec:	fc26                	sd	s1,56(sp)
 8ee:	f84a                	sd	s2,48(sp)
 8f0:	f44e                	sd	s3,40(sp)
 8f2:	f052                	sd	s4,32(sp)
 8f4:	ec56                	sd	s5,24(sp)
 8f6:	e85a                	sd	s6,16(sp)
 8f8:	e45e                	sd	s7,8(sp)
 8fa:	e062                	sd	s8,0(sp)
 8fc:	0880                	addi	s0,sp,80
    uint64 oldest = __INT64_MAX__;
    int threadIndex = -1;
    int alternativeIndex = -1;
    for (t = ulthreads+1; t < &ulthreads[MAXULTHREADS]; t++)
    {
      if (t->state == RUNNABLE && t != scheduler_thread && t->lastTime < oldest)
 8fe:	00000b97          	auipc	s7,0x0
 902:	712b8b93          	addi	s7,s7,1810 # 1010 <scheduler_thread>
    int alternativeIndex = -1;
 906:	5afd                	li	s5,-1
    uint64 oldest = __INT64_MAX__;
 908:	001adb13          	srli	s6,s5,0x1
      if (t->state == RUNNABLE && t != scheduler_thread && t->lastTime < oldest)
 90c:	4485                	li	s1,1
        oldest = t->lastTime;
        threadIndex = t->tid;
        threadAvailable = true;
      }

      if (t->state == YIELD){
 90e:	4989                	li	s3,2
    for (t = ulthreads+1; t < &ulthreads[MAXULTHREADS]; t++)
 910:	00004917          	auipc	s2,0x4
 914:	c4090913          	addi	s2,s2,-960 # 4550 <ulthreads+0x3520>
        break;
      }
      
    }
    label : 
      struct ulthread *temp = current_thread;
 918:	00000a17          	auipc	s4,0x0
 91c:	700a0a13          	addi	s4,s4,1792 # 1018 <current_thread>
 920:	a88d                	j	992 <firstComeFirstServe+0xac>
      if (t->state == RUNNABLE && t != scheduler_thread && t->lastTime < oldest)
 922:	00f58963          	beq	a1,a5,934 <firstComeFirstServe+0x4e>
 926:	6b98                	ld	a4,16(a5)
 928:	00c77663          	bgeu	a4,a2,934 <firstComeFirstServe+0x4e>
        threadIndex = t->tid;
 92c:	0047a803          	lw	a6,4(a5)
        oldest = t->lastTime;
 930:	863a                	mv	a2,a4
        threadAvailable = true;
 932:	8526                	mv	a0,s1
    for (t = ulthreads+1; t < &ulthreads[MAXULTHREADS]; t++)
 934:	08878793          	addi	a5,a5,136
 938:	01278a63          	beq	a5,s2,94c <firstComeFirstServe+0x66>
      if (t->state == RUNNABLE && t != scheduler_thread && t->lastTime < oldest)
 93c:	4398                	lw	a4,0(a5)
 93e:	fe9702e3          	beq	a4,s1,922 <firstComeFirstServe+0x3c>
      if (t->state == YIELD){
 942:	ff3719e3          	bne	a4,s3,934 <firstComeFirstServe+0x4e>
        t->state = RUNNABLE;
 946:	c384                	sw	s1,0(a5)
        alternativeIndex = t->tid;
 948:	43d4                	lw	a3,4(a5)
 94a:	b7ed                	j	934 <firstComeFirstServe+0x4e>
    if (!threadAvailable)
 94c:	ed31                	bnez	a0,9a8 <firstComeFirstServe+0xc2>
      if(alternativeIndex > 0){
 94e:	04d05f63          	blez	a3,9ac <firstComeFirstServe+0xc6>
      struct ulthread *temp = current_thread;
 952:	000a3c03          	ld	s8,0(s4)
      current_thread = &ulthreads[threadIndex];
 956:	00469793          	slli	a5,a3,0x4
 95a:	00d78733          	add	a4,a5,a3
 95e:	070e                	slli	a4,a4,0x3
 960:	00000617          	auipc	a2,0x0
 964:	6d060613          	addi	a2,a2,1744 # 1030 <ulthreads>
 968:	9732                	add	a4,a4,a2
 96a:	00ea3023          	sd	a4,0(s4)
      printf("[*] ultschedule (next tid: %d), time = %d\n", get_current_tid());
 96e:	434c                	lw	a1,4(a4)
 970:	00000517          	auipc	a0,0x0
 974:	4b850513          	addi	a0,a0,1208 # e28 <digits+0x38>
 978:	00000097          	auipc	ra,0x0
 97c:	d0c080e7          	jalr	-756(ra) # 684 <printf>
      ulthread_context_switch(&temp->context, &current_thread->context);
 980:	000a3583          	ld	a1,0(s4)
 984:	05e1                	addi	a1,a1,24
 986:	018c0513          	addi	a0,s8,24
 98a:	00000097          	auipc	ra,0x0
 98e:	378080e7          	jalr	888(ra) # d02 <ulthread_context_switch>
      if (t->state == RUNNABLE && t != scheduler_thread && t->lastTime < oldest)
 992:	000bb583          	ld	a1,0(s7)
    int alternativeIndex = -1;
 996:	86d6                	mv	a3,s5
    int threadIndex = -1;
 998:	8856                	mv	a6,s5
    uint64 oldest = __INT64_MAX__;
 99a:	865a                	mv	a2,s6
    bool threadAvailable = false;
 99c:	4501                	li	a0,0
    for (t = ulthreads+1; t < &ulthreads[MAXULTHREADS]; t++)
 99e:	00000797          	auipc	a5,0x0
 9a2:	71a78793          	addi	a5,a5,1818 # 10b8 <ulthreads+0x88>
 9a6:	bf59                	j	93c <firstComeFirstServe+0x56>
    label : 
 9a8:	86c2                	mv	a3,a6
 9aa:	b765                	j	952 <firstComeFirstServe+0x6c>
  }
}
 9ac:	60a6                	ld	ra,72(sp)
 9ae:	6406                	ld	s0,64(sp)
 9b0:	74e2                	ld	s1,56(sp)
 9b2:	7942                	ld	s2,48(sp)
 9b4:	79a2                	ld	s3,40(sp)
 9b6:	7a02                	ld	s4,32(sp)
 9b8:	6ae2                	ld	s5,24(sp)
 9ba:	6b42                	ld	s6,16(sp)
 9bc:	6ba2                	ld	s7,8(sp)
 9be:	6c02                	ld	s8,0(sp)
 9c0:	6161                	addi	sp,sp,80
 9c2:	8082                	ret

00000000000009c4 <priorityScheduling>:


void priorityScheduling(void)
{
 9c4:	715d                	addi	sp,sp,-80
 9c6:	e486                	sd	ra,72(sp)
 9c8:	e0a2                	sd	s0,64(sp)
 9ca:	fc26                	sd	s1,56(sp)
 9cc:	f84a                	sd	s2,48(sp)
 9ce:	f44e                	sd	s3,40(sp)
 9d0:	f052                	sd	s4,32(sp)
 9d2:	ec56                	sd	s5,24(sp)
 9d4:	e85a                	sd	s6,16(sp)
 9d6:	e45e                	sd	s7,8(sp)
 9d8:	0880                	addi	s0,sp,80
    int maxPriority = -1;
    int threadIndex = -1;
    int alternativeIndex = -1;
    for (t = ulthreads+1; t < &ulthreads[MAXULTHREADS]; t++)
    {
      if (t->state == RUNNABLE && t != scheduler_thread && t->priority > maxPriority)
 9da:	00000b17          	auipc	s6,0x0
 9de:	636b0b13          	addi	s6,s6,1590 # 1010 <scheduler_thread>
    int alternativeIndex = -1;
 9e2:	5a7d                	li	s4,-1
      if (t->state == RUNNABLE && t != scheduler_thread && t->priority > maxPriority)
 9e4:	4485                	li	s1,1
        // flag = true;

        // break; // switch to highest-priority thread and exit loop
      }

      if (t->state == YIELD){
 9e6:	4989                	li	s3,2
    for (t = ulthreads+1; t < &ulthreads[MAXULTHREADS]; t++)
 9e8:	00004917          	auipc	s2,0x4
 9ec:	b6890913          	addi	s2,s2,-1176 # 4550 <ulthreads+0x3520>
        break;
      }
      
    }
    label : 
      struct ulthread *temp = current_thread;
 9f0:	00000a97          	auipc	s5,0x0
 9f4:	628a8a93          	addi	s5,s5,1576 # 1018 <current_thread>
 9f8:	a88d                	j	a6a <priorityScheduling+0xa6>
      if (t->state == RUNNABLE && t != scheduler_thread && t->priority > maxPriority)
 9fa:	00f58963          	beq	a1,a5,a0c <priorityScheduling+0x48>
 9fe:	47d8                	lw	a4,12(a5)
 a00:	00e65663          	bge	a2,a4,a0c <priorityScheduling+0x48>
        threadIndex = t->tid;
 a04:	0047a803          	lw	a6,4(a5)
        maxPriority = t->priority;
 a08:	863a                	mv	a2,a4
        threadAvailable = true;
 a0a:	8526                	mv	a0,s1
    for (t = ulthreads+1; t < &ulthreads[MAXULTHREADS]; t++)
 a0c:	08878793          	addi	a5,a5,136
 a10:	01278a63          	beq	a5,s2,a24 <priorityScheduling+0x60>
      if (t->state == RUNNABLE && t != scheduler_thread && t->priority > maxPriority)
 a14:	4398                	lw	a4,0(a5)
 a16:	fe9702e3          	beq	a4,s1,9fa <priorityScheduling+0x36>
      if (t->state == YIELD){
 a1a:	ff3719e3          	bne	a4,s3,a0c <priorityScheduling+0x48>
        t->state = RUNNABLE;
 a1e:	c384                	sw	s1,0(a5)
        alternativeIndex = t->tid;
 a20:	43d4                	lw	a3,4(a5)
 a22:	b7ed                	j	a0c <priorityScheduling+0x48>
    if (!threadAvailable)
 a24:	ed31                	bnez	a0,a80 <priorityScheduling+0xbc>
      if(alternativeIndex > 0){
 a26:	04d05f63          	blez	a3,a84 <priorityScheduling+0xc0>
      struct ulthread *temp = current_thread;
 a2a:	000abb83          	ld	s7,0(s5)
      current_thread = &ulthreads[threadIndex];
 a2e:	00469793          	slli	a5,a3,0x4
 a32:	00d78733          	add	a4,a5,a3
 a36:	070e                	slli	a4,a4,0x3
 a38:	00000617          	auipc	a2,0x0
 a3c:	5f860613          	addi	a2,a2,1528 # 1030 <ulthreads>
 a40:	9732                	add	a4,a4,a2
 a42:	00eab023          	sd	a4,0(s5)
      printf("[*] ultschedule (next tid: %d)\n", get_current_tid());
 a46:	434c                	lw	a1,4(a4)
 a48:	00000517          	auipc	a0,0x0
 a4c:	3c050513          	addi	a0,a0,960 # e08 <digits+0x18>
 a50:	00000097          	auipc	ra,0x0
 a54:	c34080e7          	jalr	-972(ra) # 684 <printf>
      ulthread_context_switch(&temp->context, &current_thread->context);
 a58:	000ab583          	ld	a1,0(s5)
 a5c:	05e1                	addi	a1,a1,24
 a5e:	018b8513          	addi	a0,s7,24
 a62:	00000097          	auipc	ra,0x0
 a66:	2a0080e7          	jalr	672(ra) # d02 <ulthread_context_switch>
      if (t->state == RUNNABLE && t != scheduler_thread && t->priority > maxPriority)
 a6a:	000b3583          	ld	a1,0(s6)
    int alternativeIndex = -1;
 a6e:	86d2                	mv	a3,s4
    int threadIndex = -1;
 a70:	8852                	mv	a6,s4
    int maxPriority = -1;
 a72:	8652                	mv	a2,s4
    bool threadAvailable = false;
 a74:	4501                	li	a0,0
    for (t = ulthreads+1; t < &ulthreads[MAXULTHREADS]; t++)
 a76:	00000797          	auipc	a5,0x0
 a7a:	64278793          	addi	a5,a5,1602 # 10b8 <ulthreads+0x88>
 a7e:	bf59                	j	a14 <priorityScheduling+0x50>
    label : 
 a80:	86c2                	mv	a3,a6
 a82:	b765                	j	a2a <priorityScheduling+0x66>
  }
}
 a84:	60a6                	ld	ra,72(sp)
 a86:	6406                	ld	s0,64(sp)
 a88:	74e2                	ld	s1,56(sp)
 a8a:	7942                	ld	s2,48(sp)
 a8c:	79a2                	ld	s3,40(sp)
 a8e:	7a02                	ld	s4,32(sp)
 a90:	6ae2                	ld	s5,24(sp)
 a92:	6b42                	ld	s6,16(sp)
 a94:	6ba2                	ld	s7,8(sp)
 a96:	6161                	addi	sp,sp,80
 a98:	8082                	ret

0000000000000a9a <ulthread_init>:

/* Thread initialization */
void ulthread_init(int schedalgo)
{
 a9a:	1141                	addi	sp,sp,-16
 a9c:	e422                	sd	s0,8(sp)
 a9e:	0800                	addi	s0,sp,16
  struct ulthread *t;
  int i;
  for (i = 0, t = ulthreads; t < &ulthreads[MAXULTHREADS]; t++, i++)
 aa0:	4701                	li	a4,0
 aa2:	00000797          	auipc	a5,0x0
 aa6:	58e78793          	addi	a5,a5,1422 # 1030 <ulthreads>
 aaa:	00004697          	auipc	a3,0x4
 aae:	aa668693          	addi	a3,a3,-1370 # 4550 <ulthreads+0x3520>
  {
    t->state = FREE;
 ab2:	0007a023          	sw	zero,0(a5)
    t->tid = i;
 ab6:	c3d8                	sw	a4,4(a5)
  for (i = 0, t = ulthreads; t < &ulthreads[MAXULTHREADS]; t++, i++)
 ab8:	08878793          	addi	a5,a5,136
 abc:	2705                	addiw	a4,a4,1
 abe:	fed79ae3          	bne	a5,a3,ab2 <ulthread_init+0x18>
  }
  current_thread = &ulthreads[0];
 ac2:	00000797          	auipc	a5,0x0
 ac6:	56e78793          	addi	a5,a5,1390 # 1030 <ulthreads>
 aca:	00000717          	auipc	a4,0x0
 ace:	54f73723          	sd	a5,1358(a4) # 1018 <current_thread>
  scheduler_thread = &ulthreads[0];
 ad2:	00000717          	auipc	a4,0x0
 ad6:	52f73f23          	sd	a5,1342(a4) # 1010 <scheduler_thread>
  scheduler_thread->state = RUNNABLE;
 ada:	4705                	li	a4,1
 adc:	c398                	sw	a4,0(a5)
  t->state = FREE;
 ade:	00004797          	auipc	a5,0x4
 ae2:	a607a923          	sw	zero,-1422(a5) # 4550 <ulthreads+0x3520>
  algorithm = schedalgo;
 ae6:	00000797          	auipc	a5,0x0
 aea:	52a7a123          	sw	a0,1314(a5) # 1008 <algorithm>
}
 aee:	6422                	ld	s0,8(sp)
 af0:	0141                	addi	sp,sp,16
 af2:	8082                	ret

0000000000000af4 <ulthread_create>:

/* Thread creation */
bool ulthread_create(uint64 start, uint64 stack, uint64 args[], int priority)
{
 af4:	7179                	addi	sp,sp,-48
 af6:	f406                	sd	ra,40(sp)
 af8:	f022                	sd	s0,32(sp)
 afa:	ec26                	sd	s1,24(sp)
 afc:	e84a                	sd	s2,16(sp)
 afe:	e44e                	sd	s3,8(sp)
 b00:	e052                	sd	s4,0(sp)
 b02:	1800                	addi	s0,sp,48
 b04:	89aa                	mv	s3,a0
 b06:	8a2e                	mv	s4,a1
 b08:	8932                	mv	s2,a2
  /* Please add thread-id instead of '0' here. */
  struct ulthread *t;
  bool flag = false;
  for (t = ulthreads; t < &ulthreads[MAXULTHREADS]; t++)
 b0a:	00000497          	auipc	s1,0x0
 b0e:	52648493          	addi	s1,s1,1318 # 1030 <ulthreads>
 b12:	00004717          	auipc	a4,0x4
 b16:	a3e70713          	addi	a4,a4,-1474 # 4550 <ulthreads+0x3520>
  {
    if (t->state == FREE)
 b1a:	409c                	lw	a5,0(s1)
 b1c:	cf89                	beqz	a5,b36 <ulthread_create+0x42>
  for (t = ulthreads; t < &ulthreads[MAXULTHREADS]; t++)
 b1e:	08848493          	addi	s1,s1,136
 b22:	fee49ce3          	bne	s1,a4,b1a <ulthread_create+0x26>
      break;
    }
  }
  if (!flag)
  {
    return false;
 b26:	4501                	li	a0,0
 b28:	a871                	j	bc4 <ulthread_create+0xd0>
  t->sp = (int)(stack + USTACKSIZE); // set sp to the top of the stack
  t->state = RUNNABLE;
  t->priority = priority;

  if(algorithm==FCFS){
    t->lastTime = ctime();
 b2a:	00000097          	auipc	ra,0x0
 b2e:	88a080e7          	jalr	-1910(ra) # 3b4 <ctime>
 b32:	e888                	sd	a0,16(s1)
 b34:	a839                	j	b52 <ulthread_create+0x5e>
  t->sp = (int)(stack + USTACKSIZE); // set sp to the top of the stack
 b36:	6785                	lui	a5,0x1
 b38:	014787bb          	addw	a5,a5,s4
 b3c:	c49c                	sw	a5,8(s1)
  t->state = RUNNABLE;
 b3e:	4785                	li	a5,1
 b40:	c09c                	sw	a5,0(s1)
  t->priority = priority;
 b42:	c4d4                	sw	a3,12(s1)
  if(algorithm==FCFS){
 b44:	00000717          	auipc	a4,0x0
 b48:	4c472703          	lw	a4,1220(a4) # 1008 <algorithm>
 b4c:	4789                	li	a5,2
 b4e:	fcf70ee3          	beq	a4,a5,b2a <ulthread_create+0x36>
  }

  for (int argc = 0; argc < 6; argc++)
 b52:	874a                	mv	a4,s2
 b54:	03090693          	addi	a3,s2,48
  {
    t->sp -= 16;
 b58:	449c                	lw	a5,8(s1)
 b5a:	37c1                	addiw	a5,a5,-16 # ff0 <digits+0x200>
 b5c:	0007881b          	sext.w	a6,a5
 b60:	c49c                	sw	a5,8(s1)
    *(uint64 *)(t->sp) = (uint64)args[argc];
 b62:	631c                	ld	a5,0(a4)
 b64:	00f83023          	sd	a5,0(a6)
  for (int argc = 0; argc < 6; argc++)
 b68:	0721                	addi	a4,a4,8
 b6a:	fed717e3          	bne	a4,a3,b58 <ulthread_create+0x64>
  }

  memset(&t->context, 0, sizeof(t->context));
 b6e:	07000613          	li	a2,112
 b72:	4581                	li	a1,0
 b74:	01848513          	addi	a0,s1,24
 b78:	fffff097          	auipc	ra,0xfffff
 b7c:	5a2080e7          	jalr	1442(ra) # 11a <memset>
  t->context.ra = start;
 b80:	0134bc23          	sd	s3,24(s1)
  t->context.sp = t->sp;
 b84:	449c                	lw	a5,8(s1)
 b86:	f09c                	sd	a5,32(s1)
  t->context.s0 = args[0];
 b88:	00093783          	ld	a5,0(s2)
 b8c:	f49c                	sd	a5,40(s1)
  t->context.s1 = args[1];
 b8e:	00893783          	ld	a5,8(s2)
 b92:	f89c                	sd	a5,48(s1)
  t->context.s2 = args[2];
 b94:	01093783          	ld	a5,16(s2)
 b98:	fc9c                	sd	a5,56(s1)
  t->context.s3 = args[3];
 b9a:	01893783          	ld	a5,24(s2)
 b9e:	e0bc                	sd	a5,64(s1)
  t->context.s4 = args[4];
 ba0:	02093783          	ld	a5,32(s2)
 ba4:	e4bc                	sd	a5,72(s1)
  t->context.s5 = args[5];
 ba6:	02893783          	ld	a5,40(s2)
 baa:	e8bc                	sd	a5,80(s1)

  printf("[*] ultcreate(tid: %d, ra: %p, sp: %p)\n", t->tid, start, stack);
 bac:	86d2                	mv	a3,s4
 bae:	864e                	mv	a2,s3
 bb0:	40cc                	lw	a1,4(s1)
 bb2:	00000517          	auipc	a0,0x0
 bb6:	2a650513          	addi	a0,a0,678 # e58 <digits+0x68>
 bba:	00000097          	auipc	ra,0x0
 bbe:	aca080e7          	jalr	-1334(ra) # 684 <printf>
  return true;
 bc2:	4505                	li	a0,1
}
 bc4:	70a2                	ld	ra,40(sp)
 bc6:	7402                	ld	s0,32(sp)
 bc8:	64e2                	ld	s1,24(sp)
 bca:	6942                	ld	s2,16(sp)
 bcc:	69a2                	ld	s3,8(sp)
 bce:	6a02                	ld	s4,0(sp)
 bd0:	6145                	addi	sp,sp,48
 bd2:	8082                	ret

0000000000000bd4 <ulthread_schedule>:

/* Thread scheduler */
void ulthread_schedule(void)
{
 bd4:	1141                	addi	sp,sp,-16
 bd6:	e406                	sd	ra,8(sp)
 bd8:	e022                	sd	s0,0(sp)
 bda:	0800                	addi	s0,sp,16
  switch (algorithm)
 bdc:	00000797          	auipc	a5,0x0
 be0:	42c7a783          	lw	a5,1068(a5) # 1008 <algorithm>
 be4:	4705                	li	a4,1
 be6:	02e78463          	beq	a5,a4,c0e <ulthread_schedule+0x3a>
 bea:	4709                	li	a4,2
 bec:	00e78c63          	beq	a5,a4,c04 <ulthread_schedule+0x30>
 bf0:	c789                	beqz	a5,bfa <ulthread_schedule+0x26>

  // Push argument strings, prepare rest of stack in ustack.

  // Switch between thread contexts
  // ulthread_context_switch(NULL, NULL);
}
 bf2:	60a2                	ld	ra,8(sp)
 bf4:	6402                	ld	s0,0(sp)
 bf6:	0141                	addi	sp,sp,16
 bf8:	8082                	ret
    roundRobin();
 bfa:	00000097          	auipc	ra,0x0
 bfe:	c3e080e7          	jalr	-962(ra) # 838 <roundRobin>
    break;
 c02:	bfc5                	j	bf2 <ulthread_schedule+0x1e>
    firstComeFirstServe();
 c04:	00000097          	auipc	ra,0x0
 c08:	ce2080e7          	jalr	-798(ra) # 8e6 <firstComeFirstServe>
    break;
 c0c:	b7dd                	j	bf2 <ulthread_schedule+0x1e>
    priorityScheduling();
 c0e:	00000097          	auipc	ra,0x0
 c12:	db6080e7          	jalr	-586(ra) # 9c4 <priorityScheduling>
}
 c16:	bff1                	j	bf2 <ulthread_schedule+0x1e>

0000000000000c18 <ulthread_yield>:

/* Yield CPU time to some other thread. */
void ulthread_yield(void)
{
 c18:	1101                	addi	sp,sp,-32
 c1a:	ec06                	sd	ra,24(sp)
 c1c:	e822                	sd	s0,16(sp)
 c1e:	e426                	sd	s1,8(sp)
 c20:	e04a                	sd	s2,0(sp)
 c22:	1000                	addi	s0,sp,32
  current_thread->state = YIELD;
 c24:	00000797          	auipc	a5,0x0
 c28:	3f478793          	addi	a5,a5,1012 # 1018 <current_thread>
 c2c:	6398                	ld	a4,0(a5)
 c2e:	4909                	li	s2,2
 c30:	01272023          	sw	s2,0(a4)
  struct ulthread *temp = current_thread;
 c34:	6384                	ld	s1,0(a5)
  printf("[*] ultyield(tid: %d)\n", current_thread->tid);
 c36:	40cc                	lw	a1,4(s1)
 c38:	00000517          	auipc	a0,0x0
 c3c:	24850513          	addi	a0,a0,584 # e80 <digits+0x90>
 c40:	00000097          	auipc	ra,0x0
 c44:	a44080e7          	jalr	-1468(ra) # 684 <printf>
  if(algorithm==FCFS){
 c48:	00000797          	auipc	a5,0x0
 c4c:	3c07a783          	lw	a5,960(a5) # 1008 <algorithm>
 c50:	03278763          	beq	a5,s2,c7e <ulthread_yield+0x66>
    current_thread->lastTime = ctime();
  }
  current_thread = scheduler_thread;
 c54:	00000597          	auipc	a1,0x0
 c58:	3bc5b583          	ld	a1,956(a1) # 1010 <scheduler_thread>
 c5c:	00000797          	auipc	a5,0x0
 c60:	3ab7be23          	sd	a1,956(a5) # 1018 <current_thread>
  
  ulthread_context_switch(&temp->context, &scheduler_thread->context);
 c64:	05e1                	addi	a1,a1,24
 c66:	01848513          	addi	a0,s1,24
 c6a:	00000097          	auipc	ra,0x0
 c6e:	098080e7          	jalr	152(ra) # d02 <ulthread_context_switch>
  // ulthread_schedule();
}
 c72:	60e2                	ld	ra,24(sp)
 c74:	6442                	ld	s0,16(sp)
 c76:	64a2                	ld	s1,8(sp)
 c78:	6902                	ld	s2,0(sp)
 c7a:	6105                	addi	sp,sp,32
 c7c:	8082                	ret
    current_thread->lastTime = ctime();
 c7e:	fffff097          	auipc	ra,0xfffff
 c82:	736080e7          	jalr	1846(ra) # 3b4 <ctime>
 c86:	00000797          	auipc	a5,0x0
 c8a:	3927b783          	ld	a5,914(a5) # 1018 <current_thread>
 c8e:	eb88                	sd	a0,16(a5)
 c90:	b7d1                	j	c54 <ulthread_yield+0x3c>

0000000000000c92 <ulthread_destroy>:

/* Destroy thread */
void ulthread_destroy(void)
{
 c92:	1101                	addi	sp,sp,-32
 c94:	ec06                	sd	ra,24(sp)
 c96:	e822                	sd	s0,16(sp)
 c98:	e426                	sd	s1,8(sp)
 c9a:	e04a                	sd	s2,0(sp)
 c9c:	1000                	addi	s0,sp,32
  memset(&current_thread->context, 0, sizeof(current_thread->context));
 c9e:	00000497          	auipc	s1,0x0
 ca2:	37a48493          	addi	s1,s1,890 # 1018 <current_thread>
 ca6:	6088                	ld	a0,0(s1)
 ca8:	07000613          	li	a2,112
 cac:	4581                	li	a1,0
 cae:	0561                	addi	a0,a0,24
 cb0:	fffff097          	auipc	ra,0xfffff
 cb4:	46a080e7          	jalr	1130(ra) # 11a <memset>
  current_thread->sp = 0;
 cb8:	609c                	ld	a5,0(s1)
 cba:	0007a423          	sw	zero,8(a5)
  current_thread->priority = -1;
 cbe:	577d                	li	a4,-1
 cc0:	c7d8                	sw	a4,12(a5)
  current_thread->state = FREE;
 cc2:	0007a023          	sw	zero,0(a5)

  struct ulthread *temp = current_thread;
 cc6:	0004b903          	ld	s2,0(s1)

  printf("[*] ultdestroy(tid: %d)\n", get_current_tid());
 cca:	00492583          	lw	a1,4(s2)
 cce:	00000517          	auipc	a0,0x0
 cd2:	1ca50513          	addi	a0,a0,458 # e98 <digits+0xa8>
 cd6:	00000097          	auipc	ra,0x0
 cda:	9ae080e7          	jalr	-1618(ra) # 684 <printf>
  current_thread = scheduler_thread;
 cde:	00000597          	auipc	a1,0x0
 ce2:	3325b583          	ld	a1,818(a1) # 1010 <scheduler_thread>
 ce6:	e08c                	sd	a1,0(s1)
  ulthread_context_switch(&temp->context, &scheduler_thread->context);
 ce8:	05e1                	addi	a1,a1,24
 cea:	01890513          	addi	a0,s2,24
 cee:	00000097          	auipc	ra,0x0
 cf2:	014080e7          	jalr	20(ra) # d02 <ulthread_context_switch>
}
 cf6:	60e2                	ld	ra,24(sp)
 cf8:	6442                	ld	s0,16(sp)
 cfa:	64a2                	ld	s1,8(sp)
 cfc:	6902                	ld	s2,0(sp)
 cfe:	6105                	addi	sp,sp,32
 d00:	8082                	ret

0000000000000d02 <ulthread_context_switch>:
 d02:	00153023          	sd	ra,0(a0)
 d06:	00253423          	sd	sp,8(a0)
 d0a:	e900                	sd	s0,16(a0)
 d0c:	ed04                	sd	s1,24(a0)
 d0e:	03253023          	sd	s2,32(a0)
 d12:	03353423          	sd	s3,40(a0)
 d16:	03453823          	sd	s4,48(a0)
 d1a:	03553c23          	sd	s5,56(a0)
 d1e:	05653023          	sd	s6,64(a0)
 d22:	05753423          	sd	s7,72(a0)
 d26:	05853823          	sd	s8,80(a0)
 d2a:	05953c23          	sd	s9,88(a0)
 d2e:	07a53023          	sd	s10,96(a0)
 d32:	07b53423          	sd	s11,104(a0)
 d36:	0005b083          	ld	ra,0(a1)
 d3a:	0085b103          	ld	sp,8(a1)
 d3e:	6980                	ld	s0,16(a1)
 d40:	6d84                	ld	s1,24(a1)
 d42:	0205b903          	ld	s2,32(a1)
 d46:	0285b983          	ld	s3,40(a1)
 d4a:	0305ba03          	ld	s4,48(a1)
 d4e:	0385ba83          	ld	s5,56(a1)
 d52:	0405bb03          	ld	s6,64(a1)
 d56:	0485bb83          	ld	s7,72(a1)
 d5a:	0505bc03          	ld	s8,80(a1)
 d5e:	0585bc83          	ld	s9,88(a1)
 d62:	0605bd03          	ld	s10,96(a1)
 d66:	0685bd83          	ld	s11,104(a1)
 d6a:	6546                	ld	a0,80(sp)
 d6c:	6586                	ld	a1,64(sp)
 d6e:	7642                	ld	a2,48(sp)
 d70:	7682                	ld	a3,32(sp)
 d72:	6742                	ld	a4,16(sp)
 d74:	6782                	ld	a5,0(sp)
 d76:	8082                	ret
