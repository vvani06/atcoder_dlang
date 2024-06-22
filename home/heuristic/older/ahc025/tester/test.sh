#!/bin/bash -e

cd `dirname $0`

ldmd2 -O -release ../src/a.d -of ./a
touch score
rm score
rm out/*

for i in {0000..0099}; do
  echo ${i} > out/${i}_score; cat in/${i}.txt >> out/${i}_score; 
done

for i in {0000..0099}; do
  ./tester ./a < in/${i}.txt > out/${i}.txt 2>> out/${i}_score &
done

wait

ldmd2 -run conv.d
