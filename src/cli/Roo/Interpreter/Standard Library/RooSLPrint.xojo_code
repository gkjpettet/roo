#tag Class
Protected Class RooSLPrint
Implements Invokable, Stringable
	#tag Method, Flags = &h0
		Function Arity() As Variant
		  // Part of the Invokable interface.
		  // Return the number of parameters the function requires.
		  
		  Return 1
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Invoke(interpreter As RooInterpreter, args() As Variant, where As RooToken) As Variant
		  // Part of the Invokable interface.
		  // Used to "print" the passed argument. We will fire the interpreter's Print() event by calling into
		  // its HookPrint() method.
		  
		  #Pragma Unused where
		  #Pragma BreakOnExceptions False
		  
		  // Is the object passed to the print() function a custom class?
		  If args(0) IsA RooInstance And RooInstance(args(0)).Klass <> Nil Then
		    Dim override As RooFunction = RooInstance(args(0)).Klass.FindMethod(RooInstance(args(0)), "to_text")
		    If override <> Nil Then 
		      Dim funcArgs() As Variant
		      Dim overrideResult As Variant = override.Invoke(interpreter, funcArgs, where)
		      interpreter.PrintHook(Stringable(overrideResult).StringValue)
		    Else
		      // This custom class has not defined an override for the `to_text` getter.
		      interpreter.PrintHook(Stringable(args(0)).StringValue)
		    End If
		  Else
		    // Not a custom class.
		    interpreter.PrintHook(Stringable(args(0)).StringValue)
		  End If
		  
		  Return args(0)
		  
		  Exception err As NilObjectException
		    Raise New RooRuntimeError(where, _
		    "NilObjectException encountered in the standard library `print()` function")
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function StringValue() As String
		  // Part of the Stringable interface.
		  // Return this function's name.
		  
		  Return "<function: print>"
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
