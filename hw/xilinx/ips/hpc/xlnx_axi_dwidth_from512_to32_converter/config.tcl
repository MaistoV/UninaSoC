# Author: Manuel Maddaluno <manuel.maddaluno@unina.it>
# Description: AXI Data Width Converter - Needed to link the HBUS (512 bit) to CSR (32 bit) - mainly used in cmac_wrapper.sv

create_ip -name axi_dwidth_converter -vendor xilinx.com -library ip -version 2.1 -module_name $::env(IP_NAME)

set_property -dict [list \
  CONFIG.SI_DATA_WIDTH {512} \
  CONFIG.MI_DATA_WIDTH {32}  \
] [get_ips $::env(IP_NAME)]

# Use envvars out of list
set_property CONFIG.SI_ID_WIDTH    $::env(HBUS_ID_WIDTH)    [get_ips $::env(IP_NAME)]
