# Author: Vincenzo Maisto <vincenzo.maisto2@unina.it>
# Description: Reset from VIO probe

set_property OUTPUT_VALUE 1 [get_hw_probes vio_reset_1 -of_objects [get_hw_vios -of_objects [get_hw_devices $::env(XILINX_FPGA_DEVICE)] -filter {CELL_NAME=~"xlnx_vio_inst"}]]
commit_hw_vio [get_hw_probes {vio_reset_1} -of_objects [get_hw_vios -of_objects [get_hw_devices $::env(XILINX_FPGA_DEVICE)] -filter {CELL_NAME=~"xlnx_vio_inst"}]]
# Wait for 100 ns
after 100
set_property OUTPUT_VALUE 0 [get_hw_probes vio_reset_1 -of_objects [get_hw_vios -of_objects [get_hw_devices $::env(XILINX_FPGA_DEVICE)] -filter {CELL_NAME=~"xlnx_vio_inst"}]]
commit_hw_vio [get_hw_probes {vio_reset_1} -of_objects [get_hw_vios -of_objects [get_hw_devices $::env(XILINX_FPGA_DEVICE)] -filter {CELL_NAME=~"xlnx_vio_inst"}]]