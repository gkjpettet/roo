#tag Class
Protected Class JSONGenerate
Implements Roo.Invokable,Roo.Textable
	#tag Method, Flags = &h0
		Function Arity() As Variant
		  ' Part of the Invokable interface.
		  ' Return the number of parameters the `generate` function requires.
		  ' JSON.generate(hash)
		  
		  Return 1
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Invoke(interpreter As Interpreter, arguments() As Variant, where As Roo.Token) As Variant
		  ' JSON.generate(what as Hash) as Text object
		  
		  #Pragma Unused interpreter
		  
		  Dim hash As Roo.Objects.HashObject
		  
		  ' Get the `hash` parameter.
		  If Not arguments(0) IsA HashObject Then
		    Raise New RuntimeError(where, _
		    "The JSON.generate(what) method expects a Hash object. Instead got " + VariantType(arguments(0)) + ".")
		  Else
		    hash = HashObject(arguments(0))
		  End If
		  
		  ' Convert the passed Roo Hash into JSON.
		  Return New TextObject(Roo.JSON.Serialise(hash))
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Shared Function JSONToRooStructure(t As Text) As Variant
		  ' Takes JSON and tries to parse it into a Roo structure - either an array or a hash.
		  ' If the passed string is not valid JSON then this methods returns Nothing.
		  
		  Return JSON.Parse(t)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function ToText(interpreter As Roo.Interpreter) As String
		  ' Part of the Textable interface.
		  ' Return this function's name.
		  
		  #Pragma Unused interpreter
		  
		  Return "<function: JSON.generate>"
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
