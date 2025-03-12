# Author: Stefano Mercogliano <stefano.mercogliano@unina.it>
# Description:
#   This Makefile defines the project name and paths for the common Makefile.
#   Optionally, a user can define additional targets here.

################
# Program Name #
################

# Get program name from directory name
PROGRAM_NAME = $(shell basename $$PWD)

#############
# Toolchain #
#############

#####################
# Paths and Folders #
#####################

SOC_SW_ROOT_DIR = $(SW_ROOT)/SoC

SRC_DIR        = src
OBJ_DIR        = obj
INC_DIR     = inc
STARTUP_DIR = $(SOC_SW_ROOT_DIR)/common

LD_SCRIPT     = ld/user.ld

#############
# Libraries #
#############

LIB_OBJ_TINYIO     = $(LIB_DIR)/tinyio/lib/tinyio.a
LIB_INC_TINYIO    = -I$(LIB_DIR)/tinyio/inc

LIB_OBJ_LIST     = $(LIB_OBJ_TINYIO)
LIB_INC_LIST     = $(LIB_INC_TINYIO)

##########
# MACROS #
##########

MACRO_LIST =
ifeq ($(SOC_CONFIG), embedded)
MACRO_LIST += -DIS_EMBEDDED
endif


#############
# Toolchain #
#############

RV_PREFIX     = riscv32-unknown-elf-
CC             = $(RV_PREFIX)gcc
LD             = $(RV_PREFIX)ld
OBJDUMP     = $(RV_PREFIX)objdump
OBJCOPY     = $(RV_PREFIX)objcopy

DFLAG        = -g
CFLAGS         = -march=rv32imac_zicsr_zifencei -mabi=ilp32 -O0 $(MACRO_LIST) $(DFLAG) -c
LDFLAGS     = $(LIB_OBJ_LIST) -nostdlib -T$(LD_SCRIPT)

include $(SW_ROOT)/SoC/common/Makefile
