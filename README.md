# UninaSoC
RISC-V SoC design for FPGA fast prototyping from University of Naples Federico II.

Alternative name candidates:
* Federico-V
* ...?

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
   * Students can access a shared machine for using the simulator

# Vivado version 
2022.2

# TODO
* Design configuration flow under config/ directory
* Design address space -> linker script in sw/linker from template + configs to .ld
* Decide whether to wrap Xilinx IPs in top level or keep the IP instatiation
* Design Xilinx IPs simulation flow
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

# ES Draft Project Ideas
- SoC-independent:
	1. Autogenerate linker script + Xilinx AXI crossbar address map from a configuration file
      - Use same syntax as device tree address ranges
	2. Bare-metal driver xlnx axi uart in C, not asssemby
		- Host is the PS Cortex-A (on Zybo), not a RISC-V core
	3. Verify jtag2axi integration and develop minimal bootrom
		- Can leverage spike and RISC-V GCC from CE2/APC demo
- Soc-dependent?
	4. ???
