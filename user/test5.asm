
user/_test5:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <ul_start_func>:
    /* Replace with ctime */
    return ctime();
}

/* Simple example that allocates heap memory and accesses it. */
void ul_start_func(int a1) {
   0:	7139                	addi	sp,sp,-64
   2:	fc06                	sd	ra,56(sp)
   4:	f822                	sd	s0,48(sp)
   6:	f426                	sd	s1,40(sp)
   8:	f04a                	sd	s2,32(sp)
   a:	ec4e                	sd	s3,24(sp)
   c:	e852                	sd	s4,16(sp)
   e:	e456                	sd	s5,8(sp)
  10:	0080                	addi	s0,sp,64
  12:	84aa                	mv	s1,a0
    printf("[.] started the thread function (tid = %d, a1 = %d)\n", 
  14:	00001097          	auipc	ra,0x1
  18:	900080e7          	jalr	-1792(ra) # 914 <get_current_tid>
  1c:	85aa                	mv	a1,a0
  1e:	8626                	mv	a2,s1
  20:	00001517          	auipc	a0,0x1
  24:	e5050513          	addi	a0,a0,-432 # e70 <ulthread_context_switch+0x7c>
  28:	00000097          	auipc	ra,0x0
  2c:	74e080e7          	jalr	1870(ra) # 776 <printf>
    return ctime();
  30:	00000097          	auipc	ra,0x0
  34:	476080e7          	jalr	1142(ra) # 4a6 <ctime>
  38:	8a2a                	mv	s4,a0

    uint64 start_time = get_current_time();
    uint64 prev_time = start_time;
    int c = 0, cc=0;
    /* Execute for a really long period */
    for (int i = 0; i <10000000; i++) {
  3a:	4481                	li	s1,0
        if (i%1000000 == 0) {
  3c:	000f49b7          	lui	s3,0xf4
  40:	2409899b          	addiw	s3,s3,576 # f4240 <ulthreads+0x8e210>
            uint64 d = get_current_time();
            if ((d - prev_time) > 10000) { 
  44:	6a89                	lui	s5,0x2
  46:	710a8a93          	addi	s5,s5,1808 # 2710 <stacks+0x6f0>
    for (int i = 0; i <10000000; i++) {
  4a:	00989937          	lui	s2,0x989
  4e:	68090913          	addi	s2,s2,1664 # 989680 <ulthreads+0x923650>
  52:	a021                	j	5a <ul_start_func+0x5a>
  54:	2485                	addiw	s1,s1,1
  56:	03248763          	beq	s1,s2,84 <ul_start_func+0x84>
        if (i%1000000 == 0) {
  5a:	0334e7bb          	remw	a5,s1,s3
  5e:	fbfd                	bnez	a5,54 <ul_start_func+0x54>
    return ctime();
  60:	00000097          	auipc	ra,0x0
  64:	446080e7          	jalr	1094(ra) # 4a6 <ctime>
            if ((d - prev_time) > 10000) { 
  68:	414507b3          	sub	a5,a0,s4
  6c:	fefaf4e3          	bgeu	s5,a5,54 <ul_start_func+0x54>
                ulthread_yield();
  70:	00001097          	auipc	ra,0x1
  74:	c9a080e7          	jalr	-870(ra) # d0a <ulthread_yield>
    return ctime();
  78:	00000097          	auipc	ra,0x0
  7c:	42e080e7          	jalr	1070(ra) # 4a6 <ctime>
  80:	8a2a                	mv	s4,a0
  82:	bfc9                	j	54 <ul_start_func+0x54>
                prev_time = get_current_time();
            }
        }
    }
    /* Notify for a thread exit. */
    ulthread_destroy();
  84:	00001097          	auipc	ra,0x1
  88:	d00080e7          	jalr	-768(ra) # d84 <ulthread_destroy>
}
  8c:	70e2                	ld	ra,56(sp)
  8e:	7442                	ld	s0,48(sp)
  90:	74a2                	ld	s1,40(sp)
  92:	7902                	ld	s2,32(sp)
  94:	69e2                	ld	s3,24(sp)
  96:	6a42                	ld	s4,16(sp)
  98:	6aa2                	ld	s5,8(sp)
  9a:	6121                	addi	sp,sp,64
  9c:	8082                	ret

000000000000009e <get_current_time>:
uint64 get_current_time(void) {
  9e:	1141                	addi	sp,sp,-16
  a0:	e406                	sd	ra,8(sp)
  a2:	e022                	sd	s0,0(sp)
  a4:	0800                	addi	s0,sp,16
    return ctime();
  a6:	00000097          	auipc	ra,0x0
  aa:	400080e7          	jalr	1024(ra) # 4a6 <ctime>
}
  ae:	60a2                	ld	ra,8(sp)
  b0:	6402                	ld	s0,0(sp)
  b2:	0141                	addi	sp,sp,16
  b4:	8082                	ret

00000000000000b6 <main>:

int
main(int argc, char *argv[])
{
  b6:	715d                	addi	sp,sp,-80
  b8:	e486                	sd	ra,72(sp)
  ba:	e0a2                	sd	s0,64(sp)
  bc:	fc26                	sd	s1,56(sp)
  be:	0880                	addi	s0,sp,80
    /* Clear the stack region */
    memset(&stacks, 0, sizeof(stacks));
  c0:	00064637          	lui	a2,0x64
  c4:	4581                	li	a1,0
  c6:	00002517          	auipc	a0,0x2
  ca:	f5a50513          	addi	a0,a0,-166 # 2020 <stacks>
  ce:	00000097          	auipc	ra,0x0
  d2:	13e080e7          	jalr	318(ra) # 20c <memset>

    /* Initialize the user-level threading library */
    ulthread_init(PRIORITY);
  d6:	4505                	li	a0,1
  d8:	00001097          	auipc	ra,0x1
  dc:	ab4080e7          	jalr	-1356(ra) # b8c <ulthread_init>

    /* Create a user-level thread */
    uint64 args[6] = {1,1,1,1,0,0};
  e0:	00001797          	auipc	a5,0x1
  e4:	e1078793          	addi	a5,a5,-496 # ef0 <ulthread_context_switch+0xfc>
  e8:	6388                	ld	a0,0(a5)
  ea:	678c                	ld	a1,8(a5)
  ec:	6b90                	ld	a2,16(a5)
  ee:	6f94                	ld	a3,24(a5)
  f0:	7398                	ld	a4,32(a5)
  f2:	779c                	ld	a5,40(a5)
  f4:	faa43823          	sd	a0,-80(s0)
  f8:	fab43c23          	sd	a1,-72(s0)
  fc:	fcc43023          	sd	a2,-64(s0)
 100:	fcd43423          	sd	a3,-56(s0)
 104:	fce43823          	sd	a4,-48(s0)
 108:	fcf43c23          	sd	a5,-40(s0)
    for (int i = 0; i < 3; i++)
        ulthread_create((uint64) ul_start_func, (uint64) (stacks+((i+1)*PGSIZE)), args, i%5);
 10c:	00000497          	auipc	s1,0x0
 110:	ef448493          	addi	s1,s1,-268 # 0 <ul_start_func>
 114:	4681                	li	a3,0
 116:	fb040613          	addi	a2,s0,-80
 11a:	00003597          	auipc	a1,0x3
 11e:	f0658593          	addi	a1,a1,-250 # 3020 <stacks+0x1000>
 122:	8526                	mv	a0,s1
 124:	00001097          	auipc	ra,0x1
 128:	ac2080e7          	jalr	-1342(ra) # be6 <ulthread_create>
 12c:	4685                	li	a3,1
 12e:	fb040613          	addi	a2,s0,-80
 132:	00004597          	auipc	a1,0x4
 136:	eee58593          	addi	a1,a1,-274 # 4020 <stacks+0x2000>
 13a:	8526                	mv	a0,s1
 13c:	00001097          	auipc	ra,0x1
 140:	aaa080e7          	jalr	-1366(ra) # be6 <ulthread_create>
 144:	4689                	li	a3,2
 146:	fb040613          	addi	a2,s0,-80
 14a:	00005597          	auipc	a1,0x5
 14e:	ed658593          	addi	a1,a1,-298 # 5020 <stacks+0x3000>
 152:	8526                	mv	a0,s1
 154:	00001097          	auipc	ra,0x1
 158:	a92080e7          	jalr	-1390(ra) # be6 <ulthread_create>

    /* Schedule all of the threads */
    ulthread_schedule();
 15c:	00001097          	auipc	ra,0x1
 160:	b6a080e7          	jalr	-1174(ra) # cc6 <ulthread_schedule>

    printf("[*] User-Level Threading Test #5 (PRIO Collaborative) Complete.\n");
 164:	00001517          	auipc	a0,0x1
 168:	d4450513          	addi	a0,a0,-700 # ea8 <ulthread_context_switch+0xb4>
 16c:	00000097          	auipc	ra,0x0
 170:	60a080e7          	jalr	1546(ra) # 776 <printf>
    return 0;
}
 174:	4501                	li	a0,0
 176:	60a6                	ld	ra,72(sp)
 178:	6406                	ld	s0,64(sp)
 17a:	74e2                	ld	s1,56(sp)
 17c:	6161                	addi	sp,sp,80
 17e:	8082                	ret

0000000000000180 <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
 180:	1141                	addi	sp,sp,-16
 182:	e406                	sd	ra,8(sp)
 184:	e022                	sd	s0,0(sp)
 186:	0800                	addi	s0,sp,16
  extern int main();
  main();
 188:	00000097          	auipc	ra,0x0
 18c:	f2e080e7          	jalr	-210(ra) # b6 <main>
  exit(0);
 190:	4501                	li	a0,0
 192:	00000097          	auipc	ra,0x0
 196:	274080e7          	jalr	628(ra) # 406 <exit>

000000000000019a <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 19a:	1141                	addi	sp,sp,-16
 19c:	e422                	sd	s0,8(sp)
 19e:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 1a0:	87aa                	mv	a5,a0
 1a2:	0585                	addi	a1,a1,1
 1a4:	0785                	addi	a5,a5,1
 1a6:	fff5c703          	lbu	a4,-1(a1)
 1aa:	fee78fa3          	sb	a4,-1(a5)
 1ae:	fb75                	bnez	a4,1a2 <strcpy+0x8>
    ;
  return os;
}
 1b0:	6422                	ld	s0,8(sp)
 1b2:	0141                	addi	sp,sp,16
 1b4:	8082                	ret

00000000000001b6 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 1b6:	1141                	addi	sp,sp,-16
 1b8:	e422                	sd	s0,8(sp)
 1ba:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 1bc:	00054783          	lbu	a5,0(a0)
 1c0:	cb91                	beqz	a5,1d4 <strcmp+0x1e>
 1c2:	0005c703          	lbu	a4,0(a1)
 1c6:	00f71763          	bne	a4,a5,1d4 <strcmp+0x1e>
    p++, q++;
 1ca:	0505                	addi	a0,a0,1
 1cc:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 1ce:	00054783          	lbu	a5,0(a0)
 1d2:	fbe5                	bnez	a5,1c2 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 1d4:	0005c503          	lbu	a0,0(a1)
}
 1d8:	40a7853b          	subw	a0,a5,a0
 1dc:	6422                	ld	s0,8(sp)
 1de:	0141                	addi	sp,sp,16
 1e0:	8082                	ret

00000000000001e2 <strlen>:

uint
strlen(const char *s)
{
 1e2:	1141                	addi	sp,sp,-16
 1e4:	e422                	sd	s0,8(sp)
 1e6:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 1e8:	00054783          	lbu	a5,0(a0)
 1ec:	cf91                	beqz	a5,208 <strlen+0x26>
 1ee:	0505                	addi	a0,a0,1
 1f0:	87aa                	mv	a5,a0
 1f2:	86be                	mv	a3,a5
 1f4:	0785                	addi	a5,a5,1
 1f6:	fff7c703          	lbu	a4,-1(a5)
 1fa:	ff65                	bnez	a4,1f2 <strlen+0x10>
 1fc:	40a6853b          	subw	a0,a3,a0
 200:	2505                	addiw	a0,a0,1
    ;
  return n;
}
 202:	6422                	ld	s0,8(sp)
 204:	0141                	addi	sp,sp,16
 206:	8082                	ret
  for(n = 0; s[n]; n++)
 208:	4501                	li	a0,0
 20a:	bfe5                	j	202 <strlen+0x20>

000000000000020c <memset>:

void*
memset(void *dst, int c, uint n)
{
 20c:	1141                	addi	sp,sp,-16
 20e:	e422                	sd	s0,8(sp)
 210:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 212:	ca19                	beqz	a2,228 <memset+0x1c>
 214:	87aa                	mv	a5,a0
 216:	1602                	slli	a2,a2,0x20
 218:	9201                	srli	a2,a2,0x20
 21a:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 21e:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 222:	0785                	addi	a5,a5,1
 224:	fee79de3          	bne	a5,a4,21e <memset+0x12>
  }
  return dst;
}
 228:	6422                	ld	s0,8(sp)
 22a:	0141                	addi	sp,sp,16
 22c:	8082                	ret

000000000000022e <strchr>:

char*
strchr(const char *s, char c)
{
 22e:	1141                	addi	sp,sp,-16
 230:	e422                	sd	s0,8(sp)
 232:	0800                	addi	s0,sp,16
  for(; *s; s++)
 234:	00054783          	lbu	a5,0(a0)
 238:	cb99                	beqz	a5,24e <strchr+0x20>
    if(*s == c)
 23a:	00f58763          	beq	a1,a5,248 <strchr+0x1a>
  for(; *s; s++)
 23e:	0505                	addi	a0,a0,1
 240:	00054783          	lbu	a5,0(a0)
 244:	fbfd                	bnez	a5,23a <strchr+0xc>
      return (char*)s;
  return 0;
 246:	4501                	li	a0,0
}
 248:	6422                	ld	s0,8(sp)
 24a:	0141                	addi	sp,sp,16
 24c:	8082                	ret
  return 0;
 24e:	4501                	li	a0,0
 250:	bfe5                	j	248 <strchr+0x1a>

0000000000000252 <gets>:

char*
gets(char *buf, int max)
{
 252:	711d                	addi	sp,sp,-96
 254:	ec86                	sd	ra,88(sp)
 256:	e8a2                	sd	s0,80(sp)
 258:	e4a6                	sd	s1,72(sp)
 25a:	e0ca                	sd	s2,64(sp)
 25c:	fc4e                	sd	s3,56(sp)
 25e:	f852                	sd	s4,48(sp)
 260:	f456                	sd	s5,40(sp)
 262:	f05a                	sd	s6,32(sp)
 264:	ec5e                	sd	s7,24(sp)
 266:	1080                	addi	s0,sp,96
 268:	8baa                	mv	s7,a0
 26a:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 26c:	892a                	mv	s2,a0
 26e:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 270:	4aa9                	li	s5,10
 272:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 274:	89a6                	mv	s3,s1
 276:	2485                	addiw	s1,s1,1
 278:	0344d863          	bge	s1,s4,2a8 <gets+0x56>
    cc = read(0, &c, 1);
 27c:	4605                	li	a2,1
 27e:	faf40593          	addi	a1,s0,-81
 282:	4501                	li	a0,0
 284:	00000097          	auipc	ra,0x0
 288:	19a080e7          	jalr	410(ra) # 41e <read>
    if(cc < 1)
 28c:	00a05e63          	blez	a0,2a8 <gets+0x56>
    buf[i++] = c;
 290:	faf44783          	lbu	a5,-81(s0)
 294:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 298:	01578763          	beq	a5,s5,2a6 <gets+0x54>
 29c:	0905                	addi	s2,s2,1
 29e:	fd679be3          	bne	a5,s6,274 <gets+0x22>
  for(i=0; i+1 < max; ){
 2a2:	89a6                	mv	s3,s1
 2a4:	a011                	j	2a8 <gets+0x56>
 2a6:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 2a8:	99de                	add	s3,s3,s7
 2aa:	00098023          	sb	zero,0(s3)
  return buf;
}
 2ae:	855e                	mv	a0,s7
 2b0:	60e6                	ld	ra,88(sp)
 2b2:	6446                	ld	s0,80(sp)
 2b4:	64a6                	ld	s1,72(sp)
 2b6:	6906                	ld	s2,64(sp)
 2b8:	79e2                	ld	s3,56(sp)
 2ba:	7a42                	ld	s4,48(sp)
 2bc:	7aa2                	ld	s5,40(sp)
 2be:	7b02                	ld	s6,32(sp)
 2c0:	6be2                	ld	s7,24(sp)
 2c2:	6125                	addi	sp,sp,96
 2c4:	8082                	ret

00000000000002c6 <stat>:

int
stat(const char *n, struct stat *st)
{
 2c6:	1101                	addi	sp,sp,-32
 2c8:	ec06                	sd	ra,24(sp)
 2ca:	e822                	sd	s0,16(sp)
 2cc:	e426                	sd	s1,8(sp)
 2ce:	e04a                	sd	s2,0(sp)
 2d0:	1000                	addi	s0,sp,32
 2d2:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 2d4:	4581                	li	a1,0
 2d6:	00000097          	auipc	ra,0x0
 2da:	170080e7          	jalr	368(ra) # 446 <open>
  if(fd < 0)
 2de:	02054563          	bltz	a0,308 <stat+0x42>
 2e2:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 2e4:	85ca                	mv	a1,s2
 2e6:	00000097          	auipc	ra,0x0
 2ea:	178080e7          	jalr	376(ra) # 45e <fstat>
 2ee:	892a                	mv	s2,a0
  close(fd);
 2f0:	8526                	mv	a0,s1
 2f2:	00000097          	auipc	ra,0x0
 2f6:	13c080e7          	jalr	316(ra) # 42e <close>
  return r;
}
 2fa:	854a                	mv	a0,s2
 2fc:	60e2                	ld	ra,24(sp)
 2fe:	6442                	ld	s0,16(sp)
 300:	64a2                	ld	s1,8(sp)
 302:	6902                	ld	s2,0(sp)
 304:	6105                	addi	sp,sp,32
 306:	8082                	ret
    return -1;
 308:	597d                	li	s2,-1
 30a:	bfc5                	j	2fa <stat+0x34>

000000000000030c <atoi>:

int
atoi(const char *s)
{
 30c:	1141                	addi	sp,sp,-16
 30e:	e422                	sd	s0,8(sp)
 310:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 312:	00054683          	lbu	a3,0(a0)
 316:	fd06879b          	addiw	a5,a3,-48
 31a:	0ff7f793          	zext.b	a5,a5
 31e:	4625                	li	a2,9
 320:	02f66863          	bltu	a2,a5,350 <atoi+0x44>
 324:	872a                	mv	a4,a0
  n = 0;
 326:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 328:	0705                	addi	a4,a4,1
 32a:	0025179b          	slliw	a5,a0,0x2
 32e:	9fa9                	addw	a5,a5,a0
 330:	0017979b          	slliw	a5,a5,0x1
 334:	9fb5                	addw	a5,a5,a3
 336:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 33a:	00074683          	lbu	a3,0(a4)
 33e:	fd06879b          	addiw	a5,a3,-48
 342:	0ff7f793          	zext.b	a5,a5
 346:	fef671e3          	bgeu	a2,a5,328 <atoi+0x1c>
  return n;
}
 34a:	6422                	ld	s0,8(sp)
 34c:	0141                	addi	sp,sp,16
 34e:	8082                	ret
  n = 0;
 350:	4501                	li	a0,0
 352:	bfe5                	j	34a <atoi+0x3e>

0000000000000354 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 354:	1141                	addi	sp,sp,-16
 356:	e422                	sd	s0,8(sp)
 358:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 35a:	02b57463          	bgeu	a0,a1,382 <memmove+0x2e>
    while(n-- > 0)
 35e:	00c05f63          	blez	a2,37c <memmove+0x28>
 362:	1602                	slli	a2,a2,0x20
 364:	9201                	srli	a2,a2,0x20
 366:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 36a:	872a                	mv	a4,a0
      *dst++ = *src++;
 36c:	0585                	addi	a1,a1,1
 36e:	0705                	addi	a4,a4,1
 370:	fff5c683          	lbu	a3,-1(a1)
 374:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 378:	fee79ae3          	bne	a5,a4,36c <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 37c:	6422                	ld	s0,8(sp)
 37e:	0141                	addi	sp,sp,16
 380:	8082                	ret
    dst += n;
 382:	00c50733          	add	a4,a0,a2
    src += n;
 386:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 388:	fec05ae3          	blez	a2,37c <memmove+0x28>
 38c:	fff6079b          	addiw	a5,a2,-1 # 63fff <stacks+0x61fdf>
 390:	1782                	slli	a5,a5,0x20
 392:	9381                	srli	a5,a5,0x20
 394:	fff7c793          	not	a5,a5
 398:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 39a:	15fd                	addi	a1,a1,-1
 39c:	177d                	addi	a4,a4,-1
 39e:	0005c683          	lbu	a3,0(a1)
 3a2:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 3a6:	fee79ae3          	bne	a5,a4,39a <memmove+0x46>
 3aa:	bfc9                	j	37c <memmove+0x28>

00000000000003ac <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 3ac:	1141                	addi	sp,sp,-16
 3ae:	e422                	sd	s0,8(sp)
 3b0:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 3b2:	ca05                	beqz	a2,3e2 <memcmp+0x36>
 3b4:	fff6069b          	addiw	a3,a2,-1
 3b8:	1682                	slli	a3,a3,0x20
 3ba:	9281                	srli	a3,a3,0x20
 3bc:	0685                	addi	a3,a3,1
 3be:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 3c0:	00054783          	lbu	a5,0(a0)
 3c4:	0005c703          	lbu	a4,0(a1)
 3c8:	00e79863          	bne	a5,a4,3d8 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 3cc:	0505                	addi	a0,a0,1
    p2++;
 3ce:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 3d0:	fed518e3          	bne	a0,a3,3c0 <memcmp+0x14>
  }
  return 0;
 3d4:	4501                	li	a0,0
 3d6:	a019                	j	3dc <memcmp+0x30>
      return *p1 - *p2;
 3d8:	40e7853b          	subw	a0,a5,a4
}
 3dc:	6422                	ld	s0,8(sp)
 3de:	0141                	addi	sp,sp,16
 3e0:	8082                	ret
  return 0;
 3e2:	4501                	li	a0,0
 3e4:	bfe5                	j	3dc <memcmp+0x30>

00000000000003e6 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 3e6:	1141                	addi	sp,sp,-16
 3e8:	e406                	sd	ra,8(sp)
 3ea:	e022                	sd	s0,0(sp)
 3ec:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 3ee:	00000097          	auipc	ra,0x0
 3f2:	f66080e7          	jalr	-154(ra) # 354 <memmove>
}
 3f6:	60a2                	ld	ra,8(sp)
 3f8:	6402                	ld	s0,0(sp)
 3fa:	0141                	addi	sp,sp,16
 3fc:	8082                	ret

00000000000003fe <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 3fe:	4885                	li	a7,1
 ecall
 400:	00000073          	ecall
 ret
 404:	8082                	ret

0000000000000406 <exit>:
.global exit
exit:
 li a7, SYS_exit
 406:	4889                	li	a7,2
 ecall
 408:	00000073          	ecall
 ret
 40c:	8082                	ret

000000000000040e <wait>:
.global wait
wait:
 li a7, SYS_wait
 40e:	488d                	li	a7,3
 ecall
 410:	00000073          	ecall
 ret
 414:	8082                	ret

0000000000000416 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 416:	4891                	li	a7,4
 ecall
 418:	00000073          	ecall
 ret
 41c:	8082                	ret

000000000000041e <read>:
.global read
read:
 li a7, SYS_read
 41e:	4895                	li	a7,5
 ecall
 420:	00000073          	ecall
 ret
 424:	8082                	ret

0000000000000426 <write>:
.global write
write:
 li a7, SYS_write
 426:	48c1                	li	a7,16
 ecall
 428:	00000073          	ecall
 ret
 42c:	8082                	ret

000000000000042e <close>:
.global close
close:
 li a7, SYS_close
 42e:	48d5                	li	a7,21
 ecall
 430:	00000073          	ecall
 ret
 434:	8082                	ret

0000000000000436 <kill>:
.global kill
kill:
 li a7, SYS_kill
 436:	4899                	li	a7,6
 ecall
 438:	00000073          	ecall
 ret
 43c:	8082                	ret

000000000000043e <exec>:
.global exec
exec:
 li a7, SYS_exec
 43e:	489d                	li	a7,7
 ecall
 440:	00000073          	ecall
 ret
 444:	8082                	ret

0000000000000446 <open>:
.global open
open:
 li a7, SYS_open
 446:	48bd                	li	a7,15
 ecall
 448:	00000073          	ecall
 ret
 44c:	8082                	ret

000000000000044e <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 44e:	48c5                	li	a7,17
 ecall
 450:	00000073          	ecall
 ret
 454:	8082                	ret

0000000000000456 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 456:	48c9                	li	a7,18
 ecall
 458:	00000073          	ecall
 ret
 45c:	8082                	ret

000000000000045e <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 45e:	48a1                	li	a7,8
 ecall
 460:	00000073          	ecall
 ret
 464:	8082                	ret

0000000000000466 <link>:
.global link
link:
 li a7, SYS_link
 466:	48cd                	li	a7,19
 ecall
 468:	00000073          	ecall
 ret
 46c:	8082                	ret

000000000000046e <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 46e:	48d1                	li	a7,20
 ecall
 470:	00000073          	ecall
 ret
 474:	8082                	ret

0000000000000476 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 476:	48a5                	li	a7,9
 ecall
 478:	00000073          	ecall
 ret
 47c:	8082                	ret

000000000000047e <dup>:
.global dup
dup:
 li a7, SYS_dup
 47e:	48a9                	li	a7,10
 ecall
 480:	00000073          	ecall
 ret
 484:	8082                	ret

0000000000000486 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 486:	48ad                	li	a7,11
 ecall
 488:	00000073          	ecall
 ret
 48c:	8082                	ret

000000000000048e <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 48e:	48b1                	li	a7,12
 ecall
 490:	00000073          	ecall
 ret
 494:	8082                	ret

0000000000000496 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 496:	48b5                	li	a7,13
 ecall
 498:	00000073          	ecall
 ret
 49c:	8082                	ret

000000000000049e <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 49e:	48b9                	li	a7,14
 ecall
 4a0:	00000073          	ecall
 ret
 4a4:	8082                	ret

00000000000004a6 <ctime>:
.global ctime
ctime:
 li a7, SYS_ctime
 4a6:	48d9                	li	a7,22
 ecall
 4a8:	00000073          	ecall
 ret
 4ac:	8082                	ret

00000000000004ae <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 4ae:	1101                	addi	sp,sp,-32
 4b0:	ec06                	sd	ra,24(sp)
 4b2:	e822                	sd	s0,16(sp)
 4b4:	1000                	addi	s0,sp,32
 4b6:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 4ba:	4605                	li	a2,1
 4bc:	fef40593          	addi	a1,s0,-17
 4c0:	00000097          	auipc	ra,0x0
 4c4:	f66080e7          	jalr	-154(ra) # 426 <write>
}
 4c8:	60e2                	ld	ra,24(sp)
 4ca:	6442                	ld	s0,16(sp)
 4cc:	6105                	addi	sp,sp,32
 4ce:	8082                	ret

00000000000004d0 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 4d0:	7139                	addi	sp,sp,-64
 4d2:	fc06                	sd	ra,56(sp)
 4d4:	f822                	sd	s0,48(sp)
 4d6:	f426                	sd	s1,40(sp)
 4d8:	f04a                	sd	s2,32(sp)
 4da:	ec4e                	sd	s3,24(sp)
 4dc:	0080                	addi	s0,sp,64
 4de:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 4e0:	c299                	beqz	a3,4e6 <printint+0x16>
 4e2:	0805c963          	bltz	a1,574 <printint+0xa4>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 4e6:	2581                	sext.w	a1,a1
  neg = 0;
 4e8:	4881                	li	a7,0
 4ea:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 4ee:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 4f0:	2601                	sext.w	a2,a2
 4f2:	00001517          	auipc	a0,0x1
 4f6:	a8e50513          	addi	a0,a0,-1394 # f80 <digits>
 4fa:	883a                	mv	a6,a4
 4fc:	2705                	addiw	a4,a4,1
 4fe:	02c5f7bb          	remuw	a5,a1,a2
 502:	1782                	slli	a5,a5,0x20
 504:	9381                	srli	a5,a5,0x20
 506:	97aa                	add	a5,a5,a0
 508:	0007c783          	lbu	a5,0(a5)
 50c:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 510:	0005879b          	sext.w	a5,a1
 514:	02c5d5bb          	divuw	a1,a1,a2
 518:	0685                	addi	a3,a3,1
 51a:	fec7f0e3          	bgeu	a5,a2,4fa <printint+0x2a>
  if(neg)
 51e:	00088c63          	beqz	a7,536 <printint+0x66>
    buf[i++] = '-';
 522:	fd070793          	addi	a5,a4,-48
 526:	00878733          	add	a4,a5,s0
 52a:	02d00793          	li	a5,45
 52e:	fef70823          	sb	a5,-16(a4)
 532:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 536:	02e05863          	blez	a4,566 <printint+0x96>
 53a:	fc040793          	addi	a5,s0,-64
 53e:	00e78933          	add	s2,a5,a4
 542:	fff78993          	addi	s3,a5,-1
 546:	99ba                	add	s3,s3,a4
 548:	377d                	addiw	a4,a4,-1
 54a:	1702                	slli	a4,a4,0x20
 54c:	9301                	srli	a4,a4,0x20
 54e:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 552:	fff94583          	lbu	a1,-1(s2)
 556:	8526                	mv	a0,s1
 558:	00000097          	auipc	ra,0x0
 55c:	f56080e7          	jalr	-170(ra) # 4ae <putc>
  while(--i >= 0)
 560:	197d                	addi	s2,s2,-1
 562:	ff3918e3          	bne	s2,s3,552 <printint+0x82>
}
 566:	70e2                	ld	ra,56(sp)
 568:	7442                	ld	s0,48(sp)
 56a:	74a2                	ld	s1,40(sp)
 56c:	7902                	ld	s2,32(sp)
 56e:	69e2                	ld	s3,24(sp)
 570:	6121                	addi	sp,sp,64
 572:	8082                	ret
    x = -xx;
 574:	40b005bb          	negw	a1,a1
    neg = 1;
 578:	4885                	li	a7,1
    x = -xx;
 57a:	bf85                	j	4ea <printint+0x1a>

000000000000057c <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 57c:	715d                	addi	sp,sp,-80
 57e:	e486                	sd	ra,72(sp)
 580:	e0a2                	sd	s0,64(sp)
 582:	fc26                	sd	s1,56(sp)
 584:	f84a                	sd	s2,48(sp)
 586:	f44e                	sd	s3,40(sp)
 588:	f052                	sd	s4,32(sp)
 58a:	ec56                	sd	s5,24(sp)
 58c:	e85a                	sd	s6,16(sp)
 58e:	e45e                	sd	s7,8(sp)
 590:	e062                	sd	s8,0(sp)
 592:	0880                	addi	s0,sp,80
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 594:	0005c903          	lbu	s2,0(a1)
 598:	18090c63          	beqz	s2,730 <vprintf+0x1b4>
 59c:	8aaa                	mv	s5,a0
 59e:	8bb2                	mv	s7,a2
 5a0:	00158493          	addi	s1,a1,1
  state = 0;
 5a4:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 5a6:	02500a13          	li	s4,37
 5aa:	4b55                	li	s6,21
 5ac:	a839                	j	5ca <vprintf+0x4e>
        putc(fd, c);
 5ae:	85ca                	mv	a1,s2
 5b0:	8556                	mv	a0,s5
 5b2:	00000097          	auipc	ra,0x0
 5b6:	efc080e7          	jalr	-260(ra) # 4ae <putc>
 5ba:	a019                	j	5c0 <vprintf+0x44>
    } else if(state == '%'){
 5bc:	01498d63          	beq	s3,s4,5d6 <vprintf+0x5a>
  for(i = 0; fmt[i]; i++){
 5c0:	0485                	addi	s1,s1,1
 5c2:	fff4c903          	lbu	s2,-1(s1)
 5c6:	16090563          	beqz	s2,730 <vprintf+0x1b4>
    if(state == 0){
 5ca:	fe0999e3          	bnez	s3,5bc <vprintf+0x40>
      if(c == '%'){
 5ce:	ff4910e3          	bne	s2,s4,5ae <vprintf+0x32>
        state = '%';
 5d2:	89d2                	mv	s3,s4
 5d4:	b7f5                	j	5c0 <vprintf+0x44>
      if(c == 'd'){
 5d6:	13490263          	beq	s2,s4,6fa <vprintf+0x17e>
 5da:	f9d9079b          	addiw	a5,s2,-99
 5de:	0ff7f793          	zext.b	a5,a5
 5e2:	12fb6563          	bltu	s6,a5,70c <vprintf+0x190>
 5e6:	f9d9079b          	addiw	a5,s2,-99
 5ea:	0ff7f713          	zext.b	a4,a5
 5ee:	10eb6f63          	bltu	s6,a4,70c <vprintf+0x190>
 5f2:	00271793          	slli	a5,a4,0x2
 5f6:	00001717          	auipc	a4,0x1
 5fa:	93270713          	addi	a4,a4,-1742 # f28 <ulthread_context_switch+0x134>
 5fe:	97ba                	add	a5,a5,a4
 600:	439c                	lw	a5,0(a5)
 602:	97ba                	add	a5,a5,a4
 604:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
 606:	008b8913          	addi	s2,s7,8
 60a:	4685                	li	a3,1
 60c:	4629                	li	a2,10
 60e:	000ba583          	lw	a1,0(s7)
 612:	8556                	mv	a0,s5
 614:	00000097          	auipc	ra,0x0
 618:	ebc080e7          	jalr	-324(ra) # 4d0 <printint>
 61c:	8bca                	mv	s7,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 61e:	4981                	li	s3,0
 620:	b745                	j	5c0 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 622:	008b8913          	addi	s2,s7,8
 626:	4681                	li	a3,0
 628:	4629                	li	a2,10
 62a:	000ba583          	lw	a1,0(s7)
 62e:	8556                	mv	a0,s5
 630:	00000097          	auipc	ra,0x0
 634:	ea0080e7          	jalr	-352(ra) # 4d0 <printint>
 638:	8bca                	mv	s7,s2
      state = 0;
 63a:	4981                	li	s3,0
 63c:	b751                	j	5c0 <vprintf+0x44>
        printint(fd, va_arg(ap, int), 16, 0);
 63e:	008b8913          	addi	s2,s7,8
 642:	4681                	li	a3,0
 644:	4641                	li	a2,16
 646:	000ba583          	lw	a1,0(s7)
 64a:	8556                	mv	a0,s5
 64c:	00000097          	auipc	ra,0x0
 650:	e84080e7          	jalr	-380(ra) # 4d0 <printint>
 654:	8bca                	mv	s7,s2
      state = 0;
 656:	4981                	li	s3,0
 658:	b7a5                	j	5c0 <vprintf+0x44>
        printptr(fd, va_arg(ap, uint64));
 65a:	008b8c13          	addi	s8,s7,8
 65e:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 662:	03000593          	li	a1,48
 666:	8556                	mv	a0,s5
 668:	00000097          	auipc	ra,0x0
 66c:	e46080e7          	jalr	-442(ra) # 4ae <putc>
  putc(fd, 'x');
 670:	07800593          	li	a1,120
 674:	8556                	mv	a0,s5
 676:	00000097          	auipc	ra,0x0
 67a:	e38080e7          	jalr	-456(ra) # 4ae <putc>
 67e:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 680:	00001b97          	auipc	s7,0x1
 684:	900b8b93          	addi	s7,s7,-1792 # f80 <digits>
 688:	03c9d793          	srli	a5,s3,0x3c
 68c:	97de                	add	a5,a5,s7
 68e:	0007c583          	lbu	a1,0(a5)
 692:	8556                	mv	a0,s5
 694:	00000097          	auipc	ra,0x0
 698:	e1a080e7          	jalr	-486(ra) # 4ae <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 69c:	0992                	slli	s3,s3,0x4
 69e:	397d                	addiw	s2,s2,-1
 6a0:	fe0914e3          	bnez	s2,688 <vprintf+0x10c>
        printptr(fd, va_arg(ap, uint64));
 6a4:	8be2                	mv	s7,s8
      state = 0;
 6a6:	4981                	li	s3,0
 6a8:	bf21                	j	5c0 <vprintf+0x44>
        s = va_arg(ap, char*);
 6aa:	008b8993          	addi	s3,s7,8
 6ae:	000bb903          	ld	s2,0(s7)
        if(s == 0)
 6b2:	02090163          	beqz	s2,6d4 <vprintf+0x158>
        while(*s != 0){
 6b6:	00094583          	lbu	a1,0(s2)
 6ba:	c9a5                	beqz	a1,72a <vprintf+0x1ae>
          putc(fd, *s);
 6bc:	8556                	mv	a0,s5
 6be:	00000097          	auipc	ra,0x0
 6c2:	df0080e7          	jalr	-528(ra) # 4ae <putc>
          s++;
 6c6:	0905                	addi	s2,s2,1
        while(*s != 0){
 6c8:	00094583          	lbu	a1,0(s2)
 6cc:	f9e5                	bnez	a1,6bc <vprintf+0x140>
        s = va_arg(ap, char*);
 6ce:	8bce                	mv	s7,s3
      state = 0;
 6d0:	4981                	li	s3,0
 6d2:	b5fd                	j	5c0 <vprintf+0x44>
          s = "(null)";
 6d4:	00001917          	auipc	s2,0x1
 6d8:	84c90913          	addi	s2,s2,-1972 # f20 <ulthread_context_switch+0x12c>
        while(*s != 0){
 6dc:	02800593          	li	a1,40
 6e0:	bff1                	j	6bc <vprintf+0x140>
        putc(fd, va_arg(ap, uint));
 6e2:	008b8913          	addi	s2,s7,8
 6e6:	000bc583          	lbu	a1,0(s7)
 6ea:	8556                	mv	a0,s5
 6ec:	00000097          	auipc	ra,0x0
 6f0:	dc2080e7          	jalr	-574(ra) # 4ae <putc>
 6f4:	8bca                	mv	s7,s2
      state = 0;
 6f6:	4981                	li	s3,0
 6f8:	b5e1                	j	5c0 <vprintf+0x44>
        putc(fd, c);
 6fa:	02500593          	li	a1,37
 6fe:	8556                	mv	a0,s5
 700:	00000097          	auipc	ra,0x0
 704:	dae080e7          	jalr	-594(ra) # 4ae <putc>
      state = 0;
 708:	4981                	li	s3,0
 70a:	bd5d                	j	5c0 <vprintf+0x44>
        putc(fd, '%');
 70c:	02500593          	li	a1,37
 710:	8556                	mv	a0,s5
 712:	00000097          	auipc	ra,0x0
 716:	d9c080e7          	jalr	-612(ra) # 4ae <putc>
        putc(fd, c);
 71a:	85ca                	mv	a1,s2
 71c:	8556                	mv	a0,s5
 71e:	00000097          	auipc	ra,0x0
 722:	d90080e7          	jalr	-624(ra) # 4ae <putc>
      state = 0;
 726:	4981                	li	s3,0
 728:	bd61                	j	5c0 <vprintf+0x44>
        s = va_arg(ap, char*);
 72a:	8bce                	mv	s7,s3
      state = 0;
 72c:	4981                	li	s3,0
 72e:	bd49                	j	5c0 <vprintf+0x44>
    }
  }
}
 730:	60a6                	ld	ra,72(sp)
 732:	6406                	ld	s0,64(sp)
 734:	74e2                	ld	s1,56(sp)
 736:	7942                	ld	s2,48(sp)
 738:	79a2                	ld	s3,40(sp)
 73a:	7a02                	ld	s4,32(sp)
 73c:	6ae2                	ld	s5,24(sp)
 73e:	6b42                	ld	s6,16(sp)
 740:	6ba2                	ld	s7,8(sp)
 742:	6c02                	ld	s8,0(sp)
 744:	6161                	addi	sp,sp,80
 746:	8082                	ret

0000000000000748 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 748:	715d                	addi	sp,sp,-80
 74a:	ec06                	sd	ra,24(sp)
 74c:	e822                	sd	s0,16(sp)
 74e:	1000                	addi	s0,sp,32
 750:	e010                	sd	a2,0(s0)
 752:	e414                	sd	a3,8(s0)
 754:	e818                	sd	a4,16(s0)
 756:	ec1c                	sd	a5,24(s0)
 758:	03043023          	sd	a6,32(s0)
 75c:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 760:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 764:	8622                	mv	a2,s0
 766:	00000097          	auipc	ra,0x0
 76a:	e16080e7          	jalr	-490(ra) # 57c <vprintf>
}
 76e:	60e2                	ld	ra,24(sp)
 770:	6442                	ld	s0,16(sp)
 772:	6161                	addi	sp,sp,80
 774:	8082                	ret

0000000000000776 <printf>:

void
printf(const char *fmt, ...)
{
 776:	711d                	addi	sp,sp,-96
 778:	ec06                	sd	ra,24(sp)
 77a:	e822                	sd	s0,16(sp)
 77c:	1000                	addi	s0,sp,32
 77e:	e40c                	sd	a1,8(s0)
 780:	e810                	sd	a2,16(s0)
 782:	ec14                	sd	a3,24(s0)
 784:	f018                	sd	a4,32(s0)
 786:	f41c                	sd	a5,40(s0)
 788:	03043823          	sd	a6,48(s0)
 78c:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 790:	00840613          	addi	a2,s0,8
 794:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 798:	85aa                	mv	a1,a0
 79a:	4505                	li	a0,1
 79c:	00000097          	auipc	ra,0x0
 7a0:	de0080e7          	jalr	-544(ra) # 57c <vprintf>
}
 7a4:	60e2                	ld	ra,24(sp)
 7a6:	6442                	ld	s0,16(sp)
 7a8:	6125                	addi	sp,sp,96
 7aa:	8082                	ret

00000000000007ac <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 7ac:	1141                	addi	sp,sp,-16
 7ae:	e422                	sd	s0,8(sp)
 7b0:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 7b2:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7b6:	00002797          	auipc	a5,0x2
 7ba:	84a7b783          	ld	a5,-1974(a5) # 2000 <freep>
 7be:	a02d                	j	7e8 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 7c0:	4618                	lw	a4,8(a2)
 7c2:	9f2d                	addw	a4,a4,a1
 7c4:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 7c8:	6398                	ld	a4,0(a5)
 7ca:	6310                	ld	a2,0(a4)
 7cc:	a83d                	j	80a <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 7ce:	ff852703          	lw	a4,-8(a0)
 7d2:	9f31                	addw	a4,a4,a2
 7d4:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 7d6:	ff053683          	ld	a3,-16(a0)
 7da:	a091                	j	81e <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7dc:	6398                	ld	a4,0(a5)
 7de:	00e7e463          	bltu	a5,a4,7e6 <free+0x3a>
 7e2:	00e6ea63          	bltu	a3,a4,7f6 <free+0x4a>
{
 7e6:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7e8:	fed7fae3          	bgeu	a5,a3,7dc <free+0x30>
 7ec:	6398                	ld	a4,0(a5)
 7ee:	00e6e463          	bltu	a3,a4,7f6 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7f2:	fee7eae3          	bltu	a5,a4,7e6 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 7f6:	ff852583          	lw	a1,-8(a0)
 7fa:	6390                	ld	a2,0(a5)
 7fc:	02059813          	slli	a6,a1,0x20
 800:	01c85713          	srli	a4,a6,0x1c
 804:	9736                	add	a4,a4,a3
 806:	fae60de3          	beq	a2,a4,7c0 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 80a:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 80e:	4790                	lw	a2,8(a5)
 810:	02061593          	slli	a1,a2,0x20
 814:	01c5d713          	srli	a4,a1,0x1c
 818:	973e                	add	a4,a4,a5
 81a:	fae68ae3          	beq	a3,a4,7ce <free+0x22>
    p->s.ptr = bp->s.ptr;
 81e:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 820:	00001717          	auipc	a4,0x1
 824:	7ef73023          	sd	a5,2016(a4) # 2000 <freep>
}
 828:	6422                	ld	s0,8(sp)
 82a:	0141                	addi	sp,sp,16
 82c:	8082                	ret

000000000000082e <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 82e:	7139                	addi	sp,sp,-64
 830:	fc06                	sd	ra,56(sp)
 832:	f822                	sd	s0,48(sp)
 834:	f426                	sd	s1,40(sp)
 836:	f04a                	sd	s2,32(sp)
 838:	ec4e                	sd	s3,24(sp)
 83a:	e852                	sd	s4,16(sp)
 83c:	e456                	sd	s5,8(sp)
 83e:	e05a                	sd	s6,0(sp)
 840:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 842:	02051493          	slli	s1,a0,0x20
 846:	9081                	srli	s1,s1,0x20
 848:	04bd                	addi	s1,s1,15
 84a:	8091                	srli	s1,s1,0x4
 84c:	0014899b          	addiw	s3,s1,1
 850:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 852:	00001517          	auipc	a0,0x1
 856:	7ae53503          	ld	a0,1966(a0) # 2000 <freep>
 85a:	c515                	beqz	a0,886 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 85c:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 85e:	4798                	lw	a4,8(a5)
 860:	02977f63          	bgeu	a4,s1,89e <malloc+0x70>
  if(nu < 4096)
 864:	8a4e                	mv	s4,s3
 866:	0009871b          	sext.w	a4,s3
 86a:	6685                	lui	a3,0x1
 86c:	00d77363          	bgeu	a4,a3,872 <malloc+0x44>
 870:	6a05                	lui	s4,0x1
 872:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 876:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 87a:	00001917          	auipc	s2,0x1
 87e:	78690913          	addi	s2,s2,1926 # 2000 <freep>
  if(p == (char*)-1)
 882:	5afd                	li	s5,-1
 884:	a895                	j	8f8 <malloc+0xca>
    base.s.ptr = freep = prevp = &base;
 886:	00065797          	auipc	a5,0x65
 88a:	79a78793          	addi	a5,a5,1946 # 66020 <base>
 88e:	00001717          	auipc	a4,0x1
 892:	76f73923          	sd	a5,1906(a4) # 2000 <freep>
 896:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 898:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 89c:	b7e1                	j	864 <malloc+0x36>
      if(p->s.size == nunits)
 89e:	02e48c63          	beq	s1,a4,8d6 <malloc+0xa8>
        p->s.size -= nunits;
 8a2:	4137073b          	subw	a4,a4,s3
 8a6:	c798                	sw	a4,8(a5)
        p += p->s.size;
 8a8:	02071693          	slli	a3,a4,0x20
 8ac:	01c6d713          	srli	a4,a3,0x1c
 8b0:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 8b2:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 8b6:	00001717          	auipc	a4,0x1
 8ba:	74a73523          	sd	a0,1866(a4) # 2000 <freep>
      return (void*)(p + 1);
 8be:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 8c2:	70e2                	ld	ra,56(sp)
 8c4:	7442                	ld	s0,48(sp)
 8c6:	74a2                	ld	s1,40(sp)
 8c8:	7902                	ld	s2,32(sp)
 8ca:	69e2                	ld	s3,24(sp)
 8cc:	6a42                	ld	s4,16(sp)
 8ce:	6aa2                	ld	s5,8(sp)
 8d0:	6b02                	ld	s6,0(sp)
 8d2:	6121                	addi	sp,sp,64
 8d4:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 8d6:	6398                	ld	a4,0(a5)
 8d8:	e118                	sd	a4,0(a0)
 8da:	bff1                	j	8b6 <malloc+0x88>
  hp->s.size = nu;
 8dc:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 8e0:	0541                	addi	a0,a0,16
 8e2:	00000097          	auipc	ra,0x0
 8e6:	eca080e7          	jalr	-310(ra) # 7ac <free>
  return freep;
 8ea:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 8ee:	d971                	beqz	a0,8c2 <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8f0:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 8f2:	4798                	lw	a4,8(a5)
 8f4:	fa9775e3          	bgeu	a4,s1,89e <malloc+0x70>
    if(p == freep)
 8f8:	00093703          	ld	a4,0(s2)
 8fc:	853e                	mv	a0,a5
 8fe:	fef719e3          	bne	a4,a5,8f0 <malloc+0xc2>
  p = sbrk(nu * sizeof(Header));
 902:	8552                	mv	a0,s4
 904:	00000097          	auipc	ra,0x0
 908:	b8a080e7          	jalr	-1142(ra) # 48e <sbrk>
  if(p == (char*)-1)
 90c:	fd5518e3          	bne	a0,s5,8dc <malloc+0xae>
        return 0;
 910:	4501                	li	a0,0
 912:	bf45                	j	8c2 <malloc+0x94>

0000000000000914 <get_current_tid>:
struct ulthread *scheduler_thread;
enum ulthread_scheduling_algorithm algorithm;

/* Get thread ID */
int get_current_tid(void)
{
 914:	1141                	addi	sp,sp,-16
 916:	e422                	sd	s0,8(sp)
 918:	0800                	addi	s0,sp,16
  return current_thread->tid;
}
 91a:	00001797          	auipc	a5,0x1
 91e:	6fe7b783          	ld	a5,1790(a5) # 2018 <current_thread>
 922:	43c8                	lw	a0,4(a5)
 924:	6422                	ld	s0,8(sp)
 926:	0141                	addi	sp,sp,16
 928:	8082                	ret

000000000000092a <roundRobin>:

void roundRobin(void)
{
 92a:	715d                	addi	sp,sp,-80
 92c:	e486                	sd	ra,72(sp)
 92e:	e0a2                	sd	s0,64(sp)
 930:	fc26                	sd	s1,56(sp)
 932:	f84a                	sd	s2,48(sp)
 934:	f44e                	sd	s3,40(sp)
 936:	f052                	sd	s4,32(sp)
 938:	ec56                	sd	s5,24(sp)
 93a:	e85a                	sd	s6,16(sp)
 93c:	e45e                	sd	s7,8(sp)
 93e:	e062                	sd	s8,0(sp)
 940:	0880                	addi	s0,sp,80
        struct ulthread *temp = current_thread;
        current_thread = t;
        printf("[*] ultschedule (next tid: %d)\n", get_current_tid());
        ulthread_context_switch(&temp->context, &t->context);
      }
      if (t->state == YIELD)
 942:	4a09                	li	s4,2
      if (t->state == RUNNABLE && t != scheduler_thread)
 944:	00001b97          	auipc	s7,0x1
 948:	6ccb8b93          	addi	s7,s7,1740 # 2010 <scheduler_thread>
        struct ulthread *temp = current_thread;
 94c:	00001a97          	auipc	s5,0x1
 950:	6cca8a93          	addi	s5,s5,1740 # 2018 <current_thread>
        printf("[*] ultschedule (next tid: %d)\n", get_current_tid());
 954:	00000c17          	auipc	s8,0x0
 958:	644c0c13          	addi	s8,s8,1604 # f98 <digits+0x18>
    for (t = ulthreads; t < &ulthreads[MAXULTHREADS]; t++)
 95c:	00069997          	auipc	s3,0x69
 960:	bf498993          	addi	s3,s3,-1036 # 69550 <ulthreads+0x3520>
 964:	a0b9                	j	9b2 <roundRobin+0x88>
      if (t->state == RUNNABLE && t != scheduler_thread)
 966:	000bb783          	ld	a5,0(s7)
 96a:	02978863          	beq	a5,s1,99a <roundRobin+0x70>
        struct ulthread *temp = current_thread;
 96e:	000abb03          	ld	s6,0(s5)
        current_thread = t;
 972:	009ab023          	sd	s1,0(s5)
        printf("[*] ultschedule (next tid: %d)\n", get_current_tid());
 976:	40cc                	lw	a1,4(s1)
 978:	8562                	mv	a0,s8
 97a:	00000097          	auipc	ra,0x0
 97e:	dfc080e7          	jalr	-516(ra) # 776 <printf>
        ulthread_context_switch(&temp->context, &t->context);
 982:	01848593          	addi	a1,s1,24
 986:	018b0513          	addi	a0,s6,24
 98a:	00000097          	auipc	ra,0x0
 98e:	46a080e7          	jalr	1130(ra) # df4 <ulthread_context_switch>
        threadAvailable = true;
 992:	874a                	mv	a4,s2
 994:	a811                	j	9a8 <roundRobin+0x7e>
      {
        t->state = RUNNABLE;
 996:	0124a023          	sw	s2,0(s1)
    for (t = ulthreads; t < &ulthreads[MAXULTHREADS]; t++)
 99a:	08848493          	addi	s1,s1,136
 99e:	01348963          	beq	s1,s3,9b0 <roundRobin+0x86>
      if (t->state == RUNNABLE && t != scheduler_thread)
 9a2:	409c                	lw	a5,0(s1)
 9a4:	fd2781e3          	beq	a5,s2,966 <roundRobin+0x3c>
      if (t->state == YIELD)
 9a8:	409c                	lw	a5,0(s1)
 9aa:	ff4798e3          	bne	a5,s4,99a <roundRobin+0x70>
 9ae:	b7e5                	j	996 <roundRobin+0x6c>
      }
    }
    if (!threadAvailable)
 9b0:	cb01                	beqz	a4,9c0 <roundRobin+0x96>
    bool threadAvailable = false;
 9b2:	4701                	li	a4,0
    for (t = ulthreads; t < &ulthreads[MAXULTHREADS]; t++)
 9b4:	00065497          	auipc	s1,0x65
 9b8:	67c48493          	addi	s1,s1,1660 # 66030 <ulthreads>
      if (t->state == RUNNABLE && t != scheduler_thread)
 9bc:	4905                	li	s2,1
 9be:	b7d5                	j	9a2 <roundRobin+0x78>
    {
      break;
    }
  }
}
 9c0:	60a6                	ld	ra,72(sp)
 9c2:	6406                	ld	s0,64(sp)
 9c4:	74e2                	ld	s1,56(sp)
 9c6:	7942                	ld	s2,48(sp)
 9c8:	79a2                	ld	s3,40(sp)
 9ca:	7a02                	ld	s4,32(sp)
 9cc:	6ae2                	ld	s5,24(sp)
 9ce:	6b42                	ld	s6,16(sp)
 9d0:	6ba2                	ld	s7,8(sp)
 9d2:	6c02                	ld	s8,0(sp)
 9d4:	6161                	addi	sp,sp,80
 9d6:	8082                	ret

00000000000009d8 <firstComeFirstServe>:

void firstComeFirstServe(void)
{
 9d8:	715d                	addi	sp,sp,-80
 9da:	e486                	sd	ra,72(sp)
 9dc:	e0a2                	sd	s0,64(sp)
 9de:	fc26                	sd	s1,56(sp)
 9e0:	f84a                	sd	s2,48(sp)
 9e2:	f44e                	sd	s3,40(sp)
 9e4:	f052                	sd	s4,32(sp)
 9e6:	ec56                	sd	s5,24(sp)
 9e8:	e85a                	sd	s6,16(sp)
 9ea:	e45e                	sd	s7,8(sp)
 9ec:	e062                	sd	s8,0(sp)
 9ee:	0880                	addi	s0,sp,80
    uint64 oldest = __INT64_MAX__;
    int threadIndex = -1;
    int alternativeIndex = -1;
    for (t = ulthreads+1; t < &ulthreads[MAXULTHREADS]; t++)
    {
      if (t->state == RUNNABLE && t != scheduler_thread && t->lastTime < oldest)
 9f0:	00001b97          	auipc	s7,0x1
 9f4:	620b8b93          	addi	s7,s7,1568 # 2010 <scheduler_thread>
    int alternativeIndex = -1;
 9f8:	5afd                	li	s5,-1
    uint64 oldest = __INT64_MAX__;
 9fa:	001adb13          	srli	s6,s5,0x1
      if (t->state == RUNNABLE && t != scheduler_thread && t->lastTime < oldest)
 9fe:	4485                	li	s1,1
        oldest = t->lastTime;
        threadIndex = t->tid;
        threadAvailable = true;
      }

      if (t->state == YIELD){
 a00:	4989                	li	s3,2
    for (t = ulthreads+1; t < &ulthreads[MAXULTHREADS]; t++)
 a02:	00069917          	auipc	s2,0x69
 a06:	b4e90913          	addi	s2,s2,-1202 # 69550 <ulthreads+0x3520>
        break;
      }
      
    }
    label : 
      struct ulthread *temp = current_thread;
 a0a:	00001a17          	auipc	s4,0x1
 a0e:	60ea0a13          	addi	s4,s4,1550 # 2018 <current_thread>
 a12:	a88d                	j	a84 <firstComeFirstServe+0xac>
      if (t->state == RUNNABLE && t != scheduler_thread && t->lastTime < oldest)
 a14:	00f58963          	beq	a1,a5,a26 <firstComeFirstServe+0x4e>
 a18:	6b98                	ld	a4,16(a5)
 a1a:	00c77663          	bgeu	a4,a2,a26 <firstComeFirstServe+0x4e>
        threadIndex = t->tid;
 a1e:	0047a803          	lw	a6,4(a5)
        oldest = t->lastTime;
 a22:	863a                	mv	a2,a4
        threadAvailable = true;
 a24:	8526                	mv	a0,s1
    for (t = ulthreads+1; t < &ulthreads[MAXULTHREADS]; t++)
 a26:	08878793          	addi	a5,a5,136
 a2a:	01278a63          	beq	a5,s2,a3e <firstComeFirstServe+0x66>
      if (t->state == RUNNABLE && t != scheduler_thread && t->lastTime < oldest)
 a2e:	4398                	lw	a4,0(a5)
 a30:	fe9702e3          	beq	a4,s1,a14 <firstComeFirstServe+0x3c>
      if (t->state == YIELD){
 a34:	ff3719e3          	bne	a4,s3,a26 <firstComeFirstServe+0x4e>
        t->state = RUNNABLE;
 a38:	c384                	sw	s1,0(a5)
        alternativeIndex = t->tid;
 a3a:	43d4                	lw	a3,4(a5)
 a3c:	b7ed                	j	a26 <firstComeFirstServe+0x4e>
    if (!threadAvailable)
 a3e:	ed31                	bnez	a0,a9a <firstComeFirstServe+0xc2>
      if(alternativeIndex > 0){
 a40:	04d05f63          	blez	a3,a9e <firstComeFirstServe+0xc6>
      struct ulthread *temp = current_thread;
 a44:	000a3c03          	ld	s8,0(s4)
      current_thread = &ulthreads[threadIndex];
 a48:	00469793          	slli	a5,a3,0x4
 a4c:	00d78733          	add	a4,a5,a3
 a50:	070e                	slli	a4,a4,0x3
 a52:	00065617          	auipc	a2,0x65
 a56:	5de60613          	addi	a2,a2,1502 # 66030 <ulthreads>
 a5a:	9732                	add	a4,a4,a2
 a5c:	00ea3023          	sd	a4,0(s4)
      printf("[*] ultschedule (next tid: %d), time = %d\n", get_current_tid());
 a60:	434c                	lw	a1,4(a4)
 a62:	00000517          	auipc	a0,0x0
 a66:	55650513          	addi	a0,a0,1366 # fb8 <digits+0x38>
 a6a:	00000097          	auipc	ra,0x0
 a6e:	d0c080e7          	jalr	-756(ra) # 776 <printf>
      ulthread_context_switch(&temp->context, &current_thread->context);
 a72:	000a3583          	ld	a1,0(s4)
 a76:	05e1                	addi	a1,a1,24
 a78:	018c0513          	addi	a0,s8,24
 a7c:	00000097          	auipc	ra,0x0
 a80:	378080e7          	jalr	888(ra) # df4 <ulthread_context_switch>
      if (t->state == RUNNABLE && t != scheduler_thread && t->lastTime < oldest)
 a84:	000bb583          	ld	a1,0(s7)
    int alternativeIndex = -1;
 a88:	86d6                	mv	a3,s5
    int threadIndex = -1;
 a8a:	8856                	mv	a6,s5
    uint64 oldest = __INT64_MAX__;
 a8c:	865a                	mv	a2,s6
    bool threadAvailable = false;
 a8e:	4501                	li	a0,0
    for (t = ulthreads+1; t < &ulthreads[MAXULTHREADS]; t++)
 a90:	00065797          	auipc	a5,0x65
 a94:	62878793          	addi	a5,a5,1576 # 660b8 <ulthreads+0x88>
 a98:	bf59                	j	a2e <firstComeFirstServe+0x56>
    label : 
 a9a:	86c2                	mv	a3,a6
 a9c:	b765                	j	a44 <firstComeFirstServe+0x6c>
  }
}
 a9e:	60a6                	ld	ra,72(sp)
 aa0:	6406                	ld	s0,64(sp)
 aa2:	74e2                	ld	s1,56(sp)
 aa4:	7942                	ld	s2,48(sp)
 aa6:	79a2                	ld	s3,40(sp)
 aa8:	7a02                	ld	s4,32(sp)
 aaa:	6ae2                	ld	s5,24(sp)
 aac:	6b42                	ld	s6,16(sp)
 aae:	6ba2                	ld	s7,8(sp)
 ab0:	6c02                	ld	s8,0(sp)
 ab2:	6161                	addi	sp,sp,80
 ab4:	8082                	ret

0000000000000ab6 <priorityScheduling>:


void priorityScheduling(void)
{
 ab6:	715d                	addi	sp,sp,-80
 ab8:	e486                	sd	ra,72(sp)
 aba:	e0a2                	sd	s0,64(sp)
 abc:	fc26                	sd	s1,56(sp)
 abe:	f84a                	sd	s2,48(sp)
 ac0:	f44e                	sd	s3,40(sp)
 ac2:	f052                	sd	s4,32(sp)
 ac4:	ec56                	sd	s5,24(sp)
 ac6:	e85a                	sd	s6,16(sp)
 ac8:	e45e                	sd	s7,8(sp)
 aca:	0880                	addi	s0,sp,80
    int maxPriority = -1;
    int threadIndex = -1;
    int alternativeIndex = -1;
    for (t = ulthreads+1; t < &ulthreads[MAXULTHREADS]; t++)
    {
      if (t->state == RUNNABLE && t != scheduler_thread && t->priority > maxPriority)
 acc:	00001b17          	auipc	s6,0x1
 ad0:	544b0b13          	addi	s6,s6,1348 # 2010 <scheduler_thread>
    int alternativeIndex = -1;
 ad4:	5a7d                	li	s4,-1
      if (t->state == RUNNABLE && t != scheduler_thread && t->priority > maxPriority)
 ad6:	4485                	li	s1,1
        // flag = true;

        // break; // switch to highest-priority thread and exit loop
      }

      if (t->state == YIELD){
 ad8:	4989                	li	s3,2
    for (t = ulthreads+1; t < &ulthreads[MAXULTHREADS]; t++)
 ada:	00069917          	auipc	s2,0x69
 ade:	a7690913          	addi	s2,s2,-1418 # 69550 <ulthreads+0x3520>
        break;
      }
      
    }
    label : 
      struct ulthread *temp = current_thread;
 ae2:	00001a97          	auipc	s5,0x1
 ae6:	536a8a93          	addi	s5,s5,1334 # 2018 <current_thread>
 aea:	a88d                	j	b5c <priorityScheduling+0xa6>
      if (t->state == RUNNABLE && t != scheduler_thread && t->priority > maxPriority)
 aec:	00f58963          	beq	a1,a5,afe <priorityScheduling+0x48>
 af0:	47d8                	lw	a4,12(a5)
 af2:	00e65663          	bge	a2,a4,afe <priorityScheduling+0x48>
        threadIndex = t->tid;
 af6:	0047a803          	lw	a6,4(a5)
        maxPriority = t->priority;
 afa:	863a                	mv	a2,a4
        threadAvailable = true;
 afc:	8526                	mv	a0,s1
    for (t = ulthreads+1; t < &ulthreads[MAXULTHREADS]; t++)
 afe:	08878793          	addi	a5,a5,136
 b02:	01278a63          	beq	a5,s2,b16 <priorityScheduling+0x60>
      if (t->state == RUNNABLE && t != scheduler_thread && t->priority > maxPriority)
 b06:	4398                	lw	a4,0(a5)
 b08:	fe9702e3          	beq	a4,s1,aec <priorityScheduling+0x36>
      if (t->state == YIELD){
 b0c:	ff3719e3          	bne	a4,s3,afe <priorityScheduling+0x48>
        t->state = RUNNABLE;
 b10:	c384                	sw	s1,0(a5)
        alternativeIndex = t->tid;
 b12:	43d4                	lw	a3,4(a5)
 b14:	b7ed                	j	afe <priorityScheduling+0x48>
    if (!threadAvailable)
 b16:	ed31                	bnez	a0,b72 <priorityScheduling+0xbc>
      if(alternativeIndex > 0){
 b18:	04d05f63          	blez	a3,b76 <priorityScheduling+0xc0>
      struct ulthread *temp = current_thread;
 b1c:	000abb83          	ld	s7,0(s5)
      current_thread = &ulthreads[threadIndex];
 b20:	00469793          	slli	a5,a3,0x4
 b24:	00d78733          	add	a4,a5,a3
 b28:	070e                	slli	a4,a4,0x3
 b2a:	00065617          	auipc	a2,0x65
 b2e:	50660613          	addi	a2,a2,1286 # 66030 <ulthreads>
 b32:	9732                	add	a4,a4,a2
 b34:	00eab023          	sd	a4,0(s5)
      printf("[*] ultschedule (next tid: %d)\n", get_current_tid());
 b38:	434c                	lw	a1,4(a4)
 b3a:	00000517          	auipc	a0,0x0
 b3e:	45e50513          	addi	a0,a0,1118 # f98 <digits+0x18>
 b42:	00000097          	auipc	ra,0x0
 b46:	c34080e7          	jalr	-972(ra) # 776 <printf>
      ulthread_context_switch(&temp->context, &current_thread->context);
 b4a:	000ab583          	ld	a1,0(s5)
 b4e:	05e1                	addi	a1,a1,24
 b50:	018b8513          	addi	a0,s7,24
 b54:	00000097          	auipc	ra,0x0
 b58:	2a0080e7          	jalr	672(ra) # df4 <ulthread_context_switch>
      if (t->state == RUNNABLE && t != scheduler_thread && t->priority > maxPriority)
 b5c:	000b3583          	ld	a1,0(s6)
    int alternativeIndex = -1;
 b60:	86d2                	mv	a3,s4
    int threadIndex = -1;
 b62:	8852                	mv	a6,s4
    int maxPriority = -1;
 b64:	8652                	mv	a2,s4
    bool threadAvailable = false;
 b66:	4501                	li	a0,0
    for (t = ulthreads+1; t < &ulthreads[MAXULTHREADS]; t++)
 b68:	00065797          	auipc	a5,0x65
 b6c:	55078793          	addi	a5,a5,1360 # 660b8 <ulthreads+0x88>
 b70:	bf59                	j	b06 <priorityScheduling+0x50>
    label : 
 b72:	86c2                	mv	a3,a6
 b74:	b765                	j	b1c <priorityScheduling+0x66>
  }
}
 b76:	60a6                	ld	ra,72(sp)
 b78:	6406                	ld	s0,64(sp)
 b7a:	74e2                	ld	s1,56(sp)
 b7c:	7942                	ld	s2,48(sp)
 b7e:	79a2                	ld	s3,40(sp)
 b80:	7a02                	ld	s4,32(sp)
 b82:	6ae2                	ld	s5,24(sp)
 b84:	6b42                	ld	s6,16(sp)
 b86:	6ba2                	ld	s7,8(sp)
 b88:	6161                	addi	sp,sp,80
 b8a:	8082                	ret

0000000000000b8c <ulthread_init>:

/* Thread initialization */
void ulthread_init(int schedalgo)
{
 b8c:	1141                	addi	sp,sp,-16
 b8e:	e422                	sd	s0,8(sp)
 b90:	0800                	addi	s0,sp,16
  struct ulthread *t;
  int i;
  for (i = 0, t = ulthreads; t < &ulthreads[MAXULTHREADS]; t++, i++)
 b92:	4701                	li	a4,0
 b94:	00065797          	auipc	a5,0x65
 b98:	49c78793          	addi	a5,a5,1180 # 66030 <ulthreads>
 b9c:	00069697          	auipc	a3,0x69
 ba0:	9b468693          	addi	a3,a3,-1612 # 69550 <ulthreads+0x3520>
  {
    t->state = FREE;
 ba4:	0007a023          	sw	zero,0(a5)
    t->tid = i;
 ba8:	c3d8                	sw	a4,4(a5)
  for (i = 0, t = ulthreads; t < &ulthreads[MAXULTHREADS]; t++, i++)
 baa:	08878793          	addi	a5,a5,136
 bae:	2705                	addiw	a4,a4,1
 bb0:	fed79ae3          	bne	a5,a3,ba4 <ulthread_init+0x18>
  }
  current_thread = &ulthreads[0];
 bb4:	00065797          	auipc	a5,0x65
 bb8:	47c78793          	addi	a5,a5,1148 # 66030 <ulthreads>
 bbc:	00001717          	auipc	a4,0x1
 bc0:	44f73e23          	sd	a5,1116(a4) # 2018 <current_thread>
  scheduler_thread = &ulthreads[0];
 bc4:	00001717          	auipc	a4,0x1
 bc8:	44f73623          	sd	a5,1100(a4) # 2010 <scheduler_thread>
  scheduler_thread->state = RUNNABLE;
 bcc:	4705                	li	a4,1
 bce:	c398                	sw	a4,0(a5)
  t->state = FREE;
 bd0:	00069797          	auipc	a5,0x69
 bd4:	9807a023          	sw	zero,-1664(a5) # 69550 <ulthreads+0x3520>
  algorithm = schedalgo;
 bd8:	00001797          	auipc	a5,0x1
 bdc:	42a7a823          	sw	a0,1072(a5) # 2008 <algorithm>
}
 be0:	6422                	ld	s0,8(sp)
 be2:	0141                	addi	sp,sp,16
 be4:	8082                	ret

0000000000000be6 <ulthread_create>:

/* Thread creation */
bool ulthread_create(uint64 start, uint64 stack, uint64 args[], int priority)
{
 be6:	7179                	addi	sp,sp,-48
 be8:	f406                	sd	ra,40(sp)
 bea:	f022                	sd	s0,32(sp)
 bec:	ec26                	sd	s1,24(sp)
 bee:	e84a                	sd	s2,16(sp)
 bf0:	e44e                	sd	s3,8(sp)
 bf2:	e052                	sd	s4,0(sp)
 bf4:	1800                	addi	s0,sp,48
 bf6:	89aa                	mv	s3,a0
 bf8:	8a2e                	mv	s4,a1
 bfa:	8932                	mv	s2,a2
  /* Please add thread-id instead of '0' here. */
  struct ulthread *t;
  bool flag = false;
  for (t = ulthreads; t < &ulthreads[MAXULTHREADS]; t++)
 bfc:	00065497          	auipc	s1,0x65
 c00:	43448493          	addi	s1,s1,1076 # 66030 <ulthreads>
 c04:	00069717          	auipc	a4,0x69
 c08:	94c70713          	addi	a4,a4,-1716 # 69550 <ulthreads+0x3520>
  {
    if (t->state == FREE)
 c0c:	409c                	lw	a5,0(s1)
 c0e:	cf89                	beqz	a5,c28 <ulthread_create+0x42>
  for (t = ulthreads; t < &ulthreads[MAXULTHREADS]; t++)
 c10:	08848493          	addi	s1,s1,136
 c14:	fee49ce3          	bne	s1,a4,c0c <ulthread_create+0x26>
      break;
    }
  }
  if (!flag)
  {
    return false;
 c18:	4501                	li	a0,0
 c1a:	a871                	j	cb6 <ulthread_create+0xd0>
  t->sp = (int)(stack + USTACKSIZE); // set sp to the top of the stack
  t->state = RUNNABLE;
  t->priority = priority;

  if(algorithm==FCFS){
    t->lastTime = ctime();
 c1c:	00000097          	auipc	ra,0x0
 c20:	88a080e7          	jalr	-1910(ra) # 4a6 <ctime>
 c24:	e888                	sd	a0,16(s1)
 c26:	a839                	j	c44 <ulthread_create+0x5e>
  t->sp = (int)(stack + USTACKSIZE); // set sp to the top of the stack
 c28:	6785                	lui	a5,0x1
 c2a:	014787bb          	addw	a5,a5,s4
 c2e:	c49c                	sw	a5,8(s1)
  t->state = RUNNABLE;
 c30:	4785                	li	a5,1
 c32:	c09c                	sw	a5,0(s1)
  t->priority = priority;
 c34:	c4d4                	sw	a3,12(s1)
  if(algorithm==FCFS){
 c36:	00001717          	auipc	a4,0x1
 c3a:	3d272703          	lw	a4,978(a4) # 2008 <algorithm>
 c3e:	4789                	li	a5,2
 c40:	fcf70ee3          	beq	a4,a5,c1c <ulthread_create+0x36>
  }

  for (int argc = 0; argc < 6; argc++)
 c44:	874a                	mv	a4,s2
 c46:	03090693          	addi	a3,s2,48
  {
    t->sp -= 16;
 c4a:	449c                	lw	a5,8(s1)
 c4c:	37c1                	addiw	a5,a5,-16 # ff0 <digits+0x70>
 c4e:	0007881b          	sext.w	a6,a5
 c52:	c49c                	sw	a5,8(s1)
    *(uint64 *)(t->sp) = (uint64)args[argc];
 c54:	631c                	ld	a5,0(a4)
 c56:	00f83023          	sd	a5,0(a6)
  for (int argc = 0; argc < 6; argc++)
 c5a:	0721                	addi	a4,a4,8
 c5c:	fed717e3          	bne	a4,a3,c4a <ulthread_create+0x64>
  }

  memset(&t->context, 0, sizeof(t->context));
 c60:	07000613          	li	a2,112
 c64:	4581                	li	a1,0
 c66:	01848513          	addi	a0,s1,24
 c6a:	fffff097          	auipc	ra,0xfffff
 c6e:	5a2080e7          	jalr	1442(ra) # 20c <memset>
  t->context.ra = start;
 c72:	0134bc23          	sd	s3,24(s1)
  t->context.sp = t->sp;
 c76:	449c                	lw	a5,8(s1)
 c78:	f09c                	sd	a5,32(s1)
  t->context.s0 = args[0];
 c7a:	00093783          	ld	a5,0(s2)
 c7e:	f49c                	sd	a5,40(s1)
  t->context.s1 = args[1];
 c80:	00893783          	ld	a5,8(s2)
 c84:	f89c                	sd	a5,48(s1)
  t->context.s2 = args[2];
 c86:	01093783          	ld	a5,16(s2)
 c8a:	fc9c                	sd	a5,56(s1)
  t->context.s3 = args[3];
 c8c:	01893783          	ld	a5,24(s2)
 c90:	e0bc                	sd	a5,64(s1)
  t->context.s4 = args[4];
 c92:	02093783          	ld	a5,32(s2)
 c96:	e4bc                	sd	a5,72(s1)
  t->context.s5 = args[5];
 c98:	02893783          	ld	a5,40(s2)
 c9c:	e8bc                	sd	a5,80(s1)

  printf("[*] ultcreate(tid: %d, ra: %p, sp: %p)\n", t->tid, start, stack);
 c9e:	86d2                	mv	a3,s4
 ca0:	864e                	mv	a2,s3
 ca2:	40cc                	lw	a1,4(s1)
 ca4:	00000517          	auipc	a0,0x0
 ca8:	34450513          	addi	a0,a0,836 # fe8 <digits+0x68>
 cac:	00000097          	auipc	ra,0x0
 cb0:	aca080e7          	jalr	-1334(ra) # 776 <printf>
  return true;
 cb4:	4505                	li	a0,1
}
 cb6:	70a2                	ld	ra,40(sp)
 cb8:	7402                	ld	s0,32(sp)
 cba:	64e2                	ld	s1,24(sp)
 cbc:	6942                	ld	s2,16(sp)
 cbe:	69a2                	ld	s3,8(sp)
 cc0:	6a02                	ld	s4,0(sp)
 cc2:	6145                	addi	sp,sp,48
 cc4:	8082                	ret

0000000000000cc6 <ulthread_schedule>:

/* Thread scheduler */
void ulthread_schedule(void)
{
 cc6:	1141                	addi	sp,sp,-16
 cc8:	e406                	sd	ra,8(sp)
 cca:	e022                	sd	s0,0(sp)
 ccc:	0800                	addi	s0,sp,16
  switch (algorithm)
 cce:	00001797          	auipc	a5,0x1
 cd2:	33a7a783          	lw	a5,826(a5) # 2008 <algorithm>
 cd6:	4705                	li	a4,1
 cd8:	02e78463          	beq	a5,a4,d00 <ulthread_schedule+0x3a>
 cdc:	4709                	li	a4,2
 cde:	00e78c63          	beq	a5,a4,cf6 <ulthread_schedule+0x30>
 ce2:	c789                	beqz	a5,cec <ulthread_schedule+0x26>

  // Push argument strings, prepare rest of stack in ustack.

  // Switch between thread contexts
  // ulthread_context_switch(NULL, NULL);
}
 ce4:	60a2                	ld	ra,8(sp)
 ce6:	6402                	ld	s0,0(sp)
 ce8:	0141                	addi	sp,sp,16
 cea:	8082                	ret
    roundRobin();
 cec:	00000097          	auipc	ra,0x0
 cf0:	c3e080e7          	jalr	-962(ra) # 92a <roundRobin>
    break;
 cf4:	bfc5                	j	ce4 <ulthread_schedule+0x1e>
    firstComeFirstServe();
 cf6:	00000097          	auipc	ra,0x0
 cfa:	ce2080e7          	jalr	-798(ra) # 9d8 <firstComeFirstServe>
    break;
 cfe:	b7dd                	j	ce4 <ulthread_schedule+0x1e>
    priorityScheduling();
 d00:	00000097          	auipc	ra,0x0
 d04:	db6080e7          	jalr	-586(ra) # ab6 <priorityScheduling>
}
 d08:	bff1                	j	ce4 <ulthread_schedule+0x1e>

0000000000000d0a <ulthread_yield>:

/* Yield CPU time to some other thread. */
void ulthread_yield(void)
{
 d0a:	1101                	addi	sp,sp,-32
 d0c:	ec06                	sd	ra,24(sp)
 d0e:	e822                	sd	s0,16(sp)
 d10:	e426                	sd	s1,8(sp)
 d12:	e04a                	sd	s2,0(sp)
 d14:	1000                	addi	s0,sp,32
  current_thread->state = YIELD;
 d16:	00001797          	auipc	a5,0x1
 d1a:	30278793          	addi	a5,a5,770 # 2018 <current_thread>
 d1e:	6398                	ld	a4,0(a5)
 d20:	4909                	li	s2,2
 d22:	01272023          	sw	s2,0(a4)
  struct ulthread *temp = current_thread;
 d26:	6384                	ld	s1,0(a5)
  printf("[*] ultyield(tid: %d)\n", current_thread->tid);
 d28:	40cc                	lw	a1,4(s1)
 d2a:	00000517          	auipc	a0,0x0
 d2e:	2e650513          	addi	a0,a0,742 # 1010 <digits+0x90>
 d32:	00000097          	auipc	ra,0x0
 d36:	a44080e7          	jalr	-1468(ra) # 776 <printf>
  if(algorithm==FCFS){
 d3a:	00001797          	auipc	a5,0x1
 d3e:	2ce7a783          	lw	a5,718(a5) # 2008 <algorithm>
 d42:	03278763          	beq	a5,s2,d70 <ulthread_yield+0x66>
    current_thread->lastTime = ctime();
  }
  current_thread = scheduler_thread;
 d46:	00001597          	auipc	a1,0x1
 d4a:	2ca5b583          	ld	a1,714(a1) # 2010 <scheduler_thread>
 d4e:	00001797          	auipc	a5,0x1
 d52:	2cb7b523          	sd	a1,714(a5) # 2018 <current_thread>
  
  ulthread_context_switch(&temp->context, &scheduler_thread->context);
 d56:	05e1                	addi	a1,a1,24
 d58:	01848513          	addi	a0,s1,24
 d5c:	00000097          	auipc	ra,0x0
 d60:	098080e7          	jalr	152(ra) # df4 <ulthread_context_switch>
  // ulthread_schedule();
}
 d64:	60e2                	ld	ra,24(sp)
 d66:	6442                	ld	s0,16(sp)
 d68:	64a2                	ld	s1,8(sp)
 d6a:	6902                	ld	s2,0(sp)
 d6c:	6105                	addi	sp,sp,32
 d6e:	8082                	ret
    current_thread->lastTime = ctime();
 d70:	fffff097          	auipc	ra,0xfffff
 d74:	736080e7          	jalr	1846(ra) # 4a6 <ctime>
 d78:	00001797          	auipc	a5,0x1
 d7c:	2a07b783          	ld	a5,672(a5) # 2018 <current_thread>
 d80:	eb88                	sd	a0,16(a5)
 d82:	b7d1                	j	d46 <ulthread_yield+0x3c>

0000000000000d84 <ulthread_destroy>:

/* Destroy thread */
void ulthread_destroy(void)
{
 d84:	1101                	addi	sp,sp,-32
 d86:	ec06                	sd	ra,24(sp)
 d88:	e822                	sd	s0,16(sp)
 d8a:	e426                	sd	s1,8(sp)
 d8c:	e04a                	sd	s2,0(sp)
 d8e:	1000                	addi	s0,sp,32
  memset(&current_thread->context, 0, sizeof(current_thread->context));
 d90:	00001497          	auipc	s1,0x1
 d94:	28848493          	addi	s1,s1,648 # 2018 <current_thread>
 d98:	6088                	ld	a0,0(s1)
 d9a:	07000613          	li	a2,112
 d9e:	4581                	li	a1,0
 da0:	0561                	addi	a0,a0,24
 da2:	fffff097          	auipc	ra,0xfffff
 da6:	46a080e7          	jalr	1130(ra) # 20c <memset>
  current_thread->sp = 0;
 daa:	609c                	ld	a5,0(s1)
 dac:	0007a423          	sw	zero,8(a5)
  current_thread->priority = -1;
 db0:	577d                	li	a4,-1
 db2:	c7d8                	sw	a4,12(a5)
  current_thread->state = FREE;
 db4:	0007a023          	sw	zero,0(a5)

  struct ulthread *temp = current_thread;
 db8:	0004b903          	ld	s2,0(s1)

  printf("[*] ultdestroy(tid: %d)\n", get_current_tid());
 dbc:	00492583          	lw	a1,4(s2)
 dc0:	00000517          	auipc	a0,0x0
 dc4:	26850513          	addi	a0,a0,616 # 1028 <digits+0xa8>
 dc8:	00000097          	auipc	ra,0x0
 dcc:	9ae080e7          	jalr	-1618(ra) # 776 <printf>
  current_thread = scheduler_thread;
 dd0:	00001597          	auipc	a1,0x1
 dd4:	2405b583          	ld	a1,576(a1) # 2010 <scheduler_thread>
 dd8:	e08c                	sd	a1,0(s1)
  ulthread_context_switch(&temp->context, &scheduler_thread->context);
 dda:	05e1                	addi	a1,a1,24
 ddc:	01890513          	addi	a0,s2,24
 de0:	00000097          	auipc	ra,0x0
 de4:	014080e7          	jalr	20(ra) # df4 <ulthread_context_switch>
}
 de8:	60e2                	ld	ra,24(sp)
 dea:	6442                	ld	s0,16(sp)
 dec:	64a2                	ld	s1,8(sp)
 dee:	6902                	ld	s2,0(sp)
 df0:	6105                	addi	sp,sp,32
 df2:	8082                	ret

0000000000000df4 <ulthread_context_switch>:
 df4:	00153023          	sd	ra,0(a0)
 df8:	00253423          	sd	sp,8(a0)
 dfc:	e900                	sd	s0,16(a0)
 dfe:	ed04                	sd	s1,24(a0)
 e00:	03253023          	sd	s2,32(a0)
 e04:	03353423          	sd	s3,40(a0)
 e08:	03453823          	sd	s4,48(a0)
 e0c:	03553c23          	sd	s5,56(a0)
 e10:	05653023          	sd	s6,64(a0)
 e14:	05753423          	sd	s7,72(a0)
 e18:	05853823          	sd	s8,80(a0)
 e1c:	05953c23          	sd	s9,88(a0)
 e20:	07a53023          	sd	s10,96(a0)
 e24:	07b53423          	sd	s11,104(a0)
 e28:	0005b083          	ld	ra,0(a1)
 e2c:	0085b103          	ld	sp,8(a1)
 e30:	6980                	ld	s0,16(a1)
 e32:	6d84                	ld	s1,24(a1)
 e34:	0205b903          	ld	s2,32(a1)
 e38:	0285b983          	ld	s3,40(a1)
 e3c:	0305ba03          	ld	s4,48(a1)
 e40:	0385ba83          	ld	s5,56(a1)
 e44:	0405bb03          	ld	s6,64(a1)
 e48:	0485bb83          	ld	s7,72(a1)
 e4c:	0505bc03          	ld	s8,80(a1)
 e50:	0585bc83          	ld	s9,88(a1)
 e54:	0605bd03          	ld	s10,96(a1)
 e58:	0685bd83          	ld	s11,104(a1)
 e5c:	6546                	ld	a0,80(sp)
 e5e:	6586                	ld	a1,64(sp)
 e60:	7642                	ld	a2,48(sp)
 e62:	7682                	ld	a3,32(sp)
 e64:	6742                	ld	a4,16(sp)
 e66:	6782                	ld	a5,0(sp)
 e68:	8082                	ret
