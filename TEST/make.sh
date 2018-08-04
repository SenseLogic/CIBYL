#!/bin/sh
set -x
../cibyl --ruby --compact CB/ RB/
../cibyl --crystal --create --watch CB/ CR/
