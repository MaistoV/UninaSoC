# Author: Vincenzo Maisto <vincenzo.maisto2@unina.it>
# Description: Board-independent constraints

# False path though VIO reset
set VIO_RESETN [get_pins -of [get_nets vio_resetn] -filter {NAME=~vio_inst/*}]
set_false_path -hold -through $VIO_RESETN

#############################################################################################
# Only for Veer core (CORE_SELECTOR == CORE_VEER)
set BSCAN_TAP_CELL rvm_socket_u/core_veer.custom_veer_u/inst/bscan_tap_u
create_clock -add -name tck_dmi -period 100.00 [get_pins $BSCAN_TAP_CELL/tap_dmi/TCK];
create_clock -add -name tck_dtmcs -period 100.00 [get_pins $BSCAN_TAP_CELL/tap_dtmcs/TCK];
create_clock -add -name tck_idcode -period 100.00 [get_pins $BSCAN_TAP_CELL/tap_idcode/DRCK];

#FIXME: Improve this later but hopefully ok for now.
#Since the JTAG clock is slow and bits 0 and 1 are properly synced, we can be a bit careless about the rest
set_false_path -from  [get_cells -regexp {$BSCAN_TAP_CELL/dtmcs_r_reg\[([2-9]|[1-9][0-9])\]}]
#############################################################################################
