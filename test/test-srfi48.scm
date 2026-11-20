#! /usr/bin/env sscm -C UTF-8

;;  Filename : test-srfi48.scm
;;  About    : unit test for SRFI-48
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

;; All tests in this file are passed against r3170 (new repository)

(require-extension (srfi 64))

(require-extension (srfi 6 38 48))

(if (not (provided? "r6rs-chars"))
    (test-skip-file "R6RS characters is not enabled"))

(test-begin "test-srfi48")

;; test SRFI-28 compatible part of SRFI-48
(load "./test/test-srfi28.scm")

(define testing-format+? (and (symbol-bound? 'format+)
                              (eq? format format+)))

(define cl (list 0 1))
(set-cdr! (cdr cl) cl)

(test-begin "SRFI-48 format invalid form")
(test-error (format 0       "~~"))
(test-error (format #\a     "~~"))
(test-error (format "a"     "~~"))
(test-error (format '(0 1)  "~~"))
(test-error (format '#(0 1) "~~"))
(test-error (format 0       "~s" 0))
(test-error (format #\a     "~s" #\a))
(test-error (format "a"     "~s" "aBc"))
(test-error (format '(0 1)  "~s" '(0 1)))
(test-error (format '#(0 1) "~s" '#(0 1)))
(test-error (format "~"))
(test-error (format "a~"))
(test-end "SRFI-48 format invalid form")

(test-begin "SRFI-48 format explicit port")
(test-equal "\"aBc\""
            (format #f "~s" "aBc"))
(display "expected output: \"aBc\"")
(newline)
(display "actual output:   ")
(test-equal (undef)
            (format #t "~s" "aBc"))
(newline)
(let ((port (open-output-string)))
  (test-equal (undef)
              (format port "~s" "aBc"))
  (test-equal "\"aBc\""
              (get-output-string port)))
(test-end "SRFI-48 format explicit port")

(test-begin "format ~w")
(test-error (format "~w"))
(test-error (format "~w" 0 1))
(test-error (format "~1w" 1))
(test-equal "#f"
            (format "~w" #f))
(test-equal "#t"
            (format "~w" #t))
(test-equal "123"
            (format "~w" 123))
(test-equal "#\\a"
            (format "~w" #\a))
(test-equal "\"\""
            (format "~w" ""))
(test-equal "\"\\\"\""
            (format "~w" "\""))
(test-equal "\"aBc\""
            (format "~w" "aBc"))
(test-equal "(#t 123 #\\a \"aBc\" (0))"
            (format "~w" '(#t 123 #\a "aBc" (0))))
(test-equal "#(#t 123 #\\a \"aBc\" (0))"
            (format "~w" '#(#t 123 #\a "aBc" (0))))
(test-equal (if (provided? "sigscheme")
                "#1=(0 1 . #1#)"  ;; SigScheme starts the index with 1
                "#0=(0 1 . #0#)")
            (format "~w" cl))
(test-equal "#t"
            (format "~W" #t))
(test-end "format ~w")

(test-begin "format ~d")
(test-error (format "~d"))
(test-error (format "~d" 0 1))
(test-error (format "~d" #t))
(test-error (format "~d" #\a))
(test-error (format "~d" "aBc"))
(test-error (format "~d" '(0 1)))
(test-error (format "~d" '#(0 1)))
(if (not testing-format+?)
    (test-error (format "~1d" 1)))
(test-equal "-100" (format "~d" -100))
(test-equal "-10"  (format "~d" -10))
(test-equal "-1"   (format "~d" -1))
(test-equal "0"    (format "~d" 0))
(test-equal "1"    (format "~d" 1))
(test-equal "10"   (format "~d" 10))
(test-equal "100"  (format "~d" 100))
(test-equal "10"   (format "~D" 10))
(test-end "format ~d")

(test-begin "format ~x")
(test-error (format "~x"))
(test-error (format "~x" 0 1))
(test-error (format "~x" #t))
(test-error (format "~x" #\a))
(test-error (format "~x" "aBc"))
(test-error (format "~x" '(0 1)))
(test-error (format "~x" '#(0 1)))
(if (not testing-format+?)
    (test-error (format "~1x" 1)))
(test-equal "-64"  (format "~x" -100))
(test-equal "-a"   (format "~x" -10))
(test-equal "-1"   (format "~x" -1))
(test-equal "0"    (format "~x" 0))
(test-equal "1"    (format "~x" 1))
(test-equal "a"    (format "~x" 10))
(test-equal "64"   (format "~x" 100))
(test-equal "a"    (format "~X" 10))
(test-end "format ~x")

(test-begin "format ~o")
(test-error (format "~o"))
(test-error (format "~o" 0 1))
(test-error (format "~o" #t))
(test-error (format "~o" #\a))
(test-error (format "~o" "aBc"))
(test-error (format "~o" '(0 1)))
(test-error (format "~o" '#(0 1)))
(if (not testing-format+?)
    (test-error (format "~1o" 1)))
(test-equal "-144" (format "~o" -100))
(test-equal "-12"  (format "~o" -10))
(test-equal "-1"   (format "~o" -1))
(test-equal "0"    (format "~o" 0))
(test-equal "1"    (format "~o" 1))
(test-equal "12"   (format "~o" 10))
(test-equal "144"  (format "~o" 100))
(test-equal "12"   (format "~O" 10))
(test-end "format ~o")

(test-begin "format ~b")
(test-error (format "~b"))
(test-error (format "~b" 0 1))
(test-error (format "~b" #t))
(test-error (format "~b" #\a))
(test-error (format "~b" "aBc"))
(test-error (format "~b" '(0 1)))
(test-error (format "~b" '#(0 1)))
(if (not testing-format+?)
    (test-error (format "~1b" 1)))
(test-equal "-1100100" (format "~b" -100))
(test-equal "-1010"    (format "~b" -10))
(test-equal "-1"       (format "~b" -1))
(test-equal "0"        (format "~b" 0))
(test-equal "1"        (format "~b" 1))
(test-equal "1010"     (format "~b" 10))
(test-equal "1100100"  (format "~b" 100))
(test-equal "1010"     (format "~B" 10))
(test-end "format ~b")

(if (and (symbol-bound? 'greatest-fixnum)
         (symbol-bound? 'least-fixnum))
    (case fixnum-bits
      ((28)
       (test-begin "format 28bit fixnum")
       (test-equal "-134217728"
                   (format "~d" (least-fixnum)))
       (test-equal "111111111111111111111111111"
                   (format "~b" (greatest-fixnum)))
       (test-equal "-1000000000000000000000000000"
                   (format "~b" (least-fixnum)))
       (test-equal "-111111111111111111111111111"
                   (format "~b" (+ (least-fixnum) 1)))
       (test-end "format 28bit fixnum"))

      ((32)
       (test-begin "format 32bit fixnum")
       (test-equal "-2147483648"
                   (format "~d" (least-fixnum)))
       (test-equal "1111111111111111111111111111111"
                   (format "~b" (greatest-fixnum)))
       (test-equal "-10000000000000000000000000000000"
                   (format "~b" (least-fixnum)))
       (test-equal "-1111111111111111111111111111111"
                   (format "~b" (+ (least-fixnum) 1)))
       (test-end "format 32bit fixnum"))

      ((60)
       (test-begin "format 60bit fixnum")
       (test-equal "-576460752303423488"
                   (format "~d" (least-fixnum)))
       (test-equal "11111111111111111111111111111111111111111111111111111111111"
                   (format "~b" (greatest-fixnum)))
       (test-equal "-100000000000000000000000000000000000000000000000000000000000"
                   (format "~b" (least-fixnum)))
       (test-equal "-11111111111111111111111111111111111111111111111111111111111"
                   (format "~b" (+ (least-fixnum) 1)))
       (test-end "format 60bit fixnum"))

      ((64)
       (test-begin "format 64bit fixnum")
       (test-equal "-9223372036854775808"
                   (format "~d" (least-fixnum)))
       (test-equal "111111111111111111111111111111111111111111111111111111111111111"
                   (format "~b" (greatest-fixnum)))
       (test-equal "-1000000000000000000000000000000000000000000000000000000000000000"
                   (format "~b" (least-fixnum)))
       (test-equal "-111111111111111111111111111111111111111111111111111111111111111"
                   (format "~b" (+ (least-fixnum) 1)))
       (test-end "format 64bit fixnum"))

      (else
       (error "unknown int bitwidth"))))

(test-begin "format ~c")
(test-error (format "~c"))
(test-error (format "~c" #\a #\b))
(test-error (format "~c" #t))
(test-error (format "~c" 0))
(test-error (format "~c" "aBc"))
(test-error (format "~c" '(#\a #\b)))
(test-error (format "~c" '#(#\a #\b)))
(test-error (format "~1c" #\a))
(test-equal "a"  (format "~c" #\a))
(test-equal "\"" (format "~c" #\"))
(test-equal "あ" (format "~c" #\あ))
(test-end "format ~c")

(test-begin "format ~f (number)")
(test-error (format "~f"))
(test-error (format "~f" 0 1))
(test-error (format "~f" #t))
(test-error (format "~f" #\a))
(test-error (format "~f" '(0 1)))
(test-error (format "~f" '#(0 1)))
(test-error (format "0128f"    1))
(test-error (format "0128,1f"  1))
(test-error (format "1,0128f"  1))
(test-error (format "01024f"   1))
(test-error (format "01024,1f" 1))
(test-error (format "1,01024f" 1))
(test-error (format "~-1f"    1))
(test-error (format "~-0f"    1))
(test-error (format "~0,-0f"  1))
(test-error (format "~0,-1f"  1))
(test-error (format "~1,-0f"  1))
(test-error (format "~1,-1f"  1))
(test-error (format "~-0,0f"  1))
(test-error (format "~-0,1f"  1))
(test-error (format "~-1,0f"  1))
(test-error (format "~-1,1f"  1))
(test-error (format "~-0,-0f" 1))
(test-error (format "~-0,-1f" 1))
(test-error (format "~-1,-0f" 1))
(test-error (format "~-1,-1f" 1))
(test-error (format "~,f"     1))
(test-error (format "~,1f"    1))
(test-error (format "~1,f"    1))
(test-equal "-100" (format "~f" -100))
(test-equal "-10"  (format "~f" -10))
(test-equal "-1"   (format "~f" -1))
(test-equal "0"    (format "~f" 0))
(test-equal "1"    (format "~f" 1))
(test-equal "10"   (format "~f" 10))
(test-equal "100"  (format "~f" 100))

(if (not testing-format+?)
    (begin
      (test-equal "-100" (format "~0f" -100))
      (test-equal "-10"  (format "~0f" -10))
      (test-equal "-1"   (format "~0f" -1))
      (test-equal "0"    (format "~0f" 0))
      (test-equal "1"    (format "~0f" 1))
      (test-equal "10"   (format "~0f" 10))
      (test-equal "100"  (format "~0f" 100))))

(test-equal "-100" (format "~1f" -100))
(test-equal "-10"  (format "~1f" -10))
(test-equal "-1"   (format "~1f" -1))
(test-equal "0"    (format "~1f" 0))
(test-equal "1"    (format "~1f" 1))
(test-equal "10"   (format "~1f" 10))
(test-equal "100"  (format "~1f" 100))

(test-equal "-100" (format "~2f" -100))
(test-equal "-10"  (format "~2f" -10))
(test-equal "-1"   (format "~2f" -1))
(test-equal " 0"   (format "~2f" 0))
(test-equal " 1"   (format "~2f" 1))
(test-equal "10"   (format "~2f" 10))
(test-equal "100"  (format "~2f" 100))

(test-equal "-100" (format "~3f" -100))
(test-equal "-10"  (format "~3f" -10))
(test-equal " -1"  (format "~3f" -1))
(test-equal "  0"  (format "~3f" 0))
(test-equal "  1"  (format "~3f" 1))
(test-equal " 10"  (format "~3f" 10))
(test-equal "100"  (format "~3f" 100))

(test-equal "-100" (format "~4f" -100))
(test-equal " -10" (format "~4f" -10))
(test-equal "  -1" (format "~4f" -1))
(test-equal "   0" (format "~4f" 0))
(test-equal "   1" (format "~4f" 1))
(test-equal "  10" (format "~4f" 10))
(test-equal " 100" (format "~4f" 100))

(test-equal " -100" (format "~5f" -100))
(test-equal "  -10" (format "~5f" -10))
(test-equal "   -1" (format "~5f" -1))
(test-equal "    0" (format "~5f" 0))
(test-equal "    1" (format "~5f" 1))
(test-equal "   10" (format "~5f" 10))
(test-equal "  100" (format "~5f" 100))

(if (not testing-format+?)
    (begin
      (test-equal "-100" (format "~0,0f" -100))
      (test-equal "-10"  (format "~0,0f" -10))
      (test-equal "-1"   (format "~0,0f" -1))
      (test-equal "0"    (format "~0,0f" 0))
      (test-equal "1"    (format "~0,0f" 1))
      (test-equal "10"   (format "~0,0f" 10))
      (test-equal "100"  (format "~0,0f" 100))))

(if (not testing-format+?)
    (begin
      (test-equal " -100" (format "~05f" -100))
      (test-equal "  -10" (format "~05f" -10))
      (test-equal "   -1" (format "~05f" -1))
      (test-equal "    0" (format "~05f" 0))
      (test-equal "    1" (format "~05f" 1))
      (test-equal "   10" (format "~05f" 10))
      (test-equal "  100" (format "~05f" 100))))

;; Inexact numbers are supported only when "0.5" can be converted.
(if (string->number "0.5")
    (begin
      (test-equal "-100.0" (format "~5,0f" -100))
      (test-equal "-10.0"  (format "~5,0f" -10))
      (test-equal " -1.0"  (format "~5,0f" -1))
      (test-equal "  0.0"  (format "~5,0f" 0))
      (test-equal "  1.0"  (format "~5,0f" 1))
      (test-equal " 10.0"  (format "~5,0f" 10))
      (test-equal "100.0"  (format "~5,0f" 100))

      (test-equal "-100.0" (format "~5,1f" -100))
      (test-equal "-10.0"  (format "~5,1f" -10))
      (test-equal " -1.0"  (format "~5,1f" -1))
      (test-equal "  0.0"  (format "~5,1f" 0))
      (test-equal "  1.0"  (format "~5,1f" 1))
      (test-equal " 10.0"  (format "~5,1f" 10))
      (test-equal "100.0"  (format "~5,1f" 100))

      (test-equal "-100.00" (format "~5,2f" -100))
      (test-equal "-10.00"  (format "~5,2f" -10))
      (test-equal "-1.00"   (format "~5,2f" -1))
      (test-equal " 0.00"   (format "~5,2f" 0))
      (test-equal " 1.00"   (format "~5,2f" 1))
      (test-equal "10.00"   (format "~5,2f" 10))
      (test-equal "100.00"  (format "~5,2f" 100))

      (if (not testing-format+?)
          (begin
            (test-equal "-100.00" (format "~05,02f" -100))
            (test-equal "-10.00"  (format "~05,02f" -10))
            (test-equal "-1.00"   (format "~05,02f" -1))
            (test-equal " 0.00"   (format "~05,02f" 0))
            (test-equal " 1.00"   (format "~05,02f" 1))
            (test-equal "10.00"   (format "~05,02f" 10))
            (test-equal "100.00"  (format "~05,02f" 100))))

      (test-equal "100.0"  (format "~5,1F" 100))))

(test-equal "                                                                                                                            123"
            (format "~127f" 123))
(if (not testing-format+?)
    (test-equal "                                                                                                                            123"
                (format "~0127f" 123)))

(test-equal "10"    (format "~F" 10))
(test-equal "  100" (format "~5F" 100))
(test-end "format ~f (number)")

(test-begin "format ~f (string)")
(test-error (format "~f" "a" "b"))
(test-error (format "~f" '("a" "b")))
(test-error (format "~f" '#("a" "b")))
(test-error (format "0100f"   "a"))
(test-error (format "0100,1f" "a"))
(test-error (format "1,0100f" "a"))
(test-error (format "~-1f"    "a"))
(test-error (format "~-0f"    "a"))
(test-error (format "~0,-0f"  "a"))
(test-error (format "~0,-1f"  "a"))
(test-error (format "~1,-0f"  "a"))
(test-error (format "~1,-1f"  "a"))
(test-error (format "~-0,0f"  "a"))
(test-error (format "~-0,1f"  "a"))
(test-error (format "~-1,0f"  "a"))
(test-error (format "~-1,1f"  "a"))
(test-error (format "~-0,-0f" "a"))
(test-error (format "~-0,-1f" "a"))
(test-error (format "~-1,-0f" "a"))
(test-error (format "~-1,-1f" "a"))
(test-equal ""        (format "~f"   ""))
(test-equal "\""      (format "~f"   "\""))
(test-equal "aBc"     (format "~f"   "aBc"))
(test-equal "あbう"   (format "~f"   "あbう"))

(test-equal ""        (format "~0f"  ""))
(test-equal "\""      (format "~0f"  "\""))
(test-equal "aBc"     (format "~0f"  "aBc"))
(test-equal "あbう"   (format "~0f"  "あbう"))

(test-equal " "       (format "~1f"  ""))
(test-equal "\""      (format "~1f"  "\""))
(test-equal "aBc"     (format "~1f"  "aBc"))
(test-equal "あbう"   (format "~1f"  "あbう"))

(test-equal "  "      (format "~2f"  ""))
(test-equal " \""     (format "~2f"  "\""))
(test-equal "aBc"     (format "~2f"  "aBc"))
(test-equal "あbう"   (format "~2f"  "あbう"))

(test-equal "   "     (format "~3f"  ""))
(test-equal "  \""    (format "~3f"  "\""))
(test-equal "aBc"     (format "~3f"  "aBc"))
(test-equal "あbう"   (format "~3f"  "あbう"))

(test-equal "    "    (format "~4f"  ""))
(test-equal "   \""   (format "~4f"  "\""))
(test-equal " aBc"    (format "~4f"  "aBc"))
(test-equal " あbう"  (format "~4f"  "あbう"))

(test-equal "     "   (format "~5f"  ""))
(test-equal "    \""  (format "~5f"  "\""))
(test-equal "  aBc"   (format "~5f"  "aBc"))
(test-equal "  あbう" (format "~5f"  "あbう"))

(test-equal "     "   (format "~05f" ""))
(test-equal "    \""  (format "~05f" "\""))
(test-equal "  aBc"   (format "~05f" "aBc"))
(test-equal "  あbう" (format "~05f" "あbう"))

(test-equal "     "   (format "~5,2f"   ""))
(test-equal "    \""  (format "~5,2f"   "\""))
(test-equal "  aBc"   (format "~5,2f"   "aBc"))
(test-equal "  あbう" (format "~5,2f"   "あbう"))

(test-equal "     "   (format "~05,02f" ""))
(test-equal "    \""  (format "~05,02f" "\""))
(test-equal "  aBc"   (format "~05,02f" "aBc"))
(test-equal "  あbう" (format "~05,02f" "あbう"))

(test-equal "                                                                                                                            aBc"
            (format "~127f" "aBc"))
(test-equal "                                                                                                                            aBc"
            (format "~0127f" "aBc"))

(test-equal "aBc"     (format "~F"      "aBc"))
(test-equal "  aBc"   (format "~5F"     "aBc"))
(test-equal "  aBc"   (format "~05F"    "aBc"))
(test-equal "  aBc"   (format "~5,2F"   "aBc"))
(test-end "format ~f (string)")

(test-begin "format ~?")
(test-error (format "~?"))
(test-error (format "~?" "~~"))
(test-error (format "~?" "a"))
(test-error (format "~?" "a" '() "b"))
(test-error (format "~1?" "a" '()))
(test-error (format "~?" "~a" '()))
(test-error (format "~?" "~a" '(0 1)))
(test-error (format "~?" "~?" '("~a")))
(test-error (format "~?" "~?" '("~a" (0 1))))
(test-error (format "~?" #t      '()))
(test-error (format "~?" 0       '()))
(test-error (format "~?" #\a     '()))
(test-error (format "~?" '(0 1)  '()))
(test-error (format "~?" '#(0 1) '()))
(test-equal "~"       (format "~?" "~~" '()))
(test-equal " "       (format "~?" "~_" '()))
(test-equal "\n"      (format "~?" "~%" '()))
(test-equal "\n"      (format "~?" "~&" '()))
;; hard to be this on current port implementation
;;(assert-equal? (tn) "\n"      (format "~?" "~%~?"  '("~&" ())))
(test-equal "\n\n"    (format "~?" "~%~?"  '("~&" ())))
(test-equal "\n \n"   (format "~?" "~% ~?" '("~&" ())))
(test-equal "\n \n"   (format "~?" "~%~?"  '(" ~&" ())))
(test-equal "aBc"     (format "~?" "aBc" '()))
(test-equal "0aBc1"   (format "~?" "0~a1" '("aBc")))
(test-equal "02aBc31" (format "~?" "0~?1" '("2~a3" ("aBc"))))
(test-equal "024aBc531"
       (format "~?" "0~?1" '("2~?3" ("4~a5" ("aBc")))))
(test-equal "#f"
            (format "~?" "~w" '(#f)))
(test-equal "#t"
            (format "~?" "~w" '(#t)))
(test-equal "123"
            (format "~?" "~w" '(123)))
(test-equal "#\\a"
            (format "~?" "~w" '(#\a)))
(test-equal "\"\""
            (format "~?" "~w" '("")))
(test-equal "\"\\\"\""
            (format "~?" "~w" '("\"")))
(test-equal "\"aBc\""
            (format "~?" "~w" '("aBc")))
(test-equal "(#t 123 #\\a \"aBc\" (0))"
            (format "~?" "~w" '((#t 123 #\a "aBc" (0)))))
(test-equal "#(#t 123 #\\a \"aBc\" (0))"
            (format "~?" "~w" '(#(#t 123 #\a "aBc" (0)))))
(test-equal (if (provided? "sigscheme")
                "#1=(0 1 . #1#)"  ;; SigScheme starts the index with 1
                "#0=(0 1 . #0#)")
            (format "~?" "~w" (list cl)))
(test-end "format ~?")

;; alias of ~?
(test-begin "format ~k")
(test-error (format "~k"))
(test-error (format "~k" "~~"))
(test-error (format "~k" "a"))
(test-error (format "~k" "a" '() "b"))
(test-error (format "~1k" "a" '()))
(test-error (format "~k" "~a" '()))
(test-error (format "~k" "~a" '(0 1)))
(test-error (format "~k" "~k" '("~a")))
(test-error (format "~k" "~k" '("~a" (0 1))))
(test-error (format "~k" #t      '()))
(test-error (format "~k" 0       '()))
(test-error (format "~k" #\a     '()))
(test-error (format "~k" '(0 1)  '()))
(test-error (format "~k" '#(0 1) '()))
(test-equal "~"       (format "~k" "~~" '()))
(test-equal "02aBc31" (format "~k" "0~k1" '("2~a3" ("aBc"))))
(test-error (format "~K"))
(test-error (format "~K" "~~"))
(test-error (format "~K" "a"))
(test-error (format "~K" "a" '() "b"))
(test-error (format "~1K" "a" '()))
(test-error (format "~K" "~a" '()))
(test-error (format "~K" "~a" '(0 1)))
(test-error (format "~K" "~K" '("~a")))
(test-error (format "~K" "~K" '("~a" (0 1))))
(test-error (format "~K" #t      '()))
(test-error (format "~K" 0       '()))
(test-error (format "~K" #\a     '()))
(test-error (format "~K" '(0 1)  '()))
(test-error (format "~K" '#(0 1) '()))
(test-equal "~"       (format "~K" "~~" '()))
(test-equal "02aBc31" (format "~K" "0~K1" '("2~a3" ("aBc"))))
(test-end "format ~k")

(test-begin "format ~y")
(test-error (format "~y"))
(test-error (format "~y" 0 1))
(test-error (format "~1y" 1))
(test-equal "#f"
            (format "~y" #f))
(test-equal "#t"
            (format "~y" #t))
(test-equal "123"
            (format "~y" 123))
(test-equal "#\\a"
            (format "~y" #\a))
(test-equal "\"\""
            (format "~y" ""))
(test-equal "\"\\\"\""
            (format "~y" "\""))
(test-equal "\"aBc\""
            (format "~y" "aBc"))
;; no pretty-print procedure
(test-equal "(#t 123 #\\a \"aBc\" (0))"
            (format "~y" '(#t 123 #\a "aBc" (0))))
(test-equal "#(#t 123 #\\a \"aBc\" (0))"
            (format "~y" '#(#t 123 #\a "aBc" (0))))
(test-end "format ~y")
(test-begin "format ~y with explicit port to pretty-print")
(let ((p (open-output-string)))
  (format p "~y" 123)
  (test-equal "123" (get-output-string p)))
(define pretty-print write)
(let ((p (open-output-string)))
  (format p "~y" 123)
  (test-equal "123" (get-output-string p)))
(define pretty-print #f)
(let ((p (open-output-string)))
  (test-error (format p "~y" 123)))
(test-end "format ~y with explicit port to pretty-print")

(test-begin "format ~t")
(test-error (format "~t" #t))
(test-error (format "~t" 0))
(test-error (format "~t" #\a))
(test-error (format "~t" "aBc"))
(test-error (format "~t" '(0 1)))
(test-error (format "~t" '#(0 1)))
(test-error (format "~1t"))
(test-equal "	" (format "~t"))
(test-equal "\t"  (format "~t"))
(test-equal "\t"  (format "~T"))
(test-end "format ~t")

(test-begin "format ~_")
(test-error (format "~_" #t))
(test-error (format "~_" 0))
(test-error (format "~_" #\a))
(test-error (format "~_" "aBc"))
(test-error (format "~_" '(0 1)))
(test-error (format "~_" '#(0 1)))
(test-error (format "~1_"))
(test-equal " " (format "~_"))
(test-end "format ~_")

(test-begin "format ~&")
(test-error (format "~&" #t))
(test-error (format "~&" 0))
(test-error (format "~&" #\a))
(test-error (format "~&" "aBc"))
(test-error (format "~&" '(0 1)))
(test-error (format "~&" '#(0 1)))
(test-error (format "~1&"))
(test-equal "
" (format "~&"))
(test-equal "\n"   (format "~&"))
(test-equal "\n"   (format "~&~&"))
(test-equal "\n"   (format "~&~&~&"))
(test-equal "\n"   (format "~%~&"))
(test-equal "\n"   (format "~%~&~&"))
(test-equal "\n\n" (format "~&~%"))
(test-equal "\n\n" (format "~&~%~&"))
(test-equal "\n"   (format "\n~&"))
(test-equal "\n\n" (format "~&\n"))
(test-equal "\n\n" (format "~&\n~&"))
(test-equal " \n"  (format " ~&"))
(test-equal "\n \n \n" (format "\n ~& ~&"))
(test-end "format ~&")

(test-begin "format ~h")
(define help-str
"(format [<port>] <format-string> [<arg>...])
  - <port> is #t, #f or an output-port
  - any escape sequence is case insensitive

SEQ   MNEMONIC        DESCRIPTION
~H    [Help]          output this text
~A    [Any]           (display arg) for humans
~S    [Slashified]    (write arg) for parsers
~W    [WriteCircular] like ~s but outputs with write/ss
~~    [Tilde]         output a tilde
~T    [Tab]           output a tab character
~%    [Newline]       output a newline character
~&    [Freshline]     output a newline if the previous output was not a newline
~D    [Decimal]       the arg is a number which is output in decimal radix
~X    [heXadecimal]   the arg is a number which is output in hexdecimal radix
~O    [Octal]         the arg is a number which is output in octal radix
~B    [Binary]        the arg is a number which is output in binary radix
~F
~wF   [Fixed]         the arg is a string or number which has width w and
~w,dF                 d digits after the decimal
~C    [Character]     character arg is output by write-char
~_    [Space]         a single space character is output
~Y    [Yuppify]       the list arg is pretty-printed to the output
~?    [Indirection]   recursive format: next 2 args are format-string and list
                      of arguments
~K    [Indirection]   same as ~?
")
(if (not testing-format+?)
    (begin
      (test-error (format "~h" #t))
      (test-error (format "~h" 0))
      (test-error (format "~h" #\a))
      (test-error (format "~h" "aBc"))
      (test-error (format "~h" '(0 1)))
      (test-error (format "~h" '#(0 1)))
      (test-error (format "~1h"))
      (test-equal help-str (format "~h"))
      (test-equal help-str (format "~H"))))
(test-end "format ~h")

(test-end "test-srfi48")
