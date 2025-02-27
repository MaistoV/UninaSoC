# Variables
PYTHON ?= python3.10 # Requires >= 3.10

all: config_main_bus config_peripheral_bus config_ld config_xilinx

config_main_bus:
config_peripheral_bus:
config_%_bus: CONFIG_CSV = ${CONFIG_ROOT}/configs/${SOC_CONFIG}/config_$*_bus.csv
config_%_bus: OUTPUT_TCL_FILE = ${XILINX_ROOT}/ips/common/xlnx_$*_crossbar/config.tcl
config_%_bus:
	${PYTHON} ${CONFIG_ROOT}/axi_memory_map/create_crossbar_config.py \
		${CONFIG_CSV} \
		${OUTPUT_TCL_FILE}
	@echo "[CONFIG] Output file is at ${OUTPUT_TCL_FILE}"

# csv array for the create linker script
CONFIG_CSVS ?= ${CONFIG_ROOT}/configs/${SOC_CONFIG}/config_main_bus.csv \
               ${CONFIG_ROOT}/configs/${SOC_CONFIG}/config_peripheral_bus.csv

OUTPUT_LD_FILE ?= ${SW_ROOT}/SoC/common/UninaSoC.ld
config_ld:
	${PYTHON} ${CONFIG_ROOT}/axi_memory_map/create_linker_script.py \
		${CONFIG_CSVS} \
		${OUTPUT_LD_FILE}
	@echo "[CONFIG] Output file is at ${OUTPUT_LD_FILE}"

# Update config in Makefile
CONFIG_CSV ?= ${CONFIG_ROOT}/configs/${SOC_CONFIG}/config_main_bus.csv
OUTPUT_MK_FILE ?= ${XILINX_ROOT}/make/config.mk
config_xilinx:
	export AXI_ADDR_WIDTH=$(shell grep "\bADDR_WIDTH\b" ${CONFIG_CSV} | awk -F "," '{print $$2}'); \
	export AXI_DATA_WIDTH=$(shell grep "\bDATA_WIDTH\b" ${CONFIG_CSV} | awk -F "," '{print $$2}'); \
	export AXI_ID_WIDTH=$(shell grep "\bID_WIDTH\b" 	${CONFIG_CSV} | awk -F "," '{print $$2}'); \
	sed -E -i "s/AXI_ADDR_WIDTH.?\?=.+/AXI_ADDR_WIDTH \?= $${AXI_ADDR_WIDTH}/g" ${OUTPUT_MK_FILE}; \
	sed -E -i "s/AXI_DATA_WIDTH.?\?=.+/AXI_DATA_WIDTH \?= $${AXI_DATA_WIDTH}/g" ${OUTPUT_MK_FILE}; \
	sed -E -i "s/AXI_ID_WIDTH.?\?=.+/AXI_ID_WIDTH \?= $${AXI_ID_WIDTH}/g" 		${OUTPUT_MK_FILE}
	@echo "[CONFIG] Output file is at ${OUTPUT_MK_FILE}"
