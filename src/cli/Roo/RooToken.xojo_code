#tag Class
Protected Class RooToken
	#tag Method, Flags = &h0
		Sub Constructor()
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor(type As Roo.TokenType)
		  Self.Type = type
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Shared Function TypeToString(type As Roo.TokenType) As String
		  ' Returns a String representation of a TokenType enumeration.
		  
		  Select Case type
		  Case Roo.TokenType.AMPERSAND
		    Return "AMPERSAND"
		  Case Roo.TokenType.AND_KEYWORD
		    Return "AND"
		  Case Roo.TokenType.ARROW
		    Return "ARROW"
		  Case Roo.TokenType.BANG
		    Return "BANG"
		  Case Roo.TokenType.Boolean
		    Return "BOOLEAN"
		  Case Roo.TokenType.BREAK_KEYWORD
		    Return "BREAK"
		  Case Roo.TokenType.CARET
		    Return "CARET"
		  Case Roo.TokenType.CLASS_KEYWORD
		    Return "CLASS"
		  Case Roo.TokenType.COLON
		    Return "COLON"
		  Case Roo.TokenType.COMMA
		    Return "COMMA"
		  Case Roo.TokenType.DEDENT
		    Return "DEDENT"
		  Case Roo.TokenType.DEF_KEYWORD
		    Return "DEF"
		  Case Roo.TokenType.DOT
		    Return "DOT"
		  Case Roo.TokenType.ELSE_KEYWORD
		    Return "ELSE"
		  Case Roo.TokenType.EOF
		    Return "EOF"
		  Case Roo.TokenType.EQUAL
		    Return "EQUAL"
		  Case Roo.TokenType.EQUAL_EQUAL
		    Return "EQUAL_EQUAL"
		  Case Roo.TokenType.Error
		    Return "ERROR"
		  Case Roo.TokenType.EXIT_KEYWORD
		    Return "EXIT"
		  Case Roo.TokenType.FOR_KEYWORD
		    Return "FOR"
		  Case Roo.TokenType.GREATER
		    Return "GREATER"
		  Case Roo.TokenType.GREATER_EQUAL
		    Return "GREATER_EQUAL"
		  Case Roo.TokenType.GREATER_GREATER
		    Return "GREATER_GREATER"
		  Case Roo.TokenType.IDENTIFIER
		    Return "IDENTIFIER"
		  Case Roo.TokenType.IF_KEYWORD
		    Return "IF"
		  Case Roo.TokenType.INDENT
		    Return "INDENT"
		  Case Roo.TokenType.LCURLY
		    Return "LCURLY"
		  Case Roo.TokenType.LESS
		    Return "LESS"
		  Case Roo.TokenType.LESS_EQUAL
		    Return "LESS_EQUAL"
		  Case Roo.TokenType.LESS_LESS
		    Return "LESS_LESS"
		  Case Roo.TokenType.LPAREN
		    Return "LPAREN"
		  Case Roo.TokenType.LSQUARE
		    Return "LSQUARE"
		  Case Roo.TokenType.MINUS
		    Return "MINUS"
		  Case Roo.TokenType.MINUS_EQUAL
		    Return "MINUS_EQUAL"
		  Case Roo.TokenType.MINUS_MINUS
		    Return "MINUS_MINUS"
		  Case Roo.TokenType.MODULE_KEYWORD
		    Return "MODULE"
		  Case Roo.TokenType.NOT_EQUAL
		    Return "NOT_EQUAL"
		  Case Roo.TokenType.NOTHING
		    Return "NOTHING"
		  Case Roo.TokenType.NOT_KEYWORD
		    Return "NOT"
		  Case Roo.TokenType.NUMBER
		    Return "NUMBER"
		  Case Roo.TokenType.OR_KEYWORD
		    Return "OR"
		  Case ROo.TokenType.PASS_KEYWORD
		    Return "PASS"
		  Case Roo.TokenType.PERCENT
		    Return "PERCENT"
		  Case Roo.TokenType.PERCENT_EQUAL
		    Return "PERCENT_EQUAL"
		  Case Roo.TokenType.PIPE
		    Return "PIPE"
		  Case Roo.TokenType.PLUS
		    Return "PLUS"
		  Case Roo.TokenType.PLUS_EQUAL
		    Return "PLUS_EQUAL"
		  Case Roo.TokenType.PLUS_PLUS
		    Return "PLUS_PLUS"
		  Case Roo.TokenType.QUERY
		    Return "QUERY"
		  Case Roo.TokenType.QUIT_KEYWORD
		    Return "QUIT"
		  Case Roo.TokenType.RCURLY
		    Return "RCURLY"
		  Case Roo.TokenType.REQUIRE_KEYWORD
		    Return "REQUIRE"
		  Case Roo.TokenType.RETURN_KEYWORD
		    Return "RETURN"
		  Case Roo.TokenType.RPAREN
		    Return "RPAREN"
		  Case Roo.TokenType.RSQUARE
		    Return "RSQUARE"
		  Case Roo.TokenType.SELF_KEYWORD
		    Return "SELF"
		  Case Roo.TokenType.SLASH
		    Return "SLASH"
		  Case Roo.TokenType.SLASH_EQUAL
		    Return "SLASH_EQUAL"
		  Case Roo.TokenType.STATIC_KEYWORD
		    Return "STATIC"
		  Case Roo.TokenType.STAR
		    Return "STAR"
		  Case Roo.TokenType.STAR_EQUAL
		    Return "STAR_EQUAL"
		  Case Roo.TokenType.SUPER_KEYWORD
		    Return "SUPER"
		  Case Roo.TokenType.TERMINATOR
		    Return "TERMINATOR"
		  Case Roo.TokenType.TEXT
		    Return "TEXT"
		  Case Roo.TokenType.TILDE
		    Return "TILDE"
		  Case Roo.TokenType.VAR
		    Return "VAR"
		  Case Roo.TokenType.WHILE_KEYWORD
		    Return "WHILE"
		  Else
		    Return "UNKNOWN TOKEN"
		  End Select
		End Function
	#tag EndMethod


	#tag Property, Flags = &h0
		Base As RooToken.BaseType
	#tag EndProperty

	#tag Property, Flags = &h0
		File As FolderItem
	#tag EndProperty

	#tag Property, Flags = &h0
		Finish As Integer
	#tag EndProperty

	#tag Property, Flags = &h0
		Length As Integer
	#tag EndProperty

	#tag Property, Flags = &h0
		Lexeme As String
	#tag EndProperty

	#tag Property, Flags = &h0
		Line As Integer
	#tag EndProperty

	#tag Property, Flags = &h0
		Start As Integer
	#tag EndProperty

	#tag Property, Flags = &h0
		Type As Roo.TokenType
	#tag EndProperty


	#tag Enum, Name = BaseType, Flags = &h0
		Binary
		  Decimal
		  Hexadecimal
		Octal
	#tag EndEnum


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
			Name="Type"
			Group="Behavior"
			Type="Roo.TokenType"
			EditorType="Enum"
			#tag EnumValues
				"0 - AMPERSAND"
				"1 - AND_KEYWORD"
				"2 - ARROW"
				"3 - BANG"
				"4 - BOOLEAN"
				"5 - BREAK_KEYWORD"
				"6 - CARET"
				"7 - CLASS_KEYWORD"
				"8 - COLON"
				"9 - COMMA"
				"10 - DEDENT"
				"11 - DEF_KEYWORD"
				"12 - DOT"
				"13 - ELSE_KEYWORD"
				"14 - EQUAL"
				"15 - EQUAL_EQUAL"
				"16 - EOF"
				"17 - ERROR"
				"18 - EXIT_KEYWORD"
				"19 - FOR_KEYWORD"
				"20 - GREATER"
				"21 - GREATER_EQUAL"
				"22 - GREATER_GREATER"
				"23 - IDENTIFIER"
				"24 - IF_KEYWORD"
				"25 - INDENT"
				"26 - LCURLY"
				"27 - LESS"
				"28 - LESS_EQUAL"
				"29 - LESS_LESS"
				"30 - LPAREN"
				"31 - LSQUARE"
				"32 - MINUS"
				"33 - MINUS_EQUAL"
				"34 - MINUS_MINUS"
				"35 - MODULE_KEYWORD"
				"36 - NOT_EQUAL"
				"37 - NOT_KEYWORD"
				"38 - NOTHING"
				"39 - NUMBER"
				"40 - OR_KEYWORD"
				"41 - PASS_KEYWORD"
				"42 - PERCENT"
				"43 - PERCENT_EQUAL"
				"44 - PIPE"
				"45 - PLUS"
				"46 - PLUS_EQUAL"
				"47 - PLUS_PLUS"
				"48 - QUERY"
				"49 - QUIT_KEYWORD"
				"50 - RCURLY"
				"51 - REQUIRE_KEYWORD"
				"52 - RETURN_KEYWORD"
				"53 - RPAREN"
				"54 - RSQUARE"
				"55 - SELF_KEYWORD"
				"56 - SLASH"
				"57 - SLASH_EQUAL"
				"58 - STAR_EQUAL"
				"59 - STAR"
				"60 - STATIC_KEYWORD"
				"61 - SUPER_KEYWORD"
				"62 - TERMINATOR"
				"63 - TEXT"
				"64 - TILDE"
				"65 - VAR"
				"66 - WHILE_KEYWORD"
			#tag EndEnumValues
		#tag EndViewProperty
		#tag ViewProperty
			Name="Finish"
			Group="Behavior"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Length"
			Group="Behavior"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Lexeme"
			Group="Behavior"
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Line"
			Group="Behavior"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Start"
			Group="Behavior"
			Type="Integer"
		#tag EndViewProperty
	#tag EndViewBehavior
End Class
#tag EndClass
