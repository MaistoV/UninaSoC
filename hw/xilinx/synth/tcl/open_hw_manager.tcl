# Author: Vincenzo Maisto <vincenzo.maisto2@unina.it>
# Description: Open Vivado Hardware Manager

# First check if the probe file exists
exec ls $::env(XILINX_PROJECT_LTX) 

# Connect to hw server
open_hw_manager
set url $::env(XILINX_HW_SERVER_HOST):$::env(XILINX_HW_SERVER_PORT)
if {[catch {connect_hw_server -url $url} 0]} {
    puts stderr "WARNING: Another connection is already up, proceeding using the existing connection instead"
}
set target $::env(XILINX_HW_SERVER_HOST):$::env(XILINX_HW_SERVER_PORT)/$::env(XILINX_HW_SERVER_FPGA_PATH)
open_hw_target $target
set_property PARAM.FREQUENCY 15000000 [get_hw_targets $target]

puts "Using probe file $::env(XILINX_PROJECT_LTX)"
set_property PROBES.FILE      $::env(XILINX_PROJECT_LTX) [get_hw_devices $::env(XILINX_FPGA_DEVICE)]
set_property FULL_PROBES.FILE $::env(XILINX_PROJECT_LTX) [get_hw_devices $::env(XILINX_FPGA_DEVICE)]
current_hw_device                                        [get_hw_devices $::env(XILINX_FPGA_DEVICE)]

puts "Query the design"
# Debug
report_property -all [get_hw_targets $target]
# Search for hw probes
refresh_hw_device [lindex [get_hw_devices $::env(XILINX_FPGA_DEVICE)] 0]
