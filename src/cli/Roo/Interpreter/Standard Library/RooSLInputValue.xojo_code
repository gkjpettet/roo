#tag Class
Protected Class RooSLInputValue
Implements Invokable
	#tag Method, Flags = &h0
		Function Arity() As Variant
		  // Part of the Invokable interface.
		  // The input_value() function has two definitions:
		  // input_value()
		  // input_value(prompt As TextObject)
		  
		  Return Array(0, 1)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Invoke(interpreter As RooInterpreter, arguments() As Variant, where As RooToken) As Variant
		  // Part of the Invokable interface.
		  // Used to get input from the user into the running script. 
		  // The input_value() function differs from the input() function in 
		  // that it will try to convert the String returned by the interpreter's Input() 
		  // method into the correct Roo runtime object. for example, if True is returned 
		  // we will create a RooBoolean, if 0xFFFFFF is returned we will create a RooNumber, etc.
		  // We will fire the interpreter's Input() event by calling into its InputHook() method.
		  // The only values we allow are:
		  // Text, Numbers, Booleans, Nothing.
		  // We don't parse arrays and hashes.
		  
		  Dim prompt As String = ""
		  
		  // Has a prompt been provided?
		  If arguments.Ubound = 0 Then prompt = Stringable(arguments(0)).StringValue
		  
		  // Fire the intepreter's Input() event.
		  Dim userInput As String = interpreter.InputHook(prompt)
		  
		  // Convert the user-provided value into a runtime representation.
		  // Only Text will contain whitespace.
		  If userInput.InStr(" ") <> 0 Or userInput.InStr(Chr(9)) <> 0 Then
		    Return New RooText(userInput)
		  End If
		  
		  // Nothing?
		  If userInput = "" Or StrComp(userInput, "Nothing", 0) = 0 Then
		    Return New RooNothing
		  End If
		  
		  // Boolean?
		  If StrComp(userInput, "True", 0) = 0 Then
		    Return New RooBoolean(True)
		  ElseIf StrComp(userInput, "False", 0) = 0 Then
		    Return New RooBoolean(False)
		  End If
		  
		  // Zero?
		  If userInput = "0" Then Return New RooNumber(0)
		  
		  // Before we check to see if this is a prefixed number, 
		  // check to see if the user input is too short to be one.
		  If userInput.Len >= 3 Then
		    // Hex number?
		    If userInput.Left(2) = "0x" Then
		      Dim hexValue As String = userInput.Right(userInput.Len - 2)
		      If ValidHex(hexValue) Then
		        Return New RooNumber(Val("&h" + hexValue))
		      Else
		        // Invalid hex value.
		        Return New RooText(userInput)
		      End If
		    End If
		    
		    // Binary number?
		    If userInput.Left(2) = "0b" Then
		      Dim binaryValue As String = userInput.Right(userInput.Len - 2)
		      If ValidBinary(binaryValue) Then
		        Return New RooNumber(Val("&b" + binaryValue))
		      Else
		        // Invalid binary value.
		        Return New RooText(userInput)
		      End If
		    End If
		    
		    // Octal number?
		    If userInput.Left(2) = "0o" Then
		      Dim octalValue As String = userInput.Right(userInput.Len - 2)
		      If ValidOctal(octalValue) Then
		        Return New RooNumber(Val("&o" + octalValue))
		      Else
		        // Invalid octal value.
		        Return New RooText(userInput)
		      End If
		    End If
		  End If
		  
		  // Decimal number?
		  If Val(userInput) <> 0 Then Return New RooNumber(userInput.Val)
		  
		  // Assume text.
		  Return New RooText(userInput)
		  
		  Exception err
		    Raise New RooRuntimeError(where, "If a parameter is passed to the input() method, " + _
		    "it must have a text representation.")
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function StringValue() As String
		  // Part of the Stringable interface.
		  // Return this function's name.
		  
		  Return "<function: input_value>"
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function ValidBinary(s As String) As Boolean
		  // Takes a String and determines if it is a valid binary number.
		  
		  If s = "" Then Return False
		  
		  Dim chars() As String = s.Split("")
		  For i As Integer = 0 To chars.Ubound
		    Select Case chars(i)
		    Case "0", "1"
		      // Valid character. Carry on.
		    Else
		      Return False
		    End Select
		  Next i
		  
		  Return True
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function ValidHex(s As String) As Boolean
		  // Takes a String and determines if it is a valid hex number.
		  
		  If s = "" Then Return False
		  
		  Dim chars() As String = s.Split("")
		  For i As Integer = 0 To chars.Ubound
		    Select Case chars(i)
		    Case "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", _
		      "a", "b", "c", "d", "e", "f"
		      // Valid character. Carry on.
		    Else
		      Return False
		    End Select
		  Next i
		  
		  Return True
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function ValidOctal(s As String) As Boolean
		  // Takes a String and determines if it is a valid octal number.
		  
		  If s = "" Then Return False
		  
		  Dim chars() As String = s.Split("")
		  For i As Integer = 0 To chars.Ubound
		    Select Case chars(i)
		    Case "0", "1", "2", "3", "4", "5", "6", "7"
		      // Valid character. Carry on.
		    Else
		      Return False
		    End Select
		  Next i
		  
		  Return True
		  
		End Function
	#tag EndMethod


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
