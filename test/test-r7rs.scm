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

(tn "number predicates")
(assert-eq? (tn) #t (exact-integer? 1))
(assert-eq? (tn) #f (exact-integer? '()))
(assert-eq? (tn) #t (finite? 1))
(assert-eq? (tn) #f (infinite? 1))
(assert-eq? (tn) #f (nan? 1))
(assert-error (tn) (lambda () (finite? 'a)))

(tn "floor/ and truncate/")
(assert-equal? (tn) '(2 1) (call-with-values (lambda () (floor/ 5 2)) list))
(assert-equal? (tn) '(-3 1) (call-with-values (lambda () (floor/ -5 2)) list))
(assert-equal? (tn) '(-3 -1) (call-with-values (lambda () (floor/ 5 -2)) list))
(assert-equal? (tn) '(2 -1) (call-with-values (lambda () (floor/ -5 -2)) list))
(assert-equal? (tn) '(2 0) (call-with-values (lambda () (floor/ 4 2)) list))
(assert-equal? (tn) -3 (floor-quotient -5 2))
(assert-equal? (tn) 1 (floor-remainder -5 2))
(assert-equal? (tn) '(2 1) (call-with-values (lambda () (truncate/ 5 2)) list))
(assert-equal? (tn) '(-2 -1)
               (call-with-values (lambda () (truncate/ -5 2)) list))
(assert-equal? (tn) '(-2 1)
               (call-with-values (lambda () (truncate/ 5 -2)) list))
(assert-equal? (tn) '(2 -1)
               (call-with-values (lambda () (truncate/ -5 -2)) list))
(assert-equal? (tn) -2 (truncate-quotient -5 2))
(assert-equal? (tn) -1 (truncate-remainder -5 2))
(assert-error (tn) (lambda () (floor/ 1 0)))
(assert-error (tn) (lambda () (floor-quotient 1 0)))
(assert-error (tn) (lambda () (floor-remainder 1 0)))
(assert-error (tn) (lambda () (truncate/ 1 0)))
(assert-error (tn) (lambda () (truncate-quotient 1 0)))
(assert-error (tn) (lambda () (truncate-remainder 1 0)))

(tn "square")
(assert-equal? (tn) 0 (square 0))
(assert-equal? (tn) 1764 (square 42))
(assert-equal? (tn) 4 (square -2))

(tn "exact-integer-sqrt")
(for-each (lambda (k expected)
            (assert-equal? (tn)
                           expected
                           (call-with-values
                               (lambda () (exact-integer-sqrt k))
                             list)))
          '(0 1 2 3 4 5 8 9 10 17 32 99 100)
          '((0 0) (1 0) (1 1) (1 2) (2 0) (2 1) (2 4) (3 0) (3 1) (4 1)
            (5 7) (9 18) (10 0)))
(assert-error (tn) (lambda () (exact-integer-sqrt -1)))

(tn "exactness")
(assert-equal? (tn) 1 (exact 1))
(assert-error (tn) (lambda () (inexact 1)))

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

(tn "string comparisons")
(assert-eq? (tn) #t (string=? "a" "a" "a"))
(assert-eq? (tn) #f (string=? "a" "a" "b"))
(assert-eq? (tn) #t (string<? "a" "b" "c"))
(assert-eq? (tn) #f (string<? "a" "c" "b"))
(assert-eq? (tn) #t (string>? "c" "b" "a"))
(assert-eq? (tn) #t (string<=? "a" "a" "b"))
(assert-eq? (tn) #f (string<=? "a" "b" "a"))
(assert-eq? (tn) #t (string>=? "b" "b" "a"))
(assert-eq? (tn) #t (string-ci=? "a" "A" "a"))
(assert-eq? (tn) #t (string-ci<? "a" "B" "c"))
(assert-eq? (tn) #t (string-ci>? "C" "b" "A"))
(assert-eq? (tn) #t (string-ci<=? "a" "A" "b"))
(assert-eq? (tn) #t (string-ci>=? "b" "B" "a"))
(assert-error (tn) (lambda () (string=? "a" "a" 'a)))

(tn "string->list")
(assert-equal? (tn) '(#\a #\b #\c) (string->list "abc"))
(assert-equal? (tn) '(#\b #\c) (string->list "abc" 1))
(assert-equal? (tn) '(#\b) (string->list "abc" 1 2))
(assert-error (tn) (lambda () (string->list "abc" 2 1)))

(tn "string-copy")
(assert-equal? (tn) "abc" (string-copy "abc"))
(assert-equal? (tn) "bc" (string-copy "abc" 1))
(assert-equal? (tn) "b" (string-copy "abc" 1 2))
(assert-equal? (tn) "" (string-copy "abc" 3))
(assert-error (tn) (lambda () (string-copy "abc" 4)))

(tn "string-copy!")
(let ((str (string-copy "abcde")))
  (string-copy! str 1 "12")
  (assert-equal? (tn) "a12de" str))
(let ((str (string-copy "abcde")))
  (string-copy! str 0 "123" 1 3)
  (assert-equal? (tn) "23cde" str))
(let ((str (string-copy "abcde")))
  (string-copy! str 1 str 0 3)
  (assert-equal? (tn) "aabce" str))
(let ((str (string-copy "abcde")))
  (string-copy! str 0 str 2)
  (assert-equal? (tn) "cdede" str))
(assert-error (tn) (lambda () (string-copy! (string-copy "ab") 1 "xy")))
(assert-error (tn) (lambda () (string-copy! (string-copy "ab") -1 "x")))

(tn "string-fill!")
(let ((str (string-copy "abcde")))
  (string-fill! str #\x)
  (assert-equal? (tn) "xxxxx" str))
(let ((str (string-copy "abcde")))
  (string-fill! str #\x 3)
  (assert-equal? (tn) "abcxx" str))
(let ((str (string-copy "abcde")))
  (string-fill! str #\x 1 3)
  (assert-equal? (tn) "axxde" str))
(assert-error (tn) (lambda () (string-fill! (string-copy "ab") #\x 3)))
(assert-error (tn) (lambda () (string-fill! (string-copy "ab") 'x)))

(tn "string-map")
(assert-equal? (tn) "ABC" (string-map char-upcase "abc"))
(assert-equal? (tn) "" (string-map char-upcase ""))
(assert-equal? (tn)
               "bd"
               (string-map (lambda (c1 c2)
                             (if (char<? c1 c2) c2 c1))
                           "abc" "bd"))
(assert-error (tn) (lambda () (string-map char-upcase 'abc)))
(assert-error (tn) (lambda () (string-map 'x "abc")))

(tn "string-for-each")
(let ((chars '()))
  (string-for-each (lambda (c) (set! chars (cons c chars))) "abc")
  (assert-equal? (tn) '(#\c #\b #\a) chars))
(let ((pairs '()))
  (string-for-each (lambda (c1 c2) (set! pairs (cons (list c1 c2) pairs)))
                   "abc" "xy")
  (assert-equal? (tn) '((#\b #\y) (#\a #\x)) pairs))

(tn "vector->list")
(assert-equal? (tn) '(a b c) (vector->list #(a b c)))
(assert-equal? (tn) '(b c) (vector->list #(a b c) 1))
(assert-equal? (tn) '(b) (vector->list #(a b c) 1 2))
(assert-equal? (tn) '() (vector->list #(a b c) 3))
(assert-error (tn) (lambda () (vector->list #(a b c) 4)))
(assert-error (tn) (lambda () (vector->list #(a b c) 2 1)))
(assert-error (tn) (lambda () (vector->list #(a b c) -1)))
(assert-error (tn) (lambda () (vector->list #(a b c) 'a)))
(assert-error (tn) (lambda () (vector->list #(a b c) 0 1 2)))

(tn "vector->string")
(assert-equal? (tn) "" (vector->string #()))
(assert-equal? (tn) "abc" (vector->string #(#\a #\b #\c)))
(assert-equal? (tn) "bc" (vector->string #(#\a #\b #\c) 1))
(assert-equal? (tn) "b" (vector->string #(#\a #\b #\c) 1 2))
(assert-error (tn) (lambda () (vector->string #(1))))

(tn "string->vector")
(assert-equal? (tn) #() (string->vector ""))
(assert-equal? (tn) #(#\a #\b #\c) (string->vector "abc"))
(assert-equal? (tn) #(#\b #\c) (string->vector "abc" 1))
(assert-equal? (tn) #(#\b) (string->vector "abc" 1 2))
(assert-error (tn) (lambda () (string->vector "abc" 4)))

(tn "vector-copy")
(assert-equal? (tn) #() (vector-copy #()))
(assert-equal? (tn) #(a b c) (vector-copy #(a b c)))
(assert-equal? (tn) #(b c) (vector-copy #(a b c) 1))
(assert-equal? (tn) #(b) (vector-copy #(a b c) 1 2))
(let* ((vec (vector 1 2 3))
       (copy (vector-copy vec)))
  (vector-set! copy 0 'x)
  (assert-equal? (tn) #(1 2 3) vec))

(tn "vector-copy!")
(let ((vec (vector 1 2 3 4 5)))
  (vector-copy! vec 1 #(a b))
  (assert-equal? (tn) #(1 a b 4 5) vec))
(let ((vec (vector 1 2 3 4 5)))
  (vector-copy! vec 0 #(a b c) 1 3)
  (assert-equal? (tn) #(b c 3 4 5) vec))
(let ((vec (vector 1 2 3 4 5)))
  (vector-copy! vec 1 vec 0 3)
  (assert-equal? (tn) #(1 1 2 3 5) vec))
(let ((vec (vector 1 2 3 4 5)))
  (vector-copy! vec 0 vec 2)
  (assert-equal? (tn) #(3 4 5 4 5) vec))
(assert-error (tn) (lambda () (vector-copy! (vector 1 2) 1 #(a b))))
(assert-error (tn) (lambda () (vector-copy! (vector 1 2) -1 #(a))))

(tn "vector-append")
(assert-equal? (tn) #() (vector-append))
(assert-equal? (tn) #() (vector-append #() #()))
(assert-equal? (tn) #(a b c) (vector-append #(a) #() #(b c)))
(assert-error (tn) (lambda () (vector-append #(a) '(b))))

(tn "vector-fill!")
(let ((vec (vector 1 2 3 4 5)))
  (vector-fill! vec 'x)
  (assert-equal? (tn) #(x x x x x) vec))
(let ((vec (vector 1 2 3 4 5)))
  (vector-fill! vec 'x 3)
  (assert-equal? (tn) #(1 2 3 x x) vec))
(let ((vec (vector 1 2 3 4 5)))
  (vector-fill! vec 'x 1 3)
  (assert-equal? (tn) #(1 x x 4 5) vec))
(assert-error (tn) (lambda () (vector-fill! (vector 1 2) 'x 3)))

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
                      (string-upcase (string-append "a" alpha "b"))))
      (tn "string mutation with non-ASCII characters")
      (let ((str (string-copy "abc")))
        (string-fill! str (integer->char #x3b1) 1 2)
        (assert-equal? (tn) (string-append "a" alpha "c") str))
      (let ((str (string-append "a" alpha "c")))
        (string-copy! str 1 "b")
        (assert-equal? (tn) "abc" str))
      (let ((str (string-copy "abcd")))
        (string-copy! str 1 (string-append alpha capital-alpha))
        (assert-equal? (tn) (string-append "a" alpha capital-alpha "d") str)
        (assert-equal? (tn) 4 (string-length str)))))

(total-report)
