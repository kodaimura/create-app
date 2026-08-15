#lang racket

(provide greeting)

(define (greeting)
  "Hello, Racket!")

(module+ main
  (displayln (greeting)))
