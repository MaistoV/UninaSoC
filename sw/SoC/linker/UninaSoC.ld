/* This file is auto-generated with create_linker_script.py */

/*
	Note 0:
		Currently, data section is omitted. In conventional MCUs, data is located in
		non-loadable SRAM, while code is in flash. Linker script complains about
		this, though it does not forbid defininh loadable and RWX sections.
	Note 1:
		Currently, text starts after the vector table and taks as much space as required.
		Is this what we want?
	Note 2:
		Do we need to tune bss, data, r odata and stack size? Or are we going to keep
		these fixed?
*/

/* Memory blocks */
MEMORY
{
	BRAM (xrw) : ORIGIN = 0x0,  LENGTH = 0x20000
	PERIPHERALS (rw) : ORIGIN = 0x20000,  LENGTH = 0x4000
}

/* Sizes */

_text_size = 0x10000;
_data_size = 0x2000;
_bss_size = 0x1000;
_rodata_size = 0x1000;
_stack_size = 0x1000;

/* Code standard definitions */
_vector_table_start = ORIGIN(BRAM);

_text_start = _vector_table_start + 128;
/* text end is left unbounded */
_data_start = _text_end;
_data_end = _data_start + _data_size;

_bss_start = _stack_end - 0x1000;
_bss_end = _stack_end;
_rodata_start = _bss_start - 0x1000;  
_rodata_end = _bss_end;

_stack_start = ORIGIN(BRAM) + LENGTH(BRAM);
_stack_end = ORIGIN(BRAM) + LENGTH(BRAM) - 0x1000;

/* Slave Peripheral mappings */
_slave_BRAM_base = 0x0;
_slave_BRAM_end = 0x20000;
_slave_UART_base = 0x10000;
_slave_UART_end = 0x12000;
_slave_GPIO_out_base = 0x20000;
_slave_GPIO_out_end = 0x22000;

/* Sections */
SECTIONS
{
	.vector_table _vector_table_start :
	{
		KEEP(*(.vector_table))
		
	}> BRAM

	.text _text_start :
	{
		. = ALIGN(32);
		*(.text.handlers)
		*(.text.start)
		*(.text)
		*(.text.*)
		. = ALIGN(32);
		_text_end = .;
	}> BRAM

	.rodata _rodata_start : 	
	{
		*(.rodata)
		*(.rodata.*)
		. = ALIGN(32);
	}> BRAM

	.bss _bss_start :
	{
		*(.bss)
		. = ALIGN(32);
	}> BRAM

}

