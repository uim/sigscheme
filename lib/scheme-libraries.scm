;;  Filename : scheme-libraries.scm
;;  About    : R7RS Standard Libraries
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

;; The exports of the standard libraries. Each entry is (name symbol ...).
;; library.scm reads this file when a standard library is imported first.
;; The libraries export the builtins. Unsupported features such as complex
;; numbers aren't listed. Unbound symbols such as auxiliary syntax aren't
;; exported.

((scheme base)
 * + - ... / < <= = => > >= _ abs and append apply assoc assq assv begin
 binary-port? boolean=? boolean? bytevector bytevector-append
 bytevector-copy bytevector-copy! bytevector-length bytevector-u8-ref
 bytevector-u8-set! bytevector? caar cadr call-with-current-continuation
 call-with-port call-with-values call/cc car case cdar cddr cdr ceiling
 char->integer char-ready? char<=? char<? char=? char>=? char>? char?
 close-input-port close-output-port close-port complex? cond cond-expand
 cons current-error-port current-input-port current-output-port define
 define-record-type define-syntax define-values denominator do dynamic-wind
 else eof-object eof-object? eq? equal? eqv? error error-object-irritants
 error-object-message error-object? even? exact exact-integer-sqrt
 exact-integer? exact? expt features file-error? floor floor-quotient
 floor-remainder floor/ flush-output-port for-each gcd get-output-bytevector
 get-output-string guard if include include-ci inexact inexact? input-port-open?
 input-port? integer->char integer? lambda lcm length let let* let*-values
 let-syntax let-values letrec letrec* letrec-syntax list list->string
 list->vector list-copy list-ref list-set! list-tail list? make-bytevector
 make-list make-parameter make-string make-vector map max member memq memv
 min modulo negative? newline not null? number->string number? numerator
 odd? open-input-bytevector open-input-string open-output-bytevector
 open-output-string or output-port-open? output-port? pair? parameterize
 peek-char peek-u8 port? positive? procedure? quasiquote quote quotient
 raise raise-continuable rational? rationalize read-bytevector
 read-bytevector! read-char read-error? read-line read-string read-u8 real?
 remainder reverse round set! set-car! set-cdr! square string string->list
 string->number string->symbol string->utf8 string->vector string-append
 string-copy string-copy! string-fill! string-for-each string-length
 string-map string-ref string-set! string<=? string<? string=? string>=?
 string>? string? substring symbol->string symbol=? symbol? syntax-error
 syntax-rules textual-port? truncate truncate-quotient truncate-remainder
 truncate/ u8-ready? unless unquote unquote-splicing utf8->string values
 vector vector->list vector->string vector-append vector-copy vector-copy!
 vector-fill! vector-for-each vector-length vector-map vector-ref
 vector-set! vector? when with-exception-handler write-bytevector
 write-char write-string write-u8 zero?)

((scheme case-lambda) case-lambda)

((scheme char)
 char-alphabetic? char-ci<=? char-ci<? char-ci=? char-ci>=? char-ci>?
 char-downcase char-foldcase char-lower-case? char-numeric? char-upcase
 char-upper-case? char-whitespace? digit-value string-ci<=? string-ci<?
 string-ci=? string-ci>=? string-ci>? string-downcase string-foldcase
 string-upcase)

((scheme cxr)
 caaaar caaadr caaar caadar caaddr caadr cadaar cadadr cadar caddar cadddr
 caddr cdaaar cdaadr cdaar cdadar cdaddr cdadr cddaar cddadr cddar cdddar
 cddddr cdddr)

((scheme eval) environment eval)

((scheme file)
 call-with-input-file call-with-output-file delete-file file-exists?
 open-binary-input-file open-binary-output-file open-input-file
 open-output-file with-input-from-file with-output-to-file)

((scheme inexact) acos asin atan cos exp finite? infinite? log nan? sin sqrt tan)

((scheme lazy) delay delay-force force make-promise promise?)

((scheme load) load)

((scheme process-context)
 command-line emergency-exit exit get-environment-variable
 get-environment-variables)

((scheme read) read)

((scheme repl) interaction-environment)

((scheme time) current-jiffy current-second jiffies-per-second)

((scheme write) display write write-shared write-simple)

((scheme r5rs)
 * + - / < <= = > >= abs acos and append apply asin assoc assq assv atan begin
 boolean? caaaar caaadr caaar caadar caaddr caadr caar cadaar cadadr cadar
 caddar cadddr caddr cadr call-with-current-continuation call-with-input-file
 call-with-output-file call-with-values car case cdaaar cdaadr cdaar cdadar
 cdaddr cdadr cdar cddaar cddadr cddar cdddar cddddr cdddr cddr cdr ceiling
 char->integer char-alphabetic? char-ci<=? char-ci<? char-ci=? char-ci>=?
 char-ci>? char-downcase char-lower-case? char-numeric? char-ready?
 char-upcase char-upper-case? char-whitespace? char<=? char<? char=? char>=?
 char>? char? close-input-port close-output-port complex? cond cons cos
 current-input-port current-output-port define define-syntax delay denominator
 display do dynamic-wind eof-object? eq? equal? eqv? eval even? exact->inexact
 exact? exp expt floor for-each force gcd if inexact->exact inexact?
 input-port? integer->char integer? interaction-environment lambda lcm length
 let let* let-syntax letrec letrec-syntax list list->string list->vector
 list-ref list-tail list? load log make-string make-vector map max member memq
 memv min modulo negative? newline not null-environment null? number->string
 number? numerator odd? open-input-file open-output-file or output-port? pair?
 peek-char positive? procedure? quasiquote quote quotient rational?
 rationalize read read-char real? remainder reverse round
 scheme-report-environment set! set-car! set-cdr! sin sqrt string string->list
 string->number string->symbol string-append string-ci<=? string-ci<?
 string-ci=? string-ci>=? string-ci>? string-copy string-fill! string-length
 string-ref string-set! string<=? string<? string=? string>=? string>? string?
 substring symbol->string symbol? tan truncate values vector vector->list
 vector-fill! vector-length vector-ref vector-set! vector?
 with-input-from-file with-output-to-file write write-char zero?)
