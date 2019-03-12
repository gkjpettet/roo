#tag Class
Protected Class RooParser
	#tag Method, Flags = &h21
		Private Function ActuallyParse() As RooStmt()
		  // This method actually does the parsing. It's called from one of the two Parse() methods after 
		  // those methods have correctly setup the scanner.
		  
		  Redim Tokens(-1)
		  Current = 0
		  HasError = False
		  
		  Dim statements() As RooStmt
		  
		  // Tokenise the source code.
		  Tokens = scanner.Scan
		  
		  // If a error occurred whilst scanning, it will have already fired our custom 
		  // ScanningError event and set HasError to True.
		  If HasError Then Return statements
		  
		  // Bail early if there is only an EOF token.
		  If Tokens.Ubound = 0 Then Return statements
		  
		  // Parse the tokens.
		  Dim s As RooStmt
		  While Tokens(Current).Type <> Roo.TokenType.EOF
		    s = Declaration
		    If s <> Nil Then statements.Append(s)
		  Wend
		  
		  // Return the AST.
		  Return statements
		  
		  Exception err As RooParserError
		    HasError = True
		    ParsingError(err.Token, err.Message)
		    Return statements // Return what we managed to successfully parse.
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function Addition() As RooExpr
		  // Addition → Multiplication ( ( MINUS | PLUS ) Multiplication )*
		  
		  Dim operator As RooToken
		  Dim right As RooExpr
		  
		  Dim expr As RooExpr = Multiplication
		  
		  While Match(Roo.TokenType.MINUS, Roo.TokenType.PLUS)
		    operator = Tokens(Current - 1)
		    right = Multiplication
		    expr = New RooBinaryExpr(expr, operator, right)
		  Wend
		  
		  Return expr
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub Advance()
		  // Consumes the current token WITHOUT returning it.
		  
		  If Tokens(Current).Type <> Roo.TokenType.EOF Then Current = Current + 1
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function Advance() As RooToken
		  // Consumes the current token and returns it.
		  
		  If Tokens(Current).Type <> Roo.TokenType.EOF Then Current = Current + 1
		  
		  Return Tokens(Current - 1)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function Assignment() As RooExpr
		  // Assignment → ( CALL DOT )? IDENTIFIER 
		  //          (EQUAL | PLUS_EQUAL | MINUS_EQUAL | STAR_EQUAL | SLASH_EQUAL | PERCENT_EQUAL) Assignment
		  //            | Ternary
		  
		  Dim expr As RooExpr = Ternary
		  
		  If Match(Roo.TokenType.EQUAL, Roo.TokenType.PLUS_EQUAL, Roo.TokenType.MINUS_EQUAL, _
		    Roo.TokenType.STAR_EQUAL, Roo.TokenType.SLASH_EQUAL, Roo.TokenType.PERCENT_EQUAL) Then
		    
		    Dim operator As RooToken = Tokens(Current - 1)
		    Dim value As RooExpr = Assignment
		    
		    If expr IsA RooVariableExpr Then
		      Dim name As RooToken = RooVariableExpr(expr).Name
		      Return New RooAssignExpr(name, value, operator)
		      
		    ElseIf expr IsA RooGetExpr Then
		      Dim get As RooGetExpr = RooGetExpr(expr)
		      Return New RooSetExpr(get.Obj, get.Name, value, operator)
		      
		    ElseIf expr IsA RooArrayExpr Then
		      Dim name As RooToken = RooArrayExpr(expr).Name
		      Dim index As RooExpr = RooArrayExpr(expr).Index
		      Return New RooArrayAssignExpr(name, index, value, operator)
		      
		    ElseIf expr IsA RooHashExpr Then
		      Dim name As RooToken = RooHashExpr(expr).Name
		      Dim key As RooExpr = RooHashExpr(expr).Key
		      Return New RooHashAssignExpr(name, key, value, operator)
		      
		    End If
		    
		    Raise New RooParserError(operator, "Invalid assignment target.")
		    
		  End If
		  
		  Return expr
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function Bitwise() As RooExpr
		  // Bitwise → Addition ( ( AMPERSAND | PIPE | LESS_LESS | GREATER_GREATER) Addition )*
		  
		  Dim operator As RooToken
		  Dim right As RooExpr
		  
		  Dim expr As RooExpr = Addition
		  
		  While Match(Roo.TokenType.AMPERSAND, Roo.TokenType.PIPE, _
		    Roo.TokenType.LESS_LESS, Roo.TokenType.GREATER_GREATER)
		    
		    operator = Tokens(Current - 1)
		    right = Addition
		    expr = New RooBitwiseExpr(expr, operator, right)
		    
		  Wend
		  
		  Return expr
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function Block() As RooStmt()
		  // Block → Declaration* DEDENT
		  // Remember that this method assumes that the INDENT has already been matched.
		  
		  Dim statements() As RooStmt
		  
		  While Not Check(Roo.TokenType.DEDENT) And Tokens(Current).Type <> Roo.TokenType.EOF
		    statements.Append(Declaration)
		    If statements(statements.Ubound) = Nil Then
		      // Something has gone wrong parsing this block. 
		      HasError = True
		      Exit
		    End If
		  Wend
		  
		  If HasError Then Raise New RooParserError(Tokens(Current), "Unable to parse block.")
		  
		  Consume(Roo.TokenType.DEDENT, "Expected dedentation after block.")
		  
		  Return statements
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function BreakStatement() As RooStmt
		  // BreakStmt → BREAK TERMINATOR
		  // BreakStmt → BREAK (IF Expression)? TERMINATOR
		  
		  Dim condition As RooExpr
		  
		  // Get a reference to the triggering `break` token in case we encounter an error and need
		  // to inform the user of it's position in the source code.
		  Dim keyword As RooToken = Tokens(Current - 1)
		  
		  // Is there a break condition?
		  If Match(Roo.TokenType.IF_KEYWORD) Then condition = Expression
		  
		  Consume(Roo.TokenType.TERMINATOR, "Expected a new line or semicolon after the `break` keyword.")
		  
		  Return New RooBreakStmt(keyword, condition)
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function Check(type As Roo.TokenType) As Boolean
		  // Returns True if the current token type matches `type`, otherwise we return False. 
		  // Unlike Match(), it doesn't consume the token.
		  
		  Return If(Tokens(Current).Type = type, True, False)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function ClassDeclaration() As RooClassStmt
		  // ClassDeclaration → CLASS IDENTIFIER ( LESS IDENTIFIER )? COLON (PASS | INDENT (PASS | FunctionDeclaration*) DEDENT)
		  
		  Dim name As RooToken = Consume(Roo.TokenType.IDENTIFIER, "Expected a class name.")
		  
		  // Has a superclass been defined?
		  Dim superclass As RooVariableExpr = Nil
		  If Match(Roo.TokenType.LESS) Then
		    Consume(Roo.TokenType.IDENTIFIER, "Expected a superclass name.")
		    superclass = New RooVariableExpr(Tokens(Current - 1))
		  End If
		  
		  // Check for the colon.
		  Consume(Roo.TokenType.COLON, "Expected a `:` before class body.")
		  
		  Dim staticMethods(), methods() As RooFunctionStmt
		  If Match(Roo.TokenType.PASS_KEYWORD) Then
		    // There is no substance to this class definition.
		    Consume(Roo.TokenType.TERMINATOR, "Expected a new line or semicolon after the `pass` statement.")
		  Else
		    // There is a body to the definition - get it.
		    // Get any static and instance methods.
		    Consume(Roo.TokenType.INDENT, "Expected an indentation after class declaration.")
		    While Not Check(Roo.TokenType.DEDENT) And Tokens(Current).Type <> Roo.TokenType.EOF
		      If Tokens(Current).Type = Roo.TokenType.STATIC_KEYWORD Then
		        Advance
		        staticMethods.Append(FunctionDeclaration("method"))
		      ElseIf Tokens(Current).Type = Roo.TokenType.DEF_KEYWORD Then
		        Advance
		        methods.Append(FunctionDeclaration("method"))
		      ElseIf Tokens(Current).Type = Roo.TokenType.PASS_KEYWORD Then
		        Advance
		        Consume(Roo.TokenType.TERMINATOR, "Expected a new line or semicolon after the `pass` statement.")
		      Else
		        Raise New RooParserError(Tokens(Current), "Expected a method name.")
		      End If
		    Wend
		    Consume(Roo.TokenType.DEDENT, "Expected dedentation after class body.")
		  End If
		  
		  Return New RooClassStmt(name, superclass, staticMethods, methods)
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function Comparison() As RooExpr
		  // Comparison → Bitwise ( ( GREATER | GREATER_EQUAL | LESS | LESS_EQUAL ) Bitwise )*
		  
		  Dim operator As RooToken
		  Dim right As RooExpr
		  
		  Dim expr As RooExpr = Bitwise
		  
		  While Match(Roo.TokenType.GREATER, Roo.TokenType.GREATER_EQUAL, Roo.TokenType.LESS, _
		    Roo.TokenType.LESS_EQUAL)
		    operator = Tokens(Current - 1)
		    right = Bitwise
		    expr = New RooBinaryExpr(expr, operator, right)
		  Wend
		  
		  Return expr
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub Consume(type As Roo.TokenType, message As String)
		  // Checks to see if the current token's type is `type`. If so we consume the current token and 
		  // return. Otherwise we raise an error.
		  
		  #Pragma BreakOnExceptions False
		  
		  If Check(type) Then
		    Advance
		    Return
		  End If
		  
		  // Houston, we have a problem.
		  HasError = True
		  Raise New RooParserError(Tokens(Current), message)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function Consume(type As Roo.TokenType, message As String) As RooToken
		  // Checks to see if the current token's type is `type`. If so we return the current token.
		  
		  #Pragma BreakOnExceptions False
		  
		  If Check(type) Then Return Advance
		  
		  // Houston, we have a problem.
		  HasError = True
		  Raise New RooParserError(Tokens(Current), message)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function Declaration() As RooStmt
		  // Declaration → VarDeclaration | FunctionDeclaration 
		  //             | ClassDeclaration | ModuleDeclaration
		  //             | Statement
		  
		  If Match(Roo.TokenType.VAR) Then Return VarDeclaration
		  If Match(Roo.TokenType.DEF_KEYWORD) Then Return FunctionDeclaration("function")
		  If Match(Roo.TokenType.CLASS_KEYWORD) Then Return ClassDeclaration
		  If Match(Roo.TokenType.MODULE_KEYWORD) Then Return ModuleDeclaration
		  
		  Return Statement
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function Equality() As RooExpr
		  // Equality → Comparison ( ( NOT_EQUAL | EQUAL_EQUAL ) Comparison )*
		  
		  Dim operator As RooToken
		  Dim right As RooExpr
		  
		  Dim expr As RooExpr = Comparison
		  
		  While Match(Roo.TokenType.NOT_EQUAL, Roo.TokenType.EQUAL_EQUAL)
		    
		    operator = Previous
		    right = Comparison
		    expr = New RooBinaryExpr(expr, operator, right)
		    
		  Wend
		  
		  Return expr
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function ExitStatement() As RooStmt
		  // ExitStmt → EXIT TERMINATOR
		  
		  // Get a reference to the triggering `exit` token in case we encounter an error and need
		  // to inform the user of it's position in the source code.
		  Dim keyword As RooToken = Tokens(Current - 1)
		  
		  Consume(Roo.TokenType.TERMINATOR, "Expected a new line or semicolon after the `exit` keyword.")
		  
		  Return New RooExitStmt(keyword)
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function Expression() As RooExpr
		  // Expression → Assignment
		  
		  Return Assignment
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function ExpressionStatement() As RooStmt
		  Dim expr As RooExpr = Expression
		  
		  Consume(Roo.TokenType.TERMINATOR, "Expected a new line or semicolon after expression.")
		  
		  If expr <> Nil Then
		    Return New RooExpressionStmt(expr)
		  Else
		    Return Nil
		  End If
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function FinishInvoke(invokee As RooExpr) As RooExpr
		  // Used in conjunction with Invoke() to parse the (optional) arguments list.
		  
		  Dim arguments() As RooExpr
		  
		  If Not Check(Roo.TokenType.RPAREN) Then
		    
		    Do
		      If arguments.Ubound = 7 Then
		        // Limit the number of arguments to 8 (simplifies things in our future VM implementation).
		        HasError = True
		        Raise new RooParserError(Tokens(Current), "Cannot have more than 8 arguments.")
		      end if
		      
		      arguments.Append(Expression)
		      
		    Loop Until Not Match(Roo.TokenType.COMMA)
		  End If
		  
		  Dim paren As RooToken = Consume(Roo.TokenType.RPAREN, "Expected `)` after arguments.")
		  
		  Return New RooInvokeExpr(invokee, paren, arguments)
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function ForStatement() As RooStmt
		  // ForStmt → FOR LPAREN (VarDeclaration | ExpressionStmt | TERMINATOR ) 
		  //           Expression? TERMINATOR Expression? RPAREN COLON Block
		  
		  // E.g: for (var i = 0; i < 10; i = i + 1) print(i)
		  
		  Consume(Roo.TokenType.LPAREN, "Expected `(` after for keyword.")
		  
		  // Get the initialiser (if defined).
		  Dim initialiser As RooStmt
		  If Match(Roo.TokenType.TERMINATOR) Then
		    initialiser = Nil // The initialiser has been omitted.
		  ElseIf Match(Roo.TokenType.VAR) Then
		    initialiser = VarDeclaration
		  Else
		    initialiser = ExpressionStatement
		  End If
		  
		  // Get the loop condition (if defined).
		  Dim condition As RooExpr = Nil
		  If Not Check(Roo.TokenType.TERMINATOR) Then condition = Expression
		  Consume(Roo.TokenType.TERMINATOR, "Expected `;` after for loop condition.")
		  
		  // Get the increment (if defined).
		  Dim increment As RooExpr = Nil
		  If Not Check(Roo.TokenType.RPAREN) Then increment = Expression
		  Consume(Roo.TokenType.RPAREN, "Expected `)` after for loop clauses.")
		  
		  // Check for a colon.
		  Consume(Roo.TokenType.COLON, "Expected a `:` before for loop block.")
		  
		  // Get the loop body.
		  Dim body As RooStmt = Statement
		  
		  // Desugar to a while loop.
		  // The increment, if there is one, executes after the body in each iteration of the loop.
		  // We do that by replacing the body with a little block that contains the original body
		  // followed by an expression statement that evaluates the increment.
		  If increment <> Nil Then
		    Dim blockStatements() As RooStmt // HACK: Xojo can't create an array of subclasses using the `Array` keyword.
		    blockStatements.Append(body)
		    blockStatements.Append(New RooExpressionStmt(increment))
		    body = New RooBlockStmt(blockStatements)
		  End If
		  
		  // Next, we take the condition and the body and build the loop using a primitive while loop.
		  // If the condition is omitted, we jam in True to make an infinite loop.
		  If condition = Nil Then condition = New RooBooleanLiteralExpr(True)
		  body = New RooWhileStmt(condition, body)
		  
		  // Finally, if there's an initializer, it runs once before the entire loop. We do that by,
		  // again, replacing the whole statement with a block that runs the initializer and then executes the loop.
		  If initialiser <> Nil Then body = New RooBlockStmt(Array(initialiser, body))
		  
		  Return body
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function FunctionDeclaration(kind As String) As RooFunctionStmt
		  // FunctionStmt → IDENTIFIER (LPAREN parameters? RPAREN)? COLON (PASS | INDENT Block)
		  
		  // A method (NOT a function) can be declared without parentheses to signify that it is a getter method.
		  // Getter declarations are represented in the FunctionStmt by setting the `parameters` array to Nil. 
		  // Methods that take no parameters will set `parameters` to an empty array. This is a very important
		  // distinction and we must be careful to check for Nil when utilising the `parameters` property in the 
		  // Resolver and the Interpeter. 
		  
		  Dim name As RooToken = Consume(Roo.TokenType.IDENTIFIER, "Expected a " + kind + " name. ")
		  
		  Dim parameters() As RooToken
		  If kind <> "method" Or Check(Roo.TokenType.LPAREN) Then
		    Consume(Roo.TokenType.LPAREN, "Expected `(` after " + kind + " name.")
		    If Not Check(Roo.TokenType.RPAREN) Then
		      Do
		        If parameters.Ubound = 7 Then
		          ' Limit the number of parameters to 8 (simplifies things in our future VM implementation).
		          HasError = True
		          Raise New RooParserError(Tokens(Current), "Cannot have more than 8 parameters.")
		        End If
		        parameters.Append(Consume(Roo.TokenType.IDENTIFIER, "Expected parameter name."))
		      Loop Until Not Match(Roo.TokenType.COMMA)
		    End If
		    Consume(Roo.TokenType.RPAREN, "Expected a `)` after parameters.")
		  Else
		    parameters = Nil
		  End If
		  
		  Consume(Roo.TokenType.COLON, "Expected a `:` before " + kind + " body.")
		  
		  Dim body() As RooStmt
		  If Match(Roo.TokenType.PASS_KEYWORD) Then
		    Consume(Roo.TokenType.TERMINATOR, "Expected a new line or semicolon after the `pass` statement.")
		  Else
		    Consume(Roo.TokenType.INDENT, "Expected an indentation before " + kind + " body.")
		    body = Block
		  End If
		  
		  Return New RooFunctionStmt(name, parameters, body)
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function IfStatement() As RooStmt
		  // IfStmt → IF Expression COLON Statement
		  
		  // Get the primary condition.
		  Dim condition As RooExpr = Expression
		  Consume(Roo.TokenType.COLON, "Expected a `:` after `if` condition.")
		  
		  // Get the primary if statement.
		  Dim thenBranch As RooStmt = Statement
		  
		  // Get any `or` clauses.
		  Dim orClauses(-1) As RooOrStmt
		  Dim tmpExpr As RooExpr
		  Dim tmpStmt As RooStmt
		  While Check(Roo.TokenType.OR_KEYWORD)
		    // Move past the `or` keyword we know is present.
		    Advance
		    // Get this `or` clause's condition.
		    tmpExpr = Expression
		    Consume(Roo.TokenType.COLON, "Expected a `:` after `or` condition.")
		    // Get the statement to execute if this `or` clause is true.
		    tmpStmt = Statement
		    orClauses.Append(New RooOrStmt(tmpExpr, tmpStmt))
		  Wend
		  
		  // Is there an optional `else` clause?
		  Dim elseBranch As RooStmt = Nil
		  If Match(Roo.TokenType.ELSE_KEYWORD) Then
		    Consume(Roo.TokenType.COLON, "Expected a `:` after `else` keyword")
		    elseBranch = Statement
		  End If
		  
		  Return New RooIfStmt(condition, thenBranch, orClauses, elseBranch)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function Invoke() As RooExpr
		  // Invoke → Primary ( LPAREN arguments? RPAREN | DOT IDENTIFIER )*
		  
		  Dim expr As RooExpr = Primary
		  
		  While True
		    
		    If Match(Roo.TokenType.LPAREN) Then
		      // Each time we find a `(`, use FinishInvoke() to parse the Invoke expression using the 
		      // previously parsed expression as the invokee. The returned expression becomes the new 
		      // expr and then loop to see if the result is itself called.
		      expr = FinishInvoke(expr)
		    ElseIf Match(Roo.TokenType.DOT) Then
		      Dim name As RooToken = Consume(Roo.TokenType.IDENTIFIER, "Expected a property name after `.`.")
		      
		      // Is the identifier an array or hash?
		      If Match(Roo.TokenType.LSQUARE) Then // Array.
		        Dim index As RooExpr = Expression
		        Consume(Roo.TokenType.RSQUARE, "Expected a `]` after an array index.")
		        expr = New RooGetExpr(expr, name, index)
		      ElseIf Peek.Type = Roo.TokenType.LCURLY Then // Hash.
		        Advance // Move past the `{` we just checked and know is present.
		        Dim key As RooExpr = Expression
		        Consume(Roo.TokenType.RCURLY, "Expected a `}` after a hash key.")
		        expr = New RooGetExpr(expr, name, key)
		      Else
		        expr = New RooGetExpr(expr, name)
		      End If
		    Else
		      Exit
		    End If
		    
		  Wend
		  
		  Return expr
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function KeyValue() As Pair
		  // Return the next key-value pair.
		  // Valid format is:
		  // KEY => VALUE
		  // Where KEY and VALUE are both valid expressions.
		  // Returns a Pair where Left is the key and Right is the value.
		  
		  Dim key As RooExpr = Expression
		  
		  Consume(Roo.TokenType.ARROW, "Expected `=>` operator after hash key.")
		  
		  Dim value As RooExpr = Expression
		  
		  Return new Pair(key, value)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function LogicAnd() As RooExpr
		  // LogicAnd → Equality ( AND Equality )*
		  
		  Dim operator As RooToken
		  Dim right As RooExpr
		  
		  Dim expr As RooExpr = Equality
		  
		  While Match(Roo.TokenType.AND_KEYWORD)
		    
		    operator = Tokens(Current - 1)
		    right = Equality
		    expr = New RooLogicalExpr(expr, operator, right)
		    
		  Wend
		  
		  Return expr
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function LogicOr() As RooExpr
		  // LogicOr → LogicAnd ( OR LogicAnd )*
		  
		  Dim operator As RooToken
		  Dim right As RooExpr
		  
		  Dim expr As RooExpr = LogicAnd
		  
		  While Match(Roo.TokenType.OR_KEYWORD)
		    
		    operator = Tokens(Current - 1)
		    right = LogicAnd
		    expr = New RooLogicalExpr(expr, operator, right)
		    
		  Wend
		  
		  Return expr
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function MakeNumberLiteral(lexeme As String, base As RooToken.BaseType) As RooNumberLiteralExpr
		  // Creates a new RooNumberLiteralExpr from the passed lexeme and base type.
		  
		  Select Case base
		  Case RooToken.BaseType.Decimal
		    Return New RooNumberLiteralExpr(lexeme.Val)
		  Case RooToken.BaseType.Hexadecimal
		    Dim hexValue As Text = lexeme.Replace("0x", "").ToText
		    Return New RooNumberLiteralExpr(Integer.FromHex(hexValue))
		  Case RooToken.BaseType.Binary
		    Dim binaryValue As Text = lexeme.Replace("0b", "").ToText
		    Return New RooNumberLiteralExpr(Integer.FromBinary(binaryValue))
		  Case RooToken.BaseType.Octal
		    Dim octalValue As Text = lexeme.Replace("0o", "").ToText
		    Return New RooNumberLiteralExpr(Integer.FromOctal(octalValue))
		  End Select
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function Match(ParamArray types As Roo.TokenType) As Boolean
		  // Checks to see if the current token is any of the passed types. If it is then the token is 
		  // consumed and we return True. Otherwise we leave the token where it is and return False.
		  
		  For Each type As Roo.TokenType In types
		    If Check(type) Then
		      If Tokens(Current).Type <> Roo.TokenType.EOF Then Current = Current + 1
		      Return True
		    End If
		  Next type
		  
		  Return False
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function ModuleDeclaration() As RooModuleStmt
		  // ModuleDeclaration → MODULE IDENTIFIER COLON (PASS | INDENT (PASS | ModuleDeclaration | ClassDeclaration | FunctionDeclaration)* DEDENT)
		  
		  Dim name As RooToken = Consume(Roo.TokenType.IDENTIFIER, "Expected a module name.")
		  
		  // Check for the colon.
		  Consume(Roo.TokenType.COLON, "Expected a `:` before module body.")
		  
		  Dim modules() As RooModuleStmt
		  Dim classes() As RooClassStmt
		  Dim methods() As RooFunctionStmt
		  If Match(Roo.TokenType.PASS_KEYWORD) Then
		    // There is no substance to this module definition.
		    Consume(Roo.TokenType.TERMINATOR, "Expected a new line or semicolon after the `pass` statement.")
		  Else
		    // There is a body to this module definition. Get it.
		    Consume(Roo.TokenType.INDENT, "Expected indentation before module body.")
		    // Get any modules, classes and methods defined within the module.
		    While Not Check(Roo.TokenType.DEDENT) And Tokens(Current).Type <> Roo.TokenType.EOF
		      If Check(Roo.TokenType.CLASS_KEYWORD) Then
		        Advance
		        classes.Append(ClassDeclaration)
		      ElseIf Check(Roo.TokenType.MODULE_KEYWORD) Then
		        Advance
		        modules.Append(ModuleDeclaration)
		      ElseIf Check(Roo.TokenType.DEF_KEYWORD) Then
		        Advance
		        methods.Append(FunctionDeclaration("method"))
		      ElseIf Check(Roo.TokenType.PASS_KEYWORD) Then
		        Advance
		        Consume(Roo.TokenType.TERMINATOR, "Expected a new line or semicolon after the `pass` statement.")
		      Else
		        Raise New RooParserError(Tokens(Current), "Expected a module, class or method definition.")
		      End If
		    Wend
		    Consume(Roo.TokenType.DEDENT, "Expected dedentation after module body.")
		  End If
		  
		  Return New RooModuleStmt(name, modules, classes, methods)
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function Multiplication() As RooExpr
		  // Multiplication → Unary ((SLASH|STAR|PERCENT|CARET) Unary)*
		  
		  Dim operator As RooToken
		  Dim right As RooExpr
		  
		  Dim expr As RooExpr = Unary
		  
		  While Match(Roo.TokenType.SLASH, Roo.TokenType.STAR, Roo.TokenType.PERCENT, _
		    Roo.TokenType.CARET)
		    
		    operator = Tokens(Current - 1)
		    right = Unary
		    expr = New RooBinaryExpr(expr, operator, right)
		    
		  Wend
		  
		  Return expr
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Parse(sourceFile As FolderItem) As RooStmt()
		  // Takes a file containing Roo code, builds an abstract syntax tree AST and returns it as an 
		  // array of RooStmts.
		  // If a scanning error occurs we fire the ScannerError event and return an empty array.
		  
		  // Initialise a scanner with this source code.
		  Scanner = New RooScanner(sourceFile)
		  AddHandler Scanner.Error, AddressOf ScannerErrorDelegate
		  
		  // Now parse.
		  Return ActuallyParse
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Parse(source as String) As RooStmt()
		  // Builds an abstract syntax tree AST and returns it as an array of RooStmts.
		  // If a scanning error occurs we fire the ScannerError event and return an empty array.
		  
		  // Initialise a scanner with this source code.
		  Scanner = New RooScanner(source)
		  AddHandler Scanner.Error, AddressOf ScannerErrorDelegate
		  
		  // Now parse.
		  Return ActuallyParse
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function PassStatement() As RooStmt
		  // PassStmt → PASS TERMINATOR
		  
		  // Get a reference to the triggering `pass` token in case we encounter an error and need
		  // to inform the user of it's position in the source code.
		  Dim keyword As RooToken = Tokens(Current - 1)
		  
		  Consume(Roo.TokenType.TERMINATOR, "Expected a new line or semicolon after the `pass` keyword.")
		  
		  Return New RooPassStmt(keyword)
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function Peek() As RooToken
		  // Returns the current token we have yet to consume.
		  
		  Return Tokens(Current)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function Previous() As RooToken
		  // Returns the most recently consumed token.
		  
		  Return Tokens(Current - 1)
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function Primary() As RooExpr
		  // Primary → BOOLEAN | NOTHING | SELF | NUMBER | TEXT
		  //         | LPAREN Expression RPAREN 
		  //         | IDENTIFIER
		  //         | SUPER DOT IDENTIFIER 
		  //         | LSQUARE arguments? RSQUARE
		  
		  // Simple literals (booleans, numbers, nothing and text).
		  If Match(Roo.TokenType.Boolean) Then
		    Return New RooBooleanLiteralExpr(StringToBoolean(Tokens(Current - 1).Lexeme))
		  End If
		  If Match(Roo.TokenType.NUMBER) Then
		    Return MakeNumberLiteral(Tokens(Current - 1).Lexeme, Tokens(Current - 1).Base)
		  End If
		  If Match(Roo.TokenType.NOTHING) Then Return New RooNothingExpr
		  If Match(Roo.TokenType.TEXT) Then Return New RooTextLiteralExpr(Tokens(Current - 1).Lexeme)
		  
		  // Array literal? (E.g: [1, 3, "a"]).
		  If Match(Roo.TokenType.LSQUARE) Then
		    Dim elements() As RooExpr
		    If Tokens(Current).Type = Roo.TokenType.RSQUARE Then // Empty array []
		      Current = Current + 1 // Consume the `]`
		      Return New RooArrayLiteralExpr(elements)
		    End If
		    Do
		      elements.Append(Expression)
		    Loop Until Not Match(Roo.TokenType.COMMA)
		    If Not Match(Roo.TokenType.RSQUARE) Then
		      Raise New RooParserError(Tokens(Current - 1), _
		      "Expected a closing square bracket after an array literal list.")
		    End If
		    Return New RooArrayLiteralExpr(elements)
		  End If
		  
		  // Hash literal? (E.g: {"a" => 1, "b" => 2}).
		  If Match(Roo.TokenType.LCURLY) Then
		    Dim keyValues() As Pair
		    If Tokens(Current).Type = Roo.TokenType.RCURLY Then // Empty hash {}
		      Current = Current + 1 // Consume the `}`
		      Return New RooHashLiteralExpr(keyValues)
		    End If
		    Do
		      keyValues.Append(KeyValue)
		    Loop Until Not Match(Roo.TokenType.COMMA)
		    If Not Match(Roo.TokenType.RCURLY) Then
		      Raise New RooParserError(Tokens(Current - 1), _
		      "Expected a closing `}` after a hash literal list.")
		    End If
		    Return New RooHashLiteralExpr(keyValues)
		  End If
		  
		  // Self.
		  If Match(Roo.TokenType.SELF_KEYWORD) Then Return New RooSelfExpr(Tokens(Current - 1))
		  
		  // Super.
		  If Match(Roo.TokenType.SUPER_KEYWORD) Then
		    Dim keyword As RooToken = Tokens(Current - 1)
		    Consume(Roo.TokenType.DOT, "Expected superclass method name after `super.`.")
		    Dim method As RooToken = Consume(Roo.TokenType.IDENTIFIER, "Expected superclass method name.")
		    Return New RooSuperExpr(keyword, method)
		  End If
		  
		  // Grouping expression.
		  If Match(Roo.TokenType.LPAREN) Then
		    Dim expr As RooExpr = Expression
		    Consume(Roo.TokenType.RPAREN, "Expected ')' after expression.")
		    Return New RooGroupingExpr(expr)
		  End If
		  
		  // Variable, array and hash access.
		  If Match(Roo.TokenType.IDENTIFIER) Then
		    Dim identifier As RooToken = Tokens(Current - 1)
		    If Match(Roo.TokenType.LSQUARE) Then // Array? (e.g: a[3])
		      Dim index As RooExpr = Expression
		      Consume(Roo.TokenType.RSQUARE, "Expected a closing `]` after an array index.")
		      Return New RooArrayExpr(identifier, index)
		    ElseIf Match(Roo.TokenType.LCURLY) Then // Hash? (e.g: a{"name"})
		      Dim key As RooExpr = Expression
		      Consume(Roo.TokenType.RCURLY, "Expected a closing `}` after a hash key.")
		      Return New RooHashExpr(identifier, key)
		    Else
		      Return New RooVariableExpr(Tokens(Current - 1))
		    End If
		  End If
		  
		  // Houston, we have a problem.
		  HasError = True
		  #Pragma BreakOnExceptions False
		  Raise New RooParserError(Tokens(Current), "Syntax error. Unexpected token: " + _
		  RooToken.TypeToString(Tokens(Current).Type))
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function QuitStatement() As RooStmt
		  // QuitStmt → QUIT TERMINATOR
		  
		  // Get a reference to the triggering `quit` token in case we encounter an error and need
		  // to inform the user of it's position in the source code.
		  Dim keyword As RooToken = Tokens(Current - 1)
		  
		  Consume(Roo.TokenType.TERMINATOR, "Expected a new line or semicolon after the quit keyword.")
		  
		  Return New RooQuitStmt(keyword)
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function ReturnStatement() As RooStmt
		  // ReturnStmt → RETURN TERMINATOR
		  
		  // Get a reference to the `return` keyword for prettier error reporting later (if one occurs).
		  Dim keyword As RooToken = Tokens(Current - 1)
		  
		  // Is there a return value? We default to Nothing if there isn't.
		  Dim value As RooExpr = New RooNothingExpr
		  If Not Check(Roo.TokenType.TERMINATOR) Then value = Expression
		  
		  Consume(Roo.TokenType.TERMINATOR, "Expected a new line or semicolon after return value.")
		  
		  Return New RooReturnStmt(keyword, value)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub ScannerErrorDelegate(sender As RooScanner, file As FolderItem, message As String, line As Integer, position As Integer)
		  #Pragma Unused sender
		  
		  HasError = True
		  ScanningError(file, message, line, position)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function Statement() As RooStmt
		  // Statement → ExpressionStatement 
		  //           | Pass
		  //           | Block
		  //           | BreakStmt
		  //           | ExitStmt
		  //           | ForStmt
		  //           | IfStmt
		  //           | QuitStmt
		  //           | ReturnStmt
		  //           | WhileStmt
		  
		  If Match(Roo.TokenType.PASS_KEYWORD) Then Return PassStatement
		  If Match(Roo.TokenType.INDENT) Then Return New RooBlockStmt(Block)
		  If Match(Roo.TokenType.BREAK_KEYWORD) Then Return BreakStatement
		  If Match(Roo.TokenType.EXIT_KEYWORD) Then Return ExitStatement
		  If Match(Roo.TokenType.IF_KEYWORD) Then Return IfStatement
		  If Match(Roo.TokenType.QUIT_KEYWORD) Then Return QuitStatement
		  If Match(Roo.TokenType.FOR_KEYWORD) Then Return ForStatement
		  If Match(Roo.TokenType.RETURN_KEYWORD) Then Return ReturnStatement
		  If Match(Roo.TokenType.WHILE_KEYWORD) Then Return WhileStatement
		  
		  If Match(Roo.TokenType.TERMINATOR) Then Return Nil // Empty statement.
		  
		  Return ExpressionStatement
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function StringToBoolean(s As String) As Boolean
		  Return If(s.Lowercase = "true", True, False)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function Ternary() As RooExpr
		  // Ternary → LogicOr (QUERY Expression COLON Ternary)?
		  
		  Dim expr As RooExpr = LogicOr
		  
		  If Match(Roo.TokenType.QUERY) Then
		    Dim thenBranch As RooExpr = Expression
		    Consume(Roo.TokenType.COLON, "Expected a `:` after `then` condition in ternary operator.")
		    Dim elseBranch As RooExpr = Ternary
		    expr = New RooTernaryExpr(expr, thenBranch, elseBranch)
		  End If
		  
		  Return expr
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function Unary() As RooExpr
		  // Unary → (BANG|NOT|MINUS) Unary
		  //         | Invoke
		  
		  If Match(Roo.TokenType.BANG, Roo.TokenType.NOT_KEYWORD, Roo.TokenType.MINUS) Then
		    
		    Dim operator As RooToken = Tokens(Current - 1)
		    Dim right as RooExpr = Unary
		    
		    Return New RooUnaryExpr(operator, right)
		    
		  End If
		  
		  Return Invoke
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function VarDeclaration() As RooStmt
		  // VarDeclaration → VAR IDENTIFIER ( EQUAL Expression )? TERMINATOR
		  
		  Dim name As RooToken = Consume(Roo.TokenType.IDENTIFIER, "Expected a variable name.")
		  
		  // Is there an initialiser for this variable (e.g: a = 10)?
		  Dim initialiser As RooExpr = Nil
		  If Match(Roo.TokenType.EQUAL) Then initialiser = Expression
		  
		  Consume(Roo.TokenType.TERMINATOR, "Expected either a new line or semicolon after variable declaration.")
		  
		  Return New RooVarStmt(name, initialiser)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function WhileStatement() As RooStmt
		  // WhileStmt → WHILE Expression Statement
		  
		  Dim condition As RooExpr = Expression
		  Consume(Roo.TokenType.COLON, "Expected a `:` after `while` condition.")
		  
		  Dim body As RooStmt = Statement
		  
		  Return New RooWhileStmt(condition, body)
		End Function
	#tag EndMethod


	#tag Hook, Flags = &h0
		Event ParsingError(where As RooToken, message As String)
	#tag EndHook

	#tag Hook, Flags = &h0
		Event ScanningError(file As FolderItem, message As String, line As Integer, position As Integer)
	#tag EndHook


	#tag Property, Flags = &h21
		Private Current As Integer = 0
	#tag EndProperty

	#tag Property, Flags = &h0
		HasError As Boolean = False
	#tag EndProperty

	#tag Property, Flags = &h21
		Private Scanner As RooScanner
	#tag EndProperty

	#tag Property, Flags = &h21
		Private Tokens() As RooToken
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
			Name="HasError"
			Group="Behavior"
			InitialValue="False"
			Type="Boolean"
		#tag EndViewProperty
	#tag EndViewBehavior
End Class
#tag EndClass
