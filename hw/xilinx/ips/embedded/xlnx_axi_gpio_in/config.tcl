
# Import IP
create_ip -name axi_gpio -vendor xilinx.com -library ip -version 2.0 -module_name $::env(IP_NAME)

# Configure IP
set_property -dict [list CONFIG.C_GPIO_WIDTH {1} \
                        CONFIG.C_ALL_INPUTS  {1} \
                        CONFIG.C_ALL_OUTPUTS {0} \
                        CONFIG.C_IS_DUAL     {0} \
                    ] [get_ips $::env(IP_NAME)]

