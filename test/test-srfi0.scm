;;  Filename : test-srfi0.scm
;;  About    : unit tests for SRFI-0
;;
;;  Copyright (c) 2007-2008 SigScheme Project <uim-en AT googlegroups.com>
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


(test-begin "cond-expand invalid forms")
(test-error (cond-expand))
(test-error (cond-expand (nonexistent)))
(test-error (cond-expand ((not srfi-0))))
(test-error (cond-expand ((not))))
(test-error (cond-expand ((not nonexistent nonexistent))))
(test-error (cond-expand ((invalid))))
;; cond-expand may only be placed to toplevel
(test-error (if #t (cond-expand (else #t))))
(test-error ((lambda () (cond-expand (else #t)))))
(test-end)

(test-begin "cond-expand null matched body")
(test-eq (undef) (eval '(cond-expand (else))
                       (interaction-environment)))
(test-eq (undef) (eval '(cond-expand (srfi-0))
                       (interaction-environment)))
(test-eq (undef) (eval '(cond-expand (sigscheme))
                       (interaction-environment)))
(test-eq (undef) (eval '(cond-expand ((or)) (else))
                       (interaction-environment)))
(test-eq (undef) (eval '(cond-expand ((and)))
                       (interaction-environment)))
(test-eq (undef) (eval '(cond-expand ((not nonexistent)))
                       (interaction-environment)))
(test-end)

(test-begin "cond-expand")
(test-end)

(test-report-result)
