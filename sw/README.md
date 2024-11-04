# RISC-V Software Flow
This tree requires [RISC-V GCC](https://github.com/riscv/riscv-gnu-toolchain.git) to be installed on the developement host.

## Building GCC from Sources
You can build GCC from sources, as in the following.

Download prerequisites, e.g. for Debian:
``` bash
sudo apt-get install -y autoconf automake autotools-dev curl python3 python3-pip \
    libmpc-dev libmpfr-dev libgmp-dev gawk build-essential bison flex texinfo gperf \
    libtool patchutils bc zlib1g-dev libexpat-dev ninja-build git cmake libglib2.0-dev
```

Clone sources:
``` bash
git clone https://github.com/riscv/riscv-gnu-toolchain.git --depth 1 -b 2024.03.01
cd riscv-gnu-toolchain
git submodule update --init --recursive --depth 1 binutils gcc glibc newlib gdb
```
> NOTE: RISC-V GCC release 2024.03.01 has been verified with host GCC 11.4.0. Newer or older releases might require a different host GCC version.

Configure and build:
``` bash
cd riscv-gnu-toolchain
mkdir build
cd build
# For RV32
../configure --prefix=$INSTALL_DIR/gnu-toolchain32 --with-arch=rv32gc
# For RV64
../configure --prefix=$INSTALL_DIR/gnu-toolchain64 --enable-multilib
# NOTE: this is going to take a while...
make -j $(nproc)
```

Install in `--prefix`:
``` bash
make install
```

# Building Software
The sw directory is divided in two sub-directories:
* host - software for the host
* SoC  - software for the SoC

### Directory structure
```
.
├── host                                  # Host software
│   └── <project_name>                    # Project directory
│       ├── Makefile                      # Makefile
│       └── src                           # Sources
│           └── ...
├── Makefile                              # Top level Makefile
└── SoC                                   # SoC software
    ├── examples                          # Example projects
    │   └── <project_name>                # Project directory
    │       ├── Makefile                  # Makefile
    │       └── src                       # Sources
    │           └── ...
    ├── linker                            # Linker script directory
    │   └── <LINKER_SCRIPT>.ld
    ├── startup                           # Startup directory
    │   └── startup.s
    └── template                          # Template project
        ├── Makefile
        └── src
            └── main.c
```

The top level Makefile contains targets for both host software and SoC software.

### Build command
To build software for the host:
```
make host_<project_name>
```
To build software for the SoC:
```
make soc_<project_name>
```
The relative output product (objs, `.bin`, `.elf` ...) can be found in the `sw/[host|SoC]/<project_name>` directory.