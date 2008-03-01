#! /usr/bin/env sscm -C EUC-CN
;; -*- buffer-file-coding-system: euc-jp -*-

;;  Filename : test-enc-eucgeneric.scm
;;  About    : unit test for EUC string
;;
;;  Copyright (C) 2005-2006 Kazuki Ohta <mover AT hct.zaq.ne.jp>
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

(if (not (and (provided? "euc-jp")
              (symbol-bound? 'char?)
              (symbol-bound? 'string?)))
    (test-skip "EUC-JP codec is not enabled"))

(define tn test-name)

;; This file provides a fallback test unit for all EUC systems.  It's
;; just a copy of test-enc-eucjp.scm with EUCJP-specific character
;; sequences removed, so some characters may be undefined in other EUC
;; systems.
(assert-equal? "string 1" "Èş¿Í¤Ë¤Ï" (string #\Èş #\¿Í #\¤Ë #\¤Ï))
(assert-equal? "list->string 1" "3Æü¤Ç" (list->string '(#\3 #\Æü #\¤Ç)))
(assert-equal? "string->list 1" '(#\¤¡ #\¤­ #\¤ë) (string->list "¤¡¤­¤ë"))

;; since single shift is only supported in EUC-JP in SigScheme, the JIS X 0201
;; kana character is replaced to JIS x 0208.  -- YamaKen 2005-11-25
(assert-equal? "string-ref 1" #\Êâ  (string-ref "»õhiÊâ¤ØÊâ" 3))

(assert-equal? "make-string 1" "ÊâÊâÊâÊâÊâ"   (make-string 5 #\Êâ))
(assert-equal? "string-copy 1"     "¶â¶ä¹á"   (string-copy "¶â¶ä¹á"))
(assert-equal? "string-set! 1"     "¶â·Ë¶Ì"   (let ((s (string-copy "¶â·Ë¤È")))
                                                (string-set! s 2 #\¶Ì)
                                                s))

(define str1 "¤¢¥ãahË½\\Ë½n!¡ù¡ı!")
(define str1-list '(#\¤¢ #\¥ã #\a #\h #\Ë½ #\\ #\Ë½ #\n #\! #\¡ù #\¡ı #\!))

(assert-equal? "string 2" str1 (apply string str1-list))
(assert-equal? "list->string 2" str1-list (string->list str1))

;; unsupported SRFI-75 literals cause error
(tn "SRFI-75")
(assert-parseable   (tn) "#\\x63")
(assert-parse-error (tn) "#\\u0063")
(assert-parse-error (tn) "#\\U00000063")

(assert-parse-error (tn) "\"\\x63\"")
(assert-parse-error (tn) "\"\\u0063\"")
(assert-parse-error (tn) "\"\\U00000063\"")

(assert-parseable   (tn) "'a")
;; Non-Unicode multibyte symbols are not allowed.
(assert-parse-error (tn) "'¤¢")

(tn "R6RS (R5.92RS) chars")
(assert-parseable   (tn) "#\\x")
(assert-parseable   (tn) "#\\x6")
(assert-parseable   (tn) "#\\xf")
(assert-parseable   (tn) "#\\x63")
(assert-parseable   (tn) "#\\x063")
(assert-parseable   (tn) "#\\x0063")
(assert-parseable   (tn) "#\\x00063")
(assert-parseable   (tn) "#\\x0000063")
(assert-parseable   (tn) "#\\x00000063")
(assert-parse-error (tn) "#\\x000000063")

(assert-parseable   (tn) "#\\x3042")

(assert-parse-error (tn) "#\\x-")
(assert-parse-error (tn) "#\\x-6")
(assert-parse-error (tn) "#\\x-f")
(assert-parse-error (tn) "#\\x-63")
(assert-parse-error (tn) "#\\x-063")
(assert-parse-error (tn) "#\\x-0063")
(assert-parse-error (tn) "#\\x-00063")
(assert-parse-error (tn) "#\\x-0000063")
(assert-parse-error (tn) "#\\x-00000063")
(assert-parse-error (tn) "#\\x-000000063")

(assert-parse-error (tn) "#\\x+")
(assert-parse-error (tn) "#\\x+6")
(assert-parse-error (tn) "#\\x+f")
(assert-parse-error (tn) "#\\x+63")
(assert-parse-error (tn) "#\\x+063")
(assert-parse-error (tn) "#\\x+0063")
(assert-parse-error (tn) "#\\x+00063")
(assert-parse-error (tn) "#\\x+0000063")
(assert-parse-error (tn) "#\\x+00000063")
(assert-parse-error (tn) "#\\x+000000063")

(tn "R6RS (R5.92RS) string hex escapes")
(assert-parse-error (tn) "\"\\x\"")
(assert-parse-error (tn) "\"\\x6\"")
(assert-parse-error (tn) "\"\\xf\"")
(assert-parse-error (tn) "\"\\x63\"")
(assert-parse-error (tn) "\"\\x063\"")
(assert-parse-error (tn) "\"\\x0063\"")
(assert-parse-error (tn) "\"\\x00063\"")
(assert-parse-error (tn) "\"\\x0000063\"")
(assert-parse-error (tn) "\"\\x00000063\"")
(assert-parse-error (tn) "\"\\x000000063\"")

(assert-parse-error (tn) "\"\\x;\"")
(assert-parseable   (tn) "\"\\x6;\"")
(assert-parseable   (tn) "\"\\xf;\"")
(assert-parseable   (tn) "\"\\x63;\"")
(assert-parseable   (tn) "\"\\x063;\"")
(assert-parseable   (tn) "\"\\x0063;\"")
(assert-parseable   (tn) "\"\\x00063;\"")
(assert-parseable   (tn) "\"\\x0000063;\"")
(assert-parseable   (tn) "\"\\x00000063;\"")
(assert-parse-error (tn) "\"\\x000000063;\"")

(assert-parse-error (tn) "\"\\x-\"")
(assert-parse-error (tn) "\"\\x-6\"")
(assert-parse-error (tn) "\"\\x-f\"")
(assert-parse-error (tn) "\"\\x-63\"")
(assert-parse-error (tn) "\"\\x-063\"")
(assert-parse-error (tn) "\"\\x-0063\"")
(assert-parse-error (tn) "\"\\x-00063\"")
(assert-parse-error (tn) "\"\\x-0000063\"")
(assert-parse-error (tn) "\"\\x-00000063\"")
(assert-parse-error (tn) "\"\\x-000000063\"")

(assert-parse-error (tn) "\"\\x-;\"")
(assert-parse-error (tn) "\"\\x-6;\"")
(assert-parse-error (tn) "\"\\x-f;\"")
(assert-parse-error (tn) "\"\\x-63;\"")
(assert-parse-error (tn) "\"\\x-063;\"")
(assert-parse-error (tn) "\"\\x-0063;\"")
(assert-parse-error (tn) "\"\\x-00063;\"")
(assert-parse-error (tn) "\"\\x-0000063;\"")
(assert-parse-error (tn) "\"\\x-00000063;\"")
(assert-parse-error (tn) "\"\\x-000000063;\"")

(assert-parse-error (tn) "\"\\x+\"")
(assert-parse-error (tn) "\"\\x+6\"")
(assert-parse-error (tn) "\"\\x+f\"")
(assert-parse-error (tn) "\"\\x+63\"")
(assert-parse-error (tn) "\"\\x+063\"")
(assert-parse-error (tn) "\"\\x+0063\"")
(assert-parse-error (tn) "\"\\x+00063\"")
(assert-parse-error (tn) "\"\\x+0000063\"")
(assert-parse-error (tn) "\"\\x+00000063\"")
(assert-parse-error (tn) "\"\\x+000000063\"")

(assert-parse-error (tn) "\"\\x+;\"")
(assert-parse-error (tn) "\"\\x+6;\"")
(assert-parse-error (tn) "\"\\x+f;\"")
(assert-parse-error (tn) "\"\\x+63;\"")
(assert-parse-error (tn) "\"\\x+063;\"")
(assert-parse-error (tn) "\"\\x+0063;\"")
(assert-parse-error (tn) "\"\\x+00063;\"")
(assert-parse-error (tn) "\"\\x+0000063;\"")
(assert-parse-error (tn) "\"\\x+00000063;\"")
(assert-parse-error (tn) "\"\\x+000000063;\"")

(total-report)
