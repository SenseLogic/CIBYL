#!/bin/sh
set -x
../cibyl --ruby --concise CB/ RB/
../cibyl --crystal --create --watch CB/ CR/
