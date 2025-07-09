## UNINASOC CMAC
UNINASOC_CMAC_DIR = $(SW_SOC_ROOT)/lib/uninasoc_cmac
UNINASOC_CMAC_SRCS := $(wildcard $(UNINASOC_CMAC_DIR)/src/*.c)
UNINASOC_CMAC_OBJS := $(patsubst $(UNINASOC_CMAC_DIR)/src/%.c, %.o, $(wildcard $(UNINASOC_CMAC_DIR)/src/*.c))
UNINASOC_CMAC_SRCS_DIR := $(UNINASOC_CMAC_DIR)/src
UNINASOC_CMAC_LIB := $(UNINASOC_CMAC_DIR)/lib/libuninasoc_cmac.a
UNINASOC_CMAC_INC := $(UNINASOC_CMAC_DIR)/inc
TINY_IO := $(SW_SOC_ROOT)/lib/tinyio/inc

include $(SW_ROOT)/SoC/common/config.mk

all: $(UNINASOC_CMAC_LIB)

# Build sources for devices
%.o: $(UNINASOC_CMAC_SRCS_DIR)/%.c
	@echo "[CC] $<"
	$(CC) -c $< -o $@ -I$(UNINASOC_CMAC_INC) -I$(TINY_IO) $(CFLAGS) $(MACRO_LIST)

# Build libuninasoc.a library
$(UNINASOC_CMAC_LIB): $(UNINASOC_CMAC_OBJS)
	@echo "\n[OBJ] Creating libuninasoc.a library"
	echo "THIS IS THE ROOT YOU'RE USING: $(SW_SOC_ROOT)"
	@mkdir -p lib
	ar rcs $(UNINASOC_CMAC_LIB) $(UNINASOC_CMAC_OBJS)
	@rm -f $(UNINASOC_CMAC_OBJS)

clean:
	@rm $(UNINASOC_CMAC_LIB)