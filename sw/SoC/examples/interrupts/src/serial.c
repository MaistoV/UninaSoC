#include "serial.h"

void serial_init(){

    uint32_t* uart_base_address = (uint32_t*) &_peripheral_UART_start;

    tinyIO_init((uint32_t) uart_base_address);
}