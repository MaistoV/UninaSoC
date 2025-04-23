#include "stdlib.h"
#include "driver.h"
#include "tinyIO.h"

// Null macros
// #define printf
// #define tinyIO_init

void initialize_data(
                        uint32_t A[DATA_SIZE*DATA_SIZE],
                        uint32_t B[DATA_SIZE*DATA_SIZE],
                        uint32_t hls_out[DATA_SIZE*DATA_SIZE]
                    ) {
    for (int i = 0; i < DATA_SIZE; i++) {
        for (int j = 0; j < DATA_SIZE; j++) {
            A[i*DATA_SIZE + j] = i*DATA_SIZE + j +2;
            B[i*DATA_SIZE + j] = j*DATA_SIZE + i +2;
            hls_out[i*DATA_SIZE + j] = 0x55555555;
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
                outsum += A[i*DATA_SIZE + k] * B[k*DATA_SIZE + j];
            }
            expected[i*DATA_SIZE + j] = outsum;
        }
    }
}

int check_results (
        uint32_t expected  [DATA_SIZE*DATA_SIZE],
        uint32_t hls_out   [DATA_SIZE*DATA_SIZE]
    ) {

    // Compare
    for (int i=0; i<DATA_SIZE; i++) {
        for(int j=0; j<DATA_SIZE; j++) {
            if (hls_out[i*DATA_SIZE + j] != expected[i*DATA_SIZE + j])
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
    printf( "   AP_CTRL     = 0x%04x    ", Xil_In32(Xkrnl_Control   ) );
    printf( "   AXI_A_ADDR  = 0x%04x\n\r", Xil_In32(Xkrnl_AXI_ADDR_A) );
    printf( "   GIE         = 0x%04x    ", Xil_In32(Xkrnl_GIE       ) );
    printf( "   AXI_B_ADDR  = 0x%04x\n\r", Xil_In32(Xkrnl_AXI_ADDR_B) );
    printf( "   IER         = 0x%04x    ", Xil_In32(Xkrnl_IER       ) );
    printf( "   AXI_C_ADDR  = 0x%04x\n\r", Xil_In32(Xkrnl_AXI_ADDR_C) );
    printf( "   ISR         = 0x%04x\n\r", Xil_In32(Xkrnl_ISR       ) );
}

// Print each field of a control CSR word
void print_control_csr ( uint32_t csr_read_in ) {
    // Print fields
    printf("AP_CTRL = 0x%04x\n\r", csr_read_in);
    printf("    START       =  0x%x    ", ( csr_read_in & AP_START    ) >> (AP_START_BIT    ));
    printf("    DONE        =  0x%x\n\r", ( csr_read_in & AP_DONE     ) >> (AP_DONE_BIT     ));
    printf("    IDLE        =  0x%x    ", ( csr_read_in & AP_IDLE     ) >> (AP_IDLE_BIT     ));
    printf("    READY       =  0x%x\n\r", ( csr_read_in & AP_READY    ) >> (AP_READY_BIT    ));
    printf("    CONTINUE    =  0x%x    ", ( csr_read_in & AP_CONTINUE ) >> (AP_CONTINUE_BIT ));
    printf("    AUTORESTART =  0x%x\n\r", ( csr_read_in & AP_AUTORESTART) >> (AP_AUTORESTART_BIT));
    printf("    INTERRUPT   =  0x%x\n\r", ( csr_read_in & AP_INTERRUPT) >> (AP_INTERRUPT_BIT));
}

// Print DATA_SIZE x DATA_SIZE matrix
void print_matrix (uint32_t data [DATA_SIZE*DATA_SIZE]) {
    for ( int i = 0; i < DATA_SIZE; i++ ) {
        for ( int j = 0; j < DATA_SIZE; j++ ) {
            printf("0x%08x ", data[i*DATA_SIZE + j]);
        }
        printf("\n\r");
    }
}

// Import symbols for peripherals
extern const volatile uint32_t _peripheral_UART_start;

#define PRINT_LEAP 10000
int main() {

    // Control CSR
    uint32_t csr_read;
    uint32_t cnt;

    // Init platform
    tinyIO_init((uint32_t)&_peripheral_UART_start);

    // Allocate data
    #define ALIGN (4*DATA_SIZE*DATA_SIZE)
    uint32_t A        [DATA_SIZE*DATA_SIZE] __attribute__((aligned(ALIGN)));
    uint32_t B        [DATA_SIZE*DATA_SIZE] __attribute__((aligned(ALIGN)));
    uint32_t hls_out  [DATA_SIZE*DATA_SIZE] __attribute__((aligned(ALIGN)));
    uint32_t expected [DATA_SIZE][DATA_SIZE] = {0};

    printf("\n\r");
    printf("-----------------\n\r");
    printf("- HLS GEMM v1.1 -\n\r");
    printf("-----------------\n\r");
    printf("\n\r");

    // Initializing input/output data
    initialize_data(A, B, hls_out);

    // Dump source data
    printf("A 0x%04x:\n\r", (uint32_t)A); print_matrix(A);
    printf("B 0x%04x:\n\r", (uint32_t)B); print_matrix(B);

    // Compute expected
    compute_expected(A, B, (uint32_t*)expected);

    printf("[INFO] Waiting for idle...\n\r");
    // Reset counter
    // print_control_csr(csr_read);
    cnt = 0;
    do {
        // Increment counter
        cnt++;
        if ( cnt == PRINT_LEAP ) {
            // Reset counter
            cnt = 0;
            // Read
            csr_read = -1;
            csr_read = Xil_In32(Xkrnl_Control);
            // Print
            print_control_csr(csr_read);
        }
    } while ( XKrnl_IsIdle() );

    ///////////////////////
    // Enable interrupts //
    ///////////////////////
    // // Global Interrupts Enable
    // Xil_Out32(Xkrnl_GIE, 0x1);
    // // Enable done and ready interrupts
    // Xil_Out32(Xkrnl_IER, 0x3);

    /////////////////////////
    // Starting the kernel //
    /////////////////////////
    // Writing input/output addresses
    Xil_Out32(Xkrnl_AXI_ADDR_A, (uint32_t)A);
    Xil_Out32(Xkrnl_AXI_ADDR_B, (uint32_t)B);
    Xil_Out32(Xkrnl_AXI_ADDR_C, (uint32_t)hls_out);
    // Enable auto-restart
    XKrnl_EnableAutoRestart();
    // Raising ap_start to start the kernel
    XKrnl_Start();

    // Dump
    // dump_csrs();

    // for ( uint32_t i = 0; i < 1000; i++ ) {
        // Waiting for the kernel to finish (polling the ap_done control bit)
        printf("[INFO] Waiting for done...\n\r");
        // Reset counter
        cnt = 0;
        do {
            // Increment counter
            cnt++;
            if ( cnt == PRINT_LEAP ) {
                // Reset counter
                cnt = 0;
                // Read
                csr_read = -1;
                csr_read = Xil_In32(Xkrnl_Control);
                // Print
                print_control_csr(csr_read);
            }
        } while ( XKrnl_IsDone() );

        // // Read pending interrupts
        // printf( "   ISR     = 0x%04x\n\r", XKrnl_InterruptGetStatus() );
        // // Clear interrupts
        // XKrnl_InterruptClear_ap_done();
        // XKrnl_InterruptClear_ap_ready();
        // // Read pending interrupts
        // printf( "   ISR     = 0x%04x\n\r", XKrnl_InterruptGetStatus() );

        // // Write continue
        // XKrnl_Continue();

        // Dump
        printf("hls_out : 0x%04x:\n\r", (uint32_t*)hls_out ); print_matrix(hls_out );
        printf("expected: 0x%04x:\n\r", (uint32_t*)expected); print_matrix((uint32_t*)expected);
        print_control_csr( Xil_In32(Xkrnl_Control) );
        dump_csrs();

    // }

    // Checking results
    if ( check_results((uint32_t*)expected, hls_out) == 0 ) {
        printf("Expected result ok!\n\r");
    }
    else {
        printf("ERROR! The result is not as expected!\n\r");
    }


    return 0;

}