;b
(define (make-save inst machine stack pc)
  (let ((reg-name (stack-inst-reg-name inst))
        (reg (get-register machine (stack-inst-reg-name inst))))
    (lambda ()
      (push stack (cons reg-name (get-contents reg)))
      (advance-pc pc))))

(define (make-restore inst machine stack pc)
  (let ((reg-name (stack-inst-reg-name inst))
        (reg (get-register machine (stack-inst-reg-name inst))))
    (lambda ()
      (if (eq? (peek stack) reg-name)
          (begin
            (set-contents! reg (pop stack))
            (advance-pc pc))
          (error "Attempted to restore value to wrong register: RESTORE" inst)))))


(define (peek stack) (stack 'peek))
(define (stack-inst-reg-name stack-instruction)
  (cadr stack-instruction))

;c
(define (make-stack)
  (let ((s '()))
    (define (push x) (set! s (cons x s)))
    (define (pop)
      (if (null? s)
          (error "Empty stack: POP")
          (let ((top (cdar (car s))))
               (set! s (cdr s))
               top)))
    (define (initialize)
      (set! s '())
      'done)
    (define (peek);ex 5.11
      (caar s))
    (define (dispatch message)
      (cond ((eq? message 'push) push)
            ((eq? message 'pop) (pop))
            ((eq? message 'peek) (peek))
            ((eq? message 'initialize) (initialize))
            (else (error "Unknown request: STACK" message))))
    dispatch))


(define (pop stack) (stack 'pop))
(define (push stack value) ((stack 'push) value))
(define (peek stack) (stack 'peek))

(define (make-new-machine)
  (let ((pc (make-register 'pc))
        (flag (make-register 'flag))
        (stacks '())
        (the-instruction-sequence '()))
        ;initialize-stack does nothing,it should be reinitialize stack
    (let ((the-ops (list (list 'initialize-stack (lambda () (stacks 'initialize)))))
          (register-table (list (list 'pc pc) (list 'flag flag))))
      (define (allocate-register name)
        (if (assoc name register-table)
            (error "Multiply defined register: " name)
            (begin
              (set! register-table (cons (list name (make-register name)) register-table))
              (set! stacks (cons (list name (make-stack)) stacks))))
            'register-allocated)
      (define (lookup-register name)
        (let ((val (assoc name register-table)))
          (if val
              (cadr val)
              (error "Unknown register: " name))))
      (define (execute)
        (let ((insts (get-contents pc)))
          (if (null? insts)
              'done
              (begin
                ((instruction-execution-proc (car insts)))
                (execute)))))
      (define (dispatch message)
        (cond ((eq? message 'start)
                (set_contents! pc the-instruction-sequence)
                (execute))
              ((eq? message 'install-instruction-sequence)
                (lambda (seq)
                  (set! the-instruction-sequence seq)))
              ((eq? message 'allocate-register)
                allocate-register)
              ((eq? message 'get-register)
                lookup-register)
              ((eq? message 'install-operations)
                (lambda (ops)
                  (set! the-ops (append the-ops ops))))
              ((eq? message 'stacks) stacks)
              ((eq? message 'operations) the-ops)
              (else (error "Unknown request: MACHINE" message))))
      dispatch)))

(define (start machine) (machine 'start))
(define (get-register-contents machine register-name)
  (get-contents (get-register machine register-name)))
(define (set-register-contents machine register-name value)
  (set-contents! (get-register machine register-name) value)
  'done)
(define (get-register machine reg-name)
  ((machine 'get-register) reg-name))
;
;; modified restore and save from inchmeal , nothing special
(define (make-save inst machine stacks pc)
  (let ((reg-name (stack-inst-reg-name inst)))
	(let ((reg (get-register machine
							 reg-name)))
      (lambda ()
		(push (get-stack stacks reg-name)                ;;;
			  (get-contents reg))
		(advance-pc pc)))))

(define (make-restore inst machine stacks pc)
  (let ((reg-name (stack-inst-reg-name inst)))
	(let ((reg (get-register machine reg-name)))
      (lambda ()
		(set-contents! reg (pop (get-stack stacks reg-name))) ;;;
		(advance-pc pc)))))
