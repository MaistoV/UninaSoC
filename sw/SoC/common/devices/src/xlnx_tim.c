#include "../inc/xlnx_tim.h"
#include "../inc/io.h"
#include <stdint.h>

#define TIM_DOWN_COUNTER (1 << 1)
#define TIM_AUTO_RELOAD (1 << 4)
#define TIM_LOAD (1 << 5)
#define TIM_ENABLE_INTERRUPT (1 << 6)
#define TIM_ENABLE (1 << 7)

// FOR LOAD: 0x1312D00; That is 20000000 to count one second at 20 MHz
void xlnx_tim_configure(uint32_t counter)
{
    write32(TIM0_TLR, counter);
    write32(TIM0_CSR, TIM_DOWN_COUNTER | TIM_LOAD | TIM_AUTO_RELOAD);
}

void xlnx_tim_enable_int()
{
    uint32_t csr_value = read32(TIM0_CSR);
    csr_value |= TIM_ENABLE_INTERRUPT;
    write32(TIM0_CSR, csr_value);
}

void xlnx_tim_start()
{
    uint32_t csr_value = read32(TIM0_CSR);
    // Lower LOAD0 (necessary to start the timer correctly)
    csr_value &= ~TIM_LOAD;
    csr_value |= TIM_ENABLE;
    write32(TIM0_CSR, csr_value);
}
