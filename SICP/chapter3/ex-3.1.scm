(define (make-accumulator init-sum)
  (define (dispatch val)
    (set! init-sum (+ init-sum val))
    init-sum)
    dispatch)
