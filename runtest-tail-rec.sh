#!/bin/sh

SSCM="src/sscm --system-load-path $PWD/lib"
TEST=test/test-tail-rec.scm

ulimit -s 128 && ulimit -d 2048 && $SSCM $TEST \
    || echo 'All tests finished successfully only if the message "All normal tests have been passed" and subsequent intended segmentation fault message are printed above.'
