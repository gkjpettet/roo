#tag Class
Protected Class RooRegex
Inherits RooInstance
Implements  RooNativeClass,  RooNativeSettable
	#tag Method, Flags = &h0
		Function Arity() As Variant
		  // Part of the Invokable interface.
		  
		  Raise New RooRuntimeError(New RooToken, "Cannot invoke the native Regex type.")
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor(where As RooToken, pattern As String, optionString As String)
		  Super.Constructor(Nil) // No metaclass.
		  
		  Self.Regex = New RegEx
		  
		  Self.Regex.SearchPattern = pattern
		  Self.Options = optionString
		  ParseOptionsString(where)
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function GetterWithName(name As RooToken) As Variant
		  // Return the result of the requested getter operation.
		  If StrComp(name.Lexeme, "case_sensitive", 0) = 0 Then
		    Return New RooBoolean(Self.Regex.Options.CaseSensitive)
		  ElseIf StrComp(name.Lexeme, "dot_matches_all", 0) = 0 Then
		    Return New RooBoolean(Self.Regex.Options.DotMatchAll)
		  ElseIf StrComp(name.Lexeme, "greedy", 0) = 0 Then
		    Return New RooBoolean(Self.Regex.Options.Greedy)
		  ElseIf StrComp(name.Lexeme, "match_empty", 0) = 0 Then
		    Return New RooBoolean(Self.Regex.Options.MatchEmpty)
		  ElseIf StrComp(name.Lexeme, "multiline", 0) = 0 Then
		    Return New RooBoolean(Not Self.Regex.Options.TreatTargetAsOneLine)
		  End If
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function HasGetterWithName(name As String) As Boolean
		  // Query the global Roo dictionary of Regex object getters for the existence of a getter 
		  // with the passed name.
		  
		  Return RooSLCache.RegexGetters.HasKey(name)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function HasMethodWithName(name As String) As Boolean
		  // Part of the RooNativeClass interface.
		  // Query the global Roo dictionary of Regex object methods for the existence of a method 
		  // with the passed name.
		  
		  Return RooSLCache.RegexMethods.HasKey(name)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Invoke(interpreter As RooInterpreter, arguments() As Variant, where As RooToken) As Variant
		  // Part of the Invokable interface.
		  
		  #Pragma Unused interpreter
		  #Pragma Unused arguments
		  
		  Raise New RooRuntimeError(where, "Cannot invoke the native Regex type.")
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function MethodWithName(name As RooToken) As Invokable
		  // Part of the RooNativeClass interface.
		  // Return a new instance of a Regex object method initialised with the name of the method 
		  // being called. That way, when the returned method is invoked, it will know what operation 
		  // to perform.
		  Return New RooRegexMethod(Self, name.Lexeme)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub ParseOptionsString(where As RooToken)
		  // Internal helper method.
		  // Parses a Roo Regex option string into Xojo RegEx options.
		  
		  // Default options:
		  // Case sensitive (c): False
		  // Dot matches All (d): False
		  // Greedy (g): True
		  // Match empty (e): True
		  // Multiline (m): True
		  
		  // Bail early if we're using the option defaults.
		  If Options = "" Then Return
		  
		  // c, d, g, e, m.
		  Dim chars() As String = Options.Split("")
		  Dim limit As Integer = chars.Ubound
		  For i As Integer = 0 To limit
		    Select Case chars(i)
		    Case "c" // Case sensitive.
		      Self.Regex.Options.CaseSensitive = True
		    Case "d" // Dot matches all.
		      Self.Regex.Options.DotMatchAll = True
		    Case "g" //  Greedy.
		      Self.Regex.Options.Greedy = True
		    Case "e" // Match empty.
		      Self.Regex.Options.MatchEmpty = True
		    Case "m" // Multiline.
		      Self.Regex.Options.TreatTargetAsOneLine = False
		    Else
		      Raise New RooRuntimeError(where, "invalid regex option `" + chars(i) + "`.")
		    End Select
		  Next i
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Set(name As RooToken, value As Variant)
		  // Part of the RooNativeSettable interface.
		  
		  If StrComp(name.Lexeme, "case_sensitive", 0) = 0 Then
		    Roo.AssertIsBoolean(name, value)
		    Self.Regex.Options.CaseSensitive = RooBoolean(value).Value
		  ElseIf StrComp(name.Lexeme, "dot_matches_all", 0) = 0 Then
		    Roo.AssertIsBoolean(name, value)
		    Self.Regex.Options.DotMatchAll = RooBoolean(value).Value
		  ElseIf StrComp(name.Lexeme, "greedy", 0) = 0 Then
		    Roo.AssertIsBoolean(name, value)
		    Self.Regex.Options.Greedy = RooBoolean(value).Value
		  ElseIf StrComp(name.Lexeme, "match_empty", 0) = 0 Then
		    Roo.AssertIsBoolean(name, value)
		    Self.Regex.Options.MatchEmpty = RooBoolean(value).Value
		  ElseIf StrComp(name.Lexeme, "multiline", 0) = 0 Then
		    Roo.AssertIsBoolean(name, value)
		    Self.Regex.Options.TreatTargetAsOneLine = Not RooBoolean(value).Value
		  Else
		    Raise New RooRuntimeError(name, "The Regex data type has no property named `" + _
		    name.Lexeme + "`.")
		  End If
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function StringValue() As String
		  // Part of the Stringable interface.
		  
		  Return Self.Regex.SearchPattern + "(" + Options + ")"
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Type() As String
		  // Part of the RooNativeClass interface.
		  
		  Return "Regex"
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Shared Function ZeroBasedPos(bytePosition As Integer, originalString As String) As Integer
		  // Takes the value provided by Xojo's RegexMatch SubExpressionStartB and converts 
		  // it into a zero-based character position. 
		  // This is required because multibute strings (e.g: UTF-8) do not represent a single 
		  // character with a single byte.
		  
		  Return originalString.LeftB(bytePosition).Len
		End Function
	#tag EndMethod


	#tag Property, Flags = &h0
		Options As String
	#tag EndProperty

	#tag Property, Flags = &h0
		Regex As RegEx
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
			Name="Options"
			Group="Behavior"
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
	#tag EndViewBehavior
End Class
#tag EndClass
