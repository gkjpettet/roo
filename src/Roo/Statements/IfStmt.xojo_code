#tag Class
Protected Class IfStmt
Inherits Stmt
	#tag Method, Flags = &h0
		Function Accept(visitor as StmtVisitor) As Variant
		  return visitor.VisitIfStmt(self)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor(condition as Expr, thenBranch as Stmt, elseBranch as Stmt)
		  self.condition = condition
		  self.thenBranch = thenBranch
		  self.elseBranch = elseBranch
		End Sub
	#tag EndMethod


	#tag Property, Flags = &h0
		condition As Expr
	#tag EndProperty

	#tag Property, Flags = &h0
		elseBranch As Stmt
	#tag EndProperty

	#tag Property, Flags = &h0
		thenBranch As Stmt
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
