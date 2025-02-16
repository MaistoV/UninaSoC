#include "tinyIO.h"
#include <stdint.h>

extern const volatile uint32_t _peripheral_UART_start;

int main()
{ 

  uint32_t uart_base_address = (uint32_t) &_peripheral_UART_start;
  char str[128];

  tinyIO_init(uart_base_address);


  while(1){
    printf("Please enter a string\n\r");

    scanf("%s",str);

    printf("Your string is\n\r%s", str);
    printf("\n\r");
  }

  return 0;

}


