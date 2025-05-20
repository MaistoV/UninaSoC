
# Description: tcl script used to read back from AXI
# Input args:
#    -argv0: base address
#    -argv1: number of transactions

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
puts "Usage <base_address> <num_bytes>"
puts "base_address  : base address"
puts "num_bytes     : number of bytes"
if { $argc != 2 } {
    # Default
    set base_address    0x0000
    set num_bytes       16
} else {
    set base_address    [lindex $argv 0]
    set num_bytes       [lindex $argv 1]
}

########
# Init #
########

# Disable message limit
set_msg_config -id {Labtoolstcl 44-481} -limit 99999

# AXI transaction names
set gpio_wr_txn gpio_wr_txn
set gpio_rd_txn gpio_rd_txn

# Bytes per burst
set burst_size 4
# Number of $burst_size-bytes transaction
set num_bursts [expr {int( $num_bytes / $burst_size)}]

#########################
# Read-back from memory #
#########################

for {set i 0} {$i < $num_bursts} {incr i} {
    # Compose address
    set address [format 0x%x [expr {$base_address + $i * $burst_size}]]

    # Debug
    puts "Reading from address $address"

    # Create and run transaction
    create_hw_axi_txn $gpio_rd_txn [get_hw_axis hw_axi_1] -type read -force -address $address
    run_hw_axi [get_hw_axi_txns $gpio_rd_txn]

}

############
# Clean up #
############
# Restore message limit
reset_msg_config -id {Labtoolstcl 44-481} -limit