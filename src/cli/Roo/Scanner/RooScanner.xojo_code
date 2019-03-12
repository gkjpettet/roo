#tag Class
Protected Class RooScanner
	#tag Method, Flags = &h21
		Private Sub AddDedentToken()
		  // Adds a new DEDENT token.
		  
		  Dim token As New RooToken
		  token.Type = Roo.TokenType.DEDENT
		  token.Start = Start - 1
		  token.Length = 1
		  token.Finish = Current - 1
		  token.Lexeme = "Dedent"
		  token.Line = Line
		  token.File = SourceFile
		  
		  Tokens.Append(token)
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub AddEOFToken()
		  // Adds the EOF token.
		  // To handle several edge cases, it's best to ensure that there is always a TERMINATOR token 
		  // before the EOF token. This catches issues such as an expression statement at the 
		  // end of a file.
		  AddTerminatorToken
		  
		  Dim token As New RooToken
		  token.Type = Roo.TokenType.EOF
		  token.Start = Start - 1
		  token.Length = 1
		  token.Finish = Current - 1
		  token.Lexeme = "EOF"
		  token.Line = Line
		  token.File = SourceFile
		  
		  Tokens.Append(token)
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub AddIndentToken()
		  // Adds a new INDENT token.
		  
		  Dim token As New RooToken
		  token.Type = Roo.TokenType.INDENT
		  token.Start = Start - 1
		  token.Length = 1
		  token.Finish = Current - 1
		  token.Lexeme = "Indent"
		  token.Line = Line
		  token.File = SourceFile
		  
		  Tokens.Append(token)
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub AddTerminatorToken()
		  // Add a new TERMINATOR token if required.
		  
		  // There is no point having consecutive TERMINATOR tokens as they just marke statement 
		  // boundaries or function as no-ops.
		  // Don't add a TERMINATOR token if the preceding token is another TERMINATOR token, 
		  // a colon, indent or dedent token.
		  If Tokens.Ubound >= 0 Then
		    Select Case Tokens(Tokens.Ubound).Type
		    Case Roo.TokenType.TERMINATOR, Roo.TokenType.COLON, _
		      Roo.TokenType.INDENT, Roo.TokenType.DEDENT
		      Return
		    End Select
		  End If
		  
		  Dim token As New RooToken
		  token.Type = Roo.TokenType.TERMINATOR
		  token.Start = Start - 1
		  token.Length = 1
		  token.Finish = Current - 1
		  token.Lexeme = "Terminator"
		  token.Line = Line
		  token.File = SourceFile
		  
		  Tokens.Append(token)
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub AddToken(type As Roo.TokenType)
		  // Adds a new token of the specified type based on the current position in the source.
		  
		  Tokens.Append(MakeToken(type))
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub Advance()
		  // Consumes (without returning) the current character in the source.
		  
		  AtLogicalLineStart = False
		  Current = Current + 1
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function Advance() As String
		  // Consumes and returns the current character in the source.
		  
		  AtLogicalLineStart = False
		  Current = Current + 1
		  Return Source.Mid(Current - 1, 1)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor(sourceFile As FolderItem, doNotRequire As Dictionary = Nil, requireRoot As FolderItem = Nil)
		  // Construct a new lexer from the passed source file.
		  // Takes an optional dictionary which specifies the paths of 
		  // any files that have already been required by this scrip and 
		  // need not be required again.
		  // May raise an IOException if the passed source file is not valid.
		  
		  // Get the contents of the file.
		  Dim s As String
		  Dim tin As TextInputStream
		  Try
		    tin = TextInputStream.Open(sourceFile)
		    s = tin.ReadAll
		    tin.Close
		  End Try
		  
		  Initialise(s, sourceFile, doNotRequire, requireRoot)
		  
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor(source As String, doNotRequire As Dictionary = Nil, requireRoot As FolderItem = Nil)
		  // Construct a new lexer from the passed source code.
		  // Takes an optional dictionary which specifies the paths of 
		  // any files that have already been required by this scrip and 
		  // need not be required again.
		  
		  Initialise(source, Nil, doNotRequire, requireRoot)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function EndOfLogicalLine() As Boolean
		  // This method is called when the scanner encounters a newline character.
		  // Roo considers there to be two types of line: physical and logical.
		  // Physical lines are visibly distinct lines we can see in source code. They are never more 
		  // than one line long.
		  // Logical lines can span multiple physical lines of source code. An example would be the following 
		  // Array literal definition:
		  ' var h = {
		  '   "name" => "Garry"
		  '   "age" => 37
		  ' }
		  // Roo considers the above example to be a single logical line because at the time it encounters 
		  // the newline character there is an unmatched curly brace.
		  
		  If mUnclosedCurlyCount > 0 Or mUnclosedParenCount > 0 Or mUnclosedSquareCount > 0 Then
		    Return False
		  Else
		    Return True
		  End If
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub HandleIndentation()
		  // This method is called when the scanner has just moved to the beginning of a new logical line.
		  // We need to check if we need to create any INDENT or DEDENT tokens.
		  
		  // Ignore this line if it is empty.
		  mPeekChar = Peek
		  If mPeekChar = &u0A Or mPeekChar = "" Then Return
		  
		  Dim lineLevel As Integer = 0
		  Dim currentLevel As Integer = IndentationStack(IndentationStack.Ubound)
		  
		  // How many levels of indentation is this line?
		  While Peek = &u09
		    lineLevel = lineLevel + 1
		    Advance
		  Wend
		  
		  // Has the indentation level stayed the same?
		  If lineLevel = currentLevel Then Return
		  
		  // Are we at a greater indentation level than the line above?
		  If lineLevel > currentLevel Then
		    IndentationStack.Append(lineLevel)
		    AddIndentToken
		    Return
		  End If
		  
		  // We have dedented.
		  // This line's indentation level MUST be the same as one of the others on the stack.
		  If IndentationStack.IndexOf(lineLevel) = -1 Then
		    Raise New RooScannerError(SourceFile, "Unmatched indentation", Line, Start)
		  End If
		  // All numbers on the stack that are larger than this line's level are popped off 
		  // and for each number popped off a DEDENT token is generated.
		  While lineLevel < IndentationStack(IndentationStack.Ubound)
		    AddDedentToken
		    Call IndentationStack.Pop
		  Wend
		  
		  // Flag that we're no longer at the start of a logical line.
		  AtLogicalLineStart = False
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub HandleRequire()
		  // The scanner has just encountered (and consumed) a REQUIRE token.
		  
		  // The next token must be a text literal in order for this to be a valid require statement.
		  ScanToken
		  Dim pathToken As RooToken = Tokens.Pop
		  If pathToken.Type <> Roo.TokenType.TEXT Then
		    Raise New RooScannerError(SourceFile, "Expected a Text literal after the `require` keyword.", _
		    Line, Start)
		  End If
		  
		  // The next token must be either a newline or the EOF.
		  If Peek = &u0A Then // It's a newline.
		    Line = Line + 1
		    Advance
		  Else // EOF?
		    ScanToken
		    Dim t As RooToken = Tokens.Pop
		    If t.Type <> Roo.TokenType.EOF Then
		      Raise New RooScannerError(SourceFile, "Expected a newline or EOF after the `require` " + _
		      "statement's Text literal.", Line, Start)
		    End If
		  End If
		  
		  // This is a syntactically valid require statement.
		  // Now check that the target path is valid and, if so, do the require.
		  Require(pathToken.Lexeme)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function Identifier() As RooToken
		  #Pragma BreakOnExceptions False
		  
		  // Consumes an identifier and returns a token of the correct type.
		  
		  Do
		    // Get the next character.
		    mPeekChar = Peek
		    
		    // Get its ASCII value/codepoint.
		    mCodePoint = Asc(mPeekChar)
		    
		    // NB: We are limiting ourselves to traditional ASCII character values.
		    Select Case mCodePoint
		    Case 48 To 57, 65 To 90, 95, 97 To 122 // a-z, A-Z, 0-9, _
		      Advance
		    Else
		      Exit
		    End Select
		  Loop
		  
		  // Identifiers can end with `?` or `!`
		  Select Case Peek
		  Case "?", "!"
		    Advance
		  End Select
		  
		  // Since identifiers can be reserved words, we need to determine 
		  // the correct identifier type.
		  Return MakeToken(IdentifierType)
		  
		  Exception err As OutOfBoundsException
		    // This happens when we call Source.Mid and we're at the end of the source code.
		    Return MakeToken(IdentifierType)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function IdentifierType() As Roo.TokenType
		  // Since identifiers can also be reserved words, we need to determine the 
		  // correct token type.
		  // NB: Reserved words/identifiers are case sensitive.
		  //                                         ---------
		  
		  Dim lexeme As String = Source.Mid(Start, Current - Start)
		  
		  // Types.
		  If StrComp(lexeme, "True", 0) = 0 Then
		    Return Roo.TokenType.BOOLEAN
		  ElseIf StrComp(lexeme, "False", 0) = 0 Then
		    Return Roo.TokenType.BOOLEAN
		  ElseIf StrComp(lexeme, "Nothing", 0) = 0 Then
		    Return Roo.TokenType.NOTHING
		  End If
		  
		  // Keywords.
		  If StrComp(lexeme, "and", 0) = 0 Then
		    Return Roo.TokenType.AND_KEYWORD
		  ElseIf StrComp(lexeme, "break", 0) = 0 Then
		    Return Roo.TokenType.BREAK_KEYWORD
		  ElseIf StrComp(lexeme, "class", 0) = 0 Then
		    Return Roo.TokenType.CLASS_KEYWORD
		  ElseIf StrComp(lexeme, "def", 0) = 0 Then
		    Return Roo.TokenType.DEF_KEYWORD
		  ElseIf StrComp(lexeme, "else", 0) = 0 Then
		    Return Roo.TokenType.ELSE_KEYWORD
		  ElseIf StrComp(lexeme, "exit", 0) = 0 Then
		    Return Roo.TokenType.EXIT_KEYWORD
		  ElseIf StrComp(lexeme, "for", 0) = 0 Then
		    Return Roo.TokenType.FOR_KEYWORD
		  ElseIf StrComp(lexeme, "if", 0) = 0 Then
		    Return Roo.TokenType.IF_KEYWORD
		  ElseIf StrComp(lexeme, "module", 0) = 0 Then
		    Return Roo.TokenType.MODULE_KEYWORD
		  ElseIf StrComp(lexeme, "not", 0) = 0 Then
		    Return Roo.TokenType.NOT_KEYWORD
		  ElseIf StrComp(lexeme, "or", 0) = 0 Then
		    Return Roo.TokenType.OR_KEYWORD
		  ElseIf StrComp(lexeme, "pass", 0) = 0 Then
		    Return Roo.TokenType.PASS_KEYWORD
		  ElseIf StrComp(lexeme, "quit", 0) = 0 Then
		    Return Roo.TokenType.QUIT_KEYWORD
		  ElseIf StrComp(lexeme, "require", 0) = 0 Then
		    Return Roo.TokenType.REQUIRE_KEYWORD
		  ElseIf StrComp(lexeme, "return", 0) = 0 Then
		    Return Roo.TokenType.RETURN_KEYWORD
		  ElseIf StrComp(lexeme, "self", 0) = 0 Then
		    Return Roo.TokenType.SELF_KEYWORD
		  ElseIf StrComp(lexeme, "static", 0) = 0 Then
		    Return Roo.TokenType.STATIC_KEYWORD
		  ElseIf StrComp(lexeme, "super", 0) = 0 Then
		    Return Roo.TokenType.SUPER_KEYWORD
		  ElseIf StrComp(lexeme, "var", 0) = 0 Then
		    Return Roo.TokenType.VAR
		  ElseIf StrComp(lexeme, "while", 0) = 0 Then
		    Return Roo.TokenType.WHILE_KEYWORD
		  Else
		    Return Roo.TokenType.IDENTIFIER
		  End If
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub Initialise(source As String, sourceFile As FolderItem, doNotRequire As Dictionary, requireRoot As FolderItem = Nil)
		  // Common setup tasks required by the scanner regardless of whether or not 
		  // it's tokenising source code or a file.
		  
		  If requireRoot = Nil Then
		    // Default to the root drive or volume that this application is running on.
		    Dim f As FolderItem = App.ExecutableFile.Parent
		    Do
		      If f.Parent = Nil Or Not f.Parent.Exists Then Exit
		      f = f.Parent
		    Loop
		    Self.RequireRoot = f
		  Else
		    Self.RequireRoot = requireRoot
		  End If
		  
		  // Are there any files that do not need re-requiring?
		  If doNotRequire = Nil Then
		    Self.DoNotRequire = New Dictionary
		  Else
		    Self.DoNotRequire = doNotRequire
		  End If
		  
		  // Setup the AlphaCharacter dictionary.
		  InitialiseAlphaCharactersDictionary
		  
		  // Assign properties.
		  Self.Source = StandardiseLineEndings(source)
		  Self.SourceLength = Self.Source.Len
		  Self.SourceFile = sourceFile
		  
		  // Reset.
		  Reset
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub InitialiseAlphaCharactersDictionary()
		  // This dictionary acts as a fast lookup table for determining 
		  // if a character is A-Z, a-z or _
		  // We will use a case-sensitive dictionary.
		  
		  AlphaCharacters = Roo.CaseSensitiveDictionary
		  
		  AlphaCharacters.Value("a") = 0
		  AlphaCharacters.Value("b") = 0
		  AlphaCharacters.Value("c") = 0
		  AlphaCharacters.Value("d") = 0
		  AlphaCharacters.Value("e") = 0
		  AlphaCharacters.Value("f") = 0
		  AlphaCharacters.Value("g") = 0
		  AlphaCharacters.Value("h") = 0
		  AlphaCharacters.Value("i") = 0
		  AlphaCharacters.Value("j") = 0
		  AlphaCharacters.Value("k") = 0
		  AlphaCharacters.Value("l") = 0
		  AlphaCharacters.Value("m") = 0
		  AlphaCharacters.Value("n") = 0
		  AlphaCharacters.Value("o") = 0
		  AlphaCharacters.Value("p") = 0
		  AlphaCharacters.Value("q") = 0
		  AlphaCharacters.Value("r") = 0
		  AlphaCharacters.Value("s") = 0
		  AlphaCharacters.Value("t") = 0
		  AlphaCharacters.Value("u") = 0
		  AlphaCharacters.Value("v") = 0
		  AlphaCharacters.Value("w") = 0
		  AlphaCharacters.Value("x") = 0
		  AlphaCharacters.Value("y") = 0
		  AlphaCharacters.Value("z") = 0
		  AlphaCharacters.Value("A") = 0
		  AlphaCharacters.Value("B") = 0
		  AlphaCharacters.Value("C") = 0
		  AlphaCharacters.Value("D") = 0
		  AlphaCharacters.Value("E") = 0
		  AlphaCharacters.Value("F") = 0
		  AlphaCharacters.Value("G") = 0
		  AlphaCharacters.Value("H") = 0
		  AlphaCharacters.Value("I") = 0
		  AlphaCharacters.Value("J") = 0
		  AlphaCharacters.Value("K") = 0
		  AlphaCharacters.Value("L") = 0
		  AlphaCharacters.Value("M") = 0
		  AlphaCharacters.Value("N") = 0
		  AlphaCharacters.Value("O") = 0
		  AlphaCharacters.Value("P") = 0
		  AlphaCharacters.Value("Q") = 0
		  AlphaCharacters.Value("R") = 0
		  AlphaCharacters.Value("S") = 0
		  AlphaCharacters.Value("T") = 0
		  AlphaCharacters.Value("U") = 0
		  AlphaCharacters.Value("V") = 0
		  AlphaCharacters.Value("W") = 0
		  AlphaCharacters.Value("X") = 0
		  AlphaCharacters.Value("Y") = 0
		  AlphaCharacters.Value("Z") = 0
		  AlphaCharacters.Value("_") = 0
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function IsAlpha(char As String) As Boolean
		  ' Returns True if `char` is any of the following: a-z, A-Z, _
		  
		  Return AlphaCharacters.HasKey(char)
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function IsBinary(char As String) As Boolean
		  // Returns True if `char` is 0 or 1.
		  
		  Select Case char
		  Case "0", "1"
		    Return True
		  Else
		    Return False
		  End Select
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function IsDigit(char As String) As Boolean
		  // Returns True if `char` is a digit.
		  
		  Select Case char
		  Case "0", "1", "2", "3", "4", "5", "6", "7", "8", "9"
		    Return True
		  Else
		    Return False
		  End Select
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function IsHexadecimal(char As String) As Boolean
		  // Returns True if `char` is a hexadecimal digit.
		  // Case-insensitive.
		  
		  Select Case char
		  Case "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "A", "B", "C", "D", "E", "F"
		    Return True
		  Else
		    Return False
		  End Select
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function IsOctal(char As String) As Boolean
		  // Returns True if `char` is an octal numeral.
		  
		  Select Case char
		  Case "0", "1", "2", "3", "4", "5", "6", "7"
		    Return True
		  Else
		    Return False
		  End Select
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function MakeNumberToken(base As RooToken.BaseType) As RooToken
		  // Returns a new number token of the specified base based on the current position 
		  // in the source.
		  
		  Dim token As New RooToken
		  token.Type = Roo.TokenType.NUMBER
		  token.Base = base
		  token.Start = Start - 1
		  token.Length = Current - Start
		  token.Finish = Current - 2
		  token.Lexeme = Source.Mid(Start, token.Length)
		  token.Line = Line
		  token.File = SourceFile
		  
		  Return token
		  
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function MakeToken(type As Roo.TokenType) As RooToken
		  // Returns a new token of the specified type based on the current position 
		  // in the source.
		  
		  Dim token As New RooToken
		  token.Type = type
		  token.Start = Start - 1
		  token.Length = Current - Start
		  token.Finish = Current - 2
		  token.Lexeme = Source.Mid(Start, token.Length)
		  token.Line = Line
		  token.File = SourceFile
		  
		  Return token
		  
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function Match(expected As Text) As Boolean
		  // If the next character in the source is `expected` then we consume it 
		  // and return True. Otherwise we leave it alone and return False.
		  
		  If Current > SourceLength Then Return False
		  
		  If source.Mid(Current, 1) = expected Then
		    Advance // Consume the character by incrementing the pointer.
		    Return True
		  Else
		    Return False
		  End If
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function Number() As RooToken
		  // Consumes a number.
		  
		  While IsDigit(Peek)
		    Advance
		  Wend
		  
		  // Is this a Double?
		  If Peek = "." And IsDigit(PeekNext) Then
		    Advance // Advance to consume the dot.
		    
		    While IsDigit(Peek)
		      Advance
		    Wend
		  End If
		  
		  // So far we have a number (either an integer or a double). Is there a valid exponent?
		  If Peek = "e" Then
		    Select Case PeekNext
		    Case "-", "+"
		      // Advance twice to consume the `e` and sign character.
		      Advance
		      Advance
		      While IsDigit(Peek)
		        Advance
		      Wend
		    Case "0", "1", "2", "3", "4", "5", "6", "7", "8", "9"
		      Advance // Advance to consume the `e`.
		      While IsDigit(Peek)
		        Advance
		      Wend
		    End Select
		  End If
		  
		  Return MakeNumberToken(RooToken.BaseType.Decimal)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function Peek() As String
		  // Returns the current character at the pointer in the source code but DOESN'T consume it.
		  // If we've reached the end of the source code we'll return "".
		  
		  If Current <= SourceLength Then Return Source.Mid(Current, 1)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function PeekNext() As String
		  // Similar to Peek.
		  // Returns the character one past the current one in the source code 
		  // but DOESN'T consume it. If we've reached the end of the source 
		  // code we'll return "".
		  
		  If current + 1 > SourceLength Then
		    Return ""
		  Else
		    Return source.Mid(Current + 1, 1)
		  End If
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function PrefixedNumber(base As RooToken.BaseType) As RooToken
		  // Consumes a 0x-prefixed number.
		  // Acceptable formats:
		  // 0b (binary), 0o (octal), ox (hexadecimal).
		  
		  Select Case base
		  Case RooToken.BaseType.Hexadecimal
		    While IsHexadecimal(Peek)
		      Advance
		    Wend
		    Return MakeNumberToken(RooToken.BaseType.Hexadecimal)
		  Case RooToken.BaseType.Binary
		    While IsBinary(Peek)
		      Advance
		    Wend
		    Return MakeNumberToken(RooToken.BaseType.Binary)
		  Case RooToken.BaseType.Octal
		    While IsOctal(Peek)
		      Advance
		    Wend
		    Return MakeNumberToken(RooToken.BaseType.Octal)
		  End Select
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub Require(path As String)
		  // This method is called by HandleRequire when a potentially valid `require` statement is 
		  // encountered. It takes the path of the file to require.
		  // Valid require paths can be relative or absolute. 
		  
		  // Removing any superfluous trailing slash.
		  If path.Right(1) = "/" Then path = path.Left(path.Len - 1)
		  
		  // The .roo extension for the file to require is optional but necessary for later so 
		  // we will add it if omitted.
		  If path.Right(4) <> ".roo" Then path = path + ".roo"
		  
		  // Is `path` valid?
		  // Attempt to convert the Roo path to a Xojo FolderItem.
		  Dim fileToRequire As FolderItem = RooPathToFolderItem(path, Self.SourceFile)
		  If fileToRequire = Nil Or fileToRequire.Exists = False Then
		    Raise New RooScannerError(SourceFile, "Invalid require path: `" + path + "`.", Line, Start)
		  End If
		  
		  // Make sure `fileToRequire` is a file and not a folder.
		  If fileToRequire.Directory Then
		    Raise New RooScannerError(SourceFile, "Invalid require path. Expected a file not a folder: " + _
		    "`" + path + "`.", Line, Start)
		  End If
		  
		  // Check that the file is readable.
		  If fileToRequire.IsReadable = False Then
		    Raise New RooScannerError(SourceFile, "Unable to open the required file for reading: `" + _
		    path + "`.", Line, Start)
		  End If
		  
		  // Has this file already been required? (If so, we're done).
		  If doNotRequire.HasKey(fileToRequire.NativePath) Then Return
		  
		  // Record that this file has been required to prevent it be re-required within the same script.
		  doNotRequire.Value(fileToRequire.NativePath) = True
		  
		  // Spin up a new scanner to tokenise the file.
		  Dim scanner As New RooScanner(fileToRequire, doNotRequire, mRequireRoot)
		  Dim requireTokens() As RooToken = scanner.Scan
		  If requireTokens.Ubound >= 0 Then
		    // Remove the EOF token if this is the last token.
		    If requireTokens(requireTokens.Ubound).Type = Roo.TokenType.EOF Then Call requireTokens.Pop
		    // Append these tokens to THIS scanner's tokens.
		    For Each t As RooToken In requireTokens
		      Self.Tokens.Append(t)
		    Next t
		  End If
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Reset()
		  Current = 1
		  Start = 1
		  Line = 1
		  Redim Tokens(-1)
		  mUnclosedCurlyCount = 0
		  mUnclosedParenCount = 0
		  mUnclosedSquareCount = 0
		  AtLogicalLineStart = True
		  Redim IndentationStack(-1)
		  IndentationStack.Append(0)
		  
		  mPeekChar = ""
		  mCodePoint = 0
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function RooPathToFolderItem(path As String, baseFile As FolderItem) As FolderItem
		  // Takes a Roo file path and returns it as a FolderItem or Nil if it's not possible to derive one.
		  // File paths in Roo are separated by forward slashes.
		  // `../` moves up the hierarchy to the parent.
		  // If a path starts with a `/` it is absolute, otherwise it is taken to be relative to `baseFile`.
		  
		  // An empty path refers to the base file.
		  If path = "" Then Return baseFile
		  
		  // Is this an absolute path? If so it will begin with `/`.
		  Dim absolute As Boolean = False
		  If path.Left(1) = "/" Then
		    absolute = True
		    path = path.Right(path.Len - 1)
		  End If
		  
		  // Split the path into it's constituent parts.
		  Dim chars() As String = path.Split("")
		  Dim char, part, parts() As String
		  For Each char In chars
		    If char = "/" Then
		      parts.Append(part)
		      part = ""
		    Else
		      part = part + char
		    End if
		  Next char
		  If char <> "/" Then parts.Append(part)
		  
		  Dim result As FolderItem
		  
		  // Handle absolute paths.
		  If absolute Then
		    result = New FolderItem(mRequireRoot.NativePath, FolderItem.PathTypeNative)
		    For Each part In parts
		      If part = ".." Then
		        result = result.Parent
		      Else
		        result = result.Child(part)
		      End If
		    Next part
		    Return result
		  End If
		  
		  // Handle relative paths.
		  If baseFile = Nil Then
		    result = mRequireRoot
		  ElseIf Not baseFile.Directory Then // Use this file's parent folder as our starting point.
		    result = New FolderItem(baseFile.Parent.NativePath, FolderItem.PathTypeNative)
		  Else
		    result = New FolderItem(baseFile.NativePath, FolderItem.PathTypeNative)
		  End If
		  For Each part In parts
		    If part = ".." Then
		      result = result.Parent
		    Else
		      result = result.Child(part)
		    End If
		  Next part
		  
		  Return result
		  
		  Exception err
		    Return Nil
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Scan() As RooToken()
		  // Scans the source code and either returns an array of tokens or raises a ScannerError.
		  // NB: If an exception occurs, it will happen in ScanToken().
		  // If an error occurs then we return an empty array.
		  // NB: If a `require` statement is encountered, it is handled within the ScanToken() method 
		  // but returns a token of type TokenType.REQUIRE_KEYWORD
		  
		  Redim Tokens(-1)
		  
		  Do
		    ScanToken
		  Loop Until Tokens(Tokens.Ubound).Type = Roo.TokenType.EOF
		  
		  // Make sure that we close any open blocks by adding in any required DEDENT tokens.
		  If IndentationStack.Ubound > 0 Then
		    // Pop off the EOF token.
		    Dim eofToken As RooToken = Tokens.Pop
		    // At the end of the file, add any required DEDENT tokens.
		    While 0 < IndentationStack(IndentationStack.Ubound)
		      AddDedentToken
		      Call IndentationStack.Pop
		    Wend
		    // Add back the EOF token.
		    Tokens.Append(eofToken)
		  End If
		  
		  Return Tokens
		  
		  // If an exception occurs we fire the scanner's custom Error event.
		  Exception err As RooScannerError
		    Error(err.File, err.Message, err.Line, err.Position)
		    Redim Tokens(-1)
		    Return Tokens
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub ScanToken()
		  // Adds the next token to the scanner's Tokens() array.
		  
		  SkipWhitespace
		  
		  Start = Current
		  
		  // Finished?
		  If Current > SourceLength Then
		    AddEOFToken
		    Return
		  End If
		  
		  // Get the next character.
		  Dim c As String = Advance
		  
		  // Is this a 0base-prefixed number?
		  If c = "0" Then
		    Dim base As String = Peek
		    If base = "x" Or base = "b" Or base = "o" Then
		      // Consume the base.
		      Advance
		      Select Case base
		      Case "x"
		        Tokens.Append(PrefixedNumber(RooToken.BaseType.Hexadecimal))
		      Case "b"
		        Tokens.Append(PrefixedNumber(RooToken.BaseType.Binary))
		      Case "o"
		        Tokens.Append(PrefixedNumber(RooToken.BaseType.Octal))
		      End Select
		      Return
		    End If
		  End If
		  
		  // Is the character a number?
		  If IsDigit(c) Then
		    Tokens.Append(Number)
		    Return
		  End If
		  
		  // Not a number.
		  Select Case c
		    // ---------------------------------------------------------------
		    // Single character tokens.
		    // ---------------------------------------------------------------
		  Case "("
		    AddToken(Roo.TokenType.LPAREN)
		    mUnclosedParenCount = mUnclosedParenCount + 1
		    Return
		  Case ")"
		    AddToken(Roo.TokenType.RPAREN)
		    mUnclosedParenCount = mUnclosedParenCount - 1
		    If mUnclosedParenCount < 0 Then
		      Raise New RooScannerError(SourceFile, "Unmatched closing parenthesis encountered", Line, Start)
		    End If
		    Return
		  Case "{"
		    AddToken(Roo.TokenType.LCURLY)
		    mUnclosedCurlyCount = mUnclosedCurlyCount + 1
		    Return
		  Case "}"
		    AddToken(Roo.TokenType.RCURLY)
		    mUnclosedCurlyCount = mUnclosedCurlyCount - 1
		    If mUnclosedCurlyCount < 0 Then
		      Raise New RooScannerError(SourceFile, "Unmatched closing curly brace encountered", Line, Start)
		    End If
		    Return
		  Case "["
		    AddToken(Roo.TokenType.LSQUARE)
		    mUnclosedSquareCount = mUnclosedSquareCount + 1
		    Return
		  Case "]"
		    AddToken(Roo.TokenType.RSQUARE)
		    mUnclosedSquareCount = mUnclosedSquareCount - 1
		    If mUnclosedSquareCount < 0 Then
		      Raise New RooScannerError(SourceFile, "Unmatched closing square bracket encountered", Line, Start)
		    End If
		    Return
		  Case ","
		    AddToken(Roo.TokenType.COMMA)
		    Return
		  Case "."
		    AddToken(Roo.TokenType.DOT)
		    Return
		  Case "|"
		    AddToken(Roo.TokenType.PIPE)
		    Return
		  Case "&"
		    AddToken(Roo.TokenType.AMPERSAND)
		    Return
		  Case "~"
		    AddToken(Roo.TokenType.TILDE)
		    Return
		  Case "!"
		    AddToken(Roo.TokenType.BANG)
		    Return
		  Case "^"
		    AddToken(Roo.TokenType.CARET)
		    Return
		  Case "?"
		    AddToken(Roo.TokenType.QUERY)
		    Return
		  Case ":"
		    AddToken(Roo.TokenType.COLON)
		    Return
		  Case ";"
		    AddToken(Roo.TokenType.TERMINATOR)
		    Return
		    
		    // ---------------------------------------------------------------
		    // Single OR double character tokens.
		    // ---------------------------------------------------------------
		  Case "=" // =, ==, =>
		    If Match("=") Then
		      AddToken(Roo.TokenType.EQUAL_EQUAL)
		      Return
		    End If
		    AddToken(If(Match(">"), Roo.TokenType.ARROW, Roo.TokenType.EQUAL))
		    Return
		  Case "+" ' +=, ++, +
		    If Match("=") Then
		      AddToken(Roo.TokenType.PLUS_EQUAL)
		      Return
		    End If
		    AddToken(If(Match("+"), Roo.TokenType.PLUS_PLUS, Roo.TokenType.PLUS))
		    Return
		  Case "-" ' -=, --, -
		    If Match("=") Then
		      AddToken(Roo.TokenType.MINUS_EQUAL)
		      Return
		    End If
		    AddToken(If(Match("-"), Roo.TokenType.MINUS_MINUS, Roo.TokenType.MINUS))
		    Return
		  Case "*" ' *, *=
		    If Match("=") Then
		      AddToken(Roo.TokenType.STAR_EQUAL)
		      Return
		    Else
		      AddToken(Roo.TokenType.STAR)
		      Return
		    End If
		  Case "/" ' /, /=
		    If Match("=") Then
		      AddToken(Roo.TokenType.SLASH_EQUAL)
		      Return
		    Else
		      AddToken(Roo.TokenType.SLASH)
		      Return
		    End If
		  Case "%" ' %, /%
		    If Match("=") Then
		      AddToken(Roo.TokenType.PERCENT_EQUAL)
		      Return
		    Else
		      AddToken(Roo.TokenType.PERCENT)
		      Return
		    End If
		  Case ">" ' >, >=, >>
		    If Match("=") Then
		      AddToken(Roo.TokenType.GREATER_EQUAL)
		      Return
		    ElseIf Match(">") Then
		      AddToken(Roo.TokenType.GREATER_GREATER)
		      Return
		    Else
		      AddToken(Roo.TokenType.GREATER)
		      Return
		    End If
		  Case "<" ' <, <=, <>, <<
		    If Match("=") Then
		      AddToken(Roo.TokenType.LESS_EQUAL)
		      Return
		    ElseIf Match(">") Then
		      AddToken(Roo.TokenType.NOT_EQUAL)
		      Return
		    ElseIf Match("<") Then
		      AddToken(Roo.TokenType.LESS_LESS)
		      Return
		    Else
		      AddToken(Roo.TokenType.LESS)
		      Return
		    End If
		    
		    // ---------------------------------------------------------------
		    // Text.
		    // ---------------------------------------------------------------
		  Case """"
		    Tokens.Append(TextToken(TextDelimiter.DoubleQuote))
		    Return
		  Case "'"
		    Tokens.Append(TextToken(TextDelimiter.SingleQuote))
		    Return
		  End Select
		  
		  // Identifier?
		  If IsAlpha(c) Then
		    Dim tok As RooToken = Identifier
		    If tok.type = Roo.TokenType.REQUIRE_KEYWORD Then
		      HandleRequire
		      Return
		    Else
		      Tokens.Append(tok)
		      Return
		    End If
		  End If
		  
		  // Houston we have a problem.
		  Raise New RooScannerError(SourceFile, "Unexpected character (" + c + ")", Line, Start)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function SingleCharacterCodePoint(t As Text) As UInt32
		  // This method returns the unicode codepoint of the first character in the passed Text object.
		  
		  For Each c As UInt32 In t.Codepoints
		    Return c
		  Next c
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub SkipWhitespace()
		  // Advance the scanner past meaningless whitespace.
		  // We also need to handle indentation and dedentation.
		  
		  Do
		    
		    Select Case Peek
		    Case " " // Simple space.
		      If AtLogicalLineStart Then
		        // Whitespace other tabs is not allowed at the beginning of a logical line.
		        Raise New RooScannerError(SourceFile, "Unexpected whitespace at beginning of line", Line, Start)
		      Else
		        Advance
		      End If
		      
		    Case &u09 // Tab.
		      If AtLogicalLineStart Then
		        HandleIndentation
		      Else
		        Advance
		      End If
		      
		    Case &u0A // Newline.
		      Line = Line + 1
		      If EndOfLogicalLine Then
		        AddTerminatorToken
		        Advance
		        AtLogicalLineStart = True // Since we've just advanced past the newline character.
		        HandleIndentation
		      Else
		        Advance
		      End If
		      
		    Case "#" // Comment. These go to the end of the line.
		      
		      Do
		        mPeekChar = Peek
		        If mPeekChar = &u0A Or mPeekChar = "" Then Exit
		        Advance
		      Loop
		      
		      If mPeekChar = &u0A Then
		        Line = Line + 1 // Remember to increment the line number.
		        If EndOfLogicalLine Then
		          AddTerminatorToken
		          Advance
		          AtLogicalLineStart = True // Since we've just advanced past the newline character.
		          HandleIndentation
		        Else
		          Advance
		        End If
		      End If
		      
		    Else
		      Return
		    End Select
		    
		  Loop
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function StandardiseLineEndings(s As String) As String
		  // Convert all line endings in `s` to UNIX ones (i.e. LF, &u0A).
		  
		  Return ReplaceLineEndings(s, &u0A)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function TextToken(delimiterType As TextDelimiter) As RooToken
		  Dim delimiter As Text = If(delimiterType = TextDelimiter.DoubleQuote, """", "'")
		  
		  Dim previousChar As String = ""
		  Dim escapedDelimiterCount As Integer = 0
		  
		  Do
		    If Current > SourceLength Then Exit
		    mPeekChar = Source.Mid(current, 1)
		    If mPeekChar = delimiter Then
		      // We've found the closing delimiter UNLESS it's been escaped with `\`.
		      If previousChar <> "\" Then
		        Exit
		      Else
		        // This is an escaped delimiter. Flag that it needs removing later.
		        escapedDelimiterCount = escapedDelimiterCount + 1
		      End If
		    End If
		    If mPeekChar = &u0A Then Line = Line + 1 // Handle multiline text.
		    Advance // Advance to consume the character.
		    
		    // Keep track of this character before we loop again.
		    previousChar = mPeekChar
		  Loop
		  
		  // Did the user terminate the text?
		  If Current > SourceLength Then
		    Raise New RooScannerError(sourceFile, "Unterminated text literal", Line, Start)
		  End If
		  
		  // Consume the closing delimiter.
		  Advance
		  
		  // Create the token. We do it here rather than MakeToken() because the 
		  // lexeme is handled differently.
		  Dim token As New RooToken
		  token.Type = Roo.TokenType.TEXT
		  token.Start = Start - 1
		  token.Length = Current - Start - 2 // The lexeme won't contain the flanking delimiters.
		  token.Finish = Current - 2
		  token.Lexeme = source.Mid(Start + 1, token.Length) // Need to remove the flanking delimiters.
		  token.Line = Line
		  token.File = SourceFile
		  
		  // Do we need to handle escaped delimiters?
		  If escapedDelimiterCount > 0 Then
		    If delimiterType = TextDelimiter.DoubleQuote Then
		      token.Lexeme = token.Lexeme.ReplaceAll("\" + Chr(34), Chr(34))
		    ElseIf delimiterType = TextDelimiter.SingleQuote Then
		      token.Lexeme = token.Lexeme.ReplaceAll("\'", "'")
		    End If
		  End If
		  
		  Return token
		End Function
	#tag EndMethod


	#tag Hook, Flags = &h0
		Event Error(file As FolderItem, message As String, line As Integer, position As Integer)
	#tag EndHook


	#tag Property, Flags = &h21
		#tag Note
			Contains the alpha characters A-Z, a-z and _ for fast lookup.
		#tag EndNote
		Private AlphaCharacters As Xojo.Core.Dictionary
	#tag EndProperty

	#tag Property, Flags = &h21
		Private AtLogicalLineStart As Boolean = True
	#tag EndProperty

	#tag Property, Flags = &h21
		Private Current As Integer
	#tag EndProperty

	#tag Property, Flags = &h21
		#tag Note
			Stores files that do not need to be required again as they have previously
			already been required by the script.
			
			Key = Native path of the file
			Value = True
		#tag EndNote
		Private DoNotRequire As Dictionary
	#tag EndProperty

	#tag Property, Flags = &h21
		Private IndentationStack() As Integer
	#tag EndProperty

	#tag Property, Flags = &h21
		Private Line As Integer
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mCodePoint As Integer
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mPeekChar As String
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mRequireRoot As FolderItem
	#tag EndProperty

	#tag Property, Flags = &h21
		#tag Note
			Every time the scanner encounter a LCURLY token, this value is incremented. Everytime a 
			RCURLY token is encounted, it is decremented. This is used to determine whether a NEWLINE token 
			should be generated or not.
		#tag EndNote
		Private mUnclosedCurlyCount As Integer = 0
	#tag EndProperty

	#tag Property, Flags = &h21
		#tag Note
			Every time the scanner encounter a LPAREN token, this value is incremented. Everytime a 
			RPAREN token is encounted, it is decremented. This is used to determine whether a NEWLINE token 
			should be generated or not.
		#tag EndNote
		Private mUnclosedParenCount As Integer = 0
	#tag EndProperty

	#tag Property, Flags = &h21
		#tag Note
			Every time the scanner encounter a LSQUARE token, this value is incremented. Everytime a 
			RSQUARE token is encounted, it is decremented. This is used to determine whether a NEWLINE token 
			should be generated or not.
		#tag EndNote
		Private mUnclosedSquareCount As Integer = 0
	#tag EndProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  Return mRequireRoot
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  // The require root folder must be a directory and must exist.
			  If value = Nil Or Not value.Exists Or Not value.Directory Then
			    Dim err As NilObjectException
			    err.Message = "The RootFolder property of a RooScanner must be a valid directory"
			    Raise err
			  Else
			    mRequireRoot = value
			  End If
			End Set
		#tag EndSetter
		RequireRoot As FolderItem
	#tag EndComputedProperty

	#tag Property, Flags = &h21
		Private Source As String
	#tag EndProperty

	#tag Property, Flags = &h21
		Private SourceFile As FolderItem
	#tag EndProperty

	#tag Property, Flags = &h21
		Private SourceLength As Integer
	#tag EndProperty

	#tag Property, Flags = &h21
		Private Start As Integer
	#tag EndProperty

	#tag Property, Flags = &h21
		Private Tokens() As RooToken
	#tag EndProperty


	#tag Constant, Name = kQuote, Type = String, Dynamic = False, Default = \"\"", Scope = Public
	#tag EndConstant


	#tag Enum, Name = TextDelimiter, Flags = &h0
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
	#tag EndViewBehavior
End Class
#tag EndClass
