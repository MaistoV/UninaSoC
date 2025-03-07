#include "interrupts.h"
#include "plic.h"
#include "xlnx_tim.h"

#ifdef IS_EMBEDDED
    #include "xlnx_gpio.h"
#endif


// This function is based on low risc demo system hal
int install_exception_handler(uint32_t vector_num, void (*handler_fn)(void)) {

    if (vector_num >= 32) return 1;

    volatile uint32_t* vector_table_entry = (uint32_t *)(&_vector_table_start) + vector_num;

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


void _sw_handler(void) {
    // Unused for this example
}

void _timer_handler(void) {
    // Unused for this example
}

void _ext_handler(void) {

    // Interrupts are automatically disabled by the microarchitecture (uarch).
    // Nested interrupts can be enabled manually by setting the IE bit in the mstatus register,
    // but this requires careful handling of registers.
    // Interrupts are automatically re-enabled by the microarchitecture when the MRET instruction is executed.

    // Since this code calls other functions, the compiler will likely save ALL registers,
    // including floating-point and vector registers. To ensure compatibility with most processors,
    // we compile using only the IMA extensions.

    // In this example, the core is connected to PLIC target 1 line.
    // Therefore, we need to access the PLIC claim/complete register 1 (base_addr + 0x200004).
    // The interrupt source ID is obtained from the claim register.
    uint32_t * plic_addr = (uint32_t *) &_peripheral_PLIC_start;
    uint32_t interrupt_id = *(plic_addr + 0x200004/sizeof(uint32_t));

    switch(interrupt_id){
        case 0x0: // unused
            break;
        case 0x1:
        #ifdef IS_EMBEDDED
            // GPIO_in (Switch) interrupts (embedded config only)
            gpio_handler();
        #endif
        break;
        case 0x2:
            // Timer interrupt
            tim_handler();
            break;
        default:
            break;
    }

    // To notify the handler completion, a write-back on the claim/complete register is required.
    *(plic_addr + 0x200004/sizeof(uint32_t)) = interrupt_id;

}