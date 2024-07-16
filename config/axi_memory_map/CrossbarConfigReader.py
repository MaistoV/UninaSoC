#Author: Stefano Toscano - stefa.toscano@studenti.unina.it
#Description: this script contains the acquisition Functions, they take csv Input File Parameters to set Configuration Parameters. If Constraints aren't respected, correct values are used ignoring the input
#             given. They take as Input the Configuration class that keeps track of the current Configuration and the row containing the Input values coming from csv Configuration File. Some of them are
#             generic to be used for multiple Parameters, thus they also take the Parameter Name as Input. Others require also values' ranges.

#Libraries imported
import logging #to print logging and error messages in the shell
import math #for math operations
from ConfigurationClass import * #Contains the Configuration Class

def read_Interfaces(config,parameter,row):
    #Reads the number of Master and Slave Interfaces
    #The range of possible values is [0 ; 16] whith 1 as deafault value
    #If the value is missing or is incorrect in the csv file, default value is used
    retrieved = row.to_string(index = False) #Gets row as String without the index
    value = int(retrieved)
    if (retrieved != ""):
        if (value in range(0,17)):
        	match parameter:
        		case "SI_Number":
        			config.SI_Number = value
        		case "MI_Number":
        			config.MI_Number = value   		
        else:
            logging.warning("WARNING! " + parameter + " out-of-range [0 ; 16]. Using default value.")
    else:
        logging.warning("WARNING! No " + parameter + " specified. Using default value.")
    return config

def read_Strategy(config,parameter,row):
    #Reads the Configuration Strategy
    #The range of possible values is [0 ; 2] whith 0 as deafault value
    #0 => Use Configuration Strategy in the Connectivity Mode Parameter
    #1 => SASD
    #2 => SAMD
    #If the value is missing or is incorrect in the csv file, default value is used
    retrieved = row.to_string(index = False) #Gets row as String without the index
    value = int(retrieved)
    if (retrieved != ""):
        if (value in range(0,3)):
            config.Strategy = value
        else:
            logging.warning("WARNING! Strategy out-of-range [0 ; 2]. Using default value.")
    else:
        logging.warning("WARNING! No Strategy specified. Using default value.")
    return config

def read_R_Register(config,parameter,row):
    #Reads the R_Register value
    #The range of possible values is [0 ; 1] whith 0 as deafault value
    #1 => only if SASD Configuration Strategy is selected
    #If the value is missing or is incorrect in the csv file, default or coherent value is used
    retrieved = row.to_string(index = False) #Gets row as String without the index
    value = int(retrieved)
    if (config.Strategy == 2):
        config.R_Register = 0
        logging.warning("WARNING! Configuration Strategy set to 2. By default Connectivity Mode is SAMD and R_Register is 0. Input Ignored.")
    else:
        if (retrieved != ""):
            if (value in range(0,2)):
                config.R_Register = value
            else:
                logging.warning("WARNING! R_Register value out-of-range [0 ; 1]. Using default value.")
        else:
            logging.warning("WARNING! No R_Regiter value specified. Using default value.")
    return config

def read_Protocol(config,parameter,row):
    #Reads the AXI Protocol Version
    #The range of possible values is [AXI4 ; AXI4LITE ; AXI3] whith AXI4 as deafault value
    #If the value is missing or is incorrect in the csv file, default value is used
    retrieved = row.to_string(index = False) #Gets row as String without the index
    if (retrieved != ""):
        if ((retrieved == "AXI4") or (retrieved == "AXI4LITE") or (retrieved == "AXI3")):
            config.Protocol = retrieved
        else:
            logging.warning("WARNING! Protocol invalid. Using default value (AXI4).")
    else:
        logging.warning("WARNING! No Protocol specified. Using default value (AXI4).")
    return config

def read_Addr_Width(config,parameter,row):
    #Reads the Address Widdth applied to all Interfaces
    #[AXI4 ; AXI3] => the range of possible values is [12 ; 64]
    #AXI4LITE => the range of possible values is [1 ; 64]
    #32 is the default value in every scenario
    #If the value is missing or is incorrect in the csv file, default value is used
    retrieved = row.to_string(index = False) #Gets row as String without the index
    value = int(retrieved)
    if (retrieved != ""):
        if ((config.Protocol == "AXI4LITE") and (value in range(1,65))):
            config.Addr_Width = value
        elif (((config.Protocol == "AXI4") or (config.Protocol == "AXI3")) and (value in range(12,65))):
            config.Addr_Width = value
        else:
            logging.warning("WARNING! Address Width value isn't compatible with AXI Protocol Used. Using default value.")
    else:
        logging.warning("WARNING! No Address Width value specified. Using default value.")
    return config

def read_Data_Width(config,parameter,row):
    #Reads the Address Widdth applied to all Interfaces
    #[AXI4 ; AXI3] => the range of possible values is {32 , 64 , 128 , 256 , 512 , 1024}
    #AXI4LITE => the range of possible values is {32 , 64}
    #32 is the default value in every scenario
    #If the value is missing or is incorrect in the csv file, default value is used
    retrieved = row.to_string(index = False) #Gets row as String without the index
    value = int(retrieved)
    if (retrieved != ""):
        Data_Width_Found = False
        Base_Data = 32
        while ((Data_Width_Found == False) and (Base_Data <= 1024)):
            if (value == Base_Data):
                Data_Width_Found = True
            Base_Data = Base_Data * 2
        if ((config.Protocol == "AXI4LITE") and ((value == 32) or (value == 64))):
            config.Data_Width = value
        elif (((config.Protocol == "AXI4") or (config.Protocol == "AXI3")) and (Data_Width_Found == True)):
            config.Data_Width = value
        else:
            logging.warning("WARNING! Data Width value isn't compatible with AXI Protocol Used. Using default value.")
    else:
        logging.warning("WARNING! No Data Width value specified. Using default value.")
    return config

def read_IDWidth_UsersWidth_AddrRanges(config,parameter,row,lower_range,higer_range):
    #Reads the Data Width applied to all Master Interfacess
    #The range of possible values is [4 ; 32] whith 4 as deafault value
    
    #Reads User Widths used by each Interface (the AXI Protocol Signals)
    #The range of possible values is [0 ; 1024] whith 0 as deafault value
    
    #Reads the number of Address Ranges applaied to all Master Interfaces
    #The range of possible values is [1 ; 16] whith 1 as deafault value
    
    #If the values are missing or are incorrect in the csv file, default value is used
    retrieved = row.to_string(index = False) #Gets row as String without the index
    value = int(retrieved)
    if (retrieved != ""):
        if (value in range(lower_range,higer_range+1)):
        	match parameter:
        		case "ID_Width":
        			config.ID_Width = value
        		case "AW_User_Width":
        			config.AW_User_Width = value
        		case "AR_User_Width":
        			config.AR_User_Width = value
        		case "W_User_Width":
        			config.W_User_Width = value
        		case "R_User_Width":
        			config.R_User_Width = value
        		case "B_User_Width":
        			config.B_User_Width = value
        		case "Addr_Ranges":
        			config.Addr_Ranges = value
        else:
            logging.warning("WARNING! " + parameter + " value out-of-range [" + str(lower_range) + " ; " + str(higer_range) + "]. Using default value.") 
    else:
        logging.warning("WARNING! No " + parameter + " value specified. Using default value.")
    return config

def read_Connectivity_Mode(config,parameter,row):
    #Reads the Connectivity Mode
    #The two possible values are SAMD and SASD
    #[Configuration Strategy = 1 or R_Register = 1] => SASD
    #[Configuration Strategy = 2] => SAMD
    #If the value is missing or is incorrect in the csv file, default or coherent value is used
    retrieved = row.to_string(index = False) #Gets row as String without the index
    if ((config.Strategy == 1) or (config.R_Register == 1)):
        config.Connectivity_Mode = "SASD"
        logging.warning("WARNING! Configuration Strategy or R_Register set to 1. By default Connectivity Mode is SASD. Input ignored.") 
    elif (config.Strategy == 2):
        config.Connectivity_Mode = "SAMD"
        logging.warning("WARNING! Configuration Strategy set to 2. By default Connectivity Mode is SAMD. Input ignored.")
    else:
        if (retrieved != ""):
            if ((retrieved == "SASD") or (retrieved == "SAMD")):
                config.Connectivity_Mode = retrieved
            else:
                logging.warning("WARNING! Connectivity Mode invalid. Using default value (SASD).") 
        else:
            logging.warning("WARNING! Connectivity Mode invalid. Using default value (SASD).")
    return config

def read_Slave_Priority(config,row):
    #Reads every Slave Interface Priority
    #The range of possible values is [0 ; 16] whith 0 (Round-Robin) as deafault value
    #If the values are missing or are incorrect in the csv file, default value is used (input validity check is done for the single Slave)
    retrieved = row.to_string(index = False) #Gets row as String without the index
    values = []
    if (retrieved != ""):
        values = retrieved.split()
    if ((len(values) == config.SI_Number) and (retrieved != "")):
        for i in range(config.SI_Number):
            number = int(values[i])
            if (number in range(0,17)):
                config.Slave_Priorities.append(number)
            else:
                config.Slave_Priorities.append(0)
                if (i < 10):
                    logging.warning("WARNING! A Priority value is out-of-range [0 ; 16]. Using default value for this Slave." + " - S0" + str(i))
                else:
                    logging.warning("WARNING! A Priority value is out-of-range [0 ; 16]. Using default value for this Slave." + " - S" + str(i))
    else:
        for i in range(config.SI_Number):
            config.Slave_Priorities.append(0)
        logging.warning("WARNING! Not enough Priority values have been given. Using default values.")
    return config

def read_Acceptance(config,parameter,row):
    #Reads the number of Active Read or Write Transactions that each Slave Interface can generate
    #The range of possible values is [1 ; 32] whith 2 as deafault value
    #SASD => 1
    #If the value is missing or is incorrect in the csv file, default or coherent value is used (input validity check is done for the single Slave)
    retrieved = row.to_string(index = False) #Gets row as String without the index
    values = []
    if (retrieved != ""):
        values = retrieved.split()
    if (config.Connectivity_Mode == "SASD"):
        for i in range(config.SI_Number):
            match parameter:
            	case "SI_Read_Acceptance":
            		config.SI_Read_Acceptance.append(1)
            	case "SI_Write_Acceptance":
            		config.SI_Write_Acceptance.append(1)
        logging.warning("WARNING! Connectivity Mode set to SASD. By default every " + parameter + " value is set to 1. Input Ignored.")
    elif ((len(values) == config.SI_Number) and (retrieved != "")):
        for i in range(config.SI_Number):
            number = int(values[i])
            if (number in range(1,33)):
                match parameter:
                	case "SI_Read_Acceptance":
                		config.SI_Read_Acceptance.append(number)
                	case "SI_Write_Acceptance":
                		config.SI_Write_Acceptance.append(number)
            else:
                match parameter:
                	case "SI_Read_Acceptance":
                		config.SI_Read_Acceptance.append(2)
                	case "SI_Write_Acceptance":
                		config.SI_Write_Acceptance.append(2)
                if (i < 10):
                	logging.warning("WARNING! A " + parameter + " value is out-of-range [1 ; 32]. Using default value for this Slave." + " - S0" + str(i))
                else:
                       logging.warning("WARNING! A " + parameter + " value is out-of-range [1 ; 32]. Using default value for this Slave." + " - S" + str(i))
    else:
        for i in range(config.SI_Number):
                match parameter:
                	case "SI_Read_Acceptance":
                		config.SI_Read_Acceptance.append(2)
                	case "SI_Write_Acceptance":
                		config.SI_Write_Acceptance.append(2)
        logging.warning("WARNING! Not enough " + parameter + " values have been given. Using default values.")
    return config

def read_Thread_ID_Width(config,row):
    #Reads the number of ID bits used by each Slave Interface for its Thread IDs
    #For the moment whe don't use the and these numbers are set to 0, the default value (input validity check is done for the single Slave)
    retrieved = row.to_string(index = False) #Gets row as String without the index
    values = []
    if (retrieved != ""):
        values = retrieved.split()
    Bits_Available = math.floor(config.ID_Width - math.log2(config.SI_Number))
    if (Bits_Available < 0):
        Bits_Available = 0
    Bits_Available = 0 #At the moment we don't need them
    if (Bits_Available == 0):
        for i in range(config.SI_Number):
            config.Thread_ID_Width.append(0)
        logging.warning("WARNING! There are no bits available for Thread IDs. Setting all values to 0")
    elif ((len(values) == config.SI_Number) and (retrieved != "")):
        for i in range(config.SI_Number):
            number = int(values[i])
            if (number in range(1,Bits_Available+1)):
                config.Thread_ID_Width.append(number)
            else:
                config.Thread_ID_Width.append(0)
                if (i < 10):
                    logging.warning("WARNING! A Thread ID value is out-of-range [0 ; Bits_Available]. Using default value for this Slave." + " - S0" + str(i))
                else:
                    logging.warning("WARNING! A Thread ID value is out-of-range [0 ; Bits_Available]. Using default value for this Slave." + " - S" + str(i))
    else:
        for i in range(config.SI_Number):
            config.Thread_ID_Width.append(0)
        logging.warning("WARNING! Not enough Thread IDs values have been given. Using default values.")
    return config

def read_Single_Thread(config,row):
    #Reads the Silngle Thread Mode option for each Slave Interface
    #The range of possible values is [0 ; 1] whith 0 as deafault value
    #0 => Multiple Threads
    #1 => Single Thread
    #If the value is missing or is incorrect in the csv file, default value is used (input validity check is done for the single Slave)
    retrieved = row.to_string(index = False) #Gets row as String without the index
    values = []
    if (retrieved != ""):
        values = retrieved.split()
    if ((len(values) == config.SI_Number) and (retrieved != "")):
        for i in range(config.SI_Number):
            number = int(values[i])
            if (number in range(0,2)):
                config.Single_Thread.append(number)
            else:
                config.Single_Thread.append(0)
                if (i < 10):
                    logging.warning("WARNING! A Single Thread value is out-of-range [0 ; 1]. Using default value for this Slave." + " - S0" + str(i))
                else:
                    logging.warning("WARNING! A Single Thread value is out-of-range [0 ; 1]. Using default value for this Slave." + " - S" + str(i))
    else:
        for i in range(config.SI_Number):
            config.Single_Thread.append(0)
        logging.warning("WARNING! Not enough Single Thread values have been given. Using default values.")
    return config

def read_Base_ID(config,row):
    #Reads the 32 bit Base ID value for each Slave Interface
    #The range of possible values is [0x00000000 ; 0xffffffff] whith 0x00000000 as deafault value
    #If the value is missing or is incorrect in the csv file, default value is used
    #It also check input format validity
    retrieved = row.to_string(index = False) #Gets row as String without the index
    values = []
    if (retrieved != ""):
        values = retrieved.split()
    Correct_Format = True
    if ((len(values) != config.SI_Number) or (retrieved == "")):
        Correct_Format = False
    for i in range(config.SI_Number):
        if (Correct_Format == False):
            break
        if ((len(values[i]) != 10) or (values[i][0] != "0") or (values[i][1] != "x")):
            Correct_Format = False
            break
        for j in range(8):
            if ((ord(values[i][j+2]) in range(48,58)) or (ord(values[i][j+2]) in range (97,103))):
                continue
            else:
                Correct_Format = False
                break
    if ((len(values) == config.SI_Number) and (retrieved != "") and (Correct_Format == True)):
        for i in range(config.SI_Number):
            config.Base_ID.append(values[i])
    else:
        for i in range(config.SI_Number):
            config.Base_ID.append("0x00000000")
        logging.warning("WARNING! Not enough correct Base IDs values have been given. Using default values.")
    return config

def read_Issuing(config,parameter,row):
    #Reads the number of Active Read or Write Transactions that each Master Interface can generate
    #The range of possible values is [1 ; 32] whith 4 as deafault value
    #[AXI4LITE ; AXI3] => 1
    #If the value is missing or is incorrect in the csv file, default or coherent value is used (input validity check is done for the single Master)
    retrieved = row.to_string(index = False) #Gets row as String without the index
    values = []
    if (retrieved != ""):
        values = retrieved.split()
    if ((config.Protocol == "AXI3") or (config.Protocol == "AXI4LITE")):
        for i in range(config.MI_Number):
            match parameter:
            	case "MI_Read_Issuing":
            		config.MI_Read_Issuing.append(1)
            	case "MI_Write_Issuing":
            		config.MI_Write_Issuing.append(1)
        logging.warning("WARNING! Protocol is set to " + config.Protocol + ". By default every value is set to 1. Input Ignored.")
    elif ((len(values) == config.MI_Number) and (retrieved != "")):
        for i in range(config.MI_Number):
            number = int(values[i])
            if (number in range(1,33)):
                match parameter:
                	case "MI_Read_Issuing":
                		config.MI_Read_Issuing.append(number)
                	case "MI_Write_Issuing":
                		config.MI_Write_Issuing.append(number)
            else:
                match parameter:
                	case "MI_Read_Issuing":
                		config.MI_Read_Issuing.append(4)
                	case "MI_Write_Issuing":
                		config.MI_Write_Issuing.append(4)
                if (i < 10):
                    logging.warning("WARNING! An " + parameter + " value is out-of-range [1 ; 32]. Using default value for this Master." + " - M0" + str(i))
                else:
                    logging.warning("WARNING! An " + parameter + " value is out-of-range [1 ; 32]. Using default value for this Master." + " - M" + str(i))
    else:
        for i in range(config.MI_Number):
            match parameter:
            	case "MI_Read_Issuing":
            		config.MI_Read_Issuing.append(4)
            	case "MI_Write_Issuing":
            		config.MI_Write_Issuing.append(4)
        logging.warning("WARNING! Not enough correct " + parameter + " values have been given. Using default values.")
    return config

def read_Secure(config,row):
    #Reads the TrustZone Activation option for each Master Interface
    #The range of possible values is [0 ; 1] whith 0 as deafault value
    #0 => Non Secure
    #1 => Secure
    #If the value is missing or is incorrect in the csv file, default value is used (input validity check is done for the single Master)
    retrieved = row.to_string(index = False) #Gets row as String without the index
    values = []
    if (retrieved != ""):
        values = retrieved.split()
    if ((len(values) == config.MI_Number) and (retrieved != "")):
        for i in range(config.MI_Number):
            number = int(values[i])
            if (number in range(0,2)):
                config.Secure.append(number)
            else:
                config.Secure.append(0)
                if (i < 10):
                    logging.warning("WARNING! A Secure value is out-of-range [0 ; 1]. Using default value for this Master." + " - M0" + str(i))
                else:
                    logging.warning("WARNING! A Secure value is out-of-range [0 ; 1]. Using default value for this Master." + " - M" + str(i))
    else:
        for i in range(config.MI_Number):
            config.Secure.append(0)
        logging.warning("WARNING! Not enough correct Secure values have been given. Using default values.")
    return config

def read_Range_Base_Addr(config,row):
    #Reads every 64 bit Range Base Address for each Master Interface
    #The range of possible values is [0x0000000000000000 ; 0xffffffffffffffff] whith 0xffffffffffffffff (not used) as deafault value (0x0000000000100000 for the first Range of every Master)
    #If the value is missing or is incorrect in the csv file, default value is used
    #It also check input format validity
    retrieved = row.to_string(index = False) #Gets row as String without the index
    values = []
    if (retrieved != ""):
        values = retrieved.split()
    Correct_Format = True
    if ((len(values) != config.MI_Number*config.Addr_Ranges) or (retrieved == "")):
        Correct_Format = False
    for i in range(config.MI_Number*config.Addr_Ranges):
        if (Correct_Format == False):
            break
        if ((len(values[i]) != 18) or (values[i][0] != "0") or (values[i][1] != "x")):
            Correct_Format = False
            break
        for j in range(16):
            if ((ord(values[i][j+2]) in range(48,58)) or (ord(values[i][j+2]) in range (97,103))):
                continue
            else:
                Correct_Format = False
                break
    if ((len(values) == config.MI_Number*config.Addr_Ranges) and (retrieved != "") and (Correct_Format == True)):
        for i in range(config.MI_Number):
            for j in range(config.Addr_Ranges):
                config.Base_Addr.append(values[config.Addr_Ranges*i+j])
    else:
        for i in range(config.MI_Number):
            for j in range(config.Addr_Ranges):
                if (j == 0):
                    config.Base_Addr.append("0x0000000000100000")
                else:
                    config.Base_Addr.append("0xffffffffffffffff")
        logging.warning("WARNING! Not enough correct Ranges' Base Adress values have been given. Using default values.")
    return config

def read_Range_Width(config,row):
    #Reads every Range Address Width for each Master Interface. It must be inferior to the global Address Width
    #[AXI4 ; AXI3] => the range of possible values is [12 ; 64] whith 0 as deafault value (12 for the first Range of every Master)
    #AXI4LITE => the range of possible values is [1 ; 64] whith 0 as deafault value (12 for the first Range of every Master)
    #If the value is missing or is incorrect in the csv file, default or coherent value is used (input validity check is done for the single Master)
    retrieved = row.to_string(index = False) #Gets row as String without the index
    values = []
    if (retrieved != ""):
        values = retrieved.split()
    if ((len(values) == config.MI_Number*config.Addr_Ranges) and (retrieved != "")):
        if (config.Protocol == "AXI4LITE"):
            for i in range(config.MI_Number):
                for j in range(config.Addr_Ranges):
                    number = int(values[config.Addr_Ranges*i+j])
                    if ((number in range(1,65)) and (number <= config.Addr_Width)):
                        config.Range_Width.append(number)
                    elif (j == 0):
                        config.Range_Width.append(12)
                        if (i < 10):
                            logging.warning("WARNING! A Range's Width value is out-of-range [1 ; 64] or greater than global Address Width. Using default value for this Master." + " - M0" + str(i) + ", Range " + str(j))
                        else:
                            logging.warning("WARNING! A Range's Width value is out-of-range [1 ; 64] or greater than global Address Width. Using default value for this Master." + " - M" + str(i) + ", Range " + str(j))
                    else:
                        config.Range_Width.append(0)
                        if (i < 10):
                            logging.warning("WARNING! A Range's Width value is out-of-range [1 ; 64] or greater than global Address Width. Using default value for this Master." + " - M0" + str(i) + ", Range " + str(j))
                        else:
                            logging.warning("WARNING! A Range's Width value is out-of-range [1 ; 64] or greater than global Address Width. Using default value for this Master." + " - M" + str(i) + ", Range " + str(j))
        else:
            for i in range(config.MI_Number):
                for j in range(config.Addr_Ranges):
                    number = int(values[config.Addr_Ranges*i+j])
                    if ((number in range(12,65)) and (number <= config.Addr_Width)):
                        config.Range_Width.append(number)
                    elif (j == 0):
                        config.Range_Width.append(12)
                        if (i < 10):
                            logging.warning("WARNING! A Range's Width value is out-of-range [12 ; 64] or greater than global Address Width. Using default value for this Master." + " - M0" + str(i) + ", Range " + str(j))
                        else:
                            logging.warning("WARNING! A Range's Width value is out-of-range [12 ; 64] or greater than global Address Width. Using default value for this Master." + " - M" + str(i) + ", Range " + str(j))
                    else:
                        config.Range_Width.append(0)
                        if (i < 10):
                            logging.warning("WARNING! A Range's Width value is out-of-range [12 ; 64] or greater than global Address Width. Using default value for this Master." + " - M0" + str(i) + ", Range " + str(j))
                        else:
                            logging.warning("WARNING! A Range's Width value is out-of-range [12 ; 64] or greater than global Address Width. Using default value for this Master." + " - M" + str(i) + ", Range " + str(j))
    else:
        for i in range(config.MI_Number):
            for j in range(config.Addr_Ranges):
                    if (j == 0):
                        config.Range_Width.append(12)
                    else:
                        config.Range_Width.append(0)
        logging.warning("WARNING! Not enough correct Ranges' Width values have been given. Using default values.")
    return config

def read_Connectivity(config,parameter,row):
    #Reads the Activation option for each Master-Slave Connectione for Read or Write Transactions
    #The range of possible values is [0 ; 1] whith 1 as deafault value
    #0 => Connection Activated
    #1 => Connection Deactivated
    #If the value is missing or is incorrect in the csv file, default value is used (input validity check is done for the single Connection)
    retrieved = row.to_string(index = False) #Gets row as String without the index
    values = []
    if (retrieved != ""):
        values = retrieved.split()
    if ((len(values) == config.MI_Number*config.SI_Number) and (retrieved != "")):
        for i in range(config.MI_Number):
            for j in range(config.SI_Number):
                number = int(values[config.SI_Number*i+j])
                if (number in range(0,2)):
                    match parameter:
                    	case "Read_Connectivity":
                    		config.Read_Connectivity.append(number)
                    	case "Write_Connectivity":
                    		config.Write_Connectivity.append(number)
                else:
                    match parameter:
                    	case "Read_Connectivity":
                    		config.Read_Connectivity.append(1)
                    	case "Write_Connectivity":
                    		config.Write_Connectivity.append(1)
                    index = ""
                    if (i < 10):
                        index = " - M0" + str(i)
                    else:
                        index = " - M" + str(i)
                    if (j < 10):
                        index = index + "S0" + str(j)
                    else:
                        index = index + "S" + str(j)
                    logging.warning("WARNING! A " + parameter + " value is out-of-range [0 ; 1]. Using default value for this Master and Slave." + index)
    else:
        for i in range(config.MI_Number):
            for j in range(config.SI_Number):
                match parameter:
                	case "Read_Connectivity":
                		config.Read_Connectivity.append(1)
                	case "Write_Connectivity":
                		config.Write_Connectivity.append(1)
        logging.warning("WARNING! Not enough correct " + parameter + " values have been given. Using default values.")
    return config
