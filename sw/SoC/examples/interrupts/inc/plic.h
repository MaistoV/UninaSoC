#ifndef PLIC_H
#define PLIC_H

#include <stdint.h>

// Import linker script symbol
extern const volatile uint32_t _peripheral_PLIC_start;

// Functions
void plic_configure();
void plic_enable();

#endif