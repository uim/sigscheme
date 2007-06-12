;;  Filename : test-srfi2.scm
;;  About    : unit test for the SRFI-2 'and-let*'
;;
;;  Copyright (C) 2005-2006 Kazuki Ohta <mover AT hct.zaq.ne.jp>
;;  Copyright (c) 2007 SigScheme Project <uim AT freedesktop.org>
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

(load "./test/unittest.scm")

(use srfi-2)

(if (not (provided? "srfi-2"))
    (test-skip "SRFI-2 is not enabled"))

(define tn test-name)

;; (and-let* <claws> <body>)
;; 
;; <claws> ::= '() | (cons <claw> <claws>)
;; <claw>  ::=  (<variable> <expression>) | (<expression>)
;;              | <bound-variable>

(define true #t)
(define false #f)

(tn "and-let* invalid forms")
(assert-error (tn) (lambda () (and-let* ((#t) . #t) #t)))
(assert-error (tn) (lambda () (and-let* ((foo #t) . #t) #t)))

(tn "and-let* misc normal forms")
(assert-true  (tn) (and-let* () #t))
(assert-true  (tn) (and-let* () #t #t))
(assert-true  (tn) (and-let* () #t #t #t))
(assert-false (tn) (and-let* () #f))
(assert-false (tn) (and-let* () #t #f))
(assert-false (tn) (and-let* () #t #t #f))

(tn "and-let* (<variable> <expression>) style claw")
(assert-false (tn) (and-let* ((false (< 2 1)))
                     #t))
(assert-false (tn) (and-let* ((true  (< 1 2))
                              (false (< 2 1)))
                     #t))
(assert-true  (tn) (and-let* ((one 1)
                              (two (+ one 1))
                              (three (+ two 1)))
                     (= three 3)))
(assert-false (tn) (and-let* ((one 1)
                              (two (+ one 1))
                              (three (+ two 1)))
                     (= three 4)))

(tn "and-let* <bound-variable> style claw")
(assert-true  (tn) (and-let* (true)
                     'ok))
(assert-true  (tn) (and-let* (even?)
                     'ok))
(assert-false (tn) (and-let* (false)
                     'ok))
(assert-true  (tn) (and-let* (even?
                              true)
                     'ok))
(assert-false (tn) (and-let* (even?
                              true
                              false)
                     'ok))

(tn "and-let* (<expression>) style claw")
(assert-true  (tn) (and-let* ((#t))
                     'ok))
(assert-false (tn) (and-let* ((#f))
                     'ok))
(assert-true  (tn) (and-let* (((integer? 1)))
                     'ok))
(assert-false (tn) (and-let* (((integer? #t)))
                     'ok))
(assert-true  (tn) (and-let* (((integer? 1))
                              ((integer? 2)))
                     'ok))
(assert-false (tn) (and-let* (((integer? 1))
                              ((integer? 2))
                              ((integer? #t)))
                     'ok))

(tn "and-let* procedure itself as value")
(assert-true (tn) (and-let* ((even?))
                    'ok))

(tn "and-let* combined forms")
(assert-true  (tn) (and-let* (true
                              even?
                              ((integer? 1)))
                     'ok))
(assert-true  (tn) (and-let* (true
                              even?
                              ((integer? 1))
                              (foo '(1 2 3))
                              ((list? foo))
                              (bar foo))
                     'ok))
(assert-false (tn) (and-let* (true
                              even?
                              ((integer? 1))
                              (foo '#(1 2 3))
                              ((list? foo))
                              (bar foo))
                     'ok))
(assert-false (tn) (and-let* (true
                              even?
                              ((integer? 1))
                              (foo '(1 2 3))
                              (bar (car foo))
                              bar
                              ((null? bar)))
                     'ok))

(total-report)
