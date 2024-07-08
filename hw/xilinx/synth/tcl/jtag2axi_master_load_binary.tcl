# ------------------------------------------------------------------------
# /https://github.com/MaistoV/UninaSoC/blob/main/hw/xilinx/rtl/uninasoc.sv#L1 :
# Author: Zaira Abdel Majid <z.abdelmajid@studenti.unina.it>
# Description: tcl script used to transfer a .bin file in a BRam memory using jtag2axi IP and axi transactions
# Input args: 
#	-argv0: absolute path to bin file to transfer. IMPORTANT! Write absolute path between two high quotes with double slashs 
#	i.e. "C:\\Users\\user\\Downloads\\blink.bin"
#	-argv1: base address of BRAM
# Internal variables: 
#	-data_list: binary file read at absolute path
#	-num_bursts: size of each "burst" (data sent) in each transaction in bytes (4= 32 bits). This parameter is architecture dependent.
#	-remaining bytes: reminder in terms of bytes that will handled with padding. 
#	-segment: chunk of 4 bytes extracted from data_lists and converted in hexadecimal
#
#IMPORTANT: if after 100 reps. vivado omits output of transaction, just type the following command in tcl console
#set_msg_config -id {Labtoolstcl 44-481} -limit 0
#
#*********************************************************



proc read_file_to_words {filename fsize} {

#function to read binary file 
    set fp [open $filename r]
	fconfigure $fp -translation binary


    set file_data [read $fp $fsize]
    close $fp

   # set data_list [split $file_data "\n"]
    return $file_data
}

if { $argc != 2 } {
    puts "This script requires two args to be inputed."
    puts "Please try again."
} else {
    set filename [lindex $argv 0]
	set base_address [lindex $argv 1]
    }

# Init

set fsize [file size $filename]; #get file size in bytes
set gpio_wt gpio_wt ;
set gpio_rt gpio_rt;
create_hw_axi_txn $gpio_rt [get_hw_axis hw_axi_1] -type read -force -address $base_address  ;

set data_list [read_file_to_words $filename $fsize]; # Read the file
set burst_size 4  ; #4 byte 
set num_bursts [expr {int( $fsize / $burst_size)}]; #how many transaction there will be
set remaining_bytes [expr {$fsize % $burst_size}]

for {set i 0} {$i < $num_bursts} {incr i} {
set segment [string range $data_list [expr {$i * 4}] [expr {$i * 4 + 3}]]; #select segment to read
binary scan $segment H* Memword;

set address [format 0x%x [expr {$base_address + $i * 4}]]; #calculate address
create_hw_axi_txn $gpio_wt [get_hw_axis hw_axi_1] -type write -force -address $address -data $Memword -len 4; #len= 4 bytes
run_hw_axi [get_hw_axi_txns $gpio_wt]; #execute transaction
puts $address; #debug
}

if {$remaining_bytes > 0} {
 set start [expr {$num_bursts * $burst_size}] 
    set segment [string range $data_list $start end]; #read the remaining bytes 

   
    append segment [string repeat \0 [expr {$burst_size - $remaining_bytes}]]; #append 0

    binary scan $segment H* word; #convert in hex

    # execute axi transaction
    set address [format 0x%x [expr {$base_address + ($num_bursts * 4)}]]
    create_hw_axi_txn $gpio_wt [get_hw_axis hw_axi_1] -type write -force -address $address -data $word -len 4;
    run_hw_axi [get_hw_axi_txns $gpio_wt] ;# esegui la transazione
}



#decomment to start transactions to read from memory

#for {set i 0} {$i < $num_bursts} {incr i} {
#set address [format 0x%x [expr {$base_address + $i * 4}]]; #elabora l'indirizzo
#create_hw_axi_txn $gpio_rt [get_hw_axis hw_axi_1] -type read -force -address $address  ;
#run_hw_axi [get_hw_axi_txns $gpio_rt]; #esegui la transazione
#}
