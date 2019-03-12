#tag Class
Protected Class RooRegexMethod
Implements Invokable, Stringable
	#tag Method, Flags = &h0
		Function Arity() As Variant
		  // Part of the Invokable interface.
		  // Return the arity of this method. This is stored in the cached RegexMethods dictionary.
		  
		  Return RooSLCache.RegexMethods.Value(Name)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor(owner As RooRegex, name As String)
		  Self.Owner = owner
		  Self.Name = name
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function DoMatch(args() As Variant, where As RooToken) As Variant
		  // Regex.match(what as Text) as array of RegexMatch objects or Nothing
		  // Regex.match(what as Text, start as Integer) as array of RegexMatch objects or Nothing
		  
		  #Pragma BreakOnExceptions False
		  
		  // If the optional `start` argument is passed make sure it's a positive integer.
		  Dim start As Integer = 0
		  If args.Ubound = 1 Then
		    Roo.AssertIsPositiveInteger(where, args(1))
		    start = RooNumber(args(1)).Value
		  End If
		  
		  // Get the text to search.
		  Dim what As String = Stringable(args(0)).StringValue
		  
		  // Convert the passed start position into a byte start position.
		  // The Xojo Regex library requires a byte position which does not always align with 
		  // the character position in multibyte (i.e: UTF-8) strings.
		  start = what.Left(start).LenB
		  
		  // Do the search.
		  Dim numCaptureGroups, matchStart As Integer
		  Dim matchValue As String
		  
		  Dim m, matches() As RooRegexMatch
		  
		  Dim match As RegExMatch = Owner.Regex.Search(what, start)
		  Do Until match = Nil
		    
		    // Create a new Roo RegexMatch object.
		    matchValue = match.SubExpressionString(0)
		    matchStart = RooRegex.ZeroBasedPos(match.SubExpressionStartB(0), what)
		    m = New RooRegexMatch(matchStart, matchValue)
		    
		    // Handle any capture groups.
		    numCaptureGroups = match.SubExpressionCount - 1
		    If numCaptureGroups > 0 Then
		      For i As Integer = 1 To numCaptureGroups
		        // Create a dictionary to hold the value, start pos and length of this 
		        // capture group's content.
		        Dim d As Xojo.Core.Dictionary = Roo.CaseSensitiveDictionary
		        d.Value("start") = RooRegex.ZeroBasedPos(match.SubExpressionStartB(i), what)
		        d.Value("value") = match.SubExpressionString(i)
		        d.Value("length") = match.SubExpressionString(i).Len
		        
		        // Add this dictionary to this match's array of capture group dictionaries.
		        // NB: m.Groups(0) = first capture group, m.Groups(1) = 2nd group, etc.
		        m.Groups.Append(d)
		      Next i
		    End If
		    
		    // Add this match to our array of matches.
		    matches.Append(m)
		    
		    // Keep searching the query string.
		    match = Owner.Regex.Search
		    
		  Loop
		  
		  // If there were no matches, return Nothing.
		  If matches.Ubound < 0 Then Return New RooNothing
		  
		  // There was at least one match. Return an array of RegexMatch objects.
		  Dim a As New RooArray
		  For i As Integer = 0 To matches.Ubound
		    a.Elements.Append(matches(i))
		  Next i
		  Return a
		  
		  Exception err As RegExSearchPatternException
		    Raise New RooRuntimeError(where, "Invalid regular expression (" + err.Message + _
		    "): " + Owner.Regex.SearchPattern)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function DoMatches(args() As Variant, where As RooToken) As RooBoolean
		  // Regex.matches?(what as Text) as Boolean.
		  
		  #Pragma Unused where
		  
		  // Get the string to search.
		  Dim what As String = Stringable(args(0)).StringValue
		  
		  // Run the search query, looking for at least one match.
		  Dim match As RegExMatch = Owner.Regex.Search(what)
		  
		  // Return whether there is a match or not.
		  Return New RooBoolean(If(match <> Nil, True, False))
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Invoke(interpreter As RooInterpreter, arguments() As Variant, where As RooToken) As Variant
		  // Part of the Invokable interface.
		  // Perform the required method operation on this Regex object.
		  
		  #Pragma Unused interpreter
		  
		  Select Case Name
		  Case "first_match"
		    Dim result As Variant = DoMatch(arguments, where)
		    If result IsA RooNothing Then Return result
		    If result IsA RooArray Then Return RooArray(result).Elements(0)
		  Case "match"
		    Return DoMatch(arguments, where)
		  Case "matches?"
		    Return DoMatches(arguments, where)
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
			The RooRegex object that owns this method.
		#tag EndNote
		Owner As RooRegex
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
