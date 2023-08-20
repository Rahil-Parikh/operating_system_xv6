# CSE 536: Advanced Operating System
Follow steps to setup necessary dependencies for developing xv6 OS. Find the respective implentations in the branches of the same repository.

## Check the following branches to find their respective implementations
- <a href ="https://github.com/Rahil-Parikh/operating_system_xv6/tree/1_startup_process">1_startup_process</a> - Boot Rom and Bootloader
- <a href ="https://github.com/Rahil-Parikh/operating_system_xv6/tree/2_virtual_mem_mngt">2_vitual_mem_mngt</a> - Process Memory Management
- <a href ="https://github.com/Rahil-Parikh/operating_system_xv6/tree/3_user_thread_mngt">3_user_thread_mngt</a> - User-Level Thread Management
- <a href ="https://github.com/Rahil-Parikh/operating_system_xv6/tree/4_trap_emulate_virtualization">4_trap_emulate_virtualization</a> - Trap and Emulate Virtualization 

## A. Installing xv6 pre-requisites 

Please reach out to the TAs if you have any installation issues.

#### Linux/WSL

1. Navigate to the install/linux-wsl folder
2. Install RISC-V QEMU: `./linux-qemu.sh`
3. Install RISC-V toolchain:`./linux-toolchain.sh`
4. Add installed binaries to path: `source .add-linux-paths`

#### MacOS

1. Navigate to the install/mac folder
2. Install RISC-V QEMU: `./mac-qemu.sh`
3. Install RISC-V toolchain: `./mac-toolchain.sh`
4. Add installed binaries to path: `source .add-mac-paths`

## B. Running the xv6 OS

1. Navigate back to main folder and clone the xv6 OS using 

        git clone https://github.com/mit-pdos/xv6-riscv.git

2. Navigate to xv6-riscv and run `make qemu`

## C. FAQs

1. While running linux-qemu.sh, if you run into `ERROR: glib-2.48 gthread-2.0 is required to compile QEMU`, then :

- Run this command in the terminal.  `sudo apt install libglib2.0-dev`. This is caused due to a newer version of your linux distro([link](https://github.com/Xilinx/qemu/issues/40)). 

2. linux-qemu.sh : `../meson.build:328:2: ERROR: Dependency "pixman-1" not found, tried pkgconfig`

- Can be resolved by running `sudo apt install libpixman-1-dev` ([link](https://stackoverflow.com/a/39916441))



## Acknowledgement

Thankful to the xv6 team at MIT for their open-source codebase. 
