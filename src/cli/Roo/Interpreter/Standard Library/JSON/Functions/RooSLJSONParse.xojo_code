#tag Class
Protected Class RooSLJSONParse
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
		  
		  // JSON.parse(what as Text) as Array, Hash or Nothing
		  
		  #Pragma Unused interpreter
		  
		  // Get the `what` parameter.
		  Roo.AssertIsTextObject(where, args(0))
		  Dim what As Text = RooText(args(0)).Value.ToText
		  
		  // Parse `what` into a Roo structure (array or hash) or Nothing if not valid JSON.
		  Return Owner.Parse(what)
		  
		  Exception err
		    Return New RooNothing
		    
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function StringValue() As String
		  // Part of the Stringable interface.
		  
		  Return "<function: JSON.parse>"
		  
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
