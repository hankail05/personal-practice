#lang sicp
; front      end
;   │    ┌───────┐
;   │    ∨    │  │ 
;   ∨─────┐   ∨  │
;   │──> │──> │/ │
;  ∨    ∨ │   ∨ │
;  a│/  b│    c│ 

(define (front-ptr deque) (car deque))
(define (rear-ptr deque) (cdr deque))
(define (set-front-ptr! deque item) (set-car! deque item))
(define (set-rear-ptr! deque item) (set-cdr! deque item))

(define (empty-deque? deque) (null? (front-ptr deque)))
(define (make-deque) (cons '() '()))
(define (front-deque deque)
  (if (empty-deque? deque)
      (error "FRONT called with an empty deque" (print-deque deque))
      (caar (front-ptr deque))))
(define (rear-deque? deque)
  (if (empty-deque? deque)
      (error "REAR called with an empty deque" (print-deque deque))
      (caar (rear-ptr deque))))
(define (front-insert-deque! deque item)
  (let ((new-pair (cons (cons item '()) (front-ptr deque))))
    (cond ((empty-deque? deque) (set-front-ptr! deque new-pair)
                                (set-rear-ptr! deque new-pair)
                                (print-deque deque))
          (else (set-cdr! (car (front-ptr deque)) new-pair)
                (set-front-ptr! deque new-pair)
                (print-deque deque)))))
(define (rear-insert-deque! deque item)
  (let ((new-pair (cons (cons item (rear-ptr deque)) '())))
    (cond ((empty-deque? deque) (set-front-ptr! deque new-pair)
                                (set-rear-ptr! deque new-pair)
                                (print-deque deque))
          (else (set-cdr! (rear-ptr deque) new-pair)
                (set-rear-ptr! deque new-pair)
                (print-deque deque)))))
(define (front-delete-deque! deque)
  (cond ((empty-deque? deque) (error "FRONT-DELETE! called with an empty deque" (print-deque deque)))
        (else (if (not (null? (cdr (front-ptr deque))))
                  (set-cdr! (cadr (front-ptr deque)) '()))
              (set-front-ptr! deque (cdr (front-ptr deque)))
              (print-deque deque))))
(define (rear-delete-deque! deque)
  (cond ((empty-deque? deque) (error "REAR-DELETE! called with an empty deque" (print-deque deque)))
        (else (set-rear-ptr! deque (cdar (rear-ptr deque)))
              (if (not (null? (rear-ptr deque)))
                  (set-cdr! (rear-ptr deque) '())
                  (set-front-ptr! deque '()))
              (print-deque deque))))
(define (print-deque deque)
  (front-ptr deque))


(define d1 (make-deque))
(rear-insert-deque! d1 'b)
(rear-insert-deque! d1 'c)
(front-insert-deque! d1 'a)
(front-delete-deque! d1)
(rear-delete-deque! d1)
(rear-delete-deque! d1)
(front-insert-deque! d1 'a)
(front-delete-deque! d1)