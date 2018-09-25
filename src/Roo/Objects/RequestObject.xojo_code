#tag Class
Protected Class RequestObject
Inherits RooClass
Implements Roo.Textable
	#tag Method, Flags = &h21
		Private Sub AddResponseCookies()
		  ' Internal helper method.
		  ' Parses the content of this request's response's Set-Cookie header (if present).
		  ' If the Set-Cookie header is present then cookies are represented as name=value pairs, separated 
		  ' by `;`.
		  
		  Dim rawCookies As String = HTTP.ResponseHeader("Set-Cookie")
		  If rawCookies = "" Then Return
		  
		  Dim cookiePairs() As String = rawCookies.Split(";")
		  Dim cookieParts() As String
		  For Each cookie As String In cookiePairs
		    cookieParts = cookie.Split("=")
		    Try
		      MyResponse.Cookies.Map.Value(cookieParts(0).Trim) = New TextObject(cookieParts(1).Trim)
		    Catch err
		      ' Invalid cookie format. Ignore.
		    End Try
		  Next cookie
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub AddResponseHeader(headerName As String)
		  ' Internal helper method.
		  ' Adds the passed response header to our Response object's `headers` Hash.
		  
		  MyResponse.Headers.Map.Value(headerName) = New TextObject(HTTP.ResponseHeader(headerName.ToText))
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor()
		  ' Calling the overridden superclass constructor.
		  Super.Constructor(Nil)
		  
		  Self.HTTP = New Xojo.Net.HTTPSocket
		  AddHandler Self.HTTP.PageReceived, AddressOf PageReceived
		  
		  Self.Headers = New Roo.Objects.HashObject
		  Self.Cookies = New Roo.Objects.HashObject
		  
		  ' Default timeout is 10 seconds.
		  Self.Timeout = 10000
		  
		  ' Default HTTP method is GET.
		  Self.Method = "GET"
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function DoSend(where As Roo.Token) As Roo.Objects.ResponseObject
		  ' Request.send as Response
		  
		  ' Is networking enabled?
		  If Not Roo.NetworkingEnabled Then
		    Raise New RuntimeError(where, "Unable to send request as networking has been disabled.")
		  End If
		  
		  ' Flag that we are waiting for a response.
		  AwaitingResponse = True
		  
		  ' Save the location of the send call.
		  SendLocation = where
		  
		  ' Create a timer that will set AwaitingResponse to False after the specified Timeout period.
		  Xojo.Core.Timer.CallLater(Self.Timeout, AddressOf RequestTimedOut)
		  
		  ' Create a new Response object to return.
		  MyResponse = New Roo.Objects.ResponseObject
		  
		  ' Build the request.
		  SetRequestHeaders
		  SetRequestContent
		  
		  ' Send the request.
		  HTTP.Send(Self.Method.ToText, Self.URL.ToText)
		  
		  ' Since Xojo sends the request asynchronously, we'll go into a holding pattern...
		  Do Until Not AwaitingResponse
		    ' AwaitingResponse will be set to False by the PageReceived event or the Timer above after 
		    ' Self.Timeout milliseconds (in case a response is never received).
		    App.DoEvents
		  Loop
		  
		  ' Return the Response object created by the PageReceived method.
		  Return MyResponse
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub DoSetContent(where As Roo.Token, value As Variant)
		  ' request.content
		  ' Sets the content (body) for this request.
		  
		  ' Make sure that the passed value is a Text object.
		  If value = Nil Or Not value IsA Roo.Objects.TextObject Then
		    Raise New Roo.RuntimeError(where, "The request.content property must be assigned a Text object.")
		  End If
		  
		  Self.Body = TextObject(value).Value
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub DoSetContentType(where As Roo.Token, value As Variant)
		  ' Request.content_type = Text
		  
		  ' Make sure that the passed value is a Text object.
		  If value = Nil Or Not value IsA Roo.Objects.TextObject Then
		    Raise New Roo.RuntimeError(where, "The request.content_type property must be assigned a Text object.")
		  End If
		  
		  ' Set the content type property and value in the headers Hash.
		  Self.ContentType = TextObject(value).Value
		  Self.Headers.Map.Value("Content-Type") = New TextObject(Self.ContentType)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub DoSetCookies(where As Roo.Token, value As Variant)
		  ' Request.cookies = Hash
		  ' Sets this request's cookies. Accepts a Hash object.
		  
		  ' Make sure that the passed value is a Hash object.
		  If value = Nil Or Not value IsA Roo.Objects.HashObject Then
		    Raise New Roo.RuntimeError(where, "The request.cookies property must be assigned a Hash object.")
		  End If
		  
		  ' Set the cookies Hash.
		  Self.Cookies = value
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub DoSetHeaders(where As Roo.Token, value As Variant)
		  ' Request.headers = Hash
		  ' Sets this request's headers. Accepts a Hash object.
		  
		  ' Make sure that the passed value is a Hash object.
		  If value = Nil Or Not value IsA Roo.Objects.HashObject Then
		    Raise New Roo.RuntimeError(where, "The request.headers property must be assigned a Hash object.")
		  End If
		  
		  ' Set the headers Hash.
		  Self.Headers = value
		  
		  ' Update our quick-access headers.
		  ' Content-Type.
		  If Self.Headers.Map.HasKey("Content-Type") Then
		    Self.ContentType = TextObject(Self.Headers.Map.Value("Content-Type")).Value
		  End If
		  ' Host.
		  If Self.Headers.Map.HasKey("Host") Then
		    Self.Host = TextObject(Self.Headers.Map.Value("Host")).Value
		  End If
		  ' If-Modified-Since.
		  If Self.Headers.Map.HasKey("If-Modified-Since") Then
		    Self.IfModifiedSince = TextObject(Self.Headers.Map.Value("If-Modified-Since")).Value
		  End If
		  ' Referer.
		  If Self.Headers.Map.HasKey("Referer") Then
		    Self.IfModifiedSince = TextObject(Self.Headers.Map.Value("Referer")).Value
		  End If
		  ' User-Agent.
		  If Self.Headers.Map.HasKey("User-Agent") Then
		    Self.UserAgent = TextObject(Self.Headers.Map.Value("User-Agent")).Value
		  End If
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub DoSetHost(where As Roo.Token, value As Variant)
		  ' Request.host = Text
		  
		  ' Make sure that the passed value is a Text object.
		  If value = Nil Or Not value IsA Roo.Objects.TextObject Then
		    Raise New Roo.RuntimeError(where, "The request.host property must be assigned a Text object.")
		  End If
		  
		  ' Set the host property and value in the headers Hash.
		  Self.Host = TextObject(value).Value
		  Self.Headers.Map.Value("Host") = New TextObject(Self.Host)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub DoSetIfModifiedSince(where As Roo.Token, value As Variant)
		  ' Request.if_modified_since = Text or Date
		  
		  ' Make sure that the passed value is either a Text object or a Date object.
		  If value = Nil Or Not value IsA Roo.Dateable Then
		    Raise New Roo.RuntimeError(where, "The request.if_modified_since property must be assigned a date.")
		  End If
		  
		  Dim d As String
		  If value IsA Roo.Objects.DateTimeObject Then
		    d = DateTimeObject(value).ToHTTPHeaderFormat
		  Else ' Text object.
		    d = TextObject(value).Value
		  End If
		  
		  ' Set the content type property and value in the headers Hash.
		  Self.IfModifiedSince = d
		  Self.Headers.Map.Value("If-Modified-Since") = New TextObject(Self.IfModifiedSince)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub DoSetMethod(where As Roo.Token, value As Variant)
		  ' request.method
		  ' Sets the HTTP method for this request.
		  
		  ' Make sure that the passed value is a Text object.
		  If value = Nil Or Not value IsA Roo.Objects.TextObject Then
		    Raise New Roo.RuntimeError(where, "The request.method property must be assigned a Text object.")
		  End If
		  
		  Self.Method = TextObject(value).Value.Uppercase
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub DoSetReferer(where As Roo.token, value As Variant)
		  ' Request.referer
		  ' Sets the referring URL for this request.
		  ' Referer is deliberately mispelt - https://en.wikipedia.org/wiki/HTTP_referer
		  
		  ' Make sure that the passed value is a Text object.
		  If value = Nil Or Not value IsA Roo.Objects.TextObject Then
		    Raise New Roo.RuntimeError(where, "The request.referer property must be assigned a Text object.")
		  End If
		  
		  ' Set the referer property and value in the headers Hash.
		  Self.Referer = TextObject(value).Value
		  Self.Headers.Map.Value("Referer") = New TextObject(Self.Referer)
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub DoSetTimeout(where As Roo.Token, value As Variant)
		  ' request.timeout As integer Number
		  ' Specifies how many seconds the Request object should wait after making a `send` request before it 
		  ' assumes the request timed out.
		  
		  ' Make sure that the passed value is an integer Number object.
		  If value = Nil Or Not value IsA Roo.Objects.NumberObject Or Not NumberObject(value).IsInteger Then
		    Raise New Roo.RuntimeError(where, _
		    "The request.timeout property must be assigned an integer Number object.")
		  End If
		  
		  ' Constrain the value to be > 0 and <= 60.
		  ' Remember that Timeout is in milliseconds but Roo passes the value in seconds.
		  Dim n As Integer = NumberObject(value).Value
		  If n < 1 Then
		    n = 1000
		  ElseIf n > 60 Then
		    n = 60000
		  Else
		    n = n * 1000
		  End If
		  
		  ' Set the timeout.
		  Self.Timeout = n
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub DoSetURL(where As Roo.Token, value As Variant)
		  ' Sets this Request object's URL.
		  
		  ' Make sure that the passed value is a Text object.
		  If value = Nil Or Not value IsA Roo.Objects.TextObject Then
		    Raise New Roo.RuntimeError(where, "The request.url property must be assigned a Text object.")
		  End If
		  
		  Self.URL = TextObject(value).Value
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub DoSetUserAgent(where As Roo.token, value As Variant)
		  ' Request.user_agent
		  ' Sets the user agent for this request.
		  
		  ' Make sure that the passed value is a Text object.
		  If value = Nil Or Not value IsA Roo.Objects.TextObject Then
		    Raise New Roo.RuntimeError(where, "The request.user_agent property must be assigned a Text object.")
		  End If
		  
		  ' Set the user agent property and value in the headers Hash.
		  Self.UserAgent = TextObject(value).Value
		  Self.Headers.Map.Value("User-Agent") = New TextObject(Self.UserAgent)
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Get(name As Token) As Variant
		  ' Override RooInstance.Get().
		  
		  If Lookup.RequestMethod(name.lexeme) Then Return New RequestObjectMethod(Self, name.lexeme)
		  
		  If Lookup.RequestGetter(name.lexeme) Then
		    Select Case name.lexeme
		    Case "content"
		      Return New TextObject(Self.Body)
		    Case "content_type"
		      Return New TextObject(Self.ContentType)
		    Case "cookies"
		      Return Self.Cookies
		    Case "headers"
		      Return Self.Headers
		    Case "host"
		      Return New TextObject(Self.Host)
		    Case "if_modified_since"
		      Return New TextObject(Self.IfModifiedSince)
		    Case "method"
		      Return New TextObject(Self.Method)
		    Case "nothing?"
		      Return New BooleanObject(False)
		    Case "number?"
		      Return New BooleanObject(False)
		    Case "referer"
		      Return New TextObject(Self.Referer)
		    Case "send"
		      Return DoSend(name)
		    Case "timeout"
		      Dim timeoutSecs As Integer = Self.Timeout / 1000
		      Return New NumberObject(timeoutSecs)
		    Case "to_text"
		      Return New TextObject(Self.ToText)
		    Case "type"
		      Return New TextObject("Request")
		    Case "url"
		      Return New TextObject(Self.URL)
		    Case "user_agent"
		      Return New TextObject(Self.UserAgent)
		    End Select
		  End If
		  
		  Raise New RuntimeError(name, "Request objects have no method named `" + name.lexeme + "`.")
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub PageReceived(sender As Xojo.Net.HTTPSocket, url As Text, HTTPStatus As Integer, content As Xojo.Core.MemoryBlock)
		  #Pragma Unused sender
		  #Pragma Unused url
		  
		  ' Flag that we've got a response (to break the loop in DoSend).
		  AwaitingResponse = False
		  
		  ' Build the ResponseObject.
		  ' ------------------------
		  ' Set the response's status code.
		  MyResponse.StatusCode = HTTPStatus
		  
		  ' Parse the response headers (including cookies).
		  ParseResponseHeaders
		  
		  ' Parse the body.
		  ParseBody(content)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub ParseBody(content As Xojo.Core.MemoryBlock)
		  ' Internal helper method.
		  ' The body of the response depends on the content type.
		  
		  ' Convert the memory block to Text.
		  Dim contentText As Text = ""
		  Dim contentString As String = ""
		  Try
		    contentText = Xojo.Core.TextEncoding.UTF8.ConvertDataToText(content)
		  Catch e1
		    ' Convert this modern framework MemoryBlock to a classic Xojo String object.
		    ' Thanks to Rob Johnston from the Xojo forums: 
		    ' https://forum.xojo.com/23227-convert-xojo-core-memoryblock-to-classic-string/0
		    contentString = CType(content.Data, MemoryBlock).StringValue(0, content.Size)
		    Try
		      contentString = DefineEncoding(contentString, Encodings.UTF8)
		    Catch e2
		      ' Treat as raw data. Ignore.
		    End Try
		  End Try
		  
		  If contentText <> "" Then
		    MyResponse.Body = New TextObject(contentText)
		  Else
		    MyResponse.Body = New TextObject(contentString)
		  End If
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub ParseResponseHeaders()
		  ' Takes the response received by our Xojo.Net.HTTPSocket (a Xojo.Core.MemoryBlock) and parses the 
		  ' response headers.
		  
		  ' Until we figure out a way to iterate through the headers, we'll just check for the most common
		  ' response headers.
		  ' See: https://en.wikipedia.org/wiki/List_of_HTTP_header_fields#Standard_response_fields and
		  ' https://code.tutsplus.com/tutorials/http-headers-for-dummies--net-8039
		  
		  ' Standard response fields.
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
		  
		  ' Content-Type is a little special.
		  AddResponseHeader("Content-Type")
		  MyResponse.ContentType = HTTP.ResponseHeader("Content-Type")
		  
		  ' Common non-standard response fields.
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
		  
		  ' Handle cookies.
		  AddResponseCookies
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub RequestTimedOut()
		  ' This method is called by the Timer that starts when a request is made after 60 seconds.
		  ' It is used as a fail safe so we don't get stuck in an infinite loop if no response is received.
		  
		  AwaitingResponse = False
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Set(name As Roo.Token, value As Variant)
		  #Pragma Unused value
		  
		  ' Override RooInstance.Set
		  ' We want to prevent both the creating of new fields on Request objects and setting their values 
		  ' EXCEPT for a few specific permitted values.
		  
		  Select Case name.Lexeme
		  Case "content"
		    DoSetContent(name, value)
		  Case "cookies"
		    DoSetCookies(name, value)
		  Case "content_type"
		    DoSetContentType(name, value)
		  Case "headers"
		    DoSetHeaders(name, value)
		  Case "host"
		    DoSetHost(name, value)
		  Case "if_modified_since"
		    DoSetIfModifiedSince(name, value)
		  Case "method"
		    DoSetMethod(name, value)
		  Case "referer"
		    DoSetReferer(name, value)
		  Case "timeout"
		    DoSetTimeout(name, value)
		  Case "url"
		    DoSetURL(name, value)
		  Case "user_agent"
		    DoSetUserAgent(name, value)
		  Else
		    Raise New RuntimeError(name, "Cannot create or set fields on Request objects " +_ 
		    "(Request." + name.lexeme + ").")
		  End Select
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub SetRequestContent()
		  ' Internal helper method.
		  ' Sets the value of our Xojo.Net.HTTPSocket's body to this Request object's body property.
		  
		  If Self.Body = "" Then Return
		  
		  ' Convert the String Body property to a modern framework MemoryBlock.
		  Dim mb As MemoryBlock = Body
		  Dim content As New Xojo.Core.MemoryBlock(mb, mb.Size)
		  
		  ' Set the request content.
		  HTTP.SetRequestContent(content, ContentType.ToText)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub SetRequestCookies()
		  ' Internal helper method.
		  ' Sets any cookies that are to be passed with this request.
		  ' Cookies are concatenated with semicolons separating pairs in the form <name>=<value>;
		  
		  If Self.Cookies = Nil Or Self.Cookies.Map.Count = 0 Then Return
		  
		  Dim i As VariantToVariantHashMapIteratorMBS = Cookies.Map.First
		  Dim e As VariantToVariantHashMapIteratorMBS = Cookies.Map.Last
		  
		  Dim name, result, value As String
		  While i.isNotEqual(e)
		    name = i.Key
		    If i.Value IsA DateTimeObject Then
		      value = DateTimeObject(i.Value).ToHTTPHeaderFormat
		    Else
		      value = Textable(i.Value).ToText(Nil)
		    End If
		    result = result + name + "=" + value + ";"
		    i.MoveNext
		  Wend
		  
		  ' Remove any superfluous semicolon.
		  result = If(result.Right(1) = ";", result.Left(result.Len - 1), result)
		  
		  ' Set the request cookie(s).
		  HTTP.RequestHeader("Cookie") = result.ToText
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub SetRequestHeaders()
		  ' Internal helper method.
		  ' Sets the headers defined in this request object's Headers Hash to this Xojo.Net.HTTPSocket request.
		  
		  HTTP.ClearRequestHeaders
		  
		  Dim i As VariantToVariantHashMapIteratorMBS = Headers.Map.First
		  Dim e As VariantToVariantHashMapIteratorMBS = Headers.Map.Last
		  
		  While i.isNotEqual(e)
		    If i.Value IsA DateTimeObject Then
		      HTTP.RequestHeader(i.Key.StringValue.ToText) = DateTimeObject(i.Value).ToHTTPHeaderFormat.ToText
		    Else
		      HTTP.RequestHeader(i.Key.StringValue.ToText) = Textable(i.Value).ToText(Nil).ToText
		    End If
		    i.MoveNext
		  Wend
		  
		  ' Set any cookies.
		  SetRequestCookies
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function ToText(interpreter As Roo.Interpreter) As String
		  ' Part of the Textable interface.
		  
		  #Pragma Unused interpreter
		  
		  Return "<Request instance>"
		End Function
	#tag EndMethod


	#tag Property, Flags = &h0
		AwaitingResponse As Boolean = False
	#tag EndProperty

	#tag Property, Flags = &h0
		Body As String
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
		Host As String
	#tag EndProperty

	#tag Property, Flags = &h0
		HTTP As Xojo.Net.HTTPSocket
	#tag EndProperty

	#tag Property, Flags = &h0
		IfModifiedSince As String
	#tag EndProperty

	#tag Property, Flags = &h0
		Method As String
	#tag EndProperty

	#tag Property, Flags = &h0
		MyResponse As Roo.Objects.ResponseObject
	#tag EndProperty

	#tag Property, Flags = &h0
		Referer As String
	#tag EndProperty

	#tag Property, Flags = &h0
		#tag Note
			Stores the location in the script as a Token that a send call was made from.
		#tag EndNote
		SendLocation As Roo.Token
	#tag EndProperty

	#tag Property, Flags = &h0
		#tag Note
			The time (in milliseconds) that the Request object should wait until it is assumed that the request
			has timed out.
			NB: The maximum permitted value is 60 seconds (Xojo.Net.HTTPSocket limitation).
			Defaults to 10 seconds.
		#tag EndNote
		Timeout As Integer
	#tag EndProperty

	#tag Property, Flags = &h0
		URL As String
	#tag EndProperty

	#tag Property, Flags = &h0
		UserAgent As String
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
			Name="AwaitingResponse"
			Group="Behavior"
			InitialValue="False"
			Type="Boolean"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Method"
			Group="Behavior"
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Timeout"
			Group="Behavior"
			InitialValue="10000"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="URL"
			Group="Behavior"
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Body"
			Group="Behavior"
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="ContentType"
			Group="Behavior"
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Host"
			Group="Behavior"
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="IfModifiedSince"
			Group="Behavior"
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Referer"
			Group="Behavior"
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="UserAgent"
			Group="Behavior"
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
	#tag EndViewBehavior
End Class
#tag EndClass
