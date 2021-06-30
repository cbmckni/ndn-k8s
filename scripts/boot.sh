#!/bin/bash

usage(){
	echo "Usage:"
        echo "  ./boot.sh -h                           Display this help message."
        echo "  ./boot.sh -c CONFIG -l LOGFILE         NFD Launcher, -c and -l are optional args."
}

# A POSIX variable
OPTIND=1 # Reset in case getopts has been used previously in the shell.

# Initialize our own variables:
config=$CONFIG
logfile=$LOG_FILE

while getopts ":c:l:h" opt; do
  case ${opt} in
    c )
        name=$OPTARG
        ;;
    l ) 
	timef=$OPTARG
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

/usr/local/bin/nfd -c $config > $logfile 2>&1 &
/workspace/ndn/scripts/delay.sh 3
