#ifndef GPIO_H
#define GPIO_H

#include <cstdint>
#include <stdint.h>

// https://docs.amd.com/v/u/en-US/pg144-axi-gpio

// GPIO is configured to use just one channel (so all the "2" registers like GPIO2_DATA are unused)

// Bits
#define GPIO_DATA 0x0000 // Data Register
#define GPIO_TRI 0x0004 // Direction Register
#define GPIO2_DATA 0x0008 // Data register second channel
#define GPIO2_TRI 0x000C // Data register second channel
#define GIER 0x011C // Global Interrupt Enable Register
#define IP_ISR 0x0120 // Interrupt Status Register
#define IP_IER 0x0128 // Interrupt Enable Register


// GPIO peripherals, used to choose the GPIO to configure
typedef struct{
    uint32_t data;
    uint32_t tri;
    uint32_t data_2;
    uint32_t trie_2;
    uint8_t padding[0x010C];
    uint32_t gier;
    uint32_t isr;
    uint32_t ier;
} GPIO_Peripheral;


// Import linker script symbol
extern const volatile uint32_t _peripheral_GPIO_in_start;
extern const volatile uint32_t _peripheral_GPIO_out_start;

#define GPIO_IN  ((GPIO_Peripheral *)&_peripheral_GPIO_in_start)
#define GPIO_OUT ((GPIO_Peripheral *)&_peripheral_GPIO_out_start)

// PINS (GPIOS are configured with 16-bits width)
enum {
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
}

// PINS MODE
enum {
    INPUT,
    OUTPUT
}

// INTERRUPTS
enum {
    ENABLE_INT,
    DISABLE_INT
}

// GPIO initialization struct
typedef struct {
    uint16_t pins;
    uint16_t mode : 1;
    uint16_t interrupt : 1;
} GPIO_Init;

// Not atomic RMW
// General config function, sets all the pins (specified inside GPIO_Init) to the selected mode
// If the GPIO is set to output mode, the eint field is ignored
void gpio_configure(GPIO_Peripheral* gpio, GPIO_Init* init);

void gpio_enable_int(GPIO_Peripheral* gpio);

// This function is called by the external handler
// It implements the logic to turn on a led depending on the switch used.
void gpio_handler();

#endif
