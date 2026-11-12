;;  Filename : srfi-64.scm
;;  About    : SRFI-64 A Scheme API for test suites
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

;; Implementation-defined behaviors:
;;
;; * The simple test runner reports failures and a summary to the current
;;   output port. It doesn't write a log file.
;; * The error-type of test-error is #t for any error or a predicate that
;;   is called with the raised object. Other values never match. An error
;;   in the predicate is a failure and actual-error is still the raised
;;   object.
;; * The source-file and source-line result properties aren't set.
;;   The source-form result property is set.
;; * test-expect-fail specifiers aren't called for a skipped test. So
;;   (test-expect-fail 1) is used by the next test that isn't skipped.
;; * Only test-skip specifiers are applied to a test group. A test group
;;   isn't filtered by test-apply and test-expect-fail specifiers. So
;;   tests in a group can be selected by test-apply and (test-expect-fail 1)
;;   is used by the first test in the next group.
;; * A skipped test group is counted as a skipped test without calling
;;   on-test-begin and on-test-end.
;; * The cleanup form of a skipped test-group-with-cleanup isn't
;;   evaluated because nothing in the group is evaluated.
;; * on-group-begin is called before the group is pushed to the group
;;   stack.
;; * The specifiers of a nested test-apply replace the outer ones.
;; * test-on-bad-end-name-simple raises an error. The group is still
;;   active after the error because on-group-end isn't called yet.

(require-extension (srfi 6 9 23 34))


;;
;; Test runners
;;

;; The result kinds in the order of %srfi64-runner-counts.
(define %srfi64-result-kinds '(pass fail xpass xfail skip))

(define-record-type <test-runner>
  (%srfi64-make-runner)
  test-runner?
  ;; An alist of a result kind and the number of the tests.
  (counts %srfi64-runner-counts %srfi64-set-runner-counts!)
  ;; A list of <%srfi64-frame>. The innermost one is the first one. The
  ;; last one is the frame outside of all groups.
  (frames %srfi64-runner-frames %srfi64-set-runner-frames!)
  ;; #f or a list of specifiers given by test-apply.
  (selection %srfi64-runner-selection %srfi64-set-runner-selection!)
  (name test-runner-test-name %srfi64-set-runner-name!)
  (results test-result-alist %srfi64-set-runner-results!)
  ;; Whether on-final has been called. test-apply uses this.
  (finalized? %srfi64-runner-finalized? %srfi64-set-runner-finalized!)
  (aux test-runner-aux-value test-runner-aux-value!)
  (test-begin-callback test-runner-on-test-begin test-runner-on-test-begin!)
  (test-end-callback test-runner-on-test-end test-runner-on-test-end!)
  (group-begin-callback test-runner-on-group-begin
                        test-runner-on-group-begin!)
  (group-end-callback test-runner-on-group-end test-runner-on-group-end!)
  (final-callback test-runner-on-final test-runner-on-final!)
  (bad-count-callback test-runner-on-bad-count test-runner-on-bad-count!)
  (bad-end-name-callback test-runner-on-bad-end-name
                         test-runner-on-bad-end-name!))

;; A test group or the outside of all groups.
(define-record-type <%srfi64-frame>
  (%srfi64-make-frame name expected-count owner? count skips xfails)
  %srfi64-frame?
  ;; Unused for the outside of all groups.
  (name %srfi64-frame-name)
  (expected-count %srfi64-frame-expected-count)
  ;; Whether test-begin of this group installed the runner.
  (owner? %srfi64-frame-owner?)
  ;; The number of the tests in this group. A nested group is one test.
  (count %srfi64-frame-count %srfi64-set-frame-count!)
  ;; The specifiers given by test-skip and test-expect-fail in this group.
  (skips %srfi64-frame-skips %srfi64-set-frame-skips!)
  (xfails %srfi64-frame-xfails %srfi64-set-frame-xfails!))

(define (%srfi64-push-frame! runner name expected-count owner?)
  (%srfi64-set-runner-frames! runner
                              (cons (%srfi64-make-frame name expected-count
                                                        owner? 0 '() '())
                                    (%srfi64-runner-frames runner))))

;; Whether the current frame is the outside of all groups.
(define (%srfi64-outside? runner)
  (null? (cdr (%srfi64-runner-frames runner))))

(define (%srfi64-current-frame runner)
  (car (%srfi64-runner-frames runner)))

(define (%srfi64-count runner kind)
  (cdr (assq kind (%srfi64-runner-counts runner))))

(define (test-runner-pass-count runner) (%srfi64-count runner 'pass))
(define (test-runner-fail-count runner) (%srfi64-count runner 'fail))
(define (test-runner-xpass-count runner) (%srfi64-count runner 'xpass))
(define (test-runner-xfail-count runner) (%srfi64-count runner 'xfail))
(define (test-runner-skip-count runner) (%srfi64-count runner 'skip))

(define (test-runner-reset runner)
  (%srfi64-set-runner-counts! runner
                              (map (lambda (kind) (cons kind 0))
                                   %srfi64-result-kinds))
  (%srfi64-set-runner-frames! runner '())
  (%srfi64-push-frame! runner #f #f #f)
  (%srfi64-set-runner-selection! runner #f)
  (%srfi64-set-runner-name! runner "")
  (%srfi64-set-runner-results! runner '())
  (%srfi64-set-runner-finalized! runner #f))

(define (test-runner-group-stack runner)
  (let loop ((frames (%srfi64-runner-frames runner)))
    (if (null? (cdr frames))
        '()
        (cons (%srfi64-frame-name (car frames)) (loop (cdr frames))))))

(define (test-runner-group-path runner)
  (reverse (test-runner-group-stack runner)))

(define (%srfi64-ignore . args)
  #f)

(define (test-runner-null)
  (let ((runner (%srfi64-make-runner)))
    (test-runner-reset runner)
    (test-runner-aux-value! runner #f)
    (test-runner-on-test-begin! runner %srfi64-ignore)
    (test-runner-on-test-end! runner %srfi64-ignore)
    (test-runner-on-group-begin! runner %srfi64-ignore)
    (test-runner-on-group-end! runner %srfi64-ignore)
    (test-runner-on-final! runner %srfi64-ignore)
    (test-runner-on-bad-count! runner %srfi64-ignore)
    (test-runner-on-bad-end-name! runner %srfi64-ignore)
    runner))

(define test-on-test-begin-simple %srfi64-ignore)

;; Reports a failed test such as:
;;
;;   FAIL: group/name
;;     (source-form + 1 2)
;;     (expected-value . 4)
;;     (actual-value . 3)
(define (%srfi64-report runner label)
  (display label)
  (display ": ")
  (for-each (lambda (group)
              (display group)
              (display "/"))
            (test-runner-group-path runner))
  (display (test-runner-test-name runner))
  (newline)
  (for-each (lambda (entry)
              (if (memq (car entry)
                        '(source-form
                          expected-value
                          actual-value
                          expected-error
                          actual-error))
                  (begin
                    (display "  ")
                    (write entry)
                    (newline))))
            (reverse (test-result-alist runner))))

(define (test-on-test-end-simple runner)
  (case (test-result-kind runner)
    ((fail) (%srfi64-report runner "FAIL"))
    ((xpass) (%srfi64-report runner "XPASS"))))

(define test-on-group-begin-simple %srfi64-ignore)

(define test-on-group-end-simple %srfi64-ignore)

(define (test-on-bad-count-simple runner count expected)
  (display "WARNING: ")
  (display (car (test-runner-group-stack runner)))
  (display ": ")
  (display count)
  (display " tests were run but ")
  (display expected)
  (display " tests were expected")
  (newline))

(define (test-on-bad-end-name-simple runner begin-name end-name)
  (error "test-end: the name doesn't match test-begin" end-name begin-name))

;; Reports a summary such as:
;;
;;   pass: 3, fail: 1, xpass: 0, xfail: 0, skip: 0
(define (test-on-final-simple runner)
  (let loop ((counts (%srfi64-runner-counts runner)))
    (display (caar counts))
    (display ": ")
    (display (cdar counts))
    (if (null? (cdr counts))
        (newline)
        (begin
          (display ", ")
          (loop (cdr counts))))))

(define (test-runner-simple)
  (let ((runner (test-runner-null)))
    (test-runner-on-test-begin! runner test-on-test-begin-simple)
    (test-runner-on-test-end! runner test-on-test-end-simple)
    (test-runner-on-group-begin! runner test-on-group-begin-simple)
    (test-runner-on-group-end! runner test-on-group-end-simple)
    (test-runner-on-bad-count! runner test-on-bad-count-simple)
    (test-runner-on-bad-end-name! runner test-on-bad-end-name-simple)
    (test-runner-on-final! runner test-on-final-simple)
    runner))

;; Returns a procedure that returns VALUE without an argument and
;; replaces VALUE with an argument.
(define (%srfi64-make-variable value)
  (lambda new-value
    (if (null? new-value)
        value
        (set! value (car new-value)))))

(define test-runner-current (%srfi64-make-variable #f))

(define test-runner-factory (%srfi64-make-variable test-runner-simple))

(define (test-runner-get)
  (let ((runner (test-runner-current)))
    (if (not runner)
        (error "test-runner-get: no current test runner"))
    runner))

(define (test-runner-create)
  ((test-runner-factory)))

;; Calls THUNK while (GET) returns VALUE. (PUT VALUE) sets it.
(define (%srfi64-call-with get put value thunk)
  (let ((other value))
    (define (swap!)
      (let ((current (get)))
        (put other)
        (set! other current)))
    (dynamic-wind swap! thunk swap!)))

(define-syntax test-with-runner
  (syntax-rules ()
    ((_ runner)
     (test-with-runner runner #f))
    ((_ runner body ...)
     (%srfi64-call-with test-runner-current test-runner-current runner
                        (lambda () body ...)))))


;;
;; Test results
;;

(define (test-result-ref runner name . default)
  (let ((entry (assq name (test-result-alist runner))))
    (if entry
        (cdr entry)
        (and (pair? default) (car default)))))

(define (test-result-set! runner name value)
  (let ((entry (assq name (test-result-alist runner))))
    (if entry
        (set-cdr! entry value)
        (%srfi64-set-runner-results! runner
                                     (cons (cons name value)
                                           (test-result-alist runner))))))

(define (test-result-remove runner name)
  (%srfi64-set-runner-results!
   runner
   (let remove ((alist (test-result-alist runner)))
     (cond ((null? alist) '())
           ((eq? (caar alist) name) (remove (cdr alist)))
           (else (cons (car alist) (remove (cdr alist))))))))

(define (test-result-clear runner)
  (%srfi64-set-runner-results! runner '()))

(define (test-result-kind . runner)
  (test-result-ref (if (pair? runner) (car runner) (test-runner-get))
                   'result-kind))

(define (test-passed? . runner)
  (if (memq (apply test-result-kind runner) '(pass xpass)) #t #f))


;;
;; Specifiers
;;

(define (%srfi64-specifier specifier)
  (cond ((string? specifier) (test-match-name specifier))
        ((integer? specifier) (test-match-nth 1 specifier))
        ((procedure? specifier) specifier)
        (else (error "test: invalid specifier" specifier))))

;; Calls all SPECIFIERS in order and returns the number of the matched
;; ones. All of them are called because a specifier such as
;; test-match-nth counts calls.
(define (%srfi64-matches specifiers runner)
  (let loop ((specifiers specifiers)
             (n 0))
    (if (null? specifiers)
        n
        (loop (cdr specifiers)
              (if ((car specifiers) runner) (+ n 1) n)))))

(define (%srfi64-any? specifiers runner)
  (> (%srfi64-matches specifiers runner) 0))

(define (test-match-name name)
  (lambda (runner)
    (equal? (test-runner-test-name runner) name)))

(define (test-match-nth n . count)
  (let ((last (+ n (if (pair? count) (car count) 1) -1))
        (calls 0))
    (lambda (runner)
      (set! calls (+ calls 1))
      (and (<= n calls) (<= calls last)))))

(define (test-match-any . specifiers)
  (let ((specifiers (map %srfi64-specifier specifiers)))
    (lambda (runner)
      (%srfi64-any? specifiers runner))))

(define (test-match-all . specifiers)
  (let ((specifiers (map %srfi64-specifier specifiers)))
    (lambda (runner)
      (= (%srfi64-matches specifiers runner) (length specifiers)))))

(define (%srfi64-add-specifier! frame-specifiers put! specifier)
  (let ((frame (%srfi64-current-frame (test-runner-get))))
    (put! frame (cons (%srfi64-specifier specifier)
                      (frame-specifiers frame)))))

(define (test-skip specifier)
  (%srfi64-add-specifier! %srfi64-frame-skips
                          %srfi64-set-frame-skips!
                          specifier))

(define (test-expect-fail specifier)
  (%srfi64-add-specifier! %srfi64-frame-xfails
                          %srfi64-set-frame-xfails!
                          specifier))

;; The specifiers that are active in the current group.
(define (%srfi64-active runner frame-specifiers)
  (apply append (map frame-specifiers (%srfi64-runner-frames runner))))

(define (%srfi64-skipped? runner)
  (%srfi64-any? (%srfi64-active runner %srfi64-frame-skips) runner))


;;
;; Test groups
;;

(define (%srfi64-count! runner)
  (let ((frame (%srfi64-current-frame runner)))
    (%srfi64-set-frame-count! frame (+ (%srfi64-frame-count frame) 1))))

;; Counts a test or a skipped group as KIND.
(define (%srfi64-tally! runner kind)
  (let ((count (assq kind (%srfi64-runner-counts runner))))
    (set-cdr! count (+ (cdr count) 1)))
  (%srfi64-count! runner))

(define (test-begin name . count)
  (let ((owner? (not (test-runner-current))))
    (if owner?
        (test-runner-current (test-runner-create)))
    (let ((runner (test-runner-get))
          (expected-count (and (pair? count) (car count))))
      (%srfi64-set-runner-name! runner name)
      ((test-runner-on-group-begin runner) runner name expected-count)
      (%srfi64-push-frame! runner name expected-count owner?))))

(define (test-end . name)
  (let* ((runner (test-runner-get))
         (frame (%srfi64-current-frame runner))
         (begin-name (%srfi64-frame-name frame))
         (expected-count (%srfi64-frame-expected-count frame))
         (count (%srfi64-frame-count frame)))
    (if (%srfi64-outside? runner)
        (error "test-end: no matching test-begin"))
    (if (and (pair? name) (not (equal? (car name) begin-name)))
        ((test-runner-on-bad-end-name runner) runner begin-name (car name)))
    (if (and expected-count (not (= count expected-count)))
        ((test-runner-on-bad-count runner) runner count expected-count))
    ((test-runner-on-group-end runner) runner)
    (%srfi64-set-runner-frames! runner (cdr (%srfi64-runner-frames runner)))
    (%srfi64-count! runner)
    (if (%srfi64-outside? runner)
        (begin
          ((test-runner-on-final runner) runner)
          (%srfi64-set-runner-finalized! runner #t)))
    (if (%srfi64-frame-owner? frame)
        (test-runner-current #f))))

;; Only test-skip specifiers are applied to a group. A skipped group is
;; counted as a skipped test.
(define (%srfi64-group name thunk)
  (let ((runner (test-runner-current)))
    (if runner
        (%srfi64-set-runner-name! runner name))
    (if (and runner (%srfi64-skipped? runner))
        (begin
          (test-result-clear runner)
          (test-result-set! runner 'result-kind 'skip)
          (%srfi64-tally! runner 'skip))
        (dynamic-wind
            (lambda () (test-begin name))
            thunk
            (lambda () (test-end name))))))

(define-syntax test-group
  (syntax-rules ()
    ((_ name)
     (%srfi64-group name %srfi64-ignore))
    ((_ name body ...)
     (%srfi64-group name (lambda () body ...)))))

;; This moves forms to BODY until the last form that is the cleanup form.
;; "(body ... cleanup)" can't be used as a pattern without R7RS.
(define-syntax %srfi64-group-with-cleanup
  (syntax-rules ()
    ((_ name () cleanup)
     (test-group name cleanup))
    ((_ name (body ...) cleanup)
     (test-group name
                 (dynamic-wind %srfi64-ignore
                               (lambda () body ...)
                               (lambda () cleanup))))
    ((_ name (body ...) form rest ...)
     (%srfi64-group-with-cleanup name (body ... form) rest ...))))

(define-syntax test-group-with-cleanup
  (syntax-rules ()
    ((_ name form ...)
     (%srfi64-group-with-cleanup name () form ...))))


;;
;; Test cases
;;

;; Returns skip, xfail or #f for the next test. The specifiers are called
;; in this order until the disposition is decided: test-apply ones,
;; test-skip ones and test-expect-fail ones.
(define (%srfi64-disposition runner)
  (let ((selection (%srfi64-runner-selection runner)))
    (cond ((and selection (not (%srfi64-any? selection runner))) 'skip)
          ((%srfi64-skipped? runner) 'skip)
          ((%srfi64-any? (%srfi64-active runner %srfi64-frame-xfails) runner)
           'xfail)
          (else #f))))

;; Runs a test. RUN returns whether the test passed. It isn't called if
;; the test is skipped. An error in RUN is a failure.
(define (%srfi64-test runner name form run)
  (test-result-clear runner)
  (%srfi64-set-runner-name! runner name)
  (test-result-set! runner 'source-form form)
  (let ((disposition (%srfi64-disposition runner)))
    (if disposition
        (test-result-set! runner 'result-kind disposition)))
  ((test-runner-on-test-begin runner) runner)
  (let ((kind (test-result-kind runner)))
    (if (not (eq? kind 'skip))
        (let ((passed? (guard (condition
                               (#t
                                (test-result-set! runner
                                                  'actual-error
                                                  condition)
                                #f))
                         (run))))
          (test-result-set! runner
                            'result-kind
                            (cond ((eq? kind 'xfail)
                                   (if passed? 'xpass 'xfail))
                                  (passed? 'pass)
                                  (else 'fail))))))
  (%srfi64-tally! runner (test-result-kind runner))
  ((test-runner-on-test-end runner) runner))

;; Sets the NAME result property to VALUE and returns VALUE.
(define (%srfi64-result! runner name value)
  (test-result-set! runner name value)
  value)

(define (%srfi64-assert runner name form thunk)
  (%srfi64-test runner name form
                (lambda ()
                  (%srfi64-result! runner 'actual-value (thunk)))))

(define (%srfi64-compare runner name form same? expected-thunk thunk)
  (%srfi64-test runner name form
                (lambda ()
                  (let* ((expected (%srfi64-result! runner
                                                    'expected-value
                                                    (expected-thunk)))
                         (actual (%srfi64-result! runner
                                                  'actual-value
                                                  (thunk))))
                    (same? expected actual)))))

(define (%srfi64-error runner name form error-type-thunk thunk)
  (%srfi64-test runner name form
                (lambda ()
                  (let* ((error-type (%srfi64-result! runner
                                                      'expected-error
                                                      (error-type-thunk)))
                         ;; (condition) or #f
                         (raised (guard (condition (#t (list condition)))
                                   (%srfi64-result! runner
                                                    'actual-value
                                                    (thunk))
                                   #f)))
                    (and raised
                         (begin
                           (test-result-set! runner 'actual-error (car raised))
                           (cond ((eq? error-type #t) #t)
                                 ((procedure? error-type)
                                  (guard (condition (#t #f))
                                    (error-type (car raised))))
                                 (else #f))))))))

;; NAME is optional in test-assert, test-eqv, test-equal, test-eq,
;; test-approximate and test-error.

(define-syntax test-assert
  (syntax-rules ()
    ((_ expr)
     (test-assert "" expr))
    ((_ name expr)
     (%srfi64-assert (test-runner-get) name 'expr (lambda () expr)))))

(define-syntax %srfi64-compare-syntax
  (syntax-rules ()
    ((_ same? expected expr)
     (%srfi64-compare-syntax same? "" expected expr))
    ((_ same? name expected expr)
     (%srfi64-compare (test-runner-get) name 'expr same?
                      (lambda () expected)
                      (lambda () expr)))))

(define-syntax test-eqv
  (syntax-rules ()
    ((_ arg ...) (%srfi64-compare-syntax eqv? arg ...))))

(define-syntax test-equal
  (syntax-rules ()
    ((_ arg ...) (%srfi64-compare-syntax equal? arg ...))))

(define-syntax test-eq
  (syntax-rules ()
    ((_ arg ...) (%srfi64-compare-syntax eq? arg ...))))

(define-syntax test-approximate
  (syntax-rules ()
    ((_ expected expr error)
     (test-approximate "" expected expr error))
    ((_ name expected expr error)
     (%srfi64-compare-syntax (lambda (expected-value value)
                               (let ((error-value error))
                                 (and (>= value (- expected-value error-value))
                                      (<= value
                                          (+ expected-value error-value)))))
                             name expected expr))))

(define-syntax test-error
  (syntax-rules ()
    ((_ expr)
     (test-error "" #t expr))
    ((_ error-type expr)
     (test-error "" error-type expr))
    ((_ name error-type expr)
     (%srfi64-error (test-runner-get) name 'expr (lambda () error-type)
                    (lambda () expr)))))


;;
;; Miscellaneous
;;

;; (test-apply [runner] specifier ... procedure)
(define (test-apply . args)
  (let* ((given-runner (and (test-runner? (car args)) (car args)))
         (reversed-args (reverse (if given-runner (cdr args) args)))
         (procedure (car reversed-args))
         (selection (map %srfi64-specifier (reverse (cdr reversed-args))))
         (created? (not (or given-runner (test-runner-current))))
         (runner (or given-runner (test-runner-current) (test-runner-create))))
    (test-with-runner runner
      (if (null? selection)
          (procedure)
          (%srfi64-call-with
           (lambda () (%srfi64-runner-selection runner))
           (lambda (selection)
             (%srfi64-set-runner-selection! runner selection))
           selection
           procedure)))
    ;; The outermost test-end in PROCEDURE may call on-final.
    (if (and created? (not (%srfi64-runner-finalized? runner)))
        ((test-runner-on-final runner) runner))))

(define (test-read-eval-string string)
  (let ((port (open-input-string string)))
    (let ((datum (read port)))
      (if (or (eof-object? datum)
              (not (eof-object? (peek-char port))))
          (error "test-read-eval-string: not exactly one datum" string))
      (eval datum (interaction-environment)))))
