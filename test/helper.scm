;;  Filename : helper.scm
;;  About    : helper for tests that use SRFI-64
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
;;  PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT HOLDERS OR
;;  CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
;;  EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
;;  PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
;;  PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
;;  LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
;;  NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
;;  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

;; This is loaded by "sscm --load" before a test that uses SRFI-64.

(require-extension (srfi 6 64))


;;
;; Test runner
;;

;; The simple test runner only reports results. This makes the sscm
;; command exit with a non-zero status on failure too.
(test-runner-factory
 (lambda ()
   (let* ((runner (test-runner-simple))
          (on-final (test-runner-on-final runner)))
     (test-runner-on-final! runner
                            (lambda (runner)
                              (on-final runner)
                              (if (> (+ (test-runner-fail-count runner)
                                        (test-runner-xpass-count runner))
                                     0)
                                  (exit 70))))  ;; EX_SOFTWARE
     runner)))

;; Skips all tests in the test file. test-skip of SRFI-64 can't be used for
;; it because forms that aren't tests such as definitions are still
;; evaluated. They may need a disabled feature.
(define (test-skip-file reason)
  (display "SKIP: ")
  (display reason)
  (newline)
  (exit 77))  ;; Meson and Automake report it as a skipped test.

;; Skips the rest of tests in the current test group. Forms that aren't
;; tests are still evaluated.
(define (test-skip-rest)
  (test-skip (lambda (runner) #t)))

;; test-error for an error that is detected only with strict-argcheck.
;; Its expression isn't evaluated without strict-argcheck because an
;; invalid form may not return.
(define-syntax test-argcheck-error
  (syntax-rules ()
    ((_ arg ...)
     (if (provided? "strict-argcheck")
         (test-error arg ...)))))


;;
;; Utilities
;;

;; Returns #<undef>.
(define (undef)
  (for-each values '()))

(define (string-read str)
  (read (open-input-string str)))

;; Returns #<eof>.
(define (eof)
  (string-read ""))

(define (string-eval str)
  (eval (string-read str) (interaction-environment)))

(define (obj->literal obj)
  (let ((port (open-output-string)))
    (write obj port)
    (get-output-string port)))

(define (print-expected expected)
  (display " expected print: ")
  (display expected)
  (newline)
  (display "   actual print: "))


;;
;; Implementation information
;;

(define sigscheme? (provided? "sigscheme"))

(define fixnum-bits (and (symbol-bound? 'fixnum-width)
                         (fixnum-width)))
