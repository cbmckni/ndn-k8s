#!/bin/bash

if [ "$#" -eq 0 ]; then
	tail -f /dev/null 	
else
	sleep $1
fi
