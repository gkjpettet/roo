#tag Class
Protected Class ResponseObject
Inherits RooClass
Implements Roo.Textable
	#tag Method, Flags = &h0
		Sub Constructor()
		  ' Calling the overridden superclass constructor.
		  Super.Constructor(Nil)
		  
		  Self.Body = New Roo.Objects.TextObject("")
		  Self.Cookies = New Roo.Objects.HashObject
		  Self.Headers = New Roo.Objects.HashObject
		  
		  Self.StatusCode = 408 ' Default to request timeout.
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Get(name As Token) As Variant
		  ' Override RooInstance.Get().
		  
		  If Lookup.ResponseMethod(name.Lexeme) Then Return New ResponseObjectMethod(Self, name.Lexeme)
		  
		  If Lookup.ResponseGetter(name.Lexeme) Then
		    Select Case name.lexeme
		    Case "body"
		      Return Self.Body
		    Case "content_disposition"
		      Return Self.Headers.Map.Lookup("Content-Disposition", New TextObject(""))
		    Case "content_encoding"
		      Return Self.Headers.Map.Lookup("Content-Encoding", New TextObject(""))
		    Case "content_length"
		      Return Self.Headers.Map.Lookup("Content-Length", New TextObject(""))
		    Case "content_type"
		      Return Self.Headers.Map.Lookup("Content-Type", New TextObject(""))
		    Case "cookies"
		      Return Self.Cookies
		    Case "headers"
		      Return Self.Headers
		    Case "last_modified"
		      Return Self.Headers.Map.Lookup("Last-Modified", New TextObject(""))
		    Case "location"
		      Return Self.Headers.Map.Lookup("Location", New TextObject(""))
		    Case "nothing?"
		      Return New BooleanObject(False)
		    Case "number?"
		      Return New BooleanObject(False)
		    Case "status"
		      Return New NumberObject(Self.StatusCode)
		    Case "to_text"
		      Return New TextObject(Self.ToText)
		    Case "type"
		      Return New TextObject("Response")
		    End Select
		  End If
		  
		  Raise New RuntimeError(name, "Response objects have no method named `" + name.Lexeme + "`.")
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Set(name As Roo.Token, value As Variant)
		  #Pragma Unused value
		  
		  ' Override RooInstance.Set
		  ' We want to prevent both the creating of new fields on Response objects and setting their values 
		  ' EXCEPT for a few specific permitted values.
		  
		  Select Case name.Lexeme
		    ' No setters defined.
		  Else
		    Raise New RuntimeError(name, "Cannot create or set fields on Response objects " +_ 
		    "(Response." + name.Lexeme + ").")
		  End Select
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function ToText(interpreter As Roo.Interpreter = Nil) As String
		  ' Part of the Textable interface.
		  
		  #Pragma Unused interpreter
		  
		  Return "<Response instance>"
		End Function
	#tag EndMethod


	#tag Property, Flags = &h0
		Body As Roo.Objects.TextObject
	#tag EndProperty

	#tag Property, Flags = &h0
		ContentType As String
	#tag EndProperty

	#tag Property, Flags = &h0
		Cookies As Roo.Objects.HashObject
	#tag EndProperty

	#tag Property, Flags = &h0
		Headers As Roo.Objects.HashObject
	#tag EndProperty

	#tag Property, Flags = &h0
		StatusCode As Integer
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
		#tag ViewProperty
			Name="ContentType"
			Group="Behavior"
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="StatusCode"
			Group="Behavior"
			Type="Integer"
		#tag EndViewProperty
	#tag EndViewBehavior
End Class
#tag EndClass
