#tag Class
Protected Class HashExpr
Inherits Expr
	#tag Method, Flags = &h0
		Function Accept(visitor as ExprVisitor) As Variant
		  return visitor.VisitHashExpr(self)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor(name as Token, key as Expr)
		  self.name = name
		  self.key = key
		End Sub
	#tag EndMethod


	#tag Property, Flags = &h0
		key As Expr
	#tag EndProperty

	#tag Property, Flags = &h0
		name As Token
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
			Name="name"
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