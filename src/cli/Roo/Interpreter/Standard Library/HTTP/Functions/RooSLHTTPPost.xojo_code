#tag Class
Protected Class RooSLHTTPPost
Implements Invokable, Stringable
	#tag Method, Flags = &h0
		Function Arity() As Variant
		  // Part of the Invokable interface.
		  // The HTTP.post() method takes either 2 or 3 parameters.
		  // HTTP.post(url, content) or HTTP.post(url, content, timeout)
		  
		  Return Array(2, 3)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Invoke(interpreter As RooInterpreter, args() As Variant, where As RooToken) As Variant
		  // Part of the Invokable interface.
		  // HTTP.post(url, content) or HTTP.post(url, content, timeout)
		  
		  // Get the url.
		  Roo.AssertIsStringable(where, args(0))
		  Dim url As String = Stringable(args(0)).StringValue
		  
		  // Get the content.
		  Roo.AssertIsStringable(where, args(1))
		  Dim content As String = Stringable(args(1)).StringValue
		  
		  // Get the timeout.
		  Dim timeout As Integer = RooSLHTTP.kDefaultRequestTimeout
		  If args.Ubound = 2 Then
		    Roo.AssertIsPositiveInteger(where, args(2))
		    timeout = RooNumber(args(2)).Value
		  End If
		  
		  // Create a basic HTTP.Request object to make the request.
		  Dim r As New RooSLHTTPRequest(interpreter)
		  r.URL = url
		  r.Content = content
		  r.Timeout = timeout
		  r.Method = RooSLHTTP.MethodType.POST
		  
		  // Send the request.
		  Return r.Send(where)
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function StringValue() As String
		  // Part of the Stringable interface.
		  
		  Return "<function: HTTP.post>"
		  
		End Function
	#tag EndMethod


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
