#include "krnl_matmul.h"

#include <string.h> // For memcpy
#include <stdio.h>  // For printf

void krnl_matmul (
                    volatile uint32_t * A,
                    volatile uint32_t * B,
                    volatile uint32_t * C
                ) {

    #pragma HLS INTERFACE mode=m_axi depth=SIZE_MM bundle=gmem0 port=A
    #pragma HLS INTERFACE mode=m_axi depth=SIZE_MM bundle=gmem0 port=B
    #pragma HLS INTERFACE mode=m_axi depth=SIZE_MM bundle=gmem0 port=C
    // TODO: more properties for m_axi
    // max_read_burst_length=16
    // max_widen_bitwidth=512 max_write_burst_length=16 num_read_outstanding=16
    // num_write_outstanding=16
    // see also https://github.com/Xilinx/Vitis-HLS-Introductory-Examples/blob/master/Interface/Memory/burst_rw/vadd.cpp

    // Local buffers
    uint32_t A_row [DATA_SIZE];
    uint32_t B_col [DATA_SIZE];

    #pragma HLS DATAFLOW
    for (uint32_t i=0; i<DATA_SIZE; i++) {
        #pragma HLS LOOP_TRIPCOUNT min = DATA_SIZE max = DATA_SIZE

        // Start a burst with memcpy
        #define BURST_SIZE_BYTES DATA_SIZE * sizeof(uint32_t)
        #define A_STRIDE DATA_SIZE
        // memcpy((uint32_t*)A_row, (const uint32_t*)(A + i*A_STRIDE), BURST_SIZE_BYTES);
        for ( uint32_t ii = 0; ii < DATA_SIZE; ii++ ) {
            A_row[ii] = A[ii + i*A_STRIDE];
        }
        printf("A_row %u: ", i); for ( uint32_t ii = 0; ii < DATA_SIZE; ii++ ) { printf("0x%03x ", A_row[ii]); } printf("\n");

        // Local buffer
        uint32_t C_row [DATA_SIZE] = {0};
        for (uint32_t j=0; j<DATA_SIZE; j++) {
            #pragma HLS LOOP_TRIPCOUNT min = DATA_SIZE max = DATA_SIZE

            // Load strided B col in local buffer
            #define B_STRIDE DATA_SIZE
            for (uint32_t ii=0; ii<DATA_SIZE; ii++) { B_col[ii] = B[j + ii*B_STRIDE]; }
            printf("B_col %u: ", j); for ( uint32_t ii = 0; ii < DATA_SIZE; ii++ ) { printf("0x%03x ", B_col[ii]); } printf("\n");

            // Reset accumulator
            uint32_t outsum = 0;
            for (uint32_t k=0; k<DATA_SIZE; k++) {
                #pragma HLS LOOP_TRIPCOUNT min = DATA_SIZE max = DATA_SIZE
                // Accumulate
                outsum += A_row[k] * B_col[k];
            }
            // Save result locally
            C_row[j] = outsum;
            C[i*DATA_SIZE + j] = outsum;
        }

        // Store result, with anoter burst
        #define BURST_SIZE_BYTES DATA_SIZE * sizeof(uint32_t)
        // memcpy((uint32_t*)(C + i*DATA_SIZE), (uint32_t*)C_row, BURST_SIZE_BYTES);
        printf("C_row %u: ", i); for ( uint32_t ii = 0; ii < DATA_SIZE; ii++ ) { printf("0x%03x ", C_row[ii]                ); } printf("\n");
        printf("C     %u: ", i); for ( uint32_t ii = 0; ii < DATA_SIZE; ii++ ) { printf("0x%03x ", (C + i*DATA_SIZE)[ii]    ); } printf("\n");
    }
}