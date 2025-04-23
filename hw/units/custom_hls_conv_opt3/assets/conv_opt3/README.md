# Vitis HLS GEMM
This repository automates IP building for Vitis HLS GEMM accelerator and provides bare-metal application code.
It is all arranged to be UninaSoC directories-compliant.

You can clone all git repository or use only scripts/fetch_sources.sh.
- If you clone all repo, outputs will be in hw/build/ directory;
- If you use fetch_sources.sh only, outputs will be in build/ directory.

## Algorithm description
It executes a General Matrix Multiply:

$$ C = A \cdot B $$

with the following features:
- One AXI master interfaces;
- One ap_ctrl_chain slave control interface;
- 32 elements inputs;
- Not yet tested bare-metal application.

## Hardware build
To compile HLS and package the IP:

    make syn
    make package

from hw/ directory.

Or you can call

    ./scripts/fetch_sources.sh

To extract only rtl sources (in Verilog), ip directory for Vivado and ip zip.
Outputs will be located in build/ directory.

## Application build
The bare-metal application is already arranged to be UninaSoC directories-compliant.
You can test if it compiles by using Makefile_test (you need riscv bare-metal toolchain):

    make -f Makefile_test

After importing on UninaSoC some files can be deleted:
* startup/
* Makefile_test

are not needed.
