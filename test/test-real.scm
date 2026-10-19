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

;; Use eqv? to distinguish exactness.
(define-syntax assert-eqv-number?
  (syntax-rules ()
    ((_ name expected actual)
     (assert-true name (eqv? expected actual)))))

(tn "+")
(assert-eqv-number? (tn) 3.5 (+ 1 2.5))
(assert-eqv-number? (tn) 3.5 (+ 2.5 1))
(assert-eqv-number? (tn) 1.5 (+ 1.5))
(assert-eqv-number? (tn) 6.0 (+ 1 2 3.0))
(assert-eqv-number? (tn) 6 (+ 1 2 3))
(assert-error (tn) (lambda () (+ 1.5 'a)))

(tn "-")
(assert-eqv-number? (tn) -1.5 (- 1.5))
(assert-eqv-number? (tn) 2.5 (- 3 0.5))
(assert-eqv-number? (tn) 0.0 (- 1.5 1 0.5))

(tn "*")
(assert-eqv-number? (tn) 3.0 (* 2 1.5))
(assert-eqv-number? (tn) 1.5 (* 1.5))
(assert-eqv-number? (tn) 0.0 (* 0 1.5))

(tn "/")
(assert-eqv-number? (tn) 0.5 (/ 1 2))
(assert-eqv-number? (tn) 0.5 (/ 2))
(assert-eqv-number? (tn) 2 (/ 6 3))
(assert-eqv-number? (tn) 0.25 (/ 1.0 4))
(assert-eqv-number? (tn) 0.25 (/ 1 2 2))
(assert-eqv-number? (tn) +inf.0 (/ 1 0.0))
(assert-eqv-number? (tn) -inf.0 (/ -1 0.0))
(assert-error (tn) (lambda () (/ 1 0)))

(tn "comparison")
(assert-true (tn) (= 1 1.0))
(assert-true (tn) (< 1 1.5 2))
(assert-true (tn) (> 2.5 2 1))
(assert-true (tn) (<= 1 1.0 1))
(assert-true (tn) (>= 2.0 2 1.5))
(assert-false (tn) (= +nan.0 +nan.0))
(assert-false (tn) (< 1 +nan.0))
(assert-false (tn) (> +nan.0 1))
(assert-true (tn) (< -inf.0 0 +inf.0))
;; Large integers are compared exactly.
(assert-false (tn) (= 9007199254740993 9007199254740992.0))
(assert-true (tn) (< 9007199254740992.0 9007199254740993))
(assert-error (tn) (lambda () (< 1.5 'a)))

(tn "zero? positive? negative?")
(assert-true (tn) (zero? 0.0))
(assert-true (tn) (zero? -0.0))
(assert-true (tn) (positive? 1e-300))
(assert-false (tn) (positive? -0.0))
(assert-true (tn) (negative? -0.5))
(assert-false (tn) (negative? +nan.0))

(tn "odd? even?")
(assert-true (tn) (odd? 3.0))
(assert-true (tn) (odd? -3.0))
(assert-true (tn) (even? 4.0))
(assert-true (tn) (even? 0.0))
(assert-error (tn) (lambda () (odd? 1.5)))
(assert-error (tn) (lambda () (even? +inf.0)))

(tn "max min")
(assert-eqv-number? (tn) 2.0 (max 1 2.0))
(assert-eqv-number? (tn) 3.0 (max 3 2.0))
(assert-eqv-number? (tn) 1.0 (min 1 2.0))
(assert-eqv-number? (tn) 4.0 (max 2.0 3 4))
(assert-eqv-number? (tn) 1.5 (max 1.5))
(let ((nan (max 1 +nan.0)))
  (assert-false (tn) (= nan nan)))

(tn "abs")
(assert-eqv-number? (tn) 2.5 (abs -2.5))
(assert-eqv-number? (tn) 0.0 (abs -0.0))

(tn "integer division")
(assert-eqv-number? (tn) 3.0 (quotient 7.0 2))
(assert-eqv-number? (tn) -1.0 (remainder -7.0 2))
(assert-eqv-number? (tn) 1.0 (modulo -7.0 2))
(assert-eqv-number? (tn) -1.0 (modulo 7 -2.0))
(if (provided? "r7rs")
    (begin
      (assert-eqv-number? (tn) -4.0 (floor-quotient -7 2.0))
      (assert-eqv-number? (tn) 1.0 (floor-remainder -7 2.0))
      (assert-eqv-number? (tn) -3.0 (truncate-quotient -7.0 2))
      (assert-eqv-number? (tn) -1.0 (truncate-remainder -7.0 2))
      (assert-equal? (tn) '(-4.0 1.0)
                     (call-with-values (lambda () (floor/ -7 2.0)) list))
      (assert-equal? (tn) '(-3.0 -1.0)
                     (call-with-values (lambda () (truncate/ -7.0 2)) list))))
(assert-error (tn) (lambda () (quotient 1.5 1)))
(assert-error (tn) (lambda () (modulo 1 0.0)))

(tn "expt")
(assert-eqv-number? (tn) 8.0 (expt 2.0 3))
(assert-eqv-number? (tn) 0.5 (expt 2 -1))
(assert-eqv-number? (tn) 2.0 (expt 4 0.5))
(assert-eqv-number? (tn) 6.25 (expt 2.5 2))
(assert-eqv-number? (tn) 1024 (expt 2 10))
(assert-error (tn) (lambda () (expt 0 -1)))

(tn "square")
(if (provided? "r7rs")
    (assert-eqv-number? (tn) 2.25 (square 1.5)))

(tn "rounding")
(assert-eqv-number? (tn) -3.0 (floor -2.5))
(assert-eqv-number? (tn) -2.0 (ceiling -2.5))
(assert-eqv-number? (tn) -2.0 (truncate -2.5))
(assert-eqv-number? (tn) 2.0 (round 2.5))
(assert-eqv-number? (tn) 4.0 (round 3.5))
(assert-eqv-number? (tn) -2.0 (round -2.5))
(assert-eqv-number? (tn) 3.0 (round 2.6))
(assert-eqv-number? (tn) 3 (round 3))

(tn "exactness")
(assert-eqv-number? (tn) 2.0 (exact->inexact 2))
(assert-eqv-number? (tn) 2.5 (exact->inexact 2.5))
(assert-eqv-number? (tn) -4 (inexact->exact -4.0))
(assert-eqv-number? (tn) 10000000000 (inexact->exact 1e10))
(assert-eqv-number? (tn) 3 (inexact->exact 3))
(assert-error (tn) (lambda () (inexact->exact 1.5)))
(assert-error (tn) (lambda () (inexact->exact +inf.0)))
(assert-error (tn) (lambda () (inexact->exact +nan.0)))
(assert-error (tn) (lambda () (exact->inexact 'a)))
(if (provided? "r7rs")
    (begin
      (assert-eqv-number? (tn) 2.0 (inexact 2))
      (assert-eqv-number? (tn) 2 (exact 2.0))
      (assert-error (tn) (lambda () (exact 1.5)))))

(tn "numerator denominator")
(assert-eqv-number? (tn) 1.0 (numerator 0.5))
(assert-eqv-number? (tn) 2.0 (denominator 0.5))
(assert-eqv-number? (tn) 3.0 (numerator 0.75))
(assert-eqv-number? (tn) 4.0 (denominator 0.75))
(assert-eqv-number? (tn) -5.0 (numerator -5.0))
(assert-eqv-number? (tn) 1.0 (denominator -5.0))
(assert-error (tn) (lambda () (numerator +inf.0)))

(tn "gcd lcm")
(assert-eqv-number? (tn) 4.0 (gcd 32.0 -36))
(assert-eqv-number? (tn) 4.0 (gcd -4.0))
(assert-eqv-number? (tn) 4.0 (gcd 0 4.0))
(assert-eqv-number? (tn) 288.0 (lcm 32.0 -36))
(assert-eqv-number? (tn) 3.0 (lcm -3.0))
(assert-eqv-number? (tn) 0.0 (lcm 0 2.0))
(assert-error (tn) (lambda () (gcd 1.5 2)))

(tn "rationalize")
(assert-eqv-number? (tn) 0.3333333333333333 (rationalize 0.3 0.1))
(assert-eqv-number? (tn) -0.3333333333333333 (rationalize -0.3 0.1))
(assert-eqv-number? (tn) 1.0 (rationalize 1 0.5))
(assert-eqv-number? (tn) 0.0 (rationalize 0.3 1))
(assert-eqv-number? (tn) 2 (rationalize 3 1))
(assert-eqv-number? (tn) 0 (rationalize 5 10))
(assert-eqv-number? (tn) +inf.0 (rationalize +inf.0 3))

(tn "sqrt")
(assert-eqv-number? (tn) 2 (sqrt 4))
(assert-eqv-number? (tn) 0 (sqrt 0))
(assert-eqv-number? (tn) 1000000 (sqrt 1000000000000))
(assert-eqv-number? (tn) 1.4142135623730951 (sqrt 2))
(assert-eqv-number? (tn) 4.0 (sqrt 16.0))
(assert-eqv-number? (tn) +inf.0 (sqrt +inf.0))
(assert-error (tn) (lambda () (sqrt -1)))
(assert-error (tn) (lambda () (sqrt 'a)))

(tn "exp log")
(assert-eqv-number? (tn) 1.0 (exp 0))
(assert-eqv-number? (tn) 0.0 (log 1))
(assert-eqv-number? (tn) -inf.0 (log 0))
(assert-eqv-number? (tn) 2.0 (log 100 10))
(assert-eqv-number? (tn) 3.0 (log 8 2))
(assert-error (tn) (lambda () (log -1)))
(assert-error (tn) (lambda () (log 1 -2)))
(assert-error (tn) (lambda () (log 1 2 3)))

(tn "trigonometric functions")
(assert-eqv-number? (tn) 0.0 (sin 0))
(assert-eqv-number? (tn) 1.0 (cos 0))
(assert-eqv-number? (tn) 0.0 (tan 0))
(assert-eqv-number? (tn) 1.5707963267948966 (asin 1))
(assert-eqv-number? (tn) 0.0 (acos 1))
(assert-eqv-number? (tn) 0.7853981633974483 (atan 1))
(assert-eqv-number? (tn) 2.356194490192345 (atan 1 -1))
(assert-eqv-number? (tn) 3.141592653589793 (atan 0 -1))
(assert-error (tn) (lambda () (asin 2)))
(assert-error (tn) (lambda () (acos -2)))

(tn "expt complex")
(assert-error (tn) (lambda () (expt -8 0.5)))
(assert-eqv-number? (tn) -8.0 (expt -2.0 3))

(total-report)
