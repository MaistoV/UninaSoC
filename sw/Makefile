# TODO: this is just a skeleton

# RISC-V toolchain
XLEN	?= 32
TARGET 	?= riscv${XLEN}-unknown-elf
CC 		:= ${TARGET}-gcc
LD 		:= ${TARGET}-ld
AS 		:= ${TARGET}-as
OBJCOPY := ${TARGET}-objcopy
OBJDUMP := ${TARGET}-objdump
RISCV_MARCH ?= rv32gc_zicsr_zifencei

LD_GEN = TBD
BIN2COE = bin2coe

all: template

# Only temporary, until bootrom is added

.PHONY: template host_virtual_uart soc_virtual_uart_hello_world soc_virtual_uart_echo_server

# For now the selection of the application is a mare target, we could also pass the application to this Makefile (i.e. make APP=...)
# SoC applications
template:
	${MAKE} -C SoC/template

soc_virtual_uart_hello_world:
	${MAKE} -C SoC/examples/virtual_uart_hello_world

soc_virtual_uart_echo_server:
	${MAKE} -C SoC/examples/virtual_uart_echo_server

# Host applications
host_virtual_uart:
	${MAKE} -C host/virtual_uart

###############################################################################################################

linker/UninaSoC.ld: linker/UninaSoC.ld.tpl
	${LD_GEN} $< -o $@

objs/bootrom.o: src/bootrom.s
	${AS} --march=${RISCV_MARCH} $< -o $@

objs/bootrom.elf: src/bootrom.c objs/bootrom.o linker/UninaSoC.ld
	mkdir -p objs
	${CC} src/bootrom.c objs/bootrom.o -o $@ -T linker/UninaSoC.ld

# Convert ELF to binary
objs/bootrom.bin: objs/bootrom.elf
	${OBJCOPY} -O binary $< $@

# Convert binary to COE
${BOOTROM_COE}: objs/bootrom.bin
	${BIN2COE} -i $< -o $@ -w 32