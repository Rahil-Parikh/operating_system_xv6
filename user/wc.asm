
user/_wc:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <wc>:

char buf[512];

void
wc(int fd, char *name)
{
   0:	7119                	addi	sp,sp,-128
   2:	fc86                	sd	ra,120(sp)
   4:	f8a2                	sd	s0,112(sp)
   6:	f4a6                	sd	s1,104(sp)
   8:	f0ca                	sd	s2,96(sp)
   a:	ecce                	sd	s3,88(sp)
   c:	e8d2                	sd	s4,80(sp)
   e:	e4d6                	sd	s5,72(sp)
  10:	e0da                	sd	s6,64(sp)
  12:	fc5e                	sd	s7,56(sp)
  14:	f862                	sd	s8,48(sp)
  16:	f466                	sd	s9,40(sp)
  18:	f06a                	sd	s10,32(sp)
  1a:	ec6e                	sd	s11,24(sp)
  1c:	0100                	addi	s0,sp,128
  1e:	f8a43423          	sd	a0,-120(s0)
  22:	f8b43023          	sd	a1,-128(s0)
  int i, n;
  int l, w, c, inword;

  l = w = c = 0;
  inword = 0;
  26:	4901                	li	s2,0
  l = w = c = 0;
  28:	4d01                	li	s10,0
  2a:	4c81                	li	s9,0
  2c:	4c01                	li	s8,0
  while((n = read(fd, buf, sizeof(buf))) > 0){
  2e:	00001d97          	auipc	s11,0x1
  32:	ff2d8d93          	addi	s11,s11,-14 # 1020 <buf>
    for(i=0; i<n; i++){
      c++;
      if(buf[i] == '\n')
  36:	4aa9                	li	s5,10
        l++;
      if(strchr(" \r\t\n\v", buf[i]))
  38:	00001a17          	auipc	s4,0x1
  3c:	e48a0a13          	addi	s4,s4,-440 # e80 <ulthread_context_switch+0x82>
        inword = 0;
  40:	4b81                	li	s7,0
  while((n = read(fd, buf, sizeof(buf))) > 0){
  42:	a805                	j	72 <wc+0x72>
      if(strchr(" \r\t\n\v", buf[i]))
  44:	8552                	mv	a0,s4
  46:	00000097          	auipc	ra,0x0
  4a:	1f2080e7          	jalr	498(ra) # 238 <strchr>
  4e:	c919                	beqz	a0,64 <wc+0x64>
        inword = 0;
  50:	895e                	mv	s2,s7
    for(i=0; i<n; i++){
  52:	0485                	addi	s1,s1,1
  54:	00998d63          	beq	s3,s1,6e <wc+0x6e>
      if(buf[i] == '\n')
  58:	0004c583          	lbu	a1,0(s1)
  5c:	ff5594e3          	bne	a1,s5,44 <wc+0x44>
        l++;
  60:	2c05                	addiw	s8,s8,1
  62:	b7cd                	j	44 <wc+0x44>
      else if(!inword){
  64:	fe0917e3          	bnez	s2,52 <wc+0x52>
        w++;
  68:	2c85                	addiw	s9,s9,1
        inword = 1;
  6a:	4905                	li	s2,1
  6c:	b7dd                	j	52 <wc+0x52>
      c++;
  6e:	01ab0d3b          	addw	s10,s6,s10
  while((n = read(fd, buf, sizeof(buf))) > 0){
  72:	20000613          	li	a2,512
  76:	85ee                	mv	a1,s11
  78:	f8843503          	ld	a0,-120(s0)
  7c:	00000097          	auipc	ra,0x0
  80:	3ac080e7          	jalr	940(ra) # 428 <read>
  84:	8b2a                	mv	s6,a0
  86:	00a05963          	blez	a0,98 <wc+0x98>
    for(i=0; i<n; i++){
  8a:	00001497          	auipc	s1,0x1
  8e:	f9648493          	addi	s1,s1,-106 # 1020 <buf>
  92:	009509b3          	add	s3,a0,s1
  96:	b7c9                	j	58 <wc+0x58>
      }
    }
  }
  if(n < 0){
  98:	02054e63          	bltz	a0,d4 <wc+0xd4>
    printf("wc: read error\n");
    exit(1);
  }
  printf("%d %d %d %s\n", l, w, c, name);
  9c:	f8043703          	ld	a4,-128(s0)
  a0:	86ea                	mv	a3,s10
  a2:	8666                	mv	a2,s9
  a4:	85e2                	mv	a1,s8
  a6:	00001517          	auipc	a0,0x1
  aa:	df250513          	addi	a0,a0,-526 # e98 <ulthread_context_switch+0x9a>
  ae:	00000097          	auipc	ra,0x0
  b2:	6d2080e7          	jalr	1746(ra) # 780 <printf>
}
  b6:	70e6                	ld	ra,120(sp)
  b8:	7446                	ld	s0,112(sp)
  ba:	74a6                	ld	s1,104(sp)
  bc:	7906                	ld	s2,96(sp)
  be:	69e6                	ld	s3,88(sp)
  c0:	6a46                	ld	s4,80(sp)
  c2:	6aa6                	ld	s5,72(sp)
  c4:	6b06                	ld	s6,64(sp)
  c6:	7be2                	ld	s7,56(sp)
  c8:	7c42                	ld	s8,48(sp)
  ca:	7ca2                	ld	s9,40(sp)
  cc:	7d02                	ld	s10,32(sp)
  ce:	6de2                	ld	s11,24(sp)
  d0:	6109                	addi	sp,sp,128
  d2:	8082                	ret
    printf("wc: read error\n");
  d4:	00001517          	auipc	a0,0x1
  d8:	db450513          	addi	a0,a0,-588 # e88 <ulthread_context_switch+0x8a>
  dc:	00000097          	auipc	ra,0x0
  e0:	6a4080e7          	jalr	1700(ra) # 780 <printf>
    exit(1);
  e4:	4505                	li	a0,1
  e6:	00000097          	auipc	ra,0x0
  ea:	32a080e7          	jalr	810(ra) # 410 <exit>

00000000000000ee <main>:

int
main(int argc, char *argv[])
{
  ee:	7179                	addi	sp,sp,-48
  f0:	f406                	sd	ra,40(sp)
  f2:	f022                	sd	s0,32(sp)
  f4:	ec26                	sd	s1,24(sp)
  f6:	e84a                	sd	s2,16(sp)
  f8:	e44e                	sd	s3,8(sp)
  fa:	1800                	addi	s0,sp,48
  int fd, i;

  if(argc <= 1){
  fc:	4785                	li	a5,1
  fe:	04a7d963          	bge	a5,a0,150 <main+0x62>
 102:	00858913          	addi	s2,a1,8
 106:	ffe5099b          	addiw	s3,a0,-2
 10a:	02099793          	slli	a5,s3,0x20
 10e:	01d7d993          	srli	s3,a5,0x1d
 112:	05c1                	addi	a1,a1,16
 114:	99ae                	add	s3,s3,a1
    wc(0, "");
    exit(0);
  }

  for(i = 1; i < argc; i++){
    if((fd = open(argv[i], 0)) < 0){
 116:	4581                	li	a1,0
 118:	00093503          	ld	a0,0(s2)
 11c:	00000097          	auipc	ra,0x0
 120:	334080e7          	jalr	820(ra) # 450 <open>
 124:	84aa                	mv	s1,a0
 126:	04054363          	bltz	a0,16c <main+0x7e>
      printf("wc: cannot open %s\n", argv[i]);
      exit(1);
    }
    wc(fd, argv[i]);
 12a:	00093583          	ld	a1,0(s2)
 12e:	00000097          	auipc	ra,0x0
 132:	ed2080e7          	jalr	-302(ra) # 0 <wc>
    close(fd);
 136:	8526                	mv	a0,s1
 138:	00000097          	auipc	ra,0x0
 13c:	300080e7          	jalr	768(ra) # 438 <close>
  for(i = 1; i < argc; i++){
 140:	0921                	addi	s2,s2,8
 142:	fd391ae3          	bne	s2,s3,116 <main+0x28>
  }
  exit(0);
 146:	4501                	li	a0,0
 148:	00000097          	auipc	ra,0x0
 14c:	2c8080e7          	jalr	712(ra) # 410 <exit>
    wc(0, "");
 150:	00001597          	auipc	a1,0x1
 154:	e9058593          	addi	a1,a1,-368 # fe0 <digits+0xc0>
 158:	4501                	li	a0,0
 15a:	00000097          	auipc	ra,0x0
 15e:	ea6080e7          	jalr	-346(ra) # 0 <wc>
    exit(0);
 162:	4501                	li	a0,0
 164:	00000097          	auipc	ra,0x0
 168:	2ac080e7          	jalr	684(ra) # 410 <exit>
      printf("wc: cannot open %s\n", argv[i]);
 16c:	00093583          	ld	a1,0(s2)
 170:	00001517          	auipc	a0,0x1
 174:	d3850513          	addi	a0,a0,-712 # ea8 <ulthread_context_switch+0xaa>
 178:	00000097          	auipc	ra,0x0
 17c:	608080e7          	jalr	1544(ra) # 780 <printf>
      exit(1);
 180:	4505                	li	a0,1
 182:	00000097          	auipc	ra,0x0
 186:	28e080e7          	jalr	654(ra) # 410 <exit>

000000000000018a <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
 18a:	1141                	addi	sp,sp,-16
 18c:	e406                	sd	ra,8(sp)
 18e:	e022                	sd	s0,0(sp)
 190:	0800                	addi	s0,sp,16
  extern int main();
  main();
 192:	00000097          	auipc	ra,0x0
 196:	f5c080e7          	jalr	-164(ra) # ee <main>
  exit(0);
 19a:	4501                	li	a0,0
 19c:	00000097          	auipc	ra,0x0
 1a0:	274080e7          	jalr	628(ra) # 410 <exit>

00000000000001a4 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 1a4:	1141                	addi	sp,sp,-16
 1a6:	e422                	sd	s0,8(sp)
 1a8:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 1aa:	87aa                	mv	a5,a0
 1ac:	0585                	addi	a1,a1,1
 1ae:	0785                	addi	a5,a5,1
 1b0:	fff5c703          	lbu	a4,-1(a1)
 1b4:	fee78fa3          	sb	a4,-1(a5)
 1b8:	fb75                	bnez	a4,1ac <strcpy+0x8>
    ;
  return os;
}
 1ba:	6422                	ld	s0,8(sp)
 1bc:	0141                	addi	sp,sp,16
 1be:	8082                	ret

00000000000001c0 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 1c0:	1141                	addi	sp,sp,-16
 1c2:	e422                	sd	s0,8(sp)
 1c4:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 1c6:	00054783          	lbu	a5,0(a0)
 1ca:	cb91                	beqz	a5,1de <strcmp+0x1e>
 1cc:	0005c703          	lbu	a4,0(a1)
 1d0:	00f71763          	bne	a4,a5,1de <strcmp+0x1e>
    p++, q++;
 1d4:	0505                	addi	a0,a0,1
 1d6:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 1d8:	00054783          	lbu	a5,0(a0)
 1dc:	fbe5                	bnez	a5,1cc <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 1de:	0005c503          	lbu	a0,0(a1)
}
 1e2:	40a7853b          	subw	a0,a5,a0
 1e6:	6422                	ld	s0,8(sp)
 1e8:	0141                	addi	sp,sp,16
 1ea:	8082                	ret

00000000000001ec <strlen>:

uint
strlen(const char *s)
{
 1ec:	1141                	addi	sp,sp,-16
 1ee:	e422                	sd	s0,8(sp)
 1f0:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 1f2:	00054783          	lbu	a5,0(a0)
 1f6:	cf91                	beqz	a5,212 <strlen+0x26>
 1f8:	0505                	addi	a0,a0,1
 1fa:	87aa                	mv	a5,a0
 1fc:	86be                	mv	a3,a5
 1fe:	0785                	addi	a5,a5,1
 200:	fff7c703          	lbu	a4,-1(a5)
 204:	ff65                	bnez	a4,1fc <strlen+0x10>
 206:	40a6853b          	subw	a0,a3,a0
 20a:	2505                	addiw	a0,a0,1
    ;
  return n;
}
 20c:	6422                	ld	s0,8(sp)
 20e:	0141                	addi	sp,sp,16
 210:	8082                	ret
  for(n = 0; s[n]; n++)
 212:	4501                	li	a0,0
 214:	bfe5                	j	20c <strlen+0x20>

0000000000000216 <memset>:

void*
memset(void *dst, int c, uint n)
{
 216:	1141                	addi	sp,sp,-16
 218:	e422                	sd	s0,8(sp)
 21a:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 21c:	ca19                	beqz	a2,232 <memset+0x1c>
 21e:	87aa                	mv	a5,a0
 220:	1602                	slli	a2,a2,0x20
 222:	9201                	srli	a2,a2,0x20
 224:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 228:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 22c:	0785                	addi	a5,a5,1
 22e:	fee79de3          	bne	a5,a4,228 <memset+0x12>
  }
  return dst;
}
 232:	6422                	ld	s0,8(sp)
 234:	0141                	addi	sp,sp,16
 236:	8082                	ret

0000000000000238 <strchr>:

char*
strchr(const char *s, char c)
{
 238:	1141                	addi	sp,sp,-16
 23a:	e422                	sd	s0,8(sp)
 23c:	0800                	addi	s0,sp,16
  for(; *s; s++)
 23e:	00054783          	lbu	a5,0(a0)
 242:	cb99                	beqz	a5,258 <strchr+0x20>
    if(*s == c)
 244:	00f58763          	beq	a1,a5,252 <strchr+0x1a>
  for(; *s; s++)
 248:	0505                	addi	a0,a0,1
 24a:	00054783          	lbu	a5,0(a0)
 24e:	fbfd                	bnez	a5,244 <strchr+0xc>
      return (char*)s;
  return 0;
 250:	4501                	li	a0,0
}
 252:	6422                	ld	s0,8(sp)
 254:	0141                	addi	sp,sp,16
 256:	8082                	ret
  return 0;
 258:	4501                	li	a0,0
 25a:	bfe5                	j	252 <strchr+0x1a>

000000000000025c <gets>:

char*
gets(char *buf, int max)
{
 25c:	711d                	addi	sp,sp,-96
 25e:	ec86                	sd	ra,88(sp)
 260:	e8a2                	sd	s0,80(sp)
 262:	e4a6                	sd	s1,72(sp)
 264:	e0ca                	sd	s2,64(sp)
 266:	fc4e                	sd	s3,56(sp)
 268:	f852                	sd	s4,48(sp)
 26a:	f456                	sd	s5,40(sp)
 26c:	f05a                	sd	s6,32(sp)
 26e:	ec5e                	sd	s7,24(sp)
 270:	1080                	addi	s0,sp,96
 272:	8baa                	mv	s7,a0
 274:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 276:	892a                	mv	s2,a0
 278:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 27a:	4aa9                	li	s5,10
 27c:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 27e:	89a6                	mv	s3,s1
 280:	2485                	addiw	s1,s1,1
 282:	0344d863          	bge	s1,s4,2b2 <gets+0x56>
    cc = read(0, &c, 1);
 286:	4605                	li	a2,1
 288:	faf40593          	addi	a1,s0,-81
 28c:	4501                	li	a0,0
 28e:	00000097          	auipc	ra,0x0
 292:	19a080e7          	jalr	410(ra) # 428 <read>
    if(cc < 1)
 296:	00a05e63          	blez	a0,2b2 <gets+0x56>
    buf[i++] = c;
 29a:	faf44783          	lbu	a5,-81(s0)
 29e:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 2a2:	01578763          	beq	a5,s5,2b0 <gets+0x54>
 2a6:	0905                	addi	s2,s2,1
 2a8:	fd679be3          	bne	a5,s6,27e <gets+0x22>
  for(i=0; i+1 < max; ){
 2ac:	89a6                	mv	s3,s1
 2ae:	a011                	j	2b2 <gets+0x56>
 2b0:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 2b2:	99de                	add	s3,s3,s7
 2b4:	00098023          	sb	zero,0(s3)
  return buf;
}
 2b8:	855e                	mv	a0,s7
 2ba:	60e6                	ld	ra,88(sp)
 2bc:	6446                	ld	s0,80(sp)
 2be:	64a6                	ld	s1,72(sp)
 2c0:	6906                	ld	s2,64(sp)
 2c2:	79e2                	ld	s3,56(sp)
 2c4:	7a42                	ld	s4,48(sp)
 2c6:	7aa2                	ld	s5,40(sp)
 2c8:	7b02                	ld	s6,32(sp)
 2ca:	6be2                	ld	s7,24(sp)
 2cc:	6125                	addi	sp,sp,96
 2ce:	8082                	ret

00000000000002d0 <stat>:

int
stat(const char *n, struct stat *st)
{
 2d0:	1101                	addi	sp,sp,-32
 2d2:	ec06                	sd	ra,24(sp)
 2d4:	e822                	sd	s0,16(sp)
 2d6:	e426                	sd	s1,8(sp)
 2d8:	e04a                	sd	s2,0(sp)
 2da:	1000                	addi	s0,sp,32
 2dc:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 2de:	4581                	li	a1,0
 2e0:	00000097          	auipc	ra,0x0
 2e4:	170080e7          	jalr	368(ra) # 450 <open>
  if(fd < 0)
 2e8:	02054563          	bltz	a0,312 <stat+0x42>
 2ec:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 2ee:	85ca                	mv	a1,s2
 2f0:	00000097          	auipc	ra,0x0
 2f4:	178080e7          	jalr	376(ra) # 468 <fstat>
 2f8:	892a                	mv	s2,a0
  close(fd);
 2fa:	8526                	mv	a0,s1
 2fc:	00000097          	auipc	ra,0x0
 300:	13c080e7          	jalr	316(ra) # 438 <close>
  return r;
}
 304:	854a                	mv	a0,s2
 306:	60e2                	ld	ra,24(sp)
 308:	6442                	ld	s0,16(sp)
 30a:	64a2                	ld	s1,8(sp)
 30c:	6902                	ld	s2,0(sp)
 30e:	6105                	addi	sp,sp,32
 310:	8082                	ret
    return -1;
 312:	597d                	li	s2,-1
 314:	bfc5                	j	304 <stat+0x34>

0000000000000316 <atoi>:

int
atoi(const char *s)
{
 316:	1141                	addi	sp,sp,-16
 318:	e422                	sd	s0,8(sp)
 31a:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 31c:	00054683          	lbu	a3,0(a0)
 320:	fd06879b          	addiw	a5,a3,-48
 324:	0ff7f793          	zext.b	a5,a5
 328:	4625                	li	a2,9
 32a:	02f66863          	bltu	a2,a5,35a <atoi+0x44>
 32e:	872a                	mv	a4,a0
  n = 0;
 330:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 332:	0705                	addi	a4,a4,1
 334:	0025179b          	slliw	a5,a0,0x2
 338:	9fa9                	addw	a5,a5,a0
 33a:	0017979b          	slliw	a5,a5,0x1
 33e:	9fb5                	addw	a5,a5,a3
 340:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 344:	00074683          	lbu	a3,0(a4)
 348:	fd06879b          	addiw	a5,a3,-48
 34c:	0ff7f793          	zext.b	a5,a5
 350:	fef671e3          	bgeu	a2,a5,332 <atoi+0x1c>
  return n;
}
 354:	6422                	ld	s0,8(sp)
 356:	0141                	addi	sp,sp,16
 358:	8082                	ret
  n = 0;
 35a:	4501                	li	a0,0
 35c:	bfe5                	j	354 <atoi+0x3e>

000000000000035e <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 35e:	1141                	addi	sp,sp,-16
 360:	e422                	sd	s0,8(sp)
 362:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 364:	02b57463          	bgeu	a0,a1,38c <memmove+0x2e>
    while(n-- > 0)
 368:	00c05f63          	blez	a2,386 <memmove+0x28>
 36c:	1602                	slli	a2,a2,0x20
 36e:	9201                	srli	a2,a2,0x20
 370:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 374:	872a                	mv	a4,a0
      *dst++ = *src++;
 376:	0585                	addi	a1,a1,1
 378:	0705                	addi	a4,a4,1
 37a:	fff5c683          	lbu	a3,-1(a1)
 37e:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 382:	fee79ae3          	bne	a5,a4,376 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 386:	6422                	ld	s0,8(sp)
 388:	0141                	addi	sp,sp,16
 38a:	8082                	ret
    dst += n;
 38c:	00c50733          	add	a4,a0,a2
    src += n;
 390:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 392:	fec05ae3          	blez	a2,386 <memmove+0x28>
 396:	fff6079b          	addiw	a5,a2,-1
 39a:	1782                	slli	a5,a5,0x20
 39c:	9381                	srli	a5,a5,0x20
 39e:	fff7c793          	not	a5,a5
 3a2:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 3a4:	15fd                	addi	a1,a1,-1
 3a6:	177d                	addi	a4,a4,-1
 3a8:	0005c683          	lbu	a3,0(a1)
 3ac:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 3b0:	fee79ae3          	bne	a5,a4,3a4 <memmove+0x46>
 3b4:	bfc9                	j	386 <memmove+0x28>

00000000000003b6 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 3b6:	1141                	addi	sp,sp,-16
 3b8:	e422                	sd	s0,8(sp)
 3ba:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 3bc:	ca05                	beqz	a2,3ec <memcmp+0x36>
 3be:	fff6069b          	addiw	a3,a2,-1
 3c2:	1682                	slli	a3,a3,0x20
 3c4:	9281                	srli	a3,a3,0x20
 3c6:	0685                	addi	a3,a3,1
 3c8:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 3ca:	00054783          	lbu	a5,0(a0)
 3ce:	0005c703          	lbu	a4,0(a1)
 3d2:	00e79863          	bne	a5,a4,3e2 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 3d6:	0505                	addi	a0,a0,1
    p2++;
 3d8:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 3da:	fed518e3          	bne	a0,a3,3ca <memcmp+0x14>
  }
  return 0;
 3de:	4501                	li	a0,0
 3e0:	a019                	j	3e6 <memcmp+0x30>
      return *p1 - *p2;
 3e2:	40e7853b          	subw	a0,a5,a4
}
 3e6:	6422                	ld	s0,8(sp)
 3e8:	0141                	addi	sp,sp,16
 3ea:	8082                	ret
  return 0;
 3ec:	4501                	li	a0,0
 3ee:	bfe5                	j	3e6 <memcmp+0x30>

00000000000003f0 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 3f0:	1141                	addi	sp,sp,-16
 3f2:	e406                	sd	ra,8(sp)
 3f4:	e022                	sd	s0,0(sp)
 3f6:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 3f8:	00000097          	auipc	ra,0x0
 3fc:	f66080e7          	jalr	-154(ra) # 35e <memmove>
}
 400:	60a2                	ld	ra,8(sp)
 402:	6402                	ld	s0,0(sp)
 404:	0141                	addi	sp,sp,16
 406:	8082                	ret

0000000000000408 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 408:	4885                	li	a7,1
 ecall
 40a:	00000073          	ecall
 ret
 40e:	8082                	ret

0000000000000410 <exit>:
.global exit
exit:
 li a7, SYS_exit
 410:	4889                	li	a7,2
 ecall
 412:	00000073          	ecall
 ret
 416:	8082                	ret

0000000000000418 <wait>:
.global wait
wait:
 li a7, SYS_wait
 418:	488d                	li	a7,3
 ecall
 41a:	00000073          	ecall
 ret
 41e:	8082                	ret

0000000000000420 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 420:	4891                	li	a7,4
 ecall
 422:	00000073          	ecall
 ret
 426:	8082                	ret

0000000000000428 <read>:
.global read
read:
 li a7, SYS_read
 428:	4895                	li	a7,5
 ecall
 42a:	00000073          	ecall
 ret
 42e:	8082                	ret

0000000000000430 <write>:
.global write
write:
 li a7, SYS_write
 430:	48c1                	li	a7,16
 ecall
 432:	00000073          	ecall
 ret
 436:	8082                	ret

0000000000000438 <close>:
.global close
close:
 li a7, SYS_close
 438:	48d5                	li	a7,21
 ecall
 43a:	00000073          	ecall
 ret
 43e:	8082                	ret

0000000000000440 <kill>:
.global kill
kill:
 li a7, SYS_kill
 440:	4899                	li	a7,6
 ecall
 442:	00000073          	ecall
 ret
 446:	8082                	ret

0000000000000448 <exec>:
.global exec
exec:
 li a7, SYS_exec
 448:	489d                	li	a7,7
 ecall
 44a:	00000073          	ecall
 ret
 44e:	8082                	ret

0000000000000450 <open>:
.global open
open:
 li a7, SYS_open
 450:	48bd                	li	a7,15
 ecall
 452:	00000073          	ecall
 ret
 456:	8082                	ret

0000000000000458 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 458:	48c5                	li	a7,17
 ecall
 45a:	00000073          	ecall
 ret
 45e:	8082                	ret

0000000000000460 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 460:	48c9                	li	a7,18
 ecall
 462:	00000073          	ecall
 ret
 466:	8082                	ret

0000000000000468 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 468:	48a1                	li	a7,8
 ecall
 46a:	00000073          	ecall
 ret
 46e:	8082                	ret

0000000000000470 <link>:
.global link
link:
 li a7, SYS_link
 470:	48cd                	li	a7,19
 ecall
 472:	00000073          	ecall
 ret
 476:	8082                	ret

0000000000000478 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 478:	48d1                	li	a7,20
 ecall
 47a:	00000073          	ecall
 ret
 47e:	8082                	ret

0000000000000480 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 480:	48a5                	li	a7,9
 ecall
 482:	00000073          	ecall
 ret
 486:	8082                	ret

0000000000000488 <dup>:
.global dup
dup:
 li a7, SYS_dup
 488:	48a9                	li	a7,10
 ecall
 48a:	00000073          	ecall
 ret
 48e:	8082                	ret

0000000000000490 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 490:	48ad                	li	a7,11
 ecall
 492:	00000073          	ecall
 ret
 496:	8082                	ret

0000000000000498 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 498:	48b1                	li	a7,12
 ecall
 49a:	00000073          	ecall
 ret
 49e:	8082                	ret

00000000000004a0 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 4a0:	48b5                	li	a7,13
 ecall
 4a2:	00000073          	ecall
 ret
 4a6:	8082                	ret

00000000000004a8 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 4a8:	48b9                	li	a7,14
 ecall
 4aa:	00000073          	ecall
 ret
 4ae:	8082                	ret

00000000000004b0 <ctime>:
.global ctime
ctime:
 li a7, SYS_ctime
 4b0:	48d9                	li	a7,22
 ecall
 4b2:	00000073          	ecall
 ret
 4b6:	8082                	ret

00000000000004b8 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 4b8:	1101                	addi	sp,sp,-32
 4ba:	ec06                	sd	ra,24(sp)
 4bc:	e822                	sd	s0,16(sp)
 4be:	1000                	addi	s0,sp,32
 4c0:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 4c4:	4605                	li	a2,1
 4c6:	fef40593          	addi	a1,s0,-17
 4ca:	00000097          	auipc	ra,0x0
 4ce:	f66080e7          	jalr	-154(ra) # 430 <write>
}
 4d2:	60e2                	ld	ra,24(sp)
 4d4:	6442                	ld	s0,16(sp)
 4d6:	6105                	addi	sp,sp,32
 4d8:	8082                	ret

00000000000004da <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 4da:	7139                	addi	sp,sp,-64
 4dc:	fc06                	sd	ra,56(sp)
 4de:	f822                	sd	s0,48(sp)
 4e0:	f426                	sd	s1,40(sp)
 4e2:	f04a                	sd	s2,32(sp)
 4e4:	ec4e                	sd	s3,24(sp)
 4e6:	0080                	addi	s0,sp,64
 4e8:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 4ea:	c299                	beqz	a3,4f0 <printint+0x16>
 4ec:	0805c963          	bltz	a1,57e <printint+0xa4>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 4f0:	2581                	sext.w	a1,a1
  neg = 0;
 4f2:	4881                	li	a7,0
 4f4:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 4f8:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 4fa:	2601                	sext.w	a2,a2
 4fc:	00001517          	auipc	a0,0x1
 500:	a2450513          	addi	a0,a0,-1500 # f20 <digits>
 504:	883a                	mv	a6,a4
 506:	2705                	addiw	a4,a4,1
 508:	02c5f7bb          	remuw	a5,a1,a2
 50c:	1782                	slli	a5,a5,0x20
 50e:	9381                	srli	a5,a5,0x20
 510:	97aa                	add	a5,a5,a0
 512:	0007c783          	lbu	a5,0(a5)
 516:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 51a:	0005879b          	sext.w	a5,a1
 51e:	02c5d5bb          	divuw	a1,a1,a2
 522:	0685                	addi	a3,a3,1
 524:	fec7f0e3          	bgeu	a5,a2,504 <printint+0x2a>
  if(neg)
 528:	00088c63          	beqz	a7,540 <printint+0x66>
    buf[i++] = '-';
 52c:	fd070793          	addi	a5,a4,-48
 530:	00878733          	add	a4,a5,s0
 534:	02d00793          	li	a5,45
 538:	fef70823          	sb	a5,-16(a4)
 53c:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 540:	02e05863          	blez	a4,570 <printint+0x96>
 544:	fc040793          	addi	a5,s0,-64
 548:	00e78933          	add	s2,a5,a4
 54c:	fff78993          	addi	s3,a5,-1
 550:	99ba                	add	s3,s3,a4
 552:	377d                	addiw	a4,a4,-1
 554:	1702                	slli	a4,a4,0x20
 556:	9301                	srli	a4,a4,0x20
 558:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 55c:	fff94583          	lbu	a1,-1(s2)
 560:	8526                	mv	a0,s1
 562:	00000097          	auipc	ra,0x0
 566:	f56080e7          	jalr	-170(ra) # 4b8 <putc>
  while(--i >= 0)
 56a:	197d                	addi	s2,s2,-1
 56c:	ff3918e3          	bne	s2,s3,55c <printint+0x82>
}
 570:	70e2                	ld	ra,56(sp)
 572:	7442                	ld	s0,48(sp)
 574:	74a2                	ld	s1,40(sp)
 576:	7902                	ld	s2,32(sp)
 578:	69e2                	ld	s3,24(sp)
 57a:	6121                	addi	sp,sp,64
 57c:	8082                	ret
    x = -xx;
 57e:	40b005bb          	negw	a1,a1
    neg = 1;
 582:	4885                	li	a7,1
    x = -xx;
 584:	bf85                	j	4f4 <printint+0x1a>

0000000000000586 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 586:	715d                	addi	sp,sp,-80
 588:	e486                	sd	ra,72(sp)
 58a:	e0a2                	sd	s0,64(sp)
 58c:	fc26                	sd	s1,56(sp)
 58e:	f84a                	sd	s2,48(sp)
 590:	f44e                	sd	s3,40(sp)
 592:	f052                	sd	s4,32(sp)
 594:	ec56                	sd	s5,24(sp)
 596:	e85a                	sd	s6,16(sp)
 598:	e45e                	sd	s7,8(sp)
 59a:	e062                	sd	s8,0(sp)
 59c:	0880                	addi	s0,sp,80
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 59e:	0005c903          	lbu	s2,0(a1)
 5a2:	18090c63          	beqz	s2,73a <vprintf+0x1b4>
 5a6:	8aaa                	mv	s5,a0
 5a8:	8bb2                	mv	s7,a2
 5aa:	00158493          	addi	s1,a1,1
  state = 0;
 5ae:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 5b0:	02500a13          	li	s4,37
 5b4:	4b55                	li	s6,21
 5b6:	a839                	j	5d4 <vprintf+0x4e>
        putc(fd, c);
 5b8:	85ca                	mv	a1,s2
 5ba:	8556                	mv	a0,s5
 5bc:	00000097          	auipc	ra,0x0
 5c0:	efc080e7          	jalr	-260(ra) # 4b8 <putc>
 5c4:	a019                	j	5ca <vprintf+0x44>
    } else if(state == '%'){
 5c6:	01498d63          	beq	s3,s4,5e0 <vprintf+0x5a>
  for(i = 0; fmt[i]; i++){
 5ca:	0485                	addi	s1,s1,1
 5cc:	fff4c903          	lbu	s2,-1(s1)
 5d0:	16090563          	beqz	s2,73a <vprintf+0x1b4>
    if(state == 0){
 5d4:	fe0999e3          	bnez	s3,5c6 <vprintf+0x40>
      if(c == '%'){
 5d8:	ff4910e3          	bne	s2,s4,5b8 <vprintf+0x32>
        state = '%';
 5dc:	89d2                	mv	s3,s4
 5de:	b7f5                	j	5ca <vprintf+0x44>
      if(c == 'd'){
 5e0:	13490263          	beq	s2,s4,704 <vprintf+0x17e>
 5e4:	f9d9079b          	addiw	a5,s2,-99
 5e8:	0ff7f793          	zext.b	a5,a5
 5ec:	12fb6563          	bltu	s6,a5,716 <vprintf+0x190>
 5f0:	f9d9079b          	addiw	a5,s2,-99
 5f4:	0ff7f713          	zext.b	a4,a5
 5f8:	10eb6f63          	bltu	s6,a4,716 <vprintf+0x190>
 5fc:	00271793          	slli	a5,a4,0x2
 600:	00001717          	auipc	a4,0x1
 604:	8c870713          	addi	a4,a4,-1848 # ec8 <ulthread_context_switch+0xca>
 608:	97ba                	add	a5,a5,a4
 60a:	439c                	lw	a5,0(a5)
 60c:	97ba                	add	a5,a5,a4
 60e:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
 610:	008b8913          	addi	s2,s7,8
 614:	4685                	li	a3,1
 616:	4629                	li	a2,10
 618:	000ba583          	lw	a1,0(s7)
 61c:	8556                	mv	a0,s5
 61e:	00000097          	auipc	ra,0x0
 622:	ebc080e7          	jalr	-324(ra) # 4da <printint>
 626:	8bca                	mv	s7,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 628:	4981                	li	s3,0
 62a:	b745                	j	5ca <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 62c:	008b8913          	addi	s2,s7,8
 630:	4681                	li	a3,0
 632:	4629                	li	a2,10
 634:	000ba583          	lw	a1,0(s7)
 638:	8556                	mv	a0,s5
 63a:	00000097          	auipc	ra,0x0
 63e:	ea0080e7          	jalr	-352(ra) # 4da <printint>
 642:	8bca                	mv	s7,s2
      state = 0;
 644:	4981                	li	s3,0
 646:	b751                	j	5ca <vprintf+0x44>
        printint(fd, va_arg(ap, int), 16, 0);
 648:	008b8913          	addi	s2,s7,8
 64c:	4681                	li	a3,0
 64e:	4641                	li	a2,16
 650:	000ba583          	lw	a1,0(s7)
 654:	8556                	mv	a0,s5
 656:	00000097          	auipc	ra,0x0
 65a:	e84080e7          	jalr	-380(ra) # 4da <printint>
 65e:	8bca                	mv	s7,s2
      state = 0;
 660:	4981                	li	s3,0
 662:	b7a5                	j	5ca <vprintf+0x44>
        printptr(fd, va_arg(ap, uint64));
 664:	008b8c13          	addi	s8,s7,8
 668:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 66c:	03000593          	li	a1,48
 670:	8556                	mv	a0,s5
 672:	00000097          	auipc	ra,0x0
 676:	e46080e7          	jalr	-442(ra) # 4b8 <putc>
  putc(fd, 'x');
 67a:	07800593          	li	a1,120
 67e:	8556                	mv	a0,s5
 680:	00000097          	auipc	ra,0x0
 684:	e38080e7          	jalr	-456(ra) # 4b8 <putc>
 688:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 68a:	00001b97          	auipc	s7,0x1
 68e:	896b8b93          	addi	s7,s7,-1898 # f20 <digits>
 692:	03c9d793          	srli	a5,s3,0x3c
 696:	97de                	add	a5,a5,s7
 698:	0007c583          	lbu	a1,0(a5)
 69c:	8556                	mv	a0,s5
 69e:	00000097          	auipc	ra,0x0
 6a2:	e1a080e7          	jalr	-486(ra) # 4b8 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 6a6:	0992                	slli	s3,s3,0x4
 6a8:	397d                	addiw	s2,s2,-1
 6aa:	fe0914e3          	bnez	s2,692 <vprintf+0x10c>
        printptr(fd, va_arg(ap, uint64));
 6ae:	8be2                	mv	s7,s8
      state = 0;
 6b0:	4981                	li	s3,0
 6b2:	bf21                	j	5ca <vprintf+0x44>
        s = va_arg(ap, char*);
 6b4:	008b8993          	addi	s3,s7,8
 6b8:	000bb903          	ld	s2,0(s7)
        if(s == 0)
 6bc:	02090163          	beqz	s2,6de <vprintf+0x158>
        while(*s != 0){
 6c0:	00094583          	lbu	a1,0(s2)
 6c4:	c9a5                	beqz	a1,734 <vprintf+0x1ae>
          putc(fd, *s);
 6c6:	8556                	mv	a0,s5
 6c8:	00000097          	auipc	ra,0x0
 6cc:	df0080e7          	jalr	-528(ra) # 4b8 <putc>
          s++;
 6d0:	0905                	addi	s2,s2,1
        while(*s != 0){
 6d2:	00094583          	lbu	a1,0(s2)
 6d6:	f9e5                	bnez	a1,6c6 <vprintf+0x140>
        s = va_arg(ap, char*);
 6d8:	8bce                	mv	s7,s3
      state = 0;
 6da:	4981                	li	s3,0
 6dc:	b5fd                	j	5ca <vprintf+0x44>
          s = "(null)";
 6de:	00000917          	auipc	s2,0x0
 6e2:	7e290913          	addi	s2,s2,2018 # ec0 <ulthread_context_switch+0xc2>
        while(*s != 0){
 6e6:	02800593          	li	a1,40
 6ea:	bff1                	j	6c6 <vprintf+0x140>
        putc(fd, va_arg(ap, uint));
 6ec:	008b8913          	addi	s2,s7,8
 6f0:	000bc583          	lbu	a1,0(s7)
 6f4:	8556                	mv	a0,s5
 6f6:	00000097          	auipc	ra,0x0
 6fa:	dc2080e7          	jalr	-574(ra) # 4b8 <putc>
 6fe:	8bca                	mv	s7,s2
      state = 0;
 700:	4981                	li	s3,0
 702:	b5e1                	j	5ca <vprintf+0x44>
        putc(fd, c);
 704:	02500593          	li	a1,37
 708:	8556                	mv	a0,s5
 70a:	00000097          	auipc	ra,0x0
 70e:	dae080e7          	jalr	-594(ra) # 4b8 <putc>
      state = 0;
 712:	4981                	li	s3,0
 714:	bd5d                	j	5ca <vprintf+0x44>
        putc(fd, '%');
 716:	02500593          	li	a1,37
 71a:	8556                	mv	a0,s5
 71c:	00000097          	auipc	ra,0x0
 720:	d9c080e7          	jalr	-612(ra) # 4b8 <putc>
        putc(fd, c);
 724:	85ca                	mv	a1,s2
 726:	8556                	mv	a0,s5
 728:	00000097          	auipc	ra,0x0
 72c:	d90080e7          	jalr	-624(ra) # 4b8 <putc>
      state = 0;
 730:	4981                	li	s3,0
 732:	bd61                	j	5ca <vprintf+0x44>
        s = va_arg(ap, char*);
 734:	8bce                	mv	s7,s3
      state = 0;
 736:	4981                	li	s3,0
 738:	bd49                	j	5ca <vprintf+0x44>
    }
  }
}
 73a:	60a6                	ld	ra,72(sp)
 73c:	6406                	ld	s0,64(sp)
 73e:	74e2                	ld	s1,56(sp)
 740:	7942                	ld	s2,48(sp)
 742:	79a2                	ld	s3,40(sp)
 744:	7a02                	ld	s4,32(sp)
 746:	6ae2                	ld	s5,24(sp)
 748:	6b42                	ld	s6,16(sp)
 74a:	6ba2                	ld	s7,8(sp)
 74c:	6c02                	ld	s8,0(sp)
 74e:	6161                	addi	sp,sp,80
 750:	8082                	ret

0000000000000752 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 752:	715d                	addi	sp,sp,-80
 754:	ec06                	sd	ra,24(sp)
 756:	e822                	sd	s0,16(sp)
 758:	1000                	addi	s0,sp,32
 75a:	e010                	sd	a2,0(s0)
 75c:	e414                	sd	a3,8(s0)
 75e:	e818                	sd	a4,16(s0)
 760:	ec1c                	sd	a5,24(s0)
 762:	03043023          	sd	a6,32(s0)
 766:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 76a:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 76e:	8622                	mv	a2,s0
 770:	00000097          	auipc	ra,0x0
 774:	e16080e7          	jalr	-490(ra) # 586 <vprintf>
}
 778:	60e2                	ld	ra,24(sp)
 77a:	6442                	ld	s0,16(sp)
 77c:	6161                	addi	sp,sp,80
 77e:	8082                	ret

0000000000000780 <printf>:

void
printf(const char *fmt, ...)
{
 780:	711d                	addi	sp,sp,-96
 782:	ec06                	sd	ra,24(sp)
 784:	e822                	sd	s0,16(sp)
 786:	1000                	addi	s0,sp,32
 788:	e40c                	sd	a1,8(s0)
 78a:	e810                	sd	a2,16(s0)
 78c:	ec14                	sd	a3,24(s0)
 78e:	f018                	sd	a4,32(s0)
 790:	f41c                	sd	a5,40(s0)
 792:	03043823          	sd	a6,48(s0)
 796:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 79a:	00840613          	addi	a2,s0,8
 79e:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 7a2:	85aa                	mv	a1,a0
 7a4:	4505                	li	a0,1
 7a6:	00000097          	auipc	ra,0x0
 7aa:	de0080e7          	jalr	-544(ra) # 586 <vprintf>
}
 7ae:	60e2                	ld	ra,24(sp)
 7b0:	6442                	ld	s0,16(sp)
 7b2:	6125                	addi	sp,sp,96
 7b4:	8082                	ret

00000000000007b6 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 7b6:	1141                	addi	sp,sp,-16
 7b8:	e422                	sd	s0,8(sp)
 7ba:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 7bc:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7c0:	00001797          	auipc	a5,0x1
 7c4:	8407b783          	ld	a5,-1984(a5) # 1000 <freep>
 7c8:	a02d                	j	7f2 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 7ca:	4618                	lw	a4,8(a2)
 7cc:	9f2d                	addw	a4,a4,a1
 7ce:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 7d2:	6398                	ld	a4,0(a5)
 7d4:	6310                	ld	a2,0(a4)
 7d6:	a83d                	j	814 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 7d8:	ff852703          	lw	a4,-8(a0)
 7dc:	9f31                	addw	a4,a4,a2
 7de:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 7e0:	ff053683          	ld	a3,-16(a0)
 7e4:	a091                	j	828 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7e6:	6398                	ld	a4,0(a5)
 7e8:	00e7e463          	bltu	a5,a4,7f0 <free+0x3a>
 7ec:	00e6ea63          	bltu	a3,a4,800 <free+0x4a>
{
 7f0:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7f2:	fed7fae3          	bgeu	a5,a3,7e6 <free+0x30>
 7f6:	6398                	ld	a4,0(a5)
 7f8:	00e6e463          	bltu	a3,a4,800 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7fc:	fee7eae3          	bltu	a5,a4,7f0 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 800:	ff852583          	lw	a1,-8(a0)
 804:	6390                	ld	a2,0(a5)
 806:	02059813          	slli	a6,a1,0x20
 80a:	01c85713          	srli	a4,a6,0x1c
 80e:	9736                	add	a4,a4,a3
 810:	fae60de3          	beq	a2,a4,7ca <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 814:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 818:	4790                	lw	a2,8(a5)
 81a:	02061593          	slli	a1,a2,0x20
 81e:	01c5d713          	srli	a4,a1,0x1c
 822:	973e                	add	a4,a4,a5
 824:	fae68ae3          	beq	a3,a4,7d8 <free+0x22>
    p->s.ptr = bp->s.ptr;
 828:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 82a:	00000717          	auipc	a4,0x0
 82e:	7cf73b23          	sd	a5,2006(a4) # 1000 <freep>
}
 832:	6422                	ld	s0,8(sp)
 834:	0141                	addi	sp,sp,16
 836:	8082                	ret

0000000000000838 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 838:	7139                	addi	sp,sp,-64
 83a:	fc06                	sd	ra,56(sp)
 83c:	f822                	sd	s0,48(sp)
 83e:	f426                	sd	s1,40(sp)
 840:	f04a                	sd	s2,32(sp)
 842:	ec4e                	sd	s3,24(sp)
 844:	e852                	sd	s4,16(sp)
 846:	e456                	sd	s5,8(sp)
 848:	e05a                	sd	s6,0(sp)
 84a:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 84c:	02051493          	slli	s1,a0,0x20
 850:	9081                	srli	s1,s1,0x20
 852:	04bd                	addi	s1,s1,15
 854:	8091                	srli	s1,s1,0x4
 856:	0014899b          	addiw	s3,s1,1
 85a:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 85c:	00000517          	auipc	a0,0x0
 860:	7a453503          	ld	a0,1956(a0) # 1000 <freep>
 864:	c515                	beqz	a0,890 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 866:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 868:	4798                	lw	a4,8(a5)
 86a:	02977f63          	bgeu	a4,s1,8a8 <malloc+0x70>
  if(nu < 4096)
 86e:	8a4e                	mv	s4,s3
 870:	0009871b          	sext.w	a4,s3
 874:	6685                	lui	a3,0x1
 876:	00d77363          	bgeu	a4,a3,87c <malloc+0x44>
 87a:	6a05                	lui	s4,0x1
 87c:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 880:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 884:	00000917          	auipc	s2,0x0
 888:	77c90913          	addi	s2,s2,1916 # 1000 <freep>
  if(p == (char*)-1)
 88c:	5afd                	li	s5,-1
 88e:	a895                	j	902 <malloc+0xca>
    base.s.ptr = freep = prevp = &base;
 890:	00001797          	auipc	a5,0x1
 894:	99078793          	addi	a5,a5,-1648 # 1220 <base>
 898:	00000717          	auipc	a4,0x0
 89c:	76f73423          	sd	a5,1896(a4) # 1000 <freep>
 8a0:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 8a2:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 8a6:	b7e1                	j	86e <malloc+0x36>
      if(p->s.size == nunits)
 8a8:	02e48c63          	beq	s1,a4,8e0 <malloc+0xa8>
        p->s.size -= nunits;
 8ac:	4137073b          	subw	a4,a4,s3
 8b0:	c798                	sw	a4,8(a5)
        p += p->s.size;
 8b2:	02071693          	slli	a3,a4,0x20
 8b6:	01c6d713          	srli	a4,a3,0x1c
 8ba:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 8bc:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 8c0:	00000717          	auipc	a4,0x0
 8c4:	74a73023          	sd	a0,1856(a4) # 1000 <freep>
      return (void*)(p + 1);
 8c8:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 8cc:	70e2                	ld	ra,56(sp)
 8ce:	7442                	ld	s0,48(sp)
 8d0:	74a2                	ld	s1,40(sp)
 8d2:	7902                	ld	s2,32(sp)
 8d4:	69e2                	ld	s3,24(sp)
 8d6:	6a42                	ld	s4,16(sp)
 8d8:	6aa2                	ld	s5,8(sp)
 8da:	6b02                	ld	s6,0(sp)
 8dc:	6121                	addi	sp,sp,64
 8de:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 8e0:	6398                	ld	a4,0(a5)
 8e2:	e118                	sd	a4,0(a0)
 8e4:	bff1                	j	8c0 <malloc+0x88>
  hp->s.size = nu;
 8e6:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 8ea:	0541                	addi	a0,a0,16
 8ec:	00000097          	auipc	ra,0x0
 8f0:	eca080e7          	jalr	-310(ra) # 7b6 <free>
  return freep;
 8f4:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 8f8:	d971                	beqz	a0,8cc <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8fa:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 8fc:	4798                	lw	a4,8(a5)
 8fe:	fa9775e3          	bgeu	a4,s1,8a8 <malloc+0x70>
    if(p == freep)
 902:	00093703          	ld	a4,0(s2)
 906:	853e                	mv	a0,a5
 908:	fef719e3          	bne	a4,a5,8fa <malloc+0xc2>
  p = sbrk(nu * sizeof(Header));
 90c:	8552                	mv	a0,s4
 90e:	00000097          	auipc	ra,0x0
 912:	b8a080e7          	jalr	-1142(ra) # 498 <sbrk>
  if(p == (char*)-1)
 916:	fd5518e3          	bne	a0,s5,8e6 <malloc+0xae>
        return 0;
 91a:	4501                	li	a0,0
 91c:	bf45                	j	8cc <malloc+0x94>

000000000000091e <get_current_tid>:
struct ulthread *scheduler_thread;
enum ulthread_scheduling_algorithm algorithm;

/* Get thread ID */
int get_current_tid(void)
{
 91e:	1141                	addi	sp,sp,-16
 920:	e422                	sd	s0,8(sp)
 922:	0800                	addi	s0,sp,16
  return current_thread->tid;
}
 924:	00000797          	auipc	a5,0x0
 928:	6f47b783          	ld	a5,1780(a5) # 1018 <current_thread>
 92c:	43c8                	lw	a0,4(a5)
 92e:	6422                	ld	s0,8(sp)
 930:	0141                	addi	sp,sp,16
 932:	8082                	ret

0000000000000934 <roundRobin>:

void roundRobin(void)
{
 934:	715d                	addi	sp,sp,-80
 936:	e486                	sd	ra,72(sp)
 938:	e0a2                	sd	s0,64(sp)
 93a:	fc26                	sd	s1,56(sp)
 93c:	f84a                	sd	s2,48(sp)
 93e:	f44e                	sd	s3,40(sp)
 940:	f052                	sd	s4,32(sp)
 942:	ec56                	sd	s5,24(sp)
 944:	e85a                	sd	s6,16(sp)
 946:	e45e                	sd	s7,8(sp)
 948:	e062                	sd	s8,0(sp)
 94a:	0880                	addi	s0,sp,80
        struct ulthread *temp = current_thread;
        current_thread = t;
        printf("[*] ultschedule (next tid: %d)\n", get_current_tid());
        ulthread_context_switch(&temp->context, &t->context);
      }
      if (t->state == YIELD)
 94c:	4a09                	li	s4,2
      if (t->state == RUNNABLE && t != scheduler_thread)
 94e:	00000b97          	auipc	s7,0x0
 952:	6c2b8b93          	addi	s7,s7,1730 # 1010 <scheduler_thread>
        struct ulthread *temp = current_thread;
 956:	00000a97          	auipc	s5,0x0
 95a:	6c2a8a93          	addi	s5,s5,1730 # 1018 <current_thread>
        printf("[*] ultschedule (next tid: %d)\n", get_current_tid());
 95e:	00000c17          	auipc	s8,0x0
 962:	5dac0c13          	addi	s8,s8,1498 # f38 <digits+0x18>
    for (t = ulthreads; t < &ulthreads[MAXULTHREADS]; t++)
 966:	00004997          	auipc	s3,0x4
 96a:	dea98993          	addi	s3,s3,-534 # 4750 <ulthreads+0x3520>
 96e:	a0b9                	j	9bc <roundRobin+0x88>
      if (t->state == RUNNABLE && t != scheduler_thread)
 970:	000bb783          	ld	a5,0(s7)
 974:	02978863          	beq	a5,s1,9a4 <roundRobin+0x70>
        struct ulthread *temp = current_thread;
 978:	000abb03          	ld	s6,0(s5)
        current_thread = t;
 97c:	009ab023          	sd	s1,0(s5)
        printf("[*] ultschedule (next tid: %d)\n", get_current_tid());
 980:	40cc                	lw	a1,4(s1)
 982:	8562                	mv	a0,s8
 984:	00000097          	auipc	ra,0x0
 988:	dfc080e7          	jalr	-516(ra) # 780 <printf>
        ulthread_context_switch(&temp->context, &t->context);
 98c:	01848593          	addi	a1,s1,24
 990:	018b0513          	addi	a0,s6,24
 994:	00000097          	auipc	ra,0x0
 998:	46a080e7          	jalr	1130(ra) # dfe <ulthread_context_switch>
        threadAvailable = true;
 99c:	874a                	mv	a4,s2
 99e:	a811                	j	9b2 <roundRobin+0x7e>
      {
        t->state = RUNNABLE;
 9a0:	0124a023          	sw	s2,0(s1)
    for (t = ulthreads; t < &ulthreads[MAXULTHREADS]; t++)
 9a4:	08848493          	addi	s1,s1,136
 9a8:	01348963          	beq	s1,s3,9ba <roundRobin+0x86>
      if (t->state == RUNNABLE && t != scheduler_thread)
 9ac:	409c                	lw	a5,0(s1)
 9ae:	fd2781e3          	beq	a5,s2,970 <roundRobin+0x3c>
      if (t->state == YIELD)
 9b2:	409c                	lw	a5,0(s1)
 9b4:	ff4798e3          	bne	a5,s4,9a4 <roundRobin+0x70>
 9b8:	b7e5                	j	9a0 <roundRobin+0x6c>
      }
    }
    if (!threadAvailable)
 9ba:	cb01                	beqz	a4,9ca <roundRobin+0x96>
    bool threadAvailable = false;
 9bc:	4701                	li	a4,0
    for (t = ulthreads; t < &ulthreads[MAXULTHREADS]; t++)
 9be:	00001497          	auipc	s1,0x1
 9c2:	87248493          	addi	s1,s1,-1934 # 1230 <ulthreads>
      if (t->state == RUNNABLE && t != scheduler_thread)
 9c6:	4905                	li	s2,1
 9c8:	b7d5                	j	9ac <roundRobin+0x78>
    {
      break;
    }
  }
}
 9ca:	60a6                	ld	ra,72(sp)
 9cc:	6406                	ld	s0,64(sp)
 9ce:	74e2                	ld	s1,56(sp)
 9d0:	7942                	ld	s2,48(sp)
 9d2:	79a2                	ld	s3,40(sp)
 9d4:	7a02                	ld	s4,32(sp)
 9d6:	6ae2                	ld	s5,24(sp)
 9d8:	6b42                	ld	s6,16(sp)
 9da:	6ba2                	ld	s7,8(sp)
 9dc:	6c02                	ld	s8,0(sp)
 9de:	6161                	addi	sp,sp,80
 9e0:	8082                	ret

00000000000009e2 <firstComeFirstServe>:

void firstComeFirstServe(void)
{
 9e2:	715d                	addi	sp,sp,-80
 9e4:	e486                	sd	ra,72(sp)
 9e6:	e0a2                	sd	s0,64(sp)
 9e8:	fc26                	sd	s1,56(sp)
 9ea:	f84a                	sd	s2,48(sp)
 9ec:	f44e                	sd	s3,40(sp)
 9ee:	f052                	sd	s4,32(sp)
 9f0:	ec56                	sd	s5,24(sp)
 9f2:	e85a                	sd	s6,16(sp)
 9f4:	e45e                	sd	s7,8(sp)
 9f6:	e062                	sd	s8,0(sp)
 9f8:	0880                	addi	s0,sp,80
    uint64 oldest = __INT64_MAX__;
    int threadIndex = -1;
    int alternativeIndex = -1;
    for (t = ulthreads+1; t < &ulthreads[MAXULTHREADS]; t++)
    {
      if (t->state == RUNNABLE && t != scheduler_thread && t->lastTime < oldest)
 9fa:	00000b97          	auipc	s7,0x0
 9fe:	616b8b93          	addi	s7,s7,1558 # 1010 <scheduler_thread>
    int alternativeIndex = -1;
 a02:	5afd                	li	s5,-1
    uint64 oldest = __INT64_MAX__;
 a04:	001adb13          	srli	s6,s5,0x1
      if (t->state == RUNNABLE && t != scheduler_thread && t->lastTime < oldest)
 a08:	4485                	li	s1,1
        oldest = t->lastTime;
        threadIndex = t->tid;
        threadAvailable = true;
      }

      if (t->state == YIELD){
 a0a:	4989                	li	s3,2
    for (t = ulthreads+1; t < &ulthreads[MAXULTHREADS]; t++)
 a0c:	00004917          	auipc	s2,0x4
 a10:	d4490913          	addi	s2,s2,-700 # 4750 <ulthreads+0x3520>
        break;
      }
      
    }
    label : 
      struct ulthread *temp = current_thread;
 a14:	00000a17          	auipc	s4,0x0
 a18:	604a0a13          	addi	s4,s4,1540 # 1018 <current_thread>
 a1c:	a88d                	j	a8e <firstComeFirstServe+0xac>
      if (t->state == RUNNABLE && t != scheduler_thread && t->lastTime < oldest)
 a1e:	00f58963          	beq	a1,a5,a30 <firstComeFirstServe+0x4e>
 a22:	6b98                	ld	a4,16(a5)
 a24:	00c77663          	bgeu	a4,a2,a30 <firstComeFirstServe+0x4e>
        threadIndex = t->tid;
 a28:	0047a803          	lw	a6,4(a5)
        oldest = t->lastTime;
 a2c:	863a                	mv	a2,a4
        threadAvailable = true;
 a2e:	8526                	mv	a0,s1
    for (t = ulthreads+1; t < &ulthreads[MAXULTHREADS]; t++)
 a30:	08878793          	addi	a5,a5,136
 a34:	01278a63          	beq	a5,s2,a48 <firstComeFirstServe+0x66>
      if (t->state == RUNNABLE && t != scheduler_thread && t->lastTime < oldest)
 a38:	4398                	lw	a4,0(a5)
 a3a:	fe9702e3          	beq	a4,s1,a1e <firstComeFirstServe+0x3c>
      if (t->state == YIELD){
 a3e:	ff3719e3          	bne	a4,s3,a30 <firstComeFirstServe+0x4e>
        t->state = RUNNABLE;
 a42:	c384                	sw	s1,0(a5)
        alternativeIndex = t->tid;
 a44:	43d4                	lw	a3,4(a5)
 a46:	b7ed                	j	a30 <firstComeFirstServe+0x4e>
    if (!threadAvailable)
 a48:	ed31                	bnez	a0,aa4 <firstComeFirstServe+0xc2>
      if(alternativeIndex > 0){
 a4a:	04d05f63          	blez	a3,aa8 <firstComeFirstServe+0xc6>
      struct ulthread *temp = current_thread;
 a4e:	000a3c03          	ld	s8,0(s4)
      current_thread = &ulthreads[threadIndex];
 a52:	00469793          	slli	a5,a3,0x4
 a56:	00d78733          	add	a4,a5,a3
 a5a:	070e                	slli	a4,a4,0x3
 a5c:	00000617          	auipc	a2,0x0
 a60:	7d460613          	addi	a2,a2,2004 # 1230 <ulthreads>
 a64:	9732                	add	a4,a4,a2
 a66:	00ea3023          	sd	a4,0(s4)
      printf("[*] ultschedule (next tid: %d), time = %d\n", get_current_tid());
 a6a:	434c                	lw	a1,4(a4)
 a6c:	00000517          	auipc	a0,0x0
 a70:	4ec50513          	addi	a0,a0,1260 # f58 <digits+0x38>
 a74:	00000097          	auipc	ra,0x0
 a78:	d0c080e7          	jalr	-756(ra) # 780 <printf>
      ulthread_context_switch(&temp->context, &current_thread->context);
 a7c:	000a3583          	ld	a1,0(s4)
 a80:	05e1                	addi	a1,a1,24
 a82:	018c0513          	addi	a0,s8,24
 a86:	00000097          	auipc	ra,0x0
 a8a:	378080e7          	jalr	888(ra) # dfe <ulthread_context_switch>
      if (t->state == RUNNABLE && t != scheduler_thread && t->lastTime < oldest)
 a8e:	000bb583          	ld	a1,0(s7)
    int alternativeIndex = -1;
 a92:	86d6                	mv	a3,s5
    int threadIndex = -1;
 a94:	8856                	mv	a6,s5
    uint64 oldest = __INT64_MAX__;
 a96:	865a                	mv	a2,s6
    bool threadAvailable = false;
 a98:	4501                	li	a0,0
    for (t = ulthreads+1; t < &ulthreads[MAXULTHREADS]; t++)
 a9a:	00001797          	auipc	a5,0x1
 a9e:	81e78793          	addi	a5,a5,-2018 # 12b8 <ulthreads+0x88>
 aa2:	bf59                	j	a38 <firstComeFirstServe+0x56>
    label : 
 aa4:	86c2                	mv	a3,a6
 aa6:	b765                	j	a4e <firstComeFirstServe+0x6c>
  }
}
 aa8:	60a6                	ld	ra,72(sp)
 aaa:	6406                	ld	s0,64(sp)
 aac:	74e2                	ld	s1,56(sp)
 aae:	7942                	ld	s2,48(sp)
 ab0:	79a2                	ld	s3,40(sp)
 ab2:	7a02                	ld	s4,32(sp)
 ab4:	6ae2                	ld	s5,24(sp)
 ab6:	6b42                	ld	s6,16(sp)
 ab8:	6ba2                	ld	s7,8(sp)
 aba:	6c02                	ld	s8,0(sp)
 abc:	6161                	addi	sp,sp,80
 abe:	8082                	ret

0000000000000ac0 <priorityScheduling>:


void priorityScheduling(void)
{
 ac0:	715d                	addi	sp,sp,-80
 ac2:	e486                	sd	ra,72(sp)
 ac4:	e0a2                	sd	s0,64(sp)
 ac6:	fc26                	sd	s1,56(sp)
 ac8:	f84a                	sd	s2,48(sp)
 aca:	f44e                	sd	s3,40(sp)
 acc:	f052                	sd	s4,32(sp)
 ace:	ec56                	sd	s5,24(sp)
 ad0:	e85a                	sd	s6,16(sp)
 ad2:	e45e                	sd	s7,8(sp)
 ad4:	0880                	addi	s0,sp,80
    int maxPriority = -1;
    int threadIndex = -1;
    int alternativeIndex = -1;
    for (t = ulthreads+1; t < &ulthreads[MAXULTHREADS]; t++)
    {
      if (t->state == RUNNABLE && t != scheduler_thread && t->priority > maxPriority)
 ad6:	00000b17          	auipc	s6,0x0
 ada:	53ab0b13          	addi	s6,s6,1338 # 1010 <scheduler_thread>
    int alternativeIndex = -1;
 ade:	5a7d                	li	s4,-1
      if (t->state == RUNNABLE && t != scheduler_thread && t->priority > maxPriority)
 ae0:	4485                	li	s1,1
        // flag = true;

        // break; // switch to highest-priority thread and exit loop
      }

      if (t->state == YIELD){
 ae2:	4989                	li	s3,2
    for (t = ulthreads+1; t < &ulthreads[MAXULTHREADS]; t++)
 ae4:	00004917          	auipc	s2,0x4
 ae8:	c6c90913          	addi	s2,s2,-916 # 4750 <ulthreads+0x3520>
        break;
      }
      
    }
    label : 
      struct ulthread *temp = current_thread;
 aec:	00000a97          	auipc	s5,0x0
 af0:	52ca8a93          	addi	s5,s5,1324 # 1018 <current_thread>
 af4:	a88d                	j	b66 <priorityScheduling+0xa6>
      if (t->state == RUNNABLE && t != scheduler_thread && t->priority > maxPriority)
 af6:	00f58963          	beq	a1,a5,b08 <priorityScheduling+0x48>
 afa:	47d8                	lw	a4,12(a5)
 afc:	00e65663          	bge	a2,a4,b08 <priorityScheduling+0x48>
        threadIndex = t->tid;
 b00:	0047a803          	lw	a6,4(a5)
        maxPriority = t->priority;
 b04:	863a                	mv	a2,a4
        threadAvailable = true;
 b06:	8526                	mv	a0,s1
    for (t = ulthreads+1; t < &ulthreads[MAXULTHREADS]; t++)
 b08:	08878793          	addi	a5,a5,136
 b0c:	01278a63          	beq	a5,s2,b20 <priorityScheduling+0x60>
      if (t->state == RUNNABLE && t != scheduler_thread && t->priority > maxPriority)
 b10:	4398                	lw	a4,0(a5)
 b12:	fe9702e3          	beq	a4,s1,af6 <priorityScheduling+0x36>
      if (t->state == YIELD){
 b16:	ff3719e3          	bne	a4,s3,b08 <priorityScheduling+0x48>
        t->state = RUNNABLE;
 b1a:	c384                	sw	s1,0(a5)
        alternativeIndex = t->tid;
 b1c:	43d4                	lw	a3,4(a5)
 b1e:	b7ed                	j	b08 <priorityScheduling+0x48>
    if (!threadAvailable)
 b20:	ed31                	bnez	a0,b7c <priorityScheduling+0xbc>
      if(alternativeIndex > 0){
 b22:	04d05f63          	blez	a3,b80 <priorityScheduling+0xc0>
      struct ulthread *temp = current_thread;
 b26:	000abb83          	ld	s7,0(s5)
      current_thread = &ulthreads[threadIndex];
 b2a:	00469793          	slli	a5,a3,0x4
 b2e:	00d78733          	add	a4,a5,a3
 b32:	070e                	slli	a4,a4,0x3
 b34:	00000617          	auipc	a2,0x0
 b38:	6fc60613          	addi	a2,a2,1788 # 1230 <ulthreads>
 b3c:	9732                	add	a4,a4,a2
 b3e:	00eab023          	sd	a4,0(s5)
      printf("[*] ultschedule (next tid: %d)\n", get_current_tid());
 b42:	434c                	lw	a1,4(a4)
 b44:	00000517          	auipc	a0,0x0
 b48:	3f450513          	addi	a0,a0,1012 # f38 <digits+0x18>
 b4c:	00000097          	auipc	ra,0x0
 b50:	c34080e7          	jalr	-972(ra) # 780 <printf>
      ulthread_context_switch(&temp->context, &current_thread->context);
 b54:	000ab583          	ld	a1,0(s5)
 b58:	05e1                	addi	a1,a1,24
 b5a:	018b8513          	addi	a0,s7,24
 b5e:	00000097          	auipc	ra,0x0
 b62:	2a0080e7          	jalr	672(ra) # dfe <ulthread_context_switch>
      if (t->state == RUNNABLE && t != scheduler_thread && t->priority > maxPriority)
 b66:	000b3583          	ld	a1,0(s6)
    int alternativeIndex = -1;
 b6a:	86d2                	mv	a3,s4
    int threadIndex = -1;
 b6c:	8852                	mv	a6,s4
    int maxPriority = -1;
 b6e:	8652                	mv	a2,s4
    bool threadAvailable = false;
 b70:	4501                	li	a0,0
    for (t = ulthreads+1; t < &ulthreads[MAXULTHREADS]; t++)
 b72:	00000797          	auipc	a5,0x0
 b76:	74678793          	addi	a5,a5,1862 # 12b8 <ulthreads+0x88>
 b7a:	bf59                	j	b10 <priorityScheduling+0x50>
    label : 
 b7c:	86c2                	mv	a3,a6
 b7e:	b765                	j	b26 <priorityScheduling+0x66>
  }
}
 b80:	60a6                	ld	ra,72(sp)
 b82:	6406                	ld	s0,64(sp)
 b84:	74e2                	ld	s1,56(sp)
 b86:	7942                	ld	s2,48(sp)
 b88:	79a2                	ld	s3,40(sp)
 b8a:	7a02                	ld	s4,32(sp)
 b8c:	6ae2                	ld	s5,24(sp)
 b8e:	6b42                	ld	s6,16(sp)
 b90:	6ba2                	ld	s7,8(sp)
 b92:	6161                	addi	sp,sp,80
 b94:	8082                	ret

0000000000000b96 <ulthread_init>:

/* Thread initialization */
void ulthread_init(int schedalgo)
{
 b96:	1141                	addi	sp,sp,-16
 b98:	e422                	sd	s0,8(sp)
 b9a:	0800                	addi	s0,sp,16
  struct ulthread *t;
  int i;
  for (i = 0, t = ulthreads; t < &ulthreads[MAXULTHREADS]; t++, i++)
 b9c:	4701                	li	a4,0
 b9e:	00000797          	auipc	a5,0x0
 ba2:	69278793          	addi	a5,a5,1682 # 1230 <ulthreads>
 ba6:	00004697          	auipc	a3,0x4
 baa:	baa68693          	addi	a3,a3,-1110 # 4750 <ulthreads+0x3520>
  {
    t->state = FREE;
 bae:	0007a023          	sw	zero,0(a5)
    t->tid = i;
 bb2:	c3d8                	sw	a4,4(a5)
  for (i = 0, t = ulthreads; t < &ulthreads[MAXULTHREADS]; t++, i++)
 bb4:	08878793          	addi	a5,a5,136
 bb8:	2705                	addiw	a4,a4,1
 bba:	fed79ae3          	bne	a5,a3,bae <ulthread_init+0x18>
  }
  current_thread = &ulthreads[0];
 bbe:	00000797          	auipc	a5,0x0
 bc2:	67278793          	addi	a5,a5,1650 # 1230 <ulthreads>
 bc6:	00000717          	auipc	a4,0x0
 bca:	44f73923          	sd	a5,1106(a4) # 1018 <current_thread>
  scheduler_thread = &ulthreads[0];
 bce:	00000717          	auipc	a4,0x0
 bd2:	44f73123          	sd	a5,1090(a4) # 1010 <scheduler_thread>
  scheduler_thread->state = RUNNABLE;
 bd6:	4705                	li	a4,1
 bd8:	c398                	sw	a4,0(a5)
  t->state = FREE;
 bda:	00004797          	auipc	a5,0x4
 bde:	b607ab23          	sw	zero,-1162(a5) # 4750 <ulthreads+0x3520>
  algorithm = schedalgo;
 be2:	00000797          	auipc	a5,0x0
 be6:	42a7a323          	sw	a0,1062(a5) # 1008 <algorithm>
}
 bea:	6422                	ld	s0,8(sp)
 bec:	0141                	addi	sp,sp,16
 bee:	8082                	ret

0000000000000bf0 <ulthread_create>:

/* Thread creation */
bool ulthread_create(uint64 start, uint64 stack, uint64 args[], int priority)
{
 bf0:	7179                	addi	sp,sp,-48
 bf2:	f406                	sd	ra,40(sp)
 bf4:	f022                	sd	s0,32(sp)
 bf6:	ec26                	sd	s1,24(sp)
 bf8:	e84a                	sd	s2,16(sp)
 bfa:	e44e                	sd	s3,8(sp)
 bfc:	e052                	sd	s4,0(sp)
 bfe:	1800                	addi	s0,sp,48
 c00:	89aa                	mv	s3,a0
 c02:	8a2e                	mv	s4,a1
 c04:	8932                	mv	s2,a2
  /* Please add thread-id instead of '0' here. */
  struct ulthread *t;
  bool flag = false;
  for (t = ulthreads; t < &ulthreads[MAXULTHREADS]; t++)
 c06:	00000497          	auipc	s1,0x0
 c0a:	62a48493          	addi	s1,s1,1578 # 1230 <ulthreads>
 c0e:	00004717          	auipc	a4,0x4
 c12:	b4270713          	addi	a4,a4,-1214 # 4750 <ulthreads+0x3520>
  {
    if (t->state == FREE)
 c16:	409c                	lw	a5,0(s1)
 c18:	cf89                	beqz	a5,c32 <ulthread_create+0x42>
  for (t = ulthreads; t < &ulthreads[MAXULTHREADS]; t++)
 c1a:	08848493          	addi	s1,s1,136
 c1e:	fee49ce3          	bne	s1,a4,c16 <ulthread_create+0x26>
      break;
    }
  }
  if (!flag)
  {
    return false;
 c22:	4501                	li	a0,0
 c24:	a871                	j	cc0 <ulthread_create+0xd0>
  t->sp = (int)(stack + USTACKSIZE); // set sp to the top of the stack
  t->state = RUNNABLE;
  t->priority = priority;

  if(algorithm==FCFS){
    t->lastTime = ctime();
 c26:	00000097          	auipc	ra,0x0
 c2a:	88a080e7          	jalr	-1910(ra) # 4b0 <ctime>
 c2e:	e888                	sd	a0,16(s1)
 c30:	a839                	j	c4e <ulthread_create+0x5e>
  t->sp = (int)(stack + USTACKSIZE); // set sp to the top of the stack
 c32:	6785                	lui	a5,0x1
 c34:	014787bb          	addw	a5,a5,s4
 c38:	c49c                	sw	a5,8(s1)
  t->state = RUNNABLE;
 c3a:	4785                	li	a5,1
 c3c:	c09c                	sw	a5,0(s1)
  t->priority = priority;
 c3e:	c4d4                	sw	a3,12(s1)
  if(algorithm==FCFS){
 c40:	00000717          	auipc	a4,0x0
 c44:	3c872703          	lw	a4,968(a4) # 1008 <algorithm>
 c48:	4789                	li	a5,2
 c4a:	fcf70ee3          	beq	a4,a5,c26 <ulthread_create+0x36>
  }

  for (int argc = 0; argc < 6; argc++)
 c4e:	874a                	mv	a4,s2
 c50:	03090693          	addi	a3,s2,48
  {
    t->sp -= 16;
 c54:	449c                	lw	a5,8(s1)
 c56:	37c1                	addiw	a5,a5,-16 # ff0 <digits+0xd0>
 c58:	0007881b          	sext.w	a6,a5
 c5c:	c49c                	sw	a5,8(s1)
    *(uint64 *)(t->sp) = (uint64)args[argc];
 c5e:	631c                	ld	a5,0(a4)
 c60:	00f83023          	sd	a5,0(a6)
  for (int argc = 0; argc < 6; argc++)
 c64:	0721                	addi	a4,a4,8
 c66:	fed717e3          	bne	a4,a3,c54 <ulthread_create+0x64>
  }

  memset(&t->context, 0, sizeof(t->context));
 c6a:	07000613          	li	a2,112
 c6e:	4581                	li	a1,0
 c70:	01848513          	addi	a0,s1,24
 c74:	fffff097          	auipc	ra,0xfffff
 c78:	5a2080e7          	jalr	1442(ra) # 216 <memset>
  t->context.ra = start;
 c7c:	0134bc23          	sd	s3,24(s1)
  t->context.sp = t->sp;
 c80:	449c                	lw	a5,8(s1)
 c82:	f09c                	sd	a5,32(s1)
  t->context.s0 = args[0];
 c84:	00093783          	ld	a5,0(s2)
 c88:	f49c                	sd	a5,40(s1)
  t->context.s1 = args[1];
 c8a:	00893783          	ld	a5,8(s2)
 c8e:	f89c                	sd	a5,48(s1)
  t->context.s2 = args[2];
 c90:	01093783          	ld	a5,16(s2)
 c94:	fc9c                	sd	a5,56(s1)
  t->context.s3 = args[3];
 c96:	01893783          	ld	a5,24(s2)
 c9a:	e0bc                	sd	a5,64(s1)
  t->context.s4 = args[4];
 c9c:	02093783          	ld	a5,32(s2)
 ca0:	e4bc                	sd	a5,72(s1)
  t->context.s5 = args[5];
 ca2:	02893783          	ld	a5,40(s2)
 ca6:	e8bc                	sd	a5,80(s1)

  printf("[*] ultcreate(tid: %d, ra: %p, sp: %p)\n", t->tid, start, stack);
 ca8:	86d2                	mv	a3,s4
 caa:	864e                	mv	a2,s3
 cac:	40cc                	lw	a1,4(s1)
 cae:	00000517          	auipc	a0,0x0
 cb2:	2da50513          	addi	a0,a0,730 # f88 <digits+0x68>
 cb6:	00000097          	auipc	ra,0x0
 cba:	aca080e7          	jalr	-1334(ra) # 780 <printf>
  return true;
 cbe:	4505                	li	a0,1
}
 cc0:	70a2                	ld	ra,40(sp)
 cc2:	7402                	ld	s0,32(sp)
 cc4:	64e2                	ld	s1,24(sp)
 cc6:	6942                	ld	s2,16(sp)
 cc8:	69a2                	ld	s3,8(sp)
 cca:	6a02                	ld	s4,0(sp)
 ccc:	6145                	addi	sp,sp,48
 cce:	8082                	ret

0000000000000cd0 <ulthread_schedule>:

/* Thread scheduler */
void ulthread_schedule(void)
{
 cd0:	1141                	addi	sp,sp,-16
 cd2:	e406                	sd	ra,8(sp)
 cd4:	e022                	sd	s0,0(sp)
 cd6:	0800                	addi	s0,sp,16
  switch (algorithm)
 cd8:	00000797          	auipc	a5,0x0
 cdc:	3307a783          	lw	a5,816(a5) # 1008 <algorithm>
 ce0:	4705                	li	a4,1
 ce2:	02e78463          	beq	a5,a4,d0a <ulthread_schedule+0x3a>
 ce6:	4709                	li	a4,2
 ce8:	00e78c63          	beq	a5,a4,d00 <ulthread_schedule+0x30>
 cec:	c789                	beqz	a5,cf6 <ulthread_schedule+0x26>

  // Push argument strings, prepare rest of stack in ustack.

  // Switch between thread contexts
  // ulthread_context_switch(NULL, NULL);
}
 cee:	60a2                	ld	ra,8(sp)
 cf0:	6402                	ld	s0,0(sp)
 cf2:	0141                	addi	sp,sp,16
 cf4:	8082                	ret
    roundRobin();
 cf6:	00000097          	auipc	ra,0x0
 cfa:	c3e080e7          	jalr	-962(ra) # 934 <roundRobin>
    break;
 cfe:	bfc5                	j	cee <ulthread_schedule+0x1e>
    firstComeFirstServe();
 d00:	00000097          	auipc	ra,0x0
 d04:	ce2080e7          	jalr	-798(ra) # 9e2 <firstComeFirstServe>
    break;
 d08:	b7dd                	j	cee <ulthread_schedule+0x1e>
    priorityScheduling();
 d0a:	00000097          	auipc	ra,0x0
 d0e:	db6080e7          	jalr	-586(ra) # ac0 <priorityScheduling>
}
 d12:	bff1                	j	cee <ulthread_schedule+0x1e>

0000000000000d14 <ulthread_yield>:

/* Yield CPU time to some other thread. */
void ulthread_yield(void)
{
 d14:	1101                	addi	sp,sp,-32
 d16:	ec06                	sd	ra,24(sp)
 d18:	e822                	sd	s0,16(sp)
 d1a:	e426                	sd	s1,8(sp)
 d1c:	e04a                	sd	s2,0(sp)
 d1e:	1000                	addi	s0,sp,32
  current_thread->state = YIELD;
 d20:	00000797          	auipc	a5,0x0
 d24:	2f878793          	addi	a5,a5,760 # 1018 <current_thread>
 d28:	6398                	ld	a4,0(a5)
 d2a:	4909                	li	s2,2
 d2c:	01272023          	sw	s2,0(a4)
  struct ulthread *temp = current_thread;
 d30:	6384                	ld	s1,0(a5)
  printf("[*] ultyield(tid: %d)\n", current_thread->tid);
 d32:	40cc                	lw	a1,4(s1)
 d34:	00000517          	auipc	a0,0x0
 d38:	27c50513          	addi	a0,a0,636 # fb0 <digits+0x90>
 d3c:	00000097          	auipc	ra,0x0
 d40:	a44080e7          	jalr	-1468(ra) # 780 <printf>
  if(algorithm==FCFS){
 d44:	00000797          	auipc	a5,0x0
 d48:	2c47a783          	lw	a5,708(a5) # 1008 <algorithm>
 d4c:	03278763          	beq	a5,s2,d7a <ulthread_yield+0x66>
    current_thread->lastTime = ctime();
  }
  current_thread = scheduler_thread;
 d50:	00000597          	auipc	a1,0x0
 d54:	2c05b583          	ld	a1,704(a1) # 1010 <scheduler_thread>
 d58:	00000797          	auipc	a5,0x0
 d5c:	2cb7b023          	sd	a1,704(a5) # 1018 <current_thread>
  
  ulthread_context_switch(&temp->context, &scheduler_thread->context);
 d60:	05e1                	addi	a1,a1,24
 d62:	01848513          	addi	a0,s1,24
 d66:	00000097          	auipc	ra,0x0
 d6a:	098080e7          	jalr	152(ra) # dfe <ulthread_context_switch>
  // ulthread_schedule();
}
 d6e:	60e2                	ld	ra,24(sp)
 d70:	6442                	ld	s0,16(sp)
 d72:	64a2                	ld	s1,8(sp)
 d74:	6902                	ld	s2,0(sp)
 d76:	6105                	addi	sp,sp,32
 d78:	8082                	ret
    current_thread->lastTime = ctime();
 d7a:	fffff097          	auipc	ra,0xfffff
 d7e:	736080e7          	jalr	1846(ra) # 4b0 <ctime>
 d82:	00000797          	auipc	a5,0x0
 d86:	2967b783          	ld	a5,662(a5) # 1018 <current_thread>
 d8a:	eb88                	sd	a0,16(a5)
 d8c:	b7d1                	j	d50 <ulthread_yield+0x3c>

0000000000000d8e <ulthread_destroy>:

/* Destroy thread */
void ulthread_destroy(void)
{
 d8e:	1101                	addi	sp,sp,-32
 d90:	ec06                	sd	ra,24(sp)
 d92:	e822                	sd	s0,16(sp)
 d94:	e426                	sd	s1,8(sp)
 d96:	e04a                	sd	s2,0(sp)
 d98:	1000                	addi	s0,sp,32
  memset(&current_thread->context, 0, sizeof(current_thread->context));
 d9a:	00000497          	auipc	s1,0x0
 d9e:	27e48493          	addi	s1,s1,638 # 1018 <current_thread>
 da2:	6088                	ld	a0,0(s1)
 da4:	07000613          	li	a2,112
 da8:	4581                	li	a1,0
 daa:	0561                	addi	a0,a0,24
 dac:	fffff097          	auipc	ra,0xfffff
 db0:	46a080e7          	jalr	1130(ra) # 216 <memset>
  current_thread->sp = 0;
 db4:	609c                	ld	a5,0(s1)
 db6:	0007a423          	sw	zero,8(a5)
  current_thread->priority = -1;
 dba:	577d                	li	a4,-1
 dbc:	c7d8                	sw	a4,12(a5)
  current_thread->state = FREE;
 dbe:	0007a023          	sw	zero,0(a5)

  struct ulthread *temp = current_thread;
 dc2:	0004b903          	ld	s2,0(s1)

  printf("[*] ultdestroy(tid: %d)\n", get_current_tid());
 dc6:	00492583          	lw	a1,4(s2)
 dca:	00000517          	auipc	a0,0x0
 dce:	1fe50513          	addi	a0,a0,510 # fc8 <digits+0xa8>
 dd2:	00000097          	auipc	ra,0x0
 dd6:	9ae080e7          	jalr	-1618(ra) # 780 <printf>
  current_thread = scheduler_thread;
 dda:	00000597          	auipc	a1,0x0
 dde:	2365b583          	ld	a1,566(a1) # 1010 <scheduler_thread>
 de2:	e08c                	sd	a1,0(s1)
  ulthread_context_switch(&temp->context, &scheduler_thread->context);
 de4:	05e1                	addi	a1,a1,24
 de6:	01890513          	addi	a0,s2,24
 dea:	00000097          	auipc	ra,0x0
 dee:	014080e7          	jalr	20(ra) # dfe <ulthread_context_switch>
}
 df2:	60e2                	ld	ra,24(sp)
 df4:	6442                	ld	s0,16(sp)
 df6:	64a2                	ld	s1,8(sp)
 df8:	6902                	ld	s2,0(sp)
 dfa:	6105                	addi	sp,sp,32
 dfc:	8082                	ret

0000000000000dfe <ulthread_context_switch>:
 dfe:	00153023          	sd	ra,0(a0)
 e02:	00253423          	sd	sp,8(a0)
 e06:	e900                	sd	s0,16(a0)
 e08:	ed04                	sd	s1,24(a0)
 e0a:	03253023          	sd	s2,32(a0)
 e0e:	03353423          	sd	s3,40(a0)
 e12:	03453823          	sd	s4,48(a0)
 e16:	03553c23          	sd	s5,56(a0)
 e1a:	05653023          	sd	s6,64(a0)
 e1e:	05753423          	sd	s7,72(a0)
 e22:	05853823          	sd	s8,80(a0)
 e26:	05953c23          	sd	s9,88(a0)
 e2a:	07a53023          	sd	s10,96(a0)
 e2e:	07b53423          	sd	s11,104(a0)
 e32:	0005b083          	ld	ra,0(a1)
 e36:	0085b103          	ld	sp,8(a1)
 e3a:	6980                	ld	s0,16(a1)
 e3c:	6d84                	ld	s1,24(a1)
 e3e:	0205b903          	ld	s2,32(a1)
 e42:	0285b983          	ld	s3,40(a1)
 e46:	0305ba03          	ld	s4,48(a1)
 e4a:	0385ba83          	ld	s5,56(a1)
 e4e:	0405bb03          	ld	s6,64(a1)
 e52:	0485bb83          	ld	s7,72(a1)
 e56:	0505bc03          	ld	s8,80(a1)
 e5a:	0585bc83          	ld	s9,88(a1)
 e5e:	0605bd03          	ld	s10,96(a1)
 e62:	0685bd83          	ld	s11,104(a1)
 e66:	6546                	ld	a0,80(sp)
 e68:	6586                	ld	a1,64(sp)
 e6a:	7642                	ld	a2,48(sp)
 e6c:	7682                	ld	a3,32(sp)
 e6e:	6742                	ld	a4,16(sp)
 e70:	6782                	ld	a5,0(sp)
 e72:	8082                	ret
