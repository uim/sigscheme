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

;; Defines a library that exports the builtins SYMS. Unbound symbols
;; aren't exported.
(define (%%define-builtin-library name syms)
  (%%register-library
   name
   (let loop ((syms syms)
              (exports '()))
     (if (null? syms)
         (reverse exports)
         (let ((location (%%builtin-location (car syms))))
           (loop (cdr syms)
                 (if location
                     (cons (cons (car syms) location) exports)
                     exports)))))))

(define %%standard-libraries-loaded? #f)

;; Returns the entry of the library NAME in %%libraries or #f. The standard
;; libraries are defined by scheme-libraries.scm when one of them is used
;; first.
(define (%%library-entry name)
  (if (and (eq? (car name) 'scheme)
           (not %%standard-libraries-loaded?))
      (begin
        (set! %%standard-libraries-loaded? #t)
        (for-each (lambda (library)
                    (%%define-builtin-library (car library) (cdr library)))
                  (%%read-file (string-append (%%system-load-path)
                                              "/scheme-libraries.scm")
                               #f))))
  (assoc name %%libraries))

(define (%%register-library name exports)
  (let ((entry (assoc name %%libraries)))
    (if entry
        (set-cdr! entry exports)
        (set! %%libraries (cons (cons name exports) %%libraries)))
    (if #f #f)))

(define (%%library-exports name)
  (let ((entry (or (%%library-entry name)
                   (begin
                     (%%load-library name)
                     (assoc name %%libraries)))))
    (if entry
        (cdr entry)
        (error "import: unknown library" name))))

;; Returns the file name of the library NAME: (foo bar 1) -> "foo/bar/1.sld"
(define (%%library-file-name name)
  (let loop ((parts name)
             (file-name ""))
    (let ((part (if (symbol? (car parts))
                    (symbol->string (car parts))
                    (number->string (car parts)))))
      (if (null? (cdr parts))
          (string-append file-name part ".sld")
          (loop (cdr parts) (string-append file-name part "/"))))))

;; Names of the libraries being loaded to detect circular imports.
(define %%loading-libraries '())

;; Loads define-library forms in the library file of NAME if it exists.
(define (%%load-library name)
  (let ((path (%%find-file (%%library-file-name name)))
        (loading %%loading-libraries))
    (if (member name loading)
        (error "import: circular import" name))
    (if path
        (dynamic-wind
            (lambda () (set! %%loading-libraries (cons name loading)))
            (lambda ()
              (for-each
               (lambda (form)
                 (if (and (pair? form) (eq? (car form) 'define-library))
                     (%%define-library (cadr form) (cddr form)
                                       (%%directory-name path))
                     (error "define-library: define-library required but got"
                            form)))
               (%%read-file path #f)))
            (lambda () (set! %%loading-libraries loading))))))

(define (%%directory-name path)
  (let loop ((i (- (string-length path) 1)))
    (if (char=? (string-ref path i) #\/)
        (substring path 0 i)
        (loop (- i 1)))))

;; Returns the forms in the file PATH. Symbols are folded if FOLD-CASE?.
(define (%%read-file path fold-case?)
  (call-with-input-file path
    (lambda (port)
      (let loop ((forms '()))
        (let ((form (read port)))
          (if (eof-object? form)
              (reverse forms)
              (loop (cons (if fold-case? (%%fold-case form) form)
                          forms))))))))

(define (%%fold-case obj)
  (cond
   ((symbol? obj) (string->symbol (string-foldcase (symbol->string obj))))
   ((pair? obj) (cons (%%fold-case (car obj)) (%%fold-case (cdr obj))))
   ((vector? obj) (vector-map %%fold-case obj))
   (else obj)))

;; Returns the path of the included FILE. A relative file name is resolved
;; from DIRECTORY or the library path. DIRECTORY is #f for a library that
;; isn't defined in a file.
(define (%%include-path file directory)
  (or (and directory
           (not (char=? (string-ref file 0) #\/))
           (%%find-file (string-append directory "/" file)))
      (%%find-file file)
      (error "include: file not found" file)))

;; Returns the forms in FILES.
(define (%%include-files files directory fold-case?)
  (apply append
         (map (lambda (file)
                (%%read-file (%%include-path file directory) fold-case?))
              files)))

;; Returns true if the feature requirement of cond-expand is satisfied.
(define (%%feature-requirement? requirement)
  (cond
   ((symbol? requirement)
    (or (eq? requirement 'else)
        (and (memq requirement (features)) #t)))
   ((pair? requirement)
    (case (car requirement)
      ((and) (%%every %%feature-requirement? (cdr requirement)))
      ((or) (%%any %%feature-requirement? (cdr requirement)))
      ((not) (not (%%feature-requirement? (cadr requirement))))
      ((library) (and (or (%%library-entry (cadr requirement))
                          (%%find-file
                           (%%library-file-name (cadr requirement))))
                      #t))
      (else (error "cond-expand: invalid feature requirement"
                   requirement))))
   (else (error "cond-expand: invalid feature requirement" requirement))))

(define (%%every pred lst)
  (or (null? lst)
      (and (pred (car lst)) (%%every pred (cdr lst)))))

(define (%%any pred lst)
  (and (pair? lst)
       (or (pred (car lst)) (%%any pred (cdr lst)))))

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

(define %%environments '())

;; R7RS: (environment import-set ...)
;; Environments are cached because a module is never freed.
(define (environment . sets)
  (let ((entry (assoc sets %%environments)))
    (if entry
        (cdr entry)
        (let* ((module (%%make-module '(environment)))
               (env (%%module-environment module)))
          (%%import-sets sets
                         (lambda (sym location)
                           (%%module-import! module sym location)))
          (set! %%environments (cons (cons sets env) %%environments))
          env))))

(define-syntax define-library
  (syntax-rules ()
    ((_ name declaration ...)
     (%%define-library 'name '(declaration ...) #f))))

(define (%%define-library name declarations directory)
  (let ((module (%%make-module name))
        (export-specs '()))
    (letrec
        ((process
          (lambda (declaration directory)
            (case (and (pair? declaration) (car declaration))
              ((import)
               (%%import-sets (cdr declaration)
                              (lambda (sym location)
                                (%%module-import! module sym location))))
              ((begin)
               (%%eval-forms (cdr declaration) module))
              ((include include-ci)
               (%%eval-forms (%%include-files (cdr declaration) directory
                                              (eq? (car declaration)
                                                   'include-ci))
                             module))
              ((include-library-declarations)
               (for-each (lambda (file)
                           (let ((path (%%include-path file directory)))
                             (for-each (lambda (declaration)
                                         (process declaration
                                                  (%%directory-name path)))
                                       (%%read-file path #f))))
                         (cdr declaration)))
              ((cond-expand)
               (let loop ((clauses (cdr declaration)))
                 (cond
                  ((null? clauses) #f)
                  ((%%feature-requirement? (caar clauses))
                   (for-each (lambda (declaration)
                               (process declaration directory))
                             (cdar clauses)))
                  (else (loop (cdr clauses))))))
              ((export)
               (set! export-specs (append export-specs (cdr declaration))))
              (else
               (error "define-library: unknown declaration" declaration))))))
      (for-each (lambda (declaration) (process declaration directory))
                declarations))
    ;; Exported identifiers are resolved after all definitions.
    (%%register-library
     name
     (map (lambda (spec)
            (if (pair? spec)  ; (rename internal external)
                (%%export-binding module (caddr spec) (cadr spec))
                (%%export-binding module spec spec)))
          export-specs))))

(define (%%eval-forms forms module)
  (for-each (lambda (form) (eval form module)) forms))

(define (%%export-binding module external internal)
  (cons external
        (or (%%module-location module internal)
            (error "define-library: exported identifier isn't defined"
                   internal))))
