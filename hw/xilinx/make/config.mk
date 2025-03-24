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
NUM_MI ?= 5
# PBUS
PBUS_NUM_MI ?= 3

# RV core
CORE_SELECTOR ?= CORE_CV32E40P

# BRAM size
BRAM_DEPTHS ?=  8192
