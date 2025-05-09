# Author: Vincenzo Maisto <vincenzo.maisto2@unina.it>
# Description: Mark nets in the post-syntesis netlist for debug

# System master AXI interface
# set_property MARK_DEBUG 1 [get_nets sys_master_u/m_axi_*]

# Fetch PC
set_property MARK_DEBUG 1 [get_nets rvm_socket_u/core_veer.custom_veer_u/inst/veer_wrapper_dmi_u/veer/ifu/ifu_fetch_pc]

# AXI interfaces
# TBD