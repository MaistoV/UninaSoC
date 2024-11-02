// Author: Manuel Maddaluno <manuel.maddaluno@unina.it>
// Description: Virtual uart SoC bare metal application
//              This is a simple Hello World application 
//              The core prints Hello world!!! through the virtual uart peripheral

#include <stdint.h>

#define UART_ADDR           0x00001000
#define TX_EMPTY_BIT_MASK   0x04000000 /* Wrong endianess - it should be 0x00000004 */
#define RX_FULL_BIT_MASK    0x02000000 


void __putchar (uint32_t * uart, char c) 
{
    /* Wait for the TX reg is empty */
    while( (((*(uart+2)) & TX_EMPTY_BIT_MASK) > 24 ) != 1 );  
    /* Put the char */
    *(char *)(uart+1) = c;
}

void printstr (uint32_t * uart, char * str, uint8_t str_len) 
{
    for (uint8_t i = 0; i < str_len; i++) {
        __putchar(uart, str[i]);
    }
}

int main()
{
    uint32_t * uart = (uint32_t *) UART_ADDR;

    printstr(uart, "Hello world!!!", 14);

    while(1);
    return 0;
}
