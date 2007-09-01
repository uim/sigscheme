;; Ported from http://pobox.com/~oleg/ftp/Scheme/vland.scm

;; License terms:
;;
;; http://pobox.com/~oleg/ftp/
;;
;; "Unless specified otherwise, all the code and the documentation on this site
;; is in public domain."

;; ChangeLog
;;
;; 2007-06-13 yamaken    Copied from "vland.scm,v 2.0 2002/06/28" and adapted
;;                       to SigScheme


; 		A special form and-let*
;	           Validation code
;
; AND-LET* (formerly known as LAND*) is an AND with local bindings, a
; guarded LET* special form.  It evaluates a sequence of forms one
; after another till the first one that yields #f; the non-#f result
; of a form can be bound to a fresh variable and used in the
; subsequent forms.
;
; It is defined in SRFI-2 <http://srfi.schemers.org/srfi-2/>
;
; Motivation:
; When an ordinary AND is formed of _proper_ boolean expressions:
;	(AND E1 E2 ...)
;
; the expression E2, if it gets to be evaluated, knows that E1 has
; returned non-#f.  Moreover, E2 knows exactly what the result of E1
; was - #t - so E2 can use this knowledge to its advantage. If E1
; however is an _extended_ boolean expression, E2 can no longer tell
; which particular non-#f value was returned by E1. Chances are it
; took a lot of work to evaluate E1, and the produced result (a
; number, a vector, a string, etc) may be of value to E2. Alas, the
; AND form merely checks that the result is not an #f, and throws it
; away. If E2 needs it, it has to recompute the value again.  This
; proposed AND-LET* special form lets constituent expressions get hold
; of the results of already evaluated expressions, without re-doing
; their work.
;
; Syntax:
; 	AND-LET* (CLAWS) BODY
;
; where CLAWS is a list of expressions or bindings: 
;	CLAWS ::= '() | (cons CLAW CLAWS)
; Every element of the CLAWS list, a CLAW, must be one of the following:
;	(VARIABLE EXPRESSION)
; or
;	(EXPRESSION)
; or
;	BOUND-VARIABLE
; These CLAWS are evaluated in the strict left-to-right order. For each
; CLAW, the EXPRESSION part is evaluated first
; (or BOUND-VARIABLE is looked up).
;
; If the result is #f, AND-LET* immediately returns #f,
; thus disregarding the rest of the CLAWS and the BODY. If the
; EXPRESSION evaluates to not-#f, and the CLAW is of the form
;	(VARIABLE EXPRESSION)
; the EXPRESSION's value is bound to a freshly made VARIABLE. The VARIABLE is
; available for _the rest_ of the CLAWS, and the BODY.
;
; Thus AND-LET* is a sort of cross-breed between LET* and AND.
;
; Denotation semantics:
;
; Eval[ (AND-LET* (CLAW1 ...) BODY), Env] =
;	EvalClaw[ CLAW1, Env ] andalso 
;		Eval[ (AND-LET* ( ...) BODY), ExtClawEnv[ CLAW1, Env]]
;
; Eval[ (AND-LET* (CLAW) ), Env] = EvalClaw[ CLAW, Env ]
; Eval[ (AND-LET* () FORM1 ...), Env] = Eval[ (BEGIN FORM1 ...), Env ]
; Eval[ (AND-LET* () ), Env] = #t
;
; EvalClaw[ BOUND-VARIABLE, Env ] = Eval[ BOUND-VARIABLE, Env ]
; EvalClaw[ (EXPRESSION), Env ] = Eval[ EXPRESSION, Env ]
; EvalClaw[ (VARIABLE EXPRESSION), Env ] = Eval[ EXPRESSION, Env ]
;
; ExtClawEnv[ BOUND-VARIABLE, Env ] = Env
; ExtClawEnv[ (EXPRESSION), Env ] = EnvAfterEval[ EXPRESSION, Env ]
; ExtClawEnv[ (VARIABLE EXPRESSION), Env ] = 
;	ExtendEnv[ EnvAfterEval[ EXPRESSION, Env ],
;		   VARIABLE boundto Eval[ EXPRESSION, Env ]]
;
; If AND-LET* is implemented as a macro, it converts a AND-LET* expression
; into a "tree" of AND and LET expressions. For example,
;
;     (AND-LET* ((my-list (compute-list)) ((not (null? my-list))))
;	  (do-something my-list))
; is transformed into
;     (and (let ((my-list (compute-list)))
;	(and my-list  (not (null? my-list)) (begin (do-something my-list)))))
;

; Sample applications:
;
; The following piece of code (from my treap package) 
;   (let ((new-root (node:dispatch-on-key root key ...)))
;      (if new-root (set! root new-root)))
; could be elegantly re-written as
;   (and-let* ((new-root (node:dispatch-on-key root key ...)))
;		(set! root new-root))
;
; A very common application of and-let* is looking up a value
; associated with a given key in an assoc list, returning #f in case of a
; look-up failure:
;
;		; Standard implementation
; (define (look-up key alist)
;   (let ((found-assoc (assq key alist)))
;	(and found-assoc (cdr found-assoc))))
;
; 		; A more elegant solution
; (define (look-up key alist)
;   (cdr (or (assq key alist) '(#f . #f))))
;
; 		; An implementation which is just as graceful as the latter
;		; and just as efficient as the former:
; (define (look-up key alist)
;   (and-let* ((x (assq key alist))) (cdr x)))
;
; Generalized cond:
;
; (or
;   (and-let* (bindings-cond1) body1)
;   (and-let* (bindings-cond2) body2)
;   (begin else-clause))
;
; Unlike => (cond's send), AND-LET* applies beyond cond. AND-LET* can
; also be used to generalize cond, as => is limited to sending of
; a single value; AND-LET* allows as many bindings as necessary 
; (which are performed in sequence)
;
; (or
;  (and-let* ((c (read-char)) ((not (eof-object? c))))
;	(string-set! some-str i c) (++! i))
;  (begin (do-process-eof)))
;
; Another concept AND-LET* is reminiscent of is programming with guards:
; an AND-LET* form can be considered a sequence of _guarded_ expressions.
; In a regular program, forms may produce results, bind them to variables
; and let other forms use these results. AND-LET* differs in that it checks
; to make sure that every produced result "makes sense" (that is, not an #f).
; The first "failure" triggers the guard and aborts the rest of the
; sequence (which presumably would not make any sense to execute anyway).
;
; $Id: vland.scm,v 2.0 2002/06/28 19:50:32 oleg Exp oleg $

; -- make sure the implementation of and-let* is included. It is usually
; the part of my prelude.
; We also assume the the myenv prelude is included at this point,
; as well as SRFI-12. For Gambit, do the following:
;   (include "myenv.scm")
;   (include "srf-12.scm")
; prior to evaluation of this file.
; For example: gsi -e '(include "myenv.scm")(include "srfi-12.scm")' vland.scm
; For Bigloo, the following command line can be used:
; echo '(module test (include "myenv-bigloo.scm") (include "srfi-12.scm") 
;        (include "vland.scm"))' | bigloo -i --

(require-extension (unittest))

(require-extension (srfi 2))

(if (not (provided? "srfi-2"))
    (test-skip "SRFI-2 is not enabled"))

(define tn test-name)

(define expect
  (lambda (form expected-result)
    (assert-equal? (tn)
                   expected-result
                   (eval form (interaction-environment)))))

(define must-be-a-syntax-error
  (lambda (form)
    (assert-error (tn)
                  (lambda ()
                    (eval form (interaction-environment))))))


;--- Test cases

; No claws
(tn "and-let* no claws")
(expect  '(and-let* () 1) 1)
(expect  '(and-let* () 1 2) 2)
(expect  '(and-let* () ) #t)

(must-be-a-syntax-error '(and-let* #f #t) )
(must-be-a-syntax-error '(and-let* #f) )

; One claw, no body
(tn "and-let* one claw, no body")
(expect '(let ((x #f)) (and-let* (x))) #f)
(expect '(let ((x 1)) (and-let* (x))) 1)
(expect '(let ((x 1)) (and-let* ( (x) ))) 1)
(expect '(let ((x 1)) (and-let* ( ((+ x 1)) ))) 2)
(expect '(and-let* ((x #f)) ) #f)
(expect '(and-let* ((x 1)) ) 1)
(must-be-a-syntax-error '(and-let* ( #f (x 1))) )

; two claws, no body
(tn "and-let* two claws, no body")
(expect '(and-let* ( (#f) (x 1)) ) #f)
(must-be-a-syntax-error '(and-let* (2 (x 1))) )
(expect '(and-let* ( (2) (x 1)) ) 1)
(expect '(and-let* ( (x 1) (2)) ) 2)
(expect '(and-let* ( (x 1) x) ) 1)
(expect '(and-let* ( (x 1) (x)) ) 1)

; two claws, body
(tn "and-let* two claws, body")
(expect '(let ((x #f)) (and-let* (x) x)) #f)
(expect '(let ((x "")) (and-let* (x) x)) "")
(expect '(let ((x "")) (and-let* (x)  )) "")
(expect '(let ((x 1)) (and-let* (x) (+ x 1))) 2)
(expect '(let ((x #f)) (and-let* (x) (+ x 1))) #f)
(expect '(let ((x 1)) (and-let* (((positive? x))) (+ x 1))) 2)
(expect '(let ((x 1)) (and-let* (((positive? x))) )) #t)
(expect '(let ((x 0)) (and-let* (((positive? x))) (+ x 1))) #f)
(expect '(let ((x 1)) (and-let* (((positive? x)) (x (+ x 1))) (+ x 1)))  3)
(expect
 '(let ((x 1)) (and-let* (((positive? x)) (x (+ x 1)) (x (+ x 1))) (+ x 1)))
 4
)

(expect '(let ((x 1)) (and-let* (x ((positive? x))) (+ x 1))) 2)
(expect '(let ((x 1)) (and-let* ( ((begin x)) ((positive? x))) (+ x 1))) 2)
(expect '(let ((x 0)) (and-let* (x ((positive? x))) (+ x 1))) #f)
(expect '(let ((x #f)) (and-let* (x ((positive? x))) (+ x 1))) #f)
(expect '(let ((x #f)) (and-let* ( ((begin x)) ((positive? x))) (+ x 1))) #f)

(expect  '(let ((x 1)) (and-let* (x (y (- x 1)) ((positive? y))) (/ x y))) #f)
(expect  '(let ((x 0)) (and-let* (x (y (- x 1)) ((positive? y))) (/ x y))) #f)
(expect  '(let ((x #f)) (and-let* (x (y (- x 1)) ((positive? y))) (/ x y))) #f)
(expect  '(let ((x 3)) (and-let* (x (y (- x 1)) ((positive? y))) (/ x y))) (/ 3 2))

(total-report)
