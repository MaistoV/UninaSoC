# Author: Stefano Mercogliano <stefano.mercogliano@unina.it>
# Description:
# 	It assigns the correct toolchain size depending on XLEN config parameter.
#	XLEN is defined in `config/scripts/config_sw.sh`
#	In the future, flags and toolchain will be selected using the same configuration flow.

#############
# Toolchain #
#############

RV_PREFIX ?= riscv${XLEN}-unknown-elf-

CC          = $(RV_PREFIX)gcc
LD          = $(RV_PREFIX)ld
OBJDUMP     = $(RV_PREFIX)objdump
OBJCOPY     = $(RV_PREFIX)objcopy

#########
# Flags #
#########

DFLAG ?= -g
CFLAGS ?= -march=rv${XLEN}imac_zicsr_zifencei -mabi=ilp${XLEN} -O0 $(DFLAG) -c
LDFLAGS ?= $(LIB_OBJ_LIST) -nostdlib -T$(LD_SCRIPT)

