
user/_init:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:

char *argv[] = { "sh", 0 };

int
main(void)
{
   0:	1101                	addi	sp,sp,-32
   2:	ec06                	sd	ra,24(sp)
   4:	e822                	sd	s0,16(sp)
   6:	e426                	sd	s1,8(sp)
   8:	e04a                	sd	s2,0(sp)
   a:	1000                	addi	s0,sp,32
  int pid, wpid;

  if(open("console", O_RDWR) < 0){
   c:	4589                	li	a1,2
   e:	00001517          	auipc	a0,0x1
  12:	de250513          	addi	a0,a0,-542 # df0 <ulthread_context_switch+0x84>
  16:	00000097          	auipc	ra,0x0
  1a:	3a8080e7          	jalr	936(ra) # 3be <open>
  1e:	06054363          	bltz	a0,84 <main+0x84>
    mknod("console", CONSOLE, 0);
    open("console", O_RDWR);
  }
  dup(0);  // stdout
  22:	4501                	li	a0,0
  24:	00000097          	auipc	ra,0x0
  28:	3d2080e7          	jalr	978(ra) # 3f6 <dup>
  dup(0);  // stderr
  2c:	4501                	li	a0,0
  2e:	00000097          	auipc	ra,0x0
  32:	3c8080e7          	jalr	968(ra) # 3f6 <dup>

  for(;;){
    printf("init: starting sh\n");
  36:	00001917          	auipc	s2,0x1
  3a:	dc290913          	addi	s2,s2,-574 # df8 <ulthread_context_switch+0x8c>
  3e:	854a                	mv	a0,s2
  40:	00000097          	auipc	ra,0x0
  44:	6ae080e7          	jalr	1710(ra) # 6ee <printf>
    pid = fork();
  48:	00000097          	auipc	ra,0x0
  4c:	32e080e7          	jalr	814(ra) # 376 <fork>
  50:	84aa                	mv	s1,a0
    if(pid < 0){
  52:	04054d63          	bltz	a0,ac <main+0xac>
      printf("init: fork failed\n");
      exit(1);
    }
    if(pid == 0){
  56:	c925                	beqz	a0,c6 <main+0xc6>
    }

    for(;;){
      // this call to wait() returns if the shell exits,
      // or if a parentless process exits.
      wpid = wait((int *) 0);
  58:	4501                	li	a0,0
  5a:	00000097          	auipc	ra,0x0
  5e:	32c080e7          	jalr	812(ra) # 386 <wait>
      if(wpid == pid){
  62:	fca48ee3          	beq	s1,a0,3e <main+0x3e>
        // the shell exited; restart it.
        break;
      } else if(wpid < 0){
  66:	fe0559e3          	bgez	a0,58 <main+0x58>
        printf("init: wait returned an error\n");
  6a:	00001517          	auipc	a0,0x1
  6e:	dde50513          	addi	a0,a0,-546 # e48 <ulthread_context_switch+0xdc>
  72:	00000097          	auipc	ra,0x0
  76:	67c080e7          	jalr	1660(ra) # 6ee <printf>
        exit(1);
  7a:	4505                	li	a0,1
  7c:	00000097          	auipc	ra,0x0
  80:	302080e7          	jalr	770(ra) # 37e <exit>
    mknod("console", CONSOLE, 0);
  84:	4601                	li	a2,0
  86:	4585                	li	a1,1
  88:	00001517          	auipc	a0,0x1
  8c:	d6850513          	addi	a0,a0,-664 # df0 <ulthread_context_switch+0x84>
  90:	00000097          	auipc	ra,0x0
  94:	336080e7          	jalr	822(ra) # 3c6 <mknod>
    open("console", O_RDWR);
  98:	4589                	li	a1,2
  9a:	00001517          	auipc	a0,0x1
  9e:	d5650513          	addi	a0,a0,-682 # df0 <ulthread_context_switch+0x84>
  a2:	00000097          	auipc	ra,0x0
  a6:	31c080e7          	jalr	796(ra) # 3be <open>
  aa:	bfa5                	j	22 <main+0x22>
      printf("init: fork failed\n");
  ac:	00001517          	auipc	a0,0x1
  b0:	d6450513          	addi	a0,a0,-668 # e10 <ulthread_context_switch+0xa4>
  b4:	00000097          	auipc	ra,0x0
  b8:	63a080e7          	jalr	1594(ra) # 6ee <printf>
      exit(1);
  bc:	4505                	li	a0,1
  be:	00000097          	auipc	ra,0x0
  c2:	2c0080e7          	jalr	704(ra) # 37e <exit>
      exec("sh", argv);
  c6:	00001597          	auipc	a1,0x1
  ca:	f3a58593          	addi	a1,a1,-198 # 1000 <argv>
  ce:	00001517          	auipc	a0,0x1
  d2:	d5a50513          	addi	a0,a0,-678 # e28 <ulthread_context_switch+0xbc>
  d6:	00000097          	auipc	ra,0x0
  da:	2e0080e7          	jalr	736(ra) # 3b6 <exec>
      printf("init: exec sh failed\n");
  de:	00001517          	auipc	a0,0x1
  e2:	d5250513          	addi	a0,a0,-686 # e30 <ulthread_context_switch+0xc4>
  e6:	00000097          	auipc	ra,0x0
  ea:	608080e7          	jalr	1544(ra) # 6ee <printf>
      exit(1);
  ee:	4505                	li	a0,1
  f0:	00000097          	auipc	ra,0x0
  f4:	28e080e7          	jalr	654(ra) # 37e <exit>

00000000000000f8 <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
  f8:	1141                	addi	sp,sp,-16
  fa:	e406                	sd	ra,8(sp)
  fc:	e022                	sd	s0,0(sp)
  fe:	0800                	addi	s0,sp,16
  extern int main();
  main();
 100:	00000097          	auipc	ra,0x0
 104:	f00080e7          	jalr	-256(ra) # 0 <main>
  exit(0);
 108:	4501                	li	a0,0
 10a:	00000097          	auipc	ra,0x0
 10e:	274080e7          	jalr	628(ra) # 37e <exit>

0000000000000112 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 112:	1141                	addi	sp,sp,-16
 114:	e422                	sd	s0,8(sp)
 116:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 118:	87aa                	mv	a5,a0
 11a:	0585                	addi	a1,a1,1
 11c:	0785                	addi	a5,a5,1
 11e:	fff5c703          	lbu	a4,-1(a1)
 122:	fee78fa3          	sb	a4,-1(a5)
 126:	fb75                	bnez	a4,11a <strcpy+0x8>
    ;
  return os;
}
 128:	6422                	ld	s0,8(sp)
 12a:	0141                	addi	sp,sp,16
 12c:	8082                	ret

000000000000012e <strcmp>:

int
strcmp(const char *p, const char *q)
{
 12e:	1141                	addi	sp,sp,-16
 130:	e422                	sd	s0,8(sp)
 132:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 134:	00054783          	lbu	a5,0(a0)
 138:	cb91                	beqz	a5,14c <strcmp+0x1e>
 13a:	0005c703          	lbu	a4,0(a1)
 13e:	00f71763          	bne	a4,a5,14c <strcmp+0x1e>
    p++, q++;
 142:	0505                	addi	a0,a0,1
 144:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 146:	00054783          	lbu	a5,0(a0)
 14a:	fbe5                	bnez	a5,13a <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 14c:	0005c503          	lbu	a0,0(a1)
}
 150:	40a7853b          	subw	a0,a5,a0
 154:	6422                	ld	s0,8(sp)
 156:	0141                	addi	sp,sp,16
 158:	8082                	ret

000000000000015a <strlen>:

uint
strlen(const char *s)
{
 15a:	1141                	addi	sp,sp,-16
 15c:	e422                	sd	s0,8(sp)
 15e:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 160:	00054783          	lbu	a5,0(a0)
 164:	cf91                	beqz	a5,180 <strlen+0x26>
 166:	0505                	addi	a0,a0,1
 168:	87aa                	mv	a5,a0
 16a:	86be                	mv	a3,a5
 16c:	0785                	addi	a5,a5,1
 16e:	fff7c703          	lbu	a4,-1(a5)
 172:	ff65                	bnez	a4,16a <strlen+0x10>
 174:	40a6853b          	subw	a0,a3,a0
 178:	2505                	addiw	a0,a0,1
    ;
  return n;
}
 17a:	6422                	ld	s0,8(sp)
 17c:	0141                	addi	sp,sp,16
 17e:	8082                	ret
  for(n = 0; s[n]; n++)
 180:	4501                	li	a0,0
 182:	bfe5                	j	17a <strlen+0x20>

0000000000000184 <memset>:

void*
memset(void *dst, int c, uint n)
{
 184:	1141                	addi	sp,sp,-16
 186:	e422                	sd	s0,8(sp)
 188:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 18a:	ca19                	beqz	a2,1a0 <memset+0x1c>
 18c:	87aa                	mv	a5,a0
 18e:	1602                	slli	a2,a2,0x20
 190:	9201                	srli	a2,a2,0x20
 192:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 196:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 19a:	0785                	addi	a5,a5,1
 19c:	fee79de3          	bne	a5,a4,196 <memset+0x12>
  }
  return dst;
}
 1a0:	6422                	ld	s0,8(sp)
 1a2:	0141                	addi	sp,sp,16
 1a4:	8082                	ret

00000000000001a6 <strchr>:

char*
strchr(const char *s, char c)
{
 1a6:	1141                	addi	sp,sp,-16
 1a8:	e422                	sd	s0,8(sp)
 1aa:	0800                	addi	s0,sp,16
  for(; *s; s++)
 1ac:	00054783          	lbu	a5,0(a0)
 1b0:	cb99                	beqz	a5,1c6 <strchr+0x20>
    if(*s == c)
 1b2:	00f58763          	beq	a1,a5,1c0 <strchr+0x1a>
  for(; *s; s++)
 1b6:	0505                	addi	a0,a0,1
 1b8:	00054783          	lbu	a5,0(a0)
 1bc:	fbfd                	bnez	a5,1b2 <strchr+0xc>
      return (char*)s;
  return 0;
 1be:	4501                	li	a0,0
}
 1c0:	6422                	ld	s0,8(sp)
 1c2:	0141                	addi	sp,sp,16
 1c4:	8082                	ret
  return 0;
 1c6:	4501                	li	a0,0
 1c8:	bfe5                	j	1c0 <strchr+0x1a>

00000000000001ca <gets>:

char*
gets(char *buf, int max)
{
 1ca:	711d                	addi	sp,sp,-96
 1cc:	ec86                	sd	ra,88(sp)
 1ce:	e8a2                	sd	s0,80(sp)
 1d0:	e4a6                	sd	s1,72(sp)
 1d2:	e0ca                	sd	s2,64(sp)
 1d4:	fc4e                	sd	s3,56(sp)
 1d6:	f852                	sd	s4,48(sp)
 1d8:	f456                	sd	s5,40(sp)
 1da:	f05a                	sd	s6,32(sp)
 1dc:	ec5e                	sd	s7,24(sp)
 1de:	1080                	addi	s0,sp,96
 1e0:	8baa                	mv	s7,a0
 1e2:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1e4:	892a                	mv	s2,a0
 1e6:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 1e8:	4aa9                	li	s5,10
 1ea:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 1ec:	89a6                	mv	s3,s1
 1ee:	2485                	addiw	s1,s1,1
 1f0:	0344d863          	bge	s1,s4,220 <gets+0x56>
    cc = read(0, &c, 1);
 1f4:	4605                	li	a2,1
 1f6:	faf40593          	addi	a1,s0,-81
 1fa:	4501                	li	a0,0
 1fc:	00000097          	auipc	ra,0x0
 200:	19a080e7          	jalr	410(ra) # 396 <read>
    if(cc < 1)
 204:	00a05e63          	blez	a0,220 <gets+0x56>
    buf[i++] = c;
 208:	faf44783          	lbu	a5,-81(s0)
 20c:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 210:	01578763          	beq	a5,s5,21e <gets+0x54>
 214:	0905                	addi	s2,s2,1
 216:	fd679be3          	bne	a5,s6,1ec <gets+0x22>
  for(i=0; i+1 < max; ){
 21a:	89a6                	mv	s3,s1
 21c:	a011                	j	220 <gets+0x56>
 21e:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 220:	99de                	add	s3,s3,s7
 222:	00098023          	sb	zero,0(s3)
  return buf;
}
 226:	855e                	mv	a0,s7
 228:	60e6                	ld	ra,88(sp)
 22a:	6446                	ld	s0,80(sp)
 22c:	64a6                	ld	s1,72(sp)
 22e:	6906                	ld	s2,64(sp)
 230:	79e2                	ld	s3,56(sp)
 232:	7a42                	ld	s4,48(sp)
 234:	7aa2                	ld	s5,40(sp)
 236:	7b02                	ld	s6,32(sp)
 238:	6be2                	ld	s7,24(sp)
 23a:	6125                	addi	sp,sp,96
 23c:	8082                	ret

000000000000023e <stat>:

int
stat(const char *n, struct stat *st)
{
 23e:	1101                	addi	sp,sp,-32
 240:	ec06                	sd	ra,24(sp)
 242:	e822                	sd	s0,16(sp)
 244:	e426                	sd	s1,8(sp)
 246:	e04a                	sd	s2,0(sp)
 248:	1000                	addi	s0,sp,32
 24a:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 24c:	4581                	li	a1,0
 24e:	00000097          	auipc	ra,0x0
 252:	170080e7          	jalr	368(ra) # 3be <open>
  if(fd < 0)
 256:	02054563          	bltz	a0,280 <stat+0x42>
 25a:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 25c:	85ca                	mv	a1,s2
 25e:	00000097          	auipc	ra,0x0
 262:	178080e7          	jalr	376(ra) # 3d6 <fstat>
 266:	892a                	mv	s2,a0
  close(fd);
 268:	8526                	mv	a0,s1
 26a:	00000097          	auipc	ra,0x0
 26e:	13c080e7          	jalr	316(ra) # 3a6 <close>
  return r;
}
 272:	854a                	mv	a0,s2
 274:	60e2                	ld	ra,24(sp)
 276:	6442                	ld	s0,16(sp)
 278:	64a2                	ld	s1,8(sp)
 27a:	6902                	ld	s2,0(sp)
 27c:	6105                	addi	sp,sp,32
 27e:	8082                	ret
    return -1;
 280:	597d                	li	s2,-1
 282:	bfc5                	j	272 <stat+0x34>

0000000000000284 <atoi>:

int
atoi(const char *s)
{
 284:	1141                	addi	sp,sp,-16
 286:	e422                	sd	s0,8(sp)
 288:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 28a:	00054683          	lbu	a3,0(a0)
 28e:	fd06879b          	addiw	a5,a3,-48
 292:	0ff7f793          	zext.b	a5,a5
 296:	4625                	li	a2,9
 298:	02f66863          	bltu	a2,a5,2c8 <atoi+0x44>
 29c:	872a                	mv	a4,a0
  n = 0;
 29e:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 2a0:	0705                	addi	a4,a4,1
 2a2:	0025179b          	slliw	a5,a0,0x2
 2a6:	9fa9                	addw	a5,a5,a0
 2a8:	0017979b          	slliw	a5,a5,0x1
 2ac:	9fb5                	addw	a5,a5,a3
 2ae:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 2b2:	00074683          	lbu	a3,0(a4)
 2b6:	fd06879b          	addiw	a5,a3,-48
 2ba:	0ff7f793          	zext.b	a5,a5
 2be:	fef671e3          	bgeu	a2,a5,2a0 <atoi+0x1c>
  return n;
}
 2c2:	6422                	ld	s0,8(sp)
 2c4:	0141                	addi	sp,sp,16
 2c6:	8082                	ret
  n = 0;
 2c8:	4501                	li	a0,0
 2ca:	bfe5                	j	2c2 <atoi+0x3e>

00000000000002cc <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 2cc:	1141                	addi	sp,sp,-16
 2ce:	e422                	sd	s0,8(sp)
 2d0:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 2d2:	02b57463          	bgeu	a0,a1,2fa <memmove+0x2e>
    while(n-- > 0)
 2d6:	00c05f63          	blez	a2,2f4 <memmove+0x28>
 2da:	1602                	slli	a2,a2,0x20
 2dc:	9201                	srli	a2,a2,0x20
 2de:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 2e2:	872a                	mv	a4,a0
      *dst++ = *src++;
 2e4:	0585                	addi	a1,a1,1
 2e6:	0705                	addi	a4,a4,1
 2e8:	fff5c683          	lbu	a3,-1(a1)
 2ec:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 2f0:	fee79ae3          	bne	a5,a4,2e4 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 2f4:	6422                	ld	s0,8(sp)
 2f6:	0141                	addi	sp,sp,16
 2f8:	8082                	ret
    dst += n;
 2fa:	00c50733          	add	a4,a0,a2
    src += n;
 2fe:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 300:	fec05ae3          	blez	a2,2f4 <memmove+0x28>
 304:	fff6079b          	addiw	a5,a2,-1
 308:	1782                	slli	a5,a5,0x20
 30a:	9381                	srli	a5,a5,0x20
 30c:	fff7c793          	not	a5,a5
 310:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 312:	15fd                	addi	a1,a1,-1
 314:	177d                	addi	a4,a4,-1
 316:	0005c683          	lbu	a3,0(a1)
 31a:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 31e:	fee79ae3          	bne	a5,a4,312 <memmove+0x46>
 322:	bfc9                	j	2f4 <memmove+0x28>

0000000000000324 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 324:	1141                	addi	sp,sp,-16
 326:	e422                	sd	s0,8(sp)
 328:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 32a:	ca05                	beqz	a2,35a <memcmp+0x36>
 32c:	fff6069b          	addiw	a3,a2,-1
 330:	1682                	slli	a3,a3,0x20
 332:	9281                	srli	a3,a3,0x20
 334:	0685                	addi	a3,a3,1
 336:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 338:	00054783          	lbu	a5,0(a0)
 33c:	0005c703          	lbu	a4,0(a1)
 340:	00e79863          	bne	a5,a4,350 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 344:	0505                	addi	a0,a0,1
    p2++;
 346:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 348:	fed518e3          	bne	a0,a3,338 <memcmp+0x14>
  }
  return 0;
 34c:	4501                	li	a0,0
 34e:	a019                	j	354 <memcmp+0x30>
      return *p1 - *p2;
 350:	40e7853b          	subw	a0,a5,a4
}
 354:	6422                	ld	s0,8(sp)
 356:	0141                	addi	sp,sp,16
 358:	8082                	ret
  return 0;
 35a:	4501                	li	a0,0
 35c:	bfe5                	j	354 <memcmp+0x30>

000000000000035e <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 35e:	1141                	addi	sp,sp,-16
 360:	e406                	sd	ra,8(sp)
 362:	e022                	sd	s0,0(sp)
 364:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 366:	00000097          	auipc	ra,0x0
 36a:	f66080e7          	jalr	-154(ra) # 2cc <memmove>
}
 36e:	60a2                	ld	ra,8(sp)
 370:	6402                	ld	s0,0(sp)
 372:	0141                	addi	sp,sp,16
 374:	8082                	ret

0000000000000376 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 376:	4885                	li	a7,1
 ecall
 378:	00000073          	ecall
 ret
 37c:	8082                	ret

000000000000037e <exit>:
.global exit
exit:
 li a7, SYS_exit
 37e:	4889                	li	a7,2
 ecall
 380:	00000073          	ecall
 ret
 384:	8082                	ret

0000000000000386 <wait>:
.global wait
wait:
 li a7, SYS_wait
 386:	488d                	li	a7,3
 ecall
 388:	00000073          	ecall
 ret
 38c:	8082                	ret

000000000000038e <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 38e:	4891                	li	a7,4
 ecall
 390:	00000073          	ecall
 ret
 394:	8082                	ret

0000000000000396 <read>:
.global read
read:
 li a7, SYS_read
 396:	4895                	li	a7,5
 ecall
 398:	00000073          	ecall
 ret
 39c:	8082                	ret

000000000000039e <write>:
.global write
write:
 li a7, SYS_write
 39e:	48c1                	li	a7,16
 ecall
 3a0:	00000073          	ecall
 ret
 3a4:	8082                	ret

00000000000003a6 <close>:
.global close
close:
 li a7, SYS_close
 3a6:	48d5                	li	a7,21
 ecall
 3a8:	00000073          	ecall
 ret
 3ac:	8082                	ret

00000000000003ae <kill>:
.global kill
kill:
 li a7, SYS_kill
 3ae:	4899                	li	a7,6
 ecall
 3b0:	00000073          	ecall
 ret
 3b4:	8082                	ret

00000000000003b6 <exec>:
.global exec
exec:
 li a7, SYS_exec
 3b6:	489d                	li	a7,7
 ecall
 3b8:	00000073          	ecall
 ret
 3bc:	8082                	ret

00000000000003be <open>:
.global open
open:
 li a7, SYS_open
 3be:	48bd                	li	a7,15
 ecall
 3c0:	00000073          	ecall
 ret
 3c4:	8082                	ret

00000000000003c6 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 3c6:	48c5                	li	a7,17
 ecall
 3c8:	00000073          	ecall
 ret
 3cc:	8082                	ret

00000000000003ce <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 3ce:	48c9                	li	a7,18
 ecall
 3d0:	00000073          	ecall
 ret
 3d4:	8082                	ret

00000000000003d6 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 3d6:	48a1                	li	a7,8
 ecall
 3d8:	00000073          	ecall
 ret
 3dc:	8082                	ret

00000000000003de <link>:
.global link
link:
 li a7, SYS_link
 3de:	48cd                	li	a7,19
 ecall
 3e0:	00000073          	ecall
 ret
 3e4:	8082                	ret

00000000000003e6 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 3e6:	48d1                	li	a7,20
 ecall
 3e8:	00000073          	ecall
 ret
 3ec:	8082                	ret

00000000000003ee <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 3ee:	48a5                	li	a7,9
 ecall
 3f0:	00000073          	ecall
 ret
 3f4:	8082                	ret

00000000000003f6 <dup>:
.global dup
dup:
 li a7, SYS_dup
 3f6:	48a9                	li	a7,10
 ecall
 3f8:	00000073          	ecall
 ret
 3fc:	8082                	ret

00000000000003fe <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 3fe:	48ad                	li	a7,11
 ecall
 400:	00000073          	ecall
 ret
 404:	8082                	ret

0000000000000406 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 406:	48b1                	li	a7,12
 ecall
 408:	00000073          	ecall
 ret
 40c:	8082                	ret

000000000000040e <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 40e:	48b5                	li	a7,13
 ecall
 410:	00000073          	ecall
 ret
 414:	8082                	ret

0000000000000416 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 416:	48b9                	li	a7,14
 ecall
 418:	00000073          	ecall
 ret
 41c:	8082                	ret

000000000000041e <ctime>:
.global ctime
ctime:
 li a7, SYS_ctime
 41e:	48d9                	li	a7,22
 ecall
 420:	00000073          	ecall
 ret
 424:	8082                	ret

0000000000000426 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 426:	1101                	addi	sp,sp,-32
 428:	ec06                	sd	ra,24(sp)
 42a:	e822                	sd	s0,16(sp)
 42c:	1000                	addi	s0,sp,32
 42e:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 432:	4605                	li	a2,1
 434:	fef40593          	addi	a1,s0,-17
 438:	00000097          	auipc	ra,0x0
 43c:	f66080e7          	jalr	-154(ra) # 39e <write>
}
 440:	60e2                	ld	ra,24(sp)
 442:	6442                	ld	s0,16(sp)
 444:	6105                	addi	sp,sp,32
 446:	8082                	ret

0000000000000448 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 448:	7139                	addi	sp,sp,-64
 44a:	fc06                	sd	ra,56(sp)
 44c:	f822                	sd	s0,48(sp)
 44e:	f426                	sd	s1,40(sp)
 450:	f04a                	sd	s2,32(sp)
 452:	ec4e                	sd	s3,24(sp)
 454:	0080                	addi	s0,sp,64
 456:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 458:	c299                	beqz	a3,45e <printint+0x16>
 45a:	0805c963          	bltz	a1,4ec <printint+0xa4>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 45e:	2581                	sext.w	a1,a1
  neg = 0;
 460:	4881                	li	a7,0
 462:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 466:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 468:	2601                	sext.w	a2,a2
 46a:	00001517          	auipc	a0,0x1
 46e:	a5e50513          	addi	a0,a0,-1442 # ec8 <digits>
 472:	883a                	mv	a6,a4
 474:	2705                	addiw	a4,a4,1
 476:	02c5f7bb          	remuw	a5,a1,a2
 47a:	1782                	slli	a5,a5,0x20
 47c:	9381                	srli	a5,a5,0x20
 47e:	97aa                	add	a5,a5,a0
 480:	0007c783          	lbu	a5,0(a5)
 484:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 488:	0005879b          	sext.w	a5,a1
 48c:	02c5d5bb          	divuw	a1,a1,a2
 490:	0685                	addi	a3,a3,1
 492:	fec7f0e3          	bgeu	a5,a2,472 <printint+0x2a>
  if(neg)
 496:	00088c63          	beqz	a7,4ae <printint+0x66>
    buf[i++] = '-';
 49a:	fd070793          	addi	a5,a4,-48
 49e:	00878733          	add	a4,a5,s0
 4a2:	02d00793          	li	a5,45
 4a6:	fef70823          	sb	a5,-16(a4)
 4aa:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 4ae:	02e05863          	blez	a4,4de <printint+0x96>
 4b2:	fc040793          	addi	a5,s0,-64
 4b6:	00e78933          	add	s2,a5,a4
 4ba:	fff78993          	addi	s3,a5,-1
 4be:	99ba                	add	s3,s3,a4
 4c0:	377d                	addiw	a4,a4,-1
 4c2:	1702                	slli	a4,a4,0x20
 4c4:	9301                	srli	a4,a4,0x20
 4c6:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 4ca:	fff94583          	lbu	a1,-1(s2)
 4ce:	8526                	mv	a0,s1
 4d0:	00000097          	auipc	ra,0x0
 4d4:	f56080e7          	jalr	-170(ra) # 426 <putc>
  while(--i >= 0)
 4d8:	197d                	addi	s2,s2,-1
 4da:	ff3918e3          	bne	s2,s3,4ca <printint+0x82>
}
 4de:	70e2                	ld	ra,56(sp)
 4e0:	7442                	ld	s0,48(sp)
 4e2:	74a2                	ld	s1,40(sp)
 4e4:	7902                	ld	s2,32(sp)
 4e6:	69e2                	ld	s3,24(sp)
 4e8:	6121                	addi	sp,sp,64
 4ea:	8082                	ret
    x = -xx;
 4ec:	40b005bb          	negw	a1,a1
    neg = 1;
 4f0:	4885                	li	a7,1
    x = -xx;
 4f2:	bf85                	j	462 <printint+0x1a>

00000000000004f4 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 4f4:	715d                	addi	sp,sp,-80
 4f6:	e486                	sd	ra,72(sp)
 4f8:	e0a2                	sd	s0,64(sp)
 4fa:	fc26                	sd	s1,56(sp)
 4fc:	f84a                	sd	s2,48(sp)
 4fe:	f44e                	sd	s3,40(sp)
 500:	f052                	sd	s4,32(sp)
 502:	ec56                	sd	s5,24(sp)
 504:	e85a                	sd	s6,16(sp)
 506:	e45e                	sd	s7,8(sp)
 508:	e062                	sd	s8,0(sp)
 50a:	0880                	addi	s0,sp,80
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 50c:	0005c903          	lbu	s2,0(a1)
 510:	18090c63          	beqz	s2,6a8 <vprintf+0x1b4>
 514:	8aaa                	mv	s5,a0
 516:	8bb2                	mv	s7,a2
 518:	00158493          	addi	s1,a1,1
  state = 0;
 51c:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 51e:	02500a13          	li	s4,37
 522:	4b55                	li	s6,21
 524:	a839                	j	542 <vprintf+0x4e>
        putc(fd, c);
 526:	85ca                	mv	a1,s2
 528:	8556                	mv	a0,s5
 52a:	00000097          	auipc	ra,0x0
 52e:	efc080e7          	jalr	-260(ra) # 426 <putc>
 532:	a019                	j	538 <vprintf+0x44>
    } else if(state == '%'){
 534:	01498d63          	beq	s3,s4,54e <vprintf+0x5a>
  for(i = 0; fmt[i]; i++){
 538:	0485                	addi	s1,s1,1
 53a:	fff4c903          	lbu	s2,-1(s1)
 53e:	16090563          	beqz	s2,6a8 <vprintf+0x1b4>
    if(state == 0){
 542:	fe0999e3          	bnez	s3,534 <vprintf+0x40>
      if(c == '%'){
 546:	ff4910e3          	bne	s2,s4,526 <vprintf+0x32>
        state = '%';
 54a:	89d2                	mv	s3,s4
 54c:	b7f5                	j	538 <vprintf+0x44>
      if(c == 'd'){
 54e:	13490263          	beq	s2,s4,672 <vprintf+0x17e>
 552:	f9d9079b          	addiw	a5,s2,-99
 556:	0ff7f793          	zext.b	a5,a5
 55a:	12fb6563          	bltu	s6,a5,684 <vprintf+0x190>
 55e:	f9d9079b          	addiw	a5,s2,-99
 562:	0ff7f713          	zext.b	a4,a5
 566:	10eb6f63          	bltu	s6,a4,684 <vprintf+0x190>
 56a:	00271793          	slli	a5,a4,0x2
 56e:	00001717          	auipc	a4,0x1
 572:	90270713          	addi	a4,a4,-1790 # e70 <ulthread_context_switch+0x104>
 576:	97ba                	add	a5,a5,a4
 578:	439c                	lw	a5,0(a5)
 57a:	97ba                	add	a5,a5,a4
 57c:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
 57e:	008b8913          	addi	s2,s7,8
 582:	4685                	li	a3,1
 584:	4629                	li	a2,10
 586:	000ba583          	lw	a1,0(s7)
 58a:	8556                	mv	a0,s5
 58c:	00000097          	auipc	ra,0x0
 590:	ebc080e7          	jalr	-324(ra) # 448 <printint>
 594:	8bca                	mv	s7,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 596:	4981                	li	s3,0
 598:	b745                	j	538 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 59a:	008b8913          	addi	s2,s7,8
 59e:	4681                	li	a3,0
 5a0:	4629                	li	a2,10
 5a2:	000ba583          	lw	a1,0(s7)
 5a6:	8556                	mv	a0,s5
 5a8:	00000097          	auipc	ra,0x0
 5ac:	ea0080e7          	jalr	-352(ra) # 448 <printint>
 5b0:	8bca                	mv	s7,s2
      state = 0;
 5b2:	4981                	li	s3,0
 5b4:	b751                	j	538 <vprintf+0x44>
        printint(fd, va_arg(ap, int), 16, 0);
 5b6:	008b8913          	addi	s2,s7,8
 5ba:	4681                	li	a3,0
 5bc:	4641                	li	a2,16
 5be:	000ba583          	lw	a1,0(s7)
 5c2:	8556                	mv	a0,s5
 5c4:	00000097          	auipc	ra,0x0
 5c8:	e84080e7          	jalr	-380(ra) # 448 <printint>
 5cc:	8bca                	mv	s7,s2
      state = 0;
 5ce:	4981                	li	s3,0
 5d0:	b7a5                	j	538 <vprintf+0x44>
        printptr(fd, va_arg(ap, uint64));
 5d2:	008b8c13          	addi	s8,s7,8
 5d6:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 5da:	03000593          	li	a1,48
 5de:	8556                	mv	a0,s5
 5e0:	00000097          	auipc	ra,0x0
 5e4:	e46080e7          	jalr	-442(ra) # 426 <putc>
  putc(fd, 'x');
 5e8:	07800593          	li	a1,120
 5ec:	8556                	mv	a0,s5
 5ee:	00000097          	auipc	ra,0x0
 5f2:	e38080e7          	jalr	-456(ra) # 426 <putc>
 5f6:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 5f8:	00001b97          	auipc	s7,0x1
 5fc:	8d0b8b93          	addi	s7,s7,-1840 # ec8 <digits>
 600:	03c9d793          	srli	a5,s3,0x3c
 604:	97de                	add	a5,a5,s7
 606:	0007c583          	lbu	a1,0(a5)
 60a:	8556                	mv	a0,s5
 60c:	00000097          	auipc	ra,0x0
 610:	e1a080e7          	jalr	-486(ra) # 426 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 614:	0992                	slli	s3,s3,0x4
 616:	397d                	addiw	s2,s2,-1
 618:	fe0914e3          	bnez	s2,600 <vprintf+0x10c>
        printptr(fd, va_arg(ap, uint64));
 61c:	8be2                	mv	s7,s8
      state = 0;
 61e:	4981                	li	s3,0
 620:	bf21                	j	538 <vprintf+0x44>
        s = va_arg(ap, char*);
 622:	008b8993          	addi	s3,s7,8
 626:	000bb903          	ld	s2,0(s7)
        if(s == 0)
 62a:	02090163          	beqz	s2,64c <vprintf+0x158>
        while(*s != 0){
 62e:	00094583          	lbu	a1,0(s2)
 632:	c9a5                	beqz	a1,6a2 <vprintf+0x1ae>
          putc(fd, *s);
 634:	8556                	mv	a0,s5
 636:	00000097          	auipc	ra,0x0
 63a:	df0080e7          	jalr	-528(ra) # 426 <putc>
          s++;
 63e:	0905                	addi	s2,s2,1
        while(*s != 0){
 640:	00094583          	lbu	a1,0(s2)
 644:	f9e5                	bnez	a1,634 <vprintf+0x140>
        s = va_arg(ap, char*);
 646:	8bce                	mv	s7,s3
      state = 0;
 648:	4981                	li	s3,0
 64a:	b5fd                	j	538 <vprintf+0x44>
          s = "(null)";
 64c:	00001917          	auipc	s2,0x1
 650:	81c90913          	addi	s2,s2,-2020 # e68 <ulthread_context_switch+0xfc>
        while(*s != 0){
 654:	02800593          	li	a1,40
 658:	bff1                	j	634 <vprintf+0x140>
        putc(fd, va_arg(ap, uint));
 65a:	008b8913          	addi	s2,s7,8
 65e:	000bc583          	lbu	a1,0(s7)
 662:	8556                	mv	a0,s5
 664:	00000097          	auipc	ra,0x0
 668:	dc2080e7          	jalr	-574(ra) # 426 <putc>
 66c:	8bca                	mv	s7,s2
      state = 0;
 66e:	4981                	li	s3,0
 670:	b5e1                	j	538 <vprintf+0x44>
        putc(fd, c);
 672:	02500593          	li	a1,37
 676:	8556                	mv	a0,s5
 678:	00000097          	auipc	ra,0x0
 67c:	dae080e7          	jalr	-594(ra) # 426 <putc>
      state = 0;
 680:	4981                	li	s3,0
 682:	bd5d                	j	538 <vprintf+0x44>
        putc(fd, '%');
 684:	02500593          	li	a1,37
 688:	8556                	mv	a0,s5
 68a:	00000097          	auipc	ra,0x0
 68e:	d9c080e7          	jalr	-612(ra) # 426 <putc>
        putc(fd, c);
 692:	85ca                	mv	a1,s2
 694:	8556                	mv	a0,s5
 696:	00000097          	auipc	ra,0x0
 69a:	d90080e7          	jalr	-624(ra) # 426 <putc>
      state = 0;
 69e:	4981                	li	s3,0
 6a0:	bd61                	j	538 <vprintf+0x44>
        s = va_arg(ap, char*);
 6a2:	8bce                	mv	s7,s3
      state = 0;
 6a4:	4981                	li	s3,0
 6a6:	bd49                	j	538 <vprintf+0x44>
    }
  }
}
 6a8:	60a6                	ld	ra,72(sp)
 6aa:	6406                	ld	s0,64(sp)
 6ac:	74e2                	ld	s1,56(sp)
 6ae:	7942                	ld	s2,48(sp)
 6b0:	79a2                	ld	s3,40(sp)
 6b2:	7a02                	ld	s4,32(sp)
 6b4:	6ae2                	ld	s5,24(sp)
 6b6:	6b42                	ld	s6,16(sp)
 6b8:	6ba2                	ld	s7,8(sp)
 6ba:	6c02                	ld	s8,0(sp)
 6bc:	6161                	addi	sp,sp,80
 6be:	8082                	ret

00000000000006c0 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 6c0:	715d                	addi	sp,sp,-80
 6c2:	ec06                	sd	ra,24(sp)
 6c4:	e822                	sd	s0,16(sp)
 6c6:	1000                	addi	s0,sp,32
 6c8:	e010                	sd	a2,0(s0)
 6ca:	e414                	sd	a3,8(s0)
 6cc:	e818                	sd	a4,16(s0)
 6ce:	ec1c                	sd	a5,24(s0)
 6d0:	03043023          	sd	a6,32(s0)
 6d4:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 6d8:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 6dc:	8622                	mv	a2,s0
 6de:	00000097          	auipc	ra,0x0
 6e2:	e16080e7          	jalr	-490(ra) # 4f4 <vprintf>
}
 6e6:	60e2                	ld	ra,24(sp)
 6e8:	6442                	ld	s0,16(sp)
 6ea:	6161                	addi	sp,sp,80
 6ec:	8082                	ret

00000000000006ee <printf>:

void
printf(const char *fmt, ...)
{
 6ee:	711d                	addi	sp,sp,-96
 6f0:	ec06                	sd	ra,24(sp)
 6f2:	e822                	sd	s0,16(sp)
 6f4:	1000                	addi	s0,sp,32
 6f6:	e40c                	sd	a1,8(s0)
 6f8:	e810                	sd	a2,16(s0)
 6fa:	ec14                	sd	a3,24(s0)
 6fc:	f018                	sd	a4,32(s0)
 6fe:	f41c                	sd	a5,40(s0)
 700:	03043823          	sd	a6,48(s0)
 704:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 708:	00840613          	addi	a2,s0,8
 70c:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 710:	85aa                	mv	a1,a0
 712:	4505                	li	a0,1
 714:	00000097          	auipc	ra,0x0
 718:	de0080e7          	jalr	-544(ra) # 4f4 <vprintf>
}
 71c:	60e2                	ld	ra,24(sp)
 71e:	6442                	ld	s0,16(sp)
 720:	6125                	addi	sp,sp,96
 722:	8082                	ret

0000000000000724 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 724:	1141                	addi	sp,sp,-16
 726:	e422                	sd	s0,8(sp)
 728:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 72a:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 72e:	00001797          	auipc	a5,0x1
 732:	8e27b783          	ld	a5,-1822(a5) # 1010 <freep>
 736:	a02d                	j	760 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 738:	4618                	lw	a4,8(a2)
 73a:	9f2d                	addw	a4,a4,a1
 73c:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 740:	6398                	ld	a4,0(a5)
 742:	6310                	ld	a2,0(a4)
 744:	a83d                	j	782 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 746:	ff852703          	lw	a4,-8(a0)
 74a:	9f31                	addw	a4,a4,a2
 74c:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 74e:	ff053683          	ld	a3,-16(a0)
 752:	a091                	j	796 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 754:	6398                	ld	a4,0(a5)
 756:	00e7e463          	bltu	a5,a4,75e <free+0x3a>
 75a:	00e6ea63          	bltu	a3,a4,76e <free+0x4a>
{
 75e:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 760:	fed7fae3          	bgeu	a5,a3,754 <free+0x30>
 764:	6398                	ld	a4,0(a5)
 766:	00e6e463          	bltu	a3,a4,76e <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 76a:	fee7eae3          	bltu	a5,a4,75e <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 76e:	ff852583          	lw	a1,-8(a0)
 772:	6390                	ld	a2,0(a5)
 774:	02059813          	slli	a6,a1,0x20
 778:	01c85713          	srli	a4,a6,0x1c
 77c:	9736                	add	a4,a4,a3
 77e:	fae60de3          	beq	a2,a4,738 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 782:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 786:	4790                	lw	a2,8(a5)
 788:	02061593          	slli	a1,a2,0x20
 78c:	01c5d713          	srli	a4,a1,0x1c
 790:	973e                	add	a4,a4,a5
 792:	fae68ae3          	beq	a3,a4,746 <free+0x22>
    p->s.ptr = bp->s.ptr;
 796:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 798:	00001717          	auipc	a4,0x1
 79c:	86f73c23          	sd	a5,-1928(a4) # 1010 <freep>
}
 7a0:	6422                	ld	s0,8(sp)
 7a2:	0141                	addi	sp,sp,16
 7a4:	8082                	ret

00000000000007a6 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 7a6:	7139                	addi	sp,sp,-64
 7a8:	fc06                	sd	ra,56(sp)
 7aa:	f822                	sd	s0,48(sp)
 7ac:	f426                	sd	s1,40(sp)
 7ae:	f04a                	sd	s2,32(sp)
 7b0:	ec4e                	sd	s3,24(sp)
 7b2:	e852                	sd	s4,16(sp)
 7b4:	e456                	sd	s5,8(sp)
 7b6:	e05a                	sd	s6,0(sp)
 7b8:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 7ba:	02051493          	slli	s1,a0,0x20
 7be:	9081                	srli	s1,s1,0x20
 7c0:	04bd                	addi	s1,s1,15
 7c2:	8091                	srli	s1,s1,0x4
 7c4:	0014899b          	addiw	s3,s1,1
 7c8:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 7ca:	00001517          	auipc	a0,0x1
 7ce:	84653503          	ld	a0,-1978(a0) # 1010 <freep>
 7d2:	c515                	beqz	a0,7fe <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 7d4:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 7d6:	4798                	lw	a4,8(a5)
 7d8:	02977f63          	bgeu	a4,s1,816 <malloc+0x70>
  if(nu < 4096)
 7dc:	8a4e                	mv	s4,s3
 7de:	0009871b          	sext.w	a4,s3
 7e2:	6685                	lui	a3,0x1
 7e4:	00d77363          	bgeu	a4,a3,7ea <malloc+0x44>
 7e8:	6a05                	lui	s4,0x1
 7ea:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 7ee:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 7f2:	00001917          	auipc	s2,0x1
 7f6:	81e90913          	addi	s2,s2,-2018 # 1010 <freep>
  if(p == (char*)-1)
 7fa:	5afd                	li	s5,-1
 7fc:	a895                	j	870 <malloc+0xca>
    base.s.ptr = freep = prevp = &base;
 7fe:	00001797          	auipc	a5,0x1
 802:	83278793          	addi	a5,a5,-1998 # 1030 <base>
 806:	00001717          	auipc	a4,0x1
 80a:	80f73523          	sd	a5,-2038(a4) # 1010 <freep>
 80e:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 810:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 814:	b7e1                	j	7dc <malloc+0x36>
      if(p->s.size == nunits)
 816:	02e48c63          	beq	s1,a4,84e <malloc+0xa8>
        p->s.size -= nunits;
 81a:	4137073b          	subw	a4,a4,s3
 81e:	c798                	sw	a4,8(a5)
        p += p->s.size;
 820:	02071693          	slli	a3,a4,0x20
 824:	01c6d713          	srli	a4,a3,0x1c
 828:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 82a:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 82e:	00000717          	auipc	a4,0x0
 832:	7ea73123          	sd	a0,2018(a4) # 1010 <freep>
      return (void*)(p + 1);
 836:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 83a:	70e2                	ld	ra,56(sp)
 83c:	7442                	ld	s0,48(sp)
 83e:	74a2                	ld	s1,40(sp)
 840:	7902                	ld	s2,32(sp)
 842:	69e2                	ld	s3,24(sp)
 844:	6a42                	ld	s4,16(sp)
 846:	6aa2                	ld	s5,8(sp)
 848:	6b02                	ld	s6,0(sp)
 84a:	6121                	addi	sp,sp,64
 84c:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 84e:	6398                	ld	a4,0(a5)
 850:	e118                	sd	a4,0(a0)
 852:	bff1                	j	82e <malloc+0x88>
  hp->s.size = nu;
 854:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 858:	0541                	addi	a0,a0,16
 85a:	00000097          	auipc	ra,0x0
 85e:	eca080e7          	jalr	-310(ra) # 724 <free>
  return freep;
 862:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 866:	d971                	beqz	a0,83a <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 868:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 86a:	4798                	lw	a4,8(a5)
 86c:	fa9775e3          	bgeu	a4,s1,816 <malloc+0x70>
    if(p == freep)
 870:	00093703          	ld	a4,0(s2)
 874:	853e                	mv	a0,a5
 876:	fef719e3          	bne	a4,a5,868 <malloc+0xc2>
  p = sbrk(nu * sizeof(Header));
 87a:	8552                	mv	a0,s4
 87c:	00000097          	auipc	ra,0x0
 880:	b8a080e7          	jalr	-1142(ra) # 406 <sbrk>
  if(p == (char*)-1)
 884:	fd5518e3          	bne	a0,s5,854 <malloc+0xae>
        return 0;
 888:	4501                	li	a0,0
 88a:	bf45                	j	83a <malloc+0x94>

000000000000088c <get_current_tid>:
struct ulthread *scheduler_thread;
enum ulthread_scheduling_algorithm algorithm;

/* Get thread ID */
int get_current_tid(void)
{
 88c:	1141                	addi	sp,sp,-16
 88e:	e422                	sd	s0,8(sp)
 890:	0800                	addi	s0,sp,16
  return current_thread->tid;
}
 892:	00000797          	auipc	a5,0x0
 896:	7967b783          	ld	a5,1942(a5) # 1028 <current_thread>
 89a:	43c8                	lw	a0,4(a5)
 89c:	6422                	ld	s0,8(sp)
 89e:	0141                	addi	sp,sp,16
 8a0:	8082                	ret

00000000000008a2 <roundRobin>:

void roundRobin(void)
{
 8a2:	715d                	addi	sp,sp,-80
 8a4:	e486                	sd	ra,72(sp)
 8a6:	e0a2                	sd	s0,64(sp)
 8a8:	fc26                	sd	s1,56(sp)
 8aa:	f84a                	sd	s2,48(sp)
 8ac:	f44e                	sd	s3,40(sp)
 8ae:	f052                	sd	s4,32(sp)
 8b0:	ec56                	sd	s5,24(sp)
 8b2:	e85a                	sd	s6,16(sp)
 8b4:	e45e                	sd	s7,8(sp)
 8b6:	e062                	sd	s8,0(sp)
 8b8:	0880                	addi	s0,sp,80
        struct ulthread *temp = current_thread;
        current_thread = t;
        printf("[*] ultschedule (next tid: %d)\n", get_current_tid());
        ulthread_context_switch(&temp->context, &t->context);
      }
      if (t->state == YIELD)
 8ba:	4a09                	li	s4,2
      if (t->state == RUNNABLE && t != scheduler_thread)
 8bc:	00000b97          	auipc	s7,0x0
 8c0:	764b8b93          	addi	s7,s7,1892 # 1020 <scheduler_thread>
        struct ulthread *temp = current_thread;
 8c4:	00000a97          	auipc	s5,0x0
 8c8:	764a8a93          	addi	s5,s5,1892 # 1028 <current_thread>
        printf("[*] ultschedule (next tid: %d)\n", get_current_tid());
 8cc:	00000c17          	auipc	s8,0x0
 8d0:	614c0c13          	addi	s8,s8,1556 # ee0 <digits+0x18>
    for (t = ulthreads; t < &ulthreads[MAXULTHREADS]; t++)
 8d4:	00004997          	auipc	s3,0x4
 8d8:	c8c98993          	addi	s3,s3,-884 # 4560 <ulthreads+0x3520>
 8dc:	a0b9                	j	92a <roundRobin+0x88>
      if (t->state == RUNNABLE && t != scheduler_thread)
 8de:	000bb783          	ld	a5,0(s7)
 8e2:	02978863          	beq	a5,s1,912 <roundRobin+0x70>
        struct ulthread *temp = current_thread;
 8e6:	000abb03          	ld	s6,0(s5)
        current_thread = t;
 8ea:	009ab023          	sd	s1,0(s5)
        printf("[*] ultschedule (next tid: %d)\n", get_current_tid());
 8ee:	40cc                	lw	a1,4(s1)
 8f0:	8562                	mv	a0,s8
 8f2:	00000097          	auipc	ra,0x0
 8f6:	dfc080e7          	jalr	-516(ra) # 6ee <printf>
        ulthread_context_switch(&temp->context, &t->context);
 8fa:	01848593          	addi	a1,s1,24
 8fe:	018b0513          	addi	a0,s6,24
 902:	00000097          	auipc	ra,0x0
 906:	46a080e7          	jalr	1130(ra) # d6c <ulthread_context_switch>
        threadAvailable = true;
 90a:	874a                	mv	a4,s2
 90c:	a811                	j	920 <roundRobin+0x7e>
      {
        t->state = RUNNABLE;
 90e:	0124a023          	sw	s2,0(s1)
    for (t = ulthreads; t < &ulthreads[MAXULTHREADS]; t++)
 912:	08848493          	addi	s1,s1,136
 916:	01348963          	beq	s1,s3,928 <roundRobin+0x86>
      if (t->state == RUNNABLE && t != scheduler_thread)
 91a:	409c                	lw	a5,0(s1)
 91c:	fd2781e3          	beq	a5,s2,8de <roundRobin+0x3c>
      if (t->state == YIELD)
 920:	409c                	lw	a5,0(s1)
 922:	ff4798e3          	bne	a5,s4,912 <roundRobin+0x70>
 926:	b7e5                	j	90e <roundRobin+0x6c>
      }
    }
    if (!threadAvailable)
 928:	cb01                	beqz	a4,938 <roundRobin+0x96>
    bool threadAvailable = false;
 92a:	4701                	li	a4,0
    for (t = ulthreads; t < &ulthreads[MAXULTHREADS]; t++)
 92c:	00000497          	auipc	s1,0x0
 930:	71448493          	addi	s1,s1,1812 # 1040 <ulthreads>
      if (t->state == RUNNABLE && t != scheduler_thread)
 934:	4905                	li	s2,1
 936:	b7d5                	j	91a <roundRobin+0x78>
    {
      break;
    }
  }
}
 938:	60a6                	ld	ra,72(sp)
 93a:	6406                	ld	s0,64(sp)
 93c:	74e2                	ld	s1,56(sp)
 93e:	7942                	ld	s2,48(sp)
 940:	79a2                	ld	s3,40(sp)
 942:	7a02                	ld	s4,32(sp)
 944:	6ae2                	ld	s5,24(sp)
 946:	6b42                	ld	s6,16(sp)
 948:	6ba2                	ld	s7,8(sp)
 94a:	6c02                	ld	s8,0(sp)
 94c:	6161                	addi	sp,sp,80
 94e:	8082                	ret

0000000000000950 <firstComeFirstServe>:

void firstComeFirstServe(void)
{
 950:	715d                	addi	sp,sp,-80
 952:	e486                	sd	ra,72(sp)
 954:	e0a2                	sd	s0,64(sp)
 956:	fc26                	sd	s1,56(sp)
 958:	f84a                	sd	s2,48(sp)
 95a:	f44e                	sd	s3,40(sp)
 95c:	f052                	sd	s4,32(sp)
 95e:	ec56                	sd	s5,24(sp)
 960:	e85a                	sd	s6,16(sp)
 962:	e45e                	sd	s7,8(sp)
 964:	e062                	sd	s8,0(sp)
 966:	0880                	addi	s0,sp,80
    uint64 oldest = __INT64_MAX__;
    int threadIndex = -1;
    int alternativeIndex = -1;
    for (t = ulthreads+1; t < &ulthreads[MAXULTHREADS]; t++)
    {
      if (t->state == RUNNABLE && t != scheduler_thread && t->lastTime < oldest)
 968:	00000b97          	auipc	s7,0x0
 96c:	6b8b8b93          	addi	s7,s7,1720 # 1020 <scheduler_thread>
    int alternativeIndex = -1;
 970:	5afd                	li	s5,-1
    uint64 oldest = __INT64_MAX__;
 972:	001adb13          	srli	s6,s5,0x1
      if (t->state == RUNNABLE && t != scheduler_thread && t->lastTime < oldest)
 976:	4485                	li	s1,1
        oldest = t->lastTime;
        threadIndex = t->tid;
        threadAvailable = true;
      }

      if (t->state == YIELD){
 978:	4989                	li	s3,2
    for (t = ulthreads+1; t < &ulthreads[MAXULTHREADS]; t++)
 97a:	00004917          	auipc	s2,0x4
 97e:	be690913          	addi	s2,s2,-1050 # 4560 <ulthreads+0x3520>
        break;
      }
      
    }
    label : 
      struct ulthread *temp = current_thread;
 982:	00000a17          	auipc	s4,0x0
 986:	6a6a0a13          	addi	s4,s4,1702 # 1028 <current_thread>
 98a:	a88d                	j	9fc <firstComeFirstServe+0xac>
      if (t->state == RUNNABLE && t != scheduler_thread && t->lastTime < oldest)
 98c:	00f58963          	beq	a1,a5,99e <firstComeFirstServe+0x4e>
 990:	6b98                	ld	a4,16(a5)
 992:	00c77663          	bgeu	a4,a2,99e <firstComeFirstServe+0x4e>
        threadIndex = t->tid;
 996:	0047a803          	lw	a6,4(a5)
        oldest = t->lastTime;
 99a:	863a                	mv	a2,a4
        threadAvailable = true;
 99c:	8526                	mv	a0,s1
    for (t = ulthreads+1; t < &ulthreads[MAXULTHREADS]; t++)
 99e:	08878793          	addi	a5,a5,136
 9a2:	01278a63          	beq	a5,s2,9b6 <firstComeFirstServe+0x66>
      if (t->state == RUNNABLE && t != scheduler_thread && t->lastTime < oldest)
 9a6:	4398                	lw	a4,0(a5)
 9a8:	fe9702e3          	beq	a4,s1,98c <firstComeFirstServe+0x3c>
      if (t->state == YIELD){
 9ac:	ff3719e3          	bne	a4,s3,99e <firstComeFirstServe+0x4e>
        t->state = RUNNABLE;
 9b0:	c384                	sw	s1,0(a5)
        alternativeIndex = t->tid;
 9b2:	43d4                	lw	a3,4(a5)
 9b4:	b7ed                	j	99e <firstComeFirstServe+0x4e>
    if (!threadAvailable)
 9b6:	ed31                	bnez	a0,a12 <firstComeFirstServe+0xc2>
      if(alternativeIndex > 0){
 9b8:	04d05f63          	blez	a3,a16 <firstComeFirstServe+0xc6>
      struct ulthread *temp = current_thread;
 9bc:	000a3c03          	ld	s8,0(s4)
      current_thread = &ulthreads[threadIndex];
 9c0:	00469793          	slli	a5,a3,0x4
 9c4:	00d78733          	add	a4,a5,a3
 9c8:	070e                	slli	a4,a4,0x3
 9ca:	00000617          	auipc	a2,0x0
 9ce:	67660613          	addi	a2,a2,1654 # 1040 <ulthreads>
 9d2:	9732                	add	a4,a4,a2
 9d4:	00ea3023          	sd	a4,0(s4)
      printf("[*] ultschedule (next tid: %d), time = %d\n", get_current_tid());
 9d8:	434c                	lw	a1,4(a4)
 9da:	00000517          	auipc	a0,0x0
 9de:	52650513          	addi	a0,a0,1318 # f00 <digits+0x38>
 9e2:	00000097          	auipc	ra,0x0
 9e6:	d0c080e7          	jalr	-756(ra) # 6ee <printf>
      ulthread_context_switch(&temp->context, &current_thread->context);
 9ea:	000a3583          	ld	a1,0(s4)
 9ee:	05e1                	addi	a1,a1,24
 9f0:	018c0513          	addi	a0,s8,24
 9f4:	00000097          	auipc	ra,0x0
 9f8:	378080e7          	jalr	888(ra) # d6c <ulthread_context_switch>
      if (t->state == RUNNABLE && t != scheduler_thread && t->lastTime < oldest)
 9fc:	000bb583          	ld	a1,0(s7)
    int alternativeIndex = -1;
 a00:	86d6                	mv	a3,s5
    int threadIndex = -1;
 a02:	8856                	mv	a6,s5
    uint64 oldest = __INT64_MAX__;
 a04:	865a                	mv	a2,s6
    bool threadAvailable = false;
 a06:	4501                	li	a0,0
    for (t = ulthreads+1; t < &ulthreads[MAXULTHREADS]; t++)
 a08:	00000797          	auipc	a5,0x0
 a0c:	6c078793          	addi	a5,a5,1728 # 10c8 <ulthreads+0x88>
 a10:	bf59                	j	9a6 <firstComeFirstServe+0x56>
    label : 
 a12:	86c2                	mv	a3,a6
 a14:	b765                	j	9bc <firstComeFirstServe+0x6c>
  }
}
 a16:	60a6                	ld	ra,72(sp)
 a18:	6406                	ld	s0,64(sp)
 a1a:	74e2                	ld	s1,56(sp)
 a1c:	7942                	ld	s2,48(sp)
 a1e:	79a2                	ld	s3,40(sp)
 a20:	7a02                	ld	s4,32(sp)
 a22:	6ae2                	ld	s5,24(sp)
 a24:	6b42                	ld	s6,16(sp)
 a26:	6ba2                	ld	s7,8(sp)
 a28:	6c02                	ld	s8,0(sp)
 a2a:	6161                	addi	sp,sp,80
 a2c:	8082                	ret

0000000000000a2e <priorityScheduling>:


void priorityScheduling(void)
{
 a2e:	715d                	addi	sp,sp,-80
 a30:	e486                	sd	ra,72(sp)
 a32:	e0a2                	sd	s0,64(sp)
 a34:	fc26                	sd	s1,56(sp)
 a36:	f84a                	sd	s2,48(sp)
 a38:	f44e                	sd	s3,40(sp)
 a3a:	f052                	sd	s4,32(sp)
 a3c:	ec56                	sd	s5,24(sp)
 a3e:	e85a                	sd	s6,16(sp)
 a40:	e45e                	sd	s7,8(sp)
 a42:	0880                	addi	s0,sp,80
    int maxPriority = -1;
    int threadIndex = -1;
    int alternativeIndex = -1;
    for (t = ulthreads+1; t < &ulthreads[MAXULTHREADS]; t++)
    {
      if (t->state == RUNNABLE && t != scheduler_thread && t->priority > maxPriority)
 a44:	00000b17          	auipc	s6,0x0
 a48:	5dcb0b13          	addi	s6,s6,1500 # 1020 <scheduler_thread>
    int alternativeIndex = -1;
 a4c:	5a7d                	li	s4,-1
      if (t->state == RUNNABLE && t != scheduler_thread && t->priority > maxPriority)
 a4e:	4485                	li	s1,1
        // flag = true;

        // break; // switch to highest-priority thread and exit loop
      }

      if (t->state == YIELD){
 a50:	4989                	li	s3,2
    for (t = ulthreads+1; t < &ulthreads[MAXULTHREADS]; t++)
 a52:	00004917          	auipc	s2,0x4
 a56:	b0e90913          	addi	s2,s2,-1266 # 4560 <ulthreads+0x3520>
        break;
      }
      
    }
    label : 
      struct ulthread *temp = current_thread;
 a5a:	00000a97          	auipc	s5,0x0
 a5e:	5cea8a93          	addi	s5,s5,1486 # 1028 <current_thread>
 a62:	a88d                	j	ad4 <priorityScheduling+0xa6>
      if (t->state == RUNNABLE && t != scheduler_thread && t->priority > maxPriority)
 a64:	00f58963          	beq	a1,a5,a76 <priorityScheduling+0x48>
 a68:	47d8                	lw	a4,12(a5)
 a6a:	00e65663          	bge	a2,a4,a76 <priorityScheduling+0x48>
        threadIndex = t->tid;
 a6e:	0047a803          	lw	a6,4(a5)
        maxPriority = t->priority;
 a72:	863a                	mv	a2,a4
        threadAvailable = true;
 a74:	8526                	mv	a0,s1
    for (t = ulthreads+1; t < &ulthreads[MAXULTHREADS]; t++)
 a76:	08878793          	addi	a5,a5,136
 a7a:	01278a63          	beq	a5,s2,a8e <priorityScheduling+0x60>
      if (t->state == RUNNABLE && t != scheduler_thread && t->priority > maxPriority)
 a7e:	4398                	lw	a4,0(a5)
 a80:	fe9702e3          	beq	a4,s1,a64 <priorityScheduling+0x36>
      if (t->state == YIELD){
 a84:	ff3719e3          	bne	a4,s3,a76 <priorityScheduling+0x48>
        t->state = RUNNABLE;
 a88:	c384                	sw	s1,0(a5)
        alternativeIndex = t->tid;
 a8a:	43d4                	lw	a3,4(a5)
 a8c:	b7ed                	j	a76 <priorityScheduling+0x48>
    if (!threadAvailable)
 a8e:	ed31                	bnez	a0,aea <priorityScheduling+0xbc>
      if(alternativeIndex > 0){
 a90:	04d05f63          	blez	a3,aee <priorityScheduling+0xc0>
      struct ulthread *temp = current_thread;
 a94:	000abb83          	ld	s7,0(s5)
      current_thread = &ulthreads[threadIndex];
 a98:	00469793          	slli	a5,a3,0x4
 a9c:	00d78733          	add	a4,a5,a3
 aa0:	070e                	slli	a4,a4,0x3
 aa2:	00000617          	auipc	a2,0x0
 aa6:	59e60613          	addi	a2,a2,1438 # 1040 <ulthreads>
 aaa:	9732                	add	a4,a4,a2
 aac:	00eab023          	sd	a4,0(s5)
      printf("[*] ultschedule (next tid: %d)\n", get_current_tid());
 ab0:	434c                	lw	a1,4(a4)
 ab2:	00000517          	auipc	a0,0x0
 ab6:	42e50513          	addi	a0,a0,1070 # ee0 <digits+0x18>
 aba:	00000097          	auipc	ra,0x0
 abe:	c34080e7          	jalr	-972(ra) # 6ee <printf>
      ulthread_context_switch(&temp->context, &current_thread->context);
 ac2:	000ab583          	ld	a1,0(s5)
 ac6:	05e1                	addi	a1,a1,24
 ac8:	018b8513          	addi	a0,s7,24
 acc:	00000097          	auipc	ra,0x0
 ad0:	2a0080e7          	jalr	672(ra) # d6c <ulthread_context_switch>
      if (t->state == RUNNABLE && t != scheduler_thread && t->priority > maxPriority)
 ad4:	000b3583          	ld	a1,0(s6)
    int alternativeIndex = -1;
 ad8:	86d2                	mv	a3,s4
    int threadIndex = -1;
 ada:	8852                	mv	a6,s4
    int maxPriority = -1;
 adc:	8652                	mv	a2,s4
    bool threadAvailable = false;
 ade:	4501                	li	a0,0
    for (t = ulthreads+1; t < &ulthreads[MAXULTHREADS]; t++)
 ae0:	00000797          	auipc	a5,0x0
 ae4:	5e878793          	addi	a5,a5,1512 # 10c8 <ulthreads+0x88>
 ae8:	bf59                	j	a7e <priorityScheduling+0x50>
    label : 
 aea:	86c2                	mv	a3,a6
 aec:	b765                	j	a94 <priorityScheduling+0x66>
  }
}
 aee:	60a6                	ld	ra,72(sp)
 af0:	6406                	ld	s0,64(sp)
 af2:	74e2                	ld	s1,56(sp)
 af4:	7942                	ld	s2,48(sp)
 af6:	79a2                	ld	s3,40(sp)
 af8:	7a02                	ld	s4,32(sp)
 afa:	6ae2                	ld	s5,24(sp)
 afc:	6b42                	ld	s6,16(sp)
 afe:	6ba2                	ld	s7,8(sp)
 b00:	6161                	addi	sp,sp,80
 b02:	8082                	ret

0000000000000b04 <ulthread_init>:

/* Thread initialization */
void ulthread_init(int schedalgo)
{
 b04:	1141                	addi	sp,sp,-16
 b06:	e422                	sd	s0,8(sp)
 b08:	0800                	addi	s0,sp,16
  struct ulthread *t;
  int i;
  for (i = 0, t = ulthreads; t < &ulthreads[MAXULTHREADS]; t++, i++)
 b0a:	4701                	li	a4,0
 b0c:	00000797          	auipc	a5,0x0
 b10:	53478793          	addi	a5,a5,1332 # 1040 <ulthreads>
 b14:	00004697          	auipc	a3,0x4
 b18:	a4c68693          	addi	a3,a3,-1460 # 4560 <ulthreads+0x3520>
  {
    t->state = FREE;
 b1c:	0007a023          	sw	zero,0(a5)
    t->tid = i;
 b20:	c3d8                	sw	a4,4(a5)
  for (i = 0, t = ulthreads; t < &ulthreads[MAXULTHREADS]; t++, i++)
 b22:	08878793          	addi	a5,a5,136
 b26:	2705                	addiw	a4,a4,1
 b28:	fed79ae3          	bne	a5,a3,b1c <ulthread_init+0x18>
  }
  current_thread = &ulthreads[0];
 b2c:	00000797          	auipc	a5,0x0
 b30:	51478793          	addi	a5,a5,1300 # 1040 <ulthreads>
 b34:	00000717          	auipc	a4,0x0
 b38:	4ef73a23          	sd	a5,1268(a4) # 1028 <current_thread>
  scheduler_thread = &ulthreads[0];
 b3c:	00000717          	auipc	a4,0x0
 b40:	4ef73223          	sd	a5,1252(a4) # 1020 <scheduler_thread>
  scheduler_thread->state = RUNNABLE;
 b44:	4705                	li	a4,1
 b46:	c398                	sw	a4,0(a5)
  t->state = FREE;
 b48:	00004797          	auipc	a5,0x4
 b4c:	a007ac23          	sw	zero,-1512(a5) # 4560 <ulthreads+0x3520>
  algorithm = schedalgo;
 b50:	00000797          	auipc	a5,0x0
 b54:	4ca7a423          	sw	a0,1224(a5) # 1018 <algorithm>
}
 b58:	6422                	ld	s0,8(sp)
 b5a:	0141                	addi	sp,sp,16
 b5c:	8082                	ret

0000000000000b5e <ulthread_create>:

/* Thread creation */
bool ulthread_create(uint64 start, uint64 stack, uint64 args[], int priority)
{
 b5e:	7179                	addi	sp,sp,-48
 b60:	f406                	sd	ra,40(sp)
 b62:	f022                	sd	s0,32(sp)
 b64:	ec26                	sd	s1,24(sp)
 b66:	e84a                	sd	s2,16(sp)
 b68:	e44e                	sd	s3,8(sp)
 b6a:	e052                	sd	s4,0(sp)
 b6c:	1800                	addi	s0,sp,48
 b6e:	89aa                	mv	s3,a0
 b70:	8a2e                	mv	s4,a1
 b72:	8932                	mv	s2,a2
  /* Please add thread-id instead of '0' here. */
  struct ulthread *t;
  bool flag = false;
  for (t = ulthreads; t < &ulthreads[MAXULTHREADS]; t++)
 b74:	00000497          	auipc	s1,0x0
 b78:	4cc48493          	addi	s1,s1,1228 # 1040 <ulthreads>
 b7c:	00004717          	auipc	a4,0x4
 b80:	9e470713          	addi	a4,a4,-1564 # 4560 <ulthreads+0x3520>
  {
    if (t->state == FREE)
 b84:	409c                	lw	a5,0(s1)
 b86:	cf89                	beqz	a5,ba0 <ulthread_create+0x42>
  for (t = ulthreads; t < &ulthreads[MAXULTHREADS]; t++)
 b88:	08848493          	addi	s1,s1,136
 b8c:	fee49ce3          	bne	s1,a4,b84 <ulthread_create+0x26>
      break;
    }
  }
  if (!flag)
  {
    return false;
 b90:	4501                	li	a0,0
 b92:	a871                	j	c2e <ulthread_create+0xd0>
  t->sp = (int)(stack + USTACKSIZE); // set sp to the top of the stack
  t->state = RUNNABLE;
  t->priority = priority;

  if(algorithm==FCFS){
    t->lastTime = ctime();
 b94:	00000097          	auipc	ra,0x0
 b98:	88a080e7          	jalr	-1910(ra) # 41e <ctime>
 b9c:	e888                	sd	a0,16(s1)
 b9e:	a839                	j	bbc <ulthread_create+0x5e>
  t->sp = (int)(stack + USTACKSIZE); // set sp to the top of the stack
 ba0:	6785                	lui	a5,0x1
 ba2:	014787bb          	addw	a5,a5,s4
 ba6:	c49c                	sw	a5,8(s1)
  t->state = RUNNABLE;
 ba8:	4785                	li	a5,1
 baa:	c09c                	sw	a5,0(s1)
  t->priority = priority;
 bac:	c4d4                	sw	a3,12(s1)
  if(algorithm==FCFS){
 bae:	00000717          	auipc	a4,0x0
 bb2:	46a72703          	lw	a4,1130(a4) # 1018 <algorithm>
 bb6:	4789                	li	a5,2
 bb8:	fcf70ee3          	beq	a4,a5,b94 <ulthread_create+0x36>
  }

  for (int argc = 0; argc < 6; argc++)
 bbc:	874a                	mv	a4,s2
 bbe:	03090693          	addi	a3,s2,48
  {
    t->sp -= 16;
 bc2:	449c                	lw	a5,8(s1)
 bc4:	37c1                	addiw	a5,a5,-16 # ff0 <digits+0x128>
 bc6:	0007881b          	sext.w	a6,a5
 bca:	c49c                	sw	a5,8(s1)
    *(uint64 *)(t->sp) = (uint64)args[argc];
 bcc:	631c                	ld	a5,0(a4)
 bce:	00f83023          	sd	a5,0(a6)
  for (int argc = 0; argc < 6; argc++)
 bd2:	0721                	addi	a4,a4,8
 bd4:	fed717e3          	bne	a4,a3,bc2 <ulthread_create+0x64>
  }

  memset(&t->context, 0, sizeof(t->context));
 bd8:	07000613          	li	a2,112
 bdc:	4581                	li	a1,0
 bde:	01848513          	addi	a0,s1,24
 be2:	fffff097          	auipc	ra,0xfffff
 be6:	5a2080e7          	jalr	1442(ra) # 184 <memset>
  t->context.ra = start;
 bea:	0134bc23          	sd	s3,24(s1)
  t->context.sp = t->sp;
 bee:	449c                	lw	a5,8(s1)
 bf0:	f09c                	sd	a5,32(s1)
  t->context.s0 = args[0];
 bf2:	00093783          	ld	a5,0(s2)
 bf6:	f49c                	sd	a5,40(s1)
  t->context.s1 = args[1];
 bf8:	00893783          	ld	a5,8(s2)
 bfc:	f89c                	sd	a5,48(s1)
  t->context.s2 = args[2];
 bfe:	01093783          	ld	a5,16(s2)
 c02:	fc9c                	sd	a5,56(s1)
  t->context.s3 = args[3];
 c04:	01893783          	ld	a5,24(s2)
 c08:	e0bc                	sd	a5,64(s1)
  t->context.s4 = args[4];
 c0a:	02093783          	ld	a5,32(s2)
 c0e:	e4bc                	sd	a5,72(s1)
  t->context.s5 = args[5];
 c10:	02893783          	ld	a5,40(s2)
 c14:	e8bc                	sd	a5,80(s1)

  printf("[*] ultcreate(tid: %d, ra: %p, sp: %p)\n", t->tid, start, stack);
 c16:	86d2                	mv	a3,s4
 c18:	864e                	mv	a2,s3
 c1a:	40cc                	lw	a1,4(s1)
 c1c:	00000517          	auipc	a0,0x0
 c20:	31450513          	addi	a0,a0,788 # f30 <digits+0x68>
 c24:	00000097          	auipc	ra,0x0
 c28:	aca080e7          	jalr	-1334(ra) # 6ee <printf>
  return true;
 c2c:	4505                	li	a0,1
}
 c2e:	70a2                	ld	ra,40(sp)
 c30:	7402                	ld	s0,32(sp)
 c32:	64e2                	ld	s1,24(sp)
 c34:	6942                	ld	s2,16(sp)
 c36:	69a2                	ld	s3,8(sp)
 c38:	6a02                	ld	s4,0(sp)
 c3a:	6145                	addi	sp,sp,48
 c3c:	8082                	ret

0000000000000c3e <ulthread_schedule>:

/* Thread scheduler */
void ulthread_schedule(void)
{
 c3e:	1141                	addi	sp,sp,-16
 c40:	e406                	sd	ra,8(sp)
 c42:	e022                	sd	s0,0(sp)
 c44:	0800                	addi	s0,sp,16
  switch (algorithm)
 c46:	00000797          	auipc	a5,0x0
 c4a:	3d27a783          	lw	a5,978(a5) # 1018 <algorithm>
 c4e:	4705                	li	a4,1
 c50:	02e78463          	beq	a5,a4,c78 <ulthread_schedule+0x3a>
 c54:	4709                	li	a4,2
 c56:	00e78c63          	beq	a5,a4,c6e <ulthread_schedule+0x30>
 c5a:	c789                	beqz	a5,c64 <ulthread_schedule+0x26>

  // Push argument strings, prepare rest of stack in ustack.

  // Switch between thread contexts
  // ulthread_context_switch(NULL, NULL);
}
 c5c:	60a2                	ld	ra,8(sp)
 c5e:	6402                	ld	s0,0(sp)
 c60:	0141                	addi	sp,sp,16
 c62:	8082                	ret
    roundRobin();
 c64:	00000097          	auipc	ra,0x0
 c68:	c3e080e7          	jalr	-962(ra) # 8a2 <roundRobin>
    break;
 c6c:	bfc5                	j	c5c <ulthread_schedule+0x1e>
    firstComeFirstServe();
 c6e:	00000097          	auipc	ra,0x0
 c72:	ce2080e7          	jalr	-798(ra) # 950 <firstComeFirstServe>
    break;
 c76:	b7dd                	j	c5c <ulthread_schedule+0x1e>
    priorityScheduling();
 c78:	00000097          	auipc	ra,0x0
 c7c:	db6080e7          	jalr	-586(ra) # a2e <priorityScheduling>
}
 c80:	bff1                	j	c5c <ulthread_schedule+0x1e>

0000000000000c82 <ulthread_yield>:

/* Yield CPU time to some other thread. */
void ulthread_yield(void)
{
 c82:	1101                	addi	sp,sp,-32
 c84:	ec06                	sd	ra,24(sp)
 c86:	e822                	sd	s0,16(sp)
 c88:	e426                	sd	s1,8(sp)
 c8a:	e04a                	sd	s2,0(sp)
 c8c:	1000                	addi	s0,sp,32
  current_thread->state = YIELD;
 c8e:	00000797          	auipc	a5,0x0
 c92:	39a78793          	addi	a5,a5,922 # 1028 <current_thread>
 c96:	6398                	ld	a4,0(a5)
 c98:	4909                	li	s2,2
 c9a:	01272023          	sw	s2,0(a4)
  struct ulthread *temp = current_thread;
 c9e:	6384                	ld	s1,0(a5)
  printf("[*] ultyield(tid: %d)\n", current_thread->tid);
 ca0:	40cc                	lw	a1,4(s1)
 ca2:	00000517          	auipc	a0,0x0
 ca6:	2b650513          	addi	a0,a0,694 # f58 <digits+0x90>
 caa:	00000097          	auipc	ra,0x0
 cae:	a44080e7          	jalr	-1468(ra) # 6ee <printf>
  if(algorithm==FCFS){
 cb2:	00000797          	auipc	a5,0x0
 cb6:	3667a783          	lw	a5,870(a5) # 1018 <algorithm>
 cba:	03278763          	beq	a5,s2,ce8 <ulthread_yield+0x66>
    current_thread->lastTime = ctime();
  }
  current_thread = scheduler_thread;
 cbe:	00000597          	auipc	a1,0x0
 cc2:	3625b583          	ld	a1,866(a1) # 1020 <scheduler_thread>
 cc6:	00000797          	auipc	a5,0x0
 cca:	36b7b123          	sd	a1,866(a5) # 1028 <current_thread>
  
  ulthread_context_switch(&temp->context, &scheduler_thread->context);
 cce:	05e1                	addi	a1,a1,24
 cd0:	01848513          	addi	a0,s1,24
 cd4:	00000097          	auipc	ra,0x0
 cd8:	098080e7          	jalr	152(ra) # d6c <ulthread_context_switch>
  // ulthread_schedule();
}
 cdc:	60e2                	ld	ra,24(sp)
 cde:	6442                	ld	s0,16(sp)
 ce0:	64a2                	ld	s1,8(sp)
 ce2:	6902                	ld	s2,0(sp)
 ce4:	6105                	addi	sp,sp,32
 ce6:	8082                	ret
    current_thread->lastTime = ctime();
 ce8:	fffff097          	auipc	ra,0xfffff
 cec:	736080e7          	jalr	1846(ra) # 41e <ctime>
 cf0:	00000797          	auipc	a5,0x0
 cf4:	3387b783          	ld	a5,824(a5) # 1028 <current_thread>
 cf8:	eb88                	sd	a0,16(a5)
 cfa:	b7d1                	j	cbe <ulthread_yield+0x3c>

0000000000000cfc <ulthread_destroy>:

/* Destroy thread */
void ulthread_destroy(void)
{
 cfc:	1101                	addi	sp,sp,-32
 cfe:	ec06                	sd	ra,24(sp)
 d00:	e822                	sd	s0,16(sp)
 d02:	e426                	sd	s1,8(sp)
 d04:	e04a                	sd	s2,0(sp)
 d06:	1000                	addi	s0,sp,32
  memset(&current_thread->context, 0, sizeof(current_thread->context));
 d08:	00000497          	auipc	s1,0x0
 d0c:	32048493          	addi	s1,s1,800 # 1028 <current_thread>
 d10:	6088                	ld	a0,0(s1)
 d12:	07000613          	li	a2,112
 d16:	4581                	li	a1,0
 d18:	0561                	addi	a0,a0,24
 d1a:	fffff097          	auipc	ra,0xfffff
 d1e:	46a080e7          	jalr	1130(ra) # 184 <memset>
  current_thread->sp = 0;
 d22:	609c                	ld	a5,0(s1)
 d24:	0007a423          	sw	zero,8(a5)
  current_thread->priority = -1;
 d28:	577d                	li	a4,-1
 d2a:	c7d8                	sw	a4,12(a5)
  current_thread->state = FREE;
 d2c:	0007a023          	sw	zero,0(a5)

  struct ulthread *temp = current_thread;
 d30:	0004b903          	ld	s2,0(s1)

  printf("[*] ultdestroy(tid: %d)\n", get_current_tid());
 d34:	00492583          	lw	a1,4(s2)
 d38:	00000517          	auipc	a0,0x0
 d3c:	23850513          	addi	a0,a0,568 # f70 <digits+0xa8>
 d40:	00000097          	auipc	ra,0x0
 d44:	9ae080e7          	jalr	-1618(ra) # 6ee <printf>
  current_thread = scheduler_thread;
 d48:	00000597          	auipc	a1,0x0
 d4c:	2d85b583          	ld	a1,728(a1) # 1020 <scheduler_thread>
 d50:	e08c                	sd	a1,0(s1)
  ulthread_context_switch(&temp->context, &scheduler_thread->context);
 d52:	05e1                	addi	a1,a1,24
 d54:	01890513          	addi	a0,s2,24
 d58:	00000097          	auipc	ra,0x0
 d5c:	014080e7          	jalr	20(ra) # d6c <ulthread_context_switch>
}
 d60:	60e2                	ld	ra,24(sp)
 d62:	6442                	ld	s0,16(sp)
 d64:	64a2                	ld	s1,8(sp)
 d66:	6902                	ld	s2,0(sp)
 d68:	6105                	addi	sp,sp,32
 d6a:	8082                	ret

0000000000000d6c <ulthread_context_switch>:
 d6c:	00153023          	sd	ra,0(a0)
 d70:	00253423          	sd	sp,8(a0)
 d74:	e900                	sd	s0,16(a0)
 d76:	ed04                	sd	s1,24(a0)
 d78:	03253023          	sd	s2,32(a0)
 d7c:	03353423          	sd	s3,40(a0)
 d80:	03453823          	sd	s4,48(a0)
 d84:	03553c23          	sd	s5,56(a0)
 d88:	05653023          	sd	s6,64(a0)
 d8c:	05753423          	sd	s7,72(a0)
 d90:	05853823          	sd	s8,80(a0)
 d94:	05953c23          	sd	s9,88(a0)
 d98:	07a53023          	sd	s10,96(a0)
 d9c:	07b53423          	sd	s11,104(a0)
 da0:	0005b083          	ld	ra,0(a1)
 da4:	0085b103          	ld	sp,8(a1)
 da8:	6980                	ld	s0,16(a1)
 daa:	6d84                	ld	s1,24(a1)
 dac:	0205b903          	ld	s2,32(a1)
 db0:	0285b983          	ld	s3,40(a1)
 db4:	0305ba03          	ld	s4,48(a1)
 db8:	0385ba83          	ld	s5,56(a1)
 dbc:	0405bb03          	ld	s6,64(a1)
 dc0:	0485bb83          	ld	s7,72(a1)
 dc4:	0505bc03          	ld	s8,80(a1)
 dc8:	0585bc83          	ld	s9,88(a1)
 dcc:	0605bd03          	ld	s10,96(a1)
 dd0:	0685bd83          	ld	s11,104(a1)
 dd4:	6546                	ld	a0,80(sp)
 dd6:	6586                	ld	a1,64(sp)
 dd8:	7642                	ld	a2,48(sp)
 dda:	7682                	ld	a3,32(sp)
 ddc:	6742                	ld	a4,16(sp)
 dde:	6782                	ld	a5,0(sp)
 de0:	8082                	ret
