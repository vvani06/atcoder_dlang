#!/bin/bash -e

base=`pwd`
cd /tmp

cp ${base}/a.d ./ -f
if [ -z "${1}" ]; then
    cp ${base}/input/a ./a -f
else
    testcase=`printf "%04d" "${1}"`
    cp "/ahc_in/${testcase}.txt" ./a -f
fi

ldmd2 -debug -O ./a.d -of=./built
{ time -p ./built; } < ./a > ${base}/../tester/debug_out

cat ${base}/../tester/debug_out | grep -v "#" > ${base}/../tester/debug_out_filtered

# cat ${base}/../tester/devug_out
vis ./a ${base}/../tester/debug_out_filtered
