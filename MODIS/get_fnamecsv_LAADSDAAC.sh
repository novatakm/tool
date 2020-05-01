#!/usr/bin/env bash

usage(){
    echo $( basename $0 )
    echo "-s <start_date (in yyyymmdd format)>"
    echo "-e <end_date (in yyyymmdd format)>"
    echo "-o <out_dir>"
    echo "-p <product_id (default: MOD03)>"
    echo "-a <app-key>"
    echo "-h help"
    exit
}

PROD_ID='MOD03'
MY_APP_KEY=$DENV_LAADSDAAC_APPKEY

while getopts s:e:p:o:a:h  OPT
do
    case $OPT in
        s)
            START_DATE=$OPTARG
        ;;
        e)
            END_DATE=$OPTARG
        ;;
        o)
            OUT_DIR=$OPTARG
            mkdir -p $OUT_DIR
        ;;
        p)
            PROD_ID=$OPTARG
        ;;
        a)
            MY_APP_KEY=$OPTARG
        ;;
        h)
            usage
        ;;
    esac
done


n_date=$( expr $( $DENV_TOOL/util/calc_datesubstr.sh $END_DATE $START_DATE ) + 1 )
obs_dates+=( $( jot $n_date 0 | xargs -I n date '+%Y%m%d' --date "n days $START_DATE") )
for obs_date in ${obs_dates[*]}
do
    doy=$( $DENV_TOOL/util/DOY_converter.sh -d $obs_date )
    yyyy=$( echo $obs_date | cut -c 1-4 )
    fname_csv=$OUT_DIR/${obs_date}_${doy}.csv
    curl -v -H 'Authorization: Bearer $MY_APP_KEY' "https://ladsweb.modaps.eosdis.nasa.gov/archive/allData/6/${PROD_ID}/${yyyy}/${doy}.csv" > $fname_csv
done
