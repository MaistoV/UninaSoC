#!/bin/python3.10
# Author: Stefano Toscano <stefa.toscano@studenti.unina.it>
# Author: Vincenzo Maisto <vincenzo.maisto2@unina.it>
# Description:
#   Generate and fd script from the CSV configuration.
# Note:
#   Addresses overlaps are not sanitized.
# Args:
#   1: Input configuration file
#   2: Output generated fd script

####################
# Import libraries #
####################
# Parse args
import sys
# For basename
import os
# Manipulate CSV
import pandas as pd

##############
# Parse args #
##############

# CSV configuration file path
config_file_name = 'config/axi_memory_map/configs/config.csv'
# config_file_name = 'config/axi_memory_map/configs/PoC_config.csv'
if len(sys.argv) >= 2:
	config_file_name = sys.argv[1]

# Target TCL file
ld_file_name = 'sw/linker/UninaSoC.ld'
if len(sys.argv) >= 3:
	ld_file_name = sys.argv[2]


###############
# Read config #
###############
# Read CSV file
config_df = pd.read_csv(config_file_name, sep=",", index_col=0)

# Read number of masters interfaces
NUM_MI = int(config_df.loc["NUM_MI"]["Value"])
# print("[DEBUG] NUM_MI", NUM_MI)

# Read slaves' names
SLAVE_NAMES = config_df.loc["SLAVE_NAMES"]["Value"].split()
# print("[DEBUG] SLAVE_NAMES", SLAVE_NAMES)

# Read address Ranges
RANGE_BASE_ADDR = config_df.loc["RANGE_BASE_ADDR"]["Value"].split()
# print("[DEBUG] RANGE_BASE_ADDR", RANGE_BASE_ADDR)

# Read address widths
RANGE_ADDR_WIDTH = config_df.loc["RANGE_ADDR_WIDTH"]["Value"].split()
# Turns the values into Integers
for i in range(len(RANGE_ADDR_WIDTH)):
	RANGE_ADDR_WIDTH[i] = int(RANGE_ADDR_WIDTH[i])
# print("[DEBUG] RANGE_ADDR_WIDTH", RANGE_ADDR_WIDTH)

################
# Sanity check #
################
assert (NUM_MI == len(SLAVE_NAMES)) & (NUM_MI == len(RANGE_BASE_ADDR) ) & (NUM_MI  == len(RANGE_ADDR_WIDTH)), \
	"Mismatch in lenght of configurations: NUM_MI(" + str(NUM_MI) + "), SLAVE_NAMES (" + str(len(SLAVE_NAMES)) + \
	"), RANGE_BASE_ADDR(" + str(len(RANGE_BASE_ADDR)) + ") RANGE_ADDR_WIDTH(" + str(len(RANGE_ADDR_WIDTH)) + ")"

###########################
# Calculate memory blocks #
###########################
# NOTE: this assumes peripherals slaves to always be after memory regions
counter = 0
PERIPHERALS_LENGTH = 0
BRAM_LENGTH = 0
DDR_LENGTH = 0
HBM_LENGTH = 0
BRAM_END = 0
DDR_END = 0
HBM_END = 0
for name in SLAVE_NAMES:
	match name:
		# BRAM
		case "BRAM":
			BRAM_ORIGIN = int(RANGE_BASE_ADDR[counter], 16)
			BRAM_LENGTH = 2 << RANGE_ADDR_WIDTH[counter]
			BRAM_END 	= BRAM_ORIGIN + BRAM_LENGTH
		# DDR
		case "DDR":
			DDR_ORIGIN = int(RANGE_BASE_ADDR[counter], 16)
			DDR_LENGTH = 2 << RANGE_ADDR_WIDTH[counter]
			DDR_END    = DDR_ORIGIN + DDR_LENGTH
		# HBM
		case "HBM":
			HBM_ORIGIN = int(RANGE_BASE_ADDR[counter], 16)
			HBM_LENGTH = 2 << RANGE_ADDR_WIDTH[counter]
			HBM_END    = HBM_ORIGIN + HBM_LENGTH
		# Peripherals
		case _:
			# Max reduce
			PERIPHERALS_LENGTH = max(PERIPHERALS_LENGTH, 2 << RANGE_ADDR_WIDTH[counter])

	# Increment counter
	counter += 1

# Peripherals base, soon as the memory space ends
PERIPHERALS_ORIGIN = max(BRAM_END, DDR_END, HBM_END)

# Peripherals length,
PERIPHERALS_LENGTH = 0
for i in range(1, len(RANGE_ADDR_WIDTH)):
	PERIPHERALS_LENGTH += (2 << RANGE_ADDR_WIDTH[i])

#################
# Write to file #
#################
# Open output file
fd = open(ld_file_name,  "w")

# Write header
fd.write("/* This file is auto-generated with " + os.path.basename(__file__) + " */\n")

# BLOCKS
fd.write("\n")
fd.write("/* Memory blocks */\n")
fd.write("MEMORY\n")
fd.write("{\n")
# Memories
if BRAM_LENGTH != 0:
	fd.write("\tBRAM (xrw) : ORIGIN = " + hex(BRAM_ORIGIN) + ",  LENGTH = " + hex(BRAM_LENGTH) + "\n")
if DDR_LENGTH != 0:
	fd.write("\tDDR (xrw) : ORIGIN = " + hex(DDR_ORIGIN) + ",  LENGTH = " + hex(DDR_LENGTH) + "\n")
if HBM_LENGTH != 0:
	fd.write("\tHBM (xrw) : ORIGIN = " + hex(HBM_ORIGIN) + ",  LENGTH = " + hex(HBM_LENGTH) + "\n")
# Peripherals
fd.write("\tPERIPHERALS (rw) : ORIGIN = " + hex(PERIPHERALS_ORIGIN) + ",  LENGTH = " + hex(PERIPHERALS_LENGTH) + "\n")
fd.write("}\n")

# SECTIONS
fd.write("\n")
fd.write("/* Sections */\n")
fd.write("SECTIONS\n")
fd.write("{\n")
start = int(RANGE_BASE_ADDR[0], 16)
for i in range(NUM_MI):
	range_start = int(RANGE_BASE_ADDR[i], 16)
	range_end = range_start + (2 << RANGE_ADDR_WIDTH[i])
	fd.write("\t_slave_" + SLAVE_NAMES[i] + "_base = " + hex(range_start) + ";\n")
	fd.write("\t_slave_" + SLAVE_NAMES[i] + "_end = "  + hex(range_end)   + ";\n")
fd.write("}\n")

# Files closing
fd.write("\n")
fd.close()

