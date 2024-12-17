/* This file is auto-generated with create_linker_script.py */

/* Memory blocks */
MEMORY
{
	BRAM (xrw) : ORIGIN = 0x00000000,  LENGTH = 0x20000
}

/* Peripherals symbols */
_peripheral_UART_start = 0x00010000;
_peripheral_UART_end = 0x00012000;
_peripheral_GPIO_out_start = 0x00020000;
_peripheral_GPIO_out_end = 0x00022000;

/* Global symbols */
_vector_table_start = 0x00000000;
_vector_table_end = 0x00000080;
_stack_start = 0x00020000;

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

