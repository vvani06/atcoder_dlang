#!/bin/bash

# ldmd2 -debug -run a.d < input/a
tester ldmd2 -debug -O -run a.d < input/a > output/out 2> output/err
tail -n 1 output/err

# cat output/out
# vis input/a output/out

