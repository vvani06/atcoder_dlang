#!/bin/bash

cd `dirname $0`

# D_OPT="--DRT-gcopt=disable:1"
D_OPT=""

ldmd2 -O -release ../src/a.d -of ./a ${D_OPT} 
touch score
mkdir -p out
mkdir -p logs
rm score
rm out/*

for i in {0000..0149}; do
  ./a ${D_OPT} < in/${i}.txt > out/${i}.txt 2>> score
done

wait

SCORE=`cat score | awk '{sum+=$3} END {printf "%.2f\n", sum}'`
echo $SCORE

DATE=`date "+%Y%m%d_%H%M%S"`
echo -e "${DATE}\t${SCORE}" >> score_history

cp score "logs/test_${DATE}"
