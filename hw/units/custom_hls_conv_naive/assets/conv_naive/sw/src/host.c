#include "xil_io.h"
#include <stdbool.h>
#include "xkrnl_matmul_hw.h"

#define Xkrnl_BASE                  __peripheral_HLS_Accelerator_Control_start
#define Xkrnl_Control               (Xkrnl_BASE + XKRNL_MATMUL_CONTROL_ADDR_AP_CTRL)
#define Xkrnl_GIE                   (Xkrnl_BASE + XKRNL_MATMUL_CONTROL_ADDR_GIE)
#define Xkrnl_IER                   (Xkrnl_BASE + XKRNL_MATMUL_CONTROL_ADDR_IER)
#define Xkrnl_ISR                   (Xkrnl_BASE + XKRNL_MATMUL_CONTROL_ADDR_ISR)
#define Xkrnl_A_ADDR                (Xkrnl_BASE + XKRNL_MATMUL_CONTROL_ADDR_AXI_MM_DATA)

#define AP_START                    (0x00000001)
#define AP_DONE                     (0x00000002)
#define AP_IDLE                     (0x00000004)
#define AP_READY                    (0x00000008)
#define AP_CONTINUE                 (0x00000010)
#define AP_INTERRUPT                (0x00000020)

#define DATA_SIZE 32
#define EXPCTD DATA_SIZE

#define OFFSET_A 0
#define OFFSET_B DATA_SIZE*DATA_SIZE
#define OFFSET_C 2*DATA_SIZE*DATA_SIZE

#define SIZE_MM 3*DATA_SIZE*DATA_SIZE

void initialize_data(uint32_t axi_mm[SIZE_MM]) {

    for (int i = 0; i < DATA_SIZE; i++) {

        for (int j=0; j<DATA_SIZE; j++) {

            axi_mm[OFFSET_A + (i*DATA_SIZE + j)] = 1;
            axi_mm[OFFSET_B + (i*DATA_SIZE + j)] = 1;
            axi_mm[OFFSET_C + (i*DATA_SIZE + j)] = 0;
        
        }

    }

}

// Starts kernel execution
void start_kernel(uint32_t axi_mm[SIZE_MM]) {

    // Writing input/output addresses
    Xil_Out64(Xkrnl_A_ADDR, (uint64_t)axi_mm);

    // Raising ap_start to start the kernel
    Xil_Out32(Xkrnl_Control, AP_START);

    // Waiting for the kernel to finish (polling the ap_done control bit)
    while ( (Xil_In32(Xkrnl_Control) && AP_DONE) != AP_DONE ) {}
}

// Checks the idle status of the kernel
bool is_kernel_idle() {
    return ( (Xil_In32(Xkrnl_Control) && AP_IDLE) == AP_IDLE );
}

// Checks the ready status of the kernel
bool is_kernel_ready() {
    return ( (Xil_In32(Xkrnl_Control) && AP_READY) == AP_READY );
}

bool check_results(uint32_t out[SIZE_MM]) {

    for (int i=0; i<DATA_SIZE; i++) {

        for(int j=0; j<DATA_SIZE; j++) {

            if (axi_mm[OFFSET_C + (i*DATA_SIZE + j)] != EXPCTD)
                return false;

        }

    }

    return true;
}

int main() {

    uint32_t axi_mm[SIZE_MM];

    // Initializing input/output data
    initialize_data(axi_mm);

    // Starting the kernel
    start_kernel(axi_mm);

    // Checking results
    // if (check_results(out))
    //     return 0;
    // else return 1;
    while(1);

    return 0;

}