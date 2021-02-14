(in-package #:canonicalized-initargs)

(defclass canon-initargs:early-canonicalization-class (object-class:class object-class:autosuperclass canon-initargs:class)
  ())

(defclass canon-initargs:early-canonicalization-object (canon-initargs:object)
  ()
  (:metaclass object-class:object-class))

(defmethod object-class:autosuperclass ((class canon-initargs:early-canonicalization-class))
  (list (find-class 'canon-initargs:early-canonicalization-object)))


(defmethod make-instance :around ((class canon-initargs:early-canonicalization-class) &rest initargs)
  (apply #'call-next-method class
         (canon-initargs:canonicalize-initargs 'make-instance class initargs)))

(defmethod reinitialize-instance :around ((instance canon-initargs:early-canonicalization-object) &rest initargs)
  (apply #'call-next-method instance
         (canon-initargs:canonicalize-initargs 'reinitialize-instance (class-of instance) initargs)))

(defmethod update-instance-for-redefined-class :around ((instance canon-initargs:early-canonicalization-object) added-slots discarded-slots property-list &rest initargs)
  (apply #'call-next-method instance added-slots discarded-slots property-list
         (canon-initargs:canonicalize-initargs 'update-instance-for-redefined-class (class-of instance) initargs)))

(defmethod change-class :around (instance (new-class canon-initargs:early-canonicalization-class) &rest initargs)
  (apply #'call-next-method instance new-class
         (canon-initargs:canonicalize-initargs 'change-class new-class initargs)))
