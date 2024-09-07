# Variables

all: xilinx hw sw

hw:

xilinx:
	${MAKE} -C ${XILINX_ROOT}

.PHONY: 
sw:
	${MAKE} -C ${SW_ROOT}

.PHONY: sim xilinx sw



