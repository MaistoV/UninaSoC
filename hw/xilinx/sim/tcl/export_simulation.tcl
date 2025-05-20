
# Description: Create simulation model for a Xilix IP

# Open a project containing the target IP
open_project $::env(VIVADO_PROJECT)

# Export simulation
export_simulation       \
    -simulator questa   \
    -directory "$::env(XILINX_SIM_IP_ROOT)"  \
    -lib_map_path "$::env(XILINX_SIMLIB_PATH)" \
    -absolute_path      \
    -force              \
    -of_objects [get_ips *]
