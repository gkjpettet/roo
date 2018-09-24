#tag Class
Protected Class ClassStmt
Inherits Stmt
	#tag Method, Flags = &h0
		Function Accept(visitor as StmtVisitor) As Variant
		  return visitor.VisitClassStmt(self)
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor(name as Token, superclass as VariableExpr,  staticMethods() as FunctionStmt, methods() as FunctionStmt)
		  self.name = name
		  self.superclass = superclass
		  self.staticMethods = staticMethods
		  self.methods = methods
		End Sub
	#tag EndMethod


	#tag Property, Flags = &h0
		methods() As FunctionStmt
	#tag EndProperty

	#tag Property, Flags = &h0
		name As Token
	#tag EndProperty

	#tag Property, Flags = &h0
		staticMethods() As FunctionStmt
	#tag EndProperty

	#tag Property, Flags = &h0
		superclass As VariableExpr
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
