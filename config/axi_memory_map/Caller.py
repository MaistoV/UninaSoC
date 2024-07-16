#Author: Stefano Toscano - stefa.toscano@studenti.unina.it
#Description: this script calls the Functions used to read and set Configuration Parameters according to the given Parameter that has to be set. The Configuration class is taken as input and given to the
#             called Functions to modify the Configuration.

#Libraries imported
from CrossbarConfigReader import * #Contains all the operations to set the config Parameters according to provided csv config File

def read_Property(property_name,config,file_csv):
	base_func_name = "read_"
	match property_name:
		case "SI_Number" | "MI_Number": #SI and MI Number Acquisition
			func_name = base_func_name + "Interfaces"
			config = eval(func_name + "(config,property_name,file_csv.loc[property_name])")
		case "Strategy" | "R_Register" | "Protocol" | "Addr_Width" | "Data_Width" | "Connectivity_Mode": #Strategy, R_Register, Protocol, Address and Data Widths, Connectivity Mode Acquisition
			func_name = base_func_name + property_name
			config = eval(func_name + "(config,property_name,file_csv.loc[property_name])")
		case "ID_Width": #ID Width Acquisition
			func_name = base_func_name + "IDWidth_UsersWidth_AddrRanges"
			config = eval(func_name + "(config,property_name,file_csv.loc[property_name],4,32)")
		case "AW_User_Width" | "AR_User_Width" | "W_User_Width" | "R_User_Width" | "B_User_Width": #User Widths Acquisition
			func_name = base_func_name + "IDWidth_UsersWidth_AddrRanges"
			config = eval(func_name + "(config,property_name,file_csv.loc[property_name],0,1024)")
		case "Addr_Ranges": #Addreass Ranges Acquisition
			func_name = base_func_name + "IDWidth_UsersWidth_AddrRanges"
			config = eval(func_name + "(config,property_name,file_csv.loc[property_name],1,16)")
		case "Slave_Priority" | "Thread_ID_Width" | "Single_Thread" | "Base_ID" | "Secure" | "Range_Base_Addr" | "Range_Width": #Slave Priorities, Slave Thread IDs Width, Slave Single Thread Modes, Slave Base IDs, #Master Secure Modes, Ranges' Base Address, Ranges' Width Acquisition
			func_name = base_func_name + property_name
			config = eval(func_name + "(config,file_csv.loc[property_name])")
		case "SI_Read_Acceptance" | "SI_Write_Acceptance": #Slave Read and Write Acceptance Acquisition
			func_name = base_func_name + "Acceptance"
			config = eval(func_name + "(config,property_name,file_csv.loc[property_name])")
		case "MI_Read_Issuing" | "MI_Write_Issuing": #Master Read and Write Acquisition
			func_name = base_func_name + "Issuing"
			config = eval(func_name + "(config,property_name,file_csv.loc[property_name])")
		case "Read_Connectivity" | "Write_Connectivity": #Read and Write Connectivity Acquisition
			func_name = base_func_name + "Connectivity"
			config = eval(func_name + "(config,property_name,file_csv.loc[property_name])")
		case _: #Invalid Parameter
			logging.warning("WARNING! " + property_name + " is not a property to be set")
	return config

