#tag Class
Protected Class RooArrayMethod
Implements Invokable, Stringable
	#tag Method, Flags = &h0
		Function Arity() As Variant
		  // Part of the Invokable interface.
		  // Return the arity of this method. This is stored in the cached ArrayMethods dictionary.
		  
		  Return RooSLCache.ArrayMethods.Value(Name)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor(owner As RooArray, name As String)
		  Self.Owner = owner
		  Self.Name = name
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function DoContains(args() As Variant) As RooBoolean
		  // Array.contains(obj As Object) As Boolean object.
		  // Searches the array for the passed object. Returns True if found, False if not.
		  
		  // Quick check for an empty array.
		  If Owner.Elements.Ubound < 0 Then Return New RooBoolean(False)
		  
		  // First see if we can find the actual object in the array using Xojo's built-in method.
		  If Owner.Elements.IndexOf(args(0)) <> -1 Then Return New RooBoolean(True)
		  
		  Dim element As Variant
		  // Didn't find an object match. Check literal types. 
		  // Start with Text.
		  // We can't use Xojo's built-in Array.IndexOf() method if `obj` is text because Xojo does a 
		  // case-insensitive search so we'll have to traverse the array ourselves.
		  If args(0) IsA RooText Then
		    Dim query As String = RooText(args(0)).Value
		    For Each element In Owner.Elements
		      If element IsA RooText And StrComp(RooText(element).Value, query, 0) = 0 Then
		        Return New RooBoolean(True)
		      End If
		    Next element
		    Return New RooBoolean(False) // Not found.
		  End If
		  
		  // Number?
		  If args(0) IsA RooNumber Then
		    Dim num As Double = RooNumber(args(0)).Value
		    For Each element In Owner.Elements
		      If element IsA RooNumber And RooNumber(element).Value = num Then Return New RooBoolean(True)
		    Next element
		  End If
		  
		  // Boolean?
		  If args(0) IsA RooBoolean Then
		    Dim b As Boolean = RooBoolean(args(0)).Value
		    For Each element In Owner.Elements
		      If element IsA RooBoolean And RooBoolean(element).Value = b Then Return New RooBoolean(True)
		    Next element
		  End If
		  
		  // Nothing?
		  If args(0) IsA RooNothing Then
		    For Each element In Owner.Elements
		      If element IsA RooNothing Then Return New RooBoolean(True)
		    Next element
		  End If
		  
		  // Not found.
		  Return New RooBoolean(False)
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function DoDeleteAt(args() As Variant, where As RooToken) As Variant
		  // Array.delete_at!(index As Integer) As Object
		  // Deletes the object at the specified index.
		  // Returns the deleted object or Nothing if index is out of range.
		  
		  // Check that `index` is an integer.
		  Roo.AssertArePositiveIntegers(where, args(0))
		  Dim index As Integer = RooNumber(args(0)).Value
		  
		  // Out of range?
		  If index > Owner.Elements.Ubound Then Return New RooNothing
		  
		  // Get the element to remove.
		  Dim removed As Variant = Owner.Elements(index)
		  
		  // Remove the element.
		  Owner.Elements.Remove(index)
		  
		  // Return it.
		  Return removed
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function DoEach(args() As Variant, where As RooToken, interpreter As RooInterpreter) As RooArray
		  // Array.each(func As Invokable, optional arguments As Array) As Array
		  // Invokes the passed function for each element of this array, passing to the function the 
		  // element as the first argument.
		  // Optionally can take a second argument in the form of an Array. The elements of this
		  // Array will be passed to the function as additional arguments.
		  // Returns this array (unaltered).
		  // E.g: 
		  ' def stars(e):
		  '   print("*" + e + "*")
		  
		  ' def prefix(e, what):
		  '  print(what + e)
		  
		  ' var a = ["a", "b", "c"]
		  ' a.each(stars)
		  ' # Prints:
		  ' # *a*
		  ' # *b*
		  ' # *c*
		  
		  ' a.each(prefix, ["->"])
		  ' # Prints:
		  ' # ->a
		  ' # ->b
		  ' # ->c
		  
		  Dim funcArgs() As Variant
		  Dim func As Invokable
		  Dim i, elementsUbound As Integer
		  
		  // Check that `func` is invokable.
		  Roo.AssertIsInvokable(where, args(0))
		  func = args(0)
		  
		  // If a second argument has been passed, check that it's an Array object.
		  If args.Ubound = 1 Then
		    Roo.AssertIsArray(where, args(1))
		    // Get an array of the additional arguments to pass to the function we will invoke.
		    For Each v As Variant In RooArray(args(1)).Elements
		      funcArgs.Append(v)
		    Next v
		  End If
		  
		  // Check that we have the correct number of arguments for `func`.
		  // NB: +2 as we will pass in each element as the first argument.
		  If Not Interpreter.CorrectArity(func, funcArgs.Ubound + 2) Then
		    Raise New RooRuntimeError(where, "Incorrect number of arguments passed to the " +_
		    Stringable(func).StringValue + " function.")
		  End If
		  
		  elementsUbound = Owner.Elements.Ubound
		  For i = 0 To elementsUbound
		    funcArgs.Insert(0, Owner.Elements(i)) // Inject the element as the first argument to `func`.
		    call func.Invoke(interpreter, funcArgs, where)
		    funcArgs.Remove(0) // Remove this element from the argument list prior to the next iteration.
		  Next i
		  
		  // Return this array.
		  Return Owner
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function DoEachIndex(args() As Variant, where As RooToken, interpreter As RooInterpreter) As RooArray
		  // Array.each_index(func as Invokable, optional arguments as Array) as Array
		  // Invokes the passed function for each index of this array, passing to the function the 
		  // element index as the first argument.
		  // Optionally can take a second argument in the form of an Array. The elements of this
		  // array will be passed to the function as additional arguments.
		  // Returns this array (unaltered).
		  // E.g: 
		  
		  ' def squared(e):
		  '   print("*" + e*e + "*")
		  
		  ' def prefix(e, what):
		  '   print(what + e)
		  
		  ' var a = ["a", "b", "c", "d"]
		  
		  ' a.each_index(squared)
		  ' # Prints:
		  ' # *0*
		  ' # *1*
		  ' # *4*
		  ' # *0*
		  
		  ' a.each_index(prefix, ["->"])
		  ' # Prints:
		  ' # ->0
		  ' # ->1
		  ' # ->2
		  ' # ->3
		  
		  ' # You can also pass standard library functions to each_index:
		  ' a.each_index(print)
		  ' # Prints:
		  ' # 0
		  ' # 1
		  ' # 2
		  ' # 3
		  
		  ' print(a) # Unchanged (["a", "b", "c", "d"])
		  
		  Dim funcArgs() As Variant
		  Dim func As Invokable
		  Dim i, elementsUbound As Integer
		  
		  // Check that `func` is invokable.
		  Roo.AssertIsInvokable(where, args(0))
		  func = args(0)
		  
		  // If a second argument has been passed, check that it's an Array object.
		  If args.Ubound = 1 Then
		    Roo.AssertIsArray(where, args(1))
		    // Get an array of the additional arguments to pass to the function we will invoke.
		    For Each v As Variant In RooArray(args(1)).Elements
		      funcArgs.Append(v)
		    Next v
		  End If
		  
		  // Check that we have the correct number of arguments for `func`.
		  // NB: +2 as we will pass in each element index as the first argument.
		  If Not Interpreter.CorrectArity(func, funcArgs.Ubound + 2) Then
		    Raise New RooRuntimeError(where, "Incorrect number of arguments passed to the " +_
		    Stringable(func).StringValue + " function.")
		  End If
		  
		  elementsUbound = Owner.Elements.Ubound
		  For i = 0 To elementsUbound
		    funcArgs.Insert(0, New RooNumber(i)) // Inject the element index as the first argument to `func`.
		    Call func.Invoke(interpreter, funcArgs, where)
		    funcArgs.Remove(0) // Remove this element from the argument list prior to the next iteration.
		  Next i
		  
		  // Return this array.
		  Return Owner
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function DoFetch(args() As Variant, where As RooToken) As Variant
		  // Array.fetch(index as Integer, default as Object) as Object
		  // Returns the element at `index`. If `index` is negative then we count backwards from the end 
		  // of the array. An index of -1 is the end of the array.
		  // If `index` is out of range then we return `default`.
		  
		  // Check that `index` is an integer.
		  Roo.AssertAreIntegers(where, args(0))
		  Dim index As Integer = RooNumber(args(0)).Value
		  
		  // Check bounds. Return `default` if out of range.
		  If index >=0 And index > Owner.Elements.Ubound Then
		    Return args(1)
		  Else
		    If Abs(index) > Owner.Elements.Ubound + 1 Then Return args(1)
		  End If
		  
		  // Return the requested element.
		  If index >= 0 Then
		    Return Owner.Elements(index)
		  Else
		    // Count backwards from the upper limit of the array (-1 is the last element).
		    Try
		      Return Owner.Elements((Owner.Elements.Ubound + 1) + index)
		    Catch OutOfBoundsException
		      #Pragma BreakOnExceptions False
		      Return args(1)
		    End Try
		  End If
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function DoFind(args() As Variant) As Variant
		  // Array.find(obj as Object) as Number object or Nothing.
		  // Searches the array for the passed object. If found, it returns its index in the array. 
		  // Returns Nothing if obj is not in the array.
		  
		  // Quick check for an empty array.
		  If Owner.Elements.Ubound < 0 Then Return New RooNothing
		  
		  Dim i, limit As Integer
		  
		  // First see if we can find the actual in-memory object in the array using Xojo's built-in method.
		  Dim index As Integer = Owner.Elements.IndexOf(args(0))
		  If index <> -1 Then Return New RooNumber(index)
		  
		  // Didn't find an object match. Check literal types. 
		  // First we check Text.
		  If args(0) IsA RooText Then
		    Dim query As String = RooText(args(0)).Value
		    limit = Owner.Elements.Ubound
		    For i = 0 To limit
		      If Owner.Elements(i) IsA RooText Then // Do a case-sensitive comparison.
		        If StrComp(RooText(Owner.Elements(i)).Value, query, 0) = 0 Then Return New RooNumber(i)
		      End If
		    Next i
		    Return New RooNothing // Not found.
		  End If
		  
		  // Number?
		  If args(0) IsA RooNumber Then
		    Dim n As Double = RooNumber(args(0)).Value
		    limit = Owner.Elements.Ubound
		    For i = 0 To limit
		      If Owner.Elements(i) IsA RooNumber Then
		        If RooNumber(Owner.Elements(i)).Value = n Then Return New RooNumber(i)
		      End If
		    Next i
		  End If
		  
		  // Boolean?
		  If args(0) IsA RooBoolean Then
		    Dim b As Boolean = RooBoolean(args(0)).Value
		    limit = Owner.Elements.Ubound
		    For i = 0 To limit
		      If Owner.Elements(i) IsA RooBoolean Then
		        If RooBoolean(Owner.Elements(i)).Value = b Then Return New RooNumber(i)
		      End If
		    Next i
		  End If
		  
		  // Nothing?
		  If args(0) IsA RooNothing Then
		    limit = Owner.Elements.Ubound
		    For i = 0 To limit
		      If Owner.Elements(i) IsA RooNothing Then Return New RooNumber(i)
		    Next i
		  End If
		  
		  // Not found.
		  Return New RooNothing
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function DoFirst(args() As Variant, where As RooToken, destructive As Boolean) As Variant
		  // Array.first() as Object or Nothing  |  Array.first(n as Integer) as Array.
		  // If no arguments are passed then we return the first element of this array (or Nothing 
		  // if the array is empty).
		  // If a single argument is passed then we return the first `n` elements of this array. Returns 
		  // an empty array if this array is empty. Returns the original array if n > Array.length.
		  
		  Dim limit As Integer
		  
		  If args.Ubound < 0 Then
		    // No arguments passed.
		    If Owner.Elements.Ubound < 0 Then
		      Return New RooNothing
		    Else
		      Dim obj As Variant = Owner.Elements(0)
		      If destructive Then Owner.Elements.Remove(0)
		      Return obj
		    End If
		  End If
		  
		  // A single argument has been passed. Check that it's a positive integer.
		  Roo.AssertIsPositiveInteger(where, args(0))
		  Dim n As Integer = RooNumber(args(0)).Value
		  
		  // If this array is empty, return a new empty array.
		  If Owner.Elements.Ubound < 0 Then Return New RooArray
		  
		  // Has the user asked for more elements than there are? If so, we return this array if `first()` or 
		  // if `first!()` we return a copy of the original array and then we remove all elements from this array.
		  If n > (Owner.Elements.Ubound + 1) Then
		    If destructive Then
		      Dim newArray As New RooArray
		      limit = Owner.Elements.Ubound
		      For i As Integer = 0 To limit
		        newArray.Elements.Insert(0, Owner.Elements.Pop)
		      Next i
		      return newArray
		    Else // Non-destructive.
		      Return Owner
		    End If
		  End If
		  
		  // Get the first n elements and store them in `result`.
		  Dim result() As Variant
		  limit = n - 1
		  For i As Integer = 0 To limit
		    result.Append(Owner.Elements(i))
		  Next i
		  
		  // If this is a destructive operation, we need to remove the first `n` elements from this array.
		  If destructive Then
		    Dim keep() As Variant
		    limit = Owner.Elements.Ubound
		    For i As Integer = n To limit
		      keep.Append(Owner.Elements(i))
		    Next i
		    Owner.Elements = keep
		  End If
		  
		  Return New RooArray(result)
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function DoInsert(args() As Variant, where As RooToken) As RooArray
		  // Array.insert!(index as Integer, obj as Object) as Array
		  // Inserts `obj` into this array and returns the modified array.
		  // Negative indices count backwards from the end of the array. Therefore an index of -1 will append 
		  // the object to the end of the array.
		  // If the passed `index` is greater than the current size of the array then we fill the missing 
		  // elements with Nothing.
		  
		  // Check that `index` is an integer.
		  Roo.AssertIsInteger(where, args(0))
		  Dim index As Integer = RooNumber(args(0)).Value
		  
		  // Check bounds.
		  If index < 0 And index < -(Owner.Elements.Ubound + 2) Then
		    Dim min As Integer = Owner.Elements.Ubound + 2
		    Raise New RooRuntimeError(where, "The " + Name + "(index, obj) method `index` parameter ( " + _
		    Str(index) + ") is too small for the array (minimum permitted is -" + Str(min) + ").")
		  End If
		  
		  // Do the insertion.
		  If index >= 0 And index <= Owner.Elements.Ubound Then
		    // Insert `obj` into an existing index and move everything in the array up one.
		    Owner.Elements.Insert(index, args(1))
		  ElseIf index > Owner.Elements.Ubound Then
		    // Insert `obj` into the specified index, filling the missing elements with Nothing.
		    Dim numNothing As Integer = index - Owner.Elements.Ubound - 1
		    For i As Integer = 1 To numNothing
		      Owner.Elements.Append(New RooNothing)
		    Next i
		    Owner.Elements.Append(args(1))
		  ElseIf index < 0 Then
		    // Count backwards from the upper limit of the array (-1 is the last element).
		    Owner.Elements.Insert(Owner.Elements.Ubound + index + 2, args(1))
		  End If
		  
		  // Return this array.
		  Return Owner
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function DoJoin(args() As Variant, where As RooToken) As RooText
		  // Array.join() as Text  |  Array.join(separator as Text) as Text
		  // Returns a new Text object created by converting each element of the array to its 
		  // text representation, separated by the optional separator. If separator is not specified 
		  // then we use empty text ("").
		  
		  Dim separator As String = ""
		  
		  If args.Ubound = 0 Then separator = Stringable(args(0)).StringValue
		  
		  // Do the join.
		  Return Owner.Join(separator)
		  
		  Catch err As IllegalCastException
		    Raise New RooRuntimeError(where, "An element in the array did not have a text representation.")
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function DoKeep(args() As Variant, where As RooToken, interpreter As RooInterpreter, destructive As Boolean) As RooArray
		  // Array.keep(func as Invokable, optional arguments as Array) as Array
		  // Array.keep!(func as Invokable, optional arguments as Array) as Array
		  // Invokes the passed `func` for each element of this array, passing to `func` the 
		  // element as the first argument. Optionally, `keep` can take a second argument in the form 
		  // of a RooArray. The elements of this array will be passed to `func` as additional arguments.
		  // If `func` returns True then that element is kept, otherwise the element is rejected from the array.
		  // We return a new array of kept elements
		  // Can be destructive and mutate the original array.
		  
		  Dim answer, toKeep(), funcArgs() As Variant
		  Dim elementsUbound, i As Integer
		  Dim func As Invokable
		  
		  // Check that `func` is invokable.
		  Roo.AssertIsInvokable(where, args(0))
		  func = args(0)
		  
		  if args.Ubound = 1 then
		    // A second argument has been passed - check that it's a RooArray.
		    Roo.AssertIsArray(where, args(1))
		    // Get an array of the additional arguments to pass to the function we will invoke.
		    Dim limit As Integer = RooArray(args(1)).Elements.Ubound
		    For i = 0 To limit
		      funcArgs.Append(RooArray(args(1)).Elements(i))
		    Next i
		  end if
		  
		  // Check that we have the correct number of arguments for `func`.
		  // NB: +2 as we will pass in each element as the first argument.
		  If Not Interpreter.CorrectArity(func, funcArgs.Ubound + 2) Then
		    Raise New RooRuntimeError(where, "Incorrect number of arguments passed to the " +_
		    Stringable(func).StringValue + " function.")
		  End If
		  
		  // Do the keep.
		  elementsUbound = Owner.Elements.Ubound
		  For i = 0 To elementsUbound
		    funcArgs.Insert(0, Owner.Elements(i)) // Inject the element as the first argument to `func`.
		    answer = func.Invoke(interpreter, funcArgs, where)
		    If answer IsA RooBoolean and RooBoolean(answer).Value Then toKeep.Append(Owner.Elements(i))
		    funcArgs.Remove(0) // Remove this element from the argument list prior to the next iteration.
		  Next i
		  
		  If destructive Then Owner.Elements = toKeep
		  
		  Return New RooArray(toKeep)
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function DoLast(args() As Variant, where As RooToken) As Variant
		  // Array.last() as Object or Nothing  |  Array.last(n as Integer) as Array.
		  // If no arguments are passed then we return the last element of this array (or Nothing 
		  // if the array is empty).
		  // If a single argument is passed then we return the last `n` elements of this array. Returns 
		  // an empty array if this array is empty. Returns the original array if n > Array.length.
		  
		  If args.Ubound < 0 Then
		    // No arguments passed.
		    If Owner.Elements.Ubound < 0 Then
		      Return New RooNothing
		    Else
		      Return Owner.Elements(Owner.Elements.Ubound)
		    End If
		  End If
		  
		  // Check that `n` is a positive Integer.
		  Roo.AssertIsPositiveInteger(where, args(0))
		  Dim n As Integer = RooNumber(args(0)).Value
		  
		  // If this array is empty, return a new empty array.
		  If Owner.Elements.Ubound < 0 Then Return New RooArray
		  
		  // Has the user asked for more elements than there are? If so, return the original array.
		  If n > (Owner.Elements.Ubound + 1) Then Return Owner
		  
		  // Get and return the last `n` elements.
		  Dim result() As Variant
		  Dim limit, start As Integer
		  limit = Owner.Elements.Ubound
		  start = (limit + 1) - n
		  
		  For i As Integer = start To limit
		    result.Append(Owner.Elements(i))
		  Next i
		  
		  Return New RooArray(result)
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function DoMap(args() As Variant, where As RooToken, interpreter As RooInterpreter, destructive As Boolean) As RooArray
		  // Array.map(func as Invokable, optional arguments as Array) as Array
		  // Array.map!(func as Invokable, optional arguments as Array) as Array
		  // Invokes the passed `func` for each element of this array, passing to `func` the element 
		  // as the first argument. Optionally, `map` can take a second argument in the form of an Array object. 
		  // The elements of this array will be passed to `func` as additional arguments.
		  // Returns a new array containing the values returned by `func`.
		  // Can be destructive and mutate this array.
		  
		  Dim funcArgs(), result() As Variant
		  Dim elementsUbound, i As Integer
		  Dim func As Invokable
		  
		  // Check that `func` is invokable.
		  Roo.AssertIsInvokable(where, args(0))
		  func = args(0)
		  
		  // If a second argument has been passed, check that it's an Array object.
		  if args.Ubound = 1 then
		    Roo.AssertIsArray(where, args(1))
		    // Get an array of the additional arguments to pass to the function we will invoke.
		    Dim limit As Integer = RooArray(args(1)).Elements.Ubound
		    For i = 0 To limit
		      funcArgs.Append(RooArray(args(1)).Elements(i))
		    Next i
		  End If
		  
		  // Check that we have the correct number of arguments for `func`.
		  // NB: +2 as we will pass in each element as the first argument.
		  If Not Interpreter.CorrectArity(func, funcArgs.Ubound + 2) Then
		    Raise New RooRuntimeError(where, "Incorrect number of arguments passed to the " +_
		    Stringable(func).StringValue + " function.")
		  End If
		  
		  elementsUbound = Owner.Elements.Ubound
		  For i = 0 To elementsUbound
		    funcArgs.Insert(0, Owner.Elements(i)) // Inject this element as the first argument to `func`.
		    result.Append(func.Invoke(interpreter, funcArgs, where))
		    funcArgs.Remove(0) // Remove this element from the argument list prior to the next iteration.
		  Next i
		  
		  If destructive Then Owner.Elements = result
		  
		  Return New RooArray(result)
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function DoPush(args() As Variant) As RooArray
		  // Array.push(obj as Object) as Array
		  // Appends the passed object to this array. Returns the amended array afterwards.
		  
		  Owner.Elements.Append(args(0))
		  
		  Return Owner
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function DoReject(args() As Variant, where As RooToken, interpreter As RooInterpreter, destructive As Boolean) As RooArray
		  // Array.reject(func as Invokable, optional arguments as Array) as Array
		  // Array.reject!(func as Invokable, optional arguments as Array) as Array
		  // Invokes the passed `func` for each element of this array, passing to `func` the element 
		  // as the first argument. Optionally, `reject` can take a second argument in the form 
		  // of an Array object. The elements of this array will be passed to `func` as additional arguments.
		  // If `func` returns True then that element is discarded, otherwise the element is kept in the array.
		  // We return a new array of kept elements
		  // Can be destructive and mutate the original array.
		  
		  Dim answer, toKeep(), funcArgs() As Variant
		  Dim elementsUbound, i As Integer
		  Dim func As Invokable
		  
		  // Check that `func` is invokable.
		  Roo.AssertIsInvokable(where, args(0))
		  func = args(0)
		  
		  // If a second argument has been passed, check that it's an Array object.
		  If args.Ubound = 1 Then
		    // Get an array of the additional arguments to pass to the function we will invoke.
		    Dim limit As Integer = RooArray(args(1)).Elements.Ubound
		    For i = 0 To limit
		      funcArgs.Append(RooArray(args(1)).Elements(i))
		    Next i
		  End If
		  
		  // Check that we have the correct number of arguments for `func`.
		  // NB: +2 as we will pass in each element as the first argument.
		  If Not Interpreter.CorrectArity(func, funcArgs.Ubound + 2) Then
		    Raise New RooRuntimeError(where, "Incorrect number of arguments passed to the " +_
		    Stringable(func).StringValue + " function.")
		  End If
		  
		  // Do the rejection.
		  elementsUbound = Owner.Elements.Ubound
		  For i = 0 To elementsUbound
		    funcArgs.Insert(0, Owner.Elements(i)) // Inject the element as the first argument to `func`.
		    answer = func.Invoke(interpreter, funcArgs, where)
		    If answer IsA RooBoolean And Not RooBoolean(answer).Value Then toKeep.Append(Owner.elements(i))
		    funcArgs.Remove(0) // Remove this element from the argument list prior to the next iteration.
		  Next i
		  
		  If destructive Then Owner.Elements = toKeep
		  
		  Return New RooArray(toKeep)
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function DoShift(args() As Variant, where As RooToken) As Variant
		  // Array.shift!() as Object
		  // Array.shift!(n as Integer) as Array
		  // If no arguments are passed then it removes the first element of this array and returns 
		  // it (shifting all other elements down by one). 
		  // If the optional `n` parameter is specified then we return an array of the first `n` elements 
		  // just like Array.slice(0, n), leaving self containing only the remaining elements.
		  
		  Dim obj, tmp() As Variant
		  Dim i, limit As Integer
		  
		  // No arguments? Just remove the first element and return it.
		  If args().Ubound < 0 Then
		    If Owner.Elements.Ubound < 0 Then Return New RooNothing
		    obj = Owner.Elements(0)
		    Owner.Elements.Remove(0)
		    Return obj
		  End If
		  
		  // Check that `n` is a positive integer.
		  Roo.AssertIsPositiveInteger(where, args(0))
		  dim n as Integer = RooNumber(args(0)).Value
		  
		  // Clear out the array if n = 0.
		  If n = 0 Then
		    tmp = Owner.Elements
		    Redim Owner.Elements(-1)
		    Return New RooArray(tmp)
		  End If
		  
		  If n > Owner.Elements.Ubound + 1 Then
		    // Return all elements of this array as a new array and clear out this array.
		    limit = Owner.Elements.Ubound
		    For i = 0 To limit // Need to do a manual copy.
		      tmp.Append(Owner.Elements(i))
		    Next i
		    Redim Owner.Elements(-1)
		    Return New RooArray(tmp)
		  Else
		    // Get the first `n` elements as a new array.
		    limit = n - 1
		    For i = 0 To limit
		      tmp.Append(Owner.Elements(i))
		    Next i
		    // Now remove these elements from this array.
		    For i = 1 To n
		      Owner.Elements.Remove(0)
		    Next i
		    Return New RooArray(tmp)
		  End If
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function DoSlice(args() As Variant, where As RooToken, destructive As Boolean) As Variant
		  // Wrapper method for the multiple Array.slice() methods.
		  // Either slice(index) or slice(start, length).
		  
		  Roo.AssertIsInteger(where, args(0)) 
		  
		  If args.Ubound = 0 Then
		    Return DoSliceIndex(RooNumber(args(0)).Value, destructive)
		  Else
		    Roo.AssertIsInteger(where, args(1))
		    Return DoSliceStartLength(RooNumber(args(0)).Value, RooNumber(args(1)).Value, destructive)
		  End If
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function DoSliceIndex(index As Integer, destructive As Boolean) As Variant
		  // Array.slice(index as Integer) as Object
		  // Array.slice!(index as Integer) as Object
		  // Negative indices count backwards from the end of the array (-1 is the last element).
		  // Returns the element at the specified index.
		  // slice() leaves this array alone. slice!() additionally removes the returned element from the array.
		  // If `Abs(index > Array.length)` then returns Nothing. Additionally in this scenario, it will NOT affect 
		  // this array if slice!() is called.
		  
		  Dim result As Variant
		  Dim length As Integer = Owner.Elements.Ubound + 1
		  
		  If index >= 0 And index > Owner.Elements.Ubound Then
		    result = New RooNothing
		  ElseIf index < 0 And Abs(index) > length Then
		    result = New RooNothing
		  Else
		    If index < 0 Then
		      result = Owner.Elements(length + index)
		      If destructive Then Owner.Elements.Remove(length + index)
		    Else
		      result = Owner.Elements(index)
		      If destructive Then Owner.Elements.Remove(index)
		    End If
		  End If
		  
		  Return result
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function DoSliceStartLength(start As Integer, length As Integer, destructive As Boolean) As Variant
		  // Array.slice(start as Integer, length as Integer) as Array or Nothing
		  // Array.slice!(start as Integer, length as Integer) as Array or Nothing
		  // If `start` is negative, we count backwards from the end of the array (-1 is the last element).
		  // `length` should be positive or else we return Nothing
		  // Returns a new subarray formed from the elements `start` to `length`.
		  // slice() leaves this array alone. slice!() additionally removes the returned elements from the array.
		  // If `Abs(index > Array.length)` then we return Nothing. Additionally in this scenario, it 
		  // will NOT affect this array if slice!() is called.
		  
		  Dim result(), keep() As Variant
		  Dim finish, i, elementsUbound As Integer
		  
		  elementsUbound = Owner.Elements.Ubound
		  
		  // Edge cases.
		  If elementsUbound < 0 Then Return New RooArray
		  If length = 0 Then Return New RooArray
		  If length < 0 Then Return New RooNothing
		  If start > elementsUbound Then Return New RooNothing
		  If start < 0 And Abs(start) > elementsUbound + 1 Then Return New RooNothing
		  
		  // Calculate the correct start index.
		  If start < 0 Then start = elementsUbound + 1 + start
		  
		  // Calculate the finishing index.
		  finish = If(start + length > elementsUbound + 1, elementsUbound, start + length - 1)
		  
		  // Do the slicing.
		  If destructive Then
		    // We not only need to get the elements to create a new array but we need to remove 
		    // them from this array.
		    For i = 0 To elementsUbound
		      If i >= start And i <= finish Then
		        result.Append(Owner.Elements(i))
		      Else
		        keep.Append(Owner.Elements(i))
		      End If
		    Next i
		    Owner.Elements = keep
		  Else
		    For i = start To finish
		      result.Append(Owner.Elements(i))
		    Next i
		  End If
		  
		  ' Return the sliced elements as a new array.
		  Return New RooArray(result)
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Invoke(interpreter As RooInterpreter, arguments() As Variant, where As RooToken) As Variant
		  // Part of the Invokable interface.
		  
		  Select Case Name
		  Case "contains?"
		    Return DoContains(arguments)
		  Case "delete_at!"
		    Return DoDeleteAt(arguments, where)
		  Case "each"
		    Return DoEach(arguments, where, interpreter)
		  Case "each_index"
		    Return DoEachIndex(arguments, where, interpreter)
		  Case "fetch"
		    Return DoFetch(arguments, where)
		  Case "find"
		    Return DoFind(arguments)
		  Case "first"
		    Return DoFirst(arguments, where, False)
		  Case "first!"
		    Return DoFirst(arguments, where, True)
		  Case "insert!"
		    Return DoInsert(arguments, where)
		  Case "join"
		    Return DoJoin(arguments, where)
		  Case "keep"
		    Return DoKeep(arguments, where, interpreter, False)
		  Case "keep!"
		    Return DoKeep(arguments, where, interpreter, True)
		  Case "last"
		    Return DoLast(arguments, where)
		  Case "map"
		    Return DoMap(arguments, where, interpreter, False)
		  Case "map!"
		    Return DoMap(arguments, where, interpreter, True)
		  Case "push!"
		    Return DoPush(arguments)
		  Case "reject"
		    Return DoReject(arguments, where, interpreter, False)
		  Case "reject!"
		    Return DoReject(arguments, where, interpreter, True)
		  Case "shift!"
		    Return DoShift(arguments, where)
		  Case "slice"
		    Return DoSlice(arguments, where, False)
		  Case "slice!"
		    Return DoSlice(arguments, where, True)
		  End Select
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function StringValue() As String
		  // Part of the Stringable interface.
		  
		  Return "<function " + Name + ">"
		End Function
	#tag EndMethod


	#tag Property, Flags = &h0
		#tag Note
			The name of this Array object method.
		#tag EndNote
		Name As String
	#tag EndProperty

	#tag Property, Flags = &h0
		#tag Note
			The RooArray object that owns this method.
		#tag EndNote
		Owner As RooArray
	#tag EndProperty


	#tag ViewBehavior
		#tag ViewProperty
			Name="Name"
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
