#!/bin/bash

time ldmd2 -run a.d < input/a > /tmp/a_out
../tester/vis input/a /tmp/a_out
