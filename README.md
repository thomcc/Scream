# Scream

Scream is a simple dialect of Lisp written in ruby.  It's an 
incomplete subset of Scheme, supporting no syntactic 
sugar (yet).  This is the second Scheme subset I've ever
written, so please for the love of god don't use this for
anything real.

## Built-in Functions

The following operations are built in:

+ Common numeric operations, e.g. `+`, `-`, `*`, `/`, 
  `=`, `modulo`, `quotient` and `expt`.
+ The unary boolean operator, `not`
+ The list manipulation functions, `car`, `cdr`, `cons` and `null?`
+ Hashtables (from Ruby's builtin hash), `hash`, `get`, and `put`
+ Ruby FFI: `new`, `.`, and `reval`.

## Built-in Syntax

Additionally, the following syntactic tokens are valid

+ `define` (defines a variable)
+ `set` (set's a variables value)
+ `lambda` (creates an anonymous function)
+ `quote` (quote's a value)
+ `debug` (prints the current environment to stdout)
+ `if` (basic conditional)
+ `begin` (for sequencing)

## To Do

+ Create expansion phase
+ a `define-macro`-like form (simple once expansion takes 
  place in its own phase)
+ Add more synactic forms
    + `let` and friends
    + `cond`
    + `and` / `or`
    + `quasiquote`, `unquote`, `unquote-splicing` (already
       supported in the lexer and parser, just need to write 
       the expansion phase)
+ Extend the FFI somewhat (or at least fix the bugs)
