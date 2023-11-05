#!/bin/bash -e

cd `dirname $0`

ldmd2 -O -release ../src/a.d -of ./a
touch score
rm score
rm out/*

for i in {0000..0149}; do
  ./a < in/${i}.txt > out/${i}.txt 2>> out/${i}_score &
done

wait

for i in {0000..0149}; do
  cat out/${i}_score >> score
done

SCORE=`cat score | awk '{sum+=$3} END {printf "%.2f\n", sum}'`
echo $SCORE

DATE=`date "+%Y%m%d_%H%M%S"`
echo -e "${DATE}\t${SCORE}" >> score_history

cp score "logs/test_${DATE}"
