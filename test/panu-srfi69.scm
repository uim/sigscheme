;; Written by Panu Kalliokoski. Although the license is expected as same as
;; http://srfi.schemers.org/srfi-69/srfi-69.html, there is no license
;; indication.

;; ChangeLog
;;
;; 2007-08-07 yamaken    Imported from
;;                       http://members.sange.fi/~atehwa/vc/r+d/guse/srfi/test-hash.ss
;;                       and adapted to SigScheme

(require-extension (unittest))

(require-extension (srfi 38 69))

(define tn test-name)

(define assert-orig assert)
(define assert
  (lambda (test)
    (let ((name (test-name)))
      (assert-orig name name test))))

;(define-syntax assert
;  (syntax-rules ()
;    ((assert test) (if (not test) (error "failed assertion: " 'test)))))

(tn "SRFI-69")

(assert (not (hash-table? 'h)))

(assert (integer? (hash #\c)))
(assert (integer? (string-hash "ikK#c")))
(assert (integer? (string-ci-hash "ikK#c")))
(assert (integer? (symbol-hash 'ebbaa)))

(define h (make-hash-table))
(assert (hash-table? h))
(assert (= 0 (hash-table-size h)))
(hash-table-set! h 'foo 'bar)
(assert (= 1 (hash-table-size h)))
(assert (eq? 'bar (hash-table-ref h 'foo)))
(assert (eq? 'baz (hash-table-ref/default h 'bar 'baz)))
(hash-table-set! h 'foo "metavariable")
(assert (= 1 (hash-table-size h)))
(assert (equal? "metavariable" (hash-table-ref h 'foo)))
(hash-table-set! h "foo" "string")
(assert (= 2 (hash-table-size h)))
(assert (hash-table-exists? h "foo"))
(assert (hash-table-exists? h 'foo))
(assert (not (hash-table-exists? h 'baz)))
(hash-table-delete! h 'foo)
(assert (= 1 (hash-table-size h)))
(hash-table-delete! h 'foo)
(assert (= 1 (hash-table-size h)))
(assert (not (hash-table-ref/default h 'foo #f)))

;; SigScheme does not have non-integer numbers.  -- YamaKen 2007-08-07
;;(define example-data
;;  '(1 2 3 4 5 6 7 8 9 10 "a" "b" #\c #t 3/5 #f
;;    5+3i (a b) et ot a b "maizen" #(t o e) x))
(define example-data
  '(1 2 3 4 5 6 7 8 9 10 "a" "b" #\c #t #f
    (a b) et ot a b "maizen" #(t o e) x))
(for-each (lambda (v) (hash-table-set! h v v)) example-data)
(hash-table-delete! h "foo")
(assert (= (hash-table-size h) (length example-data)))
(for-each (lambda (v) (assert (equal? v (hash-table-ref h v)))) example-data)
(hash-table-walk h
  (lambda (k v)
    (assert (equal? k v))
    (assert (member k example-data))))

(define (iota n)
  (let loop ((val 0))
    (if (>= val n) '()
      (cons val (loop (+ val 1))))))
(assert (equal? (iota 10) '(0 1 2 3 4 5 6 7 8 9)))
(for-each (lambda (v) (hash-table-set! h v (+ v 1))) (iota 70))
(assert (= (hash-table-size h) (+ 60 (length example-data))))
(assert (= 4 (hash-table-ref h 3)))
(assert (= 63 (hash-table-ref h 62)))
(assert (eq? 'et (hash-table-ref h 'et)))
(assert (equal? '(a b) (hash-table-ref h '(a b))))

(assert (= (hash-table-size h) (hash-table-fold h (lambda (k v n) (+ n 1)) 0)))
(define vals (hash-table-values h))
(for-each (lambda (key)
	    (assert (member (hash-table-ref h key) vals)))
	  (hash-table-keys h))

(for-each (lambda (v) (hash-table-delete! h v)) (iota 40))
(assert (= (hash-table-size h) (+ 20 (length example-data))))
(for-each (lambda (v) (hash-table-delete! h v)) (iota 40))
(assert (= (hash-table-size h) (+ 20 (length example-data))))

(define h2-data '((a b) (a y) (c d) (c foo) (e f)))
(define h2 (alist->hash-table h2-data eq?))
(assert (= 3 (hash-table-size h2)))
(assert (equal? '(b) (hash-table-ref h2 'a)))
(for-each (lambda (k)
	    (assert (equal? (hash-table-ref h2 k)
			    (cdr (assq k h2-data))))) (hash-table-keys h2))
(for-each (lambda (node)
	    (assert (eq? (cadr (assq (car node) h2-data)) (cadr node))))
	  (hash-table->alist h2))
(for-each (lambda (val) (assert (member val (hash-table-values h2))))
	  '((b) (d) (f)))

(hash-table-walk h (lambda (key val) (hash-table-set! h2 key val)))
(assert (hash-table-exists? h2 'c))
(assert (hash-table-exists? h2 'ot))
(assert (not (hash-table-exists? h2 'zip)))

(define h3 (make-hash-table string-ci=?))
(hash-table-set! h3 "foo" "bar")
(hash-table-set! h3 "Foo" "gar")
(hash-table-set! h3 "FOO" "zar")
(assert (= 1 (hash-table-size h3)))
(assert (string=? "zar" (hash-table-ref h3 "foO")))

(define char-src "meille TEILLE noille muille puille JOTAIN saarinen")
(for-each (lambda (s)
	    (hash-table-set! h3 s (string-append "-" s "-"))
	    (hash-table-set! h3 (string-append "*" s) s))
	  (map make-string (iota 50) (string->list char-src)))
(for-each (lambda (key) (assert (string? (hash-table-ref h3 key))))
	  (hash-table-keys h3))
(assert (= 101 (hash-table-size h3)))
(hash-table-set! h3 "E" "ei mittee")
(hash-table-set! h3 "ttttttt" 'kiitoksia)
(assert (= 101 (hash-table-size h3)))
(hash-table-set! h3 "tttttt" '(kuusi t-kirjainta))
(assert (= 102 (hash-table-size h3)))

(define h4 (alist->hash-table (map list (iota 300)) = modulo))
(define (prime? n)
  (let loop ((divisor 2))
    (cond ((> (* divisor divisor) n) #t)
	  ((= 0 (modulo n divisor)) #f)
	  (else (loop (+ divisor 1))))))
(assert (equal? (map prime? (iota 12)) '(#t #t #t #t #f #t #f #t #f #f #f #t)))
(hash-table-walk h4
  (lambda (key val) (if (prime? key) (hash-table-set! h4 key (* key key)))))
(assert (= 1369 (hash-table-ref h4 37)))
(assert (null? (hash-table-ref h4 250)))
(assert (= 300 (hash-table-size h4)))

(hash-table-walk h3
  (lambda (key val) (if (null? (hash-table-ref h4 (string-length key)))
		      (hash-table-delete! h3 key))))
(hash-table-walk h3
  (lambda (key val) (assert (prime? (string-length key)))))

(for-each (lambda (k) (hash-table-delete! h4 k))
	  (map (lambda (x) (* x x)) (iota 20)))
(assert (= 282 (hash-table-size h4)))

(assert (hash-table? (make-symbol-hash-table)))
(assert (hash-table? (make-string-hash-table)))
(assert (hash-table? (make-string-ci-hash-table)))
(assert (hash-table? (make-integer-hash-table)))

(define h4c (hash-table-copy h4))
(assert (= 1369 (hash-table-ref h4c 37)))
(assert (null? (hash-table-ref h4c 250)))
(assert (= 282 (hash-table-size h4c)))

(hash-table-update! h4c 37 (lambda (value) (- value 100)))
(assert (= 1269 (hash-table-ref h4c 37)))
(hash-table-update!/default h4c 473298 number? 'foo)
(assert (eq? #f (hash-table-ref h4c 473298)))

(hash-table-merge! h4c h4)
(assert (= 283 (hash-table-size h4c)))
(assert (= 1369 (hash-table-ref h4c 37)))


(total-report)
