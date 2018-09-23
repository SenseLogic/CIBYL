#!/bin/sh
set -x
../cibyl --ruby --case --compact CB/ RB/
../cibyl --crystal --case --create --watch CB/ CR/
