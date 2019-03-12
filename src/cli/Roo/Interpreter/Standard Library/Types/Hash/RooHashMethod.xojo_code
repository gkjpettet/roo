#tag Class
Protected Class RooHashMethod
Implements Invokable, Stringable
	#tag Method, Flags = &h0
		Function Arity() As Variant
		  // Part of the Invokable interface.
		  // Return the arity of this method. This is stored in the cached HashMethods dictionary.
		  
		  Return RooSLCache.HashMethods.Value(Name)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor(owner As RooHash, name As String)
		  Self.Owner = owner
		  Self.Name = name
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function DoDelete(args() As Variant) As Variant
		  // Hash.delete!(key as Object) as Object
		  // Deletes the key-value pair whose key matches `key`. 
		  // If this Hash contains `key` then it is removed and its value is returned. 
		  // If `key` does not exist, it returns Nothing.
		  
		  Dim key As Variant = args(0)
		  Dim value As Variant
		  
		  If key IsA RooText Then
		    key = RooText(key).Value
		  ElseIf key IsA RooNumber Then
		    key = RooNumber(key).Value
		  ElseIf key IsA RooBoolean Then
		    key = RooBoolean(key).Value
		  End If
		  
		  If Not Owner.Dict.HasKey(key) Then Return New RooNothing
		  
		  value = Owner.Dict.Value(key)
		  Call Owner.Dict.Remove(key)
		  Return value
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function DoEach(args() As Variant, where As RooToken, interpreter As RooInterpreter) As RooHash
		  // Hash.each(func as Invokable, optional arguments as Array) as Hash
		  // Invokes the passed function for each key-value pair of this hash, passing to the function the 
		  // key as the first argument and the value as the second argument.
		  // Optionally the method can take a second argument in the form of an Array. The elements of this
		  // Array will be passed to the function as additional arguments.
		  // Returns this hash (unaltered).
		  // E.g: 
		  
		  ' def put(key, value):
		  ' print(key + " is " + value)
		  
		  ' def putPrefix(key, value, prefix):
		  ' print(prefix + key + " is " + value)
		  
		  ' var h = {"a" => 100, "b" => 200}
		  ' h.each(put)
		  ' # Prints:
		  ' # a is 100
		  ' # b is 200
		  
		  ' h.each(putPrefix, ["* "])
		  ' # Prints:
		  ' # * a is 100
		  ' # * b is 200
		  
		  Dim funcArgs() As Variant
		  Dim func As Invokable
		  
		  // Check that `func` is invokable.
		  Roo.AssertIsInvokable(where, args(0))
		  func = args(0)
		  
		  // If a second argument has been passed, check that it's an Array object.
		  If args.Ubound = 1 Then
		    Roo.AssertIsArray(where, args(1))
		    // Get an array of the additional arguments to pass to the function we will invoke.
		    Dim limit As Integer = RooArray(args(1)).Elements.Ubound
		    For i As Integer = 0 To limit
		      funcArgs.Append(RooArray(args(1)).Elements(i))
		    Next i
		  End If
		  
		  // Check that we have the correct number of arguments for `func`.
		  // NB: +3 as we will pass in the key and the value as the first two arguments.
		  If Not Interpreter.CorrectArity(func, funcArgs.Ubound + 3) Then
		    Raise New RooRuntimeError(where, "Incorrect number of arguments passed to the " +_
		    Stringable(func).StringValue + " function.")
		  End If
		  
		  For Each entry As Xojo.Core.DictionaryEntry In Owner.Dict
		    // Inject the value as an argument to `func`.
		    funcArgs.Insert(0, entry.Value)
		    
		    // Inject the key as an argument to `func`. Remember that text, numbers and booleans are stored 
		    // in the backing dictionary as their Xojo values, not runtime representations. We therefore need 
		    // to convert them first.
		    Select Case Roo.AutoType(entry.Key)
		    Case Roo.ObjectType.XojoString, Roo.ObjectType.XojoText
		      funcArgs.Insert(0, New RooText(entry.Key))
		    Case Roo.ObjectType.XojoDouble, Roo.ObjectType.XojoInteger
		      funcArgs.Insert(0, New RooNumber(entry.Key))
		    Case Roo.ObjectType.XojoBoolean
		      funcArgs.Insert(0, New RooBoolean(entry.Key))
		    Else
		      funcArgs.Insert(0, entry.Key)
		    End Select
		    
		    // Invoke the function.
		    Call func.Invoke(interpreter, funcArgs, where)
		    
		    // Remove the key and value from the argument list prior to the next iteration.
		    funcArgs.Remove(0)
		    funcArgs.Remove(0)
		  Next entry
		  
		  // Return this hash.
		  Return Owner
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function DoEachKey(args() As Variant, where As RooToken, interpreter As RooInterpreter) As RooHash
		  // Hash.each_key(func as Invokable, optional arguments as Array) as Hash
		  // Invokes the passed function for each key of this hash, passing to the function the 
		  // key as the first argument.
		  // Optionally the method can take a second argument in the form of an Array. The elements of this
		  // Array will be passed to the function as additional arguments.
		  // Returns this hash (unaltered).
		  
		  Dim funcArgs() As Variant
		  Dim func As Invokable
		  
		  // Check that `func` is invokable.
		  Roo.AssertIsInvokable(where, args(0))
		  func = args(0)
		  
		  // If a second argument has been passed, check that it's an ArrayObject.
		  If args.Ubound = 1 Then
		    Roo.AssertIsArray(where, args(1))
		    // Get an array of the additional arguments to pass to the function we will invoke.
		    Dim limit As Integer = RooArray(args(1)).Elements.Ubound
		    For i As Integer = 0 To limit
		      funcArgs.Append(RooArray(args(1)).Elements(i))
		    Next i
		  End If
		  
		  // Check that we have the correct number of arguments for `func`.
		  // NB: +2 as we will pass in the key as the first argument.
		  If Not Interpreter.CorrectArity(func, funcArgs.Ubound + 2) Then
		    Raise New RooRuntimeError(where, "Incorrect number of arguments passed to the " +_
		    Stringable(func).StringValue + " function.")
		  End If
		  
		  For Each entry As Xojo.Core.DictionaryEntry In Owner.Dict
		    // Inject the key as the first argument to `func`. Remember that text, numbers and 
		    // booleans are stored in the backing dictionary as their Xojo values, not runtime 
		    // representations. We therefore need to convert them first.
		    Select Case Roo.AutoType(entry.Key)
		    Case Roo.ObjectType.XojoString, Roo.ObjectType.XojoText
		      funcArgs.Insert(0, New RooText(entry.Key))
		    Case Roo.ObjectType.XojoDouble, Roo.ObjectType.XojoInteger
		      funcArgs.Insert(0, New RooNumber(entry.Key))
		    Case Roo.ObjectType.XojoBoolean
		      funcArgs.Insert(0, New RooBoolean(entry.Key))
		    Else
		      funcArgs.Insert(0, entry.Key)
		    End Select
		    
		    // Invoke the function.
		    Call func.Invoke(interpreter, funcArgs, where)
		    
		    // Remove the key from the argument list prior to the next iteration.
		    funcArgs.Remove(0)
		  Next entry
		  
		  // Return this hash.
		  Return Owner
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function DoEachValue(args() As Variant, where As RooToken, interpreter As RooInterpreter) As RooHash
		  // Hash.each_value(func as Invokable, optional arguments as Array) as Hash
		  // Invokes the passed function for each value of this hash, passing to the function the 
		  // value as the first argument.
		  // Optionally the method can take a second argument in the form of an Array. The elements of this
		  // Array will be passed to the function as additional arguments.
		  // Returns this hash (unaltered).
		  // E.g: 
		  
		  ' def put(v):
		  ' print("The value is: " + v)
		  
		  ' def putSuffix(v, suffix): 
		  ' print("The value is: " + v + suffix)
		  
		  ' var h = {"a" => 100, "b" => 200}
		  ' h.each_value(put)
		  ' # Prints:
		  ' # The value is 100
		  ' # The value is 200
		  
		  ' h.each_value(putSuffix, [" silly!"])
		  ' # Prints:
		  ' # The value is 100 silly!
		  ' # The value is 200 silly!
		  
		  Dim funcArgs() As Variant
		  Dim func As Invokable
		  
		  // Check that `func` is invokable.
		  Roo.AssertIsInvokable(where, args(0))
		  func = args(0)
		  
		  // If a second argument has been passed, check that it's an ArrayObject.
		  If args.Ubound = 1 Then
		    Roo.AssertIsArray(where, args(1))
		    // Get an array of the additional arguments to pass to the function we will invoke.
		    Dim limit As Integer = RooArray(args(1)).Elements.Ubound
		    For i As Integer = 0 To limit
		      funcArgs.Append(RooArray(args(1)).Elements(i))
		    Next i
		  End If
		  
		  // Check that we have the correct number of arguments for `func`.
		  // NB: +2 as we will pass in the value as the first argument.
		  If Not Interpreter.CorrectArity(func, funcArgs.Ubound + 2) Then
		    Raise New RooRuntimeError(where, "Incorrect number of arguments passed to the " +_
		    Stringable(func).StringValue + " function.")
		  End If
		  
		  For Each entry As Xojo.Core.DictionaryEntry In Owner.Dict
		    // Inject the value as an argument to `func`.
		    funcArgs.Insert(0, entry.Value)
		    
		    // Invoke the function.
		    Call func.Invoke(interpreter, funcArgs, where)
		    
		    // Remove the value from the argument list prior to the next iteration.
		    funcArgs.Remove(0)
		  Next entry
		  
		  // Return this hash.
		  Return Owner
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function DoFetch(args() As Variant) As Variant
		  // Hash.fetch(key as Object, default as Object) as Object
		  // Returns the value for the specified key. If there is no matching key in the Hash 
		  // then `default` is returned.
		  
		  If Owner.HasKey(args(0)) Then
		    Return Owner.GetValue(args(0))
		  Else
		    Return args(1)
		  End If
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function DoFetchValues(args() As Variant, where As RooToken) As RooArray
		  // Hash.fetch_values(keys as Array) as Array
		  // Takes an array of keys and returns an array containing the values of those keys. 
		  // If a key is missing from this Hash then Nothing is substituted in its place.
		  
		  Dim keys() As Variant
		  Dim result As New RooArray
		  Dim i, limit As Integer
		  
		  // Check that the argument passed is an array
		  Roo.AssertIsArray(where, args(0))
		  
		  // Get the keys as a Xojo array.
		  keys = RooArray(args(0)).Elements
		  
		  limit = keys.Ubound
		  For i = 0 To limit
		    If Owner.HasKey(keys(i)) Then
		      result.Elements.Append(Owner.GetValue(keys(i)))
		    Else
		      result.Elements.Append(New RooNothing)
		    End If
		  Next i
		  
		  Return result
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function DoKeep(args() As Variant, where As RooToken, interpreter As RooInterpreter, destructive As Boolean) As RooHash
		  // Hash.keep(func as Invokable, optional arguments as Array) as Hash
		  // Hash.keep!(func as Invokable, optional arguments as Array) as Hash
		  // Invokes `func` for each key-value pair of this hash, passing the key and value to `func` as 
		  // the first two arguments. 
		  // Returns a new Hash consisting of entries for which `func` returns True. 
		  // Essentially the opposite of Hash.reject(). 
		  // If `destructive` = True then the original Hash is mutated.
		  
		  Dim funcArgs(), funcResult As Variant
		  Dim func As Invokable
		  Dim newHash As New RooHash
		  
		  // Check that `func` is invokable.
		  Roo.AssertIsInvokable(where, args(0))
		  func = args(0)
		  
		  // If a second argument has been passed, check that it's an ArrayObject.
		  If args.Ubound = 1 Then
		    Roo.AssertIsArray(where, args(1))
		    // Get an array of the additional arguments to pass to the function we will invoke.
		    Dim limit As Integer = RooArray(args(1)).Elements.Ubound
		    For i As Integer = 0 To limit
		      funcArgs.Append(RooArray(args(1)).Elements(i))
		    Next i
		  End If
		  
		  // Check that we have the correct number of arguments for `func`.
		  // NB: +3 as we will pass in the key and the value as the first two arguments.
		  If Not Interpreter.CorrectArity(func, funcArgs.Ubound + 3) Then
		    Raise New RooRuntimeError(where, "Incorrect number of arguments passed to the " +_
		    Stringable(func).StringValue + " function.")
		  End If
		  
		  For Each entry As Xojo.Core.DictionaryEntry In Owner.Dict
		    // Inject the value as an argument to `func`.
		    funcArgs.Insert(0, entry.Value)
		    
		    // Inject the key as an argument to `func`. Remember that text, numbers and booleans are stored 
		    // in the backing hash dictionary as their Xojo values, not runtime representations. 
		    // We therefore need to convert them first.
		    Select Case Roo.AutoType(entry.Key)
		    Case Roo.ObjectType.XojoString, Roo.ObjectType.XojoText
		      funcArgs.Insert(0, New RooText(entry.Key))
		    Case Roo.ObjectType.XojoDouble, Roo.ObjectType.XojoInteger
		      funcArgs.Insert(0, New RooNumber(entry.Key))
		    Case Roo.ObjectType.XojoBoolean
		      funcArgs.Insert(0, New RooBoolean(entry.Key))
		    Else
		      funcArgs.Insert(0, entry.Key)
		    End Select
		    
		    // Invoke the function. If it returns True then keep this key-value pair in the new hash.
		    funcResult = func.Invoke(interpreter, funcArgs, where)
		    If funcResult IsA RooBoolean And RooBoolean(funcResult).Value = True Then
		      newHash.Dict.Value(entry.Key) = entry.Value
		    End If
		    
		    // Remove the key and value from the argument list prior to the next iteration.
		    funcArgs.Remove(0)
		    funcArgs.Remove(0)
		  Next entry
		  
		  If destructive Then Owner.Dict = newHash.Dict.Clone
		  
		  // Return the new hash.
		  Return newHash
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function DoMerge(args() As Variant, where As RooToken, interpreter As RooInterpreter, destructive As Boolean) As RooHash
		  // Wrapper method for the multiple Hash.merge() methods.
		  
		  // Check the first argument is a hash object.
		  Roo.AssertIsHash(where, args(0))
		  
		  // Hash.merge(other) as Hash
		  If args.Ubound = 0 Then
		    Return DoMergeOther(args(0), destructive)
		  End If
		  
		  // Hash.merge(other, func) as Hash
		  Roo.AssertIsInvokable(where, args(1))
		  Return DoMergeOtherFunc(args(0), args(1), interpreter, where, destructive)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function DoMergeOther(other As RooHash, destructive As Boolean) As RooHash
		  // Hash.merge(other as Hash) as Hash
		  // Hash.merge!(other as Hash) as Hash
		  // Merges the passed `other` Hash with this one. 
		  // The value for entries with duplicate keys will be that of `other` Hash. 
		  // Returns the newly created Hash
		  // If `destructive` = True, then this Hash is mutated.
		  
		  // Create a new Hash and clone this Hash's dictionary into it.
		  Dim newHash As New RooHash
		  newHash.Dict = Owner.Dict.Clone
		  
		  // Merge in the keys from the `other` Hash, overwriting as needed.
		  For Each entry As Xojo.Core.DictionaryEntry In other.Dict
		    newHash.Dict.Value(entry.Key) = entry.Value
		  Next entry
		  
		  // Destructive operation?
		  If destructive Then Owner.Dict = newHash.Dict.Clone
		  
		  Return newHash
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function DoMergeOtherFunc(other As RooHash, func As Invokable, interpreter As RooInterpreter, where As RooToken, destructive As Boolean) As RooHash
		  // Hash.merge(other as Hash, func as Invokable) as Hash
		  // Hash.merge!(other as Hash, func as Invokable) as Hash
		  // Merges the passed `other` Hash with this one. The value for entries with duplicate keys will be 
		  // determined by the return value of `func`
		  // `func` is passed 3 arguments: `key`, `currentValue`, `otherValue`.
		  // Returns the newly created Hash.
		  // If `destructive` = True then this Hash is mutated.
		  
		  // Create a new Hash and clone this Hash's dictionary into it.
		  Dim newHash As New RooHash
		  newHash.Dict = Owner.Dict.Clone
		  
		  Dim funcArgs() As Variant
		  
		  // Merge in the keys from the `other` Hash, invoking `func` as needed.
		  For Each entry As Xojo.Core.DictionaryEntry In other.Dict
		    If newHash.HasKey(entry.Key) Then
		      // Check that we have the correct number of arguments for `func`.
		      If Not Interpreter.CorrectArity(func, 3) Then
		        Raise New RooRuntimeError(where, "The " + Stringable(func).StringValue + _
		        " function must accept 3 arguments (key, value1, value2.")
		      End If
		      
		      // Invoke the passed function, passing in the necessary arguments.
		      Redim funcArgs(-1)
		      funcArgs.Append(entry.Key)
		      funcArgs.Append(Owner.GetValue(entry.Key))
		      funcArgs.Append(entry.Value)
		      newHash.Dict.Value(entry.Key) = func.Invoke(interpreter, funcArgs, where)
		    Else
		      newHash.Dict.Value(entry.Key) = entry.Value
		    End If
		  Next entry
		  
		  // Destructive operation?
		  If destructive Then Owner.Dict = newHash.Dict.Clone
		  
		  Return newHash
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function DoReject(args() As Variant, where As RooToken, interpreter As RooInterpreter, destructive As Boolean) As RooHash
		  // Hash.reject(func as Invokable, optional arguments as Array) as Hash
		  // Hash.reject!(func as Invokable, optional arguments as Array) as Hash
		  // Invokes `func` for each key-value pair of this hash, passing the key and value to `func` as 
		  // the first two arguments. 
		  // Returns a new Hash consisting of entries for which `func` returns False. 
		  // Essentially the opposite of Hash.keep(). 
		  // If `destructive` = True then the original Hash is mutated.
		  
		  Dim funcArgs(), funcResult As Variant
		  Dim func As Invokable
		  Dim newHash As New RooHash
		  
		  // Check that `func` is invokable.
		  Roo.AssertIsInvokable(where, args(0))
		  func = args(0)
		  
		  // If a second argument has been passed, check that it's an Array object.
		  If args.Ubound = 1 Then
		    Roo.AssertIsArray(where, args(1))
		    // Get an array of the additional arguments to pass to the function we will invoke.
		    Dim limit As Integer = RooArray(args(1)).Elements.Ubound
		    For i As Integer = 0 To limit
		      funcArgs.Append(RooArray(args(1)).Elements(i))
		    Next i
		  End If
		  
		  // Check that we have the correct number of arguments for `func`.
		  // NB: +3 as we will pass in the key and the value as the first two arguments.
		  If Not Interpreter.CorrectArity(func, funcArgs.Ubound + 3) Then
		    Raise New RooRuntimeError(where, "Incorrect number of arguments passed to the " +_
		    Stringable(func).StringValue + " function.")
		  End If
		  
		  For Each entry As Xojo.Core.DictionaryEntry In Owner.Dict
		    // Inject the value as an argument to `func`.
		    funcArgs.Insert(0, entry.Value)
		    
		    // Inject the key as an argument to `func`. Remember that text, numbers and booleans are stored 
		    // in the backing hash dictionary as their Xojo values, not runtime representations. 
		    // We therefore need to convert them first.
		    Select Case Roo.AutoType(entry.Key)
		    Case Roo.ObjectType.XojoString, Roo.ObjectType.XojoText
		      funcArgs.Insert(0, New RooText(entry.Key))
		    Case Roo.ObjectType.XojoDouble, Roo.ObjectType.XojoInteger
		      funcArgs.Insert(0, New RooNumber(entry.Key))
		    Case Roo.ObjectType.XojoBoolean
		      funcArgs.Insert(0, New RooBoolean(entry.Key))
		    Else
		      funcArgs.Insert(0, entry.Key)
		    End Select
		    
		    // Invoke the function. If it returns False then keep this key-value pair in the new hash.
		    funcResult = func.Invoke(interpreter, funcArgs, where)
		    If funcResult IsA RooBoolean And RooBoolean(funcResult).Value = False Then
		      newHash.Dict.Value(entry.Key) = entry.Value
		    End If
		    
		    // Remove the key and value from the argument list prior to the next iteration.
		    funcArgs.Remove(0)
		    funcArgs.Remove(0)
		  Next entry
		  
		  If destructive Then Owner.Dict = newHash.Dict.Clone
		  
		  // Return the new hash.
		  Return newHash
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Invoke(interpreter As RooInterpreter, arguments() As Variant, where As RooToken) As Variant
		  // Part of the Invokable interface.
		  
		  Select Case Name
		  Case "delete!"
		    Return DoDelete(arguments)
		  Case "each"
		    Return DoEach(arguments, where, interpreter)
		  Case "each_key"
		    Return DoEachKey(arguments, where, interpreter)
		  Case "each_value"
		    Return DoEachValue(arguments, where, interpreter)
		  Case "fetch"
		    Return DoFetch(arguments)
		  Case "fetch_values"
		    Return DoFetchValues(arguments, where)
		  Case "has_key?"
		    Return New RooBoolean(Owner.HasKey(arguments(0)))
		  Case "has_value?"
		    Return New RooBoolean(Owner.HasValue(arguments(0)))
		  Case "keep"
		    Return DoKeep(arguments, where, interpreter, False)
		  Case "keep!"
		    Return DoKeep(arguments, where, interpreter, True)
		  Case "merge"
		    Return DoMerge(arguments, where, interpreter, False)
		  Case "merge!"
		    Return DoMerge(arguments, where, interpreter, True)
		  Case "reject"
		    Return DoReject(arguments, where, interpreter, False)
		  Case "reject!"
		    Return DoReject(arguments, where, interpreter, True)
		  Case "value"
		    Return Owner.GetValue(arguments(0))
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
			The name of this Text object method.
		#tag EndNote
		Name As String
	#tag EndProperty

	#tag Property, Flags = &h0
		#tag Note
			The RooHash object that owns this method.
		#tag EndNote
		Owner As RooHash
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
