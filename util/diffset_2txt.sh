#!/usr/bin/env bash

usage(){
    echo "$( basename $0 ) textfile_A textfile_B > textfile_A - textfile_B"
    echo "-h help"
    exit
}

while getopts h  OPT
do
    case $OPT in
        h)
            usage
        ;;
    esac
done

file_a=$1
file_b=$2

( cat $file_a $file_b | sort -u ; cat $file_b ) | sort | uniq -u
#( cat $file_a $file_b | sort -u ; cat $file_b ) | sort | uniq -d