;;  Filename : test-legacy-macro.scm
;;  About    : unit tests for legacy define-macro
;;
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

;; SigScheme does not have gensym.

(require-extension (unittest))


(test-begin "define-macro invalid forms")
;; invalid identifier
(test-error (define-macro #\m (lambda () #t)))
(test-error (define-macro "m" (lambda () #f)))
;; invalid closure
(test-error (define-macro m '(lambda () #t)))
(test-error (define-macro m #f))
(test-error m)  ;; must be unbound here
;; syntactic keyword
(test-error (define-macro m and))
;; another macro as alias
(define-macro m (lambda () #t))
(test-error (define-macro m2 m))
(test-end)

(test-begin "define-macro non-toplevel env")
(cond-expand
 (sigscheme
  ;; SigScheme does not accept non-toplevel env for syntactic closures.
  (test-error (define-macro m
                (let ((?var 'val))
                  (lambda ()
                    ``,?var)))))
 (else
  (define-macro m
    (let ((?var 'val))
      (lambda ()
        ``,?var)))
  (test-eq 'val (m))))
(test-end)

(test-begin "define-macro bad definition placement")
;; non-toplevel definition
(test-error (if #t (define-macro m
                     (lambda ()
                       '(define foo 3)))))
;; non-toplevel definition by a form returned by syntactic closure
(define-macro m
  (lambda ()
    '(define foo 3)))
(test-error (if #t (m)))
(test-end)

(test-begin "define-macro referring runtime env")
(define cnt 0)
(define-macro m
  (lambda ()
    (set! cnt (+ cnt 1))
    cnt))
;; The macro is expanded for each instantiation.
(test-eqv 1 (m))
(test-eqv 2 (m))
(test-eqv 3 (m))
(define proc-m
  (lambda ()
    (m)))
(cond-expand
 (sigscheme
  ;; SigScheme expands the macro for each procedure call.
  (test-eqv 4 (proc-m))
  (test-eqv 5 (proc-m))
  (test-eqv 6 (proc-m)))
 (else
  ;; Ordinary implementations expand the macro only once.
  (test-eqv 4 (proc-m))
  (test-eqv 4 (proc-m))
  (test-eqv 4 (proc-m))))
(test-end)

(test-begin "define-macro varname conflict")
(define foo 1)
(define bar 2)
(define tmp 3)
(define-macro swap
  (lambda (x y)
    `(let ((tmp ,x))
       (set! ,x ,y)
       (set! ,y tmp))))
(swap foo bar)
(test-eqv 2 foo)
(test-eqv 1 bar)
(test-eqv 3 tmp)
(swap foo bar)
(test-eqv 1 foo)
(test-eqv 2 bar)
(test-eqv 3 tmp)
(swap foo tmp)
(test-eqv 1 foo)
(test-eqv 2 bar)
(test-eqv 3 tmp)
(swap foo tmp)
(test-eqv 1 foo)
(test-eqv 2 bar)
(test-eqv 3 tmp)
(test-end)

(test-begin "define-macro evaluation timings")
(define foo 3)
(define bar 4)
(define-macro m
  (lambda ()
    '(+ foo bar)))
(define-macro m2
  (lambda ()
    (+ foo bar)))
(define proc-m
  (lambda ()
    (m)))
(define proc-m2
  (lambda ()
    (m2)))
(test-eqv 7 (m))
(test-eqv 7 (m2))
(test-eqv 7 (proc-m))
(test-eqv 7 (proc-m2))
(set! foo 5)
(test-eqv 9 (m))
(test-eqv 9 (m2))
(test-eqv 9 (proc-m))
(cond-expand
 (sigscheme
  (test-eqv 9 (proc-m2)))
 (else
  (test-eqv 7 (proc-m2))))
(test-end)

(test-begin "define-macro syntactic keywords handling")
(define-macro m
  (lambda (op x y)
    `(,op ,x ,y)))
(test-false (m and #f #f))
(test-false (m and #f #t))
(test-false (m and #t #f))
(test-true  (m and #t #t))
(test-false (m or  #f #f))
(test-true  (m or  #f #t))
(test-true  (m or  #t #f))
(test-true  (m or  #t #t))
(define-macro m
  (lambda args
    `,args))
(test-false (m and #f #f))
(test-false (m and #f #t))
(test-false (m and #t #f))
(test-true  (m and #t #t))
(test-true  (m and #t #t #t))
(test-false (m or  #f #f))
(test-true  (m or  #f #t))
(test-true  (m or  #t #f))
(test-true  (m or  #t #t))
(test-true  (m or  #t #t #f))
(define-macro (m op x y)
    `(,op ,x ,y))
(test-false (m and #f #f))
(test-false (m and #f #t))
(test-false (m and #t #f))
(test-true  (m and #t #t))
(test-false (m or  #f #f))
(test-true  (m or  #f #t))
(test-true  (m or  #t #f))
(test-true  (m or  #t #t))
(define-macro (m . args)
  `,args)
(test-false (m and #f #f))
(test-false (m and #f #t))
(test-false (m and #t #f))
(test-true  (m and #t #t))
(test-true  (m and #t #t #t))
(test-false (m or  #f #f))
(test-true  (m or  #f #t))
(test-true  (m or  #t #f))
(test-true  (m or  #t #t))
(test-true  (m or  #t #t #f))
(test-end)

(test-begin "define-macro nested macro")
(define-macro swap
  (lambda (x y)
    `(let ((?tmp ,x))
       (set! ,x ,y)
       (set! ,y ?tmp))))
(define-macro m
  (lambda (x y)
    `(begin
       (swap ,x ,y)
       (- ,x ,y))))
(define foo 3)
(define bar 4)
(test-eqv -1 (- foo bar))
(test-eqv 1  (m foo bar))
(test-eqv 4 foo)
(test-eqv 3 bar)
(test-end)

(test-report-result)
