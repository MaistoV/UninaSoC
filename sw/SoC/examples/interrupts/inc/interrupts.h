#ifndef INTERRUPTS_H
#define INTERRUPTS_H

#include <stdint.h>

#define SW_ENTRY    3
#define TIM_ENTRY   7
#define EXT_ENTRY   11


// Import linker script symbol
extern const volatile uint32_t _vector_table_start;

// Functions
// This function takes a handler function pointer and the vector entry number.
// It generates a jump instruction relative to handler_fn and writes it into
// the vector table, assuming the table is writable and not protected by PMP.
int install_exception_handler(uint32_t vector_num, void (*handler_fn)(void));

// Handlers
// Unlike conventional functions, handlers must have a distinct compiler-generated prologue
// (to save all interrupted context registers) and epilogue (using mret instead of ret).
// Alternatively, the "naked" attribute can be used instead of "interrupt", but this approach is
// less safe and requires carefully crafted assembly code.

// Note: compiling with D/F/V extension would also include the extra registers in the context.

void _sw_handler(void)      __attribute__ ((interrupt ("machine")));
void _timer_handler(void)   __attribute__ ((interrupt ("machine")));
void _ext_handler(void)     __attribute__ ((interrupt ("machine")));

#endif