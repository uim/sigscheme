#! /usr/bin/env sscm -C UTF-8

;;  Filename : test-char.scm
;;  About    : unit test for R5RS char
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

(if (not (symbol-bound? 'char?))
    (test-skip-file "R5RS characters is not enabled"))

(test-begin "test-char")
(define unicode? (provided? "full-unicode"))

(define i->chlit
  (lambda (i)
    (obj->literal (integer->char i))))

(test-begin "char?")
(test-eq #f (char? #f))
(test-eq #f (char? #t))
(test-eq #f (char? '()))
(if (provided? "sigscheme")
    (begin
      (test-eq #f (char? (eof)))
      (test-eq #f (char? (undef)))))
(test-eq #f (char? 0))
(test-eq #f (char? 1))
(test-eq #f (char? 3))
(test-eq #f (char? -1))
(test-eq #f (char? -3))
(test-eq #f (char? 'symbol))
(test-eq #f (char? 'SYMBOL))
(test-eq #t (char? #\a))
(test-eq #t (char? #\ÿ))
(test-eq #t (char? #\あ))
(test-eq #f (char? ""))
(test-eq #f (char? " "))
(test-eq #f (char? "a"))
(test-eq #f (char? "A"))
(test-eq #f (char? "aBc12!"))
(test-eq #f (char? "あ"))
(test-eq #f (char? "あ0イう12!"))
(test-eq #f (char? +))
(test-eq #f (char? (lambda () #t)))

;; syntactic keywords should not be appeared as operand
(if sigscheme?
    (begin
      ;; pure syntactic keyword
      (test-error (char? else))
      ;; expression keyword
      (test-error (char? do))))

(call-with-current-continuation
 (lambda (k)
   (test-eq #f (char? k))))
(test-eq #f (char? (current-output-port)))
(test-eq #f (char? '(#t . #t)))
(test-eq #f (char? (cons #t #t)))
(test-eq #f (char? '(0 1 2)))
(test-eq #f (char? (list 0 1 2)))
(test-eq #f (char? '#()))
(test-eq #f (char? (vector)))
(test-eq #f (char? '#(0 1 2)))
(test-eq #f (char? (vector 0 1 2)))
(test-end "char?")

(test-begin "char-upcase")
(test-equal #\x00     (char-upcase #\x00))
(test-equal #\newline (char-upcase #\newline))
(test-equal #\space   (char-upcase #\space))
(test-equal #\x09     (char-upcase #\x09)) ;; horizontal tab  (#\tab)
(test-equal #\x0b     (char-upcase #\x0b)) ;; vertical tab    (#\vtab)
(test-equal #\x0c     (char-upcase #\x0c)) ;; form feed       (#\page)
(test-equal #\x0d     (char-upcase #\x0d)) ;; carriage return (#\return)
(test-equal #\!       (char-upcase #\!))
(test-equal #\0       (char-upcase #\0))
(test-equal #\9       (char-upcase #\9))
(test-equal #\A       (char-upcase #\A))
(test-equal #\B       (char-upcase #\B))
(test-equal #\Z       (char-upcase #\Z))
(test-equal #\_       (char-upcase #\_))
(test-equal #\A       (char-upcase #\a))
(test-equal #\B       (char-upcase #\b))
(test-equal #\Z       (char-upcase #\z))
(test-equal #\~       (char-upcase #\~))
(test-equal #\x7f     (char-upcase #\x7f))
(test-end "char-upcase")
(test-begin "char-upcase non-ASCII")
;; Non-ASCII characters are converted only with Unicode support.
(test-equal #\xa0   (char-upcase #\xa0))   ;; U+00A0 NO-BREAK SPACE
(test-equal (if unicode? #\x178 #\xff) (char-upcase #\xff))   ;; U+00FF LATIN SMALL LETTER Y WITH DIAERESIS
(test-equal #\x2028 (char-upcase #\x2028)) ;; U+2028 LINE SEPARATOR
(test-equal #\x2029 (char-upcase #\x2029)) ;; U+2029 PARAGRAPH SEPARATOR
(test-equal #\　    (char-upcase #\　))    ;; U+3000 IDEOGRAPHIC SPACE
(test-equal #\あ    (char-upcase #\あ))    ;; U+3042 HIRAGANA LETTER A
(test-equal #\！    (char-upcase #\！))    ;; U+FF01 FULLWIDTH EXCLAMATION MARK
(test-equal #\０    (char-upcase #\０))    ;; U+FF10 FULLWIDTH DIGIT ZERO
(test-equal #\Ａ    (char-upcase #\Ａ))    ;; U+FF21 FULLWIDTH LATIN CAPITAL LETTER A
(test-equal (if unicode? #\Ａ #\ａ) (char-upcase #\ａ))    ;; U+FF41 FULLWIDTH LATIN SMALL LETTER A
(test-end "char-upcase non-ASCII")

(test-begin "char-downcase")
(test-equal #\x00     (char-downcase #\x00))
(test-equal #\newline (char-downcase #\newline))
(test-equal #\space   (char-downcase #\space))
(test-equal #\x09     (char-downcase #\x09)) ;; horizontal tab  (#\tab)
(test-equal #\x0b     (char-downcase #\x0b)) ;; vertical tab    (#\vtab)
(test-equal #\x0c     (char-downcase #\x0c)) ;; form feed       (#\page)
(test-equal #\x0d     (char-downcase #\x0d)) ;; carriage return (#\return)
(test-equal #\!       (char-downcase #\!))
(test-equal #\0       (char-downcase #\0))
(test-equal #\9       (char-downcase #\9))
(test-equal #\a       (char-downcase #\A))
(test-equal #\b       (char-downcase #\B))
(test-equal #\z       (char-downcase #\Z))
(test-equal #\_       (char-downcase #\_))
(test-equal #\a       (char-downcase #\a))
(test-equal #\b       (char-downcase #\b))
(test-equal #\z       (char-downcase #\z))
(test-equal #\~       (char-downcase #\~))
(test-equal #\x7f     (char-downcase #\x7f))
(test-end "char-downcase")
(test-begin "char-downcase non-ASCII")
;; Non-ASCII characters are converted only with Unicode support.
(test-equal #\xa0   (char-downcase #\xa0))   ;; U+00A0 NO-BREAK SPACE
(test-equal #\xff   (char-downcase #\xff))   ;; U+00FF LATIN SMALL LETTER Y WITH DIAERESIS
(test-equal #\x2028 (char-downcase #\x2028)) ;; U+2028 LINE SEPARATOR
(test-equal #\x2029 (char-downcase #\x2029)) ;; U+2029 PARAGRAPH SEPARATOR
(test-equal #\　    (char-downcase #\　))    ;; U+3000 IDEOGRAPHIC SPACE
(test-equal #\あ    (char-downcase #\あ))    ;; U+3042 HIRAGANA LETTER A
(test-equal #\！    (char-downcase #\！))    ;; U+FF01 FULLWIDTH EXCLAMATION MARK
(test-equal #\０    (char-downcase #\０))    ;; U+FF10 FULLWIDTH DIGIT ZERO
(test-equal (if unicode? #\ａ #\Ａ) (char-downcase #\Ａ))    ;; U+FF21 FULLWIDTH LATIN CAPITAL LETTER A
(test-equal #\ａ    (char-downcase #\ａ))    ;; U+FF41 FULLWIDTH LATIN SMALL LETTER A
(test-end "char-downcase non-ASCII")


;; invalid character literal
(test-begin "invalid char literal")
(test-error (string-read "#\\nonexistent"))

(test-equal (integer->char 120)
            (read (open-input-string "#\\x")))
(test-error (string-read "#\\x0g"))
(test-error (string-read "#\\x1g"))
(test-error (string-read "#\\x00g"))
(test-error (string-read "#\\x01g"))

(test-error (string-read "#\\x-0"))
(test-error (string-read "#\\x-1"))
(test-error (string-read "#\\x-00"))
(test-error (string-read "#\\x-01"))
(test-error (string-read "#\\x-000"))
(test-error (string-read "#\\x-010"))
(test-error (string-read "#\\x-001"))
(test-error (string-read "#\\x-100"))
(test-error (string-read "#\\x-00a"))
(test-error (string-read "#\\x-0a0"))
(test-error (string-read "#\\x-a00"))

(test-error (string-read "#\\x+0"))
(test-error (string-read "#\\x+1"))
(test-error (string-read "#\\x+00"))
(test-error (string-read "#\\x+01"))
(test-error (string-read "#\\x+000"))
(test-error (string-read "#\\x+010"))
(test-error (string-read "#\\x+001"))
(test-error (string-read "#\\x+100"))
(test-error (string-read "#\\x+00a"))
(test-error (string-read "#\\x+0a0"))
(test-error (string-read "#\\x+a00"))
(test-end "invalid char literal")

(test-begin "improper SRFI-75 char literals (proper in R5.92RS)")
(test-assert (char? (string-read "#\\x0")))
(test-assert (char? (string-read "#\\x1")))
(test-assert (char? (string-read "#\\x000")))
(test-assert (char? (string-read "#\\x010")))
(test-assert (char? (string-read "#\\x001")))
(test-assert (char? (string-read "#\\x100")))
(test-assert (char? (string-read "#\\x00a")))
(test-assert (char? (string-read "#\\x0a0")))
(test-assert (char? (string-read "#\\xa00")))
(test-end "improper SRFI-75 char literals (proper in R5.92RS)")

(test-begin "R5RS named chars case-insensitivity")
(test-equal #\newline (integer->char 10))
(test-equal #\Newline (integer->char 10))
(test-equal #\NEWLINE (integer->char 10))
(test-equal #\NeWliNE (integer->char 10))
(test-equal #\space   (integer->char 32))
(test-equal #\Space   (integer->char 32))
(test-equal #\SPACE   (integer->char 32))
(test-equal #\SpACe   (integer->char 32))
(test-end "R5RS named chars case-insensitivity")

;;
;; R6RS(SRFI-75) named chars
;;

;; NOTE: #\x0e -style character is defined in R6RS(SRFI-75)
(test-begin "R6RS named chars")
(test-equal #\nul       #\x00)  ;; 0
(test-equal #\alarm     #\x07)  ;; 7
(test-equal #\backspace #\x08)  ;; 8
(test-equal #\tab       #\x09)  ;; 9
(test-equal #\newline   #\x0a)  ;; 10
(test-equal #\vtab      #\x0b)  ;; 11
(test-equal #\page      #\x0c)  ;; 12
(test-equal #\return    #\x0d)  ;; 13
(test-equal #\esc       #\x1b)  ;; 27
(test-equal #\space     #\x20)  ;; 32
(test-equal #\delete    #\x7f)  ;; 127

(test-equal "#\\nul"     (obj->literal #\x00))  ;; 0
(test-equal "#\\alarm"   (obj->literal #\x07))  ;; 7
(test-equal "#\\backspace" (obj->literal #\x08))  ;; 8
(test-equal "#\\tab"     (obj->literal #\x09))  ;; 9
(test-equal "#\\newline" (obj->literal #\x0a))  ;; 10
(test-equal "#\\vtab"    (obj->literal #\x0b))  ;; 11
(test-equal "#\\page"    (obj->literal #\x0c))  ;; 12
(test-equal "#\\return"  (obj->literal #\x0d))  ;; 13
(test-equal "#\\esc"     (obj->literal #\x1b))  ;; 27
(test-equal "#\\space"   (obj->literal #\x20))  ;; 32
(test-equal "#\\delete"  (obj->literal #\x7f))  ;; 127
(test-end "R6RS named chars")

(test-begin "R6RS named chars case-sensitivity")
;; FIXME: SigScheme is currently not conforming to the case-sensitivity of
;; R6RS character names. These tests must be failed in R6RS character
;; processing.
(test-equal #\NUL       #\x00)  ;; 0
(test-equal #\ALARM     #\x07)  ;; 7
(test-equal #\BACKSPACE #\x08)  ;; 8
(test-equal #\TAB       #\x09)  ;; 9
(test-equal #\NEWLINE   #\x0a)  ;; 10
(test-equal #\VTAB      #\x0b)  ;; 11
(test-equal #\PAGE      #\x0c)  ;; 12
(test-equal #\RETURN    #\x0d)  ;; 13
(test-equal #\ESC       #\x1b)  ;; 27
(test-equal #\SPACE     #\x20)  ;; 32
(test-equal #\DELETE    #\x7f)  ;; 127
(test-end "R6RS named chars case-sensitivity")

(test-begin "char literal")
(test-equal "#\\nul"       (obj->literal #\nul))       ;; 0
(test-equal "#\\x01"       (obj->literal #\x01))       ;; 1
(test-equal "#\\x02"       (obj->literal #\x02))       ;; 2
(test-equal "#\\x03"       (obj->literal #\x03))       ;; 3
(test-equal "#\\x04"       (obj->literal #\x04))       ;; 4
(test-equal "#\\x05"       (obj->literal #\x05))       ;; 5
(test-equal "#\\x06"       (obj->literal #\x06))       ;; 6
(test-equal "#\\alarm"     (obj->literal #\alarm))     ;; 7
(test-equal "#\\backspace" (obj->literal #\backspace)) ;; 8
(test-equal "#\\tab"       (obj->literal #\tab))       ;; 9
(test-equal "#\\newline"   (obj->literal #\newline))   ;; 10
(test-equal "#\\vtab"      (obj->literal #\vtab))      ;; 11
(test-equal "#\\page"      (obj->literal #\page))      ;; 12
(test-equal "#\\return"    (obj->literal #\return))    ;; 13
(test-equal "#\\x0e"       (obj->literal #\x0e))       ;; 14
(test-equal "#\\x0f"       (obj->literal #\x0f))       ;; 15
(test-equal "#\\x10"       (obj->literal #\x10))       ;; 16
(test-equal "#\\x11"       (obj->literal #\x11))       ;; 17
(test-equal "#\\x12"       (obj->literal #\x12))       ;; 18
(test-equal "#\\x13"       (obj->literal #\x13))       ;; 19
(test-equal "#\\x14"       (obj->literal #\x14))       ;; 20
(test-equal "#\\x15"       (obj->literal #\x15))       ;; 21
(test-equal "#\\x16"       (obj->literal #\x16))       ;; 22
(test-equal "#\\x17"       (obj->literal #\x17))       ;; 23
(test-equal "#\\x18"       (obj->literal #\x18))       ;; 24
(test-equal "#\\x19"       (obj->literal #\x19))       ;; 25
(test-equal "#\\x1a"       (obj->literal #\x1a))       ;; 26
(test-equal "#\\esc"       (obj->literal #\esc))       ;; 27
(test-equal "#\\x1c"       (obj->literal #\x1c))       ;; 28
(test-equal "#\\x1d"       (obj->literal #\x1d))       ;; 29
(test-equal "#\\x1e"       (obj->literal #\x1e))       ;; 30
(test-equal "#\\x1f"       (obj->literal #\x1f))       ;; 31
(test-equal "#\\space"     (obj->literal #\space))     ;; 32
(test-equal "#\\!"         (obj->literal #\!))         ;; 33
(test-equal "#\\\""        (obj->literal #\"))         ;; 34
(test-equal "#\\#"         (obj->literal #\#))         ;; 35
(test-equal "#\\$"         (obj->literal #\$))         ;; 36
(test-equal "#\\%"         (obj->literal #\%))         ;; 37
(test-equal "#\\&"         (obj->literal #\&))         ;; 38
(test-equal "#\\'"         (obj->literal #\'))         ;; 39
(test-equal "#\\("         (obj->literal #\())         ;; 40
(test-equal "#\\)"         (obj->literal #\)))         ;; 41
(test-equal "#\\*"         (obj->literal #\*))         ;; 42
(test-equal "#\\+"         (obj->literal #\+))         ;; 43
(test-equal "#\\,"         (obj->literal #\,))         ;; 44
(test-equal "#\\-"         (obj->literal #\-))         ;; 45
(test-equal "#\\."         (obj->literal #\.))         ;; 46
(test-equal "#\\/"         (obj->literal #\/))         ;; 47
(test-equal "#\\0"         (obj->literal #\0))         ;; 48
(test-equal "#\\1"         (obj->literal #\1))         ;; 49
(test-equal "#\\2"         (obj->literal #\2))         ;; 50
(test-equal "#\\3"         (obj->literal #\3))         ;; 51
(test-equal "#\\4"         (obj->literal #\4))         ;; 52
(test-equal "#\\5"         (obj->literal #\5))         ;; 53
(test-equal "#\\6"         (obj->literal #\6))         ;; 54
(test-equal "#\\7"         (obj->literal #\7))         ;; 55
(test-equal "#\\8"         (obj->literal #\8))         ;; 56
(test-equal "#\\9"         (obj->literal #\9))         ;; 57
(test-equal "#\\:"         (obj->literal #\:))         ;; 58
(test-equal "#\\;"         (obj->literal #\;))         ;; 59
(test-equal "#\\<"         (obj->literal #\<))         ;; 60
(test-equal "#\\="         (obj->literal #\=))         ;; 61
(test-equal "#\\>"         (obj->literal #\>))         ;; 62
(test-equal "#\\?"         (obj->literal #\?))         ;; 63
(test-equal "#\\@"         (obj->literal #\@))         ;; 64
(test-equal "#\\A"         (obj->literal #\A))         ;; 65
(test-equal "#\\B"         (obj->literal #\B))         ;; 66
(test-equal "#\\C"         (obj->literal #\C))         ;; 67
(test-equal "#\\D"         (obj->literal #\D))         ;; 68
(test-equal "#\\E"         (obj->literal #\E))         ;; 69
(test-equal "#\\F"         (obj->literal #\F))         ;; 70
(test-equal "#\\G"         (obj->literal #\G))         ;; 71
(test-equal "#\\H"         (obj->literal #\H))         ;; 72
(test-equal "#\\I"         (obj->literal #\I))         ;; 73
(test-equal "#\\J"         (obj->literal #\J))         ;; 74
(test-equal "#\\K"         (obj->literal #\K))         ;; 75
(test-equal "#\\L"         (obj->literal #\L))         ;; 76
(test-equal "#\\M"         (obj->literal #\M))         ;; 77
(test-equal "#\\N"         (obj->literal #\N))         ;; 78
(test-equal "#\\O"         (obj->literal #\O))         ;; 79
(test-equal "#\\P"         (obj->literal #\P))         ;; 80
(test-equal "#\\Q"         (obj->literal #\Q))         ;; 81
(test-equal "#\\R"         (obj->literal #\R))         ;; 82
(test-equal "#\\S"         (obj->literal #\S))         ;; 83
(test-equal "#\\T"         (obj->literal #\T))         ;; 84
(test-equal "#\\U"         (obj->literal #\U))         ;; 85
(test-equal "#\\V"         (obj->literal #\V))         ;; 86
(test-equal "#\\W"         (obj->literal #\W))         ;; 87
(test-equal "#\\X"         (obj->literal #\X))         ;; 88
(test-equal "#\\Y"         (obj->literal #\Y))         ;; 89
(test-equal "#\\Z"         (obj->literal #\Z))         ;; 90
(test-equal "#\\["         (obj->literal #\[))         ;; 91
(test-equal "#\\\\"        (obj->literal #\\))         ;; 92
(test-equal "#\\]"         (obj->literal #\]))         ;; 93
(test-equal "#\\^"         (obj->literal #\^))         ;; 94
(test-equal "#\\_"         (obj->literal #\_))         ;; 95
(test-equal "#\\`"         (obj->literal #\`))         ;; 96
(test-equal "#\\a"         (obj->literal #\a))         ;; 97
(test-equal "#\\b"         (obj->literal #\b))         ;; 98
(test-equal "#\\c"         (obj->literal #\c))         ;; 99
(test-equal "#\\d"         (obj->literal #\d))         ;; 100
(test-equal "#\\e"         (obj->literal #\e))         ;; 101
(test-equal "#\\f"         (obj->literal #\f))         ;; 102
(test-equal "#\\g"         (obj->literal #\g))         ;; 103
(test-equal "#\\h"         (obj->literal #\h))         ;; 104
(test-equal "#\\i"         (obj->literal #\i))         ;; 105
(test-equal "#\\j"         (obj->literal #\j))         ;; 106
(test-equal "#\\k"         (obj->literal #\k))         ;; 107
(test-equal "#\\l"         (obj->literal #\l))         ;; 108
(test-equal "#\\m"         (obj->literal #\m))         ;; 109
(test-equal "#\\n"         (obj->literal #\n))         ;; 110
(test-equal "#\\o"         (obj->literal #\o))         ;; 111
(test-equal "#\\p"         (obj->literal #\p))         ;; 112
(test-equal "#\\q"         (obj->literal #\q))         ;; 113
(test-equal "#\\r"         (obj->literal #\r))         ;; 114
(test-equal "#\\s"         (obj->literal #\s))         ;; 115
(test-equal "#\\t"         (obj->literal #\t))         ;; 116
(test-equal "#\\u"         (obj->literal #\u))         ;; 117
(test-equal "#\\v"         (obj->literal #\v))         ;; 118
(test-equal "#\\w"         (obj->literal #\w))         ;; 119
(test-equal "#\\x"         (obj->literal #\x))         ;; 120
(test-equal "#\\y"         (obj->literal #\y))         ;; 121
(test-equal "#\\z"         (obj->literal #\z))         ;; 122
(test-equal "#\\{"         (obj->literal #\{))         ;; 123
(test-equal "#\\|"         (obj->literal #\|))         ;; 124
(test-equal "#\\}"         (obj->literal #\}))         ;; 125
(test-equal "#\\~"         (obj->literal #\~))         ;; 126
(test-equal "#\\delete"    (obj->literal #\delete))    ;; 127
(test-end "char literal")

;; R6RS(SRFI-75) hexadecimal character literal
(test-begin "R6RS hexadecimal char literal")
(test-equal #\nul       #\x00)    ;; 0
(test-equal #\x01       #\x01)    ;; 1
(test-equal #\x02       #\x02)    ;; 2
(test-equal #\x03       #\x03)    ;; 3
(test-equal #\x04       #\x04)    ;; 4
(test-equal #\x05       #\x05)    ;; 5
(test-equal #\x06       #\x06)    ;; 6
(test-equal #\alarm     #\x07)    ;; 7
(test-equal #\backspace #\x08)    ;; 8
(test-equal #\tab       #\x09)    ;; 9
(test-equal #\newline   #\x0a)   ;; 10
(test-equal #\vtab      #\x0b)   ;; 11
(test-equal #\page      #\x0c)   ;; 12
(test-equal #\return    #\x0d)   ;; 13
(test-equal #\x0e       #\x0e)   ;; 14
(test-equal #\x0f       #\x0f)   ;; 15
(test-equal #\x10       #\x10)   ;; 16
(test-equal #\x11       #\x11)   ;; 17
(test-equal #\x12       #\x12)   ;; 18
(test-equal #\x13       #\x13)   ;; 19
(test-equal #\x14       #\x14)   ;; 20
(test-equal #\x15       #\x15)   ;; 21
(test-equal #\x16       #\x16)   ;; 22
(test-equal #\x17       #\x17)   ;; 23
(test-equal #\x18       #\x18)   ;; 24
(test-equal #\x19       #\x19)   ;; 25
(test-equal #\x1a       #\x1a)   ;; 26
(test-equal #\esc       #\x1b)   ;; 27
(test-equal #\x1c       #\x1c)   ;; 28
(test-equal #\x1d       #\x1d)   ;; 29
(test-equal #\x1e       #\x1e)   ;; 30
(test-equal #\x1f       #\x1f)   ;; 31
(test-equal #\space     #\x20)   ;; 32
(test-equal #\!         #\x21)   ;; 33
(test-equal #\"         #\x22)   ;; 34
(test-equal #\#         #\x23)   ;; 35
(test-equal #\$         #\x24)   ;; 36
(test-equal #\%         #\x25)   ;; 37
(test-equal #\&         #\x26)   ;; 38
(test-equal #\'         #\x27)   ;; 39
(test-equal #\(         #\x28)   ;; 40
(test-equal #\)         #\x29)   ;; 41
(test-equal #\*         #\x2a)   ;; 42
(test-equal #\+         #\x2b)   ;; 43
(test-equal #\,         #\x2c)   ;; 44
(test-equal #\-         #\x2d)   ;; 45
(test-equal #\.         #\x2e)   ;; 46
(test-equal #\/         #\x2f)   ;; 47
(test-equal #\0         #\x30)   ;; 48
(test-equal #\1         #\x31)   ;; 49
(test-equal #\2         #\x32)   ;; 50
(test-equal #\3         #\x33)   ;; 51
(test-equal #\4         #\x34)   ;; 52
(test-equal #\5         #\x35)   ;; 53
(test-equal #\6         #\x36)   ;; 54
(test-equal #\7         #\x37)   ;; 55
(test-equal #\8         #\x38)   ;; 56
(test-equal #\9         #\x39)   ;; 57
(test-equal #\:         #\x3a)   ;; 58
(test-equal #\;         #\x3b)   ;; 59
(test-equal #\<         #\x3c)   ;; 60
(test-equal #\=         #\x3d)   ;; 61
(test-equal #\>         #\x3e)   ;; 62
(test-equal #\?         #\x3f)   ;; 63
(test-equal #\@         #\x40)   ;; 64
(test-equal #\A         #\x41)   ;; 65
(test-equal #\B         #\x42)   ;; 66
(test-equal #\C         #\x43)   ;; 67
(test-equal #\D         #\x44)   ;; 68
(test-equal #\E         #\x45)   ;; 69
(test-equal #\F         #\x46)   ;; 70
(test-equal #\G         #\x47)   ;; 71
(test-equal #\H         #\x48)   ;; 72
(test-equal #\I         #\x49)   ;; 73
(test-equal #\J         #\x4a)   ;; 74
(test-equal #\K         #\x4b)   ;; 75
(test-equal #\L         #\x4c)   ;; 76
(test-equal #\M         #\x4d)   ;; 77
(test-equal #\N         #\x4e)   ;; 78
(test-equal #\O         #\x4f)   ;; 79
(test-equal #\P         #\x50)   ;; 80
(test-equal #\Q         #\x51)   ;; 81
(test-equal #\R         #\x52)   ;; 82
(test-equal #\S         #\x53)   ;; 83
(test-equal #\T         #\x54)   ;; 84
(test-equal #\U         #\x55)   ;; 85
(test-equal #\V         #\x56)   ;; 86
(test-equal #\W         #\x57)   ;; 87
(test-equal #\X         #\x58)   ;; 88
(test-equal #\Y         #\x59)   ;; 89
(test-equal #\Z         #\x5a)   ;; 90
(test-equal #\[         #\x5b)   ;; 91
(test-equal #\\         #\x5c)   ;; 92
(test-equal #\]         #\x5d)   ;; 93
(test-equal #\^         #\x5e)   ;; 94
(test-equal #\_         #\x5f)   ;; 95
(test-equal #\`         #\x60)   ;; 96
(test-equal #\a         #\x61)   ;; 97
(test-equal #\b         #\x62)   ;; 98
(test-equal #\c         #\x63)   ;; 99
(test-equal #\d         #\x64)  ;; 100
(test-equal #\e         #\x65)  ;; 101
(test-equal #\f         #\x66)  ;; 102
(test-equal #\g         #\x67)  ;; 103
(test-equal #\h         #\x68)  ;; 104
(test-equal #\i         #\x69)  ;; 105
(test-equal #\j         #\x6a)  ;; 106
(test-equal #\k         #\x6b)  ;; 107
(test-equal #\l         #\x6c)  ;; 108
(test-equal #\m         #\x6d)  ;; 109
(test-equal #\n         #\x6e)  ;; 110
(test-equal #\o         #\x6f)  ;; 111
(test-equal #\p         #\x70)  ;; 112
(test-equal #\q         #\x71)  ;; 113
(test-equal #\r         #\x72)  ;; 114
(test-equal #\s         #\x73)  ;; 115
(test-equal #\t         #\x74)  ;; 116
(test-equal #\u         #\x75)  ;; 117
(test-equal #\v         #\x76)  ;; 118
(test-equal #\w         #\x77)  ;; 119
(test-equal #\x         #\x78)  ;; 120
(test-equal #\y         #\x79)  ;; 121
(test-equal #\z         #\x7a)  ;; 122
(test-equal #\{         #\x7b)  ;; 123
(test-equal #\|         #\x7c)  ;; 124
(test-equal #\}         #\x7d)  ;; 125
(test-equal #\~         #\x7e)  ;; 126
(test-equal #\delete    #\x7f)  ;; 127
(test-end "R6RS hexadecimal char literal")

(test-begin "R6RS hexadecimal char literal (string form)")
(test-equal "#\\nul"       (obj->literal #\x00))  ;; 0
(test-equal "#\\x01"       (obj->literal #\x01))  ;; 1
(test-equal "#\\x02"       (obj->literal #\x02))  ;; 2
(test-equal "#\\x03"       (obj->literal #\x03))  ;; 3
(test-equal "#\\x04"       (obj->literal #\x04))  ;; 4
(test-equal "#\\x05"       (obj->literal #\x05))  ;; 5
(test-equal "#\\x06"       (obj->literal #\x06))  ;; 6
(test-equal "#\\alarm"     (obj->literal #\x07))  ;; 7
(test-equal "#\\backspace" (obj->literal #\x08))  ;; 8
(test-equal "#\\tab"       (obj->literal #\x09))  ;; 9
(test-equal "#\\newline"   (obj->literal #\x0a))  ;; 10
(test-equal "#\\vtab"      (obj->literal #\x0b))  ;; 11
(test-equal "#\\page"      (obj->literal #\x0c))  ;; 12
(test-equal "#\\return"    (obj->literal #\x0d))  ;; 13
(test-equal "#\\x0e"       (obj->literal #\x0e))  ;; 14
(test-equal "#\\x0f"       (obj->literal #\x0f))  ;; 15
(test-equal "#\\x10"       (obj->literal #\x10))  ;; 16
(test-equal "#\\x11"       (obj->literal #\x11))  ;; 17
(test-equal "#\\x12"       (obj->literal #\x12))  ;; 18
(test-equal "#\\x13"       (obj->literal #\x13))  ;; 19
(test-equal "#\\x14"       (obj->literal #\x14))  ;; 20
(test-equal "#\\x15"       (obj->literal #\x15))  ;; 21
(test-equal "#\\x16"       (obj->literal #\x16))  ;; 22
(test-equal "#\\x17"       (obj->literal #\x17))  ;; 23
(test-equal "#\\x18"       (obj->literal #\x18))  ;; 24
(test-equal "#\\x19"       (obj->literal #\x19))  ;; 25
(test-equal "#\\x1a"       (obj->literal #\x1a))  ;; 26
(test-equal "#\\esc"       (obj->literal #\x1b))  ;; 27
(test-equal "#\\x1c"       (obj->literal #\x1c))  ;; 28
(test-equal "#\\x1d"       (obj->literal #\x1d))  ;; 29
(test-equal "#\\x1e"       (obj->literal #\x1e))  ;; 30
(test-equal "#\\x1f"       (obj->literal #\x1f))  ;; 31
(test-equal "#\\space"     (obj->literal #\x20))  ;; 32
(test-equal "#\\!"         (obj->literal #\x21))  ;; 33
(test-equal "#\\\""        (obj->literal #\x22))  ;; 34
(test-equal "#\\#"         (obj->literal #\x23))  ;; 35
(test-equal "#\\$"         (obj->literal #\x24))  ;; 36
(test-equal "#\\%"         (obj->literal #\x25))  ;; 37
(test-equal "#\\&"         (obj->literal #\x26))  ;; 38
(test-equal "#\\'"         (obj->literal #\x27))  ;; 39
(test-equal "#\\("         (obj->literal #\x28))  ;; 40
(test-equal "#\\)"         (obj->literal #\x29))  ;; 41
(test-equal "#\\*"         (obj->literal #\x2a))  ;; 42
(test-equal "#\\+"         (obj->literal #\x2b))  ;; 43
(test-equal "#\\,"         (obj->literal #\x2c))  ;; 44
(test-equal "#\\-"         (obj->literal #\x2d))  ;; 45
(test-equal "#\\."         (obj->literal #\x2e))  ;; 46
(test-equal "#\\/"         (obj->literal #\x2f))  ;; 47
(test-equal "#\\0"         (obj->literal #\x30))  ;; 48
(test-equal "#\\1"         (obj->literal #\x31))  ;; 49
(test-equal "#\\2"         (obj->literal #\x32))  ;; 50
(test-equal "#\\3"         (obj->literal #\x33))  ;; 51
(test-equal "#\\4"         (obj->literal #\x34))  ;; 52
(test-equal "#\\5"         (obj->literal #\x35))  ;; 53
(test-equal "#\\6"         (obj->literal #\x36))  ;; 54
(test-equal "#\\7"         (obj->literal #\x37))  ;; 55
(test-equal "#\\8"         (obj->literal #\x38))  ;; 56
(test-equal "#\\9"         (obj->literal #\x39))  ;; 57
(test-equal "#\\:"         (obj->literal #\x3a))  ;; 58
(test-equal "#\\;"         (obj->literal #\x3b))  ;; 59
(test-equal "#\\<"         (obj->literal #\x3c))  ;; 60
(test-equal "#\\="         (obj->literal #\x3d))  ;; 61
(test-equal "#\\>"         (obj->literal #\x3e))  ;; 62
(test-equal "#\\?"         (obj->literal #\x3f))  ;; 63
(test-equal "#\\@"         (obj->literal #\x40))  ;; 64
(test-equal "#\\A"         (obj->literal #\x41))  ;; 65
(test-equal "#\\B"         (obj->literal #\x42))  ;; 66
(test-equal "#\\C"         (obj->literal #\x43))  ;; 67
(test-equal "#\\D"         (obj->literal #\x44))  ;; 68
(test-equal "#\\E"         (obj->literal #\x45))  ;; 69
(test-equal "#\\F"         (obj->literal #\x46))  ;; 70
(test-equal "#\\G"         (obj->literal #\x47))  ;; 71
(test-equal "#\\H"         (obj->literal #\x48))  ;; 72
(test-equal "#\\I"         (obj->literal #\x49))  ;; 73
(test-equal "#\\J"         (obj->literal #\x4a))  ;; 74
(test-equal "#\\K"         (obj->literal #\x4b))  ;; 75
(test-equal "#\\L"         (obj->literal #\x4c))  ;; 76
(test-equal "#\\M"         (obj->literal #\x4d))  ;; 77
(test-equal "#\\N"         (obj->literal #\x4e))  ;; 78
(test-equal "#\\O"         (obj->literal #\x4f))  ;; 79
(test-equal "#\\P"         (obj->literal #\x50))  ;; 80
(test-equal "#\\Q"         (obj->literal #\x51))  ;; 81
(test-equal "#\\R"         (obj->literal #\x52))  ;; 82
(test-equal "#\\S"         (obj->literal #\x53))  ;; 83
(test-equal "#\\T"         (obj->literal #\x54))  ;; 84
(test-equal "#\\U"         (obj->literal #\x55))  ;; 85
(test-equal "#\\V"         (obj->literal #\x56))  ;; 86
(test-equal "#\\W"         (obj->literal #\x57))  ;; 87
(test-equal "#\\X"         (obj->literal #\x58))  ;; 88
(test-equal "#\\Y"         (obj->literal #\x59))  ;; 89
(test-equal "#\\Z"         (obj->literal #\x5a))  ;; 90
(test-equal "#\\["         (obj->literal #\x5b))  ;; 91
(test-equal "#\\\\"        (obj->literal #\x5c))  ;; 92
(test-equal "#\\]"         (obj->literal #\x5d))  ;; 93
(test-equal "#\\^"         (obj->literal #\x5e))  ;; 94
(test-equal "#\\_"         (obj->literal #\x5f))  ;; 95
(test-equal "#\\`"         (obj->literal #\x60))  ;; 96
(test-equal "#\\a"         (obj->literal #\x61))  ;; 97
(test-equal "#\\b"         (obj->literal #\x62))  ;; 98
(test-equal "#\\c"         (obj->literal #\x63))  ;; 99
(test-equal "#\\d"         (obj->literal #\x64))  ;; 100
(test-equal "#\\e"         (obj->literal #\x65))  ;; 101
(test-equal "#\\f"         (obj->literal #\x66))  ;; 102
(test-equal "#\\g"         (obj->literal #\x67))  ;; 103
(test-equal "#\\h"         (obj->literal #\x68))  ;; 104
(test-equal "#\\i"         (obj->literal #\x69))  ;; 105
(test-equal "#\\j"         (obj->literal #\x6a))  ;; 106
(test-equal "#\\k"         (obj->literal #\x6b))  ;; 107
(test-equal "#\\l"         (obj->literal #\x6c))  ;; 108
(test-equal "#\\m"         (obj->literal #\x6d))  ;; 109
(test-equal "#\\n"         (obj->literal #\x6e))  ;; 110
(test-equal "#\\o"         (obj->literal #\x6f))  ;; 111
(test-equal "#\\p"         (obj->literal #\x70))  ;; 112
(test-equal "#\\q"         (obj->literal #\x71))  ;; 113
(test-equal "#\\r"         (obj->literal #\x72))  ;; 114
(test-equal "#\\s"         (obj->literal #\x73))  ;; 115
(test-equal "#\\t"         (obj->literal #\x74))  ;; 116
(test-equal "#\\u"         (obj->literal #\x75))  ;; 117
(test-equal "#\\v"         (obj->literal #\x76))  ;; 118
(test-equal "#\\w"         (obj->literal #\x77))  ;; 119
(test-equal "#\\x"         (obj->literal #\x78))  ;; 120
(test-equal "#\\y"         (obj->literal #\x79))  ;; 121
(test-equal "#\\z"         (obj->literal #\x7a))  ;; 122
(test-equal "#\\{"         (obj->literal #\x7b))  ;; 123
(test-equal "#\\|"         (obj->literal #\x7c))  ;; 124
(test-equal "#\\}"         (obj->literal #\x7d))  ;; 125
(test-equal "#\\~"         (obj->literal #\x7e))  ;; 126
(test-equal "#\\delete"    (obj->literal #\x7f))  ;; 127
(test-end "R6RS hexadecimal char literal (string form)")

(test-begin "R6RS hexadecimal char literal (compared with integer-originated char)")
(test-equal (integer->char   0) #\x00)  ;; 0
(test-equal (integer->char   1) #\x01)  ;; 1
(test-equal (integer->char   2) #\x02)  ;; 2
(test-equal (integer->char   3) #\x03)  ;; 3
(test-equal (integer->char   4) #\x04)  ;; 4
(test-equal (integer->char   5) #\x05)  ;; 5
(test-equal (integer->char   6) #\x06)  ;; 6
(test-equal (integer->char   7) #\x07)  ;; 7
(test-equal (integer->char   8) #\x08)  ;; 8
(test-equal (integer->char   9) #\x09)  ;; 9
(test-equal (integer->char  10) #\x0a)  ;; 10
(test-equal (integer->char  11) #\x0b)  ;; 11
(test-equal (integer->char  12) #\x0c)  ;; 12
(test-equal (integer->char  13) #\x0d)  ;; 13
(test-equal (integer->char  14) #\x0e)  ;; 14
(test-equal (integer->char  15) #\x0f)  ;; 15
(test-equal (integer->char  16) #\x10)  ;; 16
(test-equal (integer->char  17) #\x11)  ;; 17
(test-equal (integer->char  18) #\x12)  ;; 18
(test-equal (integer->char  19) #\x13)  ;; 19
(test-equal (integer->char  20) #\x14)  ;; 20
(test-equal (integer->char  21) #\x15)  ;; 21
(test-equal (integer->char  22) #\x16)  ;; 22
(test-equal (integer->char  23) #\x17)  ;; 23
(test-equal (integer->char  24) #\x18)  ;; 24
(test-equal (integer->char  25) #\x19)  ;; 25
(test-equal (integer->char  26) #\x1a)  ;; 26
(test-equal (integer->char  27) #\x1b)  ;; 27
(test-equal (integer->char  28) #\x1c)  ;; 28
(test-equal (integer->char  29) #\x1d)  ;; 29
(test-equal (integer->char  30) #\x1e)  ;; 30
(test-equal (integer->char  31) #\x1f)  ;; 31
(test-equal (integer->char  32) #\x20)  ;; 32
(test-equal (integer->char  33) #\x21)  ;; 33
(test-equal (integer->char  34) #\x22)  ;; 34
(test-equal (integer->char  35) #\x23)  ;; 35
(test-equal (integer->char  36) #\x24)  ;; 36
(test-equal (integer->char  37) #\x25)  ;; 37
(test-equal (integer->char  38) #\x26)  ;; 38
(test-equal (integer->char  39) #\x27)  ;; 39
(test-equal (integer->char  40) #\x28)  ;; 40
(test-equal (integer->char  41) #\x29)  ;; 41
(test-equal (integer->char  42) #\x2a)  ;; 42
(test-equal (integer->char  43) #\x2b)  ;; 43
(test-equal (integer->char  44) #\x2c)  ;; 44
(test-equal (integer->char  45) #\x2d)  ;; 45
(test-equal (integer->char  46) #\x2e)  ;; 46
(test-equal (integer->char  47) #\x2f)  ;; 47
(test-equal (integer->char  48) #\x30)  ;; 48
(test-equal (integer->char  49) #\x31)  ;; 49
(test-equal (integer->char  50) #\x32)  ;; 50
(test-equal (integer->char  51) #\x33)  ;; 51
(test-equal (integer->char  52) #\x34)  ;; 52
(test-equal (integer->char  53) #\x35)  ;; 53
(test-equal (integer->char  54) #\x36)  ;; 54
(test-equal (integer->char  55) #\x37)  ;; 55
(test-equal (integer->char  56) #\x38)  ;; 56
(test-equal (integer->char  57) #\x39)  ;; 57
(test-equal (integer->char  58) #\x3a)  ;; 58
(test-equal (integer->char  59) #\x3b)  ;; 59
(test-equal (integer->char  60) #\x3c)  ;; 60
(test-equal (integer->char  61) #\x3d)  ;; 61
(test-equal (integer->char  62) #\x3e)  ;; 62
(test-equal (integer->char  63) #\x3f)  ;; 63
(test-equal (integer->char  64) #\x40)  ;; 64
(test-equal (integer->char  65) #\x41)  ;; 65
(test-equal (integer->char  66) #\x42)  ;; 66
(test-equal (integer->char  67) #\x43)  ;; 67
(test-equal (integer->char  68) #\x44)  ;; 68
(test-equal (integer->char  69) #\x45)  ;; 69
(test-equal (integer->char  70) #\x46)  ;; 70
(test-equal (integer->char  71) #\x47)  ;; 71
(test-equal (integer->char  72) #\x48)  ;; 72
(test-equal (integer->char  73) #\x49)  ;; 73
(test-equal (integer->char  74) #\x4a)  ;; 74
(test-equal (integer->char  75) #\x4b)  ;; 75
(test-equal (integer->char  76) #\x4c)  ;; 76
(test-equal (integer->char  77) #\x4d)  ;; 77
(test-equal (integer->char  78) #\x4e)  ;; 78
(test-equal (integer->char  79) #\x4f)  ;; 79
(test-equal (integer->char  80) #\x50)  ;; 80
(test-equal (integer->char  81) #\x51)  ;; 81
(test-equal (integer->char  82) #\x52)  ;; 82
(test-equal (integer->char  83) #\x53)  ;; 83
(test-equal (integer->char  84) #\x54)  ;; 84
(test-equal (integer->char  85) #\x55)  ;; 85
(test-equal (integer->char  86) #\x56)  ;; 86
(test-equal (integer->char  87) #\x57)  ;; 87
(test-equal (integer->char  88) #\x58)  ;; 88
(test-equal (integer->char  89) #\x59)  ;; 89
(test-equal (integer->char  90) #\x5a)  ;; 90
(test-equal (integer->char  91) #\x5b)  ;; 91
(test-equal (integer->char  92) #\x5c)  ;; 92
(test-equal (integer->char  93) #\x5d)  ;; 93
(test-equal (integer->char  94) #\x5e)  ;; 94
(test-equal (integer->char  95) #\x5f)  ;; 95
(test-equal (integer->char  96) #\x60)  ;; 96
(test-equal (integer->char  97) #\x61)  ;; 97
(test-equal (integer->char  98) #\x62)  ;; 98
(test-equal (integer->char  99) #\x63)  ;; 99
(test-equal (integer->char 100) #\x64)  ;; 100
(test-equal (integer->char 101) #\x65)  ;; 101
(test-equal (integer->char 102) #\x66)  ;; 102
(test-equal (integer->char 103) #\x67)  ;; 103
(test-equal (integer->char 104) #\x68)  ;; 104
(test-equal (integer->char 105) #\x69)  ;; 105
(test-equal (integer->char 106) #\x6a)  ;; 106
(test-equal (integer->char 107) #\x6b)  ;; 107
(test-equal (integer->char 108) #\x6c)  ;; 108
(test-equal (integer->char 109) #\x6d)  ;; 109
(test-equal (integer->char 110) #\x6e)  ;; 110
(test-equal (integer->char 111) #\x6f)  ;; 111
(test-equal (integer->char 112) #\x70)  ;; 112
(test-equal (integer->char 113) #\x71)  ;; 113
(test-equal (integer->char 114) #\x72)  ;; 114
(test-equal (integer->char 115) #\x73)  ;; 115
(test-equal (integer->char 116) #\x74)  ;; 116
(test-equal (integer->char 117) #\x75)  ;; 117
(test-equal (integer->char 118) #\x76)  ;; 118
(test-equal (integer->char 119) #\x77)  ;; 119
(test-equal (integer->char 120) #\x78)  ;; 120
(test-equal (integer->char 121) #\x79)  ;; 121
(test-equal (integer->char 122) #\x7a)  ;; 122
(test-equal (integer->char 123) #\x7b)  ;; 123
(test-equal (integer->char 124) #\x7c)  ;; 124
(test-equal (integer->char 125) #\x7d)  ;; 125
(test-equal (integer->char 126) #\x7e)  ;; 126
(test-equal (integer->char 127) #\x7f)  ;; 127
(test-end "R6RS hexadecimal char literal (compared with integer-originated char)")

(test-begin "R6RS hexadecimal char literal (capitalized hexadecimal)")
(test-equal (integer->char   0) #\x00)  ;; 0
(test-equal (integer->char   1) #\x01)  ;; 1
(test-equal (integer->char   2) #\x02)  ;; 2
(test-equal (integer->char   3) #\x03)  ;; 3
(test-equal (integer->char   4) #\x04)  ;; 4
(test-equal (integer->char   5) #\x05)  ;; 5
(test-equal (integer->char   6) #\x06)  ;; 6
(test-equal (integer->char   7) #\x07)  ;; 7
(test-equal (integer->char   8) #\x08)  ;; 8
(test-equal (integer->char   9) #\x09)  ;; 9
(test-equal (integer->char  10) #\x0A)  ;; 10
(test-equal (integer->char  11) #\x0B)  ;; 11
(test-equal (integer->char  12) #\x0C)  ;; 12
(test-equal (integer->char  13) #\x0D)  ;; 13
(test-equal (integer->char  14) #\x0E)  ;; 14
(test-equal (integer->char  15) #\x0F)  ;; 15
(test-equal (integer->char  16) #\x10)  ;; 16
(test-equal (integer->char  17) #\x11)  ;; 17
(test-equal (integer->char  18) #\x12)  ;; 18
(test-equal (integer->char  19) #\x13)  ;; 19
(test-equal (integer->char  20) #\x14)  ;; 20
(test-equal (integer->char  21) #\x15)  ;; 21
(test-equal (integer->char  22) #\x16)  ;; 22
(test-equal (integer->char  23) #\x17)  ;; 23
(test-equal (integer->char  24) #\x18)  ;; 24
(test-equal (integer->char  25) #\x19)  ;; 25
(test-equal (integer->char  26) #\x1A)  ;; 26
(test-equal (integer->char  27) #\x1B)  ;; 27
(test-equal (integer->char  28) #\x1C)  ;; 28
(test-equal (integer->char  29) #\x1D)  ;; 29
(test-equal (integer->char  30) #\x1E)  ;; 30
(test-equal (integer->char  31) #\x1F)  ;; 31
(test-equal (integer->char  32) #\x20)  ;; 32
(test-equal (integer->char  33) #\x21)  ;; 33
(test-equal (integer->char  34) #\x22)  ;; 34
(test-equal (integer->char  35) #\x23)  ;; 35
(test-equal (integer->char  36) #\x24)  ;; 36
(test-equal (integer->char  37) #\x25)  ;; 37
(test-equal (integer->char  38) #\x26)  ;; 38
(test-equal (integer->char  39) #\x27)  ;; 39
(test-equal (integer->char  40) #\x28)  ;; 40
(test-equal (integer->char  41) #\x29)  ;; 41
(test-equal (integer->char  42) #\x2A)  ;; 42
(test-equal (integer->char  43) #\x2B)  ;; 43
(test-equal (integer->char  44) #\x2C)  ;; 44
(test-equal (integer->char  45) #\x2D)  ;; 45
(test-equal (integer->char  46) #\x2E)  ;; 46
(test-equal (integer->char  47) #\x2F)  ;; 47
(test-equal (integer->char  48) #\x30)  ;; 48
(test-equal (integer->char  49) #\x31)  ;; 49
(test-equal (integer->char  50) #\x32)  ;; 50
(test-equal (integer->char  51) #\x33)  ;; 51
(test-equal (integer->char  52) #\x34)  ;; 52
(test-equal (integer->char  53) #\x35)  ;; 53
(test-equal (integer->char  54) #\x36)  ;; 54
(test-equal (integer->char  55) #\x37)  ;; 55
(test-equal (integer->char  56) #\x38)  ;; 56
(test-equal (integer->char  57) #\x39)  ;; 57
(test-equal (integer->char  58) #\x3A)  ;; 58
(test-equal (integer->char  59) #\x3B)  ;; 59
(test-equal (integer->char  60) #\x3C)  ;; 60
(test-equal (integer->char  61) #\x3D)  ;; 61
(test-equal (integer->char  62) #\x3E)  ;; 62
(test-equal (integer->char  63) #\x3F)  ;; 63
(test-equal (integer->char  64) #\x40)  ;; 64
(test-equal (integer->char  65) #\x41)  ;; 65
(test-equal (integer->char  66) #\x42)  ;; 66
(test-equal (integer->char  67) #\x43)  ;; 67
(test-equal (integer->char  68) #\x44)  ;; 68
(test-equal (integer->char  69) #\x45)  ;; 69
(test-equal (integer->char  70) #\x46)  ;; 70
(test-equal (integer->char  71) #\x47)  ;; 71
(test-equal (integer->char  72) #\x48)  ;; 72
(test-equal (integer->char  73) #\x49)  ;; 73
(test-equal (integer->char  74) #\x4A)  ;; 74
(test-equal (integer->char  75) #\x4B)  ;; 75
(test-equal (integer->char  76) #\x4C)  ;; 76
(test-equal (integer->char  77) #\x4D)  ;; 77
(test-equal (integer->char  78) #\x4E)  ;; 78
(test-equal (integer->char  79) #\x4F)  ;; 79
(test-equal (integer->char  80) #\x50)  ;; 80
(test-equal (integer->char  81) #\x51)  ;; 81
(test-equal (integer->char  82) #\x52)  ;; 82
(test-equal (integer->char  83) #\x53)  ;; 83
(test-equal (integer->char  84) #\x54)  ;; 84
(test-equal (integer->char  85) #\x55)  ;; 85
(test-equal (integer->char  86) #\x56)  ;; 86
(test-equal (integer->char  87) #\x57)  ;; 87
(test-equal (integer->char  88) #\x58)  ;; 88
(test-equal (integer->char  89) #\x59)  ;; 89
(test-equal (integer->char  90) #\x5A)  ;; 90
(test-equal (integer->char  91) #\x5B)  ;; 91
(test-equal (integer->char  92) #\x5C)  ;; 92
(test-equal (integer->char  93) #\x5D)  ;; 93
(test-equal (integer->char  94) #\x5E)  ;; 94
(test-equal (integer->char  95) #\x5F)  ;; 95
(test-equal (integer->char  96) #\x60)  ;; 96
(test-equal (integer->char  97) #\x61)  ;; 97
(test-equal (integer->char  98) #\x62)  ;; 98
(test-equal (integer->char  99) #\x63)  ;; 99
(test-equal (integer->char 100) #\x64)  ;; 100
(test-equal (integer->char 101) #\x65)  ;; 101
(test-equal (integer->char 102) #\x66)  ;; 102
(test-equal (integer->char 103) #\x67)  ;; 103
(test-equal (integer->char 104) #\x68)  ;; 104
(test-equal (integer->char 105) #\x69)  ;; 105
(test-equal (integer->char 106) #\x6A)  ;; 106
(test-equal (integer->char 107) #\x6B)  ;; 107
(test-equal (integer->char 108) #\x6C)  ;; 108
(test-equal (integer->char 109) #\x6D)  ;; 109
(test-equal (integer->char 110) #\x6E)  ;; 110
(test-equal (integer->char 111) #\x6F)  ;; 111
(test-equal (integer->char 112) #\x70)  ;; 112
(test-equal (integer->char 113) #\x71)  ;; 113
(test-equal (integer->char 114) #\x72)  ;; 114
(test-equal (integer->char 115) #\x73)  ;; 115
(test-equal (integer->char 116) #\x74)  ;; 116
(test-equal (integer->char 117) #\x75)  ;; 117
(test-equal (integer->char 118) #\x76)  ;; 118
(test-equal (integer->char 119) #\x77)  ;; 119
(test-equal (integer->char 120) #\x78)  ;; 120
(test-equal (integer->char 121) #\x79)  ;; 121
(test-equal (integer->char 122) #\x7A)  ;; 122
(test-equal (integer->char 123) #\x7B)  ;; 123
(test-equal (integer->char 124) #\x7C)  ;; 124
(test-equal (integer->char 125) #\x7D)  ;; 125
(test-equal (integer->char 126) #\x7E)  ;; 126
(test-equal (integer->char 127) #\x7F)  ;; 127
(test-end "R6RS hexadecimal char literal (capitalized hexadecimal)")

;; char->integer
;; NOTE: #\x0e -style character is defined in R6RS(SRFI-75)
(test-begin "char->integer")
(test-equal   0 (char->integer #\nul))        ;; 0
(test-equal   1 (char->integer #\x01))        ;; 1
(test-equal   1 (char->integer #\x1))         ;; 1
(test-equal   2 (char->integer #\x02))        ;; 2
(test-equal   3 (char->integer #\x03))        ;; 3
(test-equal   4 (char->integer #\x04))        ;; 4
(test-equal   5 (char->integer #\x05))        ;; 5
(test-equal   6 (char->integer #\x06))        ;; 6
(test-equal   7 (char->integer #\alarm))      ;; 7
(test-equal   8 (char->integer #\backspace))  ;; 8
(test-equal   9 (char->integer #\tab))        ;; 9
(test-equal  10 (char->integer #\newline))    ;; 10
(test-equal  11 (char->integer #\vtab))       ;; 11
(test-equal  12 (char->integer #\page))       ;; 12
(test-equal  13 (char->integer #\return))     ;; 13
(test-equal  14 (char->integer #\x0e))        ;; 14
(test-equal  15 (char->integer #\x0f))        ;; 15
(test-equal  15 (char->integer #\xf))         ;; 15
(test-equal  16 (char->integer #\x10))        ;; 16
(test-equal  17 (char->integer #\x11))        ;; 17
(test-equal  18 (char->integer #\x12))        ;; 18
(test-equal  19 (char->integer #\x13))        ;; 19
(test-equal  20 (char->integer #\x14))        ;; 20
(test-equal  21 (char->integer #\x15))        ;; 21
(test-equal  22 (char->integer #\x16))        ;; 22
(test-equal  23 (char->integer #\x17))        ;; 23
(test-equal  24 (char->integer #\x18))        ;; 24
(test-equal  25 (char->integer #\x19))        ;; 25
(test-equal  26 (char->integer #\x1a))        ;; 26
(test-equal  27 (char->integer #\esc))        ;; 27
(test-equal  28 (char->integer #\x1c))        ;; 28
(test-equal  29 (char->integer #\x1d))        ;; 29
(test-equal  30 (char->integer #\x1e))        ;; 30
(test-equal  31 (char->integer #\x1f))        ;; 31
(test-equal  31 (char->integer #\x01f))       ;; 31
(test-equal  32 (char->integer #\space))      ;; 32
(test-equal  33 (char->integer #\!))          ;; 33
(test-equal  34 (char->integer #\"))          ;; 34
(test-equal  35 (char->integer #\#))          ;; 35
(test-equal  36 (char->integer #\$))          ;; 36
(test-equal  37 (char->integer #\%))          ;; 37
(test-equal  38 (char->integer #\&))          ;; 38
(test-equal  39 (char->integer #\'))          ;; 39
(test-equal  40 (char->integer #\())          ;; 40
(test-equal  41 (char->integer #\)))          ;; 41
(test-equal  42 (char->integer #\*))          ;; 42
(test-equal  43 (char->integer #\+))          ;; 43
(test-equal  44 (char->integer #\,))          ;; 44
(test-equal  45 (char->integer #\-))          ;; 45
(test-equal  46 (char->integer #\.))          ;; 46
(test-equal  47 (char->integer #\/))          ;; 47
(test-equal  48 (char->integer #\0))          ;; 48
(test-equal  49 (char->integer #\1))          ;; 49
(test-equal  50 (char->integer #\2))          ;; 50
(test-equal  51 (char->integer #\3))          ;; 51
(test-equal  52 (char->integer #\4))          ;; 52
(test-equal  53 (char->integer #\5))          ;; 53
(test-equal  54 (char->integer #\6))          ;; 54
(test-equal  55 (char->integer #\7))          ;; 55
(test-equal  56 (char->integer #\8))          ;; 56
(test-equal  57 (char->integer #\9))          ;; 57
(test-equal  58 (char->integer #\:))          ;; 58
(test-equal  59 (char->integer #\;))          ;; 59
(test-equal  60 (char->integer #\<))          ;; 60
(test-equal  61 (char->integer #\=))          ;; 61
(test-equal  62 (char->integer #\>))          ;; 62
(test-equal  63 (char->integer #\?))          ;; 63
(test-equal  64 (char->integer #\@))          ;; 64
(test-equal  65 (char->integer #\A))          ;; 65
(test-equal  66 (char->integer #\B))          ;; 66
(test-equal  67 (char->integer #\C))          ;; 67
(test-equal  68 (char->integer #\D))          ;; 68
(test-equal  69 (char->integer #\E))          ;; 69
(test-equal  70 (char->integer #\F))          ;; 70
(test-equal  71 (char->integer #\G))          ;; 71
(test-equal  72 (char->integer #\H))          ;; 72
(test-equal  73 (char->integer #\I))          ;; 73
(test-equal  74 (char->integer #\J))          ;; 74
(test-equal  75 (char->integer #\K))          ;; 75
(test-equal  76 (char->integer #\L))          ;; 76
(test-equal  77 (char->integer #\M))          ;; 77
(test-equal  78 (char->integer #\N))          ;; 78
(test-equal  79 (char->integer #\O))          ;; 79
(test-equal  80 (char->integer #\P))          ;; 80
(test-equal  81 (char->integer #\Q))          ;; 81
(test-equal  82 (char->integer #\R))          ;; 82
(test-equal  83 (char->integer #\S))          ;; 83
(test-equal  84 (char->integer #\T))          ;; 84
(test-equal  85 (char->integer #\U))          ;; 85
(test-equal  86 (char->integer #\V))          ;; 86
(test-equal  87 (char->integer #\W))          ;; 87
(test-equal  88 (char->integer #\X))          ;; 88
(test-equal  89 (char->integer #\Y))          ;; 89
(test-equal  90 (char->integer #\Z))          ;; 90
(test-equal  91 (char->integer #\[))          ;; 91
(test-equal  92 (char->integer #\\))          ;; 92
(test-equal  93 (char->integer #\]))          ;; 93
(test-equal  94 (char->integer #\^))          ;; 94
(test-equal  95 (char->integer #\_))          ;; 95
(test-equal  96 (char->integer #\`))          ;; 96
(test-equal  97 (char->integer #\a))          ;; 97
(test-equal  98 (char->integer #\b))          ;; 98
(test-equal  99 (char->integer #\c))          ;; 99
(test-equal 100 (char->integer #\d))          ;; 100
(test-equal 101 (char->integer #\e))          ;; 101
(test-equal 102 (char->integer #\f))          ;; 102
(test-equal 103 (char->integer #\g))          ;; 103
(test-equal 104 (char->integer #\h))          ;; 104
(test-equal 105 (char->integer #\i))          ;; 105
(test-equal 106 (char->integer #\j))          ;; 106
(test-equal 107 (char->integer #\k))          ;; 107
(test-equal 108 (char->integer #\l))          ;; 108
(test-equal 109 (char->integer #\m))          ;; 109
(test-equal 110 (char->integer #\n))          ;; 110
(test-equal 111 (char->integer #\o))          ;; 111
(test-equal 112 (char->integer #\p))          ;; 112
(test-equal 113 (char->integer #\q))          ;; 113
(test-equal 114 (char->integer #\r))          ;; 114
(test-equal 115 (char->integer #\s))          ;; 115
(test-equal 116 (char->integer #\t))          ;; 116
(test-equal 117 (char->integer #\u))          ;; 117
(test-equal 118 (char->integer #\v))          ;; 118
(test-equal 119 (char->integer #\w))          ;; 119
(test-equal 120 (char->integer #\x))          ;; 120
(test-equal 121 (char->integer #\y))          ;; 121
(test-equal 122 (char->integer #\z))          ;; 122
(test-equal 123 (char->integer #\{))          ;; 123
(test-equal 124 (char->integer #\|))          ;; 124
(test-equal 125 (char->integer #\}))          ;; 125
(test-equal 126 (char->integer #\~))          ;; 126
(test-equal 127 (char->integer #\delete))     ;; 127
(test-end "char->integer")
(test-begin "char->integer non-ASCII")
(test-equal #xa0   (char->integer #\xa0))   ;; NO-BREAK SPACE
(test-equal #xff   (char->integer #\xff))   ;; LATIN SMALL LETTER Y WITH DIAERESIS
(test-equal #x2028 (char->integer #\x2028)) ;; LINE SEPARATOR
(test-equal #x2029 (char->integer #\x2029)) ;; PARAGRAPH SEPARATOR
(test-equal #x3000 (char->integer #\　))    ;; IDEOGRAPHIC SPACE
(test-equal #x3042 (char->integer #\あ))    ;; HIRAGANA LETTER A
(test-equal #xff01 (char->integer #\！))    ;; FULLWIDTH EXCLAMATION MARK
(test-equal #xff10 (char->integer #\０))    ;; FULLWIDTH DIGIT ZERO
(test-equal #xff21 (char->integer #\Ａ))    ;; FULLWIDTH LATIN CAPITAL LETTER A
(test-equal #xff41 (char->integer #\ａ))    ;; FULLWIDTH LATIN SMALL LETTER A
(test-end "char->integer non-ASCII")

;; integer->char
;; NOTE: #\x0e -style character is defined in R6RS(SRFI-75)
(test-begin "integer->char")
(test-equal #\nul       (integer->char 0))    ;; 0
(test-equal #\x01       (integer->char 1))    ;; 1
(test-equal #\x1        (integer->char 1))    ;; 1
(test-equal #\x02       (integer->char 2))    ;; 2
(test-equal #\x03       (integer->char 3))    ;; 3
(test-equal #\x04       (integer->char 4))    ;; 4
(test-equal #\x05       (integer->char 5))    ;; 5
(test-equal #\x06       (integer->char 6))    ;; 6
(test-equal #\alarm     (integer->char 7))    ;; 7
(test-equal #\backspace (integer->char 8))    ;; 8
(test-equal #\tab       (integer->char 9))    ;; 9
(test-equal #\newline   (integer->char 10))   ;; 10
(test-equal #\vtab      (integer->char 11))   ;; 11
(test-equal #\page      (integer->char 12))   ;; 12
(test-equal #\return    (integer->char 13))   ;; 13
(test-equal #\x0e       (integer->char 14))   ;; 14
(test-equal #\x0f       (integer->char 15))   ;; 15
(test-equal #\xf        (integer->char 15))   ;; 15
(test-equal #\x10       (integer->char 16))   ;; 16
(test-equal #\x11       (integer->char 17))   ;; 17
(test-equal #\x12       (integer->char 18))   ;; 18
(test-equal #\x13       (integer->char 19))   ;; 19
(test-equal #\x14       (integer->char 20))   ;; 20
(test-equal #\x15       (integer->char 21))   ;; 21
(test-equal #\x16       (integer->char 22))   ;; 22
(test-equal #\x17       (integer->char 23))   ;; 23
(test-equal #\x18       (integer->char 24))   ;; 24
(test-equal #\x19       (integer->char 25))   ;; 25
(test-equal #\x1a       (integer->char 26))   ;; 26
(test-equal #\esc       (integer->char 27))   ;; 27
(test-equal #\x1c       (integer->char 28))   ;; 28
(test-equal #\x1d       (integer->char 29))   ;; 29
(test-equal #\x1e       (integer->char 30))   ;; 30
(test-equal #\x1f       (integer->char 31))   ;; 31
(test-equal #\x01f      (integer->char 31))   ;; 31
(test-equal #\space     (integer->char 32))   ;; 32
(test-equal #\!         (integer->char 33))   ;; 33
(test-equal #\"         (integer->char 34))   ;; 34
(test-equal #\#         (integer->char 35))   ;; 35
(test-equal #\$         (integer->char 36))   ;; 36
(test-equal #\%         (integer->char 37))   ;; 37
(test-equal #\&         (integer->char 38))   ;; 38
(test-equal #\'         (integer->char 39))   ;; 39
(test-equal #\(         (integer->char 40))   ;; 40
(test-equal #\)         (integer->char 41))   ;; 41
(test-equal #\*         (integer->char 42))   ;; 42
(test-equal #\+         (integer->char 43))   ;; 43
(test-equal #\,         (integer->char 44))   ;; 44
(test-equal #\-         (integer->char 45))   ;; 45
(test-equal #\.         (integer->char 46))   ;; 46
(test-equal #\/         (integer->char 47))   ;; 47
(test-equal #\0         (integer->char 48))   ;; 48
(test-equal #\1         (integer->char 49))   ;; 49
(test-equal #\2         (integer->char 50))   ;; 50
(test-equal #\3         (integer->char 51))   ;; 51
(test-equal #\4         (integer->char 52))   ;; 52
(test-equal #\5         (integer->char 53))   ;; 53
(test-equal #\6         (integer->char 54))   ;; 54
(test-equal #\7         (integer->char 55))   ;; 55
(test-equal #\8         (integer->char 56))   ;; 56
(test-equal #\9         (integer->char 57))   ;; 57
(test-equal #\:         (integer->char 58))   ;; 58
(test-equal #\;         (integer->char 59))   ;; 59
(test-equal #\<         (integer->char 60))   ;; 60
(test-equal #\=         (integer->char 61))   ;; 61
(test-equal #\>         (integer->char 62))   ;; 62
(test-equal #\?         (integer->char 63))   ;; 63
(test-equal #\@         (integer->char 64))   ;; 64
(test-equal #\A         (integer->char 65))   ;; 65
(test-equal #\B         (integer->char 66))   ;; 66
(test-equal #\C         (integer->char 67))   ;; 67
(test-equal #\D         (integer->char 68))   ;; 68
(test-equal #\E         (integer->char 69))   ;; 69
(test-equal #\F         (integer->char 70))   ;; 70
(test-equal #\G         (integer->char 71))   ;; 71
(test-equal #\H         (integer->char 72))   ;; 72
(test-equal #\I         (integer->char 73))   ;; 73
(test-equal #\J         (integer->char 74))   ;; 74
(test-equal #\K         (integer->char 75))   ;; 75
(test-equal #\L         (integer->char 76))   ;; 76
(test-equal #\M         (integer->char 77))   ;; 77
(test-equal #\N         (integer->char 78))   ;; 78
(test-equal #\O         (integer->char 79))   ;; 79
(test-equal #\P         (integer->char 80))   ;; 80
(test-equal #\Q         (integer->char 81))   ;; 81
(test-equal #\R         (integer->char 82))   ;; 82
(test-equal #\S         (integer->char 83))   ;; 83
(test-equal #\T         (integer->char 84))   ;; 84
(test-equal #\U         (integer->char 85))   ;; 85
(test-equal #\V         (integer->char 86))   ;; 86
(test-equal #\W         (integer->char 87))   ;; 87
(test-equal #\X         (integer->char 88))   ;; 88
(test-equal #\Y         (integer->char 89))   ;; 89
(test-equal #\Z         (integer->char 90))   ;; 90
(test-equal #\[         (integer->char 91))   ;; 91
(test-equal #\\         (integer->char 92))   ;; 92
(test-equal #\]         (integer->char 93))   ;; 93
(test-equal #\^         (integer->char 94))   ;; 94
(test-equal #\_         (integer->char 95))   ;; 95
(test-equal #\`         (integer->char 96))   ;; 96
(test-equal #\a         (integer->char 97))   ;; 97
(test-equal #\b         (integer->char 98))   ;; 98
(test-equal #\c         (integer->char 99))   ;; 99
(test-equal #\d         (integer->char 100))  ;; 100
(test-equal #\e         (integer->char 101))  ;; 101
(test-equal #\f         (integer->char 102))  ;; 102
(test-equal #\g         (integer->char 103))  ;; 103
(test-equal #\h         (integer->char 104))  ;; 104
(test-equal #\i         (integer->char 105))  ;; 105
(test-equal #\j         (integer->char 106))  ;; 106
(test-equal #\k         (integer->char 107))  ;; 107
(test-equal #\l         (integer->char 108))  ;; 108
(test-equal #\m         (integer->char 109))  ;; 109
(test-equal #\n         (integer->char 110))  ;; 110
(test-equal #\o         (integer->char 111))  ;; 111
(test-equal #\p         (integer->char 112))  ;; 112
(test-equal #\q         (integer->char 113))  ;; 113
(test-equal #\r         (integer->char 114))  ;; 114
(test-equal #\s         (integer->char 115))  ;; 115
(test-equal #\t         (integer->char 116))  ;; 116
(test-equal #\u         (integer->char 117))  ;; 117
(test-equal #\v         (integer->char 118))  ;; 118
(test-equal #\w         (integer->char 119))  ;; 119
(test-equal #\x         (integer->char 120))  ;; 120
(test-equal #\y         (integer->char 121))  ;; 121
(test-equal #\z         (integer->char 122))  ;; 122
(test-equal #\{         (integer->char 123))  ;; 123
(test-equal #\|         (integer->char 124))  ;; 124
(test-equal #\}         (integer->char 125))  ;; 125
(test-equal #\~         (integer->char 126))  ;; 126
(test-equal #\delete    (integer->char 127))  ;; 127
(test-end "integer->char")
(test-begin "integer->char non-ASCII")
(test-equal #\xa0   (integer->char #xa0))   ;; NO-BREAK SPACE
(test-equal #\xff   (integer->char #xff))   ;; LATIN SMALL LETTER Y WITH DIAERESIS
(test-equal #\x2028 (integer->char #x2028)) ;; LINE SEPARATOR
(test-equal #\x2029 (integer->char #x2029)) ;; PARAGRAPH SEPARATOR
(test-equal #\　    (integer->char #x3000)) ;; IDEOGRAPHIC SPACE
(test-equal #\あ    (integer->char #x3042)) ;; HIRAGANA LETTER A
(test-equal #\！    (integer->char #xff01)) ;; FULLWIDTH EXCLAMATION MARK
(test-equal #\０    (integer->char #xff10)) ;; FULLWIDTH DIGIT ZERO
(test-equal #\Ａ    (integer->char #xff21)) ;; FULLWIDTH LATIN CAPITAL LETTER A
(test-equal #\ａ    (integer->char #xff41)) ;; FULLWIDTH LATIN SMALL LETTER A
(test-end "integer->char non-ASCII")
(test-begin "integer->char invalid Unicode charcters")
(test-error (integer->char -1))
(test-assert (char?     (integer->char 0)))         ;; valid
(test-assert (char?     (integer->char #xd7ff)))    ;; valid
(test-error (integer->char #xd800))
(test-error (integer->char #xdfff))
(test-assert (char?     (integer->char #xe000)))    ;; valid
(test-assert (char?     (integer->char #x10ffff)))  ;; valid
(test-error (integer->char #x110000))
(test-end "integer->char invalid Unicode charcters")

(test-begin "integer->char (string form)")
(test-equal "#\\nul"       (i->chlit 0))    ;; 0
(test-equal "#\\x01"       (i->chlit 1))    ;; 1
(test-equal "#\\x02"       (i->chlit 2))    ;; 2
(test-equal "#\\x03"       (i->chlit 3))    ;; 3
(test-equal "#\\x04"       (i->chlit 4))    ;; 4
(test-equal "#\\x05"       (i->chlit 5))    ;; 5
(test-equal "#\\x06"       (i->chlit 6))    ;; 6
(test-equal "#\\alarm"     (i->chlit 7))    ;; 7
(test-equal "#\\backspace" (i->chlit 8))    ;; 8
(test-equal "#\\tab"       (i->chlit 9))    ;; 9
(test-equal "#\\newline"   (i->chlit 10))   ;; 10
(test-equal "#\\vtab"      (i->chlit 11))   ;; 11
(test-equal "#\\page"      (i->chlit 12))   ;; 12
(test-equal "#\\return"    (i->chlit 13))   ;; 13
(test-equal "#\\x0e"       (i->chlit 14))   ;; 14
(test-equal "#\\x0f"       (i->chlit 15))   ;; 15
(test-equal "#\\x10"       (i->chlit 16))   ;; 16
(test-equal "#\\x11"       (i->chlit 17))   ;; 17
(test-equal "#\\x12"       (i->chlit 18))   ;; 18
(test-equal "#\\x13"       (i->chlit 19))   ;; 19
(test-equal "#\\x14"       (i->chlit 20))   ;; 20
(test-equal "#\\x15"       (i->chlit 21))   ;; 21
(test-equal "#\\x16"       (i->chlit 22))   ;; 22
(test-equal "#\\x17"       (i->chlit 23))   ;; 23
(test-equal "#\\x18"       (i->chlit 24))   ;; 24
(test-equal "#\\x19"       (i->chlit 25))   ;; 25
(test-equal "#\\x1a"       (i->chlit 26))   ;; 26
(test-equal "#\\esc"       (i->chlit 27))   ;; 27
(test-equal "#\\x1c"       (i->chlit 28))   ;; 28
(test-equal "#\\x1d"       (i->chlit 29))   ;; 29
(test-equal "#\\x1e"       (i->chlit 30))   ;; 30
(test-equal "#\\x1f"       (i->chlit 31))   ;; 31
(test-equal "#\\space"     (i->chlit 32))   ;; 32
(test-equal "#\\!"         (i->chlit 33))   ;; 33
(test-equal "#\\\""        (i->chlit 34))   ;; 34
(test-equal "#\\#"         (i->chlit 35))   ;; 35
(test-equal "#\\$"         (i->chlit 36))   ;; 36
(test-equal "#\\%"         (i->chlit 37))   ;; 37
(test-equal "#\\&"         (i->chlit 38))   ;; 38
(test-equal "#\\'"         (i->chlit 39))   ;; 39
(test-equal "#\\("         (i->chlit 40))   ;; 40
(test-equal "#\\)"         (i->chlit 41))   ;; 41
(test-equal "#\\*"         (i->chlit 42))   ;; 42
(test-equal "#\\+"         (i->chlit 43))   ;; 43
(test-equal "#\\,"         (i->chlit 44))   ;; 44
(test-equal "#\\-"         (i->chlit 45))   ;; 45
(test-equal "#\\."         (i->chlit 46))   ;; 46
(test-equal "#\\/"         (i->chlit 47))   ;; 47
(test-equal "#\\0"         (i->chlit 48))   ;; 48
(test-equal "#\\1"         (i->chlit 49))   ;; 49
(test-equal "#\\2"         (i->chlit 50))   ;; 50
(test-equal "#\\3"         (i->chlit 51))   ;; 51
(test-equal "#\\4"         (i->chlit 52))   ;; 52
(test-equal "#\\5"         (i->chlit 53))   ;; 53
(test-equal "#\\6"         (i->chlit 54))   ;; 54
(test-equal "#\\7"         (i->chlit 55))   ;; 55
(test-equal "#\\8"         (i->chlit 56))   ;; 56
(test-equal "#\\9"         (i->chlit 57))   ;; 57
(test-equal "#\\:"         (i->chlit 58))   ;; 58
(test-equal "#\\;"         (i->chlit 59))   ;; 59
(test-equal "#\\<"         (i->chlit 60))   ;; 60
(test-equal "#\\="         (i->chlit 61))   ;; 61
(test-equal "#\\>"         (i->chlit 62))   ;; 62
(test-equal "#\\?"         (i->chlit 63))   ;; 63
(test-equal "#\\@"         (i->chlit 64))   ;; 64
(test-equal "#\\A"         (i->chlit 65))   ;; 65
(test-equal "#\\B"         (i->chlit 66))   ;; 66
(test-equal "#\\C"         (i->chlit 67))   ;; 67
(test-equal "#\\D"         (i->chlit 68))   ;; 68
(test-equal "#\\E"         (i->chlit 69))   ;; 69
(test-equal "#\\F"         (i->chlit 70))   ;; 70
(test-equal "#\\G"         (i->chlit 71))   ;; 71
(test-equal "#\\H"         (i->chlit 72))   ;; 72
(test-equal "#\\I"         (i->chlit 73))   ;; 73
(test-equal "#\\J"         (i->chlit 74))   ;; 74
(test-equal "#\\K"         (i->chlit 75))   ;; 75
(test-equal "#\\L"         (i->chlit 76))   ;; 76
(test-equal "#\\M"         (i->chlit 77))   ;; 77
(test-equal "#\\N"         (i->chlit 78))   ;; 78
(test-equal "#\\O"         (i->chlit 79))   ;; 79
(test-equal "#\\P"         (i->chlit 80))   ;; 80
(test-equal "#\\Q"         (i->chlit 81))   ;; 81
(test-equal "#\\R"         (i->chlit 82))   ;; 82
(test-equal "#\\S"         (i->chlit 83))   ;; 83
(test-equal "#\\T"         (i->chlit 84))   ;; 84
(test-equal "#\\U"         (i->chlit 85))   ;; 85
(test-equal "#\\V"         (i->chlit 86))   ;; 86
(test-equal "#\\W"         (i->chlit 87))   ;; 87
(test-equal "#\\X"         (i->chlit 88))   ;; 88
(test-equal "#\\Y"         (i->chlit 89))   ;; 89
(test-equal "#\\Z"         (i->chlit 90))   ;; 90
(test-equal "#\\["         (i->chlit 91))   ;; 91
(test-equal "#\\\\"        (i->chlit 92))   ;; 92
(test-equal "#\\]"         (i->chlit 93))   ;; 93
(test-equal "#\\^"         (i->chlit 94))   ;; 94
(test-equal "#\\_"         (i->chlit 95))   ;; 95
(test-equal "#\\`"         (i->chlit 96))   ;; 96
(test-equal "#\\a"         (i->chlit 97))   ;; 97
(test-equal "#\\b"         (i->chlit 98))   ;; 98
(test-equal "#\\c"         (i->chlit 99))   ;; 99
(test-equal "#\\d"         (i->chlit 100))  ;; 100
(test-equal "#\\e"         (i->chlit 101))  ;; 101
(test-equal "#\\f"         (i->chlit 102))  ;; 102
(test-equal "#\\g"         (i->chlit 103))  ;; 103
(test-equal "#\\h"         (i->chlit 104))  ;; 104
(test-equal "#\\i"         (i->chlit 105))  ;; 105
(test-equal "#\\j"         (i->chlit 106))  ;; 106
(test-equal "#\\k"         (i->chlit 107))  ;; 107
(test-equal "#\\l"         (i->chlit 108))  ;; 108
(test-equal "#\\m"         (i->chlit 109))  ;; 109
(test-equal "#\\n"         (i->chlit 110))  ;; 110
(test-equal "#\\o"         (i->chlit 111))  ;; 111
(test-equal "#\\p"         (i->chlit 112))  ;; 112
(test-equal "#\\q"         (i->chlit 113))  ;; 113
(test-equal "#\\r"         (i->chlit 114))  ;; 114
(test-equal "#\\s"         (i->chlit 115))  ;; 115
(test-equal "#\\t"         (i->chlit 116))  ;; 116
(test-equal "#\\u"         (i->chlit 117))  ;; 117
(test-equal "#\\v"         (i->chlit 118))  ;; 118
(test-equal "#\\w"         (i->chlit 119))  ;; 119
(test-equal "#\\x"         (i->chlit 120))  ;; 120
(test-equal "#\\y"         (i->chlit 121))  ;; 121
(test-equal "#\\z"         (i->chlit 122))  ;; 122
(test-equal "#\\{"         (i->chlit 123))  ;; 123
(test-equal "#\\|"         (i->chlit 124))  ;; 124
(test-equal "#\\}"         (i->chlit 125))  ;; 125
(test-equal "#\\~"         (i->chlit 126))  ;; 126
(test-equal "#\\delete"    (i->chlit 127))  ;; 127
(test-end "integer->char (string form)")
(test-begin "integer->char non-ASCII (string form)")
(test-equal "#\\ÿ"         (i->chlit #xff))   ;; LATIN SMALL LETTER Y WITH DIAERESIS
(test-equal "#\\　"        (i->chlit #x3000)) ;; IDEOGRAPHIC SPACE
(test-equal "#\\あ"        (i->chlit #x3042)) ;; HIRAGANA LETTER A
(test-equal "#\\！"        (i->chlit #xff01)) ;; FULLWIDTH EXCLAMATION MARK
(test-equal "#\\０"        (i->chlit #xff10)) ;; FULLWIDTH DIGIT ZERO
(test-equal "#\\Ａ"        (i->chlit #xff21)) ;; FULLWIDTH LATIN CAPITAL LETTER A
(test-equal "#\\ａ"        (i->chlit #xff41)) ;; FULLWIDTH LATIN SMALL LETTER A
(test-end "integer->char non-ASCII (string form)")

(test-end "test-char")
