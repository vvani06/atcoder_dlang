#!/bin/bash

ldmd2 -O -debug ../src/a.d -of /tmp/a && time ../tester/tester /tmp/a < input/a
