#tag Class
Protected Class HTTPGet
Implements Roo.Invokable,Roo.Textable
	#tag Method, Flags = &h0
		Function Arity() As Variant
		  ' Part of the Invokable interface.
		  ' Return the number of parameters the `get` function requires.
		  ' HTTP.get(url) or HTTP.get(url, timeout)
		  
		  Return Array(1, 2)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Invoke(interpreter As Interpreter, arguments() As Variant, where As Roo.Token) As Variant
		  ' HTTP.get(url as Text) as Request
		  ' HTTP.get(url as Text, timeout as Integer) as Request
		  
		  #Pragma Unused interpreter
		  
		  ' Is networking enabled?
		  If Not Roo.NetworkingEnabled Then
		    Raise New RuntimeError(where, "Unable to send request as networking has been disabled.")
		  End If
		  
		  Dim url As String
		  Dim timeout As Integer = -1
		  
		  ' Get the URL parameter.
		  If Not arguments(0) IsA TextObject Then
		    Raise New RuntimeError(where, _
		    "The HTTP.get(url" + If(arguments.Ubound = 0, ")", ", timeout)") + "method expects the `url` " + _
		    "parameter to be a Text object. Instead got " + VariantType(arguments(0)) + ".")
		  Else
		    url = TextObject(arguments(0)).Value
		  End If
		  
		  ' Get the optional timeout parameter.
		  If arguments.Ubound = 1 Then
		    If Not arguments(1) IsA NumberObject Or Not NumberObject(arguments(1)).IsInteger Then
		      Raise New RuntimeError(where, "The HTTP.get(url, timeout) method expects the `timeout` " + _
		      "parameter to be an integer. Instead got " + VariantType(arguments(0)) + ".")
		    End If
		    ' Constrain the timeout value to be > 0 and <= 60.
		    ' Remember that Timeout is in milliseconds but Roo passes the value in seconds.
		    timeout = NumberObject(arguments(1)).Value
		    If timeout < 1 Then
		      timeout = 1000
		    ElseIf timeout > 60 Then
		      timeout = 60000
		    Else
		      timeout = timeout * 1000
		    End If
		  End If
		  
		  ' Create a basic Request object to do the GET.
		  Dim r As New Roo.Objects.RequestObject
		  r.URL = url
		  r.Method = "GET"
		  r.Timeout = If(timeout = -1, r.Timeout, timeout)
		  
		  ' Send the request.
		  Return r.DoSend(where)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function ToText(interpreter As Roo.Interpreter) As String
		  ' Part of the Textable interface.
		  ' Return this function's name.
		  
		  #Pragma Unused interpreter
		  
		  Return "<function: HTTP.get>"
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
