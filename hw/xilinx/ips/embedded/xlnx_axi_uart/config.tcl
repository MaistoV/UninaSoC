
# Import IP
create_ip -name axi_uartlite -vendor xilinx.com -library ip -version 2.0 -module_name $::env(IP_NAME)
# Configure IP
set_property -dict [list                        \
                    CONFIG.C_BAUDRATE {115200}    \
                    CONFIG.C_DATA_BITS {8} \
                    CONFIG.C_S_AXI_ACLK_FREQ_HZ_d {100} \
                    CONFIG.PARITY {No_Parity} \
                      ] [get_ips $::env(IP_NAME)]

