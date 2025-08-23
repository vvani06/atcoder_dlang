#!/bin/bash

cd `dirname $0`

ldmd2 -O -release ../src/a.d -of ./a
touch score run_times
mkdir -p out logs time
rm score run_times
rm out/*
rm time/*

TOTAL_CASES=50
PARALLEL_SIZE=5
CYCLE=$((TOTAL_CASES/PARALLEL_SIZE - 1))

for cycle in `eval echo {0..$CYCLE}`; do
  min=$(($cycle * $PARALLEL_SIZE))
  max=$(($cycle * $PARALLEL_SIZE + $PARALLEL_SIZE - 1))
  for i in {0000..0999}; do
    if [ $min -le $i ] && [ $max -ge $i ]; then
      { time -p ./a; } < /ahc_in/${i}.txt > out/${i}.txt 2>time/${i}.txt &
    fi
  done
  wait
done

for i in {0000..0999}; do
  if [ -f out/${i}.txt ]; then
    vis /ahc_in/${i}.txt out/${i}.txt >> score
    cat time/${i}.txt | head -n 1 >> run_times
  fi
done

grep -q turn score
if [ $? -eq 0 ]; then
  echo "Test results contain errors!"
  exit
fi

SCORE=`cat score | awk '{sum+=$3*3} END {printf "%.2f\n", sum}'`
echo $SCORE

DATE=`date "+%Y%m%d_%H%M%S"`
echo -e "${DATE}\t${SCORE}" >> score_history

cp score "logs/test_${DATE}"
