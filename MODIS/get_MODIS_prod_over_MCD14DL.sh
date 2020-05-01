#!/usr/bin/env bash

usage(){
    echo $( basename $0 )
    echo "-i <MCD14DL of the specific date>"
    echo "-f <MODIS prod filename listed csv file>"
    echo "-d <DAYNIGHT (in Day=D, Night=A format)>"
    echo "-o <out_dir>"
    echo "-p <product_id (default: MOD03)>"
    echo "-a <app-key>"
    echo "-h help"
    exit
}

PROD_ID='MOD03'
APP_KEY=$DENV_LAADSDAAC_APPKEY

while getopts i:f:d:o:p:a:h  OPT
do
    case $OPT in
        i)
            MCD14DL_1DAY=$OPTARG
        ;;
        f)
            FNAME_CSV=$OPTARG
        ;;
        d)
            DAYNIGHT=$OPTARG
        ;;
        o)
            OUT_DIR=$OPTARG
            mkdir -p $OUT_DIR
        ;;
        p)
            PROD_ID=$OPTARG
        ;;
        a)
            APP_KEY=$OPTARG
        ;;
        h)
            usage
        ;;
    esac
done

# n_date=$( expr $( $DENV_TOOL/util/calc_datesubstr.sh $END_DATE $START_DATE ) + 1 )
# obs_dates+=( $( jot $n_date 0 | xargs -I n date '+%Y%m%d' --date "n days $START_DATE") )
# for obs_date in ${obs_dates[*]}
# do
#     doy=$( $DENV_TOOL/util/DOY_converter.sh -d $obs_date )
#     yyyy=$( echo $obs_date | cut -c 1-4 )

# done

function main(){
    g.region -d
    yyyy=$( echo $MCD14DL_1DAY | cut -c 9-12 )
    mmdd=$( echo $MCD14DL_1DAY | cut -c 13-16 )
    doy=$( $DENV_TOOL/util/DOY_converter.sh -d $yyyy$mmdd )
    acq_times=( $( v.db.select -c map=$MCD14DL_1DAY where="SATELLITE == 'Terra' AND DAYNIGHT == '${DAYNIGHT}'" | awk 'BEGIN{FS="|"}{print $8}' ) )
    declare -a MODIS_prods=()
    for acq_time in ${acq_times[*]}
    do
        hhm=$( echo $acq_time | cut -c 1-3 )
        lowest_m=$( echo $acq_time | cut -c 4 )
        
        if [ $lowest_m -ge 1 -a $lowest_m -le 4 ]; then
            acq_time_floor="${hhm}0"
            acq_time_ceil="${hhm}5"
            MODIS_prods+=( $( get_modis_prod_name $acq_time_floor ) )
            MODIS_prods+=( $( get_modis_prod_name $acq_time_ceil ) )
            elif [ $lowest_m -ge 6 -a $lowest_m -le 9 ]; then
            acq_time_floor="${hhm}5"
            acq_time_ceil=$( date '+%H%M' --date "5 minutes $acq_time_floor" )
            MODIS_prods+=( $( get_modis_prod_name $acq_time_floor ) )
            MODIS_prods+=( $( get_modis_prod_name $acq_time_ceil ) )
        else
            MODIS_prods+=( $( get_modis_prod_name $acq_time ) )
        fi
        
    done
    
    MODIS_prods_uniq=( $( echo ${MODIS_prods[*]} | awk '{for(n=1; n<=NF; n++){print $n}}' | sort -u ) )
    for MODIS_prod in ${MODIS_prods_uniq[*]}
    do
        wget -e robots=off -m -np -R .html,.tmp -nH --cut-dirs=6 "https://ladsweb.modaps.eosdis.nasa.gov/archive/allData/6/${PROD_ID}/${yyyy}/${doy}/${MODIS_prod}" --header "Authorization: Bearer $APP_KEY" -P $OUT_DIR
        # curl -v -H "Authorization: Bearer $APP_KEY" "https://ladsweb.modaps.eosdis.nasa.gov/rchive/allData/6/${PROD_ID}/${yyyy}/${doy}/${mod03}" > ${OUT_DIR}/${mod03}
    done
}

function get_modis_prod_name(){
    local acq_time=$1
    cat $FNAME_CSV | grep "A$yyyy$doy\.$acq_time" | awk 'BEGIN{FS=","}{print $1}'
}

main