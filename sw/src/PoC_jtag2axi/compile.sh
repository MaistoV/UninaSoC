# /https://github.com/MaistoV/UninaSoC/blob/main/hw/xilinx/rtl/uninasoc.sv#L1 :
# Author: Zaira Abdel Majid <z.abdelmajid@studenti.unina.it>
# Description: a useful .sh to compile a sample Blink Led PoC
# Output: bilnk.elf, blink.bin 

riscv64-unknown-elf-as -march=rv32im -mabi=ilp32 digitalwrite.S -o digitalwrite.o &&
riscv64-unknown-elf-as -march=rv32im -mabi=ilp32 start.S -o start.o &&
riscv64-unknown-elf-gcc -march=rv32im -mabi=ilp32 -r main.c -o main.o &&
riscv64-unknown-elf-ld main.o digitalwrite.o -o blink.elf -T blink.ld -m elf32lriscv -nostdlib --no-relax &&
riscv64-unknown-elf-objcopy -O binary blink.elf blink.bin


rm start.o main.o digitalwrite.o
