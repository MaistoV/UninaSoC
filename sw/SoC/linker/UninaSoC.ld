/* This file is auto-generated with create_linker_script.py */

/* Memory blocks */
MEMORY
{
	BRAM (xrw) : ORIGIN = 0x0,  LENGTH = 0x20000
	PERIPHERALS (rw) : ORIGIN = 0x20000,  LENGTH = 0x4000
}

/* Sections */
SECTIONS
{
	_slave_BRAM_base = 0x0;
	_slave_BRAM_end = 0x20000;
	_slave_GPIO_out_base = 0x100000;
	_slave_GPIO_out_end = 0x102000;
	_slave_UART_base = 0x200000;
	_slave_UART_end = 0x202000;
}

