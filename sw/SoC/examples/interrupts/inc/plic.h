#ifndef PLIC_H
#define PLIC_H

#include <stdint.h>

#define INT_ENABLE_OFFSET 0x2000
#define SOURCE_NUM 4

// Import linker script symbol
extern const volatile uint32_t _peripheral_PLIC_start;

// Functions
void plic_configure();
void plic_enable();

#endif