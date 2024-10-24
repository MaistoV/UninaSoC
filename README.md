# UninaSoC
RISC-V soft-SoC extensible plaftorm for Xilinx FPGAs from University of Naples Federico II.
> NOTE: the name is temporary...

# SoC Configuration Profile

```
source settings.sh <soc_config> <board_config>
```
If no input parameter is specificed, the embedded Nexys A7-100T is selected.
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
The top-level Makefile can be used to build the system-on-chip for the specific target board.
First, define environmental variables by using:
```
source settings.sh
```
Then, download rtl sources for non-xilinx IPS
```
make units
```
Finally, build the SoC by running:
```
make 
```
If you need finer-grained options to control the building flow, refer to the documentation:
*`hw/units/README.md`
*`hw/xilinx/README.md`

# Simulation flow (TBD):
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
