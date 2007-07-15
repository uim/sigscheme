;; Copyright (c) 2000-2007 Shiro Kawai  <shiro@acm.org>
;;
;; Redistribution and use in source and binary forms, with or without
;; modification, are permitted provided that the following conditions
;; are met:
;;
;;  1. Redistributions of source code must retain the above copyright
;;     notice, this list of conditions and the following disclaimer.
;;
;;  2. Redistributions in binary form must reproduce the above copyright
;;     notice, this list of conditions and the following disclaimer in the
;;     documentation and/or other materials provided with the distribution.
;;
;;  3. Neither the name of the authors nor the names of its contributors
;;     may be used to endorse or promote products derived from this
;;     software without specific prior written permission.
;;
;; THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
;; "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
;; LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
;; A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
;; OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
;; SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED
;; TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
;; PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
;; LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
;; NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
;; SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

;; ChangeLog
;;
;; 2007-06-16 yamaken    Copied from Gauche CVS HEAD revision 1.6, adapted
;;                       to SigScheme and add some tests
;;                       http://gauche.cvs.sourceforge.net/*checkout*/gauche/Gauche/test/procedure.scm

(require-extension (sscm-ext))

(load "./test/unittest-gauche.scm")

;;-------------------------------------------------------------------
;; (test-section "optional arguments")

(define (oof x . args)
  (let-optionals* args ((a 'a)
                        (b 'b)
                        (c 'c))
    (list x a b c)))

(test* "let-optionals*" '(0 a b c) '(oof 0))
(test* "let-optionals*" '(0 1 b c) '(oof 0 1))
(test* "let-optionals*" '(0 1 2 c) '(oof 0 1 2))
(test* "let-optionals*" '(0 1 2 3) '(oof 0 1 2 3))
(test* "let-optionals*" '(0 1 2 3) '(oof 0 1 2 3 4))

(define (oof* x . args)
  (let-optionals* args ((a 'a)
                        (b 'b)
                        . c)
    (list x a b c)))

(test* "let-optionals*" '(0 a b ()) '(oof* 0))
(test* "let-optionals*" '(0 1 b ()) '(oof* 0 1))
(test* "let-optionals*" '(0 1 2 ()) '(oof* 0 1 2))
(test* "let-optionals*" '(0 1 2 (3)) '(oof* 0 1 2 3))
(test* "let-optionals*" '(0 1 2 (3 4)) '(oof* 0 1 2 3 4))

(define (oof+ x . args)
  (let ((i 0))
    (let-optionals* (begin (set! i (+ i 1)) args)
        ((a 'a)
         (b 'b)
         (c 'c))
      i)))

(test* "let-optionals*" 1 '(oof+ 0))
(test* "let-optionals*" 1 '(oof+ 0 1))
(test* "let-optionals*" 1 '(oof+ 0 1 2))
(test* "let-optionals*" 1 '(oof+ 0 1 2 3))
(test* "let-optionals*" 1 '(oof+ 0 1 2 3 4))


(total-report)
