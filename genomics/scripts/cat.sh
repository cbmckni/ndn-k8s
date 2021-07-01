#!/bin/bash

usage(){
	echo "Usage:"
        echo "  ./cat.sh -h                                 Display this help message."
        echo "  ./cat.sh -n NAME -o OUTPUT -t TIME_FILE     Catchunks, -o and -t are optional args."
}

# A POSIX variable
OPTIND=1 # Reset in case getopts has been used previously in the shell.

# Initialize our own variables:
outputf="/dev/null"
timef="/dev/null"
name=""

while getopts ":n:o:t:h" opt; do
  case ${opt} in
    n )
        name=$OPTARG
        ;;
    t ) 
	timef=$OPTARG
	;;
    o )
	outputf=$OPTARG
	;;
    h )
	usage
	exit 0
        ;;
    \? )
        echo "Invalid Option: -$OPTARG" 1>&2
        exit 1
        ;;
    : )
        echo "Invalid Option: -$OPTARG requires an argument" 1>&2
        exit 1
        ;;
  esac
done

shift $((OPTIND-1))

if [[ -z "$name" ]]; then
  usage
  exit 1
fi

TIME=$(time (ndncatchunks -q --fast-conv --disable-cwa --ignore-marks $name > $outputf) 2>&1)
echo "Time Test $TIME" >> $timef
