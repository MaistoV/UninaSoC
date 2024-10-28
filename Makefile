# Environment check
ifndef ROOT_DIR
$(error Setup script settings.sh has not been sourced, aborting)
endif

all: config

hw:

xilinx: units
	${MAKE} -C ${XILINX_ROOT}

units:
	${MAKE} -C ${HW_UNITS_ROOT}

config:
	${MAKE} -C ${CONFIG_ROOT} ${CONFIG_CSV}

sw:
	${MAKE} -C ${SW_ROOT}

.PHONY: sim xilinx sw config
