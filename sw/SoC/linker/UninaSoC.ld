/* This file is auto-generated with create_linker_script.py */

/* Memory blocks */
MEMORY
{
	BRAM (xrw) : ORIGIN = 0x0,  LENGTH = 0x2000
	PERIPHERALS (rw) : ORIGIN = 0x2000,  LENGTH = 0x2000
}

/* Sections */
SECTIONS
{
	_slave_BRAM_base = 0x0;
	_slave_BRAM_end = 0x2000;
	_slave_VIRTUAL_UART_base = 0x1000;
	_slave_VIRTUAL_UART_end = 0x3000;
}

