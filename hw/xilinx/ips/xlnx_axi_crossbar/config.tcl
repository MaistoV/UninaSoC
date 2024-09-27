# This file is auto-generated with create_crossbar_config.py
# Import IP
create_ip -name axi_crossbar -vendor xilinx.com -library ip -version 2.1 -module_name $::env(IP_NAME)
# Configure IP
set_property -dict [list CONFIG.PROTOCOL {AXI4} \
                         CONFIG.CONNECTIVITY_MODE {SAMD} \
                         CONFIG.ADDR_WIDTH {32} \
                         CONFIG.DATA_WIDTH {32} \
                         CONFIG.ID_WIDTH {2} \
                         CONFIG.NUM_SI {1} \
                         CONFIG.NUM_MI {2} \
                         CONFIG.ADDR_RANGES {1} \
                         CONFIG.STRATEGY {0} \
                         CONFIG.R_REGISTER {0} \
                         CONFIG.AWUSER_WIDTH {0} \
                         CONFIG.ARUSER_WIDTH {0} \
                         CONFIG.WUSER_WIDTH {0} \
                         CONFIG.RUSER_WIDTH {0} \
                         CONFIG.BUSER_WIDTH {0} \
                         CONFIG.M00_A00_BASE_ADDR {0x0} \
                         CONFIG.M01_A01_BASE_ADDR {0x20000} \
                         CONFIG.M00_A00_ADDR_WIDTH {16} \
                         CONFIG.M01_A01_ADDR_WIDTH {12} \
                         ] [get_ips $::env(IP_NAME)]