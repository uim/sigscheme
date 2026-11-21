;;  Filename : test-srfi1-obsolete.scm
;;  About    : unit test for SRFI-1 (obsolete version)
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

(require-extension (srfi 1 8))

(test-begin "test-srfi1-obsolete")

; xcons
(test-equal "xcons test1" '(a b c) (xcons '(b c) 'a))

; cons*
(test-equal "cons* test1" '(1 2 3 . 4) (cons* 1 2 3 4))
(test-equal "cons* test2" 1 (cons* 1))

; make-list
(test-equal "make-list test1" '(c c c c) (make-list 4 'c))
(test-equal "make-list test2" '() (make-list 0 'c))
(test-equal "make-list test3" '() (make-list 0))

; list-tabulate
(test-equal "list-tabulate test1" '(0 1 2 3) (list-tabulate 4 (lambda (x) x)))
(test-equal "list-tabulate test2" '(1 2 3 4) (list-tabulate 4 (lambda (x) (+ x 1))))
(test-equal "list-tabulate test3" '() (list-tabulate 0 (lambda (x) (+ x 1))))

; list-copy
(test-equal "list-copy test1" '(1 2 3 4) (list-copy (list 1 2 3 4)))
(test-equal "list-copy test2" '(1 2 (3 4)) (list-copy (list 1 2 (list 3 4))))
(test-equal "list-copy test3" '() (list-copy '()))

; iota
(test-equal "iota test1" '(0 1 2 3 4) (iota 5))
(test-equal "iota test2" '(1 2 3 4 5) (iota 5 1))
(test-equal "iota test3" '(1 2 3 4 5) (iota 5 1 1))
(test-equal "iota test4" '(1 3 5 7 9) (iota 5 1 2))
(test-equal "iota test5" '() (iota 0))
(test-equal "iota test6" '(-1 0 1) (iota 3 -1 1))
(test-equal "iota test7" '(-3 -1 1 3) (iota 4 -3 2))

; list=
(test-assert "list= test 1" (list= eq?))
(test-assert "list= test 2" (list= eq? '(a)))
(test-assert "list= test 3" (list= equal? '("a" "i" "u") '("a" "i" "u")))
(test-assert "list= test 4" (not (list= equal? '("a" "i" "u") '("a" "i" "e"))))
(test-assert "list= test 5" (not (list= eqv? '("a" "i" "u") '("a" "i" "u"))))
(test-assert "list= test 6" (list= equal? '("a" "i" "u") '("a" "i" "u") '("a" "i" "u")))
(test-assert "list= test 7" (not (list= equal? '("a" "i" "u") '("a" "i" "u") '("a" "i" "e"))))

(define proper-lst '(1 2 3 4 5))
(define circular-lst (circular-list 1 2 3 4 5))
(define dotted-lst '(1 2 3 4 . 5))
(define null-lst '())
; proper-list?
(test-assert "proper-list? test 1" (proper-list? proper-lst))
(test-assert "proper-list? test 2" (not (proper-list? circular-lst)))
(test-assert "proper-list? test 3" (not (proper-list? dotted-lst)))
(test-assert "proper-list? test 4" (proper-list? null-lst))
; circular-list?
(test-assert "circular-list? test 1" (not (circular-list? proper-lst)))
(test-assert "circular-list? test 2" (circular-list? circular-lst))
(test-assert "circular-list? test 3" (not (circular-list? dotted-lst)))
(test-assert "circular-list? test 4" (not (circular-list? null-lst)))
; dotted-list?
(test-assert "circular-list? test 1" (not (circular-list? proper-lst)))
(test-assert "circular-list? test 2" (circular-list? circular-lst))
(test-assert "circular-list? test 3" (not (circular-list? dotted-lst)))
(test-assert "circular-list? test 4" (not (circular-list? null-lst)))
; not-pair?
(test-assert "not-pair? test 1" (not (not-pair? proper-lst)))
(test-assert "not-pair? test 2" (not (not-pair? circular-lst)))
(test-assert "not-pair? test 3" (not (not-pair? dotted-lst)))
(test-assert "not-pair? test 4" (not-pair? null-lst))
; null-list?
(test-assert "null-list? test 1" (not (null-list? proper-lst)))
;; It is an error to pass this procedure a value which is not a proper or
;; circular list.
;;(test-assert "null-list? test 2" (not (null-list? circular-lst)))
;;(test-error "null-list? test 3" #t (null-list? dotted-lst))
(test-assert "null-list? test 4" (null-list? null-lst))

(define num-lst (iota 10 1))
; first
(test-equal "first test" 1 (first num-lst))
; second
(test-equal "second test" 2 (second num-lst))
; third
(test-equal "third test" 3 (third num-lst))
; fourth
(test-equal "fourth test" 4 (fourth num-lst))
; fifth
(test-equal "fifth test" 5 (fifth num-lst))
; sixth
(test-equal "sixth test" 6 (sixth num-lst))
; seventh
(test-equal "seventh test" 7 (seventh num-lst))
; eighth
(test-equal "eighth test" 8 (eighth num-lst))
; ninth
(test-equal "ninth test" 9 (ninth num-lst))
; tenth
(test-equal "tenth test" 10 (tenth num-lst))

; take
(test-equal "take test 1" '(a b) (take '(a b c d e) 2))
(test-equal "take test 2" '(1 2) (take '(1 2 3 . d) 2))
(test-equal "take test 3" '(1 2 3) (take '(1 2 3 . d) 3))

; drop
(test-equal "drop test 1" '(c d e) (drop '(a b c d e) 2))
(test-equal "drop test 2" '(3 . d) (drop '(1 2 3 . d) 2))
(test-equal "drop test 3" 'd (drop '(1 2 3 . d) 3))

; take-right
(test-equal "take-right test 1" '(d e) (take-right '(a b c d e) 2) )
(test-equal "take-right test 2" '(2 3 . d) (take-right '(1 2 3 . d) 2) )
(test-equal "take-right test 3" 'd (take-right '(1 2 3 . d) 0) )

; drop-right
(test-equal "drop-right test 1" '(a b c) (drop-right '(a b c d e) 2))
(test-equal "drop-right test 2" '(1) (drop-right '(1 2 3 . d) 2))
(test-equal "drop-right test 3" '(1 2 3) (drop-right '(1 2 3 . d) 0))

; take!
;; Commented out invalid tests -- YamaKen 2007-08-07
;;(test-equal "take! test 1" '(a b) (take! '(a b c d e) 2))
;;(test-equal "take! test 2" '(1 2) (take! '(1 2 3 . d) 2))
;;(test-equal "take! test 3" '(1 2 3) (take! '(1 2 3 . d) 3))
(test-equal "take! test 4" '(1 3) (take! (circular-list 1 3 5) 8))

; drop-right!
;; Commented out invalid tests -- YamaKen 2007-08-07
;;(test-equal "drop-right! test 1" '(a b c) (drop-right! '(a b c d e) 2))
;;(test-equal "drop-right! test 2" '(1) (drop-right! '(1 2 3 . d) 2))
;;(test-equal "drop-right! test 3" '(1 2 3) (drop-right! '(1 2 3 . d) 0))

; split-at
(receive (former latter)
         (split-at '(1 2 3 4 5 6 7) 3)
         (test-equal "split-at test 1" '(1 2 3) former)
         (test-equal "split-at test 2" '(4 5 6 7) latter))

; split-at!
;; Commented out invalid tests -- YamaKen 2007-08-07
;;(receive (former latter)
;;         (split-at! '(1 2 3 4 5 6 7) 3)
;;         (test-equal "split-at! test 1" '(1 2 3) former)
;;         (test-equal "split-at! test 2" '(4 5 6 7) latter))

; last
(test-equal "last test 1" 'a (last '(a)))
(test-equal "last test 2" 'b (last '(a b)))
(test-equal "last test 3" 'c (last '(a b c)))
(test-equal "last test 4" 'c (last '(a b c . d)))

; last-pair-pair
(test-equal "last-pair test 1" '(a) (last-pair '(a)))
(test-equal "last-pair test 2" '(b) (last-pair '(a b)))
(test-equal "last-pair test 3" '(c) (last-pair '(a b c)))
(test-equal "last-pair test 4" '(c . d) (last-pair '(a b c . d)))

; length+
(test-assert "length+ test 1" (not (length+ circular-lst)))

; concatenate
(test-equal "concatenate test 1" '() (concatenate '(())))
(test-equal "concatenate test 2" '() (concatenate '(() ())))
(test-equal "concatenate test 3" '() (concatenate '(() () ())))
(test-equal "concatenate test 4" '(a) (concatenate '((a))))
(test-equal "concatenate test 5" '(a b) (concatenate '((a) (b))))
(test-equal "concatenate test 6" '(a b c) (concatenate '((a) (b) (c))))
(test-equal "concatenate test 7" '(a b) (concatenate '((a b))))
(test-equal "concatenate test 8" '(a b c d) (concatenate '((a b) (c d))))
(test-equal "concatenate test 9" '(a b c d e f) (concatenate '((a b) (c d) (e f))))


(test-end "test-srfi1-obsolete")
