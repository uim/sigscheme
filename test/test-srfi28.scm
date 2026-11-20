;;  Filename : test-srfi28.scm
;;  About    : unit test for SRFI-28
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

;; All tests in this file are passed against r3166 (new repository)

(require-extension (srfi 64))

(require-extension (srfi 28))

(test-begin "test-srfi28")

(test-begin "format invalid form")
(test-error (format))
(test-error (format #f))
(test-error (format #\a))
(test-error (format "~"))
(test-error (format "a~"))
(test-error (format "a" "a"))
(test-end "format invalid form")

(test-begin "format unknown directives")
(test-error (format "~z"))
(test-error (format "~Z"))
(test-error (format "~'"))
(test-error (format "~$"))
(test-end "format unknown directives")

(test-begin "format SRFI-48 directives")
(if (not (provided? "srfi-48"))
    (begin
      (test-error (format "~w" 0))
      (test-error (format "~d" 0))
      (test-error (format "~x" 0))
      (test-error (format "~o" 0))
      (test-error (format "~b" 0))
      (test-error (format "~c" #\a))
      (test-error (format "~f" 0))
      (test-error (format "~2f" 0))
      (test-error (format "~2,3f" 0))
      (test-error (format "~?" "~s" '(0)))
      (test-error (format "~k" "~s" '(0)))
      (test-error (format "~y" '(0)))

      (test-error (format "~t"))
      (test-error (format "~_"))
      (test-error (format "~&"))
      (test-error (format "~h"))))
(test-end "format SRFI-48 directives")

(test-begin "format no directive")
(test-error (format "" 0))
(test-equal ""
            (format ""))
(test-equal "aBc"
            (format "aBc"))
(test-end "format no directive")

(test-begin "format ~a")
(test-error (format "~a"))
(test-error (format "~a" 0 1))
(test-error (format "~1a" 1))
(test-equal "#f"
            (format "~a" #f))
(test-equal "#t"
            (format "~a" #t))
(test-equal "123"
            (format "~a" 123))
(test-equal "a"
            (format "~a" #\a))
(test-equal "aBc"
            (format "~a" "aBc"))
(test-equal "(#t 123 a aBc (0))"
            (format "~a" '(#t 123 #\a "aBc" (0))))
(test-end "format ~a")

(test-begin "format ~A")
(test-error (format "~A"))
(test-error (format "~A" 0 1))
(test-error (format "~1A" 1))
(test-equal "#f"
            (format "~A" #f))
(test-equal "#t"
            (format "~A" #t))
(test-equal "123"
            (format "~A" 123))
(test-equal "a"
            (format "~A" #\a))
(test-equal "aBc"
            (format "~A" "aBc"))
(test-equal "(#t 123 a aBc (0))"
            (format "~A" '(#t 123 #\a "aBc" (0))))
(test-end "format ~A")

(test-begin "format ~s")
(test-error (format "~s"))
(test-error (format "~s" 0 1))
(test-error (format "~1s" 1))
(test-equal "#f"
            (format "~s" #f))
(test-equal "#t"
            (format "~s" #t))
(test-equal "123"
            (format "~s" 123))
(test-equal "#\\a"
            (format "~s" #\a))
(test-equal "\"aBc\""
            (format "~s" "aBc"))
(test-equal "(#t 123 #\\a \"aBc\" (0))"
            (format "~s" '(#t 123 #\a "aBc" (0))))
(test-end "format ~s")

(test-begin "format ~S")
(test-error (format "~S"))
(test-error (format "~S" 0 1))
(test-error (format "~1S" 1))
(test-equal "#f"
            (format "~S" #f))
(test-equal "#t"
            (format "~S" #t))
(test-equal "123"
            (format "~S" 123))
(test-equal "#\\a"
            (format "~S" #\a))
(test-equal "\"aBc\""
            (format "~S" "aBc"))
(test-equal "(#t 123 #\\a \"aBc\" (0))"
            (format "~S" '(#t 123 #\a "aBc" (0))))
(test-end "format ~S")

(test-begin "format ~%")
(test-error (format "~%" 0))
(test-equal "\n"
            (format "~%"))
(test-end "format ~%")

(test-begin "format ~~")
(test-error (format "~~" 0))
(test-equal "~"
            (format "~~"))
(test-end "format ~~")

(test-begin "format mixed directives")
(test-equal "~\n"
            (format "~~~%"))
(test-equal "slashified: #\\a\nany: a\n"
            (format "slashified: ~s~%any: ~a~%" #\a #\a))
(test-end "format mixed directives")

(test-end "test-srfi28")
