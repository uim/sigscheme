;;  Filename : test-unittest.scm
;;  About    : unit tests for unittest.scm
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

(require-extension (unittest))

(require-extension (srfi 23))

(define *test-track-progress* #f)
(define tn test-name)

;; Uncomment this to test these failure cases.
;;(provide "test-assertion-failures")
(cond-expand
 (test-assertion-failures
  (test-begin "SRFI-64 compatible assertions failure cases")
  (test-assert #f)
  (test-assert (not #t))
  (test-equal  #t #f)
  (test-equal  'symbol 'another-symbol)
  (test-equal  3 4)
  (test-equal  (+ 2 3) (+ 4 5))
  (test-equal  '(+ 2 3) '(+ 4 5))
  (test-equal  "string" "another-string")
  (test-eqv    #t #f)
  (test-eqv    'symbol 'another-symbol)
  (test-eqv    3 4)
  (test-eqv    (+ 2 3) (+ 4 5))
  (test-eqv    (list + 2 3) (list + 2 3))
  (test-eqv    (string-copy "string") (string-copy "string"))
  (test-eq     #t #f)
  (test-eq     'symbol 'another-symbol)
  (test-eq     (string-copy "string") (string-copy "string"))
  (test-error  1)
  (test-error  'symbol)
  (test-error  (+ 1 2))
  (test-end))
 (else #t))

(test-begin "SRFI-64 compatible assertions with implicit test name")
(test-assert #t)
(test-assert '(not #t))
(test-equal  #t #t)
(test-equal  #f #f)
(test-equal  'symbol 'symbol)
(test-equal  3 3)
(test-equal  (+ 2 3) (+ 1 4))
(test-equal  '(+ 2 3) '(+ 2 3))
(test-equal  "string" "string")
(test-eqv    #t #t)
(test-eqv    #f #f)
(test-eqv    'symbol 'symbol)
(test-eqv    3 3)
(test-eqv    (+ 2 3) (+ 1 4))
(test-eq     #t #t)
(test-eq     #f #f)
(test-eq     'symbol 'symbol)
(test-error  (map))
(test-error  (+ "1" "2"))
(test-error  (error "an user error"))
(test-end)

(test-begin "SRFI-64 compatible assertions with explicit test name")
(test-assert (tn) #t)
(test-assert (tn) '(not #t))
(test-equal  (tn) #t #t)
(test-equal  (tn) #f #f)
(test-equal  (tn) 'symbol 'symbol)
(test-equal  (tn) 3 3)
(test-equal  (tn) (+ 2 3) (+ 1 4))
(test-equal  (tn) '(+ 2 3) '(+ 2 3))
(test-equal  (tn) "string" "string")
(test-eqv    (tn) #t #t)
(test-eqv    (tn) #f #f)
(test-eqv    (tn) 'symbol 'symbol)
(test-eqv    (tn) 3 3)
(test-eqv    (tn) (+ 2 3) (+ 1 4))
(test-eq     (tn) #t #t)
(test-eq     (tn) #f #f)
(test-eq     (tn) 'symbol 'symbol)
(test-error  (tn) (map))
(test-error  (tn) (+ "1" "2"))
(test-error  (tn) (error "an user error"))
(test-end)

(test-begin "test-read-eval-string")
(test-eqv    3        (test-read-eval-string "(+ 1 2)"))
(test-equal  '(+ 1 2) (test-read-eval-string "'(+ 1 2)"))
(test-error           (test-read-eval-string "(+ 1 2) "))
(test-error           (test-read-eval-string "(+ 1 2"))
(test-end)

(test-begin "test-read-eval-string SRFI-64 examples")
(test-equal 7 (test-read-eval-string "(+ 3 4)"))
(test-error (test-read-eval-string "(+ 3"))
(test-error (test-read-eval-string "(+ 3 4"))
(test-error (test-read-eval-string "(+ 3 4) "))
(test-equal #\newline (test-read-eval-string "#\\newline"))
(test-error (test-read-eval-string "#\\newlin"))
(test-end)

(test-begin "Non-standard SRFI-64-like assertions")
(test-true  #t)
(test-false #f)
(test-true  (not #f))
(test-false (not #t))
(test-true  '(not #t))
(test-end)

(test-report-result)
