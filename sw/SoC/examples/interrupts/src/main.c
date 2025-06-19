// Author: Stefano Mercogliano <stefano.mercogliano@unina.it>
// Author: Valerio Di Domenico <valer.didomenico@studenti.unina.it>
// Description:
//      This code demonstrates the usage of PLIC and interrupts.
//      Physically, three interrupt lines are connected (in addition to line 0, which is reserved).
//      Logically, two interrupt sources are utilized: a timer and gpio_in.
//      The timer sends a message on the serial device every second, while gpio_in enables
//      the LED corresponding to a specific switch (only applicable in embedded configurations).
//
//      Note 1: The PLIC is connected to the core via the EXT line. Both the timer and gpio_in are expected
//      to be connected to the PLIC. The timer must NOT be connected directly to the core's TIM line in this example.
//
//      Note 2: The IS_EMBEDDED macro is automatically defined in this example's Makefile depending on
//      vesuvius configuration (according to the SOC_CONFIG envvar set in settings.sh)
//

#include <stdint.h>

#include "xlnx_tim.h"
#include "plic.h"
#include "interrupts.h"
#include "serial.h"

#ifdef IS_EMBEDDED
    #include "xlnx_gpio_in.h"
#endif

#define SOURCES_NUM 3

void _sw_handler() __handler__;
void _timer_handler() __handler__;
void _ext_handler() __handler__;

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

    switch(interrupt_id){
        case 0x0: // unused
            break;
        case 0x1:
        #ifdef IS_EMBEDDED
            printf("GPIO HANDLER REDEFINED\r\n");
            xlnx_gpio_in_clear_int();
        #endif
        break;
        case 0x2:
            // Timer interrupt
            printf("TIMER HANDLER REDEFINED\r\n");
            xlnx_tim_clear_int();
            break;
        default:
            break;
    }

    // To notify the handler completion, a write-back on the claim/complete register is required.
    plic_complete(interrupt_id);
}

int main(){


    // Initialize the serial device (using tinyIO)
    serial_init();

    printf("Interrupts Example\n\r");

    // Configure the PLIC
    uint32_t priorities[SOURCES_NUM] = { 1, 1, 1};
    plic_configure(priorities, SOURCES_NUM);
    plic_enable_all();

    #ifdef IS_EMBEDDED
    // Configure the GPIO (embedded only)
        xlnx_gpio_in_init(ENABLE_INT);
    #endif

    // Configure the timer
    uint32_t counter = 0x1312D00;
    xlnx_tim_configure(counter);
    xlnx_tim_enable_int();
    xlnx_tim_start();

    while(1);

    return 0;
}
