# Author: Vincenzo Maisto <vincenzo.maisto2@unina.it>
# Description: Compile simulation librarires in Vivado

# set command "compile_simlib -simulator questa -simulator_exec_path {$::env(SIMULATOR_PATH)} \
# -gcc_exec_path {$::env(GCC_PATH)} -family all -language verilog -library all -dir {$::env(XILINX_SIMLIB_PATH)} -force"
# # For some reason this command does not work well when not eval from the string
# eval $command

compile_simlib                                      \
    -simulator questa                               \
    -simulator_exec_path "$::env(QUESTA_PATH)"      \
    -gcc_exec_path "$::env(GCC_PATH)"               \
    -family all                                     \
    -language verilog                               \
    -library all                                    \
    -dir "$::env(XILINX_SIMLIB_PATH)"               \
    -force