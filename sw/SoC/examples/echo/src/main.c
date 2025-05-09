#include "tinyIO.h"
#include <stdint.h>

extern const volatile uint32_t _peripheral_UART_start;

int main()
{

  char str[128];

  uninasoc_init();

  while(1){
    printf("Please enter a string\n\r");

    scanf("%s",str);

    printf("Your string is\n\r%s", str);
    printf("\n\r");
  }

  return 0;

}


