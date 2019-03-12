#tag Class
Protected Class RooHash
Inherits RooInstance
Implements  RooNativeClass
	#tag Method, Flags = &h0
		Function Arity() As Variant
		  // Part of the Invokable interface.
		  
		  Raise New RooRuntimeError(New RooToken, "Cannot invoke a hash object.")
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor()
		  Super.Constructor(Nil)
		  
		  Self.Dict = Roo.CaseSensitiveDictionary
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor(d As Xojo.Core.Dictionary)
		  // Expects a case-sensitive dictionary. Check.
		  #If DebugBuild
		    If Not Roo.IsCaseSensitive(d) Then
		      Dim err As New TypeMismatchException
		      err.Reason = "A case insensitive dictionary was passed to the RooHash constructor method"
		      Raise err
		    End If
		  #Endif
		  
		  Super.Constructor(Nil)
		  
		  Self.Dict = d
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function DoInvert(destructive As Boolean) As RooHash
		  // Hash.invert as HashObject
		  // Hash.invert! as HashObject
		  // Returns a new hash object created using this hash's values as keys and the keys as values.
		  // If a key with the same value already exists in the hash then the last one encountered 
		  // will be used with earlier values being discarded.
		  
		  Dim newHash As New RooHash
		  Dim newValue, oldValue As Variant
		  
		  For Each entry As Xojo.Core.DictionaryEntry In Dict
		    newValue = entry.Key
		    oldValue = entry.Value
		    
		    // Remember that text, number and boolean keys are stored as literal values, not their runtime 
		    // object representations.
		    If oldValue IsA RooText Then
		      oldValue = RooText(oldValue).Value
		    ElseIf oldValue IsA RooNumber Then 
		      oldValue = RooNumber(oldValue).Value
		    ElseIf oldValue IsA RooBoolean Then 
		      oldValue = RooBoolean(oldValue).Value
		    End If
		    
		    // Similarly, any keys that were stored as literal Xojo values need to be converted to 
		    // a runtime representation when they are stored as values.
		    Select Case Roo.AutoType(newValue)
		    Case Roo.ObjectType.XojoString, Roo.ObjectType.XojoText
		      newValue = New RooText(newValue)
		    Case Roo.ObjectType.XojoDouble, Roo.ObjectType.XojoInteger
		      newValue = New RooNumber(newValue)
		    Case Roo.ObjectType.XojoBoolean
		      newValue = New RooBoolean(newValue)
		    End Select
		    newHash.Dict.Value(oldValue) = newValue
		  Next entry
		  
		  If destructive Then Dict = newHash.Dict.Clone
		  
		  Return newHash
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function DoKeys() As RooArray
		  // Hash.keys as Array
		  // Returns the keys of this hash object as an array object.
		  
		  Dim a As New RooArray
		  
		  For Each entry As Xojo.Core.DictionaryEntry In Dict
		    Select Case Roo.AutoType(entry.Key)
		    Case Roo.ObjectType.XojoString, Roo.ObjectType.XojoText
		      a.Elements.Append(New RooText(entry.Key))
		    Case Roo.ObjectType.XojoDouble, Roo.ObjectType.XojoInteger
		      a.Elements.Append(New RooNumber(entry.Key))
		    Case Roo.ObjectType.XojoBoolean
		      a.Elements.Append(New RooBoolean(entry.Key))
		    Else
		      a.Elements.Append(entry.Key)
		    End Select
		  Next entry
		  
		  Return a
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function DoValues() As RooArray
		  // Hash.values as Array
		  // Returns the values of this hash as an array object.
		  
		  Dim a As New RooArray
		  
		  For Each entry As Xojo.Core.DictionaryEntry In Dict
		    a.Elements.Append(entry.Value)
		  Next entry
		  
		  Return a
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function GetterWithName(name As RooToken) As Variant
		  // Return the result of the requested getter operation.
		  If StrComp(name.Lexeme, "clear!", 0) = 0 Then
		    Dict = Roo.CaseSensitiveDictionary
		    Return Self
		  ElseIf StrComp(name.Lexeme, "invert", 0) = 0 Then
		    Return DoInvert(False)
		  ElseIf StrComp(name.Lexeme, "invert!", 0) = 0 Then
		    Return DoInvert(True)
		  ElseIf StrComp(name.Lexeme, "keys", 0) = 0 Then
		    Return DoKeys
		  ElseIf StrComp(name.Lexeme, "length", 0) = 0 Then
		    Return New RooNumber(Dict.Count)
		  ElseIf StrComp(name.Lexeme, "values", 0) = 0 Then
		    Return DoValues
		  End If
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function GetValue(keyObject as Variant) As Variant
		  // Returns the value of the specified key. If `key` does not exist in this hash then we return Nothing.
		  
		  If Not HasKey(keyObject) Then Return New RooNothing
		  
		  Dim key As Variant
		  
		  // Is this a simple object lookup?
		  If Dict.HasKey(keyObject) Then Return Dict.Value(keyObject)
		  
		  // We have to handle Roo text, number and boolean objects differently.
		  If keyObject IsA RooText Then
		    key = RooText(keyObject).Value
		  ElseIf keyObject IsA RooNumber Then
		    key = RooNumber(keyObject).Value
		  elseIf keyObject IsA RooBoolean Then
		    key = RooBoolean(keyObject).Value
		  End If
		  
		  Return Dict.Value(key)
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function HasGetterWithName(name As String) As Boolean
		  // Query the global Roo dictionary of Hash object getters for the existence of a getter 
		  // with the passed name.
		  
		  Return RooSLCache.HashGetters.HasKey(name)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function HasKey(obj as Variant) As Boolean
		  // Returns True if this hash contains the specified key. 
		  
		  Dim key As Variant
		  
		  If obj = Nil Then Return False
		  
		  // Try a quick object lookup.
		  If Dict.HasKey(obj) Then Return True
		  
		  // Roo text, number and boolean objects are handled differently.
		  If obj IsA RooText Then
		    key = RooText(obj).Value.ToText  // Use Text not String.
		  ElseIf obj IsA RooNumber Then
		    key = RooNumber(obj).Value
		  ElseIf obj IsA RooBoolean Then
		    key = RooBoolean(obj).Value
		  End If
		  
		  Return Dict.HasKey(key)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function HasMethodWithName(name As String) As Boolean
		  // Query the global Roo dictionary of Hash object methods for the existence of a method 
		  // with the passed name.
		  
		  Return RooSLCache.HashMethods.HasKey(name)
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function HasValue(what As Variant) As Boolean
		  // Returns True if this Hash contains the specified value. 
		  
		  For Each entry As Xojo.Core.DictionaryEntry In Dict
		    If entry.Value = what Then Return True
		    
		    If entry.Value IsA RooNothing And what IsA RooNothing Then Return True
		    
		    If what IsA RooText And entry.Value IsA RooText Then
		      If StrComp(RooText(entry.Value).Value, RooText(what).Value, 0) = 0 Then Return True
		    End If
		    
		    If what IsA RooNumber And entry.Value IsA RooNumber Then
		      If RooNumber(entry.Value).Value = RooNumber(what).Value Then Return True
		    End If
		    
		    If what IsA RooBoolean And entry.Value IsA RooBoolean Then
		      If RooBoolean(entry.Value).Value = RooBoolean(what).Value Then Return True
		    End If
		  Next entry
		  
		  Return False
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Invoke(interpreter As RooInterpreter, arguments() As Variant, where As RooToken) As Variant
		  // Part of the Invokable interface.
		  
		  #Pragma Unused interpreter
		  #Pragma Unused arguments
		  
		  Raise New RooRuntimeError(where, "Cannot invoke a hash object.")
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function MethodWithName(name As RooToken) As Invokable
		  // Return a new instance of a Hash object method initialised with the name of the method 
		  // being called. That way, when the returned method is invoked, it will know what operation 
		  // to perform.
		  Return New RooHashMethod(Self, name.Lexeme)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function StringValue() As String
		  Dim k, v, t, QUOTE As String
		  Dim d As Double
		  
		  QUOTE = """"
		  
		  t = "{"
		  
		  For Each entry As Xojo.Core.DictionaryEntry In Self.Dict
		    // Convert the key to a String.
		    Select Case Roo.AutoType(entry.Key)
		    Case Roo.ObjectType.XojoText, Roo.ObjectType.XojoString
		      k = QUOTE + entry.Key + QUOTE
		    Case Roo.ObjectType.XojoDouble
		      If Roo.IsInteger(entry.Key) Then
		        k = Str(Roo.DoubleToInteger(entry.Key))
		      Else
		        d = entry.Key
		        k = Str(d)
		      End If
		    Case Roo.ObjectType.XojoBoolean
		      k = If(entry.Key, "True", "False")
		    Else
		      k = Stringable(entry.Key).StringValue
		    End Select
		    
		    // Convert the value to a String.
		    If entry.Value IsA RooText Then
		      v = QUOTE + RooText(entry.Value).Value + QUOTE
		    ElseIf entry.Value IsA RooNumber Then
		      d = RooNumber(entry.Value).Value
		      If Roo.IsInteger(d) Then
		        v = Str(Roo.DoubleToInteger(d))
		      Else
		        v = Str(d)
		      End If
		    Else
		      v = Stringable(entry.Value).StringValue
		    End If
		    
		    t = t + k + " => " + v + ", "
		  Next entry
		  
		  t = t.Trim
		  
		  If t.Right(1) = "," Then t = t.Left(t.Len - 1)
		  
		  Return t + "}"
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Type() As String
		  Return "Hash"
		End Function
	#tag EndMethod


	#tag Property, Flags = &h0
		Dict As Xojo.Core.Dictionary
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
