#tag Class
Protected Class RooText
Inherits RooInstance
Implements  RooNativeClass,  Dateable
	#tag Method, Flags = &h0
		Function Arity() As Variant
		  // Part of the Invokable interface.
		  
		  Raise New RooRuntimeError(New RooToken, "Cannot invoke the native Text type.")
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor(value As String)
		  Super.Constructor(Nil)
		  
		  Self.Value = value
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function DateValue() As Xojo.Core.Date
		  // Part of the Dateable interface.
		  // If possible, convert this Text object to a Xojo.Core.Date.
		  // Roo Text is considered to be a date if it is in one of the following two formats:
		  // YYYY-MM-DD HH:MM or YYYY-MM-DD
		  // If not possible, return Nil.
		  
		  Try
		    Return Xojo.Core.Date.FromText(Value.ToText)
		  Catch err
		    Return Nil
		  End Try
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function DoChars() As RooArray
		  // Text.chars As Array
		  // Converts this Text object's value to its constituent characters and returns them as a 
		  // new RooArray.
		  
		  Dim chars() As String
		  Dim a As New RooArray
		  Dim i, limit as Integer
		  
		  chars = Value.Split("")
		  limit = chars.Ubound
		  For i = 0 To limit
		    // Each character needs to be converted to a Roo Text object NOT left as a Xojo String!
		    a.Elements.Append(New RooText(chars(i)))
		  Next i
		  
		  Return a
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function DoDefineUTF8(destructive As Boolean) As Variant
		  // Text.define_utf8  |  Text.define_utf8!
		  // Returns a new Text object where the value is defined as being UTF-8 encoded.
		  // If `destructive` is True then we also mutate the original value.
		  // If Xojo is unable to define the encoding as UTF-8 then we return Nothing.
		  
		  Dim result As String
		  Try
		    result = DefineEncoding(Value, Encodings.UTF8)
		  Catch
		    Return New RooNothing
		  End Try
		  
		  Value = If(destructive, result, Value)
		  
		  Return New RooText(result)
		  
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function DoReverse(destructive as Boolean) As RooText
		  // Text.reverse As Text |  Text.reverse! As Text
		  // Returns a new Text object where the value has been reversed. 
		  // If `destructive` is True then we also mutate the original value.
		  
		  If Len(Value) < 2 Then Return New RooText(Value)
		  
		  Dim characters() As String = Split(Value, "")
		  Dim leftIndex as Integer = 0
		  Dim rightIndex as Integer = UBound(characters)
		  
		  #Pragma BackgroundTasks False
		  Dim temp As String
		  While leftIndex < rightIndex
		    temp = characters(leftIndex)
		    characters(leftIndex) = characters(rightIndex)
		    characters(rightIndex) = temp
		    leftIndex = leftIndex + 1
		    rightIndex = rightIndex - 1
		  Wend
		  temp = Join( characters, "" )
		  
		  // Alter this object's value too?
		  Value = If(destructive, temp, Value)
		  
		  Return New RooText(temp)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function DoSwapCase(destructive as Boolean) As RooText
		  // Text.swapcase  | Text.swapcase!
		  // Returns a new Text object where the case of each character has been swapped.
		  // If destructive then we will also mutate this Text object's value.
		  
		  Dim chars() As String = Value.Split("")
		  Dim result, tmp() As String
		  Dim i, limit, codePoint As Integer
		  
		  Redim tmp(Value.Len - 1)
		  limit = chars.Ubound
		  #Pragma BackgroundTasks False
		  For i = 0 To limit
		    codePoint = Asc(chars(i))
		    Select Case codePoint
		    Case 65 To 90 // Uppercase ASCII character. Add 32 to make it lowercase.
		      tmp(i) = Chr(codePoint + 32)
		    Case 97 To 122 // Lowercase ASCII character. Subtract 32 to make it uppercase.
		      tmp(i) = Chr(codePoint - 32)
		    Else // Leave it alone.
		      tmp(i) = chars(i)
		    End Select
		  Next i
		  result = Join(tmp, "")
		  
		  Value = If(destructive, result, value)
		  
		  Return New RooText(result)
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function DoToDate() As Variant
		  // Text.to_date as DateTime or Nothing
		  // If this Text object is in one of the following two formats:
		  // YYYY-MM-DD HH:MM
		  // YYYY-MM-DD
		  // Then this method returns a new DateTime object instantiated to that date and time. If not it 
		  // returns Nothing.
		  
		  Dim d As Xojo.Core.Date = DateValue
		  If d = Nil Then
		    Return New RooNothing
		  Else
		    Return New RooDateTime(d)
		  End If
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function DoToNumber() As RooNumber
		  // Text.to_number As Number object
		  // Convert this Text object to a Number object.
		  
		  // Prefixed number?
		  If Value.Left(2) = "0x" And Value.Len > 2 Then
		    Dim chars() As String = Value.Split("")
		    Call chars.Remove(0) // Remove "0"
		    Call chars.Remove(0) // Remove "x"
		    For i As Integer = 0 To chars.Ubound
		      If Not IsHexadecimal(chars(i)) Then Return New RooNumber(0)
		    Next i
		    Return New RooNumber(Integer.FromHex(Join(chars, "").ToText))
		  ElseIf Value.Left(2) = "0b" And Value.Len > 2 Then
		    Dim chars() As String = Value.Split("")
		    Call chars.Remove(0) // Remove "0"
		    Call chars.Remove(0) // Remove "b"
		    For i As Integer = 0 To chars.Ubound
		      If Not IsBinary(chars(i)) Then Return New RooNumber(0)
		    Next i
		    Return New RooNumber(Integer.FromBinary(Join(chars, "").ToText))
		  ElseIf Value.Left(2) = "0o" And Value.Len > 2 Then
		    Dim chars() As String = Value.Split("")
		    Call chars.Remove(0) // Remove "0"
		    Call chars.Remove(0) // Remove "o"
		    For i As Integer = 0 To chars.Ubound
		      If Not IsOctal(chars(i)) Then Return New RooNumber(0)
		    Next i
		    Return New RooNumber(Integer.FromOctal(Join(chars, "").ToText))
		  Else
		    // Let Xojo do the conversion for us.
		    Return New RooNumber(Val(Value))
		  End If
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function GetterWithName(name As RooToken) As Variant
		  // Return the result of the requested getter operation.
		  If StrComp(name.Lexeme, "capitalise", 0) = 0 Then
		    Return New RooText(Value.Titlecase)
		  ElseIf StrComp(name.Lexeme, "capitalise!", 0) = 0 Then
		    Value = Value.Titlecase
		    Return New RooText(Value)
		  ElseIf StrComp(name.Lexeme, "chars", 0) = 0 Then
		    Return DoChars
		  ElseIf StrComp(name.Lexeme, "define_utf8", 0) = 0 Then
		    Return DoDefineUTF8(False)
		  ElseIf StrComp(name.Lexeme, "define_utf8!", 0) = 0 Then
		    Return DoDefineUTF8(True)
		  ElseIf StrComp(name.Lexeme, "empty?", 0) = 0 Then
		    Return New RooBoolean(If(Value = "", True, False))
		  ElseIf StrComp(name.Lexeme, "length", 0) = 0 Then
		    Return New RooNumber(Value.Len)
		  ElseIf StrComp(name.Lexeme, "lowercase", 0) = 0 Then
		    Return New RooText(Value.Lowercase)
		  ElseIf StrComp(name.Lexeme, "lowercase!", 0) = 0 Then
		    Value = Value.Lowercase
		    Return New RooText(Value)
		  ElseIf StrComp(name.Lexeme, "lstrip", 0) = 0 Then
		    Return New RooText(Value.LTrim)
		  ElseIf StrComp(name.Lexeme, "lstrip!", 0) = 0 Then
		    Value = Value.LTrim
		    Return New RooText(Value)
		  ElseIf StrComp(name.Lexeme, "reverse", 0) = 0 Then
		    Return DoReverse(False)
		  ElseIf StrComp(name.Lexeme, "reverse!", 0) = 0 Then
		    Return DoReverse(True)
		  ElseIf StrComp(name.Lexeme, "rstrip", 0) = 0 Then
		    Return New RooText(Value.RTrim)
		  ElseIf StrComp(name.Lexeme, "rstrip!", 0) = 0 Then
		    Value = Value.RTrim
		    Return New RooText(Value)
		  ElseIf StrComp(name.Lexeme, "strip", 0) = 0 Then
		    Return New RooText(Value.Trim)
		  ElseIf StrComp(name.Lexeme, "strip!", 0) = 0 Then
		    Value = Value.Trim
		    Return New RooText(Value)
		  ElseIf StrComp(name.Lexeme, "swapcase", 0) = 0 Then
		    Return DoSwapCase(False)
		  ElseIf StrComp(name.Lexeme, "swapcase!", 0) = 0 Then
		    Return DoSwapCase(True)
		  ElseIf StrComp(name.Lexeme, "to_date", 0) = 0 Then
		    Return DoToDate
		  ElseIf StrComp(name.Lexeme, "to_number", 0) = 0 Then
		    Return DoToNumber
		  ElseIf StrComp(name.Lexeme, "uppercase", 0) = 0 Then
		    Return New RooText(Value.Uppercase)
		  ElseIf StrComp(name.Lexeme, "uppercase!", 0) = 0 Then
		    Value = Value.Uppercase
		    Return New RooText(Value)
		  End If
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function HasGetterWithName(name As String) As Boolean
		  // Query the global Roo dictionary of Text object getters for the existence of a getter 
		  // with the passed name.
		  
		  Return RooSLCache.TextGetters.HasKey(name)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function HasMethodWithName(name As String) As Boolean
		  // Query the global Roo dictionary of Text object methods for the existence of a method 
		  // with the passed name.
		  
		  Return RooSLCache.TextMethods.HasKey(name)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Invoke(interpreter As RooInterpreter, arguments() As Variant, where As RooToken) As Variant
		  // Part of the Invokable interface.
		  
		  #Pragma Unused interpreter
		  #Pragma Unused arguments
		  
		  Raise New RooRuntimeError(where, "Cannot invoke the native Text type.")
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function IsBinary(char As String) As Boolean
		  // Returns True if `char` is 0 or 1.
		  
		  Select Case char
		  Case "0", "1"
		    Return True
		  Else
		    Return False
		  End Select
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function IsHexadecimal(char As String) As Boolean
		  // Returns True if `char` is a hexadecimal digit.
		  // Case-insensitive.
		  
		  Select Case char
		  Case "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "A", "B", "C", "D", "E", "F"
		    Return True
		  Else
		    Return False
		  End Select
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function IsOctal(char As String) As Boolean
		  // Returns True if `char` is an octal numeral.
		  
		  Select Case char
		  Case "0", "1", "2", "3", "4", "5", "6", "7"
		    Return True
		  Else
		    Return False
		  End Select
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function MethodWithName(name As RooToken) As Invokable
		  // Return a new instance of a Text object method initialised with the name of the method 
		  // being called. That way, when the returned method is invoked, it will know what operation 
		  // to perform.
		  Return New RooTextMethod(Self, name.Lexeme)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function StringValue() As String
		  Return Self.Value
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Type() As String
		  Return "Text"
		End Function
	#tag EndMethod


	#tag Property, Flags = &h0
		Value As String
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
		#tag ViewProperty
			Name="Value"
			Group="Behavior"
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
	#tag EndViewBehavior
End Class
#tag EndClass
