# Import IP
create_ip -name blk_mem_gen -vendor xilinx.com -library ip -version 8.4 -module_name $::env(IP_NAME)

# COE file to pre-load in BRAM
# set coe_file $::env(BOOTROM_COE)
# For now, just no preload
set coe_file no_coe_file_loaded

# Configure IP
set_property -dict [list CONFIG.Interface_Type {AXI4} \
                        CONFIG.AXI_Slave_Type {Memory_Slave} \
			CONFIG.Use_AXI_ID {true} \
			CONFIG.Use_Byte_Write_Enable {TRUE} \
                        CONFIG.Memory_Type {Simple_Dual_Port_RAM} \
                        CONFIG.Byte_Size {8} \
                        CONFIG.Assume_Synchronous_Clk {true} \
                        CONFIG.Operating_Mode_A {READ_FIRST} \
                        CONFIG.Operating_Mode_B {READ_FIRST} \
                        CONFIG.Enable_B {Use_ENB_Pin} \
                        CONFIG.Register_PortA_Output_of_Memory_Primitives {false} \
                        CONFIG.Use_RSTB_Pin {true} \
                        CONFIG.Reset_Type {ASYNC} \
                        CONFIG.Port_B_Clock {100} \
                        CONFIG.Port_B_Enable_Rate {100} \
                        CONFIG.EN_SAFETY_CKT {true} \
                        CONFIG.Load_Init_File {false} \
                        CONFIG.Coe_File {$coe_file} \
                        CONFIG.Fill_Remaining_Memory_Locations {true} \
                ] [get_ips $::env(IP_NAME)]

# Use envvars out of list
set_property CONFIG.Write_Width_A $::env(DATA_WIDTH)     [get_ips $::env(IP_NAME)]
set_property CONFIG.Read_Width_A  $::env(DATA_WIDTH)     [get_ips $::env(IP_NAME)]
set_property CONFIG.Write_Width_B $::env(DATA_WIDTH)     [get_ips $::env(IP_NAME)]
set_property CONFIG.Read_Width_B  $::env(DATA_WIDTH)     [get_ips $::env(IP_NAME)]
set_property CONFIG.AXI_ID_Width  $::env(ID_WIDTH)       [get_ips $::env(IP_NAME)]

# Get the BRAM depth
set bram_depths [split $::env(BRAM_DEPTHS) " "]
# This file is the config for the first BRAM occurrence, hence it uses the index 0
# To add another BRAM, for now, you must add another BRAM occurrence in the CSV file and another configuration tcl with the right index
set_property CONFIG.Write_Depth_A [lindex $bram_depths 0] [get_ips $::env(IP_NAME)]
