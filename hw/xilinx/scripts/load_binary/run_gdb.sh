#!/bin/bash
# Author: Stefano Mercogliano <stefano.mercogliano@unina.it>
# Description: Launch GDB with a target ELF file and connecting to a specific backend port


EXPECTED_ARGC=2;
ARGC=$#;

# Print the right usage
help (){
    echo  "Usage: source ${BASH_SOURCE[0]} <elf_name> <backend_port>";
    echo  "    elf_name         :  path to the elf file";
    echo  "    backend_port     :  port backend (We use 3004 for both vivado hw_server (32-bits) and openocd. 3005 for vivado hw_server riscv 64 bits)";
    return;
}

# Check the argc
if [ $ARGC -ne $EXPECTED_ARGC ];
then
    echo  "Invalid number of arguments, please check the inputs and try again";
    help;
    return 1;
fi

# Get the args
ELF_NAME=$1;
BACKEND_PORT=$2;

# Get the correct GDB XLEN version
mkfile=$SW_SOC_ROOT"/common/config.mk"
XLEN=$(grep -E '^XLEN\s*\?\=\s*[0-9]+' "$mkfile" | sed -E 's/^XLEN\s*\?\=\s*([0-9]+)/\1/')

echo "Running GDB $XLEN-bits version";
echo "Loading ELF $ELF_NAME";
echo "Connecting to port $BACKEND_PORT";

# Run GDB
riscv$XLEN-unknown-elf-gdb $ELF_NAME -ex 'target extended-remote:'$BACKEND_PORT -ex 'load '$ELF_NAME;