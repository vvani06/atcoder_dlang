#!/bin/bash

cd `dirname $0`

ldmd2 -O -release ../src/a.d -of ./a
touch score
mkdir -p out
mkdir -p logs
rm score
rm out/*

TOTAL_CASES=300
PARALLEL_SIZE=10
CYCLE=$((TOTAL_CASES/PARALLEL_SIZE - 1))

for cycle in `eval echo {0..$CYCLE}`; do
  min=$(($cycle * $PARALLEL_SIZE))
  max=$(($cycle * $PARALLEL_SIZE + $PARALLEL_SIZE - 1))
  for i in {0000..0999}; do
    if [ $min -le $i ] && [ $max -ge $i ]; then
      tester ./a < /ahc_in/${i}.txt > out/${i}.txt &
      # ./a < /ahc_in/${i}.txt > out/${i}.txt &
    fi
  done
  wait
done

for i in {0000..0999}; do
  if [ -f out/${i}.txt ]; then
    vis /ahc_in/${i}.txt out/${i}.txt >> score
  fi
done

grep -q turn score
if [ $? -eq 0 ]; then
  echo "Test results contain errors!"
  exit
fi

SCORE=`cat score | awk '{sum+=$3} END {printf "%.2f\n", sum}'`
echo $SCORE

DATE=`date "+%Y%m%d_%H%M%S"`
echo -e "${DATE}\t${SCORE}" >> score_history

cp score "logs/test_${DATE}"
