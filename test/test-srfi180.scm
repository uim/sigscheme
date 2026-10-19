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



(require-extension (unittest) (srfi 6 180))

(define tn test-name)

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

(define (assert-json-error name str)
  (assert-true name (string? (json-error-reason-of
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

(tn "json-read literals")
(assert-equal? (tn) 'null (read-json "null"))
(assert-equal? (tn) #t (read-json "true"))
(assert-equal? (tn) #f (read-json "false"))
(assert-true (tn) (json-null? (read-json "null")))
(assert-false (tn) (json-null? #f))
(assert-json-error (tn) "nul")
(assert-json-error (tn) "True")

(tn "json-read numbers")
(assert-equal? (tn) 0 (read-json "0"))
(assert-equal? (tn) 0 (read-json "-0"))
(assert-equal? (tn) 42 (read-json "42"))
(assert-equal? (tn) -42 (read-json "-42"))
(assert-equal? (tn) 2.5 (read-json "2.5"))
(assert-equal? (tn) -0.25 (read-json "-25e-2"))
(assert-equal? (tn) 1000.0 (read-json "1E3"))
(assert-equal? (tn) 1000.0 (read-json "1e+3"))
(assert-true (tn) (inexact? (read-json "12345678901234567890")))
(assert-json-error (tn) "01")
(assert-json-error (tn) "+1")
(assert-json-error (tn) ".5")
(assert-json-error (tn) "1.")
(assert-json-error (tn) "1e")
(assert-json-error (tn) "-")

(tn "json-read strings")
(assert-equal? (tn) "" (read-json "\"\""))
(assert-equal? (tn) "abc" (read-json "\"abc\""))
(assert-equal? (tn) "\"\\/\b\f\n\r\t"
               (read-json "\"\\\"\\\\\\/\\b\\f\\n\\r\\t\""))
(assert-equal? (tn) "A~" (read-json "\"\\u0041\\u007e\""))
(assert-json-error (tn) "\"abc")
(assert-json-error (tn) "\"\\x\"")
(assert-json-error (tn) "\"\\u00g0\"")
(assert-json-error (tn) (string #\" (integer->char 1) #\"))
(if (equal? (%%current-char-codec) "UTF-8")
    (begin
      (assert-equal? (tn) (string (integer->char #x3042))
                     (read-json "\"\\u3042\""))
      (assert-equal? (tn) (string (integer->char #x1f600))
                     (read-json "\"\\ud83d\\ude00\""))
      (assert-json-error (tn) "\"\\ud83d\"")
      (assert-json-error (tn) "\"\\ude00\""))
    (assert-json-error (tn) "\"\\u3042\""))

(tn "json-read arrays")
(assert-equal? (tn) '#() (read-json "[]"))
(assert-equal? (tn) '#(1 "a" #(null)) (read-json " [ 1 , \"a\" ,[null] ] "))
(assert-json-error (tn) "[")
(assert-json-error (tn) "[1")
(assert-json-error (tn) "[1,]")
(assert-json-error (tn) "[,1]")
(assert-json-error (tn) "[1 2]")
(assert-json-error (tn) "[1}")

(tn "json-read objects")
(assert-equal? (tn) '() (read-json "{}"))
(assert-equal? (tn) '((a . 1) (b . #(#t)) (c . ((d . null))))
               (read-json "{\"a\": 1, \"b\": [true], \"c\": {\"d\": null}}"))
(assert-json-error (tn) "{")
(assert-json-error (tn) "{\"a\"}")
(assert-json-error (tn) "{\"a\" 1}")
(assert-json-error (tn) "{\"a\": 1,}")
(assert-json-error (tn) "{a: 1}")
(assert-json-error (tn) "{\"a\": 1]")

(tn "json-read toplevel")
(assert-true (tn) (eof-object? (read-json "")))
(assert-true (tn) (eof-object? (read-json "  \n")))
(let ((port (open-input-string "1 [2] {\"a\": 3}")))
  (assert-equal? (tn) 1 (json-read port))
  (assert-equal? (tn) '#(2) (json-read port))
  (assert-equal? (tn) '((a . 3)) (json-read port))
  (assert-true (tn) (eof-object? (json-read port))))
(assert-equal? (tn) '#(1 2) (json-read (string-generator "[1, 2]")))

(tn "json-generator")
(assert-equal? (tn) '(42)
               (generator->list
                (json-generator (open-input-string "42 101 1337"))))
(assert-equal? (tn) '(array-start 42 array-end)
               (generator->list
                (json-generator (open-input-string "[42] 101 1337"))))
(assert-equal? (tn) '(object-start "a" array-start 1 array-end "b" null
                      object-end)
               (generator->list
                (json-generator (string-generator
                                 "{\"a\": [1], \"b\": null}"))))

(tn "json-fold")
(assert-equal? (tn) '(#(1 #(2 3)) . 0)
               (json-fold cons
                          (lambda (seed) '())
                          (lambda (seed) (list->vector (reverse seed)))
                          (lambda (seed) '())
                          (lambda (seed) (reverse seed))
                          0
                          (open-input-string "[1, [2, 3]]")))
;; The sum of each array is added to the outer seed.
(assert-equal? (tn) 6
               (json-fold +
                          (lambda (seed) 0)
                          (lambda (seed) seed)
                          (lambda (seed) 0)
                          (lambda (seed) seed)
                          0
                          (open-input-string "[1, [2, 3]]")))

(tn "json-lines-read")
(assert-equal? (tn) '(1 ((a . 2)) #(3))
               (generator->list
                (json-lines-read
                 (open-input-string "1\n{\"a\": 2}\n\n[3]\n"))))
(assert-equal? (tn) '(1 2)
               (generator->list (json-lines-read (string-generator "1\n2"))))

(tn "json-sequence-read")
(let ((rs (string (integer->char 30))))
  (assert-equal? (tn) '(1 #(2) "3")
                 (generator->list
                  (json-sequence-read
                   (open-input-string
                    (string-append rs "1\n" rs "[2]\n" rs "\"3\"\n"))))))

(tn "limits")
;; Parameters can be changed only with R7RS.
(if (symbol-bound? 'parameterize)
    (let ((read-with-limits
           (lambda (depth n-chars str)
             (eval `(parameterize ((json-nesting-depth-limit ,depth)
                                   (json-number-of-character-limit ,n-chars))
                      (json-read (open-input-string ,str)))
                   (interaction-environment)))))
      (assert-equal? (tn) '#(#(1)) (read-with-limits 2 +inf.0 "[[1]]"))
      (assert-true (tn) (string? (json-error-reason-of
                                  (lambda ()
                                    (read-with-limits 1 +inf.0 "[[1]]")))))
      (assert-equal? (tn) '#(1) (read-with-limits +inf.0 3 "[1]"))
      (assert-true (tn) (string? (json-error-reason-of
                                  (lambda ()
                                    (read-with-limits +inf.0 2 "[1]")))))))
(assert-equal? (tn) +inf.0 (json-nesting-depth-limit))
(assert-equal? (tn) +inf.0 (json-number-of-character-limit))

(tn "json-write")
(assert-equal? (tn) "null" (write-json 'null))
(assert-equal? (tn) "true" (write-json #t))
(assert-equal? (tn) "false" (write-json #f))
(assert-equal? (tn) "-42" (write-json -42))
(assert-equal? (tn) "2.5" (write-json 2.5))
(assert-equal? (tn) "\"a\\\"\\\\\\n\\t\\r\\b\\f\\u0001\\u001f/\""
               (write-json (string #\a #\" #\\ #\newline #\tab
                                   (integer->char 13) (integer->char 8)
                                   (integer->char 12) (integer->char 1)
                                   (integer->char 31) #\/)))
(assert-equal? (tn) "[]" (write-json '#()))
(assert-equal? (tn) "{}" (write-json '()))
(assert-equal? (tn) "{\"a\":[1,{\"b\":null}],\"c\":\"d\"}"
               (write-json '((a . #(1 ((b . null)))) (c . "d"))))
(assert-equal? (tn) '((a . #(1 2.5 "x" #t #f null)) (b))
               (read-json (write-json '((a . #(1 2.5 "x" #t #f null))
                                        (b)))))

(tn "json-write errors")
(define (json-write-error-reason obj)
  (json-error-reason-of (lambda () (write-json obj))))
(assert-true (tn) (string? (json-write-error-reason 'foo)))
(assert-true (tn) (string? (json-write-error-reason +inf.0)))
(assert-true (tn) (string? (json-write-error-reason (- +inf.0 +inf.0))))
(assert-true (tn) (string? (json-write-error-reason '(1 2))))
(assert-true (tn) (string? (json-write-error-reason '((a . 1) . b))))
(assert-true (tn) (string? (json-write-error-reason '(("a" . 1)))))
(assert-true (tn) (string? (json-write-error-reason #\a)))
;; Nothing is written on error.
(let ((port (open-output-string)))
  (json-error-reason-of (lambda () (json-write '#(1 foo) port)))
  (assert-equal? (tn) "" (get-output-string port)))

(tn "json-accumulator")
(let* ((port (open-output-string))
       (accumulate (json-accumulator port)))
  (for-each accumulate
            '(object-start "a" array-start 1 "b" array-end object-end))
  (assert-equal? (tn) "{\"a\":[1,\"b\"]}" (get-output-string port)))
(let* ((strings '())
       (accumulate (json-accumulator
                    (lambda (str) (set! strings (cons str strings))))))
  (for-each accumulate '(array-start 1 2 array-end))
  (assert-equal? (tn) "[1,2]" (apply string-append (reverse strings))))
(define (accumulator-error-reason tokens)
  (json-error-reason-of
   (lambda ()
     (for-each (json-accumulator (open-output-string)) tokens))))
(assert-true (tn) (string? (accumulator-error-reason '(array-end))))
(assert-true (tn) (string? (accumulator-error-reason
                            '(array-start object-end))))
(assert-true (tn) (string? (accumulator-error-reason '(object-start 1))))
(assert-true (tn) (string? (accumulator-error-reason
                            '(object-start "a" object-end))))

(total-report)
