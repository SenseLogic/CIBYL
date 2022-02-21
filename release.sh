#!/bin/sh
set -x
dmd -O -m64 cibyl.d
rm *.o
