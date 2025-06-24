// Author: Stefano Mercogliano <stefano.mercogliano@unina.it>
// Author: Valerio Di Domenico <valer.didomenico@studenti.unina.it>
// Author: Salvatore Santoro <sal.santoro@studenti.unina.it>
// Description: 
//  This file implements all the Output GPIO's related functions

#ifdef GPIO_OUT_IS_ENABLED

#include "io.h"
#include "xlnx_gpio_out.h"
#include <stdint.h>

void xlnx_gpio_out_init()
{
    // Already configured in output as default
}

void xlnx_gpio_out_write(uint16_t val)
{
    iowrite16(GPIO_DATA, val);
}

uint16_t xlnx_gpio_out_read()
{
    return ioread16(GPIO_DATA);
}

int xlnx_gpio_out_toggle(pin_t pin){
    if ((pin <= 0) || (pin > 0xFFFF))
        return -1;
    uint16_t data = xlnx_gpio_out_read();
    data ^= pin;
    xlnx_gpio_out_write(data);
    return 0;
}

#endif
