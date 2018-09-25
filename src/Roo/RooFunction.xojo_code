#tag Class
Protected Class RooFunction
Implements Invokable,Textable
	#tag Method, Flags = &h0
		Function Arity() As Variant
		  ' Part of the Invokable interface.
		  
		  return declaration.parameters.Ubound + 1
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Bind(instance as RooInstance) As RooFunction
		  ' Create a new environment nestled inside the function's original closure. Sort of a closure-within-a-closure. 
		  ' When the function is called, that environment will become the parent of the function body’s environment.
		  ' We declare "self" as a variable in that environment and bind it to the given instance, 
		  ' the instance that the function is being accessed from. Now the returned RooFunction carries around its own 
		  ' little persistent world where "self" is bound to the object.
		  
		  dim environment as new Environment(self.closure)
		  environment.Define("self", instance)
		  return new RooFunction(declaration, environment, self.isInitialiser)
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor(declaration as FunctionStmt, closure as Environment, isInitialiser as Boolean)
		  self.declaration = declaration
		  self.closure = closure
		  self.isInitialiser = isInitialiser
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Invoke(interpreter as Interpreter, arguments() as Variant, where as Token) As Variant
		  ' Part of the Invokable interface.
		  
		  #pragma Unused where
		  
		  dim environment as new Environment(self.closure)
		  
		  dim i, limit as Integer
		  if declaration.parameters <> Nil then ' Remember that getters will have a Nil parameters array.
		    limit = declaration.parameters.Ubound
		    for i = 0 to limit
		      environment.Define(declaration.parameters(i).lexeme, arguments(i))
		    next i
		  end if
		  
		  try
		    interpreter.ExecuteBlock(declaration.body, environment)
		  catch ret as ReturnException
		    if self.isInitialiser then
		      return self.closure.GetAt(0, "self") ' An empty return from a class initialiser returns `self`.
		    else
		      return ret.value
		    end if
		  end try
		  
		  ' If this function is a class initialiser then we override the actual return value 
		  ' and forcibly return `self`.
		  if isInitialiser then return self.closure.GetAt(0, "self")
		  
		  return interpreter.nothing
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function ToText(interpreter As Roo.Interpreter) As String
		  ' Part of the Textable interface.
		  
		  #Pragma Unused interpreter
		  
		  Return "<function " + declaration.name.lexeme + ">"
		End Function
	#tag EndMethod


	#tag Property, Flags = &h21
		Private closure As Environment
	#tag EndProperty

	#tag Property, Flags = &h0
		declaration As FunctionStmt
	#tag EndProperty

	#tag Property, Flags = &h21
		Private isInitialiser As Boolean
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
