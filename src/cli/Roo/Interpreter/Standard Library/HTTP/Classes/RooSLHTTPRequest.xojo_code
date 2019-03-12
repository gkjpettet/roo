#tag Class
Protected Class RooSLHTTPRequest
Inherits RooInstance
Implements RooNativeClass,  RooNativeSettable
	#tag Method, Flags = &h21
		Private Sub AddResponseCookies()
		  // Internal helper method.
		  // Parses the content of this request's response's Set-Cookie header (if present).
		  // If the Set-Cookie header is present then cookies are represented as name=value pairs, separated 
		  // by `;`.
		  
		  Dim rawCookies As String = Connection.ResponseHeader("Set-Cookie")
		  If rawCookies = "" Then Return
		  
		  Dim cookiePairs() As String = rawCookies.Split(";")
		  Dim cookieParts() As String
		  For Each cookie As String In cookiePairs
		    cookieParts = cookie.Split("=")
		    Try
		      Response.Cookies.Dict.Value(cookieParts(0).Trim) = New RooText(cookieParts(1).Trim)
		    Catch err
		      // Invalid cookie format. Ignore.
		    End Try
		  Next cookie
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub AddResponseHeader(headerName As String)
		  // Internal helper method.
		  // Adds the passed response header to our Response object's Headers Hash object.
		  
		  Response.Headers.Dict.Value(headerName) = New RooText(Connection.ResponseHeader(headerName))
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Arity() As Variant
		  // Part of the Invokable interface.
		  
		  // The HTTP.Request constructor takes no parameters.
		  Return 0
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor(interpreter As RooInterpreter)
		  Super.Constructor(Nil) // No metaclass.
		  
		  Self.Interpreter = interpreter
		  
		  Connection = New URLConnection
		  AddHandler Connection.ContentReceived, AddressOf ContentReceived
		  
		  Headers = New RooHash
		  Cookies = New RooHash
		  
		  // Defaults.
		  AwaitingResponse = False
		  mTimeout = RooSLHTTP.kDefaultRequestTimeout
		  URL = ""
		  Content = ""
		  MIMEType = "application/json" // Default to JSON.
		  Method = RooSLHTTP.MethodType.GET
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub ContentReceived(sender As URLConnection, theURL As String, status As Integer, responseContent As String)
		  // The contents of a page has been received.
		  
		  #Pragma Unused sender
		  #Pragma Unused theURL
		  
		  // Build the HTTP.Response object.
		  Response = New RooSLHTTPResponse
		  Response.Status = status
		  
		  // Parse the response headers (including cookies).
		  ParseResponseHeaders
		  
		  // Assign the response content.
		  Response.Content = New RooText(responseContent)
		  
		  // Flag that we've got a response, to break the loop in Send().
		  AwaitingResponse = False
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function GetterWithName(name As RooToken) As Variant
		  // Part of the RooNativeClass interface.
		  
		  If StrComp(name.Lexeme, "content", 0) = 0 Then
		    Return New RooText(Content)
		  ElseIf StrComp(name.Lexeme, "content_type", 0) = 0 Then
		    Return New RooText(ContentType)
		  ElseIf StrComp(name.Lexeme, "cookies", 0) = 0 Then
		    Return Cookies
		  ElseIf StrComp(name.Lexeme, "headers", 0) = 0 Then
		    Return Headers
		  ElseIf StrComp(name.Lexeme, "host", 0) = 0 Then
		    Return New RooText(Host)
		  ElseIf StrComp(name.Lexeme, "if_modified_since", 0) = 0 Then
		    Return New RooText(IfModifiedSince)
		  ElseIf StrComp(name.Lexeme, "method", 0) = 0 Then
		    Return New RooText(RooSLHTTP.MethodTypeAsString(Method))
		  ElseIf StrComp(name.Lexeme, "referer", 0) = 0 Then
		    Return New RooText(Referer)
		  ElseIf StrComp(name.Lexeme, "send", 0) = 0 Then
		    Return Send(name)
		  ElseIf StrComp(name.Lexeme, "timeout", 0) = 0 Then
		    Return New RooNumber(Timeout)
		  ElseIf StrComp(name.Lexeme, "url", 0) = 0 Then
		    Return New RooText(URL)
		  ElseIf StrComp(name.Lexeme, "user_agent", 0) = 0 Then
		    Return New RooText(UserAgent)
		  End If
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function HasGetterWithName(name As String) As Boolean
		  // Part of the RooNativeClass interface.
		  
		  Return RooSLCache.HTTPRequestGetters.HasKey(name)
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function HasMethodWithName(name As String) As Boolean
		  // Part of the RooNativeClass interface.
		  
		  #Pragma Unused name
		  
		  // The HTTP.Request class has no methods.
		  Return False
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Invoke(interpreter As RooInterpreter, arguments() As Variant, where As RooToken) As Variant
		  // Part of the Invokable interface.
		  
		  #Pragma Unused arguments
		  #Pragma Unused interpreter
		  #Pragma Unused where
		  
		  // A script has called the HTTP.Request constructor. Just return this instance.
		  Return Self
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function MethodWithName(name As RooToken) As Invokable
		  // Part of the RooNativeClass interface.
		  
		  Raise New RooRuntimeError(name, "The HTTP.Request object has no method named `" + _
		  name.Lexeme + "`.")
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub ParseResponseHeaders()
		  // Takes the response received by the Connection object and parses the 
		  // response headers.
		  
		  // Until Xojo provides a way to iterate through the headers, we'll just check for the most common
		  // response headers.
		  // See: https://en.wikipedia.org/wiki/List_of_HTTP_header_fields#Standard_response_fields and
		  // https://code.tutsplus.com/tutorials/http-headers-for-dummies--net-8039
		  
		  // Standard response fields.
		  AddResponseHeader("Age")
		  AddResponseHeader("Allow")
		  AddResponseHeader("Cache-Control")
		  AddResponseHeader("Connection")
		  AddResponseHeader("Content-Disposition")
		  AddResponseHeader("Content-Encoding")
		  AddResponseHeader("Content-Language")
		  AddResponseHeader("Content-Length")
		  AddResponseHeader("Content-Location")
		  AddResponseHeader("Content-MD5")
		  AddResponseHeader("Content-Range")
		  AddResponseHeader("Date")
		  AddResponseHeader("ETag")
		  AddResponseHeader("Expires")
		  AddResponseHeader("Last-Modified")
		  AddResponseHeader("Link")
		  AddResponseHeader("Location")
		  AddResponseHeader("Pragma")
		  AddResponseHeader("Proxy-Authenticate")
		  AddResponseHeader("Public-Key-Pins")
		  AddResponseHeader("Retry-After")
		  AddResponseHeader("Server")
		  AddResponseHeader("Strict-Transport-Security")
		  AddResponseHeader("Trailer")
		  AddResponseHeader("Transfer-Encoding")
		  AddResponseHeader("Tk")
		  AddResponseHeader("Upgrade")
		  AddResponseHeader("Vary")
		  AddResponseHeader("Via")
		  AddResponseHeader("Warning")
		  AddResponseHeader("WWW-Authenticate")
		  AddResponseHeader("X-Frame-Options")
		  
		  // Content-Type is a little special.
		  AddResponseHeader("Content-Type")
		  Response.ContentType = Connection.ResponseHeader("Content-Type")
		  
		  // Common non-standard response fields.
		  AddResponseHeader("Access-Control-Allow-Credentials")
		  AddResponseHeader("Access-Control-Allow-Origin")
		  AddResponseHeader("Content-Security-Policy")
		  AddResponseHeader("X-Content-Security-Policy")
		  AddResponseHeader("X-WebKit-CSP")
		  AddResponseHeader("Refresh")
		  AddResponseHeader("Status")
		  AddResponseHeader("Timing-Allow-Origin")
		  AddResponseHeader("X-Content-Duration")
		  AddResponseHeader("X-Content-Type-Options")
		  AddResponseHeader("X-Powered-By")
		  AddResponseHeader("X-Request-ID")
		  AddResponseHeader("X-Correlation-ID")
		  AddResponseHeader("X-UA-Compatible")
		  AddResponseHeader("X-XSS-Protection")
		  
		  // Handle cookies.
		  AddResponseCookies
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub RequestTimedOut()
		  // This method is called by the Timer that starts when a request is made after 
		  // Timeout seconds.
		  // It's used as a fail safe so we don't get stuck in an infinite loop if no 
		  // response is received.
		  
		  AwaitingResponse = False
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Send(where As RooToken) As Variant
		  // Request.send() as HTTP.Response
		  
		  // Check that the interpreter will allow network access for this URL.
		  If Not Interpreter.ShouldAllowNetworkAccess(URL) Then
		    Raise New RooRuntimeError(where, "Network access for the url `" + URL + _
		    "` has been prevented by the interpreter.")
		  End If
		  
		  // Store the location in the script of the invoking token.
		  SendLocation = where
		  
		  // Build the request.
		  SetRequestHeaders
		  
		  // Set the request content and type.
		  Connection.SetRequestContent(Content, MIMEType)
		  
		  // Reset the Response object we will return.
		  Response = New RooSLHTTPResponse
		  
		  // Flag that we're waiting for a response.
		  AwaitingResponse = True
		  
		  // Create a timer that will set AwaitingResponse to False after the specified 
		  // timeout period.
		  Xojo.Core.Timer.CallLater(Timeout * 1000, AddressOf RequestTimedOut)
		  
		  // Asynchronously send the request.
		  Connection.Send(RooSLHTTP.MethodTypeAsString(Method), URL, Timeout)
		  
		  // Since Xojo sends the request asynchronously, we'll go into a holding pattern...
		  Do Until Not AwaitingResponse
		    // AwaitingResponse will be set to False by the ContentReceived event or the 
		    // Timer above after Timeout seconds (in case a response is never received).
		    App.DoEvents // HACK: I hate this.
		  Loop
		  
		  // Tell the interpreter that the network was accessed.
		  Interpreter.DidAccessNetwork(URL, response.Status)
		  
		  // Return the Response object populated by the ContentReceived method.
		  Return Response
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Set(name As RooToken, value As Variant)
		  // Part of the RooNativeSettable interface.
		  
		  If StrComp(name.Lexeme, "content", 0) = 0 Then
		    SetContent(name, value)
		  ElseIf StrComp(name.Lexeme, "content_type", 0) = 0 Then
		    SetContentType(name, value)
		  ElseIf StrComp(name.Lexeme, "cookies", 0) = 0 Then
		    SetCookies(name, value)
		  ElseIf StrComp(name.Lexeme, "headers", 0) = 0 Then
		    SetHeaders(name, value)
		  ElseIf StrComp(name.Lexeme, "host", 0) = 0 Then
		    SetHost(name, value)
		  ElseIf StrComp(name.Lexeme, "if_modified_since", 0) = 0 Then
		    SetIfModifiedSince(name, value)
		  ElseIf StrComp(name.Lexeme, "method", 0) = 0 Then
		    SetMethod(name, value)
		  ElseIf StrComp(name.Lexeme, "referer", 0) = 0 Then
		    SetReferer(name, value)
		  ElseIf StrComp(name.Lexeme, "timeout", 0) = 0 Then
		    SetTimeout(name, value)
		  ElseIf StrComp(name.Lexeme, "url", 0) = 0 Then
		    SetURL(name, value)
		  ElseIf StrComp(name.Lexeme, "user_agent", 0) = 0 Then
		    SetUserAgent(name, value)
		  Else
		    Raise New RooRuntimeError(name, "The HTTP.Request data type has no property named `" + _
		    name.Lexeme + "`.")
		  End If
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub SetContent(where As RooToken, value As Variant)
		  // Request.content = Text
		  // Sets the content (body) for this request.
		  
		  // Make sure that the passed value is a Text object.
		  Content = Stringable(value).StringValue
		  
		  Exception err
		    Raise New RooRuntimeError(where, "The HTTP.Request.content property must be " + _
		    "assigned an object with a text representation.")
		    
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub SetContentType(where As RooToken, value As Variant)
		  // HTTP.Request.content_type = Text
		  
		  // Set the content type property and value in the headers Hash.
		  ContentType = Stringable(value).StringValue
		  Headers.Dict.Value("Content-Type") = New RooText(ContentType)
		  
		  Exception err
		    Raise New RooRuntimeError(where, "The HTTP.Request.content_type property must be " + _
		    "assigned an object with a text representation.")
		    
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub SetCookies(where As RooToken, value As Variant)
		  // HTTP.Request.cookies = Hash
		  // Sets this request's cookies. Accepts a Hash object.
		  
		  Roo.AssertIsHash(where, value)
		  Cookies = value
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub SetHeaders(where As Rootoken, value As Variant)
		  // HTTP.Request.headers = Hash
		  // Sets this request's headers. Accepts a Hash object.
		  
		  Roo.AssertIsHash(where, value)
		  
		  // Set the headers Hash.
		  Headers = value
		  
		  //Update our quick-access headers.
		  //Content-Type.
		  If Headers.Dict.HasKey("Content-Type") Then
		    ContentType = RooText(Headers.Dict.Value("Content-Type")).Value
		  End If
		  
		  // Host.
		  If Headers.Dict.HasKey("Host") Then
		    Host = RooText(Headers.Dict.Value("Host")).Value
		  End If
		  
		  // If-Modified-Since.
		  If Headers.Dict.HasKey("If-Modified-Since") Then
		    IfModifiedSince = RooText(Headers.Dict.Value("If-Modified-Since")).Value
		  End If
		  
		  // Referer.
		  If Headers.Dict.HasKey("Referer") Then
		    IfModifiedSince = RooText(Headers.Dict.Value("Referer")).Value
		  End If
		  
		  // User-Agent.
		  If Headers.Dict.HasKey("User-Agent") Then
		    UserAgent = RooText(Headers.Dict.Value("User-Agent")).Value
		  End If
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub SetHost(where As RooToken, value As Variant)
		  // Request.host = Text
		  
		  // Make sure that the passed value is a Text object.
		  Roo.AssertIsStringable(where, value)
		  
		  Host = Stringable(value).StringValue
		  
		  // Update the headers Hash.
		  Headers.Dict.Value("Host") = New RooText(Host)
		  
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub SetIfModifiedSince(where As RooToken, value As Variant)
		  // HTTP.Request.if_modified_since = Text or Date
		  
		  Dim ims As String
		  If value IsA RooDateTime Then
		    ims = RooDateTime(value).ToHTTPHeaderFormat
		  Else // Stringable object.
		    ims = Stringable(value).StringValue
		  End If
		  
		  // Set the content type property and value in the headers Hash.
		  IfModifiedSince = ims
		  Headers.Dict.Value("If-Modified-Since") = New RooText(IfModifiedSince)
		  
		  Exception err
		    Raise New RooRuntimeError(where, "The HTTP.Request.if_modified_since property " + _
		    "must be assigned an object with a text representation.")
		    
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub SetMethod(where As RooToken, value As Variant)
		  // Request.method = Text
		  
		  // Make sure that the passed value is a Text object.
		  Roo.AssertIsStringable(where, value)
		  
		  Dim m As String = Stringable(value).StringValue
		  
		  // Make sure that `m` is an acceptable HTTP verb.
		  Dim methodType As RooSLHTTP.MethodType
		  methodType = RooSLHTTP.MethodStringToType(m)
		  If methodType = RooSLHTTP.MethodType.Unknown Then
		    Raise New RooRuntimeError(where, "The HTTP.Request.method setter expects an " + _
		    "HTTP request method (such as `GET` or `PUT`. Instead got `" + m + "`.")
		  End If
		  
		  // Do the assignment.
		  Method = methodType
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub SetReferer(where As RooToken, value As Variant)
		  // HTTP.Request.referer = Text
		  // Sets the referring URL for this request.
		  // Referer is deliberately mispelt - https://en.wikipedia.org/wiki/HTTP_referer
		  
		  // Make sure that the passed value has a text representation.
		  Roo.AssertIsStringable(where, value)
		  
		  // Set the referer property and value in the headers Hash.
		  Referer = Stringable(value).StringValue
		  Headers.Dict.Value("Referer") = New RooText(Referer)
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub SetRequestCookies()
		  // Internal helper method.
		  // Sets any cookies that are to be passed with this request.
		  // Cookies are concatenated with semicolons separating pairs in the form <name>=<value>;
		  
		  // Bail if no cookies defined.
		  If Cookies = Nil Or Cookies.Dict.Count = 0 Then Return
		  
		  Dim name, result, value As String
		  
		  For Each entry as Xojo.Core.DictionaryEntry In Cookies.Dict
		    // Convert the key (which is the cookie's name) to a String.
		    Select Case Roo.AutoType(entry.Key)
		    Case Roo.ObjectType.XojoString, Roo.ObjectType.XojoText
		      name = entry.Key
		    Case Roo.ObjectType.XojoDouble
		      Dim d As Double = entry.Key
		      name = Str(d)
		    Case Roo.ObjectType.XojoInteger
		      Dim i As Integer = entry.Key
		      name = Str(i)
		    Case Roo.ObjectType.XojoBoolean
		      name = If(entry.Key, "True", "False")
		    Else
		      name = Stringable(entry.Key).StringValue
		    End Select
		    
		    // Convert the value to a String.
		    If entry.Value IsA RooDateTime then
		      value = RooDateTime(entry.Value).ToHTTPHeaderFormat
		    Else
		      value = Stringable(entry.Value).StringValue
		    End If
		    
		    // Concatenate the cookie.
		    result = result + name + "=" + value + ";"
		    
		  Next entry
		  
		  // Remove any superfluous semicolon.
		  result = If(result.Right(1) = ";", result.Left(result.Len - 1), result)
		  
		  // Set the request cookie(s).
		  Connection.RequestHeader("Cookie") = result
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub SetRequestHeaders()
		  // Internal helper method.
		  // Sets the headers defined in this request object's Headers dictionary to this 
		  // request's Connection object.
		  
		  Connection.ClearRequestHeaders
		  
		  Dim key, value As String
		  For Each entry As Xojo.Core.DictionaryEntry In Headers.Dict
		    // Convert the key to a String.
		    Select Case Roo.AutoType(entry.Key)
		    Case Roo.ObjectType.XojoString, Roo.ObjectType.XojoText
		      key = entry.Key
		    Case Roo.ObjectType.XojoDouble
		      Dim d As Double = entry.Key
		      key = Str(d)
		    Case Roo.ObjectType.XojoInteger
		      Dim i As Integer = entry.Key
		      key = Str(i)
		    Case Roo.ObjectType.XojoBoolean
		      key = If(entry.Key, "True", "False")
		    Else
		      key = Stringable(entry.Key).StringValue
		    End Select
		    
		    // Convert the value to a String.
		    If entry.Value IsA RooDateTime then
		      value = RooDateTime(entry.Value).ToHTTPHeaderFormat
		    Else
		      value = Stringable(entry.Value).StringValue
		    End If
		    
		    // Assign this header to this connection.
		    Connection.RequestHeader(key) = value
		  Next entry
		  
		  // Set any cookies.
		  SetRequestCookies
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub SetTimeout(where As RooToken, value As Variant)
		  // HTTP.Request.timeout As integer Number object.
		  // Specifies how many seconds the Request object should wait after making a 
		  // `Send` request before it assumes the request timed out.
		  
		  // Make sure that the passed value is an integer Number object.
		  Roo.AssertIsPositiveInteger(where, value)
		  
		  // Constrain the value to be > 0 and <= 60.
		  Dim n As Integer = RooNumber(value).Value
		  If n < 1 Then
		    n = 1
		  ElseIf n > 60 Then
		    n = 60
		  End If
		  
		  // Set the timeout.
		  Timeout = n
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub SetURL(where As RooToken, value As Variant)
		  // Sets this Request object's URL.
		  
		  // Make sure that the passed value has a text representation.
		  Roo.AssertIsStringable(where, value)
		  
		  URL = Stringable(value).StringValue
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub SetUserAgent(where As RooToken, value As Variant)
		  // HTTP.Request.user_agent = Text
		  // Sets the user agent for this request.
		  
		  // Make sure that the passed value has a text representation.
		  Roo.AssertIsStringable(where, value)
		  
		  // Set the user agent property and value in the headers Hash.
		  UserAgent = Stringable(value).StringValue
		  Headers.Dict.Value("User-Agent") = New RooText(UserAgent)
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function StringValue() As String
		  // Part of the Stringable interface.
		  
		  Return "<HTTP.Request instance>"
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Type() As String
		  // Part of the RooNativeClass interface.
		  
		  Return "HTTP.Request"
		End Function
	#tag EndMethod


	#tag Property, Flags = &h21
		Private AwaitingResponse As Boolean
	#tag EndProperty

	#tag Property, Flags = &h21
		Private Connection As URLConnection
	#tag EndProperty

	#tag Property, Flags = &h0
		Content As String
	#tag EndProperty

	#tag Property, Flags = &h21
		Private ContentType As String
	#tag EndProperty

	#tag Property, Flags = &h21
		Private Cookies As RooHash
	#tag EndProperty

	#tag Property, Flags = &h21
		Private Headers As RooHash
	#tag EndProperty

	#tag Property, Flags = &h21
		Private Host As String
	#tag EndProperty

	#tag Property, Flags = &h21
		Private IfModifiedSince As String
	#tag EndProperty

	#tag Property, Flags = &h21
		Private Interpreter As RooInterpreter
	#tag EndProperty

	#tag Property, Flags = &h0
		Method As RooSLHTTP.MethodType = RooSLHTTP.MethodType.GET
	#tag EndProperty

	#tag Property, Flags = &h0
		MIMEType As String
	#tag EndProperty

	#tag Property, Flags = &h21
		#tag Note
			Timeout is in seconds.
		#tag EndNote
		Private mTimeout As Integer
	#tag EndProperty

	#tag Property, Flags = &h21
		Private Referer As String
	#tag EndProperty

	#tag Property, Flags = &h21
		Private Response As RooSLHTTPResponse
	#tag EndProperty

	#tag Property, Flags = &h21
		#tag Note
			Stores a reference to the token in the script that invoked this request's send method.
			
		#tag EndNote
		Private SendLocation As RooToken
	#tag EndProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  Return mTimeout
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  // Constrain the timeout period to between 1 and 60 seconds.
			  If value < 1 Then
			    mTimeout = 1
			  ElseIf value > 60 Then
			    mTimeout = 60
			  Else
			    mTimeout = value
			  End If
			  
			End Set
		#tag EndSetter
		Timeout As Integer
	#tag EndComputedProperty

	#tag Property, Flags = &h0
		URL As String
	#tag EndProperty

	#tag Property, Flags = &h21
		Private UserAgent As String
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
			Name="URL"
			Group="Behavior"
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Content"
			Group="Behavior"
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="MIMEType"
			Group="Behavior"
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Timeout"
			Group="Behavior"
			Type="Integer"
		#tag EndViewProperty
	#tag EndViewBehavior
End Class
#tag EndClass
