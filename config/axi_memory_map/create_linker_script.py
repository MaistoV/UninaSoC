#!/bin/python3.10
# Author: Stefano Toscano 		<stefa.toscano@studenti.unina.it>
# Author: Vincenzo Maisto 		<vincenzo.maisto2@unina.it>
# Author: Stefano Mercogliano 	<stefano.mercogliano@unina.it>
# Description:
#   Generate a linker script file from the CSV configuration.
# Note:
#   Addresses overlaps are not sanitized.
# Args:
#   1: Input configuration file
#   2: Output generated ld script

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
if len(sys.argv) >= 2:
	config_file_name = sys.argv[1]

# Target linker script file
ld_file_name = 'sw/SoC/linker/UninaSoC.ld'
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
RANGE_NAMES = config_df.loc["RANGE_NAMES"]["Value"].split()
# print("[DEBUG] RANGE_NAMES", RANGE_NAMES)

# Read address Ranges
RANGE_BASE_ADDR = config_df.loc["RANGE_BASE_ADDR"]["Value"].split()
# print("[DEBUG] RANGE_BASE_ADDR", RANGE_BASE_ADDR)

# Read address widths
RANGE_ADDR_WIDTH = config_df.loc["RANGE_ADDR_WIDTH"]["Value"].split()
# Turns the values into Integers
for i in range(len(RANGE_ADDR_WIDTH)):
	RANGE_ADDR_WIDTH[i] = int(RANGE_ADDR_WIDTH[i])

################
# Sanity check #
################
assert (NUM_MI == len(RANGE_NAMES)) & (NUM_MI == len(RANGE_BASE_ADDR) ) & (NUM_MI  == len(RANGE_ADDR_WIDTH)), \
	"Mismatch in lenght of configurations: NUM_MI(" + str(NUM_MI) + "), RANGE_NAMES (" + str(len(RANGE_NAMES)) + \
	"), RANGE_BASE_ADDR(" + str(len(RANGE_BASE_ADDR)) + ") RANGE_ADDR_WIDTH(" + str(len(RANGE_ADDR_WIDTH)) + ")"

##########################
# Generate memory blocks #
##########################
# Currently only one copy of BRAM, DDR and HBM memory ranges are supported.

DEVICE_NAME = 0
DEVICE_ORIGIN = 1
DEVICE_LENGTH = 2

memory_block_list = []
peripheral_list = []
counter = 0
for device in RANGE_NAMES:
	match device:
		# memory blocks
		case "BRAM" | "DDR" | "HBM":
			memory_block_list.append([device, int(RANGE_BASE_ADDR[counter], 16), 2 << RANGE_ADDR_WIDTH[counter]])

		# Peripherals
		case _:
			peripheral_list.append([device, int(RANGE_BASE_ADDR[counter], 16), 2 << RANGE_ADDR_WIDTH[counter]])

	# Increment counter
	counter += 1

###############################
# Generate Linker Script File #
###############################

# Create the Linker Script File
fd = open(ld_file_name,  "w")

# Write header
fd.write("/* This file is auto-generated with " + os.path.basename(__file__) + " */\n")

# Generate the memory blocks layout
fd.write("\n")
fd.write("/* Memory blocks */\n")
fd.write("MEMORY\n")
fd.write("{\n")

for block in memory_block_list:
	fd.write("\t" + block[DEVICE_NAME] + " (xrw) : ORIGIN = 0x" + format(block[DEVICE_ORIGIN], "08x") + ",  LENGTH = " + hex(block[DEVICE_LENGTH]) + "\n")
fd.write("}\n")

# Generate symbols from peripherals
fd.write("\n")
fd.write("/* Peripherals symbols */\n")
for peripheral in peripheral_list:
	fd.write("_peripheral_" + peripheral[DEVICE_NAME] + "_start = 0x" + format(peripheral[DEVICE_ORIGIN], "08x") + ";\n")
	fd.write("_peripheral_" + peripheral[DEVICE_NAME] + "_end = 0x" + format(peripheral[DEVICE_ORIGIN] + peripheral[DEVICE_LENGTH], "08x") + ";\n")

# Generate global symbols
fd.write("\n")
fd.write("/* Global symbols */\n")
# Vector table is placed at the beggining of the first memory block.
# It is aligned to 256 bytes and is 32 words deep. (as described in risc-v spec)
vector_table_start  =  memory_block_list[0][DEVICE_ORIGIN]
fd.write("_vector_table_start = 0x" + format(vector_table_start, "08x") + ";\n")
fd.write("_vector_table_end = 0x" + format(vector_table_start + 32*4, "08x") + ";\n")

# The stack is allocated at the end of first memory block
# _stack_end can be user-defined for the application, as bss and rodata
stack_start = memory_block_list[0][DEVICE_ORIGIN] + memory_block_list[0][DEVICE_LENGTH]
fd.write("_stack_start = 0x" + format(stack_start, "08x") + ";\n")

# Generate sections
# vector table and text sections are here defined.
# data, bss and rodata can be explicitly defined by the user application if required.
fd.write("\n")
fd.write("/* Sections */\n")
fd.write("SECTIONS\n")
fd.write("{\n")

# Vector Table section
fd.write("\t.vector_table _vector_table_start :\n")
fd.write("\t{\n")
fd.write("\t\tKEEP(*(.vector_table))\n")
fd.write("\t}> " + memory_block_list[0][DEVICE_NAME] + "\n")

# Text section
fd.write("\n")
fd.write("\t.text :\n")
fd.write("\t{\n")
fd.write("\t\t. = ALIGN(32);\n")
fd.write("\t\t_text_start = .;\n")
fd.write("\t\t*(.text.handlers)\n")
fd.write("\t\t*(.text.start)\n")
fd.write("\t\t*(.text)\n")
fd.write("\t\t*(.text*)\n")
fd.write("\t\t. = ALIGN(32);\n")
fd.write("\t\t_text_end = .;\n")
fd.write("\t}> " + memory_block_list[0][DEVICE_NAME] + "\n")

fd.write("}\n")

# Files closing
fd.write("\n")
fd.close()



