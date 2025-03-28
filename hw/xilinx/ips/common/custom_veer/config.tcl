# Author: Vincenzo Maisto <vincenzo.maisto2@unina.it>
# Description: create a custom IP using rtl sources

# VeerWolf sources require this file to be globally included
set global_include_files common_defines.vh

# Source the common script for packaging
source $::env(XILINX_IPS_ROOT)/common/tcl/custom_config.tcl