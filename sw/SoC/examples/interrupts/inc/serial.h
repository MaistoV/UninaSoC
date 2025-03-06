#ifndef PRINT_H
#define PRINT_H

#include "tinyIO.h"

// Import linker script symbol
extern const volatile uint32_t _peripheral_UART_start;

void serial_init();


#endif