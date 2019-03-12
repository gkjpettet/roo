#tag Class
Protected Class RooFunction
Implements Invokable,  Stringable
	#tag Method, Flags = &h0
		Function Arity() As Variant
		  Return Declaration.Parameters.Ubound + 1
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Bind(instance As RooInstance) As RooFunction
		  // Create a new environment nestled inside the function's original closure. Sort of a 
		  // closure-within-a-closure. 
		  // When the function is called, that environment will become the parent of the function 
		  // body’s environment.
		  // We declare "self" as a variable in that environment and bind it to the given 
		  // instance (the instance that the function is being accessed from). Now the returned 
		  // RooFunction carries around its own little persistent world where "self" is bound to the object.
		  
		  Dim environment As New RooEnvironment(Closure)
		  environment.Define("self", instance)
		  
		  Return New RooFunction(declaration, environment, IsInitialiser)
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor(declaration As RooFunctionStmt, closure As RooEnvironment, isInitialiser As Boolean)
		  Self.Declaration = declaration
		  Self.Closure = closure
		  Self.IsInitialiser = isInitialiser
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Invoke(interpreter As RooInterpreter, arguments() As Variant, where As RooToken) As Variant
		  #Pragma Unused where
		  
		  Dim environment As New RooEnvironment(Closure)
		  
		  If Declaration.Parameters <> Nil Then // Remember that getters will have a Nil parameters array.
		    For i As Integer = 0 To Declaration.Parameters.Ubound
		      environment.Define(Declaration.Parameters(i).Lexeme, arguments(i))
		    Next i
		  End If
		  
		  // Execute the body of this method/function.
		  Try
		    interpreter.ExecuteBlock(Declaration.Body, environment)
		  Catch r As RooReturn
		    // The function/method is returning.
		    If IsInitialiser Then
		      // An empty return from a class initialiser returns `self`.
		      Return Closure.GetAt(0, "self")
		    Else
		      // Return whatever the function/method returned.
		      Return r.Value
		    End If
		  end Try
		  
		  // If this invokable object is a class initialiser then we override the actual return value 
		  // and forcibly return `self`.
		  If IsInitialiser Then Return Closure.GetAt(0, "self")
		  
		  // If no return specified then return Nothing.
		  Return interpreter.Nothing
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function StringValue() As String
		  Return "<function " + Declaration.Name.Lexeme + ">"
		End Function
	#tag EndMethod


	#tag Property, Flags = &h21
		Private Closure As RooEnvironment
	#tag EndProperty

	#tag Property, Flags = &h0
		Declaration As RooFunctionStmt
	#tag EndProperty

	#tag Property, Flags = &h21
		Private IsInitialiser As Boolean
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
