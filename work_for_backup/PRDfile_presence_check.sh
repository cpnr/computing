#!/bin/bash


storedir=/store/cpnr-data/RENE/Data/Data

nPRD=0

for run in {475..2223..1};do
    run_str=$(printf "%06d" "$run")
    found=0
    if [ -d "Data/RAW/${run_str}" ]; then
        #echo $run_str
        for file in Data/RAW/${run_str}/PRD/*; do

            if [ -f "$file" ]; then
                found=1

                nPRD=`ls -l $dirname/PRD/* |wc -l`
            fi

        done

        dirname=$storedir/RAW/$run_str
        nFADC=`ls -l $dirname/FADC* |wc -l`

        if [ $found -eq 0 ]; then
            #echo Data/RAW/${run_str}/PRD/
            echo ${run_str}
        else
            if [ $found -gt $nPRD ]; then # nfound > nPRD
                #echo Data/RAW/${run_str}/PRD/
                echo ${run_str}
            fi
        fi          

    fi
done
