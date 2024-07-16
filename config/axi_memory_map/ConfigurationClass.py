#Author: Stefano Toscano - stefa.toscano@studenti.unina.it
#Description: this file contains a class with all the Configuration Parameters with their default values (with some exceptions). The lists of values are just initialized.

#Libraries imported
from dataclasses import dataclass #to create a class whith all the Configuration Parameters that need to be set

class Configuration:
	SI_Number: int = 1 #Slave Interface (SI) Number
	MI_Number: int = 2 #Master Interface (MI) Number
	Strategy: int = 0 #Config Strategy
	R_Register: int = 0 #Internal Registers division
	Protocol: str = "AXI4" #AXI Protocol used
	Addr_Width: int = 32 #Address Signals Width
	Data_Width: int = 32 #Data Signals Width
	ID_Width: int = 4 #ID Data Width for MI and SI (a subset of it is used by the Interfaces Thread IDs)
	AW_User_Width: int = 0 #Address Signals Width for each MI and SI for Write Operations
	AR_User_Width: int = 0 #Address Signals Width for each MI and SI for Read Operations
	W_User_Width: int = 0 #Data Signals Width for each MI and SI for Write Operations
	R_User_Width: int = 0 #Data Signals Width for each MI and SI for Read Operations
	B_User_Width: int = 0 #Data Signals Width for each MI and SI for Write Response Operations
	Connectivity_Mode: str = "SASD" #Crossbar Configuration, the default value would be "SAMD", but we don't use it in this scenario if not said specifically through config file
	Slave_Priorities: list = [] #This list contains Scheduling Priority for each Slave
	SI_Read_Acceptance: list = [] #This list contains Number of possible Active Read Transaction at the same time for each Slave
	SI_Write_Acceptance: list = [] #This list contains Number of possible Active Write Transaction at the same time for each Slave
	Thread_ID_Width: list = [] #This list contains Number of ID bits used by each SI for thei respective Threads
	Single_Thread: list = [] #This lsit contains the enable option for each SI in regards to the Single Thread Option
	Base_ID: list = [] #This list constains Base ID for each SI
	MI_Read_Issuing: list = [] #This list contains Number of possible Active Read Transaction at the same time for each Master
	MI_Write_Issuing: list = [] #This list contains Number of possible Active Write Transaction at the same time for each Master
	Secure: list = [] #This list contains the enable option for each Master to enter TrustZone
	Addr_Ranges: list = 1 #Number of Address Ranges for all MI
	Base_Addr: list = [] #This list contains the Base Address of each Range of each Master
	Range_Width: list = [] #This list contains the width of each Range of each Master
	Read_Connectivity: list = [] #This list contains the enable option for each MI_to_SI possible Connection for Read Operations
	Write_Connectivity: list = [] #This list contains the enable option for each MI_to_SI possible Connection for Write Operations

