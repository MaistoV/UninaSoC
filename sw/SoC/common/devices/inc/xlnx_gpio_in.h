// Author: Stefano Mercogliano <stefano.mercogliano@unina.it>
// Author: Valerio Di Domenico <valer.didomenico@studenti.unina.it>
// Author: Salvatore Santoro <sal.santoro@studenti.unina.it>
// Description: 
//  This file defines the API to adoperate the Input GPIO


#ifndef XLNX_GPIO_IN_H
#define XLNX_GPIO_IN_H

#include <stdint.h>

// https://docs.amd.com/v/u/en-US/pg144-axi-gpio

// Import linker script symbol
extern const volatile uint32_t _peripheral_GPIO_in_start;

// GPIO is configured to use just one channel (so all the "2" registers like GPIO2_DATA are unused)

#define GPIO_IN_BASEADDR ((uintptr_t)&_peripheral_GPIO_in_start)

// Bits
#define GPIO_IN_DATA     (GPIO_IN_BASEADDR + 0x0000) // Data Register
#define GPIO_IN_TRI      (GPIO_IN_BASEADDR + 0x0004) // Direction Register
#define GPIO2_IN_DATA    (GPIO_IN_BASEADDR + 0x0008) // Data register second channel
#define GPIO2_IN_TRI     (GPIO_IN_BASEADDR + 0x000C) // Data register second channel
#define GPIO_IN_GIER     (GPIO_IN_BASEADDR + 0x011C) // Global Interrupt Enable Register
#define GPIO_IN_ISR      (GPIO_IN_BASEADDR + 0x0120) // Interrupt Status Register
#define GPIO_IN_IER      (GPIO_IN_BASEADDR + 0x0128) // Interrupt Enable Register

// INTERRUPTS
typedef enum {
    ENABLE_INT,
    DISABLE_INT
} interrupt_conf_t;

// Initialize the input gpio and choose to enable or disable interrupts
void xlnx_gpio_in_init(interrupt_conf_t ic);

// Function that clears the gpio input interrupt bit, effectively signaling the completition
// of interrupt handling
// It's supposed to be used inside Input GPIO's interrupt handler
void xlnx_gpio_in_clear_int();

// This function returns the content of the Input GPIO's register, used to read input data
uint16_t xlnx_gpio_in_read();

#endif
