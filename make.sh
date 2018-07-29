#!/bin/sh
set -x
dmd -m64 cibyl.d
rm *.o
