###############################################################################
# Propject Info

PROJECT = filename
MCU = DEMOSYSTEM

###############################################################################

###############################################################################
# Directories

SOC_SW_ROOT_DIR = ../..
SRCS = 		      $(wildcard src/*.c) $(wildcard lib/*.c)
OBJ = 		      obj/
OBJS = 		      $(addprefix $(OBJ), $(notdir $(SRCS:.c=.o)))
LD_SCRIPT =       $(SOC_SW_ROOT_DIR)/linker/$(MCU)_FLASH.ld
INC = 		      -Iinc 
STARTUP = 	      startup

LIBLIST = 

###############################################################################
# Toolchain

# If you have 64-bit toolchain
# RV_PREFIX = riscv64-unknown-elf-
# 32BITCCFLAGS = -march=rv32im -mabi=ilp32
# 32BITODFLAGS = -mriscv:rv32
# CC = $(RV_PREFIX)gcc $(32BITCCFLAGS)
# OBJDUMP = $(RV_PREFIX)objdump $(32BITODFLAGS)
#

RV_PREFIX = 	riscv32-unknown-elf-
CC = 			$(RV_PREFIX)gcc
LD = 			$(RV_PREFIX)ld
OBJDUMP = 		$(RV_PREFIX)objdump
OBJCOPY = 		$(RV_PREFIX)objcopy

CFLAGS = 		-march=rv32imad_zicsr_zifencei -O0 -c 
LDFLAGS = 		$(LIBLIST) -nostdlib -T$(LD_SCRIPT)



###############################################################################

###############################################################################
# Misc

RM      = rm -rf 					# Remove recursively command
MKDIR   = @mkdir -p $(@D) 			# Creates folders if not present

###############################################################################

all: bin/$(PROJECT).bin

$(OBJ)%.o: src/%.c
	@echo "\n[OBJ]	Creating OBJs from src"
	$(MKDIR)
	$(CC) -o $@ $^ $(INC) $(CFLAGS)

$(OBJ)%.o: lib/%.c
	@echo "\n[OBJ]	Creating OBJs from libs"
	$(MKDIR)
	$(CC) -o $@ $^ $(INC) $(CFLAGS)

obj/$(STARTUP).o: $(SOC_SW_ROOT_DIR)/startup/$(STARTUP).s
	@echo "\n[OBJ]	Creating OBJs from $(STARTUP).s"
	$(MKDIR)
	$(CC) -o obj/$(STARTUP).o $(SOC_SW_ROOT_DIR)/startup/$(STARTUP).s $(INC) $(CFLAGS)

bin/$(PROJECT).elf: $(OBJS) obj/$(STARTUP).o
	@echo "\n[ELF]	Creating elf file"
	$(MKDIR)
	$(LD) -o $@ $^ $(LDFLAGS)

bin/$(PROJECT).bin: bin/$(PROJECT).elf
	@echo "\n[ELF]	Creating bin file"
	$(OBJCOPY) -O binary bin/$(PROJECT).elf bin/$(PROJECT).bin

clean:
	-$(RM) obj
	-$(RM) bin

.PHONY: all clean

dump:
	$(OBJDUMP) -D bin/$(PROJECT).elf

