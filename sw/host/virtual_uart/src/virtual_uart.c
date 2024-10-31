// Author: Manuel Maddaluno <manuel.maddaluno@unina.it>
// Description: Virtual Uart host application - virtual uart driver functions

#include <stdint.h>
#include <unistd.h>
#include "virtual_uart.h"


/* Transmit a char through the virtual uart peripheral */
void virtual_uart_tx_char (virtual_uart_t * virtual_uart, char c)
{
    /* Wait for the RX full bit is 0 - the core read the previous char */
    while ( ( (virtual_uart->sts_reg) & RX_FULL_BIT_MASK) >> 1 == 1);
    virtual_uart->rx_reg = (uint32_t) c;
    return;
}

/* Receive a char from the virtual uart peripheral */
char virtual_uart_rx_char (virtual_uart_t * virtual_uart, unsigned int u_poll_period) 
{
    /* Poll on the status flag TX full - waiting for the char */
    uint8_t status_tx_full = (((uint8_t)virtual_uart->sts_reg & TX_FULL_BIT_MASK) >> 3);
    while( !status_tx_full ) {
        usleep(u_poll_period);
        status_tx_full = (((uint8_t)virtual_uart->sts_reg & TX_FULL_BIT_MASK) >> 3);
    }

    /* Read the data in the TX register - get the char */
    return ((char) virtual_uart->tx_reg);
}