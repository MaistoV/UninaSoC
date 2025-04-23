// Author: Vincenzo Maisto <vincenzo.maisto2@unina.it>
// Description:
//  HLS implementation of a CONV2D engine.
//  Version opt1: Memory coalescing, i.e. bursts.

// Headers
#include <stdio.h>  // For printf()
#include "krnl_conv_opt1.h"

void krnl_conv_opt1 (
                    target_type_t * I,
                    target_type_t * W,
                    target_type_t * O,
                    uint8_t N_input,
                    uint8_t C_input,
                    uint8_t K_input
                ) {

    #pragma HLS INTERFACE mode=m_axi depth=SIZE_I bundle=gmem0 port=I \
        max_read_burst_length=16 \
        max_widen_bitwidth=512 \
        max_write_burst_length=16 \
        num_read_outstanding=16

    #pragma HLS INTERFACE mode=m_axi depth=SIZE_W bundle=gmem0 port=W \
        max_read_burst_length=16 \
        max_widen_bitwidth=512 \
        max_write_burst_length=16 \
        num_read_outstanding=16

    #pragma HLS INTERFACE mode=m_axi depth=SIZE_O bundle=gmem0 port=O \
        max_read_burst_length=16 \
        max_widen_bitwidth=512 \
        max_write_burst_length=16 \
        num_read_outstanding=16

    for ( uint8_t n = 0; n < N_input; n++ ) {
        for ( uint8_t k = 0; k < K_input; k++ ) {
            for ( uint8_t y1 = 0; y1 < Y1; y1++ ) {
                for ( uint8_t x1 = 0; x1 < X1; x1++ ) {
                    // Reset accumulator
                    target_type_t accumulator = 0;
                    // Compute
                    // for ( uint8_t c = 0; c < C; c++ ) {
                    for ( uint8_t c = 0; c < C_input; c++ ) {
                        for ( uint8_t r = 0; r < R; r++ ) {
                            for ( uint8_t s = 0; s < S; s++ ) {
                                #define INDEX_W ( ( ( ( k * C_input ) + c ) * R + r ) * S + s )
                                #define INDEX_I ( ( ( ( n * C_input ) + c ) * Y + (y1+r) ) * X + (x1+s) )
                                accumulator += W [INDEX_W] * I [INDEX_I];
                                    // ((target_type_t(*)[C][R][S])W)[k][c][r][s] *
                                    // ((target_type_t(*)[C][Y][X])I)[n][c][y1+r][x1+s];
                            } // s < S
                        } // r < R
                    } // c < C
                    // Store result
                    #define INDEX_O ( ( ( ( n * K_input ) + k ) * Y1 + y1 ) * X1 + x1 )
                    // ((target_type_t(*)[K][Y1][X1])O)[n][k][y1][x1] = accumulator;
                    O [ INDEX_O ] = accumulator;
                } // x1 < x1
            } // y1 < Y1
        } // k < K
    } // n < N


        // printf("C     %u: ", i); for ( uint8_t ii = 0; ii < DATA_SIZE; ii++ ) { printf("0x%03x ", (C + i*DATA_SIZE)[ii]    ); } printf("\n");
}