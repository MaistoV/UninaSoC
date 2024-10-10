# UninaSoC
RISC-V soft-SoC design for Xilinx FPGAs from University of Naples Federico II.

Alternative name candidates:
* Federico-V
* SECLabbino
* ?

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
| Vivado          | 2022.2           |
| Mentor Questa   | 2020.4           |
| g++             | TBD              |
| Verilator       | TBD              |
| gtkwave         | TBD              |


# SoC configuration selection

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
- [Zybo](https://digilent.com/reference/programmable-logic/zybo/reference-manual)
- [Nexys A7](https://digilent.com/shop/nexys-a7-fpga-trainer-board-recommended-for-ece-curriculum/)
- [Alveo U250](https://www.amd.com/en/products/accelerators/alveo/u250/a-u250-a64g-pq-g.html)

## Board installation
- Alveo U250 (Verified on Vivado 2023.1)
   - Download the [Alveo U250 board files](https://www.xilinx.com/bin/public/openDownload?filename=au250_board_files_20200616.zip)
   - Extract the downloaded zip into \<VIVADO_DIR>/data/xhub/boards/XilinxBoardStore/boards/Xilinx/ 
   - Restart Vivado

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
4. Bootrom: design and development
5. (?) DRAM: MIG IP integration
6. Interrupts: interrupt system design
7. Alveo porting: Port SoC on Alveo
8. SPI flash: Integrate + PoC boot from SPI flash
9. Debugger: JTAG debug core + OpenOCD/GDB
10. Design probing: ILA integration in SoC flow

Advanced projects:

11. Linux in-memory boot 
12. Linux SPI flash boot 
13. CoVe: extension implementation
