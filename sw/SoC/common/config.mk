# Author: Stefano Mercogliano <stefano.mercogliano@unina.it>
# Description:
# 	It assigns the correct compilation flags and toolchain prefix depending on XLEN config parameter.
#	It is automatically filled by the configuration flow (config_sw.sh)

#############
# Toolchain #
#############

RV_PREFIX ?= riscv32-unknown-elf-

CC          = $(RV_PREFIX)gcc
LD          = $(RV_PREFIX)ld
OBJDUMP     = $(RV_PREFIX)objdump
OBJCOPY     = $(RV_PREFIX)objcopy

#########
# Flags #
#########

DFLAG ?= -g
CFLAGS ?= -march=rv32imac_zicsr_zifencei -mabi=ilp32 -O0 $(DFLAG) -c
LDFLAGS ?= $(LIB_OBJ_LIST) -nostdlib -T$(LD_SCRIPT)

