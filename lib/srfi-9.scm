;;  Filename : srfi-9.scm
;;  About    : SRFI-9 Defining Record Types
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

;; The record procedures are implemented in module-srfi9.c. This file
;; defines define-record-type by syntax-rules. So define-record-type can be
;; used as an internal definition too.

(define-syntax define-record-type
  (syntax-rules ()
    ((_ type (constructor field ...) predicate field-spec ...)
     (begin
       (%%define-record-name type
         (%%make-record-type 'type '(field-spec ...)))
       (%%define-record-name constructor
         (%%record-constructor type '(field ...)))
       (%%define-record-name predicate (%%record-predicate type))
       (%%define-record-field type field-spec) ...))))

(define-syntax %%define-record-field
  (syntax-rules ()
    ((_ type (field accessor))
     (%%define-record-name accessor (%%record-accessor type 'field)))
    ((_ type (field accessor modifier))
     (begin
       (%%define-record-name accessor (%%record-accessor type 'field))
       (%%define-record-name modifier (%%record-modifier type 'field))))))

;; A name must be an identifier. (define (quote name) ...) defines quote
;; without this check.
(define-syntax %%define-record-name
  (syntax-rules ()
    ((_ (name . rest) value)
     (error "define-record-type: identifier required but got" '(name . rest)))
    ((_ #(name ...) value)
     (error "define-record-type: identifier required but got" '#(name ...)))
    ((_ name value)
     (define name value))))
