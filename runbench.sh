#!/bin/sh

SSCM="src/sscm --system-load-path $PWD/lib"

for bench in bench/bench-*.scm
do
  echo "Running benchmark $bench..."
  time $SSCM $bench
done
