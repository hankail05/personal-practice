(define (mul a b)
  (define (double x) (+ x x))
  (define (halve x) (/ x 2))
  (define (even? n) (= (remainder n 2) 0))
  (define (mul-iter a result b)
    (cond ((= b 0) result)
          ((even? b) (mul-iter (double a) result (halve b)))
          (else (mul-iter a (+ a result) (- b 1)))))
  (mul-iter a 0 b))

(mul 2 10)