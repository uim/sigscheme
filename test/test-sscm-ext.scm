#! /usr/bin/env sscm -C UTF-8

;;  Filename : test-sscm-ext.scm
;;  About    : unit tests for SigScheme specific extensions
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

(require-extension (sscm-ext))

(require-extension (unittest))

(if (not (symbol-bound? 'let-optionals*))
    (test-skip "SigScheme extensions are not enabled"))

(define tn test-name)
(define ud (undef))

(tn "sscm-version")
(assert-equal? (tn) "0.9.0"      (sscm-version))

(tn "%%current-char-codec")
(assert-equal? (tn) "UTF-8"      (%%current-char-codec))

(tn "%%set-current-char-codec!")
(assert-error  (tn) (lambda ()   (%%set-current-char-codec! "")))
(assert-error  (tn) (lambda ()   (%%set-current-char-codec! "UTF-32")))
(assert-equal? (tn) "UTF-8"      (%%set-current-char-codec! "UTF-8"))
(assert-equal? (tn) "UTF-8"      (%%current-char-codec))
(assert-equal? (tn) "ISO-8859-1" (%%set-current-char-codec! "ISO-8859-1"))
(assert-equal? (tn) "ISO-8859-1" (%%current-char-codec))
(assert-error  (tn) (lambda ()   (%%set-current-char-codec! "UTF-32")))
(assert-equal? (tn) "ISO-8859-1" (%%current-char-codec))
(assert-equal? (tn) "UTF-8"      (%%set-current-char-codec! "UTF-8"))
(assert-equal? (tn) "UTF-8"      (%%current-char-codec))

;; sigscheme-init.scm
(tn "with-char-codec")
(assert-equal? (tn) "UTF-8"      (%%current-char-codec))
(assert-equal? (tn) "ISO-8859-1" (with-char-codec "ISO-8859-1"
                                   (lambda ()
                                     (%%current-char-codec))))
(assert-equal? (tn) "UTF-8"      (with-char-codec "UTF-8"
                                   (lambda ()
                                     (%%current-char-codec))))
(assert-equal? (tn) "UTF-8"      (begin
                                   (guard (err
                                           (else #f))
                                     (with-char-codec "ISO-8859-1"
                                       (lambda ()
                                         (error "error in the thunk"))))
                                   (%%current-char-codec)))
(assert-equal? (tn) "UTF-8"      (begin
                                   (call-with-current-continuation
                                    (lambda (k)
                                      (with-char-codec "ISO-8859-1"
                                        (lambda ()
                                          (k #f)))))
                                   (%%current-char-codec)))

(tn "let-optionals* invalid forms")
(assert-error  (tn) (lambda () (let-optionals* '() ())))
(assert-error  (tn) (lambda () (let-optionals* #(0) () #t)))
(assert-error  (tn) (lambda () (let-optionals* #(0) args args)))
(assert-error  (tn) (lambda () (let-optionals* '() #(0) #t)))
(assert-error  (tn) (lambda () (let-optionals* '() (0) #t)))
(assert-error  (tn) (lambda () (let-optionals* '(0 1 2) (a . 3) #t)))

(tn "let-optionals* null bindings")
(assert-equal? (tn) 'ok (let-optionals* '()      () 'ok))
(assert-equal? (tn) 'ok (let-optionals* '(0)     () 'ok))
(assert-equal? (tn) 'ok (let-optionals* '(0 1)   () 'ok))
(assert-equal? (tn) 'ok (let-optionals* '(0 1 2) () 'ok))

;; Conforms to the undocumented behavior of Gauche 0.8.8.
(tn "let-optionals* restvar-only")
(assert-equal? (tn) '()      (let-optionals* '()      args args))
(assert-equal? (tn) '(0)     (let-optionals* '(0)     args args))
(assert-equal? (tn) '(0 1)   (let-optionals* '(0 1)   args args))
(assert-equal? (tn) '(0 1 2) (let-optionals* '(0 1 2) args args))

(tn "let-optionals* var-only single binding")
(assert-equal? (tn) (undef)    (let-optionals* '()      (a) a))
(assert-equal? (tn) 0          (let-optionals* '(0)     (a) a))
(assert-equal? (tn) 0          (let-optionals* '(0 1)   (a) a))

(tn "let-optionals* var-only bindings")
(assert-equal? (tn) (list ud ud) (let-optionals* '()      (a b) (list a b)))
(assert-equal? (tn) (list 0  ud) (let-optionals* '(0)     (a b) (list a b)))
(assert-equal? (tn) '(0 1)       (let-optionals* '(0 1)   (a b) (list a b)))
(assert-equal? (tn) '(0 1)       (let-optionals* '(0 1 2) (a b) (list a b)))

(tn "let-optionals* var-only bindings with restvar")
(assert-equal? (tn) (list ud ud '()) (let-optionals* '()      (a b . c) (list a b c)))
(assert-equal? (tn) (list 0  ud '()) (let-optionals* '(0)     (a b . c) (list a b c)))
(assert-equal? (tn) '(0 1 ())        (let-optionals* '(0 1)   (a b . c) (list a b c)))
(assert-equal? (tn) '(0 1 (2))       (let-optionals* '(0 1 2) (a b . c) (list a b c)))
(assert-equal? (tn) '(0 1 (2 3))     (let-optionals* '(0 1 2 3) (a b . c) (list a b c)))

(tn "let-optionals* var-defaultval single binding")
(assert-equal? (tn) 'A (let-optionals* '()      ((a 'A)) a))
(assert-equal? (tn) 0  (let-optionals* '(0)     ((a 'A)) a))
(assert-equal? (tn) 0  (let-optionals* '(0 1)   ((a 'A)) a))

(tn "let-optionals* var-defaultval bindings")
(assert-equal? (tn) '(A B) (let-optionals* '()      ((a 'A) (b 'B)) (list a b)))
(assert-equal? (tn) '(0 B) (let-optionals* '(0)     ((a 'A) (b 'B)) (list a b)))
(assert-equal? (tn) '(0 1) (let-optionals* '(0 1)   ((a 'A) (b 'B)) (list a b)))
(assert-equal? (tn) '(0 1) (let-optionals* '(0 1 2) ((a 'A) (b 'B)) (list a b)))

(tn "let-optionals* var-defaultval bindings with restvar")
(assert-equal? (tn) '(A B ())    (let-optionals* '()      ((a 'A) (b 'B) . c) (list a b c)))
(assert-equal? (tn) '(0 B ())    (let-optionals* '(0)     ((a 'A) (b 'B) . c) (list a b c)))
(assert-equal? (tn) '(0 1 ())    (let-optionals* '(0 1)   ((a 'A) (b 'B) . c) (list a b c)))
(assert-equal? (tn) '(0 1 (2))   (let-optionals* '(0 1 2) ((a 'A) (b 'B) . c) (list a b c)))
(assert-equal? (tn) '(0 1 (2 3)) (let-optionals* '(0 1 2 3) ((a 'A) (b 'B) . c) (list a b c)))

(tn "let-optionals* sequencial evaluation")
(assert-equal? (tn)
               '(2 5 10)
               (let-optionals* '() ((a 2)
                                    (b (+ a 3))
                                    (c (* a b)))
                 (list a b c)))
(assert-equal? (tn)
               '(3 6 18)
               (let-optionals* '(3 6) ((a 2)
                                       (b (+ a 3))
                                       (c (* a b)))
                 (list a b c)))

(tn "let-optionals* normal cases")
(assert-equal? (tn)
               '(21 3)
               (let-optionals* '(7) ((a 2)
                                     (b 3))
                 (set! a (* a b))
                 (list a b)))
(assert-equal? (tn)
               '(21 3)
               (let-optionals* '(7) (a
                                     (b 3))
                 (set! a (* a b))
                 (list a b)))

(total-report)
