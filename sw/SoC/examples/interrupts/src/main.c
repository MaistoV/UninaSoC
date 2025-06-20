// Author: Stefano Mercogliano <stefano.mercogliano@unina.it>
// Author: Valerio Di Domenico <valer.didomenico@studenti.unina.it>
// Author: Salvatore Santoro <sal.santoro@studenti.unina.it>
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
#include "tinyIO.h"

#include "xlnx_tim.h"
#include "plic.h"
#include "irq_handlers.h"
#include "xlnx_gpio_out.h"

#ifdef IS_EMBEDDED
    #include "xlnx_gpio_in.h"
#endif

#define SOURCES_NUM 3

// IMPORTANT:
// when defining custom handlers always use the "__irq_handler__" symbol
// this symbol is crucial, omitting it would make the compiler treat them like normal functions
// creating wrong epilogue and prologue

void _sw_handler() __irq_handler__;
void _timer_handler() __irq_handler__;
void _ext_handler() __irq_handler__;

void _sw_handler(void) {
    // Unused for this example
}

void _timer_handler(void) {
    // Unused for this example
}

void _ext_handler(void) {
    // Interrupts are automatically disabled by the microarchitecture.
    // Nested interrupts can be enabled manually by setting the IE bit in the mstatus register,
    // but this requires careful handling of registers.
    // Interrupts are automatically re-enabled by the microarchitecture when the MRET instruction is executed.

    // In this example, the core is connected to PLIC target 1 line.
    // Therefore, we need to access the PLIC claim/complete register 1 (base_addr + 0x200004).
    // The interrupt source ID is obtained from the claim register.
    uint32_t interrupt_id = plic_claim();
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

// Import linker script symbol
extern const volatile uint32_t _peripheral_UART_start;

// Main function
int main(){

    // Initialize tinyIO
    uint32_t* uart_base_address = (uint32_t*) &_peripheral_UART_start;
    tinyIO_init((uint32_t) uart_base_address);

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

    // Hot-loop, waiting for interrupts to occur
    while(1);

    return 0;
}
