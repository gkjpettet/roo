#tag Class
Protected Class Input
Implements Roo.Invokable,Roo.Textable
	#tag Method, Flags = &h0
		Function Arity() As Variant
		  ' Return the number of parameters the function requires.
		  
		  return Array(0, 1)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Invoke(interpreter as Interpreter, arguments() as Variant, where as Token) As Variant
		  ' Used to get input into the running script. We will fire the interpreter's Input() event by calling into
		  ' its HookInput() method.
		  
		  dim prompt as String = ""
		  
		  if arguments.Ubound = 0 then
		    if not arguments(0) isA Textable then
		      raise new RuntimeError(where, "If a parameter is passed to the input() method, it must have a " + _
		      "text representation.")
		    else
		      if arguments(0) isA TextObject then
		        prompt = TextObject(arguments(0)).value
		      else
		        prompt = Textable(arguments(0)).ToText
		      end if
		    end if
		  end if
		  
		  dim userInput as Variant = interpreter.HookInput(prompt)
		  if userInput.IsNumeric then
		    return new NumberObject(userInput.DoubleValue)
		  elseif StrComp(userInput, "True", 0) = 0 then
		    return new BooleanObject(True)
		  elseif StrComp(userInput, "False", 0) = 0 then
		    return new BooleanObject(False)
		  else
		    return new TextObject(userInput)
		  end if
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function ToText() As String
		  ' Return this function's name.
		  
		  return "<function: input>"
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
