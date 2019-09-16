
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


