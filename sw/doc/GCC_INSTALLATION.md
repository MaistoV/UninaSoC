# Building RISC-V GCC Toolchain from Sources
To build SoC software, we require [RISC-V GCC](https://github.com/riscv/riscv-gnu-toolchain.git) to be installed on the developement host.
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
