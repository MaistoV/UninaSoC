###############################################################################
# Toolchain
#
# First, specify your toolchain to compile the library.
# Libraries available are compiled with riscv32-unknown-elf-

RV_PREFIX = 	/opt/rv32/bin/riscv32-unknown-elf-
CC = 			$(RV_PREFIX)gcc
AR = 			$(RV_PREFIX)ar
OBJDUMP = 		$(RV_PREFIX)objdump

#Architecture
C_EXTENSION 	?= N
F_EXTENSION		?= N

ARCH = rv32imad

ifeq ($(F_EXTENSION), Y) 
ARCH := $(addsuffix f,$(ARCH))
endif

ifeq ($(C_EXTENSION), Y) 
ARCH := $(addsuffix c,$(ARCH))
endif

ARCH := $(addsuffix _zicsr_zifencei,$(ARCH))

# Compiler flags
CFLAGS = 		-march=$(ARCH)
CFLAGS +=		-Wall -Werror -Wno-unused-but-set-variable
CFLAGS +=		-O2
CFLAGS += 		-c

# Include
INCLUDES = 		-Iinc

# Configurations
LONG_SUPPORT			?= N
FLOAT_SUPPORT			?= N
EXP_SUPPORT				?= N
PTR_SUPPORT				?= N

ifeq ($(LONG_SUPPORT), N)
MACRO_LIST += -DPRINTF_DISABLE_SUPPORT_LONG_LONG
endif

ifeq ($(FLOAT_SUPPORT), N) 
MACRO_LIST += -DPRINTF_DISABLE_SUPPORT_FLOAT
endif

ifeq ($(EXP_SUPPORT), N) 
MACRO_LIST += -DPRINTF_DISABLE_SUPPORT_EXPONENTIAL
endif

ifeq ($(PTR_SUPPORT), N) 
MACRO_LIST += -DPRINTF_DISABLE_SUPPORT_PTRDIFF_T
endif



###############################################################################
# Targets

SRCS = $(wildcard src/*.c)
OBJS = $(SRCS:.c=.o)

LIB = lib/tinyio.a

all: $(LIB)

# Create the library
$(LIB): $(OBJS)
	@mkdir -p lib
	$(AR) rcs $@ $^
	rm src/*.o
	
dump:
	$(OBJDUMP) -f lib/tinyio.a

# Object file compilation
%.o: %.c
	$(CC) $(CFLAGS) $(INCLUDES) $(MACRO_LIST) -c $< -o $@

clean:
	rm -f $(OBJS) $(LIB)/* $(BIN)

.PHONY: all clean dump

