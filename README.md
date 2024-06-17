# UninaSoC
RISC-V SoC design for FPGA fast prototyping from University of Naples Federico II.

Alternative name candidates:
* Federico-V
* SECLabbino
* ?

# Supported boards:
Zybo?
Artix-7?

# Simulation flow:
The choice of the simulator is driven by the choice of the IPs and required licenses. We target two simulation flows:
* Unit tests: Verilator
   * Royalty-free, good for students
   * No support for Xilin IPs
* SoC-level tests, QuestaSim:
   * Requires license
   * Supports Xilinx IPs
   * Students can access a shared machine simulator access

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

# TODO
* Design configuration flow under config/ directory
* Design address space -> linker script in sw/linker from template + configs to .ld
* Design interchangability of RVM cores in RVM socket, e.g.:  
```
'RVM_CORE_WRAPPER # (
'rvm_core_name_parameter_map
) 
'{RVM_CORE_NAME}_inst 
'RVM_CORE_NAME_PORT_MAP
)
```
* Build and verify first design

# ES Project 2024
- SoC-independent:
	1. Autogenerate linker script + Xilinx AXI crossbar address map from a configuration file
	2. Bare-metal driver xlnx axi uart in C, not asssemby
		- Host is a PS Cortex-A (on Zybo), not a RISC-V core
	3. Verify jtag2axi integration and develop minimal bootrom
		- Can leverage spike and RISC-V GCC from CE2/APC demo
- Soc-dependent
	4. Cove (TBD)
