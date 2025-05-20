#include "uart.h"
#include <stdint.h>

struct uart_t * global_uart;

void uart_init(uint32_t baseaddr) {

	global_uart = (struct uart_t *) ((intptr_t) baseaddr + UART_RX_FIFO_REG) ;
	global_uart->ctrl_reg = UART_RX_RESET | UART_TX_RESET;	

}

//Check if the receiver is empty
__attribute__((always_inline)) inline uint8_t uart_is_rx_empty() {
	return (global_uart->state_reg & UART_RX_FIFO_NOT_EMPTY) ? 0 : 1;
}

// Check if the transmitter is empty
__attribute__((always_inline)) inline uint8_t uart_is_tx_empty() {
	return (global_uart->state_reg & UART_TX_EMPTY) ? 1 : 0;
}


// Send a single character to the UART
void uart_send_char(uint8_t ch) {
    
    while (!uart_is_tx_empty(global_uart)) {
        // If the transmitter is not empty, wait until it becomes empty
    }

    // Write the character to the transmitter
    global_uart->tx = ch;
    
    
}
// Waits until a character is received on UART (RX) and returns it.
uint32_t uart_get_char(){

    while(uart_is_rx_empty(global_uart)){
        // Wait until data is available in the RX buffer
    }
    return global_uart->rx;
    
}

