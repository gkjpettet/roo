#tag Class
Protected Class RegexObjectMethod
Implements Roo.Invokable,Roo.Textable
	#tag Method, Flags = &h0
		Function Arity() As Variant
		  select case self.name
		  case "match"
		    return Array(1, 2)
		  case "matches?"
		    return 1
		  case "responds_to?"
		    return 1
		  end select
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor(parent as RegexObject, name as String)
		  self.parent = parent
		  self.name = name
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function DoMatch(args() as Variant, where as Token) As Variant
		  ' Regex.match(what as Text) as RegexResultObject or Nothing
		  ' Regex.match(what as Text, start as Integer) as RegexResultObject or Nothing
		  
		  dim finish, pos, start as Integer
		  dim what, value as String
		  dim match as RegexMatchObject
		  dim result as new RegexResultObject
		  dim i as VariantToVariantHashMapIteratorMBS
		  dim e as VariantToVariantHashMapIteratorMBS
		  
		  ' Make sure a Textable argument is passed to the method.
		  if not args(0) isA Textable then
		    raise new RuntimeError(where, "The " + self.name + "(what) method expects a parameter with a " + _
		    "text representation. Instead got " + VariantType(args(0)) + ".")
		  end if
		  
		  ' If the optional `start` argument is passed make sure it's an integer.
		  if args.Ubound = 1 then
		    if not args(1) isA NumberObject and not NumberObject(args(1)).IsInteger then
		      raise new RuntimeError(where, "The " + self.name + "(what, start) expected an integer parameter " + _
		      "for `start`. Instead got " + VariantType(args(1)) + ".")
		    end if
		    start = NumberObject(args(1)).value
		  end if
		  
		  ' Get the text to search.
		  if args(0) isA TextObject then
		    what = TextObject(args(0)).value
		  else
		    what = Textable(args(0)).ToText
		  end if
		  
		  ' Valid start position?
		  if start < 0 then
		    raise new RuntimeError(where, "The `start` argument must be a positive integer.")
		  elseif start > 0 and start > (what.Len - 1) then
		    raise new RuntimeError(where, _
		    "The `start` argument cannot exceed the length of the text to search.")
		  end if
		  
		  ' Do the search.
		  while parent.re.Execute(what, start) > 0
		    ' Found another match in the string. Create a new match object to represent it.
		    pos = parent.re.OffsetCharacters(0)
		    finish = parent.re.OffsetCharacters(1)
		    value = what.Mid(pos + 1, finish - pos)
		    match = new RegexMatchObject(new MatchInfoObject(pos, finish, value))
		    result.matches.Append(match)
		    
		    ' Loop through each of the named groups in the regex and determine their values.
		    i = parent.namedGroups.first
		    e = parent.namedGroups.last
		    while i.isNotEqual(e)
		      value = parent.re.Substring(i.Key.StringValue)
		      try
		        pos = what.InStrB(start, value)
		      catch ' Ignore.
		      end try
		      match.AddValueForNamedGroup(i.Key, new MatchInfoObject(pos -1, pos + value.Len - 1, value))
		      i.MoveNext()
		    wend
		    
		    ' Loop through each of the capture groups in the regex and determine their values.
		    i = parent.groups.first
		    e = parent.groups.last
		    while i.isNotEqual(e)
		      value = parent.re.Substring(i.Key.DoubleValue)
		      try
		        pos = what.InStrB(start, value)
		      catch ' Ignore.
		      end try
		      match.AddValueForGroupNumber(i.Key, new MatchInfoObject(pos - 1, pos + value.Len - 1, value))
		      i.MoveNext()
		    wend
		    
		    ' Search again
		    start = parent.re.Offset(1)
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
		  ' Regex.matches?(what as Text) as Boolean.
		  
		  ' Make sure a Textable argument is passed to the method.
		  if not args(0) isA Textable then
		    raise new RuntimeError(where, "The " + self.name + "(what) method expects a parameter with a " + _
		    "text representation. Instead got " + VariantType(args(0)) + ".")
		  end if
		  
		  dim what as String
		  if args(0) isA TextObject then
		    what = TextObject(args(0)).value
		  else
		    what = Textable(args(0)).ToText
		  end if
		  
		  ' Return whether there is a match or not.
		  return new BooleanObject(parent.re.Match(what))
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function DoRespondsTo(arguments() as Variant, where as Token) As BooleanObject
		  ' Regex.responds_to?(what as Text) as Boolean.
		  
		  ' Make sure a Text argument is passed to the method.
		  if not arguments(0) isA TextObject then
		    raise new RuntimeError(where, "The " + self.name + "(what) method expects an integer parameter. " + _
		    "Instead got " + VariantType(arguments(0)) + ".")
		  end if
		  
		  dim what as String = TextObject(arguments(0)).value
		  
		  if Lookup.RegexGetter(what) then
		    return new BooleanObject(True)
		  elseif Lookup.RegexMethod(what) then
		    return new BooleanObject(True)
		  else
		    return new BooleanObject(False)
		  end if
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Invoke(interpreter as Interpreter, arguments() as Variant, where as Token) As Variant
		  #pragma Unused arguments
		  #pragma Unused interpreter
		  #pragma Unused where
		  
		  select case self.name
		  case "match"
		    return DoMatch(arguments, where)
		  case "matches?"
		    return DoMatches(arguments, where)
		  case "responds_to?"
		    return DoRespondsTo(arguments, where)
		  end select
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
		parent As RegexObject
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
