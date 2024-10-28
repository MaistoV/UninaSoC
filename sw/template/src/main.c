#include <stdint.h>

int main(){

    /* Insert your code here */
    
    // uint32_t * gpio_addr = (uint32_t *) 0x100000;

    // while(1){
	// for(int i = 0; i < 100000; i++);		
    // 	*gpio_addr = 0xffffffff;
    // 	for(int i = 0; i < 100000; i++);		
    // 	*gpio_addr = 0x00000000;
    // }


    uint32_t * uart = (uint32_t *) 0x00001000;
    char * str = "Hello world!!!";
    uint8_t i = 0;

    while(1){
        if (i<14) {
            while( (*(uart+2)) != 0x04000000);  /* Wrong endianess - it has to be 0x00000004 */
            *(char *)(uart+1) = str[i];
            i++;
        }
    }

    while(1);

    return 0;
}
