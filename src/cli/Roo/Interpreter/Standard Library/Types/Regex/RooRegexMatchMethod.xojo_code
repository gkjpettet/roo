#tag Class
Protected Class RooRegexMatchMethod
Implements Invokable, Stringable
	#tag Method, Flags = &h0
		Function Arity() As Variant
		  // Part of the Invokable interface.
		  // Return the arity of this method. This is stored in the cached RegexMatchMethods dictionary.
		  
		  Return RooSLCache.RegexMatchMethods.Value(Name)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor(owner As RooRegexMatch, name As String)
		  Self.Owner = owner
		  Self.Name = name
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function DoGroup(args() As Variant, where As RooToken) As Variant
		  // RegexMatch.group(captureNumber As Number) As Hash or Nothing.
		  // The first capture group is index 0 in the owning RegexMatch.Groups array.
		  // The Roo method however expects a 1-based argument.
		  
		  Roo.AssertIsPositiveInteger(where, args(0))
		  
		  Dim num As Integer = RooNumber(args(0)).Value - 1
		  
		  If num < 0 Or num > Owner.Groups.Ubound Then Return New RooNothing
		  
		  Return Roo.XojoDictionaryToRooHash(Owner.Groups(num))
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Invoke(interpreter As RooInterpreter, arguments() As Variant, where As RooToken) As Variant
		  // Part of the Invokable interface.
		  // Perform the required method operation on this RegexMatch object.
		  
		  #Pragma Unused interpreter
		  
		  Select Case Name
		  Case "group"
		    Return DoGroup(arguments, where)
		  End Select
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function StringValue() As String
		  // Part of the Stringable interface.
		  
		  Return "<function " + Name + ">"
		End Function
	#tag EndMethod


	#tag Property, Flags = &h0
		#tag Note
			The name of this Regex object method.
		#tag EndNote
		Name As String
	#tag EndProperty

	#tag Property, Flags = &h0
		#tag Note
			The RooRegexMatch object that owns this method.
		#tag EndNote
		Owner As RooRegexMatch
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
	#tag EndViewBehavior
End Class
#tag EndClass
