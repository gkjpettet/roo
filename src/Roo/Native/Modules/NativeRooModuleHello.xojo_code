#tag Class
Protected Class NativeRooModuleHello
Implements Roo.Invokable,Roo.Textable
	#tag Method, Flags = &h0
		Function Arity() As Variant
		  ' Part of the Invokable interface.
		  ' Return the number of parameters the `hello()` function requires.
		  
		  return 1
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Invoke(interpreter as Interpreter, arguments() as Variant, where as Token) As Variant
		  ' Roo.hello(what as Text) as Text
		  ' A simple method that simply says hello. For demonstration purposes.
		  ' E.g: Roo.hello("Garry") # "Hello Garry"
		  
		  #pragma Unused interpreter
		  #pragma Unused arguments
		  #pragma Unused where
		  
		  dim what as String
		  
		  ' Check the passed argument has a text representation.
		  if not arguments(0) isA Textable then
		    raise new RuntimeError(where, "The Roo.hello(who) method expects a parameter that has a text " + _
		    "representation.")
		  end if
		  
		  if arguments(0) isA TextObject then
		    what = TextObject(arguments(0)).value
		  else
		    what = Textable(arguments(0)).ToText
		  end if
		  
		  return new TextObject("Hello " + what)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function ToText() As String
		  ' Part of the Textable interface.
		  ' Return this function's name.
		  
		  return "<function: Roo.hello>"
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
