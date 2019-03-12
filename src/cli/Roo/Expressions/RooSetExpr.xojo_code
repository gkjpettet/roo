#tag Class
Protected Class RooSetExpr
Inherits RooExpr
	#tag Method, Flags = &h0
		Function Accept(visitor As RooExprVisitor) As Variant
		  Return visitor.VisitSetExpr(Self)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor(obj As RooExpr, name As RooToken, value As RooExpr, operator As RooToken)
		  Self.Obj = obj
		  Self.Name = name
		  Self.Value = value
		  Self.Operator = operator
		End Sub
	#tag EndMethod


	#tag Property, Flags = &h0
		Name As RooToken
	#tag EndProperty

	#tag Property, Flags = &h0
		Obj As RooExpr
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
