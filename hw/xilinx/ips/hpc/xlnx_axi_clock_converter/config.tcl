# Author: Manuel Maddaluno <manuel.maddaluno@unina.it>
# Description: AXI Clock Converter - Needed to link the AXI crossbar (in general the entire SoC 250 MHz) to the DDR MIG (300 MHz)

create_ip -name axi_clock_converter -vendor xilinx.com -library ip -version 2.1 -module_name $::env(IP_NAME)

set_property -dict [list \
    CONFIG.ACLK_ASYNC {1} \
    CONFIG.SYNCHRONIZATION_STAGES {4} \
] [get_ips $::env(IP_NAME)]

# Use envvars out of list
set_property CONFIG.DATA_WIDTH  $::env(DATA_WIDTH)  [get_ips $::env(IP_NAME)]
set_property CONFIG.ID_WIDTH    $::env(ID_WIDTH)    [get_ips $::env(IP_NAME)]