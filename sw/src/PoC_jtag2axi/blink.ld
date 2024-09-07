MEMORY
{
   BRAM (RWX) : ORIGIN = 0x01000000, LENGTH = 0x00002000
}
SECTIONS
{
    everything :
    {
	. = ALIGN(4);
	start.o (.text)
        *(.*)
    } >BRAM
}
