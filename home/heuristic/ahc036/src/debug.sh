#!/bin/bash

ldmd2 -debug -run a.d < input/a > output/out

cat output/out
vis input/a output/out
