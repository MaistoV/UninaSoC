// Author: Vincenzo Maisto <vincenzo.maisto2@unina.it>
// Description:
//  HLS implementation of a CONV2D engine.
//  Version opt6: Wide M_AXI port for HBUS.

// Headers
#include <stdio.h>  // For printf()
#include <assert.h> // For assert()
#include "krnl_conv_opt6.h"

void krnl_conv_opt6 (
                    m_axi_port_type_t * I,
                    m_axi_port_type_t * W,
                    m_axi_port_type_t * O,
                    uint8_t N_input,
                    uint8_t C_input,
                    uint8_t K_input
                ) {

    #pragma HLS INTERFACE mode=m_axi depth=(SIZE_I/sizeof(m_axi_port_type_t)) bundle=gmem0 port=I \
        max_read_burst_length=16 \
        max_widen_bitwidth=512 \
        max_write_burst_length=16

    #pragma HLS INTERFACE mode=m_axi depth=(SIZE_W/sizeof(m_axi_port_type_t)) bundle=gmem0 port=W \
        max_read_burst_length=16 \
        max_widen_bitwidth=512 \
        max_write_burst_length=16

    #pragma HLS INTERFACE mode=m_axi depth=(SIZE_O/sizeof(m_axi_port_type_t)) bundle=gmem0 port=O \
        max_read_burst_length=16 \
        max_widen_bitwidth=512 \
        max_write_burst_length=16 \
        num_read_outstanding=16

    // Help the compiler infer minimum loop iterations
    assert ( N_input > 0 );
    assert ( K_input > 0 );
    assert ( C_input > 0 );


    // Pre-fetch data
    m_axi_port_type_t I_fetch_line = 0;

    // For input batch size
    for ( uint8_t n = 0; n < N_input; n++ ) {
        // For output batch size
        for ( uint8_t k = 0; k < K_input; k++ ) {
            // Reset accumulator
            target_type_t accumulator[Y1 * X1] = {0};

            // For each input channel
            for ( uint8_t c = 0; c < C_input; c++ ) {
                m_axi_port_type_t W_fetch_line = 0;
                // Local buffers for W [K][C][R][S]
                target_type_t W_local [R * S];
                // Preload buffer
                for ( uint8_t rs = 0; rs < R * S; rs++ ) {
                    #define INDEX_W ( ( ( k * C_input ) + c ) * R * S + rs )
                    #define INDEX_W_LOCAL ( rs )
                    W_local [INDEX_W_LOCAL] = W [INDEX_W];
                    #undef INDEX_W_LOCAL
                } // rs < R * S

                // For I dimensions Y1 and X1
                for ( uint8_t y1 = 0; y1 < Y1; y1++ ) {
                    for ( uint8_t x1 = 0; x1 < X1; x1++ ) {
                        // Compute
                        for ( uint8_t r = 0; r < R; r++ ) {
                            for ( uint8_t s = 0; s < S; s++ ) {
                                #define INDEX_W_LOCAL ( r * S + s )
                                #define INDEX_I ( ( ( ( n * C_input ) + c ) * Y + (y1+r) ) * X + (x1+s) )
                                #define INDEX_ACC ( y1 * X1 + x1 )
                                accumulator[INDEX_ACC] += W_local [INDEX_W_LOCAL] * I [INDEX_I];
                                #undef INDEX_W_LOCAL
                            } // s < S
                        } // r < R
                    } // x1 < x1
                } // y1 < Y1
            } // c < C

            // Store result
            for ( uint8_t y1x1 = 0; y1x1 < Y1 * X1; y1x1++ ) {
                #define INDEX_O ( ( ( n * K_input ) + k ) * Y1 * X1 + y1x1 )
                O [ INDEX_O ] = accumulator [y1x1];
            } // y1x1 < Y1 * X1
        } // k < K
    } // n < N
} // krnl_conv_opt6()