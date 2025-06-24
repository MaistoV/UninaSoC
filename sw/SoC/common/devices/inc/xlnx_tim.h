// Author: Stefano Mercogliano <stefano.mercogliano@unina.it>
// Author: Valerio Di Domenico <valer.didomenico@studenti.unina.it>
// Author: Salvatore Santoro <sal.santoro@studenti.unina.it>
// Description: 
//  This file defines the API to adoperate the Timer

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

//Configure the timer counter, given that the timer is working at 20 MHz
//to count a second you should use 0x1312D00 (the timer is counting down)
//the timer automatically restarts everytime ciclically
void xlnx_tim_configure(uint32_t counter);

//Enables the timer interrupts
void xlnx_tim_enable_int();

//Clears the timer interrupt signal, this function is supposed to be used
//to assert the completition of the timer interrupt handling
void xlnx_tim_clear_int();

//This function starts the timer
void xlnx_tim_start();

#endif
