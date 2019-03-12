#tag Class
Protected Class RooSLJSONGenerate
Implements Invokable, Stringable
	#tag Method, Flags = &h0
		Function Arity() As Variant
		  // Part of the Invokable interface.
		  
		  Return 1
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor(owner As RooSLJSON)
		  Self.Owner = owner
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Invoke(interpreter As RooInterpreter, args() As Variant, where As RooToken) As Variant
		  // Part of the Invokable interface.
		  
		  // JSON.generate(what as Hash) as Text object or Nothing
		  
		  #Pragma Unused interpreter
		  
		  Dim h As RooHash
		  
		  // Ensure that a Hash has been passed.
		  Roo.AssertIsHash(where, args(0))
		  
		  // Get the `hash` parameter.
		  h = RooHash(args(0))
		  
		  // Convert the passed Roo Hash into JSON.
		  Return New RooText(Owner.Serialise(h))
		  
		  Exception err
		    Return New RooNothing
		    
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function StringValue() As String
		  // Part of the Stringable interface.
		  
		  Return "<function: JSON.generate>"
		  
		End Function
	#tag EndMethod


	#tag Property, Flags = &h0
		Owner As RooSLJSON
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
