#!/bin/bash

ldmd2 -O -release -run src/a.d "--DRT-gcopt=disable:1" < src/input/a | tee output/out
