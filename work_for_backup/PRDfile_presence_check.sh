#!/bin/bash


storedir=/store/cpnr-data/RENE/Data/Data

nPRD=0

#for run in 1000 ;do
for run in {475..2223..1};do
    run_str=$(printf "%06d" "$run")
    found=0
    if [ -d "${storedir}/RAW/${run_str}" ]; then
        #echo $run_str

        if [ ! -d "${storedir}/RAW/${run_str}/PRD" ]; then
            mkdir -p ${storedir}/RAW/${run_str}/PRD
            mkdir -p ${storedir}/RAW/${run_str}/Merged
            mkdir -p ${storedir}/RAW/${run_str}/PNG
        fi

        for file in ${storedir}/RAW/${run_str}/PRD/*; do

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
            if [ $nFADC -gt $found ]; then # nfound > nPRD
                #echo Data/RAW/${run_str}/PRD/
                echo ${run_str}
            fi
        fi          

    fi
done
