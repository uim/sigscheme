#! /usr/bin/env sscm -C UTF-8

;;  Filename : test-string-core.scm
;;  About    : unit test for core procedures of R5RS string
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

(if (not (symbol-bound? 'string?))
    (test-skip-file "R5RS core string procedures are not enabled"))

(if (not (provided? "r6rs-chars"))
    (test-skip-file "R6RS characters is not enabled"))

(test-begin "test-string-core")
(define cp string-copy)

(if (and (provided? "sigscheme")
         (not (symbol-bound? 'string?)))
    (test-skip-file "core string part of R5RS is not enabled"))

;;
;; All procedures that take a string as argument are tested with
;; both immutable and mutable string.
;;
;; See "3.4 Storage model" of R5RS
;;


(test-begin "string?")
(test-eq #f (string? #f))
(test-eq #f (string? #t))
(test-eq #f (string? '()))
(if (provided? "sigscheme")
    (begin
      (test-eq #f (string? (eof)))
      (test-eq #f (string? (undef)))))
(test-eq #f (string? 0))
(test-eq #f (string? 1))
(test-eq #f (string? 3))
(test-eq #f (string? -1))
(test-eq #f (string? -3))
(test-eq #f (string? 'symbol))
(test-eq #f (string? 'SYMBOL))
(test-eq #f (string? #\a))
(test-eq #f (string? #\あ))
;; immutable
(test-eq #t (string? ""))
(test-eq #t (string? " "))
(test-eq #t (string? "a"))
(test-eq #t (string? "A"))
(test-eq #t (string? "aBc12!"))
(test-eq #t (string? "あ"))
(test-eq #t (string? "あ0イう12!"))
;; mutable
(test-eq #t (string? (cp "")))
(test-eq #t (string? (cp " ")))
(test-eq #t (string? (cp "a")))
(test-eq #t (string? (cp "A")))
(test-eq #t (string? (cp "aBc12!")))
(test-eq #t (string? (cp "あ")))
(test-eq #t (string? (cp "あ0イう12!")))
(test-eq #f (string? +))
(test-eq #f (string? (lambda () #t)))

;; syntactic keywords should not be appeared as operand
(if sigscheme?
    (begin
      ;; pure syntactic keyword
      (test-error (string? else))
      ;; expression keyword
      (test-argcheck-error (string? do))))

(call-with-current-continuation
 (lambda (k)
   (test-eq #f (string? k))))
(test-eq #f (string? (current-output-port)))
(test-eq #f (string? '(#t . #t)))
(test-eq #f (string? (cons #t #t)))
(test-eq #f (string? '(0 1 2)))
(test-eq #f (string? (list 0 1 2)))
(test-eq #f (string? '#()))
(test-eq #f (string? (vector)))
(test-eq #f (string? '#(0 1 2)))
(test-eq #f (string? (vector 0 1 2)))
(test-end "string?")

(test-begin "string-length invalid objects")
(test-error (string-length #t))
(test-error (string-length #f))
(test-end "string-length invalid objects")
(test-begin "string-length immutable")
(test-equal 0 (string-length ""))
(test-equal 1 (string-length " "))
(test-equal 1 (string-length "a"))
(test-equal 1 (string-length "A"))
(test-equal 5 (string-length "abcde"))
(test-equal 6 (string-length "aBc12!"))
(if (and (provided? "sigscheme")
         (not (provided? "utf-8")))
    (begin
      (test-equal 3 (string-length "あ"))
      (test-equal 13 (string-length "あ0イう12!")))
    (begin
      (test-equal 1 (string-length "あ"))
      (test-equal 7 (string-length "あ0イう12!"))))
(test-equal 1 (string-length "\""))
(test-equal 2 (string-length "\"\""))
(test-equal 3 (string-length "\"\\\""))
(test-equal 4 (string-length "\\\"\\\""))
(test-equal 1 (string-length "\\"))
(test-equal 2 (string-length "\\\\"))
(test-equal 3 (string-length "\\\\\\"))
(test-end "string-length immutable")
(test-begin "string-length mutable")
(test-equal 0 (string-length (cp "")))
(test-equal 1 (string-length (cp " ")))
(test-equal 1 (string-length (cp "a")))
(test-equal 1 (string-length (cp "A")))
(test-equal 5 (string-length (cp "abcde")))
(test-equal 6 (string-length (cp "aBc12!")))
(if (and (provided? "sigscheme")
         (not (provided? "utf-8")))
    (begin
      (test-equal 3 (string-length (cp "あ")))
      (test-equal 13 (string-length (cp "あ0イう12!"))))
    (begin
      (test-equal 1 (string-length (cp "あ")))
      (test-equal 7 (string-length (cp "あ0イう12!")))))
(test-equal 1 (string-length (cp "\"")))
(test-equal 2 (string-length (cp "\"\"")))
(test-equal 3 (string-length (cp "\"\\\"")))
(test-equal 4 (string-length (cp "\\\"\\\"")))
(test-equal 1 (string-length (cp "\\")))
(test-equal 2 (string-length (cp "\\\\")))
(test-equal 3 (string-length (cp "\\\\\\")))
(test-end "string-length mutable")

(test-begin "string=? invalid objects")
(test-error (string=? "" #f))
(test-error (string=? "" #t))
(test-error (string=? #f ""))
(test-error (string=? #t ""))
(test-end "string=? invalid objects")
(test-begin "string=? immutable")
(test-assert (string=? "" ""))
(test-assert (string=? " " " "))
(test-assert (not (string=? "" " ")))
(test-assert (not (string=? " " "")))
(test-assert (string=? "a" "a"))
(test-assert (string=? "A" "A"))
(test-assert (not (string=? "A" "a")))
(test-assert (not (string=? "a" "A")))
(test-assert (string=? "\"" "\""))
(test-assert (string=? "\\" "\\"))
(test-assert (string=? "\\\\" "\\\\"))
(test-assert (string=? "aBc12!" "aBc12!"))
(test-assert (not (string=? "aBc12!" "aBc12")))
(test-assert (not (string=? "aBc12!" "aBC12!")))
(test-assert (not (string=? "aBc12" "aBc12!")))
(test-assert (not (string=? "aBC12!" "aBc12!")))
(test-assert (string=? "abcde" "abcde"))
(test-assert (string=? "foo" "foo"))
(test-assert (string=? "foo" (symbol->string 'foo)))
(test-assert (string=? (symbol->string 'foo) "foo"))
(test-assert (string=? (symbol->string 'foo) (symbol->string 'foo)))
;; identical strings
(let ((s1 "")
      (s2 "aBc12!"))
  (test-assert (string=? s1 s1))
  (test-assert (string=? s2 s2)))
(test-end "string=? immutable")
(test-begin "string=? mutable")
(test-assert (string=? (cp "") (cp "")))
(test-assert (string=? (cp " ") (cp " ")))
(test-assert (not (string=? (cp "") (cp " "))))
(test-assert (not (string=? (cp " ") (cp ""))))
(test-assert (string=? (cp "a") (cp "a")))
(test-assert (string=? (cp "A") (cp "A")))
(test-assert (not (string=? (cp "A") (cp "a"))))
(test-assert (not (string=? (cp "a") (cp "A"))))
(test-assert (string=? (cp "\"") (cp "\"")))
(test-assert (string=? (cp "\\") (cp "\\")))
(test-assert (string=? (cp "\\\\") (cp "\\\\")))
(test-assert (string=? (cp "aBc12!") (cp "aBc12!")))
(test-assert (not (string=? (cp "aBc12!") (cp "aBc12"))))
(test-assert (not (string=? (cp "aBc12!") (cp "aBC12!"))))
(test-assert (not (string=? (cp "aBc12") (cp "aBc12!"))))
(test-assert (not (string=? (cp "aBC12!") (cp "aBc12!"))))
(test-assert (string=? (cp "abcde") (cp "abcde")))
(test-assert (string=? (cp "foo") (cp "foo")))
(test-assert (string=? (cp "foo") (symbol->string 'foo)))
(test-assert (string=? (symbol->string 'foo) (cp "foo")))
(test-assert (string=? (symbol->string 'foo) (symbol->string 'foo)))
;; identical strings
(let ((s1 (cp ""))
      (s2 (cp "aBc12!")))
  (test-assert (string=? s1 s1))
  (test-assert (string=? s2 s2)))
(test-end "string=? mutable")
(test-begin "string=? mixed")
(test-assert (string=? (cp "") ""))
(test-assert (string=? (cp "foo") "foo"))
(test-assert (string=? (cp "foo") (symbol->string 'foo)))
(test-end "string=? mixed")

(test-begin "string-append immutable")
(test-equal ""       (string-append))
(test-equal 0 (string-length (string-append)))
(test-equal ""       (string-append ""))
(test-equal ""       (string-append "" ""))
(test-equal ""       (string-append "" "" ""))
(test-equal 0 (string-length (string-append "" "" "")))
(test-equal "a"      (string-append "a"))
(test-equal "ab"     (string-append "a" "b"))
(test-equal "abc"    (string-append "a" "b" "c"))
(test-equal 3 (string-length (string-append "a" "b" "c")))
(test-equal "ab"     (string-append "ab"))
(test-equal "abcd"   (string-append "ab" "cd"))
(test-equal "abcdef" (string-append "ab" "cd" "ef"))
(test-equal 6 (string-length (string-append "ab" "cd" "ef")))
(test-equal "あ0イう12!" (string-append "あ0" "イ" "う12!"))
(if (and (provided? "sigscheme")
         (not (provided? "utf-8")))
    (test-equal 13 (string-length (string-append "あ0" "イ" "う12!")))
    (test-equal 7 (string-length (string-append "あ0" "イ" "う12!"))))
(let ((s1 "")
      (s2 "a")
      (s3 "aBc12!"))
  (test-equal "" (string-append s1))
  (test-assert (string=? "" (string-append s1)))
  (test-assert (not (eq? "" (string-append s1))))
  (test-equal "a" (string-append s2))
  (test-assert (string=? "a" (string-append s2)))
  (test-assert (not (eq? "a" (string-append s2))))
  (test-equal "aBc12!" (string-append s3))
  (test-assert (string=? "aBc12!" (string-append s3)))
  (test-assert (not (eq? "aBc12!" (string-append s3)))))
(test-end "string-append immutable")
(test-begin "string-append mutable")
(test-equal ""       (string-append (cp "")))
(test-equal ""       (string-append (cp "") (cp "")))
(test-equal ""       (string-append (cp "") (cp "") (cp "")))
(test-equal 0 (string-length (string-append (cp "") (cp "") (cp ""))))
(test-equal "a"      (string-append (cp "a")))
(test-equal "ab"     (string-append (cp "a") (cp "b")))
(test-equal "abc"    (string-append (cp "a") (cp "b") (cp "c")))
(test-equal 3
            (string-length (string-append (cp "a") (cp "b") (cp "c"))))
(test-equal "ab"     (string-append (cp "ab")))
(test-equal "abcd"   (string-append (cp "ab") (cp "cd")))
(test-equal "abcdef" (string-append (cp "ab") (cp "cd") (cp "ef")))
(test-equal 6
            (string-length (string-append (cp "ab") (cp "cd") (cp "ef"))))
(test-equal "あ0イう12!"
            (string-append (cp "あ0") (cp "イ") (cp "う12!")))
(if (and (provided? "sigscheme")
         (not (provided? "utf-8")))
    (test-equal 13 (string-length
                    (string-append (cp "あ0") (cp "イ") (cp "う12!"))))
    (test-equal 7 (string-length
                   (string-append (cp "あ0") (cp "イ") (cp "う12!")))))
(test-end "string-append mutable")
(test-begin "string-append mixed")
(test-equal ""    (string-append (cp "") ""))
(test-equal 0 (string-length (string-append (cp "") "")))
(test-equal "ab"  (string-append (cp "a") "b"))
(test-equal "abc" (string-append "a" (cp "b") (cp "c")))
(test-equal "abc" (string-append (cp "a") "b" (cp "c")))
(test-equal "abc" (string-append (cp "a") (cp "b") "c"))
(test-equal "abc" (string-append "a" "b" (cp "c")))
(test-equal "abc" (string-append "a" (cp "b") "c"))
(test-equal "abc" (string-append (cp "a") "b" "c"))
(test-equal 3 (string-length (string-append (cp "a") "b" "c")))
(test-equal "あ0イう12!"
            (string-append "あ0" (cp "イ") (cp "う12!")))
(test-equal 3 (string-length (string-append (cp "a") "b" "c")))
(if (and (provided? "sigscheme")
         (not (provided? "utf-8")))
    (test-equal 13 (string-length
                    (string-append "あ0" (cp "イ") (cp "う12!"))))
    (test-equal 7 (string-length
                   (string-append "あ0" (cp "イ") (cp "う12!")))))
(test-end "string-append mixed")

(test-begin "string-copy")
(let* ((s1 "")
       (s2 "aBc12!")
       (s3 (string-copy s2)))
  (test-assert (not (eq? s1 (string-copy s1))))
  (test-assert (string=? "" (string-copy s1)))
  (test-equal "" (string-copy s1))
  (if (symbol-bound? 'string-set!)
      (test-error (string-set! s1 0 #\z)))
  (test-assert (not (eq? s2 (string-copy s2))))
  (test-assert (string=? "aBc12!" (string-copy s2)))
  (test-equal "aBc12!" (string-copy s2))
  (if (symbol-bound? 'string-set!)
      (begin
        (test-error (string-set! s2 0 #\z))
        (string-set! s3 0 #\z)
        (test-assert (string=? "zBc12!" s3))
        (test-assert (string=? s3 "zBc12!"))
        (test-equal "zBc12!" s3)
        (test-equal s3 "zBc12!"))))
(test-end "string-copy")


(test-end "test-string-core")
