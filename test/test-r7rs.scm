;;  Filename : test-r7rs.scm
;;  About    : unit test for R7RS (preliminary)
;;
;;  Copyright (c) 2026 SigScheme Project <uim-en AT googlegroups.com>
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

(if (not (provided? "r7rs"))
    (test-skip "R7RS is not enabled"))

(define tn test-name)

(tn "vector literal")
(assert-equal? (tn) '#(1 2) #(1 2))
(assert-equal? (tn) '#() #())

(tn "boolean=?")
(assert-eq? (tn) #t (boolean=? #t #t))
(assert-eq? (tn) #t (boolean=? #f #f))
(assert-eq? (tn) #f (boolean=? #t #f))
(assert-eq? (tn) #t (boolean=? #f #f #f))
(assert-eq? (tn) #f (boolean=? #f #f #t))
(assert-error (tn) (lambda () (boolean=? #t)))
(assert-error (tn) (lambda () (boolean=? #t 1)))
(assert-error (tn) (lambda () (boolean=? #t #t 1)))

(tn "symbol=?")
(assert-eq? (tn) #t (symbol=? 'a 'a))
(assert-eq? (tn) #f (symbol=? 'a 'b))
(assert-eq? (tn) #t (symbol=? 'a 'a 'a))
(assert-eq? (tn) #f (symbol=? 'a 'a 'b))
(assert-error (tn) (lambda () (symbol=? 'a)))
(assert-error (tn) (lambda () (symbol=? 'a "a")))
(assert-error (tn) (lambda () (symbol=? 'a 'a "a")))

(tn "digit-value")
(assert-equal? (tn) 0 (digit-value #\0))
(assert-equal? (tn) 9 (digit-value #\9))
(assert-eq? (tn) #f (digit-value #\a))
(assert-eq? (tn) #f (digit-value #\.))
(assert-error (tn) (lambda () (digit-value 0)))

(tn "char-foldcase")
(assert-equal? (tn) #\a (char-foldcase #\a))
(assert-equal? (tn) #\a (char-foldcase #\A))
(assert-equal? (tn) #\1 (char-foldcase #\1))
(assert-error (tn) (lambda () (char-foldcase "a")))

(tn "string-upcase")
(assert-equal? (tn) "ABC1" (string-upcase "aBc1"))
(assert-equal? (tn) "" (string-upcase ""))
(assert-error (tn) (lambda () (string-upcase #\a)))

(tn "string-downcase")
(assert-equal? (tn) "abc1" (string-downcase "aBc1"))
(assert-equal? (tn) "" (string-downcase ""))
(assert-error (tn) (lambda () (string-downcase #\a)))

(tn "string-foldcase")
(assert-equal? (tn) "abc1" (string-foldcase "aBc1"))
(assert-equal? (tn) "" (string-foldcase ""))
(assert-error (tn) (lambda () (string-foldcase #\a)))

(if (and (symbol-bound? '%%current-char-codec)
         (equal? (%%current-char-codec) "UTF-8"))
    (let ((alpha (string (integer->char #x3b1)))
          (capital-alpha (string (integer->char #x391))))
      (tn "string case conversion with non-ASCII characters")
      ;; Only ASCII characters are converted.
      (assert-equal? (tn)
                     (string-append "A" alpha "B")
                     (string-upcase (string-append "a" alpha "b")))
      (assert-equal? (tn)
                     (string-append "a" capital-alpha "b")
                     (string-downcase (string-append "A" capital-alpha "B")))
      (assert-equal? (tn)
                     3
                     (string-length
                      (string-upcase (string-append "a" alpha "b"))))))

(total-report)
