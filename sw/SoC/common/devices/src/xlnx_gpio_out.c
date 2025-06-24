// Author: Stefano Mercogliano <stefano.mercogliano@unina.it>
// Author: Valerio Di Domenico <valer.didomenico@studenti.unina.it>
// Author: Salvatore Santoro <sal.santoro@studenti.unina.it>
// Description:
//  This file implements all the Output GPIO's related functions



#include "uninasoc.h"

#ifdef GPIO_OUT_IS_ENABLED
#include "io.h"
#include <stdint.h>

// Extend this function implementation in case you add more peripherals
#ifdef UNINASOC_DEBUG
static inline void assert_gpio_out(xlnx_gpio_out_t* gpio)
{
    if ((gpio->base_addr != GPIO_OUT_BASEADDR)) {
        // make the system halt (assuming tinyIO is already initialized)
        printf("WRONG GPIO OUT BASE ADDRESS, HALTING THE SYSTEM!\r\n");
        while (1) {
            asm volatile("nop");
        }
    }
}
#else
static inline void assert_gpio_out(xlnx_gpio_out_t* gpio)
{
    // no-op when not debugging
}
#endif

// Registers
#define GPIO_DATA 0x0000 // Data Register
#define GPIO_TRI 0x0004 // Direction Register
#define GPIO2_DATA 0x0008 // Data register second channel
#define GPIO2_TRI 0x000C // Data register second channel
#define GIER 0x011C // Global Interrupt Enable Register
#define IP_ISR 0x0120 // Interrupt Status Register
#define IP_IER 0x0128 // Interrupt Enable Register

void xlnx_gpio_out_init(xlnx_gpio_out_t* gpio)
{
    // Already configured in output as default
    assert_gpio_out(gpio);
}

void xlnx_gpio_out_write(xlnx_gpio_out_t* gpio, pin_t val)
{
    assert_gpio_out(gpio);
    uintptr_t gpio_data = (uintptr_t) (gpio->base_addr + GPIO_DATA);
    iowrite16(gpio_data, val);
}

uint16_t xlnx_gpio_out_read(xlnx_gpio_out_t* gpio)
{
    assert_gpio_out(gpio);
    uintptr_t gpio_data = (uintptr_t) (gpio->base_addr + GPIO_DATA);
    return ioread16(gpio_data);
}

int xlnx_gpio_out_toggle(xlnx_gpio_out_t* gpio, pin_t pin)
{
    assert_gpio_out(gpio);

    if ((pin <= 0) || (pin > 0xFFFF))
        return -1;

    uint16_t data = xlnx_gpio_out_read(gpio);
    data ^= pin;
    xlnx_gpio_out_write(gpio, data);
    return 0;
}

#endif
