#include <stdint.h>

extern const volatile uint32_t _peripheral_GPIO_out_start;

int main(){

    uint32_t * gpio_addr = (uint32_t *) &_peripheral_GPIO_out_start;

    while(1){
        for(int i = 0; i < 100000; i++);
        *gpio_addr = 0xffffffff;
        for(int i = 0; i < 100000; i++);
        *gpio_addr = 0x00000000;
    }

    while(1);

    return 0;
}
