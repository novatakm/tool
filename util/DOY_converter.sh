usage(){
    echo $( basename $0 )
    echo "-d <date (in yyyymmdd format)>"
    echo "-h help"
    exit
}

while getopts d:h  OPT
do
    case $OPT in
        d)
            DATE=$OPTARG
        ;;
        h)
            usage
        ;;
    esac
done

yyyy=$( echo $DATE | cut -c 1-4 )
prev_year=$( echo $yyyy - 1 | bc)

expr \( $(date -d"$DATE" +%s) - $(date -d"${prev_year}1231" +%s) \) / 86400 | awk '{printf("%03d", $1)}'