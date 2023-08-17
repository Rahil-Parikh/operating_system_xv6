# CSE 536: Assignment 2: Process Memory Management in xv6

Implement on-demand paging for a process using page faults. This requires
you to change how the xv6 OS currently statically allocates pages for a process, write a page fault handler to intercept and load pages on page faults, and swap pages to disk if the system is out of memory.

## Implementations

- On-demand loading of a program binary’s contents
- Page fault handler to load program binary contents on-demand
- Loading heap memory on-demand as well to efficiently use system memory
- Page swapping to disk for the heap memory of a process during a page fault.