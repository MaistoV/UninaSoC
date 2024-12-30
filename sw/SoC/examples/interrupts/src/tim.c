
#include "tim.h"

void tim_configure(){

    uint32_t * tim_addr = (uint32_t *)_peripheral_TIM_start;

    // Configure timer prescaler
    *(tim_addr + ( 0x4 )/ sizeof(uint32_t)) = 0x1312D00;  // That is 20000000 to count one second at 20 MHz
    
    // Set the LOAD0 bit to transfer the value to TCR0
    *(tim_addr) = 0x00000020;  // LOAD0 = 1 (bit 5), all others set to 0

    // Lower LOAD0 (necessary to start the timer correctly)
    *(tim_addr) &= ~0x20;  // LOAD0 = 0 (bit 5 lowered)

    // Configure Auto Reload and Down Counter
    *(tim_addr) |= 0x10;  // ARHT0 = 1 (bit 4), Auto Reload enabled
    *(tim_addr) |= 0x02;  // UDT0 = 1 (bit 1), enable down counting
}

void tim_enable_int(){

    uint32_t * tim_addr = (uint32_t *)_peripheral_TIM_start;

    // Enable the interrupt
    *(tim_addr) |= 0x40;   // ENIT0 = 1 (bit 6), interrupt enabled
}

void tim_enable(){

    uint32_t * tim_addr = (uint32_t *)_peripheral_TIM_start;
    
    // Enable the timer
    *(tim_addr) |= 0x80;  // ENT0 = 1 (bit 7), timer enabled    
}