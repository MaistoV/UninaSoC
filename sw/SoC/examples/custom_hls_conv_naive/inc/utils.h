#include <stddef.h>
#include <stdlib.h> // For rand()
#include <stdint.h> // For bool

// Hw definitions
#include "xkrnl_conv_naive_hw.h"
#include "krnl_conv_naive.h"

// Init I and W tensors with random values
// Init O tensor with constant 0x55555555
void init_data (
                    target_type_t I[N][C][ Y][ X],
                    target_type_t W[K][C][ R][ S],
                    target_type_t O[N][K][Y1][X1]
                ) {

    // Init I
    for ( unsigned int n = 0; n < N; n++ )
            for ( unsigned int c = 0; c < C; c++ )
                for ( unsigned int y = 0; y < Y; y++ )
                    for ( unsigned int x = 0; x < X; x++ )
                            I[n][c][y][x] = y * x +1;

    // Init W
    for ( unsigned int k = 0; k < K; k++ )
            for ( unsigned int c = 0; c < C; c++ )
                for ( unsigned int r = 0; r < R; r++ )
                    for ( unsigned int s = 0; s < S; s++ )
                            W[k][c][s][r] =  r * s +1;

    // Init O
    for ( unsigned int n = 0; n < N; n++ )
            for ( unsigned int k = 0; k < K; k++ )
                for ( unsigned int y1 = 0; y1 < Y1; y1++ )
                    for ( unsigned int x1 = 0; x1 < X1; x1++ )
                            O[n][k][y1][x1] = 0x55555555;

}

// Compute expected result
void compute_expected (
                    target_type_t I[N][C][ Y][ X],
                    target_type_t W[K][C][ R][ S],
                    target_type_t expected[N][K][Y1][X1]
                ) {

    for ( unsigned int n = 0; n < N; n++ ) {
        for ( unsigned int k = 0; k < K; k++ ) {
            for ( unsigned int c = 0; c < C; c++ ) {
                for ( unsigned int y1 = 0; y1 < Y1; y1++ ) {
                    for ( unsigned int x1 = 0; x1 < X1; x1++ ) {
                        for ( unsigned int r = 0; r < R; r++ ) {
                            for ( unsigned int s = 0; s < S; s++ ) {
                                // O[n][k][y’][x’] += W[n][k][c][r][s] * I[n][c][y’+r][x’+s];
                                expected[n][k][y1][x1] += W[k][c][r][s] * I[n][c][y1+r][x1+s];
                            } // s < S
                        } // r < R
                    } // x1 < X1
                } // y1 < Y1
            } // c < C
        } // k < K
    } // n < N
}

// Compare two output tensors
int check_values (
                    target_type_t out     [N][K][Y1][X1],
                    target_type_t expected[N][K][Y1][X1]
                ) {

    // Compare
    for ( unsigned int n = 0; n < N; n++ ) {
        for ( unsigned int k = 0; k < K; k++ ) {
            for ( unsigned int y1 = 0; y1 < Y1; y1++ ) {
                for ( unsigned int x1 = 0; x1 < X1; x1++ ) {
                    if ( out[n][k][y1][x1] != expected[n][k][y1][x1] ) {
                        printf("[ERROR] Failing [%u,%u,%u,%u]: expected 0x%04x != 0x%04x\n\r",
                            n, k, y1, x1,
                            expected[n][k][y1][x1],
                            out     [n][k][y1][x1]
                        );
                        // Return immediately
                        return false;
                    }
                    printf("[INFO] Check [%u,%u,%u,%u]: expected 0x%04x == 0x%04x\n\r",
                            n, k, y1, x1,
                            expected[n][k][y1][x1],
                            out     [n][k][y1][x1]
                    );

                }
            }
        }
    }

    // No error occurred
    return true;
}
