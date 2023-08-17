
user/_test8:     file format elf64-littleriscv


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
  18:	8ee080e7          	jalr	-1810(ra) # 902 <get_current_tid>
  1c:	85aa                	mv	a1,a0
  1e:	8626                	mv	a2,s1
  20:	00001517          	auipc	a0,0x1
  24:	e4050513          	addi	a0,a0,-448 # e60 <ulthread_context_switch+0x7e>
  28:	00000097          	auipc	ra,0x0
  2c:	73c080e7          	jalr	1852(ra) # 764 <printf>
    return ctime();
  30:	00000097          	auipc	ra,0x0
  34:	464080e7          	jalr	1124(ra) # 494 <ctime>
  38:	8a2a                	mv	s4,a0
        get_current_tid(), a1);

    uint64 start_time = get_current_time();
    uint64 prev_time = start_time;
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
  64:	434080e7          	jalr	1076(ra) # 494 <ctime>
            if ((d - prev_time) > 10000) { 
  68:	414507b3          	sub	a5,a0,s4
  6c:	fefaf4e3          	bgeu	s5,a5,54 <ul_start_func+0x54>
                ulthread_yield();
  70:	00001097          	auipc	ra,0x1
  74:	c88080e7          	jalr	-888(ra) # cf8 <ulthread_yield>
    return ctime();
  78:	00000097          	auipc	ra,0x0
  7c:	41c080e7          	jalr	1052(ra) # 494 <ctime>
  80:	8a2a                	mv	s4,a0
  82:	bfc9                	j	54 <ul_start_func+0x54>
                prev_time = get_current_time();
            }
        }
    }
    /* Notify for a thread exit. */
    ulthread_destroy();
  84:	00001097          	auipc	ra,0x1
  88:	cee080e7          	jalr	-786(ra) # d72 <ulthread_destroy>
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
  aa:	3ee080e7          	jalr	1006(ra) # 494 <ctime>
}
  ae:	60a2                	ld	ra,8(sp)
  b0:	6402                	ld	s0,0(sp)
  b2:	0141                	addi	sp,sp,16
  b4:	8082                	ret

00000000000000b6 <main>:

int
main(int argc, char *argv[])
{
  b6:	711d                	addi	sp,sp,-96
  b8:	ec86                	sd	ra,88(sp)
  ba:	e8a2                	sd	s0,80(sp)
  bc:	e4a6                	sd	s1,72(sp)
  be:	e0ca                	sd	s2,64(sp)
  c0:	fc4e                	sd	s3,56(sp)
  c2:	f852                	sd	s4,48(sp)
  c4:	1080                	addi	s0,sp,96
    /* Clear the stack region */
    memset(&stacks, 0, sizeof(stacks));
  c6:	00064637          	lui	a2,0x64
  ca:	4581                	li	a1,0
  cc:	00002517          	auipc	a0,0x2
  d0:	f5450513          	addi	a0,a0,-172 # 2020 <stacks>
  d4:	00000097          	auipc	ra,0x0
  d8:	126080e7          	jalr	294(ra) # 1fa <memset>

    /* Initialize the user-level threading library */
    ulthread_init(FCFS);
  dc:	4509                	li	a0,2
  de:	00001097          	auipc	ra,0x1
  e2:	a9c080e7          	jalr	-1380(ra) # b7a <ulthread_init>

    /* Create a user-level thread */
    uint64 args[6] = {1,1,1,1,0,0};
  e6:	00001797          	auipc	a5,0x1
  ea:	dfa78793          	addi	a5,a5,-518 # ee0 <ulthread_context_switch+0xfe>
  ee:	6388                	ld	a0,0(a5)
  f0:	678c                	ld	a1,8(a5)
  f2:	6b90                	ld	a2,16(a5)
  f4:	6f94                	ld	a3,24(a5)
  f6:	7398                	ld	a4,32(a5)
  f8:	779c                	ld	a5,40(a5)
  fa:	faa43023          	sd	a0,-96(s0)
  fe:	fab43423          	sd	a1,-88(s0)
 102:	fac43823          	sd	a2,-80(s0)
 106:	fad43c23          	sd	a3,-72(s0)
 10a:	fce43023          	sd	a4,-64(s0)
 10e:	fcf43423          	sd	a5,-56(s0)
    for (int i = 0; i < 3; i++)
 112:	00003497          	auipc	s1,0x3
 116:	f0e48493          	addi	s1,s1,-242 # 3020 <stacks+0x1000>
 11a:	00006a17          	auipc	s4,0x6
 11e:	f06a0a13          	addi	s4,s4,-250 # 6020 <stacks+0x4000>
        ulthread_create((uint64) ul_start_func, (uint64) (stacks+((i+1)*PGSIZE)), args, -1);
 122:	00000997          	auipc	s3,0x0
 126:	ede98993          	addi	s3,s3,-290 # 0 <ul_start_func>
    for (int i = 0; i < 3; i++)
 12a:	6905                	lui	s2,0x1
        ulthread_create((uint64) ul_start_func, (uint64) (stacks+((i+1)*PGSIZE)), args, -1);
 12c:	56fd                	li	a3,-1
 12e:	fa040613          	addi	a2,s0,-96
 132:	85a6                	mv	a1,s1
 134:	854e                	mv	a0,s3
 136:	00001097          	auipc	ra,0x1
 13a:	a9e080e7          	jalr	-1378(ra) # bd4 <ulthread_create>
    for (int i = 0; i < 3; i++)
 13e:	94ca                	add	s1,s1,s2
 140:	ff4496e3          	bne	s1,s4,12c <main+0x76>

    /* Schedule all of the threads */
    ulthread_schedule();
 144:	00001097          	auipc	ra,0x1
 148:	b70080e7          	jalr	-1168(ra) # cb4 <ulthread_schedule>

    printf("[*] User-Level Threading Test #8 (FCFS Collaborative) Complete.\n");
 14c:	00001517          	auipc	a0,0x1
 150:	d4c50513          	addi	a0,a0,-692 # e98 <ulthread_context_switch+0xb6>
 154:	00000097          	auipc	ra,0x0
 158:	610080e7          	jalr	1552(ra) # 764 <printf>
    return 0;
}
 15c:	4501                	li	a0,0
 15e:	60e6                	ld	ra,88(sp)
 160:	6446                	ld	s0,80(sp)
 162:	64a6                	ld	s1,72(sp)
 164:	6906                	ld	s2,64(sp)
 166:	79e2                	ld	s3,56(sp)
 168:	7a42                	ld	s4,48(sp)
 16a:	6125                	addi	sp,sp,96
 16c:	8082                	ret

000000000000016e <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
 16e:	1141                	addi	sp,sp,-16
 170:	e406                	sd	ra,8(sp)
 172:	e022                	sd	s0,0(sp)
 174:	0800                	addi	s0,sp,16
  extern int main();
  main();
 176:	00000097          	auipc	ra,0x0
 17a:	f40080e7          	jalr	-192(ra) # b6 <main>
  exit(0);
 17e:	4501                	li	a0,0
 180:	00000097          	auipc	ra,0x0
 184:	274080e7          	jalr	628(ra) # 3f4 <exit>

0000000000000188 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 188:	1141                	addi	sp,sp,-16
 18a:	e422                	sd	s0,8(sp)
 18c:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 18e:	87aa                	mv	a5,a0
 190:	0585                	addi	a1,a1,1
 192:	0785                	addi	a5,a5,1
 194:	fff5c703          	lbu	a4,-1(a1)
 198:	fee78fa3          	sb	a4,-1(a5)
 19c:	fb75                	bnez	a4,190 <strcpy+0x8>
    ;
  return os;
}
 19e:	6422                	ld	s0,8(sp)
 1a0:	0141                	addi	sp,sp,16
 1a2:	8082                	ret

00000000000001a4 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 1a4:	1141                	addi	sp,sp,-16
 1a6:	e422                	sd	s0,8(sp)
 1a8:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 1aa:	00054783          	lbu	a5,0(a0)
 1ae:	cb91                	beqz	a5,1c2 <strcmp+0x1e>
 1b0:	0005c703          	lbu	a4,0(a1)
 1b4:	00f71763          	bne	a4,a5,1c2 <strcmp+0x1e>
    p++, q++;
 1b8:	0505                	addi	a0,a0,1
 1ba:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 1bc:	00054783          	lbu	a5,0(a0)
 1c0:	fbe5                	bnez	a5,1b0 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 1c2:	0005c503          	lbu	a0,0(a1)
}
 1c6:	40a7853b          	subw	a0,a5,a0
 1ca:	6422                	ld	s0,8(sp)
 1cc:	0141                	addi	sp,sp,16
 1ce:	8082                	ret

00000000000001d0 <strlen>:

uint
strlen(const char *s)
{
 1d0:	1141                	addi	sp,sp,-16
 1d2:	e422                	sd	s0,8(sp)
 1d4:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 1d6:	00054783          	lbu	a5,0(a0)
 1da:	cf91                	beqz	a5,1f6 <strlen+0x26>
 1dc:	0505                	addi	a0,a0,1
 1de:	87aa                	mv	a5,a0
 1e0:	86be                	mv	a3,a5
 1e2:	0785                	addi	a5,a5,1
 1e4:	fff7c703          	lbu	a4,-1(a5)
 1e8:	ff65                	bnez	a4,1e0 <strlen+0x10>
 1ea:	40a6853b          	subw	a0,a3,a0
 1ee:	2505                	addiw	a0,a0,1
    ;
  return n;
}
 1f0:	6422                	ld	s0,8(sp)
 1f2:	0141                	addi	sp,sp,16
 1f4:	8082                	ret
  for(n = 0; s[n]; n++)
 1f6:	4501                	li	a0,0
 1f8:	bfe5                	j	1f0 <strlen+0x20>

00000000000001fa <memset>:

void*
memset(void *dst, int c, uint n)
{
 1fa:	1141                	addi	sp,sp,-16
 1fc:	e422                	sd	s0,8(sp)
 1fe:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 200:	ca19                	beqz	a2,216 <memset+0x1c>
 202:	87aa                	mv	a5,a0
 204:	1602                	slli	a2,a2,0x20
 206:	9201                	srli	a2,a2,0x20
 208:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 20c:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 210:	0785                	addi	a5,a5,1
 212:	fee79de3          	bne	a5,a4,20c <memset+0x12>
  }
  return dst;
}
 216:	6422                	ld	s0,8(sp)
 218:	0141                	addi	sp,sp,16
 21a:	8082                	ret

000000000000021c <strchr>:

char*
strchr(const char *s, char c)
{
 21c:	1141                	addi	sp,sp,-16
 21e:	e422                	sd	s0,8(sp)
 220:	0800                	addi	s0,sp,16
  for(; *s; s++)
 222:	00054783          	lbu	a5,0(a0)
 226:	cb99                	beqz	a5,23c <strchr+0x20>
    if(*s == c)
 228:	00f58763          	beq	a1,a5,236 <strchr+0x1a>
  for(; *s; s++)
 22c:	0505                	addi	a0,a0,1
 22e:	00054783          	lbu	a5,0(a0)
 232:	fbfd                	bnez	a5,228 <strchr+0xc>
      return (char*)s;
  return 0;
 234:	4501                	li	a0,0
}
 236:	6422                	ld	s0,8(sp)
 238:	0141                	addi	sp,sp,16
 23a:	8082                	ret
  return 0;
 23c:	4501                	li	a0,0
 23e:	bfe5                	j	236 <strchr+0x1a>

0000000000000240 <gets>:

char*
gets(char *buf, int max)
{
 240:	711d                	addi	sp,sp,-96
 242:	ec86                	sd	ra,88(sp)
 244:	e8a2                	sd	s0,80(sp)
 246:	e4a6                	sd	s1,72(sp)
 248:	e0ca                	sd	s2,64(sp)
 24a:	fc4e                	sd	s3,56(sp)
 24c:	f852                	sd	s4,48(sp)
 24e:	f456                	sd	s5,40(sp)
 250:	f05a                	sd	s6,32(sp)
 252:	ec5e                	sd	s7,24(sp)
 254:	1080                	addi	s0,sp,96
 256:	8baa                	mv	s7,a0
 258:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 25a:	892a                	mv	s2,a0
 25c:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 25e:	4aa9                	li	s5,10
 260:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 262:	89a6                	mv	s3,s1
 264:	2485                	addiw	s1,s1,1
 266:	0344d863          	bge	s1,s4,296 <gets+0x56>
    cc = read(0, &c, 1);
 26a:	4605                	li	a2,1
 26c:	faf40593          	addi	a1,s0,-81
 270:	4501                	li	a0,0
 272:	00000097          	auipc	ra,0x0
 276:	19a080e7          	jalr	410(ra) # 40c <read>
    if(cc < 1)
 27a:	00a05e63          	blez	a0,296 <gets+0x56>
    buf[i++] = c;
 27e:	faf44783          	lbu	a5,-81(s0)
 282:	00f90023          	sb	a5,0(s2) # 1000 <digits+0x90>
    if(c == '\n' || c == '\r')
 286:	01578763          	beq	a5,s5,294 <gets+0x54>
 28a:	0905                	addi	s2,s2,1
 28c:	fd679be3          	bne	a5,s6,262 <gets+0x22>
  for(i=0; i+1 < max; ){
 290:	89a6                	mv	s3,s1
 292:	a011                	j	296 <gets+0x56>
 294:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 296:	99de                	add	s3,s3,s7
 298:	00098023          	sb	zero,0(s3)
  return buf;
}
 29c:	855e                	mv	a0,s7
 29e:	60e6                	ld	ra,88(sp)
 2a0:	6446                	ld	s0,80(sp)
 2a2:	64a6                	ld	s1,72(sp)
 2a4:	6906                	ld	s2,64(sp)
 2a6:	79e2                	ld	s3,56(sp)
 2a8:	7a42                	ld	s4,48(sp)
 2aa:	7aa2                	ld	s5,40(sp)
 2ac:	7b02                	ld	s6,32(sp)
 2ae:	6be2                	ld	s7,24(sp)
 2b0:	6125                	addi	sp,sp,96
 2b2:	8082                	ret

00000000000002b4 <stat>:

int
stat(const char *n, struct stat *st)
{
 2b4:	1101                	addi	sp,sp,-32
 2b6:	ec06                	sd	ra,24(sp)
 2b8:	e822                	sd	s0,16(sp)
 2ba:	e426                	sd	s1,8(sp)
 2bc:	e04a                	sd	s2,0(sp)
 2be:	1000                	addi	s0,sp,32
 2c0:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 2c2:	4581                	li	a1,0
 2c4:	00000097          	auipc	ra,0x0
 2c8:	170080e7          	jalr	368(ra) # 434 <open>
  if(fd < 0)
 2cc:	02054563          	bltz	a0,2f6 <stat+0x42>
 2d0:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 2d2:	85ca                	mv	a1,s2
 2d4:	00000097          	auipc	ra,0x0
 2d8:	178080e7          	jalr	376(ra) # 44c <fstat>
 2dc:	892a                	mv	s2,a0
  close(fd);
 2de:	8526                	mv	a0,s1
 2e0:	00000097          	auipc	ra,0x0
 2e4:	13c080e7          	jalr	316(ra) # 41c <close>
  return r;
}
 2e8:	854a                	mv	a0,s2
 2ea:	60e2                	ld	ra,24(sp)
 2ec:	6442                	ld	s0,16(sp)
 2ee:	64a2                	ld	s1,8(sp)
 2f0:	6902                	ld	s2,0(sp)
 2f2:	6105                	addi	sp,sp,32
 2f4:	8082                	ret
    return -1;
 2f6:	597d                	li	s2,-1
 2f8:	bfc5                	j	2e8 <stat+0x34>

00000000000002fa <atoi>:

int
atoi(const char *s)
{
 2fa:	1141                	addi	sp,sp,-16
 2fc:	e422                	sd	s0,8(sp)
 2fe:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 300:	00054683          	lbu	a3,0(a0)
 304:	fd06879b          	addiw	a5,a3,-48
 308:	0ff7f793          	zext.b	a5,a5
 30c:	4625                	li	a2,9
 30e:	02f66863          	bltu	a2,a5,33e <atoi+0x44>
 312:	872a                	mv	a4,a0
  n = 0;
 314:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 316:	0705                	addi	a4,a4,1
 318:	0025179b          	slliw	a5,a0,0x2
 31c:	9fa9                	addw	a5,a5,a0
 31e:	0017979b          	slliw	a5,a5,0x1
 322:	9fb5                	addw	a5,a5,a3
 324:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 328:	00074683          	lbu	a3,0(a4)
 32c:	fd06879b          	addiw	a5,a3,-48
 330:	0ff7f793          	zext.b	a5,a5
 334:	fef671e3          	bgeu	a2,a5,316 <atoi+0x1c>
  return n;
}
 338:	6422                	ld	s0,8(sp)
 33a:	0141                	addi	sp,sp,16
 33c:	8082                	ret
  n = 0;
 33e:	4501                	li	a0,0
 340:	bfe5                	j	338 <atoi+0x3e>

0000000000000342 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 342:	1141                	addi	sp,sp,-16
 344:	e422                	sd	s0,8(sp)
 346:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 348:	02b57463          	bgeu	a0,a1,370 <memmove+0x2e>
    while(n-- > 0)
 34c:	00c05f63          	blez	a2,36a <memmove+0x28>
 350:	1602                	slli	a2,a2,0x20
 352:	9201                	srli	a2,a2,0x20
 354:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 358:	872a                	mv	a4,a0
      *dst++ = *src++;
 35a:	0585                	addi	a1,a1,1
 35c:	0705                	addi	a4,a4,1
 35e:	fff5c683          	lbu	a3,-1(a1)
 362:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 366:	fee79ae3          	bne	a5,a4,35a <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 36a:	6422                	ld	s0,8(sp)
 36c:	0141                	addi	sp,sp,16
 36e:	8082                	ret
    dst += n;
 370:	00c50733          	add	a4,a0,a2
    src += n;
 374:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 376:	fec05ae3          	blez	a2,36a <memmove+0x28>
 37a:	fff6079b          	addiw	a5,a2,-1 # 63fff <stacks+0x61fdf>
 37e:	1782                	slli	a5,a5,0x20
 380:	9381                	srli	a5,a5,0x20
 382:	fff7c793          	not	a5,a5
 386:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 388:	15fd                	addi	a1,a1,-1
 38a:	177d                	addi	a4,a4,-1
 38c:	0005c683          	lbu	a3,0(a1)
 390:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 394:	fee79ae3          	bne	a5,a4,388 <memmove+0x46>
 398:	bfc9                	j	36a <memmove+0x28>

000000000000039a <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 39a:	1141                	addi	sp,sp,-16
 39c:	e422                	sd	s0,8(sp)
 39e:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 3a0:	ca05                	beqz	a2,3d0 <memcmp+0x36>
 3a2:	fff6069b          	addiw	a3,a2,-1
 3a6:	1682                	slli	a3,a3,0x20
 3a8:	9281                	srli	a3,a3,0x20
 3aa:	0685                	addi	a3,a3,1
 3ac:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 3ae:	00054783          	lbu	a5,0(a0)
 3b2:	0005c703          	lbu	a4,0(a1)
 3b6:	00e79863          	bne	a5,a4,3c6 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 3ba:	0505                	addi	a0,a0,1
    p2++;
 3bc:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 3be:	fed518e3          	bne	a0,a3,3ae <memcmp+0x14>
  }
  return 0;
 3c2:	4501                	li	a0,0
 3c4:	a019                	j	3ca <memcmp+0x30>
      return *p1 - *p2;
 3c6:	40e7853b          	subw	a0,a5,a4
}
 3ca:	6422                	ld	s0,8(sp)
 3cc:	0141                	addi	sp,sp,16
 3ce:	8082                	ret
  return 0;
 3d0:	4501                	li	a0,0
 3d2:	bfe5                	j	3ca <memcmp+0x30>

00000000000003d4 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 3d4:	1141                	addi	sp,sp,-16
 3d6:	e406                	sd	ra,8(sp)
 3d8:	e022                	sd	s0,0(sp)
 3da:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 3dc:	00000097          	auipc	ra,0x0
 3e0:	f66080e7          	jalr	-154(ra) # 342 <memmove>
}
 3e4:	60a2                	ld	ra,8(sp)
 3e6:	6402                	ld	s0,0(sp)
 3e8:	0141                	addi	sp,sp,16
 3ea:	8082                	ret

00000000000003ec <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 3ec:	4885                	li	a7,1
 ecall
 3ee:	00000073          	ecall
 ret
 3f2:	8082                	ret

00000000000003f4 <exit>:
.global exit
exit:
 li a7, SYS_exit
 3f4:	4889                	li	a7,2
 ecall
 3f6:	00000073          	ecall
 ret
 3fa:	8082                	ret

00000000000003fc <wait>:
.global wait
wait:
 li a7, SYS_wait
 3fc:	488d                	li	a7,3
 ecall
 3fe:	00000073          	ecall
 ret
 402:	8082                	ret

0000000000000404 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 404:	4891                	li	a7,4
 ecall
 406:	00000073          	ecall
 ret
 40a:	8082                	ret

000000000000040c <read>:
.global read
read:
 li a7, SYS_read
 40c:	4895                	li	a7,5
 ecall
 40e:	00000073          	ecall
 ret
 412:	8082                	ret

0000000000000414 <write>:
.global write
write:
 li a7, SYS_write
 414:	48c1                	li	a7,16
 ecall
 416:	00000073          	ecall
 ret
 41a:	8082                	ret

000000000000041c <close>:
.global close
close:
 li a7, SYS_close
 41c:	48d5                	li	a7,21
 ecall
 41e:	00000073          	ecall
 ret
 422:	8082                	ret

0000000000000424 <kill>:
.global kill
kill:
 li a7, SYS_kill
 424:	4899                	li	a7,6
 ecall
 426:	00000073          	ecall
 ret
 42a:	8082                	ret

000000000000042c <exec>:
.global exec
exec:
 li a7, SYS_exec
 42c:	489d                	li	a7,7
 ecall
 42e:	00000073          	ecall
 ret
 432:	8082                	ret

0000000000000434 <open>:
.global open
open:
 li a7, SYS_open
 434:	48bd                	li	a7,15
 ecall
 436:	00000073          	ecall
 ret
 43a:	8082                	ret

000000000000043c <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 43c:	48c5                	li	a7,17
 ecall
 43e:	00000073          	ecall
 ret
 442:	8082                	ret

0000000000000444 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 444:	48c9                	li	a7,18
 ecall
 446:	00000073          	ecall
 ret
 44a:	8082                	ret

000000000000044c <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 44c:	48a1                	li	a7,8
 ecall
 44e:	00000073          	ecall
 ret
 452:	8082                	ret

0000000000000454 <link>:
.global link
link:
 li a7, SYS_link
 454:	48cd                	li	a7,19
 ecall
 456:	00000073          	ecall
 ret
 45a:	8082                	ret

000000000000045c <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 45c:	48d1                	li	a7,20
 ecall
 45e:	00000073          	ecall
 ret
 462:	8082                	ret

0000000000000464 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 464:	48a5                	li	a7,9
 ecall
 466:	00000073          	ecall
 ret
 46a:	8082                	ret

000000000000046c <dup>:
.global dup
dup:
 li a7, SYS_dup
 46c:	48a9                	li	a7,10
 ecall
 46e:	00000073          	ecall
 ret
 472:	8082                	ret

0000000000000474 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 474:	48ad                	li	a7,11
 ecall
 476:	00000073          	ecall
 ret
 47a:	8082                	ret

000000000000047c <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 47c:	48b1                	li	a7,12
 ecall
 47e:	00000073          	ecall
 ret
 482:	8082                	ret

0000000000000484 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 484:	48b5                	li	a7,13
 ecall
 486:	00000073          	ecall
 ret
 48a:	8082                	ret

000000000000048c <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 48c:	48b9                	li	a7,14
 ecall
 48e:	00000073          	ecall
 ret
 492:	8082                	ret

0000000000000494 <ctime>:
.global ctime
ctime:
 li a7, SYS_ctime
 494:	48d9                	li	a7,22
 ecall
 496:	00000073          	ecall
 ret
 49a:	8082                	ret

000000000000049c <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 49c:	1101                	addi	sp,sp,-32
 49e:	ec06                	sd	ra,24(sp)
 4a0:	e822                	sd	s0,16(sp)
 4a2:	1000                	addi	s0,sp,32
 4a4:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 4a8:	4605                	li	a2,1
 4aa:	fef40593          	addi	a1,s0,-17
 4ae:	00000097          	auipc	ra,0x0
 4b2:	f66080e7          	jalr	-154(ra) # 414 <write>
}
 4b6:	60e2                	ld	ra,24(sp)
 4b8:	6442                	ld	s0,16(sp)
 4ba:	6105                	addi	sp,sp,32
 4bc:	8082                	ret

00000000000004be <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 4be:	7139                	addi	sp,sp,-64
 4c0:	fc06                	sd	ra,56(sp)
 4c2:	f822                	sd	s0,48(sp)
 4c4:	f426                	sd	s1,40(sp)
 4c6:	f04a                	sd	s2,32(sp)
 4c8:	ec4e                	sd	s3,24(sp)
 4ca:	0080                	addi	s0,sp,64
 4cc:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 4ce:	c299                	beqz	a3,4d4 <printint+0x16>
 4d0:	0805c963          	bltz	a1,562 <printint+0xa4>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 4d4:	2581                	sext.w	a1,a1
  neg = 0;
 4d6:	4881                	li	a7,0
 4d8:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 4dc:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 4de:	2601                	sext.w	a2,a2
 4e0:	00001517          	auipc	a0,0x1
 4e4:	a9050513          	addi	a0,a0,-1392 # f70 <digits>
 4e8:	883a                	mv	a6,a4
 4ea:	2705                	addiw	a4,a4,1
 4ec:	02c5f7bb          	remuw	a5,a1,a2
 4f0:	1782                	slli	a5,a5,0x20
 4f2:	9381                	srli	a5,a5,0x20
 4f4:	97aa                	add	a5,a5,a0
 4f6:	0007c783          	lbu	a5,0(a5)
 4fa:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 4fe:	0005879b          	sext.w	a5,a1
 502:	02c5d5bb          	divuw	a1,a1,a2
 506:	0685                	addi	a3,a3,1
 508:	fec7f0e3          	bgeu	a5,a2,4e8 <printint+0x2a>
  if(neg)
 50c:	00088c63          	beqz	a7,524 <printint+0x66>
    buf[i++] = '-';
 510:	fd070793          	addi	a5,a4,-48
 514:	00878733          	add	a4,a5,s0
 518:	02d00793          	li	a5,45
 51c:	fef70823          	sb	a5,-16(a4)
 520:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 524:	02e05863          	blez	a4,554 <printint+0x96>
 528:	fc040793          	addi	a5,s0,-64
 52c:	00e78933          	add	s2,a5,a4
 530:	fff78993          	addi	s3,a5,-1
 534:	99ba                	add	s3,s3,a4
 536:	377d                	addiw	a4,a4,-1
 538:	1702                	slli	a4,a4,0x20
 53a:	9301                	srli	a4,a4,0x20
 53c:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 540:	fff94583          	lbu	a1,-1(s2)
 544:	8526                	mv	a0,s1
 546:	00000097          	auipc	ra,0x0
 54a:	f56080e7          	jalr	-170(ra) # 49c <putc>
  while(--i >= 0)
 54e:	197d                	addi	s2,s2,-1
 550:	ff3918e3          	bne	s2,s3,540 <printint+0x82>
}
 554:	70e2                	ld	ra,56(sp)
 556:	7442                	ld	s0,48(sp)
 558:	74a2                	ld	s1,40(sp)
 55a:	7902                	ld	s2,32(sp)
 55c:	69e2                	ld	s3,24(sp)
 55e:	6121                	addi	sp,sp,64
 560:	8082                	ret
    x = -xx;
 562:	40b005bb          	negw	a1,a1
    neg = 1;
 566:	4885                	li	a7,1
    x = -xx;
 568:	bf85                	j	4d8 <printint+0x1a>

000000000000056a <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 56a:	715d                	addi	sp,sp,-80
 56c:	e486                	sd	ra,72(sp)
 56e:	e0a2                	sd	s0,64(sp)
 570:	fc26                	sd	s1,56(sp)
 572:	f84a                	sd	s2,48(sp)
 574:	f44e                	sd	s3,40(sp)
 576:	f052                	sd	s4,32(sp)
 578:	ec56                	sd	s5,24(sp)
 57a:	e85a                	sd	s6,16(sp)
 57c:	e45e                	sd	s7,8(sp)
 57e:	e062                	sd	s8,0(sp)
 580:	0880                	addi	s0,sp,80
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 582:	0005c903          	lbu	s2,0(a1)
 586:	18090c63          	beqz	s2,71e <vprintf+0x1b4>
 58a:	8aaa                	mv	s5,a0
 58c:	8bb2                	mv	s7,a2
 58e:	00158493          	addi	s1,a1,1
  state = 0;
 592:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 594:	02500a13          	li	s4,37
 598:	4b55                	li	s6,21
 59a:	a839                	j	5b8 <vprintf+0x4e>
        putc(fd, c);
 59c:	85ca                	mv	a1,s2
 59e:	8556                	mv	a0,s5
 5a0:	00000097          	auipc	ra,0x0
 5a4:	efc080e7          	jalr	-260(ra) # 49c <putc>
 5a8:	a019                	j	5ae <vprintf+0x44>
    } else if(state == '%'){
 5aa:	01498d63          	beq	s3,s4,5c4 <vprintf+0x5a>
  for(i = 0; fmt[i]; i++){
 5ae:	0485                	addi	s1,s1,1
 5b0:	fff4c903          	lbu	s2,-1(s1)
 5b4:	16090563          	beqz	s2,71e <vprintf+0x1b4>
    if(state == 0){
 5b8:	fe0999e3          	bnez	s3,5aa <vprintf+0x40>
      if(c == '%'){
 5bc:	ff4910e3          	bne	s2,s4,59c <vprintf+0x32>
        state = '%';
 5c0:	89d2                	mv	s3,s4
 5c2:	b7f5                	j	5ae <vprintf+0x44>
      if(c == 'd'){
 5c4:	13490263          	beq	s2,s4,6e8 <vprintf+0x17e>
 5c8:	f9d9079b          	addiw	a5,s2,-99
 5cc:	0ff7f793          	zext.b	a5,a5
 5d0:	12fb6563          	bltu	s6,a5,6fa <vprintf+0x190>
 5d4:	f9d9079b          	addiw	a5,s2,-99
 5d8:	0ff7f713          	zext.b	a4,a5
 5dc:	10eb6f63          	bltu	s6,a4,6fa <vprintf+0x190>
 5e0:	00271793          	slli	a5,a4,0x2
 5e4:	00001717          	auipc	a4,0x1
 5e8:	93470713          	addi	a4,a4,-1740 # f18 <ulthread_context_switch+0x136>
 5ec:	97ba                	add	a5,a5,a4
 5ee:	439c                	lw	a5,0(a5)
 5f0:	97ba                	add	a5,a5,a4
 5f2:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
 5f4:	008b8913          	addi	s2,s7,8
 5f8:	4685                	li	a3,1
 5fa:	4629                	li	a2,10
 5fc:	000ba583          	lw	a1,0(s7)
 600:	8556                	mv	a0,s5
 602:	00000097          	auipc	ra,0x0
 606:	ebc080e7          	jalr	-324(ra) # 4be <printint>
 60a:	8bca                	mv	s7,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 60c:	4981                	li	s3,0
 60e:	b745                	j	5ae <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 610:	008b8913          	addi	s2,s7,8
 614:	4681                	li	a3,0
 616:	4629                	li	a2,10
 618:	000ba583          	lw	a1,0(s7)
 61c:	8556                	mv	a0,s5
 61e:	00000097          	auipc	ra,0x0
 622:	ea0080e7          	jalr	-352(ra) # 4be <printint>
 626:	8bca                	mv	s7,s2
      state = 0;
 628:	4981                	li	s3,0
 62a:	b751                	j	5ae <vprintf+0x44>
        printint(fd, va_arg(ap, int), 16, 0);
 62c:	008b8913          	addi	s2,s7,8
 630:	4681                	li	a3,0
 632:	4641                	li	a2,16
 634:	000ba583          	lw	a1,0(s7)
 638:	8556                	mv	a0,s5
 63a:	00000097          	auipc	ra,0x0
 63e:	e84080e7          	jalr	-380(ra) # 4be <printint>
 642:	8bca                	mv	s7,s2
      state = 0;
 644:	4981                	li	s3,0
 646:	b7a5                	j	5ae <vprintf+0x44>
        printptr(fd, va_arg(ap, uint64));
 648:	008b8c13          	addi	s8,s7,8
 64c:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 650:	03000593          	li	a1,48
 654:	8556                	mv	a0,s5
 656:	00000097          	auipc	ra,0x0
 65a:	e46080e7          	jalr	-442(ra) # 49c <putc>
  putc(fd, 'x');
 65e:	07800593          	li	a1,120
 662:	8556                	mv	a0,s5
 664:	00000097          	auipc	ra,0x0
 668:	e38080e7          	jalr	-456(ra) # 49c <putc>
 66c:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 66e:	00001b97          	auipc	s7,0x1
 672:	902b8b93          	addi	s7,s7,-1790 # f70 <digits>
 676:	03c9d793          	srli	a5,s3,0x3c
 67a:	97de                	add	a5,a5,s7
 67c:	0007c583          	lbu	a1,0(a5)
 680:	8556                	mv	a0,s5
 682:	00000097          	auipc	ra,0x0
 686:	e1a080e7          	jalr	-486(ra) # 49c <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 68a:	0992                	slli	s3,s3,0x4
 68c:	397d                	addiw	s2,s2,-1
 68e:	fe0914e3          	bnez	s2,676 <vprintf+0x10c>
        printptr(fd, va_arg(ap, uint64));
 692:	8be2                	mv	s7,s8
      state = 0;
 694:	4981                	li	s3,0
 696:	bf21                	j	5ae <vprintf+0x44>
        s = va_arg(ap, char*);
 698:	008b8993          	addi	s3,s7,8
 69c:	000bb903          	ld	s2,0(s7)
        if(s == 0)
 6a0:	02090163          	beqz	s2,6c2 <vprintf+0x158>
        while(*s != 0){
 6a4:	00094583          	lbu	a1,0(s2)
 6a8:	c9a5                	beqz	a1,718 <vprintf+0x1ae>
          putc(fd, *s);
 6aa:	8556                	mv	a0,s5
 6ac:	00000097          	auipc	ra,0x0
 6b0:	df0080e7          	jalr	-528(ra) # 49c <putc>
          s++;
 6b4:	0905                	addi	s2,s2,1
        while(*s != 0){
 6b6:	00094583          	lbu	a1,0(s2)
 6ba:	f9e5                	bnez	a1,6aa <vprintf+0x140>
        s = va_arg(ap, char*);
 6bc:	8bce                	mv	s7,s3
      state = 0;
 6be:	4981                	li	s3,0
 6c0:	b5fd                	j	5ae <vprintf+0x44>
          s = "(null)";
 6c2:	00001917          	auipc	s2,0x1
 6c6:	84e90913          	addi	s2,s2,-1970 # f10 <ulthread_context_switch+0x12e>
        while(*s != 0){
 6ca:	02800593          	li	a1,40
 6ce:	bff1                	j	6aa <vprintf+0x140>
        putc(fd, va_arg(ap, uint));
 6d0:	008b8913          	addi	s2,s7,8
 6d4:	000bc583          	lbu	a1,0(s7)
 6d8:	8556                	mv	a0,s5
 6da:	00000097          	auipc	ra,0x0
 6de:	dc2080e7          	jalr	-574(ra) # 49c <putc>
 6e2:	8bca                	mv	s7,s2
      state = 0;
 6e4:	4981                	li	s3,0
 6e6:	b5e1                	j	5ae <vprintf+0x44>
        putc(fd, c);
 6e8:	02500593          	li	a1,37
 6ec:	8556                	mv	a0,s5
 6ee:	00000097          	auipc	ra,0x0
 6f2:	dae080e7          	jalr	-594(ra) # 49c <putc>
      state = 0;
 6f6:	4981                	li	s3,0
 6f8:	bd5d                	j	5ae <vprintf+0x44>
        putc(fd, '%');
 6fa:	02500593          	li	a1,37
 6fe:	8556                	mv	a0,s5
 700:	00000097          	auipc	ra,0x0
 704:	d9c080e7          	jalr	-612(ra) # 49c <putc>
        putc(fd, c);
 708:	85ca                	mv	a1,s2
 70a:	8556                	mv	a0,s5
 70c:	00000097          	auipc	ra,0x0
 710:	d90080e7          	jalr	-624(ra) # 49c <putc>
      state = 0;
 714:	4981                	li	s3,0
 716:	bd61                	j	5ae <vprintf+0x44>
        s = va_arg(ap, char*);
 718:	8bce                	mv	s7,s3
      state = 0;
 71a:	4981                	li	s3,0
 71c:	bd49                	j	5ae <vprintf+0x44>
    }
  }
}
 71e:	60a6                	ld	ra,72(sp)
 720:	6406                	ld	s0,64(sp)
 722:	74e2                	ld	s1,56(sp)
 724:	7942                	ld	s2,48(sp)
 726:	79a2                	ld	s3,40(sp)
 728:	7a02                	ld	s4,32(sp)
 72a:	6ae2                	ld	s5,24(sp)
 72c:	6b42                	ld	s6,16(sp)
 72e:	6ba2                	ld	s7,8(sp)
 730:	6c02                	ld	s8,0(sp)
 732:	6161                	addi	sp,sp,80
 734:	8082                	ret

0000000000000736 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 736:	715d                	addi	sp,sp,-80
 738:	ec06                	sd	ra,24(sp)
 73a:	e822                	sd	s0,16(sp)
 73c:	1000                	addi	s0,sp,32
 73e:	e010                	sd	a2,0(s0)
 740:	e414                	sd	a3,8(s0)
 742:	e818                	sd	a4,16(s0)
 744:	ec1c                	sd	a5,24(s0)
 746:	03043023          	sd	a6,32(s0)
 74a:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 74e:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 752:	8622                	mv	a2,s0
 754:	00000097          	auipc	ra,0x0
 758:	e16080e7          	jalr	-490(ra) # 56a <vprintf>
}
 75c:	60e2                	ld	ra,24(sp)
 75e:	6442                	ld	s0,16(sp)
 760:	6161                	addi	sp,sp,80
 762:	8082                	ret

0000000000000764 <printf>:

void
printf(const char *fmt, ...)
{
 764:	711d                	addi	sp,sp,-96
 766:	ec06                	sd	ra,24(sp)
 768:	e822                	sd	s0,16(sp)
 76a:	1000                	addi	s0,sp,32
 76c:	e40c                	sd	a1,8(s0)
 76e:	e810                	sd	a2,16(s0)
 770:	ec14                	sd	a3,24(s0)
 772:	f018                	sd	a4,32(s0)
 774:	f41c                	sd	a5,40(s0)
 776:	03043823          	sd	a6,48(s0)
 77a:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 77e:	00840613          	addi	a2,s0,8
 782:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 786:	85aa                	mv	a1,a0
 788:	4505                	li	a0,1
 78a:	00000097          	auipc	ra,0x0
 78e:	de0080e7          	jalr	-544(ra) # 56a <vprintf>
}
 792:	60e2                	ld	ra,24(sp)
 794:	6442                	ld	s0,16(sp)
 796:	6125                	addi	sp,sp,96
 798:	8082                	ret

000000000000079a <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 79a:	1141                	addi	sp,sp,-16
 79c:	e422                	sd	s0,8(sp)
 79e:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 7a0:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7a4:	00002797          	auipc	a5,0x2
 7a8:	85c7b783          	ld	a5,-1956(a5) # 2000 <freep>
 7ac:	a02d                	j	7d6 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 7ae:	4618                	lw	a4,8(a2)
 7b0:	9f2d                	addw	a4,a4,a1
 7b2:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 7b6:	6398                	ld	a4,0(a5)
 7b8:	6310                	ld	a2,0(a4)
 7ba:	a83d                	j	7f8 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 7bc:	ff852703          	lw	a4,-8(a0)
 7c0:	9f31                	addw	a4,a4,a2
 7c2:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 7c4:	ff053683          	ld	a3,-16(a0)
 7c8:	a091                	j	80c <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7ca:	6398                	ld	a4,0(a5)
 7cc:	00e7e463          	bltu	a5,a4,7d4 <free+0x3a>
 7d0:	00e6ea63          	bltu	a3,a4,7e4 <free+0x4a>
{
 7d4:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7d6:	fed7fae3          	bgeu	a5,a3,7ca <free+0x30>
 7da:	6398                	ld	a4,0(a5)
 7dc:	00e6e463          	bltu	a3,a4,7e4 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7e0:	fee7eae3          	bltu	a5,a4,7d4 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 7e4:	ff852583          	lw	a1,-8(a0)
 7e8:	6390                	ld	a2,0(a5)
 7ea:	02059813          	slli	a6,a1,0x20
 7ee:	01c85713          	srli	a4,a6,0x1c
 7f2:	9736                	add	a4,a4,a3
 7f4:	fae60de3          	beq	a2,a4,7ae <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 7f8:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 7fc:	4790                	lw	a2,8(a5)
 7fe:	02061593          	slli	a1,a2,0x20
 802:	01c5d713          	srli	a4,a1,0x1c
 806:	973e                	add	a4,a4,a5
 808:	fae68ae3          	beq	a3,a4,7bc <free+0x22>
    p->s.ptr = bp->s.ptr;
 80c:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 80e:	00001717          	auipc	a4,0x1
 812:	7ef73923          	sd	a5,2034(a4) # 2000 <freep>
}
 816:	6422                	ld	s0,8(sp)
 818:	0141                	addi	sp,sp,16
 81a:	8082                	ret

000000000000081c <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 81c:	7139                	addi	sp,sp,-64
 81e:	fc06                	sd	ra,56(sp)
 820:	f822                	sd	s0,48(sp)
 822:	f426                	sd	s1,40(sp)
 824:	f04a                	sd	s2,32(sp)
 826:	ec4e                	sd	s3,24(sp)
 828:	e852                	sd	s4,16(sp)
 82a:	e456                	sd	s5,8(sp)
 82c:	e05a                	sd	s6,0(sp)
 82e:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 830:	02051493          	slli	s1,a0,0x20
 834:	9081                	srli	s1,s1,0x20
 836:	04bd                	addi	s1,s1,15
 838:	8091                	srli	s1,s1,0x4
 83a:	0014899b          	addiw	s3,s1,1
 83e:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 840:	00001517          	auipc	a0,0x1
 844:	7c053503          	ld	a0,1984(a0) # 2000 <freep>
 848:	c515                	beqz	a0,874 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 84a:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 84c:	4798                	lw	a4,8(a5)
 84e:	02977f63          	bgeu	a4,s1,88c <malloc+0x70>
  if(nu < 4096)
 852:	8a4e                	mv	s4,s3
 854:	0009871b          	sext.w	a4,s3
 858:	6685                	lui	a3,0x1
 85a:	00d77363          	bgeu	a4,a3,860 <malloc+0x44>
 85e:	6a05                	lui	s4,0x1
 860:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 864:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 868:	00001917          	auipc	s2,0x1
 86c:	79890913          	addi	s2,s2,1944 # 2000 <freep>
  if(p == (char*)-1)
 870:	5afd                	li	s5,-1
 872:	a895                	j	8e6 <malloc+0xca>
    base.s.ptr = freep = prevp = &base;
 874:	00065797          	auipc	a5,0x65
 878:	7ac78793          	addi	a5,a5,1964 # 66020 <base>
 87c:	00001717          	auipc	a4,0x1
 880:	78f73223          	sd	a5,1924(a4) # 2000 <freep>
 884:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 886:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 88a:	b7e1                	j	852 <malloc+0x36>
      if(p->s.size == nunits)
 88c:	02e48c63          	beq	s1,a4,8c4 <malloc+0xa8>
        p->s.size -= nunits;
 890:	4137073b          	subw	a4,a4,s3
 894:	c798                	sw	a4,8(a5)
        p += p->s.size;
 896:	02071693          	slli	a3,a4,0x20
 89a:	01c6d713          	srli	a4,a3,0x1c
 89e:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 8a0:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 8a4:	00001717          	auipc	a4,0x1
 8a8:	74a73e23          	sd	a0,1884(a4) # 2000 <freep>
      return (void*)(p + 1);
 8ac:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 8b0:	70e2                	ld	ra,56(sp)
 8b2:	7442                	ld	s0,48(sp)
 8b4:	74a2                	ld	s1,40(sp)
 8b6:	7902                	ld	s2,32(sp)
 8b8:	69e2                	ld	s3,24(sp)
 8ba:	6a42                	ld	s4,16(sp)
 8bc:	6aa2                	ld	s5,8(sp)
 8be:	6b02                	ld	s6,0(sp)
 8c0:	6121                	addi	sp,sp,64
 8c2:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 8c4:	6398                	ld	a4,0(a5)
 8c6:	e118                	sd	a4,0(a0)
 8c8:	bff1                	j	8a4 <malloc+0x88>
  hp->s.size = nu;
 8ca:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 8ce:	0541                	addi	a0,a0,16
 8d0:	00000097          	auipc	ra,0x0
 8d4:	eca080e7          	jalr	-310(ra) # 79a <free>
  return freep;
 8d8:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 8dc:	d971                	beqz	a0,8b0 <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8de:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 8e0:	4798                	lw	a4,8(a5)
 8e2:	fa9775e3          	bgeu	a4,s1,88c <malloc+0x70>
    if(p == freep)
 8e6:	00093703          	ld	a4,0(s2)
 8ea:	853e                	mv	a0,a5
 8ec:	fef719e3          	bne	a4,a5,8de <malloc+0xc2>
  p = sbrk(nu * sizeof(Header));
 8f0:	8552                	mv	a0,s4
 8f2:	00000097          	auipc	ra,0x0
 8f6:	b8a080e7          	jalr	-1142(ra) # 47c <sbrk>
  if(p == (char*)-1)
 8fa:	fd5518e3          	bne	a0,s5,8ca <malloc+0xae>
        return 0;
 8fe:	4501                	li	a0,0
 900:	bf45                	j	8b0 <malloc+0x94>

0000000000000902 <get_current_tid>:
struct ulthread *scheduler_thread;
enum ulthread_scheduling_algorithm algorithm;

/* Get thread ID */
int get_current_tid(void)
{
 902:	1141                	addi	sp,sp,-16
 904:	e422                	sd	s0,8(sp)
 906:	0800                	addi	s0,sp,16
  return current_thread->tid;
}
 908:	00001797          	auipc	a5,0x1
 90c:	7107b783          	ld	a5,1808(a5) # 2018 <current_thread>
 910:	43c8                	lw	a0,4(a5)
 912:	6422                	ld	s0,8(sp)
 914:	0141                	addi	sp,sp,16
 916:	8082                	ret

0000000000000918 <roundRobin>:

void roundRobin(void)
{
 918:	715d                	addi	sp,sp,-80
 91a:	e486                	sd	ra,72(sp)
 91c:	e0a2                	sd	s0,64(sp)
 91e:	fc26                	sd	s1,56(sp)
 920:	f84a                	sd	s2,48(sp)
 922:	f44e                	sd	s3,40(sp)
 924:	f052                	sd	s4,32(sp)
 926:	ec56                	sd	s5,24(sp)
 928:	e85a                	sd	s6,16(sp)
 92a:	e45e                	sd	s7,8(sp)
 92c:	e062                	sd	s8,0(sp)
 92e:	0880                	addi	s0,sp,80
        struct ulthread *temp = current_thread;
        current_thread = t;
        printf("[*] ultschedule (next tid: %d)\n", get_current_tid());
        ulthread_context_switch(&temp->context, &t->context);
      }
      if (t->state == YIELD)
 930:	4a09                	li	s4,2
      if (t->state == RUNNABLE && t != scheduler_thread)
 932:	00001b97          	auipc	s7,0x1
 936:	6deb8b93          	addi	s7,s7,1758 # 2010 <scheduler_thread>
        struct ulthread *temp = current_thread;
 93a:	00001a97          	auipc	s5,0x1
 93e:	6dea8a93          	addi	s5,s5,1758 # 2018 <current_thread>
        printf("[*] ultschedule (next tid: %d)\n", get_current_tid());
 942:	00000c17          	auipc	s8,0x0
 946:	646c0c13          	addi	s8,s8,1606 # f88 <digits+0x18>
    for (t = ulthreads; t < &ulthreads[MAXULTHREADS]; t++)
 94a:	00069997          	auipc	s3,0x69
 94e:	c0698993          	addi	s3,s3,-1018 # 69550 <ulthreads+0x3520>
 952:	a0b9                	j	9a0 <roundRobin+0x88>
      if (t->state == RUNNABLE && t != scheduler_thread)
 954:	000bb783          	ld	a5,0(s7)
 958:	02978863          	beq	a5,s1,988 <roundRobin+0x70>
        struct ulthread *temp = current_thread;
 95c:	000abb03          	ld	s6,0(s5)
        current_thread = t;
 960:	009ab023          	sd	s1,0(s5)
        printf("[*] ultschedule (next tid: %d)\n", get_current_tid());
 964:	40cc                	lw	a1,4(s1)
 966:	8562                	mv	a0,s8
 968:	00000097          	auipc	ra,0x0
 96c:	dfc080e7          	jalr	-516(ra) # 764 <printf>
        ulthread_context_switch(&temp->context, &t->context);
 970:	01848593          	addi	a1,s1,24
 974:	018b0513          	addi	a0,s6,24
 978:	00000097          	auipc	ra,0x0
 97c:	46a080e7          	jalr	1130(ra) # de2 <ulthread_context_switch>
        threadAvailable = true;
 980:	874a                	mv	a4,s2
 982:	a811                	j	996 <roundRobin+0x7e>
      {
        t->state = RUNNABLE;
 984:	0124a023          	sw	s2,0(s1)
    for (t = ulthreads; t < &ulthreads[MAXULTHREADS]; t++)
 988:	08848493          	addi	s1,s1,136
 98c:	01348963          	beq	s1,s3,99e <roundRobin+0x86>
      if (t->state == RUNNABLE && t != scheduler_thread)
 990:	409c                	lw	a5,0(s1)
 992:	fd2781e3          	beq	a5,s2,954 <roundRobin+0x3c>
      if (t->state == YIELD)
 996:	409c                	lw	a5,0(s1)
 998:	ff4798e3          	bne	a5,s4,988 <roundRobin+0x70>
 99c:	b7e5                	j	984 <roundRobin+0x6c>
      }
    }
    if (!threadAvailable)
 99e:	cb01                	beqz	a4,9ae <roundRobin+0x96>
    bool threadAvailable = false;
 9a0:	4701                	li	a4,0
    for (t = ulthreads; t < &ulthreads[MAXULTHREADS]; t++)
 9a2:	00065497          	auipc	s1,0x65
 9a6:	68e48493          	addi	s1,s1,1678 # 66030 <ulthreads>
      if (t->state == RUNNABLE && t != scheduler_thread)
 9aa:	4905                	li	s2,1
 9ac:	b7d5                	j	990 <roundRobin+0x78>
    {
      break;
    }
  }
}
 9ae:	60a6                	ld	ra,72(sp)
 9b0:	6406                	ld	s0,64(sp)
 9b2:	74e2                	ld	s1,56(sp)
 9b4:	7942                	ld	s2,48(sp)
 9b6:	79a2                	ld	s3,40(sp)
 9b8:	7a02                	ld	s4,32(sp)
 9ba:	6ae2                	ld	s5,24(sp)
 9bc:	6b42                	ld	s6,16(sp)
 9be:	6ba2                	ld	s7,8(sp)
 9c0:	6c02                	ld	s8,0(sp)
 9c2:	6161                	addi	sp,sp,80
 9c4:	8082                	ret

00000000000009c6 <firstComeFirstServe>:

void firstComeFirstServe(void)
{
 9c6:	715d                	addi	sp,sp,-80
 9c8:	e486                	sd	ra,72(sp)
 9ca:	e0a2                	sd	s0,64(sp)
 9cc:	fc26                	sd	s1,56(sp)
 9ce:	f84a                	sd	s2,48(sp)
 9d0:	f44e                	sd	s3,40(sp)
 9d2:	f052                	sd	s4,32(sp)
 9d4:	ec56                	sd	s5,24(sp)
 9d6:	e85a                	sd	s6,16(sp)
 9d8:	e45e                	sd	s7,8(sp)
 9da:	e062                	sd	s8,0(sp)
 9dc:	0880                	addi	s0,sp,80
    uint64 oldest = __INT64_MAX__;
    int threadIndex = -1;
    int alternativeIndex = -1;
    for (t = ulthreads+1; t < &ulthreads[MAXULTHREADS]; t++)
    {
      if (t->state == RUNNABLE && t != scheduler_thread && t->lastTime < oldest)
 9de:	00001b97          	auipc	s7,0x1
 9e2:	632b8b93          	addi	s7,s7,1586 # 2010 <scheduler_thread>
    int alternativeIndex = -1;
 9e6:	5afd                	li	s5,-1
    uint64 oldest = __INT64_MAX__;
 9e8:	001adb13          	srli	s6,s5,0x1
      if (t->state == RUNNABLE && t != scheduler_thread && t->lastTime < oldest)
 9ec:	4485                	li	s1,1
        oldest = t->lastTime;
        threadIndex = t->tid;
        threadAvailable = true;
      }

      if (t->state == YIELD){
 9ee:	4989                	li	s3,2
    for (t = ulthreads+1; t < &ulthreads[MAXULTHREADS]; t++)
 9f0:	00069917          	auipc	s2,0x69
 9f4:	b6090913          	addi	s2,s2,-1184 # 69550 <ulthreads+0x3520>
        break;
      }
      
    }
    label : 
      struct ulthread *temp = current_thread;
 9f8:	00001a17          	auipc	s4,0x1
 9fc:	620a0a13          	addi	s4,s4,1568 # 2018 <current_thread>
 a00:	a88d                	j	a72 <firstComeFirstServe+0xac>
      if (t->state == RUNNABLE && t != scheduler_thread && t->lastTime < oldest)
 a02:	00f58963          	beq	a1,a5,a14 <firstComeFirstServe+0x4e>
 a06:	6b98                	ld	a4,16(a5)
 a08:	00c77663          	bgeu	a4,a2,a14 <firstComeFirstServe+0x4e>
        threadIndex = t->tid;
 a0c:	0047a803          	lw	a6,4(a5)
        oldest = t->lastTime;
 a10:	863a                	mv	a2,a4
        threadAvailable = true;
 a12:	8526                	mv	a0,s1
    for (t = ulthreads+1; t < &ulthreads[MAXULTHREADS]; t++)
 a14:	08878793          	addi	a5,a5,136
 a18:	01278a63          	beq	a5,s2,a2c <firstComeFirstServe+0x66>
      if (t->state == RUNNABLE && t != scheduler_thread && t->lastTime < oldest)
 a1c:	4398                	lw	a4,0(a5)
 a1e:	fe9702e3          	beq	a4,s1,a02 <firstComeFirstServe+0x3c>
      if (t->state == YIELD){
 a22:	ff3719e3          	bne	a4,s3,a14 <firstComeFirstServe+0x4e>
        t->state = RUNNABLE;
 a26:	c384                	sw	s1,0(a5)
        alternativeIndex = t->tid;
 a28:	43d4                	lw	a3,4(a5)
 a2a:	b7ed                	j	a14 <firstComeFirstServe+0x4e>
    if (!threadAvailable)
 a2c:	ed31                	bnez	a0,a88 <firstComeFirstServe+0xc2>
      if(alternativeIndex > 0){
 a2e:	04d05f63          	blez	a3,a8c <firstComeFirstServe+0xc6>
      struct ulthread *temp = current_thread;
 a32:	000a3c03          	ld	s8,0(s4)
      current_thread = &ulthreads[threadIndex];
 a36:	00469793          	slli	a5,a3,0x4
 a3a:	00d78733          	add	a4,a5,a3
 a3e:	070e                	slli	a4,a4,0x3
 a40:	00065617          	auipc	a2,0x65
 a44:	5f060613          	addi	a2,a2,1520 # 66030 <ulthreads>
 a48:	9732                	add	a4,a4,a2
 a4a:	00ea3023          	sd	a4,0(s4)
      printf("[*] ultschedule (next tid: %d), time = %d\n", get_current_tid());
 a4e:	434c                	lw	a1,4(a4)
 a50:	00000517          	auipc	a0,0x0
 a54:	55850513          	addi	a0,a0,1368 # fa8 <digits+0x38>
 a58:	00000097          	auipc	ra,0x0
 a5c:	d0c080e7          	jalr	-756(ra) # 764 <printf>
      ulthread_context_switch(&temp->context, &current_thread->context);
 a60:	000a3583          	ld	a1,0(s4)
 a64:	05e1                	addi	a1,a1,24
 a66:	018c0513          	addi	a0,s8,24
 a6a:	00000097          	auipc	ra,0x0
 a6e:	378080e7          	jalr	888(ra) # de2 <ulthread_context_switch>
      if (t->state == RUNNABLE && t != scheduler_thread && t->lastTime < oldest)
 a72:	000bb583          	ld	a1,0(s7)
    int alternativeIndex = -1;
 a76:	86d6                	mv	a3,s5
    int threadIndex = -1;
 a78:	8856                	mv	a6,s5
    uint64 oldest = __INT64_MAX__;
 a7a:	865a                	mv	a2,s6
    bool threadAvailable = false;
 a7c:	4501                	li	a0,0
    for (t = ulthreads+1; t < &ulthreads[MAXULTHREADS]; t++)
 a7e:	00065797          	auipc	a5,0x65
 a82:	63a78793          	addi	a5,a5,1594 # 660b8 <ulthreads+0x88>
 a86:	bf59                	j	a1c <firstComeFirstServe+0x56>
    label : 
 a88:	86c2                	mv	a3,a6
 a8a:	b765                	j	a32 <firstComeFirstServe+0x6c>
  }
}
 a8c:	60a6                	ld	ra,72(sp)
 a8e:	6406                	ld	s0,64(sp)
 a90:	74e2                	ld	s1,56(sp)
 a92:	7942                	ld	s2,48(sp)
 a94:	79a2                	ld	s3,40(sp)
 a96:	7a02                	ld	s4,32(sp)
 a98:	6ae2                	ld	s5,24(sp)
 a9a:	6b42                	ld	s6,16(sp)
 a9c:	6ba2                	ld	s7,8(sp)
 a9e:	6c02                	ld	s8,0(sp)
 aa0:	6161                	addi	sp,sp,80
 aa2:	8082                	ret

0000000000000aa4 <priorityScheduling>:


void priorityScheduling(void)
{
 aa4:	715d                	addi	sp,sp,-80
 aa6:	e486                	sd	ra,72(sp)
 aa8:	e0a2                	sd	s0,64(sp)
 aaa:	fc26                	sd	s1,56(sp)
 aac:	f84a                	sd	s2,48(sp)
 aae:	f44e                	sd	s3,40(sp)
 ab0:	f052                	sd	s4,32(sp)
 ab2:	ec56                	sd	s5,24(sp)
 ab4:	e85a                	sd	s6,16(sp)
 ab6:	e45e                	sd	s7,8(sp)
 ab8:	0880                	addi	s0,sp,80
    int maxPriority = -1;
    int threadIndex = -1;
    int alternativeIndex = -1;
    for (t = ulthreads+1; t < &ulthreads[MAXULTHREADS]; t++)
    {
      if (t->state == RUNNABLE && t != scheduler_thread && t->priority > maxPriority)
 aba:	00001b17          	auipc	s6,0x1
 abe:	556b0b13          	addi	s6,s6,1366 # 2010 <scheduler_thread>
    int alternativeIndex = -1;
 ac2:	5a7d                	li	s4,-1
      if (t->state == RUNNABLE && t != scheduler_thread && t->priority > maxPriority)
 ac4:	4485                	li	s1,1
        // flag = true;

        // break; // switch to highest-priority thread and exit loop
      }

      if (t->state == YIELD){
 ac6:	4989                	li	s3,2
    for (t = ulthreads+1; t < &ulthreads[MAXULTHREADS]; t++)
 ac8:	00069917          	auipc	s2,0x69
 acc:	a8890913          	addi	s2,s2,-1400 # 69550 <ulthreads+0x3520>
        break;
      }
      
    }
    label : 
      struct ulthread *temp = current_thread;
 ad0:	00001a97          	auipc	s5,0x1
 ad4:	548a8a93          	addi	s5,s5,1352 # 2018 <current_thread>
 ad8:	a88d                	j	b4a <priorityScheduling+0xa6>
      if (t->state == RUNNABLE && t != scheduler_thread && t->priority > maxPriority)
 ada:	00f58963          	beq	a1,a5,aec <priorityScheduling+0x48>
 ade:	47d8                	lw	a4,12(a5)
 ae0:	00e65663          	bge	a2,a4,aec <priorityScheduling+0x48>
        threadIndex = t->tid;
 ae4:	0047a803          	lw	a6,4(a5)
        maxPriority = t->priority;
 ae8:	863a                	mv	a2,a4
        threadAvailable = true;
 aea:	8526                	mv	a0,s1
    for (t = ulthreads+1; t < &ulthreads[MAXULTHREADS]; t++)
 aec:	08878793          	addi	a5,a5,136
 af0:	01278a63          	beq	a5,s2,b04 <priorityScheduling+0x60>
      if (t->state == RUNNABLE && t != scheduler_thread && t->priority > maxPriority)
 af4:	4398                	lw	a4,0(a5)
 af6:	fe9702e3          	beq	a4,s1,ada <priorityScheduling+0x36>
      if (t->state == YIELD){
 afa:	ff3719e3          	bne	a4,s3,aec <priorityScheduling+0x48>
        t->state = RUNNABLE;
 afe:	c384                	sw	s1,0(a5)
        alternativeIndex = t->tid;
 b00:	43d4                	lw	a3,4(a5)
 b02:	b7ed                	j	aec <priorityScheduling+0x48>
    if (!threadAvailable)
 b04:	ed31                	bnez	a0,b60 <priorityScheduling+0xbc>
      if(alternativeIndex > 0){
 b06:	04d05f63          	blez	a3,b64 <priorityScheduling+0xc0>
      struct ulthread *temp = current_thread;
 b0a:	000abb83          	ld	s7,0(s5)
      current_thread = &ulthreads[threadIndex];
 b0e:	00469793          	slli	a5,a3,0x4
 b12:	00d78733          	add	a4,a5,a3
 b16:	070e                	slli	a4,a4,0x3
 b18:	00065617          	auipc	a2,0x65
 b1c:	51860613          	addi	a2,a2,1304 # 66030 <ulthreads>
 b20:	9732                	add	a4,a4,a2
 b22:	00eab023          	sd	a4,0(s5)
      printf("[*] ultschedule (next tid: %d)\n", get_current_tid());
 b26:	434c                	lw	a1,4(a4)
 b28:	00000517          	auipc	a0,0x0
 b2c:	46050513          	addi	a0,a0,1120 # f88 <digits+0x18>
 b30:	00000097          	auipc	ra,0x0
 b34:	c34080e7          	jalr	-972(ra) # 764 <printf>
      ulthread_context_switch(&temp->context, &current_thread->context);
 b38:	000ab583          	ld	a1,0(s5)
 b3c:	05e1                	addi	a1,a1,24
 b3e:	018b8513          	addi	a0,s7,24
 b42:	00000097          	auipc	ra,0x0
 b46:	2a0080e7          	jalr	672(ra) # de2 <ulthread_context_switch>
      if (t->state == RUNNABLE && t != scheduler_thread && t->priority > maxPriority)
 b4a:	000b3583          	ld	a1,0(s6)
    int alternativeIndex = -1;
 b4e:	86d2                	mv	a3,s4
    int threadIndex = -1;
 b50:	8852                	mv	a6,s4
    int maxPriority = -1;
 b52:	8652                	mv	a2,s4
    bool threadAvailable = false;
 b54:	4501                	li	a0,0
    for (t = ulthreads+1; t < &ulthreads[MAXULTHREADS]; t++)
 b56:	00065797          	auipc	a5,0x65
 b5a:	56278793          	addi	a5,a5,1378 # 660b8 <ulthreads+0x88>
 b5e:	bf59                	j	af4 <priorityScheduling+0x50>
    label : 
 b60:	86c2                	mv	a3,a6
 b62:	b765                	j	b0a <priorityScheduling+0x66>
  }
}
 b64:	60a6                	ld	ra,72(sp)
 b66:	6406                	ld	s0,64(sp)
 b68:	74e2                	ld	s1,56(sp)
 b6a:	7942                	ld	s2,48(sp)
 b6c:	79a2                	ld	s3,40(sp)
 b6e:	7a02                	ld	s4,32(sp)
 b70:	6ae2                	ld	s5,24(sp)
 b72:	6b42                	ld	s6,16(sp)
 b74:	6ba2                	ld	s7,8(sp)
 b76:	6161                	addi	sp,sp,80
 b78:	8082                	ret

0000000000000b7a <ulthread_init>:

/* Thread initialization */
void ulthread_init(int schedalgo)
{
 b7a:	1141                	addi	sp,sp,-16
 b7c:	e422                	sd	s0,8(sp)
 b7e:	0800                	addi	s0,sp,16
  struct ulthread *t;
  int i;
  for (i = 0, t = ulthreads; t < &ulthreads[MAXULTHREADS]; t++, i++)
 b80:	4701                	li	a4,0
 b82:	00065797          	auipc	a5,0x65
 b86:	4ae78793          	addi	a5,a5,1198 # 66030 <ulthreads>
 b8a:	00069697          	auipc	a3,0x69
 b8e:	9c668693          	addi	a3,a3,-1594 # 69550 <ulthreads+0x3520>
  {
    t->state = FREE;
 b92:	0007a023          	sw	zero,0(a5)
    t->tid = i;
 b96:	c3d8                	sw	a4,4(a5)
  for (i = 0, t = ulthreads; t < &ulthreads[MAXULTHREADS]; t++, i++)
 b98:	08878793          	addi	a5,a5,136
 b9c:	2705                	addiw	a4,a4,1
 b9e:	fed79ae3          	bne	a5,a3,b92 <ulthread_init+0x18>
  }
  current_thread = &ulthreads[0];
 ba2:	00065797          	auipc	a5,0x65
 ba6:	48e78793          	addi	a5,a5,1166 # 66030 <ulthreads>
 baa:	00001717          	auipc	a4,0x1
 bae:	46f73723          	sd	a5,1134(a4) # 2018 <current_thread>
  scheduler_thread = &ulthreads[0];
 bb2:	00001717          	auipc	a4,0x1
 bb6:	44f73f23          	sd	a5,1118(a4) # 2010 <scheduler_thread>
  scheduler_thread->state = RUNNABLE;
 bba:	4705                	li	a4,1
 bbc:	c398                	sw	a4,0(a5)
  t->state = FREE;
 bbe:	00069797          	auipc	a5,0x69
 bc2:	9807a923          	sw	zero,-1646(a5) # 69550 <ulthreads+0x3520>
  algorithm = schedalgo;
 bc6:	00001797          	auipc	a5,0x1
 bca:	44a7a123          	sw	a0,1090(a5) # 2008 <algorithm>
}
 bce:	6422                	ld	s0,8(sp)
 bd0:	0141                	addi	sp,sp,16
 bd2:	8082                	ret

0000000000000bd4 <ulthread_create>:

/* Thread creation */
bool ulthread_create(uint64 start, uint64 stack, uint64 args[], int priority)
{
 bd4:	7179                	addi	sp,sp,-48
 bd6:	f406                	sd	ra,40(sp)
 bd8:	f022                	sd	s0,32(sp)
 bda:	ec26                	sd	s1,24(sp)
 bdc:	e84a                	sd	s2,16(sp)
 bde:	e44e                	sd	s3,8(sp)
 be0:	e052                	sd	s4,0(sp)
 be2:	1800                	addi	s0,sp,48
 be4:	89aa                	mv	s3,a0
 be6:	8a2e                	mv	s4,a1
 be8:	8932                	mv	s2,a2
  /* Please add thread-id instead of '0' here. */
  struct ulthread *t;
  bool flag = false;
  for (t = ulthreads; t < &ulthreads[MAXULTHREADS]; t++)
 bea:	00065497          	auipc	s1,0x65
 bee:	44648493          	addi	s1,s1,1094 # 66030 <ulthreads>
 bf2:	00069717          	auipc	a4,0x69
 bf6:	95e70713          	addi	a4,a4,-1698 # 69550 <ulthreads+0x3520>
  {
    if (t->state == FREE)
 bfa:	409c                	lw	a5,0(s1)
 bfc:	cf89                	beqz	a5,c16 <ulthread_create+0x42>
  for (t = ulthreads; t < &ulthreads[MAXULTHREADS]; t++)
 bfe:	08848493          	addi	s1,s1,136
 c02:	fee49ce3          	bne	s1,a4,bfa <ulthread_create+0x26>
      break;
    }
  }
  if (!flag)
  {
    return false;
 c06:	4501                	li	a0,0
 c08:	a871                	j	ca4 <ulthread_create+0xd0>
  t->sp = (int)(stack + USTACKSIZE); // set sp to the top of the stack
  t->state = RUNNABLE;
  t->priority = priority;

  if(algorithm==FCFS){
    t->lastTime = ctime();
 c0a:	00000097          	auipc	ra,0x0
 c0e:	88a080e7          	jalr	-1910(ra) # 494 <ctime>
 c12:	e888                	sd	a0,16(s1)
 c14:	a839                	j	c32 <ulthread_create+0x5e>
  t->sp = (int)(stack + USTACKSIZE); // set sp to the top of the stack
 c16:	6785                	lui	a5,0x1
 c18:	014787bb          	addw	a5,a5,s4
 c1c:	c49c                	sw	a5,8(s1)
  t->state = RUNNABLE;
 c1e:	4785                	li	a5,1
 c20:	c09c                	sw	a5,0(s1)
  t->priority = priority;
 c22:	c4d4                	sw	a3,12(s1)
  if(algorithm==FCFS){
 c24:	00001717          	auipc	a4,0x1
 c28:	3e472703          	lw	a4,996(a4) # 2008 <algorithm>
 c2c:	4789                	li	a5,2
 c2e:	fcf70ee3          	beq	a4,a5,c0a <ulthread_create+0x36>
  }

  for (int argc = 0; argc < 6; argc++)
 c32:	874a                	mv	a4,s2
 c34:	03090693          	addi	a3,s2,48
  {
    t->sp -= 16;
 c38:	449c                	lw	a5,8(s1)
 c3a:	37c1                	addiw	a5,a5,-16 # ff0 <digits+0x80>
 c3c:	0007881b          	sext.w	a6,a5
 c40:	c49c                	sw	a5,8(s1)
    *(uint64 *)(t->sp) = (uint64)args[argc];
 c42:	631c                	ld	a5,0(a4)
 c44:	00f83023          	sd	a5,0(a6)
  for (int argc = 0; argc < 6; argc++)
 c48:	0721                	addi	a4,a4,8
 c4a:	fed717e3          	bne	a4,a3,c38 <ulthread_create+0x64>
  }

  memset(&t->context, 0, sizeof(t->context));
 c4e:	07000613          	li	a2,112
 c52:	4581                	li	a1,0
 c54:	01848513          	addi	a0,s1,24
 c58:	fffff097          	auipc	ra,0xfffff
 c5c:	5a2080e7          	jalr	1442(ra) # 1fa <memset>
  t->context.ra = start;
 c60:	0134bc23          	sd	s3,24(s1)
  t->context.sp = t->sp;
 c64:	449c                	lw	a5,8(s1)
 c66:	f09c                	sd	a5,32(s1)
  t->context.s0 = args[0];
 c68:	00093783          	ld	a5,0(s2)
 c6c:	f49c                	sd	a5,40(s1)
  t->context.s1 = args[1];
 c6e:	00893783          	ld	a5,8(s2)
 c72:	f89c                	sd	a5,48(s1)
  t->context.s2 = args[2];
 c74:	01093783          	ld	a5,16(s2)
 c78:	fc9c                	sd	a5,56(s1)
  t->context.s3 = args[3];
 c7a:	01893783          	ld	a5,24(s2)
 c7e:	e0bc                	sd	a5,64(s1)
  t->context.s4 = args[4];
 c80:	02093783          	ld	a5,32(s2)
 c84:	e4bc                	sd	a5,72(s1)
  t->context.s5 = args[5];
 c86:	02893783          	ld	a5,40(s2)
 c8a:	e8bc                	sd	a5,80(s1)

  printf("[*] ultcreate(tid: %d, ra: %p, sp: %p)\n", t->tid, start, stack);
 c8c:	86d2                	mv	a3,s4
 c8e:	864e                	mv	a2,s3
 c90:	40cc                	lw	a1,4(s1)
 c92:	00000517          	auipc	a0,0x0
 c96:	34650513          	addi	a0,a0,838 # fd8 <digits+0x68>
 c9a:	00000097          	auipc	ra,0x0
 c9e:	aca080e7          	jalr	-1334(ra) # 764 <printf>
  return true;
 ca2:	4505                	li	a0,1
}
 ca4:	70a2                	ld	ra,40(sp)
 ca6:	7402                	ld	s0,32(sp)
 ca8:	64e2                	ld	s1,24(sp)
 caa:	6942                	ld	s2,16(sp)
 cac:	69a2                	ld	s3,8(sp)
 cae:	6a02                	ld	s4,0(sp)
 cb0:	6145                	addi	sp,sp,48
 cb2:	8082                	ret

0000000000000cb4 <ulthread_schedule>:

/* Thread scheduler */
void ulthread_schedule(void)
{
 cb4:	1141                	addi	sp,sp,-16
 cb6:	e406                	sd	ra,8(sp)
 cb8:	e022                	sd	s0,0(sp)
 cba:	0800                	addi	s0,sp,16
  switch (algorithm)
 cbc:	00001797          	auipc	a5,0x1
 cc0:	34c7a783          	lw	a5,844(a5) # 2008 <algorithm>
 cc4:	4705                	li	a4,1
 cc6:	02e78463          	beq	a5,a4,cee <ulthread_schedule+0x3a>
 cca:	4709                	li	a4,2
 ccc:	00e78c63          	beq	a5,a4,ce4 <ulthread_schedule+0x30>
 cd0:	c789                	beqz	a5,cda <ulthread_schedule+0x26>

  // Push argument strings, prepare rest of stack in ustack.

  // Switch between thread contexts
  // ulthread_context_switch(NULL, NULL);
}
 cd2:	60a2                	ld	ra,8(sp)
 cd4:	6402                	ld	s0,0(sp)
 cd6:	0141                	addi	sp,sp,16
 cd8:	8082                	ret
    roundRobin();
 cda:	00000097          	auipc	ra,0x0
 cde:	c3e080e7          	jalr	-962(ra) # 918 <roundRobin>
    break;
 ce2:	bfc5                	j	cd2 <ulthread_schedule+0x1e>
    firstComeFirstServe();
 ce4:	00000097          	auipc	ra,0x0
 ce8:	ce2080e7          	jalr	-798(ra) # 9c6 <firstComeFirstServe>
    break;
 cec:	b7dd                	j	cd2 <ulthread_schedule+0x1e>
    priorityScheduling();
 cee:	00000097          	auipc	ra,0x0
 cf2:	db6080e7          	jalr	-586(ra) # aa4 <priorityScheduling>
}
 cf6:	bff1                	j	cd2 <ulthread_schedule+0x1e>

0000000000000cf8 <ulthread_yield>:

/* Yield CPU time to some other thread. */
void ulthread_yield(void)
{
 cf8:	1101                	addi	sp,sp,-32
 cfa:	ec06                	sd	ra,24(sp)
 cfc:	e822                	sd	s0,16(sp)
 cfe:	e426                	sd	s1,8(sp)
 d00:	e04a                	sd	s2,0(sp)
 d02:	1000                	addi	s0,sp,32
  current_thread->state = YIELD;
 d04:	00001797          	auipc	a5,0x1
 d08:	31478793          	addi	a5,a5,788 # 2018 <current_thread>
 d0c:	6398                	ld	a4,0(a5)
 d0e:	4909                	li	s2,2
 d10:	01272023          	sw	s2,0(a4)
  struct ulthread *temp = current_thread;
 d14:	6384                	ld	s1,0(a5)
  printf("[*] ultyield(tid: %d)\n", current_thread->tid);
 d16:	40cc                	lw	a1,4(s1)
 d18:	00000517          	auipc	a0,0x0
 d1c:	2e850513          	addi	a0,a0,744 # 1000 <digits+0x90>
 d20:	00000097          	auipc	ra,0x0
 d24:	a44080e7          	jalr	-1468(ra) # 764 <printf>
  if(algorithm==FCFS){
 d28:	00001797          	auipc	a5,0x1
 d2c:	2e07a783          	lw	a5,736(a5) # 2008 <algorithm>
 d30:	03278763          	beq	a5,s2,d5e <ulthread_yield+0x66>
    current_thread->lastTime = ctime();
  }
  current_thread = scheduler_thread;
 d34:	00001597          	auipc	a1,0x1
 d38:	2dc5b583          	ld	a1,732(a1) # 2010 <scheduler_thread>
 d3c:	00001797          	auipc	a5,0x1
 d40:	2cb7be23          	sd	a1,732(a5) # 2018 <current_thread>
  
  ulthread_context_switch(&temp->context, &scheduler_thread->context);
 d44:	05e1                	addi	a1,a1,24
 d46:	01848513          	addi	a0,s1,24
 d4a:	00000097          	auipc	ra,0x0
 d4e:	098080e7          	jalr	152(ra) # de2 <ulthread_context_switch>
  // ulthread_schedule();
}
 d52:	60e2                	ld	ra,24(sp)
 d54:	6442                	ld	s0,16(sp)
 d56:	64a2                	ld	s1,8(sp)
 d58:	6902                	ld	s2,0(sp)
 d5a:	6105                	addi	sp,sp,32
 d5c:	8082                	ret
    current_thread->lastTime = ctime();
 d5e:	fffff097          	auipc	ra,0xfffff
 d62:	736080e7          	jalr	1846(ra) # 494 <ctime>
 d66:	00001797          	auipc	a5,0x1
 d6a:	2b27b783          	ld	a5,690(a5) # 2018 <current_thread>
 d6e:	eb88                	sd	a0,16(a5)
 d70:	b7d1                	j	d34 <ulthread_yield+0x3c>

0000000000000d72 <ulthread_destroy>:

/* Destroy thread */
void ulthread_destroy(void)
{
 d72:	1101                	addi	sp,sp,-32
 d74:	ec06                	sd	ra,24(sp)
 d76:	e822                	sd	s0,16(sp)
 d78:	e426                	sd	s1,8(sp)
 d7a:	e04a                	sd	s2,0(sp)
 d7c:	1000                	addi	s0,sp,32
  memset(&current_thread->context, 0, sizeof(current_thread->context));
 d7e:	00001497          	auipc	s1,0x1
 d82:	29a48493          	addi	s1,s1,666 # 2018 <current_thread>
 d86:	6088                	ld	a0,0(s1)
 d88:	07000613          	li	a2,112
 d8c:	4581                	li	a1,0
 d8e:	0561                	addi	a0,a0,24
 d90:	fffff097          	auipc	ra,0xfffff
 d94:	46a080e7          	jalr	1130(ra) # 1fa <memset>
  current_thread->sp = 0;
 d98:	609c                	ld	a5,0(s1)
 d9a:	0007a423          	sw	zero,8(a5)
  current_thread->priority = -1;
 d9e:	577d                	li	a4,-1
 da0:	c7d8                	sw	a4,12(a5)
  current_thread->state = FREE;
 da2:	0007a023          	sw	zero,0(a5)

  struct ulthread *temp = current_thread;
 da6:	0004b903          	ld	s2,0(s1)

  printf("[*] ultdestroy(tid: %d)\n", get_current_tid());
 daa:	00492583          	lw	a1,4(s2)
 dae:	00000517          	auipc	a0,0x0
 db2:	26a50513          	addi	a0,a0,618 # 1018 <digits+0xa8>
 db6:	00000097          	auipc	ra,0x0
 dba:	9ae080e7          	jalr	-1618(ra) # 764 <printf>
  current_thread = scheduler_thread;
 dbe:	00001597          	auipc	a1,0x1
 dc2:	2525b583          	ld	a1,594(a1) # 2010 <scheduler_thread>
 dc6:	e08c                	sd	a1,0(s1)
  ulthread_context_switch(&temp->context, &scheduler_thread->context);
 dc8:	05e1                	addi	a1,a1,24
 dca:	01890513          	addi	a0,s2,24
 dce:	00000097          	auipc	ra,0x0
 dd2:	014080e7          	jalr	20(ra) # de2 <ulthread_context_switch>
}
 dd6:	60e2                	ld	ra,24(sp)
 dd8:	6442                	ld	s0,16(sp)
 dda:	64a2                	ld	s1,8(sp)
 ddc:	6902                	ld	s2,0(sp)
 dde:	6105                	addi	sp,sp,32
 de0:	8082                	ret

0000000000000de2 <ulthread_context_switch>:
 de2:	00153023          	sd	ra,0(a0)
 de6:	00253423          	sd	sp,8(a0)
 dea:	e900                	sd	s0,16(a0)
 dec:	ed04                	sd	s1,24(a0)
 dee:	03253023          	sd	s2,32(a0)
 df2:	03353423          	sd	s3,40(a0)
 df6:	03453823          	sd	s4,48(a0)
 dfa:	03553c23          	sd	s5,56(a0)
 dfe:	05653023          	sd	s6,64(a0)
 e02:	05753423          	sd	s7,72(a0)
 e06:	05853823          	sd	s8,80(a0)
 e0a:	05953c23          	sd	s9,88(a0)
 e0e:	07a53023          	sd	s10,96(a0)
 e12:	07b53423          	sd	s11,104(a0)
 e16:	0005b083          	ld	ra,0(a1)
 e1a:	0085b103          	ld	sp,8(a1)
 e1e:	6980                	ld	s0,16(a1)
 e20:	6d84                	ld	s1,24(a1)
 e22:	0205b903          	ld	s2,32(a1)
 e26:	0285b983          	ld	s3,40(a1)
 e2a:	0305ba03          	ld	s4,48(a1)
 e2e:	0385ba83          	ld	s5,56(a1)
 e32:	0405bb03          	ld	s6,64(a1)
 e36:	0485bb83          	ld	s7,72(a1)
 e3a:	0505bc03          	ld	s8,80(a1)
 e3e:	0585bc83          	ld	s9,88(a1)
 e42:	0605bd03          	ld	s10,96(a1)
 e46:	0685bd83          	ld	s11,104(a1)
 e4a:	6546                	ld	a0,80(sp)
 e4c:	6586                	ld	a1,64(sp)
 e4e:	7642                	ld	a2,48(sp)
 e50:	7682                	ld	a3,32(sp)
 e52:	6742                	ld	a4,16(sp)
 e54:	6782                	ld	a5,0(sp)
 e56:	8082                	ret
