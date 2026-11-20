#! /usr/bin/env sscm -C UTF-8

;;  Filename : test-char-pred.scm
;;  About    : unit test for R5RS char classification predicates
;;
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

(if (not (symbol-bound? 'char-alphabetic?))
    (test-skip-file "R5RS characters is not enabled"))

(if (not (provided? "r6rs-chars"))
    (test-skip-file "R6RS characters is not enabled"))

(test-begin "test-char-pred")
(define unicode? (provided? "full-unicode"))

(test-begin "char-alphabetic?")
(test-assert (not (char-alphabetic? #\x00)))
(test-assert (not (char-alphabetic? #\newline)))
(test-assert (not (char-alphabetic? #\space)))
(test-assert (not (char-alphabetic? #\x09))) ;; horizontal tab  (#\tab)
(test-assert (not (char-alphabetic? #\x0b))) ;; vertical tab    (#\vtab)
(test-assert (not (char-alphabetic? #\x0c))) ;; form feed       (#\page)
(test-assert (not (char-alphabetic? #\x0d))) ;; carriage return (#\return)
(test-assert (not (char-alphabetic? #\!)))
(test-assert (not (char-alphabetic? #\0)))
(test-assert (not (char-alphabetic? #\9)))
(test-assert (char-alphabetic? #\A))
(test-assert (char-alphabetic? #\B))
(test-assert (char-alphabetic? #\Z))
(test-assert (not (char-alphabetic? #\_)))
(test-assert (char-alphabetic? #\a))
(test-assert (char-alphabetic? #\b))
(test-assert (char-alphabetic? #\z))
(test-assert (not (char-alphabetic? #\~)))
(test-assert (not (char-alphabetic? #\x7f)))
(test-end "char-alphabetic?")
(test-begin "char-alphabetic? non-ASCII")
;; Non-ASCII characters are classified only with Unicode support.
(test-assert (not (char-alphabetic? #\xa0)))   ;; U+00A0 NO-BREAK SPACE
(test-equal unicode? (char-alphabetic? #\xff))   ;; U+00FF LATIN SMALL LETTER Y WITH DIAERESIS
(test-assert (not (char-alphabetic? #\x2028))) ;; U+2028 LINE SEPARATOR
(test-assert (not (char-alphabetic? #\x2029))) ;; U+2029 PARAGRAPH SEPARATOR
(test-assert (not (char-alphabetic? #\　)))    ;; U+3000 IDEOGRAPHIC SPACE
(test-equal unicode? (char-alphabetic? #\あ))    ;; U+3042 HIRAGANA LETTER A
(test-assert (not (char-alphabetic? #\！)))    ;; U+FF01 FULLWIDTH EXCLAMATION MARK
(test-assert (not (char-alphabetic? #\０)))    ;; U+FF10 FULLWIDTH DIGIT ZERO
(test-equal unicode? (char-alphabetic? #\Ａ))    ;; U+FF21 FULLWIDTH LATIN CAPITAL LETTER A
(test-equal unicode? (char-alphabetic? #\ａ))    ;; U+FF41 FULLWIDTH LATIN SMALL LETTER A
(test-end "char-alphabetic? non-ASCII")

(test-begin "char-numeric?")
(test-assert (not (char-numeric? #\x00)))
(test-assert (not (char-numeric? #\newline)))
(test-assert (not (char-numeric? #\space)))
(test-assert (not (char-numeric? #\x09))) ;; horizontal tab  (#\tab)
(test-assert (not (char-numeric? #\x0b))) ;; vertical tab    (#\vtab)
(test-assert (not (char-numeric? #\x0c))) ;; form feed       (#\page)
(test-assert (not (char-numeric? #\x0d))) ;; carriage return (#\return)
(test-assert (not (char-numeric? #\!)))
(test-assert (char-numeric? #\0))
(test-assert (char-numeric? #\9))
(test-assert (not (char-numeric? #\A)))
(test-assert (not (char-numeric? #\B)))
(test-assert (not (char-numeric? #\Z)))
(test-assert (not (char-numeric? #\_)))
(test-assert (not (char-numeric? #\a)))
(test-assert (not (char-numeric? #\b)))
(test-assert (not (char-numeric? #\z)))
(test-assert (not (char-numeric? #\~)))
(test-assert (not (char-numeric? #\x7f)))
(test-end "char-numeric?")
(test-begin "char-numeric? non-ASCII")
;; Non-ASCII characters are classified only with Unicode support.
(test-assert (not (char-numeric? #\xa0)))   ;; U+00A0 NO-BREAK SPACE
(test-assert (not (char-numeric? #\xff)))   ;; U+00FF LATIN SMALL LETTER Y WITH DIAERESIS
(test-assert (not (char-numeric? #\x2028))) ;; U+2028 LINE SEPARATOR
(test-assert (not (char-numeric? #\x2029))) ;; U+2029 PARAGRAPH SEPARATOR
(test-assert (not (char-numeric? #\　)))    ;; U+3000 IDEOGRAPHIC SPACE
(test-assert (not (char-numeric? #\あ)))    ;; U+3042 HIRAGANA LETTER A
(test-assert (not (char-numeric? #\！)))    ;; U+FF01 FULLWIDTH EXCLAMATION MARK
(test-equal unicode? (char-numeric? #\０))    ;; U+FF10 FULLWIDTH DIGIT ZERO
(test-assert (not (char-numeric? #\Ａ)))    ;; U+FF21 FULLWIDTH LATIN CAPITAL LETTER A
(test-assert (not (char-numeric? #\ａ)))    ;; U+FF41 FULLWIDTH LATIN SMALL LETTER A
(test-end "char-numeric? non-ASCII")

(test-begin "char-whitespace?")
(test-assert (not (char-whitespace? #\x00)))
(test-assert (char-whitespace? #\newline))
(test-assert (char-whitespace? #\space))
(test-assert (char-whitespace? #\x09)) ;; horizontal tab  (#\tab)
(test-assert (char-whitespace? #\x0b)) ;; vertical tab    (#\vtab)
(test-assert (char-whitespace? #\x0c)) ;; form feed       (#\page)
(test-assert (char-whitespace? #\x0d)) ;; carriage return (#\return)
(test-assert (not (char-whitespace? #\!)))
(test-assert (not (char-whitespace? #\0)))
(test-assert (not (char-whitespace? #\9)))
(test-assert (not (char-whitespace? #\A)))
(test-assert (not (char-whitespace? #\B)))
(test-assert (not (char-whitespace? #\Z)))
(test-assert (not (char-whitespace? #\_)))
(test-assert (not (char-whitespace? #\a)))
(test-assert (not (char-whitespace? #\b)))
(test-assert (not (char-whitespace? #\z)))
(test-assert (not (char-whitespace? #\~)))
(test-assert (not (char-whitespace? #\x7f)))
(test-end "char-whitespace?")
(test-begin "char-whitespace? non-ASCII")
;; Non-ASCII characters are classified only with Unicode support.
(test-equal unicode? (char-whitespace? #\xa0))   ;; U+00A0 NO-BREAK SPACE
(test-assert (not (char-whitespace? #\xff)))   ;; U+00FF LATIN SMALL LETTER Y WITH DIAERESIS
(test-equal unicode? (char-whitespace? #\x2028)) ;; U+2028 LINE SEPARATOR
(test-equal unicode? (char-whitespace? #\x2029)) ;; U+2029 PARAGRAPH SEPARATOR
(test-equal unicode? (char-whitespace? #\　))    ;; U+3000 IDEOGRAPHIC SPACE
(test-assert (not (char-whitespace? #\あ)))    ;; U+3042 HIRAGANA LETTER A
(test-assert (not (char-whitespace? #\！)))    ;; U+FF01 FULLWIDTH EXCLAMATION MARK
(test-assert (not (char-whitespace? #\０)))    ;; U+FF10 FULLWIDTH DIGIT ZERO
(test-assert (not (char-whitespace? #\Ａ)))    ;; U+FF21 FULLWIDTH LATIN CAPITAL LETTER A
(test-assert (not (char-whitespace? #\ａ)))    ;; U+FF41 FULLWIDTH LATIN SMALL LETTER A
(test-end "char-whitespace? non-ASCII")

(test-begin "char-upper-case?")
(test-assert (not (char-upper-case? #\x00)))
(test-assert (not (char-upper-case? #\newline)))
(test-assert (not (char-upper-case? #\space)))
(test-assert (not (char-upper-case? #\x09))) ;; horizontal tab  (#\tab)
(test-assert (not (char-upper-case? #\x0b))) ;; vertical tab    (#\vtab)
(test-assert (not (char-upper-case? #\x0c))) ;; form feed       (#\page)
(test-assert (not (char-upper-case? #\x0d))) ;; carriage return (#\return)
(test-assert (not (char-upper-case? #\!)))
(test-assert (not (char-upper-case? #\0)))
(test-assert (not (char-upper-case? #\9)))
(test-assert (char-upper-case? #\A))
(test-assert (char-upper-case? #\B))
(test-assert (char-upper-case? #\Z))
(test-assert (not (char-upper-case? #\_)))
(test-assert (not (char-upper-case? #\a)))
(test-assert (not (char-upper-case? #\b)))
(test-assert (not (char-upper-case? #\z)))
(test-assert (not (char-upper-case? #\~)))
(test-assert (not (char-upper-case? #\x7f)))
(test-end "char-upper-case?")
(test-begin "char-upper-case? non-ASCII")
;; Non-ASCII characters are classified only with Unicode support.
(test-assert (not (char-upper-case? #\xa0)))   ;; U+00A0 NO-BREAK SPACE
(test-assert (not (char-upper-case? #\xff)))   ;; U+00FF LATIN SMALL LETTER Y WITH DIAERESIS
(test-assert (not (char-upper-case? #\x2028))) ;; U+2028 LINE SEPARATOR
(test-assert (not (char-upper-case? #\x2029))) ;; U+2029 PARAGRAPH SEPARATOR
(test-assert (not (char-upper-case? #\　)))    ;; U+3000 IDEOGRAPHIC SPACE
(test-assert (not (char-upper-case? #\あ)))    ;; U+3042 HIRAGANA LETTER A
(test-assert (not (char-upper-case? #\！)))    ;; U+FF01 FULLWIDTH EXCLAMATION MARK
(test-assert (not (char-upper-case? #\０)))    ;; U+FF10 FULLWIDTH DIGIT ZERO
(test-equal unicode? (char-upper-case? #\Ａ))    ;; U+FF21 FULLWIDTH LATIN CAPITAL LETTER A
(test-assert (not (char-upper-case? #\ａ)))    ;; U+FF41 FULLWIDTH LATIN SMALL LETTER A
(test-end "char-upper-case? non-ASCII")

(test-begin "char-lower-case?")
(test-assert (not (char-lower-case? #\x00)))
(test-assert (not (char-lower-case? #\newline)))
(test-assert (not (char-lower-case? #\space)))
(test-assert (not (char-lower-case? #\x09))) ;; horizontal tab  (#\tab)
(test-assert (not (char-lower-case? #\x0b))) ;; vertical tab    (#\vtab)
(test-assert (not (char-lower-case? #\x0c))) ;; form feed       (#\page)
(test-assert (not (char-lower-case? #\x0d))) ;; carriage return (#\return)
(test-assert (not (char-lower-case? #\!)))
(test-assert (not (char-lower-case? #\0)))
(test-assert (not (char-lower-case? #\9)))
(test-assert (not (char-lower-case? #\A)))
(test-assert (not (char-lower-case? #\B)))
(test-assert (not (char-lower-case? #\Z)))
(test-assert (not (char-lower-case? #\_)))
(test-assert (char-lower-case? #\a))
(test-assert (char-lower-case? #\b))
(test-assert (char-lower-case? #\z))
(test-assert (not (char-lower-case? #\~)))
(test-assert (not (char-lower-case? #\x7f)))
(test-end "char-lower-case?")
(test-begin "char-lower-case? non-ASCII")
;; Non-ASCII characters are classified only with Unicode support.
(test-assert (not (char-lower-case? #\xa0)))   ;; U+00A0 NO-BREAK SPACE
(test-equal unicode? (char-lower-case? #\xff))   ;; U+00FF LATIN SMALL LETTER Y WITH DIAERESIS
(test-assert (not (char-lower-case? #\x2028))) ;; U+2028 LINE SEPARATOR
(test-assert (not (char-lower-case? #\x2029))) ;; U+2029 PARAGRAPH SEPARATOR
(test-assert (not (char-lower-case? #\　)))    ;; U+3000 IDEOGRAPHIC SPACE
(test-assert (not (char-lower-case? #\あ)))    ;; U+3042 HIRAGANA LETTER A
(test-assert (not (char-lower-case? #\！)))    ;; U+FF01 FULLWIDTH EXCLAMATION MARK
(test-assert (not (char-lower-case? #\０)))    ;; U+FF10 FULLWIDTH DIGIT ZERO
(test-assert (not (char-lower-case? #\Ａ)))    ;; U+FF21 FULLWIDTH LATIN CAPITAL LETTER A
(test-equal unicode? (char-lower-case? #\ａ))    ;; U+FF41 FULLWIDTH LATIN SMALL LETTER A
(test-end "char-lower-case? non-ASCII")


(test-end "test-char-pred")
