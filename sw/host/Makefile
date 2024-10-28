# Author: Manuel Maddaluno <manuel.maddaluno@unina.it>
# For now just a stub

CC=gcc

LIBS=-lc -lpthread
LIB_DIR=.

all:
	$(CC) -o virtual_uart virtual_uart.c $(LIBS) -I$(LIB_DIR)

.PHONY: clean

clean:
	rm virtual_uart