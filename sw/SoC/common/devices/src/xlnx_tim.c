// Author: Stefano Mercogliano <stefano.mercogliano@unina.it>
// Author: Valerio Di Domenico <valer.didomenico@studenti.unina.it>
// Author: Salvatore Santoro <sal.santoro@studenti.unina.it>
// Description: 
//  This file implements all the Timer's related functions

#include "xlnx_tim.h"
#include "io.h"
#include <stdint.h>

// TODO47: For now, only timer 0 is used. 
//         These APIs need to be extended to work on TIM0, TIM1 and other instances

void xlnx_tim_configure(uint32_t counter)
{
    iowrite32(TIM0_TLR, counter);
    iowrite32(TIM0_CSR, TIM_CSR_DOWN_COUNTER | TIM_CSR_LOAD | TIM_CSR_AUTO_RELOAD);
}

void xlnx_tim_enable_int()
{
    uint32_t csr_value = ioread32(TIM0_CSR);
    csr_value |= TIM_CSR_ENABLE_INTERRUPT;
    iowrite32(TIM0_CSR, csr_value);
}

void xlnx_tim_clear_int(){
    // Clear timer interrupt by setting TCSR0.T0INT
    uint32_t csr_value = ioread32(TIM0_CSR);
    csr_value |= TIM_CSR_INTERRUPT;
    iowrite32(TIM0_CSR, csr_value);
}

void xlnx_tim_start()
{
    uint32_t csr_value = ioread32(TIM0_CSR);
    // Lower LOAD0 (necessary to start the timer correctly)
    csr_value &= ~TIM_CSR_LOAD;
    csr_value |= TIM_CSR_ENABLE;
    iowrite32(TIM0_CSR, csr_value);
}
