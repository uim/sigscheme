;;  Filename : test-number-io.scm
;;  About    : unit test for R5RS number<->string conversion procedures
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

(test-begin "test-number-io")


;;
;; number->string
;;

(test-begin "number->string invalid radix")
(test-error (number->string 0 -16))
(test-error (number->string 0 -10))
(test-error (number->string 0 -8))
(test-error (number->string 0 -2))
(test-error (number->string 0 -1))
(test-error (number->string 0 0))
(test-error (number->string 0 1))
(test-error (number->string 0 3))
(test-error (number->string 0 4))
(test-error (number->string 0 7))
(test-error (number->string 0 9))
(test-error (number->string 0 11))
(test-error (number->string 0 15))
(test-error (number->string 0 17))
(test-end "number->string invalid radix")
(test-begin "number->string invalid forms")
(test-error (number->string))
(test-error (number->string "0"))
(test-error (number->string #\0))
(test-error (number->string #f))
(test-error (number->string '()))
(test-error (number->string "0" 2))
(test-error (number->string 0 "2"))
(test-error (number->string 0 2 #f))
(test-end "number->string invalid forms")
(test-begin "number->string implicit decimal")
(test-equal "-100" (number->string -100))
(test-equal "-10"  (number->string -10))
(test-equal "-1"   (number->string -1))
(test-equal "0"    (number->string 0))
(test-equal "1"    (number->string 1))
(test-equal "10"   (number->string 10))
(test-equal "100"  (number->string 100))
(test-end "number->string implicit decimal")
(if (>= fixnum-bits 60)
    (begin
      (test-begin "number->string implicit decimal 64-bit")
      (string-eval "(test-equal  \"956397711204\"  (number->string  956397711204))")
      (string-eval "(test-equal \"-956397711204\"  (number->string -956397711204))")
      (test-end "number->string implicit decimal 64-bit")))
(test-begin "number->string explicit decimal")
(test-equal "-100" (number->string -100 10))
(test-equal "-10"  (number->string -10  10))
(test-equal "-1"   (number->string -1   10))
(test-equal "0"    (number->string 0    10))
(test-equal "1"    (number->string 1    10))
(test-equal "10"   (number->string 10   10))
(test-equal "100"  (number->string 100  10))
(test-end "number->string explicit decimal")
(if (>= fixnum-bits 60)
    (begin
      (test-begin "number->string explicit decimal 64-bit")
      (string-eval "(test-equal  \"956397711204\"  (number->string  956397711204 10))")
      (string-eval "(test-equal \"-956397711204\"  (number->string -956397711204 10))")
      (test-end "number->string explicit decimal 64-bit")))
(test-begin "number->string hexadecimal")
(test-equal "-64"  (number->string -100 16))
(test-equal "-a"   (number->string -10  16))
(test-equal "-1"   (number->string -1   16))
(test-equal "0"    (number->string 0    16))
(test-equal "1"    (number->string 1    16))
(test-equal "a"    (number->string 10   16))
(test-equal "64"   (number->string 100  16))
(test-end "number->string hexadecimal")
(if (>= fixnum-bits 60)
    (begin
      (test-begin "number->string hexadecimal 64-bit")
      (string-eval "(test-equal  \"deadbeef64\"  (number->string  956397711204 16))")
      (string-eval "(test-equal \"-deadbeef64\"  (number->string -956397711204 16))")
      (test-end "number->string hexadecimal 64-bit")))
(test-begin "number->string octal")
(test-equal "-144" (number->string -100 8))
(test-equal "-12"  (number->string -10  8))
(test-equal "-1"   (number->string -1   8))
(test-equal "0"    (number->string 0    8))
(test-equal "1"    (number->string 1    8))
(test-equal "12"   (number->string 10   8))
(test-equal "144"  (number->string 100  8))
(test-end "number->string octal")
(if (>= fixnum-bits 60)
    (begin
      (test-begin "number->string octal 64-bit")
      (string-eval "(test-equal  \"15725557567544\"  (number->string  956397711204 8))")
      (string-eval "(test-equal \"-15725557567544\"  (number->string -956397711204 8))")
      (test-end "number->string octal 64-bit")))
(test-begin "number->string binary")
(test-equal "-1100100" (number->string -100 2))
(test-equal "-1010"    (number->string -10  2))
(test-equal "-1"       (number->string -1   2))
(test-equal "0"        (number->string 0    2))
(test-equal "1"        (number->string 1    2))
(test-equal "1010"     (number->string 10   2))
(test-equal "1100100"  (number->string 100  2))
(test-end "number->string binary")
(if (>= fixnum-bits 60)
    (begin
      (test-begin "number->string binary 64-bit")
      (string-eval "(test-equal  \"1101111010101101101111101110111101100100\"  (number->string  956397711204 2))")
      (string-eval "(test-equal \"-1101111010101101101111101110111101100100\"  (number->string -956397711204 2))")
      (test-end "number->string binary 64-bit")))
(test-begin "number->string boundary numbers")
(if (and (symbol-bound? 'greatest-fixnum)
         (symbol-bound? 'least-fixnum))
    (case fixnum-bits
      ((28)
       (test-equal "134217727"
                   (number->string (greatest-fixnum)))
       (test-equal "-134217728"
                   (number->string (least-fixnum)))
       (test-equal "111111111111111111111111111"
                   (number->string (greatest-fixnum) 2))
       (test-equal "-1000000000000000000000000000"
                   (number->string (least-fixnum) 2))
       (test-equal "-111111111111111111111111111"
                   (number->string (+ (least-fixnum) 1) 2)))

      ((32)
       (test-equal "2147483647"
                   (number->string (greatest-fixnum)))
       (test-equal "-2147483648"
                   (number->string (least-fixnum)))
       (test-equal "1111111111111111111111111111111"
                   (number->string (greatest-fixnum) 2))
       (test-equal "-10000000000000000000000000000000"
                   (number->string (least-fixnum) 2))
       (test-equal "-1111111111111111111111111111111"
                   (number->string (+ (least-fixnum) 1) 2)))

      ((60)
       (test-equal "576460752303423487"
                   (number->string (greatest-fixnum)))
       (test-equal "-576460752303423488"
                   (number->string (least-fixnum)))
       (test-equal "11111111111111111111111111111111111111111111111111111111111"
                   (number->string (greatest-fixnum) 2))
       (test-equal "-100000000000000000000000000000000000000000000000000000000000"
                   (number->string (least-fixnum) 2))
       (test-equal "-11111111111111111111111111111111111111111111111111111111111"
                   (number->string (+ (least-fixnum) 1) 2)))

      ((64)
       (test-equal "9223372036854775807"
                   (number->string (greatest-fixnum)))
       (test-equal "-9223372036854775808"
                   (number->string (least-fixnum)))
       (test-equal "111111111111111111111111111111111111111111111111111111111111111"
                   (number->string (greatest-fixnum) 2))
       (test-equal "-1000000000000000000000000000000000000000000000000000000000000000"
                   (number->string (least-fixnum) 2))
       (test-equal "-111111111111111111111111111111111111111111111111111111111111111"
                   (number->string (+ (least-fixnum) 1) 2)))

      (else
       (test-assert "unknown int bitwidth" #f))))
(test-end "number->string boundary numbers")


;;
;; string->number
;;

(test-begin "string->number invalid radix")
(test-error (string->number "0" -16))
(test-error (string->number "0" -10))
(test-error (string->number "0" -8))
(test-error (string->number "0" -2))
(test-error (string->number "0" -1))
(test-error (string->number "0" 0))
(test-error (string->number "0" 1))
(test-error (string->number "0" 3))
(test-error (string->number "0" 4))
(test-error (string->number "0" 7))
(test-error (string->number "0" 9))
(test-error (string->number "0" 11))
(test-error (string->number "0" 15))
(test-error (string->number "0" 17))
(test-end "string->number invalid radix")
(test-begin "string->number invalid forms")
(test-error (string->number))
(test-error (string->number 0))
(test-error (string->number 0 2))
(test-error (string->number "0" "2"))
(test-error (string->number "0" 2 #f))
(test-end "string->number invalid forms")
(test-begin "string->number invalid strings")
(test-eq #f  (string->number ""))
(test-eq #f  (string->number "a"))
(test-eq #f  (string->number "a" 10))
(test-eq #f  (string->number "g" 16))
(test-eq #f  (string->number "0xf" 16))
(test-eq #f  (string->number "8" 8))
(test-eq #f  (string->number "2" 2))
(test-eq #f  (string->number "- 9"))
(test-eq #f  (string->number "- 9" 10))
(test-eq #f  (string->number "- f" 16))
(test-eq #f  (string->number "- 0xf" 16))
(test-eq #f  (string->number "- 7" 8))
(test-eq #f  (string->number "- 1" 2))
(test-eq #f  (string->number "-a"))
(test-eq #f  (string->number "-a" 10))
(test-eq #f  (string->number "-g" 16))
(test-eq #f  (string->number "-0xf" 16))
(test-eq #f  (string->number "-8" 8))
(test-eq #f  (string->number "-2" 2))
(test-eq #f  (string->number "+a"))
(test-eq #f  (string->number "+a" 10))
(test-eq #f  (string->number "+g" 16))
(test-eq #f  (string->number "+0xf" 16))
(test-eq #f  (string->number "+8" 8))
(test-eq #f  (string->number "+2" 2))
(test-eq #f  (string->number " 1"))
(test-eq #f  (string->number " -1"))
(test-eq #f  (string->number " +1"))
(test-eq #f  (string->number " 01"))
(test-eq #f  (string->number "1 "))
(test-eq #f  (string->number "-"))
(test-eq #f  (string->number "+"))
(test-eq #f  (string->number "+-0"))
(test-eq #f  (string->number "-+0"))
(test-eq #f  (string->number "++0"))
(test-eq #f  (string->number "--0"))
(test-end "string->number invalid strings")
(test-begin "string->number implicit decimal")
(test-equal -100 (string->number "-100"))
(test-equal -10  (string->number "-10"))
(test-equal -1   (string->number "-1"))
(test-equal 0    (string->number "-0"))
(test-equal 0    (string->number  "0"))
(test-equal 0    (string->number "+0"))
(test-equal 1    (string->number  "1"))
(test-equal 1    (string->number "+1"))
(test-equal 10   (string->number  "10"))
(test-equal 10   (string->number "+10"))
(test-equal 100  (string->number  "100"))
(test-equal 100  (string->number "+100"))
(test-equal  238975 (string->number  "0238975"))
(test-equal  238975 (string->number   "238975"))
(test-equal  238975 (string->number  "+238975"))
(test-equal  238975 (string->number "+0238975"))
(test-equal -238975 (string->number  "-238975"))
(test-equal -238975 (string->number "-0238975"))
(test-end "string->number implicit decimal")
(if (>= fixnum-bits 60)
    (begin
      (test-begin "string->number implicit decimal 64-bit")
      (string-eval "(test-equal  956397711204 (string->number  \"0956397711204\"))")
      (string-eval "(test-equal  956397711204 (string->number   \"956397711204\"))")
      (string-eval "(test-equal  956397711204 (string->number  \"+956397711204\"))")
      (string-eval "(test-equal  956397711204 (string->number \"+0956397711204\"))")
      (string-eval "(test-equal -956397711204 (string->number  \"-956397711204\"))")
      (string-eval "(test-equal -956397711204 (string->number \"-0956397711204\"))")
      (test-end "string->number implicit decimal 64-bit")))
(test-begin "string->number explicit decimal")
(test-equal -100 (string->number "-100" 10))
(test-equal -10  (string->number "-10"  10))
(test-equal -1   (string->number "-1"   10))
(test-equal 0    (string->number "-0"   10))
(test-equal 0    (string->number  "0"   10))
(test-equal 0    (string->number "+0"   10))
(test-equal 1    (string->number  "1"   10))
(test-equal 1    (string->number "+1"   10))
(test-equal 10   (string->number  "10"  10))
(test-equal 10   (string->number "+10"  10))
(test-equal 100  (string->number  "100" 10))
(test-equal 100  (string->number "+100" 10))
(test-equal  238975 (string->number  "0238975" 10))
(test-equal  238975 (string->number   "238975" 10))
(test-equal  238975 (string->number  "+238975" 10))
(test-equal  238975 (string->number "+0238975" 10))
(test-equal -238975 (string->number  "-238975" 10))
(test-equal -238975 (string->number "-0238975" 10))
(test-end "string->number explicit decimal")
(if (>= fixnum-bits 60)
    (begin
      (test-begin "string->number explicit decimal 64-bit")
      (string-eval "(test-equal  956397711204 (string->number  \"0956397711204\" 10))")
      (string-eval "(test-equal  956397711204 (string->number   \"956397711204\" 10))")
      (string-eval "(test-equal  956397711204 (string->number  \"+956397711204\" 10))")
      (string-eval "(test-equal  956397711204 (string->number \"+0956397711204\" 10))")
      (string-eval "(test-equal -956397711204 (string->number  \"-956397711204\" 10))")
      (string-eval "(test-equal -956397711204 (string->number \"-0956397711204\" 10))")
      (test-end "string->number explicit decimal 64-bit")))
(test-begin "string->number hexadecimal")
(test-equal -256 (string->number "-100" 16))
(test-equal -16  (string->number "-10"  16))
(test-equal -1   (string->number "-1"   16))
(test-equal 0    (string->number "-0"   16))
(test-equal 0    (string->number  "0"   16))
(test-equal 0    (string->number "+0"   16))
(test-equal 1    (string->number  "1"   16))
(test-equal 1    (string->number "+1"   16))
(test-equal 16   (string->number  "10"  16))
(test-equal 16   (string->number "+10"  16))
(test-equal 256  (string->number  "100" 16))
(test-equal 256  (string->number "+100" 16))
(test-equal -10  (string->number "-a"   16))
(test-equal -10  (string->number "-A"   16))
(test-equal 10   (string->number  "a"   16))
(test-equal 10   (string->number "+a"   16))
(test-equal 10   (string->number  "A"   16))
(test-equal 10   (string->number "+A"   16))
(test-equal  14593330 (string->number  "0deAd32" 16))
(test-equal  14593330 (string->number   "deAd32" 16))
(test-equal  14593330 (string->number  "+dEad32" 16))
(test-equal  14593330 (string->number "+0dEad32" 16))
(test-equal -14593330 (string->number  "-deaD32" 16))
(test-equal -14593330 (string->number "-0deaD32" 16))
(test-equal   3333805 (string->number   "32deAd" 16))
(test-equal   3333805 (string->number  "+32dEad" 16))
(test-equal  -3333805 (string->number  "-32deaD" 16))
(test-end "string->number hexadecimal")
(if (>= fixnum-bits 60)
    (begin
      (test-begin "string->number hexadecimal 64-bit")
      (string-eval "(test-equal  956397711204 (string->number  \"0deAdbeef64\" 16))")
      (string-eval "(test-equal  956397711204 (string->number   \"deAdbeef64\" 16))")
      (string-eval "(test-equal  956397711204 (string->number  \"+dEadBeef64\" 16))")
      (string-eval "(test-equal  956397711204 (string->number \"+0dEadBeef64\" 16))")
      (string-eval "(test-equal -956397711204 (string->number  \"-dEadBeef64\" 16))")
      (string-eval "(test-equal -956397711204 (string->number \"-0deaDbeeF64\" 16))")
      (test-end "string->number hexadecimal 64-bit")))
(test-begin "string->number octal")
(test-equal -64 (string->number "-100" 8))
(test-equal -8  (string->number "-10"  8))
(test-equal -1  (string->number "-1"   8))
(test-equal 0   (string->number "-0"   8))
(test-equal 0   (string->number  "0"   8))
(test-equal 0   (string->number "+0"   8))
(test-equal 1   (string->number  "1"   8))
(test-equal 1   (string->number "+1"   8))
(test-equal 8   (string->number  "10"  8))
(test-equal 8   (string->number "+10"  8))
(test-equal 64  (string->number  "100" 8))
(test-equal 64  (string->number "+100" 8))
(test-equal  1556392 (string->number  "05737650" 8))
(test-equal  1556392 (string->number   "5737650" 8))
(test-equal +1556392 (string->number  "+5737650" 8))
(test-equal +1556392 (string->number "+05737650" 8))
(test-equal -1556392 (string->number  "-5737650" 8))
(test-equal -1556392 (string->number "-05737650" 8))
(test-end "string->number octal")
(if (>= fixnum-bits 60)
    (begin
      (test-begin "string->number octal 64-bit")
      (string-eval "(test-equal  956397711204 (string->number  \"015725557567544\" 8))")
      (string-eval "(test-equal  956397711204 (string->number   \"15725557567544\" 8))")
      (string-eval "(test-equal  956397711204 (string->number  \"+15725557567544\" 8))")
      (string-eval "(test-equal  956397711204 (string->number \"+015725557567544\" 8))")
      (string-eval "(test-equal -956397711204 (string->number  \"-15725557567544\" 8))")
      (string-eval "(test-equal -956397711204 (string->number \"-015725557567544\" 8))")
      (test-end "string->number octal 64-bit")))
(test-begin "string->number binary")
(test-equal -4  (string->number "-100" 2))
(test-equal -2  (string->number "-10"  2))
(test-equal -1  (string->number "-1"   2))
(test-equal 0   (string->number "-0"   2))
(test-equal 0   (string->number  "0"   2))
(test-equal 0   (string->number "+0"   2))
(test-equal 1   (string->number  "1"   2))
(test-equal 1   (string->number "+1"   2))
(test-equal 2   (string->number  "10"  2))
(test-equal 2   (string->number "+10"  2))
(test-equal 4   (string->number  "100" 2))
(test-equal 4   (string->number "+100" 2))
(test-equal  2990842 (string->number  "01011011010001011111010" 2))
(test-equal  2990842 (string->number   "1011011010001011111010" 2))
(test-equal +2990842 (string->number  "+1011011010001011111010" 2))
(test-equal +2990842 (string->number "+01011011010001011111010" 2))
(test-equal -2990842 (string->number  "-1011011010001011111010" 2))
(test-equal -2990842 (string->number "-01011011010001011111010" 2))
(test-end "string->number binary")
(if (>= fixnum-bits 60)
    (begin
      (test-begin "string->number binary 64-bit")
      (string-eval "(test-equal  956397711204 (string->number  \"01101111010101101101111101110111101100100\" 2))")
      (string-eval "(test-equal  956397711204 (string->number   \"1101111010101101101111101110111101100100\" 2))")
      (string-eval "(test-equal  956397711204 (string->number  \"+1101111010101101101111101110111101100100\" 2))")
      (string-eval "(test-equal  956397711204 (string->number \"+01101111010101101101111101110111101100100\" 2))")
      (string-eval "(test-equal -956397711204 (string->number  \"-1101111010101101101111101110111101100100\" 2))")
      (string-eval "(test-equal -956397711204 (string->number \"-01101111010101101101111101110111101100100\" 2))")
      (test-end "string->number binary 64-bit")))
(test-begin "string->number boundary numbers")
(case fixnum-bits
  ((28)
   (string-eval
    "(test-equal  134217727 (string->number  \"134217727\"))")
   (string-eval
    "(test-equal -134217728 (string->number \"-134217728\"))")
   (test-assert (not (string->number  "134217728")))
   (test-assert (not (string->number "-134217729"))))
  ((32)
   (string-eval
    "(test-equal  2147483647 (string->number  \"2147483647\"))")
   (string-eval
    "(test-equal -2147483648 (string->number \"-2147483648\"))")
   (test-assert (not (string->number   "2147483648")))
   (test-assert (not (string->number  "-2147483649"))))
  ((60)
   (string-eval
    "(test-equal 576460752303423487
                 (string->number \"576460752303423487\"))")
   (string-eval
    "(test-equal -576460752303423488
                 (string->number \"-576460752303423488\"))")
   (test-assert (not (string->number  "576460752303423488")))
   (test-assert (not (string->number "-576460752303423489"))))
  ((64)
   (string-eval
    "(test-equal 9223372036854775807
                 (string->number \"9223372036854775807\"))")
   (string-eval
    "(test-equal -9223372036854775808
                 (string->number \"-9223372036854775808\"))")
   (test-assert (not (string->number  "9223372036854775808")))
   (test-assert (not (string->number "-9223372036854775809"))))
  (else
   (test-assert "unknown int bitwidth" #f)))
(test-end "string->number boundary numbers")


(test-end "test-number-io")
