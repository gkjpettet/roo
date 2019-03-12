#tag Class
Protected Class RooArray
Inherits RooInstance
Implements  RooNativeClass
	#tag Method, Flags = &h0
		Function Arity() As Variant
		  // Part of the Invokable interface.
		  
		  Raise New RooRuntimeError(New RooToken, "Cannot invoke an array.")
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor()
		  Constructor(0)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor(size As Integer)
		  Super.Constructor(Nil)
		  
		  If size >= 0 Then Redim Elements(size - 1)
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor(elements() As Variant)
		  Super.Constructor(Nil)
		  
		  Self.Elements = elements
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function DoReverse() As RooArray
		  // Array.reverse! As Array
		  // Reverse the order of this array's elements and return this array.
		  
		  Dim i, limit As Integer
		  Dim tmp() As Variant
		  
		  limit = Elements.Ubound
		  For i = limit DownTo 0
		    tmp.Append(elements(i))
		  Next i
		  
		  Elements = tmp
		  
		  Return Self
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function DoUnique(destructive As Boolean) As RooArray
		  // Array.unique  |  Array.unique!
		  // Returns an array constructed by removing duplicate values in this array. Can be destructive.
		  
		  Const ROO_NOTHING = "@*_*_ROONOTHING_*_*"
		  
		  Dim encounted As Xojo.Core.Dictionary = Roo.CaseSensitiveDictionary
		  Dim i, elementUbound As Integer
		  Dim result() As Variant
		  
		  // Loop through each element. Every time we encounter an element we haven't seen before we add it
		  // to the `encounted` dictionary. The key of the dictionary is the object itself, EXCEPT for Text
		  // objects (where we use the text value), Numbers (we use the numeric value), Boolean objects 
		  // (we use the Boolean value) and Nothing objects (where we use an arbitrary text constant).
		  // Why do we use the value of some objects and not others? Well, obviously two Numbers with the 
		  // value "2.0" should be treated as the same for the purposes of this function but in reality 
		  // are actually two different objects in the runtime.
		  elementUbound = elements.Ubound
		  For i = 0 To elementUbound
		    If elements(i) IsA RooText Then
		      If Not encounted.HasKey(RooText(Elements(i)).Value) Then
		        result.Append(Elements(i))
		        encounted.Value(RooText(Elements(i)).Value) = True
		      End If
		    ElseIf Elements(i) IsA RooNumber Then
		      If Not encounted.HasKey(RooNumber(Elements(i)).Value) Then
		        result.Append(Elements(i))
		        encounted.Value(RooNumber(Elements(i)).Value) = True
		      End If
		    ElseIf Elements(i) IsA RooBoolean Then
		      If Not encounted.HasKey(RooBoolean(Elements(i)).Value) Then
		        result.Append(Elements(i))
		        encounted.Value(RooBoolean(Elements(i)).Value) = True
		      End If
		    ElseIf Elements(i) IsA RooNothing Then
		      If Not encounted.HasKey(ROO_NOTHING) Then
		        result.Append(Elements(i))
		        encounted.Value(ROO_NOTHING) = True
		      End If
		    Else
		      If encounted.HasKey(Elements(i)) = False Then
		        result.Append(Elements(i))
		        encounted.Value(Elements(i)) = True
		      End If
		    End If
		  Next i
		  
		  // Destructive operation?
		  If destructive Then elements = result
		  
		  Return New RooArray(result)
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function GetterWithName(name As RooToken) As Variant
		  // Return the result of the requested getter operation.
		  If StrComp(name.Lexeme, "empty?", 0) = 0 Then
		    // Array.empty? as Integer
		    Return New RooBoolean(If(Elements.Ubound < 0, True, False))
		  ElseIf StrComp(name.Lexeme, "first", 0) = 0 Then
		    If Elements.Ubound < 0 Then
		      Return New RooNothing
		    Else
		      Return Elements(0)
		    End If
		  ElseIf StrComp(name.Lexeme, "length", 0) = 0 Then
		    // Array.length as Integer
		    Return New RooNumber(Elements.Ubound + 1)
		  ElseIf StrComp(name.Lexeme, "pop!", 0) = 0 Then
		    // Array.pop! As Object Or Nothing
		    If Elements.Ubound < 0 Then
		      Return New RooNothing
		    Else
		      Return Elements.Pop
		    End If
		  ElseIf StrComp(name.Lexeme, "reverse!", 0) = 0 Then
		    Return DoReverse
		  ElseIf StrComp(name.Lexeme, "shuffle!", 0) = 0 Then
		    Elements.Shuffle
		    Return Self
		  ElseIf StrComp(name.Lexeme, "unique", 0) = 0 Then
		    Return DoUnique(False)
		  ElseIf StrComp(name.Lexeme, "unique!", 0) = 0 Then
		    Return DoUnique(True)
		  End If
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function HasGetterWithName(name As String) As Boolean
		  // Query the global Roo dictionary of Array object getters for the existence of a getter 
		  // with the passed name.
		  
		  Return RooSLCache.ArrayGetters.HasKey(name)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function HasMethodWithName(name As String) As Boolean
		  // Query the global Roo dictionary of Array object methods for the existence of a method 
		  // with the passed name.
		  
		  Return RooSLCache.ArrayMethods.HasKey(name)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Invoke(interpreter As RooInterpreter, arguments() As Variant, where As RooToken) As Variant
		  // Part of the Invokable interface.
		  
		  #Pragma Unused interpreter
		  #Pragma Unused arguments
		  
		  Raise New RooRuntimeError(where, "Cannot invoke an array.")
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Join(separator As String) As RooText
		  // Internal helper method.
		  // Returns this array as a text object by joining it's elements together with `separator`.
		  // Recurses through subarrays.
		  
		  Dim i, limit As Integer
		  Dim result As String
		  
		  If Elements.Ubound < 0 Then Return New RooText("")
		  
		  limit = Elements.Ubound
		  For i = 0 To limit
		    If Elements(i) IsA RooArray Then // Recurse.
		      result = result + RooArray(Elements(i)).Join(separator).Value + If(i = limit, "", separator)
		    Else
		      result = result + Stringable(Elements(i)).StringValue + if(i = limit, "", separator)
		    End If
		  Next i
		  
		  Return New RooText(result)
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function MethodWithName(name As RooToken) As Invokable
		  // Return a new instance of an Array object method initialised with the name of the method 
		  // being called. That way, when the returned method is invoked, it will know what operation 
		  // to perform.
		  Return New RooArrayMethod(Self, name.Lexeme)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function StringValue() As String
		  // Return a String representation of this array.
		  
		  If Elements.Ubound < 0 Then Return "[]" // Empty array.
		  
		  Dim s, value As String
		  Dim i As Integer
		  Dim d As Double
		  
		  s = "["
		  
		  For a As Integer = 0 To Elements.Ubound
		    If a <> 0 Then s = s + ", "
		    If Elements(a) IsA RooNumber Then
		      d = RooNumber(Elements(a)).Value
		      // Format integers and doubles differently.
		      If Round(d) = d Then // Integer.
		        i = d
		        value = Str(i)
		      Else // Double.
		        value = Str(d)
		      End If
		    ElseIf Elements(a) IsA RooText Then
		      value = """" + Stringable(Elements(a)).StringValue + """"
		    ElseIf Elements(a) IsA Stringable Then
		      value = Stringable(Elements(a)).StringValue
		    Else
		      value = "<No text representation>"
		    End If
		    s = s + value
		  Next a
		  
		  Return s + "]"
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Type() As String
		  Return "Array"
		End Function
	#tag EndMethod


	#tag Property, Flags = &h0
		Elements() As Variant
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
