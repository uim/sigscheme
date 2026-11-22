;;  Filename : test-srfi60.scm
;;  About    : unit test for SRFI-60 integers as bits
;;
;;  Copyright (C) 2005-2006 YAMAMOTO Kengo <yamaken AT bp.iij4u.or.jp>
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

(require-extension (srfi 60))

(test-begin "test-srfi60")


;;
;; Bitwise Operations
;;

(test-begin "logand invalid form")
(test-error (logand #\a))
(test-error (logand #\a 1))
(test-error (logand 1 #\a))
(test-error (logand 1 1 #\a))
(test-end "logand invalid form")
(test-begin "logand")
(test-equal -1     (logand))
(test-equal 0      (logand 0))
(test-equal -1     (logand -1))
(test-equal 1      (logand 1))
(test-equal #b11   (logand #b11))
(test-equal #b10   (logand #b1010 #b10))
(test-equal 0      (logand #b1010 #b100))
(test-equal #b1010 (logand #b1010 #b1110))
(test-equal #b1000 (logand #b1010 #b1110 #b101000))
(test-equal 0      (logand #b1010 #b1110 #b101000 0))
(if (and (symbol-bound? 'least-fixnum)
         (symbol-bound? 'greatest-fixnum))
    (begin
      (test-equal (least-fixnum)    (logior 0  (least-fixnum)))
      (test-equal (greatest-fixnum) (logior 0  (greatest-fixnum)))
      (test-equal (least-fixnum)    (logand -1 (least-fixnum)))
      (test-equal (greatest-fixnum) (logand -1 (greatest-fixnum)))
      (test-equal 0 (logand (least-fixnum) (greatest-fixnum)))))
(test-end "logand")

(test-begin "logior invalid form")
(test-error (logior #\a))
(test-error (logior #\a 1))
(test-error (logior 1 #\a))
(test-error (logior 1 1 #\a))
(test-end "logior invalid form")
(test-begin "logior")
(test-equal 0        (logior))
(test-equal 0        (logior 0))
(test-equal #b11     (logior #b11))
(test-equal #b1010   (logior #b1010 #b10))
(test-equal #b1110   (logior #b1010 #b100))
(test-equal #b1110   (logior #b1010 #b1110))
(test-equal #b101110 (logior #b1010 #b1110 #b101000))
(test-equal #b101110 (logior #b1010 #b1110 #b101000 0))
(if (and (symbol-bound? 'least-fixnum)
         (symbol-bound? 'greatest-fixnum))
    (begin
      (test-equal (least-fixnum)    (logior 0  (least-fixnum)))
      (test-equal (greatest-fixnum) (logior 0  (greatest-fixnum)))
      (test-equal -1                (logior -1 (least-fixnum)))
      (test-equal -1                (logior -1 (greatest-fixnum)))
      (test-equal -1 (logior (least-fixnum) (greatest-fixnum)))))
(test-end "logior")

(test-begin "logxor invalid form")
(test-error (logxor #\a))
(test-error (logxor #\a 1))
(test-error (logxor 1 #\a))
(test-error (logxor 1 1 #\a))
(test-end "logxor invalid form")
(test-begin "logxor")
(test-equal 0        (logxor))
(test-equal 0        (logxor 0))
(test-equal #b11     (logxor #b11))
(test-equal #b1000   (logxor #b1010 #b10))
(test-equal #b1110   (logxor #b1010 #b100))
(test-equal #b0100   (logxor #b1010 #b1110))
(test-equal #b101100 (logxor #b1010 #b1110 #b101000))
(test-equal #b101100 (logxor #b1010 #b1110 #b101000 0))
(if (and (symbol-bound? 'least-fixnum)
         (symbol-bound? 'greatest-fixnum))
    (begin
      (test-equal (least-fixnum)    (logxor 0 (least-fixnum)))
      (test-equal (greatest-fixnum) (logxor 0 (greatest-fixnum)))
      (test-equal (greatest-fixnum) (logxor -1 (least-fixnum)))
      (test-equal (least-fixnum)    (logxor -1 (greatest-fixnum)))
      (test-equal -1 (logxor (least-fixnum) (greatest-fixnum)))))
(test-end "logxor")

(test-begin "lognot invalid forms")
(test-error (lognot))
(test-argcheck-error (lognot 0 0))
(test-end "lognot invalid forms")
(test-begin "lognot")
(test-equal -1            (lognot 0))
(test-equal 0             (lognot -1))
(test-equal -2            (lognot 1))
(test-equal 1             (lognot -2))
(test-equal (- -1 #b1010) (lognot #b1010))
(test-equal (- -1 #b0101) (lognot #b0101))
(if (and (symbol-bound? 'least-fixnum)
         (symbol-bound? 'greatest-fixnum))
    (begin
      (test-equal -1 (lognot 0))
      (test-equal 0  (lognot -1))
      (test-equal (greatest-fixnum) (lognot (least-fixnum)))
      (test-equal (least-fixnum)    (lognot (greatest-fixnum)))))
(test-end "lognot")

(test-begin "bitwise-if invalid forms")
(test-error (bitwise-if))
(test-error (bitwise-if 0))
(test-error (bitwise-if 0 0))
(test-end "bitwise-if invalid forms")
(test-begin "bitwise-if")
(test-equal 0 (bitwise-if 0 0 0))
(test-equal 0 (bitwise-if 0 1 0))
(test-equal 1 (bitwise-if 0 0 1))
(test-equal 1 (bitwise-if 0 1 1))
(test-equal 0 (bitwise-if 1 0 0))
(test-equal 1 (bitwise-if 1 1 0))
(test-equal 0 (bitwise-if 1 0 1))
(test-equal 1 (bitwise-if 1 1 1))
(test-equal #b0010100 (bitwise-if #b11100 #b1010101 #b0000000))
(test-equal #b0110110 (bitwise-if #b11100 #b1010101 #b0101010))
(test-equal #b0100010 (bitwise-if #b11100 #b0000000 #b0101010))
(test-end "bitwise-if")

(test-begin "logtest")
(test-eq #f (logtest 0 0))
(test-eq #f (logtest 1 0))
(test-eq #f (logtest 0 1))
(test-eq #t (logtest 1 1))
(test-eq #t (logtest #b1010 #b10))
(test-eq #f (logtest #b1010 #b100))
(test-eq #t (logtest #b1010 #b1110))

;; SRFI-33 aliases
(test-eq "bitwise-and" bitwise-and   logand)
(test-eq "bitwise-ior" bitwise-ior   logior)
(test-eq "bitwise-xor" bitwise-xor   logxor)
(test-eq "bitwise-not" bitwise-not   lognot)
(test-eq "bitwise-merge" bitwise-merge bitwise-if)
(test-eq "any-bits-set?" any-bits-set? logtest)
(test-end "logtest")


(test-end "test-srfi60")
