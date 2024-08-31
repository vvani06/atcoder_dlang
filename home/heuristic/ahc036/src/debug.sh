#!/bin/bash

base=`pwd`
cd /tmp

cp ${base}/a.d ./ -f

ldmd2 -debug -O ./a.d -of ./built
time ./built < ${base}/input/a > ${base}/../tester/devug_out

# cat ${base}/../tester/devug_out
vis ${base}/input/a ${base}/../tester/devug_out
