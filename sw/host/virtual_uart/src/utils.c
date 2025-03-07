// Author: Manuel Maddaluno <manuel.maddaluno@unina.it>
// Description: Virtual Uart host application - utility functions

#include <stdio.h>
#include <unistd.h>
#include <termios.h>
#include "utils.h"

/* Disable stdin buffering */
void disable_buffering ()
{
    struct termios t;
    tcgetattr(STDIN_FILENO, &t);           // Get current terminal settings
    t.c_lflag &= ~ICANON;                  // Disable canonical mode (line buffering)
    t.c_lflag |= ECHO;                     // Enable echo so typed characters appear
    tcsetattr(STDIN_FILENO, TCSANOW, &t);  // Apply new terminal settings
}

/* Enable stdin buffering */
void enable_buffering ()
{
    struct termios t;
    tcgetattr(STDIN_FILENO, &t);           // Get current terminal settings
    t.c_lflag |= ICANON;                   // Enable canonical mode
    t.c_lflag |= ECHO;                     // Ensure echo is re-enabled
    tcsetattr(STDIN_FILENO, TCSANOW, &t);  // Apply new terminal settings
}

/* Help function */
void help (char * ex_name)
{
    printf("------------------------------ VIRTUAL UART ------------------------------------- \n");
    printf("Usage: %s <uart_paddr> [uart_length] [u_poll_period]\n", ex_name);
    printf("    uart_paddr    : UART physical address in hex 0x... (PCIe BAR)\n");
    printf("    uart_length   : UART total registers length in byte (decimal), default 20\n");
    printf("    u_poll_period : Poll period in microseconds, default 10\n");
    printf("--------------------------------------------------------------------------------- \n");
}