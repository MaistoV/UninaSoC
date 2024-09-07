# Create Vivado project
create_project $::env(IP_NAME) . -force -part  $::env(XILINX_PART_NUMBER)
# set_property board_part $::env(XILINX_BOARD) [current_project]
