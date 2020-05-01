#!/usr/bin/env bash

usage(){
    echo $( basename $0 )
    echo "  -i <dir. that contains the L8 geotif file>"
    echo "  -o <data id of the imported L8 raster>"
    echo "  -b <band numbers to be imported>"
    echo "  -h help"
    exit
}

while getopts i:o:b:h  OPT
do
    case $OPT in
        i)
            L8_TIF_DIR=$OPTARG
        ;;
        o)
            L8_DATA_ID=$OPTARG
        ;;
        b)
            BNS=$OPTARG
        ;;
        h)
            usage
        ;;
    esac
done

tmp_fn=$$

GDAL_CACHEMAX="4096"

function get_obstime(){
    local mtl=$1
    
    iso8061=`cat ${mtl} | grep SCENE_CENTER_TIME | awk '{print $3}' | sed 's/["|Z]//g'`
    time=`echo ${iso8061} | awk 'BEGIN{FS=":"}{printf("%f", $1+$2/60+$3/3600)}'`
    echo ${time}
}

function genr_g.region.cmd(){
    local ll_tif=$1
    
    gdalinfo $ll_tif > /tmp/gdinfo$tmp_fn
    
    n=$( cat /tmp/gdinfo$tmp_fn | awk '/Upper/{print $0}' | sed 's/[(|)|,]//g' | awk '{print $4}' | xargs | awk '{if($1>$2){print $1}else{print $2}}' )
    s=$( cat /tmp/gdinfo$tmp_fn | awk '/Lower/{print $0}' | sed 's/[(|)|,]//g' | awk '{print $4}' | xargs | awk '{if($1<$2){print $1}else{print $2}}' )
    e=$( cat /tmp/gdinfo$tmp_fn | awk '/Right/{print $0}' | sed 's/[(|)|,]//g' | awk '{print $3}' | xargs | awk '{if($1>$2){print $1}else{print $2}}' )
    w=$( cat /tmp/gdinfo$tmp_fn | awk '/Left/{print $0}' | sed 's/[(|)|,]//g' | awk '{print $3}' | xargs | awk '{if($1<$2){print $1}else{print $2}}' )
    nsres=$( cat /tmp/gdinfo$tmp_fn | awk '/Pixel Size/{print $0}' | sed 's/[=|(|)|-]//g' | sed 's/,/ /g' | awk '{print $3}' )
    ewres=$( cat /tmp/gdinfo$tmp_fn | awk '/Pixel Size/{print $0}' | sed 's/[=|(|)|-]//g' | sed 's/,/ /g' | awk '{print $4}' )
    echo "g.region n=$n s=$s w=$w e=$e nsres=$nsres ewres=$ewres"
    rm /tmp/gdinfo$tmp_fn
}

function warp_ll_TIF2DN(){
    
    ##############
    # temp files #
    ##############
    #input tif
    local tif=$( ls ${L8_TIF_DIR}/*.TIF | grep B${bn}.TIF )
    #reprojected tif
    local ll_tif=${L8_TIF_DIR}/LL$tmp_fn
    #DN raster
    local dn=${L8_DATA_ID}_B${bn}
    
    #gdalwarp
    gdalwarp -overwrite \
    -t_srs "+datum=wgs84 +ellips=wgs84 +proj=longlat" \
    $tif $ll_tif
    #set GRASS region
    genr_g.region.cmd $ll_tif | sh
    
    #import tif into GRASS as DN
    r.in.gdal in=${ll_tif} out=${dn} --o
    case ${bn} in
        "QA")
            r.mapcalc "${dn} = if(${dn}==0||${dn}==1, null(), ${dn})"
        ;;
        *)
            r.mapcalc "${dn} = if(${dn}==0, null(), ${dn})"
        ;;
    esac
}

function DN2RAD(){
    
    #DN raster
    local dn=${L8_DATA_ID}_B${bn}
    #metadata
    local mtl=`ls ${L8_TIF_DIR}/*_MTL.txt`
    
    # radiance raster
    local rad=${L8_DATA_ID}_L${bn}
    
    #convert DN to L
    local gain=`cat ${mtl} | grep "RADIANCE_MULT_BAND_${bn} " | awk '{print $3}'`
    local offset=`cat ${mtl} | grep "RADIANCE_ADD_BAND_${bn} " | awk '{print $3}'`
    g.region rast=${dn}
    r.mapcalc "${rad} = ${gain}*${dn} + ${offset}"
    
    #set colortable
    r.colors map=${rad} color='grey' --o
    
}

function DN2REF(){
    
    #DN raster
    local dn=${L8_DATA_ID}_B${bn}
    #metadata
    local mtl=`ls ${L8_TIF_DIR}/*_MTL.txt`
    
    # reflactance raster
    local pref=${L8_DATA_ID}_PR${bn}
    local ref=${L8_DATA_ID}_R${bn}
    
    #convert DN to R
    local gain=`cat ${mtl} | grep REFLECTANCE_MULT_BAND_${bn} | awk '{print $3}'`
    local offset=`cat ${mtl} | grep REFLECTANCE_ADD_BAND_${bn} | awk '{print $3}'`
    local sun_elv=`cat ${mtl} | grep SUN_ELEVATION | awk '{print $3}'`
    g.region rast=${dn}
    r.mapcalc "${pref} = ${gain}*${dn} + ${offset}"
    r.mapcalc "${ref} = ${pref}/sin(${sun_elv})"
    
    #set colortable
    r.colors map=${pref} color='grey' --o
    r.colors map=${ref} color='grey' --o
}

function main(){
    
    for bn in ${BNS}
    do
        case $bn in
            [1-9])
                warp_ll_TIF2DN
                DN2RAD
                DN2REF
            ;;
            "QA")
                warp_ll_TIF2DN
            ;;
            *)
                continue
            ;;
        esac
        
    done
    
}

main
