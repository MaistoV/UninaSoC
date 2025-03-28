#!/bin/bash

# rm_list=$(cat rm_files)

# Init
# cp assets/filelist.txt assets/filelist.light.txt

# # Remove line by line
# for file in $rm_list; do
#     grep $file -v assets/filelist.light.txt > tmp
#     mv tmp assets/filelist.light.txt
# done



keep_list=$(cat keep_files)

# Init
rm assets/filelist.light.txt

# Remove line by line
for file in $keep_list; do
    grep $file assets/filelist.txt >> assets/filelist.light.txt
done