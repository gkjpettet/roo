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
		  
		  Select Case type
		  Case TokenType.AND_KEYWORD
		    Return "AND"
		  Case TokenType.ARROW
		    Return "ARROW"
		  Case TokenType.BANG
		    Return "BANG"
		  Case TokenType.Boolean
		    Return "BOOLEAN"
		  Case TokenType.BREAK_KEYWORD
		    Return "BREAK"
		  Case TokenType.CARET
		    Return "CARET"
		  Case TokenType.CLASS_KEYWORD
		    Return "CLASS"
		  Case TokenType.COLON
		    Return "COLON"
		  Case TokenType.COMMA
		    Return "COMMA"
		  Case TokenType.DOT
		    Return "DOT"
		  Case TokenType.ELSE_KEYWORD
		    Return "ELSE"
		  Case TokenType.EOF
		    Return "EOF"
		  Case TokenType.EQUAL
		    Return "EQUAL"
		  Case TokenType.EQUAL_EQUAL
		    Return "EQUAL_EQUAL"
		  Case TokenType.Error
		    Return "ERROR"
		  Case TokenType.EXIT_KEYWORD
		    Return "EXIT"
		  Case TokenType.FOR_KEYWORD
		    Return "FOR"
		  Case TokenType.FUNCTION_KEYWORD
		    Return "FUNCTION"
		  Case TokenType.GREATER
		    Return "GREATER"
		  Case TokenType.GREATER_EQUAL
		    Return "GREATER_EQUAL"
		  Case TokenType.IDENTIFIER
		    Return "IDENTIFIER"
		  Case TokenType.IF_KEYWORD
		    Return "IF"
		  Case TokenType.LCURLY
		    Return "LCURLY"
		  Case TokenType.LESS
		    Return "LESS"
		  Case TokenType.LESS_EQUAL
		    Return "LESS_EQUAL"
		  Case TokenType.LPAREN
		    Return "LPAREN"
		  Case TokenType.LSQUARE
		    Return "LSQUARE"
		  Case TokenType.MINUS
		    Return "MINUS"
		  Case TokenType.MINUS_EQUAL
		    Return "MINUS_EQUAL"
		  Case TokenType.MINUS_MINUS
		    Return "MINUS_MINUS"
		  Case TokenType.MODULE_KEYWORD
		    Return "MODULE"
		  Case TokenType.NEWLINE
		    Return "NEWLINE"
		  Case TokenType.NOT_EQUAL
		    Return "NOT_EQUAL"
		  Case TokenType.NOTHING
		    Return "NOTHING"
		  Case TokenType.NOT_KEYWORD
		    Return "NOT"
		  Case TokenType.NUMBER
		    Return "NUMBER"
		  Case TokenType.OR_KEYWORD
		    Return "OR"
		  Case TokenType.PERCENT
		    Return "PERCENT"
		  Case TokenType.PERCENT_EQUAL
		    Return "PERCENT_EQUAL"
		  Case TokenType.PIPE
		    Return "PIPE"
		  Case TokenType.PLUS
		    Return "PLUS"
		  Case TokenType.PLUS_EQUAL
		    Return "PLUS_EQUAL"
		  Case TokenType.PLUS_PLUS
		    Return "PLUS_PLUS"
		  Case TokenType.QUERY
		    Return "QUERY"
		  Case TokenType.QUIT_KEYWORD
		    Return "QUIT"
		  Case TokenType.RCURLY
		    Return "RCURLY"
		  Case TokenType.REGEX
		    Return "REGEX"
		  Case TokenType.REQUIRE_KEYWORD
		    Return "REQUIRE"
		  Case TokenType.RETURN_KEYWORD
		    Return "RETURN"
		  Case TokenType.RPAREN
		    Return "RPAREN"
		  Case TokenType.RSQUARE
		    Return "RSQUARE"
		  Case TokenType.SELF_KEYWORD
		    Return "SELF"
		  Case TokenType.SEMICOLON
		    Return "SEMICOLON"
		  Case TokenType.SLASH
		    Return "SLASH"
		  Case TokenType.SLASH_EQUAL
		    Return "SLASH_EQUAL"
		  Case TokenType.STATIC_KEYWORD
		    Return "STATIC"
		  Case TokenType.STAR
		    Return "STAR"
		  Case TokenType.STAR_EQUAL
		    Return "STAR_EQUAL"
		  Case TokenType.SUPER_KEYWORD
		    Return "SUPER"
		  Case TokenType.TEXT
		    Return "TEXT"
		  Case TokenType.VAR
		    Return "VAR"
		  Case TokenType.WHILE_KEYWORD
		    Return "WHILE"
		  Else
		    Return "UNKNOWN TOKEN"
		  End Select
		End Function
	#tag EndMethod


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
		MaybeHash As Boolean = False
	#tag EndProperty

	#tag Property, Flags = &h0
		Start As Integer
	#tag EndProperty

	#tag Property, Flags = &h0
		Type As TokenType
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
			Name="Start"
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
			Name="Finish"
			Group="Behavior"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="MaybeHash"
			Group="Behavior"
			InitialValue="False"
			Type="Boolean"
		#tag EndViewProperty
	#tag EndViewBehavior
End Class
#tag EndClass
