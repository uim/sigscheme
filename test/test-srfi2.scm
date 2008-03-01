;;  Filename : test-srfi2.scm
;;  About    : unit test for the SRFI-2 'and-let*'
;;
;;  Copyright (C) 2005-2006 Kazuki Ohta <mover AT hct.zaq.ne.jp>
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

;; See also oleg-srfi2.scm

(require-extension (unittest))

(require-extension (srfi 2))

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
(assert-error  (tn) (lambda () (and-let*)))
(assert-error  (tn) (lambda () (and-let* #t #t)))
(assert-error  (tn) (lambda () (and-let* ((#t) . #t) #t)))
(assert-error  (tn) (lambda () (and-let* ((foo #t) . #t) #t)))
(assert-error  (tn) (lambda () (and-let* ((foo . #t)) #t)))
(assert-error  (tn) (lambda () (and-let* ((foo #t . #t)) #t)))
(assert-error  (tn) (lambda () (and-let* (1) #t)))

(tn "and-let* misc normal forms")
(assert-eq?    (tn) #t  (and-let* ()))
(assert-eq?    (tn) 'ok (and-let* ((foo 'ok)) foo))
(assert-eq?    (tn) #t  (and-let* () #t))
(assert-eq?    (tn) #t  (and-let* () #t #t))
(assert-eq?    (tn) #t  (and-let* () #t #t #t))
(assert-false  (tn)     (and-let* () #f))
(assert-false  (tn)     (and-let* () #t #f))
(assert-false  (tn)     (and-let* () #t #t #f))
(assert-eq?    (tn) #t  (and-let* () #t #f #t))

(tn "and-let* (<variable> <expression>) style claw")
(assert-false  (tn) (and-let* ((false (< 2 1)))
                      #t))
(assert-false  (tn) (and-let* ((true  (< 1 2))
                               (false (< 2 1)))
                      #t))
(assert-true   (tn) (and-let* ((one 1)
                               (two (+ one 1))
                               (three (+ two 1)))
                      (= three 3)))
(assert-false  (tn) (and-let* ((one 1)
                               (two (+ one 1))
                               (three (+ two 1)))
                      (= three 4)))
(assert-equal? (tn)
               6
               (and-let* ((one 1)
                          (two (+ one 1))
                          (three (+ two 1)))
                 (+ one two three)))

(tn "and-let* <bound-variable> style claw")
(assert-eq?    (tn) 'ok   (and-let* (true)
                            'ok))
(assert-eq?    (tn) #t    (and-let* (true)))
(assert-eq?    (tn) 'ok   (and-let* (even?)
                            'ok))
(assert-equal? (tn) even? (and-let* (even?)))
(assert-false  (tn)       (and-let* (false)
                            'ok))
(assert-false  (tn)       (and-let* (false)))
(assert-eq?    (tn) 'ok   (and-let* (even?
                                     true)
                            'ok))
(assert-eq?    (tn) #t    (and-let* (even?
                                     true)))
(assert-false  (tn)       (and-let* (even?
                                     true
                                     false)
                            'ok))
(assert-false  (tn)       (and-let* (even?
                                     true
                                     false)))

(tn "and-let* (<expression>) style claw")
(assert-eq?    (tn) 'ok   (and-let* (('ok))))
(assert-eq?    (tn) 'okok (and-let* (('ok)) 'okok))
(assert-equal? (tn) 1     (and-let* ((1))))
(assert-equal? (tn) 'ok   (and-let* ((1)) 'ok))
(assert-equal? (tn) "ok"  (and-let* (("ok"))))
(assert-equal? (tn) 'ok   (and-let* (("ok")) 'ok))
(assert-eq?    (tn) 'ok   (and-let* ((#t))
                            'ok))
(assert-false  (tn)       (and-let* ((#f))
                            'ok))
(assert-eq?    (tn) 'ok   (and-let* (((integer? 1)))
                            'ok))
(assert-false  (tn)       (and-let* (((integer? #t)))
                            'ok))
(assert-eq?    (tn) 'ok   (and-let* (((integer? 1))
                                     ((integer? 2)))
                            'ok))
(assert-false  (tn)       (and-let* (((integer? 1))
                                     ((integer? 2))
                                     ((integer? #t)))
                            'ok))

(tn "and-let* combined forms")
(assert-eq?    (tn) 'ok   (and-let* (true
                                     even?
                                     ((integer? 1)))
                            'ok))
(assert-eq?    (tn) 'ok   (and-let* (true
                                     even?
                                     ((integer? 1))
                                     (foo '(1 2 3))
                                     ((list? foo))
                                     (bar foo))
                            'ok))
(assert-false  (tn)       (and-let* (true
                                     even?
                                     ((integer? 1))
                                     (foo '#(1 2 3))
                                     ((list? foo))
                                     (bar foo))
                            'ok))
(assert-false  (tn)       (and-let* (true
                                     even?
                                     ((integer? 1))
                                     (foo '(1 2 3))
                                     (bar (car foo))
                                     bar
                                     ((null? bar)))
                            'ok))

(tn "and-let* internal definitions")
(define foo 1)
(assert-equal? (tn)
               3
               (and-let* ()
                 (define foo 3)
                 foo))
(assert-equal? (tn) 1 foo)

(define foo 1)
(define bar 2)
(assert-equal? (tn)
               5
               (and-let* ((foo 3)
                          (bar 4))
                 (define foo 5)
                 foo))
(assert-equal? (tn) 1 foo)
(assert-equal? (tn) 2 bar)

(define foo 1)
(assert-equal? (tn)
               3
               (and-let* ((foo 2))
                 (set! foo 3)
                 foo))
(assert-equal? (tn) 1 foo)

(define foo 1)
(assert-equal? (tn)
               3
               (and-let* ()
                 (set! foo 3)
                 foo))
(assert-equal? (tn) 3 foo)

(total-report)
