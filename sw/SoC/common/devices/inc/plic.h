#ifndef PLIC_H
#define PLIC_H

#include <stddef.h>
#include <stdint.h>

// Import linker script symbol
extern const volatile uint32_t _peripheral_PLIC_start;

// Base address
#define PLIC_BASEADDR ((uintptr_t)&_peripheral_PLIC_start)

// Registers
#define PLIC_INT_ENABLE_CTX0    (PLIC_BASEADDR +   0x2000)
#define PLIC_CLAIM_CTX0         (PLIC_BASEADDR + 0x200004)
#define PLIC_COMPLETE_CTX0      (PLIC_BASEADDR + 0x200004)

// Functions
// pass a pointer of "source_num" elems, specifying the corresponding priorities
void plic_configure(uint32_t* priorities, size_t source_num);

void plic_enable_all();

uint32_t plic_claim();

void plic_complete(uint32_t interrupt_id);

#endif
