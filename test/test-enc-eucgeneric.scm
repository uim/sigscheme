#! /usr/bin/env sscm -C EUC-CN
;; -*- buffer-file-coding-system: euc-jp -*-

;;  Filename : test-enc-eucgeneric.scm
;;  About    : unit test for EUC string
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

(if (not (provided? "r6rs-chars"))
    (test-skip-file "R6RS characters is not enabled"))

(if (not (symbol-bound? 'string->list))
    (test-skip-file "R5RS string procedures are not enabled"))

(test-begin "test-enc-eucgeneric")

;; This file provides a fallback test unit for all EUC systems.  It's
;; just a copy of test-enc-eucjp.scm with EUCJP-specific character
;; sequences removed, so some characters may be undefined in other EUC
;; systems.
(test-equal "string 1" "Èş¿Í¤Ë¤Ï" (string #\Èş #\¿Í #\¤Ë #\¤Ï))
(test-equal "list->string 1" "3Æü¤Ç" (list->string '(#\3 #\Æü #\¤Ç)))
(test-equal "string->list 1" '(#\¤¡ #\¤­ #\¤ë) (string->list "¤¡¤­¤ë"))

;; since single shift is only supported in EUC-JP in SigScheme, the JIS X 0201
;; kana character is replaced to JIS x 0208.  -- YamaKen 2005-11-25
(test-equal "string-ref 1" #\Êâ  (string-ref "»õhiÊâ¤ØÊâ" 3))

(test-equal "make-string 1" "ÊâÊâÊâÊâÊâ"   (make-string 5 #\Êâ))
(test-equal "string-copy 1" "¶â¶ä¹á"   (string-copy "¶â¶ä¹á"))
(test-equal "string-set! 1" "¶â·Ë¶Ì"   (let ((s (string-copy "¶â·Ë¤È")))
                                         (string-set! s 2 #\¶Ì)
                                         s))

(define str1 "¤¢¥ãahË½\\Ë½n!¡ù¡ı!")
(define str1-list '(#\¤¢ #\¥ã #\a #\h #\Ë½ #\\ #\Ë½ #\n #\! #\¡ù #\¡ı #\!))

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
(test-error (string-read "'¤¢"))
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

(test-end "test-enc-eucgeneric")
