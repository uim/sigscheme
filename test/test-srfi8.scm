;;  Filename : test-srfi8.scm
;;  About    : unit test for SRFI-8
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

(require-extension (srfi 8))

(test-begin "test-srfi8")

(test-begin "receive varlist formals fixed_0")
(test-equal '()        (receive ()      (values)       '()))
(test-error (receive ()      0              '()))
(test-error (receive ()      (values 0)     '()))
(test-error (receive ()      (values 0 1)   '()))
(test-error (receive ()      (values 0 1 2) '()))
(test-end "receive varlist formals fixed_0")

(test-begin "receive varlist formals fixed_1")
(test-error (receive (x)     (values)       (list x)))
(test-equal '(0)       (receive (x)     0              (list x)))
(test-equal '(0)       (receive (x)     (values 0)     (list x)))
(test-error (receive (x)     (values 0 1)   (list x)))
(test-error (receive (x)     (values 0 1 2) (list x)))
(test-end "receive varlist formals fixed_1")

(test-begin "receive varlist formals fixed_2")
(test-error (receive (x y)   (values)       (list x y)))
(test-error (receive (x y)   0              (list x y)))
(test-error (receive (x y)   (values 0)     (list x y)))
(test-equal '(0 1)     (receive (x y)   (values 0 1)   (list x y)))
(test-error (receive (x y)   (values 0 1 2) (list x y)))
(test-end "receive varlist formals fixed_2")

(test-begin "receive varlist formals fixed_3")
(test-error (receive (x y z) (values)       (list x y z)))
(test-error (receive (x y z) 0              (list x y z)))
(test-error (receive (x y z) (values 0)     (list x y z)))
(test-error (receive (x y z) (values 0 1)   (list x y z)))
(test-equal '(0 1 2)   (receive (x y z) (values 0 1 2) (list x y z)))
(test-error (receive (x y z) (values 0 1 2 3) (list x y z)))
(test-end "receive varlist formals fixed_3")

(test-begin "receive symbol formals (variadic_0)")
(test-equal '()        (receive args (values)       args))
(test-equal '(0)       (receive args 0              args))
(test-equal '(0)       (receive args (values 0)     args))
(test-equal '(0 1)     (receive args (values 0 1)   args))
(test-equal '(0 1 2)   (receive args (values 0 1 2) args))
(test-end "receive symbol formals (variadic_0)")

(test-begin "receive dotted formals variadic_1")
(test-error (receive (x . rest) (values)    (list x rest)))
(test-equal '(0 ())    (receive (x . rest) 0           (list x rest)))
(test-equal '(0 ())    (receive (x . rest) (values 0)  (list x rest)))
(test-equal '(0 (1))   (receive (x . rest) (values 0 1) (list x rest)))
(test-equal '(0 (1 2)) (receive (x . rest) (values 0 1 2)
                         (list x rest)))
(test-end "receive dotted formals variadic_1")

(test-begin "receive dotted formals variadic_2")
(test-error (receive (x y . rest) (values)         (list x y rest)))
(test-error (receive (x y . rest) 0                (list x y rest)))
(test-error (receive (x y . rest) (values 0)       (list x y rest)))
(test-equal '(0 1 ())
            (receive (x y . rest) (values 0 1)     (list x y rest)))
(test-equal '(0 1 (2))
            (receive (x y . rest) (values 0 1 2)   (list x y rest)))
(test-equal '(0 1 (2 3))
            (receive (x y . rest) (values 0 1 2 3) (list x y rest)))
(test-end "receive dotted formals variadic_2")

(test-begin "receive env")
(test-equal '(7 -1 3 4 5)
            (let ((x 3)
                  (y 4)
                  (z 5))
              (receive (a b) (values (+ x y) (- x y))
                (list a b x y z))))
(test-equal '(3 4 5)
            (let ((x 3)
                  (y 4)
                  (z 5))
              (receive (x y) (values x y)
                (list x y z))))
(test-equal '(7 -1 5)
            (let ((x 3)
                  (y 4)
                  (z 5))
              (receive (x y) (values (+ x y) (- x y))
                (list x y z))))
(test-end "receive env")

(test-begin "receive sequencial <body> evaluation")
(test-equal '(6 15)
            (receive (x y) (values (+ 2 3) (+ 4 5))
              (set! x (+ x 1))
              (set! y (+ y x))
              (list x y)))
(test-end "receive sequencial <body> evaluation")

(test-begin "receive eval count exactness")
(test-equal '(x y)
            (let ((x 3)
                  (y 4))
              (receive (x y) (values 'x 'y) (list x y))))
(test-equal '(5 9)
            (receive (x y) (values (+ 2 3) (+ 4 5))   (list x y)))
(test-equal '((+ 2 3) (+ 4 5))
            (receive (x y) (values '(+ 2 3) '(+ 4 5)) (list x y)))
(test-end "receive eval count exactness")

(test-begin "receive invalid forms")
;; empty <body>
(test-error (receive (x) (values 0)))
(test-end "receive invalid forms")

(if (and sigscheme?
         (provided? "strict-argcheck"))
    (begin
      (test-begin "receive invalid formals: boolean as an arg")
      (test-error (receive #t #t #t))
      (test-error (receive (#t) #t #t))
      (test-error (receive (x #t) (values #t #t) #t))
      (test-error (receive (#t x) (values #t #t) #t))
      (test-error (receive (x . #t) #t #t))
      (test-error (receive (#t . x) #t #t))
      (test-error (receive (x y #t) (values #t #t #t) #t))
      (test-error (receive (x y . #t) (values #t #t #t) #t))
      (test-error (receive (x #t y) (values #t #t #t) #t))
      (test-error (receive (x #t . y) (values #t #t #t) #t))
      (test-end "receive invalid formals: boolean as an arg")
      (test-begin "receive invalid formals: intger as an arg")
      (test-error (receive 1 #t #t))
      (test-error (receive (1) #t #t))
      (test-error (receive (x 1) (values #t #t) #t))
      (test-error (receive (1 x) (values #t #t) #t))
      (test-error (receive (x . 1) #t #t))
      (test-error (receive (1 . x) #t #t))
      (test-error (receive (x y 1) (values #t #t #t) #t))
      (test-error (receive (x y . 1) (values #t #t #t) #t))
      (test-error (receive (x 1 y) (values #t #t #t) #t))
      (test-error (receive (x 1 . y) (values #t #t #t) #t))
      (test-end "receive invalid formals: intger as an arg")
      (test-begin "receive invalid formals: null as an arg")
      (test-error (receive (()) #t #t))
      (test-error (receive (x ()) (values #t #t) #t))
      (test-error (receive (() x) (values #t #t) #t))
      (test-assert (receive (x . ()) #t x))
      (test-error (receive (() . x) #t #t))
      (test-error (receive (x y ()) (values #t #t #t) #t))
      (test-error (receive (x y . ()) (values #t #t #t) x))
      (test-error (receive (x () y) (values #t #t #t) #t))
      (test-error (receive (x () . y) (values #t #t #t) #t))
      (test-end "receive invalid formals: null as an arg")
      (test-begin "receive invalid formals: pair as an arg")
      (test-error (receive ((a)) #t #t))
      (test-error (receive (x (a)) (values #t #t) #t))
      (test-error (receive ((a) x) (values #t #t) #t))
      (test-error (receive (x . (a)) #t x))
      (test-error (receive ((a) . x) #t #t))
      (test-error (receive (x y (a)) (values #t #t #t) #t))
      (test-assert (lambda () (receive (x y . (a)) (values #t #t #t) x)))
      (test-error (receive (x (a) y) (values #t #t #t) #t))
      (test-error (receive (x (a) . y) (values #t #t #t) #t))
      (test-end "receive invalid formals: pair as an arg")
      (test-begin "receive invalid formals: char as an arg")
      (test-error (receive #\a #t #t))
      (test-error (receive (#\a) #t #t))
      (test-error (receive (x #\a) (values #t #t) #t))
      (test-error (receive (#\a x) (values #t #t) #t))
      (test-error (receive (x . #\a) #t #t))
      (test-error (receive (#\a . x) #t #t))
      (test-error (receive (x y #\a) (values #t #t #t) #t))
      (test-error (receive (x y . #\a) (values #t #t #t) #t))
      (test-error (receive (x #\a y) (values #t #t #t) #t))
      (test-error (receive (x #\a . y) (values #t #t #t) #t))
      (test-end "receive invalid formals: char as an arg")
      (test-begin "receive invalid formals: string as an arg")
      (test-error (receive "a" #t #t))
      (test-error (receive ("a") #t #t))
      (test-error (receive (x "a") (values #t #t) #t))
      (test-error (receive ("a" x) (values #t #t) #t))
      (test-error (receive (x . "a") #t #t))
      (test-error (receive ("a" . x) #t #t))
      (test-error (receive (x y "a") (values #t #t #t) #t))
      (test-error (receive (x y . "a") (values #t #t #t) #t))
      (test-error (receive (x "a" y) (values #t #t #t) #t))
      (test-error (receive (x "a" . y) (values #t #t #t) #t))
      (test-end "receive invalid formals: string as an arg")
      (test-begin "receive invalid formals: vector as an arg")
      (test-error (receive #(a) #t #t))
      (test-error (receive (#(a)) #t #t))
      (test-error (receive (x #(a)) (values #t #t) #t))
      (test-error (receive (#(a) x) (values #t #t) #t))
      (test-error (receive (x . #(a)) #t #t))
      (test-error (receive (#(a) . x) #t #t))
      (test-error (receive (x y #(a)) (values #t #t #t) #t))
      (test-error (receive (x y . #(a)) (values #t #t #t) #t))
      (test-error (receive (x #(a) y) (values #t #t #t) #t))
      (test-error (receive (x #(a) . y) (values #t #t #t) #t))
      (test-end "receive invalid formals: vector as an arg")))

(test-end "test-srfi8")
