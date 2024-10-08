


# Define the top_module name (NB: IP Name must be different from the top_module name)
set top_module picorv32_wrapper

# Add here all the requires src files for the custom IP
set src_file_list [ list \
    $::env(HW_UNITS_ROOT)/$::env(IP_NAME)/rtl/picorv32.v \
    $::env(HW_UNITS_ROOT)/$::env(IP_NAME)/rtl/${top_module}.sv 
]

# Package the IP with the specified file list and top module
source $::env(XILINX_SYNTH_TCL_ROOT)/package_ip.tcl

