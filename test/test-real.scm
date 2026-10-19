;;  Filename : test-real.scm
;;  About    : unit test for inexact real numbers
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


(require-extension (unittest) (srfi 6))

(if (not (string->number "0.5"))
    (test-skip "inexact real numbers are not enabled"))

(define tn test-name)

(define (write-to-string obj)
  (let ((port (open-output-string)))
    (write obj port)
    (get-output-string port)))

(tn "read decimal")
(assert-equal? (tn) "1.0" (write-to-string 1.0))
(assert-equal? (tn) "1.0" (write-to-string 1.))
(assert-equal? (tn) "0.5" (write-to-string .5))
(assert-equal? (tn) "-0.5" (write-to-string -.5))
(assert-equal? (tn) "0.5" (write-to-string '.5))
(assert-equal? (tn) '(1 0.5) '(1 .5))
(assert-equal? (tn) "-0.0" (write-to-string -0.0))
(assert-equal? (tn) "123.456" (write-to-string 123.456))

(tn "read exponent")
(assert-equal? (tn) "100.0" (write-to-string 1e2))
(assert-equal? (tn) "100.0" (write-to-string 1E2))
(assert-equal? (tn) "0.01" (write-to-string 1e-2))
(assert-equal? (tn) "100.0" (write-to-string 1s2))
(assert-equal? (tn) "100.0" (write-to-string 1d2))
(assert-equal? (tn) "1.5e-07" (write-to-string 1.5e-7))
(assert-equal? (tn) "1.0e+21" (write-to-string 1e21))

(tn "read special values")
(assert-equal? (tn) "+inf.0" (write-to-string +inf.0))
(assert-equal? (tn) "-inf.0" (write-to-string -inf.0))
(assert-equal? (tn) "+nan.0" (write-to-string +nan.0))
(assert-equal? (tn) "+nan.0" (write-to-string +NAN.0))

(tn "read prefixes")
(assert-equal? (tn) "1.0" (write-to-string #i1))
(assert-equal? (tn) "16.0" (write-to-string #i#x10))
(assert-equal? (tn) "16.0" (write-to-string #x#i10))
(assert-equal? (tn) 1 #e1.0)
(assert-equal? (tn) 1000 #e1e3)
(assert-equal? (tn) 16 #e#x10)
(assert-equal? (tn) 482 #x1e2)
(assert-error (tn) (lambda () (read (open-input-string "#e1.5"))))
(assert-error (tn) (lambda () (read (open-input-string "#x1.5"))))
(assert-error (tn) (lambda () (read (open-input-string "#i#i1"))))
(assert-error (tn) (lambda () (read (open-input-string "1.5.5"))))

(tn "write shortest")
(assert-equal? (tn) "0.1" (write-to-string 0.1))
(assert-equal? (tn) "0.14285714285714282"
               (write-to-string 0.14285714285714282))
(assert-equal? (tn) "5.0e-324" (write-to-string 4.940656458412465e-324))
(assert-equal? (tn) "1.7976931348623157e+308"
               (write-to-string 1.7976931348623157e308))
(assert-equal? (tn) "100000000000000000000.0" (write-to-string 1e20))
(assert-equal? (tn) "0.0001" (write-to-string 1e-4))
(assert-equal? (tn) "1.0e-05" (write-to-string 1e-5))

(tn "string->number")
(assert-equal? (tn) "1.5" (write-to-string (string->number "1.5")))
(assert-equal? (tn) "1.5" (write-to-string (string->number "#d1.5")))
(assert-equal? (tn) 15 (string->number "#e1.5e1"))
(assert-false (tn) (string->number "#e1.5"))
(assert-false (tn) (string->number "1.5" 16))
(assert-false (tn) (string->number "."))
(assert-false (tn) (string->number "1e"))
(assert-false (tn) (string->number "e1"))
(assert-false (tn) (string->number "+inf"))

(tn "number->string")
(assert-equal? (tn) "1.0" (number->string 1.0))
(assert-equal? (tn) "-2.5" (number->string -2.5))
(assert-equal? (tn) "1.0e+100" (number->string 1e100))
(assert-equal? (tn) "1.5" (number->string 1.5 10))
(assert-error (tn) (lambda () (number->string 1.5 16)))

(tn "number predicates")
(assert-true (tn) (number? 1.5))
(assert-true (tn) (complex? 1.5))
(assert-true (tn) (real? 1.5))
(assert-true (tn) (rational? 1.5))
(assert-false (tn) (rational? +inf.0))
(assert-false (tn) (rational? +nan.0))
(assert-true (tn) (integer? 2.0))
(assert-false (tn) (integer? 2.5))
(assert-false (tn) (integer? +inf.0))
(assert-true (tn) (integer? 1e300))
(assert-false (tn) (exact? 1.0))
(assert-true (tn) (inexact? 1.0))
(assert-false (tn) (inexact? 1))
(assert-error (tn) (lambda () (exact? 'a)))

(tn "eqv?")
(assert-true (tn) (eqv? 1.5 1.5))
(assert-false (tn) (eqv? 1.0 1))
(assert-false (tn) (eqv? 0.0 -0.0))
(assert-true (tn) (eqv? +nan.0 +nan.0))
(assert-true (tn) (equal? '(1.5 #(2.5)) (list 1.5 (vector 2.5))))
(assert-equal? (tn) '(2.0) (memv 2.0 '(1.0 2.0)))
(assert-equal? (tn) '(2.0 . x) (assv 2.0 '((1.0 . y) (2.0 . x))))

(total-report)
