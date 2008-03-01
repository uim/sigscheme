;;  Filename : test-srfi9.scm
;;  About    : unit tests for SRFI-9
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

(define orig-vector? vector?)
(define orig-eval    eval)

(require-extension (unittest) (srfi 9))


(test-begin "SRFI-9 overridden R5RS procedures")
(test-false (eq? vector? orig-vector?))
(cond-expand
 (sigscheme
  (test-true  (eq? eval orig-eval)))
 (else
  (test-false (eq? eval orig-eval))))
(test-eq    #t (vector? (vector)))
(test-eq    #f (vector? (list)))
;; Overridden 'eval' must be capable of (interaction-environment).
(test-read-eval-string "(define foo 3)")
;; Original reference implementation of SRFI-9 lacks environment argument
;; handling.
(test-error (eval '(+ 2 3)))
(test-eqv   5 (eval '(+ 2 3) (interaction-environment)))
;; 'vector? must be evaluated to the redefined vector?.
(test-eq    vector? (eval 'vector? (interaction-environment)))
(test-end)

(test-begin "SRFI-9 invalid forms")
;; invalid definition placement
(test-error (if #t (define-record-type my-rec (make-my-rec) my-rec?)))
(test-error (test-read-eval-string
             "(if #t (define-record-type my-rec (make-my-rec) my-rec?))"))
;; invalid record names
(test-error (define-record-type 'my-rec (make-my-rec) my-rec?))
(test-error (define-record-type "my-rec" (make-my-rec) my-rec?))
;; invalid predicate names
(test-error (define-record-type my-rec (make-my-rec) 'my-rec?))
(test-error (define-record-type my-rec (make-my-rec) "my-rec?"))
;; invalid constructor
(test-error (define-record-type my-rec make-my-rec my-rec?))
(test-error (define-record-type my-rec '(make-my-rec) my-rec?))
(test-error (define-record-type my-rec (list make-my-rec) my-rec?))
(test-error (define-record-type my-rec (list 'make-my-rec) my-rec?))
(test-error (define-record-type my-rec #(make-my-rec) my-rec?))
(test-error (define-record-type my-rec '#(make-my-rec) my-rec?))
;; non-existent field name in constructor
(test-error (define-record-type my-rec (make-my-rec x) my-rec?))
;; without accessor
(test-error (define-record-type my-rec (make-my-rec x) my-rec?
              (x)))
(test-end)

(test-begin "SRFI-9 no-field record")
(test-false (symbol-bound? 'make-my-null))
(test-false (symbol-bound? 'my-null?))
(test-eq    (undef)
            (define-record-type my-null (make-my-null) my-null?))
(test-true  (procedure? make-my-null))
(test-true  (procedure? my-null?))
(test-error (make-my-null 0))
(test-eq    #t (record? (make-my-null)))
(test-true  (not (vector? (make-my-null))))
(test-eq    #t (my-null? (make-my-null)))
(test-false (my-null? (vector)))
(test-end)

(test-begin "SRFI-9 2-field record")
(define x (list 'x))
(define y (list 'y))
(define z (list 'z))
(test-false (symbol-bound? 'make-my-pair))
(test-false (symbol-bound? 'my-pair?))
(test-false (symbol-bound? 'my-pair-kar))
(test-false (symbol-bound? 'my-pair-kdr))
(test-false (symbol-bound? 'my-pair-set-kar!))
(test-false (symbol-bound? 'my-pair-set-kdr!))
(test-eq    (undef)
            (define-record-type my-pair (make-my-pair kar kdr) my-pair?
              (kar my-pair-kar my-pair-set-kar!)
              (kdr my-pair-kdr my-pair-set-kdr!)))
(test-true  (procedure? make-my-pair))
(test-true  (procedure? my-pair?))
(test-true  (procedure? my-pair-kar))
(test-true  (procedure? my-pair-kdr))
(test-true  (procedure? my-pair-set-kar!))
(test-true  (procedure? my-pair-set-kdr!))
(test-error (make-my-pair))
(test-error (make-my-pair x))
(test-error (make-my-pair x y z))
(test-eq    #t (record? (make-my-pair x y)))
(test-true  (not (vector? (make-my-pair x y))))
(test-eq    #t (my-pair? (make-my-pair x y)))
(test-false (my-pair? (vector x y)))
(test-false (my-pair? (make-my-null)))
(test-eq    x (my-pair-kar (make-my-pair x y)))
(test-eq    y (my-pair-kdr (make-my-pair x y)))
(define foo (make-my-pair x y))
(test-eq    x (my-pair-kar foo))
(test-eq    y (my-pair-kdr foo))
(test-eq    (undef) (my-pair-set-kar! foo z))
(test-eq    z (my-pair-kar foo))
(test-eq    y (my-pair-kdr foo))
(test-eq    (undef) (my-pair-set-kdr! foo x))
(test-eq    z (my-pair-kar foo))
(test-eq    x (my-pair-kdr foo))
(test-end)

(test-begin "SRFI-9 2-field record with swapped constructor tags")
(define x (list 'x))
(define y (list 'y))
(define z (list 'z))
(test-false (symbol-bound? 'make-my-pair2))
(test-false (symbol-bound? 'my-pair2?))
(test-false (symbol-bound? 'my-pair2-kar))
(test-false (symbol-bound? 'my-pair2-kdr))
(test-false (symbol-bound? 'my-pair2-set-kar!))
(test-false (symbol-bound? 'my-pair2-set-kdr!))
(test-eq    (undef)
            (define-record-type my-pair2 (make-my-pair2 kdr kar) my-pair2?
              (kar my-pair2-kar my-pair2-set-kar!)
              (kdr my-pair2-kdr my-pair2-set-kdr!)))
(test-true  (procedure? make-my-pair2))
(test-true  (procedure? my-pair2?))
(test-true  (procedure? my-pair2-kar))
(test-true  (procedure? my-pair2-kdr))
(test-true  (procedure? my-pair2-set-kar!))
(test-true  (procedure? my-pair2-set-kdr!))
(test-error (make-my-pair2))
(test-error (make-my-pair2 x))
(test-error (make-my-pair2 x y z))
(test-eq    #t (record? (make-my-pair2 x y)))
(test-true  (not (vector? (make-my-pair2 x y))))
(test-eq    #t (my-pair2? (make-my-pair2 x y)))
(test-false (my-pair2? (vector x y)))
(test-eq    y (my-pair2-kar (make-my-pair2 x y)))
(test-eq    x (my-pair2-kdr (make-my-pair2 x y)))
(define foo (make-my-pair2 x y))
(test-eq    y (my-pair2-kar foo))
(test-eq    x (my-pair2-kdr foo))
(test-eq    (undef) (my-pair2-set-kar! foo z))
(test-eq    z (my-pair2-kar foo))
(test-eq    x (my-pair2-kdr foo))
(test-eq    (undef) (my-pair2-set-kdr! foo y))
(test-eq    z (my-pair2-kar foo))
(test-eq    y (my-pair2-kdr foo))
(test-end)

(test-begin "SRFI-9 2-field record with partial constructor tags")
(define x (list 'x))
(define y (list 'y))
(define z (list 'z))
(test-false (symbol-bound? 'make-my-pair3))
(test-false (symbol-bound? 'my-pair3?))
(test-false (symbol-bound? 'my-pair3-kar))
(test-false (symbol-bound? 'my-pair3-kdr))
(test-false (symbol-bound? 'my-pair3-set-kar!))
(test-false (symbol-bound? 'my-pair3-set-kdr!))
(test-eq    (undef)
            (define-record-type my-pair3 (make-my-pair3 kdr) my-pair3?
              (kar my-pair3-kar my-pair3-set-kar!)
              (kdr my-pair3-kdr my-pair3-set-kdr!)))
(test-true  (procedure? make-my-pair3))
(test-true  (procedure? my-pair3?))
(test-true  (procedure? my-pair3-kar))
(test-true  (procedure? my-pair3-kdr))
(test-true  (procedure? my-pair3-set-kar!))
(test-true  (procedure? my-pair3-set-kdr!))
(test-error (make-my-pair3))
(test-error (make-my-pair3 x y))
(test-error (make-my-pair3 x y z))
(test-eq    #t (record? (make-my-pair3 x)))
(test-true  (not (vector? (make-my-pair3 x))))
(test-eq    #t (my-pair3? (make-my-pair3 x)))
(test-false (my-pair3? (vector x y)))
(test-false (my-pair3? (make-my-null)))
(test-eq    (undef) (my-pair3-kar (make-my-pair3 x)))
(test-eq    x       (my-pair3-kdr (make-my-pair3 x)))
(define foo (make-my-pair3 x))
(test-eq    (undef) (my-pair3-kar foo))
(test-eq    x       (my-pair3-kdr foo))
(test-eq    (undef) (my-pair3-set-kar! foo z))
(test-eq    z (my-pair3-kar foo))
(test-eq    x (my-pair3-kdr foo))
(test-eq    (undef) (my-pair3-set-kdr! foo y))
(test-eq    z (my-pair3-kar foo))
(test-eq    y (my-pair3-kdr foo))
(test-end)

(test-begin "SRFI-9 2-field record without constructor tags")
(define x (list 'x))
(define y (list 'y))
(define z (list 'z))
(test-false (symbol-bound? 'make-my-pair4))
(test-false (symbol-bound? 'my-pair4?))
(test-false (symbol-bound? 'my-pair4-kar))
(test-false (symbol-bound? 'my-pair4-kdr))
(test-false (symbol-bound? 'my-pair4-set-kar!))
(test-false (symbol-bound? 'my-pair4-set-kdr!))
(test-eq    (undef)
            (define-record-type my-pair4 (make-my-pair4) my-pair4?
              (kar my-pair4-kar my-pair4-set-kar!)
              (kdr my-pair4-kdr my-pair4-set-kdr!)))
(test-true  (procedure? make-my-pair4))
(test-true  (procedure? my-pair4?))
(test-true  (procedure? my-pair4-kar))
(test-true  (procedure? my-pair4-kdr))
(test-true  (procedure? my-pair4-set-kar!))
(test-true  (procedure? my-pair4-set-kdr!))
(test-error (make-my-pair4 x))
(test-error (make-my-pair4 x y))
(test-error (make-my-pair4 x y z))
(test-eq    #t (record? (make-my-pair4)))
(test-true  (not (vector? (make-my-pair4))))
(test-eq    #t (my-pair4? (make-my-pair4)))
(test-false (my-pair4? (vector x y)))
(test-eq    (undef) (my-pair4-kar (make-my-pair4)))
(test-eq    (undef) (my-pair4-kdr (make-my-pair4)))
(define foo (make-my-pair4))
(test-eq    (undef) (my-pair4-kar foo))
(test-eq    (undef) (my-pair4-kdr foo))
(test-eq    (undef) (my-pair4-set-kar! foo z))
(test-eq    z       (my-pair4-kar foo))
(test-eq    (undef) (my-pair4-kdr foo))
(test-eq    (undef) (my-pair4-set-kdr! foo x))
(test-eq    z       (my-pair4-kar foo))
(test-eq    x       (my-pair4-kdr foo))
(test-end)

(test-begin "SRFI-9 2-field record without modifiers")
(test-false (symbol-bound? 'make-my-pair5))
(test-false (symbol-bound? 'my-pair5?))
(test-false (symbol-bound? 'my-pair5-kar))
(test-false (symbol-bound? 'my-pair5-kdr))
(test-eq    (undef)
            (define-record-type my-pair5 (make-my-pair5 kar kdr) my-pair5?
              (kar my-pair5-kar)
              (kdr my-pair5-kdr)))
(test-true  (procedure? make-my-pair5))
(test-true  (procedure? my-pair5?))
(test-true  (procedure? my-pair5-kar))
(test-true  (procedure? my-pair5-kdr))
(test-end)

(test-report-result)
