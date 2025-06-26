# Author: Manuel Maddaluno <manuel.maddaluno@unina.it>
# Description: CMAC configuration file

# TODO: For now the GT_DRP_CLK, the DIFFCLK_BOARD_INTERFACE, the GT_GROUP_SELECT, and the ETHERNET_BOARD_INTERFACE are hardcoded. Need to be parametrized

create_ip -name cmac_usplus -vendor xilinx.com -library ip -version 3.1 -module_name $::env(IP_NAME)

set_property -dict [list \
  CONFIG.CMAC_CAUI4_MODE {1} \
  CONFIG.CMAC_CORE_SELECT {CMACE4_X0Y8} \
  CONFIG.DIFFCLK_BOARD_INTERFACE {qsfp0_156mhz} \
  CONFIG.ENABLE_AXI_INTERFACE {1} \
  CONFIG.ETHERNET_BOARD_INTERFACE {qsfp0_4x} \
  CONFIG.GT_GROUP_SELECT {X1Y44~X1Y47} \
  CONFIG.RX_MAX_PACKET_LEN {1518} \
  CONFIG.USER_INTERFACE {AXIS} \
  CONFIG.INCLUDE_RS_FEC {1} \
] [get_ips $::env(IP_NAME)]

# TODO: This GT_DRP_CLK must be the same as MBUS clock
set_property CONFIG.GT_DRP_CLK 50 [get_ips $::env(IP_NAME)]