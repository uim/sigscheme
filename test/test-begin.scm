;;  Filename : test-begin.scm
;;  About    : unit test for R5RS begin
;;
;;  Copyright (C) 2006 YAMAMOTO Kengo <yamaken AT bp.iij4u.or.jp>
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

(test-begin "test-begin")

;; R5RS: 7.1.6 Programs and definitions
;; 
;; <program> --> <command or definition>*
;; <command or definition> --> <command>
;;     | <definition>
;;     | <syntax definition>
;;     | (begin <command or definition>+)
;; <definition> --> (define <variable> <expression>)
;;       | (define (<variable> <def formals>) <body>)
;;       | (begin <definition>*)
;; <def formals> --> <variable>*
;;       | <variable>* . <variable>
;; <syntax definition> -->
;;      (define-syntax <keyword> <transformer spec>)

(test-begin "top-level begin invalid forms")
;; 'if', 'and', 'or', 'cond', 'case' do not make environment so these
;; '(begin)'s are not internal definitions and invalid.
;; See also test-do.scm for more invalid definitions.
;; See also test-define.scm for top-level definitions.
(if (provided? "strict-toplevel-definitions")
    (begin
      (test-error (eval '(if #t (begin))
                        (interaction-environment)))
      (test-error (eval '(if #f #t (begin))
                        (interaction-environment)))
      (test-error (eval '(and (begin))
                        (interaction-environment)))
      (test-error (eval '(or (begin))
                        (interaction-environment)))
      (test-error (eval '(cond (#t (begin)))
                        (interaction-environment)))
      (test-error (eval '(cond (else (begin)))
                        (interaction-environment)))
      (test-error (eval '(case 'key (#t (begin)))
                        (interaction-environment)))
      (test-error (eval '(case 'key (else (begin)))
                        (interaction-environment)))))
(test-end "top-level begin invalid forms")

(test-begin "top-level begin invalid forms (strict)")
(if (provided? "strict-toplevel-definitions")
    (begin
      (test-error (eval '(if #t (begin (define var0 1)))
                        (interaction-environment)))
      (test-error (eval '(if #t (begin (define var0 1) #t))
                        (interaction-environment)))
      (test-error (eval '(if #f #t (begin (define var0 1)))
                        (interaction-environment)))
      (test-error (eval '(if #f #t (begin (define var0 1) #t))
                        (interaction-environment)))
      (test-error (eval '(and (begin (define var0 1)))
                        (interaction-environment)))
      (test-error (eval '(and (begin (define var0 1) #t))
                        (interaction-environment)))
      (test-error (eval '(or (begin (define var0 1)))
                        (interaction-environment)))
      (test-error (eval '(or (begin (define var0 1) #t))
                        (interaction-environment)))
      (test-error (eval '(cond (#t (begin (define var0 1))))
                        (interaction-environment)))
      (test-error (eval '(cond (#t (begin (define var0 1) #t)))
                        (interaction-environment)))
      (test-error (eval '(cond (else (begin (define var0 1))))
                        (interaction-environment)))
      (test-error (eval '(cond (else (begin (define var0 1) #t)))
                        (interaction-environment)))
      (test-error (eval '(case 'key ((key) (begin (define var0 1))))
                        (interaction-environment)))
      (test-error (eval '(case 'key ((key) (begin (define var0 1) #t)))
                        (interaction-environment)))
      (test-error (eval '(case 'key (else (begin (define var0 1))))
                        (interaction-environment)))
      (test-error (eval '(case 'key (else (begin (define var0 1) #t)))
                        (interaction-environment)))))
(test-end "top-level begin invalid forms (strict)")

(test-begin "top-level begin invalid forms (strict) 2")
;; top-level define cannot be placed under a non-begin structure even if
;; wrapped into top-level begin.
(if (provided? "strict-toplevel-definitions")
    (begin
      (test-error (eval '(begin (if #t (begin (define var0 1))))
                        (interaction-environment)))
      (test-error (eval '(begin (if #t (begin (define var0 1) #t)))
                        (interaction-environment)))
      (test-error (eval '(begin (if #f #t (begin (define var0 1))))
                        (interaction-environment)))
      (test-error (eval '(begin (if #f #t (begin (define var0 1) #t)))
                        (interaction-environment)))
      (test-error (eval '(begin (and (begin (define var0 1))))
                        (interaction-environment)))
      (test-error (eval '(begin (and (begin (define var0 1) #t)))
                        (interaction-environment)))
      (test-error (eval '(begin (or (begin (define var0 1))))
                        (interaction-environment)))
      (test-error (eval '(begin (or (begin (define var0 1) #t)))
                        (interaction-environment)))
      (test-error (eval '(begin (cond (#t (begin (define var0 1)))))
                        (interaction-environment)))
      (test-error (eval '(begin (cond (#t (begin (define var0 1) #t))))
                        (interaction-environment)))
      (test-error (eval '(begin (cond (else (begin (define var0 1)))))
                        (interaction-environment)))
      (test-error (eval '(begin (cond (else (begin (define var0 1) #t))))
                        (interaction-environment)))
      (test-error (eval '(begin (case 'key
                                  ((key) (begin (define var0 1)))))
                        (interaction-environment)))
      (test-error (eval '(begin (case 'key
                                  ((key) (begin (define var0 1) #t))))
                        (interaction-environment)))
      (test-error (eval '(begin (case 'key
                                  (else (begin (define var0 1)))))
                        (interaction-environment)))
      (test-error (eval '(begin (case 'key
                                  (else (begin (define var0 1) #t))))
                        (interaction-environment)))))
(test-end "top-level begin invalid forms (strict) 2")

(test-begin "top-level begin invalid forms (strict) 3")
(if (provided? "strict-toplevel-definitions")
    (begin
      ;; top-level define cannot be placed under a non-begin structure even if
      ;; wrapped into top-level begin.
      (test-error (eval '(begin (if #t (define var0 1)))
                        (interaction-environment)))
      (test-error (eval '(begin (if #f #t (define var0 1)))
                        (interaction-environment)))
      (test-error (eval '(begin (and (define var0 1)))
                        (interaction-environment)))
      (test-error (eval '(begin (or (define var0 1)))
                        (interaction-environment)))
      (test-error (eval '(begin (cond (#t (define var0 1))))
                        (interaction-environment)))
      (test-error (eval '(begin (cond (else (define var0 1))))
                        (interaction-environment)))
      (test-error (eval '(begin (case 'key ((key) (define var0 1))))
                        (interaction-environment)))
      (test-error (eval '(begin (case 'key (else (define var0 1))))
                        (interaction-environment)))
      ;; test being evaled at non-tail part of 'begin'
      (test-error (eval '(begin (if #t (define var0 1)) #t)
                        (interaction-environment)))
      (test-error (eval '(begin (if #f #t (define var0 1)) #t)
                        (interaction-environment)))
      (test-error (eval '(begin (and (define var0 1)) #t)
                        (interaction-environment)))
      (test-error (eval '(begin (or (define var0 1)) #t)
                        (interaction-environment)))
      (test-error (eval '(begin (cond (#t (define var0 1))) #t)
                        (interaction-environment)))
      (test-error (eval '(begin (cond (else (define var0 1))) #t)
                        (interaction-environment)))
      (test-error (eval '(begin (case 'key ((key) (define var0 1))) #t)
                        (interaction-environment)))
      (test-error (eval '(begin (case 'key (else (define var0 1))) #t)
                        (interaction-environment)))))
(test-end "top-level begin invalid forms (strict) 3")


(test-begin "top-level begin valid forms")
;; '(begin)' is allowd at toplevel
(if (provided? "sigscheme")
    (begin
      (test-equal (undef)
                  (eval '(begin)
                        (interaction-environment)))
      (test-equal (undef)
                  (eval '(begin (begin))
                        (interaction-environment)))))
;; 'begin' does not create an environment
(test-assert (not (symbol-bound? 'var1)))
(begin
  (define var1 1))
(test-equal 1 var1)
;; duplicate definition is allowed
(begin
  (define var1 3))
(test-equal 3 var1)
(begin
  (define var1 4)
  (define var1 5))
(test-equal 5 var1)
;; intermixing expression and definition on top-level is valid
(begin
  (+ 1 2)
  (define var2 1))
(test-equal 1 var2)
(begin
  (define var3 1)
  (+ 1 2))
(test-equal 1 var3)
(begin
  (define var4 1)
  (+ 1 2)
  (begin
    (define var5 1)))
(test-equal 1 var4)
(test-equal 1 var5)
(test-end "top-level begin valid forms")


(test-end "test-begin")
