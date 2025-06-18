#ifdef IS_EMBEDDED // TODO: placeholder to HAL

#include "../inc/io.h"
#include "../inc/xlnx_gpio_in.h"

void xlnx_gpio_out_init()
{
    // Already configured in output as default
}

void xlnx_gpio_out_write(uint16_t val)
{
    write16(GPIO_DATA, val);
}

#endif 
