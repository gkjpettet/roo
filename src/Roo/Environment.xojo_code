#tag Class
Protected Class Environment
	#tag Method, Flags = &h0
		Function Ancestor(distance as Integer) As Environment
		  dim environment as Environment = self
		  
		  ' Walk a fixed number of hops up the parent chain and return the environment at that point.
		  dim target as Integer = distance - 1
		  for i as Integer = 0 to target
		    environment = environment.enclosing
		  next i
		  
		  return environment
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Assign(name as Token, value as Variant)
		  ' Assign `value` to an existing variable named `name`. We first inspect this environment but if we don't find
		  ' the variable in it we recursively look up the enclosing environment chain.
		  
		  if self.values.HasKey(name.lexeme) then 
		    self.values.Value(name.lexeme) = value
		    return
		  end if
		  
		  if enclosing <> Nil then 
		    enclosing.Assign(name, value)
		    return
		  end if
		  
		  raise new RuntimeError(name, "Undefined variable `" + name.lexeme + "`.")
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub AssignAt(distance as Integer, name as Token, value as Variant)
		  Ancestor(distance).values.Value(name.lexeme) = value
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor()
		  values = new StringToVariantHashMapMBS
		  self.enclosing = Nil
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor(enclosing as Environment)
		  values = new StringToVariantHashMapMBS
		  self.enclosing = enclosing
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Define(name as String, value as Variant)
		  values.Value(name) = value
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Get(name as Token) As Variant
		  if values.HasKey(name.lexeme) then return values.Lookup(name.lexeme, Nil)
		  
		  if enclosing <> Nil then return enclosing.Get(name)
		  
		  raise new RuntimeError(name, "Undefined variable `" + name.lexeme + "`.")
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function GetAt(distance as Integer, name as String) As Variant
		  return Ancestor(distance).values.Value(name)
		End Function
	#tag EndMethod


	#tag Property, Flags = &h0
		enclosing As Environment
	#tag EndProperty

	#tag Property, Flags = &h0
		values As StringToVariantHashMapMBS
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
