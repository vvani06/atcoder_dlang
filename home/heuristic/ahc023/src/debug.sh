#!/bin/bash

time ldmd2 -debug -run a.d < input/a > /tmp/a_out
cat /tmp/a_out | grep -v "#" > /tmp/a_out_filtered
../tester/vis input/a /tmp/a_out_filtered
