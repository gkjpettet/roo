#tag Class
Protected Class RooNumber
Inherits RooInstance
Implements  RooNativeClass
	#tag Method, Flags = &h0
		Function Arity() As Variant
		  // Part of the Invokable interface.
		  
		  Raise New RooRuntimeError(New RooToken, "Cannot invoke the native Number type.")
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor(value As Double)
		  Super.Constructor(Nil)
		  
		  Self.Value = value
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function DoDigits(where As RooToken) As RooArray
		  // Number.digits As Array object.
		  // Returns each digit as a separate element within a array.
		  // Decimal points are ignored.
		  // E.g: 1234 -> [1, 2, 3, 4]
		  // E.g: 0 -> [0]
		  // E.g: 42.5 -> [4, 2, 5]
		  
		  Dim a As New RooArray
		  
		  // Quick zero check.
		  If Value = 0 Then
		    a.Elements.Append(New RooNumber(0))
		    Return a
		  End If
		  
		  // Convert the value to a String then split that into 
		  // its individual characters.
		  Dim s As String = Str(Value, kDoubleFormatString)
		  
		  // Check to see if there is an exponent in the string. If so, this number 
		  // has too many digits in either the integer-part or fractional-part.
		  If s.InStr("e") <> 0 Then
		    Raise New RooRuntimeError(where, "The Number.digits getter only " + _
		    "supports numbers with integer-parts or fractional-parts <= 30 digits. " + _
		    "This number is " + s)
		  End If
		  
		  Dim chars() As String = s.Split("")
		  For i As Integer = 0 To chars.Ubound
		    If chars(i) <> "." And chars(i) <> "-" Then // Ignore decimal points and minus signs.
		      a.Elements.Append(New RooNumber(Val(chars(i))))
		    End If
		  Next i
		  
		  Return a
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function Even() As Boolean
		  // Returns True if this number object is an even integer.
		  
		  If Not Roo.IsInteger(Value) Then Return False
		  
		  Return If(Value Mod 2 = 0, True, False)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function GetterWithName(name As RooToken) As Variant
		  // Return the result of the requested getter operation.
		  If StrComp(name.Lexeme, "abs", 0) = 0 Then
		    Return New RooNumber(Abs(Value))
		  ElseIf StrComp(name.Lexeme, "acos", 0) = 0 Then
		    Return New RooNumber(ACos(Value))
		  ElseIf StrComp(name.Lexeme, "asin", 0) = 0 Then
		    Return New RooNumber(ASin(Value))
		  ElseIf StrComp(name.Lexeme, "atan", 0) = 0 Then
		    Return New RooNumber(ATan(Value))
		  ElseIf StrComp(name.Lexeme, "ceil", 0) = 0 Then
		    Return New RooNumber(Ceil(Value))
		  ElseIf StrComp(name.Lexeme, "cos", 0) = 0 Then
		    Return New RooNumber(Cos(Value))
		  ElseIf StrComp(name.Lexeme, "digits", 0) = 0 Then
		    Return DoDigits(name)
		  ElseIf StrComp(name.Lexeme, "even?", 0) = 0 Then
		    Return New RooBoolean(Even)
		  ElseIf StrComp(name.Lexeme, "floor", 0) = 0 Then
		    Return New RooNumber(Floor(Value))
		  ElseIf StrComp(name.Lexeme, "integer?", 0) = 0 Then
		    Return New RooBoolean(Roo.IsInteger(Value))
		  ElseIf StrComp(name.Lexeme, "odd?", 0) = 0 Then
		    Return New RooBoolean(Odd)
		  ElseIf StrComp(name.Lexeme, "round", 0) = 0 Then
		    Return New RooNumber(Round(Value))
		  ElseIf StrComp(name.Lexeme, "sign", 0) = 0 Then
		    Return New RooNumber(Sign(Value))
		  ElseIf StrComp(name.Lexeme, "sin", 0) = 0 Then
		    Return New RooNumber(Sin(Value))
		  ElseIf StrComp(name.Lexeme, "sqrt", 0) = 0 Then
		    Return New RooNumber(Sqrt(Value))
		  ElseIf StrComp(name.Lexeme, "tan", 0) = 0 Then
		    Return New RooNumber(Tan(Value))
		  ElseIf StrComp(name.Lexeme, "to_degrees", 0) = 0 Then
		    Return New RooNumber(Value * 57.295779513) // 57.295779513 is 180/π
		  ElseIf StrComp(name.Lexeme, "to_radians", 0) = 0 Then
		    Return New RooNumber(Value / 57.295779513) // 57.295779513 is 180/π
		  End If
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function HasGetterWithName(name As String) As Boolean
		  // Query the global Roo dictionary of Number object getters for the existence of a getter 
		  // with the passed name.
		  
		  Return RooSLCache.NumberGetters.HasKey(name)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function HasMethodWithName(name As String) As Boolean
		  // Query the global Roo dictionary of Number object methods for the existence of a method 
		  // with the passed name.
		  
		  Return RooSLCache.NumberMethods.HasKey(name)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Invoke(interpreter As RooInterpreter, arguments() As Variant, where As RooToken) As Variant
		  // Part of the Invokable interface.
		  
		  #Pragma Unused interpreter
		  #Pragma Unused arguments
		  
		  Raise New RooRuntimeError(where, "Cannot invoke the native Number type.")
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function MethodWithName(name As RooToken) As Invokable
		  // Return a new instance of a Number object method initialised with the name of the method 
		  // being called. That way, when the returned method is invoked, it will know what operation 
		  // to perform.
		  Return New RooNumberMethod(Self, name.Lexeme)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function Odd() As Boolean
		  // Returns True if this number object is an odd integer.
		  
		  If Not Roo.IsInteger(Value) Then Return False
		  
		  Return If(Value Mod 2 = 0, False, True)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function StringValue() As String
		  If Roo.IsInteger(Self.Value) Then
		    Dim i As Integer = Self.Value
		    Return Str(i, kIntegerFormatString)
		  Else
		    Dim tmp As String = Str(Self.Value)
		    If tmp.InStr("e") = 0 Then
		      Return tmp
		    Else
		      // Only format high precision doubles
		      Return Str(Self.Value, kDoubleFormatString)
		    End If
		  End If
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Type() As String
		  Return "Number"
		End Function
	#tag EndMethod


	#tag Note, Name = About
		The Number.digits, Number.each_digit(), Number.starts_with?() and Number.ends_with?() 
		only work correctly with integer-parts and fractional_parts that are <= 30 digits long.
		This due to how Xojo's Built-in Str() function works. I have elected to hard code this 
		value in the Str format String (RooNumber.kDoubleFormatString).
		
	#tag EndNote


	#tag Property, Flags = &h0
		Value As Double
	#tag EndProperty


	#tag Constant, Name = kDoubleFormatString, Type = String, Dynamic = False, Default = \"-##############################.##############################", Scope = Public
	#tag EndConstant

	#tag Constant, Name = kIntegerFormatString, Type = String, Dynamic = False, Default = \"-##############################", Scope = Public
	#tag EndConstant


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
		#tag ViewProperty
			Name="Value"
			Group="Behavior"
			Type="Double"
		#tag EndViewProperty
	#tag EndViewBehavior
End Class
#tag EndClass
