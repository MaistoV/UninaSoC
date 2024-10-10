

# Top module name must be different from IP name
# No file in the hierarchy should be names ad the IP name as well.
set top_module axi_from_mem_wrapper

# Add here all the requires src files for the custom IP
set src_file_list [ list \
    $::env(HW_UNITS_ROOT)/$::env(IP_NAME)/rtl/axi_pkg.sv \
    $::env(HW_UNITS_ROOT)/$::env(IP_NAME)/rtl/typedef.svh \
    $::env(HW_UNITS_ROOT)/$::env(IP_NAME)/rtl/registers.svh \
    $::env(HW_UNITS_ROOT)/$::env(IP_NAME)/rtl/assertions.svh \
    $::env(HW_UNITS_ROOT)/$::env(IP_NAME)/rtl/fifo_v3.sv \
    $::env(HW_UNITS_ROOT)/$::env(IP_NAME)/rtl/axi_lite_from_mem.sv \
    $::env(HW_UNITS_ROOT)/$::env(IP_NAME)/rtl/axi_lite_to_axi.sv \
    $::env(HW_UNITS_ROOT)/$::env(IP_NAME)/rtl/axi_from_mem.sv \
    $::env(HW_UNITS_ROOT)/$::env(IP_NAME)/rtl/${top_module}.sv 
]

# Package the IP with the specified file list and top module
source $::env(XILINX_SYNTH_TCL_ROOT)/package_ip.tcl
