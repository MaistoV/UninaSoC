#include <stdint.h>

int main(){

    uint32_t * gpio_addr = (uint32_t *) 0x100000;

    while(1){
	    for(int i = 0; i < 100000; i++);
    	*gpio_addr = 0x00000001;
    	for(int i = 0; i < 100000; i++);
    	*gpio_addr = 0x00000000;
    }

    while(1);

    return 0;
}
