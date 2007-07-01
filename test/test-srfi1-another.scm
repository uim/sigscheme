#! /usr/bin/env sscm -C UTF-8

;;  Filename : test-srfi1-another.scm
;;  About    : unit test for SRFI-1 (another version)
;;
;;  Copyright (c) 2007 SigScheme Project <uim AT freedesktop.org>
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

(use srfi-1)

(if (not (provided? "srfi-1"))
    (test-skip "SRFI-1 is not enabled"))

(define tn test-name)

;;(define drop list-tail)

;; To prevent being affected from possible bug of the C implementation of
;; list-tail, tests in this file use this R5RS definition of list-tail.
(define my-list-tail
  (lambda (x k)
    (if (zero? k)
        x
        (my-list-tail (cdr x) (- k 1)))))

;; unique objects
(define elm0 (list #t))
(define elm1 (list #t))
(define elm2 (list #t))
(define elm3 (list #t))
(define elm4 (list #t))
(define elm5 (list #t))
(define elm6 (list #t))
(define elm7 (list #t))
(define elm8 (list #t))
(define elm9 (list #t))
;; sublists
(define cdr9 (cons elm9 '()))
(define cdr8 (cons elm8 cdr9))
(define cdr7 (cons elm7 cdr8))
(define cdr6 (cons elm6 cdr7))
(define cdr5 (cons elm5 cdr6))
(define cdr4 (cons elm4 cdr5))
(define cdr3 (cons elm3 cdr4))
(define cdr2 (cons elm2 cdr3))
(define cdr1 (cons elm1 cdr2))
(define cdr0 (cons elm0 cdr1))
(define lst cdr0)
;; circular lists
(define clst1 (list 1))
(set-cdr! clst1 clst1)
(define clst2 (list 1 2))
(set-cdr! (my-list-tail clst2 1) clst2)
(define clst3 (list 1 2 3))
(set-cdr! (my-list-tail clst3 2) clst3)
(define clst4 (list 1 2 3 4))
(set-cdr! (my-list-tail clst4 3) clst4)


;;
;; Constructors
;;

(tn "xcons")
(assert-equal? (tn) (cons elm1 elm0)      (xcons elm0 elm1))
(assert-eq?    (tn) elm1             (car (xcons elm0 elm1)))
(assert-eq?    (tn) elm0             (cdr (xcons elm0 elm1)))

(tn "cons* invalid forms")
(assert-error  (tn) (lambda () (cons*)))
(tn "cons*")
(assert-eq?    (tn) elm0                         (cons* elm0))
(assert-equal? (tn) (cons elm0 elm1)             (cons* elm0 elm1))
(assert-equal? (tn) (cons elm0 (cons elm1 elm2)) (cons* elm0 elm1 elm2))
(assert-equal? (tn) lst                        (cons* elm0 elm1 elm2 cdr3))
(assert-false  (tn) (eq? lst                   (cons* elm0 elm1 elm2 cdr3)))
(assert-false  (tn) (eq? cdr2 (my-list-tail    (cons* elm0 elm1 elm2 cdr3) 2)))
(assert-true   (tn) (eq? cdr3 (my-list-tail    (cons* elm0 elm1 elm2 cdr3) 3)))
(assert-equal? (tn) '(1 2 3 4 5 6)               (cons* 1 2 3 '(4 5 6)))
(tn "cons* SRFI-1 examples")
(assert-equal? (tn) '(1 2 3 . 4) (cons* 1 2 3 4))
(assert-equal? (tn) 1            (cons* 1))

(tn "make-list invalid forms")
(assert-error  (tn) (lambda () (make-list #t)))
(assert-error  (tn) (lambda () (make-list -1)))
(assert-error  (tn) (lambda () (make-list 0 #t #t)))
(tn "make-list")
(define fill (if sigscheme?
                 (undef)
                 (error "filler value of make-list is unknown")))
(assert-equal? (tn) '()                        (make-list 0))
(assert-equal? (tn) (list fill)                (make-list 1))
(assert-equal? (tn) (list fill fill)           (make-list 2))
(assert-equal? (tn) (list fill fill fill)      (make-list 3))
(assert-equal? (tn) (list fill fill fill fill) (make-list 4))
(assert-equal? (tn) '()                        (make-list 0 elm0))
(assert-equal? (tn) (list elm0)                (make-list 1 elm0))
(assert-equal? (tn) (list elm0 elm0)           (make-list 2 elm0))
(assert-equal? (tn) (list elm0 elm0 elm0)      (make-list 3 elm0))
(assert-equal? (tn) (list elm0 elm0 elm0 elm0) (make-list 4 elm0))

(tn "list-tabulate invalid forms")
(assert-error  (tn) (lambda () (list-tabulate 0)))
(assert-error  (tn) (lambda () (list-tabulate 0 number->string #t)))
(assert-error  (tn) (lambda () (list-tabulate 0 #t #t)))
(assert-error  (tn) (lambda () (list-tabulate 1 string->number)))
(tn "list-tabulate")
(assert-equal? (tn) '()                (list-tabulate 0 number->string))
(assert-equal? (tn) '("0")             (list-tabulate 1 number->string))
(assert-equal? (tn) '("0" "1")         (list-tabulate 2 number->string))
(assert-equal? (tn) '("0" "1" "2")     (list-tabulate 3 number->string))
(assert-equal? (tn) '("0" "1" "2" "3") (list-tabulate 4 number->string))
(tn "list-tabulate SRFI-1 examples")
(assert-equal? (tn) '(0 1 2 3) (list-tabulate 4 values))

(tn "list-copy invalid forms")
(assert-error  (tn) (lambda () (list-copy)))
(tn "list-copy")
(assert-equal? (tn) lst (list-copy lst))
(assert-false  (tn) (eq? lst (list-copy lst)))
(assert-false  (tn) (eq? (my-list-tail lst             1)
                         (my-list-tail (list-copy lst) 1)))
(assert-false  (tn) (eq? (my-list-tail lst             2)
                         (my-list-tail (list-copy lst) 2)))
(assert-false  (tn) (eq? (my-list-tail lst             9)
                         (my-list-tail (list-copy lst) 9)))
;; null terminator
(assert-true   (tn) (eq? (my-list-tail lst             10)
                         (my-list-tail (list-copy lst) 10)))

(tn "circular-list invalid forms")
(assert-error  (tn) (lambda () (circular-list)))
(tn "circular-list length 1")
(assert-eq?    (tn) elm0 (car (my-list-tail (circular-list elm0) 0)))
(assert-eq?    (tn) elm0 (car (my-list-tail (circular-list elm0) 1)))
(assert-eq?    (tn) elm0 (car (my-list-tail (circular-list elm0) 2)))
(assert-eq?    (tn) elm0 (car (my-list-tail (circular-list elm0) 3)))
(assert-eq?    (tn) elm0 (car (my-list-tail (circular-list elm0) 4)))
(assert-eq?    (tn) elm0 (car (my-list-tail (circular-list elm0) 5)))
(tn "circular-list length 2")
(assert-eq?    (tn) elm0 (car (my-list-tail (circular-list elm0 elm1) 0)))
(assert-eq?    (tn) elm1 (car (my-list-tail (circular-list elm0 elm1) 1)))
(assert-eq?    (tn) elm0 (car (my-list-tail (circular-list elm0 elm1) 2)))
(assert-eq?    (tn) elm1 (car (my-list-tail (circular-list elm0 elm1) 3)))
(assert-eq?    (tn) elm0 (car (my-list-tail (circular-list elm0 elm1) 4)))
(assert-eq?    (tn) elm1 (car (my-list-tail (circular-list elm0 elm1) 5)))
(tn "circular-list length 3")
(assert-eq?    (tn) elm0 (car (my-list-tail (circular-list elm0 elm1 elm2) 0)))
(assert-eq?    (tn) elm1 (car (my-list-tail (circular-list elm0 elm1 elm2) 1)))
(assert-eq?    (tn) elm2 (car (my-list-tail (circular-list elm0 elm1 elm2) 2)))
(assert-eq?    (tn) elm0 (car (my-list-tail (circular-list elm0 elm1 elm2) 3)))
(assert-eq?    (tn) elm1 (car (my-list-tail (circular-list elm0 elm1 elm2) 4)))
(assert-eq?    (tn) elm2 (car (my-list-tail (circular-list elm0 elm1 elm2) 5)))
(assert-eq?    (tn) elm0 (car (my-list-tail (circular-list elm0 elm1 elm2) 6)))

(tn "iota invalid forms")
(assert-error  (tn) (lambda ()    (iota)))
(assert-error  (tn) (lambda ()    (iota -1)))
(assert-error  (tn) (lambda ()    (iota -1 0 1)))
(assert-error  (tn) (lambda ()    (iota -1 0 1)))
(assert-error  (tn) (lambda ()    (iota 0 0 0 0)))
(assert-error  (tn) (lambda ()    (iota 1 0 0 0)))
(tn "iota count only")
(assert-equal? (tn) '()           (iota 0))
(assert-equal? (tn) '(0)          (iota 1))
(assert-equal? (tn) '(0 1)        (iota 2))
(assert-equal? (tn) '(0 1 2)      (iota 3))
(assert-equal? (tn) '(0 1 2 3)    (iota 4))
(tn "iota count and start")
(assert-equal? (tn) '()           (iota 0 2))
(assert-equal? (tn) '(2)          (iota 1 2))
(assert-equal? (tn) '(2 3)        (iota 2 2))
(assert-equal? (tn) '(2 3 4)      (iota 3 2))
(assert-equal? (tn) '(2 3 4 5)    (iota 4 2))
;; nagative start
(assert-equal? (tn) '()           (iota 0 -2))
(assert-equal? (tn) '(-2)         (iota 1 -2))
(assert-equal? (tn) '(-2 -1)      (iota 2 -2))
(assert-equal? (tn) '(-2 -1 0)    (iota 3 -2))
(assert-equal? (tn) '(-2 -1 0 1)  (iota 4 -2))
(tn "iota count, start and step")
(assert-equal? (tn) '()           (iota 0 2 3))
(assert-equal? (tn) '(2)          (iota 1 2 3))
(assert-equal? (tn) '(2 5)        (iota 2 2 3))
(assert-equal? (tn) '(2 5 8)      (iota 3 2 3))
(assert-equal? (tn) '(2 5 8 11)   (iota 4 2 3))
;; negative step
(assert-equal? (tn) '()           (iota 0 2 -3))
(assert-equal? (tn) '(2)          (iota 1 2 -3))
(assert-equal? (tn) '(2 -1)       (iota 2 2 -3))
(assert-equal? (tn) '(2 -1 -4)    (iota 3 2 -3))
(assert-equal? (tn) '(2 -1 -4 -7) (iota 4 2 -3))
;; zero step
(assert-equal? (tn) '()           (iota 0 2 0))
(assert-equal? (tn) '(2)          (iota 1 2 0))
(assert-equal? (tn) '(2 2)        (iota 2 2 0))
(assert-equal? (tn) '(2 2 2)      (iota 3 2 0))
(assert-equal? (tn) '(2 2 2 2)    (iota 4 2 0))

;;
;; Predicates
;;

;; proper-list?
(tn "proper-list? proper list")
(assert-eq?    (tn) #t (proper-list? '()))
(assert-eq?    (tn) #t (proper-list? '(1)))
(assert-eq?    (tn) #t (proper-list? '(1 2)))
(assert-eq?    (tn) #t (proper-list? '(1 2 3)))
(assert-eq?    (tn) #t (proper-list? '(1 2 3 4)))
(tn "proper-list? dotted list")
(assert-eq?    (tn) #f (proper-list? 1))
(assert-eq?    (tn) #f (proper-list? '(1 . 2)))
(assert-eq?    (tn) #f (proper-list? '(1 2 . 3)))
(assert-eq?    (tn) #f (proper-list? '(1 2 3 . 4)))
(assert-eq?    (tn) #f (proper-list? '(1 2 3 4 . 5)))
(tn "proper-list? circular list")
(assert-eq?    (tn) #f (proper-list? clst1))
(assert-eq?    (tn) #f (proper-list? clst2))
(assert-eq?    (tn) #f (proper-list? clst3))
(assert-eq?    (tn) #f (proper-list? clst4))
(tn "proper-list? all kind of Scheme objects")
(if (and sigscheme?
         (provided? "siod-bugs"))
    (assert-eq? (tn) #t (proper-list? #f))
    (assert-eq? (tn) #f (proper-list? #f)))
(assert-eq? (tn) #f (proper-list? #t))
(assert-eq? (tn) #t (proper-list? '()))
(if sigscheme?
    (begin
      (assert-eq? (tn) #f (proper-list? (eof)))
      (assert-eq? (tn) #f (proper-list? (undef)))))
(assert-eq? (tn) #f (proper-list? 0))
(assert-eq? (tn) #f (proper-list? 1))
(assert-eq? (tn) #f (proper-list? 3))
(assert-eq? (tn) #f (proper-list? -1))
(assert-eq? (tn) #f (proper-list? -3))
(assert-eq? (tn) #f (proper-list? 'symbol))
(assert-eq? (tn) #f (proper-list? 'SYMBOL))
(assert-eq? (tn) #f (proper-list? #\a))
(assert-eq? (tn) #f (proper-list? #\あ))
(assert-eq? (tn) #f (proper-list? ""))
(assert-eq? (tn) #f (proper-list? " "))
(assert-eq? (tn) #f (proper-list? "a"))
(assert-eq? (tn) #f (proper-list? "A"))
(assert-eq? (tn) #f (proper-list? "aBc12!"))
(assert-eq? (tn) #f (proper-list? "あ"))
(assert-eq? (tn) #f (proper-list? "あ0イう12!"))
(assert-eq? (tn) #f (proper-list? +))
(assert-eq? (tn) #f (proper-list? (lambda () #t)))

;; syntactic keywords should not be appeared as operand
(if sigscheme?
    (begin
      ;; pure syntactic keyword
      (assert-error (tn) (lambda () (proper-list? else)))
      ;; expression keyword
      (assert-error (tn) (lambda () (proper-list? do)))))

(call-with-current-continuation
 (lambda (k)
   (assert-eq? (tn) #f (proper-list? k))))
(assert-eq? (tn) #f (proper-list? (current-output-port)))
(assert-eq? (tn) #f (proper-list? '(#t . #t)))
(assert-eq? (tn) #f (proper-list? (cons #t #t)))
(assert-eq? (tn) #t (proper-list? '(0 1 2)))
(assert-eq? (tn) #t (proper-list? (list 0 1 2)))
(assert-eq? (tn) #f (proper-list? '#()))
(assert-eq? (tn) #f (proper-list? (vector)))
(assert-eq? (tn) #f (proper-list? '#(0 1 2)))
(assert-eq? (tn) #f (proper-list? (vector 0 1 2)))

;; circular-list?
(tn "circular-list? proper list")
(assert-eq?    (tn) #f (circular-list? '()))
(assert-eq?    (tn) #f (circular-list? '(1)))
(assert-eq?    (tn) #f (circular-list? '(1 2)))
(assert-eq?    (tn) #f (circular-list? '(1 2 3)))
(assert-eq?    (tn) #f (circular-list? '(1 2 3 4)))
(tn "circular-list? dotted list")
(assert-eq?    (tn) #f (circular-list? 1))
(assert-eq?    (tn) #f (circular-list? '(1 . 2)))
(assert-eq?    (tn) #f (circular-list? '(1 2 . 3)))
(assert-eq?    (tn) #f (circular-list? '(1 2 3 . 4)))
(assert-eq?    (tn) #f (circular-list? '(1 2 3 4 . 5)))
(tn "circular-list? circular list")
(assert-eq?    (tn) #t (circular-list? clst1))
(assert-eq?    (tn) #t (circular-list? clst2))
(assert-eq?    (tn) #t (circular-list? clst3))
(assert-eq?    (tn) #t (circular-list? clst4))
(tn "circular-list? all kind of Scheme objects")
(if (and sigscheme?
         (provided? "siod-bugs"))
    (assert-eq? (tn) #f (circular-list? #f))
    (assert-eq? (tn) #f (circular-list? #f)))
(assert-eq? (tn) #f (circular-list? #t))
(assert-eq? (tn) #f (circular-list? '()))
(if sigscheme?
    (begin
      (assert-eq? (tn) #f (circular-list? (eof)))
      (assert-eq? (tn) #f (circular-list? (undef)))))
(assert-eq? (tn) #f (circular-list? 0))
(assert-eq? (tn) #f (circular-list? 1))
(assert-eq? (tn) #f (circular-list? 3))
(assert-eq? (tn) #f (circular-list? -1))
(assert-eq? (tn) #f (circular-list? -3))
(assert-eq? (tn) #f (circular-list? 'symbol))
(assert-eq? (tn) #f (circular-list? 'SYMBOL))
(assert-eq? (tn) #f (circular-list? #\a))
(assert-eq? (tn) #f (circular-list? #\あ))
(assert-eq? (tn) #f (circular-list? ""))
(assert-eq? (tn) #f (circular-list? " "))
(assert-eq? (tn) #f (circular-list? "a"))
(assert-eq? (tn) #f (circular-list? "A"))
(assert-eq? (tn) #f (circular-list? "aBc12!"))
(assert-eq? (tn) #f (circular-list? "あ"))
(assert-eq? (tn) #f (circular-list? "あ0イう12!"))
(assert-eq? (tn) #f (circular-list? +))
(assert-eq? (tn) #f (circular-list? (lambda () #t)))

;; syntactic keywords should not be appeared as operand
(if sigscheme?
    (begin
      ;; pure syntactic keyword
      (assert-error (tn) (lambda () (circular-list? else)))
      ;; expression keyword
      (assert-error (tn) (lambda () (circular-list? do)))))

(call-with-current-continuation
 (lambda (k)
   (assert-eq? (tn) #f (circular-list? k))))
(assert-eq? (tn) #f (circular-list? (current-output-port)))
(assert-eq? (tn) #f (circular-list? '(#t . #t)))
(assert-eq? (tn) #f (circular-list? (cons #t #t)))
(assert-eq? (tn) #f (circular-list? '(0 1 2)))
(assert-eq? (tn) #f (circular-list? (list 0 1 2)))
(assert-eq? (tn) #f (circular-list? '#()))
(assert-eq? (tn) #f (circular-list? (vector)))
(assert-eq? (tn) #f (circular-list? '#(0 1 2)))
(assert-eq? (tn) #f (circular-list? (vector 0 1 2)))

;; dotted-list?
(tn "dotted-list? proper list")
(assert-eq?    (tn) #f (dotted-list? '()))
(assert-eq?    (tn) #f (dotted-list? '(1)))
(assert-eq?    (tn) #f (dotted-list? '(1 2)))
(assert-eq?    (tn) #f (dotted-list? '(1 2 3)))
(assert-eq?    (tn) #f (dotted-list? '(1 2 3 4)))
(tn "dotted-list? dotted list")
(assert-eq?    (tn) #t (dotted-list? 1))
(assert-eq?    (tn) #t (dotted-list? '(1 . 2)))
(assert-eq?    (tn) #t (dotted-list? '(1 2 . 3)))
(assert-eq?    (tn) #t (dotted-list? '(1 2 3 . 4)))
(assert-eq?    (tn) #t (dotted-list? '(1 2 3 4 . 5)))
(tn "dotted-list? circular list")
(assert-eq?    (tn) #f (dotted-list? clst1))
(assert-eq?    (tn) #f (dotted-list? clst2))
(assert-eq?    (tn) #f (dotted-list? clst3))
(assert-eq?    (tn) #f (dotted-list? clst4))
(tn "dotted-list? all kind of Scheme objects")
(if (and sigscheme?
         (provided? "siod-bugs"))
    (assert-eq? (tn) #f (dotted-list? #f))
    (assert-eq? (tn) #t (dotted-list? #f)))
(assert-eq? (tn) #t (dotted-list? #t))
(assert-eq? (tn) #f (dotted-list? '()))
(if sigscheme?
    (begin
      (assert-eq? (tn) #t (dotted-list? (eof)))
      (assert-eq? (tn) #t (dotted-list? (undef)))))
(assert-eq? (tn) #t (dotted-list? 0))
(assert-eq? (tn) #t (dotted-list? 1))
(assert-eq? (tn) #t (dotted-list? 3))
(assert-eq? (tn) #t (dotted-list? -1))
(assert-eq? (tn) #t (dotted-list? -3))
(assert-eq? (tn) #t (dotted-list? 'symbol))
(assert-eq? (tn) #t (dotted-list? 'SYMBOL))
(assert-eq? (tn) #t (dotted-list? #\a))
(assert-eq? (tn) #t (dotted-list? #\あ))
(assert-eq? (tn) #t (dotted-list? ""))
(assert-eq? (tn) #t (dotted-list? " "))
(assert-eq? (tn) #t (dotted-list? "a"))
(assert-eq? (tn) #t (dotted-list? "A"))
(assert-eq? (tn) #t (dotted-list? "aBc12!"))
(assert-eq? (tn) #t (dotted-list? "あ"))
(assert-eq? (tn) #t (dotted-list? "あ0イう12!"))
(assert-eq? (tn) #t (dotted-list? +))
(assert-eq? (tn) #t (dotted-list? (lambda () #t)))

;; syntactic keywords should not be appeared as operand
(if sigscheme?
    (begin
      ;; pure syntactic keyword
      (assert-error (tn) (lambda () (dotted-list? else)))
      ;; expression keyword
      (assert-error (tn) (lambda () (dotted-list? do)))))

(call-with-current-continuation
 (lambda (k)
   (assert-eq? (tn) #t (dotted-list? k))))
(assert-eq? (tn) #t (dotted-list? (current-output-port)))
(assert-eq? (tn) #t (dotted-list? '(#t . #t)))
(assert-eq? (tn) #t (dotted-list? (cons #t #t)))
(assert-eq? (tn) #f (dotted-list? '(0 1 2)))
(assert-eq? (tn) #f (dotted-list? (list 0 1 2)))
(assert-eq? (tn) #t (dotted-list? '#()))
(assert-eq? (tn) #t (dotted-list? (vector)))
(assert-eq? (tn) #t (dotted-list? '#(0 1 2)))
(assert-eq? (tn) #t (dotted-list? (vector 0 1 2)))

;; null-list?
(tn "null-list? proper list")
(assert-eq?    (tn) #t (null-list? '()))
(assert-eq?    (tn) #f (null-list? '(1)))
(assert-eq?    (tn) #f (null-list? '(1 2)))
(assert-eq?    (tn) #f (null-list? '(1 2 3)))
(assert-eq?    (tn) #f (null-list? '(1 2 3 4)))
;; SRFI-1: List is a proper or circular list. It is an error to pass this
;; procedure a value which is not a proper or circular list.
(tn "null-list? dotted list")
(if sigscheme?
    (begin
      ;; SigScheme (SRFI-1 reference implementation) specific behavior
      (assert-error  (tn) (lambda () (null-list? 1)))
      (assert-eq?    (tn) #f         (null-list? '(1 . 2)))
      (assert-eq?    (tn) #f         (null-list? '(1 2 . 3)))
      (assert-eq?    (tn) #f         (null-list? '(1 2 3 . 4)))
      (assert-eq?    (tn) #f         (null-list? '(1 2 3 4 . 5)))))
(tn "null-list? circular list")
(assert-eq?    (tn) #f (null-list? clst1))
(assert-eq?    (tn) #f (null-list? clst2))
(assert-eq?    (tn) #f (null-list? clst3))
(assert-eq?    (tn) #f (null-list? clst4))

;; not-pair?
(tn "not-pair? proper list")
(assert-eq?    (tn) #t (not-pair? '()))
(assert-eq?    (tn) #f (not-pair? '(1)))
(assert-eq?    (tn) #f (not-pair? '(1 2)))
(assert-eq?    (tn) #f (not-pair? '(1 2 3)))
(assert-eq?    (tn) #f (not-pair? '(1 2 3 4)))
(tn "not-pair? dotted list")
(assert-eq?    (tn) #t (not-pair? 1))
(assert-eq?    (tn) #f (not-pair? '(1 . 2)))
(assert-eq?    (tn) #f (not-pair? '(1 2 . 3)))
(assert-eq?    (tn) #f (not-pair? '(1 2 3 . 4)))
(assert-eq?    (tn) #f (not-pair? '(1 2 3 4 . 5)))
(tn "not-pair? circular list")
(assert-eq?    (tn) #f (not-pair? clst1))
(assert-eq?    (tn) #f (not-pair? clst2))
(assert-eq?    (tn) #f (not-pair? clst3))
(assert-eq?    (tn) #f (not-pair? clst4))
(tn "not-pair? all kind of Scheme objects")
(assert-eq? (tn) #t (not-pair? #f))
(assert-eq? (tn) #t (not-pair? #t))
(assert-eq? (tn) #t (not-pair? '()))
(if sigscheme?
    (begin
      (assert-eq? (tn) #t (not-pair? (eof)))
      (assert-eq? (tn) #t (not-pair? (undef)))))
(assert-eq? (tn) #t (not-pair? 0))
(assert-eq? (tn) #t (not-pair? 1))
(assert-eq? (tn) #t (not-pair? 3))
(assert-eq? (tn) #t (not-pair? -1))
(assert-eq? (tn) #t (not-pair? -3))
(assert-eq? (tn) #t (not-pair? 'symbol))
(assert-eq? (tn) #t (not-pair? 'SYMBOL))
(assert-eq? (tn) #t (not-pair? #\a))
(assert-eq? (tn) #t (not-pair? #\あ))
(assert-eq? (tn) #t (not-pair? ""))
(assert-eq? (tn) #t (not-pair? " "))
(assert-eq? (tn) #t (not-pair? "a"))
(assert-eq? (tn) #t (not-pair? "A"))
(assert-eq? (tn) #t (not-pair? "aBc12!"))
(assert-eq? (tn) #t (not-pair? "あ"))
(assert-eq? (tn) #t (not-pair? "あ0イう12!"))
(assert-eq? (tn) #t (not-pair? +))
(assert-eq? (tn) #t (not-pair? (lambda () #t)))

;; syntactic keywords should not be appeared as operand
(if sigscheme?
    (begin
      ;; pure syntactic keyword
      (assert-error (tn) (lambda () (not-pair? else)))
      ;; expression keyword
      (assert-error (tn) (lambda () (not-pair? do)))))

(call-with-current-continuation
 (lambda (k)
   (assert-eq? (tn) #t (not-pair? k))))
(assert-eq? (tn) #t (not-pair? (current-output-port)))
(assert-eq? (tn) #f (not-pair? '(#t . #t)))
(assert-eq? (tn) #f (not-pair? (cons #t #t)))
(assert-eq? (tn) #f (not-pair? '(0 1 2)))
(assert-eq? (tn) #f (not-pair? (list 0 1 2)))
(assert-eq? (tn) #t (not-pair? '#()))
(assert-eq? (tn) #t (not-pair? (vector)))
(assert-eq? (tn) #t (not-pair? '#(0 1 2)))
(assert-eq? (tn) #t (not-pair? (vector 0 1 2)))

;; list=
(tn "list= SRFI-1 examples")
(assert-eq? (tn) #t (list= eq?))
(assert-eq? (tn) #t (list= eq? '(a)))
(tn "list= 1 list")
(assert-eq? (tn) #t (list= eq?    '()))
(assert-eq? (tn) #t (list= equal? '()))
(assert-eq? (tn) #t (list= eq?    lst))
(assert-eq? (tn) #t (list= equal? lst))
(assert-eq? (tn) #t (list= eq?    (list elm0)))
(assert-eq? (tn) #t (list= equal? (list elm0)))
(assert-eq? (tn) #t (list= equal? '("a" "b" "c")))
(assert-eq? (tn) #t (list= equal? (list "a" "b" "c")))
(tn "list= 2 lists")
(assert-eq? (tn) #t (list= eq?    '() '()))
(assert-eq? (tn) #t (list= equal? '() '()))
(assert-eq? (tn) #t (list= eq?    lst lst))
(assert-eq? (tn) #t (list= equal? lst lst))
(assert-eq? (tn) #t (list= eq?    (list elm0)           (list elm0)))
(assert-eq? (tn) #t (list= equal? (list elm0)           (list elm0)))
(assert-eq? (tn) #t (list= eq?    (list elm0 elm1)      (list elm0 elm1)))
(assert-eq? (tn) #t (list= equal? (list elm0 elm1)      (list elm0 elm1)))
(assert-eq? (tn) #t (list= eq?    (list elm0 elm1 elm2) (list elm0 elm1 elm2)))
(assert-eq? (tn) #t (list= equal? (list elm0 elm1 elm2) (list elm0 elm1 elm2)))
(assert-eq? (tn) #t (list= equal? '("a" "b" "c")        '("a" "b" "c")))
(assert-eq? (tn) #t (list= equal? (list "a" "b" "c")    (list "a" "b" "c")))
(tn "list= 2 lists unequal length")
(assert-eq? (tn) #f (list= eq?    (list elm0 elm1)      (list elm0 elm1 elm2)))
(assert-eq? (tn) #f (list= equal? (list elm0 elm1)      (list elm0 elm1 elm2)))
(assert-eq? (tn) #f (list= eq?    (list elm0 elm1 elm2) (list elm0 elm1)))
(assert-eq? (tn) #f (list= equal? (list elm0 elm1 elm2) (list elm0 elm1)))
(assert-eq? (tn) #f (list= eq?    '()                   (list elm0 elm1 elm2)))
(assert-eq? (tn) #f (list= equal? '()                   (list elm0 elm1 elm2)))
(assert-eq? (tn) #f (list= eq?    (list elm0 elm1 elm2) '()))
(assert-eq? (tn) #f (list= equal? (list elm0 elm1 elm2) '()))
(tn "list= 3 lists")
(assert-eq? (tn) #t (list= eq?    '() '() '()))
(assert-eq? (tn) #t (list= equal? '() '() '()))
(assert-eq? (tn) #t (list= eq?    lst lst lst))
(assert-eq? (tn) #t (list= equal? lst lst lst))
(assert-eq? (tn) #t (list= eq?    (list elm0) (list elm0) (list elm0)))
(assert-eq? (tn) #t (list= equal? (list elm0) (list elm0) (list elm0)))
(assert-eq? (tn) #t (list= eq?    (list elm0 elm1) (list elm0 elm1)
                                  (list elm0 elm1)))
(assert-eq? (tn) #t (list= equal? (list elm0 elm1) (list elm0 elm1)
                                  (list elm0 elm1)))
(assert-eq? (tn) #t (list= eq?    (list elm0 elm1 elm2) (list elm0 elm1 elm2)
                                  (list elm0 elm1 elm2)))
(assert-eq? (tn) #t (list= equal? (list elm0 elm1 elm2) (list elm0 elm1 elm2)
                                  (list elm0 elm1 elm2)))
(assert-eq? (tn) #t (list= equal? '("a" "b" "c") '("a" "b" "c")
                                  '("a" "b" "c")))
;; This test is failed on the original srfi-1-reference.scm
(assert-eq? (tn) #t (list= equal? (list "a" "b" "c") (list "a" "b" "c")
                                  (list "a" "b" "c")))
(tn "list= 3 lists unequal length")
(assert-eq? (tn) #f (list= eq?    (list elm0 elm1)      (list elm0 elm1 elm2)
                                  (list elm0 elm1 elm2)))
(assert-eq? (tn) #f (list= equal? (list elm0 elm1)      (list elm0 elm1 elm2)
                                  (list elm0 elm1 elm2)))
(assert-eq? (tn) #f (list= eq?    (list elm0 elm1 elm2) (list elm0 elm1)
                                  (list elm0 elm1 elm2)))
(assert-eq? (tn) #f (list= equal? (list elm0 elm1 elm2) (list elm0 elm1)
                                  (list elm0 elm1 elm2)))
(assert-eq? (tn) #f (list= eq?    (list elm0 elm1 elm2) (list elm0 elm1 elm2)
                                  (list elm0 elm1)))
(assert-eq? (tn) #f (list= equal? (list elm0 elm1 elm2) (list elm0 elm1 elm2)
                                  (list elm0 elm1)))
(assert-eq? (tn) #f (list= eq?    '()                   (list elm0 elm1 elm2)
                                  (list elm0 elm1 elm2)))
(assert-eq? (tn) #f (list= equal? '()                   (list elm0 elm1 elm2)
                                  (list elm0 elm1 elm2)))
(assert-eq? (tn) #f (list= eq?    (list elm0 elm1 elm2) '()             
                                  (list elm0 elm1 elm2)))
(assert-eq? (tn) #f (list= equal? (list elm0 elm1 elm2) '()             
                                  (list elm0 elm1 elm2)))
(assert-eq? (tn) #f (list= eq?    (list elm0 elm1 elm2) (list elm0 elm1 elm2)
                                  '()))
(assert-eq? (tn) #f (list= equal? (list elm0 elm1 elm2) (list elm0 elm1 elm2)
                                  '()))
(tn "list= 4 lists")
(assert-eq? (tn) #t (list= eq?    '() '() '() '()))
(assert-eq? (tn) #t (list= equal? '() '() '() '()))
(assert-eq? (tn) #t (list= eq?    lst lst lst lst))
(assert-eq? (tn) #t (list= equal? lst lst lst lst))
(assert-eq? (tn) #t (list= eq?    (list elm0) (list elm0)
                                  (list elm0) (list elm0)))
(assert-eq? (tn) #t (list= equal? (list elm0) (list elm0)
                                  (list elm0) (list elm0)))
(assert-eq? (tn) #t (list= eq?    (list elm0 elm1) (list elm0 elm1)
                                  (list elm0 elm1) (list elm0 elm1)))
(assert-eq? (tn) #t (list= equal? (list elm0 elm1) (list elm0 elm1)
                                  (list elm0 elm1) (list elm0 elm1)))
(assert-eq? (tn) #t (list= eq?    (list elm0 elm1 elm2) (list elm0 elm1 elm2)
                                  (list elm0 elm1 elm2) (list elm0 elm1 elm2)))
(assert-eq? (tn) #t (list= equal? (list elm0 elm1 elm2) (list elm0 elm1 elm2)
                                  (list elm0 elm1 elm2) (list elm0 elm1 elm2)))
(assert-eq? (tn) #t (list= equal? '("a" "b" "c") '("a" "b" "c")
                                  '("a" "b" "c") '("a" "b" "c")))
;; This test is failed on the original srfi-1-reference.scm
(assert-eq? (tn) #t (list= equal? (list "a" "b" "c") (list "a" "b" "c")
                                  (list "a" "b" "c") (list "a" "b" "c")))
(tn "list= 4 lists unequal length")
(assert-eq? (tn) #f (list= eq?    (list elm0 elm1)      (list elm0 elm1 elm2)
                                  (list elm0 elm1 elm2) (list elm0 elm1 elm2)))
(assert-eq? (tn) #f (list= equal? (list elm0 elm1)      (list elm0 elm1 elm2)
                                  (list elm0 elm1 elm2) (list elm0 elm1 elm2)))
(assert-eq? (tn) #f (list= eq?    (list elm0 elm1 elm2) (list elm0 elm1)
                                  (list elm0 elm1 elm2) (list elm0 elm1 elm2)))
(assert-eq? (tn) #f (list= equal? (list elm0 elm1 elm2) (list elm0 elm1)
                                  (list elm0 elm1 elm2) (list elm0 elm1 elm2)))
(assert-eq? (tn) #f (list= eq?    (list elm0 elm1 elm2) (list elm0 elm1 elm2)
                                  (list elm0 elm1)      (list elm0 elm1 elm2)))
(assert-eq? (tn) #f (list= equal? (list elm0 elm1 elm2) (list elm0 elm1 elm2)
                                  (list elm0 elm1)      (list elm0 elm1 elm2)))
(assert-eq? (tn) #f (list= eq?    '()                   (list elm0 elm1 elm2)
                                  (list elm0 elm1 elm2) (list elm0 elm1 elm2)))
(assert-eq? (tn) #f (list= equal? '()                   (list elm0 elm1 elm2)
                                  (list elm0 elm1 elm2) (list elm0 elm1 elm2)))
(assert-eq? (tn) #f (list= eq?    (list elm0 elm1 elm2) '()             
                                  (list elm0 elm1 elm2) (list elm0 elm1 elm2)))
(assert-eq? (tn) #f (list= equal? (list elm0 elm1 elm2) '()             
                                  (list elm0 elm1 elm2) (list elm0 elm1 elm2)))
(assert-eq? (tn) #f (list= eq?    (list elm0 elm1 elm2) (list elm0 elm1 elm2)
                                  '()                   (list elm0 elm1 elm2)))
(assert-eq? (tn) #f (list= equal? (list elm0 elm1 elm2) (list elm0 elm1 elm2)
                                  '()                   (list elm0 elm1 elm2)))
(assert-eq? (tn) #f (list= eq?    (list elm0 elm1 elm2) (list elm0 elm1 elm2)
                                  (list elm0 elm1 elm2) '()))
(assert-eq? (tn) #f (list= equal? (list elm0 elm1 elm2) (list elm0 elm1 elm2)
                                  (list elm0 elm1 elm2) '()))


;;
;; Selectors
;;

(tn "first")
(assert-eq? (tn) elm0 (first   lst))
(tn "second")
(assert-eq? (tn) elm1 (second  lst))
(tn "third")
(assert-eq? (tn) elm2 (third   lst))
(tn "fourth")
(assert-eq? (tn) elm3 (fourth  lst))
(tn "fifth")
(assert-eq? (tn) elm4 (fifth   lst))
(tn "sixth")
(assert-eq? (tn) elm5 (sixth   lst))
(tn "seventh")
(assert-eq? (tn) elm6 (seventh lst))
(tn "eighth")
(assert-eq? (tn) elm7 (eighth  lst))
(tn "ninth")
(assert-eq? (tn) elm8 (ninth   lst))
(tn "tenth")
(assert-eq? (tn) elm9 (tenth   lst))

(tn "car+cdr")
(assert-true (tn) (call-with-values
                      (lambda () (car+cdr (cons elm0 elm1)))
                    (lambda (kar kdr)
                      (and (eq? kar elm0)
                           (eq? kdr elm1)))))

;; take
(tn "take")
;; SRFI-1: If the argument is a list of non-zero length, take is guaranteed to
;; return a freshly-allocated list, even in the case where the entire list is
;; taken, e.g. (take lis (length lis)).
(assert-false  (tn) (eq?    lst (take lst (length lst))))
(assert-true   (tn) (equal? lst (take lst (length lst))))

;; drop
;;
;; SRFI-1: drop returns all but the first i elements of list x.
;; x may be any value -- a proper, circular, or dotted list.
(tn "drop proper list invalid forms")
(assert-error  (tn) (lambda () (drop '()        -1)))
(assert-error  (tn) (lambda () (drop '(1 2)     -1)))
(tn "drop proper list index 0")
(assert-equal? (tn) '()        (drop '()        0))
(assert-equal? (tn) '(1)       (drop '(1)       0))
(assert-equal? (tn) '(1 2)     (drop '(1 2)     0))
(assert-equal? (tn) '(1 2 3)   (drop '(1 2 3)   0))
(assert-equal? (tn) '(1 2 3 4) (drop '(1 2 3 4) 0))
(assert-eq?    (tn) cdr0       (drop lst        0))
(assert-eq?    (tn) cdr9       (drop cdr9       0))
(tn "drop proper list index 1")
(assert-error  (tn) (lambda () (drop '()        1)))
(assert-equal? (tn) '()        (drop '(1)       1))
(assert-equal? (tn) '(2)       (drop '(1 2)     1))
(assert-equal? (tn) '(2 3)     (drop '(1 2 3)   1))
(assert-equal? (tn) '(2 3 4)   (drop '(1 2 3 4) 1))
(assert-eq?    (tn) cdr1       (drop lst        1))
(assert-eq?    (tn) cdr9       (drop cdr8       1))
(assert-eq?    (tn) '()        (drop cdr9       1))
(tn "drop proper list index 2")
(assert-error  (tn) (lambda () (drop '()        2)))
(assert-error  (tn) (lambda () (drop '(1)       2)))
(assert-equal? (tn) '()        (drop '(1 2)     2))
(assert-equal? (tn) '(3)       (drop '(1 2 3)   2))
(assert-equal? (tn) '(3 4)     (drop '(1 2 3 4) 2))
(assert-eq?    (tn) cdr2       (drop lst        2))
(assert-eq?    (tn) cdr9       (drop cdr7       2))
(assert-eq?    (tn) '()        (drop cdr8       2))
(assert-error  (tn) (lambda () (drop cdr9       2)))
(tn "drop proper list index 3")
(assert-error  (tn) (lambda () (drop '()        3)))
(assert-error  (tn) (lambda () (drop '(1)       3)))
(assert-error  (tn) (lambda () (drop '(1 2)     3)))
(assert-equal? (tn) '()        (drop '(1 2 3)   3))
(assert-equal? (tn) '(4)       (drop '(1 2 3 4) 3))
(assert-eq?    (tn) cdr3       (drop lst        3))
(assert-eq?    (tn) cdr9       (drop cdr6       3))
(assert-eq?    (tn) '()        (drop cdr7       3))
(assert-error  (tn) (lambda () (drop cdr8       3)))
(assert-error  (tn) (lambda () (drop cdr9       3)))
(tn "drop proper list index 4")
(assert-error  (tn) (lambda () (drop '()        4)))
(assert-error  (tn) (lambda () (drop '(1)       4)))
(assert-error  (tn) (lambda () (drop '(1 2)     4)))
(assert-error  (tn) (lambda () (drop '(1 2 3)   4)))
(assert-equal? (tn) '()        (drop '(1 2 3 4) 4))
(assert-eq?    (tn) cdr4       (drop lst        4))
(assert-eq?    (tn) cdr9       (drop cdr5       4))
(assert-eq?    (tn) '()        (drop cdr6       4))
(assert-error  (tn) (lambda () (drop cdr7       4)))
(assert-error  (tn) (lambda () (drop cdr8       4)))
(assert-error  (tn) (lambda () (drop cdr9       4)))
(tn "drop proper list index 5")
(assert-error  (tn) (lambda () (drop '()        5)))
(assert-error  (tn) (lambda () (drop '(1)       5)))
(assert-error  (tn) (lambda () (drop '(1 2)     5)))
(assert-error  (tn) (lambda () (drop '(1 2 3)   5)))
(assert-error  (tn) (lambda () (drop '(1 2 3 4) 5)))
(assert-eq?    (tn) cdr5       (drop lst        5))
(assert-eq?    (tn) cdr9       (drop cdr4       5))
(assert-eq?    (tn) '()        (drop cdr5       5))
(assert-error  (tn) (lambda () (drop cdr6       5)))
(assert-error  (tn) (lambda () (drop cdr7       5)))
(assert-error  (tn) (lambda () (drop cdr8       5)))
(assert-error  (tn) (lambda () (drop cdr9       5)))
(tn "drop proper list other indices")
(assert-eq?    (tn) cdr6       (drop lst        6))
(assert-eq?    (tn) cdr7       (drop lst        7))
(assert-eq?    (tn) cdr8       (drop lst        8))
(assert-eq?    (tn) cdr9       (drop lst        9))
(assert-eq?    (tn) '()        (drop lst        10))
(assert-error  (tn) (lambda () (drop lst        11)))

(tn "drop dotted list invalid forms")
(assert-error  (tn) (lambda ()     (drop 1              -1)))
(assert-error  (tn) (lambda ()     (drop '(1 . 2)       -1)))
(tn "drop dotted list index 0")
(assert-equal? (tn) 1              (drop 1              0))
(assert-equal? (tn) '(1 . 2)       (drop '(1 . 2)       0))
(assert-equal? (tn) '(1 2 . 3)     (drop '(1 2 . 3)     0))
(assert-equal? (tn) '(1 2 3 . 4)   (drop '(1 2 3 . 4)   0))
(assert-equal? (tn) '(1 2 3 4 . 5) (drop '(1 2 3 4 . 5) 0))
(tn "drop dotted list index 1")
(assert-error  (tn) (lambda ()     (drop 1              1)))
(assert-equal? (tn) 2              (drop '(1 . 2)       1))
(assert-equal? (tn) '(2 . 3)       (drop '(1 2 . 3)     1))
(assert-equal? (tn) '(2 3 . 4)     (drop '(1 2 3 . 4)   1))
(assert-equal? (tn) '(2 3 4 . 5)   (drop '(1 2 3 4 . 5) 1))
(tn "drop dotted list index 2")
(assert-error  (tn) (lambda ()     (drop 1              2)))
(assert-error  (tn) (lambda ()     (drop '(1 . 2)       2)))
(assert-equal? (tn) 3              (drop '(1 2 . 3)     2))
(assert-equal? (tn) '(3 . 4)       (drop '(1 2 3 . 4)   2))
(assert-equal? (tn) '(3 4 . 5)     (drop '(1 2 3 4 . 5) 2))
(tn "drop dotted list index 3")
(assert-error  (tn) (lambda ()     (drop 1              3)))
(assert-error  (tn) (lambda ()     (drop '(1 . 2)       3)))
(assert-error  (tn) (lambda ()     (drop '(1 2 . 3)     3)))
(assert-equal? (tn) 4              (drop '(1 2 3 . 4)   3))
(assert-equal? (tn) '(4 . 5)       (drop '(1 2 3 4 . 5) 3))
(tn "drop dotted list index 4")
(assert-error  (tn) (lambda ()     (drop 1              4)))
(assert-error  (tn) (lambda ()     (drop '(1 . 2)       4)))
(assert-error  (tn) (lambda ()     (drop '(1 2 . 3)     4)))
(assert-error  (tn) (lambda ()     (drop '(1 2 3 . 4)   4)))
(assert-equal? (tn) 5              (drop '(1 2 3 4 . 5) 4))
(tn "drop dotted list index 5")
(assert-error  (tn) (lambda ()     (drop 1              5)))
(assert-error  (tn) (lambda ()     (drop '(1 . 2)       5)))
(assert-error  (tn) (lambda ()     (drop '(1 2 . 3)     5)))
(assert-error  (tn) (lambda ()     (drop '(1 2 3 . 4)   5)))
(assert-error  (tn) (lambda ()     (drop '(1 2 3 4 . 5) 5)))

(tn "drop circular list invalid forms")
;; SigScheme's implementation does not detect negative index on circular list
;; since it is an user error. It goes an infinite loop.
;;(assert-error  (tn) (lambda ()             (drop clst1 -1)))
;;(assert-error  (tn) (lambda ()             (drop clst2 -1)))
(tn "drop circular list index 0")
(assert-eq?    (tn) clst1                  (drop clst1 0))
(assert-eq?    (tn) clst2                  (drop clst2 0))
(assert-eq?    (tn) clst3                  (drop clst3 0))
(assert-eq?    (tn) clst4                  (drop clst4 0))
(tn "drop circular list index 1")
(assert-eq?    (tn) clst1                  (drop clst1 1))
(assert-eq?    (tn) (my-list-tail clst2 1) (drop clst2 1))
(assert-eq?    (tn) (my-list-tail clst3 1) (drop clst3 1))
(assert-eq?    (tn) (my-list-tail clst4 1) (drop clst4 1))
(tn "drop circular list index 2")
(assert-eq?    (tn) clst1                  (drop clst1 2))
(assert-eq?    (tn) clst2                  (drop clst2 2))
(assert-eq?    (tn) (my-list-tail clst3 2) (drop clst3 2))
(assert-eq?    (tn) (my-list-tail clst4 2) (drop clst4 2))
(tn "drop circular list index 3")
(assert-eq?    (tn) clst1                  (drop clst1 3))
(assert-eq?    (tn) (my-list-tail clst2 1) (drop clst2 3))
(assert-eq?    (tn) clst3                  (drop clst3 3))
(assert-eq?    (tn) (my-list-tail clst4 3) (drop clst4 3))
(tn "drop circular list index 4")
(assert-eq?    (tn) clst1                  (drop clst1 4))
(assert-eq?    (tn) clst2                  (drop clst2 4))
(assert-eq?    (tn) (my-list-tail clst3 1) (drop clst3 4))
(assert-eq?    (tn) clst4                  (drop clst4 4))
(tn "drop circular list index 5")
(assert-eq?    (tn) clst1                  (drop clst1 5))
(assert-eq?    (tn) (my-list-tail clst2 1) (drop clst2 5))
(assert-eq?    (tn) (my-list-tail clst3 2) (drop clst3 5))
(assert-eq?    (tn) (my-list-tail clst4 1) (drop clst4 5))
(tn "drop circular list index 6")
(assert-eq?    (tn) clst1                  (drop clst1 6))
(assert-eq?    (tn) clst2                  (drop clst2 6))
(assert-eq?    (tn) clst3                  (drop clst3 6))
(assert-eq?    (tn) (my-list-tail clst4 2) (drop clst4 6))

(tn "drop SRFI-1 examples")
(assert-equal? (tn) '(c d e) (drop '(a b c d e) 2))
(assert-equal? (tn) '(3 . d) (drop '(1 2 3 . d) 2))
(assert-equal? (tn) 'd       (drop '(1 2 3 . d) 3))

;; last
;;
;; SRFI-1: last returns the last element of the non-empty, finite list pair.
(tn "last invalid forms")
(assert-error  (tn) (lambda () (last '())))
(assert-error  (tn) (lambda () (last 1)))
(tn "last")
(assert-eq?    (tn) elm9       (last lst))
(assert-eq?    (tn) elm9       (last cdr7))
(assert-eq?    (tn) elm9       (last cdr8))
(assert-eq?    (tn) elm9       (last cdr9))
(assert-equal? (tn) 1          (last '(1 . 2)))
(assert-equal? (tn) 2          (last '(1 2 . 3)))
(assert-equal? (tn) 3          (last '(1 2 3 . 4)))

;; last-pair
;;
;; SRFI-1: last-pair returns the last pair in the non-empty, finite list pair.
(tn "last-pair invalid forms")
(assert-error  (tn) (lambda () (last-pair '())))
(assert-error  (tn) (lambda () (last-pair 1)))
(tn "last-pair")
(assert-eq?    (tn) cdr9       (last-pair lst))
(assert-eq?    (tn) cdr9       (last-pair cdr7))
(assert-eq?    (tn) cdr9       (last-pair cdr8))
(assert-eq?    (tn) cdr9       (last-pair cdr9))
(assert-equal? (tn) '(1 . 2)   (last-pair '(1 . 2)))
(assert-equal? (tn) '(2 . 3)   (last-pair '(1 2 . 3)))
(assert-equal? (tn) '(3 . 4)   (last-pair '(1 2 3 . 4)))


;;
;; Miscellaneous: length, append, concatenate, reverse, zip & count
;;

;; length+
(tn "length+ proper list")
(assert-equal? (tn) 0 (length+ '()))
(assert-equal? (tn) 1 (length+ '(1)))
(assert-equal? (tn) 2 (length+ '(1 2)))
(assert-equal? (tn) 3 (length+ '(1 2 3)))
(assert-equal? (tn) 4 (length+ '(1 2 3 4)))
(tn "length+ dotted list")
;; Although the behavior on dotted list is not defined in SRFI-1 itself, the
;; reference implementation returns its length. So SigScheme followed it.
(if sigscheme?
    (begin
      (assert-equal? (tn) 0 (length+ 1))
      (assert-equal? (tn) 1 (length+ '(1 . 2)))
      (assert-equal? (tn) 2 (length+ '(1 2 . 3)))
      (assert-equal? (tn) 3 (length+ '(1 2 3 . 4)))
      (assert-equal? (tn) 4 (length+ '(1 2 3 4 . 5)))))
(tn "length+ circular list")
(assert-eq?    (tn) #f (length+ clst1))
(assert-eq?    (tn) #f (length+ clst2))
(assert-eq?    (tn) #f (length+ clst3))
(assert-eq?    (tn) #f (length+ clst4))


;;
;; Fold, unfold & map
;;


;;
;; Filtering & partitioning
;;


;;
;; Searching
;;

;; find-tail
(tn "find-tail invalid forms")
(assert-error  (tn) (lambda ()   (find-tail even? '#(1 2))))
(assert-error  (tn) (lambda ()   (find-tail 1 '(1 2))))
(tn "find-tail proper list")
;; Although the behavior on null list is not explicitly defined in SRFI-1
;; itself, the reference implementation returns #f So SigScheme followed it.
(assert-false  (tn)      (find-tail even?                     '()))
(assert-false  (tn)      (find-tail (lambda (x) #f)           lst))
(assert-eq?    (tn) lst  (find-tail (lambda (x) (eq? x elm0)) lst))
(assert-eq?    (tn) cdr1 (find-tail (lambda (x) (eq? x elm1)) lst))
(assert-eq?    (tn) cdr2 (find-tail (lambda (x) (eq? x elm2)) lst))
(assert-eq?    (tn) cdr8 (find-tail (lambda (x) (eq? x elm8)) lst))
(assert-eq?    (tn) cdr9 (find-tail (lambda (x) (eq? x elm9)) lst))
(tn "find-tail dotted list")
(assert-error  (tn) (lambda ()   (find-tail even? 1)))
;; Although the behavior on dotted list is not defined in SRFI-1 itself, the
;; reference implementation returns the last pair. So SigScheme followed it.
(assert-equal? (tn) '(1 . 2)     (find-tail (lambda (x) (= x 1)) '(1 . 2)))
(assert-equal? (tn) '(2 . 3)     (find-tail (lambda (x) (= x 2)) '(1 2 . 3)))
(assert-equal? (tn) '(3 . 4)     (find-tail (lambda (x) (= x 3)) '(1 2 3 . 4)))
(assert-error  (tn) (lambda ()   (find-tail even? '(1 . 2))))
(assert-equal? (tn) '(2 . 3)     (find-tail even? '(1 2 . 3)))
(assert-equal? (tn) '(2 3 . 4)   (find-tail even? '(1 2 3 . 4)))
(assert-equal? (tn) '(1 . 2)     (find-tail odd?  '(1 . 2)))
(assert-equal? (tn) '(1 2 . 3)   (find-tail odd?  '(1 2 . 3)))
(assert-equal? (tn) '(1 2 3 . 4) (find-tail odd?  '(1 2 3 . 4)))
(tn "find-tail circular list")
;; SRFI-1: In the circular-list case, this procedure "rotates" the list.
(assert-eq?    (tn) clst4 (find-tail (lambda (x) (= x 1)) clst4))
(assert-eq?    (tn) (my-list-tail clst4 1) (find-tail (lambda (x) (= x 2))
                                                      clst4))
(assert-eq?    (tn) (my-list-tail clst4 2) (find-tail (lambda (x) (= x 3))
                                                      clst4))
(assert-eq?    (tn) (my-list-tail clst4 3) (find-tail (lambda (x) (= x 4))
                                                      clst4))
(assert-eq?    (tn)
               clst4
               (let ((cnt 2))
                 (find-tail (lambda (x)
                              (if (= x 1)
                                  (set! cnt (- cnt 1)))
                              (and (zero? cnt)
                                   (= x 1)))
                            clst4)))
(assert-eq?    (tn)
               (my-list-tail clst4 1)
               (let ((cnt 2))
                 (find-tail (lambda (x)
                              (if (= x 1)
                                  (set! cnt (- cnt 1)))
                              (and (zero? cnt)
                                   (= x 2)))
                            clst4)))
(assert-eq?    (tn)
               (my-list-tail clst4 2)
               (let ((cnt 2))
                 (find-tail (lambda (x)
                              (if (= x 1)
                                  (set! cnt (- cnt 1)))
                              (and (zero? cnt)
                                   (= x 3)))
                            clst4)))
(assert-eq?    (tn)
               clst4
               (let ((cnt 3))
                 (find-tail (lambda (x)
                              (if (= x 1)
                                  (set! cnt (- cnt 1)))
                              (and (zero? cnt)
                                   (= x 1)))
                            clst4)))
(assert-eq?    (tn)
               clst4
               (let ((cnt 4))
                 (find-tail (lambda (x)
                              (if (= x 1)
                                  (set! cnt (- cnt 1)))
                              (and (zero? cnt)
                                   (= x 1)))
                            clst4)))


;;
;; Deleting
;;


;;
;; Association lists
;;


;;
;; Set operations on lists
;;


(total-report)
