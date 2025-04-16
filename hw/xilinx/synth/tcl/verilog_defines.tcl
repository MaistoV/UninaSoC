# Author: Vincenzo Maisto <vincenzo.maisto2@unina.it>
# Description: Define Verilog macros for build environment, in an opened project
# Input args:
#    None

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
lappend verilog_defines SYS_DATA_WIDTH=$::env(DATA_WIDTH)
lappend verilog_defines SYS_ADDR_WIDTH=$::env(ADDR_WIDTH)
lappend verilog_defines SYS_ID_WIDTH=$::env(ID_WIDTH)
lappend verilog_defines NUM_SI=$::env(NUM_SI)
lappend verilog_defines NUM_MI=$::env(NUM_MI)
lappend verilog_defines PBUS_NUM_MI=$::env(PBUS_NUM_MI)
# Core selection
lappend verilog_defines CORE_SELECTOR=$::env(CORE_SELECTOR)
# Clock domains
lappend verilog_defines MAIN_CLOCK_FREQ_MHZ=$::env(MAIN_CLOCK_FREQ_MHZ)
set clock_domain_list [split $::env(RANGE_CLOCK_DOMAINS) " "]
foreach clock_domain $clock_domain_list {
    lappend verilog_defines $clock_domain=$clock_domain
}

# Info
puts "\[INFO\] Verilog defines: $verilog_defines"

# Set property to list
set_property verilog_define $verilog_defines [current_fileset]
