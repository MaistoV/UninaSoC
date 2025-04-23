// Author: Vincenzo Maisto <vincenzo.maisto2@unina.it>
// Description:
//  HLS implementation of a CONV2D engine.
//  Version naive: No optimization, memory coalescing disabled with "volatile"

// Headers
#include <stdio.h>  // For printf()
#include "krnl_conv_naive.h"

void krnl_conv_naive (
                    volatile target_type_t * I,
                    volatile target_type_t * W,
                    volatile target_type_t * O,
                    uint8_t N_input,
                    uint8_t C_input,
                    uint8_t K_input
                ) {

    #pragma HLS INTERFACE mode=m_axi depth=SIZE_I bundle=gmem0 port=I
    #pragma HLS INTERFACE mode=m_axi depth=SIZE_W bundle=gmem0 port=W
    #pragma HLS INTERFACE mode=m_axi depth=SIZE_O bundle=gmem0 port=O
    // TODO: more properties for m_axi
    // max_read_burst_length=16
    // max_widen_bitwidth=512 max_write_burst_length=16 num_read_outstanding=16
    // num_write_outstanding=16
    // see also https://github.com/Xilinx/Vitis-HLS-Introductory-Examples/blob/master/Interface/Memory/burst_rw/vadd.cpp


    // Local buffers
    // target_type_t P [DATA_SIZE];

//  Input-Centric Loop
// for(n=0; n<2; n++)
//  for(k=0; k<4; k++)
//     for(c=0; c<6; c++)
//         for(y=0; y<8; y++)
//             for(x=0; x<8; x++)
//                 for(r=0; r<3; r++)
//                     for(s=0; s<3; s++)
//                         O[k][y-r][x-s] += W[k][c][r][s] * I[c][y][x];


// Output-Centric Loop
// for(n=0; n<2; n++)
//     for(k=0; k<4; k++)
//         for(c=0; c<6; c++)
//         for(y’=0; y’<6; y’++)
//             for(x’=0; x’<6; x’++)
//                 for(r=0; r<3; r++)
//                     for(s=0; s<3; s++)
//                         O[k][y’][x’] += W[k][c][r][s] * I[c][y’+r][x’+s];

    #pragma HLS DATAFLOW
    // for ( uint8_t n = 0; n < N; n++ ) {
    //     for ( uint8_t k = 0; k < K; k++ ) {
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