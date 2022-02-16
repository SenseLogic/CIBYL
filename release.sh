#!/bin/sh
set -x
dmd -O -inline -m64 cibyl.d
rm *.o
