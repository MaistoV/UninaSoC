#include "xil_io.h"
#include "tinyIO.h"
#include "xkrnl_matmul_hw.h"

#define Xkrnl_BASE                  ((unsigned int)(&_peripheral_HLS_CONTROL_start))
#define Xkrnl_Control               (Xkrnl_BASE + XKRNL_MATMUL_CONTROL_ADDR_AP_CTRL)
#define Xkrnl_GIE                   (Xkrnl_BASE + XKRNL_MATMUL_CONTROL_ADDR_GIE)
#define Xkrnl_IER                   (Xkrnl_BASE + XKRNL_MATMUL_CONTROL_ADDR_IER)
#define Xkrnl_ISR                   (Xkrnl_BASE + XKRNL_MATMUL_CONTROL_ADDR_ISR)
#define Xkrnl_A_ADDR                (Xkrnl_BASE + XKRNL_MATMUL_CONTROL_ADDR_IN_A_DATA)
#define Xkrnl_B_ADDR                (Xkrnl_BASE + XKRNL_MATMUL_CONTROL_ADDR_IN_B_DATA)
#define Xkrnl_out_ADDR              (Xkrnl_BASE + XKRNL_MATMUL_CONTROL_ADDR_OUT_R_DATA)

#define AP_START                    (0x00000001)
#define AP_DONE                     (0x00000002)
#define AP_IDLE                     (0x00000004)
#define AP_READY                    (0x00000008)
#define AP_CONTINUE                 (0x00000010)
#define AP_INTERRUPT                (0x00000020)

#define AP_START_BIT                (0x00000000)
#define AP_DONE_BIT                 (0x00000001)
#define AP_IDLE_BIT                 (0x00000002)
#define AP_READY_BIT                (0x00000003)
#define AP_CONTINUE_BIT             (0x00000004)
#define AP_INTERRUPT_BIT            (0x00000005)

#define DATA_SIZE 32
#define A_OFFSET 0
#define B_OFFSET DATA_SIZE
#define hls_out_OFFSET 2*DATA_SIZE

void initialize_data(
                        uint32_t A[DATA_SIZE*DATA_SIZE],
                        uint32_t B[DATA_SIZE*DATA_SIZE],
                        uint32_t out[DATA_SIZE*DATA_SIZE]
                    ) {
    for (int i = 0; i < DATA_SIZE; i++) {
        for (int j=0; j<DATA_SIZE; j++) {
            A[i*DATA_SIZE + j] = i*DATA_SIZE + j;
            B[i*DATA_SIZE + j] = j*DATA_SIZE + i;
            out[i*DATA_SIZE + j] = 0x55555555;
        }
    }
}

void compute_expected (
                        uint32_t A[DATA_SIZE*DATA_SIZE],
                        uint32_t B[DATA_SIZE*DATA_SIZE],
                        uint32_t expected[DATA_SIZE*DATA_SIZE]
                    ) {
    for (int i=0; i<DATA_SIZE; i++) {
        for (int j=0; j<DATA_SIZE; j++) {
            uint32_t outsum = 0;
            for (int k=0; k<DATA_SIZE; k++) {
                outsum += A[i][k] * B[k][j];
            }
            expected[i][j] = outsum;
        }
    }
}

// Starts kernel execution
void start_kernel(  uint32_t A[DATA_SIZE*DATA_SIZE],
                    uint32_t B[DATA_SIZE*DATA_SIZE],
                    uint32_t out[DATA_SIZE*DATA_SIZE]) {

    // Writing input/output addresses
    Xil_Out64(Xkrnl_A_ADDR, (uint32_t)A);
    Xil_Out64(Xkrnl_B_ADDR, (uint32_t)B);
    Xil_Out64(Xkrnl_out_ADDR, (uint32_t)out);

    // Raising ap_start to start the kernel
    Xil_Out32(Xkrnl_Control, AP_START);

    // Waiting for the kernel to finish (polling the ap_done control bit)
    while ( (Xil_In32(Xkrnl_Control) && AP_DONE) != AP_DONE ) {}
}

int check_results (
        uint32_t expected  [DATA_SIZE][DATA_SIZE],
        uint32_t out       [DATA_SIZE*DATA_SIZE]
    ) {

    // Compare
    for (int i=0; i<DATA_SIZE; i++) {
        for(int j=0; j<DATA_SIZE; j++) {
            if (out[i*DATA_SIZE + j] != [i][j])
                return 1;
        }
    }
    return 0;
}

void dump_csrs () {
    // Init
    uint32_t csr = -1;
    // Read & print
    printf( "CSR DUMP:\n\r");
    printf( "   AP_CTRL     = 0x%04x\n\r", Xil_In32(Xkrnl_Control ) );
    printf( "   GIE         = 0x%04x\n\r", Xil_In32(Xkrnl_GIE     ) );
    printf( "   IER         = 0x%04x\n\r", Xil_In32(Xkrnl_IER     ) );
    printf( "   ISR         = 0x%04x\n\r", Xil_In32(Xkrnl_ISR     ) );
    printf( "   AXI_MM_DATA = 0x%04x\n\r", Xil_In32(Xkrnl_out_ADDR) );
}

#define PRINT_LEAP 100000
int main() {

    // Control CSR
    uint32_t csr_read;
    uint32_t cnt;

    #define BUFFER_SIZE (DATA_SIZE*DATA_SIZE)
    uint32_t A       [BUFFER_SIZE] __attribute__((aligned(BUFFER_SIZE)));
    uint32_t B       [BUFFER_SIZE] __attribute__((aligned(BUFFER_SIZE)));
    uint32_t out     [BUFFER_SIZE] __attribute__((aligned(BUFFER_SIZE)));
    uint32_t expected[BUFFER_SIZE] = {0};

    // Initializing input/output data
    initialize_data(A, B, out);

    // Compute expected
    compute_expected(A, B, expected);

    printf("Waiting for idle...\n\r");
    // Reset counter
    cnt = 0;
    do {
        // Read
        csr_read = -1;
        csr_read = Xil_In32(Xkrnl_Control);
        // Increment counter
        cnt++;
        if ( cnt == PRINT_LEAP ) {
            // Reset counter
            cnt = 0;
            // Print
            dump_csrs();
        }
    } while ( ( csr_read & AP_IDLE ) != AP_IDLE );

    /////////////////////////
    // Starting the kernel //
    /////////////////////////

    // Writing input/output addresses
    Xil_Out64(Xkrnl_A_ADDR, (uint32_t)A);
    Xil_Out64(Xkrnl_B_ADDR, (uint32_t)B);
    Xil_Out64(Xkrnl_out_ADDR, (uint32_t)out);
    // Raising ap_start to start the kernel
    Xil_Out32(Xkrnl_Control, AP_START);

    // Dump
    dump_csrs();

    // Waiting for the kernel to finish (polling the ap_done control bit)
    printf("Waiting for done...\n\r");
    // Reset counter
    cnt = 0;
    do {
        // Increment counter
        cnt++;
        if ( cnt == PRINT_LEAP ) {
            // Read
            csr_read = -1;
            csr_read = Xil_In32(Xkrnl_Control);
            // Reset counter
            cnt = 0;
            // Print
            print_control_csr ( csr_read );
        }
    } while ( ( csr_read & AP_DONE) != AP_DONE );

    // Checking results
    if ( check_results(expected, out) == 0 ) {
        printf("Expected result ok!");
    }
    else {
        printf("ERROR! The result is not that expected");
    }


    return 0;

}