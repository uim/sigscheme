;;  Filename : test-library.scm
;;  About    : unit test for R7RS libraries
;;
;;  Copyright (c) 2026 SigScheme Project https://github.com/uim/sigscheme
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

(if (not (provided? "r7rs"))
    (test-skip-file "R7RS is not enabled"))

(test-begin "test-library")

;; %%make-module is the internal procedure used by define-library.
(test-begin "module definitions")
(define module (%%make-module '(test module)))
(define count 100)
(eval '(define count 0) module)
(eval '(define (next!) (set! count (+ count 1)) count) module)
(define next! (eval 'next! module))
(test-equal 1 (next!))
(test-equal 2 (next!))
(test-equal 100 count)
(test-equal 2 (eval 'count module))
(test-assert (symbol-bound? 'next! module))
(test-assert (not (symbol-bound? 'module-only)))
(eval '(define module-only 1) module)
(test-assert (not (symbol-bound? 'module-only)))
(test-assert (symbol-bound? 'module-only module))
(test-end "module definitions")

(test-begin "module redefinition")
(eval '(define module-only 2) module)
(test-equal 2 (eval 'module-only module))
(test-end "module redefinition")

(test-begin "module builtins")
;; Builtins are visible in a module.
(test-equal 3 (eval '(car (list 3)) module))
(test-end "module builtins")

(test-begin "module begin and define-values")
(eval '(begin (define c 3) (define d 4)) module)
(test-equal 7 (eval '(+ c d) module))
(eval '(define-values (a b) (values 1 2)) module)
(test-equal '(1 2) (eval '(list a b) module))
(test-assert (not (symbol-bound? 'a)))
(test-end "module begin and define-values")

(test-begin "module internal definitions")
(if (not (provided? "internal-definitions"))
    (test-skip-rest))
(eval '(define (f x) (define y 2) (let ((z 3)) (+ x y z count))) module)
(test-equal 8 (eval '(f 1) module))
(test-end "module internal definitions")

(test-begin "module syntax")
(eval '(define-syntax inc!
         (syntax-rules ()
           ((_ v) (begin (set! v (+ v 1)) v))))
      module)
(test-equal 6 (eval '(let ((z 5)) (inc! z)) module))
(test-equal 3 (eval '(inc! count) module))
(test-assert (not (symbol-bound? 'inc!)))
(test-end "module syntax")

(test-begin "module many definitions")
(let loop ((i 0))
  (if (< i 200)
      (begin
        (eval (list 'define
                    (string->symbol (string-append "x" (number->string i)))
                    i)
              module)
        (loop (+ i 1)))))
(test-equal 0 (eval 'x0 module))
(test-equal 150 (eval 'x150 module))
(test-equal 199 (eval 'x199 module))
(test-end "module many definitions")

(test-begin "module toplevel definitions")
(if (provided? "strict-toplevel-definitions")
    (test-error (eval '(if #t (define zz 1)) module)))
(test-error (eval 'no-such-variable module))
(test-end "module toplevel definitions")

(test-begin "builtins redefined in the global environment")
(define orig-car car)
(define orig-cdr cdr)
;; Tests can't be run while car and cdr are redefined because the test
;; runner also uses them.
(define (car x) 'global-car)
(define global-car-result (car '(1)))
(define module-car-result (eval '(car '(1)) module))
(set! cdr (lambda (x) 'global-cdr))
(define global-cdr-result (cdr '(1 2)))
(define module-cdr-result (eval '(cdr '(1 2)) module))
(define car orig-car)
(set! cdr orig-cdr)
(test-equal 'global-car global-car-result)
(test-equal 1 module-car-result)
(test-equal 'global-cdr global-cdr-result)
(test-equal '(2) module-cdr-result)
(test-equal 1 (car '(1)))
(test-equal '(2) (cdr '(1 2)))
(test-end "builtins redefined in the global environment")

(test-begin "builtins written in Scheme use builtins")
(define orig-open-input-file open-input-file)
(define (open-input-file path) (error "global open-input-file is used"))
(test-equal #\;
            (call-with-input-file (string-append (%%system-load-path)
                                                 "/srfi-9.scm")
              read-char))
(define open-input-file orig-open-input-file)
(test-end "builtins written in Scheme use builtins")

(test-begin "builtin macros")
;; Template identifiers of a builtin macro are resolved in the builtin
;; namespace even if the global environment redefines them.
(define orig-make-record-type %%make-record-type)
(define %%make-record-type 'global)
(define-record-type point (make-point x y) point?
  (x point-x)
  (y point-y))
(test-assert (point? (make-point 1 2)))
(test-equal 2 (point-y (make-point 1 2)))
(define %%make-record-type orig-make-record-type)
(eval '(define-record-type module-point (make-module-point x) module-point?
         (x module-point-x))
      module)
(test-equal 5 (eval '(module-point-x (make-module-point 5)) module))
(test-assert (not (symbol-bound? 'make-module-point)))
(test-end "builtin macros")

(test-begin "module macros")
(eval '(define secret 42) module)
(eval '(define-syntax get-secret (syntax-rules () ((_) secret))) module)
(test-equal 42 (eval '(get-secret) module))
(test-equal 42 (eval '(let ((secret 0)) (get-secret)) module))
(test-end "module macros")

(test-begin "global variables")
(define global-counter 0)
(set! global-counter (+ global-counter 1))
(test-equal 1 global-counter)
(test-error (eval '(set! no-such-global 1)
                  (interaction-environment)))
(test-end "global variables")

(test-begin "define-library")
(%%define-builtin-library '(test builtin) '(car cdr list +))
(define-library (test counter)
  (export make-counter (rename counter-value value) counter-list)
  (import (only (test builtin) list +))
  (begin
    (define counter-value 0)
    (define (make-counter)
      (set! counter-value (+ counter-value 1))
      counter-value)
    (define (counter-list) (list 'counter counter-value))))
(test-assert (not (symbol-bound? 'make-counter)))
(import (test counter))
(test-equal 1 (make-counter))
(test-equal 2 (make-counter))
;; The REPL shares the location with the library.
(test-equal 2 value)
(test-assert (not (symbol-bound? 'counter-value)))
(test-equal '(counter 2) (counter-list))
(test-end "define-library")

(test-begin "define-library macros")
(define-library (test swap)
  (export swap!)
  (begin
    (define (swapped) 'swapped)
    (define-syntax swap!
      (syntax-rules ()
        ((_ a b) (let ((tmp a)) (set! a b) (set! b tmp) (swapped)))))))
(define-library (test use-swap)
  (export use-swap)
  (import (test swap) (test builtin))
  (begin
    (define (use-swap)
      (let ((x 1) (y 2))
        (list (swap! x y) x y)))))
(import (test use-swap))
(test-equal '(swapped 2 1) (use-swap))
(import (test swap))
(define swapped 'global)
(define x 1)
(define y 2)
(test-equal 'swapped (swap! x y))
(test-equal '(2 1) (list x y))
(test-end "define-library macros")

(test-begin "import sets")
(define-library (test abc)
  (export a b c)
  (begin
    (define a 'a)
    (define b 'b)
    (define c 'c)))
(import (only (test abc) a))
(test-equal 'a a)
(test-assert (not (symbol-bound? 'b)))
(import (except (test abc) a b))
(test-equal 'c c)
(test-assert (not (symbol-bound? 'b)))
(import (prefix (only (test abc) b) abc:))
(test-equal 'b abc:b)
(import (rename (test abc) (b bb) (c cc)))
(test-equal '(a b c) (list a bb cc))
(test-error (eval '(import (only (test abc) d))
                  (interaction-environment)))
(test-error (eval '(import (except (test abc) d))
                  (interaction-environment)))
(test-error (eval '(import (rename (test abc) (d e)))
                  (interaction-environment)))
(test-error (eval '(import (test unknown))
                  (interaction-environment)))
(test-end "import sets")

(test-begin "import builtins")
(define-library (test my-car)
  (export car)
  (import (only (test builtin) list))
  (begin
    (define (car x) (list 'my x))))
;; Tests can't be run while car is replaced because the test runner also
;; uses it.
(import (test my-car))
(define my-car-result (car '(1)))
;; Builtins such as import use the builtin car.
(import (only (test abc) a))
(import (test builtin))
(test-equal '(my (1)) my-car-result)
(test-equal 'a a)
(test-equal 1 (car '(1)))
(test-end "import builtins")

(test-begin "imported bindings")
(test-error (define-library (test redefine)
              (import (test builtin))
              (begin (define car 1))))
(test-error (define-library (test set)
              (import (test abc))
              (begin (set! a 1))))
(test-error (define-library (test set-builtin)
              (import (test builtin))
              (begin (set! car 1))))
(test-error (define-library (test unimported)
              (begin (set! cons 1))))
(test-equal '(1 . 2) (cons 1 2))
(test-error (define-library (test conflict)
              (import (test builtin) (test my-car))))
;; The same binding can be imported twice.
(define-library (test same)
  (export same-car)
  (import (test builtin) (only (test builtin) car))
  (begin (define same-car car)))
(import (test same))
(test-equal 1 (same-car '(1)))
(test-error (define-library (test unexported)
              (export undefined)))
;; The REPL can redefine and mutate imported bindings without changing the
;; library.
(define value 10)
(test-equal 3 (make-counter))
(test-equal 10 value)
(import (test counter))
(test-equal 3 value)
(set! value 20)
(test-equal '(counter 3) (counter-list))
(test-end "imported bindings")

(test-begin "library files")
;; (test library greeting) is defined in test/library/greeting.sld.
(import (test library greeting))
(test-equal '(hello world) (greet 'world))
(test-equal 'r7rs greeting-feature)
;; include-ci folds symbols.
(test-equal 'hello loud)
(test-error (eval '(import (test library broken))
                  (interaction-environment)))
(test-error (eval '(import (test library circular))
                  (interaction-environment)))
(test-error (eval '(import (test library nonexistent))
                  (interaction-environment)))
(test-end "library files")

(test-begin "define-library cond-expand")
(define-library (test cond-expand)
  (export feature)
  (cond-expand
   ((library (test library nonexistent))
    (begin (define feature 'nonexistent)))
   ((or no-such-feature (not r7rs))
    (begin (define feature 'not-r7rs)))
   ((library (test library greeting))
    (begin (define feature 'greeting)))
   (else
    (begin (define feature 'else)))))
(import (test cond-expand))
(test-equal 'greeting feature)
(test-error (define-library (test include)
              (include "test/library/nonexistent.scm")))
(test-end "define-library cond-expand")

(test-begin "standard libraries")
(define-library (test standard)
  (export double)
  (import (scheme base) (prefix (scheme cxr) cxr:))
  (begin
    (define (double lst)
      (vector-map (lambda (x) (* x 2)) (list->vector (cxr:cdddr lst))))))
(import (test standard))
(test-equal #(8 10) (double '(1 2 3 4 5)))
;; All symbols in scheme-libraries.scm are exported except unbound ones.
(define standard-libraries
  (call-with-input-file "lib/scheme-libraries.scm"
    (lambda (port)
      (let loop ((libraries '()))
        (let ((library (read port)))
          (if (eof-object? library)
              libraries
              (loop (cons library libraries))))))))
;; They are unbound without R5RS quasiquote.
(define unbound-symbols
  (if (symbol-bound? 'quasiquote)
      '()
      '(quasiquote unquote unquote-splicing)))
(define (unexported-symbols library)
  (let ((exports (%%library-exports (car library))))
    (let loop ((syms (cdr library))
               (unexported '()))
      (cond
       ((null? syms) (reverse unexported))
       ((assq (car syms) exports) (loop (cdr syms) unexported))
       ((memq (car syms) unbound-symbols) (loop (cdr syms) unexported))
       (else (loop (cdr syms) (cons (car syms) unexported)))))))
(test-equal '((scheme base))
            (assoc '(scheme base) (map (lambda (library)
                                         (cons (car library)
                                               (unexported-symbols library)))
                                       standard-libraries)))
(for-each (lambda (library)
            (if (not (equal? (car library) '(scheme base)))
                (test-equal (list (car library))
                            (cons (car library)
                                  (unexported-symbols library)))))
          standard-libraries)
(test-end "standard libraries")

(test-begin "environment")
(define env (environment '(scheme base) '(only (scheme write) write)))
(test-equal 3 (eval '(+ 1 2) env))
(test-equal 'ok (eval '(let ((x 'ok)) x) env))
(test-assert (eq? env (environment '(scheme base)
                                    '(only (scheme write) write))))
;; A definition in an immutable environment is rejected by the same
;; mechanism as strict toplevel definitions.
(if (provided? "strict-toplevel-definitions")
    (test-error (eval '(define x 1) env)))
(test-error (eval '(set! car 1) env))
(test-end "environment")

(test-begin "cond-expand library")
;; cond-expand is valid only at toplevel.
(test-equal 'base (eval '(cond-expand
                          ((library (scheme base)) 'base)
                          (else 'else))
                        (interaction-environment)))
(test-equal 'else (eval '(cond-expand
                          ((library (scheme nonexistent)) 'nonexistent)
                          (else 'else))
                        (interaction-environment)))
(test-end "cond-expand library")

(test-begin "auxiliary syntax")
(define-library (test auxiliary)
  (export classify)
  (import (only (scheme base) define cond case else => _ ... quote
                syntax-rules define-syntax list))
  (begin
    (define-syntax first
      (syntax-rules ()
        ((_ x y ...) x)))
    (define (classify x)
      (list (cond ((assv x '((1 . one))) => cdr)
                  (else 'other))
            (case x
              ((1) 'one)
              (else 'other))
            (first x 2 3)))))
(import (test auxiliary))
(test-equal '(one one 1) (classify 1))
(test-equal '(other other 2) (classify 2))
(test-error (eval 'else (environment '(scheme base))))
(test-end "auxiliary syntax")

(test-begin "include")
(include "test/library/greeting.scm")
(test-equal '(hello include) (greet 'include))
(include-ci "test/library/greeting-ci.scm")
(test-equal 'hello loud)
(if (provided? "internal-definitions")
    (test-equal '(hello in-let) (let ()
                                  (include "test/library/greeting.scm")
                                  (greet 'in-let))))
(test-error (eval '(include "test/library/nonexistent.scm")
                  (interaction-environment)))
(test-end "include")

(test-end "test-library")
