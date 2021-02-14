(asdf:defsystem #:canonicalized-initargs_tests

  :author "Jean-Philippe Paradis <hexstream@hexstreamsoft.com>"

  :license "Unlicense"

  :description "canonicalized-initargs unit tests."

  :depends-on ("canonicalized-initargs"
               "parachute"
               "enhanced-boolean"
               "enhanced-eval-when")

  :serial cl:t
  :components ((:file "tests"))

  :perform (asdf:test-op (op c) (uiop:symbol-call '#:parachute '#:test '#:canonicalized-initargs_tests)))
