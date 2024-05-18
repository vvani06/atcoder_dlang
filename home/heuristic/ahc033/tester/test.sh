#!/bin/bash

cd `dirname $0`

ldmd2 -O -release ../src/a.d -of ./a "--DRT-gcopt=disable:1" 
touch score
mkdir -p out
mkdir -p logs
rm score
rm out/*

for i in {0000..0099}; do
  ./a "--DRT-gcopt=disable:1" < in/${i}.txt > out/${i}.txt
done

wait

for i in {0000..0099}; do
  ./vis in/${i}.txt out/${i}.txt >> score
done

SCORE=`cat score | awk '{sum+=$3} END {printf "%.2f\n", sum}'`
echo $SCORE

DATE=`date "+%Y%m%d_%H%M%S"`
echo -e "${DATE}\t${SCORE}" >> score_history

cp score "logs/test_${DATE}"
