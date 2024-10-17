# Import IP by version
create_ip -name vio -vendor xilinx.com -library ip -version 3.0 -module_name $::env(IP_NAME)

# Configure IP
set_property -dict [list CONFIG.C_NUM_PROBE_OUT       {8}   \
                         CONFIG.C_PROBE_OUT0_WIDTH    {1}   \
                         CONFIG.C_PROBE_OUT0_INIT_VAL {0x0} \
                         CONFIG.C_PROBE_OUT1_WIDTH    {1}   \
                         CONFIG.C_PROBE_OUT1_INIT_VAL {0x0} \
                         CONFIG.C_PROBE_OUT2_WIDTH    {1}   \
                         CONFIG.C_PROBE_OUT2_INIT_VAL {0x0} \
                         CONFIG.C_PROBE_OUT3_WIDTH    {1}   \
                         CONFIG.C_PROBE_OUT3_INIT_VAL {0x0} \
                         CONFIG.C_PROBE_OUT4_WIDTH    {32}  \
                         CONFIG.C_PROBE_OUT4_INIT_VAL {0x0} \
                         CONFIG.C_PROBE_OUT5_WIDTH    {32}  \
                         CONFIG.C_PROBE_OUT5_INIT_VAL {0x0} \
                         CONFIG.C_PROBE_OUT6_WIDTH    {32}  \
                         CONFIG.C_PROBE_OUT6_INIT_VAL {0x0} \
                         CONFIG.C_PROBE_OUT7_WIDTH    {32}  \
                         CONFIG.C_PROBE_OUT7_INIT_VAL {0x0} \
                         CONFIG.C_EN_PROBE_IN_ACTIVITY {0}  \
                         CONFIG.C_NUM_PROBE_IN        {8}   \
                         CONFIG.C_PROBE_IN0_WIDTH     {1}   \
                         CONFIG.C_PROBE_IN1_WIDTH     {1}   \
                         CONFIG.C_PROBE_IN2_WIDTH     {1}   \
                         CONFIG.C_PROBE_IN3_WIDTH     {1}   \
                         CONFIG.C_PROBE_IN4_WIDTH     {32}  \
                         CONFIG.C_PROBE_IN5_WIDTH     {32}  \
                         CONFIG.C_PROBE_IN6_WIDTH     {32}  \
                         CONFIG.C_PROBE_IN7_WIDTH     {32}  \
                   ] [get_ips $::env(IP_NAME)]
