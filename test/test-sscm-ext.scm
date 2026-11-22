#! /usr/bin/env sscm -C UTF-8

;;  Filename : test-sscm-ext.scm
;;  About    : unit tests for SigScheme specific extensions
;;
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

(require-extension (sscm-ext))

(require-extension (srfi 64))

(if (not (symbol-bound? 'let-optionals*))
    (test-skip-file "SigScheme extensions are not enabled"))

(test-begin "test-sscm-ext")
(define ud (undef))

(test-begin "sscm-version")
(test-assert (string? (sscm-version)))
;; MAJOR.MINOR.PATCHLEVEL
(if (symbol-bound? 'string->list)
    (let ((n-dots 0)
          (n-others 0))
      (for-each (lambda (c)
                  (cond
                   ((char=? c #\.) (set! n-dots (+ n-dots 1)))
                   ((not (char-numeric? c))
                    (set! n-others (+ n-others 1)))))
                (string->list (sscm-version)))
      (test-equal 2 n-dots)
      (test-equal 0 n-others)))
(test-end "sscm-version")

(test-begin "%%current-char-codec")
(test-equal "UTF-8"      (%%current-char-codec))
(test-end "%%current-char-codec")

(test-begin "%%set-current-char-codec!")
(test-error (%%set-current-char-codec! ""))
(test-error (%%set-current-char-codec! "UTF-32"))
(test-equal "UTF-8"      (%%set-current-char-codec! "UTF-8"))
(test-equal "UTF-8"      (%%current-char-codec))
(test-equal "ISO-8859-1" (%%set-current-char-codec! "ISO-8859-1"))
(test-equal "ISO-8859-1" (%%current-char-codec))
(test-error (%%set-current-char-codec! "UTF-32"))
(test-equal "ISO-8859-1" (%%current-char-codec))
(test-equal "UTF-8"      (%%set-current-char-codec! "UTF-8"))
(test-equal "UTF-8"      (%%current-char-codec))
(test-end "%%set-current-char-codec!")

;; sigscheme-init.scm
(test-begin "with-char-codec")
(test-equal "UTF-8"      (%%current-char-codec))
(test-equal "ISO-8859-1" (with-char-codec "ISO-8859-1"
                           (lambda ()
                             (%%current-char-codec))))
(test-equal "UTF-8"      (with-char-codec "UTF-8"
                           (lambda ()
                             (%%current-char-codec))))
(test-equal "UTF-8"      (begin
                           (guard (err
                                   (else #f))
                             (with-char-codec "ISO-8859-1"
                               (lambda ()
                                 (error "error in the thunk"))))
                           (%%current-char-codec)))
(test-equal "UTF-8"      (begin
                           (call-with-current-continuation
                            (lambda (k)
                              (with-char-codec "ISO-8859-1"
                                (lambda ()
                                  (k #f)))))
                           (%%current-char-codec)))
(test-end "with-char-codec")

(test-begin "let-optionals* invalid forms")
(test-error (let-optionals* '() ()))
(test-error (let-optionals* #(0) () #t))
(test-error (let-optionals* #(0) args args))
(test-error (let-optionals* '() #(0) #t))
(test-error (let-optionals* '() (0) #t))
(test-error (let-optionals* '(0 1 2) (a . 3) #t))
(test-end "let-optionals* invalid forms")

(test-begin "let-optionals* null bindings")
(test-equal 'ok (let-optionals* '()      () 'ok))
(test-equal 'ok (let-optionals* '(0)     () 'ok))
(test-equal 'ok (let-optionals* '(0 1)   () 'ok))
(test-equal 'ok (let-optionals* '(0 1 2) () 'ok))
(test-end "let-optionals* null bindings")

;; Conforms to the undocumented behavior of Gauche 0.8.8.
(test-begin "let-optionals* restvar-only")
(test-equal '()      (let-optionals* '()      args args))
(test-equal '(0)     (let-optionals* '(0)     args args))
(test-equal '(0 1)   (let-optionals* '(0 1)   args args))
(test-equal '(0 1 2) (let-optionals* '(0 1 2) args args))
(test-end "let-optionals* restvar-only")

(test-begin "let-optionals* var-only single binding")
(test-equal (undef)    (let-optionals* '()      (a) a))
(test-equal 0          (let-optionals* '(0)     (a) a))
(test-equal 0          (let-optionals* '(0 1)   (a) a))
(test-end "let-optionals* var-only single binding")

(test-begin "let-optionals* var-only bindings")
(test-equal (list ud ud) (let-optionals* '()      (a b) (list a b)))
(test-equal (list 0  ud) (let-optionals* '(0)     (a b) (list a b)))
(test-equal '(0 1)       (let-optionals* '(0 1)   (a b) (list a b)))
(test-equal '(0 1)       (let-optionals* '(0 1 2) (a b) (list a b)))
(test-end "let-optionals* var-only bindings")

(test-begin "let-optionals* var-only bindings with restvar")
(test-equal (list ud ud '()) (let-optionals* '()      (a b . c) (list a b c)))
(test-equal (list 0  ud '()) (let-optionals* '(0)     (a b . c) (list a b c)))
(test-equal '(0 1 ())        (let-optionals* '(0 1)   (a b . c) (list a b c)))
(test-equal '(0 1 (2))       (let-optionals* '(0 1 2) (a b . c) (list a b c)))
(test-equal '(0 1 (2 3))     (let-optionals* '(0 1 2 3) (a b . c) (list a b c)))
(test-end "let-optionals* var-only bindings with restvar")

(test-begin "let-optionals* var-defaultval single binding")
(test-equal 'A (let-optionals* '()      ((a 'A)) a))
(test-equal 0  (let-optionals* '(0)     ((a 'A)) a))
(test-equal 0  (let-optionals* '(0 1)   ((a 'A)) a))
(test-end "let-optionals* var-defaultval single binding")

(test-begin "let-optionals* var-defaultval bindings")
(test-equal '(A B) (let-optionals* '()      ((a 'A) (b 'B)) (list a b)))
(test-equal '(0 B) (let-optionals* '(0)     ((a 'A) (b 'B)) (list a b)))
(test-equal '(0 1) (let-optionals* '(0 1)   ((a 'A) (b 'B)) (list a b)))
(test-equal '(0 1) (let-optionals* '(0 1 2) ((a 'A) (b 'B)) (list a b)))
(test-end "let-optionals* var-defaultval bindings")

(test-begin "let-optionals* var-defaultval bindings with restvar")
(test-equal '(A B ())    (let-optionals* '()      ((a 'A) (b 'B) . c) (list a b c)))
(test-equal '(0 B ())    (let-optionals* '(0)     ((a 'A) (b 'B) . c) (list a b c)))
(test-equal '(0 1 ())    (let-optionals* '(0 1)   ((a 'A) (b 'B) . c) (list a b c)))
(test-equal '(0 1 (2))   (let-optionals* '(0 1 2) ((a 'A) (b 'B) . c) (list a b c)))
(test-equal '(0 1 (2 3)) (let-optionals* '(0 1 2 3) ((a 'A) (b 'B) . c) (list a b c)))
(test-end "let-optionals* var-defaultval bindings with restvar")

(test-begin "let-optionals* sequencial evaluation")
(test-equal '(2 5 10)
            (let-optionals* '() ((a 2)
                                 (b (+ a 3))
                                 (c (* a b)))
              (list a b c)))
(test-equal '(3 6 18)
            (let-optionals* '(3 6) ((a 2)
                                    (b (+ a 3))
                                    (c (* a b)))
              (list a b c)))
(test-end "let-optionals* sequencial evaluation")

(test-begin "let-optionals* normal cases")
(test-equal '(21 3)
            (let-optionals* '(7) ((a 2)
                                  (b 3))
              (set! a (* a b))
              (list a b)))
(test-equal '(21 3)
            (let-optionals* '(7) (a
                                  (b 3))
              (set! a (* a b))
              (list a b)))
(test-end "let-optionals* normal cases")

(test-begin "require")
(let ((path (string-append (%%system-load-path) "/srfi-95.scm")))
  (test-assert (not (provided? (string-append "*" path "-loaded*"))))
  (require path)
  (test-assert (provided? (string-append "*" path "-loaded*"))))
(test-end "require")

(test-end "test-sscm-ext")
