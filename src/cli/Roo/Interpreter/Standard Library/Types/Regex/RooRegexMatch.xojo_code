#tag Class
Protected Class RooRegexMatch
Inherits RooInstance
Implements RooNativeClass
	#tag Method, Flags = &h0
		Function Arity() As Variant
		  // Part of the Invokable interface.
		  
		  Raise New RooRuntimeError(New RooToken, "Cannot invoke a RegexMatch object.")
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor(start As Integer, value As String)
		  Super.Constructor(Nil) // No metaclass.
		  
		  Self.Start = start
		  Self.Value = value
		  Self.Length = Self.Value.Len
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function DoGroups() As Variant
		  // RegexMatch.groups As RooArray or Nothing.
		  // If there are capture groups within this match then this methods returns a 
		  // Roo array where each element is a Roo hash version of the Dictionaries contained 
		  // within this match's Groups() array.
		  // If there are no capture groups within this match, this method returns Nothing.
		  
		  If Self.Groups.Ubound < 0 Then Return New RooNothing
		  
		  Dim result As New RooArray
		  
		  For i As Integer = 0 To Self.Groups.Ubound
		    result.Elements.Append(Roo.XojoDictionaryToRooHash(Self.Groups(i)))
		  Next i
		  
		  Return result
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function GetterWithName(name As RooToken) As Variant
		  // Part of the RooNativeClass interface.
		  // Return the result of the requested getter operation.
		  
		  If StrComp(name.Lexeme, "groups", 0) = 0 Then
		    Return DoGroups
		  ElseIf StrComp(name.Lexeme, "length", 0) = 0 Then
		    Return New RooNumber(Self.Length)
		  ElseIf StrComp(name.Lexeme, "start", 0) = 0 Then
		    Return New RooNumber(Self.Start)
		  ElseIf StrComp(name.Lexeme, "value", 0) = 0 Then
		    Return New RooText(Self.Value)
		  End If
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function HasGetterWithName(name As String) As Boolean
		  // Query the global Roo dictionary of RegexMatch object getters for the existence of a getter 
		  // with the passed name.
		  
		  Return RooSLCache.RegexMatchGetters.HasKey(name)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function HasMethodWithName(name As String) As Boolean
		  // Part of the RooNativeClass interface.
		  // Query the global Roo dictionary of RegexMatch object methods for the existence of a method 
		  // with the passed name.
		  
		  Return RooSLCache.RegexMatchMethods.HasKey(name)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Invoke(interpreter As RooInterpreter, arguments() As Variant, where As RooToken) As Variant
		  // Part of the Invokable interface.
		  
		  #Pragma Unused interpreter
		  #Pragma Unused arguments
		  
		  Raise New RooRuntimeError(where, "Cannot invoke RegexMatch objects.")
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function MethodWithName(name As RooToken) As Invokable
		  // Part of the RooNativeClass interface.
		  // Return a new instance of a RegexMatch object method initialised with the name of the method 
		  // being called. That way, when the returned method is invoked, it will know what operation 
		  // to perform.
		  Return New RooRegexMatchMethod(Self, name.Lexeme)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function StringValue() As String
		  // Part of the Stringable interface.
		  
		  Return "<RegexMatch: " + Self.Value + ", start " + Str(Self.Start) + ">"
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Type() As String
		  // Part of the RooNativeClass interface.
		  
		  Return "RegexMatch"
		End Function
	#tag EndMethod


	#tag Property, Flags = &h0
		#tag Note
			Groups(0) is the first capture group, Groups(1) is the second, etc.
			Each Dictionary has the following structure:
			Start => 0-based start position
			Value => The value of the capture group
			Length => The length of Value
		#tag EndNote
		Groups() As Xojo.Core.Dictionary
	#tag EndProperty

	#tag Property, Flags = &h0
		Length As Integer
	#tag EndProperty

	#tag Property, Flags = &h0
		Start As Integer
	#tag EndProperty

	#tag Property, Flags = &h0
		Value As String
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
			Name="Start"
			Group="Behavior"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Length"
			Group="Behavior"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Value"
			Group="Behavior"
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
	#tag EndViewBehavior
End Class
#tag EndClass
