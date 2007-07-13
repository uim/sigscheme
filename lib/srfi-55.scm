(define %require-extension-handler-srfi
  (lambda numbers
    (for-each (lambda (n)
                (let ((srfi-n (string-append "srfi-" (number->string n))))
                  (or (%%require-module srfi-n)
                      (%require-sysfile srfi-n))))
              numbers)))

;; Be quasiquote free to allow --disable-quasiquote
(define %require-extension-alist
  (list
   (cons 'srfi %require-extension-handler-srfi)))

(define %require-sysfile
  (lambda (ext-id)
    (or (provided? ext-id)
        (let* ((file (string-append ext-id ".scm"))
               (path (string-append (%%system-load-path) "/" file)))
          (load path)
          (provide ext-id)))))

(define %require-extension
  (lambda clauses
    (for-each (lambda (clause)
                (let* ((id (car clause))
                       (args (cdr clause))
                       (id-str (symbol->string id))
                       (default-handler (lambda ()
                                          (or (%%require-module id-str)
                                              (%require-sysfile id-str))))
                       (handler (cond
                                 ((assq id %require-extension-alist) => cdr)
                                 (else
                                  default-handler))))
                  (apply handler args)))
              clauses)))
