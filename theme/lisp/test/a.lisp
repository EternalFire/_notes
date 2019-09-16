
; sbcl --script a.lisp
(defun x () (list 'a 'b "text text_1 text_2" 12))
(format t "~a~%" (x))


(if (listp '(a b c))
      (format t "is list") ; then
      (format t "NOT list") ; else
) 


(if (listp 123)
      (format t "is list") ; then
      (format t "NOT list") ; else
) 

(defun show-squares (start end)
  (do ((i start (+ i 1)))
    ((> i end) 'done)
    (format t "~A ~A~%" i (* i i))
  )
)

(do ((i 1 (+ i 1)))
	((> i 10) 'Text_xxx_yyy 'return_value)
	(format t "~A, " i)
)

(defun show-squares-1 (i end)
   (if (> i end)
     'done
     (progn
       (format t "~A ~A~%" i (* i i))
       (show-squares (+ i 1) end))))


(dolist (obj '(1 10 100 1000))
	(format t "~A|" obj)
)


(defun our-length (lst)
  (let ((len 0))
    (dolist (obj lst)
      (setf len (+ len 1)))
    len))
(our-length '(1 0))

(list 'a '(b c (d)))
(cons 'a '(b c (d)))
(first (cons 'a '(b c (d))))
(car '(m n))
(first nil)

(let ((x 1) (y 2) (z 3))
	(+ x y z))

(defconstant limit "constant___")
(format t "~a~%" limit)

(defparameter *g_val* 99)

(let ((x '(o p q)))
	(format t "1:[~a]~%" x)
	(setf (car x) 'a)
	(format t "2:[~a]~%" x)
)

(let (x '(o p q))
	x
)


(do ((i 1 (+ i 1)))
	(> i 10)
	(format t "~A~%" i)
)

(dotimes (i 5 i))
(dotimes (i 5 'i))
(dotimes (i 5 'done) (print "1"))

(defun get-fourth (x)
  (car (cdr (cdr (cdr x))))
)
(get-fourth '(1 2 3 4 5 6))
(get-fourth '(a b c r t y u))

(car (
    x ; car
    (cdr '(a (b c) d) ; '((b c) d)
    )
  ) 
) ; b

(or 13 (/ 1 0)) ; 13

(apply #'list 1 nil) ; (1)

(funcall #'list 1 nil) ; (1 nil)

(defun our-atom (x) (not (consp x)))

(eql (cons 'a nil) (cons 'a nil)) ; nil
(equal (cons 'a nil) (cons 'a nil)) ; t

(setf x '(a bird cat dog))
(setf z (copy-list x))

(nth 0 '(a b c))
(nthcdr 2 '(a b c d e f))

(maplist #'(lambda (x) x) '(a b c))

(mapcar #'(lambda (x) (+ x 10))
          '(1 2 3))

(mapcar #'(lambda (x y) (+ x 10 y))
          '(1 2 3)
          '(1 2 3))

(mapcar #'list
          '(a b c)
          '(1 2 3 4))

(subst 'abc 'ccc '(ccc 789))

; 替换表达式中的 x
(subst 'y 'x '(and (integerp x) (zerop (mod x 2))))
; (AND (INTEGERP Y) (ZEROP (MOD Y 2)))


(member '(a) '((a) (z)) :test #'equal)
(member '(z) '((a) (z)) :test #'equal) ; (Z)
(member 'ac '((a b) (ac d)) :key #'car)


