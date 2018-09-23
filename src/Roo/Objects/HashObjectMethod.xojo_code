#tag Class
Protected Class HashObjectMethod
Implements Roo.Invokable,Roo.Textable
	#tag Method, Flags = &h0
		Function Arity() As Variant
		  select case self.name
		  case "delete!"
		    return 1
		  case "each"
		    return Array(1, 2)
		  case "each_key"
		    return Array(1, 2)
		  case "each_value"
		    return Array(1, 2)
		  case "fetch"
		    return 2
		  case "fetch_values"
		    return 1
		  case "has_key?"
		    return 1
		  case "has_value?"
		    return 1
		  case "keep", "keep!"
		    return Array(1, 2)
		  case "merge", "merge!"
		    return Array(1, 2)
		  case "reject", "reject!"
		    return Array(1, 2)
		  case "responds_to?"
		    return 1
		  Case "value"
		    Return 1
		  end select
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor(parent as HashObject, name as String)
		  self.parent = parent
		  self.name = name
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function DoDelete(args() as Variant) As Variant
		  ' Hash.delete!(key as Object) as Object
		  ' Deletes the key-value pair whose key matches `key`. 
		  ' If this Hash contains `key` then it is removed and its value is returned. 
		  ' If `key` does not exist, it returns Nothing.
		  
		  dim key as Variant = args(0)
		  dim value as Variant
		  
		  if key isA TextObject then
		    key = TextObject(key).value
		  elseif key isA NumberObject then
		    key = NumberObject(key).value
		  elseif key isA BooleanObject then
		    key = BooleanObject(key).value
		  end if
		  
		  if not parent.map.hasKey(key) then return new NothingObject
		  
		  value = parent.map.Value(key)
		  call parent.map.Remove(key)
		  return value
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function DoEach(args() as Variant, where as Token, interpreter as Interpreter) As HashObject
		  ' Hash.each(func as Invokable, optional arguments as Array) as Hash
		  ' Invokes the passed function for each key-value pair of this hash, passing to the function the 
		  ' key as the first argument and the value as the second argument.
		  ' Optionally the method can take a second argument in the form of an Array. The elements of this
		  ' Array will be passed to the function as additional arguments.
		  ' Returns this hash (unaltered).
		  ' E.g: 
		  
		  ' function put(key, value) {
		  '   print(key + " is " + value);
		  ' }
		  '
		  ' function putPrefix(key, value, prefix) {
		  '   print(prefix + key + " is " + value);
		  ' }
		  '
		  ' var h = {"a" => 100, "b" => 200};
		  ' h.each(put);
		  ' # Prints:
		  ' # a is 100
		  ' # b is 200
		  '
		  ' h.each(putPrefix, ["* "]);
		  ' # Prints:
		  ' # * a is 100
		  ' # * b is 200
		  
		  dim funcArgs() as Variant
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
		  ' +3 as we will pass in the key and the value as the first two arguments.
		  if not Interpreter.CorrectArity(func, funcArgs.Ubound + 3) then
		    raise new RuntimeError(where, "Incorrect number of arguments passed to the " +_
		    Textable(func).ToText + " function.")
		  end if
		  
		  dim i as VariantToVariantHashMapIteratorMBS = parent.map.first
		  dim e as VariantToVariantHashMapIteratorMBS = parent.map.last
		  
		  while i.isNotEqual(e)
		    ' Inject the value as an argument to `func`.
		    funcArgs.Insert(0, i.Value)
		    
		    ' Inject the key as an argument to `func`. Remember that text, numbers and booleans are stored 
		    ' in the backing hash map as their Xojo values, not runtime representations. We therefore need 
		    ' to convert them first.
		    if i.Key.Type = Variant.TypeString then
		      funcArgs.Insert(0, new TextObject(i.Key))
		    elseif i.Key.Type = Variant.TypeDouble then
		      funcArgs.Insert(0, new NumberObject(i.Key))
		    elseif i.Key.Type = Variant.TypeBoolean then
		      funcArgs.Insert(0, new BooleanObject(i.Key))
		    else
		      funcArgs.Insert(0, i.Key)
		    end if
		    
		    ' Invoke the function.
		    call func.Invoke(interpreter, funcArgs, where)
		    
		    ' Remove the key and value from the argument list prior to the next iteration.
		    funcArgs.Remove(0)
		    funcArgs.Remove(0)
		    
		    i.MoveNext()
		  wend
		  
		  ' Return this hash.
		  return parent
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function DoEachKey(args() as Variant, where as Token, interpreter as Interpreter) As HashObject
		  ' Hash.each_key(func as Invokable, optional arguments as Array) as Hash
		  ' Invokes the passed function for each key of this hash, passing to the function the 
		  ' key as the first argument.
		  ' Optionally the method can take a second argument in the form of an Array. The elements of this
		  ' Array will be passed to the function as additional arguments.
		  ' Returns this hash (unaltered).
		  ' E.g: 
		  
		  ' function put(key) {
		  ' print("The key is: " + key);
		  ' }
		  ' 
		  ' function putSuffix(key, suffix) {
		  ' print("The key is: " + key + suffix);
		  ' }
		  ' 
		  ' var h = {"a" => 100, "b" => 200};
		  ' h.each_key(put);
		  ' # Prints:
		  ' # The key is a
		  ' # The key is b
		  ' 
		  ' h.each_key(putSuffix, [" silly!"]);
		  ' # Prints:
		  ' # The key is a silly!
		  ' # The key is b silly!
		  
		  dim funcArgs() as Variant
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
		  ' +2 as we will pass in the key as the first argument.
		  if not Interpreter.CorrectArity(func, funcArgs.Ubound + 2) then
		    raise new RuntimeError(where, "Incorrect number of arguments passed to the " +_
		    Textable(func).ToText + " function.")
		  end if
		  
		  dim i as VariantToVariantHashMapIteratorMBS = parent.map.first
		  dim e as VariantToVariantHashMapIteratorMBS = parent.map.last
		  
		  while i.isNotEqual(e)
		    
		    ' Inject the key as the first argument to `func`. Remember that text, numbers and booleans are stored 
		    ' in the backing hash map as their Xojo values, not runtime representations. We therefore need 
		    ' to convert them first.
		    if i.Key.Type = Variant.TypeString then
		      funcArgs.Insert(0, new TextObject(i.Key))
		    elseif i.Key.Type = Variant.TypeDouble then
		      funcArgs.Insert(0, new NumberObject(i.Key))
		    elseif i.Key.Type = Variant.TypeBoolean then
		      funcArgs.Insert(0, new BooleanObject(i.Key))
		    else
		      funcArgs.Insert(0, i.Key)
		    end if
		    
		    ' Invoke the function.
		    call func.Invoke(interpreter, funcArgs, where)
		    
		    ' Remove the key from the argument list prior to the next iteration.
		    funcArgs.Remove(0)
		    
		    i.MoveNext()
		  wend
		  
		  ' Return this hash.
		  return parent
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function DoEachValue(args() as Variant, where as Token, interpreter as Interpreter) As HashObject
		  ' Hash.each_value(func as Invokable, optional arguments as Array) as Hash
		  ' Invokes the passed function for each value of this hash, passing to the function the 
		  ' value as the first argument.
		  ' Optionally the method can take a second argument in the form of an Array. The elements of this
		  ' Array will be passed to the function as additional arguments.
		  ' Returns this hash (unaltered).
		  ' E.g: 
		  
		  ' function put(v) {
		  ' print("The value is: " + v);
		  ' }
		  ' 
		  ' function putSuffix(v, suffix) {
		  ' print("The value is: " + v + suffix);
		  ' }
		  ' 
		  ' var h = {"a" => 100, "b" => 200};
		  ' h.each_value(put);
		  ' # Prints:
		  ' # The value is 100
		  ' # The value is 200
		  ' 
		  ' h.each_value(putSuffix, [" silly!"]);
		  ' # Prints:
		  ' # The value is 100 silly!
		  ' # The value is 200 silly!
		  
		  dim funcArgs() as Variant
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
		  ' +2 as we will pass in the value as the first argument.
		  if not Interpreter.CorrectArity(func, funcArgs.Ubound + 2) then
		    raise new RuntimeError(where, "Incorrect number of arguments passed to the " +_
		    Textable(func).ToText + " function.")
		  end if
		  
		  dim i as VariantToVariantHashMapIteratorMBS = parent.map.first
		  dim e as VariantToVariantHashMapIteratorMBS = parent.map.last
		  
		  while i.isNotEqual(e)
		    ' Inject the value as an argument to `func`.
		    funcArgs.Insert(0, i.Value)
		    
		    ' Invoke the function.
		    call func.Invoke(interpreter, funcArgs, where)
		    
		    ' Remove the value from the argument list prior to the next iteration.
		    funcArgs.Remove(0)
		    
		    i.MoveNext()
		  wend
		  
		  ' Return this hash.
		  return parent
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function DoFetch(args() as Variant) As Variant
		  ' Hash.fetch(key as Object, default as Object) as Object
		  ' Returns the value for the specified key. If there is no matching key in the Hash 
		  ' then `default` is returned.
		  
		  if parent.HasKey(args(0)) then
		    return parent.GetValue(args(0))
		  else
		    return args(1)
		  end if
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function DoFetchValues(args() as Variant, where as Token) As ArrayObject
		  ' Hash.fetch_values(keys as Array) as Array
		  ' Takes an array of keys and returns an array containing the values of those keys. 
		  ' If a key is missing from this Hash then Nothing is substituted in its place.
		  
		  dim keys() as Variant
		  dim result as new ArrayObject
		  dim i, limit as Integer
		  
		  ' Check that the argument passed is an array
		  if not args(0) isA ArrayObject then
		    raise new RuntimeError(where, "The " + self.name + "(keys) method expects an array parameter. " + _
		    "Instead got " + VariantType(args(0)) + ".")
		  else
		    ' Get the keys as a Xojo array
		    keys = ArrayObject(args(0)).elements
		  end if
		  
		  limit = keys.Ubound
		  for i = 0 to limit
		    if parent.HasKey(keys(i)) then
		      result.elements.Append(parent.GetValue(keys(i)))
		    else
		      result.elements.Append(new NothingObject)
		    end if
		  next i
		  
		  return result
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function DoKeep(args() as Variant, where as Token, interpreter as Interpreter, destructive as Boolean) As HashObject
		  ' Hash.keep(func as Invokable, optional arguments as Array) as Hash
		  ' Hash.keep!(func as Invokable, optional arguments as Array) as Hash
		  ' Invokes `func` for each key-value pair of this hash, passing the key and value to `func` as 
		  ' the first two arguments. 
		  ' Returns a new Hash consisting of entries for which `func` returns True. 
		  ' Essentially the opposite of Hash.reject(). 
		  ' If `destructive` = True then the original Hash is mutated.
		  
		  dim funcArgs(), funcResult as Variant
		  dim func as Invokable
		  dim newHash as new HashObject
		  
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
		  ' +3 as we will pass in the key and the value as the first two arguments.
		  if not Interpreter.CorrectArity(func, funcArgs.Ubound + 3) then
		    raise new RuntimeError(where, "Incorrect number of arguments passed to the " +_
		    Textable(func).ToText + " function.")
		  end if
		  
		  dim i as VariantToVariantHashMapIteratorMBS = parent.map.first
		  dim e as VariantToVariantHashMapIteratorMBS = parent.map.last
		  
		  while i.isNotEqual(e)
		    ' Inject the value as an argument to `func`.
		    funcArgs.Insert(0, i.Value)
		    
		    ' Inject the key as an argument to `func`. Remember that text, numbers and booleans are stored 
		    ' in the backing hash map as their Xojo values, not runtime representations. We therefore need 
		    ' to convert them first.
		    if i.Key.Type = Variant.TypeString then
		      funcArgs.Insert(0, new TextObject(i.Key))
		    elseif i.Key.Type = Variant.TypeDouble then
		      funcArgs.Insert(0, new NumberObject(i.Key))
		    elseif i.Key.Type = Variant.TypeBoolean then
		      funcArgs.Insert(0, new BooleanObject(i.Key))
		    else
		      funcArgs.Insert(0, i.Key)
		    end if
		    
		    ' Invoke the function. If it returns True then keep this key-value pair in the new hash.
		    funcResult = func.Invoke(interpreter, funcArgs, where)
		    if funcResult isA BooleanObject and BooleanObject(funcResult).value = True then
		      newHash.map.Value(i.Key) = i.Value
		    end if
		    
		    ' Remove the key and value from the argument list prior to the next iteration.
		    funcArgs.Remove(0)
		    funcArgs.Remove(0)
		    
		    i.MoveNext()
		  wend
		  
		  if destructive then parent.map = newHash.map.Clone()
		  
		  ' Return the new hash.
		  return newHash
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function DoMerge(args() as Variant, where as Token, interpreter as Interpreter, destructive as Boolean) As HashObject
		  ' Wrapper method for the multiple Hash.merge() methods.
		  
		  if args.Ubound = 0 then ' Hash.merge(other) as Hash
		    if not args(0) isA HashObject then
		      raise new RuntimeError(where, "The " + self.name + "(other) method expects a Hash parameter. " + _
		      "Instead got " + VariantType(args(0)) + ".")
		    else
		      return DoMergeOther(args(0), destructive)
		    end if
		  end if
		  
		  ' Hash.merge(other, func) as Hash
		  if not args(0) isA HashObject then
		    raise new RuntimeError(where, "The " + self.name + "(other, func) method expects the first " + _
		    "parameter to be a Hash object. Instead got " + VariantType(args(0)) + ".")
		  end if
		  if not args(1) isA Invokable then
		    raise new RuntimeError(where, "The " + self.name + "(other, func) method expects the second " + _
		    "parameter to be an invokable object. Instead got " + VariantType(args(0)) + ".")
		  end if
		  
		  return DoMergeOtherFunc(args(0), args(1), interpreter, where, destructive)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function DoMergeOther(other as HashObject, destructive as Boolean) As HashObject
		  ' Hash.merge(other as Hash) as Hash
		  ' Hash.merge!(other as Hash) as Hash
		  ' Merges the passed `other` Hash with this one. 
		  ' The value for entries with duplicate keys will be that of `other` Hash. 
		  ' Returns the newly created Hash
		  ' If `destructive` = True, then this Hash is mutated.
		  
		  ' Create a new Hash and clone this Hash's dictionary into it.
		  dim newHash as new HashObject
		  newHash.map = parent.map.Clone()
		  
		  ' Merge in the keys from the `other` Hash, overwriting as needed.
		  dim i as VariantToVariantHashMapIteratorMBS = other.map.first
		  dim e as VariantToVariantHashMapIteratorMBS = other.map.last
		  
		  while i.isNotEqual(e)
		    newHash.map.Value(i.Key) = i.Value
		    i.MoveNext()
		  wend
		  
		  ' Destructive operation?
		  if destructive then parent.map = newHash.map.Clone()
		  
		  return newHash
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function DoMergeOtherFunc(other as HashObject, func as Invokable, interpreter as Interpreter, where as Token, destructive as Boolean) As HashObject
		  ' Hash.merge(other as Hash, func as Invokable) as Hash
		  ' Hash.merge!(other as Hash, func as Invokable) as Hash
		  ' Merges the passed `other` Hash with this one. The value for entries with duplicate keys will be 
		  ' determined by the return value of `func`
		  ' `func` is passed 3 arguments: `key`, `currentValue`, `otherValue`.
		  ' Returns the newly created Hash.
		  ' If `destructive` = True then this Hash is mutated.
		  
		  ' Create a new Hash and clone this Hash's dictionary into it.
		  dim newHash as new HashObject
		  newHash.map = parent.map.Clone()
		  
		  dim funcArgs() as Variant
		  
		  ' Merge in the keys from the `other` Hash, invoking `func` as needed.
		  dim i as VariantToVariantHashMapIteratorMBS = other.map.first
		  dim e as VariantToVariantHashMapIteratorMBS = other.map.last
		  
		  while i.isNotEqual(e)
		    if newHash.HasKey(i.Key) then
		      ' Check that we have the correct number of arguments for `func`.
		      if not Interpreter.CorrectArity(func, 3) then
		        raise new RuntimeError(where, "The " + Textable(func).ToText + " function must accept 3 " + _
		        "arguments (key, value1, value2.")
		      end if
		      ' Invoke the passed function, passing in the necessary arguments.
		      funcArgs = Array(i.Key, parent.GetValue(i.Key), i.Value)
		      newHash.map.Value(i.Key) = func.Invoke(interpreter, funcArgs, where)
		    else
		      newHash.map.Value(i.Key) = i.Value
		    end if
		    i.MoveNext()
		  wend
		  
		  ' Destructive operation?
		  if destructive then parent.map = newHash.map.Clone()
		  
		  return newHash
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function DoReject(args() as Variant, where as Token, interpreter as Interpreter, destructive as Boolean) As HashObject
		  ' Hash.reject(func as Invokable, optional arguments as Array) as Hash
		  ' Hash.reject!(func as Invokable, optional arguments as Array) as Hash
		  ' Invokes `func` for each key-value pair of this hash, passing the key and value to `func` as 
		  ' the first two arguments. 
		  ' Returns a new Hash consisting of entries for which `func` returns False. 
		  ' Essentially the opposite of Hash.keep(). 
		  ' If `destructive` = True then the original Hash is mutated.
		  
		  dim funcArgs(), funcResult as Variant
		  dim func as Invokable
		  dim newHash as new HashObject
		  
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
		  ' +3 as we will pass in the key and the value as the first two arguments.
		  if not Interpreter.CorrectArity(func, funcArgs.Ubound + 3) then
		    raise new RuntimeError(where, "Incorrect number of arguments passed to the " +_
		    Textable(func).ToText + " function.")
		  end if
		  
		  dim i as VariantToVariantHashMapIteratorMBS = parent.map.first
		  dim e as VariantToVariantHashMapIteratorMBS = parent.map.last
		  
		  while i.isNotEqual(e)
		    ' Inject the value as an argument to `func`.
		    funcArgs.Insert(0, i.Value)
		    
		    ' Inject the key as an argument to `func`. Remember that text, numbers and booleans are stored 
		    ' in the backing hash map as their Xojo values, not runtime representations. We therefore need 
		    ' to convert them first.
		    if i.Key.Type = Variant.TypeString then
		      funcArgs.Insert(0, new TextObject(i.Key))
		    elseif i.Key.Type = Variant.TypeDouble then
		      funcArgs.Insert(0, new NumberObject(i.Key))
		    elseif i.Key.Type = Variant.TypeBoolean then
		      funcArgs.Insert(0, new BooleanObject(i.Key))
		    else
		      funcArgs.Insert(0, i.Key)
		    end if
		    
		    ' Invoke the function. If it returns False then keep this key-value pair in the new hash.
		    funcResult = func.Invoke(interpreter, funcArgs, where)
		    if funcResult isA BooleanObject and BooleanObject(funcResult).value = False then
		      newHash.map.Value(i.Key) = i.Value
		    end if
		    
		    ' Remove the key and value from the argument list prior to the next iteration.
		    funcArgs.Remove(0)
		    funcArgs.Remove(0)
		    
		    i.MoveNext()
		  wend
		  
		  if destructive then parent.map = newHash.map.Clone()
		  
		  ' Return the new hash.
		  return newHash
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function DoRespondsTo(arguments() as Variant, where as Token) As BooleanObject
		  ' Hash.responds_to?(what as Text) as Boolean.
		  
		  ' Make sure a Text argument is passed to the method.
		  if not arguments(0) isA TextObject then
		    raise new RuntimeError(where, "The " + self.name + "(what) method expects an integer parameter. " + _
		    "Instead got " + VariantType(arguments(0)) + ".")
		  end if
		  
		  dim what as String = TextObject(arguments(0)).value
		  
		  if Lookup.HashGetter(what) then
		    return new BooleanObject(True)
		  elseif Lookup.HashMethod(what) then
		    return new BooleanObject(True)
		  else
		    return new BooleanObject(False)
		  end if
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Invoke(interpreter as Interpreter, arguments() as Variant, where as Token) As Variant
		  #pragma Unused arguments
		  #pragma Unused interpreter
		  #pragma Unused where
		  
		  select case self.name
		  case "delete!"
		    return DoDelete(arguments)
		  case "each"
		    return DoEach(arguments, where, interpreter)
		  case "each_key"
		    return DoEachKey(arguments, where, interpreter)
		  case "each_value"
		    return DoEachValue(arguments, where, interpreter)
		  case "fetch"
		    return DoFetch(arguments)
		  case "fetch_values"
		    return DoFetchValues(arguments, where)
		  case "has_key?"
		    return new BooleanObject(parent.HasKey(arguments(0)))
		  case "has_value?"
		    return new BooleanObject(parent.HasValue(arguments(0)))
		  case "keep"
		    return DoKeep(arguments, where, interpreter, False)
		  case "keep!"
		    return DoKeep(arguments, where, interpreter, True)
		  case "merge"
		    return DoMerge(arguments, where, interpreter, False)
		  case "merge!"
		    return DoMerge(arguments, where, interpreter, True)
		  case "reject"
		    return DoReject(arguments, where, interpreter, False)
		  case "reject!"
		    return DoReject(arguments, where, interpreter, True)
		  case "responds_to?"
		    return DoRespondsTo(arguments, where)
		  Case "value"
		    Return Parent.GetValue(arguments(0))
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
		parent As HashObject
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
