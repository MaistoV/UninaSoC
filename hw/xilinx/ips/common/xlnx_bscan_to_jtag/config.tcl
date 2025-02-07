# Import IP
create_ip -name bscan_jtag -vendor xilinx.com -library ip -version 1.0 -module_name $::env(IP_NAME)

# Configure IP
# This IP only has one only property
set_property CONFIG.enable_tck_bufg {true} [get_ips $::env(IP_NAME)]