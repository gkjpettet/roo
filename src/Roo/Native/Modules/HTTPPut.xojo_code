#tag Class
Protected Class HTTPPut
Implements Roo.Invokable,Roo.Textable
	#tag Method, Flags = &h0
		Function Arity() As Variant
		  ' Part of the Invokable interface.
		  ' Return the number of parameters the `put` function requires.
		  ' HTTP.put(url, content) or HTTP.put(url, content, timeout)
		  
		  Return Array(2, 3)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Invoke(interpreter As Interpreter, arguments() As Variant, where As Roo.Token) As Variant
		  ' HTTP.put(url as Text, content as Textable) as Response
		  ' HTTP.put(url as Text, content as Textable, timeout as Integer) as Response
		  
		  #Pragma Unused interpreter
		  
		  ' Is networking enabled?
		  If Not Roo.NetworkingEnabled Then
		    Raise New RuntimeError(where, "Unable to send request as networking has been disabled.")
		  End If
		  
		  Dim content, url As String
		  Dim timeout As Integer = -1
		  
		  ' Get the URL parameter.
		  If Not arguments(0) IsA TextObject Then
		    Raise New RuntimeError(where, _
		    "The HTTP.put(url, content" + If(arguments.Ubound = 0, ")", ", timeout)") + _
		    "method expects the `url` parameter to be a Text object. Instead got " + _
		    VariantType(arguments(0)) + ".")
		  Else
		    url = TextObject(arguments(0)).Value
		  End If
		  
		  ' Get the content parameter.
		  If Not arguments(1) IsA Textable Then
		    Raise New RuntimeError(where, _
		    "The HTTP.put(url, content" + If(arguments.Ubound = 0, ")", ", timeout)") + _
		    "method expects the `content` parameter to have a Text representation. Instead got " + _
		    VariantType(arguments(1)) + ".")
		  Else
		    content = Textable(arguments(1)).ToText
		  End If
		  
		  ' Get the optional timeout parameter.
		  If arguments.Ubound = 2 Then
		    If Not arguments(2) IsA NumberObject Or Not NumberObject(arguments(2)).IsInteger Then
		      Raise New RuntimeError(where, _
		      "The HTTP.put(url, content, timeout) method expects the `timeout` parameter to " + _
		      "be an integer. Instead got " + VariantType(arguments(2)) + ".")
		    End If
		    ' Constrain the timeout value to be > 0 and <= 60.
		    ' Remember that Timeout is in milliseconds but Roo passes the value in seconds.
		    timeout = NumberObject(arguments(2)).Value
		    If timeout < 1 Then
		      timeout = 1000
		    ElseIf timeout > 60 Then
		      timeout = 60000
		    Else
		      timeout = timeout * 1000
		    End If
		  End If
		  
		  ' Create a basic Request object to do the PUT.
		  Dim r As New Roo.Objects.RequestObject
		  r.Body = content
		  r.URL = url
		  r.Method = "PUT"
		  r.Timeout = If(timeout = -1, r.Timeout, timeout)
		  
		  ' Send the request.
		  Return r.DoSend(where)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function ToText() As String
		  ' Part of the Textable interface.
		  ' Return this function's name.
		  
		  return "<function: HTTP.put>"
		End Function
	#tag EndMethod


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
