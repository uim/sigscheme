;;  Filename : test-formatplus.scm
;;  About    : unit test for SigScheme-specific procedure format+
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

(require-extension (srfi 48))

(if (not (symbol-bound? 'format+))
    (test-skip-file "format+ is not enabled"))

(if (not (provided? "r6rs-chars"))
    (test-skip-file "R6RS characters is not enabled"))

(test-begin "test-formatplus")

;; test SRFI-48 compatible part of format+
(define format format+)
(load "./test/test-srfi48.scm")

(test-begin "format+ ~d")
(test-error (format+ "0128d"    1))
(test-error (format+ "0128,1d"  1))
(test-error (format+ "1,0128d"  1))
(test-error (format+ "01024d"   1))
(test-error (format+ "01024,1d" 1))
(test-error (format+ "1,01024d" 1))
(test-equal "-100" (format+ "~0d" -100))
(test-equal "-10"  (format+ "~0d" -10))
(test-equal "-1"   (format+ "~0d" -1))
(test-equal "0"    (format+ "~0d" 0))
(test-equal "1"    (format+ "~0d" 1))
(test-equal "10"   (format+ "~0d" 10))
(test-equal "100"  (format+ "~0d" 100))

(test-equal "-100" (format+ "~03d" -100))
(test-equal "-10"  (format+ "~03d" -10))
(test-equal "-01"  (format+ "~03d" -1))
(test-equal "000"  (format+ "~03d" 0))
(test-equal "001"  (format+ "~03d" 1))
(test-equal "010"  (format+ "~03d" 10))
(test-equal "100"  (format+ "~03d" 100))

(test-equal "                                                                                                                            123"
            (format+ "~127d" 123))
(test-equal "0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000123"
            (format+ "~0127d" 123))
(test-end "format+ ~d")

(test-begin "format+ ~x")
(test-error (format+ "0128x"    1))
(test-error (format+ "0128,1x"  1))
(test-error (format+ "1,0128x"  1))
(test-error (format+ "01024x"   1))
(test-error (format+ "01024,1x" 1))
(test-error (format+ "1,01024x" 1))
(test-equal "-64"  (format+ "~0x" -100))
(test-equal "-a"   (format+ "~0x" -10))
(test-equal "-1"   (format+ "~0x" -1))
(test-equal "0"    (format+ "~0x" 0))
(test-equal "1"    (format+ "~0x" 1))
(test-equal "a"    (format+ "~0x" 10))
(test-equal "64"   (format+ "~0x" 100))

(test-equal "-64"  (format+ "~03x" -100))
(test-equal "-0a"  (format+ "~03x" -10))
(test-equal "-01"  (format+ "~03x" -1))
(test-equal "000"  (format+ "~03x" 0))
(test-equal "001"  (format+ "~03x" 1))
(test-equal "00a"  (format+ "~03x" 10))
(test-equal "064"  (format+ "~03x" 100))

(test-equal "                                                                                                                            1ac"
            (format+ "~127x" #x1ac))
(test-equal "00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001ac"
            (format+ "~0127x" #x1ac))
(test-end "format+ ~x")

(test-begin "format+ ~o")
(test-error (format+ "0128o"    1))
(test-error (format+ "0128,1o"  1))
(test-error (format+ "1,0128o"  1))
(test-error (format+ "01024o"   1))
(test-error (format+ "01024,1o" 1))
(test-error (format+ "1,01024o" 1))
(test-equal "-144" (format+ "~0o" -100))
(test-equal "-12"  (format+ "~0o" -10))
(test-equal "-1"   (format+ "~0o" -1))
(test-equal "0"    (format+ "~0o" 0))
(test-equal "1"    (format+ "~0o" 1))
(test-equal "12"   (format+ "~0o" 10))
(test-equal "144"  (format+ "~0o" 100))

(test-equal "-144" (format+ "~03o" -100))
(test-equal "-12"  (format+ "~03o" -10))
(test-equal "-01"  (format+ "~03o" -1))
(test-equal "000"  (format+ "~03o" 0))
(test-equal "001"  (format+ "~03o" 1))
(test-equal "012"  (format+ "~03o" 10))
(test-equal "144"  (format+ "~03o" 100))

(test-equal "                                                                                                                            123"
            (format+ "~127o" #o123))
(test-equal "0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000123"
            (format+ "~0127o" #o123))
(test-end "format+ ~o")

(test-begin "format+ ~b")
(test-error (format+ "0128b"    1))
(test-error (format+ "0128,1b"  1))
(test-error (format+ "1,0128b"  1))
(test-error (format+ "01024b"   1))
(test-error (format+ "01024,1b" 1))
(test-error (format+ "1,01024b" 1))
(test-equal "-1100100" (format+ "~0b" -100))
(test-equal "-1010"    (format+ "~0b" -10))
(test-equal "-1"       (format+ "~0b" -1))
(test-equal "0"        (format+ "~0b" 0))
(test-equal "1"        (format+ "~0b" 1))
(test-equal "1010"     (format+ "~0b" 10))
(test-equal "1100100"  (format+ "~0b" 100))

(test-equal "-1100100" (format+ "~05b" -100))
(test-equal "-1010"    (format+ "~05b" -10))
(test-equal "-0001"    (format+ "~05b" -1))
(test-equal "00000"    (format+ "~05b" 0))
(test-equal "00001"    (format+ "~05b" 1))
(test-equal "01010"    (format+ "~05b" 10))
(test-equal "1100100"  (format+ "~05b" 100))

(test-equal "                                                                                                                            101"
            (format+ "~127b" #b101))
(test-equal "0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000101"
            (format+ "~0127b" #b101))
(test-end "format+ ~b")

(test-begin "format+ ~f (number)")
(test-equal "-100" (format+ "~0f" -100))
(test-equal "-10"  (format+ "~0f" -10))
(test-equal "-1"   (format+ "~0f" -1))
(test-equal "0"    (format+ "~0f" 0))
(test-equal "1"    (format+ "~0f" 1))
(test-equal "10"   (format+ "~0f" 10))
(test-equal "100"  (format+ "~0f" 100))

(test-equal "-100" (format "~03f" -100))
(test-equal "-10"  (format "~03f" -10))
(test-equal "-01"  (format "~03f" -1))
(test-equal "000"  (format "~03f" 0))
(test-equal "001"  (format "~03f" 1))
(test-equal "010"  (format "~03f" 10))
(test-equal "100"  (format "~03f" 100))

;; Inexact numbers are supported only when "0.5" can be converted.
(if (string->number "0.5")
    (begin
      (test-equal "-100.00" (format+ "~06,02f" -100))
      (test-equal "-10.00"  (format+ "~06,02f" -10))
      (test-equal "-01.00"  (format+ "~06,02f" -1))
      (test-equal "000.00"  (format+ "~06,02f" 0))
      (test-equal "001.00"  (format+ "~06,02f" 1))
      (test-equal "010.00"  (format+ "~06,02f" 10))
      (test-equal "100.00"  (format+ "~06,02f" 100))))

(test-equal "0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000123"
            (format+ "~0127f" 123))
(test-end "format+ ~f (number)")

(test-begin "format ~h")
(define help-str
"(format+ [<port>] <format-string> [<arg>...])
  - <port> is #t, #f or an output-port
  - any escape sequence is case insensitive

  The format+ procedure is a SigScheme-specific superset of SRFI-48.
  Following directives accept optional width w and d digits after the decimal,
  and w accepts leading zero as zero-digit-padding specifier. All other rules
  are same as SRFI-48. See also the help message for SRFI-48.

SEQ        MNEMONIC       DESCRIPTION
~[w[,d]]D  [Decimal]      the arg is a number output in decimal radix
~[w[,d]]X  [heXadecimal]  the arg is a number output in hexdecimal radix
~[w[,d]]O  [Octal]        the arg is a number output in octal radix
~[w[,d]]B  [Binary]       the arg is a number output in binary radix
~[w[,d]]F  [Fixed]        the arg is a string or number
")
(test-equal help-str (format "~h"))
(test-equal help-str (format "~H"))
(test-end "format ~h")

(test-end "test-formatplus")
