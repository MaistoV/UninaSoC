# Import IP by version
create_ip -name vio -vendor xilinx.com -library ip -version 3.0 -module_name $::env(IP_NAME)

# Configure IP
set_property -dict [list CONFIG.C_NUM_PROBE_OUT       {1}   \
                         CONFIG.C_PROBE_OUT0_WIDTH    {1}   \
                         CONFIG.C_PROBE_OUT0_INIT_VAL {0x0} \
                         CONFIG.C_NUM_PROBE_IN        {1}   \
                         CONFIG.C_PROBE_IN3_WIDTH     {1}   \
                   ] [get_ips $::env(IP_NAME)]
