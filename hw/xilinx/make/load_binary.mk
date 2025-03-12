# Author: Vincenzo Maisto <vincenzo.maisto2@unina.it>
# Author: Stefano Mercogliano <stefano.mercogliano@unina.it>
# Description: Make target to load binaries to SoC memory and interact with debugger

# Common scripts directory
XILINX_SCRIPTS_LOAD_ROOT := ${XILINX_SCRIPT_ROOT}/load_binary

###############
# Load Binary #
###############

# For CPUs that does not support debuggers yet

# Path to target binary
BIN_PATH ?= ${SW_ROOT}/SoC/examples/blinky/bin/blinky.bin
# BRAM base address
BASE_ADDRESS ?= 0x00000000
# Whether to readback and check the loaded binary or not
LOAD_BINARY_READBACK ?= false

# Load the binary into SoC memory (BRAM for now)
# Call the specific load script based on the SOC_CONFIG (HPC or EMBEDDED)
load_binary: load_binary_${SOC_CONFIG}

# Write the binary to BRAM through jtag2axi
load_binary_embedded: ${BIN_PATH}
	${XILINX_VIVADO} \
		-source ${XILINX_SCRIPT_ROOT}/utils/open_hw_manager.tcl \
		-source ${XILINX_SCRIPTS_LOAD_ROOT}/jtag2axi_load_binary.tcl \
		-tclargs ${BIN_PATH} ${BASE_ADDRESS} ${LOAD_BINARY_READBACK}

# Write the binary to BRAM/DDR through XDMA
load_binary_hpc: ${BIN_PATH}
	@bash -c "source ${XILINX_SCRIPTS_LOAD_ROOT}/xdma_load_binary.sh ${BIN_PATH} ${BASE_ADDRESS} ${LOAD_BINARY_READBACK}"

############
# Load ELF #
############
# In case a debug module is available
# Use XSDB as backend and GDB as a loader/debugger

XSDB ?= xsdb
# Path to target elf
ELF_PATH ?= ${SW_ROOT}/SoC/examples/blinky/bin/blinky.elf
# 32-bit RISC-V port exposed by Vivado HW Server is 3004
XSDB_DEBUG_PORT ?= 3004

# Load program directly with XSDB
xsdb_run_elf:
	${XSDB} ${XILINX_SCRIPTS_LOAD_ROOT}/$@.tcl ${ELF_PATH} ${XILINX_BITSTREAM}

# Use XSDB as a backend
xsdb_backend:
	${XSDB} -interactive ${XILINX_SCRIPTS_LOAD_ROOT}/$@.tcl

# Use GDB to load the ELF and run (open the backend in a shell before) (TO TEST)
run_gdb:
	@bash -c "source ${XILINX_SCRIPTS_LOAD_ROOT}/$@.sh ${ELF_PATH} ${XSDB_DEBUG_PORT}"

# PHONIES
.PHONY: load_binary load_binary_embedded load_binary_hpc xsdb_run_elf xsdb_backend debug_run

###########
# OpenOCD #
###########
OPENOCD ?= openocd
OPENOCD_TARGET ?= nexysA7
OPENOCD_SCRIPT ?= ${XILINX_SYNTH_TCL_ROOT}/openocd_${OPENOCD_TARGET}.cfg
run_openocd:
	@echo "[INFO] Make sure to kill any instance of hw_server running on the target USB device"
	${OPENOCD} -f ${OPENOCD_SCRIPT}
