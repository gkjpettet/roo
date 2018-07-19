#tag Class
Protected Class ArrayObjectMethod
Implements Roo.Invokable,Roo.Textable
	#tag Method, Flags = &h0
		Function Arity() As Variant
		  select case self.name
		  case "contains?"
		    return 1
		  case "delete_at!"
		    return 1
		  case "each"
		    return Array(1, 2)
		  case "each_index"
		    return Array(1, 2)
		  case "fetch"
		    return 2
		  case "find"
		    return 1
		  case "first", "first!"
		    return Array(0, 1)
		  case "insert!"
		    return 2
		  case "join"
		    return Array(0, 1)
		  case "keep", "keep!"
		    return Array(1, 2)
		  case "last"
		    return Array(0, 1)
		  case "map", "map!"
		    return Array(1, 2)
		  case "push"
		    return 1
		  case "reject", "reject!"
		    return Array(1, 2)
		  case "responds_to?"
		    return 1
		  case "shift!"
		    return Array(0, 1)
		  case "slice", "slice!"
		    return Array(1, 2)
		  case "take", "take!"
		    return 1
		  end select
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor(parent as ArrayObject, name as String)
		  self.parent = parent
		  self.name = name
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function DoContains(args() as Variant) As BooleanObject
		  ' Array.contains(obj as Object) as BooleanObject.
		  ' Searches the array for the passed object. Returns True if found, False if not.
		  
		  if parent.elements.Ubound < 0 then return new BooleanObject(False)
		  
		  dim i, limit as Integer
		  
		  ' First see if we can find the actual object in the array using Xojo's built-in method.
		  dim index as Integer = parent.elements.IndexOf(args(0))
		  if index <> -1 then return new BooleanObject(True)
		  
		  ' Didn't find an object match. Check literal types. First Text.
		  ' We can't use Xojo's built-in Array.IndexOf() method if `obj` is text because Xojo does a 
		  ' case-insensitive search so we'll have to traverse the array ourselves.
		  if args(0) isA TextObject then
		    dim query as String = TextObject(args(0)).value
		    limit = parent.elements.Ubound
		    for i = 0 to limit ' Look for TextObject elements.
		      if parent.elements(i) isA TextObject then
		        if StrComp(TextObject(parent.elements(i)).value, query, 0) = 0 then return new BooleanObject(True)
		      end if
		    next i
		    return new BooleanObject(False) ' Not found.
		  end if
		  
		  ' Number?
		  if args(0) isA NumberObject then
		    dim num as Double = NumberObject(args(0)).value
		    limit = parent.elements.Ubound
		    for i = 0 to limit
		      if parent.elements(i) isA NumberObject then
		        if NumberObject(parent.elements(i)).value = num then return new BooleanObject(True)
		      end if
		    next i
		  end if
		  
		  ' Boolean?
		  if args(0) isA BooleanObject then
		    dim b as Boolean = BooleanObject(args(0)).value
		    limit = parent.elements.Ubound
		    for i = 0 to limit
		      if parent.elements(i) isA BooleanObject then
		        if BooleanObject(parent.elements(i)).value = b then return new BooleanObject(True)
		      end if
		    next i
		  end if
		  
		  ' Nothing?
		  if args(0) isA NothingObject then
		    limit = parent.elements.Ubound
		    for i = 0 to limit
		      if parent.elements(i) isA NothingObject then return new BooleanObject(True)
		    next i
		  end if
		  
		  ' Not found.
		  return new BooleanObject(False)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function DoDeleteAt(args() as Variant, where as Token) As Variant
		  ' Array.delete_at!(index as Integer) as Object
		  ' Deletes the object at the specified index.
		  ' Returns the deleted object or Nothing if index is out of range.
		  
		  ' Check that `index` is an integer.
		  dim index as Integer
		  if not args(0) isA NumberObject or not NumberObject(args(0)).IsInteger then
		    raise new RuntimeError(where, "The " + self.name + "(index) method expects an integer parameter. " + _
		    "Instead got " + VariantType(args(0)) + ".")
		  else
		    index = NumberObject(args(0)).value
		    ' Make sure that it's a positive integer.
		    if index <= 0 then
		      raise new RuntimeError(where, "The " + self.name + "(index) method expects an integer parameter " + _
		      "greater than zero. Instead got " + Str(index) + ".")
		    end if
		  end if
		  
		  if index > parent.elements.Ubound then return new NothingObject
		  
		  dim removed as Variant = parent.elements(index)
		  
		  parent.elements.Remove(index)
		  
		  return removed
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function DoEach(args() as Variant, where as Token, interpreter as Interpreter) As ArrayObject
		  ' Array.each(func as Invokable, optional arguments as Array) as Array
		  ' Invokes the passed function for each element of this array, passing to the function the 
		  ' element as the first argument.
		  ' Optionally can take a second argument in the form of an Array. The elements of this
		  ' Array will be passed to the function as additional arguments.
		  ' Returns this array (unaltered).
		  ' E.g: 
		  
		  ' function stars(e)
		  '   print("*" + e + "*")
		  
		  ' function prefix(e, what)
		  '  print(what + e)
		  
		  ' var a = [a", "b", "c"]
		  ' a.each(stars)
		  ' # Prints:
		  ' # *a*
		  ' # *b*
		  ' # *c*
		  
		  ' a.each(prefix, ["->"]
		  ' # Prints:
		  ' # ->a
		  ' # ->b
		  ' # ->c
		  
		  dim funcArgs() as Variant
		  dim func as Invokable
		  dim i, elementsUbound as Integer
		  
		  ' Check that `func` is invokable.
		  if not args(0) isA Invokable then
		    raise new RuntimeError(where, "The " + self.name + "(func, args?) method expects a function as the " +_
		    "first parameter. Instead got " + VariantType(args(0)) + ".")
		  else
		    func = args(0)
		  end if
		  
		  ' If a second argument has been passed, check that it's an ArrayObject.
		  if args.Ubound = 1 then
		    if not args(1) isA ArrayObject then
		      raise new RuntimeError(where, "The " + self.name + "(func, args?) method expects the optional " +_
		      "second parameter to be an array. Instead got " + VariantType(args(1)) + ".")
		    else
		      ' Get an array of the additional arguments to pass to the function we will invoke.
		      for each v as Variant in ArrayObject(args(1)).elements
		        funcArgs.Append(v)
		      next v
		    end if
		  end if
		  
		  ' Check that we have the correct number of arguments for `func`.
		  ' +2 as we will pass in each element as the first argument.
		  if not Interpreter.CorrectArity(func, funcArgs.Ubound + 2) then
		    raise new RuntimeError(where, "Incorrect number of arguments passed to the " +_
		    Textable(func).ToText + " function.")
		  end if
		  
		  elementsUbound = parent.elements.Ubound
		  for i = 0 to elementsUbound
		    funcArgs.Insert(0, parent.elements(i)) ' Inject the element as the first argument to `func`.
		    call func.Invoke(interpreter, funcArgs, where)
		    funcArgs.Remove(0) ' Remove this element from the argument list prior to the next iteration.
		  next i
		  
		  ' Return this array.
		  return parent
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function DoEachIndex(args() as Variant, where as Token, interpreter as Interpreter) As ArrayObject
		  ' Array.each_index(func as Invokable, optional arguments as Array) as Array
		  ' Invokes the passed function for each index of this array, passing to the function the 
		  ' element index as the first argument.
		  ' Optionally can take a second argument in the form of an Array. The elements of this
		  ' Array will be passed to the function as additional arguments.
		  ' Returns this array (unaltered).
		  ' E.g: 
		  
		  ' function stars(e) {
		  '   print("*" + e + "*");
		  ' }
		  ' 
		  ' function prefix(e, what) {
		  '   print(what + e);
		  ' }
		  ' 
		  ' var a = ["a", "b", "c"];
		  ' a.each_index(stars);
		  ' # Prints:
		  ' # *0*
		  ' # *1*
		  ' # *2*
		  ' 
		  ' a.each_index(prefix, ["->"]);
		  ' # Prints:
		  ' # ->0
		  ' # ->1
		  ' # ->2
		  ' 
		  ' print(a); # => [a", "b", "c"]. Note unaltered.
		  
		  dim funcArgs() as Variant
		  dim func as Invokable
		  dim i, elementsUbound as Integer
		  
		  ' Check that `func` is an integer.
		  if not args(0) isA Invokable then
		    raise new RuntimeError(where, "The " + self.name + "(func, args?) method expects a function as the " +_
		    "first parameter. Instead got " + VariantType(args(0)) + ".")
		  else
		    func = args(0)
		  end if
		  
		  ' If a second argument has been passed, check that it's an ArrayObject.
		  if args.Ubound = 1 then
		    if not args(1) isA ArrayObject then
		      raise new RuntimeError(where, "The " + self.name + "(func, args?) method expects the optional " +_
		      "second parameter to be an array. Instead got " + VariantType(args(1)) + ".")
		    else
		      ' Get an array of the additional arguments to pass to the function we will invoke.
		      for each v as Variant in ArrayObject(args(1)).elements
		        funcArgs.Append(v)
		      next v
		    end if
		  end if
		  
		  ' Check that we have the correct number of arguments for `func`.
		  ' +2 as we will pass in each element index as the first argument.
		  if not Interpreter.CorrectArity(func, funcArgs.Ubound + 2) then
		    raise new RuntimeError(where, "Incorrect number of arguments passed to the " +_
		    Textable(func).ToText + " function.")
		  end if
		  
		  elementsUbound = parent.elements.Ubound
		  for i = 0 to elementsUbound
		    funcArgs.Insert(0, new NumberObject(i)) ' Inject the element index as the first argument to `func`.
		    call func.Invoke(interpreter, funcArgs, where)
		    funcArgs.Remove(0) ' Remove this element from the argument list prior to the next iteration.
		  next i
		  
		  ' Return this array.
		  return parent
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function DoFetch(args() as Variant, where as Token) As Variant
		  ' Array.fetch(index as Integer, default as Object) as Object
		  ' Returns the element at `index`. If `index` is negative then we count backwards from the end 
		  ' of the array. An index of -1 is the end of the array.
		  ' If `index` is out of range then we return `default`.
		  
		  ' Check that `index` is an integer.
		  if not args(0) isA NumberObject or not NumberObject(args(0)).IsInteger then
		    raise new RuntimeError(where, "The " + self.name + "(index, default) method expects an integer " + _
		    "parameter. Instead got " + VariantType(args(0)) + ".")
		  end if
		  
		  dim index as Integer = NumberObject(args(0)).value
		  
		  ' Check bounds. Return `default` if out of range.
		  if index >=0 and index > parent.elements.Ubound then
		    return args(1)
		  else
		    if Abs(index) > parent.elements.Ubound + 1 then return args(1)
		  end if
		  
		  ' Return the requested element.
		  if index >= 0 then
		    return parent.elements(index)
		  else
		    ' Count backwards from the upper limit of the array (-1 is the last element).
		    try
		      return parent.elements((parent.elements.Ubound + 1) + index)
		    catch OutOfBoundsException
		      #pragma BreakOnExceptions False
		      return args(1)
		    end try
		  end if
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function DoFind(args() as Variant) As Variant
		  ' Array.find(obj as Object) as NumberObject or Nothing.
		  ' Searches the array for the passed object. If found, it returns its index in the array. 
		  ' Returns Nothing if obj is not in the array.
		  
		  if parent.elements.Ubound < 0 then return new NothingObject
		  
		  dim i, limit as Integer
		  
		  ' First see if we can find the actual object in the array using Xojo's built-in method.
		  dim index as Integer = parent.elements.IndexOf(args(0))
		  if index <> -1 then return new NumberObject(index)
		  
		  ' Didn't find an object match. Check literal types. First Text.
		  ' We can't use Xojo's built-in Array.IndexOf() method if `obj` is text because Xojo does a 
		  ' case-insensitive search so we'll have to traverse the array ourselves.
		  if args(0) isA TextObject then
		    dim query as String = TextObject(args(0)).value
		    limit = parent.elements.Ubound
		    for i = 0 to limit ' Look for TextObject elements.
		      if parent.elements(i) isA TextObject then
		        if StrComp(TextObject(parent.elements(i)).value, query, 0) = 0 then return new NumberObject(i)
		      end if
		    next i
		    return new NothingObject ' Not found.
		  end if
		  
		  ' Number?
		  if args(0) isA NumberObject then
		    dim num as Double = NumberObject(args(0)).value
		    limit = parent.elements.Ubound
		    for i = 0 to limit
		      if parent.elements(i) isA NumberObject then
		        if NumberObject(parent.elements(i)).value = num then return new NumberObject(i)
		      end if
		    next i
		  end if
		  
		  ' Boolean?
		  if args(0) isA BooleanObject then
		    dim b as Boolean = BooleanObject(args(0)).value
		    limit = parent.elements.Ubound
		    for i = 0 to limit
		      if parent.elements(i) isA BooleanObject then
		        if BooleanObject(parent.elements(i)).value = b then return new NumberObject(i)
		      end if
		    next i
		  end if
		  
		  ' Nothing?
		  if args(0) isA NothingObject then
		    limit = parent.elements.Ubound
		    for i = 0 to limit
		      if parent.elements(i) isA NothingObject then return new NumberObject(i)
		    next i
		  end if
		  
		  ' Not found.
		  return new NothingObject
		  
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function DoFirst(args() as Variant, where as Token, destructive as Boolean) As Variant
		  ' Array.first() as Object or Nothing  |  Array.first(n as Integer) as Array.
		  ' If no arguments are passed then we return the first element of this array (or Nothing 
		  ' if the array is empty).
		  ' If a single argument is passed then we return the first `n` elements of this array. Returns 
		  ' an empty array if this array is empty. Returns the original array if n > Array.length.
		  
		  dim limit as Integer
		  
		  ' No arguments passed?
		  if args.Ubound < 0 then
		    if parent.elements.Ubound < 0 then
		      return new NothingObject
		    else
		      dim obj as Variant = parent.elements(0)
		      if destructive then parent.elements.Remove(0)
		      return obj
		    end if
		  end if
		  
		  ' Check that `n` is an integer.
		  dim n as Integer
		  if not args(0) isA NumberObject or not NumberObject(args(0)).IsInteger then
		    raise new RuntimeError(where, "The " + self.name + "(n) method expects an integer parameter. " + _
		    "Instead got " + VariantType(args(0)) + ".")
		  else
		    n = NumberObject(args(0)).value
		    ' Make sure that it's a positive integer.
		    if n <= 0 then
		      raise new RuntimeError(where, "The " + self.name + "(n) method expects an integer parameter " + _
		      "greater than zero. Instead got " + Str(n) + ".")
		    end if
		  end if
		  
		  if parent.elements.Ubound < 0 then return new ArrayObject
		  
		  ' Has the user asked for more elements than there are? If so, we return this array if `first()` or 
		  ' if `first!()` we return a copy of the original array but with all elements removed from the parent.
		  if n > (parent.elements.Ubound + 1) then
		    if destructive then
		      dim newArray as new ArrayObject
		      limit = parent.elements.Ubound
		      for i as Integer = 0 to limit
		        newArray.elements.Insert(0, parent.elements.Pop)
		      next i
		      return newArray
		    else
		      return parent
		    end if
		  end if
		  
		  dim result() as Variant
		  for i as Integer = 0 to (n - 1)
		    result.Append(parent.elements(i))
		  next i
		  
		  if destructive then
		    dim keep() as Variant
		    limit = parent.elements.Ubound
		    for i as Integer = n to limit
		      keep.Append(parent.elements(i))
		    next i
		    parent.elements = keep
		  end if
		  
		  return new ArrayObject(result)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function DoInsert(args() as Variant, where as Token) As ArrayObject
		  ' Array.insert!(index as Integer, obj as Object) as Array
		  ' Inserts `obj` into this array and returns the modified array.
		  ' Negative indices count backwards from the end of the array. Therefore an index of -1 will append 
		  ' the object to the end of the array.
		  ' If the passed `index` is greater than the current size of the array then we fill the missing 
		  ' elements with Nothing.
		  
		  ' Check that `index` is an integer.
		  if not args(0) isA NumberObject or not NumberObject(args(0)).IsInteger then
		    raise new RuntimeError(where, "The " + self.name + "(index, obj) method expects an integer parameter. " + _
		    "Instead got " + VariantType(args(0)) + ".")
		  end if
		  
		  dim index as Integer = NumberObject(args(0)).value
		  
		  ' Check bounds.
		  if index < 0 and index < -(parent.elements.Ubound + 2) then
		    dim min as Integer = parent.elements.Ubound + 2
		    raise new RuntimeError(where, "The " + self.name + "(index, obj) method `index` parameter ( " + _
		    Str(index) + ") is too small for the array (minimum permitted is -" + min.ToText + ").")
		  end if
		  
		  ' Do the insertion.
		  if index >= 0 and index <= parent.elements.Ubound then
		    ' Insert `obj` into an existing index and move everything in the array up one.
		    parent.elements.Insert(index, args(1))
		  elseif index > parent.elements.Ubound then
		    ' Insert `obj` into the specified index, filling the missing elements with Nothing.
		    dim numNothing as Integer = index - parent.elements.Ubound - 1
		    for i as Integer = 1 to numNothing
		      parent.elements.Append(new NothingObject)
		    next i
		    parent.elements.Append(args(1))
		  elseif index < 0 then
		    ' Count backwards from the upper limit of the array (-1 is the last element).
		    parent.elements.Insert(parent.elements.Ubound + index + 2, args(1))
		  end if
		  
		  ' Return this array.
		  return parent
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function DoJoin(args() as Variant, where as Token) As TextObject
		  ' Array.join() as Text  |  Array.join(separator as Text) as Text
		  ' Returns a new Text object created by converting each element of the array to its 
		  ' text representation, separated by the optional separator. If separator is not specified 
		  ' then we use empty text ("").
		  
		  dim separator as String = ""
		  
		  if args.Ubound = 0 then
		    if not args(0) isA Textable then
		      raise new RuntimeError(where, "The " + self.name + "(separator) method `separator` parameter " + _
		      "does not have a text representation.")
		    else
		      separator = Textable(args(0)).ToText()
		    end if
		  end if
		  
		  ' Do the join.
		  return parent.Join(separator)
		  
		  catch err as IllegalCastException
		    raise new RuntimeError(where, "An element in the array did not have a text representation.")
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function DoKeep(args() as Variant, where as Token, interpreter as Interpreter, destructive as Boolean) As ArrayObject
		  ' Array.keep(func as Invokable, optional arguments as Array) as Array
		  ' Array.keep!(func as Invokable, optional arguments as Array) as Array
		  ' Invokes the passed `func` for each element of this array, passing to `func` the element as the first
		  ' argument. Optionally, `keep` can take a second argument in the form of an ArrayObject. 
		  ' The elements of this array will be passed to `func` as additional arguments.
		  ' If `func` returns True then that element is kept, otherwise the element is rejected from the array.
		  ' We return a new array of kept elements
		  ' Can be destructive and mutate the original array.
		  
		  dim answer, toKeep(), funcArgs() as Variant
		  dim elementsUbound, i as Integer
		  dim func as Invokable
		  
		  ' Check that `func` is invokable.
		  if not args(0) isA Invokable then
		    raise new RuntimeError(where, "The " + self.name + "(func, args?) method expects a function as the " +_
		    "first parameter. Instead got " + VariantType(args(0)) + ".")
		  else
		    func = args(0)
		  end if
		  
		  ' If a second argument has been passed, check that it's an ArrayObject.
		  if args.Ubound = 1 then
		    if not args(1) isA ArrayObject then
		      raise new RuntimeError(where, "The " + self.name + "(func, args?) method expects the optional " +_
		      "second parameter to be an array. Instead got " + VariantType(args(1)) + ".")
		    else
		      ' Get an array of the additional arguments to pass to the function we will invoke.
		      for each v as Variant in ArrayObject(args(1)).elements
		        funcArgs.Append(v)
		      next v
		    end if
		  end if
		  
		  ' Check that we have the correct number of arguments for `func`.
		  ' +2 as we will pass in each element as the first argument.
		  if not Interpreter.CorrectArity(func, funcArgs.Ubound + 2) then
		    raise new RuntimeError(where, "Incorrect number of arguments passed to the " +_
		    Textable(func).ToText + " function.")
		  end if
		  
		  ' Do the keep.
		  elementsUbound = parent.elements.Ubound
		  for i = 0 to elementsUbound
		    funcArgs.Insert(0, parent.elements(i)) ' Inject the element as the first argument to `func`.
		    answer = func.Invoke(interpreter, funcArgs, where)
		    if answer isA BooleanObject and BooleanObject(answer).value then toKeep.Append(parent.elements(i))
		    funcArgs.Remove(0) ' Remove this element from the argument list prior to the next iteration.
		  next i
		  
		  if destructive then parent.elements = toKeep
		  
		  return new ArrayObject(toKeep)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function DoLast(args() as Variant, where as Token) As Variant
		  ' Array.last() as Object or Nothing  |  Array.last(n as Integer) as Array.
		  ' If no arguments are passed then we return the last element of this array (or Nothing 
		  ' if the array is empty).
		  ' If a single argument is passed then we return the last `n` elements of this array. Returns 
		  ' an empty array if this array is empty. Returns the original array if n > Array.length.
		  
		  ' No arguments passed?
		  if args.Ubound < 0 then
		    if parent.elements.Ubound < 0 then
		      return new NothingObject
		    else
		      return parent.elements(parent.elements.Ubound)
		    end if
		  end if
		  
		  ' Check that `n` is an Integer.
		  dim n as Integer
		  if not args(0) isA NumberObject or not NumberObject(args(0)).IsInteger then
		    raise new RuntimeError(where, "The " + self.name + "(n) method expects an integer parameter. " + _
		    "Instead got " + VariantType(args(0)) + ".")
		  else
		    n = NumberObject(args(0)).value
		    ' Make sure that it's a positive integer.
		    if n <= 0 then
		      raise new RuntimeError(where, "The " + self.name + "(n) method expects an integer parameter " + _
		      "greater than zero. Instead got " + Str(n) + ".")
		    end if
		  end if
		  
		  if parent.elements.Ubound < 0 then return new ArrayObject
		  
		  ' Has the user asked for more elements than there are? If so, return the original array.
		  if n > (parent.elements.Ubound + 1) then return parent
		  
		  dim result() as Variant
		  dim limit, start as Integer
		  limit = parent.elements.Ubound
		  start = (limit + 1) - n
		  
		  for i as Integer = start to limit
		    result.Append(parent.elements(i))
		  next i
		  
		  return new ArrayObject(result)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function DoMap(args() as Variant, where as Token, interpreter as Interpreter, destructive as Boolean) As ArrayObject
		  ' Array.map(func as Invokable, optional arguments as Array) as Array
		  ' Array.map!(func as Invokable, optional arguments as Array) as Array
		  
		  ' Invokes the passed `func` for each element of this array, passing to `func` the element as the first
		  ' argument. Optionally, `map` can take a second argument in the form of an ArrayObject. 
		  ' The elements of this array will be passed to `func` as additional arguments.
		  ' Returns a new array containing the values returned by `func`.
		  ' Can be destructive and mutate this array.
		  
		  dim funcArgs(), result() as Variant
		  dim elementsUbound, i as Integer
		  dim func as Invokable
		  
		  ' Check that `func` is invokable.
		  if not args(0) isA Invokable then
		    raise new RuntimeError(where, "The " + self.name + "(func, args?) method expects a function as the " +_
		    "first parameter. Instead got " + VariantType(args(0)) + ".")
		  else
		    func = args(0)
		  end if
		  
		  ' If a second argument has been passed, check that it's an ArrayObject.
		  if args.Ubound = 1 then
		    if not args(1) isA ArrayObject then
		      raise new RuntimeError(where, "The " + self.name + "(func, args?) method expects the optional " +_
		      "second parameter to be an array. Instead got " + VariantType(args(1)) + ".")
		    else
		      ' Get an array of the additional arguments to pass to the function we will invoke.
		      for each v as Variant in ArrayObject(args(1)).elements
		        funcArgs.Append(v)
		      next v
		    end if
		  end if
		  
		  ' Check that we have the correct number of arguments for `func`.
		  ' +2 as we will pass in each element as the first argument.
		  if not Interpreter.CorrectArity(func, funcArgs.Ubound + 2) then
		    raise new RuntimeError(where, "Incorrect number of arguments passed to the " +_
		    Textable(func).ToText + " function.")
		  end if
		  
		  elementsUbound = parent.elements.Ubound
		  for i = 0 to elementsUbound
		    funcArgs.Insert(0, parent.elements(i)) ' Inject this element as the first argument to `func`.
		    result.Append(func.Invoke(interpreter, funcArgs, where))
		    funcArgs.Remove(0) ' Remove this element from the argument list prior to the next iteration.
		  next i
		  
		  if destructive then parent.elements = result
		  
		  return new ArrayObject(result)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function DoPush(args() as Variant) As ArrayObject
		  ' Array.push(obj as Object) as Array
		  ' Appends the passed object to this array. Returns the amended array afterwards.
		  
		  parent.elements.Append(args(0))
		  
		  return parent
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function DoReject(args() as Variant, where as Token, interpreter as Interpreter, destructive as Boolean) As ArrayObject
		  ' Array.reject(func as Invokable, optional arguments as Array) as Array
		  ' Array.reject!(func as Invokable, optional arguments as Array) as Array
		  ' Invokes the passed `func` for each element of this array, passing to `func` the element as the first
		  ' argument. Optionally, `reject` can take a second argument in the form of an ArrayObject. 
		  ' The elements of this array will be passed to `func` as additional arguments.
		  ' If `func` returns True then that element is discarded, otherwise the element is kept in the array.
		  ' We return a new array of kept elements
		  ' Can be destructive and mutate the original array.
		  
		  dim answer, toKeep(), funcArgs() as Variant
		  dim elementsUbound, i as Integer
		  dim func as Invokable
		  
		  ' Check that `func` is invokable.
		  if not args(0) isA Invokable then
		    raise new RuntimeError(where, "The " + self.name + "(func, args?) method expects a function as the " +_
		    "first parameter. Instead got " + VariantType(args(0)) + ".")
		  else
		    func = args(0)
		  end if
		  
		  ' If a second argument has been passed, check that it's an ArrayObject.
		  if args.Ubound = 1 then
		    if not args(1) isA ArrayObject then
		      raise new RuntimeError(where, "The " + self.name + "(func, args?) method expects the optional " +_
		      "second parameter to be an array. Instead got " + VariantType(args(1)) + ".")
		    else
		      ' Get an array of the additional arguments to pass to the function we will invoke.
		      for each v as Variant in ArrayObject(args(1)).elements
		        funcArgs.Append(v)
		      next v
		    end if
		  end if
		  
		  ' Check that we have the correct number of arguments for `func`.
		  ' +2 as we will pass in each element as the first argument.
		  if not Interpreter.CorrectArity(func, funcArgs.Ubound + 2) then
		    raise new RuntimeError(where, "Incorrect number of arguments passed to the " +_
		    Textable(func).ToText + " function.")
		  end if
		  
		  ' Do the rejection.
		  elementsUbound = parent.elements.Ubound
		  for i = 0 to elementsUbound
		    funcArgs.Insert(0, parent.elements(i)) ' Inject the element as the first argument to `func`.
		    answer = func.Invoke(interpreter, funcArgs, where)
		    if answer isA BooleanObject and not BooleanObject(answer).value then toKeep.Append(parent.elements(i))
		    funcArgs.Remove(0) ' Remove this element from the argument list prior to the next iteration.
		  next i
		  
		  if destructive then parent.elements = toKeep
		  
		  return new ArrayObject(toKeep)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function DoRespondsTo(arguments() as Variant, where as Token) As BooleanObject
		  ' Array.responds_to?(what as Text) as Boolean.
		  
		  ' Make sure a Text argument is passed to the method.
		  if not arguments(0) isA TextObject then
		    raise new RuntimeError(where, "The " + self.name + "(what) method expects a text parameter. " + _
		    "Instead got " + VariantType(arguments(0)) + ".")
		  end if
		  
		  dim what as String = TextObject(arguments(0)).value
		  
		  if Lookup.ArrayGetter(what) then
		    return new BooleanObject(True)
		  elseif Lookup.ArrayMethod(what) then
		    return new BooleanObject(True)
		  else
		    return new BooleanObject(False)
		  end if
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function DoShift(args() as Variant, where as Token) As Variant
		  ' Array.shift!() as Object
		  ' Array.shift!(n as Integer) as Array
		  ' If no arguments are passed then it removes the first element of self and returns 
		  ' it (shifting all other elements down by one). 
		  ' If the optional `n` parameter is specified then we return an array of the first `n` elements 
		  ' just like Array.slice(0, n), leaving self containing only the remaining elements.
		  
		  dim obj, tmp() as Variant
		  dim i, limit as Integer
		  
		  ' No arguments? Just remove the first element and return it.
		  if args().Ubound < 0 then
		    if parent.elements.Ubound < 0 then return new NothingObject
		    obj = parent.elements(0)
		    parent.elements.Remove(0)
		    return obj
		  end if
		  
		  ' Check that `n` is an integer.
		  dim n as Integer
		  if not args(0) isA NumberObject or not NumberObject(args(0)).IsInteger then
		    raise new RuntimeError(where, "The " + self.name + "(n) method expects an integer parameter. " + _
		    "Instead got " + VariantType(args(0)) + ".")
		  else
		    n = NumberObject(args(0)).value
		    ' Make sure that it's a positive integer.
		    if n <= 0 then
		      raise new RuntimeError(where, "The " + self.name + "(n) method expects an integer parameter " + _
		      "greater than zero. Instead got " + Str(n) + ".")
		    end if
		  end if
		  
		  ' Clear out the array (n = 0)?
		  if n = 0 then
		    tmp = parent.elements
		    redim parent.elements(-1)
		    return new ArrayObject(tmp)
		  end if
		  
		  if n > parent.elements.Ubound + 1 then
		    ' Return all elements of this array as a new array and clear out this array.
		    limit = parent.elements.Ubound
		    for i = 0 to limit ' Need to do a manual copy.
		      tmp.Append(parent.elements(i))
		    next i
		    redim parent.elements(-1)
		    return new ArrayObject(tmp)
		  else
		    ' Get the first `n` elements as a new array.
		    limit = n - 1
		    for i = 0 to limit
		      tmp.Append(parent.elements(i))
		    next i
		    ' Now remove these elements from this array.
		    for i = 1 to n
		      parent.elements.Remove(0)
		    next i
		    return new ArrayObject(tmp)
		  end if
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function DoSlice(args() as Variant, where as Token, destructive as Boolean) As Variant
		  ' Wrapper method for the multiple Array.slice() methods.
		  ' Either slice(index) or slice(start, length).
		  
		  if args.Ubound = 0 then 
		    if not args(0) isA NumberObject or not NumberObject(args(0)).IsInteger then
		      raise new RuntimeError(where, "The " + self.name + "(index) method expects an integer parameter. " + _
		      "Instead got " + VariantType(args(0)) + ".")
		    end if
		    return DoSliceIndex(NumberObject(args(0)).value, destructive)
		  else
		    if not args(0) isA NumberObject or not NumberObject(args(0)).IsInteger then
		      raise new RuntimeError(where, "The " + self.name + "(start, length) method expects `start` to be an " +_
		      "integer. Instead got " + VariantType(args(0)) + ".")
		    end if
		    if not args(1) isA NumberObject or not NumberObject(args(1)).IsInteger then
		      raise new RuntimeError(where, "The " + self.name + "(start, length) method expects `length` to be " +_
		      "an integer. Instead got " + VariantType(args(1)) + ".")
		    end if
		    return DoSliceStartLength(NumberObject(args(0)).value, NumberObject(args(1)).value, destructive)
		  end if
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function DoSliceIndex(index as Integer, destructive as Boolean) As Variant
		  ' Array.slice(index as Integer) as Object
		  ' Array.slice!(index as Integer) as Object
		  ' Negative indices count backwards from the end of the array (-1 is the last element).
		  ' Returns the element at the specified index.
		  ' slice() leaves this array alone. slice!() additionally removes the returned element from the array.
		  ' If `Abs(index > Array.length)` then returns Nothing. Additionally in this scenario, it will NOT affect 
		  ' this array if slice!() is called.
		  
		  dim result as Variant
		  dim length as Integer = parent.elements.Ubound + 1
		  
		  if index >= 0 and index > parent.elements.Ubound then
		    result = new NothingObject
		  elseif index < 0 and Abs(index) > length then
		    result = new NothingObject
		  else
		    if index < 0 then
		      result = parent.elements(length + index)
		      if destructive then parent.elements.Remove(length + index)
		    else
		      result = parent.elements(index)
		      if destructive then parent.elements.Remove(index)
		    end if
		  end if
		  
		  return result
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function DoSliceStartLength(start as Integer, length as Integer, destructive as Boolean) As Variant
		  ' Array.slice(start as Integer, length as Integer) as Array or Nothing
		  ' Array.slice!(start as Integer, length as Integer) as Array or Nothing
		  ' If `start` is negative, we count backwards from the end of the array (-1 is the last element).
		  ' `length` should be positive or else we return Nothing
		  ' Returns a new subarray formed from the elements `start` to `length`.
		  ' slice() leaves this array alone. slice!() additionally removes the returned elements from the array.
		  ' If `Abs(index > Array.length)` then we return Nothing. Additionally in this scenario, it 
		  ' will NOT affect this array if slice!() is called.
		  
		  dim result(), keep() as Variant
		  dim finish, i, elementsUbound as Integer
		  
		  elementsUbound = parent.elements.Ubound
		  
		  ' Edge cases.
		  if elementsUbound < 0 then return new ArrayObject
		  if length = 0 then return new ArrayObject
		  if length < 0 then return new NothingObject
		  if start > elementsUbound then return new NothingObject
		  if start < 0 and Abs(start) > elementsUbound + 1 then return new NothingObject
		  
		  ' Calculate the correct start index.
		  if start < 0 then start = elementsUbound + 1 + start
		  
		  ' Calculate the finishing index.
		  finish = if(start + length > elementsUbound + 1, elementsUbound, start + length - 1)
		  
		  ' Do the slicing.
		  if destructive then
		    ' We not only need to get the elements to create a new array but we need to remove them from this array.
		    for i = 0 to elementsUbound
		      if i >= start and i <= finish then
		        result.Append(parent.elements(i))
		      else
		        keep.Append(parent.elements(i))
		      end if
		    next i
		    parent.elements = keep
		  else
		    for i = start to finish
		      result.Append(parent.elements(i))
		    next i
		  end if
		  
		  ' Return the sliced elements as a new array.
		  return new ArrayObject(result)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Invoke(interpreter as Interpreter, arguments() as Variant, where as Token) As Variant
		  #pragma Unused arguments
		  #pragma Unused interpreter
		  #pragma Unused where
		  
		  select case self.name
		  case "contains?"
		    return DoContains(arguments)
		  case "delete_at!"
		    return DoDeleteAt(arguments, where)
		  case "each"
		    return DoEach(arguments, where, interpreter)
		  case "each_index"
		    return DoEachIndex(arguments, where, interpreter)
		  case "fetch"
		    return DoFetch(arguments, where)
		  case "find"
		    return DoFind(arguments)
		  case "first"
		    return DoFirst(arguments, where, False)
		  case "first!"
		    return DoFirst(arguments, where, True)
		  case "insert!"
		    return DoInsert(arguments, where)
		  case "join"
		    return DoJoin(arguments, where)
		  case "keep"
		    return DoKeep(arguments, where, interpreter, False)
		  case "keep!"
		    return DoKeep(arguments, where, interpreter, True)
		  case "last"
		    return DoLast(arguments, where)
		  case "map"
		    return DoMap(arguments, where, interpreter, False)
		  case "map!"
		    return DoMap(arguments, where, interpreter, True)
		  case "push"
		    return DoPush(arguments)
		  case "reject"
		    return DoReject(arguments, where, interpreter, False)
		  case "reject!"
		    return DoReject(arguments, where, interpreter, True)
		  case "responds_to?"
		    return DoRespondsTo(arguments, where)
		  case "shift!"
		    return DoShift(arguments, where)
		  case "slice"
		    return DoSlice(arguments, where, False)
		  case "slice!"
		    return DoSlice(arguments, where, True)
		  end select
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function ToText() As String
		  ' Part of the Textable interface.
		  
		  return "<function " + self.name + ">"
		End Function
	#tag EndMethod


	#tag Property, Flags = &h0
		name As String
	#tag EndProperty

	#tag Property, Flags = &h0
		parent As ArrayObject
	#tag EndProperty


	#tag ViewBehavior
		#tag ViewProperty
			Name="name"
			Visible=true
			Group="ID"
			Type="String"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Index"
			Visible=true
			Group="ID"
			InitialValue="-2147483648"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Super"
			Visible=true
			Group="ID"
			Type="String"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Left"
			Visible=true
			Group="Position"
			InitialValue="0"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Top"
			Visible=true
			Group="Position"
			InitialValue="0"
			Type="Integer"
		#tag EndViewProperty
	#tag EndViewBehavior
End Class
#tag EndClass
