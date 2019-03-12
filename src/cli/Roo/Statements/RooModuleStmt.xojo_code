#tag Class
Protected Class RooModuleStmt
Inherits RooStmt
	#tag Method, Flags = &h0
		Function Accept(visitor As RooStmtVisitor) As Variant
		  Return visitor.VisitModuleStmt(Self)
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor(name As RooToken, modules() As RooModuleStmt, classes() As RooClassStmt, methods() As RooFunctionStmt)
		  Self.Name = name
		  Self.Modules = modules
		  Self.Classes = classes
		  Self.Methods = methods
		End Sub
	#tag EndMethod


	#tag Property, Flags = &h0
		Classes() As RooClassStmt
	#tag EndProperty

	#tag Property, Flags = &h0
		Methods() As RooFunctionStmt
	#tag EndProperty

	#tag Property, Flags = &h0
		Modules() As RooModuleStmt
	#tag EndProperty

	#tag Property, Flags = &h0
		Name As RooToken
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
