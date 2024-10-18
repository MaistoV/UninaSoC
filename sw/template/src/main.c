//#include "../lib/demo_system.h"
//#include "../lib/dev_access.h"
#include <stdint.h>

int main(){

    /* Insert your code here */
    
    uint32_t * gpio_addr = (uint32_t *) 0x100000;

    while(1){
	for(int i = 0; i < 100000; i++);		
    	*gpio_addr = 0xffffffff;
    	for(int i = 0; i < 100000; i++);		
    	*gpio_addr = 0x00000000;
    }
    
    while(1);
    
    return 0;
}
