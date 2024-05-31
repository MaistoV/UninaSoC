# Copyright 2018 ETH Zurich and University of Bologna.
# Solderpad Hardware License, Version 0.51, see LICENSE for details.
# SPDX-License-Identifier: SHL-0.51
#
# Author: Florian Zaruba <zarubaf@iis.ee.ethz.ch>

open_hw_manager

connect_hw_server -url $::env(XILINX_HW_SERVER_HOST):$::env(XILINX_HW_SERVER_PORT)
open_hw_target $::env(XILINX_HW_SERVER_HOST):$::env(XILINX_HW_SERVER_PORT)/$::env(XILINX_FPGA_PATH)

if {$::env(XILINX_BOARD) eq "genesys2"} {
  set hw_device [get_hw_devices xc7k325t_0]
}
if {$::env(XILINX_BOARD) eq "vcu128"} {
  set hw_device [get_hw_devices xcvu37p_0]
}

set_property PARAM.FREQUENCY 15000000 [get_hw_targets *]

current_hw_device $hw_device
set_property PROGRAM.FILE $::env(XILINX_BITSTREAM) $hw_device
program_hw_devices $hw_device
refresh_hw_device [lindex $hw_device 0]

puts "Query the design"
# Debug
report_property -all [get_hw_targets]
# Search for hw probes
refresh_hw_device -update_hw_probes false [lindex [get_hw_devices $::env(XILINX_FPGA_DEVICE)] 0]