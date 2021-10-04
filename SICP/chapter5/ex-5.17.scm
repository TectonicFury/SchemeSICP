;ex 5.16 and 5.17
;enter 0 as value and it keeps pushing on stack
(controller
  (assign continue (label fact-done))
  fact-loop
    (assign n (op read))
  test=
    (test (op =) (reg n) (const 1))
    (branch (label base-case))
    (save continue)
    (save n)

    (assign n (op -) (reg n) (const 1))
    (assign continue (label after-fact))
    (goto (label test=))
  after-fact
    (restore n)
    (restore continue)
    (assign val (op *) (reg n) (reg val))
    (goto (reg continue))
  base-case
    (assign val (const 1))
    (goto (reg continue))
  fact-done
    (perform (op print) (reg val))
    (perform (op initialize-stack))
    (goto (label fact-loop)))
;(perform (op print-stack-statistics)) 
(define (make-machine ops controller-text)
  (let ((machine (make-new-machine))
        (register-names (extract-registers controller-text))) ; ex 5.13
    (for-each
      (lambda (register-name)
        ((machine 'allocate-register) register-name))
        register-names)
    ((machine 'install-operations) ops)
    ((machine 'install-instruction-sequence) (assemble controller-text machine))
    machine))

(define (make-register name)
  (let ((contents '*unassigned))
    (define (dispatch message)
      (cond ((eq? message 'get) contents)
            ((eq? message 'set)
              (lambda (value) (set! contents value)))
            (else
              (error "Unknown request: REGISTER" message))))
    dispatch))

(define (get-contents register)
  (register 'get))
(define (set-contents! register value)
  ((register 'set) value))

; (define (make-stack)
;   (let ((s '()))
;     (define (push x) (set! s (cons x s)))
;     (define (pop)
;       (if (null? s)
;           (error "Empty stack: POP")
;           (let ((top (car s)))
;               (display top) (newline)
;                (set! s (cdr s))
;                top)))
;     (define (initialize)
;       (set! s '())
;       'done)
;     ; (define (peek);ex 5.11
;     ;   (caar s))
;     (define (dispatch message)
;       (cond ((eq? message 'push) push)
;             ((eq? message 'pop) (pop))
;             ((eq? message 'peek) (peek))
;             ((eq? message 'initialize) (initialize))
;             (else (error "Unknown request: STACK" message))))
;     dispatch))

(define (make-stack)
  (let ((s '())
        (number-pushes 0)
        (max-depth 0)
        (current-depth 0))
    (define (push x)
      (set! s (cons x s))
      (set! number-pushes (+ 1 number-pushes))
      (set! current-depth (+ 1 current-depth))
      (set! max-depth (max current-depth max-depth)))
    (define (pop)
      (if (null? s)
          (error "Empty stack: POP")
          (let
            ((top (car s)))
            (set! s (cdr s))
            (set! current-depth (- current-depth 1))
            top)))
    (define (initialize)
      (set! s '())
      (set! number-pushes 0)
      (set! max-depth 0)
      (set! current-depth 0)
      'done)

    (define (print-statistics)
      (newline)
      (display
        (list 'total-pushes '= number-pushes 'maximum-depth '= max-depth)))

    (define (dispatch message)
      (cond ((eq? message 'push) push)
            ((eq? message 'pop) (pop))
            ((eq? message 'initialize) (initialize))
            ((eq? message 'print-statistics) (print-statistics))
            (else (error "Unknown request: STACK" message))))
    dispatch))

(define (pop stack) (stack 'pop))
(define (push stack value) ((stack 'push) value))
; (define (peek stack) (stack 'peek))

;make-new-machine
(define (make-new-machine)
  (let ((pc (make-register 'pc))
        (flag (make-register 'flag))
        (stack (make-stack))
        (the-instruction-sequence '())
        (trace-on false))
    (let ((the-ops (list
                    (list 'initialize-stack (lambda () (stack 'initialize)))
                    (list 'print-stack-statistics
                      (lambda () (stack 'print-statistics)))
                    (list 'read (lambda () (read)))
                    (list 'print (lambda (x) (display x) (newline)))))
          (register-table (list (list 'pc pc) (list 'flag flag))))
      (define (allocate-register name)
        (if (assoc name register-table)
            (error "Multiply defined register: " name)
            (set! register-table (cons (list name (make-register name)) register-table)))
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
              (let ((inst (car insts)))
                (if (labeled-inst? inst)
                    (begin
                      (if trace-on
                          (begin
                            ; (display (list 'trace-on-status trace-on))
                            ; (newline)
                            (display (cadr inst))
                            (newline)
                            (display (car (caddr inst)))
                            (newline)))
                      ((instruction-execution-proc (caddr inst)))
                      (execute))
                    (begin
                      (if trace-on
                          (begin
                            ; (display (list 'trace-on-status trace-on))
                            ; (newline)
                            (display (instruction-text inst))
                            (newline)))
                      ((instruction-execution-proc inst))
                      (execute)))))))
      (define (dispatch message)
        (cond ((eq? message 'start)
                (set-contents! pc the-instruction-sequence)
                (display "start!") (newline)
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
              ((eq? message 'stack) stack)
              ((eq? message 'operations) the-ops)
              ((eq? message 'trace-on) (set! trace-on true))
              ((eq? message 'trace-off) (set! trace-on false))
              ((eq? message 'is-trace-on?) trace-on)
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

; assembler

(define (assemble controller-text machine)
  (extract-labels
    controller-text
    (lambda (insts labels)
      (update-insts! insts labels machine)
      insts)))
(define (extract-labels text receive)
  (if (null? text)
      (receive '() '())
      (extract-labels
        (cdr text)
        (lambda (insts labels)
          (let ((next-inst (car text)))
            (if (symbol? next-inst)
                (if (assoc next-inst labels)
                    (error "Same label used twice: EXTRACT-LABELS" next-inst)
                    (receive (make-labeled-instructions insts next-inst)
                             (cons (make-label-entry
                                      next-inst
                                      (make-labeled-instructions insts next-inst)) labels)))
                (receive (cons (make-instruction next-inst) insts) labels)))))))

(define (update-insts! insts labels machine)
  (display "Update insts in process")
  (newline)
  (let ((pc (get-register machine 'pc))
        (flag (get-register machine 'flag))
        (stack (machine 'stack))
        (ops (machine 'operations)))
    (for-each
      (lambda (inst)
        (display inst)
        (newline)
        (if (labeled-inst? inst)
            (set-instruction-execution-proc!
              (caddr inst) (make-execution-procedure
                    (instruction-text (caddr inst)) labels machine pc flag stack ops))
            (set-instruction-execution-proc!
              inst (make-execution-procedure
                    (instruction-text inst) labels machine pc flag stack ops))))
      insts)))
(define (labeled-inst? inst)
  (if (eq? (car inst) 'labeled)
      true
      false))
(define (make-instruction text)
 (cons text '()))
(define (make-labeled-instructions insts label) ;ex 5.17
  (cons (list 'labeled label (car insts)) (cdr insts)))
(define (instruction-text inst) (car inst)) ;instruction text is useful for debugging, though not used by simulator
(define (instruction-execution-proc inst) (cdr inst))
(define (set-instruction-execution-proc! inst proc) (set-cdr! inst proc))

(define (make-label-entry label-name insts) (cons label-name insts))

(define (lookup-label labels label-name)
  (let ((val (assoc label-name labels)))
    (if val
        (cdr val)
        (error "Undefined label: ASSEMBLE" label-name))))

; making execution procedures
(define (make-execution-procedure inst labels machine pc flag stack ops)
  (cond ((eq? (car inst) 'assign) (make-assign inst machine labels ops pc))
        ((eq? (car inst) 'test) (make-test inst machine labels ops flag pc))
        ((eq? (car inst) 'branch) (make-branch inst machine labels flag pc))
        ((eq? (car inst) 'goto) (make-goto inst machine labels pc))
        ((eq? (car inst) 'save) (make-save inst machine stack pc))
        ((eq? (car inst) 'restore) (make-restore inst machine stack pc))
        ((eq? (car inst) 'perform) (make-perform inst machine labels ops pc))
        (else (error "Unknown instruction type: ASSEMBLE" inst))))

(define (make-assign inst machine labels operations pc)
  (let ((target (get-register machine (assign-reg-name inst)))
        (value-exp (assign-value-exp inst)))
    (let ((value-proc
            (if (operation-exp? value-exp)
                (make-operation-exp value-exp machine labels operations)
                (make-primitive-exp (car value-exp) machine labels))))
      (lambda ()
        (set-contents! target (value-proc))
        (advance-pc pc)))))
(define (assign-reg-name assign-instruction)
  (cadr assign-instruction))
(define (assign-value-exp assign-instruction)
  (cddr assign-instruction))
(define (advance-pc pc)
  (set-contents! pc (cdr (get-contents pc))))

(define (make-test inst machine labels operations flag pc)
  (let ((condition (test-condition inst)))
    (if (operation-exp? condition)
        (let ((condition-proc (make-operation-exp condition machine labels operations)))
          (lambda ()
            (set-contents! flag (condition-proc))
            (advance-pc pc)))
        (error "Bad TEST instruction: ASSEMBLE" inst))))

(define (test-condition test-instruction)
  (cdr test-instruction))

(define (make-branch inst machine labels flag pc)
  (let ((dest (branch-dest inst)))
    (if (label-exp? dest)
        (let ((insts (lookup-label labels (label-exp-label dest))))
          (lambda ()
            (if (get-contents flag)
                (set-contents! pc insts)
                (advance-pc pc))))
        (error "Bad branch instruction: ASSEMBLE" inst))))

(define (branch-dest branch-instruction)
  (cadr branch-instruction))

(define (make-goto inst machine labels pc)
  (let ((dest (goto-dest inst)))
    (cond ((label-exp? dest)
            (let ((insts (lookup-label labels (label-exp-label dest))))
              (lambda () (set-contents! pc insts))))
          ((register-exp? dest)
            (let ((reg (get-register machine (register-exp-reg dest))))
              (lambda () (set-contents! pc (get-contents reg)))))
          (else (error "Bad GOTO instruction" inst)))))

(define (goto-dest goto-instruction)
  (cadr goto-instruction))

(define (make-save inst machine stack pc)
  (let ((reg (get-register machine (stack-inst-reg-name inst))))
    (lambda ()
      (push stack (get-contents reg))
      (advance-pc pc))))

(define (make-restore inst machine stack pc)
  (let ((reg (get-register machine (stack-inst-reg-name inst))))
    (lambda ()
      ;(display "restoring") (newline)
      ;(display reg) (newline)
      (set-contents! reg (pop stack))
      ;(display "restored") (newline)
      (advance-pc pc))))

(define (stack-inst-reg-name stack-instruction)
  (cadr stack-instruction))

(define (make-perform inst machine labels operations pc)
  (let ((action (perform-action inst)))
    (if (operation-exp? action)
        (let ((action-proc
                (make-operation-exp action machine labels operations)))
          (lambda ()
            (action-proc)
            (advance-pc pc)))
        (error "Bad PERFORM instruction: ASSEMBLE" inst))))
(define (perform-action inst)
  (cdr inst))

; subexpression execution procedures

(define (make-primitive-exp exp machine labels)
  (cond ((constant-exp? exp)
          (let ((c (constant-exp-value exp)))
            (lambda () c)))
        ((label-exp? exp)
          (let ((insts (lookup-label labels (label-exp-label exp))))
            (lambda () insts)))
        ((register-exp? exp)
          (let ((r (get-register machine (register-exp-reg exp))))
            (lambda () (get-contents r))))
        (else (error "Unknown expression type: ASSEMBLE" exp))))

(define (register-exp? exp) (tagged-list? exp 'reg))
(define (register-exp-reg exp) (cadr exp))
(define (constant-exp? exp) (tagged-list? exp 'const))
(define (constant-exp-value exp) (cadr exp))
(define (label-exp? exp) (tagged-list? exp 'label))
(define (label-exp-label exp) (cadr exp))

(define (make-operation-exp exp machine labels operations)
  (let ((op (lookup-prim (operation-exp-op exp) operations))
        (aprocs
          (map
            (lambda (e)
              (if (label-exp? e) ;ex 5.9
                  (error "Operations can't be used with labels: ASSEMBLE" e)
                  (make-primitive-exp e machine labels)))
            (operation-exp-operands exp))))
    (lambda ()
      (apply op (map (lambda (p) (p)) aprocs)))))

(define (operation-exp? exp)
  (and (pair? exp) (tagged-list? (car exp) 'op)))
(define (operation-exp-op operation-exp)
  (cadr (car operation-exp)))
(define (operation-exp-operands operation-exp)
  (cdr operation-exp))

(define (lookup-prim symbol operations)
  (let ((val (assoc symbol operations)))
    (if val
        (cadr val)
        (error "Unknown operation: ASSEMBLE" symbol))))