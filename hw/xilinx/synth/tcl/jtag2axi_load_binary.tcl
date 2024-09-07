# Author: Zaira Abdel Majid <z.abdelmajid@studenti.unina.it>
# Author: Vincenzo Maisto <vincenzo.maisto2@unina.it>
# Description: tcl script used to transfer a .bin file in a BRAM memory using jtag2axi IP and axi transactions
# Input args:
#	-argv0: absolute path to bin file to transfer
#	-argv1: base address of BRAM
#	-argv2: whether to read-back data after writing

#########
# Utils #
#########

# Utility function to read binary file
proc read_file_to_words {filename fsize} {
    # Open file
    set fp [open $filename r]

    # Translate file to binary
	fconfigure $fp -translation binary

    # Read data
    set file_data [read $fp $fsize]

    # Close file
    close $fp

    # Return
    return $file_data
}

##############
# Parse args #
##############
if { $argc != 3 } {
    puts "Usage <filename> <base_address> <read_back>"
    puts "filename      : path to bin file to transfer"
    puts "base_address  : base address of BRAM"
    puts "read_back     : whether to read-back data after writing"
    return
} else {
    set filename        [lindex $argv 0]
	set base_address    [lindex $argv 1]
	set read_back       [lindex $argv 2]
}

########
# Init #
########

# Disable message limit
set_msg_config -id {Labtoolstcl 44-481} -limit 99999

# Connects to hw_server and sets variable hw_device
source $::env(XILINX_SYNTH_TCL_ROOT)/open_hw_manager.tcl

# File size in bytes
set fsize [file size $filename]

# AXI transaction names
set gpio_wr_txn gpio_wr_txn
set gpio_rd_txn gpio_rd_txn

# Test read transaction
# puts "create_hw_axi_txn $gpio_rd_txn [get_hw_axis hw_axi_1] -type read -force -address $base_address"
# puts [get_hw_axis hw_axi_1]
# create_hw_axi_txn $gpio_rd_txn [get_hw_axis hw_axi_1] -type read -force -address $base_address

# Internal variables:
#	-data_list: binary file read at absolute path
#	-num_bursts: size of each "burst" (data sent) in each transaction in bytes (4= 32 bits). This parameter is architecture dependent.
#	-remaining bytes: reminder in terms of bytes that will handled with padding.
#	-segment: chunk of 4 bytes extracted from data_lists and converted in hexadecimal

# Read file
set data_list [read_file_to_words $filename $fsize]
# 4 bytes
set burst_size 4
# Number of 4-bytes transaction
set num_bursts [expr {int( $fsize / $burst_size)}]
# Remining bytes
set remaining_bytes [expr {$fsize % $burst_size}]

###################
# Write to memory #
###################
# Run burst-based transactions
for {set i 0} {$i < $num_bursts} {incr i} {
    # Select segment to read
    set segment [string range $data_list [expr {$i * 4}] [expr {$i * 4 + 3}]]
    # Convert to binary
    binary scan $segment H* Memword

    # Calculate address
    set address [format 0x%x [expr {$base_address + $i * 4}]]

    # Create and run transaction
    create_hw_axi_txn $gpio_wr_txn [get_hw_axis hw_axi_1] -type write -force -address $address -data $Memword -len 4
    run_hw_axi [get_hw_axi_txns $gpio_wr_txn]

    # Debug
    # puts "Writing to address $address"
}

# Run for remaining bytes
if {$remaining_bytes > 0} {
    # Read remaining bytes
    set start [expr {$num_bursts * $burst_size}]
    set segment [string range $data_list $start end]

    append segment [string repeat \0 [expr {$burst_size - $remaining_bytes}]]

    # Convert in hex
    binary scan $segment H* word

    # Compose address
    set address [format 0x%x [expr {$base_address + ($num_bursts * 4)}]]

    # Execute axi transaction
    create_hw_axi_txn $gpio_wr_txn [get_hw_axis hw_axi_1] -type write -force -address $address -data $word -len 4
    run_hw_axi [get_hw_axi_txns $gpio_wr_txn]

    # Debug
    # puts "Writing to address $address"
}


#########################
# Read-back from memory #
#########################

if { $read_back == "true" } {
    for {set i 0} {$i < $num_bursts} {incr i} {
        # Compose address
        set address [format 0x%x [expr {$base_address + $i * 4}]]

        # Create and run transaction
        create_hw_axi_txn $gpio_rd_txn [get_hw_axis hw_axi_1] -type read -force -address $address
        run_hw_axi [get_hw_axi_txns $gpio_rd_txn]

        # Debug
        # puts "Reading from to address $address"
    }
}

############
# Clean up #
############
# Restore message limit
reset_msg_config -id {Labtoolstcl 44-481} -limit