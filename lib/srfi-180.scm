;;  Filename : srfi-180.scm
;;  About    : SRFI-180 JSON
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


;; JSON values are represented as the following Scheme objects:
;;
;;   null   -> the symbol null
;;   true   -> #t
;;   false  -> #f
;;   number -> number
;;   string -> string
;;   array  -> vector
;;   object -> association list with symbol keys
;;
;; \uXXXX escapes of non-ASCII characters require UTF-8 because characters
;; aren't converted between encodings.

(require-extension (srfi 6 34))

(define %json-eof (read-char (open-input-string "")))

;; An error of this library is #(tag reason).
(define %json-error-tag (list 'json-error))

(define (%json-error reason . irritants)
  (raise (vector %json-error-tag
                 (if (null? irritants)
                     reason
                     (let ((port (open-output-string)))
                       (display reason port)
                       (display ":" port)
                       (for-each (lambda (irritant)
                                   (display " " port)
                                   (write irritant port))
                                 irritants)
                       (get-output-string port))))))

(define (json-error? obj)
  (and (vector? obj)
       (= (vector-length obj) 2)
       (eq? (vector-ref obj 0) %json-error-tag)))

(define (json-error-reason obj)
  (vector-ref obj 1))

(define (json-null? obj)
  (eq? obj 'null))

;; Parameters can't be changed without R7RS.
(define %json-make-parameter
  (if (symbol-bound? 'make-parameter)
      make-parameter
      (lambda (value) (lambda () value))))

(define json-nesting-depth-limit (%json-make-parameter +inf.0))
(define json-number-of-character-limit (%json-make-parameter +inf.0))

;;
;; Reader
;;

;; A source is (peek . read) procedures of characters. A generator of
;; characters is wrapped to peek a character.
(define (%json-source args)
  (let ((port-or-generator (if (null? args) (current-input-port) (car args))))
    (if (procedure? port-or-generator)
        (let ((peeked #f))
          (cons (lambda ()
                  (if (not peeked)
                      (set! peeked (port-or-generator)))
                  peeked)
                (lambda ()
                  (if peeked
                      (let ((c peeked))
                        (set! peeked #f)
                        c)
                      (port-or-generator)))))
        (cons (lambda () (peek-char port-or-generator))
              (lambda () (read-char port-or-generator))))))

(define (json-generator . args)
  (%json-generator (%json-source args)))

;; Returns a generator of the tokens of a JSON text in SOURCE. STACK has the
;; states of the nested arrays and objects:
;;
;;   array-first:  after [
;;   array-next:   after an element
;;   object-first: after {
;;   object-next:  after a member
;;   object-value: after a key and :
(define (%json-generator source)
  (let ((peek (car source))
        (read (cdr source))
        (n-chars 0)
        (character-limit (json-number-of-character-limit))
        (depth-limit (json-nesting-depth-limit))
        (stack '())
        (depth 0)
        (done? #f))

    (define (next-char)
      (set! n-chars (+ n-chars 1))
      (if (> n-chars character-limit)
          (%json-error "too many characters"))
      (read))

    (define (skip-whitespace)
      (if (memv (peek) '(#\space #\tab #\newline #\return))
          (begin
            (next-char)
            (skip-whitespace))))

    (define (expect char)
      (let ((c (next-char)))
        (if (not (eqv? c char))
            (%json-error "unexpected character" c))))

    (define (start state token)
      (if (>= depth depth-limit)
          (%json-error "too deep nesting"))
      (next-char)
      (set! stack (cons state stack))
      (set! depth (+ depth 1))
      token)

    (define (end token)
      (next-char)
      (set! stack (cdr stack))
      (set! depth (- depth 1))
      token)

    (define (read-literal chars value)
      (for-each expect chars)
      value)

    (define (read-value c)
      (cond
       ((eqv? c #\[) (start 'array-first 'array-start))
       ((eqv? c #\{) (start 'object-first 'object-start))
       ((eqv? c #\") (next-char) (read-string))
       ((eqv? c #\t) (read-literal '(#\t #\r #\u #\e) #t))
       ((eqv? c #\f) (read-literal '(#\f #\a #\l #\s #\e) #f))
       ((eqv? c #\n) (read-literal '(#\n #\u #\l #\l) 'null))
       ((or (eqv? c #\-) (%json-digit? c)) (read-number))
       ((eof-object? c) (%json-error "unexpected end of JSON text"))
       (else (%json-error "unexpected character" c))))

    (define (read-key c)
      (if (not (eqv? c #\"))
          (%json-error "string expected but got" c))
      (next-char)
      (let ((key (read-string)))
        (skip-whitespace)
        (expect #\:)
        (set-car! stack 'object-value)
        key))

    (define (read-string)
      (let loop ((chars '()))
        (let ((c (next-char)))
          (cond
           ((eof-object? c) (%json-error "unterminated string"))
           ((eqv? c #\") (list->string (reverse chars)))
           ((eqv? c #\\) (loop (cons (read-escape) chars)))
           ((< (char->integer c) 32)
            (%json-error "control character in string" c))
           (else (loop (cons c chars)))))))

    (define (read-escape)
      (let ((c (next-char)))
        (case c
          ((#\" #\\ #\/) c)
          ((#\b) (integer->char 8))
          ((#\f) (integer->char 12))
          ((#\n) #\newline)
          ((#\r) (integer->char 13))
          ((#\t) #\tab)
          ((#\u) (read-unicode-escape))
          (else (%json-error "invalid escape" c)))))

    ;; A character out of the BMP is a pair of surrogates.
    (define (read-unicode-escape)
      (let ((code (read-hex4)))
        (cond
         ((<= #xd800 code #xdbff)
          (expect #\\)
          (expect #\u)
          (let ((low (read-hex4)))
            (if (not (<= #xdc00 low #xdfff))
                (%json-error "invalid surrogate pair" code low))
            (%json-code->char (+ #x10000
                                 (* (- code #xd800) #x400)
                                 (- low #xdc00)))))
         ((<= #xdc00 code #xdfff)
          (%json-error "invalid surrogate pair" code))
         (else (%json-code->char code)))))

    (define (read-hex4)
      (let loop ((i 0)
                 (code 0))
        (if (= i 4)
            code
            (let* ((c (next-char))
                   (digit (and (char? c) (%json-hex-digit c))))
              (if (not digit)
                  (%json-error "invalid \\u escape" c))
              (loop (+ i 1) (+ (* code 16) digit))))))

    (define (read-number)
      (let loop ((chars '()))
        (if (memv (peek) '(#\0 #\1 #\2 #\3 #\4 #\5 #\6 #\7 #\8 #\9
                           #\- #\+ #\. #\e #\E))
            (loop (cons (next-char) chars))
            (let ((chars (reverse chars)))
              (if (not (%json-number-chars? chars))
                  (%json-error "invalid number" (list->string chars)))
              (%json-chars->number chars)))))

    (define (next-token)
      (let ((c (peek)))
        (if (null? stack)
            (if (eof-object? c) c (read-value c))
            (case (car stack)
              ((array-first)
               (if (eqv? c #\])
                   (end 'array-end)
                   (begin
                     (set-car! stack 'array-next)
                     (read-value c))))
              ((array-next)
               (cond
                ((eqv? c #\]) (end 'array-end))
                ((eqv? c #\,)
                 (next-char)
                 (skip-whitespace)
                 (read-value (peek)))
                (else (%json-error "\",\" or \"]\" expected but got" c))))
              ((object-first)
               (if (eqv? c #\})
                   (end 'object-end)
                   (read-key c)))
              ((object-next)
               (cond
                ((eqv? c #\}) (end 'object-end))
                ((eqv? c #\,)
                 (next-char)
                 (skip-whitespace)
                 (read-key (peek)))
                (else (%json-error "\",\" or \"}\" expected but got" c))))
              ((object-value)
               (set-car! stack 'object-next)
               (read-value c))))))

    (lambda ()
      (if done?
          %json-eof
          (begin
            (skip-whitespace)
            (let ((token (next-token)))
              ;; Only one JSON value is read.
              (if (null? stack)
                  (set! done? #t))
              token))))))

(define (%json-digit? c)
  (and (char? c) (char<=? #\0 c) (char<=? c #\9)))

(define (%json-hex-digit c)
  (cond
   ((%json-digit? c) (- (char->integer c) (char->integer #\0)))
   ((and (char<=? #\a c) (char<=? c #\f))
    (+ 10 (- (char->integer c) (char->integer #\a))))
   ((and (char<=? #\A c) (char<=? c #\F))
    (+ 10 (- (char->integer c) (char->integer #\A))))
   (else #f)))

(define (%json-code->char code)
  (if (or (< code #x80)
          (equal? (%%current-char-codec) "UTF-8"))
      (integer->char code)
      (%json-error "\\u escape of non-ASCII character requires UTF-8" code)))

;; Returns the rest after one or more digits in CHARS or #f.
(define (%json-skip-digits chars)
  (and (pair? chars)
       (%json-digit? (car chars))
       (let loop ((chars chars))
         (if (and (pair? chars) (%json-digit? (car chars)))
             (loop (cdr chars))
             chars))))

;; -?(0|[1-9][0-9]*)(\.[0-9]+)?([eE][-+]?[0-9]+)?
(define (%json-number-chars? chars)
  (let* ((chars (if (and (pair? chars) (eqv? (car chars) #\-))
                    (cdr chars)
                    chars))
         (chars (if (and (pair? chars) (eqv? (car chars) #\0))
                    (cdr chars)
                    (%json-skip-digits chars)))
         (chars (if (and (pair? chars) (eqv? (car chars) #\.))
                    (%json-skip-digits (cdr chars))
                    chars))
         (chars (if (and (pair? chars) (memv (car chars) '(#\e #\E)))
                    (%json-skip-digits
                     (if (and (pair? (cdr chars))
                              (memv (cadr chars) '(#\- #\+)))
                         (cddr chars)
                         (cdr chars)))
                    chars)))
    (null? chars)))

;; An integer out of the fixnum range is read as an inexact number.
(define (%json-chars->number chars)
  (let ((str (list->string chars)))
    (or (string->number str)
        (string->number (string-append "#i" str))
        (%json-error "unsupported number" str))))

(define (json-fold proc array-start array-end object-start object-end seed
                   . args)
  (let ((generator (%json-generator (%json-source args))))
    ;; STACK has the seeds of the outer arrays and objects.
    (let loop ((seed seed)
               (stack '()))
      (let ((token (generator)))
        (cond
         ((eof-object? token) seed)
         ((eq? token 'array-start)
          (loop (array-start seed) (cons seed stack)))
         ((eq? token 'object-start)
          (loop (object-start seed) (cons seed stack)))
         ((eq? token 'array-end)
          (loop (proc (array-end seed) (car stack)) (cdr stack)))
         ((eq? token 'object-end)
          (loop (proc (object-end seed) (car stack)) (cdr stack)))
         (else
          (loop (proc token seed) stack)))))))

(define (json-read . args)
  (%json-read (%json-source args)))

(define (%json-read source)
  (let ((generator (%json-generator source)))
    (define (read-value token)
      (case token
        ((array-start)
         (let loop ((elements '()))
           (let ((token (generator)))
             (if (eq? token 'array-end)
                 (list->vector (reverse elements))
                 (loop (cons (read-value token) elements))))))
        ((object-start)
         (let loop ((members '()))
           (let ((token (generator)))
             (if (eq? token 'object-end)
                 (reverse members)
                 (let ((key (string->symbol token)))
                   (loop (cons (cons key (read-value (generator)))
                               members)))))))
        (else token)))
    (read-value (generator))))

;; JSON Lines
(define (json-lines-read . args)
  (let ((source (%json-source args)))
    (lambda ()
      (%json-read source))))

;; RFC 7464: Each JSON text is preceded by RS.
(define (json-sequence-read . args)
  (let ((source (%json-source args))
        (rs (integer->char 30)))
    (lambda ()
      (let loop ()
        (if (memv ((car source)) (list rs #\space #\tab #\newline #\return))
            (begin
              ((cdr source))
              (loop))))
      (%json-read source))))

;;
;; Writer
;;

;; Returns a procedure that writes JSON tokens of json-generator. The
;; states of nested arrays and objects are the same as json-generator.
(define (json-accumulator port-or-accumulator)
  (let ((out (if (procedure? port-or-accumulator)
                 port-or-accumulator
                 (lambda (str) (display str port-or-accumulator))))
        (stack '()))
    (define (start state str)
      (out str)
      (set! stack (cons state stack)))
    (define (end str)
      (out str)
      (set! stack (cdr stack)))
    (lambda (token)
      (let ((state (if (pair? stack) (car stack) 'toplevel)))
        (cond
         ((memq state '(object-first object-next))
          (cond
           ((eq? token 'object-end) (end "}"))
           ((string? token)
            (if (eq? state 'object-next)
                (out ","))
            (out (%json-string->json token))
            (out ":")
            (set-car! stack 'object-value))
           (else (%json-error "object key or end expected but got" token))))
         ((eq? token 'array-end)
          (if (not (memq state '(array-first array-next)))
              (%json-error "unexpected array end"))
          (end "]"))
         ((eq? token 'object-end)
          (%json-error "unexpected object end"))
         (else
          (case state
            ((array-first) (set-car! stack 'array-next))
            ((array-next) (out ","))
            ((object-value) (set-car! stack 'object-next)))
          (cond
           ((eq? token 'array-start) (start 'array-first "["))
           ((eq? token 'object-start) (start 'object-first "{"))
           (else (out (%json-value->json token))))))))))

(define (%json-value->json obj)
  (cond
   ((eq? obj 'null) "null")
   ((eq? obj #t) "true")
   ((eq? obj #f) "false")
   ((string? obj) (%json-string->json obj))
   ((and (number? obj)
         (if (exact? obj)
             (integer? obj)
             (and (real? obj)
                  (= obj obj)  ; not NaN
                  (not (= (abs obj) +inf.0)))))
    (number->string obj))
   (else (%json-error "invalid JSON value" obj))))

(define (%json-string->json str)
  (let ((port (open-output-string)))
    (write-char #\" port)
    (for-each
     (lambda (c)
       (case c
         ((#\") (display "\\\"" port))
         ((#\\) (display "\\\\" port))
         ((#\newline) (display "\\n" port))
         ((#\tab) (display "\\t" port))
         (else
          (let ((code (char->integer c)))
            (cond
             ((= code 8) (display "\\b" port))
             ((= code 12) (display "\\f" port))
             ((= code 13) (display "\\r" port))
             ((< code 32)
              (display (if (< code 16) "\\u000" "\\u001") port)
              (display (number->string (modulo code 16) 16) port))
             (else (write-char c port)))))))
     (string->list str))
    (write-char #\" port)
    (get-output-string port)))

;; The whole JSON text is built before writing to validate OBJ.
(define (json-write obj . args)
  (let* ((port (open-output-string))
         (accumulate (json-accumulator port))
         (out (if (null? args) (current-output-port) (car args))))
    (let write-value ((obj obj))
      (cond
       ((vector? obj)
        (accumulate 'array-start)
        (for-each write-value (vector->list obj))
        (accumulate 'array-end))
       ((list? obj)
        (accumulate 'object-start)
        (for-each (lambda (member)
                    (if (not (and (pair? member) (symbol? (car member))))
                        (%json-error "invalid JSON object member" member))
                    (accumulate (symbol->string (car member)))
                    (write-value (cdr member)))
                  obj)
        (accumulate 'object-end))
       ((and (symbol? obj) (not (eq? obj 'null)))
        (%json-error "invalid JSON value" obj))
       (else (accumulate obj))))
    (if (procedure? out)
        (out (get-output-string port))
        (display (get-output-string port) out))))
