#!/bin/sh
set -x
../cibyl --ruby --case --parse CB/ --compact CB/ RB/
../cibyl --crystal --case --parse CB/ --create --watch CB/ CR/
