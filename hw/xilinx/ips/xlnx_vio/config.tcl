# Import IP by version
create_ip -name vio -vendor xilinx.com -library ip -version 3.0 -module_name $::env(IP_NAME)

# Configure IP
set_property -dict [list CONFIG.C_NUM_PROBE_OUT {5} \
                         CONFIG.C_PROBE_OUT0_INIT_VAL {0x0} \
                         CONFIG.C_PROBE_OUT1_INIT_VAL {0x2} \
                         CONFIG.C_PROBE_OUT2_INIT_VAL {0x1} \
                         CONFIG.C_PROBE_OUT3_INIT_VAL {0x0} \
                         CONFIG.C_PROBE_OUT4_INIT_VAL {0x0} \
                         CONFIG.C_PROBE_OUT1_WIDTH {2} \
                         CONFIG.C_EN_PROBE_IN_ACTIVITY {0} \
                         CONFIG.C_NUM_PROBE_IN {0} \
                   ] [get_ips $::env(IP_NAME)]
