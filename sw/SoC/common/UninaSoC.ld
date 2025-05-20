/* This file is auto-generated with create_linker_script.py */

/* Memory blocks */
MEMORY
{
	BRAM (xrw) : ORIGIN = 0x0000000000000000,  LENGTH = 0x10000
	DDR (xrw) : ORIGIN = 0x0000000000040000,  LENGTH = 0x10000
}

/* Peripherals symbols */
_peripheral_DM_mem_start = 0x0000000000010000;
_peripheral_DM_mem_end = 0x0000000000020000;
_peripheral_HLS_CONTROL_start = 0x0000000000030000;
_peripheral_HLS_CONTROL_end = 0x0000000000040000;
_peripheral_PLIC_start = 0x0000000004000000;
_peripheral_PLIC_end = 0x0000000008000000;
_peripheral_UART_start = 0x0000000000020000;
_peripheral_UART_end = 0x0000000000020010;
_peripheral_TIM0_start = 0x0000000000020020;
_peripheral_TIM0_end = 0x0000000000020040;
_peripheral_TIM1_start = 0x0000000000020040;
_peripheral_TIM1_end = 0x0000000000020060;

/* Global symbols */
_vector_table_start = 0x0000000000000000;
_vector_table_end = 0x0000000000000080;
_stack_start = 0x0000000000007ff8;

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

