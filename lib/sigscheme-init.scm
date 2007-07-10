;;  Filename : sigscheme-init.scm
;;  About    : Initialize file for SigScheme
;;
;;  Copyright (c) 2007 SigScheme Project <uim-en AT googlegroups.com>
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


(define %with-guarded-char-codec
  (lambda (thunk)
    (let ((orig-codec (%%current-char-codec))
          (thunk-codec (%%current-char-codec)))
      (dynamic-wind
          (lambda ()
            (%%set-current-char-codec! thunk-codec))
          thunk
          (lambda ()
            (set! thunk-codec (%%current-char-codec))
            (%%set-current-char-codec! orig-codec))))))

(define with-char-codec
  (lambda (codec thunk)
    (%with-guarded-char-codec
     (lambda ()
       (%%set-current-char-codec! codec)
       (thunk)))))

;; Preserve original C implementation.
(define %%load load)

;; Recover original char codec when an error is occurred on loading.
(define load
  (if (provided? "multibyte-char")
      (lambda (file)
        (%with-guarded-char-codec
         (lambda ()
           (%%load file))))
      %%load))
