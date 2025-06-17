#ifndef GPIO_H
#define GPIO_H

#include <stdint.h>

// Bits
#define GPIO_DATA    0x0000  // Data Register
#define GPIO_TRI     0x0004  // Direction Register
#define GIER         0x011C  // Global Interrupt Enable Register
#define IP_IER       0x0128  // Interrupt Enable Register
#define IP_ISR       0x0120  // Interrupt Status Register

// Import linker script symbol
extern const volatile uint32_t _peripheral_GPIO_in_start;
extern const volatile uint32_t _peripheral_GPIO_out_start;

// Functions
void gpio_in_configure();
void gpio_in_enable_int();

// This function is called by the external handler
// It implements the logic to turn on a led depending on the switch used.
void gpio_handler();


#endif
