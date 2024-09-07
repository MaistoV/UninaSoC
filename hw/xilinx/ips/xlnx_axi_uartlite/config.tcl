# Import IP
create_ip -name axi_uartlite -vendor xilinx.com -library ip -version 2.0 -module_name $::env(IP_NAME)
# Configure IP
set_property -dict [list CONFIG.C_BAUDRATE             {115200}    \
                         CONFIG.C_S_AXI_ACLK_FREQ_HZ   {300000000} \
                         CONFIG.C_S_AXI_ACLK_FREQ_HZ_d {300}       \
                         CONFIG.C_DATA_BITS            {7}         \
                    ] [get_ips $::env(IP_NAME)]
