#tag Class
Protected Class RooBreakStmt
Inherits RooStmt
	#tag Method, Flags = &h0
		Function Accept(visitor As RooStmtVisitor) As Variant
		  Return visitor.VisitBreakStmt(Self)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor(keyword As RooToken, condition As RooExpr)
		  Self.Keyword = keyword
		  Self.Condition = condition
		End Sub
	#tag EndMethod


	#tag Property, Flags = &h0
		Condition As RooExpr
	#tag EndProperty

	#tag Property, Flags = &h0
		Keyword As RooToken
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
