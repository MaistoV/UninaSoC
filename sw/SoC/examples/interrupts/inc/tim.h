#ifndef TIM_H
#define TIM_H

#include <stdint.h>

// Import linker script symbol
extern const volatile uint32_t _peripheral_TIM0_start;

// Functions
void tim_configure();
void tim_enable_int();
void tim_enable();

void tim_handler();


#endif