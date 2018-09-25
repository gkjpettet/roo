#tag Class
Protected Class Scanner
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
		Sub Constructor(sourceFile As FolderItem, doNotRequire As Xojo.Core.Dictionary = Nil)
		  ' Create a scanner to tokenise this source code file.
		  
		  ' Generic setup.
		  Initialise(doNotRequire)
		  
		  ' Get the contents of the file.
		  Dim ti As TextInputStream
		  Self.SourceFile = sourceFile
		  If sourceFile <> Nil And sourceFile.Exists And sourceFile.IsReadable Then
		    ti = TextInputStream.Open(sourceFile)
		    ti.Encoding = Encodings.UTF8
		    Self.Source = DefineEncoding(ti.ReadAll, Encodings.UTF8) ' Only UTF-8 is supported
		    ti.Close
		  End If
		  
		  ' Assign the standardised content of the file to the source property.
		  Self.Source = StandardiseNewlines(Self.Source) ' Get rid of pesky Windows newlines
		  Self.SourceLength = Self.Source.Len ' Cache for performance
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor(sourceToScan As String, doNotRequire As Xojo.Core.Dictionary = Nil)
		  Initialise(doNotRequire)
		  
		  Self.Source = DefineEncoding(sourceToScan, Encodings.UTF8) ' Only UTF-8 is supported
		  Self.Source = StandardiseNewlines(Self.Source) ' Get rid of pesky Windows newlines
		  Self.SourceLength = Self.Source.Len ' Cache for performance
		  Self.SourceFile = Nil
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub HandleRequire()
		  ' The scanner has just encountered (and consumed) a REQUIRE token.
		  
		  ' The next token must be a text literal in order for this to be a valid require statement.
		  ScanToken
		  Dim target As Roo.Token = Tokens.Pop
		  If target.type <> TokenType.TEXT Then
		    Raise New ScannerError(sourceFile, "Expected a Text literal after the `require` keyword.", _
		    line, start)
		  End If
		  
		  ' The next token must be either a newline, semicolon or the EOF for this to be a valid 
		  ' require statement.
		  If Peek = &u0A Then
		    ' Newline
		    line = line + 1
		    Advance
		  Else ' Semicolon or EOF?
		    ScanToken
		    Dim t As Roo.Token = Tokens.Pop
		    If t.type <> TokenType.SEMICOLON And t.type <> TokenType.EOF Then
		      Raise New ScannerError(sourceFile, "Expected a newline, semicolon or EOF after the require " + _
		      "statement's Text literal.", line, start)
		    End If
		  End If
		  
		  ' This is a syntactically valid require statement.
		  ' Now check that the target path is valid and, if so, do the require.
		  Require(target.Lexeme)
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
		  if StrComp(lexeme, "exit", 0) = 0 then return TokenType.EXIT_KEYWORD
		  if StrComp(lexeme, "for", 0) = 0 then return TokenType.FOR_KEYWORD
		  if StrComp(lexeme, "function", 0) = 0 then return TokenType.FUNCTION_KEYWORD
		  if StrComp(lexeme, "if", 0) = 0 then return TokenType.IF_KEYWORD
		  if StrComp(lexeme, "module", 0) = 0 then return TokenType.MODULE_KEYWORD
		  if StrComp(lexeme, "not", 0) = 0 then return TokenType.NOT_KEYWORD
		  if StrComp(lexeme, "or", 0) = 0 then return TokenType.OR_KEYWORD
		  if StrComp(lexeme, "quit", 0) = 0 then return TokenType.QUIT_KEYWORD
		  if StrComp(lexeme, "require", 0) = 0 then return TokenType.REQUIRE_KEYWORD
		  if StrComp(lexeme, "return", 0) = 0 then return TokenType.RETURN_KEYWORD
		  if StrComp(lexeme, "self", 0) = 0 then return TokenType.SELF_KEYWORD
		  if StrComp(lexeme, "static", 0) = 0 then return TokenType.STATIC_KEYWORD
		  if StrComp(lexeme, "super", 0) = 0 then return TokenType.SUPER_KEYWORD
		  if StrComp(lexeme, "var", 0) = 0 then return TokenType.VAR
		  if StrComp(lexeme, "while", 0) = 0 then return TokenType.WHILE_KEYWORD
		  
		  return TokenType.IDENTIFIER
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub Initialise(doNotRequire As Xojo.Core.Dictionary)
		  ' Common setup tasks required by the scanner regardless of whether or not it is tokenising a 
		  ' String or a file.
		  
		  ' Are there any files that do not need re-requiring?
		  If doNotRequire = Nil Then
		    Self.DoNotRequire = New Xojo.Core.Dictionary
		  Else
		    Self.DoNotRequire = doNotRequire
		  End If
		  
		  ' Initialise properties.
		  Self.Current = 1
		  Self.Start = 1
		  Self.Line = 1
		  Redim Self.Tokens(-1)
		End Sub
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
		Private Sub MagicSemicolon()
		  ' The scanner has just hit a newline or the EOF. Do we need to append a semicolon token?
		  ' Semicolons should be inserted if the last added token is one of the following:
		  ' Identifier
		  ' Literal (boolean, nothing, number, text, regex)
		  ' break
		  ' exit
		  ' quit
		  ' return
		  ' )
		  ' ]
		  
		  If Tokens.Ubound < 0 Then Return
		  
		  Select Case Tokens(Tokens.Ubound).type
		  Case TokenType.IDENTIFIER, TokenType.BOOLEAN, TokenType.NOTHING, TokenType.NUMBER, _
		    TokenType.TEXT, TokenType.REGEX, TokenType.BREAK_KEYWORD, TokenType.EXIT_KEYWORD, _
		    TokenType.QUIT_KEYWORD, TokenType.RETURN_KEYWORD, TokenType.RPAREN, TokenType.RSQUARE
		    Tokens.Append(MakeToken(TokenType.SEMICOLON))
		  End Select
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function MakeToken(type As Roo.TokenType) As Token
		  ' Returns a new token based on the current position in the source string of the requested type.
		  
		  dim token as new Token
		  token.type = type
		  token.start = start
		  token.length = current - start
		  token.finish = current - 1
		  token.lexeme = source.Mid(start, token.length)
		  token.line = line
		  token.File = sourceFile
		  
		  If token.type = TokenType.LCURLY Then
		    If Tokens.Ubound >= 0 And Tokens(Tokens.Ubound).type = TokenType.IDENTIFIER _
		      And Peek <> &u0A And source.Mid(current-2, 1) <> " " Then
		      Tokens(Tokens.Ubound).MaybeHash = True
		    End If
		  End If
		  
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

	#tag Method, Flags = &h21
		Private Sub Require(path As String)
		  ' This method is called by HandleRequire when a potentially valid `require` statement is encountered. 
		  ' It takes the path of the file to require.
		  
		  ' Valid require paths can be relative or absolute. 
		  
		  ' Removing any superfluous trailing slash.
		  If path.Right(1) = "/" Then path = path.Left(path.Len - 1)
		  
		  ' The .roo extension for the file to require is optional so we will add it if omitted.
		  If path.Right(4) <> ".roo" Then path = path + ".roo"
		  
		  ' Is `path` valid?
		  Dim requireFile As FolderItem = Roo.RooPathToFolderItem(path, Self.sourceFile)
		  If requireFile = Nil Or Not requireFile.Exists Then
		    Raise New ScannerError(sourceFile, "Invalid require path: `" + path + "`.", line, start)
		  End If
		  
		  ' Make sure requireFile is a file and not a folder.
		  If requireFile.Directory Then
		    Raise New ScannerError(sourceFile, "Invalid require path. Expected a file not a folder: " + _
		    "`" + path + "`.", line, start)
		  End If
		  
		  ' Check the file is readable.
		  If Not requireFile.IsReadable Then
		    Raise New ScannerError(sourceFile, "Unable to open the required file for reading: `" + _
		    path + "`.", line, start)
		  End If
		  
		  ' Has this file already been required? (If so, we're done).
		  If doNotRequire.HasKey(requireFile.NativePath) Then Return
		  
		  ' Record that this file has been required to prevent it be re-required within the same script.
		  doNotRequire.Value(requireFile.NativePath) = True
		  
		  ' Spin up a new scanner to tokenise the file.
		  Dim scanner As New Roo.scanner(requireFile, doNotRequire)
		  Dim requireTokens() As Token = scanner.Scan()
		  If requireTokens.Ubound >= 0 Then
		    ' Remove the EOF token if this is the last token.
		    If requireTokens(requireTokens.Ubound).type = TokenType.EOF Then Call requireTokens.Pop
		    ' Append these tokens to THIS scanner's tokens.
		    For Each t As Token In requireTokens
		      Self.tokens.Append(t)
		    Next t
		  End If
		  
		  ' Done.
		  
		End Sub
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
		  redim self.tokens(-1)
		  self.sourceFile = Nil
		  self.doNotRequire = new Xojo.Core.Dictionary
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Scan() As Token()
		  ' Scans the source code and either returns an array of tokens or raises a ScannerError.
		  ' NB: If an exception occurs, it happens in ScanToken().
		  ' NB: If a `require` statement is encountered, it is handled within the ScanToken() method but returns
		  ' a token of type TokenType.REQUIRE_KEYWORD
		  
		  Redim tokens(-1)
		  
		  Do
		    ScanToken
		  Loop Until Tokens(Tokens.Ubound).type = TokenType.EOF
		  
		  Return Tokens
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub ScanToken()
		  ' Adds the next token to the scanner's Tokens() array.
		  
		  SkipWhitespace
		  
		  start = current
		  
		  If IsAtEnd Then
		    MagicSemicolon
		    Tokens.Append(MakeToken(TokenType.EOF))
		    Return
		  End If
		  
		  Dim c As String = Advance
		  
		  ' Number?
		  If IsDigit(c) Then
		    Tokens.Append(Number)
		    Return
		  End If
		  
		  Select Case c
		    ' ---------------------------------------------------------------
		    ' Single character tokens.
		    ' ---------------------------------------------------------------
		  Case "("
		    Tokens.Append(MakeToken(TokenType.LPAREN))
		    Return
		  Case ")"
		    Tokens.Append(MakeToken(TokenType.RPAREN))
		    Return
		  Case "{"
		    Tokens.Append(MakeToken(TokenType.LCURLY))
		    Return
		  Case "}"
		    Tokens.Append(MakeToken(TokenType.RCURLY))
		    Return
		  Case "["
		    Tokens.Append(MakeToken(TokenType.LSQUARE))
		    Return
		  Case "]"
		    Tokens.Append(MakeToken(TokenType.RSQUARE))
		    Return
		  Case ","
		    Tokens.Append(MakeToken(TokenType.COMMA))
		    Return
		  Case "."
		    Tokens.Append(MakeToken(TokenType.DOT))
		    Return
		  Case "!"
		    Tokens.Append(MakeToken(TokenType.BANG))
		    Return
		  Case "^"
		    Tokens.Append(MakeToken(TokenType.CARET))
		    Return
		  Case "?"
		    Tokens.Append(MakeToken(TokenType.QUERY))
		    Return
		  Case ":"
		    Tokens.Append(MakeToken(TokenType.COLON))
		    Return
		  Case ";"
		    Tokens.Append(MakeToken(TokenType.SEMICOLON))
		    Return
		    
		    ' ---------------------------------------------------------------
		    ' Single OR double character tokens.
		    ' ---------------------------------------------------------------
		  Case "=" '=, ==, =>
		    If Match("=") Then
		      Tokens.Append(MakeToken(TokenType.EQUAL_EQUAL))
		      Return
		    End If
		    Tokens.Append(MakeToken(If(Match(">"), TokenType.ARROW, TokenType.EQUAL)))
		    Return
		  Case "+" ' +=, ++, +
		    If Match("=") Then
		      Tokens.Append(MakeToken(TokenType.PLUS_EQUAL))
		      Return
		    End If
		    Tokens.Append(MakeToken(If(Match("+"), TokenType.PLUS_PLUS, TokenType.PLUS)))
		    Return
		  Case "-" ' -=, --, -
		    If Match("=") Then
		      Tokens.Append(MakeToken(TokenType.MINUS_EQUAL))
		      Return
		    End If
		    Tokens.Append(MakeToken(If(Match("-"), TokenType.MINUS_MINUS, TokenType.MINUS)))
		    Return
		  Case "*" ' *, *=
		    If Match("=") Then
		      Tokens.Append(MakeToken(TokenType.STAR_EQUAL))
		      Return
		    Else
		      Tokens.Append(MakeToken(TokenType.STAR))
		      Return
		    End If
		  Case "/" ' /, /=
		    If Match("=") Then
		      Tokens.Append(MakeToken(TokenType.SLASH_EQUAL))
		      Return
		    Else
		      Tokens.Append(MakeToken(TokenType.SLASH))
		      Return
		    End If
		  Case "%" ' %, /%
		    If Match("=") Then
		      Tokens.Append(MakeToken(TokenType.PERCENT_EQUAL))
		      Return
		    Else
		      Tokens.Append(MakeToken(TokenType.PERCENT))
		      Return
		    End If
		  Case ">" ' >, >=
		    If Match("=") Then
		      Tokens.Append(MakeToken(TokenType.GREATER_EQUAL))
		      Return
		    Else
		      Tokens.Append(MakeToken(TokenType.GREATER))
		      Return
		    End If
		  Case "<" ' <, <=, <>
		    If Match("=") Then
		      Tokens.Append(MakeToken(TokenType.LESS_EQUAL))
		      Return
		    ElseIf Match(">") Then
		      Tokens.Append(MakeToken(TokenType.NOT_EQUAL))
		      Return
		    Else
		      Tokens.Append(MakeToken(TokenType.LESS))
		      Return
		    End If
		    
		    ' ---------------------------------------------------------------
		    ' Text.
		    ' ---------------------------------------------------------------
		  Case """"
		    Tokens.Append(TextToken(TextDelimiter.DoubleQuote))
		    Return
		  Case "'"
		    Tokens.Append(TextToken(TextDelimiter.SingleQuote))
		    Return
		    
		    ' ---------------------------------------------------------------
		    ' Regex?
		    ' ---------------------------------------------------------------
		  Case "|"
		    Dim nextOne As String
		    Do
		      nextOne = Peek
		      If nextOne = "\" And PeekNext = "|" Then ' Escaped pipe, not the end of the regex.
		        Advance
		      ElseIf nextOne = "|" Then
		        ' Gobble up the closing pipe.
		        Advance
		        ' Are there any suffixing options? ('i','s','e','u','m')
		        Do
		          nextOne = Peek
		          Select Case nextOne
		          Case "i", "s", "e", "u", "m"
		            Advance
		          Else
		            Exit
		          End Select
		        Loop
		        Tokens.Append(MakeToken(TokenType.REGEX))
		        Return
		      ElseIf nextOne = "" Then
		        Raise New ScannerError(sourceFile, "Missing closing regex delimiter", line, start)
		      End If
		      Advance ' Keep consuming the contents
		    Loop
		    
		  End Select
		  
		  ' Identifier?
		  If IsAlpha(c) Then
		    Dim tok As Roo.Token = Identifier
		    If tok.type = TokenType.REQUIRE_KEYWORD Then
		      HandleRequire
		      Return
		    Else
		      Tokens.Append(tok)
		      Return
		    End If
		  End If
		  
		  ' If we get to here we have a problem.
		  Raise New ScannerError(sourceFile, "Unexpected character (" + c + ")", line, start)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub SkipWhitespace()
		  ' Advance the scanner past meaningless whitespace.
		  ' If we encounter a newline, we may need to insert a semicolon token.
		  
		  Dim c As String
		  
		  Do
		    
		    c = Peek
		    
		    Select Case c
		    Case " ", &u9 ' Spaces and tabs.
		      Advance
		      
		    Case &u0A ' Newlines.
		      line = line + 1
		      MagicSemicolon
		      Advance
		      
		    Case "#" ' Comment. These go to the end of the line.
		      While Peek <> &u0A And Not IsAtEnd
		        Advance
		      Wend
		      If Peek = &u0A Then
		        line = line + 1 ' Remember to increment the line number.
		        MagicSemicolon
		        Advance ' Consume the newline at the end of the comment.
		      End If
		      
		    Else
		      Return
		    End Select
		    
		  Loop
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
		  if IsAtEnd() then raise new ScannerError(sourceFile, "Unterminated text literal", line, start)
		  
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
		  token.File = sourceFile
		  
		  return token
		End Function
	#tag EndMethod


	#tag Property, Flags = &h0
		#tag Note
			The current position in the source string.
			NB: The first character is 1
		#tag EndNote
		Current As Integer = 1
	#tag EndProperty

	#tag Property, Flags = &h21
		#tag Note
			Stores files that do not need to be required again as they have previously been required
			already by the script.
			
			Key = Native path of the file
			Value = True
		#tag EndNote
		Private DoNotRequire As Xojo.Core.Dictionary
	#tag EndProperty

	#tag Property, Flags = &h0
		#tag Note
			The current line of source code that the scanner is tokenising.
			NB: The first line is 1
		#tag EndNote
		Line As Integer = 1
	#tag EndProperty

	#tag Property, Flags = &h0
		Source As String
	#tag EndProperty

	#tag Property, Flags = &h0
		#tag Note
			If the scanner is parsing source from a file then this FolderItem keeps a reference to that file.
			Used to report the file that a token or error occurs within.
		#tag EndNote
		SourceFile As FolderItem
	#tag EndProperty

	#tag Property, Flags = &h21
		Private SourceLength As Integer
	#tag EndProperty

	#tag Property, Flags = &h0
		#tag Note
			The start position of the current token in the source string.
			NB: The first character in the source string is 1
		#tag EndNote
		Start As Integer = 1
	#tag EndProperty

	#tag Property, Flags = &h0
		Tokens() As Roo.Token
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
			Name="Current"
			Group="Behavior"
			InitialValue="1"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Line"
			Group="Behavior"
			InitialValue="1"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Source"
			Group="Behavior"
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Start"
			Group="Behavior"
			InitialValue="1"
			Type="Integer"
		#tag EndViewProperty
	#tag EndViewBehavior
End Class
#tag EndClass
