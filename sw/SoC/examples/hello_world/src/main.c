// Description: Basic hello world application on platform

// #include "uninasoc.h"
#include "tinyIO.h"
#include <stdint.h>

extern const volatile uint32_t _peripheral_UART_start;

// Get cycle count since reset
static inline uint32_t get_mcycle() {
  uint32_t mcycle;
  asm volatile("csrr %0, cycle" : "=r"(mcycle)::"memory");
  // asm volatile("rdcycle %0" : "=r"(mcycle)::"memory");
  // asm volatile("fence; csrr %[mcycle], cycle" : [mcycle] "=r"(mcycle));
  // asm volatile("csrr %[mcycle], time" : [mcycle] "=r"(mcycle));

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


int main()
{

  // Init platform
  // uninasoc_init();

  uint32_t uart_base_address = (uint32_t) &_peripheral_UART_start;
  tinyIO_init(uart_base_address);

  // Enable counters for experiements
  // asm volatile("csrw mcountinhibit, 0");
  // asm volatile("csrw mcounteren, 0xf");

  printf("mcountinhibit = 0x%08x\n\r", get_mcountinhibit());
  printf("mcounteren = 0x%08x\n\r", get_mcounteren());

  // Print
  printf("---------------------------------------------\n\r");
  uint32_t mcycle;

  asm volatile("csrr %0, cycle" : "=r"(mcycle)::"memory");
  printf("mcycle = 0x%08x\n\r", mcycle);
  asm volatile("csrr %0, cycle" : "=r"(mcycle)::"memory");
  printf("mcycle = 0x%08x\n\r", mcycle);
  mcycle = get_mcycle();
  printf("mcycle = 0x%08x\n\r", mcycle);
  mcycle = get_mcycle();
  printf("mcycle = 0x%08x\n\r", mcycle);

  // Return
  return 0;

}
