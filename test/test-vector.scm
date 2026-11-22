#! /usr/bin/env sscm -C UTF-8

;;  Filename : test-vector.scm
;;  About    : unit test for R5RS vector
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

(require-extension (sscm-ext))

(require-extension (srfi 64))

(if (not (symbol-bound? 'vector?))
    (test-skip-file "R5RS vectors is not enabled"))

(if (not (provided? "r6rs-chars"))
    (test-skip-file "R6RS characters is not enabled"))

(test-begin "test-vector")

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
(test-begin "vector?")
(test-eq #f (vector? #f))
(test-eq #f (vector? #t))
(test-eq #f (vector? '()))
(test-eq #f (vector? (eof)))
(test-eq #f (vector? (undef)))
(test-eq #f (vector? 0))
(test-eq #f (vector? 1))
(test-eq #f (vector? 3))
(test-eq #f (vector? -1))
(test-eq #f (vector? -3))
(test-eq #f (vector? 'symbol))
(test-eq #f (vector? 'SYMBOL))
(test-eq #f (vector? #\a))
(test-eq #f (vector? #\あ))
(test-eq #f (vector? ""))
(test-eq #f (vector? " "))
(test-eq #f (vector? "a"))
(test-eq #f (vector? "A"))
(test-eq #f (vector? "aBc12!"))
(test-eq #f (vector? "あ"))
(test-eq #f (vector? "あ0イう12!"))
(test-eq #f (vector? +))
(test-eq #f (vector? (lambda () #t)))

;; syntactic keywords should not be appeared as operand
(if sigscheme?
    (begin
      ;; pure syntactic keyword
      (test-error (vector? else))
      ;; expression keyword
      (test-error (vector? do))))

(call-with-current-continuation
 (lambda (k)
   (test-eq #f (vector? k))))
(test-eq #f (vector? (current-output-port)))
(test-eq #f (vector? '(#t . #t)))
(test-eq #f (vector? (cons #t #t)))
(test-eq #f (vector? '(0 1 2)))
(test-eq #f (vector? (list 0 1 2)))
(test-eq #t (vector? '#()))
(test-eq #t (vector? (vector)))
(test-eq #t (vector? '#(0 1 2)))
(test-eq #t (vector? (vector 0 1 2)))
(test-end "vector?")

;;
;; make-vector
;;
(test-begin "make-vector invalid forms")
(test-error (make-vector #t))
(test-error (make-vector #t #t))
(test-error (make-vector 0 #t #t))
(test-end "make-vector invalid forms")

(test-begin "make-vector")
(test-error (make-vector -1))
(test-equal '#()                             (make-vector  0))
(test-equal (vector (undef))                 (make-vector  1))
(test-equal (vector (undef) (undef))         (make-vector  2))
(test-equal (vector (undef) (undef) (undef)) (make-vector  3))
(test-equal 0                 (vector-length (make-vector  0)))
(test-equal 1                 (vector-length (make-vector  1)))
(test-equal 2                 (vector-length (make-vector  2)))
(test-equal 3                 (vector-length (make-vector  3)))
(test-error (make-vector -1 #t))
(test-equal '#()                             (make-vector  0  #t))
(test-equal '#(#t)                           (make-vector  1  #t))
(test-equal '#(#t #t)                        (make-vector  2  #t))
(test-equal '#(#t #t #t)                     (make-vector  3  #t))
(test-equal 0                 (vector-length (make-vector  0  #t)))
(test-equal 1                 (vector-length (make-vector  1  #t)))
(test-equal 2                 (vector-length (make-vector  2  #t)))
(test-equal 3                 (vector-length (make-vector  3  #t)))
(test-equal '#(#(a b) #(a b)) (make-vector 2 '#(a b)))
(test-end "make-vector")

(test-begin "make-vector filler identity")
(define filler '(a b))
(define v (make-vector 3 filler))
(test-eq filler (vector-ref v 0))
(test-eq filler (vector-ref v 1))
(test-eq filler (vector-ref v 2))
(test-end "make-vector filler identity")

(test-begin "make-vector mutability")
(if sigscheme?
    (begin
      (test-assert (vector-mutable? (make-vector 0)))
      (test-assert (vector-mutable? (make-vector 1)))
      (test-assert (vector-mutable? (make-vector 2)))
      (test-assert (vector-mutable? (make-vector 3)))
      (test-assert (vector-mutable? (make-vector 0 #t)))
      (test-assert (vector-mutable? (make-vector 1 #t)))
      (test-assert (vector-mutable? (make-vector 2 #t)))
      (test-assert (vector-mutable? (make-vector 3 #t)))))
(test-end "make-vector mutability")

;;
;; vector
;;
(test-begin "vector")
(test-equal '#()              (vector))
(test-equal '#(a)             (vector 'a))
(test-equal '#(a #\b "c" #xd) (vector 'a #\b "c" #xd))
(test-error (vector 'a #\b "c" #xd . e))
(test-end "vector")

(test-begin "vector element identity")
(define elm '(a b))
(define v (vector elm elm elm))
(test-eq elm (vector-ref v 0))
(test-eq elm (vector-ref v 1))
(test-eq elm (vector-ref v 2))
(test-end "vector element identity")

(test-begin "vector mutability")
(if sigscheme?
    (begin
      (test-assert (vector-mutable? (vector)))
      (test-assert (vector-mutable? (vector 'a)))
      (test-assert (vector-mutable? (vector 'a 'b 'c 'd)))))
(test-end "vector mutability")

;;
;; vector-length
;;
(test-begin "vector-length invalid forms")
(test-error (vector-length #f))
(test-error (vector-length #t))
(test-error (vector-length '(a b)))
(test-end "vector-length invalid forms")

(test-begin "vector-length")
(test-equal 0 (vector-length '#()))
(test-equal 1 (vector-length '#(a)))
(test-equal 2 (vector-length '#(a b)))
(test-equal 3 (vector-length '#(a b c)))
(test-equal 4 (vector-length '#(a b c d)))
(test-equal 0 (vector-length (vector)))
(test-equal 1 (vector-length (vector 'a)))
(test-equal 2 (vector-length (vector 'a 'b)))
(test-equal 3 (vector-length (vector 'a 'b 'c)))
(test-equal 4 (vector-length (vector 'a 'b 'c 'd)))
(test-end "vector-length")

;;
;; vector-ref
;;
(test-begin "vector-ref invalid forms")
(test-error (vector-ref '(a)  0))
(test-error (vector-ref '#(a) #\0))
(test-end "vector-ref invalid forms")

(test-begin "vector-ref immutable")
(define immv1 '#(e0))
(define immv5 '#(e0 e1 e2 e3 e4))
(if (and sigscheme?
         (provided? "const-vector-literal"))
    (begin
      (test-assert (not (vector-mutable? immv1)))
      (test-assert (not (vector-mutable? immv5)))))
(test-error (vector-ref '#() -1))
(test-error (vector-ref '#()  0))
(test-error (vector-ref '#()  1))
(test-error (vector-ref immv1 -1))
(test-equal 'e0        (vector-ref immv1  0))
(test-error (vector-ref immv1  1))
(test-error (vector-ref immv5 -1))
(test-equal 'e0        (vector-ref immv5  0))
(test-equal 'e1        (vector-ref immv5  1))
(test-equal 'e2        (vector-ref immv5  2))
(test-equal 'e3        (vector-ref immv5  3))
(test-equal 'e4        (vector-ref immv5  4))
(test-error (vector-ref immv5  5))
(test-end "vector-ref immutable")

(test-begin "vector-ref mutable")
(define e0 '(0))
(define e1 '(1))
(define e2 '(2))
(define e3 '(3))
(define e4 '(4))
(define mutv1 (vector e0))
(define mutv5 (vector e0 e1 e2 e3 e4))
(if sigscheme?
    (begin
      (test-assert (vector-mutable? mutv1))
      (test-assert (vector-mutable? mutv5))))
(test-error (vector-ref (vector) -1))
(test-error (vector-ref (vector)  0))
(test-error (vector-ref (vector)  1))
(test-error (vector-ref mutv1 -1))
(test-eq e0         (vector-ref mutv1  0))
(test-error (vector-ref mutv1  1))
(test-error (vector-ref mutv5 -1))
(test-eq e0         (vector-ref mutv5  0))
(test-eq e1         (vector-ref mutv5  1))
(test-eq e2         (vector-ref mutv5  2))
(test-eq e3         (vector-ref mutv5  3))
(test-eq e4         (vector-ref mutv5  4))
(test-error (vector-ref mutv5  5))
(test-end "vector-ref mutable")

;;
;; vector-set!
;;
(test-begin "vector-set! invalid forms")
(test-error (vector-set! (list 0)   0   'x))
(test-error (vector-set! (vector 0) #\0 'x))
(test-end "vector-set! invalid forms")

(test-begin "vector-set! mutable")
(define e0 '(0))
(define e1 '(1))
(define e2 '(2))
(define e3 '(3))
(define e4 '(4))
(define x  '(#t))

;; The value returned by `vector-set!' is unspecified in R5RS.
(if sigscheme?
    (test-equal (undef) (vector-set! (vector 0 1 2) 0 x)))

(if sigscheme?
    (test-assert (let ((v (vector e0)))
                   (vector-set! v 0 x)
                   (vector-mutable? v))))

;; length 0
(test-error (vector-set! (vector) -1 x))
(test-error (vector-set! (vector)  0 x))
(test-error (vector-set! (vector)  1 x))
;; length 1
(test-error (vector-set! (vector e0) -1 x))
(test-eq x           (let ((v (vector e0)))
                       (vector-set! v 0 x)
                       (vector-ref  v 0)))
(test-error (vector-set! (vector e0)  1 x))
;; length 3
;; index -1
(test-error (vector-set! (vector e0 e1 e2) -1 x))
;; index 0
(test-eq x           (let ((v (vector e0 e1 e2)))
                       (vector-set! v 0 x)
                       (vector-ref  v 0)))
(test-eq e1          (let ((v (vector e0 e1 e2)))
                       (vector-set! v 0 x)
                       (vector-ref  v 1)))
(test-eq e2          (let ((v (vector e0 e1 e2)))
                       (vector-set! v 0 x)
                       (vector-ref  v 2)))
;; index 1
(test-eq e0          (let ((v (vector e0 e1 e2)))
                       (vector-set! v 1 x)
                       (vector-ref  v 0)))
(test-eq x           (let ((v (vector e0 e1 e2)))
                       (vector-set! v 1 x)
                       (vector-ref  v 1)))
(test-eq e2          (let ((v (vector e0 e1 e2)))
                       (vector-set! v 1 x)
                       (vector-ref  v 2)))
;; index 2
(test-eq e0          (let ((v (vector e0 e1 e2)))
                       (vector-set! v 2 x)
                       (vector-ref  v 0)))
(test-eq e1          (let ((v (vector e0 e1 e2)))
                       (vector-set! v 2 x)
                       (vector-ref  v 1)))
(test-eq x           (let ((v (vector e0 e1 e2)))
                       (vector-set! v 2 x)
                       (vector-ref  v 2)))
;; index 3
(test-error (vector-set! (vector e0 e1 e2)  3 x))
(test-end "vector-set! mutable")

(test-begin "vector-set! immutable")
(define x  '(#t))
;; length 0
(test-error (vector-set! '#() -1 x))
(test-error (vector-set! '#()  0 x))
(test-error (vector-set! '#()  1 x))
;; length 1
(test-error (vector-set! '#(0) -1 x))
(test-error (vector-set! '#(0)  1 x))
;; length 3
(test-error (vector-set! '#(0 1 2) -1 x))
(test-error (vector-set! '#(0 1 2)  3 x))
;; A valid index is an error only for a constant vector.
(if (provided? "const-vector-literal")
    (begin
      (test-error (vector-set! '#(0)  0 x))
      (test-error (vector-set! '#(0 1 2)  0 x))
      (test-error (vector-set! '#(0 1 2)  1 x))
      (test-error (vector-set! '#(0 1 2)  2 x))))
(test-end "vector-set! immutable")

;;
;; vector->list
;;
(test-begin "vector->list invalid forms")
(test-error (vector->list '()))
(test-error (vector->list '(0 1 2)))
(test-error (vector->list #t))
(test-end "vector->list invalid forms")

(test-begin "vector->list immutable")
(define e0 '(0))
(define e1 '(1))
(define e2 '(2))
(test-equal '()              (vector->list '#()))
(test-equal '(a)             (vector->list '#(a)))
(test-equal '(a b)           (vector->list '#(a b)))
(test-equal '(a b c)         (vector->list '#(a b c)))

(test-equal 0        (length (vector->list '#())))
(test-equal 1        (length (vector->list '#(a))))
(test-equal 2        (length (vector->list '#(a b))))
(test-equal 3        (length (vector->list '#(a b c))))
(test-end "vector->list immutable")

(test-begin "vector->list mutable")
(define e0 '(0))
(define e1 '(1))
(define e2 '(2))
(test-equal '()              (vector->list (vector)))
(test-equal '(a)             (vector->list (vector 'a)))
(test-equal '(a b)           (vector->list (vector 'a 'b)))
(test-equal '(a b c)         (vector->list (vector 'a 'b 'c)))
(test-eq e0     (list-ref (vector->list (vector e0 e1 e2)) 0))
(test-eq e1     (list-ref (vector->list (vector e0 e1 e2)) 1))
(test-eq e2     (list-ref (vector->list (vector e0 e1 e2)) 2))

(test-equal 0        (length (vector->list (vector))))
(test-equal 1        (length (vector->list (vector 'a))))
(test-equal 2        (length (vector->list (vector 'a 'b))))
(test-equal 3        (length (vector->list (vector e0 e1 e2))))
(test-end "vector->list mutable")

(test-begin "vector->list mutability")
(if sigscheme?
    (begin
      (test-assert (pair-mutable? (vector->list '#(a))))
      (test-assert (pair-mutable? (vector->list '#(a b))))
      (test-assert (pair-mutable? (vector->list '#(a b c))))

      (test-assert (pair-mutable? (vector->list (vector 'a))))
      (test-assert (pair-mutable? (vector->list (vector 'a 'b))))
      (test-assert (pair-mutable? (vector->list (vector 'a 'b 'c))))))
(test-end "vector->list mutability")

;;
;; list->vector
;;
(test-begin "list->vector invalid forms")
(test-error (list->vector '#()))
(test-error (list->vector '#(0 1 2)))
(test-error (list->vector #t))
(test-end "list->vector invalid forms")

(test-begin "list->vector improper list")
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
      (test-error (list->vector '(0 1 2 . 3)))
      (test-error (list->vector clst1))
      (test-error (list->vector clst2))
      (test-error (list->vector clst3))
      (test-error (list->vector clst4))))
(test-end "list->vector improper list")

(test-begin "list->vector immutable")
(define e0 '(0))
(define e1 '(1))
(define e2 '(2))
(test-equal '#()              (list->vector '()))
(test-equal '#(a)             (list->vector '(a)))
(test-equal '#(a b)           (list->vector '(a b)))
(test-equal '#(a b c)         (list->vector '(a b c)))

(test-equal 0     (vector-length (list->vector '())))
(test-equal 1     (vector-length (list->vector '(a))))
(test-equal 2     (vector-length (list->vector '(a b))))
(test-equal 3     (vector-length (list->vector '(a b c))))
(test-end "list->vector immutable")

(test-begin "list->vector mutable")
(define e0 '(0))
(define e1 '(1))
(define e2 '(2))
(test-equal '#(a)             (list->vector (list 'a)))
(test-equal '#(a b)           (list->vector (list 'a 'b)))
(test-equal '#(a b c)         (list->vector (list 'a 'b 'c)))

(test-equal 1     (vector-length (list->vector (list 'a))))
(test-equal 2     (vector-length (list->vector (list 'a 'b))))
(test-equal 3     (vector-length (list->vector (list 'a 'b 'c))))
(test-end "list->vector mutable")

(test-begin "list->vector mutability")
(if sigscheme?
    (begin
      (test-assert (vector-mutable? (list->vector '())))
      (test-assert (vector-mutable? (list->vector '(a))))
      (test-assert (vector-mutable? (list->vector '(a b))))
      (test-assert (vector-mutable? (list->vector '(a b c))))

      (test-assert (vector-mutable? (list->vector (list 'a))))
      (test-assert (vector-mutable? (list->vector (list 'a 'b))))
      (test-assert (vector-mutable? (list->vector (list 'a 'b 'c))))))
(test-end "list->vector mutability")

;;
;; vector-fill!
;;
(test-begin "vector-fill! invalid forms")
(test-error (vector-fill! #f     #t))
(test-error (vector-fill! #t     #t))
(test-error (vector-fill! '()    #t))
(test-error (vector-fill! '(a b) #t))
(test-end "vector-fill! invalid forms")

(test-begin "vector-fill! mutable")
(define e0 '(0))
(define e1 '(1))
(define e2 '(2))
(define e3 '(3))
(define e4 '(4))
(define x  '(#t))

;; The value returned by `vector-fill!' is unspecified in R5RS.
(if sigscheme?
    (test-equal (undef) (vector-fill! (vector 0 1 2) x)))

;; length 0
(test-equal 0           (let ((v (vector)))
                          (vector-fill!  v x)
                          (vector-length v)))
;; length 1
(test-eq x           (let ((v (vector e0)))
                       (vector-fill!  v x)
                       (vector-ref    v 0)))
(test-equal 1           (let ((v (vector e0)))
                          (vector-fill!  v x)
                          (vector-length v)))
;; length 2
(test-eq x           (let ((v (vector e0 e1)))
                       (vector-fill!  v x)
                       (vector-ref    v 0)))
(test-eq x           (let ((v (vector e0 e1)))
                       (vector-fill!  v x)
                       (vector-ref    v 1)))
(test-equal 2           (let ((v (vector e0 e1)))
                          (vector-fill!  v x)
                          (vector-length v)))
;; length 5
(test-eq x           (let ((v (vector e0 e1 e2 e3 e4)))
                       (vector-fill!  v x)
                       (vector-ref    v 0)))
(test-eq x           (let ((v (vector e0 e1 e2 e3 e4)))
                       (vector-fill!  v x)
                       (vector-ref    v 1)))
(test-eq x           (let ((v (vector e0 e1 e2 e3 e4)))
                       (vector-fill!  v x)
                       (vector-ref    v 2)))
(test-eq x           (let ((v (vector e0 e1 e2 e3 e4)))
                       (vector-fill!  v x)
                       (vector-ref    v 3)))
(test-eq x           (let ((v (vector e0 e1 e2 e3 e4)))
                       (vector-fill!  v x)
                       (vector-ref    v 4)))
(test-equal 5           (let ((v (vector e0 e1 e2 e3 e4)))
                          (vector-fill!  v x)
                          (vector-length v)))
(test-end "vector-fill! mutable")

(test-begin "vector-fill! immutable")
(if (provided? "const-vector-literal")
    (begin
      (test-error (vector-fill! '#()      #t))
      (test-error (vector-fill! '#(a)     #t))
      (test-error (vector-fill! '#(a b)   #t))
      (test-error (vector-fill! '#(a b c) #t))))
(test-end "vector-fill! immutable")


(test-end "test-vector")
