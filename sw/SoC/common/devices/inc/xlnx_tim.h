#ifndef TIM_H
#define TIM_H

#include <stdint.h>

// https://docs.amd.com/v/u/en-US/pg079-axi-timer

// Import linker script symbols
extern const volatile uint32_t _peripheral_TIM0_start;
//extern const volatile uint32_t _peripheral_TIM1_start;

// Base address
#define TIM0_BASEADDR ((uintptr_t)&_peripheral_TIM0_start)
// #define TIM1_BASEADDR ((uintptr_t)&_peripheral_TIM1_start)

// Registers
#define TIM0_CSR (TIM0_BASEADDR + 0x0000) // Control and Status register
#define TIM0_TLR (TIM0_BASEADDR + 0x0004) // Load register
#define TIM0_TCR (TIM0_BASEADDR + 0x0008) // Counter register

// #define TIM1_CSR (TIM1_BASEADDR + 0x0000) // Control and Status register
// #define TIM1_TLR (TIM1_BASEADDR + 0x0004) // Load register
// #define TIM1_TCR (TIM1_BASEADDR + 0x0008) // Counter register

// Modes
#define TIM_CSR_DOWN_COUNTER (1 << 1)
#define TIM_CSR_AUTO_RELOAD (1 << 4)
#define TIM_CSR_LOAD (1 << 5)
#define TIM_CSR_ENABLE_INTERRUPT (1 << 6)
#define TIM_CSR_ENABLE (1 << 7)
#define TIM_CSR_INTERRUPT (1 << 8)

// Functions

void xlnx_tim_configure(uint32_t counter);

void xlnx_tim_enable_int();

void xlnx_tim_clear_int();

void xlnx_tim_start();

#endif
