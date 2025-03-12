# Author: Vincenzo Maisto <vincenzo.maisto2@unina.it>
# Description: Suppress or change severity of Vivado messages
# Input args:
#    None

# The IP file <...> has been moved from its original location, as a result the outputs for this IP will now be generated in <...>. Alternatively a copy of the IP can be imported into the project using one of the 'import_ip' or 'import_files' commands.
set_msg_config -id {[Vivado 12-13650]} -suppress

# INFO: [Synth 8-11241] undeclared symbol 'REGCCE', assumed default net type 'wire' [<vivado install>/data/verilog/src/unimacro/BRAM_SINGLE_MACRO.v:2170]
set_msg_config -id {[Synth 8-11241]} -suppress

# WARNING: [Board 49-26] cannot add Board Part<...> available at <vivado install>/data/xhub/boards/XilinxBoardStore/boards<...> as part <...> specified in board_part file is either invalid or not available
# set_msg_config -id {[Board 49-26]} -suppress
