#Author: Stefano Toscano - stefa.toscano@studenti.unina.it
#Description: this script creates a template for the LinkerScript. It reads the csv Configuration File to get the Ranges' Addresses and Widths and the Slave Names along with the Number of Masters.
#             Once the informations are retrieved, the Address Space is calculated and the template is generated.

#Libraries used
import os #for file operations
import pandas as pd #to read csv files

#Files used
linker_file = '/home/crossbar/Scrivania/Repository/UninaSoCCrossbar/sw/linker/UninaSoC.ld' #LinkerScript Template name and path (UPGRADE WITH ACTUAL PATH!!!)
config_file = '/home/crossbar/Scrivania/Repository/UninaSoCCrossbar/config/axi_memory_map/configs/config.csv' #csv Configuration File name and path (UPGRADE WITH ACTUAL PATH!!!)

#Files opening
linker = open(linker_file, "w")
pd.set_option('display.max_colwidth',1000) #to avoid data truncations
config = pd.read_csv(config_file,sep=",",index_col=0,header=None) #reads the csv file

linker.write("/*This file is auto-generated with CreateLinkerScript.py*/\n")

#Parameters
#Let's retieve the Address Ranges
row = config.loc["Range_Base_Addr"] #Reads the row of the csv Configuration File containing the Ranges' Base Addresses
retrieved = row.to_string(index = False) #Gets row as String without the index
Addresses = [] #List of Addresses
Addresses = retrieved.split() #Fills the list with retrieved values
#Let's retieve the Addresses' Widths
row = config.loc["Range_Width"] #Reads the row of the csv Configuration File containing the Ranges' Width
retrieved = row.to_string(index = False) #Gets row as String without the index
Lengths = [] #List of Addresses' Lengths
Lengths = retrieved.split() #Fills the list with retrieved values
for i in range(len(Lengths)): #Turns the values into Integers
	Lengths[i] = int(Lengths[i])
#Let's retieve the Number of Masters
row = config.loc["MI_Number"] #Reads the row of the csv Configuration File containing the Master Number
retrieved = row.to_string(index = False) #Gets row as String without the index
Master_Number = int(retrieved) #Gets the Number of Masters as Integer
#Let's retieve the Slaves' Names
row = config.loc["Slave_Name"] #Reads the row of the csv Configuration File containing the Slave Names
retrieved = row.to_string(index = False) #Gets row as String without the index
Slave_Names = [] #List of Slaves' names
Slave_Names = retrieved.split() #Fills the list with retrieved values

#Calculate Address Space
BRAM_Origin = Addresses[0]
BRAM_Length = Lengths[0]
base = int(BRAM_Origin,16)
ph_base = base + BRAM_Length*8
PERIPHERALS_Origin = hex(ph_base)
ph_len = len(PERIPHERALS_Origin) - 2
while (ph_len < 16):
	ph_len = ph_len + 1
	first_part = PERIPHERALS_Origin[:2]
	last_part = PERIPHERALS_Origin[2:]
	PERIPHERALS_Origin = first_part + '0' + last_part
PERIPHERALS_Length = 0
for i in range(1,len(Lengths)):
	PERIPHERALS_Length = PERIPHERALS_Length + Lengths[i]

#BLOCKS
linker.write("\n")
linker.write("/*Memories definition*/\n")
linker.write("MEMORY\n")
linker.write("{\n")
linker.write("\t\tBRAM (xrw) : ORIGIN = " + BRAM_Origin + ", LENGTH = " + str(BRAM_Length) + "\n")
linker.write("\t\tPERIPHERALS (rw) : ORIGIN = " + PERIPHERALS_Origin + ", LENGTH = " + str(PERIPHERALS_Length) + "\n")
linker.write("}\n")

#SECTIONS
linker.write("\n")
linker.write("/*Sections*/\n")
linker.write("SECTIONS\n")
linker.write("{\n")
for i in range(Master_Number):
	start = Addresses[i]
	base = int(start,16)
	offset = base + Lengths[i]*8
	stop = hex(offset)
	stop_len = len(stop) - 2
	while (stop_len < 16):
		stop_len = stop_len + 1
		first_part = stop[:2]
		last_part = stop[2:]
		stop = first_part + '0' + last_part
	linker.write("\t\t_slave_" + Slave_Names[i] + "_base = " + str(start) + ";\n")
	linker.write("\t\t_slave_" + Slave_Names[i] + "_end = " + str(stop) + ";\n")
linker.write("}\n")

#Files closing
linker.write("\n")
linker.close()

