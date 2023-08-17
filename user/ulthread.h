#ifndef __UTHREAD_H__
#define __UTHREAD_H__

#include <stdbool.h>
#define MAXULTHREADS 100
#define USTACKSIZE 4096
#define MAXPRIORITY 10

enum ulthread_state
{
  FREE,
  RUNNABLE,
  YIELD,
};

enum ulthread_scheduling_algorithm
{
  ROUNDROBIN,
  PRIORITY,
  FCFS, // first-come-first serve
};

struct threadContext
{
  uint64 ra;
  uint64 sp;

  // callee-saved
  uint64 s0;
  uint64 s1;
  uint64 s2;
  uint64 s3;
  uint64 s4;
  uint64 s5;
  uint64 s6;
  uint64 s7;
  uint64 s8;
  uint64 s9;
  uint64 s10;
  uint64 s11;
};

struct ulthread
{
  // struct spinlock lock;

  // p->lock must be held when using these:
  enum ulthread_state state; // ulthread state
  // void *chan;                  // If non-zero, sleeping on chan
  // int killed;                  // If non-zero, have been killed
  // int xstate;                  // Exit status to be returned to parent's wait
  int tid; // Process ID
  int sp;
  int priority;
  uint64 lastTime;

  // wait_lock must be held when using this:
  // struct proc *parent;         // Parent process

  // // these are private to the process, so p->lock need not be held.
  // struct threadframe *trapframe; // data page for trampoline.S
  struct threadContext context;  // swtch() here to run process
  // struct file *ofile[NOFILE];  // Open files
  // struct inode *cwd;           // Current directory

  // char name[16]; // Process name (debugging)
};

#endif