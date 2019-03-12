#tag Class
Protected Class RooSLHTTP
Inherits RooInstance
Implements RooNativeModule
	#tag Method, Flags = &h0
		Function ClassWithName(name As RooToken) As RooNativeClass
		  // Part of the RooNativeModule interface.
		  
		  If StrComp(name.Lexeme, "Request", 0) = 0 Then
		    Return New RooSLHTTPRequest(Interpreter)
		  ElseIf StrComp(name.Lexeme, "Response", 0) = 0 Then
		    Return New RooSLHTTPResponse
		  End If
		  
		  // Unknown class.
		  Return Nil
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor(interpreter As RooInterpreter)
		  Super.Constructor(Nil)
		  
		  Self.Interpreter = interpreter
		  
		  // Add getters.
		  Getters = Roo.CaseSensitiveDictionary
		  Getters.Value("TIMEOUT") = True
		  
		  // Add methods.
		  Methods = Roo.CaseSensitiveDictionary
		  Methods.Value("delete") = New RooSLHTTPDelete
		  Methods.Value("get") = New RooSLHTTPGet
		  Methods.Value("post") = New RooSLHTTPPost
		  Methods.Value("put") = New RooSLHTTPPut
		  
		  // Add classes.
		  Classes = Roo.CaseSensitiveDictionary
		  Classes.Value("Request") = True
		  Classes.Value("Response") = True
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function GetterWithName(name As RooToken) As Variant
		  // Part of the RooNativeModule interface.
		  
		  If StrComp(name.Lexeme, "TIMEOUT", 0) = 0 Then
		    Return New RooNumber(kDefaultRequestTimeout)
		  End If
		  
		  Raise New RooRuntimeError(name, "The HTTP module has no getter named `" + name.Lexeme + "`.")
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function HasClassWithName(name As String) As Boolean
		  // Part of the RooNativeModule interface.
		  
		  Return Classes.HasKey(name)
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function HasGetterWithName(name As String) As Boolean
		  // Part of the RooNativeModule interface.
		  
		  Return Getters.HasKey(name)
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function HasMethodWithName(name As String) As Boolean
		  // Part of the RooNativeModule interface.
		  
		  Return Methods.HasKey(name)
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function HasModuleWithName(name As String) As Boolean
		  // Part of the RooNativeModule interface.
		  
		  #Pragma Unused name
		  
		  // The HTTP module has no submodules.
		  Return False
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Shared Function MethodStringToType(s As String) As RooSLHTTP.MethodType
		  // Takes a String and converts it to a MethodType enumeration.
		  
		  Select Case Uppercase(s)
		  Case "CONNECT"
		    Return RooSLHTTP.MethodType.CONNECT
		  Case "DELETE"
		    Return RooSLHTTP.MethodType.DELETE
		  Case "GET"
		    Return RooSLHTTP.MethodType.GET
		  Case "HEAD"
		    Return RooSLHTTP.MethodType.HEAD
		  Case "OPTIONS"
		    Return RooSLHTTP.MethodType.OPTIONS
		  Case "PATCH"
		    Return RooSLHTTP.MethodType.PATCH
		  Case "POST"
		    Return RooSLHTTP.MethodType.POST
		  Case "PUT"
		    Return RooSLHTTP.MethodType.PUT
		  Case "TRACE"
		    Return RooSLHTTP.MethodType.TRACE
		  Else
		    Return RooSLHTTP.MethodType.UNKNOWN
		  End Select
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Shared Function MethodTypeAsString(method As RooSLHTTP.MethodType) As String
		  Select Case method
		  Case RooSLHTTP.MethodType.CONNECT
		    Return "CONNECT"
		  Case RooSLHTTP.MethodType.DELETE
		    Return "DELETE"
		  Case RooSLHTTP.MethodType.GET
		    Return "GET"
		  Case RooSLHTTP.MethodType.HEAD
		    Return "HEAD"
		  Case RooSLHTTP.MethodType.OPTIONS
		    Return "OPTIONS"
		  Case RooSLHTTP.MethodType.PATCH
		    Return "PATCH"
		  Case RooSLHTTP.MethodType.POST
		    Return "POST"
		  Case RooSLHTTP.MethodType.PUT
		    Return "PUT"
		  Case RooSLHTTP.MethodType.TRACE
		    Return "TRACE"
		  Case RooSLHTTP.MethodType.UNKNOWN
		    Return "UNKNOWN"
		  End Select
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function MethodWithName(name As RooToken) As Invokable
		  // Part of the RooNativeModule interface.
		  
		  Return Methods.Value(name.Lexeme)
		  
		  Exception err As KeyNotFoundException
		    Raise New RooRuntimeError(name, "Cannot find a method named `" + name.Lexeme + _
		    "` for the HTTP module.")
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function ModuleWithName(name As RooToken) As RooNativeModule
		  // Part of the RooNativeModule interface.
		  
		  #Pragma Unused name
		  
		  // The HTTP module has no submodules.
		  Return Nil
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function StringValue() As String
		  // Part of the Stringable interface.
		  
		  Return "HTTP module"
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Type() As String
		  // Part of the RooNativeModule interface.
		  
		  Return "Module"
		  
		End Function
	#tag EndMethod


	#tag Property, Flags = &h21
		Private Classes As Xojo.Core.Dictionary
	#tag EndProperty

	#tag Property, Flags = &h21
		Private Getters As Xojo.Core.Dictionary
	#tag EndProperty

	#tag Property, Flags = &h21
		Private Interpreter As RooInterpreter
	#tag EndProperty

	#tag Property, Flags = &h21
		Private Methods As Xojo.Core.Dictionary
	#tag EndProperty


	#tag Constant, Name = kDefaultRequestTimeout, Type = Double, Dynamic = False, Default = \"10", Scope = Public
	#tag EndConstant


	#tag Enum, Name = MethodType, Type = Integer, Flags = &h0
		CONNECT
		  DELETE
		  GET
		  HEAD
		  OPTIONS
		  PATCH
		  POST
		  PUT
		  TRACE
		UNKNOWN
	#tag EndEnum


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
