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

;; %%make-module is an internal procedure until define-library is
;; implemented.
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

(total-report)
