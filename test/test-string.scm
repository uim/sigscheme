;;  Filename : test-string.scm
;;  About    : unit test for R5RS string
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

;; See also test-string-{core,null,pred,proc}.scm

(require-extension (srfi 64))

(if (not (symbol-bound? 'string?))
    (test-skip-file "R5RS strings is not enabled"))

(if (not (provided? "r6rs-chars"))
    (test-skip-file "R6RS characters is not enabled"))

(test-begin "test-string")
(define cp string-copy)

(if (and (provided? "sigscheme")
         (not (symbol-bound? 'make-string)))
    (test-skip-file "string part of R5RS is not enabled"))

(test-begin "symbol->string")
(test-equal "a"  (symbol->string 'a))
(test-equal "ab" (symbol->string 'ab))
(test-end "symbol->string")

;; TODO: need to investigate (string->symbol "") behavior
(test-begin "string->symbol immutable")
(test-equal 'a  (string->symbol "a"))
(test-equal 'ab (string->symbol "ab"))
(test-end "string->symbol immutable")
(test-begin "string->symbol mutable")
(test-equal 'a  (string->symbol (cp "a")))
(test-equal 'ab (string->symbol (cp "ab")))
(test-end "string->symbol mutable")

;;
;; escape sequences
;;

(define integer->string
  (lambda (i)
    (list->string (list (integer->char i)))))

;; R5RS compliant
(test-begin "R5RS escape sequence")
(test-equal (integer->string 34)        "\"")  ;; 34
(test-equal (list->string '(#\"))       "\"")  ;; 34
(test-equal '(#\")       (string->list "\""))  ;; 34
(test-equal (integer->string 92)        "\\")  ;; 92
(test-equal (list->string '(#\\))       "\\")  ;; 92
(test-equal '(#\\)       (string->list "\\"))  ;; 92
(test-equal (integer->string 10)        "\n")  ;; 110
(test-equal (list->string '(#\newline)) "\n")  ;; 110
(test-equal '(#\newline) (string->list "\n"))  ;; 110
(test-end "R5RS escape sequence")

;; R6RS(SRFI-75) compliant
(test-begin "R6RS escape sequence")
;; See also test-string-null.scm for "\x00" tests
(test-equal (integer->string 7)           "\a")  ;; 97
(test-equal (list->string '(#\alarm))     "\a")  ;; 97
(test-equal '(#\alarm)  (string->list    "\a"))  ;; 97
(test-equal (integer->string 8)           "\b")  ;; 98
(test-equal (list->string '(#\backspace)) "\b")  ;; 98
(test-equal '(#\backspace) (string->list "\b"))  ;; 98
(test-equal (integer->string 12)          "\f")  ;; 102
(test-equal (list->string '(#\page))      "\f")  ;; 102
(test-equal '(#\page)   (string->list    "\f"))  ;; 102
(test-equal (integer->string 13)          "\r")  ;; 114
(test-equal (list->string '(#\return))    "\r")  ;; 114
(test-equal '(#\return) (string->list    "\r"))  ;; 114
(test-equal (integer->string 9)           "\t")  ;; 116
(test-equal (list->string '(#\tab))       "\t")  ;; 116
(test-equal '(#\tab)    (string->list    "\t"))  ;; 116
(test-equal (integer->string 11)          "\v")  ;; 118
(test-equal (list->string '(#\vtab))      "\v")  ;; 118
(test-equal '(#\vtab)   (string->list    "\v"))  ;; 118
(test-end "R6RS escape sequence")
;; "\|" is removed from final R6RS
;;(test-error (integer->string 124)         "\|")  ;; 124

;; All these conventional escape sequences should cause parse error as defined
;; in SRFI-75: "Any other character in a string after a backslash is an
;; error".
(test-begin "conventional escape sequence")
;;                            "\0"   ;; 0
(test-error (string-read "\"\\ \""))  ;; 32
(test-error (string-read "\"\\!\""))  ;; 33
;;                            "\""   ;; 34
(test-error (string-read "\"\\#\""))  ;; 35
(test-error (string-read "\"\\$\""))  ;; 36
(test-error (string-read "\"\\%\""))  ;; 37
(test-error (string-read "\"\\&\""))  ;; 38
(test-error (string-read "\"\\'\""))  ;; 39
(test-error (string-read "\"\\(\""))  ;; 40
(test-error (string-read "\"\\)\""))  ;; 41
(test-error (string-read "\"\\*\""))  ;; 42
(test-error (string-read "\"\\+\""))  ;; 43
(test-error (string-read "\"\\,\""))  ;; 44
(test-error (string-read "\"\\-\""))  ;; 45
(test-error (string-read "\"\\.\""))  ;; 46
(test-error (string-read "\"\\/\""))  ;; 47
(test-error (string-read "\"\\0\""))  ;; 48
(test-error (string-read "\"\\1\""))  ;; 49
(test-error (string-read "\"\\2\""))  ;; 50
(test-error (string-read "\"\\3\""))  ;; 51
(test-error (string-read "\"\\4\""))  ;; 52
(test-error (string-read "\"\\5\""))  ;; 53
(test-error (string-read "\"\\6\""))  ;; 54
(test-error (string-read "\"\\7\""))  ;; 55
(test-error (string-read "\"\\8\""))  ;; 56
(test-error (string-read "\"\\9\""))  ;; 57
(test-error (string-read "\"\\:\""))  ;; 58
(test-error (string-read "\"\\;\""))  ;; 59
(test-error (string-read "\"\\<\""))  ;; 60
(test-error (string-read "\"\\=\""))  ;; 61
(test-error (string-read "\"\\>\""))  ;; 62
(test-error (string-read "\"\\?\""))  ;; 63
(test-error (string-read "\"\\@\""))  ;; 64
(test-error (string-read "\"\\A\""))  ;; 65
(test-error (string-read "\"\\B\""))  ;; 66
(test-error (string-read "\"\\C\""))  ;; 67
(test-error (string-read "\"\\D\""))  ;; 68
(test-error (string-read "\"\\E\""))  ;; 69
(test-error (string-read "\"\\F\""))  ;; 70
(test-error (string-read "\"\\G\""))  ;; 71
(test-error (string-read "\"\\H\""))  ;; 72
(test-error (string-read "\"\\I\""))  ;; 73
(test-error (string-read "\"\\J\""))  ;; 74
(test-error (string-read "\"\\K\""))  ;; 75
(test-error (string-read "\"\\L\""))  ;; 76
(test-error (string-read "\"\\M\""))  ;; 77
(test-error (string-read "\"\\N\""))  ;; 78
(test-error (string-read "\"\\O\""))  ;; 79
(test-error (string-read "\"\\P\""))  ;; 80
(test-error (string-read "\"\\Q\""))  ;; 81
(test-error (string-read "\"\\R\""))  ;; 82
(test-error (string-read "\"\\S\""))  ;; 83
(test-error (string-read "\"\\T\""))  ;; 84
(test-error (string-read "\"\\U\""))  ;; 85
(test-error (string-read "\"\\V\""))  ;; 86
(test-error (string-read "\"\\W\""))  ;; 87
(test-error (string-read "\"\\X\""))  ;; 88
(test-error (string-read "\"\\Y\""))  ;; 89
(test-error (string-read "\"\\Z\""))  ;; 90
(test-error (string-read "\"\\[\""))  ;; 91
;;                            "\\"   ;; 92
(test-error (string-read "\"\\]\""))  ;; 93
(test-error (string-read "\"\\^\""))  ;; 94
(test-error (string-read "\"\\_\""))  ;; 95
(test-error (string-read "\"\\`\""))  ;; 96
;;                            "\a"   ;; 97
;;                            "\b"   ;; 98
(test-error (string-read "\"\\c\""))  ;; 99
(test-error (string-read "\"\\d\""))  ;; 100
(test-error (string-read "\"\\e\""))  ;; 101
;;                            "\f"   ;; 102
(test-error (string-read "\"\\g\""))  ;; 103
(test-error (string-read "\"\\h\""))  ;; 104
(test-error (string-read "\"\\i\""))  ;; 105
(test-error (string-read "\"\\j\""))  ;; 106
(test-error (string-read "\"\\k\""))  ;; 107
(test-error (string-read "\"\\l\""))  ;; 108
(test-error (string-read "\"\\m\""))  ;; 109
;;                            "\n"   ;; 110
(test-error (string-read "\"\\o\""))  ;; 111
(test-error (string-read "\"\\p\""))  ;; 112
(test-error (string-read "\"\\q\""))  ;; 113
;;                            "\r"   ;; 114
(test-error (string-read "\"\\s\""))  ;; 115
;;                            "\t"   ;; 116
(test-error (string-read "\"\\u\""))  ;; 117
;;                            "\v"   ;; 118
(test-error (string-read "\"\\w\""))  ;; 119
(test-error (string-read "\"\\x\""))  ;; 120
(test-error (string-read "\"\\y\""))  ;; 121
(test-error (string-read "\"\\z\""))  ;; 122
(test-error (string-read "\"\\{\""))  ;; 123
;; "\|" is removed from final R6RS
;; R7RS allows \|.
(if (not (provided? "r7rs"))
    (test-error (string-read "\"\\|\""))  ;; 124
    )
(test-error (string-read "\"\\}\""))  ;; 125
(test-error (string-read "\"\\~\""))  ;; 126
(test-end "conventional escape sequence")

;; raw control chars
(test-begin "raw control char in string literal")
;; See also test-string-null.scm for " " (charcode 0) test
(test-equal (integer->string   1) "")  ;; 1
(test-equal (integer->string   2) "")  ;; 2
(test-equal (integer->string   3) "")  ;; 3
(test-equal (integer->string   4) "")  ;; 4
(test-equal (integer->string   5) "")  ;; 5
(test-equal (integer->string   6) "")  ;; 6
(test-equal (integer->string   7) "")  ;; 7
(test-equal (integer->string   8) "")  ;; 8  ;; DON'T EDIT THIS LINE!
(test-equal (integer->string   9) "	")  ;; 9
(test-equal (integer->string  10) "
")  ;; 10 ;; DON'T EDIT THIS LINE!
(test-equal (integer->string  11) "")  ;; 11
(test-equal (integer->string  12) "")  ;; 12
(test-equal (integer->string  13) "")  ;; 13 ;; DON'T EDIT THIS LINE!
(test-equal (integer->string  14) "")  ;; 14
(test-equal (integer->string  15) "")  ;; 15
(test-equal (integer->string  16) "")  ;; 16
(test-equal (integer->string  17) "")  ;; 17
(test-equal (integer->string  18) "")  ;; 18
(test-equal (integer->string  19) "")  ;; 19
(test-equal (integer->string  20) "")  ;; 20
(test-equal (integer->string  21) "")  ;; 21
(test-equal (integer->string  22) "")  ;; 22
(test-equal (integer->string  23) "")  ;; 23
(test-equal (integer->string  24) "")  ;; 24
(test-equal (integer->string  25) "")  ;; 25 ;; DON'T EDIT THIS LINE!
(test-equal (integer->string  26) "")  ;; 26
(test-equal (integer->string  27) "")  ;; 27
(test-equal (integer->string  28) "")  ;; 28
(test-equal (integer->string  29) "")  ;; 29
(test-equal (integer->string  30) "")  ;; 30
(test-equal (integer->string  31) "")  ;; 31
(test-equal (integer->string 127) "")  ;; 127
(test-end "raw control char in string literal")

;; escaped raw control chars
(test-begin "escaped raw control char in string literal")
;; See also test-string-null.scm for " " (charcode 0) test
(test-error (string-read "\"\\\""))  ;; 1
(test-error (string-read "\"\\\""))  ;; 2
(test-error (string-read "\"\\\""))  ;; 3
(test-error (string-read "\"\\\""))  ;; 4
(test-error (string-read "\"\\\""))  ;; 5
(test-error (string-read "\"\\\""))  ;; 6
(test-error (string-read "\"\\\""))  ;; 7
(test-error (string-read "\"\\\""))  ;; 8  ;; DON'T EDIT THIS LINE!
(test-error (string-read "\"\\	\""))  ;; 9
;; R7RS allows a line continuation.
(if (not (provided? "r7rs"))
    (test-error (string-read "\"\\
\""))  ;; 10  ;; DON'T EDIT THIS LINE!
    )
(test-error (string-read "\"\\\""))  ;; 11
(test-error (string-read "\"\\\""))  ;; 12
(if (not (provided? "r7rs"))
    (test-error (string-read "\"\\\""))  ;; 13  ;; DON'T EDIT THIS LINE!
    )
(test-error (string-read "\"\\\""))  ;; 14
(test-error (string-read "\"\\\""))  ;; 15
(test-error (string-read "\"\\\""))  ;; 16
(test-error (string-read "\"\\\""))  ;; 17
(test-error (string-read "\"\\\""))  ;; 18
(test-error (string-read "\"\\\""))  ;; 19
(test-error (string-read "\"\\\""))  ;; 20
(test-error (string-read "\"\\\""))  ;; 21
(test-error (string-read "\"\\\""))  ;; 22
(test-error (string-read "\"\\\""))  ;; 23
(test-error (string-read "\"\\\""))  ;; 24
(test-error (string-read "\"\\\""))  ;; 25  ;; DON'T EDIT THIS LINE!
(test-error (string-read "\"\\\""))  ;; 26
(test-error (string-read "\"\\\""))  ;; 27
(test-error (string-read "\"\\\""))  ;; 28
(test-error (string-read "\"\\\""))  ;; 29
(test-error (string-read "\"\\\""))  ;; 30
(test-error (string-read "\"\\\""))  ;; 31
(test-error (string-read "\"\\\""))  ;; 127
(test-end "escaped raw control char in string literal")

(test-end "test-string")
