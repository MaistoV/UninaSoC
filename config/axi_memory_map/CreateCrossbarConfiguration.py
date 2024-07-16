#Author: Stefano Toscano - stefa.toscano@studenti.unina.it
#Description: this is the Main script that calls all the appropriate Functions to generate a valid Crossbar Configuration File in tcl.
#             It first create the Default Configuration and reeds the csv Configuration File, then, for each Parameter, calls the Function that handles the Configuration.
#             Once the Configuration is created, the tcl Commands Properties are generated and written to a tcl File using the appropriate Functions.

#Libraries imported
import pandas as pd #to read csv files
from Caller import * #Contains the Function that calls the read and set operations for Configuration Parameters
from WriteFinalConfig import * #Contains all operations needed to frite the tcl config File

#Files used
config_file_name = '/home/crossbar/Scrivania/Repository/UninaSoCCrossbar/config/axi_memory_map/configs/config.csv' #csv Configuration File name and path (UPGRADE WITH ACTUAL PATH!!!)
config_tcl_file_name = '/home/crossbar/Scrivania/Repository/UninaSoCCrossbar/hw/xilinx/ips/xlnx_axi_crossbar/config.tcl' #tcl Configuration File name and path (UPGRADE WITH ACTUAL PATH!!!)

config = Configuration() #Creates the Initial config


#The csv Input File is read and the config Parameters are set


pd.set_option('display.max_colwidth',1000) #to avoid data truncations
file_csv = pd.read_csv(config_file_name,sep=",",index_col=0,header=None) #reads the csv file

properties = file_csv.index.tolist() #Creates a list of all Configuration Parameters Names
#Reads and Sets all Configuration Parameters
for property_name in properties:
	config = read_Property(property_name,config,file_csv)


#Creates the config commands in tcl


Single_Command_List = []
Count_Commands = 10 #This is the number of commands that are surely produced

Single_Command_List.append("CONFIG.NUM_SI {" + str(config.SI_Number) + "}")
Single_Command_List.append("CONFIG.NUM_MI {" + str(config.MI_Number) + "}")
Single_Command_List.append("CONFIG.STRATEGY {" + str(config.Strategy) + "}")
Single_Command_List.append("CONFIG.R_REGISTER {" + str(config.R_Register) + "}")
Single_Command_List.append("CONFIG.PROTOCOL {" + config.Protocol + "}")
Single_Command_List.append("CONFIG.ADDR_WIDTH {" + str(config.Addr_Width) + "}")
Single_Command_List.append("CONFIG.DATA_WIDTH {" + str(config.Data_Width) + "}")
Single_Command_List.append("CONFIG.ID_WIDTH {" + str(config.ID_Width) + "}")

if (config.Protocol == "AXI4"):
	Single_Command_List.append("CONFIG.AWUSER_WIDTH {" + str(config.AW_User_Width) + "}")
	Single_Command_List.append("CONFIG.ARUSER_WIDTH {" + str(config.AR_User_Width) + "}")
	Single_Command_List.append("CONFIG.WUSER_WIDTH {" + str(config.W_User_Width) + "}")
	Single_Command_List.append("CONFIG.RUSER_WIDTH {" + str(config.R_User_Width) + "}")
	Single_Command_List.append("CONFIG.BUSER_WIDTH {" + str(config.B_User_Width) + "}")
	Count_Commands = Count_Commands + 5

Single_Command_List.append("CONFIG.CONNECTIVITY_MODE {" + config.Connectivity_Mode + "}")

Slave_Priorities_Config_List = []
SI_Read_Acceptance_Config_List = []
SI_Write_Acceptance_Config_List = []
Thread_ID_Width_Config_List = []
Single_Thread_Config_List = []
Base_ID_Config_List = []
for i in range (config.SI_Number):
    if (i < 10):
        slave_index = "0" + str(i)
    else:
        slave_index = str(i)
    Slave_Priorities_Config_List.append("CONFIG.S" + slave_index + "_ARB_PRIORITY {" + str(config.Slave_Priorities[i]) + "}")
    SI_Read_Acceptance_Config_List.append("CONFIG.S" + slave_index + "_READ_ACCEPTANCE {" + str(config.SI_Read_Acceptance[i]) + "}")
    SI_Write_Acceptance_Config_List.append("CONFIG.S" + slave_index + "_WRITE_ACCEPTANCE {" + str(config.SI_Write_Acceptance[i]) + "}")
    Thread_ID_Width_Config_List.append("CONFIG.S" + slave_index + "_THREAD_ID_WIDTH {" + str(config.Thread_ID_Width[i]) + "}")
    Single_Thread_Config_List.append("CONFIG.S" + slave_index + "_SINGLE_THREAD {" + str(config.Single_Thread[i]) + "}")
    Base_ID_Config_List.append("CONFIG.S" + slave_index + "_BASE_ID {" + config.Base_ID[i] + "}")
    Count_Commands = Count_Commands + 6
Single_Command_List.extend(Slave_Priorities_Config_List)
Single_Command_List.extend(SI_Read_Acceptance_Config_List)
Single_Command_List.extend(SI_Write_Acceptance_Config_List)
Single_Command_List.extend(Thread_ID_Width_Config_List)
Single_Command_List.extend(Single_Thread_Config_List)
Single_Command_List.extend(Base_ID_Config_List)

MI_Read_Issuing_Config_List = []
MI_Write_Issuing_Config_List = []
Secure_Config_List = []
for i in range (config.MI_Number):
    if (i < 10):
        master_index = "0" + str(i)
    else:
        master_index = str(i)
    MI_Read_Issuing_Config_List.append("CONFIG.M" + master_index + "_READ_ISSUING {" + str(config.MI_Read_Issuing[i]) + "}")
    MI_Write_Issuing_Config_List.append("CONFIG.M" + master_index + "_WRITE_ISSUING {" + str(config.MI_Write_Issuing[i]) + "}")
    Secure_Config_List.append("CONFIG.M" + master_index + "_SECURE {" + str(config.Secure[i]) + "}")
    Count_Commands = Count_Commands + 3
Single_Command_List.extend(MI_Read_Issuing_Config_List)
Single_Command_List.extend(MI_Write_Issuing_Config_List)
Single_Command_List.extend(Secure_Config_List)

Single_Command_List.append("CONFIG.ADDR_RANGES {" + str(config.Addr_Ranges) + "}")

Base_Addr_Config_List = []
Range_Width_Config_List = []
for i in range (config.MI_Number):
    if (i < 10):
        master_index = "0" + str(i)
    else:
        master_index = str(i)
    for j in range (config.Addr_Ranges):
        if (j < 10):
            range_index = "0" + str(j)
        else:
            range_index = str(j)
        Base_Addr_Config_List.append("CONFIG.M" + master_index + "_A" + range_index + "_BASE_ADDR {" + config.Base_Addr[config.Addr_Ranges*i+j] + "}")
        Range_Width_Config_List.append("CONFIG.M" + master_index + "_A" + range_index + "_ADDR_WIDTH {" + str(config.Range_Width[config.Addr_Ranges*i+j]) + "}")
        Count_Commands = Count_Commands + 2
Single_Command_List.extend(Base_Addr_Config_List)
Single_Command_List.extend(Range_Width_Config_List)

Read_Connectivity_Config_List = []
Write_Connectivity_Config_List = []
for i in range (config.MI_Number):
    if (i < 10):
        master_index = "0" + str(i)
    else:
        master_index = str(i)
    for j in range (config.SI_Number):
        if (j < 10):
            slave_index = "0" + str(j)
        else:
            slave_index = str(j)
        Read_Connectivity_Config_List.append("CONFIG.M" + master_index + "_S" + slave_index + "_READ_CONNECTIVITY {" + str(config.Read_Connectivity[config.SI_Number*i+j]) + "}")
        Write_Connectivity_Config_List.append("CONFIG.M" + master_index + "_S" + slave_index + "_WRITE_CONNECTIVITY {" + str(config.Write_Connectivity[config.SI_Number*i+j]) + "}")
        Count_Commands = Count_Commands + 2
Single_Command_List.extend(Read_Connectivity_Config_List)
Single_Command_List.extend(Write_Connectivity_Config_List)


#Creates the actual config file with tcl commands


file = open(config_tcl_file_name, "w")
file.write("#This file is auto-generated with CreateCrossbarConfiguration.py\n")
initialize_File(file)

Count = 0 #This variable helps to understand when we have written all the properties
for command in Single_Command_List:
	write_SingleCommand_Configuration(file,command)
	Count = Count + 1
	if (Count < Count_Commands):
		file.write("\\\r                         ")
	else:
		file.write("\r                    ")

end_File(file)
file.close
