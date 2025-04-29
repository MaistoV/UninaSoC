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
ID_WIDTH ?= 3

# Main bus
NUM_SI ?= 5
NUM_MI ?= 6
# PBUS
PBUS_NUM_MI ?= 3
# HBUS
HBUS_NUM_MI ?= 2
HBUS_NUM_SI ?= 2

# RV core
CORE_SELECTOR ?= CORE_MICROBLAZEV

# VIO resetn
VIO_RESETN_DEFAULT ?= 1

# BRAM size
BRAM_DEPTHS ?=  8192

# Clock domains
MAIN_CLOCK_FREQ_MHZ ?= 100
RANGE_CLOCK_DOMAINS ?= MAIN_CLOCK_DOMAIN PBUS_HAS_CLOCK_DOMAIN HLS_CONTROL_HAS_CLOCK_DOMAIN HBUS_HAS_CLOCK_DOMAIN