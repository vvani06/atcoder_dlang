#!/bin/bash

ldmd2 -debug -O a.d -of /tmp/built
time /tmp/built < input/a > output/out

# cat output/out
vis input/a output/out
