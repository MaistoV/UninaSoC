#define IS_EMBEDDED
#ifdef IS_EMBEDDED // TODO: placeholder to HAL

#include "../inc/xlnx_gpio.h"
#include <stdint.h>

void gpio_enable_int(GPIO_Peripheral* gpio)
{
    // Enable interrupt for the channel (1 in IP_IER)
    gpio->ier = 0x1;
    // Enable global interrupts (1 in GIER)
    gpio->gier = 0x80000000;
}

void gpio_configure(GPIO_Peripheral* gpio, GPIO_Init* init)
{
    if (init->mode == INPUT)
        gpio->tri |= init->pins;
    else
        gpio->tri &= ~init->pins;

    if (init->interrupt == ENABLE_INT)
        gpio_enable_int(gpio);
}

void gpio_handler()
{

    uint32_t* gpio_in_addr = (uint32_t*)&_peripheral_GPIO_in_start;
    uint32_t* gpio_out_addr = (uint32_t*)&_peripheral_GPIO_out_start;

    // Switches to leds
    *gpio_out_addr = *gpio_in_addr;

    // Acknowledge GPIO interrupt has been handled.
    // To do so, go to the Interrupt Status Register (0x120)
    *(gpio_in_addr + 0x120 / sizeof(uint32_t)) = 0x1;
}

#endif // IS_EMBEDDED
