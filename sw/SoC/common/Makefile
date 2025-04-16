# Author: Stefano Mercogliano <stefano.mercogliano@unina.it>
# Description:
#   The common Makefile includes the standard targets to build bare-metal code.
#	Each application will include this makefile and define the envvar related to path, dependencies and compilation flags.

SOC_SW_ROOT_DIR = $(SW_ROOT)/SoC
LIB_DIR	= $(SOC_SW_ROOT_DIR)/lib

########
# Misc #
########

SRCS	 = $(wildcard src/*.c) $(wildcard lib/*.c)
OBJS	 = $(addprefix $(OBJ_DIR)/, $(notdir $(SRCS:.c=.o)))

RM	  = rm -rf					 # Remove recursively command
MKDIR   = @mkdir -p $(@D)			 # Creates folders if not present

###############################################################################

###########
# Targets #
###########

all: bin/$(PROGRAM_NAME).bin bin/$(PROGRAM_NAME).dump

$(OBJ_DIR)/%.o: $(SRC_DIR)/%.c
	@echo "\n[OBJ] Creating OBJs $@ from SRC $^"
	$(MKDIR)
	$(CC) -o $@ $^ $(INC_FLAGS) $(LIB_INC_LIST) $(CFLAGS)

obj/startup.o:
	@echo "\n[OBJ] Creating OBJ $@ from SRC $(STARTUP_DIR)/startup.s"
	$(MKDIR)
	$(CC) -o obj/startup.o $(STARTUP_DIR)/startup.s $(CFLAGS) $(LIB_INC_LIST)

bin/$(PROGRAM_NAME).elf: $(OBJS) obj/startup.o
	@echo "\n[ELF] Linking $^ into $@"
	$(MKDIR)
	$(LD) -o $@ $^ $(LDFLAGS)

bin/$(PROGRAM_NAME).bin: bin/$(PROGRAM_NAME).elf
	@echo "\n[BIN] Creating bin file"
	$(OBJCOPY) -O binary bin/$(PROGRAM_NAME).elf bin/$(PROGRAM_NAME).bin

clean:
	-$(RM) obj
	-$(RM) bin

.PHONY: all clean

dump: bin/$(PROGRAM_NAME).dump
bin/$(PROGRAM_NAME).dump:
	$(OBJDUMP) -D bin/$(PROGRAM_NAME).elf > $@

