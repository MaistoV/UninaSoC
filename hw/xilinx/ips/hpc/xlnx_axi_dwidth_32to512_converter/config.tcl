# Author: Manuel Maddaluno <manuel.maddaluno@unina.it>
# Description: AXI Data Width Converter - Needed to link the AXI crossbar (in general the entire SoC 32 bits) to the DDR MIG (512 bit)

create_ip -name axi_dwidth_converter -vendor xilinx.com -library ip -version 2.1 -module_name $::env(IP_NAME)

set_property -dict [list \
  CONFIG.MI_DATA_WIDTH {512} \
  CONFIG.SI_DATA_WIDTH $::env(AXI_DATA_WIDTH) \
  CONFIG.SI_ID_WIDTH $::env(AXI_ID_WIDTH) \
] [get_ips $::env(IP_NAME)]