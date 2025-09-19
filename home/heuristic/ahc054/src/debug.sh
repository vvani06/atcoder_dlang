#!/bin/bash

export RUST_BACKTRACE=full

base=`pwd`

if [ ! -z "${1}" ]; then
    testcase=`printf "%04d" "${1}"`
    cp "/ahc_in/${testcase}.txt" ./input/a -f
    cp "/ahc_in/${testcase}.txt" ${base}/input/lastcase -f
fi

ldmd2 -debug -O ./a.d -of=/tmp/built && \
tester /tmp/built < input/a > output/out 2> output/err && \
tail -n 1 output/err

# cat output/out
# vis input/a output/out

