#include "xil_io.h"
#include "tinyIO.h"
#include "xkrnl_matmul_hw.h"
#include "stdlib.h"

// Import symbols for peripherals
extern const volatile uint32_t _peripheral_UART_start;
extern const volatile uint32_t _peripheral_HLS_CONTROL_start;

#define Xkrnl_BASE                  ((unsigned int)(&_peripheral_HLS_CONTROL_start))
#define Xkrnl_Control               (Xkrnl_BASE + XKRNL_MATMUL_CONTROL_ADDR_AP_CTRL)
#define Xkrnl_GIE                   (Xkrnl_BASE + XKRNL_MATMUL_CONTROL_ADDR_GIE)
#define Xkrnl_IER                   (Xkrnl_BASE + XKRNL_MATMUL_CONTROL_ADDR_IER)
#define Xkrnl_ISR                   (Xkrnl_BASE + XKRNL_MATMUL_CONTROL_ADDR_ISR)
#define Xkrnl_AXI_MM_ADDR           (Xkrnl_BASE + XKRNL_MATMUL_CONTROL_ADDR_AXI_MM_DATA)

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

#define DATA_SIZE 4
#define A_OFFSET 0
#define B_OFFSET DATA_SIZE*DATA_SIZE
#define hls_out_OFFSET 2*DATA_SIZE*DATA_SIZE

void initialize_data(
                        uint32_t A[DATA_SIZE*DATA_SIZE],
                        uint32_t B[DATA_SIZE*DATA_SIZE],
                        uint32_t hls_out[DATA_SIZE*DATA_SIZE]
                    ) {
    for (int i = 0; i < DATA_SIZE; i++) {
        for (int j = 0; j < DATA_SIZE; j++) {
            A[i*DATA_SIZE + j] = i*DATA_SIZE + j;
            B[i*DATA_SIZE + j] = j*DATA_SIZE + i;
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
    // printf( "CSR DUMP:\n\r");
    printf( "   AP_CTRL     = 0x%04x\n\r", Xil_In32(Xkrnl_Control) );
    // printf( "   GIE         = 0x%04x\n\r", Xil_In32(Xkrnl_GIE     ) );
    // printf( "   IER         = 0x%04x\n\r", Xil_In32(Xkrnl_IER     ) );
    // printf( "   ISR         = 0x%04x\n\r", Xil_In32(Xkrnl_ISR     ) );
    // printf( "   AXI_MM_DATA = 0x%04x\n\r", Xil_In32(Xkrnl_AXI_MM_ADDR) );
}

// Print each field of a control CSR word
void print_control_csr ( uint32_t csr_read_in ) {

    // Print fields
    printf("AP_CTRL = 0x%04x\n\r", csr_read_in);
    printf("    AP_START     =  0x%x \n\r", ( csr_read_in & AP_START    ) >> (AP_START_BIT    ));
    printf("    AP_DONE      =  0x%x \n\r", ( csr_read_in & AP_DONE     ) >> (AP_DONE_BIT     ));
    printf("    AP_IDLE      =  0x%x \n\r", ( csr_read_in & AP_IDLE     ) >> (AP_IDLE_BIT     ));
    printf("    AP_READY     =  0x%x \n\r", ( csr_read_in & AP_READY    ) >> (AP_READY_BIT    ));
    printf("    AP_CONTINUE  =  0x%x \n\r", ( csr_read_in & AP_CONTINUE ) >> (AP_CONTINUE_BIT ));
    printf("    AP_INTERRUPT =  0x%x \n\r", ( csr_read_in & AP_INTERRUPT) >> (AP_INTERRUPT_BIT));
}


void print_matrix (uint32_t data [DATA_SIZE*DATA_SIZE]) {
    for ( int i = 0; i < DATA_SIZE; i++ ) {
        for ( int j = 0; j < DATA_SIZE; j++ ) {
            printf("0x%08x ", data[i*DATA_SIZE + j]);
        }
        printf("\n\r");
    }
    printf("\n\r");
}

#define PRINT_LEAP 100000
int main() {

    // Control CSR
    uint32_t csr_read;
    uint32_t cnt;

    // Init platform
    uint32_t uart_base_address = (uint32_t) &_peripheral_UART_start;
    tinyIO_init(uart_base_address);

    // Allocate data
    // - A,B, hls_out    : 3 buffers of DATA_SIZE*DATA_SIZE elements
    #define HLS_BUFFER_SIZE ((3*DATA_SIZE*DATA_SIZE))
    // Align to read burst address span:
    // - must be a power of two
    #define HLS_BUFFER_ALIGN (4*DATA_SIZE*DATA_SIZE)
    uint32_t HLS_buffer[HLS_BUFFER_SIZE] __attribute__((aligned(HLS_BUFFER_ALIGN)));
    // Pointers to arguments
    uint32_t* A       = HLS_buffer + A_OFFSET;
    uint32_t* B       = HLS_buffer + B_OFFSET;
    uint32_t* hls_out = HLS_buffer + hls_out_OFFSET;
    uint32_t expected[DATA_SIZE*DATA_SIZE] = {0};

    printf("\n\r");
    printf("-----------------\n\r");
    printf("- HLS GEMM v1.1 -\n\r");
    printf("-----------------\n\r");
    printf("\n\r");

    printf("HLS_buffer:   0x%04x\n\r", (uint32_t) HLS_buffer);

    // Initializing input/output data
    initialize_data(A, B, hls_out);

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
            print_control_csr(csr_read);
        }
    } while ( ( csr_read & AP_IDLE ) != AP_IDLE );

    /////////////////////////
    // Starting the kernel //
    /////////////////////////

    // Writing input/output addresses
    Xil_Out32(Xkrnl_AXI_MM_ADDR, (uint32_t)HLS_buffer);
    // Raising ap_start to start the kernel
    Xil_Out32(Xkrnl_Control, AP_START);

    // Dump
    // dump_csrs();

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
            print_control_csr(csr_read);
        }
    } while ( ( csr_read & AP_DONE) != AP_DONE );

    printf("hls_out :\n\r"); print_matrix(hls_out );
    printf("expected:\n\r"); print_matrix(expected);

    // Checking results
    if ( check_results(expected, hls_out) == 0 ) {
        printf("Expected result ok!");
    }
    else {
        printf("ERROR! The result is not that expected");
    }


    return 0;

}