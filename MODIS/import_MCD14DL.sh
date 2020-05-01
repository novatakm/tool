#!/usr/bin/env bash

usage(){
    echo $( basename $0 )
    echo "-g <GISDBASE path>"
    echo "-i <input MCD14DL shpfile name>"
    echo "-s <start_date to import (in yyyymmdd format)>"
    echo "-e <end_date to import (in yyyymmdd format)>"
    echo "-o <imported vector name>"
    echo "-t <tile number (in VxxHxx format)>"
    echo "-h help"
    exit
}

while getopts g:i:t:o:s:e:h  OPT
do
    case $OPT in
        g)
            GISDBASE=$OPTARG
        ;;
        i)
            MCD14DL_FILE=$OPTARG
        ;;
        s)
            START_DATE=$OPTARG
        ;;
        e)
            END_DATE=$OPTARG
        ;;
        t)
            TILE=$OPTARG
        ;;
        o)
            MCD14DL_VECT=$OPTARG
        ;;
        h)
            usage
        ;;
    esac
done

n_date=$( expr $( $DENV_TOOL/util/calc_datesubstr.sh $END_DATE $START_DATE ) + 1 )
obs_dates+=( $( jot $n_date 0 | xargs -I n date '+%Y%m%d' --date "n days $START_DATE") )

g.region -d
v.in.ogr -r inp=$MCD14DL_FILE out=$MCD14DL_VECT --o

for obs_date in ${obs_dates[*]}
do
    mcd14dl=MCD14DL_${obs_date}
    obs_date_altform=$( date '+%Y-%m-%d' --date "$obs_date" )
    v.extract inp=$MCD14DL_VECT out=$mcd14dl where="ACQ_DATE == '${obs_date_altform}'" --o
done