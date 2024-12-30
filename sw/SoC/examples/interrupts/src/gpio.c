
#include "gpio.h"

void gpio_in_configure(){

    uint32_t * gpio_in_addr = (uint32_t *)_peripheral_GPIO_in_start;

    // Configure GPIO as input (1 in GPIO_TRI)
    *(gpio_in_addr + (GPIO_TRI / sizeof(uint32_t))) = (0x1);  // Configure the first pin as input

}

void gpio_in_enable_int(){

    uint32_t * gpio_in_addr = (uint32_t *)_peripheral_GPIO_in_start;

    // Enable interrupt for the channel (1 in IP_IER)
    *(gpio_in_addr + (IP_IER / sizeof(uint32_t))) = (0x1);  // Enable interrupt on the first pin

    // Enable global interrupts (1 in GIER)
    *(gpio_in_addr + (GIER / sizeof(uint32_t))) = (0x80000000);  // Enable global interrupts by writing 1 to the 32nd bit of the register

}