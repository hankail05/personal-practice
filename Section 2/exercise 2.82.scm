#lang sicp
(define global-array '())
(define (make-entry k v) (list k v))
(define (key entry) (car entry))
(define (value entry) (cadr entry))
(define (put op type item)
  (define (put-helper k array)
    (cond ((null? array) (list (make-entry k item)))
          ((equal? (key (car array)) k) array)
          (else (cons (car array) (put-helper k (cdr array))))))
  (set! global-array (put-helper (list op type) global-array)))
(define (get op type)
  (define (get-helper k array)
    (cond ((null? array) #f)
          ((equal? (key (car array)) k) (value (car array)))
          (else (get-helper k (cdr array)))))
  (get-helper (list op type) global-array))
; get/put
(define global-array-coercion '())
(define (put-coercion op type item)
  (define (put-helper k array)
    (cond ((null? array) (list (make-entry k item)))
          ((equal? (key (car array)) k) array)
          (else (cons (car array) (put-helper k (cdr array))))))
  (set! global-array-coercion (put-helper (list op type) global-array-coercion)))
(define (get-coercion op type)
  (define (get-helper k array)
    (cond ((null? array) #f)
          ((equal? (key (car array)) k) (value (car array)))
          (else (get-helper k (cdr array)))))
  (get-helper (list op type) global-array-coercion))
; get-coercion/put-coercion


(define (square x) (* x x))
(define (attach-tag type-tag contents) (cons type-tag contents))
(define (type-tag datum)
  (if (pair? datum) (car datum) (error "Bad tagged datum -- TYPE-TAG" datum)))
(define (contents datum)
  (if (pair? datum) (cdr datum) (error "Bad tagged datum -- CONTENTS" datum)))

(define (apply-generic op . args)
  (let ((type-tags (map type-tag args)))
    (define (multiple-coercion args type-formula)
      (map (lambda (arg)
             (define (iter arg formula)
               (if (null? formula)
                   arg
                   (let ((type1 (type-tag arg)) (type2 (car formula)))
                     (let ((t1->t2 (get-coercion type1 type2)) (t2->t1 (get-coercion type2 type1)))
                       (cond (t1->t2 (iter (t1->t2 arg) (cdr formula)))
                             (t2->t1 (iter arg (cdr formula)))
                             ((eq? type1 type2) (iter arg (cdr formula)))
                             (else (error "No method for these types" (list op type-tags))))))))
             (iter arg type-formula))
           args))
    (define (multiple-operation args result)
        (if (null? args)
            result
            (let ((proc (get op (list (type-tag result) (type-tag (car args))))))
              (cond (proc (multiple-operation (cdr args) (apply proc (map contents (list result (car args))))))
                    (else (error "No method for these types" (list op type-tags)))))))
    (if (= (length type-tags) 1)
        (let ((proc (get op type-tags)))
          (cond (proc (apply proc (map contents args)))
                (error "No method for these types" (list op type-tags))))
        (let ((coerced-args (multiple-coercion args type-tags)))
          (multiple-operation (cdr coerced-args) (car coerced-args))))))


(define (install-scheme-number-package)
  (define (tag x) (attach-tag 'scheme-number x))
  (put 'add '(scheme-number scheme-number) (lambda (x y) (tag (+ x y))))
  (put 'sub '(scheme-number scheme-number) (lambda (x y) (tag (- x y))))
  (put 'mul '(scheme-number scheme-number) (lambda (x y) (tag (* x y))))
  (put 'div '(scheme-number scheme-number) (lambda (x y) (tag (/ x y))))
  (put 'make 'scheme-number (lambda (x) (tag x)))
  'done)

(define (make-scheme-number n) ((get 'make 'scheme-number) n))


(define (install-rational-package)
  (define (numer x) (car x))
  (define (denom x) (cdr x))
  (define (make-rat n d) (let ((g (gcd n d))) (cons (/ n g) (/ d g))))
  (define (add-rat x y)
    (make-rat (+ (* (numer x) (denom y)) (* (numer y) (denom x))) (* (denom x) (denom y))))
  (define (sub-rat x y)
    (make-rat (- (* (numer x) (denom y)) (* (numer y) (denom x))) (* (denom x) (denom y))))
  (define (mul-rat x y)
    (make-rat (* (numer x) (numer y)) (* (denom x) (denom y))))
  (define (div-rat x y)
    (make-rat (* (numer x) (denom y)) (* (denom x) (numer y))))

  (define (tag x) (attach-tag 'rational x))
  (put 'add '(rational rational) (lambda (x y) (tag (add-rat x y))))
  (put 'sub '(rational rational) (lambda (x y) (tag (sub-rat x y))))
  (put 'mul '(rational rational) (lambda (x y) (tag (mul-rat x y))))
  (put 'div '(rational rational) (lambda (x y) (tag (div-rat x y))))
  (put 'make 'rational (lambda (n d) (tag (make-rat n d))))
  'done)

(define (make-rational n d) ((get 'make 'rational) n d))


(define (install-complex-package)
  (define (install-rectangular-package)
    (define (real-part z) (car z))
    (define (imag-part z) (cdr z))
    (define (make-from-real-imag x y) (cons x y))
    (define (magnitude z) (sqrt (+ (square (real-part z)) (square (imag-part z)))))
    (define (angle z) (atan (imag-part z) (real-part z)))
    (define (make-from-mag-ang r a) (cons (* r (cos a)) (* r (sin a))))

    (define (tag x) (attach-tag 'rectangular x))
    (put 'real-part '(rectangular) real-part)
    (put 'imag-part '(rectangular) imag-part)
    (put 'magnitude '(rectangular) magnitude)
    (put 'angle '(rectangular) angle)
    (put 'make-from-real-imag 'rectangular (lambda (x y) (tag (make-from-real-imag x y))))
    (put 'make-from-mag-ang 'rectangular (lambda (r a) (tag (make-from-mag-ang r a))))
    'done)
  
  (define (install-polar-package)
    (define (magnitude z) (car z))
    (define (angle z) (cdr z))
    (define (make-from-mag-ang r a) (cons r a))
    (define (real-part z) (* (magnitude z) (cos (angle z))))
    (define (imag-part z) (* (magnitude z) (sin (angle z))))
    (define (make-from-real-imag x y) (cons (sqrt (+ (square x) (square y))) (atan y x)))

    (define (tag x) (attach-tag 'polar x))
    (put 'real-part '(polar) real-part)
    (put 'imag-part '(polar) imag-part)
    (put 'magnitude '(polar) magnitude)
    (put 'angle '(polar) angle)
    (put 'make-from-real-imag 'polar (lambda (x y) (tag (make-from-real-imag x y))))
    (put 'make-from-mag-ang 'polar (lambda (r a) (tag (make-from-mag-ang r a))))
    'done)

  (install-rectangular-package)
  (install-polar-package)

  (define (real-part z) (apply-generic 'real-part z))
  (define (imag-part z) (apply-generic 'imag-part z))
  (define (magnitude z) (apply-generic 'magnitude z))
  (define (angle z) (apply-generic 'angle z))
  (define (make-from-real-imag x y) ((get 'make-from-real-imag 'rectangular) x y))
  (define (make-from-mag-ang r a) ((get 'make-from-mag-ang 'polar) r a))

  (define (add-complex z1 z2)
    (make-from-real-imag (+ (real-part z1) (real-part z2)) (+ (imag-part z1) (imag-part z2))))
  (define (sub-complex z1 z2)
    (make-from-real-imag (- (real-part z1) (real-part z2)) (- (imag-part z1) (imag-part z2))))
  (define (mul-complex z1 z2)
    (make-from-mag-ang (* (magnitude z1) (magnitude z2)) (+ (angle z1) (angle z2))))
  (define (div-complex z1 z2)
    (make-from-mag-ang (/ (magnitude z1) (magnitude z2)) (- (angle z1) (angle z2))))

  (define (tag z) (attach-tag 'complex z))
  (put 'add '(complex complex) (lambda (z1 z2) (tag (add-complex z1 z2))))
  (put 'sub '(complex complex) (lambda (z1 z2) (tag (sub-complex z1 z2))))
  (put 'mul '(complex complex) (lambda (z1 z2) (tag (mul-complex z1 z2))))
  (put 'div '(complex complex) (lambda (z1 z2) (tag (div-complex z1 z2))))
  (put 'make-from-real-imag 'complex (lambda (x y) (tag (make-from-real-imag x y))))
  (put 'make-from-mag-ang 'complex (lambda (r a) (tag (make-from-mag-ang r a))))
  'done)

(define (make-complex-from-real-imag x y) ((get 'make-from-real-imag 'complex) x y))
(define (make-complex-from-mag-ang r a) ((get 'make-from-mag-ang 'complex) r a))


(define (install-coercion-package)
  (define (scheme-number->complex n)
    (make-complex-from-real-imag (contents n) 0))

  (put-coercion 'scheme-number 'complex scheme-number->complex)
  'done)


(define (add x y) (apply-generic 'add x y))
(define (sub x y) (apply-generic 'sub x y))
(define (mul x y) (apply-generic 'mul x y))
(define (div x y) (apply-generic 'div x y))


(install-scheme-number-package)
(install-complex-package)
(install-coercion-package)

(apply-generic 'add (make-scheme-number 1) (make-complex-from-real-imag 1 2)
               (make-scheme-number 2) (make-complex-from-real-imag 1 2))
; Existing generic-arithmetic function cannot take variadic arguments.

; apply-generic coerces the arguments to types in the call, not all types.