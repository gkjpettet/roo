#tag Class
Protected Class DateTime
Implements Roo.Invokable,Roo.Textable
	#tag Method, Flags = &h0
		Function Arity() As Variant
		  ' There are four DateTime constructor function signatures:
		  ' var d1 = DateTime()
		  ' var d2 = DateTime(UNIX Time)
		  ' var d3 = DateTime(y, m, d)
		  ' var d4 = DateTime(y, m, d, h, min, s)
		  
		  Return Array(0, 1, 3, 6)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function DoDateTimeNow() As Roo.Objects.DateTimeObject
		  ' Return a new DateTime object, instantiated to the current date and time.
		  
		  Return New Roo.Objects.DateTimeObject(Xojo.Core.Date.Now)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function DoFromDateTimeValues(arguments() As Variant, where As Roo.Token) As Roo.Objects.DateTimeObject
		  ' Returns a new DateTime object instantiated to the time specified by the passed arguments.
		  ' The method signature is:
		  ' DateTime(year, month, day, hour, minute, second)
		  ' The year, month and day arguments must be positive integers. 
		  ' The hour, minute and second arguments may be negative.
		  ' Values roll over (i.e. hour = 26 rolls over to hour = 2, etc).
		  
		  ' We don't need to check the number of arguments as this will have been done previously.
		  ' Check the individual arguments.
		  ' YEAR
		  If arguments(0) IsA Roo.Objects.NumberObject = False Or _
		    Roo.Objects.NumberObject(arguments(0)).IsInteger = False Or _
		    Roo.Objects.NumberObject(arguments(0)).value < 0 Then
		    Raise New RuntimeError(where, "The DateTime constructor, DateTime(y, m, d, h, min, s), expects " + _
		    "the year parameter to be a positive integer. Instead got `" + _
		    Textable(arguments(0)).ToText(Nil) + "`.")
		  End If
		  Dim year As Integer = Roo.Objects.NumberObject(arguments(0)).value
		  
		  ' MONTH
		  If arguments(1) IsA Roo.Objects.NumberObject = False Or _
		    Roo.Objects.NumberObject(arguments(1)).IsInteger = False Or _
		    Roo.Objects.NumberObject(arguments(1)).value < 0 Then
		    Raise New RuntimeError(where, "The DateTime constructor, DateTime(y, m, d, h, min, s), expects " + _
		    "the month parameter to be a positive integer. Instead got `" + _
		    Textable(arguments(1)).ToText(Nil) + "`.")
		  End If
		  Dim month As Integer = Roo.Objects.NumberObject(arguments(1)).value
		  
		  ' DAY
		  If arguments(2) IsA Roo.Objects.NumberObject = False Or _
		    Roo.Objects.NumberObject(arguments(2)).IsInteger = False Or _
		    Roo.Objects.NumberObject(arguments(2)).value < 0 Then
		    Raise New RuntimeError(where, "The DateTime constructor, DateTime(y, m, d, h, min, s), expects " + _
		    "the day parameter to be a positive integer. Instead got `" + _
		    Textable(arguments(2)).ToText(Nil) + "`.")
		  End If
		  Dim day As Integer = Roo.Objects.NumberObject(arguments(2)).value
		  
		  ' HOUR
		  If arguments(3) IsA Roo.Objects.NumberObject = False Or _
		    Roo.Objects.NumberObject(arguments(3)).IsInteger = False Then
		    Raise New RuntimeError(where, "The DateTime constructor, DateTime(y, m, d, h, min, s), expects " + _
		    "the hour parameter to be an integer. Instead got `" + Textable(arguments(3)).ToText(Nil) + "`.")
		  End If
		  Dim hour As Integer = Roo.Objects.NumberObject(arguments(3)).value
		  
		  ' MINUTE
		  If arguments(4) IsA Roo.Objects.NumberObject = False Or _
		    Roo.Objects.NumberObject(arguments(4)).IsInteger = False Then
		    Raise New RuntimeError(where, "The DateTime constructor, DateTime(y, m, d, h, min, s), expects " + _
		    "the minute parameter to be an integer. Instead got `" + Textable(arguments(4)).ToText(Nil) + "`.")
		  End If
		  Dim minute As Integer = Roo.Objects.NumberObject(arguments(4)).value
		  
		  ' SECOND
		  If arguments(5) IsA Roo.Objects.NumberObject = False Or _
		    Roo.Objects.NumberObject(arguments(5)).IsInteger = False Then
		    Raise New RuntimeError(where, "The DateTime constructor, DateTime(y, m, d, h, min, s), expects " + _
		    "the second parameter to be an integer. Instead got `" + Textable(arguments(5)).ToText(Nil) + "`.")
		  End If
		  Dim sec As Integer = Roo.Objects.NumberObject(arguments(5)).value
		  
		  ' Return the new DateTime object.
		  Return New Roo.Objects.DateTimeObject(New Xojo.Core.Date(year, month, day, _
		  hour, minute, sec, Xojo.Core.TimeZone.Current))
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function DoFromDateValues(arguments() As Variant, where As Roo.Token) As Roo.Objects.DateTimeObject
		  ' Returns a new DateTime object instantiated to the time specified by the passed arguments.
		  ' The method signature is:
		  ' DateTime(year, month, day)
		  ' The year, month and day arguments must be positive integers. 
		  ' Values roll over (i.e. hour = 26 rolls over to hour = 2, etc).
		  ' Implicitly sets the hour, minute and second to 0.
		  
		  ' We don't need to check the number of arguments as this will have been done previously.
		  ' Check the individual arguments.
		  ' YEAR
		  If arguments(0) IsA Roo.Objects.NumberObject = False Or _
		    Roo.Objects.NumberObject(arguments(0)).IsInteger = False Or _
		    Roo.Objects.NumberObject(arguments(0)).value < 0 Then
		    Raise New RuntimeError(where, "The DateTime constructor, DateTime(y, m, d, h, min, s), expects " + _
		    "the year parameter to be a positive integer. Instead got `" + Textable(arguments(0)).ToText(Nil) + "`.")
		  End If
		  Dim year As Integer = Roo.Objects.NumberObject(arguments(0)).value
		  
		  ' MONTH
		  If arguments(1) IsA Roo.Objects.NumberObject = False Or _
		    Roo.Objects.NumberObject(arguments(1)).IsInteger = False Or _
		    Roo.Objects.NumberObject(arguments(1)).value < 0 Then
		    Raise New RuntimeError(where, "The DateTime constructor, DateTime(y, m, d, h, min, s), expects " + _
		    "the month parameter to be a positive integer. Instead got `" + _
		    Textable(arguments(1)).ToText(Nil) + "`.")
		  End If
		  Dim month As Integer = Roo.Objects.NumberObject(arguments(1)).value
		  
		  ' DAY
		  If arguments(2) IsA Roo.Objects.NumberObject = False Or _
		    Roo.Objects.NumberObject(arguments(2)).IsInteger = False Or _
		    Roo.Objects.NumberObject(arguments(2)).value < 0 Then
		    Raise New RuntimeError(where, "The DateTime constructor, DateTime(y, m, d, h, min, s), expects " + _
		    "the day parameter to be a positive integer. Instead got `" + _
		    Textable(arguments(2)).ToText(Nil) + "`.")
		  End If
		  Dim day As Integer = Roo.Objects.NumberObject(arguments(2)).value
		  
		  ' Return the new DateTime object.
		  Return New Roo.Objects.DateTimeObject(New Xojo.Core.Date(year, month, day, Xojo.Core.TimeZone.Current))
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function DoFromUNIX(argument As Variant, where As Roo.Token) As Roo.Objects.DateTimeObject
		  ' Returns a new DateTime object, instantiated to the specified UNIX time.
		  
		  ' Check that the passed argument is a Number object.
		  If Not argument IsA Roo.Objects.NumberObject Then
		    Raise New RuntimeError(where, "The parameter passed to the DateTime function must be a Number object.")
		  End If
		  
		  ' Check that the passed argument is an integer
		  If Not Roo.Objects.NumberObject(argument).IsInteger Then
		    Raise New RuntimeError(where, "The parameter passed to the DateTime function must be an integer.")
		  End If
		  
		  ' Get the UNIX time.
		  Dim unixTime As Double = Roo.Objects.NumberObject(argument).value
		  
		  ' Make sure it's positive.
		  If unixTime < 0 Then
		    Raise New RuntimeError(where, "The parameter passed to the DateTime function must be a " +_
		    "positive integer.")
		  End If
		  
		  ' Create and return the new object.
		  Return New Roo.Objects.DateTimeObject(New Xojo.Core.Date(unixTime, Xojo.Core.TimeZone.Current))
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Invoke(interpreter As Interpreter, arguments() As Variant, where As Token) As Variant
		  ' Create a new DateTime object instance.
		  ' There are four DateTime constructor function signatures:
		  ' Sig 1: var d1 = DateTime()
		  ' Sig 2: var d2 = DateTime(UNIX time)
		  ' Sig 3: var d3 = DateTime(y, m, d)
		  ' Sig 4: var d4 = DateTime(y, m, d, h, min, s)
		  
		  #Pragma Unused interpreter
		  
		  If arguments.Ubound = -1 Then ' DateTime()
		    Return DoDateTimeNow
		  ElseIf arguments.Ubound = 0 Then ' DateTime(UNIX time)
		    Return DoFromUNIX(arguments(0), where)
		  ElseIf arguments.Ubound = 2 then ' DateTime(y, m, d)
		    Return DoFromDateValues(arguments, where)
		  Else ' DateTime(y, m, d, h, min, s)
		    Return DoFromDateTimeValues(arguments, where)
		  End If
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function ToText(interpreter As Roo.Interpreter) As String
		  ' Return this function's name.
		  
		  #Pragma Unused interpreter
		  
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
