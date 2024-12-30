#include <stdint.h>

#define GPIO_DATA    0x0000  // Data Register
#define GPIO_TRI     0x0004  // Direction Register
#define GIER         0x011C  // Global Interrupt Enable Register
#define IP_IER       0x0128  // Interrupt Enable Register
#define IP_ISR       0x0120  // Interrupt Status Register

int main(){

    /* Insert your code here */

    uint32_t * gpio_out_addr  = (uint32_t *) 0x20000;
    uint32_t * gpio_in_addr   = (uint32_t *) 0x30000;
    uint32_t * rv_plic_addr   = (uint32_t *) 0x4000000;
    uint32_t * tim_addr       = (uint32_t *) 0x40000;
    uint32_t reg_value_plic;
    uint32_t reg_value_gpio;
    uint32_t reg_value_tim;


    //Set interrupt priorities
    for (int i = 1; i < 4; i++) {
        
        *(rv_plic_addr + (0x4 * i) / sizeof(uint32_t)) = 0x1;

    }

    // Enable PLIC interrupts for the first 4 sources
    *(rv_plic_addr + (0x2000) / sizeof(uint32_t)) = 0xf;

    // 1. Configure GPIO as input (1 in GPIO_TRI)
    *(gpio_in_addr + (GPIO_TRI / sizeof(uint32_t))) = (0x1);  // Configure the first pin as input

    // 2. Enable interrupt for the channel (1 in IP_IER)
    *(gpio_in_addr + (IP_IER / sizeof(uint32_t))) = (0x1);  // Enable interrupt on the first pin

    // 3. Enable global interrupts (1 in GIER)
    *(gpio_in_addr + (GIER / sizeof(uint32_t))) = (0x80000000);  // Enable global interrupts by writing 1 to the 32nd bit of the register

    // Step 1:
    *(tim_addr + ( 0x4 )/ sizeof(uint32_t)) = 0x1312D00;  // That is 20000000 to count one second at 20 MHz
    
    // Step 2: Set the LOAD0 bit to transfer the value to TCR0
    *(tim_addr) = 0x00000020;  // LOAD0 = 1 (bit 5), all others set to 0

    // Step 3: Lower LOAD0 (necessary to start the timer correctly)
    *(tim_addr) &= ~0x20;  // LOAD0 = 0 (bit 5 lowered)

    // Step 4: Configure Auto Reload and Down Counter
    *(tim_addr) |= 0x10;  // ARHT0 = 1 (bit 4), Auto Reload enabled
    *(tim_addr) |= 0x02;  // UDT0 = 1 (bit 1), enable down counting

    // Step 5: Enable the interrupt
    *(tim_addr) |= 0x40;   // ENIT0 = 1 (bit 6), interrupt enabled

    // Step 6: Enable the timer
    *(tim_addr) |= 0x80;  // ENT0 = 1 (bit 7), timer enabled    
    
    while(1);

    return 0;
}
