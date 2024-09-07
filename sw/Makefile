# TODO: this is just a skeleton

# Init to your RISC-V installation
RISCV 	?= 
TARGET 	?= riscv32-unknown-elf
GCC 	= ${RISCV}/${TARGET}-gcc
AS 		= ${RISCV}/${TARGET}-as
OBJCOPY = ${RISCV}/${TARGET}-objcopy
RISCV_MARCH ?= rv32i

LD_GEN = TBD
BIN2COE = bin2coe

# Only temporary, until bootrom is added
PoC_jtag2axi:
	cd ${SW_ROOT}/src/PoC_jtag2axi; \
	./compile.sh

linker/UninaSoC.ld: linker/UninaSoC.ld.tpl
	${LD_GEN} $< -o $@

objs/bootrom.o: src/bootrom.s
	${AS} --march=${RISCV_MARCH} $< -o $@

objs/bootrom.elf: src/bootrom.c objs/bootrom.o linker/UninaSoC.ld
	mkdir -p objs
	${GCC} src/bootrom.c objs/bootrom.o -o $@ -T linker/UninaSoC.ld

# Convert ELF to binary
objs/bootrom.bin: objs/bootrom.elf
	${OBJCOPY} -O binary $< $@

# Convert binary to COE
${BOOTROM_COE}: objs/bootrom.bin
	${BIN2COE} -i $< -o $@ -w 32