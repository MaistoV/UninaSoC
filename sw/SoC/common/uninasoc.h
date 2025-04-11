// Author: Vincenzo Maisto <vincenzo.maisto2@unina.it>
// Description: Common header file for basic funcitons

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

static inline uint32_t get_mcounteren() {
  uint32_t mcounteren;
  asm volatile("csrr %0, mcounteren" : "=r"(mcounteren)::"memory");
  return mcounteren;
}

static inline uint32_t get_mcountinhibit() {
  uint32_t mcountinhibit;
  asm volatile("csrr %0, mcountinhibit" : "=r"(mcountinhibit)::"memory");
  return mcountinhibit;
}

static inline void enable_counters() {
  asm volatile("csrw mcountinhibit, 0");
}

// Initialize platform
void uninasoc_init() {

    // TinyIO init
    uint32_t uart_base_address = (uint32_t) &_peripheral_UART_start;
    tinyIO_init(uart_base_address);

    // Enable counters for experiements
    enable_counters();
}

#endif // __UNINASOC_H_