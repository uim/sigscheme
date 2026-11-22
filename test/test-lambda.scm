;;  Filename : test-lambda.scm
;;  About    : unit test for R5RS lambda
;;
;;  Copyright (C) 2005-2006 YAMAMOTO Kengo <yamaken AT bp.iij4u.or.jp>
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

(test-begin "test-lambda")


(if (and (provided? "sigscheme")
         (provided? "strict-argcheck"))
    (begin
      (test-begin "lambda invalid formals: boolean as an arg")
      (test-error (lambda (#t) #t))
      (test-error (lambda (x #t) #t))
      (test-error (lambda (#t x) #t))
      (test-error (lambda (x . #t) #t))
      (test-error (lambda (#t . x) #t))
      (test-error (lambda (x y #t) #t))
      (test-error (lambda (x y . #t) #t))
      (test-error (lambda (x #t y) #t))
      (test-error (lambda (x #t . y) #t))
      (test-end "lambda invalid formals: boolean as an arg")
      (test-begin "lambda invalid formals: intger as an arg")
      (test-error (lambda (1) #t))
      (test-error (lambda (x 1) #t))
      (test-error (lambda (1 x) #t))
      (test-error (lambda (x . 1) #t))
      (test-error (lambda (1 . x) #t))
      (test-error (lambda (x y 1) #t))
      (test-error (lambda (x y . 1) #t))
      (test-error (lambda (x 1 y) #t))
      (test-error (lambda (x 1 . y) #t))
      (test-end "lambda invalid formals: intger as an arg")
      (test-begin "lambda invalid formals: null as an arg")
      (test-error (lambda (()) #t))
      (test-error (lambda (x ()) #t))
      (test-error (lambda (() x) #t))
      (test-assert (lambda (x . ()) #t))
      (test-error (lambda (() . x) #t))
      (test-error (lambda (x y ()) #t))
      (test-assert (lambda (x y . ()) #t))
      (test-error (lambda (x () y) #t))
      (test-error (lambda (x () . y) #t))
      (test-end "lambda invalid formals: null as an arg")
      (test-begin "lambda invalid formals: pair as an arg")
      (test-error (lambda ((a)) #t))
      (test-error (lambda (x (a)) #t))
      (test-error (lambda ((a) x) #t))
      (test-assert (lambda (x . (a)) #t))
      (test-error (lambda ((a) . x) #t))
      (test-error (lambda (x y (a)) #t))
      (test-assert (lambda (x y . (a)) #t))
      (test-error (lambda (x (a) y) #t))
      (test-error (lambda (x (a) . y) #t))
      (test-end "lambda invalid formals: pair as an arg")
      (test-begin "lambda invalid formals: char as an arg")
      (test-error (lambda (#\a) #t))
      (test-error (lambda (x #\a) #t))
      (test-error (lambda (#\a x) #t))
      (test-error (lambda (x . #\a) #t))
      (test-error (lambda (#\a . x) #t))
      (test-error (lambda (x y #\a) #t))
      (test-error (lambda (x y . #\a) #t))
      (test-error (lambda (x #\a y) #t))
      (test-error (lambda (x #\a . y) #t))
      (test-end "lambda invalid formals: char as an arg")
      (test-begin "lambda invalid formals: string as an arg")
      (test-error (lambda ("a") #t))
      (test-error (lambda (x "a") #t))
      (test-error (lambda ("a" x) #t))
      (test-error (lambda (x . "a") #t))
      (test-error (lambda ("a" . x) #t))
      (test-error (lambda (x y "a") #t))
      (test-error (lambda (x y . "a") #t))
      (test-error (lambda (x "a" y) #t))
      (test-error (lambda (x "a" . y) #t))
      (test-end "lambda invalid formals: string as an arg")
      (test-begin "lambda invalid formals: vector as an arg")
      (test-error (lambda (#(a)) #t))
      (test-error (lambda (x #(a)) #t))
      (test-error (lambda (#(a) x) #t))
      (test-error (lambda (x . #(a)) #t))
      (test-error (lambda (#(a) . x) #t))
      (test-error (lambda (x y #(a)) #t))
      (test-error (lambda (x y . #(a)) #t))
      (test-error (lambda (x #(a) y) #t))
      (test-error (lambda (x #(a) . y) #t))
      (test-end "lambda invalid formals: vector as an arg")))

(test-begin "lambda invalid body")
(test-error (lambda ()))
(test-error (lambda () . 1))
(test-error (lambda (x)))
(test-error (lambda x))
;; An improper body is detected without calling the procedure.
(test-argcheck-error (lambda () 1 . 1))
(test-argcheck-error (lambda () 1 2 . 3))
(test-argcheck-error (lambda (x) 1 . 1))
(test-argcheck-error (lambda x 1 . 1))
(test-end "lambda invalid body")

(test-begin "lambda")
;; empty args
(test-equal 'result
            ((lambda () 'result)))
(test-error ((lambda () 'result) 0))
;; variable args
(test-equal '()
            ((lambda args args)))
(test-equal '(2)
            ((lambda args args) (+ 1 1)))
(test-equal '(2 3)
            ((lambda args args) (+ 1 1) (+ 2 1)))
(test-equal '(2 3 4)
            ((lambda args args) (+ 1 1) (+ 2 1) (+ 3 1)))
;; 1 arg + rest
(test-error ((lambda (var1 . rest)
               (list var1 rest))))
(test-equal '(2 ())
            ((lambda (var1 . rest)
               (list var1 rest))
             (+ 1 1)))
(test-equal '(2 (3))
            ((lambda (var1 . rest)
               (list var1 rest))
             (+ 1 1) (+ 2 1)))
(test-equal '(2 (3 4))
            ((lambda (var1 . rest)
               (list var1 rest))
             (+ 1 1) (+ 2 1) (+ 3 1)))
;; 2 arg + rest
(test-error ((lambda (var1 var2 . rest)
               (list var1 var2 rest))))
(test-error ((lambda (var1 var2 . rest)
               (list var1 var2 rest))
             (+ 1 1)))
(test-equal '(2 3 ())
            ((lambda (var1 var2 . rest)
               (list var1 var2 rest))
             (+ 1 1) (+ 2 1)))
(test-equal '(2 3 (4))
            ((lambda (var1 var2 . rest)
               (list var1 var2 rest))
             (+ 1 1) (+ 2 1) (+ 3 1)))
;; duplicate variable name: SigScheme does not perform the check
;;(test-error ((lambda (var1 var2) 'result) 0 1))
;; masked variable name
(test-equal '(4 5 3)
            ((lambda (var1 var2 var3)
               ((lambda (var1 var2)
                  (list var1 var2 var3))
                4 5))
             1 2 3))
(test-equal '(1 2 3)
            ((lambda (var1 var2 var3)
               ((lambda (var1 var2)
                  'dymmy)
                4 5)
               (list var1 var2 var3))
             1 2 3))
(test-equal '(1 2 9)
            ((lambda (var1 var2 var3)
               ((lambda (var1 var2)
                  (set! var3 (+ var1 var2)))
                4 5)
               (list var1 var2 var3))
             1 2 3))
(test-equal '(1 2 30)
            ((lambda (var1 var2 var3)
               ((lambda (var1 var2)
                  (set! var1 10)
                  (set! var2 20)
                  (set! var3 (+ var1 var2)))
                4 5)
               (list var1 var2 var3))
             1 2 3))
(test-end "lambda")

(test-begin "lambda lexical scope")
(define count-let
  ((lambda (count-let)  ;; intentionally same name
     (lambda ()
       (set! count-let (+ count-let 1))
       count-let))
   0))
(test-assert (procedure? count-let))
(test-equal 1 (count-let))
(test-equal 2 (count-let))
(test-equal 3 (count-let))
(test-end "lambda lexical scope")

(test-begin "let internal definitions lacking sequence part")
;; at least one <expression> is required
(test-error ((lambda ()
              (define var1 1))))
(test-error ((lambda ()
              (define (proc1) 1))))
(test-error ((lambda ()
              (define var1 1)
              (define var2 2))))
(test-error ((lambda ()
              (define (proc1) 1)
              (define (proc2) 2))))
(test-error ((lambda ()
              (define var1 1)
              (define (proc2) 2))))
(test-error ((lambda ()
              (define (proc1) 1)
              (define var2 2))))
(test-error ((lambda ()
              (begin))))
(test-error ((lambda ()
              (begin
                (define var1 1)))))
(test-error ((lambda ()
              (begin
                (define (proc1) 1)))))
(test-error ((lambda ()
              (begin
                (define var1 1)
                (define var2 2)))))
(test-error ((lambda ()
              (begin
                (define (proc1) 1)
                (define (proc2) 2)))))
(test-error ((lambda ()
              (begin
                (define var1 1)
                (define (proc2) 2)))))
(test-error ((lambda ()
              (begin
                (define (proc1) 1)
                (define var2 2)))))
;; appending a non-definition expression into a begin block is invalid
(test-error ((lambda ()
              (begin
                (define var1 1)
                'val))))
(test-error ((lambda ()
              (begin
                (define (proc1) 1)
                'val))))
(test-error ((lambda ()
              (begin
                (define var1 1)
                (define var2 2)
                'val))))
(test-error ((lambda ()
              (begin
                (define (proc1) 1)
                (define (proc2) 2)
                'val))))
(test-error ((lambda ()
              (begin
                (define var1 1)
                (define (proc2) 2)
                'val))))
(test-error ((lambda ()
              (begin
                (define (proc1) 1)
                (define var2 2)
                'val))))
(test-end "let internal definitions lacking sequence part")

(test-begin "let internal definitions cross reference")
(if (not (provided? "internal-definitions"))
    (test-skip-rest))
;; R5RS: 5.2.2 Internal definitions
;; Just as for the equivalent `letrec' expression, it must be possible to
;; evaluate each <expression> of every internal definition in a <body> without
;; assigning or referring to the value of any <variable> being defined.
;; R7RS: Internal definitions are letrec* and refer to the preceding ones.
(if (provided? "r7rs")
    (test-equal 1
                ((lambda ()
                  (define var1 1)
                  (define var2 var1)
                  var2)))
    (test-error ((lambda ()
                  (define var1 1)
                  (define var2 var1)
                  'val))))
(test-error ((lambda ()
              (define var1 var2)
              (define var2 2)
              'val)))
(test-error ((lambda ()
              (define var1 var1)
              'val)))
(test-equal '(0 0 0 0 0)
            ((lambda (var0)
              (define var1 var0)
              (define var2 var0)
              (begin
                (define var3 var0)
                (begin
                  (define var4 var0)))
              (define var5 var0)
              (list var1 var2 var3 var4 var5)) 0))
(test-equal '(#f #f #f #f #f #f)
            ((lambda (var0)
              (define var1 (symbol-bound? 'var1))
              (define var2 (symbol-bound? 'var1))
              (begin
                (define var3 (symbol-bound? 'var1))
                (begin
                  (define var4 (symbol-bound? 'var1))))
              (define var5 (symbol-bound? 'var1))
              (list var0 var1 var2 var3 var4 var5))
             (symbol-bound? 'var1)))
(test-equal '(#f #f #f #f #f #f)
            ((lambda (var0)
              (define var1 (symbol-bound? 'var2))
              (define var2 (symbol-bound? 'var2))
              (begin
                (define var3 (symbol-bound? 'var2))
                (begin
                  (define var4 (symbol-bound? 'var2))))
              (define var5 (symbol-bound? 'var2))
              (list var0 var1 var2 var3 var4 var5))
             (symbol-bound? 'var2)))
(test-equal '(#f #f #f #f #f #f)
            ((lambda (var0)
              (define var1 (symbol-bound? 'var3))
              (define var2 (symbol-bound? 'var3))
              (begin
                (define var3 (symbol-bound? 'var3))
                (begin
                  (define var4 (symbol-bound? 'var3))))
              (define var5 (symbol-bound? 'var3))
              (list var0 var1 var2 var3 var4 var5))
             (symbol-bound? 'var3)))
(test-equal '(#f #f #f #f #f #f)
            ((lambda (var0)
              (define var1 (symbol-bound? 'var4))
              (define var2 (symbol-bound? 'var4))
              (begin
                (define var3 (symbol-bound? 'var4))
                (begin
                  (define var4 (symbol-bound? 'var4))))
              (define var5 (symbol-bound? 'var4))
              (list var0 var1 var2 var3 var4 var5))
             (symbol-bound? 'var4)))
(test-equal '(#f #f #f #f #f #f)
            ((lambda (var0)
              (define var1 (symbol-bound? 'var5))
              (define var2 (symbol-bound? 'var5))
              (begin
                (define var3 (symbol-bound? 'var5))
                (begin
                  (define var4 (symbol-bound? 'var5))))
              (define var5 (symbol-bound? 'var5))
              (list var0 var1 var2 var3 var4 var5))
             (symbol-bound? 'var5)))
;; outer region cannot refer internal variable
(test-error ((lambda (var0)
               (define var1 (lambda () 1))
               (eq? (var0) var0))
             (lambda () var1)))
;; defining procedure can refer other (and self) variables as if letrec
(test-equal '(#t #t #t #t #t)
            ((lambda (var0)
               (define var1 (lambda () var0))
               (define var2 (lambda () var0))
               (begin
                 (define var3 (lambda () var0))
                 (begin
                   (define var4 (lambda () var0))))
               (define var5 (lambda () var0))
               (list (eq? (var1) var0)
                     (eq? (var2) var0)
                     (eq? (var3) var0)
                     (eq? (var4) var0)
                     (eq? (var5) var0)))
             (lambda () 0)))
(test-equal '(#t #t #t #t #t)
            ((lambda ()
              (define var1 (lambda () var1))
              (define var2 (lambda () var1))
              (begin
                (define var3 (lambda () var1))
                (begin
                  (define var4 (lambda () var1))))
              (define var5 (lambda () var1))
              (list (eq? (var1) var1)
                    (eq? (var2) var1)
                    (eq? (var3) var1)
                    (eq? (var4) var1)
                    (eq? (var5) var1)))))
(test-equal '(#t #t #t #t #t)
            ((lambda ()
              (define var1 (lambda () var2))
              (define var2 (lambda () var2))
              (begin
                (define var3 (lambda () var2))
                (begin
                  (define var4 (lambda () var2))))
              (define var5 (lambda () var2))
              (list (eq? (var1) var2)
                    (eq? (var2) var2)
                    (eq? (var3) var2)
                    (eq? (var4) var2)
                    (eq? (var5) var2)))))
(test-equal '(#t #t #t #t #t)
            ((lambda ()
              (define var1 (lambda () var3))
              (define var2 (lambda () var3))
              (begin
                (define var3 (lambda () var3))
                (begin
                  (define var4 (lambda () var3))))
              (define var5 (lambda () var3))
              (list (eq? (var1) var3)
                    (eq? (var2) var3)
                    (eq? (var3) var3)
                    (eq? (var4) var3)
                    (eq? (var5) var3)))))
(test-equal '(#t #t #t #t #t)
            ((lambda ()
              (define var1 (lambda () var4))
              (define var2 (lambda () var4))
              (begin
                (define var3 (lambda () var4))
                (begin
                  (define var4 (lambda () var4))))
              (define var5 (lambda () var4))
              (list (eq? (var1) var4)
                    (eq? (var2) var4)
                    (eq? (var3) var4)
                    (eq? (var4) var4)
                    (eq? (var5) var4)))))
(test-equal '(#t #t #t #t #t)
            ((lambda ()
              (define var1 (lambda () var5))
              (define var2 (lambda () var5))
              (begin
                (define var3 (lambda () var5))
                (begin
                  (define var4 (lambda () var5))))
              (define var5 (lambda () var5))
              (list (eq? (var1) var5)
                    (eq? (var2) var5)
                    (eq? (var3) var5)
                    (eq? (var4) var5)
                    (eq? (var5) var5)))))
(test-end "let internal definitions cross reference")

(test-begin "let internal definitions valid forms")
(if (not (provided? "internal-definitions"))
    (test-skip-rest))
;; valid internal definitions
(test-equal '(1)
            ((lambda ()
              (define var1 1)
              (list var1))))
(test-equal '(1)
            ((lambda ()
              (define (proc1) 1)
              (list (proc1)))))
(test-equal '(1 2)
            ((lambda ()
              (define var1 1)
              (define var2 2)
              (list var1 var2))))
(test-equal '(1 2)
            ((lambda ()
               (define (proc1) 1)
               (define (proc2) 2)
               (list (proc1) (proc2)))))
(test-equal '(1 2)
            ((lambda ()
               (define var1 1)
               (define (proc2) 2)
               (list var1 (proc2)))))
(test-equal '(1 2)
            ((lambda ()
               (define (proc1) 1)
               (define var2 2)
               (list (proc1) var2))))
;; SigScheme accepts '(begin)' as valid internal definition '(begin
;; <definition>*)' as defined in "7.1.6 Programs and definitions" of R5RS
;; although it is rejected as expression '(begin <sequence>)' as defined in
;; "7.1.3 Expressions".
(test-equal 1
            ((lambda ()
               (begin)
               1)))
(test-equal 1
            ((lambda ()
               (begin)
               (define var1 1)
               (begin)
               1)))
(test-equal '(1)
            ((lambda ()
               (begin
                 (define var1 1))
               (list var1))))
(test-equal '(1)
            ((lambda ()
              (begin
                (define (proc1) 1))
              (list (proc1)))))
(test-equal '(1 2)
            ((lambda ()
              (begin
                (define var1 1)
                (define var2 2))
              (list var1 var2))))
(test-equal '(1 2)
            ((lambda ()
              (begin
                (define (proc1) 1)
                (define (proc2) 2))
              (list (proc1) (proc2)))))
(test-equal '(1 2)
            ((lambda ()
              (begin
                (define var1 1)
                (define (proc2) 2))
              (list var1 (proc2)))))
(test-equal '(1 2)
            ((lambda ()
              (begin
                (define (proc1) 1)
                (define var2 2))
              (list (proc1) var2))))
(test-equal '(1 2 3 4 5 6)
            ((lambda ()
              (begin
                (define (proc1) 1)
                (define var2 2)
                (begin
                  (define (proc3) 3)
                  (define var4 4)
                  (begin
                    (define (proc5) 5)
                    (define var6 6))))
              (list (proc1) var2
                    (proc3) var4
                    (proc5) var6))))
;; begin block and single definition mixed
(test-equal '(1 2 3 4 5 6)
            ((lambda ()
              (begin)
              (define (proc1) 1)
              (begin
                (define var2 2)
                (begin
                  (define (proc3) 3)
                  (begin)
                  (define var4 4)))
              (begin)
              (define (proc5) 5)
              (begin
                (begin
                  (begin
                    (begin)))
                (define var6 6)
                (begin))
              (begin)
              (list (proc1) var2
                    (proc3) var4
                    (proc5) var6))))
(test-end "let internal definitions valid forms")

(test-begin "let internal definitions invalid begin blocks")
;; appending a non-definition expression into a begin block is invalid
(test-error ((lambda ()
               (begin
                 (define var1 1)
                 'val)
               (list var1))))
(test-error ((lambda ()
              (begin
                (define (proc1) 1)
                'val)
              (list (proc1)))))
(test-error ((lambda ()
              (begin
                (define var1 1)
                (define var2 2)
                'val)
              (list var1 var2))))
(test-error ((lambda ()
              (begin
                (define (proc1) 1)
                (define (proc2) 2)
                'val)
              (list (proc1) (proc2)))))
(test-error ((lambda ()
              (begin
                (define var1 1)
                (define (proc2) 2)
                'val)
              (list var1 (proc2)))))
(test-error ((lambda ()
              (begin
                (define (proc1) 1)
                (define var2 2)
                'val)
              (list (proc1) var2))))
(test-error ((lambda ()
              (begin
                (define (proc1) 1)
                (define var2 2)
                (begin
                  (define (proc3) 3)
                  (define var4 4)
                  (begin
                    (define (proc5) 5)
                    (define var6 6)
                    'val)))
              (list (proc1) var2
                    (proc3) var4
                    (proc5) var6))))
(test-end "let internal definitions invalid begin blocks")

(test-begin "let internal definitions invalid placement")
;; a non-definition expression prior to internal definition is invalid
(test-error ((lambda ()
              'val
              (define var1 1))))
(test-error ((lambda ()
              'val
              (define (proc1) 1))))
(test-error ((lambda ()
              'val
              (define var1 1)
              (define var2 2))))
(test-error ((lambda ()
              'val
              (define (proc1) 1)
              (define (proc2) 2))))
(test-error ((lambda ()
              'val
              (define var1 1)
              (define (proc2) 2))))
(test-error ((lambda ()
              'val
              (define (proc1) 1)
              (define var2 2))))
(test-error ((lambda ()
              'val
              (begin))))
(test-error ((lambda ()
              'val
              (begin
                (define var1 1)))))
(test-error ((lambda ()
              'val
              (begin
                (define (proc1) 1)))))
(test-error ((lambda ()
              'val
              (begin
                (define var1 1)
                (define var2 2)))))
(test-error ((lambda ()
              'val
              (begin
                (define (proc1) 1)
                (define (proc2) 2)))))
(test-error ((lambda ()
              'val
              (begin
                (define var1 1)
                (define (proc2) 2)))))
(test-error ((lambda ()
              'val
              (begin
                (define (proc1) 1)
                (define var2 2)))))
(test-error ((lambda ()
              'val
              (begin
                (define (proc1) 1)
                (define var2 2)
                (begin
                  (define (proc3) 3)
                  (define var4 4)
                  (begin
                    (define (proc5) 5)
                    (define var6 6)))))))
(test-error ((lambda ()
              (begin
                (define (proc1) 1)
                (define var2 2)
                'val
                (begin
                  (define (proc3) 3)
                  (define var4 4)
                  (begin
                    (define (proc5) 5)
                    (define var6 6)))))))
;; a non-definition expression prior to internal definition is invalid even if
;; expression(s) is following the internal definition
(test-error ((lambda ()
              'val
              (define var1 1)
              'val)))
(test-error ((lambda ()
              'val
              (define (proc1) 1)
              'val)))
(test-error ((lambda ()
              'val
              (define var1 1)
              (define var2 2)
              'val)))
(test-error ((lambda ()
              'val
              (define (proc1) 1)
              (define (proc2) 2)
              'val)))
(test-error ((lambda ()
              'val
              (define var1 1)
              (define (proc2) 2)
              'val)))
(test-error ((lambda ()
              'val
              (define (proc1) 1)
              (define var2 2)
              'val)))
(test-error ((lambda ()
              'val
              (begin)
              'val)))
(test-error ((lambda ()
              'val
              (begin
                (define var1 1))
              'val)))
(test-error ((lambda ()
              'val
              (begin
                (define (proc1) 1))
              'val)))
(test-error ((lambda ()
              'val
              (begin
                (define var1 1)
                (define var2 2))
              'val)))
(test-error ((lambda ()
              'val
              (begin
                (define (proc1) 1)
                (define (proc2) 2))
              'val)))
(test-error ((lambda ()
              'val
              (begin
                (define var1 1)
                (define (proc2) 2))
              'val)))
(test-error ((lambda ()
              'val
              (begin
                (define (proc1) 1)
                (define var2 2))
              'val)))
(test-error ((lambda ()
              'val
              (begin
                (define (proc1) 1)
                (define var2 2)
                (begin
                  (define (proc3) 3)
                  (define var4 4)
                  (begin
                    (define (proc5) 5)
                    (define var6 6))))
              (list (proc1) var2
                    (proc3) var4
                    (proc5) var6))))
(test-end "let internal definitions invalid placement")


(test-end "test-lambda")
