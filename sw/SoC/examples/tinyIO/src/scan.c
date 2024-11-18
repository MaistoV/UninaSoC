/*
 * mini-scanf - Minimal scanf() implementation for embedded projects. 
 * Copyright (c) 2023 Aleksej Muratov
 */
#include "scan.h"
#include <stdint.h>
#include "tinyIO.h"
// implementation of basic dependencies
// std
int c_isspace(const char c)
{
	switch (c)
	{ /* in the "C" locale: */
		case ' ': /* space */
		case '\f': /* form feed */
		case '\n': /* new-line */
		case '\r': /* carriage return */
		case '\t': /* horizontal tab */
		case '\v': /* vertical tab */
			return 1;
		default:
			return 0;
	}
}

// std
int	c_isdigit(int c)
{
	if (c >= '0' && c <= '9')
		return (1);
	else
		return (0);
}

// parodies the standard
#ifdef C_SSCANF
	#define NEXTCHAR (PointBuf++)
	#define CURCHAR (buff[PointBuf])
	int c_sscanf(const char* buff, char* format, ...)
#else
	#define NEXTCHAR (charBuf=c_getch())
	#define CURCHAR (charBuf)
	int c_scanf(char* format, ...)
#endif
{
	int count = 0;

	#ifdef C_SSCANF
		int PointBuf = 0;
	#else
		char charBuf = c_getch();
	#endif

	int PointFt = 0;

 va_list ap;
 va_start(ap, format);

    while (format && format[PointFt])
    {
        if (format[PointFt] == '%')
        {
            PointFt++;
            bool save = true;

            if (format[PointFt] == '*')
            {
                save = false;
                PointFt++;
            }

            unsigned len = 0;
            bool lenEn = false;

            while (c_isdigit(format[PointFt]))
            {
                lenEn = true;
                len *= 10;
                len += (format[PointFt] - '0');
                PointFt++;
            }

            char stop[LENSCANS];
            unsigned stopN = 0;

            if (format[PointFt] == '[')
            {
              //  PointFt++;
                while (format[PointFt] != ']')
                {
                    if(format[PointFt] != '[')
                    {
                        stop[stopN] = format[PointFt];
                        stopN++;
                    }    
                    PointFt++;
                }
            }

            switch (format[PointFt])
            {
                case 'c':
                    while (c_isspace(CURCHAR)) // ignor isspace (std)
                        NEXTCHAR; //
                    if (save)
                        *(char*)va_arg(ap, char*) = CURCHAR;
                    NEXTCHAR;
                    //if (save) // ignore %* (std)
                        count++;
                    break;
                
                case 'u':
                case 'd':
                {
                    // Implementazione per %u e %d
                    int sign = 1;
                    while (!c_isdigit(CURCHAR))
                    {
                       if (CURCHAR == '+' || CURCHAR == '-')
                            if (CURCHAR == '-')
                                //if(format[PointFt] != 'u') // ignore sign (no std)
                                    sign = -1;
                        NEXTCHAR;
                    }
                    long value = 0;
                    while(c_isdigit(CURCHAR) && (lenEn != true || len > 0))
                    {
                        value *= 10;
                        value += (int)(CURCHAR - '0');
                        NEXTCHAR;
                        len--;
                    }

                    if (save)
                        *(int*)va_arg(ap, int*) = value * sign;
                    //if (save) // ignore %* (std)
                        count++;
                    break;
                    }
                case ']':
                case 's':
                {
                    // Implementation for %s
                    char* t = save ? va_arg(ap, char*) : NULL;
                    while (CURCHAR != '\n' && CURCHAR != EOF && (!lenEn || len > 0)) {
                        if (save)
                            *t++ = CURCHAR;
                        NEXTCHAR;
                        if (lenEn)
                            len--;
                    }
                    if (save)
                        *t = '\0'; 
                    count++;
                    break;
                }

                default:
                    break;
                }
             
            #ifndef C_SSCANF
            if(format[PointFt] != 'c' 
            && format[PointFt] != 'u'
            && format[PointFt] != 'd')
                c_getbackch(CURCHAR);
            #endif
        }
        //else  // drop char in buff (no std)
        //    NEXTCHAR; //
        PointFt++;
    }

    va_end(ap);
    return count;
}

// custom
char backch = 0;
char c_getch()
{
	if(backch == 0)
		return (char)_getchar();
	else
	{	
		char tmp = backch;
		backch = 0;
		return tmp;
	}
}

// new
bool c_getbackch(char b)
{
	char tmp = backch;
	backch = b;
	if (tmp != 0)
		return 1;
	else 
		return 0;
}

/*
Calls uart_get_char() to retrieve a character received on UART (RX).
Returns the character received from uart_get_char().
*/
extern struct uart_t *global_uart;
uint32_t _getchar(){

    return uart_get_char(global_uart);

}
