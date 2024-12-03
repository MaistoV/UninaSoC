#include "tinyIO.h"
#include <stdint.h>

int main()
{ 

  uint32_t uart_base_address = 0x10000;
  char c;

  tinyIO_init(uart_base_address);

  while(1){
    scanf("%c",&c);
    printf("%c", c);
  }

  return 0;

}


