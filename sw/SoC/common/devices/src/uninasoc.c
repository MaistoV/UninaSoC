#include "uninasoc.h"
#include "tinyIO.h"


void uninasoc_init() {

    // TinyIO init
    uint32_t uart_base_address = (uint32_t) &_peripheral_UART_start;
    tinyIO_init(uart_base_address);

    // Enable counters for experiements
    enable_counters();
}
