## Author: Vincenzo Maisto <vincenzo.maisto2@unina.it>
## Description: Utility script to trigger VIO probe attached to core reset

set_property OUTPUT_VALUE 0 [get_hw_probes vio_resetn -of_objects [get_hw_vios -of_objects [get_hw_devices $hw_device] -filter {CELL_NAME=~"vio_inst"}]]
commit_hw_vio [get_hw_probes {vio_resetn} -of_objects [get_hw_vios -of_objects [get_hw_devices $hw_device] -filter {CELL_NAME=~"vio_inst"}]]

after 500

set_property OUTPUT_VALUE 1 [get_hw_probes vio_resetn -of_objects [get_hw_vios -of_objects [get_hw_devices $hw_device] -filter {CELL_NAME=~"vio_inst"}]]
commit_hw_vio [get_hw_probes {vio_resetn} -of_objects [get_hw_vios -of_objects [get_hw_devices $hw_device] -filter {CELL_NAME=~"vio_inst"}]]
