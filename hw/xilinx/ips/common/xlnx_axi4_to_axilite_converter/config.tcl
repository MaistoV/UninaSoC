# Import IP by version
create_ip -name axi_protocol_converter -vendor xilinx.com -library ip -version 2.1 -module_name $::env(IP_NAME)

# Configure IP
set_property -dict [list \
                CONFIG.Component_Name {$::env(IP_NAME)} \
                CONFIG.ADDR_WIDTH {32} \
                CONFIG.DATA_WIDTH {32} \
                CONFIG.ID_WIDTH {2} \
                CONFIG.MI_PROTOCOL {AXI4LITE} \
                CONFIG.READ_WRITE_MODE {READ_WRITE} \
                CONFIG.SI_PROTOCOL {AXI4} \
                CONFIG.TRANSLATION_MODE {2} \
    ] [get_ips $::env(IP_NAME)]

