// Author: Manuel Maddaluno <manuel.maddaluno@unina.it>
// Description: Virtual uart threads header file

#ifndef THREADS_H__
#define THREADS_H__

/* Threads arguments */
typedef struct {
    uint64_t paddr;               /* PCIe BAR of the uart device */
    size_t length;                /* The length of the mapping   */
} write_thread_arg_t;

typedef struct {
    uint64_t paddr;               /* PCIe BAR of the uart device */
    size_t length;                /* The length of the mapping   */
    unsigned int u_poll_period;   /* Poll period in microseconds */   
} read_thread_arg_t;

/* Threads functions */
void * write_thread_function(void * arg);
void * read_thread_function(void * arg);


#endif