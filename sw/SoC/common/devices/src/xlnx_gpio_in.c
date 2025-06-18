#ifdef IS_EMBEDDED // TODO: placeholder to HAL

#include "../inc/io.h"
#include "../inc/xlnx_gpio_in.h"
#include <stdint.h>

void xlnx_gpio_in_init(interrupt_conf_t ic)
{
    // Already configured in input as default

    if (ic == ENABLE_INT) {
        // Enable interrupt for the channel (1 in IP_IER)
        write32(IP_IER, 0x01);
        // Enable global interrupts (1 in GIER)
        write32(IP_IER, 0x80000000);
    }
}

uint16_t xlnx_gpio_in_read(){
    return read16(GPIO_DATA);
}

#endif // IS_EMBEDDED
