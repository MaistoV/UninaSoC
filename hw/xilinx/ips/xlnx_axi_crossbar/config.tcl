# Import IP
create_ip -name axi_crossbar -vendor xilinx.com -library ip -version 2.1 -module_name $::env(IP_NAME)
# Configure IP
set_property -dict [list CONFIG.M00_A00_ADDR_WIDTH  {16}
                         CONFIG.M00_A00_BASE_ADDR   {0x0000000040000000}
                         CONFIG.M01_A00_ADDR_WIDTH  {16}
                         CONFIG.M01_A00_BASE_ADDR   {0x0000000001000000}
                         CONFIG.NUM_MI              {2} #2 slaves
                         CONFIG.NUM_SI              {1} #1 master
                         CONFIG.ID_WIDTH {2}
                    ] [get_ips $::env(IP_NAME)]
