
user/_test4:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <ul_start_func>:
uint64 get_current_time(void) {
    return ctime();
}

/* Simple example that allocates heap memory and accesses it. */
void ul_start_func(int a1) {
   0:	7179                	addi	sp,sp,-48
   2:	f406                	sd	ra,40(sp)
   4:	f022                	sd	s0,32(sp)
   6:	ec26                	sd	s1,24(sp)
   8:	e84a                	sd	s2,16(sp)
   a:	e44e                	sd	s3,8(sp)
   c:	e052                	sd	s4,0(sp)
   e:	1800                	addi	s0,sp,48
  10:	84aa                	mv	s1,a0
    printf("[.] started the thread function (tid = %d, a1 = %d)\n", 
  12:	00001097          	auipc	ra,0x1
  16:	8d4080e7          	jalr	-1836(ra) # 8e6 <get_current_tid>
  1a:	85aa                	mv	a1,a0
  1c:	8626                	mv	a2,s1
  1e:	00001517          	auipc	a0,0x1
  22:	e2250513          	addi	a0,a0,-478 # e40 <ulthread_context_switch+0x7a>
  26:	00000097          	auipc	ra,0x0
  2a:	722080e7          	jalr	1826(ra) # 748 <printf>
    return ctime();
  2e:	00000097          	auipc	ra,0x0
  32:	44a080e7          	jalr	1098(ra) # 478 <ctime>
  36:	84aa                	mv	s1,a0
        get_current_tid(), a1);
    
    uint64 start_time = get_current_time();
    uint64 prev_time = start_time;

    int scheduling_rounds = 0;
  38:	4901                	li	s2,0
    while (scheduling_rounds < 5) {
  3a:	4a15                	li	s4,5
        /* If 10000 cycles have passed, yield the CPU. */
        if ((get_current_time() - prev_time) >= 10000) {
  3c:	6989                	lui	s3,0x2
  3e:	70f98993          	addi	s3,s3,1807 # 270f <stacks+0x6ef>
    while (scheduling_rounds < 5) {
  42:	03490463          	beq	s2,s4,6a <ul_start_func+0x6a>
    return ctime();
  46:	00000097          	auipc	ra,0x0
  4a:	432080e7          	jalr	1074(ra) # 478 <ctime>
        if ((get_current_time() - prev_time) >= 10000) {
  4e:	8d05                	sub	a0,a0,s1
  50:	fea9f9e3          	bgeu	s3,a0,42 <ul_start_func+0x42>
            ulthread_yield();
  54:	00001097          	auipc	ra,0x1
  58:	c88080e7          	jalr	-888(ra) # cdc <ulthread_yield>
    return ctime();
  5c:	00000097          	auipc	ra,0x0
  60:	41c080e7          	jalr	1052(ra) # 478 <ctime>
  64:	84aa                	mv	s1,a0
            /* Get time using ctime() */
            prev_time = get_current_time();
            scheduling_rounds++;
  66:	2905                	addiw	s2,s2,1
  68:	bfe9                	j	42 <ul_start_func+0x42>
        }
    }

    /* Notify for a thread exit. */
    ulthread_destroy();
  6a:	00001097          	auipc	ra,0x1
  6e:	cec080e7          	jalr	-788(ra) # d56 <ulthread_destroy>
}
  72:	70a2                	ld	ra,40(sp)
  74:	7402                	ld	s0,32(sp)
  76:	64e2                	ld	s1,24(sp)
  78:	6942                	ld	s2,16(sp)
  7a:	69a2                	ld	s3,8(sp)
  7c:	6a02                	ld	s4,0(sp)
  7e:	6145                	addi	sp,sp,48
  80:	8082                	ret

0000000000000082 <get_current_time>:
uint64 get_current_time(void) {
  82:	1141                	addi	sp,sp,-16
  84:	e406                	sd	ra,8(sp)
  86:	e022                	sd	s0,0(sp)
  88:	0800                	addi	s0,sp,16
    return ctime();
  8a:	00000097          	auipc	ra,0x0
  8e:	3ee080e7          	jalr	1006(ra) # 478 <ctime>
}
  92:	60a2                	ld	ra,8(sp)
  94:	6402                	ld	s0,0(sp)
  96:	0141                	addi	sp,sp,16
  98:	8082                	ret

000000000000009a <main>:

int
main(int argc, char *argv[])
{
  9a:	711d                	addi	sp,sp,-96
  9c:	ec86                	sd	ra,88(sp)
  9e:	e8a2                	sd	s0,80(sp)
  a0:	e4a6                	sd	s1,72(sp)
  a2:	e0ca                	sd	s2,64(sp)
  a4:	fc4e                	sd	s3,56(sp)
  a6:	f852                	sd	s4,48(sp)
  a8:	1080                	addi	s0,sp,96
    /* Clear the stack region */
    memset(&stacks, 0, sizeof(stacks));
  aa:	00064637          	lui	a2,0x64
  ae:	4581                	li	a1,0
  b0:	00002517          	auipc	a0,0x2
  b4:	f7050513          	addi	a0,a0,-144 # 2020 <stacks>
  b8:	00000097          	auipc	ra,0x0
  bc:	126080e7          	jalr	294(ra) # 1de <memset>

    /* Initialize the user-level threading library */
    ulthread_init(ROUNDROBIN);
  c0:	4501                	li	a0,0
  c2:	00001097          	auipc	ra,0x1
  c6:	a9c080e7          	jalr	-1380(ra) # b5e <ulthread_init>

    /* Create a user-level thread */
    uint64 args[6] = {1,1,1,1,0,0};
  ca:	00001797          	auipc	a5,0x1
  ce:	dee78793          	addi	a5,a5,-530 # eb8 <ulthread_context_switch+0xf2>
  d2:	6388                	ld	a0,0(a5)
  d4:	678c                	ld	a1,8(a5)
  d6:	6b90                	ld	a2,16(a5)
  d8:	6f94                	ld	a3,24(a5)
  da:	7398                	ld	a4,32(a5)
  dc:	779c                	ld	a5,40(a5)
  de:	faa43023          	sd	a0,-96(s0)
  e2:	fab43423          	sd	a1,-88(s0)
  e6:	fac43823          	sd	a2,-80(s0)
  ea:	fad43c23          	sd	a3,-72(s0)
  ee:	fce43023          	sd	a4,-64(s0)
  f2:	fcf43423          	sd	a5,-56(s0)
    for (int i = 0; i < 3; i++)
  f6:	00003497          	auipc	s1,0x3
  fa:	f2a48493          	addi	s1,s1,-214 # 3020 <stacks+0x1000>
  fe:	00006a17          	auipc	s4,0x6
 102:	f22a0a13          	addi	s4,s4,-222 # 6020 <stacks+0x4000>
        ulthread_create((uint64) ul_start_func, (uint64) (stacks+((i+1)*PGSIZE)), args, -1);
 106:	00000997          	auipc	s3,0x0
 10a:	efa98993          	addi	s3,s3,-262 # 0 <ul_start_func>
    for (int i = 0; i < 3; i++)
 10e:	6905                	lui	s2,0x1
        ulthread_create((uint64) ul_start_func, (uint64) (stacks+((i+1)*PGSIZE)), args, -1);
 110:	56fd                	li	a3,-1
 112:	fa040613          	addi	a2,s0,-96
 116:	85a6                	mv	a1,s1
 118:	854e                	mv	a0,s3
 11a:	00001097          	auipc	ra,0x1
 11e:	a9e080e7          	jalr	-1378(ra) # bb8 <ulthread_create>
    for (int i = 0; i < 3; i++)
 122:	94ca                	add	s1,s1,s2
 124:	ff4496e3          	bne	s1,s4,110 <main+0x76>

    /* Schedule all of the threads */
    ulthread_schedule();
 128:	00001097          	auipc	ra,0x1
 12c:	b70080e7          	jalr	-1168(ra) # c98 <ulthread_schedule>

    printf("[*] User-Level Threading Test #4 (RR Collaborative) Complete.\n");
 130:	00001517          	auipc	a0,0x1
 134:	d4850513          	addi	a0,a0,-696 # e78 <ulthread_context_switch+0xb2>
 138:	00000097          	auipc	ra,0x0
 13c:	610080e7          	jalr	1552(ra) # 748 <printf>
    return 0;
 140:	4501                	li	a0,0
 142:	60e6                	ld	ra,88(sp)
 144:	6446                	ld	s0,80(sp)
 146:	64a6                	ld	s1,72(sp)
 148:	6906                	ld	s2,64(sp)
 14a:	79e2                	ld	s3,56(sp)
 14c:	7a42                	ld	s4,48(sp)
 14e:	6125                	addi	sp,sp,96
 150:	8082                	ret

0000000000000152 <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
 152:	1141                	addi	sp,sp,-16
 154:	e406                	sd	ra,8(sp)
 156:	e022                	sd	s0,0(sp)
 158:	0800                	addi	s0,sp,16
  extern int main();
  main();
 15a:	00000097          	auipc	ra,0x0
 15e:	f40080e7          	jalr	-192(ra) # 9a <main>
  exit(0);
 162:	4501                	li	a0,0
 164:	00000097          	auipc	ra,0x0
 168:	274080e7          	jalr	628(ra) # 3d8 <exit>

000000000000016c <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 16c:	1141                	addi	sp,sp,-16
 16e:	e422                	sd	s0,8(sp)
 170:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 172:	87aa                	mv	a5,a0
 174:	0585                	addi	a1,a1,1
 176:	0785                	addi	a5,a5,1
 178:	fff5c703          	lbu	a4,-1(a1)
 17c:	fee78fa3          	sb	a4,-1(a5)
 180:	fb75                	bnez	a4,174 <strcpy+0x8>
    ;
  return os;
}
 182:	6422                	ld	s0,8(sp)
 184:	0141                	addi	sp,sp,16
 186:	8082                	ret

0000000000000188 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 188:	1141                	addi	sp,sp,-16
 18a:	e422                	sd	s0,8(sp)
 18c:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 18e:	00054783          	lbu	a5,0(a0)
 192:	cb91                	beqz	a5,1a6 <strcmp+0x1e>
 194:	0005c703          	lbu	a4,0(a1)
 198:	00f71763          	bne	a4,a5,1a6 <strcmp+0x1e>
    p++, q++;
 19c:	0505                	addi	a0,a0,1
 19e:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 1a0:	00054783          	lbu	a5,0(a0)
 1a4:	fbe5                	bnez	a5,194 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 1a6:	0005c503          	lbu	a0,0(a1)
}
 1aa:	40a7853b          	subw	a0,a5,a0
 1ae:	6422                	ld	s0,8(sp)
 1b0:	0141                	addi	sp,sp,16
 1b2:	8082                	ret

00000000000001b4 <strlen>:

uint
strlen(const char *s)
{
 1b4:	1141                	addi	sp,sp,-16
 1b6:	e422                	sd	s0,8(sp)
 1b8:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 1ba:	00054783          	lbu	a5,0(a0)
 1be:	cf91                	beqz	a5,1da <strlen+0x26>
 1c0:	0505                	addi	a0,a0,1
 1c2:	87aa                	mv	a5,a0
 1c4:	86be                	mv	a3,a5
 1c6:	0785                	addi	a5,a5,1
 1c8:	fff7c703          	lbu	a4,-1(a5)
 1cc:	ff65                	bnez	a4,1c4 <strlen+0x10>
 1ce:	40a6853b          	subw	a0,a3,a0
 1d2:	2505                	addiw	a0,a0,1
    ;
  return n;
}
 1d4:	6422                	ld	s0,8(sp)
 1d6:	0141                	addi	sp,sp,16
 1d8:	8082                	ret
  for(n = 0; s[n]; n++)
 1da:	4501                	li	a0,0
 1dc:	bfe5                	j	1d4 <strlen+0x20>

00000000000001de <memset>:

void*
memset(void *dst, int c, uint n)
{
 1de:	1141                	addi	sp,sp,-16
 1e0:	e422                	sd	s0,8(sp)
 1e2:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 1e4:	ca19                	beqz	a2,1fa <memset+0x1c>
 1e6:	87aa                	mv	a5,a0
 1e8:	1602                	slli	a2,a2,0x20
 1ea:	9201                	srli	a2,a2,0x20
 1ec:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 1f0:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 1f4:	0785                	addi	a5,a5,1
 1f6:	fee79de3          	bne	a5,a4,1f0 <memset+0x12>
  }
  return dst;
}
 1fa:	6422                	ld	s0,8(sp)
 1fc:	0141                	addi	sp,sp,16
 1fe:	8082                	ret

0000000000000200 <strchr>:

char*
strchr(const char *s, char c)
{
 200:	1141                	addi	sp,sp,-16
 202:	e422                	sd	s0,8(sp)
 204:	0800                	addi	s0,sp,16
  for(; *s; s++)
 206:	00054783          	lbu	a5,0(a0)
 20a:	cb99                	beqz	a5,220 <strchr+0x20>
    if(*s == c)
 20c:	00f58763          	beq	a1,a5,21a <strchr+0x1a>
  for(; *s; s++)
 210:	0505                	addi	a0,a0,1
 212:	00054783          	lbu	a5,0(a0)
 216:	fbfd                	bnez	a5,20c <strchr+0xc>
      return (char*)s;
  return 0;
 218:	4501                	li	a0,0
}
 21a:	6422                	ld	s0,8(sp)
 21c:	0141                	addi	sp,sp,16
 21e:	8082                	ret
  return 0;
 220:	4501                	li	a0,0
 222:	bfe5                	j	21a <strchr+0x1a>

0000000000000224 <gets>:

char*
gets(char *buf, int max)
{
 224:	711d                	addi	sp,sp,-96
 226:	ec86                	sd	ra,88(sp)
 228:	e8a2                	sd	s0,80(sp)
 22a:	e4a6                	sd	s1,72(sp)
 22c:	e0ca                	sd	s2,64(sp)
 22e:	fc4e                	sd	s3,56(sp)
 230:	f852                	sd	s4,48(sp)
 232:	f456                	sd	s5,40(sp)
 234:	f05a                	sd	s6,32(sp)
 236:	ec5e                	sd	s7,24(sp)
 238:	1080                	addi	s0,sp,96
 23a:	8baa                	mv	s7,a0
 23c:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 23e:	892a                	mv	s2,a0
 240:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 242:	4aa9                	li	s5,10
 244:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 246:	89a6                	mv	s3,s1
 248:	2485                	addiw	s1,s1,1
 24a:	0344d863          	bge	s1,s4,27a <gets+0x56>
    cc = read(0, &c, 1);
 24e:	4605                	li	a2,1
 250:	faf40593          	addi	a1,s0,-81
 254:	4501                	li	a0,0
 256:	00000097          	auipc	ra,0x0
 25a:	19a080e7          	jalr	410(ra) # 3f0 <read>
    if(cc < 1)
 25e:	00a05e63          	blez	a0,27a <gets+0x56>
    buf[i++] = c;
 262:	faf44783          	lbu	a5,-81(s0)
 266:	00f90023          	sb	a5,0(s2) # 1000 <digits+0xb8>
    if(c == '\n' || c == '\r')
 26a:	01578763          	beq	a5,s5,278 <gets+0x54>
 26e:	0905                	addi	s2,s2,1
 270:	fd679be3          	bne	a5,s6,246 <gets+0x22>
  for(i=0; i+1 < max; ){
 274:	89a6                	mv	s3,s1
 276:	a011                	j	27a <gets+0x56>
 278:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 27a:	99de                	add	s3,s3,s7
 27c:	00098023          	sb	zero,0(s3)
  return buf;
}
 280:	855e                	mv	a0,s7
 282:	60e6                	ld	ra,88(sp)
 284:	6446                	ld	s0,80(sp)
 286:	64a6                	ld	s1,72(sp)
 288:	6906                	ld	s2,64(sp)
 28a:	79e2                	ld	s3,56(sp)
 28c:	7a42                	ld	s4,48(sp)
 28e:	7aa2                	ld	s5,40(sp)
 290:	7b02                	ld	s6,32(sp)
 292:	6be2                	ld	s7,24(sp)
 294:	6125                	addi	sp,sp,96
 296:	8082                	ret

0000000000000298 <stat>:

int
stat(const char *n, struct stat *st)
{
 298:	1101                	addi	sp,sp,-32
 29a:	ec06                	sd	ra,24(sp)
 29c:	e822                	sd	s0,16(sp)
 29e:	e426                	sd	s1,8(sp)
 2a0:	e04a                	sd	s2,0(sp)
 2a2:	1000                	addi	s0,sp,32
 2a4:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 2a6:	4581                	li	a1,0
 2a8:	00000097          	auipc	ra,0x0
 2ac:	170080e7          	jalr	368(ra) # 418 <open>
  if(fd < 0)
 2b0:	02054563          	bltz	a0,2da <stat+0x42>
 2b4:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 2b6:	85ca                	mv	a1,s2
 2b8:	00000097          	auipc	ra,0x0
 2bc:	178080e7          	jalr	376(ra) # 430 <fstat>
 2c0:	892a                	mv	s2,a0
  close(fd);
 2c2:	8526                	mv	a0,s1
 2c4:	00000097          	auipc	ra,0x0
 2c8:	13c080e7          	jalr	316(ra) # 400 <close>
  return r;
}
 2cc:	854a                	mv	a0,s2
 2ce:	60e2                	ld	ra,24(sp)
 2d0:	6442                	ld	s0,16(sp)
 2d2:	64a2                	ld	s1,8(sp)
 2d4:	6902                	ld	s2,0(sp)
 2d6:	6105                	addi	sp,sp,32
 2d8:	8082                	ret
    return -1;
 2da:	597d                	li	s2,-1
 2dc:	bfc5                	j	2cc <stat+0x34>

00000000000002de <atoi>:

int
atoi(const char *s)
{
 2de:	1141                	addi	sp,sp,-16
 2e0:	e422                	sd	s0,8(sp)
 2e2:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 2e4:	00054683          	lbu	a3,0(a0)
 2e8:	fd06879b          	addiw	a5,a3,-48
 2ec:	0ff7f793          	zext.b	a5,a5
 2f0:	4625                	li	a2,9
 2f2:	02f66863          	bltu	a2,a5,322 <atoi+0x44>
 2f6:	872a                	mv	a4,a0
  n = 0;
 2f8:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 2fa:	0705                	addi	a4,a4,1
 2fc:	0025179b          	slliw	a5,a0,0x2
 300:	9fa9                	addw	a5,a5,a0
 302:	0017979b          	slliw	a5,a5,0x1
 306:	9fb5                	addw	a5,a5,a3
 308:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 30c:	00074683          	lbu	a3,0(a4)
 310:	fd06879b          	addiw	a5,a3,-48
 314:	0ff7f793          	zext.b	a5,a5
 318:	fef671e3          	bgeu	a2,a5,2fa <atoi+0x1c>
  return n;
}
 31c:	6422                	ld	s0,8(sp)
 31e:	0141                	addi	sp,sp,16
 320:	8082                	ret
  n = 0;
 322:	4501                	li	a0,0
 324:	bfe5                	j	31c <atoi+0x3e>

0000000000000326 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 326:	1141                	addi	sp,sp,-16
 328:	e422                	sd	s0,8(sp)
 32a:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 32c:	02b57463          	bgeu	a0,a1,354 <memmove+0x2e>
    while(n-- > 0)
 330:	00c05f63          	blez	a2,34e <memmove+0x28>
 334:	1602                	slli	a2,a2,0x20
 336:	9201                	srli	a2,a2,0x20
 338:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 33c:	872a                	mv	a4,a0
      *dst++ = *src++;
 33e:	0585                	addi	a1,a1,1
 340:	0705                	addi	a4,a4,1
 342:	fff5c683          	lbu	a3,-1(a1)
 346:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 34a:	fee79ae3          	bne	a5,a4,33e <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 34e:	6422                	ld	s0,8(sp)
 350:	0141                	addi	sp,sp,16
 352:	8082                	ret
    dst += n;
 354:	00c50733          	add	a4,a0,a2
    src += n;
 358:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 35a:	fec05ae3          	blez	a2,34e <memmove+0x28>
 35e:	fff6079b          	addiw	a5,a2,-1 # 63fff <stacks+0x61fdf>
 362:	1782                	slli	a5,a5,0x20
 364:	9381                	srli	a5,a5,0x20
 366:	fff7c793          	not	a5,a5
 36a:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 36c:	15fd                	addi	a1,a1,-1
 36e:	177d                	addi	a4,a4,-1
 370:	0005c683          	lbu	a3,0(a1)
 374:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 378:	fee79ae3          	bne	a5,a4,36c <memmove+0x46>
 37c:	bfc9                	j	34e <memmove+0x28>

000000000000037e <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 37e:	1141                	addi	sp,sp,-16
 380:	e422                	sd	s0,8(sp)
 382:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 384:	ca05                	beqz	a2,3b4 <memcmp+0x36>
 386:	fff6069b          	addiw	a3,a2,-1
 38a:	1682                	slli	a3,a3,0x20
 38c:	9281                	srli	a3,a3,0x20
 38e:	0685                	addi	a3,a3,1
 390:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 392:	00054783          	lbu	a5,0(a0)
 396:	0005c703          	lbu	a4,0(a1)
 39a:	00e79863          	bne	a5,a4,3aa <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 39e:	0505                	addi	a0,a0,1
    p2++;
 3a0:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 3a2:	fed518e3          	bne	a0,a3,392 <memcmp+0x14>
  }
  return 0;
 3a6:	4501                	li	a0,0
 3a8:	a019                	j	3ae <memcmp+0x30>
      return *p1 - *p2;
 3aa:	40e7853b          	subw	a0,a5,a4
}
 3ae:	6422                	ld	s0,8(sp)
 3b0:	0141                	addi	sp,sp,16
 3b2:	8082                	ret
  return 0;
 3b4:	4501                	li	a0,0
 3b6:	bfe5                	j	3ae <memcmp+0x30>

00000000000003b8 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 3b8:	1141                	addi	sp,sp,-16
 3ba:	e406                	sd	ra,8(sp)
 3bc:	e022                	sd	s0,0(sp)
 3be:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 3c0:	00000097          	auipc	ra,0x0
 3c4:	f66080e7          	jalr	-154(ra) # 326 <memmove>
}
 3c8:	60a2                	ld	ra,8(sp)
 3ca:	6402                	ld	s0,0(sp)
 3cc:	0141                	addi	sp,sp,16
 3ce:	8082                	ret

00000000000003d0 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 3d0:	4885                	li	a7,1
 ecall
 3d2:	00000073          	ecall
 ret
 3d6:	8082                	ret

00000000000003d8 <exit>:
.global exit
exit:
 li a7, SYS_exit
 3d8:	4889                	li	a7,2
 ecall
 3da:	00000073          	ecall
 ret
 3de:	8082                	ret

00000000000003e0 <wait>:
.global wait
wait:
 li a7, SYS_wait
 3e0:	488d                	li	a7,3
 ecall
 3e2:	00000073          	ecall
 ret
 3e6:	8082                	ret

00000000000003e8 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 3e8:	4891                	li	a7,4
 ecall
 3ea:	00000073          	ecall
 ret
 3ee:	8082                	ret

00000000000003f0 <read>:
.global read
read:
 li a7, SYS_read
 3f0:	4895                	li	a7,5
 ecall
 3f2:	00000073          	ecall
 ret
 3f6:	8082                	ret

00000000000003f8 <write>:
.global write
write:
 li a7, SYS_write
 3f8:	48c1                	li	a7,16
 ecall
 3fa:	00000073          	ecall
 ret
 3fe:	8082                	ret

0000000000000400 <close>:
.global close
close:
 li a7, SYS_close
 400:	48d5                	li	a7,21
 ecall
 402:	00000073          	ecall
 ret
 406:	8082                	ret

0000000000000408 <kill>:
.global kill
kill:
 li a7, SYS_kill
 408:	4899                	li	a7,6
 ecall
 40a:	00000073          	ecall
 ret
 40e:	8082                	ret

0000000000000410 <exec>:
.global exec
exec:
 li a7, SYS_exec
 410:	489d                	li	a7,7
 ecall
 412:	00000073          	ecall
 ret
 416:	8082                	ret

0000000000000418 <open>:
.global open
open:
 li a7, SYS_open
 418:	48bd                	li	a7,15
 ecall
 41a:	00000073          	ecall
 ret
 41e:	8082                	ret

0000000000000420 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 420:	48c5                	li	a7,17
 ecall
 422:	00000073          	ecall
 ret
 426:	8082                	ret

0000000000000428 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 428:	48c9                	li	a7,18
 ecall
 42a:	00000073          	ecall
 ret
 42e:	8082                	ret

0000000000000430 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 430:	48a1                	li	a7,8
 ecall
 432:	00000073          	ecall
 ret
 436:	8082                	ret

0000000000000438 <link>:
.global link
link:
 li a7, SYS_link
 438:	48cd                	li	a7,19
 ecall
 43a:	00000073          	ecall
 ret
 43e:	8082                	ret

0000000000000440 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 440:	48d1                	li	a7,20
 ecall
 442:	00000073          	ecall
 ret
 446:	8082                	ret

0000000000000448 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 448:	48a5                	li	a7,9
 ecall
 44a:	00000073          	ecall
 ret
 44e:	8082                	ret

0000000000000450 <dup>:
.global dup
dup:
 li a7, SYS_dup
 450:	48a9                	li	a7,10
 ecall
 452:	00000073          	ecall
 ret
 456:	8082                	ret

0000000000000458 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 458:	48ad                	li	a7,11
 ecall
 45a:	00000073          	ecall
 ret
 45e:	8082                	ret

0000000000000460 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 460:	48b1                	li	a7,12
 ecall
 462:	00000073          	ecall
 ret
 466:	8082                	ret

0000000000000468 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 468:	48b5                	li	a7,13
 ecall
 46a:	00000073          	ecall
 ret
 46e:	8082                	ret

0000000000000470 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 470:	48b9                	li	a7,14
 ecall
 472:	00000073          	ecall
 ret
 476:	8082                	ret

0000000000000478 <ctime>:
.global ctime
ctime:
 li a7, SYS_ctime
 478:	48d9                	li	a7,22
 ecall
 47a:	00000073          	ecall
 ret
 47e:	8082                	ret

0000000000000480 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 480:	1101                	addi	sp,sp,-32
 482:	ec06                	sd	ra,24(sp)
 484:	e822                	sd	s0,16(sp)
 486:	1000                	addi	s0,sp,32
 488:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 48c:	4605                	li	a2,1
 48e:	fef40593          	addi	a1,s0,-17
 492:	00000097          	auipc	ra,0x0
 496:	f66080e7          	jalr	-154(ra) # 3f8 <write>
}
 49a:	60e2                	ld	ra,24(sp)
 49c:	6442                	ld	s0,16(sp)
 49e:	6105                	addi	sp,sp,32
 4a0:	8082                	ret

00000000000004a2 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 4a2:	7139                	addi	sp,sp,-64
 4a4:	fc06                	sd	ra,56(sp)
 4a6:	f822                	sd	s0,48(sp)
 4a8:	f426                	sd	s1,40(sp)
 4aa:	f04a                	sd	s2,32(sp)
 4ac:	ec4e                	sd	s3,24(sp)
 4ae:	0080                	addi	s0,sp,64
 4b0:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 4b2:	c299                	beqz	a3,4b8 <printint+0x16>
 4b4:	0805c963          	bltz	a1,546 <printint+0xa4>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 4b8:	2581                	sext.w	a1,a1
  neg = 0;
 4ba:	4881                	li	a7,0
 4bc:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 4c0:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 4c2:	2601                	sext.w	a2,a2
 4c4:	00001517          	auipc	a0,0x1
 4c8:	a8450513          	addi	a0,a0,-1404 # f48 <digits>
 4cc:	883a                	mv	a6,a4
 4ce:	2705                	addiw	a4,a4,1
 4d0:	02c5f7bb          	remuw	a5,a1,a2
 4d4:	1782                	slli	a5,a5,0x20
 4d6:	9381                	srli	a5,a5,0x20
 4d8:	97aa                	add	a5,a5,a0
 4da:	0007c783          	lbu	a5,0(a5)
 4de:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 4e2:	0005879b          	sext.w	a5,a1
 4e6:	02c5d5bb          	divuw	a1,a1,a2
 4ea:	0685                	addi	a3,a3,1
 4ec:	fec7f0e3          	bgeu	a5,a2,4cc <printint+0x2a>
  if(neg)
 4f0:	00088c63          	beqz	a7,508 <printint+0x66>
    buf[i++] = '-';
 4f4:	fd070793          	addi	a5,a4,-48
 4f8:	00878733          	add	a4,a5,s0
 4fc:	02d00793          	li	a5,45
 500:	fef70823          	sb	a5,-16(a4)
 504:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 508:	02e05863          	blez	a4,538 <printint+0x96>
 50c:	fc040793          	addi	a5,s0,-64
 510:	00e78933          	add	s2,a5,a4
 514:	fff78993          	addi	s3,a5,-1
 518:	99ba                	add	s3,s3,a4
 51a:	377d                	addiw	a4,a4,-1
 51c:	1702                	slli	a4,a4,0x20
 51e:	9301                	srli	a4,a4,0x20
 520:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 524:	fff94583          	lbu	a1,-1(s2)
 528:	8526                	mv	a0,s1
 52a:	00000097          	auipc	ra,0x0
 52e:	f56080e7          	jalr	-170(ra) # 480 <putc>
  while(--i >= 0)
 532:	197d                	addi	s2,s2,-1
 534:	ff3918e3          	bne	s2,s3,524 <printint+0x82>
}
 538:	70e2                	ld	ra,56(sp)
 53a:	7442                	ld	s0,48(sp)
 53c:	74a2                	ld	s1,40(sp)
 53e:	7902                	ld	s2,32(sp)
 540:	69e2                	ld	s3,24(sp)
 542:	6121                	addi	sp,sp,64
 544:	8082                	ret
    x = -xx;
 546:	40b005bb          	negw	a1,a1
    neg = 1;
 54a:	4885                	li	a7,1
    x = -xx;
 54c:	bf85                	j	4bc <printint+0x1a>

000000000000054e <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 54e:	715d                	addi	sp,sp,-80
 550:	e486                	sd	ra,72(sp)
 552:	e0a2                	sd	s0,64(sp)
 554:	fc26                	sd	s1,56(sp)
 556:	f84a                	sd	s2,48(sp)
 558:	f44e                	sd	s3,40(sp)
 55a:	f052                	sd	s4,32(sp)
 55c:	ec56                	sd	s5,24(sp)
 55e:	e85a                	sd	s6,16(sp)
 560:	e45e                	sd	s7,8(sp)
 562:	e062                	sd	s8,0(sp)
 564:	0880                	addi	s0,sp,80
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 566:	0005c903          	lbu	s2,0(a1)
 56a:	18090c63          	beqz	s2,702 <vprintf+0x1b4>
 56e:	8aaa                	mv	s5,a0
 570:	8bb2                	mv	s7,a2
 572:	00158493          	addi	s1,a1,1
  state = 0;
 576:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 578:	02500a13          	li	s4,37
 57c:	4b55                	li	s6,21
 57e:	a839                	j	59c <vprintf+0x4e>
        putc(fd, c);
 580:	85ca                	mv	a1,s2
 582:	8556                	mv	a0,s5
 584:	00000097          	auipc	ra,0x0
 588:	efc080e7          	jalr	-260(ra) # 480 <putc>
 58c:	a019                	j	592 <vprintf+0x44>
    } else if(state == '%'){
 58e:	01498d63          	beq	s3,s4,5a8 <vprintf+0x5a>
  for(i = 0; fmt[i]; i++){
 592:	0485                	addi	s1,s1,1
 594:	fff4c903          	lbu	s2,-1(s1)
 598:	16090563          	beqz	s2,702 <vprintf+0x1b4>
    if(state == 0){
 59c:	fe0999e3          	bnez	s3,58e <vprintf+0x40>
      if(c == '%'){
 5a0:	ff4910e3          	bne	s2,s4,580 <vprintf+0x32>
        state = '%';
 5a4:	89d2                	mv	s3,s4
 5a6:	b7f5                	j	592 <vprintf+0x44>
      if(c == 'd'){
 5a8:	13490263          	beq	s2,s4,6cc <vprintf+0x17e>
 5ac:	f9d9079b          	addiw	a5,s2,-99
 5b0:	0ff7f793          	zext.b	a5,a5
 5b4:	12fb6563          	bltu	s6,a5,6de <vprintf+0x190>
 5b8:	f9d9079b          	addiw	a5,s2,-99
 5bc:	0ff7f713          	zext.b	a4,a5
 5c0:	10eb6f63          	bltu	s6,a4,6de <vprintf+0x190>
 5c4:	00271793          	slli	a5,a4,0x2
 5c8:	00001717          	auipc	a4,0x1
 5cc:	92870713          	addi	a4,a4,-1752 # ef0 <ulthread_context_switch+0x12a>
 5d0:	97ba                	add	a5,a5,a4
 5d2:	439c                	lw	a5,0(a5)
 5d4:	97ba                	add	a5,a5,a4
 5d6:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
 5d8:	008b8913          	addi	s2,s7,8
 5dc:	4685                	li	a3,1
 5de:	4629                	li	a2,10
 5e0:	000ba583          	lw	a1,0(s7)
 5e4:	8556                	mv	a0,s5
 5e6:	00000097          	auipc	ra,0x0
 5ea:	ebc080e7          	jalr	-324(ra) # 4a2 <printint>
 5ee:	8bca                	mv	s7,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 5f0:	4981                	li	s3,0
 5f2:	b745                	j	592 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 5f4:	008b8913          	addi	s2,s7,8
 5f8:	4681                	li	a3,0
 5fa:	4629                	li	a2,10
 5fc:	000ba583          	lw	a1,0(s7)
 600:	8556                	mv	a0,s5
 602:	00000097          	auipc	ra,0x0
 606:	ea0080e7          	jalr	-352(ra) # 4a2 <printint>
 60a:	8bca                	mv	s7,s2
      state = 0;
 60c:	4981                	li	s3,0
 60e:	b751                	j	592 <vprintf+0x44>
        printint(fd, va_arg(ap, int), 16, 0);
 610:	008b8913          	addi	s2,s7,8
 614:	4681                	li	a3,0
 616:	4641                	li	a2,16
 618:	000ba583          	lw	a1,0(s7)
 61c:	8556                	mv	a0,s5
 61e:	00000097          	auipc	ra,0x0
 622:	e84080e7          	jalr	-380(ra) # 4a2 <printint>
 626:	8bca                	mv	s7,s2
      state = 0;
 628:	4981                	li	s3,0
 62a:	b7a5                	j	592 <vprintf+0x44>
        printptr(fd, va_arg(ap, uint64));
 62c:	008b8c13          	addi	s8,s7,8
 630:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 634:	03000593          	li	a1,48
 638:	8556                	mv	a0,s5
 63a:	00000097          	auipc	ra,0x0
 63e:	e46080e7          	jalr	-442(ra) # 480 <putc>
  putc(fd, 'x');
 642:	07800593          	li	a1,120
 646:	8556                	mv	a0,s5
 648:	00000097          	auipc	ra,0x0
 64c:	e38080e7          	jalr	-456(ra) # 480 <putc>
 650:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 652:	00001b97          	auipc	s7,0x1
 656:	8f6b8b93          	addi	s7,s7,-1802 # f48 <digits>
 65a:	03c9d793          	srli	a5,s3,0x3c
 65e:	97de                	add	a5,a5,s7
 660:	0007c583          	lbu	a1,0(a5)
 664:	8556                	mv	a0,s5
 666:	00000097          	auipc	ra,0x0
 66a:	e1a080e7          	jalr	-486(ra) # 480 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 66e:	0992                	slli	s3,s3,0x4
 670:	397d                	addiw	s2,s2,-1
 672:	fe0914e3          	bnez	s2,65a <vprintf+0x10c>
        printptr(fd, va_arg(ap, uint64));
 676:	8be2                	mv	s7,s8
      state = 0;
 678:	4981                	li	s3,0
 67a:	bf21                	j	592 <vprintf+0x44>
        s = va_arg(ap, char*);
 67c:	008b8993          	addi	s3,s7,8
 680:	000bb903          	ld	s2,0(s7)
        if(s == 0)
 684:	02090163          	beqz	s2,6a6 <vprintf+0x158>
        while(*s != 0){
 688:	00094583          	lbu	a1,0(s2)
 68c:	c9a5                	beqz	a1,6fc <vprintf+0x1ae>
          putc(fd, *s);
 68e:	8556                	mv	a0,s5
 690:	00000097          	auipc	ra,0x0
 694:	df0080e7          	jalr	-528(ra) # 480 <putc>
          s++;
 698:	0905                	addi	s2,s2,1
        while(*s != 0){
 69a:	00094583          	lbu	a1,0(s2)
 69e:	f9e5                	bnez	a1,68e <vprintf+0x140>
        s = va_arg(ap, char*);
 6a0:	8bce                	mv	s7,s3
      state = 0;
 6a2:	4981                	li	s3,0
 6a4:	b5fd                	j	592 <vprintf+0x44>
          s = "(null)";
 6a6:	00001917          	auipc	s2,0x1
 6aa:	84290913          	addi	s2,s2,-1982 # ee8 <ulthread_context_switch+0x122>
        while(*s != 0){
 6ae:	02800593          	li	a1,40
 6b2:	bff1                	j	68e <vprintf+0x140>
        putc(fd, va_arg(ap, uint));
 6b4:	008b8913          	addi	s2,s7,8
 6b8:	000bc583          	lbu	a1,0(s7)
 6bc:	8556                	mv	a0,s5
 6be:	00000097          	auipc	ra,0x0
 6c2:	dc2080e7          	jalr	-574(ra) # 480 <putc>
 6c6:	8bca                	mv	s7,s2
      state = 0;
 6c8:	4981                	li	s3,0
 6ca:	b5e1                	j	592 <vprintf+0x44>
        putc(fd, c);
 6cc:	02500593          	li	a1,37
 6d0:	8556                	mv	a0,s5
 6d2:	00000097          	auipc	ra,0x0
 6d6:	dae080e7          	jalr	-594(ra) # 480 <putc>
      state = 0;
 6da:	4981                	li	s3,0
 6dc:	bd5d                	j	592 <vprintf+0x44>
        putc(fd, '%');
 6de:	02500593          	li	a1,37
 6e2:	8556                	mv	a0,s5
 6e4:	00000097          	auipc	ra,0x0
 6e8:	d9c080e7          	jalr	-612(ra) # 480 <putc>
        putc(fd, c);
 6ec:	85ca                	mv	a1,s2
 6ee:	8556                	mv	a0,s5
 6f0:	00000097          	auipc	ra,0x0
 6f4:	d90080e7          	jalr	-624(ra) # 480 <putc>
      state = 0;
 6f8:	4981                	li	s3,0
 6fa:	bd61                	j	592 <vprintf+0x44>
        s = va_arg(ap, char*);
 6fc:	8bce                	mv	s7,s3
      state = 0;
 6fe:	4981                	li	s3,0
 700:	bd49                	j	592 <vprintf+0x44>
    }
  }
}
 702:	60a6                	ld	ra,72(sp)
 704:	6406                	ld	s0,64(sp)
 706:	74e2                	ld	s1,56(sp)
 708:	7942                	ld	s2,48(sp)
 70a:	79a2                	ld	s3,40(sp)
 70c:	7a02                	ld	s4,32(sp)
 70e:	6ae2                	ld	s5,24(sp)
 710:	6b42                	ld	s6,16(sp)
 712:	6ba2                	ld	s7,8(sp)
 714:	6c02                	ld	s8,0(sp)
 716:	6161                	addi	sp,sp,80
 718:	8082                	ret

000000000000071a <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 71a:	715d                	addi	sp,sp,-80
 71c:	ec06                	sd	ra,24(sp)
 71e:	e822                	sd	s0,16(sp)
 720:	1000                	addi	s0,sp,32
 722:	e010                	sd	a2,0(s0)
 724:	e414                	sd	a3,8(s0)
 726:	e818                	sd	a4,16(s0)
 728:	ec1c                	sd	a5,24(s0)
 72a:	03043023          	sd	a6,32(s0)
 72e:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 732:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 736:	8622                	mv	a2,s0
 738:	00000097          	auipc	ra,0x0
 73c:	e16080e7          	jalr	-490(ra) # 54e <vprintf>
}
 740:	60e2                	ld	ra,24(sp)
 742:	6442                	ld	s0,16(sp)
 744:	6161                	addi	sp,sp,80
 746:	8082                	ret

0000000000000748 <printf>:

void
printf(const char *fmt, ...)
{
 748:	711d                	addi	sp,sp,-96
 74a:	ec06                	sd	ra,24(sp)
 74c:	e822                	sd	s0,16(sp)
 74e:	1000                	addi	s0,sp,32
 750:	e40c                	sd	a1,8(s0)
 752:	e810                	sd	a2,16(s0)
 754:	ec14                	sd	a3,24(s0)
 756:	f018                	sd	a4,32(s0)
 758:	f41c                	sd	a5,40(s0)
 75a:	03043823          	sd	a6,48(s0)
 75e:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 762:	00840613          	addi	a2,s0,8
 766:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 76a:	85aa                	mv	a1,a0
 76c:	4505                	li	a0,1
 76e:	00000097          	auipc	ra,0x0
 772:	de0080e7          	jalr	-544(ra) # 54e <vprintf>
}
 776:	60e2                	ld	ra,24(sp)
 778:	6442                	ld	s0,16(sp)
 77a:	6125                	addi	sp,sp,96
 77c:	8082                	ret

000000000000077e <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 77e:	1141                	addi	sp,sp,-16
 780:	e422                	sd	s0,8(sp)
 782:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 784:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 788:	00002797          	auipc	a5,0x2
 78c:	8787b783          	ld	a5,-1928(a5) # 2000 <freep>
 790:	a02d                	j	7ba <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 792:	4618                	lw	a4,8(a2)
 794:	9f2d                	addw	a4,a4,a1
 796:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 79a:	6398                	ld	a4,0(a5)
 79c:	6310                	ld	a2,0(a4)
 79e:	a83d                	j	7dc <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 7a0:	ff852703          	lw	a4,-8(a0)
 7a4:	9f31                	addw	a4,a4,a2
 7a6:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 7a8:	ff053683          	ld	a3,-16(a0)
 7ac:	a091                	j	7f0 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7ae:	6398                	ld	a4,0(a5)
 7b0:	00e7e463          	bltu	a5,a4,7b8 <free+0x3a>
 7b4:	00e6ea63          	bltu	a3,a4,7c8 <free+0x4a>
{
 7b8:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7ba:	fed7fae3          	bgeu	a5,a3,7ae <free+0x30>
 7be:	6398                	ld	a4,0(a5)
 7c0:	00e6e463          	bltu	a3,a4,7c8 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7c4:	fee7eae3          	bltu	a5,a4,7b8 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 7c8:	ff852583          	lw	a1,-8(a0)
 7cc:	6390                	ld	a2,0(a5)
 7ce:	02059813          	slli	a6,a1,0x20
 7d2:	01c85713          	srli	a4,a6,0x1c
 7d6:	9736                	add	a4,a4,a3
 7d8:	fae60de3          	beq	a2,a4,792 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 7dc:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 7e0:	4790                	lw	a2,8(a5)
 7e2:	02061593          	slli	a1,a2,0x20
 7e6:	01c5d713          	srli	a4,a1,0x1c
 7ea:	973e                	add	a4,a4,a5
 7ec:	fae68ae3          	beq	a3,a4,7a0 <free+0x22>
    p->s.ptr = bp->s.ptr;
 7f0:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 7f2:	00002717          	auipc	a4,0x2
 7f6:	80f73723          	sd	a5,-2034(a4) # 2000 <freep>
}
 7fa:	6422                	ld	s0,8(sp)
 7fc:	0141                	addi	sp,sp,16
 7fe:	8082                	ret

0000000000000800 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 800:	7139                	addi	sp,sp,-64
 802:	fc06                	sd	ra,56(sp)
 804:	f822                	sd	s0,48(sp)
 806:	f426                	sd	s1,40(sp)
 808:	f04a                	sd	s2,32(sp)
 80a:	ec4e                	sd	s3,24(sp)
 80c:	e852                	sd	s4,16(sp)
 80e:	e456                	sd	s5,8(sp)
 810:	e05a                	sd	s6,0(sp)
 812:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 814:	02051493          	slli	s1,a0,0x20
 818:	9081                	srli	s1,s1,0x20
 81a:	04bd                	addi	s1,s1,15
 81c:	8091                	srli	s1,s1,0x4
 81e:	0014899b          	addiw	s3,s1,1
 822:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 824:	00001517          	auipc	a0,0x1
 828:	7dc53503          	ld	a0,2012(a0) # 2000 <freep>
 82c:	c515                	beqz	a0,858 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 82e:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 830:	4798                	lw	a4,8(a5)
 832:	02977f63          	bgeu	a4,s1,870 <malloc+0x70>
  if(nu < 4096)
 836:	8a4e                	mv	s4,s3
 838:	0009871b          	sext.w	a4,s3
 83c:	6685                	lui	a3,0x1
 83e:	00d77363          	bgeu	a4,a3,844 <malloc+0x44>
 842:	6a05                	lui	s4,0x1
 844:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 848:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 84c:	00001917          	auipc	s2,0x1
 850:	7b490913          	addi	s2,s2,1972 # 2000 <freep>
  if(p == (char*)-1)
 854:	5afd                	li	s5,-1
 856:	a895                	j	8ca <malloc+0xca>
    base.s.ptr = freep = prevp = &base;
 858:	00065797          	auipc	a5,0x65
 85c:	7c878793          	addi	a5,a5,1992 # 66020 <base>
 860:	00001717          	auipc	a4,0x1
 864:	7af73023          	sd	a5,1952(a4) # 2000 <freep>
 868:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 86a:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 86e:	b7e1                	j	836 <malloc+0x36>
      if(p->s.size == nunits)
 870:	02e48c63          	beq	s1,a4,8a8 <malloc+0xa8>
        p->s.size -= nunits;
 874:	4137073b          	subw	a4,a4,s3
 878:	c798                	sw	a4,8(a5)
        p += p->s.size;
 87a:	02071693          	slli	a3,a4,0x20
 87e:	01c6d713          	srli	a4,a3,0x1c
 882:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 884:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 888:	00001717          	auipc	a4,0x1
 88c:	76a73c23          	sd	a0,1912(a4) # 2000 <freep>
      return (void*)(p + 1);
 890:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 894:	70e2                	ld	ra,56(sp)
 896:	7442                	ld	s0,48(sp)
 898:	74a2                	ld	s1,40(sp)
 89a:	7902                	ld	s2,32(sp)
 89c:	69e2                	ld	s3,24(sp)
 89e:	6a42                	ld	s4,16(sp)
 8a0:	6aa2                	ld	s5,8(sp)
 8a2:	6b02                	ld	s6,0(sp)
 8a4:	6121                	addi	sp,sp,64
 8a6:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 8a8:	6398                	ld	a4,0(a5)
 8aa:	e118                	sd	a4,0(a0)
 8ac:	bff1                	j	888 <malloc+0x88>
  hp->s.size = nu;
 8ae:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 8b2:	0541                	addi	a0,a0,16
 8b4:	00000097          	auipc	ra,0x0
 8b8:	eca080e7          	jalr	-310(ra) # 77e <free>
  return freep;
 8bc:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 8c0:	d971                	beqz	a0,894 <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8c2:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 8c4:	4798                	lw	a4,8(a5)
 8c6:	fa9775e3          	bgeu	a4,s1,870 <malloc+0x70>
    if(p == freep)
 8ca:	00093703          	ld	a4,0(s2)
 8ce:	853e                	mv	a0,a5
 8d0:	fef719e3          	bne	a4,a5,8c2 <malloc+0xc2>
  p = sbrk(nu * sizeof(Header));
 8d4:	8552                	mv	a0,s4
 8d6:	00000097          	auipc	ra,0x0
 8da:	b8a080e7          	jalr	-1142(ra) # 460 <sbrk>
  if(p == (char*)-1)
 8de:	fd5518e3          	bne	a0,s5,8ae <malloc+0xae>
        return 0;
 8e2:	4501                	li	a0,0
 8e4:	bf45                	j	894 <malloc+0x94>

00000000000008e6 <get_current_tid>:
struct ulthread *scheduler_thread;
enum ulthread_scheduling_algorithm algorithm;

/* Get thread ID */
int get_current_tid(void)
{
 8e6:	1141                	addi	sp,sp,-16
 8e8:	e422                	sd	s0,8(sp)
 8ea:	0800                	addi	s0,sp,16
  return current_thread->tid;
}
 8ec:	00001797          	auipc	a5,0x1
 8f0:	72c7b783          	ld	a5,1836(a5) # 2018 <current_thread>
 8f4:	43c8                	lw	a0,4(a5)
 8f6:	6422                	ld	s0,8(sp)
 8f8:	0141                	addi	sp,sp,16
 8fa:	8082                	ret

00000000000008fc <roundRobin>:

void roundRobin(void)
{
 8fc:	715d                	addi	sp,sp,-80
 8fe:	e486                	sd	ra,72(sp)
 900:	e0a2                	sd	s0,64(sp)
 902:	fc26                	sd	s1,56(sp)
 904:	f84a                	sd	s2,48(sp)
 906:	f44e                	sd	s3,40(sp)
 908:	f052                	sd	s4,32(sp)
 90a:	ec56                	sd	s5,24(sp)
 90c:	e85a                	sd	s6,16(sp)
 90e:	e45e                	sd	s7,8(sp)
 910:	e062                	sd	s8,0(sp)
 912:	0880                	addi	s0,sp,80
        struct ulthread *temp = current_thread;
        current_thread = t;
        printf("[*] ultschedule (next tid: %d)\n", get_current_tid());
        ulthread_context_switch(&temp->context, &t->context);
      }
      if (t->state == YIELD)
 914:	4a09                	li	s4,2
      if (t->state == RUNNABLE && t != scheduler_thread)
 916:	00001b97          	auipc	s7,0x1
 91a:	6fab8b93          	addi	s7,s7,1786 # 2010 <scheduler_thread>
        struct ulthread *temp = current_thread;
 91e:	00001a97          	auipc	s5,0x1
 922:	6faa8a93          	addi	s5,s5,1786 # 2018 <current_thread>
        printf("[*] ultschedule (next tid: %d)\n", get_current_tid());
 926:	00000c17          	auipc	s8,0x0
 92a:	63ac0c13          	addi	s8,s8,1594 # f60 <digits+0x18>
    for (t = ulthreads; t < &ulthreads[MAXULTHREADS]; t++)
 92e:	00069997          	auipc	s3,0x69
 932:	c2298993          	addi	s3,s3,-990 # 69550 <ulthreads+0x3520>
 936:	a0b9                	j	984 <roundRobin+0x88>
      if (t->state == RUNNABLE && t != scheduler_thread)
 938:	000bb783          	ld	a5,0(s7)
 93c:	02978863          	beq	a5,s1,96c <roundRobin+0x70>
        struct ulthread *temp = current_thread;
 940:	000abb03          	ld	s6,0(s5)
        current_thread = t;
 944:	009ab023          	sd	s1,0(s5)
        printf("[*] ultschedule (next tid: %d)\n", get_current_tid());
 948:	40cc                	lw	a1,4(s1)
 94a:	8562                	mv	a0,s8
 94c:	00000097          	auipc	ra,0x0
 950:	dfc080e7          	jalr	-516(ra) # 748 <printf>
        ulthread_context_switch(&temp->context, &t->context);
 954:	01848593          	addi	a1,s1,24
 958:	018b0513          	addi	a0,s6,24
 95c:	00000097          	auipc	ra,0x0
 960:	46a080e7          	jalr	1130(ra) # dc6 <ulthread_context_switch>
        threadAvailable = true;
 964:	874a                	mv	a4,s2
 966:	a811                	j	97a <roundRobin+0x7e>
      {
        t->state = RUNNABLE;
 968:	0124a023          	sw	s2,0(s1)
    for (t = ulthreads; t < &ulthreads[MAXULTHREADS]; t++)
 96c:	08848493          	addi	s1,s1,136
 970:	01348963          	beq	s1,s3,982 <roundRobin+0x86>
      if (t->state == RUNNABLE && t != scheduler_thread)
 974:	409c                	lw	a5,0(s1)
 976:	fd2781e3          	beq	a5,s2,938 <roundRobin+0x3c>
      if (t->state == YIELD)
 97a:	409c                	lw	a5,0(s1)
 97c:	ff4798e3          	bne	a5,s4,96c <roundRobin+0x70>
 980:	b7e5                	j	968 <roundRobin+0x6c>
      }
    }
    if (!threadAvailable)
 982:	cb01                	beqz	a4,992 <roundRobin+0x96>
    bool threadAvailable = false;
 984:	4701                	li	a4,0
    for (t = ulthreads; t < &ulthreads[MAXULTHREADS]; t++)
 986:	00065497          	auipc	s1,0x65
 98a:	6aa48493          	addi	s1,s1,1706 # 66030 <ulthreads>
      if (t->state == RUNNABLE && t != scheduler_thread)
 98e:	4905                	li	s2,1
 990:	b7d5                	j	974 <roundRobin+0x78>
    {
      break;
    }
  }
}
 992:	60a6                	ld	ra,72(sp)
 994:	6406                	ld	s0,64(sp)
 996:	74e2                	ld	s1,56(sp)
 998:	7942                	ld	s2,48(sp)
 99a:	79a2                	ld	s3,40(sp)
 99c:	7a02                	ld	s4,32(sp)
 99e:	6ae2                	ld	s5,24(sp)
 9a0:	6b42                	ld	s6,16(sp)
 9a2:	6ba2                	ld	s7,8(sp)
 9a4:	6c02                	ld	s8,0(sp)
 9a6:	6161                	addi	sp,sp,80
 9a8:	8082                	ret

00000000000009aa <firstComeFirstServe>:

void firstComeFirstServe(void)
{
 9aa:	715d                	addi	sp,sp,-80
 9ac:	e486                	sd	ra,72(sp)
 9ae:	e0a2                	sd	s0,64(sp)
 9b0:	fc26                	sd	s1,56(sp)
 9b2:	f84a                	sd	s2,48(sp)
 9b4:	f44e                	sd	s3,40(sp)
 9b6:	f052                	sd	s4,32(sp)
 9b8:	ec56                	sd	s5,24(sp)
 9ba:	e85a                	sd	s6,16(sp)
 9bc:	e45e                	sd	s7,8(sp)
 9be:	e062                	sd	s8,0(sp)
 9c0:	0880                	addi	s0,sp,80
    uint64 oldest = __INT64_MAX__;
    int threadIndex = -1;
    int alternativeIndex = -1;
    for (t = ulthreads+1; t < &ulthreads[MAXULTHREADS]; t++)
    {
      if (t->state == RUNNABLE && t != scheduler_thread && t->lastTime < oldest)
 9c2:	00001b97          	auipc	s7,0x1
 9c6:	64eb8b93          	addi	s7,s7,1614 # 2010 <scheduler_thread>
    int alternativeIndex = -1;
 9ca:	5afd                	li	s5,-1
    uint64 oldest = __INT64_MAX__;
 9cc:	001adb13          	srli	s6,s5,0x1
      if (t->state == RUNNABLE && t != scheduler_thread && t->lastTime < oldest)
 9d0:	4485                	li	s1,1
        oldest = t->lastTime;
        threadIndex = t->tid;
        threadAvailable = true;
      }

      if (t->state == YIELD){
 9d2:	4989                	li	s3,2
    for (t = ulthreads+1; t < &ulthreads[MAXULTHREADS]; t++)
 9d4:	00069917          	auipc	s2,0x69
 9d8:	b7c90913          	addi	s2,s2,-1156 # 69550 <ulthreads+0x3520>
        break;
      }
      
    }
    label : 
      struct ulthread *temp = current_thread;
 9dc:	00001a17          	auipc	s4,0x1
 9e0:	63ca0a13          	addi	s4,s4,1596 # 2018 <current_thread>
 9e4:	a88d                	j	a56 <firstComeFirstServe+0xac>
      if (t->state == RUNNABLE && t != scheduler_thread && t->lastTime < oldest)
 9e6:	00f58963          	beq	a1,a5,9f8 <firstComeFirstServe+0x4e>
 9ea:	6b98                	ld	a4,16(a5)
 9ec:	00c77663          	bgeu	a4,a2,9f8 <firstComeFirstServe+0x4e>
        threadIndex = t->tid;
 9f0:	0047a803          	lw	a6,4(a5)
        oldest = t->lastTime;
 9f4:	863a                	mv	a2,a4
        threadAvailable = true;
 9f6:	8526                	mv	a0,s1
    for (t = ulthreads+1; t < &ulthreads[MAXULTHREADS]; t++)
 9f8:	08878793          	addi	a5,a5,136
 9fc:	01278a63          	beq	a5,s2,a10 <firstComeFirstServe+0x66>
      if (t->state == RUNNABLE && t != scheduler_thread && t->lastTime < oldest)
 a00:	4398                	lw	a4,0(a5)
 a02:	fe9702e3          	beq	a4,s1,9e6 <firstComeFirstServe+0x3c>
      if (t->state == YIELD){
 a06:	ff3719e3          	bne	a4,s3,9f8 <firstComeFirstServe+0x4e>
        t->state = RUNNABLE;
 a0a:	c384                	sw	s1,0(a5)
        alternativeIndex = t->tid;
 a0c:	43d4                	lw	a3,4(a5)
 a0e:	b7ed                	j	9f8 <firstComeFirstServe+0x4e>
    if (!threadAvailable)
 a10:	ed31                	bnez	a0,a6c <firstComeFirstServe+0xc2>
      if(alternativeIndex > 0){
 a12:	04d05f63          	blez	a3,a70 <firstComeFirstServe+0xc6>
      struct ulthread *temp = current_thread;
 a16:	000a3c03          	ld	s8,0(s4)
      current_thread = &ulthreads[threadIndex];
 a1a:	00469793          	slli	a5,a3,0x4
 a1e:	00d78733          	add	a4,a5,a3
 a22:	070e                	slli	a4,a4,0x3
 a24:	00065617          	auipc	a2,0x65
 a28:	60c60613          	addi	a2,a2,1548 # 66030 <ulthreads>
 a2c:	9732                	add	a4,a4,a2
 a2e:	00ea3023          	sd	a4,0(s4)
      printf("[*] ultschedule (next tid: %d), time = %d\n", get_current_tid());
 a32:	434c                	lw	a1,4(a4)
 a34:	00000517          	auipc	a0,0x0
 a38:	54c50513          	addi	a0,a0,1356 # f80 <digits+0x38>
 a3c:	00000097          	auipc	ra,0x0
 a40:	d0c080e7          	jalr	-756(ra) # 748 <printf>
      ulthread_context_switch(&temp->context, &current_thread->context);
 a44:	000a3583          	ld	a1,0(s4)
 a48:	05e1                	addi	a1,a1,24
 a4a:	018c0513          	addi	a0,s8,24
 a4e:	00000097          	auipc	ra,0x0
 a52:	378080e7          	jalr	888(ra) # dc6 <ulthread_context_switch>
      if (t->state == RUNNABLE && t != scheduler_thread && t->lastTime < oldest)
 a56:	000bb583          	ld	a1,0(s7)
    int alternativeIndex = -1;
 a5a:	86d6                	mv	a3,s5
    int threadIndex = -1;
 a5c:	8856                	mv	a6,s5
    uint64 oldest = __INT64_MAX__;
 a5e:	865a                	mv	a2,s6
    bool threadAvailable = false;
 a60:	4501                	li	a0,0
    for (t = ulthreads+1; t < &ulthreads[MAXULTHREADS]; t++)
 a62:	00065797          	auipc	a5,0x65
 a66:	65678793          	addi	a5,a5,1622 # 660b8 <ulthreads+0x88>
 a6a:	bf59                	j	a00 <firstComeFirstServe+0x56>
    label : 
 a6c:	86c2                	mv	a3,a6
 a6e:	b765                	j	a16 <firstComeFirstServe+0x6c>
  }
}
 a70:	60a6                	ld	ra,72(sp)
 a72:	6406                	ld	s0,64(sp)
 a74:	74e2                	ld	s1,56(sp)
 a76:	7942                	ld	s2,48(sp)
 a78:	79a2                	ld	s3,40(sp)
 a7a:	7a02                	ld	s4,32(sp)
 a7c:	6ae2                	ld	s5,24(sp)
 a7e:	6b42                	ld	s6,16(sp)
 a80:	6ba2                	ld	s7,8(sp)
 a82:	6c02                	ld	s8,0(sp)
 a84:	6161                	addi	sp,sp,80
 a86:	8082                	ret

0000000000000a88 <priorityScheduling>:


void priorityScheduling(void)
{
 a88:	715d                	addi	sp,sp,-80
 a8a:	e486                	sd	ra,72(sp)
 a8c:	e0a2                	sd	s0,64(sp)
 a8e:	fc26                	sd	s1,56(sp)
 a90:	f84a                	sd	s2,48(sp)
 a92:	f44e                	sd	s3,40(sp)
 a94:	f052                	sd	s4,32(sp)
 a96:	ec56                	sd	s5,24(sp)
 a98:	e85a                	sd	s6,16(sp)
 a9a:	e45e                	sd	s7,8(sp)
 a9c:	0880                	addi	s0,sp,80
    int maxPriority = -1;
    int threadIndex = -1;
    int alternativeIndex = -1;
    for (t = ulthreads+1; t < &ulthreads[MAXULTHREADS]; t++)
    {
      if (t->state == RUNNABLE && t != scheduler_thread && t->priority > maxPriority)
 a9e:	00001b17          	auipc	s6,0x1
 aa2:	572b0b13          	addi	s6,s6,1394 # 2010 <scheduler_thread>
    int alternativeIndex = -1;
 aa6:	5a7d                	li	s4,-1
      if (t->state == RUNNABLE && t != scheduler_thread && t->priority > maxPriority)
 aa8:	4485                	li	s1,1
        // flag = true;

        // break; // switch to highest-priority thread and exit loop
      }

      if (t->state == YIELD){
 aaa:	4989                	li	s3,2
    for (t = ulthreads+1; t < &ulthreads[MAXULTHREADS]; t++)
 aac:	00069917          	auipc	s2,0x69
 ab0:	aa490913          	addi	s2,s2,-1372 # 69550 <ulthreads+0x3520>
        break;
      }
      
    }
    label : 
      struct ulthread *temp = current_thread;
 ab4:	00001a97          	auipc	s5,0x1
 ab8:	564a8a93          	addi	s5,s5,1380 # 2018 <current_thread>
 abc:	a88d                	j	b2e <priorityScheduling+0xa6>
      if (t->state == RUNNABLE && t != scheduler_thread && t->priority > maxPriority)
 abe:	00f58963          	beq	a1,a5,ad0 <priorityScheduling+0x48>
 ac2:	47d8                	lw	a4,12(a5)
 ac4:	00e65663          	bge	a2,a4,ad0 <priorityScheduling+0x48>
        threadIndex = t->tid;
 ac8:	0047a803          	lw	a6,4(a5)
        maxPriority = t->priority;
 acc:	863a                	mv	a2,a4
        threadAvailable = true;
 ace:	8526                	mv	a0,s1
    for (t = ulthreads+1; t < &ulthreads[MAXULTHREADS]; t++)
 ad0:	08878793          	addi	a5,a5,136
 ad4:	01278a63          	beq	a5,s2,ae8 <priorityScheduling+0x60>
      if (t->state == RUNNABLE && t != scheduler_thread && t->priority > maxPriority)
 ad8:	4398                	lw	a4,0(a5)
 ada:	fe9702e3          	beq	a4,s1,abe <priorityScheduling+0x36>
      if (t->state == YIELD){
 ade:	ff3719e3          	bne	a4,s3,ad0 <priorityScheduling+0x48>
        t->state = RUNNABLE;
 ae2:	c384                	sw	s1,0(a5)
        alternativeIndex = t->tid;
 ae4:	43d4                	lw	a3,4(a5)
 ae6:	b7ed                	j	ad0 <priorityScheduling+0x48>
    if (!threadAvailable)
 ae8:	ed31                	bnez	a0,b44 <priorityScheduling+0xbc>
      if(alternativeIndex > 0){
 aea:	04d05f63          	blez	a3,b48 <priorityScheduling+0xc0>
      struct ulthread *temp = current_thread;
 aee:	000abb83          	ld	s7,0(s5)
      current_thread = &ulthreads[threadIndex];
 af2:	00469793          	slli	a5,a3,0x4
 af6:	00d78733          	add	a4,a5,a3
 afa:	070e                	slli	a4,a4,0x3
 afc:	00065617          	auipc	a2,0x65
 b00:	53460613          	addi	a2,a2,1332 # 66030 <ulthreads>
 b04:	9732                	add	a4,a4,a2
 b06:	00eab023          	sd	a4,0(s5)
      printf("[*] ultschedule (next tid: %d)\n", get_current_tid());
 b0a:	434c                	lw	a1,4(a4)
 b0c:	00000517          	auipc	a0,0x0
 b10:	45450513          	addi	a0,a0,1108 # f60 <digits+0x18>
 b14:	00000097          	auipc	ra,0x0
 b18:	c34080e7          	jalr	-972(ra) # 748 <printf>
      ulthread_context_switch(&temp->context, &current_thread->context);
 b1c:	000ab583          	ld	a1,0(s5)
 b20:	05e1                	addi	a1,a1,24
 b22:	018b8513          	addi	a0,s7,24
 b26:	00000097          	auipc	ra,0x0
 b2a:	2a0080e7          	jalr	672(ra) # dc6 <ulthread_context_switch>
      if (t->state == RUNNABLE && t != scheduler_thread && t->priority > maxPriority)
 b2e:	000b3583          	ld	a1,0(s6)
    int alternativeIndex = -1;
 b32:	86d2                	mv	a3,s4
    int threadIndex = -1;
 b34:	8852                	mv	a6,s4
    int maxPriority = -1;
 b36:	8652                	mv	a2,s4
    bool threadAvailable = false;
 b38:	4501                	li	a0,0
    for (t = ulthreads+1; t < &ulthreads[MAXULTHREADS]; t++)
 b3a:	00065797          	auipc	a5,0x65
 b3e:	57e78793          	addi	a5,a5,1406 # 660b8 <ulthreads+0x88>
 b42:	bf59                	j	ad8 <priorityScheduling+0x50>
    label : 
 b44:	86c2                	mv	a3,a6
 b46:	b765                	j	aee <priorityScheduling+0x66>
  }
}
 b48:	60a6                	ld	ra,72(sp)
 b4a:	6406                	ld	s0,64(sp)
 b4c:	74e2                	ld	s1,56(sp)
 b4e:	7942                	ld	s2,48(sp)
 b50:	79a2                	ld	s3,40(sp)
 b52:	7a02                	ld	s4,32(sp)
 b54:	6ae2                	ld	s5,24(sp)
 b56:	6b42                	ld	s6,16(sp)
 b58:	6ba2                	ld	s7,8(sp)
 b5a:	6161                	addi	sp,sp,80
 b5c:	8082                	ret

0000000000000b5e <ulthread_init>:

/* Thread initialization */
void ulthread_init(int schedalgo)
{
 b5e:	1141                	addi	sp,sp,-16
 b60:	e422                	sd	s0,8(sp)
 b62:	0800                	addi	s0,sp,16
  struct ulthread *t;
  int i;
  for (i = 0, t = ulthreads; t < &ulthreads[MAXULTHREADS]; t++, i++)
 b64:	4701                	li	a4,0
 b66:	00065797          	auipc	a5,0x65
 b6a:	4ca78793          	addi	a5,a5,1226 # 66030 <ulthreads>
 b6e:	00069697          	auipc	a3,0x69
 b72:	9e268693          	addi	a3,a3,-1566 # 69550 <ulthreads+0x3520>
  {
    t->state = FREE;
 b76:	0007a023          	sw	zero,0(a5)
    t->tid = i;
 b7a:	c3d8                	sw	a4,4(a5)
  for (i = 0, t = ulthreads; t < &ulthreads[MAXULTHREADS]; t++, i++)
 b7c:	08878793          	addi	a5,a5,136
 b80:	2705                	addiw	a4,a4,1
 b82:	fed79ae3          	bne	a5,a3,b76 <ulthread_init+0x18>
  }
  current_thread = &ulthreads[0];
 b86:	00065797          	auipc	a5,0x65
 b8a:	4aa78793          	addi	a5,a5,1194 # 66030 <ulthreads>
 b8e:	00001717          	auipc	a4,0x1
 b92:	48f73523          	sd	a5,1162(a4) # 2018 <current_thread>
  scheduler_thread = &ulthreads[0];
 b96:	00001717          	auipc	a4,0x1
 b9a:	46f73d23          	sd	a5,1146(a4) # 2010 <scheduler_thread>
  scheduler_thread->state = RUNNABLE;
 b9e:	4705                	li	a4,1
 ba0:	c398                	sw	a4,0(a5)
  t->state = FREE;
 ba2:	00069797          	auipc	a5,0x69
 ba6:	9a07a723          	sw	zero,-1618(a5) # 69550 <ulthreads+0x3520>
  algorithm = schedalgo;
 baa:	00001797          	auipc	a5,0x1
 bae:	44a7af23          	sw	a0,1118(a5) # 2008 <algorithm>
}
 bb2:	6422                	ld	s0,8(sp)
 bb4:	0141                	addi	sp,sp,16
 bb6:	8082                	ret

0000000000000bb8 <ulthread_create>:

/* Thread creation */
bool ulthread_create(uint64 start, uint64 stack, uint64 args[], int priority)
{
 bb8:	7179                	addi	sp,sp,-48
 bba:	f406                	sd	ra,40(sp)
 bbc:	f022                	sd	s0,32(sp)
 bbe:	ec26                	sd	s1,24(sp)
 bc0:	e84a                	sd	s2,16(sp)
 bc2:	e44e                	sd	s3,8(sp)
 bc4:	e052                	sd	s4,0(sp)
 bc6:	1800                	addi	s0,sp,48
 bc8:	89aa                	mv	s3,a0
 bca:	8a2e                	mv	s4,a1
 bcc:	8932                	mv	s2,a2
  /* Please add thread-id instead of '0' here. */
  struct ulthread *t;
  bool flag = false;
  for (t = ulthreads; t < &ulthreads[MAXULTHREADS]; t++)
 bce:	00065497          	auipc	s1,0x65
 bd2:	46248493          	addi	s1,s1,1122 # 66030 <ulthreads>
 bd6:	00069717          	auipc	a4,0x69
 bda:	97a70713          	addi	a4,a4,-1670 # 69550 <ulthreads+0x3520>
  {
    if (t->state == FREE)
 bde:	409c                	lw	a5,0(s1)
 be0:	cf89                	beqz	a5,bfa <ulthread_create+0x42>
  for (t = ulthreads; t < &ulthreads[MAXULTHREADS]; t++)
 be2:	08848493          	addi	s1,s1,136
 be6:	fee49ce3          	bne	s1,a4,bde <ulthread_create+0x26>
      break;
    }
  }
  if (!flag)
  {
    return false;
 bea:	4501                	li	a0,0
 bec:	a871                	j	c88 <ulthread_create+0xd0>
  t->sp = (int)(stack + USTACKSIZE); // set sp to the top of the stack
  t->state = RUNNABLE;
  t->priority = priority;

  if(algorithm==FCFS){
    t->lastTime = ctime();
 bee:	00000097          	auipc	ra,0x0
 bf2:	88a080e7          	jalr	-1910(ra) # 478 <ctime>
 bf6:	e888                	sd	a0,16(s1)
 bf8:	a839                	j	c16 <ulthread_create+0x5e>
  t->sp = (int)(stack + USTACKSIZE); // set sp to the top of the stack
 bfa:	6785                	lui	a5,0x1
 bfc:	014787bb          	addw	a5,a5,s4
 c00:	c49c                	sw	a5,8(s1)
  t->state = RUNNABLE;
 c02:	4785                	li	a5,1
 c04:	c09c                	sw	a5,0(s1)
  t->priority = priority;
 c06:	c4d4                	sw	a3,12(s1)
  if(algorithm==FCFS){
 c08:	00001717          	auipc	a4,0x1
 c0c:	40072703          	lw	a4,1024(a4) # 2008 <algorithm>
 c10:	4789                	li	a5,2
 c12:	fcf70ee3          	beq	a4,a5,bee <ulthread_create+0x36>
  }

  for (int argc = 0; argc < 6; argc++)
 c16:	874a                	mv	a4,s2
 c18:	03090693          	addi	a3,s2,48
  {
    t->sp -= 16;
 c1c:	449c                	lw	a5,8(s1)
 c1e:	37c1                	addiw	a5,a5,-16 # ff0 <digits+0xa8>
 c20:	0007881b          	sext.w	a6,a5
 c24:	c49c                	sw	a5,8(s1)
    *(uint64 *)(t->sp) = (uint64)args[argc];
 c26:	631c                	ld	a5,0(a4)
 c28:	00f83023          	sd	a5,0(a6)
  for (int argc = 0; argc < 6; argc++)
 c2c:	0721                	addi	a4,a4,8
 c2e:	fed717e3          	bne	a4,a3,c1c <ulthread_create+0x64>
  }

  memset(&t->context, 0, sizeof(t->context));
 c32:	07000613          	li	a2,112
 c36:	4581                	li	a1,0
 c38:	01848513          	addi	a0,s1,24
 c3c:	fffff097          	auipc	ra,0xfffff
 c40:	5a2080e7          	jalr	1442(ra) # 1de <memset>
  t->context.ra = start;
 c44:	0134bc23          	sd	s3,24(s1)
  t->context.sp = t->sp;
 c48:	449c                	lw	a5,8(s1)
 c4a:	f09c                	sd	a5,32(s1)
  t->context.s0 = args[0];
 c4c:	00093783          	ld	a5,0(s2)
 c50:	f49c                	sd	a5,40(s1)
  t->context.s1 = args[1];
 c52:	00893783          	ld	a5,8(s2)
 c56:	f89c                	sd	a5,48(s1)
  t->context.s2 = args[2];
 c58:	01093783          	ld	a5,16(s2)
 c5c:	fc9c                	sd	a5,56(s1)
  t->context.s3 = args[3];
 c5e:	01893783          	ld	a5,24(s2)
 c62:	e0bc                	sd	a5,64(s1)
  t->context.s4 = args[4];
 c64:	02093783          	ld	a5,32(s2)
 c68:	e4bc                	sd	a5,72(s1)
  t->context.s5 = args[5];
 c6a:	02893783          	ld	a5,40(s2)
 c6e:	e8bc                	sd	a5,80(s1)

  printf("[*] ultcreate(tid: %d, ra: %p, sp: %p)\n", t->tid, start, stack);
 c70:	86d2                	mv	a3,s4
 c72:	864e                	mv	a2,s3
 c74:	40cc                	lw	a1,4(s1)
 c76:	00000517          	auipc	a0,0x0
 c7a:	33a50513          	addi	a0,a0,826 # fb0 <digits+0x68>
 c7e:	00000097          	auipc	ra,0x0
 c82:	aca080e7          	jalr	-1334(ra) # 748 <printf>
  return true;
 c86:	4505                	li	a0,1
}
 c88:	70a2                	ld	ra,40(sp)
 c8a:	7402                	ld	s0,32(sp)
 c8c:	64e2                	ld	s1,24(sp)
 c8e:	6942                	ld	s2,16(sp)
 c90:	69a2                	ld	s3,8(sp)
 c92:	6a02                	ld	s4,0(sp)
 c94:	6145                	addi	sp,sp,48
 c96:	8082                	ret

0000000000000c98 <ulthread_schedule>:

/* Thread scheduler */
void ulthread_schedule(void)
{
 c98:	1141                	addi	sp,sp,-16
 c9a:	e406                	sd	ra,8(sp)
 c9c:	e022                	sd	s0,0(sp)
 c9e:	0800                	addi	s0,sp,16
  switch (algorithm)
 ca0:	00001797          	auipc	a5,0x1
 ca4:	3687a783          	lw	a5,872(a5) # 2008 <algorithm>
 ca8:	4705                	li	a4,1
 caa:	02e78463          	beq	a5,a4,cd2 <ulthread_schedule+0x3a>
 cae:	4709                	li	a4,2
 cb0:	00e78c63          	beq	a5,a4,cc8 <ulthread_schedule+0x30>
 cb4:	c789                	beqz	a5,cbe <ulthread_schedule+0x26>

  // Push argument strings, prepare rest of stack in ustack.

  // Switch between thread contexts
  // ulthread_context_switch(NULL, NULL);
}
 cb6:	60a2                	ld	ra,8(sp)
 cb8:	6402                	ld	s0,0(sp)
 cba:	0141                	addi	sp,sp,16
 cbc:	8082                	ret
    roundRobin();
 cbe:	00000097          	auipc	ra,0x0
 cc2:	c3e080e7          	jalr	-962(ra) # 8fc <roundRobin>
    break;
 cc6:	bfc5                	j	cb6 <ulthread_schedule+0x1e>
    firstComeFirstServe();
 cc8:	00000097          	auipc	ra,0x0
 ccc:	ce2080e7          	jalr	-798(ra) # 9aa <firstComeFirstServe>
    break;
 cd0:	b7dd                	j	cb6 <ulthread_schedule+0x1e>
    priorityScheduling();
 cd2:	00000097          	auipc	ra,0x0
 cd6:	db6080e7          	jalr	-586(ra) # a88 <priorityScheduling>
}
 cda:	bff1                	j	cb6 <ulthread_schedule+0x1e>

0000000000000cdc <ulthread_yield>:

/* Yield CPU time to some other thread. */
void ulthread_yield(void)
{
 cdc:	1101                	addi	sp,sp,-32
 cde:	ec06                	sd	ra,24(sp)
 ce0:	e822                	sd	s0,16(sp)
 ce2:	e426                	sd	s1,8(sp)
 ce4:	e04a                	sd	s2,0(sp)
 ce6:	1000                	addi	s0,sp,32
  current_thread->state = YIELD;
 ce8:	00001797          	auipc	a5,0x1
 cec:	33078793          	addi	a5,a5,816 # 2018 <current_thread>
 cf0:	6398                	ld	a4,0(a5)
 cf2:	4909                	li	s2,2
 cf4:	01272023          	sw	s2,0(a4)
  struct ulthread *temp = current_thread;
 cf8:	6384                	ld	s1,0(a5)
  printf("[*] ultyield(tid: %d)\n", current_thread->tid);
 cfa:	40cc                	lw	a1,4(s1)
 cfc:	00000517          	auipc	a0,0x0
 d00:	2dc50513          	addi	a0,a0,732 # fd8 <digits+0x90>
 d04:	00000097          	auipc	ra,0x0
 d08:	a44080e7          	jalr	-1468(ra) # 748 <printf>
  if(algorithm==FCFS){
 d0c:	00001797          	auipc	a5,0x1
 d10:	2fc7a783          	lw	a5,764(a5) # 2008 <algorithm>
 d14:	03278763          	beq	a5,s2,d42 <ulthread_yield+0x66>
    current_thread->lastTime = ctime();
  }
  current_thread = scheduler_thread;
 d18:	00001597          	auipc	a1,0x1
 d1c:	2f85b583          	ld	a1,760(a1) # 2010 <scheduler_thread>
 d20:	00001797          	auipc	a5,0x1
 d24:	2eb7bc23          	sd	a1,760(a5) # 2018 <current_thread>
  
  ulthread_context_switch(&temp->context, &scheduler_thread->context);
 d28:	05e1                	addi	a1,a1,24
 d2a:	01848513          	addi	a0,s1,24
 d2e:	00000097          	auipc	ra,0x0
 d32:	098080e7          	jalr	152(ra) # dc6 <ulthread_context_switch>
  // ulthread_schedule();
}
 d36:	60e2                	ld	ra,24(sp)
 d38:	6442                	ld	s0,16(sp)
 d3a:	64a2                	ld	s1,8(sp)
 d3c:	6902                	ld	s2,0(sp)
 d3e:	6105                	addi	sp,sp,32
 d40:	8082                	ret
    current_thread->lastTime = ctime();
 d42:	fffff097          	auipc	ra,0xfffff
 d46:	736080e7          	jalr	1846(ra) # 478 <ctime>
 d4a:	00001797          	auipc	a5,0x1
 d4e:	2ce7b783          	ld	a5,718(a5) # 2018 <current_thread>
 d52:	eb88                	sd	a0,16(a5)
 d54:	b7d1                	j	d18 <ulthread_yield+0x3c>

0000000000000d56 <ulthread_destroy>:

/* Destroy thread */
void ulthread_destroy(void)
{
 d56:	1101                	addi	sp,sp,-32
 d58:	ec06                	sd	ra,24(sp)
 d5a:	e822                	sd	s0,16(sp)
 d5c:	e426                	sd	s1,8(sp)
 d5e:	e04a                	sd	s2,0(sp)
 d60:	1000                	addi	s0,sp,32
  memset(&current_thread->context, 0, sizeof(current_thread->context));
 d62:	00001497          	auipc	s1,0x1
 d66:	2b648493          	addi	s1,s1,694 # 2018 <current_thread>
 d6a:	6088                	ld	a0,0(s1)
 d6c:	07000613          	li	a2,112
 d70:	4581                	li	a1,0
 d72:	0561                	addi	a0,a0,24
 d74:	fffff097          	auipc	ra,0xfffff
 d78:	46a080e7          	jalr	1130(ra) # 1de <memset>
  current_thread->sp = 0;
 d7c:	609c                	ld	a5,0(s1)
 d7e:	0007a423          	sw	zero,8(a5)
  current_thread->priority = -1;
 d82:	577d                	li	a4,-1
 d84:	c7d8                	sw	a4,12(a5)
  current_thread->state = FREE;
 d86:	0007a023          	sw	zero,0(a5)

  struct ulthread *temp = current_thread;
 d8a:	0004b903          	ld	s2,0(s1)

  printf("[*] ultdestroy(tid: %d)\n", get_current_tid());
 d8e:	00492583          	lw	a1,4(s2)
 d92:	00000517          	auipc	a0,0x0
 d96:	25e50513          	addi	a0,a0,606 # ff0 <digits+0xa8>
 d9a:	00000097          	auipc	ra,0x0
 d9e:	9ae080e7          	jalr	-1618(ra) # 748 <printf>
  current_thread = scheduler_thread;
 da2:	00001597          	auipc	a1,0x1
 da6:	26e5b583          	ld	a1,622(a1) # 2010 <scheduler_thread>
 daa:	e08c                	sd	a1,0(s1)
  ulthread_context_switch(&temp->context, &scheduler_thread->context);
 dac:	05e1                	addi	a1,a1,24
 dae:	01890513          	addi	a0,s2,24
 db2:	00000097          	auipc	ra,0x0
 db6:	014080e7          	jalr	20(ra) # dc6 <ulthread_context_switch>
}
 dba:	60e2                	ld	ra,24(sp)
 dbc:	6442                	ld	s0,16(sp)
 dbe:	64a2                	ld	s1,8(sp)
 dc0:	6902                	ld	s2,0(sp)
 dc2:	6105                	addi	sp,sp,32
 dc4:	8082                	ret

0000000000000dc6 <ulthread_context_switch>:
 dc6:	00153023          	sd	ra,0(a0)
 dca:	00253423          	sd	sp,8(a0)
 dce:	e900                	sd	s0,16(a0)
 dd0:	ed04                	sd	s1,24(a0)
 dd2:	03253023          	sd	s2,32(a0)
 dd6:	03353423          	sd	s3,40(a0)
 dda:	03453823          	sd	s4,48(a0)
 dde:	03553c23          	sd	s5,56(a0)
 de2:	05653023          	sd	s6,64(a0)
 de6:	05753423          	sd	s7,72(a0)
 dea:	05853823          	sd	s8,80(a0)
 dee:	05953c23          	sd	s9,88(a0)
 df2:	07a53023          	sd	s10,96(a0)
 df6:	07b53423          	sd	s11,104(a0)
 dfa:	0005b083          	ld	ra,0(a1)
 dfe:	0085b103          	ld	sp,8(a1)
 e02:	6980                	ld	s0,16(a1)
 e04:	6d84                	ld	s1,24(a1)
 e06:	0205b903          	ld	s2,32(a1)
 e0a:	0285b983          	ld	s3,40(a1)
 e0e:	0305ba03          	ld	s4,48(a1)
 e12:	0385ba83          	ld	s5,56(a1)
 e16:	0405bb03          	ld	s6,64(a1)
 e1a:	0485bb83          	ld	s7,72(a1)
 e1e:	0505bc03          	ld	s8,80(a1)
 e22:	0585bc83          	ld	s9,88(a1)
 e26:	0605bd03          	ld	s10,96(a1)
 e2a:	0685bd83          	ld	s11,104(a1)
 e2e:	6546                	ld	a0,80(sp)
 e30:	6586                	ld	a1,64(sp)
 e32:	7642                	ld	a2,48(sp)
 e34:	7682                	ld	a3,32(sp)
 e36:	6742                	ld	a4,16(sp)
 e38:	6782                	ld	a5,0(sp)
 e3a:	8082                	ret
