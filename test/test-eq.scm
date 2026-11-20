#! /usr/bin/env sscm -C UTF-8
;; -*- buffer-file-coding-system: utf-8 -*-

;;  Filename : test-eq.scm
;;  About    : unit tests for eq?
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

(test-begin "test-eq")
(define case-insensitive-symbol? #f)

(test-begin "eq? invalid form")
(test-error (eq?))
(test-error (eq? #f))
(test-error (eq? #f #f #f))
(test-end "eq? invalid form")

(test-begin "eq? different types")
(test-eq #f (eq? 1 #\1))
(test-eq #f (eq? #\1 "1"))
(test-eq #f (eq? #\1 '("1")))
(test-eq #f (eq? '#("1") '("1")))
(test-end "eq? different types")

(test-begin "eq? boolean")
(test-eq #t (eq? #f #f))
(test-eq #f (eq? #f #t))
(test-eq #f (eq? #t #f))
(test-eq #t (eq? #t #t))
(test-end "eq? boolean")

(test-begin "eq? null")
(test-eq #t (eq? '() '()))
(test-eq #f (eq? #f '()))
(test-eq #f (eq? '() #f))
(if (symbol-bound? 'vector?)
    (begin
      (test-eq #f (eq? '() '#()))
      (test-eq #f (eq? '#() '()))))
(test-end "eq? null")

(test-begin "eq? #<eof>")
(if (provided? "sigscheme")
    (begin
      (test-eq #t (eq? (eof) (eof)))
      (test-eq #f (eq? (eof) (undef)))
      (test-eq #f (eq? (undef) (eof)))
      (test-eq #f (eq? '() (eof)))
      (test-eq #f (eq? (eof) '()))
      (test-eq #f (eq? #f (eof)))
      (test-eq #f (eq? (eof) #f))))
(test-end "eq? #<eof>")

(test-begin "eq? #<undef>")
(if (provided? "sigscheme")
    (begin
      (test-eq #t (eq? (undef) (undef)))
      (test-eq #f (eq? (eof) (undef)))
      (test-eq #f (eq? (undef) (eof)))
      (test-eq #f (eq? '() (undef)))
      (test-eq #f (eq? (undef) '()))
      (test-eq #f (eq? #f (undef)))
      (test-eq #f (eq? (undef) #f))))
(test-end "eq? #<undef>")

(test-begin "eq? integer")
(if (and (provided? "sigscheme")
         (provided? "immediate-number-only"))
    (begin
      (test-eq #t (eq? 0 0))
      (test-eq #t (eq? 1 1))
      (test-eq #t (eq? 3 3))
      (test-eq #t (eq? -1 -1))
      (test-eq #t (eq? -3 -3))

      (test-eq #f (eq? 0 1))
      (test-eq #f (eq? 1 0))
      (test-eq #f (eq? 1 3))
      (test-eq #f (eq? 3 1))
      (test-eq #f (eq? -1 1))
      (test-eq #f (eq? 1 -1))
      (test-eq #f (eq? -3 3))
      (test-eq #f (eq? 3 -3))
      (test-eq #f (eq? -1 -3))
      (test-eq #f (eq? -3 -1))))
(test-end "eq? integer")

(test-begin "eq? symbol")
(test-eq #t (eq? 'symbol 'symbol))
(test-eq #f (eq? 'symbol1 'symbol2))
(if (and (provided? "sigscheme")
         (provided? "strict-r5rs")
         case-insensitive-symbol?)
    (begin
      (test-eq #t (eq? 'symbol 'SYMBOL))
      (test-eq #t (eq? 'SYMBOL 'symbol))
      (test-eq #t (eq? 'symbol 'Symbol))
      (test-eq #t (eq? 'Symbol 'symbol))
      (test-eq #t (eq? 'symbol 'syMBoL))
      (test-eq #t (eq? 'syMBoL 'symbol)))
    (begin
      (test-eq #f (eq? 'symbol 'SYMBOL))
      (test-eq #f (eq? 'SYMBOL 'symbol))
      (test-eq #f (eq? 'symbol 'Symbol))
      (test-eq #f (eq? 'Symbol 'symbol))
      (test-eq #f (eq? 'symbol 'syMBoL))
      (test-eq #f (eq? 'syMBoL 'symbol))))
(test-end "eq? symbol")

(test-begin "eq? singlebyte char")
(if (provided? "sigscheme")
    (if (provided? "immediate-char-only")
        (begin
          (test-eq #t (eq? #\a #\a))
          (test-eq #f (eq? #\a #\b))
          (test-eq #f (eq? #\b #\a))
          (test-eq #t (eq? #\b #\b)))
        (begin
          (test-eq #f (eq? #\a #\a))
          (test-eq #f (eq? #\a #\b))
          (test-eq #f (eq? #\b #\a))
          (test-eq #f (eq? #\b #\b)))))

(let ((c1 #\a)
      (c2 #\b))
  (test-eq #t (eq? c1 c1))
  (test-eq #t (eq? c2 c2)))
(test-end "eq? singlebyte char")

(test-begin "eq? multibyte char")
(if (provided? "sigscheme")
    (if (provided? "immediate-char-only")
        (begin
          (test-eq #t (eq? #\あ #\あ))
          (test-eq #f (eq? #\あ #\い))
          (test-eq #f (eq? #\い #\あ))
          (test-eq #t (eq? #\い #\い)))
        (begin
          (test-eq #f (eq? #\あ #\あ))
          (test-eq #f (eq? #\あ #\い))
          (test-eq #f (eq? #\い #\あ))
          (test-eq #f (eq? #\い #\い)))))

(let ((c1 #\あ)
      (c2 #\い))
  (test-eq #t (eq? c1 c1))
  (test-eq #t (eq? c2 c2)))
(test-end "eq? multibyte char")

(test-begin "eq? singlebyte string")
(if (provided? "sigscheme")
    (begin
      (test-eq #f (eq? "" ""))
      (test-eq #f (eq? "a" "a"))
      (test-eq #f (eq? "b" "b"))
      (test-eq #f (eq? "aBc12!" "aBc12!"))))
(let ((s1 "")
      (s2 "a")
      (s3 "b")
      (s4 "aBc12!"))
  (test-eq #t (eq? s1 s1))
  (test-eq #t (eq? s2 s2))
  (test-eq #t (eq? s3 s3))
  (test-eq #t (eq? s4 s4)))
(test-eq #f (eq? "" "a"))
(test-eq #f (eq? "a" ""))
(test-eq #f (eq? "a" "b"))
(test-eq #f (eq? "b" "a"))
(test-eq #f (eq? "a" "A"))
(test-eq #f (eq? "A" "a"))
(test-eq #f (eq? "aBc123!" "aBc12!"))
(test-eq #f (eq? "aBc12!" "aBc123!"))
(test-end "eq? singlebyte string")

(test-begin "eq? multibyte string")
(if (provided? "sigscheme")
    (begin
      (test-eq #f (eq? "あ" "あ"))
      (test-eq #f (eq? "い" "い"))
      (test-eq #f (eq? "あ0イう12!" "あ0イう12!"))))
(let ((s1 "あ")
      (s2 "い")
      (s3 "あ0イう12!"))
  (test-eq #t (eq? s1 s1))
  (test-eq #t (eq? s2 s2))
  (test-eq #t (eq? s3 s3)))
(test-eq #f (eq? "" "あ"))
(test-eq #f (eq? "あ" ""))
(test-eq #f (eq? "あ" "い"))
(test-eq #f (eq? "い" "あ"))
(test-eq #f (eq? "あ" "ア"))
(test-eq #f (eq? "ア" "あ"))
(test-eq #f (eq? "あ0イうぇ12!" "あ0イう12!"))
(test-eq #f (eq? "あ0イう12!" "あ0イうぇ12!"))
(test-end "eq? multibyte string")

(test-begin "eq? procedure")
(test-eq #t (eq? + +))
(test-eq #f (eq? + -))
(test-eq #f (eq? - +))
(test-eq #t (eq? - -))
(let ((plus +))
  (test-eq #t (eq? + plus))
  (test-eq #t (eq? plus +))
  (test-eq #t (eq? plus plus)))
(test-end "eq? procedure")

(test-begin "eq? syntax")
(test-error (eq? if if))
(test-error (eq? if set!))
(test-error (eq? set! if))
(test-error (eq? set! set!))
(test-end "eq? syntax")
;; (define syntax if) is an invalid form

(test-begin "eq? macro")
(if (symbol-bound? 'let-syntax)
    (let-syntax ((macro1 (syntax-rules ()
                           ((_) 'macro1-expanded)))
                 (macro2 (syntax-rules ()
                           ((_) 'macro2-expanded))))
      ;; syntactic keyword as value
      (test-error (eq? macro1 macro1))
      (test-error (eq? macro2 macro1))
      (test-error (eq? macro1 macro2))
      (test-error (eq? macro2 macro2))))
(test-end "eq? macro")

(test-begin "eq? closure")
(let ((closure (lambda () #t)))
  (test-eq #t (eq? closure closure))
  (if (provided? "sigscheme")
      (begin
        (test-eq #f (eq? closure (lambda () #t)))
        (test-eq #f (eq? (lambda () #t) closure))
        (test-eq #f (eq? (lambda () #t) (lambda () #t))))))
(test-end "eq? closure")

(test-begin "eq? stateful closure")
(let ((stateful (lambda ()
                  (let ((state 0))
                    (lambda ()
                      (set! state (+ state 1))
                      state)))))
  (test-eq #t (eq? stateful stateful))
  (test-eq #f (eq? (stateful) (stateful))))

(let ((may-be-optimized-out (lambda ()
                              (let ((state 0))
                                (lambda ()
                                  (set! state (+ state 1))
                                  0)))))
  (test-eq #t (eq? may-be-optimized-out may-be-optimized-out))
  (if (provided? "sigscheme")
      (test-eq #f (eq? (may-be-optimized-out) (may-be-optimized-out)))))

(letrec ((may-be-unified1 (lambda ()
                            (if (eq? may-be-unified1
                                     may-be-unified2)
                                'optimized-out
                                'not-unified1)))
         (may-be-unified2 (lambda ()
                            (if (eq? may-be-unified1
                                     may-be-unified2)
                                'optimized-out
                                'not-unified2))))
  (if (provided? "sigscheme")
      (begin
        (test-eq #f (eq? may-be-unified1 may-be-unified2))
        (test-eq #f (eq? (may-be-unified1) (may-be-unified2))))
      (begin
        ;; other implementations may pass this
        ;;(test-eq #t (eq? may-be-unified1 may-be-unified2))
        ;;(test-eq #t (eq? (may-be-unified1) (may-be-unified2)))
        )))
(test-end "eq? stateful closure")

(test-begin "eq? continuation")
(call-with-current-continuation
 (lambda (k1)
   (call-with-current-continuation
    (lambda (k2)
      (test-eq #t (eq? k1 k1))
      (test-eq #f (eq? k1 k2))
      (test-eq #f (eq? k2 k1))
      (test-eq #t (eq? k2 k2))
      (let ((cont k1))
        (test-eq #t (eq? cont cont))
        (test-eq #t (eq? cont k1))
        (test-eq #t (eq? k1 cont))
        (test-eq #f (eq? cont k2))
        (test-eq #f (eq? k2 cont)))))))
(test-end "eq? continuation")

(test-begin "eq? port")
(test-eq #t (eq? (current-output-port) (current-output-port)))
(test-eq #f (eq? (current-input-port) (current-output-port)))
(test-eq #f (eq? (current-output-port) (current-input-port)))
(test-eq #t (eq? (current-input-port) (current-input-port)))
(let ((port (current-input-port)))
  (test-eq #t (eq? port port))
  (test-eq #t (eq? (current-input-port) port))
  (test-eq #t (eq? port (current-input-port)))
  (test-eq #f (eq? (current-output-port) port))
  (test-eq #f (eq? port (current-output-port))))
(test-end "eq? port")

(test-begin "eq? pair")
(if (provided? "sigscheme")
    (begin
      (test-eq #f (eq? '(#t . #t) '(#t . #t)))
      (test-eq #f (eq? '(#f . #t) '(#f . #t)))
      (test-eq #f (eq? '(#t . #f) '(#t . #f)))
      (test-eq #f (eq? '(#f . #t) '(#t . #f)))
      (test-eq #f (eq? '(#\a . #\a) '(#\a . #\a)))
      (test-eq #f (eq? '(#\a . #\b) '(#\a . #\b)))
      (test-eq #f (eq? '(#\b . #\a) '(#\b . #\a)))
      (test-eq #f (eq? '(#\a . #\b) '(#\b . #\a)))
      (test-eq #f (eq? '("a" . "a") '("a" . "a")))
      (test-eq #f (eq? '("a" . "b") '("a" . "b")))
      (test-eq #f (eq? '("b" . "a") '("b" . "a")))
      (test-eq #f (eq? '("a" . "b") '("b" . "a")))))

(test-eq #f (eq? (cons #t #t) (cons #t #t)))
(test-eq #f (eq? (cons #f #t) (cons #f #t)))
(test-eq #f (eq? (cons #t #f) (cons #t #f)))
(test-eq #f (eq? (cons #f #t) (cons #t #f)))
(test-eq #f (eq? (cons #\a #\a) (cons #\a #\a)))
(test-eq #f (eq? (cons #\a #\b) (cons #\a #\b)))
(test-eq #f (eq? (cons #\b #\a) (cons #\b #\a)))
(test-eq #f (eq? (cons #\a #\b) (cons #\b #\a)))
(test-eq #f (eq? (cons "a" "a") (cons "a" "a")))
(test-eq #f (eq? (cons "a" "b") (cons "a" "b")))
(test-eq #f (eq? (cons "b" "a") (cons "b" "a")))
(test-eq #f (eq? (cons "a" "b") (cons "b" "a")))
(test-end "eq? pair")

(test-begin "eq? list")
(if (provided? "sigscheme")
    (begin
      (test-eq #f (eq? '(#f) '(#f)))
      (test-eq #f (eq? '(#f) '(#t)))
      (test-eq #f (eq? '(#t) '(#f)))
      (test-eq #f (eq? '(#t) '(#t)))
      (test-eq #f (eq? '((#f)) '((#f))))
      (test-eq #f (eq? '((#f)) '((#t))))
      (test-eq #f (eq? '((#t)) '((#f))))
      (test-eq #f (eq? '((#t)) '((#t))))
      (test-eq #f (eq? '(1) '(1)))
      (test-eq #f (eq? '(1) '(0)))
      (test-eq #f (eq? '(1 3 5 0 13)
                       '(1 3 5 0 13)))
      (test-eq #f (eq? '(1 3 2 0 13)
                       '(1 3 5 0 13)))
      (test-eq #f (eq? '(1 3 (5 0 13))
                       '(1 3 (5 0 13))))
      (test-eq #f (eq? '(1 3 (2 0 13))
                       '(1 3 (5 0 13))))
      (test-eq #f (eq? '((1)) '((1))))
      (test-eq #f (eq? '((1)) '((0))))
      (test-eq #f (eq? '((1) (3) (5) (0) (13))
                       '((1) (3) (5) (0) (13))))
      (test-eq #f (eq? '((1) (3) (2) (0) (13))
                       '((1) (3) (5) (0) (13))))
      (test-eq #f (eq? '(#\a) '(#\a)))
      (test-eq #f (eq? '(#\a) '(#\b)))
      (test-eq #f (eq? '(#\b) '(#\a)))
      (test-eq #f (eq? '((#\a)) '((#\a))))
      (test-eq #f (eq? '((#\a)) '((#\b))))
      (test-eq #f (eq? '((#\b)) '((#\a))))))

(test-eq #f (eq? (list #f) (list #f)))
(test-eq #f (eq? (list #f) (list #t)))
(test-eq #f (eq? (list #t) (list #f)))
(test-eq #f (eq? (list #t) (list #t)))
(test-eq #f (eq? (list (list #f)) (list (list #f))))
(test-eq #f (eq? (list (list #f)) (list (list #t))))
(test-eq #f (eq? (list (list #t)) (list (list #f))))
(test-eq #f (eq? (list (list #t)) (list (list #t))))
(test-eq #f (eq? (list 1) (list 1)))
(test-eq #f (eq? (list 1) (list 0)))
(test-eq #f (eq? (list 1 3 5 0 13)
                 (list 1 3 5 0 13)))
(test-eq #f (eq? (list 1 3 2 0 13)
                 (list 1 3 5 0 13)))
(test-eq #f (eq? (list 1 3 (list 5 0 13))
                 (list 1 3 (list 5 0 13))))
(test-eq #f (eq? (list 1 3 (list 2 0 13))
                 (list 1 3 (list 5 0 13))))
(test-eq #f (eq? (list (list 1)) (list (list 1))))
(test-eq #f (eq? (list (list 1)) (list (list 0))))
(test-eq #f (eq? (list (list 1) (list 3) (list 5) (list 0) (list 13))
                 (list (list 1) (list 3) (list 5) (list 0) (list 13))))
(test-eq #f (eq? (list (list 1) (list 3) (list 2) (list 0) (list 13))
                 (list (list 1) (list 3) (list 5) (list 0) (list 13))))
(test-eq #f (eq? (list #\a) (list #\a)))
(test-eq #f (eq? (list #\a) (list #\b)))
(test-eq #f (eq? (list #\b) (list #\a)))
(test-eq #f (eq? (list (list #\a)) (list (list #\a))))
(test-eq #f (eq? (list (list #\a)) (list (list #\b))))
(test-eq #f (eq? (list (list #\b)) (list (list #\a))))

(if (provided? "sigscheme")
    (begin
      (test-eq #f (eq? '("") '("")))
      (test-eq #f (eq? '(("")) '((""))))
      (test-eq #f (eq? '("aBc12!")
                       '("aBc12!")))
      (test-eq #f (eq? '("あ0イう12!")
                       '("あ0イう12!")))
      (test-eq #f (eq? '("a" "" "aB1" ("3c" "d") "a")
                       '("a" "" "aB1" ("3c" "d") "a")))
      (test-eq #f (eq? '(("aBc12!"))
                       '(("aBc12!"))))
      (test-eq #f (eq? '(("あ0イう12!"))
                       '(("あ0イう12!"))))))

(test-eq #f (eq? (list "") (list "")))
(test-eq #f (eq? (list (list "")) (list (list ""))))
(test-eq #f (eq? (list "aBc12!")
                 (list "aBc12!")))
(test-eq #f (eq? (list "あ0イう12!")
                 (list "あ0イう12!")))
(test-eq #f (eq? (list "a" "" "aB1" (list "3c" "d") "a")
                 (list "a" "" "aB1" (list "3c" "d") "a")))
(test-eq #f (eq? (list (list "aBc12!"))
                 (list (list "aBc12!"))))
(test-eq #f (eq? (list (list "あ0イう12!"))
                 (list (list "あ0イう12!"))))

(if (provided? "sigscheme")
    (begin
      (test-eq #f (eq? '("aBc123!")
                       '("aBc12!")))
      (test-eq #f (eq? '("あ0イぅ12!")
                       '("あ0イう12!")))
      (test-eq #f (eq? '("a" "" "aB1" ("3c" "e") "a")
                       '("a" "" "aB1" ("3c" "d") "a")))
      (test-eq #f (eq? '(("aBc123!"))
                       '(("aBc12!"))))
      (test-eq #f (eq? '(("あ0イぅ12!"))
                       '(("あ0イう12!"))))))

(test-eq #f (eq? (list "aBc123!")
                 (list "aBc12!")))
(test-eq #f (eq? (list "あ0イぅ12!")
                 (list "あ0イう12!")))
(test-eq #f (eq? (list "a" "" "aB1" (list "3c" "e") "a")
                 (list "a" "" "aB1" (list "3c" "d") "a")))
(test-eq #f (eq? (list (list "aBc123!"))
                 (list (list "aBc12!"))))
(test-eq #f (eq? (list (list "あ0イぅ12!"))
                 (list (list "あ0イう12!"))))

(if (provided? "sigscheme")
    (begin
      (test-eq #f
          (eq? '(0 #\a "" #("vE" -1 (#\?)) 23 + "aBc" (-1 #\b ("Ls")) #t)
               '(0 #\a "" #("vE" -1 (#\?)) 23 + "aBc" (-1 #\b ("Ls")) #t)))
      (test-eq #f
          (eq? '(0 #\a "" #("vE" -1 (#\?)) 23 + "aBc" (-1 #\b ("Ls")) #t)
               '(0 #\a "" #("vE" -1 (#\?)) 23 + "aBc" (-1 #\b ("L")) #t)))
      (test-eq #f
          (eq? '(0 #\a "" #("vE" -1 (#\?)) 23 + "aBc" (-1 #\b ("Ls")) #t)
               '(0 #\a "" ("vE" -1 (#\?)) 23 + "aBc" (-1 #\b ("Ls")) #t)))
      (test-eq #f
          (eq? '(0 #\a "" #("vE" -1 (#\?)) 23 + "aBc" (-1 #\b ("Ls")) #t)
               '(0 #\a "" #("vE" -1 (#\?)) 23 + "aBc" #t)))
      (test-eq #f
          (eq? '(0 #\a "" #("vE" -1 (#\?)) 23 + "aBc" #t)
               '(0 #\a "" #("vE" -1 (#\?)) 23 + "aBc" (-1 #\b ("Ls")) #t)))))

(test-eq #f
    (eq? (list 0 #\a "" (vector "vE" -1 '(#\?)) 23 + "aBc" (list -1 #\b '("Ls")) #t)
         (list 0 #\a "" (vector "vE" -1 '(#\?)) 23 + "aBc" (list -1 #\b '("Ls")) #t)))
(test-eq #f
    (eq? (list 0 #\a "" (vector "vE" -1 '(#\?)) 23 + "aBc" (list -1 #\b '("Ls")) #t)
         (list 0 #\a "" (vector "vE" -1 '(#\?)) 23 + "aBc" (list -1 #\b '("L")) #t)))
(test-eq #f
    (eq? (list 0 #\a "" (vector "vE" -1 '(#\?)) 23 + "aBc" (list -1 #\b '("Ls")) #t)
         (list 0 #\a "" (list "vE" -1 '(#\?))  23 + "aBc" (list -1 #\b '("Ls")) #t)))
(test-eq #f
    (eq? (list 0 #\a "" (vector "vE" -1 '(#\?)) 23 + "aBc" (list -1 #\b '("Ls")) #t)
         (list 0 #\a "" (vector "vE" -1 '(#\?)) 23 + "aBc" #t)))
(test-eq #f
    (eq? (list 0 #\a "" (vector "vE" -1 '(#\?)) 23 + "aBc" #t)
         (list 0 #\a "" (vector "vE" -1 '(#\?)) 23 + "aBc" (list -1 #\b '("Ls")) #t)))
(test-end "eq? list")

(test-begin "eq? empty vector")
(if (provided? "sigscheme")
    (test-eq #f (eq? '#() '#())))
(test-eq #f (eq? (vector) (vector)))

(let ((v1 '#())
      (v2 (vector)))
  (test-eq #t (eq? v1 v1))
  (test-eq #t (eq? v2 v2))
  (test-eq #f (eq? v1 v2)))
(test-end "eq? empty vector")

(test-begin "eq? vector")
(if (provided? "sigscheme")
    (begin
      (test-eq #f (eq? '#(#f) '#(#f)))
      (test-eq #f (eq? '#(#f) '#(#t)))
      (test-eq #f (eq? '#(#t) '#(#f)))
      (test-eq #f (eq? '#(#t) '#(#t)))
      (test-eq #f (eq? '#(#(#f)) '#(#(#f))))
      (test-eq #f (eq? '#(#(#f)) '#(#(#t))))
      (test-eq #f (eq? '#(#(#t)) '#(#(#f))))
      (test-eq #f (eq? '#(#(#t)) '#(#(#t))))
      (test-eq #f (eq? '#(1) '#(1)))
      (test-eq #f (eq? '#(1) '#(0)))
      (test-eq #f (eq? '#(1 3 5 0 13)
                       '#(1 3 5 0 13)))
      (test-eq #f (eq? '#(1 3 2 0 13)
                       '#(1 3 5 0 13)))
      (test-eq #f (eq? '#(1 3 #(5 0 13))
                       '#(1 3 #(5 0 13))))
      (test-eq #f (eq? '#(1 3 #(2 0 13))
                       '#(1 3 #(5 0 13))))
      (test-eq #f (eq? '#(#(1)) '#(#(1))))
      (test-eq #f (eq? '#(#(1)) '#(#(0))))
      (test-eq #f (eq? '#(#(1) #(3) #(5) #(0) #(13))
                       '#(#(1) #(3) #(5) #(0) #(13))))
      (test-eq #f (eq? '#(#(1) #(3) #(2) #(0) #(13))
                       '#(#(1) #(3) #(5) #(0) #(13))))
      (test-eq #f (eq? '#(#\a) '#(#\a)))
      (test-eq #f (eq? '#(#\a) '#(#\b)))
      (test-eq #f (eq? '#(#\b) '#(#\a)))
      (test-eq #f (eq? '#(#(#\a)) '#(#(#\a))))
      (test-eq #f (eq? '#(#(#\a)) '#(#(#\b))))
      (test-eq #f (eq? '#(#(#\b)) '#(#(#\a))))))

(test-eq #f (eq? (vector #f) (vector #f)))
(test-eq #f (eq? (vector #f) (vector #t)))
(test-eq #f (eq? (vector #t) (vector #f)))
(test-eq #f (eq? (vector #t) (vector #t)))
(test-eq #f (eq? (vector (vector #f)) (vector (vector #f))))
(test-eq #f (eq? (vector (vector #f)) (vector (vector #t))))
(test-eq #f (eq? (vector (vector #t)) (vector (vector #f))))
(test-eq #f (eq? (vector (vector #t)) (vector (vector #t))))
(test-eq #f (eq? (vector 1) (vector 1)))
(test-eq #f (eq? (vector 1) (vector 0)))
(test-eq #f (eq? (vector 1 3 5 0 13)
                 (vector 1 3 5 0 13)))
(test-eq #f (eq? (vector 1 3 2 0 13)
                 (vector 1 3 5 0 13)))
(test-eq #f (eq? (vector 1 3 (vector 5 0 13))
                 (vector 1 3 (vector 5 0 13))))
(test-eq #f (eq? (vector 1 3 (vector 2 0 13))
                 (vector 1 3 (vector 5 0 13))))
(test-eq #f (eq? (vector (vector 1)) (vector (vector 1))))
(test-eq #f (eq? (vector (vector 1)) (vector (vector 0))))
(test-eq #f (eq? (vector (vector 1) (vector 3) (vector 5) (vector 0) (vector 13))
                 (vector (vector 1) (vector 3) (vector 5) (vector 0) (vector 13))))
(test-eq #f (eq? (vector (vector 1) (vector 3) (vector 2) (vector 0) (vector 13))
                 (vector (vector 1) (vector 3) (vector 5) (vector 0) (vector 13))))
(test-eq #f (eq? (vector #\a) (vector #\a)))
(test-eq #f (eq? (vector #\a) (vector #\b)))
(test-eq #f (eq? (vector #\b) (vector #\a)))
(test-eq #f (eq? (vector (vector #\a)) (vector (vector #\a))))
(test-eq #f (eq? (vector (vector #\a)) (vector (vector #\b))))
(test-eq #f (eq? (vector (vector #\b)) (vector (vector #\a))))

(if (provided? "sigscheme")
    (begin
      (test-eq #f (eq? '#("") '#("")))
      (test-eq #f (eq? '#(#("")) '#(#(""))))
      (test-eq #f (eq? '#("aBc12!")
                       '#("aBc12!")))
      (test-eq #f (eq? '#("あ0イう12!")
                       '#("あ0イう12!")))
      (test-eq #f (eq? '#("a" "" "aB1" #("3c" "d") "a")
                       '#("a" "" "aB1" #("3c" "d") "a")))
      (test-eq #f (eq? '#(#("aBc12!"))
                       '#(#("aBc12!"))))
      (test-eq #f (eq? '#(#("あ0イう12!"))
                       '#(#("あ0イう12!"))))))

(test-eq #f (eq? (vector "") (vector "")))
(test-eq #f (eq? (vector (vector "")) (vector (vector ""))))
(test-eq #f (eq? (vector "aBc12!")
                 (vector "aBc12!")))
(test-eq #f (eq? (vector "あ0イう12!")
                 (vector "あ0イう12!")))
(test-eq #f (eq? (vector "a" "" "aB1" (vector "3c" "d") "a")
                 (vector "a" "" "aB1" (vector "3c" "d") "a")))
(test-eq #f (eq? (vector (vector "aBc12!"))
                 (vector (vector "aBc12!"))))
(test-eq #f (eq? (vector (vector "あ0イう12!"))
                 (vector (vector "あ0イう12!"))))

(if (provided? "sigscheme")
    (begin
      (test-eq #f (eq? '#("aBc123!")
                       '#("aBc12!")))
      (test-eq #f (eq? '#("あ0イぅ12!")
                       '#("あ0イう12!")))
      (test-eq #f (eq? '#("a" "" "aB1" #("3c" "e") "a")
                       '#("a" "" "aB1" #("3c" "d") "a")))
      (test-eq #f (eq? '#(#("aBc123!"))
                       '#(#("aBc12!"))))
      (test-eq #f (eq? '#(#("あ0イぅ12!"))
                       '#(#("あ0イう12!"))))))

(test-eq #f (eq? (vector "aBc123!")
                 (vector "aBc12!")))
(test-eq #f (eq? (vector "あ0イぅ12!")
                 (vector "あ0イう12!")))
(test-eq #f (eq? (vector "a" "" "aB1" (vector "3c" "e") "a")
                 (vector "a" "" "aB1" (vector "3c" "d") "a")))
(test-eq #f (eq? (vector (vector "aBc123!"))
                 (vector (vector "aBc12!"))))
(test-eq #f (eq? (vector (vector "あ0イぅ12!"))
                 (vector (vector "あ0イう12!"))))

(if (provided? "sigscheme")
    (begin
      (test-eq #f
          (eq? '#(0 #\a "" #("vE" -1 (#\?)) 23 + "aBc" (-1 #\b ("Ls")) #t)
               '#(0 #\a "" #("vE" -1 (#\?)) 23 + "aBc" (-1 #\b ("Ls")) #t)))
      (test-eq #f
          (eq? '#(0 #\a "" #("vE" -1 (#\?)) 23 + "aBc" (-1 #\b ("Ls")) #t)
               '#(0 #\a "" #("vE" -1 (#\?)) 23 + "aBc" (-1 #\b ("L")) #t)))
      (test-eq #f
          (eq? '#(0 #\a "" #("vE" -1 (#\?)) 23 + "aBc" (-1 #\b ("Ls")) #t)
               '#(0 #\a "" ("vE" -1 (#\?))  23 + "aBc" (-1 #\b ("Ls")) #t)))
      (test-eq #f
          (eq? '#(0 #\a "" #("vE" -1 (#\?)) 23 + "aBc" (-1 #\b ("Ls")) #t)
               '#(0 #\a "" #("vE" -1 (#\?)) 23 + "aBc" #t)))
      (test-eq #f
          (eq? '#(0 #\a "" #("vE" -1 (#\?)) 23 + "aBc" #t)
               '#(0 #\a "" #("vE" -1 (#\?)) 23 + "aBc" (-1 #\b ("Ls")) #t)))))

(test-eq #f
    (eq? (vector 0 #\a "" (vector "vE" -1 '(#\?)) 23 + "aBc" (vector -1 #\b '("Ls")) #t)
         (vector 0 #\a "" (vector "vE" -1 '(#\?)) 23 + "aBc" (vector -1 #\b '("Ls")) #t)))
(test-eq #f
    (eq? (vector 0 #\a "" (vector "vE" -1 '(#\?)) 23 + "aBc" (vector -1 #\b '("Ls")) #t)
         (vector 0 #\a "" (vector "vE" -1 '(#\?)) 23 + "aBc" (vector -1 #\b '("L")) #t)))
(test-eq #f
    (eq? (vector 0 #\a "" (vector "vE" -1 '(#\?)) 23 + "aBc" (vector -1 #\b '("Ls")) #t)
         (vector 0 #\a "" (list "vE" -1 '(#\?))   23 + "aBc" (vector -1 #\b '("Ls")) #t)))
(test-eq #f
    (eq? (vector 0 #\a "" (vector "vE" -1 '(#\?)) 23 + "aBc" (vector -1 #\b '("Ls")) #t)
         (vector 0 #\a "" (vector "vE" -1 '(#\?)) 23 + "aBc" #t)))
(test-eq #f
    (eq? (vector 0 #\a "" (vector "vE" -1 '(#\?)) 23 + "aBc" #t)
         (vector 0 #\a "" (vector "vE" -1 '(#\?)) 23 + "aBc" (vector -1 #\b '("Ls")) #t)))
(test-end "eq? vector")


(test-end "test-eq")
