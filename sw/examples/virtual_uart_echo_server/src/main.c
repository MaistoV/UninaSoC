// Author: Manuel Maddaluno <manuel.maddaluno@unina.it>
// Description: Virtual uart SoC bare metal application
//              This is a Echo Server application through the virtual uart peripheral

#include <stdint.h>

#define UART_ADDR           0x00001000
#define TX_FULL_BIT_MASK    0x04000000 /* Wrong endianess - it should be 0x00000004 */
#define RX_FULL_BIT_MASK    0x02000000 
 

int main(){
    uint32_t * uart = (uint32_t *) UART_ADDR;
    uint8_t i = 0;
    char c;

    while (1) {
        /* Wait for the char from the host */
        while ( (((*(uart+2)) & RX_FULL_BIT_MASK) > 24) !=  1 );
        c = (*(uart) & 0xFF000000) >> 24;

        /* Write back the char to the host*/
        while( (((*(uart+2)) & TX_FULL_BIT_MASK) > 24 ) != 1 );  
        *(char *)(uart+1) = c;
    }

    while(1);
    return 0;
}
