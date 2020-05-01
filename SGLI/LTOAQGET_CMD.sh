#!/usr/bin/env bash

#
# FTPGET_LTOACLFG.sh 
#/standard/GCOM-C/GCOM-C.SGLI/L2.LAND.LTOA/1/2018/01

FN=$$
YYYY=$1
MM=$2
VV=$3
HH=$4

TOPDIR="/standard/GCOM-C/GCOM-C.SGLI"
LTOADIR="${TOPDIR}/L2.LAND.LTOA/1"
CLFGDIR="${TOPDIR}/L2.ATMOS.CLFG/1"
USER="takmiura35"
PSWD="anonymous"

NDAY[1]=31
if [ `isly ${YYYY}` -eq 1 ]; then
    NDAY[2]=29
else
    NDAY[2]=28
fi
NDAY[3]=31
NDAY[4]=30
NDAY[5]=31
NDAY[6]=30
NDAY[7]=31
NDAY[8]=31
NDAY[9]=30
NDAY[10]=31
NDAY[11]=30
NDAY[12]=31

function LTOA_cmd_gnrtr(){

    cat <<EOF
open ftp.gportal.jaxa.jp
user ${USER} ${PSWD}
bin
prompt
EOF

    mm=`echo $MM | awk '{printf("%d", $1)}'`
    for dd in `jot -w %02d ${NDAY[$mm]} 1`
    do
	cat <<EOF
cd ${LTOADIR}/${YYYY}/${MM}/${dd}/
mget *_T${VV}${HH}_*_LTOAQ_*
EOF
    done

    cat <<EOF
quit
EOF
}

function main(){

    LTOA_cmd_gnrtr
}

main
