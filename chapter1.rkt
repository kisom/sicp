#lang scheme

;;; ## Building Abstractions with Procedures
;;;
;;; > The acts of the mind, wherein it exerts its power over simple
;;; > ideas, are chiefly these three: 1. Combining several simple ideas
;;; > into one compound one, and thus all complex ideas are made.  2.
;;; > The second is bringing two ideas, whether simple or complex,
;;; > together, and setting them by one another so as to take a view of
;;; > them at once, without uniting them into one, by which it gets all
;;; > its ideas of relations.  3.  The third is separating them from all
;;; > other ideas that accompany them in their real existence: this is
;;; > called abstraction, and thus all its general ideas are made.
;;; >  
;;; > --John Locke, _An Essay Concerning Human Understanding_ (1690)
;;;
;;; This chapter concerns _computational processes_, abstractions
;;; inhabiting computers that manipulate other abstractions called
;;; _data_, directed by a pattern of rules called _programs_.
;;;
;;; > In effect, we conjure the spirits of the computer with our spells.

;;; The art of programming is in recognising and anticipating the
;;; consequences of programs.

;;; ### The Elements of Programming

;;; Language, in addition specifying patterns of rules, provides a
;;; framework for organising ideas about computational
;;; processes. There are three mechanisms provided for this:
;;;
;;; * _primitive expressions_: the atoms of the programming language
;;;
;;; * _means of combination_: means to build compound elements from
;;; simpler ones
;;;
;;; * _means of abstraction_: how compound elements are named and
;;; manipulated as units.

;;; #### Expressions

;;; A _combination_ is a list of expressions, contained inside
;;; parenthesis, denoting procedure application. The _operator_ is the
;;; name given to the leftmost element, and the remaining elements are
;;; called the _operands_. For example:

(+ 21 35 12 7)

;;; `+` is the operand, and the numbers `21`, `35`, `12`, and `7` are
;;; the operands. There are two advantages:
;;;
;;; First, there is no ambiguity given the structure of an expression.
;;;
;;; Second, it extends simply in terms of nesting (where combinations
;;; have elements that are, themselves, combinations:
;;; `(+ (* 3 5) (- 10 6))`. For example, there is no linguistic ambiguity in
(+ (* 3 (+ (* 2 4) (+ 3 5))) (+ (- 10 7) 6))
;;; It is we who would be confused by this; indentation and formatting
;;; helps us to visualise the structure of the code:
(+ (* 3
      (+ (* 2 4)
         (+ 3 5)))
   (+ (- 10 7)
      6))
;;; This convention is known as _pretty printing_.
;;;
;;; No matter the complexity of the expression, the interpreter
;;; follows a basic cycle: read, evaluate, print &mdash; the
;;; read-evaluate-print loop, or _REPL_. Notably, there is no need to
;;; tell the interpreter explicitly to print the result.

;;; #### Naming and the Environment

;;; Naming things is core to programming, for it allows us to refer to
;;; computational objects by name. In Scheme, things are named with
;;; `define`, wherein a name identifies a _variable_ whose _value_ is
;;; the object.

(define size 2)

;;; The interpreter now associates the value `2` with the name
;;; `size`. We can now refer to this value by name:

(* 5 size)

;;; We can build combinations of names:

(define pi 3.14159)

(define radius 10)

(define circumference (* 2 pi radius))

circumference

;;; ```
;;; 62.8318
;;; ```

;;; `define` is Scheme's simplest form of abstraction. Computational
;;; objects tend to complex structures, and this allows these
;;; structures to be named. This value-symbol associate requires a
;;; memory to track these pairs (which is termed the _environement_,
;;; and in this case, more precisely, the _global environment_).

;;; #### Evaluating Combinations

;;; We want to isolate issues in thinking procedurally. Consider: the
;;; interpreter follows a procedure when evaluating combinations:
;;;
;;; To evaluate a combination:
;;;
;;; 1. Evaluate the subexpressions of the combination.
;;; 
;;; 2. Apply the procedure given by the leftmost subexpression (the
;;; operator) to the arguments that are the remaining subexpressions
;;; (the operands).

;;; The first rule includes as a step the need to invoke the rule
;;; itself (_recursion_). Recursion is an elegant way to express the
;;; evaluation of deeply nested expressions. Consider the following
;;; expression:

(* (+ 2 (* 4 6))
   (+ 3 5 7))

;;; which might be represented by the following tree:

;                 390
;                 /|\____________
;                / |             \
;               *  26            15
;                  /|\            |
;                 / | \         // \\
;                +  2  24      / |  | \
;                      /|\    +  3  5  7
;                     / | \
;                    *  4  6

;;; Each node is a combination, with the leftmost terminal branch
;;; corresponding to the operator; terminal nodes are either
;;; expressions or numbers. It might be imagined that values percolate
;;; upwards; this form of the evaluation rule exemplifies a
;;; generalised kind of process term _tree accumulation_.

;;; Note that repeatedly applying the first step requires, at some
;;; point, the evaluation of primitive expressions. These cases can be
;;; covered by these rules:
;;;
;;; * the value of a numeral is the number it names
;;;
;;; * values of built-in operators are their corresponding machine
;;; instruction sequences.
;;;
;;; * other names take their values from their associated objects in
;;; the environment.
;;;
;;; The second rule might be taken as seen as a special case of the
;;; third: the symbol `+` might be associated with machine
;;; instructions in the environment. The key point is the role of the
;;; environment in providing meaning for symbols. It is meaningless to
;;; consider `(+ x 1)` without considering its accompanying
;;; environment. It is a key component in understanding program
;;; execution.

;;; This evaluation rule doesn't cover definitions: `(define x 3)`
;;; doesn't apply `define` to the arguments `x` or `3`. This is our
;;; first example of a _special form_. Each of these carries their own
;;; evaluation rule.

;;; > "Syntactic sugar causes cancer of the semicolon."
;;; >
;;; > --Alan Perlis
