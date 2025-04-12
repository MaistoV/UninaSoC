#include "xil_io.h"
#include "tinyIO.h"
#include <stdbool.h>
#include "xkrnl_vdotprod_hw.h"

extern const volatile uint32_t _peripheral_UART_start;
extern const volatile uint32_t _peripheral_HLS_CONTROL_start;

#define Xkrnl_BASE                  ((unsigned int)(&_peripheral_HLS_CONTROL_start))
#define Xkrnl_Control               (Xkrnl_BASE + XKRNL_VDOTPROD_CONTROL_ADDR_AP_CTRL)
#define Xkrnl_GIE                   (Xkrnl_BASE + XKRNL_VDOTPROD_CONTROL_ADDR_GIE)
#define Xkrnl_IER                   (Xkrnl_BASE + XKRNL_VDOTPROD_CONTROL_ADDR_IER)
#define Xkrnl_ISR                   (Xkrnl_BASE + XKRNL_VDOTPROD_CONTROL_ADDR_ISR)
#define Xkrnl_AXI_ADDR              (Xkrnl_BASE + XKRNL_VDOTPROD_CONTROL_ADDR_AXI_MM_DATA)

#define AP_START                    (0x00000001)
#define AP_DONE                     (0x00000002)
#define AP_IDLE                     (0x00000004)
#define AP_READY                    (0x00000008)
#define AP_CONTINUE                 (0x00000010)
#define AP_INTERRUPT                (0x00000020)

#define DATA_SIZE 32
#define DATA 1

void initialize_data (
                        uint32_t A[DATA_SIZE],
                        uint32_t B[DATA_SIZE],
                        uint32_t* hls_out
                    ) {
    for (int i = 0; i < DATA_SIZE; i++) {
        A[i] = i;
        B[i] = i;
    }

    *hls_out = -1;

    // Debug
    printf("A      :   0x%04x\n\r", (uint32_t*) A      );
    printf("B      :   0x%04x\n\r", (uint32_t*) B      );
    printf("hls_out:   0x%04x\n\r", (uint32_t*) hls_out);
}

#define DATA_SIZE 32
#define A_OFFSET 0
#define B_OFFSET DATA_SIZE
#define out_OFFSET 2*DATA_SIZE

// Prepare inputs to HLS core
void setup_hls (
                        uint32_t A[DATA_SIZE],
                        uint32_t B[DATA_SIZE],
                        uint32_t* hls_out
                    ) {

    Xil_Out32(Xkrnl_AXI_ADDR + A_OFFSET  , (u32) A      );
    Xil_Out32(Xkrnl_AXI_ADDR + B_OFFSET  , (u32) B      );
    Xil_Out32(Xkrnl_AXI_ADDR + out_OFFSET, (u32) hls_out);

}

uint32_t compute_result (
                        uint32_t A[DATA_SIZE],
                        uint32_t B[DATA_SIZE]
                    ) {

    // Compute locally
    uint32_t expected = 0;
    for ( uint32_t i = 0; i < DATA_SIZE; i++ ) {
        expected += A[i] * B[i];
    }

    // Return
    return expected;
}

void print_csrs () {
    // Init
    uint32_t csr = -1;
    // Read & print
    printf( "AP_CTRL     = 0x%04x\n\r", Xil_In32(Xkrnl_Control ) );
    printf( "GIE         = 0x%04x\n\r", Xil_In32(Xkrnl_GIE     ) );
    printf( "IER         = 0x%04x\n\r", Xil_In32(Xkrnl_IER     ) );
    printf( "ISR         = 0x%04x\n\r", Xil_In32(Xkrnl_ISR     ) );
    printf( "AXI_MM_DATA = 0x%04x\n\r", Xil_In32(Xkrnl_AXI_ADDR) );
}

uint32_t print_control_csr () {
    // Init
    uint32_t csr = -1;

    // Read
    csr = Xil_In32(Xkrnl_Control);

    // Print fields
    printf("AP_CTRL = 0x%04x\n\r", csr);
    printf("    AP_START     =  0x%x \n\r", csr & AP_START     );
    printf("    AP_DONE      =  0x%x \n\r", csr & AP_DONE      );
    printf("    AP_IDLE      =  0x%x \n\r", csr & AP_IDLE      );
    printf("    AP_READY     =  0x%x \n\r", csr & AP_READY     );
    printf("    AP_CONTINUE  =  0x%x \n\r", csr & AP_CONTINUE  );
    printf("    AP_INTERRUPT =  0x%x \n\r", csr & AP_INTERRUPT );
}

int main() {

    printf("----------------\n\r");
    printf("- HLS VDOTPROD -\n\r");
    printf("----------------\n\r");

    // Control CSR
    uint32_t control_csr;

    // Init platform
    uint32_t uart_base_address = (uint32_t) &_peripheral_UART_start;
    tinyIO_init(uart_base_address);

    // Allocate data
    uint32_t A[DATA_SIZE];
    uint32_t B[DATA_SIZE];
    uint32_t hls_out;

    // Debug print
    print_control_csr();
    print_csrs();

    // Prepare data
    initialize_data ( A, B, &hls_out );
    return 0;

    printf("Waiting for idle...\n\r");
    do {
        control_csr = -1;
        control_csr = print_control_csr();
    } while ( ( control_csr & AP_IDLE) != AP_IDLE );

    // printf("Waiting for ready...\n\r");
    // do {
    //     control_csr = -1;
    //     control_csr = print_control_csr();
    // } while ( ( control_csr & AP_READY) != AP_READY );

    // Pass arguments
    setup_hls( A, B, &hls_out );


    // Raising ap_start to start the kernel
    Xil_Out32(Xkrnl_Control, AP_START);

    // Waiting for the kernel to finish (polling the ap_done control bit)
    printf("Waiting for done...\n\r");
    do {
        control_csr = -1;
        control_csr = print_control_csr();
        print_csrs();
    } while ( ( control_csr & AP_DONE) != AP_DONE );

    // Checking results
    uint32_t expected = compute_result(A, B);
    printf("Expected: %u\n\r", expected);
    printf("Computed: %u\n\r", hls_out );
    if ( expected != hls_out ) {
        printf("ERROR! Wrong result!\n\r");
    }

    return 0;

}
