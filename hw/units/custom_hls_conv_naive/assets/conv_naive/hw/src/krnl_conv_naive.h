#ifndef __CONV_NAIVE_H__
#define __CONV_NAIVE_H__

#include <stdint.h> // uint32_t

///////////////////////////
// Notation from MAESTRO //
///////////////////////////

// Tensor Dimension Notation
// Input Batch      N
#define  N 1
// Output Channel   K
#define  K 4
// Input Channel    C
#define  C 6
// Input Row        Y
#define  Y 8
// Input Column     X
#define  X 8
// Filter Row       R
#define  R 3
// Filter Column    S
#define  S 3
// Output Row       Y’
#define Y1 6
// Output Column    X’
#define X1 6

// Tensor               Tensor Index
// Input Activation     I [n][c][y][s]
// Filter Weight        W [k][c][r][s]
// Partial Sum          P [n][k][c][y’][x’][r][s]
// Output Activation    O [n][k][y’][x’]

// Tensor sizes
#define SIZE_I ( N  *  C  *  Y  *  X )
#define SIZE_W ( K  *  C  *  R  *  S )
#define SIZE_O ( N  *  K  * Y1  * X1 )

typedef uint32_t target_type_t;

void krnl_conv_naive (
                    volatile target_type_t * I,
                    volatile target_type_t * W,
                    volatile target_type_t * O
                );


void init_data (
                    target_type_t I[N][C][ Y][ X],
                    target_type_t W[K][C][ R][ S],
                    target_type_t O[N][K][Y1][X1]
                );

void compute_expected (
                    target_type_t I[N][C][ Y][ X],
                    target_type_t W[K][C][ R][ S],
                    target_type_t expected[N][K][Y1][X1]
                );

int check_values (
                    target_type_t out     [N][K][Y1][X1],
                    target_type_t expected[N][K][Y1][X1]
                );


#endif // __CONV_NAIVE_H__