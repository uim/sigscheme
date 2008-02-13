#! /usr/bin/env sscm -C UTF-8

;;  Filename : test-char-pred.scm
;;  About    : unit test for R5RS char classification predicates
;;
;;  Copyright (c) 2007-2008 SigScheme Project <uim-en AT googlegroups.com>
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

(require-extension (unittest))

(if (not (symbol-bound? 'char-alphabetic?))
    (test-skip "R5RS characters is not enabled"))

(define tn test-name)

(tn "char-alphabetic?")
(assert-false  (tn) (char-alphabetic? #\x00))
(assert-false  (tn) (char-alphabetic? #\newline))
(assert-false  (tn) (char-alphabetic? #\space))
(assert-false  (tn) (char-alphabetic? #\x09)) ;; horizontal tab  (#\tab)
(assert-false  (tn) (char-alphabetic? #\x0b)) ;; vertical tab    (#\vtab)
(assert-false  (tn) (char-alphabetic? #\x0c)) ;; form feed       (#\page)
(assert-false  (tn) (char-alphabetic? #\x0d)) ;; carriage return (#\return)
(assert-false  (tn) (char-alphabetic? #\!))
(assert-false  (tn) (char-alphabetic? #\0))
(assert-false  (tn) (char-alphabetic? #\9))
(assert-true   (tn) (char-alphabetic? #\A))
(assert-true   (tn) (char-alphabetic? #\B))
(assert-true   (tn) (char-alphabetic? #\Z))
(assert-false  (tn) (char-alphabetic? #\_))
(assert-true   (tn) (char-alphabetic? #\a))
(assert-true   (tn) (char-alphabetic? #\b))
(assert-true   (tn) (char-alphabetic? #\z))
(assert-false  (tn) (char-alphabetic? #\~))
(assert-false  (tn) (char-alphabetic? #\x7f))
(tn "char-alphabetic? non-ASCII")
;; SigScheme currently does not support non-ASCII charcter classification
(assert-false  (tn) (char-alphabetic? #\xa0))   ;; U+00A0 NO-BREAK SPACE
(assert-false  (tn) (char-alphabetic? #\xff))   ;; U+00FF LATIN SMALL LETTER Y WITH DIAERESIS
(assert-false  (tn) (char-alphabetic? #\x2028)) ;; U+2028 LINE SEPARATOR
(assert-false  (tn) (char-alphabetic? #\x2029)) ;; U+2029 PARAGRAPH SEPARATOR
(assert-false  (tn) (char-alphabetic? #\　))    ;; U+3000 IDEOGRAPHIC SPACE
(assert-false  (tn) (char-alphabetic? #\あ))    ;; U+3042 HIRAGANA LETTER A
(assert-false  (tn) (char-alphabetic? #\！))    ;; U+FF01 FULLWIDTH EXCLAMATION MARK
(assert-false  (tn) (char-alphabetic? #\０))    ;; U+FF10 FULLWIDTH DIGIT ZERO
(assert-false  (tn) (char-alphabetic? #\Ａ))    ;; U+FF21 FULLWIDTH LATIN CAPITAL LETTER A
(assert-false  (tn) (char-alphabetic? #\ａ))    ;; U+FF41 FULLWIDTH LATIN SMALL LETTER A

(tn "char-numeric?")
(assert-false  (tn) (char-numeric? #\x00))
(assert-false  (tn) (char-numeric? #\newline))
(assert-false  (tn) (char-numeric? #\space))
(assert-false  (tn) (char-numeric? #\x09)) ;; horizontal tab  (#\tab)
(assert-false  (tn) (char-numeric? #\x0b)) ;; vertical tab    (#\vtab)
(assert-false  (tn) (char-numeric? #\x0c)) ;; form feed       (#\page)
(assert-false  (tn) (char-numeric? #\x0d)) ;; carriage return (#\return)
(assert-false  (tn) (char-numeric? #\!))
(assert-true   (tn) (char-numeric? #\0))
(assert-true   (tn) (char-numeric? #\9))
(assert-false  (tn) (char-numeric? #\A))
(assert-false  (tn) (char-numeric? #\B))
(assert-false  (tn) (char-numeric? #\Z))
(assert-false  (tn) (char-numeric? #\_))
(assert-false  (tn) (char-numeric? #\a))
(assert-false  (tn) (char-numeric? #\b))
(assert-false  (tn) (char-numeric? #\z))
(assert-false  (tn) (char-numeric? #\~))
(assert-false  (tn) (char-numeric? #\x7f))
(tn "char-numeric? non-ASCII")
;; SigScheme currently does not support non-ASCII charcter classification
(assert-false  (tn) (char-numeric? #\xa0))   ;; U+00A0 NO-BREAK SPACE
(assert-false  (tn) (char-numeric? #\xff))   ;; U+00FF LATIN SMALL LETTER Y WITH DIAERESIS
(assert-false  (tn) (char-numeric? #\x2028)) ;; U+2028 LINE SEPARATOR
(assert-false  (tn) (char-numeric? #\x2029)) ;; U+2029 PARAGRAPH SEPARATOR
(assert-false  (tn) (char-numeric? #\　))    ;; U+3000 IDEOGRAPHIC SPACE
(assert-false  (tn) (char-numeric? #\あ))    ;; U+3042 HIRAGANA LETTER A
(assert-false  (tn) (char-numeric? #\！))    ;; U+FF01 FULLWIDTH EXCLAMATION MARK
(assert-false  (tn) (char-numeric? #\０))    ;; U+FF10 FULLWIDTH DIGIT ZERO
(assert-false  (tn) (char-numeric? #\Ａ))    ;; U+FF21 FULLWIDTH LATIN CAPITAL LETTER A
(assert-false  (tn) (char-numeric? #\ａ))    ;; U+FF41 FULLWIDTH LATIN SMALL LETTER A

(tn "char-whitespace?")
(assert-false  (tn) (char-whitespace? #\x00))
(assert-true   (tn) (char-whitespace? #\newline))
(assert-true   (tn) (char-whitespace? #\space))
(assert-true   (tn) (char-whitespace? #\x09)) ;; horizontal tab  (#\tab)
(assert-true   (tn) (char-whitespace? #\x0b)) ;; vertical tab    (#\vtab)
(assert-true   (tn) (char-whitespace? #\x0c)) ;; form feed       (#\page)
(assert-true   (tn) (char-whitespace? #\x0d)) ;; carriage return (#\return)
(assert-false  (tn) (char-whitespace? #\!))
(assert-false  (tn) (char-whitespace? #\0))
(assert-false  (tn) (char-whitespace? #\9))
(assert-false  (tn) (char-whitespace? #\A))
(assert-false  (tn) (char-whitespace? #\B))
(assert-false  (tn) (char-whitespace? #\Z))
(assert-false  (tn) (char-whitespace? #\_))
(assert-false  (tn) (char-whitespace? #\a))
(assert-false  (tn) (char-whitespace? #\b))
(assert-false  (tn) (char-whitespace? #\z))
(assert-false  (tn) (char-whitespace? #\~))
(assert-false  (tn) (char-whitespace? #\x7f))
(tn "char-whitespace? non-ASCII")
;; SigScheme currently does not support non-ASCII charcter classification
(assert-false  (tn) (char-whitespace? #\xa0))   ;; U+00A0 NO-BREAK SPACE
(assert-false  (tn) (char-whitespace? #\xff))   ;; U+00FF LATIN SMALL LETTER Y WITH DIAERESIS
(assert-false  (tn) (char-whitespace? #\x2028)) ;; U+2028 LINE SEPARATOR
(assert-false  (tn) (char-whitespace? #\x2029)) ;; U+2029 PARAGRAPH SEPARATOR
(assert-false  (tn) (char-whitespace? #\　))    ;; U+3000 IDEOGRAPHIC SPACE
(assert-false  (tn) (char-whitespace? #\あ))    ;; U+3042 HIRAGANA LETTER A
(assert-false  (tn) (char-whitespace? #\！))    ;; U+FF01 FULLWIDTH EXCLAMATION MARK
(assert-false  (tn) (char-whitespace? #\０))    ;; U+FF10 FULLWIDTH DIGIT ZERO
(assert-false  (tn) (char-whitespace? #\Ａ))    ;; U+FF21 FULLWIDTH LATIN CAPITAL LETTER A
(assert-false  (tn) (char-whitespace? #\ａ))    ;; U+FF41 FULLWIDTH LATIN SMALL LETTER A

(tn "char-upper-case?")
(assert-false  (tn) (char-upper-case? #\x00))
(assert-false  (tn) (char-upper-case? #\newline))
(assert-false  (tn) (char-upper-case? #\space))
(assert-false  (tn) (char-upper-case? #\x09)) ;; horizontal tab  (#\tab)
(assert-false  (tn) (char-upper-case? #\x0b)) ;; vertical tab    (#\vtab)
(assert-false  (tn) (char-upper-case? #\x0c)) ;; form feed       (#\page)
(assert-false  (tn) (char-upper-case? #\x0d)) ;; carriage return (#\return)
(assert-false  (tn) (char-upper-case? #\!))
(assert-false  (tn) (char-upper-case? #\0))
(assert-false  (tn) (char-upper-case? #\9))
(assert-true   (tn) (char-upper-case? #\A))
(assert-true   (tn) (char-upper-case? #\B))
(assert-true   (tn) (char-upper-case? #\Z))
(assert-false  (tn) (char-upper-case? #\_))
(assert-false  (tn) (char-upper-case? #\a))
(assert-false  (tn) (char-upper-case? #\b))
(assert-false  (tn) (char-upper-case? #\z))
(assert-false  (tn) (char-upper-case? #\~))
(assert-false  (tn) (char-upper-case? #\x7f))
(tn "char-upper-case? non-ASCII")
;; SigScheme currently does not support non-ASCII charcter classification
(assert-false  (tn) (char-upper-case? #\xa0))   ;; U+00A0 NO-BREAK SPACE
(assert-false  (tn) (char-upper-case? #\xff))   ;; U+00FF LATIN SMALL LETTER Y WITH DIAERESIS
(assert-false  (tn) (char-upper-case? #\x2028)) ;; U+2028 LINE SEPARATOR
(assert-false  (tn) (char-upper-case? #\x2029)) ;; U+2029 PARAGRAPH SEPARATOR
(assert-false  (tn) (char-upper-case? #\　))    ;; U+3000 IDEOGRAPHIC SPACE
(assert-false  (tn) (char-upper-case? #\あ))    ;; U+3042 HIRAGANA LETTER A
(assert-false  (tn) (char-upper-case? #\！))    ;; U+FF01 FULLWIDTH EXCLAMATION MARK
(assert-false  (tn) (char-upper-case? #\０))    ;; U+FF10 FULLWIDTH DIGIT ZERO
(assert-false  (tn) (char-upper-case? #\Ａ))    ;; U+FF21 FULLWIDTH LATIN CAPITAL LETTER A
(assert-false  (tn) (char-upper-case? #\ａ))    ;; U+FF41 FULLWIDTH LATIN SMALL LETTER A

(tn "char-lower-case?")
(assert-false  (tn) (char-lower-case? #\x00))
(assert-false  (tn) (char-lower-case? #\newline))
(assert-false  (tn) (char-lower-case? #\space))
(assert-false  (tn) (char-lower-case? #\x09)) ;; horizontal tab  (#\tab)
(assert-false  (tn) (char-lower-case? #\x0b)) ;; vertical tab    (#\vtab)
(assert-false  (tn) (char-lower-case? #\x0c)) ;; form feed       (#\page)
(assert-false  (tn) (char-lower-case? #\x0d)) ;; carriage return (#\return)
(assert-false  (tn) (char-lower-case? #\!))
(assert-false  (tn) (char-lower-case? #\0))
(assert-false  (tn) (char-lower-case? #\9))
(assert-false  (tn) (char-lower-case? #\A))
(assert-false  (tn) (char-lower-case? #\B))
(assert-false  (tn) (char-lower-case? #\Z))
(assert-false  (tn) (char-lower-case? #\_))
(assert-true   (tn) (char-lower-case? #\a))
(assert-true   (tn) (char-lower-case? #\b))
(assert-true   (tn) (char-lower-case? #\z))
(assert-false  (tn) (char-lower-case? #\~))
(assert-false  (tn) (char-lower-case? #\x7f))
(tn "char-lower-case? non-ASCII")
;; SigScheme currently does not support non-ASCII charcter classification
(assert-false  (tn) (char-lower-case? #\xa0))   ;; U+00A0 NO-BREAK SPACE
(assert-false  (tn) (char-lower-case? #\xff))   ;; U+00FF LATIN SMALL LETTER Y WITH DIAERESIS
(assert-false  (tn) (char-lower-case? #\x2028)) ;; U+2028 LINE SEPARATOR
(assert-false  (tn) (char-lower-case? #\x2029)) ;; U+2029 PARAGRAPH SEPARATOR
(assert-false  (tn) (char-lower-case? #\　))    ;; U+3000 IDEOGRAPHIC SPACE
(assert-false  (tn) (char-lower-case? #\あ))    ;; U+3042 HIRAGANA LETTER A
(assert-false  (tn) (char-lower-case? #\！))    ;; U+FF01 FULLWIDTH EXCLAMATION MARK
(assert-false  (tn) (char-lower-case? #\０))    ;; U+FF10 FULLWIDTH DIGIT ZERO
(assert-false  (tn) (char-lower-case? #\Ａ))    ;; U+FF21 FULLWIDTH LATIN CAPITAL LETTER A
(assert-false  (tn) (char-lower-case? #\ａ))    ;; U+FF41 FULLWIDTH LATIN SMALL LETTER A


(total-report)
