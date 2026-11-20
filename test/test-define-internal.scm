;;  Filename : test-define-internal.scm
;;  About    : unit test for R5RS internal definitions
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

;; internal definitions in 'let' variants are writtin at test-let.scm

(require-extension (srfi 64))

(if (not (provided? "internal-definitions"))
    (test-skip-file "R5RS internal definitions is not enabled"))

(test-begin "test-define-internal")

(test-begin "internal defintions")
(test-equal 14
            (let ((x 5))
              (+ (let ()
                   (define x 6)
                   (+ x 3))
                 x)))
(test-equal 14
            (let ((x 5))
              (+ (let* ()
                   (define x 6)
                   (+ x 3))
                 x)))
(test-equal 14
            (let ((x 5))
              (+ (letrec ()
                   (define x 6)
                   (+ x 3))
                 x)))
(test-equal 14
            (let ((x 5))
              (+ ((lambda ()
                    (define x 6)
                    (+ x 3)))
                 x)))
(test-equal 14
            (let ((x 5))
              (+ (let ()
                   (define (f)
                     (define x 6)
                     (+ x 3))
                   (f))
                 x)))
(test-end "internal defintions")

(test-begin "internal defintions: letrec-like behavior")
(test-equal 45
            (let ((x 5))
              (define foo (lambda (y) (bar x y)))
              (define bar (lambda (a b) (+ (* a b) a)))
              (foo (+ x 3))))
(test-equal 45
            (let ((x 5))
              (define bar (lambda (a b) (+ (* a b) a)))
              (define foo (lambda (y) (bar x y)))
              (foo (+ x 3))))
(test-error (let ((x 5))
              (define foo bar)
              (define bar (lambda (a b) (+ (* a b) a)))
              (foo x (+ x 3))))
;; R7RS: Internal definitions are letrec* and refer to the preceding ones.
(if (provided? "r7rs")
    (begin
      (test-equal 45
                  (let ((x 5))
                    (define bar (lambda (a b) (+ (* a b) a)))
                    (define foo bar)
                    (foo x (+ x 3))))
      (test-equal 3
                  (let ()
                    (define foo 1)
                    (define bar (+ foo 1))
                    (+ foo bar))))
    (begin
      (test-error (let ((x 5))
                    (define bar (lambda (a b) (+ (* a b) a)))
                    (define foo bar)
                    (foo x (+ x 3))))
      (test-error (let ()
                    (define foo 1)
                    (define bar (+ foo 1))
                    (+ foo bar)))))
(test-error (let ()
              (define bar (+ foo 1))
              (define foo 1)
              (+ foo bar)))
(if (provided? "r7rs")
    (test-equal 3
                (let ((foo 3))
                  (define foo 1)
                  (define bar (+ foo 1))
                  (+ foo bar)))
    (test-error (let ((foo 3))
                  (define foo 1)
                  (define bar (+ foo 1))
                  (+ foo bar))))
(test-error (let ((foo 3))
              (define bar (+ foo 1))
              (define foo 1)
              (+ foo bar)))
(test-end "internal defintions: letrec-like behavior")

(test-begin "internal defintions: non-beginning of block")
(test-error (let ()
              (define foo 1)
              (set! foo 5)
              (define bar 2)
              (+ foo bar)))
(test-error (let* ()
              (define foo 1)
              (set! foo 5)
              (define bar 2)
              (+ foo bar)))
(test-error (letrec ()
              (define foo 1)
              (set! foo 5)
              (define bar 2)
              (+ foo bar)))
(test-error ((lambda ()
               (define foo 1)
               (set! foo 5)
               (define bar 2)
               (+ foo bar))))
(test-error (begin (define (f)
                     (define foo 1)
                     (set! foo 5)
                     (define bar 2)
                     (+ foo bar))
                   (f)))
(test-end "internal defintions: non-beginning of block")

(test-begin "internal defintions: non-beginning of block (in begin)")
(test-error (let ()
              (define foo 1)
              (set! foo 5)
              (begin
                (define bar 2))
              (+ foo bar)))
(test-error (let* ()
              (define foo 1)
              (set! foo 5)
              (begin
                (define bar 2))
              (+ foo bar)))
(test-error (letrec ()
              (define foo 1)
              (set! foo 5)
              (begin
                (define bar 2))
              (+ foo bar)))
(test-error ((lambda ()
               (define foo 1)
               (set! foo 5)
               (begin
                 (define bar 2))
               (+ foo bar))))
(test-error (begin (define (f)
                     (define foo 1)
                     (set! foo 5)
                     (begin
                       (define bar 2))
                     (+ foo bar))
                   (f)))
(test-end "internal defintions: non-beginning of block (in begin)")

(test-begin "internal defintions: non-beginning of block (in eval)")
(test-equal 7
            (let ()
              (define foo 1)
              (set! foo 5)
              (eval '(define bar 2)
                    (interaction-environment))
              (+ foo bar)))
(test-equal 7
            (let* ()
              (define foo 1)
              (set! foo 5)
              (eval '(define bar 2)
                    (interaction-environment))
              (+ foo bar)))
(test-equal 7
            (letrec ()
              (define foo 1)
              (set! foo 5)
              (eval '(define bar 2)
                    (interaction-environment))
              (+ foo bar)))
(test-equal 7
            ((lambda ()
               (define foo 1)
               (set! foo 5)
               (eval '(define bar 2)
                     (interaction-environment))
               (+ foo bar))))
(test-equal 7
            (let ()
              (define (f)
                (define foo 1)
                (set! foo 5)
                (eval '(define bar 2)
                      (interaction-environment))
                (+ foo bar))
              (f)))
(test-end "internal defintions: non-beginning of block (in eval)")

;; As specified as follows in R5RS, definitions in following forms are invalid.
;;
;; 5.2 Definitions
;;
;; Definitions are valid in some, but not all, contexts where expressions are
;; allowed. They are valid only at the top level of a <program> and at the
;; beginning of a <body>.
;;
;; 5.2.2 Internal definitions
;;
;; Definitions may occur at the beginning of a <body> (that is, the body of a
;; lambda, let, let*, letrec, let-syntax, or letrec-syntax expression or that
;; of a definition of an appropriate form).
;;
;; Wherever an internal definition may occur (begin <definition1> ...) is
;; equivalent to the sequence of definitions that form the body of the begin.
(test-begin "definition in do")
(test-error (do ((i 0 (+ i 1)))
                ((= i 1) (+ x 3))
              (define x 6)))
(test-error (do ((i 0 (+ i 1)))
                ((= i 1) (+ x 3))
              (begin
                (define x 6))))
(test-equal 9
            (do ((i 0 (+ i 1)))
                ((= i 1) (+ x 3))
              (eval '(define x 6)
                    (interaction-environment))))
(test-end "definition in do")
(test-begin "definition in if")
(test-error (if #t
                (define x 6)))
(test-error (if #t
                (begin
                  (define x 6))))
(if (provided? "strict-r5rs")
    ;; R5RS doesn't specify the return value of define.
    (begin
      (if #t
          (eval '(define x 7)
                (interaction-environment)))
      (test-equal 7 x))
    (test-equal 'x
                (if #t
                    (eval '(define x 6)
                          (interaction-environment)))))
(test-end "definition in if")


(test-begin "func-form define internal definitions lacking sequence part")
;; at least one <expression> is required
(define (f)
  (define var1 1))
(test-error (f))
(define (f)
  (define (proc1) 1))
(test-error (f))
(define (f)
  (define var1 1)
  (define var2 2))
(test-error (f))
(define (f)
  (define (proc1) 1)
  (define (proc2) 2))
(test-error (f))
(define (f)
  (define var1 1)
  (define (proc2) 2))
(test-error (f))
(define (f)
  (define (proc1) 1)
  (define var2 2))
(test-error (f))
(define (f)
  (begin))
(test-error (f))
(define (f)
  (begin
    (define var1 1)))
(test-error (f))
(define (f)
  (begin
    (define (proc1) 1)))
(test-error (f))
(define (f)
  (begin
    (define var1 1)
    (define var2 2)))
(test-error (f))
(define (f)
  (begin
    (define (proc1) 1)
    (define (proc2) 2)))
(test-error (f))
(define (f)
  (begin
    (define var1 1)
    (define (proc2) 2)))
(test-error (f))
(define (f)
  (begin
    (define (proc1) 1)
    (define var2 2)))
(test-error (f))
;; appending a non-definition expression into a begin block is invalid
(define (f)
  (begin
    (define var1 1)
    'val))
(test-error (f))
(define (f)
  (begin
    (define (proc1) 1)
    'val))
(test-error (f))
(define (f)
  (begin
    (define var1 1)
    (define var2 2)
    'val))
(test-error (f))
(define (f)
  (begin
    (define (proc1) 1)
    (define (proc2) 2)
    'val))
(test-error (f))
(define (f)
  (begin
    (define var1 1)
    (define (proc2) 2)
    'val))
(test-error (f))
(define (f)
  (begin
    (define (proc1) 1)
    (define var2 2)
    'val))
(test-error (f))
(test-end "func-form define internal definitions lacking sequence part")

(test-begin "func-form define internal definitions cross reference")
;; R5RS: 5.2.2 Internal definitions
;; Just as for the equivalent `letrec' expression, it must be possible to
;; evaluate each <expression> of every internal definition in a <body> without
;; assigning or referring to the value of any <variable> being defined.
(define (f)
  (define var1 1)
  (define var2 var1)
  var2)
;; R7RS: Internal definitions are letrec* and refer to the preceding ones.
(if (provided? "r7rs")
    (test-equal 1 (f))
    (test-error (f)))
(define (f)
  (define var1 var2)
  (define var2 2)
  'val)
(test-error (f))
(define (f)
  (define var1 var1)
  'val)
(test-error (f))
(define (f var0)
  (define var1 var0)
  (define var2 var0)
  (begin
    (define var3 var0)
    (begin
      (define var4 var0)))
  (define var5 var0)
  (list var1 var2 var3 var4 var5))
(test-equal '(0 0 0 0 0)
            (f 0))
(test-equal '(#f #f #f #f #f #f)
            (list (symbol-bound? 'var0)
                  (symbol-bound? 'var1)
                  (symbol-bound? 'var2)
                  (symbol-bound? 'var3)
                  (symbol-bound? 'var4)
                  (symbol-bound? 'var5)))
(define (f var0)
  (define var1 (symbol-bound? 'var1))
  (define var2 (symbol-bound? 'var1))
  (begin
    (define var3 (symbol-bound? 'var1))
    (begin
      (define var4 (symbol-bound? 'var1))))
  (define var5 (symbol-bound? 'var1))
  (list var0 var1 var2 var3 var4 var5))
(test-equal '(#f #f #f #f #f #f)
            (f #f))
(define (f var0)
  (define var1 (symbol-bound? 'var3))
  (define var2 (symbol-bound? 'var3))
  (begin
    (define var3 (symbol-bound? 'var3))
    (begin
      (define var4 (symbol-bound? 'var3))))
  (define var5 (symbol-bound? 'var3))
  (list var0 var1 var2 var3 var4 var5))
(test-equal '(#f #f #f #f #f #f)
            (f #f))
(define (f var0)
  (define var1 (symbol-bound? 'var4))
  (define var2 (symbol-bound? 'var4))
  (begin
    (define var3 (symbol-bound? 'var4))
    (begin
      (define var4 (symbol-bound? 'var4))))
  (define var5 (symbol-bound? 'var4))
  (list var0 var1 var2 var3 var4 var5))
(test-equal '(#f #f #f #f #f #f)
            (f #f))
(define (f var0)
  (define var1 (symbol-bound? 'var5))
  (define var2 (symbol-bound? 'var5))
  (begin
    (define var3 (symbol-bound? 'var5))
    (begin
      (define var4 (symbol-bound? 'var5))))
  (define var5 (symbol-bound? 'var5))
  (list var0 var1 var2 var3 var4 var5))
(test-equal '(#f #f #f #f #f #f)
            (f #f))
;; defining procedure can refer other (and self) variables as if letrec
(define (f var0)
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
(test-equal '(#t #t #t #t #t)
            (f (lambda () 0)))
(define (f)
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
        (eq? (var5) var1)))
(test-equal '(#t #t #t #t #t)
            (f))
(define (f)
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
        (eq? (var5) var2)))
(test-equal '(#t #t #t #t #t)
            (f))
(define (f)
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
        (eq? (var5) var4)))
(test-equal '(#t #t #t #t #t)
            (f))
(define (f)
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
        (eq? (var5) var5)))
(test-equal '(#t #t #t #t #t)
            (f))
(test-end "func-form define internal definitions cross reference")

(test-begin "func-form define internal definitions valid forms")
;; valid internal definitions
(define (f)
  (define var1 1)
  (list var1))
(test-equal '(1)
            (f))
(define (f)
  (define (proc1) 1)
  (list (proc1)))
(test-equal '(1)
            (f))
(define (f)
  (define var1 1)
  (define var2 2)
  (list var1 var2))
(test-equal '(1 2)
            (f))
(define (f)
  (define (proc1) 1)
  (define (proc2) 2)
  (list (proc1) (proc2)))
(test-equal '(1 2)
            (f))
(define (f)
  (define var1 1)
  (define (proc2) 2)
  (list var1 (proc2)))
(test-equal '(1 2)
            (f))
(define (f)
  (define (proc1) 1)
  (define var2 2)
  (list (proc1) var2))
(test-equal '(1 2)
            (f))
;; SigScheme accepts '(begin)' as valid internal definition '(begin
;; <definition>*)' as defined in "7.1.6 Programs and definitions" of R5RS
;; although it is rejected as expression '(begin <sequence>)' as defined in
;; "7.1.3 Expressions".
(define (f)
  (begin)
  1)
(test-equal 1
            (f))
(define (f)
  (begin)
  (define var1 1)
  (begin)
  1)
(test-equal 1
            (f))
(define (f)
  (begin
    (define var1 1))
  (list var1))
(test-equal '(1)
            (f))
(define (f)
  (begin
    (define (proc1) 1))
  (list (proc1)))
(test-equal '(1)
            (f))
(define (f)
  (begin
    (define var1 1)
    (define var2 2))
  (list var1 var2))
(test-equal '(1 2)
            (f))
(define (f)
  (begin
    (define (proc1) 1)
    (define (proc2) 2))
  (list (proc1) (proc2)))
(test-equal '(1 2)
            (f))
(define (f)
  (begin
    (define var1 1)
    (define (proc2) 2))
  (list var1 (proc2)))
(test-equal '(1 2)
            (f))
(define (f)
  (begin
    (define (proc1) 1)
    (define var2 2))
  (list (proc1) var2))
(test-equal '(1 2)
            (f))
(define (f)
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
        (proc5) var6))
(test-equal '(1 2 3 4 5 6)
            (f))
;; begin block and single definition mixed
(define (f)
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
        (proc5) var6))
(test-equal '(1 2 3 4 5 6)
            (f))
(test-end "func-form define internal definitions valid forms")

(test-begin "func-form define internal definitions invalid begin blocks")
(define (f)
  (begin
    (define var1 1)
    'val)
  (list var1))
(test-error (f))
(define (f)
  (begin
    (define (proc1) 1)
    'val)
  (list (proc1)))
(test-error (f))
(define (f)
  (begin
    (define var1 1)
    (define var2 2)
    'val)
  (list var1 var2))
(test-error (f))
(define (f)
  (begin
    (define (proc1) 1)
    (define (proc2) 2)
    'val)
  (list (proc1) (proc2)))
(test-error (f))
(define (f)
  (begin
    (define var1 1)
    (define (proc2) 2)
    'val)
  (list var1 (proc2)))
(test-error (f))
(define (f)
  (begin
    (define (proc1) 1)
    (define var2 2)
    'val)
  (list (proc1) var2))
(test-error (f))
(test-end "func-form define internal definitions invalid begin blocks")
(define (f)
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
        (proc5) var6))

(test-begin "func-form define internal definitions invalid placement")
;; a non-definition expression prior to internal definition is invalid
(test-error (f))
(define (f)
  'val
  (define var1 1))
(test-error (f))
(define (f)
  'val
  (define (proc1) 1))
(test-error (f))
(define (f)
  'val
  (define var1 1)
  (define var2 2))
(test-error (f))
(define (f)
  'val
  (define (proc1) 1)
  (define (proc2) 2))
(test-error (f))
(define (f)
  'val
  (define var1 1)
  (define (proc2) 2))
(test-error (f))
(define (f)
  'val
  (define (proc1) 1)
  (define var2 2))
(test-error (f))
(define (f)
  'val
  (begin))
(test-error (f))
(define (f)
  'val
  (begin
    (define var1 1)))
(test-error (f))
(define (f)
  'val
  (begin
    (define (proc1) 1)))
(test-error (f))
(define (f)
  'val
  (begin
    (define var1 1)
    (define var2 2)))
(test-error (f))
(define (f)
  'val
  (begin
    (define (proc1) 1)
    (define (proc2) 2)))
(test-error (f))
(define (f)
  'val
  (begin
    (define var1 1)
    (define (proc2) 2)))
(test-error (f))
(define (f)
  'val
  (begin
    (define (proc1) 1)
    (define var2 2)))
(test-error (f))
(define (f)
  'val
  (begin
    (define (proc1) 1)
    (define var2 2)
    (begin
      (define (proc3) 3)
      (define var4 4)
      (begin
        (define (proc5) 5)
        (define var6 6)))))
(test-error (f))
(define (f)
  (begin
    (define (proc1) 1)
    (define var2 2)
    'val
    (begin
      (define (proc3) 3)
      (define var4 4)
      (begin
        (define (proc5) 5)
        (define var6 6)))))
(test-error (f))
;; a non-definition expression prior to internal definition is invalid even if
;; expression(s) is following the internal definition
(define (f)
  'val
  (define var1 1)
  'val)
(test-error (f))
(define (f)
  'val
  (define (proc1) 1)
  'val)
(test-error (f))
(define (f)
  'val
  (define var1 1)
  (define var2 2)
  'val)
(test-error (f))
(define (f)
  'val
  (define (proc1) 1)
  (define (proc2) 2)
  'val)
(test-error (f))
(define (f)
  'val
  (define var1 1)
  (define (proc2) 2)
  'val)
(test-error (f))
(define (f)
  'val
  (define (proc1) 1)
  (define var2 2)
  'val)
(test-error (f))
(define (f)
  'val
  (begin)
  'val)
(test-error (f))
(define (f)
  'val
  (begin
    (define var1 1))
  'val)
(test-error (f))
(define (f)
  'val
  (begin
    (define (proc1) 1))
  'val)
(test-error (f))
(define (f)
  'val
  (begin
    (define var1 1)
    (define var2 2))
  'val)
(test-error (f))
(define (f)
  'val
  (begin
    (define (proc1) 1)
    (define (proc2) 2))
  'val)
(test-error (f))
(define (f)
  'val
  (begin
    (define var1 1)
    (define (proc2) 2))
  'val)
(test-error (f))
(define (f)
  'val
  (begin
    (define (proc1) 1)
    (define var2 2))
  'val)
(test-error (f))
(define (f)
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
        (proc5) var6))
(test-error (f))
(test-end "func-form define internal definitions invalid placement")


(test-end "test-define-internal")
