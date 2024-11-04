/* This file is auto-generated with create_linker_script.py */

/* Memory blocks */
MEMORY
{
<<<<<<< HEAD
	BRAM (xrw) : ORIGIN = 0x0,  LENGTH = 0x20000
	PERIPHERALS (rw) : ORIGIN = 0x20000,  LENGTH = 0x2000
=======
	BRAM (xrw) : ORIGIN = 0x0,  LENGTH = 0x2000
	PERIPHERALS (rw) : ORIGIN = 0x2000,  LENGTH = 0x2000
>>>>>>> 650147f (Feature/hpc/virtual uart (#12))
}

/* Sections */
SECTIONS
{
	_slave_BRAM_base = 0x0;
<<<<<<< HEAD
	_slave_BRAM_end = 0x20000;
	_slave_GPIO_out_base = 0x100000;
	_slave_GPIO_out_end = 0x102000;
=======
	_slave_BRAM_end = 0x2000;
	_slave_VIRTUAL_UART_base = 0x1000;
	_slave_VIRTUAL_UART_end = 0x3000;
>>>>>>> 650147f (Feature/hpc/virtual uart (#12))
}

