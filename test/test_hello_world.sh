#!/bin/bash
# Author: Manuel Maddaluno <manuel.maddaluno@unina.it>
# Description: Script to test the hello_world example application

# We don't have this variable here, only in environment.mk
XILINX_VIVADO_CMD=vivado

# Close the hardware server
${XILINX_VIVADO_CMD} -mode batch -source ${TEST_ROOT}/close_hw_manager.tcl -notrace -nolog -nojournal

# LAUNCH OPENOCD
OPENOCD=openocd
OPENOCD_SCRIPT=${XILINX_SCRIPT_ROOT}/load_binary/openocd.cfg
${OPENOCD} -f ${OPENOCD_SCRIPT}


# LAUNCH GDB
#   LOAD THE ELF
#   EXECUTE THE ELF
#   COMPARE THE EXPECTED OUTPUT



# gdb_run: openocd_run
# 	riscv32-unknown-elf-gdb -ex "target extended-remote :3004"

# # -ex "target extended-remote :3004" -ex "file $FILE" -ex "load" -ex "run"


# screen /dev/serial/by-id/usb-FTDI_FT232R_USB_UART_A5069RR4-if00-port0 9600