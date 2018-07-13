#tag Class
Protected Class MathsRandomInt
Implements Roo.Invokable,Roo.Textable
	#tag Method, Flags = &h0
		Function Arity() As Variant
		  ' Part of the Invokable interface.
		  ' Return the number of parameters the `randomInt` function requires.
		  
		  return 2
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Invoke(interpreter as Interpreter, arguments() as Variant, where as Token) As Variant
		  #pragma Unused interpreter
		  #pragma Unused arguments
		  #pragma Unused where
		  
		  dim min, max as Integer
		  
		  ' Check the passed arguments are both integers.
		  if not arguments(0) isA NumberObject or not NumberObject(arguments(0)).IsInteger then
		    raise new RuntimeError(where, "The Maths.randomInt(min, max) method expects the `min` parameter " +_
		    "to be an integer. Instead got " + VariantType(arguments(0)) + ".")
		  else
		    min = NumberObject(arguments(0)).value
		  end if
		  if not arguments(1) isA NumberObject or not NumberObject(arguments(0)).IsInteger then
		    raise new RuntimeError(where, "The Maths.randomInt(min, max) method expects the `max` parameter " +_
		    "to be an integer. Instead got " + VariantType(arguments(1)) + ".")
		  else
		    max = NumberObject(arguments(1)).value
		  end if
		  
		  return new NumberObject(Xojo.Math.RandomInt(min, max))
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function ToText() As String
		  ' Part of the Textable interface.
		  ' Return this function's name.
		  
		  return "<function: Maths.randomInt>"
		End Function
	#tag EndMethod


	#tag ViewBehavior
		#tag ViewProperty
			Name="Index"
			Visible=true
			Group="ID"
			InitialValue="-2147483648"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Left"
			Visible=true
			Group="Position"
			InitialValue="0"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Name"
			Visible=true
			Group="ID"
			Type="String"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Super"
			Visible=true
			Group="ID"
			Type="String"
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
