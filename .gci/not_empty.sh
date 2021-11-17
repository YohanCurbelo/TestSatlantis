#!/bin/bash

set -e
if [ $(ls $1 2>/dev/null | wc -w) -gt 1 ]
then
    echo "Directory is not empty: SUCCESS"
else
    echo "Directory is empty: FAILED"
    false
fi
