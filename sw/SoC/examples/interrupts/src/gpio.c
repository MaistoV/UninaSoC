
#include "gpio.h"

uint32_t switch_current_status;

void gpio_in_configure(){

    uint32_t * gpio_in_addr = (uint32_t *) &_peripheral_GPIO_in_start;

    // Configure GPIO as input (1 in GPIO_TRI)
    *(gpio_in_addr + (GPIO_TRI / sizeof(uint32_t))) = (0x1);  // Configure the first pin as input

    // Initialize swtich_status
    switch_current_status = *gpio_in_addr;

}

void gpio_in_enable_int(){

    uint32_t * gpio_in_addr = (uint32_t *) &_peripheral_GPIO_in_start;

    // Enable interrupt for the channel (1 in IP_IER)
    *(gpio_in_addr + (IP_IER / sizeof(uint32_t))) = (0x1);  // Enable interrupt on the first pin

    // Enable global interrupts (1 in GIER)
    *(gpio_in_addr + (GIER / sizeof(uint32_t))) = (0x80000000);  // Enable global interrupts by writing 1 to the 32nd bit of the register

}

void gpio_handler() {

    uint32_t * gpio_in_addr = (uint32_t *) &_peripheral_GPIO_in_start;
    uint32_t * gpio_out_addr = (uint32_t *) &_peripheral_GPIO_out_start;
    
    // First, identify the status of the switches
    uint32_t switch_next_status = *gpio_in_addr;
    uint32_t switch_mask = switch_next_status ^ switch_current_status;

    // Toggle the leds associated to the switch diff
    uint32_t led_status = *gpio_out_addr;
    uint32_t target_led;
    uint32_t non_target_led;

    // First, we toggle all the target leds
    target_led = led_status ^ switch_mask;

    // Then we select all the target leds
    target_led = led_status & switch_mask;

    // Now we select only the non-target leds
    non_target_led = led_status & ~switch_mask;

    // Finally, we build the new led status
    led_status = target_led | non_target_led;
    *gpio_out_addr = led_status;

    // Acknowledge GPIO interrupt has been handled.
    // To do so, go to the Interrupt Status Register (0x120)
    *(gpio_in_addr + 0x120/sizeof(uint32_t)) = 0x1;

    // Update switch current status
    switch_current_status = switch_next_status;
}