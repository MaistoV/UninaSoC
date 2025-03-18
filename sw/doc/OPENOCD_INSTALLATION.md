# OpenOCD Installation

To install OpenOCD,
run the following commands:
``` bash
git clone https://github.com/riscv/riscv-openocd
cd riscv-openocd
# git checkout v2018.12.0
git submodule update --init
./bootstrap
./configure --enable-ftdi
make
sudo make install
```
> NOTE: If simulation support is required, add `--enable-jtag_vpi` flag from `configure`
