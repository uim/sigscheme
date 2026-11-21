#! /usr/bin/env sscm -C Shift_JIS
;; -*- buffer-file-coding-system: shift_jisx0213 -*-
;; C-x RET c shift_jisx0213 C-x C-f test-enc-sjis.scm

;;  Filename : test-enc-sjis.scm
;;  About    : unit test for SJIS string
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

(if (not (and (provided? "shift-jis")
              (symbol-bound? 'char?)
              (symbol-bound? 'string?)))
    (test-skip-file "Shift_JIS codec is not enabled"))

(test-begin "test-enc-sjis")

(test-equal "string 1" "”ül‚É‚Í" (string #\”ü #\l #\‚É #\‚Í))
(test-equal "list->string 1" "3“ú‚Å" (list->string '(#\3 #\“ú #\‚Å)))
(test-equal "string->list 1" '(#\‚Ÿ #\‚« #\‚é) (string->list "‚Ÿ‚«‚é"))

(test-equal "string-ref 1" #\•à  (string-ref "•hi•àÍ•à" 3))
(test-equal "make-string 1" "•à•à•à•à•à"   (make-string 5 #\•à))
(test-equal "string-copy 1" "‹à‹â"   (string-copy "‹à‹â"))
(test-equal "string-set! 1" "‹àŒj‹Ê"   (let ((s (string-copy "‹àŒj‚Æ")))
                                         (string-set! s 2 #\‹Ê)
                                         s))




;; The character after ™ is in JIS X 0213 plane 2.
(define str1 "‚ Ëƒƒah–\\\–\n!!™ğ@!")
(define str1-list '(#\‚  #\Ë #\ƒƒ #\a #\h #\–\ #\\ #\–\ #\n #\! #\! #\™ #\ğ@ #\!))

(test-equal "string 2" str1 (apply string str1-list))
(test-equal "list->string 2" str1-list (string->list str1))

;; JIS X 0201 kana (single byte)
(test-equal "JIS X 0201 kana" #\Ë (integer->char #xcb))
(test-equal "JIS X 0201 kana" #xcb (char->integer #\Ë))
(test-equal "JIS X 0201 kana" '(#\Ë) (string->list "Ë"))
(test-equal "JIS X 0201 kana" "Ë" (list->string '(#\Ë)))

(test-equal "JIS X 0208 kana #1" #\ƒ„ (integer->char #x8384))
(test-equal "JIS X 0208 kana #2" (car (string->list "ƒ„")) (integer->char #x8384))
(test-equal "JIS X 0208 kana #3" #x8384 (char->integer #\ƒ„))
(test-equal "JIS X 0208 kana #4" #x8384 (char->integer (integer->char #x8384)))
(test-equal "JIS X 0208 kana #5" '(#\ƒ„) (string->list "ƒ„"))
(test-equal "JIS X 0208 kana #6" "ƒ„" (list->string '(#\ƒ„)))
(test-equal "JIS X 0208 kana #7" "ƒ„" (list->string (string->list "ƒ„")))

(test-equal "JIS X 0201 kana and 0208 kana" '(#\Ë #\ƒƒ) (string->list "Ëƒƒ"))
(test-equal "JIS X 0201 kana and 0208 kana" "Ëƒƒ" (list->string '(#\Ë #\ƒƒ)))

;; SRFI-75
(test-begin "SRFI-75")
(test-assert (begin (string-read "#\\x63") #t))
(test-error (string-read "#\\u0063"))
(test-error (string-read "#\\U00000063"))

(test-error (string-read "\"\\x63\""))
(test-error (string-read "\"\\u0063\""))
(test-error (string-read "\"\\U00000063\""))

(test-assert (begin (string-read "'a") #t))
;; Non-Unicode multibyte symbols are not allowed.
(test-error (string-read "'‚ "))
(test-end "SRFI-75")

(test-begin "R6RS (R5.92RS) chars")
(test-assert (begin (string-read "#\\x") #t))
(test-assert (begin (string-read "#\\x6") #t))
(test-assert (begin (string-read "#\\xf") #t))
(test-assert (begin (string-read "#\\x63") #t))
(test-assert (begin (string-read "#\\x063") #t))
(test-assert (begin (string-read "#\\x0063") #t))
(test-assert (begin (string-read "#\\x00063") #t))
(test-assert (begin (string-read "#\\x0000063") #t))
(test-assert (begin (string-read "#\\x00000063") #t))
(test-error (string-read "#\\x000000063"))

(test-assert (begin (string-read "#\\x3042") #t))

(test-error (string-read "#\\x-"))
(test-error (string-read "#\\x-6"))
(test-error (string-read "#\\x-f"))
(test-error (string-read "#\\x-63"))
(test-error (string-read "#\\x-063"))
(test-error (string-read "#\\x-0063"))
(test-error (string-read "#\\x-00063"))
(test-error (string-read "#\\x-0000063"))
(test-error (string-read "#\\x-00000063"))
(test-error (string-read "#\\x-000000063"))

(test-error (string-read "#\\x+"))
(test-error (string-read "#\\x+6"))
(test-error (string-read "#\\x+f"))
(test-error (string-read "#\\x+63"))
(test-error (string-read "#\\x+063"))
(test-error (string-read "#\\x+0063"))
(test-error (string-read "#\\x+00063"))
(test-error (string-read "#\\x+0000063"))
(test-error (string-read "#\\x+00000063"))
(test-error (string-read "#\\x+000000063"))
(test-end "R6RS (R5.92RS) chars")

(test-begin "R6RS (R5.92RS) string hex escapes")
(test-error (string-read "\"\\x\""))
(test-error (string-read "\"\\x6\""))
(test-error (string-read "\"\\xf\""))
(test-error (string-read "\"\\x63\""))
(test-error (string-read "\"\\x063\""))
(test-error (string-read "\"\\x0063\""))
(test-error (string-read "\"\\x00063\""))
(test-error (string-read "\"\\x0000063\""))
(test-error (string-read "\"\\x00000063\""))
(test-error (string-read "\"\\x000000063\""))

(test-error (string-read "\"\\x;\""))
(test-assert (begin (string-read "\"\\x6;\"") #t))
(test-assert (begin (string-read "\"\\xf;\"") #t))
(test-assert (begin (string-read "\"\\x63;\"") #t))
(test-assert (begin (string-read "\"\\x063;\"") #t))
(test-assert (begin (string-read "\"\\x0063;\"") #t))
(test-assert (begin (string-read "\"\\x00063;\"") #t))
(test-assert (begin (string-read "\"\\x0000063;\"") #t))
(test-assert (begin (string-read "\"\\x00000063;\"") #t))
(test-error (string-read "\"\\x000000063;\""))

(test-error (string-read "\"\\x-\""))
(test-error (string-read "\"\\x-6\""))
(test-error (string-read "\"\\x-f\""))
(test-error (string-read "\"\\x-63\""))
(test-error (string-read "\"\\x-063\""))
(test-error (string-read "\"\\x-0063\""))
(test-error (string-read "\"\\x-00063\""))
(test-error (string-read "\"\\x-0000063\""))
(test-error (string-read "\"\\x-00000063\""))
(test-error (string-read "\"\\x-000000063\""))

(test-error (string-read "\"\\x-;\""))
(test-error (string-read "\"\\x-6;\""))
(test-error (string-read "\"\\x-f;\""))
(test-error (string-read "\"\\x-63;\""))
(test-error (string-read "\"\\x-063;\""))
(test-error (string-read "\"\\x-0063;\""))
(test-error (string-read "\"\\x-00063;\""))
(test-error (string-read "\"\\x-0000063;\""))
(test-error (string-read "\"\\x-00000063;\""))
(test-error (string-read "\"\\x-000000063;\""))

(test-error (string-read "\"\\x+\""))
(test-error (string-read "\"\\x+6\""))
(test-error (string-read "\"\\x+f\""))
(test-error (string-read "\"\\x+63\""))
(test-error (string-read "\"\\x+063\""))
(test-error (string-read "\"\\x+0063\""))
(test-error (string-read "\"\\x+00063\""))
(test-error (string-read "\"\\x+0000063\""))
(test-error (string-read "\"\\x+00000063\""))
(test-error (string-read "\"\\x+000000063\""))

(test-error (string-read "\"\\x+;\""))
(test-error (string-read "\"\\x+6;\""))
(test-error (string-read "\"\\x+f;\""))
(test-error (string-read "\"\\x+63;\""))
(test-error (string-read "\"\\x+063;\""))
(test-error (string-read "\"\\x+0063;\""))
(test-error (string-read "\"\\x+00063;\""))
(test-error (string-read "\"\\x+0000063;\""))
(test-error (string-read "\"\\x+00000063;\""))
(test-error (string-read "\"\\x+000000063;\""))
(test-end "R6RS (R5.92RS) string hex escapes")

(test-end "test-enc-sjis")
