// Author: Vincenzo Maisto <vincenzo.maisto2@unina.it>
// Description: Common header file for bare-metal measures

#ifndef __MEASURES_H_
#define __MEASURES_H_

// System libraries
#include <stdint.h>

// Print measure header
void print_meas_header( char* name ){
  // printf("%s, start, end, diff\n\r", name);
}

// Print measure sample
void print_meas( char* name, uint32_t sample, uint32_t start, uint32_t end ) {
  printf("data: %s, %u, %u, %u, %u\n\r",
          name,
          sample,
          start,
          end,
          end - start
      );
}

// Stringify app names
#define STRINGIFY2(X) #X
#define STRINGIFY(X) STRINGIFY2(X)

// Concat macros
#define CAT_HELPER(x, y) x##y
#define CAT(x, y) CAT_HELPER(x, y)

// Helper macros for concat
#define _init _init
#define _main _main
#define _return _return

// Number of runs
// NOTE: For these experiments, the number of runs is determitic for each kernel
#define NUM_RUNS 1

// Run application
#define RUN_APP(app_name) \
      CAT(app_name,_init ());  \
      CAT(app_name,_main ());

// Return function
#define RETURN(app_name) return( CAT(app_name,_return ()) );

// Main program structure
#define MAIN_APP(app_name)                            \
    int main( void ) {                                \
      uint32_t mcycle_start;                          \
      uint32_t mcycle_end;                            \
      uninasoc_init();                                \
      print_meas_header(STRINGIFY(app_name));         \
      for ( uint32_t i = 0; i < NUM_RUNS; i++ ) {     \
        mcycle_start = get_mcycle();                  \
        RUN_APP(app_name);                            \
        mcycle_end = get_mcycle();                    \
        print_meas(                                   \
              STRINGIFY(app_name),                    \
              i,                                      \
              mcycle_start,                           \
              mcycle_end                              \
          );                                          \
      }                                               \
      RETURN(app_name);                               \
    }                                                 \

#endif // __MEASURES_H_