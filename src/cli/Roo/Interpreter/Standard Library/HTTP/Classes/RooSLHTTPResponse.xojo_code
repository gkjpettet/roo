#tag Class
Protected Class RooSLHTTPResponse
Inherits RooInstance
Implements RooNativeClass
	#tag Method, Flags = &h0
		Function Arity() As Variant
		  // Part of the Invokable interface.
		  
		  // The HTTP.Response constructor takes no parameters.
		  Return 0
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor()
		  Super.Constructor(Nil) // No metaclass.
		  
		  Content = New RooText("")
		  Cookies = New RooHash
		  Headers = New RooHash
		  
		  // Defaults.
		  Status = 408 // Request timed out.
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function GetterWithName(name As RooToken) As Variant
		  // Part of the RooNativeClass interface.
		  
		  If StrComp(name.Lexeme, "content", 0) = 0 Then
		    Return Content
		  ElseIf StrComp(name.Lexeme, "content_disposition", 0) = 0 Then
		    Return Headers.Dict.Lookup("Content-Disposition", New RooText(""))
		  ElseIf StrComp(name.Lexeme, "content_encoding", 0) = 0 Then
		    Return Headers.Dict.Lookup("Content-Encoding", New RooText(""))
		  ElseIf StrComp(name.Lexeme, "content_length", 0) = 0 Then
		    Return Headers.Dict.Lookup("Content-Length", New RooText(""))
		  ElseIf StrComp(name.Lexeme, "content_type", 0) = 0 Then
		    Return Headers.Dict.Lookup("Content-Type", New RooText(""))
		  ElseIf StrComp(name.Lexeme, "cookies", 0) = 0 Then
		    Return Cookies
		  ElseIf StrComp(name.Lexeme, "headers", 0) = 0 Then
		    Return Headers
		  ElseIf StrComp(name.Lexeme, "last_modified", 0) = 0 Then
		    Return Headers.Dict.Lookup("Last-Modified", New RooText(""))
		  ElseIf StrComp(name.Lexeme, "location", 0) = 0 Then
		    Return Headers.Dict.Lookup("Location", New RooText(""))
		  ElseIf StrComp(name.Lexeme, "status", 0) = 0 Then
		    Return New RooNumber(Status)
		  End If
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function HasGetterWithName(name As String) As Boolean
		  // Part of the RooNativeClass interface.
		  
		  Return RooSLCache.HTTPResponseGetters.HasKey(name)
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function HasMethodWithName(name As String) As Boolean
		  // Part of the RooNativeClass interface.
		  
		  #Pragma Unused name
		  
		  // The HTTP.Response object has no methods.
		  Return False
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Invoke(interpreter As RooInterpreter, arguments() As Variant, where As RooToken) As Variant
		  // Part of the Invokable interface.
		  
		  #Pragma Unused arguments
		  #Pragma Unused interpreter
		  #Pragma Unused where
		  
		  // A script has called the HTTP.Response constructor. Just return this instance.
		  Return Self
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function MethodWithName(name As RooToken) As Invokable
		  // Part of the RooNativeClass interface.
		  
		  Raise New RooRuntimeError(name, "The HTTP.Response object has no method named `" + _
		  name.Lexeme + "`.")
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function StringValue() As String
		  // Part of the Stringable interface.
		  
		  Return "<HTTP.Response instance>"
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Type() As String
		  // Part of the RooNativeClass interface.
		  
		  Return "HTTP Response"
		End Function
	#tag EndMethod


	#tag Property, Flags = &h0
		Content As RooText
	#tag EndProperty

	#tag Property, Flags = &h0
		ContentType As String
	#tag EndProperty

	#tag Property, Flags = &h0
		Cookies As RooHash
	#tag EndProperty

	#tag Property, Flags = &h0
		Headers As RooHash
	#tag EndProperty

	#tag Property, Flags = &h0
		#tag Note
			Defaults to 408 (request timed out).
		#tag EndNote
		Status As Integer
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
			Name="Status"
			Group="Behavior"
			InitialValue="408"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="ContentType"
			Group="Behavior"
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
	#tag EndViewBehavior
End Class
#tag EndClass
