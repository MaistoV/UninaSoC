// Author: Vincenzo Maisto <vincenzo.maisto2@unina.it>
// Description: Using -nostdlib is not sufficient, this file provides local implementations of compiler-inferred functions

#ifndef __STDLIB_H_
#define __STDLIB_H_

// System libraries
#include <stdint.h>
#include <stddef.h>

// Local memcpy (byte-wise unoptimized)
void* memcpy(void *dest, const void *src, size_t n) {
  for (size_t i = 0; i < n; i++) {
      ((char*)dest)[i] = ((char*)src)[i];
  }
}

// Local memset (from https://github.com/gcc-mirror/gcc/blob/master/libiberty/memset.c)
void * memset (void *dest, register int val, register size_t len) {
  register unsigned char *ptr = (unsigned char*)dest;
  while (len-- > 0)
    *ptr++ = val;
  return dest;
}

#endif // __STDLIB_H_
