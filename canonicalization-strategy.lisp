(in-package #:canonicalized-initargs)

(defclass canon-initargs:early-canonicalization-class (object-class:class object-class:autosuperclass canon-initargs:class)
  ())

(defclass canon-initargs:early-canonicalization-object (canon-initargs:object)
  ()
  (:metaclass object-class:object-class))

(defmethod object-class:autosuperclass ((class canon-initargs:early-canonicalization-class))
  (list (find-class 'canon-initargs:early-canonicalization-object)))


(defmethod initialize-instance :around ((instance canon-initargs:early-canonicalization-object) &rest initargs)
  (apply #'call-next-method instance
         (canon-initargs:canonicalize-initargs 'initialize-instance instance initargs)))

(defmethod reinitialize-instance :around ((instance canon-initargs:early-canonicalization-object) &rest initargs)
  (apply #'call-next-method instance
         (canon-initargs:canonicalize-initargs 'reinitialize-instance instance initargs)))

(defmethod update-instance-for-redefined-class :around ((instance canon-initargs:early-canonicalization-object) added-slots discarded-slots property-list &rest initargs)
  (apply #'call-next-method instance added-slots discarded-slots property-list
         (canon-initargs:canonicalize-initargs 'update-instance-for-redefined-class instance initargs)))

(defmethod update-instance-for-different-class :around (previous (instance canon-initargs:early-canonicalization-object) &rest initargs)
  (apply #'call-next-method previous instance
         (canon-initargs:canonicalize-initargs 'update-instance-for-different-class instance initargs)))
