# Author: Manuel Maddaluno <manuel.maddaluno@unina.it>
# Description: Makefile to execute all the functional regressive tests:
#                  - Build the hardware (bitstream)
#                  - Program the FPGA with the bitstream
#                  - Build the software
#                  - Execute hello_world example application


# Limit the number of parallel Vivado instances
MAX_VIVADO_INSTANCES ?= 6 # This should be safe for a 16-cores CPU


all: hello_world

# TEST: Hello world
hello_world: build_hardware build_software
	@echo "[TEST] testing the hello_world example application..."
	@bash -c "source ${TEST_ROOT}/test_hello_world.sh"
	@echo "[TEST] testing the hello_world example application passed!"

# TEST: Flash the bitsream
program_bitstream: build_hardware
	@echo "[TEST] programming the bitstream..."
	${MAKE} -C ${XILINX_ROOT} program_bitstream
	@echo "[TEST] programming the bitstream passed!"

# TEST: Build the hardware
build_hardware: units config
	@echo "[TEST] building the hardware..."
	${MAKE} -C ${XILINX_ROOT} -j ${MAX_VIVADO_INSTANCES}
	@echo "[TEST] building the hardware passed!"

# TEST: Build the software
build_software: config
	@echo "[TEST] building the software..."
	${MAKE} -C ${SW_ROOT}
	@echo "[TEST] building the software passed!"

config:
	${MAKE} -C ${CONFIG_ROOT}

units:
	${MAKE} -C ${HW_UNITS_ROOT} -j ${MAX_VIVADO_INSTANCES}


clean:
	${MAKE} -C ${XILINX_ROOT} clean clean_ips
	${MAKE} -C ${HW_UNITS_ROOT} clean
	${MAKE} -C ${SW_ROOT} clean


.PHONY: clean build_hardware program_bitstream config build_software units

