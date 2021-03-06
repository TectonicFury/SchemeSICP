(define (or-gate a1 a2 output)
  (let ((b (make-wire))
        (c (make-wire))
        (d (make-wire))
        (e (make-wire))
        (f (make-wire)))
        (and-gate a1 a1 b)
        (and-gate a2 a2 d)
        (inverter b c)
        (inverter d e)
        (and-gate c e f)
        (inverter f output)
        'ok))
