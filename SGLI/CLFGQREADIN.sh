#!/bin/sh
if [ "$1" = "-h" ]; then
    echo "`basename $0` H5_FILE GISDB"
    exit
fi
#
# LTOAREADIN H5FILE
#
FN=$$
#
PFSN=`basename $1 | awk '{print substr($1,1,6)}'`
YMD=`basename $1 | awk '{print substr($1,8,9)}'`
V=`basename $1 | awk '{print substr($1,22,2)}'`
H=`basename $1 | awk '{print substr($1,24,2)}'`
#
gdalinfo $1 > /tmp/$FN
#
LLAT=`grep Geometry_data_Lower_left_latitude /tmp/$FN | tr '=' ' ' | awk '{print $2}'`
ULAT=`grep Geometry_data_Upper_left_latitude /tmp/$FN | tr '=' ' ' | awk '{print $2}'`
LLNG1=`grep Geometry_data_Lower_left_longitude /tmp/$FN | tr '=' ' ' | awk '{print $2}'`
LLNG2=`grep Geometry_data_Upper_left_longitude /tmp/$FN | tr '=' ' ' | awk '{print $2}'`
LLNG=`echo $LLNG1 $LLNG2 | awk '($1<$2){print $1} ($1>=$2){print $2}'`
RLNG1=`grep Geometry_data_Lower_right_longitude /tmp/$FN | tr '=' ' ' | awk '{print $2}'`
RLNG2=`grep Geometry_data_Upper_right_longitude /tmp/$FN | tr '=' ' ' | awk '{print $2}'`
RLNG=`echo $RLNG1 $RLNG2 | awk '($1<$2){print $2} ($1>=$2){print $1}'`

GISDB=$2
g.mapset map=PERMANENT loc=LL dbase=${GISDB}

#
#CFLG
#
DD=`grep Image_data_Grid_interval= /tmp/$FN | head -1 | tr '=' ' ' | awk '{print $2}'`
LLRECL=`echo $LLNG $RLNG $DD | awk '{print int(0.5+($2-$1)/$3)}'`
echo 4800 4800 > /tmp/P$FN
echo $LLRECL 4800 >> /tmp/P$FN
echo $H $V >> /tmp/P$FN
echo $ULAT $LLAT $RLNG $LLNG $DD 65535 >> /tmp/P$FN
h5dump -d //Image_data/Cloud_flag -b LE -o /tmp/D$FN $1
echo /tmp/D$FN >> /tmp/P$FN
$HOME/TOOLS/GCSGLI/SIN2LL_US /tmp/P$FN > /tmp/S$FN
r.in.bin  bytes=2 input=/tmp/S$FN output=${PFSN}_${YMD}_V${V}H${H}_CLFG_Q n=$ULAT s=$LLAT w=$LLNG e=$RLNG rows=4800 cols=$LLRECL anull=65535 --o
r.colors map=${PFSN}_${YMD}_V${V}H${H}_CLFG_Q color=grey
rm /tmp/P$FN /tmp/D$FN /tmp/S$FN
rm /tmp/$FN

#
# Cut out Algorithm Execution Bits
#
CEX=${PFSN}_${YMD}_V${V}H${H}_CEX_Q
MSK=1
RSH=0
g.region rast=${PFSN}_${YMD}_V${V}H${H}_CLFG_Q
r.mapcalc "$CEX = if(${PFSN}_${YMD}_V${V}H${H}_CLFG_Q!=65535, ${PFSN}_${YMD}_V${V}H${H}_CLFG_Q & $MSK)"
#r.mapcalc "$CEX = $CEX >> $RSH"
r.colors map=$CEX color=grey --o

#
# Cut out Clear Confidence Level Bits
#
CCL=${PFSN}_${YMD}_V${V}H${H}_CCL_Q
MSK=14
RSH=1
g.region rast=${PFSN}_${YMD}_V${V}H${H}_CLFG_Q
r.mapcalc "$CCL = if(${PFSN}_${YMD}_V${V}H${H}_CLFG_Q!=65535, ${PFSN}_${YMD}_V${V}H${H}_CLFG_Q & $MSK)"
r.mapcalc "$CCL = $CCL >> $RSH"
r.colors map=$CCL color=grey --o
# CCL="V"$V"H"$H"."$YMD".CCL"
# UPB=3
# LWB=1
# LSH="31-$UPB"
# RSH="31-($UPB-$LWB)"
# g.region rast=$CLF
# r.mapcalc "$CCL = if($CLF!=65535, $CLF << $LSH)"
# r.mapcalc "$CCL = $CCL >>> $RSH"

#
# Cut out Heavy Aerosol Bits
#
HVA=${PFSN}_${YMD}_V${V}H${H}_HVA_Q
MSK=512
RSH=9
g.region rast=${PFSN}_${YMD}_V${V}H${H}_CLFG_Q
r.mapcalc "$HVA = if(${PFSN}_${YMD}_V${V}H${H}_CLFG_Q!=65535, ${PFSN}_${YMD}_V${V}H${H}_CLFG_Q & $MSK)"
r.mapcalc "$HVA = $HVA >> $RSH"
r.colors map=$HVA color=grey --o
# HVA="V"$V"H"$H"."$YMD".HVA"
# UPB=9
# LWB=9
# LSH="31-$UPB"
# RSH="31-($UPB-$LWB)"
# g.region rast=$CLF
# r.mapcalc "$HVA = if($CLF!=65535, $CLF << $LSH)"
# r.mapcalc "$HVA = $HVA >>> $RSH"

#
# Cut out Snow/Ice Bits
#
SNW=${PFSN}_${YMD}_V${V}H${H}_SNW_Q
MSK=64
RSH=6
g.region rast=${PFSN}_${YMD}_V${V}H${H}_CLFG_Q
r.mapcalc "$SNW = if(${PFSN}_${YMD}_V${V}H${H}_CLFG_Q!=65535, ${PFSN}_${YMD}_V${V}H${H}_CLFG_Q & $MSK)"
r.mapcalc "$SNW = $SNW >> $RSH"
r.colors map=$SNW color=grey --o
# HVA="V"$V"H"$H"."$YMD".HVA"
# UPB=9
# LWB=9
# LSH="31-$UPB"
# RSH="31-($UPB-$LWB)"
# g.region rast=$CLF
# r.mapcalc "$HVA = if($CLF!=65535, $CLF << $LSH)"
# r.mapcalc "$HVA = $HVA >>> $RSH"

#
# Cut out Cirrus Probabilty Bits
#
CIR=${PFSN}_${YMD}_V${V}H${H}_CIR_Q
MSK=1024
RSH=10
g.region rast=${PFSN}_${YMD}_V${V}H${H}_CLFG_Q
r.mapcalc "$CIR = if(${PFSN}_${YMD}_V${V}H${H}_CLFG_Q!=65535, ${PFSN}_${YMD}_V${V}H${H}_CLFG_Q & $MSK)"
r.mapcalc "$CIR = $CIR >> $RSH"
r.colors map=$CIR color=grey --o
