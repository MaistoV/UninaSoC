/* This file is auto-generated with create_linker_script.py */

/* Memory blocks */
MEMORY
{
	BRAM (xrw) : ORIGIN = 0x0000000000000000,  LENGTH = 0x20000
}

/* Peripherals symbols */
_peripheral_UART_start = 0x0000000000010000;
_peripheral_UART_end = 0x0000000000012000;
_peripheral_GPIO_out_start = 0x0000000000020000;
_peripheral_GPIO_out_end = 0x0000000000022000;

/* Global symbols */
_vector_table_start = 0x0000000000000000;
_vector_table_end = 0x0000000000000080;
_stack_start = 0x0000000000007ffc;

/* Sections */
SECTIONS
{
	.vector_table _vector_table_start :
	{
		KEEP(*(.vector_table))
	}> BRAM

	.text :
	{
		. = ALIGN(32);
		_text_start = .;
		*(.text.handlers)
		*(.text.start)
		*(.text)
		*(.text*)
		. = ALIGN(32);
		_text_end = .;
	}> BRAM
}

