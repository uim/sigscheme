;;  Filename : test-eval.scm
;;  About    : unit test for evaluation
;;
;;  Copyright (C) 2005-2006 Kazuki Ohta <mover AT hct.zaq.ne.jp>
;;  Copyright (c) 2007-2026 SigScheme Project https://github.com/uim/sigscheme
;;
;;  All rights reserved.
;;
;;  Redistribution and use in source and binary forms, with or without
;;  modification, are permitted provided that the following conditions
;;  are met:
;;
;;  1. Redistributions of source code must retain the above copyright
;;     notice, this list of conditions and the following disclaimer.
;;  2. Redistributions in binary form must reproduce the above copyright
;;     notice, this list of conditions and the following disclaimer in the
;;     documentation and/or other materials provided with the distribution.
;;  3. Neither the name of authors nor the names of its contributors
;;     may be used to endorse or promote products derived from this software
;;     without specific prior written permission.
;;
;;  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS ``AS
;;  IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
;;  THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
;;  PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT HOLDERS OR
;;  CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
;;  EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
;;  PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
;;  PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
;;  LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
;;  NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
;;  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

(require-extension (srfi 64))

(test-begin "test-eval")

(test-begin "eval")
(test-equal 3 (eval '(+ 1 2)
                    (interaction-environment)))

(test-equal 3 (eval '((lambda (x y) (+ x y)) 1 2)
                    (interaction-environment)))
(test-end "eval")

(test-begin "eval with invalid environment specifiers")
(test-error (eval '(+ 1 2) 3))
(test-error (eval '(+ 1 2) 'symbol))
(test-error (eval '(+ 1 2) "string"))
(test-error (eval '(+ 1 2) #\a))
(test-end "eval with invalid environment specifiers")

;; R5RS: 4.1.3 Procedure calls
;; > Procedure calls may return any number of values (see values in section see
;; > section 6.4 Control features). With the exception of `values' the
;; > procedures available in the initial environment return one value or, for
;; > procedures such as `apply', pass on the values returned by a call to one
;; > of their arguments.
;; SigScheme apply this specification for 'eval' also.  -- YamaKen 2006-09-02
(test-begin "eval that returns multiple values")
(call-with-values
    (lambda ()
      (eval '(values 1 2 3)
            (interaction-environment)))
  (lambda vals
    (test-equal '(1 2 3) vals)))
(call-with-values
    (lambda ()
      (eval '(apply values '(1 2 3))
            (interaction-environment)))
  (lambda vals
    (test-equal '(1 2 3) vals)))
(test-end "eval that returns multiple values")

(test-begin "scheme-report-environment")
(if (provided? "sigscheme")
    (begin
      (test-error (eval '(+ 1 2)
                        (scheme-report-environment 4)))
      (test-error (eval '(+ 1 2)
                        (scheme-report-environment 6)))))
(test-error (eval '(+ 1 2)
                  (scheme-report-environment 'symbol)))
(test-error (eval '(+ 1 2)
                  (scheme-report-environment "string")))
(test-error (eval '(+ 1 2)
                  (scheme-report-environment #\a)))
(if (provided? "strict-r5rs")
    ;; SigScheme doesn't provide an environment that conforms to R5RS.
    (test-error (eval '(+ 1 2)
                      (scheme-report-environment 5)))
    (test-equal 3 (eval '(+ 1 2)
                        (scheme-report-environment 5))))
;; R5RS: 6.5 Eval
;; `eval' is not allowed to create new bindings in the environments associated
;; with `null-environment' or `scheme-report-environment'.
;; FIXME: SigScheme does not support this yet.
(if (and #f (provided? "sigscheme"))
    (begin
      (test-error (eval '(define foo 1)
                        (scheme-report-environment 5)))
      (test-error (eval 'use
                        (scheme-report-environment 5)))))
(test-end "scheme-report-environment")

(test-begin "null-environment")
(if (and #f (provided? "sigscheme"))
    (begin
      (test-error (eval '(+ 1 2)
                        (null-environment 4)))
      (test-error (eval '(+ 1 2)
                        (null-environment 6)))))
(test-error (eval '(+ 1 2)
                  (null-environment 'symbol)))
(test-error (eval '(+ 1 2)
                  (null-environment "string")))
(test-error (eval '(+ 1 2)
                  (null-environment #\a)))
(if (provided? "strict-r5rs")
    ;; SigScheme doesn't provide an environment that conforms to R5RS.
    (test-error (eval '(+ 1 2)
                      (null-environment 5)))
    (test-equal 3 (eval '(+ 1 2)
                        (null-environment 5))))
;; R5RS: 6.5 Eval
;; `eval' is not allowed to create new bindings in the environments associated
;; with `null-environment' or `scheme-report-environment'.
;; FIXME: SigScheme does not support this yet.
(if (and #f (provided? "sigscheme"))
    (begin
      (test-error (eval '(define foo 1)
                        (null-environment 5)))
      (test-error (eval 'use
                        (null-environment 5)))
      (test-error (eval 'procedure?
                        (null-environment 5)))))
(test-end "null-environment")

(if (provided? "sigscheme")
    (begin
      (test-begin "eval with handmade env")
      ;; single frame
      (test-equal 10 (eval '(+ x y)
                           '(((x y) . (4 6)))))
      ;; 2 frames
      (test-equal 15 (eval '(+ x y z)
                           '(((x y) . (4 6))
                             ((z)   . (5)))))
      ;; 3 frames
      (test-equal 14 (eval '(+ x y z v w)
                           '(((x y) . (4 6))
                             ((v w) . (0 -1))
                             ((z)   . (5)))))
      ;; dotted arg as formals
      (test-equal 44 (eval '(apply + lst)
                           '(((x y . lst) . (4 6 8 10 12 14))
                             ((z)  . (5)))))
      ;; symbol as formals
      (test-equal 54 (eval '(apply + lst)
                           '((lst . (4 6 8 10 12 14))
                             ((z) . (5)))))
      (test-end "eval with handmade env")

      (test-begin "eval with invalid handmade env")
      ;; improper frame list
      (test-error (eval '(+ 1 2)
                        '(((x y) . (4 6))
                          . #t)))
      ;; actuals shortage
      (test-error (eval '(+ 1 2)
                        '(((x y z) . (4 6)))))
      ;; actuals shortage #2
      (test-error (eval '(+ 1 2)
                        '(((x y . z) . (4)))))
      ;; superfluous actuals
      (test-error (eval '(+ 1 2)
                        '(((x y) . (4 6 8)))))
      ;; dotted actuals
      (test-error (eval '(+ 1 2)
                        '(((x y) . (4 . 6)))))
      ;; dotted actuals #2
      (test-error (eval '(+ 1 2)
                        '(((x y) . (4 6 . 8)))))
      ;; dotted actuals #3
      ;; This pattern has been allowd when let-optionals* is introduced.
      (test-equal '(4 (6 . 8))
                  (eval '(list x y)
                        '(((x . y) . (4 6 . 8)))))
      ;; not a symbol in formals
      (test-argcheck-error (eval '(+ 1 2)
                                 '(((x 3) . (4 6)))))
      ;; not a list as actuals
      (test-error (eval '(+ 1 2)
                        '(((x) . 4)
                          ((y) . 6))))
      ;; not a list as both formals and actuals
      ;; This pattern has been allowd when let-optionals* is introduced.
      (test-equal '(4 6)
                  (eval '(list x y)
                        '((x . 4)
                          (y . 6))))
      (test-end "eval with invalid handmade env")))

(test-end "test-eval")
