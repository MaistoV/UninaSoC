# Environment check
ifndef ROOT_DIR
$(error Setup script settings.sh has not been sourced, aborting)
endif

all: hw sw

config:
	${MAKE} -C ${CONFIG_ROOT}

hw: xilinx

xilinx: units config
	${MAKE} -C ${XILINX_ROOT}

units:
	${MAKE} -C ${HW_UNITS_ROOT}

sw: config
	${MAKE} -C ${SW_ROOT}

clean:
	${MAKE} -C ${XILINX_ROOT} clean clean_ips
	${MAKE} -C ${HW_UNITS_ROOT} clean
	${MAKE} -C ${SW_ROOT} clean

.PHONY: config hw sw xilinx units
