#!/bin/bash



storedir=/store/cpnr-data/RENE/Data/Data

echo "runN,nFADC,nSADC"

for run in {1..2223..1};do
    run_str=$(printf "%06d" "$run")

    #echo "$run_str"

    dirname=$storedir/RAW/$run_str

    if [ -d "$storedir/RAW/${run_str}" ]; then
        nn=`ls -l $storedir/RAW/${run_str} |wc -l`
        if [ ${nn} -ne 3 ];then
            nFADC=`ls -l $dirname/FADC* |wc -l`
            nSADC=`ls -l $dirname/SADC* |wc -l`
            echo "${run_str},${nFADC},${nSADC}"
        fi

        if [ ${nn} -eq 3 ];then
            echo "${run_str},0,0"
        fi
    fi

    if [ ! -d "$storedir/RAW/${run_str}" ]; then
        echo "${run_str},0,0"
    fi

done 

