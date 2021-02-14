(in-package #:canonicalized-initargs)

(defclass canon-initargs:class (c2mop:standard-class)
  ())

(defclass canon-initargs:object (c2mop:standard-object)
  ()
  (:metaclass object-class:object-class))

(defmethod object-class:autosuperclass ((class canon-initargs:class))
  (list (find-class 'canon-initargs:object)))

(defmethod c2mop:validate-superclass ((class canon-initargs:class) (superclass canon-initargs:class))
  t)

(defmethod c2mop:validate-superclass ((class canon-initargs:class) superclass)
  (let ((superclass-metaclass (class-of superclass)))
    (or (eq superclass-metaclass (load-time-value (find-class 'c2mop:standard-class)))
        (eq superclass-metaclass (load-time-value (find-class 'c2mop:funcallable-standard-class)))
        (call-next-method))))


(defgeneric canon-initargs:canonicalize-initargs (operation class initargs))

(defun %combine-canonicalizers (canonicalizers)
  (check-type canonicalizers cons)
  (if (rest canonicalizers)
      (lambda (value)
        (dolist (canonicalizer canonicalizers value)
          (setf value (funcall canonicalizer value))))
      (first canonicalizers)))
