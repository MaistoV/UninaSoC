/*This file is auto-generated with CreateLinkerScript.py*/

/*Memories definition*/
MEMORY
{
		BRAM (xrw) : ORIGIN = 0x0000000000000000, LENGTH = 24
		PERIPHERALS (rw) : ORIGIN = 0x00000000000000c0, LENGTH = 48
}

/*Sections*/
SECTIONS
{
		_slave_Slave_Name_A_base = 0x0000000000000000;
		_slave_Slave_Name_A_end = 0x00000000000000c0;
		_slave_Slave_Name_B_base = 0x0001000000000000;
		_slave_Slave_Name_B_end = 0x0001000000000180;
}

