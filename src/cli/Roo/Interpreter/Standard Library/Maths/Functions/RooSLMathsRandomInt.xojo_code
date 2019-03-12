#tag Class
Protected Class RooSLMathsRandomInt
Implements Invokable, Stringable
	#tag Method, Flags = &h0
		Function Arity() As Variant
		  // Part of the Invokable interface.
		  
		  // The Maths.random_nt() method takes 2 arguments.
		  Return 2
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Invoke(interpreter As RooInterpreter, arguments() As Variant, where As RooToken) As Variant
		  // Part of the Invokable interface.
		  #Pragma Unused interpreter
		  
		  Dim min, max As Integer
		  
		  // Check the passed arguments are both integers.
		  Roo.AssertAreIntegers(where, arguments(0), arguments(1))
		  min = RooNumber(arguments(0)).Value
		  max = RooNumber(arguments(1)).Value
		  
		  // Return a random integer between min and max as a Roo Number object.
		  Return New RooNumber(Xojo.Math.RandomInt(min, max))
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function StringValue() As String
		  // Part of the Stringable interface.
		  
		  Return "<function: Maths.random_int>"
		  
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
