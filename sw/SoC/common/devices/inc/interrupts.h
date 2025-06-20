#ifndef INTERRUPTS_H
#define INTERRUPTS_H

#include <stdint.h>

// Handlers
// Unlike conventional functions, handlers must have a distinct compiler-generated prologue
// (to save all interrupted context registers) and epilogue (using mret instead of ret).
// Alternatively, the "naked" attribute can be used instead of "interrupt", but this approach is
// less safe and requires carefully crafted assembly code.

// Note: compiling with D/F/V extension would also include the extra registers in the context.

// Should make sure to not relocate the code far away from the vector_table "jump instruction" (see startup.s)
// __attribute__((section(".text")) in this case is just a placeholder to signal this eventual problem
// the "__handler__" symbol must be used to redefine the handler correctly inside the specific example
// (see interrupts example)

#define __handler__ __attribute__((interrupt("machine"))) __attribute__((section(".text")))

__attribute__((weak)) void _sw_handler(void) __handler__;
__attribute__((weak)) void _timer_handler(void) __handler__;
__attribute__((weak)) void _ext_handler(void) __handler__;

#endif
