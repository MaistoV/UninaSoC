// Author: Manuel Maddaluno <manuel.maddaluno@unina.it>
// Description: Virtual Uart host application - threads
//              This is a two-posix-thread application.
//              The write_thread writes on the RX uart register (writes to the core)
//              The read_thread reads on the TX uart register (reads from the host) polling with u_poll_period microseconds

#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h>
#include <unistd.h>
#include <pthread.h>
#include <sys/mman.h>
#include <stdint.h>
#include "virtual_uart.h"
#include "threads.h"

void * write_thread_function(void * arg)
{
    int fd;
    uint64_t paddr;
    size_t length;
    off_t pa_offset;                    /* page aligned offset */
    virtual_uart_t * virtual_uart;      /* virtual address from mmap */

    char c;                             /* Char to send when write on the console */

    /* Get the arguments */
    write_thread_arg_t * thread_arg = (write_thread_arg_t *) arg;
    paddr  = thread_arg->paddr;
    length = thread_arg->length;

    /* Open the /dev/mem file */
    fd = open("/dev/mem", O_RDWR | O_SYNC);
    if (fd == -1) {
	    printf("ERROR: Cannot open device file\n");
	    goto end;
    }

    /* Compute the page aligned offset  */
    pa_offset = paddr & ~(sysconf(_SC_PAGE_SIZE) - 1);

    /* Get the virtual address */
    virtual_uart = (virtual_uart_t *) mmap(NULL, length + paddr - pa_offset, PROT_READ | PROT_WRITE, MAP_SHARED, fd, pa_offset);
    if (virtual_uart == MAP_FAILED) {
        printf("ERROR: Map failed\n");
        goto end;
    }

    close(fd);


    while(1) {
        /* Get the char from the console - blocking function */
        c = getchar();
        /* Transmit the char - blocking function */
        virtual_uart_tx_char( virtual_uart, c );
    }

    end:
        if(virtual_uart)
            munmap((void *)virtual_uart, length + paddr - pa_offset);
        if (fd)
            close(fd);
        return NULL;
}


void * read_thread_function( void * arg )
{
    int fd;
    uint64_t paddr;
    size_t length;
    off_t pa_offset;                       /* page aligned offset */
    virtual_uart_t * virtual_uart;         /* virtual address from mmap */
    unsigned int u_poll_period;

    char c;                                /* Char to send when write on the console */

    /* Get the arguments */
    read_thread_arg_t * thread_arg = (read_thread_arg_t *) arg;
    paddr         = thread_arg->paddr;
    length        = thread_arg->length;
    u_poll_period = thread_arg->u_poll_period;

    /* Open the /dev/mem file */
    fd = open("/dev/mem", O_RDWR | O_SYNC);
    if (fd == -1) {
	    printf("ERROR: Cannot open device file\n");
	    goto end;
    }

    /* Compute the page aligned offset  */
    pa_offset = paddr & ~(sysconf(_SC_PAGE_SIZE) - 1);

    /* Get the virtual address */
    virtual_uart = (virtual_uart_t *) mmap(NULL, length + paddr - pa_offset, PROT_READ | PROT_WRITE, MAP_SHARED, fd, pa_offset);
    if (virtual_uart == MAP_FAILED) {
        printf("ERROR: Map failed\n");
        goto end;
    }

    /* Virtual uart init - simply ack the SoC we are here waiting for it */
    virtual_uart_init (virtual_uart);

    while (1) {
        /* Receive the char - blocking function */
        c = virtual_uart_rx_char(virtual_uart, u_poll_period);
        /* Print the char on the console */
        putchar(c);

        /* ACK the interrupt */
        // virtual_uart->int_ack_reg = 0x000000FF;
    }

    end:
        if(virtual_uart)
            munmap((void *)virtual_uart, length + paddr - pa_offset);
        if (fd)
            close(fd);
        return NULL;
}
