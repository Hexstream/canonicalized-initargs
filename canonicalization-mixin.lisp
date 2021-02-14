(in-package #:canonicalized-initargs)

(defclass canon-initargs:canonicalization-mixin (canon-initargs:class)
  ((%initarg-to-canonicalizer :reader %initarg-to-canonicalizer
                              :type hash-table)))

(defgeneric canon-initargs:map-initarg-canonicalizers (function class)
  (:method-combination progn)
  (:argument-precedence-order class function))

(defmethod c2mop:finalize-inheritance :after ((class canon-initargs:canonicalization-mixin))
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
                     hash)))))

(defmethod canon-initargs:canonicalize-initargs (operation (class canon-initargs:canonicalization-mixin) initargs)
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
