# Import IP
create_ip -name axi_crossbar -vendor xilinx.com -library ip -version 2.1 -module_name $::env(IP_NAME)
# Configure IP
set_property -dict [list CONFIG.NUM_SI {3}
                         CONFIG.ID_WIDTH {2}
                    ] [get_ips $::env(IP_NAME)]
