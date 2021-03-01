(in-package #:canonicalized-initargs)

(defclass canon-initargs:class (c2mop:standard-class)
  ())

(defclass canon-initargs:object (c2mop:standard-object)
  ()
  (:metaclass object-class:object-class))

(defmethod object-class:autosuperclass ((class canon-initargs:class))
  (list (find-class 'canon-initargs:object)))


(defgeneric canon-initargs:canonicalize-initargs (operation instance initargs))

(defun %combine-canonicalizers (canonicalizers)
  (check-type canonicalizers cons)
  (if (rest canonicalizers)
      (lambda (value)
        (dolist (canonicalizer canonicalizers value)
          (setf value (funcall canonicalizer value))))
      (first canonicalizers)))
