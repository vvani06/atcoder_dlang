#!/bin/bash

ldmd2 -O -release -run src/a.d "--DRT-gcopt=profile:0" < src/input/a | tee output/out
