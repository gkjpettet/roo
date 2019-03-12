#tag Class
Protected Class RooSLAssert
Implements Invokable, Stringable
	#tag Method, Flags = &h0
		Function Arity() As Variant
		  // Part of the Invokable interface.
		  // assert(condition) As Boolean
		  // assert(condition, message) As Boolean
		  Return Array(1, 2)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Invoke(interpreter As RooInterpreter, args() As Variant, where As RooToken) As Variant
		  // Part of the Invokable interface.
		  // If the passed condition is truthy then return True. If its falsey then raise a runtime error.
		  // Remember, only Nil, Nothing and False are False. Everything else is True.
		  // Can take an optional message to append to the raised runtime error.
		  
		  #Pragma BreakOnExceptions False
		  #Pragma Unused interpreter
		  
		  Dim message As String = ""
		  
		  // Has a message been provided?
		  If args.Ubound = 1 Then message = Stringable(args(1)).StringValue
		  
		  If args(0) = Nil Or args(0) IsA RooNothing Then
		    Raise New RooRuntimeError(where, "Failed assertion. " + message)
		  End If
		  
		  If args(0) IsA RooBoolean And RooBoolean(args(0)).Value = False Then
		    Raise New RooRuntimeError(where, "Failed assertion. " + message)
		  End If
		  
		  // Must be truthy.
		  Return New RooBoolean(True)
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function StringValue() As String
		  // Part of the Stringable interface.
		  // Return this function's name.
		  
		  Return "<function: assert>"
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
