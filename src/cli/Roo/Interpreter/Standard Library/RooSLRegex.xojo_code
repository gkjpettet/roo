#tag Class
Protected Class RooSLRegex
Implements Invokable, Stringable
	#tag Method, Flags = &h0
		Function Arity() As Variant
		  // Part of the Invokable interface.
		  // There are two Regex constructor function signatures:
		  // var r1 = Regex(PATTERN)
		  // var d2 = Regex(PATTERN, OPTIONS)
		  
		  Return Array(1, 2)
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function DoRegexFromPattern(argument As Variant, where As RooToken) As RooRegex
		  // Returns a new Regex object, instantiated with the specified pattern and default options.
		  
		  // Get the pattern.
		  Dim pattern As String = Stringable(argument).StringValue
		  
		  // Create and return the new object.
		  Return New RooRegex(where, pattern, "")
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function DoRegexFromPatternWithOptions(arg1 As Variant, arg2 As Variant, where As RooToken) As RooRegex
		  // Returns a new Regex object, instantiated with the specified pattern and the 
		  // specified options.
		  
		  // Get the pattern string.
		  Dim pattern As String = Stringable(arg1).StringValue
		  
		  // Get the option string.
		  Dim options As String = Stringable(arg2).StringValue
		  
		  // Create and return the new object.
		  Return New RooRegex(where, pattern, options)
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Invoke(interpreter As RooInterpreter, arguments() As Variant, where As RooToken) As Variant
		  // Part of the Invokable interface.
		  // Create a new Regex object instance.
		  // There are two Regex constructor function signatures:
		  // var r1 = Regex(PATTERN)
		  // var d2 = Regex(PATTERN, OPTIONS)
		  
		  #Pragma Unused interpreter
		  
		  If arguments.Ubound = 0 Then // Regex(PATTERN)
		    Return DoRegexFromPattern(arguments(0), where)
		  ElseIf arguments.Ubound = 1 Then // Regex(PATTERN, OPTIONS)
		    Return DoRegexFromPatternWithOptions(arguments(0), arguments(1), where)
		  End If
		  
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function StringValue() As String
		  // Part of the Stringable interface.
		  // Return this function's name.
		  
		  Return "<function: Regex>"
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
