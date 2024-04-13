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

TEST_CASES=150
PARARELL_SIZE=5

for ((i=0; i<$(($TEST_CASES / $PARARELL_SIZE)); i++)); do
  for ((j=0; j<$PARARELL_SIZE; j++)); do
    case_no=$(printf "%04d" "$(($i * $PARARELL_SIZE + $j))")
    ./a ${D_OPT} < in/${case_no}.txt > out/${case_no}.txt 2>> out/${case_no}_score.txt &
  done
  wait
done

for i in {0000..0149}; do
  cat out/${i}_score.txt >> score
done

SCORE=`cat score | awk '{sum+=$3} END {printf "%.2f\n", sum}'`
echo $SCORE

DATE=`date "+%Y%m%d_%H%M%S"`
echo -e "${DATE}\t${SCORE}" >> score_history

cp score "logs/test_${DATE}"
