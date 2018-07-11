#tag Class
Protected Class RegexMatchObjectMethod
Implements Roo.Invokable,Roo.Textable
	#tag Method, Flags = &h0
		Function Arity() As Variant
		  select case self.name
		  case "group"
		    return 1
		  case "name"
		    return 1
		  case "responds_to?"
		    return 1
		  end select
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor(parent as RegexMatchObject, name as String)
		  self.parent = parent
		  self.name = name
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function DoGroup(args() as Variant, where as Token) As Variant
		  ' RegexMatch.group(number as Integer) as MatchInfo.
		  ' Returns the MatchInfo for the specified group or Nothing if there is no capture group with the 
		  ' specified number.
		  
		  dim number as Integer
		  
		  ' Check that `index` is a positive integer.
		  if not args(0) isA NumberObject or not NumberObject(args(0)).IsInteger then
		    raise new RuntimeError(where, "The " + self.name + "(number) method expects an integer parameter. " + _
		    "Instead got " + VariantType(args(0)) + ".")
		  else
		    number = NumberObject(args(0)).value
		    if number < 0 then
		      raise new RuntimeError(where, "The " + self.name + "(number) method expects an integer parameter " + _
		      " >= 0. Instead got " + VariantType(args(0)) + ".")
		    end if
		  end if
		  
		  return parent.groups.Lookup(number, new NothingObject)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function DoName(args() as Variant, where as Token) As Variant
		  ' RegexMatch.name(name as Text) as MatchInfo.
		  ' Returns the MatchInfo for the specified named group or Nothing if there is no capture group with the 
		  ' specified name.
		  
		  ' Check that `name` is text.
		  if not args(0) isA TextObject then
		    raise new RuntimeError(where, "The " + self.name + "(name) method expects a text argument. " +_
		    "Instead got " + VariantType(args(0)) + ".")
		  end if
		  
		  return parent.namedGroups.Lookup(TextObject(args(0)).value, new NothingObject)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function DoRespondsTo(arguments() as Variant, where as Token) As BooleanObject
		  ' RegexMatch.responds_to?(what as Text) as Boolean.
		  
		  ' Make sure a Text argument is passed to the method.
		  if not arguments(0) isA TextObject then
		    raise new RuntimeError(where, "The " + self.name + "(what) method expects an integer parameter. " + _
		    "Instead got " + VariantType(arguments(0)) + ".")
		  end if
		  
		  dim what as String = TextObject(arguments(0)).value
		  
		  if Lookup.RegexMatchGetter(what) then
		    return new BooleanObject(True)
		  elseif Lookup.RegexMatchMethod(what) then
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
		  case "group"
		    return DoGroup(arguments, where)
		  case "name"
		    return DoName(arguments, where)
		  case "responds_to?"
		    return DoRespondsTo(arguments, where)
		  end select
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function ToText() As String
		  ' Part of the Textable interface.
		  
		  return "<function " + self.name + ">"
		End Function
	#tag EndMethod


	#tag Property, Flags = &h0
		name As String
	#tag EndProperty

	#tag Property, Flags = &h0
		parent As RegexMatchObject
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
