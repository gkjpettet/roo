#tag Class
Protected Class RooSLDateTime
Implements Invokable, Stringable
	#tag Method, Flags = &h0
		Function Arity() As Variant
		  // Part of the Invokable interface.
		  // There are four DateTime constructor function signatures:
		  // var d1 = DateTime()
		  // var d2 = DateTime(UNIX Time)
		  // var d3 = DateTime(y, m, d)
		  // var d4 = DateTime(y, m, d, h, min, s)
		  
		  Return Array(0, 1, 3, 6)
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function DoDateTimeNow() As RooDateTime
		  // Return a new DateTime object, instantiated to the current date and time.
		  
		  Return New RooDateTime(Xojo.Core.Date.Now)
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function DoFromDateTimeValues(arguments() As Variant, where As RooToken) As RooDateTime
		  // Returns a new DateTime object instantiated to the time specified by the passed arguments. 
		  //The method signature is: DateTime(year, month, day, hour, minute, second)
		  // The arguments must be positive integers. 
		  
		  // We don't need to check the number of arguments as this will have been done previously.
		  // Check the individual arguments.
		  // YEAR
		  Roo.AssertArePositiveIntegers(where, arguments(0))
		  Dim year As Integer = RooNumber(arguments(0)).Value
		  
		  // MONTH
		  Roo.AssertArePositiveIntegers(where, arguments(1))
		  Dim month As Integer = RooNumber(arguments(1)).Value
		  If month < 1 Or month > 12 Then
		    Raise New RooRuntimeError(where, "The DateTime constructor, DateTime(y, m, d, h, min, s), expects " + _
		    "the month parameter to be an integer between 1 and 12. Instead got `" + Str(month) + "`.")
		  End If
		  
		  // DAY
		  Roo.AssertArePositiveIntegers(where, arguments(2))
		  Dim day As Integer = RooNumber(arguments(2)).Value
		  If day < 1 Or day > 31 Then
		    Raise New RooRuntimeError(where, "The DateTime constructor, DateTime(y, m, d, h, min, s), expects " + _
		    "the day parameter to be an integer between 1 and 31. Instead got `" + Str(day) + "`.")
		  End If
		  // Make sure a valid day for the specified month has been passed.
		  Select Case month
		  Case 2 // Feb.
		    If day > 29 Or (day = 29 And Not RooDateTime.IsLeapYear(year)) Then
		      Raise New RooRuntimeError(where, "Invalid day parameter (" + Str(day) + _
		      " passed to the DateTime constructor. There are only 28 days in February in the year " + _
		      Str(year) + ".")
		    End If
		  Case 9, 4, 6, 11 // Sep, Apr, Jun, Nov have 30 days.
		    If day > 30 Then
		      Raise New RooRuntimeError(where, "Invalid day parameter (" + Str(day) + _
		      " passed to the DateTime constructor. There are only 30 days in " + _
		      Roo.LongMonthFromInteger(month) + ".")
		    End If
		  End Select
		  
		  // HOUR
		  Roo.AssertArePositiveIntegers(where, arguments(3))
		  Dim hour As Integer = RooNumber(arguments(3)).Value
		  If hour > 23 Then
		    Raise New RooRuntimeError(where, "The DateTime constructor, DateTime(y, m, d, h, min, s), expects " + _
		    "the hour parameter to be an integer between 0 and 23. Instead got `" + Str(hour) + "`.")
		  End If
		  
		  // MINUTE
		  Roo.AssertArePositiveIntegers(where, arguments(4))
		  Dim minute As Integer = RooNumber(arguments(4)).Value
		  If minute > 59 Then
		    Raise New RooRuntimeError(where, "The DateTime constructor, DateTime(y, m, d, h, min, s), expects " + _
		    "the minute parameter to be an integer between 0 and 59. Instead got `" + Str(minute) + "`.")
		  End If
		  
		  // SECOND
		  Roo.AssertArePositiveIntegers(where, arguments(5))
		  Dim sec As Integer = RooNumber(arguments(5)).Value
		  If sec > 59 Then
		    Raise New RooRuntimeError(where, "The DateTime constructor, DateTime(y, m, d, h, min, s), expects " + _
		    "the seconds parameter to be an integer between 0 and 59. Instead got `" + Str(sec) + "`.")
		  End If
		  
		  // Return the new DateTime object.
		  Return New RooDateTime(New Xojo.Core.Date(year, month, day, _
		  hour, minute, sec, Xojo.Core.TimeZone.Current))
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function DoFromDateValues(arguments() As Variant, where As RooToken) As RooDateTime
		  // Returns a new DateTime object instantiated to the time specified by the passed arguments.
		  // The method signature is: DateTime(year, month, day)
		  // The year, month and day arguments must be positive integers. 
		  // Implicitly sets the hour, minute and second to 0.
		  
		  // We don't need to check the number of arguments as this will have been done previously.
		  // Check the individual arguments.
		  // YEAR
		  Roo.AssertArePositiveIntegers(where, arguments(0))
		  Dim year As Integer = RooNumber(arguments(0)).Value
		  
		  // MONTH
		  Roo.AssertArePositiveIntegers(where, arguments(1))
		  Dim month As Integer = RooNumber(arguments(1)).Value
		  If month < 1 Or month > 12 Then
		    Raise New RooRuntimeError(where, "The DateTime constructor, DateTime(y, m, d), expects " + _
		    "the month parameter to be an integer between 1 and 12. Instead got `" + Str(month) + "`.")
		  End If
		  
		  // DAY
		  Roo.AssertArePositiveIntegers(where, arguments(2))
		  Dim day As Integer = RooNumber(arguments(2)).Value
		  If day < 1 Or day > 31 Then
		    Raise New RooRuntimeError(where, "The DateTime constructor, DateTime(y, m, d), expects " + _
		    "the day parameter to be an integer between 1 and 31. Instead got `" + Str(day) + "`.")
		  End If
		  // Make sure a valid day for the specified month has been passed.
		  Select Case month
		  Case 2 // Feb.
		    If day > 29 Or (day = 29 And Not RooDateTime.IsLeapYear(year)) Then
		      Raise New RooRuntimeError(where, "Invalid day parameter (" + Str(day) + _
		      " passed to the DateTime constructor. There are only 28 days in February in the year " + _
		      Str(year) + ".")
		    End If
		  Case 9, 4, 6, 11 // Sep, Apr, Jun, Nov have 30 days.
		    If day > 30 Then
		      Raise New RooRuntimeError(where, "Invalid day parameter (" + Str(day) + _
		      " passed to the DateTime constructor. There are only 30 days in " + _
		      Roo.LongMonthFromInteger(month) + ".")
		    End If
		  End Select
		  
		  //Return the new DateTime object.
		  Return New RooDateTime(New Xojo.Core.Date(year, month, day, Xojo.Core.TimeZone.Current))
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function DoFromUNIX(argument As Variant, where As RooToken) As RooDateTime
		  // Returns a new DateTime object, instantiated to the specified UNIX time.
		  
		  // Check that the passed argument is an integer.
		  Roo.AssertAreIntegers(where, argument)
		  
		  // Get the UNIX time.
		  Dim unixTime As Double = RooNumber(argument).Value
		  
		  // Make sure it's positive.
		  If unixTime < 0 Then
		    Raise New RooRuntimeError(where, "The parameter passed to the DateTime constructor must be a " +_
		    "positive integer.")
		  End If
		  
		  // Create and return the new object.
		  Return New RooDateTime(New Xojo.Core.Date(unixTime, Xojo.Core.TimeZone.Current))
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Invoke(interpreter As RooInterpreter, arguments() As Variant, where As RooToken) As Variant
		  // Part of the Invokable interface.
		  // Create a new DateTime object instance.
		  // There are four DateTime constructor function signatures:
		  // Sig 1: var d1 = DateTime()
		  // Sig 2: var d2 = DateTime(UNIX time)
		  // Sig 3: var d3 = DateTime(y, m, d)
		  // Sig 4: var d4 = DateTime(y, m, d, h, min, s)
		  
		  #Pragma Unused interpreter
		  
		  If arguments.Ubound = -1 Then // DateTime()
		    Return DoDateTimeNow
		  ElseIf arguments.Ubound = 0 Then // DateTime(UNIX time)
		    Return DoFromUNIX(arguments(0), where)
		  ElseIf arguments.Ubound = 2 then // DateTime(y, m, d)
		    Return DoFromDateValues(arguments, where)
		  Else// DateTime(y, m, d, h, min, s)
		    Return DoFromDateTimeValues(arguments, where)
		  End If
		  
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function StringValue() As String
		  // Part of the Stringable interface.
		  // Return this function's name.
		  
		  Return "<function: DateTime>"
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
