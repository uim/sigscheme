;;  Filename : test-srfi55.scm
;;  About    : unit test for SRFI-55
;;
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

(test-begin "test-srfi55")

(test-begin "require-extension")
;; sscm-ext is enabled by default for SRFI-55
(test-assert (provided? "sscm-ext"))
(require-extension (sscm-ext))
(test-assert (provided? "sscm-ext"))
(test-end "require-extension")

(test-begin "require-extension SRFIs")
(test-assert (not (provided? "srfi-1")))
(test-assert (not (provided? "srfi-2")))
(test-assert (not (provided? "srfi-48")))
(test-assert (not (provided? "srfi-60")))
(require-extension (srfi 1 48 2 60))
(test-assert (provided? "srfi-1"))
(test-assert (provided? "srfi-2"))
(test-assert (provided? "srfi-48"))
(test-assert (provided? "srfi-60"))
;; mixed
(require-extension (sscm-ext) (srfi 1 8 2 60) (sscm-ext) (srfi 23))
(test-assert (provided? "srfi-1"))
(test-assert (provided? "srfi-2"))
(test-assert (provided? "srfi-8"))
(test-assert (provided? "srfi-23"))
(test-assert (provided? "srfi-48"))
(test-assert (provided? "srfi-60"))
(test-assert (provided? "sscm-ext"))
(test-end "require-extension SRFIs")


(test-end "test-srfi55")
