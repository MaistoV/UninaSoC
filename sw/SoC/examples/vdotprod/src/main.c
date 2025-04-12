#include "xil_io.h"
#include "tinyIO.h"
#include <stdbool.h>
#include "xkrnl_vdotprod_hw.h"

extern const volatile uint32_t _peripheral_UART_start;
extern const volatile uint32_t _peripheral_HLS_VDOTPROD_CONTROL_start;

#define Xkrnl_BASE                  ((unsigned int)(&_peripheral_HLS_VDOTPROD_CONTROL_start))
#define Xkrnl_Control               (Xkrnl_BASE + XKRNL_VDOTPROD_CONTROL_ADDR_AP_CTRL)
#define Xkrnl_GIE                   (Xkrnl_BASE + XKRNL_VDOTPROD_CONTROL_ADDR_GIE)
#define Xkrnl_IER                   (Xkrnl_BASE + XKRNL_VDOTPROD_CONTROL_ADDR_IER)
#define Xkrnl_ISR                   (Xkrnl_BASE + XKRNL_VDOTPROD_CONTROL_ADDR_ISR)
#define Xkrnl_RETURN                (Xkrnl_BASE + XKRNL_VDOTPROD_CONTROL_ADDR_AP_RETURN)

#define AP_START                    (0x00000001)
#define AP_DONE                     (0x00000002)
#define AP_IDLE                     (0x00000004)
#define AP_READY                    (0x00000008)
#define AP_CONTINUE                 (0x00000010)
#define AP_INTERRUPT                (0x00000020)

#define DATA_SIZE 32
#define DATA 1
#define EXPCTD DATA_SIZE

// Starts kernel execution
void start_kernel() {

    // Raising ap_start to start the kernel
    Xil_Out32(Xkrnl_Control, AP_START);

}

// // Checks the idle status of the kernel
// bool is_kernel_idle() {
//     return ( (Xil_In32(Xkrnl_Control) && AP_IDLE) == AP_IDLE );
// }

// // Checks the ready status of the kernel
// bool is_kernel_ready() {
//     return ( (Xil_In32(Xkrnl_Control) && AP_READY) == AP_READY );
// }

bool check_results() {

    return (Xil_In32(Xkrnl_RETURN) == EXPCTD);
}

int main() {

    // Starting the kernel
    uint32_t uart_base_address = (uint32_t) &_peripheral_UART_start;
    tinyIO_init(uart_base_address);

    start_kernel();

    // Waiting for the kernel to finish (polling the ap_done control bit)
    while ( (Xil_In32(Xkrnl_Control) && AP_DONE) != AP_DONE ) {}

    // Checking results
    if (check_results())
        printf("The result is: %d\n", Xil_In32(Xkrnl_RETURN));
    else printf("ERROR! Not expected result\n");
    
    while(1);

    return 0;

}
