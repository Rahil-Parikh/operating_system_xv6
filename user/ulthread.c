/* CSE 536: User-Level Threading Library */
#include "kernel/types.h"
#include "kernel/stat.h"
#include "kernel/fcntl.h"
#include "user/user.h"
#include "user/ulthread.h"
/* Standard definitions */
#include <stdbool.h>
#include <stddef.h>

struct ulthread ulthreads[MAXULTHREADS];
struct ulthread *current_thread;
struct ulthread *scheduler_thread;
enum ulthread_scheduling_algorithm algorithm;

/* Get thread ID */
int get_current_tid(void)
{
  return current_thread->tid;
}

void roundRobin(void)
{
  struct ulthread *t;
  for (;;)
  {

    bool threadAvailable = false;
    for (t = ulthreads; t < &ulthreads[MAXULTHREADS]; t++)
    {
      if (t->state == RUNNABLE && t != scheduler_thread)
      {
        threadAvailable = true;
        // Switch to chosen process.  It is the process's job
        // to release its lock and then reacquire it
        // before jumping back to us.
        struct ulthread *temp = current_thread;
        current_thread = t;
        printf("[*] ultschedule (next tid: %d)\n", get_current_tid());
        ulthread_context_switch(&temp->context, &t->context);
      }
      if (t->state == YIELD)
      {
        t->state = RUNNABLE;
      }
    }
    if (!threadAvailable)
    {
      break;
    }
  }
}

void firstComeFirstServe(void)
{
  struct ulthread *t;
  for (;;)
  {
    bool threadAvailable = false;
    uint64 oldest = __INT64_MAX__;
    int threadIndex = -1;
    int alternativeIndex = -1;
    for (t = ulthreads+1; t < &ulthreads[MAXULTHREADS]; t++)
    {
      if (t->state == RUNNABLE && t != scheduler_thread && t->lastTime < oldest)
      {
        oldest = t->lastTime;
        threadIndex = t->tid;
        threadAvailable = true;
      }

      if (t->state == YIELD){
        t->state = RUNNABLE;
        alternativeIndex = t->tid;
      }
    }
    if (!threadAvailable)
    {
      if(alternativeIndex > 0){
        threadIndex = alternativeIndex;
        alternativeIndex = -1;
        goto label;
      }else{
        break;
      }
      
    }
    label : 
      struct ulthread *temp = current_thread;
      current_thread = &ulthreads[threadIndex];
      printf("[*] ultschedule (next tid: %d), time = %d\n", get_current_tid());
      ulthread_context_switch(&temp->context, &current_thread->context);
  }
}


void priorityScheduling(void)
{
  struct ulthread *t;
  for (;;)
  {
    bool threadAvailable = false;
    int maxPriority = -1;
    int threadIndex = -1;
    int alternativeIndex = -1;
    for (t = ulthreads+1; t < &ulthreads[MAXULTHREADS]; t++)
    {
      if (t->state == RUNNABLE && t != scheduler_thread && t->priority > maxPriority)
      {;

        maxPriority = t->priority;
        threadIndex = t->tid;
        threadAvailable = true;

        // switch to chosen process

        // flag = true;

        // break; // switch to highest-priority thread and exit loop
      }

      if (t->state == YIELD){
        t->state = RUNNABLE;
        alternativeIndex = t->tid;
      }
        

    }
    if (!threadAvailable)
    {
      if(alternativeIndex > 0){
        threadIndex = alternativeIndex;
        alternativeIndex = -1;
        goto label;
      }else{
        break;
      }
      
    }
    label : 
      struct ulthread *temp = current_thread;
      current_thread = &ulthreads[threadIndex];
      printf("[*] ultschedule (next tid: %d)\n", get_current_tid());
      ulthread_context_switch(&temp->context, &current_thread->context);
  }
}

/* Thread initialization */
void ulthread_init(int schedalgo)
{
  struct ulthread *t;
  int i;
  for (i = 0, t = ulthreads; t < &ulthreads[MAXULTHREADS]; t++, i++)
  {
    t->state = FREE;
    t->tid = i;
  }
  current_thread = &ulthreads[0];
  scheduler_thread = &ulthreads[0];
  scheduler_thread->state = RUNNABLE;
  t->state = FREE;
  algorithm = schedalgo;
}

/* Thread creation */
bool ulthread_create(uint64 start, uint64 stack, uint64 args[], int priority)
{
  /* Please add thread-id instead of '0' here. */
  struct ulthread *t;
  bool flag = false;
  for (t = ulthreads; t < &ulthreads[MAXULTHREADS]; t++)
  {
    if (t->state == FREE)
    {
      flag = true;
      break;
    }
  }
  if (!flag)
  {
    return false;
  }
  t->sp = (int)(stack + USTACKSIZE); // set sp to the top of the stack
  t->state = RUNNABLE;
  t->priority = priority;

  if(algorithm==FCFS){
    t->lastTime = ctime();
  }

  for (int argc = 0; argc < 6; argc++)
  {
    t->sp -= 16;
    *(uint64 *)(t->sp) = (uint64)args[argc];
  }

  memset(&t->context, 0, sizeof(t->context));
  t->context.ra = start;
  t->context.sp = t->sp;
  t->context.s0 = args[0];
  t->context.s1 = args[1];
  t->context.s2 = args[2];
  t->context.s3 = args[3];
  t->context.s4 = args[4];
  t->context.s5 = args[5];

  printf("[*] ultcreate(tid: %d, ra: %p, sp: %p)\n", t->tid, start, stack);
  return true;
}

/* Thread scheduler */
void ulthread_schedule(void)
{
  switch (algorithm)
  {

  case ROUNDROBIN:
    roundRobin();
    break;
  case FCFS:
    firstComeFirstServe();
    break;
  case PRIORITY:
    priorityScheduling();
    break;
  }
  /* Add this statement to denote which thread-id is being scheduled next */

  // Push argument strings, prepare rest of stack in ustack.

  // Switch between thread contexts
  // ulthread_context_switch(NULL, NULL);
}

/* Yield CPU time to some other thread. */
void ulthread_yield(void)
{
  current_thread->state = YIELD;
  struct ulthread *temp = current_thread;
  printf("[*] ultyield(tid: %d)\n", current_thread->tid);
  if(algorithm==FCFS){
    current_thread->lastTime = ctime();
  }
  current_thread = scheduler_thread;
  
  ulthread_context_switch(&temp->context, &scheduler_thread->context);
  // ulthread_schedule();
}

/* Destroy thread */
void ulthread_destroy(void)
{
  memset(&current_thread->context, 0, sizeof(current_thread->context));
  current_thread->sp = 0;
  current_thread->priority = -1;
  current_thread->state = FREE;

  struct ulthread *temp = current_thread;

  printf("[*] ultdestroy(tid: %d)\n", get_current_tid());
  current_thread = scheduler_thread;
  ulthread_context_switch(&temp->context, &scheduler_thread->context);
}
