# Create Vivado project
create_project $::env(IP_PRJ_NAME) . -force -part  $::env(XILINX_PART_NUMBER)
set_property board_part $::env(XILINX_BOARD_PART) [current_project]

# Define list
set global_include_files []

