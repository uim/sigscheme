#! /usr/bin/env sscm -C UTF-8
;; -*- buffer-file-coding-system: utf-8 -*-

;;  Filename : test-symbol.scm
;;  About    : unit tests for symbols
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

;; See also test-syntax.scm for valid identifiers based on "7.1 Formal syntax"
;; of R5RS.

(require-extension (srfi 64))

(if (not (provided? "r6rs-chars"))
    (test-skip-file "R6RS characters is not enabled"))

(test-begin "test-symbol")

(test-begin "symbol comparisons")
(test-assert (eq? 'symbol 'symbol))
(test-assert (eq? 'SYMBOL 'SYMBOL))
(test-assert (eq? 'syMBol 'syMBol))
(if (provided? "sigscheme")
    (begin
      ;; SigScheme distinguishes case of identifiers.
      (test-assert (not (eq? 'symbol 'SYMBOL)))
      (test-assert (not (eq? 'symbol 'syMBol)))
      (test-assert (not (eq? 'SYMBOL 'syMBol))))
    (begin
      ;; R5RS-conformant implementations normalize the cases.
      (test-assert (eq? 'symbol 'SYMBOL))
      (test-assert (eq? 'symbol 'syMBol))
      (test-assert (eq? 'SYMBOL 'syMBol))))
(test-assert (eq? '日本語シンボル '日本語シンボル))
(test-assert (not (eq? '日本語しんぼる '日本語シンボル)))
(test-assert (not (eq? 'sym1 'sym2)))
(test-assert (not (eq? 'sym 'mys)))
(test-assert (not (eq? 'sym 'symb)))
(test-end "symbol comparisons")

(test-begin "case normalization of literal symbols")
(test-assert (eq? 'symbol
                  (string->symbol (symbol->string 'symbol))))
(test-assert (eq? 'SYMBOL
                  (string->symbol (symbol->string 'SYMBOL))))
(test-assert (eq? 'syMBol
                  (string->symbol (symbol->string 'syMBol))))
(if (provided? "sigscheme")
    (begin
      ;; SigScheme distinguishes case of identifiers.
      (test-assert (not (eq? 'symbol
                             (string->symbol (symbol->string 'SYMBOL)))))
      (test-assert (not (eq? 'symbol
                             (string->symbol (symbol->string 'syMBol)))))
      (test-assert (not (eq? 'SYMBOL
                             (string->symbol (symbol->string 'symbol)))))
      (test-assert (not (eq? 'SYMBOL
                             (string->symbol (symbol->string 'syMBol)))))
      (test-assert (not (eq? 'syMBol
                             (string->symbol (symbol->string 'symbol)))))
      (test-assert (not (eq? 'syMBol
                             (string->symbol (symbol->string 'SYMBOL))))))
    (begin
      ;; R5RS-conformant implementations normalize the cases.
      (test-assert (not (eq? 'symbol
                             (string->symbol (symbol->string 'SYMBOL)))))
      (test-assert (not (eq? 'symbol
                             (string->symbol (symbol->string 'syMBol)))))
      (test-assert (not (eq? 'SYMBOL
                             (string->symbol (symbol->string 'symbol)))))
      (test-assert (not (eq? 'SYMBOL
                             (string->symbol (symbol->string 'syMBol)))))
      (test-assert (not (eq? 'syMBol
                             (string->symbol (symbol->string 'symbol)))))
      (test-assert (not (eq? 'syMBol
                             (string->symbol (symbol->string 'SYMBOL)))))))
(test-end "case normalization of literal symbols")

(test-begin "case preservation of non-literal symbols")
(test-assert (string=? "symbol"
                       (symbol->string (string->symbol "symbol"))))
(test-assert (string=? "SYMBOL"
                       (symbol->string (string->symbol "SYMBOL"))))
(test-assert (string=? "syMBol"
                       (symbol->string (string->symbol "syMBol"))))
(test-assert (string=? "Yes, this is a valid symbol."
                       (symbol->string (string->symbol "Yes, this is a valid symbol."))))
(test-end "case preservation of non-literal symbols")

;;
;; symbol?
;;

(test-begin "symbol?")
(test-eq #f (symbol? #f))
(test-eq #f (symbol? #t))
(test-eq #f (symbol? '#f))
(test-eq #f (symbol? '#t))
(test-eq #f (symbol? '()))
(if (provided? "sigscheme")
    (begin
      (test-eq #f (symbol? (eof)))
      (test-eq #f (symbol? (undef)))))
(test-eq #f (symbol? 0))
(test-eq #f (symbol? 1))
(test-eq #f (symbol? 3))
(test-eq #f (symbol? -1))
(test-eq #f (symbol? -3))
(test-eq #t (symbol? 'symbol))
(test-eq #t (symbol? 'SYMBOL))
(if (and (provided? "sigscheme")
         (provided? "utf-8"))
    (test-eq #t (symbol? (string-read "日本語シンボル"))))
(let ((s 'symbol))
  (test-eq #t (symbol? s)))
(test-eq #t (symbol? (car '(a b))))
(test-eq #f (symbol? #\a))
(test-eq #f (symbol? #\あ))
(test-eq #f (symbol? ""))
(test-eq #f (symbol? " "))
(test-eq #f (symbol? "a"))
(test-eq #f (symbol? "A"))
(test-eq #f (symbol? "aBc12!"))
(test-eq #f (symbol? "あ"))
(test-eq #f (symbol? "あ0イう12!"))
(test-eq #f (symbol? +))
(test-eq #f (symbol? (lambda () #t)))

;; syntactic keywords should not be appeared as operand
(if sigscheme?
    (begin
      ;; pure syntactic keyword
      (test-error (symbol? else))
      ;; expression keyword
      (test-argcheck-error (symbol? do))))

(call-with-current-continuation
 (lambda (k)
   (test-eq #f (symbol? k))))
(test-eq #f (symbol? (current-output-port)))
(test-eq #f (symbol? '(#t . #t)))
(test-eq #f (symbol? (cons #t #t)))
(test-eq #f (symbol? '(0 1 2)))
(test-eq #f (symbol? (list 0 1 2)))
(test-eq #f (symbol? '#()))
(test-eq #f (symbol? (vector)))
(test-eq #f (symbol? '#(0 1 2)))
(test-eq #f (symbol? (vector 0 1 2)))
(test-end "symbol?")


;;
;; symbol->string
;;

(test-begin "symbol->string")
(test-equal "symbol" (symbol->string 'symbol))
(if (provided? "sigscheme")
    (begin
      ;; SigScheme distinguishes case of identifiers and so does not conforms
      ;; to R5RS.
      (test-equal "symbol" (symbol->string 'symbol))
      (test-equal "SYMBOL" (symbol->string 'SYMBOL))
      (test-equal "syMBol" (symbol->string 'syMBol)))
    ;; R5RS-conformant implementations normalize the cases of LITERAL symbols
    ;; to implementation-specific ones. Non-literal symbols is not (see
    ;; the string->symbol tests).
    (if (string-equal? "a" (symbol->string "A"))
        (begin
          (test-equal "symbol" (symbol->string 'symbol))
          (test-equal "symbol" (symbol->string 'SYMBOL))
          (test-equal "symbol" (symbol->string 'syMBol)))
        (begin
          (test-equal "SYMBOL" (symbol->string 'symbol))
          (test-equal "SYMBOL" (symbol->string 'SYMBOL))
          (test-equal "SYMBOL" (symbol->string 'syMBol)))))
(test-end "symbol->string")

(test-begin "symbol->string special initial identifier")
(test-equal "!" (symbol->string '!))
(test-equal "$" (symbol->string '$))
(test-equal "%" (symbol->string '%))
(test-equal "&" (symbol->string '&))
(test-equal "*" (symbol->string '*))
(test-equal "/" (symbol->string '/))
(test-equal ":" (symbol->string ':))
(test-equal "<" (symbol->string '<))
(test-equal "=" (symbol->string '=))
(test-equal ">" (symbol->string '>))
(test-equal "?" (symbol->string '?))
(test-equal "^" (symbol->string '^))
(test-equal "_" (symbol->string '_))
(test-equal "~" (symbol->string '~))
(test-end "symbol->string special initial identifier")

(test-begin "symbol->string special initial identifier + number")
(test-equal "!1" (symbol->string '!1))
(test-equal "$1" (symbol->string '$1))
(test-equal "%1" (symbol->string '%1))
(test-equal "&1" (symbol->string '&1))
(test-equal "*1" (symbol->string '*1))
(test-equal "/1" (symbol->string '/1))
(test-equal ":1" (symbol->string ':1))
(test-equal "<1" (symbol->string '<1))
(test-equal "=1" (symbol->string '=1))
(test-equal ">1" (symbol->string '>1))
(test-equal "?1" (symbol->string '?1))
(test-equal "^1" (symbol->string '^1))
(test-equal "_1" (symbol->string '_1))
(test-equal "~1" (symbol->string '~1))
(test-end "symbol->string special initial identifier + number")

(test-begin "symbol->string special initial identifier + letter")
(test-equal "!a" (symbol->string '!a))
(test-equal "$a" (symbol->string '$a))
(test-equal "%a" (symbol->string '%a))
(test-equal "&a" (symbol->string '&a))
(test-equal "*a" (symbol->string '*a))
(test-equal "/a" (symbol->string '/a))
(test-equal ":a" (symbol->string ':a))
(test-equal "<a" (symbol->string '<a))
(test-equal "=a" (symbol->string '=a))
(test-equal ">a" (symbol->string '>a))
(test-equal "?a" (symbol->string '?a))
(test-equal "^a" (symbol->string '^a))
(test-equal "_a" (symbol->string '_a))
(test-equal "~a" (symbol->string '~a))
(test-end "symbol->string special initial identifier + letter")

(test-begin "symbol->string identifiers")
(test-equal "..." (symbol->string '...))
(test-equal "+"   (symbol->string '+))
(test-equal "-"   (symbol->string '-))
(test-equal "a."  (symbol->string 'a.))
(test-equal "a+"  (symbol->string 'a+))
(test-equal "a-"  (symbol->string 'a-))
(test-equal "a@"  (symbol->string 'a@))
(test-equal "a1"  (symbol->string 'a1))
;; SigScheme 0.7.0 and later disallows initial hyphen of an identifier. Use
;; string->symbol to acquire identifiers that beginning with hypen.
(if sigscheme?
    (begin
      (test-error (symbol? (string-read "(symbol->string '-a)")))
      (test-equal "-a" (symbol->string (string->symbol "-a")))))
(test-end "symbol->string identifiers")

;;
;; string->symbol
;;

(test-begin "string->symbol")
(if (provided? "sigscheme")
    (begin
      (test-assert (eq? 'symbol (string->symbol "symbol")))
      (test-assert (eq? 'SYMBOL (string->symbol "SYMBOL")))
      (test-assert (eq? 'syMBol (string->symbol "syMBol"))))
    (begin
      (if (string-equal? "a" (symbol->string "A"))
          (begin
            (test-assert (eq? 'symbol (string->symbol "symbol")))
            (test-assert (not (eq? 'SYMBOL (string->symbol "SYMBOL")))))
          (begin
            (test-assert (not (eq? 'symbol (string->symbol "symbol"))))
            (test-assert (eq? 'SYMBOL (string->symbol "SYMBOL")))))
      ;; Literal symbols (e.g. 'syMBol) is normalized in R5RS-conformant
      ;; implementations, but symbols that created by string->symbol is not
      ;; (i.e. returns 'syMBol).
      (test-assert (not (eq? 'syMBol (string->symbol "syMBol"))))))
(test-assert (eq? '日本語シンボル (string->symbol "日本語シンボル")))
(test-end "string->symbol")

(test-begin "string->symbol non-literal symbols")
(test-assert (symbol? (string->symbol "")))
(test-assert (symbol? (string->symbol "Yes, this is a valid symbol.")))

(test-assert (symbol? (string->symbol "#f")))
(test-assert (symbol? (string->symbol "#t")))
(test-assert (symbol? (string->symbol "()")))
(test-assert (symbol? (string->symbol "0")))
(test-assert (symbol? (string->symbol "1")))
(test-assert (symbol? (string->symbol "3")))
(test-assert (symbol? (string->symbol "-1")))
(test-assert (symbol? (string->symbol "-3")))
(test-assert (symbol? (string->symbol "#\\a")))
(test-assert (symbol? (string->symbol "#\\あ")))
(test-assert (symbol? (string->symbol "\"\"")))
(test-assert (symbol? (string->symbol "\" \"")))
(test-assert (symbol? (string->symbol "\"a\"")))
(test-assert (symbol? (string->symbol "\"A\"")))
(test-assert (symbol? (string->symbol "\"aBc12!\"")))
(test-assert (symbol? (string->symbol "\"あ\"")))
(test-assert (symbol? (string->symbol "\"あ0イう12!\"")))
(test-assert (symbol? (string->symbol "+")))
(test-assert (symbol? (string->symbol "(lambda () #t)")))
(test-assert (symbol? (string->symbol "(#t . #t)")))
(test-assert (symbol? (string->symbol "(0 1 2)")))
(test-assert (symbol? (string->symbol "#()")))
(test-assert (symbol? (string->symbol "#(0 1 2)")))

(test-assert (symbol? (string->symbol "#")))
(test-assert (symbol? (string->symbol ".")))
(test-assert (symbol? (string->symbol "..")))
(test-assert (symbol? (string->symbol "....")))
(test-assert (symbol? (string->symbol ".a")))
(test-assert (symbol? (string->symbol "+a")))
(test-assert (symbol? (string->symbol "++")))
(test-assert (symbol? (string->symbol "--")))
(test-assert (symbol? (string->symbol "-=")))
(test-assert (symbol? (string->symbol "-$")))
(test-assert (symbol? (string->symbol "-.")))
(test-assert (symbol? (string->symbol "-@")))
(test-assert (symbol? (string->symbol "@")))
(test-assert (symbol? (string->symbol "1a")))
(test-assert (symbol? (string->symbol "-a")))

(test-assert (symbol? (string->symbol ";")))
(test-assert (symbol? (string->symbol "'")))
(test-assert (symbol? (string->symbol "`")))
(test-assert (symbol? (string->symbol ",")))
(test-assert (symbol? (string->symbol ",@")))
(test-assert (symbol? (string->symbol "\"")))
(test-assert (symbol? (string->symbol "\\")))
(test-assert (symbol? (string->symbol "(")))
(test-assert (symbol? (string->symbol ")")))
(test-assert (symbol? (string->symbol "[")))
(test-assert (symbol? (string->symbol "]")))
(test-assert (symbol? (string->symbol "{")))
(test-assert (symbol? (string->symbol "}")))
(test-assert (symbol? (string->symbol "|")))
(test-end "string->symbol non-literal symbols")


(test-end "test-symbol")
