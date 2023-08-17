# CSE 536: Assignment 4: Trap and Emulate Virtualization

Implemented a way to design a virtual machine—trap and emulate. The high-level idea of this approach is that the virtual machine (VM) runs as a user-mode process on the host operating system, which also acts like a virtual machine monitor (VMM). The VM is allowed to execute user-level (unprivileged) instructions directly, while all supervisor-level (privileged) instructions trap to the VMM. It then emulates these trapped privileged instructions and maintains (in-memory) all privileged state of the VM. This state includes all privileged registers (e.g., satp, scause, stvec, etc. in RISC-V)

## Implementations
- Privileged Virtual Machine State Initialization 
- Track Virtual Machine Execution and Redirect Traps
- Decode Trapped Privileged Instruction
- Emulate Decoded Instructions
- Emulating Physical Memory Protection (PMP)
