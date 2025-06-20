#include "xlnx_tim.h"
#include "io.h"
#include <stdint.h>

#define TIM_DOWN_COUNTER (1 << 1)
#define TIM_AUTO_RELOAD (1 << 4)
#define TIM_LOAD (1 << 5)
#define TIM_ENABLE_INTERRUPT (1 << 6)
#define TIM_ENABLE (1 << 7)
#define TIM_INTERRUPT (1 << 8)

// FOR LOAD: 0x1312D00; That is 20000000 to count one second at 20 MHz
void xlnx_tim_configure(uint32_t counter)
{
    iowrite32(TIM0_TLR, counter);
    iowrite32(TIM0_CSR, TIM_DOWN_COUNTER | TIM_LOAD | TIM_AUTO_RELOAD);
}

void xlnx_tim_enable_int()
{
    uint32_t csr_value = ioread32(TIM0_CSR);
    csr_value |= TIM_ENABLE_INTERRUPT;
    iowrite32(TIM0_CSR, csr_value);
}

void xlnx_tim_clear_int(){
    // Clear timer interrupt by setting TCSR0.T0INT
    uint32_t csr_value = ioread32(TIM0_CSR);
    csr_value |= TIM_INTERRUPT;
    iowrite32(TIM0_CSR, csr_value);
}

void xlnx_tim_start()
{
    uint32_t csr_value = ioread32(TIM0_CSR);
    // Lower LOAD0 (necessary to start the timer correctly)
    csr_value &= ~TIM_LOAD;
    csr_value |= TIM_ENABLE;
    iowrite32(TIM0_CSR, csr_value);
}
