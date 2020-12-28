(define (func_rec n)
(cond ((< n 3) n)
      (else (+ (func_rec (- n 1)) (* (func_rec (- n 2)) 2) (* (func_rec (- n 3)) 3)))
)
)

(define (funcn n) (func-iter 2 1 0 n 2))

(define (func-iter p1 p2 p3 n count)
  (cond ((= n 0) 0)
    ((= n 1) 1)
    ((= n count) p1)
    (else (func-iter (+ p1 (* p2 2) (* p3 3)) p1 p2 n (+ count 1)))
  )
)
