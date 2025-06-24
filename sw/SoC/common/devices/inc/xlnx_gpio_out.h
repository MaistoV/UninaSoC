// Author: Stefano Mercogliano <stefano.mercogliano@unina.it>
// Author: Valerio Di Domenico <valer.didomenico@studenti.unina.it>
// Author: Salvatore Santoro <sal.santoro@studenti.unina.it>
// Description: 
//  This file defines the API to adoperate the Output GPIO

#ifndef XLNX_GPIO_OUT_H
#define XLNX_GPIO_OUT_H

#include <stdint.h>

// https://docs.amd.com/v/u/en-US/pg144-axi-gpio

// Import linker script symbol
extern const volatile uint32_t _peripheral_GPIO_out_start;

// GPIO is configured to use just one channel (so all the "2" registers like GPIO2_DATA are unused)

// Base address
#define GPIO_OUT_BASEADDR ((uintptr_t)&_peripheral_GPIO_out_start)

// Registers
#define GPIO_DATA   (GPIO_OUT_BASEADDR + 0x0000) // Data Register
#define GPIO_TRI    (GPIO_OUT_BASEADDR + 0x0004) // Direction Register
#define GPIO2_DATA  (GPIO_OUT_BASEADDR + 0x0008) // Data register second channel
#define GPIO2_TRI   (GPIO_OUT_BASEADDR + 0x000C) // Data register second channel
#define GIER        (GPIO_OUT_BASEADDR + 0x011C) // Global Interrupt Enable Register
#define IP_ISR      (GPIO_OUT_BASEADDR + 0x0120) // Interrupt Status Register
#define IP_IER      (GPIO_OUT_BASEADDR + 0x0128) // Interrupt Enable Register

// The GPIO OUT peripheral has 16 output pins
// every bit in the "DATA" register controls the output of each pins
// here are defined the values to place in the data register to activate each pin
// PIN_0 = 2^0 = 1 (first bit)
// PIN_1 = 2^1 = 2 (second bit)
// and so on...
typedef enum{
    PIN_0 = (1 << 0),
    PIN_1 = (1 << 1),
    PIN_2 = (1 << 2),
    PIN_3 = (1 << 3),
    PIN_4 = (1 << 4),
    PIN_5 = (1 << 5),
    PIN_6 = (1 << 6),
    PIN_7 = (1 << 7),
    PIN_8 = (1 << 8),
    PIN_9 = (1 << 9),
    PIN_10 = (1 << 10),
    PIN_11 = (1 << 11),
    PIN_12 = (1 << 12),
    PIN_13 = (1 << 13),
    PIN_14 = (1 << 14),
    PIN_15 = (1 << 15),
    PIN_ALL = 0xFFFF    // All pins bits
}pin_t;

// Initializes the gpio out peripheral
void xlnx_gpio_out_init();

// Raise the selected pin (to raise multiple pins just use bitwise OR es. PIN_0 | PIN_1)
void xlnx_gpio_out_write(pin_t val);

// Read the content of the DATA register
uint16_t xlnx_gpio_out_read();

// Toggle the selected pin(s) switching 0 and 1 back and forth
int xlnx_gpio_out_toggle(pin_t pin);

#endif
