#!/bin/sh
set -x
../cibyl --ruby --replace ../dictionary.txt --convert --compact CB/ RB/
../cibyl --crystal --replace ../dictionary.txt --convert --create --watch CB/ CR/
