#ifndef INTERRUPTS_H
#define INTERRUPTS_H

#include <stdint.h>

#define SW_ENTRY    3
#define TIM_ENTRY   7
#define EXT_ENTRY   11


// Import linker script symbol
extern const volatile uint32_t _vector_table_start;

// Functions
int install_exception_handler(uint32_t vector_num, void (*handler_fn)(void));

// Handlers
void _sw_handler();
void _tim_handler();
void _ext_handler();

#endif 