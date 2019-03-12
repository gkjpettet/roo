#tag Class
Protected Class RooSLHTTPDelete
Implements Invokable, Stringable
	#tag Method, Flags = &h0
		Function Arity() As Variant
		  // Part of the Invokable interface.
		  
		  // The HTTP.delete() method takes 1 or 2 parameters.
		  Return Array(1, 2)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Invoke(interpreter As RooInterpreter, args() As Variant, where As RooToken) As Variant
		  // Part of the Invokable interface.
		  
		  // HTTP.delete(url as Text) as HTTP.Request
		  // HTTP.delete(url as Text, timeout as Integer) as HTTP.Request
		  
		  // Get the url.
		  Dim url As String = Stringable(args(0)).StringValue
		  
		  // Get the timeout.
		  Dim timeout As Integer = RooSLHTTP.kDefaultRequestTimeout
		  If args.Ubound = 1 Then
		    Roo.AssertIsPositiveInteger(where, args(1))
		    timeout = RooNumber(args(1)).Value
		  End If
		  
		  // Create a basic HTTP.Request object to make the request.
		  Dim r As New RooSLHTTPRequest(interpreter)
		  r.URL = url
		  r.Timeout = timeout
		  r.Method = RooSLHTTP.MethodType.DELETE
		  
		  // Send the request.
		  Return r.Send(where)
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function StringValue() As String
		  // Part of the Stringable interface.
		  
		  Return "<function: HTTP.delete>"
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
