// Author: Manuel Maddaluno <manuel.maddaluno@unina.it>
// Description: Virtual uart host application header file

#ifndef VIRTUAL_UART_H__
#define VIRTUAL_UART_H__

/* Masks */
#define RX_FULL_BIT_MASK 0x00000002
#define TX_FULL_BIT_MASK 0b00001000

/* UART registers struct */
typedef volatile struct {
    uint32_t rx_reg;            /* RX register - host to core   */
    uint32_t tx_reg;            /* TX register - core to host   */
    uint32_t sts_reg;           /* Status register              */
    uint32_t ctrl_reg;          /* Control register             */
    uint32_t int_ack_reg;       /* Interrupt ack - host to XDMA */
} uart_csr;

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

/* Utility functions */
void disable_buffering();
void enable_buffering();
void help(char * ex_name);

#endif