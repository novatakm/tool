#!/usr/bin/env bash

# function calc_date() {
#   expr \( `date -d"$1" +%s` - `date -d"$2" +%s` \) / 86400
# }

function calc_date() {
    expr \( $( date +%s --date "$1" ) - $( date +%s --date "$2" ) \) / 86400
}

function usage() {
    echo "Usage: $(basename $0) datestr datestr"
    exit 1
}

if [ $# -ne 2 ]; then
    usage
fi

calc_date $1 $2