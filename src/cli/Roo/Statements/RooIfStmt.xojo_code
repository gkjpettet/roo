#tag Class
Protected Class RooIfStmt
Inherits RooStmt
	#tag Method, Flags = &h0
		Function Accept(visitor As RooStmtVisitor) As Variant
		  Return visitor.VisitIfStmt(Self)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor(condition As RooExpr, thenBranch As RooStmt, orStatements() As RooOrStmt, elseBranch As RooStmt)
		  Self.Condition = condition
		  Self.ThenBranch = thenBranch
		  Self.OrStatements = orStatements
		  Self.ElseBranch = elseBranch
		End Sub
	#tag EndMethod


	#tag Property, Flags = &h0
		Condition As RooExpr
	#tag EndProperty

	#tag Property, Flags = &h0
		ElseBranch As RooStmt
	#tag EndProperty

	#tag Property, Flags = &h0
		OrStatements() As RooOrStmt
	#tag EndProperty

	#tag Property, Flags = &h0
		ThenBranch As RooStmt
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
