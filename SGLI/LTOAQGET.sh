#!/usr/bin/env bash

#
# FTPGET_LTOACLFG.sh
#/standard/GCOM-C/GCOM-C.SGLI/L2.LAND.LTOA/1/2018/01

usage() {
    echo $(basename $0)
    echo "-m <year-month in YYYYMM format>"
    echo "-t <tile number in VVHH format>"
    exit 0
}

FN=$$

while getopts m:t:h OPT
do
    case $OPT in
        m)
            YYYYMM=$OPTARG
        ;;
        t)
            VVHH=$OPTARG
        ;;
        h)
            usage
        ;;
        \?)
            usage
        ;;
    esac
done

FN=$$
YYYY=$( echo $YYYYMM | cut -c 1-4 )
MM=$( echo $YYYYMM | cut -c 5-6 )
VV=$( echo $VVHH | cut -c 1-2 )
HH=$( echo $VVHH | cut -c 3-4 )

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

# function LTOA_get_cmd(){

# }

# function CLFG_get_cmd(){

# }

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
    
    LTOA_cmd_gnrtr > /tmp/CMD$FN
    ftp -n < /tmp/CMD$FN
    
    #cat /tmp/CMD$FN
    rm /tmp/CMD$FN
}

main
