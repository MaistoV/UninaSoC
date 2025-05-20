#ifndef TINYIO_H
#define TINYIO_H

#include "scan.h"
#include "print.h"

/* Supported format specifiers:
 - %d, %i: Signed decimal integer conversion.
 - %u: Unsigned decimal integer conversion.
 - %x, %X: Unsigned hexadecimal integer conversion (lowercase 'x' for lowercase hex digits, 'X' for uppercase).
 - %c: Single character conversion.
 - %s: String conversion.
 - %p: Pointer conversion (printed in hexadecimal format).
 Not all format specifiers are supported, such as %n for writing the number of characters written so far, or floating-point conversions like %f, %e, %E, %g, %G. 
 This function utilizes _putchar, which transmits a single character 'ch' via UART. It waits for the UART transmitter (tx) to become empty before proceeding to write 'ch'. Note: This implementation assumes a polling mechanism where it waits for the transmitter to indicate readiness (tx empty) before transmitting the character.
 */
#define printf c_printf

/*Supported formats: 
- %s (string), 
- %u (unsigned integer),
- %d (signed integer), 
- %c (character).
Other format specifiers are not supported.
The use of `scanf` waits indefinitely for input, causing a block if no data is received. In case of invalid input, an error code is returned. */
#define scanf c_scanf

/* Initializes UART communication at the provided base address.
  Sets up global_uart to point to the UART structure at baseaddr offset by UART_RX_FIFO_REG.Resets UART control registers to clear receive (RX) and transmit (TX) FIFOs */
void tinyIO_init(uint32_t uart_base_addr);

#endif // TINYIO_H

