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


(require-extension (unittest))

(if (not (provided? "r7rs"))
    (test-skip "R7RS is not enabled"))

(define tn test-name)

;; %%make-module is the internal procedure used by define-library.
(tn "module definitions")
(define module (%%make-module '(test module)))
(define count 100)
(eval '(define count 0) module)
(eval '(define (next!) (set! count (+ count 1)) count) module)
(define next! (eval 'next! module))
(assert-equal? (tn) 1 (next!))
(assert-equal? (tn) 2 (next!))
(assert-equal? (tn) 100 count)
(assert-equal? (tn) 2 (eval 'count module))
(assert-true (tn) (symbol-bound? 'next! module))
(assert-false (tn) (symbol-bound? 'module-only))
(eval '(define module-only 1) module)
(assert-false (tn) (symbol-bound? 'module-only))
(assert-true (tn) (symbol-bound? 'module-only module))

(tn "module redefinition")
(eval '(define module-only 2) module)
(assert-equal? (tn) 2 (eval 'module-only module))

(tn "module builtins")
;; Builtins are visible in a module.
(assert-equal? (tn) 3 (eval '(car (list 3)) module))

(tn "module begin and define-values")
(eval '(begin (define c 3) (define d 4)) module)
(assert-equal? (tn) 7 (eval '(+ c d) module))
(eval '(define-values (a b) (values 1 2)) module)
(assert-equal? (tn) '(1 2) (eval '(list a b) module))
(assert-false (tn) (symbol-bound? 'a))

(tn "module internal definitions")
(eval '(define (f x) (define y 2) (let ((z 3)) (+ x y z count))) module)
(assert-equal? (tn) 8 (eval '(f 1) module))

(tn "module syntax")
(eval '(define-syntax inc!
         (syntax-rules ()
           ((_ v) (begin (set! v (+ v 1)) v))))
      module)
(assert-equal? (tn) 6 (eval '(let ((z 5)) (inc! z)) module))
(assert-equal? (tn) 3 (eval '(inc! count) module))
(assert-false (tn) (symbol-bound? 'inc!))

(tn "module many definitions")
(let loop ((i 0))
  (if (< i 200)
      (begin
        (eval (list 'define
                    (string->symbol (string-append "x" (number->string i)))
                    i)
              module)
        (loop (+ i 1)))))
(assert-equal? (tn) 0 (eval 'x0 module))
(assert-equal? (tn) 150 (eval 'x150 module))
(assert-equal? (tn) 199 (eval 'x199 module))

(tn "module toplevel definitions")
(assert-error (tn) (lambda () (eval '(if #t (define zz 1)) module)))
(assert-error (tn) (lambda () (eval 'no-such-variable module)))

(tn "builtins redefined in the global environment")
(define orig-car car)
(define orig-cdr cdr)
(define (car x) 'global-car)
(assert-equal? (tn) 'global-car (car '(1)))
(assert-equal? (tn) 1 (eval '(car '(1)) module))
(set! cdr (lambda (x) 'global-cdr))
(assert-equal? (tn) 'global-cdr (cdr '(1 2)))
(assert-equal? (tn) '(2) (eval '(cdr '(1 2)) module))
(define car orig-car)
(set! cdr orig-cdr)
(assert-equal? (tn) 1 (car '(1)))
(assert-equal? (tn) '(2) (cdr '(1 2)))

(tn "builtins written in Scheme use builtins")
(define orig-open-input-file open-input-file)
(define (open-input-file path) (error "global open-input-file is used"))
(assert-equal? (tn)
               #\;
               (call-with-input-file (string-append (%%system-load-path)
                                                    "/srfi-9.scm")
                 read-char))
(define open-input-file orig-open-input-file)

(tn "builtin macros")
;; Template identifiers of a builtin macro are resolved in the builtin
;; namespace even if the global environment redefines them.
(define orig-make-record-type %%make-record-type)
(define %%make-record-type 'global)
(define-record-type point (make-point x y) point?
  (x point-x)
  (y point-y))
(assert-true (tn) (point? (make-point 1 2)))
(assert-equal? (tn) 2 (point-y (make-point 1 2)))
(define %%make-record-type orig-make-record-type)
(eval '(define-record-type module-point (make-module-point x) module-point?
         (x module-point-x))
      module)
(assert-equal? (tn) 5 (eval '(module-point-x (make-module-point 5)) module))
(assert-false (tn) (symbol-bound? 'make-module-point))

(tn "module macros")
(eval '(define secret 42) module)
(eval '(define-syntax get-secret (syntax-rules () ((_) secret))) module)
(assert-equal? (tn) 42 (eval '(get-secret) module))
(assert-equal? (tn) 42 (eval '(let ((secret 0)) (get-secret)) module))

(tn "global variables")
(define global-counter 0)
(set! global-counter (+ global-counter 1))
(assert-equal? (tn) 1 global-counter)
(assert-error (tn) (lambda () (eval '(set! no-such-global 1)
                                    (interaction-environment))))

(tn "define-library")
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
(assert-false (tn) (symbol-bound? 'make-counter))
(import (test counter))
(assert-equal? (tn) 1 (make-counter))
(assert-equal? (tn) 2 (make-counter))
;; The REPL shares the location with the library.
(assert-equal? (tn) 2 value)
(assert-false (tn) (symbol-bound? 'counter-value))
(assert-equal? (tn) '(counter 2) (counter-list))

(tn "define-library macros")
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
(assert-equal? (tn) '(swapped 2 1) (use-swap))
(import (test swap))
(define swapped 'global)
(define x 1)
(define y 2)
(assert-equal? (tn) 'swapped (swap! x y))
(assert-equal? (tn) '(2 1) (list x y))

(tn "import sets")
(define-library (test abc)
  (export a b c)
  (begin
    (define a 'a)
    (define b 'b)
    (define c 'c)))
(import (only (test abc) a))
(assert-equal? (tn) 'a a)
(assert-false (tn) (symbol-bound? 'b))
(import (except (test abc) a b))
(assert-equal? (tn) 'c c)
(assert-false (tn) (symbol-bound? 'b))
(import (prefix (only (test abc) b) abc:))
(assert-equal? (tn) 'b abc:b)
(import (rename (test abc) (b bb) (c cc)))
(assert-equal? (tn) '(a b c) (list a bb cc))
(assert-error (tn) (lambda () (eval '(import (only (test abc) d))
                                    (interaction-environment))))
(assert-error (tn) (lambda () (eval '(import (except (test abc) d))
                                    (interaction-environment))))
(assert-error (tn) (lambda () (eval '(import (rename (test abc) (d e)))
                                    (interaction-environment))))
(assert-error (tn) (lambda () (eval '(import (test unknown))
                                    (interaction-environment))))

(tn "import builtins")
(define-library (test my-car)
  (export car)
  (import (only (test builtin) list))
  (begin
    (define (car x) (list 'my x))))
(import (test my-car))
(assert-equal? (tn) '(my (1)) (car '(1)))
;; Builtins such as import use the builtin car.
(import (only (test abc) a))
(assert-equal? (tn) 'a a)
(import (test builtin))
(assert-equal? (tn) 1 (car '(1)))

(tn "imported bindings")
(assert-error (tn) (lambda ()
                     (define-library (test redefine)
                       (import (test builtin))
                       (begin (define car 1)))))
(assert-error (tn) (lambda ()
                     (define-library (test set)
                       (import (test abc))
                       (begin (set! a 1)))))
(assert-error (tn) (lambda ()
                     (define-library (test set-builtin)
                       (import (test builtin))
                       (begin (set! car 1)))))
(assert-error (tn) (lambda ()
                     (define-library (test unimported)
                       (begin (set! cons 1)))))
(assert-equal? (tn) '(1 . 2) (cons 1 2))
(assert-error (tn) (lambda ()
                     (define-library (test conflict)
                       (import (test builtin) (test my-car)))))
;; The same binding can be imported twice.
(define-library (test same)
  (export same-car)
  (import (test builtin) (only (test builtin) car))
  (begin (define same-car car)))
(import (test same))
(assert-equal? (tn) 1 (same-car '(1)))
(assert-error (tn) (lambda ()
                     (define-library (test unexported)
                       (export undefined))))
;; The REPL can redefine and mutate imported bindings without changing the
;; library.
(define value 10)
(assert-equal? (tn) 3 (make-counter))
(assert-equal? (tn) 10 value)
(import (test counter))
(assert-equal? (tn) 3 value)
(set! value 20)
(assert-equal? (tn) '(counter 3) (counter-list))

(tn "library files")
;; (test library greeting) is defined in test/library/greeting.sld.
(import (test library greeting))
(assert-equal? (tn) '(hello world) (greet 'world))
(assert-equal? (tn) 'r7rs greeting-feature)
;; include-ci folds symbols.
(assert-equal? (tn) 'hello loud)
(assert-error (tn) (lambda () (eval '(import (test library broken))
                                    (interaction-environment))))
(assert-error (tn) (lambda () (eval '(import (test library circular))
                                    (interaction-environment))))
(assert-error (tn) (lambda () (eval '(import (test library nonexistent))
                                    (interaction-environment))))

(tn "define-library cond-expand")
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
(assert-equal? (tn) 'greeting feature)
(assert-error (tn) (lambda ()
                     (define-library (test include)
                       (include "test/library/nonexistent.scm"))))

(tn "standard libraries")
(define-library (test standard)
  (export double)
  (import (scheme base) (prefix (scheme cxr) cxr:))
  (begin
    (define (double lst)
      (vector-map (lambda (x) (* x 2)) (list->vector (cxr:cdddr lst))))))
(import (test standard))
(assert-equal? (tn) #(8 10) (double '(1 2 3 4 5)))
;; All symbols in scheme-libraries.scm are exported except unbound ones.
(define standard-libraries
  (call-with-input-file "lib/scheme-libraries.scm"
    (lambda (port)
      (let loop ((libraries '()))
        (let ((library (read port)))
          (if (eof-object? library)
              libraries
              (loop (cons library libraries))))))))
(define (unexported-symbols library)
  (let ((exports (%%library-exports (car library))))
    (let loop ((syms (cdr library))
               (unexported '()))
      (cond
       ((null? syms) (reverse unexported))
       ((assq (car syms) exports) (loop (cdr syms) unexported))
       (else (loop (cdr syms) (cons (car syms) unexported)))))))
(assert-equal? (tn)
               '((scheme base) ... => _ else include include-ci)
               (assoc '(scheme base) (map (lambda (library)
                                            (cons (car library)
                                                  (unexported-symbols library)))
                                          standard-libraries)))
(for-each (lambda (library)
            (if (not (equal? (car library) '(scheme base)))
                (assert-equal? (tn) (list (car library))
                               (cons (car library)
                                     (unexported-symbols library)))))
          standard-libraries)

(tn "environment")
(define env (environment '(scheme base) '(only (scheme write) write)))
(assert-equal? (tn) 3 (eval '(+ 1 2) env))
(assert-equal? (tn) 'ok (eval '(let ((x 'ok)) x) env))
(assert-true (tn) (eq? env (environment '(scheme base)
                                         '(only (scheme write) write))))
(assert-error (tn) (lambda () (eval '(define x 1) env)))
(assert-error (tn) (lambda () (eval '(set! car 1) env)))

(tn "cond-expand library")
(assert-equal? (tn) 'base (cond-expand
                           ((library (scheme base)) 'base)
                           (else 'else)))
(assert-equal? (tn) 'else (cond-expand
                           ((library (scheme nonexistent)) 'nonexistent)
                           (else 'else)))

(total-report)
