// Author: Manuel Maddaluno <manuel.maddaluno@unina.it>
// Description: Virtual uart SoC bare metal application
//              This is a Echo Server application through the virtual uart peripheral
//              The server waits for a string from the user and reply with the same string

#include <stdint.h>

#define UART_ADDR           0x00001000
#define TX_EMPTY_BIT_MASK   0x04000000 /* Wrong endianess - it should be 0x00000004 */
#define RX_FULL_BIT_MASK    0x02000000 
#define MAX_STR_LEN         32


char __getchar (uint32_t * uart)
{
    /* Wait for the char - RX is full */
    while ( (((*(uart+2)) & RX_FULL_BIT_MASK) > 24) !=  1 );
    /* Get the char */
    return (*(uart) & 0xFF000000) >> 24;
}


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

uint8_t scanstr (uint32_t * uart, char * str, uint8_t max_len)
{
    char c;
    uint8_t i = 0;

    /* Get the char from the host - blocking function */
    c = __getchar(uart);

    while ( (c != '\n') && (i < MAX_STR_LEN) ) {
        /* Add the char to the string  */
        str[i++] = c;
        /* Get the char from the host - blocking function */
        c = __getchar(uart);
    }
    /* return the str_len */
    return i;
}

int main()
{
    uint32_t * uart = (uint32_t *) UART_ADDR;
    uint8_t str_len = 0;
    char str[MAX_STR_LEN];

    while (1) {
        printstr(uart, "Please enter a string: ", 23);

        /* save the string and the length */
        str_len = scanstr(uart, str, MAX_STR_LEN);

        printstr(uart, "This is your string: ", 21);

        /* reply to the host with the saved string */
        printstr(uart, str, str_len);
    }

    while(1);
    return 0;
}
