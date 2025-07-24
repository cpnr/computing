#!/bin/bash

#if [ $# -ne 2 ]; then
#    echo "usage: $0 <folderA> <folderB>"
#    exit 1
#fi

dirname_1=Data/RAW 
dirname_2=Data_ssd/RAW


for run in {1..2300..1}
do

    #DIR_A="$1"
    #DIR_B="$2"
    DIR_A=${dirname_1}/${run}
    DIR_B=${dirname_2}/${run}


    # tmp file
    FILES_A=$(mktemp)
    FILES_B=$(mktemp)

    find "$DIR_A" -type f | sed "s|^$DIR_A/||" | sort > "$FILES_A"
    find "$DIR_B" -type f | sed "s|^$DIR_B/||" | sort > "$FILES_B"

    #echo "same file:"
    #comm -12 "$FILES_A" "$FILES_B"
    #echo

    echo "only in ${DIR_A}:"
    comm -23 "$FILES_A" "$FILES_B"
    echo

    echo "only in ${DIR_B}:"
    comm -13 "$FILES_A" "$FILES_B"
    echo

    # remove tmp file
    rm -f "$FILES_A" "$FILES_B"

done
