#ifndef PLIC_H
#define PLIC_H

#include <cstdint>
#include <stddef.h>
#include <stdint.h>

// Import linker script symbol
extern const volatile uint32_t _peripheral_PLIC_start;

#define PLIC ((uintptr_t)&_peripheral_PLIC_start)

#define PLIC_INT_ENABLE_CTX0 PLIC+0x2000


// Functions
// pass a pointer of "source_num" elems, specifying the corresponding priorities
void plic_configure(uint32_t* priorities, size_t source_num);

void plic_enable_all();

#endif
