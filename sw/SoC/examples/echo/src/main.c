#include "tinyIO.h"
#include <stdint.h>

extern const volatile uint32_t _peripheral_UART_start;

int main()
{ 

  uint32_t uart_base_address = _peripheral_UART_start;
  char c;

  tinyIO_init(uart_base_address);

  while(1){
    scanf("%c",&c);
    printf("%c", c);
  }

  return 0;

}


