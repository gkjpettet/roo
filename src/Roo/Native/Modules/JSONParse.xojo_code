#tag Class
Protected Class JSONParse
Implements Roo.Invokable,Roo.Textable
	#tag Method, Flags = &h0
		Function Arity() As Variant
		  ' Part of the Invokable interface.
		  ' Return the number of parameters the `parse` function requires.
		  ' JSON.parse(what)
		  
		  Return 1
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Invoke(interpreter As Interpreter, arguments() As Variant, where As Roo.Token) As Variant
		  ' JSON.parse(what as Text) as Array, Hash or Nothing
		  
		  #Pragma Unused interpreter
		  
		  Dim what As Text
		  
		  ' Get the `what` parameter.
		  If Not arguments(0) IsA TextObject Then
		    Raise New RuntimeError(where, _
		    "The JSON.parse(what) method expects a Text object. Instead got " + VariantType(arguments(0)) + ".")
		  Else
		    Try
		      what = TextObject(arguments(0)).Value.ToText
		    Catch err
		      ' Unable to convert `what` to valid UTF-8 encoded Text.
		      Return New NothingObject
		    End Try
		  End If
		  
		  ' Parse `what` into a Roo structure (array or hash) or Nothing if not valid JSON.
		  Return JSONToRooStructure(what)
		  
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
		  
		  Return "<function: JSON.parse>"
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
