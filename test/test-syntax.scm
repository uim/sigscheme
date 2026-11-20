;;  Filename : test-syntax.scm
;;  About    : unit test for R5RS syntaxes
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

(test-begin "test-syntax")

(define tee #t)
(define ef #f)


;;
;; if
;;
(test-begin "if invalid form")
(test-error (if))
(test-error (if #t))
(test-error (if #f))
(test-error (if #t 'true 'false 'excessive))
(test-error (if #f 'true 'false 'excessive))
(test-end "if invalid form")

(test-begin "if")
(test-equal 'true  (if #t 'true 'false))
(test-equal 'true  (if #t 'true))
(test-equal 'false (if #f 'true 'false))
;; check that does not cause error
(test-equal (if #f 'true) (if #f 'true))
;; check that <test> is evaluated
(test-equal 'true  (if tee 'true 'false))
(test-equal 'false (if ef 'true 'false))
(test-end "if")

;;
;; set!
;;
(test-begin "set! invalid form")
(define test-var #f)
(test-error (set!))
(test-error (set! test-unbound))
(test-error (set! test-var))
(test-error (set! test-var #t #t))
(test-error (set! 1 #t))
(test-end "set! invalid form")

(test-begin "set!")
(test-assert (set! test-var 'foo))
(test-equal 'foo test-var)
(test-assert (let ((test-var #f))
               (set! test-var 'bar)))
(test-equal 'foo test-var)
(test-assert (let ((test-var #f))
               (let ((test-var2 #f))
                 (set! test-var 'baz))
               (test-equal 'baz test-var)))
(test-equal 'foo test-var)
(test-error (set! test-unbound 'foo))
(test-error (let ((test-var #f))
              (set! test-unbound 'foo)))
(test-end "set!")

;;
;; cond
;;
(test-begin "cond invalid form")
;; 'cond' must contain at least one clause
(test-error (cond))
;; empty clause
(test-error (cond
             ()))
;; empty clause with 'else'
(test-error (cond
             ()
             (else #t)))
;; 'else' followed by another caluse
(test-error (cond
             (else #t)
             (#t)))
;; 'else' clause must contain at least one expression (7.1.3 Expressions)
(test-error (cond
             (else)))
;; '=>' is interpreted as unbound symbol if not followed by <exp>
(test-error (cond
             (#t =>)))
;; '=>' is interpreted as unbound symbol
(test-error (cond
             (=>)))
;; evaluation of '=>' causes error even if 'else' clause exists
(test-error (cond
             (#t =>)
             (else #t)))
;; '=>' is interpreted as unbound symbol even if in 'else' clause
(test-error (cond
             (else =>)))
;; '=>' is interpreted as unbound symbol even if in 'else' clause
(test-error (cond
             (else => 1 3)))
;; not a procedure
(test-error (cond
             (#t => #t)))
(test-error (cond
             (#t => #f)))
;; procedure but argument number mismatch
(test-error (cond
             (#t => eq?)))
;; not a procedure but a syntax
(test-error (cond
             (#t => delay)))
;; '=>' is not applicable at 'else' clause
(test-error (cond
             (else => values)))
(test-end "cond invalid form")

(test-begin "cond unspecified behavior")
;; not specified in R5RS, but SigScheme surely returns #<undef>
(if (provided? "sigscheme")
    (test-equal (undef)
                (cond
                 (#f))))
(if (provided? "sigscheme")
    (test-equal (undef)
                (cond
                 ((even? 3) #f)
                 ((positive? -1) #f))))
(test-end "cond unspecified behavior")


(test-begin "cond")
;; R5RS: If the selected <clause> contains only the <test> and no
;; <expression>s, then the value of the <test> is returned as the result.
(test-equal #t
            (cond
             (#t)))
(test-equal 3
            (cond
             (#f)
             (3)))
(test-equal 3
            (cond
             ((not #t))
             ((+ 1 2))))
(test-equal 3
            (cond
             (#f)
             (3)
             (4)))

(test-equal 'greater
            (cond
             ((> 3 2) 'greater)
             ((< 3 2) 'less)))
(test-equal 'equal
            (cond
             ((> 3 3) 'greater)
             ((< 3 3) 'less)
             (else 'equal)))
(test-equal #t
            (cond
             ((> 3 2))
             ((< 3 4) 'less)
             (else 'equal)))
(test-equal 2
            (cond
             ((assv 'b '((a 1) (b 2))) => cadr)
             (else #f)))
(test-equal 2
            (cond
             ((assv 'b '((a 1) (b 2))) => (car (list cadr cdar)))
             (else #f)))
(test-equal #f
            (cond
             ((assv 'c '((a 1) (b 2))) => cadr)
             (else #f)))
(test-equal 'greater1
            (cond
             ((> 3 2) 'greater0 'greater1)
             (else #f)))
;; single 'else' clause is allowed
(test-equal 'else
            (cond
             (else 'else)))
;; '=>' is interpreted as ordinary symbol if not followed by exactly one <exp>
(test-equal 'defined
            (let ((=> 'defined))
              (cond
               (#t =>))))
(test-equal 3
            (let ((=> 'defined))
              (cond
               (#t => 1 3))))
(test-end "cond")

(test-begin "cond locally bound keyword")
;; R5RS 4.3.2: A locally bound => isn't the keyword.
(test-equal 'ok (let ((=> #f)) (cond (#t => 'ok))))
(test-equal 'b (let ((else #f)) (cond (else 'a) (#t 'b))))
(test-end "cond locally bound keyword")


;;
;; case
;;
(test-begin "case invalid form")
(test-error (case))
(test-error (case 'key))
(test-error (case 'key
              ()))
;; case requires at least one <exp> in a clause
(test-error (case 'key
              ((key))))
(test-error (case 'key
              ((1 key))))
(test-error (case 'key
              (1)))
(test-error (case 'key
              ((1 . 2))))
;; not a ((<datum> ...) <exp>...) style clause
(test-error (case 'key
              (1 'matched)))
(test-error (case 'key
              (key 'matched)))
(test-error (case 'key
              (#(key) 'matched)))

(if (provided? "sigscheme")
    (begin
      ;; improper clause does not cause error if not evaled
      (test-equal (undef)
                  (case 'key
                    ((1) . 2)))
      (test-equal (undef)
                  (case 'key
                    ((1) #t . 2)))
      ;; causes error when evaled
      (test-error (case 1
                    ((1) . 2)))
      (test-error (case 1
                    ((1) #t . 2)))))

(test-error (case 'key
             ()
             (else #t)))
;; 'else' followed by another caluse
(test-error (case 'key
             (else #t)
             (#t)))
;; not specified in R5RS, but SigScheme should cause error
(if (provided? "sigscheme")
    (test-error (case 'key
                 (else))))
(test-error (case 'key
             (=>)))
(test-error (case 'key
             (#t =>)))
(test-error (case 'key
             (#t =>)
             (else #t)))
(test-error (case 'key
             (else =>)))
;; R7RS supports (else => <expression>) clause.
(if (provided? "r7rs")
    (test-eq #t
             (case 'key
               (else => symbol?)))
    (test-error (case 'key
                  (else => symbol?))))
(test-error (case 'key
             (else => #t)))
;; R7RS supports ((<datum>*) => <expression>) clause.
(if (provided? "r7rs")
    (test-eq 'key
             (case 'key
               ((key) => values)))
    (test-error (case 'key
                  ((key) => values))))
(test-error (case 'key
             ((key) => eq?)))
(test-error (case 'key
             ((key) => delay)))
(test-error (case 'key
             ((key) => #t)))
(test-error (case 'key
             ((key) => #f)))
(test-end "case invalid form")

(test-begin "case unspecified behavior")
;; not specified in R5RS, but SigScheme surely returns #<undef>
(if (provided? "sigscheme")
    (test-equal (undef)
                (case 'key
                  ((#f) #f))))
(if (provided? "sigscheme")
    (test-equal (undef)
                (case 'key
                  ((foo) #f)
                  ((bar) #f))))
(test-end "case unspecified behavior")

(test-begin "case")
(test-equal 'odd
            (case 3
              ((1 3 5) 'odd)
              ((2 4 6) 'even)))
(test-equal 'unknown
            (case 0
              ((1 3 5) 'odd)
              ((2 4 6) 'even)
              (else 'unknown)))
(test-equal 'odd
            (case (+ 1 2)
              ((1 3 5) 'odd)
              ((2 4 6) 'even)
              (else 'unknown)))
(test-equal 'second
            (case 3
              ((1 3 5) 'first 'second)
              ((2 4 6) 'even)
              (else 'unknown)))
(test-equal 'second
            (case (+ 1 2)
              ((1 3 5) 'first 'second)
              ((2 4 6) 'even)
              (else 'unknown)))
(test-equal 'third
            (case 'key
              ((1 foo 5) 'first 'second)
              ((2 key 6) 'third)
              (else 'unknown)))
(test-equal 'third
            (case (cadr '(foo key bar))
              ((1 foo 5) 'first 'second)
              ((2 key 6) 'third)
              (else 'unknown)))
;; single 'else' clause is allowed
(test-equal 'else
            (case 'key
             (else 'else)))
(test-end "case")

(test-begin "case locally bound keyword")
(test-error (let ((else #f))
              (case 3
                ((1) 'one)
                (else 'x))))
(if (provided? "r7rs")
    (test-equal 'ok
                (let ((=> #f))
                  (case 1
                    ((1) => 'ok)))))
(test-end "case locally bound keyword")

;;
;; and
;;
(test-begin "and")
(test-error (and . #t))
(test-error (and #t . #t))
(test-equal #t (and))
(test-equal #t (and (= 2 2) (> 2 1)))
(test-equal #f (and (= 2 2) (< 2 1)))
(test-equal '(f g) (and 1 2 'c '(f g)))
(test-equal #f (and #t #f))
(test-equal 3  (and #t (+ 1 2)))
(test-equal #f (and #t (not 3) (+ 1 2)))
(test-end "and")

;;
;; or
;;
(test-begin "or")
(test-error (or . #t))
(test-error (or #t . #t))
(test-equal #f (or))
(test-equal #t (or (= 2 2) (> 2 1)))
(test-equal #t (or (= 2 2) (< 2 1)))
(test-equal #f (or #f #f #f))
(test-equal '(b c) (or (memq 'b '(a b c))
                       (/ 3 0)))
(test-equal 3  (or #f (+ 1 2)))
(test-equal 3  (or #f (not 3) (+ 1 2) (not 4)))
(test-end "or")


(test-end "test-syntax")
