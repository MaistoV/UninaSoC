#include "plic.h"

// In this example, only 4 interrupts sources are supported in the SoC

void plic_configure(){

    uint32_t * plic_addr = (uint32_t *) &_peripheral_PLIC_start;

    //Set interrupt priorities
    for (int i = 1; i < SOURCE_NUM; i++) {

        *(plic_addr + (0x4 * i) / sizeof(uint32_t)) = 0x1;

    }

}

void plic_enable(){

    uint32_t * plic_addr = (uint32_t *) &_peripheral_PLIC_start;

    // Enable PLIC interrupts for the first 4 sources
    *(plic_addr + (INT_ENABLE_OFFSET) / sizeof(uint32_t)) = 0xf;

}