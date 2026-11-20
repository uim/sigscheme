#! /usr/bin/env sscm -C UTF-8
;; -*- buffer-file-coding-system: utf-8 -*-

;;  Filename : test-pair.scm
;;  About    : unit tests for pairs
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

(test-begin "test-pair")

(test-begin "pair?")
(test-eq #f (pair? #f))
(test-eq #f (pair? #t))
(test-eq #f (pair? '()))
(if (provided? "sigscheme")
    (begin
      (test-eq #f (pair? (eof)))
      (test-eq #f (pair? (undef)))))
(test-eq #f (pair? 0))
(test-eq #f (pair? 1))
(test-eq #f (pair? 3))
(test-eq #f (pair? -1))
(test-eq #f (pair? -3))
(test-eq #f (pair? 'symbol))
(test-eq #f (pair? 'SYMBOL))
(test-eq #f (pair? #\a))
(test-eq #f (pair? #\あ))
(test-eq #f (pair? ""))
(test-eq #f (pair? " "))
(test-eq #f (pair? "a"))
(test-eq #f (pair? "A"))
(test-eq #f (pair? "aBc12!"))
(test-eq #f (pair? "あ"))
(test-eq #f (pair? "あ0イう12!"))
(test-eq #f (pair? +))
(test-eq #f (pair? (lambda () #t)))

;; syntactic keywords should not be appeared as operand
(if sigscheme?
    (begin
      ;; pure syntactic keyword
      (test-error (pair? else))
      ;; expression keyword
      (test-error (pair? do))))

(call-with-current-continuation
 (lambda (k)
   (test-eq #f (pair? k))))
(test-eq #f (pair? (current-output-port)))
(test-eq #t (pair? '(#t . #t)))
(test-eq #t (pair? (cons #t #t)))
(test-eq #t (pair? '(0 1 2)))
(test-eq #t (pair? (list 0 1 2)))
(test-eq #f (pair? '#()))
(test-eq #f (pair? (vector)))
(test-eq #f (pair? '#(0 1 2)))
(test-eq #f (pair? (vector 0 1 2)))
(test-end "pair?")

(test-begin "cons")
(test-equal '(a) (cons 'a '()))
(test-equal '((a) b c d) (cons '(a) '(b c d)))
(test-equal '(a . 3) (cons 'a 3))
(test-equal '((a b) . c) (cons '(a b) 'c))
(test-equal '(a b c) (cons 'a '(b c)))
(test-end "cons")

(test-begin "car")
(test-equal 'a (car '(a b c)))
(test-equal '(a) (car '((a) b c)))
(test-equal 1 (car '(1 . 2)))
(test-error (car '()))
(test-end "car")

(test-begin "car various type objects")
(test-error (car #f))
(test-error (car #t))
(if (provided? "sigscheme")
    (begin
      (test-error (car (eof)))
      (test-error (car (undef)))))
(test-error (car 0))
(test-error (car 1))
(test-error (car 3))
(test-error (car -1))
(test-error (car -3))
(test-error (car 'symbol))
(test-error (car 'SYMBOL))
(test-error (car #\a))
(test-error (car #\あ))
(test-error (car ""))
(test-error (car " "))
(test-error (car "a"))
(test-error (car "A"))
(test-error (car "aBc12!"))
(test-error (car "あ"))
(test-error (car "あ0イう12!"))
(test-error (car +))
(test-error (car (lambda () #t)))

;; syntactic keywords should not be appeared as operand
(if sigscheme?
    (begin
      ;; pure syntactic keyword
      (test-error (car else))
      ;; expression keyword
      (test-error (car do))))

(call-with-current-continuation
 (lambda (k)
   (test-error (car k))))
(test-error (car (current-output-port)))
(test-equal #t (car '(#t . #t)))
(test-equal #t (car (cons #t #t)))
(test-equal 0 (car '(0 1 2)))
(test-equal 0 (car (list 0 1 2)))
(test-error (car '#()))
(test-error (car (vector)))
(test-error (car '#(0 1 2)))
(test-error (car (vector 0 1 2)))
(test-end "car various type objects")


(test-begin "cdr")
(test-equal '(b c d) (cdr '((a) b c d)))
(test-equal 2 (cdr '(1 . 2)))
(test-error (cdr '()))
(test-end "cdr")

(test-begin "cdr various type objects")
(test-error (cdr #f))
(test-error (cdr #t))
(if (provided? "sigscheme")
    (begin
      (test-error (cdr (eof)))
      (test-error (cdr (undef)))))
(test-error (cdr 0))
(test-error (cdr 1))
(test-error (cdr 3))
(test-error (cdr -1))
(test-error (cdr -3))
(test-error (cdr 'symbol))
(test-error (cdr 'SYMBOL))
(test-error (cdr #\a))
(test-error (cdr #\あ))
(test-error (cdr ""))
(test-error (cdr " "))
(test-error (cdr "a"))
(test-error (cdr "A"))
(test-error (cdr "aBc12!"))
(test-error (cdr "あ"))
(test-error (cdr "あ0イう12!"))
(test-error (cdr +))
(test-error (cdr (lambda () #t)))

;; syntactic keywords should not be appeared as operand
(if sigscheme?
    (begin
      ;; pure syntactic keyword
      (test-error (cdr else))
      ;; expression keyword
      (test-error (cdr do))))

(call-with-current-continuation
 (lambda (k)
   (test-error (cdr k))))
(test-error (cdr (current-output-port)))
(test-equal #t (cdr '(#t . #t)))
(test-equal #t (cdr (cons #t #t)))
(test-equal '(1 2) (cdr '(0 1 2)))
(test-equal '(1 2) (cdr (list 0 1 2)))
(test-error (cdr '#()))
(test-error (cdr (vector)))
(test-error (cdr '#(0 1 2)))
(test-error (cdr (vector 0 1 2)))
(test-end "cdr various type objects")


(test-begin "set-car!")
(define my-set-car!
  (lambda (kons x)
    (set-car! kons x)
    kons))
(test-error (set-car! '() 2))
(test-error (set-car! (list) 2))
(test-equal '(2)       (my-set-car! (list 0) 2))
(test-equal '(2 . 1)   (my-set-car! (cons 0 1) 2))
(test-equal '(2 1)     (my-set-car! (list 0 1) 2))
(test-equal '(2 1 . 2) (my-set-car! (cons 0 '(1 . 2)) 2))
(if (and (provided? "sigscheme")
         (provided? "const-list-literal"))
    (begin
      (test-error (set-car! '(0) 2))
      (test-error (set-car! '(0 . 1) 2))
      (test-error (set-car! '(0 1) 2))
      (test-error (set-car! '(0 1 . 2) 2)))
    (begin
      (test-equal '(2)       (my-set-car! '(0) 2))
      (test-equal '(2 . 1)   (my-set-car! '(0 . 1) 2))
      (test-equal '(2 1)     (my-set-car! '(0 1) 2))
      (test-equal '(2 1 . 2) (my-set-car! '(0 1 . 2) 2))))
(test-end "set-car!")

(test-begin "set-cdr!")
(define my-set-cdr!
  (lambda (kons x)
    (set-cdr! kons x)
    kons))
(test-error (set-cdr! '() 2))
(test-error (set-cdr! (list) 2))
(test-equal '(0 . 2)   (my-set-cdr! (list 0) 2))
(test-equal '(0 . 2)   (my-set-cdr! (cons 0 1) 2))
(test-equal '(0 . 2)   (my-set-cdr! (list 0 1) 2))
(test-equal '(0 . 2)   (my-set-cdr! (cons 0 '(1 . 2)) 2))
(if (and (provided? "sigscheme")
         (provided? "const-list-literal"))
    (begin
      (test-error (set-cdr! '(0) 2))
      (test-error (set-cdr! '(0 . 1) 2))
      (test-error (set-cdr! '(0 1) 2))
      (test-error (set-cdr! '(0 1 . 2) 2)))
    (begin
      (test-equal '(0 . 2) (my-set-cdr! '(0) 2))
      (test-equal '(0 . 2) (my-set-cdr! '(0 . 1) 2))
      (test-equal '(0 . 2) (my-set-cdr! '(0 1) 2))
      (test-equal '(0 . 2) (my-set-cdr! '(0 1 . 2) 2))))


(define tree (cons (cons (cons '(0  . 1)
                               '(2  . 3))
                         (cons '(4  . 5)
                               '(6  . 7)))
                   (cons (cons '(8  . 9)
                               '(10 . 11))
                         (cons '(12 . 13)
                               '(14 . 15)))))
(test-equal "caar" '((0 . 1)   . (2 . 3))   (caar tree))
(test-equal "cadr" '((8 . 9)   . (10 . 11)) (cadr tree))
(test-equal "cdar" '((4 . 5)   . (6 . 7))   (cdar tree))
(test-equal "cddr" '((12 . 13) . (14 . 15)) (cddr tree))
(test-equal "caddr" '(12 . 13) (caddr tree))
(test-equal "cdddr" '(14 . 15) (cdddr tree))
(if (or (not (provided? "sigscheme"))
        (provided? "deep-cadrs"))
    (begin
      (test-equal "caaar" '(0  . 1)  (caaar tree))
      (test-equal "caadr" '(8  . 9)  (caadr tree))
      (test-equal "cadar" '(4  . 5)  (cadar tree))
      (test-equal "cdaar" '(2  . 3)  (cdaar tree))
      (test-equal "cdadr" '(10 . 11) (cdadr tree))
      (test-equal "cddar" '(6  . 7)  (cddar tree))
      (test-equal "caaaar" 0  (caaaar tree))
      (test-equal "caaadr" 8  (caaadr tree))
      (test-equal "caadar" 4  (caadar tree))
      (test-equal "caaddr" 12 (caaddr tree))
      (test-equal "cadaar" 2  (cadaar tree))
      (test-equal "cadadr" 10 (cadadr tree))
      (test-equal "caddar" 6  (caddar tree))
      (test-equal "cadddr" 14 (cadddr tree))
      (test-equal "cdaaar" 1  (cdaaar tree))
      (test-equal "cdaadr" 9  (cdaadr tree))
      (test-equal "cdadar" 5  (cdadar tree))
      (test-equal "cdaddr" 13 (cdaddr tree))
      (test-equal "cddaar" 3  (cddaar tree))
      (test-equal "cddadr" 11 (cddadr tree))
      (test-equal "cdddar" 7  (cdddar tree))
      (test-equal "cddddr" 15 (cddddr tree))))

(test-error "caar empty list" #t (caar '()))
(test-error "cadr empty list" #t (cadr '()))
(test-error "cdar empty list" #t (cdar '()))
(test-error "cddr empty list" #t (cddr '()))
(test-error "caddr empty list" #t (caddr '()))
(test-error "cdddr empty list" #t (cdddr '()))
(if (or (not (provided? "sigscheme"))
        (provided? "deep-cadrs"))
    (begin
      (test-error "caaar empty list" #t (caaar '()))
      (test-error "caadr empty list" #t (caadr '()))
      (test-error "cadar empty list" #t (cadar '()))
      (test-error "cdaar empty list" #t (cdaar '()))
      (test-error "cdadr empty list" #t (cdadr '()))
      (test-error "cddar empty list" #t (cddar '()))
      (test-error "caaaar empty list" #t (caaaar '()))
      (test-error "caaadr empty list" #t (caaadr '()))
      (test-error "caadar empty list" #t (caadar '()))
      (test-error "caaddr empty list" #t (caaddr '()))
      (test-error "cadaar empty list" #t (cadaar '()))
      (test-error "cadadr empty list" #t (cadadr '()))
      (test-error "caddar empty list" #t (caddar '()))
      (test-error "cadddr empty list" #t (cadddr '()))
      (test-error "cdaaar empty list" #t (cdaaar '()))
      (test-error "cdaadr empty list" #t (cdaadr '()))
      (test-error "cdadar empty list" #t (cdadar '()))
      (test-error "cdaddr empty list" #t (cdaddr '()))
      (test-error "cddaar empty list" #t (cddaar '()))
      (test-error "cddadr empty list" #t (cddadr '()))
      (test-error "cdddar empty list" #t (cdddar '()))
      (test-error "cddddr empty list" #t (cddddr '()))))

(test-error "caar insufficient list" #t (caar '(0 . 1)))
(test-error "cadr insufficient list" #t (cadr '(0 . 1)))
(test-error "cdar insufficient list" #t (cdar '(0 . 1)))
(test-error "cddr insufficient list" #t (cddr '(0 . 1)))
(test-error "caddr insufficient list" #t (caddr '(0 . 1)))
(test-error "cdddr insufficient list" #t (cdddr '(0 . 1)))
(if (or (not (provided? "sigscheme"))
        (provided? "deep-cadrs"))
    (begin
      (test-error "caaar insufficient list" #t (caaar '(0 . 1)))
      (test-error "caadr insufficient list" #t (caadr '(0 . 1)))
      (test-error "cadar insufficient list" #t (cadar '(0 . 1)))
      (test-error "cdaar insufficient list" #t (cdaar '(0 . 1)))
      (test-error "cdadr insufficient list" #t (cdadr '(0 . 1)))
      (test-error "cddar insufficient list" #t (cddar '(0 . 1)))
      (test-error "caaaar insufficient list" #t (caaaar '(0 . 1)))
      (test-error "caaadr insufficient list" #t (caaadr '(0 . 1)))
      (test-error "caadar insufficient list" #t (caadar '(0 . 1)))
      (test-error "caaddr insufficient list" #t (caaddr '(0 . 1)))
      (test-error "cadaar insufficient list" #t (cadaar '(0 . 1)))
      (test-error "cadadr insufficient list" #t (cadadr '(0 . 1)))
      (test-error "caddar insufficient list" #t (caddar '(0 . 1)))
      (test-error "cadddr insufficient list" #t (cadddr '(0 . 1)))
      (test-error "cdaaar insufficient list" #t (cdaaar '(0 . 1)))
      (test-error "cdaadr insufficient list" #t (cdaadr '(0 . 1)))
      (test-error "cdadar insufficient list" #t (cdadar '(0 . 1)))
      (test-error "cdaddr insufficient list" #t (cdaddr '(0 . 1)))
      (test-error "cddaar insufficient list" #t (cddaar '(0 . 1)))
      (test-error "cddadr insufficient list" #t (cddadr '(0 . 1)))
      (test-error "cdddar insufficient list" #t (cdddar '(0 . 1)))
      (test-error "cddddr insufficient list" #t (cddddr '(0 . 1)))))

(test-error "caar invalid object" #t (caar #t))
(test-error "cadr invalid object" #t (cadr #t))
(test-error "cdar invalid object" #t (cdar #t))
(test-error "cddr invalid object" #t (cddr #t))
(test-error "caddr invalid object" #t (caddr #t))
(test-error "cdddr invalid object" #t (cdddr #t))
(if (or (not (provided? "sigscheme"))
        (provided? "deep-cadrs"))
    (begin
      (test-error "caaar invalid object" #t (caaar #t))
      (test-error "caadr invalid object" #t (caadr #t))
      (test-error "cadar invalid object" #t (cadar #t))
      (test-error "cdaar invalid object" #t (cdaar #t))
      (test-error "cdadr invalid object" #t (cdadr #t))
      (test-error "cddar invalid object" #t (cddar #t))
      (test-error "caaaar invalid object" #t (caaaar #t))
      (test-error "caaadr invalid object" #t (caaadr #t))
      (test-error "caadar invalid object" #t (caadar #t))
      (test-error "caaddr invalid object" #t (caaddr #t))
      (test-error "cadaar invalid object" #t (cadaar #t))
      (test-error "cadadr invalid object" #t (cadadr #t))
      (test-error "caddar invalid object" #t (caddar #t))
      (test-error "cadddr invalid object" #t (cadddr #t))
      (test-error "cdaaar invalid object" #t (cdaaar #t))
      (test-error "cdaadr invalid object" #t (cdaadr #t))
      (test-error "cdadar invalid object" #t (cdadar #t))
      (test-error "cdaddr invalid object" #t (cdaddr #t))
      (test-error "cddaar invalid object" #t (cddaar #t))
      (test-error "cddadr invalid object" #t (cddadr #t))
      (test-error "cdddar invalid object" #t (cdddar #t))
      (test-error "cddddr invalid object" #t (cddddr #t))))
(test-end "set-cdr!")


(test-end "test-pair")
