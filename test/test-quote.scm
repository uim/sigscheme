;;  Filename : test-quote.scm
;;  About    : unit test for quote and quasiquote
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

(if (not (symbol-bound? 'quasiquote))
    (test-skip-file "R5RS quasiquote is not enabled"))

(test-begin "test-quote")

(test-begin "quote")
(test-equal #f  '#f)
(test-equal #t  '#t)
(test-equal #\a '#\a)
(test-equal #\a '#\a)
(test-equal 1   '1)
(test-equal -1  '-1)
(test-equal 1   '#b1)
(test-equal 1   '#o1)
(test-equal 1   '#d1)
(test-equal 1   '#x1)
(test-equal "a" '"a")
(test-equal (string->symbol "sym") 'sym)
(test-equal (quote sym) 'sym)
(test-equal (quote (quote sym)) ''sym)
(test-equal (quote (quote (quote sym))) '''sym)
(test-equal (list)     '())
(test-equal (list 1)   '(1))
(test-equal (vector)   '#())
(test-equal (vector 1) '#(1))


(test-assert "quasiquote check #1" (equal? '(1 2 3) `(1 2 3)))
(test-assert "quasiquote check #2" (equal? '(5) `(,(+ 2 3))))
(test-assert "unquote check" (equal? `(1 2 3) `(1 ,(+ 1 1) ,(+ 1 2))))
(test-assert "unquote-splicing check" (equal? `(1 2 3) `(1 ,@(cdr '(1 2)) 3)))
(test-assert "mixed check" (equal? '(a 3 c 7 8 9) `(a ,(+ 1 2) c ,@(cdr '(6 7 8 9)))))
(test-equal "nested quasiquote check #1"
            '(a `(b c ,() 0) 1)
            `(a `(b c ,(,@'() ,@'()) 0) 1))

(test-equal "nested quasiquote check #2"
            '(0 1)
            `(0 . ,(list 1)))

(test-equal "nested quasiquote check #3"
            '(0 . 1)
            `(0 . ,'1))

(test-equal "nested quasiquote check #4"
            '(0 quasiquote (unquote 1))
            `(0 . `,,(+ 1)))

(test-assert "vector quasiquote check #1"
             (equal?
              '#(#(a b c d) e)
              `#(,@'() #(a ,@(list 'b 'c) d) e)))
(test-equal "vector quasiquote check #2" '(1 . #(2 3)) `(1 . #(,(+ 1 1) 3)))
(test-equal "vector quasiquote check #3"
            '(0 . #(1 2 3 4 5 6))
            `(0 . #(1 ,2 ,@(list 3 4) 5 ,6 ,@'())))
(test-equal "vector quasiquote check #3"
            '#(a b)
            `#(,@(list 'a 'b)))
(test-end "quote")

(test-begin "quasiquote reference test of R5RS")
(if (not (symbol-bound? 'sqrt))
    (eval '(define sqrt
             (lambda (x)
               (cdr (assv x '((4  . 2)
                              (9  . 3)
                              (16 . 4))))))
          (interaction-environment)))
(test-equal '(list 3 4)
            `(list ,(+ 1 2) 4))
(test-equal '(list a (quote a))
            (let ((name 'a)) `(list ,name ',name)))
(test-equal '(a 3 4 5 6 b)
            `(a ,(+ 1 2) ,@(map abs '(4 -5 6)) b))
;; Commented out since the test seems to wrong. Even if the interpretation for
;; the quote after foo (foo') may varied by implementation, at least the
;; quasiquote before foo (`foo) must be remained.
;;
;; SigScheme: (((quasiquote foo') 7) . cons)
;; Gauche:    ((`foo '7) . cons)
;; Guile:     (((quasiquote foo') 7) . cons)
;; Bigloo:    (((quasiquote foo') 7) . cons)
;; Scheme48:  (((quasiquote foo) '7) . cons)
;; SCM:       (((quasiquote foo\') 7) . cons)
;; PLT:       read: illegal use of backquote
;;(test-equal '((foo 7) . cons)
;;            `((`foo' ,(- 10 3)) ,@(cdr '(c)) . ,(car '(cons))))
(test-equal '#(10 5 2 4 3 8)
            `#(10 5 ,(sqrt 4) ,@(map sqrt '(16 9)) 8))
(test-equal '(a `(b ,(+ 1 2) ,(foo 4 d) e) f)
            `(a `(b ,(+ 1 2) ,(foo ,(+ 1 3) d) e) f))
(test-equal '(a `(b ,x ,'y d) e)
            (let ((name1 'x)
                  (name2 'y))
              `(a `(b ,,name1 ,',name2 d) e)))
(test-equal '(list 3 4)
            (quasiquote (list (unquote (+ 1 2)) 4)))
(test-equal '`(list ,(+ 1 2) 4)
            '(quasiquote (list (unquote (+ 1 2)) 4)))
(test-end "quasiquote reference test of R5RS")

(test-begin "quasiquote valid form")
(test-equal ''1      `'1)
(test-equal '`1      ``1)
(test-equal 1        `,1)
(test-equal ''1      `',1)
(test-equal '(quote 1)      `'1)
(test-equal '(quasiquote 1) ``1)
(test-equal '(quote 1)      `',1)
(test-equal '()      `())
(test-equal '('1)    `('1))
(test-equal '(`1)    `(`1))
(test-equal '(1)     `(,1))
(test-equal '('1)    `(',1))
(test-equal '(1)     `(,'1))
(test-equal '(1)     `(,`1))
(test-equal '((quote 1))      `('1))
(test-equal '((quasiquote 1)) `(`1))
(test-equal '(1)              `(,1))
(test-equal '((quote 1))      `(',1))
(test-equal '#()      `#())
(test-equal '#('1)    `#('1))
(test-equal '#(`1)    `#(`1))
(test-equal '#(1)     `#(,1))
(test-equal '#('1)    `#(',1))
(test-equal '#(1)     `#(,'1))
(test-equal '#(1)     `#(,`1))
(test-end "quasiquote valid form")

(test-begin "quasiquote nested")
(test-equal '((quasiquote q) q)
            `(`q ,`q))
(test-equal '((quasiquote q) (q (quasiquote q)))
            `(`q ,`(q `q)))
(test-equal '((quasiquote q) (q q))
            `(`q ,`(q ,`q)))
(test-equal '((quasiquote q) (q q (quasiquote q)))
            `(`q ,`(q ,`q `q)))
(test-equal '((quasiquote q) (q q (quasiquote (unquote q))))
            `(`q ,`(q ,`q `,q)))
(test-equal '((quasiquote q) (q q (quasiquote (unquote (quasiquote q)))))
            `(`q ,`(q ,`q `,`q)))
(test-equal '((quasiquote q) (q q (quasiquote (unquote q))))
            `(`q ,`(q ,`q `,,`q)))
(test-end "quasiquote nested")

(test-begin "unquote-splicing nested")
(test-equal '(1 2)
            `(,@(list 1 2)))
(test-equal '(quasiquote ((unquote-splicing (list 1 2))))
            ``(,@(list 1 2)))
(test-equal '(quasiquote (unquote (1 2)))
            ``,(,@(list 1 2)))

;; These tests show implementation-dependent behavior. But I believe that
;; SigScheme's implementation is conforming to following R5RS specification
;; better. Let me know if I'm misunderstanding.  -- YamaKen 2006-06-25
;;
;; R5RS: 7.1.4 Quasiquotations
;;
;; In <quasiquotation>s, a <list qq template D> can sometimes be confused with
;; either an <unquotation D> or a <splicing unquotation D>. The interpretation
;; as an <unquotation> or <splicing unquotation D> takes precedence.

;; Guile, Gauche, Bigloo, SCM
;;(test-equal '(quasiquote ((unquote (unquote-splicing (list 1 2)))))
;;            ``(,,@(list 1 2)))
;;(test-equal '(quasiquote ((unquote (unquote-splicing (list 1 2)))))
;;            (quasiquote
;;             (quasiquote
;;              ((unquote (unquote-splicing (list 1 2)))))))
;; SigScheme, Scheme48
(test-equal '(quasiquote ((unquote 1 2)))
            ``(,,@(list 1 2)))
(test-equal '(quasiquote ((unquote 1 2)))
            (quasiquote
             (quasiquote
              ((unquote (unquote-splicing (list 1 2)))))))

(test-equal '(quasiquote (list 1 2 (unquote-splicing (list 1 2))))
            ``(list 1 2 ,@(list 1 2)))
;; Guile, Gauche, Bigloo, SCM
;;(test-equal '(quasiquote
;;              (list 1 2 (unquote (unquote-splicing (list 1 2)))))
;;            ``(list 1 2 ,,@(list 1 2)))
;;(test-equal '(quasiquote
;;              (list 1 2 (unquote (unquote-splicing (list 1 2)))))
;;            (quasiquote
;;             (quasiquote
;;              (list 1 2 (unquote (unquote-splicing (list 1 2)))))))
;; SigScheme, Scheme48
(test-equal '(quasiquote (list 1 2 (unquote 1 2)))
            ``(list 1 2 ,,@(list 1 2)))
(test-equal '(quasiquote (list 1 2 (unquote 1 2)))
            (quasiquote
             (quasiquote
              (list 1 2 (unquote (unquote-splicing (list 1 2)))))))

;; Guile, Gauche, Bigloo, SCM
;;(test-equal '((+ 1 2)
;;              3
;;              (list (+ 1 2) 3 1 2)
;;              `(list (+ 1 2) ,(+ 1 2) ,@(list 1 2))
;;              `(list ,(+ 1 2) ,3 ,,@(list 1 2)))
;;            `((+ 1 2)
;;              ,(+ 1 2)
;;              (list (+ 1 2) ,(+ 1 2) ,@(list 1 2))
;;              `(list (+ 1 2) ,(+ 1 2) ,@(list 1 2))
;;              `(list ,(+ 1 2) ,,(+ 1 2) ,,@(list 1 2))))
;; SigScheme, Scheme48
(test-equal '((+ 1 2)
              3
              (list (+ 1 2) 3 1 2)
              `(list (+ 1 2) ,(+ 1 2) ,@(list 1 2))
              `(list ,(+ 1 2) ,3 (unquote 1 2)))
            `((+ 1 2)
              ,(+ 1 2)
              (list (+ 1 2) ,(+ 1 2) ,@(list 1 2))
              `(list (+ 1 2) ,(+ 1 2) ,@(list 1 2))
              `(list ,(+ 1 2) ,,(+ 1 2) ,,@(list 1 2))))
(test-end "unquote-splicing nested")


;; R5RS allows these forms to be an error
(test-begin "quasiquote implementation-dependent form")
(if (provided? "sigscheme")
    (begin
      (test-error `((quasiquote)))
      (test-error `((quasiquote . 0)))
      (test-error `((quasiquote 0 1)))
      (test-error `((quasiquote 0 . 1)))
      (test-error `(0 quasiquote))
      (test-error `(0 . (quasiquote)))
      (test-error `(0 quasiquote 2 3))
      (test-error `(0 . (quasiquote 2 3)))
      (test-error `(0 quasiquote 2 3 4))
      (test-error `(0 . (quasiquote 2 3 4)))
      (test-error `(0 quasiquote . 0))
      (test-error `(0 . (quasiquote . 0)))
      (test-error `(0 quasiquote 2 3 . 0))
      (test-error `(0 . (quasiquote 2 3 . 0)))
      (test-error `(0 quasiquote 2 3 4 . 0))
      (test-error `(0 . (quasiquote 2 3 4 . 0)))))
(test-end "quasiquote implementation-dependent form")
(test-begin "unquote implementation-dependent form")
(if (provided? "sigscheme")
    (begin
      (test-error `((unquote)))
      (test-error `((unquote . 0)))
      (test-error `((unquote 0 1)))
      (test-error `((unquote 0 . 1)))
      (test-error `(0 unquote))
      (test-error `(0 . (unquote)))
      (test-error `(0 unquote 2 3))
      (test-error `(0 . (unquote 2 3)))
      (test-error `(0 unquote 2 3 4))
      (test-error `(0 . (unquote 2 3 4)))
      (test-error `(0 unquote . 0))
      (test-error `(0 . (unquote . 0)))
      (test-error `(0 unquote 2 3 . 0))
      (test-error `(0 . (unquote 2 3 . 0)))
      (test-error `(0 unquote 2 3 4 . 0))
      (test-error `(0 . (unquote 2 3 4 . 0)))))
(test-end "unquote implementation-dependent form")
(test-begin "unquote-splicing implementation-dependent form")
(if (provided? "sigscheme")
    (begin
      (test-error `(0 unquote-splicing))
      (test-error `(0 . (unquote-splicing)))
      (test-error `(0 unquote-splicing 2 3))
      (test-error `(0 . (unquote-splicing 2 3)))
      (test-error `(0 unquote-splicing 2 3 4))
      (test-error `(0 . (unquote-splicing 2 3 4)))
      (test-error `(0 unquote-splicing . 0))
      (test-error `(0 . (unquote-splicing . 0)))
      (test-error `(0 unquote-splicing 2 3 . 0))
      (test-error `(0 . (unquote-splicing 2 3 . 0)))
      (test-error `(0 unquote-splicing 2 3 4 . 0))
      (test-error `(0 . (unquote-splicing 2 3 4 . 0)))
      (test-error `((unquote-splicing)))
      (test-error `((unquote-splicing . 0)))
      (test-error `((unquote-splicing 0 1)))
      (test-error `((unquote-splicing 0 . 1)))))
(test-end "unquote-splicing implementation-dependent form")

(test-begin "quasiquote dotted list")
(test-equal '(0 . '1)         `(0 . '1))
(test-equal '(0 . `1)         `(0 . `1))
(test-equal '(0 . 1)          `(0 . ,1))
(test-equal '(0 . (quote 1))  `(0 . '1))
(test-equal '(0 . (quasiquote 1)) `(0 . `1))
(test-equal '(0 . #(1))       `(0 . ,'#(1)))
(test-equal '(0 . #(1))       `(0 . ,`#(1)))
(test-equal '(0 . #(1 3))     `(0 . ,`#(1 ,(+ 1 2))))
(test-equal '(0 . #(1 -1 -2)) `(0 . ,`#(1 ,@(list (- 1) (- 2)))))
(test-error `(0 . ,@'()))
(test-error `(0 . ,@(list)))
(test-error `(0 . ,@(list 1)))
(test-error `(0 . ,@(list 1 2)))
(test-error `(0 . ,@(list 1 2 3)))
(test-error `(0 . ,@#t))
(test-error `(0 . ,@1))
(test-error `(0 . ,@#\a))
(test-error `(0 . ,@"str"))
(test-error `(0 . ,@'sym))
(test-error `(0 . ,@sym))
(test-error `(0 . ,@var))
(test-error `(0 . ,@(lambda () #f)))
(test-error `(0 . ,@(+ 1 2)))
(test-error `(0 . ,@#(1 2)))
(test-error `(0 . (unquote-splicing ())))
(test-error `(0 . (unquote-splicing (list))))
(test-error `(0 . (unquote-splicing (list 1))))
(test-error `(0 . (unquote-splicing (list 1 2))))
(test-error `(0 . (unquote-splicing (list 1 2 3))))
(test-error `(0 . (unquote-splicing #t)))
(test-error `(0 . (unquote-splicing 1)))
(test-error `(0 . (unquote-splicing #\a)))
(test-error `(0 . (unquote-splicing "str")))
(test-error `(0 . (unquote-splicing 'sym)))
(test-error `(0 . (unquote-splicing sym)))
(test-error `(0 . (unquote-splicing var)))
(test-error `(0 . (unquote-splicing (lambda () #f))))
(test-error `(0 . (unquote-splicing (+ 1 2))))
(test-error `(0 . (unquote-splicing #(1 2))))
(test-end "quasiquote dotted list")

(test-begin "unquote valid form")
(test-equal 1     `,1)
(test-equal ',1   ',1)
(test-equal '(quasiquote 1)           ``1)
(test-equal '(quasiquote (unquote 1)) ``,1)
(test-equal '(quasiquote (unquote 1)) ``,,1)
(test-equal '(quasiquote (+ 1 2))           ``(+ 1 2))
(test-equal '(quasiquote (unquote (+ 1 2))) ``,(+ 1 2))
(test-equal '(quasiquote (unquote 3))       ``,,(+ 1 2))
(test-equal '(quasiquote (list 1 2 (+ 1 2)))
            ``(list 1 2 (+ 1 2)))
(test-equal '(quasiquote (unquote (list 1 2 (+ 1 2))))
            ``,(list 1 2 (+ 1 2)))
(test-equal '(quasiquote (unquote (1 2 3)))
            ``,,(list 1 2 (+ 1 2)))
(test-equal '(quasiquote (list 1 2 (unquote (+ 1 2))))
            ``(list 1 2 ,(+ 1 2)))
(test-equal '(quasiquote (list 1 2 (unquote 3)))
            ``(list 1 2 ,,(+ 1 2)))
(test-equal '(quasiquote (list 1 2))           ``(list 1 2))
(test-equal '(quasiquote (unquote (list 1 2))) ``,(list 1 2))
(test-equal '(quasiquote (unquote (1 2)))      ``,,(list 1 2))
(test-equal 1 `,`,1)
(test-equal 3 `,(+ 1 2))
(test-equal ',(+ 1 2) ',(+ 1 2))
(test-equal '(+ 1 2) (cadr ',(+ 1 2)))
(test-equal '(quasiquote (unquote 3)) ``,,(+ 1 2))
(test-equal 3     `,`,(+ 1 2))
;; list
(test-equal '(1)  `(,1))
(test-equal '(quasiquote ((unquote 1))) ``(,,1))
(test-equal '(1)  `(,`,1))
(test-equal '(quasiquote (quasiquote ((unquote (unquote 1)))))
            ```(,,,1))
(test-equal '(3)  `(,(+ 1 2)))
(test-equal '(quasiquote ((unquote 3))) ``(,,(+ 1 2)))
;; vector
(test-equal '#(1)  `#(,1))
(test-equal '(quasiquote #((unquote 1))) ``#(,,1))
(test-equal '#(1)  `#(,`,1))
(test-equal '(quasiquote (quasiquote #((unquote (unquote 1)))))
            ```#(,,,1))
(test-equal '#(3)  `#(,(+ 1 2)))
(test-equal '(quasiquote #((unquote 3))) ``#(,,(+ 1 2)))
(test-end "unquote valid form")

(test-begin "unquote invalid form")
(test-error ,1)
(test-error ,,1)
(test-error `,,1)
(test-error ,(+ 1 2))
(test-error ,,(+ 1 2))
(test-error `,,(+ 1 2))
(test-error `(,,1))
(test-error ``(,,,1))
(test-error `(,,(+ 1 2)))
(test-error ``(,,,(+ 1 2)))
(test-error `#(,,1))
(test-error ``#(,,,1))
(test-error `#(,,(+ 1 2)))
(test-error ``#(,,,(+ 1 2)))
(test-end "unquote invalid form")

(test-begin "unquote-splicing valid form")
(test-equal '()      `(,@'()))
(test-equal '()      `(,@'() ,@'()))
(test-equal '()      `(,@'() ,@'() ,@'()))
(test-equal '(0)     `(0 ,@'()))
(test-equal '(1)     `(,@'() 1))
(test-equal '(0 1)   `(0 ,@'() 1))
(test-equal '()      `(,@(list)))
(test-equal '(1)     `(,@(list 1)))
(test-equal '(1 2)   `(,@(list 1 2)))
(test-equal '(1 2 3) `(,@(list 1 2 3)))
(test-equal '(0 1 2 3) `(0 ,@(list 1 2 3)))
(test-equal '(1 2 3 4) `(,@(list 1 2 3) 4))
(test-equal '(0 1 2 3 4) `(0 ,@(list 1 2 3) 4))
(test-equal '(1 2 3) `(,@((lambda () '(1 2 3)))))
(test-equal '(0 1 2 3 4) `(0 ,@((lambda () '(1 2 3))) 4))
(test-equal '#()      `#(,@'()))
(test-equal '#()      `#(,@'() ,@'()))
(test-equal '#()      `#(,@'() ,@'() ,@'()))
(test-equal '#(0)     `#(0 ,@'()))
(test-equal '#(1)     `#(,@'() 1))
(test-equal '#(0 1)   `#(0 ,@'() 1))
;; negative growth for vectran
(test-equal '#(0 1)   `#(0 ,@'() ,@'() ,@'() ,@'() 1 ,@'()))
(test-equal '#(1 2 3) `#(,@((lambda () '(1 2 3)))))
(test-equal '#(0 1 2 3 4) `#(0 ,@((lambda () '(1 2 3))) 4))
(test-end "unquote-splicing valid form")

(test-begin "unquote-splicing invalid form")
(define sym 'sym)
(define var 3)
(test-error `,@'())
(test-error `,@(list))
(test-error `,@(list 1))
(test-error `,@(list 1 2))
(test-error `,@(list 1 2 3))
(test-error `(,@(,@'())))
(test-error `(,@(`,@'())))
(test-error `(,@(,1)))
(test-error `(,@(`(,,1))))
(test-error `#(,@(,@'())))
(test-error `#(,@(`,@'())))
(test-error `#(,@(,1)))
(test-error `#(,@(`(,,1))))
(test-error `(0 ,@((lambda () '(1 2 . 3))) 4))
(test-error `#(0 ,@((lambda () '(1 2 . 3))) 4))
(test-error `,@#t)
(test-error `,@1)
(test-error `,@1)
(test-error `,@#\a)
(test-error `,@"str")
(test-error `,@'sym)
(test-error `,@sym)
(test-error `,@var)
(test-error `,@(lambda () #f))
(test-error `,@(+ 1 2))
(test-error `,@#(1 2))
(test-error `(,@#t))
(test-error `(,@1))
(test-error `(,@#\a))
(test-error `(,@"str"))
(test-error `(,@'sym))
(test-error `(,@sym))
(test-error `(,@var))
(test-error `(,@(lambda () #f)))
(test-error `(,@(+ 1 2)))
(test-error `(,@#(1 2)))
(test-end "unquote-splicing invalid form")

(test-end "test-quote")
