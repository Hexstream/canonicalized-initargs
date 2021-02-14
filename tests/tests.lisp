(cl:defpackage #:canonicalized-initargs_tests
  (:use #:cl #:parachute)
  (:shadowing-import-from #:enhanced-defclass #:defclass)
  (:shadowing-import-from #:enhanced-boolean #:boolean))

(cl:in-package #:canonicalized-initargs_tests)

(enhanced-eval-when:eval-when t
  (setf (shared-preferences:preferences-1 (load-time-value *package*))
        (make-instance 'enhanced-defclass:preferences
                       'enhanced-defclass:default-metaclass-advisor (find-class 'canon-initargs:standard-class))))

(defclass canon-boolean ()
  ((%boolean :initarg :boolean
             :reader %boolean
             :canonicalize #'boolean)))

(defclass inherited-canon-boolean (canon-boolean)
  ())

(defclass class-canon-boolean ()
  ((%boolean :initarg :boolean
             :reader %boolean))
  :canonicalize (:boolean #'boolean))

(defclass inherited-class-canon-boolean (class-canon-boolean)
  ())

(define-test "main"
  (flet ((test (class-name)
           (let ((canon (make-instance class-name :boolean 'true)))
             (is eq t (%boolean canon)))))
    (test 'canon-boolean)
    (test 'class-canon-boolean)
    (test 'inherited-canon-boolean)
    (test 'inherited-class-canon-boolean)))
