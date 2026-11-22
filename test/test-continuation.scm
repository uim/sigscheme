;;  Filename : test-continuation.scm
;;  About    : unit test for continuation
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

(require-extension (srfi 64))

(if (not (symbol-bound? 'call-with-current-continuation))
    (test-skip-file "R5RS continuation is not enabled"))

(test-begin "test-continuation")
(define call/cc call-with-current-continuation)

(test-begin "call/cc invalid forms")
;; no procedure
(test-error (call-with-current-continuation))
;; not a procedure
(test-error (call-with-current-continuation #t))
;; excessive
(test-argcheck-error (call-with-current-continuation procedure? #t))
(test-end "call/cc invalid forms")

(test-begin "call/cc")
;; not applicable
(test-error (call-with-current-continuation +))

(test-equal -3
            (call-with-current-continuation
             (lambda (exit)
               (for-each (lambda (x)
                           (if (negative? x)
                               (exit x)))
                         '(54 0 37 -3 245 19))
               #t)))

(define list-length
  (lambda (obj)
    (call-with-current-continuation
     (lambda (return)
       (letrec ((re
                 (lambda (obj1)
                   (cond ((null? obj1) 0)
                         ((pair? obj1)
                          (+ (re (cdr obj1)) 1))
                         (else
                          (return #f))))))
      (re obj))))))

(test-equal 4  (list-length '(1 2 3 4)))
(test-equal #f (list-length '(a b . c)))

;; function written in C as proc
(test-assert (call/cc procedure?))

;; another continuation as proc
(test-assert (procedure? (call/cc (lambda (c) (call/cc c)))))

(test-equal 'ret-call/cc
            (call-with-current-continuation
             (lambda (k)
               'ret-call/cc)))

(test-equal 'ret-call/cc
            (call-with-current-continuation
             (lambda (k)
               (k 'ret-call/cc))))

;; Call an expired continuation. Current SigScheme cause an error due to its
;; setjmp/longjmp implementation.
(test-error (let ((res (call-with-current-continuation
                        (lambda (k)
                          k))))
              (if (procedure? res)
                  (res 'succeeded)
                  res)))

;; "6.4 Control features" of R5RS:
;; The escape procedure accepts the same number of arguments as the
;; continuation to the original call to call-with-current-continuation.
;; Except for continuations created by the `call-with-values' procedure, all
;; continuations take exactly one value.
(test-argcheck-error (call-with-current-continuation
                      (lambda (k)
                        (k (values 1 2)))))

(test-argcheck-error (call-with-current-continuation
                      (lambda (k)
                        (k (values)))))

;; one value is OK
(test-equal 1
            (call-with-current-continuation
             (lambda (k)
               (k (values 1)))))
(test-end "call/cc")

(test-begin "call/cc SigScheme-specific behavior")
(if (and (provided? "sigscheme")
         (provided? "nested-continuation-only"))
    ;; expired continuation
    (test-error ((call/cc (lambda (c) c))
                 procedure?))
    (test-assert ((call/cc (lambda (c) c))
                  procedure?)))
(test-end "call/cc SigScheme-specific behavior")

(test-begin "call/cc multiple values continuation")
(test-equal '()
            (call-with-values
                (lambda ()
                  (call/cc (lambda (k) (k))))
              (lambda args
                args)))
(test-error (call-with-values
                (lambda ()
                  (call/cc (lambda (k) (k 0))))
              (lambda ()
                #t)))
(test-error (call-with-values
                (lambda ()
                  (call/cc (lambda (k) (k 0))))
              (lambda (x y)
                #t)))
(test-argcheck-error (call/cc (lambda (k) (k))))

(test-equal '(0 1 2)
            (call-with-values
                (lambda ()
                  (call/cc (lambda (k) (k 0 1 2))))
              (lambda args
                args)))
(test-error (call-with-values
                (lambda ()
                  (call/cc (lambda (k) (k 0 1 2))))
              (lambda ()
                #t)))
(test-error (call-with-values
                (lambda ()
                  (call/cc (lambda (k) (k 0 1 2))))
              (lambda (x)
                #t)))
(test-error (call-with-values
                (lambda ()
                  (call/cc (lambda (k) (k 0 1 2))))
              (lambda (x y)
                #t)))
(test-error (call-with-values
                (lambda ()
                  (call/cc (lambda (k) (k 0 1 2))))
              (lambda (x y z a)
                #t)))
(test-argcheck-error (call/cc (lambda (k) (k 0 1 2))))
(test-end "call/cc multiple values continuation")

(test-end "test-continuation")
