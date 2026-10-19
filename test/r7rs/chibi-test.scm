;;  Filename : chibi-test.scm
;;  About    : (chibi test) compatible procedures to run r7rs-tests.scm
;;
;;  Copyright (c) 2026 SigScheme Project https://github.com/uim/sigscheme
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
;;  PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT OWNER OR
;;  CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
;;  EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
;;  PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
;;  PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
;;  LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
;;  NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
;;  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

;; run.py evaluates each top-level form of r7rs-tests.scm by
;; %r7rs-run-form and reads results from lines that start with
;; "@@r7rs ".

(%%require-module "srfi-6")
(%%require-module "srfi-34")

(define (%r7rs-report . items)
  (display "@@r7rs")
  (for-each (lambda (item)
              (display " ")
              (display item))
            items)
  (newline))

(define (%r7rs-object->string obj)
  (let ((port (open-output-string)))
    (write obj port)
    (get-output-string port)))

;; An error object is (tag reason irritants trace).
(define (%r7rs-error->string err)
  (%r7rs-object->string
   (if (%%error-object? err)
       (cons (cadr err) (caddr err))
       err)))

(define (%r7rs-run-form index form-string)
  (%r7rs-report "form" index)
  (guard (err
          (#t
           (%r7rs-report "form-error" (%r7rs-error->string err))))
    (eval (read (open-input-string form-string))
          (interaction-environment))))

(define (test-begin . name)
  (%r7rs-report "begin" (if (pair? name) (car name) "")))

(define (test-end . name)
  (%r7rs-report "end"))

(define (%r7rs-pass)
  (%r7rs-report "pass"))

(define (%r7rs-fail description detail)
  (%r7rs-report "fail" (%r7rs-object->string description) detail))

;; Returns (#t . value) or (#f . error).
(define (%r7rs-call thunk)
  (guard (err
          (#t (cons #f err)))
    (cons #t (thunk))))

;; Inexact numbers are compared approximately like (chibi test). 1e-5 is
;; read only with inexact numbers.
(define (%r7rs-equal? expected result)
  (or (equal? expected result)
      (and (real? expected)
           (inexact? expected)
           (real? result)
           (<= (abs (- expected result))
               (* (string->number "1e-5") (max 1 (abs expected)))))))

(define (%r7rs-test description expected-thunk thunk)
  (let ((expected (expected-thunk))
        (result (%r7rs-call thunk)))
    (cond
     ((not (car result))
      (%r7rs-fail description
                  (string-append "error: "
                                 (%r7rs-error->string (cdr result)))))
     ((%r7rs-equal? expected (cdr result))
      (%r7rs-pass))
     (else
      (%r7rs-fail description
                  (string-append "expected "
                                 (%r7rs-object->string expected)
                                 " but got "
                                 (%r7rs-object->string (cdr result))))))))

(define (%r7rs-test-error description thunk)
  (if (car (%r7rs-call thunk))
      (%r7rs-fail description "no error")
      (%r7rs-pass)))

;; (test expected expr) or (test name expected expr)
;;
;; The tested expression is the description if no name is given.
(define-syntax test
  (syntax-rules ()
    ((_ expected expr)
     (test 'expr expected expr))
    ((_ name expected expr)
     (%r7rs-test name (lambda () expected) (lambda () expr)))))

;; (test-assert expr) or (test-assert name expr)
(define-syntax test-assert
  (syntax-rules ()
    ((_ expr)
     (test-assert 'expr expr))
    ((_ name expr)
     (%r7rs-test name (lambda () #t) (lambda () (if expr #t #f))))))

;; (test-error expr) or (test-error name expr)
(define-syntax test-error
  (syntax-rules ()
    ((_ expr)
     (test-error 'expr expr))
    ((_ name expr)
     (%r7rs-test-error name (lambda () expr)))))

;; (test-values expected expr) or (test-values name expected expr)
(define-syntax test-values
  (syntax-rules ()
    ((_ expected expr)
     (test-values 'expr expected expr))
    ((_ name expected expr)
     (%r7rs-test name
                 (lambda () (call-with-values (lambda () expected) list))
                 (lambda () (call-with-values (lambda () expr) list))))))
