// Author: Manuel Maddaluno <manuel.maddaluno@unina.it>
// Description: Virtual Uart host application - main
//              This is a two-posix-thread application. 
//              The write_thread writes on the RX uart register (writes to the core) 
//              The read_thread reads on the TX uart register (reads from the host) polling with u_poll_period microseconds           

#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>
#include "virtual_uart.h"

int main ( int argc, char *argv[] )
{

    pthread_t read_thread;
    pthread_t write_thread;

    write_thread_arg_t * write_thread_arg = (write_thread_arg_t *) malloc (sizeof(write_thread_arg_t));
    read_thread_arg_t * read_thread_arg = (read_thread_arg_t *) malloc (sizeof(read_thread_arg_t));

    if ( argc < 2 ) {
        help(argv[0]);
        return -1;
    }

    write_thread_arg->paddr = (uint64_t)strtol(argv[1], NULL, 0);
    write_thread_arg->length = atoi(argv[2]);

    read_thread_arg->paddr = (uint64_t)strtol(argv[1], NULL, 0);
    read_thread_arg->length = atoi(argv[2]);
    read_thread_arg->u_poll_period = atoi(argv[3]);


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