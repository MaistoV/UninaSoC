# Author: Manuel Maddaluno <manuel.maddaluno@unina.it>
# Description: Virtual uart host application Makefile


PROJECT = virtual_uart

CC      = gcc
RM      = rm -rf
MKDIR   = @mkdir -p $(@D)

LIB_DIR = src
SRC_DIR = src
BIN_DIR = bin

LIBS    = -lc -lpthread
SRCS    = $(wildcard src/*.c)

all: $(BIN_DIR)/$(PROJECT)

$(BIN_DIR)/$(PROJECT): $(SRCS)
	$(MKDIR)
	$(CC) -o $@ $^ $(LIBS) -I$(LIB_DIR)


.PHONY: all clean

clean:
	$(RM) $(BIN_DIR)