#tag Class
Protected Class TextObjectMethod
Implements Roo.Invokable,Roo.Textable
	#tag Method, Flags = &h0
		Function Arity() As Variant
		  ' Return the number of arguments each method expects.
		  ' If a method has more than one method signature then return an Integer array where each element 
		  ' is the number of arguments a signature requires.
		  
		  select case self.name
		  case "ends_with?"
		    return 1
		  case "include?"
		    return 1
		  case "index"
		    return 1
		  case "match"
		    return Array(1, 2)
		  case "matches?"
		    return 1
		  case "replace_all", "replace_all!"
		    return 2
		  case "replace_first", "replace_first!"
		    return 2
		  case "responds_to?"
		    return 1
		  case "slice", "slice!"
		    return Array(1, 2)
		  case "starts_with?"
		    return 1
		  end select
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor(parent as TextObject, name as String)
		  self.parent = parent
		  self.name = name
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function DoEndsWith(arguments() as Variant, where as Token) As BooleanObject
		  ' Text.ends_with?(what as Text) as Boolean.
		  
		  ' Check that `what` has a text representation
		  if not arguments(0) isA Textable then
		    raise new RuntimeError(where, "The " + self.name + "(what) method expects a parameter that has . " + _
		    "a text representation. Instead got " + VariantType(arguments(0)) + ".")
		  end if
		  
		  dim what as String = Textable(arguments(0)).ToText
		  
		  if StrComp(parent.value.Right(what.Len), what, 0) = 0 then
		    return new BooleanObject(True)
		  else
		    return new BooleanObject(False)
		  end if
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function DoInclude(arguments() as Variant, where as Token) As BooleanObject
		  ' Text.include?(needle as Text) as Boolean.
		  
		  ' Check that `needle` has a text representation
		  if not arguments(0) isA Textable then
		    raise new RuntimeError(where, "The " + self.name + "(needle) method expects a parameter that has . " + _
		    "a text representation. Instead got " + VariantType(arguments(0)) + ".")
		  end if
		  
		  ' We need to convert the String values to Xojo Text objects to take advantage of Xojo's
		  ' built-in case-sensitive searching.
		  dim needle as Text = Textable(arguments(0)).ToText.ToText
		  dim haystack as Text = parent.value.ToText
		  
		  ' Do the case-sensitive search.
		  return if(haystack.IndexOf(needle, Text.CompareCaseSensitive) > -1, _
		  new BooleanObject(True), new BooleanObject(False))
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function DoIndex(arguments() as Variant, where as Token) As Variant
		  ' Text.index(needle as Text) as Boolean.
		  
		  ' Check that `what` has a text representation
		  if not arguments(0) isA Textable then
		    raise new RuntimeError(where, "The " + self.name + "(needle) method expects a parameter that has . " + _
		    "a text representation. Instead got " + VariantType(arguments(0)) + ".")
		  end if
		  
		  ' We need to convert the String values to Xojo Text objects to take advantage of Xojo's
		  ' built-in case-sensitive searching.
		  dim needle as Text = Textable(arguments(0)).ToText.ToText
		  dim haystack as Text = parent.value.ToText
		  dim index as Integer
		  
		  ' Do the case-sensitive search.
		  index = haystack.IndexOf(needle, Text.CompareCaseSensitive)
		  if index = -1 then
		    return new NothingObject
		  else
		    return new NumberObject(index)
		  end if
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function DoMatch(args() as Variant, where as Token) As Variant
		  ' Text.match(pattern as Regex) as RegexResultObject or Nothing
		  ' Text.match(pattern as Regex, start as Integer) as RegexResultObject or Nothing
		  
		  dim finish, start, pos as Integer
		  dim rObj as RegexObject
		  dim value as String
		  dim match as RegexMatchObject
		  dim result as new RegexResultObject
		  dim i as VariantToVariantHashMapIteratorMBS
		  dim e as VariantToVariantHashMapIteratorMBS
		  
		  ' Make sure a regex object argument is passed to the method.
		  if not args(0) isA RegexObject then
		    raise new RuntimeError(where, "The " + self.name + "(pattern) method expects a regex object. " + _
		    "Instead got " + VariantType(args(0)) + ".")
		  else
		    rObj = args(0)
		  end if
		  
		  ' If the optional `start` argument is passed make sure it's an integer.
		  if args.Ubound = 1 then
		    if not args(1) isA NumberObject and not NumberObject(args(1)).IsInteger then
		      raise new RuntimeError(where, "The " + self.name + "(pattern, start) expected an integer parameter " + _
		      "for `start`. Instead got " + VariantType(args(1)) + ".")
		    end if
		    start = NumberObject(args(1)).value
		  end if
		  
		  ' Valid start position?
		  if start < 0 then
		    raise new RuntimeError(where, "The `start` argument must be a positive integer.")
		  elseif start > 0 and start > (parent.value.Len - 1) then
		    raise new RuntimeError(where, _
		    "The `start` argument cannot exceed the length of the text to search.")
		  end if
		  
		  ' Do the search.
		  while rObj.re.Execute(parent.value, start) > 0
		    ' Found another match in the string. Create a new match object to represent it.
		    pos = rObj.re.OffsetCharacters(0)
		    finish = rObj.re.OffsetCharacters(1)
		    value = parent.value.Mid(pos + 1, finish - pos)
		    match = new RegexMatchObject(new MatchInfoObject(pos, finish, value))
		    result.matches.Append(match)
		    
		    ' Loop through each of the named groups in the regex and determine their values.
		    i = rObj.namedGroups.first
		    e = rObj.namedGroups.last
		    while i.isNotEqual(e)
		      value = rObj.re.Substring(i.Key.StringValue)
		      try
		        pos = parent.value.InStrB(start, value)
		      catch ' Ignore.
		      end try
		      match.AddValueForNamedGroup(i.Key, new MatchInfoObject(pos -1, pos + value.Len - 1, value))
		      i.MoveNext()
		    wend
		    
		    ' Loop through each of the capture groups in the regex and determine their values.
		    i = rObj.groups.first
		    e = rObj.groups.last
		    while i.isNotEqual(e)
		      value = rObj.re.Substring(i.Key.DoubleValue)
		      try
		        pos = parent.value.InStrB(start, value)
		      catch ' Ignore.
		      end try
		      match.AddValueForGroupNumber(i.Key, new MatchInfoObject(pos - 1, pos + value.Len - 1, value))
		      i.MoveNext()
		    wend
		    
		    ' Search again
		    start = rObj.re.Offset(1)
		  wend
		  
		  if result.matches.Ubound < 0 then
		    return new NothingObject
		  else
		    return result
		  end if
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function DoMatches(args() as Variant, where as Token) As BooleanObject
		  ' Text.matches?(pattern as Regex) as Boolean.
		  
		  ' Make sure a Regex object argument is passed to the method.
		  if not args(0) isA RegexObject then
		    raise new RuntimeError(where, "The " + self.name + "(pattern) method expects a regex object as a " + _
		    "parameter with a Instead got " + VariantType(args(0)) + ".")
		  end if
		  
		  dim rObj as RegexObject = args(0)
		  
		  ' Return whether there is a match or not.
		  return new BooleanObject(rObj.re.Match(parent.value))
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function DoReplaceAll(arguments() as Variant, destructive as Boolean, where as Token) As TextObject
		  ' Text.replace_all(what as Text, replacement as Text) as Text
		  ' Text.replace_all!(what as Text, replacement as Text) as Text
		  
		  if not arguments(0) isA TextObject then
		    raise new RuntimeError(where, "The " + self.name + "(what, with) method expects Text for " + _
		    "`what`. Instead got " + VariantType(arguments(0)) + ".")
		  end if
		  if not arguments(1) isA TextObject then
		    raise new RuntimeError(where, "The " + self.name + "(what, with) method expects Text for " + _
		    "`with`. Instead got " + VariantType(arguments(1)) + ".")
		  end if
		  
		  dim what as Text = TextObject(arguments(0)).value.ToText
		  dim replacement as Text = TextObject(arguments(1)).value.ToText
		  
		  ' Prevent an exception where `what` is an empty string. If it is then act as if we've not found it.
		  if what = "" then return new TextObject(parent.value)
		  
		  ' Do the search and replace
		  dim result as Text = parent.value.ToText.ReplaceAll(what, replacement, Text.CompareCaseSensitive)
		  
		  ' Destructive operation?
		  parent.value = if(destructive, result, parent.value)
		  
		  return new TextObject(result)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function DoReplaceFirst(arguments() as Variant, destructive as Boolean, where as Token) As TextObject
		  ' Text.replace_first(what as Text, replacement as Text) as Text
		  ' Text.replace_first!(what as Text, replacement as Text) as Text
		  
		  if not arguments(0) isA TextObject then
		    raise new RuntimeError(where, "The " + self.name + "(what, with) method expects Text for " + _
		    "`what`. Instead got " + VariantType(arguments(0)) + ".")
		  end if
		  if not arguments(1) isA TextObject then
		    raise new RuntimeError(where, "The " + self.name + "(what, with) method expects Text for " + _
		    "`with`. Instead got " + VariantType(arguments(1)) + ".")
		  end if
		  
		  dim what as Text = TextObject(arguments(0)).value.ToText
		  dim replacement as Text = TextObject(arguments(1)).value.ToText
		  
		  ' Prevent an exception where `what` is an empty string. If it is then act as if we've not found it.
		  if what = "" then return new TextObject(parent.value)
		  
		  ' Do the search and replace
		  dim result as Text = parent.value.ToText.Replace(what, replacement, Text.CompareCaseSensitive)
		  
		  ' Destructive operation?
		  parent.value = if(destructive, result, parent.value)
		  
		  return new TextObject(result)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function DoRespondsTo(arguments() as Variant, where as Token) As BooleanObject
		  ' Text.responds_to?(what as Text) as Boolean.
		  
		  ' Make sure a Text argument is passed to the method.
		  if not arguments(0) isA TextObject then
		    raise new RuntimeError(where, "The " + self.name + "(what) method expects an integer parameter. " + _
		    "Instead got " + VariantType(arguments(0)) + ".")
		  end if
		  
		  dim what as String = TextObject(arguments(0)).value
		  
		  if Lookup.TextGetter(what) then
		    return new BooleanObject(True)
		  elseif Lookup.TextMethod(what) then
		    return new BooleanObject(True)
		  else
		    return new BooleanObject(False)
		  end if
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function DoSlice(arguments() as Variant, destructive as Boolean, where as Token) As Variant
		  ' Text.slice(pos)  |  Text.slice(start, end)
		  ' Text.slice!(pos) |  Text.slice!(start, end)
		  ' If one argument is passed then we return the character at that position.
		  ' If two arguments are passed then we return the text starting at position `start` and ending at `end`.
		  ' Positions are zero based.
		  ' If `pos` or `start` are negative then we count backwards.
		  
		  ' Quick check to see if we can get away with doing nothing.
		  if parent.value = "" then return new TextObject("")
		  
		  ' Dispatch to the current method depending on the number of arguments passed.
		  if arguments.Ubound = 0 then ' Text.slice(pos) or Text.slice!(pos)
		    ' Check that `pos` is an Integer.
		    if not arguments(0) isA NumberObject or not NumberObject(arguments(0)).IsInteger then
		      raise new RuntimeError(where, "The " + self.name + "(pos) method expects an integer parameter. " + _
		      "Instead got " + VariantType(arguments(0)) + ".")
		    end if
		    return DoSlicePos(NumberObject(arguments(0)).value, destructive)
		    
		  elseif arguments.Ubound = 1 then ' Text.slice(start, end) or Text.slice!(start, end)
		    if not arguments(0) isA NumberObject or not NumberObject(arguments(0)).IsInteger then
		      raise new RuntimeError(where, "The " + self.name + "(start, end) method expects an integer for " + _
		      "`start`. Instead got " + VariantType(arguments(0)) + ".")
		    end if
		    if not arguments(1) isA NumberObject or not NumberObject(arguments(1)).IsInteger then
		      raise new RuntimeError(where, "The " + self.name + "(start, end) method expects an integer for " + _
		      "`end`. Instead got " + VariantType(arguments(1)) + ".")
		    end if
		    return DoSliceStartEnd(NumberObject(arguments(0)).value, NumberObject(arguments(1)).value, destructive, where)
		  end if
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function DoSlicePos(pos as Integer, destructive as Boolean) As Variant
		  ' Text.slice(pos) as Text  |  Text.slice!(pos) as Text
		  ' Returns a new Text object containing the character at position `pos`. If pos < 0 we count backwards 
		  ' from the end of the text to find the character. 
		  ' Position is zero-based.
		  ' If `pos` > length of the text then we return Nothing.
		  ' If destructive then we will also change the value of this Text object's value to the sliced value.
		  ' Whenever Nothing is returned, we leave the original text alone (even if it's a destructive operation).
		  
		  dim tmp, result as String
		  
		  if pos + 1 > parent.value.Len then
		    return new NothingObject
		  elseif pos >= 0 then
		    try
		      result = parent.value.Mid(pos + 1, 1)
		    catch
		      return new NothingObject
		    end try
		  else
		    pos = Abs(pos)
		    if pos > parent.value.Len then return new NothingObject
		    tmp = Reverse(parent.value)
		    try
		      result = tmp.Mid(pos, 1)
		    catch
		      return new NothingObject
		    end try
		  end if
		  
		  ' Is this a destructive operation? - slice!()
		  parent.value = if(destructive, result, parent.value)
		  
		  return new TextObject(result)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function DoSliceStartEnd(start as Integer, length as Integer, destructive as Boolean, where as Token) As Variant
		  ' Text.slice(start, length) as Text  |  Text.slice!(start, length) as Text
		  ' Indices are zero-based.
		  ' Returns a new Text object of length `length` starting from position `start`. 
		  ' If start < 0 then we count backwards from the end of the text to find the start character. 
		  ' Whenever Nothing is returned, we leave the original text alone (even if it's a destructive operation).
		  ' 
		  ' E.g:
		  ' var t = "Hello World"
		  ' t.slice(0, 3)  # "Hel"
		  ' t.slice(2, 6)  # "llo Wo"
		  ' t.slice(-3, 2) # "rl"
		  ' t.slice(2, -5) # Nothing
		  ' t.slice(7, 2)  # "or"
		  ' t.slice(7, 4)  # "orld"
		  ' t.slice(7, 8)  # "orld"
		  
		  dim result as String
		  
		  ' Make sure `length` is valid.
		  if length <= 0 then return new NothingObject
		  
		  ' Make sure a valid start position has been passed.
		  if Abs(start) > parent.value.Len then
		    raise new RuntimeError(where, self.name + "(start, length): " + _
		    "Argument `start` must not exceed the number of characters in the Text object.")
		  end if
		  
		  ' Adjust the start position as required.
		  if start < 0 then start = parent.value.Len + start
		  
		  ' If the user has passed a length greater than the number of characters remaining between 
		  ' `start` and the end of the text, adjust `length` such that we return all characters from 
		  ' `start` to the end of the text.
		  length = if(start + length > parent.value.Len, parent.value.Len - start, length)
		  
		  try
		    result = parent.value.Mid(start+1, length)
		  catch
		    return new NothingObject
		  end try
		  
		  parent.value = if(destructive, result, parent.value)
		  
		  return new TextObject(result)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function DoStartsWith(arguments() as Variant, where as Token) As BooleanObject
		  ' Text.starts_with?(what as Text) as Boolean.
		  
		  ' Check that `what` has a text representation
		  if not arguments(0) isA Textable then
		    raise new RuntimeError(where, "The " + self.name + "(what) method expects a parameter that has . " + _
		    "a text representation. Instead got " + VariantType(arguments(0)) + ".")
		  end if
		  
		  dim what as String = Textable(arguments(0)).ToText
		  
		  if StrComp(parent.value.Left(what.Len), what, 0) = 0 then
		    return new BooleanObject(True)
		  else
		    return new BooleanObject(False)
		  end if
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Invoke(interpreter as Interpreter, arguments() as Variant, where as Token) As Variant
		  #pragma Unused interpreter
		  
		  select case self.name
		  case "ends_with?"
		    return DoEndsWith(arguments, where)
		  case "include?"
		    return DoInclude(arguments, where)
		  case "index"
		    return DoIndex(arguments, where)
		  case "match"
		    return DoMatch(arguments, where)
		  case "matches?"
		    return DoMatches(arguments, where)
		  case "replace_all"
		    return DoReplaceAll(arguments, False, where)
		  case "replace_all!"
		    return DoReplaceAll(arguments, True, where)
		  case "replace_first"
		    return DoReplaceFirst(arguments, False, where)
		  case "replace_first!"
		    return DoReplaceFirst(arguments, True, where)
		  case "responds_to?"
		    return DoRespondsTo(arguments, where)
		  case "slice"
		    return DoSlice(arguments, False, where)
		  case "slice!"
		    return DoSlice(arguments, True, where)
		  case "starts_with?"
		    return DoStartsWith(arguments, where)
		  end select
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function Reverse(s as String) As String
		  ' Internal helper method. Simply returns the reversed version of String `s`.
		  
		  if s = "" then return ""
		  
		  dim chars() as String = s.Split("")
		  dim result as String
		  dim i, limit as Integer
		  
		  limit = chars.Ubound
		  for i = limit downTo 0
		    result = result + chars(i)
		  next i
		  
		  return result
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function ToText(interpreter As Roo.Interpreter = Nil) As String
		  ' Part of the Textable interface.
		  
		  #Pragma Unused interpreter
		  
		  Return "<function " + Self.Name + ">"
		End Function
	#tag EndMethod


	#tag Property, Flags = &h0
		name As String
	#tag EndProperty

	#tag Property, Flags = &h0
		parent As TextObject
	#tag EndProperty


	#tag ViewBehavior
		#tag ViewProperty
			Name="name"
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
