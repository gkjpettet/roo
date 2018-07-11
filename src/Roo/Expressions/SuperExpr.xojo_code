#tag Class
Protected Class SuperExpr
Inherits Expr
	#tag Method, Flags = &h0
		Function Accept(visitor as ExprVisitor) As Variant
		  return visitor.VisitSuperExpr(self)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor(keyword as Token, method as Token)
		  self.keyword = keyword
		  self.method = method
		  
		End Sub
	#tag EndMethod


	#tag Property, Flags = &h0
		keyword As Token
	#tag EndProperty

	#tag Property, Flags = &h0
		method As Token
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
