
# Create new project (no force)
create_project $::env(XILINX_PROJECT_NAME) . -part $::env(XILINX_PART) # -force
set_property board_part $::env(XILINX_BOARD) [current_project]

# Add sources
source ../tcl/add_xilinx_sources.tcl

# Load constraints
import_files -fileset constrs_1 -norecurse $::env(XILIN_ROOT)/constraints/$::env(XILINX_PROJECT_NAME)/.xdc
import_files -fileset constrs_1 -norecurse $::env(XILIN_ROOT)/constraints/${board}.xdc

# Import IPS
read_ip $::env(XILINX_IP_LIST_XCI)

# Set top level module
set_property top uninasoc_top [current_fileset]

# Generate compilation order
update_compile_order -fileset sources_1

# For which memory IP was this?
set_property XPM_LIBRARIES XPM_MEMORY [current_project]

###################
# RTL elaboration #
###################
synth_design -rtl -name rtl_1

#############
# Synthesis #
#############
# Set strategy
set_property STRATEGY                                           $::env(SYNTH_STRATEGY)   [get_runs synth_1]
# Preserve the net names and hierarchy for debug
set_property STEPS.SYNTH_DESIGN.ARGS.FLATTEN_HIERARCHY          none                     [get_runs synth_1]
set_property STEPS.SYNTH_DESIGN.ARGS.KEEP_EQUIVALENT_REGISTERS  true                     [get_runs synth_1]
# Enable retiming in synthesis
set_property STEPS.SYNTH_DESIGN.ARGS.RETIMING                   true                     [get_runs synth_1]

# Run
launch_runs synth_1
wait_on_run synth_1
# Open synthesized design
open_run synth_1 -name synth_1
# Genate reports
check_timing -verbose                                       -file reports/$::env(XILINX_PROJECT_NAME).post_synth.check_timing.rpt
report_utilization -hierarchical -hierarchical_percentage   -file reports/$::env(XILINX_PROJECT_NAME).post_synth.utilization.rpt

############
# Add ILAs #
############
source ../tcl/add_ilas.tcl

##################
# Implementation #
##################
# Runtime optimized build
set_property "steps.place_design.args.directive"            "RuntimeOptimized"       [get_runs impl_1]
set_property "steps.route_design.args.directive"            "RuntimeOptimized"       [get_runs impl_1]
# Set strategy
set_property STRATEGY                                       Flow_RuntimeOptimized  [get_runs impl_1]
# set_property STRATEGY                                       $::env(IMPL_STRATEGY)    [get_runs impl_1]
# # Enable physical optimizations (longer runtime)
# set_property STEPS.PHYS_OPT_DESIGN.IS_ENABLED 		        true                     [get_runs impl_1]
# set_property STEPS.POST_ROUTE_PHYS_OPT_DESIGN.IS_ENABLED    true                     [get_runs impl_1]

# Run
launch_runs impl_1 -to_step write_bitstream
wait_on_run impl_1
# Open implemented design
open_run impl_1

# Genate reports
check_timing                                                              -file reports/$::env(XILINX_PROJECT_NAME).post_impl.check_timing.rpt
report_timing -max_paths 100 -nworst 100 -delay_type max -sort_by slack   -file reports/$::env(XILINX_PROJECT_NAME).post_impl.timing_WORST_100.rpt
report_timing -nworst 1 -delay_type max -sort_by group                    -file reports/$::env(XILINX_PROJECT_NAME).post_impl.timing.rpt
report_utilization -hierarchical -hierarchical_percentage                 -file reports/$::env(XILINX_PROJECT_NAME).post_impl.utilization.rpt
report_timing_summary                                                     -file reports/$::env(XILINX_PROJECT_NAME).post_impl.timing_summary.rpt
