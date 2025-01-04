#include <stdint.h>

#include "tim.h"
#include "gpio.h"
#include "plic.h"
#include "interrupts.h"

#include "tinyIO.h"

#define IS_EMBEDDED 1

extern const volatile uint32_t _peripheral_UART_start;

int main(){

    uint32_t* uart_base_address = (uint32_t*) &_peripheral_UART_start;

    tinyIO_init((uint32_t) uart_base_address);

    printf("\n\r");
    printf("* Interrupt Tests *\n\r");
    printf("\n\r");

    // This code is an example of PLIC and interrupts.
    // Phyisically, 3 interrupt lines are connected (plus line 0, which is reserved)
    // Logically, two sources of interrupts are used: timer and gpio_in
    // The former sends on the uart a message, while the latter 
    // Enable the led corresponding to the specific switch (only on embedded configuration)

    // Note: the PLIC is connected to the core via EXT line. both timer and gpio_in are expected
    // to be connected to the PLIC; the timer should NOT be connected to the core TIM line for this example.

    uint32_t * vt = (uint32_t *) &_vector_table_start;
    
    printf("Software Handler Jump: 0x%08x\n\r", vt[SW_ENTRY]);
    printf("Timer Handler Jump: 0x%08x\n\r", vt[TIM_ENTRY]);
    printf("External Handler Jump: 0x%08x\n\r", vt[EXT_ENTRY]);
    printf("\n\r");

    // Define vector table entries for handlers (only EXT is actually used)
    install_exception_handler(SW_ENTRY, _sw_handler);
    install_exception_handler(TIM_ENTRY, _tim_handler);
    install_exception_handler(EXT_ENTRY, _ext_handler);

    printf("Software Handler Jump: 0x%08x\n\r", vt[SW_ENTRY]);
    printf("Timer Handler Jump: 0x%08x\n\r", vt[TIM_ENTRY]);
    printf("External Handler Jump: 0x%08x\n\r", vt[EXT_ENTRY]);
    printf("\n\r");

    // Configure the PLIC
    plic_configure();
    plic_enable();

    // Configure the GPIO
    if (IS_EMBEDDED) {
        gpio_in_configure();
        gpio_in_enable_int();
    }

    ///////////////////////
    // Debug Print Begin //
    ///////////////////////

    /*uint32_t result;

    printf("Registers data:\n\r");

    __asm__ volatile("csrr %0, mtvec;" : "=r"(result));
    printf("mtvec: 0x%08x\n\r", result);
    __asm__ volatile("csrr %0, mstatus;" : "=r"(result));
    printf("mstatus: 0x%08x\n\r", result);
    __asm__ volatile("csrr %0, mie;" : "=r"(result));
    printf("mie: 0x%08x\n\r", result);*/

    /////////////////////
    // Debug Print End //
    /////////////////////


    // Configure the timer
    /*tim_configure();
    tim_enable_int();
    tim_enable();*/

    while(1);

    return 0;
}

