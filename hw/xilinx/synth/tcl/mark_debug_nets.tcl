# Author: Vincenzo Maisto <vincenzo.maisto2@unina.it>
# Description: Mark nets in the post-syntesis netlist for debug

# System master AXI interface
#set_property MARK_DEBUG 1 [get_nets sys_master_u/m_axi_rvalid*]

#set_property MARK_DEBUG 1 [get_nets custom_rv_plic_u/s_axi_ar*]
#set_property MARK_DEBUG 1 [get_nets custom_rv_plic_u/s_axi_r*]
#set_property MARK_DEBUG 1 [get_nets custom_rv_plic_u/s_axi_aw*]

#set_property MARK_DEBUG 1 [get_nets custom_rv_plic_u/s_axi_araddr*]
#set_property MARK_DEBUG 1 [get_nets custom_rv_plic_u/s_axi_arready*]
#set_property MARK_DEBUG 1 [get_nets custom_rv_plic_u/s_axi_arsize*]
#set_property MARK_DEBUG 1 [get_nets custom_rv_plic_u/s_axi_arvalid*]

#set_property MARK_DEBUG 1 [get_nets custom_rv_plic_u/s_axi_awaddr*]
#set_property MARK_DEBUG 1 [get_nets custom_rv_plic_u/s_axi_awready*]
#set_property MARK_DEBUG 1 [get_nets custom_rv_plic_u/s_axi_awsize*]
#set_property MARK_DEBUG 1 [get_nets custom_rv_plic_u/s_axi_awvalid*]

#set_property MARK_DEBUG 1 [get_nets custom_rv_plic_u/s_axi_rdata*]
#set_property MARK_DEBUG 1 [get_nets custom_rv_plic_u/s_axi_rready*]
#set_property MARK_DEBUG 1 [get_nets custom_rv_plic_u/s_axi_rresp*]
#set_property MARK_DEBUG 1 [get_nets custom_rv_plic_u/s_axi_rvalid*]

#set_property MARK_DEBUG 1 [get_nets custom_rv_plic_u/req_*]
#set_property MARK_DEBUG 1 [get_nets custom_rv_plic_u/rsp_*]

set_property MARK_DEBUG 1 [get_nets custom_rv_plic_u/irq_o*]
set_property MARK_DEBUG 1 [get_nets tim_u/interrupt*]
set_property MARK_DEBUG 1 [get_nets gpio_in_u/ip2intc_irpt*]
set_property MARK_DEBUG 1 [get_nets rvm_socket_u/irq_i*]

set_property MARK_DEBUG 1 [get_nets tim_u/s_axi_*]


#set_property MARK_DEBUG 1 [get_nets gpio_out_u/s_axi_ar*]
#set_property MARK_DEBUG 1 [get_nets gpio_out_u/s_axi_r*]

#set_property MARK_DEBUG 1 [get_nets tim_u/s_axi_ar*]
#set_property MARK_DEBUG 1 [get_nets tim_u/s_axi_r*]


