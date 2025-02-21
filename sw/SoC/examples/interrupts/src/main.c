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

#include "tim.h"
#include "plic.h"
#include "interrupts.h"
#include "serial.h"

#ifdef IS_EMBEDDED
    #include "gpio.h"
#endif 

int main(){

    // Define vector table entries for handlers (only the EXT line is actually used).
    install_exception_handler(SW_ENTRY, _sw_handler);
    install_exception_handler(TIM_ENTRY, _timer_handler);
    install_exception_handler(EXT_ENTRY, _ext_handler);

    // Initialize the serial device (using tinyIO)
    serial_init();

    // Configure the PLIC
    plic_configure();
    plic_enable();

    #ifdef IS_EMBEDDED
    // Configure the GPIO (embedded only)
    
        gpio_in_configure();
        gpio_in_enable_int();
    #endif

    // Configure the timer
    tim_configure();
    tim_enable_int();
    tim_enable();

    while(1);

    return 0;
}
