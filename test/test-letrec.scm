;;  Filename : test-letrec.scm
;;  About    : unit test for R5RS letrec
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

(test-begin "test-letrec")


;;
;; letrec
;;
(test-begin "letrec invalid form")
;; bindings and body required
(test-error (letrec))
(test-error (letrec ()))
(test-error (letrec ((a))))
(test-error (letrec ((a 1))))
(test-error (letrec (a 1)))
(test-error (letrec a))
(test-error (letrec #()))
(test-error (letrec #f))
(test-error (letrec #t))
;; bindings must be a list
(test-error (letrec a 'val))
(test-error (letrec #f 'val))
(test-error (letrec #() 'val))
(test-error (letrec #t 'val))
;; each binding must be a 2-elem list
(test-error (letrec (a 1) 'val))
(test-error (letrec ((a)) 'val))
(test-error (letrec ((a 1 'excessive)) 'val))
(test-error (letrec ((a 1) . (b 2)) 'val))
(test-error (letrec ((a . 1)) 'val))
(test-error (letrec ((a  1)) . a))
(test-argcheck-error (letrec ((a  1)) 'val . a))
(test-error (letrec (1) #t))
(test-end "letrec invalid form")

(test-begin "letrec binding syntactic keyword")
(test-equal 7 (letrec ((else 7)) else))
(test-equal 8 (letrec ((=> 8)) =>))
(test-equal 9 (letrec ((unquote 9)) unquote))
(test-error else)
(test-error =>)
(test-argcheck-error unquote)
(test-end "letrec binding syntactic keyword")

(test-begin "letrec env isolation")
;; referencing a variable within bindings evaluation is invalid
(test-error (letrec ((var1 1)
                     (var2 var1))
              'result))
(test-error (letrec ((var1 var2)
                     (var2 2))
              'result))
;; all variables are kept unbound until body evaluation
(test-equal '(#f #f #f)
            (letrec ((var1 (symbol-bound? 'var1))
                     (var2 (symbol-bound? 'var1))
                     (var3 (symbol-bound? 'var1)))
              (list var1 var2 var3)))
(test-equal '(#f #f #f)
            (letrec ((var1 (symbol-bound? 'var2))
                     (var2 (symbol-bound? 'var2))
                     (var3 (symbol-bound? 'var2)))
              (list var1 var2 var3)))
(test-equal '(#f #f #f)
            (letrec ((var1 (symbol-bound? 'var3))
                     (var2 (symbol-bound? 'var3))
                     (var3 (symbol-bound? 'var3)))
              (list var1 var2 var3)))
;; all variables can be referred from any position of the bindings
(test-equal '(#t #t #t)
            (letrec ((var1 (lambda () var1))
                     (var2 (lambda () var1))
                     (var3 (lambda () var1)))
              (list (eq? (var1) var1)
                    (eq? (var2) var1)
                    (eq? (var3) var1))))
(test-equal '(#t #t #t)
            (letrec ((var1 (lambda () var2))
                     (var2 (lambda () var2))
                     (var3 (lambda () var2)))
              (list (eq? (var1) var2)
                    (eq? (var2) var2)
                    (eq? (var3) var2))))
(test-equal '(#t #t #t)
            (letrec ((var1 (lambda () var3))
                     (var2 (lambda () var3))
                     (var3 (lambda () var3)))
              (list (eq? (var1) var3)
                    (eq? (var2) var3)
                    (eq? (var3) var3))))
(test-end "letrec env isolation")

(test-begin "letrec internal definitions lacking sequence part")
;; at least one <expression> is required
(test-error (letrec ()
              (define var1 1)))
(test-error (letrec ()
              (define (proc1) 1)))
(test-error (letrec ()
              (define var1 1)
              (define var2 2)))
(test-error (letrec ()
              (define (proc1) 1)
              (define (proc2) 2)))
(test-error (letrec ()
              (define var1 1)
              (define (proc2) 2)))
(test-error (letrec ()
              (define (proc1) 1)
              (define var2 2)))
(test-error (letrec ()
              (begin)))
(test-error (letrec ()
              (begin
                (define var1 1))))
(test-error (letrec ()
              (begin
                (define (proc1) 1))))
(test-error (letrec ()
              (begin
                (define var1 1)
                (define var2 2))))
(test-error (letrec ()
              (begin
                (define (proc1) 1)
                (define (proc2) 2))))
(test-error (letrec ()
              (begin
                (define var1 1)
                (define (proc2) 2))))
(test-error (letrec ()
              (begin
                (define (proc1) 1)
                (define var2 2))))
;; appending a non-definition expression into a begin block is invalid
(test-error (letrec ()
              (begin
                (define var1 1)
                'val)))
(test-error (letrec ()
              (begin
                (define (proc1) 1)
                'val)))
(test-error (letrec ()
              (begin
                (define var1 1)
                (define var2 2)
                'val)))
(test-error (letrec ()
              (begin
                (define (proc1) 1)
                (define (proc2) 2)
                'val)))
(test-error (letrec ()
              (begin
                (define var1 1)
                (define (proc2) 2)
                'val)))
(test-error (letrec ()
              (begin
                (define (proc1) 1)
                (define var2 2)
                'val)))
(test-end "letrec internal definitions lacking sequence part")

(test-begin "letrec internal definitions cross reference")
(if (not (provided? "internal-definitions"))
    (test-skip-rest))
;; R5RS: 5.2.2 Internal definitions
;; Just as for the equivalent `letrec' expression, it must be possible to
;; evaluate each <expression> of every internal definition in a <body> without
;; assigning or referring to the value of any <variable> being defined.
;; R7RS: Internal definitions are letrec* and refer to the preceding ones.
(if (provided? "r7rs")
    (test-equal 1
                (letrec ()
                  (define var1 1)
                  (define var2 var1)
                  var2))
    (test-error (letrec ()
                  (define var1 1)
                  (define var2 var1)
                  'val)))
(test-error (letrec ()
              (define var1 var2)
              (define var2 2)
              'val))
(test-error (letrec ()
              (define var1 var1)
              'val))
(test-equal '(0 0 0 0 0)
            (letrec ((var0 0))
              (define var1 var0)
              (define var2 var0)
              (begin
                (define var3 var0)
                (begin
                  (define var4 var0)))
              (define var5 var0)
              (list var1 var2 var3 var4 var5)))
(test-equal '(#f #f #f #f #f #f)
            (letrec ((var0 (symbol-bound? 'var1)))
              (define var1 (symbol-bound? 'var1))
              (define var2 (symbol-bound? 'var1))
              (begin
                (define var3 (symbol-bound? 'var1))
                (begin
                  (define var4 (symbol-bound? 'var1))))
              (define var5 (symbol-bound? 'var1))
              (list var0 var1 var2 var3 var4 var5)))
(test-equal '(#f #f #f #f #f #f)
            (letrec ((var0 (symbol-bound? 'var2)))
              (define var1 (symbol-bound? 'var2))
              (define var2 (symbol-bound? 'var2))
              (begin
                (define var3 (symbol-bound? 'var2))
                (begin
                  (define var4 (symbol-bound? 'var2))))
              (define var5 (symbol-bound? 'var2))
              (list var0 var1 var2 var3 var4 var5)))
(test-equal '(#f #f #f #f #f #f)
            (letrec ((var0 (symbol-bound? 'var3)))
              (define var1 (symbol-bound? 'var3))
              (define var2 (symbol-bound? 'var3))
              (begin
                (define var3 (symbol-bound? 'var3))
                (begin
                  (define var4 (symbol-bound? 'var3))))
              (define var5 (symbol-bound? 'var3))
              (list var0 var1 var2 var3 var4 var5)))
(test-equal '(#f #f #f #f #f #f)
            (letrec ((var0 (symbol-bound? 'var4)))
              (define var1 (symbol-bound? 'var4))
              (define var2 (symbol-bound? 'var4))
              (begin
                (define var3 (symbol-bound? 'var4))
                (begin
                  (define var4 (symbol-bound? 'var4))))
              (define var5 (symbol-bound? 'var4))
              (list var0 var1 var2 var3 var4 var5)))
(test-equal '(#f #f #f #f #f #f)
            (letrec ((var0 (symbol-bound? 'var5)))
              (define var1 (symbol-bound? 'var5))
              (define var2 (symbol-bound? 'var5))
              (begin
                (define var3 (symbol-bound? 'var5))
                (begin
                  (define var4 (symbol-bound? 'var5))))
              (define var5 (symbol-bound? 'var5))
              (list var0 var1 var2 var3 var4 var5)))
;; outer let cannot refer internal variable even if letrec
(test-error (letrec ((var0 (lambda () var1)))
              (define var1 (lambda () 1))
              (eq? (var0) var0)))
;; defining procedure can refer other (and self) variables as if letrec
(test-equal '(#t #t #t #t #t)
            (letrec ((var0 (lambda () 0)))
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
                    (eq? (var5) var0))))
(test-equal '(#t #t #t #t #t)
            (letrec ()
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
                    (eq? (var5) var1))))
(test-equal '(#t #t #t #t #t)
            (letrec ()
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
                    (eq? (var5) var2))))
(test-equal '(#t #t #t #t #t)
            (letrec ()
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
                    (eq? (var5) var3))))
(test-equal '(#t #t #t #t #t)
            (letrec ()
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
                    (eq? (var5) var4))))
(test-equal '(#t #t #t #t #t)
            (letrec ()
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
                    (eq? (var5) var5))))
(test-end "letrec internal definitions cross reference")

(test-begin "letrec internal definitions valid forms")
(if (not (provided? "internal-definitions"))
    (test-skip-rest))
;; valid internal definitions
(test-equal '(1)
            (letrec ()
              (define var1 1)
              (list var1)))
(test-equal '(1)
            (letrec ()
              (define (proc1) 1)
              (list (proc1))))
(test-equal '(1 2)
            (letrec ()
              (define var1 1)
              (define var2 2)
              (list var1 var2)))
(test-equal '(1 2)
            (letrec ()
              (define (proc1) 1)
              (define (proc2) 2)
              (list (proc1) (proc2))))
(test-equal '(1 2)
            (letrec ()
              (define var1 1)
              (define (proc2) 2)
              (list var1 (proc2))))
(test-equal '(1 2)
            (letrec ()
              (define (proc1) 1)
              (define var2 2)
              (list (proc1) var2)))
;; SigScheme accepts '(begin)' as valid internal definition '(begin
;; <definition>*)' as defined in "7.1.6 Programs and definitions" of R5RS
;; although it is rejected as expression '(begin <sequence>)' as defined in
;; "7.1.3 Expressions".
(test-equal 1
            (letrec ()
              (begin)
              1))
(test-equal 1
            (letrec ()
              (begin)
              (define var1 1)
              (begin)
              1))
(test-equal '(1)
            (letrec ()
              (begin
                (define var1 1))
              (list var1)))
(test-equal '(1)
            (letrec ()
              (begin
                (define (proc1) 1))
              (list (proc1))))
(test-equal '(1 2)
            (letrec ()
              (begin
                (define var1 1)
                (define var2 2))
              (list var1 var2)))
(test-equal '(1 2)
            (letrec ()
              (begin
                (define (proc1) 1)
                (define (proc2) 2))
              (list (proc1) (proc2))))
(test-equal '(1 2)
            (letrec ()
              (begin
                (define var1 1)
                (define (proc2) 2))
              (list var1 (proc2))))
(test-equal '(1 2)
            (letrec ()
              (begin
                (define (proc1) 1)
                (define var2 2))
              (list (proc1) var2)))
(test-equal '(1 2 3 4 5 6)
            (letrec ()
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
                    (proc5) var6)))
;; begin block and single definition mixed
(test-equal '(1 2 3 4 5 6)
            (letrec ()
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
                    (proc5) var6)))
(test-end "letrec internal definitions valid forms")

(test-begin "letrec internal definitions invalid begin blocks")
;; appending a non-definition expression into a begin block is invalid
(test-error (letrec ()
              (begin
                (define var1 1)
                'val)
              (list var1)))
(test-error (letrec ()
              (begin
                (define (proc1) 1)
                'val)
              (list (proc1))))
(test-error (letrec ()
              (begin
                (define var1 1)
                (define var2 2)
                'val)
              (list var1 var2)))
(test-error (letrec ()
              (begin
                (define (proc1) 1)
                (define (proc2) 2)
                'val)
              (list (proc1) (proc2))))
(test-error (letrec ()
              (begin
                (define var1 1)
                (define (proc2) 2)
                'val)
              (list var1 (proc2))))
(test-error (letrec ()
              (begin
                (define (proc1) 1)
                (define var2 2)
                'val)
              (list (proc1) var2)))
(test-error (letrec ()
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
                    (proc5) var6)))
(test-end "letrec internal definitions invalid begin blocks")

(test-begin "letrec internal definitions invalid placement")
;; a non-definition expression prior to internal definition is invalid
(test-error (letrec ()
              'val
              (define var1 1)))
(test-error (letrec ()
              'val
              (define (proc1) 1)))
(test-error (letrec ()
              'val
              (define var1 1)
              (define var2 2)))
(test-error (letrec ()
              'val
              (define (proc1) 1)
              (define (proc2) 2)))
(test-error (letrec ()
              'val
              (define var1 1)
              (define (proc2) 2)))
(test-error (letrec ()
              'val
              (define (proc1) 1)
              (define var2 2)))
(test-error (letrec ()
              'val
              (begin)))
(test-error (letrec ()
              'val
              (begin
                (define var1 1))))
(test-error (letrec ()
              'val
              (begin
                (define (proc1) 1))))
(test-error (letrec ()
              'val
              (begin
                (define var1 1)
                (define var2 2))))
(test-error (letrec ()
              'val
              (begin
                (define (proc1) 1)
                (define (proc2) 2))))
(test-error (letrec ()
              'val
              (begin
                (define var1 1)
                (define (proc2) 2))))
(test-error (letrec ()
              'val
              (begin
                (define (proc1) 1)
                (define var2 2))))
(test-error (letrec ()
              'val
              (begin
                (define (proc1) 1)
                (define var2 2)
                (begin
                  (define (proc3) 3)
                  (define var4 4)
                  (begin
                    (define (proc5) 5)
                    (define var6 6))))))
(test-error (letrec ()
              (begin
                (define (proc1) 1)
                (define var2 2)
                'val
                (begin
                  (define (proc3) 3)
                  (define var4 4)
                  (begin
                    (define (proc5) 5)
                    (define var6 6))))))
;; a non-definition expression prior to internal definition is invalid even if
;; expression(s) is following the internal definition
(test-error (letrec ()
              'val
              (define var1 1)
              'val))
(test-error (letrec ()
              'val
              (define (proc1) 1)
              'val))
(test-error (letrec ()
              'val
              (define var1 1)
              (define var2 2)
              'val))
(test-error (letrec ()
              'val
              (define (proc1) 1)
              (define (proc2) 2)
              'val))
(test-error (letrec ()
              'val
              (define var1 1)
              (define (proc2) 2)
              'val))
(test-error (letrec ()
              'val
              (define (proc1) 1)
              (define var2 2)
              'val))
(test-error (letrec ()
              'val
              (begin)
              'val))
(test-error (letrec ()
              'val
              (begin
                (define var1 1))
              'val))
(test-error (letrec ()
              'val
              (begin
                (define (proc1) 1))
              'val))
(test-error (letrec ()
              'val
              (begin
                (define var1 1)
                (define var2 2))
              'val))
(test-error (letrec ()
              'val
              (begin
                (define (proc1) 1)
                (define (proc2) 2))
              'val))
(test-error (letrec ()
              'val
              (begin
                (define var1 1)
                (define (proc2) 2))
              'val))
(test-error (letrec ()
              'val
              (begin
                (define (proc1) 1)
                (define var2 2))
              'val))
(test-error (letrec ()
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
                    (proc5) var6)))
(test-end "letrec internal definitions invalid placement")

(test-begin "letrec binding syntactic keywords")
(test-argcheck-error (letrec ((syn define))
                       #t))
(test-argcheck-error (letrec ((syn if))
                       #t))
(test-argcheck-error (letrec ((syn and))
                       #t))
(test-argcheck-error (letrec ((syn cond))
                       #t))
(test-argcheck-error (letrec ((syn begin))
                       #t))
(test-argcheck-error (letrec ((syn do))
                       #t))
(test-argcheck-error (letrec ((syn delay))
                       #t))
(test-argcheck-error (letrec ((syn let*))
                       #t))
(test-error (letrec ((syn else))
              #t))
(test-error (letrec ((syn =>))
              #t))
(test-argcheck-error (letrec ((syn quote))
                       #t))
(test-argcheck-error (letrec ((syn quasiquote))
                       #t))
(test-argcheck-error (letrec ((syn unquote))
                       #t))
(test-argcheck-error (letrec ((syn unquote-splicing))
                       #t))
(test-end "letrec binding syntactic keywords")


(test-begin "letrec")
;; empty bindings is allowed by the formal syntax spec
(test-equal 'result
            (letrec () 'result))
;; duplicate variable name
(test-argcheck-error (letrec ((var1 1)
                              (var1 2))
                       'result))
;; masked variable name
(test-equal '(#t #t #t #t #f #f #t #t #f #t)
            (letrec ((var1 (lambda () var3))
                     (var2 (lambda () var4))
                     (var3 (lambda () var3))
                     (var4 (lambda () var4))
                     (var1in #f)
                     (var2in #f)
                     (var5in #f))
              (letrec ((var1 (lambda () var1))
                       (var2 (lambda () var1))
                       (var5 (lambda () var3)))
                (set! var1in var1)
                (set! var2in var2)
                (set! var5in var5))
              (list (eq? (var1) var3)
                    (eq? (var2) var4)
                    (eq? (var3) var3)
                    (eq? (var4) var4)
                    (eq? (var1in) var1)
                    (eq? (var2in) var1)
                    (eq? (var1in) var1in)
                    (eq? (var2in) var1in)
                    (eq? (var2in) var2in)
                    (eq? (var5in) var3))))
(test-equal '(4 5 3)
            (letrec ((var1 1)
                     (var2 2)
                     (var3 3))
              (letrec ((var1 4)
                       (var2 5))
                (list var1 var2 var3))))
(test-equal '(1 2 3)
            (letrec ((var1 1)
                     (var2 2)
                     (var3 3))
              (letrec ((var1 4)
                       (var2 5))
                'dummy)
              (list var1 var2 var3)))
(test-equal '(1 2 9)
            (letrec ((var1 1)
                     (var2 2)
                     (var3 3))
              (letrec ((var1 4)
                       (var2 5))
                (set! var3 (+ var1 var2)))
              (list var1 var2 var3)))
(test-equal '(1 2 30)
            (letrec ((var1 1)
                     (var2 2)
                     (var3 3))
              (letrec ((var1 4)
                       (var2 5))
                (set! var1 10)
                (set! var2 20)
                (set! var3 (+ var1 var2)))
              (list var1 var2 var3)))
(test-equal '(1 2 3 (10 20))
            (letrec ((var1 1)
                     (var2 2)
                     (var3 3)
                     (var4 (letrec ((var1 4)
                                        (var2 5))
                                 (set! var1 10)
                                 (set! var2 20)
                                 (list var1 var2))))
              (list var1 var2 var3 var4)))
(test-error (letrec ((var1 1)
                     (var2 2)
                     (var3 3)
                     (var4 (letrec ((var1 4)
                                        (var2 5))
                                 (set! var3 10))))
              (list var1 var2 var3 var4)))
;; variable reference
(test-equal 3
            (letrec ((proc (lambda () var))
                     (var  3))
              (proc)))
;; ordinary recursions
(test-equal 4
            (letrec ((proc1 (lambda (n) (+ n 1)))
                     (proc2 (lambda (n) (proc1 n))))
              (proc2 3)))
(test-equal 6
            (letrec ((proc1 (lambda (n) (proc2 n)))
                     (proc2 (lambda (n) (+ n 1))))
              (proc1 5)))
(test-equal #t
            (letrec ((even?
                      (lambda (n)
                        (if (zero? n)
                            #t
                            (odd? (- n 1)))))
                     (odd?
                      (lambda (n)
                        (if (zero? n)
                            #f
                            (even? (- n 1))))))
              (even? 88)))
(test-equal #f
            (letrec ((even?
                      (lambda (n)
                        (if (zero? n)
                            #t
                            (odd? (- n 1)))))
                     (odd?
                      (lambda (n)
                        (if (zero? n)
                            #f
                            (even? (- n 1))))))
              (odd? 88)))
(test-end "letrec")

(test-begin "letrec lexical scope")
(define count-letrec
  (letrec ((count-letrec 0))  ;; intentionally same name
    (lambda ()
      (set! count-letrec (+ count-letrec 1))
      count-letrec)))
(test-assert (procedure? count-letrec))
(test-equal 1 (count-letrec))
(test-equal 2 (count-letrec))
(test-equal 3 (count-letrec))
(test-end "letrec lexical scope")


(test-end "test-letrec")
