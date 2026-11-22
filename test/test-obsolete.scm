;;  Filename : test-obsolete.scm
;;  About    : unit tests for obsolete miscellaneous R5RS things
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

(if (not (provided? "r6rs-chars"))
    (test-skip-file "R6RS characters is not enabled"))

(test-begin "test-obsolete")
(define cp string-copy)


(test-equal "basic case check1" 'case1 (case 1
                                      ((1) 'case1)
                                      ((2) 'case2)))

(test-equal "basic case check2" 'case2 (case 2
                                      ((1) 'case1)
                                      ((2) 'case2)))

(test-equal "basic case check3" #t (case (* 2 3)
                           ((2 3 4 7)   #f)
                           ((1 4 6 8 9) #t)))

(test-equal "basic case else" 'caseelse (case 3
                                       ((1) 'case1)
                                       ((2) 'case2)
                                       (else
                                        'caseelse)))

(define mularg-apply
  (letrec ((apply-2 apply)
           (append-to-last
            (lambda (lst)
              (if (null? (cdr lst))
                  (car lst)
                  (cons (car lst) (append-to-last (cdr lst)))))))
    (lambda args
      (apply-2 (car args) (append-to-last (cdr args))))))
(test-equal "basic letrec test3" '((1) . 2) (mularg-apply cons '(1) '(2)))
(test-equal "basic letrec test4" '(1 2) (mularg-apply cons 1 '((2))))
;; SigScheme dependent behavior
(test-error "basic letrec test5" #t (letrec ((letrec-a 1)
                                             (letrec-b letrec-a))
                                      letrec-b))


(test-equal "basic map test1" '(2 2 2) (map cadr '((1 2) (1 2) (1 2))))
(test-equal "basic map test2" '(2 4 6) (map + '(1 2 3) '(1 2 3)))
(test-equal "basic map test3" '(2 4 6) (map (lambda (x y) (+ x y))
                                             '(1 2 3) '(1 2 3)))

(define (callee a)
  (test-equal "basic map test4" '(1 2) a))

(map callee '((1 2)))


; numbers in various radices
(test-assert "binary number test1" (= #b1111 15))
(test-assert "binary number test2" (= #b010  2))
(test-assert "binary number test3" (= #b0    0))
(test-assert "binary number test4" (= #b-1   -1))
(test-assert "binary number test5" (= #b-10  -2))
(test-assert "binary number test6" (= #b-010 -2))
(test-assert "octal number test1" (= #o077  63))
(test-assert "octal number test2" (= #o361  241))
(test-assert "decimal number test1" (= #d3900 3900))
(test-assert "decimal number test2" (= #d18782 18782))
(test-assert "hexadecimal test1" (= #xffff 65535))
(test-assert "hexadecimal test2" (= #x0A7b 2683))

(test-begin "pair?")
(test-assert (pair? '(a . b)))
(test-assert (pair? '(a b c)))
(test-equal #f (pair? '()))
(test-equal #f (pair? '#(a b)))
(test-end "pair?")

;;
;; All procedures that take a string as argument are tested with
;; both immutable and mutable string.
;;
;; See "3.4 Storage model" of R5RS
;;


;; string->list and list->string are available only with R5RS string
;; procedures.
(if (symbol-bound? 'string->list)
    (begin
      (test-begin "string->list immutable")
      (test-equal '()                (string->list ""))
      (test-equal '(#\\)             (string->list "\\"))
      (test-equal '(#\\ #\\)         (string->list "\\\\"))
      (test-equal '(#\\ #\\ #\\)     (string->list "\\\\\\"))
      ;;(test-equal '(#\tab)           (string->list "\t"))
      (test-equal '(#\	)      (string->list "\t"))
      ;;(test-equal '(#\return)        (string->list "\r"))
      (test-equal '(#\)            (string->list "\r"))
      (test-equal '(#\ #\)       (string->list "\r\r"))
      (test-equal '(#\newline)           (string->list "\n"))
      (test-equal '(#\newline #\newline) (string->list "\n\n"))
      (test-equal '(#\space)         (string->list " "))
      (test-equal '(#\space #\space) (string->list "  "))
      (test-equal '(#\")             (string->list "\""))
      (test-equal '(#\" #\")         (string->list "\"\""))
      (test-end "string->list immutable")
      (test-begin "string->list mutable")
      (test-equal '()                    (string->list (cp "")))
      (test-equal '(#\\)                 (string->list (cp "\\")))
      (test-equal '(#\\ #\\)             (string->list (cp "\\\\")))
      (test-equal '(#\\ #\\ #\\)         (string->list (cp "\\\\\\")))
      ;;(test-equal '(#\tab)           (string->list (cp "\t")))
      (test-equal '(#\	)            (string->list (cp "\t")))
      ;;(test-equal '(#\return)        (string->list (cp "\r")))
      (test-equal '(#\)                (string->list (cp "\r")))
      (test-equal '(#\ #\)           (string->list (cp "\r\r")))
      (test-equal '(#\newline)           (string->list (cp "\n")))
      (test-equal '(#\newline #\newline) (string->list (cp "\n\n")))
      (test-equal '(#\space)             (string->list (cp " ")))
      (test-equal '(#\space #\space)     (string->list (cp "  ")))
      (test-equal '(#\")                 (string->list (cp "\"")))
      (test-equal '(#\" #\")             (string->list (cp "\"\"")))
      (test-end "string->list mutable")

      (test-begin "list->string")
      (test-equal ""     (list->string '()))
      (test-equal "\\"     (list->string '(#\\)))
      (test-equal "\\\\"   (list->string '(#\\ #\\)))
      (test-equal "\\\\\\" (list->string '(#\\ #\\ #\\)))
      (test-equal "\t" (list->string '(#\	)))
      ;;(test-equal "\t" (list->string '(#\tab)))
      (test-equal "\r" (list->string '(#\)))
      ;;(test-equal "\r" (list->string '(#\return)))
      (test-equal "\n" (list->string '(#\
      )))
      (test-equal "\n" (list->string '(#\newline)))
      (test-equal " " (list->string '(#\ )))
      (test-equal " " (list->string '(#\space)))
      (test-equal " " (list->string '(#\ )))
      (test-equal "\"" (list->string '(#\")))
      (test-equal "\"a\"" (list->string '(#\" #\a #\")))
      (test-end "list->string")))


(test-end "test-obsolete")
