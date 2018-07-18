#tag Class
Protected Class GenericObjectRespondsToMethod
Implements Invokable,Textable
	#tag Method, Flags = &h0
		Function Arity() As Variant
		  return 1
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor(parent as RooInstance)
		  self.parent = parent
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Invoke(interpreter as Interpreter, arguments() as Variant, where as Token) As Variant
		  #pragma Unused interpreter
		  
		  ' Make sure a Text argument is passed to the method.
		  if not arguments(0) isA TextObject then
		    raise new RuntimeError(where, "The responds_to?(what) method expects a text parameter. " + _
		    "Instead got " + VariantType(arguments(0)) + ".")
		  end if
		  
		  dim what as String = TextObject(arguments(0)).value
		  
		  if parent.klass.FindMethod(parent, what) = Nil then
		    return new Roo.Objects.BooleanObject(False)
		  else
		    return new Roo.Objects.BooleanObject(True)
		  end if
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function ToText() As String
		  ' Part of the Textable interface.
		  
		  return "<function responds_to?>"
		End Function
	#tag EndMethod


	#tag Property, Flags = &h0
		parent As Roo.RooInstance
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
