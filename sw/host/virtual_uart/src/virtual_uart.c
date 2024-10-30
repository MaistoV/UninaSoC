// Author: Manuel Maddaluno <manuel.maddaluno@unina.it>
// Description: Virtual Uart host application - utility functions
//              This is a two-posix-thread application. 
//              The write_thread writes on the RX uart register (writes to the core) 
//              The read_thread reads on the TX uart register (reads from the host) polling with u_poll_period microseconds           

#include <fcntl.h>
#include <poll.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h>
#include <unistd.h>
#include <pthread.h>
#include <sys/mman.h>
#include <stdint.h>
#include <termios.h>
#include "virtual_uart.h"

void * write_thread_function(void * arg) 
{
    int fd;
    uint64_t paddr;
    size_t length;
    off_t pa_offset;     /* page aligned offset */
    uart_csr * map;      /* virtual address from mmap */

    char c;              /* Char to send when write on the console */ 

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
    map = (uart_csr *) mmap(NULL, length + paddr - pa_offset, PROT_READ | PROT_WRITE, MAP_SHARED, fd, pa_offset);
    if (map == MAP_FAILED) {
        printf("ERROR: Map failed\n");
        goto end;
    }

    close(fd);


    while(1) {
        c = getchar();
        /* Wait for the RX full bit is 0 - the core read the previous char */
        while ( ( (map->sts_reg) & RX_FULL_BIT_MASK) >> 1 == 1);
        map->rx_reg = (uint32_t) c;
    }

    end:
        if(map) 
            munmap((void *)map, length + paddr - pa_offset);
        if (fd)
            close(fd);
        return NULL;
}



void * read_thread_function( void * arg ) 
{
    int fd;
    uint64_t paddr;   
    size_t length;
    off_t pa_offset;    /* page aligned offset */
    uart_csr * map;         /* virtual address from mmap */
    unsigned int u_poll_period; 

    char c;           /* Char to send when write on the console */ 

    uint8_t status_tx_full = 0;

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
    map = (uart_csr *) mmap(NULL, length + paddr - pa_offset, PROT_READ | PROT_WRITE, MAP_SHARED, fd, pa_offset);
    if (map == MAP_FAILED) {
        printf("ERROR: Map failed\n");
        goto end;
    }

    while (1) {
        
        /* Poll on the status flag TX full */
        status_tx_full = (((uint8_t)map->sts_reg & TX_FULL_BIT_MASK) >> 3);
        while( !status_tx_full ) {
            usleep(u_poll_period);
            status_tx_full = (((uint8_t)map->sts_reg & TX_FULL_BIT_MASK) >> 3);
        }

        /* Directly read the data in the TX register, no need to check the status */
        c = (char) map->tx_reg;
        putchar(c);

        /* ACK the interrupt */
        map->int_ack_reg = 0x000000FF;
    }

    end:
        if(map) 
            munmap((void *)map, length + paddr - pa_offset);
        if (fd)
            close(fd);
        return NULL;
}


void disable_buffering () 
{
    struct termios t;
    tcgetattr(STDIN_FILENO, &t);           // Get current terminal settings
    t.c_lflag &= ~ICANON;                  // Disable canonical mode (line buffering)
    t.c_lflag |= ECHO;                     // Enable echo so typed characters appear
    tcsetattr(STDIN_FILENO, TCSANOW, &t);  // Apply new terminal settings
}

void enable_buffering () 
{
    struct termios t;
    tcgetattr(STDIN_FILENO, &t);           // Get current terminal settings
    t.c_lflag |= ICANON;                   // Enable canonical mode
    t.c_lflag |= ECHO;                     // Ensure echo is re-enabled
    tcsetattr(STDIN_FILENO, TCSANOW, &t);  // Apply new terminal settings
}


void help (char * ex_name)
{
    printf("------------------------------ VIRTUAL UART ------------------------------------- \n"); 
    printf("Usage: %s <uart_paddr> [uart_length] [u_poll_period]\n", ex_name); 
    printf("    uart_paddr    : UART physical address in hex 0x... (PCIe BAR)\n");
    printf("    uart_length   : UART total registers length in byte (decimal), default 20\n");
    printf("    u_poll_period : Poll period in microseconds, default 10\n");
    printf("--------------------------------------------------------------------------------- \n"); 
}