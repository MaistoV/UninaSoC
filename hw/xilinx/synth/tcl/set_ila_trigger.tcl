E.g. imported from cheshire_fork

#######################
## ILA configuration ##
#######################
# Set triggers
# Ara req/resp valid
set_property TRIGGER_COMPARE_VALUE eq1'bR [get_hw_probes {i_cheshire_soc/gen_cva6_cores[0].i_ara/acc_req_i[req_valid]} -of_objects [get_hw_ilas -of_objects [get_hw_devices $::env(XILINX_FPGA_DEVICE)] -filter {CELL_NAME=~"u_ila_0"}]]
set_property TRIGGER_COMPARE_VALUE eq1'bR [get_hw_probes {i_cheshire_soc/gen_cva6_cores[0].i_ara/acc_resp_o[resp_valid]} -of_objects [get_hw_ilas -of_objects [get_hw_devices $::env(XILINX_FPGA_DEVICE)] -filter {CELL_NAME=~"u_ila_0"}]]
# CVA6 exception valid
# set_property TRIGGER_COMPARE_VALUE eq1'bR [get_hw_probes {i_cheshire_soc/gen_cva6_cores[0].i_core_cva6/commit_stage_i/exception_o[valid]} -of_objects [get_hw_ilas -of_objects [get_hw_devices $::env(XILINX_FPGA_DEVICE)] -filter {CELL_NAME=~"u_ila_0"}]]

# Debug, PC hang
set_property TRIGGER_COMPARE_VALUE eq1'bR [get_hw_probes {i_cheshire_soc/gen_cva6_cores[0].i_core_cva6/commit_stage_i/commit_instr_i[0][valid]} -of_objects [get_hw_ilas -of_objects [get_hw_devices $::env(XILINX_FPGA_DEVICE)] -filter {CELL_NAME=~"u_ila_0"}]]
set_property TRIGGER_COMPARE_VALUE eq64'hFFFF_FFFF_8000_331X [get_hw_probes {i_cheshire_soc/gen_cva6_cores[0].i_core_cva6/pc_commit} -of_objects [get_hw_ilas -of_objects [get_hw_devices $::env(XILINX_FPGA_DEVICE)] -filter {CELL_NAME=~"u_ila_0"}]]


# Set trigger control
set_property CONTROL.TRIGGER_CONDITION OR [get_hw_ilas -of_objects [get_hw_devices $::env(XILINX_FPGA_DEVICE)] -filter {CELL_NAME=~"u_ila_0"}]
set_property CONTROL.TRIGGER_POSITION 4096 [get_hw_ilas -of_objects [get_hw_devices $::env(XILINX_FPGA_DEVICE)] -filter {CELL_NAME=~"u_ila_0"}]

# Arm ILA
run_hw_ila [get_hw_ilas -of_objects [get_hw_devices $::env(XILINX_FPGA_DEVICE)] -filter {CELL_NAME=~"u_ila_0"}]