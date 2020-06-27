# The Roo Language Reference

This reference document describes the syntax and core semantics of the Roo programming language. The semantics of the built-in data types and of the built-in functions and modules are described in [The Roo Standard Library](/roo/docs/standard-library). For information on embedding Roo in a Xojo application see [Embedding Roo](/roo/docs/embedding).

- [Introduction](#introduction)
- [Scanning](#scanning)
	- [Line Structure](#scanning-line-structure)
	- [Blank Lines](#scanning-blank-lines)
	- [Comments](#scanning-comments)
	- [Indentation](#scanning-indentation)
	- [Whitespace between tokens](#scanning-whitespace)
	- [Identifiers and Keywords](#scanning-identifiers-and-keywords)
	- [Literals](#scanning-literals)
	- [Operators](#scanning-operators)
	- [Delimiters](#scanning-delimiters)
	- [Programs With Multiple Source Files](#scanning-multiple-source-files)
- [Mathematical operators](#mathematical-operators)
	- [Basic Aritmetic](#basic-arithmetic)
	- [Modulo Operator](#modulo-operator)
	- [Exponention Operator](#exponention-operator)
	- [Unary Negation](#unary-negation)
	- [Boolean Negation](#boolean-negation)
- [Bitwise Operators](#bitwise-operators)
	- [The & Operator](#bitwise-operators-and)
	- [The | Operator](#bitwise-operators-or)
	- [The << Operator](#bitwise-operators-left-shift)
	- [The >> Operator](#bitwise-operators-right-shift)
- [Logical Operators](#logical-operators)
	- [Equality](#equality)
	- [Comparison Operators](#comparison-operators)
	- [And and Or](#logical-and-or)
- [Variables](#variables)
	- [Scope](#variables-scope)
- [Assignment](#assignment)
- [Simple Statements](#simple-statements)
	- [The pass Statement](#simple-statements-pass)
	- [The return Statement](#simple-statements-return)
- [Functions](#functions)
- [Control Flow](#control-flow)
	- [The break Statement](#control-flow-break)
	- [The exit Statement](#control-flow-exit)
	- [The while Loop](#control-flow-while)
	- [The for Loop](#control-flow-for)
	- [if Constructs](#control-flow-if)
	- [Ternary Conditionals](#control-flow-ternary-conditionals)
- [The Object System](#the-object-system)
- [Classes](#classes)
	- [Methods](#classes-methods)
	- [Properties](#classes-properties)
	- [Getters](#classes-getters)
	- [Static Methods and Getters](#classes-static-methods-and-getters)
	- [Text Representation](#classes-text-representation)
	- [Inheritance](#classes-inheritance)
- [Modules](#modules)
- [Style Guide](#style-guide)

---

## <a name="introduction"></a>Introduction

This reference document describes the Roo programming language. It is not a tutorial. Whilst some implementation details are provided, I have deliberately not gone into too much detail about them as other implementations of the language (should any appear) may choose to implement a feature differently. For the purposes of this document, you can assume that I'm using the [reference implementation](https://github.com/gkjpettet/roo) of the interpreter which is written in [Xojo](https://xojo.com).

---

## <a name="scanning"></a>Scanning

The first step in running a Roo program is lexical analysis or _scanning_. This is performed by a _scanner_. The purpose of the scanner is to split the source code into a stream of _tokens_. Tokens not only contain information about the type of token encountered but also many other pieces of metadata such as the line number that the token occurred on, the script file it is from, etc. Roo expects source code to be UTF-8 encoded. Odd things will happen if you feed it text of a different encoding.

The scanner handles newline characters by standardising them at the beginning of the scanning process to the `Line Feed` character (unicode `U+000A`). This ensures that programs written on different operating systems can run on any platform that has a Roo interpreter.

### <a name="scanning-line-structure"></a>Line Structure

A Roo program is divided into one or more _logical lines_.

##### Physical lines
 A _physical line_ is a visibly distinct line of source code as visible to the human eye. They are never more than one line long.

##### Logical lines
A _logical line_ can span multiple physical lines. Typically, the end of a logical line is represented by the newline character which, as described above, is considered to be `U+000A`. However, if the scanner reaches a newline character but has previously encountered unmatched `(`, `[` or `{` tokens then it ignores the newline character and continues as if it is still on the same line of source code. This permits things like multiline declarations of `Hash` objects:

```roo
var h = {
	"name" => "Garry",
	"age" => 37
}
```

Text literals may also span more than one physical line. The scanner will continue looking for characters within a text literal if it has encountered unmatched `'` or `"` tokens. For example:

```roo
var line1 = "This is a single line text literal"
var line2 = "This spans
multiple lines"
```

### <a name="scanning-blank-lines"></a>Blank Lines

A physical line containing just a newline character is ignored.

### <a name="scanning-comments"></a>Comments

A comment starts with a hash character (`#`) that is not part of a text literal and ends at the end of the physical line. Comments are ignored by the scanner, they are not tokens.

### <a name="scanning-indentation"></a>Indentation

Leading tabs at the beginning of a logical line are used to determine the indentation level of the line which, in turn, is used to determine the grouping of statements and their scope. Tabs and spaces are **not** interchangeable. Indentation is determined purely by the number of contiguous tabs from the start of a line. In fact, if any whitespace other than a tab is encountered at the start of a line, a scanning error is raised. This decision was made because it seems nuts to mix spaces and tabs as although they look physically similar to the eye they confuse the heck out of a scanner.

The indentation levels of consecutive lines are used to generate `INDENT` and `DEDENT` tokens using a simple stack-based system. Before the first line of input is read, a single zero is pushed onto the stack; this will never be popped off. The numbers pushed onto the stack will always increase from top to bottom. At the beginning of each logical line, the line's indentation level (as determined by the number of leading tab characters) is compared to the number on the top of the stack. If the numbers are equal then nothing happens. If the current line's indentation level is greater than the number on the top of the stack, this number is pushed onto the stack and one `INDENT` token is generated. If the current line's indentation level is smaller than the number on the top of the stack it _must_ match one of the numbers already on the stack. All numbers on the stack that are smaller than the current line's indentation level are popped off the stack and for each number popped off, a `DEDENT` token is generated. At the end of the source code, a `DEDENT` token is generated for each number remaining on the stack that is greater than zero.

Below is an example of correctly indented Roo code:

```roo
def fizz_bang(start, end):

	# Check we have positive integers.
	assert(start.type == "Number" and start.integer? and start >= 0, "You need to enter an integer >= 0 for `start`")
	assert(end.type == "Number" and end.integer? and end >= 0, "You need to enter an integer >= 0 for `end`")
	
	# Make sure end is after start.
	assert(end > start, "`end` must be greater than `start`")
	
	for (var num = start; num <= end; num += 1):
		if num % 3 == 0 and num % 5 == 0:
			print("FizzBuzz")
		or num % 3 == 0:
			print("Fizz")
		or num % 5 == 0:
			print("Buzz")
		else:
			print(num)

# Get the start and end values.
var start = input_value("Enter the start number (positive integer)")
var end = input_value("Enter the end number (positive integer)")

# FizzBang them.
fizz_bang(start, end)
```

### <a name="scanning-whitespace"></a>Whitespace Between Tokens

Except for the beginning of logical lines, whitespace (tabs and spaces) can be used interchangeably to separate tokens. Whitespace is only needed between tokens if their concatenation coould otherwise be interpreted as a different token. For instance, `a=b` and `a = b` are both the same. `foobar` is one token but `foo bar` is two tokens.

### <a name="scanning-identifiers-and-keywords"></a>Identifiers and Keywords

Identifiers (aka object names) begin with either an upper or lower case letter (a-z or A-Z, ASCII range) or an underscore (`_`). They then may have zero or more upper or lower case letters, underscores or digits (`0-9`). Optionally they may be suffixed with either `?` or `!` (but not both). Identifiers are unlimited in length and are **case sensitive**. Only ASCII characters are permitted for identifiers. Emoji are not supported (although work fine in text literals).

The following are examples of valid and invalid identifiers:

```roo
# Valid.
name
_my_variable
hero1
shout!

# Invalid.
1stop # Starts with a digit
😀 # Roo dislikes emoji
```

The following identifiers are used as reserved words (aka _keywords_) by the Roo language. They cannot be used as ordinary identifiers. Like the rest of Roo, they are case sensitive:

```
and		exit		not		require		var
break		False		Nothing		self		while
class		for		or		static
def		if		pass		super
else		module		quit		True
```

### <a name="scanning-literals"></a>Literals

Literals are notations for constant values for some of the built-in types.

#### Text Literals

Text literals are a stream of characters enclosed by matching pairs of either single (`'`) or double (`"`) quotes. Smart quotes (e.g: `“` or `”`) cannot be used to enclose a text literal but can be included within one. A double quote can be included within a text literal that is declared with enclosing double quotes by _escaping_ it with `\"`. Similarly, a single quote can be included within a text literal that is declared with enclosing single quotes by escaping it with `\'`. Examples:

```roo
var t1 = "Enclosed with double quotes"
var t2 = 'Enclosed with single quotes'
var t3 = "Escaped \" in double quotes"
var t4 = 'Escaped \' in single quotes'
```

Text literals can also span multiple lines as the scanner is smart enough to know that a non-terminated quote implies the logical line should continue:

```roo
var lorem = "Lorem ipsum dolor sit amet, consectetur 
adipiscing elit, sed do eiusmod tempor incididunt 
ut labore et dolore magna aliqua."
```

#### Numeric Literals

There are two types of numeric literals: integers and doubles (also known as floating point numbers). Note that numeric literals do not include a sign; a phrase like `-5` is actually an expression composed of the unary operator `-` and the literal `5`.

##### Integer Literals

Integer literals can be of four bases: decimal, hexadecimal, octal and binary. Decimal base integers are simply written as you would expect. Numbers like `10`, `3` and `10456` are all decimal integers. 

Hexadecimal numbers are prefixed with `0x`. This prefix should immediately be followed by any number and combination of contiguous characters in the range `a-f`, `A-F` and `0-9`. Case is ignored. For example, the decimal number `1234` can be expressed in hexadecimal as `0x4d2`.

Octal numbers are prefixed with `0o`. This prefix should be immediately followed by any number and combination of the digits `0-7`. For example, the decimal number `1234` can be expressed in octal as `0o2322`.

Binary numbers are prefixed with `0b`. This prefix should immediately be followed by any number of `0` or `1` digits. For example, the decimal number `1234` can be expressed in binary as `0b10011010010`.

##### Double literals

Below are a few examples of valid double literals:

```roo
100.5
0.01
3e4 # 30000
20.5e-2 # 0.205
```

Note that fractional numbers less than zero must be prefixed with a zero. For example, `0.5` is a valid number, `.5` is not.

### <a name="scanning-operators"></a>Operators

The following tokens are considered to be operators by the scanner:

```
+		-		*		/		%
<<		>>		&		|		^
<		>		<=		>=		==
<>
```

### <a name="scanning-delimiters"></a>Delimiters

The following tokens are delimiters in the grammar:

```
(		)		[		]		{
}		,		.		:		;
=		=>		+=		-=		*=
/=		%=		?
```

The following ASCII characters have special meaning to the scanner:

```
'		"		#		\
```

### <a name="scanning-multiple-source-files"></a>Programs With Multiple Source Files

Writing a program in a single file is fine for small tasks but more complicated programs are better when split across multiple files. They are easier to read and maintain and code can be reused more easliy.

To include one file within another use the `require` keyword. It accepts a single argument without parentheses (a `Text` literal). The Roo interpreter is smart enough to only require a file once and so subsequent calls to require the same file will be ignored.

```roo
require "/Users/garry/Desktop/test1.roo" # Absolute paths begin with `/`
require "/Users/garry/Desktop/test2" # Note the `.roo` extension is optional
require "test3.roo" # Can pass a path relative the the current script file
```

---

## <a name="mathematical-operators"></a>Mathematical Operators

Like all good programming lanaguages, Roo provides a rich set of standard mathematical operators. 

### <a name="basic-arithmetic"></a>Basic Arithmetic

Roo supports the addition (`+`), subtraction (`-`), division (`/`) and multiplication (`*`) operators.

```roo
3 + 3 # 6
10 - 4 # 6
9 * 9 # 81
30 / 3 # 10
```

### <a name="modulo-operator"></a>Modulo Operator

The modulo operation finds the remainder after division of one number by another. The modulo operator is `%`.

```roo
5 % 2 # 1 (5 divided by 2 leaves a remainder of 1)
```

### <a name="exponention-operator"></a>Exponention Operator

The `^` operator is used to perform exponention.

```roo
2 ^ 2 # 4
(2 + 3) ^ (4 - 2) # 25
3.75 ^ 3.5 # 102.12
```

### <a name="unary-negation"></a>Unary Negation

The unary negation operator (`-`) negates a numeric value.

```roo
-5 # -5
var i = -3 # -3
-i # 3
```

### <a name="boolean-negation"></a>Boolean Negation

The boolean negation operator (`!`) negates a boolean value.

```roo
!True # False
!(10 > 20) # True
```

---

## <a name="bitwise-operators"></a>Bitwise Operators

Bitwise operators operate on `Number` objects at the binary level. 

### <a name="bitwise-operators-and"></a>The & Operator

The `&` operator performs a bitwise _and_ operation on two `Number` operands and returns a new `Number` object:

```roo
print(7 & 5) # 5

# Explanation:
#  7 in Base 2: 0000 0111
#  5 in Base 2: 0000 0101
#   128 64 32 16 8 4 2 1
#  ---------------------- 
# 7: 0  0  0  0  0 1 1 1
#    &  &  &  &  & & & &
# 5: 0  0  0  0  0 1 0 1
# -----------------------
# 5: 0  0  0  0  0 1 0 1
```

### <a name="bitwise-operators-or"></a>The | Operator

The `|` operator performs a bitwise _or_ operation on two `Number` operands and returns a new `Number` object:

```roo
print(7 | 5) # 7

# Explanation
# 7 in Base 2: 0000 0111
# 5 in Base 2: 0000 0101
#  128 64 32 16 8 4 2 1
# ---------------------- 
# 7: 0  0  0  0  0 1 1 1
#    |  |  |  |  | | | |
# 5: 0  0  0  0  0 1 0 1
#  ----------------------
# 7: 0  0  0  0  0 1 1 1
```

### <a name="bitwise-operators-left-shift"></a>The << Operator

The `<<` is the _left shift_ operator. It shifts each bit of a `Number` object to the left by the number of positions specified by its right-hand `Number` operand.

```roo
print(7 << 2) # 28 

# Explanation:
# 7 in Base 2: 0000 0111
#    128 64 32 16  8 4 2 1
#   ---------------------- 
# 7:  0  0  0  0   0 1 1 1
# Shift each bit to the left by 2 positions
#   ----------------------
# 28: 0  0  0  1   1 1 0 0
```

### <a name="bitwise-operators-right-shift"></a>The >> Operator

The `>>` is the _right shift_ operator. It shifts each bit of a `Number` object to the right by the number of positions specified by its right-hand `Number` operand.

```roo
print(40 >> 2) # 10

# Explanation:
# 40 in Base 2: 0010 1000
#    128 64 32 16  8 4 2 1
#    ---------------------- 
# 7:  0  0  1  0   1 0 0 0
# Shift each bit to the right by 2 positions
#    ----------------------
# 10: 0  0  0  0   1 0 1 0
```

---

## <a name="logical-operators"></a>Logical Operators

Logical operators compare two operands and return either `True` or `False`.

### <a name="equality"></a>Equality

The equality operator (`==`) determines if two objects are equal to one another. If they are it returns `True`, if not it returns `False`.  The following rules for equality apply in Roo:

1. If two identifiers refer to the same object in memory they are considered equal
2. If two `Text` objects are compared and they match exactly in both length and case they are considered equal
3. `Number` and `Boolean` objects are compared by value, not by location in memory
4. Two `DateTime` objects are considered equal if they have identical [UNIX time](https://en.wikipedia.org/wiki/Unix_time) values
5. `Nothing` always equals `Nothing`

```roo
var a = 100
var b = a
a == b # True

var c = "Hello"
c == "Hello" # True
c == "hello" # False (remember: case-sensitive!)

30 == 30 # True

var d1 = DateTime(1552142940) # 9th March 2019 @ 14:49
var d2 = DateTime(1552142940)
d1 == d2 # True

var e
e == Nothing # True
```

The opposite of the equality operator is the "not equal" operator (`<>`).

```roo
100 <> 50 # True
```

### <a name="comparison-operators"></a>Comparison Operators

You can determine if a `Number` object is greater than another with the `>` operator. The `<` operator determines if one `Number` object is less than another. `DateTime` objects can also be compared with the `>` and `<` operators. Attempting to compare other types of objects will result in a runtime error.

```roo
1 < 2 # True
2 > 3 # False

var now = DateTime()
var yesterday = DateTime().sub_days(1)
now > yesterday # True
```

### <a name="logical-and-or"></a>And and Or

The `and` and `or` operators performs a logical comparison between two boolean expressions. Any expression that evaluates to a `Boolean` object can be compared. They can be chained together.

```roo
var rich = True
var beautiful = False
var happy = rich and beautiful # False
rich or happy # True
```

---

## <a name="variables"></a>Variables

Variables must be declared before they are used. This is done with the `var` keyword. A variable may be assigned a value when declared (so called _initialisation_). If a value is not assigned at declaration time then it defaults to `Nothing`.

```roo
var age # Nothing
var name = "Spider-Man"
```

### <a name="variables-scope"></a>Scope

A **scope** is a region where a name maps to a certain entity. Multiple scopes enable the same name to refer to different things in different contexts. Variables declared at the top level of the script are **global** in scope. That is, they are visible to the whole program. Variables declared in functions, classes and modules are scoped to the containing function, class or module. They are **encapsulated** within their enclosing scope.

Thanks to encapsulation, it is possible to _shadow_ a variable in an enclosing scope with a newly declared variable in an inner scope:

```roo
# How loud?
var volume = 11

# Silence.
volume = 0

# Calculate size of 3x4x5 cuboid.
def test():
	var volume = 3 * 4 * 5
	print(volume) # 60

test() # 60
print(volume) # 0
```

In addition to a new scope being created within the bodies of functions, methods, classes and modules, you can create a **block** by indenting code:

```roo
var outer = "outer"

	var inner = "inner"
	print(inner) # "inner"
	print(outer) # "outer"

print(outer) # "outer"
print(inner) # Runtime error (`inner` doesn't exist in this scope)
```

Re-declaring a variable in the same scope will overwrite it **without** raising an error:

```roo
var team = "Manchester United"
var team = "Chelsea"
print(team) # "Chelsea"
```

---

## <a name="assignment"></a>Assignment

Variable assignment is performed with the `=` operator. Note this is an entirely separate operator from the equality (`==`) operator described elsewhere.

```roo
var name # Nothing
name = "Tony" # `name` now has the value "Tony"
```

Everyone loves syntactic sugar which is why Roo has a number of **compound assignment operators**:

```roo
var counter = 0
counter += 10 # 10 (addition assignment)
counter -= 4 # 6 (subtraction assignment)
counter *= 5 # 30 (multiplication assignment)
counter /= 10 # 3 (division assignment)
counter %= 2 # 1 (modulus assignment)
```

---

## <a name="simple-statements"></a>Simple Statements

A simple statement is contained within a single logical line. Several simple statements may occur on a single line separated by semicolons. Many of the simple statements are described elsewhere in this document where it seems more appropriate (e.g. [`break`](#control-flow-break) in the [Control Flow](#control-flow) section).

### <a name="simple-statements-pass"></a>The pass Statement

`pass` is a null operation. When it's executed nothing happens. It's useful as a placeholder when a statement is required syntactically but no code needs to be executed:

```roo
# Use `pass` to stub out functions.
def empty1(): pass

def empty2():
	pass

# `pass` is also useful for stubbing out non-implemented classes.
class Person: pass # A class with no methods (yet).
```

### <a name="simple-statements-return"></a>The return Statement

The `return` statement may only occur within the body of a function. It is used to return a value from a function. When encountered, execution of the function ends immediately and the value specified by the `return` statement is returned to the caller. By default, functions return `Nothing` unless commanded to return something with the `return` keyword.

```roo
def echo(what):
	return what

var a = echo("Hello") # a is now "Hello"

def silence(what): pass

var b = silence("Hello") # b is now Nothing as no return value specified.
```

---

## <a name="functions"></a>Functions

Functions allow you to encapsulate and reuse code. Defining a function is done with the `def` keyword. 

```roo
def say_boo():
	print("Boo!")

# Call it like so:
say_boo() # Prints "Boo!"
```

Functions can take parameters too:

```roo
def say_hi(forename, surname):
	print("Hi " + forename + " " + surname + "!")

say_hi("Garry", "Pettet") # Prints "Hi Garry Pettet!"
```

Since functions are objects, they can be assigned to variables and subsequently invoked:

```roo
def woof():
	print("Bow wow")

var noise = woof # Note the exclusion of the parentheses
noise() # Prints "Bow wow"

# All objects also have an innate textual representation.
print(noise) # Prints "<function woof>"
```

---

## <a name="control-flow"></a>Control Flow

Before we can talk about control flow, we need to understand what _truthiness_ is. A _truthy_ value is a value that is considered true for a logical operation. A _falsey_ value is considered false for a logical operation. The only falsey values in Roo are `Nothing` and `False`. **Everything** else is truthy.

### <a name="control-flow-break"></a>The break Statement

Use the `break` statement to break out of a `for` or `while` loop early:

```roo
var a = 2
while (a +=1 ) < 20:
	if (a == 10): break # Jumps to `print(a)`

print(a) # 10
```

The `break` keyword can be conditional by following it with the `if` keyword and then an expression:

```roo
var balance = 0
while True:
	print("Balance: £" + balance)
	balance += 1000
	break if balance > 9999

# Prints:
# Balance: £0
# Balance: £1000
# Balance: £2000
# Balance: £3000
# Balance: £4000
# Balance: £5000
# Balance: £6000
# Balance: £7000
# Balance: £8000
# Balance: £9000
```

### <a name="control-flow-exit"></a>The exit Statement

Use the `exit` statement to break out of an `if` construct early:

```roo
if True:
	print("This is shown")
	exit
	print("This is never printed")
```

### <a name="control-flow-while"></a>The while Loop

A `while` loop executes its body whilst its condition is _truthy_.

```roo
while some_condition:
	# Do something.
```

The condition is first tested and if _truthy_ the body is executed. Note that it's therefore possible that the body never executes. If you need to execute the body at least once and then check for a breaking condition, you can do something like this:

```roo
while True:
	# Do something.
	break if some_condition
```

### <a name="control-flow-for"></a>The for Loop

`for` loops are a powerful looping mechanism. The syntax of a `for` loop is:

```
for (INITIAL_EXPRESSION; TEST_EXPRESSION; ITERATION_EXPRESSION):
	# Code block to execute.
```

As you can see, there are three `for` loop expressions, separated by semicolons and enclosed in parentheses. All of the expressions are optional but the semicolons are not. The `for` loop declaration is terminated by a colon (`:`).

The first expression is evaluated once, at the beginning of the loop. Typically this is used to set the value of an existing variable or to declare a new variable and assign a value to it. Often this is the counter for the loop.

The second expression is evaluated at the **beginning of each iteration** of the loop. If the expression is _truthy_ then the body of the loop is executed. If this expression is _falsey_ then the loop exits.

Finally, a third expression can be provided which is evaluated at the **end of each iteration** of the loop.

```roo
# Print the first 10 numbers.
for (var i = 1; i <= 10; i += 1):
	print(i)

# As above but notice that we use an existing variable as our counter.
var j = 1
for (; j <= 10; j += 1):
	print(j)
```

An infinite loop can be created by omitting the test (i.e: the second) expression. We can also omit the initial expression and the iteration expression if we like. Note how the semicolons are still required after an absent first and/or second expression:

```roo
for (;;):
	print("Wakanda forever") # Bad idea. Prints this forever.
```

Of course the above infinite loop could just as easily be created with a more readable while loop:

```roo
while True:
	print("Wakanda forever")
```

As with `while` loops, we can exit them at any point with the `break` statement.

```roo
for (var i = 0; ; i += 1):
	print("Wakanda forever")
	break if i == 10
```

### <a name="control-flow-if"></a>if Constructs

The `if` construct evaluates its branch of code **only** if its condition is _truthy_. An `if` clause's condition may or may not be enclosed in parentheses (do whatever you feel makes your code more readable).

```roo
var name = "Garry"
if name.length == 5:
	print("5 character name")
```

If the block of code that makes up an `if` branch is a single statement or expression then the `if` construct can be reduced to one line of code. Given the above example:

```roo
var name = "Garry"
if name.length == 5: print("5 character name")
```

If an `if` clause's condition is _falsey_ then it will evaluate its `else` branch (optional):

```roo
if False:
	print("This is never printed")
else:
	print("This is shown")
```

Use the `or` keyword to add additional conditions that will be evaluated (sequentially) for their truthiness if the `if` condition is _falsey_. The first `or` condition that is _truthy_ will have its branch evaluated:

```roo
var a = 3

if a == 1:
	print("a == 1")
or a == 2:
	print("a == 2")
or a == 3:
	print("a == 3")
else:
	print("a is something else")
```

### <a name="control-flow-ternary-conditionals"></a>Ternary Conditionals

The ternary operator allows us to write an `if...else` construct in a shorter way:

```roo
var a
if 1 > 2:
	a = 3
else:
	a = 4

# The above can be re-written as:
var a = 1 > 2 ? 3 : 4 # 4
```

The syntax is: `(condition) ? (value if truthy) : (value if falsey)`.

---

## <a name="the-object-system"></a>The Object System

In Roo, everything (except for functions) are objects. The following points apply to all objects:

- They have a **type**
- The respond to methods

Methods are functions that _belong to an object_. The Roo object system provides a mechanism for determining an object's type at runtime and whether or not it responds to a particular method. The only way to query the internal state of an object is through that instance's methods:

```roo
var n
n.type # Nothing.

var i = 10
i.type # Number

i.responds_to?("laugh") # False.
i.responds_to?("sqrt") # True.
```

Since everything is an object, you can even call methods on literals:

```roo
var name = "iron man".reverse # "nam nori"
9.sqrt # 3

# Chain calls to your heart's content.
var t = True.to_text.reverse.uppercase # EURT
```

---

## <a name="classes"></a>Classes

A class is a blueprint from which individual objects or _instances_ are created. The below example shows how to create an empty class blueprint for a `Person` class:

```roo
class Person: pass # The `pass` statement is required if the body of a class is empty.
```

It's convention that class (and module) names start with an uppercase letter although this is not enforced by the interpreter.

A new instance of a class is created by calling the class name like a function:

```roo
var peter = Person()
```

At the moment, the `Person` class is not very useful so let's add some functionality to it. A person should have a name and an age. These values will be stored internally in properties on the `Person` instance called `name` and `age`. Since every person needs these attributes, we want to make sure we specify them at the time of creation of the `Person` instance. We do this with a special `init()` method. The `init()` method is optional.

```roo
class Person:
	def init(name, age):
		self.name = name
		self.age = age
```

Now we can create people like this:

```roo
var peter = Person("Peter", 17)
var tony = Person("Tony", 40)

# Print out some instance values.
print(peter.age) # 17
print(tony.name) # "Tony"

# We can also alter the existing properties:
tony.name = "Anthony"
print(tony.name) # "Anthony"
```

### <a name="classes-methods"></a>Methods

Let's carry on extending our `Person` class. People usually like to interact so let's add a method so people can greet each other:

```roo
class Person:
	def init(name, age):
		self.name = name
		self.age = age
	
	def greet(someone):
		print("Hello " + someone)

var peter = Person("Peter", 17)
peter.greet("Tony") # "Hello Tony"
```

### <a name="classes-properties"></a>Properties

A _property_ holds a value. That value can be any object or function. Properties can be added to instances of classes dynamically:

```roo
var hulk = Person("Bruce", 45)
hulk.colour = "Green"
print(hulk.colour) # "Green"
```

As we saw above, properties can also be added to an instance within a class definition, such as the `name` and `age` properties. Note that when in a class definition and you want to refer to the particular instance of that class, use the `self` keyword.

### <a name="classes-getters"></a>Getters

_Getters_ are methods without parameters. They allow a class to return a computed value. They are invoked with their name without trailing parentheses. Let's add to the `Person` class the ability to print out how many days old they are:

```roo
class Person:
	def init(name, age):
		self.name = name
		self.age = age
	
	def greet(someone):
		print("Hello " + someone)
	
	def days_old:
		return self.age * 365

var peter = Person("Peter", 17)
print(peter.days_old + " days") # "6205 days"
```

It's worth remembering that instance methods, getters and properties can be overriden on a per-instance basis simply by assigning a different value to them:

```roo
def boo():
	return "Boo!"

var peter = Person("Peter", 17)
print(peter.days_old) # 6205

peter.days_old = boo()
print(peter.days_old) # "Boo!"
```

### <a name="classes-static-methods-and-getters"></a>Static Methods and Getters

Static methods and getters are associated with a particular class rather than a specific instance. To make a method or getter within a class definition static, simply prefix the its declaration with the `static` keyword:

```roo
class Pizza:
	def init(ingredients):
		self.ingredients = ingredients
		
	static pepperoni:
		return Pizza(["cheese", "pepperoni"])
	
	static hawaiian:
		return Pizza(["cheese", "pineapple", "ham"])
		
var p1 = Pizza.pepperoni
var p2 = Pizza.hawaiian

print(p1.ingredients) # ["cheese", "pepperoni"]
print(p2.ingredients) # ["cheese", "pineapple", "ham"]
```

### <a name="classes-text-representation"></a>Text representation

Every object in Roo has a text representation. For simple data types like `Text`, `Number` and `Boolean` literals this is their value. E.g:

```roo
var t = "Hello" # "Hello"
var n = 100 # "100"
var b = True # "True"
```

Other intrinsic data types have more varied text representations such as:

```roo
var r = Request() # "<Request instance>"
var f = File("/Users/garry/Desktop") # "Users/garry/Desktop"
```

If you create a custom class and you try to either print it with the global `print()` function or concatenate it with a `Text` object, by default you'll get something like:

```roo
class Person:
	def init(name):
		self.name = name
		
var p = Person("garry")
print(p + " is cool") # "<Person instance> is cool"
```

The default text representation of `"<Person instance>"` is a little unhelpful. Fortunately, Roo allows us to provide a getter in the class definition that Roo will call whenever it needs a text representation of an instance of your custom class. Just define a getter named `to_text`:

```roo
class Person:
	def init(name):
		self.name = name
	
	def to_text:
		# Lets return this person's name capitalised.
		return self.name.capitalise
		
var p = Person("garry")
print(p + " is cool") # "Garry is cool"
```

### <a name="classes-inheritance"></a>Inheritance

A class can inherit from another class. The class that is inheriting is called the **subclass** and the class that is inherited from is the **superclass**. When a class inherits from another it gains all of the methods, getters and properties already defined in the superclass. Roo supports single inheritance. Inheritance is specified in the class declaration with the `<` operator:

```roo
class Person:	
	def greet(someone):
		print("Hello " + someone)

class MadScientist < Person:
	def exclaim:
		print("Great Scott!")

var emmett = MadScientist()
emmett.greet("Marty") # "Hello Marty"
emmett.exclaim # "Great Scott!"
```

If a superclass defines an `init()` method, it is **not** inherited by the subclass. It can however be accessed by the subclass using the `super` keyword:

```roo
class Person:
	def init(name):
		self.name = name
		print("Hello from the Person init() method")

class MadScientist < Person:
	def init(name):
		super.init(name)
		print("Hello from the MadScientist init() method")

var emmett = MadScientist("Doc Brown")
# Prints:
# "Hello from the Person init() method"
# "Hello from the MadScientist init() method"
```

The `super` keyword allows you to access any of the methods, getters and properties on the superclass, not just the `init()` method.

You can override methods defined in the superclass by simply re-defining them in the subclass.:

```roo
class Person:
	def greet:
		print("I'm a person")

class MadScientist < Person:
	def greet:
		print("I'm a mad scientist!")

var marty = Person()
var emmett = MadScientist()

marty.greet # "I'm a person"
emmett.greet # "I'm a mad scientist!"
```

---

## <a name="modules"></a>Modules

Modules serve as a namespace for defining other classes, modules, methods and getters. They are an excellent way to reuse code and make creating libraries to share with other Roo users easy. Below is an example of a module as a namespace:

```roo
module HTML:
	class Parser:
		def parse(text):
			print("I don't know how to parse yet!")
		
	def ampersand:
		return "&amp;"
		
	def copyright:
		return "&copy;"
		
	def wrap_in_tags(what, tag_name):
		return "<" + tag_name + ">" + what + "</" + tag_name + ">"

var parser = HTML.Parser()
parser.parse("something") # "I don't know how to parse yet!"
HTML.copyright # "&copy;"
HTML.ampersand # "&amp;"
HTML.wrap_in_tags("Some text", "p") # "<p>Some text</p>"
```

---

## <a name="style-guide"></a>Style Guide

Whilst you are free to style your identifiers however you wish, it's suggested that the following format is used:

- Class and module names should begin with capital letters (e.g: `Person`) and be CamelCased
- Functions and methods should begin with a lowercase letter and use snake_case (e.g: `increase_score()`)
- Functions and methods that return a Boolean should end with `?` (e.g: `has_paid?()`)
- Methods that are destructive to the object they belong to should end with `!` (e.g: `capitalise!`)
- Variables that are intended to be private should start with an underscore (e.g: `_counter`)