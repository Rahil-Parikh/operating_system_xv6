
user/_cat:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <cat>:

char buf[512];

void
cat(int fd)
{
   0:	7179                	addi	sp,sp,-48
   2:	f406                	sd	ra,40(sp)
   4:	f022                	sd	s0,32(sp)
   6:	ec26                	sd	s1,24(sp)
   8:	e84a                	sd	s2,16(sp)
   a:	e44e                	sd	s3,8(sp)
   c:	1800                	addi	s0,sp,48
   e:	89aa                	mv	s3,a0
  int n;

  while((n = read(fd, buf, sizeof(buf))) > 0) {
  10:	00001917          	auipc	s2,0x1
  14:	01090913          	addi	s2,s2,16 # 1020 <buf>
  18:	20000613          	li	a2,512
  1c:	85ca                	mv	a1,s2
  1e:	854e                	mv	a0,s3
  20:	00000097          	auipc	ra,0x0
  24:	39a080e7          	jalr	922(ra) # 3ba <read>
  28:	84aa                	mv	s1,a0
  2a:	02a05963          	blez	a0,5c <cat+0x5c>
    if (write(1, buf, n) != n) {
  2e:	8626                	mv	a2,s1
  30:	85ca                	mv	a1,s2
  32:	4505                	li	a0,1
  34:	00000097          	auipc	ra,0x0
  38:	38e080e7          	jalr	910(ra) # 3c2 <write>
  3c:	fc950ee3          	beq	a0,s1,18 <cat+0x18>
      fprintf(2, "cat: write error\n");
  40:	00001597          	auipc	a1,0x1
  44:	dd058593          	addi	a1,a1,-560 # e10 <ulthread_context_switch+0x80>
  48:	4509                	li	a0,2
  4a:	00000097          	auipc	ra,0x0
  4e:	69a080e7          	jalr	1690(ra) # 6e4 <fprintf>
      exit(1);
  52:	4505                	li	a0,1
  54:	00000097          	auipc	ra,0x0
  58:	34e080e7          	jalr	846(ra) # 3a2 <exit>
    }
  }
  if(n < 0){
  5c:	00054963          	bltz	a0,6e <cat+0x6e>
    fprintf(2, "cat: read error\n");
    exit(1);
  }
}
  60:	70a2                	ld	ra,40(sp)
  62:	7402                	ld	s0,32(sp)
  64:	64e2                	ld	s1,24(sp)
  66:	6942                	ld	s2,16(sp)
  68:	69a2                	ld	s3,8(sp)
  6a:	6145                	addi	sp,sp,48
  6c:	8082                	ret
    fprintf(2, "cat: read error\n");
  6e:	00001597          	auipc	a1,0x1
  72:	dba58593          	addi	a1,a1,-582 # e28 <ulthread_context_switch+0x98>
  76:	4509                	li	a0,2
  78:	00000097          	auipc	ra,0x0
  7c:	66c080e7          	jalr	1644(ra) # 6e4 <fprintf>
    exit(1);
  80:	4505                	li	a0,1
  82:	00000097          	auipc	ra,0x0
  86:	320080e7          	jalr	800(ra) # 3a2 <exit>

000000000000008a <main>:

int
main(int argc, char *argv[])
{
  8a:	7179                	addi	sp,sp,-48
  8c:	f406                	sd	ra,40(sp)
  8e:	f022                	sd	s0,32(sp)
  90:	ec26                	sd	s1,24(sp)
  92:	e84a                	sd	s2,16(sp)
  94:	e44e                	sd	s3,8(sp)
  96:	1800                	addi	s0,sp,48
  int fd, i;

  if(argc <= 1){
  98:	4785                	li	a5,1
  9a:	04a7d763          	bge	a5,a0,e8 <main+0x5e>
  9e:	00858913          	addi	s2,a1,8
  a2:	ffe5099b          	addiw	s3,a0,-2
  a6:	02099793          	slli	a5,s3,0x20
  aa:	01d7d993          	srli	s3,a5,0x1d
  ae:	05c1                	addi	a1,a1,16
  b0:	99ae                	add	s3,s3,a1
    cat(0);
    exit(0);
  }

  for(i = 1; i < argc; i++){
    if((fd = open(argv[i], 0)) < 0){
  b2:	4581                	li	a1,0
  b4:	00093503          	ld	a0,0(s2)
  b8:	00000097          	auipc	ra,0x0
  bc:	32a080e7          	jalr	810(ra) # 3e2 <open>
  c0:	84aa                	mv	s1,a0
  c2:	02054d63          	bltz	a0,fc <main+0x72>
      fprintf(2, "cat: cannot open %s\n", argv[i]);
      exit(1);
    }
    cat(fd);
  c6:	00000097          	auipc	ra,0x0
  ca:	f3a080e7          	jalr	-198(ra) # 0 <cat>
    close(fd);
  ce:	8526                	mv	a0,s1
  d0:	00000097          	auipc	ra,0x0
  d4:	2fa080e7          	jalr	762(ra) # 3ca <close>
  for(i = 1; i < argc; i++){
  d8:	0921                	addi	s2,s2,8
  da:	fd391ce3          	bne	s2,s3,b2 <main+0x28>
  }
  exit(0);
  de:	4501                	li	a0,0
  e0:	00000097          	auipc	ra,0x0
  e4:	2c2080e7          	jalr	706(ra) # 3a2 <exit>
    cat(0);
  e8:	4501                	li	a0,0
  ea:	00000097          	auipc	ra,0x0
  ee:	f16080e7          	jalr	-234(ra) # 0 <cat>
    exit(0);
  f2:	4501                	li	a0,0
  f4:	00000097          	auipc	ra,0x0
  f8:	2ae080e7          	jalr	686(ra) # 3a2 <exit>
      fprintf(2, "cat: cannot open %s\n", argv[i]);
  fc:	00093603          	ld	a2,0(s2)
 100:	00001597          	auipc	a1,0x1
 104:	d4058593          	addi	a1,a1,-704 # e40 <ulthread_context_switch+0xb0>
 108:	4509                	li	a0,2
 10a:	00000097          	auipc	ra,0x0
 10e:	5da080e7          	jalr	1498(ra) # 6e4 <fprintf>
      exit(1);
 112:	4505                	li	a0,1
 114:	00000097          	auipc	ra,0x0
 118:	28e080e7          	jalr	654(ra) # 3a2 <exit>

000000000000011c <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
 11c:	1141                	addi	sp,sp,-16
 11e:	e406                	sd	ra,8(sp)
 120:	e022                	sd	s0,0(sp)
 122:	0800                	addi	s0,sp,16
  extern int main();
  main();
 124:	00000097          	auipc	ra,0x0
 128:	f66080e7          	jalr	-154(ra) # 8a <main>
  exit(0);
 12c:	4501                	li	a0,0
 12e:	00000097          	auipc	ra,0x0
 132:	274080e7          	jalr	628(ra) # 3a2 <exit>

0000000000000136 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 136:	1141                	addi	sp,sp,-16
 138:	e422                	sd	s0,8(sp)
 13a:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 13c:	87aa                	mv	a5,a0
 13e:	0585                	addi	a1,a1,1
 140:	0785                	addi	a5,a5,1
 142:	fff5c703          	lbu	a4,-1(a1)
 146:	fee78fa3          	sb	a4,-1(a5)
 14a:	fb75                	bnez	a4,13e <strcpy+0x8>
    ;
  return os;
}
 14c:	6422                	ld	s0,8(sp)
 14e:	0141                	addi	sp,sp,16
 150:	8082                	ret

0000000000000152 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 152:	1141                	addi	sp,sp,-16
 154:	e422                	sd	s0,8(sp)
 156:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 158:	00054783          	lbu	a5,0(a0)
 15c:	cb91                	beqz	a5,170 <strcmp+0x1e>
 15e:	0005c703          	lbu	a4,0(a1)
 162:	00f71763          	bne	a4,a5,170 <strcmp+0x1e>
    p++, q++;
 166:	0505                	addi	a0,a0,1
 168:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 16a:	00054783          	lbu	a5,0(a0)
 16e:	fbe5                	bnez	a5,15e <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 170:	0005c503          	lbu	a0,0(a1)
}
 174:	40a7853b          	subw	a0,a5,a0
 178:	6422                	ld	s0,8(sp)
 17a:	0141                	addi	sp,sp,16
 17c:	8082                	ret

000000000000017e <strlen>:

uint
strlen(const char *s)
{
 17e:	1141                	addi	sp,sp,-16
 180:	e422                	sd	s0,8(sp)
 182:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 184:	00054783          	lbu	a5,0(a0)
 188:	cf91                	beqz	a5,1a4 <strlen+0x26>
 18a:	0505                	addi	a0,a0,1
 18c:	87aa                	mv	a5,a0
 18e:	86be                	mv	a3,a5
 190:	0785                	addi	a5,a5,1
 192:	fff7c703          	lbu	a4,-1(a5)
 196:	ff65                	bnez	a4,18e <strlen+0x10>
 198:	40a6853b          	subw	a0,a3,a0
 19c:	2505                	addiw	a0,a0,1
    ;
  return n;
}
 19e:	6422                	ld	s0,8(sp)
 1a0:	0141                	addi	sp,sp,16
 1a2:	8082                	ret
  for(n = 0; s[n]; n++)
 1a4:	4501                	li	a0,0
 1a6:	bfe5                	j	19e <strlen+0x20>

00000000000001a8 <memset>:

void*
memset(void *dst, int c, uint n)
{
 1a8:	1141                	addi	sp,sp,-16
 1aa:	e422                	sd	s0,8(sp)
 1ac:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 1ae:	ca19                	beqz	a2,1c4 <memset+0x1c>
 1b0:	87aa                	mv	a5,a0
 1b2:	1602                	slli	a2,a2,0x20
 1b4:	9201                	srli	a2,a2,0x20
 1b6:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 1ba:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 1be:	0785                	addi	a5,a5,1
 1c0:	fee79de3          	bne	a5,a4,1ba <memset+0x12>
  }
  return dst;
}
 1c4:	6422                	ld	s0,8(sp)
 1c6:	0141                	addi	sp,sp,16
 1c8:	8082                	ret

00000000000001ca <strchr>:

char*
strchr(const char *s, char c)
{
 1ca:	1141                	addi	sp,sp,-16
 1cc:	e422                	sd	s0,8(sp)
 1ce:	0800                	addi	s0,sp,16
  for(; *s; s++)
 1d0:	00054783          	lbu	a5,0(a0)
 1d4:	cb99                	beqz	a5,1ea <strchr+0x20>
    if(*s == c)
 1d6:	00f58763          	beq	a1,a5,1e4 <strchr+0x1a>
  for(; *s; s++)
 1da:	0505                	addi	a0,a0,1
 1dc:	00054783          	lbu	a5,0(a0)
 1e0:	fbfd                	bnez	a5,1d6 <strchr+0xc>
      return (char*)s;
  return 0;
 1e2:	4501                	li	a0,0
}
 1e4:	6422                	ld	s0,8(sp)
 1e6:	0141                	addi	sp,sp,16
 1e8:	8082                	ret
  return 0;
 1ea:	4501                	li	a0,0
 1ec:	bfe5                	j	1e4 <strchr+0x1a>

00000000000001ee <gets>:

char*
gets(char *buf, int max)
{
 1ee:	711d                	addi	sp,sp,-96
 1f0:	ec86                	sd	ra,88(sp)
 1f2:	e8a2                	sd	s0,80(sp)
 1f4:	e4a6                	sd	s1,72(sp)
 1f6:	e0ca                	sd	s2,64(sp)
 1f8:	fc4e                	sd	s3,56(sp)
 1fa:	f852                	sd	s4,48(sp)
 1fc:	f456                	sd	s5,40(sp)
 1fe:	f05a                	sd	s6,32(sp)
 200:	ec5e                	sd	s7,24(sp)
 202:	1080                	addi	s0,sp,96
 204:	8baa                	mv	s7,a0
 206:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 208:	892a                	mv	s2,a0
 20a:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 20c:	4aa9                	li	s5,10
 20e:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 210:	89a6                	mv	s3,s1
 212:	2485                	addiw	s1,s1,1
 214:	0344d863          	bge	s1,s4,244 <gets+0x56>
    cc = read(0, &c, 1);
 218:	4605                	li	a2,1
 21a:	faf40593          	addi	a1,s0,-81
 21e:	4501                	li	a0,0
 220:	00000097          	auipc	ra,0x0
 224:	19a080e7          	jalr	410(ra) # 3ba <read>
    if(cc < 1)
 228:	00a05e63          	blez	a0,244 <gets+0x56>
    buf[i++] = c;
 22c:	faf44783          	lbu	a5,-81(s0)
 230:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 234:	01578763          	beq	a5,s5,242 <gets+0x54>
 238:	0905                	addi	s2,s2,1
 23a:	fd679be3          	bne	a5,s6,210 <gets+0x22>
  for(i=0; i+1 < max; ){
 23e:	89a6                	mv	s3,s1
 240:	a011                	j	244 <gets+0x56>
 242:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 244:	99de                	add	s3,s3,s7
 246:	00098023          	sb	zero,0(s3)
  return buf;
}
 24a:	855e                	mv	a0,s7
 24c:	60e6                	ld	ra,88(sp)
 24e:	6446                	ld	s0,80(sp)
 250:	64a6                	ld	s1,72(sp)
 252:	6906                	ld	s2,64(sp)
 254:	79e2                	ld	s3,56(sp)
 256:	7a42                	ld	s4,48(sp)
 258:	7aa2                	ld	s5,40(sp)
 25a:	7b02                	ld	s6,32(sp)
 25c:	6be2                	ld	s7,24(sp)
 25e:	6125                	addi	sp,sp,96
 260:	8082                	ret

0000000000000262 <stat>:

int
stat(const char *n, struct stat *st)
{
 262:	1101                	addi	sp,sp,-32
 264:	ec06                	sd	ra,24(sp)
 266:	e822                	sd	s0,16(sp)
 268:	e426                	sd	s1,8(sp)
 26a:	e04a                	sd	s2,0(sp)
 26c:	1000                	addi	s0,sp,32
 26e:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 270:	4581                	li	a1,0
 272:	00000097          	auipc	ra,0x0
 276:	170080e7          	jalr	368(ra) # 3e2 <open>
  if(fd < 0)
 27a:	02054563          	bltz	a0,2a4 <stat+0x42>
 27e:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 280:	85ca                	mv	a1,s2
 282:	00000097          	auipc	ra,0x0
 286:	178080e7          	jalr	376(ra) # 3fa <fstat>
 28a:	892a                	mv	s2,a0
  close(fd);
 28c:	8526                	mv	a0,s1
 28e:	00000097          	auipc	ra,0x0
 292:	13c080e7          	jalr	316(ra) # 3ca <close>
  return r;
}
 296:	854a                	mv	a0,s2
 298:	60e2                	ld	ra,24(sp)
 29a:	6442                	ld	s0,16(sp)
 29c:	64a2                	ld	s1,8(sp)
 29e:	6902                	ld	s2,0(sp)
 2a0:	6105                	addi	sp,sp,32
 2a2:	8082                	ret
    return -1;
 2a4:	597d                	li	s2,-1
 2a6:	bfc5                	j	296 <stat+0x34>

00000000000002a8 <atoi>:

int
atoi(const char *s)
{
 2a8:	1141                	addi	sp,sp,-16
 2aa:	e422                	sd	s0,8(sp)
 2ac:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 2ae:	00054683          	lbu	a3,0(a0)
 2b2:	fd06879b          	addiw	a5,a3,-48
 2b6:	0ff7f793          	zext.b	a5,a5
 2ba:	4625                	li	a2,9
 2bc:	02f66863          	bltu	a2,a5,2ec <atoi+0x44>
 2c0:	872a                	mv	a4,a0
  n = 0;
 2c2:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 2c4:	0705                	addi	a4,a4,1
 2c6:	0025179b          	slliw	a5,a0,0x2
 2ca:	9fa9                	addw	a5,a5,a0
 2cc:	0017979b          	slliw	a5,a5,0x1
 2d0:	9fb5                	addw	a5,a5,a3
 2d2:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 2d6:	00074683          	lbu	a3,0(a4)
 2da:	fd06879b          	addiw	a5,a3,-48
 2de:	0ff7f793          	zext.b	a5,a5
 2e2:	fef671e3          	bgeu	a2,a5,2c4 <atoi+0x1c>
  return n;
}
 2e6:	6422                	ld	s0,8(sp)
 2e8:	0141                	addi	sp,sp,16
 2ea:	8082                	ret
  n = 0;
 2ec:	4501                	li	a0,0
 2ee:	bfe5                	j	2e6 <atoi+0x3e>

00000000000002f0 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 2f0:	1141                	addi	sp,sp,-16
 2f2:	e422                	sd	s0,8(sp)
 2f4:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 2f6:	02b57463          	bgeu	a0,a1,31e <memmove+0x2e>
    while(n-- > 0)
 2fa:	00c05f63          	blez	a2,318 <memmove+0x28>
 2fe:	1602                	slli	a2,a2,0x20
 300:	9201                	srli	a2,a2,0x20
 302:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 306:	872a                	mv	a4,a0
      *dst++ = *src++;
 308:	0585                	addi	a1,a1,1
 30a:	0705                	addi	a4,a4,1
 30c:	fff5c683          	lbu	a3,-1(a1)
 310:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 314:	fee79ae3          	bne	a5,a4,308 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 318:	6422                	ld	s0,8(sp)
 31a:	0141                	addi	sp,sp,16
 31c:	8082                	ret
    dst += n;
 31e:	00c50733          	add	a4,a0,a2
    src += n;
 322:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 324:	fec05ae3          	blez	a2,318 <memmove+0x28>
 328:	fff6079b          	addiw	a5,a2,-1
 32c:	1782                	slli	a5,a5,0x20
 32e:	9381                	srli	a5,a5,0x20
 330:	fff7c793          	not	a5,a5
 334:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 336:	15fd                	addi	a1,a1,-1
 338:	177d                	addi	a4,a4,-1
 33a:	0005c683          	lbu	a3,0(a1)
 33e:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 342:	fee79ae3          	bne	a5,a4,336 <memmove+0x46>
 346:	bfc9                	j	318 <memmove+0x28>

0000000000000348 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 348:	1141                	addi	sp,sp,-16
 34a:	e422                	sd	s0,8(sp)
 34c:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 34e:	ca05                	beqz	a2,37e <memcmp+0x36>
 350:	fff6069b          	addiw	a3,a2,-1
 354:	1682                	slli	a3,a3,0x20
 356:	9281                	srli	a3,a3,0x20
 358:	0685                	addi	a3,a3,1
 35a:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 35c:	00054783          	lbu	a5,0(a0)
 360:	0005c703          	lbu	a4,0(a1)
 364:	00e79863          	bne	a5,a4,374 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 368:	0505                	addi	a0,a0,1
    p2++;
 36a:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 36c:	fed518e3          	bne	a0,a3,35c <memcmp+0x14>
  }
  return 0;
 370:	4501                	li	a0,0
 372:	a019                	j	378 <memcmp+0x30>
      return *p1 - *p2;
 374:	40e7853b          	subw	a0,a5,a4
}
 378:	6422                	ld	s0,8(sp)
 37a:	0141                	addi	sp,sp,16
 37c:	8082                	ret
  return 0;
 37e:	4501                	li	a0,0
 380:	bfe5                	j	378 <memcmp+0x30>

0000000000000382 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 382:	1141                	addi	sp,sp,-16
 384:	e406                	sd	ra,8(sp)
 386:	e022                	sd	s0,0(sp)
 388:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 38a:	00000097          	auipc	ra,0x0
 38e:	f66080e7          	jalr	-154(ra) # 2f0 <memmove>
}
 392:	60a2                	ld	ra,8(sp)
 394:	6402                	ld	s0,0(sp)
 396:	0141                	addi	sp,sp,16
 398:	8082                	ret

000000000000039a <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 39a:	4885                	li	a7,1
 ecall
 39c:	00000073          	ecall
 ret
 3a0:	8082                	ret

00000000000003a2 <exit>:
.global exit
exit:
 li a7, SYS_exit
 3a2:	4889                	li	a7,2
 ecall
 3a4:	00000073          	ecall
 ret
 3a8:	8082                	ret

00000000000003aa <wait>:
.global wait
wait:
 li a7, SYS_wait
 3aa:	488d                	li	a7,3
 ecall
 3ac:	00000073          	ecall
 ret
 3b0:	8082                	ret

00000000000003b2 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 3b2:	4891                	li	a7,4
 ecall
 3b4:	00000073          	ecall
 ret
 3b8:	8082                	ret

00000000000003ba <read>:
.global read
read:
 li a7, SYS_read
 3ba:	4895                	li	a7,5
 ecall
 3bc:	00000073          	ecall
 ret
 3c0:	8082                	ret

00000000000003c2 <write>:
.global write
write:
 li a7, SYS_write
 3c2:	48c1                	li	a7,16
 ecall
 3c4:	00000073          	ecall
 ret
 3c8:	8082                	ret

00000000000003ca <close>:
.global close
close:
 li a7, SYS_close
 3ca:	48d5                	li	a7,21
 ecall
 3cc:	00000073          	ecall
 ret
 3d0:	8082                	ret

00000000000003d2 <kill>:
.global kill
kill:
 li a7, SYS_kill
 3d2:	4899                	li	a7,6
 ecall
 3d4:	00000073          	ecall
 ret
 3d8:	8082                	ret

00000000000003da <exec>:
.global exec
exec:
 li a7, SYS_exec
 3da:	489d                	li	a7,7
 ecall
 3dc:	00000073          	ecall
 ret
 3e0:	8082                	ret

00000000000003e2 <open>:
.global open
open:
 li a7, SYS_open
 3e2:	48bd                	li	a7,15
 ecall
 3e4:	00000073          	ecall
 ret
 3e8:	8082                	ret

00000000000003ea <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 3ea:	48c5                	li	a7,17
 ecall
 3ec:	00000073          	ecall
 ret
 3f0:	8082                	ret

00000000000003f2 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 3f2:	48c9                	li	a7,18
 ecall
 3f4:	00000073          	ecall
 ret
 3f8:	8082                	ret

00000000000003fa <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 3fa:	48a1                	li	a7,8
 ecall
 3fc:	00000073          	ecall
 ret
 400:	8082                	ret

0000000000000402 <link>:
.global link
link:
 li a7, SYS_link
 402:	48cd                	li	a7,19
 ecall
 404:	00000073          	ecall
 ret
 408:	8082                	ret

000000000000040a <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 40a:	48d1                	li	a7,20
 ecall
 40c:	00000073          	ecall
 ret
 410:	8082                	ret

0000000000000412 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 412:	48a5                	li	a7,9
 ecall
 414:	00000073          	ecall
 ret
 418:	8082                	ret

000000000000041a <dup>:
.global dup
dup:
 li a7, SYS_dup
 41a:	48a9                	li	a7,10
 ecall
 41c:	00000073          	ecall
 ret
 420:	8082                	ret

0000000000000422 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 422:	48ad                	li	a7,11
 ecall
 424:	00000073          	ecall
 ret
 428:	8082                	ret

000000000000042a <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 42a:	48b1                	li	a7,12
 ecall
 42c:	00000073          	ecall
 ret
 430:	8082                	ret

0000000000000432 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 432:	48b5                	li	a7,13
 ecall
 434:	00000073          	ecall
 ret
 438:	8082                	ret

000000000000043a <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 43a:	48b9                	li	a7,14
 ecall
 43c:	00000073          	ecall
 ret
 440:	8082                	ret

0000000000000442 <ctime>:
.global ctime
ctime:
 li a7, SYS_ctime
 442:	48d9                	li	a7,22
 ecall
 444:	00000073          	ecall
 ret
 448:	8082                	ret

000000000000044a <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 44a:	1101                	addi	sp,sp,-32
 44c:	ec06                	sd	ra,24(sp)
 44e:	e822                	sd	s0,16(sp)
 450:	1000                	addi	s0,sp,32
 452:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 456:	4605                	li	a2,1
 458:	fef40593          	addi	a1,s0,-17
 45c:	00000097          	auipc	ra,0x0
 460:	f66080e7          	jalr	-154(ra) # 3c2 <write>
}
 464:	60e2                	ld	ra,24(sp)
 466:	6442                	ld	s0,16(sp)
 468:	6105                	addi	sp,sp,32
 46a:	8082                	ret

000000000000046c <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 46c:	7139                	addi	sp,sp,-64
 46e:	fc06                	sd	ra,56(sp)
 470:	f822                	sd	s0,48(sp)
 472:	f426                	sd	s1,40(sp)
 474:	f04a                	sd	s2,32(sp)
 476:	ec4e                	sd	s3,24(sp)
 478:	0080                	addi	s0,sp,64
 47a:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 47c:	c299                	beqz	a3,482 <printint+0x16>
 47e:	0805c963          	bltz	a1,510 <printint+0xa4>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 482:	2581                	sext.w	a1,a1
  neg = 0;
 484:	4881                	li	a7,0
 486:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 48a:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 48c:	2601                	sext.w	a2,a2
 48e:	00001517          	auipc	a0,0x1
 492:	a2a50513          	addi	a0,a0,-1494 # eb8 <digits>
 496:	883a                	mv	a6,a4
 498:	2705                	addiw	a4,a4,1
 49a:	02c5f7bb          	remuw	a5,a1,a2
 49e:	1782                	slli	a5,a5,0x20
 4a0:	9381                	srli	a5,a5,0x20
 4a2:	97aa                	add	a5,a5,a0
 4a4:	0007c783          	lbu	a5,0(a5)
 4a8:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 4ac:	0005879b          	sext.w	a5,a1
 4b0:	02c5d5bb          	divuw	a1,a1,a2
 4b4:	0685                	addi	a3,a3,1
 4b6:	fec7f0e3          	bgeu	a5,a2,496 <printint+0x2a>
  if(neg)
 4ba:	00088c63          	beqz	a7,4d2 <printint+0x66>
    buf[i++] = '-';
 4be:	fd070793          	addi	a5,a4,-48
 4c2:	00878733          	add	a4,a5,s0
 4c6:	02d00793          	li	a5,45
 4ca:	fef70823          	sb	a5,-16(a4)
 4ce:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 4d2:	02e05863          	blez	a4,502 <printint+0x96>
 4d6:	fc040793          	addi	a5,s0,-64
 4da:	00e78933          	add	s2,a5,a4
 4de:	fff78993          	addi	s3,a5,-1
 4e2:	99ba                	add	s3,s3,a4
 4e4:	377d                	addiw	a4,a4,-1
 4e6:	1702                	slli	a4,a4,0x20
 4e8:	9301                	srli	a4,a4,0x20
 4ea:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 4ee:	fff94583          	lbu	a1,-1(s2)
 4f2:	8526                	mv	a0,s1
 4f4:	00000097          	auipc	ra,0x0
 4f8:	f56080e7          	jalr	-170(ra) # 44a <putc>
  while(--i >= 0)
 4fc:	197d                	addi	s2,s2,-1
 4fe:	ff3918e3          	bne	s2,s3,4ee <printint+0x82>
}
 502:	70e2                	ld	ra,56(sp)
 504:	7442                	ld	s0,48(sp)
 506:	74a2                	ld	s1,40(sp)
 508:	7902                	ld	s2,32(sp)
 50a:	69e2                	ld	s3,24(sp)
 50c:	6121                	addi	sp,sp,64
 50e:	8082                	ret
    x = -xx;
 510:	40b005bb          	negw	a1,a1
    neg = 1;
 514:	4885                	li	a7,1
    x = -xx;
 516:	bf85                	j	486 <printint+0x1a>

0000000000000518 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 518:	715d                	addi	sp,sp,-80
 51a:	e486                	sd	ra,72(sp)
 51c:	e0a2                	sd	s0,64(sp)
 51e:	fc26                	sd	s1,56(sp)
 520:	f84a                	sd	s2,48(sp)
 522:	f44e                	sd	s3,40(sp)
 524:	f052                	sd	s4,32(sp)
 526:	ec56                	sd	s5,24(sp)
 528:	e85a                	sd	s6,16(sp)
 52a:	e45e                	sd	s7,8(sp)
 52c:	e062                	sd	s8,0(sp)
 52e:	0880                	addi	s0,sp,80
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 530:	0005c903          	lbu	s2,0(a1)
 534:	18090c63          	beqz	s2,6cc <vprintf+0x1b4>
 538:	8aaa                	mv	s5,a0
 53a:	8bb2                	mv	s7,a2
 53c:	00158493          	addi	s1,a1,1
  state = 0;
 540:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 542:	02500a13          	li	s4,37
 546:	4b55                	li	s6,21
 548:	a839                	j	566 <vprintf+0x4e>
        putc(fd, c);
 54a:	85ca                	mv	a1,s2
 54c:	8556                	mv	a0,s5
 54e:	00000097          	auipc	ra,0x0
 552:	efc080e7          	jalr	-260(ra) # 44a <putc>
 556:	a019                	j	55c <vprintf+0x44>
    } else if(state == '%'){
 558:	01498d63          	beq	s3,s4,572 <vprintf+0x5a>
  for(i = 0; fmt[i]; i++){
 55c:	0485                	addi	s1,s1,1
 55e:	fff4c903          	lbu	s2,-1(s1)
 562:	16090563          	beqz	s2,6cc <vprintf+0x1b4>
    if(state == 0){
 566:	fe0999e3          	bnez	s3,558 <vprintf+0x40>
      if(c == '%'){
 56a:	ff4910e3          	bne	s2,s4,54a <vprintf+0x32>
        state = '%';
 56e:	89d2                	mv	s3,s4
 570:	b7f5                	j	55c <vprintf+0x44>
      if(c == 'd'){
 572:	13490263          	beq	s2,s4,696 <vprintf+0x17e>
 576:	f9d9079b          	addiw	a5,s2,-99
 57a:	0ff7f793          	zext.b	a5,a5
 57e:	12fb6563          	bltu	s6,a5,6a8 <vprintf+0x190>
 582:	f9d9079b          	addiw	a5,s2,-99
 586:	0ff7f713          	zext.b	a4,a5
 58a:	10eb6f63          	bltu	s6,a4,6a8 <vprintf+0x190>
 58e:	00271793          	slli	a5,a4,0x2
 592:	00001717          	auipc	a4,0x1
 596:	8ce70713          	addi	a4,a4,-1842 # e60 <ulthread_context_switch+0xd0>
 59a:	97ba                	add	a5,a5,a4
 59c:	439c                	lw	a5,0(a5)
 59e:	97ba                	add	a5,a5,a4
 5a0:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
 5a2:	008b8913          	addi	s2,s7,8
 5a6:	4685                	li	a3,1
 5a8:	4629                	li	a2,10
 5aa:	000ba583          	lw	a1,0(s7)
 5ae:	8556                	mv	a0,s5
 5b0:	00000097          	auipc	ra,0x0
 5b4:	ebc080e7          	jalr	-324(ra) # 46c <printint>
 5b8:	8bca                	mv	s7,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 5ba:	4981                	li	s3,0
 5bc:	b745                	j	55c <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 5be:	008b8913          	addi	s2,s7,8
 5c2:	4681                	li	a3,0
 5c4:	4629                	li	a2,10
 5c6:	000ba583          	lw	a1,0(s7)
 5ca:	8556                	mv	a0,s5
 5cc:	00000097          	auipc	ra,0x0
 5d0:	ea0080e7          	jalr	-352(ra) # 46c <printint>
 5d4:	8bca                	mv	s7,s2
      state = 0;
 5d6:	4981                	li	s3,0
 5d8:	b751                	j	55c <vprintf+0x44>
        printint(fd, va_arg(ap, int), 16, 0);
 5da:	008b8913          	addi	s2,s7,8
 5de:	4681                	li	a3,0
 5e0:	4641                	li	a2,16
 5e2:	000ba583          	lw	a1,0(s7)
 5e6:	8556                	mv	a0,s5
 5e8:	00000097          	auipc	ra,0x0
 5ec:	e84080e7          	jalr	-380(ra) # 46c <printint>
 5f0:	8bca                	mv	s7,s2
      state = 0;
 5f2:	4981                	li	s3,0
 5f4:	b7a5                	j	55c <vprintf+0x44>
        printptr(fd, va_arg(ap, uint64));
 5f6:	008b8c13          	addi	s8,s7,8
 5fa:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 5fe:	03000593          	li	a1,48
 602:	8556                	mv	a0,s5
 604:	00000097          	auipc	ra,0x0
 608:	e46080e7          	jalr	-442(ra) # 44a <putc>
  putc(fd, 'x');
 60c:	07800593          	li	a1,120
 610:	8556                	mv	a0,s5
 612:	00000097          	auipc	ra,0x0
 616:	e38080e7          	jalr	-456(ra) # 44a <putc>
 61a:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 61c:	00001b97          	auipc	s7,0x1
 620:	89cb8b93          	addi	s7,s7,-1892 # eb8 <digits>
 624:	03c9d793          	srli	a5,s3,0x3c
 628:	97de                	add	a5,a5,s7
 62a:	0007c583          	lbu	a1,0(a5)
 62e:	8556                	mv	a0,s5
 630:	00000097          	auipc	ra,0x0
 634:	e1a080e7          	jalr	-486(ra) # 44a <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 638:	0992                	slli	s3,s3,0x4
 63a:	397d                	addiw	s2,s2,-1
 63c:	fe0914e3          	bnez	s2,624 <vprintf+0x10c>
        printptr(fd, va_arg(ap, uint64));
 640:	8be2                	mv	s7,s8
      state = 0;
 642:	4981                	li	s3,0
 644:	bf21                	j	55c <vprintf+0x44>
        s = va_arg(ap, char*);
 646:	008b8993          	addi	s3,s7,8
 64a:	000bb903          	ld	s2,0(s7)
        if(s == 0)
 64e:	02090163          	beqz	s2,670 <vprintf+0x158>
        while(*s != 0){
 652:	00094583          	lbu	a1,0(s2)
 656:	c9a5                	beqz	a1,6c6 <vprintf+0x1ae>
          putc(fd, *s);
 658:	8556                	mv	a0,s5
 65a:	00000097          	auipc	ra,0x0
 65e:	df0080e7          	jalr	-528(ra) # 44a <putc>
          s++;
 662:	0905                	addi	s2,s2,1
        while(*s != 0){
 664:	00094583          	lbu	a1,0(s2)
 668:	f9e5                	bnez	a1,658 <vprintf+0x140>
        s = va_arg(ap, char*);
 66a:	8bce                	mv	s7,s3
      state = 0;
 66c:	4981                	li	s3,0
 66e:	b5fd                	j	55c <vprintf+0x44>
          s = "(null)";
 670:	00000917          	auipc	s2,0x0
 674:	7e890913          	addi	s2,s2,2024 # e58 <ulthread_context_switch+0xc8>
        while(*s != 0){
 678:	02800593          	li	a1,40
 67c:	bff1                	j	658 <vprintf+0x140>
        putc(fd, va_arg(ap, uint));
 67e:	008b8913          	addi	s2,s7,8
 682:	000bc583          	lbu	a1,0(s7)
 686:	8556                	mv	a0,s5
 688:	00000097          	auipc	ra,0x0
 68c:	dc2080e7          	jalr	-574(ra) # 44a <putc>
 690:	8bca                	mv	s7,s2
      state = 0;
 692:	4981                	li	s3,0
 694:	b5e1                	j	55c <vprintf+0x44>
        putc(fd, c);
 696:	02500593          	li	a1,37
 69a:	8556                	mv	a0,s5
 69c:	00000097          	auipc	ra,0x0
 6a0:	dae080e7          	jalr	-594(ra) # 44a <putc>
      state = 0;
 6a4:	4981                	li	s3,0
 6a6:	bd5d                	j	55c <vprintf+0x44>
        putc(fd, '%');
 6a8:	02500593          	li	a1,37
 6ac:	8556                	mv	a0,s5
 6ae:	00000097          	auipc	ra,0x0
 6b2:	d9c080e7          	jalr	-612(ra) # 44a <putc>
        putc(fd, c);
 6b6:	85ca                	mv	a1,s2
 6b8:	8556                	mv	a0,s5
 6ba:	00000097          	auipc	ra,0x0
 6be:	d90080e7          	jalr	-624(ra) # 44a <putc>
      state = 0;
 6c2:	4981                	li	s3,0
 6c4:	bd61                	j	55c <vprintf+0x44>
        s = va_arg(ap, char*);
 6c6:	8bce                	mv	s7,s3
      state = 0;
 6c8:	4981                	li	s3,0
 6ca:	bd49                	j	55c <vprintf+0x44>
    }
  }
}
 6cc:	60a6                	ld	ra,72(sp)
 6ce:	6406                	ld	s0,64(sp)
 6d0:	74e2                	ld	s1,56(sp)
 6d2:	7942                	ld	s2,48(sp)
 6d4:	79a2                	ld	s3,40(sp)
 6d6:	7a02                	ld	s4,32(sp)
 6d8:	6ae2                	ld	s5,24(sp)
 6da:	6b42                	ld	s6,16(sp)
 6dc:	6ba2                	ld	s7,8(sp)
 6de:	6c02                	ld	s8,0(sp)
 6e0:	6161                	addi	sp,sp,80
 6e2:	8082                	ret

00000000000006e4 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 6e4:	715d                	addi	sp,sp,-80
 6e6:	ec06                	sd	ra,24(sp)
 6e8:	e822                	sd	s0,16(sp)
 6ea:	1000                	addi	s0,sp,32
 6ec:	e010                	sd	a2,0(s0)
 6ee:	e414                	sd	a3,8(s0)
 6f0:	e818                	sd	a4,16(s0)
 6f2:	ec1c                	sd	a5,24(s0)
 6f4:	03043023          	sd	a6,32(s0)
 6f8:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 6fc:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 700:	8622                	mv	a2,s0
 702:	00000097          	auipc	ra,0x0
 706:	e16080e7          	jalr	-490(ra) # 518 <vprintf>
}
 70a:	60e2                	ld	ra,24(sp)
 70c:	6442                	ld	s0,16(sp)
 70e:	6161                	addi	sp,sp,80
 710:	8082                	ret

0000000000000712 <printf>:

void
printf(const char *fmt, ...)
{
 712:	711d                	addi	sp,sp,-96
 714:	ec06                	sd	ra,24(sp)
 716:	e822                	sd	s0,16(sp)
 718:	1000                	addi	s0,sp,32
 71a:	e40c                	sd	a1,8(s0)
 71c:	e810                	sd	a2,16(s0)
 71e:	ec14                	sd	a3,24(s0)
 720:	f018                	sd	a4,32(s0)
 722:	f41c                	sd	a5,40(s0)
 724:	03043823          	sd	a6,48(s0)
 728:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 72c:	00840613          	addi	a2,s0,8
 730:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 734:	85aa                	mv	a1,a0
 736:	4505                	li	a0,1
 738:	00000097          	auipc	ra,0x0
 73c:	de0080e7          	jalr	-544(ra) # 518 <vprintf>
}
 740:	60e2                	ld	ra,24(sp)
 742:	6442                	ld	s0,16(sp)
 744:	6125                	addi	sp,sp,96
 746:	8082                	ret

0000000000000748 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 748:	1141                	addi	sp,sp,-16
 74a:	e422                	sd	s0,8(sp)
 74c:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 74e:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 752:	00001797          	auipc	a5,0x1
 756:	8ae7b783          	ld	a5,-1874(a5) # 1000 <freep>
 75a:	a02d                	j	784 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 75c:	4618                	lw	a4,8(a2)
 75e:	9f2d                	addw	a4,a4,a1
 760:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 764:	6398                	ld	a4,0(a5)
 766:	6310                	ld	a2,0(a4)
 768:	a83d                	j	7a6 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 76a:	ff852703          	lw	a4,-8(a0)
 76e:	9f31                	addw	a4,a4,a2
 770:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 772:	ff053683          	ld	a3,-16(a0)
 776:	a091                	j	7ba <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 778:	6398                	ld	a4,0(a5)
 77a:	00e7e463          	bltu	a5,a4,782 <free+0x3a>
 77e:	00e6ea63          	bltu	a3,a4,792 <free+0x4a>
{
 782:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 784:	fed7fae3          	bgeu	a5,a3,778 <free+0x30>
 788:	6398                	ld	a4,0(a5)
 78a:	00e6e463          	bltu	a3,a4,792 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 78e:	fee7eae3          	bltu	a5,a4,782 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 792:	ff852583          	lw	a1,-8(a0)
 796:	6390                	ld	a2,0(a5)
 798:	02059813          	slli	a6,a1,0x20
 79c:	01c85713          	srli	a4,a6,0x1c
 7a0:	9736                	add	a4,a4,a3
 7a2:	fae60de3          	beq	a2,a4,75c <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 7a6:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 7aa:	4790                	lw	a2,8(a5)
 7ac:	02061593          	slli	a1,a2,0x20
 7b0:	01c5d713          	srli	a4,a1,0x1c
 7b4:	973e                	add	a4,a4,a5
 7b6:	fae68ae3          	beq	a3,a4,76a <free+0x22>
    p->s.ptr = bp->s.ptr;
 7ba:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 7bc:	00001717          	auipc	a4,0x1
 7c0:	84f73223          	sd	a5,-1980(a4) # 1000 <freep>
}
 7c4:	6422                	ld	s0,8(sp)
 7c6:	0141                	addi	sp,sp,16
 7c8:	8082                	ret

00000000000007ca <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 7ca:	7139                	addi	sp,sp,-64
 7cc:	fc06                	sd	ra,56(sp)
 7ce:	f822                	sd	s0,48(sp)
 7d0:	f426                	sd	s1,40(sp)
 7d2:	f04a                	sd	s2,32(sp)
 7d4:	ec4e                	sd	s3,24(sp)
 7d6:	e852                	sd	s4,16(sp)
 7d8:	e456                	sd	s5,8(sp)
 7da:	e05a                	sd	s6,0(sp)
 7dc:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 7de:	02051493          	slli	s1,a0,0x20
 7e2:	9081                	srli	s1,s1,0x20
 7e4:	04bd                	addi	s1,s1,15
 7e6:	8091                	srli	s1,s1,0x4
 7e8:	0014899b          	addiw	s3,s1,1
 7ec:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 7ee:	00001517          	auipc	a0,0x1
 7f2:	81253503          	ld	a0,-2030(a0) # 1000 <freep>
 7f6:	c515                	beqz	a0,822 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 7f8:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 7fa:	4798                	lw	a4,8(a5)
 7fc:	02977f63          	bgeu	a4,s1,83a <malloc+0x70>
  if(nu < 4096)
 800:	8a4e                	mv	s4,s3
 802:	0009871b          	sext.w	a4,s3
 806:	6685                	lui	a3,0x1
 808:	00d77363          	bgeu	a4,a3,80e <malloc+0x44>
 80c:	6a05                	lui	s4,0x1
 80e:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 812:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 816:	00000917          	auipc	s2,0x0
 81a:	7ea90913          	addi	s2,s2,2026 # 1000 <freep>
  if(p == (char*)-1)
 81e:	5afd                	li	s5,-1
 820:	a895                	j	894 <malloc+0xca>
    base.s.ptr = freep = prevp = &base;
 822:	00001797          	auipc	a5,0x1
 826:	9fe78793          	addi	a5,a5,-1538 # 1220 <base>
 82a:	00000717          	auipc	a4,0x0
 82e:	7cf73b23          	sd	a5,2006(a4) # 1000 <freep>
 832:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 834:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 838:	b7e1                	j	800 <malloc+0x36>
      if(p->s.size == nunits)
 83a:	02e48c63          	beq	s1,a4,872 <malloc+0xa8>
        p->s.size -= nunits;
 83e:	4137073b          	subw	a4,a4,s3
 842:	c798                	sw	a4,8(a5)
        p += p->s.size;
 844:	02071693          	slli	a3,a4,0x20
 848:	01c6d713          	srli	a4,a3,0x1c
 84c:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 84e:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 852:	00000717          	auipc	a4,0x0
 856:	7aa73723          	sd	a0,1966(a4) # 1000 <freep>
      return (void*)(p + 1);
 85a:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 85e:	70e2                	ld	ra,56(sp)
 860:	7442                	ld	s0,48(sp)
 862:	74a2                	ld	s1,40(sp)
 864:	7902                	ld	s2,32(sp)
 866:	69e2                	ld	s3,24(sp)
 868:	6a42                	ld	s4,16(sp)
 86a:	6aa2                	ld	s5,8(sp)
 86c:	6b02                	ld	s6,0(sp)
 86e:	6121                	addi	sp,sp,64
 870:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 872:	6398                	ld	a4,0(a5)
 874:	e118                	sd	a4,0(a0)
 876:	bff1                	j	852 <malloc+0x88>
  hp->s.size = nu;
 878:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 87c:	0541                	addi	a0,a0,16
 87e:	00000097          	auipc	ra,0x0
 882:	eca080e7          	jalr	-310(ra) # 748 <free>
  return freep;
 886:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 88a:	d971                	beqz	a0,85e <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 88c:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 88e:	4798                	lw	a4,8(a5)
 890:	fa9775e3          	bgeu	a4,s1,83a <malloc+0x70>
    if(p == freep)
 894:	00093703          	ld	a4,0(s2)
 898:	853e                	mv	a0,a5
 89a:	fef719e3          	bne	a4,a5,88c <malloc+0xc2>
  p = sbrk(nu * sizeof(Header));
 89e:	8552                	mv	a0,s4
 8a0:	00000097          	auipc	ra,0x0
 8a4:	b8a080e7          	jalr	-1142(ra) # 42a <sbrk>
  if(p == (char*)-1)
 8a8:	fd5518e3          	bne	a0,s5,878 <malloc+0xae>
        return 0;
 8ac:	4501                	li	a0,0
 8ae:	bf45                	j	85e <malloc+0x94>

00000000000008b0 <get_current_tid>:
struct ulthread *scheduler_thread;
enum ulthread_scheduling_algorithm algorithm;

/* Get thread ID */
int get_current_tid(void)
{
 8b0:	1141                	addi	sp,sp,-16
 8b2:	e422                	sd	s0,8(sp)
 8b4:	0800                	addi	s0,sp,16
  return current_thread->tid;
}
 8b6:	00000797          	auipc	a5,0x0
 8ba:	7627b783          	ld	a5,1890(a5) # 1018 <current_thread>
 8be:	43c8                	lw	a0,4(a5)
 8c0:	6422                	ld	s0,8(sp)
 8c2:	0141                	addi	sp,sp,16
 8c4:	8082                	ret

00000000000008c6 <roundRobin>:

void roundRobin(void)
{
 8c6:	715d                	addi	sp,sp,-80
 8c8:	e486                	sd	ra,72(sp)
 8ca:	e0a2                	sd	s0,64(sp)
 8cc:	fc26                	sd	s1,56(sp)
 8ce:	f84a                	sd	s2,48(sp)
 8d0:	f44e                	sd	s3,40(sp)
 8d2:	f052                	sd	s4,32(sp)
 8d4:	ec56                	sd	s5,24(sp)
 8d6:	e85a                	sd	s6,16(sp)
 8d8:	e45e                	sd	s7,8(sp)
 8da:	e062                	sd	s8,0(sp)
 8dc:	0880                	addi	s0,sp,80
        struct ulthread *temp = current_thread;
        current_thread = t;
        printf("[*] ultschedule (next tid: %d)\n", get_current_tid());
        ulthread_context_switch(&temp->context, &t->context);
      }
      if (t->state == YIELD)
 8de:	4a09                	li	s4,2
      if (t->state == RUNNABLE && t != scheduler_thread)
 8e0:	00000b97          	auipc	s7,0x0
 8e4:	730b8b93          	addi	s7,s7,1840 # 1010 <scheduler_thread>
        struct ulthread *temp = current_thread;
 8e8:	00000a97          	auipc	s5,0x0
 8ec:	730a8a93          	addi	s5,s5,1840 # 1018 <current_thread>
        printf("[*] ultschedule (next tid: %d)\n", get_current_tid());
 8f0:	00000c17          	auipc	s8,0x0
 8f4:	5e0c0c13          	addi	s8,s8,1504 # ed0 <digits+0x18>
    for (t = ulthreads; t < &ulthreads[MAXULTHREADS]; t++)
 8f8:	00004997          	auipc	s3,0x4
 8fc:	e5898993          	addi	s3,s3,-424 # 4750 <ulthreads+0x3520>
 900:	a0b9                	j	94e <roundRobin+0x88>
      if (t->state == RUNNABLE && t != scheduler_thread)
 902:	000bb783          	ld	a5,0(s7)
 906:	02978863          	beq	a5,s1,936 <roundRobin+0x70>
        struct ulthread *temp = current_thread;
 90a:	000abb03          	ld	s6,0(s5)
        current_thread = t;
 90e:	009ab023          	sd	s1,0(s5)
        printf("[*] ultschedule (next tid: %d)\n", get_current_tid());
 912:	40cc                	lw	a1,4(s1)
 914:	8562                	mv	a0,s8
 916:	00000097          	auipc	ra,0x0
 91a:	dfc080e7          	jalr	-516(ra) # 712 <printf>
        ulthread_context_switch(&temp->context, &t->context);
 91e:	01848593          	addi	a1,s1,24
 922:	018b0513          	addi	a0,s6,24
 926:	00000097          	auipc	ra,0x0
 92a:	46a080e7          	jalr	1130(ra) # d90 <ulthread_context_switch>
        threadAvailable = true;
 92e:	874a                	mv	a4,s2
 930:	a811                	j	944 <roundRobin+0x7e>
      {
        t->state = RUNNABLE;
 932:	0124a023          	sw	s2,0(s1)
    for (t = ulthreads; t < &ulthreads[MAXULTHREADS]; t++)
 936:	08848493          	addi	s1,s1,136
 93a:	01348963          	beq	s1,s3,94c <roundRobin+0x86>
      if (t->state == RUNNABLE && t != scheduler_thread)
 93e:	409c                	lw	a5,0(s1)
 940:	fd2781e3          	beq	a5,s2,902 <roundRobin+0x3c>
      if (t->state == YIELD)
 944:	409c                	lw	a5,0(s1)
 946:	ff4798e3          	bne	a5,s4,936 <roundRobin+0x70>
 94a:	b7e5                	j	932 <roundRobin+0x6c>
      }
    }
    if (!threadAvailable)
 94c:	cb01                	beqz	a4,95c <roundRobin+0x96>
    bool threadAvailable = false;
 94e:	4701                	li	a4,0
    for (t = ulthreads; t < &ulthreads[MAXULTHREADS]; t++)
 950:	00001497          	auipc	s1,0x1
 954:	8e048493          	addi	s1,s1,-1824 # 1230 <ulthreads>
      if (t->state == RUNNABLE && t != scheduler_thread)
 958:	4905                	li	s2,1
 95a:	b7d5                	j	93e <roundRobin+0x78>
    {
      break;
    }
  }
}
 95c:	60a6                	ld	ra,72(sp)
 95e:	6406                	ld	s0,64(sp)
 960:	74e2                	ld	s1,56(sp)
 962:	7942                	ld	s2,48(sp)
 964:	79a2                	ld	s3,40(sp)
 966:	7a02                	ld	s4,32(sp)
 968:	6ae2                	ld	s5,24(sp)
 96a:	6b42                	ld	s6,16(sp)
 96c:	6ba2                	ld	s7,8(sp)
 96e:	6c02                	ld	s8,0(sp)
 970:	6161                	addi	sp,sp,80
 972:	8082                	ret

0000000000000974 <firstComeFirstServe>:

void firstComeFirstServe(void)
{
 974:	715d                	addi	sp,sp,-80
 976:	e486                	sd	ra,72(sp)
 978:	e0a2                	sd	s0,64(sp)
 97a:	fc26                	sd	s1,56(sp)
 97c:	f84a                	sd	s2,48(sp)
 97e:	f44e                	sd	s3,40(sp)
 980:	f052                	sd	s4,32(sp)
 982:	ec56                	sd	s5,24(sp)
 984:	e85a                	sd	s6,16(sp)
 986:	e45e                	sd	s7,8(sp)
 988:	e062                	sd	s8,0(sp)
 98a:	0880                	addi	s0,sp,80
    uint64 oldest = __INT64_MAX__;
    int threadIndex = -1;
    int alternativeIndex = -1;
    for (t = ulthreads+1; t < &ulthreads[MAXULTHREADS]; t++)
    {
      if (t->state == RUNNABLE && t != scheduler_thread && t->lastTime < oldest)
 98c:	00000b97          	auipc	s7,0x0
 990:	684b8b93          	addi	s7,s7,1668 # 1010 <scheduler_thread>
    int alternativeIndex = -1;
 994:	5afd                	li	s5,-1
    uint64 oldest = __INT64_MAX__;
 996:	001adb13          	srli	s6,s5,0x1
      if (t->state == RUNNABLE && t != scheduler_thread && t->lastTime < oldest)
 99a:	4485                	li	s1,1
        oldest = t->lastTime;
        threadIndex = t->tid;
        threadAvailable = true;
      }

      if (t->state == YIELD){
 99c:	4989                	li	s3,2
    for (t = ulthreads+1; t < &ulthreads[MAXULTHREADS]; t++)
 99e:	00004917          	auipc	s2,0x4
 9a2:	db290913          	addi	s2,s2,-590 # 4750 <ulthreads+0x3520>
        break;
      }
      
    }
    label : 
      struct ulthread *temp = current_thread;
 9a6:	00000a17          	auipc	s4,0x0
 9aa:	672a0a13          	addi	s4,s4,1650 # 1018 <current_thread>
 9ae:	a88d                	j	a20 <firstComeFirstServe+0xac>
      if (t->state == RUNNABLE && t != scheduler_thread && t->lastTime < oldest)
 9b0:	00f58963          	beq	a1,a5,9c2 <firstComeFirstServe+0x4e>
 9b4:	6b98                	ld	a4,16(a5)
 9b6:	00c77663          	bgeu	a4,a2,9c2 <firstComeFirstServe+0x4e>
        threadIndex = t->tid;
 9ba:	0047a803          	lw	a6,4(a5)
        oldest = t->lastTime;
 9be:	863a                	mv	a2,a4
        threadAvailable = true;
 9c0:	8526                	mv	a0,s1
    for (t = ulthreads+1; t < &ulthreads[MAXULTHREADS]; t++)
 9c2:	08878793          	addi	a5,a5,136
 9c6:	01278a63          	beq	a5,s2,9da <firstComeFirstServe+0x66>
      if (t->state == RUNNABLE && t != scheduler_thread && t->lastTime < oldest)
 9ca:	4398                	lw	a4,0(a5)
 9cc:	fe9702e3          	beq	a4,s1,9b0 <firstComeFirstServe+0x3c>
      if (t->state == YIELD){
 9d0:	ff3719e3          	bne	a4,s3,9c2 <firstComeFirstServe+0x4e>
        t->state = RUNNABLE;
 9d4:	c384                	sw	s1,0(a5)
        alternativeIndex = t->tid;
 9d6:	43d4                	lw	a3,4(a5)
 9d8:	b7ed                	j	9c2 <firstComeFirstServe+0x4e>
    if (!threadAvailable)
 9da:	ed31                	bnez	a0,a36 <firstComeFirstServe+0xc2>
      if(alternativeIndex > 0){
 9dc:	04d05f63          	blez	a3,a3a <firstComeFirstServe+0xc6>
      struct ulthread *temp = current_thread;
 9e0:	000a3c03          	ld	s8,0(s4)
      current_thread = &ulthreads[threadIndex];
 9e4:	00469793          	slli	a5,a3,0x4
 9e8:	00d78733          	add	a4,a5,a3
 9ec:	070e                	slli	a4,a4,0x3
 9ee:	00001617          	auipc	a2,0x1
 9f2:	84260613          	addi	a2,a2,-1982 # 1230 <ulthreads>
 9f6:	9732                	add	a4,a4,a2
 9f8:	00ea3023          	sd	a4,0(s4)
      printf("[*] ultschedule (next tid: %d), time = %d\n", get_current_tid());
 9fc:	434c                	lw	a1,4(a4)
 9fe:	00000517          	auipc	a0,0x0
 a02:	4f250513          	addi	a0,a0,1266 # ef0 <digits+0x38>
 a06:	00000097          	auipc	ra,0x0
 a0a:	d0c080e7          	jalr	-756(ra) # 712 <printf>
      ulthread_context_switch(&temp->context, &current_thread->context);
 a0e:	000a3583          	ld	a1,0(s4)
 a12:	05e1                	addi	a1,a1,24
 a14:	018c0513          	addi	a0,s8,24
 a18:	00000097          	auipc	ra,0x0
 a1c:	378080e7          	jalr	888(ra) # d90 <ulthread_context_switch>
      if (t->state == RUNNABLE && t != scheduler_thread && t->lastTime < oldest)
 a20:	000bb583          	ld	a1,0(s7)
    int alternativeIndex = -1;
 a24:	86d6                	mv	a3,s5
    int threadIndex = -1;
 a26:	8856                	mv	a6,s5
    uint64 oldest = __INT64_MAX__;
 a28:	865a                	mv	a2,s6
    bool threadAvailable = false;
 a2a:	4501                	li	a0,0
    for (t = ulthreads+1; t < &ulthreads[MAXULTHREADS]; t++)
 a2c:	00001797          	auipc	a5,0x1
 a30:	88c78793          	addi	a5,a5,-1908 # 12b8 <ulthreads+0x88>
 a34:	bf59                	j	9ca <firstComeFirstServe+0x56>
    label : 
 a36:	86c2                	mv	a3,a6
 a38:	b765                	j	9e0 <firstComeFirstServe+0x6c>
  }
}
 a3a:	60a6                	ld	ra,72(sp)
 a3c:	6406                	ld	s0,64(sp)
 a3e:	74e2                	ld	s1,56(sp)
 a40:	7942                	ld	s2,48(sp)
 a42:	79a2                	ld	s3,40(sp)
 a44:	7a02                	ld	s4,32(sp)
 a46:	6ae2                	ld	s5,24(sp)
 a48:	6b42                	ld	s6,16(sp)
 a4a:	6ba2                	ld	s7,8(sp)
 a4c:	6c02                	ld	s8,0(sp)
 a4e:	6161                	addi	sp,sp,80
 a50:	8082                	ret

0000000000000a52 <priorityScheduling>:


void priorityScheduling(void)
{
 a52:	715d                	addi	sp,sp,-80
 a54:	e486                	sd	ra,72(sp)
 a56:	e0a2                	sd	s0,64(sp)
 a58:	fc26                	sd	s1,56(sp)
 a5a:	f84a                	sd	s2,48(sp)
 a5c:	f44e                	sd	s3,40(sp)
 a5e:	f052                	sd	s4,32(sp)
 a60:	ec56                	sd	s5,24(sp)
 a62:	e85a                	sd	s6,16(sp)
 a64:	e45e                	sd	s7,8(sp)
 a66:	0880                	addi	s0,sp,80
    int maxPriority = -1;
    int threadIndex = -1;
    int alternativeIndex = -1;
    for (t = ulthreads+1; t < &ulthreads[MAXULTHREADS]; t++)
    {
      if (t->state == RUNNABLE && t != scheduler_thread && t->priority > maxPriority)
 a68:	00000b17          	auipc	s6,0x0
 a6c:	5a8b0b13          	addi	s6,s6,1448 # 1010 <scheduler_thread>
    int alternativeIndex = -1;
 a70:	5a7d                	li	s4,-1
      if (t->state == RUNNABLE && t != scheduler_thread && t->priority > maxPriority)
 a72:	4485                	li	s1,1
        // flag = true;

        // break; // switch to highest-priority thread and exit loop
      }

      if (t->state == YIELD){
 a74:	4989                	li	s3,2
    for (t = ulthreads+1; t < &ulthreads[MAXULTHREADS]; t++)
 a76:	00004917          	auipc	s2,0x4
 a7a:	cda90913          	addi	s2,s2,-806 # 4750 <ulthreads+0x3520>
        break;
      }
      
    }
    label : 
      struct ulthread *temp = current_thread;
 a7e:	00000a97          	auipc	s5,0x0
 a82:	59aa8a93          	addi	s5,s5,1434 # 1018 <current_thread>
 a86:	a88d                	j	af8 <priorityScheduling+0xa6>
      if (t->state == RUNNABLE && t != scheduler_thread && t->priority > maxPriority)
 a88:	00f58963          	beq	a1,a5,a9a <priorityScheduling+0x48>
 a8c:	47d8                	lw	a4,12(a5)
 a8e:	00e65663          	bge	a2,a4,a9a <priorityScheduling+0x48>
        threadIndex = t->tid;
 a92:	0047a803          	lw	a6,4(a5)
        maxPriority = t->priority;
 a96:	863a                	mv	a2,a4
        threadAvailable = true;
 a98:	8526                	mv	a0,s1
    for (t = ulthreads+1; t < &ulthreads[MAXULTHREADS]; t++)
 a9a:	08878793          	addi	a5,a5,136
 a9e:	01278a63          	beq	a5,s2,ab2 <priorityScheduling+0x60>
      if (t->state == RUNNABLE && t != scheduler_thread && t->priority > maxPriority)
 aa2:	4398                	lw	a4,0(a5)
 aa4:	fe9702e3          	beq	a4,s1,a88 <priorityScheduling+0x36>
      if (t->state == YIELD){
 aa8:	ff3719e3          	bne	a4,s3,a9a <priorityScheduling+0x48>
        t->state = RUNNABLE;
 aac:	c384                	sw	s1,0(a5)
        alternativeIndex = t->tid;
 aae:	43d4                	lw	a3,4(a5)
 ab0:	b7ed                	j	a9a <priorityScheduling+0x48>
    if (!threadAvailable)
 ab2:	ed31                	bnez	a0,b0e <priorityScheduling+0xbc>
      if(alternativeIndex > 0){
 ab4:	04d05f63          	blez	a3,b12 <priorityScheduling+0xc0>
      struct ulthread *temp = current_thread;
 ab8:	000abb83          	ld	s7,0(s5)
      current_thread = &ulthreads[threadIndex];
 abc:	00469793          	slli	a5,a3,0x4
 ac0:	00d78733          	add	a4,a5,a3
 ac4:	070e                	slli	a4,a4,0x3
 ac6:	00000617          	auipc	a2,0x0
 aca:	76a60613          	addi	a2,a2,1898 # 1230 <ulthreads>
 ace:	9732                	add	a4,a4,a2
 ad0:	00eab023          	sd	a4,0(s5)
      printf("[*] ultschedule (next tid: %d)\n", get_current_tid());
 ad4:	434c                	lw	a1,4(a4)
 ad6:	00000517          	auipc	a0,0x0
 ada:	3fa50513          	addi	a0,a0,1018 # ed0 <digits+0x18>
 ade:	00000097          	auipc	ra,0x0
 ae2:	c34080e7          	jalr	-972(ra) # 712 <printf>
      ulthread_context_switch(&temp->context, &current_thread->context);
 ae6:	000ab583          	ld	a1,0(s5)
 aea:	05e1                	addi	a1,a1,24
 aec:	018b8513          	addi	a0,s7,24
 af0:	00000097          	auipc	ra,0x0
 af4:	2a0080e7          	jalr	672(ra) # d90 <ulthread_context_switch>
      if (t->state == RUNNABLE && t != scheduler_thread && t->priority > maxPriority)
 af8:	000b3583          	ld	a1,0(s6)
    int alternativeIndex = -1;
 afc:	86d2                	mv	a3,s4
    int threadIndex = -1;
 afe:	8852                	mv	a6,s4
    int maxPriority = -1;
 b00:	8652                	mv	a2,s4
    bool threadAvailable = false;
 b02:	4501                	li	a0,0
    for (t = ulthreads+1; t < &ulthreads[MAXULTHREADS]; t++)
 b04:	00000797          	auipc	a5,0x0
 b08:	7b478793          	addi	a5,a5,1972 # 12b8 <ulthreads+0x88>
 b0c:	bf59                	j	aa2 <priorityScheduling+0x50>
    label : 
 b0e:	86c2                	mv	a3,a6
 b10:	b765                	j	ab8 <priorityScheduling+0x66>
  }
}
 b12:	60a6                	ld	ra,72(sp)
 b14:	6406                	ld	s0,64(sp)
 b16:	74e2                	ld	s1,56(sp)
 b18:	7942                	ld	s2,48(sp)
 b1a:	79a2                	ld	s3,40(sp)
 b1c:	7a02                	ld	s4,32(sp)
 b1e:	6ae2                	ld	s5,24(sp)
 b20:	6b42                	ld	s6,16(sp)
 b22:	6ba2                	ld	s7,8(sp)
 b24:	6161                	addi	sp,sp,80
 b26:	8082                	ret

0000000000000b28 <ulthread_init>:

/* Thread initialization */
void ulthread_init(int schedalgo)
{
 b28:	1141                	addi	sp,sp,-16
 b2a:	e422                	sd	s0,8(sp)
 b2c:	0800                	addi	s0,sp,16
  struct ulthread *t;
  int i;
  for (i = 0, t = ulthreads; t < &ulthreads[MAXULTHREADS]; t++, i++)
 b2e:	4701                	li	a4,0
 b30:	00000797          	auipc	a5,0x0
 b34:	70078793          	addi	a5,a5,1792 # 1230 <ulthreads>
 b38:	00004697          	auipc	a3,0x4
 b3c:	c1868693          	addi	a3,a3,-1000 # 4750 <ulthreads+0x3520>
  {
    t->state = FREE;
 b40:	0007a023          	sw	zero,0(a5)
    t->tid = i;
 b44:	c3d8                	sw	a4,4(a5)
  for (i = 0, t = ulthreads; t < &ulthreads[MAXULTHREADS]; t++, i++)
 b46:	08878793          	addi	a5,a5,136
 b4a:	2705                	addiw	a4,a4,1
 b4c:	fed79ae3          	bne	a5,a3,b40 <ulthread_init+0x18>
  }
  current_thread = &ulthreads[0];
 b50:	00000797          	auipc	a5,0x0
 b54:	6e078793          	addi	a5,a5,1760 # 1230 <ulthreads>
 b58:	00000717          	auipc	a4,0x0
 b5c:	4cf73023          	sd	a5,1216(a4) # 1018 <current_thread>
  scheduler_thread = &ulthreads[0];
 b60:	00000717          	auipc	a4,0x0
 b64:	4af73823          	sd	a5,1200(a4) # 1010 <scheduler_thread>
  scheduler_thread->state = RUNNABLE;
 b68:	4705                	li	a4,1
 b6a:	c398                	sw	a4,0(a5)
  t->state = FREE;
 b6c:	00004797          	auipc	a5,0x4
 b70:	be07a223          	sw	zero,-1052(a5) # 4750 <ulthreads+0x3520>
  algorithm = schedalgo;
 b74:	00000797          	auipc	a5,0x0
 b78:	48a7aa23          	sw	a0,1172(a5) # 1008 <algorithm>
}
 b7c:	6422                	ld	s0,8(sp)
 b7e:	0141                	addi	sp,sp,16
 b80:	8082                	ret

0000000000000b82 <ulthread_create>:

/* Thread creation */
bool ulthread_create(uint64 start, uint64 stack, uint64 args[], int priority)
{
 b82:	7179                	addi	sp,sp,-48
 b84:	f406                	sd	ra,40(sp)
 b86:	f022                	sd	s0,32(sp)
 b88:	ec26                	sd	s1,24(sp)
 b8a:	e84a                	sd	s2,16(sp)
 b8c:	e44e                	sd	s3,8(sp)
 b8e:	e052                	sd	s4,0(sp)
 b90:	1800                	addi	s0,sp,48
 b92:	89aa                	mv	s3,a0
 b94:	8a2e                	mv	s4,a1
 b96:	8932                	mv	s2,a2
  /* Please add thread-id instead of '0' here. */
  struct ulthread *t;
  bool flag = false;
  for (t = ulthreads; t < &ulthreads[MAXULTHREADS]; t++)
 b98:	00000497          	auipc	s1,0x0
 b9c:	69848493          	addi	s1,s1,1688 # 1230 <ulthreads>
 ba0:	00004717          	auipc	a4,0x4
 ba4:	bb070713          	addi	a4,a4,-1104 # 4750 <ulthreads+0x3520>
  {
    if (t->state == FREE)
 ba8:	409c                	lw	a5,0(s1)
 baa:	cf89                	beqz	a5,bc4 <ulthread_create+0x42>
  for (t = ulthreads; t < &ulthreads[MAXULTHREADS]; t++)
 bac:	08848493          	addi	s1,s1,136
 bb0:	fee49ce3          	bne	s1,a4,ba8 <ulthread_create+0x26>
      break;
    }
  }
  if (!flag)
  {
    return false;
 bb4:	4501                	li	a0,0
 bb6:	a871                	j	c52 <ulthread_create+0xd0>
  t->sp = (int)(stack + USTACKSIZE); // set sp to the top of the stack
  t->state = RUNNABLE;
  t->priority = priority;

  if(algorithm==FCFS){
    t->lastTime = ctime();
 bb8:	00000097          	auipc	ra,0x0
 bbc:	88a080e7          	jalr	-1910(ra) # 442 <ctime>
 bc0:	e888                	sd	a0,16(s1)
 bc2:	a839                	j	be0 <ulthread_create+0x5e>
  t->sp = (int)(stack + USTACKSIZE); // set sp to the top of the stack
 bc4:	6785                	lui	a5,0x1
 bc6:	014787bb          	addw	a5,a5,s4
 bca:	c49c                	sw	a5,8(s1)
  t->state = RUNNABLE;
 bcc:	4785                	li	a5,1
 bce:	c09c                	sw	a5,0(s1)
  t->priority = priority;
 bd0:	c4d4                	sw	a3,12(s1)
  if(algorithm==FCFS){
 bd2:	00000717          	auipc	a4,0x0
 bd6:	43672703          	lw	a4,1078(a4) # 1008 <algorithm>
 bda:	4789                	li	a5,2
 bdc:	fcf70ee3          	beq	a4,a5,bb8 <ulthread_create+0x36>
  }

  for (int argc = 0; argc < 6; argc++)
 be0:	874a                	mv	a4,s2
 be2:	03090693          	addi	a3,s2,48
  {
    t->sp -= 16;
 be6:	449c                	lw	a5,8(s1)
 be8:	37c1                	addiw	a5,a5,-16 # ff0 <digits+0x138>
 bea:	0007881b          	sext.w	a6,a5
 bee:	c49c                	sw	a5,8(s1)
    *(uint64 *)(t->sp) = (uint64)args[argc];
 bf0:	631c                	ld	a5,0(a4)
 bf2:	00f83023          	sd	a5,0(a6)
  for (int argc = 0; argc < 6; argc++)
 bf6:	0721                	addi	a4,a4,8
 bf8:	fed717e3          	bne	a4,a3,be6 <ulthread_create+0x64>
  }

  memset(&t->context, 0, sizeof(t->context));
 bfc:	07000613          	li	a2,112
 c00:	4581                	li	a1,0
 c02:	01848513          	addi	a0,s1,24
 c06:	fffff097          	auipc	ra,0xfffff
 c0a:	5a2080e7          	jalr	1442(ra) # 1a8 <memset>
  t->context.ra = start;
 c0e:	0134bc23          	sd	s3,24(s1)
  t->context.sp = t->sp;
 c12:	449c                	lw	a5,8(s1)
 c14:	f09c                	sd	a5,32(s1)
  t->context.s0 = args[0];
 c16:	00093783          	ld	a5,0(s2)
 c1a:	f49c                	sd	a5,40(s1)
  t->context.s1 = args[1];
 c1c:	00893783          	ld	a5,8(s2)
 c20:	f89c                	sd	a5,48(s1)
  t->context.s2 = args[2];
 c22:	01093783          	ld	a5,16(s2)
 c26:	fc9c                	sd	a5,56(s1)
  t->context.s3 = args[3];
 c28:	01893783          	ld	a5,24(s2)
 c2c:	e0bc                	sd	a5,64(s1)
  t->context.s4 = args[4];
 c2e:	02093783          	ld	a5,32(s2)
 c32:	e4bc                	sd	a5,72(s1)
  t->context.s5 = args[5];
 c34:	02893783          	ld	a5,40(s2)
 c38:	e8bc                	sd	a5,80(s1)

  printf("[*] ultcreate(tid: %d, ra: %p, sp: %p)\n", t->tid, start, stack);
 c3a:	86d2                	mv	a3,s4
 c3c:	864e                	mv	a2,s3
 c3e:	40cc                	lw	a1,4(s1)
 c40:	00000517          	auipc	a0,0x0
 c44:	2e050513          	addi	a0,a0,736 # f20 <digits+0x68>
 c48:	00000097          	auipc	ra,0x0
 c4c:	aca080e7          	jalr	-1334(ra) # 712 <printf>
  return true;
 c50:	4505                	li	a0,1
}
 c52:	70a2                	ld	ra,40(sp)
 c54:	7402                	ld	s0,32(sp)
 c56:	64e2                	ld	s1,24(sp)
 c58:	6942                	ld	s2,16(sp)
 c5a:	69a2                	ld	s3,8(sp)
 c5c:	6a02                	ld	s4,0(sp)
 c5e:	6145                	addi	sp,sp,48
 c60:	8082                	ret

0000000000000c62 <ulthread_schedule>:

/* Thread scheduler */
void ulthread_schedule(void)
{
 c62:	1141                	addi	sp,sp,-16
 c64:	e406                	sd	ra,8(sp)
 c66:	e022                	sd	s0,0(sp)
 c68:	0800                	addi	s0,sp,16
  switch (algorithm)
 c6a:	00000797          	auipc	a5,0x0
 c6e:	39e7a783          	lw	a5,926(a5) # 1008 <algorithm>
 c72:	4705                	li	a4,1
 c74:	02e78463          	beq	a5,a4,c9c <ulthread_schedule+0x3a>
 c78:	4709                	li	a4,2
 c7a:	00e78c63          	beq	a5,a4,c92 <ulthread_schedule+0x30>
 c7e:	c789                	beqz	a5,c88 <ulthread_schedule+0x26>

  // Push argument strings, prepare rest of stack in ustack.

  // Switch between thread contexts
  // ulthread_context_switch(NULL, NULL);
}
 c80:	60a2                	ld	ra,8(sp)
 c82:	6402                	ld	s0,0(sp)
 c84:	0141                	addi	sp,sp,16
 c86:	8082                	ret
    roundRobin();
 c88:	00000097          	auipc	ra,0x0
 c8c:	c3e080e7          	jalr	-962(ra) # 8c6 <roundRobin>
    break;
 c90:	bfc5                	j	c80 <ulthread_schedule+0x1e>
    firstComeFirstServe();
 c92:	00000097          	auipc	ra,0x0
 c96:	ce2080e7          	jalr	-798(ra) # 974 <firstComeFirstServe>
    break;
 c9a:	b7dd                	j	c80 <ulthread_schedule+0x1e>
    priorityScheduling();
 c9c:	00000097          	auipc	ra,0x0
 ca0:	db6080e7          	jalr	-586(ra) # a52 <priorityScheduling>
}
 ca4:	bff1                	j	c80 <ulthread_schedule+0x1e>

0000000000000ca6 <ulthread_yield>:

/* Yield CPU time to some other thread. */
void ulthread_yield(void)
{
 ca6:	1101                	addi	sp,sp,-32
 ca8:	ec06                	sd	ra,24(sp)
 caa:	e822                	sd	s0,16(sp)
 cac:	e426                	sd	s1,8(sp)
 cae:	e04a                	sd	s2,0(sp)
 cb0:	1000                	addi	s0,sp,32
  current_thread->state = YIELD;
 cb2:	00000797          	auipc	a5,0x0
 cb6:	36678793          	addi	a5,a5,870 # 1018 <current_thread>
 cba:	6398                	ld	a4,0(a5)
 cbc:	4909                	li	s2,2
 cbe:	01272023          	sw	s2,0(a4)
  struct ulthread *temp = current_thread;
 cc2:	6384                	ld	s1,0(a5)
  printf("[*] ultyield(tid: %d)\n", current_thread->tid);
 cc4:	40cc                	lw	a1,4(s1)
 cc6:	00000517          	auipc	a0,0x0
 cca:	28250513          	addi	a0,a0,642 # f48 <digits+0x90>
 cce:	00000097          	auipc	ra,0x0
 cd2:	a44080e7          	jalr	-1468(ra) # 712 <printf>
  if(algorithm==FCFS){
 cd6:	00000797          	auipc	a5,0x0
 cda:	3327a783          	lw	a5,818(a5) # 1008 <algorithm>
 cde:	03278763          	beq	a5,s2,d0c <ulthread_yield+0x66>
    current_thread->lastTime = ctime();
  }
  current_thread = scheduler_thread;
 ce2:	00000597          	auipc	a1,0x0
 ce6:	32e5b583          	ld	a1,814(a1) # 1010 <scheduler_thread>
 cea:	00000797          	auipc	a5,0x0
 cee:	32b7b723          	sd	a1,814(a5) # 1018 <current_thread>
  
  ulthread_context_switch(&temp->context, &scheduler_thread->context);
 cf2:	05e1                	addi	a1,a1,24
 cf4:	01848513          	addi	a0,s1,24
 cf8:	00000097          	auipc	ra,0x0
 cfc:	098080e7          	jalr	152(ra) # d90 <ulthread_context_switch>
  // ulthread_schedule();
}
 d00:	60e2                	ld	ra,24(sp)
 d02:	6442                	ld	s0,16(sp)
 d04:	64a2                	ld	s1,8(sp)
 d06:	6902                	ld	s2,0(sp)
 d08:	6105                	addi	sp,sp,32
 d0a:	8082                	ret
    current_thread->lastTime = ctime();
 d0c:	fffff097          	auipc	ra,0xfffff
 d10:	736080e7          	jalr	1846(ra) # 442 <ctime>
 d14:	00000797          	auipc	a5,0x0
 d18:	3047b783          	ld	a5,772(a5) # 1018 <current_thread>
 d1c:	eb88                	sd	a0,16(a5)
 d1e:	b7d1                	j	ce2 <ulthread_yield+0x3c>

0000000000000d20 <ulthread_destroy>:

/* Destroy thread */
void ulthread_destroy(void)
{
 d20:	1101                	addi	sp,sp,-32
 d22:	ec06                	sd	ra,24(sp)
 d24:	e822                	sd	s0,16(sp)
 d26:	e426                	sd	s1,8(sp)
 d28:	e04a                	sd	s2,0(sp)
 d2a:	1000                	addi	s0,sp,32
  memset(&current_thread->context, 0, sizeof(current_thread->context));
 d2c:	00000497          	auipc	s1,0x0
 d30:	2ec48493          	addi	s1,s1,748 # 1018 <current_thread>
 d34:	6088                	ld	a0,0(s1)
 d36:	07000613          	li	a2,112
 d3a:	4581                	li	a1,0
 d3c:	0561                	addi	a0,a0,24
 d3e:	fffff097          	auipc	ra,0xfffff
 d42:	46a080e7          	jalr	1130(ra) # 1a8 <memset>
  current_thread->sp = 0;
 d46:	609c                	ld	a5,0(s1)
 d48:	0007a423          	sw	zero,8(a5)
  current_thread->priority = -1;
 d4c:	577d                	li	a4,-1
 d4e:	c7d8                	sw	a4,12(a5)
  current_thread->state = FREE;
 d50:	0007a023          	sw	zero,0(a5)

  struct ulthread *temp = current_thread;
 d54:	0004b903          	ld	s2,0(s1)

  printf("[*] ultdestroy(tid: %d)\n", get_current_tid());
 d58:	00492583          	lw	a1,4(s2)
 d5c:	00000517          	auipc	a0,0x0
 d60:	20450513          	addi	a0,a0,516 # f60 <digits+0xa8>
 d64:	00000097          	auipc	ra,0x0
 d68:	9ae080e7          	jalr	-1618(ra) # 712 <printf>
  current_thread = scheduler_thread;
 d6c:	00000597          	auipc	a1,0x0
 d70:	2a45b583          	ld	a1,676(a1) # 1010 <scheduler_thread>
 d74:	e08c                	sd	a1,0(s1)
  ulthread_context_switch(&temp->context, &scheduler_thread->context);
 d76:	05e1                	addi	a1,a1,24
 d78:	01890513          	addi	a0,s2,24
 d7c:	00000097          	auipc	ra,0x0
 d80:	014080e7          	jalr	20(ra) # d90 <ulthread_context_switch>
}
 d84:	60e2                	ld	ra,24(sp)
 d86:	6442                	ld	s0,16(sp)
 d88:	64a2                	ld	s1,8(sp)
 d8a:	6902                	ld	s2,0(sp)
 d8c:	6105                	addi	sp,sp,32
 d8e:	8082                	ret

0000000000000d90 <ulthread_context_switch>:
 d90:	00153023          	sd	ra,0(a0)
 d94:	00253423          	sd	sp,8(a0)
 d98:	e900                	sd	s0,16(a0)
 d9a:	ed04                	sd	s1,24(a0)
 d9c:	03253023          	sd	s2,32(a0)
 da0:	03353423          	sd	s3,40(a0)
 da4:	03453823          	sd	s4,48(a0)
 da8:	03553c23          	sd	s5,56(a0)
 dac:	05653023          	sd	s6,64(a0)
 db0:	05753423          	sd	s7,72(a0)
 db4:	05853823          	sd	s8,80(a0)
 db8:	05953c23          	sd	s9,88(a0)
 dbc:	07a53023          	sd	s10,96(a0)
 dc0:	07b53423          	sd	s11,104(a0)
 dc4:	0005b083          	ld	ra,0(a1)
 dc8:	0085b103          	ld	sp,8(a1)
 dcc:	6980                	ld	s0,16(a1)
 dce:	6d84                	ld	s1,24(a1)
 dd0:	0205b903          	ld	s2,32(a1)
 dd4:	0285b983          	ld	s3,40(a1)
 dd8:	0305ba03          	ld	s4,48(a1)
 ddc:	0385ba83          	ld	s5,56(a1)
 de0:	0405bb03          	ld	s6,64(a1)
 de4:	0485bb83          	ld	s7,72(a1)
 de8:	0505bc03          	ld	s8,80(a1)
 dec:	0585bc83          	ld	s9,88(a1)
 df0:	0605bd03          	ld	s10,96(a1)
 df4:	0685bd83          	ld	s11,104(a1)
 df8:	6546                	ld	a0,80(sp)
 dfa:	6586                	ld	a1,64(sp)
 dfc:	7642                	ld	a2,48(sp)
 dfe:	7682                	ld	a3,32(sp)
 e00:	6742                	ld	a4,16(sp)
 e02:	6782                	ld	a5,0(sp)
 e04:	8082                	ret
