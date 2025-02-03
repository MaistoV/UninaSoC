# Author: Vincenzo Maisto <vincenzo.maisto2@unina.it>
# Description: Basic XSDB script to run an ELF file

# Variables
# TODO: these should come either from args or env
set BITSTREAM /home/vincenzo/RISC-V/prjs/UninaSoC/verify/microblaze-v/hw/xilinx/build/uninasoc.runs/impl_1/uninasoc.bit
set ELF /home/vincenzo/RISC-V/prjs/UninaSoC/verify/microblaze-v/sw/SoC/examples/blinky/bin/blinky.elf

# Connect to local hw_server
connect
# Configure FPGA
fpga $BITSTREAM
# Filter and set target
targets -set -filter {name  =~ "*Hart #0*"}
# Reset target
rst -processor
# Load elf into memory
dow $ELF
# Wait 0.5 seconds
after 500
# Continue execution
con
# Wait for 5 seconds
# after 5000
# Stop program
# stop

