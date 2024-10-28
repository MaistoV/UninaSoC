// Author: Manuel Maddaluno <manuel.maddaluno@unina.it>

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
    off_t offset;
    off_t pa_offset;    /* page aligned offset */
    void * map;         /* virtual address from mmap */

    char c;             /* Char to send when write on the console */ 

    /* Get the arguments */
    write_thread_arg_t * thread_arg = (write_thread_arg_t *) arg;
    paddr  = thread_arg->paddr;
    length = thread_arg->length;
    offset = thread_arg->offset;

    /* Open the /dev/mem file */
    fd = open("/dev/mem", O_RDWR | O_SYNC);
    if (fd == -1) {
	    printf("ERROR: Cannot open device file\n");
	    goto end;
    }

    /* Compute the page aligned offset  */
    pa_offset = paddr+offset & ~(sysconf(_SC_PAGE_SIZE) - 1);
    
    /* Get the virtual address */
    map = mmap(NULL, length + paddr+offset - pa_offset, PROT_READ | PROT_WRITE, MAP_SHARED, fd, pa_offset);
    if (map == MAP_FAILED) {
        printf("ERROR: Map failed\n");
        goto end;
    }

    close(fd);


    while(1) {
        c = getchar();
        /* Wait for the RX full bit is 0 - the core read the previous char */
        while ( (*(uint32_t *) (map + 8) & RX_FULL_BIT_MASK) >> 1 == 1);
        *(char *) map = c;
    }

    end:
        if(map) 
            munmap(map, length + offset - pa_offset);
        if (fd)
            close(fd);
        return NULL;
}



void * read_thread_function( void * arg ) 
{
    int fd;
    uint64_t paddr;   
    size_t length;
    off_t offset;
    off_t pa_offset;    /* page aligned offset */
    void * map;         /* virtual address from mmap */
    unsigned int u_poll_period; 

    char c;           /* Char to send when write on the console */ 

    uint8_t status_tx_full = 0;

    /* Get the arguments */
    read_thread_arg_t * thread_arg = (read_thread_arg_t *) arg;
    paddr         = thread_arg->paddr;
    length        = thread_arg->length;
    offset        = thread_arg->offset;
    u_poll_period = thread_arg->u_poll_period;

    /* Open the /dev/mem file */
    fd = open("/dev/mem", O_RDWR | O_SYNC);
    if (fd == -1) {
	    printf("ERROR: Cannot open device file\n");
	    goto end;
    }

    /* Compute the page aligned offset  */
    pa_offset = paddr+offset & ~(sysconf(_SC_PAGE_SIZE) - 1);
    
    /* Get the virtual address */
    map = mmap(NULL, length + paddr+offset - pa_offset, PROT_READ | PROT_WRITE, MAP_SHARED, fd, pa_offset);
    if (map == MAP_FAILED) {
        printf("ERROR: Map failed\n");
        goto end;
    }

    while (1) {
        
        /* Poll on the status flag TX full */
        status_tx_full = ((*(uint8_t *)(map+8) & TX_FULL_BIT_MASK) >> 3);
        while( !status_tx_full ) {
            usleep(u_poll_period);
            status_tx_full = ((*(uint8_t *)(map+8) & TX_FULL_BIT_MASK) >> 3);
        }

        /* Directly read the data in the TX register, no need to check the status */
        c = *(char *) (map+4);
        putchar(c);

        /* ACK the interrupt */
        *(uint32_t *) (map+16) = 0x000000FF;
    }

    end:
        if(map) 
            munmap(map, length + offset - pa_offset);
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
    printf("------------------------------ VIRTUAL UART ----------------------------------- \n"); 
    printf("Usage: %s <uart_paddr> <uart_length> <offset> <u_poll_period>\n", ex_name); 
    printf("    uart_paddr    : UART physical address in hex 0x... (PCIe BAR)\n");
    printf("    uart_length   : UART register length in byte, always 20\n");
    printf("    offset        : UART offset, always 0\n");
    printf("    u_poll_period : Poll period in microseconds, 10 is good\n");
    printf("------------------------------------------------------------------------------- \n"); 
}


int main ( int argc, char *argv[] )
{

    pthread_t read_thread;
    pthread_t write_thread;

    write_thread_arg_t * write_thread_arg = (write_thread_arg_t *) malloc (sizeof(write_thread_arg_t));
    read_thread_arg_t * read_thread_arg = (read_thread_arg_t *) malloc (sizeof(read_thread_arg_t));

    if ( argc < 5 ) {
        help(argv[0]);
        return -1;
    }

    write_thread_arg->paddr = (uint64_t)strtol(argv[1], NULL, 0);
    write_thread_arg->length = atoi(argv[2]);
    write_thread_arg->offset = atoi(argv[3]);

    
    read_thread_arg->paddr = (uint64_t)strtol(argv[1], NULL, 0);
    read_thread_arg->length = atoi(argv[2]);
    read_thread_arg->offset = atoi(argv[3]);
    read_thread_arg->u_poll_period = atoi(argv[4]);


    /* Disable stdin buffering*/
    disable_buffering();
    setbuf(stdin, NULL);
    /* Disable stdout buffering */ 
    setbuf(stdout, NULL);

    if ( pthread_create(&write_thread, NULL, write_thread_function, (void *) write_thread_arg ) != 0 ) {
        printf("ERROR: pthread_create failed\n");
        enable_buffering();
        return -1;
    } 


    if ( pthread_create(&read_thread, NULL, read_thread_function, (void *) read_thread_arg) != 0 ) {
        printf("ERROR: pthread_create failed\n");
        enable_buffering();
        return -1;
    }
    

    pthread_join(write_thread, NULL);
    pthread_join(read_thread, NULL);

    enable_buffering();
	
    return 0;
}
