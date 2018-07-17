#tag Module
Protected Module Roo
	#tag Method, Flags = &h0
		Function DoubleToString(d as Double) As String
		  ' Converts a Double to a String. Used for prettier printing of Doubles that are Integers.
		  
		  if d.IsInteger then
		    dim i as Integer = d
		    return Str(i)
		  else
		    return Str(d)
		  end if
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function IsInteger(extends d as Double) As Boolean
		  return if(Round(d) = d, True, False)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function ToBoolean(extends s as String) As Boolean
		  return if(s = "True", True, False)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function ToInteger(extends d as Double) As Integer
		  return d
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function ToString(extends b as Boolean) As String
		  return if(b = True, "True", "False")
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function VariantType(v as Variant) As String
		  ' A more robust implementation of Variant.StringValue().
		  
		  if v = Nil then return "Nil"
		  if v isA BooleanObject then return "Boolean object"
		  if v isA NumberObject then return "Number object"
		  if v isA TextObject then return "Text object"
		  if v isA NothingObject then return "Nothing"
		  if v isA RooClass then return RooClass(v).name + " class"
		  if v isA RooFunction then return RooFunction(v).ToText
		  if v isA RooInstance then return RooInstance(v).ToText
		  
		  dim info as Xojo.Introspection.TypeInfo = Xojo.Introspection.GetType(v)
		  return info.Name
		  
		  exception err
		    return "Cannot determine variant type."
		End Function
	#tag EndMethod


	#tag Constant, Name = VERSION_BUG, Type = Double, Dynamic = False, Default = \"4", Scope = Public
	#tag EndConstant

	#tag Constant, Name = VERSION_MAJOR, Type = Double, Dynamic = False, Default = \"2", Scope = Public
	#tag EndConstant

	#tag Constant, Name = VERSION_MINOR, Type = Double, Dynamic = False, Default = \"1", Scope = Public
	#tag EndConstant


	#tag Enum, Name = TokenType, Type = Integer, Flags = &h0
		AND_KEYWORD
		  ARROW
		  BANG
		  BOOLEAN
		  BREAK_KEYWORD
		  CARET
		  CLASS_KEYWORD
		  COLON
		  COMMA
		  DOT
		  ELSE_KEYWORD
		  EQUAL
		  EQUAL_EQUAL
		  EOF
		  ERROR
		  FOR_KEYWORD
		  FUNCTION_KEYWORD
		  GREATER
		  GREATER_EQUAL
		  IDENTIFIER
		  IF_KEYWORD
		  LCURLY
		  LESS
		  LESS_EQUAL
		  LPAREN
		  LSQUARE
		  MINUS
		  MINUS_EQUAL
		  MINUS_MINUS
		  MODULE_KEYWORD
		  NEWLINE
		  NOT_EQUAL
		  NOT_KEYWORD
		  NOTHING
		  NUMBER
		  OR_KEYWORD
		  PERCENT
		  PERCENT_EQUAL
		  PIPE
		  PLUS
		  PLUS_EQUAL
		  PLUS_PLUS
		  QUERY
		  QUIT_KEYWORD
		  RCURLY
		  REGEX
		  RETURN_KEYWORD
		  RPAREN
		  RSQUARE
		  SELF_KEYWORD
		  SEMICOLON
		  SLASH
		  SLASH_EQUAL
		  STAR_EQUAL
		  STAR
		  STATIC_KEYWORD
		  SUPER_KEYWORD
		  TEXT
		  VAR
		WHILE_KEYWORD
	#tag EndEnum

	#tag Using, Name = Roo.Expressions
	#tag EndUsing

	#tag Using, Name = Roo.Native.Functions
	#tag EndUsing

	#tag Using, Name = Roo.Native.Modules
	#tag EndUsing

	#tag Using, Name = Roo.Objects
	#tag EndUsing

	#tag Using, Name = Roo.Statements
	#tag EndUsing


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
End Module
#tag EndModule
