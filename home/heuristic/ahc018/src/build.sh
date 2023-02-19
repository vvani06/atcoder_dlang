#!/bin/bash

ldmd2 -O a.d -of /tmp/a && time ../tester/tester /tmp/a < ../tester/in/0000.txt > /dev/null
