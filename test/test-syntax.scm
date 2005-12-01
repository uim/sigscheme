#! /usr/bin/env sscm -C UTF-8
;; -*- buffer-file-coding-system: utf-8 -*-

;;  FileName : test-syntax.scm
;;  About    : unit test for R5RS syntax
;;
;;  Copyright (C) 2005      by YamaKen (yamaken AT bp.iij4u.or.jp)
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

(load "./test/unittest.scm")

;; See "7.1 Formal syntax" of R5RS

(assert-parse-error "invalid boolean" "#F")
(assert-parse-error "invalid boolean" "#T")

(assert-true "boolean" (boolean? (string-read "#f")))
(assert-true "boolean" (boolean? (string-read "#t")))

(assert-parse-error "invalid identifier" "#")
(assert-parse-error "invalid identifier" ".")
(assert-parse-error "invalid identifier" "..")
(assert-parse-error "invalid identifier" "....")
(assert-parse-error "invalid identifier" ".a")
(assert-parse-error "invalid identifier" "+a")
(assert-parse-error "invalid identifier" "++")
(assert-parse-error "invalid identifier" "--")
(assert-parse-error "invalid identifier" "@")
(assert-parse-error "invalid identifier" "1a")

(assert-true "special initial identifier" (symbol? (string-read "!")))
(assert-true "special initial identifier" (symbol? (string-read "$")))
(assert-true "special initial identifier" (symbol? (string-read "%")))
(assert-true "special initial identifier" (symbol? (string-read "&")))
(assert-true "special initial identifier" (symbol? (string-read "*")))
(assert-true "special initial identifier" (symbol? (string-read "/")))
(assert-true "special initial identifier" (symbol? (string-read ":")))
(assert-true "special initial identifier" (symbol? (string-read "<")))
(assert-true "special initial identifier" (symbol? (string-read "=")))
(assert-true "special initial identifier" (symbol? (string-read ">")))
(assert-true "special initial identifier" (symbol? (string-read "?")))
(assert-true "special initial identifier" (symbol? (string-read "^")))
(assert-true "special initial identifier" (symbol? (string-read "_")))
(assert-true "special initial identifier" (symbol? (string-read "~")))

(assert-true "special initial identifier #2" (symbol? (string-read "!1")))
(assert-true "special initial identifier #2" (symbol? (string-read "$1")))
(assert-true "special initial identifier #2" (symbol? (string-read "%1")))
(assert-true "special initial identifier #2" (symbol? (string-read "&1")))
(assert-true "special initial identifier #2" (symbol? (string-read "*1")))
(assert-true "special initial identifier #2" (symbol? (string-read "/1")))
(assert-true "special initial identifier #2" (symbol? (string-read ":1")))
(assert-true "special initial identifier #2" (symbol? (string-read "<1")))
(assert-true "special initial identifier #2" (symbol? (string-read "=1")))
(assert-true "special initial identifier #2" (symbol? (string-read ">1")))
(assert-true "special initial identifier #2" (symbol? (string-read "?1")))
(assert-true "special initial identifier #2" (symbol? (string-read "^1")))
(assert-true "special initial identifier #2" (symbol? (string-read "_1")))
(assert-true "special initial identifier #2" (symbol? (string-read "~1")))

(assert-true "special initial identifier #2" (symbol? (string-read "!a")))
(assert-true "special initial identifier #2" (symbol? (string-read "$a")))
(assert-true "special initial identifier #2" (symbol? (string-read "%a")))
(assert-true "special initial identifier #2" (symbol? (string-read "&a")))
(assert-true "special initial identifier #2" (symbol? (string-read "*a")))
(assert-true "special initial identifier #2" (symbol? (string-read "/a")))
(assert-true "special initial identifier #2" (symbol? (string-read ":a")))
(assert-true "special initial identifier #2" (symbol? (string-read "<a")))
(assert-true "special initial identifier #2" (symbol? (string-read "=a")))
(assert-true "special initial identifier #2" (symbol? (string-read ">a")))
(assert-true "special initial identifier #2" (symbol? (string-read "?a")))
(assert-true "special initial identifier #2" (symbol? (string-read "^a")))
(assert-true "special initial identifier #2" (symbol? (string-read "_a")))
(assert-true "special initial identifier #2" (symbol? (string-read "~a")))

(assert-true "identifier" (symbol? (string-read "...")))
(assert-true "identifier" (symbol? (string-read "+")))
(assert-true "identifier" (symbol? (string-read "-")))
(assert-true "identifier" (symbol? (string-read "a.")))
(assert-true "identifier" (symbol? (string-read "a+")))
(assert-true "identifier" (symbol? (string-read "a-")))
(assert-true "identifier" (symbol? (string-read "a@")))
(assert-true "identifier" (symbol? (string-read "a1")))

(assert-true "integer" (integer? (string-read "1")))
(assert-true "integer" (integer? (string-read "1")))
(assert-true "integer" (integer? (string-read "+1")))
(assert-true "integer" (integer? (string-read "-1")))
(assert-true "integer" (integer? (string-eval "'+1")))
(assert-true "integer" (integer? (string-eval "'-1")))
(assert-true "integer" (integer? (string-read "#d1")))
(assert-true "integer" (integer? (string-read "#d1")))
(assert-true "integer" (integer? (string-read "#d+1")))
(assert-true "integer" (integer? (string-read "#d-1")))
(assert-true "integer" (integer? (string-eval "'#d+1")))
(assert-true "integer" (integer? (string-eval "'#d-1")))

(total-report)