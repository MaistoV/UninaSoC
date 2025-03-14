# Author: Vincenzo Maisto <vincenzo.maisto2@unina.it>
# Description:
#    Hold all the configurable variables.
#    This file is meant to be updated by the configuration flow.

##########
# Values #
##########

# AXI
ADDR_WIDTH ?= 32
DATA_WIDTH ?= 32
ID_WIDTH ?= 2

# Main bus
NUM_SI ?= 4
NUM_MI ?= 4
# PBUS
PBUS_NUM_MI ?= 5

# RV core
CORE_SELECTOR ?= CORE_CV32A6
