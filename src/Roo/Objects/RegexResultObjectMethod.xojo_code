#tag Class
Protected Class RegexResultObjectMethod
Implements  Roo.Invokable,  Roo.Textable
	#tag Method, Flags = &h0
		Function Arity() As Variant
		  select case self.name
		  case "match"
		    return 1
		  case "responds_to?"
		    return 1
		  end select
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor(parent as RegexResultObject, name as String)
		  self.parent = parent
		  self.name = name
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function DoMatch(args() as Variant, where as Token) As Variant
		  ' RegexResult.match(index as Integer) as RegexMatch
		  ' Returns the specified RegexMatch object.
		  ' `index` is zero-based (i.e. the first match is 0).
		  ' Returns Nothing if `index` is out of bounds.
		  
		  ' Check that `index` is an integer.
		  dim index as Integer
		  if not args(0) isA NumberObject or not NumberObject(args(0)).IsInteger then
		    raise new RuntimeError(where, "The " + self.name + "(index) method expects an integer parameter. " + _
		    "Instead got " + VariantType(args(0)) + ".")
		  else
		    index = NumberObject(args(0)).value
		    ' Make sure that it's a positive integer.
		    if index < 0 then
		      raise new RuntimeError(where, "The " + self.name + "(index) method expects an integer parameter " + _
		      ">= 0. Instead got " + Str(index) + ".")
		    end if
		  end if
		  
		  try
		    return parent.matches(index)
		  catch OutOfBoundsException
		    return new NothingObject
		  end try
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function DoRespondsTo(arguments() as Variant, where as Token) As BooleanObject
		  ' RegexResult.responds_to?(what as Text) as Boolean.
		  
		  ' Make sure a Text argument is passed to the method.
		  if not arguments(0) isA TextObject then
		    raise new RuntimeError(where, "The " + self.name + "(what) method expects an integer parameter. " + _
		    "Instead got " + VariantType(arguments(0)) + ".")
		  end if
		  
		  dim what as String = TextObject(arguments(0)).value
		  
		  if Lookup.RegexResultGetter(what) then
		    return new BooleanObject(True)
		  elseif Lookup.RegexResultMethod(what) then
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
		parent As RegexResultObject
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
