#include "xil_io.h"
#include "tinyIO.h"
#include <stdbool.h>
#include "xkrnl_vdotprod_hw.h"

// Import symbols for peripherals
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

void dump_csrs () {
    // Init
    uint32_t csr = -1;
    // Read & print
    printf( "CSR DUMP:\n\r");
    printf( "   AP_CTRL     = 0x%04x\n\r", Xil_In32(Xkrnl_Control ) );
    printf( "   GIE         = 0x%04x\n\r", Xil_In32(Xkrnl_GIE     ) );
    printf( "   IER         = 0x%04x\n\r", Xil_In32(Xkrnl_IER     ) );
    printf( "   ISR         = 0x%04x\n\r", Xil_In32(Xkrnl_ISR     ) );
    printf( "   AXI_MM_DATA = 0x%04x\n\r", Xil_In32(Xkrnl_AXI_ADDR) );
}

// Print each field of a control CSR word
void print_control_csr ( uint32_t csr_read_in ) {

    // Print fields
    printf("AP_CTRL = 0x%04x\n\r", csr_read_in);
    // printf("    AP_START     =  0x%x \n\r", ( csr_read_in & AP_START    ) >> (AP_START_BIT    ));
    // printf("    AP_DONE      =  0x%x \n\r", ( csr_read_in & AP_DONE     ) >> (AP_DONE_BIT     ));
    // printf("    AP_IDLE      =  0x%x \n\r", ( csr_read_in & AP_IDLE     ) >> (AP_IDLE_BIT     ));
    // printf("    AP_READY     =  0x%x \n\r", ( csr_read_in & AP_READY    ) >> (AP_READY_BIT    ));
    // printf("    AP_CONTINUE  =  0x%x \n\r", ( csr_read_in & AP_CONTINUE ) >> (AP_CONTINUE_BIT ));
    // printf("    AP_INTERRUPT =  0x%x \n\r", ( csr_read_in & AP_INTERRUPT) >> (AP_INTERRUPT_BIT));
}

uint32_t read_and_print_control_csr ( ) {
    // Init
    uint32_t csr_read = -1;
    // Read
    csr_read = Xil_In32(Xkrnl_Control);
    // Print
    print_control_csr ( csr_read );
}

void print_array ( uint32_t* array, uint32_t len ){
    for ( uint32_t i = 0; i < len; i++ ) {
        printf("%u ", array[i]);
    }
    printf("\n\r");
}

// Init data for HLS core
void initialize_data (
                        uint32_t * __restrict A,
                        uint32_t * __restrict B,
                        uint32_t * __restrict hls_out
                    ) {
    // Init inputs
    for (uint32_t i = 0; i < DATA_SIZE; i++) {
        A[i] = i ;
        B[i] = i + DATA_SIZE;
    }

    // Init output
    *hls_out = 0x555555;

    // Debug
    printf("A       :   0x%04x\n\r", (uint32_t*) A      );
    printf("B       :   0x%04x\n\r", (uint32_t*) B      );
    printf("hls_out :   0x%04x\n\r", (uint32_t*) hls_out);
    printf("A[*]    : "); print_array ( A, DATA_SIZE);
    printf("B[*]    : "); print_array ( B, DATA_SIZE);
    printf("*hls_out:   0x%04x\n\r", (uint32_t*) *hls_out);
}


#define PRINT_LEAP 100000

int main() {

    printf("\n\r");
    printf("----------------\n\r");
    printf("- HLS VDOTPROD -\n\r");
    printf("----------------\n\r");

    // Control CSR
    uint32_t csr_read;
    uint32_t cnt;

    // Init platform
    uint32_t uart_base_address = (uint32_t) &_peripheral_UART_start;
    tinyIO_init(uart_base_address);

    // Allocate data
    // - A,B    : 2 buffers of DATA_SIZE elements
    // - hls_out: 1 single element
    #define HLS_BUFFER_SIZE ((DATA_SIZE*2) +1)
    // Align to read burst address span:
    // - size of A and B combined
    #define HLS_BUFFER_ALIGN (DATA_SIZE*2)
    uint32_t HLS_buffer[HLS_BUFFER_SIZE] __attribute__((aligned(HLS_BUFFER_ALIGN)));
    // Pointers to arguments
    uint32_t* A       = HLS_buffer + A_OFFSET;
    uint32_t* B       = HLS_buffer + B_OFFSET;
    uint32_t* hls_out = HLS_buffer + hls_out_OFFSET;

    // Debug print
    read_and_print_control_csr();
    dump_csrs();

    // Prepare data
    initialize_data ( A, B, hls_out );

    // printf("Waiting for idle...\n\r");
    // // Reset counter
    // cnt = 0;
    // do {
    //     // Read
    //     csr_read = -1;
    //     csr_read = Xil_In32(Xkrnl_Control);
    //     // Increment counter
    //     cnt++;
    //     if ( cnt == PRINT_LEAP ) {
    //         // Reset counter
    //         cnt = 0;
    //         // Print
    //         // print_control_csr ( csr_read );
    //         dump_csrs();
    //     }
    // } while ( ( csr_read & AP_IDLE ) != AP_IDLE );

    // printf("Waiting for ready...\n\r");
    // do {
    //     csr_read = -1;
    //     csr_read = print_control_csr();
    // } while ( ( csr_read & AP_READY) != AP_READY );

    // Pass arguments
    Xil_Out32(Xkrnl_AXI_ADDR, (uint32_t) HLS_buffer);

    // Start
    csr_read = Xil_In32(Xkrnl_Control);
    Xil_Out32(Xkrnl_Control, csr_read | AP_START);

    // Dump
    dump_csrs();

    // Waiting for the kernel to finish (polling the ap_done control bit)
    // printf("Waiting for done...\n\r");
    // // Reset counter
    // cnt = 0;
    // do {
    //     // Increment counter
    //     cnt++;
    //     if ( cnt == PRINT_LEAP ) {
    //         // Read
    //         csr_read = -1;
    //         csr_read = Xil_In32(Xkrnl_Control);
    //         // Reset counter
    //         cnt = 0;
    //         // Print
    //         print_control_csr ( csr_read );
    //     }
    // } while ( ( csr_read & AP_DONE) != AP_DONE );

    // Checking results
    uint32_t expected = compute_result(A, B);
    printf("Expected: %u\n\r", expected);
    printf("Computed: %u\n\r", *hls_out );
    if ( expected != *hls_out ) {
        printf("ERROR! Wrong result!\n\r");
    }
    printf("\n\r\n\r");


    return 0;

}
