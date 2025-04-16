#include <iostream>
#include "krnl_matmul.h"
using namespace std;

bool check_values(uint32_t *out, uint32_t *expected) {

    // Compare
    for (int i=0; i<DATA_SIZE; i++) {
        for(int j=0; j<DATA_SIZE; j++) {
            if (out[i*DATA_SIZE + j] != expected[i*DATA_SIZE + j]) {
                printf("Failing [%u,%u]: 0x%x != 0x%x\n",
                    i,
                    j,
                    out[i*DATA_SIZE + j],
                    expected[i*DATA_SIZE + j]
                );
                return false;
            }
        }
    }
    return true;
}

// Print DATA_SIZE x DATA_SIZE matrix
void print_matrix (uint32_t data [DATA_SIZE*DATA_SIZE]) {
    for ( int i = 0; i < DATA_SIZE; i++ ) {
        for ( int j = 0; j < DATA_SIZE; j++ ) {
            printf("0x%03x ", data[i*DATA_SIZE + j]);
        }
        printf("\n\r");
    }
}

int main(int argc, const char **argv) {

    // Pre-allocate
    uint32_t A [SIZE_MM];
    uint32_t B [SIZE_MM];
    uint32_t C [SIZE_MM];
    uint32_t expected[DATA_SIZE][DATA_SIZE] = {0};

    // Init
    for (int i=0; i<DATA_SIZE; i++) {
        for (int j=0; j<DATA_SIZE; j++) {
            A[i*DATA_SIZE + j] = i*DATA_SIZE + j +2;
            B[i*DATA_SIZE + j] = j*DATA_SIZE + i +2;
            C[i*DATA_SIZE + j] = 0x55555555;
        }
    }

    // Compute locally
    for (int i=0; i<DATA_SIZE; i++) {
        for (int j=0; j<DATA_SIZE; j++) {
            for ( int k = 0; k < DATA_SIZE; k++ ) {
                expected[i][j] += A[i*DATA_SIZE + k] * B[k*DATA_SIZE + j];
            }
        }
    }


    // Dump source data
    printf("A         0x%p:\n\r", A); print_matrix((uint32_t*)A);
    printf("B         0x%p:\n\r", B); print_matrix((uint32_t*)B);

    // Call to kernel
    krnl_matmul(A, B, C);

    // Dump
    printf("hls_out  0x%p:\n\r", C       ); print_matrix((uint32_t*)C       );
    printf("expected 0x%p:\n\r", expected); print_matrix((uint32_t*)expected);

    // Check result
    bool result = check_values((uint32_t*)C, (uint32_t*)expected);
    if ( !result ) {
        printf("Check failed!\n");
        return 1;
    }
    else {
        printf("Check successful!\n");
    }

    return 0;

}