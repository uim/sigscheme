#! /usr/bin/env sscm -C EUC-JP
;; -*- buffer-file-coding-system: euc-jisx0213 -*-

;;  Filename : test-enc-eucjp.scm
;;  About    : unit test for EUC-JP string
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

(if (not (and (provided? "euc-jp")
              (symbol-bound? 'char?)
              (symbol-bound? 'string?)))
    (test-skip-file "EUC-JP codec is not enabled"))

(test-begin "test-enc-eucjp")

;; string?
(test-assert "string? check" (string? "あいうえお"))

;; make-string
(test-assert "alphabet make-string check" (string=? "aaa" (make-string 3 #\a)))
(test-assert "hiragana make-string check" (string=? "あああ" (make-string 3 #\あ)))
(test-equal "make-string 1" "歩歩歩歩歩"   (make-string 5 #\歩))

;; string-ref
(test-equal "hiragana string-ref check" #\お (string-ref "あいうえお" 4))
(test-equal "mixed string-ref check" #\お (string-ref "あiueお" 4))
(test-equal "alphabet string-ref 0 check" #\a  (string-ref "aiueo" 0))
(test-equal "hiragena string-ref 0 check" #\あ (string-ref "あいうえお" 0))
(test-equal "string-ref 1" #\歩  (string-ref "歯hi歩ﾍ歩" 3))


;; string-set!
(test-assert "hiragana string-set! check"
             (string=? "あいかえお"
                       (let ((str (string-copy "あいうえお")))
                         (string-set! str 2 #\か)
                         str)))
(test-assert "mixed string-set! check"
             (string=? "aiueo"
                       (let ((str (string-copy "aiうeo")))
                         (string-set! str 2 #\u)
                         str)))
(test-equal "string-set! 1" "金桂玉"   (let ((s (string-copy "金桂と")))
                                         (string-set! s 2 #\玉)
                                         s))


;; string-length
(test-equal "hiragana string-length check" 5 (string-length "あいうえお"))

;; string=?
(test-equal "hiragana string=? check" #t (string=? "あいうえお" "あいうえお"))
(test-equal "mixed string=? check" #t (string=? "aいうえo" "aいうえo"))

;; substring
(test-assert "hiragana substring check" (string=? "いう" (substring (string-copy "あいうえお") 1 3)))
(test-assert "mixed substring check" (string=? "いu"  (substring (string-copy "aいuえo") 1 3)))

;; string-append
(test-assert "hiragana 1 string-append check" (string=? "あ"     (string-append "あ")))
(test-assert "hiragana 2 string-append check" (string=? "あい"   (string-append "あ" "い")))
(test-assert "hiragana 3 string-append check" (string=? "あいう" (string-append "あ" "い" "う")))
(test-assert "mixed 2 string-append check" (string=? "あi"   (string-append "あ" "i")))
(test-assert "mixed 3 string-append check" (string=? "あiう" (string-append "あ" "i" "う")))


;; string->list
(test-assert "string->list check" (equal? '(#\あ #\i #\う #\e #\お) (string->list "あiうeお")))
(test-equal "string->list 1" '(#\ぁ #\き #\る) (string->list "ぁきる"))

;; list->string
(test-equal "list->string check" "あaい" (list->string '(#\あ #\a #\い)))
(test-equal "list->string 1" "3日で" (list->string '(#\3 #\日 #\で)))

;; string-fill!
(test-assert "hiragana string-fill! check"
             (string=? "あああああ"
                       (let ((str (string-copy "aiueo")))
                         (string-fill! str #\あ)
                         str)))
(test-assert "mixed string-fill! by alphabet check"
             (string=? "aaaaa"
                       (let ((str (string-copy "aいうえo")))
                         (string-fill! str #\a)
                         str)))
(test-assert "mixed string-fill! by hiragana check"
             (string=? "いいいいい"
                       (let ((str (string-copy "aいうえo")))
                         (string-fill! str #\い)
                         str)))

;; string
(test-equal "string 1" "美人には" (string #\美 #\人 #\に #\は))

;; string-copy
(test-equal "string-copy 1" "金銀香"   (string-copy "金銀香"))


;; The character after ☆ is from JIS X 0212.  The one after ◎ is
;; from JIS X 0213 plane 2.  This violates all known standards, but
;; souldn't be a real problem.
(define str1 "あﾋャah暴\\暴n!☆錳◎�、!")
(define str1-list '(#\あ #\ﾋ #\ャ #\a #\h #\暴 #\\ #\暴 #\n #\! #\☆ #\錳 #\◎ #\�、 #\!))

(test-equal "string 2" str1 (apply string str1-list))
(test-equal "list->string 2" str1-list (string->list str1))

;; unsupported SRFI-75 literals cause error
(test-begin "SRFI-75")
(test-assert (begin (string-read "#\\x63") #t))
(test-error (string-read "#\\u0063"))
(test-error (string-read "#\\U00000063"))

(test-error (string-read "\"\\x63\""))
(test-error (string-read "\"\\u0063\""))
(test-error (string-read "\"\\U00000063\""))

(test-assert (begin (string-read "'a") #t))
;; Non-Unicode multibyte symbols are not allowed.
(test-error (string-read "'あ"))
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

(test-end "test-enc-eucjp")
