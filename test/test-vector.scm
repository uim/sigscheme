#! /usr/bin/env sscm -C UTF-8

;;  Filename : test-vector.scm
;;  About    : unit test for R5RS vector
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

(require-extension (sscm-ext))

(require-extension (unittest))

(if (not (symbol-bound? 'vector?))
    (test-skip "R5RS vectors is not enabled"))

(define tn test-name)

(define vector-mutable?
  (if sigscheme?
      %%vector-mutable?
      (lambda (v) #t)))

(define pair-mutable?
  (if sigscheme?
      %%pair-mutable?
      (lambda (kons) #t)))

;;
;; vector?
;;
(tn "vector?")
(assert-eq? (tn) #f (vector? #f))
(assert-eq? (tn) #f (vector? #t))
(assert-eq? (tn) #f (vector? '()))
(assert-eq? (tn) #f (vector? (eof)))
(assert-eq? (tn) #f (vector? (undef)))
(assert-eq? (tn) #f (vector? 0))
(assert-eq? (tn) #f (vector? 1))
(assert-eq? (tn) #f (vector? 3))
(assert-eq? (tn) #f (vector? -1))
(assert-eq? (tn) #f (vector? -3))
(assert-eq? (tn) #f (vector? 'symbol))
(assert-eq? (tn) #f (vector? 'SYMBOL))
(assert-eq? (tn) #f (vector? #\a))
(assert-eq? (tn) #f (vector? #\あ))
(assert-eq? (tn) #f (vector? ""))
(assert-eq? (tn) #f (vector? " "))
(assert-eq? (tn) #f (vector? "a"))
(assert-eq? (tn) #f (vector? "A"))
(assert-eq? (tn) #f (vector? "aBc12!"))
(assert-eq? (tn) #f (vector? "あ"))
(assert-eq? (tn) #f (vector? "あ0イう12!"))
(assert-eq? (tn) #f (vector? +))
(assert-eq? (tn) #f (vector? (lambda () #t)))

;; syntactic keywords should not be appeared as operand
(if sigscheme?
    (begin
      ;; pure syntactic keyword
      (assert-error (tn) (lambda () (vector? else)))
      ;; expression keyword
      (assert-error (tn) (lambda () (vector? do)))))

(call-with-current-continuation
 (lambda (k)
   (assert-eq? (tn) #f (vector? k))))
(assert-eq? (tn) #f (vector? (current-output-port)))
(assert-eq? (tn) #f (vector? '(#t . #t)))
(assert-eq? (tn) #f (vector? (cons #t #t)))
(assert-eq? (tn) #f (vector? '(0 1 2)))
(assert-eq? (tn) #f (vector? (list 0 1 2)))
(assert-eq? (tn) #t (vector? '#()))
(assert-eq? (tn) #t (vector? (vector)))
(assert-eq? (tn) #t (vector? '#(0 1 2)))
(assert-eq? (tn) #t (vector? (vector 0 1 2)))

;;
;; make-vector
;;
(tn "make-vector invalid forms")
(assert-error  (tn) (lambda ()                       (make-vector #t)))
(assert-error  (tn) (lambda ()                       (make-vector #t #t)))
(assert-error  (tn) (lambda ()                       (make-vector 0 #t #t)))

(tn "make-vector")
(assert-error  (tn) (lambda ()                       (make-vector -1)))
(assert-equal? (tn) '#()                             (make-vector  0))
(assert-equal? (tn) (vector (undef))                 (make-vector  1))
(assert-equal? (tn) (vector (undef) (undef))         (make-vector  2))
(assert-equal? (tn) (vector (undef) (undef) (undef)) (make-vector  3))
(assert-equal? (tn) 0                 (vector-length (make-vector  0)))
(assert-equal? (tn) 1                 (vector-length (make-vector  1)))
(assert-equal? (tn) 2                 (vector-length (make-vector  2)))
(assert-equal? (tn) 3                 (vector-length (make-vector  3)))
(assert-error  (tn) (lambda ()                       (make-vector -1 #t)))
(assert-equal? (tn) '#()                             (make-vector  0  #t))
(assert-equal? (tn) '#(#t)                           (make-vector  1  #t))
(assert-equal? (tn) '#(#t #t)                        (make-vector  2  #t))
(assert-equal? (tn) '#(#t #t #t)                     (make-vector  3  #t))
(assert-equal? (tn) 0                 (vector-length (make-vector  0  #t)))
(assert-equal? (tn) 1                 (vector-length (make-vector  1  #t)))
(assert-equal? (tn) 2                 (vector-length (make-vector  2  #t)))
(assert-equal? (tn) 3                 (vector-length (make-vector  3  #t)))
(assert-equal? (tn) '#(#(a b) #(a b)) (make-vector 2 '#(a b)))

(tn "make-vector filler identity")
(define filler '(a b))
(define v (make-vector 3 filler))
(assert-eq?    (tn) filler (vector-ref v 0))
(assert-eq?    (tn) filler (vector-ref v 1))
(assert-eq?    (tn) filler (vector-ref v 2))

(tn "make-vector mutability")
(if sigscheme?
    (begin
      (assert-true   (tn) (vector-mutable? (make-vector 0)))
      (assert-true   (tn) (vector-mutable? (make-vector 1)))
      (assert-true   (tn) (vector-mutable? (make-vector 2)))
      (assert-true   (tn) (vector-mutable? (make-vector 3)))
      (assert-true   (tn) (vector-mutable? (make-vector 0 #t)))
      (assert-true   (tn) (vector-mutable? (make-vector 1 #t)))
      (assert-true   (tn) (vector-mutable? (make-vector 2 #t)))
      (assert-true   (tn) (vector-mutable? (make-vector 3 #t)))))

;;
;; vector
;;
(tn "vector")
(assert-equal? (tn) '#()              (vector))
(assert-equal? (tn) '#(a)             (vector 'a))
(assert-equal? (tn) '#(a #\b "c" #xd) (vector 'a #\b "c" #xd))
(assert-error  (tn) (lambda ()        (vector 'a #\b "c" #xd . e)))

(tn "vector element identity")
(define elm '(a b))
(define v (vector elm elm elm))
(assert-eq?    (tn) elm (vector-ref v 0))
(assert-eq?    (tn) elm (vector-ref v 1))
(assert-eq?    (tn) elm (vector-ref v 2))

(tn "vector mutability")
(if sigscheme?
    (begin
      (assert-true   (tn) (vector-mutable? (vector)))
      (assert-true   (tn) (vector-mutable? (vector 'a)))
      (assert-true   (tn) (vector-mutable? (vector 'a 'b 'c 'd)))))

;;
;; vector-length
;;
(tn "vector-length invalid forms")
(assert-error  (tn) (lambda () (vector-length #f)))
(assert-error  (tn) (lambda () (vector-length #t)))
(assert-error  (tn) (lambda () (vector-length '(a b))))

(tn "vector-length")
(assert-equal? (tn) 0 (vector-length '#()))
(assert-equal? (tn) 1 (vector-length '#(a)))
(assert-equal? (tn) 2 (vector-length '#(a b)))
(assert-equal? (tn) 3 (vector-length '#(a b c)))
(assert-equal? (tn) 4 (vector-length '#(a b c d)))
(assert-equal? (tn) 0 (vector-length (vector)))
(assert-equal? (tn) 1 (vector-length (vector 'a)))
(assert-equal? (tn) 2 (vector-length (vector 'a 'b)))
(assert-equal? (tn) 3 (vector-length (vector 'a 'b 'c)))
(assert-equal? (tn) 4 (vector-length (vector 'a 'b 'c 'd)))

;;
;; vector-ref
;;
(tn "vector-ref invalid forms")
(assert-error  (tn) (lambda () (vector-ref '(a)  0)))
(assert-error  (tn) (lambda () (vector-ref '#(a) #\0)))

(tn "vector-ref immutable")
(define immv1 '#(e0))
(define immv5 '#(e0 e1 e2 e3 e4))
(if sigscheme?
    (begin
      (assert-true   (tn) (not (vector-mutable? immv1)))
      (assert-true   (tn) (not (vector-mutable? immv5)))))
(assert-error  (tn) (lambda () (vector-ref '#() -1)))
(assert-error  (tn) (lambda () (vector-ref '#()  0)))
(assert-error  (tn) (lambda () (vector-ref '#()  1)))
(assert-error  (tn) (lambda () (vector-ref immv1 -1)))
(assert-equal? (tn) 'e0        (vector-ref immv1  0))
(assert-error  (tn) (lambda () (vector-ref immv1  1)))
(assert-error  (tn) (lambda () (vector-ref immv5 -1)))
(assert-equal? (tn) 'e0        (vector-ref immv5  0))
(assert-equal? (tn) 'e1        (vector-ref immv5  1))
(assert-equal? (tn) 'e2        (vector-ref immv5  2))
(assert-equal? (tn) 'e3        (vector-ref immv5  3))
(assert-equal? (tn) 'e4        (vector-ref immv5  4))
(assert-error  (tn) (lambda () (vector-ref immv5  5)))

(tn "vector-ref mutable")
(define e0 '(0))
(define e1 '(1))
(define e2 '(2))
(define e3 '(3))
(define e4 '(4))
(define mutv1 (vector e0))
(define mutv5 (vector e0 e1 e2 e3 e4))
(if sigscheme?
    (begin
      (assert-true   (tn) (vector-mutable? mutv1))
      (assert-true   (tn) (vector-mutable? mutv5))))
(assert-error  (tn) (lambda () (vector-ref (vector) -1)))
(assert-error  (tn) (lambda () (vector-ref (vector)  0)))
(assert-error  (tn) (lambda () (vector-ref (vector)  1)))
(assert-error  (tn) (lambda () (vector-ref mutv1 -1)))
(assert-eq?    (tn) e0         (vector-ref mutv1  0))
(assert-error  (tn) (lambda () (vector-ref mutv1  1)))
(assert-error  (tn) (lambda () (vector-ref mutv5 -1)))
(assert-eq?    (tn) e0         (vector-ref mutv5  0))
(assert-eq?    (tn) e1         (vector-ref mutv5  1))
(assert-eq?    (tn) e2         (vector-ref mutv5  2))
(assert-eq?    (tn) e3         (vector-ref mutv5  3))
(assert-eq?    (tn) e4         (vector-ref mutv5  4))
(assert-error  (tn) (lambda () (vector-ref mutv5  5)))

;;
;; vector-set!
;;
(tn "vector-set! invalid forms")
(assert-error  (tn) (lambda ()  (vector-set! (list 0)   0   'x)))
(assert-error  (tn) (lambda ()  (vector-set! (vector 0) #\0 'x)))

(tn "vector-set! mutable")
(define e0 '(0))
(define e1 '(1))
(define e2 '(2))
(define e3 '(3))
(define e4 '(4))
(define x  '(#t))

;; The value returned by `vector-set!' is unspecified in R5RS.
(if sigscheme?
    (assert-equal? (tn) (undef) (vector-set! (vector 0 1 2) 0 x)))

(if sigscheme?
    (assert-true   (tn) (let ((v (vector e0)))
                          (vector-set! v 0 x)
                          (vector-mutable? v))))

;; length 0
(assert-error  (tn) (lambda ()  (vector-set! (vector) -1 x)))
(assert-error  (tn) (lambda ()  (vector-set! (vector)  0 x)))
(assert-error  (tn) (lambda ()  (vector-set! (vector)  1 x)))
;; length 1
(assert-error  (tn) (lambda ()  (vector-set! (vector e0) -1 x)))
(assert-eq?    (tn) x           (let ((v (vector e0)))
                                  (vector-set! v 0 x)
                                  (vector-ref  v 0)))
(assert-error  (tn) (lambda ()  (vector-set! (vector e0)  1 x)))
;; length 3
;; index -1
(assert-error  (tn) (lambda ()  (vector-set! (vector e0 e1 e2) -1 x)))
;; index 0
(assert-eq?    (tn) x           (let ((v (vector e0 e1 e2)))
                                  (vector-set! v 0 x)
                                  (vector-ref  v 0)))
(assert-eq?    (tn) e1          (let ((v (vector e0 e1 e2)))
                                  (vector-set! v 0 x)
                                  (vector-ref  v 1)))
(assert-eq?    (tn) e2          (let ((v (vector e0 e1 e2)))
                                  (vector-set! v 0 x)
                                  (vector-ref  v 2)))
;; index 1
(assert-eq?    (tn) e0          (let ((v (vector e0 e1 e2)))
                                  (vector-set! v 1 x)
                                  (vector-ref  v 0)))
(assert-eq?    (tn) x           (let ((v (vector e0 e1 e2)))
                                  (vector-set! v 1 x)
                                  (vector-ref  v 1)))
(assert-eq?    (tn) e2          (let ((v (vector e0 e1 e2)))
                                  (vector-set! v 1 x)
                                  (vector-ref  v 2)))
;; index 2
(assert-eq?    (tn) e0          (let ((v (vector e0 e1 e2)))
                                  (vector-set! v 2 x)
                                  (vector-ref  v 0)))
(assert-eq?    (tn) e1          (let ((v (vector e0 e1 e2)))
                                  (vector-set! v 2 x)
                                  (vector-ref  v 1)))
(assert-eq?    (tn) x           (let ((v (vector e0 e1 e2)))
                                  (vector-set! v 2 x)
                                  (vector-ref  v 2)))
;; index 3
(assert-error  (tn) (lambda ()  (vector-set! (vector e0 e1 e2)  3 x)))

(tn "vector-set! immutable")
(define x  '(#t))
;; length 0
(assert-error  (tn) (lambda ()  (vector-set! '#() -1 x)))
(assert-error  (tn) (lambda ()  (vector-set! '#()  0 x)))
(assert-error  (tn) (lambda ()  (vector-set! '#()  1 x)))
;; length 1
(assert-error  (tn) (lambda ()  (vector-set! '#(0) -1 x)))
(assert-error  (tn) (lambda ()  (vector-set! '#(0)  0 x)))
(assert-error  (tn) (lambda ()  (vector-set! '#(0)  1 x)))
;; length 3
(assert-error  (tn) (lambda ()  (vector-set! '#(0 1 2) -1 x)))
(assert-error  (tn) (lambda ()  (vector-set! '#(0 1 2)  0 x)))
(assert-error  (tn) (lambda ()  (vector-set! '#(0 1 2)  1 x)))
(assert-error  (tn) (lambda ()  (vector-set! '#(0 1 2)  2 x)))
(assert-error  (tn) (lambda ()  (vector-set! '#(0 1 2)  3 x)))

;;
;; vector->list
;;
(tn "vector->list invalid forms")
(assert-error  (tn) (lambda () (vector->list '())))
(assert-error  (tn) (lambda () (vector->list '(0 1 2))))
(assert-error  (tn) (lambda () (vector->list #t)))

(tn "vector->list immutable")
(define e0 '(0))
(define e1 '(1))
(define e2 '(2))
(assert-equal? (tn) '()              (vector->list '#()))
(assert-equal? (tn) '(a)             (vector->list '#(a)))
(assert-equal? (tn) '(a b)           (vector->list '#(a b)))
(assert-equal? (tn) '(a b c)         (vector->list '#(a b c)))

(assert-equal? (tn) 0        (length (vector->list '#())))
(assert-equal? (tn) 1        (length (vector->list '#(a))))
(assert-equal? (tn) 2        (length (vector->list '#(a b))))
(assert-equal? (tn) 3        (length (vector->list '#(a b c))))

(tn "vector->list mutable")
(define e0 '(0))
(define e1 '(1))
(define e2 '(2))
(assert-equal? (tn) '()              (vector->list (vector)))
(assert-equal? (tn) '(a)             (vector->list (vector 'a)))
(assert-equal? (tn) '(a b)           (vector->list (vector 'a 'b)))
(assert-equal? (tn) '(a b c)         (vector->list (vector 'a 'b 'c)))
(assert-eq?    (tn) e0     (list-ref (vector->list (vector e0 e1 e2)) 0))
(assert-eq?    (tn) e1     (list-ref (vector->list (vector e0 e1 e2)) 1))
(assert-eq?    (tn) e2     (list-ref (vector->list (vector e0 e1 e2)) 2))

(assert-equal? (tn) 0        (length (vector->list (vector))))
(assert-equal? (tn) 1        (length (vector->list (vector 'a))))
(assert-equal? (tn) 2        (length (vector->list (vector 'a 'b))))
(assert-equal? (tn) 3        (length (vector->list (vector e0 e1 e2))))

(tn "vector->list mutability")
(if sigscheme?
    (begin
      (assert-true   (tn) (pair-mutable? (vector->list '#(a))))
      (assert-true   (tn) (pair-mutable? (vector->list '#(a b))))
      (assert-true   (tn) (pair-mutable? (vector->list '#(a b c))))

      (assert-true   (tn) (pair-mutable? (vector->list (vector 'a))))
      (assert-true   (tn) (pair-mutable? (vector->list (vector 'a 'b))))
      (assert-true   (tn) (pair-mutable? (vector->list (vector 'a 'b 'c))))))

;;
;; list->vector
;;
(tn "list->vector invalid forms")
(assert-error  (tn) (lambda () (list->vector '#())))
(assert-error  (tn) (lambda () (list->vector '#(0 1 2))))
(assert-error  (tn) (lambda () (list->vector #t)))

(tn "list->vector improper list")
;; circular lists
(define clst1 (list 1))
(set-cdr! clst1 clst1)
(define clst2 (list 1 2))
(set-cdr! (list-tail clst2 1) clst2)
(define clst3 (list 1 2 3))
(set-cdr! (list-tail clst3 2) clst3)
(define clst4 (list 1 2 3 4))
(set-cdr! (list-tail clst4 3) clst4)
(if sigscheme?
    (begin
      (assert-error  (tn) (lambda () (list->vector '(0 1 2 . 3))))
      (assert-error  (tn) (lambda () (list->vector clst1)))
      (assert-error  (tn) (lambda () (list->vector clst2)))
      (assert-error  (tn) (lambda () (list->vector clst3)))
      (assert-error  (tn) (lambda () (list->vector clst4)))))

(tn "list->vector immutable")
(define e0 '(0))
(define e1 '(1))
(define e2 '(2))
(assert-equal? (tn) '#()              (list->vector '()))
(assert-equal? (tn) '#(a)             (list->vector '(a)))
(assert-equal? (tn) '#(a b)           (list->vector '(a b)))
(assert-equal? (tn) '#(a b c)         (list->vector '(a b c)))

(assert-equal? (tn) 0     (vector-length (list->vector '())))
(assert-equal? (tn) 1     (vector-length (list->vector '(a))))
(assert-equal? (tn) 2     (vector-length (list->vector '(a b))))
(assert-equal? (tn) 3     (vector-length (list->vector '(a b c))))

(tn "list->vector mutable")
(define e0 '(0))
(define e1 '(1))
(define e2 '(2))
(assert-equal? (tn) '#(a)             (list->vector (list 'a)))
(assert-equal? (tn) '#(a b)           (list->vector (list 'a 'b)))
(assert-equal? (tn) '#(a b c)         (list->vector (list 'a 'b 'c)))

(assert-equal? (tn) 1     (vector-length (list->vector (list 'a))))
(assert-equal? (tn) 2     (vector-length (list->vector (list 'a 'b))))
(assert-equal? (tn) 3     (vector-length (list->vector (list 'a 'b 'c))))

(tn "list->vector mutability")
(if sigscheme?
    (begin
      (assert-true   (tn) (vector-mutable? (list->vector '())))
      (assert-true   (tn) (vector-mutable? (list->vector '(a))))
      (assert-true   (tn) (vector-mutable? (list->vector '(a b))))
      (assert-true   (tn) (vector-mutable? (list->vector '(a b c))))

      (assert-true   (tn) (vector-mutable? (list->vector (list 'a))))
      (assert-true   (tn) (vector-mutable? (list->vector (list 'a 'b))))
      (assert-true   (tn) (vector-mutable? (list->vector (list 'a 'b 'c))))))

;;
;; vector-fill!
;;
(tn "vector-fill! invalid forms")
(assert-error  (tn) (lambda () (vector-fill! #f     #t)))
(assert-error  (tn) (lambda () (vector-fill! #t     #t)))
(assert-error  (tn) (lambda () (vector-fill! '()    #t)))
(assert-error  (tn) (lambda () (vector-fill! '(a b) #t)))

(tn "vector-fill! mutable")
(define e0 '(0))
(define e1 '(1))
(define e2 '(2))
(define e3 '(3))
(define e4 '(4))
(define x  '(#t))

;; The value returned by `vector-fill!' is unspecified in R5RS.
(if sigscheme?
    (assert-equal? (tn) (undef) (vector-fill! (vector 0 1 2) x)))

;; length 0
(assert-equal? (tn) 0           (let ((v (vector)))
                                  (vector-fill!  v x)
                                  (vector-length v)))
;; length 1
(assert-eq?    (tn) x           (let ((v (vector e0)))
                                  (vector-fill!  v x)
                                  (vector-ref    v 0)))
(assert-equal? (tn) 1           (let ((v (vector e0)))
                                  (vector-fill!  v x)
                                  (vector-length v)))
;; length 2
(assert-eq?    (tn) x           (let ((v (vector e0 e1)))
                                  (vector-fill!  v x)
                                  (vector-ref    v 0)))
(assert-eq?    (tn) x           (let ((v (vector e0 e1)))
                                  (vector-fill!  v x)
                                  (vector-ref    v 1)))
(assert-equal? (tn) 2           (let ((v (vector e0 e1)))
                                  (vector-fill!  v x)
                                  (vector-length v)))
;; length 5
(assert-eq?    (tn) x           (let ((v (vector e0 e1 e2 e3 e4)))
                                  (vector-fill!  v x)
                                  (vector-ref    v 0)))
(assert-eq?    (tn) x           (let ((v (vector e0 e1 e2 e3 e4)))
                                  (vector-fill!  v x)
                                  (vector-ref    v 1)))
(assert-eq?    (tn) x           (let ((v (vector e0 e1 e2 e3 e4)))
                                  (vector-fill!  v x)
                                  (vector-ref    v 2)))
(assert-eq?    (tn) x           (let ((v (vector e0 e1 e2 e3 e4)))
                                  (vector-fill!  v x)
                                  (vector-ref    v 3)))
(assert-eq?    (tn) x           (let ((v (vector e0 e1 e2 e3 e4)))
                                  (vector-fill!  v x)
                                  (vector-ref    v 4)))
(assert-equal? (tn) 5           (let ((v (vector e0 e1 e2 e3 e4)))
                                  (vector-fill!  v x)
                                  (vector-length v)))

(tn "vector-fill! immutable")
(assert-error  (tn) (lambda () (vector-fill! '#()      #t)))
(assert-error  (tn) (lambda () (vector-fill! '#(a)     #t)))
(assert-error  (tn) (lambda () (vector-fill! '#(a b)   #t)))
(assert-error  (tn) (lambda () (vector-fill! '#(a b c) #t)))


(total-report)
