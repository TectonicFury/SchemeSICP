(define (make-mobile left right)
  (list left right)
)
(define (make-branch length structure)
  (list length structure)
)
;a.
(define (left-branch mobile) (car mobile))
(define (right-branch mobile) (cadr mobile))
(define (branch-length branch) (car branch))
(define (branch-structure branch) (cadr branch))
;b.
(define (total-weight mobile)
  (cond ((and (not (pair? (branch-structure (left-branch mobile))))
          (not (pair? (branch-structure (right-branch mobile)))))
            (+ (branch-structure (left-branch mobile))
              (branch-structure (right-branch mobile))))
        ((not (pair? (branch-structure (left-branch mobile))))
          (+ (branch-structure (left-branch mobile))
            (total-weight (branch-structure (right-branch mobile)))))
        ((not (pair? (branch-structure (right-branch mobile))))
          (+ (total-weight (branch-structure (left-branch mobile)))
            (branch-structure (right-branch mobile))))
        (else
          (+ (total-weight (branch-structure (left-branch mobile)))
            (total-weight (branch-structure (right-branch mobile)))))
  )
)

;c
(define (balanced? mbl)
  (define (balanced-aux? mobile)
    (cond
      ((and (not (pair? (branch-structure (left-branch mobile)))) (not (pair? (branch-structure (right-branch mobile)))))

        (list (= (* (branch-length (left-branch mobile)) (branch-structure (left-branch mobile)))
           (* (branch-length (right-branch mobile)) (branch-structure (right-branch mobile))))
             (+ (branch-structure (left-branch mobile)) (branch-structure (right-branch mobile)))))
      ((not (pair? (branch-structure (left-branch mobile))))
        (let ((balR (balanced-aux? (branch-structure (right-branch mobile)))))
           (list (and (car balR)
                      (= (* (branch-length (left-branch mobile)) (branch-structure (left-branch mobile)))
                         (* (branch-length (right-branch mobile)) (cadr balR)))
                  ) (+ (branch-structure (left-branch mobile)) (cadr balR))
           )
        )
      )
      ((not (pair? (branch-structure (right-branch mobile))))
        (let ((balL (balanced-aux? (branch-structure (left-branch mobile)))))
          (list (and (car balL)
                     (= (* (branch-length (right-branch mobile)) (branch-structure (right-branch mobile)))
                        (* (branch-length (left-branch mobile)) (cadr balL)))
                ) (+ (cadr balL) (branch-structure (right-branch mobile)))
          )
        )
      )
      (else
        (let ((balL (balanced-aux? (branch-structure (left-branch mobile))))
             (balR (balanced-aux? (branch-structure (right-branch mobile))))
             )
             (list (and (car balL) (car balR)
                        (= (* (branch-length (left-branch mobile)) (cadr balL))
                           (* (branch-length (right-branch mobile)) (cadr balR))
                        )
                   ) (+ (cadr balL) (cadr balR))
             )
        )
     )
   )
 )
  (car (balanced-aux? mbl))
)
