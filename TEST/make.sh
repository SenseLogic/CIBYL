#!/bin/sh
set -x
../cibyl --ruby --replace ../dictionary.txt --convert --join --compact CB/ RB/
../cibyl --crystal --replace ../dictionary.txt --convert --join --create --watch CB/ CR/
