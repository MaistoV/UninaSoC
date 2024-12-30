#ifndef TIM_H
#define TIM_H

#include <stdint.h>

// Import linker script symbol
extern const volatile uint32_t _peripheral_TIM_start;

// Functions
void tim_configure();
void tim_enable_int();
void tim_enable();


#endif 