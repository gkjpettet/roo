#tag Class
Protected Class RooTextMethod
Implements Invokable, Stringable
	#tag Method, Flags = &h0
		Function Arity() As Variant
		  // Part of the Invokable interface.
		  // Return the arity of this method. This is stored in the cached TextMethods dictionary.
		  
		  Return RooSLCache.TextMethods.Value(Name)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor(owner As RooText, name As String)
		  Self.Owner = owner
		  Self.Name = name
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function DoEachChar(args() As Variant, where As RooToken, interpreter As RooInterpreter) As RooArray
		  // Text.each_char(func as Invokable, optional arguments as Array) as Array
		  // Invokes the passed `func` for each character of this text object, passing to `func` the character 
		  // as the first argument. Optionally, `each_char` can take a second argument in the form of an Array object. 
		  // The elements of this array will be passed to `func` as additional arguments.
		  // Returns a new array containing the values returned by `func`.
		  
		  Dim funcArgs(), result() As Variant
		  Dim charsUbound, i As Integer
		  Dim func As Invokable
		  
		  // Check that `func` is invokable.
		  Roo.AssertIsInvokable(where, args(0))
		  func = args(0)
		  
		  // If a second argument has been passed, check that it's an Array object.
		  if args.Ubound = 1 then
		    Roo.AssertIsArray(where, args(1))
		    // Get an array of the additional arguments to pass to the function we will invoke.
		    Dim limit As Integer = RooArray(args(1)).Elements.Ubound
		    For i = 0 To limit
		      funcArgs.Append(RooArray(args(1)).Elements(i))
		    Next i
		  End If
		  
		  // Check that we have the correct number of arguments for `func`.
		  // NB: +2 as we will pass in each character as the first argument.
		  If Not Interpreter.CorrectArity(func, funcArgs.Ubound + 2) Then
		    Raise New RooRuntimeError(where, "Incorrect number of arguments passed to the " +_
		    Stringable(func).StringValue + " function.")
		  End If
		  
		  // Split this text object into characters.
		  Dim chars() As String = Owner.Value.Split("")
		  
		  charsUbound = chars.Ubound
		  For i = 0 To charsUbound
		    funcArgs.Insert(0, New RooText(chars(i))) // Inject this character as the first argument to `func`.
		    result.Append(func.Invoke(interpreter, funcArgs, where))
		    funcArgs.Remove(0) // Remove this character from the argument list prior to the next iteration.
		  Next i
		  
		  Return New RooArray(result)
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function DoEndsWith(args() As Variant, where As RooToken) As RooBoolean
		  // Text.ends_with?(what as Text or Array) as Boolean.
		  
		  #Pragma Unused where
		  
		  Dim what As String
		  
		  // The first (and only) argument passed is the query string.
		  // It will be either an array or a single value.
		  If args(0) IsA RooArray Then
		    // Loop through each element of the passed array comparing its 
		    // text value to the end of this object's text value.
		    Dim limit As Integer = RooArray(args(0)).Elements.Ubound
		    For i As Integer = 0 To limit
		      what = Stringable(RooArray(args(0)).Elements(i)).StringValue
		      If what.Len <= Owner.Value.Len Then
		        If StrComp(Owner.Value.Right(what.Len), what, 0) = 0 Then
		          // Matches.
		          Return New RooBoolean(True)
		        End If
		      End If
		    Next i
		    // No match.
		    Return New RooBoolean(False)
		  Else
		    what = Stringable(args(0)).StringValue
		    Return New RooBoolean(StrComp(Owner.Value.Right(what.Len), what, 0) = 0)
		  End If
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function DoInclude(arguments() As Variant, where As RooToken) As RooBoolean
		  // Text.include?(needle As Text) As Boolean.
		  
		  #Pragma Unused where
		  
		  // Get the string to look for.
		  Dim needle As String = Stringable(arguments(0)).StringValue
		  
		  // Do a case-sensitive search.
		  Return New RooBoolean( Owner.Value.InStrB(needle) > 0 )
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function DoIndex(arguments() As Variant, where As RooToken) As Variant
		  // Text.index(what As Text) As Number or Nothing
		  // Returns the position (zero-based index) of the first character of the passed query text. 
		  // If not found it returns Nothing.
		  
		  #Pragma Unused where
		  
		  Dim what As String = Stringable(arguments(0)).StringValue
		  Dim index As Integer
		  
		  // Do a case-sensitive search.
		  index = Owner.Value.InStrB(what) - 1
		  If index = -1 Then
		    Return New RooNothing
		  Else
		    Return New RooNumber(index)
		  End If
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function DoLPad(args() As Variant, where As RooToken, destructive As Boolean) As RooText
		  // Text.lpad(width as Number, optional padding As Text) As Text
		  // Returns a new Text object where the value has been padded to at least the specified width 
		  // with whatever `padding` is.
		  // If `padding` is omitted we use " ".
		  // If destructive then is Text object's value is also mutated.
		  
		  // Get the width as a positive integer.
		  Roo.AssertIsPositiveInteger(where, args(0))
		  Dim width As Integer = RooNumber(args(0)).Value
		  
		  // Get the padding character(s). Default to " ".
		  Dim padding As String = " "
		  If args.Ubound = 1 Then
		    padding = Stringable(args(1)).StringValue
		  End If
		  
		  Dim length As Integer = Owner.Value.Len
		  Dim newValue As String
		  
		  If length >= width Then
		    newValue = Owner.Value
		  Else
		    Dim mostToRepeat As Integer
		    mostToRepeat = Ceil((width - length) / Len(padding))
		    newValue = Mid(Repeat(padding, mostToRepeat), 1, width - length) + Owner.Value
		  End If
		  
		  // Destructive operation?
		  Owner.Value = If(destructive, newValue, Owner.Value)
		  
		  Return New RooText(newValue)
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function DoMatch(args() As Variant, where As RooToken) As Variant
		  // Text.match(pattern as Regex) as array of RegexMatch objects or Nothing
		  // Text.match(pattern as Regex, start as Integer) as array of RegexMatch objects or Nothing
		  
		  #Pragma BreakOnExceptions False
		  
		  // Has a regex object been passed?
		  Roo.AssertIsRegex(where, args(0))
		  Dim re As RooRegex = RooRegex(args(0))
		  
		  // If the optional `start` argument is passed make sure it's a positive integer.
		  Dim start As Integer = 0
		  If args.Ubound = 1 Then
		    Roo.AssertIsPositiveInteger(where, args(1))
		    start = RooNumber(args(1)).Value
		  End If
		  
		  // Get the text to search.
		  Dim what As String = Owner.Value
		  
		  // Convert the passed start position into a byte start position.
		  // The Xojo Regex library requires a byte position which does not always align with 
		  // the character position in multibyte (i.e: UTF-8) strings.
		  start = what.Left(start).LenB
		  
		  // Do the search.
		  Dim numCaptureGroups, matchStart As Integer
		  Dim matchValue As String
		  
		  Dim m, matches() As RooRegexMatch
		  
		  Dim match As RegExMatch = re.Regex.Search(what, start)
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
		    match = re.Regex.Search
		    
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
		    "): " + re.Regex.SearchPattern)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function DoMatches(args() As Variant, where As RooToken) As RooBoolean
		  // Text.matches?(pattern as Regex) as Boolean.
		  
		  #Pragma Unused where
		  
		  // Check that a Regex object has been passed as the parameter.
		  Roo.AssertIsRegex(where, args(0))
		  Dim re As RooRegex = RooRegex(args(0))
		  
		  // Run the search query, looking for at least one match.
		  Dim match As RegExMatch = re.Regex.Search(Owner.Value)
		  
		  // Return whether there is a match or not.
		  Return New RooBoolean(If(match <> Nil, True, False))
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function DoReplaceAll(arguments() As Variant, destructive As Boolean, where As RooToken) As RooText
		  // Text.replace_all(what As Text, replacement As Text) as Text
		  // Text.replace_all!(what As Text, replacement As Text) As Text
		  // Returns a new Text object where every occurrence of `what` is replaced with `replacement`.
		  // If destructive then is Text object's value is also mutated.
		  
		  // Make sure that both arguments are Text objects.
		  Roo.AssertAreTextObjects(where, arguments(0), arguments(1))
		  
		  Dim what As String = RooText(arguments(0)).Value
		  Dim replacement As String = RooText(arguments(1)).Value
		  
		  // Do the search and replace
		  Dim result As String = Owner.Value.ReplaceAllB(what, replacement)
		  
		  // Destructive operation?
		  Owner.Value = If(destructive, result, Owner.Value)
		  
		  Return New RooText(result)
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function DoReplaceFirst(arguments() As Variant, destructive As Boolean, where As RooToken) As RooText
		  // Text.replace_first(what As Text, replacement As Text) as Text
		  // Text.replace_first!(what As Text, replacement As Text) As Text
		  // Returns a new Text object where the first occurrence of `what` is replaced with `replacement`.
		  // If destructive then is Text object's value is also mutated.
		  
		  // Make sure that both arguments are Text objects.
		  Roo.AssertAreTextObjects(where, arguments(0), arguments(1))
		  
		  Dim what As String = RooText(arguments(0)).Value
		  Dim replacement As String = RooText(arguments(1)).Value
		  
		  // Do the search and replace
		  Dim result As String = Owner.Value.ReplaceB(what, replacement)
		  
		  // Destructive operation?
		  Owner.Value = If(destructive, result, Owner.Value)
		  
		  Return New RooText(result)
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function DoRPad(args() As Variant, where As RooToken, destructive As Boolean) As RooText
		  // Text.rpad(width as Number, optional padding As Text) As Text
		  // Returns a new Text object where the value has been right-padded to at least the 
		  // specified width with whatever `padding` is.
		  // If `padding` is omitted we use " ".
		  // If destructive then is Text object's value is also mutated.
		  
		  // Get the width as a positive integer.
		  Roo.AssertIsPositiveInteger(where, args(0))
		  Dim width As Integer = RooNumber(args(0)).Value
		  
		  // Get the padding character(s). Default to " ".
		  Dim padding As String = " "
		  If args.Ubound = 1 Then
		    padding = Stringable(args(1)).StringValue
		  End If
		  
		  Dim length As Integer = Owner.Value.Len
		  Dim newValue As String
		  
		  If length >= width Then
		    newValue = Owner.Value
		  Else
		    Dim mostToRepeat As Integer
		    mostToRepeat = Ceil((width - length) / Len(padding))
		    newValue = Owner.Value + Mid(Repeat(padding, mostToRepeat), 1, width - length)
		  End If
		  
		  // Destructive operation?
		  Owner.Value = If(destructive, newValue, Owner.Value)
		  
		  Return New RooText(newValue)
		  
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function DoSlice(arguments() As Variant, destructive As Boolean, where As RooToken) As Variant
		  // Text.slice(pos)  |  Text.slice(start, end)
		  // Text.slice!(pos) |  Text.slice!(start, end)
		  // If one argument is passed then we return the character at that position.
		  // If two arguments are passed then we return the text starting at position `start` 
		  // and ending at `end`.
		  // Positions are zero based.
		  // If `pos` or `start` are negative then we count backwards.
		  
		  // Quick check to see if we can get away with doing nothing.
		  If Owner.Value = "" Then Return New RooText("")
		  
		  // Dispatch to the correct method depending on the number of arguments passed.
		  If arguments.Ubound = 0 Then // Text.slice(pos) or Text.slice!(pos)
		    // Check that `pos` is an Integer.
		    Roo.AssertAreIntegers(where, arguments(0))
		    Return DoSlicePos(RooNumber(arguments(0)).Value, destructive)
		  ElseIf arguments.Ubound = 1 Then // Text.slice(start, end) or Text.slice!(start, end)
		    // Check both arguments are integers.
		    Roo.AssertAreIntegers(where, arguments(0), arguments(1))
		    Return DoSliceStartEnd(RooNumber(arguments(0)).Value, _
		    RooNumber(arguments(1)).Value, destructive, where)
		  End If
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function DoSlicePos(pos As Integer, destructive As Boolean) As Variant
		  // Text.slice(pos) as Text  |  Text.slice!(pos) as Text
		  // Returns a new Text object containing the character at position `pos`. 
		  // If pos < 0 we count backwards from the end of the text to find the character. 
		  // Position is zero-based.
		  // If `pos` > length of the text then we return Nothing.
		  // If destructive then we will also change the value of this Text object's value to 
		  // the sliced value.
		  // Whenever Nothing is returned, we leave the original text alone 
		  // (even if it's a destructive operation).
		  
		  Dim tmp, result As String
		  
		  If pos + 1 > Owner.Value.Len Then Return New RooNothing
		  
		  If pos >= 0 Then
		    result = Owner.Value.Mid(pos + 1, 1)
		  Else
		    pos = Abs(pos)
		    If pos > Owner.Value.Len Then Return New RooNothing
		    tmp = Reverse(Owner.Value)
		    result = tmp.Mid(pos, 1)
		  End If
		  
		  If result = "" Then Return New RooNothing
		  
		  // Is this a destructive operation? - slice!()
		  Owner.Value = If(destructive, result, Owner.Value)
		  
		  Return New RooText(result)
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function DoSliceStartEnd(start As Integer, length As Integer, destructive As Boolean, where As RooToken) As Variant
		  // Text.slice(start, length) as Text  |  Text.slice!(start, length) as Text
		  // Indices are zero-based.
		  // Returns a new Text object of length `length` starting from position `start`. 
		  // If start < 0 then we count backwards from the end of the text to find the start character. 
		  // Whenever Nothing is returned, we leave the original text alone 
		  // (even if it's a destructive operation).
		  
		  // E.g:
		  // var t = "Hello World"
		  // t.slice(0, 3)  # "Hel"
		  // t.slice(2, 6)  # "llo Wo"
		  // t.slice(-3, 2) # "rl"
		  // t.slice(2, -5) # Nothing
		  // t.slice(7, 2)  # "or"
		  // t.slice(7, 4)  # "orld"
		  // t.slice(7, 8)  # "orld"
		  
		  #Pragma Unused where
		  
		  Dim result As String
		  
		  // Make sure `length` is valid.
		  If length <= 0 Then Return New RooNothing
		  
		  // Make sure a valid start position has been passed.
		  If Abs(start) > Owner.Value.Len Then Return New RooNothing
		  
		  // Adjust the start position as required.
		  If start < 0 Then start = Owner.Value.Len + start
		  
		  // If the user has passed a length greater than the number of characters remaining between 
		  // `start` and the end of the text, adjust `length` such that we return all characters from 
		  // `start` to the end of the text.
		  length = If(start + length > Owner.Value.Len, Owner.Value.Len - start, length)
		  
		  // Do the slice.
		  result = Owner.Value.Mid(start + 1, length)
		  
		  If result = "" Then Return New RooNothing
		  
		  // Destructive operation?
		  Owner.Value = If(destructive, result, Owner.Value)
		  
		  Return New RooText(result)
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function DoStartsWith(args() As Variant, where As RooToken) As RooBoolean
		  // Text.starts_with?(what as Text or Array) as Boolean.
		  
		  #Pragma Unused where
		  
		  Dim what As String
		  
		  // The first (and only) argument passed is the query string.
		  // It will be either an array or a single value.
		  If args(0) IsA RooArray Then
		    // Loop through each element of the passed array comparing its 
		    // text value to the start of this object's text value.
		    Dim limit As Integer = RooArray(args(0)).Elements.Ubound
		    For i As Integer = 0 To limit
		      what = Stringable(RooArray(args(0)).Elements(i)).StringValue
		      If what.Len <= Owner.Value.Len Then
		        If StrComp(Owner.Value.Left(what.Len), what, 0) = 0 Then
		          // Matches.
		          Return New RooBoolean(True)
		        End If
		      End If
		    Next i
		    // No match.
		    Return New RooBoolean(False)
		  Else
		    what = Stringable(args(0)).StringValue
		    Return New RooBoolean(StrComp(Owner.Value.Left(what.Len), what, 0) = 0)
		  End If
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Invoke(interpreter As RooInterpreter, arguments() As Variant, where As RooToken) As Variant
		  // Part of the Invokable interface.
		  // Perform the required method operation on this Text object.
		  
		  #Pragma Unused interpreter
		  
		  Select Case Name
		  Case "each_char"
		    Return DoEachChar(arguments, where, interpreter)
		  Case "ends_with?"
		    Return DoEndsWith(arguments, where)
		  Case "first_match"
		    Dim result As Variant = DoMatch(arguments, where)
		    If result IsA RooNothing Then Return result
		    If result IsA RooArray Then Return RooArray(result).Elements(0)
		  Case "lpad"
		    Return DoLPad(arguments, where, False)
		  Case "lpad!"
		    Return DoLPad(arguments, where, True)
		  Case "include?"
		    Return DoInclude(arguments, where)
		  Case "index"
		    Return DoIndex(arguments, where)
		  Case "match"
		    Return DoMatch(arguments, where)
		  Case "matches?"
		    Return DoMatches(arguments, where)
		  Case "replace_all"
		    Return DoReplaceAll(arguments, False, where)
		  Case "replace_all!"
		    Return DoReplaceAll(arguments, True, where)
		  Case "replace_first"
		    Return DoReplaceFirst(arguments, False, where)
		  Case "replace_first!"
		    Return DoReplaceFirst(arguments, True, where)
		  Case "rpad"
		    Return DoRPad(arguments, where, False)
		  Case "rpad!"
		    Return DoRPad(arguments, where, True)
		  Case "slice"
		    Return DoSlice(arguments, False, where)
		  Case "slice!"
		    Return DoSlice(arguments, True, where)
		  Case "starts_with?"
		    Return DoStartsWith(arguments, where)
		  End Select
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function Repeat(s As String, repeatCount As Integer) As String
		  // Concatenate a string to itself `repeatCount` times.
		  // Example: Repeat("spam ", 5) = "spam spam spam spam spam ".
		  // Credit Joe Strout: http://www.strout.net/files/rb/stringutils.zip
		  
		  #Pragma DisableBackgroundTasks
		  
		  If repeatCount <= 0 Then Return ""
		  If repeatCount = 1 Then Return s
		  
		  // Implementation note: normally, you don't want to use string concatenation
		  // for something like this, since that creates a new string on each operation.
		  // But in this case, we can double the size of the string on iteration, which
		  // quickly reduces the overhead of concatenation to insignificance.  This method
		  // is faster than any other we've found (short of declares, which were only
		  // about 2X faster and were quite platform-specific).
		  
		  Dim desiredLenB As Integer = LenB(s) * repeatCount
		  Dim output As String = s
		  Dim cutoff As Integer = (desiredLenB + 1)\2
		  Dim curLenB As Integer = LenB(output)
		  
		  While curLenB < cutoff
		    output = output + output
		    curLenB = curLenB + curLenB
		  Wend
		  
		  output = output + LeftB(output, desiredLenB - curLenB)
		  Return output
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function Reverse(s As String) As String
		  // Internal helper method. Returns `s` with the characters in reverse order.
		  
		  If Len(s) < 2 Then Return s
		  
		  Dim characters() As String = Split(s, "")
		  Dim leftIndex As Integer = 0
		  Dim rightIndex As Integer = UBound(characters)
		  
		  Dim temp As String
		  #Pragma BackgroundTasks False
		  While leftIndex < rightIndex
		    temp = characters(leftIndex)
		    characters(leftIndex) = characters(rightIndex)
		    characters(rightIndex) = temp
		    leftIndex = leftIndex + 1
		    rightIndex = rightIndex - 1
		  Wend
		  
		  Return Join(characters, "")
		  
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
			The name of this Text object method.
		#tag EndNote
		Name As String
	#tag EndProperty

	#tag Property, Flags = &h0
		#tag Note
			The RooText object that owns this method.
		#tag EndNote
		Owner As RooText
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
