
// Description: Virtual uart host driver functions header file

#ifndef VIRTUAL_UART_H__
#define VIRTUAL_UART_H__

/* Masks */
#define RX_FULL_BIT_MASK 0x00000002
#define TX_FULL_BIT_MASK 0b00001000

/* Virtual Uart struct */
typedef volatile struct {
    uint32_t rx_reg;            /* RX register - host to core   */
    uint32_t tx_reg;            /* TX register - core to host   */
    uint32_t sts_reg;           /* Status register              */
    uint32_t ctrl_reg;          /* Control register             */
    uint32_t int_ack_reg;       /* Interrupt ack - host to XDMA */
} virtual_uart_t;


void virtual_uart_tx_char (virtual_uart_t * virtual_uart, char c);
char virtual_uart_rx_char (virtual_uart_t * virtual_uart, unsigned int u_poll_period);
void virtual_uart_init (virtual_uart_t * virtual_uart);

#endif