# Author: Vincenzo Maisto <vincenzo.maisto2@unina.it>
# Description: Mark nets in the post-syntesis netlist for debug

# System master AXI interface
#set_property MARK_DEBUG 1 [get_nets sys_master_u/m_axi_*]
set_property MARK_DEBUG 1 [get_nets rv_socket_u/rv_socket_data_*]
set_property MARK_DEBUG 1 [get_nets ddr4_channel_0_wrapper_u/s_axi*]