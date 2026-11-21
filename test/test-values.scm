;;  Filename : test-values.scm
;;  About    : unit tests for multiple values
;;
;;  Copyright (C) 2006 YAMAMOTO Kengo <yamaken AT bp.iij4u.or.jp>
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

(test-begin "test-values")


;;
;; values
;;

;; These tests use explicit equivalence predicates instead of test-equal, to
;; avoid being affected by multiple-values -specific behavior.

(test-begin "values invalid forms")
;; Normal continuations accept exactly one value only.
(test-error (eq? '() (values)))
(test-error (eq? '() (apply values '())))
(test-error (eq? '() (values . 1)))
(test-error (eq? '() (values 1 2)))
(test-error (eq? '() (apply values '(1 2))))
(test-error (eq? '() (values 1 . 2)))
(test-end "values invalid forms")

(test-begin "values disallowed places")
;; top-level variable
(test-error (eval '(define foo (values 1 2 3))
                  (interaction-environment)))
(define foo 1)
(test-error (eval '(set! foo (values 1 2 3))
                  (interaction-environment)))
;; internal variable
(test-error (let () (define bar (values 1 2 3)) #t))
;; others
(test-error (let ((bar (values 1 2 3))) #t))
(test-error (let* ((bar (values 1 2 3))) #t))
(test-error (letrec ((bar (values 1 2 3))) #t))
(test-error (if (values 1 2 3) #t))
(test-error (and (values 1 2 3) #t))
(test-error (or (values 1 2 3) #t))
(test-error (cond ((values 1 2 3) #t) (else #t)))
(test-error (case (values 1 2 3) (else #t)))
(test-error (begin (values 1 2 3) #t))
(test-error ((lambda () (values 1 2 3) #t)))
(test-end "values disallowed places")

(test-begin "values")
;; Exactly one value.
(test-assert (eqv? 1 (values 1)))
(test-assert (eqv? 1 (apply values '(1))))
(test-assert (eq? '() (values '())))
(test-assert (eq? '() (apply values '(()))))
(test-assert (eq? #f (values #f)))
(test-assert (eq? #f (apply values '(#f))))
(test-end "values")

;; Returning multiple values in top-level is allowed (SigScheme-specific).
;; These forms test whether evaluations are passed without blowing up.
(values)
(values 1 2 3)
(apply values '())
(apply values '(1 2 3))
(begin
  (values))
(begin
  (values 1 2 3))
(begin
  (apply values '()))
(begin
  (apply values '(1 2 3)))

;;
;; call-with-values
;;

(test-begin "call-with-values invalid forms")
(test-error (call-with-values))
(test-error (call-with-values even?))
(test-error (call-with-values even? #t))
(test-error (call-with-values #t even?))
(test-end "call-with-values invalid forms")

(test-begin "call-with-values")
(test-equal -1
            (call-with-values * -))

(test-equal 'ok
            (call-with-values
                (lambda () (values))
              (lambda () 'ok)))
(test-equal '()
            (call-with-values
                (lambda () (values))
              (lambda args args)))
(test-equal 'ok
            (call-with-values
                (lambda () (apply values '()))
              (lambda () 'ok)))
(test-equal '()
            (call-with-values
                (lambda () (apply values '()))
              (lambda args args)))

(test-equal 1
            (call-with-values
                (lambda () (values 1))
              (lambda (x) x)))
(test-equal '(1)
            (call-with-values
                (lambda () (values 1))
              (lambda args args)))
(test-equal 1
            (call-with-values
                (lambda () (apply values '(1)))
              (lambda (x) x)))
(test-equal '(1)
            (call-with-values
                (lambda () (apply values '(1)))
              (lambda args args)))

(test-equal '(1 2)
            (call-with-values
                (lambda () (values 1 2))
              (lambda (x y) (list x y))))
(test-equal '(1 2)
            (call-with-values
                (lambda () (values 1 2))
              (lambda args args)))
(test-equal '(1 2)
            (call-with-values
                (lambda () (apply values '(1 2)))
              (lambda (x y) (list x y))))
(test-equal '(1 2)
            (call-with-values
                (lambda () (apply values '(1 2)))
              (lambda args args)))
(test-end "call-with-values")

(test-begin "call-with-values by apply")
(test-equal -1
            (apply call-with-values (list * -)))

(test-equal 'ok
            (apply call-with-values
                   (list (lambda () (values))
                         (lambda () 'ok))))
(test-equal '()
            (apply call-with-values
                   (list (lambda () (values))
                         (lambda args args))))
(test-equal 'ok
            (apply call-with-values
                   (list (lambda () (apply values '()))
                         (lambda () 'ok))))
(test-equal '()
            (apply call-with-values
                   (list (lambda () (apply values '()))
                         (lambda args args))))

(test-equal 1
            (apply call-with-values
                   (list (lambda () (values 1))
                         (lambda (x) x))))
(test-equal '(1)
            (apply call-with-values
                   (list (lambda () (values 1))
                         (lambda args args))))
(test-equal 1
            (apply call-with-values
                   (list (lambda () (apply values '(1)))
                         (lambda (x) x))))
(test-equal '(1)
            (apply call-with-values
                   (list (lambda () (apply values '(1)))
                         (lambda args args))))

(test-equal '(1 2)
            (apply call-with-values
                   (list (lambda () (values 1 2))
                         (lambda (x y) (list x y)))))
(test-equal '(1 2)
            (apply call-with-values
                   (list (lambda () (values 1 2))
                         (lambda args args))))
(test-equal '(1 2)
            (apply call-with-values
                   (list (lambda () (apply values '(1 2)))
                         (lambda (x y) (list x y)))))
(test-equal '(1 2)
            (apply call-with-values
                   (list (lambda () (apply values '(1 2)))
                         (lambda args args))))
(test-end "call-with-values by apply")

(test-begin "call-with-values misc")
;; test whether the variable is properly bound
(test-equal 1
            ((lambda (n)
               (call-with-values
                   (lambda () (values 2 3 n))
                 (lambda (dummy1 dummy2 n2)
                   n2)))
             1))
(test-end "call-with-values misc")


(test-end "test-values")
