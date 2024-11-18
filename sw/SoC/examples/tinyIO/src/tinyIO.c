#include "tinyIO.h"

struct uart_t * global_uart;

void tinyIO_init() {

    if(!global_uart) global_uart = uart_init(UART_BASE_ADDR);

}