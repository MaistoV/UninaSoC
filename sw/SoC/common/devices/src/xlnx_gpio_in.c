// Author: Stefano Mercogliano <stefano.mercogliano@unina.it>
// Author: Valerio Di Domenico <valer.didomenico@studenti.unina.it>
// Author: Salvatore Santoro <sal.santoro@studenti.unina.it>
// Description: 
//  This file implements all the Input GPIO's related functions

#ifdef GPIO_IN_IS_ENABLED

#include "io.h"
#include "xlnx_gpio_in.h"
#include <stdint.h>

void xlnx_gpio_in_init(interrupt_conf_t ic)
{
    // Already configured in input as default

    if (ic == ENABLE_INT) {
        // Enable interrupt for the channel (1 in IP_IER)
        iowrite32(GPIO_IN_IER, 0x01);
        // Enable global interrupts (1 in GIER)
        iowrite32(GPIO_IN_GIER, 0x80000000);
    }
}

uint16_t xlnx_gpio_in_read(){
    return ioread16(GPIO_IN_DATA);
}

void xlnx_gpio_in_clear_int(){
    // Acknowledge GPIO interrupt has been handled.
    iowrite32(GPIO_IN_ISR, 0x1);
}

#endif
