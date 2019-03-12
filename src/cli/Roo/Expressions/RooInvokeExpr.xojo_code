#tag Class
Protected Class RooInvokeExpr
Inherits RooExpr
	#tag Method, Flags = &h0
		Function Accept(visitor As RooExprVisitor) As Variant
		  Return visitor.VisitInvokeExpr(Self)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor(invokee As RooExpr, paren As RooToken, arguments() As RooExpr)
		  Self.Invokee = invokee
		  Self.Paren = paren
		  Self.Arguments = arguments
		End Sub
	#tag EndMethod


	#tag Property, Flags = &h0
		Arguments() As RooExpr
	#tag EndProperty

	#tag Property, Flags = &h0
		Invokee As RooExpr
	#tag EndProperty

	#tag Property, Flags = &h0
		Paren As RooToken
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
