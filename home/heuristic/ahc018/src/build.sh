#!/bin/bash

ldmd2 -O a.d -of /tmp/a && time ../tester/tester /tmp/a < input/a > /dev/null
