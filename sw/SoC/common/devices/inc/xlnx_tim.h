#ifndef TIM_H
#define TIM_H

#include <stdint.h>

// https://docs.amd.com/v/u/en-US/pg079-axi-timer

// Import linker script symbols
extern const volatile uint32_t _peripheral_TIM0_start;
extern const volatile uint32_t _peripheral_TIM1_start;

typedef struct {
    uint32_t tcsr;
    uint32_t tlr;
    uint32_t tcr;
} TIM32;

typedef struct {
    TIM32 tim0;
    uint32_t rsvd0; // reserved
    TIM32 tim1;
    uint32_t rsvd1; // reserved
} TIM64;

// Modes
#define GENERATE_MODE (~(1 << 0))
#define CAPTURE_MODE (1 << 0)

// UDT
#define UP_CT (~(1 << 1))
#define DOWN_CT (1 << 1)

// GENERATE SIGNAL
#define DISABLE_GENERATE_SIG (~(1 << 2))
#define ENABLE_GENERATE_SIG (1 << 2)

// CAPTURE TRIGGER
#define DISABLE_CAPTURE_TRG (~(1 << 3))
#define ENABLE_CAPTURE_TRG (1 << 3)

// Auto Reload / Hold Timer
#define HOLD (~(1 << 4))
#define RELOAD (1 << 4)

// interrupts
#define DISABLE_INT (~(1 << 6))
#define ENABLE_INT (1 << 6)

// load
#define NO_LOAD_TIMER (~(1 << 5))
#define LOAD_TIMER (1 << 5)

// PWM
#define DISABLE_PWM (~(1 << 9))
#define ENABLE_PWM (1 << 9)

// errors
enum {
    CONFIG_OK = 0,
    UNINITIALIZED_TIMER,
    WRONG_MODE
};

typedef struct {
    // only first 32 bits are used for 32bits timers
    uint64_t load_value;
    uint32_t set_tcsr; // bits to set
    uint32_t mask_tcsr; // bits to reset
} TIM_Config;

#define TIM0_32b ((TIM32*)&_peripheral_TIM0_start)
#define TIM1_32b ((TIM32*)&_peripheral_TIM1_start)
#define TIM_64b ((TIM64*)&_peripheral_TIM0_start)

typedef void TIM_Peripheral;

// Timer initialization flags
enum {
    TIM32B = 1,
    TIM64B // CASCADING THE TIMERS
};

// Functions
// Setting the mode defines how to use the timers (2 timers of 32bits or 1 timer of 64bits)
void tim_init(int);

// returns error if tim_init wasn't called
int tim_configure(TIM_Peripheral* tim, TIM_Config* config);

void tim_enable_int();
void tim_enable(TIM_Peripheral* tim);

void tim_handler();

#endif
