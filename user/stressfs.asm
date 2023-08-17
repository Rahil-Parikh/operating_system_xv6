
user/_stressfs:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "kernel/fs.h"
#include "kernel/fcntl.h"

int
main(int argc, char *argv[])
{
   0:	dd010113          	addi	sp,sp,-560
   4:	22113423          	sd	ra,552(sp)
   8:	22813023          	sd	s0,544(sp)
   c:	20913c23          	sd	s1,536(sp)
  10:	21213823          	sd	s2,528(sp)
  14:	1c00                	addi	s0,sp,560
  int fd, i;
  char path[] = "stressfs0";
  16:	00001797          	auipc	a5,0x1
  1a:	e1a78793          	addi	a5,a5,-486 # e30 <ulthread_context_switch+0xb0>
  1e:	6398                	ld	a4,0(a5)
  20:	fce43823          	sd	a4,-48(s0)
  24:	0087d783          	lhu	a5,8(a5)
  28:	fcf41c23          	sh	a5,-40(s0)
  char data[512];

  printf("stressfs starting\n");
  2c:	00001517          	auipc	a0,0x1
  30:	dd450513          	addi	a0,a0,-556 # e00 <ulthread_context_switch+0x80>
  34:	00000097          	auipc	ra,0x0
  38:	6ce080e7          	jalr	1742(ra) # 702 <printf>
  memset(data, 'a', sizeof(data));
  3c:	20000613          	li	a2,512
  40:	06100593          	li	a1,97
  44:	dd040513          	addi	a0,s0,-560
  48:	00000097          	auipc	ra,0x0
  4c:	150080e7          	jalr	336(ra) # 198 <memset>

  for(i = 0; i < 4; i++)
  50:	4481                	li	s1,0
  52:	4911                	li	s2,4
    if(fork() > 0)
  54:	00000097          	auipc	ra,0x0
  58:	336080e7          	jalr	822(ra) # 38a <fork>
  5c:	00a04563          	bgtz	a0,66 <main+0x66>
  for(i = 0; i < 4; i++)
  60:	2485                	addiw	s1,s1,1
  62:	ff2499e3          	bne	s1,s2,54 <main+0x54>
      break;

  printf("write %d\n", i);
  66:	85a6                	mv	a1,s1
  68:	00001517          	auipc	a0,0x1
  6c:	db050513          	addi	a0,a0,-592 # e18 <ulthread_context_switch+0x98>
  70:	00000097          	auipc	ra,0x0
  74:	692080e7          	jalr	1682(ra) # 702 <printf>

  path[8] += i;
  78:	fd844783          	lbu	a5,-40(s0)
  7c:	9fa5                	addw	a5,a5,s1
  7e:	fcf40c23          	sb	a5,-40(s0)
  fd = open(path, O_CREATE | O_RDWR);
  82:	20200593          	li	a1,514
  86:	fd040513          	addi	a0,s0,-48
  8a:	00000097          	auipc	ra,0x0
  8e:	348080e7          	jalr	840(ra) # 3d2 <open>
  92:	892a                	mv	s2,a0
  94:	44d1                	li	s1,20
  for(i = 0; i < 20; i++)
//    printf(fd, "%d\n", i);
    write(fd, data, sizeof(data));
  96:	20000613          	li	a2,512
  9a:	dd040593          	addi	a1,s0,-560
  9e:	854a                	mv	a0,s2
  a0:	00000097          	auipc	ra,0x0
  a4:	312080e7          	jalr	786(ra) # 3b2 <write>
  for(i = 0; i < 20; i++)
  a8:	34fd                	addiw	s1,s1,-1
  aa:	f4f5                	bnez	s1,96 <main+0x96>
  close(fd);
  ac:	854a                	mv	a0,s2
  ae:	00000097          	auipc	ra,0x0
  b2:	30c080e7          	jalr	780(ra) # 3ba <close>

  printf("read\n");
  b6:	00001517          	auipc	a0,0x1
  ba:	d7250513          	addi	a0,a0,-654 # e28 <ulthread_context_switch+0xa8>
  be:	00000097          	auipc	ra,0x0
  c2:	644080e7          	jalr	1604(ra) # 702 <printf>

  fd = open(path, O_RDONLY);
  c6:	4581                	li	a1,0
  c8:	fd040513          	addi	a0,s0,-48
  cc:	00000097          	auipc	ra,0x0
  d0:	306080e7          	jalr	774(ra) # 3d2 <open>
  d4:	892a                	mv	s2,a0
  d6:	44d1                	li	s1,20
  for (i = 0; i < 20; i++)
    read(fd, data, sizeof(data));
  d8:	20000613          	li	a2,512
  dc:	dd040593          	addi	a1,s0,-560
  e0:	854a                	mv	a0,s2
  e2:	00000097          	auipc	ra,0x0
  e6:	2c8080e7          	jalr	712(ra) # 3aa <read>
  for (i = 0; i < 20; i++)
  ea:	34fd                	addiw	s1,s1,-1
  ec:	f4f5                	bnez	s1,d8 <main+0xd8>
  close(fd);
  ee:	854a                	mv	a0,s2
  f0:	00000097          	auipc	ra,0x0
  f4:	2ca080e7          	jalr	714(ra) # 3ba <close>

  wait(0);
  f8:	4501                	li	a0,0
  fa:	00000097          	auipc	ra,0x0
  fe:	2a0080e7          	jalr	672(ra) # 39a <wait>

  exit(0);
 102:	4501                	li	a0,0
 104:	00000097          	auipc	ra,0x0
 108:	28e080e7          	jalr	654(ra) # 392 <exit>

000000000000010c <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
 10c:	1141                	addi	sp,sp,-16
 10e:	e406                	sd	ra,8(sp)
 110:	e022                	sd	s0,0(sp)
 112:	0800                	addi	s0,sp,16
  extern int main();
  main();
 114:	00000097          	auipc	ra,0x0
 118:	eec080e7          	jalr	-276(ra) # 0 <main>
  exit(0);
 11c:	4501                	li	a0,0
 11e:	00000097          	auipc	ra,0x0
 122:	274080e7          	jalr	628(ra) # 392 <exit>

0000000000000126 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 126:	1141                	addi	sp,sp,-16
 128:	e422                	sd	s0,8(sp)
 12a:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 12c:	87aa                	mv	a5,a0
 12e:	0585                	addi	a1,a1,1
 130:	0785                	addi	a5,a5,1
 132:	fff5c703          	lbu	a4,-1(a1)
 136:	fee78fa3          	sb	a4,-1(a5)
 13a:	fb75                	bnez	a4,12e <strcpy+0x8>
    ;
  return os;
}
 13c:	6422                	ld	s0,8(sp)
 13e:	0141                	addi	sp,sp,16
 140:	8082                	ret

0000000000000142 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 142:	1141                	addi	sp,sp,-16
 144:	e422                	sd	s0,8(sp)
 146:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 148:	00054783          	lbu	a5,0(a0)
 14c:	cb91                	beqz	a5,160 <strcmp+0x1e>
 14e:	0005c703          	lbu	a4,0(a1)
 152:	00f71763          	bne	a4,a5,160 <strcmp+0x1e>
    p++, q++;
 156:	0505                	addi	a0,a0,1
 158:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 15a:	00054783          	lbu	a5,0(a0)
 15e:	fbe5                	bnez	a5,14e <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 160:	0005c503          	lbu	a0,0(a1)
}
 164:	40a7853b          	subw	a0,a5,a0
 168:	6422                	ld	s0,8(sp)
 16a:	0141                	addi	sp,sp,16
 16c:	8082                	ret

000000000000016e <strlen>:

uint
strlen(const char *s)
{
 16e:	1141                	addi	sp,sp,-16
 170:	e422                	sd	s0,8(sp)
 172:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 174:	00054783          	lbu	a5,0(a0)
 178:	cf91                	beqz	a5,194 <strlen+0x26>
 17a:	0505                	addi	a0,a0,1
 17c:	87aa                	mv	a5,a0
 17e:	86be                	mv	a3,a5
 180:	0785                	addi	a5,a5,1
 182:	fff7c703          	lbu	a4,-1(a5)
 186:	ff65                	bnez	a4,17e <strlen+0x10>
 188:	40a6853b          	subw	a0,a3,a0
 18c:	2505                	addiw	a0,a0,1
    ;
  return n;
}
 18e:	6422                	ld	s0,8(sp)
 190:	0141                	addi	sp,sp,16
 192:	8082                	ret
  for(n = 0; s[n]; n++)
 194:	4501                	li	a0,0
 196:	bfe5                	j	18e <strlen+0x20>

0000000000000198 <memset>:

void*
memset(void *dst, int c, uint n)
{
 198:	1141                	addi	sp,sp,-16
 19a:	e422                	sd	s0,8(sp)
 19c:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 19e:	ca19                	beqz	a2,1b4 <memset+0x1c>
 1a0:	87aa                	mv	a5,a0
 1a2:	1602                	slli	a2,a2,0x20
 1a4:	9201                	srli	a2,a2,0x20
 1a6:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 1aa:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 1ae:	0785                	addi	a5,a5,1
 1b0:	fee79de3          	bne	a5,a4,1aa <memset+0x12>
  }
  return dst;
}
 1b4:	6422                	ld	s0,8(sp)
 1b6:	0141                	addi	sp,sp,16
 1b8:	8082                	ret

00000000000001ba <strchr>:

char*
strchr(const char *s, char c)
{
 1ba:	1141                	addi	sp,sp,-16
 1bc:	e422                	sd	s0,8(sp)
 1be:	0800                	addi	s0,sp,16
  for(; *s; s++)
 1c0:	00054783          	lbu	a5,0(a0)
 1c4:	cb99                	beqz	a5,1da <strchr+0x20>
    if(*s == c)
 1c6:	00f58763          	beq	a1,a5,1d4 <strchr+0x1a>
  for(; *s; s++)
 1ca:	0505                	addi	a0,a0,1
 1cc:	00054783          	lbu	a5,0(a0)
 1d0:	fbfd                	bnez	a5,1c6 <strchr+0xc>
      return (char*)s;
  return 0;
 1d2:	4501                	li	a0,0
}
 1d4:	6422                	ld	s0,8(sp)
 1d6:	0141                	addi	sp,sp,16
 1d8:	8082                	ret
  return 0;
 1da:	4501                	li	a0,0
 1dc:	bfe5                	j	1d4 <strchr+0x1a>

00000000000001de <gets>:

char*
gets(char *buf, int max)
{
 1de:	711d                	addi	sp,sp,-96
 1e0:	ec86                	sd	ra,88(sp)
 1e2:	e8a2                	sd	s0,80(sp)
 1e4:	e4a6                	sd	s1,72(sp)
 1e6:	e0ca                	sd	s2,64(sp)
 1e8:	fc4e                	sd	s3,56(sp)
 1ea:	f852                	sd	s4,48(sp)
 1ec:	f456                	sd	s5,40(sp)
 1ee:	f05a                	sd	s6,32(sp)
 1f0:	ec5e                	sd	s7,24(sp)
 1f2:	1080                	addi	s0,sp,96
 1f4:	8baa                	mv	s7,a0
 1f6:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1f8:	892a                	mv	s2,a0
 1fa:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 1fc:	4aa9                	li	s5,10
 1fe:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 200:	89a6                	mv	s3,s1
 202:	2485                	addiw	s1,s1,1
 204:	0344d863          	bge	s1,s4,234 <gets+0x56>
    cc = read(0, &c, 1);
 208:	4605                	li	a2,1
 20a:	faf40593          	addi	a1,s0,-81
 20e:	4501                	li	a0,0
 210:	00000097          	auipc	ra,0x0
 214:	19a080e7          	jalr	410(ra) # 3aa <read>
    if(cc < 1)
 218:	00a05e63          	blez	a0,234 <gets+0x56>
    buf[i++] = c;
 21c:	faf44783          	lbu	a5,-81(s0)
 220:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 224:	01578763          	beq	a5,s5,232 <gets+0x54>
 228:	0905                	addi	s2,s2,1
 22a:	fd679be3          	bne	a5,s6,200 <gets+0x22>
  for(i=0; i+1 < max; ){
 22e:	89a6                	mv	s3,s1
 230:	a011                	j	234 <gets+0x56>
 232:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 234:	99de                	add	s3,s3,s7
 236:	00098023          	sb	zero,0(s3)
  return buf;
}
 23a:	855e                	mv	a0,s7
 23c:	60e6                	ld	ra,88(sp)
 23e:	6446                	ld	s0,80(sp)
 240:	64a6                	ld	s1,72(sp)
 242:	6906                	ld	s2,64(sp)
 244:	79e2                	ld	s3,56(sp)
 246:	7a42                	ld	s4,48(sp)
 248:	7aa2                	ld	s5,40(sp)
 24a:	7b02                	ld	s6,32(sp)
 24c:	6be2                	ld	s7,24(sp)
 24e:	6125                	addi	sp,sp,96
 250:	8082                	ret

0000000000000252 <stat>:

int
stat(const char *n, struct stat *st)
{
 252:	1101                	addi	sp,sp,-32
 254:	ec06                	sd	ra,24(sp)
 256:	e822                	sd	s0,16(sp)
 258:	e426                	sd	s1,8(sp)
 25a:	e04a                	sd	s2,0(sp)
 25c:	1000                	addi	s0,sp,32
 25e:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 260:	4581                	li	a1,0
 262:	00000097          	auipc	ra,0x0
 266:	170080e7          	jalr	368(ra) # 3d2 <open>
  if(fd < 0)
 26a:	02054563          	bltz	a0,294 <stat+0x42>
 26e:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 270:	85ca                	mv	a1,s2
 272:	00000097          	auipc	ra,0x0
 276:	178080e7          	jalr	376(ra) # 3ea <fstat>
 27a:	892a                	mv	s2,a0
  close(fd);
 27c:	8526                	mv	a0,s1
 27e:	00000097          	auipc	ra,0x0
 282:	13c080e7          	jalr	316(ra) # 3ba <close>
  return r;
}
 286:	854a                	mv	a0,s2
 288:	60e2                	ld	ra,24(sp)
 28a:	6442                	ld	s0,16(sp)
 28c:	64a2                	ld	s1,8(sp)
 28e:	6902                	ld	s2,0(sp)
 290:	6105                	addi	sp,sp,32
 292:	8082                	ret
    return -1;
 294:	597d                	li	s2,-1
 296:	bfc5                	j	286 <stat+0x34>

0000000000000298 <atoi>:

int
atoi(const char *s)
{
 298:	1141                	addi	sp,sp,-16
 29a:	e422                	sd	s0,8(sp)
 29c:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 29e:	00054683          	lbu	a3,0(a0)
 2a2:	fd06879b          	addiw	a5,a3,-48
 2a6:	0ff7f793          	zext.b	a5,a5
 2aa:	4625                	li	a2,9
 2ac:	02f66863          	bltu	a2,a5,2dc <atoi+0x44>
 2b0:	872a                	mv	a4,a0
  n = 0;
 2b2:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 2b4:	0705                	addi	a4,a4,1
 2b6:	0025179b          	slliw	a5,a0,0x2
 2ba:	9fa9                	addw	a5,a5,a0
 2bc:	0017979b          	slliw	a5,a5,0x1
 2c0:	9fb5                	addw	a5,a5,a3
 2c2:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 2c6:	00074683          	lbu	a3,0(a4)
 2ca:	fd06879b          	addiw	a5,a3,-48
 2ce:	0ff7f793          	zext.b	a5,a5
 2d2:	fef671e3          	bgeu	a2,a5,2b4 <atoi+0x1c>
  return n;
}
 2d6:	6422                	ld	s0,8(sp)
 2d8:	0141                	addi	sp,sp,16
 2da:	8082                	ret
  n = 0;
 2dc:	4501                	li	a0,0
 2de:	bfe5                	j	2d6 <atoi+0x3e>

00000000000002e0 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 2e0:	1141                	addi	sp,sp,-16
 2e2:	e422                	sd	s0,8(sp)
 2e4:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 2e6:	02b57463          	bgeu	a0,a1,30e <memmove+0x2e>
    while(n-- > 0)
 2ea:	00c05f63          	blez	a2,308 <memmove+0x28>
 2ee:	1602                	slli	a2,a2,0x20
 2f0:	9201                	srli	a2,a2,0x20
 2f2:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 2f6:	872a                	mv	a4,a0
      *dst++ = *src++;
 2f8:	0585                	addi	a1,a1,1
 2fa:	0705                	addi	a4,a4,1
 2fc:	fff5c683          	lbu	a3,-1(a1)
 300:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 304:	fee79ae3          	bne	a5,a4,2f8 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 308:	6422                	ld	s0,8(sp)
 30a:	0141                	addi	sp,sp,16
 30c:	8082                	ret
    dst += n;
 30e:	00c50733          	add	a4,a0,a2
    src += n;
 312:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 314:	fec05ae3          	blez	a2,308 <memmove+0x28>
 318:	fff6079b          	addiw	a5,a2,-1
 31c:	1782                	slli	a5,a5,0x20
 31e:	9381                	srli	a5,a5,0x20
 320:	fff7c793          	not	a5,a5
 324:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 326:	15fd                	addi	a1,a1,-1
 328:	177d                	addi	a4,a4,-1
 32a:	0005c683          	lbu	a3,0(a1)
 32e:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 332:	fee79ae3          	bne	a5,a4,326 <memmove+0x46>
 336:	bfc9                	j	308 <memmove+0x28>

0000000000000338 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 338:	1141                	addi	sp,sp,-16
 33a:	e422                	sd	s0,8(sp)
 33c:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 33e:	ca05                	beqz	a2,36e <memcmp+0x36>
 340:	fff6069b          	addiw	a3,a2,-1
 344:	1682                	slli	a3,a3,0x20
 346:	9281                	srli	a3,a3,0x20
 348:	0685                	addi	a3,a3,1
 34a:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 34c:	00054783          	lbu	a5,0(a0)
 350:	0005c703          	lbu	a4,0(a1)
 354:	00e79863          	bne	a5,a4,364 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 358:	0505                	addi	a0,a0,1
    p2++;
 35a:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 35c:	fed518e3          	bne	a0,a3,34c <memcmp+0x14>
  }
  return 0;
 360:	4501                	li	a0,0
 362:	a019                	j	368 <memcmp+0x30>
      return *p1 - *p2;
 364:	40e7853b          	subw	a0,a5,a4
}
 368:	6422                	ld	s0,8(sp)
 36a:	0141                	addi	sp,sp,16
 36c:	8082                	ret
  return 0;
 36e:	4501                	li	a0,0
 370:	bfe5                	j	368 <memcmp+0x30>

0000000000000372 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 372:	1141                	addi	sp,sp,-16
 374:	e406                	sd	ra,8(sp)
 376:	e022                	sd	s0,0(sp)
 378:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 37a:	00000097          	auipc	ra,0x0
 37e:	f66080e7          	jalr	-154(ra) # 2e0 <memmove>
}
 382:	60a2                	ld	ra,8(sp)
 384:	6402                	ld	s0,0(sp)
 386:	0141                	addi	sp,sp,16
 388:	8082                	ret

000000000000038a <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 38a:	4885                	li	a7,1
 ecall
 38c:	00000073          	ecall
 ret
 390:	8082                	ret

0000000000000392 <exit>:
.global exit
exit:
 li a7, SYS_exit
 392:	4889                	li	a7,2
 ecall
 394:	00000073          	ecall
 ret
 398:	8082                	ret

000000000000039a <wait>:
.global wait
wait:
 li a7, SYS_wait
 39a:	488d                	li	a7,3
 ecall
 39c:	00000073          	ecall
 ret
 3a0:	8082                	ret

00000000000003a2 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 3a2:	4891                	li	a7,4
 ecall
 3a4:	00000073          	ecall
 ret
 3a8:	8082                	ret

00000000000003aa <read>:
.global read
read:
 li a7, SYS_read
 3aa:	4895                	li	a7,5
 ecall
 3ac:	00000073          	ecall
 ret
 3b0:	8082                	ret

00000000000003b2 <write>:
.global write
write:
 li a7, SYS_write
 3b2:	48c1                	li	a7,16
 ecall
 3b4:	00000073          	ecall
 ret
 3b8:	8082                	ret

00000000000003ba <close>:
.global close
close:
 li a7, SYS_close
 3ba:	48d5                	li	a7,21
 ecall
 3bc:	00000073          	ecall
 ret
 3c0:	8082                	ret

00000000000003c2 <kill>:
.global kill
kill:
 li a7, SYS_kill
 3c2:	4899                	li	a7,6
 ecall
 3c4:	00000073          	ecall
 ret
 3c8:	8082                	ret

00000000000003ca <exec>:
.global exec
exec:
 li a7, SYS_exec
 3ca:	489d                	li	a7,7
 ecall
 3cc:	00000073          	ecall
 ret
 3d0:	8082                	ret

00000000000003d2 <open>:
.global open
open:
 li a7, SYS_open
 3d2:	48bd                	li	a7,15
 ecall
 3d4:	00000073          	ecall
 ret
 3d8:	8082                	ret

00000000000003da <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 3da:	48c5                	li	a7,17
 ecall
 3dc:	00000073          	ecall
 ret
 3e0:	8082                	ret

00000000000003e2 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 3e2:	48c9                	li	a7,18
 ecall
 3e4:	00000073          	ecall
 ret
 3e8:	8082                	ret

00000000000003ea <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 3ea:	48a1                	li	a7,8
 ecall
 3ec:	00000073          	ecall
 ret
 3f0:	8082                	ret

00000000000003f2 <link>:
.global link
link:
 li a7, SYS_link
 3f2:	48cd                	li	a7,19
 ecall
 3f4:	00000073          	ecall
 ret
 3f8:	8082                	ret

00000000000003fa <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 3fa:	48d1                	li	a7,20
 ecall
 3fc:	00000073          	ecall
 ret
 400:	8082                	ret

0000000000000402 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 402:	48a5                	li	a7,9
 ecall
 404:	00000073          	ecall
 ret
 408:	8082                	ret

000000000000040a <dup>:
.global dup
dup:
 li a7, SYS_dup
 40a:	48a9                	li	a7,10
 ecall
 40c:	00000073          	ecall
 ret
 410:	8082                	ret

0000000000000412 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 412:	48ad                	li	a7,11
 ecall
 414:	00000073          	ecall
 ret
 418:	8082                	ret

000000000000041a <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 41a:	48b1                	li	a7,12
 ecall
 41c:	00000073          	ecall
 ret
 420:	8082                	ret

0000000000000422 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 422:	48b5                	li	a7,13
 ecall
 424:	00000073          	ecall
 ret
 428:	8082                	ret

000000000000042a <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 42a:	48b9                	li	a7,14
 ecall
 42c:	00000073          	ecall
 ret
 430:	8082                	ret

0000000000000432 <ctime>:
.global ctime
ctime:
 li a7, SYS_ctime
 432:	48d9                	li	a7,22
 ecall
 434:	00000073          	ecall
 ret
 438:	8082                	ret

000000000000043a <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 43a:	1101                	addi	sp,sp,-32
 43c:	ec06                	sd	ra,24(sp)
 43e:	e822                	sd	s0,16(sp)
 440:	1000                	addi	s0,sp,32
 442:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 446:	4605                	li	a2,1
 448:	fef40593          	addi	a1,s0,-17
 44c:	00000097          	auipc	ra,0x0
 450:	f66080e7          	jalr	-154(ra) # 3b2 <write>
}
 454:	60e2                	ld	ra,24(sp)
 456:	6442                	ld	s0,16(sp)
 458:	6105                	addi	sp,sp,32
 45a:	8082                	ret

000000000000045c <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 45c:	7139                	addi	sp,sp,-64
 45e:	fc06                	sd	ra,56(sp)
 460:	f822                	sd	s0,48(sp)
 462:	f426                	sd	s1,40(sp)
 464:	f04a                	sd	s2,32(sp)
 466:	ec4e                	sd	s3,24(sp)
 468:	0080                	addi	s0,sp,64
 46a:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 46c:	c299                	beqz	a3,472 <printint+0x16>
 46e:	0805c963          	bltz	a1,500 <printint+0xa4>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 472:	2581                	sext.w	a1,a1
  neg = 0;
 474:	4881                	li	a7,0
 476:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 47a:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 47c:	2601                	sext.w	a2,a2
 47e:	00001517          	auipc	a0,0x1
 482:	a2250513          	addi	a0,a0,-1502 # ea0 <digits>
 486:	883a                	mv	a6,a4
 488:	2705                	addiw	a4,a4,1
 48a:	02c5f7bb          	remuw	a5,a1,a2
 48e:	1782                	slli	a5,a5,0x20
 490:	9381                	srli	a5,a5,0x20
 492:	97aa                	add	a5,a5,a0
 494:	0007c783          	lbu	a5,0(a5)
 498:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 49c:	0005879b          	sext.w	a5,a1
 4a0:	02c5d5bb          	divuw	a1,a1,a2
 4a4:	0685                	addi	a3,a3,1
 4a6:	fec7f0e3          	bgeu	a5,a2,486 <printint+0x2a>
  if(neg)
 4aa:	00088c63          	beqz	a7,4c2 <printint+0x66>
    buf[i++] = '-';
 4ae:	fd070793          	addi	a5,a4,-48
 4b2:	00878733          	add	a4,a5,s0
 4b6:	02d00793          	li	a5,45
 4ba:	fef70823          	sb	a5,-16(a4)
 4be:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 4c2:	02e05863          	blez	a4,4f2 <printint+0x96>
 4c6:	fc040793          	addi	a5,s0,-64
 4ca:	00e78933          	add	s2,a5,a4
 4ce:	fff78993          	addi	s3,a5,-1
 4d2:	99ba                	add	s3,s3,a4
 4d4:	377d                	addiw	a4,a4,-1
 4d6:	1702                	slli	a4,a4,0x20
 4d8:	9301                	srli	a4,a4,0x20
 4da:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 4de:	fff94583          	lbu	a1,-1(s2)
 4e2:	8526                	mv	a0,s1
 4e4:	00000097          	auipc	ra,0x0
 4e8:	f56080e7          	jalr	-170(ra) # 43a <putc>
  while(--i >= 0)
 4ec:	197d                	addi	s2,s2,-1
 4ee:	ff3918e3          	bne	s2,s3,4de <printint+0x82>
}
 4f2:	70e2                	ld	ra,56(sp)
 4f4:	7442                	ld	s0,48(sp)
 4f6:	74a2                	ld	s1,40(sp)
 4f8:	7902                	ld	s2,32(sp)
 4fa:	69e2                	ld	s3,24(sp)
 4fc:	6121                	addi	sp,sp,64
 4fe:	8082                	ret
    x = -xx;
 500:	40b005bb          	negw	a1,a1
    neg = 1;
 504:	4885                	li	a7,1
    x = -xx;
 506:	bf85                	j	476 <printint+0x1a>

0000000000000508 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 508:	715d                	addi	sp,sp,-80
 50a:	e486                	sd	ra,72(sp)
 50c:	e0a2                	sd	s0,64(sp)
 50e:	fc26                	sd	s1,56(sp)
 510:	f84a                	sd	s2,48(sp)
 512:	f44e                	sd	s3,40(sp)
 514:	f052                	sd	s4,32(sp)
 516:	ec56                	sd	s5,24(sp)
 518:	e85a                	sd	s6,16(sp)
 51a:	e45e                	sd	s7,8(sp)
 51c:	e062                	sd	s8,0(sp)
 51e:	0880                	addi	s0,sp,80
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 520:	0005c903          	lbu	s2,0(a1)
 524:	18090c63          	beqz	s2,6bc <vprintf+0x1b4>
 528:	8aaa                	mv	s5,a0
 52a:	8bb2                	mv	s7,a2
 52c:	00158493          	addi	s1,a1,1
  state = 0;
 530:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 532:	02500a13          	li	s4,37
 536:	4b55                	li	s6,21
 538:	a839                	j	556 <vprintf+0x4e>
        putc(fd, c);
 53a:	85ca                	mv	a1,s2
 53c:	8556                	mv	a0,s5
 53e:	00000097          	auipc	ra,0x0
 542:	efc080e7          	jalr	-260(ra) # 43a <putc>
 546:	a019                	j	54c <vprintf+0x44>
    } else if(state == '%'){
 548:	01498d63          	beq	s3,s4,562 <vprintf+0x5a>
  for(i = 0; fmt[i]; i++){
 54c:	0485                	addi	s1,s1,1
 54e:	fff4c903          	lbu	s2,-1(s1)
 552:	16090563          	beqz	s2,6bc <vprintf+0x1b4>
    if(state == 0){
 556:	fe0999e3          	bnez	s3,548 <vprintf+0x40>
      if(c == '%'){
 55a:	ff4910e3          	bne	s2,s4,53a <vprintf+0x32>
        state = '%';
 55e:	89d2                	mv	s3,s4
 560:	b7f5                	j	54c <vprintf+0x44>
      if(c == 'd'){
 562:	13490263          	beq	s2,s4,686 <vprintf+0x17e>
 566:	f9d9079b          	addiw	a5,s2,-99
 56a:	0ff7f793          	zext.b	a5,a5
 56e:	12fb6563          	bltu	s6,a5,698 <vprintf+0x190>
 572:	f9d9079b          	addiw	a5,s2,-99
 576:	0ff7f713          	zext.b	a4,a5
 57a:	10eb6f63          	bltu	s6,a4,698 <vprintf+0x190>
 57e:	00271793          	slli	a5,a4,0x2
 582:	00001717          	auipc	a4,0x1
 586:	8c670713          	addi	a4,a4,-1850 # e48 <ulthread_context_switch+0xc8>
 58a:	97ba                	add	a5,a5,a4
 58c:	439c                	lw	a5,0(a5)
 58e:	97ba                	add	a5,a5,a4
 590:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
 592:	008b8913          	addi	s2,s7,8
 596:	4685                	li	a3,1
 598:	4629                	li	a2,10
 59a:	000ba583          	lw	a1,0(s7)
 59e:	8556                	mv	a0,s5
 5a0:	00000097          	auipc	ra,0x0
 5a4:	ebc080e7          	jalr	-324(ra) # 45c <printint>
 5a8:	8bca                	mv	s7,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 5aa:	4981                	li	s3,0
 5ac:	b745                	j	54c <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 5ae:	008b8913          	addi	s2,s7,8
 5b2:	4681                	li	a3,0
 5b4:	4629                	li	a2,10
 5b6:	000ba583          	lw	a1,0(s7)
 5ba:	8556                	mv	a0,s5
 5bc:	00000097          	auipc	ra,0x0
 5c0:	ea0080e7          	jalr	-352(ra) # 45c <printint>
 5c4:	8bca                	mv	s7,s2
      state = 0;
 5c6:	4981                	li	s3,0
 5c8:	b751                	j	54c <vprintf+0x44>
        printint(fd, va_arg(ap, int), 16, 0);
 5ca:	008b8913          	addi	s2,s7,8
 5ce:	4681                	li	a3,0
 5d0:	4641                	li	a2,16
 5d2:	000ba583          	lw	a1,0(s7)
 5d6:	8556                	mv	a0,s5
 5d8:	00000097          	auipc	ra,0x0
 5dc:	e84080e7          	jalr	-380(ra) # 45c <printint>
 5e0:	8bca                	mv	s7,s2
      state = 0;
 5e2:	4981                	li	s3,0
 5e4:	b7a5                	j	54c <vprintf+0x44>
        printptr(fd, va_arg(ap, uint64));
 5e6:	008b8c13          	addi	s8,s7,8
 5ea:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 5ee:	03000593          	li	a1,48
 5f2:	8556                	mv	a0,s5
 5f4:	00000097          	auipc	ra,0x0
 5f8:	e46080e7          	jalr	-442(ra) # 43a <putc>
  putc(fd, 'x');
 5fc:	07800593          	li	a1,120
 600:	8556                	mv	a0,s5
 602:	00000097          	auipc	ra,0x0
 606:	e38080e7          	jalr	-456(ra) # 43a <putc>
 60a:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 60c:	00001b97          	auipc	s7,0x1
 610:	894b8b93          	addi	s7,s7,-1900 # ea0 <digits>
 614:	03c9d793          	srli	a5,s3,0x3c
 618:	97de                	add	a5,a5,s7
 61a:	0007c583          	lbu	a1,0(a5)
 61e:	8556                	mv	a0,s5
 620:	00000097          	auipc	ra,0x0
 624:	e1a080e7          	jalr	-486(ra) # 43a <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 628:	0992                	slli	s3,s3,0x4
 62a:	397d                	addiw	s2,s2,-1
 62c:	fe0914e3          	bnez	s2,614 <vprintf+0x10c>
        printptr(fd, va_arg(ap, uint64));
 630:	8be2                	mv	s7,s8
      state = 0;
 632:	4981                	li	s3,0
 634:	bf21                	j	54c <vprintf+0x44>
        s = va_arg(ap, char*);
 636:	008b8993          	addi	s3,s7,8
 63a:	000bb903          	ld	s2,0(s7)
        if(s == 0)
 63e:	02090163          	beqz	s2,660 <vprintf+0x158>
        while(*s != 0){
 642:	00094583          	lbu	a1,0(s2)
 646:	c9a5                	beqz	a1,6b6 <vprintf+0x1ae>
          putc(fd, *s);
 648:	8556                	mv	a0,s5
 64a:	00000097          	auipc	ra,0x0
 64e:	df0080e7          	jalr	-528(ra) # 43a <putc>
          s++;
 652:	0905                	addi	s2,s2,1
        while(*s != 0){
 654:	00094583          	lbu	a1,0(s2)
 658:	f9e5                	bnez	a1,648 <vprintf+0x140>
        s = va_arg(ap, char*);
 65a:	8bce                	mv	s7,s3
      state = 0;
 65c:	4981                	li	s3,0
 65e:	b5fd                	j	54c <vprintf+0x44>
          s = "(null)";
 660:	00000917          	auipc	s2,0x0
 664:	7e090913          	addi	s2,s2,2016 # e40 <ulthread_context_switch+0xc0>
        while(*s != 0){
 668:	02800593          	li	a1,40
 66c:	bff1                	j	648 <vprintf+0x140>
        putc(fd, va_arg(ap, uint));
 66e:	008b8913          	addi	s2,s7,8
 672:	000bc583          	lbu	a1,0(s7)
 676:	8556                	mv	a0,s5
 678:	00000097          	auipc	ra,0x0
 67c:	dc2080e7          	jalr	-574(ra) # 43a <putc>
 680:	8bca                	mv	s7,s2
      state = 0;
 682:	4981                	li	s3,0
 684:	b5e1                	j	54c <vprintf+0x44>
        putc(fd, c);
 686:	02500593          	li	a1,37
 68a:	8556                	mv	a0,s5
 68c:	00000097          	auipc	ra,0x0
 690:	dae080e7          	jalr	-594(ra) # 43a <putc>
      state = 0;
 694:	4981                	li	s3,0
 696:	bd5d                	j	54c <vprintf+0x44>
        putc(fd, '%');
 698:	02500593          	li	a1,37
 69c:	8556                	mv	a0,s5
 69e:	00000097          	auipc	ra,0x0
 6a2:	d9c080e7          	jalr	-612(ra) # 43a <putc>
        putc(fd, c);
 6a6:	85ca                	mv	a1,s2
 6a8:	8556                	mv	a0,s5
 6aa:	00000097          	auipc	ra,0x0
 6ae:	d90080e7          	jalr	-624(ra) # 43a <putc>
      state = 0;
 6b2:	4981                	li	s3,0
 6b4:	bd61                	j	54c <vprintf+0x44>
        s = va_arg(ap, char*);
 6b6:	8bce                	mv	s7,s3
      state = 0;
 6b8:	4981                	li	s3,0
 6ba:	bd49                	j	54c <vprintf+0x44>
    }
  }
}
 6bc:	60a6                	ld	ra,72(sp)
 6be:	6406                	ld	s0,64(sp)
 6c0:	74e2                	ld	s1,56(sp)
 6c2:	7942                	ld	s2,48(sp)
 6c4:	79a2                	ld	s3,40(sp)
 6c6:	7a02                	ld	s4,32(sp)
 6c8:	6ae2                	ld	s5,24(sp)
 6ca:	6b42                	ld	s6,16(sp)
 6cc:	6ba2                	ld	s7,8(sp)
 6ce:	6c02                	ld	s8,0(sp)
 6d0:	6161                	addi	sp,sp,80
 6d2:	8082                	ret

00000000000006d4 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 6d4:	715d                	addi	sp,sp,-80
 6d6:	ec06                	sd	ra,24(sp)
 6d8:	e822                	sd	s0,16(sp)
 6da:	1000                	addi	s0,sp,32
 6dc:	e010                	sd	a2,0(s0)
 6de:	e414                	sd	a3,8(s0)
 6e0:	e818                	sd	a4,16(s0)
 6e2:	ec1c                	sd	a5,24(s0)
 6e4:	03043023          	sd	a6,32(s0)
 6e8:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 6ec:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 6f0:	8622                	mv	a2,s0
 6f2:	00000097          	auipc	ra,0x0
 6f6:	e16080e7          	jalr	-490(ra) # 508 <vprintf>
}
 6fa:	60e2                	ld	ra,24(sp)
 6fc:	6442                	ld	s0,16(sp)
 6fe:	6161                	addi	sp,sp,80
 700:	8082                	ret

0000000000000702 <printf>:

void
printf(const char *fmt, ...)
{
 702:	711d                	addi	sp,sp,-96
 704:	ec06                	sd	ra,24(sp)
 706:	e822                	sd	s0,16(sp)
 708:	1000                	addi	s0,sp,32
 70a:	e40c                	sd	a1,8(s0)
 70c:	e810                	sd	a2,16(s0)
 70e:	ec14                	sd	a3,24(s0)
 710:	f018                	sd	a4,32(s0)
 712:	f41c                	sd	a5,40(s0)
 714:	03043823          	sd	a6,48(s0)
 718:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 71c:	00840613          	addi	a2,s0,8
 720:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 724:	85aa                	mv	a1,a0
 726:	4505                	li	a0,1
 728:	00000097          	auipc	ra,0x0
 72c:	de0080e7          	jalr	-544(ra) # 508 <vprintf>
}
 730:	60e2                	ld	ra,24(sp)
 732:	6442                	ld	s0,16(sp)
 734:	6125                	addi	sp,sp,96
 736:	8082                	ret

0000000000000738 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 738:	1141                	addi	sp,sp,-16
 73a:	e422                	sd	s0,8(sp)
 73c:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 73e:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 742:	00001797          	auipc	a5,0x1
 746:	8be7b783          	ld	a5,-1858(a5) # 1000 <freep>
 74a:	a02d                	j	774 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 74c:	4618                	lw	a4,8(a2)
 74e:	9f2d                	addw	a4,a4,a1
 750:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 754:	6398                	ld	a4,0(a5)
 756:	6310                	ld	a2,0(a4)
 758:	a83d                	j	796 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 75a:	ff852703          	lw	a4,-8(a0)
 75e:	9f31                	addw	a4,a4,a2
 760:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 762:	ff053683          	ld	a3,-16(a0)
 766:	a091                	j	7aa <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 768:	6398                	ld	a4,0(a5)
 76a:	00e7e463          	bltu	a5,a4,772 <free+0x3a>
 76e:	00e6ea63          	bltu	a3,a4,782 <free+0x4a>
{
 772:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 774:	fed7fae3          	bgeu	a5,a3,768 <free+0x30>
 778:	6398                	ld	a4,0(a5)
 77a:	00e6e463          	bltu	a3,a4,782 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 77e:	fee7eae3          	bltu	a5,a4,772 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 782:	ff852583          	lw	a1,-8(a0)
 786:	6390                	ld	a2,0(a5)
 788:	02059813          	slli	a6,a1,0x20
 78c:	01c85713          	srli	a4,a6,0x1c
 790:	9736                	add	a4,a4,a3
 792:	fae60de3          	beq	a2,a4,74c <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 796:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 79a:	4790                	lw	a2,8(a5)
 79c:	02061593          	slli	a1,a2,0x20
 7a0:	01c5d713          	srli	a4,a1,0x1c
 7a4:	973e                	add	a4,a4,a5
 7a6:	fae68ae3          	beq	a3,a4,75a <free+0x22>
    p->s.ptr = bp->s.ptr;
 7aa:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 7ac:	00001717          	auipc	a4,0x1
 7b0:	84f73a23          	sd	a5,-1964(a4) # 1000 <freep>
}
 7b4:	6422                	ld	s0,8(sp)
 7b6:	0141                	addi	sp,sp,16
 7b8:	8082                	ret

00000000000007ba <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 7ba:	7139                	addi	sp,sp,-64
 7bc:	fc06                	sd	ra,56(sp)
 7be:	f822                	sd	s0,48(sp)
 7c0:	f426                	sd	s1,40(sp)
 7c2:	f04a                	sd	s2,32(sp)
 7c4:	ec4e                	sd	s3,24(sp)
 7c6:	e852                	sd	s4,16(sp)
 7c8:	e456                	sd	s5,8(sp)
 7ca:	e05a                	sd	s6,0(sp)
 7cc:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 7ce:	02051493          	slli	s1,a0,0x20
 7d2:	9081                	srli	s1,s1,0x20
 7d4:	04bd                	addi	s1,s1,15
 7d6:	8091                	srli	s1,s1,0x4
 7d8:	0014899b          	addiw	s3,s1,1
 7dc:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 7de:	00001517          	auipc	a0,0x1
 7e2:	82253503          	ld	a0,-2014(a0) # 1000 <freep>
 7e6:	c515                	beqz	a0,812 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 7e8:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 7ea:	4798                	lw	a4,8(a5)
 7ec:	02977f63          	bgeu	a4,s1,82a <malloc+0x70>
  if(nu < 4096)
 7f0:	8a4e                	mv	s4,s3
 7f2:	0009871b          	sext.w	a4,s3
 7f6:	6685                	lui	a3,0x1
 7f8:	00d77363          	bgeu	a4,a3,7fe <malloc+0x44>
 7fc:	6a05                	lui	s4,0x1
 7fe:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 802:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 806:	00000917          	auipc	s2,0x0
 80a:	7fa90913          	addi	s2,s2,2042 # 1000 <freep>
  if(p == (char*)-1)
 80e:	5afd                	li	s5,-1
 810:	a895                	j	884 <malloc+0xca>
    base.s.ptr = freep = prevp = &base;
 812:	00001797          	auipc	a5,0x1
 816:	80e78793          	addi	a5,a5,-2034 # 1020 <base>
 81a:	00000717          	auipc	a4,0x0
 81e:	7ef73323          	sd	a5,2022(a4) # 1000 <freep>
 822:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 824:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 828:	b7e1                	j	7f0 <malloc+0x36>
      if(p->s.size == nunits)
 82a:	02e48c63          	beq	s1,a4,862 <malloc+0xa8>
        p->s.size -= nunits;
 82e:	4137073b          	subw	a4,a4,s3
 832:	c798                	sw	a4,8(a5)
        p += p->s.size;
 834:	02071693          	slli	a3,a4,0x20
 838:	01c6d713          	srli	a4,a3,0x1c
 83c:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 83e:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 842:	00000717          	auipc	a4,0x0
 846:	7aa73f23          	sd	a0,1982(a4) # 1000 <freep>
      return (void*)(p + 1);
 84a:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 84e:	70e2                	ld	ra,56(sp)
 850:	7442                	ld	s0,48(sp)
 852:	74a2                	ld	s1,40(sp)
 854:	7902                	ld	s2,32(sp)
 856:	69e2                	ld	s3,24(sp)
 858:	6a42                	ld	s4,16(sp)
 85a:	6aa2                	ld	s5,8(sp)
 85c:	6b02                	ld	s6,0(sp)
 85e:	6121                	addi	sp,sp,64
 860:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 862:	6398                	ld	a4,0(a5)
 864:	e118                	sd	a4,0(a0)
 866:	bff1                	j	842 <malloc+0x88>
  hp->s.size = nu;
 868:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 86c:	0541                	addi	a0,a0,16
 86e:	00000097          	auipc	ra,0x0
 872:	eca080e7          	jalr	-310(ra) # 738 <free>
  return freep;
 876:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 87a:	d971                	beqz	a0,84e <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 87c:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 87e:	4798                	lw	a4,8(a5)
 880:	fa9775e3          	bgeu	a4,s1,82a <malloc+0x70>
    if(p == freep)
 884:	00093703          	ld	a4,0(s2)
 888:	853e                	mv	a0,a5
 88a:	fef719e3          	bne	a4,a5,87c <malloc+0xc2>
  p = sbrk(nu * sizeof(Header));
 88e:	8552                	mv	a0,s4
 890:	00000097          	auipc	ra,0x0
 894:	b8a080e7          	jalr	-1142(ra) # 41a <sbrk>
  if(p == (char*)-1)
 898:	fd5518e3          	bne	a0,s5,868 <malloc+0xae>
        return 0;
 89c:	4501                	li	a0,0
 89e:	bf45                	j	84e <malloc+0x94>

00000000000008a0 <get_current_tid>:
struct ulthread *scheduler_thread;
enum ulthread_scheduling_algorithm algorithm;

/* Get thread ID */
int get_current_tid(void)
{
 8a0:	1141                	addi	sp,sp,-16
 8a2:	e422                	sd	s0,8(sp)
 8a4:	0800                	addi	s0,sp,16
  return current_thread->tid;
}
 8a6:	00000797          	auipc	a5,0x0
 8aa:	7727b783          	ld	a5,1906(a5) # 1018 <current_thread>
 8ae:	43c8                	lw	a0,4(a5)
 8b0:	6422                	ld	s0,8(sp)
 8b2:	0141                	addi	sp,sp,16
 8b4:	8082                	ret

00000000000008b6 <roundRobin>:

void roundRobin(void)
{
 8b6:	715d                	addi	sp,sp,-80
 8b8:	e486                	sd	ra,72(sp)
 8ba:	e0a2                	sd	s0,64(sp)
 8bc:	fc26                	sd	s1,56(sp)
 8be:	f84a                	sd	s2,48(sp)
 8c0:	f44e                	sd	s3,40(sp)
 8c2:	f052                	sd	s4,32(sp)
 8c4:	ec56                	sd	s5,24(sp)
 8c6:	e85a                	sd	s6,16(sp)
 8c8:	e45e                	sd	s7,8(sp)
 8ca:	e062                	sd	s8,0(sp)
 8cc:	0880                	addi	s0,sp,80
        struct ulthread *temp = current_thread;
        current_thread = t;
        printf("[*] ultschedule (next tid: %d)\n", get_current_tid());
        ulthread_context_switch(&temp->context, &t->context);
      }
      if (t->state == YIELD)
 8ce:	4a09                	li	s4,2
      if (t->state == RUNNABLE && t != scheduler_thread)
 8d0:	00000b97          	auipc	s7,0x0
 8d4:	740b8b93          	addi	s7,s7,1856 # 1010 <scheduler_thread>
        struct ulthread *temp = current_thread;
 8d8:	00000a97          	auipc	s5,0x0
 8dc:	740a8a93          	addi	s5,s5,1856 # 1018 <current_thread>
        printf("[*] ultschedule (next tid: %d)\n", get_current_tid());
 8e0:	00000c17          	auipc	s8,0x0
 8e4:	5d8c0c13          	addi	s8,s8,1496 # eb8 <digits+0x18>
    for (t = ulthreads; t < &ulthreads[MAXULTHREADS]; t++)
 8e8:	00004997          	auipc	s3,0x4
 8ec:	c6898993          	addi	s3,s3,-920 # 4550 <ulthreads+0x3520>
 8f0:	a0b9                	j	93e <roundRobin+0x88>
      if (t->state == RUNNABLE && t != scheduler_thread)
 8f2:	000bb783          	ld	a5,0(s7)
 8f6:	02978863          	beq	a5,s1,926 <roundRobin+0x70>
        struct ulthread *temp = current_thread;
 8fa:	000abb03          	ld	s6,0(s5)
        current_thread = t;
 8fe:	009ab023          	sd	s1,0(s5)
        printf("[*] ultschedule (next tid: %d)\n", get_current_tid());
 902:	40cc                	lw	a1,4(s1)
 904:	8562                	mv	a0,s8
 906:	00000097          	auipc	ra,0x0
 90a:	dfc080e7          	jalr	-516(ra) # 702 <printf>
        ulthread_context_switch(&temp->context, &t->context);
 90e:	01848593          	addi	a1,s1,24
 912:	018b0513          	addi	a0,s6,24
 916:	00000097          	auipc	ra,0x0
 91a:	46a080e7          	jalr	1130(ra) # d80 <ulthread_context_switch>
        threadAvailable = true;
 91e:	874a                	mv	a4,s2
 920:	a811                	j	934 <roundRobin+0x7e>
      {
        t->state = RUNNABLE;
 922:	0124a023          	sw	s2,0(s1)
    for (t = ulthreads; t < &ulthreads[MAXULTHREADS]; t++)
 926:	08848493          	addi	s1,s1,136
 92a:	01348963          	beq	s1,s3,93c <roundRobin+0x86>
      if (t->state == RUNNABLE && t != scheduler_thread)
 92e:	409c                	lw	a5,0(s1)
 930:	fd2781e3          	beq	a5,s2,8f2 <roundRobin+0x3c>
      if (t->state == YIELD)
 934:	409c                	lw	a5,0(s1)
 936:	ff4798e3          	bne	a5,s4,926 <roundRobin+0x70>
 93a:	b7e5                	j	922 <roundRobin+0x6c>
      }
    }
    if (!threadAvailable)
 93c:	cb01                	beqz	a4,94c <roundRobin+0x96>
    bool threadAvailable = false;
 93e:	4701                	li	a4,0
    for (t = ulthreads; t < &ulthreads[MAXULTHREADS]; t++)
 940:	00000497          	auipc	s1,0x0
 944:	6f048493          	addi	s1,s1,1776 # 1030 <ulthreads>
      if (t->state == RUNNABLE && t != scheduler_thread)
 948:	4905                	li	s2,1
 94a:	b7d5                	j	92e <roundRobin+0x78>
    {
      break;
    }
  }
}
 94c:	60a6                	ld	ra,72(sp)
 94e:	6406                	ld	s0,64(sp)
 950:	74e2                	ld	s1,56(sp)
 952:	7942                	ld	s2,48(sp)
 954:	79a2                	ld	s3,40(sp)
 956:	7a02                	ld	s4,32(sp)
 958:	6ae2                	ld	s5,24(sp)
 95a:	6b42                	ld	s6,16(sp)
 95c:	6ba2                	ld	s7,8(sp)
 95e:	6c02                	ld	s8,0(sp)
 960:	6161                	addi	sp,sp,80
 962:	8082                	ret

0000000000000964 <firstComeFirstServe>:

void firstComeFirstServe(void)
{
 964:	715d                	addi	sp,sp,-80
 966:	e486                	sd	ra,72(sp)
 968:	e0a2                	sd	s0,64(sp)
 96a:	fc26                	sd	s1,56(sp)
 96c:	f84a                	sd	s2,48(sp)
 96e:	f44e                	sd	s3,40(sp)
 970:	f052                	sd	s4,32(sp)
 972:	ec56                	sd	s5,24(sp)
 974:	e85a                	sd	s6,16(sp)
 976:	e45e                	sd	s7,8(sp)
 978:	e062                	sd	s8,0(sp)
 97a:	0880                	addi	s0,sp,80
    uint64 oldest = __INT64_MAX__;
    int threadIndex = -1;
    int alternativeIndex = -1;
    for (t = ulthreads+1; t < &ulthreads[MAXULTHREADS]; t++)
    {
      if (t->state == RUNNABLE && t != scheduler_thread && t->lastTime < oldest)
 97c:	00000b97          	auipc	s7,0x0
 980:	694b8b93          	addi	s7,s7,1684 # 1010 <scheduler_thread>
    int alternativeIndex = -1;
 984:	5afd                	li	s5,-1
    uint64 oldest = __INT64_MAX__;
 986:	001adb13          	srli	s6,s5,0x1
      if (t->state == RUNNABLE && t != scheduler_thread && t->lastTime < oldest)
 98a:	4485                	li	s1,1
        oldest = t->lastTime;
        threadIndex = t->tid;
        threadAvailable = true;
      }

      if (t->state == YIELD){
 98c:	4989                	li	s3,2
    for (t = ulthreads+1; t < &ulthreads[MAXULTHREADS]; t++)
 98e:	00004917          	auipc	s2,0x4
 992:	bc290913          	addi	s2,s2,-1086 # 4550 <ulthreads+0x3520>
        break;
      }
      
    }
    label : 
      struct ulthread *temp = current_thread;
 996:	00000a17          	auipc	s4,0x0
 99a:	682a0a13          	addi	s4,s4,1666 # 1018 <current_thread>
 99e:	a88d                	j	a10 <firstComeFirstServe+0xac>
      if (t->state == RUNNABLE && t != scheduler_thread && t->lastTime < oldest)
 9a0:	00f58963          	beq	a1,a5,9b2 <firstComeFirstServe+0x4e>
 9a4:	6b98                	ld	a4,16(a5)
 9a6:	00c77663          	bgeu	a4,a2,9b2 <firstComeFirstServe+0x4e>
        threadIndex = t->tid;
 9aa:	0047a803          	lw	a6,4(a5)
        oldest = t->lastTime;
 9ae:	863a                	mv	a2,a4
        threadAvailable = true;
 9b0:	8526                	mv	a0,s1
    for (t = ulthreads+1; t < &ulthreads[MAXULTHREADS]; t++)
 9b2:	08878793          	addi	a5,a5,136
 9b6:	01278a63          	beq	a5,s2,9ca <firstComeFirstServe+0x66>
      if (t->state == RUNNABLE && t != scheduler_thread && t->lastTime < oldest)
 9ba:	4398                	lw	a4,0(a5)
 9bc:	fe9702e3          	beq	a4,s1,9a0 <firstComeFirstServe+0x3c>
      if (t->state == YIELD){
 9c0:	ff3719e3          	bne	a4,s3,9b2 <firstComeFirstServe+0x4e>
        t->state = RUNNABLE;
 9c4:	c384                	sw	s1,0(a5)
        alternativeIndex = t->tid;
 9c6:	43d4                	lw	a3,4(a5)
 9c8:	b7ed                	j	9b2 <firstComeFirstServe+0x4e>
    if (!threadAvailable)
 9ca:	ed31                	bnez	a0,a26 <firstComeFirstServe+0xc2>
      if(alternativeIndex > 0){
 9cc:	04d05f63          	blez	a3,a2a <firstComeFirstServe+0xc6>
      struct ulthread *temp = current_thread;
 9d0:	000a3c03          	ld	s8,0(s4)
      current_thread = &ulthreads[threadIndex];
 9d4:	00469793          	slli	a5,a3,0x4
 9d8:	00d78733          	add	a4,a5,a3
 9dc:	070e                	slli	a4,a4,0x3
 9de:	00000617          	auipc	a2,0x0
 9e2:	65260613          	addi	a2,a2,1618 # 1030 <ulthreads>
 9e6:	9732                	add	a4,a4,a2
 9e8:	00ea3023          	sd	a4,0(s4)
      printf("[*] ultschedule (next tid: %d), time = %d\n", get_current_tid());
 9ec:	434c                	lw	a1,4(a4)
 9ee:	00000517          	auipc	a0,0x0
 9f2:	4ea50513          	addi	a0,a0,1258 # ed8 <digits+0x38>
 9f6:	00000097          	auipc	ra,0x0
 9fa:	d0c080e7          	jalr	-756(ra) # 702 <printf>
      ulthread_context_switch(&temp->context, &current_thread->context);
 9fe:	000a3583          	ld	a1,0(s4)
 a02:	05e1                	addi	a1,a1,24
 a04:	018c0513          	addi	a0,s8,24
 a08:	00000097          	auipc	ra,0x0
 a0c:	378080e7          	jalr	888(ra) # d80 <ulthread_context_switch>
      if (t->state == RUNNABLE && t != scheduler_thread && t->lastTime < oldest)
 a10:	000bb583          	ld	a1,0(s7)
    int alternativeIndex = -1;
 a14:	86d6                	mv	a3,s5
    int threadIndex = -1;
 a16:	8856                	mv	a6,s5
    uint64 oldest = __INT64_MAX__;
 a18:	865a                	mv	a2,s6
    bool threadAvailable = false;
 a1a:	4501                	li	a0,0
    for (t = ulthreads+1; t < &ulthreads[MAXULTHREADS]; t++)
 a1c:	00000797          	auipc	a5,0x0
 a20:	69c78793          	addi	a5,a5,1692 # 10b8 <ulthreads+0x88>
 a24:	bf59                	j	9ba <firstComeFirstServe+0x56>
    label : 
 a26:	86c2                	mv	a3,a6
 a28:	b765                	j	9d0 <firstComeFirstServe+0x6c>
  }
}
 a2a:	60a6                	ld	ra,72(sp)
 a2c:	6406                	ld	s0,64(sp)
 a2e:	74e2                	ld	s1,56(sp)
 a30:	7942                	ld	s2,48(sp)
 a32:	79a2                	ld	s3,40(sp)
 a34:	7a02                	ld	s4,32(sp)
 a36:	6ae2                	ld	s5,24(sp)
 a38:	6b42                	ld	s6,16(sp)
 a3a:	6ba2                	ld	s7,8(sp)
 a3c:	6c02                	ld	s8,0(sp)
 a3e:	6161                	addi	sp,sp,80
 a40:	8082                	ret

0000000000000a42 <priorityScheduling>:


void priorityScheduling(void)
{
 a42:	715d                	addi	sp,sp,-80
 a44:	e486                	sd	ra,72(sp)
 a46:	e0a2                	sd	s0,64(sp)
 a48:	fc26                	sd	s1,56(sp)
 a4a:	f84a                	sd	s2,48(sp)
 a4c:	f44e                	sd	s3,40(sp)
 a4e:	f052                	sd	s4,32(sp)
 a50:	ec56                	sd	s5,24(sp)
 a52:	e85a                	sd	s6,16(sp)
 a54:	e45e                	sd	s7,8(sp)
 a56:	0880                	addi	s0,sp,80
    int maxPriority = -1;
    int threadIndex = -1;
    int alternativeIndex = -1;
    for (t = ulthreads+1; t < &ulthreads[MAXULTHREADS]; t++)
    {
      if (t->state == RUNNABLE && t != scheduler_thread && t->priority > maxPriority)
 a58:	00000b17          	auipc	s6,0x0
 a5c:	5b8b0b13          	addi	s6,s6,1464 # 1010 <scheduler_thread>
    int alternativeIndex = -1;
 a60:	5a7d                	li	s4,-1
      if (t->state == RUNNABLE && t != scheduler_thread && t->priority > maxPriority)
 a62:	4485                	li	s1,1
        // flag = true;

        // break; // switch to highest-priority thread and exit loop
      }

      if (t->state == YIELD){
 a64:	4989                	li	s3,2
    for (t = ulthreads+1; t < &ulthreads[MAXULTHREADS]; t++)
 a66:	00004917          	auipc	s2,0x4
 a6a:	aea90913          	addi	s2,s2,-1302 # 4550 <ulthreads+0x3520>
        break;
      }
      
    }
    label : 
      struct ulthread *temp = current_thread;
 a6e:	00000a97          	auipc	s5,0x0
 a72:	5aaa8a93          	addi	s5,s5,1450 # 1018 <current_thread>
 a76:	a88d                	j	ae8 <priorityScheduling+0xa6>
      if (t->state == RUNNABLE && t != scheduler_thread && t->priority > maxPriority)
 a78:	00f58963          	beq	a1,a5,a8a <priorityScheduling+0x48>
 a7c:	47d8                	lw	a4,12(a5)
 a7e:	00e65663          	bge	a2,a4,a8a <priorityScheduling+0x48>
        threadIndex = t->tid;
 a82:	0047a803          	lw	a6,4(a5)
        maxPriority = t->priority;
 a86:	863a                	mv	a2,a4
        threadAvailable = true;
 a88:	8526                	mv	a0,s1
    for (t = ulthreads+1; t < &ulthreads[MAXULTHREADS]; t++)
 a8a:	08878793          	addi	a5,a5,136
 a8e:	01278a63          	beq	a5,s2,aa2 <priorityScheduling+0x60>
      if (t->state == RUNNABLE && t != scheduler_thread && t->priority > maxPriority)
 a92:	4398                	lw	a4,0(a5)
 a94:	fe9702e3          	beq	a4,s1,a78 <priorityScheduling+0x36>
      if (t->state == YIELD){
 a98:	ff3719e3          	bne	a4,s3,a8a <priorityScheduling+0x48>
        t->state = RUNNABLE;
 a9c:	c384                	sw	s1,0(a5)
        alternativeIndex = t->tid;
 a9e:	43d4                	lw	a3,4(a5)
 aa0:	b7ed                	j	a8a <priorityScheduling+0x48>
    if (!threadAvailable)
 aa2:	ed31                	bnez	a0,afe <priorityScheduling+0xbc>
      if(alternativeIndex > 0){
 aa4:	04d05f63          	blez	a3,b02 <priorityScheduling+0xc0>
      struct ulthread *temp = current_thread;
 aa8:	000abb83          	ld	s7,0(s5)
      current_thread = &ulthreads[threadIndex];
 aac:	00469793          	slli	a5,a3,0x4
 ab0:	00d78733          	add	a4,a5,a3
 ab4:	070e                	slli	a4,a4,0x3
 ab6:	00000617          	auipc	a2,0x0
 aba:	57a60613          	addi	a2,a2,1402 # 1030 <ulthreads>
 abe:	9732                	add	a4,a4,a2
 ac0:	00eab023          	sd	a4,0(s5)
      printf("[*] ultschedule (next tid: %d)\n", get_current_tid());
 ac4:	434c                	lw	a1,4(a4)
 ac6:	00000517          	auipc	a0,0x0
 aca:	3f250513          	addi	a0,a0,1010 # eb8 <digits+0x18>
 ace:	00000097          	auipc	ra,0x0
 ad2:	c34080e7          	jalr	-972(ra) # 702 <printf>
      ulthread_context_switch(&temp->context, &current_thread->context);
 ad6:	000ab583          	ld	a1,0(s5)
 ada:	05e1                	addi	a1,a1,24
 adc:	018b8513          	addi	a0,s7,24
 ae0:	00000097          	auipc	ra,0x0
 ae4:	2a0080e7          	jalr	672(ra) # d80 <ulthread_context_switch>
      if (t->state == RUNNABLE && t != scheduler_thread && t->priority > maxPriority)
 ae8:	000b3583          	ld	a1,0(s6)
    int alternativeIndex = -1;
 aec:	86d2                	mv	a3,s4
    int threadIndex = -1;
 aee:	8852                	mv	a6,s4
    int maxPriority = -1;
 af0:	8652                	mv	a2,s4
    bool threadAvailable = false;
 af2:	4501                	li	a0,0
    for (t = ulthreads+1; t < &ulthreads[MAXULTHREADS]; t++)
 af4:	00000797          	auipc	a5,0x0
 af8:	5c478793          	addi	a5,a5,1476 # 10b8 <ulthreads+0x88>
 afc:	bf59                	j	a92 <priorityScheduling+0x50>
    label : 
 afe:	86c2                	mv	a3,a6
 b00:	b765                	j	aa8 <priorityScheduling+0x66>
  }
}
 b02:	60a6                	ld	ra,72(sp)
 b04:	6406                	ld	s0,64(sp)
 b06:	74e2                	ld	s1,56(sp)
 b08:	7942                	ld	s2,48(sp)
 b0a:	79a2                	ld	s3,40(sp)
 b0c:	7a02                	ld	s4,32(sp)
 b0e:	6ae2                	ld	s5,24(sp)
 b10:	6b42                	ld	s6,16(sp)
 b12:	6ba2                	ld	s7,8(sp)
 b14:	6161                	addi	sp,sp,80
 b16:	8082                	ret

0000000000000b18 <ulthread_init>:

/* Thread initialization */
void ulthread_init(int schedalgo)
{
 b18:	1141                	addi	sp,sp,-16
 b1a:	e422                	sd	s0,8(sp)
 b1c:	0800                	addi	s0,sp,16
  struct ulthread *t;
  int i;
  for (i = 0, t = ulthreads; t < &ulthreads[MAXULTHREADS]; t++, i++)
 b1e:	4701                	li	a4,0
 b20:	00000797          	auipc	a5,0x0
 b24:	51078793          	addi	a5,a5,1296 # 1030 <ulthreads>
 b28:	00004697          	auipc	a3,0x4
 b2c:	a2868693          	addi	a3,a3,-1496 # 4550 <ulthreads+0x3520>
  {
    t->state = FREE;
 b30:	0007a023          	sw	zero,0(a5)
    t->tid = i;
 b34:	c3d8                	sw	a4,4(a5)
  for (i = 0, t = ulthreads; t < &ulthreads[MAXULTHREADS]; t++, i++)
 b36:	08878793          	addi	a5,a5,136
 b3a:	2705                	addiw	a4,a4,1
 b3c:	fed79ae3          	bne	a5,a3,b30 <ulthread_init+0x18>
  }
  current_thread = &ulthreads[0];
 b40:	00000797          	auipc	a5,0x0
 b44:	4f078793          	addi	a5,a5,1264 # 1030 <ulthreads>
 b48:	00000717          	auipc	a4,0x0
 b4c:	4cf73823          	sd	a5,1232(a4) # 1018 <current_thread>
  scheduler_thread = &ulthreads[0];
 b50:	00000717          	auipc	a4,0x0
 b54:	4cf73023          	sd	a5,1216(a4) # 1010 <scheduler_thread>
  scheduler_thread->state = RUNNABLE;
 b58:	4705                	li	a4,1
 b5a:	c398                	sw	a4,0(a5)
  t->state = FREE;
 b5c:	00004797          	auipc	a5,0x4
 b60:	9e07aa23          	sw	zero,-1548(a5) # 4550 <ulthreads+0x3520>
  algorithm = schedalgo;
 b64:	00000797          	auipc	a5,0x0
 b68:	4aa7a223          	sw	a0,1188(a5) # 1008 <algorithm>
}
 b6c:	6422                	ld	s0,8(sp)
 b6e:	0141                	addi	sp,sp,16
 b70:	8082                	ret

0000000000000b72 <ulthread_create>:

/* Thread creation */
bool ulthread_create(uint64 start, uint64 stack, uint64 args[], int priority)
{
 b72:	7179                	addi	sp,sp,-48
 b74:	f406                	sd	ra,40(sp)
 b76:	f022                	sd	s0,32(sp)
 b78:	ec26                	sd	s1,24(sp)
 b7a:	e84a                	sd	s2,16(sp)
 b7c:	e44e                	sd	s3,8(sp)
 b7e:	e052                	sd	s4,0(sp)
 b80:	1800                	addi	s0,sp,48
 b82:	89aa                	mv	s3,a0
 b84:	8a2e                	mv	s4,a1
 b86:	8932                	mv	s2,a2
  /* Please add thread-id instead of '0' here. */
  struct ulthread *t;
  bool flag = false;
  for (t = ulthreads; t < &ulthreads[MAXULTHREADS]; t++)
 b88:	00000497          	auipc	s1,0x0
 b8c:	4a848493          	addi	s1,s1,1192 # 1030 <ulthreads>
 b90:	00004717          	auipc	a4,0x4
 b94:	9c070713          	addi	a4,a4,-1600 # 4550 <ulthreads+0x3520>
  {
    if (t->state == FREE)
 b98:	409c                	lw	a5,0(s1)
 b9a:	cf89                	beqz	a5,bb4 <ulthread_create+0x42>
  for (t = ulthreads; t < &ulthreads[MAXULTHREADS]; t++)
 b9c:	08848493          	addi	s1,s1,136
 ba0:	fee49ce3          	bne	s1,a4,b98 <ulthread_create+0x26>
      break;
    }
  }
  if (!flag)
  {
    return false;
 ba4:	4501                	li	a0,0
 ba6:	a871                	j	c42 <ulthread_create+0xd0>
  t->sp = (int)(stack + USTACKSIZE); // set sp to the top of the stack
  t->state = RUNNABLE;
  t->priority = priority;

  if(algorithm==FCFS){
    t->lastTime = ctime();
 ba8:	00000097          	auipc	ra,0x0
 bac:	88a080e7          	jalr	-1910(ra) # 432 <ctime>
 bb0:	e888                	sd	a0,16(s1)
 bb2:	a839                	j	bd0 <ulthread_create+0x5e>
  t->sp = (int)(stack + USTACKSIZE); // set sp to the top of the stack
 bb4:	6785                	lui	a5,0x1
 bb6:	014787bb          	addw	a5,a5,s4
 bba:	c49c                	sw	a5,8(s1)
  t->state = RUNNABLE;
 bbc:	4785                	li	a5,1
 bbe:	c09c                	sw	a5,0(s1)
  t->priority = priority;
 bc0:	c4d4                	sw	a3,12(s1)
  if(algorithm==FCFS){
 bc2:	00000717          	auipc	a4,0x0
 bc6:	44672703          	lw	a4,1094(a4) # 1008 <algorithm>
 bca:	4789                	li	a5,2
 bcc:	fcf70ee3          	beq	a4,a5,ba8 <ulthread_create+0x36>
  }

  for (int argc = 0; argc < 6; argc++)
 bd0:	874a                	mv	a4,s2
 bd2:	03090693          	addi	a3,s2,48
  {
    t->sp -= 16;
 bd6:	449c                	lw	a5,8(s1)
 bd8:	37c1                	addiw	a5,a5,-16 # ff0 <digits+0x150>
 bda:	0007881b          	sext.w	a6,a5
 bde:	c49c                	sw	a5,8(s1)
    *(uint64 *)(t->sp) = (uint64)args[argc];
 be0:	631c                	ld	a5,0(a4)
 be2:	00f83023          	sd	a5,0(a6)
  for (int argc = 0; argc < 6; argc++)
 be6:	0721                	addi	a4,a4,8
 be8:	fed717e3          	bne	a4,a3,bd6 <ulthread_create+0x64>
  }

  memset(&t->context, 0, sizeof(t->context));
 bec:	07000613          	li	a2,112
 bf0:	4581                	li	a1,0
 bf2:	01848513          	addi	a0,s1,24
 bf6:	fffff097          	auipc	ra,0xfffff
 bfa:	5a2080e7          	jalr	1442(ra) # 198 <memset>
  t->context.ra = start;
 bfe:	0134bc23          	sd	s3,24(s1)
  t->context.sp = t->sp;
 c02:	449c                	lw	a5,8(s1)
 c04:	f09c                	sd	a5,32(s1)
  t->context.s0 = args[0];
 c06:	00093783          	ld	a5,0(s2)
 c0a:	f49c                	sd	a5,40(s1)
  t->context.s1 = args[1];
 c0c:	00893783          	ld	a5,8(s2)
 c10:	f89c                	sd	a5,48(s1)
  t->context.s2 = args[2];
 c12:	01093783          	ld	a5,16(s2)
 c16:	fc9c                	sd	a5,56(s1)
  t->context.s3 = args[3];
 c18:	01893783          	ld	a5,24(s2)
 c1c:	e0bc                	sd	a5,64(s1)
  t->context.s4 = args[4];
 c1e:	02093783          	ld	a5,32(s2)
 c22:	e4bc                	sd	a5,72(s1)
  t->context.s5 = args[5];
 c24:	02893783          	ld	a5,40(s2)
 c28:	e8bc                	sd	a5,80(s1)

  printf("[*] ultcreate(tid: %d, ra: %p, sp: %p)\n", t->tid, start, stack);
 c2a:	86d2                	mv	a3,s4
 c2c:	864e                	mv	a2,s3
 c2e:	40cc                	lw	a1,4(s1)
 c30:	00000517          	auipc	a0,0x0
 c34:	2d850513          	addi	a0,a0,728 # f08 <digits+0x68>
 c38:	00000097          	auipc	ra,0x0
 c3c:	aca080e7          	jalr	-1334(ra) # 702 <printf>
  return true;
 c40:	4505                	li	a0,1
}
 c42:	70a2                	ld	ra,40(sp)
 c44:	7402                	ld	s0,32(sp)
 c46:	64e2                	ld	s1,24(sp)
 c48:	6942                	ld	s2,16(sp)
 c4a:	69a2                	ld	s3,8(sp)
 c4c:	6a02                	ld	s4,0(sp)
 c4e:	6145                	addi	sp,sp,48
 c50:	8082                	ret

0000000000000c52 <ulthread_schedule>:

/* Thread scheduler */
void ulthread_schedule(void)
{
 c52:	1141                	addi	sp,sp,-16
 c54:	e406                	sd	ra,8(sp)
 c56:	e022                	sd	s0,0(sp)
 c58:	0800                	addi	s0,sp,16
  switch (algorithm)
 c5a:	00000797          	auipc	a5,0x0
 c5e:	3ae7a783          	lw	a5,942(a5) # 1008 <algorithm>
 c62:	4705                	li	a4,1
 c64:	02e78463          	beq	a5,a4,c8c <ulthread_schedule+0x3a>
 c68:	4709                	li	a4,2
 c6a:	00e78c63          	beq	a5,a4,c82 <ulthread_schedule+0x30>
 c6e:	c789                	beqz	a5,c78 <ulthread_schedule+0x26>

  // Push argument strings, prepare rest of stack in ustack.

  // Switch between thread contexts
  // ulthread_context_switch(NULL, NULL);
}
 c70:	60a2                	ld	ra,8(sp)
 c72:	6402                	ld	s0,0(sp)
 c74:	0141                	addi	sp,sp,16
 c76:	8082                	ret
    roundRobin();
 c78:	00000097          	auipc	ra,0x0
 c7c:	c3e080e7          	jalr	-962(ra) # 8b6 <roundRobin>
    break;
 c80:	bfc5                	j	c70 <ulthread_schedule+0x1e>
    firstComeFirstServe();
 c82:	00000097          	auipc	ra,0x0
 c86:	ce2080e7          	jalr	-798(ra) # 964 <firstComeFirstServe>
    break;
 c8a:	b7dd                	j	c70 <ulthread_schedule+0x1e>
    priorityScheduling();
 c8c:	00000097          	auipc	ra,0x0
 c90:	db6080e7          	jalr	-586(ra) # a42 <priorityScheduling>
}
 c94:	bff1                	j	c70 <ulthread_schedule+0x1e>

0000000000000c96 <ulthread_yield>:

/* Yield CPU time to some other thread. */
void ulthread_yield(void)
{
 c96:	1101                	addi	sp,sp,-32
 c98:	ec06                	sd	ra,24(sp)
 c9a:	e822                	sd	s0,16(sp)
 c9c:	e426                	sd	s1,8(sp)
 c9e:	e04a                	sd	s2,0(sp)
 ca0:	1000                	addi	s0,sp,32
  current_thread->state = YIELD;
 ca2:	00000797          	auipc	a5,0x0
 ca6:	37678793          	addi	a5,a5,886 # 1018 <current_thread>
 caa:	6398                	ld	a4,0(a5)
 cac:	4909                	li	s2,2
 cae:	01272023          	sw	s2,0(a4)
  struct ulthread *temp = current_thread;
 cb2:	6384                	ld	s1,0(a5)
  printf("[*] ultyield(tid: %d)\n", current_thread->tid);
 cb4:	40cc                	lw	a1,4(s1)
 cb6:	00000517          	auipc	a0,0x0
 cba:	27a50513          	addi	a0,a0,634 # f30 <digits+0x90>
 cbe:	00000097          	auipc	ra,0x0
 cc2:	a44080e7          	jalr	-1468(ra) # 702 <printf>
  if(algorithm==FCFS){
 cc6:	00000797          	auipc	a5,0x0
 cca:	3427a783          	lw	a5,834(a5) # 1008 <algorithm>
 cce:	03278763          	beq	a5,s2,cfc <ulthread_yield+0x66>
    current_thread->lastTime = ctime();
  }
  current_thread = scheduler_thread;
 cd2:	00000597          	auipc	a1,0x0
 cd6:	33e5b583          	ld	a1,830(a1) # 1010 <scheduler_thread>
 cda:	00000797          	auipc	a5,0x0
 cde:	32b7bf23          	sd	a1,830(a5) # 1018 <current_thread>
  
  ulthread_context_switch(&temp->context, &scheduler_thread->context);
 ce2:	05e1                	addi	a1,a1,24
 ce4:	01848513          	addi	a0,s1,24
 ce8:	00000097          	auipc	ra,0x0
 cec:	098080e7          	jalr	152(ra) # d80 <ulthread_context_switch>
  // ulthread_schedule();
}
 cf0:	60e2                	ld	ra,24(sp)
 cf2:	6442                	ld	s0,16(sp)
 cf4:	64a2                	ld	s1,8(sp)
 cf6:	6902                	ld	s2,0(sp)
 cf8:	6105                	addi	sp,sp,32
 cfa:	8082                	ret
    current_thread->lastTime = ctime();
 cfc:	fffff097          	auipc	ra,0xfffff
 d00:	736080e7          	jalr	1846(ra) # 432 <ctime>
 d04:	00000797          	auipc	a5,0x0
 d08:	3147b783          	ld	a5,788(a5) # 1018 <current_thread>
 d0c:	eb88                	sd	a0,16(a5)
 d0e:	b7d1                	j	cd2 <ulthread_yield+0x3c>

0000000000000d10 <ulthread_destroy>:

/* Destroy thread */
void ulthread_destroy(void)
{
 d10:	1101                	addi	sp,sp,-32
 d12:	ec06                	sd	ra,24(sp)
 d14:	e822                	sd	s0,16(sp)
 d16:	e426                	sd	s1,8(sp)
 d18:	e04a                	sd	s2,0(sp)
 d1a:	1000                	addi	s0,sp,32
  memset(&current_thread->context, 0, sizeof(current_thread->context));
 d1c:	00000497          	auipc	s1,0x0
 d20:	2fc48493          	addi	s1,s1,764 # 1018 <current_thread>
 d24:	6088                	ld	a0,0(s1)
 d26:	07000613          	li	a2,112
 d2a:	4581                	li	a1,0
 d2c:	0561                	addi	a0,a0,24
 d2e:	fffff097          	auipc	ra,0xfffff
 d32:	46a080e7          	jalr	1130(ra) # 198 <memset>
  current_thread->sp = 0;
 d36:	609c                	ld	a5,0(s1)
 d38:	0007a423          	sw	zero,8(a5)
  current_thread->priority = -1;
 d3c:	577d                	li	a4,-1
 d3e:	c7d8                	sw	a4,12(a5)
  current_thread->state = FREE;
 d40:	0007a023          	sw	zero,0(a5)

  struct ulthread *temp = current_thread;
 d44:	0004b903          	ld	s2,0(s1)

  printf("[*] ultdestroy(tid: %d)\n", get_current_tid());
 d48:	00492583          	lw	a1,4(s2)
 d4c:	00000517          	auipc	a0,0x0
 d50:	1fc50513          	addi	a0,a0,508 # f48 <digits+0xa8>
 d54:	00000097          	auipc	ra,0x0
 d58:	9ae080e7          	jalr	-1618(ra) # 702 <printf>
  current_thread = scheduler_thread;
 d5c:	00000597          	auipc	a1,0x0
 d60:	2b45b583          	ld	a1,692(a1) # 1010 <scheduler_thread>
 d64:	e08c                	sd	a1,0(s1)
  ulthread_context_switch(&temp->context, &scheduler_thread->context);
 d66:	05e1                	addi	a1,a1,24
 d68:	01890513          	addi	a0,s2,24
 d6c:	00000097          	auipc	ra,0x0
 d70:	014080e7          	jalr	20(ra) # d80 <ulthread_context_switch>
}
 d74:	60e2                	ld	ra,24(sp)
 d76:	6442                	ld	s0,16(sp)
 d78:	64a2                	ld	s1,8(sp)
 d7a:	6902                	ld	s2,0(sp)
 d7c:	6105                	addi	sp,sp,32
 d7e:	8082                	ret

0000000000000d80 <ulthread_context_switch>:
 d80:	00153023          	sd	ra,0(a0)
 d84:	00253423          	sd	sp,8(a0)
 d88:	e900                	sd	s0,16(a0)
 d8a:	ed04                	sd	s1,24(a0)
 d8c:	03253023          	sd	s2,32(a0)
 d90:	03353423          	sd	s3,40(a0)
 d94:	03453823          	sd	s4,48(a0)
 d98:	03553c23          	sd	s5,56(a0)
 d9c:	05653023          	sd	s6,64(a0)
 da0:	05753423          	sd	s7,72(a0)
 da4:	05853823          	sd	s8,80(a0)
 da8:	05953c23          	sd	s9,88(a0)
 dac:	07a53023          	sd	s10,96(a0)
 db0:	07b53423          	sd	s11,104(a0)
 db4:	0005b083          	ld	ra,0(a1)
 db8:	0085b103          	ld	sp,8(a1)
 dbc:	6980                	ld	s0,16(a1)
 dbe:	6d84                	ld	s1,24(a1)
 dc0:	0205b903          	ld	s2,32(a1)
 dc4:	0285b983          	ld	s3,40(a1)
 dc8:	0305ba03          	ld	s4,48(a1)
 dcc:	0385ba83          	ld	s5,56(a1)
 dd0:	0405bb03          	ld	s6,64(a1)
 dd4:	0485bb83          	ld	s7,72(a1)
 dd8:	0505bc03          	ld	s8,80(a1)
 ddc:	0585bc83          	ld	s9,88(a1)
 de0:	0605bd03          	ld	s10,96(a1)
 de4:	0685bd83          	ld	s11,104(a1)
 de8:	6546                	ld	a0,80(sp)
 dea:	6586                	ld	a1,64(sp)
 dec:	7642                	ld	a2,48(sp)
 dee:	7682                	ld	a3,32(sp)
 df0:	6742                	ld	a4,16(sp)
 df2:	6782                	ld	a5,0(sp)
 df4:	8082                	ret
