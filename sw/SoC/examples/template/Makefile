# Author: Stefano Mercogliano 	<stefano.mercogliano@unina.it>
# Description:
#   Makefile for generating a bare-metal software PROGRAM_NAME.
#	Currently, only rv32 is supported.

################
# Program Name #
################

PROGRAM_NAME = $(shell basename "$$PWD")

#####################
# Paths and Folders #
#####################

SOC_SW_ROOT_DIR = $(SW_ROOT)/SoC

SRC_DIR		= src
OBJ_DIR		= obj
INC_DIR 	= inc 
STARTUP_DIR = $(SOC_SW_ROOT_DIR)/startup

LD_SCRIPT 	= ld/user.ld 

#############
# Libraries #
#############

LIB_OBJ_LIST = 
LIB_INC_LIST =

#############
# Toolchain #
#############

RV_PREFIX 	= riscv32-unknown-elf-
CC 			= $(RV_PREFIX)gcc
LD 			= $(RV_PREFIX)ld
OBJDUMP 	= $(RV_PREFIX)objdump
OBJCOPY 	= $(RV_PREFIX)objcopy

CFLAGS 		= -march=rv32imad_zicsr_zifencei -O0 -c 
LDFLAGS 	= $(LIB_OBJ_LIST) -nostdlib -T$(LD_SCRIPT)


########
# Misc #
########

SRCS 	= $(wildcard src/*.c) $(wildcard lib/*.c)
OBJS 	= $(addprefix $(OBJ_DIR)/, $(notdir $(SRCS:.c=.o)))

RM      = rm -rf 					# Remove recursively command
MKDIR   = @mkdir -p $(@D) 			# Creates folders if not present

###############################################################################

###########
# Targets #
###########

all: bin/$(PROGRAM_NAME).bin

$(OBJ_DIR)/%.o: $(SRC_DIR)/%.c
	@echo "\n[OBJ]	Creating OBJs from src"
	$(MKDIR)
	$(CC) -o $@ $^ -I$(INC_DIR) $(LIB_INC_LIST) $(CFLAGS)

obj/startup.o: 
	@echo "\n[OBJ]	Creating OBJs from $(STARTUP_DIR)/startup.s"
	$(MKDIR)
	$(CC) -o obj/startup.o $(STARTUP_DIR)/startup.s -I$(LIB_INC_LIST) $(CFLAGS)

bin/$(PROGRAM_NAME).elf: $(OBJS) obj/startup.o
	@echo "\n[ELF]	Creating elf file"
	$(MKDIR)
	$(LD) -o $@ $^ $(LDFLAGS)

bin/$(PROGRAM_NAME).bin: bin/$(PROGRAM_NAME).elf
	@echo "\n[BIN]	Creating bin file"
	$(OBJCOPY) -O binary bin/$(PROGRAM_NAME).elf bin/$(PROGRAM_NAME).bin

clean:
	-$(RM) obj
	-$(RM) bin

.PHONY: all clean

dump:
	$(OBJDUMP) -D bin/$(PROGRAM_NAME).elf

