#include "interrupts.h"
#include "plic.h"
#include "xlnx_tim.h"
#include "xlnx_gpio_out.h"

#ifdef IS_EMBEDDED
    #include "xlnx_gpio_in.h"
#endif


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
    uint32_t interrupt_id = plic_claim();

    // JUST TURN LEDS ON TO SIGNAL THAT INTERRUPTS ARE WORKING
    xlnx_gpio_out_init();

    switch(interrupt_id){
        case 0x0: // unused
            break;
        case 0x1:
        #ifdef IS_EMBEDDED
            xlnx_gpio_out_toggle(PIN_0);
            xlnx_gpio_in_clear_int();
            //gpio_handler();
        #endif
        break;
        case 0x2:
            // Timer interrupt
            xlnx_gpio_out_toggle(PIN_1);
            xlnx_tim_clear_int();
            //tim_handler();
            break;
        default:
            break;
    }

    // To notify the handler completion, a write-back on the claim/complete register is required.
    plic_complete(interrupt_id);
}
