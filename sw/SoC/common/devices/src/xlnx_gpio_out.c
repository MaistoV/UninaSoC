#ifdef IS_EMBEDDED // TODO: placeholder to HAL

#include "io.h"
#include "xlnx_gpio_out.h"

void xlnx_gpio_out_init()
{
    // Already configured in output as default
}

void xlnx_gpio_out_write(uint16_t val)
{
    write16(GPIO_DATA, val);
}

#endif
