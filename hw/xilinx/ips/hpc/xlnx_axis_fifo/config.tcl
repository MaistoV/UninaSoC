# Author: Manuel Maddaluno <manuel.maddaluno@unina.it>
# Description: AXI Stream FIFO (axi_fifo_mm_s) IP configuration file
#              This IP is used for converting AXI Stream (from/to the CMAC) to AXI4 (from/to the core)

create_ip -name axi_fifo_mm_s -vendor xilinx.com -library ip -version 4.3 -module_name $::env(IP_NAME)

set_property -dict [list \
  CONFIG.C_DATA_INTERFACE_TYPE {1} \
  CONFIG.C_HAS_AXIS_TKEEP {true} \
  CONFIG.C_S_AXI4_DATA_WIDTH {512} \
  CONFIG.C_USE_TX_CTRL {0} \
  CONFIG.C_AXI4_BASEADDR {0x00060000} \
] [get_ips $::env(IP_NAME)]