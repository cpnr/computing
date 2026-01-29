for runN in {1..2101..1};do
    RunStr=$(seq -f "%06g" ${runN} ${runN})
    if [ -d "Data/RAW/${RunStr}" ];then
        echo "remove ${RunStr}/Merged/*.root.*"
        rm Data/RAW/${RunStr}/Merged/*.root.*
    fi
done


