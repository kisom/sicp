;; #lang planet neil/sicp

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

;;; #### Compound Procedures

;;; _Procedure definitions_ allow us to name compound _operations_ and
;;; refer to them as a unit. In Scheme:

(define (square x) (* x x))

;;; This names a _compound procedure_, named _square_, which is an
;;; operating that multiplies something by itself. The object to be
;;; multiplies is given a local name `x`, which acts as a
;;; pronoun. Evaluating this instance of `define` both creates the
;;; procedure and names it. The generate form of a procedure
;;; definition:
;;;
;;; ``` (define (<NAME> <FORMAL PARAMETERS>) <BODY>) 
;;;```
;;;
;;; &lt;NAME&gt; is a symbol to be associated with the procedure;
;;; &lt;FORMAT PARAMETERS&gt; gives names to the corresponding
;;; arguments; and &lt;BODY&gt; is the expression that yields the
;;; operation's value, with the formal parameters replaced by the
;;; actual arguments.

;;; Having named this operation, it may now be used:

(square 21)

;;; ```
;;; 441
;;; ```

;;; `square` may now be used as a building block. The procedure
;;; x<sup>2</sup> + y<sup>2</sup> could be expressed as

;;; ```
;;; (+ (square x) (square y)
;;; ```

;;; We can name this `sum-of-squares`:

(define (sum-of-squares x y)
  (+ (square x) (square y)))
(sum-of-squares 3 4)

;;; ```
;;; 25
;;; ```

;;; Continuing this theme, `sum-of-squares` can also be used as a
;;; building block:

(define (f a)
  (sum-of-squares (+ a 1) (* a 2)))
(f 5)

;;; ```
;;; 136
;;; ```

;;; Compound procedures are indistinguishable in their use from
;;; primitive procedures.

;;; It is important to distinguish between creating a procedure and
;;; naming it. For example, a procedure may be created without naming
;;; it via `lambda`:

((lambda (x) (* x x)) 2)

;;; ```
;;; 4
;;; ```

(define square2 (lambda (x) (* x x)))
(= (square 2) (square2 2))

;;; The body of a procedure can be a sequence of expressions, the
;;; final of which is returned as the value of the procedure:

(define (body-sequence-example x)
  (+ x x)
  (* x x))
(body-sequence-example 3)

;;; ```
;;; 9
;;; ```

;;; #### The Substitution Model for Procedure Application

;;; Right now, we'll assume that the interpreter knows how to evaluate
;;; primitives. Compound procedures are interpreted as:
;;;
;;; > To apply a compound procedure to arguments, evaluate the body of
;;; > the procedure with each formal parameter replaced by the
;;; > corresponding argument.

;;; As an example, consider `(f 5)`. First, substitute the definition
;;; of `f`:

;;; ```
;;; (sum-of-squares (+ a 1 (* a 2)))
;;; ```

;;; Then the formal parameter `a` is replaced by the argument:

(sum-of-squares (+ 5 1) (* 5 2))

;;; This yields an evaluation of a combination with the operator
;;; `sum-of-squares` and a pair of operands. To determine the
;;; procedure to be applied, the operator must be evaluated, and the
;;; operands must be evaluated to determine the arguments. This
;;; reduces to

(+ (square 6) (square 10))

;;; Further reduction yields

(+ (* 6 6) (* 10 10))

;;; Reduction via multiplication:

(+ 36 100)

;;; The final reduction:

136

;;; This technique is called the _substitution model_ for procedure
;;; application, and comes with two caveats:

;;; 1. This gives us a means to think about procedure application, not
;;; an insight into the mechanics of the interpreter. In practice,
;;; this is done via a local environment.
;;;
;;; 2. The substition model is but the first in a sequence of models,
;;; aimed to spur thinking about how expressions are evaluated. As is
;;; done often in science and engineering, a simplified model is
;;; present first and are replaced as they become inadequate in
;;; explaining the phenomena under study. In chapter 3, mutable data
;;; will cause this model to break down.

;;; ##### Applicative order vs. normal order

;;; An alternative model only evaluates operands as their values are
;;; needed, substitution operand expressoins for parameters to arrive
;;; at an expression involving only primitive operators. In this
;;; model, `(f 5)` would be evaluated as

(sum-of-squares (+ 5 1) (* 5 2))

(+   (square (+ 5 1))    (square (* 5 2)))

(+   (* (+ 5 1) (+ 5 1)) (* (* 5 2) (* 5 2)))

;;; which reduces to

(+  (* 6 6)  (* 10 10))

(+    36        100)

136

;;; While we arrive at the same answer, the process is different: the
;;; evaluation of `(+ 5 1)` and `(* 5 2)` are done twice via `(* x
;;; x)`.

;;; This is called _normal-order evaluation_, and its "fully expand
;;; and then reduce" technique differs from the "evaluate the
;;; arguments and then apply" methodology of _applicative-order
;;; evaluation_ (which is what the interpreter uses). For any
;;; precedure application that can be modeled by the substition model,
;;; both of these techniques produce the same value.

;;; Lisp uses applicative-order evaluation due to both the additional
;;; efficiency gained from avoiding multiple evaluations and (more
;;; significantly) because normal-order evaluation is much more
;;; difficult when procedure application can no longer be modeled by
;;; substitution. Despite this, normal-order evaluation still has its
;;; uses.

;;; #### Conditional Expressions and Predicates

;;; Consider the definition of the absolute function:

;          /
;          |   x  if x > 0
;    |x| = <   0  if x = 0
;          |  -x  if x < 0
;          \

;;; This construct is called a _case analysis_. The `cond` special
;;; form expresses this in Lisp:

(define (abs x)
  (cond ((> x 0) x)
        ((= x 0) 0)
        ((< x 0) (- x))))

;; The general form of a conditional is

; (cond (<P1> <E1>)
;       (<P2> <E2>)
;       ...
;       (<PN> <EN>))

;;; Each `(<P> <E>)` pair is a clause, where P is a predicate and E is
;;; an expresion. A shorter way to write `abs` would be:

(define (abs x)
  (cond ((< x 0) (- x))
        (else x)))

;;; `else` is a special symbol that is used in the final clause as a
;;; default value. There's a shortcut for this form of `abs`:

(define (abs x)
  (if (< x 0)
      (- x)
      x))

;;; `if` takes the form

; (if <PREDICATE> <CONSEQUENT> <ALTERNATIVE>)

;;; The logical predicates are also available: `and`, `or`, and `not`.

(define (>= x y)
  (or (> x y) (= x y)))

(define (>= x y)
  (not (< x y)))

;;; ##### Exercises

;;; *Exercise 1.1:* Below is a sequence of expressions.  What is the
;;; result printed by the interpreter in response to each expression?
;;; Assume that the sequence is to be evaluated in the order in which
;;; it is presented.

; 10

;;; `10`

; (+ 5 3 4)

;;; `12`

; (- 9 1)

;;; `8`

; (/ 6 2)

;;; `3`

; (+ (* 2 4) (- 4 6))

;;; `6`

; (define a 3)

;;; Nothing is printed, but it assigns the value `3` to the symbol `a`.

; (define b (+ a 1))

;;; Nothing is printed, but it assigns the value `4` to the symbol `b`.

; (+ a b (* a b))

;;; `19`

; (= a b)

;;; '#f'

; (if (and (> b a) (< b (* a b)))
;     b
;     a)

;;; `4` (b is greater than a, and b is less than b * a)

; (cond ((= a 4) 6)
;       ((= b 4) (+ 6 7 a))
;       (else 25))

;;; `16` (b is 4)

; (+ 2 (if (> b a) b a))

;;; `6` (b > a)

; (* (cond ((> a b) a)
;          ((< a b) b)
;          (else -1))
;    (+ a 1))

;;; `16` (this reduces to `(* b (+ a 1))`)

;;; *Exercise 1.2:* Translate the following expression into prefix
;;; form.

;          5 + 4 + (2 - (3 - (6 + 4/5)))
;          -----------------------------
;                 3(6 - 2)(2 - 7)

(/
 (+ 5 4
    (- 2
       (- 3
          (+ 6
             (/ 4 5)))))
 (* 3
    (- 6 2) 
    (- 2 7)))

;;; *Exercise 1.3:* Define a procedure that takes three numbers as
;;; arguments and returns the sum of the squares of the two larger
;;; numbers.

(define (sum-greatest-squares x y z)
  (+
   (square (if (> x y z) 
               x 
               (if (> y z) y z)))
   (square (if (> x y z) 
               (if (> y z) y z)
               (if (> y x z) 
                   (if (> x z) x z)
                   (if (> x y) x y))))))

;;; *Exercise 1.4:* Observe that our model of evaluation allows for
;;; combinations whose operators are compound expressions.  Use this
;;; observation to describe the behavior of the following procedure:

          (define (a-plus-abs-b a b)
            ((if (> b 0) + -) a b))

;;; As the operand expression is evaluated to determine the final
;;; primitives for evaluation, the if statement is evaluated the
;;; determine the final operand (in this case, `+` or `-`).

;;; *Exercise 1.5:* Ben Bitdiddle has invented a test to determine
;;; whether the interpreter he is faced with is using
;;; applicative-order evaluation or normal-order evaluation.  He
;;; defines the following two procedures:

;          (define (p) (p))
;
;          (define (test x y)
;            (if (= x 0)
;                0
;                y))

;;; Then he evaluates the expression

;          (test 0 (p))

;;; What behavior will Ben observe with an interpreter that uses
;;; applicative-order evaluation?  What behavior will he observe with
;;; an interpreter that uses normal-order evaluation?  Explain your
;;; answer.  (Assume that the evaluation rule for the special form
;;; `if' is the same whether the interpreter is using normal or
;;; applicative order: The predicate expression is evaluated first,
;;; and the result determines whether to evaluate the consequent or
;;; the alternative expression.)

;;; *Case: applicative-order evaluation*:
;;;
; (test 0 p)
;  
; (test 0 (p))
;  
; (test 0 (p))
;; ... and so forth

;;; In applicative-order evaluation, the arguments are fully evaluated
;;; first, which leads to an infinite call chain attempting to
;;; evaluate `(p)`.
;;;
;;; *Case: normal-order evaluation*:
;;; 
; (test 0 p)
;  
; (if (= 0 0)
;     0
;     p)
;  
; (if t 0 p)
;  
; 0
;;; In normal-order evaluation, the expression is fully expanded
;;; before evaluating. In this case, `p` is never evaluated.

;;; #### Example: Square Roots by Newton's Method

;;; Newton's method: given a guess y for the value of the square root
;;; of x, there is a simple manipulation to get a better guess:
;;; average `y` with `x/y` and repeat. Formalised as a set of procedures:

(define (sqrt-iter guess x)
  (if (good-enough? guess x)
      guess
      (sqrt-iter (improve guess x)
                 x)))

(define (improve guess x)
  (average guess (/ x guess)))

(define (average x y)
  (/ (+ x y) 2))

;;; So, what's meant by "good enough"? We could employ a primitive
;;; technique and check that the square of the guess differs from the
;;; radicand by some tolerance:

(define (good-enough? guess x)
  (< (abs (- (square guess) x)) 0.001))

;;; Now we need an interface that takes the radicand as an argument:

(define (sqrt x)
  (sqrt-iter 1.0 x))

(sqrt 9)

(sqrt (+ 100 37))

(sqrt (+ (sqrt 2) (sqrt 3)))

(square (sqrt 1000))

;;; *Exercise 1.6* Alyssa O. Hacker doesn't see why `if` needs to be
;;; provided as a special form. "Why can't I just define it as an
;;; ordinary procedure in terms of `cond`?" she asks. Alyssa's friend
;;; Eva Lu Ator claims this can indeed be done, and she defines a new
;;; version of `if`:

(define (new-if predicate then-clause else-clause)
  (cond (predicate then-clause)
        (else else-clause)))

;;; Eva then demonstrates the program for Alyssa:

(new-if (= 2 3) 0 5)

(new-if (= 1 1) 0 5)

;;; Delighted, Alyssa uses new-if to rewrite the square-root program:

; (define (sqrt-iter guess x)
;   (new-if (good-enough? guess x)
;           guess
;           (sqrt-iter (improve guess x)
;                      x)))

;;; What happens when Alyssa attempts to compute square roots?
;;; Explain.

;;; _Answer_: The function will never end, because according to our
;;; evaluation rule, both the then and else clauses are evaluated
;;; _before_ the predicate is evaluated; this is due to the use of
;;; applicative-order "evaluate the arguments then apply" method.

;;; *Exercise 1.7:* The `good-enough?` test used in computing square
;;; roots will not be very effective for finding the square roots of
;;; very small numbers.  Also, in real computers, arithmetic
;;; operations are almost always performed with limited precision.
;;; This makes our test inadequate for very large numbers.  Explain
;;; these statements, with examples showing how the test fails for
;;; small and large numbers.  An alternative strategy for implementing
;;; `good-enough?` is to watch how `guess` changes from one iteration
;;; to the next and to stop when the change is a very small fraction
;;; of the guess.  Design a square-root procedure that uses this kind
;;; of end test.  Does this work better for small and large numbers?

;;; _Answer_: First, consider the case of a small number:

(square (sqrt 0.0001))

;;; The computed answer of `0.0010438...` is off by a factor of 10,
;;; illustrating the weakness of `good-enough?` in the case of very
;;; small numbers. Here, the number is small enough that our tolerance
;;; is larger than the number; our resolution is limited to the size
;;; of the tolerance, roughly. Next, consider the case

(square (sqrt 123456789123456789))

;;; The computer answer of `1.2345678912345678e+17` is also not quite
;;; accurate. The number is large enough that once the result is
;;; within some (still-large) value, it satisfies our tolerance
;;; condition.

;;; These results suggest that we could tune the tolerance, but that
;;; is a cat and mouse game, constantly changing the tolerance to
;;; match numbers better. 

(define (sqrt-iter guess x)
  (good-enough? (improve guess x) guess x))

(define (good-enough? improvement guess x)
  (if (< (abs (- improvement guess)) 0.001)
      improvement
      (sqrt-iter improvement x)))

;;; This works better for small numbers, but large numbers still don't
;;; work well -- they are limited to the resolution given by the
;;; Scheme number system.

;;; *Exercise 1.8:* Newton's method for cube roots is based on the
;;; fact that if y is an approximation to the cube root of x, then a
;;; better approximation is given by the value

;             x/y^2 + 2y
;             ----------
;                 3

;;; Use this formula to implement a cube-root procedure analogous to
;;; the square-root procedure. (In section 1-3-4 we will see
;;; how to implement Newton's method in general as an abstraction of
;;; these square-root and cube-root procedures.)

(define (cube-iter guess x)
  (good-enough3? (improve3 guess x) guess x))

(define (good-enough3? improvement guess x)
  (if (< (abs (- improvement guess)) 0.001)
      improvement
      (cube-iter improvement x)))

(define (improve3 guess x)
   (/ 
    (+
     (/ x (square guess))
     (* 2 guess))
    3))
   
(define (cube-root x)
  (cube-iter 1.0 x))

;;; #### Procedures as Black-Box Abstractions

;;; Notice that `sqrt-iter` is defined _recursively_: it is defined in
;;; terms of itself. This problem breaks down neatly into discrete
;;; subproblems. A useful decomposition strategy has each subproblem
;;; accomplishing a specific task that can be used as a combination in
;;; other procedures. We can regard these combinations as _black
;;; boxes_ &mdash; we don't concern ourselves with their
;;; implementation, only their functionality. In this way, `square` is
;;; not so much a procedure as an abstraction of a procedure, to wit:
;;; a _procedural abstraction_.

; *Figure 1.2:* Procedural decomposition of the `sqrt' program.
;  
;                       sqrt
;                        |
;                    sqrt-iter
;                    /       \
;            good-enough    improve
;              /    \          |
;           square  abs     average

;;; A procedure definition should be able to suppress detail: users
;;; shouldn't need to concern themselves with how the procedure
;;; arrives at its answer, only that it arrives at the correct answer.

;;; ##### Local Names
;;;
;;; The choice of parameter names for procedures shouldn't affect
;;; users: that is, the following should be indistinguishable:

; (define (square x) (* x x))

; (define (square y) (* y y))

;;; This may seem to be an obvious principle but it carries profound
;;; implications, the simplest of which is that the parameter names
;;; *must* be local to the body of the procedure. If an implementation
;;; of `square` used `x` as a parameter name, the definition of
;;; `good-enough?` should not be affected by this. Otherwise, their
;;; values could be confused and neither would serve as a useful black
;;; box.

;;; Names in situations such as these are referred to as _bound
;;; variables_; it is said that the procedure _binds_ its formal
;;; parameters. It a variable is not bound, it is said to be _free_;
;;; the set of expressions defining a name comprise the _scope_ of
;;; that name. Notice that in Scheme, variable names occupy the same
;;; environment as function names; accordingly, had `good-enough?`
;;; been named `abs`, it would introduce a bug by _capturing_ the
;;; previously defined _abs_.

;;; ##### Internal definitions and block structure
;;;
;;; So far, we have seen one kind of name isolation: formal parameter
;;; are local to the body of their enclosing procedure. However, in
;;; the definitions germane to `sqrt` we see another type of isolation
;;; that would be useful: of all the definitions, only `sqrt` is
;;; useful to an end user. The other definitions only service to
;;; introduce noise masking the one definition useful to user. Abelson
;;; and Sussman use the wondeful phrasing,

;;; > The other procedures&hellip; only clutter up their minds.

;;; If we were to build a library of mathematical procedures, many of
;;; the functions would be computed through successive approximation,
;;; which require many accompanying auxillary functions such as
;;; `good-enough?` and `improve`. Subprocedures may be localised, such
;;; that they may co-exist with others and allowing each numerical
;;; function to have its own `good-enough?` and `improve` through the
;;; use of internal definitions. For example, we could write the
;;; square root function as

(define (sqrt x)
  (define (good-enough? guess x)
    (< (abs (- (square guess) x)) 0.001))
  (define (improve guess x)
    (average guess (/ x guess)))
  (define (sqrt-iter guess x)
    (if (good-enough? guess x)
        guess
        (sqrt-iter (improve guess x) x)))
  (sqrt-iter 1.0 x))

;;; This nesting of definitions is called _block structure_, and is a
;;; basic approach to the simplest name-packaging problems. However,
;;; it can be simplified further: note that `x` is shared among many
;;; of the functions &mdash; we can allow it to be a free variable in
;;; the definitions. It will then derive its value from the enclosing
;;; expressions (a discipline termed _lexical scoping_).

(define (sqrt x)
  (define (good-enough? guess)
    (< (abs (- (square guess) x)) 0.001))
  (define (improve guess)
    (average guess (/ x guess)))
  (define (sqrt-iter guess)
    (if (good-enough? guess)
        guess
        (sqrt-iter (improve guess))))
  (sqrt-iter 1.0))

