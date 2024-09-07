# Author: Vincenzo Maisto <vincenzo.maisto2@unina.it>
# Description: Program bitstream

# Connects to hw_server and sets variable hw_device
source  $::env(XILINX_SYNTH_TCL_ROOT)/open_hw_manager.tcl

set_property PROGRAM.FILE $::env(XILINX_BITSTREAM) $hw_device
program_hw_devices $hw_device
refresh_hw_device [lindex $hw_device 0]

puts "Query the design"
# Debug
report_property -all [get_hw_targets]
# Search for hw probes
refresh_hw_device -update_hw_probes false [lindex [get_hw_devices $::env(XILINX_FPGA_DEVICE)] 0]