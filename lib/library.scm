;;  Filename : library.scm
;;  About    : R7RS Libraries
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


;; define-library and import are implemented by syntax-rules and procedures
;; that process the quoted declarations. A library is a module created by
;; %%make-module. Modules share locations (value . owner) to export and
;; import bindings. See library.c for details.

;; Each entry is (name . exports). EXPORTS is an alist of
;; (symbol . location).
(define %%libraries '())

;; Defines a library that exports the builtins SYMS. It's only for tests
;; until the standard libraries are defined.
(define (%%define-builtin-library name syms)
  (%%register-library
   name
   (map (lambda (sym)
          (cons sym (or (%%builtin-location sym)
                        (error "define-library: unbound builtin" sym))))
        syms)))

(define (%%register-library name exports)
  (let ((entry (assoc name %%libraries)))
    (if entry
        (set-cdr! entry exports)
        (set! %%libraries (cons (cons name exports) %%libraries)))
    (if #f #f)))

(define (%%library-exports name)
  (let ((entry (assoc name %%libraries)))
    (if entry
        (cdr entry)
        (error "import: unknown library" name))))

;; Returns an alist of (symbol . location) for the import set SET.
(define (%%import-set-bindings set)
  (if (and (pair? set)
           (memq (car set) '(only except prefix rename))
           (pair? (cdr set))
           (pair? (cadr set)))
      (let ((bindings (%%import-set-bindings (cadr set)))
            (args (cddr set)))
        (case (car set)
          ((only)
           (map (lambda (sym)
                  (or (assq sym bindings)
                      (error "import: identifier isn't exported" sym)))
                args))
          ((except)
           (for-each (lambda (sym)
                       (if (not (assq sym bindings))
                           (error "import: identifier isn't exported" sym)))
                     args)
           (%%remove-bindings bindings args))
          ((prefix)
           (map (lambda (binding)
                  (cons (string->symbol
                         (string-append (symbol->string (car args))
                                        (symbol->string (car binding))))
                        (cdr binding)))
                bindings))
          ((rename)
           (for-each (lambda (rename)
                       (if (not (assq (car rename) bindings))
                           (error "import: identifier isn't exported"
                                  (car rename))))
                     args)
           (map (lambda (binding)
                  (let ((rename (assq (car binding) args)))
                    (if rename
                        (cons (cadr rename) (cdr binding))
                        binding)))
                bindings))))
      (%%library-exports set)))

(define (%%remove-bindings bindings syms)
  (cond
   ((null? bindings) '())
   ((memq (caar bindings) syms) (%%remove-bindings (cdr bindings) syms))
   (else (cons (car bindings) (%%remove-bindings (cdr bindings) syms)))))

;; Calls (IMPORT! symbol location) for each binding of the import SETS.
(define (%%import-sets sets import!)
  (for-each (lambda (set)
              (for-each (lambda (binding)
                          (import! (car binding) (cdr binding)))
                        (%%import-set-bindings set)))
            sets))

(define-syntax import
  (syntax-rules ()
    ((_ set ...)
     (%%import-sets '(set ...) %%global-import!))))

(define-syntax define-library
  (syntax-rules ()
    ((_ name declaration ...)
     (%%define-library 'name '(declaration ...)))))

(define (%%define-library name declarations)
  (let ((module (%%make-module name))
        (export-specs '()))
    (for-each
     (lambda (declaration)
       (case (and (pair? declaration) (car declaration))
         ((import)
          (%%import-sets (cdr declaration)
                         (lambda (sym location)
                           (%%module-import! module sym location))))
         ((begin)
          (for-each (lambda (form) (eval form module))
                    (cdr declaration)))
         ((export)
          (set! export-specs (append export-specs (cdr declaration))))
         (else
          (error "define-library: unknown declaration" declaration))))
     declarations)
    ;; Exported identifiers are resolved after all definitions.
    (%%register-library
     name
     (map (lambda (spec)
            (if (pair? spec)  ; (rename internal external)
                (%%export-binding module (caddr spec) (cadr spec))
                (%%export-binding module spec spec)))
          export-specs))))

(define (%%export-binding module external internal)
  (cons external
        (or (%%module-location module internal)
            (error "define-library: exported identifier isn't defined"
                   internal))))
