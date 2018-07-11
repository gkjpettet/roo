#tag Class
Protected Class Clock
Implements Roo.Invokable,Roo.Textable
	#tag Method, Flags = &h0
		Function Arity() As Variant
		  ' Return the number of parameters the function requires.
		  
		  return 0
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Invoke(interpreter as Interpreter, arguments() as Variant, where as Token) As Variant
		  ' Return the number of microseconds that have elapsed since the user's computer was started.
		  
		  #pragma Unused interpreter
		  #pragma Unused arguments
		  #pragma Unused where
		  
		  return new NumberObject(Microseconds())
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function ToText() As String
		  ' Return this function's name.
		  
		  return "<function: clock>"
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
