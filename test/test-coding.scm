#! /usr/bin/env sscm -C UTF-8
;; -*- buffer-file-coding-system: utf-8 -*-

;;  Filename : test-coding.scm
;;  About    : Unit tests for coding declarations
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



(require-extension (unittest))

(define tn test-name)

(tn "coding declaration")
(load "test/coding/euc-jp.scm")
(assert-equal? (tn) "日本語" coding-euc-jp)
(assert-equal? (tn) 3 (string-length coding-euc-jp))
(load "test/coding/shift_jis.scm")
(assert-equal? (tn) "日本語" coding-shift-jis)
;; The second line and Emacs' end-of-line suffix
(load "test/coding/utf-8.scm")
(assert-equal? (tn) "日本語" coding-utf-8)

(tn "coding declaration errors")
(assert-error (tn) (lambda () (load "test/coding/invalid.scm")))
(assert-error (tn) (lambda () (load "test/coding/unknown.scm")))

(tn "coding declaration with ISO-8859-1")
;; The generic singlebyte codec reads bytes as is.
(with-char-codec "ISO-8859-1"
  (lambda ()
    (load "test/coding/euc-jp.scm")
    (assert-equal? (tn) 6 (string-length coding-euc-jp))))

(tn "fallback encodings")
(assert-equal? (tn) '() (%%load-fallback-encodings))
;; An unknown encoding is skipped.
(%%set-load-fallback-encodings! '("no-such-encoding" "EUC-JP"))
(assert-equal? (tn) '("no-such-encoding" "EUC-JP") (%%load-fallback-encodings))
(load "test/coding/fallback-euc-jp.scm")
(assert-equal? (tn) "日本語" fallback-euc-jp)
;; A valid file in the current codec isn't converted.
(load "test/coding/fallback-utf-8.scm")
(assert-equal? (tn) "日本語" fallback-utf-8)
;; A coding declaration takes precedence.
(load "test/coding/shift_jis.scm")
(assert-equal? (tn) "日本語" coding-shift-jis)
;; None of the fallback encodings can convert it.
(assert-error (tn) (lambda () (load "test/coding/fallback-invalid.scm")))
(%%set-load-fallback-encodings! '())
(assert-error (tn) (lambda () (%%set-load-fallback-encodings! '(euc-jp))))
(assert-error (tn) (lambda () (%%set-load-fallback-encodings! '("EUC-JP" . 1))))
;; The list is modified after it's set.
(let ((encodings (list "EUC-JP")))
  (%%set-load-fallback-encodings! encodings)
  (set-car! encodings 'euc-jp)
  (assert-error (tn) (lambda () (load "test/coding/fallback-euc-jp.scm")))
  (%%set-load-fallback-encodings! '()))
(assert-error (tn) (lambda () (%%set-load-fallback-encodings! "EUC-JP")))

(tn "broken file")
(assert-error (tn) (lambda () (load "test/coding/fallback-invalid.scm")))
;; The error message has the file name.
(if (symbol-bound? 'error-object-message)
    (let ((message (guard (e (#t (error-object-message e)))
                     (load "test/coding/fallback-invalid.scm")))
          (file "test/coding/fallback-invalid.scm"))
      (assert-equal? (tn)
                     file
                     (substring message
                                (- (string-length message)
                                   (string-length file))
                                (string-length message)))))

(tn "with-load-fallback-encodings")
(set! fallback-euc-jp #f)
(with-load-fallback-encodings '("EUC-JP")
  (lambda ()
    (assert-equal? (tn) '("EUC-JP") (%%load-fallback-encodings))
    (load "test/coding/fallback-euc-jp.scm")))
(assert-equal? (tn) "日本語" fallback-euc-jp)
(assert-equal? (tn) '() (%%load-fallback-encodings))
;; The fallback encodings are restored on error.
(assert-error (tn) (lambda ()
                     (with-load-fallback-encodings '("EUC-JP")
                       (lambda () (error "error")))))
(assert-equal? (tn) '() (%%load-fallback-encodings))

(total-report)
