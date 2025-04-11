# Author: Vincenzo Maisto <vincenzo.maisto2@unina.it>
# Author: Stefano Mercogliano <stefano.mercogliano@unina.it>
# Description:
#    Hold all the configurable variables.
#    This file is meant to be updated by the configuration flow.

##########
# Values #
##########

# AXI
XLEN ?= 32
ADDR_WIDTH ?= ${XLEN}
DATA_WIDTH ?= ${XLEN}
ID_WIDTH ?= 2

# Main bus
NUM_SI ?= 4
NUM_MI ?= 5
# PBUS
PBUS_NUM_MI ?= 3

# RV core
CORE_SELECTOR ?= CORE_CV32E40P

# VIO resetn
VIO_RESETN_DEFAULT ?= 1

# BRAM size
BRAM_DEPTHS ?=  8192

# Clock domains
MAIN_CLOCK_FREQ_MHZ ?= 100
RANGE_CLOCK_DOMAINS ?= MAIN_CLOCK_DOMAIN PBUS_HAS_CLOCK_DOMAIN DDR_HAS_CLOCK_DOMAIN