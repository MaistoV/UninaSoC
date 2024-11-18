#include "tinyIO.h"
#include <stdint.h>

/*
 - Main function to test printf and scanf functionalities along with UART initialization.
 - Initializes UART communication with a specified base address.
 - Sends initial messages over UART.
 - Demonstrates usage of printf for printing integers, unsigned integers, and floats.
 - Uses scanf to read a string, a character, and an unsigned integer from user input.
 */

int main()
{ 

  //struct uart_t * uart;

  /*char c;
  uart = uart_init(UART_BASE_ADDR);

  while(1){
    c = uart_get_char(uart);
    uart_send_char(uart, c);
  }*/

  tinyIO_init();
  printf("Hello World!\n");
  /*uart_send_char(uart, 'H');
  uart_send_char(uart, 'e');
  uart_send_char(uart, 'l');
  uart_send_char(uart, 'l');
  uart_send_char(uart, 'o');
  uart_send_char(uart, ' ');
  uart_send_char(uart, 'W');
  uart_send_char(uart, 'o');
  uart_send_char(uart, 'r');
  uart_send_char(uart, 'l');
  uart_send_char(uart, 'd');
  uart_send_char(uart, '!');
  uart_send_char(uart, '\n');*/



  while(1);

  return 0;

}


