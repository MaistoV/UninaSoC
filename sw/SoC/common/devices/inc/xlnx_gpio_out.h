#ifndef XLNX_GPIO_OUT_H
#define XLNX_GPIO_OUT_H

#include <stdint.h>

// https://docs.amd.com/v/u/en-US/pg144-axi-gpio

// Import linker script symbol
extern const volatile uint32_t _peripheral_GPIO_out_start;

// GPIO is configured to use just one channel (so all the "2" registers like GPIO2_DATA are unused)

#define GPIO_OUT ((uintptr_t)&_peripheral_GPIO_out_start)

// Bits
#define GPIO_DATA GPIO_OUT + 0x0000 // Data Register
#define GPIO_TRI GPIO_OUT + 0x0004 // Direction Register
#define GPIO2_DATA GPIO_OUT + 0x0008 // Data register second channel
#define GPIO2_TRI GPIO_OUT + 0x000C // Data register second channel
#define GIER GPIO_OUT + 0x011C // Global Interrupt Enable Register
#define IP_ISR GPIO_OUT + 0x0120 // Interrupt Status Register
#define IP_IER GPIO_OUT + 0x0128 // Interrupt Enable Register

// INTERRUPTS
typedef enum {
    ENABLE_INT,
    DISABLE_INT
} interrupt_conf_t;

void xlnx_gpio_out_init();

void xlnx_gpio_out_write(uint16_t val);

#endif
