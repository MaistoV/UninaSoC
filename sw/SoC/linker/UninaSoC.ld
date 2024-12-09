/* This file is auto-generated with create_linker_script.py */

/* Memory blocks */
MEMORY
{
	BRAM (xrw) : ORIGIN = 0x0,  LENGTH = 0x20000
	PERIPHERALS (rw) : ORIGIN = 0x20000,  LENGTH = 0x40000
}

/* Sections */
SECTIONS
{
	_slave_BRAM_base = 0x0;
	_slave_BRAM_end = 0x20000;
	_slave_VIRTUAL_UART_base = 0x10000;
	_slave_VIRTUAL_UART_end = 0x30000;
	_slave_DDR4_base = 0x20000;
	_slave_DDR4_end = 0x40000;
}

