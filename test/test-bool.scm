#! /usr/bin/env sscm -C UTF-8
;; -*- buffer-file-coding-system: utf-8 -*-

;;  Filename : test-bool.scm
;;  About    : unit tests for boolean
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

(test-begin "test-bool")

;; To sense boolean values accurately, these tests use '(test-assert (if <exp>
;; #t #f))' form to test a boolean expression instead of '(test-assert <exp>)'
;; of '(test-equal #t <exp>)'.  -- YamaKen 2006-09-07
(test-begin "R5RS upper-case boolean literal")
(test-assert (not (if (string-read "#F") #t #f)))
(test-assert (if (string-read "#T") #t #f))
(test-end "R5RS upper-case boolean literal")

(test-begin "boolean self-evaluation")
(test-assert (eq? #f '#f))
(test-assert (eq? #t '#t))
(test-end "boolean self-evaluation")

(test-begin "boolean values")
(test-assert (not (if #f #t #f)))
(test-assert (if #t #t #f))
(test-assert '())
(test-assert (not (eq? #f '())))
(if (provided? "sigscheme")
    (begin
      (test-assert (if (eof) #t #f))
      (test-assert (if (undef) #t #f))))
(test-assert (if 0 #t #f))
(test-assert (if 1 #t #f))
(test-assert (if 3 #t #f))
(test-assert (if -1 #t #f))
(test-assert (if -3 #t #f))
(test-assert (if 'symbol #t #f))
(test-assert (if 'SYMBOL #t #f))
(test-assert (if #\a #t #f))
(test-assert (if #\あ #t #f))
(test-assert (if "" #t #f))
(test-assert (if " " #t #f))
(test-assert (if "a" #t #f))
(test-assert (if "A" #t #f))
(test-assert (if "aBc12!" #t #f))
(test-assert (if "あ" #t #f))
(test-assert (if "あ0イう12!" #t #f))
(test-assert (if + #t #f))
(test-assert (if (lambda () #t) #t #f))

;; syntactic keywords should not be appeared as operand
(if sigscheme?
    (begin
      ;; pure syntactic keyword
      (test-error (if else #t #f))
      ;; expression keyword
      (test-argcheck-error (if do #t #f))))

(call-with-current-continuation
 (lambda (k)
   (test-assert (if k #t #f))))
(test-assert (if (current-output-port) #t #f))
(test-assert (if '(#t . #t) #t #f))
(test-assert (if (cons #t #t) #t #f))
(test-assert (if '(0 1 2) #t #f))
(test-assert (if (list 0 1 2) #t #f))
(test-assert (if '#() #t #f))
(test-assert (if (vector) #t #f))
(test-assert (if '#(0 1 2) #t #f))
(test-assert (if (vector 0 1 2) #t #f))
(test-end "boolean values")

(test-begin "not")
;; 'not' must return exact #t
;; > R5RS: 6.3 Other data types
;; > `Not' returns #t if obj is false, and returns #f otherwise.
(test-eq #t (not #f))
(test-eq #f (not #t))
(test-eq #f (not '()))
(if (provided? "sigscheme")
    (begin
      (test-eq #f (not (eof)))
      (test-eq #f (not (undef)))))
(test-eq #f (not 0))
(test-eq #f (not 1))
(test-eq #f (not 3))
(test-eq #f (not -1))
(test-eq #f (not -3))
(test-eq #f (not 'symbol))
(test-eq #f (not 'SYMBOL))
(test-eq #f (not #\a))
(test-eq #f (not #\あ))
(test-eq #f (not ""))
(test-eq #f (not " "))
(test-eq #f (not "a"))
(test-eq #f (not "A"))
(test-eq #f (not "aBc12!"))
(test-eq #f (not "あ"))
(test-eq #f (not "あ0イう12!"))
(test-eq #f (not +))
(test-eq #f (not (lambda () #t)))

;; syntactic keywords should not be appeared as operand
(if sigscheme?
    (begin
      ;; pure syntactic keyword
      (test-error (not else))
      ;; expression keyword
      (test-argcheck-error (not do))))

(call-with-current-continuation
 (lambda (k)
   (test-eq #f (not k))))
(test-eq #f (not (current-output-port)))
(test-eq #f (not '(#t . #t)))
(test-eq #f (not (cons #t #t)))
(test-eq #f (not '(0 1 2)))
(test-eq #f (not (list 0 1 2)))
(test-eq #f (not '#()))
(test-eq #f (not (vector)))
(test-eq #f (not '#(0 1 2)))
(test-eq #f (not (vector 0 1 2)))
(test-end "not")

(test-begin "boolean?")
(test-eq #t (boolean? #f))
(test-eq #t (boolean? #t))
(test-eq #f (boolean? '()))
(if (provided? "sigscheme")
    (begin
      (test-eq #f (boolean? (eof)))
      (test-eq #f (boolean? (undef)))))
(test-eq #f (boolean? 0))
(test-eq #f (boolean? 1))
(test-eq #f (boolean? 3))
(test-eq #f (boolean? -1))
(test-eq #f (boolean? -3))
(test-eq #f (boolean? 'symbol))
(test-eq #f (boolean? 'SYMBOL))
(test-eq #f (boolean? #\a))
(test-eq #f (boolean? #\あ))
(test-eq #f (boolean? ""))
(test-eq #f (boolean? " "))
(test-eq #f (boolean? "a"))
(test-eq #f (boolean? "A"))
(test-eq #f (boolean? "aBc12!"))
(test-eq #f (boolean? "あ"))
(test-eq #f (boolean? "あ0イう12!"))
(test-eq #f (boolean? +))
(test-eq #f (boolean? (lambda () #t)))

;; syntactic keywords should not be appeared as operand
(if sigscheme?
    (begin
      ;; pure syntactic keyword
      (test-error (boolean? else))
      ;; expression keyword
      (test-argcheck-error (boolean? do))))

(call-with-current-continuation
 (lambda (k)
   (test-eq #f (boolean? k))))
(test-eq #f (boolean? (current-output-port)))
(test-eq #f (boolean? '(#t . #t)))
(test-eq #f (boolean? (cons #t #t)))
(test-eq #f (boolean? '(0 1 2)))
(test-eq #f (boolean? (list 0 1 2)))
(test-eq #f (boolean? '#()))
(test-eq #f (boolean? (vector)))
(test-eq #f (boolean? '#(0 1 2)))
(test-eq #f (boolean? (vector 0 1 2)))
(test-end "boolean?")

(test-end "test-bool")
