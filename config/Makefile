# Variables
PYTHON ?= python3.10 # Requires >= 3.10

# csv array for check config and create linker script
CONFIG_CSVS ?= ${CONFIG_ROOT}/configs/${SOC_CONFIG}/config_main_bus.csv \
			   ${CONFIG_ROOT}/configs/${SOC_CONFIG}/config_peripheral_bus.csv

all: config_main_bus config_peripheral_bus config_ld config_xilinx

config_main_bus:
config_peripheral_bus:
config_%_bus: CONFIG_CSV = ${CONFIG_ROOT}/configs/${SOC_CONFIG}/config_$*_bus.csv
config_%_bus: OUTPUT_TCL_FILE = ${XILINX_ROOT}/ips/common/xlnx_$*_crossbar/config.tcl
config_%_bus: config_check
	${PYTHON} ${CONFIG_ROOT}/scripts/create_crossbar_config.py \
		${CONFIG_CSV} \
		${OUTPUT_TCL_FILE}
	@echo "[CONFIG] Output file is at ${OUTPUT_TCL_FILE}"
	${PYTHON} ${CONFIG_ROOT}/axi_memory_map/declare_and_concat_buses_rtl.py ${CONFIG_CSV}


OUTPUT_LD_FILE ?= ${SW_ROOT}/SoC/common/UninaSoC.ld
config_ld:
	${PYTHON} ${CONFIG_ROOT}/scripts/create_linker_script.py \
		${CONFIG_CSVS} \
		${OUTPUT_LD_FILE}
	@echo "[CONFIG] Output file is at ${OUTPUT_LD_FILE}"


config_check:
	${PYTHON} ${CONFIG_ROOT}/scripts/check_config.py ${CONFIG_CSVS}

# Update config in Makefile
OUTPUT_MK_FILE ?= ${XILINX_ROOT}/make/config.mk
config_xilinx:
	${CONFIG_ROOT}/scripts/config_xilinx.sh ${CONFIG_CSVS} ${OUTPUT_MK_FILE}

