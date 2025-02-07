# Import IP by version
create_ip -name debug_bridge -vendor xilinx.com -library ip -version 3.0 -module_name $::env(IP_NAME)

# Configure IP
# CONFIG.C_DEBUG_MODE 1 -> BSCAN-to-Debug Hub (necessary to instatiate also other debg cores, e.g. JTAG2AXI, ILAs and VIOs)
# CONFIG.C_DEBUG_MODE 7 -> BSCAN primitive
set_property -dict [list \
                        CONFIG.C_DEBUG_MODE {7}       \
                        CONFIG.C_NUM_BS_MASTER {1}    \
                        CONFIG.C_USER_SCAN_CHAIN {1}  \
                   ] [get_ips $::env(IP_NAME)]
