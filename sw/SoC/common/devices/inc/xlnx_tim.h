#ifndef TIM_H
#define TIM_H

#include <stdint.h>

// https://docs.amd.com/v/u/en-US/pg079-axi-timer

// Import linker script symbols
extern const volatile uint32_t _peripheral_TIM0_start;
//extern const volatile uint32_t _peripheral_TIM1_start;

#define TIM0 ((uintptr_t)&_peripheral_TIM0_start)
// #define TIM1 ((uintptr_t)&_peripheral_TIM1_start)

// Bits
#define TIM0_CSR TIM0 + 0x0000 // Control and Status register
#define TIM0_TLR TIM0 + 0x0004 // Load register
#define TIM0_TCR TIM0 + 0x0008 // Counter register

// #define TIM1_CSR TIM1 + 0x0000 // Control and Status register
// #define TIM1_TLR TIM1 + 0x0004 // Load register
// #define TIM1_TCR TIM1 + 0x0008 // Counter register

// Functions

void xlnx_tim_configure(uint32_t counter);

void xlnx_tim_enable_int();

void xlnx_tim_clear_int();

void xlnx_tim_start();

#endif
