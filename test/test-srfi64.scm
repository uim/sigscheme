;;  Filename : test-srfi64.scm
;;  About    : unit test for SRFI-64
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

;; This doesn't use unittest.scm because it defines test-begin, test-skip
;; and so on too. SRFI-64 itself is tested by running tests with another
;; runner in an outer test suite.

(require-extension (srfi 64))

;; Runs THUNK with a new null runner and returns the runner. Its aux-value
;; is a list of (name kind result-alist) of the run tests. The last test is
;; the first one.
(define (run thunk)
  (let ((runner (test-runner-null)))
    (test-runner-aux-value! runner '())
    (test-runner-on-test-end!
     runner
     (lambda (runner)
       (test-runner-aux-value! runner
                               (cons (list (test-runner-test-name runner)
                                           (test-result-kind runner)
                                           (test-result-alist runner))
                                     (test-runner-aux-value runner)))))
    (test-with-runner runner (thunk))
    runner))

;; Returns (pass fail xpass xfail skip) counts of tests run by THUNK.
(define (counts thunk)
  (let ((runner (run thunk)))
    (map (lambda (count) (count runner))
         (list test-runner-pass-count
               test-runner-fail-count
               test-runner-xpass-count
               test-runner-xfail-count
               test-runner-skip-count))))

;; Returns ((name . kind) ...) of tests run by THUNK.
(define (kinds thunk)
  (map (lambda (test) (cons (car test) (cadr test)))
       (reverse (test-runner-aux-value (run thunk)))))

;; Returns the result alist of the last test run by THUNK.
(define (last-result thunk)
  (car (cddr (car (test-runner-aux-value (run thunk))))))

(define (result-ref alist name)
  (let ((pair (assq name alist)))
    (and pair (cdr pair))))

;; Returns the output of THUNK to the current output port.
(define (output-of thunk)
  (let ((port (open-output-string))
        (saved-port (current-output-port)))
    (dynamic-wind
        (lambda () (%%set-current-output-port! port))
        thunk
        (lambda () (%%set-current-output-port! saved-port)))
    (get-output-string port)))

;; Joins LINES with newlines.
(define (lines . lines)
  (apply string-append
         (map (lambda (line) (string-append line (string #\newline)))
              lines)))

(test-begin "SRFI-64")
(define main-runner (test-runner-current))

(test-group "test-assert"
  (test-equal '(2 2 0 0 0)
              (counts (lambda ()
                        (test-assert "true" #t)
                        (test-assert "false" #f)
                        (test-assert 1)
                        (test-assert (car '())))))
  (test-equal '(("true" . pass) ("" . fail))
              (kinds (lambda ()
                       (test-assert "true" #t)
                       (test-assert #f))))
  (let ((result (last-result (lambda () (test-assert "value" (+ 1 2))))))
    (test-equal 'pass (result-ref result 'result-kind))
    (test-equal '(+ 1 2) (result-ref result 'source-form))
    (test-equal 3 (result-ref result 'actual-value)))
  (let ((result (last-result (lambda () (test-assert (car '()))))))
    (test-equal 'fail (result-ref result 'result-kind))
    (test-assert (%%error-object? (result-ref result 'actual-error)))))

(test-group "test-eqv, test-equal and test-eq"
  (test-equal '(3 3 0 0 0)
              (counts (lambda ()
                        (test-eqv "eqv" 3 (+ 1 2))
                        (test-eqv 3 (+ 1 1))
                        (test-equal "equal" '(1 (2)) (list 1 (list 2)))
                        (test-equal '(1) (list 2))
                        (test-eq 'a 'a)
                        (test-eq "eq" '(1) (list 1)))))
  (let ((result (last-result (lambda () (test-equal "e" '(1) (list 2))))))
    (test-equal 'fail (result-ref result 'result-kind))
    (test-equal '(1) (result-ref result 'expected-value))
    (test-equal '(2) (result-ref result 'actual-value)))
  (test-equal '(0 1 0 0 0)
              (counts (lambda () (test-equal 1 (car '())))))
  (test-equal "error in expected"
              '(0 1 0 0 0)
              (counts (lambda () (test-eqv (car '()) 1))))
  (let ((result (last-result (lambda () (test-eqv (car '()) 1)))))
    (test-assert (%%error-object? (result-ref result 'actual-error))))
  (test-equal '(("eqv" . pass) ("" . fail))
              (kinds (lambda ()
                       (test-eqv "eqv" 1 1)
                       (test-eqv 1 2)))))

(test-group "test-approximate"
  (test-equal '(2 2 0 0 0)
              (counts (lambda ()
                        (test-approximate "upper" 10 11 1)
                        (test-approximate 10 9 1)
                        (test-approximate 10 12 1)
                        (test-approximate "lower" 10 8 1))))
  (let ((evaluations 0))
    (run (lambda ()
           (test-approximate 10 10
                             (begin (set! evaluations (+ evaluations 1)) 1))))
    (test-equal "error is evaluated once" 1 evaluations)))

(test-group "test-error"
  (test-equal '(4 2 0 0 0)
              (counts (lambda ()
                        (test-error (car '()))
                        (test-error #t (car '()))
                        (test-error "named" #t (car '()))
                        (test-error "predicate"
                                    %%error-object?
                                    (error "error"))
                        (test-error "unmatched" string? (error "error"))
                        (test-error "no error" #t (+ 1 2)))))
  (let ((result (last-result (lambda () (test-error #t (error "error" 1))))))
    (test-equal 'pass (result-ref result 'result-kind))
    (test-equal #t (result-ref result 'expected-error))
    (test-assert (%%error-object? (result-ref result 'actual-error))))
  (test-equal "error in predicate"
              '(0 1 0 0 0)
              (counts (lambda ()
                        (test-error (lambda (err) (car '()))
                                    (error "error")))))
  (let ((result (last-result (lambda ()
                               (test-error (lambda (err) (car '()))
                                           (raise 'raised))))))
    (test-equal "actual-error after an error in predicate"
                'raised
                (result-ref result 'actual-error)))
  ;; Only #t and a predicate are supported as error-type.
  (test-equal '(0 2 0 0 0)
              (counts (lambda ()
                        (test-error 'symbol (raise 'symbol))
                        (test-error "string" "string" (error "string")))))
  (let ((evaluated? #f))
    (test-equal '(0 0 0 0 1)
                (counts (lambda ()
                          (test-skip 1)
                          (test-error (begin (set! evaluated? #t) #t)
                                      (error "error")))))
    (test-assert "error-type isn't evaluated when skipped" (not evaluated?)))
  (let ((result (last-result (lambda () (test-error #t (+ 1 2))))))
    (test-equal 'fail (result-ref result 'result-kind))
    (test-equal 3 (result-ref result 'actual-value))))

(test-group "test-skip"
  (test-equal '(("a" . pass) ("b" . skip) ("c" . pass) ("b" . skip))
              (kinds (lambda ()
                       (test-skip "b")
                       (test-assert "a" #t)
                       (test-assert "b" (car '()))
                       (test-assert "c" #t)
                       (test-assert "b" #t))))
  (test-equal '(("a" . skip) ("b" . skip) ("c" . pass))
              (kinds (lambda ()
                       (test-skip 2)
                       (test-assert "a" #t)
                       (test-assert "b" #t)
                       (test-assert "c" #t))))
  (test-equal '(("a" . pass) ("b" . skip) ("c" . skip) ("d" . pass))
              (kinds (lambda ()
                       (test-skip (test-match-nth 2 2))
                       (test-assert "a" #t)
                       (test-assert "b" #t)
                       (test-assert "c" #t)
                       (test-assert "d" #t))))
  ;; A specifier is active until the end of the current group.
  (test-equal '(("a" . skip) ("a" . pass))
              (kinds (lambda ()
                       (test-begin "outer")
                       (test-begin "inner")
                       (test-skip "a")
                       (test-assert "a" #t)
                       (test-end "inner")
                       (test-assert "a" #t)
                       (test-end "outer")))))

(test-group "test-expect-fail"
  (test-equal '(("a" . xfail) ("b" . xpass) ("c" . pass) ("d" . fail))
              (kinds (lambda ()
                       (test-expect-fail 2)
                       (test-assert "a" #f)
                       (test-assert "b" #t)
                       (test-assert "c" #t)
                       (test-assert "d" #f))))
  (test-equal '(0 0 0 1 0)
              (counts (lambda ()
                        (test-expect-fail "error")
                        (test-equal "error" 1 (car '())))))
  ;; A skipped test doesn't use test-expect-fail specifiers.
  (test-equal '(("a" . skip) ("b" . xfail) ("c" . fail))
              (kinds (lambda ()
                       (test-skip "a")
                       (test-expect-fail 1)
                       (test-assert "a" #f)
                       (test-assert "b" #f)
                       (test-assert "c" #f)))))

(test-group "test-match-any and test-match-all"
  (test-equal '(("a" . skip) ("b" . skip) ("c" . pass))
              (kinds (lambda ()
                       (test-skip (test-match-any "a" "b"))
                       (test-assert "a" #t)
                       (test-assert "b" #t)
                       (test-assert "c" #t))))
  (test-equal '(("a" . pass) ("b" . skip) ("b" . pass))
              (kinds (lambda ()
                       (test-skip (test-match-all "b" 2))
                       (test-assert "a" #t)
                       (test-assert "b" #t)
                       (test-assert "b" #t))))
  ;; All specifiers are called for each test to count tests.
  (test-equal '(("a" . skip) ("b" . skip) ("c" . pass))
              (kinds (lambda ()
                       (test-skip (test-match-any "a" (test-match-nth 2)))
                       (test-assert "a" #t)
                       (test-assert "b" #t)
                       (test-assert "c" #t))))
  (test-equal '(("a" . pass) ("b" . skip) ("c" . pass))
              (kinds (lambda ()
                       (test-skip (test-match-all "b" (test-match-nth 2)))
                       (test-assert "a" #t)
                       (test-assert "b" #t)
                       (test-assert "c" #t)))))

(test-group "test-group"
  (test-equal '(("g1-a" . pass) ("g1-b" . fail))
              (kinds (lambda ()
                       (test-group "g1"
                         (define x 1)
                         (test-eqv "g1-a" 1 x)
                         (test-eqv "g1-b" 2 x)))))
  (let ((executed? #f))
    (test-equal '()
                (kinds (lambda ()
                         (test-skip "g")
                         (test-group "g"
                           (set! executed? #t)
                           (test-assert "a" #t)))))
    (test-assert "skipped group isn't executed" (not executed?)))
  ;; A skipped group is counted as a skipped test.
  (test-equal '(1 0 0 0 1)
              (counts (lambda ()
                        (test-skip "g")
                        (test-group "g" (test-assert "a" #t))
                        (test-assert "b" #t))))
  (let ((bad-count #f))
    (let ((runner (test-runner-null)))
      (test-runner-on-bad-count! runner
                                 (lambda (runner count expected)
                                   (set! bad-count (list count expected))))
      (test-with-runner runner
        (test-begin "outer" 2)
        (test-skip "g")
        (test-group "g" (test-assert "a" #t))
        (test-assert "b" #t)
        (test-end "outer")))
    (test-equal "skipped group in count" #f bad-count))
  ;; A group is checked only by test-skip specifiers. So the first test in
  ;; the group is the first one for test-expect-fail.
  (test-equal '(("a" . xfail) ("b" . pass))
              (kinds (lambda ()
                       (test-expect-fail (test-match-nth 1))
                       (test-group "g"
                         (test-assert "a" #f)
                         (test-assert "b" #t)))))
  (let ((stacks '()))
    (run (lambda ()
           (test-group "outer"
             (test-group "inner"
               (set! stacks
                     (list (test-runner-group-stack (test-runner-current))
                           (test-runner-group-path (test-runner-current))))))))
    (test-equal '(("inner" "outer") ("outer" "inner")) stacks)))

(test-group "empty body"
  (test-equal '(0 0 0 0 0)
              (counts (lambda () (test-group "g"))))
  (test-eq #f (test-with-runner (test-runner-null))))

(test-group "test-group-with-cleanup"
  (let ((cleaned? #f))
    (test-equal '(("a" . pass))
                (kinds (lambda ()
                         (test-group-with-cleanup "g"
                           (test-assert "a" #t)
                           (set! cleaned? #t)))))
    (test-assert "cleanup" cleaned?))
  (let ((cleaned? #f))
    (guard (err (#t #f))
      (run (lambda ()
             (test-group-with-cleanup "g"
               (error "error in the body")
               (set! cleaned? #t)))))
    (test-assert "cleanup after an error" cleaned?))
  (let ((cleaned? #f))
    (run (lambda ()
           (test-group-with-cleanup "g"
             (set! cleaned? #t))))
    (test-assert "only cleanup" cleaned?))
  (test-equal '(("defined" . pass))
              (kinds (lambda ()
                       (test-group-with-cleanup "g"
                         (define x 1)
                         (test-eqv "defined" 1 x)
                         #f)))))

(test-group "test-begin and test-end"
  (let ((events '()))
    (define (record! event) (set! events (cons event events)))
    (let ((runner (test-runner-null)))
      (test-runner-on-group-begin! runner
                                   (lambda (runner name count)
                                     (record! (list 'begin name count))))
      (test-runner-on-group-end! runner
                                 (lambda (runner)
                                   (record! (list 'end
                                                  (test-runner-group-stack
                                                   runner)))))
      (test-runner-on-bad-count! runner
                                 (lambda (runner count expected)
                                   (record! (list 'bad-count count expected))))
      (test-runner-on-bad-end-name! runner
                                    (lambda (runner begin-name end-name)
                                      (record! (list 'bad-end-name
                                                     begin-name end-name))))
      (test-runner-on-final! runner (lambda (runner) (record! 'final)))
      (test-with-runner runner
        (test-begin "outer" 2)
        (test-begin "inner" 1)
        (test-assert #t)
        (test-assert #t)
        (test-end "wrong")
        (test-end "outer")))
    (test-equal '((begin "outer" 2)
                  (begin "inner" 1)
                  (bad-end-name "inner" "wrong")
                  (bad-count 2 1)
                  (end ("inner" "outer"))
                  (bad-count 1 2)
                  (end ("outer"))
                  final)
                (reverse events)))
  (test-error "test-end without test-begin"
              #t
              (run (lambda () (test-end))))
  (test-error "simple bad end name"
              #t
              (run (lambda ()
                     (test-runner-on-bad-end-name! (test-runner-current)
                                                   test-on-bad-end-name-simple)
                     (test-begin "a")
                     (test-end "b")))))

(test-group "test runners"
  (test-assert (test-runner? (test-runner-null)))
  (test-assert (test-runner? (test-runner-simple)))
  (test-assert (not (test-runner? 'runner)))
  (test-eq main-runner (test-runner-current))
  (test-eq main-runner (test-runner-get))
  (let ((runner (test-runner-null)))
    (test-with-runner runner
      (test-assert #t))
    (test-eq "test-with-runner restores" main-runner (test-runner-current))
    (test-equal 1 (test-runner-pass-count runner))
    (test-runner-aux-value! runner 'aux)
    (test-eq 'aux (test-runner-aux-value runner))
    (test-runner-reset runner)
    (test-equal 0 (test-runner-pass-count runner)))
  ;; test-begin installs a new runner only if there is no current runner.
  (let ((saved-runner (test-runner-current))
        (saved-factory (test-runner-factory))
        (created #f)
        (installed #f)
        (finalized? #f)
        (after-end #t))
    (test-runner-current #f)
    (test-runner-factory
     (lambda ()
       (let ((runner (test-runner-null)))
         (set! created runner)
         (test-runner-on-final! runner
                                (lambda (runner) (set! finalized? #t)))
         runner)))
    (guard (err (#t #f))
      (test-runner-get))
    (test-begin "implicit")
    (set! installed (test-runner-current))
    (test-end "implicit")
    (set! after-end (test-runner-current))
    (test-runner-factory saved-factory)
    (test-runner-current saved-runner)
    (test-eq "test-begin installs" created installed)
    (test-assert "test-end calls on-final" finalized?)
    (test-eq "test-end uninstalls" #f after-end))
  (test-error "test-runner-get without runner"
              #t
              (let ((saved-runner (test-runner-current)))
                (dynamic-wind
                    (lambda () (test-runner-current #f))
                    (lambda () (test-runner-get))
                    (lambda () (test-runner-current saved-runner)))))
  (let ((names '()))
    (let ((runner (test-runner-null)))
      (test-runner-on-test-begin!
       runner
       (lambda (runner)
         (set! names (cons (test-runner-test-name runner) names))
         (if (equal? (test-runner-test-name runner) "skip-by-callback")
             (test-result-set! runner 'result-kind 'skip))))
      (test-equal '(1 0 0 0 1)
                  (list (begin
                          (test-with-runner runner
                            (test-assert "a" #t)
                            (test-assert "skip-by-callback" (car '())))
                          (test-runner-pass-count runner))
                        (test-runner-fail-count runner)
                        (test-runner-xpass-count runner)
                        (test-runner-xfail-count runner)
                        (test-runner-skip-count runner))))
    (test-equal '("a" "skip-by-callback") (reverse names))))

(test-group "test-runner-simple"
  (let ((runner (test-runner-simple)))
    (test-eq test-on-test-begin-simple (test-runner-on-test-begin runner))
    (test-eq test-on-test-end-simple (test-runner-on-test-end runner))
    (test-eq test-on-group-begin-simple (test-runner-on-group-begin runner))
    (test-eq test-on-group-end-simple (test-runner-on-group-end runner))
    (test-eq test-on-bad-count-simple (test-runner-on-bad-count runner))
    (test-eq test-on-bad-end-name-simple
             (test-runner-on-bad-end-name runner))
    (test-eq test-on-final-simple (test-runner-on-final runner)))
  (test-equal (lines "FAIL: g/ng"
                     "  (source-form + 1 2)"
                     "  (expected-value . 4)"
                     "  (actual-value . 3)"
                     "FAIL: g/string"
                     "  (source-form . \"b\")"
                     "  (expected-value . \"a\")"
                     "  (actual-value . \"b\")"
                     "XPASS: g/xpass"
                     "  (source-form . #t)"
                     "  (actual-value . #t)"
                     "WARNING: g: 5 tests were run but 3 tests were expected"
                     "pass: 1, fail: 2, xpass: 1, xfail: 0, skip: 1")
              (output-of (lambda ()
                           (test-with-runner (test-runner-simple)
                             (test-begin "g" 3)
                             (test-assert "ok" #t)
                             (test-equal "ng" 4 (+ 1 2))
                             (test-equal "string" "a" "b")
                             (test-expect-fail "xpass")
                             (test-assert "xpass" #t)
                             (test-skip "skip")
                             (test-assert "skip" #f)
                             (test-end "g"))))))

(test-group "test results"
  ;; The results of the most recent test are available until a new test
  ;; starts.
  (let ((runner (test-runner-null))
        (results '()))
    (test-with-runner runner
      (test-assert "t" #t)
      (test-begin "g")
      (set! results (cons (test-result-kind) results))
      (test-group "inner"
        (set! results (cons (test-result-kind) results)))
      (test-end "g"))
    (test-equal '(pass pass) results))
  (let ((runner (test-runner-null)))
    (test-with-runner runner
      (test-assert "a" #t))
    (test-eq 'pass (test-result-kind runner))
    (test-assert (test-passed? runner))
    (test-result-set! runner 'custom 1)
    (test-equal 1 (test-result-ref runner 'custom))
    (test-result-set! runner 'custom 2)
    (test-equal 2 (test-result-ref runner 'custom))
    (test-equal #f (test-result-ref runner 'unknown))
    (test-equal 'default (test-result-ref runner 'unknown 'default))
    (test-result-remove runner 'custom)
    (test-equal #f (test-result-ref runner 'custom))
    (test-assert (assq 'result-kind (test-result-alist runner)))
    (test-result-clear runner)
    (test-equal '() (test-result-alist runner))
    (test-equal #f (test-result-kind runner))
    (test-assert (not (test-passed? runner))))
  (let ((runner (test-runner-null)))
    (test-with-runner runner
      (test-expect-fail 1)
      (test-assert #t))
    (test-eq 'xpass (test-result-kind runner))
    (test-assert (test-passed? runner))))

(test-group "test-apply"
  (test-equal '(("a" . pass) ("b" . skip) ("c" . pass))
              (kinds (lambda ()
                       (test-apply "a" "c"
                                   (lambda ()
                                     (test-assert "a" #t)
                                     (test-assert "b" #t)
                                     (test-assert "c" #t))))))
  (let ((runner (test-runner-null)))
    (test-apply runner (lambda () (test-assert "a" #t)))
    (test-equal 1 (test-runner-pass-count runner))
    (test-eq "test-apply restores" main-runner (test-runner-current)))
  (test-equal '(("a" . pass) ("b" . skip) ("b" . pass))
              (kinds (lambda ()
                       (test-apply "a"
                                   (lambda ()
                                     (test-assert "a" #t)
                                     (test-assert "b" #t)))
                       (test-assert "b" #t))))
  ;; on-final is called once when test-apply creates a runner.
  (let ((saved-runner (test-runner-current))
        (saved-factory (test-runner-factory))
        (finals '()))
    (test-runner-current #f)
    (test-runner-factory
     (lambda ()
       (let ((runner (test-runner-null)))
         (test-runner-on-final! runner
                                (lambda (runner)
                                  (set! finals
                                        (cons (test-runner-pass-count runner)
                                              finals))))
         runner)))
    (test-apply (lambda () (test-assert #t)))
    (test-apply (lambda ()
                  (test-begin "g")
                  (test-assert #t)
                  (test-end "g")))
    (test-runner-factory saved-factory)
    (test-runner-current saved-runner)
    (test-equal "test-apply calls on-final once" '(1 1) finals))
  ;; test-skip specifiers aren't called for a test that isn't selected.
  (test-equal '(("a" . skip) ("b" . pass) ("c" . skip))
              (kinds (lambda ()
                       (test-skip (test-match-nth 2))
                       (test-apply "b" "c"
                                   (lambda ()
                                     (test-assert "a" #t)
                                     (test-assert "b" #t)
                                     (test-assert "c" #t))))))
  ;; A test group isn't filtered by test-apply.
  (test-equal '(("a" . pass) ("b" . skip))
              (kinds (lambda ()
                       (test-apply "a"
                                   (lambda ()
                                     (test-group "g"
                                       (test-assert "a" #t)
                                       (test-assert "b" #t))))))))

(test-group "test-read-eval-string"
  (test-equal 6 (test-read-eval-string "(* 2 3)"))
  (test-equal 'a (test-read-eval-string " 'a"))
  (test-error #t (test-read-eval-string "1 2"))
  ;; Characters after the datum aren't allowed even if they are spaces.
  (test-error #t (test-read-eval-string "1 "))
  (test-error #t (test-read-eval-string "")))

(test-end "SRFI-64")

;; Counting may be broken. So no passed tests is also a failure.
(exit (if (and (= (test-runner-fail-count main-runner) 0)
               (= (test-runner-xpass-count main-runner) 0)
               (> (test-runner-pass-count main-runner) 0))
          0
          1))
