# Author: Stefano Mercogliano <stefano.mercogliano@unina.it>
# Description:
#   The common Makefile includes the standard targets to build bare-metal code.
#	Each application will include this makefile and define the envvar related to path, dependencies and compilation flags.

SOC_SW_ROOT_DIR = $(SW_ROOT)/SoC
LIB_DIR	= $(SOC_SW_ROOT_DIR)/lib

## DEVICES
DEVICES_DIR = $(SOC_SW_ROOT_DIR)/common/devices
DEVICES_SRCS := $(wildcard $(DEVICES_DIR)/src/*.c)
DEVICES_OBJS := $(addprefix obj/,$(patsubst %.c,%.o,$(notdir $(DEVICES_SRCS))))
DEVICES_SRCS_DIR := $(DEVICES_DIR)/src
DEVICES_INC_DIR = $(DEVICES_DIR)/inc

########
# Misc #
########

SRCS	 = $(wildcard src/*.c) $(wildcard lib/*.c)
OBJS	 = $(addprefix $(OBJ_DIR)/, $(notdir $(SRCS:.c=.o)))


RM	  = rm -rf					 # Remove recursively command
MKDIR   = @mkdir -p $(@D)			 # Creates folders if not present

##########
# MACROS #
##########

MACRO_LIST =
ifeq ($(SOC_CONFIG), embedded)
MACRO_LIST += -DIS_EMBEDDED
endif

###############################################################################

###########
# Targets #
###########

all: bin/$(PROGRAM_NAME).bin

$(OBJ_DIR)/%.o: $(SRC_DIR)/%.c
	@echo "\n[OBJ] Creating OBJs from src"
	$(MKDIR)
	$(CC) -o $@ $^ $(INC_FLAGS) -I$(INC_DIR) $(LIB_INC_LIST) $(CFLAGS) $(MACRO_LIST)

obj/%.o: $(DEVICES_SRCS_DIR)/%.c
	@echo "\n[OBJ] Creating devices OBJs"
	$(MKDIR)
	$(CC) -o $@ $^ -I$(DEVICES_INC_DIR) $(CFLAGS) $(MACRO_LIST)

obj/startup.o:
	@echo "\n[OBJ] Creating OBJs from $(STARTUP_DIR)/startup.s"
	$(MKDIR)
	$(CC) -o obj/startup.o $(STARTUP_DIR)/startup.s -I$(LIB_INC_LIST) $(CFLAGS)

bin/$(PROGRAM_NAME).elf: $(OBJS) $(DEVICES_OBJS) obj/startup.o
	@echo "\n[ELF] Creating elf file"
	$(MKDIR)
	$(LD) -o $@ $^ $(LDFLAGS)

bin/$(PROGRAM_NAME).bin: bin/$(PROGRAM_NAME).elf
	@echo "\n[BIN] Creating bin file"
	$(OBJCOPY) -O binary bin/$(PROGRAM_NAME).elf bin/$(PROGRAM_NAME).bin

clean:
	-$(RM) obj
	-$(RM) bin

.PHONY: all clean

dump:
	$(OBJDUMP) -D bin/$(PROGRAM_NAME).elf

