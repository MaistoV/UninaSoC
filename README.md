# UninaSoC
RISC-V soft-SoC extensible plaftorm for Xilinx FPGAs from University of Naples Federico II.
> NOTE: the name is temporary...

# SoC Configuration Profile
The SoC comes in two flavors, `hpc` and `embedded`, with multiple boards supported for each configuration.
Valid Soc Configuration and boards are:

| soc_config               | board                    |
|--------------------------|--------------------------|
| embedded (Default)       | Nexsys A7-100T (Default) |
| embedded (Default)       | Nexsys A7-50T            |
| hpc                      | Alveo U250               |

## Supported boards:
Embedded:
- [Nexys A7-100T](https://digilent.com/reference/programmable-logic/nexys-a7/reference-manual)
- [Nexys A7-50T](https://digilent.com/reference/programmable-logic/nexys-a7/reference-manual)

HPC:
- [Alveo U250](https://www.amd.com/en/products/accelerators/alveo/u250/a-u250-a64g-pq-g.html)

Todo:
- (TBD) [Zybo](https://digilent.com/reference/programmable-logic/zybo/reference-manual)
- (TBD) [ZCU102](https://www.xilinx.com/products/boards-and-kits/ek-u1-zcu102-g.html)
- (TBD) [Alveo U50](https://docs.amd.com/r/en-US/ug1371-u50-reconfig-accel)
- (TBD) [Alveo U280](https://docs.amd.com/r/en-US/ug1314-alveo-u280-reconfig-accel)

# Build and Run:
The top-level Makefile can be used to build the System-on-Chip for the specific target board.

First, setup environment with:
```
source settings.sh <soc_config> <board>
```
> NOTE: If no input parameter is specificed, the `embedded` profile and the Nexys A7-100T are selected.

Then, download rtl sources for non-xilinx IPS
```
make units
```

Finally, build the SoC bitstream by running:
```
make xilinx
```

## Simulation flow (TBD):
The choice of the simulator is driven by the choice of the IPs and required licenses. We target two simulation flows:
* Unit tests: Verilator
   * Royalty-free, good for students
   * No support for Xilin IPs
* SoC-level tests, QuestaSim:
   * Requires license
   * Supports Xilinx IPs
   * Students can access a licensed host for simulator access

## Environment and Tools Version
This project was verified on Ubuntu 22.04.
W.r.t. the single tools:
| Tool            | Verified version |
|-----------------|------------------|
| Vivado          | 2022.2/2023.1    |
| Mentor Questa   | 2020.4           |
| g++             | TBD              |
| Verilator       | TBD              |
| gtkwave         | TBD              |

## Architecture

Basic SoC architecture and host connection:
> NOTE: this needs refinement

![SoC Architecture](./Base_SoC_layout.png)

## Documentation Index

If you need finer-grained documentation and insights to control the building flow, refer to the documentation:
- Units RTL [hw/units/README.md](hw/units/README.md)
- Xilinx FPGA [hw/xilinx/README.md](hw/xilinx/README.md)
- Software build [hw/sw/README.md](hw/sw/README.md)

