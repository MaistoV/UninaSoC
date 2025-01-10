#!/bin/bash
# Author: Manuel Maddaluno <manuel.maddaluno@unina.it>
# Description: Load a binary into the SoC memory through the XDMA and PCIe
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
hex_file=$(xxd -p -c 9999999999 $FILE_NAME);

# Set the transaction size in bytes
trans_size=64; # XDMA supports 64-bytes transactions
# Set size of endianess flip
#   Every four bytes, we read 0x01234567 (nibble-order) from file (least to most significant byte),
#   but we actually need to write those nibbles as 0x67543201 (most to least significant byte)
endianess_flip_size=4;
# Number of flips per transaction
num_flips_per_trans=$(($trans_size/$endianess_flip_size))

# Compute number of transactions
num_trans=$(($FILE_SIZE/$trans_size));
remaining_bytes=$(($FILE_SIZE%$trans_size));

# Print warning
if [ $remaining_bytes -ne 0 ]; then
    echo "[WARINING] Binary is has pending $remaining_bytes bytes past the $trans_size-byte aligned size, ignoring last bytes..." >&2
fi

# Golden result for later readback check
golden_hex=""

# Write the binary
addr=$BASE_ADDRESS;
echo "Start writing...";
# For each transaction
for i in $(seq 0 $(($num_trans -1)));
do
    # Clear accumulator
    hex_data="";

    # For flips in a single transaction
    for k in $(seq 1 $(($num_flips_per_trans)));
    do
        # Clear accumulator
        flipped_hex_data="";

        # Flip endiannes from string (0x01234567 -> 0x67543201)
        # For each byte in $endianess_flip_size
        for((j=$k*2*$endianess_flip_size-2; j>$(($k-1))*2*$endianess_flip_size-2; j=j-2));
        do
            # Append a single byte (2 nibbles slice)
            flipped_hex_data=${flipped_hex_data}${hex_file:$((j + i*$trans_size*2)):$((2))}
        done

        # Append
        hex_data=${hex_data}${flipped_hex_data}
    done

    # Write to BAR-mapped physical address
    sudo busybox devmem 0x$hex_addr $(($trans_size*8)) 0x$hex_data

    # Increment address
    addr=$(($addr + $trans_size));

    # Save for readback
    if [[ ${READBACK} == "true" ]];
    then
        # Append to old
        golden_hex=${golden_hex}${hex_data}
    fi
done

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
        readback_data=${readback_data}$( sudo busybox devmem 0x$hex_addr $(($trans_size*8)) );
        addr=$(($addr+$trans_size));
    done

    echo "Readback complete!";
    echo "Golden hexadecimal binary:";
    echo $golden_hex;
    echo "Readback hexadecimal data:";
    echo $readback_data;

    # Check they are the same
    if [[ ${golden_hex} == ${readback_data} ]];
    then
        echo "Test passed :)";
    else
        echo "Test failed :(";
    fi
fi
