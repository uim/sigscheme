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


(require-extension (srfi 64))
(require-extension (srfi 6))

(if (not (string->number "0.5"))
    (test-skip-file "inexact real numbers are not enabled"))

(test-begin "test-real")

(define (write-to-string obj)
  (let ((port (open-output-string)))
    (write obj port)
    (get-output-string port)))

(test-begin "read decimal")
(test-equal "1.0" (write-to-string 1.0))
(test-equal "1.0" (write-to-string 1.))
(test-equal "0.5" (write-to-string .5))
(test-equal "-0.5" (write-to-string -.5))
(test-equal "0.5" (write-to-string '.5))
(test-equal '(1 0.5) '(1 .5))
(test-equal "-0.0" (write-to-string -0.0))
(test-equal "123.456" (write-to-string 123.456))
(test-end "read decimal")

(test-begin "read exponent")
(test-equal "100.0" (write-to-string 1e2))
(test-equal "100.0" (write-to-string 1E2))
(test-equal "0.01" (write-to-string 1e-2))
(test-equal "100.0" (write-to-string 1s2))
(test-equal "100.0" (write-to-string 1d2))
(test-equal "1.5e-07" (write-to-string 1.5e-7))
(test-equal "1.0e+21" (write-to-string 1e21))
(test-end "read exponent")

(test-begin "read special values")
(test-equal "+inf.0" (write-to-string +inf.0))
(test-equal "-inf.0" (write-to-string -inf.0))
(test-equal "+nan.0" (write-to-string +nan.0))
(test-equal "+nan.0" (write-to-string +NAN.0))
(test-end "read special values")

(test-begin "read prefixes")
(test-equal "1.0" (write-to-string #i1))
(test-equal "16.0" (write-to-string #i#x10))
(test-equal "16.0" (write-to-string #x#i10))
(test-equal 1 #e1.0)
(test-equal 1000 #e1e3)
(test-equal 16 #e#x10)
(test-equal 482 #x1e2)
(test-error (read (open-input-string "#e1.5")))
(test-error (read (open-input-string "#x1.5")))
(test-error (read (open-input-string "#i#i1")))
(test-error (read (open-input-string "#i3/2")))
(test-equal "1.0e+30"
       (write-to-string
        (read (open-input-string "#i1000000000000000000000000000000"))))
(test-error (read (open-input-string "1.5.5")))
(test-end "read prefixes")

(test-begin "write shortest")
(test-equal "0.1" (write-to-string 0.1))
(test-equal "0.14285714285714282"
       (write-to-string 0.14285714285714282))
(test-equal "5.0e-324" (write-to-string 4.940656458412465e-324))
(test-equal "1.7976931348623157e+308"
       (write-to-string 1.7976931348623157e308))
(test-equal "100000000000000000000.0" (write-to-string 1e20))
(test-equal "0.0001" (write-to-string 1e-4))
(test-equal "1.0e-05" (write-to-string 1e-5))
(test-end "write shortest")

(test-begin "string->number")
(test-equal "1.5" (write-to-string (string->number "1.5")))
(test-equal "1.5" (write-to-string (string->number "#d1.5")))
(test-equal 15 (string->number "#e1.5e1"))
(test-assert (not (string->number "#e1.5")))
(test-assert (not (string->number "1.5" 16)))
(test-assert (not (string->number ".")))
(test-assert (not (string->number "1e")))
(test-assert (not (string->number "e1")))
(test-assert (not (string->number "+inf")))
(test-end "string->number")

(test-begin "number->string")
(test-equal "1.0" (number->string 1.0))
(test-equal "-2.5" (number->string -2.5))
(test-equal "1.0e+100" (number->string 1e100))
(test-equal "1.5" (number->string 1.5 10))
(test-error (number->string 1.5 16))
(test-end "number->string")

(test-begin "number predicates")
(test-assert (number? 1.5))
(test-assert (complex? 1.5))
(test-assert (real? 1.5))
(test-assert (rational? 1.5))
(test-assert (not (rational? +inf.0)))
(test-assert (not (rational? +nan.0)))
(test-assert (integer? 2.0))
(test-assert (not (integer? 2.5)))
(test-assert (not (integer? +inf.0)))
(test-assert (integer? 1e300))
(test-assert (not (exact? 1.0)))
(test-assert (inexact? 1.0))
(test-assert (not (inexact? 1)))
(test-error (exact? 'a))
(test-end "number predicates")

(test-begin "eqv?")
(test-assert (eqv? 1.5 1.5))
(test-assert (not (eqv? 1.0 1)))
(test-assert (not (eqv? 0.0 -0.0)))
(test-assert (eqv? +nan.0 +nan.0))
(test-assert (equal? '(1.5 #(2.5)) (list 1.5 (vector 2.5))))
(test-equal '(2.0) (memv 2.0 '(1.0 2.0)))
(test-equal '(2.0 . x) (assv 2.0 '((1.0 . y) (2.0 . x))))
(test-end "eqv?")

;; Use eqv? to distinguish exactness.
(test-begin "+")
(test-eqv 3.5 (+ 1 2.5))
(test-eqv 3.5 (+ 2.5 1))
(test-eqv 1.5 (+ 1.5))
(test-eqv 6.0 (+ 1 2 3.0))
(test-eqv 6 (+ 1 2 3))
(test-error (+ 1.5 'a))
(test-end "+")

(test-begin "-")
(test-eqv -1.5 (- 1.5))
(test-eqv 2.5 (- 3 0.5))
(test-eqv 0.0 (- 1.5 1 0.5))
(test-end "-")

(test-begin "*")
(test-eqv 3.0 (* 2 1.5))
(test-eqv 1.5 (* 1.5))
(test-eqv 0.0 (* 0 1.5))
(test-end "*")

(test-begin "/")
(test-eqv 0.5 (/ 1 2))
(test-eqv 0.5 (/ 2))
(test-eqv 2 (/ 6 3))
(test-eqv 0.25 (/ 1.0 4))
(test-eqv 0.25 (/ 1 2 2))
(test-eqv +inf.0 (/ 1 0.0))
(test-eqv -inf.0 (/ -1 0.0))
(test-error (/ 1 0))
(test-end "/")

(test-begin "comparison")
(test-assert (= 1 1.0))
(test-assert (< 1 1.5 2))
(test-assert (> 2.5 2 1))
(test-assert (<= 1 1.0 1))
(test-assert (>= 2.0 2 1.5))
(test-assert (not (= +nan.0 +nan.0)))
(test-assert (not (< 1 +nan.0)))
(test-assert (not (> +nan.0 1)))
(test-assert (< -inf.0 0 +inf.0))
;; Large integers are compared exactly.
(test-assert (not (= 9007199254740993 9007199254740992.0)))
(test-assert (< 9007199254740992.0 9007199254740993))
(test-error (< 1.5 'a))
(test-end "comparison")

(test-begin "zero? positive? negative?")
(test-assert (zero? 0.0))
(test-assert (zero? -0.0))
(test-assert (positive? 1e-300))
(test-assert (not (positive? -0.0)))
(test-assert (negative? -0.5))
(test-assert (not (negative? +nan.0)))
(test-end "zero? positive? negative?")

(test-begin "odd? even?")
(test-assert (odd? 3.0))
(test-assert (odd? -3.0))
(test-assert (even? 4.0))
(test-assert (even? 0.0))
(test-error (odd? 1.5))
(test-error (even? +inf.0))
(test-end "odd? even?")

(test-begin "max min")
(test-eqv 2.0 (max 1 2.0))
(test-eqv 3.0 (max 3 2.0))
(test-eqv 1.0 (min 1 2.0))
(test-eqv 4.0 (max 2.0 3 4))
(test-eqv 1.5 (max 1.5))
(let ((nan (max 1 +nan.0)))
  (test-assert (not (= nan nan))))
(test-end "max min")

(test-begin "abs")
(test-eqv 2.5 (abs -2.5))
(test-eqv 0.0 (abs -0.0))
(test-end "abs")

(test-begin "integer division")
(test-eqv 3.0 (quotient 7.0 2))
(test-eqv -1.0 (remainder -7.0 2))
(test-eqv 1.0 (modulo -7.0 2))
(test-eqv -1.0 (modulo 7 -2.0))
(if (provided? "r7rs")
    (begin
      (test-eqv -4.0 (floor-quotient -7 2.0))
      (test-eqv 1.0 (floor-remainder -7 2.0))
      (test-eqv -3.0 (truncate-quotient -7.0 2))
      (test-eqv -1.0 (truncate-remainder -7.0 2))
      (test-equal '(-4.0 1.0)
             (call-with-values (lambda () (floor/ -7 2.0)) list))
      (test-equal '(-3.0 -1.0)
             (call-with-values (lambda () (truncate/ -7.0 2)) list))))
(test-error (quotient 1.5 1))
(test-error (modulo 1 0.0))
(test-end "integer division")

(test-begin "expt")
(test-eqv 8.0 (expt 2.0 3))
(test-eqv 0.5 (expt 2 -1))
(test-eqv 2.0 (expt 4 0.5))
(test-eqv 6.25 (expt 2.5 2))
(test-eqv 1024 (expt 2 10))
(test-error (expt 0 -1))
(test-end "expt")

(test-begin "square")
(if (provided? "r7rs")
    (test-eqv 2.25 (square 1.5)))
(test-end "square")

(test-begin "rounding")
(test-eqv -3.0 (floor -2.5))
(test-eqv -2.0 (ceiling -2.5))
(test-eqv -2.0 (truncate -2.5))
(test-eqv 2.0 (round 2.5))
(test-eqv 4.0 (round 3.5))
(test-eqv -2.0 (round -2.5))
(test-eqv 3.0 (round 2.6))
(test-eqv 3 (round 3))
(test-end "rounding")

(test-begin "exactness")
(test-eqv 2.0 (exact->inexact 2))
(test-eqv 2.5 (exact->inexact 2.5))
(test-eqv -4 (inexact->exact -4.0))
(test-eqv 10000000000 (inexact->exact 1e10))
(test-eqv 3 (inexact->exact 3))
(test-error (inexact->exact 1.5))
(test-error (inexact->exact +inf.0))
(test-error (inexact->exact +nan.0))
(test-error (exact->inexact 'a))
(if (provided? "r7rs")
    (begin
      (test-eqv 2.0 (inexact 2))
      (test-eqv 2 (exact 2.0))
      (test-error (exact 1.5))))
(test-end "exactness")

(test-begin "numerator denominator")
(test-eqv 1.0 (numerator 0.5))
(test-eqv 2.0 (denominator 0.5))
(test-eqv 3.0 (numerator 0.75))
(test-eqv 4.0 (denominator 0.75))
(test-eqv -5.0 (numerator -5.0))
(test-eqv 1.0 (denominator -5.0))
(test-error (numerator +inf.0))
(test-end "numerator denominator")

(test-begin "gcd lcm")
(test-eqv 4.0 (gcd 32.0 -36))
(test-eqv 4.0 (gcd -4.0))
(test-eqv 4.0 (gcd 0 4.0))
(test-eqv 288.0 (lcm 32.0 -36))
(test-eqv 3.0 (lcm -3.0))
(test-eqv 0.0 (lcm 0 2.0))
(test-error (gcd 1.5 2))
(test-end "gcd lcm")

(test-begin "rationalize")
(test-eqv 0.3333333333333333 (rationalize 0.3 0.1))
(test-eqv -0.3333333333333333 (rationalize -0.3 0.1))
(test-eqv 1.0 (rationalize 1 0.5))
(test-eqv 0.0 (rationalize 0.3 1))
(test-eqv 2 (rationalize 3 1))
(test-eqv 0 (rationalize 5 10))
(test-eqv +inf.0 (rationalize +inf.0 3))
(test-end "rationalize")

(test-begin "sqrt")
(test-eqv 2 (sqrt 4))
(test-eqv 0 (sqrt 0))
(test-eqv 1000000 (sqrt 1000000000000))
(test-eqv 1.4142135623730951 (sqrt 2))
(test-eqv 4.0 (sqrt 16.0))
(test-eqv +inf.0 (sqrt +inf.0))
(test-error (sqrt -1))
(test-error (sqrt 'a))
(test-end "sqrt")

(test-begin "exp log")
(test-eqv 1.0 (exp 0))
(test-eqv 0.0 (log 1))
(test-eqv -inf.0 (log 0))
(test-eqv 2.0 (log 100 10))
(test-eqv 3.0 (log 8 2))
(test-error (log -1))
(test-error (log 1 -2))
(test-argcheck-error (log 1 2 3))
(test-end "exp log")

(test-begin "trigonometric functions")
(test-eqv 0.0 (sin 0))
(test-eqv 1.0 (cos 0))
(test-eqv 0.0 (tan 0))
(test-eqv 1.5707963267948966 (asin 1))
(test-eqv 0.0 (acos 1))
(test-eqv 0.7853981633974483 (atan 1))
(test-eqv 2.356194490192345 (atan 1 -1))
(test-eqv 3.141592653589793 (atan 0 -1))
(test-error (asin 2))
(test-error (acos -2))
(test-end "trigonometric functions")

(test-begin "expt complex")
(test-error (expt -8 0.5))
(test-eqv -8.0 (expt -2.0 3))
(test-end "expt complex")

(test-end "test-real")
