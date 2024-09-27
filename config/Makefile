# Variables
PYTHON ?= python3.10 # Requires >= 3.10
CONFIG_CSV ?= ${CONFIG_ROOT}/axi_memory_map/configs/config.csv

all: config_axi config_ld

OUTPUT_TCL_FILE ?= ${XILINX_ROOT}/ips/xlnx_axi_crossbar/config.tcl
config_axi:
	${PYTHON} ${CONFIG_ROOT}/axi_memory_map/create_crossbar_config.py \
		${CONFIG_CSV} \
		${OUTPUT_TCL_FILE}
	@echo "Output file is at ${OUTPUT_TCL_FILE}"

OUTPUT_LD_FILE ?= ${SW_ROOT}/linker/UninaSoC.ld
config_ld:
	${PYTHON} ${CONFIG_ROOT}/axi_memory_map/create_linker_script.py \
		${CONFIG_CSV} \
		${OUTPUT_LD_FILE}
	@echo "Output file is at ${OUTPUT_LD_FILE}"

