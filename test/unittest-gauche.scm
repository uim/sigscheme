(require-extension (unittest))

(define test
  (lambda (msg ret func)
    (assert-equal? msg ret (func))))

;; <expr> must be quoted (not compatible with Gauche's)
(define test*
  (lambda (name expected expr . compare)
    (assert-equal? name expected (eval expr (interaction-environment)))))
