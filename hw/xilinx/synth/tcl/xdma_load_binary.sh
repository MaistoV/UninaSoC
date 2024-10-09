#!/bin/bash
# Author: Manuel Maddaluno <manuel.maddaluno@unina.it>
# This is a bash script in the "tcl" directory ...

EXPECTED_ARGC=3;
ARGC=$#;

# Print the right usage
help (){
    echo  "Usage: source ${BASH_SOURCE[0]} <file_name> <base_address> <read_back>";
    echo  "    binary_file   :  path to bin file to transfer";
    echo  "    base_address  :  base address of BRAM";
    echo  "    read_back     :  whether to read-back data after writing";
    return;
}

# Check the argc
if [ $ARGC -ne $EXPECTED_ARGC ]; 
then
    echo  "Invalid number of arguments, please check the inputs and try again";
    help;
    return 1;
fi

# Get the args
FILE_NAME=$1;
BASE_ADDRESS=$2;
READBACK=$3;

# Get the file size in bytes
FILE_SIZE=$(stat -c%s "$FILE_NAME");

# Read the entire file in hexadecimal
hex_file=$(xxd -p -u -c 9999999999 $FILE_NAME);

# Set the transaction size to 8 bytes
trans_size=4;

num_trans=$(($FILE_SIZE/$trans_size));
remaining_bytes=$(($FILE_SIZE%$trans_size));

# Write the binary
addr=$BASE_ADDRESS;
echo "Start writing...";

for i in $(seq 0 $(($num_trans-1)));
do
    hex_data=${hex_file:$(($i*$trans_size*2)):$(($trans_size*2))};
    hex_addr=$(printf "%x" $addr);
    sudo busybox devmem 0x$hex_addr $(($trans_size*8)) 0x$hex_data;
    addr=$(($addr+$trans_size));
done

# Write remaining bytes
if [ $remaining_bytes -gt 0 ]; 
then
    hex_data=${hex_file:$((($i+1)*$trans_size*2)):$remaining_bytes*2};
    hex_addr=$(printf "%x" $addr);
    sudo busybox devmem 0x$hex_addr $(($trans_size*8)) 0x$hex_data;
fi

echo "Write complete!";

# Readback
if [[ ${READBACK} == "true" ]]; 
then
    echo "Start readback...";
    addr=$BASE_ADDRESS;
    readback_data="";
    for i in $(seq 0 $(($num_trans-1)));
    do
        hex_addr=$(printf "%x" $addr);
        read_data=$( sudo busybox devmem 0x$hex_addr $(($trans_size*8)) );
        readback_data=$readback_data${read_data:2:$(($trans_size*2))};
        addr=$(($addr+$trans_size));
    done
    if [ $remaining_bytes -gt 0 ]; 
    then
        hex_addr=$(printf "%x" $addr);
        read_data=$( sudo busybox devmem 0x$hex_addr $(($trans_size*8)) );
        remaining_index=$((($trans_size-$remaining_bytes)*2));
        readback_data=$readback_data${read_data:$((2+$remaining_index)):$(($trans_size*2))};
    fi
    echo "Readback complete!";
    echo "Original hexadecimal binary:";
    echo $hex_file;
    echo "Readback hexadecimal data:";
    echo $readback_data; 

    if [[ ${hex_file} == ${readback_data} ]];
    then
        echo "Test passed :)";
    else 
        echo "Test failed :(";
    fi
fi
