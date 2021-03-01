(in-package #:canonicalized-initargs)

(defclass compatible-autoclass (enhanced-defclass:standard-autoclass
                                compatible-metaclasses:standard-metaclass)
  ())

(defclass canon-initargs:standard-class (canon-initargs:canonicalization-class
                                         canon-initargs:canonicalized-class-initargs-class
                                         canon-initargs:canonicalized-slot-initargs-class
                                         canon-initargs:early-canonicalization-class
                                         compatible-metaclasses:standard-class)
  ()
  (:metaclass compatible-autoclass))

(defclass canon-initargs:standard-object (canon-initargs:canonicalization-object
                                          canon-initargs:early-canonicalization-object)
  ()
  (:metaclass object-class:object-class))

(defmethod object-class:autosuperclass ((class canon-initargs:standard-class))
  (list (find-class 'canon-initargs:standard-object)))

(c2mop:ensure-finalized (find-class 'canon-initargs:standard-class))
