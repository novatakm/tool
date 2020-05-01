#!/usr/bin/env bash

if [ "$1" = "-h" ]; then
    cat <<EOF
`basename $0` L8_DATA_ID L8_tmp_dir
EOF
    exit
fi

FN=$$
DATA_ID=$1
TMP_DIR=$2

SCRIPT_DIR=$( cd $( dirname $0 ); pwd)

function wfd_day(){
    
    prm_file=${TMP_DIR}/PRM$FN
    # export a raster as a binary and generate the parameter file
    eval `g.region -pg rast=${DATA_ID}_PR7`
    echo "${cols} ${rows}" > ${prm_file}
    for bn in 1 2 3 4 5 6 7
    do
        r.out.bin -f in=${DATA_ID}_PR${bn} out=${TMP_DIR}/PR${bn}$FN bytes=8
        echo "${TMP_DIR}/PR${bn}$FN" >> ${prm_file}
    done
    echo "${TMP_DIR}/DET$FN" >> ${prm_file}
    
    # fire detection
    ${SCRIPT_DIR}/L8_wfd_day ${prm_file}
    
    # import detection map rasters into GRASS
    r.in.bin in=${TMP_DIR}/DET$FN out=${DATA_ID}_DET bytes=1 anull=-1 \
    n=$n s=$s w=$w e=$e rows=$rows cols=$cols --o
}

function main(){
    wfd_day
}

main
