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

## Prerequisites
RISC-V OpenOCD requires:
* the [`jimtcl`](https://github.com/msteveb/jimtcl) library.
* libusb 1.x

### jimtcl 

You can build `jimtcl` from source with:
``` bash
git clone https://github.com/msteveb/jimtcl -b 0.83
cd jimtcl
./configure
make
sudo make install
```

> After installation, make sure `jimtcl` is in your library include path.

### libusb 1.x
For Ubuntu, install with:
``` bash
sudo apt-get install libusb-1.0-0-dev
```
