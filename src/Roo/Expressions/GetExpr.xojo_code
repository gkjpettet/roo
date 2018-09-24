#tag Class
Protected Class GetExpr
Inherits Expr
	#tag Method, Flags = &h0
		Function Accept(visitor as ExprVisitor) As Variant
		  return visitor.VisitGetExpr(self)
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor(obj as Expr, name as Token)
		  Self.Obj = obj
		  Self.Name = name
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor(obj As Expr, name As Token, indexOrKey As Expr)
		  Self.Obj = obj
		  Self.Name = name
		  Self.IndexOrKey = indexOrKey
		End Sub
	#tag EndMethod


	#tag Property, Flags = &h0
		IndexOrKey As Expr
	#tag EndProperty

	#tag Property, Flags = &h0
		Name As Token
	#tag EndProperty

	#tag Property, Flags = &h0
		Obj As Expr
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
