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
                        CONFIG.AXI_ID_Width {2} \
			CONFIG.Use_Byte_Write_Enable {TRUE} \
                        CONFIG.Memory_Type {Simple_Dual_Port_RAM} \
                        CONFIG.Byte_Size {8} \
                        CONFIG.Assume_Synchronous_Clk {true} \
                        CONFIG.Write_Width_A {32} \
                        CONFIG.Write_Depth_A {1024} \
                        CONFIG.Read_Width_A {32} \
                        CONFIG.Operating_Mode_A {READ_FIRST} \
                        CONFIG.Write_Width_B {32} \
                        CONFIG.Read_Width_B {32} \
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
