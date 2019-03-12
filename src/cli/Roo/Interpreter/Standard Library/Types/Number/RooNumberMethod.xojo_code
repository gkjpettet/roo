#tag Class
Protected Class RooNumberMethod
Implements Invokable
	#tag Method, Flags = &h0
		Function Arity() As Variant
		  // Part of the Invokable interface.
		  // Return the arity of this method. This is stored in the cached NumberMethods dictionary.
		  
		  Return RooSLCache.NumberMethods.Value(Name)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor(owner As RooNumber, name As String)
		  Self.Owner = owner
		  Self.Name = name
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function DoEachDigit(args() As Variant, where As RooToken, interpreter As RooInterpreter) As RooNumber
		  // Number.each_digit(func as Invokable, optional arguments as Array) as Number
		  // Invokes the passed function for each digit of this number, passing to the function the 
		  // digit as the first argument.
		  // Optionally the method can take a second argument in the form of an Array. The elements of this
		  // Array will be passed to the function as additional arguments.
		  // Returns the number of digits invoked.
		  
		  // E.g: 
		  
		  ' def listDigits(digit):
		  '   print(digit)
		  
		  ' 123.each_digit(listDigits)
		  ' # Prints:
		  ' 1
		  ' 2
		  ' 3
		  
		  Dim funcArgs() As Variant
		  Dim func As Invokable
		  
		  // Check that `func` is invokable.
		  Roo.AssertIsInvokable(where, args(0))
		  func = args(0)
		  
		  // If a second argument has been passed, check that it's an Array object.
		  If args.Ubound = 1 Then
		    Roo.AssertIsArray(where, args(1))
		    // Get an array of the additional arguments to pass to the function that we will invoke.
		    Dim limit As Integer = RooArray(args(1)).Elements.Ubound
		    For i As Integer = 0 To limit
		      funcArgs.Append(RooArray(args(1)).Elements(i))
		    Next i
		  End If
		  
		  // Check that we have the correct number of arguments for `func`.
		  // NB: +2 as we will pass in each digit as the first argument.
		  If Not Interpreter.CorrectArity(func, funcArgs.Ubound + 2) Then
		    Raise New RooRuntimeError(where, "Incorrect number of arguments passed to the " +_
		    Stringable(func).StringValue + " function.")
		  End If
		  
		  // Convert this number into a String array.
		  Dim tmp As String
		  If Roo.IsInteger(Owner.Value) Then
		    tmp = Str(Owner.Value, Owner.kIntegerFormatString)
		  Else
		    tmp = Str(Owner.Value)
		    If tmp.InStr("e") <> 0 Then
		      // Only specially format high precision doubles.
		      tmp = Str(Owner.Value, Owner.kDoubleFormatString)
		    End If
		  End If
		  
		  // Check to see if there is an exponent in the string. If so, this number 
		  // has too many digits in either the integer-part or fractional-part.
		  If tmp.InStr("e") <> 0 Then
		    Raise New RooRuntimeError(where, "The Number.each_digit() method only " + _
		    "supports numbers with integer-parts or fractional-parts <= 30 digits. " + _
		    "This number is " + tmp)
		  End If
		  
		  Dim s() As String = tmp.Split("")
		  Dim digits() As RooNumber
		  Dim i As Integer
		  For i = 0 To s.Ubound
		    // Ignore decimal points and minus signs.
		    If s(i) <> "." And s(i) <> "-" Then digits.Append(New RooNumber(Val(s(i))))
		  Next i
		  
		  For i = 0 To digits.Ubound
		    // Inject the digit as the first argument to `func`.
		    funcArgs.Insert(0, digits(i))
		    // Call the function for this digit.
		    Call func.Invoke(interpreter, funcArgs, where)
		    // Remove the digit from the argument list prior to the next iteration.
		    funcArgs.Remove(0)
		  Next i
		  
		  // Return the number of digits.
		  Return New RooNumber(i)
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function DoEndsWith(args() As Variant, where As RooToken) As RooBoolean
		  // Number.ends_with?(digits As Text) As Boolean object
		  // Number.ends_with?(digits As Number) As Boolean object
		  // Number.ends_with?(digits As Array) As Boolean object
		  // Returns True or False depending on whether or not this number object 
		  // ends with the specified digits.
		  // Digits may be passed as Text, as a single Number or as an array of digits.
		  
		  Dim what As String
		  
		  If args(0) IsA RooArray Then
		    // Convert this array into a single string.
		    For i As Integer = 0 To RooArray(args(0)).Elements.Ubound
		      what = what + Stringable(RooArray(args(0)).Elements(i)).StringValue
		    Next i
		  Else
		    what = Stringable(args(0)).StringValue
		  End If
		  
		  // Convert this Number into a String to compare.
		  Dim thisValue As String
		  If Roo.IsInteger(Owner.Value) Then
		    thisValue = Str(Owner.Value, Owner.kIntegerFormatString)
		  Else
		    thisValue = Str(Owner.Value)
		    If thisValue.InStr("e") <> 0 Then
		      // Only specially format high precision doubles.
		      thisValue = Str(Owner.Value, Owner.kDoubleFormatString)
		    End If
		  End If
		  
		  // Remove any decimal point.
		  thisValue = thisValue.Replace(".", "")
		  
		  // Check to see if there is an exponent in the string. If so, this number 
		  // has too many digits in either the integer-part or fractional-part.
		  If thisValue.InStr("e") <> 0 Then
		    Raise New RooRuntimeError(where, "The Number.ends_with?() method only " + _
		    "supports numbers with integer-parts or fractional-parts <= 30 digits. " + _
		    "This number is " + thisValue)
		  End If
		  
		  // Sanity check.
		  If what.Len > thisValue.Len Then Return New RooBoolean(False)
		  
		  // Do the check.
		  Return New RooBoolean(thisValue.Right(what.Len) = what)
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function DoStartsWith(args() As Variant, where As RooToken) As RooBoolean
		  // Number.starts_with?(digits As Text) As Boolean object
		  // Number.starts_with?(digits As Number) As Boolean object
		  // Number.starts_with?(digits As Array) As Boolean object
		  // Returns True or False depending on whether or not this number object 
		  // starts with the specified digits.
		  // Digits may be passed as Text, as a single Number or as an array of digits.
		  
		  Dim what As String
		  
		  If args(0) IsA RooArray Then
		    // Convert this array into a single string.
		    For i As Integer = 0 To RooArray(args(0)).Elements.Ubound
		      what = what + Stringable(RooArray(args(0)).Elements(i)).StringValue
		    Next i
		  Else
		    what = Stringable(args(0)).StringValue
		  End If
		  
		  // Convert this Number into a String to compare.
		  Dim thisValue As String
		  If Roo.IsInteger(Owner.Value) Then
		    thisValue = Str(Owner.Value, Owner.kIntegerFormatString)
		  Else
		    thisValue = Str(Owner.Value)
		    If thisValue.InStr("e") <> 0 Then
		      // Only specially format high precision doubles.
		      thisValue = Str(Owner.Value, Owner.kDoubleFormatString)
		    End If
		  End If
		  
		  // Remove any decimal point.
		  thisValue = thisValue.Replace(".", "")
		  
		  // Check to see if there is an exponent in the string. If so, this number 
		  // has too many digits in either the integer-part or fractional-part.
		  If thisValue.InStr("e") <> 0 Then
		    Raise New RooRuntimeError(where, "The Number.starts_with?() method only " + _
		    "supports numbers with integer-parts or fractional-parts <= 30 digits. " + _
		    "This number is " + thisValue)
		  End If
		  
		  // Sanity check.
		  If what.Len > thisValue.Len Then Return New RooBoolean(False)
		  
		  // Do the check.
		  Return New RooBoolean(thisValue.Left(what.Len) = what)
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Invoke(interpreter As RooInterpreter, arguments() As Variant, where As RooToken) As Variant
		  // Part of the Invokable interface.
		  // Perform the required method operation on this Number object.
		  
		  Select Case Name
		  Case "each_digit"
		    Return DoEachDigit(arguments, where, interpreter)
		  Case "ends_with?"
		    Return DoEndsWith(arguments, where)
		  Case "starts_with?"
		    Return DoStartsWith(arguments, where)
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
			The RooNumber object that owns this method.
		#tag EndNote
		Owner As RooNumber
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
