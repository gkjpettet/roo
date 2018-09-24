#tag Class
Protected Class DateTimeObjectMethod
Implements Roo.Invokable,Roo.Textable
	#tag Method, Flags = &h0
		Function Arity() As Variant
		  Select Case Self.name
		  Case "add_days"
		    Return 1
		  Case "add_hours"
		    Return 1
		  Case "add_months"
		    Return 1
		  Case "add_nanoseconds"
		    Return 1
		  Case "add_seconds"
		    Return 1
		  Case "add_years"
		    Return 1
		  Case "responds_to?"
		    Return 1
		  Case "sub_days"
		    Return 1
		  Case "sub_hours"
		    Return 1
		  Case "sub_months"
		    Return 1
		  Case "sub_nanoseconds"
		    Return 1
		  Case "sub_seconds"
		    Return 1
		  Case "sub_years"
		    Return 1
		  End Select
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub CheckIntegerArgument(argument As Variant, argumentName As String, where As Roo.Token)
		  ' Checks that the passed argument is an integer. Raises a runtime error if not.
		  
		  If Not argument IsA NumberObject Or Not NumberObject(argument).IsInteger Then
		    Raise New RuntimeError(where, "The " + Self.Name + "(" + argumentName + ") method expects an " + _
		    "integer parameter. Instead got " + VariantType(argument) + ".")
		  End If
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor(parent As DateTimeObject, name As String)
		  Self.Parent = parent
		  Self.Name = name
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function DoModifyDays(arguments() As Variant, where As Roo.Token, subtract As Boolean = False) As Roo.Objects.DateTimeObject
		  ' DateTime.add_days(value as Number) as DateTime
		  ' or
		  ' DateTime.sub_days(value as Number) as DateTime (if `subtract` = True).
		  ' Returns a new DateTime object with the specified number of days added.
		  ' This DateTime object is unaltered.
		  
		  ' Make sure an integer has been passed.
		  CheckIntegerArgument(arguments(0), "value", where)
		  
		  ' Create and return a new DateTime object.
		  Dim di As New Xojo.Core.DateInterval(0, 0, NumberObject(arguments(0)).value)
		  Return New DateTimeObject(If(subtract, Parent.Value - di, Parent.Value + di))
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function DoModifyHours(arguments() As Variant, where As Roo.Token, subtract As Boolean = False) As Roo.Objects.DateTimeObject
		  ' DateTime.add_hours(value as Number) as DateTime
		  ' or
		  ' DateTime.sub_hours(value as Number) as DateTime (if `subtract` = True).
		  ' Returns a new DateTime object with the specified number of hours added.
		  ' This DateTime object is unaltered.
		  
		  ' Make sure an integer has been passed.
		  CheckIntegerArgument(arguments(0), "value", where)
		  
		  ' Create and return a new DateTime object.
		  Dim di As New Xojo.Core.DateInterval(0, 0, 0, NumberObject(arguments(0)).value)
		  Return New DateTimeObject(If(subtract, Parent.Value - di, Parent.Value + di))
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function DoModifyMonths(arguments() As Variant, where As Roo.Token, subtract As Boolean = False) As Roo.Objects.DateTimeObject
		  ' DateTime.add_months(value as Number) as DateTime
		  ' or
		  ' DateTime.sub_months(value as Number) as DateTime (if `subtract` = True).
		  ' Returns a new DateTime object with the specified number of months added.
		  ' This DateTime object is unaltered.
		  
		  ' Make sure an integer has been passed.
		  CheckIntegerArgument(arguments(0), "value", where)
		  
		  ' Create and return a new DateTime object.
		  Dim di As New Xojo.Core.DateInterval(0, NumberObject(arguments(0)).value)
		  Return New DateTimeObject(If(subtract, Parent.Value - di, Parent.Value + di))
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function DoModifyNanoseconds(arguments() As Variant, where As Roo.Token, subtract As Boolean = False) As Roo.Objects.DateTimeObject
		  ' DateTime.add_nanoseconds(value as Number) as DateTime
		  ' or
		  ' DateTime.sub_nanoseconds(value as Number) as DateTime (if `subtract` = True).
		  ' Returns a new DateTime object with the specified number of nanoseconds added.
		  ' This DateTime object is unaltered.
		  
		  ' Make sure an integer has been passed.
		  CheckIntegerArgument(arguments(0), "value", where)
		  
		  ' Create and return a new DateTime object.
		  Dim di As New Xojo.Core.DateInterval(0, 0, 0, 0, 0, 0, NumberObject(arguments(0)).value)
		  Return New DateTimeObject(If(subtract, Parent.Value - di, Parent.Value + di))
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function DoModifySeconds(arguments() As Variant, where As Roo.Token, subtract As Boolean = False) As Roo.Objects.DateTimeObject
		  ' DateTime.add_seconds(value as Number) as DateTime
		  ' or
		  ' DateTime.sub_seconds(value as Number) as DateTime (if `subtract` = True).
		  ' Returns a new DateTime object with the specified number of seconds added.
		  ' This DateTime object is unaltered.
		  
		  ' Make sure an integer has been passed.
		  CheckIntegerArgument(arguments(0), "value", where)
		  
		  ' Create and return a new DateTime object.
		  Dim di As New Xojo.Core.DateInterval(0, 0, 0, 0, 0, NumberObject(arguments(0)).value)
		  Return New DateTimeObject(If(subtract, Parent.Value - di, Parent.Value + di))
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function DoModifyYears(arguments() As Variant, where As Roo.Token, subtract As Boolean = False) As Roo.Objects.DateTimeObject
		  ' DateTime.add_years(value as Number) as DateTime
		  ' or
		  ' DateTime.sub_years(value as Number) as DateTime (if `subtract` = True).
		  ' Returns a new DateTime object with the specified number of years added.
		  ' This DateTime object is unaltered.
		  
		  ' Make sure an integer has been passed.
		  CheckIntegerArgument(arguments(0), "value", where)
		  
		  ' Create and return a new DateTime object.
		  Dim di As New Xojo.Core.DateInterval(NumberObject(arguments(0)).value)
		  Return New DateTimeObject(If(subtract, Parent.Value - di, Parent.Value + di))
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function DoRespondsTo(arguments() As Variant, where As Token) As BooleanObject
		  ' DateTime.responds_to?(what as Text) as Boolean.
		  
		  ' Make sure a Text argument is passed to the method.
		  If Not arguments(0) IsA TextObject Then
		    Raise New RuntimeError(where, "The " + Self.Name + "(what) method expects an integer parameter. " + _
		    "Instead got " + VariantType(arguments(0)) + ".")
		  End If
		  
		  Dim what As String = TextObject(arguments(0)).value
		  
		  If Lookup.DateTimeGetter(what) Then
		    Return New BooleanObject(True)
		  ElseIf Lookup.DateTimeMethod(what) Then
		    Return New BooleanObject(True)
		  Else
		    Return New BooleanObject(False)
		  End If
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Invoke(interpreter As Interpreter, arguments() As Variant, where As Token) As Variant
		  #Pragma Unused arguments
		  #Pragma Unused interpreter
		  #Pragma Unused where
		  
		  Select Case Self.Name
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
		  Case "responds_to?"
		    Return DoRespondsTo(arguments, where)
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
		Function ToText(interpreter As Roo.Interpreter = Nil) As String
		  ' Part of the Textable interface.
		  
		  #Pragma Unused interpreter
		  
		  Return "<function " + Self.Name + ">"
		End Function
	#tag EndMethod


	#tag Property, Flags = &h0
		Name As String
	#tag EndProperty

	#tag Property, Flags = &h0
		Parent As DateTimeObject
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
