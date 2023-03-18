#!/bin/bash

ldmd2 -O -debug a.d -of /tmp/a && time ../tester/tester /tmp/a < ../tester/in/0000.txt > ../tester/out/0.txt
