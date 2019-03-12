#tag Class
Protected Class RooDateTimeMethod
Implements Invokable, Stringable
	#tag Method, Flags = &h0
		Function Arity() As Variant
		  // Part of the Invokable interface.
		  // Return the arity of this method. This is stored in the cached DateTimeMethods dictionary.
		  
		  Return RooSLCache.DateTimeMethods.Value(Name)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor(owner As RooDateTime, name As String)
		  Self.Owner = owner
		  Self.Name = name
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function DoModifyDays(arguments() As Variant, where As RooToken, subtract As Boolean = False) As RooDateTime
		  // DateTime.add_days(value As Number) As DateTime
		  // or
		  // DateTime.sub_days(value As Number) As DateTime (if `subtract` = True).
		  // Returns a new DateTime object with the specified number of days added or subtracted.
		  // This DateTime object is unaltered.
		  
		  // Make sure an integer has been passed.
		  Roo.AssertAreIntegers(where, arguments(0))
		  
		  // Create and return a new DateTime object.
		  Dim di As New Xojo.Core.DateInterval(0, 0, RooNumber(arguments(0)).Value)
		  Return New RooDateTime(If(subtract, Owner.Value - di, Owner.Value + di))
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function DoModifyHours(arguments() As Variant, where As RooToken, subtract As Boolean = False) As RooDateTime
		  // DateTime.add_hours(value As Number) As DateTime.
		  // or
		  // DateTime.sub_hours(value As Number) As DateTime (if `subtract` = True).
		  // Returns a new DateTime object with the specified number of hours added or subtracted.
		  // This DateTime object is unaltered.
		  
		  // Make sure an integer has been passed.
		  Roo.AssertAreIntegers(where, arguments(0))
		  
		  // Create and return a new DateTime object.
		  Dim di As New Xojo.Core.DateInterval(0, 0, 0, RooNumber(arguments(0)).Value)
		  Return New RooDateTime(If(subtract, Owner.Value - di, Owner.Value + di))
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function DoModifyMonths(arguments() As Variant, where As RooToken, subtract As Boolean = False) As RooDateTime
		  // DateTime.add_months(value As Number) As DateTime.
		  // or
		  // DateTime.sub_months(value As Number) As DateTime (if `subtract` = True).
		  // Returns a new DateTime object with the specified number of months added or subtracted.
		  // This DateTime object is unaltered.
		  
		  // Make sure an integer has been passed.
		  Roo.AssertAreIntegers(where, arguments(0))
		  
		  // Create and return a new DateTime object.
		  Dim di As New Xojo.Core.DateInterval(0, RooNumber(arguments(0)).Value)
		  Return New RooDateTime(If(subtract, Owner.Value - di, Owner.Value + di))
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function DoModifyNanoseconds(arguments() As Variant, where As RooToken, subtract As Boolean = False) As RooDateTime
		  // DateTime.add_nanoseconds(value As Number) As DateTime.
		  // or
		  // DateTime.sub_nanoseconds(value As Number) As DateTime (if `subtract` = True).
		  // Returns a new DateTime object with the specified number of nanoseconds added or subtracted.
		  // This DateTime object is unaltered.
		  
		  // Make sure an integer has been passed.
		  Roo.AssertAreIntegers(where, arguments(0))
		  
		  // Create and return a new DateTime object.
		  Dim di As New Xojo.Core.DateInterval(0, 0, 0, 0, 0, 0, RooNumber(arguments(0)).Value)
		  Return New RooDateTime(If(subtract, Owner.Value - di, Owner.Value + di))
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function DoModifySeconds(arguments() As Variant, where As RooToken, subtract As Boolean = False) As RooDateTime
		  // DateTime.add_seconds(value as Number) as DateTime.
		  // or
		  // DateTime.sub_seconds(value As Number) As DateTime (if `subtract` = True).
		  // Returns a new DateTime object with the specified number of seconds added or subtracted,
		  // This DateTime object is unaltered.
		  
		  // Make sure an integer has been passed.
		  Roo.AssertAreIntegers(where, arguments(0))
		  
		  // Create and return a new DateTime object.
		  Dim di As New Xojo.Core.DateInterval(0, 0, 0, 0, 0, RooNumber(arguments(0)).Value)
		  Return New RooDateTime(If(subtract, Owner.Value - di, Owner.Value + di))
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function DoModifyYears(arguments() As Variant, where As RooToken, subtract As Boolean = False) As RooDateTime
		  // DateTime.add_years(value As Number) As DateTime.
		  // or
		  // DateTime.sub_years(value As Number) As DateTime (if `subtract` = True).
		  // Returns a new DateTime object with the specified number of years added or subtracted.
		  // This DateTime object is unaltered.
		  
		  // Make sure an integer has been passed.
		  Roo.AssertAreIntegers(where, arguments(0))
		  
		  // Create and return a new DateTime object.
		  Dim di As New Xojo.Core.DateInterval(RooNumber(arguments(0)).Value)
		  Return New RooDateTime(If(subtract, Owner.Value - di, Owner.Value + di))
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Invoke(interpreter As RooInterpreter, arguments() As Variant, where As RooToken) As Variant
		  // Part of the Invokable interface.
		  // Perform the required method operation on this DateTime object.
		  
		  #Pragma Unused interpreter
		  
		  Select Case Name
		  Case "add_days"
		    Return DoModifyDays(arguments, where)
		  Case "add_hours"
		    Return DoModifyHours(arguments, where)
		  Case "add_months"
		    Return DoModifyMonths(arguments, where)
		  Case "add_nanoseconds"
		    Return DoModifyNanoseconds(arguments, where)
		  Case "add_seconds"
		    Return DoModifySeconds(arguments, where)
		  Case "add_years"
		    Return DoModifyYears(arguments, where)
		  Case "sub_days"
		    Return DoModifyDays(arguments, where, True)
		  Case "sub_hours"
		    Return DoModifyHours(arguments, where, True)
		  Case "sub_months"
		    Return DoModifyMonths(arguments, where, True)
		  Case "sub_nanoseconds"
		    Return DoModifyNanoseconds(arguments, where, True)
		  Case "sub_seconds"
		    Return DoModifySeconds(arguments, where, True)
		  Case "sub_years"
		    Return DoModifyYears(arguments, where, True)
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
			The name of this DateTime object method.
		#tag EndNote
		Name As String
	#tag EndProperty

	#tag Property, Flags = &h0
		#tag Note
			The RooDateTime object that owns this method.
		#tag EndNote
		Owner As RooDateTime
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
