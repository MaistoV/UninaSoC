#include "tinyIO.h"
#include <stdint.h>

int main()
{ 

  uint32_t uart_base_address = 0x10000;

  tinyIO_init(uart_base_address);

  printf("Hello World!\n");

  while(1);

  return 0;

}


