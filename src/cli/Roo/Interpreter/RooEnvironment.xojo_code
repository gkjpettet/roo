#tag Class
Protected Class RooEnvironment
	#tag Method, Flags = &h0
		Function Ancestor(distance As Integer) As RooEnvironment
		  Dim environment As RooEnvironment = Self
		  
		  // Walk a fixed number of hops up the parent chain and return the environment at that point.
		  Dim target As Integer = distance - 1
		  For i As Integer = 0 To target
		    environment = environment.Enclosing
		  Next i
		  
		  Return environment
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Assign(name As RooToken, value As Variant)
		  // Assign `value` to an existing variable named `name`. 
		  // We first inspect this environment but if we don't find the variable in it then we 
		  // recursively look up the enclosing environment chain.
		  
		  #Pragma BreakOnExceptions False
		  
		  If Self.Values.HasKey(name.Lexeme) Then 
		    Self.Values.Value(name.Lexeme) = value
		    Return
		  End If
		  
		  If Enclosing <> Nil Then 
		    Enclosing.Assign(name, value)
		    Return
		  End If
		  
		  Raise New RooRuntimeError(name, "Undefined variable `" + name.Lexeme + "`.")
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub AssignAt(distance As Integer, name As RooToken, value As Variant)
		  Ancestor(distance).Values.Value(name.Lexeme) = value
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor()
		  Values = Roo.CaseSensitiveDictionary
		  Enclosing = Nil
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor(enclosing As RooEnvironment)
		  Values = Roo.CaseSensitiveDictionary
		  Self.Enclosing = enclosing
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Define(name As String, value As Variant)
		  Self.Values.Value(name) = value
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Get(name As RooToken) As Variant
		  #Pragma BreakOnExceptions False
		  
		  If Values.HasKey(name.Lexeme) Then Return Values.Lookup(name.Lexeme, Nil)
		  
		  If Enclosing <> Nil Then Return Enclosing.Get(name)
		  
		  Raise New RooRuntimeError(name, "Undefined variable `" + name.Lexeme + "`.")
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function GetAt(distance As Integer, name As String) As Variant
		  Return Ancestor(distance).Values.Value(name)
		End Function
	#tag EndMethod


	#tag Property, Flags = &h0
		Enclosing As RooEnvironment
	#tag EndProperty

	#tag Property, Flags = &h0
		Values As Xojo.Core.Dictionary
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
