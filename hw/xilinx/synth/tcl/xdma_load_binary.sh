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
hex_file=$(xxd -p -u -c 9999999999 $FILE_NAME);
# echo $hex_file

# Set the transaction size in bytes
trans_size=8;

num_trans=$(($FILE_SIZE/$trans_size));
remaining_bytes=$(($FILE_SIZE%$trans_size));

# Write the binary
addr=$BASE_ADDRESS;
# echo "Start writing...";

num_trans=4
for i in $(seq 1 $(($num_trans)));
do
    # NOTE: for now assumes fixed-width 4-bytes instructions, i.e.:
    #   - no C-extension
    #   - no 8-byte (or longer) transactions
    # if [ $trans_size != 4 ]; then
    #     echo "Unsupported trans_size=$trans_size! Supported value is 4, for now." >&2
    #     return 1
    # fi
    hex_data="";
    # Invert endiannes from string (0xAABBCCDD -> 0xDDCCBBAA)
    # for((j=$trans_size*$i*2-1+$trans_size*2;j>=$i*2*$trans_size;j=j-2));
    # do
    #     hex_data=${hex_data}${hex_file:$((j-1)):$((2))};
    # done
    # for((j=$trans_size*$i*2-1+$trans_size*2;j>=$i*2*$trans_size;j=j-2));
    for((j=$i*2*$trans_size-2;j>$(($i-1))*2*$trans_size-2;j=j-2));
    do
        # echo $i: {$j $(($j +1))}
        hex_data=${hex_data}${hex_file:$((j)):$((2))};
    done

    echo "0x$hex_data"

    hex_addr=$(printf "%x" $addr);
    # sudo busybox devmem 0x$hex_addr $(($trans_size*8)) 0x$hex_data;
    addr=$(($addr+$trans_size));
done

# Write remaining bytes
if [ $remaining_bytes -gt 0 ];
then
    hex_data="";

    # Invert endiannes from string (0xAABBCCDD -> 0xDDCCBBAA)
    # NOTE: for now assumes fixed-width 4-bytes instructions, i.e.:
    #   - no C-extension
    #   - no 8-byte (or longer) transactions
    if [ $trans_size != 4 ]; then
        echo "Unsupported trans_size=$trans_size! Supported value is 4, for now." >&2
        return 1
    fi
    for((j=$trans_size*($i+1)*2-1+$remaining_bytes*2;j>=($i+1)*2*$trans_size;j=j-2));
    do
        hex_data=${hex_data}${hex_file:$((j-1)):$((2))};
    done
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
        read_data=${read_data:$((2))};
        tmp_data="";

        # Restore the inverse endianness reading the data
        for((j=$trans_size*2-1;j>=0;j=j-2));
        do
            tmp_data=${tmp_data}${read_data:$((j-1)):$((2))};
        done

        readback_data=$readback_data${tmp_data};

        addr=$(($addr+$trans_size));
    done

    if [ $remaining_bytes -gt 0 ];
    then
        hex_addr=$(printf "%x" $addr);
        read_data=$( sudo busybox devmem 0x$hex_addr $(($trans_size*8)) );
        read_data=${read_data:$((2))};
        tmp_data="";

        # Restore the inverse endianness reading the data
        for((j=$trans_size*2-1;j>=0;j=j-2));
        do
            tmp_data=${tmp_data}${read_data:$((j-1)):$((2))};
        done
        remaining_index=$((($trans_size-$remaining_bytes)*2));
        readback_data=$readback_data${tmp_data:$((0)):$(($remaining_index))};
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
