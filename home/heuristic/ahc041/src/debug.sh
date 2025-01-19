#!/bin/bash

base=`pwd`
cd /tmp

cp ${base}/a.d ./ -f

ldmd2 -debug -O ./a.d -of ./built
{ time -p ./built; } < ${base}/input/a > ${base}/../tester/debug_out

cat ${base}/../tester/debug_out | grep -v "#" > ${base}/../tester/debug_out_filtered

# cat ${base}/../tester/devug_out
vis ${base}/input/a ${base}/../tester/debug_out_filtered
