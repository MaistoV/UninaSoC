#include "../inc/xlnx_tim.h"
#include <stdint.h>

// CASCADE
#define ENABLE_CASCADE (1 << 11)
#define TIMER_ENABLE (1 << 7)
#define TIMER_DISABLE (~(1 << 7))

// 0-not initialized
// 1-32 bit timers
// 2-64 bit timer
static int timer_init = 0;

void tim_init(int init)
{
    timer_init = init;
}

// FOR LOAD: 0x1312D00; That is 20000000 to count one second at 20 MHz

int tim_configure(TIM_Peripheral* tim, TIM_Config* config)
{
    TIM32* timer32 = (TIM32*)tim;
    TIM64* timer64 = (TIM64*)tim;

    if (timer_init == 0)
        return UNINITIALIZED_TIMER;
    // can't use pwm if timer is in 32 bit
    if ((config->mask_tcsr & ENABLE_PWM) && (timer_init != TIM64B))
        return WRONG_MODE;

    // set configs for 64 bit
    if (timer_init == TIM64B) {
        timer64->tim1.tlr = (uint32_t)(config->load_value >> 32);
        if ((config->mask_tcsr & ENABLE_PWM)) {
            timer64->tim0.tcsr |= ENABLE_GENERATE_SIG;
            timer64->tim1.tcsr |= ENABLE_GENERATE_SIG;
        }
        // if not using PWM then just set cascade
        else {
            config->set_tcsr |= ENABLE_CASCADE;
        }
    }

    timer32->tlr = (uint32_t)config->load_value;
    // reset bits
    timer32->tcsr &= config->mask_tcsr;
    // set bits
    timer32->tcsr |= config->set_tcsr;

    return CONFIG_OK;
}

void tim_enable_int()
{

    uint32_t* tim_addr = (uint32_t*)&_peripheral_TIM0_start;

    // Enable the interrupt
    *(tim_addr) |= 0x40; // ENIT0 = 1 (bit 6), interrupt enabled
}

void tim_enable(TIM_Peripheral* tim)
{
    TIM32* timer = (TIM32*)tim;
    // turn off load bit
    timer->tcsr &= LOAD_TIMER;
    // enable timer
    timer->tcsr |= TIMER_ENABLE;
}

void tim_disable(TIM_Peripheral* tim)
{
    TIM32* timer = (TIM32*)tim;
    timer->tcsr &= TIMER_DISABLE;
}

void tim_handler()
{

    uint32_t* tim_addr = (uint32_t*)&_peripheral_TIM0_start;

    // Print
    printf("\n\r******* Timer Interrupt! *******\n\r\n\r");

    // Clear timer interrupt by setting TCSR0.T0INT
    *tim_addr = 0x100;

    // Restart the timer
    *tim_addr = 0xD2;
}
