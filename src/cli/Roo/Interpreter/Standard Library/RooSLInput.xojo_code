#tag Class
Protected Class RooSLInput
Implements Invokable, Stringable
	#tag Method, Flags = &h0
		Function Arity() As Variant
		  // Part of the Invokable interface.
		  // The input() function has two definitions:
		  // input()
		  // input(prompt As TextObject)
		  
		  Return Array(0, 1)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Invoke(interpreter As RooInterpreter, arguments() As Variant, where As RooToken) As Variant
		  // Part of the Invokable interface.
		  // Used to get input from the user into the running script. 
		  // We will fire the interpreter's Input() event by calling into its InputHook() method.
		  
		  Dim prompt As String = ""
		  
		  // Has a prompt been provided?
		  If arguments.Ubound = 0 Then prompt = Stringable(arguments(0)).StringValue
		  
		  // Fire the intepreter's Input() event.
		  Dim userInput As Variant = interpreter.InputHook(prompt)
		  
		  // Convert the user-provided value into a runtime representation.
		  Return New RooText(userInput)
		  
		  Exception err
		    Raise New RooRuntimeError(where, "If a parameter is passed to the input() method, " + _
		    "it must have a text representation.")
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function StringValue() As String
		  // Part of the Stringable interface.
		  // Return this function's name.
		  
		  Return "<function: input>"
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
