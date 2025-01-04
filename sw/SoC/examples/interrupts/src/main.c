


#include <stdint.h>

#include "tim.h"
#include "gpio.h"
#include "plic.h"
#include "interrupts.h"
#include "print.h"

#define IS_EMBEDDED 1

int main(){

    // This code is an example of PLIC and interrupts.
    // Phyisically, 3 interrupt lines are connected (plus line 0, which is reserved)
    // Logically, two sources of interrupts are used: timer and gpio_in
    // The former sends on the serial a message, while the latter 
    // Enable the led corresponding to the specific switch (only on embedded configuration)

    // Note: the PLIC is connected to the core via EXT line. both timer and gpio_in are expected
    // to be connected to the PLIC; the timer should NOT be connected to the core TIM line for this example.

    // Define vector table entries for handlers (only EXT is actually used)
    install_exception_handler(SW_ENTRY, _sw_handler);
    install_exception_handler(TIM_ENTRY, _timer_handler);
    install_exception_handler(EXT_ENTRY, _ext_handler);

    // Initialize the serial device (using tinyIO)
    serial_init();

    // Configure the PLIC
    plic_configure();
    plic_enable();

    // Configure the GPIO
    if (IS_EMBEDDED) {
        gpio_in_configure();
        gpio_in_enable_int();
    }

    // Configure the timer
    tim_configure();
    tim_enable_int();
    tim_enable();

    while(1);

    return 0;
}

