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

(total-report)
