(in-package #:canonicalized-initargs)

(defclass canon-initargs:canonicalized-slot-initargs-class (cesdi:cesdi-mixin canon-initargs:class)
  ((%canon-slots :reader canon-initargs:canonicalized-slots
                 :type list)))

(defmethod enhanced-defclass:compute-slot-options nconc ((class canon-initargs:canonicalized-slot-initargs-class))
  (list :canonicalize))

(defmethod c2mop:finalize-inheritance :after ((class canon-initargs:canonicalized-slot-initargs-class))
  (setf (slot-value class '%canon-slots)
        (remove-if-not (typep 'canon-initargs:effective-slot-definition)
                       (c2mop:class-slots class))))

(defun %wrap-slot-initargs-canonicalizer (acc finish slot-initarg-name prepender)
  (let (initarg-value seenp)
    (values (lambda (name value)
              (if (eq name slot-initarg-name)
                  (progn
                    (if seenp
                        (error "Duplicate ~S initarg for slot." slot-initarg-name)
                        (setf seenp t))
                    (setf initarg-value value))
                  (funcall acc name value)))
            (lambda ()
              (let ((canonicalized-initargs (funcall finish)))
                (if seenp
                    (funcall prepender initarg-value canonicalized-initargs)
                    canonicalized-initargs))))))

(defmethod enhanced-defclass:make-slot-initargs-canonicalizer ((metaclass canon-initargs:canonicalized-slot-initargs-class))
  (multiple-value-bind (acc finish) (call-next-method)
    (%wrap-slot-initargs-canonicalizer
     acc finish :canonicalize
     (lambda (canonicalization-function-form canonicalized-initargs)
       (list* :canonicalization-function canonicalization-function-form
              canonicalized-initargs)))))


(defclass canon-initargs:direct-slot-definition (c2mop:standard-direct-slot-definition)
  ((%canonicalization-function :initarg :canonicalization-function
                               :reader canon-initargs:canonicalization-function
                               :initform nil)))

(defmethod c2mop:direct-slot-definition-class ((class canon-initargs:canonicalized-slot-initargs-class)
                                               &key (canonicalization-function nil suppliedp) &allow-other-keys)
  (declare (ignore canonicalization-function))
  (if suppliedp
      (find-class 'canon-initargs:direct-slot-definition)
      (call-next-method)))

(defclass canon-initargs:effective-slot-definition (c2mop:standard-effective-slot-definition)
  ((%canonicalization-function :initarg :canonicalization-function
                               :reader canon-initargs:canonicalization-function
                               :initform nil)))

(defmethod cesdi:compute-effective-slot-definition-initargs ((class canon-initargs:canonicalized-slot-initargs-class) direct-slot-definitions)
  (let ((canonicalizing-slots (remove-if-not (typep 'canon-initargs:direct-slot-definition)
                                             direct-slot-definitions)))
    (if canonicalizing-slots
        (list* :canonicalization-function (%combine-canonicalizers (mapcar #'canon-initargs:canonicalization-function canonicalizing-slots))
               (call-next-method))
        (call-next-method))))

(defmethod cesdi:effective-slot-definition-class ((class canon-initargs:canonicalized-slot-initargs-class)
                                                  &key (canonicalization-function nil suppliedp))
  (declare (ignore canonicalization-function))
  (if suppliedp
      (find-class 'canon-initargs:effective-slot-definition)
      (call-next-method)))

(defgeneric canon-initargs:map-slot-initargs-canonicalizers (function class)
  (:argument-precedence-order class function)
  (:method (function (class canon-initargs:canonicalized-slot-initargs-class))
    (let ((seen (make-hash-table :test 'eq)))
      (dolist (slot (canon-initargs:canonicalized-slots class))
        (dolist (initarg (c2mop:slot-definition-initargs slot))
          (let ((existing (gethash initarg seen)))
            (if existing
                (error "Conflicting slot canonicalization functions for initarg ~S in class ~S."
                       initarg class)
                (progn
                  (setf (gethash initarg seen) t)
                  (funcall function initarg (canon-initargs:canonicalization-function slot))))))))))

(defmethod canon-initargs:map-initarg-canonicalizers progn (function (class canon-initargs:canonicalized-slot-initargs-class))
  (canon-initargs:map-slot-initargs-canonicalizers function class))
