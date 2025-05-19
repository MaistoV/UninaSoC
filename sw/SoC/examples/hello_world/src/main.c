#include "tinyIO.h"
#include <stdint.h>

extern const volatile uint32_t _peripheral_UART_start;

int main()
{

  uint32_t uart_base_address = (uint32_t) &_peripheral_UART_start;

  tinyIO_init(uart_base_address);

  printf("Hello World!\n\r");

  while(1);

  return 0;

}


