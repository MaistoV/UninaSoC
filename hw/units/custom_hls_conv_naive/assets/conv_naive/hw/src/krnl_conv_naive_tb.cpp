#include "krnl_conv_naive.h"
#include <stdio.h> // For printf()

// NOTE: Dirty workaround to Vitis HLS project configuration. Just include the source file here.
#ifndef __UTILS_C_
#define __UTILS_C_
    #include "utils.h"
#endif // __UTILS_C_

int main(int argc, const char **argv) {

    // Pre-allocate tensors
    target_type_t I       [N][C][ Y][ X];
    target_type_t W       [K][C][ R][ S];
    target_type_t O       [N][K][Y1][X1];
    target_type_t expected[N][K][Y1][X1] = {0};

    // Init
    printf("[INFO] Init data\n");
    init_data(I, W, O);

    // Compute locally
    printf("[INFO] Compute expected\n");
    compute_expected(I, W, expected);

    // Call to kernel
    printf("[INFO] Call to kernel\n");
    krnl_conv_naive(
            (target_type_t*)I,
            (target_type_t*)W,
            (target_type_t*)O
        );


    // // Check result
    printf("[INFO] Checking results...\n");
    bool result = check_values(O, expected);
    if ( !result ) {
        printf("[ERROR] Check failed!\n");
        return 1;
    }
    else {
        printf("[INFO] Check successful!\n");
    }

    return 0;

}