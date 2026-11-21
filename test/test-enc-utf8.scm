#! /usr/bin/env sscm -C UTF-8
;; -*- buffer-file-coding-system: utf-8 -*-

;;  Filename : test-enc-utf8.scm
;;  About    : unit test for UTF-8 string
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

(require-extension (srfi 28))

(if (not (and (provided? "utf-8")
              (symbol-bound? 'char?)
              (symbol-bound? 'string?)))
    (test-skip-file "UTF-8 codec is not enabled"))

(if (not (provided? "r6rs-chars"))
    (test-skip-file "R6RS characters is not enabled"))

(test-begin "test-enc-utf8")

(test-equal "string 1" "美人には" (string #\美 #\人 #\に #\は))
(test-equal "list->string 1" "3日で" (list->string '(#\3 #\日 #\で)))
(test-equal "string->list 1" '(#\ぁ #\き #\る) (string->list "ぁきる"))

(test-equal "string-ref 1" #\歩  (string-ref "歯hi歩ﾍ歩" 3))
(test-equal "make-string 1" "歩歩歩歩歩"   (make-string 5 #\歩))
(test-equal "string-copy 1" "金銀香"   (string-copy "金銀香"))
(test-equal "string-set! 1" "金桂玉"   (let ((s (string-copy "金桂と")))
                                         (string-set! s 2 #\玉)
                                         s))


(define str1 "あﾋャah暴\\暴n!☆錳◎!")
(define str1-list '(#\あ #\ﾋ #\ャ #\a #\h #\暴 #\\ #\暴 #\n #\! #\☆ #\錳 #\◎ #\!))

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
(test-assert (begin (string-read "'あ") #t))
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

;; Each byte of an invalid sequence is a character whose code is the
;; byte as in string-length and string-ref.
(test-begin "invalid sequence")
;; The length of a string is counted in the current character codec on
;; its creation. So it's recounted in UTF-8.
(define (bytes->string . bytes)
  (%%string-reconstruct!
   (with-char-codec "ISO-8859-1"
     (lambda ()
       (list->string (map integer->char bytes))))))
(define invalid-str (string-append "a" (bytes->string #xa4 #xa2) "b"))
(test-equal 4 (string-length invalid-str))
(test-equal (integer->char #xa4) (string-ref invalid-str 1))
(test-equal (list #\a (integer->char #xa4) (integer->char #xa2) #\b)
            (string->list invalid-str))
(test-assert (string<? invalid-str
                       (string #\a (integer->char #xa5))))
(test-assert (string-ci=? invalid-str (string-copy invalid-str)))
(if (provided? "srfi-6")
    (test-equal (string-append "\"" invalid-str "\"")
                (let ((port (open-output-string)))
                  (write invalid-str port)
                  (get-output-string port))))
(if (and (provided? "srfi-6") (provided? "srfi-28"))
    (begin
      ;; An invalid sequence is written as-is. It isn't written as
      ;; U+00A4 and U+00A2 in UTF-8.
      (test-equal invalid-str (format invalid-str))
      (test-equal (string-append "a" (bytes->string #xa4 #xa2) "b1")
                  (format (string-append invalid-str "~a") 1))))
(if (symbol-bound? 'string-upcase)
    (begin
      ;; An invalid sequence is kept as-is. It isn't converted to
      ;; U+00A4 and U+00A2 in UTF-8.
      (test-equal (string-append "A" (bytes->string #xa4 #xa2) "B")
                  (string-upcase invalid-str))
      (test-equal (string-append "a" (bytes->string #xa4 #xa2) "b")
                  (string-downcase (string-upcase invalid-str)))
      (test-equal (string-append "a" (bytes->string #xa4 #xa2) "b")
                  (string-foldcase (string-upcase invalid-str)))
      ;; #xb5 isn't U+00B5 (MICRO SIGN) whose upper case is U+039C.
      (test-equal (bytes->string #xb5)
                  (string-upcase (bytes->string #xb5)))
      ;; An incomplete sequence at the end is kept as-is too.
      (test-equal (string-append "A" (bytes->string #xe3 #x81))
                  (string-upcase
                   (string-append "a" (bytes->string #xe3 #x81))))))
(test-end "invalid sequence")

(test-end "test-enc-utf8")
