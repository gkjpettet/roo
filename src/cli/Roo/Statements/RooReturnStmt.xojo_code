#tag Class
Protected Class RooReturnStmt
Inherits RooStmt
	#tag Method, Flags = &h0
		Function Accept(visitor As RooStmtVisitor) As Variant
		  Return visitor.VisitReturnStmt(Self)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor(keyword As RooToken, value As RooExpr)
		  Self.Keyword = keyword
		  Self.Value = value
		  
		End Sub
	#tag EndMethod


	#tag Property, Flags = &h0
		Keyword As RooToken
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
