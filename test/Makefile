
FILE=${ROOT_DIR}/sw/SoC/examples/hello_world/bin/hello_world.elf

# Limit the number of parallel Vivado instances
MAX_VIVADO_INSTANCES ?= 6 # This should be safe for a 16-cores CPU


all: clean build_hardware flash_bitstream gdb_run

gdb_run: openocd_run
	riscv32-unknown-elf-gdb -ex "target extended-remote :3004"

# -ex "target extended-remote :3004" -ex "file $FILE" -ex "load" -ex "run"

# Use openOCD as a backed
OPENOCD ?= openocd
OPENOCD_SCRIPT ?= ${XILINX_SCRIPTS_LOAD_ROOT}/openocd.cfg

# TODO: KILL THE HARDWARE SERVER FIRST
openocd_run:
	@echo "[INFO] Make sure to kill any instance of hw_server running on the target USB device"
	${OPENOCD} -f ${OPENOCD_SCRIPT}

# TEST: Flash the bitsream
flash_bistream: build_hardware
	@echo "[TEST] flashing the bitstream..."
	${MAKE} -C ${XILINX_ROOT} program_bitstream
	@echo "[TEST] flashing the bitstream passed!"

# TEST build the hardware
build_hardware: clean units config
	@echo "[TEST] building the hardware..."
	${MAKE} -C ${XILINX_ROOT} -j ${MAX_VIVADO_INSTANCES}
	@echo "[TEST] building the hardware passed!"

# TEST build the software
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


.PHONY: clean build_hardware flash_bistream gdb_run openocd_run config build_software units

# screen /dev/serial/by-id/usb-FTDI_FT232R_USB_UART_A5069RR4-if00-port0 9600