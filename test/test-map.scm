;;  Filename : test-map.scm
;;  About    : unit tests for R5RS map and for-each
;;
;;  Copyright (C) 2006 YAMAMOTO Kengo <yamaken AT bp.iij4u.or.jp>
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

(test-begin "test-map")

;; R5RS: 6.4 Control features
;; > If more than one list is given, then they must all be the same length.
;; SigScheme rejects such user-error explicitly.
;;
;; R7RS: 6.10 Control features
;; > If more than one list is given and not all lists have the same
;; > length, map terminates when the shortest list runs out.
(define test-uneven
  (if (provided? "r7rs")
      (lambda (expected thunk)
        (test-equal expected (thunk)))
      (lambda (expected thunk)
        (test-error (thunk)))))


;;
;; map
;;

(test-begin "map invalid forms")
(test-error (map))
(test-error (map even?))
(test-end "map invalid forms")

(test-begin "map single-arg invalid forms")
(test-error (map #t '(0 1 2)))
(test-error (map even? '(0 1 2 . 3)))
(test-error (map even? #t))
(test-error (map even? '#(0 1 2)))
(test-error (map even? #f))
(test-end "map single-arg invalid forms")

(test-begin "map single-arg")
;; not applicable
(test-error (map car '(0 1 2)))
;; Evaluation order is unspecified.
(test-assert (let* ((count 0)
                    (res (map (lambda (dummy)
                                (set! count (+ count 1))
                                count)
                              '(a b))))
               (or (equal? res '(1 2))
                   (equal? res '(2 1)))))
;; builtin procedure
(test-equal '()
            (map cadr '()))
(test-equal '(b)
            (map cadr '((a b))))
(test-equal '(b d f h)
            (map cadr '((a b) (c d) (e f) (g h))))
(test-equal '(b d g i)
            (map cadr '((a b) (c d e) (f g) (h i))))
;; closure
(test-equal '()
            (map (lambda (l) (car (cdr l)))
                 '()))
(test-equal '(b)
            (map (lambda (l) (car (cdr l)))
                 '((a b))))
(test-equal '(b d f h)
            (map (lambda (l) (car (cdr l)))
                 '((a b) (c d) (e f) (g h))))
(test-end "map single-arg")

(test-begin "map multiple-args invalid forms")
(test-error (map #t '(0 1 2) '(3 4 5)))
(test-error (map + '(0 1 2 . 3)  '(3 4 5 . 6)))
(test-error (map + '(0 1 2) '(3 4 5) . #t))
(test-error (map + #t #t))
(test-error (map + '#(0 1 2) '#(3 4 5)))
(test-error (map even? #f #f))
(test-end "map multiple-args invalid forms")

(test-begin "map multiple-args")
;; not applicable
(test-error (map car '(0 1 2) '(3 4 5)))
;; Evaluation order is unspecified.
(test-assert (let* ((count 0)
                    (res (map (lambda (dummy1 dummy2 dummy3)
                                (set! count (+ count 1))
                                count)
                              '(a b)
                              '(c d)
                              '(e f))))
               (or (equal? res '(1 2))
                   (equal? res '(2 1)))))

(test-equal '()
            (map cons '() '()))
(test-equal '((0 . 3) (1 . 4) (2 . 5))
            (map cons '(0 1 2) '(3 4 5)))
(test-uneven '((0 . 3) (1 . 4) (2 . 5))
             (lambda () (map cons '(0 1 2) '(3 4 5 6))))
(test-uneven '((0 . 3) (1 . 4))
             (lambda () (map cons '(0 1 2) '(3 4))))
(test-uneven '()
             (lambda () (map cons '(0) '())))
(test-uneven '()
             (lambda () (map cons '() '(0))))

(test-equal '()
            (map +
                 '()
                 '()
                 '()))
(test-uneven '()
             (lambda ()
               (map +
                    '(0)
                    '()
                    '())))
(test-uneven '()
             (lambda ()
               (map +
                    '()
                    '(0)
                    '())))
(test-uneven '()
             (lambda ()
               (map +
                    '()
                    '()
                    '(0))))

(test-equal '(9 12 15)
            (map +
                 '(0 1 2)
                 '(3 4 5)
                 '(6 7 8)))
(test-uneven '(9 12 15)
             (lambda ()
               (map +
                    '(0 1 2 3)
                    '(3 4 5)
                    '(6 7 8))))
(test-uneven '(9 12 15)
             (lambda ()
               (map +
                    '(0 1 2)
                    '(3 4 5 6)
                    '(6 7 8))))
(test-uneven '(9 12 15)
             (lambda ()
               (map +
                    '(0 1 2)
                    '(3 4 5)
                    '(6 7 8 9))))

;; closure
(test-equal '()
            (map (lambda (x y)
                   (cons x y))
                 '()))
(test-equal '((0 . 3) (1 . 4) (2 . 5))
            (map (lambda (x y)
                   (cons x y))
                 '(0 1 2) '(3 4 5)))
(test-equal '()
            (map (lambda (x y z)
                   (+ x y z))
                 '()
                 '()
                 '()))
(test-equal '(9 12 15)
            (map (lambda (x y z)
                   (+ x y z))
                 '(0 1 2)
                 '(3 4 5)
                 '(6 7 8)))
(test-end "map multiple-args")

;;
;; for-each
;;

(test-begin "for-each invalid forms")
(test-error (for-each))
(test-error (for-each even?))
(test-end "for-each invalid forms")

(test-begin "for-each single-arg invalid forms")
(test-error (for-each #t '(0 1 2)))
(test-error (for-each even? '(0 1 2 . 3)))
(test-error (for-each even? #t))
(test-error (for-each even? '#(0 1 2)))
(test-error (for-each even? #f))
(test-end "for-each single-arg invalid forms")

(test-begin "for-each single-arg")
;; not applicable
(test-error (for-each car '(0 1 2)))
;; Evaluation order is guaranteed.
(test-equal '(2 1)
            (let* ((count 0)
                   (res '()))
              (for-each (lambda (dummy)
                          (set! count (+ count 1))
                          (set! res (cons count res)))
                        '(a b))
              res))

;; builtin procedure
(test-equal (undef)
            (for-each cadr '()))
(test-equal (undef)
            (for-each cadr '((a b))))
(test-equal (undef)
            (for-each cadr '((a b) (c d) (e f) (g h))))
(test-equal (undef)
            (for-each cadr '((a b) (c d e) (f g) (h i))))

;; closure
(test-equal (undef)
            (for-each (lambda (l)
                        (car (cdr l)))
                      '()))
(test-equal 'not-modified
            (let ((res 'not-modified))
              (for-each (lambda (l)
                          (set! res (car (cdr l))))
                        '())
              res))

(test-equal (undef)
            (for-each (lambda (l)
                        (car (cdr l)))
                      '((a b))))
(test-equal 'b
            (let ((res 'not-modified))
              (for-each (lambda (l)
                          (set! res (car (cdr l))))
                        '((a b)))
              res))

(test-equal (undef)
            (for-each (lambda (l)
                        (car (cdr l)))
                      '((a b) (c d) (e f) (g h))))
(test-equal '(h f d b)
            (let ((res '()))
              (for-each (lambda (l)
                          (set! res (cons (car (cdr l))
                                          res)))
                        '((a b) (c d) (e f) (g h)))
              res))
(test-end "for-each single-arg")

(test-begin "for-each multiple-args invalid forms")
(test-error (for-each #t '(0 1 2) '(3 4 5)))
(test-error (for-each + '(0 1 2 . 3)  '(3 4 5 . 6)))
(test-error (for-each + '(0 1 2) '(3 4 5) . #t))
(test-error (for-each + #t #t))
(test-error (for-each + '#(0 1 2) '#(3 4 5)))
(test-error (for-each even? #f #f))
(test-end "for-each multiple-args invalid forms")

(test-begin "for-each multiple-args")
;; not applicable
(test-error (for-each car '(0 1 2) '(3 4 5)))
;; Evaluation order is guaranteed.
(test-equal '(2 1)
            (let* ((count 0)
                   (res '()))
              (for-each (lambda (dummy1 dummy2 dummy3)
                          (set! count (+ count 1))
                          (set! res (cons count res)))
                        '(a b)
                        '(c d)
                        '(e f))
              res))

(test-equal (undef)
            (for-each cons '() '()))
(test-equal (undef)
            (for-each cons '(0 1 2) '(3 4 5)))
(test-uneven (undef)
             (lambda () (for-each cons '(0 1 2) '(3 4 5 6))))
(test-uneven (undef)
             (lambda () (for-each cons '(0 1 2) '(3 4))))
(test-uneven (undef)
             (lambda () (for-each cons '(0) '())))
(test-uneven (undef)
             (lambda () (for-each cons '() '(0))))

(test-equal (undef)
            (for-each +
                      '()
                      '()
                      '()))
(test-uneven (undef)
             (lambda ()
               (for-each +
                         '(0)
                         '()
                         '())))
(test-uneven (undef)
             (lambda ()
               (for-each +
                         '()
                         '(0)
                         '())))
(test-uneven (undef)
             (lambda ()
               (for-each +
                         '()
                         '()
                         '(0))))

(test-equal (undef)
            (for-each +
                      '(0 1 2)
                      '(3 4 5)
                      '(6 7 8)))
(test-uneven (undef)
             (lambda ()
               (for-each +
                         '(0 1 2 3)
                         '(3 4 5)
                         '(6 7 8))))
(test-uneven (undef)
             (lambda ()
               (for-each +
                         '(0 1 2)
                         '(3 4 5 6)
                         '(6 7 8))))
(test-uneven (undef)
             (lambda ()
               (for-each +
                         '(0 1 2)
                         '(3 4 5)
                         '(6 7 8 9))))

;; closure
(test-equal (undef)
            (for-each (lambda (x y)
                        (cons x y))
                      '()))
(test-equal 'not-modified
            (let ((res 'not-modified))
              (for-each (lambda (x y)
                          (set! res (cons x y)))
                        '())
              res))

(test-equal (undef)
            (for-each (lambda (x y)
                        (cons x y))
                      '(0 1 2) '(3 4 5)))
(test-equal '((2 . 5) (1 . 4) (0 . 3))
            (let ((res '()))
              (for-each (lambda (x y)
                          (set! res (cons (cons x y)
                                          res)))
                        '(0 1 2) '(3 4 5))
              res))

(test-equal (undef)
            (for-each (lambda (x y z)
                        (+ x y z))
                      '()
                      '()
                      '()))
(test-equal 'not-modified
            (let ((res 'not-modified))
              (for-each (lambda (x y z)
                          (set! res (+ x y z)))
                        '()
                        '()
                        '())
              res))

(test-equal (undef)
            (for-each (lambda (x y z)
                        (+ x y z))
                      '(0 1 2)
                      '(3 4 5)
                      '(6 7 8)))
(test-equal '(15 12 9)
            (let ((res '()))
              (for-each (lambda (x y z)
                          (set! res (cons (+ x y z)
                                          res)))
                        '(0 1 2)
                        '(3 4 5)
                        '(6 7 8))
              res))
(test-end "for-each multiple-args")


(test-end "test-map")
