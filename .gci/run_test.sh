#!/bin/bash

set -e
make -C  $1
file=$(find $1 -name results.xml)
if [ -e "$file" ]; then
	if grep -q failure $file ; then
		printf "FAILED\n" $1
        false
	else
		printf "SUCCESS\n" $1
	fi
else 
	printf "FAILED\n" $1
    false
fi 
