(asdf:defsystem #:canonicalized-initargs

  :author "Jean-Philippe Paradis <hexstream@hexstreamsoft.com>"

  :license "Unlicense"

  :description "Provides a :canonicalize slot option accepting an initarg canonicalization function."

  :depends-on ("closer-mop"
               "cesdi"
               "compatible-metaclasses"
               "enhanced-defclass"
               "object-class"
               "enhanced-typep")

  :version "1.0.1"
  :serial cl:t
  :components ((:file "package")
               (:file "shared")
               (:file "canonicalization-strategy")
               (:file "canonicalization-mixin")
               (:file "slot-initargs")
               (:file "class-initargs")
               (:file "standard"))

  :in-order-to ((asdf:test-op (asdf:test-op #:canonicalized-initargs_tests))))
