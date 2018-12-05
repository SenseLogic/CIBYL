#!/bin/sh
set -x
../../cibyl --crystal --replace ../../dictionary.txt --convert --join --create --watch CB/ CR/
