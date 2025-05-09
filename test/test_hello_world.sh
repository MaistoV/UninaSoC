#!/bin/bash
# Author: Manuel Maddaluno <manuel.maddaluno@unina.it>
# Description: Script to test the hello_world example application

# Printing colors
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# We don't have this variable here, only in environment.mk
XILINX_VIVADO_CMD=vivado

# Close the hardware server
echo -e "${NC}Launching Vivado to close the hardware server"
${XILINX_VIVADO_CMD} -mode batch -source ${TEST_ROOT}/close_hw_manager.tcl -notrace -nolog -nojournal

# Launch OpenOCD
OPENOCD=openocd
OPENOCD_SCRIPT=${XILINX_SCRIPT_ROOT}/load_binary/openocd.cfg
echo -e "${NC}Launching OpenOCD${NC}"
${OPENOCD} -f ${OPENOCD_SCRIPT} > /dev/null 2>&1 & OPENOCD_PID=$!

# Launch the UART host application (screen for embedded, virtual_uart for hpc)
echo -e "${NC}Launching uart host application"
# SoC profile embedded
if [ "${SOC_CONFIG}" == "embedded" ]; then
    PHYSICAL_UART_BAUD_RATE=9600
    # TODO: test this
    screen /dev/serial/by-id/usb-FTDI_FT232R_USB_UART_A5069RR4-if00-port0 $PHYSICAL_UART_BAUD_RATE > ./tmp.txt 2>&1 & UART_PID=$!
# SoC profile hpc
elif [ "${SOC_CONFIG}" == "hpc" ]; then
    VIRTUAL_UART_BASE_ADDR=0x82020000
    sudo ${SW_HOST_ROOT}/virtual_uart/bin/virtual_uart $VIRTUAL_UART_BASE_ADDR > ./tmp.txt 2>&1 & UART_PID=$!
else
    echo -e "${RED}[ERROR] The provided SoC profile (${SOC_CONFIG}) is not supported${NC}"
    exit 1
fi

# Launch GDB and run the SoC application
echo -e "${NC}Launching GDB"
FILE=${SW_SOC_ROOT}/examples/hello_world/bin/hello_world.elf
BACKEND_PORT=3004
$(${XILINX_SCRIPT_ROOT}/load_binary/run_gdb.sh $FILE $BACKEND_PORT < <(echo "run")) > /dev/null 2>&1 & GDB_PID=$!

# Wait for the application to write the expected output
sleep 5

# Terminate the uart host application (screen for embedded, virtual_uart for hpc)
echo -e "${NC}Killing uart host application (PID $UART_PID)${NC}"
sudo kill $UART_PID
wait $UART_PID 2>/dev/null

# Terminate gdb
echo -e "${NC}Killing GDB (PID $GDB_PID)${NC}"
sudo kill $GDB_PID
wait $GDB_PID 2>/dev/null

# Terminate openocd
echo -e "${NC}Killing OpenOCD (PID $OPENOCD_PID)${NC}"
sudo kill $OPENOCD_PID
wait $OPENOCD_PID 2>/dev/null

# Check the output
echo -e "${NC}Checking the output${NC}"

output=$(cat ./tmp.txt)
expected_output="Hello World!"$'\n'$'\r'

rm ./tmp.txt

if [[ "$output" == $expected_output ]]; then
    echo -e "${GREEN}[SUCCESS] Hello World test passed${NC}"
    exit 0
else
   echo -e "${RED}[ERROR] Hello World test failed${NC}"
   exit 1
fi
