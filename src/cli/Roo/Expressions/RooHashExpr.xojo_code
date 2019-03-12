#tag Class
Protected Class RooHashExpr
Inherits RooExpr
	#tag Method, Flags = &h0
		Function Accept(visitor As RooExprVisitor) As Variant
		  Return visitor.VisitHashExpr(Self)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor(name As RooToken, key As RooExpr)
		  Self.Name = name
		  Self.Key = key
		End Sub
	#tag EndMethod


	#tag Property, Flags = &h0
		Key As RooExpr
	#tag EndProperty

	#tag Property, Flags = &h0
		Name As RooToken
	#tag EndProperty


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
			Name="name"
			Group="Behavior"
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
