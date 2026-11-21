#! /usr/bin/env sscm -C UTF-8

;;  Filename : test-misc.scm
;;  About    : unit tests for miscellaneous procedures
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

(require-extension (srfi 64))

(if (not (provided? "r6rs-chars"))
    (test-skip-file "R6RS characters is not enabled"))

(test-begin "test-misc")

(test-begin "procedure?")
(test-eq #f (procedure? #f))
(test-eq #f (procedure? #t))
(test-eq #f (procedure? '()))
(if (provided? "sigscheme")
    (begin
      (test-eq #f (procedure? (eof)))
      (test-eq #f (procedure? (undef)))))
(test-eq #f (procedure? 0))
(test-eq #f (procedure? 1))
(test-eq #f (procedure? 3))
(test-eq #f (procedure? -1))
(test-eq #f (procedure? -3))
(test-eq #f (procedure? 'symbol))
(test-eq #f (procedure? 'SYMBOL))
(test-eq #f (procedure? #\a))
(test-eq #f (procedure? #\あ))
(test-eq #f (procedure? ""))
(test-eq #f (procedure? " "))
(test-eq #f (procedure? "a"))
(test-eq #f (procedure? "A"))
(test-eq #f (procedure? "aBc12!"))
(test-eq #f (procedure? "あ"))
(test-eq #f (procedure? "あ0イう12!"))
(test-eq #t (procedure? car))
(test-eq #f (procedure? 'car))
(test-eq #t (procedure? +))
(test-eq #t (procedure? (lambda () #t)))
(test-eq #f (procedure? '(lambda () #t)))

;; syntactic keywords should not be appeared as operand
(if sigscheme?
    (begin
      ;; pure syntactic keyword
      (test-error (procedure? else))
      ;; expression keyword
      (test-error (procedure? do))))

(call-with-current-continuation
 (lambda (k)
   (test-eq #t (procedure? k))))
(test-eq #t (call-with-current-continuation procedure?))
(test-eq #f (procedure? (current-output-port)))
(test-eq #f (procedure? '(#t . #t)))
(test-eq #f (procedure? (cons #t #t)))
(test-eq #f (procedure? '(0 1 2)))
(test-eq #f (procedure? (list 0 1 2)))
(test-eq #f (procedure? '#()))
(test-eq #f (procedure? (vector)))
(test-eq #f (procedure? '#(0 1 2)))
(test-eq #f (procedure? (vector 0 1 2)))
(test-end "procedure?")

(test-begin "Optional argument modification")
;; Dotted
(test-equal '(a . #t)
            ((lambda args (set-cdr! args #t) args) 'a 'b 'c))
;; Circular
(test-equal 'a
            (caddr ((lambda args (set-cdr! args args) args) 'a 'b)))
(test-end "Optional argument modification")

(test-end "test-misc")
