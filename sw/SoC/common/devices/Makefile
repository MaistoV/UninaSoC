## DEVICES
## TODO47: this is just a placeholder for a HAL library
DEVICES_DIR = $(SW_SOC_ROOT)/common/devices
DEVICES_SRCS := $(wildcard $(DEVICES_DIR)/src/*.c)
DEVICES_OBJS := $(patsubst $(DEVICES_DIR)/src/%.c, %.o, $(wildcard $(DEVICES_DIR)/src/*.c))
DEVICES_SRCS_DIR := $(DEVICES_DIR)/src
DEVICES_LIB := $(DEVICES_DIR)/lib/libuninasoc.a
DEVICES_INC := $(DEVICES_DIR)/inc
TINY_IO := $(SW_SOC_ROOT)/lib/tinyio/inc

include $(SW_ROOT)/SoC/common/config.mk

all: $(DEVICES_LIB)

# Build sources for devices
%.o: $(DEVICES_SRCS_DIR)/%.c
	@echo "[CC] $<"
	$(CC) -c $< -o $@ -I$(DEVICES_INC) -I$(TINY_IO) $(CFLAGS) $(MACRO_LIST)

# Build libuninasoc.a library
$(DEVICES_LIB): $(DEVICES_OBJS)
	@echo "\n[OBJ] Creating libuninasoc.a library"
	mkdir -p lib
	ar rcs $(DEVICES_LIB) $(DEVICES_OBJS)	
	@rm -f $(DEVICES_OBJS)

clean:
	@rm $(DEVICES_LIB)
