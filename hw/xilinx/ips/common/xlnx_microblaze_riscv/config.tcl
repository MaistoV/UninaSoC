# Import IP by version
create_ip -name microblaze_riscv -vendor xilinx.com -library ip -version 1.0 -module_name $::env(IP_NAME)

# Configure IP
set_property -dict [list \
        CONFIG.C_DEBUG_ENABLED {1} \
        CONFIG.C_ENABLE_DISCRETE_PORTS {0} \
        CONFIG.C_D_AXI {1} \
        CONFIG.C_I_AXI {1} \
        CONFIG.C_USE_DCACHE {0} \
        CONFIG.C_USE_ICACHE {0} \
        CONFIG.C_D_LMB {0} \
        CONFIG.C_I_LMB {0} \
        CONFIG.C_OPTIMIZATION {0} \
        CONFIG.C_USE_BARREL {1} \
        CONFIG.C_USE_COUNTERS {1} \
        CONFIG.C_M_AXI_D_BUS_EXCEPTION {0} \
        CONFIG.C_M_AXI_I_BUS_EXCEPTION {0} \
        CONFIG.C_ILL_INSTR_EXCEPTION {2} \
    ] [get_ips $::env(IP_NAME)]

###############################
# AXI interconnect parameters #
###############################
# Data width
set_property CONFIG.C_DATA_SIZE $::env(AXI_DATA_WIDTH) [get_ips $::env(IP_NAME)]
# Address width is fixed equal to data width
# set_property CONFIG.ADDR_WIDTH  $::env(AXI_ADDR_WIDTH)  [get_ips $::env(IP_NAME)]
# AXI ID width is fixed to 1
# set_property CONFIG.ID_WIDTH    $::env(AXI_ID_WIDTH)    [get_ips $::env(IP_NAME)]

#####################
# RISC-V Extensions #
#####################
# Set configuration preset (1: Microcontroller, 2: Real-time, 4: RVIMC, 5: RVIMAC, 6: RVIMAFC)
set_property CONFIG.G_TEMPLATE_LIST         {1} [get_ips $::env(IP_NAME)]
# C-ext
set_property CONFIG.C_USE_COMPRESSION       {1} [get_ips $::env(IP_NAME)]
# A-ext
set_property CONFIG.C_USE_ATOMIC            {0} [get_ips $::env(IP_NAME)]
# M-ext (1: STANDARD; 2: OPTIMIZED)
set_property CONFIG.C_USE_MULDIV            {0} [get_ips $::env(IP_NAME)]
# F-ext
set_property CONFIG.C_USE_FPU               {0} [get_ips $::env(IP_NAME)]
# Bit-manipulation
set_property CONFIG.C_USE_BITMAN_A          {0} [get_ips $::env(IP_NAME)]
set_property CONFIG.C_USE_BITMAN_B          {0} [get_ips $::env(IP_NAME)]
set_property CONFIG.C_USE_BITMAN_C          {0} [get_ips $::env(IP_NAME)]
set_property CONFIG.C_USE_BITMAN_S          {0} [get_ips $::env(IP_NAME)]
# PMP entries and granularity
set_property CONFIG.C_PMP_ENTRIES           {0} [get_ips $::env(IP_NAME)]
set_property CONFIG.C_PMP_GRANULARITY       {2} [get_ips $::env(IP_NAME)]
# Enable User mode
set_property CONFIG.C_USE_MMU               {0} [get_ips $::env(IP_NAME)]
# Illegal instruction exception (1:BASIC, 2: COMPLETE)
set_property CONFIG.C_ILL_INSTR_EXCEPTION   {2} [get_ips $::env(IP_NAME)]
