;;  Filename : test-srfi2.scm
;;  About    : unit test for the SRFI-2 'and-let*'
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

;; See also oleg-srfi2.scm

(require-extension (srfi 64))

(require-extension (srfi 2))

(test-begin "test-srfi2")

;; (and-let* <claws> <body>)
;; 
;; <claws> ::= '() | (cons <claw> <claws>)
;; <claw>  ::=  (<variable> <expression>) | (<expression>)
;;              | <bound-variable>

(define true #t)
(define false #f)

(test-begin "and-let* invalid forms")
(test-error (and-let*))
(test-error (and-let* #t #t))
(test-error (and-let* ((#t) . #t) #t))
(test-error (and-let* ((foo #t) . #t) #t))
(test-error (and-let* ((foo . #t)) #t))
(test-error (and-let* ((foo #t . #t)) #t))
(test-error (and-let* (1) #t))
(test-end "and-let* invalid forms")

(test-begin "and-let* misc normal forms")
(test-eq #t  (and-let* ()))
(test-eq 'ok (and-let* ((foo 'ok)) foo))
(test-eq #t  (and-let* () #t))
(test-eq #t  (and-let* () #t #t))
(test-eq #t  (and-let* () #t #t #t))
(test-assert (not (and-let* () #f)))
(test-assert (not (and-let* () #t #f)))
(test-assert (not (and-let* () #t #t #f)))
(test-eq #t  (and-let* () #t #f #t))
(test-end "and-let* misc normal forms")

(test-begin "and-let* (<variable> <expression>) style claw")
(test-assert (not (and-let* ((false (< 2 1)))
                    #t)))
(test-assert (not (and-let* ((true  (< 1 2))
                             (false (< 2 1)))
                    #t)))
(test-assert (and-let* ((one 1)
                        (two (+ one 1))
                        (three (+ two 1)))
               (= three 3)))
(test-assert (not (and-let* ((one 1)
                             (two (+ one 1))
                             (three (+ two 1)))
                    (= three 4))))
(test-equal 6
            (and-let* ((one 1)
                       (two (+ one 1))
                       (three (+ two 1)))
              (+ one two three)))
(test-end "and-let* (<variable> <expression>) style claw")

(test-begin "and-let* <bound-variable> style claw")
(test-eq 'ok   (and-let* (true)
                 'ok))
(test-eq #t    (and-let* (true)))
(test-eq 'ok   (and-let* (even?)
                 'ok))
(test-equal even? (and-let* (even?)))
(test-assert (not (and-let* (false)
                    'ok)))
(test-assert (not (and-let* (false))))
(test-eq 'ok   (and-let* (even?
                          true)
                 'ok))
(test-eq #t    (and-let* (even?
                          true)))
(test-assert (not (and-let* (even?
                             true
                             false)
                    'ok)))
(test-assert (not (and-let* (even?
                             true
                             false))))
(test-end "and-let* <bound-variable> style claw")

(test-begin "and-let* (<expression>) style claw")
(test-eq 'ok   (and-let* (('ok))))
(test-eq 'okok (and-let* (('ok)) 'okok))
(test-equal 1     (and-let* ((1))))
(test-equal 'ok   (and-let* ((1)) 'ok))
(test-equal "ok"  (and-let* (("ok"))))
(test-equal 'ok   (and-let* (("ok")) 'ok))
(test-eq 'ok   (and-let* ((#t))
                 'ok))
(test-assert (not (and-let* ((#f))
                    'ok)))
(test-eq 'ok   (and-let* (((integer? 1)))
                 'ok))
(test-assert (not (and-let* (((integer? #t)))
                    'ok)))
(test-eq 'ok   (and-let* (((integer? 1))
                          ((integer? 2)))
                 'ok))
(test-assert (not (and-let* (((integer? 1))
                             ((integer? 2))
                             ((integer? #t)))
                    'ok)))
(test-end "and-let* (<expression>) style claw")

(test-begin "and-let* combined forms")
(test-eq 'ok   (and-let* (true
                          even?
                          ((integer? 1)))
                 'ok))
(test-eq 'ok   (and-let* (true
                          even?
                          ((integer? 1))
                          (foo '(1 2 3))
                          ((list? foo))
                          (bar foo))
                 'ok))
(test-assert (not (and-let* (true
                             even?
                             ((integer? 1))
                             (foo '#(1 2 3))
                             ((list? foo))
                             (bar foo))
                    'ok)))
(test-assert (not (and-let* (true
                             even?
                             ((integer? 1))
                             (foo '(1 2 3))
                             (bar (car foo))
                             bar
                             ((null? bar)))
                    'ok)))
(test-end "and-let* combined forms")

(test-begin "and-let* internal definitions")
(if (not (provided? "internal-definitions"))
    (test-skip-rest))
(define foo 1)
(test-equal 3
            (and-let* ()
              (define foo 3)
              foo))
(test-equal 1 foo)

(define foo 1)
(define bar 2)
(test-equal 5
            (and-let* ((foo 3)
                       (bar 4))
              (define foo 5)
              foo))
(test-equal 1 foo)
(test-equal 2 bar)

(define foo 1)
(test-equal 3
            (and-let* ((foo 2))
              (set! foo 3)
              foo))
(test-equal 1 foo)

(define foo 1)
(test-equal 3
            (and-let* ()
              (set! foo 3)
              foo))
(test-equal 3 foo)
(test-end "and-let* internal definitions")

(test-end "test-srfi2")
