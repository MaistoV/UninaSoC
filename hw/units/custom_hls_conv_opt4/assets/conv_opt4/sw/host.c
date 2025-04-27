// Author: Vincenzo Maisto <vincenzo.maisto2@unina.it>
// Description: Baremetal host code coe conv_opt4 HLS IP core.

#include "driver.h"
#include "krnl_conv_opt4.h"
#include "uninasoc.h"
#include "measures.h"
#include "utils.h"

void dump_conv_opt4_csrs () {
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

#define PRINT_LEAP 10000
int main() {

    // Control CSR
    uint32_t csr_read;
    uint32_t cnt;

    // Init platform
    uninasoc_init();

    // Pre-allocate tensors, aligned to power of two
    #define ALIGN_I 2048
    #define ALIGN_W 1024
    #define ALIGN_O 1024
    target_type_t I       [N][C][ Y][ X]__attribute__((aligned(ALIGN_I)));
    target_type_t W       [K][C][ R][ S]__attribute__((aligned(ALIGN_W)));
    target_type_t O       [N][K][Y1][X1]__attribute__((aligned(ALIGN_O)));
    target_type_t expected[N][K][Y1][X1] = {0};

    printf("\n\r");
    printf("------------------\n\r");
    printf("- HLS CONV OPT4  -\n\r");
    printf("------------------\n\r");
    printf("\n\r");

    // Initializing input/output data
    init_data(I, W, O);

    // Compute expected
    printf("[INFO] Compute expected\n\r");
    #define HOST_REPS 1
    for ( int i = 0; i < HOST_REPS; i++) {
        uint32_t mcycle_start_host, mcycle_end_host;
        mcycle_start_host = get_mcycle();
        compute_expected(I, W, expected);
        mcycle_end_host = get_mcycle();
        print_meas(
                "host",
                i,
                mcycle_start_host,
                mcycle_end_host   );
    }

    printf("[INFO] Waiting for idle...\n\r");
    // Reset counter
    cnt = 0;
    // print_control_csr(csr_read);
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
    // Global Interrupts Enable
    XKrnl_InterruptGlobalEnable();
    // Enable done and ready interrupts
    XKrnl_InterruptEnable_ap_done();
    // XKrnl_InterruptEnable_ap_ready();

    /////////////////////////
    // Starting the kernel //
    /////////////////////////

    uint32_t mcycle_start, mcycle_end;
    mcycle_start = get_mcycle();

    // Writing input/output addresses
    Xil_Out32(Xkrnl_AXI_ADDR_I, (uint32_t)I);
    Xil_Out32(Xkrnl_AXI_ADDR_W, (uint32_t)W);
    Xil_Out32(Xkrnl_AXI_ADDR_O, (uint32_t)O);
    Xil_Out32(Xkrnl_N, (uint8_t)N);
    Xil_Out32(Xkrnl_C, (uint8_t)C);
    Xil_Out32(Xkrnl_K, (uint8_t)K);

    // Enable auto-restart
    XKrnl_EnableAutoRestart();
    // Raising ap_start to start the kernel
    XKrnl_Start();

    // Waiting for the kernel to finish (polling the ap_done control bit)
    // printf("[INFO] Waiting for done...\n\r");
    // Reset counter
    // cnt = 0;
    do {
        // Increment counter
        // cnt++;
        // if ( cnt == PRINT_LEAP ) {
        //     // Reset counter
        //     cnt = 0;
        //     // Read
        //     csr_read = -1;
        //     csr_read = Xil_In32(Xkrnl_Control);
        //     // Print
        //     print_control_csr(csr_read);
        // }
    } while ( XKrnl_IsDone() );

    mcycle_end = get_mcycle();
    print_meas (
            "conv_opt4",
            N,
            mcycle_start,
            mcycle_end
        );

    // // Read pending interrupts
    // printf( "   ISR     = 0x%04x\n\r", XKrnl_InterruptGetStatus() );
    // // Clear interrupts
    XKrnl_InterruptClear_ap_done();
    // XKrnl_InterruptClear_ap_ready();
    // Read pending interrupts
    // printf( "   ISR     = 0x%04x\n\r", XKrnl_InterruptGetStatus() );

    // // Write continue
    // XKrnl_Continue();

    // DUMP
    // dump_conv_opt4_csrs();
    // printf("I **********************************:\n\r"); print_tensor((target_type_t*)I,N,C,Y,X);
    // printf("W **********************************:\n\r"); print_tensor((target_type_t*)W,K,C,R,S);
    // printf("expected ***************************:\n\r"); print_tensor((target_type_t*)expected,N,K,Y1,X1);
    // printf("O **********************************:\n\r"); print_tensor((target_type_t*)O,N,K,Y1,X1);

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