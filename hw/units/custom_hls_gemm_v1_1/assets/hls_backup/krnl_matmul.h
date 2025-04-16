#ifndef __KRNL_MATMUL_H__
#define __KRNL_MATMUL_H__

#include <stdint.h>
#include <hls_stream.h>

#define DATA_SIZE 4

#define OFFSET_A 0
#define OFFSET_B DATA_SIZE*DATA_SIZE
#define OFFSET_C 2*DATA_SIZE*DATA_SIZE

#define SIZE_MM DATA_SIZE*DATA_SIZE

void krnl_matmul (
                    volatile uint32_t * A,
                    volatile uint32_t * B,
                    volatile uint32_t *       C
                ) ;

#endif