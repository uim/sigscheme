(define-library (test library greeting)
  (export greet)
  (import (test builtin))
  (include-library-declarations "greeting-declarations.scm")
  (include "greeting.scm")
  (include-ci "greeting-ci.scm")
  (cond-expand
   ((and r7rs (library (test builtin)))
    (begin (define greeting-feature 'r7rs)))
   (else
    (begin (define greeting-feature 'else)))))
