(define (expmod-mod base exp m)
  (cond ((and (= (remainder (sqr base) m) 1) (not (or (= base 1) (= base (- m 1))))) 0)
        ((= exp 0) 1)
        ((even? exp) (remainder (square (expmod-mod base (/ exp 2) m)) m))
        (else (remainder (* base (expmod-mod base (- exp 1) m)) m))
  )
)

(define (fast-prime-miller-rabin? n times count)
  (cond ((and (= times 0) (= count 0)) true)
        ((= times 0) (fast-prime-miller-rabin? n 100 (- count 1)))
        ((fermat-test n) (fast-prime-miller-rabin? n (- times 1) count))
        (else false)
  )
)

(define (sqr x) (* x x))
(define (even? x) (= (remainder x 2) 0))
(define (fermat-test n)
  (define (try-it a) (= (expmod-mod a (- n 1) n) 1))
  (try-it (+ 1 (random (- n 1))))
)
(define (n-primes-larger-than m n count)
  (cond ((even? m) (n-primes-larger-than (+ m 1) n count))
        ((and (fast-prime-miller-rabin? m 100 1) (< count n))
          (newline) (display m) (n-primes-larger-than (+ m 2) n (+ count 1)))
        ((= count n) (newline) (display "Done"))
        (else (n-primes-larger-than (+ m 2) n count))
  )
)
(define (three-primes-larger-than n)
  (define (three-primes-larger-aux m pcount)
    (cond ((even? m) (three-primes-larger-aux (+ m 1) pcount))
          ((and (fast-prime-miller-rabin? m 100 1) (< pcount 3)) (timed-prime-test m) (three-primes-larger-aux (+ m 2) (+ pcount 1)))
          ((= pcount 3) (newline) (display "Done"))
          (else (three-primes-larger-aux (+ m 2) pcount))
    )
  )
(three-primes-larger-aux (+ n 1) 0))

(define (timed-prime-test n) (newline)
(display n)
(start-prime-test n (runtime)))
(define (start-prime-test n start-time) (if (fast-prime-miller-rabin? n 100 1)
(report-prime (- (runtime) start-time)))) (define (report-prime elapsed-time)
(display " *** ") (display elapsed-time))
