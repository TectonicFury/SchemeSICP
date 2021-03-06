(define (curry exp)
  (let ((a (car exp))
        (e (cadr (cdr exp))))
       (define (curry-aux z)
          (cond ((null? (cdr z)) (list a (list (car z)) e))
                (else (cons a (list (list (car z)) (curry-aux (cdr z)))))))
                (curry-aux (cadr exp))))
