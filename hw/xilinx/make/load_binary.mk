# Description: Make target to load binaries to SoC memory and interact with debugger

###############
# Load Binary #
###############

# For CPUs that does not support debuggers yet

BIN_PATH ?= ${SW_ROOT}/SoC/examples/blinky/bin/blinky.bin
BASE_ADDRESS ?= 0x00000000                        # BRAM base address
LOAD_BINARY_READBACK ?= false                     # Whether to readback and check the loaded binary or not

# Load the binary into SoC memory (BRAM for now)
# Call the specific load script based on the SOC_CONFIG (HPC or EMBEDDED)
load_binary: load_binary_${SOC_CONFIG}

# Write the binary to BRAM through jtag2axi
load_binary_embedded: ${BIN_PATH}
	${XILINX_VIVADO} \
		-source ${XILINX_SYNTH_TCL_ROOT}/jtag2axi_load_binary.tcl \
		-tclargs ${BIN_PATH} ${BASE_ADDRESS} ${LOAD_BINARY_READBACK}

# Write the binary to BRAM/DDR through XDMA
load_binary_hpc: ${BIN_PATH}
	@bash -c "source ${XILINX_SYNTH_TCL_ROOT}/xdma_load_binary.sh ${BIN_PATH} ${BASE_ADDRESS} ${LOAD_BINARY_READBACK}"

############
# Load ELF #
############
# In case a debug module is available
# Use XSDB as backend and GDB as a loader/debugger

XSDB ?= xsdb
ELF_PATH ?= ${SW_ROOT}/SoC/examples/blinky/bin/blinky.elf
# 32-bit RISC-V port exposed by Vivado HW Server is 3004
XSDB_DEBUG_PORT ?= 3004

# Load program directly with XSDB
xsdb_run_elf:
	${XSDB} ${XILINX_SYNTH_TCL_ROOT}/xsdb_run_elf.tcl ${ELF_PATH} ${XILINX_BITSTREAM}

# Use XSDB as a backend
debug_backend:
	${XSDB} -interactive ${XILINX_SYNTH_TCL_ROOT}/xsdb_connect.tcl

# Use GDB to load the ELF and run (open the backend in a shell before) (TO TEST)
debug_run:
	@bash -c "source ${XILINX_SYNTH_TCL_ROOT}/run_gdb.sh ${ELF_PATH} ${XSDB_DEBUG_PORT}"

# PHONIES
.PHONY: load_binary load_binary_embedded load_binary_hpc xsdb_run_elf debug_backend debug_run

###########
# OpenOCD #
###########
OPENOCD ?= openocd
OPENOCD_TARGET ?= nexysA7
OPENOCD_SCRIPT ?= ${XILINX_SYNTH_TCL_ROOT}/openocd_${OPENOCD_TARGET}.cfg
openocd_run:
	@echo "[INFO] Make sure to kill any instance of hw_server running on the target USB device"
	${OPENOCD} -f ${OPENOCD_SCRIPT}