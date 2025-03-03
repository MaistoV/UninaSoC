# OpenOCD Installation

TBD


Run the following commands:
```
git clone https://github.com/riscv/riscv-openocd
cd riscv-openocd
# git checkout v2018.12.0 ??
git submodule update --init
./bootstrap
./configure --enable-ftdi
make
sudo make install
```
> NOTE: remove `--enable-jtag_vpi` flag from `configure`