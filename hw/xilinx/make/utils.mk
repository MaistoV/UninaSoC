# Author: Vincenzo Maisto <vincenzo.maisto2@unina.it>
# Description: Hold all the Xilinx-related utility targets

# Common scripts directory
XILINX_SCRIPTS_UTILS_ROOT := ${XILINX_SCRIPT_ROOT}/utils

# Open project in TCL mode
open_prj:
	cd ${XILINX_PROJECT_BUILD_DIR}; \
	${XILINX_VIVADO_ENV} ${XILINX_VIVADO_CMD} \
	-mode tcl ${XILINX_PROJECT_NAME}.xpr

# Open project and GUI
open_gui:
	cd ${XILINX_PROJECT_BUILD_DIR}; \
	${XILINX_VIVADO_ENV} ${XILINX_VIVADO_CMD} \
	-mode gui ${XILINX_PROJECT_NAME}.xpr

# Start hardware server
start_hw_server:
	${XILINX_HW_SERVER} -d -L- -stcp::${XILINX_HW_SERVER_PORT}

# Open Vivado hardware manager in tcl mode
open_hw_manager:
	${XILINX_VIVADO_ENV} ${XILINX_VIVADO_CMD} -mode tcl \
		-source ${XILINX_SCRIPTS_UTILS_ROOT}/$@.tcl

# Open ILA dashboard GUI
open_ila:
		${XILINX_VIVADO_ENV} ${XILINX_VIVADO_CMD} -mode gui \
		-source ${XILINX_SCRIPTS_UTILS_ROOT}/open_hw_manager.tcl \
		-source ${XILINX_SCRIPTS_UTILS_ROOT}/set_ila_trigger.tcl

# Read back from address
OFFSET	?= 0x40000
NUM_BYTES ?= 16
readback_jtag2axi:
	${XILINX_VIVADO_ENV} ${XILINX_VIVADO} \
	-source ${XILINX_SCRIPTS_UTILS_ROOT}/open_hw_manager.tcl \
	-source ${XILINX_SCRIPTS_UTILS_ROOT}/$@.tcl -tclargs ${OFFSET} ${NUM_BYTES}

# Trigger a reset pulse on VIO probes
vio_resetn:
vio_%:
	${XILINX_VIVADO_ENV} ${XILINX_VIVADO} \
		-source ${XILINX_SCRIPTS_UTILS_ROOT}/open_hw_manager.tcl \
		-source ${XILINX_SCRIPTS_UTILS_ROOT}/vio_reset.tcl -tclargs $@

program_bitstream:
	${XILINX_VIVADO} \
		-source ${XILINX_SCRIPTS_UTILS_ROOT}/open_hw_manager.tcl \
		-source ${XILINX_SCRIPTS_UTILS_ROOT}/$@.tcl

# PHONIES
.PHONY: open_prj open_gui start_hw_server open_hw_manager open_ila program_bitstream
