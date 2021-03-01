(in-package #:canonicalized-initargs)

(defclass canon-initargs:canonicalization-class (object-class:class object-class:autosuperclass canon-initargs:class)
  ((%initarg-to-canonicalizer :reader %initarg-to-canonicalizer
                              :type hash-table)))

(let ((shared-slot '(:name %canonicalization-class
                     :allocation :class)))

  (defmethod initialize-instance :around ((class canon-initargs:canonicalization-class) &rest initargs &key direct-slots)
    (apply #'call-next-method class
           :direct-slots (cons shared-slot direct-slots)
           initargs))

  (defmethod reinitialize-instance :around ((class canon-initargs:canonicalization-class) &rest initargs &key (direct-slots nil direct-slots-p))
    (if direct-slots-p
        (apply #'call-next-method class
               :direct-slots (cons shared-slot direct-slots)
               initargs)
        (call-next-method))))

(defgeneric canon-initargs:map-initarg-canonicalizers (function class)
  (:method-combination progn)
  (:argument-precedence-order class function))

(defmethod c2mop:finalize-inheritance :after ((class canon-initargs:canonicalization-class))
  (setf (slot-value class '%initarg-to-canonicalizer)
        (let ((hash (make-hash-table :test 'eq)))
          (prog1 hash
            (canon-initargs:map-initarg-canonicalizers
             (lambda (initarg-name canonicalizer)
               (push canonicalizer (gethash initarg-name hash)))
             class)
            (maphash (lambda (initarg-name canonicalizers)
                       (setf (gethash initarg-name hash)
                             (%combine-canonicalizers (nreverse canonicalizers))))
                     hash)))
        (slot-value (c2mop:class-prototype class) '%canonicalization-class)
        class))

(defmethod canon-initargs:canonicalize-initargs (operation (class canon-initargs:canonicalization-class) initargs)
  (declare (ignore operation))
  (let ((initarg-to-canonicalizer (%initarg-to-canonicalizer class)))
    (labels ((recurse (rest)
               (if rest
                   (let* ((key (first rest))
                          (canonicalizer (gethash key initarg-to-canonicalizer)))
                     (if canonicalizer
                         (list* key (funcall canonicalizer (second rest))
                                (recurse (cddr rest)))
                         (recurse (cddr rest))))
                   initargs)))
      (recurse initargs))))


(defclass canon-initargs:canonicalization-object (canon-initargs:object)
  ((%canonicalization-class :allocation :class
                            :type canon-initargs:class))
  (:metaclass object-class:object-class))

(defmethod object-class:autosuperclass ((class canon-initargs:canonicalization-class))
  (list (find-class 'canon-initargs:canonicalization-object)))

(defgeneric canon-initargs:canonicalization-class (object)
  (:method ((object canon-initargs:canonicalization-object))
    (unless (slot-boundp object '%canonicalization-class)
      (c2mop:finalize-inheritance (find-if (typep 'canon-initargs:canonicalization-class)
                                           (c2mop:class-precedence-list (class-of object)))))
    (slot-value object '%canonicalization-class)))

(defmethod canon-initargs:canonicalize-initargs (operation (instance canon-initargs:canonicalization-object) initargs)
  (canon-initargs:canonicalize-initargs operation (canon-initargs:canonicalization-class instance) initargs))
