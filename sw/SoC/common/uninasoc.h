// Author: Vincenzo Maisto <vincenzo.maisto2@unina.it>
// Description: Common header file for basic functions.

#ifndef __UNINASOC_H_
#define __UNINASOC_H_

// System libraries
#include <stdint.h>

// TinyIO header
#include "tinyIO.h"

void uninasoc_init();

// Uart physical address
extern const volatile uint32_t _peripheral_UART_start;

// Get cycle count since reset
static inline uint32_t get_mcycle() {
  uint32_t mcycle;
  asm volatile("csrr %0, mcycle" : "=r"(mcycle)::"memory");
  return mcycle;
}

// Initialize platform
void uninasoc_init() {

    // TinyIO init
    uint32_t uart_base_address = (uint32_t) &_peripheral_UART_start;
    tinyIO_init(uart_base_address);

    // Enable counters for experiements
    asm volatile("csrw mcountinhibit, 0");
}

#endif // __UNINASOC_H_
