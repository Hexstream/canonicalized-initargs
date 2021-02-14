(cl:defpackage #:canon-initargs
  (:nicknames #:canonicalized-initargs)
  (:use #:cl)
  (:shadowing-import-from #:enhanced-typep #:typep)
  (:shadow #:class #:standard-class #:standard-object)
  (:export #:class
           #:object
           #:canonicalize-initargs

           #:early-canonicalization-class
           #:early-canonicalization-object

           #:canonicalization-mixin
           #:map-initarg-canonicalizers

           #:canonicalized-slot-initargs-class
           #:canonicalized-slots
           #:direct-slot-definition
           #:effective-slot-definition
           #:canonicalization-function
           #:map-slot-initargs-canonicalizers

           #:canonicalized-class-initargs-class
           #:map-direct-class-initargs-canonicalizers
           #:map-class-initargs-canonicalizers

           #:standard-class))
