# Author: Vincenzo Maisto <vincenzo.maisto2@unina.it>
# Author: Stefano Mercogliano <stefano.mercogliano@unina.it>
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
CORE_SELECTOR ?= CORE_CV32E40P

# VIO resetn
VIO_RESETN_DEFAULT ?= 1

# BRAM size
BRAM_DEPTHS ?=  8192

# Clock domains
MAIN_CLOCK_FREQ_MHZ ?= 20
RANGE_CLOCK_DOMAINS ?= MAIN_CLOCK_DOMAIN PBUS_HAS_CLOCK_DOMAIN