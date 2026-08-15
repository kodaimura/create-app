#lang racket

(require "main.rkt")

(unless (equal? (greeting) "Hello, Racket!")
  (error 'greeting "unexpected result"))

(displayln "1 test passed")
