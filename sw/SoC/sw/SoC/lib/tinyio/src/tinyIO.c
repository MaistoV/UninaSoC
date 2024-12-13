#include "tinyIO.h"

//struct uart_t * global_uart;

void tinyIO_init(uint32_t uart_base_addr) {

    uart_init(uart_base_addr);

}