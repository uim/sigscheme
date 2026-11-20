#! /usr/bin/env sscm -C UTF-8
;; -*- buffer-file-coding-system: utf-8 -*-

;;  Filename : test-list.scm
;;  About    : unit test for list operations
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

(if (not (provided? "r6rs-chars"))
    (test-skip-file "R6RS characters is not enabled"))

(test-begin "test-list")

(define elm0 (list #t))
(define elm1 (list #t))
(define elm2 (list #t))
(define elm3 (list #t))
(define nil  '())
(define cdr3 (cons elm3 nil))
(define cdr2 (cons elm2 cdr3))
(define cdr1 (cons elm1 cdr2))
(define cdr0 (cons elm0 cdr1))
(define lst cdr0)
;; circular lists
(define clst1 (list 1))
(set-cdr! clst1 clst1)
(define clst2 (list 1 2))
(set-cdr! (list-tail clst2 1) clst2)
(define clst3 (list 1 2 3))
(set-cdr! (list-tail clst3 2) clst3)
(define clst4 (list 1 2 3 4))
(set-cdr! (list-tail clst4 3) clst4)


(test-begin "null?")
(test-eq #f (null? #f))
(test-eq #f (null? #t))
(test-eq #t (null? '()))
(if (provided? "sigscheme")
    (begin
      (test-eq #f (null? (eof)))
      (test-eq #f (null? (undef)))))
(test-eq #f (null? 0))
(test-eq #f (null? 1))
(test-eq #f (null? 3))
(test-eq #f (null? -1))
(test-eq #f (null? -3))
(test-eq #f (null? 'symbol))
(test-eq #f (null? 'SYMBOL))
(test-eq #f (null? #\a))
(test-eq #f (null? #\あ))
(test-eq #f (null? ""))
(test-eq #f (null? " "))
(test-eq #f (null? "a"))
(test-eq #f (null? "A"))
(test-eq #f (null? "aBc12!"))
(test-eq #f (null? "あ"))
(test-eq #f (null? "あ0イう12!"))
(test-eq #f (null? +))
(test-eq #f (null? (lambda () #t)))

;; syntactic keywords should not be appeared as operand
(if sigscheme?
    (begin
      ;; pure syntactic keyword
      (test-error (null? else))
      ;; expression keyword
      (test-error (null? do))))

(call-with-current-continuation
 (lambda (k)
   (test-eq #f (null? k))))
(test-eq #f (null? (current-output-port)))
(test-eq #f (null? '(#t . #t)))
(test-eq #f (null? (cons #t #t)))
(test-eq #f (null? '(0 1 2)))
(test-eq #f (null? (list 0 1 2)))
;; improper lists
(test-eq #f (null? '(0 . 1)))
(test-eq #f (null? '(0 1 . 2)))
(test-eq #f (null? '(0 1 2 . 3)))
;; circular lists
(test-eq #f (null? clst1))
(test-eq #f (null? clst2))
(test-eq #f (null? clst3))
(test-eq #f (null? clst4))
(test-eq #f (null? '#()))
(test-eq #f (null? (vector)))
(test-eq #f (null? '#(0 1 2)))
(test-eq #f (null? (vector 0 1 2)))
(test-end "null?")

(test-begin "list?")
(test-eq #f (list? #f))
(test-eq #f (list? #t))
(test-eq #t (list? '()))
(if (provided? "sigscheme")
    (begin
      (test-eq #f (list? (eof)))
      (test-eq #f (list? (undef)))))
(test-eq #f (list? 0))
(test-eq #f (list? 1))
(test-eq #f (list? 3))
(test-eq #f (list? -1))
(test-eq #f (list? -3))
(test-eq #f (list? 'symbol))
(test-eq #f (list? 'SYMBOL))
(test-eq #f (list? #\a))
(test-eq #f (list? #\あ))
(test-eq #f (list? ""))
(test-eq #f (list? " "))
(test-eq #f (list? "a"))
(test-eq #f (list? "A"))
(test-eq #f (list? "aBc12!"))
(test-eq #f (list? "あ"))
(test-eq #f (list? "あ0イう12!"))
(test-eq #f (list? +))
(test-eq #f (list? (lambda () #t)))

;; syntactic keywords should not be appeared as operand
(if sigscheme?
    (begin
      ;; pure syntactic keyword
      (test-error (list? else))
      ;; expression keyword
      (test-error (list? do))))

(call-with-current-continuation
 (lambda (k)
   (test-eq #f (list? k))))
(test-eq #f (list? (current-output-port)))
(test-eq #f (list? '(#t . #t)))
(test-eq #f (list? (cons #t #t)))
(test-eq #t (list? '(0 1 2)))
(test-eq #t (list? (list 0 1 2)))
;; improper lists
(test-eq #f (list? '(0 . 1)))
(test-eq #f (list? '(0 1 . 2)))
(test-eq #f (list? '(0 1 2 . 3)))
;; circular lists
(test-eq #f (list? clst1))
(test-eq #f (list? clst2))
(test-eq #f (list? clst3))
(test-eq #f (list? clst4))
(test-eq #f (list? '#()))
(test-eq #f (list? (vector)))
(test-eq #f (list? '#(0 1 2)))
(test-eq #f (list? (vector 0 1 2)))
(test-end "list?")

(test-begin "list? from R5RS examples")
(test-eq #t (list? '(a b c)))
(test-eq #t (list? '()))
(test-eq #f (list? '(a . b)))
(test-eq #f (list? '(a b . c)))
(test-eq #f (let ((x (list 'a)))
              (set-cdr! x x)
              (list? x)))
(test-end "list? from R5RS examples")

(test-begin "list")
(test-equal '() (list))
(test-equal '(a) (list 'a))
(test-equal '(7) (list (+ 3 4)))
(test-equal '(7 a c) (list (+ 3 4) 'a 'c))
(test-equal '(a 7 c) (list 'a (+ 3 4) 'c))
(test-equal '(a c 7) (list 'a 'c (+ 3 4)))
(test-error (list . 0))
(test-error (list 0 . 1))
(test-end "list")

(test-begin "length proper lists")
(test-equal 0 (length '()))
(test-equal 1 (length '(1)))
(test-equal 2 (length '(1 2)))
(test-equal 3 (length '(1 2 3)))
(test-equal 4 (length '(1 2 3 4)))
(test-end "length proper lists")
(test-begin "length improper lists")
(test-error (length #t))
(test-error (length '(#t . #t)))
(test-error (length '(#t #t . #t)))
(test-error (length '(#t #t #t . #t)))
(test-error (length '(#t #t #t #t . #t)))
(test-error (length 0))
(test-error (length '(1 . 2)))
(test-error (length '(1 2 . 3)))
(test-error (length '(1 2 3 . 4)))
(test-error (length '(1 2 3 4 . 5)))
(test-end "length improper lists")
(test-begin "length circular lists")
(test-error (length clst1))
(test-error (length clst2))
(test-error (length clst3))
(test-error (length clst4))
(test-end "length circular lists")
(test-begin "length from R5RS examples")
(test-equal 3 (length '(a b c)))
(test-equal 3 (length '(a (b) (c d e))))
(test-equal 0 (length '()))
(test-end "length from R5RS examples")

(test-begin "append")
(test-equal '() (append))
(test-equal '() (append '()))
(test-equal '() (append '() '()))
(test-equal '() (append '() '() '()))
(test-equal '(a) (append '(a) '() '()))
(test-equal '(a) (append '() '(a) '()))
(test-equal '(a) (append '() '() '(a)))
(test-equal 'a (append 'a))
(test-error (append 'a 'b))
(test-error (append 'a '(b)))
(test-error (append 'a '()))
(test-equal '(a . b) (append '(a . b)))
(test-error (append '(a . b) '()))
(test-error (append '() '(a . b) '()))
(test-equal '(a . b) (append '() '() '(a . b)))
(test-equal '(1 2 3 a . b) (append '(1) '(2 3) '(a . b)))
(test-equal 7 (append (+ 3 4)))
(test-equal '(+ 3 4) (append '(+ 3 4)))

(test-equal '(x y) (append '(x) '(y)))
(test-equal '(a b c d) (append '(a) '(b c d)))
(test-equal '(a (b) (c)) (append '(a (b)) '((c))))
(define w '(n o))
(define x '(d o))
(define y '(car))
(define z '(why))
(test-equal '(n o d o car why . ta) (append w x y () z 'ta))
(test-equal '(n o) w)	; test non-destructiveness
(test-eq x (cdr (append '((Calpis hosi-)) x))) ; share last
(test-end "append")

(test-begin "append from R5RS examples")
(test-equal '(x y)       (append '(x) '(y)))
(test-equal '(a b c d)   (append '(a) '(b c d)))
(test-equal '(a (b) (c)) (append '(a (b)) '((c))))
(test-equal '(a b c . d) (append '(a b) '(c . d)))
(test-equal 'a           (append '() 'a))
(test-end "append from R5RS examples")

(test-begin "reverse")
(test-equal '() (reverse '()))
(test-error (reverse))
(test-error (reverse '(a . b)))
(test-error (reverse 'a))
(test-error (reverse '() '()))
(test-error (reverse '(a) '()))
(test-error (reverse '() '(a)))
(test-end "reverse")

(test-begin "reverse from R5RS examples")
(test-equal '(c b a) (reverse '(a b c)))
(test-equal '((e (f)) d (b c) a) (reverse '(a (b c) d (e (f)))))
(test-end "reverse from R5RS examples")

(test-begin "list-tail")
(test-equal '(a b c)   (list-tail '(a b c) 0))
(test-equal '(b c)     (list-tail '(a b c) 1))
(test-equal '(c)       (list-tail '(a b c) 2))
(test-equal '()        (list-tail '(a b c) 3))
(test-error (list-tail '(a b c) 4))
(test-error (list-tail '(a b c) -1))
(test-equal '()        (list-tail '() 0))
(test-error (list-tail '() 1))
(test-error (list-tail '() -1))
(test-eq cdr0       (list-tail lst 0))
(test-eq cdr1       (list-tail lst 1))
(test-eq cdr2       (list-tail lst 2))
(test-eq cdr3       (list-tail lst 3))
(test-eq nil        (list-tail lst 4))
(test-error (list-tail lst 5))
(test-error (list-tail lst -1))
(test-end "list-tail")

(test-begin "list-tail improper list")
(test-equal '(a b c . d) (list-tail '(a b c . d) 0))
(test-equal '(b c . d)   (list-tail '(a b c . d) 1))
(test-equal '(c . d)     (list-tail '(a b c . d) 2))
(test-equal 'd           (list-tail '(a b c . d) 3))
(test-error (list-tail '(a b c . d) 4))
(test-error (list-tail '(a b c . d) -1))
(test-equal 'a           (list-tail 'a 0))
(test-error (list-tail 'a 1))
(test-error (list-tail 'a -1))
(test-end "list-tail improper list")

(test-begin "list-ref")
(test-equal 'a         (list-ref '(a b c d) 0))
(test-equal 'b         (list-ref '(a b c d) 1))
(test-equal 'c         (list-ref '(a b c d) 2))
(test-equal 'd         (list-ref '(a b c d) 3))
(test-error (list-ref '(a b c d) 4))
(test-error (list-ref '(a b c d) -1))
(test-error (list-ref '() 0))
(test-error (list-ref '() 1))
(test-error (list-ref '() -1))
(test-eq elm0       (list-ref lst 0))
(test-eq elm1       (list-ref lst 1))
(test-eq elm2       (list-ref lst 2))
(test-eq elm3       (list-ref lst 3))
(test-error (list-ref lst 4))
(test-error (list-ref lst -1))
(test-end "list-ref")

(test-begin "list-ref improper list")
(test-equal 'a         (list-ref '(a b c . d) 0))
(test-equal 'b         (list-ref '(a b c . d) 1))
(test-equal 'c         (list-ref '(a b c . d) 2))
(test-error (list-ref '(a b c . d) 3))
(test-error (list-ref '(a b c . d) 4))
(test-error (list-ref '(a b c . d) -1))
(test-error (list-ref 'a 0))
(test-error (list-ref 'a 1))
(test-error (list-ref 'a -1))
(test-end "list-ref improper list")

(if sigscheme?
    (begin
      (require-extension (sscm-ext))
      (test-begin "length* proper list")
      (test-equal 0 (length* '()))
      (test-equal 1 (length* '(1)))
      (test-equal 2 (length* '(1 2)))
      (test-equal 3 (length* '(1 2 3)))
      (test-equal 4 (length* '(1 2 3 4)))
      (test-end "length* proper list")
      (test-begin "length* dotted list")
      (test-equal -1 (length* 1))
      (test-equal -2 (length* '(1 . 2)))
      (test-equal -3 (length* '(1 2 . 3)))
      (test-equal -4 (length* '(1 2 3 . 4)))
      (test-equal -5 (length* '(1 2 3 4 . 5)))
      (test-end "length* dotted list")
      (test-begin "length* circular list")
      (test-eq #f (length* clst1))
      (test-eq #f (length* clst2))
      (test-eq #f (length* clst3))
      (test-eq #f (length* clst4))
      (test-end "length* circular list")))

(test-end "test-list")
