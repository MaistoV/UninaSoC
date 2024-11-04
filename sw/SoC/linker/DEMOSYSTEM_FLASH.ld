/* NOTE: this is a temporary file */

OUTPUT_ARCH("riscv")

/* Entry Point */
ENTRY(reset_handler)

/* Memories definition */
MEMORY
{
  DDR	(xrw)	: ORIGIN = 0x00000000,	LENGTH = 2K
}

/* Sections */
SECTIONS
{

  .isr_vector :
  {
    KEEP(*(.isr_vector))
    . = ALIGN(32);
  } >DDR

  .text :
  {
	  *(.init)
    *(.text)
	  *(.text.*)
	  *(.fini)
	  *(.rodata)
	  *(.rodata.*)
	  . = ALIGN(32);
	  _etext = .;
  }> DDR

  .data :
  {
    *(.data)
    *(.data.*)
    . = ALIGN(32);
  }> DDR

  .bss :
  {
	  *(.bss)
	  *(.bss.*)
	  *(COMMON)
	  . = ALIGN(32);
	  end = .;
	  __end__ = .;
  }> DDR

  PROVIDE( _vectors_start = ADDR(.isr_vector));
  PROVIDE( _start_of_ddr = ORIGIN(DDR) );
  PROVIDE( _stack_start = ORIGIN(DDR) + LENGTH(DDR) );
  PROVIDE( _estack = ORIGIN(DDR) + LENGTH(DDR) );    /* TO CHECK*/
  PROVIDE( _bss_start = ADDR(.bss) );
  PROVIDE( _bss_end = ADDR(.bss) + SIZEOF(.bss) );
  PROVIDE( _data_start = ADDR(.data) );
  PROVIDE( _data_end = ADDR(.data) + SIZEOF(.data) );
}
