(in-package #:canonicalized-initargs)

(defclass canon-initargs:canonicalized-class-initargs-class (canon-initargs:class)
  ((%direct-canonicalizers :initarg :canonicalize
                           :reader %direct-canonicalizers
                           :type list
                           :initform nil)))

(defmethod enhanced-defclass:compute-class-options nconc ((class canon-initargs:canonicalized-class-initargs-class))
  (list :canonicalize))

(defun %every-other (function)
  (let ((processp t))
    (lambda (key value)
      (prog1 (when processp
               (funcall function key value))
        (setf processp (not processp))))))

(defun %mappcon (function plist)
  (mapcan (%every-other function) plist (cdr plist)))

(defun %mappl (function plist)
  (mapl (let ((processp t))
          (lambda (tail)
            (prog1 (when processp
                     (funcall function (first tail) (second tail)))
              (setf processp (not processp)))))
        plist))

(defmethod enhanced-defclass:make-initargs-canonicalizer ((prototype canon-initargs:canonicalized-class-initargs-class))
  (let ((inner (call-next-method)))
    (lambda (name value)
      (if (eq name :canonicalize)
          (list name `(list ,@(%mappcon (lambda (name value)
                                          (list `',name value))
                                        value)))
          (funcall inner name value)))))

(defgeneric canon-initargs:map-direct-class-initargs-canonicalizers (function class)
  (:argument-precedence-order class function)
  (:method (function (class cl:class))
    (declare (ignore function))
    nil)
  (:method (function (class canon-initargs:canonicalized-class-initargs-class))
    (%mappl function (%direct-canonicalizers class))
    nil))

(defgeneric canon-initargs:map-class-initargs-canonicalizers (function class)
  (:argument-precedence-order class function)
  (:method (function (class canon-initargs:canonicalized-class-initargs-class))
    (dolist (class (c2mop:class-precedence-list class))
      (canon-initargs:map-direct-class-initargs-canonicalizers function class))))

(defmethod canon-initargs:map-initarg-canonicalizers progn (function (class canon-initargs:canonicalized-class-initargs-class))
  (canon-initargs:map-class-initargs-canonicalizers function class))
