
#include "interrupts.h"

// This function is based on low risc demo system hal
int install_exception_handler(uint32_t vector_num, void (*handler_fn)(void)) {

    if (vector_num >= 32) return 1;

    volatile uint32_t* vector_table_entry = (uint32_t *)(_vector_table_start + vector_num*4);

    // Compute the relative jump stride
    int32_t offset = (uint32_t)handler_fn - (uint32_t)vector_table_entry;

    // Build the jump instruction
    if ((offset >= (1 << 19)) || (offset < -(1 << 19))) {
      return 2;
    }

    uint32_t offset_uimm = offset;
    uint32_t jmp_ins = ((offset_uimm & 0x7fe) << 20) |     // imm[10:1] -> 21
                       ((offset_uimm & 0x800) << 9) |      // imm[11] -> 20
                       (offset_uimm & 0xff000) |           // imm[19:12] -> 12
                       ((offset_uimm & 0x100000) << 11) |  // imm[20] -> 31
                       0x6f;                               // J opcode

    // Overwrite vector table entry with the jump instruction
    *vector_table_entry = jmp_ins;

    //__asm__ volatile("fence.i;");

    return 0;
}


void _sw_handler() {
    // Unimplemented
}

void _tim_handler() {
    // Unimplemented
}

void _ext_handler() {

    // Connected to the PLIC

    // Is it coming from GPIO_in?

    // Is it coming from TIM?
}