(define (unique-pairs n)
(accumulate append '() (map (lambda (i)
        (map (lambda (j) (list i j)) (enumerate-interval 1 (- i 1)))) (enumerate-interval 2 n))))
(define (unique-pairs2 n)
  (flatmap (lambda (i)
          (map (lambda (j) (list i j)) (enumerate-interval 1 (- i 1)))) (enumerate-interval 2 n)))
(define (flatmap proc seq)
  (accumulate append '() (map proc seq)))

(define (enumerate-interval low high)
  (define (iter a b res)
    (if (> a b)
        res
        (iter (+ a 1) b (append res (cons a '())))))
        (iter low high '()))