#!/bin/bash

SRC_BASE="Data_ssd/RAW"
DST_BASE="Data/RAW"

for SRC_DIR in "${SRC_BASE}"/*; do

    echo "SRC DIR : $SRC_DIR"

    runNumber=$(basename "$SRC_DIR")
    DST_DIR="${DST_BASE}/${runNumber}"

    if [ ! -d "$DST_DIR" ]; then
        mkdir "$DST_DIR"
        echo "Created directory: $DST_DIR"
    fi

    rsync -av --ignore-existing \
          "${SRC_DIR}/" \
          "${DST_DIR}/"
done

