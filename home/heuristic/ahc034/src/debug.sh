#!/bin/bash

time ldmd2 -debug -run a.d < input/a > ../tester/a_out
cat ../tester/a_out | grep -v "#" > ../tester/a_out_filtered
