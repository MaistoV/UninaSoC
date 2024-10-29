// Author: Manuel Maddaluno <manuel.maddaluno@unina.it>
// Description: Virtual uart SoC bare metal application
//              This code sends "Hello world!!!" to the host char by char through the virtual uart peripheral

#include <stdint.h>

#define UART_ADDR           0x00001000
#define TX_FULL_BIT_MASK    0x04000000 /* Wrong endianess - it should be 0x00000004 */

int main(){
    uint32_t * uart = (uint32_t *) UART_ADDR;
    char * str = "Hello world!!!";
    uint8_t i = 0;

    while(1){
        if (i<14) {
            while( (*(uart+2)) != TX_FULL_BIT_MASK);  
            *(char *)(uart+1) = str[i];
            i++;
        }
    }

    while(1);

    return 0;
}
