# Variables
PYTHON ?= python3.10 # Requires >= 3.10

# # Config csv and output tcl for main bus
# CONFIG_CSV_MBUS ?= ${CONFIG_ROOT}/configs/config.csv
# OUTPUT_TCL_FILE_MBUS ?= ${XILINX_ROOT}/ips/common/xlnx_axi_crossbar/config.tcl

# # Config csv and output tcl for peripheral bus
# CONFIG_CSV_PBUS ?= ${CONFIG_ROOT}/configs/config_pbus.csv
# OUTPUT_TCL_FILE_PBUS ?= ${XILINX_ROOT}/ips/common/xlnx_axilite_crossbar/config.tcl

all: config_main_bus config_peripheral_bus config_ld config_xilinx

config_%_bus: CONFIG_CSV = ${CONFIG_ROOT}/configs/config_$*_bus_${SOC_CONFIG}.csv
config_%_bus: OUTPUT_TCL_FILE = ${XILINX_ROOT}/ips/common/xlnx_$*_crossbar/config.tcl
config_%_bus:
	${PYTHON} ${CONFIG_ROOT}/axi_memory_map/create_crossbar_config.py \
		${CONFIG_CSV} \
		${OUTPUT_TCL_FILE}
	@echo "[CONFIG] Output file is at ${OUTPUT_TCL_FILE}"

# csv array for the create linker script
CONFIG_CSVS ?= ${CONFIG_ROOT}/configs/config_main_bus_${SOC_CONFIG}.csv \
               ${CONFIG_ROOT}/configs/config_peripheral_bus_${SOC_CONFIG}.csv

OUTPUT_LD_FILE ?= ${SW_ROOT}/SoC/common/UninaSoC.ld
config_ld:
	${PYTHON} ${CONFIG_ROOT}/axi_memory_map/create_linker_script.py \
		${CONFIG_CSVS} \
		${OUTPUT_LD_FILE}
	@echo "[CONFIG] Output file is at ${OUTPUT_LD_FILE}"

# Update config in Makefile
CONFIG_CSV ?= ${CONFIG_ROOT}/configs/config_main_bus_${SOC_CONFIG}.csv
OUTPUT_MK_FILE ?= ${XILINX_ROOT}/axi_config.mk
config_xilinx:
	export AXI_ADDR_WIDTH=$(shell grep "\bADDR_WIDTH\b" ${CONFIG_CSV} | awk -F "," '{print $$2}'); \
	export AXI_DATA_WIDTH=$(shell grep "\bDATA_WIDTH\b" ${CONFIG_CSV} | awk -F "," '{print $$2}'); \
	export AXI_ID_WIDTH=$(shell grep "\bID_WIDTH\b" 	${CONFIG_CSV} | awk -F "," '{print $$2}'); \
	sed -E -i "s/AXI_ADDR_WIDTH.?\?=.+/AXI_ADDR_WIDTH \?= $${AXI_ADDR_WIDTH}/g" ${OUTPUT_MK_FILE}; \
	sed -E -i "s/AXI_DATA_WIDTH.?\?=.+/AXI_DATA_WIDTH \?= $${AXI_DATA_WIDTH}/g" ${OUTPUT_MK_FILE}; \
	sed -E -i "s/AXI_ID_WIDTH.?\?=.+/AXI_ID_WIDTH \?= $${AXI_ID_WIDTH}/g" 		${OUTPUT_MK_FILE}
	@echo "[CONFIG] Output file is at ${OUTPUT_MK_FILE}"
