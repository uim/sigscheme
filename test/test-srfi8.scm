;;  Filename : test-srfi8.scm
;;  About    : unit test for SRFI-8
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

(require-extension (unittest))

(require-extension (srfi 8))

(if (not (provided? "srfi-8"))
    (test-skip "SRFI-8 is not enabled"))

(define tn test-name)

(tn "receive varlist formals fixed_0")
(assert-equal? (tn) '()        (receive ()      (values)       '()))
(assert-error  (tn) (lambda () (receive ()      0              '())))
(assert-error  (tn) (lambda () (receive ()      (values 0)     '())))
(assert-error  (tn) (lambda () (receive ()      (values 0 1)   '())))
(assert-error  (tn) (lambda () (receive ()      (values 0 1 2) '())))

(tn "receive varlist formals fixed_1")
(assert-error  (tn) (lambda () (receive (x)     (values)       (list x))))
(assert-equal? (tn) '(0)       (receive (x)     0              (list x)))
(assert-equal? (tn) '(0)       (receive (x)     (values 0)     (list x)))
(assert-error  (tn) (lambda () (receive (x)     (values 0 1)   (list x))))
(assert-error  (tn) (lambda () (receive (x)     (values 0 1 2) (list x))))

(tn "receive varlist formals fixed_2")
(assert-error  (tn) (lambda () (receive (x y)   (values)       (list x y))))
(assert-error  (tn) (lambda () (receive (x y)   0              (list x y))))
(assert-error  (tn) (lambda () (receive (x y)   (values 0)     (list x y))))
(assert-equal? (tn) '(0 1)     (receive (x y)   (values 0 1)   (list x y)))
(assert-error  (tn) (lambda () (receive (x y)   (values 0 1 2) (list x y))))

(tn "receive varlist formals fixed_3")
(assert-error  (tn) (lambda () (receive (x y z) (values)       (list x y z))))
(assert-error  (tn) (lambda () (receive (x y z) 0              (list x y z))))
(assert-error  (tn) (lambda () (receive (x y z) (values 0)     (list x y z))))
(assert-error  (tn) (lambda () (receive (x y z) (values 0 1)   (list x y z))))
(assert-equal? (tn) '(0 1 2)   (receive (x y z) (values 0 1 2) (list x y z)))
(assert-error  (tn) (lambda () (receive (x y z) (values 0 1 2 3) (list x y z))))

(tn "receive symbol formals (variadic_0)")
(assert-equal? (tn) '()        (receive args (values)       args))
(assert-equal? (tn) '(0)       (receive args 0              args))
(assert-equal? (tn) '(0)       (receive args (values 0)     args))
(assert-equal? (tn) '(0 1)     (receive args (values 0 1)   args))
(assert-equal? (tn) '(0 1 2)   (receive args (values 0 1 2) args))

(tn "receive dotted formals variadic_1")
(assert-error  (tn) (lambda () (receive (x . rest) (values)    (list x rest))))
(assert-equal? (tn) '(0 ())    (receive (x . rest) 0           (list x rest)))
(assert-equal? (tn) '(0 ())    (receive (x . rest) (values 0)  (list x rest)))
(assert-equal? (tn) '(0 (1))   (receive (x . rest) (values 0 1) (list x rest)))
(assert-equal? (tn) '(0 (1 2)) (receive (x . rest) (values 0 1 2)
                                 (list x rest)))

(tn "receive dotted formals variadic_2")
(assert-error  (tn) (lambda ()
               (receive (x y . rest) (values)         (list x y rest))))
(assert-error  (tn) (lambda ()
               (receive (x y . rest) 0                (list x y rest))))
(assert-error  (tn) (lambda ()
               (receive (x y . rest) (values 0)       (list x y rest))))
(assert-equal? (tn) '(0 1 ())
               (receive (x y . rest) (values 0 1)     (list x y rest)))
(assert-equal? (tn) '(0 1 (2))
               (receive (x y . rest) (values 0 1 2)   (list x y rest)))
(assert-equal? (tn) '(0 1 (2 3))
               (receive (x y . rest) (values 0 1 2 3) (list x y rest)))

(tn "receive env")
(assert-equal? (tn)
               '(7 -1 3 4 5)
               (let ((x 3)
                     (y 4)
                     (z 5))
                 (receive (a b) (values (+ x y) (- x y))
                   (list a b x y z))))
(assert-equal? (tn)
               '(3 4 5)
               (let ((x 3)
                     (y 4)
                     (z 5))
                 (receive (x y) (values x y)
                   (list x y z))))
(assert-equal? (tn)
               '(7 -1 5)
               (let ((x 3)
                     (y 4)
                     (z 5))
                 (receive (x y) (values (+ x y) (- x y))
                   (list x y z))))

(tn "receive sequencial <body> evaluation")
(assert-equal? (tn)
               '(6 15)
               (receive (x y) (values (+ 2 3) (+ 4 5))
                 (set! x (+ x 1))
                 (set! y (+ y x))
                 (list x y)))

(tn "receive eval count exactness")
(assert-equal? (tn)
               '(x y)
               (let ((x 3)
                     (y 4))
                 (receive (x y) (values 'x 'y) (list x y))))
(assert-equal? (tn)
               '(5 9)
               (receive (x y) (values (+ 2 3) (+ 4 5))   (list x y)))
(assert-equal? (tn)
               '((+ 2 3) (+ 4 5))
               (receive (x y) (values '(+ 2 3) '(+ 4 5)) (list x y)))

(tn "receive invalid forms")
;; empty <body>
(assert-error (tn) (lambda () (receive (x) (values 0))))

(if (and sigscheme?
         (provided? "strict-argcheck"))
    (begin
      (tn "receive invalid formals: boolean as an arg")
      (assert-error (tn) (lambda () (receive #t #t #t)))
      (assert-error (tn) (lambda () (receive (#t) #t #t)))
      (assert-error (tn) (lambda () (receive (x #t) (values #t #t) #t)))
      (assert-error (tn) (lambda () (receive (#t x) (values #t #t) #t)))
      (assert-error (tn) (lambda () (receive (x . #t) #t #t)))
      (assert-error (tn) (lambda () (receive (#t . x) #t #t)))
      (assert-error (tn) (lambda () (receive (x y #t) (values #t #t #t) #t)))
      (assert-error (tn) (lambda () (receive (x y . #t) (values #t #t #t) #t)))
      (assert-error (tn) (lambda () (receive (x #t y) (values #t #t #t) #t)))
      (assert-error (tn) (lambda () (receive (x #t . y) (values #t #t #t) #t)))
      (tn "receive invalid formals: intger as an arg")
      (assert-error (tn) (lambda () (receive 1 #t #t)))
      (assert-error (tn) (lambda () (receive (1) #t #t)))
      (assert-error (tn) (lambda () (receive (x 1) (values #t #t) #t)))
      (assert-error (tn) (lambda () (receive (1 x) (values #t #t) #t)))
      (assert-error (tn) (lambda () (receive (x . 1) #t #t)))
      (assert-error (tn) (lambda () (receive (1 . x) #t #t)))
      (assert-error (tn) (lambda () (receive (x y 1) (values #t #t #t) #t)))
      (assert-error (tn) (lambda () (receive (x y . 1) (values #t #t #t) #t)))
      (assert-error (tn) (lambda () (receive (x 1 y) (values #t #t #t) #t)))
      (assert-error (tn) (lambda () (receive (x 1 . y) (values #t #t #t) #t)))
      (tn "receive invalid formals: null as an arg")
      (assert-error (tn) (lambda () (receive (()) #t #t)))
      (assert-error (tn) (lambda () (receive (x ()) (values #t #t) #t)))
      (assert-error (tn) (lambda () (receive (() x) (values #t #t) #t)))
      (assert-true  (tn)            (receive (x . ()) #t x))
      (assert-error (tn) (lambda () (receive (() . x) #t #t)))
      (assert-error (tn) (lambda () (receive (x y ()) (values #t #t #t) #t)))
      (assert-error (tn) (lambda () (receive (x y . ()) (values #t #t #t) x)))
      (assert-error (tn) (lambda () (receive (x () y) (values #t #t #t) #t)))
      (assert-error (tn) (lambda () (receive (x () . y) (values #t #t #t) #t)))
      (tn "receive invalid formals: pair as an arg")
      (assert-error (tn) (lambda () (receive ((a)) #t #t)))
      (assert-error (tn) (lambda () (receive (x (a)) (values #t #t) #t)))
      (assert-error (tn) (lambda () (receive ((a) x) (values #t #t) #t)))
      (assert-error (tn) (lambda () (receive (x . (a)) #t x)))
      (assert-error (tn) (lambda () (receive ((a) . x) #t #t)))
      (assert-error (tn) (lambda () (receive (x y (a)) (values #t #t #t) #t)))
      (assert-true  (tn) (lambda () (receive (x y . (a)) (values #t #t #t) x)))
      (assert-error (tn) (lambda () (receive (x (a) y) (values #t #t #t) #t)))
      (assert-error (tn) (lambda () (receive (x (a) . y) (values #t #t #t) #t)))
      (tn "receive invalid formals: char as an arg")
      (assert-error (tn) (lambda () (receive #\a #t #t)))
      (assert-error (tn) (lambda () (receive (#\a) #t #t)))
      (assert-error (tn) (lambda () (receive (x #\a) (values #t #t) #t)))
      (assert-error (tn) (lambda () (receive (#\a x) (values #t #t) #t)))
      (assert-error (tn) (lambda () (receive (x . #\a) #t #t)))
      (assert-error (tn) (lambda () (receive (#\a . x) #t #t)))
      (assert-error (tn) (lambda () (receive (x y #\a) (values #t #t #t) #t)))
      (assert-error (tn) (lambda () (receive (x y . #\a) (values #t #t #t) #t)))
      (assert-error (tn) (lambda () (receive (x #\a y) (values #t #t #t) #t)))
      (assert-error (tn) (lambda () (receive (x #\a . y) (values #t #t #t) #t)))
      (tn "receive invalid formals: string as an arg")
      (assert-error (tn) (lambda () (receive "a" #t #t)))
      (assert-error (tn) (lambda () (receive ("a") #t #t)))
      (assert-error (tn) (lambda () (receive (x "a") (values #t #t) #t)))
      (assert-error (tn) (lambda () (receive ("a" x) (values #t #t) #t)))
      (assert-error (tn) (lambda () (receive (x . "a") #t #t)))
      (assert-error (tn) (lambda () (receive ("a" . x) #t #t)))
      (assert-error (tn) (lambda () (receive (x y "a") (values #t #t #t) #t)))
      (assert-error (tn) (lambda () (receive (x y . "a") (values #t #t #t) #t)))
      (assert-error (tn) (lambda () (receive (x "a" y) (values #t #t #t) #t)))
      (assert-error (tn) (lambda () (receive (x "a" . y) (values #t #t #t) #t)))
      (tn "receive invalid formals: vector as an arg")
      (assert-error (tn) (lambda () (receive #(a) #t #t)))
      (assert-error (tn) (lambda () (receive (#(a)) #t #t)))
      (assert-error (tn) (lambda () (receive (x #(a)) (values #t #t) #t)))
      (assert-error (tn) (lambda () (receive (#(a) x) (values #t #t) #t)))
      (assert-error (tn) (lambda () (receive (x . #(a)) #t #t)))
      (assert-error (tn) (lambda () (receive (#(a) . x) #t #t)))
      (assert-error (tn) (lambda () (receive (x y #(a)) (values #t #t #t) #t)))
      (assert-error (tn) (lambda () (receive (x y . #(a)) (values #t #t #t) #t)))
      (assert-error (tn) (lambda () (receive (x #(a) y) (values #t #t #t) #t)))
      (assert-error (tn) (lambda () (receive (x #(a) . y) (values #t #t #t) #t)))))

(total-report)
