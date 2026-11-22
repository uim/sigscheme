;;  Filename : test-define.scm
;;  About    : unit test for R5RS 'define'
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

;; internal definitions in 'define' are writtin at test-define-internal.scm
;; internal definitions in 'let' variants are writtin at test-let.scm
;; see also test-begin.scm for top-level definitions

(require-extension (srfi 64))

(test-begin "test-define")

(test-begin "define invalid form")
(test-error (let () (define) #t))
(test-error (let () (define . a) #t))
(test-error (let () (define a) #t))
(test-error (let () (define a . 2) #t))
(test-error (let () (define a 1 'excessive) #t))
(test-error (let () (define a 1 . 'excessive) #t))
;; <variable> is not a symbol
(test-error (let () (define 1) #t))
(test-error (let () (define 1 . 1) #t))
(test-error (let () (define 1 1) #t))
(test-error (let () (define #t 1) #t))
(test-error (let () (define #f 1) #t))
(test-error (let () (define 1 1 'excessive) #t))
(test-error (let () (define 1 1 . 'excessive) #t))
;; function forms
;; An improper body such as "1 . 1" is detected without calling the
;; procedure.
(test-error (let () (define ()) #t))
(test-error (let () (define () 1) #t))
(test-error (let () (define (f)) #t))
(test-error (let () (define (f) . 1) #t))
(test-argcheck-error (let () (define (f) 1 . 1) #t))
(test-error (let () (define (f x)) #t))
(test-error (let () (define (f x) . 1) #t))
(test-argcheck-error (let () (define (f x) 1 . 1) #t))
(test-error (let () (define (f . x)) #t))
(test-error (let () (define (f . x) . 1) #t))
(test-argcheck-error (let () (define (f . x) 1 . 1) #t))
(test-end "define invalid form")

(test-begin "define syntactic keywords as value")
(test-argcheck-error (eval '(define syn define)
                           (interaction-environment)))
(test-argcheck-error (eval '(define syn if)
                           (interaction-environment)))
(test-argcheck-error (eval '(define syn and)
                           (interaction-environment)))
(test-argcheck-error (eval '(define syn cond)
                           (interaction-environment)))
(test-argcheck-error (eval '(define syn begin)
                           (interaction-environment)))
(test-argcheck-error (eval '(define syn do)
                           (interaction-environment)))
(test-argcheck-error (eval '(define syn delay)
                           (interaction-environment)))
(test-argcheck-error (eval '(define syn let*)
                           (interaction-environment)))
(test-error (eval '(define syn else)
                  (interaction-environment)))
(test-error (eval '(define syn =>)
                  (interaction-environment)))
(test-argcheck-error (eval '(define syn quote)
                           (interaction-environment)))
(test-argcheck-error (eval '(define syn quasiquote)
                           (interaction-environment)))
(test-argcheck-error (eval '(define syn unquote)
                           (interaction-environment)))
(test-argcheck-error (eval '(define syn unquote-splicing)
                           (interaction-environment)))
(test-end "define syntactic keywords as value")

(test-begin "define syntactic keywords as value internally")
(test-argcheck-error (let ()
                       (define syn define)
                       #t))
(test-argcheck-error (let ()
                       (define syn if)
                       #t))
(test-argcheck-error (let ()
                       (define syn and)
                       #t))
(test-argcheck-error (let ()
                       (define syn cond)
                       #t))
(test-argcheck-error (let ()
                       (define syn begin)
                       #t))
(test-argcheck-error (let ()
                       (define syn do)
                       #t))
(test-argcheck-error (let ()
                       (define syn delay)
                       #t))
(test-argcheck-error (let ()
                       (define syn let*)
                       #t))
(test-error (let ()
              (define syn else)
              #t))
(test-error (let ()
              (define syn =>)
              #t))
(test-argcheck-error (let ()
                       (define syn quote)
                       #t))
(test-argcheck-error (let ()
                       (define syn quasiquote)
                       #t))
(test-argcheck-error (let ()
                       (define syn unquote)
                       #t))
(test-argcheck-error (let ()
                       (define syn unquote-splicing)
                       #t))
(test-end "define syntactic keywords as value internally")

(test-begin "define syntactic keyword internally")
(if (provided? "internal-definitions")
    (begin
      (test-equal 7 ((lambda () (define else 7) else)))
      (test-equal 8 ((lambda () (define => 8) =>)))
      (test-equal 9 ((lambda () (define do 9) do)))))
(test-error else)
(test-error =>)
(test-argcheck-error do)
(test-end "define syntactic keyword internally")

(test-begin "define syntactic keyword as top-level variable")
(define else 3)
(test-equal 3 else)
(define => 4)
(test-equal 4 =>)
(define do 5)
(test-equal 5 do)
(test-end "define syntactic keyword as top-level variable")

(if (and sigscheme?
         (provided? "strict-argcheck"))
    (begin
      (test-begin "define function form: boolean as an arg")
      (test-error (let () (define (f . #t) #t) #t))
      (test-error (let () (define (f #t) #t) #t))
      (test-error (let () (define (f x #t) #t) #t))
      (test-error (let () (define (f #t x) #t) #t))
      (test-error (let () (define (f x . #t) #t) #t))
      (test-error (let () (define (f #t . x) #t) #t))
      (test-error (let () (define (f x y #t) #t) #t))
      (test-error (let () (define (f x y . #t) #t) #t))
      (test-error (let () (define (f x #t y) #t) #t))
      (test-error (let () (define (f x #t . y) #t) #t))
      (test-end "define function form: boolean as an arg")
      (test-begin "define function form: intger as an arg")
      (test-error (let () (define (f . 1) #t) #t))
      (test-error (let () (define (f 1) #t) #t))
      (test-error (let () (define (f x 1) #t) #t))
      (test-error (let () (define (f 1 x) #t) #t))
      (test-error (let () (define (f x . 1) #t) #t))
      (test-error (let () (define (f 1 . x) #t) #t))
      (test-error (let () (define (f x y 1) #t) #t))
      (test-error (let () (define (f x y . 1) #t) #t))
      (test-error (let () (define (f x 1 y) #t) #t))
      (test-error (let () (define (f x 1 . y) #t) #t))
      (test-end "define function form: intger as an arg")
      (test-begin "define function form: null as an arg")
      ;; A valid definition is wrapped by (let () ...) because a test
      ;; evaluates its expression as a body of a procedure and a body
      ;; needs an expression after definitions.
      (if (provided? "internal-definitions")
          (test-assert (let () (define (f . ()) #t) #t)))
      (test-error (let () (define (f ()) #t) #t))
      (test-error (let () (define (f x ()) #t) #t))
      (test-error (let () (define (f () x) #t) #t))
      (if (provided? "internal-definitions")
          (test-assert (let () (define (f x . ()) #t) #t)))
      (test-error (let () (define (f () . x) #t) #t))
      (test-error (let () (define (f x y ()) #t) #t))
      (if (provided? "internal-definitions")
          (test-assert (let () (define (f x y . ()) #t) #t)))
      (test-error (let () (define (f x () y) #t) #t))
      (test-error (let () (define (f x () . y) #t) #t))
      (test-end "define function form: null as an arg")
      (test-begin "define function form: pair as an arg")
      (if (provided? "internal-definitions")
          (test-assert (let () (define (f . (a)) #t) #t)))
      (test-error (let () (define (f (a)) #t) #t))
      (test-error (let () (define (f x (a)) #t) #t))
      (test-error (let () (define (f (a) x) #t) #t))
      (if (provided? "internal-definitions")
          (test-assert (let () (define (f x . (a)) #t) #t)))
      (test-error (let () (define (f (a) . x) #t) #t))
      (test-error (let () (define (f x y (a)) #t) #t))
      (if (provided? "internal-definitions")
          (test-assert (let () (define (f x y . (a)) #t) #t)))
      (test-error (let () (define (f x (a) y) #t) #t))
      (test-error (let () (define (f x (a) . y) #t) #t))
      (test-end "define function form: pair as an arg")
      (test-begin "define function form: char as an arg")
      (test-error (let () (define (f . #\a) #t) #t))
      (test-error (let () (define (f #\a) #t) #t))
      (test-error (let () (define (f x #\a) #t) #t))
      (test-error (let () (define (f #\a x) #t) #t))
      (test-error (let () (define (f x . #\a) #t) #t))
      (test-error (let () (define (f #\a . x) #t) #t))
      (test-error (let () (define (f x y #\a) #t) #t))
      (test-error (let () (define (f x y . #\a) #t) #t))
      (test-error (let () (define (f x #\a y) #t) #t))
      (test-error (let () (define (f x #\a . y) #t) #t))
      (test-end "define function form: char as an arg")
      (test-begin "define function form: string as an arg")
      (test-error (let () (define (f . "a") #t) #t))
      (test-error (let () (define (f "a") #t) #t))
      (test-error (let () (define (f x "a") #t) #t))
      (test-error (let () (define (f "a" x) #t) #t))
      (test-error (let () (define (f x . "a") #t) #t))
      (test-error (let () (define (f "a" . x) #t) #t))
      (test-error (let () (define (f x y "a") #t) #t))
      (test-error (let () (define (f x y . "a") #t) #t))
      (test-error (let () (define (f x "a" y) #t) #t))
      (test-error (let () (define (f x "a" . y) #t) #t))
      (test-end "define function form: string as an arg")
      (test-begin "define function form: vector as an arg")
      (test-error (let () (define (f . #(a)) #t) #t))
      (test-error (let () (define (f #(a)) #t) #t))
      (test-error (let () (define (f x #(a)) #t) #t))
      (test-error (let () (define (f #(a) x) #t) #t))
      (test-error (let () (define (f x . #(a)) #t) #t))
      (test-error (let () (define (f #(a) . x) #t) #t))
      (test-error (let () (define (f x y #(a)) #t) #t))
      (test-error (let () (define (f x y . #(a)) #t) #t))
      (test-error (let () (define (f x #(a) y) #t) #t))
      (test-error (let () (define (f x #(a) . y) #t) #t))
      (test-end "define function form: vector as an arg")))

;; top-level define cannot be placed under a non-begin structure.
;; See also test-begin.scm for top-level definitions.
(if (provided? "strict-toplevel-definitions")
    (begin
      (test-begin "top-level definition invalid forms")
      (test-error (eval '(if #t (define var0 1))
                        (interaction-environment)))
      (test-error (eval '(if #f #t (define var0 1))
                        (interaction-environment)))
      (test-error (eval '(and (define var0 1))
                        (interaction-environment)))
      (test-error (eval '(or (define var0 1))
                        (interaction-environment)))
      (test-error (eval '(cond (#t (define var0 1)))
                        (interaction-environment)))
      (test-error (eval '(cond (else (define var0 1)))
                        (interaction-environment)))
      (test-error (eval '(case 'key ((key) (define var0 1)))
                        (interaction-environment)))
      (test-error (eval '(case 'key (else (define var0 1)))
                        (interaction-environment)))
      (test-end "top-level definition invalid forms")
      (test-begin "ttt")
      ;; test being evaled at non-tail part of <sequence>
      (test-error (eval '(and (define var0 1) #t)
                        (interaction-environment)))
      (test-error (eval '(or (define var0 1) #t)
                        (interaction-environment)))
      (test-error (eval '(cond (#t (define var0 1) #t))
                        (interaction-environment)))
      (test-error (eval '(cond (else (define var0 1) #t))
                        (interaction-environment)))
      (test-error (eval '(case 'key ((key) (define var0 1) #t))
                        (interaction-environment)))
      (test-error (eval '(case 'key (else (define var0 1) #t))
                        (interaction-environment)))
      (test-end "ttt")))

; basic define
(define val1 3)
(test-equal "basic define check" 3 val1)

; redefine
(define val1 5)
(test-equal "redefine check" 5 val1)

; define lambda
(define (what? x)
  "DEADBEEF" x)
(test-equal "func define" 10 (what? 10))

(define what2?
  (lambda (x)
    "DEADBEEF" x))
(test-equal "func define" 10 (what2? 10))

(define (nullarg)
  "nullarg")
(test-equal "nullarg test" "nullarg" (nullarg))

(define (add x y)
  (+ x y))
(test-equal "func define" 10 (add 2 8))

; tests for dot list arguments
(define (dotarg1 . a)
  a)
(test-equal "dot arg test 1" '(1 2) (dotarg1 1 2))

(define (dotarg2 a . b)
  a)
(test-equal "dot arg test 2" 1 (dotarg2 1 2))

(define (dotarg3 a . b)
  b)
(test-equal "dot arg test 3" '(2) (dotarg3 1 2))
(test-equal "dot arg test 4" '(2 3) (dotarg3 1 2 3))


(define (dotarg4 a b . c)
  b)
(test-equal "dot arg test 5" 2 (dotarg4 1 2 3))

(define (dotarg5 a b . c)
  c)
(test-equal "dot arg test 6" '(3 4) (dotarg5 1 2 3 4))

; set!
(define (set-dot a . b)
  (set! b '(1 2))
  b)
(test-equal "set dot test" '(1 2) (set-dot '()))

; test for internal define
; more comprehensive tests are written at test-define-internal.scm
(define (idefine-o a)
  (define (idefine-i c)
    (+ c 3))
  (idefine-i a))
(if (provided? "internal-definitions")
    (test-equal "internal define1" 5 (idefine-o 2)))

(define (idefine0 a)
  (define (idefine1 . args)
    (apply +  args))
  (define (idefine2 c)
    (+ c 2))
  (+ (idefine1 1 2 3 4 5) (idefine2 a)))
(if (provided? "internal-definitions")
    (test-equal "internal define2" 17 (idefine0 0)))


(test-end "test-define")
