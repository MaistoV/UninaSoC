# Import IP by version
create_ip -name jtag_axi -vendor xilinx.com -library ip -version 1.2 -module_name $::env(IP_NAME)

# Configure IP
# - CONFIG.PROTOCOL {0} is AXI4, {2} is AXI4LITE
# - CONFIG.M_HAS_BURST {1} ALL BURST TYPES, {0} INCR BURST ONLY
set_property -dict [list CONFIG.PROTOCOL {0} \
                        CONFIG.M_AXI_DATA_WIDTH {32} \
                        CONFIG.M_AXI_ADDR_WIDTH {32} \
                        CONFIG.M_AXI_ID_WIDTH {2} \
                        CONFIG.RD_TXN_QUEUE_LENGTH {1} \
                        CONFIG.WR_TXN_QUEUE_LENGTH {1} \
                        CONFIG.M_HAS_BURST {1} \
    ] [get_ips $::env(IP_NAME)]
