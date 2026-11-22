;;  Filename : test-srfi180.scm
;;  About    : Unit tests for SRFI-180 JSON
;;
;;  Copyright (c) 2026 SigScheme Project https://github.com/uim/sigscheme
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
(require-extension (srfi 6 180))

(test-begin "test-srfi180")

(define (read-json str)
  (json-read (open-input-string str)))

(define (write-json obj)
  (let ((port (open-output-string)))
    (json-write obj port)
    (get-output-string port)))

(define (json-error-reason-of thunk)
  (guard (err ((json-error? err) (json-error-reason err)))
    (thunk)
    #f))

(define (test-json-error str)
  (test-assert (string? (json-error-reason-of
                         (lambda () (read-json str))))))

(define (generator->list generator)
  (let loop ((objs '()))
    (let ((obj (generator)))
      (if (eof-object? obj)
          (reverse objs)
          (loop (cons obj objs))))))

;; A generator of the characters in STR.
(define (string-generator str)
  (let ((chars (string->list str)))
    (lambda ()
      (if (null? chars)
          (read-char (open-input-string ""))
          (let ((c (car chars)))
            (set! chars (cdr chars))
            c)))))

(test-begin "json-read literals")
(test-equal 'null (read-json "null"))
(test-equal #t (read-json "true"))
(test-equal #f (read-json "false"))
(test-assert (json-null? (read-json "null")))
(test-assert (not (json-null? #f)))
(test-json-error "nul")
(test-json-error "True")
(test-end "json-read literals")

(test-begin "json-read numbers")
(test-equal 0 (read-json "0"))
(test-equal 0 (read-json "-0"))
(test-equal 42 (read-json "42"))
(test-equal -42 (read-json "-42"))
(test-equal 2.5 (read-json "2.5"))
(test-equal -0.25 (read-json "-25e-2"))
(test-equal 1000.0 (read-json "1E3"))
(test-equal 1000.0 (read-json "1e+3"))
(test-assert (inexact? (read-json "12345678901234567890")))
(test-json-error "01")
(test-json-error "+1")
(test-json-error ".5")
(test-json-error "1.")
(test-json-error "1e")
(test-json-error "-")
(test-end "json-read numbers")

(test-begin "json-read strings")
(test-equal "" (read-json "\"\""))
(test-equal "abc" (read-json "\"abc\""))
(test-equal "\"\\/\b\f\n\r\t"
       (read-json "\"\\\"\\\\\\/\\b\\f\\n\\r\\t\""))
(test-equal "A~" (read-json "\"\\u0041\\u007e\""))
(test-json-error "\"abc")
(test-json-error "\"\\x\"")
(test-json-error "\"\\u00g0\"")
(test-json-error (string #\" (integer->char 1) #\"))
(if (equal? (%%current-char-codec) "UTF-8")
    (begin
      (test-equal (string (integer->char #x3042))
             (read-json "\"\\u3042\""))
      (test-equal (string (integer->char #x1f600))
             (read-json "\"\\ud83d\\ude00\""))
      (test-json-error "\"\\ud83d\"")
      (test-json-error "\"\\ude00\""))
    (test-json-error "\"\\u3042\""))
(test-end "json-read strings")

(test-begin "json-read arrays")
(test-equal '#() (read-json "[]"))
(test-equal '#(1 "a" #(null)) (read-json " [ 1 , \"a\" ,[null] ] "))
(test-json-error "[")
(test-json-error "[1")
(test-json-error "[1,]")
(test-json-error "[,1]")
(test-json-error "[1 2]")
(test-json-error "[1}")
(test-end "json-read arrays")

(test-begin "json-read objects")
(test-equal '() (read-json "{}"))
(test-equal '((a . 1) (b . #(#t)) (c . ((d . null))))
       (read-json "{\"a\": 1, \"b\": [true], \"c\": {\"d\": null}}"))
(test-json-error "{")
(test-json-error "{\"a\"}")
(test-json-error "{\"a\" 1}")
(test-json-error "{\"a\": 1,}")
(test-json-error "{a: 1}")
(test-json-error "{\"a\": 1]")
(test-end "json-read objects")

(test-begin "json-read toplevel")
(test-assert (eof-object? (read-json "")))
(test-assert (eof-object? (read-json "  \n")))
(let ((port (open-input-string "1 [2] {\"a\": 3}")))
  (test-equal 1 (json-read port))
  (test-equal '#(2) (json-read port))
  (test-equal '((a . 3)) (json-read port))
  (test-assert (eof-object? (json-read port))))
(test-equal '#(1 2) (json-read (string-generator "[1, 2]")))
(test-end "json-read toplevel")

(test-begin "json-generator")
(test-equal '(42)
       (generator->list
        (json-generator (open-input-string "42 101 1337"))))
(test-equal '(array-start 42 array-end)
       (generator->list
        (json-generator (open-input-string "[42] 101 1337"))))
(test-equal '(object-start "a" array-start 1 array-end "b" null
              object-end)
       (generator->list
        (json-generator (string-generator
                         "{\"a\": [1], \"b\": null}"))))
(test-end "json-generator")

(test-begin "json-fold")
(test-equal '(#(1 #(2 3)) . 0)
       (json-fold cons
                  (lambda (seed) '())
                  (lambda (seed) (list->vector (reverse seed)))
                  (lambda (seed) '())
                  (lambda (seed) (reverse seed))
                  0
                  (open-input-string "[1, [2, 3]]")))
;; The sum of each array is added to the outer seed.
(test-equal 6
       (json-fold +
                  (lambda (seed) 0)
                  (lambda (seed) seed)
                  (lambda (seed) 0)
                  (lambda (seed) seed)
                  0
                  (open-input-string "[1, [2, 3]]")))
(test-end "json-fold")

(test-begin "json-lines-read")
(test-equal '(1 ((a . 2)) #(3))
       (generator->list
        (json-lines-read
         (open-input-string "1\n{\"a\": 2}\n\n[3]\n"))))
(test-equal '(1 2)
       (generator->list (json-lines-read (string-generator "1\n2"))))
(test-end "json-lines-read")

(test-begin "json-sequence-read")
(let ((rs (string (integer->char 30))))
  (test-equal '(1 #(2) "3")
         (generator->list
          (json-sequence-read
           (open-input-string
            (string-append rs "1\n" rs "[2]\n" rs "\"3\"\n"))))))
(test-end "json-sequence-read")

(test-begin "limits")
;; Parameters can be changed only with R7RS.
(if (symbol-bound? 'parameterize)
    (let ((read-with-limits
           (lambda (depth n-chars str)
             (eval (list 'parameterize
                         (list (list 'json-nesting-depth-limit depth)
                               (list 'json-number-of-character-limit n-chars))
                         (list 'json-read (list 'open-input-string str)))
                   (interaction-environment)))))
      (test-equal '#(#(1)) (read-with-limits 2 +inf.0 "[[1]]"))
      (test-assert (string? (json-error-reason-of
                             (lambda ()
                               (read-with-limits 1 +inf.0 "[[1]]")))))
      (test-equal '#(1) (read-with-limits +inf.0 3 "[1]"))
      (test-assert (string? (json-error-reason-of
                             (lambda ()
                               (read-with-limits +inf.0 2 "[1]")))))))
(test-equal +inf.0 (json-nesting-depth-limit))
(test-equal +inf.0 (json-number-of-character-limit))
(test-end "limits")

(test-begin "json-write")
(test-equal "null" (write-json 'null))
(test-equal "true" (write-json #t))
(test-equal "false" (write-json #f))
(test-equal "-42" (write-json -42))
(test-equal "2.5" (write-json 2.5))
(test-equal "\"a\\\"\\\\\\n\\t\\r\\b\\f\\u0001\\u001f/\""
       (write-json (string #\a #\" #\\ #\newline #\tab
                           (integer->char 13) (integer->char 8)
                           (integer->char 12) (integer->char 1)
                           (integer->char 31) #\/)))
(test-equal "[]" (write-json '#()))
(test-equal "{}" (write-json '()))
(test-equal "{\"a\":[1,{\"b\":null}],\"c\":\"d\"}"
       (write-json '((a . #(1 ((b . null)))) (c . "d"))))
(test-equal '((a . #(1 2.5 "x" #t #f null)) (b))
       (read-json (write-json '((a . #(1 2.5 "x" #t #f null))
                                (b)))))
(test-end "json-write")

(test-begin "json-write errors")
(define (json-write-error-reason obj)
  (json-error-reason-of (lambda () (write-json obj))))
(test-assert (string? (json-write-error-reason 'foo)))
(test-assert (string? (json-write-error-reason +inf.0)))
(test-assert (string? (json-write-error-reason (- +inf.0 +inf.0))))
(test-assert (string? (json-write-error-reason '(1 2))))
(test-assert (string? (json-write-error-reason '((a . 1) . b))))
(test-assert (string? (json-write-error-reason '(("a" . 1)))))
(test-assert (string? (json-write-error-reason #\a)))
;; Nothing is written on error.
(let ((port (open-output-string)))
  (json-error-reason-of (lambda () (json-write '#(1 foo) port)))
  (test-equal "" (get-output-string port)))
(test-end "json-write errors")

(test-begin "json-accumulator")
(let* ((port (open-output-string))
       (accumulate (json-accumulator port)))
  (for-each accumulate
            '(object-start "a" array-start 1 "b" array-end object-end))
  (test-equal "{\"a\":[1,\"b\"]}" (get-output-string port)))
(let* ((strings '())
       (accumulate (json-accumulator
                    (lambda (str) (set! strings (cons str strings))))))
  (for-each accumulate '(array-start 1 2 array-end))
  (test-equal "[1,2]" (apply string-append (reverse strings))))
(define (accumulator-error-reason tokens)
  (json-error-reason-of
   (lambda ()
     (for-each (json-accumulator (open-output-string)) tokens))))
(test-assert (string? (accumulator-error-reason '(array-end))))
(test-assert (string? (accumulator-error-reason
                       '(array-start object-end))))
(test-assert (string? (accumulator-error-reason '(object-start 1))))
(test-assert (string? (accumulator-error-reason
                       '(object-start "a" object-end))))
(test-end "json-accumulator")

(test-end "test-srfi180")
