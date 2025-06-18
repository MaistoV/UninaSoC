#ifndef XLNX_GPIO_IN_H
#define XLNX_GPIO_IN_H

#include <stdint.h>

// https://docs.amd.com/v/u/en-US/pg144-axi-gpio

// Import linker script symbol
extern const volatile uint32_t _peripheral_GPIO_in_start;

// GPIO is configured to use just one channel (so all the "2" registers like GPIO2_DATA are unused)

#define GPIO_IN ((uintptr_t)&_peripheral_GPIO_in_start)

// Bits
#define GPIO_DATA GPIO_IN + 0x0000 // Data Register
#define GPIO_TRI GPIO_IN + 0x0004 // Direction Register
#define GPIO2_DATA GPIO_IN + 0x0008 // Data register second channel
#define GPIO2_TRI GPIO_IN + 0x000C // Data register second channel
#define GIER GPIO_IN + 0x011C // Global Interrupt Enable Register
#define IP_ISR GPIO_IN + 0x0120 // Interrupt Status Register
#define IP_IER GPIO_IN + 0x0128 // Interrupt Enable Register

// INTERRUPTS
typedef enum {
    ENABLE_INT,
    DISABLE_INT
} interrupt_conf_t;

void xlnx_gpio_in_init(interrupt_conf_t ic);

uint16_t xlnx_gpio_in_read();

#endif
