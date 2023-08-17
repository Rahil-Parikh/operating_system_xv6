# CSE 536: Assignment 3: User-Level Thread Management

Implement user-level threads (also called self-threads) for xv6 processes and make scheduling decisions inside the process based on different policies.
An xv6 process starts with only one kernel-supported thread. Within the process, thread divided
into several user-level threads. Maintaining one of these user-level threads as a user-level scheduler thread. This thread will make decisions regarding which user-level thread should execute at a certain time, based on different scheduling algorithms that can be choose.

## User-Level Threading Library 
- Library initialization
- Thread creation
- Thread switch
- Thread yield and destroy
- Thread scheduling decisions
