#!/bin/sh
set -x
dmd -debug -g -gf -gs -m64 cibyl.d
rm *.o
