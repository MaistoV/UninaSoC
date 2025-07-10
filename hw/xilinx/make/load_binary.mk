# Author: Vincenzo Maisto <vincenzo.maisto2@unina.it>
# Author: Stefano Mercogliano <stefano.mercogliano@unina.it>
# Description: Make target to load binaries to SoC memory and interact with debugger

# Get XLEN for SoC Configuration
include ${XILINX_ROOT}/make/config.mk

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

######################
# Load ELF - Backend #
######################

# To load a program as an .elf, a Debug Module must be available
# Depending on the selected CPU, two backends flows are supported

# Path to target elf
ELF_PATH ?= ${SW_ROOT}/SoC/examples/blinky/bin/blinky.elf

# Use XSDB as a backend
XSDB ?= xsdb
# 32-bit RISC-V port exposed by Vivado HW Server is 3004, while it is 3005 for 64_bit
# If using OpenOCD, we always connect to port 3004
DEBUG_PORT ?= 3004

xsdb_run:
	${XSDB} -interactive ${XILINX_SCRIPTS_LOAD_ROOT}/xsdb_backend.tcl

# Use openOCD as a backed
OPENOCD ?= openocd
OPENOCD_SCRIPT ?= ${XILINX_SCRIPTS_LOAD_ROOT}/openocd.cfg

openocd_run:
	@echo "[INFO] Make sure to kill any instance of hw_server running on the target USB device"
	${OPENOCD} -f ${OPENOCD_SCRIPT}

##################################
# Load ELF - Debugger and Loader #
##################################

# Use GDB to load the ELF and run (open the backend in a shell before)

gdb_run:
	@bash -c "source ${XILINX_SCRIPTS_LOAD_ROOT}/run_gdb.sh ${ELF_PATH} ${DEBUG_PORT} ${XLEN}"

xsdb_run_elf:
	${XSDB} ${XILINX_SCRIPTS_LOAD_ROOT}/xsdb_run_elf.tcl ${ELF_PATH}

###########
# PHONIES #
###########

.PHONY: load_binary load_binary_embedded load_binary_hpc xsdb_run openocd_run gdb_run
