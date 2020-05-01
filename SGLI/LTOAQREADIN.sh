#!/bin/sh
if [ "$1" = "-h" ]; then
    # LTOAREADIN H5FILE "[bandname,...]"
    echo "`basename $0` H5_FILE GISDB \"bname bnanme ...\""
    exit
fi
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
BNS=$3

g.mapset map=PERMANENT loc=LL dbase=${GISDB}

if [ -z "${BNS}" ]; then
    BNS="VN08 VN11 SW01 SW03 SW04 TI01"
fi

for BN in ${BNS}
do
    case $BN in
	VN*)
	    # Reflectance convertion
	    DD=`grep Image_data_Lt_${BN}_Spatial_resolution= /tmp/$FN | head -1 | tr '=' ' ' | awk '{print $2}'`
	    LLRECL=`echo $LLNG $RLNG $DD | awk '{print int(0.5+($2-$1)/$3)}'`
	    G=`grep Image_data_Lt_${BN}_Slope_reflectance= /tmp/$FN  | tr '=' ' '| awk '{print $2}'`
	    O=`grep Image_data_Lt_${BN}_Offset_reflectance= /tmp/$FN  | tr '=' ' '| awk '{print $2}'`
	    echo 4800 4800 > /tmp/P$FN
	    echo $LLRECL 4800 >> /tmp/P$FN
	    echo $H $V >> /tmp/P$FN
	    echo $ULAT $LLAT $RLNG $LLNG $DD 65535 >> /tmp/P$FN
	    h5dump -d //Image_data/Lt_${BN} -b LE -o /tmp/D$FN $1
	    echo /tmp/D$FN >> /tmp/P$FN
	    echo $G $O >> /tmp/P$FN
	    $HOME/TOOLS/GCSGLI/SIN2LL_MUSGO /tmp/P$FN > /tmp/S$FN
	    r.in.bin -d input=/tmp/S$FN output=${PFSN}_${YMD}_V${V}H${H}_R${BN}_Q n=$ULAT s=$LLAT w=$LLNG e=$RLNG rows=4800 cols=$LLRECL anull=-500 --o
	    #g.region rast=${PFSN}_${YMD}_V${V}H${H}_R${BN}_Q
	    #r.mapcalc "${PFSN}_${YMD}_V${V}H${H}_R${BN}_Q = if(${PFSN}_${YMD}_V${V}H${H}_R${BN}_Q<=0, null(), ${PFSN}_${YMD}_V${V}H${H}_R${BN}_Q)"
	    r.colors map=${PFSN}_${YMD}_V${V}H${H}_R${BN}_Q color=grey
	    rm /tmp/P$FN /tmp/D$FN /tmp/S$FN
	    ;;
	
	SW03)
	    # Reflectance convertion
	    DD=`grep Image_data_Lt_${BN}_Spatial_resolution= /tmp/$FN | head -1 | tr '=' ' ' | awk '{print $2}'`
	    LLRECL=`echo $LLNG $RLNG $DD | awk '{print int(0.5+($2-$1)/$3)}'`
	    G=`grep Image_data_Lt_${BN}_Slope_reflectance= /tmp/$FN  | tr '=' ' '| awk '{print $2}'`
	    O=`grep Image_data_Lt_${BN}_Offset_reflectance= /tmp/$FN  | tr '=' ' '| awk '{print $2}'`
	    echo 4800 4800 > /tmp/P$FN
	    echo $LLRECL 4800 >> /tmp/P$FN
	    echo $H $V >> /tmp/P$FN
	    echo $ULAT $LLAT $RLNG $LLNG $DD 65535 >> /tmp/P$FN
	    h5dump -d //Image_data/Lt_${BN} -b LE -o /tmp/D$FN $1
	    echo /tmp/D$FN >> /tmp/P$FN
	    echo $G $O >> /tmp/P$FN
	    $HOME/TOOLS/GCSGLI/SIN2LL_MUSGO /tmp/P$FN > /tmp/S$FN
	    r.in.bin -d input=/tmp/S$FN output=${PFSN}_${YMD}_V${V}H${H}_R${BN}_Q n=$ULAT s=$LLAT w=$LLNG e=$RLNG rows=4800 cols=$LLRECL anull=-500 --o
	    #g.region rast=${PFSN}_${YMD}_V${V}H${H}_R${BN}_Q
	    #r.mapcalc "${PFSN}_${YMD}_V${V}H${H}_R${BN}_Q = if(${PFSN}_${YMD}_V${V}H${H}_R${BN}_Q<=0, null(), ${PFSN}_${YMD}_V${V}H${H}_R${BN}_Q)"
	    r.colors map=${PFSN}_${YMD}_V${V}H${H}_R${BN}_Q color=grey
	    rm /tmp/P$FN /tmp/D$FN /tmp/S$FN

	    # Radiacne convertion
	    DD=`grep Image_data_Lt_${BN}_Spatial_resolution= /tmp/$FN | head -1 | tr '=' ' ' | awk '{print $2}'`
	    LLRECL=`echo $LLNG $RLNG $DD | awk '{print int(0.5+($2-$1)/$3)}'`
	    G=`grep Image_data_Lt_${BN}_Slope= /tmp/$FN  | tr '=' ' '| awk '{print $2}'`
	    O=`grep Image_data_Lt_${BN}_Offset= /tmp/$FN  | tr '=' ' '| awk '{print $2}'`
	    echo 4800 4800 > /tmp/P$FN
	    echo $LLRECL 4800 >> /tmp/P$FN
	    echo $H $V >> /tmp/P$FN
	    echo $ULAT $LLAT $RLNG $LLNG $DD 65535 >> /tmp/P$FN
	    h5dump -d //Image_data/Lt_${BN} -b LE -o /tmp/D$FN $1
	    echo /tmp/D$FN >> /tmp/P$FN
	    echo $G $O >> /tmp/P$FN
	    $HOME/TOOLS/GCSGLI/SIN2LL_MUSGO /tmp/P$FN > /tmp/S$FN
	    r.in.bin -d input=/tmp/S$FN output=${PFSN}_${YMD}_V${V}H${H}_L${BN}_Q n=$ULAT s=$LLAT w=$LLNG e=$RLNG rows=4800 cols=$LLRECL anull=-500 --o
	    #g.region rast=${PFSN}_${YMD}_V${V}H${H}_L${BN}_Q
	    #r.mapcalc "${PFSN}_${YMD}_V${V}H${H}_L${BN}_Q = if(${PFSN}_${YMD}_V${V}H${H}_L${BN}_Q<=0, null(), ${PFSN}_${YMD}_V${V}H${H}_L${BN}_Q)"
	    r.colors map=${PFSN}_${YMD}_V${V}H${H}_L${BN}_Q color=grey
	    rm /tmp/P$FN /tmp/D$FN /tmp/S$FN
	    ;;


	SW01 | SW02 | SW04)
	    # Refrectance conversion
	    DD=`grep Image_data_Lt_SW03_Spatial_resolution= /tmp/$FN | head -1 | tr '=' ' ' | awk '{print $2}'`
	    LLRECL=`echo $LLNG $RLNG $DD | awk '{print int(0.5+($2-$1)/$3)}'`
	    h5dump -d //Image_data/Lt_${BN} -b LE -o /tmp/D$FN $1
	    $HOME/TOOLS/GCSGLI/12to48  /tmp/D$FN >  /tmp/DD$FN
	    G=`grep Image_data_Lt_${BN}_Slope_reflectance= /tmp/$FN  | tr '=' ' '| awk '{print $2}'`
	    O=`grep Image_data_Lt_${BN}_Offset_reflectance= /tmp/$FN  | tr '=' ' '| awk '{print $2}'`
	    echo 4800 4800 > /tmp/P$FN
	    echo $LLRECL 4800 >> /tmp/P$FN
	    echo $H $V >> /tmp/P$FN
	    echo $ULAT $LLAT $RLNG $LLNG $DD 65535 >> /tmp/P$FN
	    echo /tmp/DD$FN >> /tmp/P$FN
	    echo $G $O >> /tmp/P$FN
	    $HOME/TOOLS/GCSGLI/SIN2LL_MUSGO /tmp/P$FN > /tmp/S$FN
	    XLRECL=`$HOME/TOOLS/GCSGLI/48to12 /tmp/S$FN $LLRECL   /tmp/DDD$FN`
	    r.in.bin -d input=/tmp/DDD$FN output=${PFSN}_${YMD}_V${V}H${H}_R${BN}_K n=$ULAT s=$LLAT w=$LLNG e=$RLNG rows=1200 cols=$XLRECL anull=-500 --o
	    #g.region rast=${PFSN}_${YMD}_V${V}H${H}_R${BN}_K
	    #r.mapcalc "${PFSN}_${YMD}_V${V}H${H}_R${BN}_K = if(${PFSN}_${YMD}_V${V}H${H}_R${BN}_K<=0, null(), ${PFSN}_${YMD}_V${V}H${H}_R${BN}_K)"
	    r.colors map=${PFSN}_${YMD}_V${V}H${H}_R${BN}_K color=grey
	    rm /tmp/P$FN /tmp/D$FN /tmp/S$FN  /tmp/DD$FN /tmp/DDD$FN

	    # Radiance conversion
	    DD=`grep Image_data_Lt_SW03_Spatial_resolution= /tmp/$FN | head -1 | tr '=' ' ' | awk '{print $2}'`
	    LLRECL=`echo $LLNG $RLNG $DD | awk '{print int(0.5+($2-$1)/$3)}'`
	    h5dump -d //Image_data/Lt_${BN} -b LE -o /tmp/D$FN $1
	    $HOME/TOOLS/GCSGLI/12to48  /tmp/D$FN >  /tmp/DD$FN
	    G=`grep Image_data_Lt_${BN}_Slope= /tmp/$FN  | tr '=' ' '| awk '{print $2}'`
	    O=`grep Image_data_Lt_${BN}_Offset= /tmp/$FN  | tr '=' ' '| awk '{print $2}'`
	    echo 4800 4800 > /tmp/P$FN
	    echo $LLRECL 4800 >> /tmp/P$FN
	    echo $H $V >> /tmp/P$FN
	    echo $ULAT $LLAT $RLNG $LLNG $DD 65535 >> /tmp/P$FN
	    echo /tmp/DD$FN >> /tmp/P$FN
	    echo $G $O >> /tmp/P$FN
	    $HOME/TOOLS/GCSGLI/SIN2LL_MUSGO /tmp/P$FN > /tmp/S$FN
	    XLRECL=`$HOME/TOOLS/GCSGLI/48to12 /tmp/S$FN $LLRECL   /tmp/DDD$FN`
	    r.in.bin -d input=/tmp/DDD$FN output=${PFSN}_${YMD}_V${V}H${H}_L${BN}_K n=$ULAT s=$LLAT w=$LLNG e=$RLNG rows=1200 cols=$XLRECL anull=-500 --o
	    #g.region rast=${PFSN}_${YMD}_V${V}H${H}_L${BN}_K
	    #r.mapcalc "${PFSN}_${YMD}_V${V}H${H}_L${BN}_K = if(${PFSN}_${YMD}_V${V}H${H}_L${BN}_K<=0, null(), ${PFSN}_${YMD}_V${V}H${H}_L${BN}_K)"
	    r.colors map=${PFSN}_${YMD}_V${V}H${H}_L${BN}_K color=grey
	    rm /tmp/P$FN /tmp/D$FN /tmp/S$FN  /tmp/DD$FN /tmp/DDD$FN
	    ;;
	
	TI*)
	    # Radiance conversion
	    DD=`grep Image_data_Lt_${BN}_Spatial_resolution= /tmp/$FN | head -1 | tr '=' ' ' | awk '{print $2}'`
	    LLRECL=`echo $LLNG $RLNG $DD | awk '{print int(0.5+($2-$1)/$3)}'`
	    G=`grep Image_data_Lt_${BN}_Slope= /tmp/$FN  | tr '=' ' '| awk '{print $2}'`
	    O=`grep Image_data_Lt_${BN}_Offset= /tmp/$FN  | tr '=' ' '| awk '{print $2}'`
	    echo 4800 4800 > /tmp/P$FN
	    echo $LLRECL 4800 >> /tmp/P$FN
	    echo $H $V >> /tmp/P$FN
	    echo $ULAT $LLAT $RLNG $LLNG $DD 65535 >> /tmp/P$FN
	    h5dump -d //Image_data/Lt_${BN} -b LE -o /tmp/D$FN $1
	    echo /tmp/D$FN >> /tmp/P$FN
	    echo $G $O >> /tmp/P$FN
	    $HOME/TOOLS/GCSGLI/SIN2LL_MUSGO /tmp/P$FN > /tmp/S$FN
	    r.in.bin -d input=/tmp/S$FN output=${PFSN}_${YMD}_V${V}H${H}_L${BN}_Q n=$ULAT s=$LLAT w=$LLNG e=$RLNG rows=4800 cols=$LLRECL anull=-500 --o
	    #g.region rast=${PFSN}_${YMD}_V${V}H${H}_L${BN}_Q
	    #r.mapcalc "${PFSN}_${YMD}_V${V}H${H}_L${BN}_Q = if(${PFSN}_${YMD}_V${V}H${H}_L${BN}_Q<=0, null(), ${PFSN}_${YMD}_V${V}H${H}_L${BN}_Q)"
	    r.colors map=${PFSN}_${YMD}_V${V}H${H}_L${BN}_Q color=grey

	    # Btemp conversion
	    g.copy rast=${PFSN}_${YMD}_V${V}H${H}_L${BN}_Q,X$FN
	    g.region rast=${PFSN}_${YMD}_V${V}H${H}_L${BN}_Q
	    case $BN in
		TI01)
 		    r.mapcalc "T$FN = 1333.54/log(1.0 + 813.992/X$FN)"
		    ;;
		TI02)
		    r.mapcalc "T$FN = 1204.09/log(1.0 + 488.475/X$FN)"
		    ;;
	    esac
	    g.remove -f type=rast name=X$FN
	    g.rename rast=T$FN,${PFSN}_${YMD}_V${V}H${H}_T${BN}_Q --o
	    r.colors map=${PFSN}_${YMD}_V${V}H${H}_T${BN}_Q color=grey
	    rm /tmp/P$FN /tmp/D$FN /tmp/S$FN
	    ;;
    esac
done

#
#SeZ
#
#DD=`grep Geometry_data_Sensor_zenith_Spatial_resolution= /tmp/$FN | head -1 | tr '=' ' ' | awk '{print $2}'`
#LLRECL=`echo $LLNG $RLNG $DD | awk '{print int(0.5+($2-$1)/$3)}'`
DD=`grep Image_data_Lt_SW03_Spatial_resolution= /tmp/$FN | head -1 | tr '=' ' ' | awk '{print $2}'`
LLRECL=`echo $LLNG $RLNG $DD | awk '{print int(0.5+($2-$1)/$3)}'`
G=`grep Geometry_data_Sensor_zenith_Slope= /tmp/$FN  | tr '=' ' '| awk '{print $2}'`
O=`grep Geometry_data_Sensor_zenith_Offset= /tmp/$FN  | tr '=' ' '| awk '{print $2}'`
echo 4800 4800 > /tmp/P$FN
echo $LLRECL 4800 >> /tmp/P$FN
echo $H $V >> /tmp/P$FN
echo $ULAT $LLAT $RLNG $LLNG $DD -32768 >> /tmp/P$FN
h5dump -d //Geometry_data/Sensor_zenith -b LE -o /tmp/D$FN $1
echo /tmp/D$FN >> /tmp/P$FN
echo $G $O >> /tmp/P$FN
$HOME/TOOLS/GCSGLI/SIN2LL_SGO /tmp/P$FN > /tmp/S$FN
r.in.bin -d input=/tmp/S$FN output=${PFSN}_${YMD}_V${V}H${H}_SeZ_Q n=$ULAT s=$LLAT w=$LLNG e=$RLNG rows=4800 cols=$LLRECL anull=-500 --o
#g.region rast=${PFSN}_${YMD}_V${V}H${H}_SeZ_Q
r.colors map=${PFSN}_${YMD}_V${V}H${H}_SeZ_Q color=grey
rm /tmp/P$FN /tmp/D$FN /tmp/S$FN

#
#SeA
#
#DD=`grep Geometry_data_Sensor_zenith_Spatial_resolution= /tmp/$FN | head -1 | tr '=' ' ' | awk '{print $2}'`
#LLRECL=`echo $LLNG $RLNG $DD | awk '{print int(0.5+($2-$1)/$3)}'`
G=`grep Geometry_data_Sensor_azimuth_Slope= /tmp/$FN  | tr '=' ' '| awk '{print $2}'`
O=`grep Geometry_data_Sensor_azimuth_Offset= /tmp/$FN  | tr '=' ' '| awk '{print $2}'`
echo 4800 4800 > /tmp/P$FN
echo $LLRECL 4800 >> /tmp/P$FN
echo $H $V >> /tmp/P$FN
echo $ULAT $LLAT $RLNG $LLNG $DD -32768 >> /tmp/P$FN
h5dump -d //Geometry_data/Sensor_azimuth -b LE -o /tmp/D$FN $1
echo /tmp/D$FN >> /tmp/P$FN
echo $G $O >> /tmp/P$FN
$HOME/TOOLS/GCSGLI/SIN2LL_SGO /tmp/P$FN > /tmp/S$FN
r.in.bin -d input=/tmp/S$FN output=${PFSN}_${YMD}_V${V}H${H}_SeA_Q n=$ULAT s=$LLAT w=$LLNG e=$RLNG rows=4800 cols=$LLRECL anull=-500 --o
#g.region rast=${PFSN}_${YMD}_V${V}H${H}_SeA_Q
r.colors map=${PFSN}_${YMD}_V${V}H${H}_SeA_Q color=grey
rm /tmp/P$FN /tmp/D$FN /tmp/S$FN

#
#SoA
#
#DD=`grep Geometry_data_Solar_zenith_Spatial_resolution= /tmp/$FN | head -1 | tr '=' ' ' | awk '{print $2}'`
#LLRECL=`echo $LLNG $RLNG $DD | awk '{print int(0.5+($2-$1)/$3)}'`
G=`grep Geometry_data_Solar_azimuth_Slope= /tmp/$FN  | tr '=' ' '| awk '{print $2}'`
O=`grep Geometry_data_Solar_azimuth_Offset= /tmp/$FN  | tr '=' ' '| awk '{print $2}'`
echo 4800 4800 > /tmp/P$FN
echo $LLRECL 4800 >> /tmp/P$FN
echo $H $V >> /tmp/P$FN
echo $ULAT $LLAT $RLNG $LLNG $DD -32768 >> /tmp/P$FN
h5dump -d //Geometry_data/Solar_azimuth -b LE -o /tmp/D$FN $1
echo /tmp/D$FN >> /tmp/P$FN
echo $G $O >> /tmp/P$FN
$HOME/TOOLS/GCSGLI/SIN2LL_SGO /tmp/P$FN > /tmp/S$FN
r.in.bin -d input=/tmp/S$FN output=${PFSN}_${YMD}_V${V}H${H}_SAZ_Q n=$ULAT s=$LLAT w=$LLNG e=$RLNG rows=4800 cols=$LLRECL anull=-500 --o
#g.region rast=${PFSN}_${YMD}_V${V}H${H}_SAZ_Q
r.colors map=${PFSN}_${YMD}_V${V}H${H}_SAZ_Q color=grey
rm /tmp/P$FN /tmp/D$FN /tmp/S$FN

#
#SZA
#
#DD=`grep Geometry_data_Solar_zenith_Spatial_resolution= /tmp/$FN | head -1 | tr '=' ' ' | awk '{print $2}'`
#LLRECL=`echo $LLNG $RLNG $DD | awk '{print int(0.5+($2-$1)/$3)}'`
G=`grep Geometry_data_Solar_zenith_Slope= /tmp/$FN  | tr '=' ' '| awk '{print $2}'`
O=`grep Geometry_data_Solar_zenith_Offset= /tmp/$FN  | tr '=' ' '| awk '{print $2}'`
echo 4800 4800 > /tmp/P$FN
echo $LLRECL 4800 >> /tmp/P$FN
echo $H $V >> /tmp/P$FN
echo $ULAT $LLAT $RLNG $LLNG $DD -32768 >> /tmp/P$FN
h5dump -d //Geometry_data/Solar_zenith -b LE -o /tmp/D$FN $1
echo /tmp/D$FN >> /tmp/P$FN
echo $G $O >> /tmp/P$FN
$HOME/TOOLS/GCSGLI/SIN2LL_SGO /tmp/P$FN > /tmp/S$FN
r.in.bin -d input=/tmp/S$FN output=${PFSN}_${YMD}_V${V}H${H}_SZA_Q n=$ULAT s=$LLAT w=$LLNG e=$RLNG rows=4800 cols=$LLRECL anull=-500 --o
#g.region rast=${PFSN}_${YMD}_V${V}H${H}_SZA_Q
r.colors map=${PFSN}_${YMD}_V${V}H${H}_SZA_Q color=grey
rm /tmp/P$FN /tmp/D$FN /tmp/S$FN

#
#OBSTIME
#
#DD=`grep Geometry_data_Solar_zenith_Spatial_resolution= /tmp/$FN | head -1 | tr '=' ' ' | awk '{print $2}'`
#LLRECL=`echo $LLNG $RLNG $DD | awk '{print int(0.5+($2-$1)/$3)}'`
G=`grep Geometry_data_Obs_time_Slope= /tmp/$FN  | tr '=' ' '| awk '{print $2}'`
O=`grep Geometry_data_Obs_time_Offset= /tmp/$FN  | tr '=' ' '| awk '{print $2}'`
echo 4800 4800 > /tmp/P$FN
echo $LLRECL 4800 >> /tmp/P$FN
echo $H $V >> /tmp/P$FN
echo $ULAT $LLAT $RLNG $LLNG $DD -32768 >> /tmp/P$FN
h5dump -d //Geometry_data/Obs_time -b LE -o /tmp/D$FN $1
echo /tmp/D$FN >> /tmp/P$FN
echo $G $O >> /tmp/P$FN
$HOME/TOOLS/GCSGLI/SIN2LL_SGO /tmp/P$FN > /tmp/S$FN
r.in.bin -d input=/tmp/S$FN output=${PFSN}_${YMD}_V${V}H${H}_OBT_Q n=$ULAT s=$LLAT w=$LLNG e=$RLNG rows=4800 cols=$LLRECL anull=-500 --o
#g.region rast=${PFSN}_${YMD}_V${V}H${H}_OBT_Q
r.colors map=${PFSN}_${YMD}_V${V}H${H}_OBT_Q color=grey
rm /tmp/P$FN /tmp/D$FN /tmp/S$FN

#
#LAND/WATERFLAG
#
#DD=`grep Geometry_data_Solar_zenith_Spatial_resolution= /tmp/$FN | head -1 | tr '=' ' ' | awk '{print $2}'`
#LLRECL=`echo $LLNG $RLNG $DD | awk '{print int(0.5+($2-$1)/$3)}'`
echo 4800 4800 > /tmp/P$FN
echo $LLRECL 4800 >> /tmp/P$FN
echo $H $V >> /tmp/P$FN
echo $ULAT $LLAT $RLNG $LLNG $DD 255 >> /tmp/P$FN
h5dump -d //Image_data/Land_water_flag -b LE -o /tmp/D$FN $1
echo /tmp/D$FN >> /tmp/P$FN
echo $G $O >> /tmp/P$FN
$HOME/TOOLS/GCSGLI/SIN2LL_UC /tmp/P$FN > /tmp/S$FN
r.in.bin bytes=1 input=/tmp/S$FN output=${PFSN}_${YMD}_V${V}H${H}_LWF_Q n=$ULAT s=$LLAT w=$LLNG e=$RLNG rows=4800 cols=$LLRECL anull=255 --o
#g.region rast=${PFSN}_${YMD}_V${V}H${H}_LWF_Q
r.colors map=${PFSN}_${YMD}_V${V}H${H}_LWF_Q color=grey
rm /tmp/P$FN /tmp/D$FN /tmp/S$FN
rm /tmp/$FN

