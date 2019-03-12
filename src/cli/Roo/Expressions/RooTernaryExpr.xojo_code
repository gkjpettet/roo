#tag Class
Protected Class RooTernaryExpr
Inherits RooExpr
	#tag Method, Flags = &h0
		Function Accept(visitor As RooExprVisitor) As Variant
		  Return visitor.VisitTernaryExpr(Self)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor(expression As RooExpr, thenBranch As RooExpr, elseBranch As RooExpr)
		  Self.Expression = expression
		  Self.ThenBranch = thenBranch
		  Self.ElseBranch = elseBranch
		  
		End Sub
	#tag EndMethod


	#tag Property, Flags = &h0
		ElseBranch As RooExpr
	#tag EndProperty

	#tag Property, Flags = &h0
		Expression As RooExpr
	#tag EndProperty

	#tag Property, Flags = &h0
		ThenBranch As RooExpr
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
