# The Roo Standard Library

Roo's standard library is intentionally comprehensive and is designed to provide easy solutions to common problems and to provide terse options for dealing with common scenarios. The standard library comprises a mixture of global functions and modules as well as methods on Roo's native types.

- [Generic Getters and Methods](#generic-getters-methods)
- Native Types
	- [Nothing](#nothing)
	- [Boolean](#boolean)
	- [Number](#number)
	- [Text](#text)
	- [Arrays](#arrays)
	- [Hashes](#hashes)
	- [DateTime](#datetime)
	- [Regular expressions](#regular-expressions)
		- [Regex](#regex)
		- [RegexMatch](#regexmatch)
- [Global Functions](#global-functions)
- [Global Modules](#global-modules)
	- [FileSystem](#filesystem)
	- [HTTP](#http)
	- [JSON](#json)
	- [Maths](#maths)
	- [Roo](#roo)

---

## <a name="generic-getters-methods"></a>Generic Getters and Methods

Everything in Roo is an object. It should come as no surprise therefore that there will be some common getters and methods available on all objects. A method is an invokable function on an object that takes zero or more parameters. They are represented by an identifier followed by the required parameters enclosed in parentheses. A getter is a function that is invoked on an object that **takes no parameters** and does **not** expect trailing parentheses. This is an important distinction as suffixing a getter with parentheses will not work. You might wonder why there is a distinction between getters and methods. Well, principally it is for readability. Since there are so many functions that can be invoked on objects that do not require parameters, it seems wasteful to litter one's code with unecessary parentheses.

Below is a list of getters that every object in Roo has. This includes not only built-in data types such as `Nothing` and `Text` but even classes that you create yourself will inherit these:

- [nothing?](#generic-nothing)
- [number?](#generic-number)
- [to_text](#generic-to_text)
- [type](#generic-type)

Below is a list of the methods available on all objects:

- [responds_to?()](#generic-responds_to)

#### <a name="generic-nothing"></a>Object.nothing?

Returns `True` if this object is `Nothing` or `False` if it is any other kind of object.

```roo
var a
var b = 10

a.nothing? # True as un-initialised variables are set to Nothing
b.nothing? # False
```

#### <a name="generic-number"></a>Object.number?

Returns `True` if this object is a `Number` or `False` if it is any other kind of object.

```roo
var name = "Garry"
var age = 37

name.number? # False
age.number? # True
```

#### <a name="generic-responds_to"></a>Object.responds_to?(name as Text) as Boolean

Returns `True` if this object has a getter or method named `name` that you can invoke.

```roo
var who = "Hulk"
who.responds_to?("uppercase") # True
who.responds_to?("smash") # False
```

It even works for classes you create:

```roo
class Child:
	def cry:
		print("Waaaa!")

var c = Child()
c.responds_to?("cry") # True
c.responds_to?("crawl") # False
```

#### <a name="generic-to_text"></a>Object.to_text

How an object represents itself as text obviously differs depending on the object type. In all cases however a new `Text` object is returned.

##### Text objects

`Text` objects simply return their own value as a new `Text` object.

##### Boolean objects

Return either `"True"` or `"False"`. 

##### Number objects

Integer `Number` objects are returned as expected but doubles are formatted to a maximum of 30 decimal places without scientific notation. 

##### Nothing objects

Return `"Nothing"`. 

##### Regex objects

Return a `Text` object in the format: `"PATTERN (OPTIONS)"`. 

##### DateTime objects

These are returned in the SQL date format of `"YYYY-MM-DD HH:MM:SS"`.

##### Arrays

Returned flanked with `"[]"`. This is a recursive process. For example:

```roo
var a = [1, 2]
a.push!(["a", "b"])
a.to_text # [1, 2, ["a", "b"]]
```
##### Hashes

Returned flanked with `"{}"`. Like arrays, this is a recursive process. For example:

```roo
var h = {"name" => "Garry", True => "Boolean key", "a" => [1, 2]}
h.to_text # {True => "Boolean key", "a" => [1, 2], "name" => "Garry"}
```

Note that the order of keys in a `Hash` is not guaranteed.

##### Functions

These are returned in the format: `"<function FUNCTION_NAME>"`

##### Instances

By default, instances of custom classes are returned as `"<CLASS_NAME instance>"`. However, if you define a getter on your custom class named `to_text` then this will override the generic `to_text` getter. Additionally, this getter will be invoked if an instance of the custom class is passed to the global `print()` function. Make sure that if you do override this getter that it returns a `Text` object.

```roo
class Person:
	def init(name):
		self.name = name
	
	def to_text:
		return "Person named " + self.name

var p = Person("Garry")
p.to_text # Person named Garry
print(p) # Person named Garry
```

#### <a name="generic-type"></a>Object.type

Returns (as a new `Text` object) the type of this object.

```roo
var nowt
var name = "Hulk"
var age = 100

nowt.type # Nothing
name.type # Text
age.type # Number
```

---

## <a name="nothing"></a>Nothing

`Nothing` is a special object in Roo that represents, well, nothing. It's equivalent to `nil` or `null` in other languages. If you create a variable without an initialiser then it will default to having a value of `Nothing`.

```roo
var i # Defaults to Nothing
```

The `Nothing` object has just one getter (in addition to the generic ones):

- [to_number](#nothing-to_number)

#### <a name="nothing-to_number"></a>Nothing.to_number

Returns `0`.

---

## <a name="boolean"></a>The Boolean Data Type

The `Boolean` data type has two possible values: `True` or `False`. A Boolean can be created using a literal expression like so:

```roo
var a = True
var b = False
```

As Roo is a case-sensitive language, remember that `True` is **not** the same as `true` and `False <> false`.

---

## <a name="number"></a>Numbers

Numbers are represented by Roo internally as double precision numbers. Number literals can be prefixed with `0x` for hexadecimals, `0b` for binary numbers or `0o` for octal numbers. Below are a few examples of valid numbers:

```roo
10
42.5
2e4 # 2000
2.3e3 # 2300
3e-3 # 0.003
0xff # 255
0b1001 # 9
0o123 # 83
```

The `Number` object getters are:

- [abs](#number-abs)
- [acos](#number-acos)
- [asin](#number-asin)
- [atan](#number-atan)
- [ceil](#number-ceil)
- [cos](#number-cos)
- [digits](#number-digits)
- [even?](#number-even)
- [floor](#number-floor)
- [integer?](#number-integer)
- [odd?](#number-odd)
- [round](#number-round)
- [sign](#number-sign)
- [sin](#number-sin)
- [sqrt](#number-sqrt)
- [tan](#number-tan)
- [to_degrees](#number-to_degrees)
- [to_radians](#number-to_radians)

The `Number` object methods are:

- [each_digit()](#number-each_digit)
- [ends_with?()](#number-ends_with)
- [starts_with?()](#number-starts_with)

#### <a name="number-abs"></a>Number.abs

Returns a new `Number` object with the [absolute value](https://en.wikipedia.org/wiki/Absolute_value) of this number. 

```roo
var i = -20
i.abs # 20
100.abs # 100
```

#### <a name="number-acos"></a>Number.acos

Returns a new `Number` object with the arc cosine of this number in radians.

```roo
0.5.acos # 1.047198
```

#### <a name="number-asin"></a>Number.asin

Returns a new `Number` object with the arc sine of this number in radians.

```roo
0.5.asin # 0.5235988
```

#### <a name="number-atan"></a>Number.atan

Returns a new `Number` object with the arc tangent of this number in radians.

```roo
0.5.atan # 0.4636476
```

#### <a name="number-ceil"></a>Number.ceil

Returns a new `Number` object whose value is this number's value rounded up to the nearest whole number.

```roo
10.7.ceil # 11
```

#### <a name="number-cos"></a>Number.cos

Returns a new `Number` object with the cosine of this number in radians.

```roo
50.cos # 0.964966
```

#### <a name="number-digits"></a>Number.digits

Return an array where each element is a `Number` object representing a digit of this number. Decimal points are ignored but the digits following the decimal point are included.

```roo
1234.digits # [1, 2, 3, 4]
0.digits # [0]
42.5.digits # [4, 2, 5]
```

Roo only supports this getter on numbers where the integer part and the fractional part (if present) are less than 30 digits in length.

#### <a name="number-each_digit"></a>Number.each_digit(function, [args]?) as Number

Invokes the passed `function` for each digit of this number, passing to `function` the digit as the first argument. The elements of the optional `args` array will be passed to `function` as additional arguments. The number of arguments required by `function` must match the number of arguments being passed to it by `each_digit()` or else a runtime error will occur. In other words, if `[args]` is omitted then `function` should expect one parameter, otherwise it should expect `args.length + 1`.

```roo
def listDigits(digit):
	print(digit)

def prefixDigits(digit, prefix):
	print(prefix + digit)

123.each_digit(listDigits)
# Prints:
# 1
# 2
# 3

123.each_digit(prefixDigits, ["=>"])
# Prints:
# =>1
# =>2
# =>3
```

#### <a name="number-ends_with"></a>Number.ends_with?(digits) as Boolean

Returns `True` if this number ends with the queried digits. `digits` may be passed either as `Text`, a `Number` or an array of digits. The maximum number of integer or fractional part digits supported is 30.

```roo
100.ends_with?(0) # True
101.ends_with?("01") # True
42.5.ends_with?([2, 5]) # True
12.ends_with?(3) # False
```

#### <a name="number-even"></a>Number.even?

Returns `True` if this number is even, `False` if not.

```roo
2.even? # True
3.even? # False
```

#### <a name="number-floor"></a>Number.floor

Returns a new `Number` object whose value is this number's value rounded down to the nearest whole number.

```roo
1.4.floor # 1
```

#### <a name="number-integer"></a>Number.integer?

Returns `True` if this number is an integer, `False` if it's a double.

```roo
5.integer?
45.78.integer? # False
```

#### <a name="number-odd"></a>Number.odd?

Returns `True` if this number is odd, `False` if it's even.

```roo
2.odd? # False
3.odd? # True
```

#### <a name="number-round"></a>Number.round

Returns a new `Number` object whose value is this number's value rounded to the nearest whole number.

```roo
1.4.round # 1
4.9.round # 5
```

#### <a name="number-sign"></a>Number.sign

Returns `-1` if this number is negative, `1` if it's positive and `0` if it's zero.

```roo
-10.sign # -1
0.sign # 0
42.34.sign # 1
```

#### <a name="number-sin"></a>Number.sin

Returns a new `Number` object with the sine of this number in radians.

```roo
50.sin # -0.2623749
```

#### <a name="number-sqrt"></a>Number.sqrt

Returns a new `Number` object with the square root of this number.

```roo
9.sqrt # 3
```

#### <a name="number-starts_with"></a>Number.starts_with?(digits) as Boolean

Returns `True` if this number starts with the queried digits. `digits` may be passed either as `Text`, a `Number` or an array of digits. The maximum number of integer or fractional part digits supported is 30.

```roo
123.starts_with?(1) # True
123.starts_with?("1") # True
123.starts_with?([1, "2"]) # True
123.starts_with?(5) # False
```

#### <a name="number-tan"></a>Number.tan

Returns a new `Number` object with the tangent of this number in radians.

```roo
50.tan # -0.2719006
```

#### <a name="number-to_degrees"></a>Number.to_degrees

Returns a new `Number` object by assuming this number's value is in radians and converting it to degrees. The formula is: `result = value*(180/π)`.

```roo
2.to_degrees # 114.5916
```

#### <a name="number-to_radians"></a>Number.to_radians

Returns a new `Number` object by assuming this number's value is in degrees and converting it to radians. The formula is: `result = value/(180/π)`.

```roo
2.to_radians # 0.0349066
```
---

## <a name="text"></a>Text

Text in Roo is a sequence of UTF-8 encoded characters. Other languages might refer to `Text` objects as `Strings`. A `Text` object is typically created with the literal syntax by enclosing characters either in matching double or single quotes:

```roo
var hero = 'Tony the tiger'
var catchphrase = "They're great!"
# Note: Flank with double quotes to include a single quote in the text or
# flank with single quotes to include a double quote in the text.
```

Text literals can span multiple lines:

```roo
var lorem = "Lorem ipsum dolor sit amet,
consectetur adipiscing elit. Phasellus id
tempus tellus."
```

Multiple `Text` objects can be concatenated with the `+` operator:

```roo
"Hello " + 'World!' # "Hello World!"
```

Concatenation even works with objects that aren't `Text` objects since Roo provides a text representation for every object:

```roo
var age = 37
print("You are " + age) # "You are 37"
```

The `Text` object getters are:

- [capitalise](#text-capitalise)
- [capitalise!](#text-capitalise_)
- [chars](#text-chars)
- [define_utf8](#text-define_utf8)
- [define_utf8!](#text-define_utf8_)
- [empty?](#text-empty)
- [length](#text-length)
- [lowercase](#text-lowercase)
- [lowercase!](#text-lowercase_)
- [lstrip](#text-lstrip)
- [lstrip!](#text-lstrip_)
- [reverse](#text-reverse)
- [reverse!](#text-reverse_)
- [rstrip](#text-rstrip)
- [rstrip!](#text-rstrip_)
- [strip](#text-strip)
- [strip!](#text-strip_)
- [swapcase](#text-swapcase)
- [swapcase!](#text-swapcase_)
- [to_date](#text-to_date)
- [to_number](#text-to_number)
- [uppercase](#text-uppercase)
- [uppercase!](#text-uppercase_)

The `Text` object methods are:

- [each_char()](#text-each_char)
- [ends_with?()](#text-ends_with)
- [first_match(pattern)](#text-first_match)
- [first_match(pattern, start)](#text-first_match-what-start)
- [lpad()](#text-lpad)
- [lpad!()](#text-lpad_)
- [include?()](#text-include)
- [index()](#text-index)
- [match(pattern)](#text-match)
- [match(pattern, start)](#text-match-start)
- [matches?()](#text-matches)
- [replace_all()](#text-replace_all)
- [replace_all!()](#text-replace_all_)
- [replace_first()](#text-replace_first)
- [replace_first!()](#text-replace_first_)
- [rpad()](#text-rpad)
- [rpad!()](#text-rpad_)
- [slice(pos)](#text-slice)
- [slice!(pos)](#text-slice_)
- [slice(start, length)](#text-slice-start-length)
- [slice!(start, length)](#text-slice-start-length_)
- [starts_with?()](#text-starts_with)

#### <a name="text-capitalise"></a>Text.capitalise as Text

Returns a new `Text` object where the first letter of each word is capitalised. The original text is unchanged.

```roo
"hello world".capitalise # "Hello World!"
```

#### <a name="text-capitalise_"></a>Text.capitalise! as Text

Returns a new `Text` object where the first letter of each word is capitalised. The first letter of each word of the original text is also capitalised.

```roo
var a = "hello world"
var b = a.capitalise!
print(a) # "Hello World"
print(b) # "Hello World"
```

#### <a name="text-chars"></a>Text.chars as [Text]

Converts this `Text` object's value to its constituent characters and returns them as a new array.

```roo
"Die Hard".chars # ["D", "i", "e", " ", "H", "a", "r", "d"]
```

#### <a name="text-define_utf8"></a>Text.define_utf8 as Text or Nothing

Returns a new `Text` object whose value is defined as being UTF-8 encoded. The original value is unaltered.
If Roo is unable to define the encoding as UTF-8 then it returns `Nothing`.

#### <a name="text-define_utf8_"></a>Text.define_utf8! as Text or Nothing

Returns a new `Text` object whose value is defined as being UTF-8 encoded. The value of _this_ `Number` object is also changed.
If Roo is unable to define the encoding as UTF-8 then it returns `Nothing`.

#### <a name="text-each_char"></a>Text.each_char(function, [args]?) as [Object]

 Invokes the passed `function` for each character of this `Text` object, passing to `function` the character as the first argument. The elements of the optional `args` array will be passed to `function` as additional arguments. The number of arguments required by `function` must match the number of arguments being passed to it by `each_char()` or else a runtime error will occur. In other words, if `[args]` is omitted then `function` should expect one parameter, otherwise it should expect `args.length + 1`.
 
```roo
def random_case(char):
	# Randomly changes the case of a character.
	var r = Maths.random_int(0, 1)
	if r == 0:
		return char.lowercase
	else:
		return char.uppercase

def prefix_char(char, prefix):
	# Prefixes the passed character with the specified prefix.
	return prefix + char

var result = "jumble".each_char(random_case)
print(result) # ["j", "U", "M", "b", "L", "e"] or similar

var prefixed = "boo".each_char(prefix_char, ["*"])
print(prefixed) # ["*b", "*o", "*o"]
```


#### <a name="text-empty"></a>Text.empty? as Boolean

Returns `True` if this `Text` object is empty (`""`), `False` otherwise.

```roo
"Hi".empty? # False
"".empty? # True
```

#### <a name="text-ends_with"></a>Text.ends_with?(what as Text or []) as Boolean

Takes either a `Text` object or an array and returns `True` if this `Text` object's value ends with either the specified `Text` value or any of the elements of the passed array's elements.

```roo
"Hello".ends_with?("lo") # True
"Bob snr".ends_with?(["esq", "jnr", "snr"]) # True
```

#### <a name="text-first_match"></a>Text.first_match(pattern as Regex) as RegexMatch or Nothing

Runs the passed `Regex` object's search pattern against this `Text` object. The search begins at the start of the text. If there are no matches to the pattern then `Nothing` is returned. Otherwise, a single `RegexMatch` object is returned, representing the first match to the pattern.

```roo
var r = Regex("hello")
"Hello world!".first_match(r) # Matches and returns a single RegexMatch object.
"Hiya".first_match(r) # Nothing
```

#### <a name="text-first_match-what-start"></a>Text.first_match(pattern as Regex, start as Number) as RegexMatch or Nothing

Runs the passed `Regex` object's search pattern against this `Text` object. The search begins at the specified (zero-based) index `start`. If at least one match to the pattern is found within this `Text` object then the method returns a single `RegexMatch` object representing the first match to the pattern, otherwise it returns `Nothing`.

```roo
var r = Regex("hello")
"Hello world!".first_match(r, 0) # Returns a single RegexMatch object.
"Hello world!".first_match(r, 4) # Nothing
```

#### <a name="text-include"></a>Text.include?(what as Text) as Boolean

Returns `True` if this `Text` object contains the passed `Text` anywhere within its value. Performs a _case-sensitive_ search.

```roo
"Jane, John, Jim".include?("Jim") # True
"do, re, mi".include?("fa") # False
```

#### <a name="text-index"></a>Text.index(what as Text) as Number or Nothing

Returns the position (zero-based index) in this `Text` object of the first character of the passed `what` `Text` object. If `what` is not found within this `Text` object then it returns `Nothing`.

```roo
var name = "Tony Stark"
name.index("T") # => 0
name.index("S") # => 5
name.index("p") # => Nothing
```

#### <a name="text-length"></a>Text.length as Number

Returns the number of characters in this `Text` object.

```roo
"Hello".length # 5
"".length # 0
```

#### <a name="text-lowercase"></a>Text.lowercase as Text

Returns a new `Text` object whose value has been converted to lowercase. The original `Text` object's value is unaltered.

```roo
"SHOUTING".lowercase # "shouting"
```

#### <a name="text-lowercase_"></a>Text.lowercase! as Text

Returns a new `Text` object whose value has been converted to lowercase. The original `Text` object's value is also converted to lowercase.

```roo
var a = "SHOUTING!"
var b = a.lowercase!
print(a) # "shouting!"
print(b) # "shouting!"
```

#### <a name="text-lpad"></a>Text.lpad(width as Number, padding? as Text) as Text

Returns a new `Text` object where the value has been _left_ padded to at least the specified width with whatever `padding` is. If `padding` is omitted then a single space (`" "`) is used. The original `Text` object's value is unaltered.

```roo
"Hello".lpad(10, "-") # "-----Hello"
```

#### <a name="text-lpad_"></a>Text.lpad!(width as Number, padding? as Text) as Text

Returns a new `Text` object where the value has been _left_ padded to at least the specified width with whatever `padding` is. If `padding` is omitted then a single space (`" "`) is used. The original `Text` object's value is also changed.

```roo
var a = "Hello"
var b = a.lpad!(10, "-")
print(a) # "-----Hello"
print(b) # "-----Hello"
```


#### <a name="text-lstrip"></a>Text.lstrip as Text

Returns a new `Text` object with the leading whitespace removed. The original text is unaltered. `lstrip` uses the list of unicode "whitespace" characters at [https://www.unicode.org/Public/UNIDATA/PropList.txt]().

```roo
"  Hello".lstrip # "Hello"
```

#### <a name="text-lstrip_"></a>Text.lstrip! as Text

Returns a new `Text` object with the leading whitespace removed. The original `Text` object's value is also changed. `lstrip` uses the list of unicode "whitespace" characters at [https://www.unicode.org/Public/UNIDATA/PropList.txt]().

```roo
var a = "   Hello"
var b = a.lstrip!
print(a) # "Hello"
print(b) # "Hello"
```

#### <a name="text-match"></a>Text.match(pattern as Regex) as [RegexMatch] or Nothing

Runs the passed `Regex` object's search pattern against this `Text` object. The search begins at the start of the text. If there are no matches to the pattern then `Nothing` is returned. Otherwise, an array of `RegexMatch` objects is returned.

```roo
var r = Regex("hello")
"Hello world!".match(r) # Matches and returns an array containing a single RegexMatch object.
"Hiya".match(r) # Nothing
```

#### <a name="text-match-start"></a>Text.match(pattern as Regex, start as Number) as [RegexMatch] or Nothing

Runs the passed `Regex` object's search pattern against this `Text` object. The search begins at the specified (zero-based) index. If at least one match to the pattern is found within this `Text` object then the method returns an array of `RegexMatch` objects, otherwise it returns `Nothing`.

```roo
var r = Regex("hello")
"Hello world!".match(r, 0) # [RegexMatch] array
"Hello world!".match(r, 4) # Nothing
```


#### <a name="text-matches"></a>Text.matches?(pattern as Regex) as Boolean

Returns `True` if this `Text` object's value contains at least one match against the passed regular expression object. Returns `False` otherwise.

```roo
var r = Regex("hello")
"Hello world!".matches?(r) # => True
"Hiya".matches?(r) # => False
```

#### <a name="text-replace_all"></a>Text.replace_all(what as Text, replacement as Text) as Text

Returns a new `Text` object where every occurrence of `what` is replaced with `replacement`. The original `Text` object is unaltered.

```roo
"yummy yummy cake".replace_all("yummy", "scrummy") # "scrummy scrummy cake"
```

#### <a name="text-replace_all_"></a>Text.replace_all!(what as Text, replacement as Text) as Text

Returns a new `Text` object where every occurrence of `what` is replaced with `replacement`. The original `Text` object's value is also changed.

```roo
var a = "Go Go Gadget!"
var b = a.replace_all!("Go", "Yo")
print(a) # => "Yo Yo Gadget!"
print(b) # => "Yo Yo Gadget!"
```

#### <a name="text-replace_first"></a>Text.replace_first(what as Text, replacement as Text) as Text

Returns a new `Text` object where the first occurrence of `what` is replaced with `replacement`. The original `Text` object is unaltered.

```roo
"yummy yummy cake".replace_first("yummy", "scrummy") # "scrummy yummy cake"
```

#### <a name="text-replace_first_"></a>Text.replace_first!(what as Text, replacement as Text) as Text

Returns a new `Text` object where the first occurrence of `what` is replaced with `replacement`. The original `Text` object's value is also changed.

```roo
var a = "Go Go Gadget!"
var b = a.replace_first!("Go", "Yo")
print(a) # => "Yo Go Gadget!"
print(b) # => "Yo Go Gadget!"
```


#### <a name="text-reverse"></a>Text.reverse as Text

Returns a new `Text` object where the value has been reversed. The original object is unchanged.

```roo
"Forwards".reverse # "sdrawroF"
```

#### <a name="text-reverse_"></a>Text.reverse! as Text

Returns a new `Text` object where the value has been reversed. The original `Text` object's value is also reversed.

```roo
var a = "Forwards"
var b = a.reverse!
print(a) # "sdrawroF"
print(b) # "sdrawroF"
```

#### <a name="text-rpad"></a>Text.rpad(width as Number, padding? as Text) as Text

Returns a new `Text` object where the value has been _right_ padded to at least the specified width with whatever `padding` is. If `padding` is omitted then a single space (`" "`) is used. The original `Text` object's value is unaltered.

```roo
"Hello".rpad(10, "-") # "Hello-----"
```

#### <a name="text-rpad_"></a>Text.rpad!(width as Number, padding? as Text) as Text

Returns a new `Text` object where the value has been _right_ padded to at least the specified width with whatever `padding` is. If `padding` is omitted then a single space (`" "`) is used. The original `Text` object's value is also changed.

```roo
var a = "Hello"
var b = a.rpad!(10, "-")
print(a) # "Hello-----"
print(b) # "Hello-----"
```


#### <a name="text-rstrip"></a>Text.rstrip as Text

Returns a new `Text` object with the trailing whitespace removed. The original text is unaltered. `rstrip` uses the list of unicode "whitespace" characters at [https://www.unicode.org/Public/UNIDATA/PropList.txt]().

```roo
"Hello   ".rstrip # "Hello"
```

#### <a name="text-rstrip_"></a>Text.rstrip! as Text

Returns a new `Text` object with the trailing whitespace removed. The original `Text` object's value is also changed. `rstrip` uses the list of unicode "whitespace" characters at [https://www.unicode.org/Public/UNIDATA/PropList.txt]().

```roo
var a = "Hello   "
var b = a.rstrip!
print(a) # "Hello"
print(b) # "Hello"
```

#### <a name="text-slice"></a>Text.slice(pos as Number) as Text or Nothing

Returns a new `Text` object containing the character at position `pos`. If `pos < 0` then we count backwards from the end of the text to find the character. 
Position is _zero-based_.
If `pos > length` of the text then we return `Nothing`.
The original `Text` object's value is unaltered.

```roo
"yes".slice(0) # => "y"
"yes".slice(1) # => "e"
"yes".slice(2) # => "s"
"yes".slice(3) # => Nothing
"yes".slice(-1) # => "s"
"yes".slice(-2) # => "e"
"yes".slice(-3) # => "y"
"yes".slice(-4) # => Nothing
```

#### <a name="text-slice_"></a>Text.slice!(pos as Number) as Text or Nothing

Returns a new `Text` object containing the character at position `pos`. If `pos < 0` then we count backwards from the end of the text to find the character. 
Position is _zero-based_.
If `pos > length` of the text then we return `Nothing`.
If `Nothing` is returned then the original `Text` object's value is unaltered, otherwise the original `Text` object's value is changed to the result.

```roo
var a = "yes"
var b = a.slice!(0)
print(a) # => "y"
print(b) # => "y"

a = "yes"
b = a.slice!(1)
print(a) # => "e"
print(b) # => "e"

a = "yes"
b = a.slice!(2)
print(a) # => "s"
print(b) # => "s"

a = "yes"
b = a.slice!(3)
print(a) # => "yes"
print(b); # => Nothing

a = "yes"
b = a.slice!(-1)
print(a) # => "s"
print(b) # => "s"

a = "yes"
b = a.slice!(-2)
print(a) # => "e"
print(b) # => "e"

a = "yes"
b = a.slice!(-3)
print(a) # => "y"
print(b) # => "y"

a = "yes"
b = a.slice!(-4)
print(a) # => "yes"
print(b) # => Nothing
```

#### <a name="text-slice-start-length"></a>Text.slice(start as Number, length as Number) as Text or Nothing

Returns a new `Text` object of length `length` starting from position `start`. Positions are _zero-based_. If `start < 0` then the method counts backwards from the end of the text to find the start character.
The original `Text` object's value is unaltered. 
Returns `Nothing` if `length <= 0`, an invalid `start` position has been passed or an empty string results from the slice.

```roo
"Hello World".slice(0, 1) # => "H"
"Hello World".slice(0, 3) # => "Hel"
"Hello World".slice(2, 6) # => "llo Wo"
"Hello World".slice(-3, 2) # => "rl"
"Hello World".slice(2, -5) # => Nothing (can't have a negative length)
```

#### <a name="text-slice-start-length_"></a>Text.slice!(start as Number, length as Number) as Text or Nothing

Returns a new `Text` object of length `length` starting from position `start`. Positions are _zero-based_. If `start < 0` then the method counts backwards from the end of the text to find the start character.
Returns `Nothing` if `length <= 0`, an invalid `start` position has been passed or an empty string results from the slice.
If `Nothing` is returned then the original `Text` object's value is unaltered, otherwise the original `Text` object's value is changed to the result.

```roo
var a = "Hello World"
var b = a.slice!(0, 1)
print(a)  # => "H"
print(b)  # => "H"

a = "Hello World"
b = a.slice!(0, 3)
print(a) # => "Hel"
print(b) # => "Hel"

a = "Hello World"
b = a.slice!(2, 6)
print(a) # => "llo Wo"
print(b) # => "llo Wo"

a = "Hello World"
b = a.slice!(-3, 2)
print(a) # => "rl"
print(b) # => "rl"

a = "Hello World"
b = a.slice!(2, -5);
print(a) # => "Hello World"
print(b) # => Nothing
```

#### <a name="text-starts_with"></a>Text.starts_with?(what as Text or []) as Boolean

Takes either a `Text` object or an array and returns `True` if this `Text` object's value starts with either the specified `Text` value or any of the elements of the passed array's elements.

```roo
"Hello".starts_with?("H") # True
var title = ["Dr", "Prof"]
"Dr Bob".starts_with?(title) # True
"Mr Stark".starts_with?(title) # False
```


#### <a name="text-strip"></a>Text.strip as Text

Returns a new `Text` object with the leading and trailing whitespace removed. The original text is unaltered. `strip` uses the list of unicode "whitespace" characters at [https://www.unicode.org/Public/UNIDATA/PropList.txt]().

```roo
"  Hello  ".strip # "Hello"
```

#### <a name="text-strip_"></a>Text.strip! as Text

Returns a new `Text` object with the leading and trailing whitespace removed. The original `Text` object's value is also changed. `strip` uses the list of unicode "whitespace" characters at [https://www.unicode.org/Public/UNIDATA/PropList.txt]().

```roo
var a = "  Hello  "
var b = a.strip!
print(a) # "Hello"
print(b) # "Hello"
```

#### <a name="text-swapcase"></a>Text.swapcase as Text

Returns a new `Text` object where the case of each character has been swapped. The original text is unaltered.

```roo
"Dr Garry Pettet".swapcase # "dR gARRY pETTET"
```

#### <a name="text-swapcase_"></a>Text.swapcase! as Text

Returns a new `Text` object where the case of each character has been swapped. The original `Text`z object's value is also changed.

```roo
var a = "Dr Garry Pettet"
var b = a.swapcase!
print(a) # "dR gARRY pETTET"
print(b) # "dR gARRY pETTET"
```

#### <a name="text-to_date"></a>Text.to_date as DateTime or Nothing

If this `Text` object is in one of the following two formats: `YYYY-MM-DD HH:MM` or `YYYY-MM-DD` then this getter returns a new `DateTime` object instantiated to that date and time. If this `Text` object is not in one of those formats or is an invalid date/time then `Nothing` is returned.

```roo
var t = "2017-12-25 23:00"
var d = t.to_date
d.day_name # Monday.
```

#### <a name="text-to_number"></a>Text.to_number as Number

Returns the numeric equivalent of this `Text` object, if one exists. If this `Text` object does not represent a valid number then the result is `0`. This getter is operating system dependent and can therefore produce different results on different operating systems. Hexadecimal, binary and octal numbers are recognised if they are prefixed with `0x`, `0b` or `0o` respectively. Apart from the prefixed exceptions for hex, binary and octal numbers, only contiguous numbers at the beginning of this `Text` object's value are considered. Subsequent alphanumeric characters are ignored.

```roo
"123".to_number # 123
"42.5".to_number # 42.5
"FF".to_number # 0
"0xFF".to_number # 255
"1001".to_number # 1001
"0b1001".to_number # 9
"3ab".to_number # 3
"0o123".to_number # 83
``` 

#### <a name="text-uppercase"></a>Text.uppercase as Text

Returns a new `Text` object whose value has been converted to uppercase. The original `Text` object's value is unaltered.

```roo
"whispering".uppercase # "WHISPERING"
```

#### <a name="text-uppercase_"></a>Text.uppercase! as Text

Returns a new `Text` object whose value has been converted to uppercase. The original `Text` object's value is also converted to uppercase.

```roo
var a = "whispering"
var b = a.uppercase!
print(a) # "WHISPERING"
print(b) # "WHISPERING"
```
---

## <a name="arrays"></a>Arrays

An array is an ordered generic collection of elements of any type (including custom classes).

Arrays are typically created with an array literal denoted by square brackets (`[]`) and individual elements are separated by commas:

```roo
[1, 2, "skip a few", 99, 100]
```

Arrays are mutable. Only single dimensional arrays are supported but arrays can be nested. They have a _zero-based_ index (i.e: the first element's index is 0):

```roo
var a = [] # Empty array.
var b = [1, 2, 3] # Creation of an array and assignment on same line.
b[1] = "Hello!" # [1, "Hello!", 3]
b[0] # 1

# Arrays of mixed types are supported.
var c = ["Female", 36, True]

# Arrays can contain other arrays.
var arr2 = [1, 2, ["a", "b"]]
```

All arrays have the following getters:

- [empty?](#array-empty)
- [length](#array-length)
- [pop!](#array-pop_)
- [reverse!](#array-reverse_)
- [shuffle!](#array-shuffle_)
- [unique](#array-unique)
- [unique!](#array-unique_)

All arrays have the following methods:

- [contains?()](#array-contains)
- [delete_at!()](#array-delete_at_)
- [each()](#array-each)
- [each_index()](#array-each_index)
- [fetch()](#array-fetch)
- [find()](#array-find)
- [first()](#array-first)
- [first(n)](#array-first-n)
- [first!()](#array-first_)
- [first!(n)](#array-first_-n)
- [insert!()](#array-insert_)
- [join()](#array-join)
- [join(separator)](#array-join-separator)
- [keep()](#array-keep)
- [keep!()](#array-keep_)
- [last()](#array-last)
- [last(n)](#array-last-n)
- [map()](#array-map)
- [map!()](#array-map_)
- [push!()](#array-push_)
- [reject()](#array-reject)
- [reject!()](#array-reject_)
- [shift!()](#array-shift_)
- [shift!(n)](#array-shift_-n)
- [slice(index)](#array-slice)
- [slice(start, length)](#array-slice-start-length)
- [slice!(index)](#array-slice_)
- [slice!(start, length)](#array-slice_-start-length)

#### <a name="array-contains"></a>Array.contains(what as Object) as Boolean

Searches the array for the passed object. Returns `True` if found, `False` if not. First the method looks to see if the exact object exists in the array (with a memory lookup). If it doesn't, the method then checks the values of `Boolean`, `Number` and `Text` objects to find a match.

```roo
var a = ["a", 10, True]
var bool = True
a.contains?("a") # True
a.contains?("A") # False
a.contains?(bool) # True
```

#### <a name="array-delete_at_"></a>Array.delete_at!(index as Number) as Object

Deletes (i.e. removes from this array) the object at the specified (zero-based) index. Returns the deleted object or `Nothing` if `index` is out of range.

```roo
var x = ["a", "b", "c", "d"]
var y = x.delete_at!(1)
print(x) # ["a", "c", "d"]
print(y) # "b"

y = x.delete_at!(1)
print(x) # ["a", "d"]
print(y) # "c"

y = x.delete_at!(10)
print(x) # ["a", "d"]
print(y) # Nothing
```

#### <a name="array-each"></a>Array.each(function, [args]?) as [Object]

Invokes `function` for each element of this array, passing to `function` the element as the first argument. The elements of the optional `args` array will be passed to `function` as additional arguments. The number of arguments required by `function` must match the number of arguments being passed to it by `each()` or else a runtime error will occur. In other words, if `[args]` is omitted then `function` should expect one parameter, otherwise it should expect `args.length + 1`.

```roo
def stars(e):
	print("*" + e + "*")

def prefix(e, what):
	print(what + e)

var a = ["a", "b", "c"]
a.each(stars)
# Prints:
# *a*
# *b*
# *c*

a.each(prefix, ["->"])
# Prints:
# ->a
# ->b
# ->c
```

#### <a name="array-each_index"></a>Array.each_index(function, [args]?) as [Object]

Invokes `function` for each index of this array, passing to `function` the index as the first argument. The elements of the optional `args` array will be passed to `function` as additional arguments. The number of arguments required by `function` must match the number of arguments being passed to it by `each_index()` or else a runtime error will occur. In other words, if `[args]` is omitted then `function` should expect one parameter, otherwise it should expect `args.length + 1`.

```roo
def squared(e):
	print("*" + e*e + "*")

def prefix(e, what):
	print(what + e)

var a = ["a", "b", "c", "d"]

a.each_index(squared)
# Prints:
# *0*
# *1*
# *4*
# *0*

a.each_index(prefix, ["->"])
# Prints:
# ->0
# ->1
# ->2
# ->3

# You can also pass standard library functions to each_index:
a.each_index(print)
# Prints:
# 0
# 1 
# 2
# 3
```

#### <a name="array-empty"></a>Array.empty? as Boolean

Returns `True` if this array has no elements. Returns `False` if it does.

```roo
var a = []
a.empty? # => True
a.push!("a")
a.empty? # => False
```

#### <a name="array-fetch"></a>Array.fetch(index as Number, default as Object) as Object

Returns the element at `index`. If `index` is negative then we count backwards from the end of the array. An index of `-1` is the end of the array. If `index` is out of range then we return `default`.

```roo
var a = ["cat", "dog", "cow"]
a.fetch(0, "nope") # "cat"
a.fetch(3, "nope") # "nope"
```

#### <a name="array-find"></a>Array.find(obj As Object) as Number or Nothing

Searches this array for the passed object `obj`. If found, it returns its index in the array. Returns `Nothing` if `obj` is not in the array. First the method looks to see if the exact object exists in the array (with a memory lookup). If it doesn't, the method then checks the values of `Boolean`, `Number` and `Text` objects to find a match.

```roo
var a = ["a", "b", "c", "d"]
a.find("b") # 1
a.find("e") # Nothing
```

#### <a name="array-first"></a>Array.first() as Object or Nothing

Returns the first element in this array. Since arrays are zero-based, this returns the object at index 0. If this is an empty array then `Nothing` is returned.

```roo
var a = []
a.first() # Nothing.

var b = ["x", "y", "z"]
b.first() # "x"
```

#### <a name="array-first_"></a>Array.first!() as Object or Nothing

Removes the first element from this array and returns it. Since arrays are zero-based, this removes and returns the object at index 0. If this is an empty array then `Nothing` is returned.

```roo
var x = ["a", "b", "c", "d"]
var y = x.first!()
print(x) # ["b", "c", "d"]
print(y) # "a"
```

#### <a name="array-first-n"></a>Array.first(n as Number) as [Object]

Returns the first `n` elements of this array as an array.
If this array is empty then this method returns an empty array. Returns the original array if `n > Array.length`.

```roo
var x = ["a", "b", "c", "d"]
x.first() # "a"
x.first(1) # ["a"]
x.first(2) # ["a", "b"]
x.first(3) # ["a", "b", "c"]
x.first(4) # ["a", "b", "c", "d"]
x.first(5) # ["a", "b", "c", "d"]
var y = []
y.first() # Nothing
y.first(1) # []
```

#### <a name="array-first_-n"></a>Array.first!(n as Number) as [Object]

Removes the first `n` elements from this array and returns them as an array.
If this array is empty then this method returns an empty array. Returns the original array if `n > Array.length`.

```roo
var x = ["a", "b", "c", "d"]
var y = x.first!()
print(x) # ["b", "c", "d"]
print(y) # "a"

x = ["a", "b", "c", "d"]
y = x.first!(1) # ["a"]
print(x) # ["b", "c", "d"]
print(y) # ["a"]

x = ["a", "b", "c", "d"]
y = x.first!(2)
print(x) # ["c", "d"]
print(y) # ["a", "b"]

x = ["a", "b", "c", "d"]
y = x.first!(3)
print(x) # ["d"]
print(y) # ["a", "b", "c"]

x = ["a", "b", "c", "d"]
y = x.first!(4)
print(x) # []
print(y) # ["a", "b", "c", "d"]

x = ["a", "b", "c", "d"]
y = x.first!(5)
print(x) # []
print(y) # ["a", "b", "c", "d"]
```

#### <a name="array-insert_"></a>Array.insert!(index as Number, obj as Object) as Array

Inserts `obj` into this array and returns the modified array. Negative indices count backwards from the end of the array. Therefore an index of `-1` will append the object to the end of the array. If the passed `index` is greater than the current size of the array then we fill the missing elements with `Nothing` objects.

```roo
[1, 2, 3].insert!(0, "a") # ["a", 1, 2, 3]
[1, 2, 3].insert!(3, "a") # [1, 2, 3, "a"]
[1, 2, 3].insert!(-1, "a") # [1, 2, 3, "a"]
[1, 2, 3].insert!(-2, "a") # [1, 2, "a", 3]
[1, 2, 3].insert!(-4, "a") # ["a", 1, 2, 3]
[1, 2, 3].insert!(5, "a") # [1, 2, 3, Nothing, Nothing, "a"]
```

#### <a name="array-join"></a>Array.join() as Text

Returns a new `Text` object created by converting each element of this array to its text representation and concatenating them.

```roo
var a = [1, 2, 3, ["x", "y"]]
a.join() # "123xy"
```

#### <a name="array-join-separator"></a>Array.join(separator as Text) as Text

Returns a new `text` object created by converting each element of this array to its text representation and concatenating them, separated by `separator`.

```roo
var a = [1, 2, 3, ["x", "y"]]
a.join("-") # "1-2-3-x-y"
```

#### <a name="array-keep"></a>Array.keep(function, [args]?) as [Object]

Invokes `function` for each element of this array, passing to `function` the element as the first argument. The elements of the optional `args` array will be passed to `function` as additional arguments. The number of arguments required by `function` must match the number of arguments being passed to it by `keep()` or else a runtime error will occur. In other words, if `[args]` is omitted then `function` should expect one parameter, otherwise it should expect `args.length + 1`. This method returns a new array comprised of the elements that cause `function` to return `True`. If `function` returns `False` then that particular element is not added to the new array. The original array is unaltered by this operation.

```roo
def ok?(e):
	# Keep any element less than 5.
	return e <= 5 ? True : False

var a = [2, 4, 6, 8, 10]
var b = a.keep(ok?)

print(a) # => [2, 4, 6, 8, 10]
print(b) # => [2, 4]
```

#### <a name="array-keep_"></a>Array.keep!(function, [args]?) as [Object]

Invokes `function` for each element of this array, passing to `function` the element as the first argument. The elements of the optional `args` array will be passed to `function` as additional arguments. The number of arguments required by `function` must match the number of arguments being passed to it by `keep()` or else a runtime error will occur. In other words, if `[args]` is omitted then `function` should expect one parameter, otherwise it should expect `args.length + 1`. This method returns a new array comprised of the elements that cause `function` to return `True`. If `function` returns `False` then that particular element is not added to the new array. This is a destructive operation and the original array will now contain the elements returned in the new array.

```roo
def ok?(e):
	# Keep any element less than 5.
	return e <= 5 ? True : False

var a = [2, 4, 6, 8, 10]
a.keep!(ok?)

print(a) # [2, 4]
```

#### <a name="array-last"></a>Array.last() as Object or Nothing

Returns the last element in this array. In other words, it returns the object at the highest index. If this is an empty array then `Nothing` is returned. It's similar to [`Array.pop!`](#array-pop_) except that this array is not modified by the operation.

```roo
var a = []
a.last() # Nothing.

var b = ["x", "y", "z"]
b.last() # "z"
```

#### <a name="array-last-n"></a>Array.last(n as Number) as [Object]

Returns the last `n` elements of this array as an array. Returns an empty array if this array is empty. Returns the original array if `n > Array.length`.

```roo
var x = ["a", "b", "c", "d"]
x.last(1) # ["d"]
x.last(2) # ["c", "d"]
x.last(3) # ["b", "c", "d"]
x.last(4) # ["a", "b", "c", "d"]
x.last(5) # ["a", "b", "c", "d"]
var y = []
y.last(1) # []
```


#### <a name="array-length"></a>Array.length as Number

Returns, as a new `Number` object, the number of elements in this array.


#### <a name="array-map"></a>Array.map(function, [args]?) as [Object]

Invokes `function` for each element of this array, passing to `function` the element as the first argument. The elements of the optional `args` array will be passed to `function` as additional arguments. The number of arguments required by `function` must match the number of arguments being passed to it by `map()` or else a runtime error will occur. In other words, if `[args]` is omitted then `function` should expect one parameter, otherwise it should expect `args.length + 1`. This method returns a new array comprised of whatever objects are returned by `function`. This array is unaltered by the operation.

```roo
def exclaim(e):
	return e.uppercase + "!"

def prefix(e, what):
	return what + e

var a = ["a", "b", "c", "d"]
var b = a.map(exclaim) # ["A!", "B!", "C!", "D!"]
var c = a.map(prefix, ["*"]) # ["*a", "*b", "*c", "*d"]

print(a) # ["a", "b", "c", "d"]
print(b) # ["A!", "B!", "C!", "D!"]
print(c) # ["*a", "*b", "*c", "*d"]
```

#### <a name="array-map_"></a>Array.map!(function, [args]?) as [Object]

Invokes `function` for each element of this array, passing to `function` the element as the first argument. The elements of the optional `args` array will be passed to `function` as additional arguments. The number of arguments required by `function` must match the number of arguments being passed to it by `map!()` or else a runtime error will occur. In other words, if `[args]` is omitted then `function` should expect one parameter, otherwise it should expect `args.length + 1`. This method returns a new array comprised of whatever objects are returned by `function`. This is a destructive operation and the original array will now contain the elements returned in the new array.

```roo
def exclaim(e): 
	return e.uppercase + "!"

var a = ["a", "b", "c", "d"]
var b = a.map!(exclaim)

print(a) # => ["A!", "B!", "C!", "D!"]
print(b) # => ["A!", "B!", "C!", "D!"]
```

#### <a name="array-pop_"></a>Array.pop! as Object or Nothing

Pops the last element off of this array and returns it. In other words, it removes the object at the highest index from this array and returns it. If this is an empty array then `Nothing` is returned. It's similar to [`Array.last`](#array-last) except that this array is changed by the operation.


#### <a name="array-push_"></a>Array.push!(obj as Object) as [Object]

Appends the passed object `obj` to this array. Returns the amended array afterwards.

```roo
var a = ["a", "b", "c"]
a.push!("d") # ["a", "b", "c", "d"]
```

#### <a name="array-reject"></a>Array.reject(function, [args]?) as [Object]

Invokes `function` for each element of this array, passing to `function` the element as the first argument. The elements of the optional `args` array will be passed to `function` as additional arguments. The number of arguments required by `function` must match the number of arguments being passed to it by `reject()` or else a runtime error will occur. In other words, if `[args]` is omitted then `function` should expect one parameter, otherwise it should expect `args.length + 1`. This method returns a new array comprised of the elements that cause `function` to return `False`. If `function` returns `True` then that particular element is not added to the new array. The original array is unaltered by this operation. In effect, this method is the opposite of the [`Array.keep()`](#array-keep) method.

```roo
def too_big?(i):
	# Reject any elements bigger than 5.
	return i > 5 ? True : False

var a = [2, 4, 6, 8, 10]
var b = a.reject(too_big?)
print(a) # => [2, 4, 6, 8, 10]
print(b) # => [2, 4]
```

#### <a name="array-reject_"></a>Array.reject!(function, [args]?) as [Object]

Invokes `function` for each element of this array, passing to `function` the element as the first argument. The elements of the optional `args` array will be passed to `function` as additional arguments. The number of arguments required by `function` must match the number of arguments being passed to it by `reject!()` or else a runtime error will occur. In other words, if `[args]` is omitted then `function` should expect one parameter, otherwise it should expect `args.length + 1`. This method returns a new array comprised of the elements that cause `function` to return `False`. If `function` returns `True` then that particular element is not added to the new array. This is a destructive operation and the original array will now contain the elements returned in the new array.

```roo
def too_big?(i):
	# Reject any elements bigger than 5
	return i > 5 ? True : False

var a = [2, 4, 6, 8, 10]
var b = a.reject!(too_big?)
print(a) # => [2, 4]
print(b) # => [2, 4]
```

#### <a name="array-reverse_"></a>Array.reverse! as [Object]

Reverses the order of this array's elements and returns this array.

```roo
var a = ["a", "b", "c"]
a.reverse! # ["c", "b", "a"]
```

#### <a name="array-shift_"></a>Array.shift!() as Object or Nothing

Removes the first element from this array and then returns the removed element (thereby shifting all other elements down by one). If this is an empty array then `Nothing` is returned.

```roo
var args = ["-m", "-q", "filename"]
args.shift!() # returns "-m"
print(args) # ["-q", "filename"]
```

#### <a name="array-shift_-n"></a>Array.shift!(n as Number) as [Object]

Creates a new array from the first `n` elements of this array. `n` must be >= 0 or else a runtime error will occur. If `n == 0` then all elements are removed from this array and transferred to the newly returned array.

```roo
var args = ["-m", "-q", "filename"]
args.shift!(2) # returns ["-m", "-q"]
print(args) # ["filename"]
```

#### <a name="array-slice"></a>Array.slice(index as Number) as Object or Nothing

Returns the element at the specified `index`. A negative `index` is permitted where `-1` is the last element. If the absolute value of `index` is greater than the number of elements in this array then `Nothing` is returned. The original array is not modified by this operation.

```roo
var a = ["a", "b", "c"]
a.slice(0) # "a"
a.slice(3) # Nothing
a.slice(-1) # "c"
```

#### <a name="array-slice_"></a>Array.slice!(index as Number) as Object or Nothing

Returns the element at the specified `index`. A negative `index` is permitted where `-1` is the last element. If the absolute value of `index` is greater than the number of elements in this array then `Nothing` is returned. If this method returns `Nothing` then the original array is not altered, otherwise this array is mutated.

```roo
var a = ["a", "b", "c"]
var b = a.slice!(0)
print(a) # ["b", "c"]
print(b) # "a"

var c = ["a", "b", "c"]
var d = c.slice!(3)
print(c) # ["a", "b", "c"]
print(d) # Nothing

var e = ["a", "b", "c"]
var f = e.slice!(-1)

print(e) # ["a", "b"]
print(f) # "c"
```

#### <a name="array-slice-start-length"></a>Array.slice(start as Number, length as Number) as [Object] or Nothing

Returns a new array formed from the elements of this array beginning at index `start`, for `length` elements. If `start` is negative, we count backwards from the end of the array (`-1` is the last element). `length` should be positive or else we return `Nothing`. Returns a new array formed from the elements `start` to `length`. If the absolute value of `start` is greater than the number of elements in this array then we return `Nothing`. The original array is not modified by this operation.

```roo
var a = ["a", "b", "c"]
a.slice(0, 0) # Returns []
a.slice(0, 1) # Returns ["a"]
a.slice(0, 5) # Returns ["a", "b", "c"]
a.slice(-1, 1) # Returns ["c"]
a.slice(-1, -1) # Returns Nothing
```

#### <a name="array-slice_-start-length"></a>Array.slice!(start as Number, length as Number) as [Object] or Nothing

Returns a new array formed from the elements of this array beginning at index `start`, for `length` elements. If `start` is negative, we count backwards from the end of the array (`-1` is the last element). `length` should be positive or else we return `Nothing`. Returns a new array formed from the elements `start` to `length`. If the absolute value of `start` is greater than the number of elements in this array then we return `Nothing`. If this method returns `Nothing` then the original array is not altered, otherwise this array is mutated.

```roo
var a = ["a", "b", "c"]
var b = a.slice!(0, 0)
print(a) # ["a", "b", "c"]
print(b) # []

var c = ["a", "b", "c"]
var d = c.slice!(0, 1)
print(c) # ["b", "c"]
print(d) # ["a"]

var e = ["a", "b", "c"]
var f = e.slice!(0, 5)
print(e) # []
print(f) # ["a", "b", "c"]

var g = ["a", "b", "c"]
var h = g.slice!(-1, 1)
print(g) # ["a", "b"]
print(h) # ["c"]

var i = ["a", "b", "c"]
var j = i.slice!(-1, -1)
print(i) # ["a", "b", "c"]
print(j) # Nothing
```

#### <a name="array-shuffle_"></a>Array.shuffle! as [Object]

Randomly rearranges the order of the elements within this array and returns this array. A [Fisher-Yates](http://en.wikipedia.org/wiki/Fisher–Yates_shuffle) shuffle is used.

```roo
var a = [1, 2, 3, 4, 5]
a.shuffle! # [1, 4, 5, 2, 3] (may differ)
```

#### <a name="array-unique"></a>Array.unique as [Object]

Returns a new array constructed by removing duplicate values in this array. This array is unaltered by the operation. `Text`, `Number`, `Boolean` and `Nothing` objects are considered identical if they have the same value. Other objects are only considered identical if they actually point to the same object in memory.

```roo
var a = ["a", "a", "b", "b", "c"]
a.unique # ["a", "b", "c"]
```

#### <a name="array-unique_"></a>Array.unique! as [Object]

Returns a new array constructed by removing duplicate values in this array. This array is also mutated. `Text`, `Number`, `Boolean` and `Nothing` objects are considered identical if they have the same value. Other objects are only considered identical if they actually point to the same object in memory.

```roo
var a = ["a", "a", "b", "b", "c"]
var b = a.unique!

print(a) # ["a", "b", "c"]
print(b) # ["a", "b", "c"]
```

---

## <a name="hashes"></a>Hashes

A `Hash` object is a generic collection of key-value pairs mapping keys to values. The keys and values can be of any data type including custom classes.

Hashes are typically created with a hash literal denoted by curly braces (`{}`) enclosing a comma-separated list of pairs, using `=>` as the delimiter between the key and the value.

```roo
var h1 = {"name" => "Tony Stark", "rich?" => True} # A Hash with two keys.
var h2 = {} # An empty Hash.
```

Accessing a value within a hash requires its key:

```roo
var person = {"name" => "Tony Stark", "rich?" => True}
person{"name"} # "Tony Stark"
```

Assigning a value to a key within a `Hash` is easy enough. If the `Hash` doesn't contain the specified key then it's created. The standard assignment operators are supported:

```roo
var h = {"a" => 10, "b" => 20}
h{"c"} = 100 # {"a" => 10, "b" => 20, "c" => 100}
h{"a"} += 50 # {"a" => 60, "b" => 20, "c" => 100}
```

The `Hash` object getters are:

- [clear!](#hash-clear_)
- [invert](#hash-invert)
- [invert!](#hash-invert_)
- [keys](#hash-keys)
- [length](#hash-length)
- [values](#hash-values)

The `Hash` object methods are:

- [delete!()](#hash-delete_)
- [each()](#hash-each)
- [each_key()](#hash-each_key)
- [each_value()](#hash-each_value)
- [fetch()](#hash-fetch)
- [has_key?()](#hash-has_key)
- [has_value?()](#hash-has_value)
- [keep()](#hash-keep)
- [keep!()](#hash-keep_)
- [merge(other)](#hash-merge)
- [merge(other, function)](#hash-merge-other-function)
- [merge!(other)](#hash-merge_)
- [merge!(other, function)](#hash-merge_-other-function)
- [reject()](#hash-reject)
- [reject!()](#hash-reject_)
- [value()](#hash-value)

#### <a name="hash-clear_"></a>Hash.clear! as Hash

Removes all key-value pairs in this `Hash` object and returns the empty `Hash`.

```roo
var h = {"name" => "Garry", "age" => 37}
h.clear! # {}
```

#### <a name="hash-delete_"></a>Hash.delete!(key as Object) as Object or Nothing

Deletes the key-value pair whose key matches `key`. If this `Hash` contains `key` then it is removed and its value is returned. If `key` does not exist in this `Hash` then the method returns `Nothing`.

```roo
var h = {"a" => 1, "b" => 2}
var i = h.delete!("a")
var j = h.delete!("oops")

print(i) # 1
print(j) # Nothing
print(h) # {"b" => 2}
```

#### <a name="hash-each"></a>Hash.each(function, [args]?) as Hash

Invokes `function` for each key-value pair of this `Hash`, passing to `function` the key as the first argument and the value as the second argument. The elements of the optional `args` array will be passed to `function` as additional arguments. The number of arguments required by `function` must match the number of arguments being passed to it by `each()` or else a runtime error will occur. In other words, if `[args]` is omitted then `function` should expect one parameter, otherwise it should expect `args.length + 2`. This `Hash` object is returned (unaltered) by the method.

```roo
def put(key, value):
	print(key + " is " + value)

def putPrefix(key, value, prefix):
	print(prefix + key + " is " + value)

var h = {"a" => 100, "b" => 200}
h.each(put)
# Prints:
# a is 100
# b is 200

h.each(putPrefix, ["* "])
# Prints:
# * a is 100
# * b is 200
```

#### <a name="hash-each_key"></a>Hash.each_key(function, [args]?) as Hash

Invokes `function` for each key of this `Hash`, passing to `function` the key as the first argument. The elements of the optional `args` array will be passed to `function` as additional arguments. The number of arguments required by `function` must match the number of arguments being passed to it by `each_key()` or else a runtime error will occur. In other words, if `[args]` is omitted then `function` should expect one parameter, otherwise it should expect `args.length + 1`. This `Hash` object is returned (unaltered) by the method.

```roo
def put(key):
	print("The key is " + key)
  
def putSuffix(key, suffix):
	print("The key is " + key + suffix)

var h = {"a" => 100, "b" => 200}
h.each_key(put)
# Prints:
# The key is a
# The key is b

h.each_key(putSuffix, [" silly!"])
# Prints:
# The key is a silly!
# The key is b silly!
```

#### <a name="hash-each_value"></a>Hash.each_value(function, [args]?) as Hash

Invokes `function` for each value of this `Hash`, passing to `function` the value as the first argument. The elements of the optional `args` array will be passed to `function` as additional arguments. The number of arguments required by `function` must match the number of arguments being passed to it by `each_value()` or else a runtime error will occur. In other words, if `[args]` is omitted then `function` should expect one parameter, otherwise it should expect `args.length + 1`. This `Hash` object is returned (unaltered) by the method.

```roo
def put(v):
	print("The value is " + v)

def putSuffix(v, suffix):
	print("The value is " + v + suffix)

var h = {"a" => 100, "b" => 200}
h.each_value(put)
# Prints:
# The value is 100
# The value is 200

h.each_value(putSuffix, [" silly!"])
# Prints:
# The value is 100 silly!
# The value is 200 silly!
```


#### <a name="hash-fetch"></a>Hash.fetch(key as Object, default as Object) as Object

Returns the value for the specified `key`. If there is no matching key in this `Hash` then returns the `default` object specified.

```roo
var grades = {"Ross" => "A", "Joey" => "D", "Chandler" => "B+"}
grades.fetch("Ross", "Not marked") # "A"
grades.fetch("Monica", "Not marked") # "Not marked"
```

#### <a name="hash-fetch_values"></a>Hash.fetch_values([keys]) as [Object]

Takes an array of keys and returns a new array containing the values of those keys. If a key is missing from this `Hash` then `Nothing` is returned as its value in the returned array.

```roo
var grades = {"Ross" => "A", "Joey" => "D", "Chandler" => "B+"}
grades.fetch_values(["Ross", "Chandler"]) # ["A", "B+"]

var people = ["Monica", "Joey"]
grades.fetch_values(people) # [Nothing, "D"]
```

#### <a name="hash-has_key"></a>Hash.has_key?(key as Object) as Boolean

Returns `True` if this `Hash` contains the specified `key`. Returns `False` otherwise.

```roo
var ages = {"Bob" => 30, "Liz" => 10}
ages.has_key?("Bob") # True
ages.has_key?("bob") # False (case-sensitive!)
```

#### <a name="hash-has_value"></a>Hash.has_value?(value as Object) as Boolean

Returns `True` if this `Hash` contains the specified value. Returns `False` otherwise.

```roo
var r = Regex("hello")
var h = {"a" => 10, "b" => 20, "c" => r}
h.has_value?(20) # True
h.has_value?(r) # True
```

#### <a name="hash-invert"></a>Hash.invert as Hash

Returns a new `Hash` object created using this `Hash` object's values as keys and keys as values. If a key with the same value already exists in the `Hash` then the last one encountered will be used, with earlier values being discarded. The original `Hash` object is unaltered by the operation.

```roo
var h = {"a" => 10, "b" => 20, "c" => 30}
var i = h.invert # {10 => "a", 20 => "b", 30 => "c"}
```

#### <a name="hash-invert_"></a>Hash.invert! as Hash

Returns a new `Hash` object created using this `Hash` object's values as keys and keys as values. If a key with the same value already exists in the `Hash` then the last one encountered will be used, with earlier values being discarded. The original `Hash` object keys and values are also inverted. Whilst a new `Hash` is returned, this original `Hash` is merely a shallow clone of the new `Hash`.

```roo
var h = {"a" => 10, "b" => 20, "c" => 30}
var i = h.invert!

print(i) # {10 => "a", 20 => "b", 30 => "c"}
print(h) # {10 => "a", 20 => "b", 30 => "c"}
```

#### <a name="hash-keep"></a>Hash.keep(function, [args]?) as 

Invokes `function` for each key-value pair of this `Hash`, passing to `function` the key as the first argument and the value as the second argument. The elements of the optional `args` array will be passed to `function` as additional arguments. The number of arguments required by `function` must match the number of arguments being passed to it by `keep()` or else a runtime error will occur. In other words, if `[args]` is omitted then `function` should expect one parameter, otherwise it should expect `args.length + 2`. This method returns a new `Hash` comprised of the key-value pairs that cause `function` to return `True`. If `function` returns `False` then that particular key-value pair is **not** added to the new `Hash`. This original `Hash` is unaltered by this operation. This method is essentially the opposite of [`Hash.reject()`](#hash-reject).

```roo
def even_key?(key, value):
	return key % 2 == 0 ? True : False

var h = {1 => "first", 2 => "second", 3 => "third"}
var result = h.keep(even_key?)
print(h) # {1 => "first", 2 => "second", 3 => "third"}
print(result) # {2 => "second"}
```

#### <a name="hash-keep_"></a>Hash.keep!(function, [args]?) as 

Invokes `function` for each key-value pair of this `Hash`, passing to `function` the key as the first argument and the value as the second argument. The elements of the optional `args` array will be passed to `function` as additional arguments. The number of arguments required by `function` must match the number of arguments being passed to it by `keep!()` or else a runtime error will occur. In other words, if `[args]` is omitted then `function` should expect one parameter, otherwise it should expect `args.length + 2`. This method returns a new `Hash` comprised of the key-value pairs that cause `function` to return `True`. If `function` returns `False` then that particular key-value pair is **not** added to the new `Hash`. The original `Hash` object mirror the newly returned `Hash` object's. Whilst a new `Hash` is returned, this original `Hash` is merely a shallow clone of the new `Hash`. This method is essentially the opposite of [`Hash.reject!()`](#hash-reject_).

```roo
def even_key?(key, value):
	return key % 2 == 0 ? True : False

var h = {1 => "first", 2 => "second", 3 => "third"}
var result = h.keep!(even_key?)

print(h) # {2 => "second"}
print(result) # {2 => "second"}
```

#### <a name="hash-keys"></a>Hash.keys as [Object]

Returns the keys of this `Hash` object as an array of objects.

```roo
var h = {"a" => 100, "b" => 200}
h.keys # ["a", "b"]
```

#### <a name="hash-length"></a>Hash.length as Number

Returns the number of key-value pairs in this `Hash` as a new `Number` object.

```roo
var h = {"a" => 100, "b" => 200}
h.length # 2
```

#### <a name="hash-merge"></a>Hash.merge(other as Hash) as Hash

Merges the passed `other` `Hash` with this one. The value for entries with duplicate keys will be that of `other` Hash. Returns the newly created `Hash`. Both `other` and this `Hash` are unaltered by this operation.

```roo
var h1 = {"a" => 100, "b" => 200}
var h2 = {"b" => 254, "c" => 300}
var h3 = h1.merge(h2)

print(h1) # {"a" => 100, "b" => 200}
print(h2) # {"b" => 254, "c" => 300}
print(h3) # {"a"=>100, "b"=>254, "c"=>300}
```

#### <a name="hash-merge_"></a>Hash.merge!(other as Hash) as Hash

Merges the passed `other` `Hash` with this one. The value for entries with duplicate keys will be that of `other` Hash. Returns the newly created `Hash`. This `Hash` is modified and becomes a shallow clone of the returned `Hash`. `other` is unaltered by the operation.

```roo
var h1 = {"a" => 100, "b" => 200}
var h2 = {"b" => 254, "c" => 300}
var h3 = h1.merge!(h2)

print(h1) # {"a"=>100, "b"=>254, "c"=>300}
print(h2) # {"b" => 254, "c" => 300};
print(h3) # {"a"=>100, "b"=>254, "c"=>300}
```

#### <a name="hash-merge-other-function"></a>Hash.merge(other as Hash, function) as Hash

Returns a new `Hash` formed by merging this `Hash` with the passed `other` `Hash`. The value for entries with duplicate keys will be determined by the return value of `function`. `function` must take 3 arguments as it is passed the following arguments (in this order): `key`, `currentValue`, `otherValue`. `key` is the current key, `currentValue` is the value of `key` in this `Hash` and `otherValue` is the value of `key` in `other`. Both `other` and this `Hash` are unaltered by this operation.

```roo
def custom_merge(key, old_val, other_val):
	# Return the difference between the two values when a
	# duplicate key is encountered.
	return other_val - old_val

var h1 = { "a" => 100, "b" => 200 }
var h2 = { "b" => 254, "c" => 300 }
var h3 = h1.merge(h2, custom_merge) # {"a"=>100, "b"=>54,  "c"=>300}
```

#### <a name="hash-merge_-other-function"></a>Hash.merge!(other as Hash, function) as Hash

Returns a new `Hash` formed by merging this `Hash` with the passed `other` `Hash`. The value for entries with duplicate keys will be determined by the return value of `function`. `function` must take 3 arguments as it is passed the following arguments (in this order): `key`, `currentValue`, `otherValue`. `key` is the current key, `currentValue` is the value of `key` in this `Hash` and `otherValue` is the value of `key` in `other`. This `Hash` is modified and becomes a shallow clone of the returned `Hash`. `other` is unaltered by the operation.

```roo
def custom_merge(key, old_val, other_val):
	# Return the difference between the two values when a
	# duplicate key is encountered.
	return other_val - old_val

var h1 = { "a" => 100, "b" => 200 }
var h2 = { "b" => 254, "c" => 300 }
var h3 = h1.merge!(h2, custom_merge)

print(h1) #  "a" => 100, "b" => 54, "c" => 300}
print(h2) # {"b" => 254, "c" => 300}
print(h3) # {"a" => 100, "b" => 54, "c" => 300}
```

#### <a name="hash-reject"></a>Hash.reject(function, [args]) as Hash

Invokes `function` for each key-value pair of this `Hash`, passing to `function` the key as the first argument and the value as the second argument. The elements of the optional `args` array will be passed to `function` as additional arguments. The number of arguments required by `function` must match the number of arguments being passed to it by `reject()` or else a runtime error will occur. In other words, if `[args]` is omitted then `function` should expect one parameter, otherwise it should expect `args.length + 2`. This method returns a new `Hash` comprised of the key-value pairs that cause `function` to return `False`. If `function` returns `True` then that particular key-value pair is **not** added to the new `Hash`. This original `Hash` is unaltered by this operation. This method is essentially the opposite of [`Hash.keep()`](#hash-keep).

```roo
def even_key?(key, value):
	return key % 2 == 0 ? True : False

var h = {1 => "first", 2 => "second", 3 => "third"}
var result = h.reject(even_key?)
print(h) # {1 => "first", 2 => "second", 3 => "third"}
print(result) # {1 => "first", 3 => "third"} <-- rejected key-value pairs.
```

#### <a name="hash-reject_"></a>Hash.reject!(function, [args]?) as Hash

Invokes `function` for each key-value pair of this `Hash`, passing to `function` the key as the first argument and the value as the second argument. The elements of the optional `args` array will be passed to `function` as additional arguments. The number of arguments required by `function` must match the number of arguments being passed to it by `reject!()` or else a runtime error will occur. In other words, if `[args]` is omitted then `function` should expect one parameter, otherwise it should expect `args.length + 2`. This method returns a new `Hash` comprised of the key-value pairs that cause `function` to return `False`. If `function` returns `True` then that particular key-value pair is **not** added to the new `Hash`. The original `Hash` object mirror the newly returned `Hash` object's. Whilst a new `Hash` is returned, this original `Hash` is merely a shallow clone of the new `Hash`. This method is essentially the opposite of [`Hash.keep!()`](#hash-keep_).

```roo
def even_key?(key, value):
	return key % 2 == 0 ? True : False

var h = {1 => "first", 2 => "second", 3 => "third"}
var result = h.reject!(even_key?)

print(h) # {1 => "first", 3 => "third"}
print(result) # {1 => "first", 3 => "third"}
```

#### <a name="hash-value"></a>Hash.value(key as Object) as Object or Nothing

Returns the value for the specified `key`. If this `Hash` has no matching `key` then `Nothing` is returned.

```roo
var h = {"a" => 1, "b" => 2}
var i = h.value("a")
var j = h.value("c")

print(i) # 1
print(j) # Nothing
```

#### <a name="hash-values"></a>Hash.values as [Object]

Returns the values of this `Hash` as an array of objects.

```roo
var h = {"a" => 100, "b" => 200}
h.values # [100, 200]
```

---

## <a name="datetime"></a>Datetime

Roo provides a convenient data type for working with dates and times, the `DateTime` object. To create a new instance, use one of the the `DateTime()` constructors:

```roo
var now = DateTime() # This moment in time.
var xmas_2017 = DateTime(1514194200) # From Unix time.
var ymd = DateTime(2018, 01, 31) # From year/month/date.
var bttf = DateTime(1955, 11, 5, 8, 0, 0) # From year/month/date/hour/min/sec
```

`DateTime` objects cannot be added or subtracted from one another. To manipulate the value of a `DateTime` object, use one of the many methods detailed below.

The `DateTime` object getters are:

- [day_name](#datetime-day_name)
- [friday?](#datetime-friday)
- [hour](#datetime-hour)
- [leap?](#datetime-leap)
- [long_month](#datetime-long_month)
- [mday](#datetime-mday)
- [meridiem](#datetime-meridiem)
- [minute](#datetime-minute)
- [monday?](#datetime-monday)
- [month](#datetime-month)
- [nanosecond](#datetime-nanosecond)
- [saturday?](#datetime-saturday)
- [second](#datetime-second)
- [short_month](#datetime-short_month)
- [sunday?](#datetime-sunday)
- [thursday](#datetime-thursday)
- [time](#datetime-time)
- [to_http_header](#datetime-to_http_header)
- [today?](#datetime-today)
- [tomorrow?](#datetime-tomorrow)
- [tuesday?](#datetime-tuesday)
- [two_digit_hour](#datetime-two_digit_hour)
- [two_digit_minute](#datetime-two_digit_minute)
- [two_digit_second](#datetime-two_digit_second)
- [unix_time](#datetime-unix_time)
- [wday](#datetime-wday)
- [wednesday?](#datetime-wednesday)
- [yday](#datetime-yday)
- [year](#datetime-year)
- [yesterday?](#datetime-yesterday)

The `DateTime` object methods are:

- [add_days](#datetime-add_days)
- [add_hours](#datetime-add_hours)
- [add_months](#datetime-add_months)
- [add_nanoseconds](#datetime-add_nanoseconds)
- [add_seconds](#datetime-add_seconds)
- [add_years](#datetime-add_years)
- [sub_days](#datetime-sub_days)
- [sub_hours](#datetime-sub_hours)
- [sub_months](#datetime-sub_months)
- [sub_nanoseconds](#datetime-sub_nanoseconds)
- [sub_seconds](#datetime-sub_seconds)
- [sub_years](#datetime-sub_years)

#### <a name="datetime-add_days"></a>DateTime.add_days(d as Number) as DateTime

Creates and returns a new `DateTime` object by adding the specified number of days to this `DateTime` object. This `DateTime` object is unaltered by the operation. `d` must be an integer `Number` object. Negative integers are permitted.

```roo
var bttf = DateTime(499137600) # Oct 26th 1985 01:20:00 AM.
var d = bttf.add_days(7)
print(d) # Nov 2nd 1985 02:20:00 AM.
```

#### <a name="datetime-add_hours"></a>DateTime.add_hours(h as Number) as DateTime

Creates and returns a new `DateTime` object by adding the specified number of hours to this `DateTime` object. This `DateTime` object is unaltered by the operation. `h` must be an integer `Number` object. Negative integers are permitted.

```roo
var bttf = DateTime(499137600) # Oct 26th 1985 01:20:00 AM.
var d = bttf.add_hours(5)
print(d) # Oct 26th 1985 07:20:00 AM
```

#### <a name="datetime-add_months"></a>DateTime.add_months(m as Number) as DateTime

Creates and returns a new `DateTime` object by adding the specified number of months to this `DateTime` object. This `DateTime` object is unaltered by the operation. `m` must be an integer `Number` object. Negative integers are permitted.

```roo
var bttf = DateTime(499137600) # Oct 26th 1985 01:20:00 AM.
var d = bttf.add_months(2)
print(d) # Dec 26th 1985 01:20:00 AM
```

#### <a name="datetime-add_nanoseconds"></a>DateTime.add_nanoseconds(n as Number) as DateTime

Creates and returns a new `DateTime` object by adding the specified number of nanoseconds to this `DateTime` object. This `DateTime` object is unaltered by the operation. `n` must be an integer `Number` object. Negative integers are permitted.

```roo
var now = DateTime()
now.add_nanoseconds(25000)
```

#### <a name="datetime-add_seconds"></a>DateTime.add_seconds(s as Number) as DateTime

Creates and returns a new `DateTime` object by adding the specified number of seconds to this `DateTime` object. This `DateTime` object is unaltered by the operation. `s` must be an integer `Number` object. Negative integers are permitted.

```roo
var bttf = DateTime(499137600) # Oct 26th 1985 01:20:00 AM.
var d = bttf.add_seconds(135)
print(d) # Oct 26th 1985 01:22:15 AM
```

#### <a name="datetime-add_years"></a>DateTime.add_years(y as Number) as DateTime

Creates and returns a new `DateTime` object by adding the specified number of years to this `DateTime` object. This `DateTime` object is unaltered by the operation. `y` must be an integer `Number` object. Negative integers are permitted.

```roo
var bttf = DateTime(499137600) # Oct 26th 1985 01:20:00 AM.
var d = bttf.add_years(30)
print(d) # Oct 26th 2015 01:20:00 AM
```

#### <a name="datetime-day_name"></a>DateTime.day_name as Text

Returns the name of this `DateTime` object's day (e.g: "Monday") as a new `Text` object.

```roo
var now = DateTime()
print(now.day_name) # E.g: "Wednesday"
```

#### <a name="datetime-friday"></a>DateTime.friday? as Boolean

Returns `True` if this `DateTime` object is a Friday, `False` if not.

```roo
var xmas_2017 = DateTime(1514194200) # Mon Dec 25th 2017.
print(xmas_2017.friday?) # False.
```

#### <a name="datetime-hour"></a>DateTime.hour as Number

Returns the hour (1 - 24) of this `DateTime` object as an integer `Number` object.

```roo
var now = DateTime(1514194200)
print(now.hour) # 9
```

#### <a name="datetime-leap"></a>DateTime.leap? as Boolean

Returns `True` if this `DateTime` object is a Gregorian leap year, `False` if not.

```roo
var d1 = DateTime(2018, 1, 31) # Jan 31st 2018.
print(d1.leap?) # False.
var d2 = DateTime(2012, 5, 10) # May 10th 2012.
print(d2.leap?) # True.
```

#### <a name="datetime-long_month"></a>DateTime.long_month as Text

Returns the name of this `DateTime` object's month as a new `Text` object (e.g: "September").

```roo
var now = DateTime()
print(now.long_month) # E.g: February.
```

#### <a name="datetime-mday"></a>DateTime.mday as Number

Returns the day of the month (1 - 31) for this `DateTime` object.

```roo
var xmas_2017 = DateTime(1514194200) 
print(xmas_2017.mday) # 25
```

#### <a name="datetime-meridiem"></a>DateTime.meridiem as Text

Returns (as a new `Text` object) the meridiem of this `DateTime` object as two uppercase characters. Either `"AM"` or `"PM"`.


#### <a name="datetime-minute"></a>DateTime.minute as Number

Returns the minute (0 - 59) of this `DateTime` object as a new `Number` object.

```roo
var bttf = DateTime(499137600) # October 26th 1985 01:20 AM.
print(bttf.minute) # 20
```

#### <a name="datetime-monday"></a>DateTime.monday? as Boolean

Returns `True` if this `DateTime` object is a Monday, `False` if not.

```roo
var xmas_2017 = DateTime(1514194200) # Mon Dec 25th 2017.
print(xmas_2017.monday?) # True.
```

#### <a name="datetime-month"></a>DateTime.month as Number

Returns the month (1 - 12) of this `DateTime` object as a new `Number` object.

```roo
var xmas_2017 = DateTime(1514194200) # Mon Dec 25th 2017.
print(xmas_2017.month) # 12
```

#### <a name="datetime-nanosecond"></a>DateTime.nanosecond as Number

Returns the nanosecond for this `DateTime` object as a new `Number` object.

```roo
var now = DateTime()
print(now.nanosecond) # e.g: 867398977
```

#### <a name="datetime-saturday"></a>DateTime.saturday? as Boolean

Returns `True` if this `DateTime` object is a Saturday, `False` if not.

```roo
var xmas_2017 = DateTime(1514194200) # Mon Dec 25th 2017.
print(xmas_2017.saturday?) # False.
```

#### <a name="datetime-second"></a>DateTime.second as Number

Returns the seconds value (0 - 59) of this `DateTime` object as a new `Number` object.

```roo
var xmas_2017 = DateTime(1514194215) # Mon Dec 25th 2017 9:30:15 AM.
print(xmas_2017.second) # 15
```

#### <a name="datetime-short_month"></a>DateTime.short_month as Text

Returns the name of this `DateTime` object's month as a new `Text` object whose value is the capitalised English month name shortened to three characters (e.g: `"Jan"`).

```roo
var now = DateTime()
print(now.short_month) # E.g: "Feb".
```

#### <a name="datetime-sub_days"></a>DateTime.sub_days(d as Number) as DateTime

Creates and returns a new `DateTime` object by subtracting the specified number of days from this `DateTime` object. This `DateTime` object is unaltered by the operation. `d` must be an integer `Number` object. Negative integers are permitted.

```roo
var xmas = DateTime(2017, 12, 25, 9, 30, 15) # Dec 25th 2017 9:30:15 AM.
var d = xmas.sub_days(7)
print(d) # Dec 18th 2017 9:30:15 AM.
```

#### <a name="datetime-sub_hours"></a>DateTime.sub_hours(h as Number) as DateTime

Creates and returns a new `DateTime` object by subtracting the specified number of hours from this `DateTime` object. This `DateTime` object is unaltered by the operation. `h` must be an integer `Number` object. Negative integers are permitted.

```roo
var xmas = DateTime(2017, 12, 25, 9, 30, 15) # Dec 25th 2017 9:30:15 AM.
var d = xmas.sub_hours(12)
print(d) # Dec 24th 2017 9:30:15 PM.
```

#### <a name="datetime-sub_months"></a>DateTime.sub_months(m as Number) as DateTime

Creates and returns a new `DateTime` object by subtracting the specified number of months from this `DateTime` object. This `DateTime` object is unaltered by the operation. `m` must be an integer `Number` object. Negative integers are permitted.

```roo
var xmas = DateTime(2017, 12, 25, 9, 30, 15) # Dec 25th 2017 9:30:15 AM.
var d = xmas.sub_months(6)
print(d) # June 25th 2017 9:30:15 AM.
```

#### <a name="datetime-sub_nanoseconds"></a>DateTime.sub_nanoseconds(n as Number) as DateTime

Creates and returns a new `DateTime` object by subtracting the specified number of nanoseconds from this `DateTime` object. This `DateTime` object is unaltered by the operation. `n` must be an integer `Number` object. Negative integers are permitted.

```roo
var now = DateTime()
now.sub_nanoseconds(25000)
```

#### <a name="datetime-sub_seconds"></a>DateTime.sub_seconds(s as Number) as DateTime

Creates and returns a new `DateTime` object by subtracting the specified number of seconds from this `DateTime` object. This `DateTime` object is unaltered by the operation. `s` must be an integer `Number` object. Negative integers are permitted.

```roo
var xmas = DateTime(2017, 12, 25, 9, 30, 15) # Dec 25th 2017 9:30:15 AM.
var d = xmas.sub_seconds(20)
print(d) # Dec 25th 2017 9:29:55 AM.
```

#### <a name="datetime-sub_years"></a>DateTime.sub_years(y as Number) as DateTime

Creates and returns a new `DateTime` object by subtracting the specified number of years from this `DateTime` object. This `DateTime` object is unaltered by the operation. `y` must be an integer `Number` object. Negative integers are permitted.

```roo
var xmas = DateTime(2017, 12, 25, 9, 30, 15) # Dec 25th 2017 9:30:15 AM.
var d = xmas.sub_years(17)
print(d) # Dec 25th 2000 9:30:15 AM.
```

#### <a name="datetime-sunday"></a>DateTime.sunday? as Boolean

Returns `True` if this `DateTime` object is a Sunday, `False` if not.

```roo
var xmas_2017 = DateTime(1514194200) # Mon Dec 25th 2017.
print(xmas_2017.sunday?) # False.
```

#### <a name="datetime-thursday"></a>DateTime.thursday? as Boolean

Returns `True` if this `DateTime` object is a Thursday, `False` if not.

```roo
var xmas_2017 = DateTime(1514194200) # Mon Dec 25th 2017.
print(xmas_2017.thursday?) # False.
```

#### <a name="datetime-time"></a>DateTime.time as Text

Returns (in English human-readable form with meridian) this `DateTime` object's time. E.g: `"9:15 am"`  or  `"8:24 pm"`


#### <a name="datetime-to_http_header"></a>DateTime.to_http_header as Text

Returns this `DateTime` object as a new `Text` object whose value is formatted for use in HTTP headers.
The format is: <day-name>, <day> <month> <year> <hour>:<minute>:<second> GMT
As per: [https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/If-Modified-Since](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/If-Modified-Since)

```roo
var now = DateTime()
print(now.to_http_header) # Tuesday, 26 Feb 2019 12:08:46 GMT
```

#### <a name="datetime-today"></a>DateTime.today? as Boolean

Returns `True` if this `DateTime` object is anytime today, `False` if not.

```roo
var now = DateTime() # Instantiate to now.
print(now.today?) # True
var tomorrow = now.add_days(1)
print(tomorrow.today?) # False.
```

#### <a name="datetime-tomorrow"></a>DateTime.tomorrow? as Boolean

Returns `True` if this `DateTime` object represents tomorrow's date, `False` otherwise.

```roo
var now = DateTime()
print(now.tomorrow?) # False.
```

#### <a name="datetime-tuesday"></a>DateTime.tuesday? as Boolean

Returns `True` if this `DateTime` object is a Tuesday, `False` if not.

```roo
var xmas_2017 = DateTime(1514194200) # Mon Dec 25th 2017.
print(xmas_2017.tuesday?) # False.
```

#### <a name="datetime-two_digit_hour"></a>DateTime.two_digit_hour as Text

Returns (as a new `Text` object) the hour value of this `DateTime` object as two digits (e.g: `"08"`).


#### <a name="datetime-two_digit_minute"></a>DateTime.two_digit_minute as Text

Returns (as a new `Text` object) the minute value of this `DateTime` object as two digits (e.g: `"15"`).


#### <a name="datetime-two_digit_second"></a>DateTime.two_digit_second as Text

Returns (as a new `Text` object) the second value of this `DateTime` object as two digits (e.g: `"02"`).

#### <a name="datetime-unix_time"></a>DateTime.unix_time as Number

Returns the Unix time representation of this `DateTime` object as a new `Number` object. This is the number of seconds that have elapsed since 00:00:00 UTC on Thursday 1st Jan 1970.

```roo
var now = DateTime() # This moment in time.
print(now.unix_time) # e.g: 1551184113
```

#### <a name="datetime-wday"></a>DateTime.wday as Number

Returns the day of the week (1 = Sunday, 7 = Saturday) as a new `Number` object for this `DateTime` object.

```roo
var xmas_2017 = DateTime(1514194200) 
print(xmas_2017.wday) # 2
```

#### <a name="datetime-wednesday"></a>DateTime.wednesday? as Boolean

Returns `True` if this `DateTime` object is a Wednesday, `False` if not.

```roo
var xmas_2017 = DateTime(1514194200) # Mon Dec 25th 2017.
print(xmas_2017.wednesday?) # False.
```

#### <a name="datetime-yday"></a>DateTime.yday as Number

Returns the day of the year (Jan 1st = 1) as a new `Number` object for this `DateTime` object.

```roo
var xmas_2017 = DateTime(1514194200)
print(xmas_2017.yday) # 359
```

#### <a name="datetime-year"></a>DateTime.year as Number

Returns the year of this `DateTime` object as a new `Number` object.

```roo
var xmas_2017 = DateTime(1514194200) # Mon Dec 25th 2017.
print(xmas_2017.year) # 2017
```

#### <a name="datetime-yesterday"></a>DateTime.yesterday? as Boolean

Returns `True` if this `DateTime` object represents yesterday's date, `False` otherwise.

```roo
var xmas_2017 = DateTime(1514194215) # Mon Dec 25th 2017 9:30:15 AM.
print(xmas_2017.yesterday?) # False. 

var y = DateTime().sub_days(1)
print(y.yesterday?) # True.
```

---

## <a name="regular-expressions"></a>Regular Expressions

Regular expressions are represented by the `Regex` class. This section will not explain how to write regular expression (regex) patterns as that is outside this document's scope. I will say that for dynamically testing an expression in a browser, [https://regex101.com](https://regex101.com) is excellent. In short, a regex is a sequence of characters that defines a search pattern. This pattern can then be applied to text to find characters, words and phrases of interest. The Roo interpreter uses [PCRE](https://pcre.org/pcre.txt) syntax.

A `Regex` object is created with the `Regex()` constructor. This constructor always takes as its first parameter the pattern (in PCRE syntax) as a Text object or Text literal. Optionally, you can specify a number of _options_ by way of a second `Text` argument. These options modify the matching behaviour of the regular expression. If you don't pass a second argument to the `Regex` constructor then the default values are used:

- `c`: Case sensitive matching. Letters in the pattern must be of the same case to match. Default is `False`
- `d`: Normally the period matches everything except a new line. This option allows it to match new lines. Default is `False`
- `g`: Greedy means that the search finds everything from the beginning of the first delimiter to the end of the last delimiter and everything in-between. Default is `True`
- `e`: Indicates whether patterns are allowed to match an empty string. The default is `True`
- `m`: Multiline matching. `^` and `$` match new lines within the data. The default is `True`   

```roo
var r1 = Regex("\d+") # Matches any number of digits.
var r2 = Regex("foo|bar") # Matches "foo" or "bar".
var r3 = Regex("hello", "cd") # Case sensitive and the period matches new lines.
```

To see if some text matches a pattern we can use either the `match()` method on a `Text` object (by passing in our `Regex` object) or by using the `match()` method on a `Regex` object (by passing in the text to search). Both approaches will return either an array of `RegexMatch` objects if at least one match is found or `Nothing` if no match is found:

```roo
var r = Regex("\w+\.\w+@\w+\.com")
"pepper.potts@stark.com".match(r) # [RegexMatch]
r.match("pepper.potts@stark.com") # [RegexMatch]
"hello there".match(r) # Nothing.
```

If you just want to see if a pattern matches some text, you can use the `matches?()` method on either a `Regex` object or a `Text` object:

```roo
"hello".matches?(Regex(".lo")) # => True
Regex(".lo").matches?("boo") # => False
```

### Handling regular expression results
An array of `RegexMatch` objects is returned when the query text matches the regex search pattern. Each `RegexMatch` object represents a single match to the pattern. There are a number of ways to get these matches:

```roo
var r = Regex("love|hate") # Matches either `love` or `hate`
var result = "Sally loves Harry. Batman hates the Joker".match(r)
result.length # 2 matches: 'love' and 'hate'.
var match1 = result[0] # Can also use result.first_match
var match2 = result[1] # Second match has a value of `1` because arrays are zero-based
```

Following on from the above example, a `RegexMatch` object contains everything you need to know about an individual match. The `RegexMatch` object contains the (zero-based) start position of the match within the original query text, the length of the match, the actual text value of the match and information about any _capture groups_:

```roo
# Following on from the love/hate matches above...
match1.value # => "love"
match1.start # => 6
match1.length # => 4

match2.value # => "hate"
match2.start # => 26
match2.length # => 4
```

### Capture groups
One of the great strengths of regular expressions is the ability to capture portions of matched text. This is done with capture groups. Any regex contained within parentheses is a capture group. Getting any capture groups from a `RegexMatch` object is easy, just use the `RegexMatch.groups` getter. This returns an array where each element is a `Hash` with the following keys: `length`, `start` and `value`.

```roo
var r = Regex("(\w+)\.(\w+)@(\w+\.com)")
# Get the groups in the first match found.
var groups = "pepper.potts@stark.com".match(r).first().groups
print(groups)
# Prints:
# [
#	{
#		"length" => 6, "start" => 0, "value" => "pepper"
#	}, 
#	{
#		"length" => 5, "start" => 7, "value" => "potts"}, 
#	{
#		"length" => 9, "start" => 13, "value" => "stark.com"
#	}
# ]
```

You can get the contents of a specific capture group using it's group number. The first group **is numbered 1**. If a regex pattern contains capture groups then you can get information about the text captured in that group with the `RegexMatch.group()` method. This returns a `Hash` object with the following keys: `length`, `start` and `value`.

```roo
var result = "Dr McCoy".match(Regex("(\w+) (\w+)"))
var group1 = result.first().group(1)
group1{"value"} # "Dr"
group1{"start"} #  0
group1{"length"} # 2

var group2 = result.first().group(2)
group2{"value"} # "McCoy"
group2{"start"} # 3
group2{"length"} # 5
```

---

### <a name="regex"></a>The Regex object

As detailed in the generic [explanatory section](#regular-expressions) on regular expressions, the `Regex` object is used to represent a regular expression. This section will detail its getters, setters and methods.

The `Regex` object getters and setters are:

- [case_sensitive](#regex-case_sensitive)
- [dot_matches_all](#regex-dot_matches_all)
- [greedy](#regex-greedy)
- [match_empty](#regex-match_empty)
- [multiline](#regex-multiline)

The `Regex` object methods are:

- [first_match(what)](#regex-first_match)
- [first_match(what, start)](#regex-first_match-what-start)
- [match(what)](#regex-match)
- [match(what, start)](#regex-match-start)
- [matches?()](#regex-matches)

#### <a name="regex-case_sensitive"></a>Regex.case_sensitive as Boolean (get/set)

Gets or sets the value of this `Regex` object's `case_sensitive` option. Returns a `Boolean` and must be assigned a `Boolean` when set or else a runtime error will occur. If `True` then patterns will respect the case of text when performing a search. By default, this value is `False` for new `Regex` objects.

```roo
var r = Regex("\w+")
r.case_sensitive # False by default.
r.case_sensitive  = True
```

#### <a name="regex-dot_matches_all"></a>Regex.dot_matches_all as Boolean (get/set)

Gets or sets the value of this `Regex` object's `dot_matches_all` option. Returns a `Boolean` and must be assigned a `Boolean` when set or else a runtime error will occur. If `True` then patterns will match the newline character when matching `.`. By default, this value is `False` for new `Regex` objects.

```roo
var r = Regex("\w+")
r.dot_matches_all # False by default
r.dot_matches_all = True
```

#### <a name="regex-first_match"></a>Regex.first_match(what as Text) as RegexMatch or Nothing

Runs this `Regex` object's search pattern against the passed `Text` object `what`. The search begins at the start of `what`. If there are no matches to the pattern then `Nothing` is returned. Otherwise, a single `RegexMatch` object is returned, representing the first match to the pattern.

```roo
var r = Regex("hello")
r.first_match("Hello world!") # Matches and returns a single RegexMatch object.
r.first_match("Hiya") # Nothing
```

#### <a name="regex-first_match-what-start"></a>Regex.first_match(what as Text, start as Number) as RegexMatch or Nothing

Runs the passed `Regex` object's search pattern against the passed `Text` object `what`. The search of `what` begins at the specified (zero-based) index `start`. If at least one match to the pattern is found within this `Text` object then the method returns a single `RegexMatch` object representing the first match to the pattern, otherwise it returns `Nothing`.

```roo
var r = Regex("hello")
r.first_match("Hello world!", 0) # Returns a single RegexMatch object.
r.first_match("Hello world!", 4) # Nothing
```

#### <a name="regex-greedy"></a>Regex.greedy as Boolean (get/set)

Gets or sets the value of this `Regex` object's `greedy` option. Returns a `Boolean` and must be assigned a `Boolean` when set or else a runtime error will occur. If `True` then the pattern finds everything from the beginning of the first delimiter to the end of the last delimiter and everything in-between. By default, this value is `True` for new `Regex` objects.

```roo
var r = Regex("\w+")
r.greedy # True by default
r.greedy = False
```

#### <a name="regex-match"></a>Regex.match(what as Text) as [RegexMatch] or Nothing

Runs this `Regex` object's search pattern against the passed `Text` object `what`. The search begins at the start of `what`. If there are no matches to the pattern then `Nothing` is returned. Otherwise, an array of `RegexMatch` objects is returned, representing all matches to the pattern. This method is analagous to the [`Text.match(pattern)`](#text-match) method.

```roo
var r = Regex("love|hate") # Matches either `love` or `hate`
var result = "Sally loves Harry. Batman hates the Joker".match(r)
result.length # Array containing 2 matches: 'love' and 'hate'.
result[0].type # RegexMatch
```

#### <a name="regex-match-start"></a>Regex.match(what as Text, start as Number) as [RegexMatch] or Nothing

Runs this `Regex` object's search pattern against the passed `Text` object `what`. The search begins at the specified (zero-based) index `start`. If at least one match to the pattern is found within `what` then the method returns an array of `RegexMatch` objects, otherwise it returns `Nothing`. This method is analagous to the [`Text.match(pattern, start)`](#text-match-start)

```roo
var r = Regex("hello")
r.match("Hello world!", 0) # [RegexMatch] array
r.match("Hello world!", 4) # Nothing
```


#### <a name="regex-match_empty"></a>Regex.match_empty as Boolean (get/set)

Gets or sets the value of this `Regex` object's `match_empty` option. Returns a `Boolean` and must be assigned a `Boolean` when set or else a runtime error will occur. If `True` then patterns are allowed to match an empty string. By default, this value is `True` for new `Regex` objects.

```roo
var r = Regex("\w+")
r.match_empty # True by default
r.match_empty = False
```

#### <a name="regex-matches"></a>Regex.matches?(what as Text) as Boolean

Returns `True` if there is at least one match within `what` to this `Regex` object's search pattern. Returns `False` otherwise.

```roo
var r = Regex("Love", "c") # Case sensitive.
r.matches?("I love you") # False
```

#### <a name="regex-multiline"></a>Regex.multiline as Boolean (get/set)

Gets or sets the value of this `Regex` object's `multiline` option. Returns a `Boolean` and must be assigned a `Boolean` when set or else a runtime error will occur. If `True` then `^` and `$` match new lines within the data. By default, this value is `True` for new `Regex` objects.

```roo
var r = Regex("\w+")
r.multiline # True by default
r.multiline = False
```

---

### <a name="regexmatch"></a>RegexMatch

`RegexMatch` objects contain information about a single match to a pattern. An array of `RegexMatch` objects may be returned from the [`Text.match()`](#text-match) and [`Regex.match()`](#regex-match) methods and a single `RegexMatch` object may be returned by the [`Text.first_match()`](#text-first_match) and [`Regex.first_match()`](#regex-first_match) methods.

The `RegexMatch` object getters are:

- [regexmatch-groups](#regexmatch-groups)
- [regexmatch-length](#regexmatch-length)
- [regexmatch-start](#regexmatch-start)
- [regexmatch-value](#regexmatch-value)

The `RegexMatch` object methods are:

- [group()](#regexmatch-group)

#### <a name="regexmatch-group"></a>RegexMatch.group(groupNumber as Number) as Hash or Nothing

If there are capture groups within this match then this method returns the requested group. The first group encountered in a pattern is **1**. The group is returned as a `Hash` containing information about that capture group. Each `Hash` object is guaranteed to contain the following keys: `"length"`, `"start"` and `"value"`. `"start"` contains the zero-based character position that the match begins at. `"length"` contains the length in characters of the match and `"value"` contains the actual text value of the match.
If there are no capture groups within this match, or an invalid `groupNumber` is requested then this method returns `Nothing`. 
To retrieve information on all groups you can also use the [`RegexMatch.groups`](#regexmatch-groups) getter.


#### <a name="regexmatch-groups"></a>RegexMatch.groups as [Hash] or Nothing

If there are capture groups within this match then this getter returns an array where each element is a `Hash` containing information about that capture group. Each `Hash` object is guaranteed to contain the following keys: `"length"`, `"start"` and `"value"`. `"start"` contains the zero-based character position that the match begins at. `"length"` contains the length in characters of the match and `"value"` contains the actual text value of the match.
If there are no capture groups within this match, then this returns `Nothing`. 
To retrieve information on a particular group you can also use the [`RegexMatch.group()`](#regexmatch-group) method.

```roo
var r = Regex("(\w+) (\w+)")
var result = r.first_match("Dr McCoy")
var groups = result.groups
print(groups)
# Prints:
# [{"length" => 2, "start" => 0, "value" => "Dr"}, {"length" => 5, "start" => 3, "value" => "McCoy"}]
```

#### <a name="regexmatch-length"></a>RegexMatch.length as Number

The length (in characters) of this match.

#### <a name="regexmatch-start"></a>RegexMatch.start as Number

The zero-based index of the first character of this match within the original search text.

#### <a name="regexmatch-value"></a>RegexMatch.value as Text

The actual text of this match.

---

## <a name="global-functions"></a>Global Functions

Roo makes available a number of functions in the _global_ namespace. These functions are callable from anywhere within a script.

The available global functions are:

- [assert(condition)](#global-assert)
- [assert(condition, message)](#global-assert-message)
- [input_value()](#global-input_value)
- [input_value(prompt)](#global-input_value-prompt)
- [input()](#global-input)
- [input(prompt)](#global-input-prompt)
- [print()](#global-print)

#### <a name="global-assert"></a>assert(condition) as Boolean or RuntimeError

If the passed `condition` expression is truthy (i.e. evaluates to `True`) then this method returns `True`. If `condition` is falsey (i.e. evaluates to `False`) then a runtime error will be raised. Use this function if you want to gracefully end script termination if a required condition is not satisfied.

```roo
var ready = False
assert(ready) # Raises a runtime error with the message "Failed assertion."
```

#### <a name="global-assert-message"></a>assert(condition, message as Text) as Boolean or RuntimeError

Similar to `assert(condition)` above except this version takes a text `message` parameter to pass along with the runtime exception. If the passed `condition` expression is truthy (i.e. evaluates to `True`) then this method returns `True`. If `condition` is falsey (i.e. evaluates to `False`) then a runtime error will be raised. Use this function if you want to gracefully end script termination if a required condition is not satisfied.

```roo
var ready = False
assert(ready, "Not ready!") # Raises a runtime error with the message "Failed assertion. Not ready!"
```

#### <a name="global-input_value"></a>input_value() as Object

Used to get input from the user into the running script. The `input_value()` function differs from the global [`input()`](#global-input) function in that it will try to convert the string returned by the interpreter into the correct Roo runtime object. For example, if `"True"` is returned we will create a `Boolean` object, if `"0xFFFFFF"` is returned we will create a `Number` object, etc. The only values we allow are: `Text`, `Number`, `Boolean` and `Nothing` objects. We don't parse arrays and hashes.

```roo
var h = input_value()
# Assume user enters "0xff0000"
print(h) # 16711680
h # Number
```

#### <a name="global-input_value-prompt"></a>input_value(prompt as Text) as Object

Used to get input from the user into the running script. The `input_value(prompt)` function differs from the global [`input(prompt)`](#global-input-prompt) function in that it will try to convert the string returned by the interpreter into the correct Roo runtime object. For example, if `"True"` is returned we will create a `Boolean` object, if `"0xFFFFFF"` is returned we will create a `Number` object, etc. The only values we allow are: `Text`, `Number`, `Boolean` and `Nothing` objects. We don't parse arrays and hashes. The `prompt` is displayed to the user by the interpreter before requesting input.

```roo
var b = input_value("Enter True or False")
# Assume user enters "True". Remember that Booleans are case-sensitive.
print(b) # True
b.type # Boolean
```

#### <a name="global-input"></a>input() as Object

Used to get input from the user into the running script. Returns whatever the user enters as a `Text` object. This method is similar to the [`input_value()`](#global-input_value) method except it performs no parsing on the entered value.

```roo
var b = input()
# Assume user enters "True"
print(b) # True
b.type # Text
```

#### <a name="global-input-prompt"></a>input(prompt as Text) as Object

Used to get input from the user into the running script. Returns whatever the user enters as a `Text` object. This method is similar to the [`input_value(prompt)`](#global-input_value-prompt) method except it performs no parsing on the entered value. The `prompt` is displayed to the user by the interpreter before requesting input.

```roo
var b = input("Enter a value")
# Assume user enters "True"
print(b) # True
b.type # Text
```

#### <a name="global-print"></a>print(what as Object) as Object

Used to print the passed object to whatever output the interpreter has been configured to use. For the command line `roo` application, this is Stdout. Returns the argument to be printed (unaltered).

```roo
print("Hello world!")
```

---

## <a name="global-modules"></a>Global Modules

The Roo standard library contains a number of modules in the global namespace which are accessible from anywhere within a script. The modules segment Roo'` functionality based on purpose. Some modules contain classes as well as functions and getters (read-only properties).

The available modules in the standard library are:

- [FileSystem](#filesystem)
- [HTTP](#http)
- [JSON](#json)
- [Maths](#maths)
- [Roo](#roo)

---

## <a name="filesystem"></a>The FileSystem Module

The `FileSystem` module contains functions and classes for working with a system's file system.

Getters:

- [cwd](#filesystem-cwd)
- [cwd_path](#filesystem-cwd_path)

Functions:

- [copy()](#filesystem-copy)
- [delete()](#filesystem-delete)
- [mkdir()](#filesystem-mkdir)
- [move()](#filesystem-move)

Classes:

- [Item](#filesystem-item)

#### <a name="filesystem-copy"></a>Filesystem.copy(source, destination, overwrite) as Boolean

Copies the folder/file at `source` to `destination`. `source` and `destination` can be either a `Text` path or a `FileSystem.Item` object. Returns `True` if the copy succeeded, `False` if it failed. If `overwrite` is `False` then if the copy operation would result in the overwriting of a file, we abort the copy and return `False`. See [`FileSystem.item.copy_to()`](#filesystem-item-copy_to) for an alternative syntax with the same functionality.

```roo
var fileToCopy = FileSystem.Item("/Users/garry/Desktop/test1.txt")
var dest = FileSystem.Item("/Users/garry/Downloads")
var result = FileSystem.copy(fileToCopy, dest, True) # True

# Let's attempt to copy again but this time prevent overwriting.
result = FileSystem.copy(fileToCopy, dest, False) # False as file already exists.
```

#### <a name="filesystem-cwd"></a>FileSystem.cwd as FileSystem.Item or Nothing

Returns the current working directory (cwd) of the script as a `FileSystem.Item` object. If Roo is being run from the command line interpreter then this will return the folder containing the script that invoked this getter. If Roo is in REPL mode or Roo is interpreting direct input when embedded within a Xojo app then this getter will return `Nothing`.

```roo
var cwd = FileSystem.cwd
cwd.type # FileSystem.Item
```

#### <a name="filesystem-cwd_path"></a>FileSystem.cwd_path as Text or Nothing

Returns the current working directory (cwd) of the script as a `Text` object. If Roo is being run from the command line interpreter then this will return the folder containing the script that invoked this getter. If Roo is in REPL mode or Roo is interpreting direct input when embedded within a Xojo app then this getter will return `Nothing`.

```roo
var path = FileSystem.cwd_path # /Users/garry/Desktop
```

#### <a name="filesystem-delete"></a>Filesystem.delete(what as Text or FileSystem.Item) as Boolean

Deletes the file/folder specified by `what` and returns `True` if successful or `False` if the deletion failed. `what` can either be a `FileSystem.Item` object or a `Text` object specifying the path to a file/folder. See [`FileSystem.Item.delete!`](#filesystem-item-delete_) for an alternative syntax with the same functionality. You should also note that deleting a file/folder does **not** move it to the trash or recycling bin. It is removed immediately.

```roo
var what = FileSystem.Item("/Users/garry/Desktop/file1.txt")
FileSystem.delete(what) # True or False
```

#### <a name="filesystem-move"></a>FileSystem.move(source, destination, overwrite) as Boolean

Moves the specified `source` file or folder to the specified `destination`. `destination` must be a valid and existing **folder**. Returns `True` if successful or `False` if the move is not possible. See [`FileSystem.Item.move_to()`](#filesystem-item-move_to) for an alternative syntax with the same functionality.

```roo
var fileToMove = FileSystem.Item("/Users/garry/Desktop/file1.txt")
var dest = "/Users/garry/Downloads" # Note this is a Text path.
FileSystem.move(fileToMove, dest, True) # Permit overwriting.
```

#### <a name="filesystem-mkdir"></a>FileSystem.mkdir(path as Text) as Text or Nothing

Creates a new directory at the specified path. Returns the path to the newly created directory if successful. Returns `Nothing` if the directory could not be created. If `path` is invalid then a runtime error is raised.

```roo
FileSystem.mkdir("/Users/garry/Desktop/My Stuff")
```

---

### <a name="filesystem-item"></a>FileSystem.Item

The `FileSystem.Item` class provides access to the file system. An `Item` represents a file or folder on disk. To create a reference to a file or folder, use the `FileSystem.Item()` constructor:

```roo
var file = FileSystem.Item("/Users/garry/Downloads/test.txt")
var folder = FileSystem.Item("/Users/garry/Desktop")
```

The following properties are both getters and setters:

- [path](#filesystem-item-path)

The `FileSystem.Item` object getters are:

- [count](#filesystem-item-count)
- [delete!](#filesystem-item-delete_)
- [directory?](#filesystem-item-directory)
- [exists?](#filesystem-item-exists)
- [file?](#filesystem-item-file)
- [name](#filesystem-item-name)
- [read_all](#filesystem-item-read_all)
- [readable?](#filesystem-item-readable)
- [writeable?](#filesystem-item-writeable)

The `FileSystem.Item` object methods are:

- [append()](#filesystem-item-append)
- [append_line()](#filesystem-item-append_line)
- [copy_to()](#filesystem-item-copy_to)
- [each_char()](#filesystem-item-each_char)
- [each_line()](#filesystem-item-each_line)
- [move_to()](#filesystem-item-move_to)
- [write()](#filesystem-item-write)
- [write_line()](#filesystem-item-write_line)

#### <a name="filesystem-item-append"></a>FileSystem.Item.append(data as Text) as Number

Appends the passed text to this `Item` object's file. If a `Text` object is _not_ passed then Roo will convert the passed argument to its text representation. The method returns the number of bytes written to disk as a new `Number` object. If the method fails for any reason then `0` is returned.


#### <a name="filesystem-item-append_line"></a>FileSystem.Item.append_line(data as Text) as Number

Appends the passed text to this `Item` object's file. If a `Text` object is _not_ passed then Roo will convert the passed argument to its text representation. A new line character is appended to the file _after_ the passed `data` is appended. The method returns the number of bytes written to disk as a new `Number` object. If the method fails for any reason then `0` is returned.

#### <a name="filesystem-item-copy_to"></a>FileSystem.Item.copy_to(destination, overwrite) as Boolean

Copies the file/folder referenced by this `Item` object to `destination`. `destination` can be either a `Text` path or a `FileSystem.Item` object. Returns `True` if the copy succeeded, `False` if it failed. If `overwrite` is `False` then if the copy operation would result in the overwriting of a file, we abort the copy and return `False`. See [`FileSystem.copy()`](#filesystem-copy) for an alternative syntax with the same functionality.

```roo
var f = FileSystem.Item("/Users/garry/Desktop/test1.txt")
var dest = FileSystem.Item("/Users/garry/Downloads")
var result = f.copy_to(dest, True) # True

# Let's attempt to copy again but this time prevent overwriting.
result = f.copy_to(dest, False) # False as file already exists.
```

#### <a name="filesystem-item-count"></a>FileSystem.Item.count as Number

If this `Item` object references a folder then this getter returns the number of files/folder in its top-level. If this `Item` is a file or an empty folder then this getter returns `0`.

#### <a name="filesystem-item-delete_"></a>FileSystem.Item.delete! as Boolean

Deletes the file/folder referenced by this `Item` object from disk. Returns `True` if the deletion was successful, `False` if the deletion failed. NB: A return value of `False` does not necessarily represent an error. For instance, the file/folder referenced my not actually exist on disk in the first place. You should also note that deleting a file/folder does **not** move it to the trash or recycling bin. It is removed immediately.

```roo
var f = FileSystem.Item("/Users/garry/Desktop/test1.txt")
f.delete! # Returns True and test1.txt is gone forever.
```

#### <a name="filesystem-item-directory"></a>FileSystem.Item.directory? as Boolean

Returns `True` if this `Item` references a folder. Returns `False` if it references a file.


#### <a name="filesystem-item-file"></a>FileSystem.Item.file? as Boolean

Returns `True` if this `Item` references a file. Returns `False` if it references a folder.


#### <a name="filesystem-item-each_char"></a>FileSystem.Item.each_char(function, [args]?) as Number

Invokes the passed `function` for each character within this file, passing to `function` the character as the first argument. The elements of the optional `args` array will be passed to `function` as additional arguments. The number of arguments required by `function` must match the number of arguments being passed to it by `each_char()` or else a runtime error will occur. In other words, if `[args]` is omitted then `function` should expect one parameter, otherwise it should expect `args.length + 1`. The file referenced by this `Item` object **must** be UTF-8 encoded or bad things will likely happen. The method returns the total number of characters passed to `function`.

```roo
def listChar(char):
	print(char)

def prefixChar(char, what):
	print(what + char)

# Assume test.txt file contents is:
# Iron Man
# Hulk
# Thor

var f = FileSystem.Item("/Users/garry/Desktop/test.txt")
f.each_char(listChar)
# # Prints:
# I
# r
# o   etc

f.each_char(prefixChar, ["Char: "])
# # Prints:
# Char: I
# Char: r
# Char: o   etc
```

#### <a name="filesystem-item-each_line"></a>FileSystem.Item.each_line(function, [args]?) as Number

Invokes the passed `function` for each line within this file, passing to `function` the line as the first argument and the (zero-based) line number as the second argument. The elements of the optional `args` array will be passed to `function` as additional arguments. The number of arguments required by `function` must match the number of arguments being passed to it by `each_line()` or else a runtime error will occur. In other words, if `[args]` is omitted then `function` should expect two parameters, otherwise it should expect `args.length + 2`. The file referenced by this `Item` object **must** be UTF-8 encoded or bad things will likely happen. The method returns the total number of lines passed to `function`.

```roo
def itemise(line, number):
	print(number + ". " + line)

def suffix(line, number, what):
	print(line + what)

# Assume test.txt file contents are:
# Iron Man
# Hulk
# Thor

var f = FileSystem.Item("/Users/garry/Desktop/test.txt")
f.each_line(itemise)
# Prints:
# 0. Iron Man
# 1. Hulk
# 2. Thor

f.each_line(suffix, ["!"])
# Prints:
# Iron Man!
# Hulk!
# Thor!
```

#### <a name="filesystem-item-exists"></a>FileSystem.Item.exists? as Boolean

Returns `True` if this `Item` references a file or folder that actually exists on disk. Returns `False` if it does not.


#### <a name="filesystem-item-move_to"></a>FileSystem.Item.move_to(destination, overwrite) as Boolean

Moves the file/folder referenced by this `FileSystem.Item` object to the specified `destination`. `destination` must be a valid and existing **folder**. Returns `True` if successful or `False` if the move is not possible. See [`FileSystem.move()`](#filesystem-move) for an alternative syntax with the same functionality.

```roo
var f = FileSystem.Item("/Users/garry/Desktop/file1.txt")
var dest = "/Users/garry/Downloads" # Note this is a Text path.
f.move_to(dest, True) # Permit overwriting.
```

#### <a name="filesystem-item-name"></a>FileSystem.Item.name as Text (get/set)

Returns the name of the file or folder referenced by this `FileSystem.Item` object as a `Text` object. If this `Item` does not point to a valid file or folder then the getter returns `Nothing`. You can use the setter version to change the name of this file or folder too.

```roo
var f = FileSystem.Item("/Users/garry/Desktop/test1.txt")
print(f.name) # test1.txt

# Change the file's name.
f.name = "new name.txt"
print(f.name) # new name.txt
```

#### <a name="filesystem-item-path"></a>FileSystem.Item.path (get/set)

Returns the path to this file/folder on disk as a `Text` object. If this `Item` does not reference a valid file/folder then this getter returns `Nothing`. Can also be used to set the path of this `Item` (thereby changing the file/folder referenced by this object). It is possible to set this object to an invalid (i.e: non-existent) file/folder.

```roo
var f = FileSystem.Item("/Users/garry/Downloads")
# `f` now points to my Desktop folder.
f.path = "/Users/garry/Downloads" # Now it points to my Downloads folder.
print(f.path) # /Users/garry/Downloads
```

#### <a name="filesystem-item-readable"></a>FileSystem.Item.readable? as Boolean

Returns `True` if this `Item` points to a valid file/folder **and** it's readable by Roo.


#### <a name="filesystem-item-read_all"></a>FileSystem.Item.read_all as Text or Nothing

If this `Item` points to an invalid file or Roo cannot read the file then this getter returns `Nothing`. If this `Item` points to a folder then this getter also returns `Nothing`. Otherwise, the contents of the file is read and converted to a `Text` object. The interpreter will attempt to define the encoding of the file as UTF-8. If it cannot then `Nothing` is returned. The file is gracefully closed after reading.


#### <a name="filesystem-item-write"></a>FileSystem.Item.write(data as Text) as Number

Writes the passed text to this `Item` object's file. If a `Text` object is _not_ passed then Roo will convert the passed argument to its text representation. The method returns the number of bytes written to disk as a new `Number` object. If the method fails for any reason then `0` is returned. NB: If successful, this method will replace any previous contents in the file with `data`. If you just want to append data to an existing file then use the [`FileSystem.Item.append()`](#filesystem-item-append) method.


#### <a name="filesystem-item-write_line"></a>FileSystem.Item.write_line(data as Text) as Number

Writes the passed text to this `Item` object's file. If a `Text` object is _not_ passed then Roo will convert the passed argument to its text representation. A new line character is appended to the file _after_ the passed `data` is written. The method returns the number of bytes written to disk as a new `Number` object. If the method fails for any reason then `0` is returned. NB: If successful, this method will replace any previous contents in the file with `data`. If you just want to append a line of data to an existing file then use the [`FileSystem.Item.append_line()`](#filesystem-item-append_line) method.


#### <a name="filesystem-item-writeable"></a>FileSystem.Item.writeable? as Boolean

Returns `True` if this `Item` points to a valid file/folder **and** the Roo interpreter is able to write to it.

---

## <a name="http"></a>The HTTP Module

The HTTP module provides getters, functions and classes for making and receiving HTTP and HTTPS requests and responses.

Getters:

- [TIMEOUT](#http-timeout)

Functions:

- [delete()](#http-delete)
- [get()](#http-get)
- [post()](#http-post)
- [put()](#http-put)
- [url_decode()](#http-url_decode)
- [url_encode()](#http-url_encode)

Classes:

- [Request](#http-request)
- [Response](#http-response)

#### <a name="http-delete"></a>HTTP.delete(url as Text, timeout? as Integer) as HTTP.Response

Makes a HTTP/HTTPS DELETE request to the specified `url`. Takes an optional integer `timeout` parameter specifying the number of seconds to wait for a response. If `timeout` is omitted then `HTTP.TIMEOUT` seconds is used instead. Returns a `HTTP.Response` object, even if the request fails.

```roo
var r = HTTP.delete("http://httpbin.org/delete", 5)
```

#### <a name="http-get"></a>HTTP.get(url as Text, timeout? as Integer) as HTTP.Response

Makes a HTTP/HTTPS GET request to the specified `url`. Takes an optional integer `timeout` parameter specifying the number of seconds to wait for a response. If `timeout` is omitted then `HTTP.TIMEOUT` seconds is used instead. Returns a `HTTP.Response` object, even if the request fails.

```roo
var r = HTTP.get("https://garrypettet.com")
```

#### <a name="http-post"></a>HTTP.post(url as Text, content as Object, timeout? as Integer) as HTTP.Response

Makes a HTTP/HTTPS POST request to the specified `url`. The `content` parameter can be any Roo object - it will be converted to it's textual representation. For example, if it isn't already. Takes an optional integer `timeout` parameter specifying the number of seconds to wait for a response. If `timeout` is omitted then `HTTP.TIMEOUT` seconds is used instead. Returns a `HTTP.Response` object, even if the request fails.

```roo
# Create a Hash to hold some data.
var h = {"name" => "Garry", "age" => 37}

# Let's assume our POST endpoint needs JSON input. 
# Convert the Hash above to JSON.
var content = JSON.generate(h)

# POST the JSON content and get a Response object.
var r = HTTP.post("https://httpbin.org/post", content)
```

#### <a name="http-put"></a>HTTP.put(url as Text, content as Object, timeout? as Integer) as HTTP.Response

Makes a HTTP/HTTPS PUT request to the specified `url`. The `content` parameter can be any Roo object - it will be converted to it's textual representation. For example, if it isn't already. Takes an optional integer `timeout` parameter specifying the number of seconds to wait for a response. If `timeout` is omitted then `HTTP.TIMEOUT` seconds is used instead. Returns a `HTTP.Response` object, even if the request fails.

```roo
# Create a Hash to hold some data.
var h = {"name" => "Garry", "age" => 37}

# Let's assume our PUT endpoint needs JSON input. 
# Convert the Hash above to JSON.
var content = JSON.generate(h)

# PUT the JSON content and get a Response object.
var r = HTTP.put("http://httpbin.org/put", content)
```

#### <a name="http-timeout"></a>HTTP.TIMEOUT as Number

Returns the default request timeout (in seconds) that Roo will use for requests if a specific timeout interval is not provided.

#### <a name="http-url_decode"></a>HTTP.url_decode(what as Text) as Text

Takes a [URL encoded](https://en.wikipedia.org/wiki/Percent-encoding) `Text` object, decodes it and returns it as a new `Text` object.

```roo
HTTP.url_decode("Hello%20World%3F") # Hello World?
```

#### <a name="http-url_encode"></a>HTTP.url_encode(what as Text) as Text

The inverse of [`HTTP.url_decode()`](#http-url_decode). Takes a `Text` object, [URL encodes](https://en.wikipedia.org/wiki/Percent-encoding) it and returns it as a new `Text` object.

```roo
HTTP.url_encode("Hello World?") # Hello%20World%3F
```

---

### <a name="http-request"></a>HTTP.Request

The `HTTP.Request` class is used for creating HTTP or HTTPS requests. Simple requests can be made with the various `HTTP` module functions (such as [`HTTP.get()`](#http-get)) without the need to create your own `Request` object. More complex requests can be made by first creating a new `Request` object with its constructor:

```roo
var req = HTTP.Request() # New Request object.
```

The following `HTTP.Request` properties are both getters _and_ setters:

- [content](#http-request-content)
- [content_type](#http-request-content_type)
- [cookies](#http-request-cookies)
- [headers](#http-request-headers)
- [host](#http-request-host)
- [if_modified_since](#http-request-if_modified_since)
- [method](#http-request-method)
- [referer](#http-request-referer)
- [timeout](#http-request-timeout)
- [url](#http-request-url)
- [user_agent](#http-request-user_agent)

The `HTTP.Request` object has the following property which is a getter _only_:

- [send](#http-request-send)

#### <a name="http-request-content"></a>HTTP.Request.content as Text (get/set)

Gets or sets the content property of this `Request` object.


#### <a name="http-request-content_type"></a>HTTP.Request.content_type as Text (get/set)

Gets or sets the value of this request's `Content-Type` header.


#### <a name="http-request-cookies"></a>HTTP.Request.cookies as Hash (get/set)

Accepts and returns a `Hash` representing this `Request` object's cookies. Cookies will be sent to the server as key-value pairs in the format `name=value`, separated by semicolons (`;`). 


#### <a name="http-request-headers"></a>HTTP.Request.headers as Hash (get/set)

Accepts and returns a `Hash` representing this `Request` object's headers. 

```roo
var req = HTTP.Request()
req.headers = {"Referer" => "Mr Blobby", "Origin" => "https://garrypettet.com"}
```

#### <a name="http-request-host"></a>HTTP.Request.host as Text (get/set)

Gets or sets the value of this request's `Host` header.


#### <a name="http-request-if_modified_since"></a>HTTP.Request.if_modified_since as DateTime or Text (set) or Text (get)

Gets or sets the value of this request's `If-Modified-Since` header. The setter will accept either a `DateTime` object or any object with a textual representation. Servers typically expect dates and times to be in the format `<day-name>, <day> <month> <year> <hour>:<minute>:<second> GMT` (as per [https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/If-Modified-Since]()). If a `DateTime` object is used to set this property then Roo will automatically convert it to this format. The getter returns a `Text` object.


#### <a name="http-request-method"></a>HTTP.Request.method as Text (get/set)

Gets or sets the type of HTTP/HTTPS method this request will use. Valid values are: `"CONNECT"`, `"DELETE"`, `"GET"`, `"HEAD"`, `"OPTIONS"`, `"PATCH"`, `"POST"`, `"PUT"` and `"TRACE"`. The value passed to the setter is **not** case-sensitive.

```roo
var req = HTTP.Request()
req.method = "GET"
```

#### <a name="http-request-referer"></a>HTTP.Request.referer as Text (get/set)

Gets or sets the value of this request's `Referer` header.


#### <a name=""></a>HTTP.Request.send as HTTP.Response

Sends this request to the previously specified url (`self.url`) using the previously specified HTTP/HTTPS method (`self.method`).

```roo
# Create a simple request.
var req = HTTP.Request()
req.url = "https://garrypettet.com"
req.method = "GET"

# Send the request and get a response.
var response = req.send

# Display the HTML content.
print(response.content)
```

#### <a name="http-request-timeout"></a>HTTP.Request.timeout as Number (get/set)

Sets or retrieves the number of seconds that this request object will wait before it assumes the request has timed out. The getter expects a positive integer between 0 and 60. The default value for new `Request` objects is `HTTP.TIMEOUT` seconds.


#### <a name="http-request-url"></a>HTTP.Request.url as Text

The url that this `Request` object will use. When setting, you must include the protocol (e.g: `http://` or `https://` in front of the url).

```roo
var req = HTTP.Request()
req.url = "https://garrypettet.com"
```

#### <a name="http-request-user_agent"></a>HTTP.Request.user_agent as Text (get/set)

Gets or sets the value of this request's `User-Agent` header.

---

### <a name="http-response"></a>HTTP.Response

The `HTTP.Response` class represents a server's response to a HTTP/HTTPS request. `Response` objects are returned by various `HTTP` module functions (such as [`HTTP.get()`](#http-get) and [`HTTP.Request.send`](#http-request-send)). Whilst it is possible to create a new `Response` object with its constructor, `HTTP.Response()`, there probably is little reason to do so.

The `HTTP.Response` class has the following getters:

- [content](#http-response-content)
- [content_disposition](#http-response-content_disposition)
- [content_encoding](#http-response-content_encoding)
- [content_length](#http-response-content_length)
- [content_type](#http-response-content_type)
- [cookies](#http-response-cookies)
- [headers](#http-response-headers)
- [last_modified](#http-response-last_modified)
- [location](#http-response-location)
- [status](#http-response-status)

#### <a name="http-response-content"></a>HTTP.Response.content as Text

Returns the content of this response as a `Text` object.


#### <a name="http-response-content_disposition"></a>HTTP.Response.content_disposition as Text

Returns (as a `Text` object) the value of this response's `"Content-Disposition"` header.


#### <a name="http-response-content_encoding"></a>HTTP.Response.content_encoding as Text

Returns (as a `Text` object) the value of this response's `"Content-Encoding"` header.


#### <a name="http-response-content_length"></a>HTTP.Response.content_length as Text

Returns (as a `Text` object) the value of this response's `"Content-Length"` header.


#### <a name="http-response-content_type"></a>HTTP.Response.content_type as Text

Returns (as a `Text` object) the value of this response's `"Content-Type"` header.


#### <a name="http-response-cookies"></a>HTTP.Response.cookies as Hash

Returns this response's cookies as a `Hash`.


#### <a name="http-response-headers"></a>HTTP.Response.headers as Hash

Returns this response's headers as a `Hash`.


#### <a name="http-response-last_modified"></a>HTTP.Response.last_modified as Text

Returns (as a `Text` object) the value of this response's `"Last-Modified"` header.


#### <a name="http-response-location"></a>HTTP.Response.location as Text

Returns (as a `Text` object) the value of this response's `"Location"` header.


#### <a name="http-response-status"></a>HTTP.Response.status as Number

Returns (as a `Number` object) the status code returned by the server.


---

## <a name="json"></a>The JSON Module

The JSON module provides functions for working with JSON.

Functions:

- [generate](#json-generate)
- [parse](#json-parse)

#### <a name="json-generate"></a>JSON.generate(what as Hash) as Text or Nothing

Converts the passed `Hash` object (`what`) into a JSON `Text` object. If an error occurs then `Nothing` is returned.

```roo
# Create a Hash with various values.
var h = {"name" => "Bart", "age" => 10, "scores" => [50, 65, 30]}

# Convert this hash into valid JSON text.
JSON.generate(h) # {"age":10,"name":Bart,"scores":[50,65,30]}
```

#### <a name="json-parse"></a>JSON.parse(what as Text) as Array or Hash or Nothing

Parses the passed `Text` object containing JSON into a usable Roo object (either an `Array` or a `Hash` object) and returns it. If `what` is not valid JSON then returns `Nothing`.

```roo
JSON.parse("Not JSON") # Nothing
JSON.parse('["Tony", "Peter", "Steve"]') # Array
JSON.parse('{"id": 100, "title": "Hello world!"}') # Hash
```

---

## <a name="maths"></a>The Maths Module

The `Maths` module contains getters and functions for performing Maths-related operations. It is only a small module because many mathematical operations are performed on `Number` objects directly rather than through a surrogate `Maths` module.

Getters:

- [random](#maths-random)
- [PI](#maths-pi)

Functions:

- [random_int()](#maths-random_int)

#### <a name="maths-pi"></a>Maths.PI as Number

Returns the value of Pi (π) that the Roo interpreter is using internally as a new `Number` object.

```roo
Maths.PI # 3.141593
```

#### <a name="maths-random"></a>Maths.random as Number

Returns a new fractional `Number` object whose value is between `0` and `1` (inclusive).

```roo
# Create a random double value between 0 and 1 (inclusive).
var i = Maths.random # E.g: 0.4901
```

#### <a name="maths-random_int"></a>Maths.random_int(min as Number, max as Number) as Number

Returns a new integer `Number` object whose value is between `min` and `max` (inclusive). `min` and `max` must both be integers or else a runtime error will be raised.

```roo
# Create a random integer between 1 and 10 (inclusive).
var i = Maths.random_int(1, 10) # E.g: 8
```

---

## <a name="roo"></a>The Roo Module

The Roo module contains miscellaneous getters.

Getters:

- [clock](#roo-clock)
- [version](#roo-version)

#### <a name="roo-clock"></a>Roo.clock as Number

Returns (as a new `Number` object) the number of microseconds (1,000,000th of a second) that have passed since the user's computer was started. As modern operating systems can stay running for so long, it's possible for the machine's internal counters to "roll over." This means that if you are using this function to determine how much time has elapsed, you may encounter a case where this time is inaccurate. The machine's internal counters may or may not continue to advance while the machine is asleep, or in a similar power-saving mode. Therefore, this function might not be suitable for use as a long-term timer.

```roo
# Start a "timer".
var start = Roo.clock

# Do a loop.
var result = 0
for (var i = 0; i < 1000; i += 1):
	result += i

var end = Roo.clock
print("result = " + result + ". Calculation took " + (end - start) + " microseconds.")
```

#### <a name="roo-version"></a>Roo.version

Returns, as a new `Text` object, the current version of Roo. The format is MAJOR_VERSION.MINOR_VERSION.BUG_VERSION.

```roo
print(Roo.version) # 3.0.0
```
