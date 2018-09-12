#tag Class
Protected Class RequestObjectMethod
Implements Roo.Invokable,Roo.Textable
	#tag Method, Flags = &h0
		Function Arity() As Variant
		  Select Case Self.Name
		  Case "responds_to?"
		    Return 1
		  End Select
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor(parent As Roo.Objects.RequestObject, name As String)
		  Self.Parent = parent
		  Self.Name = name
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function DoRespondsTo(arguments() as Variant, where as Token) As Roo.Objects.BooleanObject
		  ' Request.responds_to?(what as Text) as Boolean.
		  
		  ' Make sure a Text argument is passed to the method.
		  If Not arguments(0) IsA TextObject Then
		    Raise New RuntimeError(where, "The " + Self.Name + "(what) method expects an integer parameter. " + _
		    "Instead got " + VariantType(arguments(0)) + ".")
		  End If
		  
		  Dim what As String = TextObject(arguments(0)).Value
		  
		  If Lookup.RequestGetter(what) Then
		    Return New BooleanObject(True)
		  ElseIf Lookup.RequestMethod(what) Then
		    Return New BooleanObject(True)
		  Else
		    Return New BooleanObject(False)
		  End If
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Invoke(interpreter as Interpreter, arguments() as Variant, where as Token) As Variant
		  #Pragma Unused arguments
		  #Pragma Unused interpreter
		  #Pragma Unused where
		  
		  Select Case Self.Name
		  Case "responds_to?"
		    Return DoRespondsTo(arguments, where)
		  End Select
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function ToText() As String
		  ' Part of the Textable interface.
		  
		  return "<function " + Self.Name + ">"
		End Function
	#tag EndMethod


	#tag Property, Flags = &h0
		Name As String
	#tag EndProperty

	#tag Property, Flags = &h0
		Parent As Roo.Objects.RequestObject
	#tag EndProperty


	#tag ViewBehavior
		#tag ViewProperty
			Name="Name"
			Visible=true
			Group="ID"
			Type="String"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Index"
			Visible=true
			Group="ID"
			InitialValue="-2147483648"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Super"
			Visible=true
			Group="ID"
			Type="String"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Left"
			Visible=true
			Group="Position"
			InitialValue="0"
			Type="Integer"
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
