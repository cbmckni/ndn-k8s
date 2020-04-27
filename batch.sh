#!/bin/bash

while read line; do
  echo $line
  ndncatchunks $line > $(basename -- $line)
done < $1
