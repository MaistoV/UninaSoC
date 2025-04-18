#include "tinyIO.h"
#include "stdlib.h"
#include "driver.h"
#include "krnl_conv_naive.h"
#include "utils.h"

// Null macros
// #define printf
// #define tinyIO_init

void dump_csrs () {
    // Init
    uint32_t csr = -1;
    // Read & print
    printf( "CSR DUMP:\n\r");
    printf( "   AP_CTRL     = 0x%04x    ", Xil_In32(Xkrnl_Control   ) );
    printf( "   AXI_I_ADDR  = 0x%04x\n\r", Xil_In32(Xkrnl_AXI_ADDR_I) );
    printf( "   GIE         = 0x%04x    ", Xil_In32(Xkrnl_GIE       ) );
    printf( "   AXI_W_ADDR  = 0x%04x\n\r", Xil_In32(Xkrnl_AXI_ADDR_W) );
    printf( "   IER         = 0x%04x    ", Xil_In32(Xkrnl_IER       ) );
    printf( "   AXI_O_ADDR  = 0x%04x\n\r", Xil_In32(Xkrnl_AXI_ADDR_O) );
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

// // Print DATA_SIZE x DATA_SIZE matrix
// void print_matrix (uint32_t data [DATA_SIZE*DATA_SIZE]) {
//     for ( int i = 0; i < DATA_SIZE; i++ ) {
//         for ( int j = 0; j < DATA_SIZE; j++ ) {
//             printf("0x%08x ", data[i*DATA_SIZE + j]);
//         }
//         printf("\n\r");
//     }
// }

// Import symbols for peripherals
extern const volatile uint32_t _peripheral_UART_start;

#define PRINT_LEAP 10000
int main() {

    // Control CSR
    uint32_t csr_read;
    uint32_t cnt;

    // Init platform
    tinyIO_init((uint32_t)&_peripheral_UART_start);

    // Pre-allocate tensors, aligned to power of two
    #define ALIGN_I 2048
    #define ALIGN_W 1024
    #define ALIGN_O 1024
    target_type_t I       [N][C][ Y][ X]__attribute__((aligned(ALIGN_I)));
    target_type_t W       [K][C][ R][ S]__attribute__((aligned(ALIGN_W)));
    target_type_t O       [N][K][Y1][X1]__attribute__((aligned(ALIGN_O)));
    target_type_t expected[N][K][Y1][X1] = {0};

    printf("\n\r");
    printf("-----------------\n\r");
    printf("- HLS CONV NAIVE -\n\r");
    printf("-----------------\n\r");
    printf("\n\r");

    // Initializing input/output data
    init_data(I, W, O);

    // // Dump source data
    // printf("A 0x%04x:\n\r", (u32)A); print_matrix(A);
    // printf("B 0x%04x:\n\r", (u32)B); print_matrix(B);

    // Compute expected
    printf("[INFO] Compute expected\n\r");
    compute_expected(I, W, expected);

    printf("Waiting for idle...\n\r");
    // Reset counter
    print_control_csr(csr_read);
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
    } while ( XKrnl_conv_naive_IsIdle() );

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
    XKrnl_conv_naive_Set_axi_addr_I((void*)I);
    XKrnl_conv_naive_Set_axi_addr_W((void*)W);
    XKrnl_conv_naive_Set_axi_addr_O((void*)O);
    // Enable auto-restart
    XKrnl_conv_naive_EnableAutoRestart();
    // Raising ap_start to start the kernel
    XKrnl_conv_naive_Start();

    // Dump
    // dump_csrs();

    // for ( uint32_t i = 0; i < 1000; i++ ) {
        // Waiting for the kernel to finish (polling the ap_done control bit)
        printf("Waiting for done...\n\r");
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
        } while ( XKrnl_conv_naive_IsDone() );

        // // Read pending interrupts
        // printf( "   ISR     = 0x%04x\n\r", XKrnl_conv_naive_InterruptGetStatus() );
        // // Clear interrupts
        // XKrnl_conv_naive_InterruptClear_ap_done();
        // XKrnl_conv_naive_InterruptClear_ap_ready();
        // // Read pending interrupts
        // printf( "   ISR     = 0x%04x\n\r", XKrnl_conv_naive_InterruptGetStatus() );

        // // Write continue
        // XKrnl_conv_naive_Continue();

        // Dump
        // printf("hls_out : 0x%04x:\n\r", (uint32_t*)O ); print_matrix(hls_out );
        // printf("expected: 0x%04x:\n\r", (uint32_t*)expected); print_matrix(expected);
        // print_control_csr( Xil_In32(Xkrnl_Control) );
        dump_csrs();

    // }

    // Checking results
    printf("[INFO] Checking results...\n\r");
    bool result = check_values(O, expected);
    if ( !result ) {
        printf("[ERROR] Check failed!\n\r");
        return 1;
    }
    else {
        printf("[INFO] Check successful!\n\r");
    }


    return 0;

}