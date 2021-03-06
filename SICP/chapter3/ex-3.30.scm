(define (ripple-carry-adder A-list B-list S-list C)
  (define (iter-carry a b s C-prev-left)
    (cond ((null? (cdr a))
            (let ((dummy-c (make-wire)))
              (set-signal! dummy-c 0)
              (full-adder (car a) (car b) dummy-c (car s) C-prev-left)))
          (else
            (let ((C-right (make-wire)))
              (full-adder (car a) (car b) C-right (car s) C-prev-left)
              (iter-carry (cdr a) (cdr b) (cdr s) C-right)))))
  (iter-carry A-list B-list S-list C))

(define (half-adder a b s c)
(let ((d (make-wire)) (e (make-wire)))
(or-gate a b d)
(and-gate a b c)
(inverter c e)
(and-gate d e s) 'ok))
