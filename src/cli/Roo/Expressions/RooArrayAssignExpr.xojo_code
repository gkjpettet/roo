#tag Class
Protected Class RooArrayAssignExpr
Inherits RooExpr
	#tag Method, Flags = &h0
		Function Accept(visitor As RooExprVisitor) As Variant
		  Return visitor.VisitArrayAssignExpr(Self)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor(name As RooToken, index As RooExpr, value As RooExpr, operator As RooToken)
		  Self.Name = name
		  Self.Index = index
		  Self.Value = value
		  Self.Operator = operator
		End Sub
	#tag EndMethod


	#tag Property, Flags = &h0
		Index As RooExpr
	#tag EndProperty

	#tag Property, Flags = &h0
		Name As RooToken
	#tag EndProperty

	#tag Property, Flags = &h0
		Operator As RooToken
	#tag EndProperty

	#tag Property, Flags = &h0
		Value As RooExpr
	#tag EndProperty


	#tag ViewBehavior
		#tag ViewProperty
			Name="Index"
			Visible=true
			Group="ID"
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
