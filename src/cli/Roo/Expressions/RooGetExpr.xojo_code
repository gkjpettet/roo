#tag Class
Protected Class RooGetExpr
Inherits RooExpr
	#tag Method, Flags = &h0
		Function Accept(visitor As RooExprVisitor) As Variant
		  Return visitor.VisitGetExpr(Self)
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor(obj As RooExpr, name As RooToken)
		  Self.Obj = obj
		  Self.Name = name
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor(obj As RooExpr, name As RooToken, indexOrKey As RooExpr)
		  Self.Obj = obj
		  Self.Name = name
		  Self.IndexOrKey = indexOrKey
		End Sub
	#tag EndMethod


	#tag Property, Flags = &h0
		IndexOrKey As RooExpr
	#tag EndProperty

	#tag Property, Flags = &h0
		Name As RooToken
	#tag EndProperty

	#tag Property, Flags = &h0
		Obj As RooExpr
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
