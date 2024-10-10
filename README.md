# UninaSoC
RISC-V soft-SoC extensible plaftorm for Xilinx FPGAs from University of Naples Federico II.
> NOTE: the name is temporary...

# SoC Configuration Profile

```
source settings.sh <soc_config>
```
The board is automatically selected based on the SoC configuration
Valid Soc Configuration and boards are:

| soc_config               | board            |
|--------------------------|------------------|
| embedded (Default)       | Nexsys A7        |
| hpc                      | Alveo U250       |

## Supported boards:
Embedded:
- [Nexys A7](https://digilent.com/shop/nexys-a7-fpga-trainer-board-recommended-for-ece-curriculum/)

HPC:
- [Alveo U250](https://www.amd.com/en/products/accelerators/alveo/u250/a-u250-a64g-pq-g.html)

Todo:
- (TBD)[Zybo](https://digilent.com/reference/programmable-logic/zybo/reference-manual)
- (TBD)[ZCU102](https://www.xilinx.com/products/boards-and-kits/ek-u1-zcu102-g.html)

# Simulation flow:
The choice of the simulator is driven by the choice of the IPs and required licenses. We target two simulation flows:
* Unit tests: Verilator
   * Royalty-free, good for students
   * No support for Xilin IPs
* SoC-level tests, QuestaSim:
   * Requires license
   * Supports Xilinx IPs
   * Students can access a licensed host for simulator access

# Environment and Tools Version
This project was verified on Ubuntu 22.04.
W.r.t. the single tools:
| Tool            | Verified version |
|-----------------|------------------|
| Vivado          | 2022.2/2023.1    |
| Mentor Questa   | 2020.4           |
| g++             | TBD              |
| Verilator       | TBD              |
| gtkwave         | TBD              |


# TODO
* Design address space
	* Finalized linker script
 	* Device tree (template + generation)
* Design interchangability of RVM cores in RVM socket, e.g.:
```
'RVM_CORE_WRAPPER # (
'rvm_core_name_parameter_map
)
'{RVM_CORE_NAME}_inst
'RVM_CORE_NAME_PORT_MAP
)
```

# ES Project 2024
Basic projects:

1. ~~AXI Crossbar: Autogenerate linker script + Xilinx AXI crossbar address map from a configuration file~~
2. ~~AXI UART: Bare-metal driver xlnx axi uart in C, not asssemby~~
3. ~~JTAG2AXI: Verify jtag2axi integration~~
4. ~~Alveo porting: Port SoC on Alveo~~
5. Bootrom: design and development
6. DRAM: MIG IP (DDR) integration
7. Interrupts: interrupt system design
8. SPI flash: Integrate + PoC boot from SPI flash
9. Debugger: JTAG debug core + OpenOCD/GDB
10. Design probing: ILA integration in SoC flow

Advanced projects:

11. Linux in-memory boot
12. Linux SPI flash boot
13. CoVe: extension implementation
