(in-package #:canonicalized-initargs)

(defclass canon-initargs:standard-class (canon-initargs:canonicalization-mixin
                                         canon-initargs:canonicalized-class-initargs-class
                                         canon-initargs:canonicalized-slot-initargs-class
                                         canon-initargs:early-canonicalization-class)
  ()
  (:metaclass enhanced-defclass:standard-autoclass))

(c2mop:ensure-finalized (find-class 'canon-initargs:standard-class))
