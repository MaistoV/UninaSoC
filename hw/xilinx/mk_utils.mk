# Description: Hold all the Xilinx-related utility targets

# Open project in TCL mode
open_prj:
	cd ${XILINX_PROJECT_BUILD_DIR};			\
	${XILINX_VIVADO_ENV} ${XILINX_VIVADO_CMD} \
	-mode tcl ${XILINX_PROJECT_NAME}.xpr

# Open project and GUI
open_gui:
	cd ${XILINX_PROJECT_BUILD_DIR};			\
	${XILINX_VIVADO_ENV} ${XILINX_VIVADO_CMD} \
	-mode gui ${XILINX_PROJECT_NAME}.xpr

# Start hardware server
start_hw_server:
	${XILINX_HW_SERVER} -d -L- -stcp::${XILINX_HW_SERVER_PORT}

# Open Vivado hardware manager in tcl mode
open_hw_manager:
	${XILINX_VIVADO_ENV} ${XILINX_VIVADO_CMD} -mode tcl \
		-source ${XILINX_SYNTH_TCL_ROOT}/$@.tcl

# Open ILA dashboard GUI
open_ila:
		${XILINX_VIVADO_ENV} ${XILINX_VIVADO_CMD} -mode gui \
		-source ${XILINX_SYNTH_TCL_ROOT}/open_hw_manager.tcl \
		-source ${XILINX_SYNTH_TCL_ROOT}/set_ila_trigger.tcl

vio_reset:
	${XILINX_VIVADO_ENV} ${XILINX_VIVADO} \
		-source ${XILINX_SYNTH_TCL_ROOT}/open_hw_manager.tcl \
		-source ${XILINX_SYNTH_TCL_ROOT}/vio_reset_core.tcl

program_bitstream:
	${XILINX_VIVADO} \
		-source ${XILINX_SYNTH_TCL_ROOT}/open_hw_manager.tcl \
		-source ${XILINX_SYNTH_TCL_ROOT}/$@.tcl

# PHONIES
.PHONY: open_prj open_gui start_hw_server open_hw_manager open_ila vio_reset program_bitstream
