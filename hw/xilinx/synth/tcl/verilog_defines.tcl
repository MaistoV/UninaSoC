# Author: Vincenzo Maisto <vincenzo.maisto2@unina.it>
# Description: Define Verilog macros for build environment, in an opened project
# Input args:
#	None

# Prepare list
set verilog_defines ""

# HPC/EMBEDDED
if { "$::env(SOC_CONFIG)" == "hpc" } {
    lappend verilog_defines HPC=1
} elseif { "$::env(SOC_CONFIG)" == "embedded" } {
    lappend verilog_defines EMBEDDED=1
} else {
    puts "Unsupported board $::env(SOC_CONFIG)"
    exit 1
}

# AXI config
lappend verilog_defines AXI_DATA_WIDTH=$::env(AXI_DATA_WIDTH)
lappend verilog_defines AXI_ADDR_WIDTH=$::env(AXI_ADDR_WIDTH)
lappend verilog_defines AXI_ID_WIDTH=$::env(AXI_ID_WIDTH)
lappend verilog_defines CORE_SELECTOR=$::env(CORE_SELECTOR)

# Set property to list
set_property verilog_define $verilog_defines [current_fileset]
