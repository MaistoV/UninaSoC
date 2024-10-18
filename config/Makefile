# Variables
PYTHON ?= python3.10 # Requires >= 3.10
CONFIG_CSV ?= ${CONFIG_ROOT}/configs/config.csv

all: config_axi config_ld config_xilinx

OUTPUT_TCL_FILE ?= ${XILINX_ROOT}/ips/common/xlnx_axi_crossbar/config.tcl
config_axi:
	${PYTHON} ${CONFIG_ROOT}/axi_memory_map/create_crossbar_config.py \
		${CONFIG_CSV} \
		${OUTPUT_TCL_FILE}
	@echo "[CONFIG] Output file is at ${OUTPUT_TCL_FILE}"

OUTPUT_LD_FILE ?= ${SW_ROOT}/linker/UninaSoC.ld
config_ld:
	${PYTHON} ${CONFIG_ROOT}/axi_memory_map/create_linker_script.py \
		${CONFIG_CSV} \
		${OUTPUT_LD_FILE}
	@echo "[CONFIG] Output file is at ${OUTPUT_LD_FILE}"

# Update config in Makefile
OUTPUT_MK_FILE ?= ${XILINX_ROOT}/axi_config.mk
config_xilinx:
	export AXI_ADDR_WIDTH=$(shell grep "\bADDR_WIDTH\b" ${CONFIG_CSV} | awk -F "," '{print $$2}'); \
	export AXI_DATA_WIDTH=$(shell grep "\bDATA_WIDTH\b" ${CONFIG_CSV} | awk -F "," '{print $$2}'); \
	export AXI_ID_WIDTH=$(shell grep "\bID_WIDTH\b" 	${CONFIG_CSV} | awk -F "," '{print $$2}'); \
	sed -E -i "s/AXI_ADDR_WIDTH.?\?=.+/AXI_ADDR_WIDTH \?= $${AXI_ADDR_WIDTH}/g" ${OUTPUT_MK_FILE}; \
	sed -E -i "s/AXI_DATA_WIDTH.?\?=.+/AXI_DATA_WIDTH \?= $${AXI_DATA_WIDTH}/g" ${OUTPUT_MK_FILE}; \
	sed -E -i "s/AXI_ID_WIDTH.?\?=.+/AXI_ID_WIDTH \?= $${AXI_ID_WIDTH}/g" 		${OUTPUT_MK_FILE}
	@echo "[CONFIG] Output file is at ${OUTPUT_MK_FILE}"
