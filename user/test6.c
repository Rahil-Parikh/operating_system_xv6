#include "kernel/param.h"
#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"
#include "kernel/fs.h"
#include "kernel/fcntl.h"
#include "kernel/syscall.h"
#include "kernel/memlayout.h"
#include "kernel/riscv.h"

#include "user/ulthread.h"
#include <stdarg.h>

/* Stack region for different threads */
char stacks[PGSIZE*MAXULTHREADS];

void ul_start_func(int a1,int a2, int a3, int a4, int a5, int a6, int a7, int a8) {
    printf("[.] started the thread function (tid = %d, a1 = %d, a2 = %d, a3 = %d, a4 = %d, a5 = %d, a6 = %d)\n", get_current_tid(), a1, a2, a3, a4, a5, a6);

    /* Notify for a thread exit. */
    ulthread_destroy();
}

int
main(int argc, char *argv[])
{
    /* Clear the stack region */
    memset(&stacks, 0, sizeof(stacks));

    /* Initialize the user-level threading library */
    ulthread_init(PRIORITY);

    /* Create a user-level thread */
    uint64 args[6] = {6,5,4,3,2,1};
    ulthread_create((uint64) ul_start_func, (uint64) stacks+PGSIZE, args, 3);

    /* Schedule all of the threads */
    ulthread_schedule();
    
    printf("[*] User-Level Threading Test #6 (Arguments Checking - PRIORITY) Complete.\n");
    return 0;
}
