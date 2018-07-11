#tag Class
Protected Class Scanner
	#tag Method, Flags = &h21
		Private Sub AddReservedWord(word as String)
		  ' Convenience method for adding reserved words to our case-sensitive hash map.
		  
		  reserved.Value(word) = ""
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub Advance()
		  ' Consumes the current character in the source.
		  
		  current = current + 1
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function Advance() As String
		  ' Consumes and returns the current character in the source.
		  
		  current = current + 1
		  return source.Mid(current - 1, 1)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor(sourceToScan as String)
		  ' Define the reserved words in the language.
		  reserved = new StringToStringHashMapMBS(True)
		  
		  AddReservedWord("True")
		  AddReservedWord("False")
		  
		  AddReservedWord("Print") ' HACK: Our baked-in Print() function.
		  
		  AddReservedWord("and")
		  AddReservedWord("break")
		  AddReservedWord("class")
		  AddReservedWord("else")
		  AddReservedWord("function")
		  AddReservedWord("if")
		  AddReservedWord("let")
		  AddReservedWord("module")
		  AddReservedWord("next")
		  AddReservedWord("not")
		  AddReservedWord("or")
		  AddReservedWord("return")
		  AddReservedWord("self")
		  AddReservedWord("static")
		  AddReservedWord("super")
		  AddReservedWord("then")
		  AddReservedWord("var")
		  AddReservedWord("while")
		  
		  ' Reset properties.
		  Reset(sourceToScan)
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function Identifier() As Token
		  ' Consumes an identifier and returns a token of the correct type.
		  
		  while IsAlpha(Peek()) or IsDigit(Peek())
		    Advance()
		  wend
		  
		  ' Identifiers can end with `?` or `!`
		  if Peek() = "?" or Peek() = "!" then Advance()
		  
		  ' Since identifiers can be reserved words, we need to determine the correct identifier type.
		  return MakeToken(IdentifierType())
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function IdentifierType() As TokenType
		  ' Since identifiers can also be reserved words, we need to determinet the correct token type.
		  ' NB: Reserved words/identifiers are case-sensitive.
		  
		  dim lexeme as String = source.Mid(start, current - start)
		  
		  if StrComp(lexeme, "True", 0) = 0 or StrComp(lexeme, "False", 0) = 0 then return TokenType.BOOLEAN
		  if StrComp(lexeme, "Nothing", 0) = 0 then return TokenType.NOTHING
		  
		  if StrComp(lexeme, "and", 0) = 0 then return TokenType.AND_KEYWORD
		  if StrComp(lexeme, "break", 0) = 0 then return TokenType.BREAK_KEYWORD
		  if StrComp(lexeme, "class", 0) = 0 then return TokenType.CLASS_KEYWORD
		  if StrComp(lexeme, "else", 0) = 0 then return TokenType.ELSE_KEYWORD
		  if StrComp(lexeme, "for", 0) = 0 then return TokenType.FOR_KEYWORD
		  if StrComp(lexeme, "function", 0) = 0 then return TokenType.FUNCTION_KEYWORD
		  if StrComp(lexeme, "if", 0) = 0 then return TokenType.IF_KEYWORD
		  if StrComp(lexeme, "module", 0) = 0 then return TokenType.MODULE_KEYWORD
		  if StrComp(lexeme, "not", 0) = 0 then return TokenType.NOT_KEYWORD
		  if StrComp(lexeme, "or", 0) = 0 then return TokenType.OR_KEYWORD
		  if StrComp(lexeme, "quit", 0) = 0 then return TokenType.QUIT_KEYWORD
		  if StrComp(lexeme, "return", 0) = 0 then return TokenType.RETURN_KEYWORD
		  if StrComp(lexeme, "static", 0) = 0 then return TokenType.STATIC_KEYWORD
		  if StrComp(lexeme, "self", 0) = 0 then return TokenType.SELF_KEYWORD
		  if StrComp(lexeme, "super", 0) = 0 then return TokenType.SUPER_KEYWORD
		  if StrComp(lexeme, "var", 0) = 0 then return TokenType.VAR
		  if StrComp(lexeme, "while", 0) = 0 then return TokenType.WHILE_KEYWORD
		  
		  return TokenType.IDENTIFIER
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function IsAlpha(char as String) As Boolean
		  ' Returns True if `char` is any of the following: a-z, A-Z, _
		  
		  select case Asc(char)
		  case 65 to 90, 95, 97 to 122
		    return True
		  else
		    return False
		  end select
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function IsAtEnd() As Boolean
		  ' Returns True if the scanner has reached the end of the source string.
		  
		  return if(current > sourceLength, True, False)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function IsDigit(char as String) As Boolean
		  ' Returns True if `char` is a digit.
		  
		  select case char
		  case "0", "1", "2", "3", "4", "5", "6", "7", "8", "9"
		    return True
		  else
		    return False
		  end select
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function MakeToken(type as TokenType) As Token
		  ' Returns a new token based on the current position in the source string of the requested type.
		  
		  dim token as new Token
		  token.type = type
		  token.start = start
		  token.length = current - start
		  token.finish = current - 1
		  token.lexeme = source.Mid(start, token.length)
		  token.line = line
		  
		  return token
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function Match(expected as String) As Boolean
		  ' If the next character in the source is `expected` then we consume it and return True. Otherwise we leave 
		  ' it alone and return False.
		  
		  if IsAtEnd() then return False
		  
		  if source.Mid(current, 1) = expected then
		    self.current = self.current + 1 ' Consume the character by incrementing the pointer.
		    return True
		  else
		    return False
		  end if
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function Number() As Token
		  ' Consumes a number.
		  
		  while IsDigit(Peek())
		    Advance()
		  wend
		  
		  ' Is this a double?
		  if Peek() = "." and IsDigit(PeekNext()) then
		    Advance() ' Consume the dot.
		    
		    while IsDigit(Peek())
		      Advance()
		    wend
		  end if
		  
		  ' So far we have a number (either an integer or a double). Is there a valid exponent?
		  if Peek() = "e" then
		    select case PeekNext()
		    case "-", "+"
		      Advance() ' Consume the `e`
		      Advance() ' Consume the sign character.
		      while IsDigit(Peek())
		        Advance()
		      wend
		    case "0", "1", "2", "3", "4", "5", "6", "7", "8", "9"
		      Advance() ' Consume the `e`
		      while IsDigit(Peek())
		        Advance()
		      wend
		    end select
		  end if
		  
		  return MakeToken(TokenType.NUMBER)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function Peek() As String
		  ' Returns the current character at the pointer in the source code but DOESN'T consume it.
		  ' If we've reached the end of the source code we'll return "".
		  
		  if not IsAtEnd() then return source.Mid(current, 1)
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function PeekNext() As String
		  ' Similar to Peek().
		  ' Returns the character one past the current one in the source code but DOESN'T consume it.
		  ' If we've reached the end of the source code we'll return "".
		  
		  if current + 1 > sourceLength then return ""
		  
		  return source.Mid(current + 1, 1)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Reset(sourceToScan as String)
		  ' Resets the scanner with a new source string. 
		  ' Exists to reduce construction overhead (e.g: no need to initialise constants, etc).
		  
		  self.current = 1
		  self.start = 1
		  self.line = 1
		  self.source = DefineEncoding(sourceToScan, Encodings.UTF8) ' Only UTF-8 is supported
		  self.source = StandardiseNewlines(self.source) ' Get rid of pesky Windows newlines
		  self.sourceLength = self.source.Len ' Cache for performance
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Scan() As Token()
		  ' Scans the source code and either returns an array of tokens or raises a ScannerError.
		  ' NB: If an exception occurs, it happens in ScanToken().
		  
		  dim t, tokens() as Token
		  
		  do
		    t = ScanToken()
		    tokens.Append(t)
		  loop until t.type = TokenType.EOF
		  
		  return tokens
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function ScanToken() As Token
		  ' Return the next token.
		  
		  #pragma BreakOnExceptions False
		  
		  SkipWhitespace()
		  
		  start = current
		  
		  if IsAtEnd() then return MakeToken(TokenType.EOF)
		  
		  dim c as String = Advance()
		  
		  ' Identifer?
		  if IsAlpha(c) then return Identifier()
		  
		  ' Number?
		  if IsDigit(c) then return Number()
		  
		  select case c
		    ' ---------------------------------------------------------------
		    ' Single character tokens.
		    ' ---------------------------------------------------------------
		  case "("
		    return MakeToken(TokenType.LPAREN)
		  case ")"
		    return MakeToken(TokenType.RPAREN)
		  case "{"
		    return MakeToken(TokenType.LCURLY)
		  case "}"
		    return MakeToken(TokenType.RCURLY)
		  case "["
		    return MakeToken(TokenType.LSQUARE)
		  case "]"
		    return MakeToken(TokenType.RSQUARE)
		  case ","
		    return MakeToken(TokenType.COMMA)
		  case "."
		    return MakeToken(TokenType.DOT)
		  case "!"
		    return MakeToken(TokenType.BANG)
		  case "^"
		    return MakeToken(TokenType.CARET)
		  case "?"
		    return MakeToken(TokenType.QUERY)
		  case ":"
		    return MakeToken(TokenType.COLON)
		  case ";"
		    return MakeToken(TokenType.SEMICOLON)
		    
		    ' ---------------------------------------------------------------
		    ' Single OR double character tokens.
		    ' ---------------------------------------------------------------
		  case "=" '=, ==, =>
		    if Match("=") then return MakeToken(TokenType.EQUAL_EQUAL)
		    return MakeToken(if(Match(">"), TokenType.ARROW, TokenType.EQUAL))
		  case "+" ' +=, ++, + 
		    if Match("=") then return MakeToken(TokenType.PLUS_EQUAL)
		    return MakeToken(if(Match("+"), TokenType.PLUS_PLUS, TokenType.PLUS))
		  case "-" ' -=, --, - 
		    if Match("=") then return MakeToken(TokenType.MINUS_EQUAL)
		    return MakeToken(if(Match("-"), TokenType.MINUS_MINUS, TokenType.MINUS))
		  case "*" ' *, *=
		    return MakeToken(if(Match("="), TokenType.STAR_EQUAL, TokenType.STAR))
		  case "/" ' /, /=
		    return MakeToken(if(Match("="), TokenType.SLASH_EQUAL, TokenType.SLASH))
		  case "%" ' %, /%
		    return MakeToken(if(Match("="), TokenType.PERCENT_EQUAL, TokenType.PERCENT))
		  case ">" ' >, >=
		    return MakeToken(if(Match("="), TokenType.GREATER_EQUAL, TokenType.GREATER))
		  case "<" ' <, <=, <>
		    if Match("=") then return MakeToken(TokenType.LESS_EQUAL)
		    return MakeToken(if(Match(">"), TokenType.NOT_EQUAL, TokenType.LESS))
		    
		    ' ---------------------------------------------------------------
		    ' Text.
		    ' ---------------------------------------------------------------
		  case """"
		    return TextToken(TextDelimiter.DoubleQuote)
		  case "'"
		    return TextToken(TextDelimiter.SingleQuote)
		    
		    ' ---------------------------------------------------------------
		    ' Regex?
		    ' ---------------------------------------------------------------
		  case "|"
		    dim nextOne as String
		    do
		      nextOne = Peek()
		      if nextOne = "\" and PeekNext() = "|" then ' Escaped pipe, not the end of the regex.
		        Advance()
		      elseif nextOne = "|" then
		        ' Gobble up the closing pipe.
		        Advance()
		        ' Are there any suffixing options? ('i','s','e','u','m')
		        do
		          nextOne = Peek()
		          select case nextOne
		          case "i", "s", "e", "u", "m"
		            Advance()
		          else
		            exit
		          end select
		        loop
		        return MakeToken(TokenType.REGEX)
		      elseif nextOne = "" then
		        raise new ScannerError("Missing closing regex delimiter", line, start)
		      end if
		      Advance() ' Keep consuming the contents
		    loop
		    
		  end select
		  
		  ' If we get to here we have a problem.
		  raise new ScannerError("Unexpected character (" + c + ")", line, start)
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub SkipWhitespace()
		  ' Advance the scanner past meaningless whitespace.
		  
		  dim c as String
		  
		  do
		    
		    c = Peek()
		    
		    select case c
		    case " ", &u9 ' Spaces and tabs.
		      Advance()
		      
		    case &u0A ' Newlines.
		      line = line + 1
		      Advance()
		      
		    case "#" ' Comment. These go to the end of the line.
		      while Peek() <> &u0A and not IsAtEnd()
		        Advance()
		      wend
		      if Peek() = &u0A then
		        Advance() ' Consume the newline at the end of the comment.
		        line = line + 1 ' Remember to increment the line number.
		      end if
		      
		    else
		      return
		    end select
		    
		  loop
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function StandardiseNewlines(s as String) As String
		  ' Convert all line endings in `s` to UNIX ones (i.e. LF, char dec 10/hex 000A)
		  
		  ' Replace CR-LF (&h0000D&h000A) - Windows
		  s = s.ReplaceAll(EndOfLine.Windows, &u0A)
		  
		  ' Replace CR (&h000D) - early Mac OS
		  s = s.ReplaceAll(EndOfLine.Macintosh, &u0A)
		  
		  return s
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function TextToken(delimiterType as TextDelimiter) As Token
		  dim delimiter as String = if(delimiterType = TextDelimiter.DoubleQuote, """", "'")
		  
		  while Peek() <> delimiter and not IsAtEnd()
		    if Peek() = &u0A then self.line = self.line + 1 ' Handle multiline text.
		    Advance() ' Consume the character.
		  wend
		  
		  ' Did the user terminate the text?
		  if IsAtEnd() then raise new ScannerError("Unterminated text literal", line, start)
		  
		  ' Consume the closing delimiter.
		  Advance()
		  
		  ' Create the token. We do it here rather than MakeToken() because the lexeme is handled differently.
		  dim token as new Token
		  token.type = TokenType.TEXT
		  token.start = start
		  token.length = current - start - 2 ' The lexeme won't contain the flanking delimiters.
		  token.finish = current - 1
		  token.lexeme = source.Mid(start + 1, token.length) ' Need to remove the flanking delimiters.
		  token.line = line
		  
		  return token
		End Function
	#tag EndMethod


	#tag Property, Flags = &h0
		#tag Note
			The current position in the source string.
			NB: The first character is 1
		#tag EndNote
		current As Integer = 1
	#tag EndProperty

	#tag Property, Flags = &h0
		#tag Note
			The current line of source code that the scanner is tokenising.
			NB: The first line is 1
		#tag EndNote
		line As Integer = 1
	#tag EndProperty

	#tag Property, Flags = &h0
		reserved As StringToStringHashMapMBS
	#tag EndProperty

	#tag Property, Flags = &h0
		source As String
	#tag EndProperty

	#tag Property, Flags = &h21
		Private sourceLength As Integer
	#tag EndProperty

	#tag Property, Flags = &h0
		#tag Note
			The start position of the current token in the source string.
			NB: The first character in the source string is 1
		#tag EndNote
		start As Integer = 1
	#tag EndProperty


	#tag Enum, Name = TextDelimiter, Type = Integer, Flags = &h0
		SingleQuote
		DoubleQuote
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
			Name="current"
			Group="Behavior"
			InitialValue="1"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="line"
			Group="Behavior"
			InitialValue="1"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="source"
			Group="Behavior"
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="start"
			Group="Behavior"
			InitialValue="1"
			Type="Integer"
		#tag EndViewProperty
	#tag EndViewBehavior
End Class
#tag EndClass