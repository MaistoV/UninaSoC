#!/bin/bash
# Author: Stefano Mercogliano <stefano.mercogliano@unina.it>
# Description: Launch GDB with a target ELF file and connecting to a specific backend port


EXPECTED_ARGC=2;
ARGC=$#;

# Print the right usage
help (){
    echo  "Usage: source ${BASH_SOURCE[0]} <elf_name> <backend_port>";
    echo  "    elf_name         :  path to the elf file";
    echo  "    backend_port     :  port backend (3333 for openocd, 3004 for vivado hw_server riscv 32 bit)";
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

echo "Running GDB";
$(riscv32-unknown-elf-gdb $ELF_NAME -ex 'target extended-remote:'$BACKEND_PORT -ex 'load $(ELF_PATH)'); 
