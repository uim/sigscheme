;;  Filename : test-srfi43.scm
;;  About    : unit tests for SRFI-43
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

(require-extension (unittest) (srfi 43))


(test-begin "let-vector-start+end invalid forms")
(define vec (vector 'foo 'bar 'baz))
;; nonexistent <callee>
(test-error (let-vector-start+end nonexistent vec '() (start end) #t))
;; invalid <vector>
(test-error (let-vector-start+end vector-ref '() '() (start end) #t))
(test-error (let-vector-start+end vector-ref #f '() (start end) #t))
;; invalid <args>
(test-error (let-vector-start+end vector-ref vec '(#t) (start end) #t))
(test-error (let-vector-start+end vector-ref vec '(0 #t) (start end) #t))
(test-error (let-vector-start+end vector-ref vec '(0 1 2) (start end) #t))
(test-error (let-vector-start+end vector-ref vec '#() (start end) #t))
(test-error (let-vector-start+end vector-ref vec #f (start end) #t))
;; malformed bindings
(test-error (let-vector-start+end vector-ref vec '() () #t))
(test-error (let-vector-start+end vector-ref vec '() (start) #t))
(test-error (let-vector-start+end vector-ref vec '() (start end extra) #t))
(test-error (let-vector-start+end vector-ref vec '() '(start end) #t))
(test-error (let-vector-start+end vector-ref vec '() #() #t))
(test-error (let-vector-start+end vector-ref vec '() '#() #t))
;; no body
(test-error (let-vector-start+end vector-ref vec '() (start end)))
(test-end)

(test-begin "let-vector-start+end null vector")
(test-error (let-vector-start+end vector-ref '#() '(-1)   (start end) #t))
(test-equal '(0 0)
            (let-vector-start+end vector-ref '#() '()     (start end)
                                  (list start end)))
(test-error (let-vector-start+end vector-ref '#() '(0)    (start end)
                                  (list start end)))
(test-error (let-vector-start+end vector-ref '#() '(0 -1) (start end) #t))
(test-error (let-vector-start+end vector-ref '#() '(0 0)  (start end)
                                  (list start end)))
(test-error (let-vector-start+end vector-ref '#() '(0 1)  (start end) #t))
(test-error (let-vector-start+end vector-ref '#() '(1)    (start end) #t))
(test-error (let-vector-start+end vector-ref '#() '(1 -1) (start end) #t))
(test-error (let-vector-start+end vector-ref '#() '(1 0)  (start end) #t))
(test-error (let-vector-start+end vector-ref '#() '(1 1)  (start end) #t))
(test-end)

(test-begin "let-vector-start+end length 1")
(define vec (vector 'foo))
(test-error (let-vector-start+end vector-ref vec '(-1)    (start end) #t))
(test-error (let-vector-start+end vector-ref vec '(-1 -1) (start end) #t))
(test-error (let-vector-start+end vector-ref vec '(-1 0)  (start end) #t))
(test-error (let-vector-start+end vector-ref vec '(-1 1)  (start end) #t))
(test-error (let-vector-start+end vector-ref vec '(-1 2)  (start end) #t))
(test-equal '(0 1)
            (let-vector-start+end vector-ref vec '()      (start end)
                                  (list start end)))
(test-equal '(0 1)
            (let-vector-start+end vector-ref vec '(0)     (start end)
                                  (list start end)))
(test-error (let-vector-start+end vector-ref vec '(0 -1)  (start end) #t))
(test-equal '(0 0)
            (let-vector-start+end vector-ref vec '(0 0)   (start end)
                                  (list start end)))
(test-equal '(0 1)
            (let-vector-start+end vector-ref vec '(0 1)   (start end)
                                  (list start end)))
(test-error (let-vector-start+end vector-ref vec '(0 2)   (start end) #t))
(test-error (let-vector-start+end vector-ref vec '(1)     (start end) #t))
(test-error (let-vector-start+end vector-ref vec '(1 -1)  (start end) #t))
(test-error (let-vector-start+end vector-ref vec '(1 0)   (start end) #t))
(test-error (let-vector-start+end vector-ref vec '(1 1)   (start end) #t))
(test-error (let-vector-start+end vector-ref vec '(1 2)   (start end) #t))
(test-end)

(test-begin "let-vector-start+end length 2")
(define vec (vector 'foo 'bar))
(test-error (let-vector-start+end vector-ref vec '(-1)    (start end) #t))
(test-error (let-vector-start+end vector-ref vec '(-1 -1) (start end) #t))
(test-error (let-vector-start+end vector-ref vec '(-1 0)  (start end) #t))
(test-error (let-vector-start+end vector-ref vec '(-1 1)  (start end) #t))
(test-error (let-vector-start+end vector-ref vec '(-1 2)  (start end) #t))
(test-error (let-vector-start+end vector-ref vec '(-1 3)  (start end) #t))
(test-equal '(0 2)
            (let-vector-start+end vector-ref vec '()      (start end)
                                  (list start end)))
(test-equal '(0 2)
            (let-vector-start+end vector-ref vec '(0)     (start end)
                                  (list start end)))
(test-error (let-vector-start+end vector-ref vec '(0 -1)  (start end) #t))
(test-equal '(0 0)
            (let-vector-start+end vector-ref vec '(0 0)   (start end)
                                  (list start end)))
(test-equal '(0 1)
            (let-vector-start+end vector-ref vec '(0 1)   (start end)
                                  (list start end)))
(test-equal '(0 2)
            (let-vector-start+end vector-ref vec '(0 2)   (start end)
                                  (list start end)))
(test-error (let-vector-start+end vector-ref vec '(0 3)   (start end) #t))

(test-equal '(1 2)
            (let-vector-start+end vector-ref vec '(1)     (start end)
                                  (list start end)))
(test-error (let-vector-start+end vector-ref vec '(1 -1)  (start end) #t))
(test-error (let-vector-start+end vector-ref vec '(1 0)   (start end) #t))
(test-equal '(1 1)
            (let-vector-start+end vector-ref vec '(1 1)   (start end)
                                  (list start end)))
(test-equal '(1 2)
            (let-vector-start+end vector-ref vec '(1 2)   (start end)
                                  (list start end)))
(test-error (let-vector-start+end vector-ref vec '(1 3)   (start end) #t))
(test-error (let-vector-start+end vector-ref vec '(2)     (start end) #t))
(test-error (let-vector-start+end vector-ref vec '(2 -1)  (start end) #t))
(test-error (let-vector-start+end vector-ref vec '(2 0)   (start end) #t))
(test-error (let-vector-start+end vector-ref vec '(2 1)   (start end) #t))
(test-error (let-vector-start+end vector-ref vec '(2 2)   (start end) #t))
(test-error (let-vector-start+end vector-ref vec '(2 3)   (start end) #t))
(test-end)

(test-begin "let-vector-start+end length 3")
(define vec (vector 'foo 'bar 'baz))
(test-error (let-vector-start+end vector-ref vec '(-1)    (start end) #t))
(test-error (let-vector-start+end vector-ref vec '(-1 -1) (start end) #t))
(test-error (let-vector-start+end vector-ref vec '(-1 0)  (start end) #t))
(test-error (let-vector-start+end vector-ref vec '(-1 1)  (start end) #t))
(test-error (let-vector-start+end vector-ref vec '(-1 2)  (start end) #t))
(test-error (let-vector-start+end vector-ref vec '(-1 3)  (start end) #t))
(test-equal '(0 3)
            (let-vector-start+end vector-ref vec '()      (start end)
                                  (list start end)))
(test-equal '(0 3)
            (let-vector-start+end vector-ref vec '(0)     (start end)
                                  (list start end)))
(test-error (let-vector-start+end vector-ref vec '(0 -1)  (start end) #t))
(test-equal '(0 0)
            (let-vector-start+end vector-ref vec '(0 0)   (start end)
                                  (list start end)))
(test-equal '(0 1)
            (let-vector-start+end vector-ref vec '(0 1)   (start end)
                                  (list start end)))
(test-equal '(0 2)
            (let-vector-start+end vector-ref vec '(0 2)   (start end)
                                  (list start end)))
(test-equal '(0 3)
            (let-vector-start+end vector-ref vec '(0 3)   (start end)
                                  (list start end)))
(test-error (let-vector-start+end vector-ref vec '(0 4)   (start end) #t))

(test-equal '(1 3)
            (let-vector-start+end vector-ref vec '(1)     (start end)
                                  (list start end)))
(test-error (let-vector-start+end vector-ref vec '(1 -1)  (start end) #t))
(test-error (let-vector-start+end vector-ref vec '(1 0)   (start end) #t))
(test-equal '(1 1)
            (let-vector-start+end vector-ref vec '(1 1)   (start end)
                                  (list start end)))
(test-equal '(1 2)
            (let-vector-start+end vector-ref vec '(1 2)   (start end)
                                  (list start end)))
(test-equal '(1 3)
            (let-vector-start+end vector-ref vec '(1 3)   (start end)
                                  (list start end)))
(test-error (let-vector-start+end vector-ref vec '(1 4)   (start end) #t))

(test-equal '(2 3)
            (let-vector-start+end vector-ref vec '(2)     (start end)
                                  (list start end)))
(test-error (let-vector-start+end vector-ref vec '(2 -1)  (start end) #t))
(test-error (let-vector-start+end vector-ref vec '(2 0)   (start end) #t))
(test-error (let-vector-start+end vector-ref vec '(2 1)   (start end) #t))
(test-equal '(2 2)
            (let-vector-start+end vector-ref vec '(2 2)   (start end)
                                  (list start end)))
(test-equal '(2 3)
            (let-vector-start+end vector-ref vec '(2 3)   (start end)
                                  (list start end)))
(test-error (let-vector-start+end vector-ref vec '(2 4)   (start end) #t))

(test-error (let-vector-start+end vector-ref vec '(3)     (start end) #t))
(test-error (let-vector-start+end vector-ref vec '(3 -1)  (start end) #t))
(test-error (let-vector-start+end vector-ref vec '(3 0)   (start end) #t))
(test-error (let-vector-start+end vector-ref vec '(3 1)   (start end) #t))
(test-error (let-vector-start+end vector-ref vec '(3 2)   (start end) #t))
(test-error (let-vector-start+end vector-ref vec '(3 3)   (start end) #t))
(test-end)

;; Test real let-vector-start+end use.
(test-begin "vector->list R5RS")
(test-equal '()
            (vector->list '#()))
(test-equal '(0 1 2 3 4)
            (vector->list '#(0 1 2 3 4)))
(test-end)

(test-begin "vector->list with start index")
(test-error (vector->list '#(0 1 2 3 4) -1))
(test-equal '(0 1 2 3 4)
            (vector->list '#(0 1 2 3 4) 0))
(test-equal '(1 2 3 4)
            (vector->list '#(0 1 2 3 4) 1))
(test-equal '(2 3 4)
            (vector->list '#(0 1 2 3 4) 2))
(test-equal '(3 4)
            (vector->list '#(0 1 2 3 4) 3))
(test-equal '(4)
            (vector->list '#(0 1 2 3 4) 4))
(cond-expand
 (gauche
  (test-equal '()
              (vector->list '#(0 1 2 3 4) 5)))
 (else
  (test-error (vector->list '#(0 1 2 3 4) 5))))
(test-error (vector->list '#(0 1 2 3 4) 6))
(test-end)

(test-begin "vector->list with start and end index")
(test-error (vector->list '#(0 1 2 3 4) 0 -1))
(test-equal '()
            (vector->list '#(0 1 2 3 4) 0 0))
(test-equal '(0)
            (vector->list '#(0 1 2 3 4) 0 1))
(test-equal '(0 1)
            (vector->list '#(0 1 2 3 4) 0 2))
(test-equal '(0 1 2 3 4)
            (vector->list '#(0 1 2 3 4) 0 5))
(test-error (vector->list '#(0 1 2 3 4) 0 6))

(test-error (vector->list '#(0 1 2 3 4) 1 0))
(test-equal '()
            (vector->list '#(0 1 2 3 4) 1 1))
(test-equal '(1)
            (vector->list '#(0 1 2 3 4) 1 2))
(test-equal '(1 2)
            (vector->list '#(0 1 2 3 4) 1 3))
(test-equal '(1 2 3 4)
            (vector->list '#(0 1 2 3 4) 1 5))

(test-error (vector->list '#(0 1 2 3 4) 4 3))
(test-equal '()
            (vector->list '#(0 1 2 3 4) 4 4))
(test-equal '(4)
            (vector->list '#(0 1 2 3 4) 4 5))
(cond-expand
 (gauche
  (test-equal '()
              (vector->list '#(0 1 2 3 4) 5 5)))
 (else
  (test-error (vector->list '#(0 1 2 3 4) 5 5))))
(test-end)

(test-report-result)
