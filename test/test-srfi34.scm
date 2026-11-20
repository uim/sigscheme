;;  Filename : test-srfi34.scm
;;  About    : unit test for SRFI-34
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

(require-extension (srfi 8 34))

(test-begin "test-srfi34")

(define my-test-error
  (lambda (proc)
    (test-error (guard (var
                        ;; not an error but user-raised object
                        ((eq? var 'obj)
                         #f))
                  (proc)))))

;;
;; raise
;;

(test-begin "raise")
;; no arg
(test-error (raise))
;; multiple values are not allowed
(test-error (raise (values 1 2 3)))
;; no guard or raw exception handler
(test-error (raise 'exception))
(test-end "raise")

;;
;; with-exception-handler
;;

(test-begin "with-exception-handler invalid form")

;; handler is not a procedure
(my-test-error (lambda ()
                 (with-exception-handler
                     'a-handler-must-not-return
                   (lambda ()
                     (+ 1 (raise 'obj))))))

;; handler is a procedure but takes 2 arguments
(my-test-error (lambda ()
                 (with-exception-handler
                     eq?
                   (lambda ()
                     (+ 1 (raise 'obj))))))

;; thunk is not a procedure
(my-test-error (lambda ()
                 (with-exception-handler
                     (lambda (x)
                       'a-handler-must-not-return)
                   'an-error)))

;; thunk is a procedure but takes an argument
(my-test-error (lambda ()
                 (with-exception-handler
                     (lambda (x)
                       'a-handler-must-not-return)
                   (lambda (dummy)
                     (+ 1 (raise 'obj))))))
(test-end "with-exception-handler invalid form")

(test-begin "with-exception-handler")

;; Although the behavior when a handler returned is not specified in SRFI-34,
;; SigScheme should produce an error to prevent being misused by users.
(if sigscheme?
    (my-test-error (lambda ()
                     (with-exception-handler
                         (lambda (x)
                           'a-handler-must-not-return)
                       (lambda ()
                         (+ 1 (raise 'obj)))))))

(test-error (with-exception-handler
                (lambda (x)
                  (test-equal 'an-error x)
                  'a-handler-must-not-return)
              (lambda ()
                (+ 1 (raise 'an-error)))))

(test-equal 6
            (with-exception-handler
                (lambda (x)
                  'not-reaches-here)
              (lambda ()
                (+ 1 2 3))))

(test-equal 'success
            (with-exception-handler
                (lambda (x)
                  'not-reaches-here)
              (lambda ()
                'success)))

;; multiple values are allowed for thunk
(test-equal '(1 2 3)
            (receive vals
                (with-exception-handler
                    (lambda (x)
                      'not-reaches-here)
                  (lambda ()
                    (values 1 2 3)))
              vals))
(test-end "with-exception-handler")


;;
;; guard
;;

(test-begin "guard")
(test-equal 'exception
            (guard (condition
                    (else
                     (test-equal 'an-error condition)
                     'exception))
              (+ 1 (raise 'an-error))))

(test-equal 3
            (guard (condition
                    (else
                     'exception))
              (+ 1 2)))

(test-equal 'success
            (guard (condition
                    (else
                     'exception))
              'success))

(test-equal 'exception
            (guard (condition
                    (else
                     'exception))
              (+ 1 (raise 'error))))

(test-equal 42
            (guard (condition
                    ((assq 'a condition) => cdr)
                    ((assq 'b condition))
                    (else
                     (display condition)
                     (newline)))
              (raise (list (cons 'a 42)))))

(test-equal '(b . 23)
            (guard (condition
                    ((assq 'a condition) => cdr)
                    ((assq 'b condition))
                    (else
                     (display condition)
                     (newline)))
              (raise (list (cons 'b 23)))))

;; not matched against => and fall through to else
(test-equal 'else
            (guard (condition
                    ((assv condition '((a 1) (b 2))) => cadr)
                    (else 'else))
              (raise 'c)))
(test-end "guard")

;;
;; handler part of guard
;;

(test-begin "guard handler invalid form")

(my-test-error (lambda ()
                 (guard (var)
                   (raise 'obj))))

(my-test-error (lambda ()
                 (guard (var
                         ())
                   (raise 'obj))))

(my-test-error (lambda ()
                 (guard (var
                         ()
                         (else #t))
                   (raise 'obj))))

;; 'else' followed by another caluse
(my-test-error (lambda ()
                 (guard (var
                         (else #t)
                         (#t))
                   (raise 'obj))))

;; not specified in R5RS 'case', but SigScheme should cause error
(if (provided? "sigscheme")
    (my-test-error (lambda ()
                     (guard (var
                             (else))
                       (raise 'obj)))))

(my-test-error (lambda ()
                 (guard (var
                         (#t =>))
                   (raise 'obj))))

(my-test-error (lambda ()
                 (guard (var
                         (#t =>)
                         (else #t))
                   (raise 'obj))))

(my-test-error (lambda ()
                 (guard (var
                         (else =>))
                   (raise 'obj))))

;; not a procedure
(my-test-error (lambda ()
                 (guard (var
                         (#t => #t))
                   (raise 'obj))))

;; not a procedure but #f
(my-test-error (lambda ()
                 (guard (var
                         (#t => #f))
                   (raise 'obj))))

;; procedure but argument number mismatch
(my-test-error (lambda ()
                 (guard (var
                         (#t => eq?))
                   (raise 'obj))))

;; not a procedure but a syntax
(my-test-error (lambda ()
                 (guard (var
                         (#t => delay))
                   (raise 'obj))))
(test-end "guard handler invalid form")

(test-begin "guard namespace taintlessness")

(test-assert (not (guard (var
                          (#f var))
                    (symbol-bound? 'lex-env))))

(test-assert (not (guard (var
                          (#f var))
                    (symbol-bound? 'cond-catch))))

(test-assert (not (guard (var
                          (#f var))
                    (symbol-bound? 'body))))

(test-assert (not (guard (var
                          (#f var))
                    (symbol-bound? 'condition))))

(test-assert (not (guard (var
                          (#f var))
                    (symbol-bound? 'guard-k))))

(test-assert (not (guard (var
                          (#f var))
                    (symbol-bound? 'handler-k))))

(test-assert (not (guard (var
                          (#f var))
                    (symbol-bound? 'var))))
(test-end "guard namespace taintlessness")

(test-begin "guard handler namespace taintlessness")

(test-assert (not (guard (var
                          (else
                           (symbol-bound? 'lex-env)))
                    (raise 'err))))

(test-assert (not (guard (var
                          (else
                           (symbol-bound? 'cond-catch)))
                    (raise 'err))))

(test-assert (not (guard (var
                          (else
                           (symbol-bound? 'body)))
                    (raise 'err))))

(test-assert (not (guard (var
                          (else
                           (symbol-bound? 'condition)))
                    (raise 'err))))

(test-assert (not (guard (var
                          (else
                           (symbol-bound? 'guard-k)))
                    (raise 'err))))

(test-assert (not (guard (var
                          (else
                           (symbol-bound? 'handler-k)))
                    (raise 'err))))
(test-end "guard handler namespace taintlessness")

(test-begin "guard handler condition variable")

(test-equal 'err
            (guard (var
                    (else var))
              (raise 'err)))

;; the variable can be modified
(test-equal 'ERR
            (guard (var
                    (#t
                     (set! var 'ERR)
                     var))
              (raise 'err)))

;; the variable does not affect outer environment
(define var 'global-var)
(test-equal 'outer
            (let ((var 'outer))
              (guard (var
                      (#t
                       (set! var 'ERR)))
                (raise 'err))
              var))

;; the variable does not affect global one
(define var 'global-var)
(test-equal 'global-var
            (begin
              (guard (var
                      (#t
                       (set! var 'ERR)))
                (raise 'err))
              var))
(test-end "guard handler condition variable")

(test-begin "guard evaluation count exactness")

(test-equal 7
            (guard (var
                    (else var))
              (+ 3 4)))

(test-equal 7
            (guard (var
                    (else var))
              (raise (+ 3 4))))

(test-equal 7
            (guard (var
                    (else (+ 3 4)))
              (raise 'err)))

(test-equal 7
            (let ((a 3)
                  (b 4))
              (guard (var
                      (else var))
                (+ a b))))

(test-equal 7
            (let ((a 3)
                  (b 4))
              (guard (var
                      (else var))
                (raise (+ a b)))))

(test-equal 7
            (let ((a 3)
                  (b 4))
              (guard (var
                      (else (+ a b)))
                (raise 'err))))

(test-equal (list + 3 4)  ;; not 7
            (let ((a 3)
                  (b 4))
              (guard (var
                      (else var))
                (list + a b))))

(test-equal (list + 3 4)  ;; not 7
            (let ((a 3)
                  (b 4))
              (guard (var
                      (else var))
                (raise (list + a b)))))

(test-equal (list + 3 4)  ;; not 7
            (let ((a 3)
                  (b 4))
              (guard (var
                      (else (list + a b)))
                (raise 'err))))
(test-end "guard evaluation count exactness")

(test-begin "guard with multiple values")

(test-equal '(1 2)
            (receive vals
                (guard (var
                        (else var))
                  (values 1 2))
              vals))

(test-equal '(1 2)
            (receive vals
                (guard (var
                        (else (values 1 2)))
                  (raise 'err))
              vals))

(if (provided? "sigscheme")
    (test-error (guard (var
                        ((not (%%error-object? var))
                         var))
                  (raise (values 1 2)))))
(test-end "guard with multiple values")

(test-begin "guard handler reraise")

(test-equal 'reraised
            (guard (var
                    ((eq? var 'error)
                     'reraised))
              (guard (var
                      (#f))
                (raise 'error))))
(test-equal 'reraised
            (guard (var
                    ((eq? var 'error)
                     'reraised))
              (guard (var
                      ((even? 3) #f)
                      ((positive? -1) #f))
                (raise 'error))))
(test-error (guard (condition
                    ((positive? condition) 'positive)
                    ((negative? condition) 'negative))
              (raise 0)))
(test-end "guard handler reraise")

;; The clauses are evaluated with the dynamic environment of the guard. The
;; condition is reraised with the dynamic environment of the raise.
(test-begin "guard handler dynamic environment")
(define guard-log '())
(define (guard-note x)
  (set! guard-log (cons x guard-log)))
(define (guard-note-thunk x)
  (lambda () (guard-note x)))
(set! guard-log '())
(test-equal 'caught
            (guard (var
                    (#t (guard-note 'handler) 'caught))
              (dynamic-wind
                  (guard-note-thunk 'before)
                  (lambda () (raise 'error))
                  (guard-note-thunk 'after))))
(test-equal '(before after handler) (reverse guard-log))
(set! guard-log '())
(test-equal 'outer
            (guard (var
                    (#t (guard-note 'outer) 'outer))
              (guard (var
                      ((begin (guard-note 'test) #f) 'inner))
                (dynamic-wind
                    (guard-note-thunk 'before)
                    (lambda () (raise 'error))
                    (guard-note-thunk 'after)))))
(test-equal '(before after test before after outer)
            (reverse guard-log))
;; A raise in a clause is handled by the outer handler.
(test-equal 'again
            (guard (var
                    (#t var))
              (guard (var
                      (#t (raise 'again)))
                (raise 'error))))
(test-end "guard handler dynamic environment")

(test-begin "guard handler tested value as result")

;; R5RS: If the selected <clause> contains only the <test> and no
;; <expression>s, then the value of the <test> is returned as the result.
(test-equal #t
            (guard (var
                    (#t))
              (raise 'error)))
(test-equal 3
            (guard (var
                    (#f)
                    (3))
              (raise 'error)))
(test-equal 3
            (guard(var
                   (#f)
                   (3)
                   (4))
              (raise 'error)))
(test-end "guard handler tested value as result")

;;
;; mixed use of with-exception-handler and guard
;;

(test-begin "mixed exception handling")

(test-equal 'guard-ret
            (with-exception-handler (lambda (x)
                                      (k 'with-exception-ret))
              (lambda ()
                (guard (condition
                        (else
                         'guard-ret))
                  (raise 1)))))

(test-error (with-exception-handler (lambda (x)
                                      'with-exception-ret
                                      ;; a exception handler must not
                                      ;; return (as specified in SRFI-34)
                                      )
              (lambda ()
                (guard (condition
                        ((negative? condition)
                         'guard-ret))
                  (raise 1)))))

(test-equal 'positive
            (call-with-current-continuation
             (lambda (k)
               (with-exception-handler (lambda (x)
                                         (k 'zero))
                 (lambda ()
                   (guard (condition
                           ((positive? condition) 'positive)
                           ((negative? condition) 'negative))
                     (raise 1)))))))

(test-equal 'negative
            (call-with-current-continuation
             (lambda (k)
               (with-exception-handler (lambda (x)
                                         (k 'zero))
                 (lambda ()
                   (guard (condition
                           ((positive? condition) 'positive)
                           ((negative? condition) 'negative))
                     (raise -1)))))))

(test-equal 'zero
            (call-with-current-continuation
             (lambda (k)
               (with-exception-handler (lambda (x)
                                         (k 'zero))
                 (lambda ()
                   (guard (condition
                           ((positive? condition) 'positive)
                           ((negative? condition) 'negative))
                     (raise 0)))))))
(test-end "mixed exception handling")

(test-end "test-srfi34")
