#tag Class
Protected Class Token
	#tag Method, Flags = &h0
		Sub Constructor()
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor(type as TokenType)
		  self.type = type
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function ToString() As String
		  ' Returns a String representation of this token.
		  
		  return Str(line) + ", " + Str(start) + &u9 + Token.TypeToString(type) + &u9 + lexeme
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Shared Function TypeToString(type as TokenType) As String
		  ' Returns a String representation of a TokenType enumeration.
		  
		  select case type
		  case TokenType.AND_KEYWORD
		    return "AND"
		  case TokenType.ARROW
		    return "ARROW"
		  case TokenType.BANG
		    return "BANG"
		  case TokenType.BOOLEAN
		    return "BOOLEAN"
		  case TokenType.BREAK_KEYWORD
		    return "BREAK"
		  case TokenType.CARET
		    return "CARET"
		  case TokenType.CLASS_KEYWORD
		    return "CLASS"
		  case TokenType.COLON
		    return "COLON"
		  case TokenType.COMMA
		    return "COMMA"
		  case TokenType.DOT
		    return "DOT"
		  case TokenType.ELSE_KEYWORD
		    return "ELSE"
		  case TokenType.EOF
		    return "EOF"
		  case TokenType.EQUAL
		    return "EQUAL"
		  case TokenType.EQUAL_EQUAL
		    return "EQUAL_EQUAL"
		  case TokenType.ERROR
		    return "ERROR"
		  case TokenType.FOR_KEYWORD
		    return "FOR"
		  case TokenType.FUNCTION_KEYWORD
		    return "FUNCTION"
		  case TokenType.GREATER
		    return "GREATER"
		  case TokenType.GREATER_EQUAL
		    return "GREATER_EQUAL"
		  case TokenType.IDENTIFIER
		    return "IDENTIFIER"
		  case TokenType.IF_KEYWORD
		    return "IF"
		  case TokenType.LCURLY
		    return "LCURLY"
		  case TokenType.LESS
		    return "LESS"
		  case TokenType.LESS_EQUAL
		    return "LESS_EQUAL"
		  case TokenType.LPAREN
		    return "LPAREN"
		  case TokenType.LSQUARE
		    return "LSQUARE"
		  case TokenType.MINUS
		    return "MINUS"
		  case TokenType.MINUS_EQUAL
		    return "MINUS_EQUAL"
		  case TokenType.MINUS_MINUS
		    return "MINUS_MINUS"
		  case TokenType.MODULE_KEYWORD
		    return "MODULE"
		  case TokenType.NEWLINE
		    return "NEWLINE"
		  case TokenType.NOT_EQUAL
		    return "NOT_EQUAL"
		  case TokenType.NOTHING
		    return "NOTHING"
		  case TokenType.NOT_KEYWORD
		    return "NOT"
		  case TokenType.NUMBER
		    return "NUMBER"
		  case TokenType.OR_KEYWORD
		    return "OR"
		  case TokenType.PERCENT
		    return "PERCENT"
		  case TokenType.PERCENT_EQUAL
		    return "PERCENT_EQUAL"
		  case TokenType.PIPE
		    return "PIPE"
		  case TokenType.PLUS
		    return "PLUS"
		  case TokenType.PLUS_EQUAL
		    return "PLUS_EQUAL"
		  case TokenType.PLUS_PLUS
		    return "PLUS_PLUS"
		  case TokenType.QUERY
		    return "QUERY"
		  case TokenType.QUIT_KEYWORD
		    return "QUIT"
		  case TokenType.RCURLY
		    return "RCURLY"
		  case TokenType.REGEX
		    return "REGEX"
		  case TokenType.REQUIRE_KEYWORD
		    return "REQUIRE"
		  case TokenType.RETURN_KEYWORD
		    return "RETURN"
		  case TokenType.RPAREN
		    return "RPAREN"
		  case TokenType.RSQUARE
		    return "RSQUARE"
		  case TokenType.SELF_KEYWORD
		    return "SELF"
		  case TokenType.SEMICOLON
		    return "SEMICOLON"
		  case TokenType.SLASH
		    return "SLASH"
		  case TokenType.SLASH_EQUAL
		    return "SLASH_EQUAL"
		  case TokenType.STATIC_KEYWORD
		    return "STATIC"
		  case TokenType.STAR
		    return "STAR"
		  case TokenType.STAR_EQUAL
		    return "STAR_EQUAL"
		  case TokenType.SUPER_KEYWORD
		    return "SUPER"
		  case TokenType.TEXT
		    return "TEXT"
		  case TokenType.VAR
		    return "VAR"
		  case TokenType.WHILE_KEYWORD
		    return "WHILE"
		  else
		    return "UNKNOWN TOKEN"
		  end select
		End Function
	#tag EndMethod


	#tag Property, Flags = &h0
		File As FolderItem
	#tag EndProperty

	#tag Property, Flags = &h0
		finish As Integer
	#tag EndProperty

	#tag Property, Flags = &h0
		length As Integer
	#tag EndProperty

	#tag Property, Flags = &h0
		lexeme As String
	#tag EndProperty

	#tag Property, Flags = &h0
		line As Integer
	#tag EndProperty

	#tag Property, Flags = &h0
		start As Integer
	#tag EndProperty

	#tag Property, Flags = &h0
		type As TokenType
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
			Name="start"
			Group="Behavior"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="length"
			Group="Behavior"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="lexeme"
			Group="Behavior"
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="line"
			Group="Behavior"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="finish"
			Group="Behavior"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="type"
			Group="Behavior"
			Type="TokenType"
		#tag EndViewProperty
	#tag EndViewBehavior
End Class
#tag EndClass
