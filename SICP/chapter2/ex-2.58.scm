(define (deriv exp var)
  (cond ((number? exp) 0)
        ((variable? exp)
          (if (same-variable? exp var) 1 0))
        ((sum? exp) (make-sum (deriv (addend exp) var)
                              (deriv (augend exp) var)))
        ((product? exp) (make-sum
                              (make-product (multiplier exp) (deriv (multiplicand exp) var))
                              (make-product (deriv (multiplier exp) var) (multiplicand exp))))
        ((exponentiation? exp)
          (make-product (exponent exp)
                        (make-product (make-exponent (base exp) (- (exponent exp) 1)) (deriv (base exp) var))))
        (else
          (error "unknown expression type: DERIV" exp))))

(define (variable? x)
  (symbol? x))

(define (same-variable? v1 v2)
  (and (variable? v1) (variable? v2) (eq? v1 v2)))

(define (=number? exp num)
  (and (number? exp) (= exp num)))

(define (make-sum a1 a2)
  (cond ((=number? a1 0) a2)
        ((=number? a2 0) a1)
        ((and (number? a1) (number? a2)) (+ a1 a2))
        (else (list a1 '+ a2))))

(define (make-product m1 m2)
  (cond ((or (=number? m1 0) (=number? m2 0)) 0)
        ((=number? m1 1) m2)
        ((=number? m2 1) m1)
        ((and (number? m1) (number? m2)) (* m1 m2))
        (else (list m1 '* m2))))

(define (make-exponent u n)
  (cond ((=number? n 0) 1)
        ((=number? n 1) u)
        (else (list u '** n))))

(define (exponentiation? x)
  (and (pair? x) (eq? (cadr x) '**)))

(define (base x)
  (car x))

(define (exponent x)
  (caddr x))

(define (sum? x) (and (pair? x) (eq? (cadr x) '+)))

(define (addend s) (car s)) ; if s is a sum it has to be of the form (+ a1 a2 ..), this is for ex-2.57

(define (augend s) (caddr s))

(define (product? x) (and (pair? x) (eq? (cadr x) '*)))

(define (multiplier p) (car p))

(define (multiplicand p) (caddr p))

(define (accumulate op null-value seq)
  (if (null? seq)
      null-value
      (op (car seq) (accumulate op null-value (cdr seq)))))