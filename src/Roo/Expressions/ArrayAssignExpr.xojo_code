#tag Class
Protected Class ArrayAssignExpr
Inherits Expr
	#tag Method, Flags = &h0
		Function Accept(visitor as ExprVisitor) As Variant
		  return visitor.VisitArrayAssignExpr(self)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor(name as Token, index as Expr, value as Expr, operator as Token)
		  self.name = name
		  self.index = index
		  self.value = value
		  self.operator = operator
		End Sub
	#tag EndMethod


	#tag Property, Flags = &h0
		index As Expr
	#tag EndProperty

	#tag Property, Flags = &h0
		name As Token
	#tag EndProperty

	#tag Property, Flags = &h0
		operator As Token
	#tag EndProperty

	#tag Property, Flags = &h0
		value As Expr
	#tag EndProperty


	#tag ViewBehavior
		#tag ViewProperty
			Name="index"
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
